//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Cadastro Grupo de Empresa"

/*/{Protheus.doc} zMVCSZM
Função para cadastro do Grupo de Empresas Contabil
@type function
@version 12.1.27
@author ADM_TLA8 (Leandro Cesar)
@since 11/03/2022
@return nil, sem retorno
/*/
User Function zMVCSZM()
	Local aArea   := GetArea()
	Local oBrowse

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SZM")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Legendas
	// oBrowse:AddLegend( "SBM->BM_PROORI == '1'", "GREEN",    "Original" )

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCSZM' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    // ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCSZM' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCSZM' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCSZM' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
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
    Local oStSZM := FWFormStruct(1, "SZM")
     
    oModel := MPFormModel():New("zMVCSZMM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMSZM",/*cOwner*/,oStSZM)
    oModel:SetPrimaryKey({'ZM_FILIAL','ZM_CODIGO'})
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)     
    oModel:GetModel("FORMSZM"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel
 
// ---------------------------------------------------------------------------------------------------------------------------------------------------
 
Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("zMVCSZM")
    Local oStSZM := FWFormStruct(2, "SZM")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_SZM", oStSZM, "FORMSZM")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SZM', 'Dados do Grupo de Produtos' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SZM","TELA")
Return oView
 
// ---------------------------------------------------------------------------------------------------------------------------------------------------
