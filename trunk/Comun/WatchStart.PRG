If Vartype(_Screen.oWatch)="U"
	_Screen.AddProperty( "oWatch" )
EndIf 
_Screen.oWatch = CreateObject("Empty")
AddProperty(_Screen.oWatch,"Started")
AddProperty(_Screen.oWatch,"LastStop")
_Screen.oWatch.Started  = Seconds()
_Screen.oWatch.LastStop = 0
