*!* Program: Warning
*!* Author: M.Salías
*!* Date: 05/28/03 10:49:22 AM
*!* Copyright: 
*!* Description: Encapsulates a warning messagebox
*!* Revision Information:

Lparameters tcText as String, tcCaption as String 

Local lcCaption as String, lnDelay As Integer

If Empty( tcCaption )
	if Type( "_Screen.oApp.cAppName" ) = "C" 
		lcCaption = _Screen.oApp.cAppName
	Else
		lcCaption = "Advertencia"
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

MessageBox( tcText, 48, lcCaption, lnDelay )

Return
