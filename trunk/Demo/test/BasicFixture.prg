Define Class BasicFixture As FxuTestCase Of FxuTestCase.prg

	icTestPrefix = "Test"
	
	#If .F.
		Local This As BasicFixture Of BasicFixture.PRG
	#Endif

	*-------------------------------------
	Function Setup
	Endfunc
	
	*-------------------------------------
	Function TestDataTier
		
		
		
	Endfunc
	

	*-------------------------------------
	Function TearDown

	Endfunc

Enddefine
