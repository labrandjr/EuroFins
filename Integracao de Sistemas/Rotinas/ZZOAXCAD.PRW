#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"
 
/*/{Protheus.doc} ZZOAXCAD
AxCadastro da tabela ZZO que � a amarra��o entre o c�digo da �rea da amostra x produto
Integra��o Mylins
@type function
@author R�gis Ferreira
@since 22/12/2023
@version 1.0
/*/
 
User Function ZZOAXCAD()
    Local aArea     := GetArea()
    Local aAreaZZO  := ZZO->(GetArea())
    Local cDelOk    := ".T."
    Local cFunTOk   := "U_ValZZO()"
 
    //Chamando a tela de cadastros
    AxCadastro('ZZO', 'MyLins - Area Servi�o x Produtos.', cDelOk, cFunTOk)
 
    ZZO->(RestArea(aAreaZZO))
    RestArea(aArea)
Return

User Function ValZZO()

    Local lRet      := .T.
    Local cQuery    := ""
    Local cAliasZZI := GetNextAlias()

    if INCLUI
        cQuery := " Select "                                    + CRLF
        cQuery += "     Count(*) QTDREGISTROS "                 + CRLF
        cQuery += " From " + RetSqlName("ZZO") + " "            + CRLF
        cQuery += " Where "                                     + CRLF
        cQuery += "     1=1 "                                   + CRLF
        cQuery += "     And ZZO_AMOSTR = '"+M->ZZO_AMOSTR+"' "  + CRLF
        cQuery += "     And D_E_L_E_T_  = ' ' "                 + CRLF

        TcQuery cQuery New Alias &(cAliasZZI)
        (cAliasZZI)->(DbGoTop())

        if (cAliasZZI)->QTDREGISTROS > 0
            lRet := .F.
            MsgStop("Service Area "+M->ZZO_AMOSTR+" j� cadastrado!","ATEN��O")
        endif
        (cAliasZZI)->(DbCloseArea())
    endif
        
    if lRet
        cQuery    := ""
        cAliasZZI := GetNextAlias()
        
        cQuery := " Select "                                    + CRLF
        cQuery += "     Count(*) QTDREGISTROS "                 + CRLF
        cQuery += " From " + RetSqlName("SB1") + " "            + CRLF
        cQuery += " Where "                                     + CRLF
        cQuery += "     1=1 "                                   + CRLF
        cQuery += "     And B1_COD = '"+M->ZZO_PROD+"' "        + CRLF
        cQuery += "     And D_E_L_E_T_  = ' ' "                 + CRLF

        TcQuery cQuery New Alias &(cAliasZZI)
        (cAliasZZI)->(DbGoTop())

        if (cAliasZZI)->QTDREGISTROS <= 0
            MsgStop("Produto "+M->ZZO_PROD+" n�o tem cadastro cadastrado!","ATEN��O")
            lRet := .F.
        endif
        (cAliasZZI)->(DbCloseArea())
    endif

Return lRet
