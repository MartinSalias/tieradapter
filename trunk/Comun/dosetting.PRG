* RR, 14/08/2004
* Entity: Setting
* Tier: Data
* 

Define Class doSetting As doSystem Of doSystem.prg OLEPublic

cGetAllFields = "cDomain, cSection, cParameter, IdSetting"

Procedure Init
	If DoDefault()
		This.colTables.AddTable( 'Setting' , 'cSetting' , '' , '' , '', '', 'IdSetting' , .F. )
		Return ( This.colTables.Validate() )
	EndIf 
EndProc

EndDefine 
