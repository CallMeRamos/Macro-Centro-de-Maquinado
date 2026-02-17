(****************************************************)
(* M_FUNC.NC - MACROS AUXILIARES ADTECH CNC4940     *)
(* 99 programas - M codes definidos por usuario      *)
(* Patron: #2=1400+N / ##2=valor / LED #1800+N      *)
(* M88/M89 NO estan aqui - son comandos nativos I/O  *)
(* M98/M99 NO estan aqui - son subprogram call/return*)
(****************************************************)
(*                                                    *)
(* ============ TABLA RESUMEN DE I/O ============    *)
(*                                                    *)
(* SEC 1 - REFRIGERANTE M08/M09 (COOL)               *)
(*   M08/M09  = OUT04 (tecla COOL)                   *)
(*                                                    *)
(* SEC 2 - SALIDAS SISTEMA CON LEDs M10-M27          *)
(*   M10/M11  = OUT02  LED #1849                     *)
(*   M12/M13  = OUT03  LED #1852                     *)
(*   M14/M15  = OUT06  LED #1854                     *)
(*   M16/M17  = OUT07  LED #1855                     *)
(*   M18/M19  = OUT08  LED #1856                     *)
(*   M20/M21  = OUT09  LED #1857                     *)
(*   M22/M23  = OUT10  LED #1860                     *)
(*   M24/M25  = DESHABILITADO (antes CHIP CW)         *)
(*   M26/M27  = DESHABILITADO (antes CHIP CCW)        *)
(*                                                    *)
(* SEC 3 - EXTENDIDAS FCNC6D M128-M131              *)
(*   M128/M129 = OUT13  LED #1884  Refrigerante 2   *)
(*   M130/M131 = OUT14  LED #1885  Contactor         *)
(*                                                    *)
(* SEC 4 - LUBRICANTE M32/M33 (LUBE)                 *)
(*   M32/M33  = OUT06 (tecla LUBE)                   *)
(*                                                    *)
(* SEC 5 - SELECCION HERRAMIENTAS F0-F11 + FCNC6D   *)
(*   M34/M35  = OUT15  LED #1886  FCNC6D            *)
(*   M36/M37  = OUT16  LED #1887  FEEDING            *)
(*   M38/M39  = OUT17  LED #1889  Orient. husillo   *)
(*   M40/M41  = F0  LED #1843  Selector pagina       *)
(*   M42/M43  = F1  LED #1848  PAG1:T01 PAG2:T11    *)
(*   M44/M45  = F2  LED #1853  PAG1:T02 PAG2:T12    *)
(*   M46/M47  = F3  LED #1858  PAG1:T03 PAG2:T13    *)
(*   M48/M49  = F4  LED #1863  PAG1:T04 PAG2:T14    *)
(*   M50/M51  = F5  LED #1874  PAG1:T05 PAG2:T15    *)
(*   M52/M53  = F6  LED #1890  PAG1:T06 PAG2:T16    *)
(*   M54/M55  = F7  LED #1891  PAG1:T07 PAG2:T17    *)
(*   M56/M57  = F8  LED #1892  PAG1:T08 PAG2:T18    *)
(*   M58/M59  = F9  LED #1893  PAG1:T09 PAG2:T19    *)
(*   M60/M61  = F10 LED #1894  PAG1:T10 PAG2:T20    *)
(*   M62/M63  = F11 LED #1895  PAG2:T21 solamente    *)
(*   M64/M65  = F12  LED #1896  FCNC6D OUT20         *)
(*   M66/M67  = F13  LED #1897  FCNC6D OUT21         *)
(*                                                    *)
(* SEC 6 - USUARIO M68-M87 (sin LEDs)               *)
(*   M68/M69  = OUT32    M80/M81  = OUT38            *)
(*   M70/M71  = OUT33    M82/M83  = OUT39            *)
(*   M72/M73  = OUT34    M84/M85  = OUT40            *)
(*   M74/M75  = OUT35    M86/M87  = OUT41            *)
(*   M76/M77  = OUT36                                *)
(*   M78/M79  = OUT37                                *)
(*                                                    *)
(* SEC 7 - USUARIO M90-M97 (sin LEDs)               *)
(*   M90/M91  = OUT42    M96/M97  = OUT45            *)
(*   M92/M93  = OUT43                                *)
(*   M94/M95  = OUT44                                *)
(*                                                    *)
(* SEC 8 - EXTENDIDAS M198-M199, M100-M101           *)
(*   M198/M199 = OUT46   M100/M101 = OUT47           *)
(*                                                    *)
(* SEC 9 - HUSILLO O203-O205                         *)
(*   O203 = Adelante M03 (lee #3918, #4118)          *)
(*   O204 = Reversa  M04 (lee #3918, #4118)          *)
(*   O205 = Parar    M05                             *)
(*                                                    *)
(* SEC 10 - REFRIGERANTE/LUBRICANTE CON LEDs         *)
(*   O208/O209 = COOL OUT04  LEDs #1810, #1861       *)
(*   O212/O213 = LUBE OUT06  LEDs #1811, #1859       *)
(*                                                    *)
(* ================================================= *)

(****************************************************)
(* SECCION 1: REFRIGERANTE M08/M09 (tecla COOL)     *)
(* Salida fija: OUT04                                *)
(****************************************************)
O0008
(M08 - COOL Refrigerante ON - OUT04)
#2=1400+4
##2=1
M3000
%
O0009
(M09 - COOL Refrigerante OFF - OUT04)
#2=1400+4
##2=0
M3000
%

(****************************************************)
(* SECCION 2: SALIDAS DEL SISTEMA CON LEDs M10-M27  *)
(* OUT02 a OUT12 - Pares ON/OFF con LED de panel     *)
(* Nota: OUT04 y OUT05 no tienen M codes asignados   *)
(****************************************************)
O0010
(M10 - OUT02 ON + LED #1849)
#2=1400+2
##2=1
#1849=1
M3000
%
O0011
(M11 - OUT02 OFF + LED #1849)
#2=1400+2
##2=0
#1849=0
M3000
%

O0012
(M12 - OUT03 ON + LED #1852)
#2=1400+3
##2=1
#1852=1
M3000
%
O0013
(M13 - OUT03 OFF + LED #1852)
#2=1400+3
##2=0
#1852=0
M3000
%

O0014
(M14 - OUT06 ON + LED #1854)
IF[#3918 != 0]
{
  M3000
}
#2=1400+6
##2=1
#1854=1
M3000
%
O0015
(M15 - OUT06 OFF + LED #1854)
IF[#3918 != 0]
{
  M3000
}
#2=1400+6
##2=0
#1854=0
M3000
%

O0016
(M16 - OUT07 ON + LED #1855)
#2=1400+7
##2=1
#1855=1
M3000
%
O0017
(M17 - OUT07 OFF + LED #1855)
#2=1400+7
##2=0
#1855=0
M3000
%

O0018
(M18 - OUT08 ON + LED #1856)
IF[#3918 != 0]
{
  M3000
}
#2=1400+8
##2=1
#1856=1
M3000
%
O0019
(M19 - OUT08 OFF + LED #1856)
IF[#3918 != 0]
{
  M3000
}
#2=1400+8
##2=0
#1856=0
M3000
%

O0020
(M20 - OUT09 ON + LED #1857)
IF[#3918 != 0]
{
  M3000
}
#2=1400+9
##2=1
#1857=1
M3000
%
O0021
(M21 - OUT09 OFF + LED #1857)
IF[#3918 != 0]
{
  M3000
}
#2=1400+9
##2=0
#1857=0
M3000
%

O0022
(M22 - OUT10 ON + LED #1860)
#2=1400+10
##2=1
#1860=1
M3000
%
O0023
(M23 - OUT10 OFF + LED #1860)
#2=1400+10
##2=0
#1860=0
M3000
%

O0024
(M24 - DESHABILITADO - antes CHIP CW)
M3000
%
O0025
(M25 - DESHABILITADO - antes CHIP CW)
M3000
%

O0026
(M26 - DESHABILITADO - antes CHIP CCW)
M3000
%
O0027
(M27 - DESHABILITADO - antes CHIP CCW)
M3000
%

(****************************************************)
(* SECCION 3: SALIDAS EXTENDIDAS FCNC6D M128-M131   *)
(* OUT13, OUT14 - Fuera del rango secuencial         *)
(****************************************************)
O0128
(M128 - FCNC6D OUT13 ON + LED #1884 - Refrigerante 2)
#2=1400+13
##2=1
#1884=1
M3000
%
O0129
(M129 - FCNC6D OUT13 OFF + LED #1884 - Refrigerante 2)
#2=1400+13
##2=0
#1884=0
M3000
%

O0130
(M130 - FCNC6D OUT14 ON + LED #1885 - Contactor)
#2=1400+14
##2=1
#1885=1
M3000
%
O0131
(M131 - FCNC6D OUT14 OFF + LED #1885 - Contactor)
#2=1400+14
##2=0
#1885=0
M3000
%

(****************************************************)
(* SECCION 4: LUBRICANTE M32/M33 (tecla LUBE)       *)
(* Salida fija: OUT06                                *)
(****************************************************)
O0032
(M32 - LUBE Lubricante ON - OUT06)
#2=1400+6
##2=1
M3000
%
O0033
(M33 - LUBE Lubricante OFF - OUT06)
#2=1400+6
##2=0
M3000
%

(****************************************************)
(* SECCION 5: SELECCION HERRAMIENTAS F0-F11 + FCNC6D *)
(* F0 = Selector pagina (variable #150)               *)
(* F1-F11 = Seleccion herramienta T01-T21             *)
(* F12 = ZERO AXIS (#3934) F13 = CENTER FIND (#3934)   *)
(* OUT15-OUT17, OUT20-OUT21 = FCNC6D                   *)
(****************************************************)
O0034
(M34 - FCNC6D OUT15 ON + LED #1886)
#2=1400+15
##2=1
#1886=1
M3000
%
O0035
(M35 - FCNC6D OUT15 OFF + LED #1886)
#2=1400+15
##2=0
#1886=0
M3000
%

O0036
(M36 - FEEDING OUT16 ON + LED #1887)
#2=1400+16
##2=1
#1887=1
M3000
%
O0037
(M37 - FEEDING OUT16 OFF + LED #1887)
#2=1400+16
##2=0
#1887=0
M3000
%

O0038
(M38 - ORIENTACION HUSILLO OUT17 ON + LED #1889)
IF[#3906 != 2]
{
  M3000
}
IF[#1854 == 1]
{
  M3000
}
#2=1400+17
##2=1
#1889=1
M3000
%
O0039
(M39 - ORIENTACION HUSILLO OUT17 OFF + LED #1889)
IF[#3906 != 2]
{
  M3000
}
IF[#1854 == 1]
{
  M3000
}
#2=1400+17
##2=0
#1889=0
M3000
%

O0040
(M40 - F0 SELECTOR PAGINA HERRAMIENTAS - JOG y MDI/AUTO)
IF[[#3906 != 2] && [#3906 != 1]]
{
  M3000
}
(Apagar LED de herramienta activa)
IF[#151 > 0]
{
  ##151=0
  #151=0
}
(Toggle pagina)
IF[#150 != 1]
{
  #150=1
  (Pagina 1 - blink 1 vez - LED queda OFF)
  #1843=1
  G04 P200
  #1843=0
}
ELSE
{
  #150=2
  (Pagina 2 - blink 2 veces - LED queda ON)
  #1843=1
  G04 P150
  #1843=0
  G04 P150
  #1843=1
  G04 P150
  #1843=0
  G04 P150
  #1843=1
}
(Re-encender LED segun herramienta actual del ATC)
#3=#4120
IF[#3 == 0] GOTO 50
IF[#150 == 1]
{
  IF[#3 > 10] GOTO 50
}
ELSE
{
  IF[#3 < 11] GOTO 50
  #3=#3-10
}
IF[#3 == 1] #151=1848
IF[#3 == 2] #151=1853
IF[#3 == 3] #151=1858
IF[#3 == 4] #151=1863
IF[#3 == 5] #151=1874
IF[#3 == 6] #151=1890
IF[#3 == 7] #151=1891
IF[#3 == 8] #151=1892
IF[#3 == 9] #151=1893
IF[#3 == 10] #151=1894
IF[#3 == 11] #151=1895
##151=1
N50
M3000
%
O0041
(M41 - F0 SELECTOR PAGINA HERRAMIENTAS - JOG y MDI/AUTO)
IF[[#3906 != 2] && [#3906 != 1]]
{
  M3000
}
(Apagar LED de herramienta activa)
IF[#151 > 0]
{
  ##151=0
  #151=0
}
(Toggle pagina)
IF[#150 != 1]
{
  #150=1
  (Pagina 1 - blink 1 vez - LED queda OFF)
  #1843=1
  G04 P200
  #1843=0
}
ELSE
{
  #150=2
  (Pagina 2 - blink 2 veces - LED queda ON)
  #1843=1
  G04 P150
  #1843=0
  G04 P150
  #1843=1
  G04 P150
  #1843=0
  G04 P150
  #1843=1
}
(Re-encender LED segun herramienta actual del ATC)
#3=#4120
IF[#3 == 0] GOTO 50
IF[#150 == 1]
{
  IF[#3 > 10] GOTO 50
}
ELSE
{
  IF[#3 < 11] GOTO 50
  #3=#3-10
}
IF[#3 == 1] #151=1848
IF[#3 == 2] #151=1853
IF[#3 == 3] #151=1858
IF[#3 == 4] #151=1863
IF[#3 == 5] #151=1874
IF[#3 == 6] #151=1890
IF[#3 == 7] #151=1891
IF[#3 == 8] #151=1892
IF[#3 == 9] #151=1893
IF[#3 == 10] #151=1894
IF[#3 == 11] #151=1895
##151=1
N50
M3000
%

O0042
(M42 - F1 herramienta: PAG1=T01 PAG2=T11 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1848=1
#151=1848
IF[#150 != 2]
{
  T1
  #200=1
}
ELSE
{
  T11
  #200=11
}
#153=1
M06
M3000
%
O0043
(M43 - F1 OFF - LED persiste)
M3000
%

O0044
(M44 - F2 herramienta: PAG1=T02 PAG2=T12 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1853=1
#151=1853
IF[#150 != 2]
{
  T2
  #200=2
}
ELSE
{
  T12
  #200=12
}
#153=1
M06
M3000
%
O0045
(M45 - F2 OFF - LED persiste)
M3000
%

O0046
(M46 - F3 herramienta: PAG1=T03 PAG2=T13 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1858=1
#151=1858
IF[#150 != 2]
{
  T3
  #200=3
}
ELSE
{
  T13
  #200=13
}
#153=1
M06
M3000
%
O0047
(M47 - F3 OFF - LED persiste)
M3000
%

O0048
(M48 - F4 herramienta: PAG1=T04 PAG2=T14 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1863=1
#151=1863
IF[#150 != 2]
{
  T4
  #200=4
}
ELSE
{
  T14
  #200=14
}
#153=1
M06
M3000
%
O0049
(M49 - F4 OFF - LED persiste)
M3000
%

O0050
(M50 - F5 herramienta: PAG1=T05 PAG2=T15 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1874=1
#151=1874
IF[#150 != 2]
{
  T5
  #200=5
}
ELSE
{
  T15
  #200=15
}
#153=1
M06
M3000
%
O0051
(M51 - F5 OFF - LED persiste)
M3000
%

O0052
(M52 - F6 herramienta: PAG1=T06 PAG2=T16 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1890=1
#151=1890
IF[#150 != 2]
{
  T6
  #200=6
}
ELSE
{
  T16
  #200=16
}
#153=1
M06
M3000
%
O0053
(M53 - F6 OFF - LED persiste)
M3000
%

O0054
(M54 - F7 herramienta: PAG1=T07 PAG2=T17 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1891=1
#151=1891
IF[#150 != 2]
{
  T7
  #200=7
}
ELSE
{
  T17
  #200=17
}
#153=1
M06
M3000
%
O0055
(M55 - F7 OFF - LED persiste)
M3000
%

O0056
(M56 - F8 herramienta: PAG1=T08 PAG2=T18 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1892=1
#151=1892
IF[#150 != 2]
{
  T8
  #200=8
}
ELSE
{
  T18
  #200=18
}
#153=1
M06
M3000
%
O0057
(M57 - F8 OFF - LED persiste)
M3000
%

O0058
(M58 - F9 herramienta: PAG1=T09 PAG2=T19 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1893=1
#151=1893
IF[#150 != 2]
{
  T9
  #200=9
}
ELSE
{
  T19
  #200=19
}
#153=1
M06
M3000
%
O0059
(M59 - F9 OFF - LED persiste)
M3000
%

O0060
(M60 - F10 herramienta: PAG1=T10 PAG2=T20 - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1894=1
#151=1894
IF[#150 != 2]
{
  T10
  #200=10
}
ELSE
{
  T20
  #200=20
}
#153=1
M06
M3000
%
O0061
(M61 - F10 OFF - LED persiste)
M3000
%

O0062
(M62 - F11 herramienta: PAG2=T21 solamente - SOLO MDI/AUTO)
IF[#3906 != 1]
{
  M3000
}
IF[#152 == 1]
{
  M3000
}
IF[#150 != 2]
{
  M3000
}
IF[#151 > 0]
{
  ##151=0
}
#1895=1
#151=1895
T21
#200=21
#153=1
M06
M3000
%
O0063
(M63 - F11 OFF - LED persiste)
M3000
%

O0064
(M64 - FCNC6D OUT20 ON + LED #1896)
#2=1400+20
##2=1
#1896=1
M3000
%
O0065
(M65 - FCNC6D OUT20 OFF + LED #1896)
#2=1400+20
##2=0
#1896=0
M3000
%

O0066
(M66 - FCNC6D OUT21 ON + LED #1897)
#2=1400+21
##2=1
#1897=1
M3000
%
O0067
(M67 - FCNC6D OUT21 OFF + LED #1897)
#2=1400+21
##2=0
#1897=0
M3000
%

(****************************************************)
(* SECCION 6: SALIDAS DE USUARIO M68-M87             *)
(* OUT32 a OUT41 - Sin LEDs                          *)
(* M88/M89 AUSENTES - son comandos nativos I/O       *)
(****************************************************)
O0068
(M68 - Salida usuario OUT32 ON)
#2=1400+32
##2=1
M3000
%
O0069
(M69 - Salida usuario OUT32 OFF)
#2=1400+32
##2=0
M3000
%

O0070
(M70 - Salida usuario OUT33 ON)
#2=1400+33
##2=1
M3000
%
O0071
(M71 - Salida usuario OUT33 OFF)
#2=1400+33
##2=0
M3000
%

O0072
(M72 - Salida usuario OUT34 ON)
#2=1400+34
##2=1
M3000
%
O0073
(M73 - Salida usuario OUT34 OFF)
#2=1400+34
##2=0
M3000
%

O0074
(M74 - Salida usuario OUT35 ON)
#2=1400+35
##2=1
M3000
%
O0075
(M75 - Salida usuario OUT35 OFF)
#2=1400+35
##2=0
M3000
%

O0076
(M76 - Salida usuario OUT36 ON)
#2=1400+36
##2=1
M3000
%
O0077
(M77 - Salida usuario OUT36 OFF)
#2=1400+36
##2=0
M3000
%

O0078
(M78 - Salida usuario OUT37 ON)
#2=1400+37
##2=1
M3000
%
O0079
(M79 - Salida usuario OUT37 OFF)
#2=1400+37
##2=0
M3000
%

O0080
(M80 - Salida usuario OUT38 ON)
#2=1400+38
##2=1
M3000
%
O0081
(M81 - Salida usuario OUT38 OFF)
#2=1400+38
##2=0
M3000
%

O0082
(M82 - Salida usuario OUT39 ON)
#2=1400+39
##2=1
M3000
%
O0083
(M83 - Salida usuario OUT39 OFF)
#2=1400+39
##2=0
M3000
%

O0084
(M84 - Salida usuario OUT40 ON)
#2=1400+40
##2=1
M3000
%
O0085
(M85 - Salida usuario OUT40 OFF)
#2=1400+40
##2=0
M3000
%

O0086
(M86 - Salida usuario OUT41 ON)
#2=1400+41
##2=1
M3000
%
O0087
(M87 - Salida usuario OUT41 OFF)
#2=1400+41
##2=0
M3000
%

(****************************************************)
(* SECCION 7: SALIDAS DE USUARIO M90-M97             *)
(* OUT42 a OUT45 - Sin LEDs                          *)
(* M88/M89 = comandos nativos I/O del ADTECH         *)
(* M98/M99 = subprogram call/return del sistema       *)
(****************************************************)
O0090
(M90 - Salida usuario OUT42 ON)
#2=1400+42
##2=1
M3000
%
O0091
(M91 - Salida usuario OUT42 OFF)
#2=1400+42
##2=0
M3000
%

O0092
(M92 - Salida usuario OUT43 ON)
#2=1400+43
##2=1
M3000
%
O0093
(M93 - Salida usuario OUT43 OFF)
#2=1400+43
##2=0
M3000
%

O0094
(M94 - Salida usuario OUT44 ON)
#2=1400+44
##2=1
M3000
%
O0095
(M95 - Salida usuario OUT44 OFF)
#2=1400+44
##2=0
M3000
%

O0096
(M96 - Salida usuario OUT45 ON)
#2=1400+45
##2=1
M3000
%
O0097
(M97 - Salida usuario OUT45 OFF)
#2=1400+45
##2=0
M3000
%

(****************************************************)
(* SECCION 8: SALIDAS EXTENDIDAS M198-M199, M100-M101*)
(* OUT46, OUT47 - Sin LEDs                           *)
(* M198/M199 fuera del rango secuencial              *)
(****************************************************)
O0198
(M198 - Salida usuario OUT46 ON)
#2=1400+46
##2=1
M3000
%
O0199
(M199 - Salida usuario OUT46 OFF)
#2=1400+46
##2=0
M3000
%

O0100
(M100 - Salida usuario OUT47 ON)
#2=1400+47
##2=1
M3000
%
O0101
(M101 - Salida usuario OUT47 OFF)
#2=1400+47
##2=0
M3000
%

(****************************************************)
(* SECCION 9: CONTROL DE HUSILLO O203-O205           *)
(* Lee #3918 estado husillo y #4118 velocidad        *)
(* Si husillo parado (#3918==0) arranca, si no para  *)
(****************************************************)
O203
(Husillo adelante - M03 o parar)
IF[#3906 != 2]
{
  M3000
}
#1=#3918(Estado del husillo)
IF[#1==2]
{
  M3000
}
#2=#4118(Velocidad del husillo)
IF[#1==0]
{
 M03S#2
}
ELSE
{
 M05
}
M3000
%
O204
(Husillo reversa - M04 o parar)
IF[#3906 != 2]
{
  M3000
}
#1=#3918(Estado del husillo)
IF[#1==1]
{
  M3000
}
#2=#4118(Velocidad del husillo)
IF[#1==0]
{
 M04S#2
}
ELSE
{
 M05
}
M3000
%
O205
(Parar husillo - M05)
M05
M3000
%

(****************************************************)
(* SECCION 10: REFRIGERANTE Y LUBRICANTE CON LEDs   *)
(* O208/O209 = Refrigerante con LEDs de panel        *)
(* O212/O213 = Lubricante con LEDs de panel          *)
(* Pin dinamico igual que M08/M09 y M32/M33          *)
(****************************************************)
O208
(COOL - Refrigerante ON - OUT04 + LEDs)
#2=1400+4
##2=1
#1810=1(LED refrigerante)
#1861=1(LED auxiliar refrigerante)
M3000
%
O209
(COOL - Refrigerante OFF - OUT04 + LEDs)
#2=1400+4
##2=0
#1810=0(LED refrigerante)
#1861=0(LED auxiliar refrigerante)
M3000
%

O212
(LUBE - Lubricante ON - OUT06 + LEDs)
#2=1400+6
##2=1
#1811=1(LED lubricante)
#1859=1(LED auxiliar lubricante)
M3000
%
O213
(LUBE - Lubricante OFF - OUT06 + LEDs)
#2=1400+6
##2=0
#1811=0(LED lubricante)
#1859=0(LED auxiliar lubricante)
M3000
%
