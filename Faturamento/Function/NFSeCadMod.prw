#Include "Protheus.ch"
#Include "fwmvcdef.ch"

/*/{Protheus.doc} NFSeCadMod
CRUD MVC do Cadastro de Modelos de NF de Serviço
@type function
@version 1.0
@author Ademar Fernandes Jr.
@since 04/03/2023
@link https://gkcmp.com.br (Geeker Company)
@see https://www.ibge.gov.br/explica/codigos-dos-municipios.php
/*/
User Function NFSeCadMod()
	local oBrowse   := Nil
	private cTitulo := OemToAnsi("Cadastro de Modelos de NF de Serviço")
	
	DbSelectArea("ZZN")	//-Cadastro Modelos de NF Serviço
	DbSetOrder(1)		//-ZZN_FILIAL+ZZN_MODELO
	// DbSetOrder(2)		//-ZZN_FILIAL+ZZN_ESTADO+ZZN_CODMUN

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'ZZN' )
	oBrowse:SetDescription( cTitulo )

	oBrowse:Activate()

Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.NFSeCadMod'	OPERATION 2 ACCESS 0	//-Visualizar
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.NFSeCadMod'	OPERATION 3 ACCESS 0	//-Incluir
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.NFSeCadMod'	OPERATION 4 ACCESS 0	//-Alterar
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.NFSeCadMod'	OPERATION 5 ACCESS 0	//-Excluir
    // ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_LegCadMod()'			OPERATION 6 ACCESS 0	//-Legenda
	// ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.NFSeCadMod'	OPERATION 8 ACCESS 0	//-Imprimir
	// ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.NFSeCadMod'	OPERATION 9 ACCESS 0	//-Copiar

Return aRotina

user function LegCadMod()
	local aLegenda := {}

	aAdd(aLegenda,{"BR_AMARELO" , "Pendente" })
	aAdd(aLegenda,{"BR_VERDE"	, "Ok" })
	aAdd(aLegenda,{"BR_VERMELHO", "Nao Ok" })

	BrwLegenda("Legenda", "Legenda", aLegenda)
Return

Static Function ModelDef()
	local oModel     := Nil
	local oStructCab := FWFormStruct( 1, 'ZZN')

	//-Cria o objeto do Modelo de Dados
	//-/*cID*/, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/
	oModel := MPFormModel():New( 'ZZNMODEL' )

	//-Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'ZZNMASTER', NIL, oStructCab )

	//-Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( cTitulo )

	//-Adiciona a descrição do Componente do Modelo de Dados
	oModel:GetModel( 'ZZNMASTER' ):SetDescription( cTitulo )

	oModel:SetPrimaryKey( { 'ZZN_FILIAL','ZZN_MODELO' } )

Return oModel

Static Function ViewDef()
	local oView		 := Nil
	local oModel	 := FWLoadModel( 'NFSeCadMod' )
	Local oStructCab := FWFormStruct( 2, 'ZZN')
	
	// oStructCab:RemoveField( 'ZZN_STATUS' )

	//-Cria o objeto de View
	oView := FWFormView():New()
	
	//-Define qual o Modelo de dados será utilizado na View
	oView:SetModel( oModel )
	
	//-Adiciona no nosso View um controle do tipo formulário
	oView:AddField( 'VIEW_ZZN' , oStructCab, 'ZZNMASTER'  )
	
	//-Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'MASTER', 99 )
	
	//-Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_ZZN' , 'MASTER' )

Return oView
