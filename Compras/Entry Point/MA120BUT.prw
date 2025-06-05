#include "totvs.ch"
/*/{protheus.doc}MA120BUT 
Ponto de entrada na rotina de pedido de compra que permite adicionar botoes na tela de manutencao do pedido.
@Author Marcos Candido
@since 10/07/11   
/*/
User Function MA120BUT
	Local aBotoes := {}
	aadd(aBotoes , {"CRITICA",{|| U_MsgPC(cA120Num)},"Mensagem do Pedido de Compra","Mensagem"})
Return aBotoes