*------------------------------------------------------------------*
* Author........: Rubén Rovira
* Date..........: 06/30/2003
* Notes.........: Subclass Exception Base Class
*
#INCLUDE ..\COMUN\ms.h

DEFINE CLASS rrException AS Exception

Details = ""
ErrorNo = 0
LineContents = ""
LineNo = 0
Message = "" 
Procedure = "" 
StackLevel = 0
cStackInfo = ""

Procedure Init
	If Not Used( "cExceptionInformation" )
		Create Cursor cExceptionInformation ( Details Varchar(250), ErrorNo Integer, ErrorLevel Varchar(50), LineContents Varchar(250), LineNo Integer, Message Varchar(250), Procedure Varchar(250), StackLevel Integer, cStackInfo Memo )
	EndIf 
EndProc 

Procedure Save( toError AS Object ) AS Void

	Local lnStackLevel AS Integer, lcStackInfo AS String
	
	lnStackLevel = AStackInfo( laStackArray ) - 1  && Resto 1 para ignorar el método actual!
	lcStackInfo = CR
	For i = lnStackLevel TO 1 STEP -1
		*	Array 	Element Description 
		*	1 		Call Stack Level  
		*	2 		Current program filename  
		*	3 		Module or Object name  
		*	4 		Module or Object Source filename  
		*	5 		Line number in the object source file 
		*	6 		Source line contents
		lcStackInfo = lcStackInfo + [ *  Level: ] + Alltrim( Transform( laStackArray(i,1) ) ) + CR
		lcStackInfo = lcStackInfo + [   Method: ] + Alltrim( laStackArray(i,3) ) + CR
		lcStackInfo = lcStackInfo + [  Program: ] + Alltrim( laStackArray(i,4) ) + CR
		lcStackInfo = lcStackInfo + [     Line: ] + "(Nº " + Alltrim( Transform( laStackArray(i,5) ) ) + ") "
		lcStackInfo = lcStackInfo + Alltrim( Strtran( laStackArray(i,6), CHR(9), "" ) ) + CR && CHR(9) = TAB
	EndFor

	WITH This
		IF VarType( toError ) = "O"
			* Elimino los "User thrown errors" y me quedo con el error "original"
			DO WHILE VarType( toError.UserValue ) = "O"
				toError = toError.UserValue
			EndDo 
			.Details = toError.Details
			.ErrorNo = toError.ErrorNo
			.LineContents = toError.LineContents
			.LineNo = toError.LineNo
			.Message = toError.Message
			.Procedure = toError.Procedure
			.StackLevel = toError.StackLevel
		EndIf 
		.cStackInfo = lcStackInfo
	EndWith 

	Insert Into cExceptionInformation From Name This
	
	This.LogError()

EndProc 

Procedure Set( tnErrorNo As Integer, tcMessage As String, tcProcedure As String, tcDetails As String, tnLineNo As Integer, tcLineContents As String, tnStackLevel As Integer, tnStackInfo As String ) AS Void
	With This
		.ErrorNo 		= Iif( Empty( tnErrorNo ), 		0, 	tnErrorNo )
		.Message 		= Iif( Empty( tcMessage ), 		"", tcMessage )
		.Procedure 		= Iif( Empty( tcProcedure ), 	"", tcProcedure )
		.Details 		= Iif( Empty( tcDetails ), 		"",	tcDetails )
		.LineNo 		= Iif( Empty( tnLineNo ), 		0, 	tnLineNo )
		.LineContents 	= Iif( Empty( tcLineContents ), "", tcLineContents )
		.StackLevel 	= Iif( Empty( tnStackLevel ), 	0, 	tnStackLevel )
		.cStackInfo 	= Iif( Empty( tnStackInfo ), 	"", tnStackInfo )
	EndWith 
	Insert Into cExceptionInformation From Name This
EndProc 

Protected Procedure GenErrorInfo()

	Local lcError AS String

	With This
		lcError = [Error: ]			+ ALLTRIM( Transform( .ErrorNo ) ) + CR ;
				+ [Message: ]		+ ALLTRIM( .Message ) + CR ;
				+ [Procedure: ]		+ ALLTRIM( .Procedure ) + CR ;
				+ [LineNo: ]		+ ALLTRIM( Transform( .LineNo ) ) + CR ; 
				+ [Details: ]		+ ALLTRIM( .Details ) + CR ;
				+ [LineContents: ]	+ ALLTRIM( .LineContents ) + CR ;
				+ [StackLevel: ]	+ ALLTRIM( Transform( .StackLevel ) ) + CR ;
				+ [StackInfo: ]	    + ALLTRIM( .cStackInfo )
	EndWith 

	Return ( lcError )

EndProc 

Procedure LogError()

	Local lcError AS String

	lcError = Replicate( "*", 80 )	+ CR ;
			+ [Date: ]				+ Alltrim( Transform( Date(), "@D" ) ) + CR ;
			+ [Time: ]				+ Alltrim( Time() ) + CR ;
			+ [UserName: ]		 	+ Alltrim( This.GetUser() ) + CR ;
			+ This.GenErrorInfo()	+ CR ;
			+ Replicate( "*", 80 )	+ CRLF

	StrToFile( lcError, "Log.err", 1 )

EndProc 

Procedure Fill()
	If Used( 'cExceptionInformation' )
		Go Bottom
		* Aquí no hago un "SCATTER NAME" porque si el cursor tiene campos Memo no los levanta.
		With This
			.Details = cExceptionInformation.Details
			.ErrorNo = cExceptionInformation.ErrorNo
			.LineContents = cExceptionInformation.LineContents
			.LineNo = cExceptionInformation.LineNo
			.Message = cExceptionInformation.Message
			.Procedure = cExceptionInformation.Procedure
			.StackLevel = cExceptionInformation.StackLevel
			.cStackInfo = cExceptionInformation.cStackInfo
		EndWith 
	Else 
		Warning( "No existe el cursor con la información de los errores ocurridos." )
	EndIf 
EndProc 

Procedure Throw()
	Throw This
EndProc 

Procedure ShowError()
	Stop( This.GenErrorInfo() )
EndProc 

Protected Procedure GetUser()
	Local lcRetVal AS String
	If Vartype( _Screen.oApp.oUser ) = "O"
		lcRetVal = _Screen.oApp.oUser.cName
	Else 
		lcRetVal = "Undefined"
	EndIf 
	Return ( lcRetVal )
EndProc 

EndDefine 