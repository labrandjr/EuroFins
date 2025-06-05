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
Fun��o para validar a inclus�o e altera��o do registro
*/
User Function ZZEALT

	Local aAreaAtu	:= GetArea()
	Local aAreaZZE	:= ZZE->(GetArea())
	Local lRet		:= .T.
	Local cCondCou	:= M->ZZE_CODCOU
	Local cMsg		:= ""
	
		
	ZZE->(dbSetOrder(1))
	If ZZE->(dbSeek(xFilial("ZZE") + cCondCou))
	
		cMsg := "A Condi��o do Coupa informada (" + Alltrim(cCondCou) + ") j� foi utilizada em outro DE/PAARA."
		cMsg += CRLF + CRLF
		cMsg += "Inclus�o n�o permitida. Verifique se a mesma est� correta ou altere a existente."
		
		MsgInfo(cMsg,"ATEN��O")
	
		lRet := .F.
		cMsg := ""
	EndIf

	ZZE->(RestArea(aAreaZZE))
	RestArea(aAreaAtu)

Return lRet
