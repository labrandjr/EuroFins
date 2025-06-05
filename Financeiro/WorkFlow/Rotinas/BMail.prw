#include 'protheus.ch'
#include 'parmtype.ch'
#include "TBICONN.CH"


/*/{Protheus.doc} BrasMail
Envio de e-mail
@author Renato Castro
@since 26/01/2016
@version 1.0
@param cEmailTo, characters, descricao
@param cEmailBcc, characters, descricao
@param cTitulo, characters, descricao
@param cMensagem, characters, descricao
@param cAnexo, characters, descricao
@param lMsg, logical, Se exibe a mensagem de Ok no envio
@param cSender, characters, Se quiser mudar o remetente
@type function
/*/
user function BMail(cEmailTo,cEmailBcc,cTitulo,cMensagem,cAnexo,lMsg,cSender)
 
	local lRetorno 	  	:= .T.
	local aArquivos	  	:= {}
		
	if !empty(cAnexo)
		aadd(aArquivos,cAnexo)
	endif
	
	GFEMail(cEmailTo,cTitulo,cMensagem,.T.,aArquivos)

return(lRetorno)