|  Fuentes Vectoriales
|  PHREDA 2013
|  uso:
|	^r3/lib/fontr.txt
|   ^r3/rft/...fuente.rtf
|
|   ...fuente size fontr!
|--------------------------------------
^r3/lib/print.txt

|---------- rfont
#fontrom
#fontsize
#fycc #fxcc	| ajustes

:v>rfw ccw 14 *>> ;
:rf>xy | value -- x y
	dup 18 >> ccw 14 *>> ccx + 			|fxcc +
	swap 14 << 18 >> cch 14 *>> ccy +	|fycc +
	;

|--------- formato fuente
#yp #xp

:a0 drop ; | el valor no puede ser 0
:a1 xp yp pline rf>xy 2dup 'yp !+ ! op ;  | punto
:a2 rf>xy pline ; | linea
:a3 swap >b rf>xy b@+ rf>xy pcurve b> ;  | curva
:a4 swap >b rf>xy b@+ rf>xy b@+ rf>xy pcurve3 b> ; | curva3

| accediendo a x e y
|:a5 rf>xy xp swap pline yp pline ;
|:a6 rf>xy yp pline xp swap pline ;
#gfont a0 a1 a2 a3 a4 0 0 0

:drawrf | 'rf --
	fxcc 'ccx +!
	fycc 'ccy +!
	@+ rf>xy 2dup 'yp !+ ! op
	( @+ 1?
		dup $7 and 2 << 'gfont + @ ex
		) 2drop
	xp yp pline
	fxcc neg 'ccx +!
	fycc neg 'ccy +!
	poli
	;

:wsizerf | c -- wsize
	2 << fontsize + @ ccw 14 *>> ;

:emitrf | c --
	2 << fontrom + @ drawrf ;

::fontr! | rom size --
	pxtext
	'fontrom ! 'fontsize !
	drop
	v>rfw neg 'fxcc !
	cch dup 2 >> - 'cch !
	cch 2/ 'fycc !
	'emitrf  'wsizerf setfont
	;

|--------------- fuente en 3d
:3d>xy
	dup 18 >> ccw 14 *>> ccx + 			|fxcc +
	swap 14 << 18 >> cch 14 *>> ccy +	|fycc +
	0 project3d ; | <--- cortar por vista

:a0 drop ; | el valor no puede ser 0
:a1 xp yp pline 3d>xy 2dup 'yp !+ ! op ;  | punto
:a2 3d>xy pline ; | linea
:a3 swap >b 3d>xy b@+ 3d>xy pcurve b> ;  | curva
:a4 swap >b 3d>xy b@+ 3d>xy b@+ 3d>xy pcurve3 b> ; | curva3
#gfont a0 a1 a2 a3 a4 0 0 0

:drawrf3d | 'rf --
	fxcc 'ccx +!
	fycc 'ccy +!
	@+ 3d>xy 2dup 'yp !+ ! op
	( @+ 1?
		dup $7 and 2 << 'gfont + @ ex
		) 2drop
	xp yp pline
	fxcc neg 'ccx +!
	fycc neg 'ccy +!
	poli
	;

:emitrf3d | c --
	2 << fontrom + @ drawrf3d ;

::fontr3d! | rom size --
	pxtext
	'fontrom ! 'fontsize !
	drop
	v>rfw neg 'fxcc !
	cch dup 2 >> - 'cch !
	cch 2/ 'fycc !
	'emitrf3d  'wsizerf setfont
	;
