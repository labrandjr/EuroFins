#include 'rwmake.ch'

/*/{protheus.doc}MT110END
Na Aprovacao/Rejeicao/Bloqueio da SC. Usano para gravar a data e a hora da aprovacao. 
@Author Marcos Candido
@since 05/09/14
/*/
User Function MT110END

	Local cNumSC   := PARAMIXB[1]
	Local nEscolha := PARAMIXB[2]  // 1=Aprovou  2=Rejeitou  3=Bloqueou

	RecLock("SC1",.F.)
	C1_ZZDATA := dDataBase
	C1_ZZHORA := Time()
	MsUnlock()

Return