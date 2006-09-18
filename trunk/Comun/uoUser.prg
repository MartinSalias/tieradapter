* RR, 14/08/2004
* Entity: User
* Tier: User
* 
Define Class uoUser AS uoSystem of uoSystem.prg

cTierClass  = "boUser"     && Nombre de la clase con los que hace la instanciación.

cSelectorFields = "cFullName, cName, Id"
cSelectorCaptions = "Descripción, Nombre, Código"

cPickOneCursorFields = "Id, Id, cName"
cPickOneTableFields = "Id, Id, cName"

cFormName = "User"

IDUser = 0
cName = ""
cFullName = ""
lAdmin = .F.

Procedure Login AS Void
	If _SCREEN.oApp.lDebugMode
		With This
			.IDUser = 1
			.cName = "Admin (Develop)"
			.lAdmin = .T.
			_SCREEN.oApp.BuildMenu("MainMenu")
		EndWith 
	Else 
		Do Form login With This To oSelectedUser
		With This
			If oSelectedUser.Estado = "OK" And .GetOne( oSelectedUser.IDUser, 1 )
				.IDUser = cUser.Id
				.cName = Alltrim( cUser.cName )
				.lAdmin = (cUser.iAdmin = 1)
				.oUser = .SetUserData()
				_SCREEN.oApp.AppCaption()
				_SCREEN.oApp.BuildMenu("MainMenu")
				_SCREEN.Refresh()
			Else 
				.Logout(.T.)
			EndIf 
		EndWith 
	EndIf 
EndProc 

Procedure Logout( tlForced As Boolean ) As Void

	* Logout forced or by user confirmation
	Local llReturn
	llReturn = tlForced ;
	         Or ( Confirm( "Logout the aplication?" ) ;
	              And _SCREEN.oApp.ExitHook() )
	If llReturn 
		With This
			.IDUser = 0
			.cName = "Unknown"
			.lAdmin = .F.
			.oUser = .SetUserData()
			_SCREEN.oApp.AppCaption()
			_SCREEN.oApp.BuildMenu()
			_SCREEN.Refresh()
		EndWith 
	EndIf 

EndProc 

Procedure GrantAccess( tIdAcceso As Number ) As Boolean

	If This.lIsAdmin
		Return .T.
	EndIf 

	Local loEntidad As Object, llRetVal As Boolean
	loEntidad = NewObject( This.cTierClass, This.cTierModule )
	llRetVal = loEntidad.GrantAccess( This.IDUser, tIdAcceso )
	Return ( llRetVal )

EndProc 

Procedure GetAccesos( tIdUsuario As Number ) AS Boolean

	Local loEntidad AS Object, lcXML AS String
	loEntidad = This.NextTier()
	lcXML = loEntidad.GetAccesos( tIdUsuario )
	This.GetData( lcXML )

EndProc

Procedure PutAccesos( tIdUsuario As Number ) AS Boolean

	Local loEntidad As Object, lcDiffGram As String 

	Local loMyXA As rrXMLAdapter
	loMyXA = NewObject( "rrXMLAdapter", "rrXMLAdapter.Prg" )
	With loMyXA
		.AddTableSchema( "cAcceso" )
		lcDiffGram = .GetDiffGram()
	EndWith 
	loMyXA = .F.

	loEntidad = This.NextTier()
	Return( loEntidad.PutAccesos( tIdUsuario, lcDiffGram ) )

ENDPROC

* Busca un usuario en la tabla User por el nombre de usuario.
Procedure LocateUserByName( tcUserName As String ) As Boolean
	Local loEntidad As Object, lcXML As String
	loEntidad = This.NextTier()
	lcXML = loEntidad.LocateUserByName( tcUserName )
	This.GetData( lcXML )
EndProc

* Valida la password ingresada por el usuario.
Procedure ValidateUser( tIdUser As Number, tcPassword As String ) AS String
	Local loEntidad As Object, lcRetVal As String
	lcRetVal = ""
	Try
		loEntidad = This.NextTier()
		lcRetVal = loEntidad.ValidateUser( tIdUser, tcPassword )
		This.GetData(lcRetVal)
		lcRetVal = Alltrim(cResult.cResult)
	Catch To loError
		loMyError = NewObject( "rrException", "rrException.prg" )
		With loMyError
			.Save( loError )
			.Throw()
		EndWith 
	Finally 
	EndTry 
	Return lcRetVal
EndProc

* Graba el cambio de password de un usuario.
Procedure SaveNewPsw( tIdUser As Number, tcPassword As String ) As Boolean
	Local loEntidad AS Object, llRetVal AS Boolean, lcXML As String 
	Try
		loEntidad = This.NextTier()
		lcXML = loEntidad.SaveNewPsw( tIdUser, tcPassword )
		This.GetData( lcXML )
		llRetVal = .T.
	Catch To loError
		Stop( ParseError( loError ) )
		llRetVal = .F.
	Finally 
	EndTry 
	Return llRetVal
EndProc 

* Chequea la cantidad de usuarios en la tabla "User" y en caso de no existir ninguno
* crea el usuario Admin con password en blanco y privilegios de administrador.
Procedure ChkIfOneUserExist As VOID 
	If This.GetAll()
		If Reccount("cUser")=0
			If This.New(1)
				Replace In cUser ;
						cType     	With "U" , ;
						cName     	With "Admin" , ;
						cFullName 	With "Administrator" , ;
						cPassword 	With "" , ;
						iAdmin      With 1 , ;
						iActive     With 1 , ;
						dCreation   With Datetime()
				If This.Put(0)
					Information([Se ha creado un nuevo usuario]+Chr(13);
					           +[llamado "Admin", con contraseña en blanco]+Chr(13);
					           +[y privilegios de Administrador.])
				EndIf 
			EndIf 
		EndIf 
	EndIf 
EndProc 

EndDefine 
