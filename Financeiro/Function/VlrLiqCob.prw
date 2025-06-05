#include "rwmake.ch"

/*/{Protheus.doc} VlrLiqCob
ExecBlock chamado pelo arquivo ITAU.REM para calcular o
valor liquido de impostos para os titulos a receber.
@author Marcos Candido
@since 04/01/2018
/*/

User Function VlrLiqCob
	Local nValorTit  := SE1->(E1_SALDO-E1_DECRESC+E1_ACRESC)
	Local nValorLiq  := 0
	Local nValIRRF   := SE1->E1_IRRF
	Local nValPIS    := SE1->E1_PIS
	Local nValCOFI   := SE1->E1_COFINS
	Local nValCSLL   := SE1->E1_CSLL
	Local cValorLiq
	If nValorTit == 0
		nValorTit := SE1->E1_VALOR
	Endif

	if nValorTit >= 215
		nValorLiq := nValorTit - (nValIRRF + nValPIS + nValCOFI + nValCSLL)   
	else
		nValorLiq := nValorTit - (nValIRRF)   
	endif
	cValorLiq := StrZero(nValorLiq*100,13)  
Return cValorLiq