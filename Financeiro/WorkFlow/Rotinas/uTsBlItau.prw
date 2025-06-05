#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'


/*/{Protheus.doc} EscBolCorreto
Faz a escolha dos boletos

@author 	Fabio Hayama - Geeker Company
@since 		20/03/2018
@version	1.0
@example	''
@see 		''
/*/
user function uTsBlItau()
    u_BltITAU("000132601", .T., "", "", .F.)	
return

user function sTsBlItau()
	local cAuxEmp 	:= "01"
	local cAuxFil	:= "0100"
	
	RPCSetType(3) 	 
	PREPARE ENVIRONMENT EMPRESA cAuxEmp FILIAL cAuxFil		 
	SetModulo("SIGAFIN","FIN")

    u_uTsBlItau()

    RESET ENVIRONMENT
return