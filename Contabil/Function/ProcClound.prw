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


#define _LocBase "CLOUD"

user function PrCCCTBC()
	local l_Job        := .F.
	local cTitle       := "Processamento Contabil Periodo"
	local bProcess     := ""
	local cDescription := "Este programa tem como objetivo realizar o processamento contábil do periodo informado."
	local cPerg        := 'PROCONT'
	local cEmpDe    := "  "
	local cEmpAte   := "ZZ"
	private cFunction  := Substr(FunName(),1,8)
	l_Job              := IsBlind()
	bProcess           :={|oSelf| GeraArq(l_Job, '' ,'', 'ZZ',oSelf)}

	If l_Job
		ConOut("Inicio da rotina de schedule procont")
		ConOut("Inicio: "+cValToChar(Date())+" - "+cValToChar(Time()))
		Prepare Environment Empresa "01" Filial "5100"

		cQuery := ""
		cQuery += " SELECT SUBSTRING(CTG_DTINI,1,6) AS PERIODO FROM CTG010 CTG
		cQuery += " WHERE CTG.D_E_L_E_T_  = ''
		cQuery += " AND CTG_FILIAL = '5100'
		cQuery += " AND CTG_STATUS = '1'
		cQuery += " GROUP BY SUBSTRING(CTG_DTINI,1,6)
		TcQuery cQuery New Alias (cTRBJOB := GetNextAlias())

		dbSelectarea((cTRBJOB))
		(cTRBJOB)->(dbGoTop())
		while (cTRBJOB)->(!eof())
			ConOut("Processamento periodo: " + (cTRBJOB)->PERIODO)
			GeraArq(l_Job, (cTRBJOB)->PERIODO,cEmpDe, cEmpAte,nil)
			(cTRBJOB)->(dbSkip())
		EndDo
		(cTRBJOB)->(dbCloseArea())

		Reset Environment
		ConOut("Termino da rotina de schedule procont.")
		ConOut("Fim: "+cValToChar(Date())+" - "+cValToChar(Time()))
	Else

		tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )

	EndIf

return()

//------------------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} GeraArq
gera o arquivo CSV
@type function
@version 12.1.27
@author Leandro Cesar (Solução Compacta)
@param lp_Job, logical, processamento esta sendo realizado via JOB
@param cp_Periodo, character, periodo de processamento
@return logical, retorna se a rotina foi processada com sucesso
/*/
Static Function GeraArq(lp_Job as logical, cp_Periodo as character, cp_EmpDe as character, cp_EmpAte as character, op_Self as object )
	local lRet         := .t. as logical
	Local cPasta       := ""  as character
	Local cArquivo     := ""  as character
	Local cQuery       := ""  as character
	Local cLinha       := ""  as character

	default cP_Periodo := substr(dTos(Date()),1,6)
	default cp_EFDe    := " "
	default cp_EFAte   := "ZZZZ"
	nRecQry   := 0

	If !lp_Job
		cP_Periodo := MV_PAR01
		cp_EmpDe   := MV_PAR02
		cp_EmpAte  := MV_PAR03

		If Empty(cp_EmpDe) .and. Empty(cp_EmpAte)
			cp_EmpAte := "ZZ"
		EndIf
	EndIf

	cSequen := RetSeq(cP_Periodo, 'CLOUD')
	// If lp_Job
	// 	cPasta  := '\Download\IntContabil\'
	// Else
	// 	cPasta  := 'c:\temp\IntContabil\'
	// EndIf
	cPasta  := 'c:\temp\IntContabil\'
	FWMakeDir(cPasta)

	// aDirCSV := Directory( cPasta +"*.csv" )
	// aEval(aDirCSV,{|x| Ferase( cPasta + aDirCSV[x,1] )})

	cArquivo           := cp_Periodo + "_CLOUD_"+ alltrim(cp_EmpDe)+alltrim(cp_EmpAte)+".CSV"
	If file(cPasta + cArquivo)
		FErase(cPasta + cArquivo)
	EndIf

	oFWriter           := FWFileWriter():New(cPasta + cArquivo, .T.)
	If !lp_Job
		op_Self:SetRegua1(4)
		op_Self:SetRegua2(2)
		op_Self:IncRegua1("Validando arquivos")
	Else
		ConOut("Validando arquivos...")
	EndIf

	If !oFWriter:Create()
		If !lp_Job
			MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oFWriter:Error():Message, "Atenção")
		Else
			ConOut("Houve um erro ao gerar o arquivo: " + oFWriter:Error():Message)
		EndIf
	Else

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
			cQuery += "  	 , ROUND(SUM(CQ0_DEMOVPAGTOBITO-CQ0_CREDIT),2)																							AS [Valor]
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
			cQuery += "  	 ,'Saldo Inicial'																												AS [Pesquisa]
			cQuery += "  	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
			cQuery += "  					   WHEN '02' THEN 'Conta de Passivo'
			cQuery += "  					   WHEN '03' THEN 'Patrimônio Líquido'
			cQuery += "  					   WHEN '04' THEN 'Conta de Resultado'
			cQuery += "  					   WHEN '05' THEN 'Conta de Compensação'
			cQuery += "  					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
			cQuery += "  	 , CASE WHEN SUBSTRING(CQ0_CONTA,1,1) IN ('1','2') THEN 'BALANCO' ELSE 'DRE' END AS [VISAO]
			cQuery += "  	 , '' as [Classificao]
			cQuery += "  	 , '' as [ContPart]
			cQuery += "    FROM " + RetSqlName("CQ0") + " CQ0 with(nolock)
			cQuery += "   INNER JOIN  " + RetSqlName("CT1") + "  CT1 with(nolock) ON CT1_CONTA = CQ0_CONTA AND CT1.D_E_L_E_T_ = ''
			cQuery += "    LEFT JOIN  " + RetSqlName("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CQ0_CONTA AND CVD.D_E_L_E_T_ = ''
			cQuery += "    LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
			cQuery += "    LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
			cQuery += "   WHERE CQ0.D_E_L_E_T_ = ''
			cQuery += "     AND CQ0_DATA <= '" + cPerSldIni + "'
			cQuery += "     AND SUBSTRING(CQ0_FILIAL,1,2) >= '" + cp_EmpDe + "'
			cQuery += "     AND SUBSTRING(CQ0_FILIAL,1,2) <= '" + cp_EmpAte + "'
			cQuery += "  GROUP BY CQ0_FILIAL, RTRIM(CQ0_CONTA), RTRIM(CT1_DESC01), RTRIM(CQ0_CONTA) + ' : ' + RTRIM(CT1_DESC01), RTRIM(CQ0_TPSALD)
			cQuery += "         , ISNULL(ltrim(rtrim(CVD.CVD_CTASUP)),''), ISNULL(ltrim(rtrim(CVNS.CVN_DSCCTA)),'')
			cQuery += " 		, ISNULL(ltrim(rtrim(CVD.CVD_CTAREF)),''), ISNULL(ltrim(rtrim(CVN.CVN_DSCCTA)),'')
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
		cQuery += " 	 , ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
		cQuery += " 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
		cQuery += " 					   WHEN '02' THEN 'Conta de Passivo'
		cQuery += " 					   WHEN '03' THEN 'Patrimônio Líquido'
		cQuery += " 					   WHEN '04' THEN 'Conta de Resultado'
		cQuery += " 					   WHEN '05' THEN 'Conta de Compensação'
		cQuery += " 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
		cQuery += " 	 , 'BALANCO' AS [VISAO]
		cQuery += " 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM " + RetSqlName("CTS") + " WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = '002' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != ''  ),'') as [Classificao]
		cQuery += "  	 , CT2_CREDIT as [ContPart]
		cQuery += "   FROM " + RetSqlName("CT2") + " CT2 with(nolock)
		cQuery += "  INNER JOIN  " + RetSqlname("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlname("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
		cQuery += "  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
		cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
		cQuery += "    AND SUBSTRING(CT2_DEBITO,1,1) IN ('1','2')
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'

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
		cQuery += " 	 , ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD  AS [Pesquisa]
		cQuery += " 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
		cQuery += " 					   WHEN '02' THEN 'Conta de Passivo'
		cQuery += " 					   WHEN '03' THEN 'Patrimônio Líquido'
		cQuery += " 					   WHEN '04' THEN 'Conta de Resultado'
		cQuery += " 					   WHEN '05' THEN 'Conta de Compensação'
		cQuery += " 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
		cQuery += " 	 , 'DRE' AS [VISAO]
		cQuery += " 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM " + RetSqlName("CTS") + " WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
		cQuery += "  	 , CT2_CREDIT as [ContPart]
		cQuery += "   FROM " + RetSqlName("CT2") + " CT2 with(nolock)
		cQuery += "  INNER JOIN  " + RetSqlname("CT1") + "  CT1 with(nolock) ON CT2_DEBITO = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO = CT2_CCD AND CTT.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlname("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_DEBITO AND CVD.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
		cQuery += "  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('1','3')
		cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
		cQuery += "    AND SUBSTRING(CT2_DEBITO,1,1) NOT IN ('1','2')
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'

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
		cQuery += " 	 , ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
		cQuery += " 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
		cQuery += " 					   WHEN '02' THEN 'Conta de Passivo'
		cQuery += " 					   WHEN '03' THEN 'Patrimônio Líquido'
		cQuery += " 					   WHEN '04' THEN 'Conta de Resultado'
		cQuery += " 					   WHEN '05' THEN 'Conta de Compensação'
		cQuery += " 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
		cQuery += " 	 , 'BALANCO' AS [VISAO]
		cQuery += " 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM " + RetSqlName("CTS") + " WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = '002' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2'  AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
		cQuery += "  	 , CT2_DEBITO as [ContPart]
		cQuery += "   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
		cQuery += "  INNER JOIN  " + RetSqlname("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlname("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
		cQuery += "  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
		cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
		cQuery += "    AND SUBSTRING(CT2_CREDIT,1,1) IN ('1','2')
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'

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
		cQuery += " 	 , ltrim(rtrim(CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
		cQuery += " 	 , CASE CT1_NATCTA WHEN '01' THEN 'Conta de Ativo'
		cQuery += " 					   WHEN '02' THEN 'Conta de Passivo'
		cQuery += " 					   WHEN '03' THEN 'Patrimônio Líquido'
		cQuery += " 					   WHEN '04' THEN 'Conta de Resultado'
		cQuery += " 					   WHEN '05' THEN 'Conta de Compensação'
		cQuery += " 					   WHEN '09' THEN 'Outras' ELSE CT1_NATCTA END AS [Nat_Conta]
		cQuery += " 	 , 'DRE' AS [VISAO]
		cQuery += " 	 , isnull(( SELECT TOP 1 ltrim(rtrim(CTS_DESCCG)) FROM " + RetSqlName("CTS") + " WHERE D_E_L_E_T_ = '' AND CTS_CODPLA = 'DRE' AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM AND CTS_CLASSE = '2' AND CTS_TPSALD = CTS_TPSALD AND CTS_CT1INI != '' AND CTS_CT1FIM != '' ),'') as [Classificao]
		cQuery += "  	 , CT2_DEBITO as [ContPart]
		cQuery += "   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
		cQuery += "  INNER JOIN  " + RetSqlname("CT1") + "  CT1 with(nolock) ON CT2_CREDIT = CT1_CONTA AND CT1.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CTT") + "  CTT with(nolock) ON CTT_CUSTO  = CT2_CCC AND CTT.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlname("CVD") + "  CVD with(nolock) ON CVD.CVD_CODPLA = 'M02' AND CVD.CVD_CONTA = CT2_CREDIT AND CVD.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVN with(nolock) ON CVN.CVN_CODPLA = CVD_CODPLA AND CVN.CVN_CTAREF = CVD_CTAREF AND CVN.D_E_L_E_T_ = ''
		cQuery += "   LEFT JOIN  " + RetSqlName("CVN") + "  CVNS with(nolock) ON CVNS.CVN_CODPLA = CVD_CODPLA AND CVNS.CVN_CTAREF = CVD_CTASUP AND CVNS.D_E_L_E_T_ = ''
		cQuery += "  WHERE CT2.D_E_L_E_T_ = '' AND CT2_DC IN ('2','3')
		cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
		cQuery += "    AND SUBSTRING(CT2_CREDIT,1,1) NOT IN ('1','2')
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'

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
		cQuery += " 	 , ltrim((CONVERT(CHAR, CAST(CT2_DATA AS SMALLDATETIME),103))) + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD AS [Pesquisa]
		cQuery += " 	 , '' as [Nat_Conta]
		cQuery += " 	 , '' AS [VISAO]
		cQuery += " 	 , '' as [Classificao]
		cQuery += "  	 , '' as [ContPart]
		cQuery += "   FROM  " + RetSqlName("CT2") + "  CT2 with(nolock)
		cQuery += "     INNER JOIN  " + RetSqlName("SZM") + "  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(CT2_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
		cQuery += "  WHERE CT2.D_E_L_E_T_ = ''
		cQuery += "    AND CT2_DC = '4'
		cQuery += "    AND SUBSTRING(CT2_DATA,1,6) = ?
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) >= '" + cp_EmpDe + "'
		cQuery += "    AND SUBSTRING(CT2_FILIAL,1,2) <= '" + cp_EmpAte + "'
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
			op_Self:IncRegua1("Gravando registros arquivo CSV")
		Else
			ConOut("Gravando registros arquivo CSV")
		EndIf

		dbSelectArea((cAliasQry))
		(cAliasQry)->(dbGoTop())
		If !(cAliasQry)->(EoF())
			cLinha := ""
			cLinha += "FILIAL;DT_MOV;LOTE_CTB;SUB_LOTE;DOCUMENTO;LINHA;CONTA;DESC_CTA;CTA_DESC;VALOR;HISTORICO;CC;TP_SALDO;ORIGEM;ANO;MES;PERIODO;
				cLinha += "CTRL_CODE_SINT;DESC_CTRL_SINT;CONTROL_CODE;DESC_CONTROL_CODE;PESQUISA;NATUREZA_CONTA;VISCAO;CLASSIFICACAO;LOCAL;SEQUEN;LOG;CONT_PARTIDA;FIM"
			oFWriter:Write(cLinha + CRLF)

			While !(cAliasQry)->(EoF())
				nLin += 1
				If !lp_Job
					op_Self:IncRegua2("Gravando linha " + cValToChar(nLin) + " de " + cValToChar(nRecQry) + "...")
				EndIf

				cLinha := ""
				cLinha += (cAliasQry)->Filial                           + ";"
				cLinha += (cAliasQry)->DtMov                            + ";"
				cLinha += (cAliasQry)->LoteCtb                          + ";"
				cLinha += (cAliasQry)->SLote                            + ";"
				cLinha += (cAliasQry)->Documento                        + ";"
				cLinha += (cAliasQry)->Linha                            + ";"
				cLinha += (cAliasQry)->Conta                            + ";"
				cLinha += (cAliasQry)->DescCta                          + ";"
				cLinha += (cAliasQry)->Cta_Desc                         + ";"
				cLinha += cValToChar((cAliasQry)->Valor)                + ";"
				cLinha += strTran((cAliasQry)->Historico,';','|')       + ";"
				cLinha += (cAliasQry)->CC                               + ";"
				cLinha += (cAliasQry)->TpSaldo                          + ";"
				cLinha += (cAliasQry)->Origem                           + ";"
				cLinha += (cAliasQry)->Ano                              + ";"
				cLinha += (cAliasQry)->Mes                              + ";"
				cLinha += (cAliasQry)->Periodo                          + ";"
				cLinha += (cAliasQry)->CtrlCodeSint                     + ";"
				cLinha += (cAliasQry)->DescCtrlSint                     + ";"
				cLinha += (cAliasQry)->ControlCode                      + ";"
				cLinha += (cAliasQry)->DescCtrlCode                     + ";"
				cLinha += (cAliasQry)->Pesquisa                         + ";"
				cLinha += (cAliasQry)->Nat_Conta                        + ";"
				cLinha += (cAliasQry)->VISAO                            + ";"
				cLinha += (cAliasQry)->Classificao                      + ";"
				cLinha += _LocBase                                      + ";"
				cLinha += cSequen                                       + ";"
				cLinha += dTos(Date()) + " - " + substr(Time(),1,5)     + ";"
				cLinha += (cAliasQry)->ContPart                         + ";"
				cLinha += " "                                           + ";"

				oFWriter:Write(cLinha + CRLF)

				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

			oFWriter:Close()
			If file(cPasta + cArquivo) .and. !lp_Job
				FWAlertSuccess("Arquivo exportado com sucesso.","Aviso")
				ShellExecute("open", "explorer.exe", "Temp\intcontabil", "c:\", 1)
			EndIf

			If lp_Job
				cFileZip := strTran(cPasta + cArquivo,".CSV",".ZIP")
				If FZip(cFileZip,{cPasta + cArquivo},cPasta) == 0
					FErase(cPasta + cArquivo)
				Else
					op_Self:SaveLog("Falha na compactacao do arquivo")
				EndIf
			Endif
		EndIf

	EndIf

Return lRet


//----------------------------------------------------------------------------------------------------------------------------------------------------------

static function RetSeq(cp_Periodo, cp_Base)
	local cQuery       := ""
	local __oStatement := nil
	local aAreaUx      := GetArea()
	local cAliasQry    := GetNextAlias()
	default cP_Periodo := substr(dTos(Date()),1,6)
	default cp_Base    := "LOCAL"

	cQuery := ""
	cQuery += " SELECT ZP_PERIODO AS PERIODO, ISNULL(MAX(ZP_SEQUEN),'000') AS SEQ FROM " + RetSqlName("SZP") + " SZP with(nolock)
	cQuery += " WHERE ZP_PERIODO = ?
	cQuery += "   AND ZP_BASE = ?
	cQuery += " GROUP BY ZP_PERIODO


	__oStatement := FWPreparedStatement():New()

	cAliasQry 	:= GetNextAlias()
	__oStatemen:SetQuery(cQuery)
	__oStatemen:SetString(1,substr(cP_Periodo,1,4) + '-' + substr(cP_Periodo,5,2))
	__oStatemen:SetString(2,cp_Base)
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
