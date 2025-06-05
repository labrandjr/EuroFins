#include 'totvs.ch'


/*/{Protheus.doc} MT103SEL
Efetua valida��es espec�ficas em item selecionado
@type function
@version 12.1.33
@author Leandro Cesar
@since 11/07/2022
@return numeric, retorna se carrega ou n�o o item para o documento de entrada
/*/
User Function MT103SEL()

	Local nRecno := PARAMIXB[1]
	Local aArea  := GetArea()
	Local nRet   := 1
	local lCConduta := GetMv("CL_CCONDUT",.F.,.F.)

	dbSelectArea('SC7')
	dbGoto(nRecno)

	If lCConduta .and. !alltrim(cEspecie) $ GetMv("CL_ESPNVCC",.F.,"")
		If FUNNAME() != "MATA140"
			If dDEmissao < SC7->C7_EMISSAO
				FWAlertWarning("Para pedidos de compra emitidos posterior a data de emiss�o da nota fiscal deve ser gerado atrav�s da rotina de pr�-nota.",;
					"Codigo de Conduta")
				nRet := 0
			EndIf
		else
			If dDEmissao < SC7->C7_EMISSAO
				If !FWAlertYesNo("Pedido de compra selecionado [" + SC7->C7_NUM + " - " + SC7->C7_ITEM +"] emitido posterior a data de emiss�o "+;
						"da nota fiscal. Deseja Continuar?","Valida��o Codigo de Conduta")
					nRet := 0
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return(nRet)
