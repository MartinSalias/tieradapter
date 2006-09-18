* RR, 14/08/2004
* Entity: Group
* Tier: Data
* 

Define Class doGroup As doSystem Of doSystem.prg OLEPublic

cGetAllFields = "cFullName, Id"
cGetAllView = "vGroup"

Procedure Init
	If DoDefault()
		This.colTables.AddTable( 'User'       , 'cGroup'      , ''     , ''        , '', '', 'Id'           , .F. )
		This.colTables.AddTable( 'UserGroup'  , 'cUserGroup'  , 'User' , 'IdGroup' , '', '', 'IdUserGroup'  , .F. )
		This.colTables.AddTable( 'UserAccess' , 'cUserAccess' , 'User' , 'IdUser'  , '', '', 'IdUserAccess' , .F. )
		Return ( This.colTables.Validate() )
	EndIf 
EndProc

EndDefine 
