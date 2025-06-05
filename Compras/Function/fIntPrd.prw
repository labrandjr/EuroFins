#Include 'Protheus.ch'

#DEFINE    CPO_COD_INT          "B1_ZZINTC"

#DEFINE     INTEGRADO           "1"
#DEFINE     NAO_INTEG           "2"
#DEFINE     ERRO_INTE           "3"

User Function fIntPrd( lJob , lAltera )

    Local oWsdlExist
    Local oWsdlCria
    Local aOps          := {}
    Local lRet          := .F.
    Local lExist        := .F.
    Local cUrl          := GetNewPar("ZZ_URLINT","https://ymlllm-prd-protheus.totvscloud.com.br/ws/") + "WSINTPRD.apw?WSDL"
    Local cOperation    := "EXISTREG"
    Local cMsg          := ""
    Local cResponse     := ""
    Local cErro         := ""
    Local cLog          := ""

    Default lJob        := .F.
    Default lAltera     := .F.

    oWsdlExist := TWsdlManager():New()
    oWsdlExist:bNoCheckPeerCert := .T. // Desabilita o check de CAs   
    oWsdlExist:lVerbose          := .T.
    oWsdlExist:nTimeout		    := 120
    oWsdlExist:lProcResp 		:= .F.
    oWsdlExist:cSSLCACertFile    := "\CERTIF.pem"

    oWsdlCria := TWsdlManager():New()
    oWsdlCria:bNoCheckPeerCert  := .T. // Desabilita o check de CAs 
    oWsdlCria:lVerbose          := .T.
    oWsdlCria:nTimeout		    := 120
    oWsdlCria:lProcResp 		:= .F.
    oWsdlCria:cSSLCACertFile    := "\CERTIF.pem"

    cOperation      := "INCPROD"
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
                lRet        := .F.
            endif
        else
            cErro       := oWsdlCria:cError
        endif
    else
        cErro       := oWsdlCria:cError
    endif

    if !lExist
        if reclock("SB1",.F.)
            if lRet
                SB1->B1_ZZINTEG     := INTEGRADO
            else
                SB1->B1_ZZINTEG     := ERRO_INTE
            endif

            cLog                := SB1->B1_ZZLOG
            cLog                += DTOC(dDataBase) + "-" + Time() + CRLF + cErro + CRLF + CRLF

            SB1->B1_ZZLOG       := cLog
            SB1->(MsUnlock())

            updSB1(SB1->B1_COD,SB1->B1_ZZINTEG,SB1->B1_ZZLOG)
        endif
    endif

    If !lJob .and. !empty(cErro)
        //MsgInfo(cErro,ProcName() - " - Integração de Produtos")
    endIf

Return

static function updSB1(cCodProd,cStatus,cLog)

    local cExec         := ""

    cExec       := " UPDATE " + Retsqlname("SB1") + " SET "
    cExec       += " B1_ZZINTEG = '" + cStatus + "' "
    //cExec       += " ,B1_ZZLOG = '" + cLog + "' "
    cExec       += " WHERE D_E_L_E_T_ = ' ' AND "
    cExec       += " B1_COD = '" + cCodProd + "' "

    TcSqlExec(cExec)

return

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
    Local cParent       := "INCPROD#1"
    Local cParentItem   := ""

    Local cCodPrdAtu    := SB1->B1_COD

    aComplex    := oWsdl:NextComplex()

    if !setCabec(oWsdl,cParent,.F.)
        cErro       := oWsdl:cError
        return .f.
    endif

    aCampos     := bscCampos()

    while (ValType(aComplex) == "A")

        if (aComplex[2] == "STRUCTINTPRD") .And. (aComplex[5] == "INCPROD#1.CAMPOSINT#1.APROD#1")
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
                cConteudo       := cCodPrdAtu
            else
                cTipo       := getsx3cache(cCampo,"X3_TIPO")

                if cTipo == "N"
                    cConteudo   := cValToChar( SB1->&(cCampo) )
                elseif cTipo == "D"
                    cConteudo   := DTOC( SB1->&(cCampo) )
                else
                    cConteudo   := AllTrim( SB1->&(cCampo) )
                endif
            endif

            cParentItem     := "INCPROD#1.CAMPOSINT#1.APROD#1.STRUCTINTPRD#"+cValToChar(nY)
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

    Local cCodPrdAtu    := SB1->B1_COD

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
            lRet    := oWsdlExist:SetValPar( "CCODPROD"		, aParent, cCodPrdAtu )
        endif
    EndIf

return lRet

Static Function bscCampos()

    Local nI         := 0
    Local aRet       := {}
    Local aCposTab   := SB1->(DbStruct())
    Local cCampo     := ""

    Local lUsado    := .f.
    Local lReal     := .f.
    Local lPreenc   := .f.

    local cCpoNot           := Getnewpar("ZZ_PRDNOT1","B1_USERLGA/B1_USERLGI/B1_RASTRO/")
    local cCpoNot2          := Getnewpar("ZZ_PRDNOT2","")

    For nI := 1 to Len(aCposTab)
        cCampo      := AllTrim( aCposTab[nI,1] )

        If !( "_FILIAL" $ cCampo ) .AND. !( cCampo $ cCpoNot ) .AND. !( cCampo $ cCpoNot2 )
            lUsado      := !Empty( getsx3cache( cCampo , "X3_USADO" ) )
            lReal       := getsx3cache( cCampo , "X3_CONTEXT" ) <> "V"
            lPreenc     := !Empty( SB1->&(cCampo) )

            If lUsado .and. lReal .and. lPreenc
                aAdd( aRet, cCampo )
            endif
        endif
    Next

    aAdd( aRet , CPO_COD_INT )

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
