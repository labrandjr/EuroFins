#include 'rwmake.ch'

/*

���Programa  � MT241GRV �Autor  � Marcos Candido     � Data �  29/10/15   ���
���Desc.     � Ponto de entrada na rotina de Movimentos Internos - mod2.  ���
���          � Executado no momento da gravacao dos dados.                ���
���          � Sera avaliado se o saldo em estoque (ja atualizado)        ���
���          � atingiu o estoque se seguranca. Se sim, os usuarios        ���
���          � cadastrados receberao um aviso por e-mail.                 ���
��� Marcos   � Inserida condicao que verifica se o item atingiu o estoque ���
��� Candido  � maximo (somente para a empresa Anatech).                   ���
*/
/*/{Protheus.doc} MT241GRV
Na gravacao dos movimento interno mod.2.  Envia Email ao atingir estoque de seguran�a.
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

		//����������������������������������������Ŀ
		//� Posiciona SB1 e SB2                    �
		//������������������������������������������
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+cProd)
		aInfo   := {}

		//����������������������������������������Ŀ
		//� Ponto de Pedido                        �
		//������������������������������������������
		If SB1->B1_EMIN > 0

			cEvento := "Z02"
			//?aInfo   := {}

			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+cProd+cArmaz)

				//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
				nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

				If nSaldoSB2 <= SB1->B1_EMIN
					//�������������������������������������������������������������������������������������������������������Ŀ
					//� Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do ponto de pedido.       �
					//���������������������������������������������������������������������������������������������������������
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
							Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazem "+SB2->B2_LOCAL+", o que significa que e menor ou igual ao ponto de pedido, que e de "+;
							Transform(SB1->B1_EMIN,"@E 999,999,999.9999")+" "+SB1->B1_UM+"."})
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , " "})
				EndIf

			EndIf

		Endif

		//����������������������������������������Ŀ
		//� Estoque de seguranca (estoque minimo)  �
		//������������������������������������������
		If SB1->B1_ESTSEG > 0

			cEvento := "Z04"
			//aInfo   := {}

			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+cProd+cArmaz)

				//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
				nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

				If nSaldoSB2 <= SB1->B1_ESTSEG
					//�������������������������������������������������������������������������������������������������������Ŀ
					//� Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do estoque de seguranca.  �
					//���������������������������������������������������������������������������������������������������������
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
							Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armaz�m "+SB2->B2_LOCAL+", o que significa que � menor ou igual ao estoque m�nimo, que � de "+;
							Transform(SB1->B1_ESTSEG,"@E 999,999,999.9999")+" "+SB1->B1_UM+"."})
					nSeq++
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , " "})
				EndIf

			Endif

		Endif

		//����������������������������������������Ŀ
		//� Estoque Maximo                         �
		//������������������������������������������
		If SB1->B1_EMAX > 0

			cEvento := "Z16"
			//aInfo   := {}

			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+cProd+cArmaz)

				//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
				nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

				If nSaldoSB2 >= SB1->B1_EMAX
					//�������������������������������������������������������������������������������������������������������Ŀ
					//� Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do estoque maximo.        �
					//���������������������������������������������������������������������������������������������������������
					nSeq++
					/*aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
							Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armazem "+SB2->B2_LOCAL+", o que significa que e maior ou igual ao estoque m�ximo, que e de "+;
							Transform(SB1->B1_EMAX,"@E 999,999,999.9999")+" "+SB1->B1_UM+"."})*/
					aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" atingiu a quantidade de "+;
						Transform(nSaldoSB2,"@E 999,999,999.9999")+" "+SB1->B1_UM+" no armaz�m "+SB2->B2_LOCAL+", sendo que o produto tem como ponto de pedido: "+;
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

		//����������������������������������������Ŀ
		//� Posiciona SB1 e SB2                    �
		//������������������������������������������
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+cProd)

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+cProd+cArmaz) .and. SB2->B2_X_PPEDI > 0

			//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
			nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

			If nSaldoSB2 <= SB2->B2_X_PPEDI
				//�������������������������������������������������������������������������������������������������������Ŀ
				//� Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do ponto de pedido.       �
				//���������������������������������������������������������������������������������������������������������
				nSeq++
				aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
				           Transform(nSaldoSB2,"@E 999,999.9999")+" "+SB1->B1_UM+" no armaz�m "+SB2->B2_LOCAL+", o que significa que � menor ou igual a seu ponto de pedido, que � de "+;
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
	//�������������������������������������������������������Ŀ
	//� Verifica se algum produto atingiu o estoque maximo.   �
	//���������������������������������������������������������
	aInfo   := {}
	cEvento := "Z16"
	For nI:=1 To Len(aCols)

		cProd   := GdFieldGet("D3_COD",nI)
		cArmaz  := GdFieldGet("D3_LOCAL",nI)

		//����������������������������������������Ŀ
		//� Posiciona SB1 e SB2                    �
		//������������������������������������������
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+cProd)

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+cProd+cArmaz) .and. SB2->B2_X_EMAX > 0

			//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)
			nSaldoSB2 := CalcEst(cProd, cArmaz, dDataBase+1)[1]

			If nSaldoSB2 >= SB2->B2_X_EMAX
				//���������������������������������������������������������������������������������������������������������������Ŀ
				//� Envia e-mail aos usuarios cadastrados de que o saldo do produto ficou igual ou maior que o estoque maximo.    �
				//�����������������������������������������������������������������������������������������������������������������
				aadd(aInfo , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
				           Transform(nSaldoSB2,"@E 999,999.9999")+" "+SB1->B1_UM+" no armaz�m "+SB2->B2_LOCAL+", o que significa que � maior ou igual a seu estoque m�ximo, que � de "+;
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

		//����������������������������������������Ŀ
		//� Posiciona SB1 e SB2                    �
		//������������������������������������������
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+cProd)

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+cProd+cArmaz) .and. SB2->B2_X_PPEDI > 0

			nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)

			If nSaldoSB2 <= SB2->B2_X_PPEDI
				//�������������������������������������������������������������������������������������������������������Ŀ
				//� Envia e-mail aos usuarios cadastrados de que o produto atingiu a quantidade do ponto de pedido.       �
				//���������������������������������������������������������������������������������������������������������
				nSeq++
				aadd(aInfo , {cEvento , StrZero(nSeq,4) , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
				           Transform(nSaldoSB2,"@E 999,999.9999")+" "+SB1->B1_UM+" no armaz�m "+SB2->B2_LOCAL+", o que significa que � menor ou igual a seu ponto de pedido, que � de "+;
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
