*------------------------------------------------------------------*
* Funcion.......: Delay
* Devuelve......: nada
* Autor.........: MARTIN
* Fecha.........: Marzo 2002
* Version.......: 2.0
* Parametros....: lnDemora = tiempo a demorar
*)Notas.........: Espera 'lnDemora' segundos y continúa
*
lparameter lnDemora

DECLARE Sleep IN Win32API INTEGER nMilliseconds

Sleep( lnDemora * 1000 )

return
*--------------------------* Fin de: Delay
