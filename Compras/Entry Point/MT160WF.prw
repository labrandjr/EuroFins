#include "totvs.ch"  
/*/{protheus.doc}MT160WF
Ponto de entrada no final da rotina analise de cotacao
@author Sergio Braz
@since 03/05/2019
/*/
User Function MT160WF  
	Local cNum := IIf(Valtype(ParamIxb)=="A",ParamIxb[1],ParamIxb)
	U_ENVHTML("IP", cNum, {,,1,},"MATA160")
Return