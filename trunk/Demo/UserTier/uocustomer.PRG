* RR, 17/10/2003
* Entidad: Customers
* Capa: Usuario
* 
Define CLASS uoCustomer AS uoGeneral of uoGeneral.prg

cTierClass  = "boCustomer"     		&& Nombre de la clase con los que hace la instanciación.

cSelectorFormName = "CustomersSelector"
cSelectorFields = "CompanyName, CustomerID"
cSelectorCaptions = "Company Name, Customer ID"

cPickOneCursorFields = "CustomerID, CustomerID, CompanyName"
cPickOneTableFields = "CustomerID, CustomerID, CompanyName"

cType ='C'						&& (C=Char/I=Int) - Type para el ingreso del "ID" o "Unique Code" de la entidad
cFormat = '!'					&& Format para el ingreso del "ID" o "Unique Code" de la entidad
cInputMask = 'XXXXX'			&& InputMask para el ingreso del "ID" o "Unique Code" de la entidad

cFormName = "Customer"

EndDefine 
