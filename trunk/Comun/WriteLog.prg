Lparameters txText
Local lcText as String
lcText = Transform( txText )
StrToFile( Chr( 13 ) + Transform( Datetime() ) + Chr( 13 ) ;
 + Application.FullName + Chr( 13 ) ;
 + lcText + Chr( 13 ) ;
 + Replicate( "-", 80 ), "log.txt", 1 )
 