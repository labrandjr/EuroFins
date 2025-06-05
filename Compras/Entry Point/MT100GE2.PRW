#include 'totvs.ch'

/*/{Protheus.doc} MT100GE2
Complementa a Gravação dos Títulos Financeiros a Pagar
@type function
@version 12.1.33
@author Leandro Cesar
@since 28/11/2022
/*/
user function MT100GE2()

	If !Empty(SA2->A2_BANCO).And.!Empty(SA2->A2_NUMCON)
		// SE2->E2_TIPODOC := "01"

		If substr(SA2->A2_BANCO,1,3) == '341'
			SE2->E2_FORMPAG := '01'
		Else
			SE2->E2_FORMPAG := '41'
		EndIf
	EndIf

return()
