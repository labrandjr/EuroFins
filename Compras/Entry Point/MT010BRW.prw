#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT010BRW
Módulo: COMPRAS
Tipo: Ponto de entrada
Finalidade: Ponto de entrada que adiciona opções no menu outras ações.
Serve para verificar a possibilidade de excluir nas filiais restantes.
@author Augusto Krejci Bem-Haja
@since 25/09/2017
@version undefined

@type function
/*/
user function MT010BRW()
	local aArea 	:= getArea()
	local aRotina 	:= {}

//	aAdd(aRotina,{"Replicar","U_callRepl",0,1})

	restArea(aArea)
return aRotina