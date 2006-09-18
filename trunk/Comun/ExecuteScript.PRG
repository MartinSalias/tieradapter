If File( 'script.prg' )
	Try
		Local lcScript As String 
		lcScript = FileToStr( 'script.prg' )
		ExecScript( lcScript )
		Wait Window 'Script executed' Nowait
	Catch To loError
		Stop( 'An error was detected in the script, please check it' )
	EndTry 
Else
	Stop( 'File "script.prg" does not exist' )
EndIf 
Return