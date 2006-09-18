* RR, 17/10/2003
* Entidades: Orders, OrderDetails
* Capa: Datos
* 
Define Class doOrder AS doGeneral of doGeneral.prg OLEPUBLIC

Procedure Init

	DoDefault()

	#If .T.  && Ejemplo usando una o más tablas.

		* RR, 30/01/2004: Los valores siguientes para las propiedades 
		* cGetAllFields, cGetAllJoins y cGetAllView son para ejemplificar
		* el uso de GetAll y GetAllPaginated contra una o mas tablas.
		
		This.cGetAllFields = "Orders.OrderID, Orders.OrderDate, " ;
		                   + "Customers.CompanyName, Orders.ShippedDate"

		This.cGetAllJoins = " INNER JOIN Customers " ; 
		                  + "ON Orders.CustomerID = Customers.CustomerID "

		This.cGetAllView = ""

	#EndIf
 
	#If .F.  && Ejemplo usando una vista.

		* RR, 30/01/2004: Los valores siguientes para las propiedades 
		* cGetAllFields, cGetAllJoins y cGetAllView son para ejemplificar
		* el uso de GetAll y GetAllPaginated contra una vista.

		This.cGetAllFields = "OrderID, OrderDate, CompanyName, ShippedDate"

		This.cGetAllJoins = ""

		This.cGetAllView = "[Orders Qry]"

	#EndIf

	Local lcSQL AS String

	TEXT TO lcSQL NOSHOW PRETEXT 7
		SELECT Orders.OrderID, Orders.CustomerID, Customers.CompanyName, Orders.EmployeeID, 
               Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, 
               Orders.ShipVia, Orders.Freight, Orders.ShipName, Orders.ShipAddress, 
               Orders.ShipCity, Orders.ShipRegion, Orders.ShipPostalCode, Orders.ShipCountry 
		 FROM 
		     Orders 
		   INNER JOIN Customers 
		   ON Orders.CustomerID = Customers.CustomerID 
	ENDTEXT
	lcSQL = STRTRAN( lcSQL, CHR(13)+CHR(10), "" )

	This.ColTables.AddTable( 'Orders' , 'OrderHeader' , '' , '' , '', lcSQL, 'OrderID', .F. )

	If This.cBackEndEngine = "SQLOLEDB"
		*!* RR, 30/10/2003: Para usar con Northwind de SQL-Server
		TEXT TO lcSQL NOSHOW PRETEXT 7
			SELECT [Order Details].ProductID, Products.ProductName, [Order Details].Quantity, 
	   	           [Order Details].UnitPrice, [Order Details].Discount, 00000000.00 AS TotalItem, [Order Details].OrderID 
			 FROM [Order Details] 
			   INNER JOIN Products 
			     ON Products.ProductID = [Order Details].ProductID 
		ENDTEXT
		lcSQL = STRTRAN( lcSQL, CHR(13)+CHR(10), "" )
		This.ColTables.AddTable( '[Order Details]' , 'OrderDetail' , 'Orders' , 'OrderID' , '', lcSQL, 'OrderID, ProductID', .T. )
	Else
		*!* RR, 30/10/2003: Para usar con Northwind de VFP
		TEXT TO lcSQL NOSHOW PRETEXT 7
			SELECT OrderDetails.ProductID, Products.ProductName, OrderDetails.Quantity, 
            	   OrderDetails.UnitPrice, OrderDetails.Discount, 00000000.00 AS TotalItem, OrderDetails.OrderID 
			 FROM OrderDetails 
			   INNER JOIN Products 
			     ON Products.ProductID = OrderDetails.ProductID 
		EndText 
		lcSQL = Strtran( lcSQL, CHR(13)+CHR(10), "" )
		This.ColTables.AddTable( 'OrderDetails' , 'OrderDetail' , 'Orders' , 'OrderID' , '', lcSQL, 'OrderID, ProductID', .T. )
	EndIf

	Return ( This.ColTables.Validate() )
EndProc 

Procedure GetAllFilterCriteria( tcFilterCriteria As String ) As String
	Local lcRetVal As String
	XMLToCursor( tcFilterCriteria, 'cFilterCriteria' )
	lcRetVal = ''
	Scan
		*!* Para usar con Northwind de SQL-Server
		If This.cBackEndEngine = "SQLOLEDB"
			Do Case
				Case Alltrim( cFilterCriteria.cFilterTag ) = "dOrderDateFrom"
					lcRetVal = lcRetVal + Iif( Empty( lcRetVal ), "", " And " ) + "OrderDate >= " + DToSql( Ctot( Alltrim( cFilterCriteria.cFilterValue ) ) )
				Case Alltrim( cFilterCriteria.cFilterTag ) = "dOrderDateTo"
					lcRetVal = lcRetVal + Iif( Empty( lcRetVal ), "", " And " ) + "OrderDate <= " + DToSql( Ctot( Alltrim( cFilterCriteria.cFilterValue ) ) )
			EndCase 
		Else
			*!* Para usar con Northwind de VFP
			Do Case
				Case Alltrim( cFilterCriteria.cFilterTag ) = "dOrderDateFrom"
					lcRetVal = lcRetVal + Iif( Empty( lcRetVal ), "", " And " ) + "OrderDate >= " + Alltrim( cFilterCriteria.cFilterValue )
				Case Alltrim( cFilterCriteria.cFilterTag ) = "dOrderDateTo"
					lcRetVal = lcRetVal + Iif( Empty( lcRetVal ), "", " And " ) + "OrderDate <= " + Alltrim( cFilterCriteria.cFilterValue )
			EndCase 
		EndIf 
	EndScan
	Return lcRetVal
EndProc 

EndDefine 
