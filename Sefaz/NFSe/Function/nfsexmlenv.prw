#include "protheus.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} nfseXMLEnv
Função que monta o XML único de envio para NFS-e ao TSS.
@author Unknown
@since 19.01.2012
@param	cTipo		Tipo do documento.
@param	dDtEmiss	Data de emissão do documento.
@param	cSerie		Serie do documento.
@param	cNota		Número do documento.
@param	cClieFor	Cliente/Fornecedor do documento.
@param	cLoja		Loja do cliente/fornecedor do documento.
@param	cMotCancela	Motivo do cancelamento do documento.

@return	cString		Tag montada em forma de string.
/*/

user function nfseXMLEnv( cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela,aAIDF )
	Local aRet

	if cFilAnt == "0200" .or. cFilAnt == "0600" //Innolab Rio / Ipex
		aRet := U_nfsInnolab( cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela,aAIDF )
	elseif cFilAnt == "0500"  .or. cFilAnt == "0501" .or. cFilAnt == "0504" .or. cFilAnt == "0101" .or. cFilAnt == "0802" .or. cFilAnt == "0602" .or. cFilAnt == "0603" .or. cFilAnt == "0604" .or. cFilAnt == "0605" // Sao Paulo Bittencourt / Francisco Cruz / Recife /Rio Claro
		aRet := U_nfsAnatec( cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela,aAIDF )
	else
		aRet := U_nfsPadrao( cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela,aAIDF )
	endif
Return aRet

