* RR, 15/08/2004
* Entity: Access
* Tier: User
* 
Define Class uoAccess As uoSystem Of uoSystem.prg

cTierClass  = "boAccess"     && Nombre de la clase con los que hace la instanciación.

Procedure GetUserAccess( tcType As String, tcModule As String ) As Boolean 

	Local loEntidad As Object, lcXML As String, llRetVal As Boolean 
	Try
		loEntidad = This.NextTier()
		lcXML = loEntidad.GetUserAccess( tcType, tcModule )
		This.GetData(lcXML)
		llRetVal = .T.
	Catch To loError
		llRetVal = .F.
		Stop( ParseError( loError ) )
	Finally 
		loEntidad = Null
	EndTry 
	Return llRetVal 

EndProc 

EndDefine 
