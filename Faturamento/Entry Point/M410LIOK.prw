#include "totvs.ch"   
/*/{protheus.doc} m410liok
ponto de entrada na validação de linha da rotina de pedidos de venda (mata410)
@author Sergio Braz
@since 05/06/2019

26/02/2021 - Eduardo Cestari - Solicitação Joelma
Adicinado regra para nao obrigar o preenchimento do Centro de Custo para TES 
do parametro ZZ_TESPVTR (Tes do pedido de tranf. filiais) nem quando a conta contabil começar com 3 ou 4.
/*/
User Function M410LIOK
	Local lRet		:= .t.
	Local cConta	:= SubStr(GdFieldGet("C6_CONTA"),1,1)

	//Valida se o campo de Centro de Custo está preenchido e não veio da integração de PV
	If !GdFieldGet("C6_TES") $ SuperGetMV("ZZ_TESPVTR")
		If !IsInCallStack('U_INSPVENDA') .and. !IsInCallStack('U_AnatechConnect') .and. cConta $ "34" .and. Empty(GdFieldGet("C6_CC")) .and. !IsInCallStack('MATA311')
			MyHelp("M410LIOK - Campo Obrigatório","Para os pedidos venda é necessário informar o Centro de Custo","Informe o Centro de Custo no item "+cValToChar(N))
			lRet := .f.
		Endif
	Endif

Return lRet

Static Function MyHelp(cTipo,cProblema,cSolucao)
	Help(NIL, NIL, cTipo, NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
Return
