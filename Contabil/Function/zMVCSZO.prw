//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Vari�veis Est�ticas
Static cTitulo := "Amarra��o Empresa X BU X CC"

/*/{Protheus.doc} zMVCSZO
Fun��o para cadastro da amarra��o cont�bil Empresa X BU X CC
@type function
@version 12.1.27
@author ADM_TLA8 (Leandro Cesar)
@since 4/03/2022
/*/
User Function zMVCSZO()
	Local aArea   := GetArea()
	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("SZO")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

// ---------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cria��o do menu MVC
@type function
@version 12.1.27
@author ADM_TLA8 (Leandro Cesar)
@since 14/03/2022
@return array, retorna o aRotina com  o menu
/*/
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCSZO' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    // ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCSZO' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCSZO' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCSZO' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
// ---------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} ModelDef
Cria��o do modelo de dados MVC 
@type function
@version 12.1.27
@author ADM_TLA8 (Leandro Cesar)
@since 11/03/2022
/*/
Static Function ModelDef()
    Local oModel := Nil
    Local oStSZO := FWFormStruct(1, "SZO")
     
    oModel := MPFormModel():New("zMVCSZOM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMSZO",/*cOwner*/,oStSZO)
    oModel:SetPrimaryKey({'ZM_FILIAL','ZM_CODIGO'})
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)     
    oModel:GetModel("FORMSZO"):SetDescription("Formul�rio do Cadastro "+cTitulo)

Return oModel
 
// ---------------------------------------------------------------------------------------------------------------------------------------------------
 
Static Function ViewDef()
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("zMVCSZO")
    Local oStSZO := FWFormStruct(2, "SZO")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oView := Nil
 
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_SZO", oStSZO, "FORMSZO")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_SZO', 'Dados do Grupo de Produtos' )  
     
    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
     
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_SZO","TELA")
Return oView
 
// ---------------------------------------------------------------------------------------------------------------------------------------------------
