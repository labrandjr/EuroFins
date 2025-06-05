//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'Fileio.ch'

//Propriedades do arquivo
#Define CAMINHO_ARQUIVO_PROTHEUS		"\temp"		// GETMV("GK_DIRFILE")
//#Define CAMINHO_ARQUIVO_WINDOWS			"C:\TOTVS 12\Microsiga\protheus_data\temp"
#Define NOME_ARQUIVO					"01cobranca.txt"

//Variáveis Estáticas
Static cTitulo							:= "Cobrancas"

/*/{Protheus.doc} ZTMPCOB
Modificacao de arquivo texto com tabela MVC temporaria
@author Andre T. Harada
@since 30/06/2020
@version 1.0
	@return Nil, Função não tem retorno
	@example
	u_ZTMPCOB()
/*/

User Function TST_FILE()
	SalvaArquivo(CAMINHO_ARQUIVO_PROTHEUS + "\" + NOME_ARQUIVO)
Return

User Function ZTMPCOB()
	Local aArea       := GetArea()
	Local oBrowse
	Local aBrowse     := {}
	Local aSeek       := {}
	Local aIndex      := {}
	Private cAliasTmp := "COBTMP"
	
	//Definindo as colunas que serão usadas no browse
	aAdd(aBrowse, {"Nome da empresa", 		"TMP_EMPR", "C", 50, 	0, "@"} )
	aAdd(aBrowse, {"Imagem do logo", 		"TMP_LOGO", "C", 256, 	0, "@"} )
	aAdd(aBrowse, {"Texto a vencer", 		"TMP_VEN0", "M", 0, 	0, "@"} )
	aAdd(aBrowse, {"Texto vencidos 01", 	"TMP_VEN1", "M", 0, 	0, "@"} )
	aAdd(aBrowse, {"Texto vencidos 02", 	"TMP_VEN2", "M", 0, 	0, "@"} )
	aAdd(aBrowse, {"Texto vencidos 03", 	"TMP_VEN3", "M", 0, 	0, "@"} )
	aAdd(aBrowse, {"Telefone da empresa", 	"TMP_TELE", "C", 15, 	0, "@"} )
	aAdd(aBrowse, {"CNPJ da empresa", 		"TMP_CNPJ", "C", 18, 	0, "@ 99.999.999/9999-99"} )
	aAdd(aBrowse, {"Endereco da empresa", 	"TMP_ENDE", "C", 50, 	0, "@"} )
	aAdd(aBrowse, {"Cidade da empresa", 	"TMP_CIDA", "C", 50, 	0, "@"} )
	aAdd(aBrowse, {"Site da empresa", 		"TMP_SITE", "C", 50, 	0, "@"} )
	
	aAdd(aIndex, "TMP_EMPR" )
	
	//Criando o browse da temporária
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasTmp)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFields(aBrowse)
	oBrowse:DisableDetails()
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZTMPCOB' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ZTMPCOB' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ZTMPCOB' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ZTMPCOB' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil
	
	//Criação da estrutura de dados utilizada na interface
	Local oStTMP := FWFormModelStruct():New()
	
	oStTMP:AddTable(cAliasTmp, {;
		'TMP_EMPR', 'TMP_LOGO', 'TMP_VEN0', 'TMP_VEN1', 'TMP_VEN2', 'TMP_VEN3',;
		'TMP_TELE', 'TMP_CNPJ', 'TMP_ENDE', 'TMP_CIDA', 'TMP_SITE';
	}, "Temporaria")

	//Adiciona os campos da estrutura
	AddFieldM(oStTmp, "Nome da empresa", 	"Titulo da empresa", 	"TMP_EMPR", "C", 50)
	AddFieldM(oStTmp, "Imagem do logo", 	"Imagem do logo", 		"TMP_LOGO", "C", 256)
	AddFieldM(oStTmp, "Texto a vencer", 	"Texto a vencer", 		"TMP_VEN0", "M", 0)
	AddFieldM(oStTmp, "Texto vencidos 01", 	"Texto vencidos 01", 	"TMP_VEN1", "M", 0)
	AddFieldM(oStTmp, "Texto vencidos 02", 	"Texto vencidos 02", 	"TMP_VEN2", "M", 0)
	AddFieldM(oStTmp, "Texto vencidos 03", 	"Texto vencidos 03", 	"TMP_VEN3", "M", 0)
	AddFieldM(oStTmp, "Telefone da empresa","Telefone da empresa", 	"TMP_TELE", "C", 15)
	AddFieldM(oStTmp, "CNPJ da empresa", 	"CNPJ da empresa", 		"TMP_CNPJ", "C", 18)
	AddFieldM(oStTmp, "Endereco da empresa","Endereco da empresa", 	"TMP_ENDE", "C", 50)
	AddFieldM(oStTmp, "Cidade da empresa", 	"Cidade da empresa", 	"TMP_CIDA", "C", 50)
	AddFieldM(oStTmp, "Site da empresa", 	"Site da empresa", 		"TMP_SITE", "C", 50)
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("ZTMPCOBM", /*bPre*/, {|oModel|bPos(oModel)},/*{||bCommit(oModel)}*/,/*bCancel*/) 
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMTMP",/*cOwner*/,oStTMP, /*bPre*/, /*bPos*/, {|oFieldModel, lCopy| bFieldLoad(oFieldModel, lCopy)})
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'TMP_CNPJ'})
	
	//Adicionando descrição ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMTMP"):SetDescription("Formulário do Cadastro "+cTitulo)
	
	//Setando a operação do formulário
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	
	//Ativando o modelo
	oModel:Activate(.T.)
Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	Local aStruTMP	:= (cAliasTmp)->(DbStruct())
	Local oModel := FWLoadModel("ZTMPCOB")
	Local oStTMP := FWFormViewStruct():New()
	Local oView := Nil

	//Adicionando campos da estrutura
	AddFieldV(oStTmp, "01", "TMP_EMPR", "Nome da empresa", 		"Nome da empresa", 		"C", "@")
	AddFieldV(oStTmp, "02", "TMP_LOGO", "Imagem do logo", 		"Imagem do logo", 		"C", "@")
	AddFieldV(oStTmp, "03", "TMP_VEN0", "Texto a vencer", 		"Texto a vencer", 		"C", "@")
	AddFieldV(oStTmp, "04", "TMP_VEN1", "Texto vencidos 01", 	"Texto vencidos 01", 	"M", "@")
	AddFieldV(oStTmp, "05", "TMP_VEN2", "Texto vencidos 02", 	"Texto vencidos 02", 	"M", "@")
	AddFieldV(oStTmp, "06", "TMP_VEN3", "Texto vencidos 03", 	"Texto vencidos 03", 	"M", "@")
	AddFieldV(oStTmp, "07", "TMP_TELE", "Telefone da empresa", 	"Telefone da empresa", 	"C", "@")
	AddFieldV(oStTmp, "08", "TMP_CNPJ", "CNPJ da empresa", 		"CNPJ da empresa", 		"C", "@99.999.999/9999-99")
	AddFieldV(oStTmp, "09", "TMP_ENDE", "Endereco da empresa", 	"Endereco da empresa", 	"C", "@")
	AddFieldV(oStTmp, "10", "TMP_CIDA", "Cidade da empresa", 	"Cidade da empresa", 	"C", "@")
	AddFieldV(oStTmp, "11", "TMP_SITE", "Site da empresa", 		"Site da empresa", 		"C", "@")

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_TMP", oStTMP, "FORMTMP")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	oView:EnableTitleView('VIEW_TMP', 'Dados - '+cTitulo )  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_TMP","TELA")
Return oView

Static Function bFieldLoad(oFieldModel, lCopy)
	Local aLoad		:= {}
	
	aadd(aLoad, ASize(GetLinhasArquivo(CAMINHO_ARQUIVO_PROTHEUS, NOME_ARQUIVO), 11))	//Dados
	aadd(aLoad, -1)	//Recno
	
Return aLoad

//----------------------------------------------------------------------------------------------------------------------------------
Static Function bPos(oModel)
	Local i
	Local nOperation		:= oModel:GetOperation()
	Local lRet				:= .T.
	Local aCampos			:= {;
		'TMP_EMPR', 'TMP_LOGO', 'TMP_VEN0', 'TMP_VEN1', 'TMP_VEN2', 'TMP_VEN3',;
		'TMP_TELE', 'TMP_CNPJ', 'TMP_ENDE', 'TMP_CIDA', 'TMP_SITE';
	}
	Local aConteudo			:= {}

	If nOperation == MODEL_OPERATION_INSERT
		For i := 1 to Len(aCampos)
			aAdd(aConteudo, AllTrim(cValToChar(oModel:GetValue("FORMTMP", aCampos[i]))))
		Next i
		SalvaArquivo(CAMINHO_ARQUIVO_PROTHEUS, NOME_ARQUIVO, aConteudo)
		//AbreArquivo(CAMINHO_ARQUIVO_WINDOWS, NOME_ARQUIVO)
	EndIf
	
Return lRet

//----------------------------------------------------------------------------------------------------------------------------------
Static Function AddFieldM(oStTmp, cTitulo, cToolTip, cCampo, cTipo, nTamanho)
	//Adiciona os campos da estrutura
	oStTmp:AddField(;
		cTitulo,;                                                                                  	// [01]  C   Titulo do campo
		cToolTip,;                                                                                  // [02]  C   ToolTip do campo
		cCampo,;                                                                                 	// [03]  C   Id do Field
		cTipo,;                                                                                     // [04]  C   Tipo do campo
		nTamanho,;                                                                                  // [05]  N   Tamanho do campo
		0,;                                                                                         // [06]  N   Decimal do campo
		Nil,;                                                                                       // [07]  B   Code-block de validação do campo
		Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
		{},;                                                                                        // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
		Nil/*FwBuildFeature( STRUCT_FEATURE_INIPAD, '"' + cInit + '"')*/,;								// [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                                        // [14]  L   Indica se o campo é virtual
Return

//----------------------------------------------------------------------------------------------------------------------------------
Static Function AddFieldV(oStTmp, cOrdem, cCampo, cTitulo, cDescricao, cTipo, cPicture)
	//Adicionando campos da estrutura
	oStTmp:AddField(;
		cCampo,;                 	// [01]  C   Nome do Campo
		cOrdem,;                    // [02]  C   Ordem
		cTitulo,;                  	// [03]  C   Titulo do campo
		cDescricao,;                // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		cTipo,;                     // [06]  C   Tipo do campo
		cPicture,;                  // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;     					// [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo
Return

//----------------------------------------------------------------------------------------------------------------------------------
// @see http://www.helpfacil.com.br/forum/display_topic_threads.asp?ForumID=1&TopicID=2130&PagePosition=0
Static Function GetLinhasArquivo(cCaminho, cArquivo)
	Private aLinhas		:= {}
	Private lBuffer		:= 1024
	Private lFilePos 	:= 1024
	Private lPos 		:= 0
	Private cLine 		:= ""
	Private hFile, lFilePos, cBuffer, lRead, lPos
	
	// Abrindo o arquivo de texto
	hFile 		:= FOPEN(cCaminho + "\" + cArquivo, 32)
	
	// Verificando a existência do arquivo
	If (hFile == -1)
		Return aLinhas
	Else
		lFilePos 	:= FSEEK(hFile, 0, 0)					// POSICIONA PONTEIRO DO ARQUIVO NO PRIMEIRO CARACTER
		cBuffer 	:= SPACE(lBuffer)						// ALOCA BUFFER
		lRead 		:= FREAD(hFile, cBuffer, lBuffer)		// LE OS PRIMEIROS 1024 CARACTERES DO ARQUIVO
		lPos 		:= AT(CRLF, cBuffer)					// PROCURA O PRIMEIRO FINAL DE LINHA
	EndIf
	
	WHILE !(lRead == 0)
		WHILE (lPos == 0)								// SE CARACTER DE FINAL DE LINHA NAO FOR ENCONTRADO
			lBuffer += 1024								// AUMENTA TAMANHO DO BUFFER
        	cBuffer := SPACE(lBuffer)					// REALOCA BUFFER
        	lFilePos := FSEEK(hFile, lFilePos, 0)		// REPOSICIONA PONTEIRO DO ARQUIVO
        	lRead := FREAD(hFile, cBuffer, lBuffer)		// LE OS CARACTERES DO ARQUIVO
        	lPos := AT(CRLF, cBuffer)					// PROCURA O PRIMEIRO FINAL DE LINHA
        END
	    
        // LEITURA DOS CAMPOS E GRAVACAO DOS DADOS DA TABELA AQUI
	    cLine := SUBSTR(cBuffer, 0, lPos)

	    aAdd(aLinhas, AllTrim(StrTokArr(cLine, CRLF)[1]))
	    
	    // LEITURA DA PROXIMA LINHA DO ARQUIVO
	    cBuffer := SPACE(lBuffer)                   // ALOCA BUFFER
	    lFilePos += lPos + 1                        // POSICIONA ARQUIVO APÓS O ULTIMO EOL ENCONTRADO
	    lFilePos := FSEEK(hFile, lFilePos, 0)       // POSICIONA PONTEIRO DO ARQUIVO
	    lRead := FREAD(hFile, cBuffer, lBuffer)     // LE OS CARACTERES DO ARQUIVO
	    lPos := AT(CRLF, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
	END
	
	If !FCLOSE(hFile)
		ConOut( "Erro ao fechar arquivo, erro numero: ", FERROR() )
	EndIf
	
	/*If (Len(aLinhas) == 0)
		aLinhas := {;
		'EMPRESA',;
		'IMAGEM',;
		'VENCIMENTO',;
		'VENCIMENTO 01',;
		'VENCIMENTO 02',;
		'VENCIMENTO 03',;
		'1140334249',;
		'11111111111111',;
		'ENDERECO',;
		'CIDADE',;
		'URL SITE',;
	}
	EndIf*/

	//ConOut("GetLinhasArquivo", aLinhas)
	
Return aLinhas

/*---------------------------------------------------------------------*
 | Func:  SalvaArquivo                                                 |
 | Desc:  Salva arquivo no disco                                       |
 *---------------------------------------------------------------------*/
 // @see https://siga0984.wordpress.com/2018/12/16/manipulacao-de-arquivos-em-advpl-parte-02
 //------------------------------------------------------------------------------------------
Static Function SalvaArquivo(cCaminho, cArquivo, aConteudo)
	Local nHnd, i
	Local cFile := cCaminho + "\" + cArquivo
	Local cLine, nTamFile
	Local cNewLine, nRead, nWrote
	
	// Cria o arquivo
	// Automaticamente o arquivo é aberto em modo exclusivo para gravação
	nHnd := fCreate(cFile)
	
	If nHnd == -1
	  ConOut("Falha ao criar arquivo ["+cFile+"]","FERROR "+cValToChar(fError()))
	  Return
	Endif
	
	// Grava as linhas no conteúdo no arquivo
	For i := 1 to Len(aConteudo)
		fWrite(nHnd, cValToChar(aConteudo[i]) + CRLF)
	Next i
	
	// Fecha o arquivo 
	fClose(nHnd)
Return

//----------------------------------------------------------------------------------------------------------------------------------
/*Static Function AbreArquivo(cCaminho, cArquivo)
	Local nRet := ShellExecute("open", cArquivo, "", cCaminho, 1)
	
	//Se houver algum erro
	If nRet <= 32
		MsgStop("Não foi possível abrir o arquivo " + cCaminho + "\" + cArquivo + "!", "Atenção")
	EndIf
Return nRet*/