#INCLUDE "ctbr610.ch"
#Include "PROTHEUS.Ch"

Static _oCtbr610

Static lIsRedStor := FindFunction("IsRedStor") .and. IsRedStor() //Used to check if the Red Storn Concept used in russia is active in the system | Usada para verificar se o Conceito Red Storn utilizado na Russia esta ativo no sistema | Se usa para verificar si el concepto de Red Storn utilizado en Rusia esta activo en el sistema


/*/{Protheus.doc} EuroR610
Relatorio padr�o CTBR610 - demonstracao de resultado detalhado
@type function
@version 12.1.33
@author adm_tla8
@since 3/20/2023
/*/
User Function EuroR610()

	Private dFinalA
	Private dFinal
	Private nomeprog	:= "EuroR610"
	Private dPeriodo0

	Private aTamCodPla := TAMSX3("CTS_CODPLA")
	Private aTamDescCg := TAMSX3("CTS_DESCCG")
	Private aTamContag := TAMSX3("CTS_CONTAG")
	Private aTamConta  := TAMSX3("CT1_CONTA")
	Private aTamCusto  := TAMSX3("CT3_CUSTO")
	Private aTamItem   := TAMSX3("CT3_CUSTO")
	Private aTamCLVL   := TAMSX3("CT3_CUSTO")
	Private aTamEnt    := TAMSX3("CV0_CODIGO")
	Private aTamVal    := TAMSX3("CT2_VALOR")
	Private aTamDscCVQ := TAMSX3("CVQ_DESCRI")
	Private aTamItCVQ  := TAMSX3("CVQ_DESCIT")
	Private aTamDesCta := TAMSX3("CT1_DESC01")
	Private cCalend    := ""
	Private cRetSX5SL  := ""
	Private aSelFil    := {}

	If TRepInUse()
		CTBR610R4()
	Else
		MsgAlert( OemToAnsi(STR0030) )//"Relatorio dispon�vel apenas em TReport."
	EndIf

	If Findfunction("TempQuad")
		//Apaga tabelas temporarias do banco de dados criadas no CTBA115.PRW
		TempQuad()
	Endif

	If _oCtbr610 <> Nil
		_oCtbr610:Delete()
		_oCtbr610 := Nil
	Endif

Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} CTBR610R4
Demostrativo de balancos patrimoniais
@type function
@version 12.1.33
@author adm_tla8
@since 3/20/2023
/*/
Static Function CTBR610R4()

	Private lImpSeg2	:= .F.
	Private lImpSeg3	:= .F.
	Private aQuadros	:= {}
	Private CPERG 		:= "CTR610"

	Pergunte( CPERG, .T. )

    // faz a valida��o do livro
	if ! VdSetOfBook( mv_par02 , .T. )
		return .F.
	endif

	lImpSeg2  := Iif(mv_par19 == 1,.T.,.F.) // Imprime Detalhe da Visao ?
	lImpSeg3  := Iif(mv_par20 == 1,.T.,.F.) // Imprime Quadro contabil ?


	If lImpSeg3
		aQuadros := Ctb115SelQd()
	Endif

	oReport := ReportDef()

	If VALTYPE( oReport ) == "O"
		oReport :PrintDialog()
	EndIf

	oReport := nil

Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} ReportDef
Esta funcao tem como objetivo definir as secoes, celulas, totalizadores do relatorio que poderao ser configurados pelo relatorio.
@type function
@version 12.1.33
@author adm_tla8
@since 3/20/2023
/*/
Static Function ReportDef()

	Local aSetOfBook := CTBSetOf(mv_par02)
	Local aCtbMoeda  := {}
	Local cDescMoeda := ""
	// local aArea      := GetArea()
	Local CREPORT    := "CTBR610"
	Local CTITULO    := OemToAnsi(STR0001) // DEMONSTRACAO DE RESULTADOS
	Local CDESC      := OemToAnsi(STR0014) + ; //"Este programa ir� imprimir a Demonstra��o de Resultados, "
	OemToAnsi(STR0015) //"de acordo com os par�metros informados pelo usu�rio."
	Local aTamDesc   := TAMSX3("CTS_DESCCG")
	Local cDsc
	Local nQtEnt     := If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4)
	Local nX

	aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
	cDescMoeda 	:= AllTrim(aCtbMoeda[3])

	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	Endif

//  Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano Gerencial -> montagem especifica para impressao)
	If !ct040Valid(mv_par02)
		Return
	EndIf

//Filtra Filiais
	If Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
	EndIf

	If Empty(aSelFil)
		FwAlertError("Favor selecionar ao menos uma filial para processamento.","Filial")
		return(.F.)
	EndIf

	lMovPeriodo	:= (mv_par13 == 1)

	If mv_par09 == 1												/// SE DEVE CONSIDERAR TODO O CALENDARIO
		CTG->(DbSeek(xFilial() + mv_par01))
		If Empty(mv_par08)
			While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
				dFinal	:= CTG->CTG_DTFIM
				CTG->(DbSkip())
			EndDo
		Else
			dFinal	:= mv_par08
		EndIf
		dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
		If Empty ( dFinalA )
			If MONTH(dFinal) == 2
				If Day(dFinal) > 28 .and. Day(dFinal) == 29
					dFinalA := Ctod(Left( STRTRAN ( Dtoc(dFinal) , "29" , "28" ), 6) + Str(Year(dFinal) - 1, 4))
				EndIf
			EndIf
		EndIf

		cCalend := mv_par01

		mv_par01    := dFinal

		If lMovPeriodo
			dPeriodo0 	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 2, 4)) + 1
		EndIf
	Else															/// SE DEVE CONSIDERAR O PERIODO CONTABIL
		If Empty(mv_par08)
			MsgInfo(STR0008,STR0009)//"� necess�rio informar a data de refer�ncia !"#"Parametro Considera igual a Periodo."
			Return
		Endif

		dFinal		:= mv_par08
		dFinalA		:= CTOD("  /  /  ")
		dbSelectArea("CTG")
		dbSetOrder(1)
		MsSeek(xFilial("CTG")+mv_par01,.T.)
		While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
			If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
				dFinalA		:= CTG->CTG_DTINI
				If lMovPeriodo
					nMes			:= Month(dFinalA)
					nAno			:= Year(dFinalA)
					dPeriodo0	:= CtoD(	StrZero(Day(dFinalA),2)							+ "/" +;
						StrZero( If(nMes==1,12		,nMes-1	),2 )	+ "/" +;
						StrZero( If(nMes==1,nAno-1,nAno		),4 ) )
					dFinalA		:= dFinalA - 1
				EndIf
				Exit
			Endif
			CTG->(DbSkip())
		EndDo

		If Empty(dFinalA)
			MsgInfo(STR0010,STR0011)//"Data fora do calend�rio !"#"Data de refer�ncia."
			Return
		Endif
	Endif

	CTITULO		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], CTITULO)		// Titulo definido SetOfBook
	If Valtype(mv_par16)=="N" .And. (mv_par16 == 1)
		cTitulo := CTBNomeVis( aSetOfBook[5] )
	EndIf

	oReport	:= TReport():New( CREPORT,CTITULO,CPERG, { |oReport| ReportPrint( oReport ) }, CDESC )
	oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )
	oReport:ParamReadOnly()

	IF GETNEWPAR("MV_CTBPOFF",.T.)
		oReport:SetEdit(.F.)
	ENDIF


// Criacao da secao utilizada pelo relatorio
//
// TRSection():New
// ExpO1 : Objeto TReport que a secao pertence
// ExpC2 : Descricao da se�ao
// ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela
//         sera considerada como principal para a se��o.
// ExpA4 : Array com as Ordens do relat�rio
// ExpL5 : Carrega campos do SX3 como celulas
//         Default : False
// ExpL6 : Carrega ordens do Sindex
//         Default : False
//

	oSection1  := TRSection():New( oReport, STR0012, {"cArqTmp"},, .F., .F. )        //"Contas/Saldos"

	TRCell():New( oSection1, "ATIVO"	,"",STR0013+cDescMoeda+")"	/*Titulo*/,/*Picture*/,aTamDesc[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"(Em "
	TRCell():New( oSection1, "SALDOATU"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+2	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	TRCell():New( oSection1, "SALDOANT"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+2	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	oSection1:SetTotalInLine(.F.)

	oSection2  := TRSection():New( oReport, STR0016, {"cArqTmp2"},, .F., .F. ) // Detalhe da Visao

	TRCell():New( oSection2, "DESCCG"	,"cArqTmp2",  STR0017,/*Picture*/,aTamDesccg[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"(Em "
	TRCell():New( oSection2, "CONTAG"	,"cArqTmp2",  STR0018,/*Picture*/,aTamContag[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"(Em "
	TRCell():New( oSection2, "SLDATU"	,"cArqTmp2",STR0019,/*Picture*/,aTamVal[1]+2	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	TRCell():New( oSection2, "SLDANT"	,"cArqTmp2",STR0020,/*Picture*/,aTamVal[1]+2	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")


	oSection3  := TRSection():New( oReport, STR0021, {"cArqTmp2"},, .F., .F. ) //Itens do Detalhe

	dbSelectArea("CT0")
	dbSetOrder(1)
	TRCell():New( oSection3, "CONTA"	,"cArqTmp2", STR0022,/*Picture*/,aTamConta[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
	TRCell():New( oSection3, "DESCCTA"	,"cArqTmp2", 'DESC. CONTA',/*Picture*/,aTamDesCta[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
	TRCell():New( oSection3, "CUSTO"	,"cArqTmp2", STR0023,/*Picture*/,aTamCusto[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	// TRCell():New( oSection3, "CLVL"		,"cArqTmp2", STR0025,/*Picture*/,aTamCLVL[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	cDsc := IIf(dbSeek(xFilial("CT0")+"05"), Alltrim(CT0->CT0_DSCRES), "05")
	TRCell():New( oSection3, "ENT05"	,"cArqTmp2", cDsc,/*Picture*/,aTamEnt[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	cDsc := IIf(dbSeek(xFilial("CT0")+"06"), Alltrim(CT0->CT0_DSCRES), "06")
	TRCell():New( oSection3, "ENT06"	,"cArqTmp2", ,/*Picture*/,aTamEnt[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	cDsc := IIf(dbSeek(xFilial("CT0")+"07"), Alltrim(CT0->CT0_DSCRES), "07")
	TRCell():New( oSection3, "ENT07"	,"cArqTmp2", ,/*Picture*/,aTamEnt[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	cDsc := IIf(dbSeek(xFilial("CT0")+"08"), Alltrim(CT0->CT0_DSCRES), "08")
	TRCell():New( oSection3, "ENT08"	,"cArqTmp2", ,/*Picture*/,aTamEnt[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	cDsc := IIf(dbSeek(xFilial("CT0")+"09"), Alltrim(CT0->CT0_DSCRES), "09")
	TRCell():New( oSection3, "ENT09"	,"cArqTmp2", ,/*Picture*/,aTamEnt[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	TRCell():New( oSection3, "SALDOATU"	,"cArqTmp2", STR0019,/*Picture*/,aTamVal[1]+2	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	TRCell():New( oSection3, "SALDOANT"	,"cArqTmp2", STR0020,/*Picture*/,aTamVal[1]+2	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")

	For nX := 5 to 9
		If nQtEnt<nX
			oSection3:Cell("ENT"+StrZero(nX,2)):Disable()
		EndIf
	Next nX


	oSection4  := TRSection():New( oReport, STR0026, {"cArqQuadro"},, .F., .F. )  // Quadros Contabeis

	TRCell():New( oSection4, "DESCRICAO"	,"", "Quadro Contabil"	/*Titulo*/,/*Picture*/,aTamItCVQ[1]+(aTamVal[1]*2)+6/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",,"CENTER")


	oSection5  := TRSection():New( oReport, STR0027, {"cArqQuadro"},, .F., .F. ) //Itens do Quadro Contabil

	// TRCell():New( oSection5, "ITEM"		,"", STR0017,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"LEFT",,"LEFT")
	TRCell():New( oSection5, "SALDOATU"	,"", STR0019,/*Picture*/,aTamVal[1]+2	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	TRCell():New( oSection5, "SALDOANT"	,"", STR0020,/*Picture*/,aTamVal[1]+2	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")

	// RestArea(aArea)

Return(oReport)

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} ReportPrint
Imprime o relatorio definido pelo usuario de acordo com as secoes/celulas criadas na funcao ReportDef definida acima.
Nesta funcao deve ser criada a query das secoes se SQL ou definido o relacionamento e filtros das tabelas em CodeBase.
@type function
@version 12.1.33
@author adm_tla8
@since 3/20/2023
@param oReport, object, param_description
/*/
Static Function ReportPrint( oReport )

	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2)
	Local oSection3 	:= oReport:Section(3)
	Local oSection4 	:= oReport:Section(4)
	Local oSection5 	:= oReport:Section(5)

	Local aSetOfBook	:= CTBSetOf(mv_par02)
	Local aCtbMoeda	:= {}
	// Local lin 			:= 3001
	Local cArqTmp
	Local cArqTmp2
	Local cArqQuadro
	Local cTpValor		:= GetMV("MV_TPVALOR")
	Local cPicture
	Local cDescMoeda
	// Local lFirstPage	:= .T.
	// Local nTraco		:= 0
	// Local nSaldo
	// Local nTamLin		:= 2350
	// Local aPosCol		:= { 1740, 2045 }
	// Local nPosCol		:= 0
	Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
	Local lImpAntLP		:= Iif(mv_par04 == 1,.T.,.F.)
	Local cArqTrm		:= ""
	Local lVlrZerado	:= Iif(mv_par12==1,.T.,.F.)
	Local lMovPeriodo
	Local aTamVal		:= TAMSX3("CT2_VALOR")
	Local cMoedaDesc	:= iif( empty( mv_par14 ) , mv_par03 , mv_par14 )
	Local lPeriodoAnt 	:= (mv_par06 == 1)
	// Local cQuery		:= ""
	Local cContag	 	:= ""
	Local cSepara1		:= ""
	Local cSepara2		:= ""
	// Local cSepara3		:= ""
	// Local cSepara4		:= ""
	Local cMascara1		:= IIf (Empty(aSetOfBook[2]), GetMv("MV_MASCARA"), RetMasCtb(aSetOfBook[2],@cSepara1) )
	Local cMascara2		:= IIf (Empty(aSetOfBook[6]), GetMv("MV_MASCCUS"), RetMasCtb(aSetOfBook[6],@cSepara2) )
	// Local cMascara3		:= IIf (Empty(aSetOfBook[7]), "", RetMasCtb(aSetOfBook[7],@cSepara3) )
	// Local cMascara4		:= IIf (Empty(aSetOfBook[8]), "", RetMasCtb(aSetOfBook[8],@cSepara4) )
	Local nX            := 0
	Local aParamCVQ		:= Array(11)
	// Local Desc1			:= ""
	Local lConsSld		:= If(mv_par17 == 1,.T.,.F.)
	Local aTpSaldo		:= {}
	Local lCharSinal	:= .F.

	cRetSX5SL := mv_par18

	If !Empty(mv_par18) .AND. lConsSld
		aTpSaldo := STRTOKARR( cRetSX5SL , ";")
	Else
		Aadd(aTpSaldo, mv_par15)
		cRetSX5SL := mv_par15
	Endif

	aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	Endif

	cDescMoeda 	:= AllTrim(aCtbMoeda[3])
	nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
	cPicture 	:= aSetOfBook[4]

	If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
		cPicture := ""
	Endif

	lMovPeriodo	:= (mv_par13 == 1)

// Monta Arquivo Temporario para Impressao
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
		CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dFinalA+1, dFinal;
		, "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), "";
		, Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
		, "", Repl("Z", Len(CTH->CTH_CLVL)), mv_par03, cRetSX5SL, aSetOfBook, Space(2);
		, Space(20), Repl("Z", 20), Space(30),,,,, mv_par04 == 1, mv_par05;
		, ,lVlrZerado,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,lMovPeriodo,aSelFil,,.T.,lConsSld) };
		,STR0006, STR0001) //"Criando Arquivo Temporario..."


	If lImpSeg2
		MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTB610Tmp(oMeter,oText,oDlg,lEnd,@cArqTmp2,mv_par03,dFinal,dFinalA, aTpSaldo,;
			lImpAntLP, mv_par05,CTBSetOf(mv_par02),lMovPeriodo,lVlrZerado)},;
			STR0028,; //"Criando Arquivo Tempor�rio..."
		STR0001)  //"Emissao do Fluxo de Contas"
	Endif


	dbSelectArea("cArqTmp")
	dbGoTop()

	oReport:SetPageNumber(mv_par07) //mv_par07 - Pagina Inicial

	oSection1:Cell("SALDOATU" ):SetTitle(Dtoc(dFinal))
	oSection2:Cell("SLDATU" ):SetTitle(Dtoc(dFinal))
	oSection3:Cell("SALDOATU" ):SetTitle(Dtoc(dFinal))
	oSection5:Cell("SALDOATU" ):SetTitle(Dtoc(dFinal))

	If lPeriodoAnt
		oSection1:Cell("SALDOANT" ):SetTitle(Dtoc(dFinalA))
		oSection2:Cell("SLDANT" ):SetTitle(Dtoc(dFinalA))
		oSection3:Cell("SALDOANT" ):SetTitle(Dtoc(dFinalA))
		oSection5:Cell("SALDOANT" ):SetTitle(Dtoc(dFinalA))
	Else
		oSection1:Cell("SALDOANT" ):Disable()
		oSection2:Cell("SLDANT" ):Disable()
		oSection3:Cell("SALDOANT" ):Disable()
		oSection5:Cell("SALDOANT" ):Disable()
	EndIf

	oSection1:Cell("ATIVO"):SetBlock( { || cArqTmp->DESCCTA } )

	If lIsRedStor
		If cArqTmp->IDENTIFI < "5"
			oSection1:Cell("SALDOATU" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU),,,aTamVal[1],nDecimais,.T.,cPicture,;
				cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.,,lCharSinal ) } )
			If lPeriodoAnt
				oSection1:Cell("SALDOANT" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
					cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.,,lCharSinal ) } )
			EndIf
		EndIf

	Else
		oSection1:Cell("SALDOATU" ):SetBlock( { || If(cArqTmp->IDENTIFI < "5", ValorCTB( If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU),,,aTamVal[1],nDecimais,.T.,cPicture,;
			cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ), "") } )

		If lPeriodoAnt
			oSection1:Cell("SALDOANT" ):SetBlock( { || If(cArqTmp->IDENTIFI < "5", ValorCTB( If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
				cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ), "") } )
		EndIf
	Endif


	If lPeriodoAnt
		oSection2:Cell("SLDANT" ):SetBlock( { || ValorCTB( If(lMovPeriodo,(cArqTmp2->SLDATU-cArqTmp2->SLDANT),cArqTmp2->SLDANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
			cArqTmp2->NORMAL,cArqTmp2->CONTA,,,cTpValor,,,.F.,,lCharSinal ) } )

		//	oSection3:Cell("SALDOANT" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp2->SALDOANT,cArqTmp2->SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
			//														 cArqTmp2->NORMAL,cArqTmp2->CONTA,,,cTpValor,,,.F. ) } )
	EndIf

	oSection3:Cell("SALDOANT" ):SetBlock( { || ValorCTB( cArqTmp2->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture,;
		cArqTmp2->NORMAL,cArqTmp2->CONTA,,,cTpValor,,,.F.,,lCharSinal ) } )


	oSection2:Cell("SLDATU" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp2->(SLDATU-SLDANT),cArqTmp2->SLDATU),,,aTamVal[1],nDecimais,.T.,cPicture,;
		cArqTmp2->NORMAL,,,,,,.T.,.F.,,lCharSinal ) } )

	oSection3:Cell("SALDOATU" ):SetBlock( { || ValorCTB( cArqTmp2->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,;
		cArqTmp2->NORMAL,,,,,,.T.,.F.,,lCharSinal ) } )


	oSection3:Cell("CONTA"):SetBlock( { || EntidadeCTB(cArqTmp2->CONTA,0,0,aTamConta[1],.F.,cMascara1,cSepara1,,,,,.F.) } )
	oSection3:Cell("DESCCTA"):SetBlock( { || cArqTmp2->DESCCTA } )
	oSection3:Cell("CUSTO"):SetBlock( { || EntidadeCTB(cArqTmp2->CUSTO,0,0,aTamCusto[1],.F.,cMascara2,cSepara2,,,,,.F.) } )
	// oSection3:Cell("ITEM"):SetBlock( { || EntidadeCTB(cArqTmp2->ITEM,0,0,aTamItem[1],.F.,cMascara3,cSepara3,,,,,.F.) } )
	// oSection3:Cell("CLVL"):SetBlock( { || EntidadeCTB(cArqTmp2->CLVL,0,0,aTamCLVL[1],.F.,cMascara4,cSepara4,,,,,.F.) } )
	oSection3:Cell("ENT05"):SetBlock( { || EntidadeCTB(cArqTmp2->ENT05,0,0,aTamEnt[1],.F.,"","",,,,,.F.) } )
	oSection3:Cell("ENT06"):SetBlock( { || EntidadeCTB(cArqTmp2->ENT06,0,0,aTamEnt[1],.F.,"","",,,,,.F.) } )
	oSection3:Cell("ENT07"):SetBlock( { || EntidadeCTB(cArqTmp2->ENT07,0,0,aTamEnt[1],.F.,"","",,,,,.F.) } )
	oSection3:Cell("ENT08"):SetBlock( { || EntidadeCTB(cArqTmp2->ENT08,0,0,aTamEnt[1],.F.,"","",,,,,.F.) } )
	oSection3:Cell("ENT09"):SetBlock( { || EntidadeCTB(cArqTmp2->ENT09,0,0,aTamEnt[1],.F.,"","",,,,,.F.) } )

	oSection4:Cell("DESCRICAO"):SetBlock({ || GetAdvFVal("CVQ","CVQ_DESCRI",xFilial("CVQ")+aQuadros[nX],1 ) } )
	// oSection5:Cell("ITEM"):SetBlock({ || (cArqQuadro)->DESCRICAO } )
	oSection5:Cell("SALDOANT" ):SetBlock( { || ValorCTB((cArqQuadro)->SALDOANT,,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,.T./*lPrintZero*/,.F.) })
	oSection5:Cell("SALDOATU" ):SetBlock( { || ValorCTB((cArqQuadro)->SALDOATU,,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,.T./*lPrintZero*/,.F.) })


	oSection1:Init()
	While M->(!Eof())
		oSection1:PrintLine()
		dbSkip()
	EndDo
	oSection1:Finish()

	If lImpSeg2   // Imprime Detalhe - DRE
		oReport:EndPage()
		dbSelectArea("cArqTmp2")
		dbGoTop()

		While cArqTmp2->(!Eof())
			oSection2:Init()
			oSection2:PrintLine()
			oSection2:Finish()

			cContag := CONTAG

			oSection3:Init()
			While cContag == CONTAG

				oSection3:PrintLine()
				dbSkip()
			EndDo
			oSection3:Finish()
			oReport:SkipLine(2)

		EndDo
		dbCloseArea()

		If Select("cArqTmp2") == 0
			FErase(cArqTmp+GetDBExtension())
			FErase(cArqTmp+OrdBagExt())
		EndIF

	Endif

	If lImpSeg3  // Imprime Quadros Contabeis
		oReport:EndPage()
		For nX := 1 To Len(aQuadros)

			aParamCVQ[01] := cCalend
			aParamCVQ[02] := mv_par08
			aParamCVQ[03] := lPeriodoAnt
			aParamCVQ[04] := lImpAntLP
			aParamCVQ[05] := mv_par05
			aParamCVQ[06] := mv_par03
			aParamCVQ[07] := mv_par15
			aParamCVQ[08] := lConsSld
			aParamCVQ[09] := cRetSX5SL
			aParamCVQ[10] := dFinalA
			aParamCVQ[11] := dFinal

			MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBGERQDO(aQuadros[nX],aParamCVQ,@cArqQuadro,oMeter,oText,oDlg,aSetOfBook,@lEnd) };
				,STR0029,STR0026 ) //"Criando Arquivo Temporario..."


			dbSelectArea(cArqQuadro)
			dbGoTop()
			oReport:SkipLine(4)
			oSection4:Init()

			oSection4:PrintLine()

			oSection4:Finish()

			oSection5:Init()
			While (cArqQuadro)->(!Eof())

				oSection5:Printline()

				dbSkip()

			EndDo
			oSection5:Finish()
		Next

	Endif

	If lImpTrmAux
		cArqTRM 	:= mv_par11
		aVariaveis  := {}

		// Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
		SX1->( dbSeek("CTR610"+"01") )
		SX1->( dbSeek( padr( "CTR610" , Len( X1_GRUPO ) , ' ' ) + "01" ) )
		While SX1->X1_GRUPO == padr( "CTR610" , Len( SX1->X1_GRUPO ) , ' ' )
			AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
			SX1->( dbSkip() )
		End

		If !File(cArqTRM)
			aSavSet:=__SetSets()
			cArqTRM := CFGX024(cArqTRM,STR0007) // "Respons�veis..."
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
		Endif

		If cArqTRM#NIL
			ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
		Endif

	Endif

	DbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()

Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} Ctb610Tmp
description
@type function
@version 12.1.33
@author adm_tla8
@since 3/20/2023
@param oMeter, object, objeto do oMeter
@param oText, object, objeto do oText
@param oDlg, object, objeto do oDlg
@param lEnd, logical, a��o do codeblock
@param cArqTmp2, character, arquivo temporario
@param cMoeda, character, moeda
@param dDataAtu, date, data atual
@param dDataAnt, date, data anterior
@param aTpSaldo, array, tipo de saldo
@param lImpAntLP, logical, Imprime Ant. LP
@param dDataLP, date, data dos lucros e perda
@param aSetOfBook, array, param_description
@param lMovPeriodo, logical, mostra movimento periodo
@param lVlrZerado, logical, imprimie valor zerado

/*/
Static Function Ctb610Tmp(oMeter,oText,oDlg,lEnd,cArqTmp2,cMoeda,dDataAtu,;
		dDataAnt,aTpSaldo,lImpAntLP,dDataLP,aSetOfBook,lMovPeriodo,lVlrZerado)

	Local aCtbMoeda	:= {}
	Local aSaveArea := GetArea()
	Local aCampos
	Local cChave
	Local cQuery
	Local aSaldoAtu		:= {}
	Local aSaldoAnt		:= {}
	Local nSldTotAnt	:= 0
	Local nSldTotAtu	:= 0
	Local nSaldoAnt		:= 0
	Local nSalodAtu		:= 0
	Local nMovPerAnt	:= 0
	Local cContag		:= ""
	Local cNormal		:= ""
	Local nX

	Local nQtEnt		:= If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4)
	Local aEnt

	aCampos :={	{ "CODPLA"		, "C", aTamCodPla[1], 0 },;
		{ "DESCCG"   	, "C", aTamConta[1] , 0 },;
		{ "CONTAG"   	, "C", aTamConta[1] , 0 },;
		{ "ORDEM"   	, "C", aTamConta[1] , 0 },;
		{ "CONTA"   	, "C", aTamConta[1] , 0 },;
		{ "DESCCTA"		, "C", aTamDesCta[1], 0 },;
		{ "CUSTO"		, "C", aTamCusto[1], 0 },;
		{ "ENT05"		, "C", aTamEnt[1]	, 0 },;
		{ "ENT06"		, "C", aTamEnt[1]	, 0 },;
		{ "ENT07"		, "C", aTamEnt[1]	, 0 },;
		{ "ENT08"		, "C", aTamEnt[1]	, 0 },;
		{ "ENT09"		, "C", aTamEnt[1]	, 0 },;
		{ "NORMAL"		, "C", 1	, 0 },;
		{ "SALDOANT"	, "N", aTamVal[1]+2	, nDecimais},;
		{ "SALDOATU"	, "N", aTamVal[1]+2	, nDecimais},;
		{ "SLDATU"		, "N", aTamVal[1]+2	, nDecimais},;
		{ "SLDANT"		, "N", aTamVal[1]+2	, nDecimais}}

	If _oCtbr610 <> Nil
		_oCtbr610:Delete()
		_oCtbr610 := Nil
	Endif

	_oCtbr610 := FWTemporaryTable():New( "cArqTmp2" )
	_oCtbr610:SetFields(aCampos)
	_oCtbr610:AddIndex("1", {"CONTAG","CONTA","CUSTO"})

//------------------
//Cria��o da tabela temporaria
//------------------
	_oCtbr610:Create()

	dbSelectArea("cArqTmp2")

	cQuery := " SELECT CTS_CODPLA, CTS_DESCCG, CTS_CONTAG, CTS_FORMUL, "
	cQuery += " COALESCE(CT1_CONTA,'') CT1_CONTA, COALESCE(CT1_NORMAL,'') CT1_NORMAL, "
	cQuery += " COALESCE(CTT_CUSTO,'') CTT_CUSTO, COALESCE(CTT_NORMAL,'') CTT_NORMAL, "
	cQuery += " COALESCE(CTD_ITEM,'')  CTD_ITEM,  COALESCE(CTD_NORMAL,'') CTD_NORMAL, "
	cQuery += " COALESCE(CTH_CLVL,'')  CTH_CLVL,  COALESCE(CTH_NORMAL,'') CTH_NORMAL, "
	For nX := 5 to 9
		If nX <= nQtEnt
			cQuery += " COALESCE(CV0"+StrZero(nX,2)+".CV0_CODIGO,'') ENT"+StrZero(nX,2)+",  COALESCE(CV0"+StrZero(nX,2)+".CV0_NORMAL,'') NORMAL"+StrZero(nX,2)+", "
		Else
			cQuery += " '' ENT"+StrZero(nX,2)+",  '' NORMAL"+StrZero(nX,2)+", "
		EndIf
	Next nX
	cQuery += " CTS_NOME "
	cQuery += " , COALESCE(CT1_DESC01,'') CT1_DESC01 "
	cQuery += "FROM "+RetSqlName("CTS")+" CTS "
	cQuery += " LEFT JOIN "+RetSqlName("CT1")+" CT1 ON CT1.CT1_FILIAL='"+xFilial("CT1")+"' AND CT1.CT1_CONTA BETWEEN CTS_CT1INI AND CTS_CT1FIM AND CT1.D_E_L_E_T_='' "
	cQuery += " LEFT JOIN "+RetSqlName("CTT")+" CTT ON CTT.CTT_FILIAL='"+xFilial("CTT")+"' AND CTT.CTT_CUSTO BETWEEN CTS_CTTINI AND CTS_CTTFIM AND CTT.D_E_L_E_T_='' "
	cQuery += " LEFT JOIN "+RetSqlName("CTD")+" CTD ON CTD.CTD_FILIAL='"+xFilial("CTD")+"' AND CTD.CTD_ITEM BETWEEN CTS_CTDINI AND CTS_CTDFIM AND CTD.D_E_L_E_T_='' "
	cQuery += " LEFT JOIN "+RetSqlName("CTH")+" CTH ON CTH.CTH_FILIAL='"+xFilial("CTH")+"' AND CTH.CTH_CLVL BETWEEN CTS_CTHINI AND CTS_CTHFIM AND CTH.D_E_L_E_T_='' "
	For nX := 5 to nQtEnt
		cQuery += " LEFT JOIN "+RetSqlName("CT0")+" CT0"+StrZero(nX,2)+" ON CT0"+StrZero(nX,2)+".CT0_FILIAL='"+xFilial("CT0")+"' AND CT0"+StrZero(nX,2)+".CT0_ID = '"+StrZero(nX,2)+"' AND CT0"+StrZero(nX,2)+".D_E_L_E_T_='' "
		cQuery += " LEFT JOIN "+RetSqlName("CV0")+" CV0"+StrZero(nX,2)+" ON CV0"+StrZero(nX,2)+".CV0_FILIAL='"+xFilial("CV0")+"' AND CV0"+StrZero(nX,2)+".CV0_PLANO = CT0"+StrZero(nX,2)+".CT0_ENTIDA AND CV0"+StrZero(nX,2)+".CV0_CODIGO BETWEEN CTS_E"+StrZero(nX,2)+"INI AND CTS_E"+StrZero(nX,2)+"FIM AND CV0"+StrZero(nX,2)+".D_E_L_E_T_='' "
	Next nX
	cQuery += " WHERE CTS_CODPLA = '" + aSetOfBook[5] + "' AND CTS_CT1INI <> '' AND CTS_CLASSE = '2' AND CTS.D_E_L_E_T_='' "
	cQuery += " ORDER BY CTS_CONTAG, CT1_CONTA, CTT_CUSTO, CTD_ITEM, CTH_CLVL "
	For nX := 5 to 9
		cQuery += ", ENT"+StrZero(nX,2)
	Next nX

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TMP',.T.,.F.)

	dbSelectArea("TMP")

	dbGotop()

	Do While !Eof()

		If cContag != TMP->CTS_CONTAG
			dbSelectArea("cArqTmp")
			dbSetOrder(1)

			MsSeek(TMP->CTS_CONTAG,.T.)

			dbSelectArea("TMP")

			nSldTotAnt := cArqTmp->SALDOANT
			nSldTotAtu := cArqTmp->SALDOATU

			cContag := TMP->CTS_CONTAG
		EndIf

		If !Empty(TMP->CT1_NORMAL)
			cNormal := TMP->CT1_NORMAL
		ElseIf	!Empty(TMP->CTT_NORMAL)
			cNormal := TMP->CTT_NORMAL
		ElseIf	!Empty(TMP->CTD_NORMAL)
			cNormal := TMP->CTD_NORMAL
		ElseIf	!Empty(TMP->CTH_NORMAL)
			cNormal := TMP->CTH_NORMAL
		ElseIf	!Empty(TMP->NORMAL05)
			cNormal := TMP->NORMAL05
		ElseIf	!Empty(TMP->NORMAL06)
			cNormal := TMP->NORMAL06
		ElseIf	!Empty(TMP->NORMAL07)
			cNormal := TMP->NORMAL07
		ElseIf	!Empty(TMP->NORMAL08)
			cNormal := TMP->NORMAL08
		ElseIf	!Empty(TMP->NORMAL09)
			cNormal := TMP->NORMAL09
		EndIf

		nSaldoAtu := 0
		nSaldoAnt := 0

		For nX := 1 To Len(aTpSaldo)

			If Empty(TMP->CTS_FORMUL)
				If !Empty(TMP->ENT09)
					aEnt := {TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, TMP->CTH_CLVL, TMP->ENT05, TMP->ENT06, TMP->ENT07, TMP->ENT08, TMP->ENT09}
					aSaldoAtu	:= CtbSldCubo(aEnt,aEnt,dDataAnt+1,dDataAtu,cMoeda,aTpSaldo[nX],aSelFil)
					aSaldoAnt	:= CtbSldCubo(aEnt,aEnt,Ctod("//"),dDataAnt,cMoeda,aTpSaldo[nX],aSelFil)
				ElseIf !Empty(TMP->ENT08)
					aEnt := {TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, TMP->CTH_CLVL, TMP->ENT05, TMP->ENT06, TMP->ENT07, TMP->ENT08}
					aSaldoAtu	:= CtbSldCubo(aEnt,aEnt,dDataAnt+1,dDataAtu,cMoeda,aTpSaldo[nX],aSelFil)
					aSaldoAnt	:= CtbSldCubo(aEnt,aEnt,Ctod("//"),dDataAnt,cMoeda,aTpSaldo[nX],aSelFil)
				ElseIf !Empty(TMP->ENT07)
					aEnt := {TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, TMP->CTH_CLVL, TMP->ENT05, TMP->ENT06, TMP->ENT07}
					aSaldoAtu	:= CtbSldCubo(aEnt,aEnt,dDataAnt+1,dDataAtu,cMoeda,aTpSaldo[nX],aSelFil)
					aSaldoAnt	:= CtbSldCubo(aEnt,aEnt,Ctod("//"),dDataAnt,cMoeda,aTpSaldo[nX],aSelFil)
				ElseIf !Empty(TMP->ENT06)
					aEnt := {TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, TMP->CTH_CLVL, TMP->ENT05, TMP->ENT06}
					aSaldoAtu	:= CtbSldCubo(aEnt,aEnt,dDataAnt+1,dDataAtu,cMoeda,aTpSaldo[nX],aSelFil)
					aSaldoAnt	:= CtbSldCubo(aEnt,aEnt,Ctod("//"),dDataAnt,cMoeda,aTpSaldo[nX],aSelFil)
				ElseIf !Empty(TMP->ENT05)
					aEnt := {TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, TMP->CTH_CLVL, TMP->ENT05}
					aSaldoAtu	:= CtbSldCubo(aEnt,aEnt,dDataAnt+1,dDataAtu,cMoeda,aTpSaldo[nX],aSelFil)
					aSaldoAnt	:= CtbSldCubo(aEnt,aEnt,Ctod("//"),dDataAnt,cMoeda,aTpSaldo[nX],aSelFil)
				ElseIf !Empty(TMP->CTH_CLVL)

					aSaldoAtu	:= SaldoCTIFil(TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, TMP->CTH_CLVL, dDataAtu, cMoeda, aTpSaldo[nX], , lImpAntLP, ;
						dDataLP, aSelFil)
					aSaldoAnt	:= SaldoCTIFil(TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, TMP->CTH_CLVL, dDataAnt, cMoeda, aTpSaldo[nX], , lImpAntLP, ;
						dDataLP, aSelFil)

				ElseIf !Empty(TMP->CTD_ITEM)

					aSaldoAtu	:= SaldoCT4Fil(TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, dDataAtu, cMoeda, aTpSaldo[nX], , lImpAntLP, dDataLP, aSelFil)
					aSaldoAnt	:= SaldoCT4Fil(TMP->CT1_CONTA, TMP->CTT_CUSTO, TMP->CTD_ITEM, dDataAnt, cMoeda, aTpSaldo[nX], , lImpAntLP, dDataLP, aSelFil)

				ElseIf !Empty(TMP->CTT_CUSTO)
					aSaldoAtu	:= SaldoCT3Fil(TMP->CT1_CONTA, TMP->CTT_CUSTO, dDataAtu, cMoeda, aTpSaldo[nX], , lImpAntLP, dDataLP, aSelFil)
					aSaldoAnt	:= SaldoCT3Fil(TMP->CT1_CONTA, TMP->CTT_CUSTO, dDataAnt, cMoeda, aTpSaldo[nX], , lImpAntLP, dDataLP, aSelFil)
				Else
					aSaldoAtu	:= SaldoCT7Fil(TMP->CT1_CONTA, dDataAtu, cMoeda, aTpSaldo[nX], , lImpAntLP, dDataLP, aSelFil)
					aSaldoAnt	:= SaldoCT7Fil(TMP->CT1_CONTA, dDataAnt, cMoeda, aTpSaldo[nX], , lImpAntLP, dDataLP, aSelFil)
				Endif
			Else
				bBlock := ErrorBlock( { |e| ChecErro(e) } )
				BEGIN SEQUENCE
					xResult := &(TMP->CTS_FORMUL)
					RECOVER
					xResult := {}
				END SEQUENCE
				ErrorBlock(bBlock)
				aSaldo := IIF(ValType(xResult) == "A",xResult,{})
			EndIf

			If lMovPeriodo
				nSaldoAnt += aSaldoAnt[3]-aSaldoAnt[2]
				nSaldoAtu += aSaldoAtu[3]-aSaldoAtu[2]
			Else
				nSaldoAnt += aSaldoAnt[1]
				nSaldoAtu += aSaldoAtu[1]
			Endif

		Next

		If lVlrZerado .Or. Ascan(aSaldoAnt, {|x| Abs(x) > 0}) > 0 .Or. Ascan(aSaldoAtu, {|x| Abs(x) > 0}) > 0
			RecLock("cArqTmp2",.T.)
			Replace CODPLA		With TMP->CTS_CODPLA
			Replace DESCCG		With TMP->CTS_DESCCG
			Replace CONTAG		With TMP->CTS_CONTAG
			Replace CONTA		With TMP->CT1_CONTA
			Replace DESCCTA		With TMP->CT1_DESC01
			Replace CUSTO		With TMP->CTT_CUSTO
			// Replace ITEM		With TMP->CTD_ITEM
			// Replace CLVL		With TMP->CTH_CLVL
			Replace ENT05		With TMP->ENT05
			Replace ENT06		With TMP->ENT06
			Replace ENT07		With TMP->ENT07
			Replace ENT08		With TMP->ENT08
			Replace ENT09		With TMP->ENT09
			Replace NORMAL		With cNormal
			Replace SALDOATU	With nSaldoAtu
			Replace SALDOANT	With nSaldoAnt
			Replace SLDATU		With nSldTotAtu
			Replace SLDANT		With nSldTotAnt
			MsUnlock()
		EndIf

		dbSelectArea("TMP")
		dbSkip()
	EndDo

	dbCloseArea()

Return cArqTmp2

