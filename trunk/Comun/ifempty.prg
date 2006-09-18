*------------------------------------------------------------------*
* Funcion.......: IfEmpty
* Devuelve......: value of any type
* Autor.........: MARTIN
* Fecha.........: 28/04/2003
* Version.......: 1.0
* Parametros....: Value to evaluate, Value to return if empty
*)Notas.........: Returns the first parameter as is, or the second one if first is empty
*
Lparameters txEvaluate, txReturnIfEmpty

Return Iif( Empty( txEvaluate ), txReturnIfEmpty, txEvaluate )
