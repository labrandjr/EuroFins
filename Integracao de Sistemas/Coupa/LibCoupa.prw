#include 'protheus.ch'
#include 'topconn.ch'

#DEFINE INTEGRADO_ERRO      "N"
#DEFINE INTEGRADO_SUCESSO   "I"

//-----------------------------------------------------------------
/*/{Protheus.doc} LibCoupa
Classe de apoio as customizações da integração COUPA

@type		Class
@author		Julio Lisboa
@since		02/07/2020
/*/
//-----------------------------------------------------------------
class LibCoupa

	data cTipo              as string
	data cStatus            as string
	data cChave             as string
	data cOcorrencia        as string
	data lErro              as boolean
	data lPro2COupa         as boolean
	data cPedido            as string
	data cNF                as string
	data cArquivo           as string
	data cOperacao          as string

	method new() constructor

	method existCli()
	method gravaZZD()
	method retornaFilial()
	method limpaCaracteres()
	method excluiErros()
	method retornaAddress()
	method retConteudoArq()
	method pedidoJaRecebido()
	method retQtdNF()
	method getRecItem()
	method exisPedCoupa()
	method seqEntradaNF()
	method retNumPedido()
	method retMoeda()
	method existCC()
	method existProd()
	method isNFCoupa()
	method geraTitAdiant()
	method getMaxNumPA()
	method getValTotPed()
	method getErro()
	method geraCNPJZZC()
	method getCNPJFil()

	//Setters
	method setTipo()
	method setStatus()
	method setChave()
	method setOcorrencia()
	method setIsErro()
	method setPro2COupa()
	method setPedido()
	method setNF()
	method setArquivo()
	method setOperacao()

	//Getters
	method getTipo()
	method getStatus()
	method getChave()
	method getOcorrencia()
	method getIsErro()
	method getPro2COupa()
	method getPedido()
	method getNF()
	method getArquivo()
	method getOperacao()

endclass

//-----------------------------------------------------------------
/*/{Protheus.doc} LibCoupa
Metodo construtor da classe

@type		Method
@author		Julio Lisboa
@since		02/07/2020
/*/
//-----------------------------------------------------------------
method new() class LibCoupa

	self:cTipo              := ""
	self:cStatus            := ""
	self:cChave             := ""
	self:cOcorrencia        := ""
	self:lErro              := .F.
	self:lPro2COupa         := .F.
	self:cPedido            := ""
	self:cNF                := ""
	self:cArquivo           := ""
	self:cOperacao          := ""

return Self

//-----------------------------------------------------------------
method setTipo(cTipo) class LibCoupa
	self:cTipo      := cTipo
return .t.

//-----------------------------------------------------------------
method setStatus(cStatus) class LibCoupa
	self:cStatus      := cStatus
return .t.

//-----------------------------------------------------------------
method setChave(cChave) class LibCoupa
	self:cChave      := cChave
return .t.

//-----------------------------------------------------------------
method setOcorrencia(cOcorrencia) class LibCoupa
	self:cOcorrencia      := cOcorrencia
return .t.

//-----------------------------------------------------------------
method setIsErro(lErro) class LibCoupa
	self:lErro      := lErro
return .t.

//-----------------------------------------------------------------
method setPro2COupa(lPro2COupa) class LibCoupa
	if lPro2COupa
		self:lPro2COupa := .T.
	else
		self:lPro2COupa := .F.
	endif
return .t.

//-----------------------------------------------------------------
method setPedido(cPedido) class LibCoupa
	self:cPedido      := cPedido
return .t.

//-----------------------------------------------------------------
method setNF(cNF) class LibCoupa
	self:cNF      := cNF
return .t.

//-----------------------------------------------------------------
method setArquivo(cArquivo) class LibCoupa
	self:cArquivo      := cArquivo
return .t.

//-----------------------------------------------------------------
method setOperacao(cOperacao) class LibCoupa
	self:cOperacao      := cOperacao
return .t.

//-----------------------------------------------------------------
method getTipo() class LibCoupa
return self:cTipo

//-----------------------------------------------------------------
method getStatus() class LibCoupa
return self:cStatus

//-----------------------------------------------------------------
method getChave() class LibCoupa
return self:cChave

//-----------------------------------------------------------------
method getOcorrencia() class LibCoupa
return self:cOcorrencia

//-----------------------------------------------------------------
method getIsErro() class LibCoupa
return self:lErro

//-----------------------------------------------------------------
method getPro2COupa() class LibCoupa
return self:lPro2COupa

//-----------------------------------------------------------------
method getPedido() class LibCoupa
return self:cPedido

//-----------------------------------------------------------------
method getNF() class LibCoupa
return self:cNF

//-----------------------------------------------------------------
method getArquivo() class LibCoupa
return self:cArquivo

//-----------------------------------------------------------------
method getOperacao() class LibCoupa
return self:cOperacao

//-----------------------------------------------------------------
method existCli(cCod,cLoj) class LibCoupa
	local lRet		:= .F.

	lRet		:= !Empty( getAdvFVal("SA1", "A1_COD", FwxFilial("SA1") + cCod + cLoj, 1, "") )

return lRet

//-----------------------------------------------------------------
method gravaZZD() class LibCoupa

	Local lGravDate     := getnewpar("ZZ_ZCOUPDT",.T.)

	If Reclock("ZZD",.T.)
		ZZD->ZZD_COD        := GetSXEnum("ZZD","ZZD_COD")

		If lGravDate
			ZZD->ZZD_DATA       := Date()
		Else
			ZZD->ZZD_DATA       := dDataBase
		EndIf

		ZZD->ZZD_HORA       := Time()
		ZZD->ZZD_TIPO       := self:getTipo()

		if self:getIsErro()
			self:setStatus(INTEGRADO_ERRO)
		Else
			self:setStatus(INTEGRADO_SUCESSO)
		EndIf

		ZZD->ZZD_STATUS     := self:getStatus()
		ZZD->ZZD_CHAVE      := self:getChave()
		ZZD->ZZD_PEDIDO     := self:getPedido()
		ZZD->ZZD_DOC        := self:getNF()
		ZZD->ZZD_ARQ        := self:getArquivo()

		ZZD->ZZD_FILPRO     := cFilAnt
		ZZD->ZZD_CONTEU     := self:retConteudoArq()
		ZZD->ZZD_OPERAC     := self:getOperacao()

		If self:getPro2COupa()
			ZZD->ZZD_FLUXO      := "PROTHEUS PARA COUPA"
		else
			ZZD->ZZD_FLUXO      := "COUPA PARA PROTHEUS"
		endif

		ZZD->ZZD_OCORRE     := self:getOcorrencia()
		ZZD->ZZD_TEMPO      := DtoC(Date()) + " " + Time()
		ZZD->(MsUnlock())
		ConfirmSX8()
	EndIf

	If upper(alltrim(self:getOperacao())) == "ALTERACAO"

		cPedido := self:getPedido()
		cQuery := ""
		cQuery += "UPDATE " + RetSqlName("SC7") + " SET C7_XMODALT = '1' FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = ''
		cQuery += " AND C7_FILIAL = '" + cFilAnt + "'"
		cQuery += " AND C7_NUM = '" + cPedido + "'"
		cQuery += " AND C7_ENCER <> 'E' AND C7_QUJE = 0 AND C7_RESIDUO = ' '
		TcSqlExec(cQuery)

	EndIf

return

//-----------------------------------------------------------------
method retConteudoArq() class LibCoupa

	local cRet      := ""

	if file( self:getArquivo() )
		cRet        := MemoRead( self:getArquivo() )
	endif

return cRet

//-----------------------------------------------------------------
method seqEntradaNF() class LibCoupa

	local aAreaSD1  := SD1->(GetArea())
	local cQuery    := ""
	local cSeqPed   := ""
	local cAlias    := getnextAlias()

	cQuery	 += "SELECT" + CRLF
	cQuery	 += "	SC7.C7_FILIAL, SC7.C7_ZZCCOUP, SD1.R_E_C_N_O_ REC_SD1" + CRLF
	cQuery	 += "FROM" + CRLF
	cQuery	 += "   " + RetSqlTab("SC7") + CRLF
	cQuery	 += "	INNER JOIN" + CRLF
	cQuery	 += "		" + RetSqlTab("SD1") + CRLF
	cQuery	 += "		ON" + CRLF
	cQuery	 += "			D1_FILIAL          = C7_FILIAL" + CRLF
	cQuery	 += "			AND D1_PEDIDO      = C7_NUM" + CRLF
	cQuery	 += "			AND D1_ITEMPC      = C7_ITEM" + CRLF
	cQuery	 += "			AND D1_COD         = C7_PRODUTO" + CRLF
	cQuery	 += "			AND D1_FORNECE     = C7_FORNECE" + CRLF
	cQuery	 += "			AND SD1.D_E_L_E_T_ = ' '" + CRLF
	cQuery	 += "WHERE" + CRLF
	cQuery	 += "	SC7.D_E_L_E_T_  = ' '" + CRLF
	cQuery	 += "	AND C7_ZZCCOUP <> ' '" + CRLF
	cQuery	 += "	AND D1_ZZSQCOU  = ' '" + CRLF
	cQuery	 += "ORDER BY" + CRLF
	cQuery	 += "	SC7.C7_FILIAL, SC7.C7_ZZCCOUP" + CRLF

	TcQuery cQuery new alias &cAlias

	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	While (cAlias)->(!Eof())

		SD1->(DbGoTo( (cAlias)->REC_SD1 ))
		cSeqPed     := Self:retQtdNF( (cAlias)->C7_FILIAL , SD1->D1_PEDIDO )

		geraLog("Processando Recno SD1: " + cvaltochar((cAlias)->REC_SD1) )
		geraLog("Pedido Coupa: " + (cAlias)->C7_ZZCCOUP )
		geraLog("Sequencial: " + cSeqPed )

		If RecLock("SD1",.F.)
			SD1->D1_ZZSQCOU     := cSeqPed
			SD1->(MsUnlock())
		EndIf

		geraLog("")
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())

	RestArea(aAreaSD1)

return

//-----------------------------------------------------------------
method existCC(cCC) class LibCoupa

	local lRet      := .F.
	local cQuery    := ""
	local cAlias    := getnextalias()

	If !Empty(cCC)
		cQuery      += "SELECT " + CRLF
		cQuery      += "    COUNT(*) QTD  " + CRLF
		cQuery      += "FROM " + CRLF
		cQuery      += "    " + RetSqlTab("CTT") + CRLF
		cQuery      += "WHERE " + CRLF
		cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
		cQuery      += "    AND CTT_FILIAL = '" + FwxFilial("CTT") + "' " + CRLF
		cQuery      += "    AND CTT_CUSTO = '" + cCC + "' " + CRLF
		cQuery      += "" + CRLF

		TcQuery cQuery new Alias &cAlias

		if (cAlias)->(!Eof())
			lRet    := (cAlias)->QTD > 0
		endIf

		(cAlias)->(DbCloseArea())
	EndIf

Return lRet

//-----------------------------------------------------------------
method existProd(cCodProd,lBloq) class LibCoupa

	local lRet          := .F.
	local cQuery        := ""
	local cAlias        := getnextalias()

	default cCodProd    := ""
	default lBloq       := .F.

	If !Empty(cCodProd)
		cQuery      += "SELECT " + CRLF
		cQuery      += "    B1_MSBLQL" + CRLF
		cQuery      += "FROM " + CRLF
		cQuery      += "    " + RetSqlTab("SB1") + CRLF
		cQuery      += "WHERE " + CRLF
		cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
		cQuery      += "    AND B1_FILIAL = '" + FwxFilial("SB1") + "' " + CRLF
		cQuery      += "    AND UPPER(B1_COD) LIKE '%" + Upper(cCodProd) + "%' " + CRLF
		cQuery      += "" + CRLF

		TcQuery cQuery new Alias &cAlias

		if (cAlias)->(!Eof())
			lRet    := .T.
			lBloq   := AllTrim( (cAlias)->B1_MSBLQL ) == "1"
		endIf

		(cAlias)->(DbCloseArea())
	EndIf

Return lRet

//-----------------------------------------------------------------
method isNFCoupa(cFilNF,cDocNF,cSerieNF,cFornec,cLoja,cTipo) class LibCoupa

	local lRet          := .F.
	local cQuery        := ""
	local cAlias        := getnextalias()

	If !Empty(cFilNF) .and. !Empty(cDocNF) .and. !Empty(cSerieNF) .and. !Empty(cFornec)
		cQuery      += "SELECT " + CRLF
		cQuery      += "    COUNT(*) QTD " + CRLF
		cQuery      += "FROM " + CRLF
		cQuery      += "    " + RetSqlTab("SD1") + CRLF
		cQuery      += "INNER JOIN" + CRLF
		cQuery      += "    " + RetSqlTab("SC7") + CRLF
		cQuery      += "ON" + CRLF
		cQuery      += "        C7_FILIAL          = D1_FILIAL" + CRLF
		cQuery      += "        AND C7_NUM         = D1_PEDIDO" + CRLF
		cQuery      += "        AND C7_ITEM        = D1_ITEMPC" + CRLF
		cQuery      += "        AND C7_FORNECE     = D1_FORNECE" + CRLF
		cQuery      += "        AND SC7.D_E_L_E_T_ = ' '" + CRLF
		cQuery      += "WHERE " + CRLF
		cQuery      += "    SD1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery      += "    AND D1_FILIAL = '" + cFilNF + "' " + CRLF
		cQuery      += "    AND D1_DOC = '" + cDocNF + "' " + CRLF
		cQuery      += "    AND D1_SERIE = '" + cSerieNF + "' " + CRLF
		cQuery      += "    AND D1_FORNECE = '" + cFornec + "' " + CRLF
		cQuery      += "    AND D1_LOJA = '" + cLoja + "' " + CRLF
		cQuery      += "    AND D1_TIPO = '" + cTipo + "' " + CRLF
		cQuery      += "    AND C7_ZZCCOUP    <> ' '" + CRLF
		cQuery      += "" + CRLF

		TcQuery cQuery new Alias &cAlias

		if (cAlias)->(!Eof())
			lRet    := (cAlias)->QTD > 0
		endIf

		(cAlias)->(DbCloseArea())
	EndIf

Return lRet

//-----------------------------------------------------------------
method retMoeda(cMoedaCoupa) class LibCoupa

	local nRet      := 0
	local cQuery    := ""
	local cAlias    := getnextalias()

	If !Empty(cMoedaCoupa)
		If AllTrim(cMoedaCoupa) == "BRL"
			nRet        := 1
		Else
			cQuery      += "SELECT " + CRLF
			cQuery      += "    ZZF_CODPRO " + CRLF
			cQuery      += "FROM " + CRLF
			cQuery      += "    " + RetSqlTab("ZZF") + CRLF
			cQuery      += "WHERE " + CRLF
			cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
			cQuery      += "    AND ZZF_CODCOU = '" + cMoedaCoupa + "' " + CRLF
			cQuery      += "" + CRLF

			TcQuery cQuery new Alias &cAlias

			if (cAlias)->(!Eof())
				nRet    := (cAlias)->ZZF_CODPRO
			endIf

			(cAlias)->(DbCloseArea())
		endIf
	EndIf

Return nRet

//-----------------------------------------------------------------
method retNumPedido(cPedCoupa) class LibCoupa

	local cRet      := ""
	local cQuery    := ""
	local cAlias    := getnextalias()

	cQuery      += "SELECT " + CRLF
	cQuery      += "    C7_NUM " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("SC7") + CRLF
	cQuery      += "WHERE " + CRLF
	cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery      += "    AND C7_ZZCCOUP = '" + cPedCoupa + "' " + CRLF
	cQuery      += "" + CRLF

	TcQuery cQuery new Alias &cAlias

	if (cAlias)->(!Eof())
		cRet    := (cAlias)->C7_NUM
	endIf

	(cAlias)->(DbCloseArea())

Return cRet

return cRet

//-----------------------------------------------------------------
method exisPedCoupa(cPedCoupa) class LibCoupa

	local lRet      := .F.
	local cQuery    := ""
	local cAlias    := getnextalias()

	cQuery      += "SELECT " + CRLF
	cQuery      += "    COUNT(*) QTD " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("SC7") + CRLF
	cQuery      += "WHERE " + CRLF
	cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery      += "    AND C7_ZZCCOUP = '" + cPedCoupa + "' " + CRLF
	cQuery      += "" + CRLF

	TcQuery cQuery new Alias &cAlias

	if (cAlias)->(!Eof())
		lRet    := (cAlias)->QTD > 0
	endIf

	(cAlias)->(DbCloseArea())

Return lRet

//-----------------------------------------------------------------
method getRecItem(cNumPed,cItemPed) class LibCoupa

	local nRet      := 0
	local cQuery    := ""
	local cAlias    := getnextalias()

	cQuery      += "SELECT " + CRLF
	cQuery      += "    SC7.R_E_C_N_O_ REC_SC7 " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("SC7") + CRLF
	cQuery      += "WHERE " + CRLF
	cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery      += "    AND C7_ZZCCOUP = '" + cNumPed + "' " + CRLF
	cQuery      += "    AND C7_ITEM = '" + cItemPed + "' " + CRLF
	cQuery      += "" + CRLF

	geraLog("Query RECNO: " + changequery(cQuery))

	TcQuery cQuery new Alias &cAlias

	if (cAlias)->(!Eof())
		nRet    := (cAlias)->REC_SC7
	endIf

	(cAlias)->(DbCloseArea())

return nRet

//-----------------------------------------------------------------
method retQtdNF(cFilPed,cNumPed) class LibCoupa

	local cRet      := ""
	local cQuery    := ""
	local cAlias    := getnextalias()

	cQuery      += "SELECT " + CRLF
	cQuery      += "    MAX(D1_ZZSQCOU) SEQ " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("SD1") + CRLF
	cQuery      += "WHERE " + CRLF
	cQuery      += "    1=1 " + CRLF
	cQuery      += "    AND D1_FILIAL = '" + cFilPed + "' " + CRLF
	cQuery      += "    AND D1_PEDIDO = '" + cNumPed + "' " + CRLF
	cQuery      += "" + CRLF

	TcQuery cQuery new Alias &cAlias

	geraLog("Query QTD NF:" + changequery(cQuery))

	if (cAlias)->(!Eof())
		If Empty( (cAlias)->SEQ )
			cRet    := "01"
		Else
			cRet    := Soma1( (cAlias)->SEQ )
		EndIf
	endIf

	If Empty(cRet)
		cRet    := "01"
	EndIf

	(cAlias)->(DbCloseArea())

return cRet

//-----------------------------------------------------------------
method pedidoJaRecebido(cPedido) class LibCoupa

	local lRet          := .F.
	local cQuery        := ""
	local cAlias        := getnextalias()

	default cPedido     := ""

	if !empty(cPedido)
		cQuery := "SELECT COUNT(*) nCount"
		cQuery += " FROM "+RetSqlName("SC7")+" SC7"
		cQuery += " WHERE (SC7.C7_FILIAL = '"+xFilial("SC7")+"')"
		cQuery += " AND (SC7.C7_QUANT > SC7.C7_QUJE) "
		cQuery += " AND (SC7.C7_RESIDUO <> 'S') "
		cQuery += " AND (SC7.C7_NUM = '"+cPedido+"') "
		cQuery += " AND (SC7.D_E_L_E_T_ <> '*')"

		TcQuery cQuery new alias &cAlias

		if (cAlias)->(!eof())
			if (cAlias)->nCount == 0
				lRet    := .T.
			endif
		endif

		(cAlias)->(DbCloseArea())
	endif

return lRet

//-----------------------------------------------------------------
method excluiErros() class LibCoupa

	local aAreaZZD      := ZZD->(GetArea())
	local cQuery        := ""
	local cAlias        := getnextalias()
	local cErroAtu      := ""

	cQuery      += "SELECT " + CRLF
	cQuery      += "    DISTINCT R_E_C_N_O_ RECNO_ZZD " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("ZZD") + CRLF
	cQuery      += "WHERE " + CRLF
	cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery      += "    AND ZZD_CHAVE = '" + Self:getChave() + "' " + CRLF
	cQuery      += "    AND ZZD_TIPO = '" + Self:getTipo() + "' " + CRLF
	cQuery      += "    AND ZZD_STATUS = '" + INTEGRADO_ERRO + "' " + CRLF
	cQuery      += "" + CRLF

	TcQuery cQuery new Alias &(cAlias)

	If (cAlias)->(!Eof())
		ZZD->(DbSetOrder(1)) //ZZD_FILIAL+ZZD_COD+ZZD_TEMPO

		While (cAlias)->(!Eof())

			ZZD->(DbGoTo( (cAlias)->RECNO_ZZD ))
			If RecLock("ZZD",.F.)
				cErroAtu        := Replicate("*",20) + CRLF
				cErroAtu        += "DELETADO EM " + DTOC(dDataBase) + " "
				cErroAtu        += Time() + CRLF
				cErroAtu        += Replicate("*",20)
				cErroAtu        += CRLF + CRLF
				cErroAtu        += ZZD->ZZD_OCORRE

				ZZD->ZZD_OCORRE := cErroAtu

				ZZD->(DbDelete())
				ZZD->(MsUnlock())
			EndIf

			(cAlias)->(DbSkip())
		EndDo
	EndIf

	(cAlias)->(DbCloseArea())

	restArea(aAreaZZD)

Return

//-----------------------------------------------------------------
method limpaCaracteres(cTexto) class LibCoupa

	local aCaracteres		:= {}
	local nI				:= 0
	local cRet				:= AllTrim( cTexto )

	aAdd( aCaracteres , "/" )
	aAdd( aCaracteres , "\" )
	aAdd( aCaracteres , "." )
	aAdd( aCaracteres , "-" )
	aAdd( aCaracteres , ";" )
	aAdd( aCaracteres , "," )

	For nI := 1 to Len(aCaracteres)
		cRet		:= StrTran( cRet , aCaracteres[nI] , "" )
	Next

return cRet

//-----------------------------------------------------------------
method retornaFilial(cCenCusto,cID,cEntity,cCNPJFil) class LibCoupa

	local cFilialRet 	:= ""
	local cQuery     	:= ""
	local cAliasFil  	:= GetNextAlias()
	local aAreaSM0		:= {}

	default cCenCusto   := ""
	default cID			:= ""
	default cEntity		:= ""
	default cCNPJFil	:= ""

	If !empty(cCenCusto) .and. !empty(cID)
		cQuery  += "SELECT " + CRLF
		cQuery  += "    ZZC_FILCLI " + CRLF
		cQuery  += "FROM " + CRLF
		cQuery  += "    " + RetSqlTab("ZZC") + CRLF
		cQuery  += "WHERE " + CRLF
		cQuery  += "    D_E_L_E_T_ = ' ' " + CRLF
		cQuery  += "    AND ZZC_CCUSTO = '" + cCenCusto + "' " + CRLF
		cQuery  += "    AND ZZC_ID = '" + cID + "' " + CRLF

		if !empty(cEntity)
			cQuery  += "    AND ZZC_LE = '" + cEntity + "' " + CRLF
		endif

		if ZZC->(FieldPos("ZZC_CNPJ")) > 0 .and. !empty(cCNPJFil)
			cQuery  += "    AND ZZC_CNPJ = '" + cCNPJFil + "' " + CRLF
		endif

		cQuery  += "" + CRLF

		TcQuery cQuery New Alias &cAliasFil

		DbSelectArea(cAliasFil)
		(cAliasFil)->(DbGoTop())
		cFilialRet := (cAliasFil)->ZZC_FILCLI
		(cAliasFil)->(DbCloseArea())
	endif

Return cFilialRet
//-----------------------------------------------------------------
method retornaAddress(cCentroCusto) class LibCoupa

	local cQuery   := ""
	local cAliasCC := GetNextAlias()
	local cRetorno := ""

	cQuery += "SELECT ZZC_LE FROM " + RetSqlTab("ZZC") + CRLF
	cQuery += " WHERE ZZC_FILCLI = '" + cFilAnt + "' " + CRLF
	cQuery += "     AND ZZC_CCUSTO = '" + AllTrim(cCentroCusto) + "' " + CRLF
	cQuery += "     AND ZZC.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias &cAliasCC

	DbSelectArea(cAliasCC)
	(cAliasCC)->(DbGoTop())
	cRetorno := (cAliasCC)->ZZC_LE
	(cAliasCC)->(DbCloseArea())

Return cRetorno

//-----------------------------------------------------------------
method geraTitAdiant(lOk,cNumPed,cErro) class LibCoupa

	local lRet              := .T.
	local aTitulo           := {}
	local aRecnoSE2         := {}
	local cPrefixo          := ""
	local cNum              := ""
	local cParcela          := ""
	local cTipoTitulo       := "PA"
	local dVencto           := MonthSum( dDataBase, 1 )
	local cNatFinanceira    := getnewpar("ZZ_PATNTRZ","0202005")
	local aAreaSC7          := SC7->(GetArea())

	local cBcoPA			:= getnewpar("ZZ_BCOPA","341")
	local cAGePA			:= getnewpar("ZZ_AGEPA","3128")
	local cConPA			:= getnewpar("ZZ_CCPA","02090")

	private lMsErroAuto 	:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile  := .T.

	If lOk
		SC7->(DbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
		SC7->(DbSeek( FwxFilial("SC7") + cNumPed ))

		lRet    := .F.
		cNum    := GetSXEnum("SE2","E2_NUM") //self:getMaxNumPA()        //TODO
		nValor  := self:getValTotPed(cNumPed)       //TODO

		Aadd(aTitulo,{"E2_FILIAL" 		,xFilial("SE2")	  				,Nil})
		Aadd(aTitulo,{"E2_PREFIXO"		,cPrefixo						,Nil})
		Aadd(aTitulo,{"E2_NUM"    		,cNum							,Nil})
		Aadd(aTitulo,{"E2_PARCELA"		,cParcela						,Nil})
		Aadd(aTitulo,{"E2_TIPO"   		,cTipoTitulo					,Nil})
		Aadd(aTitulo,{"E2_NATUREZ"		,cNatFinanceira					,Nil})
		Aadd(aTitulo,{"E2_FORNECE"		,SC7->C7_FORNECE                ,Nil})
		Aadd(aTitulo,{"E2_LOJA"   		,SC7->C7_LOJA                   ,Nil})
		Aadd(aTitulo,{"E2_EMISSAO"		,dDataBase						,Nil})
		Aadd(aTitulo,{"E2_VENCTO" 		,dVencto                        ,Nil})
		Aadd(aTitulo,{"E2_VALOR"  		,nValor							,Nil})
		Aadd(aTitulo,{"E2_HIST"   		,"PC " + cNumPed	            ,Nil})
		Aadd(aTitulo,{"E2_ORIGEM"   	,"FINA050"						,Nil})

		Aadd(aTitulo,{"AUTBANCO"  		,cBcoPA							,Nil})
		Aadd(aTitulo,{"AUTAGENCIA"  	,cAGePA							,Nil})
		Aadd(aTitulo,{"AUTCONTA"  		,cConPA							,Nil})

		aTitulo		:= FwVetByDic( aTitulo , "SE2" , .F. )

		MsExecAuto( {|x,y,z| FINA050(x,y,z) } , aTitulo,, 3 )

		If lMsErroAuto
			lRet    := .F.
			cErro	:= self:getErro()
			RollBackSX8()
		Else
			aAdd( aRecnoSE2 , { cNumPed , SE2->(Recno()) , nValor } )
			FPedAdtGrv("P", 1, cNumPed, aRecnoSE2)
			lRet    := .T.
			ConfirmSX8()
		EndIf
	EndIf

	RestArea(aAreaSC7)

return lRet

//-----------------------------------------------------------------
method getMaxNumPA() class LibCoupa

	local cRet      := ""
	local cQuery    := ""
	local cAlias    := getnextalias()

	cQuery      += "SELECT " + CRLF
	cQuery      += "    MAX(E2_NUM) NUMERO " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("SE2") + CRLF
	cQuery      += "WHERE " + CRLF
	cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery      += "    AND E2_FILIAL = '" + FwxFilial("SE2") + "' " + CRLF
	cQuery      += "    AND E2_TIPO = 'PA' " + CRLF
	cQuery      += "" + CRLF

	TcQuery cQuery new Alias &cAlias

	if (cAlias)->(!Eof())
		cRet        := Soma1( (cAlias)->NUMERO )
	Else
		cRet        := "1"
	endIf

	cRet            := PadL(cRet,TamSx3("E2_NUM")[1],"0")

	(cAlias)->(DbCloseArea())

return cRet

//-----------------------------------------------------------------
method getValTotPed(cNumPed) class LibCoupa

	local nRet      := 0
	local cQuery    := ""
	local cAlias    := getnextalias()

	cQuery      += "SELECT " + CRLF
	cQuery      += "    SUM(C7_TOTAL) TOTAL " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("SC7") + CRLF
	cQuery      += "WHERE " + CRLF
	cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery      += "    AND C7_FILIAL = '" + FwxFilial("SC7") + "' " + CRLF
	cQuery      += "    AND C7_NUM = '" + cNumPed + "' " + CRLF
	cQuery      += "    AND C7_TIPO = '1' " + CRLF
	cQuery      += "" + CRLF

	TcQuery cQuery new Alias &cAlias

	if (cAlias)->(!Eof())
		nRet        := (cAlias)->TOTAL
	endIf

	(cAlias)->(DbCloseArea())

return nRet

//-----------------------------------------------------------------
method getErro() class LibCoupa

	local cRet		:= ""
	local aLog		:= {}
	local nI		:= 0

	aLog := GetAutoGrLog()
	For nI := 1 to Len(aLog)
		if !empty(aLog[nI])
			cRet += allTrim(aLog[nI])
		endif
	Next nI

return cRet


//-----------------------------------------------------------------
method getCNPJFil(cCodFil) class LibCoupa

	local cRet		:= ""
	local aSalvSM0 	:= SM0->( GetArea() )

	dbSelectArea( "SM0" )
	dbSetOrder( 1 )
	dbGoTop()
	While !SM0->( EOF() )
		If AllTrim( SM0->M0_CODFIL ) == cCodFil
			cRet	:= SM0->M0_CGC
			exit
		EndIf
		dbSkip()
	EndDo

	RestArea( aSalvSM0 )

return cRet

//-----------------------------------------------------------------
method geraCNPJZZC() class LibCoupa

	local cQuery    := ""
	local cCNPJFil	:= ""
	local cAlias    := getnextalias()
	local aAreaZZC	:= ZZC->(GetArea())

	If ZZC->(FieldPos("ZZC_CNPJ")) > 0
		cQuery      += "SELECT " + CRLF
		cQuery      += "    ZZC.R_E_C_N_O_ REC_ZZC " + CRLF
		cQuery      += "FROM " + CRLF
		cQuery      += "    " + RetSqlTab("ZZC") + CRLF
		cQuery      += "WHERE " + CRLF
		cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
		cQuery      += "    AND ZZC_CNPJ = ' ' " + CRLF
		cQuery      += "" + CRLF

		TcQuery cQuery new Alias &cAlias

		ZZC->(DbSetOrder(1))
		while (cAlias)->(!Eof())

			ZZC->(DbGoTo( (cAlias)->REC_ZZC ))
			cCNPJFil		:= self:getCNPJFil( ZZC->ZZC_FILCLI )

			If !Empty(cCNPJFil)
				If RecLock("ZZC",.F.)
					ZZC->ZZC_CNPJ	:= cCNPJFil
					ZZC->(MsUnlock())
				EndIf
			EndIf

			(cAlias)->(DbSkip())
		endDo

		(cAlias)->(DbCloseArea())
		RestArea(aAreaZZC)
	Endif

return
//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

	Conout("[" + DTOC(Date()) + " " + Time() + "] LibCoupa - " + cMensagem )

Return
