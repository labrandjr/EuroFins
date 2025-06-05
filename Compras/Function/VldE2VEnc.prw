#include "totvs.ch"
/*/{protheus.doc} VldE2VEnc
Valida��o do campo E2_VENCTO para a rotina MATA103
@author Sergio Braz
@since 07/06/2019
/*/
User Function VldE2VEnc
	Local lRet := .T.  
	Local aVenc
	Local nDiaFre := SuperGetMV("ZZ_PGTDFR",,"0") //dias pra frente que ser� aceito ao alterar a data de vencimento de nota fiscal de entrada.
	Local nDiaAtr := SuperGetMV("ZZ_PGTDAT",,"0") //dias pra tr�s que ser� aceito ao alterar a data de vencimento de nota fiscal de entrada.
	If IsInCallStack("MATA103").and.!'CTE'$cEspecie
		aVenc := Condicao(100,cCondicao,,dDEmissao)  
		If M->E2_VENCTO-aVenc[n,1] < (nDiaAtr*-1)
			MsgStop("N�o � permitido diminuir a data de pagamento calculado pelo sistema com mais de "+Alltrim(Str(nDiaAtr))+" dias do vencimento original.","Data inv�lida")
			lRet := .f.     
		Endif	
		If M->E2_VENCTO-aVenc[n,1] > (nDiaFre)
			MsgStop("N�o � permitido aumentar a data de pagamento calculado pelo sistema com mais de "+Alltrim(Str(nDiaFre))+" dias do vencimento original.","Data inv�lida")
			lRet := .f.     
		Endif	
	Endif
Return lRet
