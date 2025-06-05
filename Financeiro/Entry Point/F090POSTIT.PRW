#include 'totvs.ch'


/*/{Protheus.doc} F090POSTIT
Rotina para informar o campo de taxa de permanencia na tela de baixas do CP auto
@type function
@version 12.1.33
@author Leandro Cesar
@since 4/10/2023
/*/
user function F090POSTIT()
	local cAliasX := ParamIxb[1]
	local nPos    := aScan(oMark:oBrowse:acolumns,{|x| alltrim(x:cHeading) == "Taxa Perman."})
	local cTxPerm := "0"
	local nTxPerm := 0


	If oMark:oBrowse:ColPos == nPos
		oMark:oBrowse:acolumns[nPos]:ledit := .T.
		cTxPerm := strTran(cValToChar((cAliasX)->E2_VALJUR),".",",")
		cTxPerm := FwInputBox("Informe Taxa Permanencia", cTxPerm)

		while !FWIsNumeric(cTxPerm)
			FwAlertWarning("Favor informar um conteúdo númerico e utilize como separado de milhar a ( . ).","Conteudo Invalido")
			cTxPerm := FwInputBox("Informe Taxa Permanencia", cTxPerm)
		EndDo

		nTxPerm := Val(cTxPerm)
		reclock((cAliasX), .F.)
		(cAliasX)->E2_VALJUR := nTxPerm
		MsUnlock()

		aAreaTMP := GetArea()
		dbSelectArea("SE2")
		dbSetOrder(1)//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
		If dbSeek(FWxFilial("SE2") + (cAliasX)->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) )
			reclock("SE2",.F.)
			SE2->E2_JUROS := nTxPerm
			SE2->(MsUnlock())
		EndIf
		RestArea(aAreaTMP)

		oMark:oBrowse:Refresh()
	EndIf

return()
