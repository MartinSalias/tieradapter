* Function...: WCript
* Author.....: MARTIN
* Date.......: 12/12/1996
* Notes......: One way encription (Version 2.0 - ASCII 32~127)
* Parameters.: tcString
* Returns....: the encrypted string
* See Also...: WBcc
* 
Lparameters tcString As String 

Local lcRet As String,  lnBase As Integer, q As Integer, ;
      lnAsc As Integer, lcFilter As String, lnSource As Integer, lnCrypt As Integer

lcRet = ""

* Generates the base on the first and last characters
*
lnBase = Abs(Asc(Left(tcString,1))-Asc(Right(tcString,1))) * 7.7

* RR, 20/08/2004: inicializo q = 0 dado que si tcString viene vacío generaba un error
* porque lnAsc quedaba en .F. al no entrar al FOR

For q = 0 To Len(tcString)						&& Scans the string forward
	
	lnAsc = Asc(Substr(tcString,q,1))			&& Takes each character
	
	lnBase = Mod(lnBase+lnAsc,100)				&& Shift the base
Next 

For q = Len(tcString) To 1 Step -1				&& Scans the string backward
	
	lnAsc = Asc(Substr(tcString,q,1))			&& Takes each character
	
	If Mod(q,2) # 0 And Mod(lnAsc,2) # 0		&& On some cases, complements to 252
		lnAsc = 252 - lnAsc
	EndIf 
	
	lnAsc = (lnAsc + lnBase + q) / 3			&& Applies base and phase
	
	Do While lnAsc > 127						&& Ensures ASCII is below 128
		lnAsc = Mod(lnAsc,77)
	EndDo 
	
	lcRet = lcRet + Chr(lnAsc)					&& Forms the first stage string

Next 

* Hard filter for 2nd stage encryption
*
lcFilter = "J$*&y4h74hnR98+58Dfh_+icDC2#@Jh7$0$*H[}cnDJU328hCK$md0561+-4m,CXE7xb"
lcFilter = Right(lcFilter, lnAsc ) + lcFilter	&& Takes a random portion of the filter
lcFilter = Padr(lcFilter, Len(tcString) )		&& Fix the lenght to the same as string

tcString = lcRet								&& Saves the first stage string
lcRet = ""										&& Empties the variable for 2nd stage

For q = Len(tcString) To 1 Step -1				&& Scans again
	
	lnSource = Asc(Substr(tcString,q,1))		&& Source character
	
	lnCrypt  = Asc(Substr(lcFilter,q,1))		&& Crypt filter
	
	lnAsc    = Max(lnSource,lnCrypt)-Min(lnSource,lnCrypt)	&& Complements
	
	Do While Not Between(lnAsc,32,127)			&& Ensures ASCII is 32~127
		If lnAsc < 32
			lnAsc = (lnAsc+1) * (lnBase)		&& Avoid 0's and 1's
		Else 
			lnAsc = Mod(lnAsc,77)
		EndIf 
		lnBase = lnBase - 4.8
	EndDo 
	
	lcRet = lcRet + Chr(lnAsc)					&& Forms the 2nd stage string
Next 

Return lcRet
