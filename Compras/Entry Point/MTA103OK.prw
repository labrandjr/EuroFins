#include 'protheus.ch'

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} MTA103OK
Ponto de entrada na validacao dos itens da nota de entrada.
Estou verificando se o item esta presente em um pedido de
compra, e se a quantidade digitada superou o que foi
colocado no pedido, sem sim o item nao sera aceito, bem
como o valor unitario; se o valor superar a tolerancia de
0,01%, o usuario sera avisado e o item nao sera aceito.
@author Marcos Candido
@since 29/12/2017
/*/
User Function MTA103OK

	Local aArea    := GetArea()
	Local aAreaSC7 := SC7->(GetArea())
	Local lRet     := .T.
	Local nX       := 0
	Local nPosPc   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
	Local nPosItPc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
	Local nPosQtd  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
	Local nPosVlr   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
	//Local nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
	//Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
	Local nPosRat  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_RATEIO"})
	Local nPosCC   := GdFieldPos("D1_CC")
	Local nUsado   := Len(aHeader)
	Local nQuJE    := 0
	Local nQtde    := 0
	Local nPrcPC   := 0

	For nX :=1 To Len(aCols)
		If !aCols[nx][nUsado+1]
			If !Empty(aCols[nx][nPosPc])
				DbSelectArea("SC7")
				DbSetOrder(14)
				If MsSeek(xFilEnt(xFilial("SC7"))+aCols[nx][nPosPc]+aCols[nx][nPosItPc])
					nQuJE  := SC7->C7_QUJE
					nQtde  := SC7->C7_QUANT
					nPrcPC := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,SC7->C7_DATPRF,5,SC7->C7_TXMOEDA)

					If aCols[nx][nPosQtd] > (nQtde-nQuJE)
						IW_MsgBox("A quantidade digitada no item "+StrZero(nX,4)+" é maior que a saldo da quantidade a receber no pedido de compra."+ENTER+ENTER+"Verifique.","Divergência","STOP")
						lRet := .F.
					Endif

					//Validação retirada a pedido da Joelma Bergamo em 10/02/2023 - retornado em 21/12/2023 a pedido da Camila Nascimento
					If lRet .and. SC7->C7_MOEDA == 1 .and. aCols[nx][nPosVlr] > (nPrcPC * 1.001)
						IW_MsgBox("O valor unitário do item "+StrZero(nX,4)+" ultrapassa a tolerância permitida."+ENTER+ENTER+"Verifique.","Divergência","STOP")
					 	lRet := .F.
					Endif
				Endif
			Endif
			// If Empty(aCols[nX,nPosCC]).and. Alltrim(Upper(cSerie)) == 'ND'
			// 	MsgStop("Para a Serie 'ND' é obrigatório informar o Centro de Custo.","Centro de Custo vazio no Item "+cValTochar(nX)+"!")
			// 	lRet := .F.
			// 	Exit
			// EndIf

			//SECTION - Validação Centro Custo - ND
			// NOTE alterado por Leandro Cesar em 17/03/2022
			If Alltrim(Upper(cSerie)) == 'ND'
				If Empty(aCols[nX,nPosCC]) .and. aCols[nX,nPosRat] != '1'
					MsgStop("Para a Serie 'ND' é obrigatório informar o Centro de Custo.","Centro de Custo vazio no Item "+cValTochar(nX)+"!")
					lRet := .F.
					Exit
				EndIf
			EndIf
			//!SECTION

		Endif
	Next nX

	RestArea(aAreaSC7)
	RestArea(aArea)

Return lRet
