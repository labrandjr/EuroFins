#include 'totvs.ch'

/*/{Protheus.doc} FA070CA2
FA070CA2 - Cancela baixas
@type function
@version 12.1.27
@author Leandro Cesar
@since 16/05/2022
@link https://tdn.totvs.com/display/public/mp/FA070CA2+-+Cancela+baixas+--+11875
/*/
user function FA070CA2()

	// RESTAURA OS CAMPOS DE IMPOSTOS PCC
	If funname() == "FINA070" .and. FWIsInCallStack("FA070CAN")
		reclock("SE1",.F.)
		If SE1->(FieldPos("E1_XPIS")) > 0
			If Empty(SE1->E1_PIS) .and. !Empty(SE1->E1_XPIS)
				SE1->E1_BASEPIS := SE1->E1_XBASPIS
				SE1->E1_PIS     := SE1->E1_XPIS
				SE1->E1_XBASPIS := 0
				SE1->E1_XPIS    := 0
			EndIf
		EndIf

		If SE1->(FieldPos("E1_XCOF")) > 0
			If Empty(SE1->E1_COFINS) .and. !Empty(SE1->E1_XCOF)
				SE1->E1_BASECOF := SE1->E1_XBASCOF
				SE1->E1_COFINS  := SE1->E1_XCOF
				SE1->E1_XBASCOF := 0
				SE1->E1_XCOF    := 0
			EndIf
		EndIf

		If SE1->(FieldPos("E1_XCSLL")) > 0
			If Empty(SE1->E1_CSLL) .and. !Empty(SE1->E1_XCSLL)
				SE1->E1_BASECSL := SE1->E1_XBASCSL
				SE1->E1_CSLL    := SE1->E1_XCSLL
				SE1->E1_XBASCSL := 0
				SE1->E1_XCSLL   := 0
			EndIf
		EndIf
		SE1->(MsUnlock())
	EndIf

return
