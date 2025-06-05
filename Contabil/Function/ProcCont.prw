#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

#define _Filial        1
#define _DtMov         2
#define _LoteCtb       3
#define _SLote         4
#define _Documento     5
#define _Linha         6
#define _Conta         7
#define _DescCta       8
#define _Cta_Desc      9
#define _Valor         10
#define _Historico     11
#define _CC            12
#define _TpSaldo       13
#define _Origem        14
#define _Ano           15
#define _Mes           16
#define _Periodo       17
#define _CtrlCodeSint  18
#define _DescCtrlSint  19
#define _ControlCode   20
#define _DescCtrlCode  21

#define _Pesquisa      22
#define _NatConta      23
#define _Visao         24
#define _Classific     25

#define _Base          26
#define _Sequen        27
#define _Exporta       28
#define _CntPart       29
#define _LocBase "LOCAL"

user function procont()
	local l_Job        := IsBlind()
	local cTitle       := "Processamento Contabil Periodo"
	local bProcess     := { |oSelf| GeraArq(l_Job,'','','',oSelf)}
	local cDescription := "Este programa tem como objetivo realizar o processamento contábil do periodo informado."
	local cPerg        := 'PROCONT'

	private cFunction  := ""

	If l_Job
		ConOut("Inicio da rotina de schedule procont")
		ConOut("Inicio: "+cValToChar(Date())+" - "+cValToChar(Time()))
		Prepare Environment Empresa "01" Filial "0100"

		cQuery := ""
		cQuery += " SELECT SUBSTRING(CTG_DTINI,1,6) AS PERIODO FROM CTG010 CTG
		cQuery += " WHERE CTG.D_E_L_E_T_  = ''
		cQuery += " AND CTG_FILIAL = '0100'
		cQuery += " AND CTG_STATUS = '1'
		cQuery += " GROUP BY SUBSTRING(CTG_DTINI,1,6)
		TcQuery cQuery New Alias (cTRBJOB := GetNextAlias())

		dbSelectarea((cTRBJOB))
		(cTRBJOB)->(dbGoTop())
		while (cTRBJOB)->(!eof())
			ConOut("Processamento periodo: " + (cTRBJOB)->PERIODO)
			GeraArq(l_Job, (cTRBJOB)->PERIODO,'','ZZ',nil)
			(cTRBJOB)->(dbSkip())
		EndDo
		(cTRBJOB)->(dbCloseArea())

		Reset Environment
		ConOut("Termino da rotina de schedule procont.")
		ConOut("Fim: "+cValToChar(Date())+" - "+cValToChar(Time()))
	Else
		cFunction  := Substr(FunName(),1,8)
		tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )

	EndIf

return()

//------------------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} GeraArq
gera o arquivo CSV
@type function
@version 12.1.27
@since 15/04/2022
@author Leandro Cesar (Solução Compacta)
@param lp_Job, logical, processamento esta sendo realizado via JOB
@param cp_Periodo, character, periodo de processamento
@param op_Self, object, objeto do processamento
@return logical, retorna se a rotina foi processada com sucesso
/*/
Static Function GeraArq(lp_Job as logical, cp_Periodo as character, cp_EmpDe as character, cp_EmpAte as character, op_Self as object )
	local lRet         := .t. as logical
	// Local cPasta       := ""  as character
	// Local cArquivo     := ""  as character
	Local cQuery       := ""  as character
	// Local nX           := 0   as numeric
	default cP_Periodo := substr(dTos(Date()),1,6)
	nRecQry   := 0

	If !lp_Job
		cP_Periodo := MV_PAR01
		cp_EmpDe   := MV_PAR02
		cp_EmpAte  := MV_PAR03

		If Empty(cp_EmpDe) .and. Empty(cp_EmpAte)
			cp_EmpAte := "ZZ"
		EndIf
	EndIf

	cSequen := RetSeq(cP_Periodo, 'LOCAL')

	If !lp_Job
		op_Self:SetRegua1(4)
		op_Self:SetRegua2(2)
		op_Self:IncRegua1("Validando arquivos")
	Else
		ConOut("Validando arquivos...")
	EndIf

	cQuery := ""
	If substring(cP_Periodo,5,2) == '01' // faz a consulta do saldo inicial do periodo anterior
		cPerSldIni := substr(Dtos(MonthSub(Stod(cP_Periodo+'01'),1)),1,6)+'31'
		cQuery += "  SELECT CQ0_FILIAL																													AS [Filial]
		cQuery += "  	 , '" + cPerSldIni + "'            																								AS [DtMov]
		cQuery += "      , 'SLDINI'     																												AS [LoteCtb]
		cQuery += "  	 , '999'																											        	AS [SLote]
		cQuery += "  	 , 'SLDINI'																											        	AS [Documento]
		cQuery += "  	 , '999'																										        		AS [Linha]
		cQuery += "  	 , RTRIM(CQ0_CONTA)																												AS [Conta]
		cQuery += "  	 , RTRIM(CT1_DESC01)																											AS [DescCta]
		cQuery += "  	 , RTRIM(CQ0_CONTA) + ' : ' + RTRIM(CT1_DESC01)																					AS [Cta_Desc]
		cQuery += "  	 , ROUND(SUM(CQ0_DEBITO-CQ0_CREDIT),2)																							AS [Valor]
		cQuery += "  	 , 'Saldo Inicial'																												AS [Historico]
		cQuery += "  	 , ''                                                     																		AS [CC]
		cQuery += "  	 , RTRIM(CQ0_TPSALD)																											AS [TpSaldo]
		cQuery += "  	 , 'Saldo Inicial'																												AS [Origem]
		cQuery += "  	 , SUBSTRING('" + cPerSldIni + "',1,4)	    																					AS [Ano]
		cQuery += "  	 , SUBSTRING('" + cPerSldIni + "',5,2)																							AS [Mes]
		cQuery += "  	 , SUBSTRING('" + cPerSldIni + "',1,4)+'-'+SUBSTRING('" + cPerSldIni + "',5,2)													AS [Periodo]
		cQuery += "  	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')																						AS [CtrlCodeSint]
		cQuery += "  	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')																						AS [DescCtrlSint]
		cQuery += "  	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')																						AS [ControlCode]
		cQuery += "  	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')																						AS [DescCtrlCode]
		cQuery += "  	 , ''																															AS [CompanyCC]
		cQuery += "  	 , ISNULL(ltrim(rtrim(ZM_ID)),'')																								AS [CompanyCode]
		cQuery += "  	 , ''																															AS [BU]
		cQuery += "  	 , ''																															AS [BU_CC]
		cQuery += "  	 ,'Saldo Inicial'																												AS [Pesquisa]
		cQuery += "  	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
		cQuery += "  					   WHEN '02' THEN 'Conta de Passivo'
		cQuery += "  					   WHEN '03' THEN 'Patrimônio Líquido'
		cQuery += "  					   WHEN '04' THEN 'Conta de Resultado'
		cQuery += "  					   WHEN '05' THEN 'Conta de Compensação'
		cQuery += "  					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
		cQuery += "  	 , CASE WHEN SUBSTRING(CQ0_CONTA,1,1) IN ('1','2') THEN 'BALANCO' ELSE 'DRE' END AS [VISAO]
		cQuery += "  	 , '' as [Classificao]
		cQuery += "    FROM " + RetSqlName("CQ0") + " CQ0 with(nolock)
		cQuery += "   INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT1_CONTA = CQ0_CONTA AND CT1.D_E_L_E_T_ = ''
		cQuery += "   INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CQ0_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
		cQuery += "    LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CQ0_CONTA AND CVD.D_E_L_E_T_ = ''
		cQuery += "    LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
		cQuery += "    LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
		cQuery += "   WHERE CQ0.D_E_L_E_T_ = ''
		cQuery += "     AND CQ0_DATA <= '" + cPerSldIni + "'
		cQuery += "     AND SUBSTRING(CQ0_FILIAL,1,2) >= '" + cp_EmpDe + "'
		cQuery += "     AND SUBSTRING(CQ0_FILIAL,1,2) <= '" + cp_EmpAte + "'
		cQuery += "  GROUP BY CQ0_FILIAL, RTRIM(CQ0_CONTA), RTRIM(CT1_DESC01), RTRIM(CQ0_CONTA) + ' : ' + RTRIM(CT1_DESC01), RTRIM(CQ0_TPSALD)
		cQuery += "         , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),''), ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')
		cQuery += " 		, ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),''), ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),''), ISNULL(ltrim(rtrim(ZM_ID)),'')
		cQuery += " 		, CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
		cQuery += "  					   WHEN '02' THEN 'Conta de Passivo'
		cQuery += "  					   WHEN '03' THEN 'Patrimônio Líquido'
		cQuery += "  					   WHEN '04' THEN 'Conta de Resultado'
		cQuery += "  					   WHEN '05' THEN 'Conta de Compensação'
		cQuery += "  					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END

		cQuery += " UNION ALL
	EndIf

	cQuery += " SELECT CT2_FILIAL																													AS [Filial]
	cQuery += " 	 , CT2_DATA                        																								AS [DtMov]
	cQuery += "      , RTRIM(CT2_LOTE)																												AS [LoteCtb]
	cQuery += " 	 , RTRIM(CT2_SBLOTE)																											AS [SLote]
	cQuery += " 	 , RTRIM(CT2_DOC)																												AS [Documento]
	cQuery += " 	 , RTRIM(CT2_LINHA)																												AS [Linha]
	cQuery += " 	 , RTRIM(CT2_DEBITO)																											AS [Conta]
	cQuery += " 	 , RTRIM(CT1_DESC01)																											AS [DescCta]
	cQuery += " 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)																				AS [Cta_Desc]
	cQuery += " 	 , CT2_VALOR																													AS [Valor]
	cQuery += " 	 , RTRIM(CT2_HIST)																												AS [Historico]
	cQuery += " 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')																		AS [CC]
	cQuery += " 	 , RTRIM(CT2_TPSALD)																											AS [TpSaldo]
	cQuery += " 	 , RTRIM(CT2_ORIGEM)																											AS [Origem]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)																										AS [Ano]
	cQuery += " 	 , SUBSTRING(CT2_DATA,5,2)																										AS [Mes]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)																			AS [Periodo]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')																						AS [CtrlCodeSint]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')																						AS [DescCtrlSint]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')																						AS [ControlCode]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')																						AS [DescCtrlCode]
	cQuery += " 	 , ''																															AS [CompanyCC]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZM_ID)),'')																								AS [CompanyCode]
	cQuery += " 	 , ''																															AS [BU]
	cQuery += " 	 , ''																															AS [BU_CC]
	cQuery += " 	 , ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 , 'BALANCO' AS [VISAO]
	cQuery += " 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM " + RetSqlName("CTS") + " WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = '002' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != ''  ),'') as [Classificao]
	cQuery += "   FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += "  INNER JOIN  " + RetSqlname("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += "  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlname("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
	cQuery += " 	AND SUBSTRING(CT2_DEBITO,1,1) IN ('1','2')
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'

	cQuery += " UNION ALL

	cQuery += " SELECT CT2_FILIAL																													AS [Filial]
	cQuery += " 	 , CT2_DATA                        																								AS [DtMov]
	cQuery += "     , RTRIM(CT2_LOTE)																												AS [LoteCtb]
	cQuery += " 	 , RTRIM(CT2_SBLOTE)																											AS [SLote]
	cQuery += " 	 , RTRIM(CT2_DOC)																												AS [Documento]
	cQuery += " 	 , RTRIM(CT2_LINHA)																												AS [Linha]
	cQuery += " 	 , RTRIM(CT2_DEBITO)																											AS [Conta]
	cQuery += " 	 , RTRIM(CT1_DESC01)																											AS [DescCta]
	cQuery += " 	 , RTRIM(CT2_DEBITO) + ' : ' + RTRIM(CT1_DESC01)																				AS [Cta_Desc]
	cQuery += " 	 , CT2_VALOR																													AS [Valor]
	cQuery += " 	 , RTRIM(CT2_HIST)																												AS [Historico]
	cQuery += " 	 , RTRIM(CT2_CCD) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')																		AS [CC]
	cQuery += " 	 , RTRIM(CT2_TPSALD)																											AS [TpSaldo]
	cQuery += " 	 , RTRIM(CT2_ORIGEM)																											AS [Origem]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)																										AS [Ano]
	cQuery += " 	 , SUBSTRING(CT2_DATA,5,2)																										AS [Mes]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)																			AS [Periodo]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')																						AS [CtrlCodeSint]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')																						AS [DescCtrlSint]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')																						AS [ControlCode]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')																						AS [DescCtrlCode]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')																							AS [CompanyCC]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')																							AS [CompanyCode]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')																							AS [BU]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')																							AS [BU_CC]
	cQuery += " 	 , ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
	cQuery += " 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 , 'DRE' AS [VISAO]
	cQuery += " 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM " + RetSqlName("CTS") + " WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += "   FROM " + RetSqlName("CT2") + " CT2 with(nolock)
	cQuery += "  INNER JOIN  " + RetSqlname("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += "  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlname("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCD AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
	cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
	cQuery += " 	AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'

	cQuery += " UNION ALL

	cQuery += " SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 , CT2_DATA                     							AS [DtMov]
	cQuery += "      , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 , ''																															AS [CompanyCC]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZM_ID)),'')																								AS [CompanyCode]
	cQuery += " 	 , ''																															AS [BU]
	cQuery += " 	 , ''																															AS [BU_CC]
	cQuery += " 	 , ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 , 'BALANCO' AS [VISAO]
	cQuery += " 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM " + RetSqlName("CTS") + " WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = '002' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2'  AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += "   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += "  INNER JOIN  " + RetSqlname("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += "  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlname("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += "  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
	cQuery += " 	AND SUBSTRING(CT2_CREDIT,1,1) IN ('1','2')
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'

	cQuery += " UNION ALL

	cQuery += " SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 , CT2_DATA                     							AS [DtMov]
	cQuery += "      , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 , RTRIM(CT2_CREDIT)										AS [Conta]
	cQuery += " 	 , RTRIM(CT1_DESC01)										AS [DescCta]
	cQuery += " 	 , RTRIM(CT2_CREDIT) + ' : ' + RTRIM(CT1_DESC01)			AS [Cta_Desc]
	cQuery += " 	 , CT2_VALOR * -1											AS [Valor]
	cQuery += " 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 , RTRIM(CT2_CCC) + ISNULL(' - ' + RTRIM(CTT_DESC01),'')	AS [CC]
	cQuery += " 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),'')					AS [CtrlCodeSint]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')					AS [DescCtrlSint]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),'')					AS [ControlCode]
	cQuery += " 	 , ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')					AS [DescCtrlCode]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')						AS [CompanyCC]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')						AS [BU]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
	cQuery += " 	 , ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
	cQuery += " 					   WHEN '02' THEN 'Conta de Passivo'
	cQuery += " 					   WHEN '03' THEN 'Patrimônio Líquido'
	cQuery += " 					   WHEN '04' THEN 'Conta de Resultado'
	cQuery += " 					   WHEN '05' THEN 'Conta de Compensação'
	cQuery += " 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
	cQuery += " 	 , 'DRE' AS [VISAO]
	cQuery += " 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM " + RetSqlName("CTS") + " WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
	cQuery += "   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += "  INNER JOIN  " + RetSqlname("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
	cQuery += "  INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP  = SUBSTRING(CT2_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlname("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
	cQuery += "   LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = CT2_CCC AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
	cQuery += "  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
	cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
	cQuery += " 	AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'

	cQuery += " UNION ALL

	cQuery += " SELECT CT2_FILIAL												AS [Filial]
	cQuery += " 	 , CT2_DATA                     							AS [DtMov]
	cQuery += "      , RTRIM(CT2_LOTE)											AS [LoteCtb]
	cQuery += " 	 , RTRIM(CT2_SBLOTE)										AS [SLote]
	cQuery += " 	 , RTRIM(CT2_DOC)											AS [Documento]
	cQuery += " 	 , RTRIM(CT2_LINHA)											AS [Linha]
	cQuery += " 	 , RTRIM('')										        AS [Conta]
	cQuery += " 	 , RTRIM('')										        AS [DescCta]
	cQuery += " 	 , ''			                                            AS [Cta_Desc]
	cQuery += " 	 , 0										                AS [Valor]
	cQuery += " 	 , RTRIM(CT2_HIST)											AS [Historico]
	cQuery += " 	 , RTRIM(CT2_CCC)	                                        AS [CC]
	cQuery += " 	 , RTRIM(CT2_TPSALD)										AS [TpSaldo]
	cQuery += " 	 , RTRIM(CT2_ORIGEM)										AS [Origem]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)									AS [Ano]
	cQuery += " 	 , SUBSTRING(CT2_DATA,5,2)									AS [Mes]
	cQuery += " 	 , SUBSTRING(CT2_DATA,1,4)+'-'+SUBSTRING(CT2_DATA,5,2)		AS [Periodo]
	cQuery += " 	 , ''                                               		AS [CtrlCodeSint]
	cQuery += " 	 , ''                                               		AS [DescCtrlSint]
	cQuery += " 	 , ''                                               		AS [ControlCode]
	cQuery += " 	 , ''                                               		AS [DescCtrlCode]
	cQuery += " 	 , ''					                                    AS [CompanyCC]
	cQuery += " 	 , ISNULL(ltrim(rtrim(ZM_ID)),'')							AS [CompanyCode]
	cQuery += " 	 , ''						                                AS [BU]
	cQuery += " 	 , ''						                                AS [BU_CC]
	cQuery += " 	 , ltrim((CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
	cQuery += " 	 , '' as [Nat_Conta]
	cQuery += " 	 , '' AS [VISAO]
	cQuery += " 	 , '' as [Classificao]
	cQuery += "   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
	cQuery += "     INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
	cQuery += "  WHERE CT2.D_E_L_E_T_ = ''
	cQuery += "    AND CT2_DC = '4'
	cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
	cQuery += "     AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'
	__oStatement := FWPreparedStatement():New()

	nRecQry := 0
	__oStatemen:SetQuery(cQuery)
	__oStatemen:SetString(1,cP_Periodo)
	__oStatemen:SetString(2,cP_Periodo)
	__oStatemen:SetString(3,cP_Periodo)
	__oStatemen:SetString(4,cP_Periodo)
	__oStatemen:SetString(5,cP_Periodo)
	TcQuery __oStatemen:GetFixQuery() New Alias (cAliasQry 	:= GetNextAlias())

	Count To nRecQry
	nLin      := 0
	If !lp_Job
		op_Self:SetRegua2(nRecQry)
	EndIf

	dbSelectArea((cAliasQry))
	(cAliasQry)->(dbGoTop())
	If !(cAliasQry)->(EoF())
		If !lp_Job
			op_Self:IncRegua1("Excluindo registros do periodo")
		Else
			ConOut("Excluindo registros do periodo...")
		EndIf

		DelMov(cp_Periodo, 'LOCAL', cp_EmpDe, cp_EmpAte )
		//exclui movimentos do saldo inicial
		If substr(cp_Periodo,5,2) == '01'
			cPerSldIni := substr(Dtos(MonthSub(Stod(cP_Periodo+'01'),1)),1,6)
			DelMovSI(cPerSldIni, 'LOCAL', cp_EmpDe, cp_EmpAte )
		EndIf

		If !lp_Job
			op_Self:IncRegua1("Gravando registros na tabela")
		Else
			ConOut("Gravando registros na tabela...")
		EndIf

		While !(cAliasQry)->(EoF())
			nLin += 1

			If !lp_Job
				op_Self:IncRegua2("Gravando registro " + cValToChar(nLin) + " de " + cValToChar(nRecQry) + "...")
			Else
				ConOut("Gravando registro " + cValToChar(nLin) + " de " + cValToChar(nRecQry) + "...")
			EndIf

			reclock("SZP",.T.)
			SZP->ZP_FILIAL  := (cAliasQry)->Filial
			SZP->ZP_DATA    := sTod((cAliasQry)->DtMov)
			SZP->ZP_LOTE    := (cAliasQry)->LoteCtb
			SZP->ZP_SLOTE   := (cAliasQry)->SLote
			SZP->ZP_DOCUMEN := (cAliasQry)->Documento
			SZP->ZP_LINHA   := (cAliasQry)->Linha
			SZP->ZP_CONTA   := (cAliasQry)->Conta
			SZP->ZP_DESCCTA := (cAliasQry)->DescCta
			SZP->ZP_CTADESC := (cAliasQry)->Cta_Desc
			SZP->ZP_VALOR   := (cAliasQry)->Valor
			SZP->ZP_HISTOR  := (cAliasQry)->Historico
			SZP->ZP_CCUSTO  := (cAliasQry)->CC
			SZP->ZP_TPSALDO := (cAliasQry)->TpSaldo
			SZP->ZP_ORIGEM  := (cAliasQry)->Origem
			SZP->ZP_ANO     := (cAliasQry)->Ano
			SZP->ZP_MES     := (cAliasQry)->Mes
			SZP->ZP_PERIODO := (cAliasQry)->Periodo
			SZP->ZP_CTRLCOD := (cAliasQry)->ControlCode
			SZP->ZP_CPNYCC  := (cAliasQry)->CompanyCC
			SZP->ZP_CPNYCOD := (cAliasQry)->CompanyCode
			SZP->ZP_BU      := (cAliasQry)->BU
			SZP->ZP_BU_CC   := (cAliasQry)->BU_CC
			SZP->ZP_PESQUIS := (cAliasQry)->Pesquisa
			SZP->ZP_BASE    := _LocBase
			SZP->ZP_SEQUEN  := cSequen
			SZP->ZP_EXPORT  := dTos(Date()) + " - " + substr(Time(),1,5)
			SZP->ZP_IMPORT  := dTos(Date()) + " - " + substr(Time(),1,5)

			SZP->ZP_CTRLSUP := (cAliasQry)->CtrlCodeSint
			SZP->ZP_DSCSUP  := (cAliasQry)->DescCtrlSint
			SZP->ZP_DSCCTA  := (cAliasQry)->DescCtrlCode
			SZP->ZP_NATCTA1 := (cAliasQry)->Nat_Conta
			SZP->ZP_DREBAL  := (cAliasQry)->VISAO
			SZP->ZP_CLASSVS := (cAliasQry)->Classificao
			SZP->(MSUnLock())


			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		If !lp_Job
			op_Self:SaveLog("Fim de processamento")
		Else
			ConOut("Fim de processamento")
		EndIf

		// cPasta  := '\Downloads\IntContabil\'
		// FWMakeDir(cPasta)
		// lContinua := .F.
		// For nX := 1 to 10
		// 	If U_ConnectFTP()
		// 		lContinua := .T.
		// 		Exit
		// 	EndIf
		// Next nX

		// If lContinua
		// 	aDirCSV := Directory( cPasta +"*.csv" )
		// 	aEval(aDirCSV,{|x| Ferase( cPasta + aDirCSV[x,1] )})

		// 	cArquivo := cp_Periodo + ".CSV"

		// 	cFileZip := strTran(cPasta + cArquivo,".CSV",".ZIP")
		// 	If FZip(cFileZip,{cPasta + cArquivo},cPasta) == 0
		// 		FErase(cPasta + cArquivo)

		// 		cDestFile :=  "c:\temp\arquivo.zip"
		// 		cFolderZipD := "c:\temp\" + cp_Periodo + "\"
		// 		FwMakeDir(cFolderZipD)
		// 		If file(cFileZip)
		// 			__CopyFile(cFileZip, cDestFile)

		// 			If file(cDestFile)
		// 				FUnZip(cDestFile,cFolderZipD)

		// 				If file(cFolderZipD + cArquivo)
		// 					op_Self:IncRegua1("Importando Registros CSV")
		// 					LerCSV(cFolderZipD + cArquivo, cp_Periodo, op_Self)
		// 				EndIf
		// 			EndIf
		// 			op_Self:SaveLog("Fim de processamento")
		// 		EndIf

		// 	Else
		// 		op_Self:SaveLog("Falha na compactacao do arquivo")
		// 	EndIf
		// EndIf
	EndIf

Return lRet

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

User Function ImpCSVCloud()

	local cTitle       := "Importação CSV - Cloud"
	local bProcess     := { |oSelf| LerCSV(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,oSelf)}
	local cDescription := "Este programa tem como objetivo realizar a importacao dos registros contábil gerado pela base em Cloud."
	local cPerg        := 'PROCONT2'

	cFunction  := Substr(FunName(),1,8)
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )


Return

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

static function LerCSV(cp_File as character, cp_Periodo as character, cp_EmpDe as character, cp_EmpAte as character, op_Self)
	local cLinha      := "" as character
	local aLinha      := {} as array
	local aFields     := {} as array
	default cp_File   := ""
	default cp_EmpDe  := " "
	default cp_EmpAte := "ZZ"


	If !File(cp_File)
		Return(.F.)
	EndIf

	If right(upper(alltrim(cp_File)),3) != 'CSV'
		FwAlertError("Extencao do arquivo invalido. Favor informar um arquivo com extencao CSV.","Validacao Arquivo")
		return(.F.)
	EndIf

	cSequen := RetSeq(cP_Periodo, 'CLOUD')

	op_Self:SetRegua1(3)
	op_Self:SetRegua2(3)
	op_Self:IncRegua1("Criando estrutura temporaria")

	oFileAux := FWFileReader():New(cp_File)
	nLin    := 0
	nRecQry := 0
	If (oFileAux:Open())
		aContent := oFileAux:GetAllLines()
		nRecQry := len(aContent)
	EndIf
	oFileAux:Close()
	aContent := nil
	oFile := FWFileReader():New(cp_File)
	If (oFile:Open())
		aFields    := {}
		cAlias     := GetNextAlias()
		oTempTable := FWTemporaryTable():New(cAlias )

		aAdd( aFields, {'FILIAL'       		,GetSx3Cache('ZP_FILIAL','X3_TIPO')     ,	GetSx3Cache('ZP_FILIAL','X3_TAMANHO')   ,		0})
		aAdd( aFields, {'DATAMOV'   		,GetSx3Cache('ZP_DATA','X3_TIPO')       ,	GetSx3Cache('ZP_DATA','X3_TAMANHO')     ,		0})
		aAdd( aFields, {'LOTE'		        ,GetSx3Cache('ZP_LOTE','X3_TIPO')       ,	GetSx3Cache('ZP_LOTE','X3_TAMANHO')     ,		0})
		aAdd( aFields, {'SLOTE'   		    ,GetSx3Cache('ZP_SLOTE','X3_TIPO')      ,	GetSx3Cache('ZP_SLOTE','X3_TAMANHO')    ,		0})
		aAdd( aFields, {'DOCUMENTO'   		,GetSx3Cache('ZP_DOCUMEN','X3_TIPO')    ,	GetSx3Cache('ZP_DOCUMEN','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'LINHA'      	    ,GetSx3Cache('ZP_LINHA','X3_TIPO')      ,	GetSx3Cache('ZP_LINHA','X3_TAMANHO')    ,		0})
		aAdd( aFields, {'CONTA'         	,GetSx3Cache('ZP_CONTA','X3_TIPO')      ,	GetSx3Cache('ZP_CONTA','X3_TAMANHO')    ,		0})
		aAdd( aFields, {'DESCCTA'           ,GetSx3Cache('ZP_DESCCTA','X3_TIPO')    ,	GetSx3Cache('ZP_DESCCTA','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'CTADESC'  		    ,GetSx3Cache('ZP_CTADESC','X3_TIPO')    ,	GetSx3Cache('ZP_CTADESC','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'VALOR'		        ,GetSx3Cache('ZP_VALOR','X3_TIPO')      ,	GetSx3Cache('ZP_VALOR','X3_TAMANHO')    ,		GetSx3Cache('ZP_VALOR','X3_DECIMAL')})
		aAdd( aFields, {'HISTORICO'		    ,GetSx3Cache('ZP_HISTOR','X3_TIPO')     ,	GetSx3Cache('ZP_HISTOR','X3_TAMANHO')   ,		0})
		aAdd( aFields, {'CC'		        ,GetSx3Cache('ZP_CCUSTO','X3_TIPO')     ,	GetSx3Cache('ZP_CCUSTO','X3_TAMANHO')   ,		0})
		aAdd( aFields, {'TPSALDO'		    ,GetSx3Cache('ZP_TPSALDO','X3_TIPO')    ,	GetSx3Cache('ZP_TPSALDO','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'ORIGEM'		    ,GetSx3Cache('ZP_ORIGEM','X3_TIPO')     ,	GetSx3Cache('ZP_ORIGEM','X3_TAMANHO')   ,		0})
		aAdd( aFields, {'ANO'		        ,GetSx3Cache('ZP_ANO','X3_TIPO')        ,	GetSx3Cache('ZP_ANO','X3_TAMANHO')      ,		0})
		aAdd( aFields, {'MES'		        ,GetSx3Cache('ZP_MES','X3_TIPO')        ,	GetSx3Cache('ZP_MES','X3_TAMANHO')      ,		0})
		aAdd( aFields, {'PERIODO'		    ,GetSx3Cache('ZP_PERIODO','X3_TIPO')    ,	GetSx3Cache('ZP_PERIODO','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'CTASUP'		    ,GetSx3Cache('ZP_CTRLSUP','X3_TIPO')    ,	GetSx3Cache('ZP_CTRLSUP','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'DSCSUP'		    ,GetSx3Cache('ZP_DSCSUP','X3_TIPO')     ,	GetSx3Cache('ZP_DSCSUP','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'CTRLCODE'		    ,GetSx3Cache('ZP_CTRLCOD','X3_TIPO')    ,	GetSx3Cache('ZP_CTRLCOD','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'DSCCTRL'		    ,GetSx3Cache('ZP_DSCCTA','X3_TIPO')     ,	GetSx3Cache('ZP_DSCCTA','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'PESQUISA'		    ,GetSx3Cache('ZP_PESQUIS','X3_TIPO')    ,	GetSx3Cache('ZP_PESQUIS','X3_TAMANHO')  ,		0})

		aAdd( aFields, {'NATUREZA'		    ,GetSx3Cache('ZP_NATCTA1','X3_TIPO')    ,	GetSx3Cache('ZP_NATCTA1','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'VISAO'		        ,GetSx3Cache('ZP_DREBAL','X3_TIPO')     ,	GetSx3Cache('ZP_DREBAL','X3_TAMANHO')  ,		0})
		aAdd( aFields, {'CLASSIFICA'		,GetSx3Cache('ZP_CLASSVS','X3_TIPO')    ,	GetSx3Cache('ZP_CLASSVS','X3_TAMANHO')  ,		0})

		aAdd( aFields, {'BASE'		        ,GetSx3Cache('ZP_BASE','X3_TIPO')       ,	GetSx3Cache('ZP_BASE','X3_TAMANHO')     ,		0})
		aAdd( aFields, {'SEQUEN'		    ,GetSx3Cache('ZP_SEQUEN','X3_TIPO')     ,	GetSx3Cache('ZP_SEQUEN','X3_TAMANHO')   ,		0})
		aAdd( aFields, {'EXPORTA'		    ,GetSx3Cache('ZP_EXPORT','X3_TIPO')     ,	GetSx3Cache('ZP_EXPORT','X3_TAMANHO')   ,		0})


		oTemptable:SetFields( aFields )
		oTempTable:AddIndex("01", {"FILIAL","DATAMOV","LOTE","SLOTE","DOCUMENTO","LINHA"}  )
		oTempTable:Create()

		TcSQLExec("SET IDENTITY_INSERT "+oTemptable:GetRealName()+" ON ")
		cCampoIns := ""
		aEval(aFields,{|x| cCampoIns += x[1] + ','})
		cCampoIns := substr(cCampoIns,1,len(cCampoIns)-1)
		op_Self:IncRegua1("Importando registros CSV")
		lContinua := .T.
		lOldFil := .F.
		If ! (oFile:EoF())
			DelMov(cp_Periodo, 'CLOUD', cp_EmpDe, cp_EmpAte )

			//exclui movimentos do saldo inicial
			If substr(cp_Periodo,5,2) == '01'
				cPerSldIni := substr(Dtos(MonthSub(Stod(cP_Periodo+'01'),1)),1,6)
				DelMovSI(cPerSldIni, 'CLOUD', cp_EmpDe, cp_EmpAte)
			EndIf

			TcSQLExec(" TRUNCATE TABLE " + oTemptable:GetRealName() )
			While (oFile:HasLine())
				nLin += 1

				cLinha := oFile:GetLine()
				cLinha := strTran(cLinha,"'","")
				aLinha := StrTokArr2( cLinha, ";", .T. )

				If nLin == 1
					if alltrim(upper(cLinha)) != 'FILIAL;DT_MOV;LOTE_CTB;SUB_LOTE;DOCUMENTO;LINHA;CONTA;DESC_CTA;CTA_DESC;VALOR;HISTORICO;CC;TP_SALDO;ORIGEM;ANO;MES;PERIODO;CTRL_CODE_SINT;DESC_CTRL_SINT;CONTROL_CODE;DESC_CONTROL_CODE;PESQUISA;NATUREZA_CONTA;VISCAO;CLASSIFICACAO;LOCAL;SEQUEN;LOG;CONT_PARTIDA;FIM'
						FwAlertError("Estrutura do arquivo invalido.","Erro arquivo")
						lContinua := .F.
						Exit
					EndIf
				Else
					op_Self:IncRegua2("Importando registro " + cValToChar(nLin) + " de " + cValToChar(nRecQry) + "...")

					// cDados := "'" + alltrim(aLinha[_Filial])    + "','" + ;
						// 	alinha[_DtMov]                          + "','" + ;
						// 	alltrim(alinha[_LoteCtb])               + "','" + ;
						// 	alltrim(alinha[_SLote])                 + "','" + ;
						// 	alltrim(alinha[_Documento])             + "','" + ;
						// 	alltrim(alinha[_Linha])                 + "','" + ;
						// 	alltrim(alinha[_Conta])                 + "','" + ;
						// 	alltrim(alinha[_DescCta])               + "','" + ;
						// 	alltrim(alinha[_Cta_Desc])              + "'," + ;
						// 	alinha[_Valor]                          + ",'" + ;
						// 	alltrim(alinha[_Historico])             + "','" + ;
						// 	alltrim(alinha[_CC])                    + "','" + ;
						// 	alltrim(alinha[_TpSaldo])               + "','" + ;
						// 	alltrim(alinha[_Origem])                + "','" + ;
						// 	alltrim(alinha[_Ano])                   + "','" + ;
						// 	alltrim(alinha[_Mes])                   + "','" + ;
						// 	alltrim(alinha[_Periodo])               + "','" + ;
						// 	alltrim(alinha[_CtrlCodeSint])          + "','" + ;
						// 	alltrim(alinha[_DescCtrlSint])          + "','" + ;
						// 	alltrim(alinha[_ControlCode])           + "','" + ;
						// 	alltrim(alinha[_DescCtrlCode])          + "','" + ;
						// 	alltrim(alinha[_Pesquisa])              + "','" + ;
						// 	alltrim(alinha[_NatConta])              + "','" + ;
						// 	alltrim(alinha[_Visao])                 + "','" + ;
						// 	alltrim(alinha[_Classific])             + "','" + ;
						// 	alltrim(alinha[_Base])                  + "','" + ;
						// 	cSequen                                 + "','" + ;
						// 	alltrim(alinha[_Exporta])               + "'"


					// TcSQLExec(" INSERT INTO " + oTemptable:GetRealName() + " (" + cCampoIns + ") VALUES (" + cDados + ")")

					cHistAux := FWCutOff(alltrim(alinha[11]),.T.)
					If alltrim(aLinha[_Filial]) >= cp_EmpDe .and. alltrim(aLinha[_Filial]) <= cp_EmpAte
						reclock("SZP",.T.)
						SZP->ZP_FILIAL  := alltrim(aLinha[_Filial])
						SZP->ZP_DATA    := sTod(alinha[_DtMov])
						SZP->ZP_LOTE    := alltrim(alinha[_LoteCtb])
						SZP->ZP_SLOTE   := alltrim(alinha[_SLote])
						SZP->ZP_DOCUMEN := alltrim(alinha[_Documento])
						SZP->ZP_LINHA   := alltrim(alinha[_Linha])
						SZP->ZP_CONTA   := alltrim(alinha[_Conta])
						SZP->ZP_DESCCTA := alltrim(alinha[_DescCta])
						SZP->ZP_CTADESC := alltrim(alinha[_Cta_Desc])
						SZP->ZP_VALOR   := val(alinha[_Valor])
						SZP->ZP_HISTOR  := cHistAux
						SZP->ZP_CCUSTO  := alltrim(alinha[_CC])
						SZP->ZP_TPSALDO := alltrim(alinha[_TpSaldo])
						SZP->ZP_ORIGEM  := alltrim(alinha[_Origem])
						SZP->ZP_ANO     := alltrim(alinha[_Ano])
						SZP->ZP_MES     := alltrim(alinha[_Mes])
						SZP->ZP_PERIODO := alltrim(alinha[_Periodo])
						SZP->ZP_CTRLCOD := alltrim(alinha[_ControlCode])
						SZP->ZP_DSCCTA  := alltrim(alinha[_DescCtrlCode])
						SZP->ZP_BASE    := alltrim(alinha[_Base])
						SZP->ZP_SEQUEN  := cSequen
						SZP->ZP_EXPORT  := alltrim(alinha[_Exporta])
						SZP->ZP_IMPORT  := dTos(Date()) + " - " + substr(Time(),1,5)
						SZP->ZP_CTRLSUP := alltrim(alinha[_CtrlCodeSint])
						SZP->ZP_DSCSUP  := alltrim(alinha[_DescCtrlSint])
						SZP->ZP_NATCTA1 := alltrim(alinha[_NatConta])
						SZP->ZP_DREBAL  := alltrim(alinha[_Visao])
						SZP->ZP_CLASSVS := alltrim(alinha[_Classific])
						If SZP->(FieldPos("ZP_CNTPART"))
							SZP->ZP_CNTPART := alltrim(alinha[_CntPart])
						Endif
						SZP->(MSUnLock())
					Else
						lOldFil := .T.
					EndIf
				EndIf
			EndDo
		EndIf
		oFile:Close()

		If lOldFil
			FwAlertWarnin("Foram identificados registros de outra filial no arquivo, esses nao foram importados.","Aviso")
		EndIf

		// If !lContinua
		// 	return(.F.)
		// EndIf

		// nRecQry := 0
		// cQuery := ""
		// cQuery += " SELECT FILIAL
		// cQuery += "     , DATAMOV
		// cQuery += "     , LOTE
		// cQuery += "     , SLOTE
		// cQuery += "     , DOCUMENTO
		// cQuery += "     , LINHA
		// cQuery += "     , CONTA
		// cQuery += "     , DESCCTA
		// cQuery += "     , CTADESC
		// cQuery += "     , VALOR
		// cQuery += "     , HISTORICO
		// cQuery += "     , CC
		// cQuery += "     , TPSALDO
		// cQuery += "     , ORIGEM
		// cQuery += "     , ANO
		// cQuery += "     , MES
		// cQuery += "     , PERIODO
		// cQuery += "     , CTASUP
		// cQuery += "     , DSCSUP
		// cQuery += "     , CTRLCODE
		// cQuery += "     , DSCCTRL
		// cQuery += "     , ''								AS [CompanyCC]
		// cQuery += "     , ISNULL(ltrim(rtrim(ZM_ID)),'')	AS [CompanyCode]
		// cQuery += "     , ''								AS [BU]
		// cQuery += "     , ''								AS [BU_CC]
		// cQuery += "     , PESQUISA
		// cQuery += "     , NATUREZA
		// cQuery += "     , VISAO
		// cQuery += "     , CLASSIFICA
		// cQuery += "     , BASE
		// cQuery += "     , SEQUEN
		// cQuery += "     , EXPORTA
		// cQuery += "      FROM " + oTemptable:GetRealName() + " TMP  WITH(NOLOCK)
		// cQuery += "      INNER JOIN " + RetSqlName("SZM") + " SZM with(nolock) ON ZM_FILEMP = SUBSTRING(FILIAL,1,2) AND ZM_LOCALID = 'CLOUD' AND SZM.D_E_L_E_T_ = ''
		// cQuery += "      WHERE LOTE = 'SLDINI'
		// cQuery += "        AND VISAO != 'BALANCO'

		// cQuery += "      UNION ALL

		// cQuery += "      SELECT FILIAL
		// cQuery += "     , DATAMOV
		// cQuery += "     , LOTE
		// cQuery += "     , SLOTE
		// cQuery += "     , DOCUMENTO
		// cQuery += "     , LINHA
		// cQuery += "     , CONTA
		// cQuery += "     , DESCCTA
		// cQuery += "     , CTADESC
		// cQuery += "     , VALOR
		// cQuery += "     , HISTORICO
		// cQuery += "     , CC
		// cQuery += "     , TPSALDO
		// cQuery += "     , ORIGEM
		// cQuery += "     , ANO
		// cQuery += "     , MES
		// cQuery += "     , PERIODO
		// cQuery += "     , CTASUP
		// cQuery += "     , DSCSUP
		// cQuery += "     , CTRLCODE
		// cQuery += "     , DSCCTRL
		// cQuery += "     , ''								AS [CompanyCC]
		// cQuery += "     , ISNULL(ltrim(rtrim(ZM_ID)),'')	AS [CompanyCode]
		// cQuery += "     , ''								AS [BU]
		// cQuery += "     , ''								AS [BU_CC]
		// cQuery += "     , PESQUISA
		// cQuery += "     , NATUREZA
		// cQuery += "     , VISAO
		// cQuery += "     , CLASSIFICA
		// cQuery += "     , BASE
		// cQuery += "     , SEQUEN
		// cQuery += "     , EXPORTA
		// cQuery += "      FROM " + oTemptable:GetRealName() + " TMP  WITH(NOLOCK)
		// cQuery += "      INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(FILIAL,1,2) AND ZM_LOCALID = 'CLOUD' AND SZM.D_E_L_E_T_ = ''
		// cQuery += "      WHERE VISAO = 'BALANCO'

		// cQuery += "      UNION ALL

		// cQuery += "      SELECT FILIAL
		// cQuery += "     , DATAMOV
		// cQuery += "     , LOTE
		// cQuery += "     , SLOTE
		// cQuery += "     , DOCUMENTO
		// cQuery += "     , LINHA
		// cQuery += "     , CONTA
		// cQuery += "     , DESCCTA
		// cQuery += "     , CTADESC
		// cQuery += "     , VALOR
		// cQuery += "     , HISTORICO
		// cQuery += "     , CC
		// cQuery += "     , TPSALDO
		// cQuery += "     , ORIGEM
		// cQuery += "     , ANO
		// cQuery += "     , MES
		// cQuery += "     , PERIODO
		// cQuery += "     , CTASUP
		// cQuery += "     , DSCSUP
		// cQuery += "     , CTRLCODE
		// cQuery += "     , DSCCTRL
		// cQuery += "     , ISNULL(ltrim(rtrim(ZO_EMPXCC)),'')					AS [CompanyCC]
		// cQuery += "     , ISNULL(ltrim(rtrim(ZO_IDEMP)),'')						AS [CompanyCode]
		// cQuery += "     , ISNULL(ltrim(rtrim(ZO_CODBUS)),'')					AS [BU]
		// cQuery += "     , ISNULL(ltrim(rtrim(ZO_IDBUS)),'')						AS [BU_CC]
		// cQuery += "     , PESQUISA
		// cQuery += "     , NATUREZA
		// cQuery += "     , VISAO
		// cQuery += "     , CLASSIFICA
		// cQuery += "     , BASE
		// cQuery += "     , SEQUEN
		// cQuery += "     , EXPORTA
		// cQuery += "      FROM " + oTemptable:GetRealName() + " TMP  WITH(NOLOCK)
		// cQuery += "      INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(FILIAL,1,2) AND ZM_LOCALID = 'CLOUD' AND SZM.D_E_L_E_T_ = ''
		// cQuery += "       LEFT JOIN  " + RetSqlName("SZO") + "  SZO with(nolock) ON ZO_CC = SUBSTRING(TMP.CC,1,CHARINDEX(' - ', TMP.CC)) AND SZO.D_E_L_E_T_ = '' AND ZO_IDEMP = ZM_ID
		// cQuery += "      WHERE VISAO = 'DRE'

		// cQuery += "      UNION ALL

		// cQuery += "      SELECT FILIAL
		// cQuery += "     , DATAMOV
		// cQuery += "     , LOTE
		// cQuery += "     , SLOTE
		// cQuery += "     , DOCUMENTO
		// cQuery += "     , LINHA
		// cQuery += "     , CONTA
		// cQuery += "     , DESCCTA
		// cQuery += "     , CTADESC
		// cQuery += "     , VALOR
		// cQuery += "     , HISTORICO
		// cQuery += "     , CC
		// cQuery += "     , TPSALDO
		// cQuery += "     , ORIGEM
		// cQuery += "     , ANO
		// cQuery += "     , MES
		// cQuery += "     , PERIODO
		// cQuery += "     , CTASUP
		// cQuery += "     , DSCSUP
		// cQuery += "     , CTRLCODE
		// cQuery += "     , DSCCTRL
		// cQuery += "     , ''								AS [CompanyCC]
		// cQuery += "     , ISNULL(ltrim(rtrim(ZM_ID)),'')	AS [CompanyCode]
		// cQuery += "     , ''								AS [BU]
		// cQuery += "     , ''								AS [BU_CC]
		// cQuery += "     , PESQUISA
		// cQuery += "     , NATUREZA
		// cQuery += "     , VISAO
		// cQuery += "     , CLASSIFICA
		// cQuery += "     , BASE
		// cQuery += "     , SEQUEN
		// cQuery += "     , EXPORTA
		// cQuery += "      FROM " + oTemptable:GetRealName() + " TMP  WITH(NOLOCK)
		// cQuery += "      INNER JOIN " + RetSqlName("SZM") + " SZM with(nolock) ON ZM_FILEMP = SUBSTRING(FILIAL,1,2) AND ZM_LOCALID = 'CLOUD' AND SZM.D_E_L_E_T_ = ''
		// cQuery += "      WHERE VISAO = ' '
		// TcQuery cQuery New Alias (cTRBZ := GetNextAlias())


		// dbSelectArea((cTRBZ))
		// Count To nRecQry
		// nLin      := 0
		// (cTRBZ)->(dbGoTop())
		// op_Self:IncRegua1("Gravando Registros.")
		// op_Self:SetRegua2(nRecQry)

		// If !(cTRBZ)->(EoF())
		// 	DelMov(cp_Periodo, 'CLOUD' , cp_EmpDe, cp_EmpAte )

		// 	//exclui movimentos do saldo inicial
		// 	If substr(cp_Periodo,5,2) == '01'
		// 		cPerSldIni := substr(Dtos(MonthSub(Stod(cP_Periodo+'01'),1)),1,6)
		// 		DelMovSI(cPerSldIni, 'CLOUD', cp_EmpDe, cp_EmpAte )
		// 	EndIf

		// 	While !(cTRBZ)->(EoF())
		// 		nLin += 1
		// 		op_Self:IncRegua2("Gravando registro " + cValToChar(nLin) + " de " + cValToChar(nRecQry) + "...")

		// 		reclock("SZP",.T.)
		// 		SZP->ZP_FILIAL  := (cTRBZ)->FILIAL
		// 		SZP->ZP_DATA    := sTod((cTRBZ)->DATAMOV)
		// 		SZP->ZP_LOTE    := (cTRBZ)->LOTE
		// 		SZP->ZP_SLOTE   := (cTRBZ)->SLOTE
		// 		SZP->ZP_DOCUMEN := (cTRBZ)->DOCUMENTO
		// 		SZP->ZP_LINHA   := (cTRBZ)->LINHA
		// 		SZP->ZP_CONTA   := (cTRBZ)->CONTA
		// 		SZP->ZP_DESCCTA := (cTRBZ)->DESCCTA
		// 		SZP->ZP_CTADESC := (cTRBZ)->CTADESC
		// 		SZP->ZP_VALOR   := (cTRBZ)->VALOR
		// 		SZP->ZP_HISTOR  := (cTRBZ)->HISTORICO
		// 		SZP->ZP_CCUSTO  := (cTRBZ)->CC
		// 		SZP->ZP_TPSALDO := (cTRBZ)->TPSALDO
		// 		SZP->ZP_ORIGEM  := (cTRBZ)->ORIGEM
		// 		SZP->ZP_ANO     := (cTRBZ)->ANO
		// 		SZP->ZP_MES     := (cTRBZ)->MES
		// 		SZP->ZP_PERIODO := (cTRBZ)->PERIODO

		// 		SZP->ZP_CTRLCOD := (cTRBZ)->CTRLCODE

		// 		SZP->ZP_CPNYCC  := (cTRBZ)->CompanyCC
		// 		SZP->ZP_CPNYCOD := (cTRBZ)->CompanyCode
		// 		SZP->ZP_BU      := (cTRBZ)->BU
		// 		SZP->ZP_BU_CC   := (cTRBZ)->BU_CC
		// 		SZP->ZP_PESQUIS := (cTRBZ)->PESQUISA


		// 		SZP->ZP_BASE    := (cTRBZ)->BASE
		// 		SZP->ZP_SEQUEN  := (cTRBZ)->SEQUEN
		// 		SZP->ZP_EXPORT  := (cTRBZ)->EXPORTA
		// 		SZP->ZP_IMPORT  := dTos(Date()) + " - " + substr(Time(),1,5)


		// 		SZP->ZP_CTRLSUP := (cTRBZ)->CTASUP
		// 		SZP->ZP_DSCSUP  := (cTRBZ)->DSCSUP
		// 		SZP->ZP_DSCCTA  := (cTRBZ)->DSCCTRL

		// 		SZP->ZP_NATCTA1 := (cTRBZ)->NATUREZA
		// 		SZP->ZP_DREBAL  := (cTRBZ)->VISAO
		// 		SZP->ZP_CLASSVS := (cTRBZ)->CLASSIFICA


		// 		SZP->(MSUnLock())
		// 		(cTRBZ)->(dbSkip())
		// 	EndDo
		// 	(cTRBZ)->(dbCloseArea())

		// EndIf
		oTemptable:Delete()
	EndIf

return()

//----------------------------------------------------------------------------------------------------------------------------------------------------------

static function RetSeq(cp_Periodo, cp_Local)
	local cQuery       := ""
	local __oStatement := nil
	local aAreaUx      := GetArea()
	local cAliasQry    := GetNextAlias()
	default cP_Periodo := substr(dTos(Date()),1,6)
	default cp_Local  := 'LOCAL'

	cQuery := ""
	cQuery += " SELECT ZP_PERIODO AS PERIODO, ISNULL(MAX(ZP_SEQUEN),'000') AS SEQ FROM " + RetSqlName("SZP") + " SZP with(nolock)
	cQuery += " WHERE ZP_PERIODO = ?
	cQuery += "   AND ZP_BASE = ?
	cQuery += " GROUP BY ZP_PERIODO


	__oStatement := FWPreparedStatement():New()

	cAliasQry 	:= GetNextAlias()
	__oStatemen:SetQuery(cQuery)
	__oStatemen:SetString(1,substr(cP_Periodo,1,4) + '-' + substr(cP_Periodo,5,2))
	__oStatemen:SetString(2,cp_Local)
	cAliasQry := MPSYSOpenQuery(__oStatemen:GetFixQuery(),cAliasQry)

	dbSelectArea((cAliasQry))
	If (cAliasQry)->(!eof())
		cRet := Soma1((cAliasQry)->SEQ)
	Else
		cRet := '001'
	EndIf

	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaUx)
return(cRet)


//----------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DelMov
Excluir registros de movimento do periodo e base
@type function
@version 12.1.27
@author Leandro Cesar (Solução Compacta)
@since 21/03/2022
@param cp_Periodo, character, Periodo
/*/
static function DelMov(cp_Periodo, cp_Local, cp_EmpDe, cp_EmpAte)
	local cQuery       := ""
	local aAreaUx      := GetArea()
	default cP_Periodo := substr(dTos(Date()),1,6)
	default cp_EmpDe := ""
	default cp_EmpAte := "ZZ"

	cQuery := ""
	cQuery += " UPDATE " + RetSqlName("SZP") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ FROM " + RetSqlName("SZP")
	cQuery += " WHERE D_E_L_E_T_ = '' AND ZP_PERIODO = '" + substr(cP_Periodo,1,4) + '-' + substr(cP_Periodo,5,2) + "'
	cQuery += "   AND ZP_BASE = '" + cp_Local + "'
	cQuery += "   AND SUBSTRING(ZP_FILIAL,1,2) >= '" + cp_EmpDe + "'
	cQuery += "   AND SUBSTRING(ZP_FILIAL,1,2) <= '" + cp_EmpAte + "'
	TcSqlExec(cQuery)

	RestArea(aAreaUx)
return()

// ----------------------------------------------------------------------------------------------------------------------------------------------------

static function DelMovSI(cp_Periodo, cp_Local, cp_EmpDe, cp_EmpAte)
	local cQuery       := ""
	local aAreaUx      := GetArea()
	default cP_Periodo := substr(dTos(Date()),1,6)

	cQuery := ""
	cQuery += " UPDATE " + RetSqlName("SZP") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ FROM " + RetSqlName("SZP")
	cQuery += " WHERE D_E_L_E_T_ = ''
	cQuery += "   AND ZP_BASE = '" + cp_Local + "'
	cQuery += "   AND SUBSTRING(ZP_FILIAL,1,2) >= '" + cp_EmpDe + "'
	cQuery += "   AND SUBSTRING(ZP_FILIAL,1,2) <= '" + cp_EmpAte + "'
	cQuery += "   AND ZP_ORIGEM = 'Saldo Inicial'
	TcSqlExec(cQuery)

	RestArea(aAreaUx)
return()


// ----------------------------------------------------------------------------------------------------------------------------------------------------

user function ConnectFTP()
	local nX      := 0
	local cEndFTP := "ftpdtc.totvs.com.br"
	local cUsrFTP := "YMLLLM_TESTE@datacenter.local"
	local cPswFTP := "e#@daswed23DE3F"
	local nPrtFTP := 21
	local aFiles  := {}


	oFTPClient := tFtpClient():New()
	nRet := oFTPClient:FTPConnect(cEndFTP,nPrtFTP,cUsrFTP,cPswFTP)
	sRet := oFTPClient:GetLastResponse()
	Conout( sRet )

	If (nRet != 0)
		Conout( "Falha ao conectar" )
		Return .F.
	EndIf

	If oFTPClient:ChDir('/YMLLLM_TESTE/') == 0
		If oFTPClient:ChDir('Download/') == 0
			If oFTPClient:ChDir('IntContabil/') == 0
				aFiles := oFTPClient:Directory("*.zip",.T.)
				If len(aFiles) != 0
					lFireWall := oFTPClient:bFireWallMode
					oFTPClient:bFireWallMode := .T.
					For nX := 1 to len(aFiles)
						If oFTPClient:ReceiveFile(aFiles[nx][1], '\downloads\'+aFiles[nx][1]) != 0
							Conout( "Falha ao copiar arquivo ReceiverFile : " + alltrim(oFTPClient:cErrorString) )
							Return .F.
						EndIf
					Next nX
					oFTPClient:bFireWallMode := lFireWall
				Else
					Conout( "Nao foi identificados arquivos" )
					Return .F.
				EndIf
			Else
				Conout( "Falha ao acessar a pasta IntContabil (3) : " + alltrim(oFTPClient:cErrorString) )
				Return .F.
			EndIf
		Else
			Conout( "Falha ao acessar a pasta Download (2) : " + alltrim(oFTPClient:cErrorString) )
			Return .F.
		EndIf
	Else
		Conout( "Falha ao acessar a pasta raiz FTP (1) : " + alltrim(oFTPClient:cErrorString) )
		Return .F.
	EndIf

return(.T.)

// ----------------------------------------------------------------------------------------------------------------------------------------------------------


User Function PnlIntCb()
	Local oBFechar
	Local oBImpCSV
	Local oBPrcCtb
	Local oFBtn := TFont():New("Verdana", , 019, , .T., , , , , .F., .F.)
	Local oGroup1
	Static oDlgCtb

	DEFINE MSDIALOG oDlgCtb  FROM 000, 000  TO 220, 500 COLORS 0, 16777215 PIXEL

	@ 010, 010 GROUP oGroup1 TO 080, 240 OF oDlgCtb COLOR 0, 16777215 PIXEL
	@ 021, 040 BUTTON oBPrcCtb PROMPT "Processamento Contábil" SIZE 170, 020 OF oDlgCtb FONT oFBtn PIXEL
	@ 045, 040 BUTTON oBImpCSV PROMPT "Importação CSV Cloud" SIZE 170, 020 OF oDlgCtb FONT oFBtn PIXEL
	@ 085, 155 BUTTON oBFechar PROMPT "Fechar" SIZE 085, 018 OF oDlgCtb FONT oFBtn PIXEL

	oBPrcCtb:bAction   :={|| U_procont() }
	oBImpCSV:bAction   :={|| U_ImpCSVCloud() }

	oBFechar:bAction   :={|| oDlgCtb:End()}

	ACTIVATE MSDIALOG oDlgCtb CENTERED

Return
