#include 'totvs.ch'

/*/{Protheus.doc} M120vlpc
Ponto que permite validar o pedido de compras antes de ser carregado na Nota Fiscal
@type function
@version 12.1.33
@author Leandro Cesar
@since 11/07/2022
@return logical, Informa se o pedido deve ou não ser carregado para o documento de entrada
/*/
user function M120vlpc()
	local nX        := 0           as numeric
	local lBlqCDT   := .F.         as logical
	local aDadosPC  := PARAMIXB[1] as array
	local lMedicao  := PARAMIXB[2] as logical
	local lNFiscal  := PARAMIXB[3] as logical
	local lCConduta := GetMv("CL_CCONDUT",.F.,.F.)

	If lCConduta .and. !alltrim(cEspecie) $ GetMv("CL_ESPNVCC",.F.,"")
		If !lMedicao .and. lNFiscal
			For nX := 1 to len(aDadosPC)
				If aDadosPC[nX][1]
					If dDEmissao < cTod(aDadosPC[nX][4])
						FWAlertWarning("Para pedidos de compra emitidos posterior a data de emissão da nota fiscal deve ser gerado através da rotina de pré-nota.",;
							"Codigo de Conduta")
						lBlqCDT := .T.
					EndIf
				EndIf
			Next nX
		ElseIf !lMedicao .and. !lNFiscal
			For nX := 1 to len(aDadosPC)
				If aDadosPC[nX][1]
					If dDEmissao < cTod(aDadosPC[nX][4])
						If !FWAlertYesNo("Pedido de compra selecionado [" + aDadosPC[nX][3] + " - " + aDadosPC[nX][2] +"] emitido posterior a data de emissão " + ;
								"da nota fiscal. Deseja Continuar?","Validação Codigo de Conduta")
							lBlqCDT := .T.
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

return(!lBlqCDT)
