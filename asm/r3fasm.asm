; r3 container for compile
;
format PE64 GUI 5.0

entry start

XRES equ 1024
YRES equ 600

include 'include/win64w.inc'
include 'sdl2.inc'

section '' code readable executable

; from LocoDelAssembly in fasm forum
macro cinvoke64 name, [args]{
common
   PUSH RSP             ;save current RSP position on the stack
   PUSH qword [RSP]     ;keep another copy of that on the stack
   ADD RSP,8
   AND SPL,0F0h         ;adjust RSP to align the stack if not already there
   cinvoke name, args
   POP RSP              ;restore RSP to its original value
}

macro invoke64 name, [args]{
common
   PUSH RSP             ;save current RSP position on the stack
   PUSH qword [RSP]     ;keep another copy of that on the stack
   ADD RSP,8
   AND SPL,0F0h         ;adjust RSP to align the stack if not already there
   invoke name, args
   POP RSP              ;restore RSP to its original value
}

;===============================================
start:
  sub     rsp,40
  cinvoke SDL_CreateWindow,_title,\
    SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,\
    XRES,YRES,SDL_WINDOW_SHOWN
  mov     [window],eax
  cinvoke SDL_ShowCursor,0
  cinvoke SDL_GetWindowSurface,[window]
  mov     rbx,rax
  mov     [screen],eax
  mov     rdi,[rbx+SDL_Surface.pixels]
  mov     [SYSFRAME],rdi

  mov rbp,DATASTK
  xor rax,rax
  call INICIO
  jmp SYSEND

;----- CODE -----
include 'code.asm'
;----- CODE -----

;===============================================
align 16
SYSEND:
  cinvoke SDL_DestroyWindow,[window]
  cinvoke SDL_Quit
  add rsp,40
  ret

;===============================================
align 16
SYSREDRAW:
  cinvoke SDL_UpdateWindowSurface,[window]
  ret

;===============================================
align 16
SYSUPDATE:
  xor eax,eax
  mov [SYSKEY],eax
  mov [SYSCHAR],eax
  cinvoke SDL_Delay,10
  cinvoke64 SDL_PollEvent,evt
  test eax,eax
  jz .endr
  mov eax,[evt.type]
  cmp eax,SDL_KEYDOWN
  je upkeyd
  cmp eax,SDL_KEYUP
  je upkeyu
  cmp eax,SDL_MOUSEBUTTONDOWN
  je upmobd
  cmp eax,SDL_MOUSEBUTTONUP
  je upmobu
  cmp eax,SDL_MOUSEMOTION
  je upmomo
  cmp eax,SDL_TEXTINPUT
  je uptext
  cmp eax,SDL_QUIT
  je SYSEND
.endr:
        ret
upkeyd: ;key=(evt.key.keysym.sym&0xffff)|evt.key.keysym.sym>>16;break;
        mov eax,[evt.key.keysym.sym]
        and eax,0xffff
        mov ebx,[evt.key.keysym.sym]
        shr ebx,16
        or eax,ebx
        mov [SYSKEY],eax
        ret
upkeyu: ;key=0x1000|(evt.key.keysym.sym&0xffff)|evt.key.keysym.sym>>16;break;
        mov eax,[evt.key.keysym.sym]
        and eax,0xffff
        mov ebx,[evt.key.keysym.sym]
        shr ebx,16
        or eax,0x1000
        or eax,ebx
        mov [SYSKEY],eax
        ret
upmobd: ;bm|=evt.button.button;break;
        movzx eax,byte[evt.button.button]
        or [SYSBM],eax
        ret
upmobu: ;bm&=~evt.button.button;break;
        movzx eax,[evt.button.button]
        not eax
        and [SYSBM],eax
        ret
upmomo: ;xm=evt.motion.x;ym=evt.motion.y;break;
        mov eax,[evt.motion.x]
        mov [SYSXM],eax
        mov eax,[evt.motion.y]
        mov [SYSYM],eax
        ret
uptext: ;keychar=*(int*)evt.text.text;break;
        movzx eax,byte[evt.text.text]
        mov [SYSCHAR],eax
        ret

;===============================================
SYSMSEC: ;  ( -- msec )
  add rbp,8
  mov [rbp],rax
  invoke GetTickCount
  ret

;----------------------------------
;SYSMSEC:
;  add rbp,8
;  mov [rbp],rax
;  cinvoke64 SDL_GetTicks
;  ret

;===============================================
align 16
SYSTIME: ;  ( -- hms )
  add rbp,8
  mov [rbp],rax
  invoke GetLocalTime,SysTime
  movzx eax,word [SysTime.wHour]
  shl eax,16
  movzx ebx,word [SysTime.wMinute]
  shl ebx,8
  or eax,ebx
  movzx ebx,word [SysTime.wSecond]
  or eax,ebx
  ret

;===============================================
align 16
SYSDATE: ;  ( -- ymd )
  add rbp,8
  mov [rbp],rax
  invoke GetLocalTime,SysTime
  movzx eax,word [SysTime.wYear]
  shl eax,16
  movzx ebx,word [SysTime.wMonth]
  shl ebx,8
  or eax,ebx
  movzx ebx,word [SysTime.wDay]
  or eax,ebx
  ret

;===============================================
align 16
SYSLOAD: ; ( 'from "filename" -- 'to )
  mov rcx,[rbp]
  sub rbp,8
  invoke CreateFile,rcx,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_FLAG_NO_BUFFERING+FILE_FLAG_SEQUENTIAL_SCAN,0
  mov [hdir],rax
  or rax,rax
  jz .loadend
  mov rax,[rsp+16]
  mov [afile],rax
  invoke ReadFile,[hdir],[afile],$ffffff,cntr,0 ; hasta 16MB
  cmp rax, 0
  jne     .loadend
  invoke CloseHandle,[hdir]
  mov rax,[afile]
  add rax,[cntr]
.loadend:
  ret

;===============================================
align 16
SYSSAVE: ; ( 'from cnt "filename" -- )
  invoke CreateFile,rax,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_FLAG_SEQUENTIAL_SCAN,0
  mov [hdir],rax
  or rax,rax
  jz .saveend
  mov rdx,[rbp-8]
  mov rcx,[rbp]
  invoke WriteFile,[hdir],rdx,rcx,cntr,0
  cmp [cntr],rcx
  je .saveend
  or rax,rax
  jz .saveend
  invoke CloseHandle,[hdir]
.saveend:
  sub rbp,24
  ret

;===============================================
align 16
SYSAPPEND: ; ( 'from cnt "filename" -- )
;        mov rax,[rsp+8] ;FILE_APPEND_DATA=4
  invoke CreateFile,eax,4,0,0,CREATE_ALWAYS,FILE_FLAG_SEQUENTIAL_SCAN,0
  mov [hdir],rax
  or rax,rax
  jz .append
  mov rdx,[rbp-8]
  mov rcx,[rbp]
  invoke WriteFile,[hdir],rdx,rcx,cntr,0
  cmp [cntr],rcx
  je .append
  or rax,rax
  jz .append
  invoke CloseHandle,[hdir]
.append:
  sub rbp,24
  ret


section '.data' data readable writeable

  window dd ?
  screen dd ?
  SysTime SYSTEMTIME
  hdir dq 0
  afile dq 0
  cntr dq 0
  evt SDL_Event

  SYSXM          dd ?
  SYSYM          dd ?
  SYSBM          dd ?
  SYSKEY         dd ?
  SYSCHAR        dd ?
  FREE_MEM       dq ?
  DATASTK        rq 256
  SYSFRAME       dq ? ;rd XRES*YRES

  _title db "r3d",0
  _error db "err",0

;----- CODE -----
align 16
  include 'data.asm'
;----- CODE -----

section '.idata' import readable

  library kernel32,'KERNEL32',\
          user32,'USER32',\
          sdl2,'SDL2'
  include 'include\api\kernel32.inc'
  include 'include\api\user32.inc'
  include 'sdl2_api.inc'