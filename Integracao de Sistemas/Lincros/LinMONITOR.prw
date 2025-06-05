#Include 'Totvs.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'

#DEFINE TITULO				"Monitor de Integrações - Lincros"

#DEFINE POS_FILTRO  01
#DEFINE POS_COR     02
#DEFINE POS_LEGEND  03

//-----------------------------------------------------------------
/*/{Protheus.doc} LinMONITOR
Rotina de monitor da integração do Lincros

@type		Function
@author		Régis Ferreira
@since		01/12/2022
/*/
//-------------------------------------------------------------------
user function LinMONITOR()

    Local oBrowse 	        := FWMBrowse():New()
    Local nI                := 0
    Local aCorTmp           := {}

    Private cCadastro       := TITULO
    Private aRotina         := MenuDef()

    If !getnewpar("ZZ_LINCR05",.F.)
        MsgAlert("Integração Lincros Desligada!",FunDesc())
    EndIf

    dbSelectArea("ZZL")
    ZZL->(DbSetOrder(1))

    oBrowse:SetAlias('ZZL')
    oBrowse:SetDescription(TITULO)

    aCorTmp := retCores()
    For nI := 1 to Len(aCorTmp)
        oBrowse:AddLegend( aCorTmp[nI,POS_FILTRO] , aCorTmp[nI,POS_COR] , aCorTmp[nI,POS_LEGEND] )
    Next
    
    oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina Title 'Visualizar'               Action 'VIEWDEF.LinMONITOR'         OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title 'Configurações'            Action 'U_LinParametros()'		    OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title 'Integrar'                 Action 'U_LINCIP01(.F.)' 			OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title 'Excluir'					Action 'VIEWDEF.LinMONITOR' 		OPERATION 5 ACCESS 0
    ADD OPTION aRotina Title 'Legenda'                  Action 'U_LinLegMonit()'    		OPERATION 1 ACCESS 0
    ADD OPTION aRotina Title 'Liga/Desliga Integração'  Action 'U_LinLigInt()' 			    OPERATION 9 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStruCab 		:= FWFormStruct(1, "ZZL" )
    Local oStruItens	:= FWFormStruct(1, "ZZM" )
    Local oModel

    oModel := MPFormModel():New("PE_LINMONIT", /*bPre*/, {|oMdl| MDMVlPos( oMdl ) }/*bPos*/,/*bCommit*/,/*bCancel*/)

    oModel:AddFields('ZZLMASTER',, oStruCab)
    oModel:AddGrid( 'ZZMDETAIL', 'ZZLMASTER', oStruItens )

    oModel:GetModel('ZZLMASTER' ):SetDescription('Cabeçalho')
    oModel:GetModel('ZZMDETAIL' ):SetDescription('Itens Nota Fiscal')

    oModel:SetRelation( 'ZZMDETAIL', { { 'ZZM_FILIAL', 'xFilial( "ZZM" )' }, { 'ZZM_CODIGO', 'ZZL_CODIGO' } }, ZZM->( IndexKey( 1 ) ) )

    oModel:SetDescription(TITULO)
    oModel:SetPrimaryKey({})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()

    Local oModel 		:= FWLoadModel('LinMONITOR')
    Local oStruCab 		:= FWFormStruct(2, "ZZL")
    Local oStruItens 	:= FWFormStruct(2, "ZZM")
    Local oView

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField('CABEC', oStruCab, 'ZZLMASTER')
    oView:AddGrid( 'DETAIL', oStruItens, 'ZZMDETAIL' )

    oView:CreateHorizontalBox( 'SUPERIOR'	, 60 )
    oView:CreateHorizontalBox( 'INFERIOR'	, 40 )

    oView:SetOwnerView( 'CABEC', 'SUPERIOR' )
    oView:SetOwnerView( 'DETAIL', 'INFERIOR' )

    oStruItens:removeField("ZZM_CODIGO")

    oView:EnableTitleView('CABEC',"Cabeçalho")
    oView:EnableTitleView('DETAIL',"Itens Nota Fiscal")

    oStruCab:AddGroup( 'INT'	, 'Dados da Integração'		        , '', 2 )
    oStruCab:AddGroup( 'NOTA'	, 'Informações Cabeçalho da Nota'  	, '', 2 )
    oStruCab:AddGroup( 'FAT'	, 'Fatura'	    	                , '', 2 )

    oStruCab:SetProperty( 'ZZL_CODIGO' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_STATUS' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_INTEGR' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_TIPO' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_DOC' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_SERIE' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_FORNEC' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_LOJA' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_ERRO' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_DATA' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    oStruCab:SetProperty( 'ZZL_HORA' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )
    //oStruCab:SetProperty( 'ZZL_ENVIO' 	, MVC_VIEW_GROUP_NUMBER, 'INT' )

    oStruCab:SetProperty( 'ZZL_TIPONO' 	, MVC_VIEW_GROUP_NUMBER, 'NOTA' )
    oStruCab:SetProperty( 'ZZL_FORMUL' 	, MVC_VIEW_GROUP_NUMBER, 'NOTA' )
    oStruCab:SetProperty( 'ZZL_NOMEFO' 	, MVC_VIEW_GROUP_NUMBER, 'NOTA' )
    oStruCab:SetProperty( 'ZZL_CHAVE' 	, MVC_VIEW_GROUP_NUMBER, 'NOTA' )
    
    oStruCab:SetProperty( 'ZZL_RATCC' 	, MVC_VIEW_GROUP_NUMBER, 'FAT' )

Return oView

//-------------------------------------------------------------------
static function retCores()

    Local aCores        := {}

    //Legendas
    Local LEG_RECEBIDO	    :=	"1"
    Local LEG_INTEGRADO   :=	"2"
    Local LEG_INTDEV      :=	"3"
    Local LEG_ERRO        := 	"X"

    aAdd( aCores, { "ZZL_STATUS == '" + LEG_RECEBIDO    + "' "		, "BR_CINZA"  	        , "Recebido" })
    aAdd( aCores, { "ZZL_STATUS == '" + LEG_INTEGRADO   + "' "	    , "BR_LARANJA"  	    , "Recebido e Integrado com Protheus" })
    aAdd( aCores, { "ZZL_STATUS == '" + LEG_INTDEV      + "' "	    , "BR_VERDE"            , "Integrado Protheus e Devolvido ao Lincros" })
    aAdd( aCores, { "ZZL_STATUS == '" + LEG_ERRO        + "' "		, "BR_CANCEL"  	        , "Erro" })
    

return aCores

//-------------------------------------------------------------------
User Function LinLegMonit()

    Local aTmp      := {}
    Local nI        := 0
    Local aCores    := {}

    aTmp      := retCores()
    For nI := 1 to Len(aTmp)
        aAdd( aCores , { aTmp[nI,POS_COR] , aTmp[nI,POS_LEGEND] } )
    Next

    BrwLegenda(cCadastro,TITULO,aCores)

Return .T.

Static Function MDMVlPos( oModel )    
   
   Local nOperation := oModel:GetOperation()
   Local lRet := .T.        
   If ( nOperation == MODEL_OPERATION_DELETE .And. FwFldGet("ZZL_STATUS") <> "X" )
      Help( ,, "HELP","MDMVlPos", "Não é permitida exclusão de uma integração que não esteja com erro.", 1, 0)      
      lRet := .F.
   EndIf

Return lRet 
