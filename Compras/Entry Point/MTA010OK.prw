#include 'protheus.ch'
#include 'parmtype.ch'



/*/{Protheus.doc} MTA010OK
Módulo: COMPRAS
Tipo: Ponto de entrada
Finalidade: Ponto de entrada antes da gravação do produto.
Serve para verificar a possibilidade de excluir nas filiais restantes.
@author Augusto Krejci Bem-Haja
@since 23/09/2017
@version undefined

@type function
/*/
user function MTA010OK()
	local aArea := getArea()
	local lRet:= .T.

	public lPLockExc

	if !lPLockExc
		lPLockExc := .T.
		lRet := U_exclProd()
		lPLockExc := .F.
	endif

	restArea(aArea)
return (lRet)