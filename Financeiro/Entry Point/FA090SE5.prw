#Include 'Protheus.ch'
/*/{protheus.doc}FA090SE5
Antes da montagem da tela com a baixa a pagar. Grava Historico da baixa
@author Vinicius Vendemiatti
@since 27/09/2017


/*/
User Function FA090SE5()
	Local cHISTOR := ""
	Local cNomeFor := Posicione("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_NOME") 
	reclock("SE5",.F.)
	cHistor := "PGTO NF "+Alltrim(SE2->E2_NUM)+" "+Substr(cNomeFor,1,At(" ",cNomeFor)-1)     
	SE5->E5_HISTOR	:= cHistor   
	SE5->( MSUNLOCK() )      
Return 