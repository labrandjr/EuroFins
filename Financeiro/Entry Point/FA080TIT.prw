#include "totvs.ch"
/*/{protheus.doc}
Na baixa de titulos a pagar, valida contrato de c�mbio quando moeda <>1
@author Sergio Braz
@since 02/09/2019   
@history 27/02/2020, Gabriel Da Silva, Alterado a linha 12 inserindo a variavel global cMotbx.
@history 06/10/2021, R�gis Ferreira - Alterado para n�o ser chamado pela rotina de BXINVOICE, pois a rotina ir� gravar esse dado
/*/

User Function FA080TIT
    Local lRet      := .T.
    Local cNumero   := ""
    if !IsInCallStack("U_BXINVOICE")
        cNumero   := SE2->E2_ZZCTCAM
        If SE2->E2_MOEDA<>1
            If MovBcoBx(cMotBx,.T.)
                cNumero := FwInputBox("Numero do contrato de c�mbio",cNumero)
                If Empty(cNumero)
                    MsgStop("Contrato de c�mbio inv�lido","F070TOK")
                    lRet := .F.
                Else
                    RecLock("SE2",.F.)
                    SE2->E2_ZZCTCAM := cNumero
                    SE2->(MsUnlock())
                Endif
            Endif
        Endif
    else
        if Type("cContrSE2") != "U"
            cNumero := cContrSE2
        endif
        if RecLock("SE2",.F.)
            SE2->E2_ZZCTCAM := cNumero
            SE2->(MsUnlock())
        endif
    endif
Return lRet
