Define Class SelectorColumn As msColumn Of msBaseClass.prg

	HeaderClass = "SelectorHeader"
	HeaderClassLibrary = "SelectorGridMembers.prg"

EndDefine 

Define Class SelectorHeader As msHeader Of msBaseClass.prg
	
	Function OrderIt() As VOID 
		DoDefault()
		Thisform.nOrder = This.nCurrentColumn
		Thisform.cOrder = Iif( This.cCurrentOrder = [ASCENDING], [ASC], [DESC] )
	EndFunc 

EndDefine 
