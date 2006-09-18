*!* Program: PlayWav
*!* Author: MARTIN
*!* Date: 09/03/03 09:41:05 AM
*!* Copyright: 2003 - MS & RR
*!* Description: Plays a wav file
*!* Revision Information:
Lparameters tcWavFile

If Empty( tcWavFile )
	* No sound
Else
	If File( JustStem( tcWavFile )+".wav" )
	
		Set Bell to ( tcWavFile + ".wav" )
		?? Chr(7)
		Set Bell to
	EndIf 
EndIf 

Return  
