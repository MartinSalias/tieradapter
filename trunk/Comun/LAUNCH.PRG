*------------------------------------------------------------------*
* Author........: Martín Salías
* Date..........: 05/05/1999
* Parameters....: none
* Returns.......: none
*)Notes.........: 
*)              : 
* See also......: 
*
Lparameters tcTarget, tcParameters

#Include ..\comun\ms.h
#Include Messages.h

Local llOk

If .t. && llOk
	Local lcExtension, lcParameters, lcCommandLine
	lcExtension = Lower( JustExt( tcTarget ) )
	If Empty( lcExtension )

		lcExtension = "scx"
		tcTarget = Alltrim( tcTarget ) +"."+ lcExtension
	EndIf

	If Empty( tcParameters )
		lcParameters = ""
	Else
		lcParameters = "with "+ tcParameters
	endif

	DO case
	Case lcExtension = "prg"

		lcCommandLine = "DO ( tcTarget ) " + lcParameters
		
	Otherwise
		
		lcCommandLine = "DO form ( tcTarget ) " + lcParameters
	EndCase

	Try
		&lcCommandLine
		
	Catch to oError
		
		Local lcMessage as String 
		
		lcMessage = dcNOTIMPLEMENTED 
		If Version(2) = 2
			
			lcMessage = lcMessage ;
			 + CR + CR + tcTarget ;
			 + ParseError( oError )
			
			If Confirm( lcMessage, "¿Suspend?" )
				SUSPEND
			EndIf 
		Else 
			Warning( lcMessage )
		EndIf
		
	EndTry
Else
EndIf

Return
*---------------------------------*