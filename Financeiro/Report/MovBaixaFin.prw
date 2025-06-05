#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

Static __oTBxCanc	:= NIL
user function MovBaixaFin()

	local cTitle       := "Processamento Movimento Financeiro"
	local bProcess     := { |oSelf| Retpor(oSelf) }
	local cDescription := "Este programa tem como objetivo realizar a geração das baixas financeiras do contas a receber e a pagar."
	local cPerg        := 'MOVFIN2   '
	private cFunction  := ""

	cFunction  := Substr(FunName(),1,8)
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )

return()


// ----------------------------------------------------------------------------------------------------------------------------------------------------------

static function Retpor(op_Self)
	local cQuery   := ""
	local cArquivo := GetTempPath() + 'PlanMovBaixa_' + dtoS(dDataBase) + '_' + strTran(time(),':','') + '.xml'
	local nRegs    := 0
	local cSheet   := "Movimento Baixa"
	local cTitulo  := "Financeiro"

	op_Self:SetRegua1(2)
	op_Self:SetRegua2(1)
	op_Self:IncRegua1("Leitura dos registros financeiro")

	cQuery := ""
	cQuery += " SELECT ZM_CODIGO AS [EMPRESA]
	cQuery += "      , E1_FILIAL AS [FILIAL]
	cQuery += "      , E1_CLIENTE AS [CLIFOR]
	cQuery += "      , E1_LOJA AS [LOJA]
	cQuery += "      , E1_NOMCLI AS [NOME]
	cQuery += "      , E1_PREFIXO AS [PREFIXO]
	cQuery += "      , E1_NUM as [TITULO]
	cQuery += "      , E1_TIPO as [TIPO]
	cQuery += "      , E1_PARCELA AS [PARCELA]
	cQuery += "      , E1_EMISSAO as [EMISSAO]
	cQuery += "      , E1_EMIS1 as [DT_CONTABIL]
	cQuery += "      , E1_VENCREA as [VENCTO]
	cQuery += "      , CASE E1_MOEDA WHEN 1 THEN 'BRL'
	cQuery += "     			  WHEN 2 THEN 'USD'
	cQuery += "     			  WHEN 4 THEN 'USD'
	cQuery += "     			  WHEN 5 THEN 'EUR'
	cQuery += "     			  WHEN 6 THEN 'EUR'
	cQuery += "     			  WHEN 7 THEN 'CLP'
	cQuery += "     			  WHEN 8 THEN 'CLP'
	cQuery += "     			  WHEN 9 THEN 'GBP'
	cQuery += "     			  WHEN 10 THEN 'GBP'
	cQuery += "     			  WHEN 11 THEN 'SEK'
	cQuery += "     			  WHEN 12 THEN 'SEK'
	cQuery += "     			  WHEN 13 THEN 'CAD'
	cQuery += "     			  WHEN 14 THEN 'CAD'
	cQuery += "     			  WHEN 15 THEN 'NOK'
	cQuery += "     			  WHEN 16 THEN 'NOK'
	cQuery += "     			  WHEN 17 THEN 'CHF'
	cQuery += "     			  WHEN 18 THEN 'CHF'
	cQuery += "     			  WHEN 19 THEN 'DKK'
	cQuery += "     			  WHEN 20 THEN 'DKK'
	cQuery += "     			  WHEN 21 THEN 'NZD'
	cQuery += "     			  WHEN 22 THEN 'NZD'
	cQuery += "     			  WHEN 23 THEN 'ARS'
	cQuery += "     			  WHEN 24 THEN 'ARS'
	cQuery += "     			  WHEN 25 THEN 'AUD'
	cQuery += "     			  WHEN 26 THEN 'AUD'
	cQuery += "     			  ELSE 'XXX' END as [MOEDA]
	cQuery += "      , E1_VALLIQ as [VAL_LIQ]
	cQuery += "      , E1_NATUREZ as [NATUREZA]
	cQuery += "      , ED_DESCRIC as [DESC_NAT]
	cQuery += "      , case A1_ZZCOLIG when 'S' THEN 'SIM' ELSE 'NAO' END as [COLIGADA]
	cQuery += "      , E1_VALOR AS [VAL_TIT]
	cQuery += "      , E1_SALDO as [SALDO]
	cQuery += "      , E5_DATA as [DATA_MOV]
	cQuery += "      , CASE E5_TIPODOC WHEN 'AP' THEN 'Aplicação'
	cQuery += "     				WHEN 'BA' THEN 'Baixa de titulo'
	cQuery += "     				WHEN 'BD' THEN 'Transferência por borderô descontado'
	cQuery += "     				WHEN 'BL' THEN 'Baixa por Lote'
	cQuery += "     				WHEN 'C2' THEN 'Correção Monetária de titulo em carteira descontada'
	cQuery += "     				WHEN 'CA' THEN 'Cheque Avulso / Cancelamento de Cheque Avulso'
	cQuery += "     				WHEN 'CB' THEN 'Cancelamento de Transferência por borderô descontado'
	cQuery += "     				WHEN 'CD' THEN 'Cheque pré-datado via Movimento Bancário Manual'
	cQuery += "     				WHEN 'CH' THEN 'Cheque'
	cQuery += "     				WHEN 'CM' THEN 'Correção Monetária'
	cQuery += "     				WHEN 'CP' THEN 'Compensação CR ou CP'
	cQuery += "     				WHEN 'CX' THEN 'Correção Monetária'
	cQuery += "     				WHEN 'D2' THEN 'Desconto em título em carteira descontada'
	cQuery += "     				WHEN 'DB' THEN 'Despesas bancárias'
	cQuery += "     				WHEN 'DC' THEN 'Desconto'
	cQuery += "     				WHEN 'DH' THEN 'Dinheiro'
	cQuery += "     				WHEN 'E2' THEN 'Estorno de movimento de desconto (Cobrança Descontada)'
	cQuery += "     				WHEN 'EC' THEN 'Estorno de cheque'
	cQuery += "     				WHEN 'EP' THEN 'Empréstimo'
	cQuery += "     				WHEN 'ES' THEN 'Estorno de Baixa'
	cQuery += "     				WHEN 'IS' THEN 'Imposto Substitutivo (Localizações)'
	cQuery += "     				WHEN 'J2' THEN 'Juros de titulo em carteira descontada'
	cQuery += "     				WHEN 'JR' THEN 'Juros'
	cQuery += "     				WHEN 'LJ' THEN 'Movimento do SigaLoja'
	cQuery += "     				WHEN 'M2' THEN 'Multa de titulo em carteira descontada'
	cQuery += "     				WHEN 'MT' THEN 'Multa'
	cQuery += "     				WHEN 'OC' THEN 'Outros Créditos'
	cQuery += "     				WHEN 'OD' THEN 'Outras Despesas'
	cQuery += "     				WHEN 'OG' THEN 'Outras Garantias (Localizações)'
	cQuery += "     				WHEN 'PA' THEN 'Inclusão PA'
	cQuery += "     				WHEN 'PE' THEN 'Pagamento Empréstimo'
	cQuery += "     				WHEN 'R$' THEN 'Dinheiro'
	cQuery += "     				WHEN 'RA' THEN 'Inclusão RA'
	cQuery += "     				WHEN 'RF' THEN 'Resgate de Aplicações'
	cQuery += "     				WHEN 'SG' THEN 'Entrada de Dinheiro no Caixa (Loja)'
	cQuery += "     				WHEN 'TC' THEN 'Troco'
	cQuery += "     				WHEN 'TE' THEN 'Estorno de transferência (Movimento Bancário Manual)'
	cQuery += "     				WHEN 'TL' THEN 'Tolerância de Recebimento'
	cQuery += "     				WHEN 'TR' THEN 'Transferência para carteira descontada'
	cQuery += "     				WHEN 'V2' THEN 'Baixa de titulo em carteira descontada'
	cQuery += "     				WHEN 'VL' THEN 'Baixa de titulo'
	cQuery += "     				WHEN 'VM' THEN 'Variação Monetária' else 'Verificar' end  as [TIPO_DOC]
	cQuery += "       , E5_MOTBX as [MOT_BX]
	cQuery += "       , E5_VLMOED2 as [VLR_MOEDA]
	cQuery += "       , USR.USR_CODIGO as [PUID]
	cQuery += "       , USR.USR_NOME as [USUARIO]
	cQuery += "       , E1_NUMBOR as [BORDERO]
	cQuery += "       , E1_NUMBCO as [NUM_BCO]
	cQuery += "       , E1_IDCNAB as [ID_CNAB]
	cQuery += "       , E5_RECPAG as [RecPag]
	cQuery += "       , CASE WHEN E5_HISTOR like '%CNAB%' THEN 'BOLETO'
	cQuery += "     		 WHEN E5_MOTBX = 'CMP' THEN 'COMPENSACAO'
	cQuery += "     		 WHEN E5_HISTOR LIKE '%Juros%' THEN 'JUROS/MULTA/DESCONT'
	cQuery += "     		 WHEN E5_HISTOR LIKE '%Multa%' THEN 'JUROS/MULTA/DESCONT'
	cQuery += "     		 WHEN E5_HISTOR LIKE '%Desconto%' THEN 'JUROS/MULTA/DESCONT'
	cQuery += "     		 WHEN E5_ORIGEM = 'FINA378' THEN 'AGLUTINACAO IMPOSTO'
	cQuery += "     		 ELSE 'DEPOSITO' END [TIPO_PAGTO]
	cQuery += "       , CASE WHEN E5_HISTOR like '%CNAB%' OR E5_ARQCNAB != '' THEN 'CNAB' ELSE 'MANUAL' END AS [FORMA_BX]
	cQuery += "       , CASE WHEN E1_IDCNAB != '' OR E1_NUMBOR != '' THEN 'AUTOMATICO' ELSE 'MANUAL' END [FORMA_PAGTO]
	cQuery += "  FROM SE1010
	cQuery += " INNER JOIN SE5010 SE5 ON SE5.D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL
	cQuery += "   AND E5_PREFIXO = E1_PREFIXO
	cQuery += "   AND E5_NUMERO = E1_NUM
	cQuery += "   AND E5_TIPO = E1_TIPO
	cQuery += "   AND E5_PARCELA = E1_PARCELA
	cQuery += "   AND E5_CLIENTE = E1_CLIENTE
	cQuery += "   AND E5_LOJA = E1_LOJA
	cQuery += " INNER JOIN SA1010 SA1 with(nolock) ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += " INNER JOIN SED010 SED with(nolock) ON ED_CODIGO = E1_NATUREZ
	cQuery += " INNER JOIN  SZM010  SZM with(nolock) ON ZM_FILEMP = SUBSTRING(E1_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
	cQuery += " LEFT JOIN SYS_USR USR ON
	cQuery += "                 CASE
	cQuery += "                     WHEN (SUBSTRING(SE5.E5_USERLGI, 11, 1) != ' ') THEN
	cQuery += "                         SUBSTRING(SE5.E5_USERLGI, 11, 01) + SUBSTRING(SE5.E5_USERLGI, 15, 01) + SUBSTRING(SE5.E5_USERLGI, 02, 01) +
	cQuery += "                         SUBSTRING(SE5.E5_USERLGI, 06, 01) + SUBSTRING(SE5.E5_USERLGI, 10, 01) + SUBSTRING(SE5.E5_USERLGI, 14, 01)
	cQuery += "                     ELSE
	cQuery += "                         SUBSTRING(SE5.E5_USERLGI, 11, 01) + SUBSTRING(SE5.E5_USERLGI, 15, 01) + SUBSTRING(SE5.E5_USERLGI, 02, 01) +
	cQuery += "                         SUBSTRING(SE5.E5_USERLGI, 06, 01) + SUBSTRING(SE5.E5_USERLGI, 10, 01) + SUBSTRING(SE5.E5_USERLGI, 14, 01)
	cQuery += "                 END = USR.USR_ID
	cQuery += " WHERE SE1010.D_E_L_E_T_ = ''
	cQuery += "   AND E5_VALOR != 0
	cQuery += "   AND E1_EMIS1 >= CONVERT(char, dateadd(year, -2, getdate()),112)
	cQuery += "   AND E1_FILIAL  >= '" + MV_PAR01 + "'
	cQuery += "   AND E1_FILIAL  <= '" + MV_PAR02 + "'
	cQuery += "   AND E1_EMISSAO >= '" + dTos(MV_PAR03) + "'
	cQuery += "   AND E1_EMISSAO <= '" + dTos(MV_PAR04) + "'
	cQuery += "   AND E1_VENCREA >= '" + dTos(MV_PAR05) + "'
	cQuery += "   AND E1_VENCREA <= '" + dTos(MV_PAR06) + "'
	cQuery += "   AND E1_TIPO NOT IN " + FormatIn( MVPROVIS, "|" )
	cQuery += "   AND E1_EMIS1 >= '" + dTos(MV_PAR07) + "'
	cQuery += "   AND E1_EMIS1 <= '" + dTos(MV_PAR08) + "'
	cQuery += "   AND E5_TIPODOC NOT IN ('CM','CX','VM','C2')
	cQuery += "   AND E5_ORIGEM != 'FINA378'
	cQuery += " union

	cQuery += " SELECT ZM_CODIGO AS [EMPRESA]
	cQuery += "  , E2_FILIAL AS [FILIAL]
	cQuery += "  , E2_FORNECE AS [CLIFOR]
	cQuery += "  , E2_LOJA AS [LOJA]
	cQuery += "  , E2_NOMFOR AS [NOME]
	cQuery += "  , E2_PREFIXO AS [PREFIXO]
	cQuery += "  , E2_NUM as [TITULO]
	cQuery += "  , E2_TIPO as [TIPO]
	cQuery += "  , E2_PARCELA AS [PARCELA]
	cQuery += "  , E2_EMISSAO as [EMISSAO]
	cQuery += "  , E2_EMIS1 as [DT_CONTABIL]
	cQuery += "  , E2_VENCREA as [VENCTO]
	cQuery += "  , CASE E2_MOEDA WHEN 1 THEN 'BRL'
	cQuery += "				  WHEN 2 THEN 'USD'
	cQuery += "				  WHEN 4 THEN 'USD'
	cQuery += "				  WHEN 5 THEN 'EUR'
	cQuery += "				  WHEN 6 THEN 'EUR'
	cQuery += "				  WHEN 7 THEN 'CLP'
	cQuery += "				  WHEN 8 THEN 'CLP'
	cQuery += "				  WHEN 9 THEN 'GBP'
	cQuery += "				  WHEN 10 THEN 'GBP'
	cQuery += "				  WHEN 11 THEN 'SEK'
	cQuery += "				  WHEN 12 THEN 'SEK'
	cQuery += "				  WHEN 13 THEN 'CAD'
	cQuery += "				  WHEN 14 THEN 'CAD'
	cQuery += "				  WHEN 15 THEN 'NOK'
	cQuery += "				  WHEN 16 THEN 'NOK'
	cQuery += "				  WHEN 17 THEN 'CHF'
	cQuery += "				  WHEN 18 THEN 'CHF'
	cQuery += "				  WHEN 19 THEN 'DKK'
	cQuery += "				  WHEN 20 THEN 'DKK'
	cQuery += "				  WHEN 21 THEN 'NZD'
	cQuery += "				  WHEN 22 THEN 'NZD'
	cQuery += "				  WHEN 23 THEN 'ARS'
	cQuery += "				  WHEN 24 THEN 'ARS'
	cQuery += "				  WHEN 25 THEN 'AUD'
	cQuery += "				  WHEN 26 THEN 'AUD'
	cQuery += "				  ELSE 'XXX' END as [MOEDA]
	cQuery += "  , E2_VALLIQ as [VAL_LIQ]
	cQuery += "  , E2_NATUREZ as [NATUREZA]
	cQuery += "  , ED_DESCRIC as [DESC_NAT]
	cQuery += "  , case A2_ZZCOLIG when 'S' THEN 'SIM' ELSE 'NAO' END as [COLIGADA]
	cQuery += "  , E2_VALOR AS [VAL_TIT]
	cQuery += "  , E2_SALDO as [SALDO]
	cQuery += "  , E5_DATA as [DATA_MOV]
	cQuery += "  , CASE E5_TIPODOC WHEN 'AP' THEN 'Aplicação'
	cQuery += "					WHEN 'BA' THEN 'Baixa de titulo'
	cQuery += "					WHEN 'BD' THEN 'Transferência por borderô descontado'
	cQuery += "					WHEN 'BL' THEN 'Baixa por Lote'
	cQuery += "					WHEN 'C2' THEN 'Correção Monetária de titulo em carteira descontada'
	cQuery += "					WHEN 'CA' THEN 'Cheque Avulso / Cancelamento de Cheque Avulso'
	cQuery += "					WHEN 'CB' THEN 'Cancelamento de Transferência por borderô descontado'
	cQuery += "					WHEN 'CD' THEN 'Cheque pré-datado via Movimento Bancário Manual'
	cQuery += "					WHEN 'CH' THEN 'Cheque'
	cQuery += "					WHEN 'CM' THEN 'Correção Monetária'
	cQuery += "					WHEN 'CP' THEN 'Compensação CR ou CP'
	cQuery += "					WHEN 'CX' THEN 'Correção Monetária'
	cQuery += "					WHEN 'D2' THEN 'Desconto em título em carteira descontada'
	cQuery += "					WHEN 'DB' THEN 'Despesas bancárias'
	cQuery += "					WHEN 'DC' THEN 'Desconto'
	cQuery += "					WHEN 'DH' THEN 'Dinheiro'
	cQuery += "					WHEN 'E2' THEN 'Estorno de movimento de desconto (Cobrança Descontada)'
	cQuery += "					WHEN 'EC' THEN 'Estorno de cheque'
	cQuery += "					WHEN 'EP' THEN 'Empréstimo'
	cQuery += "					WHEN 'ES' THEN 'Estorno de Baixa'
	cQuery += "					WHEN 'IS' THEN 'Imposto Substitutivo (Localizações)'
	cQuery += "					WHEN 'J2' THEN 'Juros de titulo em carteira descontada'
	cQuery += "					WHEN 'JR' THEN 'Juros'
	cQuery += "					WHEN 'LJ' THEN 'Movimento do SigaLoja'
	cQuery += "					WHEN 'M2' THEN 'Multa de titulo em carteira descontada'
	cQuery += "					WHEN 'MT' THEN 'Multa'
	cQuery += "					WHEN 'OC' THEN 'Outros Créditos'
	cQuery += "					WHEN 'OD' THEN 'Outras Despesas'
	cQuery += "					WHEN 'OG' THEN 'Outras Garantias (Localizações)'
	cQuery += "					WHEN 'PA' THEN 'Inclusão PA'
	cQuery += "					WHEN 'PE' THEN 'Pagamento Empréstimo'
	cQuery += "					WHEN 'R$' THEN 'Dinheiro'
	cQuery += "					WHEN 'RA' THEN 'Inclusão RA'
	cQuery += "					WHEN 'RF' THEN 'Resgate de Aplicações'
	cQuery += "					WHEN 'SG' THEN 'Entrada de Dinheiro no Caixa (Loja)'
	cQuery += "					WHEN 'TC' THEN 'Troco'
	cQuery += "					WHEN 'TE' THEN 'Estorno de transferência (Movimento Bancário Manual)'
	cQuery += "					WHEN 'TL' THEN 'Tolerância de Recebimento'
	cQuery += "					WHEN 'TR' THEN 'Transferência para carteira descontada'
	cQuery += "					WHEN 'V2' THEN 'Baixa de titulo em carteira descontada'
	cQuery += "					WHEN 'VL' THEN 'Baixa de titulo'
	cQuery += "					WHEN 'VM' THEN 'Variação Monetária' else 'Verificar' end  as [TIPO_DOC]
	cQuery += "  , E5_MOTBX as [MOT_BX]
	cQuery += "  , E5_VLMOED2 as [VLR_MOEDA]
	cQuery += "  , USR.USR_CODIGO as [PUID]
	cQuery += "  , USR.USR_NOME as [USUARIO]
	cQuery += "  , E2_NUMBOR as [BORDERO]
	cQuery += "  , E2_CODBAR as [NUM_BCO]
	cQuery += "  , E2_IDCNAB as [ID_CNAB]
	cQuery += "  , E5_RECPAG as [RecPag]
	cQuery += "  , CASE WHEN E5_HISTOR like '%CNAB%' THEN 'BOLETO'
	cQuery += "		 WHEN E5_MOTBX = 'CMP' THEN 'COMPENSACAO'
	cQuery += "		 WHEN E5_HISTOR LIKE '%Juros%' THEN 'JUROS/MULTA/DESCONT'
	cQuery += "		 WHEN E5_HISTOR LIKE '%Multa%' THEN 'JUROS/MULTA/DESCONT'
	cQuery += "		 WHEN E5_HISTOR LIKE '%Desconto%' THEN 'JUROS/MULTA/DESCONT'
	cQuery += "		 WHEN E5_ORIGEM = 'FINA378' THEN 'AGLUTINACAO IMPOSTO'
	cQuery += "		 ELSE 'DEPOSITO' END [TIPO_PAGTO]
	cQuery += "   , CASE WHEN E5_HISTOR like '%CNAB%' OR E5_ARQCNAB != '' THEN 'CNAB' ELSE 'MANUAL' END AS [FORMA_BX]
	cQuery += "   , CASE WHEN E2_IDCNAB != '' OR E2_NUMBOR != '' THEN 'AUTOMATICO' ELSE 'MANUAL' END [FORMA_PAGTO]
	cQuery += " FROM SE2010 SE2
	cQuery += " INNER JOIN SE5010 SE5 ON SE5.D_E_L_E_T_ = '' AND E5_FILIAL = E2_FILIAL
	cQuery += " 	AND E5_PREFIXO = E2_PREFIXO
	cQuery += " 	AND E5_NUMERO = E2_NUM
	cQuery += " 	AND E5_TIPO = E2_TIPO
	cQuery += " 	AND E5_PARCELA = E2_PARCELA
	cQuery += " 	AND E5_FORNECE = E2_FORNECE
	cQuery += " 	AND E5_LOJA = E2_LOJA
	cQuery += " INNER JOIN SA2010 SA2 with(nolock) ON A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
	cQuery += " INNER JOIN SED010 SED with(nolock) ON ED_CODIGO = E2_NATUREZ
	cQuery += " INNER JOIN SZM010 SZM with(nolock) ON ZM_FILEMP = SUBSTRING(E2_FILIAL,1,2) AND ZM_LOCALID = 'LOCAL' AND SZM.D_E_L_E_T_ = ''
	cQuery += " LEFT JOIN SYS_USR USR ON
	cQuery += "            CASE
	cQuery += "                WHEN (SUBSTRING(SE5.E5_USERLGI, 11, 1) != ' ') THEN
	cQuery += "                    SUBSTRING(SE5.E5_USERLGI, 11, 01) + SUBSTRING(SE5.E5_USERLGI, 15, 01) + SUBSTRING(SE5.E5_USERLGI, 02, 01) +
	cQuery += "                    SUBSTRING(SE5.E5_USERLGI, 06, 01) + SUBSTRING(SE5.E5_USERLGI, 10, 01) + SUBSTRING(SE5.E5_USERLGI, 14, 01)
	cQuery += "                ELSE
	cQuery += "                    SUBSTRING(SE5.E5_USERLGI, 11, 01) + SUBSTRING(SE5.E5_USERLGI, 15, 01) + SUBSTRING(SE5.E5_USERLGI, 02, 01) +
	cQuery += "                    SUBSTRING(SE5.E5_USERLGI, 06, 01) + SUBSTRING(SE5.E5_USERLGI, 10, 01) + SUBSTRING(SE5.E5_USERLGI, 14, 01)
	cQuery += "            END = USR.USR_ID
	cQuery += " WHERE SE2.D_E_L_E_T_ = ''
	cQuery += "   AND E5_VALOR != 0
	cQuery += "   AND E2_EMIS1 >= CONVERT(char, dateadd(year, -2, getdate()),112)

	cQuery += "    AND E2_FILIAL  >= '" + MV_PAR01 + "'
	cQuery += "    AND E2_FILIAL  <= '" + MV_PAR02 + "'
	cQuery += "    AND E2_EMISSAO >= '" + dTos(MV_PAR03) + "'
	cQuery += "    AND E2_EMISSAO <= '" + dTos(MV_PAR04) + "'
	cQuery += "    AND E2_VENCREA >= '" + dTos(MV_PAR05) + "'
	cQuery += "    AND E2_VENCREA <= '" + dTos(MV_PAR06) + "'
	cQuery += "    AND E2_TIPO NOT IN " + FormatIn(MVABATIM,"|")
	cQuery += "    AND E2_TIPO NOT IN " + FormatIn(MVPROVIS,";")
	cQuery += "    AND E2_EMIS1 >= '" + dTos(MV_PAR07) + "'
	cQuery += "    AND E2_EMIS1 <= '" + dTos(MV_PAR08) + "'
	cQuery += "    AND E5_TIPODOC NOT IN ('CM','CX','VM','C2')
	cQuery += "    AND E5_ORIGEM != 'FINA378'
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

		oFWMsExcel:AddColumn(cSheet, cTitulo,"LE"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"FILIAL"           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"COD CLI/FORN"     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"LOJA"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NOME"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PREFIXO"          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NUMERO"           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"TIPO"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PARCELA"          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"ORIGEM"           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DT EMISSAO"       ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DT CONTABIL"      ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DT VENCTO"        ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"MOEDA"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VLR. LIQUIDADO"   ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NATUREZA"         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DESC. NATUREZA"   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"EMP. COLIGADA"    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VALOR TITULO"     ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"SALDO"            ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DATA MOV. BANCO"  ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"TIPO DOCUMENTO"   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"MOTIVO BAIXA"     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VALOR MOEDA"      ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PUID"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"USUARIO"          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NUM. BORDERO"     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NUM. BANCO"       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"ID CNAB"          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"TIPO PAGTO"       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"FORMA BAIXA"      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"FORMA PAGTO"      ,1,1)

		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando titulo " + (cTRB)->TITULO + "...")


			oFWMsExcel:AddRow(cSheet, cTitulo,{(cTRB)->EMPRESA,;
				(cTRB)->FILIAL,;
				(cTRB)->CLIFOR,;
				(cTRB)->LOJA,;
				(cTRB)->NOME,;
				(cTRB)->PREFIXO,;
				(cTRB)->TITULO,;
				(cTRB)->TIPO,;
				(cTRB)->PARCELA,;
				(cTRB)->RecPag,;
				sTod((cTRB)->EMISSAO),;
				sTod((cTRB)->DT_CONTABIL),;
				sTod((cTRB)->VENCTO),;
				(cTRB)->MOEDA,;
				(cTRB)->VAL_LIQ,;
				(cTRB)->NATUREZA,;
				(cTRB)->DESC_NAT,;
				(cTRB)->COLIGADA,;
				(cTRB)->VAL_TIT,;
				(cTRB)->SALDO,;
				sTod((cTRB)->DATA_MOV),;
				(cTRB)->TIPO_DOC,;
				(cTRB)->MOT_BX,;
				(cTRB)->VLR_MOEDA,;
				(cTRB)->PUID,;
				(cTRB)->USUARIO,;
				(cTRB)->BORDERO,;
				(cTRB)->NUM_BCO,;
				(cTRB)->ID_CNAB,;
				(cTRB)->TIPO_PAGTO,;
				(cTRB)->FORMA_BX,;
				(cTRB)->FORMA_PAGTO})


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
