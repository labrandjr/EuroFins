#Include 'Totvs.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'

#DEFINE STATUS_INTEG        "I"
#DEFINE STATUS_ERRO         "N"

#DEFINE ID_CABEC            "ZZDMASTER"

//-----------------------------------------------------------------
/*/{Protheus.doc} ZZDCAD
Ponto de entrada da rotina do monitor de integrações

@type		Function
@author		Julio Lisboa
@since		30/09/2020
/*/
//-----------------------------------------------------------------
user function ZZDCAD()

    Local lRet			:= .T.
    Local aParam 		:= Paramixb
    Local oObjeto		:= nil
    Local oModel        := nil
    Local cIDPonto		:= ""
    Local cIdModel		:= ""
    Local cErro         := ""
    Local cSolucao      := ""
    Local nOperacao     := 0

    If aParam <> NIL
        oObjeto		:= aParam[1]
        cIdPonto 	:= aParam[2]
        cIdModel 	:= aParam[3]
        nOperacao   := oObjeto:getOperation()
    EndIf

    //---------------------------------------------
    // VALIDA SE O REGISTRO PODE SER INCLUIDO
    //---------------------------------------------
    If cIDPonto == "FORMPRE" .or. cIdPonto == "MODELVLDACTIVE"
        If nOperacao == MODEL_OPERATION_DELETE .and. ZZD->ZZD_STATUS <> STATUS_ERRO
            cErro       := "Não foi possível excluir o item do Monitor de integração"
            cSolucao    := "Só pode ser excluido registros que estão com erro"

            oObjeto:SetErrorMessage(ID_CABEC, 'ZZD_STATUS' , ID_CABEC , 'ZZD_STATUS' , "ZZDCAD", cErro, cSolucao )
            lRet    := .F.
        EndIf

        //---------------------------------------------
        // GRAVA NO REGISTRO QUEM EXCLUIU
        //---------------------------------------------
    ElseIf cIdPonto == "MODELCOMMITTTS"
        If nOperacao == MODEL_OPERATION_DELETE
            cErro		:= Replicate("*",15) + CRLF
            cErro		+= "Deletado MANUALMENTE em "
            cErro		+= DTOC(Date()) + " - "
            cErro		+= Time() + " por: "
            cErro		+= UsrFullName(RetCodUsr())
            cErro		+= CRLF
            cErro		+= Replicate("*",15)
            cErro		+= CRLF + CRLF
            cErro		+= ZZD->ZZD_OCORRE

            If Reclock("ZZD",.F.)
                ZZD->ZZD_OCORRE   := cErro
                ZZD->(MsUnlock())
            EndIf
        EndIf
    EndIf

Return (lRet)
