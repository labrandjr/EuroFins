#INCLUDE "PROTHEUS.CH"
#include 'topconn.ch'

//-----------------------------------------------------------------
User Function MT100GRV()

    Local lRet      := .T.
    Local oLibCoupa := nil
    Local lOnOff    := getnewpar("ZZ_ESTNFCO",.T.)

    If lOnOff
        If FunName() == "MATA140" .AND. FwIsInCallStack("A140ESTCLA")
            If !INCLUI .AND. !ALTERA
                oLibCoupa   := LibCoupa():New()
                If oLibCoupa:isNFCoupa(SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_TIPO)
                    Help(NIL, NIL, "MT100GRV", NIL, "Não é possível estornar uma NF do Coupa", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilize a opção excluir"})
                    lRet    := .F.
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet
