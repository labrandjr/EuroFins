#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

Static __oTBxCanc	:= NIL
user function ConsCTBFIN()

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
	local cTitulo  := "Financeiro"

	op_Self:SetRegua1(2)
	op_Self:SetRegua2(6)
	// op_Self:SetRegua3(1)
	// op_Self:SetRegua4(1)
	// op_Self:SetRegua5(1)
	// op_Self:SetRegua6(1)
	// op_Self:SetRegua7(1)
	// op_Self:SetRegua8(1)
	op_Self:IncRegua1("Leitura dos registros financeiro")

	cQuery := ""
	cQuery += " SELECT CT2_FILIAL															AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                        				AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)														AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)													AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)														AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)														AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO)													AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)													AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)						AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR															AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)														AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')				AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)													AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)													AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)												AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)												AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)					AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')								AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')								AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')									AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')									AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')									AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')									AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 		 , RTRIM(CT2_CREDIT) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += " 	     , 0 AS VMoeda
	cQuery += "          , '' AS [Moeda]
	cQuery += "          , '' AS Cliente
	cQuery += "          , '' AS Loja
	cQuery += "          , '' AS CodeIC
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , 0 AS TMoeda
	cQuery += "          , '' AS Cli_For
	cQuery += "          , '' AS Pag_Rec
	cQuery += "        FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP NOT IN ('500','501','502','505','540','541','542','543','544','545','546','555','556','595','549'
	cQuery += "                             ,'550','551','552','553','503','504','506','507','509','51A','522','523','524','525','526','528','529','57A'
	cQuery += "                             ,'57B','592','510','511','512','513','514','515','518','519','533','577','578','57C','57D','587','593','605'
	cQuery += "                             ,'606','607','608','65C','65D','661',/*'560','561','564','565','562','563',*/'557','558','56A','56B','580','581'
	cQuery += "                             ,'582','584','585','586','598','599','516','517','520','521','527','530','531','532','588','589','594','596'
	cQuery += "                             ,'597')
	cQuery += " 	 UNION ALL
	cQuery += " 	 SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                     		AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 	     , RTRIM(CT2_DEBITO) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += " 	     , 0 AS VMoeda
	cQuery += "          , '' AS [Moeda]
	cQuery += "          , '' AS Cliente
	cQuery += "          , '' AS Loja
	cQuery += "          , '' AS CodeIC
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , 0 AS TMoeda
	cQuery += "          , '' AS Cli_For
	cQuery += "          , '' AS Pag_Rec
	cQuery += " 	   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP NOT IN ('500','501','502','505','540','541','542','543','544','545','546','555','556','595','549'
	cQuery += "                             ,'550','551','552','553','503','504','506','507','509','51A','522','523','524','525','526','528','529','57A'
	cQuery += "                             ,'57B','592','510','511','512','513','514','515','518','519','533','577','578','57C','57D','587','593','605'
	cQuery += "                             ,'606','607','608','65C','65D','661',/*'560','561','564','565','562','563',*/'557','558','56A','56B','580','581'
	cQuery += "                             ,'582','584','585','586','598','599','516','517','520','521','527','530','531','532','588','589','594','596'
	cQuery += "                             ,'597')
	cQuery += "     UNION ALL
	//  --GRUPO 1
	cQuery += " 	SELECT CT2_FILIAL															AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                        				AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)														AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)													AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)														AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)														AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO)													AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)													AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)						AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR															AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)														AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')				AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)													AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)													AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)												AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)												AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)					AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')								AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')								AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')									AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')									AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')									AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')									AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 		 , RTRIM(CT2_CREDIT) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E1_VALOR AS VMoeda
	cQuery += "          , CASE isnull(E1_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , E1_CLIENTE AS Cliente
	cQuery += "          , E1_LOJA AS Loja
	cQuery += "          , CASE WHEN A1_XICCODE = '' THEN A1_COD ELSE A1_XICCODE END AS CodeIC
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E1_TXMOEDA AS TMoeda
	cQuery += "          , 'C' AS Cli_For
	cQuery += "          , 'R' AS Pag_Rec
	cQuery += "        FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE1") + " SE1 WITH(NOLOCK) ON SE1.D_E_L_E_T_ = ''
	cQuery += "              AND E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('500','501','502','505','540','541','542','543','544','545','546','555','556','595')
	cQuery += "     UNION ALL
	cQuery += " 	 SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                     		AS [DtMov]
	cQuery += " 	      , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 	     , RTRIM(CT2_DEBITO) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E1_VALOR AS VMoeda
	cQuery += "          , CASE isnull(E1_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , E1_CLIENTE AS Cliente
	cQuery += "          , E1_LOJA AS Loja
	cQuery += "          , CASE WHEN A1_XICCODE = '' THEN A1_COD ELSE A1_XICCODE END AS CodeIC
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E1_TXMOEDA AS TMoeda
	cQuery += "          , 'C' AS Cli_For
	cQuery += "          , 'R' AS Pag_Rec
	cQuery += " 	   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE1") + " SE1 WITH(NOLOCK) ON SE1.D_E_L_E_T_ = ''
	cQuery += "              AND E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlname("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('500','501','502','505','540','541','542','543','544','545','546','555','556','595')

	TcQuery cQuery New Alias (cTRB := GetNextAlias())

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

		oFWMsExcel:AddColumn(cSheet, cTitulo,"Filial"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Movimento"               ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Lote Contabil"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Sub Lote"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Documento"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Linha"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Conta"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Desc. Conta"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Conta + Descricao"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor Contabil"               ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Historico"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Centro Custo"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tipo Saldo"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Origem Ctb"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Ano"                          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Mes"                          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Periodo"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Conta Sintetica"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Desc. Sintetica"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Conta Controle"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Desc. C. Controle"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Company CC"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Company Code"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"BU"                           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"BU CC"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Pesquisa"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Export Log"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Natureza Conta"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Visao"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Classificação"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Contra Partida"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"LP"                           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor Moeda Fin."             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Moeda Titulo Fin."            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Cliente"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Loja"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"IC Code"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Taxa Moeda"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Cli. - For."                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Rec. - Pag."                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"LE"                          ,1,1)

		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando " + (cTRB)->Pesquisa + "...")

			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->Filial,;
				(cTRB)->DtMov,;
				(cTRB)->LoteCtb,;
				(cTRB)->SLote,;
				(cTRB)->Documento,;
				(cTRB)->Linha,;
				(cTRB)->Conta,;
				(cTRB)->DescCta,;
				(cTRB)->Cta_Desc,;
				(cTRB)->Valor,;
				(cTRB)->Historico,;
				(cTRB)->CC,;
				(cTRB)->TpSaldo,;
				(cTRB)->Origem,;
				(cTRB)->Ano,;
				(cTRB)->Mes,;
				(cTRB)->Periodo,;
				(cTRB)->CtrlCodeSint,;
				(cTRB)->DescCtrlSint,;
				(cTRB)->ControlCode,;
				(cTRB)->DescCtrlCode,;
				(cTRB)->CompanyCC,;
				(cTRB)->CompanyCode,;
				(cTRB)->BU,;
				(cTRB)->BU_CC,;
				(cTRB)->Pesquisa,;
				(cTRB)->Export,;
				(cTRB)->Nat_Conta,;
				(cTRB)->VISAO,;
				(cTRB)->Classificao,;
				(cTRB)->CPartida,;
				(cTRB)->LP,;
				(cTRB)->VMoeda,;
				(cTRB)->Moeda,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->CodeIC,;
				(cTRB)->TMoeda,;
				(cTRB)->Cli_For,;
				(cTRB)->Pag_Rec,;
				(cTRB)->LE})



			(cTRB)->(dbSkip())
		EndDo
	EndIf
	(cTRB)->(dbCloseArea())

	// GRUPO 2
	cQuery := " 	 SELECT CT2_FILIAL															AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                        				AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)														AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)													AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)														AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)														AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO)													AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)													AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)						AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR															AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)														AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')				AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)													AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)													AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)												AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)												AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)					AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')								AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')								AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')									AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')									AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')									AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')									AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 		 , RTRIM(CT2_CREDIT) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E1_VALOR AS VMoeda
	cQuery += "          , CASE isnull(E1_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , E1_CLIENTE AS Cliente
	cQuery += "          , E1_LOJA AS Loja
	cQuery += "          , CASE WHEN A1_XICCODE = '' THEN A1_COD ELSE A1_XICCODE END AS CodeIC
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E1_TXMOEDA AS TMoeda
	cQuery += "          , 'C' AS Cli_For
	cQuery += "          , 'R' AS Pag_Rec
	cQuery += "        FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE1") + " SE1 WITH(NOLOCK) ON SE1.D_E_L_E_T_ = ''
	cQuery += "              AND E1_FILIAL+E1_NUMBOR+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('549','550','551','552','553')
	cQuery += "     UNION ALL
	cQuery += " 	 SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                     		AS [DtMov]
	cQuery += " 	      , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 	     , RTRIM(CT2_DEBITO) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E1_VALOR AS VMoeda
	cQuery += "          , CASE isnull(E1_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , E1_CLIENTE AS Cliente
	cQuery += "          , E1_LOJA AS Loja
	cQuery += "          , CASE WHEN A1_XICCODE = '' THEN A1_COD ELSE A1_XICCODE END AS CodeIC
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E1_TXMOEDA AS TMoeda
	cQuery += "          , 'C' AS Cli_For
	cQuery += "          , 'R' AS Pag_Rec
	cQuery += " 	   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE1") + " SE1 WITH(NOLOCK) ON SE1.D_E_L_E_T_ = ''
	cQuery += "              AND E1_FILIAL+E1_NUMBOR+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('549','550','551','552','553')

	TcQuery cQuery New Alias (cTRB := GetNextAlias())
	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())
		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando " + (cTRB)->Pesquisa + "...")

			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->Filial,;
				(cTRB)->DtMov,;
				(cTRB)->LoteCtb,;
				(cTRB)->SLote,;
				(cTRB)->Documento,;
				(cTRB)->Linha,;
				(cTRB)->Conta,;
				(cTRB)->DescCta,;
				(cTRB)->Cta_Desc,;
				(cTRB)->Valor,;
				(cTRB)->Historico,;
				(cTRB)->CC,;
				(cTRB)->TpSaldo,;
				(cTRB)->Origem,;
				(cTRB)->Ano,;
				(cTRB)->Mes,;
				(cTRB)->Periodo,;
				(cTRB)->CtrlCodeSint,;
				(cTRB)->DescCtrlSint,;
				(cTRB)->ControlCode,;
				(cTRB)->DescCtrlCode,;
				(cTRB)->CompanyCC,;
				(cTRB)->CompanyCode,;
				(cTRB)->BU,;
				(cTRB)->BU_CC,;
				(cTRB)->Pesquisa,;
				(cTRB)->Export,;
				(cTRB)->Nat_Conta,;
				(cTRB)->VISAO,;
				(cTRB)->Classificao,;
				(cTRB)->CPartida,;
				(cTRB)->LP,;
				(cTRB)->VMoeda,;
				(cTRB)->Moeda,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->CodeIC,;
				(cTRB)->TMoeda,;
				(cTRB)->Cli_For,;
				(cTRB)->Pag_Rec,;
				(cTRB)->LE})



			(cTRB)->(dbSkip())
		EndDo
	EndIf
	(cTRB)->(dbCloseArea())

	// -- gruopo 3
	cQuery := " 	SELECT CT2_FILIAL															AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                        				AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)														AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)													AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)														AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)														AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO)													AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)													AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)						AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR															AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)														AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')				AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)													AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)													AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)												AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)												AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)					AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')								AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')								AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')									AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')									AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')									AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')									AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 		 , RTRIM(CT2_CREDIT) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E1_VALOR AS VMoeda
	cQuery += "          , CASE isnull(E1_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , E1_CLIENTE AS Cliente
	cQuery += "          , E1_LOJA AS Loja
	cQuery += "          , CASE WHEN A1_XICCODE = '' THEN A1_COD ELSE A1_XICCODE END AS CodeIC
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E1_TXMOEDA AS TMoeda
	cQuery += "          , 'C' AS Cli_For
	cQuery += "          , 'R' AS Pag_Rec
	cQuery += "        FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2) AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE1") + " SE1 WITH(NOLOCK) ON SE1.D_E_L_E_T_ = ''
	cQuery += "              AND E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('503','504','506','507','509','51A','522','523','524','525','526','528','529','57A','57B','592')
	cQuery += "     UNION ALL
	cQuery += " 	 SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                     		AS [DtMov]
	cQuery += " 	      , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 	     , RTRIM(CT2_DEBITO) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E1_VALOR AS VMoeda
	cQuery += "          , CASE isnull(E1_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , E1_CLIENTE AS Cliente
	cQuery += "          , E1_LOJA AS Loja
	cQuery += "          , CASE WHEN A1_XICCODE = '' THEN A1_COD ELSE A1_XICCODE END AS CodeIC
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E1_TXMOEDA AS TMoeda
	cQuery += "          , 'C' AS Cli_For
	cQuery += "          , 'R' AS Pag_Rec
	cQuery += " 	   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE1") + " SE1 WITH(NOLOCK) ON SE1.D_E_L_E_T_ = ''
	cQuery += "              AND E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('503','504','506','507','509','51A','522','523','524','525','526','528','529','57A','57B','592')
	TcQuery cQuery New Alias (cTRB := GetNextAlias())
	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())
		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando " + (cTRB)->Pesquisa + "...")

			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->Filial,;
				(cTRB)->DtMov,;
				(cTRB)->LoteCtb,;
				(cTRB)->SLote,;
				(cTRB)->Documento,;
				(cTRB)->Linha,;
				(cTRB)->Conta,;
				(cTRB)->DescCta,;
				(cTRB)->Cta_Desc,;
				(cTRB)->Valor,;
				(cTRB)->Historico,;
				(cTRB)->CC,;
				(cTRB)->TpSaldo,;
				(cTRB)->Origem,;
				(cTRB)->Ano,;
				(cTRB)->Mes,;
				(cTRB)->Periodo,;
				(cTRB)->CtrlCodeSint,;
				(cTRB)->DescCtrlSint,;
				(cTRB)->ControlCode,;
				(cTRB)->DescCtrlCode,;
				(cTRB)->CompanyCC,;
				(cTRB)->CompanyCode,;
				(cTRB)->BU,;
				(cTRB)->BU_CC,;
				(cTRB)->Pesquisa,;
				(cTRB)->Export,;
				(cTRB)->Nat_Conta,;
				(cTRB)->VISAO,;
				(cTRB)->Classificao,;
				(cTRB)->CPartida,;
				(cTRB)->LP,;
				(cTRB)->VMoeda,;
				(cTRB)->Moeda,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->CodeIC,;
				(cTRB)->TMoeda,;
				(cTRB)->Cli_For,;
				(cTRB)->Pag_Rec,;
				(cTRB)->LE})



			(cTRB)->(dbSkip())
		EndDo
	EndIf
	(cTRB)->(dbCloseArea())

	// -- GRUPO 4
	cQuery := " 	SELECT CT2_FILIAL															AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                        				AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)														AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)													AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)														AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)														AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO)													AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)													AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)						AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR															AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)														AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')				AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)													AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)													AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)												AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)												AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)					AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')								AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')								AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')									AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')									AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')									AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')									AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 		 , RTRIM(CT2_CREDIT) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E2_VALOR AS VMoeda
	cQuery += "          , CASE isnull(E2_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , E2_FORNECE AS Cliente
	cQuery += "          , E2_LOJA AS Loja
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "          , CASE WHEN A2_XICCODE = '' THEN A2_COD ELSE A2_XICCODE END AS CodeIC
	Else
		cQuery += "          , A2_COD AS CodeIC
	EndIf
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E2_TXMOEDA AS TMoeda
	cQuery += "          , 'F' AS Cli_For
	cQuery += "          , 'P' AS Pag_Rec
	cQuery += "        FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE2") + " SE2 WITH(NOLOCK) ON SE2.D_E_L_E_T_ = ''
	cQuery += "              AND E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('510','511','512','513','514','515','518','519','533','577','578','57C','57D','587','593','605','606','607','608','65C','65D','661')
	cQuery += "     UNION ALL
	cQuery += " 	 SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                     		AS [DtMov]
	cQuery += " 	      , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 	     , RTRIM(CT2_DEBITO) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E2_VALOR AS VMoeda
	cQuery += "          , CASE isnull(E2_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , E2_FORNECE AS Cliente
	cQuery += "          , E2_LOJA AS Loja
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "          , CASE WHEN A2_XICCODE = '' THEN A2_COD ELSE A2_XICCODE END AS CodeIC
	Else
		cQuery += "          , A2_COD AS CodeIC
	EndIf
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E2_TXMOEDA AS TMoeda
	cQuery += "          , 'F' AS Cli_For
	cQuery += "          , 'P' AS Pag_Rec
	cQuery += " 	   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE2") + " SE2 WITH(NOLOCK) ON SE2.D_E_L_E_T_ = ''
	cQuery += "              AND E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('510','511','512','513','514','515','518','519','533','577','578','57C','57D','587','593','605','606','607','608','65C','65D','661')
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())
		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando " + (cTRB)->Pesquisa + "...")
			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->Filial,;
				(cTRB)->DtMov,;
				(cTRB)->LoteCtb,;
				(cTRB)->SLote,;
				(cTRB)->Documento,;
				(cTRB)->Linha,;
				(cTRB)->Conta,;
				(cTRB)->DescCta,;
				(cTRB)->Cta_Desc,;
				(cTRB)->Valor,;
				(cTRB)->Historico,;
				(cTRB)->CC,;
				(cTRB)->TpSaldo,;
				(cTRB)->Origem,;
				(cTRB)->Ano,;
				(cTRB)->Mes,;
				(cTRB)->Periodo,;
				(cTRB)->CtrlCodeSint,;
				(cTRB)->DescCtrlSint,;
				(cTRB)->ControlCode,;
				(cTRB)->DescCtrlCode,;
				(cTRB)->CompanyCC,;
				(cTRB)->CompanyCode,;
				(cTRB)->BU,;
				(cTRB)->BU_CC,;
				(cTRB)->Pesquisa,;
				(cTRB)->Export,;
				(cTRB)->Nat_Conta,;
				(cTRB)->VISAO,;
				(cTRB)->Classificao,;
				(cTRB)->CPartida,;
				(cTRB)->LP,;
				(cTRB)->VMoeda,;
				(cTRB)->Moeda,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->CodeIC,;
				(cTRB)->TMoeda,;
				(cTRB)->Cli_For,;
				(cTRB)->Pag_Rec,;
				(cTRB)->LE})


			(cTRB)->(dbSkip())
		EndDo
	EndIf

	(cTRB)->(dbCloseArea())

	cQuery := " 	SELECT CT2_FILIAL															AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                        				AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)														AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)													AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)														AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)														AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO)													AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)													AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)						AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR															AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)														AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')				AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)													AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)													AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)												AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)												AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)					AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')								AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')								AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')									AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')									AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')									AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')									AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 		 , RTRIM(CT2_CREDIT) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E5_VLMOED2 AS VMoeda
	cQuery += "          , CASE isnull(E5_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN E5_FORNECE ELSE E5_CLIENTE END AS Cliente
	cQuery += "          , E5_LOJA AS Loja
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_XICCODE != '' THEN A2_XICCODE ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	Else
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_COD != '' THEN A2_COD ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	EndIf
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E5_TXMOEDA AS TMoeda
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN 'F' ELSE 'C' END AS Cli_For
	cQuery += "          , E5_RECPAG AS Pag_Rec
	cQuery += "        FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE5") + " SE5 WITH(NOLOCK) ON SE5.D_E_L_E_T_ = '' AND E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+E5_DOCUMEN  = CT2_KEY
	cQuery += "        AND abs(E5_VALOR) = ABS(CT2_VALOR)
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E5_CLIENTE AND A1_LOJA = E5_LOJA
	cQuery += "        LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E5_FORNECE AND A2_LOJA = E5_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('557','558','56A','56B','580','581','582','584','585','586','598','599')
	cQuery += "     UNION ALL
	cQuery += " 	 SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                     		AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 	     , RTRIM(CT2_DEBITO) AS [CPartida]
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E5_VLMOED2 AS VMoeda
	cQuery += "          , CASE isnull(E5_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN E5_FORNECE ELSE E5_CLIENTE END AS Cliente
	cQuery += "          , E5_LOJA AS Loja
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_XICCODE != '' THEN A2_XICCODE ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	Else
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_COD != '' THEN A2_COD ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	EndIf
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E5_TXMOEDA AS TMoeda
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN 'F' ELSE 'C' END AS Cli_For
	cQuery += "          , E5_RECPAG AS Pag_Rec
	cQuery += " 	   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE5") + " SE5 WITH(NOLOCK) ON SE5.D_E_L_E_T_ = '' AND E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+E5_DOCUMEN  = CT2_KEY
	cQuery += "        AND abs(E5_VALOR) = ABS(CT2_VALOR)
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E5_CLIENTE AND A1_LOJA = E5_LOJA
	cQuery += "        LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E5_FORNECE AND A2_LOJA = E5_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('557','558','56A','56B','580','581','582','584','585','586','598','599')
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())
		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando " + (cTRB)->Pesquisa + "...")
			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->Filial,;
				(cTRB)->DtMov,;
				(cTRB)->LoteCtb,;
				(cTRB)->SLote,;
				(cTRB)->Documento,;
				(cTRB)->Linha,;
				(cTRB)->Conta,;
				(cTRB)->DescCta,;
				(cTRB)->Cta_Desc,;
				(cTRB)->Valor,;
				(cTRB)->Historico,;
				(cTRB)->CC,;
				(cTRB)->TpSaldo,;
				(cTRB)->Origem,;
				(cTRB)->Ano,;
				(cTRB)->Mes,;
				(cTRB)->Periodo,;
				(cTRB)->CtrlCodeSint,;
				(cTRB)->DescCtrlSint,;
				(cTRB)->ControlCode,;
				(cTRB)->DescCtrlCode,;
				(cTRB)->CompanyCC,;
				(cTRB)->CompanyCode,;
				(cTRB)->BU,;
				(cTRB)->BU_CC,;
				(cTRB)->Pesquisa,;
				(cTRB)->Export,;
				(cTRB)->Nat_Conta,;
				(cTRB)->VISAO,;
				(cTRB)->Classificao,;
				(cTRB)->CPartida,;
				(cTRB)->LP,;
				(cTRB)->VMoeda,;
				(cTRB)->Moeda,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->CodeIC,;
				(cTRB)->TMoeda,;
				(cTRB)->Cli_For,;
				(cTRB)->Pag_Rec,;
				(cTRB)->LE})



			(cTRB)->(dbSkip())
		EndDo
	EndIf

	(cTRB)->(dbCloseArea())

	cQuery := " 	SELECT CT2_FILIAL															AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                        				AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)														AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)													AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)														AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)														AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO)													AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)													AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)						AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR															AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)														AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')				AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)													AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)													AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)												AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)												AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)					AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')								AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')								AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')									AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')									AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')									AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')									AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 		 , RTRIM(CT2_CREDIT) AS [CPartida]
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E5_VLMOED2 AS VMoeda
	cQuery += "          , CASE isnull(E5_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN E5_FORNECE ELSE E5_CLIENTE END AS Cliente
	cQuery += "          , E5_LOJA AS Loja
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_XICCODE != '' THEN A2_XICCODE ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	Else
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_COD != '' THEN A2_COD ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	EndIf
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E5_TXMOEDA AS TMoeda
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN 'F' ELSE 'C' END AS Cli_For
	cQuery += "          , E5_RECPAG AS Pag_Rec
	cQuery += "        FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE5") + " SE5 WITH(NOLOCK) ON SE5.D_E_L_E_T_ = '' AND E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+E5_IDENTEE = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E5_CLIENTE AND A1_LOJA = E5_LOJA
	cQuery += "        LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E5_FORNECE AND A2_LOJA = E5_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('516,517')
	cQuery += "     UNION ALL
	cQuery += " 	 SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                     		AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 	     , RTRIM(CT2_DEBITO) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E5_VLMOED2 AS VMoeda
	cQuery += "          , CASE isnull(E5_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN E5_FORNECE ELSE E5_CLIENTE END AS Cliente
	cQuery += "          , E5_LOJA AS Loja
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_XICCODE != '' THEN A2_XICCODE ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	Else
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_COD != '' THEN A2_COD ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	EndIf
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E5_TXMOEDA AS TMoeda
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN 'F' ELSE 'C' END AS Cli_For
	cQuery += "          , E5_RECPAG AS Pag_Rec
	cQuery += " 	   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE5") + " SE5 WITH(NOLOCK) ON SE5.D_E_L_E_T_ = '' AND E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+E5_IDENTEE  = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E5_CLIENTE AND A1_LOJA = E5_LOJA
	cQuery += "        LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E5_FORNECE AND A2_LOJA = E5_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('516,517')
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())
		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando " + (cTRB)->Pesquisa + "...")

			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->Filial,;
				(cTRB)->DtMov,;
				(cTRB)->LoteCtb,;
				(cTRB)->SLote,;
				(cTRB)->Documento,;
				(cTRB)->Linha,;
				(cTRB)->Conta,;
				(cTRB)->DescCta,;
				(cTRB)->Cta_Desc,;
				(cTRB)->Valor,;
				(cTRB)->Historico,;
				(cTRB)->CC,;
				(cTRB)->TpSaldo,;
				(cTRB)->Origem,;
				(cTRB)->Ano,;
				(cTRB)->Mes,;
				(cTRB)->Periodo,;
				(cTRB)->CtrlCodeSint,;
				(cTRB)->DescCtrlSint,;
				(cTRB)->ControlCode,;
				(cTRB)->DescCtrlCode,;
				(cTRB)->CompanyCC,;
				(cTRB)->CompanyCode,;
				(cTRB)->BU,;
				(cTRB)->BU_CC,;
				(cTRB)->Pesquisa,;
				(cTRB)->Export,;
				(cTRB)->Nat_Conta,;
				(cTRB)->VISAO,;
				(cTRB)->Classificao,;
				(cTRB)->CPartida,;
				(cTRB)->LP,;
				(cTRB)->VMoeda,;
				(cTRB)->Moeda,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->CodeIC,;
				(cTRB)->TMoeda,;
				(cTRB)->Cli_For,;
				(cTRB)->Pag_Rec,;
				(cTRB)->LE})



			(cTRB)->(dbSkip())
		EndDo
	EndIf

	(cTRB)->(dbCloseArea())

	//  -- GRUPO 6
	cQuery := " 	SELECT CT2_FILIAL															AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                        				AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)														AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)													AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)														AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)														AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO)													AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)													AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)						AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR															AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)														AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')				AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)													AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)													AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)												AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)												AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)					AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')								AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')								AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')								AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')								AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')									AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')									AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')									AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')									AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS [Export]
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 		 , RTRIM(CT2_CREDIT) AS CPartida
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E5_VLMOED2 AS VMoeda
	cQuery += "          , CASE isnull(E5_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN E5_FORNECE ELSE E5_CLIENTE END AS Cliente
	cQuery += "          , E5_LOJA AS Loja
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_XICCODE != '' THEN A2_XICCODE ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	Else
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_COD != '' THEN A2_COD ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	EndIf
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E5_TXMOEDA AS TMoeda
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN 'F' ELSE 'C' END AS Cli_For
	cQuery += "          , E5_RECPAG AS Pag_Rec
	cQuery += "        FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE5") + " SE5 WITH(NOLOCK) ON SE5.D_E_L_E_T_ = '' AND E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E5_CLIENTE AND A1_LOJA = E5_LOJA
	cQuery += "        LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E5_FORNECE AND A2_LOJA = E5_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('520','521','527','530','531','532','588','589','594','596','597')
	cQuery += "     UNION ALL
	cQuery += " 	 SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 	 , CONVERT(DATETIME,CT2_DATA,128)                     		AS [DtMov]
	cQuery += " 	     , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 	 , CT2_FILIAL+ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 		 , ltrim(rtrim(CONVERT(CHAR, GETDATE(),112))) + ' - ' + substring(CONVERT(CHAR, GETDATE(),114),1,5) AS Export
	cQuery += " 	 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 	 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 	 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 	 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 	 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 	 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 	 , 'DRE' AS [VISAO]
	cQuery += " 	 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM CTS010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += " 	     , RTRIM(CT2_DEBITO) AS [CPartida]
	cQuery += "          , CT2_LP AS LP
	cQuery += "          , E5_VLMOED2 AS VMoeda
	cQuery += "          , CASE isnull(E5_MOEDA,0) WHEN 1 THEN 'BRL'
	cQuery += "     						    WHEN 2 THEN 'USD'
	cQuery += "     						    WHEN 4 THEN 'USD'
	cQuery += "     						    WHEN 5 THEN 'EUR'
	cQuery += "     						    WHEN 6 THEN 'EUR'
	cQuery += "     						    WHEN 7 THEN 'CLP'
	cQuery += "     						    WHEN 8 THEN 'CLP'
	cQuery += "     						    WHEN 9 THEN 'GBP'
	cQuery += "     						    WHEN 10 THEN 'GBP'
	cQuery += "     						    WHEN 11 THEN 'SEK'
	cQuery += "     						    WHEN 12 THEN 'SEK'
	cQuery += "     						    WHEN 13 THEN 'CAD'
	cQuery += "     						    WHEN 14 THEN 'CAD'
	cQuery += "     						    WHEN 15 THEN 'NOK'
	cQuery += "     						    WHEN 16 THEN 'NOK'
	cQuery += "     						    WHEN 17 THEN 'CHF'
	cQuery += "     						    WHEN 18 THEN 'CHF'
	cQuery += "     						    WHEN 19 THEN 'DKK'
	cQuery += "     						    WHEN 20 THEN 'DKK'
	cQuery += "     						    WHEN 21 THEN 'NZD'
	cQuery += "     						    WHEN 22 THEN 'NZD'
	cQuery += "     						    WHEN 23 THEN 'ARS'
	cQuery += "     						    WHEN 24 THEN 'ARS'
	cQuery += "     						    WHEN 25 THEN 'AUD'
	cQuery += "     						    WHEN 26 THEN 'AUD'
	cQuery += "     						    ELSE 'XXX' END AS [Moeda]
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN E5_FORNECE ELSE E5_CLIENTE END AS Cliente
	cQuery += "          , E5_LOJA AS Loja
	If SA2->(FieldPos("A2_XICCODE")) > 0
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_XICCODE != '' THEN A2_XICCODE ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	Else
		cQuery += "          , CASE WHEN E5_FORNECE != '' THEN CASE WHEN A2_COD != '' THEN A2_COD ELSE A2_COD END ELSE CASE WHEN A1_XICCODE != '' THEN A1_XICCODE ELSE A1_COD END END AS CodeIC
	EndIf
	cQuery += "          , ZM_CODIGO AS LE
	cQuery += "          , E5_TXMOEDA AS TMoeda
	cQuery += "          , CASE WHEN E5_FORNECE != '' THEN 'F' ELSE 'C' END AS Cli_For
	cQuery += "          , E5_RECPAG AS Pag_Rec
	cQuery += " 	   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += " 	  INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += " 	  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2)  AND SZM.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += " 	   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "        LEFT JOIN " + RetSqlName("CTL") + " CTL WITH(NOLOCK) ON CTL.D_E_L_E_T_ = '' AND CTL_LP = CT2_LP
	cQuery += "        LEFT JOIN " + RetSqlName("SE5") + " SE5 WITH(NOLOCK) ON SE5.D_E_L_E_T_ = '' AND E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ  = CT2_KEY
	cQuery += "        LEFT JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = E5_CLIENTE AND A1_LOJA = E5_LOJA
	cQuery += "        LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E5_FORNECE AND A2_LOJA = E5_LOJA
	cQuery += " 	  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += " 		AND SUBSTRING(CT2_DATA,1,4) in (
	cQuery += " 		SELECT DISTINCT SUBSTRING(CTG_DTINI,1,4) FROM CTG010 with(nolock) WHERE CTG010.D_E_L_E_T_  = ''
	cQuery += " 		AND CTG_FILIAL = '" + FWxFilial("CTG") + "'
	cQuery += " 		AND CTG_STATUS = '1'
	cQuery += " 		)
	cQuery += " 	 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
	cQuery += "         AND CT2_LP IN ('520','521','527','530','531','532','588','589','594','596','597')
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())
		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando " + (cTRB)->Pesquisa + "...")

			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->Filial,;
				(cTRB)->DtMov,;
				(cTRB)->LoteCtb,;
				(cTRB)->SLote,;
				(cTRB)->Documento,;
				(cTRB)->Linha,;
				(cTRB)->Conta,;
				(cTRB)->DescCta,;
				(cTRB)->Cta_Desc,;
				(cTRB)->Valor,;
				(cTRB)->Historico,;
				(cTRB)->CC,;
				(cTRB)->TpSaldo,;
				(cTRB)->Origem,;
				(cTRB)->Ano,;
				(cTRB)->Mes,;
				(cTRB)->Periodo,;
				(cTRB)->CtrlCodeSint,;
				(cTRB)->DescCtrlSint,;
				(cTRB)->ControlCode,;
				(cTRB)->DescCtrlCode,;
				(cTRB)->CompanyCC,;
				(cTRB)->CompanyCode,;
				(cTRB)->BU,;
				(cTRB)->BU_CC,;
				(cTRB)->Pesquisa,;
				(cTRB)->Export,;
				(cTRB)->Nat_Conta,;
				(cTRB)->VISAO,;
				(cTRB)->Classificao,;
				(cTRB)->CPartida,;
				(cTRB)->LP,;
				(cTRB)->VMoeda,;
				(cTRB)->Moeda,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->CodeIC,;
				(cTRB)->TMoeda,;
				(cTRB)->Cli_For,;
				(cTRB)->Pag_Rec,;
				(cTRB)->LE})



			(cTRB)->(dbSkip())
		EndDo
	EndIf

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

	(cTRB)->(dbCloseArea())

return()
