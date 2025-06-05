#include 'totvs.ch'

/*/{Protheus.doc} MT103LEG
Ponto de entrada para inclusão de novo STATUS da legenda
@type function
@version 12.1.27
@author Leandro Cesar
@since 26/08/2022
@return array, legenda
/*/
User Function MT103LEG()
	Local aXLegenda := aClone(PARAMIXB[1])

	aAdd(aXLegenda,{"BR_CANCEL","Docto. Rejeitado e Bloqueado (Cod. Conduta)"})

Return( aXLegenda )
