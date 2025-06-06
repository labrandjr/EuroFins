#Include 'Protheus.ch'
#Include "totvs.ch"

/*/{Protheus.doc} VALDIFER
Finalidade: Valida��o do campo de usu�rio ZD_COD que n�o deixar� o usu�rio abrir um novo diferimento se o produto n�o come�ar com o c�digo 09A20.
M�dulo: Estoque

@type function
@author R�gis Ferreira - Totvs IP Jundia�
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
            MsgStop("O Produto "+cDiferim+" n�o � um produto com codifica��o de produto padr�o, produtos padr�es devem come�ar com c�digo "+cPrdDifer+", por favor verique o c�digo do produto","Produo n�o � de Diferimento.")
            lRet	:= .F.
        endif
    else
        lRet	:= .F.
    endif

Return lRet
