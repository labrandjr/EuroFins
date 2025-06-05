#include 'totvs.ch'

/*/{Protheus.doc} zLogMsg
rotina para substituicao da funcao ConOut pelo FWLogMsg
@type function
@version 12.1.27
@author Leandro Cesar
@since 09/05/2022
@param cp_Msg, character, mensagem a ser apresentado no console
@obs O log de Debug somente é ativado pela chave no environment FWLOGMSG_DEBUG=1
/*/
user function zLogMsg(cp_Msg,cp_Sever)
	local aArea    := GetArea()
	local aMessage := {}
	Default cp_Msg := ""
	default cp_Sever := "INFO"

	//Informações adicionais

	aAdd(aMessage, {"MSG" , FwNoAccent(cp_Msg)})
	aAdd(aMessage, {"Date", Date()})
	aAdd(aMessage, {"Hour", Time()})

	If getRemoteType() != NO_REMOTE
		aAdd(aMessage, {"Computer", GetClientIP()})
		aAdd(aMessage, {"IP", GetClientIP()})
	EndIf

	FWLogMsg(;
		cp_Sever,;          //cSeverity      - Informe a severidade da mensagem de log. As opções possíveis são: INFO, WARN, ERROR, FATAL, DEBUG
	,;                      //cTransactionId - Informe o Id de identificação da transação para operações correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
	"zLogMsg",;             //cGroup         - Informe o Id do agrupador de mensagem de Log
	FunName(),;             //cCategory      - Informe o Id da categoria da mensagem
	"",;                    //cStep          - Informe o Id do passo da mensagem
	"01",;                  //cMsgId         - Informe o Id do código da mensagem
	FwNoAccent(cp_Msg),;    //cMessage       - Informe a mensagem de log. Limitada à 10K
	0,;                     //nMensure       - Informe a uma unidade de medida da mensagem
	0,;                     //nElapseTime    - Informe o tempo decorrido da transação
	aMessage;               //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
	)

	RestArea(aArea)
Return
