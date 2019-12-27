| cubo isometrico
| PHREDA 2017
|-------------------
^r3/lib/gui.r3
^r3/lib/3d.r3
^r3/lib/gr.r3

|------------------------------
#xcam 0 #ycam 0 #zcam 0

#octvert * 3072 	| 32 niveles de 3 valores*8 vert
#octvert> 'octvert

#rotsum * 2048		| 32 niveles de 2 valores*8 vert
#rotsum> 'rotsum

#ymin #nymin
#xmin #nxmin
#zmin #nzmin

#ymax #nymax
#xmax #nxmax
#zmax

#mask

#x0 #y0 #z0
#x1 #y1 #z1
#x2 #y2 #z2
#x4 #y4 #z4

#x7 #y7 #z7	| centro del cubo
#n1 #n2 #n3

:2/ 1 >> ;
:2* 1 << ;

|---------------
:fillstart | --
	'octvert >b
	1.0 1.0 1.0 transform b!+ b!+ b!+ | 111
	1.0 1.0 -1.0 transform b!+ b!+ b!+ | 110
	1.0 -1.0 1.0 transform b!+ b!+ b!+ | 101
	1.0 -1.0 -1.0 transform b!+ b!+ b!+ | 100
	-1.0 1.0 1.0 transform b!+ b!+ b!+ | 011
	-1.0 1.0 -1.0 transform b!+ b!+ b!+ | 010
	-1.0 -1.0 1.0 transform b!+ b!+ b!+ | 001
	-1.0 -1.0 -1.0 transform b!+ b!+ b!+ | 000
	b> 'octvert> !
	$ff $ff $ff transform 'x0 ! 'y0 ! 'z0 !
	$ff $ff -$ff transform 'x1 ! 'y1 ! 'z1 !
	$ff -$ff $ff transform 'x2 ! 'y2 ! 'z2 !
	-$ff $ff $ff transform 'x4 ! 'y4 ! 'z4 !
	-$ff -$ff -$ff transform
	x0 + 2/ 'x7 ! y0 + 2/ 'y7 ! z0 + 2/ 'z7 !
	;


| PERSPECTIVA
:id3d | x y z -- u v
	p3d ;

| ISOMETRICO
:id3d
	pick2 over - 0.03 / ox + >r
	rot + 2/ + 0.03 / oy + r> swap ;

:fillveciso | --
	octvert> 96 - >b
	'rotsum
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@ id3d rot !+ !+
	'rotsum> ! ;


:getp | n --
	3 << 'rotsum + @+ swap @ swap ;

:drawire
	$ffffff 'ink !
	0 getp op 1 getp line 3 getp line 2 getp line 0 getp line
	4 getp op 5 getp line 7 getp line 6 getp line 4 getp line
	0 getp op 4 getp line 1 getp op 5 getp line
	2 getp op 6 getp line 3 getp op 7 getp line
	;

:calco
	x0 x1 - x7 * y0 y1 - y7 * + z0 z1 - z7 * + dup 'n1 ! 31 >> $1 and
	x0 x2 - x7 * y0 y2 - y7 * + z0 z2 - z7 * + dup 'n2 ! 31 >> $2 and or
	x0 x4 - x7 * y0 y4 - y7 * + z0 z4 - z7 * + dup 'n3 ! 31 >> $4 and or
	$7 xor 'mask ! ;

:freelook
	xypen
	sh 2/ - 7 << swap
	sw 2/ - neg 7 << swap
	neg mrotx mroty ;

|-----------------------------------------
:getn | id -- z y x
	dup 2* + 2 << 'octvert +
	@+ swap @+ swap @ dup >r
	pick2 over - 0.03 / ox + >r
	rot + 2/ + 0.03 / oy + r>
	r> rot rot ;

#xx0 #yy0 #zz0
#xx1 #yy1 #zz1
#xx2 #yy2 #zz2
#xx4 #yy4 #zz4

#minx #miny #minz
#lenx #leny #lenz
#maxlev

#vecpos * 512

:raycast
	a@ $f0f0f colavg a!+ ;

:draw1
	minx miny xy>v >a
	sw lenx - 2 <<
	0 ( leny <? 
		0 ( lenx <?
			raycast
			1 + ) drop
		over a+
		1 + ) 2drop ;



|	0 0
|	xx1 -? ( rot + swap )( + )
|	xx2 -? ( rot + swap )( + )
|	xx3 -? ( rot + swap )( + )
|-- V1
:sminmax3 | a b c -- sn sx
	dup dup 31 >> dup not rot and rot rot and		| + -
	rot dup dup 31 >> dup not rot and rot rot and
	rot + >r + r>
	rot dup dup 31 >> dup not rot and rot rot and
	rot + >r + r> swap ;

|-- V2
:sminmax3 | a b c -- sn sx
	pick2 dup 31 >> not and
	pick2 dup 31 >> not and +
	over dup 31 >> not and + >r
	dup 31 >> and
	swap dup 31 >> and +
	swap dup 31 >> and +
	r> ;

:packxyz | x y z -- zyx
	zz0 + minz - 20 <<
	swap yy0 + miny - 10 << or
	swap xx0 + minx - or ;

:lbox | x1 y1 x2 y2
	2dup op pick3 over line 2over line
	over pick3 line line 2drop ;

:drawpanel | n --
	2 << 'vecpos + @
	dup $3ff and 2/ minx +
	swap 10 >> $3ff and 2/ miny +
	over lenx 2/ + over leny 2/ +
	lbox ;

#colores $ffffff $ff0000 $00ff00 $ffff00 $0000ff $ff00ff $00ffff $888888

#xmask * 1024
#ymask * 1024
#xmask1 * 512
#ymask1 * 512
#xmask2 * 256
#ymask2 * 256
#xmask3 * 128
#ymask3 * 128
#xmask4 * 64
#ymask4 * 64
#xmask5 * 32
#ymask5 * 32
#xmask6 * 16
#ymask6 * 16
#xmask7 * 8
#ymask7 * 8

#xmasl xmask xmask1 xmask2 xmask3 xmask4 xmask5 xmask6 xmask7 0
#ymasl ymask ymask1 ymask2 ymask3 ymask4 ymask5 ymask6 ymask7 0
|--------------------------------------
:pix
	an? ( b@+ ; )
	0 4 b+ ;

:drawxm
	'colores >b
	c@+ $1
	( $100 <?
		over pix
		dup a!+ sw 1 - 2 << a+
		a!+ sw 1 - 2 << a+
		2* ) 2drop ;

:drawym
	'colores >b
	c@+ $1
	( $100 <?
		over pix
		dup a!+ a!+
		2* ) 2drop ;

:drawrules
    0 ( 8 <?
    	dup 2 << 'colores + @ 'ink !
    	dup drawpanel
    	1 + ) drop
	'xmask
	0 ( lenx 2* <?  swap
    	over minx + miny 20 - xy>v >a
		drawxm
		swap 1 + ) 2drop
	'ymask
	0 ( leny 2* <?  swap
		minx 20 - pick2 miny + xy>v >a
		drawym
		swap 1 + ) 2drop
	;

#col0 0 $ff00

:8lin | bit
	dup 1 and 2 << 'col0 + @ a!+ sw 1 - 2 << a+
	dup 2 and 1 << 'col0 + @ a!+ sw 1 - 2 << a+
	dup 4 and 'col0 + @ a!+ sw 1 - 2 << a+
	dup 8 and 1 >> 'col0 + @ a!+ sw 1 - 2 << a+
	dup 16 and 2 >> 'col0 + @ a!+ sw 1 - 2 << a+
	dup 32 and 3 >> 'col0 + @ a!+ sw 1 - 2 << a+
	dup 64 and 4 >> 'col0 + @ a!+ sw 1 - 2 << a+
	128 and 5 >> 'col0 + @ a!+ sw 1 - 2 << a+
	sw 3 << neg 1 + 2 << a+
	;

#y
:drawlevels

	100 'y !
	lenx
	'xmasl
	( @+ 1?
		10 y xy>v >a 10 'y +!
		pick2 ( 1? 1 - swap
			c@+ 8lin
			swap ) 2drop
		swap 1 >> swap
		) 3drop

	200 'y !
	lenx
	'ymasl
	( @+ 1?
		10 y xy>v >a 10 'y +!
		pick2 ( 1? 1 - swap
			c@+ 8lin
			swap ) 2drop
		swap 1 >> swap
		) 3drop

	;


|--------------------------------------
:fillx | child x --
	xx0 + minx - 2/ 'xmask +
	lenx 1 + 2/ ( 1?  1 - | child xmin len
		pick2 pick2 c+!
		swap 1 + swap ) 3drop ;

:filly | child x --
	yy0 + miny - 2/ 'ymask +
	lenx 1 + 2/ ( 1?  1 - | child xmin len
		pick2 pick2 c+!
		swap 1 + swap ) 3drop ;

:fillxC | child x --
	xx0 + minx - 'xmask +
	lenx 1 + ( 1?  1 - | child xmin len
		pick2 pick2 c+!
		swap 1 + swap ) 3drop ;

:fillyC | child x --
	yy0 + miny - 'ymask +
	lenx 1 + ( 1?  1 - | child xmin len
		pick2 pick2 c+!
		swap 1 + swap ) 3drop ;

:calclev | len -- a:in b:out
	( 1?  1 -
		a@+ dup $ff00ff and swap 8 >> or $ff00ff and dup 8 >> or
		a@+ dup $ff00ff and swap 8 >> or $ff00ff and dup 8 >> or
		16 << or b!+
		) drop ;

:calclevel
	lenx 3 >> 'xmasl
	( @+ over @ 1?  | adr ms1 ms2
		>b >a over calclev
		swap 2/ swap ) 4drop
	leny 3 >> 'ymasl
	( @+ over @ 1?  | adr ms1 ms2
		>b >a over calclev
		swap 2/ swap ) 4drop
	;

:maskini
	'xmask 0 256 fill
	'ymask 0 256 fill
	;

:algo1
	0 getn 'xx0 ! 'yy0 ! 'zz0 !
	1 getn xx0 - 'xx1 ! yy0 - 'yy1 ! zz0 - 'zz1 !
	2 getn xx0 - 'xx2 ! yy0 - 'yy2 ! zz0 - 'zz2 !
	4 getn xx0 - 'xx4 ! yy0 - 'yy4 ! zz0 - 'zz4 !

    xx1 xx2 xx4 sminmax3
	over - 1 + 'lenx ! xx0 + 'minx !
    yy1 yy2 yy4 sminmax3
	over - 1 + 'leny ! yy0 + 'miny !
    zz1 zz2 zz4 sminmax3
	over - 1 + 'lenz ! zz0 + 'minz !
	30 lenx leny min clz - 'maxlev ! | -2

	'vecpos >a
	0 0 0 packxyz a!+
	xx1 yy1 zz1 packxyz a!+
	xx2 yy2 zz2 packxyz a!+
	xx1 xx2 + yy1 yy2 + zz1 zz2 + packxyz a!+
	xx4 yy4 zz4 packxyz a!+
	xx4 xx1 + yy4 yy1 + zz4 zz1 + packxyz a!+
	xx4 xx2 + yy4 yy2 + zz4 zz2 + packxyz a!+
	xx4 xx1 + xx2 + yy4 yy1 + yy2 + zz4 zz1 + zz2 + packxyz a!+

	maskini
	$1 0 fillx
	$2 xx1 fillx
	$4 xx2 fillx
	$8 xx1 xx2 + fillx
	$10 xx4 fillx
	$20 xx4 xx1 + fillx
	$40 xx4 xx2 + fillx
	$80 xx4 xx2 + xx1 + fillx

	$1 0 filly
	$2 yy1 filly
	$4 yy2 filly
	$8 yy1 yy2 + filly
	$10 yy4 filly
	$20 yy4 yy1 + filly
	$40 yy4 yy2 + filly
	$80 yy4 yy2 + yy1 + filly

	calclevel
	drawrules
	drawlevels

|    draw1

	;

|----------------------------------------
:dumpvar
	$ff00 'ink !
	minz miny minx "%d %d %d " mprint print cr
	lenz leny lenx "%d %d %d " mprint print cr

	xx1 "%d " mprint print cr
	xx1 dup dup 31 >> dup not rot and rot rot and
	"%d %d" mprint print

|	$ffff 'ink ! 0 getp 1 box
|	$ffffff 'ink ! mask getp 3 box
|	minx miny op minx lenx + miny leny + line
	;

|-----------------------------------------
:main
	cls home
	over "%d" mprint print cr

	Omode
	freelook
	xcam ycam zcam mtrans

	fillstart
	fillveciso
	calco

	dumpvar
	drawire

	algo1

	key
	<up> =? ( -0.01 'zcam +! )
	<dn> =? ( 0.01 'zcam +! )
	<le> =? ( -0.01 'xcam +! )
	<ri> =? ( 0.01 'xcam +! )
	<pgup> =? ( -0.01 'ycam +! )
	<pgdn> =? ( 0.01 'ycam +! )
	>esc< =? ( exit )
	drop
	acursor ;

:
	33
	mark
	'main onshow ;