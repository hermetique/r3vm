| Parse words
| PHREDA 2018
|-----------------
^r3/lib/mem.r3

::>>0 | adr -- adr' ; pasa 0
	( c@+ 1? drop ) drop ;

::>>cr | adr -- adr'
	( c@+ 1? 10 =? ( drop 1 - ; ) 13 =? ( drop 1 - ; ) drop ) drop 1 - ;

::>>sp | adr -- adr'
	( c@+ 1? $ff and 33 <? ( drop 1 - ; ) drop ) drop 1 - ;

::>>" | adr -- adr'
	( c@+ 1? 34 =? ( drop c@+ 34 <>? ( drop 1 - ; ) ) drop ) drop 1 - ;

::trimcar | adr -- adr' c
	( c@+ $ff and 33 <? 0? ( swap 1 - swap ; ) drop ) ;

| prefijo?
::=pre | adr "str" -- adr 1/0
	over swap
	( c@+ 1?  | adr adr' "str" c
		toupp rot c@+ toupp rot
		<>? ( 3drop 0 ; )
		drop swap ) 3drop
	1 ;

::=s | s1 s2 -- 0/1
	( c@+ $ff and 32 >? toupp >r | s1 s2  r:c2
		swap c@+ $ff and toupp r> | s2 s1 c1 c2
		<>? ( 3drop 0 ; ) drop
		swap ) drop
	swap c@ $ff and 32 >? ( 2drop 0 ; )
	2drop 1 ;
