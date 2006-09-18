*!* Program: dToExpr
*!* Author: MARTIN
*!* Date: 03/12/04
*!* Copyright: 2004, Martín Salías
*!* Description: Converts a date or datetime to a valid string expression
*!*            : in the {^yyyy/mm/dd} format
*!* Revision Information:

Lparameters tdDate

Local lcReturn as String 

If Empty( tdDate ) ;
 or NOT Vartype( tdDate ) $ "TD"

	lcReturn = "{}"
Else

	lcReturn = "{^" ;
	 + Transform( Year(  tdDate ) ) +"/" ;
	 + Transform( Month( tdDate ) ) +"/" ;
	 + Transform( Day(   tdDate ) ) +"}"
EndIf 

Return lcReturn
* End
