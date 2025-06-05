#include "Totvs.ch"  

/*/{Protheus.doc} xCadZZE
//Cadastro tabela ZZE
@author Julio Lisboa
@since 10/08/2020
@version 1.0
@type function
/*/
User Function XCadZZE()

	Local cAlias 		:= "ZZE"
	Local cTitulo 		:= "DE/PARA Cond. Pagto COUPA"

	AxCadastro(cAlias,cTitulo,".T.","U_ZZEALT()")

Return

/*
Função para validar a inclusão e alteração do registro
*/
User Function ZZEALT

	Local aAreaAtu	:= GetArea()
	Local aAreaZZE	:= ZZE->(GetArea())
	Local lRet		:= .T.
	Local cCondCou	:= M->ZZE_CODCOU
	Local cMsg		:= ""
	
		
	ZZE->(dbSetOrder(1))
	If ZZE->(dbSeek(xFilial("ZZE") + cCondCou))
	
		cMsg := "A Condição do Coupa informada (" + Alltrim(cCondCou) + ") já foi utilizada em outro DE/PAARA."
		cMsg += CRLF + CRLF
		cMsg += "Inclusão não permitida. Verifique se a mesma está correta ou altere a existente."
		
		MsgInfo(cMsg,"ATENÇÃO")
	
		lRet := .F.
		cMsg := ""
	EndIf

	ZZE->(RestArea(aAreaZZE))
	RestArea(aAreaAtu)

Return lRet
