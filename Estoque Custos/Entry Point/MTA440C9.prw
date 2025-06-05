#include "rwmake.ch"


/*/{Protheus.doc} MTA440C9
Liberação do pedido de venda. Atualiza numero do certificado
@author Unknown
@since 02/01/2018
/*/
User Function MTA440C9()
	Local xC9_NROCERT := ""                // Numero do Certificado
	Local xC9_NOMECLI := ""                // Nome do Cliente/Fornecedor

	Local cDescProd   := ""
	Local cAmostra    := ""
	Local cInfoAdic   := ""
	Local cNumPedCli  := ""

	//
	Local _cAlias  := Alias()              // Salvar Contextos
	Local _nOrder  := IndexOrd()
	Local _nRecno  := Recno()
	//
	Local _nRegSC5 := SC5->(Recno())
	Local _nOrdSC5 := SC5->(IndexOrd())
	//
	Local _nRegSA1 := SA1->(Recno())
	Local _nOrdSA1 := SA1->(IndexOrd())
	//
	Local _nRegSA2 := SA2->(Recno())
	Local _nOrdSA2 := SA2->(IndexOrd())
	//
	Local _nRegSC9 := SC9->(Recno())
	Local _nOrdSC9 := SC9->(IndexOrd())
	//
	SA1->(DbSetOrder(1))                   // Clientes
	SC5->(DbSetOrder(1))                   // Cabecalho de Pedidos de Venda
	//
	SC5->(DbSeek(xFilial("SC5") + SC9->C9_PEDIDO, .F.))
	//
	If SC5->C5_TIPO $ "NCPI"               // Pedido de Cliente
	   xC9_NOMECLI := Posicione("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_NOME")
	Else                                   // Pedido de Fornecedor
	   xC9_NOMECLI := Posicione("SA2", 1, xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A2_NOME")
	Endif
	//
	xC9_NOMECLI := IIf(!Empty(xC9_NOMECLI), xC9_NOMECLI, "N/T")
	xC9_NROCERT := IIf(!Empty(SC5->C5_ZZNROCE), SC5->C5_ZZNROCE, "N/T")
	cDescProd   := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_DESC")
	cAmostra    := Posicione("SC6",1,xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO),"C6_ZZCODAM")
	cInfoAdic   := Alltrim(SC5->C5_ZZNFMAI)
	cNumPedCli  := Posicione("SC6",1,xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO),"C6_NUM")
	//
	DbSelectArea("SC9")                    // Atualizar o Numero do Certificado da Liberacao
	If SC9->(RecLock("SC9", .F.))
	   //
	   SC9->C9_ZZNRCER := xC9_NROCERT
	   SC9->C9_ZZNOMCL := xC9_NOMECLI
	   SC9->C9_ZZDESCR := cDescProd
	   SC9->C9_ZZCODAM := cAmostra
	   SC9->C9_ZZINFAD := cInfoAdic
	   SC9->C9_PEDIDO  := cNumPedCli
	   //
	   SC9->(MSUnlock("SC9"))
	   //
	Endif
	//
	SC5->(DbSetOrder(_nOrdSC5))            // Restaurar Contextos
	SC5->(DbGoTo(_nRegSC5))
	//
	SC9->(DbSetOrder(_nOrdSC9))
	SC9->(DbGoTo(_nRegSC9))
	//
	SA1->(DbSetOrder(_nOrdSA1))
	SA1->(DbGoTo(_nRegSA1))
	//
	SA2->(DbSetOrder(_nOrdSA2))
	SA2->(DbGoTo(_nRegSA2))
	//
	DbSelectArea(_cAlias)
	DbSetOrder(_nOrder)
	DbGoTo(_nRecno)
	//
Return (.T.)