#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#include 'topconn.ch'



/*/{Protheus.doc} EXPINVOICE
Gera csv no servidor para integração de nota de entrada com o COupa
@author Tiago Maniero
@since 25/05/2020
/*/
User Function ExpInvoice(cDoc,cSerie,cFornece,cLoja,lEstorno)

	local oFile
	local cArq    := ""
	local cAlias
	local aAdress := {}
	local cDtVenc := ""
	local cPedido := ""

	private lDelete     := lEstorno

	geraLog( Replicate("*",30) )
	geraLog( "Inicio Rotina" )

	if !lDelete
		geraLog("Chamada pela rotina MATA140")
	elseif lDelete
		geraLog("Chamada pela rotina U_SF1100E")
	else
		geraLog("Rotina: " + ProcName(1))
	endif

	cAlias  := SelectNota(cDoc,cSerie,cFornece,cLoja)

	//aAdress := { (cAlias)->ZZC_ID , (cAlias)->ZZC_LE } //RetAdress((cAlias)->CH_CC)
	aAdress := { "" , (cAlias)->ZZC_LE } //RetAdress((cAlias)->CH_CC)

	cDtVenc := GetDataVenc(cDoc,cSerie,cFornece,cLoja)

	if (cAlias) -> (!EoF())
		cArq := "INV_BR-PR_" + DtoS(dDatabase) + StrTran(Time(),":","") + "_" + aAdress[2] + FWUUIDV4(.T.) +".csv"
		oFile :=  ManagerTXT():New("\coupa\INVOICE\pendente\" + cArq)
		oFile:CRIARTXT()

		geraLog("Criando o arquivo: " + cArq )
		cPedido     := (cAlias)->D1_PEDIDO

		//As três primeiras linhas tem conteúdo fixo
		oFile:INCLINHA("Invoice header,Invoice Number,Supplier Name,Supplier Number,Status,Invoice Date,Submit for Approval,Handling Amount,Misc Amount,Shipping Amount,";
			+"Line Level Taxation,Tax Amount,Tax Rate,Supplier Note,Payment Terms,Shipping Terms,Chart of Accounts,Currency,Payment Date,";
			+"Bill To Address Id,Original invoice date,Is Credit Note,Gross Total,Control Total,Image Scan Filename")
		oFile:INCLINHA("Invoice Charge,Invoice Number,Supplier Name,Supplier Number,Line Number,Type,Description,Total,Line Tax Amount")
		oFile:INCLINHA("Invoice Line,Invoice Number,Supplier Name,Supplier Number,Line Number,Description,Supplier Part Number,Price,Quantity,";
			+"Line Tax Amount,Unit of Measure,PO Number,PO Line Number")

		CompLinhas(cAlias,aAdress,cDtVenc,@oFile)

		oFile:FECHAARQUIVO()
		GravaZZD(cDoc, cPedido ,"\coupa\INVOICE\pendente\",cArq)
	endIf
	(cAlias)->(DbCloseArea())

	geraLog( "Final Rotina" )
	geraLog( Replicate("*",30) )

Return

Static Function SelectNota(cDoc,cSerie,cFornece,cLoja)
	local cQuery    := ""
	local cAlias    := GetNextAlias()
	local nQtdTotal := 0

	cQuery += "Select " + CRLF
	cQuery += "F1_DOC, F1_SERIE, C7_FORNECE, C7_LOJA, F1_EMISSAO," + CRLF
	cQuery += "F1_FRETE, F1_COND, F1_TPFRETE, A2_NOME, D1_ZZCODF, D1_VALIPI, F1_VALIPI," + CRLF
	cQuery += "D1_ITEM, D1_DOC, D1_FORNECE, C7_ITEM, D1_VUNIT, D1_COD, D1_QUANT,D1_SEGUM,B1_SEGUM,D1_QTSEGUM, " + CRLF
	cQuery += "D1_PEDIDO, D1_TES, " + CRLF
	//cQuery += "ISNULL(ZZC.ZZC_ID,ZZC_1.ZZC_ID) AS ZZC_ID," + CRLF
	cQuery += "ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE) AS ZZC_LE," + CRLF
	cQuery += "B1_DESC, F4_TEXTO, D1_TOTAL,C7_ZZCCOUP, D1_UM , sum(D1_TOTAL) AS SOMA, (Select SUM(D1_TOTAL+D1_VALIPI)
	cQuery += "                                                     FROM " + RetSqlName("SD1") + " SD1IN WHERE " + CRLF
	cQuery += "		                                                    SD1IN.D1_DOC = SD1.D1_DOC " + CRLF
	cQuery += "		                                                    AND SD1IN.D1_SERIE = SD1.D1_SERIE " + CRLF
	cQuery += "		                                                    AND SD1IN.D1_FORNECE = SD1.D1_FORNECE " + CRLF
	cQuery += "		                                                    AND SD1IN.D1_LOJA = SD1.D1_LOJA " + CRLF
	cQuery += "		                                                    AND SD1IN.D1_ITEM = SD1.D1_ITEM " + CRLF
	cQuery += "		                                                    AND SD1IN.D_E_L_E_T_ = '" + Iif(lDelete,"*"," ") + "' " + CRLF
	cQuery += "		                                                    AND SD1IN.D1_FILIAL = SD1.D1_FILIAL) as TOTALIZADOR " + CRLF
	cQuery += "	, F1_CHVNFE, F1_ESPECIE " + CRLF
	cQuery += " FROM " + RetSqlTab("SF1") + CRLF
	cQuery += "     INNER JOIN " + RetSqlTab("SD1") + CRLF
	cQuery += "         ON  D1_DOC = F1_DOC  " + CRLF
	cQuery += "         AND D1_SERIE = F1_SERIE " + CRLF
	cQuery += "         AND D1_FORNECE = F1_FORNECE " + CRLF
	cQuery += "         AND D1_LOJA = F1_LOJA " + CRLF
	cQuery += "		    AND D1_FILIAL = F1_FILIAL " + CRLF
	cQuery += "		    AND SD1.D_E_L_E_T_ = '" + Iif(lDelete,"*"," ") + "' " + CRLF
	cQuery += "		 INNER JOIN " + RetSqlTab("SA2") + CRLF
	cQuery += "		    ON A2_COD = D1_FORNECE " + CRLF
	cQuery += "		    AND A2_LOJA = D1_LOJA " + CRLF
	cQuery += "		 LEFT JOIN " + RetSqlTab("SF4") + CRLF
	cQuery += "		    ON F4_CODIGO = D1_TES " + CRLF
	cQuery += "		    AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		INNER JOIN " + RetSqlTab("SB1") + CRLF
	cQuery += "		    ON B1_COD = D1_COD " + CRLF
	cQuery += "         AND B1_FILIAL = D1_FILIAL " + CRLF
	cQuery += "		    AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		INNER JOIN " + RetSqlTab("SC7") + CRLF
	cQuery += "		    ON  D1_FORNECE = C7_FORNECE " + CRLF
	//cQuery += "         AND D1_LOJA = C7_LOJA  " + CRLF
	cQuery += "         AND D1_PEDIDO = C7_NUM " + CRLF
	cQuery += "         AND D1_ITEMPC = C7_ITEM " + CRLF
	cQuery += "		    AND D1_FILIAL = C7_FILIAL " + CRLF
	cQuery += "		    AND D1_COD = C7_PRODUTO " + CRLF
	cQuery += "		    AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		LEFT JOIN " + RetSqlTab("SCH") + CRLF
	cQuery += "		    ON  CH_FORNECE = C7_FORNECE " + CRLF
	cQuery += "         AND CH_LOJA = C7_LOJA " + CRLF
	cQuery += "		    AND CH_PEDIDO = C7_NUM " + CRLF
	cQuery += "         AND CH_ITEMPD = C7_ITEM " + CRLF
	cQuery += "		    AND CH_FILIAL = C7_FILIAL " + CRLF
	cQuery += "		    AND SCH.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "		LEFT JOIN " + RetSqlTab("ZZC") + CRLF
	cQuery += "		    ON  ZZC.ZZC_FILCLI     = D1_FILIAL" + CRLF
	cQuery += "		    AND ZZC.ZZC_CCUSTO = CH_CC" + CRLF
	cQuery += "		    AND ZZC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		LEFT JOIN " + RetSqlName("ZZC") + " ZZC_1 " + CRLF
	cQuery += "		    ON  ZZC_1.ZZC_FILCLI     = D1_FILIAL " + CRLF
	cQuery += "		    AND ZZC_1.ZZC_CCUSTO = C7_CC " + CRLF
	cQuery += "		    AND ZZC_1.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "		 WHERE F1_FILIAL = '" + xFilial("SF1") + "' " + CRLF
	cQuery += "         AND F1_DOC = '" + cDoc + "' " + CRLF
	cQuery += "		    AND F1_SERIE = '" + cSerie + "' " + CRLF
	cQuery += "		    AND F1_FORNECE = '" + cFornece + "' " + CRLF
	cQuery += "		    AND F1_LOJA = '" + cLoja + "' " + CRLF
	cQuery += "		    AND C7_ZZCCOUP <> ' ' " + CRLF
	cQuery += "		    AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		 GROUP BY  " + CRLF
	cQuery += "		    F1_DOC, F1_SERIE, C7_FORNECE, C7_LOJA, F1_FRETE, F1_EMISSAO, " + CRLF
	cQuery += "		    F1_COND, F1_TPFRETE, D1_TOTAL," + CRLF
	//cQuery += "		    ISNULL(ZZC.ZZC_ID,ZZC_1.ZZC_ID)," + CRLF
	cQuery += "		    ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE)," + CRLF
	cQuery += "         D1_VALIPI,F1_VALIPI, D1_ITEM, D1_DOC, D1_FORNECE, C7_ITEM, D1_VUNIT, D1_COD, D1_QUANT, D1_SEGUM,B1_SEGUM,D1_QTSEGUM, D1_PEDIDO, D1_TES, " + CRLF
	cQuery += "         D1_ZZCODF, C7_ZZCCOUP, D1_CC, B1_DESC, F4_TEXTO, A2_NOME, D1_UM, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_FILIAL " + CRLF
	cQuery += "         , F1_CHVNFE, F1_ESPECIE " + CRLF
	cQuery += "      ORDER BY D1_DOC,D1_ITEM"

	geraLog("Query: " + changequery(cQuery) )

	TcQuery cQuery New Alias &cAlias
	Count to nQtdTotal
	DbSelectArea(cAlias)
	(cAlias) -> (DbGoTop())

	geraLog("Resulta da consulta : " + cValToChar(nQtdTotal))

Return cAlias


Static Function CompLinhas(cAlias,aAdress,cDtVenc,oFile)

	local cUniMed   := ""
	local cCondPg   := RetCondPg((cAlias)->F1_COND)
	local cStatus   := ""
	local nQtd      := 0
	local nTotal    := 0
	local nPrcUnit  := 0
	local cNomFile  := ""

	Iif(lDelete, cStatus := "voided", cStatus := "new")

	If !Empty((cAlias)->F1_CHVNFE) .and. !lDelete
		aAreaSave := GetArea()
		cNomFile := U_GerPDFNfe((cAlias)->F1_CHVNFE, alltrim((cAlias)->F1_ESPECIE) == "SPED")
		RestArea(aAreaSave)
	EndIf

	oFile:INCLINHA("INVOICE HEADER,";
		+ (cAlias)->F1_DOC + (cAlias)->F1_SERIE + ",";
		+ StrTran(Alltrim((cAlias)->A2_NOME),",","") + ",";
		+ (cAlias)->C7_FORNECE + (cAlias)->C7_LOJA + ",";
		+ cStatus + ",";
		+ SubStr((cAlias)->F1_EMISSAO,1,4) + "-" + SubStr((cAlias)->F1_EMISSAO,5,2)+ "-"+ SubStr((cAlias)->F1_EMISSAO,7,2) + ",";
		+ "Y,";
		+ ",";
		+ ",";
		+ cValToChar((cAlias)->F1_FRETE) + ",";
		+ "Y,";
		+ ",";
		+ ",";
		+ ",";
		+ cCondPg + ",";
		+ (cAlias)->F1_TPFRETE + ",";
		+ aAdress[2] + ",";
		+ "BRL,";
		+ cDtVenc + ",";
		+ aAdress[1] + ",";
		+ SubStr((cAlias)->F1_EMISSAO,1,4) + "-" + SubStr((cAlias)->F1_EMISSAO,5,2)+ "-"+ SubStr((cAlias)->F1_EMISSAO,7,2) + ",";
		+ "N,";
		+ ",";
		+ cValToChar((cAlias)->TOTALIZADOR + (cAlias)->F1_FRETE );
		+ "," + cNomFile )


	While  (cAlias)->(!EoF())
		cUniMed     := (cAlias)->B1_SEGUM

		//nQtd        := (cAlias)->D1_QTSEGUM
		nQtd := ConvUM( (cAlias)->D1_COD , (cAlias)->D1_QUANT , 0 , 2 )

		nTotal      := (cAlias)->D1_TOTAL
		nPrcUnit    := nTotal / nQtd

		oFile:INCLINHA("INVOICE LINE,";
			+ (cAlias)->F1_DOC + (cAlias)->F1_SERIE + ",";
			+ StrTran(Alltrim((cAlias)->A2_NOME),",","") + ",";
			+ (cAlias)->C7_FORNECE + (cAlias)->C7_LOJA + ",";
			+ (cAlias)->C7_ITEM + ",";
			+ StrTran(AllTrim((cAlias)->B1_DESC),","," ") + ",";
			+ AllTrim((cAlias)->D1_ZZCODF) + ",";
			+ cValToChar( nPrcUnit ) + ",";
			+ cValToChar( nQtd ) + ",";
			+ cValToChar((cAlias)->D1_VALIPI) + ",";
			+ AllTrim(cUniMed) + ",";
			+ (cAlias)->C7_ZZCCOUP + ",";
			+ cValToChar(Val((cAlias)->C7_ITEM)) + ",";
			+ " ")

		(cAlias)->(DbSkip())
	EndDo

Return


Static Function RetAdress(cCentroCusto)
	local cQuery   := ""
	local cAliasCC := GetNextAlias()
	local aRetorno := {}


	cQuery += "SELECT ZZC_ID, ZZC_LE FROM " + RetSqlTab("ZZC") + CRLF
	cQuery += " WHERE ZZC_FILCLI = '" + cFilAnt + "' " + CRLF
	cQuery += "     AND ZZC_CCUSTO = '" + cCentroCusto + "' " + CRLF
	cQuery += "     AND ZZC.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias &cAliasCC

	DbSelectArea(cAliasCC)
	(cAliasCC)->(DbGoTop())
	aAdd(aRetorno,(cAliasCC)->ZZC_ID)
	aAdd(aRetorno,(cAliasCC)->ZZC_LE)
	(cAliasCC)->(DbCloseArea())


Return aRetorno


Static Function RetCondPg(cDescri)
	local cRetorno := ""
	local cQuery   := ""
	local cAlias   := GetNextAlias()

	cQuery += "SELECT X5_CHAVE FROM " + RetSqlTab("SX5") + CRLF
	cQuery += " WHERE X5_TABELA = 'Z4' " + CRLF
	cQuery += "     AND X5_DESCRI = '" + cDescri + "'"

	TcQuery cQuery New Alias &cAlias

	DbSelectArea(cAlias)
	cRetorno := (cAlias)->X5_CHAVE
	(cAlias)->(DbCloseArea())


Return cRetorno

Static Function GetDataVenc(cDoc,cSerie,cFornece,cLoja)
	local cQuery := ""
	local cDtAlias := GetNextAlias()
	local cDataVenc := ""

	cQuery += "SELECT TOP 1 E2_VENCREA, MAX(E2_PARCELA) " + CRLF
	cQuery += "		FROM " + RetSqlTab("SE2") + CRLF
	cQuery += "     WHERE E2_FILIAL = '" + xFilial("SE2") + "' " + CRLF
	cQuery += "		    AND E2_NUM = '" + cDoc + "' " + CRLF
	cQuery += "         AND E2_PREFIXO = '" + cSerie + "' " + CRLF
	cQuery += "			AND E2_FORNECE = '" + cFornece + "' " + CRLF
	cQuery += "			AND E2_LOJA = '" + cLoja + "' " + CRLF
	cQuery += "		GROUP BY E2_VENCREA " + CRLF
	cQuery += "		ORDER BY E2_VENCREA DESC"

	TcQuery cQuery New Alias &cDtAlias

	DbSelectArea(cDtAlias)
	cDataVenc := SubStr((cDtAlias)->E2_VENCREA,1,4) + "-" + SubStr((cDtAlias)->E2_VENCREA,5,2)+ "-"+ SubStr((cDtAlias)->E2_VENCREA,7,2)
	(cDtAlias)->(DbCloseArea())


Return cDataVenc


Static Function GravaZZD(cNota,cPedido,cDir,cArq)

	local oLibCoupa

	oLibCoupa	:= LibCoupa():New()
	oLibCoupa:setTipo("INVOICE")
	oLibCoupa:setChave(cArq)
	oLibCoupa:setArquivo(cDir+cArq)
	oLibCoupa:setNF(cNota)
	oLibCoupa:setPedido(cPedido)

	If lDelete
		oLibCoupa:setOperacao("EXCLUSAO")
	Else
		oLibCoupa:setOperacao("INCLUSAO")
	EndIf

	oLibCoupa:setIsErro(.F.)
	oLibCoupa:setOcorrencia("INCLUIDO COM SUCESSO")
	oLibCoupa:setPro2COupa(.T.)
	oLibCoupa:gravaZZD()

    /*
    Reclock("ZZD",.T.)
        ZZD->ZZD_COD  := GetSXEnum("ZZD","ZZD_COD")
        ZZD->ZZD_DATA := dDataBase
        ZZD->ZZD_TIPO := "INVOICE"
        ZZD->ZZD_STATUS := "INTEGRADO"
        ZZD->ZZD_CHAVE := cArq
        ZZD->ZZD_FLUXO := "PROTHEUS PARA COUPA"
        ZZD->ZZD_OCORRE := "INCLUIDO COM SUCESSO"
        ZZD->ZZD_TEMPO := DtoC(Date())+ " " + Time()
    MsUnlock()
	ConfirmSX8()
    */

Return

//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

	Conout("[" + DTOC(Date()) + " " + Time() + "] EXPINVOICE - " + cMensagem )

Return
