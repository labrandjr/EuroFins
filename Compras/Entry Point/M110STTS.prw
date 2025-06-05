#include 'totvs.ch'
/*/{Protheus.doc} M110STTS
Ponto de Entrada ao incluir/alterar uma SC chamar o fonte ENVHTML para envio de WF de compras
@author Sergio Braz
@since 24/04/2019
/*/
User Function M110STTS
	Local aDados     := PARAMIXB
	Local aAreaAtual := GetArea()
	Local cNum 		 := SC1->C1_NUM
	Local cTipo  	 := "SC"
	Local cRotina    := AllTrim(FunName())
	U_ENVHTML(cTIPO, cNum, aDados, cRotina)
	RestArea(aAreaAtual)
Return