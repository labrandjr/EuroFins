#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

Static __oTBxCanc	:= NIL
user function ConsFin()

	local cTitle       := "Processamento Movimento Financeiro"
	local bProcess     := { |oSelf| Retpor(oSelf) }
	local cDescription := "Este programa tem como objetivo realizar a geração dos movimentos financeiro do contas a receber e a pagar."
	local cPerg        := 'MOVFIN    '
	private cFunction  := ""

	cFunction  := Substr(FunName(),1,8)
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )

return()


// ----------------------------------------------------------------------------------------------------------------------------------------------------------

static function Retpor(op_Self)
	local cQuery   := ""
	local cArquivo := "c:\temp\PlanFin_BalSheet.XML"
	local cMoeda   := '1'
	local nRegs    := 0
	local nDecs    := MsDecimais(1)
	local cSheet   := "DataBase Bal Sheet"
	local cTitulo  := "Financeiro"
	// Local dOldDtBase 	:= dDataBase
	Local dOldData := dDataBase

    cArquivo := GetTempPath() + 'PlanFin_' + dtoS(dDataBase) + '_' + strTran(time(),':','') + '.xml'

	op_Self:SetRegua1(2)
	op_Self:SetRegua2(1)
	op_Self:IncRegua1("Leitura dos registros financeiro")

	cQuery := ""
	cQuery += "SELECT E1_FILIAL AS FILIAL
	cQuery += "    	, ZM_CODIGO AS LE
	cQuery += "    	, E1_CLIENTE AS CLIEFOR
	cQuery += "    	, E1_LOJA AS LOJA
	cQuery += "    	, CASE WHEN A1_XICCODE = '' THEN E1_CLIENTE ELSE A1_XICCODE END AS ICCODE
	cQuery += "    	, LTRIM(RTRIM(A1_NOME)) AS NOME
	cQuery += "    	, A1_EST AS UF
	cQuery += "    	, 'REC' AS ORIGEM
	cQuery += "    	, ltrim(rtrim(E1_PREFIXO)) AS PREFIXO
	cQuery += "    	, ltrim(rtrim(E1_NUM)) AS NUMERO
	cQuery += "    	, ltrim(rtrim(E1_PARCELA)) AS PARCELA
	cQuery += "    	, E1_TIPO AS TIPO
	cQuery += "    	, LTRIM(RTRIM(E1_HIST)) AS HISTORICO
	cQuery += "    	, E1_EMISSAO AS EMISSAO
	cQuery += "    	, E1_EMIS1 AS DT_CONTABIL
	cQuery += "    	, E1_VENCREA AS VENCTO
	cQuery += "    	, CASE E1_MOEDA WHEN 1 THEN 'BRL'
	cQuery += "    					WHEN 2 THEN 'USD'
	cQuery += "    					WHEN 4 THEN 'USD'
	cQuery += "    					WHEN 5 THEN 'EUR'
	cQuery += "    					WHEN 6 THEN 'EUR'
	cQuery += "    					WHEN 7 THEN 'CLP'
	cQuery += "    					WHEN 8 THEN 'CLP'
	cQuery += "    					WHEN 9 THEN 'GBP'
	cQuery += "    					WHEN 10 THEN 'GBP'
	cQuery += "    					WHEN 11 THEN 'SEK'
	cQuery += "    					WHEN 12 THEN 'SEK'
	cQuery += "    					WHEN 13 THEN 'CAD'
	cQuery += "    					WHEN 14 THEN 'CAD'
	cQuery += "    					WHEN 15 THEN 'NOK'
	cQuery += "    					WHEN 16 THEN 'NOK'
	cQuery += "    					WHEN 17 THEN 'CHF'
	cQuery += "    					WHEN 18 THEN 'CHF'
	cQuery += "    					WHEN 19 THEN 'DKK'
	cQuery += "    					WHEN 20 THEN 'DKK'
	cQuery += "    					WHEN 21 THEN 'NZD'
	cQuery += "    					WHEN 22 THEN 'NZD'
	cQuery += "    					WHEN 23 THEN 'ARS'
	cQuery += "    					WHEN 24 THEN 'ARS'
	cQuery += "    					WHEN 25 THEN 'AUD'
	cQuery += "    					WHEN 26 THEN 'AUD'
	cQuery += "    					ELSE 'XXX' END AS MOEDA
	cQuery += "    	, E1_VALOR * CASE WHEN E1_TIPO in ('IR-','NCC','PA','RA','NDF','NCF','IS-') THEN (-1) ELSE 1 END AS VALOR
	cQuery += "    	, E1_VLCRUZ * CASE WHEN E1_TIPO in ('IR-','NCC','PA','RA','NDF','NCF','IS-') THEN (-1) ELSE 1 END AS VALOR_RS
	cQuery += "    	, ISNULL(EZ_CCUSTO,E1_CCUSTO) AS CC
	cQuery += "    	, LTRIM(RTRIM(E1_NATUREZ)) AS NATUREZA
	cQuery += "    	, LTRIM(RTRIM(ISNULL(ED_DESCRIC,''))) AS DESC_NAT
	cQuery += "    	, CASE WHEN A1_ZZCOLIG = 'S' THEN 'SIM' ELSE 'NAO' END AS COLIGADO
	cQuery += "    	, LTRIM(RTRIM(A1_CONTA)) AS CONTA
	cQuery += "    	, E1_TXMOEDA AS FX_BACEN
	cQuery += "    	, ISNULL(EZ_PERC,1) AS RATEIO
	cQuery += "    	, SE1.R_E_C_N_O_ AS REC
	cQuery += " 	, ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	, ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	, ISNULL(EV_VALOR,0)								                    AS [VlrRatEV]
	cQuery += " 	, ISNULL(EV_PERC,0)								                        AS [PercRatEV]
	cQuery += "  FROM " + RetSqlName("SE1") + " SE1 WITH(NOLOCK)
	cQuery += "   INNER JOIN " + RetSqlName("SZM") + " SZM WITH(NOLOCK) ON SZM.D_E_L_E_T_ = '' AND ZM_FILEMP = SUBSTRING(E1_FILIAL,1,2)
	cQuery += "   INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += "    LEFT JOIN " + RetSqlName("SED") + " SED WITH(NOLOCK) ON SED.D_E_L_E_T_ = '' AND ED_CODIGO = E1_NATUREZ
	cQuery += "    LEFT JOIN " + RetSqlName("SEZ") + " SEZ WITH(NOLOCK)  ON EZ_FILIAL = E1_FILIAL
	cQuery += "             AND EZ_PREFIXO  = E1_PREFIXO
	cQuery += "             AND EZ_NUM      = E1_NUM
	cQuery += "             AND EZ_PARCELA  = E1_PARCELA
	cQuery += "             AND EZ_TIPO     = E1_TIPO
	cQuery += "             AND EZ_CLIFOR   = E1_CLIENTE
	cQuery += "             AND EZ_LOJA     = E1_LOJA
	cQuery += "             AND EZ_RECPAG   = 'R'
	cQuery += "             AND SEZ.D_E_L_E_T_ = ''
	cQuery += "  LEFT JOIN " + RetSqlName("SEV") + " SEV WITH(NOLOCK) ON SEV.D_E_L_E_T_ = ''"
	cQuery += "             AND EV_FILIAL = EZ_FILIAL
	cQuery += "             AND EV_PREFIXO = EZ_PREFIXO
	cQuery += "             AND EV_NUM = EZ_NUM
	cQuery += "             AND EV_PARCELA = EZ_PARCELA
	cQuery += "             AND EV_CLIFOR = EZ_CLIFOR
	cQuery += "             AND EV_LOJA  = EZ_LOJA
	cQuery += "             AND EV_TIPO = EZ_TIPO
	cQuery += "             AND EV_NATUREZ = EZ_NATUREZ
	cQuery += "             AND EV_RECPAG = EZ_RECPAG
	cQuery += "   LEFT JOIN " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = A1_CONTA AND CVD.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += "   WHERE SE1.D_E_L_E_T_ = ''
	cQuery += "     AND E1_FILIAL  >= '" + MV_PAR01 + "'
	cQuery += "     AND E1_FILIAL  <= '" + MV_PAR02 + "'
	cQuery += "     AND E1_EMISSAO >= '" + dTos(MV_PAR03) + "'
	cQuery += "     AND E1_EMISSAO <= '" + dTos(MV_PAR04) + "'
	cQuery += "     AND E1_VENCREA >= '" + dTos(MV_PAR05) + "'
	cQuery += "     AND E1_VENCREA <= '" + dTos(MV_PAR06) + "'
	cQuery += "     AND E1_TIPO NOT IN " + FormatIn( MVPROVIS, "|" )
	// cQuery += "     AND E1_TIPO NOT IN " + FormatIn( MVRECANT+"|"+MV_CRNEG, "|" )
	If MV_PAR07 == 2
		cQuery += " AND E1_SALDO > 0 "
	Else
		cQuery += " AND (E1_SALDO > 0 OR E1_BAIXA > '" + DToS(MV_PAR08) + "')
	EndIf
	cQuery += "     AND E1_EMIS1 >= '" + dTos(MV_PAR09) + "'
	cQuery += "     AND E1_EMIS1 <= '" + dTos(MV_PAR10) + "'
	// cQuery += "     AND E1_NUM = '309848361'
	cQuery += " UNION ALL "

	cQuery += "SELECT E2_FILIAL AS FILIAL
	cQuery += "	    , ZM_CODIGO AS LE
	cQuery += "	    , E2_FORNECE AS CLIEFOR
	cQuery += "	    , E2_LOJA AS LOJA
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "	    , A2_XICCODE AS ICCODE
	Else
		cQuery += "	    , E2_FORNECE AS ICCODE
	EndIf
	cQuery += "	    , LTRIM(RTRIM(A2_NOME)) AS NOME
	cQuery += "	    , A2_EST AS UF
	cQuery += "	    , 'PAG' AS ORIGEM
	cQuery += "	    , ltrim(rtrim(E2_PREFIXO)) AS PREFIXO
	cQuery += "	    , ltrim(rtrim(E2_NUM)) AS NUMERO
	cQuery += "	    , ltrim(rtrim(E2_PARCELA)) AS PARCELA
	cQuery += "	    , E2_TIPO AS TIPO
	cQuery += "	    , LTRIM(RTRIM(E2_HIST)) AS HISTORICO
	cQuery += "	    , E2_EMISSAO AS EMISSAO
	cQuery += "	    , E2_EMIS1 AS DT_CONTABIL
	cQuery += "	    , E2_VENCREA AS VENCTO
	cQuery += "	    , CASE E2_MOEDA WHEN 1 THEN 'BRL'
	cQuery += "	    				WHEN 2 THEN 'USD'
	cQuery += "	    				WHEN 4 THEN 'USD'
	cQuery += "	    				WHEN 5 THEN 'EUR'
	cQuery += "	    				WHEN 6 THEN 'EUR'
	cQuery += "	    				WHEN 7 THEN 'CLP'
	cQuery += "	    				WHEN 8 THEN 'CLP'
	cQuery += "	    				WHEN 9 THEN 'GBP'
	cQuery += "	    				WHEN 10 THEN 'GBP'
	cQuery += "	    				WHEN 11 THEN 'SEK'
	cQuery += "	    				WHEN 12 THEN 'SEK'
	cQuery += "	    				WHEN 13 THEN 'CAD'
	cQuery += "	    				WHEN 14 THEN 'CAD'
	cQuery += "	    				WHEN 15 THEN 'NOK'
	cQuery += "	    				WHEN 16 THEN 'NOK'
	cQuery += "	    				WHEN 17 THEN 'CHF'
	cQuery += "	    				WHEN 18 THEN 'CHF'
	cQuery += "	    				WHEN 19 THEN 'DKK'
	cQuery += "	    				WHEN 20 THEN 'DKK'
	cQuery += "	    				WHEN 21 THEN 'NZD'
	cQuery += "	    				WHEN 22 THEN 'NZD'
	cQuery += "	    				WHEN 23 THEN 'ARS'
	cQuery += "	    				WHEN 24 THEN 'ARS'
	cQuery += "	    				WHEN 25 THEN 'AUD'
	cQuery += "	    				WHEN 26 THEN 'AUD'
	cQuery += "	    				ELSE 'XXX' END AS MOEDA
	cQuery += "	    , E2_VALOR * CASE WHEN E2_TIPO in ('IR-','NCC','PA','RA','NDF','NCF','IS-') THEN (-1) ELSE 1 END AS VALOR
	cQuery += "	    , E2_VLCRUZ * CASE WHEN E2_TIPO in ('IR-','NCC','PA','RA','NDF','NCF','IS-') THEN (-1) ELSE 1 END AS VALOR_RS
	cQuery += "	    , ISNULL(EZ_CCUSTO,E2_CCUSTO)  AS CC
	cQuery += "	    , LTRIM(RTRIM(E2_NATUREZ)) AS NATUREZA
	cQuery += "	    , LTRIM(RTRIM(ISNULL(ED_DESCRIC,''))) AS DESC_NAT
	cQuery += "	    , CASE WHEN A2_ZZCOLIG = 'S' THEN 'SIM' ELSE 'NAO' END AS COLIGADO
	cQuery += "	    , LTRIM(RTRIM(A2_CONTA)) AS CONTA
	cQuery += "	    , E2_TXMOEDA AS FX_BACEN
	cQuery += "    	, ISNULL(EZ_PERC,1) AS RATEIO
	cQuery += "	    , SE2.R_E_C_N_O_ AS REC
	cQuery += " 	, ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	, ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	, ISNULL(EV_VALOR,0)								                    AS [VlrRatEV]
	cQuery += " 	, ISNULL(EV_PERC,0)								                        AS [PercRatEV]
	cQuery += " FROM " + RetSqlName("SE2") + " SE2 WITH(NOLOCK)
	cQuery += "  INNER JOIN " + RetSqlName("SZM") + " SZM WITH(NOLOCK) ON SZM.D_E_L_E_T_ = '' AND ZM_FILEMP = SUBSTRING(E2_FILIAL,1,2)
	cQuery += "  INNER JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
	cQuery += "   LEFT JOIN " + RetSqlName("SED") + " SED WITH(NOLOCK) ON SED.D_E_L_E_T_ = '' AND ED_CODIGO = E2_NATUREZ
	cQuery += "   LEFT JOIN " + RetSqlName("SEZ") + " SEZ WITH(NOLOCK)  ON EZ_FILIAL = E2_FILIAL
	cQuery += "             AND EZ_PREFIXO  = E2_PREFIXO
	cQuery += "             AND EZ_NUM      = E2_NUM
	cQuery += "             AND EZ_PARCELA  = E2_PARCELA
	cQuery += "             AND EZ_TIPO     = E2_TIPO
	cQuery += "             AND EZ_CLIFOR   = E2_FORNECE
	cQuery += "             AND EZ_LOJA     = E2_LOJA
	cQuery += "             AND EZ_RECPAG   = 'P'
	cQuery += "             AND SEZ.D_E_L_E_T_ = ''
	cQuery += "  LEFT JOIN " + RetSqlName("SEV") + " SEV WITH(NOLOCK) ON SEV.D_E_L_E_T_ = ''"
	cQuery += "             AND EV_FILIAL = EZ_FILIAL
	cQuery += "             AND EV_PREFIXO = EZ_PREFIXO
	cQuery += "             AND EV_NUM = EZ_NUM
	cQuery += "             AND EV_PARCELA = EZ_PARCELA
	cQuery += "             AND EV_CLIFOR = EZ_CLIFOR
	cQuery += "             AND EV_LOJA  = EZ_LOJA
	cQuery += "             AND EV_TIPO = EZ_TIPO
	cQuery += "             AND EV_NATUREZ = EZ_NATUREZ
	cQuery += "             AND EV_RECPAG = EZ_RECPAG
	cQuery += "   LEFT JOIN " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = A2_CONTA AND CVD.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += "  WHERE SE2.D_E_L_E_T_ = ''
	cQuery += "    AND E2_FILIAL  >= '" + MV_PAR01 + "'
	cQuery += "    AND E2_FILIAL  <= '" + MV_PAR02 + "'
	cQuery += "    AND E2_EMISSAO >= '" + dTos(MV_PAR03) + "'
	cQuery += "    AND E2_EMISSAO <= '" + dTos(MV_PAR04) + "'
	cQuery += "    AND E2_VENCREA >= '" + dTos(MV_PAR05) + "'
	cQuery += "    AND E2_VENCREA <= '" + dTos(MV_PAR06) + "'
	cQuery += "    AND E2_TIPO NOT IN " + FormatIn(MVABATIM,"|")
	cQuery += "    AND E2_TIPO NOT IN " + FormatIn(MVPROVIS,";")
	// cQuery += "    AND E2_TIPO NOT IN "+FormatIn(MVPAGANT,";")
	// cQuery += "    AND E2_TIPO NOT IN "+FormatIn(MV_CPNEG,"|")
	// cQuery += "    AND E2_NUM = '000001143' AND E2_TIPO = 'INV' AND E2_PARCELA = '01'
	If MV_PAR07 == 2
		cQuery += " AND E2_SALDO > 0 "
	Else
		cQuery += " AND (E2_SALDO > 0 OR E2_BAIXA > '" + DToS(MV_PAR08) + "')
	EndIf
	cQuery += "     AND E2_EMIS1 >= '" + dTos(MV_PAR09) + "'
	cQuery += "     AND E2_EMIS1 <= '" + dTos(MV_PAR10) + "'
	// cQuery += "      AND E2_NUM = '000000080' AND E2_EMISSAO = '20230223'
	TcQuery  cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	Count to nRegs
	op_Self:SetRegua2(nRegs)
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())

		If file(cArquivo)
			FERASE(cArquivo)
		EndIf
		If __oTBxCanc <> Nil
			__oTBxCanc:Destroy()
			__oTBxCanc := Nil
		EndIf
		__oTBxCanc	:= FwPreparedStatement():New("")


		lSE2FilCom := Empty(FwXFilial("SE2"))
		lSE5FilCom := Empty(FwXFilial("SE5"))

		oFWMsExcel := FWMsExcelEx():New()

		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitulo)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"FILIAL" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"LE" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"COD CLI/FORN" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"LOJA" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"I/C CODE" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NOME" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"UF" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"ORIGEM" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PREFIXO" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NUMERO" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PARCELA" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"TIPO" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"HISTORICO" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DT EMISSAO" ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DT CONTABIL" ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DT VENCTO" ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"MOEDA" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VLR. TITULO" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"SALDO" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VLR. TITULO R$" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"SALDO R$" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NATUREZA" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DESC. NATUREZA" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"EMP. COLIGADA" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"CONTA CONTABIL" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"CONTROL CODE" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DESC. CONTROL CODE",1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"CENTRO DE CUSTO",1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"FX BACEN" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VALOR FULL" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VALOR FULL R$" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VALOR CORRIGIDO" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VALOR CORRIGIDO R$" ,1,2)
		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando titulo " + (cTRB)->NUMERO + "...")
            dDataBase := dOldData
			If (cTRB)->ORIGEM == 'REC'
				dDataBase := MV_PAR08
				dbSelectArea("SE1")
				SE1->(dbGoTo((cTRB)->REC))
				dDataReaj := dDataBase

				cPrefixo  := SE1->E1_PREFIXO
				cTipo     := SE1->E1_TIPO
				cNum      := SE1->E1_NUM
				cParcela  := SE1->E1_PARCELA
				dDataReaj := dDataBase

				cFilSE5 := (cTRB)->FILIAL
				If SE1->E1_VENCREA < dDataBase .And. RecMoeda(SE1->E1_VENCREA,cMoeda) > 0
					dDataReaj := SE1->E1_VENCREA
				EndIf

				nTaxaDia := Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA))
				If MV_PAR07 == 1
					nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataReaj,;
						MV_PAR08, SE1->E1_LOJA,	cFilSE5 , 1, 1)

					// nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, 1, dDataReaj,;
						// MV_PAR08, SE1->E1_LOJA,	cFilSE5 , nTaxaDia, 1)

				Else
					nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,1,dDataReaj,ndecs+1,nTaxaDia)
				EndIf
			Else
				dDataBase := MV_PAR08
				dbSelectArea("SE2")
				SE2->(dbGoTo((cTRB)->REC))

				cPrefixo  := SE2->E2_PREFIXO
				cTipo     := SE2->E2_TIPO
				cNum      := SE2->E2_NUM
				cParcela  := SE2->E2_PARCELA
				dDataReaj := dDataBase

				If SE2->E2_VENCREA < dDataBase .and. RecMoeda(SE2->E2_VENCREA,cMoeda) > 0
					dDataReaj := SE2->E2_VENCREA
				EndIf
				lCmpMulFil := .F.
				cFilSE5 := (cTRB)->FILIAL
				// lSemTaxaM2 := (nTaxaDia := RecMoeda(dDataReaj,SE2->E2_MOEDA)) == 0
				lSemTaxaM2 := (nTaxaDia := Iif(!Empty(SE2->E2_TXMOEDA),SE2->E2_TXMOEDA,RecMoeda(dDataReaj,SE2->E2_MOEDA))) == 0
				If MV_PAR07 == 1
					nSaldo := SaldoTit(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, "P", SE2->E2_FORNECE, SE2->E2_MOEDA ,dDataReaj,, SE2->E2_LOJA,cFilSE5,;
						Iif(lSemTaxaM2,1,nTaxaDia), 1,,__oTBxCanc, Nil, @lCmpMulFil)
					If lCmpMulFil .And. !lSE2FilCom .And. !lSE5FilCom
						nSaldo -= FRVlCompFil("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,1,,,,1,SE2->E2_MOEDA,If(lSemTaxaM2,1,nTaxaDia),dDataReaj,.T.)
					EndIf

					If !(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) .And. !(SE2->E2_TIPO $ MVABATIM) .And. !(SE2->E2_TIPO $ MVPAGANT+"/"+MVPROVIS+"/"+MV_CPNEG) .and. nSaldo > 0
						nSaldo -= SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataReaj,SE2->E2_FORNECE,SE2->E2_LOJA)
					EndIf
				Else
					nSaldo := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,1,dDataReaj,ndecs+1,SE2->E2_TXMOEDA)
				EndIf
			EndIf


			nVarRS    := 0
			nVarMoeda := 0

			cQuery := ""
			cQuery += " SELECT SUM(E5_VALOR) VARCAMB_RS, SUM(E5_VLMOED2) VARCAMB FROM " + RetSqlName("SE5") + " SE5 with(nolock) WHERE SE5.D_E_L_E_T_= ''
			cQuery += " AND E5_FILIAL = '" + (cTRB)->FILIAL + "'
			cQuery += " AND E5_PREFIXO = '" + cPrefixo + "'
			cQuery += " AND E5_TIPO = '" + cTipo + "'
			cQuery += " AND E5_NUMERO = '" + cNum + "'
			cQuery += " AND E5_PARCELA = '" + cParcela + "'
			cQuery += " AND E5_CLIFOR = '" + (cTRB)->CLIEFOR + "'
			cQuery += " AND E5_LOJA = '" + (cTRB)->LOJA + "'
			cQuery += " AND E5_TIPODOC = 'VM'
			cQuery += " AND E5_DATA <= '" + DToS(MV_PAR08) + "'
			TcQuery cQuery New Alias (cTRBVC := GetNextAlias())

			dbSelectArea((cTRBVC))
			If (cTRBVC)->(!eof())
				nVarRS    := (cTRBVC)->VARCAMB_RS
				nVarMoeda := (cTRBVC)->VARCAMB
			EndIf
			(cTRBVC)->(dbCloseArea())


			If nSaldo != 0
                nValorX := iif(Empty((cTRB)->VlrRatEV),(cTRB)->VALOR,(cTRB)->VlrRatEV)
                nValorRSX := iif(Empty((cTRB)->VlrRatEV),(cTRB)->VALOR_RS,(cTRB)->VlrRatEV * nTaxaDia) //round((cTRB)->VALOR_RS * (cTRB)->RATEIO,2)

                nSaldo := iif(Empty((cTRB)->VlrRatEV), nSaldo, nSaldo * (cTRB)->PercRatEV)

				If (cTRB)->TIPO $ 'IR-#NCC#PA#RA#NDF#NCF#IS-'
					nSaldo := nSaldo * (-1)
				EndIf

				oFWMsExcel:AddRow("DataBase Bal Sheet","Financeiro",{(cTRB)->FILIAL,;
					(cTRB)->LE,;
					(cTRB)->CLIEFOR,;
					(cTRB)->LOJA,;
					(cTRB)->ICCODE,;
					(cTRB)->NOME,;
					(cTRB)->UF,;
					(cTRB)->ORIGEM,;
					(cTRB)->PREFIXO,;
					(cTRB)->NUMERO,;
					(cTRB)->PARCELA,;
					(cTRB)->TIPO,;
					(cTRB)->HISTORICO,;
					sTod((cTRB)->EMISSAO),;
					sTod((cTRB)->DT_CONTABIL),;
					sTod((cTRB)->VENCTO),;
					(cTRB)->MOEDA,;
					round(nValorX * (cTRB)->RATEIO,2),;
					round(nSaldo * (cTRB)->RATEIO,2),;
					round(nValorRSX,2),;
					round(((nSaldo * nTaxaDia) * (cTRB)->RATEIO),2),;
					(cTRB)->NATUREZA,;
					(cTRB)->DESC_NAT,;
					(cTRB)->COLIGADO,;
					(cTRB)->CONTA,;
					(cTRB)->ControlCode,;
					(cTRB)->DescCtrlCode,;
					(cTRB)->CC,;
					(cTRB)->FX_BACEN,;
					(cTRB)->VALOR,;
					(cTRB)->VALOR_RS,;
					round((nSaldo + nVarMoeda) * (cTRB)->RATEIO,2),;
					round(((nSaldo * nTaxaDia) + nVarRS ) * (cTRB)->RATEIO,2)})
			EndIf

			(cTRB)->(dbSkip())
		EndDo

		op_Self:IncRegua1("Exportando registro Excel")
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)
		If ApOleClient("MSEXCEL")
			//Abrindo o excel e abrindo o arquivo xml
			oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
			oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
			oExcel:SetVisible(.T.)              //Visualiza a planilha
			oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
		EndIf
		dDataBase := dOldData
	EndIf

	(cTRB)->(dbCloseArea())

return()
