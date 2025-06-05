#include "totvs.ch"
#include "Protheus.ch"

/*/{protheus.doc} MT140PC
Manipula o parâmetro MV_PCNFE utilizado na Pré Nota de Entrada a ser gerada.
Nao obrigar pedido de compra quando a pre-nota for originada da Transf. entre Filiais.

@author Eduardo Cestari 
@since 26/02/2021
/*/

User Function MT140PC()
    Local lRet := ParamIXB[1]
    
    If IsInCallStack("MATA310") .or. IsInCallStack("MATA311")
    	lRet := .F.
    EndIf
    
Return(lRet)
