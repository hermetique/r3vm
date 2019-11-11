^r3/lib/sys.r3
^r3/lib/str.r3
^r3/lib/print.r3

:screen
	home
	0 'ink !
	backline
	$ff00 'ink !
	over .d print sp
	pick2 .d print sp
	pick3 .d print sp
	pick4 .d print sp
	key >esc< =? ( exit ) drop
	;

::trace | --
	'screen onshow
	;

::dumpc | adr --
	16 ( 1?
		32 ( 1?
			rot c@+
			$ff and 32 <? ( drop $7e )
			emit
			rot rot 1 - ) drop
		cr 1 - ) 2drop
	waitesc ;

::dumpb | adr --
	16 ( 1?
		16 ( 1?
			rot c@+ $ff and .h print sp
			rot rot 1 - ) drop
		cr 1 - ) 2drop
	waitesc ;

::dumpd | adr --
	16 ( 1?
		8 ( 1?
			rot @+ .d print sp
			rot rot 1 - ) drop
		cr 1 - ) 2drop
	waitesc ;


:scroll
	cch neg 'ccy +!
	vframe sw cch * 2 << over + sw sh cch - * move
	vframe sw ccy * 2 << + 0 sw cch * fill
	;

::slog | ... --
	mprint print cr
	ccy cch + sh >=? ( scroll ) drop
	redraw	;

