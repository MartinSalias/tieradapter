* RR, 17/10/2003
* Entidad: Products
* Capa: Usuario
* 
Define CLASS uoProduct AS uoGeneral of uoGeneral.prg

cTierClass  = "boProduct"     		&& Nombre de la clase con los que hace la instanciación.

cSelectorFormName = "ProductsSelector"
cSelectorFields = "ProductName, ProductID"
cSelectorCaptions = "Product Name, Product ID"

Function CreateIndexes( tcCursorAlias As String ) As VOID
	Stop("pepe")
EndFunc 
 
EndDefine 
