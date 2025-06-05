#include 'totvs.ch'

/*/{Protheus.doc} M520BROW
ponto de entrada browser exclusão documento de saída
@type function
@version 12.1.33
@author adm_tla8
@since 29/05/2023
/*/
user function M520BROW()
    local cPerg := "MTA521"
    // seta a opção de contabilização on-line = sim
    setMVValue(cPerg,"MV_PAR03",1)

return()
