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

/*/{Protheus.doc} NFSe20509
Gera a NF Serviço de Indaiatuba / SP (IBGE = 20509)
@type function
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
@link https://gkcmp.com.br (Geeker Company)
@see https://www.indaiatuba.sp.gov.br/fazenda/rendas-mobiliarias/nfse
/*/
User Function NFSe20509(cNFSeFil,cNFSeNum,cNFSeSer,cNFSeCli,cNFSeLoj,cModNFSe,lPreview)
	Local cNFSe := ""

	Default cNFSeFil := ""
	Default cNFSeNum := ""
	Default cNFSeSer := ""
	Default cNFSeCli := ""
	Default cNFSeLoj := ""
	Default cModNFSe := SuperGetMV("ZZ_20509MD",.F.,"000001")	//-Indaiatuba
	Default lPreview := .F.

	private cLogoEmpr  := SuperGetMV("ZZ_NFSESM0",.F.,"")	//-Logo da Empresa/Cliente
	private cLogoPref  := SuperGetMV("ZZ_20509LG",.F.,"")	//-Logo da Prefeitura Municipal
	private cPathQRCod := SuperGetMV("ZZ_20509QR",.F.,"")	//-QRCode com o link de consulta da NFSe

	cLogoEmpr  := iif(!Empty(cLogoEmpr),  Alltrim(cLogoEmpr),  "D:\iCloud\OneDrive\_GitHub_\Totvs-Protheus\fGeeker\eurofins\eurofins-desenv\NF-Servicos\Imagens\logo-eurofins.png")
	cLogoPref  := iif(!Empty(cLogoPref),  Alltrim(cLogoPref),  "D:\iCloud\OneDrive\_GitHub_\Totvs-Protheus\fGeeker\eurofins\eurofins-desenv\NF-Servicos\Imagens\logo-indaiatuba.png")
	cPathQRCod := iif(!Empty(cPathQRCod), Alltrim(cPathQRCod), "https://www.indaiatuba.sp.gov.br/fazenda/rendas-mobiliarias/nfse/consulta/")	//"QBI2C8A18"

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
	//-"...\Faturamento\NF-Serviço\<AnoMesDia>\arquivoXYZ.pdf"
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
	Private oFont14 	:= TFont():New("Arial", 14, 14,, .F.,,,,, .F., .F.)
	Private oFont14N 	:= TFont():New("Arial", 14, 14,, .T.,,,,, .F., .F.)
	Private oFont16 	:= TFont():New("Arial", 16, 16,, .F.,,,,, .F., .F.)
	Private oFont16N 	:= TFont():New("Arial", 16, 16,, .T.,,,,, .F., .F.)
	Private oFont16NI 	:= TFont():New("Arial", 16, 16,, .T.,,,,, .F., .T.)	
	Private oFont18N 	:= TFont():New("Arial", 18, 18,, .T.,,,,, .F., .F.)
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

		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"60"+SD2->D2_CODISS)

		Cabec()
		NFSe()
		Prestador()
		Intermediario()
		Tomador()
		Servico()
		Impostos()
		ConstrucaoCivil()
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
	
	nLin := 30
	oPrint:Box(nLin, INI_COL, nLimiteVer, nLimiteHoz)
	//-SayBitmap( <nRow>, <nCol>, <cBitmap>, [nWidth], [nHeight] )
	oPrint:SayBitmap(nLin-05, INI_COL+50, Alltrim(cLogoPref), 200, 200)

	nLin += SALTO_LIN + SALTO_LIN2
	oPrint:Say(nLin, aColImp[7], "PREFEITURA MUNICPAL DE INDAIATUBA", oFont20N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[7], "SECRETARIA DA FAZENDA/DEPARTAMENTO DE RENDAS IMOBILIÁRIAS", oFont12N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[8], "NOTA FISCAL DE SERVIÇO ELETRÔNICA - NFSe", oFont14N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[16], "Impresso em: "+ DToc(dDataBase) +" "+ Time(), oFont12)

	nLin += SALTO_LIN / 2
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil

/*
	Funçao responsavel pelos dados do cabeçalho da NF - parte 2
*/
Static Function NFSe()
//--	Local aDtEmisNFSe	:= {SF2->F2_ZZDTSAI,SF2->F2_ZZHRSAI}
	Local aDtEmisNFSe	:= {SF2->F2_EMINFE,SF2->F2_HORNFE}
	Local aDtEmisRPS	:= {SF2->F2_EMINFE,SF2->F2_HORNFE}
	Local cNFSeNum 		:= SF2->F2_DOC
	Local cCodVer 		:= SF2->F2_CODNFE
	Local cRPS 			:= SF2->F2_NFELETR
	Local cRPSSub		:= ""
	local nLinVert		:= SALTO_LIN + 10

	//Número da nota
	oPrint:Say(nLin-10, INI_COL + 10, "Número da nota", oFont12)
	oPrint:Say(nLin+30, INI_COL + 10, SubStr(AllTrim(cNFSeNum),2,9), oFont12N)

	oPrint:Line(nLin - SALTO_LIN, aColImp[3], nLin + nLinVert, aColImp[3])

	//Data e hora da emissão
	oPrint:Say(nLin-10, aColImp[3] + 10, "Data e Hora de Emissão", oFont12)
	oPrint:Say(nLin+30, aColImp[3] + 10, DToC(aDtEmisNFSe[1]) +" "+ Transform(aDtEmisNFSe[2],"@R 99:99:99"), oFont12N)

	oPrint:Line(nLin - SALTO_LIN, aColImp[6], nLin + nLinVert, aColImp[6])

	//Chave de verificação
	oPrint:Say(nLin-10, aColImp[6] + 10,"Chave de Verificação", oFont12)
	oPrint:Say(nLin+30, aColImp[6] + 10, AllTrim(cCodVer), oFont12N)

	oPrint:Line(nLin - SALTO_LIN, aColImp[10], nLin + nLinVert, aColImp[10])

	//Número RPS
	oPrint:Say(nLin-10, aColImp[10] + 10,"Número do RPS", oFont12)
	oPrint:Say(nLin+30, aColImp[10] + 10, "000"+AllTrim(cRPS), oFont12N)

	oPrint:Line(nLin - SALTO_LIN, aColImp[14], nLin + nLinVert, aColImp[14])

	//Data RPS
	oPrint:Say(nLin-10, aColImp[14] + 10,"Data do RPS", oFont12)
	oPrint:Say(nLin+30, aColImp[14] + 10, DToC(aDtEmisRPS[1]), oFont12N)

	oPrint:Line(nLin - SALTO_LIN, aColImp[17], nLin + nLinVert, aColImp[17])

	//NFSe Substituída
	oPrint:Say(nLin-10, aColImp[17] + 10,"NFSe Substituída", oFont12)
	oPrint:Say(nLin+30, aColImp[17] + 10, AllTrim(cRPSSub), oFont12N)

	nLin += nLinVert	//-SALTO_LIN + 10
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil 

/*
	Funçao responsavel pelos dados do prestador de serviço
*/
Static Function Prestador()
	Local cRazaoSocial	:= SM0->M0_NOMECOM
	Local cCNPJ 		:= SM0->M0_CGC
	Local cIM 			:= SM0->M0_INSCM
	Local cEnd 			:= allTrim(SM0->M0_ENDENT)
	Local cBairro		:= SM0->M0_BAIRENT
	Local cMunicipio	:= SM0->M0_CIDENT
	Local cUF 			:= SM0->M0_ESTENT
	Local cCEP 			:= SM0->M0_CEPENT
	Local cEmail 		:= AllTrim(SuperGetMV("ZZ_NFSEEML", .F., "faturamento@eurofins.com", cFilAnt)) 
	Local cTelefone 	:= AllTrim(SuperGetMV("ZZ_NFSETEL", .F., "(19) 2107-5500", cFilAnt)) 
	Local cCodVer 		:= SF2->F2_CODNFE

	//-SayBitmap( <nRow>, <nCol>, <cBitmap>, [nWidth], [nHeight] )
	oPrint:SayBitmap(nLin+05, INI_COL+15, Alltrim(cLogoEmpr), 150, 100)	//-->>
	oPrint:Say(nLin, aColImp[08], "PRESTADOR DE SERVIÇOS", oFont16N)

	//-QRCode ( < nRow>, < nCol>, < cCodeBar>, < nSizeBar> )
	oPrint:QRCode(nLin+205, INI_COL+2000, Alltrim(cPathQRCod)+Alltrim(cCodVer), 65)

	nLin += SALTO_LIN + 10
	// oPrint:Say(nLin, INI_COL+10, "Nome/Razão Social: ", oFont12)
	oPrint:Say(nLin, aColImp[03], "Nome/Razão Social: ", oFont12)
	oPrint:Say(nLin, aColImp[06], cRazaoSocial, oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin,INI_COL+10,"CNPJ/CPF: ", oFont12)
	oPrint:Say(nLin, aColImp[03],"CNPJ/CPF: ", oFont12)
	oPrint:Say(nLin, aColImp[05], AllTrim(Transform(cCNPJ,"@R 99.999.999/9999-99")), oFont12N)

	oPrint:Say(nLin, aColImp[10],"Inscr. Municipal: ", oFont12)
	oPrint:Say(nLin, aColImp[12], Transform(cIM,"@R 999.999-9"), oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin,INI_COL+10,"Endereço: ", oFont12)
	oPrint:Say(nLin, aColImp[03],"Endereço: ", oFont12)
	oPrint:Say(nLin, aColImp[05], cEnd +" - "+ cBairro, oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin,INI_COL+10,"Município: ", oFont12)
	oPrint:Say(nLin, aColImp[03],"Município: ", oFont12)
	oPrint:Say(nLin, aColImp[05], cMunicipio, oFont12N)

	oPrint:Say(nLin, aColImp[11], "UF: ", oFont12)
	oPrint:Say(nLin, aColImp[12], cUF, oFont12N)
	
	oPrint:Say(nLin, aColImp[14], "CEP: ", oFont12)
	oPrint:Say(nLin, aColImp[15], AllTrim(Transform(cCEP, "@R 99999-999")), oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin,INI_COL+10, "Email: ", oFont12)
	oPrint:Say(nLin, aColImp[03], "E-mail: ", oFont12)
	oPrint:Say(nLin, aColImp[05], cEmail, oFont12N)

	oPrint:Say(nLin, aColImp[11],"Fone: ", oFont12)
	oPrint:Say(nLin, aColImp[12], cTelefone, oFont12N)

	nLin += SALTO_LIN / 2 //--20
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil 

/*
	Funçao responsavel pelos dados do intermediario
*/
Static Function Intermediario()
	Local cRazaoSocial	:= ""
	Local cCNPJ 		:= ""
	Local cMunicipio 	:= ""

	oPrint:Say(nLin, aColImp[8], "INTERMEDIÁRIO DE SERVIÇOS", oFont16N)

	nLin += SALTO_LIN + 10
	// oPrint:Say(nLin, INI_COL+10,"Nome/Razão Social: ", oFont12)
	oPrint:Say(nLin, aColImp[01],"Nome/Razão Social: ", oFont12)
	oPrint:Say(nLin, aColImp[04], cRazaoSocial, oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin, INI_COL+10,"CNPJ/CPF: ", oFont12)
	oPrint:Say(nLin, aColImp[01],"CNPJ/CPF: ", oFont12)
	oPrint:Say(nLin, aColImp[03], AllTrim(Transform(cCNPJ, "@R 99.999.999/9999-99")), oFont12N)
	oPrint:Say(nLin, aColImp[10],"Município: ", oFont12)
	oPrint:Say(nLin, aColImp[12], iif(Empty(cRazaoSocial),"",DescMun(cMunicipio,"")), oFont12N)

	nLin += SALTO_LIN / 2	//--20
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil

/*
	Funçao responsavel pelos dados do tomador
*/
Static Function Tomador()
	Local cRazaoSocial  := SA1->A1_NOME
	Local cCNPJ	 		:= allTrim(SA1->A1_CGC)
	Local cIM			:= SA1->A1_INSCRM
	Local cEnd 			:= allTrim(SA1->A1_END)
	Local cBairro		:= SA1->A1_BAIRRO
	Local cMun 			:= SA1->A1_MUN
	Local cUF 			:= SA1->A1_EST
	Local cCEP 			:= SA1->A1_CEP
	Local cEmail 		:= iif(SF2->(FieldPos("F2_XMAILNF"))>0, SF2->F2_XMAILNF, "")	//-SA1->A1_EMAIL
	Local cTelefone		:= SA1->A1_DDD + "-" + SA1->A1_TEL
	Local cMunPrest		:= SC5->C5_MUNPRES
	Local cMunInc		:= SC5->C5_MUNPRES
	Local cExigISS		:= "1"
	Local cProcesso		:= ""
	Local cISSRetido	:= retIssRetido()
	Local cIncFis 		:= "2"

	oPrint:Say(nLin, aColImp[8], "TOMADOR DE SERVIÇOS", oFont16N)

	nLin += SALTO_LIN + 10
	// oPrint:Say(nLin, INI_COL+10, "Nome/Razão Social: ", oFont12)
	oPrint:Say(nLin, aColImp[01], "Nome/Razão Social: ", oFont12)
	oPrint:Say(nLin, aColImp[04], cRazaoSocial, oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin, INI_COL+10,"CNPJ/CPF: ", oFont12)
	oPrint:Say(nLin, aColImp[01],"CNPJ/CPF: ", oFont12)
	If len(cCNPJ) == 14
		oPrint:Say(nLin, aColImp[03], AllTrim(Transform(cCNPJ, "@R 99.999.999/9999-99")), oFont12N)
	Else
		oPrint:Say(nLin, aColImp[03], AllTrim(Transform(cCNPJ, "@R 999.999.999-99")), oFont12N)
	EndIf

	oPrint:Say(nLin, aColImp[10],"Inscr. Municipal: ", oFont12)
	oPrint:Say(nLin, aColImp[12], cIM, oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin, INI_COL+10,"Endereço: ", oFont12)
	oPrint:Say(nLin, aColImp[01],"Endereço: ", oFont12)
	oPrint:Say(nLin, aColImp[03], cEnd +" - "+ cBairro, oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin, INI_COL+10,"Município: ", oFont12)
	oPrint:Say(nLin, aColImp[01],"Município: ", oFont12)
	oPrint:Say(nLin, aColImp[03], cMun, oFont12N)

	oPrint:Say(nLin, aColImp[11],"UF: ", oFont12)
	oPrint:Say(nLin, aColImp[12], cUF, oFont12N)
	
	oPrint:Say(nLin, aColImp[14],"CEP: ", oFont12)
	oPrint:Say(nLin, aColImp[15], AllTrim(Transform(cCEP, "@R 99999-999")), oFont12N)

	nLin += SALTO_LIN
	// oPrint:Say(nLin, INI_COL+10, "Email: ", oFont12)
	oPrint:Say(nLin, aColImp[01], "E-mail: ", oFont12)
	oPrint:Say(nLin, aColImp[03], cEmail, oFont12N)

	oPrint:Say(nLin, aColImp[11], "Fone: ", oFont12)
	oPrint:Say(nLin, aColImp[12], cTelefone, oFont12N)

	nLin += SALTO_LIN / 2	//--20
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])
	oPrint:Line(nLin, aColImp[10], nLin + 295, aColImp[10])

	///--->>> Novo Trecho / Box <<<---///
	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[02], "LOCAL DE INCIDÊNCIA DO IMPOSTO", oFont14N)
	oPrint:Say(nLin, aColImp[12], "LOCAL DE REALIZAÇÃO DO SERVIÇO", oFont14N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[01], DescMun(cMunInc, cUF), oFont12N)
	oPrint:Say(nLin, aColImp[10] + 50, DescMun(cMunPrest, cUF), oFont12N)

	nLin += SALTO_LIN / 2	//--20
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	///--->>> Novo Trecho / Box <<<---///
	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[02], "EXIGIBILIDADE DO ISS", oFont14N)
	oPrint:Say(nLin, aColImp[12], "NÚMERO DO PROCESSO", oFont14N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[01], ExigISS(cExigISS), oFont12N)
	oPrint:Say(nLin, aColImp[10] + 50, cProcesso, oFont12N)

	nLin += SALTO_LIN / 2	//--20
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	///--->>> Novo Trecho / Box <<<---///
	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[02], "ISS RETIDO",	oFont14N)
	oPrint:Say(nLin, aColImp[12], "INCENTIVO FISCAL", oFont14N)

	nLin += SALTO_LIN
	oPrint:Say(nLin, aColImp[01], IIF(cISSRetido == "1", "SIM", "NÃO"), oFont12N)
	oPrint:Say(nLin, aColImp[10] + 50, IIF(cIncFis == "1", "SIM", "NÃO") , oFont12N)

	nLin += SALTO_LIN / 2	//--20
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil 

/*
	Funçao responsavel pelos dados do serviço prestado
*/
Static Function Servico()
	Local aDesc 	:= {} 
	Local nQtdLin	:= 0
	Local nLinha 	:= 0
	Local nDesc 	:= 0
	Local nR		:= 0
	local cMsgObs	:= ""

	aDesc := StrTokArr(SX5->X5_CHAVE+" "+AllTrim(SX5->X5_DESCRI)+CHR(13)+CHR(10) /*--( +SC5->C5_ZZMSGNF )--*/, CHR(13)+CHR(10))
	
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

	oPrint:Say(nLin, aColImp[8]-15, "DESCRIÇÃO DOS SERVIÇOS", oFont16N)

	nLin += SALTO_LIN + 10

	For nDesc := 1 To Len(aDesc)

		nQtdLin	:= MLCount(aDesc[nDesc], TAM_DESC)

		For nLinha := 1 To nQtdLin
			
			If nDesc == 1
				oPrint:Say(nLin,aColImp[01], MemoLine(aDesc[nDesc], TAM_DESC, nLinha), oFont12N)
			Else
				oPrint:Say(nLin,aColImp[01], MemoLine(aDesc[nDesc], TAM_DESC, nLinha), oFont12)
			EndIf

			nLin += SALTO_LIN

		Next nLinha 
	Next nDesc 

	//-Imprime a Aliqupta, Abatimento e Observaçoes (1/2)
	oPrint:Say(nLin, aColImp[01], "Alíquota: " +Alltrim(Str(SD2->D2_ALIQISS,12,10)), oFont12)
	oPrint:Say(nLin, aColImp[05], "Abatimento: " +Alltrim(Str(SD2->D2_ABATISS,12,02)), oFont12)

	nLin += SALTO_LIN
	cMsgObs := "CARO CLIENTE, INFORMAMOS QUE O RECOLHIMENTO DO ISSQN É DE OBRIGATORIEDADE DA "+Alltrim(SM0->M0_NOMECOM)+", "
	oPrint:Say(nLin, aColImp[01], cMsgObs, oFont12)

	nLin += SALTO_LIN
	// cMsgObs := "PORTANTO SOLICITAMOS A GENTILEZA NÃO RETER O IMPOSTO."
	cMsgObs := "GENTILEZA NÃO RETER."+" SERVIÇOS REFERENTE A ANÁLISES EM ALIMENTOS."
	oPrint:Say(nLin, aColImp[01], cMsgObs, oFont12)
/*--
	nLin += SALTO_LIN
	cMsgObs := "SERVIÇOS REFERENTE A ANÁLISES EM ALIMENTOS."
	oPrint:Say(nLin, aColImp[01], cMsgObs, oFont12)
*/
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
	Local cISSRetido	:= retIssRetido()
	Local cVlrSTISS		:= 0
	Local cMsgObs		:= ""

	Private cVlrIR 		:= 0
	Private cVlrPIS  	:= 0                                
	Private cVlrCofins 	:= 0
	Private cVlrCSLL 	:= 0
    Private cVlrINSS	:= 0
	Private cVlrISS		:= SF2->F2_VALISS	//-Valor do ISS na NFSe

	//-----------------------------------------
	GetDuplic()	//-Busca os Impostos da NF
	//-----------------------------------------

	cVlrSTISS := IIF(cISSRetido == "1", cVlrISS, 0)
	// cVlrLiq   := cVlrLiq - cVlrISS - cVlrINSS
	cVlrLiq   := cVlrLiq - cVlrINSS - cVlrIR - cVlrCSLL - cVlrCofins - cVlrPIS - cVlrSTISS - cVlrOutRed

	//-Redefine a linha para impressao dos trechos do Rodape
	// nLin := 2350
	nLin := 2300 - ( SALTO_LIN * 3 )	//-->>
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN
	oPrint:Say(nLin,aColImp[8]-10, "VALOR(ES) DE RETENÇÃO(ÕES)", oFont16N)

	nLin += SALTO_LIN / 2
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	oPrint:Line(nLin, aColImp[03], nLin + 90, aColImp[03])
	oPrint:Line(nLin, aColImp[06], nLin + 90, aColImp[06])
	oPrint:Line(nLin, aColImp[09], nLin + 90, aColImp[09])
	oPrint:Line(nLin, aColImp[12], nLin + 90, aColImp[12])
	oPrint:Line(nLin, aColImp[14], nLin + 90, aColImp[14])
	oPrint:Line(nLin, aColImp[17], nLin + 90, aColImp[17])

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL + 10, 		"INSS", 			oFont12)
	oPrint:Say(nLin, aColImp[03] + 10, 	"IR", 				oFont12)
	oPrint:Say(nLin, aColImp[06] + 10, 	"CSLL", 			oFont12)
	oPrint:Say(nLin, aColImp[09] + 10, 	"COFINS", 			oFont12)
	oPrint:Say(nLin, aColImp[12] + 10, 	"PIS", 				oFont12)
	oPrint:Say(nLin, aColImp[14] + 10, 	"Sub. Trib. ISS", 	oFont12)
	oPrint:Say(nLin, aColImp[17] + 10, 	"Outras Retenções",	oFont12)

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL + 10, 		AllTrim(Transform(cVlrINSS, 	PesqPict("SF2", "F2_VALINSS"))), 	oFont12N)
	oPrint:Say(nLin, aColImp[03] + 10, 	AllTrim(Transform(cVlrIR, 		PesqPict("SF2", "F2_VALIRRF"))), 	oFont12N)
	oPrint:Say(nLin, aColImp[06] + 10, 	AllTrim(Transform(cVlrCSLL, 	PesqPict("SF2", "F2_VALCSLL"))), 	oFont12N)
	oPrint:Say(nLin, aColImp[09] + 10, 	AllTrim(Transform(cVlrCofins, 	PesqPict("SF2", "F2_VALCOFI"))),	oFont12N)
	oPrint:Say(nLin, aColImp[12] + 10, 	AllTrim(Transform(cVlrPIS, 		PesqPict("SF2", "F2_VALPIS"))), 	oFont12N)
	oPrint:Say(nLin, aColImp[14] + 10, 	AllTrim(Transform(cVlrSTISS, 	PesqPict("SF2", "F2_VALPIS"))), 	oFont12N)
	oPrint:Say(nLin, aColImp[17] + 10, 	AllTrim(Transform(cVlrOutRed,	PesqPict("SF2", "F2_VALPIS"))), 	oFont12N)

	nLin += SALTO_LIN2 //SALTO_LIN
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN
	oPrint:Say(nLin,aColImp[9], "OBSERVAÇÕES", oFont16N)

	nLin += SALTO_LIN
	//-----------------------------------------
	cMsgObs := oNFSePDF:getMensag_NFSeMain()
	//-----------------------------------------
	oPrint:Say(nLin,aColImp[01], SubStr(cMsgObs,1,133), oFont12)
	nLin += SALTO_LIN
	oPrint:Say(nLin,aColImp[01], iif(Len(cMsgObs)>133, SubStr(cMsgObs,134,133), ""), oFont12)
	nLin += SALTO_LIN
	oPrint:Say(nLin,aColImp[01], iif(Len(cMsgObs)>267, SubStr(cMsgObs,268,133), ""), oFont12)

	nLin += SALTO_LIN //* 2 //-->>
	
	nLin += SALTO_LIN2 //SALTO_LIN
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])
	oPrint:Line(nLin, aColImp[05], nLin + 90, aColImp[05])
	oPrint:Line(nLin, aColImp[09], nLin + 90, aColImp[09])
	oPrint:Line(nLin, aColImp[13], nLin + 90, aColImp[13])
	oPrint:Line(nLin, aColImp[17], nLin + 90, aColImp[17])

	nLin += SALTO_LIN
	oPrint:Say(nLin,INI_COL + 10, 		"Valor Total Deduções", oFont12)
	oPrint:Say(nLin,aColImp[05] + 10,	"Base de Cálculo", 		oFont12)
	oPrint:Say(nLin,aColImp[09] + 10, 	"Valor do ISS", 		oFont12)
	oPrint:Say(nLin,aColImp[13] + 10, 	"Valor Líquido",		oFont12)
	oPrint:Say(nLin,aColImp[17] + 10, 	"Valor do Serviço", 	oFont12)

	nLin += SALTO_LIN
	oPrint:Say(nLin,INI_COL + 10, 		AllTrim(Transform(cVlrDed,		PesqPict("SF2", "F2_BASEISS"))), 	oFont12N)
	oPrint:Say(nLin,aColImp[05] + 10,	AllTrim(Transform(cBaseCalc,	PesqPict("SF2", "F2_BASEISS"))), 	oFont12N)
	oPrint:Say(nLin,aColImp[09] + 10, 	AllTrim(Transform(cVlrISS, 		PesqPict("SF2", "F2_VALISS"))),		oFont12N)
	oPrint:Say(nLin,aColImp[13] + 10, 	AllTrim(Transform(cVlrLiq, 		PesqPict("SF2", "F2_VALFAT"))),  	oFont12N)
	oPrint:Say(nLin,aColImp[17] + 10, 	AllTrim(Transform(cVlrServ, 	PesqPict("SF3", "F3_VALCONT"))), 	oFont12N)

	nLin += SALTO_LIN2 //SALTO_LIN
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil 

/*
	Funçao responsavel pelos dados da construçao civil, se existir
*/
Static Function ConstrucaoCivil()
	Local cCEI := ""
	Local cART := ""

	oPrint:Say(nLin, aColImp[6], "DETALHAMENTO ESPECÍFICO DA CONSTRUÇÃO CIVIL", oFont16N)
	
	nLin += SALTO_LIN / 2
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])
	oPrint:Line(nLin, aColImp[10], nLin + 90, aColImp[10])

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL + 10, "Nr. Matricula CEI", 	oFont12)
	oPrint:Say(nLin, aColImp[10] + 20, "Nr. da ART", 		oFont12)
	
	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL + 10, cCEI, oFont12)
	oPrint:Say(nLin, aColImp[10] + 20, cART, oFont12)
	
	nLin += SALTO_LIN2 //SALTO_LIN
	oPrint:Line(nLin, INI_COL, nLin, aColImp[20])

	nLin += SALTO_LIN

Return Nil 

/*
	Funçao responsavel pelos dados de outras informaçoes
*/
Static Function OutrasInformacoes()
	
	oPrint:Say(nLin, aColImp[8], "OUTRAS INFORMAÇÕES", oFont16N)
	
	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL + 10, "- Para verificar a autenticidade desta nota acesse: www.indaiatuba.sp.gov.br/fazenda/rendas-mobiliarias/nfse/consulta/", oFont12)

	nLin += SALTO_LIN
	oPrint:Say(nLin, INI_COL + 10, "- A emissão desta Nota Fiscal de Serviços Eletrônica foi autorizada pelo processo No 27643/2009", oFont12)	//-"936/2010"

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

	if Empty(cDesc)
		cDesc := "INDAIATUBA - SP"
	endif

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
    cQuery += " 	AND E1_CLIENTE 	= '"+ SF2->F2_CLIENTE +"' " + CRLF   
    cQuery += " 	AND E1_LOJA 	= '"+ SF2->F2_LOJA +"' " + CRLF  
	cQuery += " 	AND E1_PREFIXO 	= '"+ SF2->F2_SERIE +"' " + CRLF  
	cQuery += " 	AND E1_NUM 		= '"+ SF2->F2_DOC +"' " + CRLF  
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
