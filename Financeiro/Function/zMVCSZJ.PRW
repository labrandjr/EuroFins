//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "TbiConn.ch"

//Posições do Array
Static nPosBanco  := 1 //Coluna A no Excel
Static nPosNome  := 2 //Coluna B no Excel
//Variáveis Estáticas
Static cTitulo := "Cadastro Banco"

/*/{Protheus.doc} zMVCSZJ
Função para cadastro de bancos Bacen
@type function
@version 12.1.33
@author ADM_TLA8 (Leandro Cesar)
@since 07/08/2023
@return nil, sem retorno
/*/
User Function zMVCSZJ()
	Local aArea   := GetArea()
	Local oBrowse

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SZJ")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Criação do menu MVC
@type function
@version 12.1.33
@author adm_tla8
@since 07/08/2023
@return array, menu
/*/
Static Function MenuDef()
	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCSZJ' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCSZJ' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCSZJ' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCSZJ' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE '# Importar CSV' ACTION 'U_IMP_SZJ()' OPERATION MODEL_OPERATION_UPDATE ACCESS 0

Return aRot

// ---------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC
@type function
@version 12.1.33
@author ADM_TLA8 (Leandro Cesar)
@since 07/08/2023
/*/
Static Function ModelDef()
	Local oModel := Nil
	Local oStSZJ := FWFormStruct(1, "SZJ")

	oModel := MPFormModel():New("zMVCSZJM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMSZJ",/*cOwner*/,oStSZJ)
	oModel:SetPrimaryKey({'ZM_FILIAL','ZM_BANCO'})
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
	oModel:GetModel("FORMSZJ"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("zMVCSZJ")
	Local oStSZJ := FWFormStruct(2, "SZJ")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_SZJ", oStSZJ, "FORMSZJ")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_SZJ', 'Dados do Cadastro Banco' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZJ","TELA")
Return oView

// ---------------------------------------------------------------------------------------------------------------------------------------------------

USER FUNCTION IMP_SZJ()

	Local aArea     := GetArea()
	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| fImporta() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function fImporta()
	Local aArea      := GetArea()
	Local cArqLog    := "zImpCSV_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
	Local nTotLinhas := 0
	Local cLinAtu    := ""
	Local nLinhaAtu  := 0
	Local aLinha     := {}
	Local oArquivo
	Local aLinhas
	Private cDirLog    := GetTempPath() + "x_importacao\"
	Private cLog       := ""

	//Se a pasta de log não existir, cria ela
	If ! ExistDir(cDirLog)
		MakeDir(cDirLog)
	EndIf

	//Definindo o arquivo a ser lido
	oArquivo := FWFileReader():New(cArqOri)

	//Se o arquivo pode ser aberto
	If (oArquivo:Open())

		//Se não for fim do arquivo
		If ! (oArquivo:EoF())

			//Definindo o tamanho da régua
			aLinhas := oArquivo:GetAllLines()
			nTotLinhas := Len(aLinhas)
			ProcRegua(nTotLinhas)

			//Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqOri)
			oArquivo:Open()

			While (oArquivo:HasLine())

				nLinhaAtu++
				IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

				cLinAtu := oArquivo:GetLine()
				aLinha  := separa(cLinAtu, ";")

				If ! "nome" $ Lower(cLinAtu)

					cBanco := aLinha[nPosBanco]
					cNome := aLinha[nPosNome]

					DbSelectArea('SZJ')
					SZJ->(DbSetOrder(1))

					lSeek := SZJ->(DbSeek(FWxFilial('SZJ') + cBanco ))

					//Realiza a alteração do fornecedor
					RecLock('SZJ', !lSeek)
					SZJ->ZJ_FILIAL  := FwXFilial("SZJ")
					SZJ->ZJ_BANCO   := cBanco
					SZJ->ZJ_NOME    := cNome
					SZJ->(MsUnlock())



				Else
					cLog += "- Lin" + cValToChar(nLinhaAtu) + ", linha não processada - cabeçalho;" + CRLF
				EndIf

			EndDo

			//Se tiver log, mostra ele
			If ! Empty(cLog)
				cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
				MemoWrite(cDirLog + cArqLog, cLog)
				ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
			EndIf

		Else
			MsgStop("Arquivo não tem conteúdo!", "Atenção")
		EndIf

		//Fecha o arquivo
		oArquivo:Close()
	Else
		MsgStop("Arquivo não pode ser aberto!", "Atenção")
	EndIf

	RestArea(aArea)
Return
