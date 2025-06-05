#include "rwmake.ch"
/*/{Protheus.doc} FA080POS
Ponto de entrada antes da montagem da tela com os dados do titulo para a baixa a pagar.
@Author  Marcos Candido
@since 03/01/2018
@Obs A variavel que armazena o Historico da Baixa sera preenchida automaticamente com um texto pre-definido.       
/*/
User Function FA080POS()

	Local cNomeFor := Posicione("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_NOME") // adicionado em 04/12/14

	cHist070 := "PGTO NF "+Alltrim(SE2->E2_NUM)+" "+Substr(cNomeFor,1,At(" ",cNomeFor)-1) // adicionado em 04/12/14

Return