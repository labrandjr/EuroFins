#INCLUDE "totvs.ch"
#INCLUDE "fwmvcdef.ch"

#DEFINE NAO_EXPORTADAS	" "
#DEFINE EXPORTADAS		"S"
#DEFINE TRANSMITIDAS	"T"

/*/{Protheus.doc} NFSeBrowse

Rotina do Menu Principal para apresentação dos dados da NF de Saída (SF2) com Funções do Integrador da NFS-e da TOTVS IP

@author Winston Dellano de Castro
@since 18/12/2015

/*/ 
User Function NFSeBrowse()

	local cAliasForm := "SF2"
	local cMessage   := ""

	private cTitle   := "Integrador NFS-e TOTVS IP (Garibaldi - RS)"
	private oBrowse  := nil
	private lActive  := GetNewPar("ZZ_NFSEINT",.T.)
	private oNFSe    := NFSeInfisc():newNFSeInfisc(cTitle)
	private aRotinas := {}
	private cFilter  := ""    
	Private lCancelado:= .f.

	if !(lActive)
		cMessage := "Atenção! O Integrador da NFS-e da TOTVS IP está desativado para esta empresa/filial. "
		cMessage += "Utilize a rotina padrão da NFS-e (FISA022)."
		cMessage += "Caso seja necessário utilizar o integrador, atualize o parâmetro 'ZZ_NFSEINT'."

		MsgAlert(cMessage,"TOTVS IP")

		return
	endif

	if ValType(oNFSe) == "O"

		if loadParam()

			oBrowse := FWMBrowse():new()

			oBrowse:setAlias(cAliasForm)
			oBrowse:setDescription(cTitle) 	
			oBrowse:setMenuDef("")

			addFilters(cFilter)		
			addLegends()
			addButtons()

			//oBrowse:setUseCursor(.F.)
			oBrowse:setCacheView(.F.)
			oBrowse:activate()		
		endif
	endif

return


/**
* Adiciona Filtros no Browse
**/
static function addFilters()

	if !(Empty(cFilter))
		oBrowse:setFilterDefault(cFilter)
	endif

return


/**
* Adiciona a Legenda no Browse
*/
static function addLegends()

	//################################################################################################
	//Ponto de Entrada para definição das legendas no browser do Integrador da NFS-e da TOTVS IP 
	//################################################################################################	
	if ExistBlock("NFSeBrLeg")	
		U_NFSeBrLeg(@oBrowse,lActive)
	else
		if lActive
			oBrowse:addLegend("F2_FIMP == ' ' ","RED"   ,"NFS-e não Transmitida")
			oBrowse:addLegend("F2_FIMP == 'T' ","BLUE"  ,"NFS-e Transmitida")
			oBrowse:addLegend("F2_FIMP == 'S' ","GREEN" ,"NFS-e Autorizada")
			oBrowse:addLegend("F2_FIMP == 'A' ","YELLOW","NFS-e Processando (Realize a Consulta da Transmissão)")
			oBrowse:addLegend("F2_FIMP == 'E' ","BLACK" ,"NFS-e Com Erro de Transmissão")
			oBrowse:addLegend("F2_FIMP == 'C' ","ORANGE","NFS-e Cancelada")
			oBrowse:addLegend("F2_FIMP == 'D' ","PINK"  ,"NFS-e Com Erro de Cancelamento")
		else
			oBrowse:addLegend("F2_FIMP == ' ' ","RED"   ,"RPS Não Exportado")
			oBrowse:addLegend("F2_FIMP == 'T' ","BLUE"  ,"RPS Exportado/Transmitido")
			oBrowse:addLegend("F2_FIMP == 'S' ","GREEN" ,"NFS-e Autorizada")
		endif
	endif

return


/**
* Função que Monta o Menu da Rotina do Cadastro
*/ 
static function addButtons()

	//################################################################################################
	//Ponto de Entrada para definição das opções de menu no browser do Integrador da NFS-e da TOTVS IP 
	//################################################################################################	
	if ExistBlock("NFSeBrMnu")
		U_NFSeBrMnu(@oBrowse,lActive)
	else	
		oBrowse:addButton("Visualiza Docto"             ,{|| u_NFeShowDoc(@oBrowse)   },,10)
		oBrowse:addButton("Exportar NFS-e"              ,{|| exportNFSe()             },,11)
		oBrowse:addButton("Importar Retorno NFS-e"      ,{|| oNFSe:importNFSe()       },,12)
		oBrowse:addButton("Imprimir RPS"                ,{|| oNFSe:printRPS()         },,13)
		oBrowse:addButton("Imprimir NFS-e"              ,{|| oNFSe:printNFSe()        },,14)
		oBrowse:addButton("Atualizar Browse"	        ,{|| u_NFeRefDoc(@oBrowse)    },,15)
		oBrowse:addButton("Visualizar Cad. do Município",{|| u_NFeShowCityData(@oNFSe)},,19)
		oBrowse:addButton("Wizard de Config."           ,{|| u_NFSeWizard(@oNFSe)     },,20)
		oBrowse:addButton("Atualizar NFS-e no RPS"      ,{|| oNFSe:inputNFSe()        },,20)	

		if lActive
			oBrowse:addButton("Transmitir NFS-e"        ,{|| oNFSe:enviarLoteNotas()  },,16)
			oBrowse:addButton("Consulta Transmissão"    ,{|| oNFSe:queryNFSe()        },,17)
			oBrowse:addButton("Cancelar NFS-e"          ,{|| oNFSe:cancelNFSe()       },,18)
		endif	
	endif

return


/**
* Mostra o documento posicionado
**/
user function NFeShowDoc(oBrowse)
	Mc090Visual("SF2",SF2->(RecNo()),1)
return


/**
* Atualiza o browser
**/
user function NFeRefDoc(oBrowse)
	oBrowse:refresh() 
return


/**
* Mostra o cadastro de cidades
**/
user function NFeShowCityData(oNFSe)

	dbSelectArea("CC2")
	CC2->(dbSetOrder(1)) //CC2_FILIAL+CC2_EST+CC2_CODMUN
	if CC2->(dbSeek(xFilial("CC2") + oNFSe:getEstado() + oNFSe:getCodMun()))
		FWExecView("VISUALIZAR","VIEWDEF.FISA010",MODEL_OPERATION_VIEW,,{ || .T. },{|| .T.})
	else
		FWExecView("VISUALIZAR","VIEWDEF.FISA010",MODEL_OPERATION_VIEW,,{ || .T. },{|| .T.})
	endif	

return


/**
* Função para Carregar as Perguntas Iniciais para Montagem da Tela 
**/
static function loadParam()

	local lReturn    := .F.
	local cGrupoPerg := "NFSeInfisc_" + oNFSe:getEstado() + oNFSe:getCodMun() + "_" + cUserName
	local cTitlePerg := "Filtros Iniciais NFS-e"
	local oParamBox  := IpParamBoxObject():newIpParamBoxObject(cGrupoPerg)

	oParamBox:setTitle(cTitle + " - " + cTitlePerg)
	addParams(@oParamBox)

	if lReturn := oParamBox:show()
		setFilter(oParamBox)
	endif

return lReturn


/**
* Adiciona Parâmetros da Rotina Principal do Integrador para Filtro de NFs
**/
static function addParams(oParamBox)

	local oParam := nil	                                   

	dbSelectArea("SF2")

	oParam := IpParamObject():newIpParamObject("MV_PAR01","get","Série da NF","C",50,Len(SF2->F2_SERIE))
	oParam:setF3("01")
	oParam:setRequired(.F.)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("MV_PAR02","combo","Filtra","C",50)
	oParam:setValues({"1=Sem Filtro","2=Não Exportadas","3=Exportadas","4=Transmitidas"})
	oParam:setRequired(.F.)
	oParamBox:addParam(oParam)

return  


/**
* Define os Filtros de NFs de Saída da Rotina Principal do Integrador da NFS-e
**/
static function setFilter(oParamBox)

	local cSerieFiltro := AllTrim(oParamBox:getValue("MV_PAR01"))
	local cTipoFiltro  := AllTrim(oParamBox:getValue("MV_PAR02"))	

	if cTipoFiltro == "1"
		cFilter	:= ""
	elseif cTipoFiltro == "2"
		cFilter := " SF2->F2_FIMP == '" + NAO_EXPORTADAS + "' "
	elseif cTipoFiltro == "3"	
		cFilter := " SF2->F2_FIMP == '" + EXPORTADAS + "' "
	elseif cTipoFiltro == "4"
		cFilter := " SF2->F2_FIMP == '" + TRANSMITIDAS + "' "
	endif

	if !(Empty(cFilter))
		cFilter += " .AND. "
	endif

	if !(Empty(cSerieFiltro))
		cFilter += "SF2->F2_SERIE == '" + cSerieFiltro + "' .AND. "
	endif

	cFilter += "SF2->F2_FILIAL == '" + cFilAnt + "' "

return