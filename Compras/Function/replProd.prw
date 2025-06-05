#include 'protheus.ch'
#include 'parmtype.ch'
#include "RWMAKE.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} replProd
Função que replica o produto que acabou de ser incluído.
@author Unknown
@since 16/10/2017
/*/


user function replProd ()
    local aFilInc := getFiliais()
    local i

    private lMsErroAuto := .F.

    beginTran()
    for i:=1 to len(aFilInc)
        incluiProduto(aFilInc[i])
    next

    if lMsErroAuto
        msgAlert("Não foi possível efetuar a "+IIF(INCLUI,"inclusão","alteração")+" para filiais restantes.","Aviso")
        disarmTransaction()
    else
        msgAlert(IIF(INCLUI,"Inclusão","Alteração")+" efetuada com sucesso para filiais restantes.","Aviso")
        endTran()
    endif
return lMsErroAuto

static function getFiliais()
    local aFiliais := FWLoadSM0()
    local aFilSel := {}
    local i

    ProcRegua(len(aFiliais))

    for i := 1 to len(aFiliais)

        if !(subStr(aFiliais[i][2],1,1) $ 'CG')
            if (cFilAnt <> aFiliais[i][2])
                aAdd(aFilSel,aFiliais[i][2])
            endif
        endif
    next
return aFilSel

static function incluiProduto(cFilInc)
    local cEmpOrig  := cEmpAnt
    local cFilOrig	:= cFilAnt
    local aVetor := {}
    local nCntSB1 := 0
    local cCampo := ""
    local xConteudo
    local cEmpInc := cEmpAnt
    local cConta := ""
    local lAltConta := .F.
    Local nPosFil	:= 0
    Local lIsblind := IsBlind()
    Local aArea := GetArea()

    IncProc("Realizando replica para filial " + cFilInc + "...")

    dbSelectArea("SB1")
    dbSetOrder(1)
    if !dbSeek(cFilInc+SB1->B1_COD)
        If lIsblind
            Conout("Produto não localizado na filial "+cFilInc)
            INCLUI:=.T.
            ALTERA:=.F.
        Else
            Alert("Produto não localizado na filial "+cFilInc)
        EndIf
    endif
    SB1->(RESTAREA(aArea))
    
    for nCntSB1 := 1 to SB1->(fCount())
        lOk := .t.
        cCampo := SB1->(FieldName(nCntSB1))
        xConteudo := SB1->(FieldGet(nCntSB1))

        dbSelectArea('SX3')
        dbSetOrder(2)
        if dbSeek(cCampo)
            if !X3Uso(SX3->X3_USADO)
                lOk := .f.
            endif

            if SX3->X3_TIPO == "C" .and. Empty(Alltrim(xConteudo))
                lOk := .f.
            endif

            if SX3->X3_TIPO == "N" .and. xConteudo == 0
                lOk := .f.
            endif

            if SX3->X3_TIPO == "D" .and. xConteudo == ctod("  /  /  ")
                lOk := .f.
            endif

            if ALLTRIM(SX3->X3_FOLDER) == "3"
                lOk := .f.
            endif

            if ValType(xConteudo) <> SX3->X3_TIPO
                lOk := .f.
            endif
        else
            lOk := .f.
        endif

        dbSelectArea("SB1")

        if !lOk
            loop
        endif

        if cCampo <> "B1_TRIBMUN" .and.;
                cCampo <> "B1_CNAE" .and.;
                cCampo <> "B1_USERLGI"  .and.;
                cCampo <> "B1_USERLGI" .and.  ;
                cCampo <> "B1_MOPC"
            if ALTERA
                dbSelectArea("SB1")
                dbSetOrder(1)
                if !dbSeek(cFilInc+SB1->B1_COD)
                    If lIsblind
                        Conout("Produto não localizado na filial "+cFilInc)
                    Else
                        Alert("Produto não localizado na filial "+cFilInc)
                    EndIf
                endif
            endif

            if INCLUI

                if cCampo == "B1_ZZCCUST" .and. SB1->B1_TIPO == "SA"
                    xConteudo := "99"
                elseif cCampo == "B1_TE"
                    xConteudo := ""
                elseif cCampo == "B1_TS"
                    xConteudo := ""
                elseif cCampo == "B1_CONTA" .and. SB1->B1_TIPO == "SA"
                    xConteudo := ""
                elseif cCampo == "B1_CC"
                    xConteudo := ""
                elseif cCampo == "B1_ITEMCC"
                    xConteudo := ""
                elseif cCampo == "B1_ALIQISS"
                    xConteudo := 0
                elseif cCampo == "B1_CODISS"
                    xConteudo := ""
                elseif cCampo == "B1_MSBLQL"
                    xConteudo := "1"
                elseif cCampo == "B1_FILIAL"
                    xConteudo := cFilInc
                endif

                aAdd (aVetor, {cCampo,xConteudo,Nil})

            endif

            if ALTERA

                if cCampo <> "B1_ZZCCUST" .and.;
                        cCampo <> "B1_TE" .and.;
                        cCampo <> "B1_TS" .and.;
                        cCampo <> "B1_CC" .and.;
                        cCampo <> "B1_ITEMCC" .and.;
                        cCampo <> "B1_ALIQISS" .and.;
                        cCampo <> "B1_CODISS" .and.;
                        cCampo <> "B1_TRIBMUN" .and.;
                        cCampo <> "B1_CNAE" .and.;
                        cCampo <> "B1_ZZSGPRD" .and.;
                        cCampo <> "B1_ZZSUBGR" .and.;
                        cCampo <> "B1_TIPO"

                    if cCampo == "B1_CONTA"
                        if SB1->B1_TIPO <> "SA"
                            //	aAdd (aVetor, {cCampo,xConteudo,Nil})
                            cConta := xConteudo
                            lAltConta := .T.
                        else
                            cConta := ""
                            lAltConta := .F.
                        endif
                    elseif cCampo == "B1_MSBLQL"
                        if SB1->B1_TIPO <> "SA"
                            aAdd (aVetor, {cCampo,xConteudo,Nil})
                        endif
                    else
                        aAdd (aVetor, {cCampo,xConteudo,Nil})
                    endif

                endif

            endif

        endif

    next

    setaFilial(cEmpInc,cFilInc)

    nPosFil		:= Ascan( aVetor  , { |x| Alltrim( x[1] ) == "B1_FILIAL" } )
    if nPosFil > 0
        aVetor[nPosFil,2]			:= cFilInc
    else
        aAdd( aVetor , {"B1_FILIAL",cFilInc,nil} )
    endif

    aVetor	:= FwVetByDic( aVetor , "SB1" , .F. )

    MSExecAuto({|x,y| Mata010(x,y)},aVetor,IIF(INCLUI,3,4))

    //o axecauto esta retornando um erro na alteração da conta contabil
    //este trecho foi feito para contornar este problema
    if ALTERA .and. lAltConta .and. !lMsErroAuto
        RecLock("SB1",.F.)
        SB1->B1_CONTA := cConta
        cConta := ""
        SB1->(msUnlock())
    endif

    setaFilial(cEmpOrig, cFilOrig)

    If lMsErroAuto
        If lIsblind
            cErro:=getErrorAuto()
            help(cErro)
        Else
            MostraErro()
        EndIf
    Endif
return

static function setaFilial(cEmp,cFil)
    cEmpAnt := cEmp
    cFilAnt := cFil
return

static function getErrorAuto()
    local aError    := {}
    local nI        := 1
    local cMessage  := ""

    aError := getAutoGRLog()

    for nI := 1 to len(aError)
        cMessage += aError[nI] + CRLF
    next nI
return cMessage
