#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'


static lEurofins := !("YMLLLM" $ GetEnvServer())

user function RTitPag()
	local cEmpX := "01"
	local cFilX := iif(lEurofins, "0100", "5000")

	PREPARE ENVIRONMENT EMPRESA cEmpX FILIAL cFilX MODULO "FIN"
	ProcQry()
	RESET ENVIRONMENT

return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function ProcQry()
	local cQuery := "" as character
	local cSheet := "Financeiro CR" as character
	local cTitulo := "Relação de Titulos em Aberto Contas a Pagar" as character
	local cPatch := "\temp\" as character
	local cFile := "RTitPag_" + dTos(dDataBase) + ".xls" as character

	cQuery := ""
	cQuery += " SELECT Filial
	cQuery += "      , LE
	cQuery += "      , Cliente
	cQuery += "      , Loja
	cQuery += "      , [I/C Code] AS IC_Code
	cQuery += "      , Nome
	cQuery += "      , UF
	cQuery += "      , Origem
	cQuery += "      , Prefixo
	cQuery += "      , Numero
	cQuery += "      , Parcela
	cQuery += "      , Tipo
	cQuery += "      , Historico
	cQuery += "      , [Data Emissao] AS [Emissao]
	cQuery += "      , [Data Contábil] AS [Contabil]
	cQuery += "      , [Data Vencimento] AS [Vencimento]
	cQuery += "      , Moeda
	cQuery += "      , CASE WHEN [Taxa Moeda] = 0 THEN 1 ELSE [Taxa Moeda] END AS [Taxa]
	cQuery += "      , [Valor Moeda] * Fator AS [Valor_Moeda]
	cQuery += "      , [Valor BRL] * Fator AS [Valor_BRL]
	cQuery += "      , Saldo * Fator as [Saldo_Moeda]
	cQuery += "      , (Saldo * CASE WHEN [Taxa Moeda] = 0 THEN 1 ELSE [Taxa Moeda] END) * Fator as [Saldo_BRL]
	cQuery += "      , (Saldo * CASE WHEN [Taxa Data] = 0 THEN 1 ELSE [Taxa Data] END) * Fator as [Saldo_Data]
	cQuery += "      , [Taxa Data] as [Taxa_Data]
	cQuery += "      , Natureza
	cQuery += "      , [Desc. Natureza] AS [Desc_Nat]
	cQuery += "      , Coligada
	cQuery += "      , [Categoria Fornecedor] AS [Categoria]
	cQuery += "  FROM(
	cQuery += "     SELECT E2_FILIAL AS [Filial]
	cQuery += "          , ZM_CODIGO AS [LE]
	cQuery += "          , E2_FORNECE AS [Cliente]
	cQuery += "          , E2_LOJA AS [Loja]
	cQuery += "          , A2_XICCODE AS [I/C Code]
	cQuery += "          , ltrim(rtrim(A2_NOME)) as [Nome]
	cQuery += "          , A2_EST AS [UF]
	cQuery += "          , 'PAG' AS [Origem]
	cQuery += "          , E2_PREFIXO AS [Prefixo]
	cQuery += "          , E2_NUM as [Numero]
	cQuery += "          , E2_PARCELA as [Parcela]
	cQuery += "          , E2_TIPO as [Tipo]
	cQuery += "          , ltrim(rtrim(E2_HIST)) as [Historico]
	cQuery += "          , E2_EMISSAO as [Data Emissao]
	cQuery += "          , E2_EMIS1 as [Data Contábil]
	cQuery += "          , E2_VENCREA as [Data Vencimento]
	cQuery += "  	     , CASE E2_MOEDA WHEN 1 THEN 'BRL'
	cQuery += "                         WHEN 2 THEN 'USD'
	cQuery += "                         WHEN 4 THEN 'USD'
	cQuery += "                         WHEN 5 THEN 'EUR'
	cQuery += "                         WHEN 6 THEN 'EUR'
	cQuery += "                         WHEN 7 THEN 'CLP'
	cQuery += "                         WHEN 8 THEN 'CLP'
	cQuery += "                         WHEN 9 THEN 'GBP'
	cQuery += "                         WHEN 10 THEN 'GBP'
	cQuery += "                         WHEN 11 THEN 'SEK'
	cQuery += "                         WHEN 12 THEN 'SEK'
	cQuery += "                         WHEN 13 THEN 'CAD'
	cQuery += "                         WHEN 14 THEN 'CAD'
	cQuery += "                         WHEN 15 THEN 'NOK'
	cQuery += "                         WHEN 16 THEN 'NOK'
	cQuery += "                         WHEN 17 THEN 'CHF'
	cQuery += "                         WHEN 18 THEN 'CHF'
	cQuery += "                         WHEN 19 THEN 'DKK'
	cQuery += "                         WHEN 20 THEN 'DKK'
	cQuery += "                         WHEN 21 THEN 'NZD'
	cQuery += "                         WHEN 22 THEN 'NZD'
	cQuery += "                         WHEN 23 THEN 'ARS'
	cQuery += "                         WHEN 24 THEN 'ARS'
	cQuery += "                         WHEN 25 THEN 'AUD'
	cQuery += "                         WHEN 26 THEN 'AUD'
	cQuery += "                         ELSE 'XXX' END AS Moeda
	cQuery += "          , E2_VALOR - (E2_COFINS + E2_PIS + E2_CSLL) AS [Valor Moeda]
	cQuery += "          , E2_VLCRUZ - (E2_COFINS + E2_PIS + E2_CSLL) AS [Valor BRL]
	cQuery += "          , E2_SALDO - (E2_COFINS + E2_PIS + E2_CSLL) as [Saldo]
	cQuery += "          , E2_NATUREZ AS [Natureza]
	cQuery += "          , isnull(ltrim(rtrim(ED_DESCRIC)),'') AS [Desc. Natureza]
	cQuery += "          , A2_ZZCOLIG AS [Coligada]
	cQuery += "          , case when E2_TXMOEDA = 0 then isnull(CASE E2_MOEDA WHEN 1 THEN M2_MOEDA1
	cQuery += "                         WHEN 2 THEN M2_MOEDA2
	cQuery += "                         WHEN 4 THEN M2_MOEDA4
	cQuery += "                         WHEN 5 THEN M2_MOEDA5
	cQuery += "                         WHEN 6 THEN M2_MOEDA6
	cQuery += "                         WHEN 7 THEN M2_MOEDA7
	cQuery += "                         WHEN 8 THEN M2_MOEDA8
	cQuery += "                         WHEN 9 THEN M2_MOEDA9
	cQuery += "                         WHEN 10 THEN M2_MOEDA10
	cQuery += "                         WHEN 11 THEN M2_MOEDA11
	cQuery += "                         WHEN 12 THEN M2_MOEDA12
	cQuery += "                         WHEN 13 THEN M2_MOEDA13
	cQuery += "                         WHEN 14 THEN M2_MOEDA14
	cQuery += "                         WHEN 15 THEN M2_MOEDA15
	cQuery += "                         WHEN 16 THEN M2_MOEDA16
	If lEurofins
		cQuery += "                         WHEN 17 THEN M2_MOEDA17
		cQuery += "                         WHEN 18 THEN M2_MOEDA18
		cQuery += "                         WHEN 19 THEN M2_MOEDA19
		cQuery += "                         WHEN 20 THEN M2_MOEDA20
		cQuery += "                         WHEN 21 THEN M2_MOEDA21
		cQuery += "                         WHEN 22 THEN M2_MOEDA22
		cQuery += "                         WHEN 23 THEN M2_MOEDA23
		cQuery += "                         WHEN 24 THEN M2_MOEDA24
		cQuery += "                         WHEN 25 THEN M2_MOEDA25
		cQuery += "                         WHEN 26 THEN M2_MOEDA26
	EndIf
	cQuery += "                         ELSE E2_TXMOEDA END,1) ELSE E2_TXMOEDA END AS [Taxa Moeda]
	cQuery += "          , isnull(CASE E2_MOEDA WHEN 1 THEN M2_MOEDA1
	cQuery += "                         WHEN 2 THEN M2_MOEDA2
	cQuery += "                         WHEN 4 THEN M2_MOEDA4
	cQuery += "                         WHEN 5 THEN M2_MOEDA5
	cQuery += "                         WHEN 6 THEN M2_MOEDA6
	cQuery += "                         WHEN 7 THEN M2_MOEDA7
	cQuery += "                         WHEN 8 THEN M2_MOEDA8
	cQuery += "                         WHEN 9 THEN M2_MOEDA9
	cQuery += "                         WHEN 10 THEN M2_MOEDA10
	cQuery += "                         WHEN 11 THEN M2_MOEDA11
	cQuery += "                         WHEN 12 THEN M2_MOEDA12
	cQuery += "                         WHEN 13 THEN M2_MOEDA13
	cQuery += "                         WHEN 14 THEN M2_MOEDA14
	cQuery += "                         WHEN 15 THEN M2_MOEDA15
	cQuery += "                         WHEN 16 THEN M2_MOEDA16
	If lEurofins
		cQuery += "                         WHEN 17 THEN M2_MOEDA17
		cQuery += "                         WHEN 18 THEN M2_MOEDA18
		cQuery += "                         WHEN 19 THEN M2_MOEDA19
		cQuery += "                         WHEN 20 THEN M2_MOEDA20
		cQuery += "                         WHEN 21 THEN M2_MOEDA21
		cQuery += "                         WHEN 22 THEN M2_MOEDA22
		cQuery += "                         WHEN 23 THEN M2_MOEDA23
		cQuery += "                         WHEN 24 THEN M2_MOEDA24
		cQuery += "                         WHEN 25 THEN M2_MOEDA25
		cQuery += "                         WHEN 26 THEN M2_MOEDA26
	EndIf
	cQuery += "                         ELSE 1 END,1) AS [Taxa Data]
	cQuery += "           , case when A2_ZZCOLIG = 'S' AND A2_EST != 'EX' then 'COLIGADA NACIONAL'
	cQuery += "                  when A2_ZZCOLIG = 'S' AND A2_EST = 'EX' then 'INTERCOMPANY'
	cQuery += "                  when A2_ZZCOLIG != 'S' AND A2_EST != 'EX' then'FORNECEDORES NACIONAL'
	cQuery += "                  when A2_ZZCOLIG != 'S' AND A2_EST = 'EX' then 'FORNECEDORES ESTRANGEIRO' else '#DEF' End as [Categoria Fornecedor]
	cQuery += "           , case when E2_TIPO IN ('AB-','FB-','FC-','FU-','IR-','IN-','IS-','PI-','CF-','CS-','FE-','IV-','PA-','NDF','PA') THEN -1 ELSE 1 END as Fator
	cQuery += "       FROM " + RetSqlName("SE2") + " SE2 WITH(NOLOCK)
	cQuery += "       INNER JOIN " + RetSqlName("SZM") + " SZM WITH(NOLOCK) ON SZM.D_E_L_E_T_ = '' AND ZM_FILEMP = LEFT(E2_FILIAL,2)
	cQuery += "       LEFT JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.D_E_L_E_T_ = '' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
	cQuery += "       LEFT JOIN " + RetSqlName("SED") + " SED WITH(NOLOCK) ON SED.D_E_L_E_T_ = '' AND ED_CODIGO = E2_NATUREZ
	cQuery += "       LEFT JOIN " + RetSqlName("SM2") + " SM2 WITH(NOLOCK) ON SM2.D_E_L_E_T_ = '' AND M2_DATA = convert(char, getdate(),112)
	cQuery += "       WHERE SE2.D_E_L_E_T_ = ''
	cQuery += "         AND E2_SALDO != 0
	cQuery += " )N1
	TcQuery cQuery New Alias (cTRB := GetNextAlias())


	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())

		oFWMsExcel := FWMsExcelEx():New()

		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitulo)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"Filial" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"LE" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Cliente" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Loja" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"I/C Code" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Nome" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"UF" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Origem" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Prefixo" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Numero" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Parcela" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tipo" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Historico" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Emissao" ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Contábil" ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Vencimento" ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Moeda" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Taxa Moeda" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor Moeda" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor BRL" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Saldo Moeda" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Saldo BRL" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Saldo BRL Data" ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Taxa Data" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Natureza" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Desc. Natureza" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Coligada" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Categoria Cli/For" ,1,1)

		While (cTRB)->(!eof())

			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->Filial,;
				(cTRB)->LE,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->IC_Code,;
				(cTRB)->Nome,;
				(cTRB)->UF,;
				(cTRB)->Origem,;
				(cTRB)->Prefixo,;
				(cTRB)->Numero,;
				(cTRB)->Parcela,;
				(cTRB)->Tipo,;
				(cTRB)->Historico,;
				sTod((cTRB)->Emissao),;
				sTod((cTRB)->Contabil),;
				sTod((cTRB)->Vencimento),;
				(cTRB)->Moeda,;
				(cTRB)->Taxa,;
				(cTRB)->Valor_Moeda,;
				(cTRB)->Valor_BRL,;
				(cTRB)->Saldo_Moeda,;
				(cTRB)->Saldo_BRL,;
				(cTRB)->Saldo_Data,;
				(cTRB)->Taxa_Data,;
				(cTRB)->Natureza,;
				(cTRB)->Desc_Nat,;
				(cTRB)->Coligada,;
				(cTRB)->Categoria})

			(cTRB)->(dbSkip())
		EndDo



		If ! ExistDir(cPatch)
			FWMakeDir(cPatch,.F.)
		EndIf

		If File(cPatch+cFile)
			FERASE(cPatch+cFile)
		EndIf

		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cPatch+cFile)

		If File(cPatch+cFile)

			cFileZip := strTran(cFile,".xls",".ZIP")
			cFileZip := cPatch + cFileZip
			If FZip(cFileZip,{cPatch+cFile},cPatch) == 0
				FErase(cPatch+cFile)
			EndIf

			cTitulo := ""
			If lEurofins
				cTitulo := 'Relatorio Contas a Pagar Eurofins - ' + cValToChar(Date())
			Else
				cTitulo := 'Relatorio Contas a Pagar Clinical - ' + cValToChar(Date())
			EndIf

			If File(cFileZip)

                cPara := GetMv("CL_EMAILCP")
				U_SendMail(, cPara, ;
					'',;
					cTitulo,;
					'Relatorio Contas a Pagar',;
					cFileZip)


				If File(cFileZip)
					FERASE(cFileZip)
				EndIf
			EndIf

		EndIf
	EndIf
	(cTRB)->(dbCloseArea())

return()
