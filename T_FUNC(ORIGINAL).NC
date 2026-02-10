O0123 (Program number)
G90 G599(Use absolute programming after switching to toolchange, use G599 coordinate system, can’t be used in processing file)
#201=#4120 (read current tool number to #201)




IF[[#200] == 0]GOTO 100 (#200 is the tool number to be changed; if the changed tool number is 0, exit from tool change)
IF[[#200] == #201]GOTO 100 (if current tool is same to the tool to be changed, exit from tool change)

IF[#400 > 21] (the system alarms if the maximum tool number exceeds 24)
{
	#3000=1 (Warning: set tool number exceeds the maximum tool number of the tool magazine!) (system parameter 3001 alarm; alarm content can be modified)
}

IF[[[#200] > [#400]] || [[#201] > [#400]]] (alarm if the tool number to be changed and current tool number of the system exceed the maximum tool number)
{
	#3000=1 (Warning: set tool number exceeds the maximum tool number of the tool magazine!) (system parameter 3001 alarm; alarm content can be modified)
}

IF[#201==0] (alarm if current tool number is 0)
{
	#3000=1 (current tool number zero error!)
}

G01 Z[#401] F#405 (Z axis rises to a safe altitude)
M09 (turn off cooling)
M89 P17 L1 (orienta)
G04 P2000 (delay 1500 ms)

IF[[#201]!=0] (check whether current tool is 0)
{ (execute following codes if nonzero)
	G01 Z[#404] F#405 (machine tool moves to Z axis reference point)
	M89 P21 L1 (acerca atc)
	M88 P26 L0 (wait for exit in-place)
	M89 P6 L1 (liberar cono)
	G04 P500 (delay 1500 ms)
	G01 Z[#401] F#405 (Z axis rises 2.5 ms, prevent pressing the cutter during tool release)
	G01 Z[#402] F#405 (Z axis rises to a safe altitude)
}

#1=0 (cutter forward/reverse rotation sign)
IF[#201 > [#400/2]] GOTO 1
IF[[#201 >= #200] || [#200 > [#201+[#400/2]]]] GOTO 2
M89 P8 L1 (cutter forward rotation)
#1=0 (the sign is 0)
GOTO 3

N2
M89 P9 L1 (cutter reverse rotation)
#1=1 (the sign is 1)
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
#2=#201 (save current tool number in temporary variable)
WHILE[#2!=#200] DO1 (check whether equals to the tool number to be changed)
	M88 P23 L0 (wait for cutter count signal becoming low)
	M88 P23 L1 (wait for cutter count signal becoming high)
	IF[#1==1] GOTO 7 (check forward/reverse rotation through the sign)
	#2 = #2+1 (forward rotation variable increases one tool position every time)
	IF[#2>#400] #2=1 (start counting from 1 if larger than tool number of the system)
	GOTO 8
	N7
	#2 = #2-1 (forward rotation variable increases one tool position every time)
	IF[#2<=0] #2=#400 (start counting from the maximum tool number if smaller than 0)
	
	N8

END1 (cycle end keyword)

IF[#1==1] GOTO 5
G04 P#408 (turn off forward rotation after delay)
M89 P8 L0 (turn off forward rotation signal)
GOTO 6

N5
G04 P#409 (turn off reverse rotation after delay)
M89 P9 L0 (turn off reverse rotation signal)

N6
M89 P21 L1 (output cutter exit signal)
M88 P26 L0 (wait for exit in-place)
G01 Z[#403] F#405(Z axis moves to 2.5 ms above reference point) 
M89 P6 L0 (cierra cono)
G04 P1000 (delay 1500 ms)
G01 Z[#404] F#405 (move Z axis to the reference point simultaneously, preventing principal axis clamping the cutter in the process of clamping)
M89 P21 L0 (cancela adelante)
M89 P20 L1 (regresa atc)
M88 P25 L0 (sensor de regreso)
M89 P20 L0 (cancela regresa atc)
M89 P17 L0 (cancela orientacion)
G01 Z[#401] F#405 (Z axis rises to a safe altitude)
#5223=#[409+#200] (set the tool setting value corresponding to current tool number in the coordinate system, and realize the tool compensation function of different lengths)
N100
M30
%
