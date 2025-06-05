#include "rwmake.ch"

#DEFINE ENTER CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA070POS ºAutor  ³ Marcos Candido     º Data ³  19/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada antes da montagem da tela com os dados    º±±
±±º          ³ do titulo para a baixa a receber.                          º±±
±±º          ³                                                            º±±
±±º          ³ A variavel que armazena o Historico da Baixa sera preen-   º±±
±±º          ³ chida automaticamente com um texto pre-definido.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Eurofins                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*/{Protheus.doc} FA070POS
Antes da montagem da tela com os dados do titulo para a baixa a receber.
@author Marcos Candido
@since 03/01/2018
/*/
User Function FA070POS()

//Local nTam := Len(cHist070)
//cHist070 := "RECBTO NF "+Space(nTam-10)
Local cNomeCli := Posicione("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_NOME") // adicionado em 28/11/14

cHist070 := "RECBTO NF "+Alltrim(SE1->E1_NUM)+" "+Substr(cNomeCli,1,At(" ",cNomeCli)-1) // adicionado em 28/11/14

lFuncIRPJBx := .F. // variavel que indica que o controle do IRPJ sera no momento da baixa. Estou desabilitando-o


If SE1->E1_ZZCUSTA > 0
//mensagem retirada conforme documento Thais
//reativado solicitação Fran 29/08/18

	IW_MsgBox("Custas Cartorárias foram agregadas à este título. Verifique."+ENTER+ENTER+"R$ "+Transform(SE1->E1_ZZCUSTA,"@E 999,999.99"),;
	              "Informação" ,;
	                 "ALERT")

Endif

Return