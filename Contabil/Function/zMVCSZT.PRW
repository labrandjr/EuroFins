//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Cadastro SUB-BU"

/*/{Protheus.doc} zMVCSZT
description
@type function
@version 12.1.33
@author Leandro Cesar
@since 4/10/2023
/*/
User Function zMVCSZT()
	Local aArea   := GetArea()
	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("SZT")
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
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCSZT' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	// ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCSZT' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCSZT' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCSZT' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

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
	Local oStSZT := FWFormStruct(1, "SZT")

	oModel := MPFormModel():New("zMVCSZTM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMSZT",/*cOwner*/,oStSZT)
	oModel:SetPrimaryKey({'ZQ_FILIAL','ZQ_CODIGO'})
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
	oModel:GetModel("FORMSZT"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("zMVCSZT")
	Local oStSZT := FWFormStruct(2, "SZT")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_SZT", oStSZT, "FORMSZT")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_SZT', 'Dados do Grupo de Produtos' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZT","TELA")
Return oView

// ---------------------------------------------------------------------------------------------------------------------------------------------------

user function IMPZRST()

	Local aParambox	:= {}
	local nTipo := 0
	local cArquivo := space(200)

	aAdd( aParambox ,{6,"Arquivo",cArquivo,"",,"", 90 ,.T.,"Arquivos .CSV |*.CSV","C:\",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})
	aAdd(aParamBox, {2, "Tipo Importação"    , nTipo    , {"1=SUB BU","2=CCG", "3=TCC"}, 150, ".T.", .T.})


	If ParamBox(aParamBox,"Importação Arquivo CSB (SUB-BU, GCC, TCC)",,,,,,,,ProcName(),.T.,.T.)
		Processa({||ImpReg(MV_PAR01, cValToChar(MV_PAR02)) },"Importando registros..." )
	Endif
Return

// ---------------------------------------------------------------------------------------------------------------------------------------------------

static function ImpReg(cp_File,  cp_Tipo)

	local nLin := 0
	local oFile := null

	If !File(cp_File)
		Return(.F.)
	EndIf

	If right(upper(alltrim(cp_File)),3) != 'CSV'
		FwAlertError("Extencao do arquivo invalido. Favor informar um arquivo com extencao CSV.","Validacao Arquivo")
		return(.F.)
	EndIf


	oFile := FWFileReader():New(cp_File)
	If (oFile:Open())
		If ! (oFile:EoF())
			While (oFile:HasLine())
				nLin += 1

				cLinha := oFile:GetLine()
				cLinha := strTran(cLinha,"'","")
				aLinha := StrTokArr2( cLinha, ";", .T. )

				If nLin == 1
					if len(aLinha) < 3
						FwAlertError("Estrutura do arquivo invalido.","Erro arquivo")
						lContinua := .F.
						Exit
					EndIf
				Else
					If cp_Tipo == '1'

						dbSelectArea("SZT")
						dbSetOrder(1)
						lSeek := dbSeek(FWxFilial("SZT") + aLinha[1])

						reclock("SZT", !lSeek)
						SZT->ZT_FILIAL  := FWxFilial("SZT")
						SZT->ZT_CODIGO  := aLinha[1]
						SZT->ZT_DESCRIC := aLinha[2]
						SZT->ZT_MSBLQL  := aLinha[3]
						SZT->ZT_ID      := ""
						SZT->(MsUnlock())

					ElseIf cp_Tipo == '2'

					ElseIf cp_Tipo == '3'

					Else

					EndIf


				EndIf
			EndDo
		EndIf
		oFile:Close()
	ENdIf


return()

