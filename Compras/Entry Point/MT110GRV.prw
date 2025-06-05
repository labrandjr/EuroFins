#include 'protheus.ch'
#include 'parmtype.ch'
/*/{protheus.doc} MT110GRV
Após a gravação da SC, grava campos personalizados
@author Unknown
@since __/__/____
/*/
user function MT110GRV()
	local cNumSC := SC1->C1_NUM

	if ALTERA
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1")+cNumSC))
			while SC1->C1_NUM == cNumSC .and. !Eof()
				RecLock("SC1",.F.)
				C1_ZZDATA := cTod("  /  /  ")
				C1_ZZHORA := "     "
				MsUnlock()
				dbSkip()
			enddo
	endif

return .T.