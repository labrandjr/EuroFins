#include "totvs.ch"
#include "topconn.ch"
#include "Dbstruct.ch"

/*/{Protheus.doc} ComRelIP
Impressão das NF de entradas

@type 		function
@author 	Julio Lisboa
@since 		07/02/2020
@return		nil,nulo
/*/
User Function ComRelIP()
	
	Private lPerg	:= .F.
	Private oReport	:= Nil
	Private cTitulo	:= "Relatório - Compras"
	Private aCampos	:= {}
	
	oReport:= TReport():new("ComRelIP", cTitulo, { || fPerg() } , { || ProcRel() }, cTitulo)
	oReport:SetLandscape()
	oReport:SetDevice(4)
	oReport:SetTitle(cTitulo)
	oReport:PrintDialog()
	
Return Nil

//*******************************************************
static function fPerg()
	
	Local aParamBox 	:= {}
	local aUFs			:= {}
	local aColigadas	:= {}
	local aDuplic		:= {}
	local aISS			:= {}

	aAdd( aUFs , "1=Nacional")
	aAdd( aUFs , "2=Exterior")
	aAdd( aUFs , "3=Todos")

	aAdd( aColigadas , "1=Sim")
	aAdd( aColigadas , "2=Nao")
	aAdd( aColigadas , "3=Todas")
	
	aAdd( aDuplic , "1=Sim")
	aAdd( aDuplic , "2=Nao")
	aAdd( aDuplic , "3=Todas")

	aAdd( aISS , "1=Sim")
	aAdd( aISS , "2=Nao")
	aAdd( aISS , "3=Todas")
	
	aAdd(aParamBox,{1,"Filial De"				,space(tamsx3("F2_FILIAL")[1]),""	,""	,""	,""	,40,.F.})	//MV_PAR01
	aAdd(aParamBox,{1,"Filial Ate"				,space(tamsx3("F2_FILIAL")[1]),""	,""	,""	,""	,40,.T.})	//MV_PAR02
	aAdd(aParamBox,{1,"Emissao De"				,Ctod("")	,""	,""	,""	,""	,80,.T.})						//MV_PAR03
	aAdd(aParamBox,{1,"Emissao Ate"				,Ctod("")	,""	,""	,""	,""	,80,.T.})						//MV_PAR04	
	aAdd(aParamBox,{1,"Digitação De"			,Ctod("")	,""	,""	,""	,""	,80,.F.})						//MV_PAR05
	aAdd(aParamBox,{1,"Digitação Ate"			,Ctod("")	,""	,""	,""	,""	,80,.F.})						//MV_PAR06	
	aAdd(aParamBox,{1,"Serie De"				,space(tamsx3("F2_SERIE")[1]),"",""	,""	,""	,50,.F.})		//MV_PAR07
	aAdd(aParamBox,{1,"Serie Ate"				,space(tamsx3("F2_SERIE")[1]),"",""	,""	,""	,50,.T.})		//MV_PAR08
	aAdd(aParamBox,{2,"UF Fornecedores"			,"3",aUFs,50,"",.T.})										//MV_PAR09
	aAdd(aParamBox,{2,"Fornecedores Coligados?"	,"3",aColigadas,60,"",.T.})									//MV_PAR10
	aAdd(aParamBox,{2,"Gera Duplicata ?"		,"3",aDuplic,55,"",.T.})									//MV_PAR11
	
	lPerg	:= ParamBox(aParamBox,"Parametros",,,,.T.,,,,"ComRelIP",.T.,.T.)

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

	cQuery		+= "SELECT DISTINCT" + CRLF
	cQuery		+= "	F1_FILIAL, A2_COD, A2_LOJA , A2_NOME, F1_DOC , F1_SERIE, ' ' E2_HIST , E2_TIPO, F1_MOEDA MOEDA" + CRLF
	cQuery		+= "	, CASE" + CRLF
	cQuery		+= "		WHEN C7_MOEDA <> 1" + CRLF
	cQuery		+= "			THEN (ISNULL(C7_TOTAL,D1_TOTAL)-F1_VALIMP5-F1_VALIMP6)" + CRLF
	cQuery		+= "			ELSE D1_TOTAL-F1_VALIMP5-F1_VALIMP6" + CRLF
	cQuery		+= "	  END E2_VALOR " + CRLF
	cQuery      += "    , D1_TOTAL-F1_VALIMP5-F1_VALIMP6 E2_VLCRUZ " + CRLF // Ajuste Solicitação Joelma 27/03/20
	cQuery      += "    , F1_EMISSAO , ISNULL (E2_EMIS1,F1_EMISSAO) E2_EMIS1, ' '" + CRLF
	cQuery		+= "	E2_NATUREZ , ISNULL (CTT_CUSTO,'') E2_CCUSTO, CASE" + CRLF
	cQuery		+= "		WHEN F1_SERIE IN ('ND','000')" + CRLF
	cQuery		+= "			THEN B1_DESC" + CRLF
	cQuery		+= "			ELSE ''" + CRLF
	cQuery		+= "	END B1_DESC, '' C6_ZZNROCE" + CRLF
	cQuery		+= "FROM" + CRLF
	cQuery		+= "	" + RetSqlTab("SD1") + CRLF
	cQuery		+= "	INNER JOIN" + CRLF
	cQuery		+= "		" + RetSqlTab("SF1") + CRLF
	cQuery		+= "		ON" + CRLF
	cQuery		+= "			F1_FILIAL          = D1_FILIAL" + CRLF
	cQuery		+= "			AND F1_DOC         = D1_DOC" + CRLF
	cQuery		+= "			AND F1_SERIE       = D1_SERIE" + CRLF
	cQuery		+= "			AND F1_FORNECE     = D1_FORNECE" + CRLF
	cQuery		+= "			AND F1_LOJA        = D1_LOJA" + CRLF
	cQuery		+= "			AND F1_TIPO        = D1_TIPO" + CRLF
	cQuery		+= "			AND SF1.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "	INNER JOIN" + CRLF
	cQuery		+= "		" + RetSqlTab("SA2") + CRLF
	cQuery		+= "		ON" + CRLF
	cQuery		+= "			A2_FILIAL          = '" + xFilial("SA2") + "'" + CRLF
	cQuery		+= "			AND A2_COD         = F1_FORNECE" + CRLF
	cQuery		+= "			AND A2_LOJA        = F1_LOJA" + CRLF
	cQuery		+= "			AND SA2.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "	INNER JOIN" + CRLF
	cQuery		+= "		" + RetSqlTab("SF4") + CRLF
	cQuery		+= "		ON" + CRLF
	cQuery		+= "			F4_FILIAL          = '" + xFilial("SF4") + "'" + CRLF
	cQuery		+= "			AND F4_CODIGO      = D1_TES" + CRLF
	cQuery		+= "			AND SF4.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "	LEFT JOIN" + CRLF
	cQuery		+= "		" + RetSqlTab("SE2") + CRLF
	cQuery		+= "		ON" + CRLF
	cQuery		+= "			E2_FILIAL          = F1_FILIAL" + CRLF
	cQuery		+= "			AND E2_PREFIXO     = F1_SERIE" + CRLF
	cQuery		+= "			AND E2_NUM         = F1_DOC" + CRLF
	cQuery		+= "			AND E2_FORNECE     = F1_FORNECE" + CRLF
	cQuery		+= "			AND E2_LOJA        = F1_LOJA" + CRLF
	cQuery		+= "			AND SE2.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "			AND E2_TIPO        = 'NF'" + CRLF
	cQuery		+= "	LEFT JOIN" + CRLF
	cQuery		+= "		" + RetSqlTab("SED") + CRLF
	cQuery		+= "		ON" + CRLF
	cQuery		+= "			ED_FILIAL          = '" + xFilial("SED") + "'" + CRLF
	cQuery		+= "			AND ED_CODIGO      = E2_NATUREZ" + CRLF
	cQuery		+= "			AND SED.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "	LEFT JOIN" + CRLF
	cQuery		+= "		" + RetSqlTab("CTT") + CRLF
	cQuery		+= "		ON" + CRLF
	cQuery		+= "			CTT_FILIAL         = '" + xFilial("CTT") + "'" + CRLF
	cQuery		+= "			AND CTT_CUSTO      = D1_CC" + CRLF
	cQuery		+= "			AND CTT.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "	LEFT JOIN" + CRLF
	cQuery		+= "		" + RetSqlTab("SC7") + CRLF
	cQuery		+= "		ON" + CRLF
	cQuery		+= "			C7_FILIAL          = D1_FILIAL" + CRLF
	cQuery		+= "			AND C7_NUM         = D1_PEDIDO" + CRLF
	cQuery		+= "			AND SC7.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "	INNER JOIN" + CRLF
	cQuery		+= "		" + RetSqlTab("SB1") + CRLF
	cQuery		+= "		ON" + CRLF
	cQuery		+= "			B1_FILIAL          = D1_FILIAL" + CRLF
	cQuery		+= "			AND B1_COD         = D1_COD" + CRLF
	cQuery		+= "			AND SB1.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "WHERE" + CRLF
	cQuery		+= "	SD1.D_E_L_E_T_ = ' '" + CRLF
	cQuery		+= "	AND D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	cQuery		+= "	AND D1_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' " + CRLF
	cQuery		+= "	AND D1_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + CRLF
	
	/* Filtro de Data de Digitação */
	if !Empty(MV_PAR05) .AND. !Empty(MV_PAR06)
		cQuery += " AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' " + CRLF
	elseif !Empty(MV_PAR05) .AND. Empty(MV_PAR06)
		cQuery += " AND D1_DTDIGIT >= '" + DTOS(MV_PAR05) + "'" + CRLF
	elseif Empty(MV_PAR05) .AND. !Empty(MV_PAR06)
		cQuery += " AND D1_DTDIGIT <= '" + DTOS(MV_PAR06) + "'" + CRLF		
	endif
	
	/*
	*		FILTRO DE FORNECEDOR EX
	*/
	If AllTrim(MV_PAR09) == "1"
		cQuery		+= "	AND A2_EST <> 'EX' " + CRLF
	ElseIf AllTrim(MV_PAR09) == "2"
		cQuery		+= "	AND A2_EST = 'EX' " + CRLF
	EndIf

	/*
	*		FILTRO DE FORNECEDOR COLIGADA
	*/
	If AllTrim(MV_PAR10) == "1"
		cQuery		+= "	AND A2_ZZCOLIG = 'S' " + CRLF
	ElseIf AllTrim(MV_PAR10) == "2"
		cQuery		+= "	AND A2_ZZCOLIG = 'N' " + CRLF
	EndIf

	/*
	*		FILTRO DE TES QUE GERA FINANCEIRO
	*/
	If AllTrim(MV_PAR11) == "1"
		cQuery		+= "	AND F4_DUPLIC = 'S' " + CRLF
	ElseIf AllTrim(MV_PAR11) == "2"
		cQuery		+= "	AND F4_DUPLIC = 'N' " + CRLF
	EndIf

	cQuery		+= "ORDER BY" + CRLF
	cQuery		+= "	A2_COD, F1_EMISSAO " + CRLF
	cQuery		+= "" + CRLF
	
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
		
		If cCampo == "MOEDA"
			TRCell():New(oSection,cCampo,"","Moeda",,10, /*lPixel*/,/*{|| code-block de impressao }*/)
		else
			TRCell():New(oSection,cCampo,"",GetSx3Cache(cCampo,"X3_TITULO"),GetSx3Cache(cCampo,"X3_PICTURE"),GetSx3Cache(cCampo,"X3_TAMANHO"), /*lPixel*/,/*{|| code-block de impressao }*/)
		endif
	Next
	
	oSection:Init()
	oReport:SetMeter(nRegs)
	
	//Impressao dos Registros
	While (cAlias)->(!Eof())
		
		For nI := 1 to Len(aCampos)
			cCampo		:= aCampos[nI,DBS_NAME]
			
			If cCampo == "MOEDA"
				if (cAlias)->&(cCampo) > 9
					cMoeda		:= GetMV("MV_MOEDP"+Str( (cAlias)->&(cCampo) ,2))
				else
					cMoeda		:= GetMV("MV_MOEDAP"+Str( (cAlias)->&(cCampo) ,1))
				endif

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
