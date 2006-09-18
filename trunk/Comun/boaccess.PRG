* RR, 15/08/2004
* Entity: Access
* Tier: Business
* 
Define Class boAccess As boSystem Of boSystem.prg OlePublic 

cTierClass  = "doAccess"     && Nombre de la clase con los que hace la instanciación.

Procedure GetUserAccess( tcType As String, tcModule As String ) As String
	Return This.oEntidad.GetUserAccess( tcType, tcModule )
EndProc 

EndDefine 
