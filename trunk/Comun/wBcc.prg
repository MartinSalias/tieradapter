* Function...: wBcc
* Author.....: MARTIN
* Date.......: 12/12/1996
* Notes......: Generates a BCC code from a string (Ver 2.0 - ASCII between 32~127)
* Parameters.: tcString
* Returns....: a one byte BCC code
* See Also...: wCRIPT
* 
lparameter tcString

local lnAcum, lnBase, q, lnAsc

* Initialize acummulator
*
lnAcum = 7

* Generates a Base from the first and last characters of the string
*
lnBase = ( asc( left(tcString, 1) ) - asc( right(tcString, 1) ) ) * 4.6

for q = len(tcString) to 1 step -1			&& Scans the string Backward
	
	lnAsc = asc( substr(tcString, q, 1) )	&& Each character in the string
	
	if mod( q, 2) = mod( lnAsc, 2)			&& Sometimes, complements to 200
		lnAsc = 200 - lnAsc
	endif
	
	lnAsc = abs( lnAsc + lnBase + q/1.7 )	&& Crunch the ascii value
	
	lnAcum = lnAcum + lnAsc					&& Accumulates the crunched value
next

do while !between( lnAcum, 32, 127 )
	if lnAcum < 32
		lnAcum = mod( int( lnAcum * len(tcString) )+ lnBase, 77 )
	else
		lnAcum = mod( int( lnAcum / len(tcString) )- lnBase, 77 )
	endif
	lnBase = lnBase + 2
enddo

return chr( lnAcum )
