*------------------------------------------------------------------*
* Author........: Rubén Rovira
* Date..........: 07/13/2003
* Notes.........: Subclass XMLAdapter Base Class
*
Define Class rrXMLAdapter As XMLAdapter

cSchemaLocation = ""
lFile = .F.
lIncludeBefore = .T.  && VFP disregards lIncludeBefore if the XMLAdapter IsDiffGram property is False (.F.). 
lChangesOnly = .T.    && VFP disregards lChangesOnly if the XMLAdapter IsDiffGram property is False (.F.). 
FormattedOutput = .F. && Display XML output as a single continuous string.
ForceCloseTag =  .F.  && Specifies whether to replace single empty element tags with a set of empty element open and close tags.

* Crea un DiffGram y lo devuelve.
Procedure GetDiffGram() As String

	Local lcRetVal As String
	lcRetVal = ""

	With This

		.ReleaseXML( .F. )
		.IsDiffgram = .T.

		* Es muy importante preservar los espacios en blanco para aplicar luego el
		* DiffGram, si no los cambios no son efectuados.
		.PreserveWhiteSpace = .T.

		.WrapMemoInCDATA = .T.

		.ToXML( "lcRetVal", .cSchemaLocation, .lFile, .lIncludeBefore, .lChangesOnly )

	EndWith 

	Return lcRetVal

EndProc 

EndDefine 