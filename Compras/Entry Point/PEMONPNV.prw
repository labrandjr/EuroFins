#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} PEMONPNV
    Ponto de entrada para valida��o da sele��o do pedido de compra - NF-e
 @type function
 @version 1.0
 @author Marcos Bortoluci
 @since 28/07/2022
 @param cTpDoc, character, Tipo do documento fiscal (NF-e, CT-e ou NFS-e)
 @param cPedido, character, N�mero do pedido selecionado
 @param cItemPC, character, Item do pedido selecionado
 @param nRestSldPC, numeric, Saldo restante do pedido selecionado
 @return logical, .T. = Se pedido v�lido, .F., se pedido inv�lido
/*/
user function PEMONPNV(cTpDoc, cPedido, cItemPC, nRestSldPC)
	local lRet		:= .T. as logical
	local lCConduta := GetMv("CL_CCONDUT",.F.,.F.)
	local dDataEmis	:= iif(cTpDoc = "NFSe", FwFldGet("DATA_EMISSAO"), cTod(cDate))

	If lCConduta
		If SC7->(dbSetOrder(1), dbSeek(FWxFilial("SC7") + cPedido + cItemPC))
			If SC7->C7_EMISSAO > dDataEmis
				If !FWAlertYesNo("Pedido de compra selecionado [" + alltrim(cPedido) + " - " + (cItemPC) +"] emitido posterior a data de emiss�o " + ;
						"da nota fiscal. Deseja Continuar?","Valida��o Codigo de Conduta")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

return(lRet)
