#include "totvs.ch"
/*/{protheus.doc}MT131WF
Ponto de entrada ao final da rotina Gera Cotação (Mata131).
Utilizada para enviar email para destinatários específicos
@author Sergio Braz
@since 08/05/2019
/*/
User Function MT131WF   
	Local cNum := PARAMIXB[1]
	U_ENVHTML("CT",cNum,{1},"MATA131")
Return