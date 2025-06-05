#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"



User Function BlqMovFor()
	Local nGTCad     := 0
	Local nGTReg     := 0
	Local oBCanc
	Local oBConf
	Local oBExp
	Local oBInv
	Local oGroup1
	Local oGTCad
	Local oGTReg
	Local oNo        := LoadBitmap( GetResources(), "LBNO")
	Local oOk        := LoadBitmap( GetResources(), "LBOK")
	Local oSay1
	Local oSay2
	Local oSay3
	Private aBrowser := {}
	private nGTRSel  := 0
	Private oBrowser
	private oGTRSel

	Static oDlgBlqSA2


	cQuery := ""
	cQuery += " SELECT A2_COD AS CODIGO, A2_LOJA AS LOJA, A2_NOME AS NOME, A2_CGC AS CNPJ, SA2.R_E_C_N_O_ AS RECNO FROM " + RetSqlName("SA2") + " SA2
	cQuery += " WHERE SA2.D_E_L_E_T_ = ''
	cQuery += " AND A2_CGC NOT IN (
	cQuery += " SELECT N2.CNPJ
	cQuery += " FROM(
	cQuery += "     SELECT CNPJ, MAX(EMISSAO) AS EMISSAO
	cQuery += "     FROM(
	cQuery += "         SELECT A2_CGC AS CNPJ, MAX(C7_EMISSAO) AS EMISSAO FROM " + RetSqlName("SC7") + " SC7
	cQuery += "         INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = '' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA
	cQuery += "         AND A2_COD NOT IN ('BRUNKW')
	cQuery += "         WHERE SC7.D_E_L_E_T_ = ''
	cQuery += "         GROUP BY A2_CGC
	cQuery += "         UNION ALL
	cQuery += "         SELECT A2_CGC AS CNPJ, MAX(F1_DTDIGIT) AS EMISSAO FROM " + RetSqlName("SF1") + " SF1
	cQuery += "         INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = '' AND A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA
	cQuery += "         AND A2_COD NOT IN ('BRUNKW')
	cQuery += "         WHERE SF1.D_E_L_E_T_ = ''
	cQuery += "         AND F1_TIPO != 'D'
	cQuery += "         GROUP BY A2_CGC
	cQuery += "         UNION ALL
	cQuery += "         SELECT A2_CGC AS CNPJ, MAX(F2_EMISSAO) AS EMISSAO FROM " + RetSqlName("SF2") + " SF2
	cQuery += "         INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA
	cQuery += "         AND A2_COD NOT IN ('BRUNKW')
	cQuery += "         WHERE SF2.D_E_L_E_T_ = ''
	cQuery += "         AND F2_TIPO = 'B'
	cQuery += "         GROUP BY A2_CGC
	cQuery += "         UNION ALL
	cQuery += "         SELECT A2_CGC AS CNPJ, MAX(E2_EMISSAO) AS EMISSAO FROM " + RetSqlName("SE2") + " SE2
	cQuery += "         INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = '' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
	cQuery += "         AND A2_COD NOT IN ('BRUNKW')
	cQuery += "         WHERE SE2.D_E_L_E_T_ = ''
	cQuery += "         GROUP BY A2_CGC
	cQuery += "     )N1
	cQuery += "     WHERE EMISSAO >= CONVERT(CHAR, DATEADD(MONTH,-18, GETDATE()), 112)
	cQuery += "     GROUP BY CNPJ
	cQuery += " )N2
	cQuery += " GROUP BY N2.CNPJ
	cQuery += " )
	cQuery += " AND A2_MSBLQL != '1' AND A2_ZZCOLIG != 'S' AND A2_COD NOT IN ('BRUNKW')
	cQuery += " ORDER BY 3
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())

	while (cTRB)->(!eof())

		Aadd(aBrowser,{.T.,(cTRB)->CODIGO,;
			(cTRB)->LOJA,;
			alltrim((cTRB)->NOME),;
			(cTRB)->CNPJ,;
			(cTRB)->RECNO})
		nGTReg += 1
		nGTRSel += 1
		(cTRB)->(dbSkip())
	EndDo
	(cTRB)->(dbCloseArea())

	cQuery := ""
	cQuery += " SELECT COUNT(*) AS REG FROM " + RetSqlName("SA2") +" WHERE D_E_L_E_T_ = '' AND A2_MSBLQL != '1'"
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	nGTCad := (cTRB)->REG
	(cTRB)->(dbCloseArea())


	DEFINE MSDIALOG oDlgBlqSA2 TITLE "::.. Bloqueio Fornecedor Sem Movimento ..::" FROM 000, 000  TO 500, 600 COLORS 0, 16777215 PIXEL

	@ 010, 005 LISTBOX oBrowser Fields HEADER "","CODIGO","LOJA","NOME","CNPJ" SIZE 290, 178 OF oDlgBlqSA2 PIXEL ColSizes 5,40,20,80,40
	oBrowser:SetArray(aBrowser)
	oBrowser:bLine := {|| {;
		If(aBrowser[oBrowser:nAT,1],oOk,oNo),;
			aBrowser[oBrowser:nAt,2],;
			aBrowser[oBrowser:nAt,3],;
			aBrowser[oBrowser:nAt,4],;
			aBrowser[oBrowser:nAt,5];
			}}
		// DoubleClick event
		oBrowser:bLDblClick := {|| aBrowser[oBrowser:nAt,1] := !aBrowser[oBrowser:nAt,1],;
			(oBrowser:DrawSelect(), TotSel())}


		@ 191, 005 SAY oSay1 PROMPT "Total Cadastros" SIZE 042, 007 OF oDlgBlqSA2 COLORS 0, 16777215 PIXEL
		@ 199, 005 MSGET oGTCad VAR nGTCad SIZE 046, 010 OF oDlgBlqSA2 COLORS 0, 16777215 PIXEL
		@ 191, 085 SAY oSay2 PROMPT "Total Registros" SIZE 044, 007 OF oDlgBlqSA2 COLORS 0, 16777215 PIXEL
		@ 199, 085 MSGET oGTReg VAR nGTReg SIZE 046, 010 OF oDlgBlqSA2 COLORS 0, 16777215 PIXEL
		@ 191, 165 SAY oSay3 PROMPT "Total Reg. Sel." SIZE 044, 007 OF oDlgBlqSA2 COLORS 0, 16777215 PIXEL
		@ 199, 165 MSGET oGTRSel VAR nGTRSel SIZE 042, 010 OF oDlgBlqSA2 COLORS 0, 16777215 PIXEL

		@ 212, 002 GROUP oGroup1 TO 244, 297 OF oDlgBlqSA2 COLOR 0, 16777215 PIXEL
		@ 219, 006 BUTTON oBExp PROMPT "Exportar Excel" SIZE 055, 020 OF oDlgBlqSA2 PIXEL
		@ 219, 065 BUTTON oBInv PROMPT "Inverter Seleção" SIZE 055, 020 OF oDlgBlqSA2 PIXEL
		@ 219, 237 BUTTON oBCanc PROMPT "Cancelar" SIZE 055, 020 OF oDlgBlqSA2 PIXEL
		@ 219, 178 BUTTON oBConf PROMPT "Confirmar" SIZE 055, 020 OF oDlgBlqSA2 PIXEL

		oGTCad:Disable()
		oGTReg:Disable()
		oGTRSel:Disable()

		oBExp:bAction  := {|| ExpExcel()}
		oBInv:bAction  := {|| (InvSel(), TotSel())}
		oBConf:bAction := {|| iif(Grava(), oDlgBlqSA2:End(),nil) }
		oBCanc:bAction := {|| oDlgBlqSA2:End()}

		ACTIVATE MSDIALOG oDlgBlqSA2 CENTERED

		Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function InvSel()

	aEval(aBrowser,{|X| X[1] := !X[1]})

Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function TotSel()
	nGTRSel := 0
	aEval(aBrowser,{|X| iif(X[1],nGTRSel += 1,0) })

	oGTRSel:Refresh(.T.)
Return()
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function Grava()
	local lRet := .T. as logical
	local nX   := 0   as numeric


	If FwAlertYesNo("Confirma o processamento de bloqueio dos registros?","Bloqueio Cadastro")
		For nX := 1 To Len(aBrowser)
			If aBrowser[nX][1]
				dbSelectArea("SA2")
				SA2->(dbGoTo(aBrowser[nX][6]))
				reclock("SA2",.F.)
				SA2->A2_MSBLQL := "1"

				If SA2->(FieldPos("A2_XDTBLOQ")) > 0
					SA2->A2_XDTBLOQ := Date()
				EndIf

				If SA2->(FieldPos("A2_XUSBLOQ")) > 0
					SA2->A2_XUSBLOQ := cUserName
				EndIf

				SA2->(MsUnlock())
			EndIf
		Next nX
	else
		lRet := .F.
	EndIf

return(lRet)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function ExpExcel()
	local cSheet   := "Cad. Fornecedor"
	local cTitPlan := "Fornecedores Sem Movimento Ultimo Ano"
	local cArquivo := ""
	local nX       := 0


	cArquivo := "c:\temp\BlqFor_" + Substr(dTos(date()),1,6)+".XML"
	If file(cArquivo)
		FERASE(cArquivo)
	EndIf

	oFWMsExcel := FWMsExcelEx():New()

	oFWMsExcel:AddworkSheet(cSheet)
	oFWMsExcel:AddTable(cSheet, cTitPlan)

	oFWMsExcel:AddColumn(cSheet, cTitPlan,"Codigo"               ,1,1)
	oFWMsExcel:AddColumn(cSheet, cTitPlan,"Loja"                ,1,1)
	oFWMsExcel:AddColumn(cSheet, cTitPlan,"Nome"                ,1,1)
	oFWMsExcel:AddColumn(cSheet, cTitPlan,"CNPJ"                ,1,1)

	For nX := 1 To Len(aBrowser)
		If aBrowser[nX][1]
			oFWMsExcel:AddRow(cSheet,cTitPlan,{aBrowser[nX][2],;
				aBrowser[nX][3],;
				aBrowser[nX][4],;
				aBrowser[nX][5]})
		EndIf
	Next nX



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

Return()
