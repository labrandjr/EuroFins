#include 'totvs.ch'
#include 'topconn.ch'


user function MovPagto()
	local l_Job        := .F.
	local cTitle       := "Movimento Bancário Pagamento"
	local bProcess     := ""
	local cDescription := "Este programa tem como objetivo exportar as movimentações bancário de pagamento (Auto)."
	local cPerg        := 'PERIODO'
	private cFunction  := Substr(FunName(),1,8)
	l_Job              := IsBlind()
	bProcess           := {|oSelf| Processa(oSelf)}

	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )


return()
// ---------------------------------------------------------------------------------------------------------------------------------------------------

static function Processa(op_Self)

	local cQuery as character
	local cSheet as character
	local cTitulo as character
	local cArquivo as charecter

	op_Self:SetRegua1(3)
	op_Self:SetRegua2(3)

	cArquivo := "c:\temp\MovPagto_" + DToS(MV_PAR01) + "_" + DToS(MV_PAR02) + ".XML"

	// cPeriodo := substr(MV_PAR01,3,4) + substr(MV_PAR01,1,2)

	oFWMsExcel := FWMsExcelEx():New()

	cQuery := ""
	cQuery += " SELECT ZM_CODIGO AS Empresa
	cQuery += " 	 , E5_FILIAL AS Filial
	cQuery += " 	 , E5_PREFIXO as Prefixo
	cQuery += " 	 , E5_NUMERO as Numero
	cQuery += " 	 , E5_PARCELA AS Parcela
	cQuery += " 	 , E5_TIPO as Tipo
	cQuery += " 	 , CASE WHEN E5_RECPAG = 'R' THEN 'RECEBER' ELSE 'PAGAR' END as [Mov_RP]
	cQuery += " 	 , E5_CLIFOR as [CliFor]
	cQuery += " 	 , E5_LOJA as [Loja]
	cQuery += " 	 , ltrim(rtrim(E5_BENEF)) AS [Nome]
	cQuery += " 	 , substring(E5_DATA,1,6) as [Periodo]
	cQuery += " 	 , E5_DATA as Data
	cQuery += " 	 , E5_DTDISPO AS [DtDispo]
	cQuery += " 	 , E5_DTDIGIT AS [DtDigit]
	cQuery += " 	 , E5_BANCO as [Portador]
	cQuery += " 	 , ltrim(rtrim(E5_NATUREZ)) AS [Natureza]
	cQuery += " 	 , ltrim(rtrim(E5_HISTOR)) as [Historico]
	cQuery += " 	 , E5_VALOR as [Valor]
	cQuery += " 	 , E5_VRETPIS AS [PIS]
	cQuery += " 	 , E5_VRETCOF AS [COFINS]
	cQuery += " 	 , E5_VRETCSL AS [CSLL]
	cQuery += " 	 , E5_VRETIRF AS [IRRF]
	cQuery += " 	 , E5_MOTBX as MotBx
	cQuery += " 	 , E5_LA [LA]
	cQuery += " 	 , E5_USERLGI [USRE_LGI]
	cQuery += " FROM " + RetSqlName("SE5") + " SE5 WITH(NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SZM") + " SZM WITH(NOLOCK) ON SZM.D_E_L_E_T_ = '' AND ZM_FILEMP = SUBSTRING(E5_FILIAL,1,2)
	cQuery += " WHERE SE5.D_E_L_E_T_ = ''
	cQuery += " AND E5_ARQCNAB != ''
	cQuery += " AND E5_DATA >= '" + DToS(MV_PAR01) + "'
	cQuery += " AND E5_DATA <= '" + DToS(MV_PAR02) + "'

	TcQuery cQuery New Alias (cTRB_PA := GetNextAlias())
	nRecQry := 0
	Count To nRecQry
	dbSelectArea((cTRB_PA))
	(cTRB_PA)->(dbGoTop())
	IF (cTRB_PA)->(!eof())
		op_Self:SetRegua2(nRecQry)
		cTitulo := "Movimento Pagamento Auto - Periodo " + cValToChar(MV_PAR01) + '  -  ' + cValToChar(MV_PAR02)
		cSheet := "Pagamento Auto"
		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitulo)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"Reporting Company"    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Filial"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Periodo"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Prefixo"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Numero"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Parcela"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tipo"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Mov. Rec/Pagar"       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Cliente / Fornecedor" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Loja"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Nome"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data"                 ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Dispo"           ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Digitacao"       ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Portador"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Natureza"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Historico"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor"                ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Motivo Baixa"         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"LA"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Usuario"              ,1,1)



		while (cTRB_PA)->(!eof())

			cUserInc := Embaralha((cTRB_PA)->USRE_LGI,1)
			cUserInc := iif(!empty(cUserInc),alltrim(UsrRetName(substring(cUserInc,3,6))) + " - " + alltrim(UsrFullName(substring(cUserInc,3,6))),"")
			op_Self:IncRegua2("")
			oFWMsExcel:AddRow(cSheet, cTitulo,{(cTRB_PA)->Empresa,;
				(cTRB_PA)->Filial,;
				(cTRB_PA)->Periodo,;
				(cTRB_PA)->Prefixo,;
				(cTRB_PA)->Numero,;
				(cTRB_PA)->Parcela,;
				(cTRB_PA)->Tipo,;
				(cTRB_PA)->Mov_RP,;
				(cTRB_PA)->CliFor,;
				(cTRB_PA)->Loja,;
				(cTRB_PA)->Nome,;
				sTod((cTRB_PA)->Data),;
				sTod((cTRB_PA)->DtDispo),;
				sTod((cTRB_PA)->DtDigit),;
				(cTRB_PA)->Portador,;
				(cTRB_PA)->Natureza,;
				(cTRB_PA)->Historico,;
				(cTRB_PA)->Valor,;
				(cTRB_PA)->MotBx,;
				(cTRB_PA)->LA,;
				cUserInc})

			(cTRB_PA)->(dbSkip())
		EndDo
	EndIf
	(cTRB_PA)->(dbCloseArea())

	op_Self:IncRegua1("")
	cQuery := ""
	cQuery += " SELECT ZM_CODIGO AS Empresa
	cQuery += " 	 , E5_FILIAL AS Filial
	cQuery += " 	 , E5_PREFIXO as Prefixo
	cQuery += " 	 , E5_NUMERO as Numero
	cQuery += " 	 , E5_PARCELA AS Parcela
	cQuery += " 	 , E5_TIPO as Tipo
	cQuery += " 	 , CASE WHEN E5_RECPAG = 'R' THEN 'RECEBER' ELSE 'PAGAR' END as [Mov_RP]
	cQuery += " 	 , E5_CLIFOR as [CliFor]
	cQuery += " 	 , E5_LOJA as [Loja]
	cQuery += " 	 , ltrim(rtrim(E5_BENEF)) AS [Nome]
	cQuery += " 	 , substring(E5_DATA,1,6) as [Periodo]
	cQuery += " 	 , E5_DATA as Data
	cQuery += " 	 , E5_DTDISPO AS [DtDispo]
	cQuery += " 	 , E5_DTDIGIT AS [DtDigit]
	cQuery += " 	 , E5_BANCO as [Portador]
	cQuery += " 	 , ltrim(rtrim(E5_NATUREZ)) AS [Natureza]
	cQuery += " 	 , ltrim(rtrim(E5_HISTOR)) as [Historico]
	cQuery += " 	 , E5_VALOR as [Valor]
	cQuery += " 	 , E5_VRETPIS AS [PIS]
	cQuery += " 	 , E5_VRETCOF AS [COFINS]
	cQuery += " 	 , E5_VRETCSL AS [CSLL]
	cQuery += " 	 , E5_VRETIRF AS [IRRF]
	cQuery += " 	 , E5_MOTBX as MotBx
	cQuery += " 	 , E5_LA [LA]
	cQuery += "      , CASE WHEN E5_ARQCNAB != '' THEN 'BAIXA AUTOMATICO'
	cQuery += "      		WHEN E5_HISTOR LIKE '%Baixa Total por CNAB%' THEN 'BAIXA AUTOMATICO'
	cQuery += "      		WHEN E5_ORIGEM IN ('FINA300','FINA090','FINA091','FINA110','FINA200','RPC') THEN 'BAIXA AUTOMATICO' ELSE 'BAIXA MANUAL' END [Sit_BX]
	cQuery += " 	 , E5_USERLGI [USRE_LGI]
	cQuery += " FROM " + RetSqlName("SE5") + " SE5 WITH(NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SZM") + " SZM WITH(NOLOCK) ON SZM.D_E_L_E_T_ = '' AND ZM_FILEMP = SUBSTRING(E5_FILIAL,1,2)
	cQuery += " WHERE SE5.D_E_L_E_T_ = ''
	// cQuery += " AND SUBSTRING(E5_DATA,1,6) = '" + cPeriodo + "'
	cQuery += " AND E5_DATA >= '" + DToS(MV_PAR01) + "'
	cQuery += " AND E5_DATA <= '" + DToS(MV_PAR02) + "'

	TcQuery cQuery New Alias (cTRB_BA := GetNextAlias())
	nRecQry := 0
	Count To nRecQry
	dbSelectArea((cTRB_BA))
	(cTRB_BA)->(dbGoTop())
	IF (cTRB_BA)->(!eof())
		op_Self:SetRegua2(nRecQry)
		// cTitulo := "Movimento Baixa Auto - Periodo " + substr(MV_PAR01,1,2) + '-' + substr(MV_PAR01,3,4)
		cTitulo := "Movimento Baixa Auto - Periodo " + cValToChar(MV_PAR01) + '  -  ' + cValToChar(MV_PAR02)
		cSheet := "Baixas Auto"
		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitulo)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"Reporting Company"    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Filial"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Periodo"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Prefixo"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Numero"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Parcela"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tipo"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Mov. Rec/Pagar"       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Cliente / Fornecedor" ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Loja"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Nome"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data"                 ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Dispo"           ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Digitacao"       ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Portador"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Natureza"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Historico"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor"                ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Motivo Baixa"         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"LA"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Situacao Baixa"       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Usuario"              ,1,1)

		while (cTRB_BA)->(!eof())

			cUserInc := Embaralha((cTRB_BA)->USRE_LGI,1)
			cUserInc := iif(!empty(cUserInc),alltrim(UsrRetName(substring(cUserInc,3,6))) + " - " + alltrim(UsrFullName(substring(cUserInc,3,6))),"")

			op_Self:IncRegua2("")
			oFWMsExcel:AddRow(cSheet, cTitulo,{(cTRB_BA)->Empresa,;
				(cTRB_BA)->Filial,;
				(cTRB_BA)->Periodo,;
				(cTRB_BA)->Prefixo,;
				(cTRB_BA)->Numero,;
				(cTRB_BA)->Parcela,;
				(cTRB_BA)->Tipo,;
				(cTRB_BA)->Mov_RP,;
				(cTRB_BA)->CliFor,;
				(cTRB_BA)->Loja,;
				(cTRB_BA)->Nome,;
				sTod((cTRB_BA)->Data),;
				sTod((cTRB_BA)->DtDispo),;
				sTod((cTRB_BA)->DtDigit),;
				(cTRB_BA)->Portador,;
				(cTRB_BA)->Natureza,;
				(cTRB_BA)->Historico,;
				(cTRB_BA)->Valor,;
				(cTRB_BA)->MotBx,;
				(cTRB_BA)->LA,;
				(cTRB_BA)->Sit_BX,;
				cUserInc})

			(cTRB_BA)->(dbSkip())
		EndDo
	EndIf
	(cTRB_BA)->(dbCloseArea())


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











return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------
