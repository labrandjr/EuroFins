#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TopConn.ch'


Static cTitulo := "::.. Tolerancia Recebimento x Especie Documento ..::"


User Function zMVCSZG()
	Local aArea   := GetArea()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZG")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
	RestArea(aArea)
Return Nil

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCSZG' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCSZG' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCSZG' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCSZG' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Regra Produto'    ACTION 'U_PRDFRF()' OPERATION MODEL_OPERATION_UPDATE ACCESS 0

Return aRot

// ---------------------------------------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel := Nil
	Local oStSZG := FWFormStruct(1, "SZG")

	oModel := MPFormModel():New("zMVCSZGM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMSZG",/*cOwner*/,oStSZG)
	oModel:SetPrimaryKey({'ZG_FILIAL','ZG_ESPECIE'})
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
	oModel:GetModel("FORMSZG"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

// ---------------------------------------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("zMVCSZG")
	Local oStSZG := FWFormStruct(2, "SZG")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_SZG", oStSZG, "FORMSZG")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_SZG', 'Dados do Grupo de Produtos' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZG","TELA")
Return oView

// ---------------------------------------------------------------------------------------------------------------------------------------------------

User Function RetTRec(cp_Espec)
	local aRet := {} as array

	dbSelectArea('SZG')
	dbSetOrder(1)
	If dbSeek(FWxFilial("SZG") + cp_Espec)
		aAdd(aRet, SZG->ZG_ESPECIE)
		aAdd(aRet, SZG->ZG_TIPO)
		aAdd(aRet, SZG->ZG_DIAS)
	EndIf

return(aRet)

// ---------------------------------------------------------------------------------------------------------------------------------------------------


User function TextInput(cp_Texto)
	Local oError     as Block
	Local cRetorno   as Character
	default cp_Texto := ""
	default lp_Obrig := .F.

	Do While Empty(cRetorno)
		cRetorno := ""
		oError := ErrorBlock({|e|ChecErro(e)})

		Begin Sequence
			cRetorno := FWInputBox(cp_Texto, "")
		End Sequence
		ErrorBlock(oError)
	EndDo

Return(cRetorno)


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------



User function PRDFRF()
	local cVldAlt as character // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	local cVldExc as character // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	local cAlias  as character
	local cTitulo  as character

	cTitulo := "Produto Excessao Receb. Fiscal"
	// Local oError     as Block
	// Local cRetorno   as Character
	// default cp_Texto := ""
	// default lp_Obrig := .F.

	// cRetorno := GetMv("CL_PRDFRF",.F.,"")
	// oError := ErrorBlock({|e|ChecErro(e)})

	// Begin Sequence
	// 	cRetorno := FWInputBox("Separar Produto por (#)",cRetorno)
	// End Sequence
	// ErrorBlock(oError)
	// If !Empty(cRetorno)
	// 	PutMv("CL_PRDFRF",cRetorno)
	// EndIf

	cAlias  := "SZK"

	dbSelectArea(cAlias)
	dbSetOrder(1)

	AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)


Return()
