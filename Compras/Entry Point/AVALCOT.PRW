#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} AVALCOT
Ponto de entrada utilizado para manipular pedidos de venda gerados a partir de uma cotação
@author ricar
@since 28/06/2018
/*/
user function AVALCOT()
	Local nEvento := PARAMIXB[1]
	If nEvento == 4
		RecLock("SC7",.F.)
		C7_ZZMAIL := "N"
		MsUnlock()
	endif
return
