#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT100LOK
Na validacao da linha digitada na tela do Documento de entrada (mata103).  Validar a existencia da conta contabil e do centro de custo (quando este for obrigatorio).
@author Unknown
@since 29/12/2017
/*/
User Function MT100LOK()

	Local aArea    := GetArea()
	Local lRet     := .T.
	Local lDel     := aCols[n][Len(aHeader)+1]
	Local nPosicao := 0 , cCC := "" , cTES := "" , cConta := ""
	Local cArmaz   := "" , cCodFor := ""
	Local nBsISS   := nVlISS := nAlISS := 0

	Local aAreaSD1 := SD1->(GetArea())
	Local aAreaSF4 := SF4->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())
	Local aAreaSC7 := SC7->(GetArea())

	Local nPosTES  := GDFieldPos("D1_TES")
	Local nPosCC   := GDFieldPos("D1_CC")
	Local nPosRat  := GDFieldPos("D1_RATEIO")
	Local nPosITC  := GDFieldPos("D1_ITEMCTA")
	Local nPosProd := GDFieldPos("D1_COD")
	Local nPosOP   := GDFieldPos("D1_OP")
	Local lDel     := (aCols[ n , Len(aCols[n]) ])
	Local nPosST   := GDFieldPos("D1_CLASFIS")

	Local _cPed    := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_PEDIDO"})
	Local _cITPed  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_ITEMPC"})
	Local _cTipo   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_TIPO"})
	Local _cCod    := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_COD"})
	Local _nQtde   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_QUANT"})
	Local _cCFOP   := Alltrim(gdFieldGet("D1_CF"))
	Local cQuery   := ""


	If nPosCC <> 0 .AND. nPosTES <> 0 .AND. nPosRat <> 0 .AND. !lDel .AND. M->cTipo != "D" .AND. lRet
		cQuery := "SELECT F4_DUPLIC, F4_ESTOQUE , F4_ZZTM FROM "+ RetSQLName("SF4") +" WHERE"
		cQuery += " F4_FILIAL ='"+ xFILIAL("SF4") +"' AND F4_CODIGO ='"+ aCols[ n , nPosTES ] +"'"
		cQuery += " AND D_E_L_E_T_ = ' '"
		TcQuery cQuery Alias TSF4 New
		TSF4->(dbGoTop())

		If  Len(Alltrim(CNFiscal)) < 9 .AND. Alltrim(cFormul) =="N" .AND. lRet
			Alert("Aten��o!!! Numero de Documento menor que 9 caracteres")
			lRet := .F.
		Endif

		// Verifica se a situa��o tribut�ria foi montada corretamente.
		If  Len(Alltrim(aCols[ n , nPosST ]))<3 .AND. lRet
			Alert("Aten��o!!! Classifica��o fiscal inv�lida, verifique os cadastro TES e PRODUTO.")
			lRet := .F.
		Endif

		//Verifica a esp�cie de documento para TM 04 - Servi�os de Transporte
		If TSF4->F4_ZZTM == "04" .AND. lRet .AND. !AllTrim(CESPECIE) $ "CA/CTA/CTE/CTF/CTR/NFST"
			Alert("Aten��o!!! Esp�cie de Documento deve estar dentro os tipos 'CA/CTA/CTE/CTF/CTR/NFST'")
			lRet := .F.
		Endif

		//Verifica a esp�cie de documento para TM 07 - Presta��o de Servi�os
		If AllTrim(TSF4->F4_ZZTM) == "07" .AND. lRet .AND. !AllTrim(CESPECIE) $ "NFPS/NFS/RPS" .AND. !_cCFOP $ "1933/2933"
	 		Alert("Aten��o!!! Esp�cie de Documento deve estar dentro os tipos 'NFPS/NFS/RPS'")
	 		lRet := .F.
		Endif

		//Verifica a esp�cie de documento para TM 02 - Energia El�trica
		If TSF4->F4_ZZTM == "02" .AND. lRet .AND. !AllTrim(CESPECIE) $ "NFCEE"
			Alert("Aten��o!!! Esp�cie de Documento deve estar dentro os tipos 'NFCEE'")
			lRet := .F.
		Endif

		//Verifica a esp�cie de documento para TM 03 - Servi�os de Comunica��o
		If AllTrim(TSF4->F4_ZZTM) == "03" .AND. lRet .AND. !AllTrim(CESPECIE) $ "NFSC/NTSC/NTST"
			Alert("Aten��o!!! Esp�cie de Documento deve estar dentro os tipos 'NFSC/NTSC/NTST'")
			lRet := .F.
		Endif

		If  Empty(CESPECIE)
			Alert("Aten��o!!! Esp�cie do Documento deve ser preenchida")
			lRet := .F.
		Endif

		If nPosProd <> 0.AND. lRet
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+aCols[ n , nPosProd ])
			If Found() .AND. ! SB1->B1_TIPO $ GETMV("MV_ZZTPEST") .AND. TSF4->F4_ESTOQUE == "S"
				Alert("Aten��o!!! O tipo do produto n�o controla estoque. Verifique a TES utilizada.")
				lRet := .F.
			//Retirado a valida��o a Pedido da Rosiani, ela ir� analisar melhor
			//elseIf Found() .AND. SB1->B1_TIPO $ GETMV("MV_ZZTPEST") .AND. TSF4->F4_ESTOQUE == "N"
				//Alert("Aten��o!!! O tipo do produto deve controlar estoque. Verifique a TES utilizada.")
				//lRet := .F.
			Elseif  Found() .AND. ! SB1->B1_TIPO $ GETMV("MV_ZZTPEST") .AND. EMPTY(gdFieldGet("D1_CC")) .AND. gdFieldGet("D1_RATEIO") <>  "1" .and. cTipo <> "B" .and. Substr(gdFieldGet("D1_CONTA"),1,5) <> Alltrim(GETMV("MV_ZZNFRCC"))
				Alert ("Aten��o!!! Preenchimento do Centro de Custo � obrigat�rio.")
				lRet := .F.
			Elseif  Found() .AND. SB1->B1_TIPO $ GETMV("MV_ZZTPEST") .AND. !EMPTY(gdFieldGet("D1_CC"))
				Alert ("Aten��o!!! Centro de Custo n�o deve ser informado.")
				lRet := .F.
			Elseif Found() .AND. SB1->B1_TIPO $ GETMV("MV_ZZTPEST") .AND. EMPTY(gdFieldGet("D1_CC")) .AND. gdFieldGet("D1_RATEIO") ==  "1"
				Alert ("Aten��o!!! Centro de Custo n�o deve ser informado na tabela de rateio.")
				lRet := .F.
			Endif
		Endif
		RestArea(aAreaSB1)

		TSF4->(dbCloseArea())

	Endif

	RestArea(aAreaSF4)
	RestArea(aAreaSD1)
	RestArea(aArea)

	if !lRet
		Return lRet
	endif

	If funname() == "MATA910"
		lRet:=.T.

	Elseif funname() == "MATA920"
		lRet:=.T.

	ElseIf !lDel
		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_TES"})
		If ( nPosicao > 0 )
			cTES := aCols[n,nPosicao]
		EndIf

		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_CONTA"})
		If ( nPosicao > 0 )
			cConta := aCols[n,nPosicao]
		EndIf

		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_CC"})
		If ( nPosicao > 0 )
			cCC := aCols[n,nPosicao]
		EndIf

		If !Empty(cTES)

			If !Empty(cConta)
				//If SM0->M0_CODIGO=='01' .and. SM0->M0_CODFIL=='01'
				//	If Substr(cConta,1,7)=='1010205' .and. Empty(cCC)
				//		IW_MsgBox(OemToAnsi("Centro de Custo Obrigat�rio !"),OemToAnsi("Aten��o"),"ALERT")
				//		lRet:=.F.
				//	ElseIf !(Substr(cConta,1,1) $ "12") .and. Empty(cCC)
				//		IW_MsgBox(OemToAnsi("Centro de Custo Obrigat�rio !"),OemToAnsi("Aten��o"),"ALERT")
				//		lRet:=.F.
				//	ElseIf Substr(cConta,1,7)<>'1010205' .and. Substr(cConta,1,1) $ "12" .and. !Empty(cCC)
				//		IW_MsgBox(OemToAnsi("O Centro de Custo n�o deve ser informado !"),OemToAnsi("Aten��o"),"ALERT")
				//		lRet:=.F.
				//	Else
				//		lRet:=.T.
				//	Endif
				//Else
				//	If !(Substr(cConta,1,1) $ "12") .and. Empty(cCC)
				//		IW_MsgBox(OemToAnsi("Centro de Custo Obrigat�rio !"),OemToAnsi("Aten��o"),"ALERT")
				//		lRet:=.F.
				//	ElseIf Substr(cConta,1,1) $ "12" .and. !Empty(cCC)
				//		IW_MsgBox(OemToAnsi("O Centro de Custo n�o deve ser informado !"),OemToAnsi("Aten��o"),"ALERT")
				//		lRet:=.F.
				//	Else
				//		lRet:=.T.
				//	Endif
				//Endif
			Else
				if gdFieldGet("D1_RATEIO") ==  "2"
					IW_MsgBox(OemToAnsi("Conta Cont�bil Obrigat�ria !"),OemToAnsi("Aten��o"),"ALERT")
					lRet:=.F.
				endif
			Endif

		Endif

		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_LOCAL"})
		If ( nPosicao > 0 )
			cArmaz := aCols[n,nPosicao]
		EndIf

		If lRet .and. Len(Alltrim(cArmaz)) < 2
			IW_MsgBox(OemToAnsi("O c�digo do armaz�m deve conter 2 d�gitos. Verifique."),OemToAnsi("Aten��o"),"ALERT")
			lRet:=.F.
		Endif

		If lRet .and. SM0->M0_CODIGO == '03' .and. cArmaz <> '01'
			IW_MsgBox(OemToAnsi("Para a Agroscience utilize o armaz�m '01'."),OemToAnsi("Aten��o"),"ALERT")
			lRet:=.F.
		Endif

		//Retirado a valida��o do campo conforme solicita��o da Joelma e Rodolfo
		//27/10/2020
		/*
		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_ZZCODF"})
		If ( nPosicao > 0 )
			cCodFor := aCols[n,nPosicao]
		EndIf

		If lRet .and. funname() <> "MATA119" .and. Empty(cCodFor)
			IW_MsgBox(OemToAnsi("Informe o C�digo do Produto no Fornecedor."),OemToAnsi("Aten��o"),"ALERT")
			lRet:=.F.
		Endif*/

		/*
		If Alltrim(cEspecie) == "NFS"
		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_BASEISS"})
		If ( nPosicao > 0 )
		nBsISS := aCols[n,nPosicao]
		EndIf

		If lRet .and. nBsISS == 0
		IW_MsgBox(OemToAnsi("Em notas de Servi�o, informe a Base do ISS."),OemToAnsi("Aten��o"),"ALERT")
		lRet:=.F.
		Endif

		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_VALISS"})
		If ( nPosicao > 0 )
		nVlISS := aCols[n,nPosicao]
		EndIf

		If lRet .and. nVlISS == 0
		IW_MsgBox(OemToAnsi("Em notas de Servi�o, informe o Valor do ISS."),OemToAnsi("Aten��o"),"ALERT")
		lRet:=.F.
		Endif

		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_ALIQISS"})
		If ( nPosicao > 0 )
		nAlISS := aCols[n,nPosicao]
		EndIf

		If lRet .and. nAlISS == 0
		IW_MsgBox(OemToAnsi("Em notas de Servi�o, informe a Al�quota do ISS."),OemToAnsi("Aten��o"),"ALERT")
		lRet:=.F.
		Endif

		If nBsISS > 0 .and. nVlISS > 0 .and. nAlISS > 0
		nPosicao := Ascan(aHeader,{|x| AllTrim(X[2]) == "D1_CODISS"})
		If Empty(aCols[n,nPosicao])
		aCols[n,nPosicao] := "1234"
		Endif
		Endif
		Endif
		*/
	Endif

	RestArea(aArea)

Return(lRet)
