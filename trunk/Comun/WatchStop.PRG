Lparameters tcSection, tlResetWatch As String 

If InList( Vartype( _Screen.oWatch ), "X", "U" )
	* No started watch
Else 
	Local lnCurrentStop As Number, lcMessage As String 
	lnCurrentStop = Seconds()
	lcMessage = "Enlapsed time from start: " + Transform( lnCurrentStop - _Screen.oWatch.Started )
	If _Screen.oWatch.LastStop # 0
		lcMessage = lcMessage + ", from last stop: " + Transform( lnCurrentStop - _Screen.oWatch.LastStop )
	EndIf 	
	Debugout tcSection, lcMessage
	If tlResetWatch
		_Screen.oWatch = Null
	Else
		_Screen.oWatch.LastStop = lnCurrentStop 
	EndIf 
EndIf 
