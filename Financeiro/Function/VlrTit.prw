#include "rwmake.ch"


/*/{Protheus.doc} VlrTit
Programa  para considerar o valor liquido do titulo.
@author Marcos Candido
@since 04/01/2018/*/
User Function VlrTit

	Local nVlrAbat  := 0
	Local nValorTit :=0

	nVlrAbat  := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,SE1->E1_EMISSAO,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nValorTit := SE1->E1_SALDO-nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC

Return nValorTit