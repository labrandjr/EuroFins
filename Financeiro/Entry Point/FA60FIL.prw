#INCLUDE "rwmake.ch"

/*/{Protheus.doc} FA60FIL
Na rotina de montagem do bordero de cobranca. Verificado se A1_ZZTPCOB= "D" o registro sera desprezado.
@author Marcos Candido
@since 03/01/2018
/*/
User Function FA60FIL

	Local cFilter := ""

	dbSelectArea("SE1")
	cFilter := dbFilter()

	cFilter += If( Empty( cFilter ),""," .AND. " )
	cFilter += 'Posicione("SA1",1,xFILIAL("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_ZZTPCOB")<>"D"'

Return(cFilter)