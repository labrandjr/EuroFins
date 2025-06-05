#include "rwmake.ch"

/*/{Protheus.doc} FA060Qry
Na rotina FINA060 permite que seja adicionado filtro aos registro que serao selecionados para a montagem do bordero.
@author Marcos Candido
@since 03/01/2018
/*/
User Function FA060Qry

	Local cRet := "" // Expressao SQL de filtro que sera adicionada a clausula WHERE da Query.

	cRet := " E1_NUMBCO <> '" + Space(TamSx3("E1_NUMBCO")[1]) + "'

Return cRet
