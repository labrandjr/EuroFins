#include 'rwmake.ch'

/*

±±ºPrograma  ³ MT241GRV ºAutor  ³ Marcos Candido     º Data ³  29/10/15   º±±
±±ºDesc.     ³ Ponto de entrada na rotina de Movimentos Internos - mod2.  º±±
±±º          ³ Executado no momento da gravacao dos dados.                º±±
±±º          ³ Sera avaliado se o saldo em estoque (ja atualizado)        º±±
±±º          ³ atingiu o estoque se seguranca. Se sim, os usuarios        º±±
±±º          ³ cadastrados receberao um aviso por e-mail.                 º±±
±±º Marcos   ³ Inserida condicao que verifica se o item atingiu o estoque º±±
±±º Candido  ³ maximo (somente para a empresa Anatech).                   º±±
*/
/*/{Protheus.doc} MT241GRV
Na gravacao dos movimento interno mod.2.  Envia Email ao atingir estoque de segurança.
@author Marcos Candido
@since 02/01/2018
/*/
User Function MT241GRV

Local nSaldoSB2 := 0
Local aInfo     := {} , aEnviar := {}
Local nI        := 0
Local cProd     := ""
Local cArmaz    := ""
Local cEvento   := ""
Local nSeq      := 0

//If SM0->M0_CODIGO == '01'

	For nI:=1 To Len(aCols)

		cProd   := GdFieldGet("D3_COD",nI)
		cArmaz  := GdFieldGet("D3_LOCAL",nI)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona SB1 e SB2                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+cProd)
		aInfo   := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Pedido                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SB1->B1_EMIN > 0

			cEvento := "Z02"
			//?aInfo   := {}

			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+cProd+cArmaz)

				//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
				nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

				If nSaldoSB2 <= SB1->B1_EMIN
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do ponto de pedido.       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
							Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazem "+SB2->B2_LOCAL+", o que significa que e menor ou igual ao ponto de pedido, que e de "+;
							Transform(SB1->B1_EMIN,"@E 999,999,999.9999")+" "+SB1->B1_UM+"."})
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , " "})
				EndIf

			EndIf

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estoque de seguranca (estoque minimo)  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SB1->B1_ESTSEG > 0

			cEvento := "Z04"
			//aInfo   := {}

			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+cProd+cArmaz)

				//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
				nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

				If nSaldoSB2 <= SB1->B1_ESTSEG
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do estoque de seguranca.  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
							Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazém "+SB2->B2_LOCAL+", o que significa que é menor ou igual ao estoque mínimo, que é de "+;
							Transform(SB1->B1_ESTSEG,"@E 999,999,999.9999")+" "+SB1->B1_UM+"."})
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , " "})
				EndIf

			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estoque Maximo                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SB1->B1_EMAX > 0

			cEvento := "Z16"
			//aInfo   := {}

			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+cProd+cArmaz)

				//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
				nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

				If nSaldoSB2 >= SB1->B1_EMAX
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do estoque maximo.        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSeq++
					/*aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
							Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazem "+SB2->B2_LOCAL+", o que significa que e maior ou igual ao estoque máximo, que e de "+;
							Transform(SB1->B1_EMAX,"@E 999,999,999.9999")+" "+SB1->B1_UM+"."})*/
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" atingiu a quantidade de "+;
						Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazém "+SB2->B2_LOCAL+", sendo que o produto tem como ponto de pedido: "+;
						Transform(SB1->B1_ESTSEG,"@E 999,999,999.9999")+" "+SB1->B1_UM+"."})
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , " "})
				EndIf

			Endif

		Endif

	Next nI

/*
ElseIf SM0->M0_CODIGO == '05'

	For nI:=1 To Len(aCols)

		cProd   := GdFieldGet("D3_COD",nI)
		cArmaz  := GdFieldGet("D3_LOCAL",nI)
		cEvento := "Z07"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona SB1 e SB2                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+cProd)

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+cProd+cArmaz) .and. SB2->B2_X_PPEDI > 0

			//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
			nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

			If nSaldoSB2 <= SB2->B2_X_PPEDI
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do ponto de pedido.       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nSeq++
				aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
				           Transform(nSaldoSB2,"@E 999,999.9999")+" "+SB1->B1_UM+" no armazém "+SB2->B2_LOCAL+", o que significa que é menor ou igual a seu ponto de pedido, que é de "+;
				           Transform(SB2->B2_X_PPEDI,"@E 999,999.9999")+" "+SB1->B1_UM+"."})
				nSeq++
				aadd(aInfo , {cEvento , StrZero(nSeq,4) , " "})
			EndIf

		Endif

	Next nI

Endif
*/

If Len(aInfo) > 0
	aSort(aInfo,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
	cEvAnt := ""
	For nI:=1 to Len(aInfo)
		If Empty(cEvAnt)
			cEvAnt := aInfo[nI][1]
		Endif
		If aInfo[nI][1] <> cEvAnt
			aadd(aEnviar , "Favor verificar. ")
			If MExistMail(cEvAnt)
				MEnviaMail(cEvAnt,aEnviar)
			Endif
			cEvAnt  := aInfo[nI][1]
			aEnviar := {}
		Endif
		aadd(aEnviar , aInfo[nI][3])
	Next nI
	If Len(aEnviar) > 0
		aadd(aEnviar , "Favor verificar. ")
		If MExistMail(cEvAnt)
			MEnviaMail(cEvAnt,aEnviar)
		Endif
	Endif
Endif

/*
If SM0->M0_CODIGO == '05'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se algum produto atingiu o estoque maximo.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aInfo   := {}
	cEvento := "Z16"
	For nI:=1 To Len(aCols)

		cProd   := GdFieldGet("D3_COD",nI)
		cArmaz  := GdFieldGet("D3_LOCAL",nI)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona SB1 e SB2                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+cProd)

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+cProd+cArmaz) .and. SB2->B2_X_EMAX > 0

			//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
			nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

			If nSaldoSB2 >= SB2->B2_X_EMAX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia e-mail aos usuarios cadastrados de que o saldo do produto ficou igual ou maior que o estoque maximo.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aInfo , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
				           Transform(nSaldoSB2,"@E 999,999.9999")+" "+SB1->B1_UM+" no armazém "+SB2->B2_LOCAL+", o que significa que é maior ou igual a seu estoque máximo, que é de "+;
				           Transform(SB2->B2_X_EMAX,"@E 999,999.9999")+" "+SB1->B1_UM+".")
				aadd(aInfo , " ")
			Endif

		Endif

	Next

	If Len(aInfo) > 0
		aadd(aInfo , "Favor verificar. ")
		If MExistMail(cEvento)
			MEnviaMail(cEvento,aInfo)
		Endif
	Endif

Endif
*/
Return

/*
Contexto anterior. Substituido em 14/10/16 - Por Marcos Candido

Local nSaldoSB2 := 0
Local aInfo     := {} , aEnviar := {}
Local nI        := 0
Local cProd     := ""
Local cArmaz    := ""
Local cEvento   := ""
Local nSeq      := 0

For nI:=1 To Len(aCols)

	cProd   := GdFieldGet("D3_COD",nI)
	cArmaz  := GdFieldGet("D3_LOCAL",nI)
	cEvento := ""

	If SM0->M0_CODIGO == '01'
		If cArmaz == '01'
			cEvento := 'Z02'
		ElseIf cArmaz $ '02/03'
			cEvento := 'Z04'
		ElseIf cArmaz == '05'
			cEvento := 'Z07'
		Endif
	Else
		cEvento := "Z07"
	Endif

	If !Empty(cEvento)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona SB1 e SB2                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+cProd)

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+cProd+cArmaz) .and. SB2->B2_X_PPEDI > 0

			nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)

			If nSaldoSB2 <= SB2->B2_X_PPEDI
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do ponto de pedido.       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nSeq++
				aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
				           Transform(nSaldoSB2,"@E 999,999.9999")+" "+SB1->B1_UM+" no armazém "+SB2->B2_LOCAL+", o que significa que é menor ou igual a seu ponto de pedido, que é de "+;
				           Transform(SB2->B2_X_PPEDI,"@E 999,999.9999")+" "+SB1->B1_UM+"."})
				nSeq++
				aadd(aInfo , {cEvento , StrZero(nSeq,4) , " "})
			EndIf

		Endif

	Endif

Next nI

If Len(aInfo) > 0
	aSort(aInfo,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
	cEvAnt := ""
	For nI:=1 to Len(aInfo)
		If Empty(cEvAnt)
			cEvAnt := aInfo[nI][1]
		Endif
		If aInfo[nI][1] <> cEvAnt
			aadd(aEnviar , "Favor verificar. ")
			MEnviaMail(cEvAnt,aEnviar)
			cEvAnt  := aInfo[nI][1]
			aEnviar := {}
		Endif
		aadd(aEnviar , aInfo[nI][3])
	Next nI
	If Len(aEnviar) > 0
		aadd(aEnviar , "Favor verificar. ")
		MEnviaMail(cEvAnt,aEnviar)
	Endif
Endif
*/
