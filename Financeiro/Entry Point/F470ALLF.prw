#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} F470ALLF
No relatorio extrato bancario, retorna .T. para n�o filtrar filiais.
@author Unknown
@since 09/01/2018
/*/
User Function F470ALLF
	Local lAllFil := ParamIxb[1]
Return .T.