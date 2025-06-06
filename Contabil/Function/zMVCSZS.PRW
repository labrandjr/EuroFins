//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Vari�veis Est�ticas
Static cTitulo := "Cadastro TCC"

/*/{Protheus.doc} zMVCSZS
description
@type function
@version 12.1.33
@author Leandro Cesar
@since 4/10/2023
/*/
User Function zMVCSZS()
	Local aArea   := GetArea()
	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("SZS")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

// ---------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} MenuDef
Cria��o do menu MVC
@type function
@version 12.1.33
@author Leandro Cesar
@since 4/10/2023
@return array, array do menu
/*/
Static Function MenuDef()
    Local aRot := {}

    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCSZS' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    // ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCSZS' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCSZS' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCSZS' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

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
    Local oStSZS := FWFormStruct(1, "SZS")

    oModel := MPFormModel():New("zMVCSZSM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
    oModel:AddFields("FORMSZS",/*cOwner*/,oStSZS)
    oModel:SetPrimaryKey({'ZQ_FILIAL','ZQ_CODIGO'})
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
    oModel:GetModel("FORMSZS"):SetDescription("Formul�rio do Cadastro "+cTitulo)

Return oModel

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ViewDef()
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("zMVCSZS")
    Local oStSZS := FWFormStruct(2, "SZS")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oView := Nil

    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_SZS", oStSZS, "FORMSZS")

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)

    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_SZS', 'Dados do Grupo de Produtos' )

    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})

    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_SZS","TELA")
Return oView

// ---------------------------------------------------------------------------------------------------------------------------------------------------
