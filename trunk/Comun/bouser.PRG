* RR, 14/08/2004
* Entity: User
* Tier: Business
* 
Define Class boUser As boSystem Of boSystem.prg OLEPublic

cTierClass  = "doUser"       && Nombre de la clase con los que hace la instanciación.

Procedure GrantAccess( tIdUsuario As Number, tIdAcceso As Number ) AS Boolean

	If tIdUsuario = 0
		Return .F.
	EndIf 

	If Empty( tIdAcceso )
		Return .F.
	EndIf 

	Local loEntidad As Object, llRetVal As Boolean
	loEntidad = NewObject( This.cTierClass, This.cTierModule )
	llRetVal = loEntidad.GrantAccess( tIdUsuario, tIdAcceso )
	Return ( llRetVal )

EndProc 

Procedure GetAccesos( tIdUsuario As Number ) AS String
	Return ( This.oEntidad.GetAccesos( tIdUsuario ) )
EndProc 

Procedure PutAccesos( tIdUsuario As Number, tcDiffGram As String ) AS Boolean
	Return( This.oEntidad.PutAccesos( tIdUsuario, tcDiffGram ) )
EndProc 

Procedure LocateUserByName( tcUserName AS String ) AS String
	Return ( This.oEntidad.GetAll( "cName Like '" + ALLTRIM( tcUserName ) + "'" ) )
EndProc

Procedure ValidateUser( tIdUser AS Number, tcPassword AS String ) AS String

	Local lcXML As String, lcRetVal As String
	Try
	
		lcXML = This.oEntidad.GetOne( tIdUser, 1 )
		This.GetData( lcXML )

		* Regenero el BCC de la tabla para ver si es válido.
		Local lcBCC As String
		lcBCC = This.GenBCC( Alltrim( cUser.cName ), Alltrim( cUser.cPassword ), cUser.iAdmin, cUser.iActive )

		If cUser.cBCC == lcBCC
			* El BCC es válido.
			Local lcPSW As String
			lcPSW = wcript( Alltrim( tcPassword ) )
			If Alltrim( cUser.cPassword ) == Alltrim( lcPSW )
				* La clave ingresada es correcta.
				lcRetVal = "OK"
			Else 
				* La clave ingresada es incorrecta.
				lcRetVal = "ERROR"
			EndIf 
		Else 
			* El BCC no es válido.
			lcRetVal = "INVALID"
		EndIf 
		
		Create Cursor cResult (cResult C(7))
		Insert Into cResult (cResult) Values (lcRetVal)

	Catch To loError
		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 
	EndTry 

	lcRetVal = This.Serialize( "cResult" )

	Return lcRetVal 

EndProc

Procedure SaveNewPsw( tIdUser AS Number, tcPassword AS String ) AS String 

	Local lcXML As String, lnRetVal AS Boolean
	lcXML = This.oEntidad.GetOne( tIdUser, 1 )
	This.GetData( lcXML )

	Replace In cUser ;
			cPassword With wcript( Alltrim( tcPassword ) )
	Replace In cUser ;
			cBCC With This.GenBCC( Alltrim( cUser.cName );
								   , Alltrim( cUser.cPassword );
								   , cUser.iAdmin ;
								   , cUser.iActive )

	Local loMyXA As rrXMLAdapter
	loMyXA = NewObject( 'rrXMLAdapter', 'rrXMLAdapter.Prg' )
	With loMyXA
		.AddTableSchema( 'cUser' )
		lcDiffGram = .GetDiffGram()
	EndWith 
	loMyXA = .F.

	Return( This.oEntidad.Put( tIdUser, lcDiffGram, 1 ) )

EndProc 

Procedure Put( IdEntidad As Number, cDiffGram As String, nLevel AS Number ) As Boolean
	Local loMyXA AS rrXMLAdapter, lcDiffGram As String 
	loMyXA = NewObject( 'rrXMLAdapter', 'rrXMLAdapter.Prg' )
	This.GetBack( idEntidad, cDiffGram, nLevel, loMyXA )
	IF cUser.Id = 0	&& Is a new user.
		Replace In cUser ;
				cPassword With wcript( Alltrim( cUser.cPassword ) )
	EndIf 
	Replace In cUser ;
			cBCC With This.GenBCC( Alltrim( cUser.cName ) ;
			                     , Alltrim( cUser.cPassword ) ;
			                     , cUser.iAdmin ;
			                     , cUser.iActive )
	lcDiffGram = This.PutBack( loMyXA )
	loMyXA = Null
	Return( This.oEntidad.Put( idEntidad, lcDiffGram, nLevel ) )

EndProc

Protected Procedure GenBCC( tcName As String, tcPassword As String, tiAdmin As Number, tiActive As Number ) As String
	Local lcRetVal AS String
	lcRetVal = wcript( ;
		               wbcc( tcName ) ;
		      		 + wbcc( tcPassword ) ;
		      		 + wbcc( IIF( tiAdmin = 1, "SI", "NO" ) ) ;
		 		     + wbcc( IIF( tiActive = 1, "SI", "NO" ) ) )
	Return ( lcRetVal )
EndProc 

EndDefine 
