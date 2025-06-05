#include "protheus.ch"
#include 'totvs.ch'
#include 'fileio.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ InsPVenda   ºAutor  ³ Marcos Candido     º Data ³ 25/04/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa que fara a importacao das informacoes do eLims    º±±
±±º          ³ para o Microsiga gerando os pedidos de venda.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*/{Protheus.doc} InsPVenda
Importacao das informacoes do eLims para o Protheus gerando os pedidos de venda.
@author Marcos Candido
@since 04/01/2018
/*/
User Function InsPVenda()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nOpt   := 0
	Local cDiret := Space(40)
	Local oDlg, oImport, oPath, oBtBrw, oBtOk, oBtCan
	Local cMascara := '*.TXT | *.TXT |'
	Local cTituloJ := 'Arquivo Texto'
	Local nMascPad := 1
	Local cDirIni  := 'C:\'
	Local lSavOp   := .T.   /*.F. = Salva || .T. = Abre*/
	Local nOpcoes  := nOR(GETF_LOCALHARD,GETF_LOCALFLOPPY,GETF_NETWORKDRIVE)
	Local lArvore  := .F. /*.T. = apresenta o arvore do servidor || .F. = não apresenta*/

	Private nPrecVen := 0
	Private lLoop    := .F.
	Private lPreChk  := .F.
	Private aDados   := {}

	//If SM0->M0_CODIGO # '01'
	//	Aviso(OemToAnsi('Atenção!!!'), OemToAnsi('Esta rotina só pode ser executada na empresa Eurofins.') , {'Sair'})
	//	Return
	//Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de interface com o usuario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Define MsDialog oDlg Title OemToAnsi("Leitura de Arquivo Texto") From 00,00 to 175,480 Pixel

	@ 00.4,01 To 04.55,25
	@ 01,03 Say OemToansi("Este programa irá ler o conteúdo de um arquivo com a extensão TXT ")
	@ 02,03 Say OemToansi("contendo informações disponibilizadas pelo sistema eLIMS FGS, e em ")
	@ 03,03 Say OemToansi("seguida fará a inclusão dos Pedidos de Venda.")
	@ 05.75,06 Say OemToansi("Diretório:")
	@ 70,047 MsGet oPath Var cDiret Size 150,08 of oDlg Pixel

	Define sButton oBtOk  From 005,208 Type 1  Action (nOpt := 1, oDlg:End()) Enable of oDlg Pixel
	Define sButton oBtCan From 020,208 Type 2  Action (nOpt := 0, oDlg:End()) Enable of oDlg Pixel
	Define sButton oBtBrw From 068,010 Type 14 Action (cDiret := PegaDirArq(cMascara , cTituloJ , nMascPad , cDirIni , lSavOp , nOpcoes , lArvore), oPath:Refresh()) Enable of oDlg Pixel

	Activate MsDialog oDlg Center

	cDiret := Alltrim(cDiret)

	If nOpt == 1
		If Empty(cDiret)
			IW_MsgBox(OemToAnsi("Nome inválido de arquivo. Verifique.") , OemToAnsi("Atenção") , "ALERT")
		ElseIf !File(cDiret)
			IW_MsgBox(OemToAnsi("Diretório ou arquivo não encontrado. Verifique.") , OemToAnsi("Atenção") , "ALERT")
		Else
			If IW_MsgBox("Deseja executar uma pré-validação dos dados?" , "Sugestão" , "YESNO")
				lPreChk := .T.
			Endif
			Processa({|| OkLeCSV(cDiret) },OemToAnsi("Processando Arquivo..."))
		Endif
	Endif

	If lLoop
		Processa({|| OkLeCSV(cDiret) },OemToAnsi("Processando Arquivo..."))
	Endif

	ChkFile("SC5")
	ChkFile("SC6")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PegaDirArq  ºAutor  ³ Marcos Candido     º Data ³          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe caminhos disponveis para usuario escolher o local    º±±
±±º          ³ ondo programa encontrara o arquivo a ser processado.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PegaDirArq(cMascara , cTituloJ , nMascPad , cDirIni , lSavOp , nOpcoes , lArvore)
	Local cDir := Space(40)
	cDir := cGetFile(cMascara , cTituloJ , nMascPad , cDirIni , lSavOp , nOpcoes , lArvore)
Return(cDir)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OkLeCSV  ºAutor  ³ Marcos Candido     º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Esta rotina faz a leitura do arquivo Texto, separa seus   º±±
±±º          ³  dados, os prepara para serem gravados fazendo as devidas  º±±
±±º          ³  consistencias. E se encontrar algum erro ele sera exibi-  º±±
±±º          ³  do em um relatorio, caso contrario serao utilizados na    º±±
±±º          ³  geracao do pedido de venda.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OkLeCSV(cRetArq)

	Local aReadCSV   := {}
	Local cLineRead  := "" , lFirst := .T.
	Local aTamPrc    := TamSX3("C6_PRCVEN")
	Local aTamQtd    := TamSX3("C6_QTDVEN")
	Local aTamTot    := TamSX3("C6_VALOR")
	Local aCabec     := {}
	Local aItens     := {}
	Local cItem      := "0"
	Local aTotItens  := {}
	Local aErroLog   := {}
	Local nLinha     := 0
	Local lOk        := .T.
	Local dDataAtual := dDataBase
	Local cAglut     := ""
	Local cTransp    := SuperGetMv( "MV_ZZIMPTR" , .F. , " " ,  )
	Local cResp      := SuperGetMv( "MV_ZZIMPRL" , .F. , " " ,  )
	Local cCliEst    := ""
	Local lTesInt	 := .F.
	Local cOldFilial := cFilAnt
	Local lContac	 := .T.
	Local lAuxCont	 := .T.
	Local lContinua	 := .T.
	Local cContabil  := ""
	Local lExistZZG  := .T.
	Local nLts		 := 0
	Local a  		 := 0
	Local t  		 := 0
	Local cEstCli	 := ""
    Local cTipoCli   := ""
    Local cNumMedic  := ""     
    Local cNumCert   := ""
    Local cNomeFatur := ""
    Local cNomeContat:= ""
    Local cMenNota   := ""
    Local dDataPed   
    Local dDataRec   := ""
    Local cNumOS1    := ""
    Local cNumOS2    := ""
    Local cNumOS3    := ""
    Local dDtEntrega := cTod("  /  /    ")
    Local dEmissao   := cTod("  /  /    ")
    Local nMoeda     := 0
    Local cCliente   := ""
    Local cProduto   := ""
    Local cDescric   := ""
    Local cOrigAn    := ""
    Local cRevCert	 := ""
    Local cCodAm	 := ""
    Local nPrecVen	 := 0
    Local nTotal	 := 0
    Local cUMedida	 := ""
    Local nQtdVen	 := 0
    Local cTes	 	 := ""
	Local cTesND 	 := SuperGetMv("ZZ_TESND",.F.,"9N0")
    Local cCFOP	 	 := ""
    Local cArmaz	 := ""
    Local cPedCli	 := ""
    Local cLjCli	 := ""
    Local cClasFis	 := ""
    Local cCodISS	 := ""


	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.
	Private _zzDebug	:= .F.

	cGravFil := xFilial("SC5")

	If lPreChk .and. lLoop
		lPreChk := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se lLoop for FALSO, trata-se do primeiro  ³
	//³ processamento. Se for VERDADEIRO, eh o    ³
	//³ segundo e portanto nao precisa ler o      ³
	//³ arquivo de novo, pois os dados ja estao   ³
	//³ no array aDados.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lLoop
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Abre arquivo e o le por completo          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		fT_fUse(cRetArq)

		ProcRegua(fT_fLastRec())

		fT_fGotop()

		While !fT_fEof()

			IncProc(OemToAnsi("Lendo arquivo CSV..."))

			cLineRead := fT_fReadLn()
			If !Empty(cLineRead)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ para nao considerar conteudo da primeira linha, pois eh cabecalho   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lFirst
					aadd( aReadCSV , cLineRead )
				Else
					lFirst := .F.
				Endif
			Endif
			fT_fSkip()

		Enddo

		fT_fUse()

		ProcRegua(Len(aReadCSV))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Separa os dados                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For a:=1 to Len(aReadCSV)

			IncProc(OemToAnsi("Separando dados..."))

			lOk  := .T.
			aPos := {}
			cLin := aReadCSV[a]

			For nLts:=1 to Len(cLin)
				If SubStr(cLin,nLts,1) == ';'
					Aadd(aPos,nLts)
				EndIf
			Next

			if len(aPos) < 33
				MsgStop("Erro no layout do arquivo. Linha: "+Str(a)+chr(13)+cLin)
				Return
			endif

			cCodCli			:= SubStr(Alltrim(cLin),1		 	,(aPos[1]-1))           //RecipientClientCode
			cLojCli			:= SubStr(Alltrim(cLin),(aPos[1]+1),(aPos[2]-1)-aPos[1])   	//RecipientLojaCode
			cNomeCli        := SubStr(Alltrim(cLin),(aPos[2]+1),(aPos[3]-1)-aPos[2])   	//RecipientInternalName
			cContCli        := SubStr(Alltrim(cLin),(aPos[3]+1),(aPos[4]-1)-aPos[3])   	//RecipientContactName
			cEmailNf        := SubStr(Alltrim(cLin),(aPos[4]+1),(aPos[5]-1)-aPos[4])	//RecipientEmail
			cCodCliEnt      := SubStr(Alltrim(cLin),(aPos[5]+1),(aPos[6]-1)-aPos[5])	//SampleSenderClientCode
			cLojCliEnt		:= SubStr(Alltrim(cLin),(aPos[6]+1),(aPos[7]-1)-aPos[6])	//SampleSenderLojaCode
			cNomAm			:= SubStr(Alltrim(cLin),(aPos[7]+1),(aPos[8]-1)-aPos[7])	//SampleSenderInternalName
			cNomCont        := SubStr(Alltrim(cLin),(aPos[8]+1),(aPos[9]-1)-aPos[8])	//SampleSenderContactName
			cCodProd		:= SubStr(Alltrim(cLin),(aPos[9]+1),(aPos[10]-1)-aPos[9])	//Product Code
			cDescrProd		:= SubStr(Alltrim(cLin),(aPos[10]+1),(aPos[11]-1)-aPos[10])	//InvoiceLineText
			cPrcTotal		:= SubStr(Alltrim(cLin),(aPos[11]+1),(aPos[12]-1)-aPos[11])	//Price
			cPrecoUnit		:= SubStr(Alltrim(cLin),(aPos[12]+1),(aPos[13]-1)-aPos[12]) //Unit Price
			cDiscount       := SubStr(Alltrim(cLin),(aPos[13]+1),(aPos[14]-1)-aPos[13])	//Discount
			cQuant			:= SubStr(Alltrim(cLin),(aPos[14]+1),(aPos[15]-1)-aPos[14])	//NumberOfUnits
			cDivDept        := SubStr(Alltrim(cLin),(aPos[15]+1),(aPos[16]-1)-aPos[15])	//DepartmentalSplit
			cDepto          := SubStr(Alltrim(cLin),(aPos[16]+1),(aPos[17]-1)-aPos[16])	//vbeiDepartment
			cMoeda			:= SubStr(Alltrim(cLin),(aPos[17]+1),(aPos[18]-1)-aPos[17])	//CurrencyName
			cCondPgto		:= SubStr(Alltrim(cLin),(aPos[18]+1),(aPos[19]-1)-aPos[18])	//PaymentConditions
			cServiceDescrp	:= SubStr(Alltrim(cLin),(aPos[19]+1),(aPos[20]-1)-aPos[19])	//ServiceDescription
			cTypeInvoice	:= SubStr(Alltrim(cLin),(aPos[20]+1),(aPos[21]-1)-aPos[20])	//InvoiceType
			cNotaCancelada	:= SubStr(Alltrim(cLin),(aPos[21]+1),(aPos[22]-1)-aPos[21])	//CancellationOfInvoice
			cDataEmissao	:= SubStr(Alltrim(cLin),(aPos[22]+1),(aPos[23]-1)-aPos[22])	//ServiceDescriptionDate
			cNPedCliente	:= SubStr(Alltrim(cLin),(aPos[23]+1),(aPos[24]-1)-aPos[23])	//ClientPurchaseOrderNo
			cIncluidoPor	:= SubStr(Alltrim(cLin),(aPos[24]+1),(aPos[25]-1)-aPos[24])	//RegisteredBy
			cTpMovProd      := SubStr(Alltrim(cLin),(aPos[25]+1),(aPos[26]-1)-aPos[25])	//TypeOfProductMovement
			cNCertNAmost	:= SubStr(Alltrim(cLin),(aPos[26]+1),(aPos[27]-1)-aPos[26])	//SampleNumber
			cCodAm          := SubStr(Alltrim(cLin),(aPos[27]+1),(aPos[28]-1)-aPos[27])	//SampleData
            //Renata Pereira solicitou a voltar a importar BatchCommentForInvoice novamente em 02/08/2024
			cComents   		:= SubStr(Alltrim(cLin),(aPos[28]+1),(aPos[29]-1)-aPos[28])	//BatchCommentForInvoice
			cDtPedCli       := SubStr(Alltrim(cLin),(aPos[29]+1),(aPos[30]-1)-aPos[29])	//clientPurchaseOrderDate
			cDTRectoPed     := SubStr(Alltrim(cLin),(aPos[30]+1),(aPos[31]-1)-aPos[30])	//ReceptionDate
			cGMOMatrix      := SubStr(Alltrim(cLin),(aPos[31]+1),(aPos[32]-1)-aPos[31])	//GMO-Matrix
			//		cGMOMatrix      := SubStr(Alltrim(cLin),(aPos[31]+1),Len(cLin)-aPos[31])	//GMO-Matrix
			cVend			:= SubStr(Alltrim(cLin),(aPos[32]+1),(aPos[33]-1)-aPos[32])	//Vendedor
			//Acrescentado a validação da coluna a pedido do Andre Malimpensa 27/06/2022
			//a Coluna ClientSamplecode irá concatenar dados com a coluna SampleData, só é necessário validar
			//se a coluna ta preenchida porque nem todas filiais irão ter essa coluna.
			if len(aPos) >= 34 //ClientSamplecode
				if Empty(cCodAm)
					cCodAm := "Cód. Cliente = "+SubStr(Alltrim(cLin),(aPos[33]+1),(aPos[34]-1)-aPos[33])
				else
					if SubStr(Alltrim(cLin),(aPos[33]+1),(aPos[34]-1)-aPos[33]) $ cCodAm
						if SubStr(cCodAm,1,15) == "Cód. Cliente = " .or. SubStr(cCodAm,1,15) == "Cod. Cliente = "
							cCodAm += " - "+SubStr(Alltrim(cLin),(aPos[33]+1),(aPos[34]-1)-aPos[33])
						else
							cCodAm := "Cód. Cliente = "+SubStr(Alltrim(cLin),(aPos[33]+1),(aPos[34]-1)-aPos[33])+iif(!Empty(cCodAm)," - "+cCodAm,"")
						endif
					else
						if SubStr(cCodAm,1,15) == "Cód. Cliente = " .or. SubStr(cCodAm,1,15) == "Cod. Cliente = "
							cCodAm += " - "+SubStr(Alltrim(cLin),(aPos[33]+1),(aPos[34]-1)-aPos[33])
						else
							cCodAm := "Cód. Cliente = "+SubStr(Alltrim(cLin),(aPos[33]+1),(aPos[34]-1)-aPos[33])+iif(!Empty(cCodAm)," - "+cCodAm,"")
						endif
					endif
				endif
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajuste em alguns campos                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodProd     := Upper(cCodProd)
			cNCertNAmost := Alltrim(cNCertNAmost)
			cCodAm       := Alltrim(cCodAm)
			cComents   	 := Alltrim(StrTran(cComents,";",""))+Space(1)
			cEmailNf     := StrTran(cEmailNf,",",";")
			cVendPro	 := RetElims(cVend)

			/*If Substr(cCodProd,1,3) $ "GBT/GBS"
			cCodProd := "IC "+cCodProd
			ElseIf Substr(cCodProd,1,5) $ "PGBZ1/PGBZ2/PGBZ3/PGBR4"
			cCodProd := "IC "+cCodProd
			ElseIf (Substr(cCodProd,1,2) # "GB" .and.;
			Substr(cCodProd,1,1) # "#" .and.;
			Substr(cCodProd,1,2) # "UM" .and.;
			Substr(cCodProd,1,3) # "PGB")
			cCodProd := "IC "+cCodProd
			Endif*/
			cCodProd   += Space(15-Len(cCodProd))
			cPrecoUnit := StrZero(Val(cPrecoUnit),aTamPrc[1],aTamPrc[2])
			cQuant     := StrZero(Val(cQuant),aTamQtd[1],aTamQtd[2])
			cPrcTotal  := StrZero(Val(cPrcTotal),aTamTot[1],aTamTot[2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica qual a origem do TXT importado        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Alterado por Tiago Badoco - TOTVS IP
			/*
			"REC-"	= 0101
			"BS-"	= 0500
			*/

			cFilAnt := chkOrigem(cNPedCliente)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste vendedor                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cVendPro) .and. !Empty(cVend)
				aadd(aErroLog , "Vendedor '"+cVend+"' não encontrado no cadastro."+;
				"Verifique, pois o registro foi desprezado.")
				lOk := .F.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste para verificar se informacao ja consta cadastrada    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SC5->(dbOrderNickName("SC5NCERT"))
			//If SC5->(dbSeek(xFilial("SC5")+cNCertNAmost,.T.))
			If SC5->(dbSeek(cGravFil+cNCertNAmost,.T.))
				//aadd(aErroLog , "O Certificado Nº "+cNCertNAmost+" se encontra no pedido nº "+;
				//SC5->C5_NUM)//+". O registro foi desprezado.")
				Alert("O Certificado Nº "+cNCertNAmost+" se encontra no pedido nº "+;
				SC5->C5_NUM+".","Verifique!")//+". O registro foi desprezado.")
				//lOk := .F.
			Endif

			cArmaz := "01"
			SB1->(dbSetOrder(1))
			If !SB1->(dbSeek(xFilial("SB1")+cCodProd))
				aadd(aErroLog , "O código do produto "+cCodProd+" não foi encontrado no cadastro."+;
				"Verifique, pois o registro foi desprezado.")
				lOk := .F.
			Else
				cArmaz := SB1->B1_LOCPAD
				If SB1->B1_MSBLQL == "1"
					aadd(aErroLog , "O código do produto "+cCodProd+" encontra-se bloqueado."+;
					"Verifique, pois o registro foi desprezado.")
					lOk := .F.
				Endif
			Endif

			If lOk
				//Retirado a validação abaixo a pedido da Renata Pereira pois isso sempre é ignorado e importado mesmo com a mensagem abaixo
				//Régis Ferreira 10/04/2024
				If Val(cPrecoUnit) <= 0 .or. Val(cPrecoUnit) == 0.01
					//aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto foi desprezada, pois o preço é menor ou igual a zero."+;
					//" Não é possível incluir este item.")
					lOk := .F.
				Endif
				
				//Retirado a validação abaixo a pedido da Renata Pereira pois isso sempre é ignorado e importado mesmo com a mensagem abaixo
				//Régis Ferreira 10/04/2024
				If Val(cPrecoUnit) == 0.01
					//aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto foi desprezada, pois o preço é igual a $ 0,01."+;
					//" Não é possível incluir este item.")
					lOk := .F.
				Endif

				If Val(cQuant) <= 0
					aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto foi desprezada, pois a quantidade é menor ou igual a zero."+;
					" Não é possível incluir este item.")
					lOk := .F.
				Endif

				//Retirado a validação abaixo a pedido da Renata Pereira pois isso sempre é ignorado e importado mesmo com a mensagem abaixo
				//Régis Ferreira 10/04/2024
				If Val(cPrcTotal) <= 0
					//aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto foi desprezada, pois o valor total é menor ou igual a zero."+;
					//" Não é possível incluir este item.")
					lOk := .F.
				Endif

				//Retirado a validação abaixo a pedido da Renata Pereira pois isso sempre é ignorado e importado mesmo com a mensagem abaixo
				//Régis Ferreira 10/04/2024
				If Val(cPrcTotal) == 0.01
					//aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto foi desprezada, pois o valor total é igual a $ 0,01."+;
					//" Não é possível incluir este item.")
					lOk := .F.
				Endif
			Endif

			If CtoD(cDtPedCli) > StoD(cDataEmissao)
				aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto foi desprezada, pois a data indicada para o pedido do cliente é maior que a data de login do pedido.")
				aadd(aErroLog , "Não é possível incluir este item.")
				lOk := .F.
			Endif
			If CtoD(cDTRectoPed) > StoD(cDataEmissao)
				aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto foi desprezada, pois a data indicada para a recepção do pedido é maior que a data de login do pedido.")
				aadd(aErroLog , "Não é possível incluir este item.")
				lOk := .F.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se origem da amostra eh a Filial Recife e se o   ³
			//³ produto esta cadastrado na tabela SBZ (Indic. de Produtos)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*If lOk
			//			cFilAgora := cFilAnt
			//			cFilAnt := cGravFil

			SBZ->(dbSetOrder(1))
			If !SBZ->(dbSeek(cGravFil+cCodProd))

			aProdSBZ := {}
			aProdSBZ := {	{"BZ_COD"	 , cCodProd	,	NIL},;
			{"BZ_LOCPAD" , cArmaz	,	NIL}}

			lMsErroAuto := .F.

			Begin Transaction

			//MSExecAuto({|x,y| MATA018(x,y)},aProdSBZ,3)
			MSExecAuto({|v,x| MATA018(v,x)},aProdSBZ,3)

			If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			Break
			Endif

			End Transaction

			Endif
			If !SBZ->(dbSeek(cGravFil+cCodProd))
			aadd(aErroLog , "O código do produto "+cCodProd+" não existe no cadastro de Indicador de Produtos. "+;
			"Verifique, pois o registro foi desprezado.")
			lOk := .F.
			Endif

			//			cFilAnt := cFilAgora

			Endif*/

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o tipo de Movimento for igual a 07 que indica que o cliente eh de EXPORTACAO, uso a mesma regra que a da analise normal. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//If cTpMovProd == '07'
			//	cTpMovProd := '01'
			//Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desabilitado em 09/05/14 por Marcos Candido , pois em conversa com a Francielle verificamos que o correto eh usar a TES     ³
			//³ indicada no cadasto da TES Inteligente.                                                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplicada nova verificacao em 01/12/14 em que verifico se o cliente eh nacional mas o registro lido veio com a indentificacao ³
			//³ de exportacao (07) . Nesse caso eu mudo para '01' . E se o cliente for estrangeiro e o registro veio com a identificacao     ³
			//³ igual a 01 , eu mudo para 07. A Francielle me ajudou nessa :)                                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA1->(dbSetOrder(1))
			//Tratativa alterada após nova regra desenvolvida abaixo de acordo com regra passada pelo Analista Leandro Gomes
			If SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli))
				cCliEst := SA1->A1_EST
			Endif
			/*
			If cTpMovProd == '07' .and. SA1->A1_EST <> 'EX'
			cTpMovProd := '01'
			ElseIf cTpMovProd == '01' .and. SA1->A1_EST == 'EX'
			cTpMovProd := '07'
			ElseIf cTpMovProd == '02' .and. SA1->A1_EST == 'EX'
			cTpMovProd := '07'
			Endif
			Endif*/

			If cTpMovProd == '01' .or. cTpMovProd == '02' .or. cTpMovProd == '07'
				cTpMovProd := '54'
			Else
                if cTpMovProd <> 'ND'
                    //Incluir erro na listagem de inconsistencias
                    aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto possui o TypeOfProductMovement diferente de 01, 02 ou 07."+;
                    " Não é possível incluir este item.")
                    lOk := .F.
                endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste moeda  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lOk
				If UPPER(cMoeda) $ "BRAZIL"
					cMoeda := "1"
				ElseIf UPPER(cMoeda) $ "EURO"
					cMoeda := "6"
				ElseIf UPPER(cMoeda) $ "U.S. DOLLARS"
					cMoeda := "4"
				Else
					cMoeda := "1"
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considerar somente os pedidos classificados como Standard ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				if Alltrim(Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_CONTA")) $ Alltrim(GetMv("ZZ_CONTINT"))
					cContabil := "ZZZZZZZZZZ"
				else
					cContabil := Alltrim(Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_CONTA"))
				endif

				If Upper(Substr(cTypeInvoice,1,1))=="S"

					aadd(aDados , { cCodCli,	cLojCli,		cCodCliEnt, 	cLojCliEnt, 	cCodProd,;
					cDescrProd, cPrecoUnit,		cQuant,			cPrcTotal,    	cMoeda,;
					cCondPgto,	cServiceDescrp, cTypeInvoice,	cNotaCancelada, cDataEmissao,;
					cNPedCliente,cIncluidoPor, 	cNCertNAmost, 	cCodAm, 		cTpMovProd,;
					cContCli,	cNomCont,		cComents, 	  	cEmailNf,		cDiscount,;
					cDtPedCli , cDTRectoPed , 	cGravFil, 		"", 			"",cVendPro,;
					cContabil })
				Else
					aadd(aErroLog , "A linha "+StrZero(a+1,4)+" do arquivo texto foi desprezada, pois o tipo de pedido é "+cTypeInvoice+".")
					aadd(aErroLog , "Não é possivel incluir um pedido de venda.")
				Endif

			Endif
		Next

		aadd(aDados , {	"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
		"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
		"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,	"ZZZ" ,;
		"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
		"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
		"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
		"ZZZ" , "ZZZ" , "ZZZ" })
		aDados := aSort(aDados,,, {|x,y| x[18]+x[32] < y[18]+y[32]} )

	Endif

	cNomeArq := cRetArq
	While At("\",cNomeArq) > 0
		cNomeArq := Substr(cNomeArq,At("\",cNomeArq)+1)
	Enddo

	If Len(aDados) > 1

		ProcRegua(Len(aDados))

		For t:=1 to Len(aDados)

			If lPreChk
				IncProc("Validando informações...")
			Else
				IncProc("Gerando Pedidos de Venda...")
			Endif

			lCont := .T.
			//Varivável para controlar se é intercompany ou não?
			lContac := .T.

			//Valida se existe registro na tabela ZZG
			//Se existir, tem que fazer o controle de conta contábil intercompany parâmetro ZZ_CONTINT
			lExistZZG := ExistZZG(aDados[t][1],aDados[t][2])

			if lExistZZG
				if  Alltrim(Posicione("SB1",1,xFilial("SB1")+aDados[t][5],"B1_CONTA")) $ Alltrim(GetMv("ZZ_CONTINT"))
					lContac := .F.
				endif
				if t == 1
					lAuxCont := lContac
				endif

				if lAuxCont == lContac
					lContinua := .T.
				else
					lContinua := .F.
				endif
				lAuxCont := lContac
			endif

			//Caso o número do certificado seja diferente ou é pedido intercompany, separa os pedidos
			If cAglut # aDados[t][18] .or. !lContinua

				If !lPreChk

					If Len(aCabec) > 0 .and. Len(aTotItens) > 0

						lMsErroAuto := .F.

						Begin Transaction

							aCabec 		:= FwVetByDic(aCabec, 	"SC5" , .F. )
							aTotItens 	:= FwVetByDic(aTotItens, 	"SC6" , .T. )

							MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aTotItens,3)

							If lMsErroAuto .or. _zzDebug
								MostraErro()
								DisarmTransaction()
								Break
							Endif

						End Transaction

						aCabec    := {}
						aTotItens := {}
						aItens    := {}

					Endif

				Else

					aCabec    := {}
					aTotItens := {}
					aItens    := {}

				Endif

				If aDados[t][18] == "ZZZ"
					Exit
				Else
					cAglut := aDados[t][18]
					cItem  := "0"
				Endif

				dbSelectArea("SA1")
				dbSetOrder(1)
				If dbSeek(xFilial("SA1")+aDados[t][1]+aDados[t][2])
					If SA1->A1_MSBLQL == "1"
						aadd(aErroLog , "O cliente "+aDados[t][1]+"/"+aDados[t][2]+" está bloqueado para uso. "+;
						"Verifique, pois o registro foi desprezado.")
						lCont := .F.
						cAglut := ""
					ElseIf SA1->A1_ZZMOEDA <> Val(aDados[t][10])
						aadd(aErroLog , "A moeda indicada no cadastro do cliente "+aDados[t][1]+"/"+aDados[t][2]+" é diferente da que foi indica no arquivo TXT. "+;
						"Verifique, pois o registro foi desprezado.")
						lCont := .F.
						cAglut := ""
					Else
						cTipoCli := SA1->A1_TIPO
						cEstCli  := SA1->A1_EST
						cCliente := aDados[t][1]
						cLjCli   := aDados[t][2]
						cCondPag := SA1->A1_COND
						if !lContac
							cCondPag := GetCond(cCondPag,cCliente,cLjCli)
						endif
						cNomeFant := SA1->A1_NREDUZ
						cMunCli   := SA1->A1_MUN
						cVend1    := aDados[t,31] //IIF(!Empty(SA1->A1_VEND) , SA1->A1_VEND , SuperGetMv( "MV_ZZIMPVD" , .F. , " " ,  ))
					Endif
				Else
					aadd(aErroLog , "O código de cliente "+aDados[t][1]+"/"+aDados[t][2]+" não foi encontrado no cadastro."+;
					"Verifique, pois o registro foi desprezado.")
					lCont := .F.
					cAglut := ""
				Endif

				If lCont
					If dbSeek(xFilial("SA1")+aDados[t][3]+aDados[t][4])
						If SA1->A1_MSBLQL == "1"
							aadd(aErroLog , "O cliente "+aDados[t][3]+"/"+aDados[t][4]+" está bloqueado para uso."+;
							"Verifique, pois o registro foi desprezado.")
							lCont := .F.
							cAglut := ""
						Else
							cCliLaud := aDados[t][3]
							cLjLaudo := aDados[t][4]
						Endif
					Else
						aadd(aErroLog , "O código de cliente "+aDados[t][3]+"/"+aDados[t][4]+" não foi encontrado no cadastro."+;
						"Verifique, pois o registro foi desprezado.")
						lCont := .F.
						cAglut := ""
					Endif
				Endif

				If lCont

					//dDtEntrega 	:= DataValida(StoD(aDados[t][15])+5,.T.)
					dDtEntrega 	:= StoD(aDados[t][15])
					dEmissao   	:= StoD(aDados[t][15])
					dDataBase  	:= dEmissao
					nMoeda     	:= Val(aDados[t][10])
					cUsuIncl   	:= aDados[t][17]
					cNumMedic  	:= aDados[t][12]
					cNumCert   	:= aDados[t][18]
					cNomeFatur 	:= aDados[t][21]
					cNomeContat	:= aDados[t][22]
					cMenNota   	:= aDados[t][23]
					dDataPed    := CtoD(aDados[t][26])
					dDataRec    := CtoD(aDados[t][27])
					cNumOS1     := Substr(aDados[t][14],1,990)
					cNumOS2     := Substr(aDados[t][14],991,990)
					cNumOS3     := Substr(aDados[t][14],1981,990)

					//				cGravFil    := aDados[t][28]
					//cGravFil    := SM0->M0_CODFIL
					//				If cFilAnt <> cGravFil
					//					cFilAnt := cGravFil
					//				Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Para efeito da apuracao do ISS, informo :                ³
					//³  * Codigo do fornecedor para qual sera recolhido o ISS;  ³
					//³  * Estado onde foi prestado o servico;                   ³
					//³  * Codigo do municipio onde foi prestado o servico;      ³
					//³  * Descricao do municipio onde foi prestado o servico.   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cFornISS := GetMv("MV_FPADISS")
					aFornISS := StrTokArr(cFornISS,";")
					cFornISS := PadR(aFornISS[1],TamSX3("A2_COD")[1])
					//				If cFilAnt == '01'
					/*If cGravFil == '01'
					cEstPres := 'SP'
					cMunPres := '20509'
					cDescMun := 'INDAIATUBA'
					Else
					cEstPres := 'PE'
					cMunPres := '11606'
					cDescMun := 'RECIFE'
					Endif*/
					cEstPres := RetField('SM0',1,cEmpAnt+cFilAnt,'M0_ESTCOB')
					cMunPres := Substr(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_CODMUN'),3)
					cDescMun := RetField('SM0',1,cEmpAnt+cFilAnt,'M0_CIDCOB')

					If Empty(Rtrim(aDados[t][24]))
						If Empty(SA1->A1_ZZNFMAI)
							cEmailNfe := SA1->A1_EMAIL
						Else
							cEmailNfe := SA1->A1_ZZNFMAI
						Endif
					Else
						cEmailNfe := aDados[t][24]
					Endif

					cFilAnt := chkOrigem(aDados[t][16]) // Numero pedido do cliente

					aCabec := {	{"C5_FILIAL"	, cFilAnt		,	NIL},;
					{"C5_TIPO"		, "N"			,	NIL},;
					{"C5_CLIENTE"	, cCliente		,	NIL},;
					{"C5_LOJACLI"	, cLjCli		,	NIL},;
					{"C5_CLIENT"	, cCliente		,	NIL},;
					{"C5_LOJAENT"	, cLjCli		,	NIL},;
					{"C5_ZZNFANT"	, cNomeFant		,	NIL},;
					{"C5_MUNIC"		, cMunCli		,	NIL},;
					{"C5_ZZCLAUD"	, cCliLaud		,	NIL},;
					{"C5_ZZLLAUD"	, cLjLaudo		,	NIL},;
					{"C5_ZZTIPCE"	, "N"			,	NIL},;
					{"C5_ZZNMEDI"	, cNumMedic		,	NIL},;
					{"C5_ZZNROCE"	, cNumCert		,	NIL},;
					{"C5_ZZTRANS"	, cTransp		,	NIL},;
					{"C5_TIPOCLI"	, cTipoCli		,	NIL},;
					{"C5_CONDPAG"	, cCondPag		,	NIL},;
					{"C5_ZZVEND"	, cVend1		,	NIL},;
					{"C5_ZZDTENT"	, dDtEntrega	,	NIL},;
					{"C5_MOEDA"		, nMoeda		,	NIL},;
					{"C5_TXMOEDA"	, 1				,	NIL},;
					{"C5_ZZTEMPO"	, "P"			,	NIL},;
					{"C5_TIPLIB"	, "2"			,	NIL},;
					{"C5_ZZUSER"	, cUsuIncl		,	NIL},;
					{"C5_ZZUSER2"	, "1"			,	NIL},;
					{"C5_ZZHOMOG"	, "N"			,	NIL},;
					{"C5_TABELA"	, Space(3)		,	NIL},;
					{"C5_TPCARGA"	, "1"			,	NIL},;
					{"C5_ZZDATAP"	, dDataPed 		,	NIL},;
					{"C5_ZZDATAR"	, dDataRec 		,	NIL},;
					{"C5_ZZCON02"	, cNomeFatur	,	NIL},;
					{"C5_ZZCON01"	, cNomeContat	,	NIL},;
					{"C5_ZZOBS"		, cMenNota    	,	NIL},;
					{"C5_ZZNFMAI"	, cEmailNfe     ,	NIL},;
					{"C5_ZZMAICO"	, cEmailNfe     ,	NIL},;
					{"C5_ZZARQ"		, cNomeArq      ,	NIL},;
					{"C5_EMISSAO"	, dEmissao		,	NIL},;
					{"C5_ZZ1NUOS"	, cNumOS1		,	NIL},;
					{"C5_ZZ2NUOS"	, cNumOS2		,	NIL},;
					{"C5_ZZ3NUOS"	, cNumOS3		,	NIL},;
					{"C5_INDPRES"	, '0'			,	NIL},;
					{"C5_ZZCLIRE"	, cCliente		,	NIL},;
					{"C5_ZZLJRET"	, cLjCli		,	NIL},;
					{"C5_FORNISS"	, cFornISS 		,	NIL},;
					{"C5_ESTPRES"	, cEstPres		,	NIL},;
					{"C5_MUNPRES"	, cMunPres		,	NIL},;
					{"C5_DESCMUN"	, cDescMun		,	NIL}}
					//{"C5_MENNOTA"	, cMenNota    	,	NIL},;
					
					//Se for ND, fixa a natureza financeira
					//Régis Ferreira - Totvs IP Jundiaí  10/04/2024
					//Ajuste para Fernada Carelli
					if aDados[t][20] == "ND"
						aadd(aCabec,{"C5_NATUREZ", "0101006", Nil})
					endif
				Endif

			Endif

			If lCont
				aItens   := {}
				cProduto := aDados[t][5]
				cDescric := LTrim(aDados[t][6])
				cOrigAn  := "I"
				cRevCert := "01"
				//nPrecVen := Val(aDados[t][7])	// Preco Unitario
				nQtdVen  := Val(aDados[t][8])	// Quantidade
				nTotal   := Val(aDados[t][9])	// Total
				//nTotal   := NoRound(nQtdVen * nPrecVen,2)
				nPrecVen := nTotal/nQtdVen	// Preco Unitario

				cTes := ""
				If cEstCli == "EX"
					cTes     := Posicione("SFM",4,xFilial("SFM")+aDados[t][20]+cEstCli,"FM_TS")
				endif

				if Empty(cTes)
					cTes     := Posicione("SFM",1,xFilial("SFM")+aDados[t][20],"FM_TS")
				end if

                //Se for ND, fixa a TES
				//Régis Ferreira - Totvs IP Jundiaí  27/02/2024
				//Ajuste para Fernada Carelli
                if aDados[t][20] == "ND" //Pedido do tipo ND
                    cTes := cTesND
                endif

				cPedCli  := StrTran(aDados[t][16],"REC-","")
				//cItem    := StrZero(Len(aTotItens)+1,2)
				cItem    := iif(cItem=="0" , Soma1(StrZero(Val(cItem),2),2) , Soma1(cItem,2) )

				//			IF LEN(Alltrim(aDados[t][19])) > 450
				//				cCodAm   := subs((aDados[t][19]),1,450)
				//			ELSE
				//				cCodam   := Alltrim(aDados[t][19])
				//			ENDIF
				cCodAm   := LTrim(Substr(aDados[t][19],1,450))

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+cProduto))
				cUMedida := SB1->B1_UM
				cArmaz   := SB1->B1_LOCPAD

				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4")+cTes))
				aDadosCfo := {}
				Aadd(aDadosCfo,{"OPERNF","S"})
				Aadd(aDadosCfo,{"TPCLIFOR",cTipoCli})
				Aadd(aDadosCfo,{"UFDEST",cEstCli})
				cCFOP    := MaFisCfo(,SF4->F4_CF,aDadosCfo)
				cClasFis := SB1->B1_ORIGEM+SF4->F4_SITTRIB
				cCodISS  := SB1->B1_CODISS
				/*
				aItens := {	{"C6_FILIAL"	, cFilAnt		,	NIL},;
				{"C6_ITEM"		, cItem			,	NIL},;
				{"C6_PRODUTO"	, cProduto		,	NIL},;
				{"C6_DESCRI"	, cDescric		,	NIL},;
				{"C6_ZZEORIG"	, cOrigAn		,	NIL},;
				{"C6_ZZREVCE"	, cRevCert		,	NIL},;
				{"C6_ZZCODAM"	, cCodAm		,	NIL},;
				{"C6_ZZNMEDI"	, cNumMedic		,	NIL},;
				{"C6_ZZNROCE"	, cNumCert		,	NIL},;
				{"C6_ENTREG"	, dDtEntrega	,	NIL},;
				{"C6_QTDVEN"	, nQtdVen		,	NIL},;
				{"C6_PRCVEN"	, nPrecVen		,	NIL},;
				{"C6_VALOR" 	, nTotal		,	NIL},;
				{"C6_UM"		, cUMedida		,	NIL},;
				{"C6_TES"   	, cTes			,	NIL},;
				{"C6_CF"  		, cCFOP 		,	NIL},;
				{"C6_LOCAL"   	, cArmaz		,	NIL},;
				{"C6_PEDCLI"	, cPedCli		,	NIL},;
				{"C6_CLI"		, cCliente		,	NIL},;
				{"C6_LOJA"		, cLjCli		,	NIL},;
				{"C6_CLASFIS"	, cClasFis		,	NIL},;
				{"C6_CODISS"	, cCodISS		,	NIL},;
				{"C6_ZZOPAPO"	, "N"			,	NIL},;
				{"C6_TPOP"		, "F"			,	NIL},;
				{"C6_ZZCODRE"	, cResp			,	NIL},;
				{"C6_QTDENT"	, 0				,	NIL},;
				{"C6_ZZTPPV"	, "N"			,	NIL}}

				//						{"C6_PRUNIT"	, nPrecVen		,	NIL},;

				aadd(aTotItens , aClone(aItens))
				*/

				aAdd( aItens ,{"C6_FILIAL"	, cFilAnt		,NIL})
				aAdd( aItens ,{"C6_ITEM"	, cItem			,NIL})
				aAdd( aItens ,{"C6_PRODUTO"	, cProduto		,NIL})
				aAdd( aItens ,{"C6_DESCRI"	, cDescric		,NIL})
				aAdd( aItens ,{"C6_ZZEORIG"	, cOrigAn		,NIL})
				aAdd( aItens ,{"C6_ZZREVCE"	, cRevCert		,NIL})
				aAdd( aItens ,{"C6_ZZCODAM"	, cCodAm		,NIL})
				aAdd( aItens ,{"C6_ZZNMEDI"	, cNumMedic		,NIL})
				aAdd( aItens ,{"C6_ZZNROCE"	, cNumCert		,NIL})
				aAdd( aItens ,{"C6_ENTREG"	, dDtEntrega	,NIL})
				aAdd( aItens ,{"C6_QTDVEN"	, nQtdVen		,NIL})
				aAdd( aItens ,{"C6_PRCVEN"	, nPrecVen		,NIL})
				aAdd( aItens ,{"C6_VALOR" 	, nTotal		,NIL})
				aAdd( aItens ,{"C6_UM"		, cUMedida		,NIL})
				if cFilAnt == "0100" .or. cFilAnt == "0101"
					aAdd( aItens ,{"C6_QTDLIB"	, nQtdVen		,NIL})
				endif

				//Se for ND, fixa a TES
				//Régis Ferreira - Totvs IP Jundiaí  27/02/2024
				//Ajuste para Fernada Carelli
				lTesInt	:= getnewpar("ZZ_OFFTEIN",.T.) //TODO
				If lTesInt
                    if aDados[t][20] == "ND" //Pedido do Tipo ND
                        cTes := cTesND
                        aAdd( aItens ,{"C6_TES", cTes,	NIL})
                    else
                        cTes := MaTesInt( 2, aDados[t][20] ,cCliente,cLjCli,"C",cProduto)
                        aAdd( aItens ,{"C6_OPER", aDados[t][20],NIL})
                        aAdd( aItens ,{"C6_TES", cTes,	NIL})
                    endif
				Else
					if aDados[t][20] == "ND" //Pedido do Tipo ND
                        cTes := cTesND
					endif
					aAdd( aItens ,{"C6_TES", cTes,	NIL})
				EndIf

				aAdd( aItens ,{"C6_CF"  	, cCFOP    ,NIL})
				aAdd( aItens ,{"C6_LOCAL"   , cArmaz   ,NIL})
				aAdd( aItens ,{"C6_PEDCLI"	, cPedCli  ,NIL})
				aAdd( aItens ,{"C6_CLI"		, cCliente ,NIL})
				aAdd( aItens ,{"C6_LOJA"	, cLjCli   ,NIL}) 
				aAdd( aItens ,{"C6_CLASFIS"	, cClasFis ,NIL})
				aAdd( aItens ,{"C6_CODISS"	, cCodISS  ,NIL})
				aAdd( aItens ,{"C6_ZZOPAPO"	, "N"	   ,NIL})
				aAdd( aItens ,{"C6_TPOP"	, "F"	   ,NIL})
				aAdd( aItens ,{"C6_ZZCODRE"	, cResp	   ,NIL})
				aAdd( aItens ,{"C6_QTDENT"	, 0		   ,NIL})
				aAdd( aItens ,{"C6_ZZTPPV"	, "N"	   ,NIL})
				//						{"C6_PRUNIT"	, nPrecVen		,	NIL},;

				aadd(aTotItens , aClone(aItens))
				aItens	:= {}

			Endif

		Next

	Endif

	If lPreChk
		If Len(aErroLog) == 0
			If IW_MsgBox(OemToAnsi("Dados verificados. Nenhum problema foi encontrado!"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+"Deseja efetivar o processamento?" ) , OemToAnsi("Informação"), "YESNO")
				lLoop := .T.
			Endif
		Else
			IW_MsgBox(OemToAnsi("Foram identificadas algumas divergências. Verifique o relatório de erros.") ,;
			OemToAnsi("Aviso"), "ALERT")
			ImprLog(aErroLog,cRetArq,cNomeArq)
		Endif
	Else
		If Len(aErroLog) == 0
			IW_MsgBox(OemToAnsi("Operação realizada com sucesso! ") , OemToAnsi("Informação"), "INFO")
		Else
			IW_MsgBox(OemToAnsi("Operação realizada, porém ocorreu ao menos um erro. Verifique os pedidos gerados e o relatório de erros.") ,;
			OemToAnsi("Aviso"), "ALERT")
			ImprLog(aErroLog,cRetArq,cNomeArq)
		Endif
	Endif

	dDataBase := dDataAtual
	cFilAnt   := cOldFilial

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ImprLog  ºAutor  ³ Marcos Candido     º Data ³  14/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para apresentar em relatorio, os erros encontrados  º±±
±±º          ³ na leitura do arquivo texto do eLims e que devido sua in-  º±±
±±º          ³ consistencia, nao foram utilizados.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImprLog(aErroLog,cRetArq,cNomeArq)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1  := "Este programa tem como objetivo imprimir relatório com os erros encontrados"
	Local cDesc2  := "na leitura do arquivo texto proveniente do sistema eLims e que tem por objetivo"
	Local cDesc3  := "gerar os pedido de venda no sistema Microsiga. Especifico para a Eurofins."
	Local titulo  := "Relacao dos Erros Encontrados"
	Local Cabec1  := Padc("Inconsistencias do arquivo "+Alltrim(cRetArq),132)
	Local Cabec2  := ""
	Local imprime := .T.
	Local aOrd    := {}
	Local cPerg   := ""

	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := cNomeArq+"_"+Time()  // "INSPV"
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private m_pag       := 01
	Private wnrel       := cNomeArq+"_"+Time()
	Private cString     := "SC5"
	Li                  := 80

	//===============================================================================================
	// Monta a interface padrao com o usuario...
	//===============================================================================================
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,aErroLog) },Titulo)

Return

/*
==============================================================================
Funcao     	RUNREPORT | Autor ³                    | Data ³
==============================================================================
Descricao 	Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS
monta a janela com a regua de processamento.
==============================================================================
Uso     	Programa principal
==============================================================================*/
Static Function RunReport(Cabec1,Cabec2,Titulo,aErroLog)

	Local nTotIncons := 0
	Local b			 := 0

	SetRegua(Len(aErroLog))

	For b:=1 to Len(aErroLog)
		IncRegua()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAbortPrint
			@ Li,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Li > 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		Endif

		@ Li,000 Psay aErroLog[b]
		Li++

		If Substr(aErroLog[b],1,5) <> "Não é"
			nTotIncons++
		Endif

	Next

	Li+=2
	If Li > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	Endif

	@ Li,000 Psay __PrtThinLine()
	Li++
	@ Li,010 Psay "Total de inconsistencias ---> "+StrZero(nTotIncons,4)
	Li++
	@ Li,000 Psay __PrtThinLine()

	Roda(cbcont,cbtxt,Tamanho)

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A410TAB  ºAutor  ³ Marcos Candido     º Data ³  18/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na rotina A410Tabela(que verifica o valor º±±
±±º          ³ correto que deve se preenchido no campo C6_PRCVEN), e que  º±±
±±º          ³ permite fazer a manipulacao do valor a ser usado.          º±±
±±º          ³ Esta sendo utilizado manter o preco que eh lido atraves do º±±
±±º          ³ arquivo texto de origem do eLims.                          º±±
±±º          ³ Se a chamada vier de outra rotina passa novamente os valo- º±±
±±º          ³ res dos parametros recebidos e nao deixa manipular o preco.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A410TAB()

	Local aInfo := PARAMIXB
	Local xInfo1 := aInfo[1]
	Local xInfo2 := aInfo[2]
	Local xInfo3 := aInfo[3]
	Local xInfo4 := aInfo[4]
	Local xInfo5 := aInfo[5]
	Local xInfo6 := aInfo[6]
	Local xInfo7 := aInfo[7]
	Local xInfo8 := aInfo[8]
	Local xInfo9 := aInfo[9]
	Local xInfo10 := .F.
	Local nUm := 1 , lVai := .F. , nPrv := 0
	While !(ProcName(nUm) == "")
		If UPPER(Alltrim(ProcName(nUM))) == "INSPVENDA"
			lVai := .T.
			Exit
		Endif
		nUm++
	Enddo

	If lVai
		nPrV := nPrecVen
	Else
		nPrV := A410Tabela(xInfo1,xInfo2,xInfo3,xInfo4,xInfo5,xInfo6,xInfo7,xInfo8,xInfo9,xInfo10)
	Endif
Return(nPrV)

//********************************************
// Retorna código do vendedor
//********************************************

Static Function RetElims(cCod)
	Local cQry
	Local aArea := GetArea()
	Local cRet := ""

	cQry := "SELECT A3_COD "
	cQry += "FROM "+RetSqlName("SA3")
	cQry += " WHERE D_E_L_E_T_ <> '*' "
	cQry += " AND A3_FILIAL = '"+xFilial("SA3")+"'"
	cQry += " AND A3_COD = '"+cCod+"'"

	dbUseArea(.t., "TOPCONN", TCGenQry(,, cQry), "TMP", .f., .t.)

	if TMP->(!Eof())
		cRet := TMP->A3_COD
	endif
	TMP->(dbCloseArea())

	RestArea(aArea)

Return cRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual a origem do TXT importado        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Alterado por Tiago Badoco/Victor Freidinger - TOTVS IP

Static Function chkOrigem(cNPedCli)

	local cGrvFil := cGravFil // Vem com o Padrão

	/*
	"REC-"	= 0101
	"BS-"	= 0500
	*/

	If Substr(cNPedCli,1,4)=="REC-"
		cGrvFil := "0101"
	ElseIf Substr(cNPedCli,1,3)=="BS-"
		cGrvFil := "0500"
	EndIf

return cGrvFil

/*
Rotina que irá buscar a condição de pagamento na tabela ZZG em vez do campo A1_COND
*/
Static Function GetCond(cCPagto,cCli,cLoja)

	Local aArea := GetArea()
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cCond := cCPagto

	cQuery := " Select " + CRLF
	cQuery += " 	ZZG_COND " + CRLF
	cQuery += " From " + CRLF
	cQuery += " "+RetSqlName("ZZG")+" " + CRLF
	cQuery += " where " + CRLF
	cQuery += " 	ZZG_CLIENT 		= '"+cCli+"' " + CRLF
	cQuery += " 	and ZZG_LOJA 	= '"+cLoja+"' " + CRLF
	cQuery += " 	and ZZG_FILIAL 	= '"+cFilAnt+"' " + CRLF
	cQuery += " 	and D_E_L_E_T_ 	= ' ' " + CRLF

	dbUseArea(.t., "TOPCONN", TCGenQry(,, cQuery), "TMP", .f., .t.)

	if TMP->(!Eof())
		cCond := TMP->ZZG_COND
	endif
	TMP->(dbCloseArea())

	RestArea(aArea)

Return cCond

/*
Rotina que verifica se o registro existe na tabela ZZG
*/

Static Function ExistZZG(cCli,cLoja)

	Local aArea  := GetArea()
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local lRet   := .T.

	cQuery := " Select " + CRLF
	cQuery += " 	Count(*) COUNT " + CRLF
	cQuery += " From " + CRLF
	cQuery += " "+RetSqlName("ZZG")+" " + CRLF
	cQuery += " where " + CRLF
	cQuery += " 	ZZG_CLIENT 		= '"+cCli+"' " + CRLF
	cQuery += " 	and ZZG_LOJA 	= '"+cLoja+"' " + CRLF
	cQuery += " 	and ZZG_FILIAL 	= '"+cFilAnt+"' " + CRLF
	cQuery += " 	and D_E_L_E_T_ 	= ' ' " + CRLF 

	dbUseArea(.t., "TOPCONN", TCGenQry(,, cQuery), "TMP", .f., .t.)

	if TMP->COUNT > 0
		lRet  := .T.
	else
		lRet  := .F.
	endif
	TMP->(dbCloseArea())

	RestArea(aArea)

Return lRet
