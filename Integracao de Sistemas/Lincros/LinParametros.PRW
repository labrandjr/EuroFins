#Include 'Totvs.ch'
#Include 'TopConn.ch'

#DEFINE POS_EXIST       01
#DEFINE POS_PARAM       02
#DEFINE POS_TIPO        03
#DEFINE POS_DESCR       04
#DEFINE POS_CONTE       05

#DEFINE TEXT_ERRO       "#ERRO"
#DEFINE NAO_LOCALIZ     "Parâmetro não encontrado"

#DEFINE TITULO			"Configuração de Parâmetros"

#DEFINE N_OK            01
#DEFINE N_PARAM         02
#DEFINE N_TIPO          04
#DEFINE N_CONTEUDO      05

//-----------------------------------------------------------------
/*/{Protheus.doc} LinParametros
Tela da configuraçao de parâmetros

@type		Function
@author		Régis Ferreira
@since		01/12/2022
/*/
//-----------------------------------------------------------------
user function LinParametros()

    Private aParametros   := {}
    Private aEditCpo      := {"CONTEUD"}
    Private aHeader       := {}
    Private aItens        := {}

    aAdd( aParametros , { .F. , "ZZ_LINCR01" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR02" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR03" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR04" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR05" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR06" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR07" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR08" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR09" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR10" , "", , } )
    aAdd( aParametros , { .F. , "ZZ_LINCR11" , "", , } )
    
    If FwIsAdmin() .or. RetCodUsr() $ Alltrim(SuperGetMV("ZZ_LINCR11",.F.,"000000"))
        FWMsgRun( ,{ || vldPar() , montaGrid() } ,FunDesc(), "Iniciando, Aguarde..."  )
        montaTela()
    Else
        MsgInfo("A rotina só pode ser utilizada por usuários administradores.",FunDesc())
    EndIf

Return

static function montaTela()

    Local cValid		:= "AlwaysTrue()"

    Local lAltGrid      := 240
    Local lLargGrid     := 545

    Local lLinButSair   := 250
    Local lColButSair   := 490

    Local lLinButOk   := 250
    Local lColButOk   := 425

    Private oDlg
    Private oGetDados

    Define MsDialog oDlg From 0,0 to 550,1100 Pixel Title TITULO
    oGetDados :=	MsNewGetDados():New(010,10,lAltGrid,lLargGrid,GD_UPDATE,cValid,cValid,"",aEditCpo,,,,,,oDlg,aHeader,aItens)

    @ lLinButOk,lColButOk Button        "Salvar"      		of oDlg Size 45,15 Pixel Action ( salvarPar() )
    @ lLinButSair,lColButSair Button    "Fechar"      		of oDlg Size 45,15 Pixel Action (oDlg:End())
    Activate MsDialog oDlg Centered

Return

static function montaGrid()

    local nI            := 0
    local cOk           := ""
    Local nTamConteud   := 100

    //Aadd(aHeader,{cTitulo,AllTrim(SX3->X3_CAMPO),SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,,,SX3->X3_TIPO,SX3->X3_F3})
    Aadd(aHeader,{"OK","OK","@BMP",2,0,,,"C",""})
    Aadd(aHeader,{"Parâmetro","PARAM","",10,0,,,"C",""})
    Aadd(aHeader,{"Descrição","DESCRI","",100,0,,,"C",""})
    Aadd(aHeader,{"Tipo","TIPO","",1,0,,,"C",""})
    Aadd(aHeader,{"Conteudo","CONTEUD","",100,0,,,"C",""})

    for nI := 1 to len( aParametros )
        if aParametros[nI,POS_EXIST]
            cOk     := "BR_VERDE"
        Else
            cOk     := "BR_VERMELHO"
        EndIf

        aAdd( aItens , { cOk , aParametros[nI,POS_PARAM] , aParametros[nI,POS_DESCR] , aParametros[nI,POS_TIPO] , PadR( aParametros[nI,POS_CONTE] , nTamConteud ) , .F. } )
    next

return

static function salvarPar()

    Local aLinhas       := {}
    Local nLinha        := 0
    Local cParam        := ""
    Local cTipo         := ""
    Local lOk           := .T.
    Local xConteudo

    If !MsgYesNo("Deseja salvar os parâmetros com os conteúdos da tela ?",FunDesc())
        return
    EndIf

    aLinhas := AClone( oGetDados:aCols )
    For nLinha := 1 to len(aLinhas)

        cParam  := aLinhas[nLinha,N_PARAM]
        cTipo   := aLinhas[nLinha,N_TIPO]

        If aLinhas[nLinha,N_OK] == "BR_VERDE"
            If cTipo == "N"
                xConteudo       := Val( aLinhas[nLinha,N_CONTEUDO] )
            ElseIf cTipo == "L"
                xConteudo       := AllTrim( Upper( AllToChar( aLinhas[nLinha,N_CONTEUDO] ) ) )
                if xConteudo == ".T." .or. xConteudo == "T"
                    xConteudo   := .T.
                    lOk         := .T.
                Elseif xConteudo == ".F." .or. xConteudo == "F"
                    xConteudo   := .F.
                    lOk         := .T.
                Else
                    lOk         := .F.
                EndIf
            ElseIf cTipo == "D"
                xConteudo   := STOD( aLinhas[nLinha,N_CONTEUDO] )
                If Empty(xConteudo)
                    xConteudo       := CTOD( aLinhas[nLinha,N_CONTEUDO] )
                    If Empty( xConteudo )
                        lOk     := .F.
                    EndIf
                EndIf
            Else
                xConteudo       := AllTrim( aLinhas[nLinha,N_CONTEUDO] )
            EndIf

            If !lOk
                MsgAlert("Por gentileza, corrija o conteudo do parâmetro [" + cParam + "] na linha [" + cValToChar(nLinha) + "].",FunDesc())
                exit
            Else
                PutMv( cParam , xConteudo )
            EndIf
        EndIf

        xConteudo   := nil
    Next

    If lOk
        MsgAlert("Parâmetros salvos com sucesso!",FunDesc())
        oDlg:End()
    EndIf

Return

static function vldPar()

    Local nY        := 1
    Local cParam    := ""

    For nY := 1 to Len( aParametros )
        cParam      := aParametros[nY,POS_PARAM]
        If AllTrim( AllToChar( getNewPar(cParam, TEXT_ERRO ) ) ) == TEXT_ERRO
            aParametros[nY,POS_EXIST]   := .F.
            aParametros[nY,POS_DESCR]   := NAO_LOCALIZ
            aParametros[nY,POS_CONTE]   := NAO_LOCALIZ
        Else
            aParametros[nY,POS_EXIST]   := .T.
            aParametros[nY,POS_DESCR]   := retParam(cParam,1)
            aParametros[nY,POS_TIPO]    := retParam(cParam,2)
            aParametros[nY,POS_CONTE]   := GetMv(cParam)
        EndIf
    Next

Return

static function retParam(cParam,nTipo)

    local cRet          := ""
    local cQuery        := ""
    local cAlias        := getnextAlias()

    cQuery  += "SELECT " + CRLF

    If nTipo == 1
        cQuery  += "    X6_DESCRIC,X6_DESC1,X6_DESC2 " + CRLF
    Else
        cQuery  += "    X6_TIPO " + CRLF
    EndIf

    cQuery  += "FROM " + CRLF
    cQuery  += "    SX6" + AllTrim(cEmpAnt) + "0 " + CRLF
    cQuery  += "WHERE " + CRLF
    cQuery  += "    D_E_L_E_T_ = ' ' " + CRLF
    cQuery  += "    AND X6_VAR = '" + cParam + "'" + CRLF
    cQuery  += "" + CRLF

    TcQuery cQuery new Alias &cAlias

    If (cAlias)->(!Eof())
        If nTipo == 1
            cRet    := AllTrim( (cAlias)->X6_DESCRIC )
            cRet    += space(1) + AllTrim( (cAlias)->X6_DESC1 )
            cRet    += space(1) + AllTrim( (cAlias)->X6_DESC2 )
        Else
            cRet    := AllTrim( (cAlias)->X6_TIPO )
        EndIf
    Else
        If nTipo == 1
            cRet    := NAO_LOCALIZ
        EndIf
    EndIf

    (cAlias)->(DbCloseArea())

return cRet
