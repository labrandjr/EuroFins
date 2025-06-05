#Include 'Protheus.ch'
#Include "totvs.ch"

/*/{Protheus.doc} VALDIFER
Finalidade: Validação do campo de usuário ZD_COD que não deixará o usuário abrir um novo diferimento se o produto não começar com o código 09A20.
Módulo: Estoque

@type function
@author Régis Ferreira - Totvs IP Jundiaí
@since 07/02/2020
@version Protheus 12 - Estoque
@return nil

/*/

User Function VALDIFER

    Local lRet		:= .T.
    Local cDiferim	:= Alltrim(M->ZD_COD)
    Local cPrdDifer := SuperGetMV("ZZ_PRDDIF",.T.,"09A20")

    if existCpo("SB1",cDiferim)
        if !SubStr(cDiferim,1,5) $ cPrdDifer
            MsgStop("O Produto "+cDiferim+" não é um produto com codificação de produto padrão, produtos padrões devem começar com código "+cPrdDifer+", por favor verique o código do produto","Produo não é de Diferimento.")
            lRet	:= .F.
        endif
    else
        lRet	:= .F.
    endif

Return lRet
