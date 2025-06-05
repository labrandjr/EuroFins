#include 'protheus.ch'
#include 'parmtype.ch'
#include "RWMAKE.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} callRepl
M�dulo: COMPRAS
Tipo: Rotina
Finalidade: Fun��o que prepara a chama da fun��o replProd.

@author Augusto Krejci Bem-Haja
@since 25/10/2017
@version undefined

@type function
/*/
user function callRepl ()
	local aArea := getArea()

	public lPLockExc

	if !lPLockExc
		lPLockExc := .T.
		U_replProd()
		lPLockExc := .F.
	endif
	restArea(aArea)
return