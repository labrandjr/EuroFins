#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

user function db_IS()

	local cTitle       := "Processamento Movimento Financeiro"
	local bProcess     := { |oSelf| Retpor(oSelf) }
	local cDescription := "Este programa tem como objetivo realizar a geração dos movimentos contabeis x financeiro."
	local cPerg        := 'MOVFINI_IS'
	private cFunction  := ""

	cFunction  := Substr(FunName(),1,8)
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )

return()


// ----------------------------------------------------------------------------------------------------------------------------------------------------------

static function Retpor(op_Self)
	local cQuery   := ""
	local cArquivo := "c:\temp\PlanFin_DBIS.XML"
	local nRegs    := 0
	local cSheet   := "DataBase IS"
	local cTitPlan := "Financeiro"

	cArquivo := GetTempPath() + 'PlanFin_DBIS_' + dtoS(dDataBase) + '_' + strTran(time(),':','') + '.xml'


	op_Self:SetRegua1(2)
	op_Self:SetRegua2(1)
	op_Self:IncRegua1("Leitura dos registros financeiro")

	cQuery := ""
	cQuery += "  SELECT CT2_FILIAL as [FILIAL]
	cQuery += "  	  , ZM_CODIGO as [COMPANY]
	cQuery += "  	  , CT2_DATA as [DATA_CTB]
	cQuery += "       , CT2_LOTE AS LOTE
	cQuery += "  	  , CT2_CREDIT AS [CONTA]
	cQuery += "       , LTRIM(RTRIM(CT1_DESC01)) AS [DESCT_CTA]
	cQuery += "       , CT2_VALOR *-1 AS [VALOR]
	cQuery += "       , CT2_HIST AS HIST_CTB
	cQuery += "       , CT2_CCC AS [CC]
	cQuery += "       , CT2_TPSALD AS TPSALDO
	cQuery += "       , CT2_ORIGEM AS ORIGEM_CTB
	cQuery += "       , SUBSTRING(CT2_DATA,1,6) AS PERIODO
	cQuery += "       , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')	AS CTRL_CODE
	cQuery += "       , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')	AS DESC_CODE
	cQuery += "       , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS PESQ_CTB
	cQuery += "       , CT2_DEBITO AS CTR_PARTIDA
	cQuery += "       , CT2_LP AS LP
	cQuery += "       , CTL_ALIAS AS ALIAS_CTL
	cQuery += "       , CTL_ORDER AS ORDEM
	cQuery += "       , CT2_KEY AS SEEK
	cQuery += "       , -1 AS FATOR
	cQuery += "       , CT2_AT02DB AS CLI_FOR
	cQuery += "       , CT2_ITEMC AS ITEM_CTBL
	cQuery += "       , ISNULL(CTD_DESC01, '') AS ITEM_CTBL_DESC
	cQuery += "   FROM CT2010 CT2 WITH(NOLOCK)
	cQuery += " INNER JOIN CT1010 CT1 WITH(NOLOCK) ON CT1.D_E_L_E_T_ = '' AND CT1_CONTA = CT2_CREDIT
	cQuery += " INNER JOIN SZM010 SZM WITH(NOLOCK) ON SZM.D_E_L_E_T_ = '' AND ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)
	cQuery += " INNER JOIN CVD010 CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += "  AND CVD_CTAREF IN('33000-62','34091','34092','41090','41090-80','41095','44290',
	cQuery += " '47990','60090','50090','61092','50092','60095','50095','61096',
	cQuery += " '61392','50392','63190','63191','62590','62591','64190','64191',
	cQuery += " '64192','64193','64194','64195','64090','64091','64092','50096',
	cQuery += " '64093','64094','64095','64491','64492','64493','64494','64497',
	cQuery += " '64498','75090','75091','75092','75093','75094','71090','73090')
	cQuery += "  LEFT JOIN  CVN010  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += "  LEFT JOIN CTL010 CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "  LEFT JOIN CTD010 CTD1 WITH(NOLOCK) ON CTD1.D_E_L_E_T_ = ''  AND CTD1.CTD_ITEM = CT2_ITEMC
	cQuery += " WHERE CT2.D_E_L_E_T_ = ''
	cQuery += " AND CT2_DC IN ('2','3')
	cQuery += " AND SUBSTRING(CT2_DATA,1,4) >= (
	cQuery += " SELECT MIN(SUBSTRING(CTG_DTINI,1,4)) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " AND CTG_STATUS = '1'
	cQuery += " )
	cQuery += " AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += "  AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += "  AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += "  AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += "  AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += " "
	cQuery += " union all
	cQuery += " "
	cQuery += " SELECT CT2_FILIAL as [FILIAL]
	cQuery += " 	 , ZM_CODIGO as [COMPANY]
	cQuery += " 	 , CT2_DATA as [DATA_CTB]
	cQuery += "      , CT2_LOTE AS LOTE
	cQuery += " 	 , CT2_DEBITO AS [CONTA]
	cQuery += "      , LTRIM(RTRIM(CT1_DESC01)) AS [DESCT_CTA]
	cQuery += "      , CT2_VALOR AS [VALOR]
	cQuery += "      , CT2_HIST AS HIST_CTB
	cQuery += "      , CT2_CCD AS [CC]
	cQuery += "      , CT2_TPSALD AS TPSALDO
	cQuery += "      , CT2_ORIGEM AS ORIGEM_CTB
	cQuery += "      , SUBSTRING(CT2_DATA,1,6) AS PERIODO
	cQuery += "      , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')	AS CTRL_CODE
	cQuery += "      , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')	AS DESC_CODE
	cQuery += "      , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS PESQ_CTB
	cQuery += "      , CT2_CREDIT AS CTR_PARTIDA
	cQuery += "      , CT2_LP AS LP
	cQuery += "      , CTL_ALIAS AS ALIAS_CTL
	cQuery += "      , CTL_ORDER AS ORDEM
	cQuery += "      , CT2_KEY AS SEEK
	cQuery += "      , 1 AS FATOR
	cQuery += "      , CT2_AT02DB AS CLI_FOR
	cQuery += "      , CT2_ITEMD AS ITEM_CTBL
	cQuery += "      , ISNULL(CTD_DESC01, '') AS ITEM_CTBL_DESC
	cQuery += "   FROM CT2010 CT2 WITH(NOLOCK)
	cQuery += " INNER JOIN CT1010 CT1 WITH(NOLOCK) ON CT1.D_E_L_E_T_ = '' AND CT1_CONTA = CT2_DEBITO
	cQuery += " INNER JOIN SZM010 SZM WITH(NOLOCK) ON SZM.D_E_L_E_T_ = '' AND ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)
	cQuery += " INNER JOIN CVD010 CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += "  AND CVD_CTAREF IN('33000-62','34091','34092','41090','41090-80','41095','44290',
	cQuery += " '47990','60090','50090','61092','50092','60095','50095','61096',
	cQuery += " '61392','50392','63190','63191','62590','62591','64190','64191',
	cQuery += " '64192','64193','64194','64195','64090','64091','64092','50096',
	cQuery += " '64093','64094','64095','64491','64492','64493','64494','64497',
	cQuery += " '64498','75090','75091','75092','75093','75094','71090','73090')
	cQuery += "  LEFT JOIN  CVN010  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += "  LEFT JOIN CTL010 CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "  LEFT JOIN CTD010 CTD2 WITH(NOLOCK) ON CTD2.D_E_L_E_T_ = ''  AND CTD2.CTD_ITEM = CT2_ITEMD
	cQuery += " WHERE CT2.D_E_L_E_T_ = ''
	cQuery += " AND CT2_DC IN ('1','3')
	cQuery += " AND SUBSTRING(CT2_DATA,1,4) >= (
	cQuery += " SELECT MIN(SUBSTRING(CTG_DTINI,1,4)) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " AND CTG_STATUS = '1'
	cQuery += " )
	cQuery += " AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += "  AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += "  AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += "  AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += "  AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	Count to nRegs
	op_Self:SetRegua2(nRegs)
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())

		If file(cArquivo)
			FERASE(cArquivo)
		EndIf

		oFWMsExcel := FWMsExcelEx():New()

		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitPlan)

		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Filial"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Reporting Company"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Data Movimento"               ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Lote Contabil"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Conta"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Desc. Conta"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Valor em BRL (CTB)"           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Historico"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Centro Custo"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Tipo Saldo"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Origem Ctb"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Periodo"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Conta Controle"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Desc. C. Controle"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Pesquisa"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Contra Partida"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"LP"                           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Prefixo"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Num. Titulo"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Parcela"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Tipo"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Emissao"                      ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Natureza"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Valor em ME"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Moeda Titulo Fin."            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Taxa Moeda"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Cliente"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Loja"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"IC Code"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Nome Cliente"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Historico Fin."               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Cli. - For."                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Rec. - Pag."                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Item Contábil"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Descrição Item Contábil"      ,1,1)

		while (cTRB)->(!eof())

			cString   := (cTRB)->ALIAS_CTL
			nOrder    := (cTRB)->ORDEM
			cSeek     := alltrim((cTRB)->SEEK)

			cCodIC    := ""
			cCodigo   := ""
			cLoja     := ""
			cNome     := ""

			If !Empty((cTRB)->CLI_FOR)
				If substring((cTRB)->CTR_PARTIDA,1,1) == '2'
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))
					If (dbSeek(FWxFilial("SA2") + Substr((cTRB)->CLI_FOR,1,6) + substr((cTRB)->CLI_FOR,8,2)))
						cCodIC    := IIF(Empty(SA2->A2_XICCODE), SA2->A2_COD, SA2->A2_XICCODE)
						cCodigo   := SA2->A2_COD
						cLoja     := SA2->A2_LOJA
						cNome     := SA2->A2_NREDUZ
					EndIf
				ElseIf substring((cTRB)->CTR_PARTIDA,1,1) == '1'
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					If (dbSeek(FWxFilial("SA1") + Substr((cTRB)->CLI_FOR,1,6) + substr((cTRB)->CLI_FOR,8,2)))
						cCodIC    := IIF(Empty(SA1->A1_XICCODE), SA1->A1_COD, SA1->A1_XICCODE)
						cCodigo   := SA1->A1_COD
						cLoja     := SA1->A1_LOJA
						cNome     := SA1->A1_NREDUZ
					EndIf
				EndIf

			EndIf


			cPrefixo  := ""
			cTitulo   := ""
			cParcela  := ""
			cTipo     := ""
			cHistFin  := ""
			cMoeda    := "" //retMoeda(cp_Moeda)
			nValor_ME := 0
			nValor    := 0
			dEmissao  := cTod("")
			cNatureza := ""
			nTaxa     := 0
			nMoedAx   := ''
			cCliFor   := ""
			cRecPag   := ""

			If !Empty(cSeek)
				dbSelectArea(cString)
				dbSetOrder(val(nOrder))
				dbSeek(cSeek)

				If cString == 'SE1'

					SA1->(dbSetOrder(1), dbSeek(FWxFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))

					cCodIC    := IIF(Empty(SA1->A1_XICCODE), SA1->A1_COD, SA1->A1_XICCODE)
					cCodigo   := SE1->E1_CLIENTE
					cLoja     := SE1->E1_LOJA
					cNome     := SE1->E1_NOMCLI
					cPrefixo  := SE1->E1_PREFIXO
					cTitulo   := SE1->E1_NUM
					cParcela  := SE1->E1_PARCELA
					cTipo     := SE1->E1_TIPO
					cHistFin  := SE1->E1_HIST
					nMoedAx   := SE1->E1_MOEDA
					cMoeda    := retMoeda(cvalToChar(SE1->E1_MOEDA))
					nValor_ME := SE1->E1_VALOR
					dEmissao  := SE1->E1_EMISSAO
					cNatureza := SE1->E1_NATUREZ
					nTaxa     := SE1->E1_TXMOEDA

					cCliFor   := 'Cli'
					cRecPag   := "Rec"

				ElseIf cString == 'SE2'

					SA2->(dbSetOrder(1), dbSeek(FWxFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA)))

					cCodIC    := IIF(Empty(SA2->A2_XICCODE), SA2->A2_COD, SA2->A2_XICCODE)

					// iF SE2->E2_NUM == '071034951'
					// 	CXXX := ""
					// eNDiF

					cCodigo   := SE2->E2_FORNECE
					cLoja     := SE2->E2_LOJA
					cNome     := SE2->E2_NOMFOR
					cPrefixo  := SE2->E2_PREFIXO
					cTitulo   := SE2->E2_NUM
					cParcela  := SE2->E2_PARCELA
					cTipo     := SE2->E2_TIPO
					cHistFin  := SE2->E2_HIST
					nMoedAx   := SE2->E2_MOEDA
					cMoeda    := retMoeda(cvalToChar(SE2->E2_MOEDA))
					nValor_ME := SE2->E2_VALOR + SE2->E2_IRRF
					dEmissao  := SE2->E2_EMISSAO
					cNatureza := SE2->E2_NATUREZ
					nTaxa     := SE2->E2_TXMOEDA

					cCliFor   := 'For'
					cRecPag   := "Pag"

				ElseIf cString == 'SE5'

					IF SE5->E5_RECPAG == 'P'
						cCliFor := 'For'
						cRecPag := "Pag"
						SA2->(dbSetOrder(1), dbSeek(FWxFilial("SA2") + SE5->(E5_CLIFOR + E5_LOJA)))
						cCodIC  := IIF(Empty(SA2->A2_XICCODE), SA2->A2_COD, SA2->A2_XICCODE)

						SE2->(dbSetOrder(1), dbSeek(SE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA)))
						cMoeda    := retMoeda(cvalToChar(SE2->E2_MOEDA))
						nMoedAx   := SE2->E2_MOEDA
						nTaxa     := iif(Empty(SE5->E5_TXMOEDA),SE2->E2_TXMOEDA,SE5->E5_TXMOEDA)
						// iF SE2->E2_NUM == '071034951'
						// 	CXXX := ""
						// eNDiF

					Else
						cCliFor := 'Cli'
						cRecPag := "Rec"
						SA1->(dbSetOrder(1), dbSeek(FWxFilial("SA1") + SE5->(E5_CLIFOR + E5_LOJA)))
						cCodIC  := IIF(Empty(SA1->A1_XICCODE), SA1->A1_COD, SA1->A1_XICCODE)

						SE1->(dbSetOrder(2), dbSeek(SE5->(E5_FILIAL +E5_CLIFOR + E5_LOJA + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO  )))
						cMoeda    := retMoeda(cvalToChar(SE1->E1_MOEDA))
						nMoedAx   := SE1->E1_MOEDA
						nTaxa     := iif(Empty(SE5->E5_TXMOEDA),SE1->E1_TXMOEDA,SE5->E5_TXMOEDA)
					EndIf


					cCodigo   := SE5->E5_CLIFOR
					cLoja     := SE5->E5_LOJA
					cNome     := SE5->E5_BENEF
					cPrefixo  := SE5->E5_PREFIXO
					cTitulo   := SE5->E5_NUMERO
					cParcela  := SE5->E5_PARCELA
					cTipo     := SE5->E5_TIPO
					cHistFin  := SE5->E5_HISTOR


					nValor_ME := SE5->E5_VLMOED2
					dEmissao  := SE5->E5_DATA
					cNatureza := SE5->E5_NATUREZ



				ElseIf cString == 'SD2'

					cQuery := ""
					cQuery += " SELECT E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_PREFIXO, E1_NUM, E1_PARCELA
					cQuery += "      , E1_TIPO, E1_HIST, E1_MOEDA, E1_EMISSAO, E1_NATUREZ, E1_TXMOEDA, SUM(E1_VALOR + E1_IRRF) AS E1_VALOR
					cQuery += "  FROM " + RetSqlName("SE1") + " SE1 WITH(NOLOCK) "
					cQuery += " WHERE E1_FILIAL = '" + SD2->D2_FILIAL + "'
					cQuery += "   AND E1_CLIENTE = '" + SD2->D2_CLIENTE + "'
					cQuery += "   AND E1_LOJA = '" + SD2->D2_LOJA + "'
					cQuery += "   AND E1_PREFIXO = '" + SD2->D2_SERIE + "'
					cQuery += "   AND E1_NUM = '" + SD2->D2_DOC + "'
					cQuery += "   AND E1_TIPO != 'TX'
					cQuery += "   AND SE1.D_E_L_E_T_ = ''
					cQuery += " GROUP BY E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_PREFIXO, E1_NUM, E1_PARCELA
					cQuery += "      , E1_TIPO, E1_HIST, E1_MOEDA, E1_EMISSAO, E1_NATUREZ, E1_TXMOEDA
					TcQuery cQuery New Alias (cTRX := GetNextAlias())

					dbSelectArea((cTRX))
					(cTRX)->(dbGoTop())
					If (cTRX)->(!eof())
						SA1->(dbSetOrder(1), dbSeek(FWxFilial("SA1") + (cTRX)->(E1_CLIENTE + E1_LOJA)))

						cCodIC    := IIF(Empty(SA1->A1_XICCODE), SA1->A1_COD, SA1->A1_XICCODE)
						cCodigo   := (cTRX)->E1_CLIENTE
						cLoja     := (cTRX)->E1_LOJA
						cNome     := (cTRX)->E1_NOMCLI
						cPrefixo  := (cTRX)->E1_PREFIXO
						cTitulo   := (cTRX)->E1_NUM
						cParcela  := (cTRX)->E1_PARCELA
						cTipo     := (cTRX)->E1_TIPO
						cHistFin  := (cTRX)->E1_HIST
						nMoedAx   := (cTRX)->E1_MOEDA
						cMoeda    := retMoeda(cvalToChar((cTRX)->E1_MOEDA))
						nValor_ME := (cTRX)->E1_VALOR
						dEmissao  := sTod((cTRX)->E1_EMISSAO)
						cNatureza := (cTRX)->E1_NATUREZ
						nTaxa     := (cTRX)->E1_TXMOEDA
						cCliFor   := 'Cli'
						cRecPag   := "Rec"
					EndIf
					(cTRX)->(dbCloseArea())

					// dbSelectArea("SE1")
					// dbSetOrder(2)//E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
					// If dbSeek(FWxFilial("SE1") + SD2->(D2_CLIENTE + D2_LOJA + D2_SERIE + D2_DOC))

					// 	SA1->(dbSetOrder(1), dbSeek(FWxFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))

					// 	cCodIC    := IIF(Empty(SA1->A1_XICCODE), SA1->A1_COD, SA1->A1_XICCODE)
					// 	cCodigo   := SE1->E1_CLIENTE
					// 	cLoja     := SE1->E1_LOJA
					// 	cNome     := SE1->E1_NOMCLI
					// 	cPrefixo  := SE1->E1_PREFIXO
					// 	cTitulo   := SE1->E1_NUM
					// 	cParcela  := SE1->E1_PARCELA
					// 	cTipo     := SE1->E1_TIPO
					// 	cHistFin  := SE1->E1_HIST
					// 	cMoeda    := retMoeda(cvalToChar(SE1->E1_MOEDA))
					// 	nValor_ME := SE1->E1_VALOR
					// 	dEmissao  := SE1->E1_EMISSAO
					// 	cNatureza := SE1->E1_NATUREZ
					// 	nTaxa     := SE1->E1_TXMOEDA
					// 	cCliFor   := 'Cli'
					// 	cRecPag   := "Rec"
					// EndIf

				ElseIf cString == 'SD1'

					cQuery := ""
					cQuery += " SELECT E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA
					cQuery += "      , E2_TIPO, E2_HIST, E2_MOEDA, E2_EMISSAO, E2_NATUREZ, E2_TXMOEDA, SUM(E2_VALOR + E2_IRRF) AS E2_VALOR
					cQuery += "  FROM " + RetSqlName("SE2") + " SE2 WITH(NOLOCK) "
					cQuery += " WHERE E2_FILIAL = '" + SD1->D1_FILIAL + "'
					cQuery += "   AND E2_FORNECE = '" + SD1->D1_FORNECE + "'
					cQuery += "   AND E2_LOJA = '" + SD1->D1_LOJA + "'
					cQuery += "   AND E2_PREFIXO = '" + SD1->D1_SERIE + "'
					cQuery += "   AND E2_NUM = '" + SD1->D1_DOC + "'
					cQuery += "   AND E2_TIPO != 'TX'
					cQuery += "   AND SE2.D_E_L_E_T_ = ''
					cQuery += " GROUP BY E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA
					cQuery += "      , E2_TIPO, E2_HIST, E2_MOEDA, E2_EMISSAO, E2_NATUREZ, E2_TXMOEDA
					TcQuery cQuery New Alias (cTRX := GetNextAlias())



					dbSelectArea((cTRX))
					(cTRX)->(dbGoTop())
					If (cTRX)->(!eof())
						SA2->(dbSetOrder(1), dbSeek(FWxFilial("SA2") + (cTRX)->(E2_FORNECE + E2_LOJA)))

						// iF (cTRX)->E2_NUM == '071034951'
						// 	CXXX := ""
						// eNDiF

						cCodIC    := IIF(Empty(SA2->A2_XICCODE), SA2->A2_COD, SA2->A2_XICCODE)
						cCodigo   := (cTRX)->E2_FORNECE
						cLoja     := (cTRX)->E2_LOJA
						cNome     := (cTRX)->E2_NOMFOR
						cPrefixo  := (cTRX)->E2_PREFIXO
						cTitulo   := (cTRX)->E2_NUM
						cParcela  := (cTRX)->E2_PARCELA
						cTipo     := (cTRX)->E2_TIPO
						cHistFin  := (cTRX)->E2_HIST
						nMoedAx   := (cTRX)->E2_MOEDA
						cMoeda    := retMoeda(cvalToChar((cTRX)->E2_MOEDA))
						nValor_ME := (cTRX)->E2_VALOR
						dEmissao  := sTod((cTRX)->E2_EMISSAO)
						cNatureza := (cTRX)->E2_NATUREZ
						nTaxa     := (cTRX)->E2_TXMOEDA
						cCliFor   := 'For'
						cRecPag   := "Pag"
					EndIf
					(cTRX)->(dbCloseArea())

					// dbSelectArea("SE2")
					// dbSetOrder(6)//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
					// If dbSeek(FWxFilial("SE2") + SD1->(D1_FORNECE + D1_LOJA + D1_SERIE + D1_DOC))

					// 	SA2->(dbSetOrder(1), dbSeek(FWxFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA)))

					// 	cCodIC    := IIF(Empty(SA2->A2_XICCODE), SA2->A2_COD, SA2->A2_XICCODE)

					// 	cCodigo   := SE2->E2_FORNECE
					// 	cLoja     := SE2->E2_LOJA
					// 	cNome     := SE2->E2_NOMFOR
					// 	cPrefixo  := SE2->E2_PREFIXO
					// 	cTitulo   := SE2->E2_NUM
					// 	cParcela  := SE2->E2_PARCELA
					// 	cTipo     := SE2->E2_TIPO
					// 	cHistFin  := SE2->E2_HIST
					// 	cMoeda    := retMoeda(cvalToChar(SE2->E2_MOEDA))
					// 	nValor_ME := SE2->E2_VALOR + SE2->E2_IRRF
					// 	dEmissao  := SE2->E2_EMISSAO
					// 	cNatureza := SE2->E2_NATUREZ
					// 	nTaxa     := SE2->E2_TXMOEDA
					// 	cCliFor   := 'For'
					// 	cRecPag   := "Pag"

					// EndIf

				ElseIf cString == 'SEZ'

					If SEZ->EZ_RECPAG == 'P'



						cQuery := ""
						cQuery += " SELECT E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA
						cQuery += "      , E2_TIPO, E2_HIST, E2_MOEDA, E2_EMISSAO, E2_NATUREZ, E2_TXMOEDA, SUM(E2_VALOR + E2_IRRF) AS E2_VALOR
						cQuery += "  FROM " + RetSqlName("SE2") + " SE2 WITH(NOLOCK) "
						// cQuery += "  INNER JOIN " + RetSqlName("SEV") + " SEV WITH(NOLOCK) ON SEV.D_E_L_E_T_ = ''"
						// cQuery += "   AND EV_FILIAL = E2_FILIAL
						// cQuery += "   AND EV_NUM = E2_NUM
						// cQuery += "   AND EV_PARCELA = E2_PARCELA
						// cQuery += "   AND EV_CLIFOR = E2_FORNECE
						// cQuery += "   AND EV_LOJA  = E2_LOJA
						// cQuery += "   AND EV_TIPO = E2_TIPO
						// cQuery += "   AND EV_NATUREZ = '" + SEZ->EZ_NATUREZ + "'
						cQuery += " WHERE E2_FILIAL = '" + SEZ->EZ_FILIAL + "'
						cQuery += "   AND E2_FORNECE = '" + SEZ->EZ_CLIFOR + "'
						cQuery += "   AND E2_LOJA = '" + SEZ->EZ_LOJA + "'
						cQuery += "   AND E2_PREFIXO = '" + SEZ->EZ_PREFIXO + "'
						cQuery += "   AND E2_NUM = '" + SEZ->EZ_NUM + "'
						cQuery += "   AND E2_TIPO != 'TX'
						cQuery += "   AND SE2.D_E_L_E_T_ = ''
						cQuery += " GROUP BY E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA
						cQuery += "      , E2_TIPO, E2_HIST, E2_MOEDA, E2_EMISSAO, E2_NATUREZ, E2_TXMOEDA
						TcQuery cQuery New Alias (cTRX := GetNextAlias())



						dbSelectArea((cTRX))
						(cTRX)->(dbGoTop())
						If (cTRX)->(!eof())
							SA2->(dbSetOrder(1), dbSeek(FWxFilial("SA2") + (cTRX)->(E2_FORNECE + E2_LOJA)))

							// iF (cTRX)->E2_NUM == '071034951'
							// 	CXXX := ""
							// eNDiF

							cCodIC    := IIF(Empty(SA2->A2_XICCODE), SA2->A2_COD, SA2->A2_XICCODE)
							cCodigo   := (cTRX)->E2_FORNECE
							cLoja     := (cTRX)->E2_LOJA
							cNome     := (cTRX)->E2_NOMFOR
							cPrefixo  := (cTRX)->E2_PREFIXO
							cTitulo   := (cTRX)->E2_NUM
							cParcela  := (cTRX)->E2_PARCELA
							cTipo     := (cTRX)->E2_TIPO
							cHistFin  := (cTRX)->E2_HIST
							nMoedAx   := (cTRX)->E2_MOEDA
							cMoeda    := retMoeda(cvalToChar((cTRX)->E2_MOEDA))
							nValor_ME := ROUND(((cTRX)->E2_VALOR * SEZ->EZ_PERC),2)
							dEmissao  := sTod((cTRX)->E2_EMISSAO)
							cNatureza := (cTRX)->E2_NATUREZ
							nTaxa     := (cTRX)->E2_TXMOEDA
							cCliFor   := 'For'
							cRecPag   := "Pag"
						EndIf

						(cTRX)->(dbCloseArea())



						// dbSelectArea("SE2")
						// dbSetOrder(6)//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
						// If dbSeek(FWxFilial("SE2") + SEZ->(EZ_CLIFOR + EZ_LOJA + EZ_PREFIXO + EZ_NUM + EZ_PARCELA + EZ_TIPO))

						// 	SA2->(dbSetOrder(1), dbSeek(FWxFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA)))

						// 	cCodIC    := IIF(Empty(SA2->A2_XICCODE), SA2->A2_COD, SA2->A2_XICCODE)

						// 	cCodigo   := SE2->E2_FORNECE
						// 	cLoja     := SE2->E2_LOJA
						// 	cNome     := SE2->E2_NOMFOR
						// 	cPrefixo  := SE2->E2_PREFIXO
						// 	cTitulo   := SE2->E2_NUM
						// 	cParcela  := SE2->E2_PARCELA
						// 	cTipo     := SE2->E2_TIPO
						// 	cHistFin  := SE2->E2_HIST
						// 	cMoeda    := retMoeda(cvalToChar(SE2->E2_MOEDA))
						// 	nValor_ME := ROUND(((SE2->E2_VALOR + SE2->E2_IRRF) * SEZ->EZ_PERC),2)
						// 	dEmissao  := SE2->E2_EMISSAO
						// 	cNatureza := SEZ->EZ_NATUREZ
						// 	nTaxa     := SE2->E2_TXMOEDA

						// 	cCliFor   := 'For'
						// 	cRecPag   := "Pag"

						// EndIf

					Else


						cQuery := ""
						cQuery += " SELECT E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_PREFIXO, E1_NUM, E1_PARCELA
						cQuery += "      , E1_TIPO, E1_HIST, E1_MOEDA, E1_EMISSAO, E1_NATUREZ, E1_TXMOEDA, SUM(E1_VALOR + E1_IRRF) AS E1_VALOR
						cQuery += "  FROM " + RetSqlName("SE1") + " SE1 WITH(NOLOCK) "
						cQuery += " WHERE E1_FILIAL = '" + SEZ->EZ_FILIAL + "'
						cQuery += "   AND E1_CLIENTE = '" + SEZ->EZ_CLIFOR + "'
						cQuery += "   AND E1_LOJA = '" + SEZ->EZ_LOJA + "'
						cQuery += "   AND E1_PREFIXO = '" + SEZ->EZ_PREFIXO + "'
						cQuery += "   AND E1_NUM = '" + SEZ->EZ_NUM + "'
						cQuery += "   AND E1_TIPO = 'NF'
						cQuery += "   AND SE1.D_E_L_E_T_ = ''
						cQuery += " GROUP BY E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_PREFIXO, E1_NUM, E1_PARCELA
						cQuery += "      , E1_TIPO, E1_HIST, E1_MOEDA, E1_EMISSAO, E1_NATUREZ, E1_TXMOEDA
						TcQuery cQuery New Alias (cTRX := GetNextAlias())

						dbSelectArea((cTRX))
						(cTRX)->(dbGoTop())
						If (cTRX)->(!eof())
							SA1->(dbSetOrder(1), dbSeek(FWxFilial("SA1") + (cTRX)->(E1_CLIENTE + E1_LOJA)))

							cCodIC    := IIF(Empty(SA1->A1_XICCODE), SA1->A1_COD, SA1->A1_XICCODE)
							cCodigo   := (cTRX)->E1_CLIENTE
							cLoja     := (cTRX)->E1_LOJA
							cNome     := (cTRX)->E1_NOMCLI
							cPrefixo  := (cTRX)->E1_PREFIXO
							cTitulo   := (cTRX)->E1_NUM
							cParcela  := (cTRX)->E1_PARCELA
							cTipo     := (cTRX)->E1_TIPO
							cHistFin  := (cTRX)->E1_HIST
							nMoedAx   := (cTRX)->E1_MOEDA
							cMoeda    := retMoeda(cvalToChar((cTRX)->E1_MOEDA))
							nValor_ME := ROUND(((cTRX)->E1_VALOR * SEZ->EZ_PERC),2)
							dEmissao  := sTod((cTRX)->E1_EMISSAO)
							cNatureza := (cTRX)->E1_NATUREZ
							nTaxa     := (cTRX)->E1_TXMOEDA
							cCliFor   := 'Cli'
							cRecPag   := "Rec"
						EndIf

						(cTRX)->(dbCloseArea())
						// dbSelectArea("SE1")
						// dbSetOrder(2)//E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
						// If dbSeek(FWxFilial("SE1") + SEZ->(EZ_CLIFOR + EZ_LOJA + EZ_PREFIXO + EZ_NUM + EZ_PARCELA + EZ_TIPO))

						// 	SA1->(dbSetOrder(1), dbSeek(FWxFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))

						// 	cCodIC    := IIF(Empty(SA1->A1_XICCODE), SA1->A1_COD, SA1->A1_XICCODE)
						// 	cCodigo   := SE1->E1_CLIENTE
						// 	cLoja     := SE1->E1_LOJA
						// 	cNome     := SE1->E1_NOMCLI
						// 	cPrefixo  := SE1->E1_PREFIXO
						// 	cTitulo   := SE1->E1_NUM
						// 	cParcela  := SE1->E1_PARCELA
						// 	cTipo     := SE1->E1_TIPO
						// 	cHistFin  := SE1->E1_HIST
						// 	cMoeda    := retMoeda(cvalToChar(SE1->E1_MOEDA))
						// 	nValor_ME := ROUND((SE1->E1_VALOR * SEZ->EZ_PERC),2)
						// 	dEmissao  := SE1->E1_EMISSAO
						// 	cNatureza := SE1->E1_NATUREZ
						// 	nTaxa     := SE1->E1_TXMOEDA

						// 	cCliFor   := 'Cli'
						// 	cRecPag   := "Rec"
						// EndIf

					EndIf

				EndIf
			EndIf

			op_Self:IncRegua2("Processando titulo " + cTitulo + "...")

			If cMoeda == 'BRL'
				nValor_ME := (cTRB)->VALOR
			ElseIf cMoeda != 'XXX' .and. !Empty(nMoedAx)
				nTaxa := iif(Empty(nTaxa), RecMoeda(dEmissao, nMoedAx), nTaxa)
				nValor_ME := round((cTRB)->VALOR / nTaxa,2)
			Else
				nValor_ME := nValor_ME * (cTRB)->FATOR
			EndIf

			oFWMsExcel:AddRow(cSheet,cTitPlan,{(cTRB)->FILIAL,;
				(cTRB)->COMPANY,;
				sTod((cTRB)->DATA_CTB),;
				(cTRB)->LOTE,;
				(cTRB)->CONTA,;
				(cTRB)->DESCT_CTA,;
				(cTRB)->VALOR,;
				(cTRB)->HIST_CTB,;
				(cTRB)->CC,;
				(cTRB)->TPSALDO,;
				(cTRB)->ORIGEM_CTB,;
				(cTRB)->PERIODO,;
				(cTRB)->CTRL_CODE,;
				(cTRB)->DESC_CODE,;
				(cTRB)->PESQ_CTB,;
				(cTRB)->CTR_PARTIDA,;
				(cTRB)->LP,;
				cPrefixo,;
				cTitulo,;
				cParcela,;
				cTipo,;
				dEmissao,;
				cNatureza,;
				nValor_ME,;
				cMoeda,;
				nTaxa,;
				cCodigo,;
				cLoja,;
				cCodIC,;
				cNome,;
				cHistFin,;
				cCliFor,;
				cRecPag,;
				(cTRB)->ITEM_CTBL,;
				(cTRB)->ITEM_CTBL_DESC})



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

	EndIf

	(cTRB)->(dbCloseArea())

return()

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

static function retMoeda(cp_Moeda)
	local cRet := ""

	DO CASE
	CASE cp_Moeda == '1' .or. Empty(cp_Moeda)
		cRet := 'BRL'
	CASE cp_Moeda == '2' .or. cp_Moeda == '4'
		cRet := 'USD'
	CASE cp_Moeda == '5' .or. cp_Moeda == '6'
		cRet := 'EUR'
	CASE cp_Moeda == '7' .or. cp_Moeda == '8'
		cRet := 'CLP'
	CASE cp_Moeda == '9' .or. cp_Moeda == '10'
		cRet := 'GBP'
	CASE cp_Moeda == '11' .or. cp_Moeda == '12'
		cRet := 'SEK'
	CASE cp_Moeda == '13' .or. cp_Moeda == '14'
		cRet := 'CAD'
	CASE cp_Moeda == '15' .or. cp_Moeda == '16'
		cRet := 'NOK'
	CASE cp_Moeda == '17' .or. cp_Moeda == '18'
		cRet := 'CHF'
	CASE cp_Moeda == '19' .or. cp_Moeda == '20'
		cRet := 'DKK'
	CASE cp_Moeda == '21' .or. cp_Moeda == '22'
		cRet := 'NZD'
	CASE cp_Moeda == '23' .or. cp_Moeda == '24'
		cRet := 'ARS'
	CASE cp_Moeda == '25' .or. cp_Moeda == '26'
		cRet := 'AUD'
	OTHERWISE
		cRet := 'XXX'
	ENDCASE

return(cRet)


// ---------------------------------------------------------------------------------------------------------------------------------------------------------------
