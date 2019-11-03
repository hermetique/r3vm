| r3 base words
| PHREDA 1018
|-------------
^r3/lib/mem.r3
^r3/lib/print.r3

^./r3parse.r3
^./r3stack.r3

##r3filename * 256
##r3path * 256

##cnttokens
##cntdef

##error
##modo

|---- includes
| 'string|'mem
##inc * $fff
##inc> 'inc

|---------  #src
|...source
|---------	#code
|...token	#<<boot
|...		#code>
|---------	#blok
| blok info


##src
##code
##code>
##<<boot
##blok
##nbloques 0

|---- dicc
| str|token|info|mov  	16 bytes/word
| 0   4     8    12

| info
| $1 - code/data
| $2 - loc/ext

| $4	1 es usado con direccion
| $8	1 r esta desbalanceada		| var cte
| $10	0 un ; 1 varios ;
| $20	1 si es recursiva
| $40	1 si tiene anonimas
| $80	1 termina sin ;
| $100	1 inline

|   $fff000 - calls
| $ff000000 - level/data type

| mov
| $fffff000 -- 20 bits token len
| $1ff - movs delta -16..15 uso:0..15


##dicc
##dicc>
##dicc<

#r3machine
"nop" ":" "::" "#" "##" "|" "^" 	| 6
"Nd" "Nh" "Nb" "Nf" "str" 					| 11
"call" "var" "dcode" "ddata" 		| 15
|";" "jmp" "jmpw" "[" "]"

#r3base
";" "(" ")" "[" "]"
"EX" "0?" "1?" "+?" "-?" 				| 10
"<?" ">?" "=?" ">=?" "<=?" "<>?" "AN?" "NA?" "BTW?" 		| 19
"DUP" "DROP" "OVER" "PICK2" "PICK3" "PICK4" "SWAP" "NIP" 	| 27
"ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP" 		| 34
">R" "R>" "R@" 												| 37
"AND" "OR" "XOR" "NOT" "NEG" 								| 42
"+" "-" "*" "/" "*/" 										| 47
"/MOD" "MOD" "ABS" "SQRT" "CLZ" 							| 52
"<<" ">>" ">>>" "*>>" "<</" 								| 57
"@" "C@" "Q@" "@+" "C@+" "Q@+"  							| 65
"!" "C!" "Q!" "!+" "C!+" "Q!+"  							| 71
"+!" "C+!" "Q+!"  											| 74
">A" "A>" "A@" "A!" "A+" "A@+" "A!+" 						| 81
">B" "B>" "B@" "B!" "B+" "B@+" "B!+" 						| 88
"MOVE" "MOVE>" "FILL" 										| 91
"CMOVE" "CMOVE>" "CFILL" 									| 94
"DMOVE" "DMOVE>" "DFILL" 									| 97

"UPDATE" "REDRAW"
"MEM" "SW" "SH" "VFRAME"
"XYPEN" "BPEN" "KEY"
"MSEC" "TIME" "DATE"
"LOAD" "SAVE" "APPEND"
"FFIRST" "FNEXT"

"SYSCALL" "SYSMEM"
"SYS"
( 0 )

::r3basename | nro -- str
	'r3base swap
	( 0 <>? 1 - swap >>0 swap ) drop ;

::r3tokenname | nro -- str
	'r3machine swap
	( 0 <>? 1 - swap >>0 swap ) drop ;

::?base | adr -- nro/-1
	0 'r3base			| adr 0 'r3base
	( dup c@ 1? drop
		pick2 over =s 1? ( 2drop nip ; ) drop
		>>0 swap 1 + swap ) 4drop
	-1 ;

::allocdic | cnt --
	4 << here
	dup 'dicc ! dup 'dicc> ! dup 'dicc< !
	+ 'here ! ;

::adr>dic | adr -- nro
	dicc - 4 >> ;

::dic>adr | nro -- adr
	4 << dicc + ;

::dic>tok | nro -- 'tok
	dic>adr 4 + ;

::dic>inf | nro -- 'inf
	dic>adr 8 + ;

::dic>mov | nro -- 'mov
	dic>adr 12 + ;

::dic>du | nro -- delta uso
	dic>adr 12 + @
	dup	23 << 27 >>	| delta
	swap $f and ;	| uso

::dic>len@
	dic>adr 12 + @ 12 >>> ;

::adr>dicname | adr -- nadr
	adr>dic "W%h" mprint ;

::tok>dicname | nro -- nadr
	8 >>> "W%h" mprint ;

::dic>toklen | nro -- adr len
	dic>adr 4 + @+ swap 4 + @ 12 >>> ;

::adr>toklen | adr+4 -- adr len
	4 + @+ swap 4 + @ 12 >>> ;

::dic>call@ | nr -- calls
	dic>inf @ 12 >> $fff and ;

::?word | str -- str dir / str 0
	dicc> 16 -	|---largo
	( dicc >=?
		dup @ pick2			| str ind pal str
		=s 1? ( drop
			dup 8 + @
			%10 na? ( drop dicc< >=? ( ; ) dup )
			) drop

|		=s 0? ( drop )( drop
|			dup 8 + @
|			%10 an? ( drop ; )( drop dicc< >=? ( ; ) )
|			)

		16 - ) drop
	0 ;

::word!+ | info info mem name --
	dicc> >a
	a!+ a!+ a!+ a!+
	a> 'dicc> ! ;

::wordnow | -- now
	dicc> dicc - 4 >> ;

|--- dibuja movimiento pilas
| mov
| $1ff - movs delta -16..15 uso:0..15

:,ncar | n car -- car
	( swap 1? 1 - swap dup ,c 1 + ) drop ;

:,mov | mov --
	"[ " ,s
	97 >r	| 'a'
	dup $f and
	dup r> ,ncar >r
	" -- " ,s
	swap 23 << 27 >> + | deltaD
	r> ,ncar drop
	" ]" ,s ;

:,movx | mov --
	dup
	dup $f and "U:%d " ,format
	23 << 27 >> "D:%d " ,format
	,mov
	;


::,codeinfo | nro --
	"; " ,s
	dic>adr
	@+ ":%w " ,format
	@+ code - 2 >> "(%h) " ,format
	@+
|	$1 an? ( ":" )( "#" ) ,s	| data/code
|	$2 an? ( "e" )( "l" ) ,s	| export/local
	1 >> $1 and "el" + ,c
|	$4 an? ( "'" )( "" ) ,s	| /adress used
	2 >> $1 and "' " + ,c
|	$8 an? ( "r" )( "" ) ,s	| /rstack mod
	3 >> $1 and "r " + ,c
|	$10 an? ( ";" )( "" ) ,s	| /multi;
	4 >> $1 and "; " + ,c
|	$20 an? ( "R" )( "" ) ,s	| /recurse
	5 >> $1 and "R " + ,c
|	$40 an? ( "[" )( "" ) ,s	| /anon
	6 >> $1 and "[ " + ,c
|	$80 an? ( "." )( "" ) ,s	| /no ;
	7 >> $1 and ". " + ,c
|	$100 an? ( ">" )( "" ) ,s	| /inline
	8 >> $1 and "> " + ,c

	dup 12 >> $fff and " <%d> " ,format
	24 >> $ff and " nivel:%d " ,format
	@ dup 12 >>> "len:%d " ,format
	,mov
|	$fff and " %h " ,format
	;

#datastr "val" "ddata" "dcode" "str" "lval" "lddata" "ldcode" "lstr" "multi" "buff"

:datatype | nro -- str
	'datastr swap ( 0 <>? 1 - swap >>0 swap ) drop ;

::,datainfo | nro --
	"; " ,s
	dic>adr
	@+ "#%w " ,format
	@+ code - 2 >> "(%h) " ,format
	@+
|	$2 an? ( "e" )( "l" ) ,s	| export/local
	1 >> $1 and "el" + ,c
|	$4 an? ( "'" )( "" ) ,s	| /adress used
	2 >> $1 and "' " + ,c
|	$8 an? ( "c" )( "" ) ,s	| cte
	3 >> $1 and "c " + ,c

	dup 12 >> $fff and " <%d> " ,format
	" tipo:" ,s
	24 >> $f and datatype ,s

	@ dup 12 >>> " len:%d " ,format
	$fff and " %h " ,format
	;


::slog | ... --
	mprint print cr
	redraw
	;

::debugdicc
	dicc ( dicc> <? dup >a
		a@+ a@+ a@+ a@+ 2swap swap
		"%w %h %h %h" slog
		16 +
		) drop ;
