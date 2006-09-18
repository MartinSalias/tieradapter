*-------------------------------------------
* Function...: Xmenu
* Author.....: MARTIN
* Date.......: 04/06/1997
* Notes......: Basado en una idea de Steve Zimmelman para FoxPro 2.x
* Parameters.: tcItems = String con los items separados por punto y coma
* ...........: tnBar   = Número de item seleccionado incialmente (default=1)
* Returns....: El número de item seleccionado
* See Also...: PROMPT() [Nativo de FoxPro]
* 
lparam tcItems, tnBar

push key clear

local cWActive, nItemCount, aItems, x, ;
 nRow, nCol, cTitle, nLastpos, cColor, aItems

private cPopMenu, lnSelect	&& Pasan al procedimiento interno GetChoice

if param() < 2
	tnBar = 1
endif

cWActive = wOnTop()
activate screen

* Parsea cad uno de los items
*
nItemCount = OCCURS( ';', tcItems ) + 1
dimen aItems[ m.nItemCount ]
nLastpos = 1

for m.x = 1 TO m.nItemCount
	
	if m.x < m.nItemCount
   		
		aItems[ m.x ] = subs( m.tcItems, m.nLastpos, ;
		 ( AT( ';', m.tcItems, m.x ) - 1 ) - m.nLastpos + 1 )
	else
		aItems[ m.x ] = subs( m.tcItems, m.nLastpos, ;
		 ( LEN( m.tcItems ) - m.nLastpos ) + 1 )
	endif
	if aItems[ m.x ] # "\-"
		
		
		* MARTIN, 27/04/1998: Se quitaron los espacios de margen al utilizar
		* la nueva clausula SHORCUT del define popup (VFP 5), que ya los agrega.
		* 
		* aItems[ m.x ] = space(6) + allt( aItems[ m.x ] ) + space(6)
		
		aItems[ m.x ] = allt( aItems[ m.x ] )
	endif
	
	m.nLastpos=AT( ';', m.tcItems, m.x ) + 1
next

* Calcula la posición en base al puntero del mouse
*
nRow = iif( mRow() + m.nItemCount < sRow(), mRow() - 1, sRow() - m.nItemCount )
nCol = iif( mCol() + 10 < sCol(), mCol() - 3, mCol() - 13 )

* Nombre único para el pop-up
*
m.cPopMenu = 'M' + SYS(3) + "_"

* MARTIN, 27/04/1998: Se actualizaó la sintáxis para utilizar la nueva clausula
* SHORTCUT de VFP 5.0
* 
* define popup ( cPopMenu ) ;
*  from nRow, nCol IN SCREEN ;
*  MARGIN RELATIVE SHADOW COLOR SCHEME 4

define popup ( cPopMenu ) shortcut relative from nRow, nCol

for m.x = 1 TO m.nItemCount
	
	define bar m.x OF ( cPopMenu ) prompt aItems[ m.x ]
next

m.cAns = ""
m.tnSelect = 0
clear type

on selection popup ( cPopMenu ) do GetChoice

activate popup ( cPopMenu ) bar tnBar

pop key
release popup ( cPopMenu )

if !empty( cWActive )
	
	* WALTER, 11/08/1999: No lo restauro porque se hay dos ventanas con 
	* el mismo nombre, siempre deja activa la primera y no es correcto.
	* Sin esto, queda igualmente activa la ventana correcta 
	* 	
	*activate window ( cWActive )
endif


RETURN iif( lastKey()=27, 0, m.tnSelect )


*--------------------
*
PROCEDURE GetChoice

m.tnSelect = bar()

deactivate popup ( cPopMenu )

RETURN
