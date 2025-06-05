#Include "Protheus.ch"

/*/{Protheus.doc} FIRSTNFSE
Este PE tem a finalidade de executar a manipulação do array aRotina utilizado pelo menu da Nota Fiscal de Serviço Eletrônica.
Programa Fonte: FISA022 / FISA031
@type function
@version 1.0
@author Ademar Fernandes Jr.
@since 05/04/2023
@link https://gkcmp.com.br (Geeker Company)
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6077188
/*/
User function FIRSTNFSE()

    If ExistBlock("NFSeMain")
        //-NFSeMain({ cFilNFSe,cNumNFSe,cSerNFSe,cNFSeCli,cNFSeLoj,cModNFSe })
        aAdd(aRotina, {"Gera PDF NFSe Indaiatuba","U_NFSeMain({F2_FILIAL,F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,'000001'})",0,2,0,NIL})
        aAdd(aRotina, {"Gera PDF NFSe Recife"    ,"U_NFSeMain({F2_FILIAL,F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,'000002'})",0,2,0,NIL})
    EndIf

Return
