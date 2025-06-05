#include 'protheus.ch'

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} SD1140I
Ponto de entrada usado somente para dar um alert para o usuário quando ultrapassar o estoque máximo.
@author Unknown
@since 05/10/2022
/*/
User function SD1140I()

    Local aArea     := GetArea()
    Local aAreaSB1  := SB1->(GetArea())
    Local aAreaSF1  := SF1->(GetArea())
    Local aAreaSD1  := SD1->(GetArea())
    Local aAreaSB2  := SB2->(GetArea())
    Local lRet      := .T.
    Local nCount    := 0
    Local cMsg      := ""
    Local aProdSald := {}
    Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
    Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
    Local nPosLocal := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})
    Local nFilAlert := Alltrim(SuperGetMv("ZZ_ALERTPN",.T.,""))

    if cFilAnt $ nFilAlert

        for nCount := 1 to len(aCols)

            if Empty(aProdSald)
                aadd(aProdSald,{aCols[nCount][nPosProd],aCols[nCount][nPosLocal],aCols[nCount][nPosQuant]})
            else
                if aCols[nCount][nPosProd] == aProdSald[len(aProdSald)][1] .and. aCols[nCount][nPosLocal] == aProdSald[len(aProdSald)][2]
                    aProdSald[len(aProdSald)][3] += aCols[nCount][nPosQuant]
                else
                    aadd(aProdSald,{aCols[nCount][nPosProd],aCols[nCount][nPosLocal],aCols[nCount][nPosQuant]})
                endif
            endif

        Next nCount

        cMsg := ""
        for nCount := 1 to len(aProdSald)
            SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
            if SB1->(DbSeek(xFilial("SB1")+aProdSald[nCount][1]))
                if SB1->B1_EMAX > 0
                    SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
                    if SB2->(DbSeek(xFilial("SB2")+aProdSald[nCount][1]+aProdSald[nCount][2]))
                        if SB2->B2_QATU+aProdSald[len(aProdSald)][3] > SB1->B1_EMAX
                            if Empty(cMsg)
                                cMsg := Alltrim(aCols[nCount][nPosProd])
                            else
                                if !Alltrim(aProdSald[nCount][1]) $ cMsg
                                    cMsg += " - "+Alltrim(aCols[nCount][nPosProd])
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        Next nCount

        if !Empty(cMsg)
            Iw_MsgBox("O(s) produto(s) "+cMsg+" vai(ao) ultrapassar o estoque maximo!", "AVISO", "INFO")
        endif
    
    endif

    SB1->(RestArea(aAreaSB1))
    SF1->(RestArea(aAreaSF1))
    SD1->(RestArea(aAreaSD1))
    SB2->(RestArea(aAreaSB2))
    RestArea(aArea)

Return lRet
