| Fractal como prueba de rendimiento
| Programa original de Markus Hoffman (2007) para la maquina virtual X11-basic
| Adaptacion de Galileo (2016)

^lib/sys.txt

#bx 0 | Ubicacion
#by 0
#bw 512 | Dimensiones de la ventana
#bh 480
#sx -1.5 | Desplazamiento de la imagen
#sy -1.0
#tw 2.0 | Escala
#th 2.0

:color | c --
  dup dup 3 << $ff and rot 2 << $ff and rot 2 * $ff and 8 << or 8 << or ink ;

:calcula | x y gx gy -- zx zy c
  2dup 0 ( 256 <? 1+ >r
    over dup *. over dup *. - pick4 + | zx
    rot 2 * rot *. pick2 +            | zy
    over dup *. over dup *. + 4.0 >? ( drop r> ; )
  drop r> ) ;

:mandel "Se esta dibujando un fractal. Paciencia ..." print redraw
  0 0 ( bh <? dup
    by - bh /. th *. sy + pick2 | gx
    bx - bw /. tw *. sx + swap  | gy
    calcula >r 4drop r>
    color 2dup a!+ swap 1+ bw =? ( drop 1+ 0 ) swap
  ) 2drop ;

:waitkey
	key 27 =? ( exit ) drop ;

: 	msec
	cls vframe >a
	mandel
	msec swap -
	$ffffff 'color !
	"Se ha tardado %d ms" print
	'waitkey onshow ;
