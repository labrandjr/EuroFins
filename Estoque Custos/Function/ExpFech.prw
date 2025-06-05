#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'


user function ExpFech()
	local aPerg := {} as array
	local cProdDe := space(tamSx3("B1_COD")[1])
	local cProdAte := replicate('Z', tamSx3("B1_COD")[1])
	local cTipoDe := space(tamSx3("B1_TIPO")[1])
	local cTipoAte := replicate('Z', tamSx3("B1_TIPO")[1])
	local cTipoNC := space(100)
	local cPeriodo := "      "

	aadd(aPerg, {1, "Periodo (AAAAMM) :"      , cPeriodo                , "@R 9999-99", "", ""   , "", 110, .T.}) //MV_PAR01
	aadd(aPerg, {1, "Filial de:"              , CriaVar("F1_FILIAL",.f.), ""          , "", "SM0", "", 110, .F.}) //MV_PAR02
	aadd(aPerg, {1, "Filial até:"             , CriaVar("F1_FILIAL",.f.), ""          , "", "SM0", "", 110, .T.}) //MV_PAR03
	aadd(aPerg, {1, "Produto de:"             , cProdDe                 , ""          , "", "SB1", "", 110, .F.}) //MV_PAR04
	aadd(aPerg, {1, "Produto Ate:"            , cProdAte                , ""          , "", "SB1", "", 110, .T.}) //MV_PAR05
	aadd(aPerg, {1, "Tipo Produto De:"        , cTipoDe                 , ""          , "", "02" , "", 110, .F.}) //MV_PAR06
	aadd(aPerg, {1, "Tipo Produto Ate:"       , cTipoAte                , ""          , "", "02" , "", 110, .T.}) //MV_PAR07
	aadd(aPerg, {1, "Nao Considerar Tipo (,):", cTipoNC                 , ""          , "", ""   , "", 110, .F.}) //MV_PAR08


	If ParamBox(aPerg,"Notas Fiscais de Entrada",,,,,,,,ProcName(),.T.,.T.)
		Processa({||ProcExcel() },"Gerando Planilha..." )
	Endif


return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function ProcExcel()

	local cSheet   := "Fechamento Estoque"
	local cTitPlan := "Fechto Estoque (" + MV_PAR01 + ")"
	local cArquivo := ""
	local cSqlIN   := ""

	If !Empty(MV_PAR08)
		cSqlIN := FormatIN( ALLTRIM(MV_PAR08), ',' )
	EndIf

	cArquivo := GetTempPath() + "MovFechto_" + MV_PAR01+".xls"
	If file(cArquivo)
		FERASE(cArquivo)
	EndIf

	cQuery := ""
	cQuery += " SELECT Filial
	cQuery += "      , [Data] as Emissao
	cQuery += "      , Company
	cQuery += "      , Produto
	cQuery += "      , [Descricão] as Descricao
	cQuery += "      , [Tipo Produto] as Tp_Prod
	cQuery += "      , [Grupo PDB] as Grupo
	cQuery += "      , [Armazém] as Armazem
	cQuery += "      , Qtde
	cQuery += "      , [Custo Médio] as CM
	cQuery += "      , [Valor BRL] as Valor
	cQuery += "      , [Periodo] as Periodo
	cQuery += "      , [Ult. Movimento] as Movimento
	cQuery += "  FROM vwEurofins_Base_Fechamento_Estoque_On "
	cQuery += " WHERE Periodo = '" + MV_PAR01 + "' "
	cQuery += "   AND Filial >= '" + MV_PAR02 + "' "
	cQuery += "   AND Filial <= '" + MV_PAR03 + "' "
	cQuery += "   AND Produto >= '" + MV_PAR04 + "' "
	cQuery += "   AND Produto <= '" + MV_PAR05 + "' "
	cQuery += "   AND substring([Tipo Produto],1,2) >= '" + MV_PAR06 + "' "
	cQuery += "   AND substring([Tipo Produto],1,2) <= '" + MV_PAR07 + "' "
	If !Empty(cSqlIN)
		cQuery += "   AND substring([Tipo Produto],1,2) not in " + cSqlIN
	EndIf
	TcQuery cQuery New Alias (cTRB := GetNextAlias())


	dbSelectArea((cTRB))
	If (cTRB)->(!eof())

		oFWMsExcel := FWMsExcelEx():New()

		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitPlan)

		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Filial"          ,2,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Data"            ,2,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Company"         ,2,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Produto"         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Descricão"       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Tipo Produto"    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Grupo PDB"       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Armazém"         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Qtde"            ,1,2,.T.)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Custo Médio"     ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Valor BRL"       ,1,2,.T.)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Ult. Movimento"  ,2,1)


		while (cTRB)->(!eof())
			oFWMsExcel:AddRow(cSheet,cTitPlan,{(cTRB)->Filial,;
				(cTRB)->Emissao,;
				(cTRB)->Company,;
				(cTRB)->Produto,;
				(cTRB)->Descricao,;
				(cTRB)->Tp_Prod,;
				(cTRB)->Grupo,;
				(cTRB)->Armazem,;
				(cTRB)->Qtde,;
				(cTRB)->CM,;
				(cTRB)->Valor,;
				(cTRB)->Movimento})

			(cTRB)->(dbSkip())
		EndDo



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

return()
