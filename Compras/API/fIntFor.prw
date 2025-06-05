#Include 'Protheus.ch'

#DEFINE    CPO_COD_INT          "A2_ZZINTCO"
#DEFINE    CPO_LOJ_INT          "A2_ZZINTLO"

#DEFINE     INTEGRADO           "1"
#DEFINE     NAO_INTEG           "2"
#DEFINE     ERRO_INTE           "3"

User Function fIntFor( lJob , lAltera )

	Local oWsdlExist
	Local oWsdlCria
	Local aOps          := {}
	Local aSimple       := {}
	Local lRet          := .F.
	Local lExist        := .F.
	Local cUrl          := GetNewPar("ZZ_URLINT","https://ymlllm-prd-protheus.totvscloud.com.br/ws/") + "WSINTFOR.apw?WSDL"
	Local cOperation    := "EXISTREG"
	Local cMsg          := ""
	Local cResponse     := ""
	Local cErro         := ""
	Local cLog          := ""

	Default lJob        := .F.
	Default lAltera     := .F.

	oWsdlCria := TWsdlManager():New()
	oWsdlCria:bNoCheckPeerCert  := .T. // Desabilita o check de CAs
	oWsdlCria:lVerbose          := .T.
	oWsdlCria:nTimeout		    := 120
	oWsdlCria:lProcResp 		:= .F.
	oWsdlCria:cSSLCACertFile    := "\CERTIF.pem"

	cOperation      := "INCFORN"
	If oWsdlCria:ParseURL( cUrl )
		If oWsdlCria:SetOperation( cOperation )
			if setItens(oWsdlCria,@cErro)
				cMsg    := trataMsg( oWsdlCria:GetSoapMsg() )

				lRet    := oWsdlCria:SendSoapMsg( cMsg )
				if lRet
					cResponse       := oWsdlCria:GetSoapResponse()
					lRet            := trataResp(cResponse,@cErro)
				else
					cErro       := oWsdlCria:cError
					lRet        := .F.
				endif
			else
				cErro       := oWsdlCria:cError
				lRet        := .F.
			endif
		else
			cErro       := oWsdlCria:cError
		endif
	Else
		cErro       := oWsdlCria:cError
	EndIf

	if !lExist
		if reclock("SA2",.F.)
			if lRet
				SA2->A2_ZZINTEG     := INTEGRADO
			else
				SA2->A2_ZZINTEG     := ERRO_INTE
			endif

			cLog                := SA2->A2_ZZLOG
			cLog                += DTOC(dDataBase) + "-" + Time() + CRLF + cErro + CRLF + CRLF

			SA2->A2_ZZLOG       := cLog
			SA2->(MsUnlock())
		endif
	endif

	If !lJob .and. !empty(cErro)
		//MsgInfo(cErro,ProcName() - " - Integração de Fornecedor")
	endIf

Return

static function trataMsg(cRetWS)

	local cRet      := ""

	cRet    := cRetWS
	cRet    := StrTran(cRet, '"', "'")
	cRet    := STRTRAN(cRet,"&","E")
	cRet    := strtran(cRet,"<?xml version='1.0' encoding='UTF-8' standalone='no' ?>","")

Return cRet

static function setItens(oWsdl,cErro)

	Local lRet          := .F.
	Local aComplex      := {}
	Local aCampos       := {}
	Local cCampo        := ""
	Local cTipo         := ""
	Local nY            := 0
	Local nQtdCampos    := 0
	Local nPos          := 0
	Local nID           := 0
	Local cConteudo     := {}
	Local aParents      := {}
	Local aSimple       := {}
	Local cParent       := "INCFORN#1"
	Local cParentItem   := ""

	Local cCodForAtu    := SA2->A2_COD
	Local cLojForAtu    := SA2->A2_LOJA

	aComplex    := oWsdl:NextComplex()

	if !setCabec(oWsdl,cParent,.F.)
		cErro       := oWsdl:cError
		return .f.
	endif

	aCampos     := bscCampos()

	while (ValType(aComplex) == "A")

		if (aComplex[2] == "STRUCTINTFOR") .And. (aComplex[5] == "INCFORN#1.CAMPOSINT#1.AFORN#1")
			nQtdCampos  := Len(aCampos)
		else
			nQtdCampos  := 0
		endIf

		lRet	:= oWsdl:SetComplexOccurs(aComplex[1], nQtdCampos)
		if  !lRet
			cErro   := "Erro ao definir elemento" + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( nQtdCampos ) + " ocorrencias."
			exit
		EndIf

		aComplex := oWsdl:NextComplex()
	endDo

	aSimple     := oWsdl:SimpleInput()

	if lRet
		for nY := 1 to Len(aCampos)
			cCampo      := aCampos[nY]

			if cCampo == CPO_COD_INT
				cConteudo       := cCodForAtu
			elseif cCampo == CPO_LOJ_INT
				cConteudo       := cLojForAtu
			else
				cTipo       := getsx3cache(cCampo,"X3_TIPO")

				if cTipo == "N"
					cConteudo   := cValToChar( SA2->&(cCampo) )
				elseif cTipo == "D"
					cConteudo   := DTOC( SA2->&(cCampo) )
				else
					cConteudo   := AllTrim( SA2->&(cCampo) )
				endif
			endif

			cParentItem     := "INCFORN#1.CAMPOSINT#1.AFORN#1.STRUCTINTFOR#"+cValToChar(nY)
			nPos            := aScan( aSimple, {|x| x[2] == "CCAMPO" .AND. x[5] == cParentItem })
			if nPos > 0
				nID         := aSimple[nPos][1]
				if oWsdl:SetValue(  nID , cCampo )
					nPos        := aScan( aSimple, {|x| x[2] == "CCONTEUDO" .AND. x[5] == cParentItem })
					if nPos > 0
						nID         := aSimple[nPos][1]
						if !oWsdl:SetValue( nID, cConteudo )
							lRet        := .F.
							cErro       := oWsdl:cError
						endif
					else
						lRet        := .F.
						cErro       := oWsdl:cError
					endif
				else
					lRet        := .F.
					cErro       := oWsdl:cError
				endif
			else
				lRet        := .F.
				cErro       := oWsdl:cError
			endif
		Next
	endif

return lRet

Static function setCabec(oWsdlExist,cParent,lFind)

	Local lRet          := .F.
	Local aParent		:= {}
	Local cEmp          := getnewpar("ZZ_EMPINT","01") //TODO
	Local cFil          := getnewpar("ZZ_FILINT","5000") //TODO
	Local cUsr          := getnewpar("ZZ_USRINT","admin") //TODO
	Local cPsw          := getnewpar("ZZ_PSWINT","") //TODO

	Local cCodForAtu    := SA2->A2_COD
	Local cLojForAtu    := SA2->A2_LOJA

	aParent		        := {cParent}

	lRet        := oWsdlExist:SetValPar( "CEMPATU"		, aParent, cEmp )
	If !lRet
		return
	else
		lRet    := oWsdlExist:SetValPar( "CFILATU"		, aParent, cFil )
	EndIf

	If !lRet
		return
	else
		lRet    := oWsdlExist:SetValPar( "CUSRINT"		, aParent, cUsr )
	EndIf

	If !lRet
		return
	else
		lRet    := oWsdlExist:SetValPar( "CPSWINT"		, aParent, cPsw )
	EndIf

	If !lRet
		return
	else
		if lFind
			lRet    := oWsdlExist:SetValPar( "CCODFOR"		, aParent, cCodForAtu )

			if lRet
				lRet       := oWsdlExist:SetValPar( "CLOJFOR"		, aParent, cLojForAtu )
			endif
		endif
	EndIf

return lRet

Static Function bscCampos()

	Local nI         := 0
	Local aRet       := {}
	Local aCposTab   := SA2->(DbStruct())
	Local cCampo     := ""

	Local lUsado    := .f.
	Local lReal     := .f.
	Local lPreenc   := .f.

	local cCpoNot           := Getnewpar("ZZ_NOTINTF","A2_CONTPRE/A2_RETISI/A2_CONTA/A2_USERLGI/A2_USRLGA/")

	For nI := 1 to Len(aCposTab)
		cCampo      := AllTrim( aCposTab[nI,1] )

		If !( "_FILIAL" $ cCampo ) .AND. !( cCampo $ cCpoNot )
			lUsado      := !Empty( getsx3cache( cCampo , "X3_USADO" ) )
			lReal       := getsx3cache( cCampo , "X3_CONTEXT" ) <> "V"
			lPreenc     := !Empty( SA2->&(cCampo) )

			If lUsado .and. lReal .and. lPreenc
				aAdd( aRet, cCampo )
			endif
		endif
	Next

	aAdd( aRet , CPO_COD_INT )
	aAdd( aRet , CPO_LOJ_INT )

Return aRet

Static function trataResp(cResponse,cErro)

	Local lRet      := .F.
	Local nPosIni   := 0
	Local nPosFim   := 0
	Local nLen      := 0
	Local cStatus   := ""
	Local cMsgRet   := ""
	Local cIniStat  := "<LSTATUS>"
	Local cIniMsg   := "<CMENSAGEM>"

	//----------------------------
	// BUSCA O RETORNO LOGICO
	//----------------------------
	nPosIni     := At( cIniStat , cResponse )
	nPosFim     := At( "</LSTATUS>" , cResponse )
	nPosIni     += Len(cIniStat)
	nLen        := nPosFim - nPosIni
	cStatus     := SubStr( cResponse, nPosIni , nLen )

	//----------------------------
	// BUSCA A MENSAGEM DE RETORNO
	//----------------------------
	nPosIni     := At( cIniMsg , cResponse )
	nPosFim     := At( "</CMENSAGEM>" , cResponse )
	nPosIni     += Len(cIniMsg)
	nLen        := nPosFim - nPosIni
	cMsgRet     := SubStr( cResponse, nPosIni , nLen )

	if cStatus == "true"
		lRet    := .T.
		cErro   := cMsgRet
	else
		lRet    := .F.
		cErro   := cMsgRet
	endif

Return lRet
