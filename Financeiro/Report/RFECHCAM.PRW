#include "totvs.ch"
#include "topconn.ch"
/*/{protheus.doc} RFECHCAM
Relatorio de fechamento de cambio do contas a pagar
@author Sergio Braz
@since 19/06/19
/*/
User Function RFECHCAM
	private cAlias := ""
	If AskMe()
		cAlias := GetData()
		Processa({|| ExpExcel()})
		(cAlias)->(DbCloseArea())
	Endif
Return

Static Function AskMe
	Local aPergs := {}
	Local aCart  := {"Receber","Pagar"}
	AADD(aPergs,{1,"Da filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Ate filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Emissao De",stod(""),"",'.t.',"",'.T.',50,.F.})
	AADD(aPergs,{1,"Emissao Ate",stod(""),"",'.t.',"",'.T.',50,.F.})
	AADD(aPergs,{1,"Vcto De",stod(""),"",'.t.',"",'.T.',50,.F.})
	AADD(aPergs,{1,"Vcto Ate",stod(""),"",'.t.',"",'.T.',50,.F.})
Return ParamBox(aPergs,"Parametros",{})

Static Function ExpExcel
	Local oExcel 	:= FWMSExcel():New()
	Local cFile 	:= GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local aFields	:= {}
	Local cFields	:= ""
	Local aTitles	:= {}
	Local cTitles	:= ""
	Local aValores	:= {}
	Local cPlan   	:= "Fechamento de Cambio"
	Local cTable  	:= "Contas a Pagar"
	Local i			:= 0

	cFields := "FILIAL,COMPANY,CENTRO_CUSTO,INVOICE,TITULO,TIPO_TITULO,HISTORICO,NATUREZA,TIPO,SUPPLIER,INTERCO,CORPORATE_NAME,CURRENCY_NUM,CURRENCY,ORIGINAL_VALUE,VALUE,INVOICE_DATE,BR_VALUE,ISS,PIS,COFINS,IRRF,CIDE,IOF,DESP_CORRETAGEM,TOTAL_EM_REAIS,VENCTO,VENCTO_REAL,COUNTRY,ACCOUNTING_DATE,TAX,CONTRATO,PREFIXO,PARCELA,LOJA"
	cTitles := StrTran(cFields,"_"," ")
	Count to nRegs
	ProcRegua(nRegs)
	(cAlias)->(DbGoTop())
	aFields := StrToKarr(cFields,",")
	aTitles := StrToKarr(cTitles,",")
	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan,cTable)
	For i:=1 To Len(aFields)
		If ValType(&(aFields[i])) == "D"
			nAlign := 2
			nType  := 4
		ElseIf ValType(&(aFields[i])) == "N" .or. 'Transform'$aFields[i]
			nAlign := 3
			nType  := 2
		Else
			nAlign := 1
			nType  := 1
		Endif
		oExcel:AddColumn(cPlan,cTable,Capital(aTitles[i]),nAlign,nType,.f.)
	Next
	While (cAlias)->(!Eof())
		aValores := {}
		For i:=1 to Len(aFields)
			If (aFields[i]) == "COUNTRY"
				//cCod := GetAdvFval("SA2", "A2_PAIS", (cAlias) -> COMPANY + (cAlias) -> SUPPLIER + (cAlias) -> E2_LOJA,1,"",.T.)
				cCod := Posicione("SA2",1,xFilial("SA2")+(cAlias)->SUPPLIER+(cAlias)->LOJA,"A2_PAIS")
				//cDesc := GetAdvFval("SYA", "YA_DESCR", (cAlias) -> COMPANY + cCod,1,"",.T.)
				cDesc := Posicione("SYA",1,xFilial("SYA")+cCod,"YA_DESCR")
				AADD(aValores,/*&(aFields[i]*/cDesc)
		    Else
		    	AADD(aValores,&(aFields[i]))
		    EndIf
		Next
		oExcel:AddRow(cPlan,cTable,aValores)
		(cAlias)->(DbSkip())
		IncProc()
	End
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	If File(cFile)
		If MsgYesNo("Abrir arquivo "+cFile)
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open(cFile)
			oExcel:SetVisible(.T.)
		Endif
	Endif
Return

Static Function GetData()
	local cQuery := ""
	local cAlias := ""

	cQuery += "SELECT FILIAL " + CRLF
	cQuery += "     , COMPANY " + CRLF
	cQuery += "     , CENTRO_CUSTO " + CRLF
	cQuery += "	    , INVOICE " + CRLF
	cQuery += "	    , TITULO " + CRLF
	cQuery += "	    , HISTORICO " + CRLF
	cQuery += "	    , NATUREZA " + CRLF
	cQuery += "	    , TIPO " + CRLF
	cQuery += "	    , SUPPLIER " + CRLF
	cQuery += "	    , INTERCO " + CRLF
	cQuery += "	    , CORPORATE_NAME " + CRLF
	cQuery += "	    , CURRENCY_NUM " + CRLF
	cQuery += "	    , CURRENCY " + CRLF
	cQuery += "	    , INVOICE_DATE " + CRLF
	cQuery += "     , RATE " + CRLF
	cQuery += "     , BR_VALUE " + CRLF
	cQuery += "     , VALUE " + CRLF
	cQuery += "     , ORIGINAL_VALUE " + CRLF
	// cQuery += "     , CASE LTRIM(RTRIM(TIPO_TITULO)) WHEN 'NF' THEN 0 ELSE VALUE END AS VALUE " + CRLF //Chamado 21709
	// cQuery += "     , CASE LTRIM(RTRIM(TIPO_TITULO)) WHEN 'NF' THEN 0 ELSE ORIGINAL_VALUE END AS ORIGINAL_VALUE " + CRLF //Chamado 21709
	cQuery += "     , ISS " + CRLF
	cQuery += "     , PIS " + CRLF
	cQuery += "     , COFINS " + CRLF
	cQuery += "     , IRRF " + CRLF
	cQuery += "     , CIDE " + CRLF
	cQuery += "     , IOF " + CRLF
	cQuery += "     , DESP_CORRETAGEM " + CRLF
	cQuery += "     , ROUND(SUM((E2_VLCRUZ*0) + E2_ISS + E2_IRRF + E2_PIS + E2_COFINS + E2_CIDE + E2_CSLL + E2_INSS),2) AS TOTAL_EM_REAIS " + CRLF
	cQuery += "     , VENCTO " + CRLF
	cQuery += "     , VENCTO_REAL " + CRLF
	cQuery += "     , TIPO_TITULO " + CRLF
	cQuery += "     , ACCOUNTING_DATE " + CRLF
	cQuery += "     , '' COUNTRY " + CRLF
	cQuery += "     , LOJA " + CRLF
	cQuery += "	    , CASE_CUSTO " + CRLF
	cQuery += "	    , CASE_VALOR " + CRLF
	cQuery += "	 	, TAX " + CRLF
    cQuery += "	 	, CONTRATO " + CRLF
	cQuery += "	 	, PREFIXO " + CRLF
	cQuery += "	 	, PARCELA " + CRLF
	cQuery += "  FROM ( SELECT SE2.E2_FILIAL as FILIAL, " + CRLF
	cQuery += "		      CASE " + CRLF
	cQuery += "             WHEN SE2.E2_RATEIO = 'S' THEN SEZ.EZ_CCUSTO " + CRLF
	cQuery += "             ELSE SE2.E2_CCUSTO " + CRLF
	cQuery += "         END AS CASE_CUSTO, " + CRLF
	cQuery += "		      CASE " + CRLF
	cQuery += "             WHEN SE2.E2_VALOR <> SE2.E2_SALDO THEN SE2.E2_SALDO " + CRLF
	cQuery += "             ELSE SE2.E2_VALOR " + CRLF
	cQuery += "         END AS CASE_VALOR, " + CRLF
	cQuery += "           CASE " + CRLF
	cQuery += "             WHEN LEFT(SE2.E2_FILIAL, 2) = '01' THEN 'CBR001' " + CRLF
	cQuery += "             WHEN LEFT(SE2.E2_FILIAL, 2) = '03' THEN 'CBR003' " + CRLF
	cQuery += "             WHEN LEFT(SE2.E2_FILIAL, 2) = '04' THEN 'CBR004' " + CRLF
	cQuery += "             WHEN LEFT(SE2.E2_FILIAL, 2) = '05' THEN 'CBR005' " + CRLF
	cQuery += "             WHEN LEFT(SE2.E2_FILIAL, 2) = '06' THEN 'CBR006' " + CRLF
	cQuery += "             WHEN LEFT(SE2.E2_FILIAL, 2) = '08' THEN 'CBR008' " + CRLF
	cQuery += "           	WHEN LEFT(SE2.E2_FILIAL, 2) = '50' THEN 'CBR013' " + CRLF
    cQuery += "           	WHEN LEFT(SE2.E2_FILIAL, 2) = '51' THEN 'CBR015' " + CRLF
    cQuery += "          	WHEN LEFT(SE2.E2_FILIAL, 2) = '52' THEN 'CBR017' " + CRLF
	cQuery += "         END AS COMPANY, " + CRLF
	cQuery += "           CASE " + CRLF
	cQuery += "             WHEN SE2.E2_RATEIO = 'S' THEN SEZ.EZ_CCUSTO " + CRLF
	cQuery += "             ELSE SE2.E2_CCUSTO " + CRLF
	cQuery += "         END AS CENTRO_CUSTO, " + CRLF
	cQuery += "       SE2.E2_ZZNUINV AS INVOICE, " + CRLF
	cQuery += "       SE2.E2_NUM AS TITULO, " + CRLF
	cQuery += "       RTRIM(SE2.E2_HIST) AS HISTORICO, " + CRLF
	cQuery += "       SE2.E2_NATUREZ AS NATUREZA, " + CRLF
	cQuery += "       SED.ED_DESCRIC AS TIPO, " + CRLF
	cQuery += "       SE2.E2_FORNECE AS SUPPLIER, " + CRLF
	cQuery += "       SE2.E2_NOMFOR AS INTERCO, " + CRLF
	cQuery += "       SA2.A2_NOME AS CORPORATE_NAME, " + CRLF
	cQuery += "       Cast(SE2.E2_MOEDA AS nvarchar(2)) AS CURRENCY_NUM, " + CRLF
	cQuery += "       CASE " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 2 THEN 'DOLAR VENDA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 4 THEN 'DOLAR COMPRA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 5 THEN 'EURO VENDA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 6 THEN 'EURO COMPRA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 7 THEN 'PESO CHIL VENDA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 8 THEN 'PESO CHIL COMPRA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 9 THEN 'LIBRA VENDA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 10 THEN 'LIBRA COMPRA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 11 THEN 'COROA SUECA VENDA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 12 THEN 'COROA SUECA COMPRA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 13 THEN 'DOLAR CAN VENDA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 14 THEN 'DOLAR CAN COMPRA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 15 THEN 'COROA NORUEG VENDA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 16 THEN 'COROA NORUEG COMPRA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 17 THEN 'FRANCO SUICO VENDA' " + CRLF
	cQuery += "           WHEN SE2.E2_MOEDA = 18 THEN 'FRANCO SUICO COMPRA' " + CRLF
	cQuery += "       END AS CURRENCY, " + CRLF
	cQuery += "       SE2.E2_VALOR AS ORIGINAL_VALUE, " + CRLF
	cQuery += "       CASE " + CRLF
	cQuery += "           WHEN SE2.E2_VALOR <> SE2.E2_SALDO THEN SE2.E2_SALDO " + CRLF
	cQuery += "           ELSE SE2.E2_VALOR " + CRLF
	cQuery += "       END AS VALUE, " + CRLF
	cQuery += "       SE2.E2_EMISSAO AS INVOICE_DATE, " + CRLF
	cQuery += "       (SE2.E2_TXMOEDA*0) AS RATE, " + CRLF
	cQuery += "       (SE2.E2_VLCRUZ*0) AS BR_VALUE, " + CRLF
	cQuery += "       SE2.E2_ISS AS ISS, " + CRLF
	cQuery += "       SE2.E2_PIS AS PIS, " + CRLF
	cQuery += "       SE2.E2_COFINS AS COFINS, " + CRLF
	cQuery += "       SE2.E2_IRRF AS IRRF, " + CRLF
	cQuery += "       SE2.E2_CIDE AS CIDE, " + CRLF
	cQuery += "       SE2.E2_CSLL AS IOF, " + CRLF
	cQuery += "       SE2.E2_INSS AS DESP_CORRETAGEM, " + CRLF
	cQuery += "       SE2.E2_VLCRUZ, " + CRLF
	cQuery += "	      SE2.E2_ISS,  " + CRLF
	cQuery += "	      SE2.E2_IRRF,  " + CRLF
	cQuery += "	      SE2.E2_PIS, " + CRLF
	cQuery += "	      SE2.E2_COFINS, " + CRLF
	cQuery += "	      SE2.E2_CIDE, " + CRLF
	cQuery += "	      SE2.E2_CSLL, " + CRLF
	cQuery += "	      SE2.E2_INSS, " + CRLF
	cQuery += "       E2_VENCTO AS VENCTO, " + CRLF
	cQuery += "       E2_VENCREA AS VENCTO_REAL, " + CRLF
	cQuery += "       E2_TIPO AS TIPO_TITULO, " + CRLF
	cQuery += "       E2_EMIS1 AS ACCOUNTING_DATE, " + CRLF
	cQuery += "       (E2_TXMOEDA*0) AS TAX, " + CRLF
    cQuery += "       E2_ZZCTCAM AS CONTRATO, " + CRLF
	cQuery += "       E2_PARCELA AS PARCELA, " + CRLF
	cQuery += "       E2_PREFIXO AS PREFIXO, " + CRLF
	cQuery += "       E2_LOJA as LOJA " + CRLF
	cQuery += "FROM SE2010 SE2 " + CRLF
	cQuery += "INNER JOIN SA2010 SA2 " + CRLF
	cQuery += "   ON E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA " + CRLF
	cQuery += "LEFT JOIN SED010 SED ON SED.ED_CODIGO = SE2.E2_NATUREZ " + CRLF
	cQuery += "	AND SED.D_E_L_E_T_ ='' " + CRLF
	cQuery += "LEFT JOIN SEZ010 SEZ ON SE2.E2_FILIAL = SEZ.EZ_FILIAL " + CRLF
	cQuery += "	AND SE2.E2_PREFIXO = SEZ.EZ_PREFIXO " + CRLF
	cQuery += "	AND SE2.E2_NUM = SEZ.EZ_NUM " + CRLF
	cQuery += "	AND SE2.E2_PARCELA = SEZ.EZ_PARCELA " + CRLF
	cQuery += "	AND SE2.E2_TIPO = SEZ.EZ_PARCELA " + CRLF
	cQuery += "	AND SE2.E2_TIPO = SEZ.EZ_TIPO " + CRLF
	cQuery += "	AND SE2.E2_FORNECE = SEZ.EZ_CLIFOR " + CRLF
	cQuery += "	AND SE2.E2_LOJA = SEZ.EZ_LOJA " + CRLF
	cQuery += "	AND SEZ.EZ_RECPAG = 'P' " + CRLF
	cQuery += "	AND SEZ.D_E_L_E_T_ = '' " + CRLF
	//cQuery += "LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ = '' " + CRLF
	//cQuery += "	AND SE2.E2_FORNECE = SA2.A2_COD " + CRLF
	//cQuery += "	AND SE2.E2_LOJA =SA2.A2_LOJA " + CRLF
	cQuery += "WHERE 1=1 " + CRLF
	cQuery += "  AND SE2.E2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + CRLF
	If !empty(MV_PAR04)
		cQuery += "  AND SE2.E2_EMISSAO BETWEEN '" + dtos(MV_PAR03) + "' AND '" + dtos(MV_PAR04) + "'" + CRLF
	EndIf
	If !empty(MV_PAR06)
		cQuery += "  AND SE2.E2_VENCREA BETWEEN '" + dtos(MV_PAR05) + "' AND '" + dtos(MV_PAR06) + "'" + CRLF
	EndIf
	//cQuery += "  AND SE2.E2_MOEDA <> 1 " + CRLF
	cQuery += "  AND SA2.A2_EST = 'EX' " + CRLF
	cQuery += "  AND SE2.E2_SALDO > 0 " + CRLF
	cQuery += "  AND SE2.D_E_L_E_T_ = '' " + CRLF
	cQuery += ") as TAB_TESTE " + CRLF
	cQuery += "GROUP BY FILIAL  " + CRLF
	cQuery += "  , COMPANY " + CRLF
	cQuery += "  , CENTRO_CUSTO " + CRLF
	cQuery += "	 , INVOICE " + CRLF
	cQuery += "	 , TITULO " + CRLF
	cQuery += "	 , HISTORICO " + CRLF
	cQuery += "	 , NATUREZA " + CRLF
	cQuery += "	 , TIPO " + CRLF
	cQuery += "	 , SUPPLIER " + CRLF
	cQuery += "	 , INTERCO " + CRLF
	cQuery += "	 , CORPORATE_NAME " + CRLF
	cQuery += "	 , CURRENCY_NUM " + CRLF
	cQuery += "	 , CURRENCY " + CRLF
	cQuery += "	 , ORIGINAL_VALUE " + CRLF
	cQuery += "	 , INVOICE_DATE " + CRLF
	cQuery += "	 , RATE " + CRLF
	cQuery += "  , BR_VALUE " + CRLF
	cQuery += "  , VALUE " + CRLF
	cQuery += "  , ISS " + CRLF
	cQuery += "  , PIS " + CRLF
	cQuery += "  , COFINS " + CRLF
	cQuery += "  , IRRF " + CRLF
	cQuery += "  , CIDE " + CRLF
	cQuery += "  , IOF " + CRLF
	cQuery += "  , DESP_CORRETAGEM " + CRLF
	cQuery += "  , VENCTO " + CRLF
	cQuery += "  , VENCTO_REAL " + CRLF
	cQuery += "  , TIPO_TITULO " + CRLF
	cQuery += "  , ACCOUNTING_DATE " + CRLF
	cQuery += "  , LOJA " + CRLF
	cQuery += "  , CASE_CUSTO " + CRLF
	cQuery += "	 , CASE_VALOR " + CRLF
	cQuery += "	 , TAX " + CRLF
    cQuery += "	 , CONTRATO " + CRLF
	cQuery += "	 , PREFIXO " + CRLF
	cQuery += "	 , PARCELA " + CRLF
	cQuery += "	 Order by FILIAL, INVOICE, TITULO " + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	TcSetField(cAlias,"INVOICE_DATE","D",8,0)
	TcSetField(cAlias,"VENCTO","D",8,0)
	TcSetField(cAlias,"VENCTO_REAL","D",8,0)
	TcSetField(cAlias,"ACCOUNTING_DATE","D",8,0)
Return cAlias


/*
	SELECT FILIAL
	     , COMPANY
	     , CENTRO_CUSTO
		    , INVOICE
		    , TITULO
		    , HISTORICO
		    , NATUREZA
		    , TIPO
		    , SUPPLIER
		    , INTERCO
		    , CORPORATE_NAME
		    , CURRENCY_NUM
		    , CURRENCY
		    , INVOICE_DATE
	     , RATE
	     , BR_VALUE
	     , ROUND(((VALUE*PERC_NT)*PERC_CC),2) AS [VALUE]
	     , ROUND(((ORIGINAL_VALUE*PERC_NT)*PERC_CC),2) AS ORIGINAL_VALUE
	     , ROUND(((ISS*PERC_NT)*PERC_CC),2) AS ISS
	     , ROUND(((PIS*PERC_NT)*PERC_CC),2) AS PIS
	     , ROUND(((COFINS*PERC_NT)*PERC_CC),2) AS COFINS
	     , ROUND(((IRRF*PERC_NT)*PERC_CC),2) AS IRRF
	     , ROUND(((CIDE*PERC_NT)*PERC_CC),2) AS CIDE
	     , ROUND(((IOF*PERC_NT)*PERC_CC),2) AS IOF
	     , ROUND(((DESP_CORRETAGEM*PERC_NT)*PERC_CC),2) AS DESP_CORRETAGEM
	     , ROUND(SUM((ROUND(((E2_VLCRUZ*PERC_NT)*PERC_CC),2)*0) +
			ROUND(((E2_ISS*PERC_NT)*PERC_CC),2) +
			ROUND(((E2_IRRF*PERC_NT)*PERC_CC),2) +
			ROUND(((E2_PIS*PERC_NT)*PERC_CC),2) +
			ROUND(((E2_COFINS*PERC_NT)*PERC_CC),2) +
			ROUND(((E2_CIDE*PERC_NT)*PERC_CC),2) +
			ROUND(((E2_CSLL*PERC_NT)*PERC_CC),2) +
			ROUND(((E2_INSS*PERC_NT)*PERC_CC),2)),2) AS TOTAL_EM_REAIS
	     , VENCTO
	     , VENCTO_REAL
	     , TIPO_TITULO
	     , ACCOUNTING_DATE
	     , '' COUNTRY
	     , LOJA
		 , CASE_CUSTO
		 , CASE_VALOR
		 , TAX
    	 , CONTRATO
		 , PREFIXO
		 , PARCELA
	  FROM (

	  SELECT SE2.E2_FILIAL as FILIAL,
			      CASE
	             WHEN (SE2.E2_RATEIO = 'S' OR SE2.E2_MULTNAT = '1') THEN SEZ.EZ_CCUSTO
	             ELSE SE2.E2_CCUSTO
	         END AS CASE_CUSTO,
			      CASE
	             WHEN SE2.E2_VALOR <> SE2.E2_SALDO THEN SE2.E2_SALDO
	             ELSE SE2.E2_VALOR
	         END AS CASE_VALOR,
	           CASE
	             WHEN LEFT(SE2.E2_FILIAL, 2) = '01' THEN 'CBR001'
	             WHEN LEFT(SE2.E2_FILIAL, 2) = '03' THEN 'CBR003'
	             WHEN LEFT(SE2.E2_FILIAL, 2) = '04' THEN 'CBR004'
	             WHEN LEFT(SE2.E2_FILIAL, 2) = '05' THEN 'CBR005'
	             WHEN LEFT(SE2.E2_FILIAL, 2) = '06' THEN 'CBR006'
	             WHEN LEFT(SE2.E2_FILIAL, 2) = '08' THEN 'CBR008'
	           	WHEN LEFT(SE2.E2_FILIAL, 2) = '50' THEN 'CBR013'
               	WHEN LEFT(SE2.E2_FILIAL, 2) = '51' THEN 'CBR015'
              	WHEN LEFT(SE2.E2_FILIAL, 2) = '52' THEN 'CBR017'
	         END AS COMPANY,
	           CASE
	             WHEN SE2.E2_RATEIO = 'S' OR SE2.E2_MULTNAT = '1' THEN SEZ.EZ_CCUSTO
	             ELSE SE2.E2_CCUSTO
	         END AS CENTRO_CUSTO,
	       SE2.E2_ZZNUINV AS INVOICE,
	       SE2.E2_NUM AS TITULO,
	       RTRIM(SE2.E2_HIST) AS HISTORICO,
	       CASE WHEN E2_MULTNAT = '1' THEN SEZ.EZ_NATUREZ ELSE SE2.E2_NATUREZ END AS NATUREZA,
	       SED.ED_DESCRIC AS TIPO,
	       SE2.E2_FORNECE AS SUPPLIER,
	       SE2.E2_NOMFOR AS INTERCO,
	       SA2.A2_NOME AS CORPORATE_NAME,
	       Cast(SE2.E2_MOEDA AS nvarchar(2)) AS CURRENCY_NUM,
	       CASE
	           WHEN SE2.E2_MOEDA = 1 THEN 'REAL'
			   WHEN SE2.E2_MOEDA = 2 THEN 'DOLAR VENDA'
	           WHEN SE2.E2_MOEDA = 4 THEN 'DOLAR COMPRA'
	           WHEN SE2.E2_MOEDA = 5 THEN 'EURO VENDA'
	           WHEN SE2.E2_MOEDA = 6 THEN 'EURO COMPRA'
	           WHEN SE2.E2_MOEDA = 7 THEN 'PESO CHIL VENDA'
	           WHEN SE2.E2_MOEDA = 8 THEN 'PESO CHIL COMPRA'
	           WHEN SE2.E2_MOEDA = 9 THEN 'LIBRA VENDA'
	           WHEN SE2.E2_MOEDA = 10 THEN 'LIBRA COMPRA'
	           WHEN SE2.E2_MOEDA = 11 THEN 'COROA SUECA VENDA'
	           WHEN SE2.E2_MOEDA = 12 THEN 'COROA SUECA COMPRA'
	           WHEN SE2.E2_MOEDA = 13 THEN 'DOLAR CAN VENDA'
	           WHEN SE2.E2_MOEDA = 14 THEN 'DOLAR CAN COMPRA'
	           WHEN SE2.E2_MOEDA = 15 THEN 'COROA NORUEG VENDA'
	           WHEN SE2.E2_MOEDA = 16 THEN 'COROA NORUEG COMPRA'
	           WHEN SE2.E2_MOEDA = 17 THEN 'FRANCO SUICO VENDA'
	           WHEN SE2.E2_MOEDA = 18 THEN 'FRANCO SUICO COMPRA'
	       END AS CURRENCY,
	       SE2.E2_VALOR AS ORIGINAL_VALUE,
	       CASE
	           WHEN SE2.E2_VALOR <> SE2.E2_SALDO THEN SE2.E2_SALDO
	           ELSE SE2.E2_VALOR
	       END AS VALUE,
	       SE2.E2_EMISSAO AS INVOICE_DATE,
	       (SE2.E2_TXMOEDA*0) AS RATE,
	       (SE2.E2_VLCRUZ*0) AS BR_VALUE,
	       SE2.E2_ISS AS ISS,
	       SE2.E2_PIS AS PIS,
	       SE2.E2_COFINS AS COFINS,
	       SE2.E2_IRRF AS IRRF,
	       SE2.E2_CIDE AS CIDE,
	       SE2.E2_CSLL AS IOF,
	       SE2.E2_INSS AS DESP_CORRETAGEM,
	       SE2.E2_VLCRUZ,
		      SE2.E2_ISS,
		      SE2.E2_IRRF,
		      SE2.E2_PIS,
		      SE2.E2_COFINS,
		      SE2.E2_CIDE,
		      SE2.E2_CSLL,
		      SE2.E2_INSS,
	       E2_VENCTO AS VENCTO,
	       E2_VENCREA AS VENCTO_REAL,
	       E2_TIPO AS TIPO_TITULO,
	       E2_EMIS1 AS ACCOUNTING_DATE,
	       (E2_TXMOEDA*0) AS TAX,
           E2_ZZCTCAM AS CONTRATO,
	       E2_PARCELA AS PARCELA,
	       E2_PREFIXO AS PREFIXO,
	       E2_LOJA as LOJA
		   , ISNULL(EZ_PERC,1) as PERC_CC
		   , ISNULL(EV_PERC,1) AS PERC_NT
	FROM SE2010 SE2
	INNER JOIN SA2010 SA2
	   ON E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA
	LEFT JOIN SED010 SED ON SED.ED_CODIGO = SE2.E2_NATUREZ
		AND SED.D_E_L_E_T_ =''
LEFT JOIN SEV010 SEV ON SEV.D_E_L_E_T_ = ''
		AND SEV.EV_FILIAL	= SE2.E2_FILIAL
		AND SEV.EV_PREFIXO	= SE2.E2_PREFIXO
		AND SEV.EV_NUM		= SE2.E2_NUM
		AND SEV.EV_PARCELA	= SE2.E2_PARCELA
		AND SEV.EV_CLIFOR	= SE2.E2_FORNECE
		AND SEV.EV_LOJA		= SE2.E2_LOJA
		AND SEV.EV_TIPO		= SE2.E2_TIPO
		AND SEV.EV_RECPAG = 'P'
	LEFT JOIN SEZ010 SEZ ON SEZ.D_E_L_E_T_ = ''
		AND SEZ.EZ_FILIAL	= SEV.EV_FILIAL
		AND SEZ.EZ_PREFIXO	= SEV.EV_PREFIXO
		AND SEZ.EZ_NUM		= SEV.EV_NUM
		AND SEZ.EZ_PARCELA	= SEV.EV_PARCELA
		AND SEZ.EZ_CLIFOR	= SEV.EV_CLIFOR
		AND SEZ.EZ_LOJA		= SEV.EV_LOJA
		AND SEZ.EZ_TIPO		= SEV.EV_TIPO
		AND SEZ.EZ_NATUREZ	= SEV.EV_NATUREZ
		AND SEZ.EZ_RECPAG = SEV.EV_RECPAG
	WHERE 1=1
	  --AND SE2.E2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'
	  AND SA2.A2_EST = 'EX'
	 -- AND SE2.E2_MULTNAT = '1'
	  AND SE2.E2_SALDO > 0
	  AND SE2.D_E_L_E_T_ = ''
	) as TAB_TESTE
	GROUP BY FILIAL
	  , COMPANY
	  , CENTRO_CUSTO
		 , INVOICE
		 , TITULO
		 , HISTORICO
		 , NATUREZA
		 , TIPO
		 , SUPPLIER
		 , INTERCO
		 , CORPORATE_NAME
		 , CURRENCY_NUM
		 , CURRENCY
		 , ORIGINAL_VALUE
		 , INVOICE_DATE
		 , RATE
	  , BR_VALUE
	  , VALUE
	  , ISS
	  , PIS
	  , COFINS
	  , IRRF
	  , CIDE
	  , IOF
	  , DESP_CORRETAGEM
	  , VENCTO
	  , VENCTO_REAL
	  , TIPO_TITULO
	  , ACCOUNTING_DATE
	  , LOJA
	  , CASE_CUSTO
		 , CASE_VALOR
		 , TAX
    	 , CONTRATO
		 , PREFIXO
		 , PARCELA
		 , PERC_CC
		   , PERC_NT
		 Order by FILIAL, INVOICE, TITULO
*/
