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
#Define	INI_COL 		0.5
#Define FIM_COL         20.5
#Define	INI_LIN 		0.5
#Define FIM_LIN         26.5
#Define CAMPO 			1
#Define VALOR 			2
#Define TAM_DESC		160
#Define CONFIRMA 		1

#Define POSLOGO			4.5

#DEFINE POSDATAHORA		4.5

#Define DATAHORA		7.5

#Define POSCOMPETEC		11

#Define COMPETENCIA		13

#Define POSVERIFIC		16.5

#Define VERIFICACAO		20.5

#Define TAM_LINHA		0.5

/*/{Protheus.doc} NFSe43907
Gera a NF Servi�o de Rio Claro / SP (IBGE = 43907)
@type function
@version 1.0
@author R�gis Ferreira
@since 02/08/2024
@link 
@see https://www.indaiatuba.sp.gov.br/fazenda/rendas-mobiliarias/nfse
/*/
User Function NFSe43907(cNFSeFil,cNFSeNum,cNFSeSer,cNFSeCli,cNFSeLoj,cModNFSe,lPreview,cCodVer)

	Local cNFSe 		:= ""

	Default cNFSeFil 	:= cFilAnt
	Default cNFSeNum 	:= "000023933"
	Default cNFSeSer 	:= "J  "
	Default cNFSeCli 	:= "001456"
	Default cNFSeLoj 	:= "01"
	Default cModNFSe 	:= SuperGetMV("ZZ_43907MD",.F.,"000001")				//-Rio Claro!
	Default lPreview 	:= .F.
	Default cCodVer		:= "EGBZTULHI"

	Private cLogoEmpr  	:= SuperGetMV("ZZ_NFSESM0",.F.,"")						//-Logo da Empresa/Cliente
	Private cLogoPref  	:= SuperGetMV("ZZ_43907LG",.F.,"")						//-Logo da Prefeitura Municipal
	Private cPathQRCod 	:= SuperGetMV("ZZ_43907QR",.F.,"")						//-QRCode com o link de consulta da NFSe
	Private oRetangulo  := Nil
	Private oPrint		:= Nil

	Private cMailTomador:= ""
	Private cCodIss		:= ""
	Private cCodTrib	:= ""
	Private nPercIss	:= ""

	cLogoEmpr  			:= iif(!Empty(cLogoEmpr),  Alltrim(cLogoEmpr),  "D:\iCloud\OneDrive\_GitHub_\Totvs-Protheus\fGeeker\eurofins\eurofins-desenv\NF-Servicos\Imagens\logo-eurofins.png")
	cLogoPref  			:= iif(!Empty(cLogoPref),  Alltrim(cLogoPref),  "c:\temp\logo_rioclaro.png")

    Private x         	:=72/2.54

	//-Posiciona na NFSe - SF2/SD2
	SF2->(DbSetOrder(1))	//-F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	if SF2->(DbSeek(cNFSeFil+cNFSeNum+cNFSeSer+cNFSeCli+cNFSeLoj,.F.))
		cPathQRCod 			:= iif(!Empty(cPathQRCod), Alltrim(cPathQRCod)+cCodVer+"&numNota="+Alltrim(SF2->F2_NFELETR)+"&cnpjPrestador=null", "https://visualizar.ginfes.com.br/report/consultarNota?__report=nfs_ver4&cdVerificacao="+cCodVer+"&numNota="+cNFSeFil+"&cnpjPrestador=null")

		SD2->(DbSetOrder(3))	//-D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		if SD2->(DbSeek(cNFSeFil+cNFSeNum+cNFSeSer+cNFSeCli+cNFSeLoj,.F.))
			GetMailstomador(cNFSeFil,cNFSeNum,cNFSeSer,cNFSeCli,cNFSeLoj)
			cNFSe := ImpRelNFSe(lPreview)

		endif
	endif

Return cNFSe

/*
	Fun�ao principal do inicio do processamento
*/
Static Function ImpRelNFSe(lPreview)

	Local cDirectory		:= GetSrvProfString("ROOTPATH","")+SuperGetMV("ZZ_NFSEPDF",.F.,"\NFSE\")
	Local cNumNFSe			:= iif(Empty(SF2->F2_NFELETR),SF2->F2_DOC,SF2->F2_NFELETR)
	Local cFilePrint 		:= "NFSE_"+Alltrim(RetCodUsr())+"_"+Alltrim(SM0->M0_CODFIL)+"_"+Alltrim(cNumNFSe)+iif(Empty(Alltrim(SF2->F2_SERIE)),"","_"+Alltrim(SF2->F2_SERIE))+".pdf"
	Local cFilePDF			:= ""
	Local nDevice			:= IMP_PDF 
	Local lAdjustToLegacy	:= .F.		//-Inibe legado de resolu��o com a TMSPrinter
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
	Private oFont18 	:= TFont():New("Arial", 18, 18,, .F.,,,,, .F., .F.)
	Private oFont18N 	:= TFont():New("Arial", 18, 18,, .T.,,,,, .F., .F.)
	Private oFont20N 	:= TFont():New("Arial", 20, 20,, .T.,,,,, .F., .F.)
	Private oBrush		:= TBrush():New(, CLR_HGRAY)

	if type("cDirNFSe")<>"U"
		cDirectory := Alltrim(cDirNFSe)
	endif

	oPrint := FWMSPrinter():New(cFilePrint, nDevice, lAdjustToLegacy, cDirectory, lDisabeSetup)	
	
	cFilePDF := cDirectory+cFilePrint	// Alltrim(RetCodUsr())+"\"+
	fErase(cFilePDF)

	If !lPreview .Or. (lPreview .And. oPrint:nModalResult == CONFIRMA) 
		
		oPrint:setmargin(x,0,0,0)
		oPrint:SetPortrait(.T.)
		oPrint:SetPaperSize(PAPEL_A4)
		oPrint:SetViewPDF(lPreview)

		If !lPreview
			oPrint:cPathPDF := cDirectory	// +Alltrim(RetCodUsr())+"\"
		EndIf 

		//nLimiteHoz  := oPrint:nHorzRes() - INI_COL
		//nLimiteVer	:= oPrint:nVertRes() - FIM_COL
		nTamCol     := 1

		For nItem := 1 To 20
			aAdd(aColImp, nItem * nTamCol)	
		Next nItem	

		SA1->(DbSetOrder(1))
		if SA1->(DbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))

			SC5->(DbSetOrder(3))	//-C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
			if SC5->(DbSeek(xFilial("SC5")+SD2->(D2_CLIENTE+D2_LOJA+D2_PEDIDO)))

				SE1->(DbSetOrder(2))	//-E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				if SE1->(DbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)))

					SX5->(DbSetOrder(1))
					if SX5->(DbSeek(xFilial("SX5")+"60"+SD2->D2_CODISS))
						cCodTrib:= Alltrim(GetAdvfVal("SB1","B1_TRIBMUN",xFilial("SB1")+SD2->D2_COD,1,""))
						cCodIss := Transform(Alltrim(SD2->D2_CODISS),"@R 99.99")+iif(Empty(cCodTrib),""," / " +cCodTrib)+" - "+Alltrim(Upper(SX5->X5_DESCRI))
						nPercIss:= SD2->D2_ALIQISS

						Cabec()
						NFSe()
						Prestador()
						Tomador()
						Discriminacao()
						Servico()
						Impostos()
						OutrasInformacoes()

						oPrint:Endpage()
						// oPrint:Print()	//-Envia o relat�rio para impressora
						oPrint:Preview()	//-Envia o relat�rio para tela
					endif
				endif
			endif
		endif
	EndIf 

	//ShellExecute("Open",cFilePDF,"","",1)

	if !File(cFilePDF)
		cFilePDF := ""
		if type("oNFSePDF") == "O"
			oNFSePDF:cError := "N�o foi poss�vel gerar o arquivo PDF"
		endif
	endIf

Return cFilePDF

/*
	Fun�ao responsavel pelos dados do cabe�alho da NF - parte 1
*/
Static Function Cabec()
	
	Local cNumNFSe	:= iif(Empty(SF2->F2_NFELETR),SF2->F2_DOC,SF2->F2_NFELETR)

	nLin := 0.7
	//Vou deixar o BOX inteiro cinza
	Linha(INI_LIN,INI_COL,FIM_LIN,FIM_COL,0.5,"CINZA")
	
	//Box do Logo
	Linha(INI_LIN,INI_COL,INI_LIN+2.5,POSLOGO,0.5)
	//Logo da prefeitura
	oPrint:SayBitmap((INI_LIN+0.2)*x, (INI_COL+0.7)*x, Alltrim(cLogoPref), 80, 60)

	//Separa o logo do t�ulo
	Linha(INI_LIN,POSLOGO-0.2,INI_LIN+2.5,INI_COL+14.5,0.5)

	Say(nLin,6,"PREFEITURA MUNICIPAL DE RIO CLARO",oFont14)
	Say(nLin + TAM_LINHA+0.1,5.4,"SECRETARIA MUNICIPAL DE ECONOMIA E",oFont16)
	Say(nLin + (TAM_LINHA*2.5),4.7,"NOTA FISCAL ELETR�NICA DE SERVI�O - NFSE",oFont16)

	//Separa o t�tulo do N�mero da NFSE
	Linha(INI_LIN,INI_COL+14.5,INI_LIN+2.5,INI_COL+17,0.5)
	Say(nLin,15.2,"N�mero da",oFont16)
	Say(nLin+TAM_LINHA,15.7,"NFS-e",oFont16)
	Say(nLin+(TAM_LINHA*2.5),15.7,cNumNFSe,oFont14)

	//Separa a NFSE do QrCode
	Linha(INI_LIN,INI_COL+17,INI_LIN+2.5,FIM_COL,0.5)

	oPrint:QRCode(2.95*x,17.8*x,cPathQRCod, 70)

	nLin := INI_LIN+2.5

Return Nil

/*
	Fun�ao responsavel pelos dados do cabe�alho da NF - parte 2
*/
Static Function NFSe()

	Local aDtEmisRPS	:= iif(!Empty(SF2->F2_NFELETR),{dToc(SF2->F2_EMINFE),Left(SF2->F2_HORNFE,5)},{dToc(SF2->F2_EMISSAO),Left(SF2->F2_HORA,5)})
	Local cNumRPS		:= SF2->F2_DOC
	Local cCodVer 		:= Alltrim(SF2->F2_CODNFE)
	Local cRPSSub		:= ""
	Local dCompentecia 	:= dToc(iif(!Empty(SF2->F2_NFELETR),SF2->F2_EMINFE,SF2->F2_EMISSAO))
	Local nFimLin		:= 0

	//Box Data e hora da Emiss�o
	nFimLin := nLin+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.1,0.7,"Data e Hora da Emiss�o",oFont12)
	
	//Data e hora
	Linha(nLin,POSDATAHORA,nFimLin,DATAHORA,0.5)
	Say(nLin+0.1,4.8,aDtEmisRPS[1]+" "+aDtEmisRPS[2],oFont12)

	//Box Compet�ncia
	Linha(nLin,DATAHORA,nFimLin,DATAHORA,0.5) 
	Say(nLin+0.1,8.2,"Compet�ncia",oFont12)

	//Competencia
	Linha(nLin,POSCOMPETEC,nFimLin,COMPETENCIA,0.5)
	Say(nLin+0.1,11.2,dCompentecia,oFont12)

	//Box C�d. Verifica��o
	Linha(nLin,COMPETENCIA,nFimLin,COMPETENCIA,0.5) 
	Say(nLin+0.1,13.1,"C�digo de Verifica��o",oFont12)
	
	//C�digo de Verifica��o
	Linha(nLin,POSVERIFIC,nFimLin,FIM_COL,0.5)
	Say(nLin+0.1,17,cCodVer,oFont12)

	//Linha de baixo

	//Box do N�mero do RPS
	nLin := nFimLin
	nFimLin := nLin+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin-0.02,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin-0.02,FIM_COL,0.5) //Linha final
	Say(nLin+0.1,1.1,"N�mero do RPS",oFont12)

	//N�mero do RPS
	Linha(nLin,POSDATAHORA,nFimLin,DATAHORA,0.5)
	Say(nLin+0.1,5,cNumRPS,oFont12)

	//Box N� da NFSe - Substu�da
	Linha(nLin,DATAHORA,nFimLin,DATAHORA,0.5)
	Say(nLin+0.1,7.7,"N� NFSe Substitu�da",oFont12)

	//NFSe Substit�ida
	Linha(nLin,POSCOMPETEC,nFimLin,COMPETENCIA,0.5)
	Say(nLin+0.1,5,cRPSSub,oFont12)

	//Box Local de Presta��o
	Linha(nLin,COMPETENCIA,nFimLin,COMPETENCIA,0.5)
	Say(nLin+0.1,13.3,"Local da Presta��o",oFont12)

	//Local de Presta��o
	Linha(nLin,POSVERIFIC,nFimLin,FIM_COL,0.5)
	Say(nLin+0.1,17,"RIO CLARO - SP",oFont12)

	nLin := nFimLin

Return Nil 

/*
	Fun�ao responsavel pelos dados do prestador de servi�o
*/
Static Function Prestador()
	Local cRazaoSocial	:= Upper(SM0->M0_NOMECOM)
	Local cCNPJ 		:= Alltrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))
	Local cIM 			:= Alltrim(SM0->M0_INSCM)
	Local cEnd 			:= Upper(Alltrim(SM0->M0_ENDENT)+" - "+Alltrim(SM0->M0_BAIRENT)+" - CEP: "+Alltrim(Transform(SM0->M0_CEPENT, "@R 99999-99")))
	Local cMunicipio	:= Upper(Alltrim(SM0->M0_CIDENT)+"/"+Alltrim(SM0->M0_ESTENT))
	Local cComplem		:= Upper(Alltrim(SM0->(M0_COMPENT)))
	Local cEmail 		:= Alltrim(SuperGetMV("ZZ_NFSEEML", .F., "faturamento-ambiental-rc@eurofinslatam.com", cFilAnt)) 
	Local cTelefone 	:= Alltrim(SuperGetMV("ZZ_NFSETEL", .F., "(19) 2112-8900", cFilAnt)) 

	nFimLin := nLin-0.02+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,7.8,"Dados do Prestador de Servi�o",oFont12N)

	nLin := nFimLin

	//box para Logo da Empresa
	Linha(nLin,INI_COL,(nLin+3)-0.15,INI_COL+2.5,0.5) //Linha da esquerda

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)
	//Raz�o Social
	Linha(nLin,6,nFimLin,FIM_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL+2.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,3.5,"Raz�o Social",oFont12)
	Say(nLin+0.07,6.2,cRazaoSocial,oFont12)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)
	//Nome Fantasia
	Linha(nLin,6,nFimLin+0.02,FIM_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL+2.5,nFimLin,FIM_COL,0.5) //Linha transversal
	//Linha(nLin,FIM_COL,nFimLin-0.02,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,3.5,"Nome Fantasia",oFont12)
	Say(nLin+0.07,6.2,"EUROFINS AMBIENTAL",oFont12)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)
	//CPF/CNPJ
	Linha(nLin,5,nFimLin,8.5,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL+2.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,3.1,"CPF/CNPJ",oFont12)
	Say(nLin+0.07,5.2,cCNPJ,oFont12)

	//Insri��o Municipal
	Linha(nLin,8.5,nFimLin,8.5,0.5)
	Linha(nLin,11.9,nFimLin,14,0.5)
	Say(nLin+0.07,8.8,"Inscri��o Municipal",oFont12)
	Say(nLin+0.07,12.02,cIM,oFont12)

	//Munic�pio/estado
	Linha(nLin,16,nFimLin-0.02,16,0.5)
	Linha(nLin,16,nFimLin,FIM_COL-0.02,0.5)
	Say(nLin+0.07,14.1,"Munic�pio",oFont12)
	Say(nLin+0.07,16.2,cMunicipio,oFont12)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)
	//Endere�o e CEP
	Linha(nLin,6,nFimLin,FIM_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL+2.5,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin-0.02,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,3.1,"Endere�o e Cep",oFont12)
	Say(nLin+0.07,6.2,cEnd,oFont12)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)
	//Complemento
	Linha(nLin-0.02,5.4,nFimLin-0.02,7.5,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL+2.5,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin-0.02,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,3.1,"Complemento:",oFont12)
	Say(nLin+0.07,5.6,cComplem,oFont12)

	//Telefone
	Linha(nLin,9.1,nFimLin-0.04,9.1,0.5) //Linha da esquerda
	Linha(nLin-0.02,9.1,nFimLin-0.04,11.8,0.5) //Linha final
	Say(nLin+0.07,7.6,"Telefone:",oFont12)
	Say(nLin+0.07,9.3,cTelefone,oFont12)

	//E-mail
	Linha(nLin,13,nFimLin-0.04,13,0.5) //Linha da esquerda
	Linha(nLin-0.02,12.98,nFimLin-0.04,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,11.9,"E-mail:",oFont12)
	Say(nLin+0.07,13.2,cEmail,oFont12)

	nLin := nFimLin-0.04

Return Nil 

/*
	Fun�ao responsavel pelos dados do tomador
*/
Static Function Tomador()
	
	Local cRazaoSocial  := SA1->A1_NOME
	Local cCNPJ	 		:= Alltrim(SA1->A1_CGC)
	Local cIM			:= Alltrim(SA1->A1_INSCRM)
	Local cEnd 			:= Upper(Alltrim(SA1->A1_END)+" - "+Alltrim(SA1->A1_BAIRRO)+" CEP: "+Alltrim(Transform(SA1->A1_CEP,"@R 99999-999")))
	Local cMun 			:= Upper(Alltrim(SA1->A1_MUN)+"/"+Alltrim(SA1->A1_EST))
	Local cEmail 		:= cMailTomador
	Local cTelefone		:= Alltrim(SA1->A1_DDD) + "-" + Alltrim(SA1->A1_TEL)
	Local cComplem		:= Left(Upper(Alltrim(SA1->A1_COMPLEM)),16)

	nFimLin := nLin-0.02+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,7.8,"Dados do Tomador de Servi�o",oFont12N)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Raz�o Social/Nome
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,INI_COL+3.5,0.5) //Linha transversal
	Linha(nLin,INI_COL+3.5,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"Raz�o Social/Nome",oFont12)
	Say(nLin+0.07,INI_COL+3.6,cRazaoSocial,oFont12)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	If len(cCNPJ) == 14
		cCNPJ := Alltrim(Transform(cCNPJ, "@R 99.999.999/9999-99"))
	Else
		cCNPJ := Alltrim(Transform(cCNPJ, "@R 999.999.999-99"))
	EndIf

	//CNPJ/CPF
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,INI_COL+2,nFimLin+0.02,INI_COL+5.6,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"CNPJ/CPF",oFont12)
	Say(nLin+0.07,INI_COL+2.3,cCNPJ,oFont12)

	//Inscri��o municipal
	Linha(nLin,INI_COL+9,nFimLin,INI_COL+9,0.5) //Linha da esquerda
	Linha(nLin,INI_COL+9,nFimLin+0.02,INI_COL+11,0.5) //Linha final
	Say(nLin+0.07,INI_COL+5.8,"Inscri��o Municipal",oFont12)
	Say(nLin+0.07,INI_COL+9.2,cIM,oFont12)

	//Munic�pio
	Linha(nLin,INI_COL+12.8,nFimLin,INI_COL+12.8,0.5) //Linha da esquerda
	Linha(nLin,INI_COL+12.8,nFimLin+0.02,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,INI_COL+11.1,"Munic�pio",oFont12)
	Say(nLin+0.07,INI_COL+13,cMun,oFont12)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Endere�o e CEP
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,INI_COL+3,0.5) //Linha transversal
	Linha(nLin,INI_COL+3,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"Endere�o e CEP",oFont12)
	Say(nLin+0.07,INI_COL+3.1,cEnd,oFont12)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Complemento
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,INI_COL+2.3,nFimLin,INI_COL+5.6,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"Complemento",oFont12)
	Say(nLin+0.07,INI_COL+2.4,cComplem,oFont12)

	//telefone
	Linha(nLin,INI_COL+7.3,nFimLin,INI_COL+7.3,0.5) //Linha da esquerda
	Linha(nLin,INI_COL+7.3,nFimLin,INI_COL+11,0.5) //Linha final
	Say(nLin+0.07,INI_COL+5.8,"Telefone",oFont12)
	Say(nLin+0.07,INI_COL+7.4,cTelefone,oFont12)

	//e-mail
	Linha(nLin,INI_COL+12.6,nFimLin,INI_COL+12.6,0.5) //Linha da esquerda
	Linha(nLin,INI_COL+12.6,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,INI_COL+11.1,"e-mail",oFont12)
	Say(nLin+0.07,INI_COL+12.7,cEmail,oFont10)

	nLin := nFimLin-0.04

Return Nil 

/*
Fun��o respons�vel por colocar a discrimina��o do servi�o prestado
*/
Static Function Discriminacao()

	Local cMsgObs	:= ""
	Local nOBS 		:= 0
	Local aMsg		:= {}

	nFimLin := nLin-0.02+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,8,"Discrimina��o dos Servi�os",oFont12N)

	//Caixa com a dicrimina��o
	nLin := nFimLin
	nFimLin := nLin-0.02+((TAM_LINHA*7)*1.3)
	Linha(nLin,INI_COL,nFimLin,FIM_COL,0.5) //caixa da discrimina��o

	//-----------------------------------------
	cMsgObs := oNFSePDF:getMensag_NFSeMain()
	//-----------------------------------------
	aMsg := QuebraMensagem(cMsgObs)
	For nOBS := 1 to len(aMsg)
		if !Empty(Alltrim(Upper(aMsg[nOBS])))		
			Say(nLin,INI_COL+0.1,Alltrim(Upper(aMsg[nOBS])),oFont10)

			nLin := nLin + TAM_LINHA-0.1
		endif
	Next nOBs
	
	nLin := nFimLin-0.04

Return
/*
	Fun�ao responsavel pelos dados do servi�o prestado
*/
Static Function Servico()
	
	nFimLin := nLin-0.02+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,8,"C�digo do Servi�o / Atividade",oFont12N)

	//C�digo do Servi�o / Atividade
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin,FIM_COL,0.5) //caixa da discrimina��o
	Say(nLin+0.07,6.5,cCodIss,oFont12N)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,7,"Detalhamento Espec�fico da Constru��o C�vil",oFont12N)

	//Caixa de C�digo da Obra e C�digo ART
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//C�digo da Obra
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,INI_COL+5,nFimLin,INI_COL+10,0.5) //Linha final
	Say(nLin+0.07,INI_COL+1.5,"C�digo da Obra",oFont12)

	//C�digo ART
	Linha(nLin,INI_COL+10,nFimLin,INI_COL+10,0.5) //Linha da esquerda
	Linha(nLin,INI_COL+15,nFimLin,INI_COL+20,0.5) //Linha final
	Say(nLin+0.07,INI_COL+11.5,"C�digo ART",oFont12)

	nLin := nFimLin-0.04

Return Nil

/*
	Fun�ao responsavel pelos dados dos impostos
*/
Static Function Impostos()
	Local cVlrOutRed 	:= 0
	Local cBaseCalc		:= SF2->F2_BASEISS
	Local cVlrLiq		:= SF2->F2_BASEISS
	Local cVlrServ		:= SF2->F2_VALBRUT
	Local cISSRetido	:= retIssRetido()
	Local cVlrSTISS		:= 0
	Local nTamCol		:= 0
	Local nTamLinAnt	:= 0
	Local nTotFederal	:= 0

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
	cVlrLiq   := cVlrLiq - cVlrINSS - cVlrIR - cVlrCSLL - cVlrCofins - cVlrPIS - cVlrSTISS - cVlrOutRed

	nTotFederal := cVlrPIS + cVlrCofins + cVlrIR + cVlrINSS + cVlrCSLL

	nFimLin := nLin-0.02+(TAM_LINHA*1.3)
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,9,"Tributos Federais",oFont12N)

	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5)

	nTamCol 	:= nTamCol + 1.8
	nTamLinAnt	:= nTamCol
	//Caixa em branco
	Linha(nLin,INI_COL,nFimLin+0.02,INI_COL+nTamCol,0.5)

	//PIS
	nTamLinAnt	:= nTamCol
	nTamCol := nTamCol + 1.8
	Linha(nLin,nTamCol,nFimLin,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.7,"PIS",oFont12)

	//Valor do PIS
	nTamLinAnt	:= nTamCol
	nTamCol 	:= nTamCol + 1.8
	Linha(nLin,nTamLinAnt,nFimLin+0.02,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,Alltrim(iif(cVlrPIS<=0,"",Transform(cVlrPIS,PesqPict("SD2","D2_TOTAL")))),oFont12)

	//COFINS
	nTamLinAnt	:= nTamCol
	nTamCol := nTamCol + 1.8
	Linha(nLin,nTamCol,nFimLin,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,"COFINS",oFont12)

	//Valor do COFINS
	nTamLinAnt	:= nTamCol
	nTamCol 	:= nTamCol + 1.8
	Linha(nLin,nTamLinAnt,nFimLin+0.02,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,Alltrim(iif(cVlrCofins<=0,"",Transform(cVlrCofins,PesqPict("SD2","D2_TOTAL")))),oFont12)

	//IR(R$)
	nTamLinAnt	:= nTamCol
	nTamCol := nTamCol + 1.8
	Linha(nLin,nTamCol,nFimLin,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,"IR(R$)",oFont12)

	//Valor do IR(R$)
	nTamLinAnt	:= nTamCol
	nTamCol 	:= nTamCol + 1.8
	Linha(nLin,nTamLinAnt,nFimLin+0.02,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,Alltrim(iif(cVlrIR<=0,"",Transform(cVlrIR,PesqPict("SD2","D2_TOTAL")))),oFont12)

	//INSS(R$)
	nTamLinAnt	:= nTamCol
	nTamCol := nTamCol + 1.8
	Linha(nLin,nTamCol,nFimLin,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,"INSS(R$)",oFont12)

	//Valor do INSS(R$)
	nTamLinAnt	:= nTamCol
	nTamCol 	:= nTamCol + 1.8
	Linha(nLin,nTamLinAnt,nFimLin+0.02,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,Alltrim(iif(cVlrINSS<=0,"",Transform(cVlrINSS,PesqPict("SD2","D2_TOTAL")))),oFont12)

	//CSLL(R$)
	nTamLinAnt	:= nTamCol
	nTamCol := nTamCol + 1.8
	Linha(nLin,nTamCol,nFimLin,nTamCol,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,"CSLL(R$)",oFont12)

	//Valor do CSLL(R$)
	nTamLinAnt	:= nTamCol
	nTamCol 	:= nTamCol + 1.8
	Linha(nLin,nTamLinAnt,nFimLin+0.02,FIM_COL,0.5)
	Say(nLin+0.07,nTamLinAnt+0.2,Alltrim(iif(cVlrCSLL<=0,"",Transform(cVlrCSLL,PesqPict("SD2","D2_TOTAL")))),oFont12)

	//Cabe�alho para os impostos
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha transversal
	Linha(nLin,FIM_COL,nFimLin,FIM_COL,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.3,"Detalhamento de Valores - Prestador dos Servi�os",oFont10N)
	Linha(nLin,8,nFimLin,8,0.5) //Separa��o de datalhamento
	Say(nLin+0.07,8.7,"Outras Reten��es",oFont10N)
	Linha(nLin,12,nFimLin,12,0.5) //Separa��o de Outras Reten��es 
	Say(nLin+0.07,13.8,"C�lculo do ISSQN devido ao Munic�pio",oFont10N)




	//Linha1 dos impostos
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Valor dos Servi�os
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,4.5,nFimLin,4.5,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"Valor dos Servi�os R$",oFont10N)
	Linha(nLin,4.5,nFimLin,8,0.5) //Caixa do valor
	Say(nLin+0.1,5.5,Alltrim(iif(cVlrServ<=0,"",Transform(cVlrServ,PesqPict("SD2","D2_TOTAL")))),oFont10)

	
	//Natureza Opera��o
	Linha(nLin-0.02,12,nFimLin-0.02,12,0.5) //Linha transversal
	Say(nLin+0.07,8.6,"Natureza Opera��o",oFont10N)

	//Valores dos Servi�os
	Linha(nLin-0.02,16.5,nFimLin-0.02,16.5,0.5) //Linha transversal
	Say(nLin+0.07,12.1,"Valores dos Servi�os R$",oFont10N)

	//Valor
	Linha(nLin,16.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Say(nLin+0.1,18,Alltrim(iif(cVlrServ<=0,"",Transform(cVlrServ,PesqPict("SD2","D2_TOTAL")))),oFont10)





	//Linha 2 dos impostos
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Desconto Incondicionado
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,4.5,nFimLin,4.5,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"(-) Desconto Incondicionado",oFont10N)
	Linha(nLin-0.02,4.5,nFimLin,8,0.5) //Caixa do valor
	Say(nLin+0.1,5.5,"",oFont10)
	
	//Tributa��o
	Linha(nLin-0.02,8,nFimLin,12,0.5) //Linha transversal
	Say(nLin+0.07,8.2,"1-Tributa��o no munic�pio",oFont10N)

	//Dedu��es permitidas em lei
	Linha(nLin-0.02,16.5,nFimLin-0.02,16.5,0.5) //Linha transversal
	Say(nLin+0.07,12.1,"(-) Dedu��es permitidas em lei",oFont10N)

	//Valor
	Linha(nLin-0.02,16.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Say(nLin+0.1,18,"0,00",oFont10)





	//Linha 3 dos impostos
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Desconto Condicionado
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,4.5,nFimLin,4.5,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"(-) Desconto Condicionado",oFont10N)
	Linha(nLin-0.02,4.5,nFimLin,8,0.5) //Caixa do valor
	Say(nLin+0.1,5.5,"",oFont10)
	
	//Regime
	Linha(nLin-0.02,12,nFimLin,12,0.5) //Linha transversal
	Say(nLin+0.07,8.1,"Regime especial Tributa��o",oFont10N)

	//Desconto Incondicionado
	Linha(nLin-0.02,16.5,nFimLin-0.02,16.5,0.5) //Linha transversal
	Say(nLin+0.07,12.1,"(-) Desconto Incondicionado",oFont10N)

	//Valor
	Linha(nLin-0.02,16.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Say(nLin+0.1,18,"",oFont10)





	//Linha 4 dos impostos
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Reten��es Federais
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,4.5,nFimLin,4.5,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"(-) Reten��es Federais",oFont10N)
	Linha(nLin-0.02,4.5,nFimLin-0.02,8,0.5) //Caixa do valor
	Say(nLin+0.1,5.5,Alltrim(iif(nTotFederal<=0,"",Transform(nTotFederal,PesqPict("SD2","D2_TOTAL")))),oFont10)

	//Natureza Opera��o
	Linha(nLin-0.02,8,nFimLin-0.02,12,0.5) //Linha transversal
	Say(nLin+0.07,9.1,"0-Nenhum",oFont10N)
	
	//Base de C�lculo
	Linha(nLin-0.02,12,nFimLin,12,0.5) //Linha transversal
	Say(nLin+0.07,12.1,"Base de C�lculo",oFont10N)

	//Valor
	Linha(nLin-0.02,16.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Say(nLin+0.1,18,Alltrim(iif(cBaseCalc<=0,"",Transform(cBaseCalc,PesqPict("SD2","D2_TOTAL")))),oFont10)




	//Linha 5 dos impostos
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Outras Reten��es
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,4.5,nFimLin,4.5,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"Outras Reten��es",oFont10N)
	Linha(nLin-0.02,4.5,nFimLin,8,0.5) //Caixa do valor
	Say(nLin+0.1,18,"",oFont10)

	//Op��o Simples nacipal
	Linha(nLin-0.02,12,nFimLin-0.02,12,0.5) //Linha transversal
	Say(nLin+0.07,8.3,"Op��o Simples Nacional",oFont10N)
	
	//Base de C�lculo
	Linha(nLin-0.02,12,nFimLin,12,0.5) //Linha transversal
	Say(nLin+0.07,12.1,"(X) Al�quota %",oFont10N)

	//Valor
	Linha(nLin-0.02,16.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Say(nLin+0.1,18,Alltrim(iif(nPercIss<=0,"",Transform(nPercIss,PesqPict("SD2","D2_TOTAL")))),oFont10)




	//Linha 5 dos impostos
	nLin := nFimLin
	nFimLin := nLin-0.02+(TAM_LINHA*1.2)

	//Iss Retido
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,4.5,nFimLin,4.5,0.5) //Linha final
	Say(nLin+0.07,INI_COL+0.1,"(-) ISS Retido",oFont10N)
	Linha(nLin,4.5,nFimLin,8,0.5) //Caixa do valor
	Say(nLin+0.1,5.5,Alltrim(iif(cVlrSTISS<=0,"",Transform(cVlrSTISS,PesqPict("SD2","D2_TOTAL")))),oFont10)

	//Iss Retido 1=Sim, 2=Nao
	Linha(nLin-0.02,12,nFimLin-0.02,12,0.5) //Linha transversal
	Say(nLin+0.07,9.4,iif(cISSRetido=="2","2-N�o","1=Sim"),oFont10N)
	
	//Iss a Reter
	Linha(nLin-0.02,12,nFimLin,12,0.5) //Linha transversal
	Say(nLin+0.07,12.1,"ISS a reter:",oFont10N)

	//Valor
	Linha(nLin,16.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Say(nLin+0.07,17.4,iif(cISSRetido=="2","( ) Sim (X) N�o","(X) Sim ( ) N�o"),oFont10)





	//Linha 6 dos impostos - Essa Linha � duplicada de tamanho
	nLin := nFimLin
	nFimLin := nLin-0.02+((TAM_LINHA*2)*1.2)

	//Iss Retido
	Linha(nLin,INI_COL,nFimLin,INI_COL,0.5) //Linha da esquerda
	Linha(nFimLin-0.02,INI_COL,nFimLin-0.02,FIM_COL,0.5) //Linha transversal
	Linha(nLin,4.5,nFimLin,4.5,0.5) //Linha final
	Say(nLin+0.37,INI_COL+0.1,"(=) Valor L�quido R$",oFont10N)
	Linha(nLin-0.02,4.5,nFimLin,8,0.5) //Caixa do valor
	Say(nLin+0.37,5.5,Alltrim(iif(cVlrLiq<=0,"",Transform(cVlrLiq,PesqPict("SD2","D2_TOTAL")))),oFont10)

	//Incentivo a Cultura
	Linha(nLin,12,nFimLin,12,0.5) //Linha transversal
	Linha(nLin+0.55,8,nLin+0.55,12,0.5) //Linha transversal
	Say(nLin+0.07,8.4,"Incentivador Cultura",oFont10N)
	Linha(nLin+0.55,8,nFimLin,12,0.5) //Linha transversal
	Say(nLin+0.67,9.4,"2-N�o",oFont10)	
	
	//Valor do ISS
	Linha(nLin-0.02,12,nFimLin,12,0.5) //Linha transversal
	Say(nLin+0.37,12.1,"(=) Valor do ISS:",oFont10N)

	//Valor
	Linha(nLin-0.02,16.5,nFimLin,FIM_COL,0.5) //Linha transversal
	Say(nLin+0.37,18,Alltrim(iif(cVlrISS<=0,"",Transform(cVlrISS,PesqPict("SD2","D2_TOTAL")))),oFont10)

	nLin := nFimLin-0.04

Return Nil 

/*
	Fun�ao responsavel pelos dados de outras informa�oes
*/
Static Function OutrasInformacoes()
	
	nFimLin := nLin-0.02+((TAM_LINHA*3)*1.3)
	Linha(nLin,INI_COL,nFimLin,FIM_COL,0.5) //Linha da esquerda

	Say(nLin+0.77,1,"Avisos",oFont08)

	Linha(nLin,2.5,nFimLin,2.5,0.5) //Linha da esquerda

	Say(nLin+0.07,2.7,"1 - Uma via desta Nota Fiscal ser� enviada atrav�s do e-mail fornecedor pelo Tomador dos Servi�os.",oFont08)
	Say(nLin+0.37,2.7,"2 - A autenticidade deste Nota Fiscal poder� ser verificada no site, RIOCLARO.ginfes.com.br com a utiliza��o do C�digo de Verifica��o.",oFont08)

Return Nil 

/*
	Fun�ao responsavel pela informa�ao do tipo de ISS
*/
Static Function ExigISS(cOpc)
	Local cDesc 	:= ""

	If cOpc == "1"
		cDesc := "EXIG�VEL"
	ElseIf cOpc == "2"
		cDesc := "N�O INCID�NCIA"
	ElseIf cOpc == "3"
		cDesc := "ISEN��O"
	ElseIf cOpc == "4"
		cDesc := "EXPORTA��O"
	ElseIf cOpc == "5"
		cDesc := "IMUNIDADE"
	ElseIf cOpc == "6"
		cDesc := "EXIGIBILIDADE SUSPENSA POR DECIS�O JUDICIAL"
	ElseIf cOpc == "7"
		cDesc := "EXIGIBILIDADE SUSPENSA POR PROCESSO ADMINISTRATIVO"
	EndIf 

Return cDesc

/*
	Fun�ao responsavel por buscar a descri�ao do municipio
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
		cDesc := Alltrim((cAliasQry)->CC2_MUN) +" - "+ cUF
	EndIf

	if Empty(cDesc)
		cDesc := "INDAIATUBA - SP"
	endif

	(cAliasQry)->(DbCloseArea())

Return cDesc

/*
	Fun�ao responsavel por buscar a reten�ao de ISS
*/
Static Function retIssRetido()
	Local cRet := ""

	dbSelectArea("SF3")
	DbSetOrder(4)
	If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
		cRet := SF3->F3_RECISS
	EndIf

Return cRet

/*
	Fun�ao responsavel por buscar as duplicatas
*/
Static Function GetDuplic()
	local cQuery	:= ""
	local cQryAux	:= GetNextAlias()
	local nAuxRet	:= 0
	local nVlrPIS	:= SuperGetMV("MV_ZZRTPIS",.F.,0)	//-Valor Minimo de Reten�ao (Pis)
	local nVlrCOF	:= SuperGetMV("MV_ZZRTCOF",.F.,0)	//-Valor Minimo de Reten�ao (Cofins)
	local nVlrCSL	:= SuperGetMV("MV_ZZRTCSL",.F.,0)	//-Valor Minimo de Reten�ao (Csll)
	local nVlrMin	:= SuperGetMV("MV_VL13137",.F.,10)	//-Valor Minimo de Reten�ao (Pis+Cofins+Csll)

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

			/* Ressaltamos que esse valor m�nimo, para efeitos de reten��o (R$ 10,00), deve ser 
				composto pelo somat�rio das contribui��es (PIS, COFINS e CSLL), n�o devendo ser 
				feito o recolhimento de forma individualizada por Contribui��o, mas conjuntamente, 
				j� que est�o sob o comando de recolhimento do mesmo c�digo de receita (5952) 
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

//Linha
Static Function Linha(l1,c1,l2,c2,t,cCor)
	Default cCor 		:= ""
	if cCor == "CINZA"
		oRetangulo := TBrush():New( , CLR_HGRAY,"-1")
	else
		oRetangulo := TBrush():New( , CLR_GRAY,"-2")
	endif
	if Empty(cCor)
		oPrint:Box(l1*x,c1*x,l2*x,c2*x,StrZero(t,2))
	else
		oPrint:Fillrect( {Round((l1+0.02)*x,3),Round((c1+0.03)*x,3),Round((l2-0.04)*x,3),Round((c2-0.05)*x,3)}, oRetangulo)
	endif
Return Nil

//Rotina para calcular as linhas/Linha em cent�metros 
Static Function Say(L,C,T,F,A)
	Local W := x*50
	Local nWeigth := 6000
	Default A:=0
	L*=x
	C*=x
	If Valtype(t)=="N"
		A := 1
		T := T(t)
	ElseIf Valtype(t)=="D"
		T := DtoC(T)
	Endif
	If A==0
		oPrint:SayAlign(L,C,T,F,(C+W),nWeigth,,A)
	Else
		oPrint:SayAlign(L,C,T,F,(C+W),nWeigth,,A)
	Endif

Return Nil

Static Function QuebraMensagem(cMsgObs)

	cMsgObs 		:= Replace(cMsgObs,"||","")
	Local aRet 		:= {"TESTE E ANALISE TECNICAS"}
	Local aAux  	:= StrToKarr2(cMsgObs,"|",.T.)
	Local nQuebra	:= 0
	Local nTam		:= 130
	Local cAux		:= ""
	Local cMsgAux	:= ""
	
	//Reordena��o de como sai a mensagem na impress�o
	for nQuebra := 1 to len(aAux)
		if "DUPLICATA" $ aAux[nQuebra]
			aadd(aRet,Alltrim(Replace(aAux[nQuebra],"DUPLICATAS - ","")))
			aAux[nQuebra]:= ""
		endif
	Next nQuebra

	for nQuebra := 1 to len(aAux)
		if "RETENCAO" $ aAux[nQuebra]
			aadd(aRet,Alltrim(aAux[nQuebra]))
			aAux[nQuebra]:= ""
		endif
	Next nQuebra

	for nQuebra := 1 to len(aAux)
		if !Empty(aAux[nQuebra])
			if Len(aAux[nQuebra]) <= nTam
				aadd(aRet,aAux[nQuebra])
			else
				cMsgAux := Alltrim(aAux[nQuebra])
				While !Empty(cMsgAux)
					if len(cMsgAux) > nTam
						cAux := Left(cMsgAux,nTam)
						cMsgAux := SubStr(cMsgAux,nTam,len(cMsgAux)-nTam)
					else
						cAux := cMsgAux
						cMsgAux:= ""
					endif
					aadd(aRet,cAux)
				enddo
			endif
		endif
	Next nQuebra

Return aRet

Static Function GetMailstomador(cNFSeFil,cNFSeNum,cNFSeSer,cNFSeCli,cNFSeLoj)

	Local cPedido	:= {}
	Local cQuery 	:= ""
	Local cAliasPed	:= GetNextAlias()
	Local nPosCorte := 0

	cQuery := " Select "								+ CRLF
	cQuery += " 	DISTINCT D2_PEDIDO "				+ CRLF
	cQuery += " From " + RetSqlName("SD2") + " SD2 "	+ CRLF
	cQuery += " Where "									+ CRLF
	cQuery += " 	1=1 "								+ CRLF
	cQuery += " 	AND D2_FILIAL = '"+cNFSeFil+"' "	+ CRLF
	cQuery += " 	AND D2_DOC = '"+cNFSeNum+"' "		+ CRLF
	cQuery += " 	AND D2_SERIE = '"+cNFSeSer+"' "		+ CRLF
	cQuery += " 	AND D2_CLIENTE = '"+cNFSeCli+"' "	+ CRLF
	cQuery += " 	AND D2_LOJA = '"+cNFSeLoj+"' "		+ CRLF
	cQuery += " 	AND D_E_L_E_T_ = ' ' "				+ CRLF

	TcQuery cQuery NEW Alias &(cAliasPed)

	(cAliasPed)->(dbGotop())
	While (cAliasPed)->(!eof())
		if Empty(cPedido)
			cPedido := (cAliasPed)->D2_PEDIDO 
		else
			if !(cAliasPed)->D2_PEDIDO $ cPedido
				cPedido += "/"+(cAliasPed)->D2_PEDIDO
			endif
		endif
		(cAliasPed)->(DbSkip())
	enddo
	(cAliasPed)->(DbCloseArea())

	cAliasPed 	:= GetNextAlias()
	cPedido 	:= FormatIn(cPedido,"/")

	cQuery := " Select "								+ CRLF
	cQuery += " 	DISTINCT C5_ZZNFMAI "				+ CRLF
	cQuery += " From " + RetSqlName("SC5") + " SC5 "	+ CRLF
	cQuery += " Where "									+ CRLF
	cQuery += " 	1=1 "								+ CRLF
	cQuery += " 	AND C5_FILIAL = '"+cNFSeFil+"' "	+ CRLF
	cQuery += " 	AND C5_CLIENTE = '"+cNFSeCli+"' "	+ CRLF
	cQuery += " 	AND C5_LOJACLI = '"+cNFSeLoj+"' "	+ CRLF
	cQuery += "		And C5_NUM in "+cPedido+""			+ CRLF
	cQuery += " 	AND D_E_L_E_T_ = ' ' "				+ CRLF

	TcQuery cQuery NEW Alias &(cAliasPed)

	(cAliasPed)->(dbGotop())
	While (cAliasPed)->(!eof())
		if Empty(cMailTomador)
			cMailTomador := (cAliasPed)->C5_ZZNFMAI 
		else
			if !(cAliasPed)->C5_ZZNFMAI $ cMailTomador
				cMailTomador += "; "+(cAliasPed)->C5_ZZNFMAI
			endif
		endif
		(cAliasPed)->(DbSkip())
	enddo
	(cAliasPed)->(DbCloseArea())

	if len(cMailTomador) > 50
		cMailTomador := left(cMailTomador,50)
		nPosCorte := Rat(";",cMailTomador)
		cMailTomador := left(cMailTomador,nPosCorte-1)
	endif

Return Nil
