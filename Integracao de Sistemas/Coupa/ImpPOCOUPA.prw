#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

#DEFINE ITEM     1
#DEFINE PRODUTO  2
#DEFINE UM       3
#DEFINE QUANT    6
#DEFINE PRECO    7
#DEFINE TOTAL    8
#DEFINE DATPRF   9
#DEFINE IPI      10
#DEFINE ZZOBSCO  11
#DEFINE CCUSTO   12
#DEFINE CONDPG   13
#DEFINE FORNECE  14
#DEFINE EMISSAO  15
#DEFINE PEDCOUPA 16
#DEFINE LOJA     18
#DEFINE SEGURO   20
#DEFINE DESPESA  21
#DEFINE VALFRETE 22
#DEFINE MOEDACOUP 23
#DEFINE DEPARAFIL 24
#DEFINE TPFRETE  25
#DEFINE PERCRAT  27
#DEFINE STATUS   28
#DEFINE IPITX	29
#DEFINE SUBCONDPGTO 30
#DEFINE CNPJFILIAL	31

#DEFINE REQUESTNAME	32
#DEFINE REQUESTMAIL	33
#DEFINE REQUESTPUD	34

#DEFINE ITENS_ROTAUTO  1
#DEFINE RATEIO_ROTAUTO  2

#DEFINE INCLUSAO 3

/*/{Protheus.doc} IMPPOCOUPA
Realiza importa��o de pedido de compra cadastrado no Coupa
@author Tiago Maniero
@since 25/05/2020
/*/
User Function ImpPOCOUPA(xParam1,xParam2,xParam3)

	local oFile
	local aPedido 			:= {}
	local aRet    			:= {}
	local nI      			:= 1
	local nJ      			:= 1
	local lRet    			:= .T.
	local aArqs   			:= {}
	local cDiretorio		:= "\coupa\PO\pendente\"
	Local cEmpJob			:= ""
	Local cFilJob			:= ""
	Local cIDUsrJob			:= ""
	local _Coupa			:= nil

	Private aErro 			:= {}
	Private lDebug			:= .F.
	Private cIDUser			:= ""

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
		geraLog( "EMPRESA / FILIAL N�O CONFIGURADAS NO JOB" )
	Else
		PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob

		cIDUser			:= cIDUsrJob
		__cUserId		:= cIDUser
		cUserName		:= "Administrador"

		geraLog( "Empresa [" + cEmpAnt + "]" )
		geraLog( "Filial [" + cFilAnt + "]" )
		geraLog( "Environment........: " + GetEnvServer()  )
		geraLog( "Vers�o.............: " + GetVersao(.T.) )
		geraLog( "Usu�rio TOTVS .....: " + __cUserId + " " +  cUserName )
		geraLog( "Computer Name......: " + GetComputerName() )
		geraLog( "Fonte..............: " + GetApoInfo( strtran( procname() , "U_" , "" ) + ".prw")[1] )
		geraLog( "Data/Hora Fonte....: " + DTOC(GetApoInfo( strtran( procname() , "U_" , "" ) + ".prw")[4]) + " " + GetApoInfo( strtran( procname() , "U_" , "" ) + ".prw")[5]  )

		aArqs := Directory( cDiretorio + "*.csv","S")

		geraLog("Diretorio: [" + cDiretorio + "*.csv]")
		geraLog("Quantidade de arquivos:" + cValToChar(len(aArqs)) )

		_Coupa	:= LibCoupa():New()
		_Coupa:geraCNPJZZC()

		For nJ := 1 to Len(aArqs)
			geraLog( Replicate("*",60) )
			geraLog( "Processando Arquivo: " + aArqs[nJ,1] )

			oFile := ManagerTXT():New(cDiretorio + aArqs[nJ,1])

			oFile:ABRIRTXT()

			aRet := oFile:LERLINHA(.T.)

			aPedido := {}
			For nI := 2 to Len(aRet)
				aAdd(aPedido, StrTokArr2( StrTran( StrTran( aRet[nI,1]  , '"', '') , "'","") , ";", .T. ) )
			Next nI

			lRet := ExecPO(aPedido,cDiretorio + aArqs[nJ,1])

			If lRet
				If File("\coupa\PO\processado\" + aArqs[nJ,1])
					fErase("\coupa\PO\processado\" + aArqs[nJ,1])
				EndIf
				FRename(oFile:cNameArq,"\coupa\PO\processado\" + aArqs[nJ,1])

				geraLog( "Arquivo " + aArqs[nJ,1] + " movido para pasta processado." )
			else
				If File("\coupa\PO\com erro\" + aArqs[nJ,1])
					fErase("\coupa\PO\com erro\" + aArqs[nJ,1])
				EndIf

				FRename(oFile:cNameArq,"\coupa\PO\com erro\" + aArqs[nJ,1])
				geraLog( "Arquivo " + aArqs[nJ,1] + " movido para pasta com erro." )
			endif

			geraLog( Replicate("*",60) )

			oFile:FECHAARQUIVO()
		Next nJ

		RESET ENVIRONMENT
	Endif

	geraLog( "Final Rotina" )
	geraLog( Replicate("*",30) )

Return


/*
Executa rotina autom�tica de pedido de compra
*/
Static Function ExecPO(aPedido,cArquivo)

	local aCabec      := {}
	local aItens      := {}
	local aRatCC      := {}
	local lRet        := .T.
	local cCond       := ""
	local nI     	  := 0
	local nValFre     := 0//Val(aPedido[1,VALFRETE])
	local nSeguro     := 0//Val(aPedido[1,SEGURO])
	local nDespesa    := 0//Val(aPedido[1,DESPESA])
	local aRetorno		:= {}
	local cErro			:= ""
	local cNumPedido	:= ""
	local nOperacao		:= 3
	local oCoupa		:= LibCoupa():New()
	local cIDFilial		:= ""
	local cEntity		:= ""
	local cFilRet		:= ""
	local cCondPgtoCoup	:= ""
	local cCNPJ			:= ""
	local cMsgErro		:= ""
	local aRet			:= {}
	local oPedReceb		:= LibCoupa():New()

	Private lGeraAdiant		:= .F.
	Private aLog        	:= {}
	private lMsErroAuto 	:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile  := .T.
	private lElimResiduo	:= .F.
	private __nMoedaPC		:= 1
	Private lGeraNum		:= getnewpar("ZZ_NUMPCCO",.F.)

	for nI := 1 to len(aPedido)
		if Len(aPedido[nI]) <= 30
			lRet := .F.
			cMsgErro		:= "Analisar o arquivo enviado pelo coupa, o arquivo n�o est� no padr�o que deveria!"
			geraLog(cMsgErro)
			AdicionaLog(cMsgErro)
		endif
	Next nI

	if lRet
		aRet		:= StrTokArr( aPedido[1,DEPARAFIL] , "|" )
		cEntity		:= AllTrim(aRet[1])
		cIDFilial	:= AllTrim(aRet[2])
	endif

	if lRet
		nValFre     := Val(aPedido[1,VALFRETE])
		nSeguro     := Val(aPedido[1,SEGURO])
		nDespesa    := Val(aPedido[1,DESPESA])

		If Len(aPedido[1]) >= CNPJFILIAL .and. !Empty(aPedido[1,CNPJFILIAL])
			cCNPJ		:= oCoupa:limpaCaracteres( aPedido[1,CNPJFILIAL] )
			geraLog("Busca a filial pelo CNPJ " + cCNPJ + "...")
		Else
			cCNPJ		:= ""
		EndIf

		cFilRet		:= oCoupa:retornaFilial( aPedido[1,CCUSTO] , cIDFilial , cEntity , cCNPJ )
		geraLog("Filial:" + cFilRet)

		If empty(cFilRet)
			lRet		:= .F.
			If empty(cCNPJ)
				cMsgErro		:= "De/Para de filial n�o encontrado. Centro de Custo/Filial: [" + aPedido[1,CCUSTO] + "/" + aPedido[1,DEPARAFIL] + "]"
			Else
				cMsgErro		:= "De/Para de filial + CNPJ n�o encontrado. Centro de Custo/Filial/CNPJ: [" + aPedido[1,CCUSTO] + "/" + aPedido[1,DEPARAFIL] + "/" + cCNPJ + "]"
			EndIf
			geraLog(cMsgErro)
			AdicionaLog(cMsgErro)
		else
			If AllTrim(cFilAnt) <> AllTrim(cFilRet)

				RESET ENVIRONMENT
				PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilRet

				__cUserId		:= cIDUser
				cUserName		:= "Administrador"
			EndIf
		endif
	endif

	if lRet
		If Len(aPedido[1]) >= 30 .and. !Empty(aPedido[1,SUBCONDPGTO])
			cCondPgtoCoup	:= aPedido[1,SUBCONDPGTO]
			geraLog("Buscando a condi��o de pagamento pela >SubCondi��o< do Coupa [" + cCondPgtoCoup + "]")
		Else
			cCondPgtoCoup	:= aPedido[1,CONDPG]
			geraLog("Buscando a condi��o de pagamento pela CONDI��O DE PAGTO do Coupa [" + cCondPgtoCoup + "]")
		EndIf

		cCond 	:= RetCodCondicaoPagamento( cCondPgtoCoup )
		if empty(cCond)
			lRet 	:= ValidacoesParaProsseguir(cCondPgtoCoup, aPedido[1,FORNECE])
		else
			lRet 	:= ValidacoesParaProsseguir(cCond, aPedido[1,FORNECE])
		endif
	endif

	if lRet
		aCabec 		:= montaCabecalho(aPedido, cCond, nSeguro, nValFre, nDespesa,@cNumPedido)

		aRetorno	:= montaItens(aPedido,cCond,@lRet,@cErro,@nOperacao)
		aItens 		:= aRetorno[ITENS_ROTAUTO]
		aRatCC 		:= aRetorno[RATEIO_ROTAUTO]

		if lRet .and. nOperacao <> 3 .and. !lElimResiduo
			If oPedReceb:pedidoJaRecebido(cNumPedido)
				lRet		:= .F.
				cErro		+= "O pedido [" + cNumPedido + "] "
				cErro		+= "j� teve recebimento no Protheus, portanto "
				cErro		+= "n�o pode ser alterado."
			endif
		endif

		If lRet .AND. !lElimResiduo
			if len(aRatCC) > 0
				geraLog("Pedido de compras tem RATEIO!")
			endif

			geraLog("Executando MATA120...")
			geraLog("Opera��o: " + cValToChar(nOperacao))

			BEGIN TRANSACTION

				If lDebug
					geraLog(" >>> MODO DEBUG ATIVO <<<")
					lMsErroAuto	:= .F.
				Else
					aCabec		:= FWVetByDic(aCabec,"SC7")
					aItens		:= FWVetByDic(aItens,"SC7",.T.)

					MSExecAuto({|k,v,w,x,y,z| MATA120(k,v,w,x,y,z)},1,aCabec,aItens,nOperacao,,aRatCC)
				endIf

				if lMsErroAuto
					geraLog("ERRO na execu��o da rotina autom�tica!")
					varinfo("aItens",aItens)
					varinfo("aRatCC",aRatCC)

					If nOperacao == INCLUSAO
						If lGeraNum
							RollBackSX8()
						EndIf
					EndIf
				else
					If nOperacao == INCLUSAO
						lMsErroAuto		:= !oCoupa:geraTitAdiant(lGeraAdiant,cNumPedido,@cErro)
					EndIf

					If lMsErroAuto
						geraLog("ERRO na execu��o da rotina autom�tica!")
						lMsErroAuto	:= .T.
					Else
						If nOperacao == INCLUSAO
							If lGeraNum
								ConfirmSX8()
							Else
								cNumPedido	:= RetPedido(aPedido)
							EndIf
						EndIf
						geraLog("Rotina autom�tica executada com sucesso!")
					EndIf
				endif

				If !lMsErroAuto .AND. aPedido[1,STATUS] == "created"
					geraLog("Incluido com sucesso! ")
				elseIf !lMsErroAuto .AND. aPedido[1,STATUS] == "updated"
					geraLog("Alterado com sucesso! ")
				elseIf !lMsErroAuto .AND. aPedido[1,STATUS] == "cancelled"
					geraLog("Cancelado com sucesso! ")
				elseIf lMsErroAuto
					aLog := GetAutoGrLog()
					For nI := 1 to Len(aLog)
						if !empty(aLog[nI])
							geraLog( allTrim(aLog[nI]) )
						endif
					Next nI
					lMsErroAuto := .F.
					lRet := .F.

					DisarmTransaction()
				EndIf

			END TRANSACTION
		else
			aLog		:= {}
			aAdd( aLog , cErro )
		endif
	EndIf

	If !lDebug
		GravaZZD(lRet, aPedido, aLog,cNumPedido,cArquivo,nOperacao)
	EndIf

	aLog		:= {}

Return lRet

Static Function RetCodCondicaoPagamento(cCodigoCondicaoPagamento)

	Local cRetorno  := ""
	Local aAreaZZE	:= ZZE->(GetArea())
	Local lAdianta	:= getnewpar("ZZ_CPFINPA",.F.)

	ZZE->(Dbsetorder(1))
	If !Empty(cCodigoCondicaoPagamento)
		If ZZE->(DbSeek( FwXfilial("ZZE") + cCodigoCondicaoPagamento ))
			cRetorno	:= ZZE->ZZE_CODPRO
			If lAdianta
				If ZZE->(FieldPos("ZZE_ADIANT")) > 0 .AND. AllTrim(ZZE->ZZE_ADIANT) == "S"
					lGeraAdiant		:= .T.
				Else
					lGeraAdiant		:= .F.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaZZE)

Return cRetorno

/*
Grava��o do rastramento de log
*/
Static Function GravaZZD(lRet, aPedido, aLog,cNumPedido,cArquivo,nOperacao)

	local cLog 		:= "Falha ao incluir pedido: "
	local nI   		:= 1
	local oLibCoupa
	Local lGrvPCCoup:= .T.

	For nI := 1 to len(aLog)
		cLog += aLog[nI] + CRLF
	Next nI

	for nI := 1 to len(aPedido)
		if Len(aPedido[nI]) < 15
			lGrvPCCoup := .F.
		endif
	Next nI

	oLibCoupa	:= LibCoupa():New()
	oLibCoupa:setTipo("PEDIDO")
	if lGrvPCCoup
		oLibCoupa:setChave(aPedido[1,PEDCOUPA])
	endif

	oLibCoupa:setArquivo(cArquivo)
	oLibCoupa:setNF("")

	if lElimResiduo
		oLibCoupa:setOperacao("RESIDUO")
	elseIf nOperacao == 3
		oLibCoupa:setOperacao("INCLUSAO")
	ElseIf nOperacao == 4
		oLibCoupa:setOperacao("ALTERACAO")
	ElseIf nOperacao == 5
		oLibCoupa:setOperacao("EXCLUSAO")
	EndIf

	if lRet
		oLibCoupa:setPedido(cNumPedido)
		oLibCoupa:setIsErro(.F.)
		oLibCoupa:setOcorrencia("INCLUIDO COM SUCESSO")

		oLibCoupa:excluiErros()
	else
		oLibCoupa:setPedido("")
		oLibCoupa:setIsErro(.T.)
		oLibCoupa:setOcorrencia(cLog)
	endif
	oLibCoupa:setPro2COupa(.F.)
	oLibCoupa:gravaZZD()

Return

//Cria valida��es de cabe�alho
Static Function ValidacoesParaProsseguir(cCond, cCodLojaFornecedor)

	local cErro:= ""
	local cLog := ""
	Local lRet := .T.

	dbSelectArea("SE4")
	dbSetOrder(1)
	If Empty(cCond)
		lRet 	:= .F.
		cErro	:= "N�o localizada a condi��o de pagamento [" + cCond + "] no De/Para"
		geraLog(cErro)
		AdicionaLog(cErro)
	Else
		If !SE4->(MsSeek(xFilial("SE4")+AllTrim(cCond)))
			lRet := .F.
			geraLog("Cadastrar condicao de pagamento: " + AllTrim(cCond))
			cLog += "Cadastrar condicao de pagamento: " + AllTrim(cCond)
			AdicionaLog(cLog)
		EndIf
	EndIf

	If lRet
		dbSelectArea("SA2")
		dbSetOrder(1)
		If !SA2->(MsSeek(xFilial("SA2")+cCodLojaFornecedor))
			lRet := .F.
			geraLog("Cadastrar fornecedor: " + cCodLojaFornecedor)
			cLog += "Cadastrar fornecedor: " + cCodLojaFornecedor
			AdicionaLog(cLog)
		Else
			If AllTrim(SA2->A2_MSBLQL) == "1"
				lRet		:= .F.
				cLog		:= "Fornecedor Bloqueado: "
				cLog		+= SA2->A2_COD + "/" + SA2->A2_LOJA + " - "
				cLog		+= AllTrim(SA2->A2_NOME)
				AdicionaLog(cLog)
			EndIf
		EndIf
	EndIf

Return lRet

//Formata o log para tabela ZZD
Static Function AdicionaLog(cLog)
	Aadd(aLog, cLog)
return

//Monta array do cabe�alho
Static Function montaCabecalho(aPedido, cCond, nSeguro, nValFre, nDespesa,cNumPedido)

	local aCabec 		:= {}
	local cNum   		:= ""
	local cNumExist		:= RetPedido(aPedido)

	if aPedido[1,STATUS] == "updated" .OR. aPedido[1,STATUS] == "cancelled" .or. !Empty(cNumExist)
		cNum 		:= RetPedido(aPedido)
		cNumPedido	:= cNum

		aadd(aCabec,{"C7_NUM" ,cNum})

		geraLog("Numero do Pedido: " + cNum)
	else
		geraLog("Gerando um novo numero de pedido...")
		if lGeraNum
			cNum		:= GetSXEnum("SC7","C7_NUM")
			cNumPedido	:= cNum
			geraLog("Gerou numero: " + cNum)
			aadd(aCabec,{"C7_NUM" ,cNum})
		endif
	endIf
	aadd(aCabec,{"C7_FILIAL" ,  xFilial("SC7") , nil })
	aadd(aCabec,{"C7_EMISSAO" ,CtoD(aPedido[1,EMISSAO])})
	aadd(aCabec,{"C7_FORNECE" ,SubStr(aPedido[1,FORNECE],1,6)})
	aadd(aCabec,{"C7_LOJA" ,SubStr(aPedido[1,FORNECE],7,2)})
	aadd(aCabec,{"C7_COND" ,AllTrim(cCond)})
	aadd(aCabec,{"C7_TPFRETE" ,aPedido[1,TPFRETE]})
	if(nSeguro > 0)
		aadd(aCabec,{"C7_SEGURO" ,nSeguro})
	endif
	if(nDespesa > 0)
		aadd(aCabec,{"C7_DESPESA" ,nDespesa})
	endif
	if(nValFre > 0)
		aadd(aCabec,{"C7_VALFRE" ,nValFre})
	endif
Return aCabec

//Retorna pedido em caso de altera��o ou exclus�o
Static Function RetPedido(aPedido)
	local cQueryPed := ""
	local cAliasPed := GetNextAlias()
	local cRetorno  := ""

	cQueryPed += "SELECT C7_NUM FROM " + RetSqlTab("SC7") + CRLF
	cQueryPed += " WHERE C7_ZZCCOUP = '" + aPedido[1,PEDCOUPA] + "' " + CRLF
	cQueryPed += " AND C7_ZZINTCO = 'S'" + CRLF
	cQueryPed += " AND SC7.D_E_L_E_T_ = ' ' AND C7_FILIAL ='" + xFilial("SC7") + "' "

	TcQuery cQueryPed New Alias &cAliasPed

	DbSelectArea(cAliasPed)
	(cAliasPed)->(DbGoTop())
	cRetorno := (cAliasPed)->C7_NUM
	(cAliasPed)->(DbCloseArea())

Return cRetorno

//Monta array de itens e rateio
Static Function montaItens(aPedido,cCond,lOk,cErro,nOperacao)

	Local nQuant  		:= 0
	Local nPreco  		:= 0
	Local nTotal		:= 0
	Local nLinha      	:= 0
	Local nItemPedido	:= 0
	Local nValIPI 		:= 0
	Local nMoeda		:= 0
	Local cItem   		:= ""
	Local cItemNext		:= ""
	Local cItemAnt		:= ""
	Local cPedLocaliz	:= ""
	Local cPedCoupa		:= ""
	Local cItArray		:= ""
	Local alinha  		:= {}
	Local aItens  		:= {}
	Local aRatCC  		:= {}
	Local aItemCC 		:= {}
	Local aReturn 		:= {}
	Local aItensEXC		:= {}
	Local lRateio		:= .F.
	Local lLinhaAnt		:= .F.
	Local nItemRateio	:= 0
	Local nPos			:= 0
	Local nIt			:= 0
	Local lItemPed		:= .F.
	Local lItemAlt		:= .T.
	Local lItemExc		:= .T.
	Local lLocaliz		:= .F.
	Local oLibCoupa		:= LibCoupa():New()
	Local aAreaSC7		:= SC7->(GetArea())
	Local nRecItem		:= 0
	Local nNovaQtd		:= 0
	Local nNovaVal		:= 0
	Local dNovaDat
	Local cNovaCond		:= ""
	Local lBloq			:= .F.
	Local lContinua 	:= .T.

	SC7->(DbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

	For nLinha := 1 To Len(aPedido)
		geraLog("Lendo a linha: " + cValToChar(nLinha))
		geraLog("Item: " + StrZero(Val(aPedido[nLinha,ITEM]),TamSx3("CH_ITEMPD")[1]))
		nItemPedido++

		aPedido[nLinha,PRODUTO] 	:= StrTran(aPedido[nLinha,PRODUTO],'"','')
		If !oLibCoupa:existProd(aPedido[nLinha,PRODUTO],@lBloq)
			cErro	:= "N�o localizado o codigo do produto [" + aPedido[nLinha,PRODUTO] + "] na filial " + cFilAnt
			lOk		:= .F.
			geraLog(cErro)
			exit
		else
			If lBloq
				cErro	:= "Produto codigo [" + aPedido[nLinha,PRODUTO] + "] na filial " + cFilAnt + " est� bloqueado"
				lOk		:= .F.
				geraLog(cErro)
				exit
			EndIf
		Endif

		geraLog("Status: " + aPedido[nLinha,STATUS] )
		if aPedido[nLinha,STATUS] $ "updated/received/partially_received"
			nOperacao			:= 4
			lItemAlt			:= .T.
			lElimResiduo		:= .F.
			cPedCoupa			:= aPedido[nLinha,PEDCOUPA]
			nNovaQtd			:= ConvUM(aPedido[nLinha,PRODUTO],0,Val(aPedido[nLinha,QUANT]),1)
			dNovaDat			:= cTod(aPedido[nLinha,DATPRF])
			cNovaCond			:= aPedido[nLinha,CONDPG]
			nNovaVal			:= aPedido[nLinha,PRECO]
			lContinua			:= .F.

			nRecItem			:= oLibCoupa:getRecItem(aPedido[nLinha,PEDCOUPA],StrZero(Val(aPedido[nLinha,ITEM]),TamSx3("C7_ITEM")[1]))
			If nRecItem > 0
				SC7->(DbGoTo( nRecItem ))

				geraLog("Quantidade Original:" + cValToChar(SC7->C7_QUANT) )
				geraLog("Quantidade Entregue:" + cValToChar(SC7->C7_QUJE) )
				geraLog("Nova Qtde:" + cValToChar(nNovaQtd))

				if nNovaQtd < SC7->C7_QUJE
					cErro	:= "Nova quantidade � menor do que a j� entregue no pedido - item " + aPedido[nLinha,ITEM]
					lOk		:= .F.
					geraLog(cErro)
					exit
				elseif SC7->C7_ENCER == "E" .or. SC7->C7_RESIDUO == "R"
					geraLog("N�o houve altera��o!")
					geraLog("")
					loop
				else
					If nNovaQtd <> SC7->C7_QUANT
						lContinua := .T.
					endif
					if SC7->C7_DATPRF  <> dNovaDat
						lContinua := .T.
					endif
					if SC7->C7_COND <> cNovaCond
						lContinua := .T.
					endif
					if SC7->C7_PRECO <> Val(nNovaVal)
						lContinua := .T.
					endif
					if !lContinua
						geraLog("N�o houve altera��o!")
						geraLog("")
						loop
					endif
				EndIf
			else
				cErro		:= "ITEM N�O LOCALIZADO PARA ALTERA��O! - item " + aPedido[nLinha,ITEM]
				geralOg(cErro)
				lOk	:= .F.
				exit
			endIf

		elseif aPedido[nLinha,STATUS] == "cancelled"
			cPedCoupa			:= aPedido[nLinha,PEDCOUPA]
			nOperacao			:= 5
			lItemExc			:= .T.
			lElimResiduo		:= .F.
		else
			if nOperacao == 3 .and. oLibCoupa:exisPedCoupa(aPedido[nLinha,PEDCOUPA])
				cPedCoupa			:= aPedido[nLinha,PEDCOUPA]
				nOperacao			:= 4
				lItemAlt			:= .T.
				lItemExc			:= .F.
			else
                lContinua			:= .T.
				nRecItem			:= oLibCoupa:getRecItem(aPedido[nLinha,PEDCOUPA],StrZero(Val(aPedido[nLinha,ITEM]),TamSx3("C7_ITEM")[1]))
				If nRecItem > 0
					SC7->(DbGoTo( nRecItem ))
					If AllTrim(SC7->C7_OBS) <> AllTrim(StrTran(aPedido[nLinha,ZZOBSCO],'"',''))
						geralog("Altera Observa��o")
						lItemAlt			:= .T.
					Else
						lItemAlt			:= .F.
					EndIf
				Else
					lItemAlt			:= .F.
					lItemExc			:= .F.
					lElimResiduo		:= .F.
				EndIf
			endif
		endif

		//---------------------------------------
		// VALIDA��ES
		//---------------------------------------
		If Empty(aPedido[nLinha,PRODUTO])
			lOk		:= .F.
			cErro	:= "ERRO - Produto n�o preenchido no item " + aPedido[nLinha,ITEM]
			geraLog(cErro)
			exit
		elseif nOperacao <> 3 .AND. !oLibCoupa:exisPedCoupa(aPedido[nLinha,PEDCOUPA])
			lOk		:= .F.
			cErro	:= "ERRO - N�o localizado nenhum pedido com o ID do Coupa: " + aPedido[nLinha,PEDCOUPA]
			geraLog(cErro)
			exit
		elseIf !Empty(aPedido[nLinha,CCUSTO]) .and. Empty(oLibCoupa:retornaAddress(aPedido[nLinha,CCUSTO]))
			lOk		:= .F.
			cErro	:= "N�o localizado cadastro De/para do Centro de Custo [" + aPedido[nLinha,CCUSTO] + "] na filial [" + cFilAnt + "]"
			geraLog(cErro)
			exit
		else
			nMoeda		:= oLibCoupa:retMoeda(aPedido[nLinha,MOEDACOUP])
			If nMoeda <= 0
				lOk		:= .F.
				cErro	:= "ERRO - N�o localizado De/Para de Moedas do Coupa [" + aPedido[nLinha,MOEDACOUP] + "]"
				geraLog(cErro)
				exit
			Else
				__nMoedaPC		:= nMoeda
				geraLog("Moeda Coupa/Protheus [" + aPedido[nLinha,MOEDACOUP] + "/" + cValToChar(nMoeda) + "]")
			EndIf
		EndIf

		If nLinha > 1
			cItemAnt		:= StrZero(Val(aPedido[nLinha-1,ITEM]),TamSx3("CH_ITEMPD")[1])
		EndIf

		If nLinha < Len(aPedido)
			cItem 			:= StrZero(Val(aPedido[nLinha,ITEM]),TamSx3("CH_ITEMPD")[1])
			cItemNext		:= StrZero(Val(aPedido[nLinha+1,ITEM]),TamSx3("CH_ITEMPD")[1])

			//Verifica se � o mesmo item
			If cItem == cItemNext
				geraLog("Proxima linha � mesmo item, � rateio...")
				lRateio		:= .T.
				lLinhaAnt	:= .F.
			ElseIf cItem == cItemAnt
				geraLog("Proxima linha � mesmo item, � rateio...")
				lRateio		:= .T.
				lLinhaAnt	:= .T.
			Else
				lRateio		:= .F.
				lLinhaAnt	:= .F.
			EndIf
		Else
			//Se for o mesmo que o item anterior
			If cItem == StrZero(Val(aPedido[nLinha,ITEM]),TamSx3("CH_ITEMPD")[1])
				geraLog("Ultima linha � mesmo item, � rateio...")
				lRateio		:= .T.
				lLinhaAnt	:= .F.
			ElseIf cItemAnt == StrZero(Val(aPedido[nLinha,ITEM]),TamSx3("CH_ITEMPD")[1])
				lRateio		:= .T.
				lLinhaAnt	:= .T.
			Else
				lRateio		:= .F.
				lLinhaAnt	:= .F.
			EndIf
		EndIf

		//Se for Rateio, monta o array
		If lRateio
			geraLog("Gerando Rateio do item: " + cItem)
			geraLog("Qtd Itens Rateados: " + cValToChar(Len(aRatCC)) )

			If Len(aRatCC) == 0
				nPos			:= 1
				nItemRateio		:= 1
				aAdd(aRatCC,{cItem,{}})
			Else
				nPos		:= aScan(aRatCC, {|x| x[1] == cItem})
				If nPos <= 0
					geraLog("Cria novo item rateado...")
					aAdd(aRatCC,{cItem,{}})
					nItemRateio		:= 1
					nPos			:= Len(aRatCC)
				Else
					geraLog("Localizado item na posi��o " + cValToChar(nPos))
					nItemRateio	:= Len(aRatCC[nPos][2]) + 1
				EndIf
			EndIf

			aAdd(aItemCC,	{"CH_ITEMPD",	cItem,NIL})
			aAdd(aItemCC,	{"CH_ITEM",		StrZero(nItemRateio,TamSx3("CH_ITEM")[1]),NIL})
			aAdd(aItemCC,	{"CH_PERC",		Val(aPedido[nLinha,PERCRAT]),NIL}) // Percentual a ser ratiado.
			aAdd(aItemCC,	{"CH_CC",		aPedido[nLinha,CCUSTO],NIL})
			aAdd(aRatCC[nPos][2],aItemCC)

			aItemCC		:= {}

			If lLinhaAnt
				lRateio	:= .F.
			EndIf
		EndIf

		//varInfo("cItem",cItem)
		//varInfo("aItens",aItens)
		For nIt := 1 to Len(aItens)
			If aItens[nIt,1,1] == "C7_ITEM"
				If aItens[nIt,1,2] == StrZero(Val(aPedido[nLinha,ITEM]),TamSx3("C7_ITEM")[1])
					//If aItens[nIt,1,2] == cItem
					lRateio			:= .T.
					lItemPed		:= .F.
					geraLog("Item j� estava no array")
					exit
				Else
					//geraLog("Item n�o estava no array, ent�o adiciona")
					lItemPed		:= .T.
				EndIf
			EndIf
		Next

		if nLinha == 1 .OR. !lRateio .OR. lItemPed .or. lContinua
			geraLog("Adicionando item no pedido...")

			nValIPI := Val(aPedido[nLinha,IPI])

			nQuant	:= Round( Val(aPedido[nLinha,QUANT]) , tamsx3("C7_QUANT")[2] )
			nPreco	:= Val(aPedido[nLinha,PRECO])

			If nPreco <= 0
				lOk		:= .F.
				cErro	:= "ERRO - Pre�o unit�rio zerado do item " + aPedido[nLinha,ITEM]
				geraLog(cErro)
				exit
			EndIf

			If nQuant <= 0
				lOk		:= .F.
				cErro	:= "ERRO - Quantidade ZERADA do item " + aPedido[nLinha,ITEM]
				geraLog(cErro)
				exit
			Else
				nQuant := Round( ConvUM(aPedido[nLinha,PRODUTO],0,Val(aPedido[nLinha,QUANT]),1) , tamsx3("C7_QUANT")[2] )
				If nQuant <= 0
					lOk		:= .F.
					cErro	:= "ERRO - Na convers�o da unidade de medida do item/produto " + aPedido[nLinha,ITEM] + "/" + aPedido[nLinha,PRODUTO]
					geraLog(cErro)
					exit
				else
					nTotal		:= Val(aPedido[nLinha,TOTAL])
					nPreco		:= nTotal / nQuant
					lOk		:= .T.
				EndIf
			EndIf

			//varinfo("nQuant",nQuant)

			aLinha := {}
			aadd(aLinha,{"C7_ITEM",			StrZero(Val(aPedido[nLinha,ITEM]),TamSx3("C7_ITEM")[1]),Nil})
			aadd(aLinha,{"C7_PRODUTO",		aPedido[nLinha,PRODUTO],Nil})
			aadd(aLinha,{"C7_QUANT",		noRound(nQuant,2),Nil})
			aadd(aLinha,{"C7_PRECO",		nPreco,Nil})
			aadd(aLinha,{"C7_ZZPRINI",		nPreco,Nil})
			aadd(aLinha,{"C7_TOTAL",		Val(aPedido[nLinha,TOTAL]),Nil})
			aadd(aLinha,{"C7_DATPRF",		CtoD(aPedido[nLinha,DATPRF]),Nil})
			aadd(aLinha,{"C7_COND",			cCond,Nil})
			if(nValIPI > 0)
				aadd(aLinha,{"C7_IPI" ,nValIPI,Nil})
			endif
			aadd(aLinha,{"C7_ZZOBSCO",		StrTran(aPedido[nLinha,ZZOBSCO],'"',''),Nil})
			aadd(aLinha,{"C7_OBS",			StrTran(aPedido[nLinha,ZZOBSCO],'"',''),Nil})
			aadd(aLinha,{"C7_ZZINTCO",		"S",Nil})
			aadd(aLinha,{"C7_ZZCCOUP",		aPedido[nLinha,PEDCOUPA],Nil})
			aadd(aLinha,{"C7_MOEDA",		nMoeda,Nil})

			//For�a a inclus�o como pedido liberado
			aadd(aLinha,{"C7_APROV",		"",						nil })
			aadd(aLinha,{"C7_CONAPRO",		"L",					nil })

			If Val(aPedido[nLinha,PERCRAT]) == 100
				If oLibCoupa:existCC(aPedido[nLinha,CCUSTO])
					aadd(aLinha,{"C7_CC",		aPedido[nLinha,CCUSTO],		nil })
					aadd(aLinha,{"C7_RATEIO",	"2",						nil })
				Else
					lOk		:= .F.
					cErro	:= "N�o localizado o centro de custo [" + aPedido[nLinha,CCUSTO] + "] no Protheus"
					geraLog(cErro)
					exit
				EndIf
			Else
				aadd(aLinha,{"C7_CC",		"",		nil })
				aadd(aLinha,{"C7_RATEIO",	"1",	nil })
			EndIf

			If lItemAlt .or. lItemExc
				geraLog("Alterando/excluindo...")
				aadd(aLinha,{"C7_REC_WT", oLibCoupa:getRecItem(aPedido[nLinha,PEDCOUPA],aPedido[nLinha,ITEM]),nil })
			Else
				aadd(aLinha,{"C7_XMODINC",		'1'                        ,		nil })
			endif

			aadd(aLinha,{"C7_XSOLICI",		aPedido[nLinha,REQUESTNAME],		nil })
			aadd(aLinha,{"C7_XEMSOLI",		aPedido[nLinha,REQUESTMAIL],		nil })


			// REQUESTPUD

			geraLog("Obs: "+ StrTran(aPedido[nLinha,ZZOBSCO],'"',''))

			aadd(aItens,aLinha)
		endIf

		geraLog("")
	Next nLinha

	//------------------------------------------
	//Verifica se houve itens exclu�dos
	//------------------------------------------
	If lOk .and. nOperacao <> 3
		cPedLocaliz		:= oLibCoupa:retNumPedido(cPedCoupa)
		If !Empty(cPedLocaliz)
			If SC7->(DbSeek( FwXfilial("SC7") + cPedLocaliz ))
				geraLog("Verificando se h� itens a serem ELIMINADO RES�DUO")

				While SC7->(!Eof()) .and. SC7->(C7_FILIAL+C7_NUM) == (FwXfilial("SC7") + cPedLocaliz)

					If Empty(SC7->C7_RESIDUO)
						For nIt := 1 to Len(aPedido)
							cItArray		:= StrZero(Val(aPedido[nIt,ITEM]),TamSx3("C7_ITEM")[1])

							If AllTrim(SC7->C7_ITEM) == cItArray
								lLocaliz		:= .T.
								exit
							else
								lLocaliz		:= .F.
							EndIf
						Next

						If !lLocaliz
							geraLog("Ir� eliminar o res�duo do item [" + SC7->C7_ITEM + "] do pedido")
							lElimResiduo	:= .T.
							lOk				:= eliminaResiduo( cPedCoupa , SC7->C7_ITEM, SC7->C7_QUANT )
							if !lOk
								exit
							endIf
						EndIf
					EndIf

					SC7->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	If Len(aItensEXC) > 0
		geraLog("Quantidade de itens a serem exclu�dos:" + cValToChar(Len(aItensEXC)))
		aAdd(aReturn,aClone(aItensEXC))
		aAdd(aReturn,{})
	Else
		aAdd(aReturn,aClone(aItens))
		aAdd(aReturn,aClone(aRatCC))
	EndIf

	RestArea(aAreaSC7)

Return aReturn

//-----------------------------------------------------------------
Static Function eliminaResiduo( cPedCoupa , cItem, nQtd )

	local aAreaSC7		:= SC7->(GetArea())
	local oLibCoupa		:= LibCoupa():New()
	local nRecPed		:= oLibCoupa:getRecItem(cPedCoupa,cItem)
	local nPerc			:= 0
	local lRet			:= .F.

	geraLog("Eliminando res�duo do Pedido/Item: [" + cPedCoupa + "/" + cItem + "]")
	geraLog("Recno Item: " + cValToChar(nRecPed) )

	If nRecPed > 0
		SC7->(DbSetOrder(1))
		SC7->(DbGoTo( nRecPed ))
		nPerc		:= (nQtd / SC7->C7_QUANT)*100

		geraLog("Percentual a eliminar: " + cValToChar(nPerc) )
		geraLog("Quantidade Original:" + cValToChar(SC7->C7_QUANT) )
		geraLog("Quantidade Entregue:" + cValToChar(SC7->C7_QUJE) )

		If nQtd <= SC7->C7_QUANT

			MA235PC(nPerc, 1, ;
				SC7->C7_EMISSAO, SC7->C7_EMISSAO, ;
				SC7->C7_NUM, SC7->C7_NUM, ;
				SC7->C7_PRODUTO, SC7->C7_PRODUTO, ;
				SC7->C7_FORNECE, SC7->C7_FORNECE, ;
				"", "", ;
				SC7->C7_ITEM, SC7->C7_ITEM,;
				, {})

			lRet		:= SC7->C7_RESIDUO == "S"
			If lRet
				geraLog("Elinado res�duo com sucesso!")
			else
				geraLog("ERRO na elimina��o de res�duo!")
			endif
		else
			geraLOg("Nada a ser eliminado res�duo.")
			geraLog("")
			lRet	:= .T.
		endif
	else
		geraLOg("N�o localizado!")
		geraLog("")
		lRet	:= .F.
	endif

	restArea(aAreaSC7)

return lRet

//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

	Conout("[" + DTOC(Date()) + " " + Time() + "] IMPPOCOUPA - " + cMensagem )

Return
