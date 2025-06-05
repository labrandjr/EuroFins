#include "totvs.ch"
#include "topconn.ch"
#include "Dbstruct.ch"

/*/{Protheus.doc} FatRelIP
Impressão do faturamento

@type 		function
@author 	Julio Lisboa
@since 		07/02/2020
@return		nil,nulo
/*/
User Function FatRelIP()
	
	Private lPerg	:= .F.
	Private oReport	:= Nil
	Private cTitulo	:= "Relatório - Faturamento"
	Private aCampos	:= {}
	
	oReport:= TReport():new("FatRelIP", cTitulo, { || fPerg() } , { || ProcRel() }, cTitulo)
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
	aAdd(aParamBox,{1,"Serie De"				,space(tamsx3("F2_SERIE")[1]),"",""	,""	,""	,50,.F.})		//MV_PAR05
	aAdd(aParamBox,{1,"Serie Ate"				,space(tamsx3("F2_SERIE")[1]),"",""	,""	,""	,50,.T.})		//MV_PAR06
	aAdd(aParamBox,{2,"UF Clientes"				,"3",aUFs,50,"",.T.})										//MV_PAR07
	aAdd(aParamBox,{2,"Clientes Coligadas?"		,"3",aColigadas,60,"",.T.})									//MV_PAR08
	aAdd(aParamBox,{2,"Gera Duplicata ?"		,"3",aDuplic,55,"",.T.})									//MV_PAR09
	aAdd(aParamBox,{2,"NF com ISS?"				,"3",aISS,60,"",.T.})										//MV_PAR10
	
	lPerg	:= ParamBox(aParamBox,"Parametros",,,,.T.,,,,"FatRelIP",.T.,.T.)

Return

//*******************************************************
Static Function ProcRel()
	
	Local oSection 	:= Nil
	Local nVlrPed	:= 0
	Local cCampo	:= ""
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local cMoeda	:= ""
	Local nI		:= 0
	
	If !lPerg
		While !lPerg
			fPerg()
		EndDo
	EndIf
	
	cQuery += " SELECT DISTINCT F2_FILIAL " + CRLF 
	cQuery += "      , F2_CLIENTE " + CRLF
	cQuery += "      , A1_LOJA " + CRLF
	cQuery += "      , RTRIM(A1_NOME) A1_NOME " + CRLF
	cQuery += "      , F2_DOC " + CRLF
	cQuery += "      , F2_SERIE " + CRLF
	cQuery += "      , RTRIM(ISNULL(E1_HIST,'')) E1_HIST " + CRLF 
	cQuery += "      , E1_TIPO " + CRLF
	//cQuery += "	     , F2_MOEDA MOEDA " + CRLF
	cQuery += "      , C5_MOEDA MOEDA " + CRLF // Alteração Solicitação Joelma 24/03/20
	cQuery += "      , CASE WHEN F2_SERIE = 'ND' " + CRLF
	cQuery += "			    THEN (C6_VALOR-F2_VALIMP5-F2_VALIMP6)" + CRLF // Alteração Solicitação Joelma 24/03/20
	cQuery += "			    ELSE (ISNULL(E1_VALOR, F2_VALBRUT)-F2_VALIMP5-F2_VALIMP6)" + CRLF // Alteração Solicitação Joelma 24/03/20
	cQuery += "	        END E1_VALOR " + CRLF
	cQuery += "		 , CASE WHEN F2_SERIE = 'ND' " + CRLF
	cQuery += "			    THEN D2_TOTAL-F2_VALIMP5-F2_VALIMP6 " + CRLF // Ajuste Solicitação Joelma 27/03/20
	cQuery += "			    ELSE (ISNULL(E1_VLCRUZ, F2_VALBRUT)-F2_VALIMP5-F2_VALIMP6) " + CRLF // Ajuste Solicitação Joelma 27/03/20
	cQuery += "	        END E1_VLCRUZ " + CRLF
	cQuery += "      , F2_EMISSAO " + CRLF
	cQuery += "      , ISNULL(E1_EMIS1,F2_EMISSAO) E1_EMIS1 " + CRLF
	cQuery += "      , RTRIM(ISNULL(ED_DESCRIC,'')) E1_NATUREZ " + CRLF
	cQuery += "	     , RTRIM(ISNULL (CTT_DESC01,'')) E1_CCUSTO " + CRLF
	cQuery += "      , CASE WHEN F2_SERIE = 'ND' " + CRLF
	cQuery += "			    THEN B1_DESC " + CRLF
	cQuery += "			    ELSE '' " + CRLF
	cQuery += "	        END B1_DESC " + CRLF
	       
	/*     
	cQuery   += "      , CASE " + CRLF
	cQuery += "		WHEN F2_SERIE = 'ND'" + CRLF
	cQuery += "			THEN RTRIM(ISNULL(C6_ZZNROCE,''))" + CRLF
	cQuery += "			ELSE ''" + CRLF
	cQuery += "	END C6_ZZNROCE, CASE" + CRLF
	cQuery += "		WHEN F2_SERIE = 'ND'" + CRLF
	cQuery += "			THEN RTRIM(ISNULL(C6_ZZCODAM,''))" + CRLF
	cQuery += "			ELSE ''" + CRLF
	cQuery += "	END C6_ZZCODAM" + CRLF
	*/     
	cQuery += "      , CASE WHEN F2_SERIE = 'ND' " + CRLF
	cQuery += "             THEN RTRIM(ISNULL(C6_ZZNROCE,'')) + ' - ' + RTRIM(ISNULL(C6_ZZCODAM,'')) " + CRLF  // Alteração Solicitação Joelma 24/03/20
	cQuery += "             ELSE '' " + CRLF
	cQuery += "         END AS CONC_COLUNAS " + CRLF
	//Johnny Fernandes - 29/03/2022 - Totvs IP - Chamado AMS: 41841 - Inicio
	cQuery += "      , CASE  " + CRLF
	cQuery += "      		WHEN F2_VALISS > 0 THEN 'SIM' " + CRLF
	cQuery += "      		ELSE 'NÃO' " + CRLF
	cQuery += "      	END VALISS " + CRLF
	//Fim
	       
	cQuery += "   FROM " + RetSqlTab("SD2") + CRLF
	cQuery += "	 INNER JOIN " + RetSqlTab("SF2") + CRLF
	cQuery += "		     ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "			AND F2_DOC = D2_DOC " + CRLF
	cQuery += "			AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "			AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "			AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "			AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "			AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	 INNER JOIN " + RetSqlTab("SA1") + CRLF
	cQuery += "		     ON A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
	cQuery += "			AND A1_COD = F2_CLIENTE " + CRLF
	cQuery += "			AND A1_LOJA = F2_LOJA " + CRLF
	cQuery += "			AND SA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	 INNER JOIN " + RetSqlTab("SF4") + CRLF
	cQuery += "		     ON F4_FILIAL = '" + xFilial("SF4") + "'" + CRLF
	cQuery += "			AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "			AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	  LEFT JOIN " + RetSqlTab("SE1") + CRLF
	cQuery += "		     ON E1_FILIAL = F2_FILIAL " + CRLF
	cQuery += "			AND E1_PREFIXO = F2_SERIE " + CRLF
	cQuery += "			AND E1_NUM = F2_DOC " + CRLF
	cQuery += "			AND E1_CLIENTE = F2_CLIENTE " + CRLF
	cQuery += "			AND E1_LOJA = F2_LOJA " + CRLF
	cQuery += "			AND SE1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "			AND E1_TIPO        = 'NF' " + CRLF
	cQuery += "	  LEFT JOIN " + RetSqlTab("SED") + CRLF
	cQuery += "		     ON ED_FILIAL = '" + xFilial("SED") + "'" + CRLF
	cQuery += "			AND ED_CODIGO = E1_NATUREZ " + CRLF
	cQuery += "			AND SED.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	  LEFT JOIN " + RetSqlTab("CTT") + CRLF
	cQuery += "		     ON CTT_FILIAL = '" + xFilial("CTT") + "'" + CRLF
	cQuery += "			AND CTT_CUSTO = E1_CCUSTO " + CRLF
	cQuery += "			AND CTT.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	  LEFT JOIN " + RetSqlTab("SC6") + CRLF
	cQuery += "		     ON C6_FILIAL = D2_FILIAL " + CRLF
	cQuery += "			AND C6_NUM = D2_PEDIDO " + CRLF
	cQuery += "			AND C6_ITEM = D2_ITEMPV " + CRLF
	cQuery += "			AND SC6.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	 INNER JOIN " + RetSqlTab("SC5") + CRLF
	cQuery += "		     ON C6_NUM = C5_NUM " + CRLF
	cQuery += "		    AND C6_FILIAL = C5_FILIAL " + CRLF
	cQuery += "		    AND SC5.D_E_L_E_T_ = ' '" + CRLF	       
	cQuery += "	 INNER JOIN" + RetSqlTab("SB1") + CRLF
	cQuery += "		     ON B1_FILIAL = D2_FILIAL " + CRLF
	cQuery += "			AND B1_COD = D2_COD " + CRLF
	cQuery += "			AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "  WHERE SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	   AND D2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	cQuery += "	   AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' " + CRLF
	cQuery += "	   AND F2_SERIE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
	
	/*
	*		FILTRO DE CLIENTE EX
	*/
	If AllTrim(MV_PAR07) == "1"
		cQuery		+= "	AND A1_EST <> 'EX' " + CRLF
	ElseIf AllTrim(MV_PAR07) == "2"
		cQuery		+= "	AND A1_EST = 'EX' " + CRLF
	EndIf

	/*
	*		FILTRO DE CLIENTE COLIGADA
	*/
	If AllTrim(MV_PAR08) == "1"
		cQuery		+= "	AND A1_ZZCOLIG = 'S' " + CRLF
	ElseIf AllTrim(MV_PAR08) == "2"
		cQuery		+= "	AND A1_ZZCOLIG = 'N' " + CRLF
	EndIf

	/*
	*		FILTRO DE TES QUE GERA FINANCEIRO
	*/
	If AllTrim(MV_PAR09) == "1"
		cQuery		+= "	AND F4_DUPLIC = 'S' " + CRLF
	ElseIf AllTrim(MV_PAR09) == "2"
		cQuery		+= "	AND F4_DUPLIC = 'N' " + CRLF
	EndIf

	/*
	*		FILTRO DE NF COM ISS
	*/
	If AllTrim(MV_PAR10) == "1"
		cQuery		+= "	AND F2_VALISS > 0 " + CRLF
	ElseIf AllTrim(MV_PAR10) == "2"
		cQuery		+= "	AND F2_VALISS = 0 " + CRLF
	EndIf
	
	cQuery		+= "	" + CRLF
	cQuery		+= "ORDER BY" + CRLF
	cQuery		+= "	F2_CLIENTE, F2_EMISSAO " + CRLF
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
		elseif cCampo == "CONC_COLUNAS"
			TRCell():New(oSection,cCampo,"","Cert/Amostra",,18, /*lPixel*/,/*{|| code-block de impressao }*/)
		elseif cCampo == "VALISS"
			TRCell():New(oSection,cCampo,"","ISS",,3, /*lPixel*/,/*{|| code-block de impressao }*/)
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
