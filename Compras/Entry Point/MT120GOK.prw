#include "totvs.ch"

/*/{protheus.doc}MT120GOK 
Ponto de entrada na rotina de pedido de compra que permite 
executar outras funcoes apos a confirmacao da operacao do  
usuario (inclusao, alteracao ou exclusao). Estou usando    
para chamar a rotina que armazena mensagens para o P.C.    
@Author  Marcos Candido
@since 10/07/2011
/*/

User Function MT120GOK
	Local cNumPedido := PARAMIXB[1]
	Local lInclui    := PARAMIXB[2]
	Local lAltera    := PARAMIXB[3]
	Local lDeleta    := PARAMIXB[4]
	If (lInclui .and. !IsInCallStack("u_imppocoupa")).or. lAltera .or. lDeleta  
		U_MsgPC(cNumPedido)
	Endif
Return
                        
