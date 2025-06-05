#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"

/*/{Protheus.doc} ZB7010
Finalidade: Rotina AxCadastro de Clientes x Natureza Financeira
Será um gatilho no pedido de venda
Módulo: Faturamento

@type function
@author Régis Ferreira - TOTVS IP Jundiaí
@since 25/06/2020
@version Protheus 12 - Faturamento
@return nil

/*/

User Function ZB7010

	Local cVldAlt := "U_ZB7ALT()" // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := "U_ZB7EXC()" // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

	Private cString := "ZB7"

	dbSelectArea("ZB7")
	dbSetOrder(1)

	AxCadastro(cString,"Cliente x Natureza",cVldExc,cVldAlt)

Return

//Função para validar a inclusão e alteração do registro
	*************************
User Function ZB7ALT
	*************************

	Local lRet		:= .T.
	Local cCliente	:= M->ZB7_CLIENT
	Local cLoja		:= M->ZB7_LOJA
	Local cMsg		:= ""

	If INCLUI
		ZB7->(dbSetOrder(1))
		If ZB7->(dbSeek(cFilAnt+cCliente+cLoja))

			cMsg := "Já temos cadastro realizado para esse cliente."
			cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)
			cMsg += "Inclusão não permitida. Verifique se o mesmo está correto."

			MsgInfo(cMsg,"ATENÇÃO")

			lRet := .F.
		EndIf
	EndIf

Return(lRet)

//Função para validar a exclusão do registro
	*************************
User Function ZB7EXC
	*************************

	Local lRet		:= .T.

Return(lRet)
