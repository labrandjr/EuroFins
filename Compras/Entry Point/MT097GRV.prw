#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT097GRV
ponto de entrada faz com que o pedido de compra não volte
para aprovação no caso de uma alteração, em conjunto com o MTALCFIM.
@author RICARDO REY
@since 09/10/2017
/*/
user function MT097GRV()
	Local ExpA1 := PARAMIXB[1]
	Local ExpD1 := PARAMIXB[2]
	Local ExpN1 := PARAMIXB[3]
	Local ExpC1 := PARAMIXB[4]
	Local ExpL1 := PARAMIXB[5]
	Local lOk:= .t.
	if ALTERA .and. FUNNAME() == "MATA121"

		if Empty(SC7->C7_APROV) //não tem aprovador, pedido pode ser alterado sem restrições
			lOk := .T.
		else
			if SC7->C7_CONAPRO <> 'L' //pedido ainda não foi liberado, pedido pode ser alterado sem restrições
				lOk := .T.
			else
				lOk := .f.
			endif
		endif
	 endif

Return lOk





