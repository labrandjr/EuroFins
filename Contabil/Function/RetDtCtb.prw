#include 'totvs.ch'

/*/{Protheus.doc} RetDtCtb
rotina de valida��o do pergunta data fim da contabiliza��o autom�tica
@type function
@version 12.1.33
@author Leandro Cesar
@since 3/10/2023
@return date, data at� para contabiliza��o
/*/
user function RetDtCtb()
	local dDtRet := dDataBase as date

	If day(dDataBase) == 1
		dDtRet := FirstDate(dDataBase)
	Else
        // dDtRet := cTod("06/03/2023")
		dDtRet := DaySub(dDataBase,1)
	EndIf

return(dDtRet)
