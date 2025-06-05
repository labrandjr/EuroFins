#include 'protheus.ch'
#include 'parmtype.ch'
#include "RWMAKE.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} callRepl
Módulo: COMPRAS
Tipo: Rotina
Finalidade: Função que prepara a chama da função replProd.

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