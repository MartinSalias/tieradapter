*------------------------------------------------------------------*
* Author........: Rubén Rovira
* Date..........: 07/16/2003
* Notes.........: Improve the VFP native function SQLEXEC()
*

LPARAMETERS tnConnHandle, tcSQL, tcCursorName

	LOCAL lnResult AS Number
	
	IF PCOUNT() = 3
		lnResult = SQLEXEC( tnConnHandle, tcSQL, tcCursorName )
	ELSE
		lnResult = SQLEXEC( tnConnHandle, tcSQL )
	ENDIF

	If lnResult = 1
		* Todo OK!
	Else 
	    = AError( laErrorArray )
	    Local loError AS Object
	    loError = NewObject( "rrException", "rrException.prg" )
	    With loError
			.ErrorNo = laErrorArray( 1 )
			.Message = laErrorArray( 2 )
			.Procedure = Program()
			.LogError()
		EndWith 
		Throw loError
	EndIf 

Return 