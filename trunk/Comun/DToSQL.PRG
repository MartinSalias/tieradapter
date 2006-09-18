*!*    Programa: DToSQL
*!*       Autor: Rubén O. Rovira
*!*       Fecha: 07/15/03 21:17:22
*!* Descripción: Arma un Convert de SQL-Server para convertir un valor DATETIME recibido
*!*              como parámetro en un STRING con el formato 'yyyy-mm-dd hh:mm:ss.xxx'

Lparameters ttDateTime, tcType

Local ltDateTime As Datetime

* RR, 30/01/2004: Controlo que el DateTime recibido como parametro no sea inferior
* al mínimo permitido en SQL-Server

ltDateTime = Max( Datetime(1900,1,1,12,00,00), ttDateTime )

tcType = Upper( IfEmpty( tcType, "DT" ) )
Local lcType As String
Do Case
	Case tcType = "DT"
		lcType = "120"  && 120 - DATETIME sin milisegundos - 'yyyy-mm-dd hh:mm:ss'
	Case tcType = "D"
		lcType = "102"  && 102 - DATE sola                 - 'yyyy-mm-dd'
	Case tcType = "DTM"
		lcType = "121"  && 121 - DATETIME con milisegundos - 'yyyy-mm-dd hh:mm:ss.xxx'
EndCase 		

Local lcRetVal As String

lcRetVal = "convert( smalldatetime, '" ;
		 + Transform( Year( ltDateTime ), "@L 9999" ) ;
         + "-" ;
         + Transform( Month( ltDateTime ), "@L 99" ) ;
         + "-" ;
         + Transform( Day( ltDateTime ), "@L 99" ) ;
         + " " ;
         + Transform( Hour( ltDateTime ), "@L 99" ) ;
         + ":" ;
         + Transform( Minute( ltDateTime ), "@L 99" ) ;
         + ":" ;
         + Transform( Sec( ltDateTime ), "@L 99" ) ;
         + "', " + lcType + " )"

Return lcRetVal
