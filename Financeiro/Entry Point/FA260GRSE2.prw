#include 'totvs.ch'


/*/{Protheus.doc} FA260GRSE2
Grava informações adicionais no título conciliado DDA
@type function
@version 12.1.33
@author Leandro Cesar
@since 28/11/2022
/*/
user function FA260GRSE2()

	If !Empty(SE2->E2_CODBAR)
		If Empty(SE2->E2_FORBCO) .and. Empty(SE2->E2_FORAGE) .and. Empty(SE2->E2_FORCTA)
			If substr(SE2->E2_CODBAR,1,3) == '341'
				SE2->E2_FORMPAG := '30'
			Else
				SE2->E2_FORMPAG := '31'
			EndIf
		Else
			SE2->E2_CODBAR := ""
		EndIf
	EndIf

return()
