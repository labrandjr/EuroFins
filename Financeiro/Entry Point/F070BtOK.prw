#include "totvs.ch" 
/*/{protheus.doc}FA080TIT
Na baixa de titulos a receber valida contrato de cambio
@author Sergio Braz
@since 02/09/2019
@history 27/02/2020, Gabriel Da Silva, Alterado a linha 12 inserindo a variavel global cMotbx.
/*/
User Function F070BtOK
	Local lRet := .T.
	Local cNumero := SE1->E1_ZZCTCAM
	If SE1->E1_MOEDA<>1
		If MovBcoBx(cMotBx,.T.)
			cNumero := FwInputBox("Numero do contrato de câmbio",cNumero)
			If Empty(cNumero)
				MsgStop("Contrato de câmbio inválido","FA080TIT")
				lRet := .F. 
			Else   
				RecLock("SE1",.F.)
				SE1->E1_ZZCTCAM := cNumero
				SE1->(MsUnlock())
			Endif
		Endif
	Endif
	
Return lRet