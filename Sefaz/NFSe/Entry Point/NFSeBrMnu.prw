#INCLUDE "totvs.ch"

/*/{Protheus.doc} NFSeBrMnu

Ponto de Entrada para definição das opções de menu no browser do Integrador da NFS-e da TOTVS IP
	
@author Winston Dellano de Castro
@since 17/12/2015

@param oBrowse, Objeto, Browser do Integrador da NFS-e da TOTVS IP
@param lUseWebService, logical, Indica se o browser utiliza web service
/*/
user function NFSeBrMnu(oBrowse,lUseWebService)

	lUseWebService := .T.

	oBrowse:AddButton("Visualiza Docto"             ,{|| u_NFeShowDoc(@oBrowse)   },,10)
//	oBrowse:AddButton("Atualizar Browse"            ,{|| u_NFeRefDoc(@oBrowse)    },,15)
//	oBrowse:AddButton("Visualizar Cad. do Município",{|| u_NFeShowCityData(@oNFSe)},,19)
//	oBrowse:AddButton("Wizard de Config."           ,{|| u_NFSeWizard(@oNFSe)     },,20)
//	oBrowse:AddButton("Atualizar NFS-e no RPS"      ,{|| oNFSe:inputNFSe()        },,20)	
	
	if lUseWebService
		oBrowse:AddButton("Transmitir NFS-e"        ,{|| oNFSe:enviarLoteNotas()},,16)
		oBrowse:AddButton("Consulta Transmissão"    ,{|| oNFSe:consultaNFSe()},,17)
	endif

return