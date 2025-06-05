#Include "Protheus.ch"
#Include "FWPrintSetup.ch"
#Include "Topconn.ch"

#Define IMP_DISCO  		1
#Define IMP_SPOOL  		2
#Define IMP_EMAIL  		3
#Define IMP_EXCEL  		4
#Define IMP_HTML  		5
#Define IMP_PDF   		6

#Define PAPEL_A4		9
#Define ALIGN_D_LEFT   	0
#Define ALIGN_D_RIGHT  	1
#Define ALIGN_D_CENTER 	2
#Define	SALTO_LIN 		40
#Define SALTO_LIN2		10
#Define	INI_COL 		50
#Define FIM_COL         160
#Define CAMPO 			1
#Define VALOR 			2
#Define TAM_DESC		160
#Define CONFIRMA 		1

/*/{Protheus.doc} NFSe04557
Gera a NF Serviço do Rio de Janeiro / PE (IBGE = 04557)
@type function
@version 1.0
@author Régis Ferreira.
@since 28/04/2025
/*/
User Function NFSe04557(cNFSeFil,cNFSeNum,cNFSeSer,cNFSeCli,cNFSeLoj,cModNFSe,lPreview)
	
	Local cNFSe := ""
	//RpcSetEnv("01","0600")
	Default cNFSeFil := "0600"
	Default cNFSeNum := "000005197"
	Default cNFSeSer := "E  "
	Default cNFSeCli := "970019"
	Default cNFSeLoj := "01"
	Default cModNFSe := SuperGetMV("ZZ_04557MD",.F.,"000002")	//-Recife
	Default lPreview := .F.

	Private cLogoEmpr   := SuperGetMV("ZZ_NFSESM0",.F.,"")	//-Logo da Empresa/Cliente
	Private cLogoPref   := SuperGetMV("ZZ_04557LG",.F.,"")	//-Logo da Prefeitura Municipal
	Private cLogoNFSe   := SuperGetMV("ZZ_04557L2",.F.,"")	//-Logo da NFSe da Prefeitura
	Private nValliqNF	:= 0

	cLogoEmpr := iif(!Empty(cLogoEmpr), Alltrim(cLogoEmpr), "D:\iCloud\OneDrive\_GitHub_\Totvs-Protheus\fGeeker\eurofins\eurofins-desenv\NF-Servicos\Imagens\logo-eurofins.png")
	cLogoPref := iif(!Empty(cLogoPref), Alltrim(cLogoPref), "D:\iCloud\OneDrive\_GitHub_\Totvs-Protheus\fGeeker\eurofins\eurofins-desenv\NF-Servicos\Imagens\logo-recife.png")
	cLogoNFSe := iif(!Empty(cLogoNFSe), Alltrim(cLogoNFSe), "D:\iCloud\OneDrive\_GitHub_\Totvs-Protheus\fGeeker\eurofins\eurofins-desenv\NF-Servicos\Imagens\logo-nfse-recife.png")

	//-Posiciona na NFSe - SF2/SD2
	dbSelectArea("SF2")
	dbSetOrder(1)	//-F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	dbSeek(cNFSeFil+cNFSeNum+cNFSeSer+cNFSeCli+cNFSeLoj,.F.)

	dbSelectArea("SD2")
	dbSetOrder(3)	//-D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	dbSeek(cNFSeFil+cNFSeNum+cNFSeSer+cNFSeCli+cNFSeLoj,.F.)

	cNFSe := ImpRelNFSe(lPreview)

Return cNFSe

/*
	Funçao principal do inicio do processamento
*/
Static Function ImpRelNFSe(lPreview)
	Local cDirectory		:= GetSrvProfString("ROOTPATH","")+SuperGetMV("ZZ_NFSEPDF",.F.,"\NFSE\")
	// Local cFilePrint 		:= "nfse_"+AllTrim(SF2->F2_DOC)+"_"+DToS(MSDate())+"_"+StrTran(Time(),":","")+".pdf"
	//Local cFilePrint 		:= cFilAnt+"_NFSe_"+AllTrim(SF2->F2_DOC)+".pdf"
	Local cNumNFSe			:= iif(Empty(SF2->F2_NFELETR),SF2->F2_DOC,SF2->F2_NFELETR)
	Local cFilePrint 		:= "NFSE_"+Alltrim(RetCodUsr())+"_"+Alltrim(SM0->M0_CODFIL)+"_"+AllTrim(cNumNFSe)+iif(Empty(Alltrim(SF2->F2_SERIE)),"","_"+Alltrim(SF2->F2_SERIE))+".pdf"
	Local cFilePDF			:= ""
	Local nDevice			:= IMP_PDF 
	Local lAdjustToLegacy	:= .T.		//-Inibe legado de resolução com a TMSPrinter
	Local lDisabeSetup		:= !lPreview
	Local nItem 			:= 0

	Private aColImp		:= {}
	Private nLin		:= 0
	Private	nInicio		:= 50
	Private nLimiteHoz	:= 0		
	Private nLimiteVer	:= 0
	Private oFont08 	:= TFont():New("Arial", 08, 08,, .F.,,,,, .F., .F.)
	Private oFont08N 	:= TFont():New("Arial", 08, 08,, .T.,,,,, .F., .F.)
	Private oFont09 	:= TFont():New("Arial", 09, 09,, .F.,,,,, .F., .F.)
	Private oFont09N 	:= TFont():New("Arial", 09, 09,, .T.,,,,, .F., .F.)
	Private oFont10 	:= TFont():New("Arial", 10, 10,, .F.,,,,, .F., .F.)	
	Private oFont10N 	:= TFont():New("Arial", 10, 10,, .T.,,,,, .F., .F.)
	Private oFont11 	:= TFont():New("Arial", 11, 11,, .F.,,,,, .F., .F.)
	Private oFont11N 	:= TFont():New("Arial", 11, 11,, .T.,,,,, .F., .F.)
	Private oFont12 	:= TFont():New("Arial", 12, 12,, .F.,,,,, .F., .F.)
	Private oFont12N 	:= TFont():New("Arial", 12, 12,, .T.,,,,, .F., .F.)
	Private oFont13 	:= TFont():New("Arial", 13, 13,, .F.,,,,, .F., .F.)
	Private oFont13N 	:= TFont():New("Arial", 13, 13,, .T.,,,,, .F., .F.)
	Private oFont14 	:= TFont():New("Arial", 14, 14,, .F.,,,,, .F., .F.)
	Private oFont14N 	:= TFont():New("Arial", 14, 14,, .T.,,,,, .F., .F.)
	Private oFont16 	:= TFont():New("Arial", 16, 16,, .F.,,,,, .F., .F.)
	Private oFont16N 	:= TFont():New("Arial", 16, 16,, .T.,,,,, .F., .F.)
	Private oFont16NI 	:= TFont():New("Arial", 16, 16,, .T.,,,,, .F., .T.)
	Private oFont18 	:= TFont():New("Arial", 18, 18,, .T.,,,,, .F., .F.)
	Private oFont18N 	:= TFont():New("Arial", 18, 18,, .T.,,,,, .F., .T.)
	Private oFont20N 	:= TFont():New("Arial", 20, 20,, .T.,,,,, .F., .F.)
	Private oBrush		:= TBrush():New(, CLR_HGRAY)

	if type("cDirNFSe")<>"U"
		cDirectory := Alltrim(cDirNFSe)
	endif

	// FWMsPrinter():New( <cFilePrintert>,[nDevice],[lAdjustToLegacy],[cPathInServer],[lDisabeSetup],[lTReport],[@oPrintSetup],;
	// 					[cPrinter],[lServer],[lPDFAsPNG],[lRaw],[lViewPDF],[nQtdCopy]) --> oPrinter
	oPrint := FWMSPrinter():New(cFilePrint, nDevice, lAdjustToLegacy, cDirectory, lDisabeSetup)	
	
	cFilePDF := cDirectory+cFilePrint	// Alltrim(RetCodUsr())+"\"+

	If !lPreview .Or. (lPreview .And. oPrint:nModalResult == CONFIRMA) 
		
		oPrint:SetPortrait()
		oPrint:SetPaperSize(PAPEL_A4)
		oPrint:SetViewPDF(lPreview)

		If !lPreview
			oPrint:cPathPDF := cDirectory	// +Alltrim(RetCodUsr())+"\"
		EndIf 

		nLimiteHoz  := oPrint:nHorzRes() - INI_COL
		nLimiteVer	:= oPrint:nVertRes() - FIM_COL
		nTamCol     := nLimiteHoz / 20

		For nItem := 1 To 20
			aAdd(aColImp, nItem * nTamCol)	
		Next nItem	

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA))

		// dbSelectArea("SD2")
		// dbSetOrder(3)	//-D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		// dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))

		dbSelectArea("SC5")
		dbSetOrder(3)	//-C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
		dbSeek(xFilial("SC5")+SD2->(D2_CLIENTE+D2_LOJA+D2_PEDIDO))

		dbSelectArea("SE1")
		dbSetOrder(2)	//-E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC))

		//-Posiciona no Contas a Pagar pra pegar dados do ISS
		dbSelectArea("SE2")
		dbSetOrder(1)	//-E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		if !dbSeek(xFilial("SE2")+SF2->(F2_SERIE+F2_DOC)+Space(Len(E2_PARCELA))+"ISS"+Alltrim(SuperGetMv("MV_MUNIC",.F.,"")), .F.)
			dbSeek(xFilial("SE2")+SF2->(F2_SERIE+F2_DOC+"01")+"ISS"+Alltrim(SuperGetMv("MV_MUNIC",.F.,"")), .F.)
		endif

		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"60"+SD2->D2_CODISS)

		Cabec()
		Prestador()
		Tomador()
		Servico()
		Impostos()
		OutrasInformacoes()

		oPrint:Endpage()
		// oPrint:Print()	//-Envia o relatório para impressora
		oPrint:Preview()	//-Envia o relatório para tela
	EndIf 

	if !File(cFilePDF)
		cFilePDF := ""
		if type("oNFSePDF") == "O"
			oNFSePDF:cError := "Não foi possível gerar o arquivo PDF"
		endif
	endIf

Return cFilePDF

/*
	Funçao responsavel pelos dados do cabeçalho da NF - parte 1
*/
Static Function Cabec()
	
	Local cRPS 			:= padl(Val(SF2->F2_NFELETR),9,"0")
	//Local cNFSerie 		:= Alltrim(SF2->F2_SERIE)
	//Local cDtEmisRPS	:= DTOC(SF2->F2_EMINFE)
	Local aDtEmisNFSe	:= {SF2->F2_EMINFE,SF2->F2_HORNFE}
	//Local cNFSeNum 		:= SF2->F2_DOC
	Local cCodVer 		:= SF2->F2_CODNFE
	local nLinVert		:= SALTO_LIN + 10

	nLin := 30
	oPrint:Box(nLin, INI_COL, nLimiteVer, nLimiteHoz)
	//-SayBitmap( <nRow>, <nCol>, <cBitmap>, [nWidth], [nHeight] )
	oPrint:SayBitmap(nLin+(SALTO_LIN), INI_COL+0050, Alltrim(cLogoPref), 300, 200)
	oPrint:Say(nLin+(SALTO_LIN*7), aColImp[1], dTos(SF2->F2_EMINFE)+"u"+Replace(Replace(Replace(SM0->M0_CGC,"-",""),".",""),"/",""), oFont10)

	oPrint:Say(nLin+SALTO_LIN, aColImp[5], "PREFEITURA DA CIDADE DO RIO DE JANEIRO", oFont18)
	oPrint:Say(nLin+(SALTO_LIN*3), aColImp[6], "SECRETARIA MUNICIPAL DE FAZENDA", oFont18)
	oPrint:Say(nLin+(SALTO_LIN*5), aColImp[5], "NOTA FISCAL DE SERVIÇOS ELETRÔNICA - NFS-e", oFont18)
	oPrint:Say(nLin+(SALTO_LIN*7), aColImp[8], "- NOTA CARIOCA -", oFont18)

	oPrint:Line(nLin, aColImp[16], nLin+(nLinVert*6), aColImp[16])
	oPrint:Line(nLin+(nLinVert*2), aColImp[16], nLin+(nLinVert*2), aColImp[20])
	oPrint:Line(nLin+(nLinVert*4), aColImp[16], nLin+(nLinVert*4), aColImp[20])

	nLin += SALTO_LIN
	//oPrint:Say(nLin, aColImp[10], "RPS N. "+cRPS+" Serie "+cNFSerie+", emitido em "+cDtEmisRPS, oFont13)

	//Número da nota
	oPrint:Say(nLin, aColImp[17]-20, "Número da nota", oFont12)
	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[17]-20, SubStr(AllTrim(cRPS),2,9), oFont16N)

	//Data e hora da emissão
	nLin += SALTO_LIN + 20
	oPrint:Say(nLin, aColImp[17]-40, "Data e Hora de Emissão", oFont12)
	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[17]-70, DToC(aDtEmisNFSe[1]) +" "+ aDtEmisNFSe[2], oFont16N)

	//Chave de verificação
	nLin += SALTO_LIN + 20
	oPrint:Say(nLin, aColImp[17]-20,"Chave de Verificação", oFont12)
	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[17], AllTrim(cCodVer), oFont16N)

	nLin += SALTO_LIN / 2
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil

/*
	Funçao responsavel pelos dados do prestador de serviço
*/
Static Function Prestador()
	Local cRazaoSocial	:= SM0->M0_NOMECOM
	Local cCNPJ 		:= SM0->M0_CGC
	Local cIMun			:= SM0->M0_INSCM
	Local cInscriEst	:= SM0->M0_INSC
	Local cEnd 			:= AllTrim(SM0->M0_ENDENT)
	Local cBairro		:= Alltrim(SM0->M0_BAIRENT)
	Local cMunicipio	:= Alltrim(SM0->M0_CIDENT)
	Local cUF 			:= SM0->M0_ESTENT
	Local cCEP 			:= SM0->M0_CEPENT
	Local cNomeFantasia := "EUROFINS INNOLAB"
	Local cEmail 		:= AllTrim(SuperGetMV("ZZ_NFSEEML", .F., "faturamento@eurofins.com", cFilAnt)) 

	//-SayBitmap( <nRow>, <nCol>, <cBitmap>, [nWidth], [nHeight] )
	oPrint:SayBitmap(nLin+50, INI_COL+55, Alltrim(cLogoEmpr), 150, 100)	//-->>
	oPrint:Say(nLin, aColImp[08], "PRESTADOR DE SERVIÇOS", oFont16N)

	nLin += SALTO_LIN + 10
	oPrint:Say(nLin, aColImp[03],"CNPJ/CPF: ", oFont12)
	oPrint:Say(nLin, aColImp[05], AllTrim(Transform(cCNPJ,"@R 99.999.999/9999-99")), oFont12N)

	oPrint:Say(nLin, aColImp[10],"Inscr. Municipal: ", oFont12)
	oPrint:Say(nLin, aColImp[12], cIMun, oFont12N)

	oPrint:Say(nLin, aColImp[15],"Inscr. Estadual: ", oFont12)
	oPrint:Say(nLin, aColImp[17], cInscriEst, oFont12N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[03], "Nome/Razão Social: ", oFont12)
	oPrint:Say(nLin, aColImp[06], cRazaoSocial, oFont12N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[03], "Nome Fantasia: ", oFont12)
	oPrint:Say(nLin, aColImp[06], cNomeFantasia, oFont12N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[03],"Endereço: ", oFont12)
	oPrint:Say(nLin, aColImp[05], cEnd +" - " +cBairro +" - CEP: " +AllTrim(Transform(cCEP, "@R 99999-999")), oFont12N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[03],"Município: ", oFont12)
	oPrint:Say(nLin, aColImp[05], cMunicipio, oFont12N)

	oPrint:Say(nLin, aColImp[10], "UF: ", oFont12)
	oPrint:Say(nLin, aColImp[11], cUF, oFont12N)
	
	oPrint:Say(nLin, aColImp[13], "E-mail: ", oFont12)
	oPrint:Say(nLin, aColImp[14], cEmail, oFont12N)

	nLin += SALTO_LIN / 2 //--20
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil 

/*
	Funçao responsavel pelos dados do tomador
*/
Static Function Tomador()
	Local cRazaoSocial  := SA1->A1_NOME
	Local cCNPJ	 		:= AllTrim(SA1->A1_CGC)
	Local cIEst			:= SA1->A1_INSCR
	Local cIMun			:= iif(!Empty(SA1->A1_INSCRM),SA1->A1_INSCRM,"----")
	Local cEnd 			:= AllTrim(SA1->A1_END)
	Local cBairro		:= AllTrim(SA1->A1_BAIRRO)
	Local cMun 			:= AllTrim(SA1->A1_MUN)
	Local cUF 			:= SA1->A1_EST
	Local cCEP 			:= SA1->A1_CEP
	Local cEmail 		:= SA1->A1_EMAIL
	Local cTel			:= "("+Alltrim(SA1->A1_DDD)+") "+ Alltrim(SA1->A1_TEL)

	oPrint:Say(nLin, aColImp[8], "TOMADOR DE SERVIÇOS", oFont16N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[01],"CNPJ/CPF: ", oFont12)
	If len(cCNPJ) == 14
		oPrint:Say(nLin, aColImp[03], AllTrim(Transform(cCNPJ, "@R 99.999.999/9999-99")), oFont12N)
	Else
		oPrint:Say(nLin, aColImp[03], AllTrim(Transform(cCNPJ, "@R 999.999.999-99")), oFont12N)
	EndIf

	oPrint:Say(nLin, aColImp[08],"Inscr. Municipal: ", oFont12)
	oPrint:Say(nLin, aColImp[10], cIMun, oFont12N)

	oPrint:Say(nLin, aColImp[13],"Inscr. Estadual: ", oFont12)
	oPrint:Say(nLin, aColImp[15], cIEst, oFont12N)

	nLin += SALTO_LIN + 10
	oPrint:Say(nLin, aColImp[01], "Nome/Razão Social: ", oFont12)
	oPrint:Say(nLin, aColImp[04], cRazaoSocial, oFont12N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[01],"Endereço: ", oFont12)
	oPrint:Say(nLin, aColImp[03], cEnd +" - " +cBairro +" - CEP: " +AllTrim(Transform(cCEP, "@R 99999-999")), oFont12N)

	oPrint:Say(nLin, aColImp[16],"Tel: ", oFont12)
	oPrint:Say(nLin, aColImp[17], cTel, oFont12N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[01],"Município: ", oFont12)
	oPrint:Say(nLin, aColImp[03], cMun, oFont12N)

	oPrint:Say(nLin, aColImp[08],"UF: ", oFont12)
	oPrint:Say(nLin, aColImp[09], cUF, oFont12N)
	
	oPrint:Say(nLin, aColImp[11], "Email: ", oFont12)
	oPrint:Say(nLin, aColImp[12], cEmail, oFont12N)

	nLin += SALTO_LIN / 2	//--20
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil 

/*
	Funçao responsavel pelos dados do serviço prestado
*/
Static Function Servico()
	local cMsgObs	:= ""

	oPrint:Say(nLin, aColImp[8]-15, "DISCRIMINAÇÃO DOS SERVIÇOS", oFont16N)

	//-Imprime a Aliquota, Abatimento e Observaçoes (1/2)
	// oPrint:Say(nLin, aColImp[01], "Alíquota: " +Alltrim(Str(SD2->D2_ALIQISS,12,10)), oFont12)
	// oPrint:Say(nLin, aColImp[05], "Abatimento: " +Alltrim(Str(SD2->D2_ABATISS,12,02)), oFont12)

	/*nLin += SALTO_LIN
	cMsgObs := "Serviços de análise em amostras de produtos alimenticios."
	oPrint:Say(nLin, aColImp[01], cMsgObs, oFont12)

	nLin += SALTO_LIN
	cMsgObs := "Caro cliente, informamos que o recolhimento do ISSQN é de obrigatoriedade da "+Alltrim(SM0->M0_NOMECOM)+", gentileza não reter."
	oPrint:Say(nLin,aColImp[01], SubStr(cMsgObs,1,133), oFont12)
	nLin += SALTO_LIN
	oPrint:Say(nLin,aColImp[01], iif(Len(cMsgObs)>133, SubStr(cMsgObs,134,133), ""), oFont12)
	nLin += SALTO_LIN*/
	
	nLin += SALTO_LIN
	//-----------------------------------------
	cMsgObs := oNFSePDF:getMensag_NFSeMain()
	cMsgObs += " Local de tributação: Rio de Janeiro/RJ"
	//-----------------------------------------
	oPrint:Say(nLin,aColImp[01], SubStr(cMsgObs,1,133), oFont12)
	nLin += SALTO_LIN
	oPrint:Say(nLin,aColImp[01], iif(Len(cMsgObs)>133, SubStr(cMsgObs,134,133), ""), oFont12)
	nLin += SALTO_LIN
	oPrint:Say(nLin,aColImp[01], iif(Len(cMsgObs)>267, SubStr(cMsgObs,268,133), ""), oFont12)

Return Nil

/*
	Funçao responsavel pelos dados dos impostos
*/
Static Function Impostos()
	Local cVlrOutRed 	:= 0
	Local cBaseCalc		:= SF2->F2_BASEISS
	Local cVlrLiq		:= SF2->F2_BASEISS
	Local cVlrServ		:= SF2->F2_VALBRUT
	Local cVlrDed		:= 0
	Local cDescInc		:= 0
	Local cAliqISS		:= SD2->D2_ALIQISS
	Local cIptuCred		:= 0
	Local cISSRetido	:= retIssRetido()
	Local cVlrSTISS		:= 0

	Private cVlrIR 		:= 0
	Private cVlrPIS  	:= 0                                
	Private cVlrCofins 	:= 0
	Private cVlrCSLL 	:= 0
    Private cVlrINSS	:= 0
	Private cVlrISS		:= SF2->F2_VALISS	//-Valor do ISS na NFSe

	//-----------------------------------------
	GetDuplic()
	//-----------------------------------------

	cVlrSTISS := IIF(cISSRetido == "1", cVlrISS, 0)
	cVlrLiq   := cVlrLiq - cVlrISS - cVlrINSS
	nValliqNF := cVlrServ-IIF(cISSRetido == "1", cVlrISS, 0)-cVlrIR-cVlrINSS-cVlrCSLL-cVlrPIS-cVlrCofins
	//-Redefine a linha para impressao dos trechos do Rodape
	nLin := 2350 - ( SALTO_LIN * 5 )	//-->>
	/*oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN
	oPrint:Say(nLin,aColImp[8]-10, "VALOR(ES) DE RETENÇÃO(ÕES)", oFont16N)*/

	nLin += SALTO_LIN / 2
	/*oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	oPrint:Line(nLin, aColImp[03], nLin+90, aColImp[03])
	oPrint:Line(nLin, aColImp[06], nLin+90, aColImp[06])
	oPrint:Line(nLin, aColImp[09], nLin+90, aColImp[09])
	oPrint:Line(nLin, aColImp[12], nLin+90, aColImp[12])
	oPrint:Line(nLin, aColImp[15], nLin+90, aColImp[15])*/

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL+10,	 "Retenção de COFINS", 		oFont13)
	oPrint:Say(nLin, aColImp[04]+10, "Retenção de CSLL", 		oFont13)
	oPrint:Say(nLin, aColImp[07]+10, "Retenção de INSS", 		oFont13)
	oPrint:Say(nLin, aColImp[10]+10, "Retenção de IRPJ",		oFont13)
	oPrint:Say(nLin, aColImp[13]+10, "Retenção de PIS", 		oFont13)
	oPrint:Say(nLin, aColImp[16]+10, "Outras Retenções",		oFont13)

	nLin += SALTO_LIN

	oPrint:Say(nLin, INI_COL+10, 	 "R$ "+AllTrim(Transform(cVlrCofins, 	PesqPict("SF2", "F2_VALCOFI"))), 	oFont13)
	oPrint:Say(nLin, aColImp[04]+10, "R$ "+AllTrim(Transform(cVlrCSLL, 		PesqPict("SF2", "F2_VALCSLL"))), 	oFont13)
	oPrint:Say(nLin, aColImp[07]+10, "R$ "+AllTrim(Transform(cVlrINSS, 		PesqPict("SF2", "F2_VALINSS"))), 	oFont13)
	oPrint:Say(nLin, aColImp[10]+10, "R$ "+AllTrim(Transform(cVlrIR, 		PesqPict("SF2", "F2_VALIRRF"))), 	oFont13)
	oPrint:Say(nLin, aColImp[13]+10, "R$ "+AllTrim(Transform(cVlrPIS, 		PesqPict("SF2", "F2_VALPIS"))),  	oFont13)
	oPrint:Say(nLin, aColImp[16]+10, "R$ "+AllTrim(Transform(cVlrOutRed,	PesqPict("SF2", "F2_VALPIS"))),  	oFont13)

	nLin += SALTO_LIN2 //SALTO_LIN
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN 
	oPrint:Say(nLin, aColImp[8]-10, "VALOR DA NOTA = R$ "+AllTrim(Transform(cVlrServ,PesqPict("SF3","F3_VALCONT"))), oFont16N)

	nLin += SALTO_LIN + 10
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	//-----------------------------------------
	PrintObserv()
	//-----------------------------------------
	
	nLin += SALTO_LIN2 //SALTO_LIN
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	oPrint:Line(nLin, aColImp[03], nLin+90, aColImp[03])
	oPrint:Line(nLin, aColImp[06], nLin+90, aColImp[06])
	oPrint:Line(nLin, aColImp[09], nLin+90, aColImp[09])
	oPrint:Line(nLin, aColImp[12], nLin+90, aColImp[12])
	oPrint:Line(nLin, aColImp[15], nLin+90, aColImp[15])

	nLin += SALTO_LIN

	oPrint:Say(nLin, INI_COL+10, 		"Deduções (R$)",		oFont12)
	oPrint:Say(nLin, aColImp[03]+10,	"Desc. Incond. (R$)",	oFont12)
	oPrint:Say(nLin, aColImp[06]+10,	"Base de Cálculo (R$)",	oFont12)
	oPrint:Say(nLin, aColImp[09]+10, 	"Aliquota (%)",			oFont12)
	oPrint:Say(nLin, aColImp[12]+10, 	"Valor do ISS (R$)", 	oFont12)
	oPrint:Say(nLin, aColImp[15]+10, 	"Credito p/ IPTU (R$)",	oFont12)

	nLin += SALTO_LIN

	oPrint:Say(nLin, INI_COL+10, 		AllTrim(Transform(cVlrDed,	PesqPict("SF2","F2_BASEISS"))), oFont12N)
	oPrint:Say(nLin, aColImp[03]+10,	AllTrim(Transform(cDescInc,	PesqPict("SF2","F2_BASEISS"))), oFont12N)
	oPrint:Say(nLin, aColImp[06]+10,	AllTrim(Transform(cBaseCalc,PesqPict("SF2","F2_BASEISS"))), oFont12N)
	oPrint:Say(nLin, aColImp[09]+10, 	AllTrim(Transform(cAliqISS,	PesqPict("SD2","D2_ALIQISS"))), oFont12N)
	oPrint:Say(nLin, aColImp[12]+10, 	AllTrim(Transform(cVlrISS, 	PesqPict("SF2","F2_VALISS"))),	oFont12N)
	oPrint:Say(nLin, aColImp[15]+10, 	AllTrim(Transform(cIptuCred,PesqPict("SF2","F2_VALISS"))),  oFont12N)

	nLin += SALTO_LIN2 //SALTO_LIN
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil 

/*
	Funçao responsavel pelos dados de outras informaçoes
*/
Static Function OutrasInformacoes()
	
	Local cRPS 			:= Alltrim(SF2->F2_DOC)
	Local cNFSerie 		:= Alltrim(SF2->F2_SERIE)
	Local cDtEmisRPS	:= DTOC(SF2->F2_EMINFE)
	Local cDataISS		:= DTOC(SF2->F2_EMINFE+1+(GetMv("MV_DIAISS")))

	oPrint:Say(nLin, aColImp[8], "OUTRAS INFORMAÇÕES", oFont16N)
	
	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL+10, "- Esta NFS-e foi emitida com respaldo na Lei nº 5.098 de 15/10/2009 e Decreto nº 32.250 de 11/05/2010.", oFont14)

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL+10, "- PROCON-RJ: Av. Rio Branco nº 25, 5º andar, tel 151: www.procon.rj.gov.br", oFont14)

	//nLin += SALTO_LIN
	//oPrint:Say(nLin, INI_COL+10, "- Data de Vencimento do iss Desta NFS-e: "+cDataISS, oFont14)

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL+10, "- Esta NFS-e não gera crédito para abatimento no IPTU", oFont14)

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL+10, "- Esta NFS-e substiui o RPS Nº "+cRPS+" Série "+cNFSerie+", emitido em "+cDtEmisRPS, oFont14)

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL+10, "- Valor Líquido a Pagar: R$ "+AllTrim(Transform(nValliqNF, 	PesqPict("SF2", "F2_VALBRUT"))), oFont14)
	
	nLin += SALTO_LIN	//-->>

Return Nil 

/*
	Funçao responsavel pela informaçao do tipo de ISS
*/
Static Function ExigISS(cOpc)
	Local cDesc 	:= ""

	If cOpc == "1"
		cDesc := "EXIGÍVEL"
	ElseIf cOpc == "2"
		cDesc := "NÃO INCIDÊNCIA"
	ElseIf cOpc == "3"
		cDesc := "ISENÇÃO"
	ElseIf cOpc == "4"
		cDesc := "EXPORTAÇÃO"
	ElseIf cOpc == "5"
		cDesc := "IMUNIDADE"
	ElseIf cOpc == "6"
		cDesc := "EXIGIBILIDADE SUSPENSA POR DECISÃO JUDICIAL"
	ElseIf cOpc == "7"
		cDesc := "EXIGIBILIDADE SUSPENSA POR PROCESSO ADMINISTRATIVO"
	EndIf 

Return cDesc

/*
	Funçao responsavel por buscar a descriçao do municipio
*/
Static Function DescMun(cCodMun, cUF)
	Local cDesc		:= ""
	Local cQuery 	:= ""
	Local cAliasQry	:= GetNextAlias()

	cQuery := "SELECT "
	cQuery += "		CC2.CC2_MUN "
	cQuery += "FROM "+ RetSqlTab("CC2") +" "
	cQuery += "WHERE "
	cQuery += "		"+ RetSqlDel("CC2") +" "
	cQuery += "		AND "+ RetSqlFil("CC2") +" "
	cQuery += "		AND CC2.CC2_EST = '"+ cUF +"' "
	cQuery += "		AND CC2.CC2_CODMUN = '"+ cCodMun +"' "
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)

	If !(cAliasQry)->(Eof())
		cDesc := AllTrim((cAliasQry)->CC2_MUN) +" - "+ cUF
	EndIf 

	(cAliasQry)->(DbCloseArea())

Return cDesc

/*
	Funçao responsavel por buscar a retençao de ISS
*/
Static Function retIssRetido()
	Local cRet := ""

	dbSelectArea("SF3")
	dbSetOrder(4)
	If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
		cRet := SF3->F3_RECISS
	EndIf

Return cRet

/*
	Funçao responsavel por buscar as duplicatas
*/
Static Function GetDuplic()
	local cQuery	:= ""
	local cQryAux	:= GetNextAlias()
	local nAuxRet	:= 0
	local nVlrPIS	:= SuperGetMV("MV_ZZRTPIS",.F.,0)	//-Valor Minimo de Retençao (Pis)
	local nVlrCOF	:= SuperGetMV("MV_ZZRTCOF",.F.,0)	//-Valor Minimo de Retençao (Cofins)
	local nVlrCSL	:= SuperGetMV("MV_ZZRTCSL",.F.,0)	//-Valor Minimo de Retençao (Csll)
	local nVlrMin	:= SuperGetMV("MV_VL13137",.F.,10)	//-Valor Minimo de Retençao (Pis+Cofins+Csll)

	if (nVlrPIS+nVlrCOF+nVlrCSL) > nVlrMin
		nVlrMin := (nVlrPIS+nVlrCOF+nVlrCSL)
	endif

	cQuery += " SELECT * " + CRLF
	cQuery += " FROM  "+ RetSqlTab("SE1") + " " + CRLF	   
	cQuery += " WHERE 1 = 1 " + CRLF	 
	cQuery += " 	AND "+ RetSqlDel("SE1") +" " + CRLF	
    cQuery += " 	AND "+ RetSqlFil("SE1") +" " + CRLF	
    cQuery += " 	AND E1_CLIENTE	= '"+ SF2->F2_CLIENTE +"' " + CRLF   
    cQuery += " 	AND E1_LOJA 	= '"+ SF2->F2_LOJA +"' " + CRLF  
	cQuery += " 	AND E1_PREFIXO	= '"+ SF2->F2_SERIE +"' " + CRLF  
	cQuery += " 	AND E1_NUM		= '"+ SF2->F2_DOC +"' " + CRLF  
	cQuery += " 	AND E1_TIPO IN ('NF ','IR-') " + CRLF  
	TcQuery cQuery NEW Alias &cQryAux

	(cQryAux)->(dbGotop())
	While (cQryAux)->(!eof())

        If (cQryAux)->E1_TIPO == "NF "
			cVlrINSS += (cQryAux)->E1_INSS
			cVlrISS	 += (cQryAux)->E1_ISS

			/* Ressaltamos que esse valor mínimo, para efeitos de retenção (R$ 10,00), deve ser 
				composto pelo somatório das contribuições (PIS, COFINS e CSLL), não devendo ser 
				feito o recolhimento de forma individualizada por Contribuição, mas conjuntamente, 
				já que estão sob o comando de recolhimento do mesmo código de receita (5952) 
			*/
			nAuxRet	:= (cQryAux)->( E1_PIS + E1_COFINS + E1_CSLL )
			if nAuxRet >= nVlrMin
				cVlrPIS    += (cQryAux)->E1_PIS
				cVlrCofins += (cQryAux)->E1_COFINS
				cVlrCSLL   += (cQryAux)->E1_CSLL
			endif

		ElseIf (cQryAux)->E1_TIPO == "IR-"
			cVlrIR += (cQryAux)->E1_VALOR
		Endif

        (cQryAux)->(dbSkip())
    EndDo

	(cQryAux)->(DbCloseArea())

Return

/*
	Funçao responsavel por montar o quadro Observaçoes 
*/
Static Function PrintObserv()
	Local aDesc 	:= {} 
	Local nQtdLin	:= 0
	Local nLinha 	:= 0
	Local nDesc 	:= 0
	Local nR		:= 0
	
	aDesc := StrTokArr(Alltrim(SX5->X5_CHAVE)+" "+AllTrim(SX5->X5_DESCRI)+CHR(13)+CHR(10) /*--( +SC5->C5_ZZMSGNF )--*/, CHR(13)+CHR(10))

	While .T.
		For nR := 1 to len(aDesc)
			nAux := aDesc[nR]
			If len(aDesc[nR]) > 130
				aAdd(aDesc,"")
				aIns(aDesc,nR+1)
				aDesc[nR] := SubStr(nAux,1,130)
				aDesc[nR+1] := SubStr(nAux,131)
				Exit
			EndIf
		Next
		If nR > len(aDesc)
			Exit
		EndIf
	EndDo

	nLin += SALTO_LIN
	oPrint:Say(nLin,INI_COL+10, "Serviço Prestado: ", oFont14)

	//nLin += SALTO_LIN
	//oPrint:Say(nLin,INI_COL+10, "7120100 - TESTES E ANÁLISES TÉCNICAS", oFont12N)

	nLin += SALTO_LIN + 10

	For nDesc := 1 To Len(aDesc)

		nQtdLin	:= MLCount(aDesc[nDesc], TAM_DESC)

		For nLinha := 1 To nQtdLin
			
			If nDesc == 1
				oPrint:Say(nLin,INI_COL+10, MemoLine(aDesc[nDesc], TAM_DESC, nLinha), oFont12N)
			Else
				oPrint:Say(nLin,INI_COL+10, MemoLine(aDesc[nDesc], TAM_DESC, nLinha), oFont12)
			EndIf

			nLin += SALTO_LIN

		Next nLinha 
	Next nDesc 

	//nLin += SALTO_LIN

Return 
