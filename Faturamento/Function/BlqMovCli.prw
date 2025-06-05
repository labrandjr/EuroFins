#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"



User Function BlqMovCli()
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

	Static oDlgBlqSA1


	cQuery := ""
	cQuery += " SELECT A1_COD AS CODIGO, A1_LOJA AS LOJA, A1_NOME AS NOME, A1_CGC AS CNPJ, SA1.R_E_C_N_O_ AS RECNO FROM " + RetSqlName("SA1") + " SA1
	cQuery += " WHERE SA1.D_E_L_E_T_ = ''
	cQuery += " AND A1_CGC NOT IN (
	cQuery += " SELECT N2.CNPJ
	cQuery += " FROM(
	cQuery += "     SELECT CNPJ, MAX(EMISSAO) AS EMISSAO
	cQuery += "     FROM(
	cQuery += "         SELECT A1_CGC AS CNPJ, MAX(C5_EMISSAO) AS EMISSAO FROM " + RetSqlName("SC5") + " SC5
	cQuery += "         INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI
	cQuery += "         WHERE SC5.D_E_L_E_T_ = ''
	cQuery += "         GROUP BY A1_CGC
	cQuery += "         UNION ALL
	cQuery += "         SELECT A1_CGC AS CNPJ, MAX(F2_EMISSAO) AS EMISSAO FROM " + RetSqlName("SF2") + " SF2
	cQuery += "         INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA
	cQuery += "         WHERE SF2.D_E_L_E_T_ = ''
	cQuery += "         AND F2_TIPO != 'D'
	cQuery += "         GROUP BY A1_CGC
	cQuery += "         UNION ALL
	cQuery += "         SELECT A1_CGC AS CNPJ, MAX(F1_DTDIGIT) AS EMISSAO FROM " + RetSqlName("SF1") + " SF1
	cQuery += "         INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND A1_COD = F1_FORNECE AND A1_LOJA = F1_LOJA
	cQuery += "         WHERE SF1.D_E_L_E_T_ = ''
	cQuery += "         AND F1_TIPO = 'D'
	cQuery += "         GROUP BY A1_CGC
	cQuery += "         UNION ALL
	cQuery += "         SELECT A1_CGC AS CNPJ, MAX(E1_EMISSAO) AS EMISSAO FROM " + RetSqlName("SE1") + " SE1
	cQuery += "         INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
	cQuery += "         WHERE SE1.D_E_L_E_T_ = ''
	cQuery += "         GROUP BY A1_CGC
	cQuery += "     )N1
	cQuery += "     WHERE EMISSAO >= CONVERT(CHAR, DATEADD(YEAR,-1, GETDATE()), 112)
	cQuery += "     GROUP BY CNPJ
	cQuery += " )N2
	cQuery += " GROUP BY N2.CNPJ
	cQuery += " )
	cQuery += " AND A1_MSBLQL != '1' AND A1_ZZCOLIG != 'S' AND A1_COD NOT IN ('BRUNKW')
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
	cQuery += " SELECT COUNT(*) AS REG FROM " + RetSqlName("SA1") +" WHERE D_E_L_E_T_ = '' AND A1_MSBLQL != '1'"
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	nGTCad := (cTRB)->REG
	(cTRB)->(dbCloseArea())


	DEFINE MSDIALOG oDlgBlqSA1 TITLE "::.. Bloqueio Cliente Sem Movimento ..::" FROM 000, 000  TO 500, 600 COLORS 0, 16777215 PIXEL

	@ 010, 005 LISTBOX oBrowser Fields HEADER "","CODIGO","LOJA","NOME","CNPJ" SIZE 290, 178 OF oDlgBlqSA1 PIXEL ColSizes 5,40,20,80,40
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


		@ 191, 005 SAY oSay1 PROMPT "Total Cadastros" SIZE 042, 007 OF oDlgBlqSA1 COLORS 0, 16777215 PIXEL
		@ 199, 005 MSGET oGTCad VAR nGTCad SIZE 046, 010 OF oDlgBlqSA1 COLORS 0, 16777215 PIXEL
		@ 191, 085 SAY oSay2 PROMPT "Total Registros" SIZE 044, 007 OF oDlgBlqSA1 COLORS 0, 16777215 PIXEL
		@ 199, 085 MSGET oGTReg VAR nGTReg SIZE 046, 010 OF oDlgBlqSA1 COLORS 0, 16777215 PIXEL
		@ 191, 165 SAY oSay3 PROMPT "Total Reg. Sel." SIZE 044, 007 OF oDlgBlqSA1 COLORS 0, 16777215 PIXEL
		@ 199, 165 MSGET oGTRSel VAR nGTRSel SIZE 042, 010 OF oDlgBlqSA1 COLORS 0, 16777215 PIXEL

		@ 212, 002 GROUP oGroup1 TO 244, 297 OF oDlgBlqSA1 COLOR 0, 16777215 PIXEL
		@ 219, 006 BUTTON oBExp PROMPT "Exportar Excel" SIZE 055, 020 OF oDlgBlqSA1 PIXEL
		@ 219, 065 BUTTON oBInv PROMPT "Inverter Seleção" SIZE 055, 020 OF oDlgBlqSA1 PIXEL
		@ 219, 237 BUTTON oBCanc PROMPT "Cancelar" SIZE 055, 020 OF oDlgBlqSA1 PIXEL
		@ 219, 178 BUTTON oBConf PROMPT "Confirmar" SIZE 055, 020 OF oDlgBlqSA1 PIXEL

		oGTCad:Disable()
		oGTReg:Disable()
		oGTRSel:Disable()

		oBExp:bAction  :={|| ExpExcel()}
		oBInv:bAction  :={|| (InvSel(), TotSel())}
		oBConf:bAction :={|| IIF(Grava(), oDlgBlqSA1:End(),NIL)}
		oBCanc:bAction :={||oDlgBlqSA1:End()}

		ACTIVATE MSDIALOG oDlgBlqSA1 CENTERED

		Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function InvSel()

	aEval(aBrowser,{|X| X[1] := !X[1]})

Return
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function Grava()
	local lRet := .T. as logical
	local nX   := 0   as numeric


	If FwAlertYesNo("Confirma o processamento de bloqueio dos registros?","Bloqueio Cadastro")
		For nX := 1 To Len(aBrowser)
			If aBrowser[nX][1]
				dbSelectArea("SA1")
				SA1->(dbGoTo(aBrowser[nX][6]))
				reclock("SA1",.F.)
				SA1->A1_MSBLQL := "1"

				If SA1->(FieldPos("A1_XDTBLOQ")) > 0
					SA1->A1_XDTBLOQ := Date()
				EndIf

				If SA1->(FieldPos("A1_XUSBLOQ")) > 0
					SA1->A1_XUSBLOQ := cUserName
				EndIf

				SA1->(MsUnlock())
			EndIf
		Next nX
	else
		lRet := .F.
	EndIf

return(lRet)
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function TotSel()
	nGTRSel := 0
	aEval(aBrowser,{|X| iif(X[1],nGTRSel += 1,0) })

	oGTRSel:Refresh(.T.)
Return()


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function ExpExcel()
	local cSheet   := "Cad. Clientes"
	local cTitPlan := "Clientes Sem Movimento Ultimo Ano"
	local cArquivo := ""
	local nX       := 0


	cArquivo := "c:\temp\BlqCli_" + Substr(dTos(date()),1,6)+".XML"
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
