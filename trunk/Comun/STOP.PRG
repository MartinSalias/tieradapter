*!* Program: Stop
*!* Author: R.Rovira
*!* Date: 06/22/03  6:06:22 PM
*!* Copyright: 
*!* Description: Encapsulates a stop messagebox
*!* Revision Information:

Lparameters tcText as String, tcCaption as String 

Local lcCaption as String, lnDelay As Integer

If Empty( tcCaption )
	if Type( "_Screen.oApp.cAppName" ) = "C" 
		lcCaption = _Screen.oApp.cAppName
	Else
		lcCaption = "Error grave"
	EndIf
Else
	lcCaption = tcCaption
EndIf

If Type( "_Screen.oApp.lDebugMode" ) = "L" And _Screen.oApp.lDebugMode
	lnDelay = 0
Else
	lnDelay = 10 * 1000
EndIf

Wait clear

MessageBox( tcText, 16, lcCaption, lnDelay )

Return


