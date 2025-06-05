#Include 'Totvs.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} LinAddZZL
Fonte que grava dados na tabela ZZL e ZZML
Integração Lincros Protheus
@type function
@version 12.1.2210
@author Régis Ferreira - 01/12/2022
@since 30/11/2022
@return lRet, return_description
/*/

//-------------------------------------------------------------------
user function LinAddZZL(cCodZZL,cErro,cTipo,cIdCte,aCab,aItens)

    Local lRet          := .T.
    Local nItens        := 0
    Local nPosFornece   := 0
    Local nPosLoja      := 0
    Local nPosDocumento := 0
    Local nPosSerie     := 0
    Local nPosTipo      := 0
    Local nPosFormul    := 0
    Local nPosChvNfe    := 0
    Local nPosProduto   := 0
    Local nPosQuant     := 0
    Local nPosVunit     := 0
    Local nPosTotal     := 0
    Local nPosTES       := 0
    Local nPosCFOP      := 0
    Local nPosCC        := 0
    Local nPosPedido    := 0
    Local nPosItemPC    := 0

    Local aArea         := GetArea()
    Local aAreaZZL      := ZZL->(GetArea())
    Local aAreaZZM      := ZZM->(GetArea())

    Local cMsgErro      := ""
    cMsgErro := AllTrim(cErro)
    cMsgErro := Replace(cErro, '|',chr(10)+chr(13))
    cMsgErro := Replace(cErro, '|',chr(10)+chr(13))


    if cTipo == "C"
        nPosFornece   := aScan(aCab,{|x| x[1] == "F1_FORNECE"})
        nPosLoja      := aScan(aCab,{|x| x[1] == "F1_LOJA"})
        nPosDocumento := aScan(aCab,{|x| x[1] == "F1_DOC"})
        nPosSerie     := aScan(aCab,{|x| x[1] == "F1_SERIE"})
        nPosTipo      := aScan(aCab,{|x| x[1] == "F1_TIPO"})
        nPosFormul    := aScan(aCab,{|x| x[1] == "F1_FORMUL"})
        nPosChvNfe    := aScan(aCab,{|x| x[1] == "F1_CHVNFE"})
    else
        nPosFornece   := aScan(aCab,{|x| x[1] == "E2_FORNECE"})
        nPosLoja      := aScan(aCab,{|x| x[1] == "E2_LOJA"})
        nPosDocumento := aScan(aCab,{|x| x[1] == "E2_NUM"})
        nPosSerie     := aScan(aCab,{|x| x[1] == "E2_PREFIXO"})
    endif

    If CHKFILE("ZZL")
        ZZL->(DbSetOrder(1))
        if ZZL->(RecLock("ZZL", .T.))
            ZZL->ZZL_FILIAL := cFilAnt
            ZZL->ZZL_CODIGO := cCodZZL
            ZZL->ZZL_FORNECE:= aCab[nPosFornece][2]
            ZZL->ZZL_LOJA   := aCab[nPosLoja][2]
            ZZL->ZZL_DOC    := aCab[nPosDocumento][2]
            ZZL->ZZL_SERIE  := aCab[nPosSerie][2]
            ZZL->ZZL_TIPO   := cTipo
            if cTIpo == "C"
                ZZL->ZZL_TIPONO := aCab[nPosTipo][2]
                ZZL->ZZL_FORMUL := aCab[nPosFormul][2]
                ZZL->ZZL_CHAVE  := aCab[nPosChvNfe][2]
            else
                ZZL->ZZL_RATCC  := StringRateio(aItens)
            endif
            ZZL->ZZL_INTEGR := cValtochar(cIdCte)
            if !Empty(cMsgErro)
                ZZL->ZZL_STATUS := "X"
                ZZL->ZZL_ERRO   := cMsgErro
            else
                ZZL->ZZL_STATUS := "1"
            endif
            ZZL->ZZL_NOMEFO := GetAdvfval("SA2","A2_NOME",xFilial("SA2")+aCab[nPosFornece][2]+aCab[nPosLoja][2],1,"")
            ZZL->ZZL_DATA   := ddatabase
            ZZL->ZZL_HORA   := Time()
            ZZL->(MsUnlock())
        endif
    endif

    if cTipo == "C"
        if CHKFILE("ZZM")
            if !Empty(aItens)
                for nItens := 1 to len(aItens)

                    nPosProduto   := aScan(aItens[nItens],{|x| x[1] == "D1_COD"})
                    nPosQuant     := aScan(aItens[nItens],{|x| x[1] == "D1_QUANT"})
                    nPosVunit     := aScan(aItens[nItens],{|x| x[1] == "D1_VUNIT"})
                    nPosTotal     := aScan(aItens[nItens],{|x| x[1] == "D1_TOTAL"})
                    nPosTES       := aScan(aItens[nItens],{|x| x[1] == "D1_TES"})
                    nPosCFOP      := aScan(aItens[nItens],{|x| x[1] == "D1_CF"})
                    nPosCC        := aScan(aItens[nItens],{|x| x[1] == "D1_CC"})
                    nPosPedido    := aScan(aItens[nItens],{|x| x[1] == "D1_PEDIDO"})
                    nPosItemPC    := aScan(aItens[nItens],{|x| x[1] == "D1_ITEMPC"})
                    nPosItem      := aScan(aItens[nItens],{|x| x[1] == "D1_ITEM"})

                    ZZL->(DbSetOrder(1))
                    if ZZM->(RecLock("ZZM", .T.))
                        ZZM->ZZM_FILIAL := cFilAnt
                        ZZM->ZZM_CODIGO := cCodZZL
                        ZZM->ZZM_FORNECE:= aCab[nPosFornece][2]
                        ZZM->ZZM_LOJA   := aCab[nPosLoja][2]
                        ZZM->ZZM_DOC    := aCab[nPosDocumento][2]
                        ZZM->ZZM_SERIE  := aCab[nPosSerie][2]
                        ZZM->ZZM_ITEM   := aItens[nItens][nPosItem][2]
                        ZZM->ZZM_PRODUT := aItens[nItens][nPosProduto][2]
                        ZZM->ZZM_QUANT  := aItens[nItens][nPosQuant][2]
                        ZZM->ZZM_VUNIT  := aItens[nItens][nPosVunit][2]
                        ZZM->ZZM_TOTAL  := aItens[nItens][nPosTotal][2]
                        ZZM->ZZM_TES    := aItens[nItens][nPosTES][2]
                        ZZM->ZZM_CF     := aItens[nItens][nPosCFOP][2]
                        ZZM->ZZM_CC     := aItens[nItens][nPosCC][2]
                        ZZM->ZZM_PEDIDO := aItens[nItens][nPosPedido][2]
                        ZZM->ZZM_ITEMPC := aItens[nItens][nPosItem][2]
                    Endif

                Next nItens
            endif
        Endif
    Endif

    ZZL->(RestArea(aAreaZZL))
    ZZM->(RestArea(aAreaZZM))
    RestArea(aArea)

Return lRet

User Function LinAtuStatus(cCodZZL,cIntegra,cErro)

    Local aArea         := GetArea()
    Local aAreaZZL      := ZZL->(GetArea())
    Local aAreaZZM      := ZZM->(GetArea())

    ZZL->(DbSetOrder(1))
    if ZZL->(Dbseek(xFilial("ZZL")+cCodZZL))

        ZZL->(RecLock("ZZL", .F.))
            if cIntegra == "Erro"
                ZZL->ZZL_STATUS := "X"
                ZZL->ZZL_ERRO   := cErro
            else
                ZZL->ZZL_STATUS := "2"
            endif
            
        ZZL->(MsUnlock())

    endif

    ZZL->(RestArea(aAreaZZL))
    ZZM->(RestArea(aAreaZZM))
    RestArea(aArea)

Return

Static Function StringRateio(aItens)

    Local cRet  := ""
    Local nRat  := 0

    for nRat :=1 to len(aItens)
        cRet += "CC: "+aItens[nRat][1]+" - Percentual: "+cValtochar(aItens[nRat][2])+CRLF
    Next nRat

Return cRet

