#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M030EXC
Ponto de entrada na exclusão de clientes.
Apaga a conta contabil do cliente quando o cliente é excluido
@author ricar
@since 08/01/2018
/*/
User Function M030EXC()
	local lMsErroAuto 	:= .F.
	local aAutoCab 		:={}
	local cConta := SA1->A1_CONTA

	if Empty(SA1->A1_CONTA)
		Return
	endif

	aadd(aAutoCab,{"CT1_CONTA"    ,SA1->A1_CONTA ,Nil})

	MSExecAuto({|x,y| CTBA020(x,y)},aAutoCab,5)

	If lMsErroAuto
		 MsgInfo("Não foi possivel excluir a Conta Contábil "+cConta+". A descrição do problema será exibida a seguir." ,"Cadastro de Clientes")
		 mostraerro()
	else
		MsgInfo("Conta Contábil "+cConta+" excluida" ,"Cadastro de Clientes")
	EndIf
return
