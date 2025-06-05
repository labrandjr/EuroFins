#include "rwmake.ch"
/*/{Protheus.doc} MT103VPC
Módulo: COMPRAS
Tipo: Ponto de entrada
Finalidade: Ponto de entrada na rotina Documento de Entrada , assim
que o usuario busca o pedido de compra.
Estou usando para permitir o usuario indicar uma taxa
que o sistema usara na conversao dos valores do pedido
de compra que esta em moeda diferente de 1.

@Author Marcos Candido
@since 26/02/15   
/*/
User Function MT103VPC
	
	Local lRet := .T.
	Local nGetTaxa := 0
	
	nTaxa := Iif(Type("nTaxa")=="U",0,nTaxa)
	
	If Type("aF4For")<>"U"
	
		If Len(aF4For) > 0 .and. aScan(aF4For,{|x| x[1] == .T.}) > 0
	
			If SC7->C7_MOEDA <> 1 .and. nTaxa == 0
	
				@ 150, 180 To 285, 470 Dialog oJanela Title "Taxa Diferenciada"
				@ 005, 005 To 047,142
				@ 012, 010 Say "Se precisar utilizar uma taxa diferente da que foi "
				@ 020, 010 Say "definida no Pedido de Compra, informe neste campo:"
				@ 030, 010 Get nGetTaxa Picture X3Picture("C7_TXMOEDA") Size 55,10
				@ 052, 058 BmpButton Type 1 Action Close(oJanela)
				Activate Dialog oJanela Center
	
				If nGetTaxa > 0
					nTaxa := nGetTaxa
				Endif
	
			Endif
	
			If nTaxa == 0
				nTaxa := 1
			Endif
	
		Endif
	
	Endif
	
Return lRet
