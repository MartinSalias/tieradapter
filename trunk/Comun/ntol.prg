*------------------------------------------------------------------*
* Funcion.......: NtoL
* Devuelve......: string con descripcion en letras
* Autor.........: MARTIN
* Fecha.........: December '90
* Version.......: 1.0
* Parametros....: tnValue
*)Notas.........: Convierte una expresión numérica a una string con su 
*)              : descripción en letras.
*
parameter tnValue

if tnValue >= 1000000000000
	
	return " *** demasiado grande *** "
endif

local laTrio[5], laParte[5], laNN[3]

local laUnits[15], laDec1[10], laDec2[10], laCien[10]

laUnits( 1)	= "UN"
laUnits( 2)	= "DOS"
laUnits( 3)	= "TRES"
laUnits( 4)	= "CUATRO"
laUnits( 5)	= "CINCO"
laUnits( 6)	= "SEIS"
laUnits( 7)	= "SIETE"
laUnits( 8)	= "OCHO"
laUnits( 9)	= "NUEVE"
laUnits(10)	= "DIEZ"
laUnits(11)	= "ONCE"
laUnits(12)	= "DOCE"
laUnits(13)	= "TRECE"
laUnits(14)	= "CATORCE"
laUnits(15)	= "QUINCE"
laDec1( 2)	= "VEINTE"
laDec1( 3)	= "TREINTA"
laDec1( 4)	= "CUARENTA"
laDec1( 5)	= "CINCUENTA"
laDec1( 6)	= "SESENTA"
laDec1( 7)	= "SETENTA"
laDec1( 8)	= "OCHENTA"
laDec1( 9)	= "NOVENTA"
laDec2( 1)	= "DIECI"
laDec2( 2)	= "VEINTI"
laDec2( 3)	= "TREINTA Y "
laDec2( 4)	= "CUARENTA Y "
laDec2( 5)	= "CINCUENTA Y "
laDec2( 6)	= "SESENTA Y "
laDec2( 7)	= "SETENTA Y "
laDec2( 8)	= "OCHENTA Y "
laDec2( 9)	= "NOVENTA Y "
laCien( 1)	= "CIENTO "
laCien( 2)	= "DOSCIENTOS "
laCien( 3)	= "TRESCIENTOS "
laCien( 4)	= "CUATROCIENTOS "
laCien( 5)	= "QUINIENTOS "
laCien( 6)	= "SEISCIENTOS "
laCien( 7)	= "SETECIENTOS "
laCien( 8)	= "OCHOCIENTOS "
laCien( 9)	= "NOVECIENTOS "

letras = ""

laTrio(1) = int(  tnValue/1000000000)
laTrio(2) = int( (tnValue-(laTrio(1)*1000000000)) /1000000)
laTrio(3) = int( (tnValue-(laTrio(1)*1000000000)-(laTrio(2)*1000000)) / 1000 )
laTrio(4) = int(  tnValue-(laTrio(1)*1000000000)-(laTrio(2)*1000000)-(laTrio(3)*1000))
laTrio(5) = int( (tnValue-(laTrio(1)*1000000000)-(laTrio(2)*1000000)-(laTrio(3)*1000)-(laTrio(4))) *100)
conta = 1

do while conta <= 5
	
	laParte(conta) = ""
	if laTrio(conta)>0
		laNN(1) = int( laTrio(conta) / 100 )
		laNN(2) = int( (laTrio(conta) - (laNN(1)*100)) /10 )
		laNN(3) = laTrio(conta) - (laNN(1)*100) - (laNN(2)*10)
		DO CASE
		CASE laTrio(conta) = 100
			laParte(conta) = "CIEN"
		OTHERWISE
			if laNN(1)>0
				laParte(conta) = laCien(laNN(1))+laParte(conta)
			endif
			if (laNN(2) = 0 and laNN(3)<>0) or (laNN(2) = 1 and laNN(3)<6)
				laParte(conta) = laParte(conta)+laUnits(laNN(2)*10 + laNN(3))
			else
				if laNN(2)>0
					if laNN(3) = 0
						laParte(conta) = laParte(conta)+laDec1(laNN(2))
					else
						laParte(conta) = laParte(conta)+laDec2(laNN(2))
					endif
				endif
				if laNN(3)>0
					laParte(conta) = laParte(conta)+laUnits(laNN(3))
				endif
			endif
			if laNN(3) = 1 and laNN(2)<>1 and conta = 4
				laParte(conta) = laParte(conta) +"O"
			endif
		ENDCASE
		
		DO CASE
		CASE conta = 1
			laParte(conta) = laParte(conta) + " MIL "
		CASE conta = 2
			if laTrio(conta) = 1 and laTrio(1) = 0
				laParte(conta) = laParte(conta) + " MILLON "
			else
				laParte(conta) = laParte(conta) + " MILLONES "
			endif
		CASE conta = 3
			laParte(conta) = laParte(conta) + " MIL "
		CASE conta = 5
			if laTrio(1) + laTrio(2) + laTrio(3) + laTrio(4) = 0
				laParte(conta) = laParte(conta) + " CENTAVOS"
			else
				laParte(conta) = " CON " + laParte(conta) + " CENTAVOS"
			endif
		ENDCASE
	endif
	conta = conta + 1
enddo

letras = laParte(1) + laParte(2) + laParte(3) + laParte(4) + laParte(5) + ".-"
return letras
