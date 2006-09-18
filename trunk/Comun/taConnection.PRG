*------------------------------------------------------------------*
* Author........: Ruben Rovira
* Date..........: 04/Oct/2005
* Parameters....: -
* Returns.......: -
* Notes.........: Represents a connection to be passed between tiers.
*               : 
* See also......: DataTierAdapter.prg and BusinessTierAdapter.prg
*
Define Class taConnection AS Session 

cType          = "NATIVE"
nDataSessionID = 0
oADOConnection = Null

EndDefine 
