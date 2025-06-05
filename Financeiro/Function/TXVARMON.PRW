#INCLUDE "PROTHEUS.CH"
#INCLUDE "XCTBA105.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE 'TOPCONN.CH'

User Function TxVarMon()

	Local cPerg:= "TXVARMON"
	Local lRet:= .T.

	//ROTINA SÓ PODE SER EXECUTADA NO ÚLTIMO DIA DO MÊS
	IF DTOS(ddatabase) <> DTOS(LastDate(ddatabase))
		FWAlertWarning("Rotina de Variação somente pode ser rodada com data base no último dia do mês ", "Validação Variação Monetária")
		Return
	Endif

	If !Pergunte(PADR(cPerg,10),.T.)
		Return
	Endif

	If MV_PAR01 == 2 .AND. MV_PAR04 == 0
		MsgAlert("Para opção de carteira a Receber, necessário preencher a taxa de variação do Contas a Receber.")
		Return
	Endif

	If MV_PAR01 == 1 .AND. MV_PAR03 == 0
		MsgAlert("Para opção de carteira a Pagar, necessário preencher a taxa de variação do Contas a Pagar.")
		Return
	Endif

	If MV_PAR01 == 3 .AND. (MV_PAR03 == 0 .OR. MV_PAR04 == 0)
		MsgAlert("Para opção de Ambos, necessário preencher tanto a taxa de variação no Contas a Pagar quanto no Contas a Receber.")
		Return
	Endif

	If MV_PAR01 == 2 .AND. (EMPTY(MV_PAR02) .OR. MV_PAR04 == 0 .OR. EMPTY(MV_PAR05) .OR. EMPTY(MV_PAR06))
		MsgAlert("Favor verificar os preenchimentos da taxa do Contas a Receber/Contabiliza Por/Considera PA/Moeda.")
		Return
	Endif

	If MV_PAR01 == 1 .AND. (EMPTY(MV_PAR02) .OR. MV_PAR03 == 0 .OR. EMPTY(MV_PAR05) .OR. EMPTY(MV_PAR06))
		MsgAlert("Favor verificar os preenchimentos da taxa do Contas a Pagar/Contabiliza Por/Considera PA/Moeda.")
		Return
	Endif

	If MV_PAR01 == 3 .AND. (EMPTY(MV_PAR02) .OR. MV_PAR03 == 0 .OR. MV_PAR04 == 0 .OR. EMPTY(MV_PAR05) .OR. EMPTY(MV_PAR06))
		MsgAlert("Favor verificar os preenchimentos da taxa do Contas a Pagar/Receber/Contabiliza Por/Considera PA/Moeda.")
		Return
	Endif

	If MV_PAR01 == 1 .AND. MV_PAR05 == 1
		MsgAlert("Carteira a Pagar não pode ser contabilizada por Cliente.")
		Return
	Endif

	If MV_PAR01 == 2 .AND. MV_PAR05 == 2
		MsgAlert("Carteira a Receber não pode ser contabilizada por Fornecedor.")
		Return
	Endif

	If MV_PAR01 == 1 .AND. MV_PAR04 <> 0
		MsgAlert("Carteira a Pagar não pode ser preenchido taxa do contas a receber.")
		Return
	Endif

	If MV_PAR01 == 2 .AND. MV_PAR03 <> 0
		MsgAlert("Carteira a Receber não pode ser preenchido taxa do contas a pagar.")
		Return
	Endif


	If lRet
		U_AltTxMon(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06)
	Endif

Return
//--------------------------------------------------------------------------------------------------------------------------------------------------------


User Function AltTxMon(_cCarteira, _cMoeda, _ctxPag, _cTxRec, _cCont, _cConsPa)
	Local cQuery:= ""
	//Local _cQuery:= ""
	Local LContabil:= .T.
	Local _cTxRecAnt:= 0
	Local _cTxPagAnt:= 0
	local aAreaSE1:= GetArea()
	Local lOk:= .T.

	// VALIDAÇÕES ANTES DE RODAR A ROTINA

	// CASO SEJA O ÚLTIMO DIA DO MÊS RODAR A REVERSÃO DOS LANÇAMENTO DE VARIAÇÃO DE TODO O MÊS REALIZADAS

	_cFirstDate:= FirstDate(ddatabase)
	_cLastDate:= LastDate(ddatabase)
	_cNextDate:= DaySum(ddatabase,3)
	_cNextFirst:=FirstDate(DaySum(ddatabase,3))

	//CONFERE SE O CALENDÁRIO CONTÁBIL ESTÁ ABERTO NO MÊS ATUAL E NO PRÓXIMO MÊS
	_cQuery := " "
	_cQuery += " SELECT CTG_STATUS
	_cQuery += "  FROM "+RetSqlName("CTG")
	_cQuery += " WHERE "+RetSqlName("CTG")+".D_E_L_E_T_ <> '*'
	_cQuery += "  AND SUBSTRING(CTG_DTINI,1,6) = '"+SUBS(DTOS(_cLastDate),1,6)+"'"
	_cQuery += " AND CTG_FILIAL = '"+FwxFilial("CTG")+"' "
	_cQuery += " UNION ALL "
	_cQuery += " SELECT CTG_STATUS
	_cQuery += "  FROM "+RetSqlName("CTG")
	_cQuery += " WHERE "+RetSqlName("CTG")+".D_E_L_E_T_ <> '*'
	_cQuery += "  AND SUBSTRING(CTG_DTINI,1,6) = '"+SUBS(DTOS(_cNextDate),1,6)+"'"
	_cQuery += " AND CTG_FILIAL = '"+FwxFilial("CTG")+"' "
	TcQuery _cQuery New Alias(cCTG := GetNextAlias())

	While (cCTG)->(!Eof())
		If (cCTG)->CTG_STATUS <> "1"
			lOk:= .F.
		EndIf
		(cCTG)->(DbSkip())
	EndDo

	DbSelectArea((cCTG))
	(cCTG)->(DbCloseArea())

	IF !lOk
		FWAlertWarning("Rotina não pode ser executada pois um dos calendários, seja ele do mês atual ou próximo mês, está bloqueado. Favor, revisar", "Validação Contabilização Reversão")
		Return
	Endif

	//CONFERE SE OS LANÇAMENTOS PADRÕES ESTÃO CRIADOS
	_cQuery := " "
	_cQuery += " SELECT COUNT(*) AS REG "
	_cQuery += " FROM "+RetSqlName("CT5")+" "
	_cQuery += " WHERE "+RetSqlName("CT5")+".D_E_L_E_T_ = '' "
	_cQuery += " AND CT5_LANPAD IN ('VM1', 'VM2', 'VM3', 'VM4')
	_cQuery += " AND CT5_STATUS = '1'
	TcQuery _cQuery New Alias(cCT5 := GetNextAlias())

	While (cCT5)->(!Eof())
		If (cCT5)->REG < 4
			lOk:= .F.
		EndIf
		(cCT5)->(DbSkip())
	EndDo

	DbSelectArea((cCT5))
	(cCT5)->(DbCloseArea())

	IF !lOk
		FWAlertWarning("Rotina não pode ser executada pois alguns dos lançamentos padrões não está criado ou está bloqueado. Revisar os seguintes LPs: VM1/VM2/VM3/VM4", "Validação LPs Variação")
		Return
	Endif

	//CONFERE SE A TABELA ZVM ESTÁ CRIADA NO PROTHEUS
	IF  Empty(RetSqlName("ZVM"))
		FWAlertWarning("Rotina não pode ser executada pois a tabela ZVM não está criada nesse ambiente. Favor, revisar", "Validação Tabelas Variação")
		Return
	Endif


	IF _cCarteira == 2 .OR. _cCarteira == 3
		cQuery:= " "
		cQuery+= " SELECT E1_FILIAL "
		cQuery+= " , E1_PREFIXO "
		cQuery+= " , E1_NUM "
		cQuery+= " , E1_PARCELA "
		cQuery+= " , E1_TIPO "
		cQuery+= " , E1_CLIENTE "
		cQuery+= " , E1_LOJA "
		cQuery+= " , E1_MOEDA "
		cQuery+= " , E1_EMISSAO "
		cQuery+= " , E1_VALOR "
		cQuery+= " , E1_VLCRUZ "
		cQuery+= " , E1_VLCRUZ/E1_SALDO AS E1_TXMOEDA "
		cQuery+= " , 'RECEBER' AS ORIGEM "
		cQuery+= " , E1_VENCREA "
		cQuery+= " , E1_VALLIQ "
		cQuery+= " , E1_SALDO "
		cQuery+= " , SE1010.R_E_C_N_O_ RECNOE1"
		cQuery+= " FROM "+RetSqlName("SE1")+""
		cQuery+= " WHERE "+RetSqlName("SE1")+".D_E_L_E_T_ = '' "
		cQuery+= " AND E1_SALDO <> 0"
		//cQuery+= " AND E1_FILIAL = '"+FwxFilial("SE1")+"' "
		cQuery+= " AND E1_EMISSAO <= '" + DTOS(dDataBase)+ "' "
		cQuery+= " AND E1_MOEDA = '"+cValTochar(_cMoeda)+"' "
		If _cConsPa == 2
			cQuery+= " AND E1_TIPO NOT IN " + FORMATIN(MVPROVIS+"|"+MVABATIM+"|"+MVRECANT,"|")"
		Else
			cQuery+= " AND E1_TIPO NOT IN " + FORMATIN(MVPROVIS+"|"+MVABATIM+"|"+MVRECANT,"|")"
		Endif
		TcQuery cQuery New Alias(cSE1 := GetNextAlias())

		If (cSE1)->(!Eof())
			While (cSE1)->(!Eof()) //.and. (cSE1)->E1_FILIAL == FwxFilial("SE1")
				DbSelectArea("SE1")
				DbSetorder(1)
				If DbSeek(FwxFilial("SE1")+(cSE1)->E1_PREFIXO+(cSE1)->E1_NUM+(cSE1)->E1_PARCELA+(cSE1)->E1_TIPO)
					_cTxRecAnt:= SE1->E1_XTMDCOR
					Reclock("SE1" , .F.)
					SE1->E1_XTMDCOR:= _ctxRec
					MsUnlock()

					DbSelectArea("ZVM")
					dbSetOrder(1)
					RecLock("ZVM",.T.)
					IF _cTxRecAnt <> 0
						_cVarTx:= (_ctxRec*(cSE1)->E1_SALDO) - (_cTxRecAnt*(cSE1)->E1_SALDO)
					ELSE
						_cVarTx:= (_ctxRec*(cSE1)->E1_SALDO) - ((cSE1)->E1_TXMOEDA*(cSE1)->E1_SALDO)
					ENDIF
					//_cDifTx:= _cVarTx - _cSE1Variacao
					IF _cVarTx < 0
						//_cDifTxNv:= _cVarTx*(-1)
						_cTpVar:= "NEGATIVA"
					else
						//_cDifTxNv:=_cVarTx
						_cTpVar := "POSITIVA"
					Endif
					ZVM_FILIAL:= FwxFilial("ZVM")
					ZVM_PREFIX:= (cSE1)->E1_PREFIXO
					ZVM_NUM:= (cSE1)->E1_NUM
					ZVM_PARCEL:= (cSE1)->E1_PARCELA
					ZVM_TIPO:= (cSE1)->E1_TIPO
					ZVM_CLIFOR:= (cSE1)->E1_CLIENTE
					ZVM_LOJA:= (cSE1)->E1_LOJA
					ZVM_ORIGEM:= (cSE1)->ORIGEM
					ZVM_EMISSA:= STOD((cSE1)->E1_EMISSAO)
					ZVM_VENCRE:= STOD((cSE1)->E1_VENCREA)
					ZVM_VALLIQ:= (cSE1)->E1_VALLIQ
					ZVM_VALOR:= _cVarTx
					ZVM_SALDO:= (cSE1)->E1_SALDO
					ZVM_VLCRUZ:= (cSE1)->E1_VLCRUZ
					ZVM_MOEDA:= _cMoeda
					ZVM_DTVAR:= Date()
					ZVM_TXFISC:= _ctxRec
					ZVM_USER:= ALLTRIM(cUserName)
					ZVM_HORA:= TIME()
					ZVM_TPVAR:= _cTpVar
					ZVM_LA:= ""
					ZVM_REVLA:= ""
					ZVM_DTBASE:= ddatabase
					MsUnlock()
				Endif
				(cSE1)->(dbSkip())
			EndDo
		ELSE
			DbSelectArea((cSE1))
			(cSE1)->(DbCloseArea())
			FWAlertWarning("Não há títulos para os parâmetros informados.", "Validação Títulos Variação")
			Return
		Endif
		DbSelectArea((cSE1))
		(cSE1)->(DbCloseArea())
		RestArea(aAreaSE1)
	ENDIF

	IF _cCarteira == 1 .OR. _cCarteira == 3
		cQuery:= " "
		cQuery+= " SELECT E2_FILIAL "
		cQuery+= " , E2_PREFIXO "
		cQuery+= " , E2_NUM "
		cQuery+= " , E2_PARCELA "
		cQuery+= " , E2_TIPO "
		cQuery+= " , E2_FORNECE "
		cQuery+= " , E2_LOJA "
		cQuery+= " , E2_MOEDA "
		cQuery+= " , E2_EMISSAO "
		cQuery+= " , E2_VALOR "
		cQuery+= " , E2_VLCRUZ "
		cQuery+= " , E2_VLCRUZ/E2_SALDO AS E2_TXMOEDA "
		cQuery+= " , 'PAGAR' AS ORIGEM "
		cQuery+= " , E2_VENCREA "
		cQuery+= " , E2_VALLIQ "
		cQuery+= " , E2_SALDO "
		cQuery+= " , SE2010.R_E_C_N_O_ RECNOE2"
		cQuery+= " FROM "+RetSqlName("SE2")+""
		cQuery+= " WHERE "+RetSqlName("SE2")+".D_E_L_E_T_ = '' "
		cQuery+= " AND E2_SALDO <> 0"
		//cQuery+= " AND E2_FILIAL = '"+FwxFilial("SE2")+"' "
		cQuery+= " AND E2_EMISSAO <= '" + DTOS(dDataBase)+ "' "
		cQuery+= " AND E2_MOEDA = '"+Alltrim(Str(_cMoeda))+"' "
		If _cConsPa == 2
			cQuery+= " AND E2_TIPO NOT IN " + FORMATIN(MVPROVIS+"|"+MVABATIM+"|"+MVPAGANT,"|")"
		Else
			cQuery+= " AND E2_TIPO NOT IN " + FORMATIN(MVPROVIS+"|"+MVABATIM,"|")"
		Endif
		TcQuery cQuery New Alias(cSE2 := GetNextAlias())

		IF (cSE2)->(!Eof())
			While (cSE2)->(!Eof()) //.and. (cSE2)->E2_FILIAL == FwxFilial("SE2")
				DbSelectArea("SE2")
				DbSetorder(1)
				If DbSeek(FwxFilial("SE2")+(cSE2)->E2_PREFIXO+(cSE2)->E2_NUM+(cSE2)->E2_PARCELA+(cSE2)->E2_TIPO)
					Reclock("SE2" , .F.)
					_cTxPagAnt:=SE2->E2_XTMDCOR
					SE2->E2_XTMDCOR:= _ctxPag
					MsUnlock()

					DbSelectArea("ZVM")
					dbSetOrder(1)
					RecLock("ZVM",.T.)
					IF _cTxPagAnt <> 0
						_cVarTx:= (_ctxPag*(cSE2)->E2_SALDO) - (_cTxPagAnt*(cSE2)->E2_SALDO)
					ELSE
						_cVarTx:= (_ctxPag*(cSE2)->E2_SALDO) - ((cSE2)->E2_TXMOEDA*(cSE2)->E2_SALDO)
					ENDIF
					//_cDifTx:= _cVarTx - _cSE2Variacao
					IF _cVarTx < 0
						//_cDifTxNv:= _cVarTx*(-1)
						_cTpVar:= "NEGATIVA"
					else
						//_cDifTxNv:=_cVarTx
						_cTpVar := "POSITIVA"
					Endif
					ZVM_FILIAL:= FwxFilial("ZVM")
					ZVM_PREFIX:= (cSE2)->E2_PREFIXO
					ZVM_NUM:= (cSE2)->E2_NUM
					ZVM_PARCEL:= (cSE2)->E2_PARCELA
					ZVM_TIPO:= (cSE2)->E2_TIPO
					ZVM_CLIFOR:= (cSE2)->E2_FORNECE
					ZVM_LOJA:= (cSE2)->E2_LOJA
					ZVM_ORIGEM:= (cSE2)->ORIGEM
					ZVM_EMISSA:= STOD((cSE2)->E2_EMISSAO)
					ZVM_VENCRE:= STOD((cSE2)->E2_VENCREA)
					ZVM_VALLIQ:= (cSE2)->E2_VALLIQ
					ZVM_VALOR:= _cVarTx
					ZVM_SALDO:= (cSE2)->E2_SALDO
					ZVM_VLCRUZ:= (cSE2)->E2_VLCRUZ
					ZVM_MOEDA:= _cMoeda
					ZVM_DTVAR:= Date()
					ZVM_TXFISC:= _ctxPag
					ZVM_USER:= ALLTRIM(cUserName)
					ZVM_HORA:= TIME()
					ZVM_TPVAR:= _cTpVar
					ZVM_LA:= ""
					ZVM_REVLA:= ""
					ZVM_DTBASE:= ddatabase
					MsUnlock()
				Endif
				(cSE2)->(dbSkip())
			EndDo
		ELSE
			DbSelectArea((cSE2))
			(cSE2)->(DbCloseArea())
			FWAlertWarning("Não há títulos para os parâmetros informados.", "Validação Títulos Variação")
			Return
		EndIf
		DbSelectArea((cSE2))
		(cSE2)->(DbCloseArea())
	ENDIF

	If LContabil .AND. (_cCarteira == 1 .OR. _cCarteira == 3)
		//REALIZANDO CONTABILIZACAO DO PROCESSO - CONTAS A PAGAR
		If _cCont == 2
			cQuery:= ""
			cQuery+= " SELECT ZVM_CLIFOR+ZVM_LOJA AS CLIENTE "
			cQuery+= " , SUM(ZVM_VALOR) AS VALOR "
			cQuery+= " , (CASE WHEN SUM(ZVM_VALOR) < 0 "
			cQuery+= "         THEN 'NEGATIVA' "
			cQuery+= "         ELSE 'POSITIVA' "
			cQuery+= "         END) AS TPVAR "
			cQuery+= " , 'FOR' AS OPCAO "
			cQuery+= " , (SELECT DISTINCT A2_NREDUZ FROM "+RetSqlName("SA2")+" "
			cQuery+= " INNER JOIN "+RetSqlName("ZVM")+" ON "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			cQuery+= " WHERE "+RetSqlName("SA2")+".D_E_L_E_T_ = '' "
			cQuery+= "  AND A2_COD = ZVM_CLIFOR "
			cQuery+= " AND A2_LOJA = ZVM_LOJA) AS NOME "
			cQuery+= " , ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL AS TITULO "
			cQuery+= " FROM "+RetSqlName("ZVM")+" "
			cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			cQuery+= " AND ZVM_ORIGEM = 'PAGAR'
			cQuery+= " AND ZVM_LA <> 'S'
			//cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
			//cQuery+= " GROUP BY ZVM_CLIFOR+ZVM_LOJA
			cQuery+= " ORDER BY ZVM_CLIFOR, ZVM_LOJA ASC "
			TcQuery cQuery New Alias(cZVM := GetNextAlias())
		ELSEIF _cCont == 3
			cQuery:= ""
			cQuery+= " SELECT ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL AS TITULO "
			cQuery+= " , SUM(ZVM_VALOR) AS VALOR "
			cQuery+= " , (CASE WHEN SUM(ZVM_VALOR) < 0 "
			cQuery+= "         THEN 'NEGATIVA' "
			cQuery+= "         ELSE 'POSITIVA' "
			cQuery+= "         END) AS TPVAR "
			cQuery+= " , 'TIT' AS OPCAO "
			cQuery+= " , (SELECT DISTINCT A2_NREDUZ FROM "+RetSqlName("SA2")+" "
			//cQuery+= " INNER JOIN "+RetSqlName("ZVM")+" ON "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			cQuery+= " WHERE "+RetSqlName("SA2")+".D_E_L_E_T_ = '' "
			cQuery+= " AND A2_COD = ZVM_CLIFOR "
			cQuery+= " AND A2_LOJA = ZVM_LOJA) AS NOME "
			cQuery+= " FROM "+RetSqlName("ZVM")+" "
			cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			cQuery+= " AND ZVM_ORIGEM = 'PAGAR'
			cQuery+= " AND ZVM_LA <> 'S'
			//cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
			//cQuery+= " GROUP BY ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL, ZVM_CLIFOR, ZVM_LOJA "
			cQuery+= " ORDER BY ZVM_PREFIX, ZVM_NUM, ZVM_PARCEL, ZVM_CLIFOR, ZVM_LOJA ASC "
			TcQuery cQuery New Alias(cZVM := GetNextAlias())
		Endif
		cArquivo := "cZVM"
		nTotal    := 0
		lDigita   := .T.
		cLote     := GetMv("CL_LOTEVAR")
		cPadrao   := "VM1"
		cFunction := Substr(FunName(),1,8)
		nHdlPrv	  := HeadProva(cLote,cFunction,Alltrim(cUserName),@cArquivo)

		DbSelectArea((cZVM))
		ProcRegua(RecCount())
		(cZVM)->(DbGoTop())
		If (cZVM)->(!Eof())
			Do While (cZVM)->(!Eof())
				IncProc("Gerando Lançamento Contábil...")

				nTotal := nTotal + DetProva(nHdlPrv,cPadrao,cFunction,cLote)

				// RodaProva(nHdlPrv,nTotal)

				// // Envia para Lancamento Contabil
				// cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,,,,,)

				If _cCont == 2
					_cQuery:= ""
					_cQuery+= " UPDATE "+RetSqlName("ZVM")+" SET ZVM_LA = 'S' "
					_cQuery+= " FROM "+RetSqlName("ZVM")+" "
					_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
					_cQuery+= " AND ZVM_CLIFOR+ZVM_LOJA = '"+(cZVM)->CLIENTE+"'
					_cQuery+= " AND ZVM_ORIGEM = 'PAGAR'
					_cQuery+= " AND ZVM_LA <> 'S'
					//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
					TcSqlExec(_cQuery)
				Elseif _cCont == 3
					_cQuery:= ""
					_cQuery+= " UPDATE "+RetSqlName("ZVM")+" SET ZVM_LA = 'S' "
					_cQuery+= " FROM "+RetSqlName("ZVM")+" "
					_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
					_cQuery+= " AND ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL = '"+(cZVM)->TITULO+"'
					_cQuery+= " AND ZVM_ORIGEM = 'PAGAR'
					_cQuery+= " AND ZVM_LA <> 'S'
					//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
					TcSqlExec(_cQuery)
				Endif

				(cZVM)->(DbSkip())
			EndDo

			RodaProva(nHdlPrv,nTotal)

			// Envia para Lancamento Contabil
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,,,,,)
		EndIf
		DbSelectArea((cZVM))
		(cZVM)->(DbCloseArea())

	Endif

	If LContabil .AND. (_cCarteira == 2 .OR. _cCarteira == 3)
		//REALIZANDO CONTABILIZACAO DO PROCESSO - CONTAS A RECEBER
		If _cCont == 1
			cQuery:= ""
			cQuery+= " SELECT ZVM_CLIFOR+ZVM_LOJA AS CLIENTE "
			cQuery+= " , SUM(ZVM_VALOR) AS VALOR "
			cQuery+= " , (CASE WHEN SUM(ZVM_VALOR) < 0 "
			cQuery+= "         THEN 'NEGATIVA' "
			cQuery+= "         ELSE 'POSITIVA' "
			cQuery+= "         END) AS TPVAR "
			cQuery+= " , 'CLI' AS OPCAO "
			cQuery+= " , (SELECT DISTINCT A1_NREDUZ FROM "+RetSqlName("SA1")+" "
			cQuery+= " INNER JOIN "+RetSqlName("ZVM")+" ON "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			cQuery+= " WHERE "+RetSqlName("SA1")+".D_E_L_E_T_ = '' "
			cQuery+= " AND A1_COD = ZVM_CLIFOR "
			cQuery+= " AND A1_LOJA = ZVM_LOJA) AS NOME "
			cQuery+= " , ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL AS TITULO "
			cQuery+= " FROM "+RetSqlName("ZVM")+" "
			cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			cQuery+= " AND ZVM_ORIGEM = 'RECEBER'
			cQuery+= " AND ZVM_LA <> 'S'
			//cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
			//cQuery+= " GROUP BY ZVM_CLIFOR+ZVM_LOJA
			cQuery+= " ORDER BY ZVM_CLIFOR, ZVM_LOJA ASC "
			TcQuery cQuery New Alias(cZVM := GetNextAlias())
		ELSEIF _cCont == 3
			cQuery:= ""
			cQuery+= " SELECT ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL AS TITULO "
			cQuery+= " , SUM(ZVM_VALOR) AS VALOR "
			cQuery+= " , (CASE WHEN SUM(ZVM_VALOR) < 0 "
			cQuery+= "         THEN 'NEGATIVA' "
			cQuery+= "         ELSE 'POSITIVA' "
			cQuery+= "         END) AS TPVAR "
			cQuery+= " , 'TIT' AS OPCAO "
			cQuery+= " , (SELECT DISTINCT A1_NREDUZ FROM "+RetSqlName("SA1")+" "
			cQuery+= " INNER JOIN "+RetSqlName("ZVM")+" ON "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			cQuery+= " WHERE "+RetSqlName("SA1")+".D_E_L_E_T_ = '' "
			cQuery+= " AND A1_COD = ZVM_CLIFOR "
			cQuery+= " AND A1_LOJA = ZVM_LOJA) AS NOME "
			cQuery+= " FROM "+RetSqlName("ZVM")+" "
			cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			cQuery+= " AND ZVM_ORIGEM = 'RECEBER'
			cQuery+= " AND ZVM_LA <> 'S'
			//cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
			//cQuery+= " GROUP BY ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL
			cQuery+= " ORDER BY ZVM_PREFIX, ZVM_NUM, ZVM_PARCEL, ZVM_CLIFOR, ZVM_LOJA ASC "
			TcQuery cQuery New Alias(cZVM := GetNextAlias())
		Endif
		cArquivo := "cZVM"
		nTotal    := 0
		lDigita   := .T.
		cLote     := GetMv("CL_LOTEVAR")
		cPadrao   := "VM2"
		cFunction := Substr(FunName(),1,8)
		nHdlPrv	  := HeadProva(cLote,cFunction,Alltrim(cUserName),@cArquivo)

		DbSelectArea((cZVM))
		ProcRegua(RecCount())
		(cZVM)->(DbGoTop())
		If (cZVM)->(!Eof())
			Do While (cZVM)->(!Eof())
				IncProc("Gerando Lançamento Contábil...")

				nTotal := nTotal + DetProva(nHdlPrv,cPadrao,cFunction,cLote)



				If _cCont == 2
					_cQuery:= ""
					_cQuery+= " UPDATE "+RetSqlName("ZVM")+" SET ZVM_LA = 'S' "
					_cQuery+= " FROM "+RetSqlName("ZVM")+" "
					_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
					_cQuery+= " AND ZVM_CLIFOR+ZVM_LOJA = '"+(cZVM)->CLIENTE+"'
					_cQuery+= " AND ZVM_LA <> 'S'
					_cQuery+= " AND ZVM_ORIGEM = 'RECEBER'
					//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
					TcSqlExec(_cQuery)
				Elseif _cCont == 3
					_cQuery:= ""
					_cQuery+= " UPDATE "+RetSqlName("ZVM")+" SET ZVM_LA = 'S' "
					_cQuery+= " FROM "+RetSqlName("ZVM")+" "
					_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
					_cQuery+= " AND ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL = '"+(cZVM)->TITULO+"'
					_cQuery+= " AND ZVM_LA <> 'S'
					_cQuery+= " AND ZVM_ORIGEM = 'RECEBER'
					//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
					TcSqlExec(_cQuery)
				Endif

				(cZVM)->(DbSkip())
			EndDo

			RodaProva(nHdlPrv,nTotal)

			// Envia para Lancamento Contabil
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,,,,,)
		Endif
		DbSelectArea((cZVM))
		(cZVM)->(DbCloseArea())

	Endif



	IF (_cCarteira == 2 .OR. _cCarteira == 3)
		//REALIZANDO REVERSÃO DA CONTABILIZACAO DO PROCESSO - CONTAS A RECEBER
		If _cCont == 1
			_cQuery:= ""
			_cQuery+= " SELECT ZVM_CLIFOR+ZVM_LOJA AS CLIENTE "
			_cQuery+= " , SUM(ZVM_VALOR) AS VALOR "
			_cQuery+= " , (CASE WHEN SUM(ZVM_VALOR) < 0 "
			_cQuery+= "         THEN 'NEGATIVA' "
			_cQuery+= "         ELSE 'POSITIVA' "
			_cQuery+= "         END) AS TPVAR "
			_cQuery+= " , 'CLI' AS OPCAO "
			_cQuery+= " , (SELECT DISTINCT A1_NREDUZ FROM "+RetSqlName("SA1")+" "
			_cQuery+= " INNER JOIN "+RetSqlName("ZVM")+" ON "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			_cQuery+= " WHERE "+RetSqlName("SA1")+".D_E_L_E_T_ = '' "
			_cQuery+= " AND A1_COD = ZVM_CLIFOR "
			_cQuery+= " AND A1_LOJA = ZVM_LOJA) AS NOME "
			_cQuery+= " , ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL AS TITULO "
			_cQuery+= " FROM "+RetSqlName("ZVM")+" "
			_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			_cQuery+= " AND ZVM_ORIGEM = 'RECEBER'
			_cQuery+= " AND ZVM_LA = 'S'
			_cQuery+= " AND ZVM_DTBASE BETWEEN '"+DTOS(_cFirstDate)+"' AND '"+DTOS(_cLastDate)+"'
			//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
			//_cQuery+= " GROUP BY ZVM_CLIFOR+ZVM_LOJA
			_cQuery+= " ORDER BY ZVM_CLIFOR, ZVM_LOJA ASC "
			TcQuery _cQuery New Alias(cZVM := GetNextAlias())
		ELSEIF _cCont == 3
			_cQuery:= ""
			_cQuery+= " SELECT ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL AS TITULO "
			_cQuery+= " , SUM(ZVM_VALOR) AS VALOR "
			_cQuery+= " , (CASE WHEN SUM(ZVM_VALOR) < 0 "
			_cQuery+= "         THEN 'NEGATIVA' "
			_cQuery+= "         ELSE 'POSITIVA' "
			_cQuery+= "         END) AS TPVAR "
			_cQuery+= " , 'TIT' AS OPCAO "
			_cQuery+= " , (SELECT DISTINCT A1_NREDUZ FROM "+RetSqlName("SA1")+" "
			_cQuery+= " INNER JOIN "+RetSqlName("ZVM")+" ON "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			_cQuery+= " WHERE "+RetSqlName("SA1")+".D_E_L_E_T_ = '' "
			_cQuery+= " AND A1_COD = ZVM_CLIFOR "
			_cQuery+= " AND A1_LOJA = ZVM_LOJA) AS NOME "
			_cQuery+= " FROM "+RetSqlName("ZVM")+" "
			_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			_cQuery+= " AND ZVM_ORIGEM = 'RECEBER'
			_cQuery+= " AND ZVM_LA = 'S'
			_cQuery+= " AND ZVM_DTBASE BETWEEN '"+DTOS(_cFirstDate)+"' AND '"+DTOS(_cLastDate)+"'
			//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
			//_cQuery+= " GROUP BY ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL
			_cQuery+= " ORDER BY ZVM_PREFIX, ZVM_NUM, ZVM_PARCEL, ZVM_CLIFOR, ZVM_LOJA ASC "
			TcQuery _cQuery New Alias(cZVM := GetNextAlias())
		ENDIF

		cArquivo := "cZVM"
		nTotal    := 0
		lDigita   := .T.
		cLote     := GetMv("CL_LOTEVAR")
		cPadrao   := "VM3"
		cFunction := Substr(FunName(),1,8)
		nHdlPrv	  := HeadProva(cLote,cFunction,Alltrim(cUserName),@cArquivo)

		DbSelectArea((cZVM))
		ProcRegua(RecCount())
		(cZVM)->(DbGoTop())
		If (cZVM)->(!Eof())
			Do While (cZVM)->(!Eof())
				IncProc("Gerando Lançamento Contábil...")

				nTotal := nTotal + DetProva(nHdlPrv,cPadrao,cFunction,cLote)



				If _cCont == 2
					_cQuery:= ""
					_cQuery+= " UPDATE "+RetSqlName("ZVM")+" SET ZVM_REVLA = 'S' "
					_cQuery+= " FROM "+RetSqlName("ZVM")+" "
					_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
					_cQuery+= " AND ZVM_CLIFOR+ZVM_LOJA = '"+(cZVM)->CLIENTE+"'
					_cQuery+= " AND ZVM_LA = 'S'
					_cQuery+= " AND ZVM_ORIGEM = 'RECEBER'
					//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
					TcSqlExec(_cQuery)
				Elseif _cCont == 3
					_cQuery:= ""
					_cQuery+= " UPDATE "+RetSqlName("ZVM")+" SET ZVM_REVLA = 'S' "
					_cQuery+= " FROM "+RetSqlName("ZVM")+" "
					_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
					_cQuery+= " AND ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL = '"+(cZVM)->TITULO+"'
					_cQuery+= " AND ZVM_LA = 'S'
					_cQuery+= " AND ZVM_ORIGEM = 'RECEBER'
					//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
					TcSqlExec(_cQuery)
				Endif

				(cZVM)->(DbSkip())
			EndDo

			RodaProva(nHdlPrv,nTotal)

			// Envia para Lancamento Contabil
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,_cNextFirst,,,,)

		Endif
		DbSelectArea((cZVM))
		(cZVM)->(DbCloseArea())


	ENDIF

	IF (_cCarteira == 1 .OR. _cCarteira == 3)
		//REALIZANDO REVERSÃO DA CONTABILIZACAO DO PROCESSO - CONTAS A PAGAR
		If _cCont == 1
			_cQuery:= ""
			_cQuery+= " SELECT ZVM_CLIFOR+ZVM_LOJA AS CLIENTE "
			_cQuery+= " , SUM(ZVM_VALOR) AS VALOR "
			_cQuery+= " , (CASE WHEN SUM(ZVM_VALOR) < 0 "
			_cQuery+= "         THEN 'NEGATIVA' "
			_cQuery+= "         ELSE 'POSITIVA' "
			_cQuery+= "         END) AS TPVAR "
			_cQuery+= " , 'CLI' AS OPCAO "
			_cQuery+= " , (SELECT DISTINCT A2_NREDUZ FROM "+RetSqlName("SA2")+" "
			//_cQuery+= " INNER JOIN "+RetSqlName("ZVM")+" ON "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			_cQuery+= " WHERE "+RetSqlName("SA2")+".D_E_L_E_T_ = '' "
			_cQuery+= " AND A2_COD = ZVM_CLIFOR "
			_cQuery+= " AND A2_LOJA = ZVM_LOJA) AS NOME "
			_cQuery+= " , ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL AS TITULO "
			_cQuery+= " FROM "+RetSqlName("ZVM")+" "
			_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			_cQuery+= " AND ZVM_ORIGEM = 'PAGAR'
			_cQuery+= " AND ZVM_LA = 'S'
			_cQuery+= " AND ZVM_DTBASE BETWEEN '"+DTOS(_cFirstDate)+"' AND '"+DTOS(_cLastDate)+"'
			//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
			//_cQuery+= " GROUP BY ZVM_CLIFOR+ZVM_LOJA, ZVM_CLIFOR, ZVM_LOJA
			_cQuery+= " ORDER BY ZVM_CLIFOR, ZVM_LOJA ASC "
			TcQuery _cQuery New Alias(cZVM := GetNextAlias())
		ELSEIF _cCont == 3
			_cQuery:= ""
			_cQuery+= " SELECT ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL AS TITULO "
			_cQuery+= " , SUM(ZVM_VALOR) AS VALOR "
			_cQuery+= " , (CASE WHEN SUM(ZVM_VALOR) < 0 "
			_cQuery+= "         THEN 'NEGATIVA' "
			_cQuery+= "         ELSE 'POSITIVA' "
			_cQuery+= "         END) AS TPVAR "
			_cQuery+= " , 'TIT' AS OPCAO "
			_cQuery+= " , (SELECT DISTINCT A2_NREDUZ FROM "+RetSqlName("SA2")+" "
			//_cQuery+= " INNER JOIN "+RetSqlName("ZVM")+" ON "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			_cQuery+= " WHERE "+RetSqlName("SA2")+".D_E_L_E_T_ = '' "
			_cQuery+= " AND A2_COD = ZVM_CLIFOR "
			_cQuery+= " AND A2_LOJA = ZVM_LOJA) AS NOME "
			_cQuery+= " FROM "+RetSqlName("ZVM")+" "
			_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
			_cQuery+= " AND ZVM_ORIGEM = 'PAGAR'
			_cQuery+= " AND ZVM_LA = 'S'
			_cQuery+= " AND ZVM_DTBASE BETWEEN '"+DTOS(_cFirstDate)+"' AND '"+DTOS(_cLastDate)+"'
			//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
			//_cQuery+= " GROUP BY ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL, ZVM_CLIFOR, ZVM_LOJA
			_cQuery+= " ORDER BY ZVM_PREFIX, ZVM_NUM, ZVM_PARCEL, ZVM_CLIFOR, ZVM_LOJA ASC "
			TcQuery _cQuery New Alias(cZVM := GetNextAlias())
		ENDIF

		cArquivo := "cZVM"
		nTotal    := 0
		lDigita   := .T.
		cLote     := GetMv("CL_LOTEVAR")
		cPadrao   := "VM4"
		cFunction := Substr(FunName(),1,8)
		nHdlPrv	  := HeadProva(cLote,cFunction,Alltrim(cUserName),@cArquivo)

		DbSelectArea((cZVM))
		ProcRegua(RecCount())
		(cZVM)->(DbGoTop())
		If (cZVM)->(!Eof())
			Do While (cZVM)->(!Eof())
				IncProc("Gerando Lançamento Contábil...")

				nTotal := nTotal + DetProva(nHdlPrv,cPadrao,cFunction,cLote)

				//RodaProva(nHdlPrv,nTotal)

				// Envia para Lancamento Contabil
				//cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,_cNextFirst,,,,)

				If _cCont == 2
					_cQuery:= ""
					_cQuery+= " UPDATE "+RetSqlName("ZVM")+" SET ZVM_REVLA = 'S' "
					_cQuery+= " FROM "+RetSqlName("ZVM")+" "
					_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
					_cQuery+= " AND ZVM_CLIFOR+ZVM_LOJA = '"+(cZVM)->CLIENTE+"'
					_cQuery+= " AND ZVM_LA = 'S'
					_cQuery+= " AND ZVM_ORIGEM = 'PAGAR'
					//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
					TcSqlExec(_cQuery)
				Elseif _cCont == 3
					_cQuery:= ""
					_cQuery+= " UPDATE "+RetSqlName("ZVM")+" SET ZVM_REVLA = 'S' "
					_cQuery+= " FROM "+RetSqlName("ZVM")+" "
					_cQuery+= " WHERE "+RetSqlName("ZVM")+".D_E_L_E_T_ = '' "
					_cQuery+= " AND ZVM_PREFIX+ZVM_NUM+ZVM_PARCEL = '"+(cZVM)->TITULO+"'
					_cQuery+= " AND ZVM_LA = 'S'
					_cQuery+= " AND ZVM_ORIGEM = 'PAGAR'
					//_cQuery+= " AND ZVM_FILIAL = '"+FwxFilial("ZVM")+"' "
					TcSqlExec(_cQuery)
				Endif

				(cZVM)->(DbSkip())
			EndDo

			RodaProva(nHdlPrv,nTotal)

			// Envia para Lancamento Contabil
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,_cNextFirst,,,,)

		Endif

		DbSelectArea((cZVM))
		(cZVM)->(DbCloseArea())

	Endif



Return

//--------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function HdPrvVar(cLote,cPrograma,cOperador,cArquivo,lCria,aDadosProva)
	Local nRetHandle := 65536	// NAO MEXA NESTE NUMERO
	Local aRetHead   := {}

	FINVARCTB()

	Default aDadosProva:={}

	__HeadProva := {cLote,cPrograma,cOperador,"", -5 }
	lCria       := If( lCria = NIL , .f. , lCria )

	If !CtbInUse()		// M¢dulo SIGACON

		If lCria
			aRetHead := CriaCProva(cLote,cPrograma,cOperador)
			__HeadProva[4] := aRetHead[1]	// Nome do Arquivo
			cArquivo       := aRetHead[1]	// Nome do Arquivo (X Referˆncia)
			__HeadProva[5] := aRetHead[2]	// Handle do Arquivo
			nRetHandle		:= aRetHead[2] // Handle do Arquivo
		EndIf

	Else							// M¢dulo SIGACTB

		IF lCria
			// AQUI! No SIGACTB n„o vai criar cProva ! N„o pode for‡ar cria‡„o
			alert("HeadProva n„o pode for‡ar cria‡„o de Arquivo")
		Endif

	Endif

// Array com dados para utilizacao multi-thread
	aDadosProva:=ACLONE(__HeadProva)

Return nRetHandle

//--------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function TxVarIncl(	cArquivo,nHdlPrv,nOpcx,cLoteContabil,lDigita,lAglut,cOnLine,;
		dData,dReproc,aFlagCTB,aDadosProva,aSeqDiario,aTpSaldo,lSimula,cTabCTK,cTabCT2)

	Local aDiario := aClone(aSeqDiario)
	DEFAULT aFlagCTB   := {}
	DEFAULT aTpSaldo   := Nil
	Default lSimula		:= .F.
	Default cTabCTK		:= "CTK"
	Default cTabCT2		:= "CT2"

	cLoteContabil := Substr(cLoteContabil,1,6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adapta‡„o para chamar a rotina de Inclus„o do SIGACTB caso habilitado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return TX_Incl(cArquivo,nHdlPrv,nOpcx,cLoteContabil,lDigita,lAglut,cOnLine,dData,dReproc,@aFlagCTB,aDadosProva,@aTpSaldo,aDiario,lSimula,cTabCTK,cTabCT2)

//--------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function TX_Incl(	cArquivo, nHdlPrv, nOpcx, cLoteContabil, lDigita, lAglut, cOnLine,;
		dData, dReproc, aFlagCTB, aDadosProva, aTpSaldo, aSeqDiario, lSimula,;
		cTabCTK, cTabCT2)

	Local aSaveArea	:= GetArea()
	Local nOpca			:= 0
	Local nArqAbre		:= 1
	Local cArqAbre		:= "CT0"
	Local CTF_LOCK		:= 0
	Local cCadastro 	:= OemToAnsi(STR0001)				// Lancamentos Contabeis
	Local cArq1			:= ""
	Local cArq2			:= ""
	Local cEmpOri		:= cEmpAnt
	Local cFilOri		:= cFilAnt
	Local oSize

	Local oDlg
	Local oFilial
	Local oLote
	Local oSubLote, lSubLote
	Local oDoc
	Local oHistCapLt
	Local oFnt

	Local lFirst		:= .T.
	Local lRpc			:= Type("oMainWnd") = "U"		// Chamada via Rpc nao tem tela
	Local lRpcOk		:= .T.
	Local nLin  		:= 0
	Local nRecCTK 		:= 0
	Local cAliasCTK		:= "CTK"

// Variaveis para guardar eventuais funcoes ja atruibuidas às teclas F4 F5 F6 e F7 em outros modulos, para serem
// restauradas no final.
	Local bVK_4
	Local bVK_5
	Local bVK_6
	Local bVK_7

	Local cPreLcto		:= ""
	Local cRotina		:= FunName()
	Local cProgName		:= ""
	Local aButton 		:= {}
	Local aButtonNew	:= {}
	Local cLoteEXEC		:= ""
	Local cSbLoteExec   := ""
	Local cExpFil		:= ""
	Local cTxtfil		:= ""

	Local aCTKxCT2		:= {}
	Local dCt2Data
	Local aStruCTK 	:= {}
	Local aStruQry		:= {}
	Local cTypDB		:= UPPER(TcGetDB())
	Local lOrdEnt		:= If(GetNewPar("MV_ORDLCTB","L")=="E",.T.,.F.)			/// MV_ORDLCTB : L= LP (sequen+lp)/ E = Entrada (Recno)
	Local nMoedas		:= 0
	Local nPosQry		:= 0
	Local nY

	Local lOrdTpSld		:= If(GetNewPar("MV_ORDLCTB","L")=="T",.T.,.F.)			/// MV_ORDLCTB : T= Tipo de Saldo
	Local lOrdLp        := If(GetNewPar("MV_ORDLCTB","L")=="L",.T.,.F.)			/// MV_ORDLCTB : L= Lanc.Padrao

	Local nTipoSaldo

	Local lSeqCorr   	:= UsaSeqCor("CT2/CTK/CT5")
	Local cSeqCorr 		:= Space(10)
	Local nX
	Local cChaveCT2		:= ""
	Local cChaveCTK		:= ""
	Local lDigitaOri    := lDigita   // salva o status original
	Local cHistCapLt	:= "" //Historico Capa do Lote
	Local nCtr1stRow
	Local nLbl1st1
	Local nCmp1st1
	Local nLbl1st2
	Local nCmp1st2

	Local nCtr3rdRow
	Local nLbl3rd1
	Local nCmp3rd1
	Local nLbl3rd2
	Local nCmp3rd2
	Local nLbl3rd3
	Local nCmp3rd3
	Local lExistcFun    := Type("cFunname")<>"U"

	Local cFilLanc		:= FWXFilial("CT2")
	Local lCriaTmp 		:= .T.
	Local lCT105But     := ExistBlock("CT105But")
	Local lFlagMain     := .F.
	Local lM330Proc		:= SuperGetMv("MV_M33UPRC",.T.,.F.)
	Local aValDif		:= {}
	Local lLockRec      as logico


//Variaveis utilizadas para metricas
	Local nQtdCntb		:= 0
	Local nStart		:= Seconds()

//variaveis para utilizar o FwPreparedStatement para a Changequery.
	Local cAuxCTK       := ""
	Local lUsaChangeQ 	:= .T.
	Local aSelect		:= {}

	Private aTELA		:= {}
	Private aGETS		:= {}
	Private aCols		:= Nil
	Private aRotina		:= MenuDef()
	Private dDataLanc	:= Iif(dData == Nil,dDataBase,dData)
	Private nTotInf		:= 0
	Private aTotRdpe 	:= {{0,0,0,0},{0,0,0,0}}
	Private nUsado		:= 0
	Private nSaida		:= 0

	Private oDig
	Private oDeb
	Private oCred
	Private oInf
	Private oDescEnt

	Private cLote		:= cLoteContabil, cSubLote
	Private cDoc		:= Space(6)

	Private cSeqCrAnt   := Space(10)

	Private aColsP		:= {}
	Private oGetDb

	Private OPCAO
	Private aCtbEntid

	Private __aCT2LC	:= {}

	Default lSimula	:= .F.
	Default cTabCTK	:= "CTK"
	Default cTabCT2	:= "CT2"

/* lNewRelease >= "12.1.31" */
	If lNewRelease
		lLockRec := .T.
	/* ---------------------------------------------------------------------------------------------
		Fazer o bloqueio dos Registros no módulo origem passadas pelo vetor aFlagCTBe nos conteudos
		dos campos CTK_TABORI e CTK_RECORI. Na maioria das vezes é o mesmo do vetor aFlagCTB
	---------------------------------------------------------------------------------------------- */
	lLockRec:= _105LockFlg(aFlagCtb)
Endif
If ! CtbVerTmpBD() .And. ! __lTmp_Zap    // ! Type("aAltera") == "U"
	Private aAltera		:= {}
EndIf

If ! CtbVerTmpBD() .And. ! __lTmp_Zap     // Type("aHeader") == "U"
	Private aHeader		:= {}
EndIf


// Controle das TMPs esta sendo feito pela FINA370
If !(FunName() $ "CTBAFIN|FINA370") .and. CtbVerTmpBD()
	If select("TMP_CTB") > 0
		dbChangeAlias("TMP_CTB", "TMP")
	EndIf
Endif

If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

lAglByHist := RetAlgHist()

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If aCtbEntid == NIL
	aCtbEntid := Array(2,nQtdEntid)  //posicao 1=debito  2=credito
EndIf

//DEBITO
aCtbEntid[1,1] := {|| TMP->CT2_DEBITO 	}
aCtbEntid[1,2] := {|| TMP->CT2_CCD		}
aCtbEntid[1,3] := {|| TMP->CT2_ITEMD 	}
aCtbEntid[1,4] := {|| TMP->CT2_CLVLDB 	}
//CREDITO
aCtbEntid[2,1] := {|| TMP->CT2_CREDIT }
aCtbEntid[2,2] := {|| TMP->CT2_CCC		}
aCtbEntid[2,3] := {|| TMP->CT2_ITEMC 	}
aCtbEntid[2,4] := {|| TMP->CT2_CLVLCR 	}

For nX := 5 TO nQtdEntid
	aCtbEntid[1, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"DB } ")  //debito
	aCtbEntid[2, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"CR } ")  //credito
Next

// controle de limpeza do cache
If __ClearCx == Nil
	__ClearCx := GetNewPar( "MV_CTBCLSC" , .T. )
Endif

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf

If __lConOutR
	ConOutR("*LOGINI*|INICIO CTBA105")
EndIf

If Type("__aCT2LC") <> "A"
	__aCT2LC := {}
Endif

DEFAULT aFlagCTB	:= {}
DEFAULT nOpcX		:= 3

// define o valor da variavel opcao utilizada na gravação
OPCAO := nOpcx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Assume as informacoes do array aDadosProva, caso as mesmas   |
//| tenham sido passadas via parametro.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(aDadosProva) == "A"
	__HeadProva := ACLONE(aDadosProva)
EndIf

// Carrego os MVS
If lM330Proc .And. cRotina$"MATA330/MATA331/MATA333"
	aMVS[MV_ALTLCTO] := .F.
	aMvs[MV_PRELAN]  := "D"
EndIf

If aMVS[MV_ALTLCTO] = Nil
	aMVS[MV_ALTLCTO] := Iif( SuperGetMv( "MV_ALTLCTO" , .F., "S") == "S", .T., .F. )
Endif

If aMVS[MV_SUBLOTE] = Nil
	aMVS[MV_SUBLOTE] := GetMv("MV_SUBLOTE")
Endif

If aMvs[MV_PRELAN] = Nil
	aMvs[MV_PRELAN] := GetMv("MV_PRELAN")
Endif

If MAX_LINHA = Nil
	MAX_LINHA := { CtbLinMax(GetMv("MV_NUMLIN")), GetMv("MV_NUMMAN") }
Endif

//Alterar o conteudo da variavel dDataLanc, caso exista o ponto de entrada
If lAltDataL .and. !lOrdTpSld .And. !lSimula
	dDataLanc	:= 	ExecBlock("ALTDATAL",.F.,.F.,{dDataLanc,cRotina})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a numeracao do lote foi alterada pelo PE LOTECTB³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEXELOTECTB .And. !lSimula		//PONTO DE ENTRADA PARA ALTERAÇÃO NO NUMERO DO LOTE CTB.
	cLoteEXEC := EXECBLOCK("LOTECTB",.F.,.F.,{cLote})
	If ValType(cLoteEXEC) == "C" .and. !Empty(cLoteEXEC)
		cLoteContabil := cLoteEXEC
	EndIf
EndIf

cSubLote	:= aMVS[MV_SUBLOTE]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera SubLote antes da gravação PE CT105SBLOTE    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lCt105SbLote .And. !lSimula		//PONTO DE ENTRADA PARA ALTERAÇÃO DO SUBLOTE CTB.
	cSbLoteExec := ExecBlock("CT105SBLOTE",.F.,.F.,{cSubLote})
	If ValType(cSbLoteExec) == "C" .and. !Empty(cSbLoteExec)
		cSubLote := cSbLoteExec
	EndIf
EndIf



lSubLote 	:= Empty(cSubLote)
nOpc		:= 4
cLote 		:= Iif(Len(Alltrim(cLoteContabil)) < 6 , PADL(ALLTRIM(cLotecontabil),6,"0") , cLoteContabil)

If __lConOutR
	ConOutR("*PROCES*|Inicializando o calculo das medias para conversão das moedas.")
EndIf

// Calcula medias para conversao de moedas
CtbMedias( dDataLanc )

If __lConOutR
	ConOutR("*PROCES*|Finalizando o calculo das medias para conversão das moedas e iniciando a leitura do headprova.")
EndIf

If nHdlPrv == 65536	.and. GetHProva() == 1024
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso houve abertura por HeadProva() ( nHdlPrv == 65536 )     ³
	//³ e houve lan‡amento cont bil (Handle Interno == 1024)         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeqChave:= GetHFile()  // Retorna a chave dos dados gravados no CTK
Else
	RestArea(aSaveArea)
	Return .F.
Endif

If __lConOutR
	ConOutR("*PROCES*|Finalizando a leitura do headprova e iniciando A ABERTURA DOS ARQUIVOS DO CTB.")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AQUI! Abre os Arquivos do CTB em outros m¢dulos              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nArqAbre :=1 to 20 // Arquivos CT1 a CTK
	cArqAbre := soma1(cArqAbre)
	If Select(cArqAbre) <= 0
		ChkFile(cArqAbre)
	Endif
Next

If __lConOutR
	ConOutR("*PROCES*|Finalizando a abertura dos arquivos do CTB e iniciando a montagem do aheader.")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CT2")
If lSimula .and. !(lExistcFun .and. (cFunname == "FINA840" .or. cFunname == "FINA087A" .or. cFunname == "FINA850"))
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()
	If SIX->(dbSeek("CT21"))
		cChaveCT2 := AllTrim(SIX->CHAVE)
		IndRegua("CT2", cTabCT2, cChaveCT2, , , )
	EndIf
	dbSelectArea("CT2")
Else
	dbSetOrder(1)
EndIf

If ! CtbVerTmpBD()

	If __lTmp_Zap
		lCriaTmp := .T.
		If Select( 'TMP') > 0
			DbSelectArea( "TMP" )
			If FieldPos("CT2_DEBITO") == 0 //verifica se nao existe campo debito no temporario
				DbCloseArea()
			Else
				lCriaTmp := .F.  //Setar FALSE para somente dar ZAP no arquivo e nao recriar a cada documento contabilizado
				cArq1 := __cArq1  //atribui a variavel local cArq1/cArq2 o conteudo da static
				cArq2 := __cArq2
			Endif
		EndIf
	EndIf

	If ! lCriaTmp
		dbSelectArea("TMP")
		//Proteção feita de acordo com a solicitação da Issue DSERCTR1-18167
		If (GetRPORelease() == "12.1.017") .Or. Upper(AllTrim(TcGetDb()))=="DB2"
			Zap
		Else
			TcSqlExec(" Truncate Table "+ cArq1 )    //Zap
			DbCommitAll()
			TcRefresh(cArq1)
		EndIf
		dbGoTop()
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHeader para Lan‡amentos Cont beis                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		__aCampos := Ctb105Head(@aAltera,lSimula)

		If ValType(_oCTBA105) <> "U" .And. ( (FWisincallstack("FINA070") .OR. FWisincallstack("FINA080")) .AND. Select("TMP") > 0 )
			cArq1 := _oCTBA105:GETREALNAME()
			cArq2 := _oCTBA105:GETREALNAME()
		Else
			Ctb105Cria(__aCampos,@cArq1,@cArq2)
		EndIf

	EndIf

Else

	cArq1 := __cArq1  //atribui a variavel local cArq1/cArq2 o conteudo da static
	cArq2 := __cArq2

EndIf

If __lConOutR
	ConOutR("*PROCES*|Finalizando a montagem do aheader.")
EndIf

If __lConOutR
	ConOutR("*PROCES*|Inicio da leitura do CTK.")
EndIf

DbSelectArea("CTK")
If lSimula
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()
	If SIX->(dbSeek("CTK1"))
		cChaveCTK := AllTrim(SIX->CHAVE)
		IndRegua("CTK", cTabCTK, cChaveCTK, , , )
	EndIf
	dbSelectArea("CTK")
Else
	DbSetOrder(1)
EndIf

CTK->(DbCommit())		// Garanto que os registros estejam no BANCO

aStruCTK	:= CTK->(dbStruct())
cAliasCTK	:= "QUERYCTK"

cQuery := ""

If lAglut
	cQuery += "CTK_FILIAL,CTK_SEQUEN,CTK_DC"
	cQuery += ",CTK_DEBITO,CTK_CREDIT,CTK_CCD,CTK_CCC,CTK_ITEMD,CTK_ITEMC,CTK_CLVLDB,CTK_CLVLCR"
	For nX := 5 TO nQtdEntid
		cQuery += ",CTK_EC"+StrZero(nX,2)+"DB,CTK_EC"+StrZero(nX,2)+"CR"
	Next
	cQuery += ",CTK_TPSALD,CTK_DATA,CTK_LP"

	If lAglByHist
		If lCTKHAGLUT
			cQuery += ",CTK_HAGLUT CTK_HIST" /// Campo CTK_HAGLUT recebe CTK_HIST como apelido
		Else
			cQuery += ",CTK_HIST"
		EndIf
	Endif

	cQuery += ",CTK_CODPAR"
	cQuery += ",CTK_DIACTB"

	//Tratativa para aglutinação da Moeda do fato - Variacao Cambial
	cQuery += ",CTK_MOEFDB,CTK_MOEFCR"

	For nMoedas	:= 1 to __nQuantas
		cQuery += ",SUM( CTK_VLR" + StrZero(nMoedas,2) + " ) CTK_VLR" + StrZero(nMoedas,2)
	Next

	If !cTypDB$"MSSQL/MSSQL7/MYSQL/POSTGRES"				//// SE NÃO FOR SQL OU MSSQL7
		cQuery +=",MAX(CTK_LP||CTK_LPSEQ) CTKLPLPSEQ"
	Else									//// SE FOR SQL
		If cTypDB=="MYSQL"
			cQuery +=",MAX(CONCAT(CTK_LP,CTK_LPSEQ)) CTKLPLPSEQ"
		ElseIf cTypDB=="POSTGRES"
			cQuery +=",MAX(CAST(CTK_LP||CTK_LPSEQ AS CHAR("+ ALLTRIM(STR(TamSX3('CTK_LP')[1]+TamSX3('CTK_LPSEQ')[1]))+"))) CTKLPLPSEQ"
		Else
			cQuery +=",MAX(CTK_LP+CTK_LPSEQ) CTKLPLPSEQ"
		EndIf
	Endif
	cQuery +=",MIN(CTK_ORIGEM) CTK_ORIGEM"
	cQuery +=",MIN(R_E_C_N_O_) CTKMINRECNO"
	cQuery +=",MAX(R_E_C_N_O_) R_E_C_N_O_"
	cQuery +=",MIN(CTK_ROTINA) CTK_ROTINA"
	cQuery +=",MIN(CTK_KEY) CTK_KEY"
	cQuery +=",MIN(CTK_ATIVDE) CTK_ATIVDE"
	cQuery +=",MIN(CTK_ATIVCR) CTK_ATIVCR"
	cQuery +=",COUNT(*) CONTAAGLUT"
	cQuery += ",MIN(CTK_DTVENC) CTK_DTVENC"
	cQuery += ",CTK_AT01DB,CTK_AT02DB,CTK_AT03DB,CTK_AT04DB,CTK_AT01CR,CTK_AT02CR,CTK_AT03CR,CTK_AT04CR"
	If cPaisLoc == "MEX"
		If CTK->( FieldPos("CTK_UUID")) > 0 .and. CT2->(FieldPos("CT2_UUID")) > 0
			cQuery += ",CTK_UUID"
		Endif
		If CTK->( FieldPos("CTK_RFC")) > 0 .and. CT2->(FieldPos("CT2_RFC")) > 0
			cQuery += ",CTK_RFC"
		Endif
	EndIf
Else
	For nY := 1 To Len(aStruCTK)
		cQuery += aStruCTK[nY][1] + ","
	Next nY
	cQuery +="R_E_C_N_O_"
EndIf

cQuery := " SELECT " + cQuery

cAuxCTK = Iif(lSimula, (cTabCTK), RetSqlName( "CTK" ))

cQuery += " FROM  ? CTK " 					// P1 retsqlname
cQuery += " WHERE CTK.CTK_FILIAL =  ? AND " // P2 filial
cQuery += " CTK.CTK_SEQUEN = ? AND " 		// P3 sequencia

If lAglut
	cQuery += "	CTK_DC <>'4' AND "
Endif

cQuery += " CTK.D_E_L_E_T_ = ' ' "

If lAglut
	cQuery += "GROUP BY CTK_FILIAL,CTK_SEQUEN,CTK_DC,CTK_DEBITO,CTK_CREDIT,CTK_CCD,CTK_CCC,CTK_ITEMD,CTK_ITEMC,CTK_CLVLDB"
	cQuery += ",CTK_AT01DB,CTK_AT02DB,CTK_AT03DB,CTK_AT04DB,CTK_AT01CR,CTK_AT02CR,CTK_AT03CR,CTK_AT04CR"
	For nX := 5 TO nQtdEntid
		cQuery += ",CTK_EC"+StrZero(nX,2)+"DB,CTK_EC"+StrZero(nX,2)+"CR"
	Next
	cQuery += ",CTK_CLVLCR,CTK_TPSALD,CTK_DATA,CTK_LP"
	If lAglByHist
		If lCTKHAGLUT
			cQuery += ",CTK_HAGLUT"
		Else
			cQuery += ",CTK_HIST"
		EndIf
	Endif

	cQuery += ",CTK_CODPAR"
	cQuery += ",CTK_DIACTB"

	//Tratativa para a aglutinação da moeda do fato - Variacao Cambial
	cQuery += ",CTK_MOEFDB,CTK_MOEFCR"

	If cPaisLoc == "MEX"
		If CTK->( FieldPos("CTK_UUID")) > 0 .and. CT2->(FieldPos("CT2_UUID")) > 0
			cQuery += ",CTK_UUID"
		Endif
		If CTK->( FieldPos("CTK_RFC")) > 0 .and. CT2->(FieldPos("CT2_RFC")) > 0
			cQuery += ",CTK_RFC"
		Endif
	EndIf
	cQuery += " ORDER BY  "
	If 	lOrdTpSld	/// MV_ORDLCTB : T= Tipo de Saldo
		cQuery += "CTK_TPSALD,"
	EndIf
	cQuery += "CTKMINRECNO " /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
Else
	If lOrdEnt
		cQuery += "ORDER BY R_E_C_N_O_"  //"+SqlOrder(CTK->(IndexKey())) /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
	Else
		cQuery += "ORDER BY "
		If 	lOrdTpSld	/// MV_ORDLCTB : T= Tipo de Saldo
			cQuery += "CTK_TPSALD,"
		ElseIf lOrdLp .AND. lVazioSubL .AND. lQuebraLP /// MV_ORDLCTB : L = Lanc.Padrao
			cQuery += "CTK_LP,"
		EndIf

		cQuery += SqlOrder(CTK->(IndexKey())) /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
		cQuery += ", CTK_TABORI, CTK_RECORI, R_E_C_N_O_" /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
	Endif
EndIf

If lCt105Qry .And. !lSimula
	cQuery 	:= 	ExecBlock("CT105QRY",.F.,.F.,{cQuery,lAglut})
EndIf

If ! lAglut .And. Alltrim( UPPER(TcGetDB()) ) == "DB2"
	lUsaChangeQ := .F.
   	cQuery += " FOR READ ONLY "               //para performance nao passar pela changequery qdo DB2
ElseIf Alltrim( UPPER(TcGetDB()) ) == "POSTGRES" .And. lAglut  //se banco for PostGres e aglutina
	//retirado ChangeQuery pois ela tentava alterar a clausula/funcao CAST( e ocorria error log  e colocado mais um espaco somente para ficar mais legivel o codigo
	cQuery += " "         //cQuery := ChangeQuery(cQuery)
	lUsaChangeQ := .F.
EndIf

IF __LoadCTK == NIL
	If lUsaChangeQ
		__cQuery := cQuery
		cQuery := ChangeQuery(cQuery)
		__LoadCTK := FWPreparedStatement():New(cQuery)
	Else
		__cQuery := cQuery
		__LoadCTK := FWPreparedStatement():New(cQuery)
	Endif
Else
	If __cQuery != cQuery //Verifico se Houve alteração na query
		__LoadCTK := NIL	//se houve alteração destruo o objeto e reconstruo
		FwFreeObj(__LoadCTK)
		If lUsaChangeQ
			__cQuery := cQuery
			cQuery := ChangeQuery(cQuery)
			__LoadCTK := FWPreparedStatement():New(cQuery)
		Else
			__cQuery := cQuery
			__LoadCTK := FWPreparedStatement():New(cQuery)
		Endif
	EndIf
EnDif

If ( Select ( cAliasCTK ) <> 0 )
	dbSelectArea ( cAliasCTK )
	( cAliasCTK )->(dbCloseArea())
Endif

__LoadCTK:SetNumeric(1,cAuxCTK)  		 // P1 retsqlname
__LoadCTK:SetString(2,xFilial( "CTK" ) ) // P2 filial
__LoadCTK:SetString(3,cSeqChave) 		 // P3 sequencia

cAliasCTK := MPSYSOpenQuery(__LoadCTK:GetFixQuery(),cAliasCTK)

aStruQry	:= &(cAliasCTK)->(dbStruct())
For nY := 1 To Len(aStruCTK)
	If aStruCTK[nY][2] <> "C"
		//Verificar se o campo existe na query antes do TcSetField
		nPosQry	:= aScan(aStruQry,{|x|(x[1])==Trim(aStruCTK[nY][1])})
		If nPosQry > 0
			Aadd( aSelect, {aStruCTK[nY][1],aStruCTK[nY][2],aStruCTK[nY][3],aStruCTK[nY][4]})
		EndIf
	EndIf
Next nY
__LoadCTK:setFields( aSelect )
__LoadCTK:doTcSetField( cAliasCTK )

If __lConOutR
	ConOutR("*PROCES*|FIM QUERY CTK e Inicio da CARGA TMP.")
EndIf

cProgName := (cAliasCTK)->CTK_ROTINA
If Empty(cProgName)
	cProgName := FunName()
Endif

bVK_4 := SetKey(VK_F4)
bVK_5 := SetKey(VK_F5)
bVK_6 := SetKey(VK_F6)
bVK_7 := SetKey(VK_F7)

lEndCTK := .F.

While (cAliasCTK)->( Ctb105Grv(	cSeqChave,lAglut,__aCampos,dDataLanc,@cSubLote,@nLin,@nRecCTK,cAliasCTK,@aFlagCTB,@aCTKxCT2,@lEndCTK,lSeqCorr,@cSeqCorr,aSeqDiario,Nil,lSimula,cTabCTK,cTabCT2,@cHistCapLt))

	__cCodSeq := SubStr(cSeqCorr,1,2)

	If __lConOutR
		ConOutR("*PROCES*|FIM CARGA TMP -> CTB105GRV")
	EndIf

	If TMP->(RecCount()) == 0
		RestArea(aSaveArea)
		TMP->( dbCloseArea() )
		Return
	EndIf

	If (lFirst .Or. (nLin > MAX_LINHA[1])) .And. !lSimula
		If CTF_LOCK > 0		//LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC (DEPOIS DE GRAVAR O PRIMEIRO DOC)
			dbSelectArea("CTF")
			dbGoTo(CTF_LOCK)
			CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
		Endif

		If lAltDataL .and. lOrdTpSld .And. !lSimula
			dDataLanc	:= 	ExecBlock("ALTDATAL",.F.,.F.,{dData,cRotina})
		EndIf

		Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o N§ do Doc estourou, incrementa o lote         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLote := CtbInc_Lot(cLote, cModulo)

		Enddo
		lFirst := .F.
	Endif

	aButton := {}
	Aadd( aButton, {"RECALC"   , { || MsAguarde({|| CtRecRdPe()},STR0055) },STR0056 } )//"Recalculando totais..."#"Rec.Totais"
	Aadd( aButton, {"SIMULACAO",{ || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc)} , STR0015+" - <F5>",STR0016 } ) //"Totais do lote e documento (outras moedas)" "Totais"
	Aadd( aButton, {"PREV"     ,{ || CTB105Flt (oGetDb,.F.              ) },STR0019,STR0026 } ) //"Inconsistencia Anterior" //"Anterior"
	Aadd( aButton, {"NEXT"     ,{ || CTB105Flt (oGetDb,.T.              ) },STR0020,STR0050 } ) //"Proxima Inconsistencia" //"Próxima"
	If aMvs[MV_ALTLCTO]
		Aadd( aButton, {"CTBREPLA"   ,{ || Ctb102Repla()}, STR0051 ,STR0052		} ) //"Replicar o conteudo do campo posicionado"###"Replicar"
	EndIf
	aButton := AddToExcel(aButton,{	{"ARRAY",STR0053,{STR0002,STR0003,STR0013,STR0004},{{dDataLanc,cLote,cSubLote,cDoc}}},{"GETDB",STR0054,aHeader,"TMP"} } ) //"Documento"###"Lançamentos"
	Aadd( aButton, {"PESQUISA"   ,{ || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil) },STR0021 } ) //"Localizar"
	Aadd( aButton, {"IMPRIMIR"   ,{ || CTB_IMPLANC() }, OemToAnsi(STR0086) } ) //'Imprimir'

	//----------------------------------------------------------------
	// Ponto de entrada para inclusão de novos itens no menu aButton
	//----------------------------------------------------------------
	If lCT105But
		aButtonNew := ExecBlock("CT105But",.F.,.F.,aButton)
		If (ValType(aButtonNew) == "A")
			aButton := aClone(aButtonNew)
		EndIf
	EndIf

	If __lConOutR
		ConOutR("*PROCES*|PEGOU No DOCUMENTO CTB")
	EndIf

	__PreLan 	:= .F.		// Indica se tenta gravar como pre-lancamento

	If !lDigita										// Se altera lancamento -> visualiza!!
		If lRpc
			//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lAntCtbGrv .And. !lSimula
				ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
			Endif

			If __lConOutR
				ConOutR("*PROCES*|INICIO VALIDACOES1")
			EndIf

			//Validacao
			If lSimula
				lRpcOk := .T.
			Else
				lRpcOk	:= CTB105Rpc(lDigita) .And. Ct105TOK(lCT105TOK,lCT105CHK,.F., .F.,aTotRdpe,nTotInf)
			EndIf

			If !lRpcOk .Or. __Prelan == .T.
				cPreLcto	:= "S"
			Else
				cPreLcto	:= "N"
			EndIf

			If __lConOutR
				ConOutR("*PROCES*|FIM VALIDACOES1")
			EndIf

			If FwGetRunSchedule() .Or. __lBlind
				Ct105TOK(lCT105TOK,lCT105CHK,.F., .F.,aTotRdpe,nTotInf,,,@aValDif)
				CtbChkDif(aValDif, @aCTKxCT2, cTabCTK)
			EndIf

			CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,__lCusto,__lItem,__lCLVL,,cProgName,;
					cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
					cHistCapLt)

			If __lConOutR
				ConOutR("*PROCES*|TERMINOU CTBGRAVA1")
			EndIf
			//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lDepCtbGrv .And. !lSimula
				ExecBlock("DEPCTBGRV",.F.,.F., {nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
			Endif

			//Dar ZAP no arquivo temporario para nao trazer residuos do documento anterior
			//dbSelectArea("TMP")
			//Zap
			If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo
				If ! CtbVerTmpBD()

					If __lTmp_Zap

						lCriaTmp := .T.
						If Select( 'TMP') > 0
							DbSelectArea( "TMP" )
							If FieldPos("CT2_DEBITO") == 0 //verifica se nao existe campo debito no temporario
								DbCloseArea()
							Else
								lCriaTmp := .F.  //Setar FALSE para somente dar ZAP no arquivo e nao recriar a cada documento contabilizado
							Endif
						EndIf

					EndIf

					If lCriaTmp
						TMP->(DbCloseArea())
						FErase( cArq1+cDBSExt )
						Ferase( cArq1+cIndExt )
						Ferase( cArq2+cIndExt )
						cArq1 := ""
						cArq2 := ""
						Ctb105Cria(__aCampos,@cArq1,@cArq2)
					Else
						dbSelectArea("TMP")
						Zap
						dbGoTop()
					EndIf
				Else
					dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
					TcSqlExec(" Truncate Table "+ cArq1 )  //Zap
					DbCommitAll()
					TcRefresh(cArq1)
					dbgobottom()
					dbgotop()
				EndIf
			EndIf
		Else
			If __lConOutR
				ConOutR("*PROCES*|INICIO VALIDACOES2 | GRAVAÇÃO DO CT2")
			EndIf

			//Validacao
			If lSimula
				lRpcOk := .T.
			Else
				lRpcOk := Ct105TOK(lCT105TOK,lCT105CHK,.F.,.F.,aTotRdpe,nTotInf,,,@aValDif)
			EndIf

			IF ! lRpcOk
				lDigita := aMvs[MV_ALTLCTO]
			Else
				If !CtbValiDt(nOpc,dDataLanc)//Se nao tem uma data valida
					lDigita	:= .T. //Mostra lancamento contabil
		    	Endif
			Endif

			If !lDigita

				//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lAntCtbGrv .And. !lSimula
					ExecBlock("ANTCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
				Endif

				If lSimula
					lRpcOk := .T.
				Else
					lRpcOk := lRpcOk .And. CTB105Rpc(lDigita)
				EndIf

				If !lRpcOk  .Or. __Prelan == .T.
					cPreLcto	:= "S"
				Else
					cPreLcto	:= "N"
				EndIf

	           lSimula := Iif(cPaisLoc=="ARG" .and. !(lExistcFun .and. cFunname == "FINA850"),.f.,lSimula)

				CtbChkDif(aValDif, @aCTKxCT2, cTabCTK)

				CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,;
						__lCusto,__lItem,__lCLVL,,cProgName,cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
						cHistCapLt)

	           lSimula := Iif(cPaisLoc=="ARG" .and. !(lExistcFun .and. cFunname == "FINA850"),.t.,lSimula)

				//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lDepCtbGrv .And. !lSimula
					ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
				Endif

				//Dar ZAP no arquivo temporario para nao trazer residuos do documento anterior
				//dbSelectArea("TMP")
				//Zap
				If !lEndCTK		///Se não terminou a leitura de CTK carrega TMP novo
					If ! CtbVerTmpBD()
						If __lTmp_Zap
							dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
							Zap
							dbGoTop()
						Else
							TMP->(DbCloseArea())
							FErase( cArq1+cDBSExt )
							Ferase( cArq1+cIndExt )
							Ferase( cArq2+cIndExt )
							cArq1 := ""
							cArq2 := ""
							Ctb105Cria(__aCampos,@cArq1,@cArq2)
						EndIf
					Else
						dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
						TcSqlExec(" Truncate Table "+ cArq1 )    //Zap
						DbCommitAll()
						TcRefresh(cArq1)
						dbgobottom()
						dbgotop()
					EndIf
				EndIf

			EndIf

			If __lConOutR
				ConOutR("*PROCES*|FIM VALIDACOES2 | GRAVAÇÃO DO CT2")
			EndIf
		EndIf
	Endif

	If lDigita
		If __lConOutR
			ConOutR("*PROCES*|INICIO INTERFACE")
		EndIf
		nOpcA 		:= 0
		__PreLan 	:= .F.		// Indica se tenta gravar como pre-lancamento

		/* Nao pemite alteracao nos lancamentos complementares */
		If CTBLCUso()
			If AllTrim(TMP->CT2_ROTINA) == "__CTBLC__"
				nOpcA := 1
			Endif
		Endif

		lFlagMain := Type("oMainWnd")="U"

		While nOpcA == 0

			If lFlagMain
				//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lAntCtbGrv
					ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
				Endif

				If __lConOutR
					ConOutR("*PROCES*|INICIO CTBGRAVA3")
				EndIf

				// valida sem mostrar ajudas, caso tenha erro
				// marca para pre-lancamento
				cPreLcto	:= "N"
				If! CTB105Rpc(lDigita, @nQtdCntb)
					cPreLcto	:= "S"
				EndIf

				If FwGetRunSchedule() .Or. __lBlind
					Ct105TOK(lCT105TOK,lCT105CHK,.F., .F.,aTotRdpe,nTotInf,,,@aValDif)
					CtbChkDif(aValDif, @aCTKxCT2, cTabCTK)
				EndIf

				CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,	__lCusto,__lItem,__lCLVL, nTotInf,cProgName,;
						cPreLcto ,	dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,;
						,,,cHistCapLt)

				If __lConOutR
					ConOutR("*PROCES*|FIM CTBGRAVA3")
				EndIf

				//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lDepCtbGrv
					ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
				Endif

				//Dar ZAP no arquivo temporario para nao trazer residuos do documento anterior
				//dbSelectArea("TMP")
				//Zap
				If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo
					If ! CtbVerTmpBD()
						If __lTmp_Zap
							dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
							Zap
							dbGoTop()
						Else
							TMP->(DbCloseArea())
							FErase( cArq1+cDBSExt )
							Ferase( cArq1+cIndExt )
							Ferase( cArq2+cIndExt )
							cArq1 := ""
							cArq2 := ""
							Ctb105Cria(__aCampos,@cArq1,@cArq2)
						EndIf
					Else
						dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
						TcSqlExec(" Truncate Table "+ cArq1 )    //Zap
						DbCommitAll()
						TcRefresh(cArq1)
						dbgobottom()
						dbgotop()
					EndIf
				EndIf
				Exit
			Endif

			SetKey(VK_F4, { || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc) })
			SetKey(VK_F5, { || CTB105Flt (oGetDb,.F.                   ) })
			SetKey(VK_F6, { || CTB105Flt (oGetDb,.T.                   ) })
			SetKey(VK_F7, { || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil     ) })

			//Faz o calculo automatico de dimensoes de objetos
			oSize := FwDefSize():New(.T.)

			oSize:lLateral	:= .F.
			oSize:lProp		:= .T. // Proporcional

			oSize:AddObject( "1STROW" ,  100, 08, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "2NDROW" ,  100, 78, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "3RDROW" ,  100, 14, .T., .T. ) // Totalmente dimensionavel

			oSize:aMargins	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

			oSize:Process() // Dispara os calculos

			a1stRow := {	oSize:GetDimension("1STROW","LININI"),;
							oSize:GetDimension("1STROW","COLINI"),;
							oSize:GetDimension("1STROW","LINEND"),;
							oSize:GetDimension("1STROW","COLEND")}

			a2ndRow := {	oSize:GetDimension("2NDROW","LININI"),;
							oSize:GetDimension("2NDROW","COLINI"),;
							oSize:GetDimension("2NDROW","LINEND"),;
							oSize:GetDimension("2NDROW","COLEND")}

			a3rdRow := {	oSize:GetDimension("3RDROW","LININI"),;
							oSize:GetDimension("3RDROW","COLINI"),;
							oSize:GetDimension("3RDROW","LINEND"),;
							oSize:GetDimension("3RDROW","COLEND")}

			//calculo o centro objeto
			nCtr1stRow := a1stRow[1] + ((a1stRow[3] - a1stRow[1]) / 2)
			nCtr3rdRow := a3rdRow[1] + ((a3rdRow[3] - a3rdRow[1]) / 2)

			//defino as coordenadas das labels e dos campos.
			nLbl3rd1	:= nCtr3rdRow - 18
			nCmp3rd1	:= nCtr3rdRow - 20
			nLbl3rd2	:= nCtr3rdRow - 4
			nCmp3rd2	:= nCtr3rdRow - 6
			nLbl3rd3	:= nCtr3rdRow + 10
			nCmp3rd3	:= nCtr3rdRow + 8

			If lSeqCorr .OR. cPaisLoc == "ARG"
				nLbl1st1 := a1stRow[1] + 6
				nCmp1st1 := a1stRow[1] + 3
				nLbl1st2 := nCtr1stRow + 6
				nCmp1st2 := nCtr1stRow + 3
			Else
				nLbl1st1 := nCtr1stRow - 3
				nCmp1st1 := nCtr1stRow - 6
			EndIf

			DEFINE MSDIALOG oDlg TITLE cCadastro From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
			oDlg:lMaximized := .T.

			@ nLbl1st1, a1stRow[2] + 000 Say OemToAnsi(STR0091) SIZE 25,9 PIXEl OF oDlg FONT oFnt //"Filial"
			@ nCmp1st1 ,a1stRow[2] + 024 MSGET oFilial VAR cFilLanc PIXEl SIZE 42, 10 OF oDlg PIXEL WHEN .F.

			@ nLbl1st1, a1stRow[2] + 071 Say OemToAnsi(STR0002) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Data"
			@ nCmp1st1, a1stRow[2] + 088 MSGET dDataLanc  Picture "99/99/9999" SIZE 45, 10 OF oDlg PIXEL HASBUTTON When aMvs[MV_ALTLCTO] Valid (NaoVazio(dDataLanc) .and. ;
				C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,3,2)).And.CtbValiDt(nOpc,dDataLanc) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

			@ nLbl1st1, a1stRow[2] + 137 Say OemToAnsi(STR0003) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Lote"
			@ nCmp1st1, a1stRow[2] + 150 MSGET oLote VAR cLote Picture "@!" PIXEl SIZE 25, 10 OF oDlg When aMvs[MV_ALTLCTO];
				Valid NaoVazio(cLote) .and.;
				C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK) .And.;
				Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,;
				oDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

			@ nLbl1st1, a1stRow[2] + 180 Say OemToAnsi(STR0013) SIZE 30,9 PIXEl	OF oDlg FONT oFnt	//"Sub-Lote"
			@ nCmp1st1, a1stRow[2] + 204 MSGET cSubLote Picture "!!!" PIXEl SIZE 24, 10 OF oDlg WHEN If( !lSeqCorr, aMvs[MV_ALTLCTO] .And. lSubLote, .F.) F3 "SB";
				VALID NaoVazio(cSubLote) .and.;
				C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK) .And.;
				Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,;
				oDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

		  	@ nLbl1st1, a1stRow[2] + 237 Say OemToAnsi(STR0004) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Docto"
		  	@ nCmp1st1, a1stRow[2] + 253 MSGET cDoc Picture "999999" PIXEl SIZE 25, 10 OF oDlg When aMvs[MV_ALTLCTO];
				Valid NaoVazio(cDoc) .and.;
				Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,@CTF_LOCK,3) .And.;
				Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

			If lSeqCorr
		  		@ nLbl1st2 ,284 Say OemToAnsi(STR0014) PIXEl	OF oDlg SIZE 55,9 FONT oFnt	//"Correlativo"
		 		@ nCmp1st2 ,318 MSGET oDoc VAR cSeqCorr Picture PesqPict("CT2","CT2_NODIA") PIXEl	SIZE 80, 10 OF oDlg READONLY
			EndIf

			If cPaisLoc == "ARG" //Tratamento para o historico na capa do lote
		  		@ nLbl1st2 ,If(lSeqCorr,414,284) Say OemToAnsi(STR0068) PIXEl	OF oDlg SIZE 55,9 FONT oFnt	//"Historico"
		 		@ nCmp1st2 ,If(lSeqCorr,443,318) MSGET oHistCapLt VAR cHistCapLt Picture "@!" PIXEL SIZE 160, 10 OF oDlg
			EndIf

			TMP->(dbSetOrder(0))

			Ctb102TamHist()


			If aMvs[MV_ALTLCTO]
				oGetDB := MSGetDB():New( a2ndRow[1], a2ndRow[2], a2ndRow[3], a2ndRow[4], 4,"CT105LINOK", "CT105TOk", "+CT2_LINHA",.T.,aAltera,,.T., MAX_LINHA[2],"TMP",,,,oDlg,,,"CT102DEL(nOpc)")
				oGetDB:cSuperDel := "IIf(CT105SDEL(nOpc),(Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe),oGetDb:oBrowse:Refresh()),)"
			Else
				oGetDB := MSGetDB():New( a2ndRow[1], a2ndRow[2], a2ndRow[3], a2ndRow[4], 2,"AlwaysTrue", "AlwaysTrue", "+CT2_LINHA",	.F.,,,.T.,,"TMP",,,,oDlg,,,"CT102DEL(nOpc)")
			EndIf

			Ctb102TamHist(.T.)

			aTotMov	:= CtbTotMov()
			aTotais	:= Ctb050Tot(dDataLanc,cLote,cSubLote,cDoc)

			//Contem os saldos do CT6 + Conteudo da Tela
			aTotRdPe[1][2] := aTotMov[1][2]
			aTotRdPe[1][3] := aTotMov[1][3]
			aTotRdPe[1][1] := aTotMov[1][1]

			//Contem somente o que esta na GETDB.
			aTotRdPe[2][2] := aTotMov[1][2]
			aTotRdPe[2][3] := aTotMov[1][3]
			aTotRdPe[2][1] := aTotMov[1][1]

			nTotInf	:= aTotais[1][4]

			@ nLbl3rd1, a3rdRow[2] + 008  	SAY OemToAnsi(STR0012) Of oDlg PIXEL FONT oFnt //"Descri‡„o da Entidade"
			@ nCmp3rd1, a3rdRow[2] + 073 	SAY oDescEnt PROMPT space(50) FONT oDlg:oFont PIXEL COLOR CLR_HBLUE	Of oDlg

			@ nLbl3rd2, a3rdRow[2] + 008  	SAY OemToAnsi(STR0006) Of oDlg PIXEL FONT oFnt //"Total Informado :"
			@ nLbl3rd3, a3rdRow[2] + 008  	SAY OemToAnsi(STR0007) Of oDlg PIXEL FONT oFnt //"Total Digitado  :"
			@ nCmp3rd2, a3rdRow[2] + 065 	MSGET oInf VAR nTotInf Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
			@ nCmp3rd3, a3rdRow[2] + 065 	MSGET oDig VAR aTotRdpe[1][1] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL

			@ nLbl3rd2, a3rdRow[2] + 190 	SAY OemToAnsi(STR0008) Of oDlg PIXEL FONT oFnt //"Total Debito  :"
			@ nLbl3rd3, a3rdRow[2] + 190	SAY OemToAnsi(STR0009) Of oDlg PIXEL FONT oFnt //"Total Credito :"
			@ nCmp3rd2, a3rdRow[2] + 240	MSGET oDeb VAR aTotRdPe[1][2] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
			@ nCmp3rd3, a3rdRow[2] + 240	MSGET oCred VAR aTotRdPe[1][3] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL


			//ponto de entrada para usuario
			If lCT102DLG
				Execblock("CT102DLG",.f.,.f.)
			Endif

			If __lConOutR
				ConOutR("*PROCES*|FIM INTERFACE")
			EndIf

			ACTIVATE MSDIALOG oDlg ON INIT (	oGetDB:oBrowse:Refresh(),;
													EnchoiceBar(oDlg,{||nOpcA:=1,IIf(Ct105TOK(lCT105TOK,lCT105CHK,oGetDB:lModified,,aTotRdpe,nTotInf,,,@aValDif) .And.;
											       Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK,nOpc) .And.;
 											       Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK),oDlg:End(),nOpcA := 0)}, {||If(AllTrim(ProcName(1)) <> "CTBA102",MsgAlert(STR0057,STR0011),oDlg:End())},,aButton))//"Atencao"##"Para encerrar essa opcao e necessario confirmar ou excluir a(s) linha(s) de lancamento(s) contabil!"

		EndDo

		IF nOpcA == 1

			//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lAntCtbGrv
				ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
			Endif

			//Validacao
			//nQtdCntb - Variavel usada para identificar qntd de linhas de lançamentos para metricas
			lRpcOk	:= CTB105Rpc(lDigita, @nQtdCntb)

			If !lRpcOk .Or. __PreLan == .T.
				cPreLcto	:= "S"
			Else
				cPreLcto	:= "N"
			EndIf

			If __lConOutR
				ConOutR("*PROCES*|INICIO CTBGRAVA4")
			EndIf

			CtbChkDif(aValDif,@aCTKxCT2, cTabCTK)

			CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,__lCusto,__lItem,__lCLVL,nTotInf,cProgName,;
					cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,,,,;
					cHistCapLt)

			If __lConOutR
				ConOutR("*PROCES*|FIM CTBGRAVA4")
			EndIf
			// Qdo o usuario solicita que nao mostre a tela de lancto, a tela sera exibida somente qdo houver alguma nao conformidade no doc.
			// Se os documentos seguintes estiverem corretos a tela não será exibida.
			lDigita := IIf( lDigitaOri, .T.,.F.)
			//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lDepCtbGrv
				ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
			Endif

			//Dar ZAP no arquivo temporario para nao trazer residuos do documento anterior
			//dbSelectArea("TMP")
			//Zap
			If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo
				If ! CtbVerTmpBD()
					If __lTmp_Zap

						//quando chamado rotina com instrucao CtbIniLan mas nao criado temporario no banco, pois nao vai utilizar procedure
						//nao apagar arquivo temporario pois a rotina CtbFinLan sera responsavel pela exclusao na SYSTEM
						//CtbInilan devera ser chamada nas rotinas batch de contabilizacao para melhorar performance
						dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
						Zap
						dbGoTop()

					Else

						TMP->(DbCloseArea())
						FErase( cArq1+cDBSExt )
						Ferase( cArq1+cIndExt )
						Ferase( cArq2+cIndExt )
						cArq1 := ""
						cArq2 := ""
						Ctb105Cria(__aCampos,@cArq1,@cArq2)

					EndIf
				Else

					dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
					TcSqlExec(" Truncate Table "+ cArq1 )   //Zap
					DbCommitAll()
					TcRefresh(cArq1)
					dbgobottom()
					dbgotop()
				EndIf
			EndIf
		Endif
	EndIf
EndDo

If CTF_LOCK > 0					/// LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL
	dbSelectArea("CTF")
	dbGoTo(CTF_LOCK)
	CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
Endif

If Select(cAliasCTK) > 0 //.And. ! ( "INFORMIX" $ Alltrim(Upper(TCGetDB())) )
	(cAliasCTK)->(DbCloseArea())
Endif

DbSelectArea( "CT2" )
//somente fecha e apaga os arquivos TMP se nao utiliza a nova procedure de gravacao do CT2
If ! CtbVerTmpBD()

	If __lTmp_Zap
		//quando chamado rotina com instrucao CtbIniLan mas nao criado temporario no banco, pois nao vai utilizar procedure
		//nao apagar arquivo temporario pois a rotina CtbFinLan sera responsavel pela exclusao na SYSTEM
		//CtbInilan devera ser chamada nas rotinas batch de contabilizacao para melhorar performance
	Else
		//procedimento padrao a cada chamada da ca100Incl apaga os arquivos temporarios na SYSTEM
		TMP->(DbCloseArea())
		FErase( cArq1+cDbsExt )
		Ferase( cArq1+cIndExt )
		Ferase( cArq2+cIndExt )
	EndIf

Else

	dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
	TcSqlExec(" Truncate Table "+ cArq1 )   //Zap
	DbCommitAll()
	TcRefresh(cArq1)
	dbgobottom()
	dbgotop()
EndIf
//
// Restaurando ou Desabilitando as teclas de função utilizadas nesta função, que foram F4, F5, F6 e F7
//
If bVK_4 == NIL
	Set Key VK_F4 to
Else
	SetKey(VK_F4,bVK_4)
EndIf
If bVK_5 == NIL
	Set Key VK_F5 to
Else
	SetKey(VK_F5,bVK_5)
EndIf
If bVK_6 == NIL
	Set Key VK_F6 to
Else
	SetKey(VK_F6,bVK_6)
EndIf
If bVK_7 == NIL
	Set Key VK_F7 to
Else
	SetKey(VK_F7,bVK_7)
EndIf

If dReproc <> Nil .AND. GetMv( "MV_ATUSAL" )== "S"
	If aTpSaldo == Nil .Or. Len( aTpSaldo ) == 0
		aTpSaldo := {"1"}	//	Reprocessar ao menos o tipo de saldo 1-Real
	EndIf

	If lSimula
		dbSelectArea("SIX")
		dbSetOrder(1)		//INDICE+ORDEM
		dbGoTop()
		If SIX->(dbSeek("CT21"))
			cChaveCT2 := AllTrim(SIX->CHAVE)
			IndRegua("CT2", cTabCT2, cChaveCT2, , , )
		EndIf
		dbSelectArea("CT2")
	Else
		CT2->(DbSetOrder(1))
	EndIf

	CT2->(DbSeek(Soma1(xFilial()), .T.))	// Procuro a proxima filial
	CT2->(DbSkip(-1))						// Volto para o registro anterior
	dCt2Data := CT2->CT2_DATA

	If !lSimula
		For nTipoSaldo := 1 to Len( aTpSaldo )
			If CT2->CT2_FILIAL = xFilial("CT2") .And. dCt2Data > dReproc
				CTBA190(.T.,dReproc,dCt2Data,cFilAnt,cFilAnt,aTpSaldo[nTipoSaldo],.F.,"  ")
			Else
				CTBA190(.T.,dReproc,dReproc,cFilAnt,cFilAnt,aTpSaldo[nTipoSaldo],.F.,"  ")
			Endif
		Next
	EndIf
Endif

RestArea(aSaveArea)

If lM330Proc .And. cRotina$"MATA330/MATA331/MATA333"
	aMVS[MV_ALTLCTO] := Nil
	aMVS[MV_PRELAN]	 := Nil
EndIf

PutHFile("")

If __lConOutR
	ConOutR("*LOGFIM*|FIM CTBA105",.T.)
EndIf

// efetua a limpeza dos caches da rotina
If __ClearCx
	ClearCx105()
Endif


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lancamento de complementar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If CTBLCUso()
	If (Type("__aCT2LC") == "A") .And. !Empty(__aCT2LC)
		CTBLCGerLC()
	Endif
Endif

//Envio de metricas
If lRpcOK .And. nQtdCntb > 0 .And. __lMetric

	/*Armazenamento de metricas
	cEvent == '01' - Metrica de tempo de execução
	cEvent == '02' - Metrica quantidade de registros
	*/

		CTB105Metrics("01" /*cEvent*/, nStart , "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/, /* nQtdReg */)
		CTB105Metrics("02" /*cEvent*/, /* nStart */, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/, nQtdCntb /* nQtdReg */)
	EndIf


Return .T.

//--------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function RdPrvVar(nHdlPrv,nTotal,aDadosProva)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Assume dados de aDadosProva caso os mesmos tenham sido       ³
//³ enviados                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aDadosProva) == "A"
		__HeadProva:=ACLONE(aDadosProva)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravar o TOTAL do Arquivo gerado                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If __HeadPRova[5] >= 0 .and. !CtbInUse()
		fWrite(__HeadProva[5],Str(nTotal,16,2)+Space(292)+"FF"+CHR(13)+CHR(10),312)
		dbCommit()
	EndIf

Return .t.

//--------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function DtPrvVar(nHdlPrv,cPadrao,cPrograma,cLote,nLinha,lExecuta,cCriterio,lRateio,	;
		cChaveBusca,aCT5,lPosiciona,aFlagCTB,aTabRecOri,aDadosProva,lSimula,;
		cTabCTK,cTabCT2,cTabCV3,cCtaRec)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na contabilizacao via CTB               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea      := GetArea()
	Local cAliasPos	 := Alias()
	Local aStruCT5   := CT5->(dbStruct())
	Local aStruCTK   := CTK->(dbStruct())
	Local aVlrCT5    := {}
	Local cAliasCT5  := "CT5"
	Local cQuery     := ""
	Local cSeqChave  := ""
	Local cCampoCTK  := ""
	Local cCampoCT5  := ""
	Local cValor     := ""
	Local cHistorico := ""
	Local cHist      := ""
	Local cHAglut	 := ""
	Local lQuery     := .F.
	Local nContador  := 0
	Local nValor     := 0
	Local nTotal     := 0
	Local nPosCtk    := 0
	Local nPosCt5    := 0
	Local nPLanpad   := 0
	Local nPSequen   := 0
	Local nPSbLote   := 0
	Local nPHist     := 0
	Local nPHAglut	 := 0
	Local nPTpSald	 := 0
	Local nPMoedLC	 := 0
	Local nPOrigem	 := 0
	Local nPosCtaRec := 0
	Local nX         := 0
	Local nY         := 0
	Local nZ         := 0
	Local nLen       := 0
	Local nSaveSX8	:= GetSX8Len()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na contabilizacao via SIGACON           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aContas    := Array(30)
	Local RetcProva  := {}
	Local n          := 0
	Local cSet       := ""
	Local cValor1    := ""
	Local cValor2    := ""
	Local cValor3    := ""
	Local cValor4    := ""
	Local cValor5    := ""
	Local nPosAFlag  := 0
	Local lAchouCTK
	Local cTabOrigem := ""
	Local nRecOrigem := 0
	Local lAS400	 := TcSrvType() == "AS/400"
	Local lPls

	Static lCT5TABORI := Nil
	Static lCT5RECORI := Nil
	Static lCTKTABORI := Nil
	Static lCTKRECORI := Nil
	Static lCTKRECDES := Nil
	Static lCTKRECCV3 := Nil
	Static lCV3TABORI := Nil
	Static lCV3RECORI := Nil
	Static lCV3RECDES := Nil

	Default lPosiciona 	:= .T.
	Default lSimula		:= .F.
	Default cTabCTK 	:= "CTK"
	Default cTabCT2 	:= "CT2"
	Default cTabCV3 	:= "CV3"
	Default cCtaRec		:= "" //Conta de Receita - Utilizada para o EFD-Contribuicoes

	If __cEFDetProva == Nil .Or. !(__cEFDetProva==cEmpAnt+cFilAnt)
		__cEFDetProva := cEmpAnt+cFilAnt
		__MV_PLSATIV := GetNewPar("MV_PLSATIV",.F.)
	EndIf

	If __MV_PLSATIV <> Nil
		lPls := __MV_PLSATIV
	EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Assume dados de aDadosProva caso os mesmos tenham sido       ³
//³ enviados                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aDadosProva) == "A"
		__HeadProva:=ACLONE(aDadosProva)
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o arquivo de de contra-prova foi criado correta- ³
//³ mente.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If __HeadProva[5] == -1
		Return(0)
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os parametros default's da funcao                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFAULT lRateio	 := .F.
	DEFAULT lExecuta := .T.
	DEFAULT cCriterio:= Space(8)
	DEFAULT nLinha   := 0
	DEFAULT aCT5     := {}

	PUBLIC LanceiCtb := .F.

	If ( __lHasCTKSxe == NIL )
		__lHasCTKSxe := FindFunction('HASCTKSXE')
	EndIf

	If (__Ct105Ctk == Nil)
		__Ct105CTK := ExistBlock("CT105CTK")
	Endif

	If __lConOutR == Nil
		__lConOutR := FindFunction("CONOUTR")
	EndIf

	cPrograma := PadR(AllTrim(UPPER(cPrograma)),10)

	If __lConOutR
		ConOutR("*DETPROVAINI*|INICIO DA MONTAGEM DO DETPROVA.|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
	EndIf

	If lPls
		If "FIN" $ cPrograma
			If __lPLSDETPR == Nil
				__lPLSDETPR := findFunction("PLSDETPR")
			EndIf
		EndIf
	EndIf

//Não contabiliza registro do PLS nas ROTINAS do BACKOFFICE
	if __lPLSDETPR

		if PLSDETPR( cPadrao, cTabOrigem, cAliasPos, @aFlagCTB )
			Return(0)
		endIf

	endIf

	If __lCWOInDic == NIL
		__lCWOInDic := Iif(AliasInDic("CWO"), .T., .F.)
	Endif
	If __lCWOInDic
	/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Prepara y inicializa las tablas que usará cada punto de asieto³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		POSTABCTB(cPadrao)
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual o metodo de contabilizacao deve ser feito:     ³
//³ CTB ou CON.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !CtbInUse()
		//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
		// Fun‡„o de DETALHE no m¢dulo Cont bil - SIGACON
		// Grava‡„o dos Detalhes em Arquivo no Disco (\CPROVA)
		//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
		cSet := Set(_SET_DATEFORMAT)
		Set(_SET_DATEFORMAT,"dd/mm/yyyy")
	/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³               ARQUIVO DE LOG-LANC AUT                   ³
		³               Mem¢ria de Calculos                       ³
		ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		³                 HEADER DO ARQUIVO                       ³
		³ Descricao       Tamanho     Pos Ini     Pos Fim         ³
		ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		³ Marca de In¡cio    002       001         002            ³
		³ Data Base          010       003         013            ³
		³ Lote               004       014         018            ³
		³ Programa           008       019         027            ³
		³ Operador           006       028         034            ³
		³ Filial             002       035         037            ³
		³ Filler             278       038         260            ³
		ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		³                 DETALHE DO ARQUIVO                      ³
		³ Descricao       Tamanho     Pos Ini     Pos Fim         ³
		ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		³ Tipo Lancamento    001       001         001            ³
		³ Codigo da Conta    020       002         021            ³
		³ Contra Partida     020       022         041            ³
		³ Valor Moeda 1      016       042         057            ³
		³ Moedas             005       058         062            ³
		³ Historico          040       063         102            ³
		³ Valor Moeda 2      016       103         118            ³
		³ Valor Moeda 3      016       119         134            ³
		³ Valor Moeda 4      016       135         150            ³
		³ Valor Moeda 5      016       151         166            ³
		³ C Custo Debito     009       167         175            ³
		³ C Custo Credito    009       176         184            ³
		³ Cod/Seq Lanc Pad   005       185         189            ³
		³ Data de Vencimento 010       190         199            ³
		³ Origem do lanc.    040       200         239            ³
		³ Ident Inter CP     001       240         240            ³
		³ Nome do Programa   010       241         250            ³
		³ Item Debito        009       251         259            ³
		³ Item Credito       009       260         268            ³
		³ Filler             042       269         310            ³
		ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		³                TOTALIZADOR DO ARQUIVO                   ³
		³ Descricao       Tamanho     Pos Ini     Pos Fim         ³
		ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		³  Valor Total       016       001         016            ³
		³  Filler            294       017         300            ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*/
		DbSelectArea("SI5")
		dbSetOrder(1)
		DbSeek(cFilial+cPadrao)
		While !Eof() .And. I5_FILIAL == cFilial .And. cPadrao==I5_CODIGO

			aContas[1]:=I5_DC
			aContas[4] :=0
			aContas[7] :=0
			aContas[8] :=0
			aContas[9] :=0
			aContas[10]:=0

			cValor1 :=Trim(I5_CPOVAL1)
			cValor2 :=Trim(I5_CPOVAL2)
			cValor3 :=Trim(I5_CPOVAL3)
			cValor4 :=Trim(I5_CPOVAL4)
			cValor5 :=Trim(I5_CPOVAL5)


			If cCriterio $ "FINA050/FINA100"
				If lExecuta
					If AllTrim(Upper(cValor1)) == "VALOR" .or. "VLRINSTR" $ Upper(cValor1)
						DbSkip()
						Loop
					End
				EndIf
				If !lExecuta
					If ! (AllTrim(Upper(cValor1)) == "VALOR" .or. "VLRINSTR" $ Upper(cValor1))
						DbSkip()
						Loop
					End
				End
			End

			If !Empty(cValor1)
				aContas[4]:=&(cValor1)
			End
			If !Empty(cValor2)
				aContas[7]:=&(cValor2)
			EndIf
			If !Empty(cValor3)
				aContas[8]:=&(cValor3)
			EndIf
			If !Empty(cValor4)
				aContas[9]:=&(cValor4)
			EndIf
			If !Empty(cValor5)
				aContas[10]:=&(cValor5)
			EndIf


			If GetMv("MV_CTVALZR") == "N"
				nValor := aContas[4]
			Else
				nValor := aContas[4]+aContas[7]+aContas[8]+aContas[9]+aContas[10]
			EndIf

			cHistorico:=AllTrim(TranslCta(I5_HISTORI,240))

			If (aContas[1] == "-" .Or. nValor > 0)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ VerIfica se na Conta devera estar o Debito ou Credito³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aContas[2] :=TranslCta(I5_DEBITO, 20)  //Interpreta d‚bito
				aContas[3] :=TranslCta(I5_CREDITO,20)  //Interpreta cr‚dito
				aContas[17]:=TranslCta(I5_ITEMD,9)
				aContas[18]:=TranslCta(I5_ITEMC,9)

				If __HeadProva[5] == -5
					//
					// Cria o cabe‡alho do lan‡amento cont bil caso n„o tenha sido criado
					//
					RetcProva := CriaCProva(__HeadProva[1],__HeadProva[2],__HeadProva[3],lSimula)

					__HeadProva[4] := RetcProva[1]	// Nome do Arquivo
					__HeadProva[5] := RetcProva[2]	// Handle do Arquivo
				EndIf
				nHdlPrv := __HeadProva[5]

				aContas[5]:=I5_MOEDAS
				LanceiCtb := .T.
				If Len(cHistorico) > 40
					For n := 1 to Len(cHistorico) Step 40
						cHist := Substr(cHistorico,n,40)
						aContas[6] := cHist + Space(40 - Len(cHist))
						If n == 1
							aContas[11] :=TranslCta(I5_CCD, 9)      //Interpreta C.Custo D‚bito
							aContas[12] :=TranslCta(I5_CCC, 9)      //Interpreta C.Custo Cr‚dito
							aContas[13] :=I5_CODIGO+I5_SEQUENC
							aContas[14] :=TranslDta(I5_DTVENC)      //Interpreta data de vencimento
							aContas[15] :=TranslCta(I5_ORIGEM,40)   //Interpreta a origem
							aContas[16] :=Substr(I5_INTERCP,1,1)      //Inter Company
							aContas[17] :=TranslCta(I5_ITEMD,9)     // Item Debito
							aContas[18] :=TranslCta(I5_ITEMC,9)     // Item Credito
						Else
							aContas[1]  := "-"
							aContas[2]  := Space(20)
							aContas[3]  := Space(20)
							aContas[4]  := 0
							aContas[7]  := 0
							aContas[8]  := 0
							aContas[9]  := 0
							aContas[10] := 0
							aContas[11] := Space(9)
							aContas[12] := Space(9)
							aContas[13] := I5_CODIGO+I5_SEQUENC
							aContas[14] := TranslDta(I5_DTVENC)       //Interpreta data de vencimento
							aContas[15] := TranslCta(I5_ORIGEM,40)    //Interpreta a origem
							aContas[16] := Substr(I5_INTERCP,1,1)     //Inter Company
							aContas[17] := Space(9)
							aContas[18] := Space(9)
						EndIf
						FWRITE(nHdlPrv,aContas[1]+aContas[2]+aContas[3]+;
							Str(aContas[4],16,2)+aContas[5]+aContas[6]+;
							Str(aContas[7],16,2)+Str(aContas[8],16,2)+;
							Str(aContas[9],16,2)+Str(aContas[10],16,2)+;
							aContas[11]+aContas[12]+aContas[13]+aContas[14]+;
							aContas[15]+aContas[16]+cPrograma+aContas[17]+;
							aContas[18]+Space(42)+CHR(13)+CHR(10),312)
						nTotal += nValor
					Next n
				Else
					aContas[6]  := cHistorico + Space(40 - Len(cHistorico))
					aContas[11] := TranslCta(I5_CCD, 9)     //Interpreta C.Custo D‚bito
					aContas[12] := TranslCta(I5_CCC, 9)     //Interpreta C.Custo Cr‚dito
					aContas[13] := I5_CODIGO+I5_SEQUENC
					aContas[14] := TranslDta(I5_DTVENC)  //Interpreta data de vencimento
					aContas[15] := TranslCta(I5_ORIGEM,40)    //Interpreta a origem
					aContas[16] := Substr(I5_INTERCP,1,1)   //Inter Company
					aContas[17] := TranslCta(I5_ITEMD,9)    //Item Debito
					aContas[18] := TranslCta(I5_ITEMC,9)    //Item Credito
					FWRITE(nHdlPrv,aContas[1]+aContas[2]+aContas[3]+;
						Str(aContas[4],16,2)+aContas[5]+aContas[6]+;
						Str(aContas[7],16,2)+Str(aContas[8],16,2)+;
						Str(aContas[9],16,2)+Str(aContas[10],16,2)+;
						aContas[11]+aContas[12]+aContas[13]+aContas[14]+;
						aContas[15]+aContas[16]+cPrograma+aContas[17]+;
						aContas[18]+Space(42)+CHR(13)+CHR(10),312)
					nTotal+=nValor
				EndIf
			EndIf
			DbSelectArea("SI5")
			nLinha++
			DbSkip()
		EndDo
		Set(_SET_DATEFORMAT,cSet)
	Else
		//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
		//  Fun‡„o de DETALHE no m¢dulo SIGACTB -> Contabilidade Gerencial
		//  Grava‡„o dos dados na tabela CTK
		//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
		DEFAULT cPrograma := FunName()
		DEFAULT aFlagCTB := {}
		nPosAFlag := Len(aFlagCTB)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a tabelas do SIGACTB estao disponiveis           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Select("CTK") == 0
			ChkFile("CTK")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe moeda cadastrada no SIGACTB                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aVlrCT5 := Array(__nQuantas)
		//Se nao existir moeda cadastrada no SIGACTB.
		If Len(aVlrCT5) = 0
			MsgAlert("Nao existe nenhuma moeda cadastrada no modulo SIGACTB.")	//Nao existe nenhuma moeda cadastrada no modulo SIGACTB.
			Return(0)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se esta configurada a configuração de lançamentos on line   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FindFunction( "CTBCFGLANC" ) .And. !lSimula .And. !IsBlind()
			CtbCfgLanc(cPadrao)
		EndIF

		#IFDEF TOP
			If !lAS400				///SE NÃO FOR AS/400
				If lCTKRECORI == Nil
					lCTKRECORI := CTK->(FieldPos("CTK_RECORI") > 0)
				Endif
				If lCTKTABORI == Nil
					lCTKTABORI := CTK->(FieldPos("CTK_TABORI") > 0)
				Endif
				If lCTKRECDES == Nil
					lCTKRECDES := CTK->(FieldPos("CTK_RECDES") > 0)
				Endif
				If lCTKRECCV3 == Nil
					lCTKRECCV3 := CTK->(FieldPos("CTK_RECCV3") > 0)
				Endif
				If lCV3TABORI == Nil
					lCV3TABORI := CV3->(FieldPos("CV3_TABORI") > 0)
				Endif
				If lCV3RECORI == Nil
					lCV3RECORI := CV3->(FieldPos("CV3_RECORI") > 0)
				Endif
				If lCV3RECDES == Nil
					lCV3RECDES := CV3->(FieldPos("CV3_RECDES") > 0)
				Endif

				/// VERIFICA SE TODOS OS CAMPOS FORAM CRIADOS PARA RASTREAMENTO SEM CONFIGURACAO
				If lCTKTABORI .or. lCTKRECORI .or. lCTKRECDES .or. lCTKRECCV3  .or. lCV3TABORI  .or. lCV3RECORI .or. lCV3RECDES
					If !( lCTKTABORI .and. lCTKRECORI .and. lCTKRECDES .and. lCTKRECCV3  .and. lCV3TABORI  .and. lCV3RECORI .and. lCV3RECDES )
						If IsBlind()
							CONOUT("DETPROVA-MATXFUNA - Verify Fields: CTK_TABORI,CTK_RECORI,CTK_RECDES,CTK_RECCV3,CV3_TABORI,CV3_RECORI,CV3_RECDES.")
						Else
							MsgInfo("Campos de rastreamento de lançamentos e remarcação de flags."+CRLF+;
								"Verifique criacao campos: "+CRLF+;
								"CTK_TABORI (Char - 3)"+CRLF+;
								"CTK_RECORI (Char - 17)"+CRLF+;
								"CTK_RECDES (Char - 17)"+CRLF+;
								"CTK_RECCV3 (Char - 17)"+CRLF+;
								"CV3_TABORI (Char - 3)"+CRLF+;
								"CV3_RECORI (Char - 17)"+CRLF+;
								"CV3_RECDES (Char - 17).","Lançamento Contabil - ATENCAO ! Administrador.")
							//STR0043="Campos de rastreamento de lançamentos e remarcação de flags."
							//STR0044="Verifique criacao campos: "
							//STR0045="Lançamento Contabil - ATENCAO ! Administrador."
						EndIf
					EndIf
				EndIf
			EndIf
		#ENDIF

		If __lConOutR
			ConOutR("*DETPROVA*|INIF|ARQUIVOS DE REGRAS PARA DRILL DOWN.|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivos de regras para drill down                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cChaveBusca == Nil
			If !lSimula
				cChaveBusca := CtRelation(cPadrao,lPosiciona)
			Else
				cChaveBusca := ""
			EndIf
		EndIf

		If __lConOutR
			ConOutR("*DETPROVA*|FINF|ARQUIVOS DE REGRAS PARA DRILL DOWN.|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
			ConOutR("*DETPROVA*|INIF|PESQUISA OS LANCAMENTOS PADROES A SEREM EXECUTADOS|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa os lancamentos padroes a serem executados           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nX := aScan(aCT5,{|x| x[1] == cPadrao})
		If nX == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa o array de otimizacao dos lancamentos padronizados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aCT5,{cPadrao,{}})
			nX := Len(aCT5)

			DbSelectArea("CT5")
			dbSetOrder(1)
			#IFDEF TOP
				If !lAS400				///SE NÃO FOR AS/400
					lQuery   := .T.
					cAliasCT5:= "DETPROVA"

					cQuery := ""
					For nY := 1 To Len(aStruCT5)
						cQuery += ","+aStruCT5[nY][1]
					Next nY
					cQuery := "SELECT "+SubStr(cQuery,2)+" "
					cQuery += "FROM "+RetSqlName("CT5")+" CT5 "
					cQuery += "WHERE CT5.CT5_FILIAL='"+xFilial("CT5")+"' AND "
					cQuery += "CT5.CT5_LANPAD='"+cPadrao+"' AND "
					cQuery += "CT5.D_E_L_E_T_=' ' "
					cQuery += "ORDER BY "+SqlOrder(CT5->(IndexKey()))

					//RETIRADO PARA PERFORMANCE - ANSI NAO HA NECESSIDADE DE PASSAR PELA CHANGEQUERY
					If ! ( Alltrim(Upper(TCGetDB())) $ "MSSQL|MSSQL7|ORACLE" )
						cQuery := ChangeQuery(cQuery)
					EndIf

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT5,.T.,.T.)

					For nY := 1 To Len(aStruCT5)
						If aStruCT5[nY][2] <> "C" .and. aStruCT5[nY][2] <> "M"
							TcSetField(cAliasCT5,aStruCT5[nY][1],aStruCT5[nY][2],aStruCT5[nY][3],aStruCT5[nY][4])
						EndIf
					Next nY
				Else
				#ENDIF
				MsSeek(xFilial("CT5")+cPadrao)
				#IFDEF TOP
				EndIf
			#ENDIF
			nZ := 0

			If __lConOutR
				ConOutR("*DETPROVA*|FINF|PESQUISA OS LANCAMENTOS PADROES A SEREM EXECUTADOS|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
				ConOutR("*DETPROVA*|INIF|ADICIONANDO NA ARRAY OS LANCAMENTOS PADROES A SEREM EXECUTADOS|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
			EndIf

			While !Eof() .And. (cAliasCT5)->CT5_FILIAL == xFilial("CT5") .And.;
					cPadrao == (cAliasCT5)->CT5_LANPAD

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Indica que o lancamento padrao esta inativo                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If CT5->(FieldPos("CT5_STATUS") > 0)
					If (cAliasCT5)->CT5_STATUS == "2"
						dbSelectArea(cAliasCT5)
						dbSkip()
						Loop
					EndIf
				EndIf

				nZ++
				aadd(aCT5[nX][2],{})
				For nY := 1 To (cAliasCT5)->(FCount())
					aadd(aCT5[nX][2][nZ],{(cAliasCT5)->(FieldName(nY)),(cAliasCT5)->(FieldGet(nY))})
				Next nY

				dbSelectArea(cAliasCT5)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasCT5)
				dbCloseArea()
				dbSelectArea("CT5")
			EndIf

			If __lConOutR
				ConOutR("*DETPROVA*|FINF|ADICIONANDO NA ARRAY OS LANCAMENTOS PADROES A SEREM EXECUTADOS|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
			EndIf
		EndIf

		//Essa condicao foi incluida, porque quando o arquivo CT5 estava em branco, sem
		//nenhum lancamento padrao cadastrado, ocorria erro de "Array out of bound"
		If Len(aCt5[nX,2]) > 0
			If __lConOutR
				ConOutR("*DETPROVA*|INIF|TRATAMENTO DOS LPS DA ARRAY|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
			EndIf

			// Ponto de entrada para tratamento do conteudo do CT5
			If Existblock("CT5CPOS") .And. !lSimula
				Execblock("CT5CPOS",.F.,.F.,{aCT5[nX]})
			Endif

			#IFDEF TOP
				If !lAS400				///SE NÃO FOR AS/400
					/////////////////////////////////////////////////////////////////////////////////////////////
					/// TRATAMENTO PARA O RASTREAMENTO DO REGISTRO DE ORIGEM DO LANÇAMENTO INDEPENDENTE DE CHAVE
					/////////////////////////////////////////////////////////////////////////////////////////////
					/// SE A TABELA E RECNO DE ORIGEM FORAM PASSADOS NA DETPROVA ...
					If ValType(aTabRecOri) == "A" .and. Len(aTabRecOri) > 0
						cTabOrigem := aTabRecOri[1]
						nRecOrigem := aTabRecOri[2]
					EndIf

					If lCT5TABORI == Nil
						lCT5TABORI := CT5->(FieldPos("CT5_TABORI") > 0)		/// TABELA DE ORIGEM DO LANÇAMENTO
					Endif
					If lCT5RECORI == Nil
						lCT5RECORI := CT5->(FieldPos("CT5_RECORI") > 0)		/// IDENTIFICADOR DE REGISTRO NA ORIGEM
					Endif

					/// SE A TABELA OU RECNO DE ORIGEM ESTIVEREM EM BRANCO - VERIFICA SE EXISTE REGRA NOS CAMPOS DO CT5 ...
					If (Empty(cTabOrigem) .or. nRecOrigem <= 0) .and. lCT5TABORI .and. lCT5RECORI
						nPT5TABORI := aScan( aCT5[nX,2][1], {|x| x[1] == "CT5_TABORI" })
						nPT5RECORI := aScan( aCT5[nX,2][1], {|x| x[1] == "CT5_RECORI" })
						If nPT5TABORI > 0 .and. nPT5RECORI > 0
							cTabOrigem := &(AllTrim(aCT5[nX,2][1][nPT5TABORI][2]))
							nRecOrigem := iif(empty((AllTrim(aCT5[nX,2][1][nPT5RECORI][2]))),0,Val(&(AllTrim(aCT5[nX,2][1][nPT5RECORI][2]))))
							If ValType(nRecOrigem) <> "N"
								nRecOrigem := 0
							EndIf
						EndIf
					EndIf

					//////////////////////////////////////////////////////////////////////
					/// TRATAMENTO PARA O RASTREAMENTO DO REGISTRO DE ORIGEM DO LANÇAMENTO
					//////////////////////////////////////////////////////////////////////
					If (Empty(cTabOrigem) .or. nRecOrigem <= 0) .and. (lCTKRECORI .AND. lCTKTABORI) .And. !lSimula
						/// SE TABELA OU RECNO AINDA ESTIVEREM EM BRANCO - VERIFICA REGRA PADRAO DE ACORDO COM O LP ...
						nRecOrigem := RetRecnoLP(cPadrao,@cTabOrigem,cAliasPos)
					EndIf
				EndIf
			#ENDIF
			If __lConOutR
				ConOutR("*DETPROVA*|FINF|TRATAMENTO DOS LPS DA ARRAY|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Execucao dos lancamentos padronizados                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPLanpad   := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_LANPAD"})
			nPSequen   := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_SEQUEN"})
			nPSbLote   := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_SBLOTE"})
			nPHist     := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_HIST"})
			nPHAglut   := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_HAGLUT"})
			nPMoedLC   := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_MOEDLC"})
			nPTpSald   := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_TPSALD"})
			nPOrigem   := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_ORIGEM"})

			If __lConOutR
				ConOutR("*DETPROVA*|INIF|EXECUTANDO AS REGRAS DOS LPS E GERANDO A CONTRA-PROVA|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
			EndIf
			For nY := 1 To Len(aCT5[nX,2])

				aVlrCT5   := AFill(aVlrCT5,0)
				nContador := 0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se nao for continuacao de historico                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosCT5 := aScan(aCT5[nX,2][nY],{|x| x[1] == "CT5_DC"})
				If aCT5[nX,2][nY][nPosCT5][2] <> "4"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existem valores a serem contabilizados.          ³
					//³                                                              ³
					//³ Como os valores podem ser expressoes complexas estes sao     ³
					//³ armazenados na variavel aVlrCt5 para que nao haja necessidade³
					//³ de serem executados novamente.                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nZ := 1 To __nQuantas
						nValor    := 0
						cCampoCT5 := "CT5_VLR"+StrZero(nZ,2)
						nPosCT5 := aScan(aCT5[nX,2][nY],{|x| x[1] == cCampoCT5 })
						If nPosCT5 > 0
							cValor := AllTrim(aCT5[nX,2][nY][nPosCT5][2])
							nValor := &(cValor)
							aVlrCT5[nZ] := nValor
							nTotal += nValor
						EndIf
					Next nZ
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se houver valores para contabilizar                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nContador <> __nQuantas
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cria semaforo para lancamento na tabela de contra-prova      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If __HeadProva[5] == -5

						CTK->(DbSetOrder(1))


						If __lConOutR
							ConOutR("*DETPROVA*|INIF|BUSCANDO A CHAVE DE SEQUENCIA DE CONTABILIZAçãO|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
						EndIf

						lAchouCTK := .T.
						// Gerar o codigo para a sequencia do lancamento. Se o codigo gerado ja foi utilizado,
						// despreza-lo e continuar gerando ate encontrar um que nao exista no CTK.
						While lAchouCTK
							If ( ! __lHasCTKSxe )
								cSeqChave := GetSx8Num("CTK","CTK_SEQUEN",,1)
							Else
								cSeqChave := GetSx8Num("_CT")
							EndIf

							lAchouCTK := CTK->( MsSeek( xFilial("CTK")+cSeqChave,.F. ) )

							If __lConOutR .AND. lAchouCTK
								ConOutR("*DETPROVA*|ERRO|BUSCANDO A CHAVE DE SEQUENCIA DE CONTABILIZAçãO|PROGRAMA|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|" + cSeqChave )
							Endif
						End

						__HeadProva[4] := cSeqChave		// Sequencia de Lan‡amento
						__HeadProva[5] := 1024			// Handle FIXO

						If __lConOutR
							ConOutR("*DETPROVA*|FINF|BUSCANDO A CHAVE DE SEQUENCIA DE CONTABILIZAçãO|PROGRAMA|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|" + cSeqChave )
						EndIf
					Else
						cSeqChave  := __HeadProva[4]
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicia a gravacao da tabela de contra-prova                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("CTK")


					DbSetOrder(1)

					If __lConOutR
						ConOutR("*DETPROVA*|INIF|GRAVANDO CONTRA-PROVA|PROGRAMA|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
					EndIf

					RecLock("CTK",.T.)
					#IFDEF TOP
						If !lAS400				///SE NÃO FOR AS/400
							If lCTKTABORI
								CTK->CTK_TABORI	:= cTabOrigem
							EndIf
							If lCTKRECORI
								CTK->CTK_RECORI	:= ALLTRIM(STR(INT(nRecOrigem)))
							EndIf
						EndIf
					#ENDIF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ As tabelas CTK e CT5 possuem campos comuns. Desta maneira    ³
					//³ devem ser repassado para os campos da tabela CTK os valores  ³
					//³ contidos nos campos da tabela CT5.                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nPosCtk := 1 To CTK->(FCount())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Obtem o nome do campo de destino na tabela CTK               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cCampoCTK := CTK->(FieldName(nPosCTK))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Obtem o nome do campo de origem na tabela CT5                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cCampoCT5 := "CT5_" + SubStr(cCampoCTK,5)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Transfere os valores do campo                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosCT5 := aScan(aCT5[nX,2][nY],{|x| x[1] == cCampoCT5 })
						If nPosCT5 > 0
							Do Case
							Case SubStr(cCampoCT5,1,7)=="CT5_VLR"
								nValor := Val(SubStr(cCampoCT5,8,2))
								If nValor <= Len(aVlrCT5)
								EndIf
							Case aStruCTK[nPosCTK][2] == "N"
								cValor	:= AllTrim(aCT5[nX,2][nY][nPosCT5][2])
								If !Empty(cValor)
									nValor := &(cValor)
									CTK->(FieldPut(nPosCTK,nValor))
								Else
									CTK->(FieldPut(nPosCTK,0))
								EndIf
							Case aStruCTK[nPosCTK][2] == "C"
								If !(cCampoCT5 $ "CT5_USERGI/CT5_USERGA/CT5_TABORI/CT5_RECORI")
									If cCampoCT5 == "CT5_SBLOTE"
										cValor := aCT5[nX,2][nY][nPosCT5][2]
									ElseIf cCampoCT5 == "CT5_FILIAL"
										cValor := xFilial("CTK")
									ElseIf cCampoCT5 == "CT5_TPSALD"
										cValor := aCT5[nX,2][nY][nPosCT5][2]
									ElseIf cCampoCT5 == "CT5_MLTSLD"
										cValor := aCT5[nX,2][nY][nPosCT5][2]
									ElseIf cCampoCT5 == "CT5_CTRLSD"
										cValor := aCT5[nX,2][nY][nPosCT5][2]
									ElseIf cCampoCT5 == "CT5_SEQUEN"
										cValor := aCT5[nX,2][nY][nPosCT5][2]
									Else
										cValor := AllTrim(TransLcta(aCT5[nX,2][nY][nPosCT5][2],240))
										If cCampoCT5 == "CT5_HIST"
											cHistorico := cValor
										ElseIf cCampoCT5 == "CT5_HAGLUT"
											If Empty(cValor) // SE HAGLUT ESTIVER EM BRANCO ASSUME HISTORICO.
												cValor := cHistorico
											EndIf
											cHAglut := cValor
										EndIf
									EndIf
									CTK->(FieldPut(nPosCTK,cValor))
								EndIf
							Case aStruCTK[nPosCTK][2] == "D"
								cValor := Ctod(AllTrim(TranslDta(aCT5[nX,2][nY][nPosCT5][2])))
								cValor := IIf(Empty(cValor),Ctod(""),cValor)
								CTK->(FieldPut(nPosCTK,cValor))
							EndCase
						EndIf
					Next nPosCTK
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os campos nao relacionados com a tabela CT5            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRateio
						CTK->CTK_CONTAB := "4"	// Contabilizacao de Rateio Contas a Pagar
					Else
						CTK->CTK_CONTAB := "2"	// Contabilizado automaticamente
					EndIf
					CTK->CTK_FILIAL	:= xFilial("CTK")
					CTK->CTK_ROTINA	:= cPrograma
					CTK->CTK_KEY	:= cChaveBusca
					CTK->CTK_LP		:= aCT5[nX,2][nY][nPLanPad][2]
					CTK->CTK_LPSEQ	:= aCT5[nX,2][nY][nPSequen][2]
					CTK->CTK_SEQUEN	:= cSeqChave
					CTK->CTK_SBLOTE	:= aCT5[nX,2][nY][nPSbLote][2]
					CTK->CTK_DATA	:= dDataBase
					CTK->CTK_LOTE	:= cLote

					If __Ct105CTK .And. !lSimula
						ExecBlock("CT105CTK", .F., .F., aCT5[nX,2][nY])
					Endif
					CTK->(MsUnlock())

					//-------------------------------------------------------
					// Obtencao da conta de Receita para o EFD-Contribuições
					//-------------------------------------------------------
					nPosCtaRec := aScan(aCT5[nX,2][1],{|x| x[1] == "CT5_CTAREC"})

					If nPosCtaRec > 0
						If aCT5[nX,2][nY][nPosCtaRec][2] == "2"
							cCtaRec := CTK->CTK_DEBITO
						ElseIf aCT5[nX,2][nY][nPosCtaRec][2] == "3"
							cCtaRec := CTK->CTK_CREDIT
						EndIf
					EndIf

					If __lConOutR
						ConOutR("*DETPROVA*|FINF|GRAVANDO CONTRA-PROVA|PROGRAMA|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
						ConOutR("*DETPROVA*|INIF|GRAVANDO FLAGS DE CONTABILIZAÇÃO|PROGRAMA|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
					EndIf

					If nPosAFlag > 0
						/// GUARDA O PRIMEIRO REGISTRO DE CTK PARA O LANCAMENTO (RODA DO FINAL P/ COMEÇO P/ NAO PRECISAR DE ASORT)
						nPosFlagOri	:= nPosAFlag
						n1StCTK	:= 0
						While aFlagCTB[nPosAFlag][5] == 0			/// PODE HAVER MAIS DE UM REGISTRO NA TAB ORIGEM
							aFlagCTB[nPosAFlag][5] := CTK->(Recno())
							n1StCTK	:= CTK->(Recno())
							nPosAFlag--
							If nPosAFlag <= 0
								Exit
							EndiF
						EndDo

						/// GUARDA O ULTIMO REGISTRO DE CTK PARA O LANCAMENTO. (RODA DO FINAL P/ COMEÇO P/ NAO PRECISAR DE ASORT)
						nPosAFlag := nPosFlagOri
						While aFlagCTB[nPosAFlag][5] == n1StCTK			/// PODE HAVER MAIS DE UM REGISTRO NA TAB ORIGEM
							aFlagCTB[nPosAFlag][6] := CTK->(Recno())
							nPosAFlag--									/// VOLTA UMA POSIÇÃO NO ARRAY
							If nPosAFlag <= 0
								Exit
							EndiF
						EndDo
					EndIf											/// ANTES DOS REGISTROS DE HISTORICO COMPLEMENTAR

					If __lConOutR
						ConOutR("*DETPROVA*|FINF|GRAVANDO FLAGS DE CONTABILIZAÇÃO|PROGRAMA|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
						ConOutR("*DETPROVA*|INIF|CONFIRMANDO NUMERAÇÃO DO SXEF - CONFIRMSX8|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
					EndIf

					While (GetSX8Len() > nSaveSX8)
						ConfirmSX8()
					EndDo

					If __lConOutR
						ConOutR("*DETPROVA*|FINF|CONFIRMANDO NUMERAÇÃO DO SXEF - CONFIRMSX8|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
						ConOutR("*DETPROVA*|INIF|GRAVACAO DO ARQUIVO DE RASTREAMENTO - CV3|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gravacao do Arquivo de Rastreamento => CV3                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("CV3")

					DbSetOrder(1)


					If !Empty(CTK->CTK_KEY) .And. (CTK->CTK_VLR01 + CTK->CTK_VLR02 + CTK->CTK_VLR03 + CTK->CTK_VLR04 + CTK->CTK_VLR05) > 0

						NewCV3byCTK(lSimula,cTabCTK,cTabCT2)			/// CRIA NOVO REGISTRO NO CV3 BASEADO NO CTK POSICIONADO (CTBXFUN.PRX)

						FKCOMMIT()
					EndIf

					If __lConOutR
						ConOutR("*DETPROVA*|FINF|GRAVACAO DO ARQUIVO DE RASTREAMENTO - CV3|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
						ConOutR("*DETPROVA*|INIF|VERIFICA SE HAVERA QUEBRA DE HISTORICO|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
					EndIf

					dbSelectArea("CTK")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se havera quebra de historico                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nPHAglut > 0 .and. Empty(cHAglut)
						cHAglut	:= AllTrim(TransLcta(aCT5[nX,2][nY][nPHAglut][2],240))
					EndIf
					If nPHist > 0
						If Empty(cHistorico)
							cHistorico 	:= AllTrim(TransLcta(aCT5[nX,2][nY][nPHist][2],240))
						EndIf
						If Empty(cHAglut)
							cHAglut := cHistorico
						EndIf
						lCTKHAGLUT := CTK->(FieldPos("CTK_HAGLUT") > 0)
						nLen := Len(CTK->CTK_HIST)
						If Len(cHistorico) > nLen
							For nZ := nLen + 1 To Len(cHistorico) Step nLen
								cHist := SubStr(cHistorico,nZ,nLen)
								RecLock("CTK",.T.)
								CTK->CTK_DC			:= "4"
								CTK->CTK_HIST		:= cHist

								If lCTKHAGLUT .and. nZ <= Len(cHAglut)
									CTK->CTK_HAGLUT	:= SubStr(cHAglut,nZ,nLen)
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava os campos nao relacionados com a tabela CT5            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lRateio
									CTK->CTK_CONTAB := "4"					// Contabilizacao de Rateio Contas a Pagar
								Else
									CTK->CTK_CONTAB := "2"					// Contabilizado automaticamente
								EndIf
								CTK->CTK_FILIAL	:= xFilial("CTK")
								CTK->CTK_ROTINA	:= cPrograma
								CTK->CTK_KEY	:= cChaveBusca
								CTK->CTK_LP		:= aCT5[nX,2][nY][nPLanPad][2]
								CTK->CTK_LPSEQ	:= aCT5[nX,2][nY][nPSequen][2]
								CTK->CTK_SEQUEN	:= cSeqChave
								CTK->CTK_SBLOTE	:= aCT5[nX,2][nY][nPSbLote][2]
								CTK->CTK_DATA	:= dDataBase
								CTK->CTK_LOTE	:= cLote
								CTK->CTK_TPSALD	:= aCT5[nX,2][nY][nPTpSald][2]
								CTK->CTK_MOEDLC	:= aCT5[nX,2][nY][nPMoedLC][2]
								CTK->CTK_ORIGEM	:=AllTrim(TransLcta(aCT5[nX,2][nY][nPOrigem][2],Len(CTK->CTK_ORIGEM)))

								#IFDEF TOP
									If lCTKTABORI
										CTK->CTK_TABORI	:= cTabOrigem
									EndIf
									If lCTKRECORI
										CTK->CTK_RECORI	:= ALLTRIM(STR(INT(nRecOrigem)))
									EndIf
								#ENDIF

								If __Ct105CTK .And. !lSimula
									ExecBlock("CT105CTK", .F., .F., aCT5[nX,2][nY])
								Endif
								MsUnlock()
							Next nZ
						EndIf
					EndIf

					LanceiCtb := .T.

					If __lConOutR
						ConOutR("*DETPROVA*|FINF|VERIFICA SE HAVERA QUEBRA DE HISTORICO|"+cPrograma+"|LP|"+cPadrao+"|SEQCHAVE|"+cSeqChave )
					EndIf
				EndIf
			Next nY
		EndIf
	EndIf

// Array com dados para utilizacao multi-thread
	aDadosProva:=ACLONE(__HeadProva)

	If __lConOutR
		ConOutR("*DETPROVAFIN*|INICIO DA MONTAGEM DO DETPROVA.|PROGRAMA|"+cPrograma+"|LP|"+cPadrao)
	EndIf


	RestArea(aArea)
Return(nTotal)
