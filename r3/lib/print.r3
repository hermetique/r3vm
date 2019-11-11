|---------------
| PRINT LIB
| PHREDA 2018
|---------------
^r3/lib/sys.r3
^r3/lib/str.r3
^r3/lib/fontpc.r3

##rows 40
##cols 80		| filas/columnas texto

##cch 16 ##ccw 8
##charrom
##charsiz
##charlin

#_charemit 'char8pc
#_charsize 'size8pc

::font! | 'vemit 'vsize --
  '_charsize ! '_charemit ! ;

::fontpc
	8 'ccw ! 16 'cch !
	'char8pc 'size8pc font! ;

::calcrowcol
	sw ccw / 'cols !
	sh cch / 'rows !
	;

::noemit | c --
	$ff and _charsize ex 'ccx +! ;

::emit | c --
	$ff and dup
	_charemit ex
	_charsize ex 'ccx +! ;

::sp
	32 emit ;
::nsp | cnt --
	( 1? 32 emit 1 - ) drop ;
::cr
	cch 'ccy +! 0 'ccx ! ;
::lf
	0 'ccx ! ;
::tab
	4 nsp ;
::gtab
	ccw 2 << 'ccx +! ;

::swprint | "" -- "" cnt
	0 over ( c@+ 1?
		$ff and _charsize ex rot + swap ) 2drop ;

::emitsize | c -- size
	$ff and _charsize ex ;

::home
	0 'ccx ! 0 'ccy ! ;

::print | "" --
	( c@+ 1? emit ) 2drop ;

::printc | "" --
	swprint 1 >> sw 1 >> swap - 'ccx !
	print ;

::printr | "" --
	swprint sw swap - 'ccx !
	print ;

::cntprint | "" cnt --
	( 1? 1 - swap c@+
		0? ( drop 1 - 32 )
		emit swap ) 2drop ;

::cntprintr | "" cnt --
	swap count swap -
	nsp print ;

::lprint
	( c@+ 1? $ff and
  		10 =? ( 2drop ; )
		13 =? ( 2drop ; )
		emit ) 2drop ;

::gotoxy | x y --
	cch * 'ccy !
	ccw * 'ccx ! ;

::atxy | x y --
	'ccy ! 'ccx ! ;

|--- fill back
::backprint | "" -- ""
	swprint | cnt
	ccx ccy 2dup cch + op pline
	ccx over + ccy op ccx + ccy cch + pline
	poli ;

::backline | --
	0 ccy 2dup cch + op pline
	sw ccy 2dup cch + op pline
	poli ;

::backlines | cnt --
	cch * >r
	0 ccy 2dup r@ + op pline
	sw ccy 2dup r> + op pline
	poli ;

