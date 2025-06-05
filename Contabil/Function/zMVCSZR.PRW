//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Cadastro GCC"

/*/{Protheus.doc} zMVCSZR
description
@type function
@version 12.1.33
@author Leandro Cesar
@since 4/10/2023
/*/
User Function zMVCSZR()
	Local aArea   := GetArea()
	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("SZR")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

// ---------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} MenuDef
Criação do menu MVC
@type function
@version 12.1.33
@author Leandro Cesar
@since 4/10/2023
@return array, array do menu
/*/
Static Function MenuDef()
    Local aRot := {}

    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCSZR' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    // ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCSZR' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCSZR' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCSZR' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

// ---------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC
@type function
@version 12.1.27
@author ADM_TLA8 (Leandro Cesar)
@since 11/03/2022
/*/
Static Function ModelDef()
    Local oModel := Nil
    Local oStSZR := FWFormStruct(1, "SZR")

    oModel := MPFormModel():New("zMVCSZRM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
    oModel:AddFields("FORMSZR",/*cOwner*/,oStSZR)
    oModel:SetPrimaryKey({'ZQ_FILIAL','ZQ_CODIGO'})
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
    oModel:GetModel("FORMSZR"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("zMVCSZR")
    Local oStSZR := FWFormStruct(2, "SZR")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oView := Nil

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Atribuindo formulários para interface
    oView:AddField("VIEW_SZR", oStSZR, "FORMSZR")

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)

    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SZR', 'Dados do Grupo de Produtos' )

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SZR","TELA")
Return oView

// ---------------------------------------------------------------------------------------------------------------------------------------------------
