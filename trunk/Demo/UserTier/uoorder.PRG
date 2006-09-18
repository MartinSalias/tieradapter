* RR, 17/10/2003
* Entidades: Orders, OrderDetails
* Capa: Usuario
* 
Define CLASS uoOrder AS uoGeneral of uoGeneral.prg

cTierClass  = "boOrder"       && Nombre de la clase con los que hace la instanciación.

cSelectorFormName = "OrdersSelector"
cSelectorFields = "OrderID, OrderDate, CompanyName, ShippedDate"
cSelectorCaptions = "Order ID, Order Date, Customer, Shipped Date"

EndDefine 
