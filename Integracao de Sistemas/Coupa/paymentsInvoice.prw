#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#include 'topconn.ch'
#INCLUDE "TbiConn.ch"


#DEFINE ADRESS  1
#DEFINE NOME    2
#DEFINE FORNECE 3
#DEFINE DOC     4
#DEFINE BAIXA   5
#DEFINE VALBRUT 6
#DEFINE PARCELA 7
#DEFINE STATUS  8


/*/{Protheus.doc} PAYMENTSINVOICE
Gera csv no servidor para integração de pagamento de fornecedores
@author Tiago Maniero
@since 26/05/2020
/*/
User Function paymentsInvoice(xParam1,xParam2,xParam3)

	local oFile
	local cArq          := ""
	local cAlias        := ""
	local cAliasDel     := ""
	local cEmpJob       := ""
	local cFilJob       := ""
	local cIDUsrJob     := ""

	private cAdress     := ""
	private aRegs       := {}
	private lCancel     := .F.

	Default xParam1			:= nil
	Default xParam2			:= nil
	Default xParam3			:= "000000"

	If ValType(xParam1) == "A"
		lJob		:= .T.
		cEmpJob		:= xParam1[01]
		cFilJob		:= xParam1[02]
		cIDUsrJob	:= xParam1[03]
	ElseIf ValType(xParam1) == "C"
		lJob		:= .T.
		cEmpJob		:= xParam1
		cFilJob		:= xParam2
		cIDUsrJob	:= xParam3
	EndIf

	geraLog( Replicate("*",30) )
	geraLog( "Inicio Rotina" )

	If Empty(cEmpJob) .or. Empty(cFilJob)
		geraLog( "EMPRESA / FILIAL NÃO CONFIGURADAS NO JOB" )
	Else
		PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob
		cIDUser			:= cIDUsrJob
		__cUserId		:= cIDUser
		cUserName		:= "Administrador"
		lExecPag        := getnewpar("ZZ_PAYCOUP",.T.)

		If lExecPag
			cAlias    := SelecFornecedores()
			geraLog("")
			cAliasDel := SelecDeletados()

			if !Empty(aRegs)

				cArq := "PM_BR-PR_" + DtoS(dDatabase) + StrTran(Time(),":","") + "_" + cAdress + FWUUIDV4(.T.) +".csv"
				oFile :=  ManagerTXT():New("\coupa\OUTGOING\pendente\" + cArq)


				oFile:CRIARTXT()
				oFile:INCLINHA("ELE number,Supplier Name,Supplier Number,Invoice Number,Expense Report Id,Paid,Paid-in-Full Date,";
					+ "Paid-in-Full Note,Check Amount Paid,Check # / Note,Check Payment Date")

				CompLinhas(@oFile)

				If File("\coupa\OUTGOING\pendente\" + cArq)
					geraLog("Gerando o arquivo [\coupa\OUTGOING\pendente\" + cArq + "]" )
				EndIf

				oFile:FECHAARQUIVO()

				GravaZZD("\coupa\OUTGOING\pendente\",cArq,aRegs[1,4])
			else
				geraLog("Nenhum dado localizado para ser gerado o arquivo.")
			endIf
		else
			geraLog("Rotina está desabilitada.")
		endif
		RESET ENVIRONMENT
	endif

	geraLog( "Final Rotina" )
	geraLog( Replicate("*",30) )

Return

//Query para trazer fornecedores pagos no último período
Static Function SelecFornecedores()

	local cQuery    := ""
	local cAlias    := GetNextAlias()
	local nQtdTotal := 0

	cQuery += "Select MAX(E2_VENCREA) AS MAXPARCELA, E2_FILIAL,E2_PARCELA, E2_TIPO, E5_SEQ, F1_DOC, F1_SERIE, C7_FORNECE, C7_LOJA," + CRLF
	cQuery += " ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE) LE, F1_VALBRUT, A2_NOME,E2_BAIXA,E5_DTCANBX, E5_DATA, E5_NUMERO, E5_MOTBX, E2_BAIXA, E2_SALDO, E5_TIPODOC, E5_RECPAG, E5_DTCANBX " + CRLF
	cQuery += " FROM " + RetSqlTab("SE5") + CRLF
	cQuery += "	INNER JOIN " +  RetSqlTab("SE2") + CRLF
	cQuery += "  ON E2_FILIAL = E5_FILIAL " + CRLF
	cQuery += "     AND E5_NUMERO = E2_NUM " + CRLF
	cQuery += "     AND E5_LOTE = E2_LOTE " + CRLF
	cQuery += "     AND E5_PREFIXO = E2_PREFIXO " + CRLF
	cQuery += "     AND E5_PARCELA = E2_PARCELA " + CRLF
	cQuery += "     AND E5_TIPO = E2_TIPO " + CRLF
	cQuery += "     AND E5_CLIFOR = E2_FORNECE " + CRLF
	cQuery += "     AND E5_LOJA = E2_LOJA " + CRLF
	cQuery += " INNER JOIN " + RetSqlTab("SF1") + CRLF
	cQuery += "    ON E2_NUM = F1_DOC" + CRLF
	cQuery += "        AND E2_PREFIXO = F1_SERIE" + CRLF
	cQuery += "        AND E2_FILIAL = F1_FILIAL" + CRLF
	cQuery += "        AND E2_FORNECE = F1_FORNECE" + CRLF
	cQuery += "        AND E2_LOJA = F1_LOJA " + CRLF
	cQuery += "        AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlTab("SD1") + CRLF
	cQuery += "    ON  D1_DOC = F1_DOC " + CRLF
	cQuery += "        AND D1_SERIE = F1_SERIE " + CRLF
	cQuery += "        AND D1_FORNECE = F1_FORNECE " + CRLF
	cQuery += "        AND D1_LOJA = F1_LOJA " + CRLF
	cQuery += "        AND D1_FILIAL = F1_FILIAL " + CRLF
	cQuery += "        AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlTab("SA2") + CRLF
	cQuery += "    ON A2_COD = D1_FORNECE " + CRLF
	cQuery += "        AND A2_LOJA = D1_LOJA " + CRLF
	cQuery += "        AND SA2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlTab("SC7") + CRLF
	cQuery += "    ON  D1_FORNECE = C7_FORNECE " + CRLF
	cQuery += "        AND D1_PEDIDO = C7_NUM " + CRLF
	cQuery += "        AND D1_FILIAL = C7_FILIAL " + CRLF
	cQuery += "        AND D1_COD = C7_PRODUTO " + CRLF
	cQuery += "        AND D1_ITEMPC = C7_ITEM " + CRLF
	cQuery += "        AND C7_ZZINTCO = 'S' " + CRLF
	cQuery += "        AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlTab("SCH") + CRLF
	cQuery += "    ON  CH_FORNECE = C7_FORNECE " + CRLF
	cQuery += "        AND CH_LOJA = C7_LOJA " + CRLF
	cQuery += "        AND CH_PEDIDO = C7_NUM " + CRLF
	cQuery += "        AND CH_ITEMPD = C7_ITEM " + CRLF
	cQuery += "        AND CH_FILIAL = C7_FILIAL " + CRLF
	cQuery += "        AND SCH.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "		LEFT JOIN " + RetSqlTab("ZZC") + CRLF
	cQuery += "		    ON  ZZC.ZZC_FILCLI     = D1_FILIAL" + CRLF
	cQuery += "		    AND ZZC.ZZC_CCUSTO = CH_CC" + CRLF
	cQuery += "		    AND ZZC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		LEFT JOIN " + RetSqlName("ZZC") + " ZZC_1 " + CRLF
	cQuery += "		    ON  ZZC_1.ZZC_FILCLI     = D1_FILIAL " + CRLF
	cQuery += "		    AND ZZC_1.ZZC_CCUSTO = C7_CC " + CRLF
	cQuery += "		    AND ZZC_1.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "    WHERE 1=1" + CRLF
	cQuery += "        AND ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE) <> ' ' " + CRLF
	cQuery += "        AND E5_ZZINTCO <> 'S' " + CRLF
	cQuery += "        AND C7_ZZCCOUP <> ' ' " + CRLF
	cQuery += "   GROUP BY E2_FILIAL,E2_PARCELA, E2_TIPO, E5_SEQ, F1_DOC, F1_SERIE, C7_FORNECE, C7_LOJA, F1_VALBRUT, ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE), A2_NOME, " + CRLF
	cQuery += "         E2_BAIXA, E5_DTCANBX, E5_DATA, E5_NUMERO, E5_MOTBX, E2_BAIXA, E2_SALDO, E5_TIPODOC, E5_RECPAG, E5_DTCANBX "

	TcQuery cQuery New Alias &cAlias
	count to nQtdTotal
	(cAlias)->(DbGoTop())

	geraLog("Resulta da consulta 'fornecedores pagos no último período': " + cValToChar(nQtdTotal))
	geraLog("Query: " + changequery(cQuery) )

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	cAdress   := (cAlias)->LE

	AddArrayRegs(cAlias)

Return

//Seleciona quando há exclusão de baixa
Static Function SelecDeletados()
	local cQuery    := ""
	local cAlias    := GetNextAlias()
	local nQtdTotal := 0

	cQuery += "Select MAX(E2_VENCREA) AS MAXPARCELA, E2_FILIAL,E2_PARCELA, E2_TIPO, E5_SEQ, F1_DOC, F1_SERIE, C7_FORNECE, C7_LOJA," + CRLF
	cQuery += " ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE) LE, F1_VALBRUT, A2_NOME,E2_BAIXA,E5_DTCANBX, E5_DATA, E5_NUMERO, E5_MOTBX, E2_BAIXA, E2_SALDO, E5_TIPODOC, E5_RECPAG, E5_DTCANBX " + CRLF
	cQuery += " FROM " + RetSqlTab("SE5") + CRLF
	cQuery += "	INNER JOIN " +  RetSqlTab("SE2") + CRLF
	cQuery += "  ON E2_FILIAL = E5_FILIAL " + CRLF
	cQuery += "     AND E5_NUMERO = E2_NUM " + CRLF
	cQuery += "     AND E5_LOTE = E2_LOTE " + CRLF
	cQuery += "     AND E5_PREFIXO = E2_PREFIXO " + CRLF
	cQuery += "     AND E5_PARCELA = E2_PARCELA " + CRLF
	cQuery += "     AND E5_TIPO = E2_TIPO " + CRLF
	cQuery += "     AND E5_CLIFOR = E2_FORNECE " + CRLF
	cQuery += "     AND E5_LOJA = E2_LOJA " + CRLF
	cQuery += " INNER JOIN " + RetSqlTab("SF1") + CRLF
	cQuery += "    ON E2_NUM = F1_DOC" + CRLF
	cQuery += "        AND E2_PREFIXO = F1_SERIE" + CRLF
	cQuery += "        AND E2_FILIAL = F1_FILIAL" + CRLF
	cQuery += "        AND E2_FORNECE = F1_FORNECE" + CRLF
	cQuery += "        AND E2_LOJA = F1_LOJA " + CRLF
	cQuery += "        AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlTab("SD1") + CRLF
	cQuery += "    ON  D1_DOC = F1_DOC " + CRLF
	cQuery += "        AND D1_SERIE = F1_SERIE " + CRLF
	cQuery += "        AND D1_FORNECE = F1_FORNECE " + CRLF
	cQuery += "        AND D1_LOJA = F1_LOJA " + CRLF
	cQuery += "        AND D1_FILIAL = F1_FILIAL " + CRLF
	cQuery += "        AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlTab("SA2") + CRLF
	cQuery += "    ON A2_COD = D1_FORNECE " + CRLF
	cQuery += "        AND A2_LOJA = D1_LOJA " + CRLF
	cQuery += "        AND SA2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlTab("SC7") + CRLF
	cQuery += "    ON  D1_FORNECE = C7_FORNECE " + CRLF
	cQuery += "        AND D1_PEDIDO = C7_NUM " + CRLF
	cQuery += "        AND D1_FILIAL = C7_FILIAL " + CRLF
	cQuery += "        AND D1_COD = C7_PRODUTO " + CRLF
	cQuery += "        AND D1_ITEMPC = C7_ITEM " + CRLF
	cQuery += "        AND C7_ZZINTCO = 'S' " + CRLF
	cQuery += "        AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlTab("SCH") + CRLF
	cQuery += "    ON  CH_FORNECE = C7_FORNECE " + CRLF
	cQuery += "        AND CH_LOJA = C7_LOJA " + CRLF
	cQuery += "        AND CH_PEDIDO = C7_NUM " + CRLF
	cQuery += "        AND CH_ITEMPD = C7_ITEM " + CRLF
	cQuery += "        AND CH_FILIAL = C7_FILIAL " + CRLF
	cQuery += "        AND SCH.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "		LEFT JOIN " + RetSqlTab("ZZC") + CRLF
	cQuery += "		    ON  ZZC.ZZC_FILCLI     = D1_FILIAL" + CRLF
	cQuery += "		    AND ZZC.ZZC_CCUSTO = CH_CC" + CRLF
	cQuery += "		    AND ZZC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		LEFT JOIN " + RetSqlName("ZZC") + " ZZC_1 " + CRLF
	cQuery += "		    ON  ZZC_1.ZZC_FILCLI     = D1_FILIAL " + CRLF
	cQuery += "		    AND ZZC_1.ZZC_CCUSTO = D1_CC " + CRLF
	cQuery += "		    AND ZZC_1.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "    WHERE 1=1" + CRLF
	//cQuery += "        AND ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE) <> ' ' " + CRLF
	cQuery += "        AND E5_ZZINTCO = 'S' " + CRLF
	cQuery += "        AND E5_ZZINTDE <> 'S' " + CRLF
	cQuery += "        AND C7_ZZCCOUP <> ' ' " + CRLF
	cQuery += "        AND SE5.D_E_L_E_T_ = '*' " + CRLF
	cQuery += "   GROUP BY E2_FILIAL,E2_PARCELA, E2_TIPO, E5_SEQ, F1_DOC, F1_SERIE, C7_FORNECE, C7_LOJA, F1_VALBRUT, ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE), A2_NOME, " + CRLF
	cQuery += "         E2_BAIXA, E5_DTCANBX, E5_DATA, E5_NUMERO, E5_MOTBX, E2_BAIXA, E2_SALDO, E5_TIPODOC, E5_RECPAG, E5_DTCANBX "

	TcQuery cQuery New Alias &cAlias
	count to nQtdTotal
	(cAlias)->(DbGoTop())

	geraLog("Resulta da consulta 'exclusão de baixa': " + cValToChar(nQtdTotal))
	geraLog("Query: " + changequery(cQuery) )

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	AddArrayRegs(cAlias)

Return

//Adiciona Registros não deletados
Static Function AddArrayRegs(cAlias2)

	local cStatus  := ""
	local cDtBaixa := ""

	While (cAlias2)->(!EoF())
		cStatus := RetStatus((cAlias2)->E5_RECPAG,(cAlias2)->E2_SALDO,(cAlias2)->E5_DTCANBX)
		Iif(Empty((cAlias2)->E2_BAIXA),cDtBaixa := "",;
			cDtBaixa := SubStr((cAlias2)->E2_BAIXA,1,4) + "-" + SubStr((cAlias2)->E2_BAIXA,5,2)+ "-"+ SubStr((cAlias2)->E2_BAIXA,7,2))

		geraLog("Gerando linha da NF/Serie:" + (cAlias2)->F1_DOC + "/" + (cAlias2)->F1_SERIE )
		geraLog("Titulo Prefixo/Numero/Parcela: " + (cAlias2)->F1_SERIE + "/" + (cAlias2)->F1_DOC + "/" + (cAlias2)->E2_PARCELA )
		geraLog("Data Baixa: " + cDtBaixa)
		geraLog("Status: " + cStatus)

		aAdd(aRegs,{cAdress ,;
			AllTrim((cAlias2)->A2_NOME) ,;
			"BR-PR-" + (cAlias2)->C7_FORNECE + (cAlias2)->C7_LOJA ,;
			(cAlias2)->F1_DOC + (cAlias2)->F1_SERIE ,;
			cDtBaixa ,;
			cValToChar((cAlias2)->F1_VALBRUT) ,;
			SubStr((cAlias2)->MAXPARCELA,1,4) + "-" + SubStr((cAlias2)->MAXPARCELA,5,2)+ "-"+ SubStr((cAlias2)->MAXPARCELA,7,2)})

		cFilAnt	:= (cAlias2)->E2_FILIAL
		GravaSE5((cAlias2)->E2_FILIAL,(cAlias2)->F1_SERIE,(cAlias2)->F1_DOC,(cAlias2)->E2_PARCELA,(cAlias2)->E2_TIPO,(cAlias2)->C7_FORNECE,;
			(cAlias2)->C7_LOJA,(cAlias2)->E5_SEQ,(cAlias2)->E5_TIPODOC,(cAlias2)->E5_DATA)

		geraLog("")
		(cAlias2)->(DbSkip())
	EndDo

	(cAlias2)->(DbCloseArea())

Return

//Escreve linhas no csv
Static Function CompLinhas(oFile)
	local nX := 1

	For nX := 1 to Len(aRegs)
		oFile:INCLINHA(aRegs[nX,ADRESS] + ",";
			+ aRegs[nX,NOME] + ",";
			+ aRegs[nX,FORNECE] + ",";
			+ aRegs[nX,DOC] + ",";
			+ ",";
			+ "Yes,";
			+ aRegs[nX,BAIXA] + ",";
			+ ",";
			+ aRegs[nX,VALBRUT] + ",";
			+ ",";
			+ aRegs[nX,PARCELA])
	Next nX

Return

Static Function RetStatus(cRecPag,nSaldo,dDtCanc)

	local cRetorno := ""

	If cRecPag == 'P' .AND. nSaldo == 0 .AND. AllTrim(dDtCanc) == ""
		cRetorno    := "created"
		lCancel     := .F.
	else
		cRetorno := "cancelled"
		lCancel     := .T.
	endIf

Return cRetorno

//Grava flag SE2
Static Function GravaSE5(cFilProtheus,cPrefixo,cDoc,cParcela,cTipo,cFornece,cLoja,cSeq,cTipoDoc,cDataSE5)

	local nI                := 0
	local nRecnoSE5         := 0
	local aArea             := SE5->(GetArea())
	local cChaveSeek        := cFilProtheus+cTipoDoc+cPrefixo+cDoc+cParcela+cTipo+cDataSE5+cFornece+cLoja+cSeq
	local aRecnoSE5         := retRecnoSE5(cFilProtheus,cTipoDoc,cPrefixo,cDoc,cParcela,cTipo,cDataSE5,cFornece,cLoja,cSeq)

	geraLog("Gravando flag na SE5...")

	DbSelectArea("SE5")
	DbSetOrder(2) //E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ

	If Len(aRecnoSE5) > 0
		for nI := 1 to len(aRecnoSE5)
			nRecnoSE5       := aRecnoSE5[nI]
			SE5->(DbGoTo( nRecnoSE5 ))
			if SE5->E5_ZZINTCO == "S"
				RecLock("SE5",.F.)
				SE5->E5_ZZINTCO     := "S"
				SE5->E5_ZZINTDE     := "S"
				SE5->(MsUnlock())
			else
				RecLock("SE5",.F.)
				SE5->E5_ZZINTCO     := "S"
				SE5->(MsUnlock())
			endIf
			geraLog("Gravando recno " + cValToChar(nRecnoSE5) + " como enviado.")
		next
	Else
		geraLog("ERRO - Nao localizou DbSeek SE5 para gravar dados como 'ja enviado'")
		geraLog("SE5 DbSeek: " + cChaveSeek )
	EndIf

	RestArea(aArea)

Return

//-----------------------------------------------------------------
static function retRecnoSE5(cFilProtheus,cTipoDoc,cPrefixo,cDoc,cParcela,cTipo,cDataSE5,cFornece,cLoja,cSeq)

	local cQuery    := ""
	local cAlias    := getnextalias()
	local aRet      := {}

	cQuery      += "SELECT " + CRLF
	cQuery      += "    DISTINCT SE5.R_E_C_N_O_ REC_SE5 " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("SE5") + CRLF
	cQuery      += "WHERE 1=1" + CRLF
	cQuery      += "    AND E5_FILIAL = '" + cFilProtheus + "' " + CRLF
	cQuery      += "    AND E5_TIPODOC = '" + cTipoDoc + "' " + CRLF
	cQuery      += "    AND E5_PREFIXO = '" + cPrefixo + "' " + CRLF
	cQuery      += "    AND E5_NUMERO = '" + cDoc + "' " + CRLF
	cQuery      += "    AND E5_PARCELA = '" + cParcela + "' " + CRLF
	cQuery      += "    AND E5_TIPO = '" + cTipo + "' " + CRLF
	cQuery      += "    AND E5_DATA = '" + cDataSE5 + "' " + CRLF
	cQuery      += "    AND E5_CLIFOR = '" + cFornece + "' " + CRLF
	//cQuery      += "    AND E5_LOJA = '" + cLoja + "' " + CRLF
	cQuery      += "    AND E5_SEQ = '" + cSeq + "' " + CRLF
	cQuery      += "" + CRLF

	geraLog("Query RECNO: " + changequery(cQuery))

	TcQuery cQuery new Alias &cAlias

	While (cAlias)->(!Eof())
		aAdd( aRet , (cAlias)->REC_SE5 )
		(cAlias)->(DbSkip())
	endDo

	(cAlias)->(DbCloseArea())

return aRet

//Grava tabela de logs
Static Function GravaZZD(cDir,cArq,cNota)

	local oLibCoupa

	oLibCoupa	:= LibCoupa():New()
	oLibCoupa:setTipo("PAYMENT")
	oLibCoupa:setChave(cArq)

	oLibCoupa:setArquivo(cDir+cArq)
	oLibCoupa:setNF(cNota)
	oLibCoupa:setPedido("")
	oLibCoupa:setIsErro(.F.)
	oLibCoupa:setOcorrencia("INCLUIDO COM SUCESSO")
	oLibCoupa:setPro2COupa(.T.)

	If lCancel
		oLibCoupa:setOperacao("EXCLUSAO")
	Else
		oLibCoupa:setOperacao("INCLUSAO")
	EndIf
	oLibCoupa:gravaZZD()

Return

//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

	Conout("[" + DTOC(Date()) + " " + Time() + "] PAYMENTSINVOICE - " + cMensagem )

Return
