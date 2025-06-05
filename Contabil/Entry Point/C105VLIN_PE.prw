#include 'protheus.ch'
#include 'parmtype.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} C105VLIN
Bloqueia a Exclusão das Linhas de Lançamento Contábil On-line

		***PARÂMETRO MV_CT105LD tem que estar com 1 - Ativo***

@type		Function
@author 	Julio Lisboa
@since 		31/01/2020
@return		lRet, Retorno logico indicando se pode ou não excluir
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
		cMsgErro		+= "Não é permitida a exclusão de lançamentos contabeis "
		cMsgErro		+= "pelo usuario [" + __cUserId + "]"
		
		cSolucao		+= "Verifique com o departamento de T.I. as permissões"
		
		Help(NIL, NIL, "C105VLIN", NIL, cMsgErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
	EndIf
	
return lRet
