*!* Program: Billboard
*!* Author: MS
*!* Date: 05/30/03 02:31:42 PM
*!* Copyright: 2003, MS
*!* Description: A big centered wait window
*!* Revision Information:

Lparameters tcText

If Empty( tcText )
	Wait clear 
Else 
	Local lnSaveMemoWidth as Integer ;
	 lnY as Integer, lnX as Integer, ;
	 lcText as String, lcLine as String 
	
	* Saves memo width
	lnSaveMemoWidth = Set( "MemoWidth", 1 )
	
	* Fixed width
	lnX = 100
	lcText = ""
	Set Memowidth To lnX - 40
	
	* Parse the string line by line
	For lnY = 1 to Memlines( tcText )
		
		* Takes each text line
		lcLine = Alltrim( Mline( tcText, lnY ) )
		* Centers the text in a fixed width
		lcText = lcText + Padc( lcLine, lnX )
	Next
	
	* Adds blank lines above and bellow
	lcText = Chr(13) + lcText + Chr(13) 

	* Restores memo width
	Set Memowidth To lnSaveMemoWidth
	
	* Calculate X and Y positions
	lnY = (Srows()/2) - (lnY/2)
	lnX = (Scols()/2) - (lnX/2)

	Clear Typeahead
	Wait clear 
	
	* Slight offsets included to improve visual centering
	Wait window lcText nowait at lnY-2, lnX + 10

EndIf 

Return
