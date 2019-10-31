| r3STACK 2018
| PHREDA
|--------------------
^r3/lib/gui.txt
^r3/util/trace.txt

|-- buffer code
##bcode * 8192
##bcode> 'bcode

##ctecode * 8192
##ctecode> 'ctecode

::codeini
	'bcode 'bcode> !
	'ctecode 'ctecode> !
	;

::code!+ | tok --
	bcode> !+ 'bcode> ! ;

::code<< | --
	-4 'bcode> +! ;

::ncode | -- n
	bcode> 'bcode - 2 >> ;

::cte!+ | val --
	ctecode>
	dup 'ctecode - 8 << 8 or | token hex are generated
	code!+
	!+ 'ctecode> ! ;

|--- Pilas
#REGA
#REGB
##TOS 0
##PSP )( 1024
##NOS 'PSP
#RSP )( 1024
##RTOS 'RSP

::NOS2 NOS 4 - ;

| format cell
| type-- $0000000f
| $0 nro	33
| $1 cte    FREEMEM
| $2 str    s01
| $3 wrd    w32
| $4 [wrd]	[w33]
| $5 reg	eax ebx
| $6 stk	[ebp] [ebp+4] ...

|--Pila
::.DUP		4 'NOS +! TOS NOS ! ;

|-------------------------------
| store value in stack
#stkvalue )( 1024
#stkvalue# 0

:newval | -- newval
	stkvalue# dup 1+ 'stkvalue# ! ;

::PUSH.NRO	| nro --
	.DUP
	newval dup 8 << 0 or 'TOS !
	2 << 'stkvalue + ! ;

::PUSH.CTE	| ncte --
	.DUP 8 << 1 or 'TOS ! ;
::PUSH.STR	| vstr --
	.DUP 8 << 2 or 'TOS ! ;
::PUSH.WRD	| vwor --
	.DUP 8 << 3 or 'TOS ! ;
::PUSH.VAR	| var --
	.DUP 8 << 4 or 'TOS ! ;
::PUSH.REG	| reg --
	.DUP 8 << 5 or 'TOS ! ;
::PUSH.STK	| stk --
	.DUP 8 << 6 or 'TOS ! ;

::.POP | -- nro
	TOS NOS @ 'TOS ! -4 'NOS +! ;

::vTOS	TOS 8 >> 2 << 'stkvalue + @ ;
::vNOS   NOS @ 8 >> 2 << 'stkvalue + @ ;
::vPK2   NOS 4 - @ 8 >> 2 << 'stkvalue + @ ;

::.OVER     .DUP NOS 4 - @ 'TOS ! ;
::.PICK2    .DUP NOS 8 - @ 'TOS ! ;
::.PICK3    .DUP NOS 12 - @ 'TOS ! ;
::.PICK4    .DUP NOS 16 - @ 'TOS ! ;
::.2DUP     .OVER .OVER ;
::.2OVER    .PICK3 .PICK3 ;

::.DROP		NOS @ 'TOS !	|...
::.NIP      -4 'NOS +! ;
::.2NIP      -8 'NOS +! ;
::.2DROP    NOS 4 - @ 'TOS ! -8 'NOS +! ;
::.3DROP    NOS 8 - @ 'TOS ! -12 'NOS +! ;
::.4DROP    NOS 12 - @ 'TOS ! -16 'NOS +! ;

::.SWAP     NOS @ TOS NOS ! 'TOS ! ;
::.ROT      TOS NOS 4 - @ 'TOS ! NOS @ NOS 4 - !+ ! ;
::.2SWAP    TOS NOS @ NOS 4 - dup 4 - @ NOS ! @ 'TOS !  NOS 8 - !+ ! ;

|-- Internas
::.LIT		.DUP dup @ 'TOS ! 4+ ;
::.ADR		.DUP dup @ @ 'TOS ! 4+ ;

::.;		RTOS @ nip -4 'RTOS +! ;
::.CALL		4 'RTOS +! dup 4+ RTOS ! @ ;
::.JMP		@ ;

|-- exec
::.EX		TOS .DROP 4 'RTOS +! swap RTOS ! ;

::.popIP	| -- val
	RTOS dup @ swap 4 - RSP max 'RTOS ! ;

|-- condicionales
::.0?		TOS 1? ( drop @ )( drop 4+ ) ;
::.1?		TOS 0?  ( drop @ )( drop 4+ ) ;
::.+?		TOS -?  ( drop @ )( drop 4+ ) ;
::.-?		TOS 1+ +? ( drop @ )( drop 4+ ) ;

::.=?		NOS @ TOS <>? ( drop @ )( drop 4+ ) .DROP ;
::.<?		NOS @ TOS >=? ( drop @ )( drop 4+ ) .DROP ;
::.>?		NOS @ TOS <=? ( drop @ )( drop 4+ ) .DROP ;
::.<=?		NOS @ TOS >? ( drop @ )( drop 4+ ) .DROP ;
::.>=?		NOS @ TOS <? ( drop @ )( drop 4+ ) .DROP ;
::.<>?		NOS @ TOS =? ( drop @ )( drop 4+ ) .DROP ;
::.A?		NOS @ TOS nand? ( drop @ )( drop 4+ ) .DROP ;
::.N?		NOS @ TOS and? ( drop @ )( drop 4+ ) .DROP ;

::.B?		NOS @ TOS and? ( drop @ )( drop 4+ ) .DROP ; |****

::.>R		4 'RTOS +! TOS RTOS ! .DROP ;
::.R>		.DUP RTOS dup @ 'TOS ! 4 - 'RTOS ! ;
::.R@		.DUP RTOS @ 'TOS ! ;

::.AND		vNOS vTOS and .2DROP PUSH.NRO ;
::.OR		vNOS vTOS or .2DROP PUSH.NRO ;
::.XOR		vNOS vTOS xor .2DROP PUSH.NRO ;
::.NOT		vTOS not .DROP PUSH.NRO ;
::.+		vNOS vTOS + .2DROP PUSH.NRO ;
::.-		vNOS vTOS - .2DROP PUSH.NRO ;
::.*		vNOS vTOS * .2DROP PUSH.NRO ;
::./		vNOS vTOS / .2DROP PUSH.NRO ;
::.*/		vPK2 vNOS vTOS */ .3DROP PUSH.NRO ;
::.*>>		vPK2 vNOS vTOS *>> .3DROP PUSH.NRO ;
::.<</		vPK2 vNOS vTOS <</ .3DROP PUSH.NRO ;
::./MOD		vNOS vTOS /mod swap .2DROP PUSH.NRO PUSH.NRO ;
::.MOD		vNOS vTOS mod .2DROP PUSH.NRO ;
::.ABS		vTOS abs .DROP PUSH.NRO ;
::.NEG		vTOS neg .DROP PUSH.NRO ;
::.CLZ		vTOS clz .DROP PUSH.NRO ;
::.SQRT		vTOS sqrt .DROP PUSH.NRO ;
::.<<		vNOS vTOS << .2DROP PUSH.NRO ;
::.>>		vNOS vTOS >> .2DROP PUSH.NRO ;
::.>>>		vNOS vTOS 0>> .2DROP PUSH.NRO ;

::.>A		TOS 'REGA ! .DROP ;
::.A>		.DUP REGA 'TOS ! ;
::.A@		.DUP REGA @ 'TOS ! ;
::.A!		TOS REGA ! .DROP ;
::.A+       TOS 'REGA +! .DROP ;
::.A@+		.DUP REGA dup 4+ 'REGA ! @ 'TOS ! ;
::.A!+		TOS REGA dup 4+ 'REGA ! ! .DROP ;

::.>B		TOS 'REGB ! .DROP ;
::.B>		.DUP REGB 'TOS ! ;
::.B@		.DUP REGB @ 'TOS ! ;
::.B!		TOS REGB ! .DROP ;
::.B+       TOS 'REGB +! .DROP ;
::.B@+		.DUP REGB dup 4+ 'REGB ! @ 'TOS ! ;
::.B!+		TOS REGB dup 4+ 'REGB ! ! .DROP ;


:i@			TOS @ 'TOS ! ;
:iC@		TOS c@ 'TOS ! ;
:iD@		TOS w@ 'TOS ! ;
:i!			NOS @ TOS ! .NIP .DROP ;
:iC!		NOS @ TOS c! .NIP .DROP ;
:iD!		NOS @ TOS w! .NIP .DROP ;
:i+!		NOS @ TOS +! .NIP .DROP ;
:iC+!		NOS @ TOS c+! .NIP .DROP ;
:iD+!		NOS @ TOS w+! .NIP .DROP ;
:i@+		.DUP 4 NOS +! TOS @ 'TOS ! ;
:i!+		NOS @ TOS ! .NIP 4 'TOS +! ;
:iC@+		.DUP 1 NOS +! TOS c@ 'TOS ! ;
:iC!+		NOS @ TOS c! .NIP 1 'TOS +! ;
:iD@+		.DUP 2 NOS +! TOS w@ 'TOS ! ;
:iD!+		NOS @ TOS w! .NIP 2 'TOS +! ;

|-- 0 is nro x tops of stack
::nro1stk | --1/0 ok
	TOS $f and ;
::nro2stk | --1/0 ok
	NOS @ $f and
	TOS $f and or ;
::nro3stk | --1/0
	NOS 4 - @ $f and
	NOS @ $f and or
	TOS $f and or ;

#stks )( 256 		| stack of stack 64 levels
#stks> 'stks

#memstk )( $fff	| stack memory
#memstk> 'memstk

::stack.cnt | -- cnt
	NOS 'PSP - 2 >> ;

::stk.push
	memstk> dup stks> !+ 'stks> !
	>a
	NOS 'PSP - a!+
	'PSP 8 + ( NOS <=? )( @+ a!+ ) drop
	'PSP NOS <? ( TOS a!+ ) drop
	;

::stk.pop
	-4 'stks> +! stks> @
	dup 'memstk> !
	>a
	a@+ 'PSP + 'NOS !
	'PSP 8 + ( NOS <=? )( a@+ swap !+ ) drop
	'PSP NOS <? ( a@+ 'TOS ! ) drop
	;

::stk.drop
	-4 'stks> +! stks> @
	'memstk> !
	;


|-------- constantes del sistema
#syscons "XRES" "YRES" "FREE_MEM" "SYSFRAME" "dword[SYSXYM]" "dword[SYSBM]" "dword[SYSKEY]"

#sysregs "eax" "ebx" "ecx" "edx" "edi" "esi" "r8d" "r9d" "r10d" "r11d" "r12d" "r13d" "r14d" "r15d"
#sysregw  "ax"  "bx"  "cx"  "dx"  "di"  "si" "r8w" "r9w" "r10w" "r11w" "r12w" "r13w" "r14w" "r15w"
#sysregb  "al"  "bl"  "cl"  "dl" "dil" "sil" "r8b" "r9b" "r10b" "r11b" "r12b" "r13b" "r14b" "r15b"

:list2str | nro 'list -- str
	swap ( 1? 1 - swap >>0 swap ) drop ;

|---- imprime celda
:value 8 >> ;

:mt0 value 2 << 'stkvalue + @ "$%h" ,print ;	|--	0 nro 	33

:mt1 value 'syscons list2str ,s ;	|--	1 cte	XRES
:mt2 value "str%h" ,print ;			|--	2 str   "hola"
:mt3 value "w%h" ,print ;			|--	3 word  'word
:mt4 value "dword[w%h]" ,print ;	|--	4 var   [var]
:mt5 value 'sysregs list2str ,s ;	|-- 5 reg 	eax
:mt5b value 'sysregb list2str ,s ;	|-- 5 regb 	al
:mt5w value 'sysregw list2str ,s ;	|-- 5 regw 	ax

:mt6 value 2 << "dword[ebp" ,s
	1? ( +? ( "+" ,s ) ,d )( drop )
	"]" ,s ; 						|-- 6 stack

#tiposrm mt0 mt1 mt2 mt3 mt4 mt5 mt6 mt0 mt0
#tiposrmb mt0 mt1 mt2 mt3 mt4 mt5b mt6 mt0 mt0
#tiposrmw mt0 mt1 mt2 mt3 mt4 mt5w mt6 mt0 mt0

::,cell | val --
	dup $f and 2 << 'tiposrm + @ exec ;

::,cellb | nro --
	dup $f and 2 << 'tiposrmb + @ exec ;

::,cellw | nro --
	dup $f and 2 << 'tiposrmw + @ exec ;

:,cstack | adr -- adr
	c@+ $30 -
	0? ( drop TOS ,cell ; )
	1- 2 << NOS swap - @ ,cell ;

:,cstackb | adr -- adr
	c@+ $30 -
	0? ( drop TOS ,cellb ; )
	1- 2 << NOS swap - @ ,cellb ;

:,car
	$23 =? ( drop ,cstack ; ) | # dword reg
	$24 =? ( drop ,cstackb ; ) | $ byte reg
	$3b =? ( drop ,cr ; ) | ;
	,c ;

::,asm | str --
	( c@+ 1? )( ,car ) 2drop
	,cr ;


::,printstk
	"; [ " ,s
	'PSP 8 + ( NOS <=? @+ ,cell ,sp ) drop
	'PSP NOS <? ( TOS ,cell ) drop
	" ] " ,s
	;

::,printstka
	"; [ " ,s
	'PSP 8 + ( NOS <=? )( @+ 8 >> "%h " ,print ) drop
	'PSP NOS <? ( TOS 8 >> "%h " ,print ) drop
	"] " ,s
	;

::stackmap | xx vector -- xx
	>a 'PSP 8 +
	( NOS <=? )( dup >r	| xx 'cell
		a> exec
		r> 4+ ) drop
	'PSP NOS >=? ( drop ; ) drop
	'TOS a> exec ;

::stackmap-1 | xx vector -- xx
	>a 'PSP 8 +
	( NOS <=? )( dup >r	| xx 'cell
		a> exec
		r> 4+ ) drop ;

|----------------- registers used
#maskreg 0

:usereg | 'cell --
	@ dup $f and
	5 <>? ( 2drop ; ) drop
	1 swap 8 >> <<
	maskreg or 'maskreg !
	;

::cell.fillreg
	0 'maskreg !
	'usereg stackmap
	;

::newreg | -- reg
	0 maskreg
	( 1 and? )( 2/ swap 1+ swap ) drop
	;

::setreg | reg --
	1 swap << maskreg or 'maskreg ! ;

|---- set cell
::cell.REG | reg 'cell --
	"mov " ,s
	over 'sysregs list2str ,s
	"," ,s
	dup @ ,cell
	swap 8 << 5 or swap !
	,cr ;

:cell.STK | stk 'cell --
	"mov [ebp" ,s
	over
	1? ( 2 << +? ( "+" ,s ) ,d )( drop )
	"]," ,s
	dup @ ,cell
	swap 8 << 6 or swap !
	,cr ;

|-----
::setEAX | 'cell --
	0 8 << 5 or swap ! ;
::setEDX | 'cell --
	3 8 << 5 or swap ! ;

:setSTK | 'cell --
	NOS over swap - 1- 2 >>
	dup 8 << 6 or
	pick2 @ =? ( 3drop ; ) drop | ya esta en orden
	swap cell.STK ;

:freeforedx | 'cell --
	dup @
	3 8 << 5 or | reg EDX
	<>? ( 2drop ; ) drop
	setSTK ;

::freeEDX
	'freeforedx stackmap ;


#stacknow

|------- convert to normal ; xxx --> ... [ebp-4] eax
#stacknormal )( 256

:fillnormal | deep --
	-? ( trace drop ; )
	'stacknormal >a
	dup 2 << a!+
	0? ( drop ; )
	1- ( 1? )(
		dup neg 8 << 6 or a!+
		1- )
	5 or a!+ ;


|-----------------
|; convert to normal
|-----------------

:cellEBP | deltap 'cell -- deltap
	dup @ $f and 6 <>? ( 2drop ; ) drop | STK?
	over 8 << swap +! ;

:shiftEBP | deltap --	; corre ebp a nuevo lugar
	0? ( drop ; )
	dup neg
	"lea ebp,[ebp" ,s +? ( "+" ,s ) 2 << ,d "]" ,ln
    'cellEBP stackmap
	drop ;

:scanuse | to from -- to from here
	a> ( NOS 4+ <=? )( @+ | t f 'a c
		pick3 =? ( drop 4 - ; ) drop
		) drop 0 ;

:resolveADR | from -- from'
	dup $f and
	drop
	;

:cellreguse | to from here --
	over swap !
	"xchg " ,s ,cell "," ,s ,cell ,cr
	;

:cellreg | toREG from --
	scanuse 1? ( cellreguse ; ) drop
	swap
	"mov " ,s ,cell "," ,s ,cell ,cr
	;

:cellstkuse | to from here --
	over $f and
	5 =? ( drop cellreguse ; )
	drop
	newreg dup setreg
	8 << 5 or dup
	rot !	| to from reg
	dup
	"mov " ,s ,cell "," ,s swap ,cell ,cr
	"xchg " ,s ,cell "," ,s ,cell ,cr
	;

:cellstk | toSTK from --
	scanuse 1? ( cellstkuse ; ) drop
	resolveADR
	swap
	"mov " ,s ,cell "," ,s ,cell ,cr
	;

:cellcpy | to from --
	over =? ( 2drop ; )	| ya esta
	over $f and
    5 =? ( drop cellreg ; )
    6 =? ( drop cellstk ; )
    3drop
    "; error stk dest reg/stk!!" ,ln
	;

:stk.cnv | 'adr --
	cell.fillreg
	TOS NOS 4+ ! | TOS in PSP
	@+ 2 >>
|	NOS 'PSP - <>? ( ; )	| diferent size
	'PSP 8 + >a
	( 1? )( swap
		@+ a@+ cellcpy 		| to from
		swap 1- ) 2drop

	NOS 4+ @ 'TOS !
	;

::stk.conv | --
	stks> 4 - @ stk.cnv
	;

::IniStack
	'PSP 'NOS !
	'RSP 'RTOS !
	0 'stkvalue# !
	'stks 'stks> !
	'memstk 'memstk> !
	;

::DeepStack | deep --
	IniStack
	( 1? )( 1-
		dup PUSH.REG
		) drop ;

|------- spill reg

:spillhere | cellreg 'stk --
	4 - | cell
	NOS over - 2 >> 1+
	stacknow stack.cnt - +
	neg | <- where in stack

	over
	cell.STK

	2drop

	NOS 4+ @ 'TOS !
	;

::spill | reg --
	8 << 5 or | cellr
	TOS NOS 4+ ! | TOS in PSP
	'PSP 8 +
	( NOS 4+ <=? )(
		@+ pick2 =? ( drop spillhere ; )
		drop )
	2drop ;

|------- ini stack in ; ... [ebp-4] eax
::stk.start | deep --
	IniStack
	dup 'stacknow !
	0? ( drop ; )
	1- ( 1? )(
		dup neg push.stk
		1- )
	push.reg ;

:stk.setnormal | deep --
	'PSP 'NOS !
	'RSP 'RTOS !
	dup 'stacknow !
	0? ( drop ; )
	1- ( 1? )(
		dup neg push.stk
		1- )
	push.reg ;

::stk.normal | --
	stacknow stack.cnt - shiftEBP 	| corre ebp a nuevo lugar
	stack.cnt fillnormal
	'stacknormal stk.cnv

	stack.cnt stk.setnormal
	;

::stk.gennormal | d u --
	dup ( 1? )( 1- .drop ) drop
	+
	0? ( drop ; )
	1- ( 1? )(
		dup neg push.stk
		1- )
	push.reg
	stack.cnt stk.setnormal
	;

|--------------------------------
| $0 nro	33
| $1 cte    FREEMEM
| $2 str    s01
| $3 wrd    w32
| $4 [wrd]	[w33]
| $5 reg	eax ebx
| $6 stk	[ebp] [ebp+4] ...

:change | cell@ reg 'cell -- 'cell reg
	pick2 over @ <>? ( 2drop ; ) drop
	over swap ! ;

:changecellall | cell@ reg -- cell@ reg
	'change stackmap ;

::needEAX | 'cell --
	dup @ 5 =? ( 2drop ; )
	"mov eax," ,s ,cell ,cr
	5 swap !
	;

::needECXcte | 'cell --
	dup @
	2 8 << 5 or =? ( 2drop ; )
	$f nand? ( 2drop ; )
	"mov ecx," ,s ,cell ,cr
	2 8 << 5 or swap !
	;

::needREG | 'cell --
	dup @ $f and
	5 =? ( 2drop ; ) | reg
	drop
	dup @
	newreg 8 << 5 or
	"mov " ,s dup ,cell "," ,s over ,cell ,cr
	changecellall nip
	swap !
	;

::needREG-EDX
	dup @ $f and
	5 =? ( 2drop ; ) | reg
	drop
	dup @
	newreg 8 << 5 or
	"mov " ,s dup ,cell "," ,s over ,cell ,cr
	changecellall nip
	swap !
	;


::needESIEDIECX
|	2 spill | free ecx
	NOS 4 - @
	$405 <>? ( 4 NOS 4 - cell.REG ) drop
	NOS @
	$505 <>? ( 5 NOS cell.REG ) drop
	TOS
	$205 =? ( drop ; ) drop
	2 'TOS cell.REG
	;

::needEDIECXEAX
|	0 spill | free eax
|	2 spill | free ecx
	NOS 4 - @
	$005 <>? ( 0 NOS 4 - cell.REG ) drop
	NOS @
	$405 <>? ( 4 NOS cell.REG ) drop
	TOS
	$205 =? ( drop ; ) drop
	2 'TOS cell.REG
	;

::needMEMREG
	dup @ $f and
	2 =? ( 2drop ; ) | str
	3 =? ( 2drop ; ) | wrd
	drop
	needREG ;

::need1REGno | 1 reg sin orden
	NOS @ $f and 5 =? ( drop ; ) drop
	TOS $f and 5 =? ( drop .swap ; ) drop
	NOS needREG ;

::need1REG | 1 reg con orden
	NOS @ $f and 5 =? ( drop ; ) drop
	NOS needREG ;


|-----------------
| DEBUG
|-----------------

:debugstk
	stks> 4 -
	'stks <? ( drop ; )
	@ @+ 2 >>
	( 1? )(
		swap @+ "%h " print
		swap 1- ) 2drop ;

:mt0 value
	2 << 'stkvalue + @ "%d" print ;			|--	0 nro 	33

:mt1 value 'syscons list2str print ;	|--	1 cte	XRES
:mt2 value "str%h" print ;			|--	2 str   "hola"
:mt3 value "w%h" print ;			|--	3 cod  'func		4 dat  'var

:mt5 value 'sysregs list2str print ;	|-- 5 reg 	eax
:mt5b value 'sysregb list2str print ;	|-- 5 regb 	al
:mt5w value 'sysregw list2str print ;	|-- 5 regw 	ax

:mt6 value 2 << "dword[ebp" print 1? ( +? ( "+" print ) "%d" print )( drop ) "]" print ; |-- 6 stack

#tiposrm mt0 mt1 mt2 mt3 mt3 mt5 mt6 mt0 mt0
#tiposrmb mt0 mt1 mt2 mt3 mt3 mt5b mt6 mt0 mt0
#tiposrmw mt0 mt1 mt2 mt3 mt3 mt5w mt6 mt0 mt0

:cell | val -- str
	dup $f and 2 << 'tiposrm + @ exec ;

:cellb | nro -- nro
	dup $f and 2 << 'tiposrmb + @ exec ;

:cellw | nro -- nro
	dup $f and 2 << 'tiposrmw + @ exec ;

:printstk
	'PSP 8 + ( NOS <=? )( @+ cell " " print ) drop
	'PSP NOS <? ( TOS cell ) drop
	;


:test
	0 PUSH.REG
	1 PUSH.REG
	2 PUSH.REG
	,printstk ,cr
	stk.push
	.rot
	,printstk ,cr
	stk.conv
	stk.pop

	,printstk ,cr
	stk.normal
	0 here !
	;

:test2
	3 stk.start
|	33 push.nro
	,printstk ,cr

|	.swap
|	.2swap
	.dup

	,printstk ,cr

	stk.normal
    ,printstk ,cr
	0 here !
	;
:test2
	0 stk.start
	,printstk ,cr
	1 push.reg
	,printstk ,cr
	stk.normal
	,printstk ,cr
	0 here !
	;
:test3
	4 stk.start
	,printstk ,cr

|	.swap
|	33 push.nro
|	.swap
|	31 push.nro
	,printstk ,cr
	0 spill		,printstk ,cr
|	stk.normal	,printstk ,cr

	0 'here !
	;

:test4
	3 stk.start
	,printstk ,cr

	.swap
|	33 push.nro
|	.swap
|	31 push.nro
	,printstk ,cr
	0 spill		,printstk ,cr
|	stk.normal	,printstk ,cr

	0 here !
	;

:accion
	'test <f1>
	'test2 <f2>

	'test3 <f3>
	'test4 <f4>

|	[ rand $f and 8 - push.nro ; ] <f1>
|	[ rand $3 and PUSH.CTE ; ] <f2>
|	[ rand $ff and PUSH.STR ; ] <f3>
|	[ rand $ff and PUSH.WRD ; ] <f4>
	[ rand $7 and PUSH.REG ; ] <f5>
|	[ rand $f and PUSH.STK ; ] <f6>

	[ .drop ; ] <f7>
	[ .swap ; ] <f8>

	[ stk.push ; ] <f9>
	[ stk.pop ; ] <f10>

	[ stk.normal 0 here ! ; ] <f11>
	[ stk.conv 0 here ! ; ] <f12>
	;

#memp

:main
	33
	mark
	here 0 over !
	'memp !
	show clrscr
		dup "%d" print cr
		cr
		printstk
		cr
		accion
		cr
		memp print
		cr cr
		debugstk

		cminiflecha
		'exit >esc< ;

: main ;