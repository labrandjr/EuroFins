#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'

User Function MVCZZH()

    Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZH')
	oBrowse:SetDescription("Parametros ExpenseON") 
    oBrowse:SetMenuDef("MVCZZH")
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return()

Static Function MenuDef()

    Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  		ACTION 'PesqBrw'        OPERATION 1 ACCESS 0
   	ADD OPTION aRotina TITLE 'Visualizar' 		ACTION 'VIEWDEF.MVCZZH' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE 'Incluir'   	 	ACTION 'VIEWDEF.MVCZZH' OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE 'Alterar'    		ACTION 'VIEWDEF.MVCZZH' OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE 'Excluir'    		ACTION 'VIEWDEF.MVCZZH' OPERATION 5 ACCESS 0 

Return aRotina

Static Function ModelDef()

	Local oStruZZH  := FWFormStruct(1,"ZZH")
	Local oModel

	oModel	:= MPFormModel():New( "MMVCZZH" ,/*pre*/ ,/*post{|oModel| MKTPM01( oModel ) }*/ , /*commit*/ {|oModel| fwformcommit(oModel)} , /*cancel*/ )

	oModel:AddFields('ZZHMASTER',, oStruZZH)

	oModel:SetPrimaryKey({'ZZH_FILPRO'})
    oModel:SetDescription('Parametros ExpenseON')
	oModel:GetModel('ZZHMASTER'):SetDescription('Parametros ExpenseON')
    oModel:SetVldActivate({|oModel| MVCZZHA( oModel ) })


    oStruZZH:SetProperty("ZZH_FILPRO" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_URL" 		,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_LOGIN" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_SENHA" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_BANCO" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_AGENCI" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_CONTA" 	,MODEL_FIELD_OBRIGAT,.T.) 
    //oStruZZH:SetProperty("ZZH_CC" 		,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_NATURE" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_PREFIX" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_PREFDP" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_TIPODP" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_NATURD" 	,MODEL_FIELD_OBRIGAT,.T.) 
    oStruZZH:SetProperty("ZZH_CONDPG" 	,MODEL_FIELD_OBRIGAT,.T.) 


	//CAMPOS SÓ VISUALIZAÇÃO
	oStruZZH:SetProperty("ZZH_FILPRO" ,MODEL_FIELD_WHEN,  FwBuildFeature(STRUCT_FEATURE_WHEN,   'INCLUI'))
	oStruZZH:SetProperty("ZZH_TOKEN"  ,MODEL_FIELD_WHEN,  FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))
	oStruZZH:SetProperty("ZZH_VALID"  ,MODEL_FIELD_WHEN,  FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))

    oStruZZH:SetProperty("ZZH_BANCO"  ,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,  'EXISTCPO("SA6")'))
    oStruZZH:SetProperty("ZZH_FILPRO" ,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,  'EXISTCPO("SM0",cEmpAnt+M->ZZH_FILPRO,1)'))
    oStruZZH:SetProperty("ZZH_CC"     ,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,  'EXISTCPO("CTT")'))
    oStruZZH:SetProperty("ZZH_NATURE" ,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,  'EXISTCPO("SED")'))
    oStruZZH:SetProperty("ZZH_TIPODP" ,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,  'EXISTCPO("SX5","05"+M->ZZH_TIPODP)'))
    oStruZZH:SetProperty("ZZH_NATURD" ,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,  'EXISTCPO("SED")'))
    oStruZZH:SetProperty("ZZH_CONDPG" ,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,  'EXISTCPO("SE4")'))


Return oModel


Static Function ViewDef()

	Local oModel 	:= FwLoadModel("MVCZZH") 
	Local oStruZZH  := FWFormStruct(2,"ZZH")
	Local oView		:= FWFormView():New()

	//F3
    oStruZZH:SetProperty("ZZH_FILPRO", MVC_VIEW_LOOKUP, "SM0")  
    oStruZZH:SetProperty("ZZH_BANCO" , MVC_VIEW_LOOKUP, "SA6")
    oStruZZH:SetProperty("ZZH_CC"    , MVC_VIEW_LOOKUP, "CTT")
    oStruZZH:SetProperty("ZZH_NATURE", MVC_VIEW_LOOKUP, "SED")
    oStruZZH:SetProperty("ZZH_TIPODP", MVC_VIEW_LOOKUP, "05")
    oStruZZH:SetProperty("ZZH_NATURD", MVC_VIEW_LOOKUP, "SED")
    oStruZZH:SetProperty("ZZH_CONDPG", MVC_VIEW_LOOKUP, "SE4")

    oStruZZH:AddGroup( 'GRUPO01', 'Config. ExpenseON', '', 2 )
    oStruZZH:AddGroup( 'GRUPO02', 'Adiantamentos', '', 2 )
    oStruZZH:AddGroup( 'GRUPO03', 'Despesas', '', 2 )
    oStruZZH:AddGroup( 'GRUPO04', 'Token', '', 2 )

	oStruZZH:SetProperty( 'ZZH_FILPRO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZZH:SetProperty( 'ZZH_URL'		, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZZH:SetProperty( 'ZZH_LOGIN'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZZH:SetProperty( 'ZZH_SENHA'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

	oStruZZH:SetProperty( 'ZZH_BANCO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZZH:SetProperty( 'ZZH_AGENCI'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZZH:SetProperty( 'ZZH_CONTA'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZZH:SetProperty( 'ZZH_CC'	    , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZZH:SetProperty( 'ZZH_NATURE'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZZH:SetProperty( 'ZZH_PREFIX'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZZH:SetProperty( 'ZZH_DIAVCT'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

	oStruZZH:SetProperty( 'ZZH_PREFDP'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZZH:SetProperty( 'ZZH_TIPODP'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZZH:SetProperty( 'ZZH_NATURD'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZZH:SetProperty( 'ZZH_CONDPG'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

	oStruZZH:SetProperty( 'ZZH_TOKEN'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	oStruZZH:SetProperty( 'ZZH_VALID'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )

	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER', oStruZZH, 'ZZHMASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100)
	oView:SetOwnerView('VIEW_MASTER', 'SUPERIOR')
	oView:SetCloseOnOK( {|| .T.} )


Return oView

//Valida antes de montar a tela 
Static Function MVCZZHA( oModel )

	Local lRet          := .T.
	//Local nOperation    := oModel:GetOperation()

	//If nOperation == MODEL_OPERATION_INSERT	
	//EndIf

	//If nOperation == MODEL_OPERATION_UPDATE	
	//EndIf

	//If nOperation == MODEL_OPERATION_DELETE	
	//EndIf


Return lRet
