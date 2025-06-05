#include 'rwmake.ch'
#include 'ap5mail.ch'
#include 'topconn.ch'
#include 'FWPrintSetup.ch'
#include 'protheus.ch'

#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030


/*/{Protheus.doc} PEDIDOC
emissão do pedido de compras
@author Marcos Candido
@since 29/12/2017
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpcx, numeric, descricao
/*/
User Function PEDIDOC(cAlias,nReg,nOpcx)

	//³Define Variaveis                                                        ³
	LOCAL wnrel        := "PEDIDOC"
	LOCAL cDesc1       := OemToAnsi("emissão dos Pedidos de Compras cadastrados.")
	LOCAL cDesc2       := " "
	LOCAL cDesc3       := " "
	LOCAL cString      := "SC7"
	Local lComp        := .T. // Ativado habilita escolher modo RETRATO / PAISAGEM
	Local cArquivo     := ""
	Local lContinua	   := .T.
	Local n			   := 1
	Local cCodUser     := Alltrim(RetCodUsr())
	Local lEnvia       := .T.
	Local _aEmail      := {}
	local X            := 0
	local nX           := 0
	PRIVATE lAuto      := Trim(Upper(FunName()))$"MATA121|MATA122|RPC|ENVPC|NEWENVPC|SCHEDENVPC"
	PRIVATE Tamanho    := "G"
	PRIVATE titulo     := OemToAnsi("emissão dos Pedidos de Compras")
	PRIVATE aReturn    :={"Zebrado", 1, "Administracao", 1, 2, 1, "", 0}
	PRIVATE nomeprog   := "PEDIDOC"
	PRIVATE nLastKey   := 0
	PRIVATE nBegin     := 0
	PRIVATE nDifColCC  := 0
	PRIVATE M_PAG      := 1
	Private cPerg      := padr("MTR110",10)
	Private lin        := 0 // Contador de Linhas
	Private lImp       := .F. // Indica se algo foi impresso
	Private oPrint
	Private cBitmap    := "\SYSTEM\LOGO"+Alltrim(SM0->M0_CODIGO)+Alltrim(SM0->M0_CODFIL)+".BMP"
	Private nPag       := 0
	Private nAltura    := 0
	Private aFiles     := {}
	Private cDiret     := "\IMAGEMPC\"
	Private cEmailForn := ""

	Private nConsNeg   := 0.4 // Constante para consertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex   := 0.38 // Constante para consertar o cálculo retornado pelo GetTextWidth.

	Private PixelX
	Private PixelY

	Private cDirPDF    := GetMV("ZZ_PEDIDOC")

	If Type("lPedido") != "L"
		lPedido := .F.
	Endif
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01               Do Pedido                             ³
	//³ mv_par02               Ate o Pedido                          ³
	//³ mv_par03               A partir da data de emissao           ³
	//³ mv_par04               Ate a data de emissao                 ³
	//³ mv_par05               Somente os Novos                      ³
	//³ mv_par06               Campo Descricao do Produto    	     ³
	//³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
	//³ mv_par08               Imprime ? Pedido Compra ou Aut. Entreg³
	//³ mv_par09               Numero de vias                        ³
	//³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
	//³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
	//³ mv_par12               Qual a Moeda ?                        ³
	//³ mv_par13               Endereco de Entrega                   ³
	//³ mv_par14               todas ou em aberto ou atendidos       ³
	// Pergunte(cPerg,.F.)
	If IsInCallStack("U_ENVPC") .or. IsInCallStack("U_NewEnvPC") .or. IsInCallStack("U_SchedEnvPC")
		MV_PAR14 := 2
	Else
		MV_PAR14 := Aviso(OemToAnsi("Impressão"),OemToAnsi("Pedido  de  compra  nº "+SC7->C7_NUM+" ?"),{"Todos","Em aberto","Atendidos","Cancela"})
		If  MV_PAR14 == 4
			Return
		Endif
	Endif
	FwMakeDir(cDirPDF,.F.)
	FwMakeDir(cDiret,.F.)
	If lAuto
		nReg   := SC7->(Recno())
		cAlias := "SC7"
		dbSelectArea("SC7")
		dbGoto(nReg)
		mv_par01 := C7_NUM
		mv_par02 := C7_NUM
		mv_par03 := C7_EMISSAO
		mv_par04 := C7_EMISSAO
		mv_par05 := 2
		mv_par06 := "C7_DESCRI"
		mv_par07 := 1
		//mv_par08 := C7_TIPO
		mv_par08 := 1 	// sempre considera que tudo eh Pedido de Compra, mesmo que seja Autorizacao de Entrega
		mv_par09 := 1
		mv_par10 := 3
		mv_par11 := 3
		mv_par12 := C7_MOEDA
		lEnvia := iif(C7_CONAPRO<>'B' , .T. , .F.)
	Endif

	//³ Verifica se no SX3 o C7_CC esta com tamanho 9 (Default) se igual a 9 muda o tamanho do relatorio           ³
	//³ para Medio possibilitando a impressao em modo Paisagem ou retrato atraves da reducao na variavel nDifColCC ³
	//³ se o tamanho do C7_CC no SX3 estiver > que 9 o relatorio sera impresso comprrimido com espaco para o campo ³
	//³ C7_CC centro de custo para ate 20 posicoes,Obs.desabilitando a selecao do modo de impresso retrato/paisagem³
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("C7_CC")
		If SX3->X3_TAMANHO == 9
			nDifColCC := 11
			Tamanho   := "M"
		Else
			lComp	  := .F.   // C.Custo c/ tamanho maior que 9, sempre PAISAGEM
		Endif
	Endif

	If nLastKey <> 27

		mv_par08 := 1

		//³ limpa conteudo dos diretorios, antes do processamento       ³
		aFiles := Directory(cDirPDF+"PC*.PDF" )
		For X :=1 to Len(aFiles)
			FErase(cDirPDF+aFiles[X,1])
		Next

		aFiles := Directory(cDiret+"PC*.PDF" )
		For X:=1 to Len(aFiles)
			FErase(cDiret+aFiles[X,1])
		Next

		aFiles := {}

		If mv_par08 == 1
			If IsInCallStack("U_SchedEnvPC")
				cDirPDF := cDiret
			EndIf
			cArquivo := "PC_"+Alltrim(mv_par01)

			//Alterado por Dione Oliveira em 10/02/2017 para salvar o arquivo em PDF automaticamente no caminho especificado no cDirPDF
			oPrint:=FWMsPrinter():New(cArquivo,6,.T.,cDirPDF,.T.)

			oPrint:SetResolution(78)
			oPrint:SetLandscape()
			oPrint:SetPaperSize(DMPAPER_A4)
			oPrint:SetMargin(60,60,60,60)

			oPrint:cPathPDF := cDirPDF
			oPrint:SetViewPDF(.T.)

			PixelX := oPrint:nLogPixelX()
			PixelY := oPrint:nLogPixelY()

			Processa({|| ImpPed()},titulo)

			lPedido := .F.

			If lAuto .and. nPag > 0
				If isInCallStack("U_ENVPC")
					oPrint:SetViewPDF(.f.)
					oPrint:Print()
					CpyT2S(cDirPDF+cArquivo+".PDF" , cDiret)
					PCEmail(aDados[nPosPC,10],Alltrim(mv_par01))
					//PCEmail("regis.ferreira@totvs.com.br;sbrazr@gmail.com",Alltrim(mv_par01))
					FErase(cDiret+cArquivo+".PDF")
				ElseIf IsInCallStack("U_NewEnvPC")
					oPrint:SetViewPDF(.f.)
					oPrint:Print()
					sleep(500)
					CpyT2S(cDirPDF+cArquivo+".PDF" , cDiret)
					aAreaX := FwGetArea()
					ConOut("Filial 2 : " + FWxFilial("SC7"))
					ConOut("Pedido MV: " + mv_par01)
					aInfMail := U_retMailPC(FWxFilial("SC7"), mv_par01)
					varinfo( "", aInfMail )
					cEmComp := aInfMail[7]
					FwRestArea(aAreaX)
					If !Empty(aInfMail[3])
						If !alltrim((cTempTable)->EMAIL) $ aInfMail[3]
							aInfMail[3] += ";" + alltrim((cTempTable)->EMAIL)
						EndIf
					Else
						aInfMail[3] := alltrim((cTempTable)->EMAIL)
					EndIf
					If Right(aInfMail[3],1) == ';'
						aInfMail[3] := substr(aInfMail[3],1,len(aInfMail[3])-2)
					ENDIF
					cMailF := ""
					For nX := 1 to len(aInfMail)
						If nX != 2
							If !Empty(aInfMail[nX])
								cMailF += iif(Empty(cMailF),ALLTRIM(aInfMail[nX]),";"+ALLTRIM(aInfMail[nX]))
							EndIf
						EndIf
					Next


					If aInfMail[2] == 'S'
						_aEmail:=  StrTokArr(aInfMail[3], ';')
						For n:=1 to len(_aEmail)
							If !isemail(ALLTRIM(_aEmail[n]))
								lContinua:= .F.
							endif
						Next n
						If lContinua

							// lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),iif(Empty(aInfMail[1]),"N",aInfMail[1]))
							lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),aInfMail[2], cEmComp)
							U_GrvLogPC(mv_par01, "AUTO", cMailF, iif(lEnvMail,"1","2"),"MANUAL","")


							If lEnvMail
								u_AtFlagPC(cFilAnt, mv_par01, "1")
							Else
								u_AtFlagPC(cFilAnt, mv_par01, "2")
							EndIf
						Else
							cMsg := ""
							cMsg += "Grupo Produto Conf. Para Envio de E-Mail" + CRLF
							cMSg += "E-Mail Fornecedor nao preenchido"
							U_GrvLogPC(mv_par01, "AUTO", cMailF, "2", "MANUAL",cMSg)
							u_AtFlagPC(cFilAnt, mv_par01, "2")
						EndIf
						ConOut("E-Mail: " + cMailF)
					Else
						cMsg := ""
						If Empty(aInfMail[1])
							cMSg += "E-Mail Solicitante nao preenchido"
						EndIf
						// lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),iif(Empty(aInfMail[1]),"N",aInfMail[1]))
						lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),aInfMail[2], cEmComp)
						ConOut("E-Mail: " + cMailF)
						U_GrvLogPC(mv_par01, "AUTO", cMailF, iif(lEnvMail,"1","2"),"MANUAL",cMSg)


						If lEnvMail
							u_AtFlagPC(cFilAnt, mv_par01, "1")
						Else
							u_AtFlagPC(cFilAnt, mv_par01, "2")
						EndIf

					EndIf

					// lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),iif(Empty(aInfMail[1]),"N",aInfMail[1]))
					// U_GrvLogPC(mv_par01, cUserName, cMailF, iif(lEnvMail,"1","2"),"MANUAL")
					FErase(cDiret+cArquivo+".PDF")


				ElseIf IsInCallStack("u_SchedEnvPC")
					oPrint:SetViewPDF(.f.)
					oPrint:Print()
					sleep(500)
					// CpyT2S(cDirPDF+cArquivo+".PDF" , cDiret)
					aAreaX := FwGetArea()
					ConOut("Filial 2 : " + FWxFilial("SC7"))
					ConOut("Pedido MV: " + mv_par01)
					aInfMail := U_retMailPC(FWxFilial("SC7"), mv_par01)
					// VarInfo("",aInfMail)
					cEmComp := aInfMail[6]
					FwRestArea(aAreaX)

					cMailF := ""
					For nX := 1 to len(aInfMail)
						If nX != 2
							iF nX != 6
								If !Empty(aInfMail[nX])
									If !(aInfMail[nX]) $ cMailF
										cMailF += iif(Empty(cMailF),aInfMail[nX],";"+aInfMail[nX])
									EndIf
								EndIf
							EndIf
						EndIf
					Next

					If aInfMail[2] == 'S'
						//If isemail(aInfMail[3])
						_aEmail:=  StrTokArr(aInfMail[3], ';')
						For n:=1 to len(_aEmail)
							If !isemail(ALLTRIM(_aEmail[n]))
								lContinua:= .F.
							endif
						Next n
						If lContinua

							// lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),iif(Empty(aInfMail[1]),"N",aInfMail[1]))
							lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),aInfMail[2], cEmComp)
							U_GrvLogPC(mv_par01, "AUTO", cMailF, iif(lEnvMail,"1","2"),"SCHEDULE","")

							ConOut("E-Mail: " + cMailF)
							If lEnvMail
								u_AtFlagPC(cFilAnt, mv_par01, "1")
							Else
								u_AtFlagPC(cFilAnt, mv_par01, "2")
							EndIf
						Else
							cMsg := ""
							cMsg += "Grupo Produto Conf. Para Envio de E-Mail" + CRLF
							cMSg += "E-Mail Fornecedor nao preenchido"
							U_GrvLogPC(mv_par01, "AUTO", cMailF, "2", "SCHEDULE",cMSg)
							u_AtFlagPC(cFilAnt, mv_par01, "2")
						EndIf
					Else
						cMsg := ""
						If Empty(aInfMail[1])
							cMSg += "E-Mail Solicitante nao preenchido"
						EndIf
						// lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),iif(Empty(aInfMail[1]),"N",aInfMail[1]))
						lEnvMail := PCEmail(cMailF,Alltrim(mv_par01),aInfMail[2], cEmComp)
						U_GrvLogPC(mv_par01, "AUTO", cMailF, iif(lEnvMail,"1","2"),"SCHEDULE",cMSg)


						If lEnvMail
							u_AtFlagPC(cFilAnt, mv_par01, "1")
						Else
							u_AtFlagPC(cFilAnt, mv_par01, "2")
						EndIf

					EndIf
					FErase(cDiret+cArquivo+".PDF")
				Else
					oPrint:Preview()
					//³ Adicionada condicao em 21/11/16 que verifica se o pedido ³
					//³ esta liberado ou nao para poder envia-lo por e-mail.     ³
					If lEnvia .and. IW_MsgBox(OemToAnsi("Deseja enviar o Pedido de Compra por e-mail ?") , OemToAnsi("Atenção") , "YESNO")
						//³  Faz copia do diretorio local para o diretorio do servidor  ³
						CpyT2S(cDirPDF+cArquivo+".PDF" , cDiret)
						PCEmail(cEmailForn,Alltrim(mv_par01),"","")
						FErase(cDiret+cArquivo+".PDF")
					Endif
				Endif
			Else
				oPrint:Preview()  // Visualiza antes de imprimir
			Endif
			FreeObj(oPrint)
		Endif
	Else
		dbClearFilter()
	EndIf

Return .T.


/*/
	±±³Fun‡…o    ³ ImpPed   ³ Autor ³ Marcos Candido        ³ Data ³ 30.03.10 ³±±
	±±³Descri‡…o ³ Impressao do PEDIDO                                        ³±±
/*/
//Static Function ImpPed(lEnd,wnRel,cString,nReg)
Static Function ImpPed()

	Local cFiltro := ""
	local ncw := 0
	Private oFont8
	Private oFont8n
	Private oFont10
	Private oFont10n
	Private oFont16
	Private oFont16n
	Private oFont24
	Private i := 0
	lin := 100

	Private cCGCPict, cCepPict , cObs01 , nValorPed
	Private aParcelas := {}
	Private nTotalPed := 0
	Private nTxMoeda , cEndEnt := ""
	Private cEndCob := ""
	Private nItemPC	  :=0

	//³Definir as pictures                                           ³
	cCepPict:=PesqPict("SA2","A2_CEP")
	cCGCPict:=PesqPict("SA2","A2_CGC")

	nDescProd:= 0
	nTotal   := 0
	nTotalPC   := 0
	nTotValIPI := 0
	nTotValICM := 0
	nTotValDES := 0
	nTotValSeg := 0
	nTotValFre := 0
	NumPed   := Space(6)
	nTotMerc := 0

	If lAuto
		ProcRegua(1)
	Else
		ProcRegua((Val(mv_par02)-Val(mv_par01))+1)
	EndIf

	if mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	ELSEIF MV_PAR14 == 1
		cFiltro := " 1 != 1 "
	ELSE
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	EndIf

	oFont8   := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont8n  := TFont():New("Arial",9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Courier New",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10n := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16  := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek(xFilial("SC7")+mv_par01,.T.)

	While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM >= mv_par01 .And. C7_NUM <= mv_par02

		IncProc()

		//³ Cria as variaveis para armazenar os valores do pedido        ³
		cObs01   := ""

		If C7_EMITIDO == "S" .And. mv_par05 == 1
			nItemPC += 1
			dbSkip()
			Loop
		Endif

		If C7_CONAPRO != "L" .And. mv_par14 == 2// .Or.;
				//(C7_CONAPRO == "B" .And. mv_par14 == 3)
			nItemPC += 1
			dbSkip()
			Loop
		Endif

		If (C7_EMISSAO < mv_par03) .Or. (C7_EMISSAO > mv_par04)
			nItemPC += 1
			dbSkip()
			Loop
		Endif

		//³ Consiste este item. EM ABERTO                                ³
		If mv_par14 == 2 //.or. mv_par14 == 1
			If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO).OR.SC7->C7_ENCER=='E'
				nItemPC += 1
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

		//³ Consiste este item. ATENDIDOS                                ³
		If mv_par14 == 3
			If SC7->C7_QUANT > SC7->C7_QUJE
				nItemPC += 1
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

		//³ Verifica mensagens adicionais (tabela SZB)                   ³
		SZB->(dbSetOrder(1))
		SZB->(dbSeek(xFilial("SZB")+SC7->C7_NUM))
		cMsgSZB := Alltrim(SZB->ZB_MSG)

		//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
		If !MtrAValOP(mv_par11, 'SC7')
			nItemPC += 1
			dbSkip()
			Loop
		EndIf

		nTxMoeda := IIF(SC7->C7_TXMOEDA > 0 , SC7->C7_TXMOEDA , Nil)

		MaFisEnd()
		R110FiniPC(SC7->C7_NUM,,,cFiltro)
		//nTotalPed := MaFisRet(,'NF_TOTAL')
		//nTotalPed += MaFisRet(Val(SC7->C7_ITEM),'IT_TOTAL')
		nOutroReg := SC7->(Recno())
		nPag := 0

		//Retirado a validação do MV_PAR13
		//If !Empty(mv_par13)
		//cEndEnt := Alltrim(mv_par13)
		//Else
		cEndEnt := Alltrim(SM0->M0_ENDENT)+" - "+Alltrim(SM0->M0_BAIRENT)+" - CEP: "+Transform(SM0->M0_CEPENT,cCepPict)+" - "+;
			Trim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT+" - Tel: "+Trim(SM0->M0_TEL)
		cEndCob := cEndEnt
		if cFilAnt$"0503"
			cEndEnt := "RUA BITTENCOURT SAMPAIO, 105 - VILA MARIANA - CEP: 04126-060 - SAO PAULO - SP - Tel: "+Trim(SM0->M0_TEL)
		endif
		if cFilAnt$"5200"
			cEndEnt := "RUA JORGE TIBIRIÇA, 461 - CASAS 1 E 2 - PRINCIPAL E EDÍCULA - CEP: 04126-001 - SAO PAULO - SP - Tel: "+Trim(SM0->M0_TEL)
		endif
		//Endif

		For ncw := 1 To mv_par09		// Imprime o numero de vias informadas

			cCondPgto:= SC7->C7_COND
			dDataEntr:= SC7->C7_DATPRF
			//nTotalPed := xMoeda(nTotalPed,SC7->C7_MOEDA,MV_PAR12,dDataEntr,,nTxMoeda)
			//aParcelas:= Condicao(nTotalPed,cCondPgto,,dDataEntr)

			nLin     := ImpCabec(lin)
			lin      := nLin
			nTotal   := 0
			nTotValIPI := 0
			nTotValICM := 0
			nTotValDES := 0
			nTotValSeg := 0
			nTotValFre := 0
			nDescProd:= 0
			nSavRec  := SC7->(Recno())
			NumPed   := SC7->C7_NUM
			nLinObs  := 0

			dbSelectArea("SC7")
			dbGoto(nSavRec)

			While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM == NumPed

				//³ Consiste este item. EM ABERTO
				If mv_par14 == 2
					If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO) .or. C7_CONAPRO != "L"
						nItemPC += 1
						dbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

				//³ Consiste este item. ATENDIDOS                                ³
				If mv_par14 == 3
					If SC7->C7_QUANT > SC7->C7_QUJE
						nItemPC += 1
						dbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

				//³ Verifica se havera salto de formulario                       ³
				If lin >= 1158
					ImpRodape(lin)			// Imprime rodape do formulario e salta para a proxima folha
					nLin := ImpCabec(lin)
					lin := nLin
				Endif

				oPrint:Say  (lin,32,C7_ITEM,oFont11)
				oPrint:Say  (lin,140,C7_PRODUTO,oFont11)
				//³ Pesquisa Descricao do Produto                                ³
				nItemPC += 1
				nLin := ImpProd(lin,nItemPC)
				lin := nLin


				If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif
				//³ Inicializacao da Observacao do Pedido.                       ³

				dbSkip()

				nOutroReg := SC7->(Recno())

			EndDo

			dbGoto(nSavRec)

			If lin >= 1158
				ImpRodape(lin)		// Imprime rodape do formulario e salta para a proxima folha
				nLin :=ImpCabec(lin)
				lin := nLin
			Endif

			lin := 1230
			FinalPed(nDescProd,lin,nTotValIPI,nTotValICM,nTotValDES,nTotValSeg,nTotValFre,nTotal,nTotalPC)		// Imprime os dados complementares do PC

		Next

		MaFisEnd()

		dbSelectArea("SC7")
		dbGoto(nOutroReg)

	EndDo

	dbSelectArea("SC7")
	Set Filter To
	dbSetOrder(1)

	dbSelectArea("SX3")
	dbSetOrder(1)

	lPedido := .F.

Return .T.

/*/
	±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Marcos Candido        ³ Data ³ 30.03.10 ³±±
	±±³Descri‡…o ³ Impressao do cabecalho do pedido de compra                 ³±±
/*/
Static Function ImpCabec(lin)
	local ff := 0
	// Inicia uma nova página
	oPrint:StartPage()

	cMoeda := Iif(mv_par12<10,Str(mv_par12,1),Str(mv_par12,2))
	nPag   := nPag + 1			// contador das paginas

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)

	cEmailForn := SA2->A2_EMAIL

	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+SC7->C7_COND)

	oPrint:Box  (30,20,270,3140)
	oPrint:SayBitmap(63,65,cBitMap,355,140)  // Largura x Altura
	oPrint:Say  (60,480,SM0->M0_NOMECOM,oFont10)
	oPrint:Say  (106,480,OemToAnsi(Alltrim(SM0->M0_ENDENT)),oFont10)
	oPrint:Say  (152,480,Transform(SM0->M0_CEPENT,cCepPict)+" - "+Alltrim(SM0->M0_BAIRENT)+" - "+Trim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT,oFont10)
	oPrint:Say  (198,480,"Tel.: "+Trim(SM0->M0_TEL),oFont10)
	oPrint:Say  (244,480,"CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + " - I.E.: " + InscrEst(),oFont10)
	oPrint:Line (30,1467,270,1467)
	oPrint:Say  (165,1670,OemToAnsi("PEDIDO DE COMPRA / SERVIÇO"),oFont16n)
	oPrint:Line (30,2600,270,2600)
	oPrint:Say  (55,2730,OemToAnsi("Número do Pedido :"),oFont8)
	oPrint:Say  (130,2745,SC7->C7_NUM,oFont16n)
	oPrint:Say  (239,2730,OemToAnsi("Folha :"),oFont8)
	oPrint:Say  (239,2850,StrZero(nPag,4),oFont10)

	oPrint:Box  (290,20,475,2030)
	oPrint:Say  (335,60,OemToAnsi("Fornecedor :"),oFont8)
	oPrint:Say  (333,230,SA2->A2_NOME,oFont10)
	oPrint:Say  (335,1100,OemToAnsi("Código :"),oFont8)
	oPrint:Say  (333,1230,SA2->A2_COD+"/"+SA2->A2_LOJA,oFont10)
	oPrint:Say  (335,1500,OemToAnsi("Contato :"),oFont8)
	oPrint:Say  (333,1635,SC7->C7_CONTATO,oFont10)
	oPrint:Say  (390,60,OemToAnsi("Endereço :"),oFont8)
	oPrint:Say  (388,227,SA2->A2_END,oFont10)
	oPrint:Say  (390,1100,OemToAnsi("CNPJ :"),oFont8)
	oPrint:Say  (388,1230,Subs(Transform(SA2->A2_CGC,PicPes(RetPessoa(SA2->A2_CGC))),1,at("%",transform(SA2->A2_CGC,PicPes(RetPessoa(SA2->A2_CGC))))-1),oFont10)
	oPrint:Say  (390,1630,OemToAnsi("I.E. :"),oFont8)
	oPrint:Say  (388,1700,SA2->A2_INSCR,oFont10)
	oPrint:Say  (445,60,OemToAnsi("C E P :"),oFont8)
	oPrint:Say  (443,190,Transform(SA2->A2_CEP,"@R 99999-999"),oFont10)
	oPrint:Say  (445,580,OemToAnsi("Cidade :"),oFont8)
	oPrint:Say  (443,727,SA2->A2_MUN,oFont10)
	oPrint:Say  (445,1100,OemToAnsi("UF :"),oFont8)
	oPrint:Say  (443,1205,SA2->A2_EST,oFont10)
	oPrint:Say  (445,1330,OemToAnsi("Tel : "),oFont8)
	oPrint:Say  (443,1400,SA2->A2_DDD+" "+Transform(Trim(SA2->A2_TEL),"@R 9999-9999"),oFont10)
	oPrint:Say  (445,1647,OemToAnsi("Fax : "),oFont8)
	oPrint:Say  (443,1717,SA2->A2_DDD+" "+Transform(Trim(SA2->A2_FAX),"@R 9999-9999"),oFont10)

	//cDescrMoed := GetMV("MV_MOEDAP"+Str(mv_par12,1))
	if mv_par12 > 9
		cDescrMoed := GetMV("MV_MOEDP"+Str(mv_par12,2))
	else
		cDescrMoed := GetMV("MV_MOEDAP"+Str(mv_par12,1))
	endif

	oPrint:Box  (290,2050,475,3140)
	oPrint:Say  (335,2080,OemToAnsi("Data :"),oFont8)
	oPrint:Say  (333,2200,Transform(SC7->C7_EMISSAO,"@D 99/99/9999"),oFont10)
	oPrint:Say  (335,2410,OemToAnsi("Condição de Pagamento :"),oFont8)
	oPrint:Say  (333,2810,Alltrim(SE4->E4_DESCRI),oFont10)

	//oPrint:Say  (370,2220,OemToAnsi("Desdobramento das Duplicatas - Valores em "+cDescrMoed),oFont8)
	Linha := 403
	Coluna := 2080

	nQtdParc := Min(4,Len(aParcelas)) //IIF(Len(aParcelas)>4,4,Len(aParcelas))

	For ff:=1 to nQtdParc
		//oPrint:Say  (Linha,Coluna,Transform(aParcelas[ff,1],"@D 99/99/9999"),oFont10)
		//oPrint:Say  (Linha,Coluna+160,OemToAnsi("-"),oFont8)
		//oPrint:Say  (Linha,Coluna+200,Transform(aParcelas[ff,2],"@E 999,999.99"),oFont10)
		Linha := Linha + iif(mod(ff,2)==0,38,0)
		If mod(ff,2) == 0
			Coluna := 2080
		Else
			Coluna := Coluna + 420
		Endif
	Next

	oPrint:Box  (495,20,1210,3140)
	oPrint:Line (495,125,1210,125)    	// linha entre ITEM e CODIGO
	oPrint:Line (495,490,1210,490)	 	// linha entre CODIGO e DESCRICAO
	oPrint:Line (495,1200,1210,1200)  	// linha entre DESCRICAO e UNIDADE DE MEDIDA
	oPrint:Line (495,1370,1210,1370)  	// linha entre UNIDADE DE MEDIDA e QUANTIDADE
	oPrint:Line (495,1670,1210,1670)    // linha entre QUANTIDADE e VALOR UNITARIO
	oPrint:Line (495,1955,1210,1955)    // linha entre VALOR UNITARIO e IPI ou VALOR TOTAL

	If mv_par08 == 1
		oPrint:Line (495,2130,1210,2130)    // linha entre IPI e VALOR TOTAL
		oPrint:Line (495,2404,1210,2404)    // linha entre VALOR TOTAL e ENTREGA
		oPrint:Line (495,2670,1210,2670)    // linha entre ENTREGA e ARMAZEM   // Observacoes    // C.C.
		oPrint:Line (495,2880,1210,2880)    // linha entre ARMAZEM e C.C.  // C.C.	e S.C.
	Else
		oPrint:Line (495,2350,1210,2350)    // linha entre VALOR TOTAL e ENTREGA
		oPrint:Line (495,2600,1210,2600)    // linha entre ENTREGA e NUM. OP.
	Endif

	If mv_par08 == 1
		oPrint:Say  (520,50,OemToAnsi("Item"),oFont8)
		oPrint:Say  (520,245,OemToAnsi("Cádigo"),oFont8)
		oPrint:Say  (520,680,OemToAnsi("Descrição do Material/Serviço"),oFont8)
		oPrint:Say  (520,1203,OemToAnsi("Unid.Medida"),oFont8)
		oPrint:Say  (520,1440,OemToAnsi("Quantidade"),oFont8)
		oPrint:Say  (520,1745,OemToAnsi("Valor Unitário"),oFont8)
		oPrint:Say  (520,2010,OemToAnsi("IPI%"),oFont8)
		oPrint:Say  (520,2198,OemToAnsi("Valor Total"),oFont8)
		oPrint:Say  (520,2475,OemToAnsi("Entrega"),oFont8)
		//oPrint:Say  (505,2497,OemToAnsi("Centro de Custo"),oFont8)
		//oPrint:Say  (505,2783,OemToAnsi("Solic. Compra"),oFont8)
		//oPrint:Say(505,2710,OemToAnsi("Observações"),oFont8)
		oPrint:Say(520,2720,OemToAnsi("Armazém"),oFont8)
		oPrint:Say(520,2900,OemToAnsi("Centro de Custo"),oFont8)
	Else
		oPrint:Say  (520,50,OemToAnsi("Item    Código            Descrição do Material            Unid.Medida    Quantidade         Valor Unitário       Valor Total         Entrega         Numero da OP  "),oFont8)
	EndIf

	oPrint:Line (540,20,540,3140)

	dbSelectArea("SC7")
	lin := 580

Return(lin)

/*/
	±±³Fun‡…o    ³ ImpProd  ³ Autor ³ Marcos Candido        ³ Data ³ 30.03.10 ³±±
	±±³Descri‡…o ³ Pesquisar e imprimir  dados Cadastrais do Produto.         ³±±
	±±³Sintaxe   ³ ImpProd(Void)                                              ³±±
/*/
Static Function ImpProd(lin,nItemPC)

	LOCAL cDesc, nLinRef := 1, nBegin := 0, cDescri := "", nLinha:=0
	LOCAL nTamDesc := iif(SM0->M0_CODIGO $ "01/03" , 30 , 50)


	mv_par06 := Alltrim(UPPER(mv_par06))

	dbSelectArea("SC7")
	//³ Se parametro estiver vazio, considero o conteudo daquilo ³
	//³ que foi digitado no Pedido de Compra.                    ³
	If Empty(mv_par06) .or. Substr(mv_par06,1,2) == "C7"
		mv_par06 := "C7_DESCRI"
		cDescri := Alltrim(SC7->C7_DESCRI)
	Endif

	//³ Impressao da descricao de campo localizado no Cad. de Produto  ³
	If Substr(mv_par06,1,2) == "B1"
		cDescri := Alltrim(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,mv_par06))
	Endif

	//³ Impressao da descricao cientifica do Produto.                ³
	If Substr(mv_par06,1,2) == "B5"
		cDescri := Alltrim(Posicione("SB5",1,xFilial("SB5")+SC7->C7_PRODUTO,mv_par06))
	EndIf

	dbSelectArea("SA5")
	dbSetOrder(1)
	If dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO).And. !Empty(SA5->A5_CODPRF)
		cDescri := cDescri + " ("+Alltrim(A5_CODPRF)+")"
	EndIf

	dbSelectArea("SC7")
	//³ Observacao do item                          ³
	If SM0->M0_CODIGO <> "03"
		If !Empty(SC7->C7_OBS)
			cDescri := cDescri + " ("+Alltrim(SC7->C7_OBS)+")"
		Endif
	Else
		If !Empty(SC7->C7_OBS)
			cDescri := cDescri + Alltrim(SC7->C7_OBS)
		Endif
	Endif

	//³ Imprime da descricao selecionada                             ³
	nLinha:= MLCount(cDescri,nTamDesc)

	oPrint:Say  (lin,510,MemoLine(cDescri,nTamDesc,1),oFont11)

	nLin := ImpCampos(lin,nItemPC)
	lin := nLin

	For nBegin := 2 To nLinha
		lin := lin + 47
		oPrint:Say  (lin,510,MemoLine(cDescri,nTamDesc,nBegin),oFont11)
	Next nBegin

	lin := lin + 47

Return(lin)

/*/
	±±³Fun‡…o    ³ ImpCampos³ Autor ³ Marcos Candido        ³ Data ³ 30.03.10 ³±±
	±±³Descri‡…o ³ Imprimir dados Complementares do Produto no Pedido.        ³±±
/*/
Static Function ImpCampos(lin)

	dbSelectArea("SC7")

	If MV_PAR07 == 2 .And. !Empty(SC7->C7_SEGUM)
		cPict := PesqPict("SC7","C7_UM")
		oPrint:Say  (lin,1260,Transform(SC7->C7_SEGUM,cPict),oFont11)
	Else
		cPict := PesqPict("SC7","C7_UM")
		oPrint:Say  (lin,1260,Transform(SC7->C7_UM,cPict),oFont11)
	EndIf
	If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM)
		cPict := PesqPictQt("C7_QUANT",13)
		oPrint:Say  (lin,1388,Transform(SC7->C7_QTSEGUM,cPict),oFont11)
	Else
		cPict := PesqPictQt("C7_QUANT",13)
		oPrint:Say  (lin,1388,Transform(SC7->C7_QUANT,cPict),oFont11)
	EndIf
	If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM)
		cPict := "@E 999,999.99999"
		oPrint:Say(lin,1675,Transform(xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,5,nTxMoeda),cPict),oFont11)
	Else
		cPict := "@E 999,999.99999"
		//cPict := "@E 999,999.99"
		oPrint:Say(lin,1675,Transform(xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,5,nTxMoeda),cPict),oFont11)
	EndIf

	If mv_par08 == 1
		cPict := PesqPictQt("C7_IPI",5)
		oPrint:Say  (lin,2000,Transform(SC7->C7_IPI,cPict),oFont11)
		cPict := PesqPict("SC7","C7_TOTAL",16,mv_par12)
		oPrint:Say  (lin,2057,Transform(xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,2,nTxMoeda),cPict),oFont11)
		cPict := PesqPict("SC7","C7_DATPRF")
		oPrint:Say  (lin,2430,Transform(SC7->C7_DATPRF,cPict),oFont11)

		oPrint:Say(lin,2740,SC7->C7_LOCAL,oFont11)
		If !Empty(SC7->C7_CC)
			oPrint:Say(lin,2920,SC7->C7_CC,oFont11)
		Else
			oPrint:Say(lin,2920,SC7->C7_CC,oFont11)
		Endif
	Else
		cPict := PesqPict("SC7","C7_TOTAL",16,mv_par12)
		oPrint:Say  (lin,1000,Transform(xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
		cPict := PesqPict("SC7","C7_DATPRF")
		oPrint:Say  (lin,1150,Transform(SC7->C7_DATPRF,cPict),oFont11)
		cPict := PesqPict("SC7","C7_OP")
		oPrint:Say  (lin,1150,Transform(SC7->C7_OP,cPict),oFont11)
	EndIf

	//Acrescentado a validação por item, pois estava imprimindo itens com valores errados quando tinhamos eliminação de resíduo
	//nTotal += SC7->C7_TOTAL
	nTotal		+= MaFisRet(nItemPC,'IT_VALMERC')
	nTotalPC	+= MaFisRet(nItemPC,'IT_TOTAL')
	nTotValIPI	+= MaFisRet(nItemPC,'IT_VALIPI')
	nTotValICM	+= MaFisRet(nItemPC,'IT_VALICM')
	nTotValDES	+= MaFisRet(nItemPC,'IT_DESPESA')
	nTotValSeg	+= MaFisRet(nItemPC,'IT_SEGURO')
	nTotValFre	+= MaFisRet(nItemPC,'IT_FRETE')
	//nTotValGer	:= MaFisRet(Val(SC7->C7_ITEM),'IT_TOTAL')

Return(lin)

/*/
	±±³Fun‡…o    ³ ImpRodape³ Autor ³ Marcos Candido        ³ Data ³ 30.03.10 ³±±
	±±³Descri‡…o ³ Impressao do pedido de compra (Rodape )                    ³±±
/*/
Static Function ImpRodape(lin)

	oPrint:Say (lin,60,"Continua na página seguinte ...",oFont10)

	lin := 1230
	oPrint:Box  (lin,20,lin+77,3140)
	lin := lin + 55
	oPrint:Say (lin,600,OemToAnsi("D  E  S  C  O  N  T  O  S  -->"),oFont10)
	oPrint:Say (lin,1200,Transform(C7_DESC1,"@E 999.99"),oFont11)
	oPrint:Say (lin,1600,Transform(C7_DESC2,"@E 999.99"),oFont11)
	oPrint:Say (lin,2000,Transform(C7_DESC3,"@E 999.99"),oFont11)
	lin := lin + 82

	oPrint:Box  (lin,20,lin+124,3140)
	lin := lin + 45

	//³ Endereco de Entrega  ³
	//Alteração do endereço de entrega conforme chamado Ticket#2020082110041641
	oPrint:Say(lin,040,OemToAnsi("LOCAL DE ENTREGA : "),oFont10n)
	oPrint:Say(lin,440,OemToAnsi(cEndEnt),oFont10)


	lin := lin + 47

	//³ Endereco de Cobranca ³
	oPrint:Say(lin,040,OemToAnsi("LOCAL DE COBRANÇA : "),oFont10n)
	oPrint:Say(lin,465,OemToAnsi(cEndCob),oFont10)

	lin := lin + 102

	linOrig := lin		// armazena para uso no outro box que sera montado ao lado deste

	dbSelectArea("SC7")
	cMensagem := Formula(C7_MSG)

	// - - - - - - - -  CONSIDERAR APENAS 12 LINHAS PARA AS MENSAGENS

	cMens1  := "                                                       ====      I M P O R T A N T E     ===="
	cMens2  := "CONDIÇÕES GERAIS DESTE PEDIDO:
	cMens3  := "  - Favor constar na nota fiscal, o nímero do nosso pedido de compra."
//	cMens4  := "  - Favor encaminhar certificado de qualidade/análise."
	//If (SM0->M0_CODIGO == '01' .and. SM0->M0_CODFIL == '01')
	//cMens4  := "  - Favor encaminhar certificado de qualidade/análise obrigatoriamente para o e-mail: recebimento@eurofins.com"
	//Else
	cMens4  := "  - Favor encaminhar certificado de qualidade/análise."
	//Endif

	//Alterado o Horário conforme chamado Ticket#2020020510030096
	if cFilAnt $ "0100"
		cMens5  := "  - Horário para recebimento de materiais é de Segunda á Quinta das 08:00h até as 15:00h."
	elseif cFilAnt $ "0101"
		cMens5  := "  - Horário para recebimento de materiais é de Segunda á Sexta das 08:00h até as 15:00h."
	elseif cFilAnt $ "0603"
		cMens5  := "  - Horário de recebimento: Segunda a Sexta das 8:00 às 12:00 e das 13:00 às 15:00."
	Else
		cMens5  := "  - Horário de recebimento: das 9:00hs às 12 horas e das 14 horas às 17 horas."
	Endif
	// EVANDRO MULLA INICIO INCLUIDO 26/06/207
	If SM0->M0_CODIGO == '05' .or. SM0->M0_CODFIL == '05'
		cMens5  := "  - Horário de recebimento: das 0hs às 0 horas e das 0 horas às 0 horas."
	Endif
	//ajustado em 29/08/18 para tratar todas as filiais
	if cFilAnt $ '0100/2000'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nf@eurofinslatam.com"
	elseif cFilAnt $ '0101' //Separado a filial 0101 conforme chamado Ticket#2020010310031993
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfrecife@eurofinslatam.com"
	elseif cFilAnt $ '0300/0301/0302/0303/0304'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail admagroscience@eurofinslatam.com"
		cMens6  += "  - Notas Fiscais e boletos deverão ser obrigatoriamente enviados para o e-mail admagroscience@eurofinslatam.com assim que emitidos."
	elseif cFilAnt $ '0400/0401/0403'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfealac@eurofinslatam.com"
	elseif cFilAnt $ '0500/0501/0502/0503/0505'  //Separado a filial 0504 conforme chamado Ticket#2019121010064355
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail 	nfgrupopasteur@eurofinslatam.com"
	elseif cFilAnt $ '0504'  //Separado a filial 0504 conforme chamado Ticket#2019121010064355
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfdioxinas@eurofins.com"
	elseif cFilAnt $ '0600'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfipex@eurofinslatam.com"
	elseif cFilAnt $ '0800/0802'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail CarolineDietrich@eurofins.com"
	elseif cFilAnt $ '0602'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfambientalsp@eurofinslatam.com"
	elseif cFilAnt $ '0603'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfspecialtests@eurofinslatam."
	elseif cFilAnt $ '0604'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfeasl@eurofinslatam.com"
	elseif cFilAnt $ '5000/5001/5002/5003/5004/5005/5006/5007/5008/5009/5010/5011/5300'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfeasl@eurofinslatam.com"
	else
		cMens6 := ""
	Endif
	cMens7  := "  - Não recebemos entregas nos últimos 3 dias úteis do mês."
	cMens8  := "  - Não recebemos Nota Fiscal cuja data de emissão é referente ao mês vigente."
	cMens9  := "  - Não recebemos Nota Fiscal de Serviço com emissão após dia 25 de cada mês."
	cMens10 := "  "
	cMens11 := "  "
	cMens12 := "  "

	If SC7->C7_MOEDA <> 1
		If Empty(cMens8)
			cMens8  := "  - Considerar neste pedido a taxa de câmbio do dia"+iif(SC7->C7_TXMOEDA > 0 , ". Taxa:  "+Alltrim(Transform(SC7->C7_TXMOEDA,"@E 999999.9999")) , "")+"."
		ElseIf Empty(cMens9)
			cMens9  := "  - Considerar neste pedido a taxa de câmbio do dia"+iif(SC7->C7_TXMOEDA > 0 , ". Taxa:  "+Alltrim(Transform(SC7->C7_TXMOEDA,"@E 999999.9999")) , "")+"."
		Else
			cMens10  := "  - Considerar neste pedido a taxa de câmbio do dia"+iif(SC7->C7_TXMOEDA > 0 , ". Taxa:  "+Alltrim(Transform(SC7->C7_TXMOEDA,"@E 999999.9999")) , "")+"."
		Endif
		If mv_par12 == 1
			If Empty(cMens8)
				cMens8 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			ElseIf Empty(cMens9)
				cMens9 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			ElseIf Empty(cMens10)
				cMens10 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			Elseif Empty(cMens11)
				cMens11 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			Else
				cMens12 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			Endif
		Endif
		If Empty(cMens8)
			cMens8  := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		ElseIf Empty(cMens9)
			cMens9  := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		ElseIf Empty(cMens10)
			cMens10  := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		ElseIf Empty(cMens11)
			cMens11 := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		Else
			cMens12 := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		Endif
	Endif

	nProxLin := lin + 517

	oPrint:Box  (lin,20,nProxLin,1830)
	lin := lin + 15

	If !Empty(cMensagem)
		oPrint:Say (lin,040,Substr(cMensagem,1,75),oFont10)
		lin := lin + 47
		If !Empty(Substr(cMensagem,76))
			oPrint:Say (lin,040,Substr(cMensagem,76,75),oFont10)
			lin := lin + 47
		Endif
	Else
		lin := lin + 23
	Endif
	oPrint:Say (lin-6,040,OemToAnsi(cMens1),oFont10)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens2),oFont10)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens3),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens4),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens5),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens6),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens7),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens8),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens9),oFont8n)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens10),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens11),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens12),oFont8)

	lin := linOrig

	oPrint:Box  (lin,1880,nProxLin,3140)
	lin := lin + 15
	If Empty(cMensagem)
		lin := lin + 23
	Endif

	oPrint:Say  (lin,2000,OemToAnsi("Total das Mercadorias "),oFont10)
	lin := lin + 55

	oPrint:Say  (lin,2000,OemToAnsi("IPI "),oFont10)
	lin := lin + 55

	oPrint:Say  (lin,2000,OemToAnsi("ICMS "),oFont10)
	lin := lin + 55

	oPrint:Say  (lin,2000,OemToAnsi("Despesas "),oFont10)
	lin := lin + 55

	oPrint:Say  (lin,2000,OemToAnsi("Seguro "),oFont10)
	lin := lin + 55

	oPrint:Say  (lin,2000,OemToAnsi("Frete "),oFont10)
	lin := lin + 55

	oPrint:Say  (lin,2000,OemToAnsi("Obs. do Frete "),oFont10)
	lin := lin + 55

	oPrint:Say  (lin,2000,OemToAnsi("Total Geral "),oFont10)

	// FINALIZA PAGINA
	oPrint:EndPage()

Return( .T. )

/*/
	±±³Fun‡…o    ³ FinalPed ³ Autor ³ Marcos Candido        ³ Data ³ 18/03/03 ³±±
	±±³Descri‡…o ³ Imprime os dados complementares do Pedido de Compra        ³±±
/*/
Static Function FinalPed(nDescProd,lin,nTotValIPI,nTotValICM,nTotValDES,nTotValSeg,nTotValFre,nTotal,ntotalPC)

	Local nTotDesc	:= nDescProd
	Local lNewAlc	:= .F.
	Local lLiber 	:= .F.
	Local lImpLeg	:= .T.
	Local cComprador:= ""
	LOcal cAlter	:= ""
	Local cAprov	:= ""
	//Retirada a validação da NF e passada por item
	//Local nTotIpi	:= MaFisRet(,'NF_VALIPI')
	//Local nTotIcms	:= MaFisRet(,'NF_VALICM')
	//Local nTotDesp	:= MaFisRet(,'NF_DESPESA')
	//Local nTotFrete := MaFisRet(,'NF_FRETE')
	//Local nTotalNF	:= MaFisRet(,'NF_TOTAL')
	//Local nTotSeguro:= MaFisRet(,'NF_SEGURO')
	Local nTotIpi	:= nTotValIPI
	Local nTotIcms	:= nTotValICM
	Local nTotDesp	:= nTotValDES
	Local nTotFrete := nTotValFre
	Local nTotalNF	:= nTotalPC
	Local nTotal	:= nTotal
	Local nTotSeguro:= nTotValSeg

	dbSelectArea("SC7")

	oPrint:Box  (lin,20,lin+77,3140)
	lin := lin + 55
	oPrint:Say (lin,600,OemToAnsi("D  E  S  C  O  N  T  O  S  -->"),oFont10)
	oPrint:Say (lin,1200,Transform(C7_DESC1,"@E 999.99"),oFont11)
	oPrint:Say (lin,1600,Transform(C7_DESC2,"@E 999.99"),oFont11)
	oPrint:Say (lin,2000,Transform(C7_DESC3,"@E 999.99"),oFont11)
	cPict := PesqPict("SC7","C7_VLDESC",14,mv_par12)
	oPrint:Say (lin,2400,Transform(xMoeda(nTotDesc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
	lin := lin + 82

	oPrint:Box  (lin,20,lin+124,3140)
	lin := lin + 45

	//³ Endereco de Entrega  ³
	//Alteração do endereço de entrega conforme chamado Ticket#2020082110041641
	oPrint:Say(lin,040,OemToAnsi("LOCAL DE ENTREGA : "),oFont10n)
	oPrint:Say(lin,440,OemToAnsi(cEndEnt),oFont10)

	lin := lin + 47

	//³ Endereco de Cobranca ³
	oPrint:Say(lin,040,OemToAnsi("LOCAL DE COBRANÇA : "),oFont10n)
	oPrint:Say(lin,465,OemToAnsi(cEndCob),oFont10)

	lin := lin + 102

	linOrig := lin		// armazena para uso no outro box que sera montado ao lado deste

	dbSelectArea("SC7")
	cMensagem := Formula(C7_MSG)

	// - - - - - - - -  CONSIDERAR APENAS 12 LINHAS PARA AS MENSAGENS

	cMens1  := "                                                       ====      I M P O R T A N T E     ===="
	cMens2  := "CONDIÇÕES GERAIS DESTE PEDIDO:
	cMens3  := "  - Favor constar na nota fiscal, o número do nosso pedido de compra."
//	cMens4  := "  - Favor encaminhar certificado de qualidade/análise."
	//If (SM0->M0_CODIGO == '01' .and. SM0->M0_CODFIL == '01')
	//cMens4  := "  - Favor encaminhar certificado de qualidade/análise obrigatoriamente para o e-mail: recebimento@eurofins.com"
	//Else
	cMens4  := "  - Favor encaminhar certificado de qualidade/análise."
	//Endif

	//Alterado o Horário conforme chamado Ticket#2020020510030096
	if cFilAnt $ "0100"
		cMens5  := "  - Horário para recebimento de materiais é de Segunda á Quinta das 08:00h até as 16:00h."
	elseif cFilAnt $ "0101"
		cMens5  := "  - Horário para recebimento de materiais é de Segunda á Sexta das 08:00h até as 15:00h."
	elseif cFilAnt $ "0603"
		cMens5  := "  - Horário de recebimento: Segunda a Sexta das 8:00 às 12:00 e das 13:00 às 15:00."
	Else
		cMens5  := "  - Horário de recebimento: das 9:00hs às 12 horas e das 14 horas às 17 horas."
	Endif
	// INCLUIDO INICIO EVANDRO MULLA 26/06/2017
	If SM0->M0_CODIGO == '05' .and. SM0->M0_CODFIL == '05
		cMens5  := "  - Horário de recebimento: das 0hs às 0 horas e das 0 horas às 0 horas."
	Endif
	// EVANDRO FIM EVANDRO MULLA 26/06/2017
	//ajustado em 29/08/18 para tratar todas as filiais
	if cFilAnt $ '0100/2000'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nf@eurofinslatam.com"
	elseif cFilAnt $ '0101' //Separado a filial 0101 conforme chamado Ticket#2020010310031993
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfrecife@eurofinslatam.com"
	elseif cFilAnt $ '0300/0301/0302/0303/0304'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail admagroscience@eurofinslatam.com"
		cMens6  += "  - Notas Fiscais e boletos deverão ser obrigatoriamente enviados para o e-mail admagroscience@eurofinslatam.com assim que emitidos."
	elseif cFilAnt $ '0400/0401/0403'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfealac@eurofinslatam.com"
	elseif cFilAnt $ '0500/0501/0502/0503/0505'  //Separado a filial 0504 conforme chamado Ticket#2019121010064355
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail 	nfgrupopasteur@eurofinslatam.com"
	elseif cFilAnt $ '0504'  //Separado a filial 0504 conforme chamado Ticket#2019121010064355
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfdioxinas@eurofins.com"
	elseif cFilAnt $ '0600'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfipex@eurofinslatam.com"
	elseif cFilAnt $ '0800/0802'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail CarolineDietrich@eurofins.com"
	elseif cFilAnt $ '0602'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfambientalsp@eurofinslatam.com"
	elseif cFilAnt $ '0603'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfspecialtests@eurofinslatam."
	elseif cFilAnt $ '0604'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfeasl@eurofinslatam.com"
	elseif cFilAnt $ '5000/5001/5002/5003/5004/5005/5006/5007/5008/5009/5010/5011/5300'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfeasl@eurofinslatam.com"
	else
		cMens6 := ""
	Endif

	cMens7  := "  - Não recebemos entregas nos últimos 3 dias úteis do mês."
	cMens8  := "  - Não recebemos Nota Fiscal cuja data de emissão não é referente ao mês vigente."
	cMens9  := "  - Não recebemos Nota Fiscal de Serviço com emissão após dia 25 de cada mês."
	cMens10 := "  "
	cMens11 := "  "
	cMens12 := "  "

	If SC7->C7_MOEDA <> 1
		If Empty(cMens8)
			cMens8  := "  - Considerar neste pedido a taxa de câmbio do dia"+iif(SC7->C7_TXMOEDA > 0 , ". Taxa:  "+Alltrim(Transform(SC7->C7_TXMOEDA,"@E 999999.9999")) , "")+"."
		ElseIf Empty(cMens9)
			cMens9  := "  - Considerar neste pedido a taxa de câmbio do dia"+iif(SC7->C7_TXMOEDA > 0 , ". Taxa:  "+Alltrim(Transform(SC7->C7_TXMOEDA,"@E 999999.9999")) , "")+"."
		Else
			cMens10 := "  - Considerar neste pedido a taxa de câmbio do dia"+iif(SC7->C7_TXMOEDA > 0 , ". Taxa:  "+Alltrim(Transform(SC7->C7_TXMOEDA,"@E 999999.9999")) , "")+"."
		Endif
		If mv_par12 == 1
			If Empty(cMens8)
				cMens8 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			ElseIf Empty(cMens9)
				cMens9 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			ElseIf Empty(cMens10)
				cMens10 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			ElseIf Empty(cMens11)
				cMens11 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			Else
				cMens12 := "  - Os valores do quadro ao lado já estão convertidos em REAIS"+iif(SC7->C7_TXMOEDA > 0 ," pela taxa indicada." ,".")
			Endif
		Endif
		If Empty(cMens8)
			cMens8  := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		ElseIf Empty(cMens9)
			cMens9  := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		ElseIf Empty(cMens10)
			cMens10  := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		ElseIf Empty(cMens11)
			cMens11 := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		Else
			cMens12 := "  - Para efeito de faturamento os valores serão utilizados com a cotação atualizada."
		Endif
	Endif

	nProxLin := lin + 517

	oPrint:Box  (lin,20,nProxLin,1830)
	lin := lin + 15

	If !Empty(cMensagem)
		oPrint:Say (lin,040,Substr(cMensagem,1,75),oFont10)
		lin := lin + 47
		If !Empty(Substr(cMensagem,76))
			oPrint:Say (lin,040,Substr(cMensagem,76,75),oFont10)
			lin := lin + 47
		Endif
	Else
		lin := lin + 23
	Endif
	oPrint:Say (lin-6,040,OemToAnsi(cMens1),oFont10)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens2),oFont10)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens3),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens4),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens5),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens6),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens7),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens8),oFont8n)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens9),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens10),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens11),oFont8)
	lin := lin + 47
	oPrint:Say (lin,040,OemToAnsi(cMens12),oFont8)

	lin := linOrig

	oPrint:Box  (lin,1880,nProxLin,3140)
	lin := lin + 45
	If Empty(cMensagem)
		lin := lin + 23
	Endif

	oPrint:Line (lin+10,2000,lin+10,2795)
	oPrint:Say  (lin,2000,OemToAnsi("Total das Mercadorias "),oFont10)
	cPict := tm(nTotal,14,MsDecimais(MV_PAR12))
	oPrint:Say  (lin,2500,Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
	lin := lin + 55

	dbSelectArea("SC7")

	oPrint:Line (lin+10,2000,lin+10,2798)
	oPrint:Say  (lin,2000,OemToAnsi("IPI "),oFont10)
	cPict:= tm(nTotIpi,14,MsDecimais(MV_PAR12))
	oPrint:Say  (lin,2500,Transform(xMoeda(nTotIPI,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
	lin := lin + 55

	oPrint:Line (lin+10,2000,lin+10,2798)
	oPrint:Say  (lin,2000,OemToAnsi("ICMS "),oFont10)
	cPict := tm(nTotIcms,14,MsDecimais(MV_PAR12))
	oPrint:Say  (lin,2500,Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
	lin := lin + 55

	oPrint:Line (lin+10,2000,lin+10,2798)
	oPrint:Say  (lin,2000,OemToAnsi("Despesas "),oFont10)
	cPict := tm(nTotDesp,14,MsDecimais(MV_PAR12))
	oPrint:Say  (lin,2500,Transform(xMoeda(nTotDesp,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
	lin := lin + 55

	oPrint:Line (lin+10,2000,lin+10,2798)
	oPrint:Say  (lin,2000,OemToAnsi("Seguro "),oFont10)
	cPict := tm(nTotSeguro,14,MsDecimais(MV_PAR12))
	oPrint:Say  (lin,2500,Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
	lin := lin + 55

	oPrint:Line (lin+10,2000,lin+10,2798)
	oPrint:Say  (lin,2000,OemToAnsi("Frete "),oFont10)
	cPict := tm(nTotFrete,14,MsDecimais(MV_PAR12))
	oPrint:Say  (lin,2500,Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
	lin := lin + 55

	oPrint:Line (lin+10,2000,lin+10,2798)
	oPrint:Say  (lin,2000,OemToAnsi("Obs. do Frete "),oFont10)
	If SC7->C7_TPFRETE == "F"
		cTpFrete := "FOB"
	ElseIF SC7->C7_TPFRETE == "C"
		cTpFrete := "CIF"
	Else
		cTpFrete := " "
	Endif
	oPrint:Say  (lin,2735,cTpFrete,oFont10)
	lin := lin + 65

	cComprador := UsrFullName(SC7->C7_USER)

	If !Empty(SC7->C7_APROV)
		lNewAlc := .T.
		If C7_CONAPRO != "B"
			lLiber := .T.
		EndIf

		nVez := 0
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM,.T.)
		While !Eof() .And. Alltrim(SCR->CR_FILIAL+SCR->CR_NUM)==Alltrim(xFilial("SCR")+SC7->C7_NUM)
			cAprov += IIF(nVez>0," - ","")+AllTrim(UsrFullName(SCR->CR_USER))+" ["+IF(SCR->CR_STATUS=="03","Ok",IF(SCR->CR_STATUS=="04","BLQ","??"))+"]"
			dbSelectArea("SCR")
			dbSkip()
			nVez++
		Enddo
		If !Empty(SC7->C7_GRUPCOM)
			dbSelectArea("SAJ")
			dbSetOrder(1)
			dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				dbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf
	EndIf

	oPrint:Line (lin+10,2000,lin+10,2798)
	cPict := tm(nTotalNF,14,MsDecimais(MV_PAR12))
	oPrint:Say  (lin,2000,OemToAnsi("Total Geral "),oFont10)

	If !lNewAlc
		oPrint:Say  (lin,2500,Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
	Else
		If lLiber
			oPrint:Say  (lin,2500,Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda),cPict),oFont11)
		Else
			oPrint:Say  (lin,2450,OemToAnsi("P E D I D O   B L O Q U E A D O "),oFont10)
		EndIf
	EndIf

	lin := nProxlin + 20
	lin := lin + 25

	If !lNewAlc
		oPrint:Say  (lin,100,OemToAnsi("Liberação do Pedido"),oFont10)
		cLiberador := ""
		nPosicao := 0
		lin := lin + 160
		oPrint:Line (lin,200,lin,600)
		oPrint:Line (lin,1000,lin,1400)
		oPrint:Line (lin,1800,lin,2200)
		lin := lin + 47
		oPrint:Say  (lin,305,OemToAnsi("Comprador"),oFont10)
		oPrint:Say  (lin,1120,OemToAnsi("Gerência"),oFont10)
		oPrint:Say  (lin,1920,OemToAnsi("Diretoria"),oFont10)
		lin := lin + 47
		oPrint:Say  (lin,270,OemToAnsi(Substr(cComprador,1,60)),oFont10)
		oPrint:Say  (lin,1950,OemToAnsi(cLiberador),oFont10)
	Else
		oPrint:Say  (lin,100,IF(lLiber,"P E D I D O   L I B E R A D O","P E D I D O   B L O Q U E A D O !!!"),oFont10)
		oPrint:Say  (lin,1300,OemToAnsi("LEGENDA : BLQ=Bloqueado     Ok=Liberado     ??=Aguardando Liberação"),oFont10)
		lin := lin + 160
		oPrint:Line (lin,200,lin,700)
		oPrint:Line (lin,1100,lin,1600)
		oPrint:Line (lin,2000,lin,2500)
		lin := lin + 25
		oPrint:Say  (lin,250,OemToAnsi("Comprador Responsável"),oFont10)
		oPrint:Say  (lin,1150,OemToAnsi("Compradores Alternativos"),oFont10)
		oPrint:Say  (lin,2110,OemToAnsi("Aprovador(es)"),oFont10)
		lin := lin + 47
		oPrint:Say  (lin,270,OemToAnsi(Substr(cComprador,1,60)),oFont10)

		nLinAtual := lin
		nAuxLin := Len(cAlter)
		While nAuxLin > 0 .oR. lImpLeg
			oPrint:Say  (lin,1170,OemToAnsi(Substr(cAlter,Len(cAlter)-nAuxLin+1,60)),oFont10)
			If lImpLeg
				lImpLeg := .F.
			EndIf
			nAuxLin -= 60
			lin := lin + 47
		EndDo

		lin := nLinAtual

		nAuxLin := Len(cAprov)
		lImpLeg := .T.
		While nAuxLin > 0 .Or. lImpLeg
			oPrint:Say  (lin,2070,OemToAnsi(Substr(cAprov,Len(cAprov)-nAuxLin+1,70)),oFont10)
			If lImpLeg
				lImpLeg := .F.
			EndIf
			nAUxLin -=70
			lin := lin + 47
		EndDo
		If nAuxLin == 0
			lin := lin + 47
		EndIf
		lin := lin + 47
	EndIf

	oPrint:EndPage()

Return .T.

/*/
	±±ºPrograma  ³ PCEMAIL  ºAutor  ³ Marcos Candido     º Data ³             º±±
	±±ºDesc.     ³ Envia email com o Pedido de Conta para a conta indicada    º±±
	±±º          ³ na caixa de dialogo.                                       º±±
/*/

Static Function PCEmail(cDestinat,cNumPC,cEnvFor,cEmComp)

	Local _CRLF      := "CHR(13)+CHR(10)"
	Local aAreaAtual := GetArea()
	Local aFilAgro   := {}
	Local cTitJan    := "Pedido de Compra - "+Alltrim(cNumPC)
	Local cAssunto   := cTitJan + " - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
	Local cDirAgro   := "\IMAGEMPC_AGRO\"
	Local cIdCV8     := ""
	Local cMSG       := ""
	Local cNomeUser  := Alltrim(UsrRetName(RetCodUsr()))
	local nX := 0
	Local lCont      := .F.
	Private cAnexos  := ""
	Private cPara    := iif(Empty(cDestinat),alltrim(UsrRetMail(RetCodUsr())),cDestinat+Space(30))
	default cEnvFor  := "S"


	If Empty(_CRLF)
		_CRLF := CHR(13)+CHR(10)
	Else
		_CRLF := Trim(_CRLF)
		_CRLF := &_CRLF
	Endif
	aFiles := Directory(cDiret+"*.pdf")
	For nX:=1 to Len(aFiles)
		If !(cDiret+aFiles[nX,1] $ cAnexos).and.(!"PC_"$Upper(aFiles[nX,1]).or.cNumPC$aFiles[nX,1])
			cAnexos += cDiret+ALLTRIM(aFiles[nX,1]) + "; "
			cAnexos:= ALLTRIM(cAnexos)
		Endif
	Next nX

	cMsg := _CRLF
	//cMsg += "Envio Automático de Pedido de Compra." + _CRLF
	cMsg += _CRLF
	//ajustado em 29/08/18 para tratar todas as filiais
	//Comentado a linha dos e-mails.
	/*if cFilAnt $ '0100/0101/0300'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nf@eurofins.com"
	elseif cFilAnt $ '0400/0401/0403'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfealac@eurofins.com"
	elseif cFilAnt $ '0500/0501/0502/0503/0504'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfanatech@eurofins.com"
	elseif cFilAnt $ '0600'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfeinnolab@eurofins.com"
	elseif cFilAnt $ '0800/0802'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail CarolineDietrich@eurofins.com"
	else
		cMens6 := ""
	Endif*/
	if cFilAnt $ '0100/2000'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nf@eurofinslatam.com"
	elseif cFilAnt $ '0101' //Separado a filial 0101 conforme chamado Ticket#2020010310031993
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfrecife@eurofinslatam.com"
	elseif cFilAnt $ '0300/0301/0302/0303/0304'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail admagroscience@eurofinslatam.com"
		cMens6  += "  - Notas Fiscais e boletos deverão ser obrigatoriamente enviados para o e-mail admagroscience@eurofinslatam.com assim que emitidos."
	elseif cFilAnt $ '0400/0401/0403'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfealac@eurofinslatam.com"
	elseif cFilAnt $ '0500/0501/0502/0503/0505'  //Separado a filial 0504 conforme chamado Ticket#2019121010064355
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail 	nfgrupopasteur@eurofinslatam.com"
	elseif cFilAnt $ '0504'  //Separado a filial 0504 conforme chamado Ticket#2019121010064355
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfdioxinas@eurofins.com"
	elseif cFilAnt $ '0600'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfipex@eurofinslatam.com"
	elseif cFilAnt $ '0800/0802'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail CarolineDietrich@eurofins.com"
	elseif cFilAnt $ '0602'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfambientalsp@eurofinslatam.com"
	elseif cFilAnt $ '0603'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfspecialtests@eurofinslatam."
	elseif cFilAnt $ '0604'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfeasl@eurofinslatam.com"
	elseif cFilAnt $ '5000/5001/5002/5003/5004/5005/5006/5007/5008/5009/5010/5011/5300'
		cMens6  := "  - Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfeasl@eurofinslatam.com"
	else
		cMens6 := ""
	Endif

	cMsg += _CRLF

    If cEnvFor == "S"
        cMsg += "Prezado fornecedor," + _CRLF
        cMsg += _CRLF
    Else
        cMsg += "Prezado," + _CRLF
        cMsg += "Por gentileza, poderia seguir com a formalização para o fornecedor?" + _CRLF
        cMsg += "**Enviar todos os anexos." + _CRLF + _CRLF
    EndIf

	cMsg += "Você está recebendo o Pedido de Compra aprovado número "+Alltrim(cNumPC)+" anexo."+_CRLF+_CRLF
	cMsg += "Por favor leia com atenção o nosso Pedido de Compra e Documentos adicionais, qualquer divergência deve ser comunicado."+_CRLF+_CRLF
	cMsg += "Lembramos que a Nota Fiscal deve ser espelho do nosso Pedido de compra, ou seja, não aceitamos divergências de valores, prazo de pagamento, dados de faturamento e quantidades."+_CRLF+_CRLF
	cMsg += "Seguem demais Condições: " + _CRLF
	cMsg += "1- Confirmar a data de entrega que consta no Pedido de Compra em até 24 horas. Qualquer alteração na data de entrega deve ser comunicado previamente." + _CRLF
	cMsg += "2- Certificados de Análise devem acompanhar o produto no ato da entrega." + _CRLF
	cMsg += "3- É necessário constar o número do Pedido de Compra na Nota Fiscal." + _CRLF
	cMsg += "4- Favor emitir a nota fiscal de acordo com o pedido de compra. As informações contidas nesse documento devem ser espelho da nota fiscal: item, preço, quantidade e CNPJ." + _CRLF
	cMsg += "5- Não recebemos Nota Fiscal de Serviço com emissão após dia 25 de cada mês." + _CRLF
	cMsg += "6- Não Recebemos materiais nos últimos 3 dias do mês devido Fechamento." + _CRLF
	cMsg += "7- Mercadorias serão aceitas somente até 10 dias após data da emissão da NF (tempo suficiente para transporte entre estados), após esse prazo, NFs e material serão recusados pelo recebimento." + _CRLF
	cMsg += "8- As entregas nos estados de PE e RS quando iniciada no estado de SP serão aceitas somente até 15 dias após data da emissão da NF." + _CRLF+ _CRLF
	cMsg += "9- Mercadorias com data de validade menor do que 70% da vida útil será rejeitada pelo Recebimento." + _CRLF
	cMsg += "10- Atenção a política de pagamento do Grupo encaminhado em anexo." + _CRLF
	cMsg += "11- Conforme determinação da legislação vigente do ICMS, por gentileza enviar os arquivos XML para o e-mail nfspecialtests@eurofinslatam." + _CRLF

	cMsg += AllTrim(cMens6)+ _CRLF
	cMsg += "Solicitamos extrema atenção a estas determinações, a fim de evitarmos problemas no recebimento fiscal e transtornos referente ao pagamento da nota fiscal." + _CRLF


    If !IsInCallStack("U_ENVPC") .and. !IsInCallStack("U_NewEnvPC") .and. !IsInCallStack("U_SchedEnvPC")
		lCont := U_MyE_EMail(cAnexos,cTitJan,cAssunto,cMsg,.F.,cPara)  //(cArquivo,cTitulo,cSubject,cBody,lShedule,cTo,cCC)
	Else
		//U_SndMail(,UsrFullName(cIDComp)+"<"+UsrRetMail(cIdComp)+">",,Trim(cPara)+";"+UsrRetMail(cIdComp),,,cAssunto,cMsg,cAnexos)//SndMail(cSmtp,cConta,cSenha,cDest,cCopia,cBlindC,cAssunto,cTexto,cAnexo,lAut)
        If !IsInCallStack("U_SchedEnvPC") .AND. !IsInCallStack("U_ENVPC") 
            cDe := alltrim(UsrFullName(RetCodUsr()))+"<"+alltrim(UsrRetMail(RetCodUsr()))+">"
        Else
            cDe := GetMV("MV_RELACNT")
        EndIf

        If !Empty(cEmComp)
            cDe := cEmComp
        EndIf

        If !alltrim(lower(UsrRetMail(RetCodUsr()))) $ cPara .and. IsInCallStack("U_SchedEnvPC")
            cPara += ";"+alltrim(UsrRetMail(RetCodUsr()))
        EndIf
        lCont := U_SndMail(,cDe,,Trim(cPara),,,cAssunto,cMsg,cAnexos)//SndMail(cSmtp,cConta,cSenha,cDest,cCopia,cBlindC,cAssunto,cTexto,cAnexo,lAut)
		//U_SndMail(,,,cEmail,,cBlindC,aTitulos[i],cHtml,cArquivo)
		If IsInCallStack("U_ENVPC")
            lCont  := .T.
        EndIf
	Endif

	If lCont
		ProcLogIni( {} , "MATA121" , cNumPC , @cIdCV8 )
		ProcLogAtu( "INICIO" , "Envio do pedido de compra por e-mail" , , , .T.)
		//ProcLogAtu( "MENSAGEM" , "Envio do pedido de compra por e-mail" , cTexto , , .T.)
		ProcLogAtu( "FIM" , "Envio do pedido de compra por e-mail" , , , .T.)

		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial("SC7")+cNumPC))
		While !SC7->(Eof()) .and. SC7->C7_FILIAL==xFilial("SC7") .and. SC7->C7_NUM==cNumPC
			RecLock("SC7",.F.)
			SC7->C7_ZZMAIL := "S"
			SC7->C7_ZZDTEM := MsDate()
			SC7->C7_ZZIDCV8:= cIdCV8
			MsUnlock()
			SC7->(dbSkip())
		Enddo
	Endif

	RestArea(aAreaAtual)

Return(lCont)


Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

	Local aArea    := GetArea()
	Local aAreaSC7 := SC7->(GetArea())
	Local cValid   := ""
	Local nPosRef  := 0
	Local nItem    := 0
	Local cItemDe  := IIf(cItem==Nil,'',cItem)
	Local cItemAte := IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
	Local cRefCols := ''
	DEFAULT cSequen := ""
	DEFAULT cFiltro := ""

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
		While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

			// Nao processar os Impostos se o item possuir residuo eliminado
/*			If !&cFiltro
				dbSelectArea('SC7')
				dbSkip()
				Loop
			EndIf*/

			// Inicia a Carga do item nas funcoes MATXFIS
			nItem++
			MaFisIniLoad(nItem)
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek('SC7')
			While !EOF() .AND. (X3_ARQUIVO == 'SC7')
				cValid    := StrTran(UPPER(SX3->X3_VALID)," ","")
				cValid    := StrTran(cValid,"'",'"')
				If "MAFISREF" $ cValid
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
					// Carrega os valores direto do SC7.
					if !Trim(SX3->X3_CAMPO) $ "C7_OPER"
						MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
					EndIf
				EndIf
				dbSkip()
			End
			MaFisEndLoad(nItem,2)
			dbSelectArea('SC7')
			dbSkip()
		End
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.
