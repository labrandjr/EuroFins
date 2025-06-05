#include "rwmake.ch"

#DEFINE ENTER CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FA070POS �Autor  � Marcos Candido     � Data �  19/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada antes da montagem da tela com os dados    ���
���          � do titulo para a baixa a receber.                          ���
���          �                                                            ���
���          � A variavel que armazena o Historico da Baixa sera preen-   ���
���          � chida automaticamente com um texto pre-definido.           ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Eurofins                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
//reativado solicita��o Fran 29/08/18

	IW_MsgBox("Custas Cartor�rias foram agregadas � este t�tulo. Verifique."+ENTER+ENTER+"R$ "+Transform(SE1->E1_ZZCUSTA,"@E 999,999.99"),;
	              "Informa��o" ,;
	                 "ALERT")

Endif

Return