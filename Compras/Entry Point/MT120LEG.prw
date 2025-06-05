#include 'rwmake.ch'

/*/{Protheus.doc} MT120LEG
Na rotina de Pedido de Compra, define mais legendas em conjunto com MT120COR.
@author Marcos Candido
@since 23/09/2013
/*/
User Function MT120LEG

	Local aMaisLeg := PARAMIXB[1]
	Local nLoc := aScan(aMaisLeg , {|x| x[1]='ENABLE'})

	aMaisLeg[nLoc][2] := 'Pendente mas com e-mail enviado'

	aAdd(aMaisLeg , {"BR_PINK" , "E-mail não enviado"})

Return aMaisLeg