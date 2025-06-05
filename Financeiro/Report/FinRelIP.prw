#include "totvs.ch"
#include "topconn.ch"
#include "Dbstruct.ch"

/*/{Protheus.doc} FinRelIP
Relatório Invoices Recebidas Financeiro

@type 		function
@author 	Victor Freidinger
@since 		05/03/2020
@return		nil,nulo
@see        FatRelIP
/*/
User Function FinRelIP()

	Private lPerg	:= .F.
	Private oReport	:= Nil
	Private cTitulo	:= "Relatório - Invoices Recebidas Financeiro"
	Private aCampos	:= {}

	oReport:= TReport():new("FinRelIP - "+DTOS(dDataBase), cTitulo, { || fPerg() } , { || ProcRel() }, cTitulo)
	oReport:SetLandscape()
	oReport:SetDevice(4)
	oReport:SetTitle(cTitulo)
	oReport:PrintDialog()

Return Nil

//*******************************************************
static function fPerg()

	Local aParamBox 	:= {}
	local aColigadas	:= {}
	
	aAdd( aColigadas , "1=Sim")
	aAdd( aColigadas , "2=Nao")
	aAdd( aColigadas , "3=Todas")

	aAdd(aParamBox,{1,"Filial De"		   ,space(tamsx3("E2_FILIAL")[1]),"",""	,""	,""	,40,.F.})	          //MV_PAR01
	aAdd(aParamBox,{1,"Filial Ate"		   ,space(tamsx3("E2_FILIAL")[1]),"",""	,""	,""	,40,.T.})	          //MV_PAR02
	aAdd(aParamBox,{1,"Contabilização De"  ,Ctod("")	,""	,""	,""	,""	,80,.F.})					          //MV_PAR03
	aAdd(aParamBox,{1,"Contabilização Ate" ,Ctod("")	,""	,""	,""	,""	,80,.T.})					          //MV_PAR04
	aAdd(aParamBox,{1,"Fornecedor de: "    ,space(getSX3Cache("A2_COD","X3_TAMANHO")),"","","SA2","",50,.F.}) //MV_PAR05
	aAdd(aParamBox,{1,"Fornecedor até: "   ,space(getSX3Cache("A2_COD","X3_TAMANHO")),"","","SA2","",50,.T.}) //MV_PAR06
	aAdd(aParamBox,{2,"Fornecedores Coligados?"	,"3",aColigadas,60,"",.T.})									  //MV_PAR07

	lPerg	:= ParamBox(aParamBox,"Parametros",,,,.T.,,,,"FinRelIP",.T.,.T.)

Return

//*******************************************************
Static Function ProcRel()

	Local oSection 	:= Nil
	Local nVlrPed	:= 0
	Local cCampo	:= ""
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local cMoeda	:= ""

	If !lPerg
		While !lPerg
			fPerg()
		EndDo
	EndIf

	cQuery := " SELECT E2_FILIAL " + CRLF
	cQuery += "      , E2_FORNECE " + CRLF
	cQuery += "      , E2_LOJA " + CRLF
	cQuery += "      , E2_NOMFOR " + CRLF
	cQuery += "      , E2_NUM " + CRLF
	cQuery += "      , E2_PREFIXO " + CRLF
	cQuery += "      , E2_HIST " + CRLF
	cQuery += "      , E2_TIPO " + CRLF
	cQuery += "      , E2_MOEDA AS MOEDA " + CRLF
	//cQuery += "      , E2_VALOR " + CRLF
	cQuery += "      , E2_BASEIRF " + CRLF
	//cQuery += "      , E2_VLCRUZ " + CRLF
	cQuery += "      , E2_VLCRUZ + E2_IRRF AS E2_VLCRUZ " + CRLF // Ajuste Solicitação Joelma 27/03/20
	cQuery += "      , E2_EMISSAO " + CRLF
	cQuery += "      , E2_EMIS1 " + CRLF
	//cQuery += "      , E2_NATUREZ " + CRLF
	cQuery += "      , ED_DESCRIC " + CRLF
	cQuery += "      , E2_CCUSTO  " + CRLF
	cQuery += "      , E2_BAIXA " + CRLF
	cQuery += "   FROM " + retSqlTab("SE2") + CRLF
	cQuery += "  INNER JOIN " + retSqlTab("SA2") + CRLF
	cQuery += "     ON E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA " + CRLF
	cQuery += "   LEFT JOIN " + retSqlTab("SED") + CRLF
	cQuery += "     ON E2_NATUREZ = ED_CODIGO " + CRLF
	cQuery += "  WHERE A2_EST = 'EX' " + CRLF
	cQuery += "    AND " + retSqlDel("SE2") + CRLF
	cQuery += "    AND " + retSqlDel("SA2") + CRLF

	/* Filtro Filial */
	if !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
		cQuery += " AND E2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + CRLF
	elseif !Empty(MV_PAR01) .AND. Empty(MV_PAR02)
		cQuery += " AND E2_FILIAL >= '" + MV_PAR01 + "'" + CRLF
	elseif Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
		cQuery += " AND E2_FILIAL <= '" + MV_PAR02 + "'" + CRLF
	endif

	/* Data da Contabilização */
	if !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
		cQuery += " AND E2_EMIS1 BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "'" + CRLF
	elseif !Empty(MV_PAR03) .AND. Empty(MV_PAR04)
		cQuery += " AND E2_EMIS1 >= '" + DTOS(MV_PAR03) + "'" + CRLF
	elseif Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
		cQuery += " AND E2_EMIS1 <= '" + DTOS(MV_PAR04) + "'" + CRLF
	endif

	/* Fornecedor */
	if !Empty(MV_PAR05) .AND. !Empty(MV_PAR06)
		cQuery += " AND E2_FORNECE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'" + CRLF
	elseif !Empty(MV_PAR05) .AND. Empty(MV_PAR06)
		cQuery += " AND E2_FORNECE >= '" + MV_PAR05 + "'" + CRLF
	elseif Empty(MV_PAR05) .AND. !Empty(MV_PAR06)
		cQuery += " AND E2_FORNECE <= '" + MV_PAR06 + "'" + CRLF
	endif
	
	/* FILTRO DE FORNECEDOR COLIGADO */	
	If AllTrim(MV_PAR07) == "1"
		cQuery += "	AND A2_ZZCOLIG = 'S' " + CRLF
	ElseIf AllTrim(MV_PAR07) == "2"
		cQuery += "	AND A2_ZZCOLIG = 'N' " + CRLF
	EndIf

	cQuery += "  ORDER BY E2_EMIS1 " + CRLF
	cQuery += "      , E2_NUM " + CRLF
	cQuery += "      , E2_PARCELA " + CRLF

	TcQuery cQuery New Alias &cAlias
	aCampos	:= (cAlias)->( DbStruct() )
	Count to nRegs
	(cAlias)->(dbGoTop())

	oSection:= TRSection():new(oReport, cTitulo)
	oSection:AutoSize()

	For nI := 1 to Len(aCampos)
		cCampo	:= AllTrim( aCampos[nI,DBS_NAME] )

		If GetSx3Cache(cCampo,"X3_TIPO") == "D"
			TcSetField( (cAlias) , cCampo , "D" , 8 , 0 )
		EndIf

		//If cCampo == "MOEDA"
		//TRCell():New(oSection,cCampo,"","Moeda",,10, /*lPixel*/,/*{|| code-block de impressao }*/)
		//else
		TRCell():New(oSection,cCampo,"",GetSx3Cache(cCampo,"X3_TITULO"),GetSx3Cache(cCampo,"X3_PICTURE"),GetSx3Cache(cCampo,"X3_TAMANHO"), /*lPixel*/,/*{|| code-block de impressao }*/)
		//endif
	Next

	oSection:Init()
	oReport:SetMeter(nRegs)

	//Impressao dos Registros
	While (cAlias)->(!Eof())

		For nI := 1 to Len(aCampos)
			cCampo		:= aCampos[nI,DBS_NAME]

			If cCampo == "MOEDA"

				cMoeda := buscaMoeda((cAlias)->&(cCampo))

				oSection:Cell(cCampo):SetValue( cMoeda )
			Else
				oSection:Cell(cCampo):SetValue( (cAlias)->&(cCampo) )
			EndIf
		Next
		oSection:PrintLine()
		oReport:IncMeter()

		If oReport:nDevice == 4 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
			oSection:lHeaderSection := .F.
		EndIf

		(cAlias)->(dbSkip())
	EndDo
	oSection:Finish()
	(cAlias)->(dbCloseArea())

Return (oReport)

static function buscaMoeda(cMoeda)

	local cDesc := ""

	if !Empty(cMoeda)
		cDesc := GETMV("MV_MOEDA"+CVALTOCHAR(cMoeda))
	endif

return cDesc