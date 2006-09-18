* RR, 17/10/2003
* Entidad: Customers
* Capa: Datos
* 
Define Class doCustomer AS doGeneral of doGeneral.prg OLEPUBLIC

cGetAllFields = "CompanyName, CustomerID"
cGetAllPaginatedOrderBy = 'CompanyName, CustomerID'

Procedure Init
	DoDefault()
	This.ColTables.AddTable( 'Customers', 'cCustomer', ;
	 '', '', '', '', 'CustomerID', .T. )
	 
	Return ( This.ColTables.Validate() )
EndProc 

Procedure GetAllFilterCriteria( tcFilterCriteria As String ) As String

	Local lcRetVal As String
	XMLToCursor( tcFilterCriteria, 'cFilterCriteria' )
	lcRetVal = ''
	Scan
		Do Case
		Case Alltrim( cFilterCriteria.cFilterTag ) = "cCustomerID"
		
			lcRetVal = lcRetVal ;
			 + Iif( Empty( lcRetVal ), "", " And " ) ;
			 + "Customers.CustomerID Like '" ;
			 + Alltrim( cFilterCriteria.cFilterValue ) + "%'"
			 
		Case Alltrim( cFilterCriteria.cFilterTag ) = "cCompanyName"
			
			lcRetVal = lcRetVal ;
			 + Iif( Empty( lcRetVal ), "", " And " ) ;
			 + "Customers.CompanyName Like '" ;
			 + Alltrim( cFilterCriteria.cFilterValue ) + "%'"
			 
		Case Alltrim( cFilterCriteria.cFilterTag ) = "cCity"
		
			lcRetVal = lcRetVal ;
			+ Iif( Empty( lcRetVal ), "", " And " ) ;
			+ "Customers.City Like '" ;
			+ Alltrim( cFilterCriteria.cFilterValue ) + "%'"
			
		Case Alltrim( cFilterCriteria.cFilterTag ) = "cCountry"
		
			lcRetVal = lcRetVal ;
			+ Iif( Empty( lcRetVal ), "", " And " ) ;
			+ "Customers.Country Like '" ;
			+ Alltrim( cFilterCriteria.cFilterValue ) + "%'"
			
		EndCase 
	EndScan
	
	Return lcRetVal
EndProc 

EndDefine 
