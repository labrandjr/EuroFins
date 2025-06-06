#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"

/*/{Protheus.doc} ZB7010
Finalidade: Rotina AxCadastro de Clientes x Natureza Financeira
Ser� um gatilho no pedido de venda
M�dulo: Faturamento

@type function
@author R�gis Ferreira - TOTVS IP Jundia�
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

//Fun��o para validar a inclus�o e altera��o do registro
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

			cMsg := "J� temos cadastro realizado para esse cliente."
			cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)
			cMsg += "Inclus�o n�o permitida. Verifique se o mesmo est� correto."

			MsgInfo(cMsg,"ATEN��O")

			lRet := .F.
		EndIf
	EndIf

Return(lRet)

//Fun��o para validar a exclus�o do registro
	*************************
User Function ZB7EXC
	*************************

	Local lRet		:= .T.

Return(lRet)
