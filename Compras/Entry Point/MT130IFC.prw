#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT130IFC/MT131FIL
Módulo: COMPRAS
Tipo: Ponto de entrada
Finalidade: Ponto de entrada utilizado para filtrar o Comprador da SC
Obs: O filtro só esta funcionando se os 2 PE forem compilados.
@author RICARDO REY
@since 28/09/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

user function MT130IFC()
Local lRet

lRet := {" .and. C1_CODCOMP>='"+MV_PAR18+"' .and. C1_CODCOMP<='"+MV_PAR19+"'"," AND C1_CODCOMP>='"+MV_PAR18+"' AND C1_CODCOMP<='"+MV_PAR19+"'"}

return lRet


user function MT131FIL()
Local lRet

lRet := iif(!Empty(MV_PAR18)," C1_CODCOMP>='"+MV_PAR18+"' .and. C1_CODCOMP<='"+MV_PAR19+"'","")

return lRet
