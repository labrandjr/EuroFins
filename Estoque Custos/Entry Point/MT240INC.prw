#include 'rwmake.ch'

/*/{Protheus.doc} MT240INC
Ponto de entrada na rotina de movimentos internos (Mod 1)
apos a confirmacao e gravacao de todos os dados.
Sera avaliado se o saldo em estoque (ja atualizado) atende a
condicao de ter atingido o estoque se seguranca.
Os usuarios cadastrados para receberem o aviso, receberao um e-mail.
@author Marcos Candido
@since 02/01/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MT240INC

Local nSaldoSB2 := 0
Local aInfo    := {}
Local cEvento  := ""

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+SD3->D3_COD)

	//³ Ponto de Pedido                        ³
	If SB1->B1_EMIN > 0

		cEvento := "Z02"
		aInfo   := {}
		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)

			nSaldoSB2 := CalcEst(SD3->D3_COD, SD3->D3_LOCAL, dDataBase+1)[1]

			If nSaldoSB2 <= SB1->B1_EMIN
				//³ Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do ponto de pedido.       ³
				aadd(aInfo , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
						Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazém "+SB2->B2_LOCAL+", o que significa que é menor ou igual ao ponto de pedido, que é de "+;
						Transform(SB1->B1_EMIN,"@E 999,999,999.9999")+" "+SB1->B1_UM+".")
				aadd(aInfo , " ")
				aadd(aInfo , "Favor verificar. ")

				If MExistMail(cEvento)
					MEnviaMail(cEvento,aInfo)
				Endif
			EndIf

		Endif

	Endif

	//³ Estoque de seguranca (estoque minimo)  ³
	If SB1->B1_ESTSEG > 0

		cEvento := "Z04"
		aInfo   := {}
		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)

			nSaldoSB2 := CalcEst(SD3->D3_COD, SD3->D3_LOCAL, dDataBase+1)[1]

			If nSaldoSB2 <= SB1->B1_ESTSEG
				//³ Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do estoque de seguranca.  ³
				aadd(aInfo , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
						Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazém "+SB2->B2_LOCAL+", o que significa que é menor ou igual ao estoque mínimo, que é de "+;
						Transform(SB1->B1_ESTSEG,"@E 999,999,999.9999")+" "+SB1->B1_UM+".")
				aadd(aInfo , " ")
				aadd(aInfo , "Favor verificar. ")

				If MExistMail(cEvento)
					MEnviaMail(cEvento,aInfo)
				Endif
			EndIf

		Endif

	Endif

	//³ Estoque Maximo                         ³
	If SB1->B1_EMAX > 0

		cEvento := "Z16"
		aInfo   := {}
		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)

			nSaldoSB2 := CalcEst(SD3->D3_COD, SD3->D3_LOCAL, dDataBase+1)[1]

			If nSaldoSB2 >= SB1->B1_EMAX
				//³ Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do estoque maximo.        ³
				aadd(aInfo , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
						Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazém "+SB2->B2_LOCAL+", o que significa que é maior ou igual ao estoque máximo, que é de "+;
						Transform(SB1->B1_EMAX,"@E 999,999,999.9999")+" "+SB1->B1_UM+".")
				aadd(aInfo , " ")
				aadd(aInfo , "Favor verificar. ")

				If MExistMail(cEvento)
					MEnviaMail(cEvento,aInfo)
				Endif
			EndIf

		Endif

	Endif

Return
