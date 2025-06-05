#include 'protheus.ch'

/*/{protheus.doc}MT340D3
Ponto de entrada para gravar o centro de custo na SD3 conforme foi preenchido na tabela SB7 na importação do inventário.
Leva o campo B7_ZZCC para o D3_CC
@author Régis Ferreira
@since 14/01/2019
/*/

User Function MT340D3( )
    
    Local cCod 		:= SD3->D3_COD
    Local cData		:= dTos(SD3->D3_EMISSAO)
    Local cArm 		:= SD3->D3_LOCAL 
    Local cCusto 	:= ""
    
    BeginSql alias "SB7CC"
    
    select 
    	SB7.B7_ZZCC 
    from %Table:SB7% SB7
    where 
    	SB7.B7_COD = %Exp:cCod% and
    	SB7.%NotDel% and 
    	SB7.B7_DATA = %Exp:cData% and 
    	SB7.B7_LOCAL = %Exp:cArm%
    
    EndSql
    
    cCusto	:= SB7CC->B7_ZZCC
    
    SB7CC->(DbCloseArea())
    
    //Busca o centro de custo no campo B7_ZZCC
    Replace SD3->D3_CC With cCusto

return