* RR, 17/10/2003
* Entidad: Products
* Capa: Datos
* 
Define Class doProduct AS doGeneral of doGeneral.prg OLEPUBLIC

cGetAllFields = "ProductName, ProductID"
cGetAllPaginatedOrderBy = 'ProductName, ProductID'

Procedure Init
	DoDefault()
	This.ColTables.AddTable( 'Products', 'cProduct', '', '', '', '', 'ProductID', .F. )
	Return ( This.ColTables.Validate() )
EndProc

Procedure GetAllFilterCriteria( tcFilterCriteria As String ) As String
	Local lcRetVal As String
	XMLToCursor( tcFilterCriteria, 'cFilterCriteria' )
	lcRetVal = ''
	Scan
		Do Case
		Case Alltrim( cFilterCriteria.cFilterTag ) ;
		 = "cProductName"
		 	
			lcRetVal = lcRetVal ;
			 + Iif( Empty( lcRetVal ), "", " And " ) ;
			 + "Products.ProductName Like '" ;
			 + Alltrim( cFilterCriteria.cFilterValue ) + "%'"
		EndCase 
	EndScan
	Return lcRetVal
EndProc 

EndDefine 
