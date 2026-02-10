O0123 (Macro de cambio automatico de herramienta)
G90 G599(Programacion absoluta, sistema de coordenadas G599 para cambio de herramienta)
#201=#4120 (lee numero de herramienta actual del sistema)

(--- R3: RESET SEGURO DE SALIDAS ---)
M89 P8 L0 (detiene rotacion carrusel adelante si estaba activa)
M89 P9 L0 (detiene rotacion carrusel atras si estaba activa)

IF[[#200] == 0]GOTO 100 (si herramienta solicitada es 0, sale del cambio)
IF[[#200] == #201]GOTO 100 (si herramienta actual es igual a la solicitada, sale del cambio)

IF[#400 > 21] (alarma si el maximo de herramientas excede 21)
{
	#3000=1 (Error: numero de herramienta excede el maximo del magazin)
}

IF[[[#200] > [#400]] || [[#201] > [#400]]] (alarma si herramienta solicitada o actual excede el maximo del magazin)
{
	#3000=1 (Error: numero de herramienta excede el maximo del magazin)
}

IF[#201==0] (alarma si herramienta actual es 0)
{
	#3000=1 (Error: numero de herramienta actual es cero)
}

G01 Z[#401] F#405 (sube Z a altura segura)
M09 (apaga refrigerante)
M05 (S3: detiene husillo antes de orientar)
M89 P17 L1 (orienta husillo)
G04 P2000 (espera 2000ms orientacion husillo)

IF[[#201]!=0] (verifica si herramienta actual no es 0)
{ (ejecuta si herramienta actual no es cero)
	G01 Z[#404] F#405 (baja Z al punto de referencia)
	M89 P21 L1 (acerca ATC al husillo)
	M88 P26 L0 Q5000 (espera sensor posicion ATC en lugar, alarma si no en 5s)
	(--- PRE-CHECK: sensores deben mostrar CERRADO antes de liberar ---)
	M88 P20 L0 Q3000 (pre-check: P20 LOW = cono cerrado, alarma 3s si no)
	M88 P21 L0 Q3000 (pre-check: P21 LOW = cono cerrado, alarma 3s si no)
	(--- Pre-check OK, procede a liberar cono ---)
	M89 P6 L1 (libera cono del husillo)
	G04 P500 (espera 500ms para mecanismo de liberacion)
	M88 P20 L1 Q3000 (confirma P20 HIGH = cono liberado, alarma 3s si no)
	M88 P21 L1 Q3000 (confirma P21 HIGH = cono liberado, alarma 3s si no)
	G01 Z[#401] F#405 (sube Z para evitar presionar herramienta al liberar)
	G01 Z[#402] F#405 (sube Z a altura segura de retraccion)
}

#1=0 (indicador de direccion de rotacion del carrusel)
IF[#201 > [#400/2]] GOTO 1
IF[[#201 >= #200] || [#200 > [#201+[#400/2]]]] GOTO 2
M89 P8 L1 (rotacion carrusel adelante)
#1=0 (indicador = 0, adelante)
GOTO 3

N2
M89 P9 L1 (rotacion carrusel atras)
#1=1 (indicador = 1, atras)
GOTO 3

N1
IF[[#201 >= #200 && #200 <= #400] && [#200 > [#201+#400/2]MOD#400]] GOTO 4
M89 P8 L1
#1=0
GOTO 3

N4
M89 P9 L1
#1=1

N3
#2=#201 (guarda herramienta actual en variable temporal)
WHILE[#2!=#200] DO1 (repite hasta llegar a herramienta solicitada)
	M88 P23 L0 Q5000 (espera senal conteo en bajo, alarma 5s si no)
	M88 P23 L1 Q5000 (espera senal conteo en alto, alarma 5s si no)
	IF[#1==1] GOTO 7 (verifica direccion de rotacion por indicador)
	#2 = #2+1 (avanza una posicion adelante)
	IF[#2>#400] #2=1 (reinicia a 1 si excede maximo del magazin)
	GOTO 8
	N7
	#2 = #2-1 (retrocede una posicion)
	IF[#2<=0] #2=#400 (reinicia al maximo si llega a 0 o menor)

	N8

END1 (fin del ciclo WHILE)

IF[#1==1] GOTO 5
G04 P#408 (retardo para detener rotacion adelante)
M89 P8 L0 (apaga senal de rotacion adelante)
GOTO 6

N5
G04 P#409 (retardo para detener rotacion atras)
M89 P9 L0 (apaga senal de rotacion atras)

N6
M89 P21 L1 (acerca ATC al husillo)
M88 P26 L0 Q5000 (espera sensor posicion ATC en lugar, alarma si no en 5s)
G01 Z[#403] F#405(baja Z a 2.5mm arriba del punto de referencia)
M89 P6 L0 (cierra cono del husillo)
G04 P1000 (espera 1000ms cierre de cono)
G01 Z[#404] F#405 (baja Z al punto de referencia para insertar herramienta)
(--- S2: POST-CHECK confirma cono CERRADO despues de insercion ---)
M88 P20 L0 Q3000 (confirma P20 LOW = cono cerrado, alarma 3s si no)
M88 P21 L0 Q3000 (confirma P21 LOW = cono cerrado, alarma 3s si no)
M89 P21 L0 (cancela senal de acercamiento ATC)
M89 P20 L1 (regresa ATC a posicion inicial)
M88 P25 L0 Q5000 (espera sensor regreso ATC, alarma si no en 5s)
M89 P20 L0 (cancela senal de regreso ATC)
M89 P17 L0 (cancela orientacion del husillo)
G01 Z[#401] F#405 (sube Z a altura segura)
#5223=#[409+#200] (aplica compensacion de longitud de herramienta en sistema de coordenadas)
N100
M30
%
