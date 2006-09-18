* RR, 15/08/2004
* Entity: Access
* Tier: Data
* 

Define Class doAccess AS doSystem of doSystem.prg OlePublic

Procedure Init

	DoDefault()

	This.colTables.AddTable( 'Access' , 'cAccess' , '' , '' , '', '', 'IdAccess', .F. )

	Return ( This.colTables.Validate() )

EndProc

Procedure GetUserAccess( tcType As String, tcModule As String ) As String

	Local lcRetVal AS String

	Local llAlreadyConnected As Boolean 

	Try 

		llAlreadyConnected = Not This.ConnectToBackend()

		Local lcSQL As String
		lcSQL = "Select * From Access Where "
		If This.oUser.lAdmin
			* No filters to add
		Else
			* Add some filters
			lcSQL = lcSQL + [ IdAccess In (Select IdAccess From UserAccess Where IdUser = ] + Alltrim(Str(This.oUser.IdUser))
			lcSQL = lcSQL + [Or IdUser In (Select IdGroup  From UserGroup  Where IdUser = ] + Alltrim(Str(This.oUser.IdUser))
			lcSQL = lcSQL + [)) And ]
		EndIf 
		lcSQL = lcSQL + [cType = '] + Alltrim(tcType) + [' And cModule = '] + Alltrim(tcModule) + [']

		Local loMyCA As rrCursorAdapter
		loMyCA = NewObject( "rrCursorAdapter", "rrCursorAdapter.Prg", "", This.cAccessType, This.oADOConnection )
		With loMyCA
			.Alias = "cUserAccess"
			.SelectCmd = lcSQL
			.CursorFill()
			.CursorDetach()
		EndWith 
		loMyCA = .F.
		Release loMyCA

	Catch To loError

		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 

		If Not llAlreadyConnected 
			This.DisconnectFromBackend()
		EndIf 

	EndTry 

	Return ( This.Serialize( "cUserAccess" ) )

EndProc 


EndDefine

