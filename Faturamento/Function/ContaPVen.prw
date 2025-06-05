#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ContaPVen
no cadastro de clientes para geração da conta contabil
@author Unknown
@since 02/01/2018
/*/
user function ContaPVen()
Local cTpCliente := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")
Local cColig 	 := Alltrim(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_ZZCOLIG"))
Local cConta 	 := Alltrim(Posicione('SB1',1,xfilial('SB1')+M->C6_PRODUTO, 'B1_CONTA'))

if cColig == "S"
	if cTpCliente <> "EX"
		cConta := "31103001"
	else
		cConta := "31103002"
	endif
else
	if cTpCliente == "EX"
		if cConta == "31101001"
			cConta := "31102001"
		elseif cConta == "31101002"
			cConta := "31102002"
		elseif cConta == "31101003"
			cConta := "31102003"
		elseif cConta == "31101004"
			cConta := "31102004"
		endif
	endif
endif

return cConta