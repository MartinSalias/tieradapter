* RR, 17/10/2003
* Entidad: Employees
* Capa: Datos
* 
DEFINE CLASS doEmployee AS doGeneral of doGeneral.prg OLEPUBLIC
cGetAllFields = "LastName, FirstName, EmployeeID"
PROCEDURE Init
	DoDefault()
	This.ColTables.AddTable( 'Employees', 'cEmployee', '', '', '', '', 'EmployeeID', .T. )
	RETURN ( This.ColTables.Validate() )
ENDPROC

ENDDEFINE
