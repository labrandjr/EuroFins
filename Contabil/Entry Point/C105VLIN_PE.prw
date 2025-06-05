#include 'protheus.ch'
#include 'parmtype.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} C105VLIN
Bloqueia a Exclus�o das Linhas de Lan�amento Cont�bil On-line

		***PAR�METRO MV_CT105LD tem que estar com 1 - Ativo***

@type		Function
@author 	Julio Lisboa
@since 		31/01/2020
@return		lRet, Retorno logico indicando se pode ou n�o excluir
/*/
//-----------------------------------------------------------------
user function C105VLIN()

	local lRet		:= .F.
	local cFlag		:= PARAMIXB[1]
	local cUserOk	:= GetNewPar("ZZ_USRDELC","")
	local cMsgErro	:= ""
	local cSolucao	:= ""
	
	If AllTrim(__cUserId) $ cUserOk
		lRet	:= .T.
	Else
		cMsgErro		+= "N�o � permitida a exclus�o de lan�amentos contabeis "
		cMsgErro		+= "pelo usuario [" + __cUserId + "]"
		
		cSolucao		+= "Verifique com o departamento de T.I. as permiss�es"
		
		Help(NIL, NIL, "C105VLIN", NIL, cMsgErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
	EndIf
	
return lRet
