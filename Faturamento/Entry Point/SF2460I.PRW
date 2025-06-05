#include "rwmake.ch"
//  Programa ...: SF2460I                              Modulo : Sigaadv     //
//  Autor ......: Paulo Roberto de Oliveira            Data ..: 11/10/05    //
//  Descricao ..: Ponto de Entrada na Gravacao do Cabecalho da NF de Saida  //
//  Uso ........: Especifico da GeneScan do Brasil                          //
//  Observacao .: Realiza a gravacao do numero do certificado do pedido de  //
//                vendas nos itens da nota fiscal de saida                  //
//  Atualizacao : 11/10/05 - Paulo Roberto de Oliveira                      //
//  Atualizacao : 27/08/13 - Marcos Candido                                 //
//                Faz checagem em cada codigo de produto para avaliar para  //
//                qual centro de custo devera ser realizado o rateio do     //
//                faturamento.                                              //
/*/{Protheus.doc} SF2460I
Grava o numero do certificado do pedido. Faz o rateio do faturamento pelo codigo de produto para avaliar para qual centro de custo devera ser realizado 
@author Paulo Roberto de Oliveira
@since 02/01/2018
/*/
User Function SF2460I()
///////////////////////
//
Local aAreaAtual := GetArea()
Local aAreaSD2   := SD2->(GetArea())
Local cCCusto    := ""
Local nPerc      := 0
Local cNumCert   := ""
Local aInfo      := {}

//
dbSelectArea("SD2")
dbSetOrder(3)                   // Itens da Nota Fiscal de Saida
dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
//
While !Eof() .And. xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
      //
	cNumCert := Posicione("SC6",1,xFilial("SC6")+SD2->(D2_PEDIDO+D2_ITEMPV),"C6_ZZNROCE")
	aInfo    := {}


    cCCusto := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_ZZCCUST")

    If SD2->D2_EST == 'EX'
    	If cCCusto == '01'
    		cCCusto := '02'
    	ElseIf cCCusto == '03'
    		cCCusto := '04'
    	ElseIf cCCusto == '05'
    		cCCusto := '06'
    	ElseIf cCCusto == '07'
    		cCCusto := '08'
    	ElseIf cCCusto == '09'
    		cCCusto := '10'
    	ElseIf cCCusto == '11'
    		cCCusto := '12'
    	Endif
    Endif

	If SF2->F2_CLIENTE $ '000313/000827' // ALAC / INNOLAB
    	If cCCusto $ '01/02/16/18'
    		cCCusto := '24'
    	ElseIf cCCusto $ '03/04/05/06'
    		cCCusto := '25'
    	ElseIf cCCusto $ '07/08/09/10'
    		cCCusto := '26'
    	ElseIf cCCusto $ '11/12/20'
    		cCCusto := '27'
    	Else
    		cCCusto := '24'
    	Endif
	Endif

    Reclock("SD2",.F.)
      SD2->D2_ZZNROCE := cNumCert   // Atualizar o Numero do Certificado
	  SD2->D2_ZZCC    := cCCusto
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia e-mail ao identificar que o Centro de custo foi gravado vazio.                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCCusto) .and. SD2->D2_SERIE == SPACE(3)
		aadd(aInfo , "O Produto "+SD2->D2_COD+" da nota fiscal/série nº "+SD2->D2_DOC+"/"+SD2->D2_SERIE+", não atendeu e nenhum quesito " )
		aadd(aInfo , "das regras estabelecidas pelo Departamento Comercial para classifica-lo em algum Centro de Custo." )
		aadd(aInfo , " " )
		aadd(aInfo , "Favor verificar. ")

		MEnviaMail("Z01",aInfo)
	Endif

	dbSelectArea("SD2")
	dbSkip()
    //
Enddo

RestArea(aAreaSD2)
RestArea(aAreaAtual)

Return (.T.)