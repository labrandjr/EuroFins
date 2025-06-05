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

/*
Existem adequacoes entre o fonte para Eurofins e para Empresa ALAC. Pesquisar por alterado para ver adequacoes realizadas.
*/

/*/{Protheus.doc} EnviaBolDescr
Envia boleto e descritivo
@type function
@version 1.0
@author Marcos Candido
@since 02/01/2018
@link https://gkcmp.com.br (Geeker Company)
@history 24/04/2023, Ademar Fernandes Jr, Tratamento da gera�ao do PDF da NFSe de Indaiatuba e Recife
@return variant, Nil
/*/
User Function EnviaBolDescr()
	Local cPerg    := PADR("SELENFS",10) ,  aPergs := {}
	Local aHelpPor := {}, aHelpIng := {}, aHelpEsp := {}
	Local aBrwSF2  := {}

	Local aChavBancoDep := Separa(SuperGetMv( "MV_ZZCDNFS" , .F. , " " ,  ),"/",.F.)

	Local aCores    := {	{ "SF2->F2_ZZEMAIL == 'S'", 'GREEN'  },;
							{ "SF2->F2_ZZEMAIL <> 'S'", 'RED'   };
						}

	Private	nValIRRF  := {}
	Private	nValPIS   := {}
	Private	nValCOFI  := {}
	Private	nValCSLL  := {}
	Private nValBruto := {}
	Private nValLiq   := {}
	Private nValMora  := {}
	Private dVenc	  := {}
	Private nParcela  := 0

	Private bFiltraBrw

	Private	cMarca	  := GetMark()
	Private	lInverte  := .F.

	Private cCadastro  := "Notas Fiscais de Sa�da"
	// Alterado
	//Private cCondBrowse := "SF2->F2_TIPO == 'N' .and. SF2->F2_SERIE == '"+Space(3)+"'"
	Private cFilSerie	:= Alltrim(GetMV("MV_ZZFILSE",,"T/E/S"))
	Private aSeries		:= {}
	Private cCondBrowse := "SF2->F2_FILIAL == '" + xFilial("SF2") + "' .and. SF2->F2_TIPO == 'N' "// .and. Alltrim(SF2->F2_SERIE) $ '"+ cFilSerie +"'"
	Private aRotina    := {	{"Pesquisar" 		, "AxPesqui"	, 0, 1},;
							{"Visualizar"		, "U_VisuNF()"	, 0, 2},;
							{"Selecionar"		, "U_SeleNF()"	, 0, 9},;
							{"Enviar E-mail"	, "U_Enviar(Space(1))"	, 0, 9}}

	Private nConsNeg := 0.4 // Constante para consertar o c�lculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex := 0.5 // Constante para consertar o c�lculo retornado pelo GetTextWidth.
	Private nBcoBol := 1
	Private nQtdDoc := 1
	Private nTpPgto := 1

	Private cDiret   := ""//"\IMAGEMBD\"+cFilant+"\"+Alltrim(RetCodUsr())+"\"
	Private cDirPDF  := ""//"C:\TEMP\"+cFilant+"\"+Alltrim(RetCodUsr())+"\"		// GetMV("MV_RELT")
	Private cDirNFSe := ""//"C:\TEMP\"+cFilant+"\"+Alltrim(RetCodUsr())+"\"+"NFSE\" //-GetSrvProfString("ROOTPATH","")+SuperGetMV("ZZ_NFSEPDF",.F.,"\NFSE\")
	Private aFiles1  := {}	//-Boleto Itau
	Private aFiles2  := {}	//-Descritivo
	Private aFiles3  := {}	//-NFSe

	Private cTipCob  := ""
	Private cBcoTran := ""
	Private cAgTran  := ""
	Private cCCTran  := ""
	// Alterado
	//Private cLogoEmp := "\IMAGEM\MSMDILOGO.BMP"
	//Private cLogoEmp := "\IMAGEM\LGRL04.BMP"
	Private oPrint := Nil
	// Alterado
	//Private aBcoBol := {"Banco Itau    ","Banco Bradesco"}
	Private aBcoBol := {"Banco Itau    "}
	Private aQtdDoc := {"Boleto e Descritivo" , "Apenas Boleto      " , "Apenas Descritivo  "}
	Private aTpPgto := {'Boleto   ','Dep�sito'}

	Private cLogoEmp := Alltrim(GetMV("MV_ZZLOGOE",,"\IMAGEM\MSMDILOGO.BMP"))
	Private cNomeFat := Alltrim(GetMV("MV_ZZNMFAT",,"Agata Gomes | Faturamento"))
	Private cEmailFat:= Alltrim(GetMV("MV_ZZEMFAT",,"faturamento@eurofins.com"))

	Private lOnNFSe  := SuperGetMv("ZZ_ONNFSE",.F.,.F.)	//-Habilita gera��o da NFSe para envio junto com Boleto e Descritivo

	Private cPrefixo := Alltrim(RetCodUsr())
	Private cBolNome := ""
	Private cDescNome:= ""
	Private cNfseNome:= ""

	cChavBancoDep := aChavBancoDep[1] + padR(aChavBancoDep[2],TamSX3("A6_AGENCIA")[1]) + aChavBancoDep[3]
	cBancoDep 	:= Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_COD")
	cBcoDescDep	:= AllTrim(Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_NOME"))
	cAgenciaDep	:= AllTrim(Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_AGENCIA")) + "-" + Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_DVAGE")
	cContaDep	:= AllTrim(Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_NUMCON")) + "-" + Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_DVCTA")
	cAg2SemDV	:= AllTrim(Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_AGENCIA"))
	cCT2SemDV	:= AllTrim(Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_NUMCON"))

	aHelpPor := {}
	aAdd(aHelpPor,"Informe a data inicial a ser consi-")
	aAdd(aHelpPor,"derada para o filtro das notas.")
	Aadd(aPergs,{"Da Data","","","MV_CH1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe a data final a ser consi-")
	aAdd(aHelpPor,"derada para o filtro das notas.")
	Aadd(aPergs,{"Ate a Data","","","MV_CH2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe o c�digo do cliente inicial")
	aAdd(aHelpPor,"a ser considerado no filtro.")
	Aadd(aPergs,{"Do Cliente","","","MV_CH3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe a loja do cliente inicial")
	aAdd(aHelpPor,"a ser considerada no filtro.")
	Aadd(aPergs,{"Da Loja","","","MV_CH4","C",02,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe o c�digo do cliente final")
	aAdd(aHelpPor,"a ser considerado no filtro.")
	Aadd(aPergs,{"Do Cliente","","","MV_CH5","C",06,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe a loja do cliente final")
	aAdd(aHelpPor,"a ser considerada no filtro.")
	Aadd(aPergs,{"Ate a Loja","","","MV_CH6","C",02,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

	//���������������������������������������������
	//� Cria, se necessario, o grupo de Perguntas �
	//���������������������������������������������
	//AjustaSx1(cPerg,aPergs)

	//�������������������������������������������������������������Ŀ
	//� Cria diretorio, caso nao exista                             �
	//���������������������������������������������������������������
	cDiret   := "\IMAGEMBD\"
	MakeDir(cDiret)
	cDiret   := "\IMAGEMBD\"+cFilant+"\"
	MakeDir(cDiret)
	cDiret   := "\IMAGEMBD\"+cFilant+"\"+Alltrim(RetCodUsr())+"\"
	MakeDir(cDiret)

	cDirPDF  := "C:\TEMP\"
	MakeDir(cDirPDF)
	cDirPDF  := "C:\TEMP\"+cFilant+"\"
	MakeDir(cDirPDF)
	cDirPDF  := "C:\TEMP\"+cFilant+"\"+Alltrim(RetCodUsr())+"\"
	MakeDir(cDirPDF)

	cDirNFSe := "C:\TEMP\"
	MakeDir(cDirNFSe)
	cDirNFSe := "C:\TEMP\"+cFilant+"\"
	MakeDir(cDirNFSe)
	cDirNFSe := "C:\TEMP\"+cFilant+"\"+Alltrim(RetCodUsr())+"\"
	MakeDir(cDirNFSe)

	Pergunte(cPerg,.T.)
/*
	cCondBrowse += ".and. DTOS(F2_EMISSAO) >= '"+DTOS(mv_par01)+"' .and. DTOS(F2_EMISSAO) <= '"+DTOS(mv_par02)+"'"
	cCondBrowse += ".and. F2_CLIENTE >= '"+mv_par03+"' .and. F2_LOJA >= '"+mv_par04+"'"
	cCondBrowse += ".and. F2_CLIENTE <= '"+mv_par05+"' .and. F2_LOJA <= '"+mv_par06+"'"
	if !Empty(mv_par07)
		cCondBrowse += ".and. Alltrim(SF2->F2_SERIE) $ '"+Alltrim(mv_par07)+"'"
	else
		cCondBrowse += ".and. Alltrim(SF2->F2_SERIE) = '"+mv_par07+"'"
	endif

	dbSelectArea("SF2")
	cFilSerie := Alltrim(mv_par07)
	//������������������������������������������������������������������������Ŀ
	//�Realiza a Filtragem                                                     �
	//��������������������������������������������������������������������������
	bFiltraBrw := {|| FilBrowse("SF2",@aBrwSF2,@cCondBrowse) }
	Eval(bFiltraBrw)

	mBrowse(06, 01, 22, 75, "SF2")

	dbSelectArea("SF2")
	RetIndex("SF2")
	dbClearFilter()
	aEval(aBrwSF2,{|x| Ferase(x[1]+OrdBagExt())})
	//EndFilBrw( "SF2" , @aBrwSF2 ) //Finaliza o Filtro
*/
	cCondBrowse += ".and. DTOS(F2_EMISSAO) >= '"+DTOS(mv_par01)+"' .and. DTOS(F2_EMISSAO) <= '"+DTOS(mv_par02)+"' "
	cCondBrowse += ".and. F2_CLIENTE >= '"+mv_par03+"' .and. F2_LOJA >= '"+mv_par04+"' "
	cCondBrowse += ".and. F2_CLIENTE <= '"+mv_par05+"' .and. F2_LOJA <= '"+mv_par06+"' "
	cCondBrowse += ".and. F2_SERIE  = '"+mv_par07+"' "
	cCondBrowse += ".and. F2_FILIAL = '"+xFilial("SF2")+"'"
	cFilSerie := Alltrim(mv_par07)

	dbSelectArea("SF2")

	//������������������������������������������������������������������������Ŀ
	//�Realiza a Filtragem                                                     �
	//��������������������������������������������������������������������������
	bFiltraBrw := {|| FilBrowse("SF2",@aBrwSF2,@cCondBrowse) }
	Eval(bFiltraBrw)

	mBrowse(06, 01, 22, 75, "SF2",,,,,, aCores )

	dbSelectArea("SF2")
	RetIndex("SF2")
	dbClearFilter()
	aEval(aBrwSF2,{|x| Ferase(x[1]+OrdBagExt())})
	//EndFilBrw( "SF2" , @aBrwSF2 ) //Finaliza o Filtro

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � VisuNF   � Autor � Marcos Candido        � Data � 25.04.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualiza a nota desejada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function VisuNF(cAlias,nReg,nOpcx)

Local aAreaAtual := GetArea()

SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
a920NFSAI("SD2",SD2->(Recno()),1)

RestArea(aAreaAtual)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � SeleNF   � Autor � Marcos Candido        � Data � 26.02.13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Seleciona a nota desejada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function SeleNF(cAlias,nReg,nOpcx)

Local lExec := .F. , lOk := .F.
Local oDlg
Local nOpca   := 0
Local aCampos := {}
Local aCpoBro := {}
/*
@ 0,0 TO 295,305 DIALOG oDlgFil TITLE OemToAnsi("Op��es de envio")
@ 05,05 To 40,110 Title OemToAnsi(" Agente Cobrador ")
// Alterado
//@ 15,17 RADIO aBcoBol VAR nBcoBol 3D SIZE 60,20 PROMPT 'Banco Itau','Banco Bradesco' OF oDlgFil
@ 15,17 RADIO aBcoBol VAR nBcoBol 3D SIZE 60,20 PROMPT 'Banco Itau' OF oDlgFil

@ 48,05 To 93,110 Title OemToAnsi(" Documentos ")
@ 58,17 RADIO aQtdDoc VAR nQtdDoc 3D SIZE 80,20 PROMPT 'Boleto e Descritivo' , 'Apenas Boleto' , 'Apenas Descritivo' OF oDlgFil

@ 101,05 To 136,110 Title OemToAnsi(" Forma de Pgto do Cliente ")
@ 111,17 RADIO aTpPgto VAR nTpPgto 3D SIZE 60,20 PROMPT 'Boleto','Dep�sito' OF oDlgFil

@ 59,120 BMPBUTTON TYPE 1 ACTION (lOk:=.T.,Close(oDlgFil))
@ 74,120 BMPBUTTON TYPE 2 ACTION (Close(oDlgFil))
ACTIVATE DIALOG oDlgFil CENTERED*/
lOK := .T.
If lOk

	aCampos := {	{"OK"   	,"C",02,0},;
					{"DOC"		,"C",09,0},;
					{"SERIE"	,"C",03,0},;
					{"CLIENTE"  ,"C",06,0},;
					{"LOJA"		,"C",02,0},;
					{"VALOR"	,"N",18,2},;
					{"EMISSAO"  ,"D",8,0},;
					{"CHAVE"  	,"N",12,0}}

	aCpoBro	:= {	{"OK"	,, " ","  "},;
					{"DOC"	    ,, OemToAnsi("Nota Fiscal"),"@X"},;
					{"SERIE"	,, OemToAnsi("S�rie"),"@X"},;
					{"CLIENTE"	,, OemToAnsi("C�digo Cliente"),"@X"},;
					{"LOJA"		,, OemToAnsi("Loja Cliente"),"@X"},;
					{"VALOR"	,, OemToAnsi("Valor Bruto"),"@E 999,999,999,999.99"},;
					{"EMISSAO"	,, OemToAnsi("Dt Emiss�o"),"@X"}}

	If ( Select ( "TRB" ) <> 0 )
		dbSelectArea ( "TRB" )
		dbCloseArea()
	Endif

	//����������������������������������������
	//� Cria e alimenta arquivo de trabalho  �
	//����������������������������������������
	TRB:=CriaTrab(aCampos,.T.)
	dbUseArea( .T.,, TRB, "TRB", NIL, .F. )
	cIndex := CriaTrab(nil,.f.)
	IndRegua("TRB",cIndex,"DOC+SERIE",,,OemToAnsi("Selecionando Registros..."))
	CarregaTRB()

	dbSelectArea("TRB")
	dbGoTop()

	//����������������������������������������
	//� Interface de interacao com o usuario �
	//����������������������������������������
	DEFINE MSDIALOG oDlgSF2 TITLE cCadastro From 1,1 To 27,100 OF oMainWnd

	oMark:= MsSelect():New("TRB","OK","",aCpoBro,@lInverte,@cMarca,{13+20,01,194,393})
	oMark:oBrowse:lhasMark = .T.
	oMark:oBrowse:lCanAllmark := .T.
	oMark:oBrowse:bAllMark := { || Inverter(cMarca) }

    bOk     := {|| nOpca := 1,oDlgSF2:End()}
    bCancel := {|| oDlgSF2:End()}

    ACTIVATE MSDIALOG oDlgSF2 CENTERED ON INIT (EnchoiceBar(oDlgSF2,bOk,bCancel))

 	If nOpca == 1
 		dbSelectArea("TRB")
		dbGoTop()

		While !Eof()

			If TRB->OK # cMarca
				dbSkip()
				Loop
			Endif

			dbSelectArea("SF2")
			dbGoTo(TRB->CHAVE)

			U_Enviar(SF2->F2_DOC)

			dbSelectArea("TRB")
			dbSkip()

		Enddo
    Endif

Endif

If ( Select ( "TRB" ) <> 0 )
	dbSelectArea ( "TRB" )
	dbCloseArea()
	fErase(TRB+GetdbExtension())
	fErase(cIndex+OrdBagExt())
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Enviar   �Autor  � Marcos Candido     � Data �  02/08/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Eurofins                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Enviar(cNumDoc)
	Local aAreaAtual := GetArea()
	Local nValorTit := 0
	Local lOk := .F.
	Local X   := 0
	Local cCodNFSE	:= ""
	Local cNumNFSe	:= Alltrim(iif(Empty(SF2->F2_NFELETR),SF2->F2_DOC,SF2->F2_NFELETR))

	//-aParam  := {cFilNFSe,cNumNFSe,cSerNFSe,cNFSeCli,cNFSeLoj,cModNFSe}
	local aParam	:= { "", "", "", "", "", "" }
	local cTitulo1	:= FunName()+" - "+FunDesc()
	local lAborta1	:= .F.
	private oNFSePDF
/*
If cNumDoc == Space(1)
	@ 0,0 TO 198,305 DIALOG oDlgFil TITLE OemToAnsi("Op��es de envio")
	@ 05,05 To 40,110 Title OemToAnsi(" Agente Cobrador ")
	// Alterado
	//@ 16,17 RADIO aBcoBol VAR nBcoBol 3D SIZE 60,20 PROMPT 'Banco Itau','Banco Bradesco' OF oDlgFil
	@ 16,17 RADIO aBcoBol VAR nBcoBol 3D SIZE 60,20 PROMPT 'Banco Itau' OF oDlgFil
	@ 51,05 To 93,110 Title OemToAnsi(" Documentos ")
	@ 61,17 RADIO aQtdDoc VAR nQtdDoc 3D SIZE 80,20 PROMPT 'Boleto e Descritivo' , 'Apenas Boleto' , 'Apenas Descritivo' OF oDlgFil
	@ 34,120 BMPBUTTON TYPE 1 ACTION (lOk:=.T.,Close(oDlgFil))
	@ 49,120 BMPBUTTON TYPE 2 ACTION (Close(oDlgFil))
	ACTIVATE DIALOG oDlgFil CENTERED
Else*/
	lOk := .T.
//Endif

If lOk

	// incluido em 07/02/13 a pedido do Bruno Afif
	// Alterado
	/*
	If nBcoBol == 1
		If Aviso(OemToAnsi("Informa��o") , OemToAnsi("O uso do Banco Ita� est� suspenso. O Banco Bradesco ser� considerado em seu lugar.") , {"Continua","Abandona"}) == 2
			lOk := .F.
		Endif
	Endif
    */
Endif

If lOk

	//Posiciona o SA1 (Cliente)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA))

	cTipCob  := SA1->A1_ZZTPCOB
	// Alterado
	/*
	cBcoTran := IIF(Empty(SA1->A1_ZZBCO)   , "237"      , SA1->A1_ZZBCO)
	cAgTran  := IIF(Empty(SA1->A1_ZZAGENC) , "316-6"    , SA1->A1_ZZAGENC)
	cCCTran  := IIF(Empty(SA1->A1_ZZCONTA) , "144605-3" , SA1->A1_ZZCONTA)
	*/
	cBcoTran := IIF(Empty(SA1->A1_ZZBCO)   , cBancoDep      , SA1->A1_ZZBCO)
	cAgTran  := IIF(Empty(SA1->A1_ZZAGENC) , cAgenciaDep    , SA1->A1_ZZAGENC)
	cCCTran  := IIF(Empty(SA1->A1_ZZCONTA) , cContaDep		, SA1->A1_ZZCONTA)

	DbSelectArea("SF2")
	If SF2->(Reclock("SF2", .F.))
		SF2->F2_ZZEMAIL := "S"
		SF2->(MsUnlock())
	Endif

	//�������������������������������������������������������������Ŀ
	//� limpa conteudo dos diretorios, antes do processamento       �
	//���������������������������������������������������������������
	delArqPdf()

	aFiles1 := {}
	aFiles2 := {}
	aFiles3 := {}
	aInfo   := {}
	nValorTit := 0
	cNumTit   := ""

	MakeDir(cDiret)
	MakeDir(cDirPDF)

	If cTipCob == "B"  // verifica tipo de cobranca no cliente (B)oleto ou (D)eposito

		//If nQtdDoc == 1

			//�������������������������������������������������������������Ŀ
			//� Impressao/Gera�ao do PDF do Boleto Itau	(aFiles1)			�
			//���������������������������������������������������������������
			Processa({|| aInfo := ImprBoleto()}, cTitulo1, "Gerando Boleto NF "+cNumNFSe+"...", lAborta1)

			//nValorTit := ImprBoleto(nValorTit)
			nValorTit := aInfo[1]
			cNumTit   := aInfo[2]
			FreeObj(oPrint)
			oPrint := Nil

			//�������������������������������������������������������������Ŀ
			//� Impressao/Gera�ao do PDF do Descritivo (aFiles2)			�
			//���������������������������������������������������������������
			Processa({|| ImprDescr()}, cTitulo1, "Gerando Descritivo NF "+cNumNFSe+"...", lAborta1)

			FreeObj(oPrint)
			oPrint := Nil

		/*ElseIf nQtdDoc == 2
			//nValorTit := ImprBoleto(nValorTit)
			aInfo := ImprBoleto()
			nValorTit := aInfo[1]
			FreeObj(oPrint)
			oPrint := Nil
		Else
			ImprDescr()
			FreeObj(oPrint)
			oPrint := Nil
		Endif*/
	Else
		//If nQtdDoc == 3

			//�������������������������������������������������������������Ŀ
			//� Impressao/Gera�ao do PDF do Descritivo (aFiles2)			�
			//���������������������������������������������������������������
			Processa({|| ImprDescr()}, cTitulo1, "Gerando Descritivo NF "+cNumNFSe+"...", lAborta1)

			FreeObj(oPrint)
			oPrint := Nil
            nQtdDoc := 3

		//Endif
	Endif

	//�������������������������������������������������������������Ŀ
	//� Impressao/Gera�ao do PDF da NFSe (Indaiatuba ou Recife)		�
	//���������������������������������������������������������������
	if	lOnNFSe .And. ( (cFilAnt == "0100") .OR.;	//-Indaiatuba
						(cFilAnt == "0101") .OR.;	//-Recife
						(cFilAnt == "0600") .OR.;	//-Rio de Janeiro
						(cFilAnt == "0604") )		//-Rio Claro

		oNFSePDF := NFSeMain():new_NFSeMain()
		oNFSePDF:cPerg := "NFSEMAIN"

		//-Verifica quais Filiais podem processar essa rotina
		Processa({|| oNFSePDF:verFiliais_NFSeMain()}, cTitulo1, "Verificando Filiais dispon�veis da NFSe...", lAborta1)

		if( Empty(oNFSePDF:cError) )

			//-Verifica se a Filial passada pode processar a NFSe
			if cFilAnt $ oNFSePDF:cFilProc

				if cFilAnt == "0100"
					cCodNFSE := "000001"
				elseif cFilAnt == "0101"
					cCodNFSE := "000002"
				elseif cFilAnt == "0604"
					cCodNFSE := "000003"
				elseif cFilAnt == "0600"
					cCodNFSE := "000004"
				endif

				//-Tabelas SF2/SD2 est� posicionadas -> Confirmar!!!
				dbSelectArea("SF2")
				aParam := {	F2_FILIAL,;		//-01
							F2_DOC,;		//-02
							F2_SERIE,;		//-03
							F2_CLIENTE,;	//-04
							F2_LOJA,;		//-05
							cCodNFSE,; 		//-06
							cDirNFSe }		//-07-cFullPath

				Processa({|| oNFSePDF:execMain_NFSeMain(aParam)}, cTitulo1, "Gerando NFSe "+cNumNFSe+"...", lAborta1)

				//�������������������������������������������������������������Ŀ
				//�  Faz copia do diretorio local para o diretorio do servidor  �
				//���������������������������������������������������������������
				CpyT2S(cDirNFSe+cNfseNome+"*.PDF", cDiret)

				//������������������������������������������������������Ŀ
				//� Varre o diret�rio e procura pelas p�ginas gravadas.  �
				//��������������������������������������������������������
				// aFiles3 := Directory(cDiret+cArquivo+"*.PDF" )
				aFiles3 := Directory(cDiret+cNfseNome+"*.PDF")

			endif
		endif
	endif

	//If nQtdDoc <> 3
		If cTipCob == "B" .and. nValorTit <= 0
			IW_MsgBox(OemToAnsi("O t�tulo "+cNumTit+" j� foi baixado. Imposs�vel envia-lo por e-mail.") , OemToAnsi("Aten��o") , "ALERT")
		//Elseif cTipCob <> "B"
			//IW_MsgBox(OemToAnsi("O cadastro do cliente "+Transform(SF2->(F2_CLIENTE+F2_LOJA),"@R 999999/99")+" indica que ele optou por fazer Dep�sito e n�o receber Boleto.") , OemToAnsi("Aten��o") , "ALERT")
		Endif
    //Endif

	If (nValorTit > 0 .or. nQtdDoc == 3)
		EnviaEmail(nValorTit,IIF(cNumDoc=Space(1),.T.,.F.))
        nQtdDoc := 1
	Endif

	//�������������������������������������������������������������Ŀ
	//� limpa conteudo dos diretorios, depois do processamento      �
	//���������������������������������������������������������������
	delArqPdf()

Endif

RestArea(aAreaAtual)

Return

/*
	Rotina para apagar os arquivos PFDs gerados
*/
Static function delArqPdf()
	local nX := 0

	aFiles1 := Directory(cDirPDF+"*.PDF")	//-Boleto Itau
	For nX := 1 to Len(aFiles1)
		FErase(cDirPDF+aFiles1[nX,1])
	Next

	aFiles1 := Directory(cDirPDF+Alltrim(RetCodUsr())+"\*.PDF")	//-Boleto Itau
	For nX := 1 to Len(aFiles1)
		FErase(cDirPDF+Alltrim(RetCodUsr())+"\"+aFiles1[nX,1])
	Next

	aFiles2 := Directory(cDiret+"*.PDF")	//-Descritivo
	For nX := 1 to Len(aFiles2)
		FErase(cDiret+aFiles2[nX,1])
	Next

	aFiles2 := Directory(cDiret+Alltrim(RetCodUsr())+"\*.PDF")	//-Descritivo
	For nX := 1 to Len(aFiles2)
		FErase(cDiret+Alltrim(RetCodUsr())+"\"+aFiles2[nX,1])
	Next

	if lOnNFSe
		aFiles3 := Directory(cDirNFSe+"*.PDF")	//-NFSe
		For nX := 1 to Len(aFiles3)
			FErase(cDirNFSe+aFiles3[nX,1])
		Next

		aFiles3 := Directory(cDirNFSe+"*.REL")	//-NFSe
		For nX := 1 to Len(aFiles3)
			FErase(cDirNFSe+aFiles3[nX,1])
		Next

		aFiles3 := Directory(cDirNFSe+Alltrim(RetCodUsr())+"\*.PDF")	//-NFSe
		For nX := 1 to Len(aFiles3)
			FErase(cDirNFSe+Alltrim(RetCodUsr())+"\"+aFiles3[nX,1])
		Next
	endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImprBoleto �Autor  � Marcos Candido    � Data �  08/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImprBoleto()
	Local cMsg01 := "O t�tulo desta nota j� foi gerado para o Banco "
	Local cMsg02 := "N�o � permitido alterar o agente cobrador. Verifique."
	Local cMsg03 := "Preencha o campo 'Tipo de Cobran�a' no cadastro do cliente."
	Local cMsg04 := "O campo 'Tipo de Cobran�a' deste cliente informa que ele n�o receber� boletos. Verifique."
	Local nX := 0
	Local cNroDoc :=  " "
	Local aDadosEmp    := {	SM0->M0_NOMECOM                                    							,; 	//[1]Nome da Empresa
							SM0->M0_ENDCOB                                     							,; 	//[2]Endere�o
							AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB	,;	//[3]Complemento
							"CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999")            				,;	//[4]CEP
							"PABX/FAX: "+SM0->M0_TEL                                                  	,;	//[5]Telefones
							"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                   	,;	//[6]CNPJ
							"I.E.: "+Transform(SM0->M0_INSC,"@R 999.999.999.999")}  					//[7]I.E

	Local aDadosTit
	Local aDadosBanco
	Local aDatSacado
	//Local aBolText     := {"Ap�s vencimento, cobrar multa de 2,00% ao m�s." , "Mora di�ria de R$ " , "Protestar ap�s o 5� dia ap�s o vencimento."}
	Local aBolText     := {"Ap�s vencimento, cobrar multa de R$ " , "Mora di�ria de R$ " , "N�o receber sem juros e multa ap�s o vencimento.", "N�o conceder descontos.", "Sujeito a negativa��o ap�s vencimento", "Efetuar o pagamento somente atrav�s desse boleto e na rede bancaria."}

	Local nI           := 1 , nValorTit := 0
	Local aCB_RN_NN    := {}
	//Local cArquivo := Alltrim(SM0->M0_CODFIL)+Alltrim(SF2->F2_DOC)+Alltrim(SF2->F2_SERIE)+"_BOLETO_NF"
	Local cNumNFSe	:= iif(Empty(SF2->F2_NFELETR),SF2->F2_DOC,SF2->F2_NFELETR)
	Local cArquivo := Alltrim(SM0->M0_CODFIL)+"_"+Alltrim(cNumNFSe)+iif(Empty(Alltrim(SF2->F2_SERIE)),"","_"+Alltrim(SF2->F2_SERIE))

	Private cPrefixo := Alltrim(RetCodUsr())
	Private PixelX
	Private PixelY

	//Limpa Vetores para impress�o de eMail
	nValIRRF  := {}
	nValPIS   := {}
	nValCOFI  := {}
	nValCSLL  := {}
	nValBruto := {}
	nValLiq   := {}
	nValMora  := {}
	dVenc	  := {}

	cArquivo := "BOLETO_"+cPrefixo+"_"+cArquivo
	cBolNome := cArquivo
	cNfseNome:= Replace(cArquivo,"BOLETO","NFSE")

	dbSelectArea("SE1")
	dbSetOrder(2)
	If dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC),.T.)

		If Empty(cTipCob)
			IW_MsgBox(OemToAnsi(cMsg03) , OemToAnsi("Aten��o") , "ALERT")
			Return({nX,""})
		Elseif cTipCob <> "B"
			IW_MsgBox(OemToAnsi(cMsg04) , OemToAnsi("Aten��o") , "ALERT")
			Return({nX,""})
		Endif

		//oPrint:= TMSPrinter():New(cArquivo)
		//oPrint:SetPortrait()		// Orientacao da impressao. Nesse caso: Retrato .  ou SetLandscape() --> Paisagem
		//oPrint:SetPaperSize(9)	// Folha A4

		oPrint:= FWMSPrinter():New(cArquivo,6,.T.,,.T.)
		//oPrint:SetPortrait()
		//oPrint:SetPaperSize(9)
		//oPrint:SetMargin(30,70,60,60)  // nEsquerda, nSuperior, nDireita, nInferior
		oPrint:SetResolution(78)
		oPrint:SetPortrait()
		oPrint:SetPaperSize(DMPAPER_A4)
		oPrint:SetMargin(60,60,60,100)

		// ----------------------------------------------
		// Define para salvar o PDF do Boleto Itau !!!
		// ----------------------------------------------
		oPrint:cPathPDF := cDirPDF
		oPrint:SetViewPDF(.F.)

		PixelX := oPrint:nLogPixelX()
		PixelY := oPrint:nLogPixelY()

		// Alterado
/*
		If nBcoBol==1
			cLogoBco  := "\IMAGEM\LOGOITAU.BMP"
			cBanco    := "341"
			cAgencia  := "3128 "
			cContaC   := "020900    "
			cCart     := "109"

		Else
			cLogoBco := "\IMAGEM\LOGOBRAD.BMP"
			cBanco   := "237"
			cAgencia := "3166 "
			cContaC  := "1446053   "
			cCart    := "09"
		Endif
*/
		If nBcoBol==1
			aBanco := StrToKarr( SuperGetMv("MV_ZZCDBOL",.F.,"341/268/516713"), "/" )
			cLogoBco  := "\IMAGEM\LOGOITAU.BMP"
			cBanco    := aBanco[1]
			cAgencia  := aBanco[2]
			cContaC   := Substr(aBanco[3],1,Len(aBanco[3])-1)
			cDV		  := Substr(aBanco[3],Len(aBanco[3]),1)
			cCart     := "109"
		Endif
		cSubConta := "001"

		//Posiciona na Arq de Parametros CNAB
		dbSelectArea("SEE")
		dbSetOrder(1)
		if !dbSeek(xFilial("SEE")+Padr(cBanco, TamSx3("EE_CODIGO")[1])+Padr(cAgencia, TamSx3("EE_AGENCIA")[1])+Padr(cContaC, TamSx3("EE_CONTA")[1])+Padr(cSubConta, TamSx3("EE_SUBCTA")[1]))
			Alert("Banco n�o configurado nos parametros CNAB "+cBanco+"/"+cAgencia+"/"+cContaC)
			Return({ 0, "" })
		else
			cBcoAg  := StrTran(Alltrim(SEE->EE_AGENCIA),"-","")
			cBcoCon := StrTran(Alltrim(SEE->EE_CONTA) + Alltrim(SEE->EE_DVCTA),"-","")
		endif
		// Alterado
/*
		If nBcoBol==1
			aDadosBanco  := {SEE->EE_CODIGO                    		,;	// [1]Numero do Banco
							cLogoBco                    			,;	// [2]Nome do Banco (LOGO)
							Transform(cBcoAg,"@R 9999")			,;	// [3]Ag�ncia
							Transform(cBcoCon,"@R 99999-9")		,;	// [4]Conta Corrente
							cCart}				    					// [5]Codigo da Carteira
		Else
			aDadosBanco  := {SEE->EE_CODIGO                    		,;	// [1]Numero do Banco
							cLogoBco                    			,;	// [2]Nome do Banco (LOGO)
							Transform(StrZero(Val(cBcoAg),5),"@R 9999-9")			,;	// [3]Ag�ncia
							Transform(cBcoCon,"@R 999999-9")		,;	// [4]Conta Corrente
							cCart}				    					// [5]Codigo da Carteira
		Endif
*/
		If nBcoBol==1
			aDadosBanco  := {SEE->EE_CODIGO                    		,;	// [1]Numero do Banco
			cLogoBco                    			,;	// [2]Nome do Banco (LOGO)
			Transform(cBcoAg,"@R 9999")			,;	// [3]Ag�ncia
			Transform(cBcoCon,"@R 99999-9")		,;	// [4]Conta Corrente
			cCart}				    					// [5]Codigo da Carteira
		Endif

		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)           	,;     	// [1]Raz�o Social
			AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA           	,;     	// [2]C�digo
			AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO)	,;     	// [3]Endere�o
			AllTrim(SA1->A1_MUN)                            	,; 		// [4]Cidade
			SA1->A1_EST                                      	,;    	// [5]Estado
			SA1->A1_CEP                                      	,;     	// [6]CEP
			SA1->A1_CGC										 	,; 		// [7]CGC
			iif(len(Alltrim(SA1->A1_CGC))==11,"F","J")		}  			// [8]PESSOA
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)            	 ,;   	// [1]Raz�o Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]C�digo
			AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endere�o
			AllTrim(SA1->A1_MUNC)	                             ,;   	// [4]Cidade
			SA1->A1_ESTC	                                     ,;   	// [5]Estado
			SA1->A1_CEPC                                        ,;   	// [6]CEP
			SA1->A1_CGC											 ,;		// [7]CGC
			iif(len(Alltrim(SA1->A1_CGC))==11,"F","J")		}  			// [8]PESSOA
		Endif

		dbSelectArea("SE1")
		lOk := .T.
		nParcela := 0
		While !SE1->(Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and. lOk .and.;
				SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

			If !(Alltrim(SE1->E1_TIPO) $ "NF/FT")
				dbSkip()
				Loop
			Endif

			nParcela++

			If nBcoBol == 1 .and. !Empty(SE1->E1_PORTADO) .and. SE1->E1_PORTADO == "237" // .and. !Empty(SE1->E1_NUMBCO) .and. Len(Alltrim(SE1->E1_NUMBCO)) > 9
				IW_MsgBox(OemToAnsi(cMsg01+"Bradesco. "+cMsg02) , OemToAnsi("Aten��o") , "STOP")
				lOk := .F.
				Loop
			ElseIf nBcoBol == 2 .and. !Empty(SE1->E1_PORTADO) .and. SE1->E1_PORTADO == "341" // .and. !Empty(SE1->E1_NUMBCO) .and. Len(Alltrim(SE1->E1_NUMBCO)) == 9
				IW_MsgBox(OemToAnsi(cMsg01+"Ita�. "+cMsg02) , OemToAnsi("Aten��o") , "STOP")
				lOk := .F.
				Loop
			Endif

			aAreaSE1  := GetArea()
			aadd(nValIRRF,0)
			aadd(nValPIS,0)
			aadd(nValCOFI,0)
			aadd(nValCSLL,0)
			aadd(nValBruto,0)
			aadd(nValLiq,0)
			aadd(nValMora,0)
			aadd(dVenc,SE1->E1_VENCTO)
			nVlIRRF := 0

		/*
			nValorTit := SE1->(E1_VALOR-E1_DECRESC+E1_ACRESC)
			nTotImp   := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_EMISSAO,,@nValIRRF,@nValCSLL,@nValPIS,@nValCOFI)
			nValorTit := nValorTit - (nValIRRF + nValPIS + nValCOFI + nValCSLL)
		*/
			//Calcular valor liquido PCC
			nValBruto[nParcela] := SE1->(E1_VALOR-E1_DECRESC+E1_ACRESC)
			nTotImp      := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_EMISSAO,,@nVlIRRF,@nValCSLL,@nValPIS,@nValCOFI)
			nValIRRF[nParcela]  := nVlIRRF
			nValCSLL[nParcela]  := iif(SE1->E1_CSLL>=SuperGetMv( "MV_ZZRTCSL"),SE1->E1_CSLL,0)
			nValCOFI[nParcela]  := iif(SE1->E1_COFINS>=SuperGetMv( "MV_ZZRTCOF"),SE1->E1_COFINS,0)
			nValPIS[nParcela]   := iif(SE1->E1_PIS>=SuperGetMv( "MV_ZZRTPIS"),SE1->E1_PIS,0)
			nValorTit           := nValBruto[nParcela] - (nValIRRF[nParcela] + nValPIS[nParcela] + nValCOFI[nParcela] + nValCSLL[nParcela])
			nValLiq[nParcela]	:= nValorTit

			RestArea(aAreaSE1)

			If nBcoBol == 1
				cNroDoc := Right(Alltrim(SE1->E1_NUMBCO),9)
				cNroDoc := Substr(cNroDoc,1,8)
				If Empty(cNroDoc)
					cNroDoc := StrZero(VAL(NOSSONUM()),08)
					cConta  := Substr(cBcoCon,1,Len(AllTrim(cBcoCon))-1)
					nDvnn   := Modulo10(cBcoAg+cConta+aDadosBanco[5]+cNroDoc)
					RecLock("SE1",.F.)
					SE1->E1_NUMBCO := cNroDoc+AllTrim(Str(nDvnn))
					//SECTION ticket: 264975
					//NOTE - alterado por Leandro Cesar 03/11/22
					//LINK - http://cs.solucaocompacta.com.br/compacta/paginas/assentamento.php?idocorr=264975
					If SE1->(FieldPos("E1_XBCONUM")) > 0
						SE1->E1_XBCONUM := cNroDoc+AllTrim(Str(nDvnn))
					EndIf
					//!SECTION
					MsUnlock()
					cNroDoc := Right(Alltrim(SE1->E1_NUMBCO),9)
					cNroDoc := Substr(cNroDoc,1,8)
				Endif
				//Monta codigo de barras
				aCB_RN_NN := I_Ret_cBarra(aDadosBanco[1], Alltrim(cNroDoc) , nValorTit , aDadosBanco[5] , cBcoAg , cBcoCon )
			Else
				cNroDoc  := Alltrim(SE1->E1_NUMBCO)
				If Empty(cNroDoc)
					cNroDoc := Right(StrZero(VAL(NOSSONUM()),11),11)
				Endif
				//Monta codigo de barras
				aCB_RN_NN := B_Ret_cBarra(aDadosBanco[1] , cNroDoc , nValorTit , aDadosBanco[5] , "9" )
				RecLock("SE1",.F.)
				SE1->E1_NUMBCO := Substr(aCB_RN_NN[3],3)  // Nosso n�mero sem a carteira
				//SECTION ticket: 264975
				//NOTE - alterado por Leandro Cesar 03/11/22
				//LINK - http://cs.solucaocompacta.com.br/compacta/paginas/assentamento.php?idocorr=264975
				If SE1->(FieldPos("E1_XBCONUM")) > 0
					SE1->E1_XBCONUM := Substr(aCB_RN_NN[3],3)
				EndIf
				//!SECTION
				MsUnlock()
			Endif
			cNroDoc := Alltrim(cNroDoc)

			dbSelectArea("SE1")
			nMora := 0
			If E1_PORCJUR == 0
				nMora := NoRound(nValorTit*0.0006666666,2) //Utilizar 2,3% a.m.
			Else
				nMora := NoRound(nValorTit*(E1_PORCJUR/100),2)
			Endif
			aadd(nValMora,nMora)

			RecLock("SE1",.F.)
			Replace	E1_VALJUR	With	nMora
			MsUnlock()

			//Altera��o do n�mero que sai no boleto, vai pegar o n�mero NFSe e nao mais do RPS, altera�a� solicitada pela Renata Pereira - 02/08/2024
			aDadosTit	:= {AllTrim(cNumNFSe)+AllTrim(E1_PARCELA)		,;  // [1] N�mero do t�tulo
								E1_EMISSAO                          ,;  // [2] Data da emiss�o do t�tulo
								dDataBase                    		,;  // [3] Data da emiss�o do boleto
								E1_VENCTO                           ,;  // [4] Data do vencimento
								nValorTit             				,;  // [5] Valor do t�tulo
								cNroDoc                             ,;  // [6] Nosso n�mero
								E1_PREFIXO                          ,;  // [7] Prefixo da NF
								E1_TIPO	                           	,;	// [8] Tipo do Titulo
								nMora}   								// [9] Mora diaria

			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

			dbSelectArea("SE1")
			dbSkip()
		Enddo

		If lOk
			//�������������������������������Ŀ
			//�  Visualiza antes de imprimir  �
			//���������������������������������
			oPrint:Preview()

			//����������������������������������������������������Ŀ
			//� Gravo o relatorio em  .JPEG para posterior envio.  �
			//� largura x altura    							   �
			//�                      						       �
			//� Tenho que gravar ANTES de fazer Preview, senao as  �
			//� figuras agregadas no objeto nao sao fixadas na     �
			//� gravacao do arquivo de extensao .JPEG              �
			//������������������������������������������������������
			//oPrint:SaveAllAsJpeg(cDiret+cArquivo,1120,1640,180) //  LARGURA X ALTURA X DPI
		Else
			nValorTit := 0
		Endif
	Endif

	//�������������������������������������������������������������Ŀ
	//�  Faz copia do diretorio local para o diretorio do servidor  �
	//���������������������������������������������������������������
	CpyT2S(cDirPDF+cArquivo+"*.PDF", cDiret)

	//������������������������������������������������������Ŀ
	//� Varre o diret�rio e procura pelas p�ginas gravadas.  �
	//��������������������������������������������������������
	aFiles1 := Directory(cDiret+cArquivo+"*.PDF" )	//-Boleto Itau

Return({nValorTit,aDadosTit[7]+aDadosTit[1]})

/*/
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Programa  �  Impress � Autor � Microsiga             � Data �          ���
	�������������������������������������������������������������������������Ĵ��
	���Descricao � IMPRESSAO DO BOLETO LASER                                  ���
	�������������������������������������������������������������������������Ĵ��
	���Uso       � Especifico para Clientes Microsiga                         ���
	��������������������������������������������������������������������������ٱ�
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

	Local oFont8
	Local oFont11c
	Local oFont10
	Local oFont14
	Local oFont16n
	Local oFont15
	Local oFont14n
	Local oFont24
	Local nI := 0

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
	oFont8  := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont18n := TFont():New("Arial",9,18,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:StartPage()   // Inicia uma nova p�gina

	nHPage := oPrint:nHorzRes()
	nHPage *= (300/PixelX)
	nHPage -= HMARGEM
	nVPage := oPrint:nVertRes()
	nVPage *= (300/PixelY)
	nVPage -= VBOX

/******************/
/* PRIMEIRA PARTE */
/******************/

	nRow1 := 0

	oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
	oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

	If nBcoBol == 1
		oPrint:SayBitMap(nRow1   ,095,aDadosBanco[2],150,130)		// [2]Nome do Banco (LOGO)
		oPrint:Say  (nRow1+0139,527,aDadosBanco[1]+"-7",oFont21 )	// [1]Numero do Banco
	Else
		oPrint:SayBitMap(nRow1+50,095,aDadosBanco[2],370,095)		// [2]Nome do Banco (LOGO)  345,130 largura x altura
		oPrint:Say  (nRow1+0139,527,aDadosBanco[1]+"-2",oFont21 )	// [1]Numero do Banco
	Endif
	oPrint:Say  (nRow1+0140,1900,"Comprovante de Entrega",oFont10)
	oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

	oPrint:Say  (nRow1+0170,100 ,"Beneficiario",oFont8)
	oPrint:Say  (nRow1+0220,100 ,aDadosEmp[1],oFont10)				//Nome + CNPJ

	oPrint:Say  (nRow1+0170,1060,"Ag�ncia/C�digo Beneficiario",oFont8)
	oPrint:Say  (nRow1+0220,1060,aDadosBanco[3]+"/"+aDadosBanco[4],oFont10)

	oPrint:Say  (nRow1+0170,1510,"Nro.Documento",oFont8)
	oPrint:Say  (nRow1+0220,1510,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow1+0270,100 ,"Pagador",oFont8)
	oPrint:Say  (nRow1+0320,100 ,aDatSacado[1],oFont10)				//Nome

	oPrint:Say  (nRow1+0270,1060,"Vencimento",oFont8)
	oPrint:Say  (nRow1+0320,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

	oPrint:Say  (nRow1+0270,1510,"Valor do Documento",oFont8)
	oPrint:Say  (nRow1+0320,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

	oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/t�tulo",oFont10)
	oPrint:Say  (nRow1+0440,0100,"com as caracter�sticas acima.",oFont10)

	oPrint:SayBitMap(nRow1+0370,630,cLogoEmp,370,095)	// LOGO DA EMPRESA

	oPrint:Say  (nRow1+0375,1060,"Data",oFont8)
	oPrint:Say  (nRow1+0375,1410,"Assinatura",oFont8)
	oPrint:Say  (nRow1+0475,1060,"Data",oFont8)
	oPrint:Say  (nRow1+0475,1410,"Entregador",oFont8)

	oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
	oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
	oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
	oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

	oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
	oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
	oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
	oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

	oPrint:Say  (nRow1+0185,1910,"(  )Mudou-se"                                	,oFont8)
	oPrint:Say  (nRow1+0225,1910,"(  )Ausente"                                    ,oFont8)
	oPrint:Say  (nRow1+0265,1910,"(  )N�o existe n� indicado"                  	,oFont8)
	oPrint:Say  (nRow1+0305,1910,"(  )Recusado"                                	,oFont8)
	oPrint:Say  (nRow1+0345,1910,"(  )N�o procurado"                              ,oFont8)
	oPrint:Say  (nRow1+0385,1910,"(  )Endere�o insuficiente"                  	,oFont8)
	oPrint:Say  (nRow1+0425,1910,"(  )Desconhecido"                            	,oFont8)
	oPrint:Say  (nRow1+0465,1910,"(  )Falecido"                                   ,oFont8)
	oPrint:Say  (nRow1+0505,1910,"(  )Outros(anotar no verso)"                  	,oFont8)

/*****************/
/* SEGUNDA PARTE */
/*****************/
	nRow2 := 180

//Pontilhado separador
	For nI := 100 to 2300 step 50
		oPrint:Line(nRow2+0540, nI,nRow2+0540, nI+30)
	Next nI

	If nBcoBol == 1
		oPrint:SayBitMap(nRow2+0560,095,aDadosBanco[2],150,130)	// [2]Nome do Banco (LOGO)
		oPrint:Say  (nRow2+0699,527,aDadosBanco[1]+"-7",oFont21 )	// [1]Numero do Banco
	Else
		oPrint:SayBitMap(nRow2+0610,095,aDadosBanco[2],370,095)		// [2]Nome do Banco (LOGO)
		oPrint:Say  (nRow2+0699,527,aDadosBanco[1]+"-2",oFont21 )	// 	[1]Numero do Banco
	Endif

	oPrint:Say  (nRow2+0700,1800,"Recibo do Pagador",oFont10)

	oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
	oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
	oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

	oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
	oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
	oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
	oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

	oPrint:Line (nRow2+0910,500,nRow2+1050,500)
	oPrint:Line (nRow2+0980,375,nRow2+1050,375)
	oPrint:Line (nRow2+0980,750,nRow2+1050,750)
	oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
	oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
	oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

	oPrint:Say  (nRow2+0730,100 ,"Local de Pagamento",oFont8)
	If nBcoBol == 1
		oPrint:Say  (nRow2+0755,400 ,"Preferencialmente nas ag�ncias Ita�,",oFont10)
	Else
		oPrint:Say  (nRow2+0755,400 ,"Preferencialmente nas ag�ncias Bradesco,",oFont10)
	Endif
	oPrint:Say  (nRow2+0785,400 ,"ou at� o vencimento em qualquer banco.",oFont10)

	oPrint:Say  (nRow2+0730,1810,"Vencimento"                                     ,oFont8)
	cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0785,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0830,100 ,"Beneficiario"                                        ,oFont8)
	oPrint:Say  (nRow2+0885,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

	oPrint:Say  (nRow2+0830,1810,"Ag�ncia/C�digo Beneficiario",oFont8)
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4])
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0885,nCol+090,cString,oFont11c)

	oPrint:Say  (nRow2+0930,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say  (nRow2+0970,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

	oPrint:Say  (nRow2+0930,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (nRow2+0970,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow2+0930,1005,"Esp�cie Doc."                                   ,oFont8)
//oPrint:Say  (nRow2+0940,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo
	oPrint:Say  (nRow2+0970,1050,"DM" 									,oFont10) //Tipo do Titulo

	oPrint:Say  (nRow2+0930,1305,"Aceite"                                         ,oFont8)
	oPrint:Say  (nRow2+0970,1400,"N"                                             ,oFont10)

	oPrint:Say  (nRow2+0930,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (nRow2+0970,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

	oPrint:Say  (nRow2+0930,1810,"Cart/Nosso N�mero"                                   ,oFont8)
	cString := Alltrim(aCB_RN_NN[3])
	nCol := 1810+(374-(len(cString)*22))
	If nBcoBol == 1
		oPrint:Say  (nRow2+0970,nCol+20,Transform(cString,"@R XXX/XXXXXXXX-X"),oFont11c)
	Else
		oPrint:Say  (nRow2+0970,nCol+20,Transform(cString,"@R XX/XXXXXXXXXXX-X"),oFont11c)
	Endif
	oPrint:Say  (nRow2+1000,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (nRow2+1000,380 ,"CIP"                                     ,oFont8)
	oPrint:Say  (nRow2+1040,400 ,"000"                                  	,oFont10)

	oPrint:Say  (nRow2+1000,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (nRow2+1040,555 ,aDadosBanco[5]                                  	,oFont10)

	oPrint:Say  (nRow2+1000,755 ,"Esp�cie"                                        ,oFont8)
	oPrint:Say  (nRow2+1040,805 ,"R$"                                             ,oFont10)

	oPrint:Say  (nRow2+1000,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say  (nRow2+1000,1485,"Valor"                                          ,oFont8)

	oPrint:Say  (nRow2+1000,1810,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 999,999,999.99"))
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+1040,nCol,cString ,oFont11c)

	oPrint:Say  (nRow2+1075,100 ,"Instru��es (Todas informa��es deste bloqueto s�o de exclusiva responsabilidade do beneficiario)",oFont8)
//oPrint:Say  (nRow2+1120,100 ,aBolText[1],oFont10)
	// oPrint:Say  (nRow2+1120,100 ,aBolText[1]+Transform(NoRound(aDadosTit[5]*(2/100),2),"@E 999,999.99"),oFont10)
	oPrint:Say  (nRow2+1120,100 ,aBolText[1]+Transform(NoRound(aDadosTit[5]*(6/100),2),"@E 999,999.99") + " ao m�s.",oFont10)
	oPrint:Say  (nRow2+1160,100 ,aBolText[2]+Transform(aDadosTit[9],"@E 999,999.99"),oFont10)
// Imprime mensagem especial caso seja Carrefour
	If Substr(aDatSacado[7],1,8)= '45543915'
		oPrint:Say  (nRow2+1200,100 ,"CNPJ DO FORNECEDOR: "+StrTran(aDadosEmp[6],"CNPJ: ",""),oFont10)
		oPrint:Say  (nRow2+1240,100 ,"CNPJ DE RECEBIMENTO GRUPO CARRREFOUR: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)
		oPrint:Say  (nRow2+1280,100 ,"NUMERO DA NOTA FISCAL: "+aDadosTit[1],oFont10)
		oPrint:Say  (nRow2+1320,100 ,aBolText[3],oFont10)
		oPrint:Say  (nRow2+1360,100 ,aBolText[4],oFont10)
		oPrint:Say  (nRow2+1400,100 ,aBolText[5],oFont10)
		oPrint:Say  (nRow2+1440,100 ,aBolText[6],oFont10)
	Else
		oPrint:Say  (nRow2+1200,100 ,aBolText[3],oFont10)
		oPrint:Say  (nRow2+1240,100 ,aBolText[4],oFont10)
		oPrint:Say  (nRow2+1280,100 ,aBolText[5],oFont10)
		oPrint:Say  (nRow2+1320,100 ,aBolText[6],oFont10)
	Endif

	oPrint:SayBitMap(nRow2+1120,1300,cLogoEmp,370,095)	// LOGO DA EMPRESA

	oPrint:Say  (nRow2+1070,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow2+1140,1810,"(-)Outras Dedu��es"                             ,oFont8)
	oPrint:Say  (nRow2+1210,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow2+1280,1810,"(+)Outros Acr�scimos"                           ,oFont8)
	oPrint:Say  (nRow2+1350,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (nRow2+1425,100 ,"Pagador"                                         ,oFont8)
	oPrint:Say  (nRow2+1465,300 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
	oPrint:Say  (nRow2+1505,300 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (nRow2+1545,300 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow2+1585,300 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow2+1585,300 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
	EndIf

	oPrint:Say  (nRow2+1625,100 ,"Sacador/Avalista",oFont8)
	oPrint:Say  (nRow2+1670,1500,"Autentica��o Mec�nica",oFont8)

	oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
	oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
	oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
	oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
	oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
	oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
	oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )

/******************/
/* TERCEIRA PARTE */
/******************/
	nRow3 := 200

	//Pontilhado separador
	For nI := 100 to 2300 step 50
		oPrint:Line(nRow3+1820, nI, nRow3+1820, nI+30)
	Next nI

	If nBcoBol == 1
		oPrint:SayBitMap(nRow3+1850,095,aDadosBanco[2],150,130)		//  [2]Nome do Banco (LOGO)
		oPrint:Say  (nRow3+1989,527,aDadosBanco[1]+"-7",oFont21 )		// 	[1]Numero do Banco
	Else
		oPrint:SayBitMap(nRow3+1900,095,aDadosBanco[2],370,095)		//  [2]Nome do Banco (LOGO)
		oPrint:Say  (nRow3+1989,527,aDadosBanco[1]+"-2",oFont21 )		// 	[1]Numero do Banco
	Endif
	oPrint:Say  (nRow3+1980,755,aCB_RN_NN[2],oFont18n)			//	Linha Digitavel do Codigo de Barras

	oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
	oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
	oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

	oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
	oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
	oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
	oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

	oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
	oPrint:Line (nRow3+2270,375,nRow3+2340,375)
	oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
	oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
	oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
	oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

	oPrint:Say  (nRow3+2015,100 ,"Local de Pagamento",oFont8)
	If nBcoBol == 1
		oPrint:Say  (nRow3+2040,400 ,"Preferencialmente nas ag�ncias Ita�,",oFont10)
	Else
		oPrint:Say  (nRow3+2040,400 ,"Preferencialmente nas ag�ncias Bradesco,",oFont10)
	Endif
	oPrint:Say  (nRow3+2070,400 ,"ou at� o vencimento em qualquer banco.",oFont10)

	oPrint:Say  (nRow3+2015,1810,"Vencimento",oFont8)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol	 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2055,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2120,100 ,"Beneficiario",oFont8)
	oPrint:Say  (nRow3+2175,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

	oPrint:Say  (nRow3+2120,1810,"Ag�ncia/C�digo Beneficiario",oFont8)
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4])
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2175,nCol+090,cString ,oFont11c)

	oPrint:Say  (nRow3+2220,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say (nRow3+2260,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

	oPrint:Say  (nRow3+2220,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (nRow3+2260,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow3+2220,1005,"Esp�cie Doc."                                   ,oFont8)
//oPrint:Say  (nRow3+2230,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo
	oPrint:Say  (nRow3+2260,1050,"DM"									,oFont10) //Tipo do Titulo

	oPrint:Say  (nRow3+2220,1305,"Aceite"                                         ,oFont8)
	oPrint:Say  (nRow3+2260,1400,"N"                                             ,oFont10)

	oPrint:Say  (nRow3+2220,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (nRow3+2260,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao

	oPrint:Say  (nRow3+2220,1810,"Cart/Nosso N�mero"                                   ,oFont8)
	cString := Alltrim(aCB_RN_NN[3])
	nCol 	 := 1810+(374-(len(cString)*22))
	If nBcoBol == 1
		oPrint:Say  (nRow3+2260,nCol+20,Transform(cString,"@R XXX/XXXXXXXX-X"),oFont11c)
	Else
		oPrint:Say  (nRow3+2260,nCol+20,Transform(cString,"@R XX/XXXXXXXXXXX-X"),oFont11c)
	Endif

	oPrint:Say  (nRow3+2290,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (nRow3+2290,380 ,"CIP"                                     ,oFont8)
	oPrint:Say  (nRow3+2330,400 ,"000"                                  	,oFont10)

	oPrint:Say  (nRow3+2290,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (nRow3+2330,555 ,aDadosBanco[5]                                  	,oFont10)

	oPrint:Say  (nRow3+2290,755 ,"Esp�cie"                                        ,oFont8)
	oPrint:Say  (nRow3+2330,805 ,"R$"                                             ,oFont10)

	oPrint:Say  (nRow3+2290,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say  (nRow3+2290,1485,"Valor"                                          ,oFont8)

	oPrint:Say  (nRow3+2290,1810,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 999,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2330,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2355,100 ,"Instru��es (Todas informa��es deste bloqueto s�o de exclusiva responsabilidade do beneficiario)",oFont8)
//oPrint:Say  (nRow3+2400,100 ,aBolText[1],oFont10)
	// oPrint:Say  (nRow3+2400,100 ,aBolText[1]+Transform(NoRound(aDadosTit[5]*(2/100),2),"@E 999,999.99"),oFont10)
	oPrint:Say  (nRow3+2400,100 ,aBolText[1]+Transform(NoRound(aDadosTit[5]*(6/100),2),"@E 999,999.99") + " ao m�s.",oFont10)
	oPrint:Say  (nRow3+2440,100 ,aBolText[2]+Transform(aDadosTit[9],"@E 999,999.99"),oFont10)
// Imprime mensagem especial caso seja Carrefour
//If Substr(aDatSacado[7],1,8)= '45543915'
//	oPrint:Say  (nRow3+2480,100 ,"CNPJ DO FORNECEDOR: "+StrTran(aDadosEmp[6],"CNPJ: ",""),oFont10)
//	oPrint:Say  (nRow3+2520,100 ,"CNPJ DE RECEBIMENTO GRUPO CARRREFOUR: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)
//	oPrint:Say  (nRow3+2560,100 ,"NUMERO DA NOTA FISCAL: "+aDadosTit[1],oFont10)
//	oPrint:Say  (nRow3+2600,100 ,aBolText[3],oFont10)
//Else
	oPrint:Say  (nRow3+2480,100 ,aBolText[3],oFont10)
	oPrint:Say  (nRow3+2520,100 ,aBolText[4],oFont10)
	oPrint:Say  (nRow3+2560,100 ,aBolText[5],oFont10)
	oPrint:Say  (nRow3+2600,100 ,aBolText[6],oFont10)
//Endif

	oPrint:Say  (nRow3+2355,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow3+2430,1810,"(-)Outras Dedu��es"                             ,oFont8)
	oPrint:Say  (nRow3+2500,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow3+2570,1810,"(+)Outros Acr�scimos"                           ,oFont8)
	oPrint:Say  (nRow3+2640,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (nRow3+2705,100 ,"Pagador"                                         ,oFont8)
	oPrint:Say  (nRow3+2730,300 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow3+2730,1600,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow3+2730,1600,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
	EndIf

	oPrint:Say  (nRow3+2760,300 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (nRow3+2790,300 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	oPrint:Say  (nRow3+2830,100 ,"Sacador/Avalista"                               ,oFont8)
	oPrint:Say  (nRow3+2865,1500,"Autentica��o Mec�nica - Ficha de Compensa��o"                        ,oFont8)

	oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
	oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
	oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
	oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
	oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
	oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

	oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

	//MSBAR3("INT25",26,0.8,aCB_RN_NN[1],oPrint  ,.F. ,Nil,Nil ,0.025,1.20,Nil,Nil,"A",.F.)
	oPrint:FWMSBAR("INT25" /*cTypeBar*/,70/*nRow*/ ,1.5/*nCol*/, aCB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.025/*nWidth*/,1.20/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
	oPrint:EndPage() // Finaliza a p�gina

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �RetDados  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � calculos para o banco Itau     					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function I_Ret_cBarra(cCodBanco,cNroDoc,nValor,cCart,cBcoAg,cBcoCon)

	Local cValorFinal := StrZero(nValor*100,10)
	Local nDvnn			:= 0
	Local nDvcb			:= 0
	Local nDv			:= 0
	Local cNN			:= ''
	Local cRN			:= ''
	Local cCB			:= ''
	Local cS			:= ''
	Local cFator        := StrZero(SE1->E1_VENCTO - IIF(DTOS(SE1->E1_VENCTO)>=GetMv("CL_NVDTBL"),CtoD(GetMv("CL_DT1000")),CtoD("07/10/1997")), 4)

	cConta := Substr(cBcoCon,1,Len(AllTrim(cBcoCon))-1)
	cDacCC := Substr(cBcoCon,Len(AllTrim(cBcoCon)),1)

//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
	cS    := cBcoAg + cConta + cCart + cNroDoc
	nDvnn := Modulo10(cS) // digito verificador Agencia + Conta + Carteira + Nosso Num
	cNN   := cCart + cNroDoc + AllTrim(Str(nDvnn))

//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
	cS    := cCodBanco + "9" + cFator +  cValorFinal + cNN + cBcoAg + cConta + cDacCC + '000'
	nDvcb := I_Modulo11(cS)
	cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cS    := cCodBanco + "9" + cCart + SubStr(cNroDoc,1,2)
	nDv   := Modulo10(cS)
	cRN   := Transform(cS+AllTrim(Str(nDv)),"@R 99999.99999") + ' '

// 	CAMPO 2:
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	cS  := Substr(cNroDoc,3,6) + Alltrim(Str(nDvnn))+ Subs(cBcoAg,1,3)
	nDv := Modulo10(cS)
	cRN += Transform(cS+AllTrim(Str(nDv)),"@R 99999.999999") + ' '

// 	CAMPO 3:
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cS    := Subs(cBcoAg,4,1) + cBcoCon + '000'
	nDv   := Modulo10(cS)
	cRN   += Transform(cS+AllTrim(Str(nDv)),"@R 99999.999999") + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
	cRN   += AllTrim(Str(nDvcb)) + ' '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
	cRN   += cFator + cValorFinal

Return({cCB,cRN,cNN})

/*/
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Programa  � Modulo10 � Autor � Microsiga             � Data � 13/10/03 ���
	�������������������������������������������������������������������������Ĵ��
	���Descricao � IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ���
	�������������������������������������������������������������������������Ĵ��
	���Uso       � Especifico para Clientes Microsiga                         ���
	��������������������������������������������������������������������������ٱ�
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
/*/
Static Function Modulo10(cData)
	Local L,D,P := 0
	Local B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
Return(D)

/*/
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Programa  � Modulo11 � Autor � Microsiga             � Data � 13/10/03 ���
	�������������������������������������������������������������������������Ĵ��
	���Descricao � IMPRESSAO DO BOLETO LASER DO ITAU COM CODIGO DE BARRAS     ���
	�������������������������������������������������������������������������Ĵ��
	���Uso       � Especifico para Clientes Microsiga                         ���
	��������������������������������������������������������������������������ٱ�
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
/*/
Static Function I_Modulo11(cData)
	Local L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
	D := 11 - (mod(D,11))
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	Endif
Return(D)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �RetDados  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � calculos para o banco Bradesco 					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function B_Ret_cBarra(cBanco,cNroDoc,nValor,cCart,cMoeda)
	Local cNosso		:= ""
	Local cDigNosso		:= ""
	Local NNUM			:= ""
	Local cCampoL		:= ""
	Local cFatorValor	:= ""
	Local cLivre		:= ""
	Local cDigBarra		:= ""
	Local cBarra		:= ""
	Local cParte1		:= ""
	Local cDig1			:= ""
	Local cParte2		:= ""
	Local cDig2			:= ""
	Local cParte3		:= ""
	Local cDig3			:= ""
	Local cParte4		:= ""
	Local cParte5		:= ""
	Local cDigital		:= ""
	Local aRet			:= {}

//Nosso Numero
	If Len(cNroDoc) == 12 // ja tem o digito
		cNosso := Substr(cNroDoc,1,11)
		cDigNN := Substr(cNroDoc,12,1)
	Else
		cNosso := cNroDoc
		cDigNN := DIGNUMB(cNosso)
	Endif

// campo livre
	cCampoL := Substr(SEE->EE_AGENCIA,1,4)+cCart+cNosso+StrZero(Val(Substr(SEE->EE_CONTA,1,6)),7)+"0"

//Fator de Vencimento + Valor do titulo
	cFator := StrZero(SE1->E1_VENCTO - IIF(DTOS(SE1->E1_VENCTO)>=GetMv("CL_NVDTBL"),CtoD(GetMv("CL_DT1000")),CtoD("07/10/1997")), 4)
	cFatorValor  := cFator+StrZero(nValor*100,10)

	cLivre := cBanco+cMoeda+cFatorValor+cCampoL

// campo do codigo de barra
	cDigBarra := CALC_DB(cLivre)
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5)

// composicao da linha digitavel
	cParte1  := Substr(cBarra,1,4)+SUBSTR(cBarra,20,5)
	cDig1    := DIGITO001( cParte1 )
	cParte2  := Substr(cBarra,25,10)
	cDig2    := DIGITO001( cParte2 )
	cParte3  := Substr(cBarra,35,10)
	cDig3    := DIGITO001( cParte3 )
	cParte4  := cDigBarra
	cParte5  := cFatorValor

	cDigital := Transform(cParte1+cDig1,"@R 99999.99999")+" "+;
		Transform(cParte2+cDig2,"@R 99999.999999")+" "+;
		Transform(cParte3+cDig3,"@R 99999.999999")+" "+;
		cParte4+" "+cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cCart+cNosso+cDigNN)

Return aRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DIGITO001 �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Para calculo da linha digitavel                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DIGITO001(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	umdois := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		auxi   := Val(SubStr(cBase, idig, 1)) * umdois
		sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
		umdois := 3 - umdois
		iDig:=iDig-1
	EndDo
	cValor:=AllTrim(STR(sumdig,12))
	nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
	auxi := nDezena - sumdig

	If auxi >= 10
		auxi := 0
	EndIf

Return(str(auxi,1,0))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_DB   �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do digito do codigo de barras                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CALC_DB(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	base   := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		If base >= 10
			base := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base   := base + 1
		iDig   := iDig-1
	EndDo
	auxi := mod(sumdig,11)
	If auxi == 0 .or. auxi == 1 .or. auxi >= 10
		auxi := 1
	Else
		auxi := 11 - auxi
	EndIf

Return(str(auxi,1,0))


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BOLBRAD   �Autor  �Microsiga           � Data �  05/22/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � calcula o digito no NOSSO NUMERO                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DIGNUMB(cEsteNum)
	Local cNUMBCO := STRZERO(VAL(cEsteNum),11)
	Local cDIGITO := MODULO11("09"+cNUMBCO,2,7)
	Local nSoma := 0
	Local I     := 0

	IF cDIGITO == "0"
		nSOMA += 0*2 + 9*7
		FOR I:=1 TO 11
			IF I<6
				nSOMA += (7-I)*VAL(SUBSTR(cNUMBCO,I,1))
			ELSE
				nSOMA += (13-I)*VAL(SUBSTR(cNUMBCO,I,1))
			ENDIF
		NEXT
		cDIGITO := IIF(MOD(nSOMA,11)==1,"P","0")
	ENDIF

Return(cDIGITO)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EnviaEmail �Autor  � Marcos Candido     � Data �  08/02/11 ���
�������������������������������������������������������������������������͹��
���Desc.     � Envia email com documentos que foram selecionados.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Eurofins                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EnviaEmail(nValorTit,lMostra)
	Local cServer  := Alltrim(GetMV("MV_RELSERV",,""))			//"smtp.suaconta.com.br"
	//Local cAccount := Alltrim(GetMV("MV_RELACNT"))			//"seu@email.com.br"
	//Local cPass    := Alltrim(GetMV("MV_RELPSW"))			//senha do email
	// Alterado
	//Local cAccount := "agatagomes@eurofins.com.br"
	//Local cPass    := "Seviero@1"
	Local cAccount	:= Alltrim(GetMV("MV_ZZEMFAT",,""))
	Local cPass		:= "Eurofins@1"

	Local cNumNFSe	:= iif(Empty(SF2->F2_NFELETR),SF2->F2_DOC,SF2->F2_NFELETR)

	Local cUserAut := Alltrim(GetMv("MV_RELAUSR",,cAccount))//Usu�rio para Autentica��o no Servidor de Email
	Local cPassAut := Alltrim(GetMv("MV_RELAPSW",,cPass))	//Senha para Autentica��o no Servidor de Email
	Local lAutentica  := GetMv("MV_RELAUTH",,.F.)			//Determina se o Servidor de Email necessita de Autentica��o
	Local cPara    := "" , aPara   := {}
	Local cAnexos  := ""
	Local cMsg     := ""
	Local cAssunto := "NFS-e emitida: "+Alltrim(cNumNFSe)+" - "+Alltrim(SM0->M0_NOMECOM)
	Local aPedido  := {}
	//Local cCopia   := "agatagomes@eurofins.com.br"
	// Alterado
	Local cCopia   := GetMV("ZZ_MAILDSC",,"")
	Local lOk := .F.
	Local cTxt1 := ""
	Local cTxt2 := ""
	Local cTxt3 := "Composi��o dos valores:"
	Local cTxt4 := "Vl. Bruto	: "
	Local cTxt5 := "-IR			: "
	Local cTxt6 := "-PIS		: "
	Local cTxt7 := "-Cofins		: "
	Local cTxt8 := "-CSLL		: "
	Local cCNPJPict := PesqPict("SA1","A1_CGC")
	Local X     := 0
	Local nA    := 0
	Local nB    := 0
	Local i     := 0
	Local cCNPJEmpPrestador := ""

	For X:=1 to Len(aFiles1)	//-Boleto Itau
		If !(cDiret+aFiles1[X,1] $ cAnexos) .and. cBolNome $ cDiret+aFiles1[X,1] 
			cAnexos += cDiret+aFiles1[X,1] + "; "
		Endif
	Next X

	For X:=1 to Len(aFiles2)	//-Descritivo
		If !(cDiret+aFiles2[X,1] $ cAnexos) .and. cDescNome $ cDiret+aFiles2[X,1]
			cAnexos += cDiret+aFiles2[X,1] + "; "
		Endif
	Next X

	if lOnNFSe
		For X:=1 to Len(aFiles3)	//-NFSe
			If !(cDiret+aFiles3[X,1] $ cAnexos) .and. cNfseNome $ cDiret+aFiles3[X,1]
				cAnexos += cDiret+aFiles3[X,1] + "; "
			Endif
			// If !(cDirNFSe+aFiles3[X,1] $ cAnexos)
			// 	cAnexos += cDirNFSe+aFiles3[X,1] + "; "
			// Endif
		Next X
	endif

	cAnexos := iif(!Empty(cAnexos),Substr(cAnexos,1,Len(cAnexos)-2),"")

	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.T.)

	While !Eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		If aScan(aPedido , D2_PEDIDO) == 0
			aadd(aPedido , D2_PEDIDO)
		Endif
		dbSkip()
	Enddo

	dbSelectArea("SC5")
	dbSetOrder(1)
	For nA:=1 to Len(aPedido)

		dbSeek(xFilial("SC5")+aPedido[nA])
		If aScan(aPara , Alltrim(C5_ZZNFMAI)) == 0
			aadd(aPara , Alltrim(C5_ZZNFMAI))
		Endif

	Next

	For nB:=1 to Len(aPara)
		cPara += iif(nB>1,";","")+aPara[nB]
	Next

	cNomeCli := Alltrim(Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME"))
//cPara    := Alltrim(Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_ZZNFMAI"))

//If nQtdDoc == 1 .and. cTipCob == "B"
	If cTipCob == "B"
		cTxt1 := "Encaminhamos neste e-mail o Boleto Banc�rio e o Descritivo da Fatura referente a NFS-e n� "
//ElseIf nQtdDoc == 2 .and. cTipCob == "B"
		//cTxt1 := "Encaminhamos neste e-mail o Boleto Banc�rio referente a NFS-e n� "
//Comentado para n�o sair os dados bancarios
//Chamado Ticket#2020013110055825 - R�gis Ferreira Totvs IP 31/01/2020
//Elseif nQtdDoc == 1 .and. cTipCob <> "B"
		//cTxt1 := "Encaminhamos neste e-mail os dados para a Transfer�ncia Banc�ria e o Descritivo da Fatura referente a NFS-e n� "
	Else
		cTxt1 := "Encaminhamos neste e-mail o Descritivo da Fatura referente a NFS-e n� "
	Endif
//If (nQtdDoc == 1 .or. nQtdDoc == 2)
	//If nQtdDoc == 1
	//	cTxt2 := "* Descritivo referente a NFS-e "+Alltrim(SF2->F2_DOC)
	//Endif
	If cTipCob == "B"
		cTxt2 := "* Boleto Banc�rio no valor de R$ "+Alltrim(Transform(nValorTit,"@E 999,999,999.99"))
		//Comentado para n�o sair os dados bancarios
		//Chamado Ticket#2020013110055825 - R�gis Ferreira Totvs IP 31/01/2020
		//Else
		//cTxt2 := "* Dados para a Transfer�ncia Banc�ria : Banco "+cBcoTran+" Ag�ncia "+cAgTran+" Conta "+cCCTran+" ."
	Endif
//Else
	//cTxt2 := "* Descritivo referente a NFS-e "+Alltrim(SF2->F2_DOC)

	//Comentado para n�o sair os dados bancarios
	//Chamado Ticket#2020013110055825 - R�gis Ferreira Totvs IP 31/01/2020
	//If cTipCob <> "B"
	//cTxt2 += '<br />'
	//cTxt2 += "* Dados para a Transfer�ncia Banc�ria : Banco "+cBcoTran+" Ag�ncia "+cAgTran+" Conta "+cCCTran+" ."
	//Endif
//Endif

	cMsg += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
	cMsg += '<html xmlns:o="">'
	cMsg += '<head>'
	cMsg += '<title>Envio autom&aacute;tico de Documentos</title>'
	cMsg += '<meta content="text/html; charset=windows-1252" http-equiv="Content-Type" />'
	cMsg += '<meta content="MSHTML 6.00.6000.16850" name="GENERATOR" />'
	cMsg += '</head>'
	cMsg += '<body bgcolor="#ffffff">'
	cMsg += '<p class="MsoNormal" style="margin: 0cm 0cm 0pt">Prezado cliente, '+cNomeCli+' - CNPJ '+Transform(POSICIONE("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_CGC"),cCNPJPict)+' - C�digo Interno '+Alltrim(SF2->F2_CLIENTE)+'/'+AllTrim(SF2->F2_LOJA)+'<br />'
	cMsg += '<br />'
//cMsg += cTxt1
//cMsg += Alltrim(SF2->F2_DOC)+' com emiss�o em '+DtoC(SF2->F2_EMISSAO)+'.<br />'
//cMsg += '<br />'
//cMsg += 'A nota fiscal foi enviada anteriormente pelo site da Prefeitura de Garibaldi, '
//cMsg += 'atrav�s do e-mail: <a href="mailto:nfse@garibaldi.rs.gov.br">nfse@garibaldi.rs.gov.br</a>. '
//cMsg += '<br />'

	cLink := ""

	If Alltrim(SM0->M0_CODFIL) == '0400'

		If !Empty(SF2->F2_CHVNFE) .and. SF2->F2_SERIE <> '001'
			cMsg += 'Para visualizar a NOTA FISCAL emitida em '+ DtoC(SF2->F2_EMISSAO) + ' acesse o link abaixo: <br />'

			cLink += 'https://nfse.garibaldi.rs.gov.br/portal/consulta.jspx?nf='+Alltrim(SF2->F2_CHVNFE)

			cMsg += '<a href="'+cLink+'">'+cLink+'</a>'+'<br />'

			cMsg += '<br />'
			cMsg += 'Utilize a chave de acesso : '+Alltrim(SF2->F2_CHVNFE)
			cMsg += '<br />'

		Endif

	elseIf !Empty(SF2->F2_CODNFE)
		//cMsg += 'Para acessar a nota fiscal utilize o link '
		cMsg += 'Para visualizar a NOTA FISCAL emitida em '+ DtoC(SF2->F2_EMISSAO) + ' acesse o link abaixo: <br />'
		//cMsg += '<a href="https://nfse.garibaldi.rs.gov.br/portal/consulta.jspx?nf='+Alltrim(SF2->F2_CHVNFE)+'">nfse.garibaldi.rs.gov.br/portal/consulta.jspx?nf='+Alltrim(SF2->F2_CHVNFE)+'</a>'+'<br />'

		If Alltrim(SM0->M0_CODFIL) == '0100'
			cLink += 'http://www.indaiatuba.sp.gov.br/fazenda/rendas-mobiliarias/nfse/consulta/'

		elseIf Alltrim(SM0->M0_CODFIL) == '0101'
			cLink += 'https://nfse.recife.pe.gov.br/nfse.aspx?inscricao='+Alltrim(SM0->M0_INSCM)+'&nf='+Alltrim(Str(VAL(SF2->F2_DOC)))+'&cod='+StrTran(Alltrim(SF2->F2_CODNFE),"-","")

		elseIf Alltrim(SM0->M0_CODFIL) $ '0200|0600|0601'
			cLink += 'https://notacarioca.rio.gov.br/contribuinte/notaprint.aspx?ccm='+Alltrim(SM0->M0_INSCM)+'&nf='+Alltrim(Str(VAL(SF2->F2_DOC)))+'&cod='+StrTran(Alltrim(SF2->F2_CODNFE),"-","")

		elseIf Alltrim(SM0->M0_CODFIL) $ '050|00501|0502|0503'
			cLink += 'https://nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?nf='+Alltrim(Str(VAL(SF2->F2_DOC)))+'&inscricao='+Alltrim(SM0->M0_INSCM)+'&verificacao='+StrTran(Alltrim(SF2->F2_CODNFE),"-","")+'&returnurl=..%2fpublico%2fverificacao.aspx%3ftipo%3d0

		elseIf Alltrim(SM0->M0_CODFIL) $ '0800|0802|0604|0602'
			cLink += 'http://visualizar.ginfes.com.br/report/consultarNota?__report=nfs_ver4&cdVerificacao='+StrTran(Alltrim(SF2->F2_CODNFE),"-","")+'&numNota='+Alltrim(Str(VAL(SF2->F2_DOC)))+'&cnpjPrestador='+Alltrim(SM0->M0_CGC)

		elseIf Alltrim(SM0->M0_CODFIL) $ '0504|0603|0605'
			cCNPJEmpPrestador := Alltrim(SM0->M0_CGC)
			cLink += 'https://visualizar.isssbc.com.br/report/consultarNota?__report=nfs_sao_bernardo_campo_novo&cdVerificacao='+StrTran(Alltrim(SF2->F2_CODNFE),"-","")+'&numNota='+Alltrim(Str(VAL(SF2->F2_DOC)))+'&cnpjPrestador='+Transform(cCNPJEmpPrestador,"@R 99.999.999/9999-99")  
		endif

		cMsg += '<a href="'+cLink+'">'+cLink+'</a>'+'<br />'

		cMsg += '<br />'
		cMsg += 'Utilize a chave de acesso : '+Alltrim(SF2->F2_CODNFE)
		cMsg += '<br />'
	Endif
	cMsg += '<br />'
	If cTipCob == "B"
		cMsg += cTxt3+'<br />'
		for i := 1 to nParcela
			cMsg += ' '+'<br />'
			if nParcela > 1
				cMsg += '<b>Parcela: ' + Transform(i,"999")+' - Vencto: '+dtoc(dVenc[i])+'</b><br />'
			endif

			cMsg += '------------------------------------------------------'+'<br />'
			cMsg += cTxt4+Transform(nValBruto[i] ,"@E 999,999,999.99")+'<br />'
			cMsg += cTxt5+Transform(nValIRRF[i]  ,"@E 999,999,999.99")+'<br />'
			cMsg += cTxt6+Transform(nValPIS[i]   ,"@E 999,999,999.99")+'<br />'
			cMsg += cTxt7+Transform(nValCOFI[i]  ,"@E 999,999,999.99")+'<br />'
			cMsg += cTxt8+Transform(nValCSLL[i]  ,"@E 999,999,999.99")+'<br />'
			cMsg += '------------------------------------------------------'+'<br />'
			cMsg += 'Valor liquido a pagar: '+Transform(nValLiq[i]  ,"@E 999,999,999.99")+'<br />'
		next
	else
		cMsg += cTxt2+'<br />'
	endif
	cMsg += '<br />'
	cMsg += '<span style="color: red; text-decoration: underline;"> Qualquer diverg�ncia, nos informar dentro do prazo de 24hs, ap�s esse per�odo a mesma n�o poder� ser cancelada. '+if(cFilAnt=="0400","Limitado as 12:00 horas do pen�ltimo dia �til do m�s."," ")+' </span> <br />'
	cMsg += '<br />'
	cMsg += 'Por gentileza confirmar o recebimento. <br />'
	cMsg += '� disposi��o.<br />'
	cMsg += '<br />'
	cMsg += '<span style="font-size: 16px">'+cNomeFat+'<br /><br />'
	cMsg += Alltrim(SM0->M0_NOMECOM)+'<br />'
	cMsg += 'Tel: 55 '+Alltrim(SM0->M0_TEL)+'</span><br />'
	cMsg += '<br />'
	cMsg += 'E-mail: <a href="mailto:'+cEmailFat+'">'+cEmailFat+'</a><br />'
	cMsg += 'Site: <a href="http://www.eurofins.com.br/">www.eurofins.com.br</a><br />'
	cMsg += '<br />'
	cMsg += '<br />'
	cMsg += '<br />'
	cMsg += 'Envio Autom�tico de Documentos.<br />'
	cMsg += 'Protheus System - Version 12 By TOTVS Software S.A.</p>'
	if "TESTE" $ UPPER(getEnvServer())
		cMsg += '<span style="color: red; text-decoration: underline;"> <h1>EMAIL ENVIADO PELA BASE DE TESTE, DESCONSIDERAR</H1> </span> <br />'
	endif
	cMsg += '</body>'
	cMsg += '</html>'

	//cMsg += '<span style="font-size: 16px">Margarete C. Cisilotto - Faturamento<br />'
	// Fim

	// Alterado
	/*
	cMsg += 'Eurofins do Brasil An�lises de Alimentos Ltda.<br />'
	cMsg += 'Rod. Eng. Erm�nio de Oliveira Penteado Km 57,7 s/n<br />'
	cMsg += 'Pr�dio 1 - Condom�nio Industriale - CEP 13337-300<br />'
	cMsg += 'Bairro Tombadouro - Indaiatuba - SP<br />'
	cMsg += 'Tel: 55 (19) 2107-5500 Fax: 55 (19) 2107-5511</span><br />'

	cMsg += Capital(Alltrim(SM0->M0_NOMECOM)) + '<br />'
	cMsg += Capital(Alltrim(SM0->M0_ENDENT)) + '<br />'
	cMsg += Capital(Alltrim(SM0->M0_COMPENT)) + Iif(!Empty(SM0->M0_COMPENT)," - ", "") + "CEP " + SM0->M0_CEPENT + '<br />'
	cMsg += Capital(Alltrim(SM0->M0_BAIRENT)) + " - " + Capital(Alltrim(SM0->M0_CIDENT)) + " - " + Alltrim(SM0->M0_ESTENT) +'<br />'
	cMsg += 'Tel: 55 ' + Alltrim(SM0->M0_TEL) + " Fax: 55 " + Alltrim(SM0->M0_FAX) + '<br />'
	// Fim
	*/

	//���������������������������������������������������������������������Ŀ
	//� Possibilito que o usuario possa usar um endereco de email maior     �
	//� que o tamanho usado pelo campo cPara esta utilizando atualmente.    �
	//�����������������������������������������������������������������������
	cPara := cPara+Space(120)

	//���������������������������������������������������������������������Ŀ
	//� Criacao da Interface                                                �
	//�����������������������������������������������������������������������
	If lMostra
		@ 106,74 To 249,606 Dialog oDialog Title OemToAnsi("Envio de documentos por E-Mail")
		@ 0.5,0.5 To 3.5,33
		@ 01.3,05 Say OemToAnsi("Enviar para:") Size 34,8
		@ 01.1,10 Get cPara Size 130,10 Valid (!Empty(cPara) .And. at("@",cPara)>0 )
		@ 05.1,30 Button OemToAnsi("Confirma") Size 36,16 Action(Close(oDialog))
		Activate Dialog oDialog
	Endif
	cPara := Alltrim(cPara)

	While !lOk
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lOk
		If !lOk
			If MsgBox(OemtoAnsi("Falha na conex�o com o servidor SMTP. Tenta novamente?") , OemToAnsi("Envio de documentos por E-Mail") , "YESNO")
				Sleep(1000)
				Loop
			Endif
		Endif
	Enddo

	If lOk .and. lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MsgBox(OemtoAnsi("Falha na autentica��o do usu�rio.") , OemToAnsi("Envio de documentos por E-Mail") , "ALERT")
			DISCONNECT SMTP SERVER RESULT lOk
			If !lOk
				GET MAIL ERROR cErrorMsg
				MsgBox(OemtoAnsi("E-Mail n�O enviado ! C�digo do erro: "+cErrorMsg) , OemToAnsi("Envio de documentos por E-Mail") , "ALERT")
			EndIf
			Return .F.
		EndIf
	EndIf

	If lOk
		ConfirmMailRead(.T.)
		SEND MAIL FROM cAccount TO cPara CC cCopia SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexos RESULT lOk
	Endif

	If lOk
		If lMostra
			MsgBox(OemtoAnsi("E-Mail enviado com sucesso.") , OemToAnsi("Envio de documentos por E-Mail") , "INFO")
		Endif
		ConfirmMailRead(.F.)
	Else
		GET MAIL ERROR cErrorMsg
		MsgBox(OemtoAnsi("E-Mail n�o enviado ! C�digo do erro: "+cErrorMsg) , OemToAnsi("Envio de documentos por E-Mail") , "ALERT")
	Endif

	DISCONNECT SMTP SERVER RESULT lOk

	If !lOk
		GET MAIL ERROR cErrorMsg
		MsgBox(OemtoAnsi("Erro na desconex�o ! "+cErrorMsg) , OemToAnsi("Envio de documentos por E-Mail") , "ALERT")
	Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVIABOLDESCR �Autor  � Marcos Candido � Data �  11/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImprDescr()
	Local cItemPV := "01"                  // Item Master do Pedido de Venda
	Local nRegIte := 0                     // Registro Corrente do Pedido de VendaAlltrim(SF2->F2_DOC)
	//Local cArquivo := Alltrim(SM0->M0_CODFIL)+Alltrim(SF2->F2_DOC)+Alltrim(SF2->F2_SERIE)+"_DESCRITIVO"
	Local cNumNFSe	:= iif(Empty(SF2->F2_NFELETR),SF2->F2_DOC,SF2->F2_NFELETR)
	Local cArquivo := Alltrim(SM0->M0_CODFIL)+"_"+Alltrim(cNumNFSe)+iif(Empty(Alltrim(SF2->F2_SERIE)),"","_"+Alltrim(SF2->F2_SERIE))

	cArquivo := "DESCRITIVO_"+cPrefixo+"_"+cArquivo
	cDescNome:= cArquivo
	cNfseNome:= Replace(cArquivo,"DESCRITIVO","NFSE")

	Private oFont8
	Private oFont11c
	Private oFont10
	Private oFont14
	Private oFont16n
	Private oFont15
	Private oFont14n
	Private oFont24
	Private nLin := 3000

	oPrint:= FWMSPrinter():New(cArquivo,6,.T.,,.T.)
	oPrint:SetPortrait()
	oPrint:SetPaperSize(9)
	oPrint:SetMargin(30,70,60,60)  // nEsquerda, nSuperior, nDireita, nInferior

	// ----------------------------------------------
	// Define para salvar o PDF do Descritivo !!!
	// ----------------------------------------------
	oPrint:cPathPDF := cDirPDF
	oPrint:SetViewPDF(.F.)

	Private PixelX := oPrint:nLogPixelX()
	Private PixelY := oPrint:nLogPixelY()

	//Parametros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)
	oFont10D  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12D  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14D  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	lPriVez := .T.                         // Flag de Controle de Quebra de Pedido
	lRodape := .F.                         // Flag de Controle de Impressao do Rodape
	nTipPro := 4                           // Tamanho do Tipo do Codigo Inteligente do Produto
	cSimbP  := ""                          // Simbolo da Moeda Padrao
	cSingP  := ""                          // Descricao da Moeda Padrao no Singular
	cPlurP  := ""                          // Descricao da Moeda Padrao no Plural
	cSimbX  := ""                          // Simbolo da Moeda Utilizada no Pedido de Venda
	cSingX  := ""                          // Descricao da Moeda Utilizada no Singular
	cPlurX  := ""                          // Descricao da Moeda Utilizada no Plural
	nItens  := 0                           // Contador de Itens da Nota Fiscal Fatura
	nTotal  := 0                           // Valor Total da Nota Fiscal Fatura
	xC6_DESCRI := ""

	SB1->(dbSetOrder(1))                   // Produtos
	SA1->(dbSetOrder(1))                   // Clientes
	SC5->(dbSetOrder(1))                   // Cabecalho de Pedidos de Venda
	SC6->(dbSetOrder(1))                   // Itens de Pedidos de Venda
	SBR->(dbSetOrder(1))                   // Dados Basicos do Produto
	SZ1->(dbSetOrder(1))                   // Tipos de Amostras
	SZ2->(dbSetOrder(1))                   // Descritivos p/ Analises
	SZ3->(dbSetOrder(1))                   // Descricao das Amostras
	SZ6->(dbSetOrder(1))                   // Configuracao de Laudos
	SZ7->(dbSetOrder(1))                   // Resultados das Analises
	SF4->(dbSetOrder(1))                   // Tipos de Entrada/Saida
	SF2->(dbSetOrder(1))                   // Cabecalho de Notas Fiscais de Saida
	SD2->(dbSetOrder(3))                   // Itens de Notas Fiscais de Saida

	dbSelectArea("SF2")

	SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

	nItens  := 0                     // Contador de Itens Impressos
	nTotal  := 0                     // Valor Total da NFF
	nPagina := 0                     // Contador de Paginas
	aDet    := {}						// array para armazenamento das informacoes a serem impressas

	SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.))

	While SD2->(!Eof()) .And. SD2->D2_FILIAL == xFilial("SD2") .And.;
			(SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA) ==;
			(SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)

		SF4->(DbSeek(xFilial("SF4") + SD2->D2_TES, .F.))

		If SF4->(!Found()) .Or. SF4->F4_DUPLIC # "S"
			SD2->(DbSkip())
			Loop
		Endif

		xC6_DESCRI := ""
		cSimbP := Alltrim(GetMv("MV_SIMB1"))
		cSingP := Alltrim(GetMv("MV_MOEDA1"))
		cPlurP := Alltrim(GetMv("MV_MOEDAP1"))

		cSimbX := cSimbP
		cSingX := cSingP
		cPlurX := cPlurP

		SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))

		If SC5->C5_MOEDA > 1 .And. SC5->C5_MOEDA <= 6

			cSimbX := Alltrim(GetMv("MV_SIMB" + Str(SC5->C5_MOEDA, 1)))
			cSingX := Alltrim(GetMv("MV_MOEDA" + Str(SC5->C5_MOEDA, 1)))
			cPlurX := Alltrim(GetMv("MV_MOEDAP" + Str(SC5->C5_MOEDA, 1)))

		Endif

		SC6->(DbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV, .F.))

		xZ2_TIPPRO := Substr(SC6->C6_PRODUTO, 1, nTipPro)

		If nLin > 2700 .Or. lPriVez
			If !lPriVez
				oPrint:EndPage()
			Endif
			Cabecalho()             // Impressao do Cabecalho
			lPriVez := .F.
		Endif

		If SBR->(DbSeek(xFilial("SBR") + xZ2_TIPPRO, .F.))
			xBR_BASE    := xZ2_TIPPRO
			xBR_DESCPRD := Alltrim(SBR->BR_DESCPRD)
		Else
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO, .F.))
			xBR_BASE    := SC6->C6_PRODUTO
			xBR_DESCPRD := " "
		Endif

		If SZ2->(DbSeek(xFilial("SZ2") + xZ2_TIPPRO, .F.))
			If !Empty(SZ2->Z2_DESCFAT)
				xC6_DESCRI := SZ2->Z2_DESCFAT
			Endif
		Endif

		nRegIte := SC6->(Recno())

		xC6_ITEM    := SC6->C6_ITEM
		xC6_PRODUTO := SC6->C6_PRODUTO
		If Empty(xC6_DESCRI)
			xC6_DESCRI  := SC6->C6_DESCRI
		Endif

    /*
		If SC6->C6_ITEM # cItemPV

			SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM + cItemPV, .F.))
			If SC6->(!Found())
				SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM, .F.))
			Endif
		Endif
    */
		xC6_ZZCODAM := OemToAnsi(Alltrim(SC6->C6_ZZCODAM))
		xC6_XLOTE1 := OemToAnsi(Alltrim(SC6->C6_ZZLOT01))
		xC6_XLOTE2 := OemToAnsi(Alltrim(SC6->C6_ZZLOT02))
		xC6_XLOTE3 := OemToAnsi(Alltrim(SC6->C6_ZZLOT03))
		xC6_XLOTE4 := OemToAnsi(Alltrim(SC6->C6_ZZLOT04))

		SZ1->(DbSeek(xFilial("SZ1") + SC6->C6_ZZTIPO, .F.))

		SZ3->(DbSeek(xFilial("SZ3") + SC6->C6_ZZSDESC, .F.))

		SC6->(DbGoTo(nRegIte))

		nItens += 1
		nTotal += SC6->C6_VALOR
		// nTotal += SD2->D2_TOTAL

		If Alltrim(xC6_PRODUTO) == "AGRO"
			If SF2->F2_EST == "EX"
				xC6_DESCRI := "Agronomical Studies"
			Endif
			lAgro := .T.
		Else
			lAgro := .F.
		Endif

		cAux := Alltrim(SC5->C5_ZZOBS)//+iif(!Empty(Alltrim(SC5->C5_XINFMAP))," - "+Alltrim(SC5->C5_XINFMAP),"")

		aadd(aDet , {nItens 		, SC6->C6_ZZNROCE 	, xBR_BASE 		, SC6->C6_VALOR /*SD2->D2_TOTAL*/	, xC6_DESCRI ,;
					xBR_DESCPRD 	, SZ1->Z1_DESCP 	, xC6_ZZCODAM	, xC6_XLOTE1						, xC6_XLOTE2 ,;
					xC6_XLOTE3		, xC6_XLOTE4		, lAgro			, Alltrim(SC6->C6_PEDCLI)/*cAux*/})

		SD2->(DbSkip())

	Enddo

	Detalhe()                  // Impressao do Item de Detalhe

	If nLin > 2700
		RodaFat()               // Impressao do Rodape
	Endif

	lRodape := .T.

	If !lPriVez
		If nLin > 2700
			oPrint:EndPage()
			Cabecalho()
		Endif

		TotalFat()                    // Impressao do Total da Fatura

		If lRodape
			RodaFat()
		Endif
	Endif

	//�������������������������������Ŀ
	//�  Visualiza antes de imprimir  �
	//���������������������������������
	oPrint:Preview()

	//�������������������������������Ŀ
	//�  Salva em JPEG                �
	//���������������������������������
	//oPrint:SaveAllAsJpeg(cDiret+"DESCRITIVO_"+ALLTRIM(SF2->F2_DOC),1120,1640,180) //  LARGURA X ALTURA X DPI

	//�������������������������������������������������������������Ŀ
	//�  Faz copia do diretorio local para o diretorio do servidor  �
	//���������������������������������������������������������������
	CpyT2S(cDirPDF+cArquivo+"*.PDF", cDiret)

	//������������������������������������������������������Ŀ
	//� Varre o diret�rio e procura pelas p�ginas gravadas.  �
	//��������������������������������������������������������
	aFiles2 := Directory(cDiret+cArquivo+"*.PDF" )	//-Descritivo

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Cabecalho �Autor  �Microsiga           � Data �  02/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Cabecalho()

	oPrint:StartPage()   // Inicia uma nova p�gina
	Local cNumNFSe	:= iif(Empty(SF2->F2_NFELETR),SF2->F2_DOC,SF2->F2_NFELETR)

	nPagina++

	SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

	If SF2->F2_EST <> "EX"              // Portugues
		cDataExt := OemToansi(U_DataExte(SF2->F2_EMISSAO, 2, "P"))
		cDataSol := OemToansi("Formul�rio de solicita��o de an�lise datado de : " + Dtoc(SC5->C5_ZZDATAP))
		cDataRec := OemToansi("Data de Recebimento da(s) amostra(s)               : " + Dtoc(SC5->C5_ZZDATAR))
		cNumeFat := OemToansi("Fatura : " + Alltrim(cNumNFSe))
		cPagiNro := OemToansi("P�gina : " + Alltrim(Str(nPagina,3)))
		cCabeca1 := OemToansi("Posi��o  No. da    Descri��o do Item                               Pre�o Total  ")
		cCabeca2 := OemToansi("         Amostra                                                     (" + cSimbX + ")")
		//                     . 999   99-X99999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999.999.999,99
		cCodiCli := OemToansi("N� do Cliente : " + Alltrim(SA1->A1_COD) + "/" + Alltrim(SA1->A1_LOJA))
	Else                   				// Ingles
		cDataExt := OemToansi(U_DataExte(SF2->F2_EMISSAO, 2, "E"))
		cDataSol := OemToansi("Date of Order             : " + Dtoc(SC5->C5_ZZDATAP))
		cDataRec := OemToansi("Sample reception(s) : " + Dtoc(SC5->C5_ZZDATAR))
		cNumeFat := OemToansi("Invoice : " + Alltrim(cNumNFSe))
		cPagiNro := OemToansi("Page : " + Alltrim(Str(nPagina,3)))
		cCabeca1 := OemToansi("Position  Sample   Item Description                                Total Price  ")
		cCabeca2 := OemToansi("          Number                                                     (" + cSimbX + ")")
		//                     . 999   99-X99999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999.999.999,99
		cCodiCli := OemToansi("Client Number : " + Alltrim(SA1->A1_COD) + "/" + Alltrim(SA1->A1_LOJA))
	Endif

	cNomeCli := OemToansi(Alltrim(SA1->A1_NOME))
	cEndeCli := OemToansi(Alltrim(SA1->A1_END) + "   " + Alltrim(SA1->A1_BAIRRO))
	cCidaCli := OemToansi(Transform(SA1->A1_CEP, "@R 99999-999") + "   " + Alltrim(SA1->A1_MUN) + " - " + Alltrim(SA1->A1_EST))
//cEntcli  := OemToansi(Alltrim(SA1->A1_NOME)) + " - " + "CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")

	If !Empty(SC5->C5_ZZCON02)
		cContCli := OemToansi("A/C " + Alltrim(SC5->C5_ZZCON02))
	Elseif !Empty(SC5->C5_ZZCON01)
		cContCli := OemToansi("A/C " + Alltrim(SC5->C5_ZZCON01))
	Else
		cContCli := ""
	Endif

	oPrint:SayBitMap(0100,100,cLogoEmp,370,110)	// LOGO DA EMPRESA

	oPrint:Say(0250,0100,cNomeCli,oFont14D) //oPrint:Say(0250,0100,cEntcli,oFont14D)
	oPrint:Say(0290,0100,cEndeCli,oFont14D)
	oPrint:Say(0330,0100,cCidaCli,oFont14D)
	oPrint:Say(0370,0100,cContCli,oFont14D)
	oPrint:Say(0410,1300,cCodiCli,oFont14D)

	oPrint:Say(0450,1300,cDataExt,oFont12D)

	oPrint:Say(0490,0100,cNumeFat,oFont14D)
	oPrint:Say(0490,1300,cPagiNro,oFont12D)

	oPrint:Say(0550,0100,cDataSol,oFont12D)
	oPrint:Say(0600,0100,cDataRec,oFont12D)

	oPrint:Line(0650,0100,0650,2200)

	If SF2->F2_EST <> "EX"              // Portugues
		oPrint:Say(0680,0200,"Posi��o",oFont12D)
		oPrint:Say(0680,0500,"N� da",oFont12D)
		oPrint:Say(0680,0970,"Descri��o do Item",oFont12D)
		oPrint:Say(0680,1900,"Pre�o Total",oFont12D)

		oPrint:Say(0720,0500,"Amostra",oFont12D)
		oPrint:Say(0720,1975,"(" + cSimbX + ")",oFont12D)
	Else
		oPrint:Say(0680,0200,"Position",oFont12D)
		oPrint:Say(0680,0500,"Sample",oFont12D)
		oPrint:Say(0680,0970,"Item Description",oFont12D)
		oPrint:Say(0680,1900,"Total Price",oFont12D)

		oPrint:Say(0720,0500,"Number",oFont12D)
		oPrint:Say(0720,1975,"(" + cSimbX + ")",oFont12D)
	Endif

	oPrint:Line(0770,0100,0770,2200)
	nLin := 810

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Detalhe  �Autor  �Microsiga           � Data �  02/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Detalhe

	Local nLoop := 0
	Local nX    := 0
	Local nD    := 0

	aSort(aDet,,, {|x,y| x[2] < y[2]} )
	nTamDesc := 45

	For nD:=1 to Len(aDet)

		oPrint:Say(nLin,230,Strzero(nD,3),oFont12D)
		oPrint:Say(nLin,0500,aDet[nD][2],oFont12D)
		oPrint:Say(nLin,0970,Alltrim(aDet[nD][3])+" "+Substr(aDet[nD][5],1,38),oFont12D)
		oPrint:Say(nLin,1940,Transform(aDet[nD][4], "@E 999,999,999.99"),oFont12D)

		If nLin >= 2500
			RodaFat()
			Cabecalho()
		Endif
		If !Empty(Substr(aDet[nD][5], 39,nTamDesc))
			nLin+=40
			oPrint:Say(nLin,0970,OemToansi(Substr(aDet[nD][5],39,nTamDesc)),oFont12D)
		Endif

		If nLin >= 2500
			RodaFat()
			Cabecalho()
		Endif
		If !Empty(Substr(aDet[nD][5], 84, nTamDesc))
			nLin+=40
			oPrint:Say(nLin,0970,OemToansi(Substr(aDet[nD][5],84,nTamDesc)),oFont12D)
		Endif

		If nLin >= 2500
			RodaFat()
			Cabecalho()
		Endif
		If !Empty(Substr(aDet[nD][5], 129, nTamDesc))
			nLin+=40
			oPrint:Say(nLin,0970,OemToansi(Substr(aDet[nD][5],129,nTamDesc)),oFont12D)
		Endif

		nLin+=40

		nMemCount := MlCount( aDet[nD][8], 45 )
		If !Empty(nMemCount)
			For nLoop := 1 To nMemCount
				cLinha := MemoLine( aDet[nD][8], 45, nLoop )
				If nLin >= 2500
					RodaFat()
					Cabecalho()
				Endif
				If !Empty(Alltrim(cLinha))
					oPrint:Say(nLin,0970,cLinha,oFont12D)
					nLin+=40
				Endif
			Next nLoop
		EndIf

		If nLin >= 2500
			RodaFat()
			Cabecalho()
		Endif

		If !Empty(aDet[nD][6])
			If SF2->F2_EST <> "EX"          // Portugues
				oPrint:Say(nLin,0970,OemToansi(Substr("C�digo : " + aDet[nD][6],1,45)),oFont12D)
			Else             				// Ingles
				oPrint:Say(nLin,0970,OemToansi(Substr("Code : " + aDet[nD][6],1,45)),oFont12D)
			Endif
			nLin+=40
		Endif

		If nLin >= 2500
			RodaFat()
			Cabecalho()
		Endif

		If SF2->F2_EST <> "EX"			// Portugues
			If aDet[nD][13]
				oPrint:Say(nLin,0970,OemToansi("Servi�o de Consultoria Estudo Agron�mico"),oFont12D)
			Else
				//oPrint:Say(nLin,0970,OemToansi(Substr("An�lise da amostra " + aDet[nD][7], 1, 45)),oFont12D)
				//Retirado o texto "An�lise da amostra" conforme chamado Ticket#2018032010032942
				oPrint:Say(nLin,0970,OemToansi(Substr(" " + aDet[nD][7], 1, 45)),oFont12D)
			Endif
		Else              				// Ingles
			If aDet[nD][13]
				oPrint:Say(nLin,0970,OemToansi("Consulting Services in Agronomical Studies"),oFont12D)
			Else
				//Retirado o texto "An�lise da amostra" conforme chamado Ticket#2018032010032942
				//oPrint:Say(nLin,0970,OemToansi(Substr("Analysis of sample " + aDet[nD][7], 1, 45)),oFont12D)
				oPrint:Say(nLin,0970,OemToansi(Substr(" " + aDet[nD][7], 1, 45)),oFont12D)
			Endif
		Endif

		nLin+=40

		nPos := At(":",aDet[nD][14])
		If nPos > 0
			cDescri1 := Substr(aDet[nD][14],nPos+2)
		Else
			cDescri1 := aDet[nD][14]
		Endif
		nLinha1  := MLCount(cDescri1,nTamDesc)

		If !Empty(MemoLine(cDescri1,nTamDesc,1))
			oPrint:Say(nLin,0970,MemoLine(cDescri1,nTamDesc,1),oFont12D)
			nLin+=40
		Endif

		For nX := 2 To nLinha1
			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif
			If !Empty(Memoline(cDescri1,nTamDesc,nX))
				oPrint:Say(nLin,0970,MemoLine(cDescri1,nTamDesc,nX),oFont12D)
				nLin+=40
			Endif
		Next

		If nLin >= 2500
			RodaFat()
			Cabecalho()
		Endif

		If !Empty(aDet[nD][9])

			oPrint:Say(nLin,0970,Substr(aDet[nD][9],1,45),oFont12D)
			nLin+=40

			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif

			If !Empty(Substr(aDet[nD][9], 46, 45))
				oPrint:Say(nLin,0970,Substr(aDet[nD][9], 46, 45),oFont12D)
				nLin+=40
			Endif

			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif

		Endif

		If !Empty(aDet[nD][10])

			oPrint:Say(nLin,0970,Substr(aDet[nD][10], 1, 45),oFont12D)
			nLin+=40

			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif

			If !Empty(Substr(aDet[nD][10], 46, 45))
				oPrint:Say(nLin,0970,Substr(aDet[nD][10], 46, 45),oFont12D)
				nLin+=40
			Endif

			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif

		Endif

		If !Empty(aDet[nD][11])

			oPrint:Say(nLin,0970,Substr(aDet[nD][11], 1, 45),oFont12D)
			nLin+=40

			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif

			If !Empty(Substr(aDet[nD][11], 46, 45))
				oPrint:Say(nLin,0970,Substr(aDet[nD][11], 46, 45),oFont12D)
				nLin+=40
			Endif

			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif

		Endif

		If !Empty(aDet[nD][12])

			oPrint:Say(nLin,0970,Substr(aDet[nD][12], 1, 45),oFont12D)
			nLin+=40

			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif

			If !Empty(Substr(aDet[nD][12], 46, 45))
				oPrint:Say(nLin,0970,Substr(aDet[nD][12], 46, 45),oFont12D)
				nLin+=40
			Endif

			If nLin >= 2500
				RodaFat()
				Cabecalho()
			Endif

		Endif

		If !Empty(aDet[nD][14])

			oPrint:Say(nLin,0970,"Num. seu P.C.: "+aDet[nD][14],oFont12D)
			nLin+=40

		Endif

		nLin+=40

		If nLin >= 2500
			RodaFat()
			Cabecalho()
		Endif

	Next

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TotalFat �Autor  �Microsiga           � Data �  02/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TotalFat

	oPrint:Line(nLin,100,nLin,2200)
	nLin+=50

	oPrint:Say(nLin,1200,OemToansi("Total (" + cSimbX + ")"),oFont12D)
	oPrint:Say(nLin,1940,Transform(nTotal, "@E 999,999,999.99"),oFont12D)
	nLin+=70

	If SC5->C5_MOEDA # 1                   // Se a Moeda Nao For a Corrente
		If SF2->F2_EST <> "EX"  // Portugues
			oPrint:Say(nLin,0100,OemToansi("Obs.: Os valores em " + cPlurX +;
				" ser�o convertidos para " + cPlurP + " no dia anterior ao faturamento."),oFont12D)
		Else            			// Ingles
			oPrint:Say(nLin,0100,OemToansi("Obs.: The values in " + cPlurX +;
				" will be converted to " + cPlurP + " the day before invoicing. "),oFont12D)
        /*
        if cFilAnt = '0100'
	        nLin+=50
	        oPrint:Say(nLin,0100,OemToansi("Beneficiary: EUROFINS DO BRASIL AN�LISES DE ALIMENTOS LTDA."),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Account with: Commerzbank AG - Frankfurt"),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Swift Code: COBADEFF"),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Accont nr: 400871809000 EUR"),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("In favor of Banco Bradesco S.A."),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Swift Code: BBDEBRSPSPO"),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("IBAN: BR4560746948003160001446053C1"),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Branch number: 0316-6"),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Account number: 144.605-3"),oFont12D)
        Endif*/
        //Acrescentado os dados para vendas externas conforme chamado 2019071510043726
        //R�gis Ferreira 01/08/2019
    	nLin+=50
        if left(cFilAnt,2) = '01'
	        oPrint:Say(nLin,0100,OemToansi("Beneficiary Bank: Ita� Unibanco S.A."),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Swift Code: ITAUBRSP"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("For further credit to: EUROFINS DO BRASIL ANALISES DE ALIMENTOS LTDA"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Branch number: 3128"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Account number: 02090-0"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Cod IBAN: BR68 6070 1190 0312 8000 0020 900C 1"),oFont12D)
        elseif left(cFilAnt,2) = '03'
        	oPrint:Say(nLin,0100,OemToansi("Beneficiary Bank: Ita� Unibanco S.A."),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Swift Code: ITAUBRSP"),oFont12D)
	        nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("For further credit to: EUROFINS AGROSCIENCE S ERVICES LTDA"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Branch number: 00.41"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Account number: 26888-9"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Cod IBAN: BR72 6070 1190 0004 1000 0268 889C 1"),oFont12D)
        elseif left(cFilAnt,2) = '04'
        	oPrint:Say(nLin,0100,OemToansi("Beneficiary Bank: Ita� Unibanco S.A."),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Swift Code: ITAUBRSP"),oFont12D)
	        nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("For further credit to: LABORAT�RIO ALAC LTDA"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Branch number: 0574"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Account number: 46639-7"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Cod IBAN: BR70 6070 1190 0057 4000 0466 397C 1"),oFont12D)
        elseif left(cFilAnt,2) = '05'
        	oPrint:Say(nLin,0100,OemToansi("Beneficiary Bank: Ita� Unibanco S.A."),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Swift Code: ITAUBRSP"),oFont12D)
	        nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("For further credit to: ANALYTICAL TECH SERV ANALITICOS E AMBIENTAIS LTDA"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Branch number: 0183"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Account number: 27102-2"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Cod IBAN: BR20 6070 1190 0018 3000 0271 022C 1"),oFont12D)
        elseif left(cFilAnt,2) = '06'
        	oPrint:Say(nLin,0100,OemToansi("Beneficiary Bank: Ita� Unibanco S.A."),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Swift Code: ITAUBRSP"),oFont12D)
	        nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("For further credit to: INTEGRATED  P EXP C S L LTDA"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Branch number: 0458"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Account number: 50023-8"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Cod IBAN: BR25 6070 1190 0045 8000 0500 238C 1"),oFont12D)
        elseif left(cFilAnt,2) = '08'
        	oPrint:Say(nLin,0100,OemToansi("Beneficiary Bank: Ita� Unibanco S.A."),oFont12D)
	        nLin+=25
	        oPrint:Say(nLin,0100,OemToansi("Swift Code: ITAUBRSP"),oFont12D)
	        nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("For further credit to: LABORAT�RIO S�O LUCAS LTDA"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Branch number: 3128"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Account number: 12828-1"),oFont12D)
        	nLin+=25
        	oPrint:Say(nLin,0100,OemToansi("Cod IBAN: BR97 6070 1190 0312 8000 0128 281C 1"),oFont12D)
        endif
	Endif
	nLin+=40
Endif

Return (.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RodaFat  �Autor  �Microsiga           � Data �  02/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RodaFat()

	//R�gis Ferreira - 11/03/2024 - A pedido do Cesar Garcia e Fernanda Careli, a mensagem abaixo ir� sair para algumas filiais especificas
	if cFilAnt $ "0600/0602/0604"
		oPrint:Say(2730,0110, "Prezados, nosso descritivo passou por melhorias! Em seu novo formato o documento apresenta as informa��es detalhadas das an�lises realizadas." ,oFont12D)
		oPrint:Say(2760,0110, "Em caso de d�vidas, entrar em contato pelo e-mail SH-Fat-Ambiental-RC@eurofinslatam.com" ,oFont12D)
	endif

	oPrint:Line(2790,0100,2790,2200)
	// Alterado
	/*
	oPrint:Say(2820,0110,"Eurofins do Brasil An�lise de Alimentos Ltda - Rodovia Engenheiro Erm�nio O. Penteado s/n Km 57,7" ,oFont12D)
	oPrint:Say(2860,0110,"Bairro Tombadouro - Condom�nio Industriale - Indaiatuba/SP",oFont12D)
	oPrint:Say(2900,0110,"CEP 13337-300 Tel:19 2107-5500 - www.eurofins.com.br",oFont12D)
	*/
	oPrint:Say(2820,0110, Capital(Alltrim(SM0->M0_NOMECOM)) + " - " + Alltrim(SM0->M0_ACTRAB) + " - " + "CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + " - " + Capital(Alltrim(SM0->M0_ENDENT)) ,oFont12D)
	oPrint:Say(2860,0110, Capital(Alltrim(SM0->M0_BAIRENT)) + " - " + Capital(Alltrim(SM0->M0_CIDENT)) + " - " + Alltrim(SM0->M0_ESTENT),oFont12D)
	oPrint:Say(2900,0110, "CEP " + SM0->M0_CEPENT + " Tel: " + Alltrim(SM0->M0_TEL) + " - www.eurofins.com.br",oFont12D)

	oPrint:EndPage()

Return

/*/
	�������������������������������������������������������������������������������
	�������������������������������������������������������������������������������
	���������������������������������������������������������������������������Ŀ��
	���Fun��o	 � CarregaTRB � Autor � Marcos Candido        � Data � 07/09/05 ���
	���������������������������������������������������������������������������Ĵ��
	���Descri��o � Insere registros no arquivo temporario  			            ���
	���������������������������������������������������������������������������Ĵ��
	��� Uso		 �     						                					���
	����������������������������������������������������������������������������ٱ�
	�������������������������������������������������������������������������������
	�������������������������������������������������������������������������������
/*/
Static Function CarregaTRB

	Local _nX := 0

	Local cQuery := ""
	Local cTpCob := IIF(nTpPgto==1,"B","D")

	cQuery += "SELECT * , SF2.R_E_C_N_O_ RECSF2 FROM "+RetSQlName("SF2")+" SF2 "
// Alterado
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA"// AND A1_ZZTPCOB = '" + cTpCob + "' "
//Fim
	cQuery += "WHERE "
	cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
	cQuery += "SF2.F2_EMISSAO >= '"+dtos(mv_par01)+"' AND SF2.F2_EMISSAO <= '"+dtos(mv_par02)+"' AND "
	cQuery += "SF2.F2_CLIENTE >= '"+mv_par03+"' AND SF2.F2_LOJA >= '"+mv_par04+"' AND "
	cQuery += "SF2.F2_CLIENTE <= '"+mv_par05+"' AND SF2.F2_LOJA <= '"+mv_par06+"' AND "
// Alterado
//cQuery += "SF2.F2_SERIE = '"+Space(3)+"' AND SF2.F2_TIPO = 'N' AND "
//cQuery += "SF2.F2_SERIE IN ('E','T') AND SF2.F2_TIPO = 'N' AND "
	if !Empty(cFilSerie)
		cQuery += "SF2.F2_SERIE IN ("
		aSeries := StrToKarr( cFilSerie, "/" )
		If Len(aSeries) > 0
			For _nX := 1 To Len(aSeries)
				If _nX > 1
					cQuery += ", "
				Endif
				cQuery += "'" + aSeries[_nX] + "'"
			Next _nX
		Endif
		cQuery += " ) AND "
	else
		cQuery += "SF2.F2_SERIE = '' AND "
	endif
	cQuery += "SF2.F2_TIPO = 'N' AND "
	cQuery += " (SF2.F2_ZZEMAIL = 'N' or SF2.F2_ZZEMAIL = ' ') AND "
	cQuery += "SF2.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY F2_FILIAL,F2_DOC,F2_SERIE"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSF2",.T.,.T.)
	aEval(SF2->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSF2",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSF2")
	dbGoTop()

	While !Eof()
		// Alterado
//	If Posicione("SA1",1,xFilial("SA1")+WSF2->(F2_CLIENTE+F2_LOJA),"A1_ZZTPCOB") == cTpCob
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		Replace	DOC			With	WSF2->F2_DOC
		Replace	SERIE		With	WSF2->F2_SERIE
		Replace	CLIENTE		With	WSF2->F2_CLIENTE
		Replace	LOJA		With 	WSF2->F2_LOJA
		Replace	VALOR		With 	WSF2->F2_VALBRUT
		Replace	EMISSAO		With 	WSF2->F2_EMISSAO
		Replace	CHAVE		With	WSF2->RECSF2
		MsUnlock()
		//	Endif

		dbSelectArea("WSF2")
		dbSkip()

	EndDo

	dbCloseArea("WSF2")

Return

/*/
	�������������������������������������������������������������������������������
	�������������������������������������������������������������������������������
	���������������������������������������������������������������������������Ŀ��
	���Fun��o	 � Inverter   � Autor � Marcos Candido        � Data � 07/09/05 ���
	���������������������������������������������������������������������������Ĵ��
	���Descri��o � Marca / Desmarca titulos			 	         			    ���
	���������������������������������������������������������������������������Ĵ��
	��� Uso		 �         										                ���
	����������������������������������������������������������������������������ٱ�
	�������������������������������������������������������������������������������
	�������������������������������������������������������������������������������
/*/
Static Function Inverter(cMarca,oMark)

	Local nReg := TRB->(Recno())

	dbSelectArea("TRB")
	dbGoTop()

	While !Eof()
		RecLock("TRB",.F.)
		If TRB->OK == cMarca
			Replace OK With Space(02)
		Else
			Replace OK With cMarca
		EndIf
		MsUnlock()
		DbSkip()
	EndDo
	DbSelectArea("TRB")
	DbGoTo(nReg)

Return(NIL)
