*------------------------------------------------------------------*
* Author........: Martín Salías
* Date..........: 06/12/2001
* Parameters....: none
* Returns.......: none
*)Notes.........: Creates the application object and set a few properties.
*)              : It is all what is needed to begin the application.
* See also......: 
*
External procedure Source\DemoApp.prg

Set Path To Images, ;
 Source, Source\Forms, Source\Prgs, Source\Reports, ;
 DataTier, BizTier, UserTier, ;
 ..\Comun, ..\Comun\taListMover ADDITIVE 

Close Databases all
Clear 
Set Talk off	&& Shut-up!

if varType( _Screen.oApp ) = "O"
	_Screen.RemoveObject( "oApp" )
EndIf

_Screen.NewObject( "oApp", "DemoApp", "Source\DemoApp.prg",, ;
 "Tier Adapter Framework (Demo)", "2.2" )

Return
*----------------*

