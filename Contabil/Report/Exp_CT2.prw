#include 'totvs.ch'
#include 'topconn.ch'

user function Exp_CT2()

	local cTitle       := "Export - Movimento Contábil CT2"
	local bProcess     := { |oSelf| Retpor(oSelf) }
	local cDescription := "Este programa tem como objetivo exportar em Excel os movimentos contábil."
	local cPerg        := 'MOVFINI_IS'
	private cFunction  := ""

	cFunction  := Substr(FunName(),1,8)
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )


return()


// ----------------------------------------------------------------------------------------------------------------------------------------------------------

static function Retpor(op_Self)
	local cQuery   := ""
	local cArquivo := "c:\temp\PlanCT2_Movimento.XML"
	// local nRegs    := 0
	local cSheet   := "Mov. Contabil"
	local cTitPlan := "Base Contábil - CT2 Periodo : " + cValToChar(MV_PAR03) + " - " + cValToChar(MV_PAR04)

	op_Self:SetRegua1(2)
	op_Self:SetRegua2(1)
	op_Self:IncRegua1("Leitura dos registros financeiro")

	cQuery := ""
	cQuery += " SELECT CT2_FILIAL AS FILIAL
	cQuery += "      , CT2_DATA AS DATA_CTB
	cQuery += "      , CT2_LOTE AS NUM_LOTE
	cQuery += "      , CT2_SBLOTE AS SBLOTE
	cQuery += "      , CT2_DOC AS DOCUMENTO
	cQuery += "      , CT2_DEBITO AS DEBITO
	cQuery += "      , CT2_CREDIT AS CREDITO
	cQuery += "      , CT2_VALOR AS VALOR
	cQuery += "      , CT2_HIST AS HISTORICO
	cQuery += "      , CT2_USERGI AS USERGI
	cQuery += "      , CT2_USERGA AS USERGA
	cQuery += "      , CASE WHEN CT2_ROTINA  IN ('CTBA102','CTBA500') THEN 'MANUAL' ELSE 'AUTOMATICO' END AS TP_INC
	cQuery += "  FROM " + RetSqlName("CT2")+ " CT2 WITH(NOLOCK)"
	cQuery += " WHERE CT2.D_E_L_E_T_ = ''
	cQuery += " AND CT2_FILIAL >= '" + MV_PAR01 + "'"
	cQuery += " AND CT2_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += " AND CT2_DATA >= '" + dTos(MV_PAR03) + "'"
	cQuery += " AND CT2_DATA <= '" + dTos(MV_PAR04) + "'"
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
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Data Contabil"                ,2,4)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Num. Lote"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Sub. Lote"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Documento"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Cta. Debito"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Cta. Credito"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Valor Contabil"               ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Historico"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Usr Inclusao"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Data Inclusao"                ,2,4)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Usr Alteracao"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Data Alteracao"               ,2,4)
		oFWMsExcel:AddColumn(cSheet, cTitPlan,"Tipo Inclusao"                ,1,1)

		while (cTRB)->(!eof())


			op_Self:IncRegua2("Processando titulo " + (cTRB)->(FILIAL+DATA_CTB+NUM_LOTE+SBLOTE+DOCUMENTO) + "...")

			xUserGI := ""
			xDtGI := cTod("")

			xUserGA := ""
			xDtGA := cTod("")

			If !Empty((cTRB)->USERGI)
				xUserGI := alltrim(UsrRetName(substring(Embaralha((cTRB)->USERGI,1),3,6)))
				xDtGI := CTOD("01/01/96","DDMMYY") + Load2in4(Substr(Embaralha((cTRB)->USERGI,1),16))
			EndIf

			If !Empty((cTRB)->USERGA)
				xUserGA := alltrim(UsrRetName(substring(Embaralha((cTRB)->USERGA,1),3,6)))
				xDtGA := CTOD("01/01/96","DDMMYY") + Load2in4(Substr(Embaralha((cTRB)->USERGA,1),16))
			EndIf


			oFWMsExcel:AddRow(cSheet,cTitPlan,{(cTRB)->FILIAL,;
				sTod((cTRB)->DATA_CTB),;
				(cTRB)->NUM_LOTE,;
				(cTRB)->SBLOTE,;
				(cTRB)->DOCUMENTO,;
				(cTRB)->DEBITO,;
				(cTRB)->CREDITO,;
				(cTRB)->VALOR,;
				(cTRB)->HISTORICO,;
				xUserGI,;
                xDtGI,;
				xUserGA,;
                xDtGA,;
                (cTRB)->TP_INC})

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
