* RR, 14/08/2004
* Entity: User
* Tier: Data
* 

Define Class doUser As doSystem Of doSystem.prg OLEPublic

cGetAllFields = "cFullName, cName, Id, cPicture"
cGetAllView = "vUser"

Procedure Init
	If DoDefault()
		This.colTables.AddTable( 'User'       , 'cUser'       , ''     , ''       , '', '', 'Id'           , .F. )
		This.colTables.AddTable( 'UserGroup'  , 'cUserGroup'  , 'User' , 'IdUser' , '', '', 'IdUserGroup'  , .F. )
		This.colTables.AddTable( 'UserAccess' , 'cUserAccess' , 'User' , 'IdUser' , '', '', 'IdUserAccess' , .F. )
		Return ( This.colTables.Validate() )
	EndIf 
EndProc

Procedure GrantAccess( tIdUsuario As Number, tIdAcceso As Number ) AS Boolean

	Local llRetVal As Boolean
	This.ConnectDataBase()
	This.cMyCATable = "lnkUsuarioAcceso"
	This.cMyCAAlias = "cLnkUsuarioAcceso"
	This.cMyCASelectCmd = "SELECT * FROM lnkUsuarioAcceso " ;
	                    + "WHERE lnkUsuarioAcceso.IDUsuario = " + STR( tIdUsuario ) ;
	                    + " AND lnkUsuarioAcceso.IDAcceso = " + STR( tIdAcceso )
	This.MyCABuilder()
	This.DisconnectDataBase()
	llRetVal = ( Reccount( "cLnkUsuarioAcceso" ) = 1 )
	Use In cLnkUsuarioAcceso
	Return ( llRetVal )

EndProc 

Procedure GetAccesos( tIdUsuario As Number ) AS String

	LOCAL lcSQL AS String, loMyCA AS rrCursorAdapter, lcRetVal AS String

	SET TEXTMERGE ON
	TEXT TO lcSQL NOSHOW PRETEXT 7
		SELECT dAcceso.ID, dAcceso.iOrden, dAcceso.cDescripcion, .T. AS lGrantAccess 
			FROM dAcceso 
			WHERE dAcceso.ID IN (SELECT IDAcceso FROM lnkUsuarioAcceso WHERE IDUsuario = <<STR(tIdUsuario)>>) 
		UNION 
		SELECT dAcceso.ID, dAcceso.iOrden, dAcceso.cDescripcion, .F. AS lGrantAccess 
			FROM dAcceso 
			WHERE dAcceso.ID NOT IN (SELECT IDAcceso FROM lnkUsuarioAcceso WHERE IDUsuario = <<STR(tIdUsuario)>>) 
			ORDER BY 2 
	ENDTEXT
	SET TEXTMERGE OFF
	lcSQL = STRTRAN( lcSQL, CHR(13)+CHR(10), "" )

	This.ConnectDataBase()
	loMyCA = NEWOBJECT( "rrCursorAdapter", "rrCursorAdapter.Prg" )
	WITH loMyCA
		.Tables = "dAcceso"
		.Alias = "cAcceso"
		.SelectCmd = lcSQL
		.CursorFill()
		.CursorDetach()
	ENDWITH
	loMyCA = .F.
	This.DisconnectDataBase()
	lcRetVal = This.Serialize( "cAcceso" )
	USE IN cAcceso

	RETURN ( lcRetVal )

ENDPROC

PROCEDURE PutAccesos( tIdUsuario As Number, tcDiffGram As String ) AS Boolean

	SET MULTILOCKS ON

	LOCAL llRetVal AS Boolean

	LOCAL loMyXA AS rrXMLAdapter
	loMyXA = NEWOBJECT( "rrXMLAdapter", "rrXMLAdapter.Prg" )
	WITH loMyXA
		.LoadXML( tcDiffGram )
		.Tables(1).ChangesToCursor()
	ENDWITH

	This.ConnectDataBase()
	LOCAL loMyCA AS rrCursorAdapter
	loMyCA = NEWOBJECT( "rrCursorAdapter", "rrCursorAdapter.Prg" )
	WITH loMyCA
		.Tables = "lnkUsuarioAcceso"
		.SelectCmd = "SELECT * FROM lnkUsuarioAcceso WHERE IdUsuario = " + STR( tIdUsuario )
		.Alias = "cLnkUsuarioAcceso"
		.KeyFieldList = "IDUsuario, IDAcceso"
		.UpdatableFieldList = "IDUsuario, IDAcceso"
		.UpdateNameList = "IDUsuario lnkUsuarioAcceso.IDUsuario, IDAcceso lnkUsuarioAcceso.IDAcceso"
		.CursorFill()
	ENDWITH

	* Turn table buffering on and make some changes
	CURSORSETPROP( "Buffering", 5 )

	SELECT cAcceso
	SCAN
		SELECT cLnkUsuarioAcceso
		LOCATE FOR IdAcceso = cAcceso.ID
		IF FOUND()
			IF cAcceso.lGrantAccess
				* Nada por hacer - Ya está con el acceso permitido al figurar en esta tabla.
			ELSE
				* Le quito el permiso de acceso
				DELETE
			EndIf 
		Else 
			If cAcceso.lGrantAccess
				Insert Into cLnkUsuarioAcceso ( IDUsuario, IDAcceso ) Values ( tIdUsuario, cAcceso.ID )
			Else 
				* Nada por hacer - Ya está con el acceso negado al no figurar en esta tabla.
			EndIf 
		EndIf 
		Select cAcceso
	EndScan 

	Select cLnkUsuarioAcceso

	* Ahora si, abro la transación y aplico, uno a uno, los TABLEUPDATE() correspondientes.
	Begin Transaction 

	llRetVal = TableUpdate( .T. )
	IF llRetVal
		End Transaction 
	Else 
		RollBack 
	EndIf 

	This.DisconnectDataBase()

	loMyCA = .F.
	loMyXA = .F.
	
	Return ( llRetVal )

EndProc 

EndDefine 
