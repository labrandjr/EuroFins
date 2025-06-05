#include "totvs.ch"  
/*/{protheus.doc}A116IDOC
Ponto de entrada na importação de XML para informar zeros à esquerda no doc e serie   (CTE)
@author Sergio Braz
@since 19/11/2019
/*/
User Function A116IDOC
	Local cDoc   := ParamIxb[1]    
	Local cSerie := ParamIxb[2]
	cDoc   := StrZero(Val(cDoc),9)
	cSerie := iif(IsNumeric(cSerie),StrZero(Val(cSerie),3),cSerie)
Return {cDoc,cSerie}

