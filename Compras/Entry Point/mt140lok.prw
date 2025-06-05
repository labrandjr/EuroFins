#include 'totvs.ch'
/*/{Protheus.doc} MT140LOK
Ponto de entrada na validacao dos itens da pré-nota de entrada.
Verifica se o item esta presente em um pedido de compra  e se a quantidade superou o que foi colocado no pedido bem como o valor unitario
@author Sergio Braz
@since 07/06/2019
/*/
User Function MT140LOK

	Local aArea     := GetArea()
	Local aAreaSC7  := SC7->(GetArea())
	Local lRet      := .T.
	Local cPedido   := GdFieldGet("D1_PEDIDO")
	Local cItemPC   := GdFieldGet("D1_ITEMPC")
	Local nQuant    := GdFieldGet("D1_QUANT")
	Local nValUnit  := GdFieldGet("D1_VUNIT")
	Local nUsado    := Len(aHeader)
	Local nQuJE		:= 0
	Local nQtde		:= 0
	Local nPrcPC	:= 0

	If !aCols[n,nUsado+1]
		If !Empty(cPedido)
			If Posicione("SC7",14,xFilEnt(xFilial("SC7"))+cPedido+cItemPC,"!Eof()")
				nQuJE  := SC7->C7_QUJE
				nQtde  := SC7->C7_QUANT
				nPrcPC := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,SC7->C7_DATPRF,5,SC7->C7_TXMOEDA)

				If nQuant > (nQtde-nQuJE)
					IW_MsgBox("A quantidade digitada no item "+StrZero(n,4)+" é maior que a saldo da quantidade a receber no pedido de compra."+CRLF+CRLF+"Verifique.","Divergência","STOP")
					lRet := .F.
				Endif

				//Validação retirada a pedido da Joelma Bergamo em 10/02/2023 - retornada a validacao a pedido da Camila
				If lRet .and. SC7->C7_MOEDA == 1 .and. nValUnit > (nPrcPC * 1.001)
					IW_MsgBox("O valor unitário do item "+StrZero(n,4)+" ultrapassa a tolerância permitida."+CRLF+CRLF+"Verifique.","Divergência","STOP")
					lRet := .F.
				Endif
			Endif
		Endif
	Endif

	RestArea(aAreaSC7)
	RestArea(aArea)

Return lRet
