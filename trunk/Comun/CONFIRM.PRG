*!* Program: Confirm
*!* Author: M.Salías
*!* Date: 05/28/03 11:01:22 AM
*!* Copyright: 
*!* Description: Encapsulates a confirmation messagebox
*!* Revision Information:

Lparameters tcText as String, tcCaption as String, tcWavFile as String 

Local lcCaption as String, lnDelay As Integer

If Empty( tcCaption )
	if Type( "_Screen.oApp.cAppName" ) = "C" 
		lcCaption = _Screen.oApp.cAppName
	Else
		lcCaption = "Confirme"
	EndIf
Else
	lcCaption = tcCaption
EndIf

PlayWav( tcWavfile )


If Type( "_Screen.oApp.lDebugMode" ) = "L" And _Screen.oApp.lDebugMode
	lnDelay = 0
Else
	lnDelay = 10 * 1000
EndIf

Wait clear

Return ( MessageBox( tcText, 32+4+256, lcCaption, lnDelay ) = 6 )

Return


