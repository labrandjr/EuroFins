#include 'protheus.ch'
#include 'parmtype.ch'
/*/{protheus.doc}FA240PA
Valida seleção de PA
@author Unknown
@since __/__/____
/*/
User Function FA240PA()
	Local lRet  :=  .T.

	lRet :=  MsgYesNo("Permite selecionar PA? ","")

Return lRet