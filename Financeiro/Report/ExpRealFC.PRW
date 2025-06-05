#include 'totvs.ch'
#include 'topconn.ch'

user function ExpRealFC()

	local cTitle       := "Processamento Movimento Realizado"
	local bProcess     := { |oSelf| Retpor(oSelf) }
	local cDescription := "Este programa tem como objetivo exportar em Excel os movimentos financeiro realizados."
	local cPerg        := 'MOVFINI_IS'
	private cFunction  := ""

	cFunction  := Substr(FunName(),1,8)
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )


return()


// ----------------------------------------------------------------------------------------------------------------------------------------------------------

static function Retpor(op_Self)
	local cQuery   := ""
	local cArquivo := "c:\temp\PlanFin_Real.XML"
	// local nRegs    := 0
	local cSheet   := "Mov. Realizado"
	local cTitPlan := "Base Fluxo de Caixa"

	op_Self:SetRegua1(2)
	op_Self:SetRegua2(1)
	op_Self:IncRegua1("Leitura dos registros financeiro")

	cQuery := ""
	cQuery += " SELECT *
	cQuery += " FROM(
	cQuery += "     SELECT * FROM vwEurofins_Base_Financeiro_CP_Fluxo_Caixa_Realizado
	cQuery += "     UNION ALL
	cQuery += "     SELECT * FROM vwEurofins_Base_Financeiro_CR_Fluxo_Caixa_Realizado
	cQuery += "     UNION ALL
	cQuery += "     SELECT * FROM vwEurofins_Base_Financeiro_MB_Fluxo_Caixa_Realizado
	cQuery += "     )N1
	cQuery += " WHERE Filial >= '" + MV_PAR01 + "'"
	cQuery += "  AND Filial <= '" + MV_PAR02 + "'"
	cQuery += "  AND Contabil >= '" + dTos(MV_PAR03) + "'"
	cQuery += "  AND Contabil <= '" + dTos(MV_PAR04) + "'"
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	// Count to nRegs
	// op_Self:SetRegua2(nRegs)
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
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Cliente"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Loja"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"I/C Code"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Nome Cliente"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"UF"                           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Origem"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Prefixo"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Numero"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Parcela"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Tipo"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Historico Fin"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Banco"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Agencia"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Conta"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Data Emissao"                 ,2,4)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Data Contabil"                ,2,4)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Data Vencimento"              ,2,4)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Moeda"                        ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Taxa Moeda"                   ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Valor Moeda"                  ,3,2,.T.)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Valor BRL"                    ,3,2,.T.)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Natureza"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Desc. Natureza"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Coligada"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Categoria Cli. / For."        ,1,1)


		while (cTRB)->(!eof())


			op_Self:IncRegua2("Processando titulo " + (cTRB)->Numero + "...")

			oFWMsExcel:AddRow(cSheet,cTitPlan,{(cTRB)->Filial,;
				(cTRB)->LE,;
				(cTRB)->Cliente,;
				(cTRB)->Loja,;
				(cTRB)->IC_CODE,;
				(cTRB)->Nome,;
				(cTRB)->UF,;
				(cTRB)->Origem,;
				(cTRB)->Prefixo,;
				(cTRB)->Numero,;
				(cTRB)->Parcela,;
				(cTRB)->Tipo,;
				(cTRB)->Historico,;
				(cTRB)->Banco,;
				(cTRB)->Agencia,;
				(cTRB)->Conta,;
				sTod((cTRB)->Emissao),;
				sTod((cTRB)->Contabil),;
				sTod((cTRB)->Vencimento),;
				(cTRB)->Moeda,;
				(cTRB)->Taxa,;
				(cTRB)->Valor,;
				(cTRB)->Valor_BRL,;
				(cTRB)->Natureza,;
				(cTRB)->Desc_Nat,;
				(cTRB)->Coligada,;
				(cTRB)->Cat_CliFor})

			(cTRB)->(dbSkip())
		EndDo
		(cTRB)->(dbCloseArea())

		op_Self:IncRegua1("Exportando registro Excel")
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

return()
