* RR, 17/10/2003
* Entidad: Shippers
* Capa: Datos
* 
DEFINE CLASS doShipper AS doGeneral of doGeneral.prg OLEPUBLIC

cGetAllFields = "CompanyName, ShipperID"

PROCEDURE Init
	DoDefault()
	This.ColTables.AddTable( 'Shippers', 'cShipper', '', '', '', '', 'ShipperID', .T. )
	RETURN ( This.ColTables.Validate() )
ENDPROC

ENDDEFINE
