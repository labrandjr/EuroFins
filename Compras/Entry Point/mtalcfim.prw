#include "totvs.ch"
/*/{Protheus.doc} MTALCFIM
ponto de entrada faz com que o pedido de compra não volte
para aprovação no caso de uma alteração, em conjunto com o MT097GRV.
@author RICARDO REY
@since 09/10/2017
/*/

User Function MTALCFIM

	if FUNNAME() <> "MATA121"
		Return
	endif


	if FUNNAME() == "MATA121" .and. ALTERA

		if Empty(SC7->C7_APROV) //não tem aprovador, pedido pode ser alterado sem restrições
			Return
		else
			if SC7->C7_CONAPRO == 'L'
				Return .t.
			 endif
		endif

	 endif

Return
