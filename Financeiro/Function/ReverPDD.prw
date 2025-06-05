#include 'totvs.ch'
#include 'topconn.ch'

User Function reverpdd()

	local aArea			:= GetArea()
	local aTreeProc := {}
	local cTitle       := "Processamento Reversão PDD"
	local bProcess     := { |oSelf| GeraCTBRev(oSelf) }
	local cDescription := ""
	local cPerg        := ''
	private cFunction	:= Substr(FunName(),1,8)

	cDescription := "Este programa tem como objetivo gerar lançamentos contábeis de reversão das provisões para cobrança duvidosa" + CRLF +;
		""

	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,aTreeProc,.T.,3,'',.T. )


	RestArea(aArea)

Return
// ----------------------------------------------------------------------------------------------------------------------------------------------------------

static function GeraCTBRev(oSelf)

	local nLinha     := 0
	local lDigita    := .T.
	local lAglut     := .F.
	local nTotProc   := 0
	local nTotDoc    := 0
	local aArea      := GetArea()
	local nFilAtu    := 0
	local cEmpBkp    := cEmpAnt
	local cFilBkp    := cFilAnt
	local cNumEmpBkp := cNumEmp
	local aFiliais   := {}
	private cLote    := LoteCont("FIN")

	private cArquivo := ''
	private _nHdlPrv := 0
	private lUsaFlag := GetNewPar("MV_CTBFLAG",.F.)
	private nTotal   := 0
	private aDiario  := {}
	private aFlagCTB := {}
	private lSeqCorr := FindFunction( "UsaSeqCor" ) .And. UsaSeqCor("SE1/SE2/SE5/SEH/SEK/SEL/SET/SEU")
	private cPadrao  := 'Z01'
	private cZDC     := ''
	private cZCCC    := ''
	private cZCCD    := ''
	private cZCtaDeb := ''
	private cZCtaCrd := ''
	private nZValorD := 0
	private nZValorC := 0
	private cZHist   := ''
	private lCriar   := .F.

	aRetInfo         :={'FLAG', 'SM0_CODFIL', 'SM0_EMPRESA', 'SM0_FILIAL'}
	lCheckUser       := .F.
	lAllEmp          := .T.
	lOnlySelect      := .T.
	aFiliais         := FwListBranches( lCheckUser , lAllEmp , lOnlySelect , aRetInfo )


	Begin Transaction
		For nFilAtu := 1 To Len(aFiliais)
			If aFiliais[nFilAtu][1]
				cEmpFil   := aFiliais[nFilAtu][2] //padrão EEFF
				aDiario   := {}
				lOnline   := .F.
				aFlagCTB  := {}
				aProvisao := {}
				CursorWait()
				cEmpAnt := '01'//SubStr(cEmpFil,1,2)
				cFilAnt := alltrim(cEmpFil)
				cNumEmp := alltrim(cEmpAnt + cFilAnt)
				DbCloseAll()
				OpenFile(cNumEmp)
				ResetModulo( {"SIGAFIN",6} )
				CursorArrow()


				If Select("TRX") > 0
					dbSelectArea("TRX")
					TRX->(dbCloseArea())
				EndIf

				cQuery := " SELECT FIA.R_E_C_N_O_ AS RECFIA FROM " + RetSqlName("FIA") + " FIA with(nolock)
				cQuery += " WHERE FIA.D_E_L_E_T_ = '' AND FIA_LA = 'S' AND FIA_FILIAL = '" + FWxFilial("FIA") + "'
				TcQuery cQuery New Alias "TRX"


				dbSelectArea("TRX")
				TRX->(dbGoTop())
				If TRX->(!Eof())

					oSelf:Savelog("Processamento iniciado.")
					oSelf:SetRegua1(2)
					oSelf:IncRegua1()
					oSelf:SetRegua2(3)
					oSelf:IncRegua2()

					lCriar		:= If(lCriar == NIL,.F.,lCriar)
					nHdlPrv	:= HeadProva(cLote,cFunction,Substr(cUsuario,7,6),@cArquivo,lCriar)

					lPadrao	:=	VerPadrao(cPadrao)

					IF !lPadrao
						RETURN(ALERT("ERRO LP Z01"))
					EndIf
					nReg := 0
					while TRX->(!eof())
						nLinha += 1
						dbSelectArea("FIA")
						FIA->(dbGoTo(TRX->RECFIA))

						cZDC 		:= '3' //partida dobrada
						cZCCC		:= '21101'
						cZCCD		:= ''
						cZCtaDeb 	:= '11206001'
						cZCtaCrd	:= '42202001'
						nZValor	    := FIA->FIA_VALOR
						cZHist		:= substr('REVERSAO PCLD ' + Substr(dtos(dDataBase),5,2) + '-' + Substr(dtos(dDataBase),1,4) + FIA->(FIA_PREFIX + ' ' + FIA_NUM + ' ' + FIA_PARCEL + ' ' + FIA_TIPO),1,40)
						cZOrigCtb	:= substr('REVERSAO PCLD ' + Substr(dtos(dDataBase),5,2) + '-' + Substr(dtos(dDataBase),1,4) + FIA->(FIA_PREFIX + ' ' + FIA_NUM + ' ' + FIA_PARCEL + ' ' + FIA_TIPO),1,40)
						cPadrao		:= 'Z01'

						nReg += 1
						If lUsaFlag
							aAdd(aFlagCTB,{"FIA_LA","X","FIA",FIA->(Recno()),0,0,0})
						EndIf

						nTotDoc	:= DetProva(nHdlPrv,cPadrao,cFunction,cLote,,,,,,,,@aFlagCTB,,)

						nTotal		+= nTotDoc
						nTotProc	+= nTotDoc //Totaliza por processo - Caso queira começar a contabilizar o processo

						If nTotDoc > 0
							// aDiario := {{"SE2",SE2->(recno()),SE2->E2_DIACTB,"E2_NODIA","E2_DIACTB"}}
							aadd(aDiario,{"FIA",FIA->(RECNO()),FIA->FIA_DIACTB,"FIA_NODIA","FIA_DIACTB"})
						EndIf


						TRX->(dbSkip())
					EndDo
					oSelf:IncRegua2()
					oSelf:Savelog("Calculadas "+alltrim(Str(nReg)) + "Reversao de Provisoes. Gerando Movimentos ...")
					oSelf:IncRegua1()

					//Grava Rodap
					If nHdlPrv > 0
						RodaProva(nHdlPrv, nTotal)
						//Envia para lancamento Contabil
						cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut,,,,@aFlagCTB,,aDiario)
						nHdlPrv := 0
					Endif

					aFlagCTB 	:= {}
					aDiario	:= {}

				EndIf


				oSelf:IncRegua2()
				oSelf:Savelog("Excluindo registros de provisoes PDD ...")

				nTcSql := 0
				cQuery := " DELETE
				cQuery += " FROM " + RetSqlName("FIA") + " WHERE FIA_LA = 'X' AND FIA_FILIAL = '" + FWxFilial("FIA") + "'
				Processa({|| nTcSql := TcSQLExec(cQuery)})

				If nTcSql < 0
					Help(" ",1,"REVERPDD",, "Não foi possivel excluir os registros da tabela FIA, favor verificar o seu ambiente Protheus." ,1,0)
					DisarmTransaction()
				EndIf
			EndIf
		Next
	End Transaction
	oSelf:Savelog("Processamento finalizado.")

	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cNumEmp := cNumEmpBkp

	DbCloseAll()
	OpenFile(cNumEmp)
	ResetModulo( {"SIGAFIN",6} )


	RestArea(aArea)

Return


// ----------------------------------------------------------------------------------------------------------------------------------------------------------

User Function Estpcd()

	local aArea			:= GetArea()
	local aTreeProc := {}
	local cTitle       := "Processamento Estorno PDD"
	local bProcess     := { |oSelf| ProcEPCD(oSelf) }
	local cDescription := ""
	local cPerg        := ''
	private cFunction	:= Substr(FunName(),1,8)

	cDescription := "Este programa tem como objetivo gerar lançamentos contábeis de estorno das provisões para cobrança duvidosa" + CRLF +;
		"Debito : 11206001  - (-) PROVISAO P/ CREDITOS LIQ DUVIDOSA   " + CRLF +;
		"Credito : 42202001 - PROVISAO P/ CREDITOS LIQ. DUVIDOSA      "

	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,aTreeProc,.T.,3,'',.T. )


	RestArea(aArea)

Return

// ----------------------------------------------------------------------------------------------------------------------------------------------------------

static function ProcEPCD(oSelf)

	local nLinha     := 0
	local lDigita    := .T.
	local lAglut     := .F.
	local nTotProc   := 0
	local nTotDoc    := 0
	local aArea      := GetArea()
	local nFilAtu    := 0
	local cEmpBkp    := cEmpAnt
	local cFilBkp    := cFilAnt
	local cNumEmpBkp := cNumEmp
	local aFiliais   := {}
	private cLote    := LoteCont("FIN")

	private cArquivo := ''
	private _nHdlPrv := 0
	private lUsaFlag := GetNewPar("MV_CTBFLAG",.F.)
	private nTotal   := 0
	private aDiario  := {}
	private aFlagCTB := {}
	private lSeqCorr := FindFunction( "UsaSeqCor" ) .And. UsaSeqCor("SE1/SE2/SE5/SEH/SEK/SEL/SET/SEU")
	private cPadrao  := 'Z01'
	private cZDC     := ''
	private cZCCC    := ''
	private cZCCD    := ''
	private cZCtaDeb := ''
	private cZCtaCrd := ''
	private nZValorD := 0
	private nZValorC := 0
	private cZHist   := ''
	private lCriar   := .F.

	aRetInfo         :={'FLAG', 'SM0_CODFIL', 'SM0_EMPRESA', 'SM0_FILIAL'}
	lCheckUser       := .F.
	lAllEmp          := .T.
	lOnlySelect      := .T.
	aFiliais         := FwListBranches( lCheckUser , lAllEmp , lOnlySelect , aRetInfo )


	Begin Transaction
		For nFilAtu := 1 To Len(aFiliais)
			If aFiliais[nFilAtu][1]
				cEmpFil   := aFiliais[nFilAtu][2] //padrão EEFF
				aDiario   := {}
				lOnline   := .F.
				aFlagCTB  := {}
				aProvisao := {}
				CursorWait()
				cEmpAnt := '01'//SubStr(cEmpFil,1,2)
				cFilAnt := alltrim(cEmpFil)
				cNumEmp := alltrim(cEmpAnt + cFilAnt)
				DbCloseAll()
				OpenFile(cNumEmp)
				ResetModulo( {"SIGAFIN",6} )
				CursorArrow()


				If Select("TRX") > 0
					dbSelectArea("TRX")
					TRX->(dbCloseArea())
				EndIf

				cQuery := " SELECT FIA.R_E_C_N_O_ AS RECFIA FROM " + RetSqlName("FIA") + " FIA with(nolock)
				cQuery += " WHERE FIA.D_E_L_E_T_ = '' AND FIA_LA = 'S' AND FIA_FILIAL = '" + FWxFilial("FIA") + "'
				TcQuery cQuery New Alias "TRX"


				dbSelectArea("TRX")
				TRX->(dbGoTop())
				If TRX->(!Eof())

					oSelf:Savelog("Processamento iniciado.")
					oSelf:SetRegua1(2)
					oSelf:IncRegua1()
					oSelf:SetRegua2(3)
					oSelf:IncRegua2()

					lCriar		:= If(lCriar == NIL,.F.,lCriar)
					nHdlPrv	:= HeadProva(cLote,cFunction,Substr(cUsuario,7,6),@cArquivo,lCriar)

					lPadrao	:=	VerPadrao(cPadrao)

					IF !lPadrao
						RETURN(ALERT("ERRO LP Z01"))
					EndIf
					nReg := 0
					while TRX->(!eof())
						nLinha += 1
						dbSelectArea("FIA")
						FIA->(dbGoTo(TRX->RECFIA))

						cZDC 		:= '3' //partida dobrada
						cZCCC		:= '21101'
						cZCCD		:= ''
						cZCtaDeb 	:= '11206001'
						cZCtaCrd	:= '42202001'
						nZValor	    := FIA->FIA_VALOR
						cZHist		:= substr('ESTORNO PCLD ' + Substr(dtos(dDataBase),5,2) + '-' + Substr(dtos(dDataBase),1,4) + FIA->(FIA_PREFIX + ' ' + FIA_NUM + ' ' + FIA_PARCEL + ' ' + FIA_TIPO),1,40)
						cZOrigCtb	:= substr('ESTORNO PCLD ' + Substr(dtos(dDataBase),5,2) + '-' + Substr(dtos(dDataBase),1,4) + FIA->(FIA_PREFIX + ' ' + FIA_NUM + ' ' + FIA_PARCEL + ' ' + FIA_TIPO),1,40)
						cPadrao		:= 'Z01'

						nReg += 1
						If lUsaFlag
							aAdd(aFlagCTB,{"FIA_LA","X","FIA",FIA->(Recno()),0,0,0})
						EndIf

						nTotDoc	:= DetProva(nHdlPrv,cPadrao,cFunction,cLote,,,,,,,,@aFlagCTB,,)

						nTotal		+= nTotDoc
						nTotProc	+= nTotDoc //Totaliza por processo - Caso queira começar a contabilizar o processo

						If nTotDoc > 0
							// aDiario := {{"SE2",SE2->(recno()),SE2->E2_DIACTB,"E2_NODIA","E2_DIACTB"}}
							aadd(aDiario,{"FIA",FIA->(RECNO()),FIA->FIA_DIACTB,"FIA_NODIA","FIA_DIACTB"})
						EndIf


						TRX->(dbSkip())
					EndDo
					oSelf:IncRegua2()
					oSelf:Savelog("Calculadas "+alltrim(Str(nReg)) + "Reversao de Provisoes. Gerando Movimentos ...")
					oSelf:IncRegua1()

					//Grava Rodap
					If nHdlPrv > 0
						RodaProva(nHdlPrv, nTotal)
						//Envia para lancamento Contabil
						cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut,,,,@aFlagCTB,,aDiario)
						nHdlPrv := 0
					Endif

					aFlagCTB 	:= {}
					aDiario	:= {}

				EndIf


				oSelf:IncRegua2()
				oSelf:Savelog("Excluindo registros de provisoes PDD ...")

				nTcSql := 0
				cQuery := " DELETE
				cQuery += " FROM " + RetSqlName("FIA") + " WHERE FIA_LA = 'X' AND FIA_FILIAL = '" + FWxFilial("FIA") + "'
				Processa({|| nTcSql := TcSQLExec(cQuery)})

				If nTcSql < 0
					Help(" ",1,"REVERPDD",, "Não foi possivel excluir os registros da tabela FIA, favor verificar o seu ambiente Protheus." ,1,0)
					DisarmTransaction()
				EndIf
			EndIf
		Next
	End Transaction
	oSelf:Savelog("Processamento finalizado.")

	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cNumEmp := cNumEmpBkp

	DbCloseAll()
	OpenFile(cNumEmp)
	ResetModulo( {"SIGAFIN",6} )


	RestArea(aArea)

Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

user function RptPCD()

	local cTitle       := "Relatório PCD"
	local bProcess     := { |oSelf| Retpor(oSelf) }
	local cDescription := "Este programa tem como objetivo realizar a geração dos títulos provisionados de clientes duvidosos."
	local cPerg        := "EUROPCD003"
	private cFunction  := ""

	cFunction  := Substr(FunName(),1,8)
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )

Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

static function Retpor(op_Self)
	local cQuery   := ""
	local cArquivo := "c:\temp\PlanPCD_"+dTos(dDataBase)+".XML"
	local nRegs    := 0
	local cSheet   := "PCD - " + dTos(dDataBase)
	local cTitulo  := "Provisao Clientes Duvidosos"

	op_Self:SetRegua1(2)
	op_Self:SetRegua2(1)
	op_Self:IncRegua1("Leitura dos registros financeiro")

	cQuery := ""
	cQuery += " SELECT E1_FILIAL AS FILIAL
	cQuery += "      , A1_COD AS CODIGO
	cQuery += "      , A1_LOJA AS LOJA
	cQuery += "      , A1_CGC AS CNPJ
	cQuery += "      , A1_COD+'-'+A1_LOJA+'-'+LTRIM(RTRIM(A1_NOME)) AS CLIENTE
	cQuery += "      , A1_ZZCOLIG AS COLIGADO
	cQuery += "      , E1_PREFIXO + '-' + E1_NUM + '-' + E1_PARCELA as TITULO
	cQuery += "      , E1_EMISSAO as EMISSAO
	cQuery += "      , E1_VENCTO AS VENCTO
	cQuery += "      , E1_VENCREA AS VENCREA
	cQuery += "      , E1_VENCORI AS VENCORI
	cQuery += "      , LTRIM(RTRIM(E1_HIST)) AS HISTORICO
	cQuery += "      , A1_EMAIL as EMAIL
	cQuery += "      , DATEDIFF(DAY, CAST(E1_VENCREA AS smalldatetime), CAST( '" + dTos(MV_PAR03) + "' AS smalldatetime) ) AS ATRASO
	cQuery += "      , E1_PORTADO AS BCO
	cQuery += "      , E1_SITUACA AS ST
	cQuery += "      , E1_TIPO AS TP
	cQuery += "      , E1_NATUREZ AS NATUREZA
	cQuery += "      , E1_NUMBCO as NUM_BCO
	cQuery += "      , E1_VALJUR AS JUROS
	cQuery += "      , E1_IRRF AS IRRF
	cQuery += "      , E1_PIS AS PIS
	cQuery += "      , E1_COFINS AS COFINS
	cQuery += "      , E1_CSLL AS CSLL
	cQuery += "      , E1_VALOR AS VALOR
	cQuery += "      , E1_SALDO AS SALDO
	cQuery += "      , E1_SALDO - E1_IRRF AS VALOR_LIQ
	cQuery += "      , A1_CONTA AS CONTA_CLI
	cQuery += "      , E1_CONTA AS CONTA_BCO
	cQuery += "      , FIA_DTPROV as DT_PROVISAO
	cQuery += "      , FIA_VALOR AS VLR_PDD
	// cQuery += "      , round(CASE WHEN FIA_VALOR = 0 THEN 0 ELSE ( FIA_VALOR / (E1_SALDO-E1_IRRF) ) END,2) AS PERC_PDD
	cQuery += "      , SE1.R_E_C_N_O_ AS RECSE1 "
	cQuery += "  FROM " + RetSqlName("SE1") + " SE1 WITH(NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON A1_COD = E1_CLIENTE
	cQuery += "   AND A1_LOJA = E1_LOJA
	cQuery += "   AND SA1.D_E_L_E_T_ = ''
	cQuery += " INNER JOIN " + RetSqlName("SZM") + " SZM WITH(NOLOCK) ON ZM_FILEMP = SUBSTRING(E1_FILIAL,1,2)
	cQuery += "  LEFT JOIN " + RetSqlName("FIA") + " FIA WITH(NOLOCK) ON FIA_FILIAL = E1_FILIAL
	cQuery += "   AND FIA_PREFIX = E1_PREFIXO
	cQuery += "   AND FIA_NUM = E1_NUM
	cQuery += "   AND FIA_PARCEL = E1_PARCELA
	cQuery += "   AND FIA_TIPO = E1_TIPO
	cQuery += "   AND FIA_CLIENT = E1_CLIENTE
	cQuery += "   AND FIA_LOJA = E1_LOJA
	cQuery += "   AND FIA.D_E_L_E_T_ = ''
	cQuery += " WHERE E1_FILIAL >= '" + MV_PAR01 + "'
	cQuery += "   AND E1_FILIAL <= '" + MV_PAR02 + "'"
	cQuery += "   AND (E1_SALDO > 0 OR E1_BAIXA > '" + dTos(MV_PAR03) + "')
	cQuery += "   AND E1_EMISSAO >= '" + dTos(MV_PAR04) + "'
	cQuery += "   AND E1_EMISSAO <= '" + dTos(MV_PAR05) + "'
	cQuery += "   AND E1_VENCREA >= '" + dTos(MV_PAR06) + "'
	cQuery += "   AND E1_VENCREA <= '" + dTos(MV_PAR07) + "'
	cQuery += "   AND SE1.D_E_L_E_T_ = ''
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	Count to nRegs
	op_Self:SetRegua2(nRegs)
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())

		If file(cArquivo)
			FERASE(cArquivo)
		EndIf

		oFWMsExcel := FWMsExcelEx():New()

		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitulo)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"Filial"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Codigo"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Loja"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Nome Cliente"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"CNPJ"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Coligado"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"N. NF/Titulo"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Emissao"                 ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Vencimento"              ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Vencto Real"             ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Vencto Ori"              ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Historico Titulo"             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"E-Mail"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Dias Atraso"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Banco"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Sit. Cobrança"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tipo do Titulo"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Natureza"                     ,1,1)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"Num. Banco"                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Juros"                        ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"IRRF"                         ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PIS"                          ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Cofins"                       ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"CSLL"                         ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor Titulo"                 ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Saldo"                        ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor Liqui."                 ,1,2)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"Conta Cliente"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Provisao"                ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor PCD"                    ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"P% PCD"                       ,1,2)

		while (cTRB)->(!eof())

			op_Self:IncRegua2("Processando titulo " + (cTRB)->TITULO + "...")

			dbSelectArea("SE1")
			SE1->(dbgoTo((cTRB)->RECSE1))
			dDataReaj := dDataBase

			cFilSE5 := SE1->E1_FILIAL
			If SE1->E1_VENCREA < dDataBase .And. RecMoeda(SE1->E1_VENCREA,'1') > 0
				dDataReaj := SE1->E1_VENCREA
			EndIf

			nImpBaixado		:= 0
			// nImpBaixado		+= bscSaldo( "PIS", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )
			// nImpBaixado		+= bscSaldo( "COF", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )
			// nImpBaixado		+= bscSaldo( "CSL", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )

			nTaxaDia := Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA))

			nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, 1, dDataReaj,;
				MV_PAR03, SE1->E1_LOJA,	cFilSE5 , nTaxaDia, 0)

			nSaldo  := nSaldo - nImpBaixado
			nIrrf   := (cTRB)->IRRF
			nSaldo  -= nIrrf

			If nSaldo != 0 .and. alltrim(SE1->E1_TIPO) != 'IR-'
				oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->FILIAL,;
					(cTRB)->CODIGO,;
					(cTRB)->LOJA,;
					(cTRB)->CLIENTE,;
					(cTRB)->CNPJ,;
					(cTRB)->COLIGADO,;
					(cTRB)->TITULO,;
					sTod((cTRB)->EMISSAO),;
					sTod((cTRB)->VENCTO),;
					sTod((cTRB)->VENCREA),;
					sTod((cTRB)->VENCORI),;
					(cTRB)->HISTORICO,;
					(cTRB)->EMAIL,;
					(cTRB)->ATRASO,;
					(cTRB)->BCO,;
					(cTRB)->ST,;
					(cTRB)->TP,;
					(cTRB)->NATUREZA,;
					(cTRB)->NUM_BCO,;
					(cTRB)->JUROS,;
					(cTRB)->IRRF,;
					(cTRB)->PIS,;
					(cTRB)->COFINS,;
					(cTRB)->CSLL,;
					(cTRB)->VALOR,;
					nSaldo,;
					(cTRB)->VALOR_LIQ,;
					(cTRB)->CONTA_CLI,;
					sTod((cTRB)->DT_PROVISAO),;
					(cTRB)->VLR_PDD,;
					0 /*(cTRB)->PERC_PDD*/})
			EndIf

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

// ----------------------------------------------------------------------------------------------------------------------------------------------------------

static function retMoeda(cp_Moeda)
	local cRet := ""

	DO CASE
	CASE cp_Moeda == '1' .or. Empty(cp_Moeda)
		cRet := 'BRL'
	CASE cp_Moeda == '2' .or. cp_Moeda == '4'
		cRet := 'USD'
	CASE cp_Moeda == '5' .or. cp_Moeda == '6'
		cRet := 'EUR'
	CASE cp_Moeda == '7' .or. cp_Moeda == '8'
		cRet := 'CLP'
	CASE cp_Moeda == '9' .or. cp_Moeda == '10'
		cRet := 'GBP'
	CASE cp_Moeda == '11' .or. cp_Moeda == '12'
		cRet := 'SEK'
	CASE cp_Moeda == '13' .or. cp_Moeda == '14'
		cRet := 'CAD'
	CASE cp_Moeda == '15' .or. cp_Moeda == '16'
		cRet := 'NOK'
	CASE cp_Moeda == '17' .or. cp_Moeda == '18'
		cRet := 'CHF'
	CASE cp_Moeda == '19' .or. cp_Moeda == '20'
		cRet := 'DKK'
	CASE cp_Moeda == '21' .or. cp_Moeda == '22'
		cRet := 'NZD'
	CASE cp_Moeda == '23' .or. cp_Moeda == '24'
		cRet := 'ARS'
	CASE cp_Moeda == '25' .or. cp_Moeda == '26'
		cRet := 'AUD'
	OTHERWISE
		cRet := 'XXX'
	ENDCASE

return(cRet)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------!SECTION
static function bscSaldo(cTipo,nVlrAtu,cFilTit,cPrefTit,cNumTit,cCliTit,cLojTit)

	local nRet		:= 0
	local cQuery	:= ""
	local cAlias	:= GetNextAlias()

	cQuery		+= "SELECT " + CRLF
	cQuery		+= "	SUM(E1_VALOR) VALOR" + CRLF
	cQuery		+= "FROM " + CRLF
	cQuery		+= "	" + RetSqlTab("SE1") + CRLF
	cQuery		+= "WHERE " + CRLF
	cQuery		+= "	D_E_L_E_T_ = ' ' " + CRLF
	cQuery		+= "	AND E1_TIPO = '" + cTipo + "' " + CRLF
	cQuery		+= "	AND E1_FILIAL = '" + cFilTit + "' " + CRLF
	cQuery		+= "	AND E1_PREFIXO = '" + cPrefTit + "' " + CRLF
	cQuery		+= "	AND E1_NUM = '" + cNumTit + "' " + CRLF
	cQuery		+= "	AND E1_CLIENTE = '" + cCliTit + "' " + CRLF
	cQuery		+= "	AND E1_LOJA = '" + cLojTit + "' " + CRLF
	cQuery		+= "	AND E1_SALDO = '0' " + CRLF
	cQuery		+= "" + CRLF

	tcquery cQuery New Alias &cAlias

	if (cAlias)->(!Eof())
		if nVlrAtu == 0 .AND. (cAlias)->VALOR > 0
			nRet	:= (cAlias)->VALOR
		else
			nRet	:= nVlrAtu - (cAlias)->VALOR
		endif
	else
		nRet	:= nVlrAtu
	endif

	(cAlias)->(DbCloseArea())


return nRet
