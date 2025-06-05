#INCLUDE "totvs.ch"

/*/{Protheus.doc} NFSeBrLeg

Ponto de Entrada para definição das legendas no browser do Integrador da NFS-e da TOTVS IP
	
@author Winston Dellano de Castro
@since 17/12/2015

@param oBrowse, Objeto, Browser do Integrador da NFS-e da TOTVS IP
@param lUseWebService, logical, Indica se o browser utiliza web service
/*/
user function NFSeBrLeg(oBrowse,lUseWebService)

	lUseWebService := .T.
	
	if lUseWebService
		oBrowse:AddLegend("F2_FIMP == ' ' ","RED"   ,"XML não gerado")
		oBrowse:AddLegend("F2_FIMP == 'G' ","BLUE"  ,"XML gerado com sucesso")
		oBrowse:AddLegend("F2_FIMP == 'S' ","GREEN" ,"NFS-e autorizada")
		oBrowse:AddLegend("F2_FIMP == 'X' ","WHITE" ,"NFS-e substituta de outra NFS-e")
		oBrowse:AddLegend("F2_FIMP == 'Y' ","YELLOW","NFS-e substituída por outra NFS-e")
		oBrowse:AddLegend("F2_FIMP == 'Z' ","ORANGE","NFS-e corrigida")
	endif

return