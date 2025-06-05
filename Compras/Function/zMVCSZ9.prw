//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#include "tbiconn.ch"

//Posições do Array
Static nPosCodigo   := 1 //Coluna A no Excel
Static nPosDescri   := 2 //Coluna B no Excel
Static nPosCta      := 3 //Coluna C no Excel
Static nPosBloq     := 4 //Coluna D no Excel
Static nPosCamex    := 5 //Coluna E no Excel
Static nPosEnvFor   := 6 //Coluna F no Excel
Static nPosPUIDCom  := 7 //Coluna G no Excel
Static nPosFerias   := 8 //Coluna H no Excel
Static nPosDtFerias := 9 //Coluna I no Excel
Static nPosPUIDSub  := 10 //Coluna J no Excel



//Variáveis Estáticas
Static cTitulo   := "Solicitacao Cadastro de Produto"

Static nPosTipo  := 1 //Coluna A no Excel
Static nPosDesc  := 2 //Coluna B no Excel
Static nPosUM    := 3 //Coluna C no Excel
Static nPosOri   := 4 //Coluna D no Excel
Static nPosConta := 5 //Coluna E no Excel
Static nPosNCM   := 6 //Coluna F no Excel
Static nPosGrp   := 7 //Coluna G no Excel
Static nPosPN    := 8 //Coluna H no Excel
Static nPosJust  := 9 //Coluna H no Excel
Static cTpProd   := GetMv("ZZ_TIPOPRD")
/*/{Protheus.doc} zMVCSZ9
rotina de solicitacao cadastro de produto
@type function
@version 12.1.27
@author Leandro Cesar
@since 02/09/2022
/*/
User Function zMVCSZ9()
	Local aArea   := GetArea()
	// Local oBrowse
	private oMark
	private cMark := GetMark()

	//corrige o status das requisições para caso encontre requisição com produto gerado.
	cQuery := " UPDATE SZ9 SET Z9_STATUS = '4', Z9_COD = B1_COD
	cQuery += " FROM " + RetSqlName("SZ9") + " SZ9
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_  = ''
	cQuery += " AND B1_XIDREQ = Z9_IDREQ
	cQuery += " AND upper(ltrim(rtrim(B1_DESC))) = upper(ltrim(rtrim(Z9_DESCR)))
	cQuery += " WHERE SZ9.D_E_L_E_T_ = ''
	cQuery += " AND Z9_STATUS != '4'
	TcSqlExec(cQuery)


	oMark := FWMarkBrowse():New()
	oMark:SetAlias( "SZ9" )
	oMark:SetDescription( cTitulo )
	oMark:SetFieldMark( "Z9_OK" )

	oMark:SetAllMark({|| AllMark() })
	// oMark:DisableReport()
	oMark:SetMark( cMark, "SZ9", "Z9_OK" )

	If !((alltrim(cUserName) $ GetMv("CL_PRDFIS")) .or. (alltrim(cUserName) $ GetMv("CL_PRDCMP")))
		oMark:SetFilterDefault("upper(alltrim(SZ9->Z9_PUIDR)) == '" + upper(alltrim(cUserName)) +"'" )
	EndIf

	//Legendas
	oMark:AddLegend( "Empty(Z9_STATUS)", "DISABLE"    ,    "Pendente Liberação Solicitante " )
	oMark:AddLegend( "Z9_STATUS == '1'", "BR_AMARELO" ,    "Pendente Aprovação Contábil" )
	oMark:AddLegend( "Z9_STATUS == '2'", "BR_AZUL"    ,    "Pendente Aprovação Compras" )
	oMark:AddLegend( "Z9_STATUS == '3'", "BR_MARROM"  ,    "Rejeicao Contabil" )
	oMark:AddLegend( "Z9_STATUS == '4'", "ENABLE"     ,    "Cadastro Aprovado" )
	oMark:AddLegend( "Z9_STATUS == '5'", "BR_PRETO"   ,    "Rejeicao Compras" )
	// oMark:AddLegend( "Empty(Z9_STATUS)", "DISABLE"    ,    "Pendente Liberação" )
	// oMark:AddLegend( "Z9_STATUS == '1'", "BR_AMARELO" ,    "Cadastro Liberado" )
	// oMark:AddLegend( "Z9_STATUS == '2'", "BR_AZUL"    ,    "Liberacao Contabil" )
	// oMark:AddLegend( "Z9_STATUS == '3'", "BR_MARROM"  ,    "Rejeicao Contabil" )
	// oMark:AddLegend( "Z9_STATUS == '4'", "ENABLE"     ,    "Cadastro Aprovado (Produto Criado)" )
	// oMark:AddLegend( "Z9_STATUS == '5'", "BR_PRETO"   ,    "Rejeicao Compras" )

	oMark:AddButton( "Confirmar", {|| Self:End()} )
	oMark:Activate()


	// oBrowse := FWMBrowse():New()
	// oBrowse:SetAlias("SZ9")
	// oBrowse:SetDescription(cTitulo)


	// If !((alltrim(cUserName) $ GetMv("CL_PRDFIS")) .or. (alltrim(cUserName) $ GetMv("CL_PRDCMP")))
	// 	oBrowse:SetFilterDefault("upper(alltrim(SZ9->Z9_PUIDR)) == '" + upper(alltrim(cUserName)) +"'" )
	// EndIf

	// //Legendas
	// oBrowse:AddLegend( "Empty(Z9_STATUS)", "DISABLE"    ,    "Pendente Liberação" )
	// oBrowse:AddLegend( "Z9_STATUS == '1'", "BR_AMARELO" ,    "Cadastro Liberado" )
	// oBrowse:AddLegend( "Z9_STATUS == '2'", "BR_AZUL"    ,    "Liberacao Contabil" )
	// oBrowse:AddLegend( "Z9_STATUS == '3'", "BR_MARROM"  ,    "Rejeicao Contabil" )
	// oBrowse:AddLegend( "Z9_STATUS == '4'", "ENABLE"     ,    "Cadastro Aprovado (Produto Criado)" )
	// oBrowse:AddLegend( "Z9_STATUS == '5'", "BR_PRETO"   ,    "Rejeicao Compras" )

	// oBrowse:Activate()

	RestArea(aArea)
Return Nil

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Criação do menu MVC
@type function
@version 12.1.27
@author Leandro Cesar
@since 02/09/2022
@return array, vetor com os menus
/*/
Static Function MenuDef()
	Local aRot    := {}
	Local aSBMFis := {}
	Local aSBMCmp := {}
	Local aSBMLot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar'          ACTION 'VIEWDEF.zMVCSZ9'    OPERATION MODEL_OPERATION_VIEW ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'             ACTION 'VIEWDEF.zMVCSZ9'    OPERATION 3 ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'             ACTION 'VIEWDEF.zMVCSZ9'    OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'             ACTION 'VIEWDEF.zMVCSZ9'    OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Liberar Cadastro'    ACTION 'u_LibCProd(1)'      OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5

	ADD OPTION aRot TITLE 'Processamento Lote' ACTION aSBMLot OPERATION 9 ACCESS 0
	ADD OPTION aSBMLot TITLE 'Liberar Cadastro - Lote' ACTION 'u_LibCadLote(1)' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5
	ADD OPTION aSBMLot TITLE 'Importar TXT' ACTION 'u_ImpSZ9TXT()' OPERATION 3 ACCESS 0 //OPERATION 5

	//Adiciona o arrya do submenu a opção do menu
	If alltrim(cUserName) $ GetMv("CL_PRDFIS")
		ADD OPTION aRot TITLE 'Aprovação Contabil' ACTION aSBMFis OPERATION 9 ACCESS 0
		ADD OPTION aSBMFis TITLE 'Aprovar' ACTION 'u_LibCProd(2)' OPERATION 7 ACCESS 0
		ADD OPTION aSBMFis TITLE 'Aprovar - Lote' ACTION 'u_LibCadLote(2)' OPERATION 7 ACCESS 0
		ADD OPTION aSBMFis TITLE 'Rejeitar' ACTION 'u_RejCProd(1)' OPERATION 8 ACCESS 0
	EndIf

	If alltrim(cUserName) $ GetMv("CL_PRDCMP")
		ADD OPTION aRot TITLE 'Aprovação Compra' ACTION aSBMCmp OPERATION 9 ACCESS 0
		ADD OPTION aSBMCmp TITLE 'Rel. Produto'             ACTION 'U_NtCodNew(1)'  OPERATION 9 ACCESS 0
		ADD OPTION aSBMCmp TITLE 'Rel. Produto (Tela)'      ACTION 'U_NtCodNew(2)'  OPERATION 9 ACCESS 0
		ADD OPTION aSBMCmp TITLE 'Aprovar - Gerar Produto'  ACTION 'u_GerProd(1)'  OPERATION 3 ACCESS 0
		ADD OPTION aSBMCmp TITLE 'Aprovar - Lote'           ACTION 'u_GerProd(2)'  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5
		ADD OPTION aSBMCmp TITLE 'Rejeitar'                 ACTION 'u_RejCProd(2)' OPERATION 8 ACCESS 0
	EndIf

Return aRot

// ---------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC
@type function
@version 12.1.27
@author Leandro Cesar
@since 02/09/2022
@return object, modelo de dados
/*/
Static Function ModelDef()
	Local oModel := Nil
	Local oStSZ9 := FWFormStruct(1, "SZ9")
	// Local bVldPre := {|| u_SZ9Pre()}

	oModel := MPFormModel():New("zMVCSZ9M", , {|oModel| u_SZ9Pos(oModel)},/*bCommit*/,/*bCancel*/)

	oModel:AddFields("FORMSZ9",/*cOwner*/,oStSZ9)
	oModel:SetPrimaryKey({'Z9_FILIAL','Z9_CODIGO'})
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
	oModel:GetModel("FORMSZ9"):SetDescription("Formulário do Cadastro "+cTitulo)

	oModel:SetVldActivate({|oModel| u_VldActivate(oModel)})

Return oModel
// ---------------------------------------------------------------------------------------------------------------------------------------------------
user function SZ9Pos(oModel)
	Local nOpc       := oModel:GetOperation()
	Local lRet       := .T.

	//Se for alteração
	If nOpc == 3

		If !FWFldGet('Z9_TIPO') $ cTpProd .and. Empty(FWFldGet('Z9_NCM'))
			Help( ,, 'ZMVCSZ9',,"Não foi informado NCM para solicitação de produto." , 1, 0 )
			return(.F.)
		Endif

		// If Empty(FWFldGet('Z9_SEGUM'))
		// 	Help( ,, 'ZMVCSZ9',,"Não foi informado Segunda Unidade de medida para solicitação de produto." , 1, 0 )
		// 	return(.F.)
		// Endif
	ElseIf nOpc == MODEL_OPERATION_UPDATE

		If !FWFldGet('Z9_TIPO') $ cTpProd .and. Empty(FWFldGet('Z9_NCM'))
			Help( ,, 'ZMVCSZ9',,"Não foi informado NCM para solicitação de produto." , 1, 0 )
			return(.F.)
		Endif

		// If Empty(FWFldGet('Z9_SEGUM'))
		// 	Help( ,, 'ZMVCSZ9',,"Não foi informado Segunda Unidade de medida para solicitação de produto." , 1, 0 )
		// 	return(.F.)
		// Endif


		If FwAlertYesNo("Deseja alterar o status da requisição para o status inicial?","Aviso")
			FwFldPut( 'Z9_CADLIB'   , ''        , , , , .T.)
			FwFldPut( 'Z9_DTLIBC'   , cTod( '' ), , , , .T.)
			// FwFldPut( 'Z9_PUIDR'    , cUserName , , , , .T.)
			FwFldPut( 'Z9_LIBFIS'   , 'N'       , , , , .T.)
			FwFldPut( 'Z9_DTLIBFI'  , cTod( '' ), , , , .T.)
			FwFldPut( 'Z9_PUIDF'    , ''        , , , , .T.)
			FwFldPut( 'Z9_LIBCOM'   , 'N'       , , , , .T.)
			FwFldPut( 'Z9_DTLIBCP'  , cTod( '' ), , , , .T.)
			FwFldPut( 'Z9_PUIDC'    , ''        , , , , .T.)
			FwFldPut( 'Z9_STATUS'   , ''        , , , , .T.)
		EndIf
	EndIf

Return lRet

// ---------------------------------------------------------------------------------------------------------------------------------------------------
user function SZ9Commit(oModel)
	Local nOpc       := oModel:GetOperation()
	Local lRet       := .T.

	//Se for alteração
	If nOpc == MODEL_OPERATION_UPDATE
		If FwAlertYesNo("Deseja alterar o status da requisição para o status inicial?","Aviso")
			reclock("SZ9",.F.)
			SZ9->Z9_CADLIB  := ''
			SZ9->Z9_DTLIBC  := cTod( '' )
			// SZ9->Z9_PUIDR   := cUserName
			SZ9->Z9_LIBFIS  := 'N'
			SZ9->Z9_DTLIBFI := cTod( '' )
			SZ9->Z9_PUIDF   := ''
			SZ9->Z9_LIBCOM  := 'N'
			SZ9->Z9_DTLIBCP := cTod( '' )
			SZ9->Z9_PUIDC   := ''
			SZ9->Z9_STATUS  := ''
			SZ9->(MsUnLock())
		EndIf
	ElseIf nOpc == MODEL_OPERATION_DELETE
		reclock("SZ9",.F.)
		SZ9->(dbDelete())
		SZ9->(MsUnLock())
	EndIf
Return lRet

// ---------------------------------------------------------------------------------------------------------------------------------------------------
user Function VldActivate(oModel)
	local nOpc := oModel:GetOperation()
	local lRet := .T.

	If nOpc == 3
		return(.T.)
	EndIf

	If nOpc != MODEL_OPERATION_VIEW

		If SZ9->Z9_STATUS == '4' .and. !Empty(SZ9->Z9_CODIGO)
			Help( ,, 'ZMVCSZ9',,"Não é possivel fazer alterar nessa solicitação pois já esta finalizada." , 1, 0 )
			return(.F.)
		EndIf

		If SZ9->Z9_LIBFIS == 'S'
			lRet := .F.
			Help( ,, 'ZMVCSZ9',,"Não é possivel fazer alterar nessa solicitação pois já esta em processo de aprovação." , 1, 0 )
		EndIf

	EndIf
Return lRet

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("zMVCSZ9")
	Local oStSZ9 := FWFormStruct(2, "SZ9")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	Local oView  := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_SZ9", oStSZ9, "FORMSZ9")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_SZ9', 'Dados do Grupo de Produtos' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZ9","TELA")
Return oView

// ---------------------------------------------------------------------------------------------------------------------------------------------------

user function VldCpoZ19()
	local lRet := .T. as logical
	local cCpo := alltrim(strTran(ReadVar(),"M->",""))

	If cCpo == "Z9_GRUPO"
		dbSelectArea("SZH")
		dbSetOrder(1)
		If dbSeek(FWxFilial("SZH") + FWFldGet('Z9_GRUPO'))
			If SZH->ZH_MSBLQL != '1'
				FwFldPut('Z9_CONTA',alltrim(SZH->ZH_CONTA))

				dbSelectArea("SX5")
				dbSetOrder(1)
				If dbSeek(FWxFilial("SX5") + "Z7" + Substr(SZH->ZH_CODIGO,1,3))
					FwFldPut('Z9_SUBGRP',Substr(SZH->ZH_CODIGO,1,3))
				EndIf



				If (alltrim(FWFldGet('Z9_TIPO')) == "AF" .AND. SZH->ZH_CAMEX != 'S') .OR. (alltrim(FWFldGet('Z9_TIPO')) != "AF" .AND. SZH->ZH_CAMEX == 'S')
					Help( ,, 'ZMVCSZ9',,"Controle Capex só deve ser utilizado para o tipo AF." , 1, 0 )
					lRet := .F.
				EndIf

			Else
				lRet := .F.
				Help(" ",1,"SCADPRD",, "Codigo GRUPO PDB bloqueado." ,1,0)
			EndIf
		else
			lRet := .F.
			Help(" ",1,"SCADPRD",, "Codigo GRUPO PDB incorreto." ,1,0)
		EndIf
	ElseIf cCpo == "Z9_UM"
		cUm := alltrim(FWFldGet('Z9_UM'))
		dbSelectArea("SAH")
		dbSetOrder(1)
		If dbSeek(FWxFilial("SAH") + cUM )

			If !Empty(SAH->AH_XUMCOUP)
				FwFldPut('Z9_SEGUM',SAH->AH_XUMCOUP)
			Else
				lRet := .F.
				Help(" ",1,"SCADPRD",, "Não existe unidade de medida COUPA vinculado com esta unidade de medida ("+cUM+")" ,1,0)
			EndIf

		else
			lRet := .F.
			Help(" ",1,"SCADPRD",, "Codigo UM incorreto." ,1,0)
		EndIf

	ElseIf cCpo == "Z9_TIPO"
		If 	!Empty(FWFldGet('Z9_GRUPO'))
			dbSelectArea("SZH")
			dbSetOrder(1)
			If dbSeek(FWxFilial("SZH") + FWFldGet('Z9_GRUPO'))
				If (alltrim(FWFldGet('Z9_TIPO')) == "AF" .and. SZH->ZH_CAMEX != 'S') .or. (alltrim(FWFldGet('Z9_TIPO')) != "AF" .and. SZH->ZH_CAMEX == 'S')
					Help( ,, 'ZMVCSZ9',,"Controle Capex só deve ser utilizado para o tipo AF." , 1, 0 )
					lRet := .F.
				EndIf
			EndIf

		EndIf
	ElseIf cCpo ==  "Z9_PARTNUM"
		cPartNum := FWFldGet('Z9_PARTNUM')
		If upper(cPartNum) != "NA"
			cTRB := GetNextAlias()
			BeginSql Alias cTRB
                Select count(*) AS Reg
                From %Table:SB1%
                Where %NotDel% and
                B1_XPARTNU = %Exp:cPartNum% and
                B1_FILIAL  = %xFilial:SB1%
			EndSql

			dbSelectArea((cTRB))
			If (cTRB)->Reg != 0
				FwAlertError("Part Number já informado em outro cadastro.","Part Number Duplicado")
				lRet := .F.
			EndIf
		EndIf
	EndIf

	GETDREFRESH()
return(lRet)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function GerProd(np_Tipo)
	local aArea := GetArea()
	local aRotBKP := {}
	Public lSolCad := .T.

	If np_Tipo == 1
		If Type("aRots") == "A"
			aRotina := AClone(aRots)
		EndIf

		If SZ9->Z9_LIBFIS == 'S' .and. SZ9->Z9_CADLIB == 'S' .and. (Empty(SZ9->Z9_CODIGO) .or. alltrim(SZ9->Z9_CODIGO) == '01') .and. SZ9->Z9_STATUS != '4' .and. SZ9->Z9_LIBCOM != 'S'			// If FwAlertYesNo("Libera Cadastro para revisão Contabil?")
			A010Inclui("SB1",0,1)
			RestArea(aArea)

			cQuery := "SELECT TOP 1 B1_COD PRODUTO FROM " + RetSqlName("SB1")
			cQuery += " WHERE D_E_L_E_T_ = '' AND B1_XIDREQ = '" + SZ9->Z9_IDREQ + "'"
			TcQuery cQuery New Alias (cTRBPRD := GetNextAlias())

			If (cTRBPRD)->(!eof())
				reclock("SZ9",.F.)
				SZ9->Z9_STATUS := '4'
				SZ9->Z9_LIBCOM := 'S'
				SZ9->Z9_DTLIBCP := dDataBase
				SZ9->Z9_PUIDC  := cUserName
				SZ9->Z9_CODIGO := (cTRBPRD)->PRODUTO
				SZ9->(MsUnlock())

				Notifica("Aprovado",__cUserID)

			EndIf

			(cTRBPRD)->(dbCloseArea())

			// EndIf
		Else
			FwAlertWarning("Ficha de requisição não esta apto a geração do cadastro de produto.","Alert")
		EndIf


		If Type("aRotBKP") == "A"
			aRotina := AClone(aRotBKP)
		EndIf
	Else

		If FwAlertYesNo("Confirma libera todos os registros selecionados para geração cadastro de produto?","Aviso")
			Processa({|| CadItem()}, "Processando...")
		EndIf

	EndIf
	restArea(aArea)

Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function LibCProd(np_Opc)
	Local cGCadLib := iif(SZ9->Z9_CADLIB=="S","SIM","NAO")
	Local cGCApv   := iif(SZ9->Z9_LIBCOM=="S","SIM","NAO")
	Local cGDesc   := SZ9->Z9_DESCR
	Local cGFisApv := iif(SZ9->Z9_LIBFIS=="S","SIM","NAO")
	Local cGGrupo  := SZ9->Z9_GRUPO
	Local cGSegUM  := SZ9->Z9_SEGUM
	Local cGSGrupo := SZ9->Z9_SUBGRP
	Local cGTipo   := SZ9->Z9_TIPO
	Local cGUM     := SZ9->Z9_UM
	local lOK      := .F.
	Local oBCanc
	Local oBConf
	Local oGCadLib
	Local oGCApv
	Local oGDesc
	Local oGFisApv
	Local oGGrupo
	Local oGroup1
	Local oGSegUM
	Local oGSGrupo
	Local oGTipo
	Local oGUM
	Local oPanel1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9

	If SZ9->Z9_LIBCOM == "S"
		FwAlertInfo("Cadastro já liberado pelo setor de compras. Não é possível submeter a aprovação.","Cadastro já aprovado.")
		return(.F.)
	EndIf

	If (np_Opc == 1 .or. np_Opc == 3) .and. SZ9->Z9_LIBFIS == "S"
		FwAlertInfo("Cadastro já liberado pelo setor Contabil.","Liberação Contabil.")
		return(.F.)
	EndIf


	If (np_Opc == 4 .or. np_Opc == 5) .and. SZ9->Z9_LIBFIS != "S"
		FwAlertInfo("Cadastro não liberado pelo setor Contabil.","Liberação Pendente Contabil.")
		return(.F.)
	EndIf


	DEFINE MSDIALOG oDlgpRD TITLE "::.. Liberação Cadastro ..::" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

	@ 003, 003 MSPANEL oPanel1 PROMPT "" SIZE 240, 077 OF oDlgpRD COLORS 0, 16777215 RAISED
	@ 000, 000 GROUP oGroup1 TO 076, 239 PROMPT " ::.. REVISÃO CADASTRO DE PRODUTO ..:: " OF oPanel1 COLOR 0, 16777215 PIXEL
	@ 010, 005 SAY oSay1 PROMPT "DESCRIÇÃO"             SIZE 044, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 017, 005 MSGET oGDesc     VAR cGDesc              SIZE 205, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 144 SAY oSay2 PROMPT "TIPO"                  SIZE 017, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 036, 144 MSGET oGTipo     VAR cGTipo              SIZE 021, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 005 SAY oSay3 PROMPT "GRUPO PDB"             SIZE 041, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 037, 005 MSGET oGGrupo    VAR cGGrupo             SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 075 SAY oSay4 PROMPT "SUB-GRUPO"             SIZE 039, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 037, 075 MSGET oGSGrupo   VAR cGSGrupo            SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 173 SAY oSay5 PROMPT "UM"                    SIZE 025, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 037, 173 MSGET oGUM       VAR cGUM                SIZE 017, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 200 SAY oSay6 PROMPT "SEG UM"                SIZE 025, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 037, 200 MSGET oGSegUM    VAR cGSegUM             SIZE 032, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 055, 005 SAY oSay7 PROMPT "CAD. LIBERADO"         SIZE 053, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 062, 005 MSGET oGCadLib   VAR cGCadLib            SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 055, 087 SAY oSay8 PROMPT "CONTABIL APROVADO"     SIZE 056, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 062, 087 MSGET oGFisApv   VAR cGFisApv            SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 055, 172 SAY oSay9 PROMPT "COMPRAS APROVADO"      SIZE 063, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 062, 172 MSGET oGCApv     VAR cGCApv              SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 083, 111 BUTTON oBConf PROMPT "&Confirmar"        SIZE 063, 012 OF oDlgpRD PIXEL
	@ 083, 182 BUTTON oBCanc PROMPT "Ca&ncelar"         SIZE 063, 012 OF oDlgpRD PIXEL


	oGFisApv:Disable()
	oGCadLib:Disable()
	oGCApv:Disable()
	oGDesc:Disable()
	oGTipo:Disable()
	oGGrupo:Disable()
	oGSGrupo:Disable()
	oGUM:Disable()
	oGSegUM:Disable()
	// Don't change the Align Order
	oGroup1:Align := CONTROL_ALIGN_ALLCLIENT

	oBConf:bAction := {|| lOK := .T., oDlgpRD:End()}
	oBCanc:bAction := {|| oDlgpRD:End()}

	ACTIVATE MSDIALOG oDlgpRD CENTERED

	If lOK
		If np_Opc == 1
			If FwAlertYesNo("Confirma liberação do cadastro para <b>REVISÃO CONTABIL</b>?","Liberacao Cadastro")
				reclock("SZ9",.F.)
				SZ9->Z9_CADLIB  := 'S'
				SZ9->Z9_DTLIBC  := date()
				// SZ9->Z9_PUIDR   := cUserName
				SZ9->Z9_LIBFIS  := 'N'
				SZ9->Z9_DTLIBFI := cTod( '' )
				SZ9->Z9_PUIDF   := ''
				SZ9->Z9_LIBCOM  := 'N'
				SZ9->Z9_DTLIBCP := cTod( '' )
				SZ9->Z9_PUIDC   := ''
				SZ9->Z9_STATUS  := '1'
				SZ9->(MsUnLock())
				// Notifica('Contabil')
			EndIf
		ElseIf np_Opc == 2
			If SZ9->Z9_CADLIB == 'S'
				If FwAlertYesNo("Confirma liberação do cadastro para <b>REVISÃO COMPRAS</b>?","Liberacao Cadastro")
					reclock("SZ9",.F.)
					SZ9->Z9_LIBFIS  := 'S'
					SZ9->Z9_DTLIBFI := Date()
					SZ9->Z9_PUIDF   := cUserName
					SZ9->Z9_LIBCOM  := 'N'
					SZ9->Z9_DTLIBCP := cTod( '' )
					SZ9->Z9_PUIDC   := ''
					SZ9->Z9_STATUS := '2'
					SZ9->(MsUnLock())
					// Notifica('Compras')
				EndIf
			Else
				FwAlertWarning("Cadastro não liberado para revisão Contabil.","Alert")
			EndIf
		EndIf
	EndIf

return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function RejCProd(np_Opc)
	Local cGCadLib := iif(SZ9->Z9_CADLIB=="S","SIM","NAO")
	Local cGCApv   := iif(SZ9->Z9_LIBCOM=="S","SIM","NAO")
	Local cGDesc   := SZ9->Z9_DESCR
	Local cGFisApv := iif(SZ9->Z9_LIBFIS=="S","SIM","NAO")
	Local cGGrupo  := SZ9->Z9_GRUPO
	Local cGSegUM  := SZ9->Z9_SEGUM
	Local cGSGrupo := SZ9->Z9_SUBGRP
	Local cGTipo   := SZ9->Z9_TIPO
	Local cGUM     := SZ9->Z9_UM

	Local oBCanc
	Local oBConf
	Local oGCadLib
	Local oGCApv
	Local oGDesc
	Local oGFisApv
	Local oGGrupo
	Local oGroup1
	Local oGroup2
	Local oGSegUM
	Local oGSGrupo
	Local oGTipo
	Local oGUM
	Local oMMotivo
	Local cMMotivo := SZ9->Z9_MOTIVO
	Local oPanel1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	local lOK := .F.
	Static oDlgRej

	DEFINE MSDIALOG oDlgRej TITLE "::.. Liberação Cadastro ..::" FROM 000, 000  TO 310, 500 COLORS 0, 16777215 PIXEL

	@ 003, 003 MSPANEL oPanel1 SIZE 240, 077 OF oDlgRej COLORS 0, 16777215 RAISED
	@ 000, 000 GROUP oGroup1 TO 076, 239 PROMPT " ::.. CADASTRO DE PRODUTO ..:: " OF oPanel1 COLOR 0, 16777215 PIXEL
	@ 010, 005 SAY oSay1 PROMPT "DESCRIÇÃO" SIZE 044, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 017, 005 MSGET oGDesc VAR cGDesc SIZE 205, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 144 SAY oSay2 PROMPT "TIPO" SIZE 017, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 036, 144 MSGET oGTipo VAR cGTipo SIZE 021, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 005 SAY oSay3 PROMPT "GRUPO PDB" SIZE 041, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 037, 005 MSGET oGGrupo VAR cGGrupo SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 075 SAY oSay4 PROMPT "SUB-GRUPO" SIZE 039, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 037, 075 MSGET oGSGrupo VAR cGSGrupo SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 173 SAY oSay5 PROMPT "UM" SIZE 025, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 037, 173 MSGET oGUM VAR cGUM SIZE 017, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 030, 200 SAY oSay6 PROMPT "SEG UM" SIZE 025, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 037, 200 MSGET oGSegUM VAR cGSegUM SIZE 032, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 055, 005 SAY oSay7 PROMPT "CAD. LIBERADO" SIZE 053, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 062, 005 MSGET oGCadLib VAR cGCadLib SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 055, 087 SAY oSay8 PROMPT "CONTABIL APROVADO" SIZE 056, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 062, 087 MSGET oGFisApv VAR cGFisApv SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 055, 172 SAY oSay9 PROMPT "COMPRAS APROVADO" SIZE 063, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 062, 172 MSGET oGCApv VAR cGCApv SIZE 060, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 140, 111 BUTTON oBConf PROMPT "&Confirmar" SIZE 063, 012 OF oDlgRej PIXEL
	@ 140, 182 BUTTON oBCanc PROMPT "Ca&ncelar" SIZE 063, 012 OF oDlgRej PIXEL

	@ 084, 005 GROUP oGroup2 TO 137, 245 PROMPT "  ..:: MOTIVO ::.. " OF oDlgRej COLOR 0, 16777215 PIXEL
	@ 092, 010 GET oMMotivo VAR cMMotivo OF oDlgRej MULTILINE SIZE 230, 041 COLORS 0, 16777215 HSCROLL PIXEL

	// Don't change the Align Order
	oGroup1:Align := CONTROL_ALIGN_ALLCLIENT
	oGFisApv:Disable()
	oGCadLib:Disable()
	oGCApv:Disable()
	oGDesc:Disable()
	oGTipo:Disable()
	oGGrupo:Disable()
	oGSGrupo:Disable()
	oGUM:Disable()
	oGSegUM:Disable()
	oBConf:bAction := {|| lOK := .T., oDlgRej:End()}
	oBCanc:bAction := {|| oDlgRej:End()}


	ACTIVATE MSDIALOG oDlgRej CENTERED

	If lOK

		If FwAlertYesNo("Confirma <b>REJEIÇÃO<b> do cadastro?","Rejeição Cadastro")
			reclock("SZ9",.F.)
			SZ9->Z9_CADLIB  := 'N'
			SZ9->Z9_DTLIBC  := cTod( '' )
			// SZ9->Z9_PUIDR   := ''
			SZ9->Z9_LIBFIS  := 'N'
			SZ9->Z9_DTLIBFI := cTod( '' )
			SZ9->Z9_PUIDF   := ''
			SZ9->Z9_LIBCOM  := 'N'
			SZ9->Z9_DTLIBCP := cTod( '' )
			SZ9->Z9_PUIDC   := ''
			SZ9->Z9_STATUS  := iif(np_Opc == 1, '3' , '5' )
			If SZ9->(FieldPos("Z9_MOTIVO")) > 0
				SZ9->Z9_MOTIVO  := cMMotivo
			EndIf
			SZ9->(MsUnLock())

			Notifica('Rejeitado',__cUserID)

		EndIf

	EndIf
Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function Notifica(cp_Status,cp_user)
	local cCC    := ""
	local cHtml  := ""
	local cEmail := ""
	local nX := 0

	dbSelectArea("SZH")
	dbSetOrder(1)
	dbSeek(FWxFilial("SZH") + SZ9->Z9_GRUPO)

	dbSelectArea("CT1")
	dbSetOrder(1)
	dbSeek(FWxFilial("CT1") + SZ9->Z9_CONTA)

	dbSelectArea("SYD")
	dbSetOrder(1)
	dbSeek(FWxFilial("SYD") + SZ9->Z9_NCM)


	cHtml := ''
	cHtml += '<!doctype html>' + CRLF
	cHtml += '<html>' + CRLF
	cHtml += '<head>' + CRLF
	cHtml += '<meta charset="utf-8">' + CRLF
	cHtml += '<title>Eurofins - Solicitacao Cadastro Produto</title>' + CRLF
	cHtml += '	<style type="text/css">' + CRLF
	cHtml += '		.titulo{' + CRLF
	cHtml += '			text-align: center;' + CRLF
	cHtml += '			font-family: "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", "DejaVu Sans", Verdana, "sans-serif";' + CRLF
	cHtml += '			font-size: 20px;' + CRLF
	cHtml += '			color: #580607' + CRLF
	cHtml += '		}' + CRLF
	cHtml += '		.titTab{' + CRLF
	cHtml += '			text-align: center;' + CRLF
	cHtml += '			font-size: 12px;' + CRLF
	cHtml += '			background: #b5850b;' + CRLF
	cHtml += '			color:white;' + CRLF
	cHtml += '		}' + CRLF
	cHtml += '		.TitMot{' + CRLF
	cHtml += '			text-align: center;' + CRLF
	cHtml += '			font-size: 12px;' + CRLF
	cHtml += '			background: #CC0202;' + CRLF
	cHtml += '			color:white;' + CRLF
	cHtml += '		}' + CRLF
	cHtml += '		.itemTab{' + CRLF
	cHtml += '			font-size: 12px;' + CRLF
	cHtml += '			background:#D8D8D8' + CRLF
	cHtml += '		}	' + CRLF
	cHtml += '    	.TitSts{' + CRLF
	cHtml += '			text-align: center;' + CRLF
	cHtml += '			font-size: 12px;' + CRLF
	cHtml += '			background: #77a493;' + CRLF
	cHtml += '			color:white;' + CRLF
	cHtml += '		}' + CRLF
	cHtml += '		table{ ' + CRLF
	cHtml += '			margin-top: 1.5cm;' + CRLF
	cHtml += '			margin-left: 1.5cm;' + CRLF
	cHtml += '			margin-right: 1.5cm;' + CRLF
	cHtml += '			font-family: "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", "DejaVu Sans", Verdana, "sans-serif"' + CRLF
	cHtml += '		}' + CRLF
	cHtml += '	</style>' + CRLF
	cHtml += '</head>' + CRLF
	cHtml += '<body>' + CRLF
	cHtml += '<div>' + CRLF
	cHtml += '	<p class="titulo"><strong>Solicitacao Cadastro de Produto [ ' + alltrim(SZ9->Z9_IDREQ) + ' ] </strong></p>' + CRLF
	cHtml += '	<p class="titulo"><strong> ' + cp_Status + ' por '+UsrRetName(cp_user)+' '+UsrFullName(cp_user)+' </strong></p>' + CRLF
	cHtml += '</div>' + CRLF
	cHtml += '<table width="95%" border="0" cellspacing="2">' + CRLF
	cHtml += '  <tbody>' + CRLF
	cHtml += '    <tr>' + CRLF
	cHtml += '      <td class="titTab" width="25%">Descricao</td>' + CRLF
	cHtml += '	    <td class="titTab" width="5%">Tipo</td>' + CRLF
	cHtml += '	    <td class="titTab" width="25%">Grupo PDB</td>' + CRLF
	cHtml += '      <td class="titTab" width="5%">Sub-Grupo</td>' + CRLF
	cHtml += '      <td class="titTab" width="5%">UM</td>' + CRLF
	cHtml += '      <td class="titTab" width="5%">UM Coupa</td>' + CRLF
	cHtml += '      <td class="titTab" width="10%">Conta Contabil</td>' + CRLF
	cHtml += '      <td class="titTab" width="10%">NCM</td>' + CRLF
	cHtml += '      <td class="titTab" width="5%">Origem</td>' + CRLF
	cHtml += '      <td class="titTab" width="5%">Part Number</td>' + CRLF
	cHtml += '      <td class="titTab" width="5%">Data Cadastro</td>' + CRLF
	cHtml += '      <td class="titTab" width="5%">Codigo Produto</td>' + CRLF
	cHtml += '      <td class="titTab" width="5%">Obs. Justificativa</td>' + CRLF
	cHtml += '    </tr>' + CRLF
	cHtml += '    <tr>' + CRLF
	cHtml += '	    <td class="itemTab">' + alltrim(SZ9->Z9_DESCR) + '</td>' + CRLF
	cHtml += '	    <td class="itemTab">' + alltrim(SZ9->Z9_TIPO) + '</td>	' + CRLF
	cHtml += '      <td class="itemTab" >' + alltrim(SZ9->Z9_GRUPO) + " : " + alltrim(SZH->ZH_DESC)+ '</td>' + CRLF
	cHtml += '      <td class="itemTab" align="center">' + alltrim(SZ9->Z9_SUBGRP) + '</td>' + CRLF
	cHtml += '      <td class="itemTab" align="center">' + alltrim(SZ9->Z9_UM) + '</td>' + CRLF
	cHtml += '      <td class="itemTab" align="center">' + alltrim(SZ9->Z9_SEGUM) + '</td>' + CRLF
	cHtml += '      <td class="itemTab" >' + alltrim(CT1->CT1_DESC01) + '</td>' + CRLF
	cHtml += '      <td class="itemTab" align="center">' + alltrim(SZ9->Z9_NCM) + " : " + alltrim(SYD->YD_DESC_P) + '</td>' + CRLF
	cHtml += '      <td class="itemTab" align="center">' + alltrim(SZ9->Z9_ORIGEM) + '</td>' + CRLF
	cHtml += '      <td class="itemTab" align="center">' + alltrim(SZ9->Z9_PARTNUM) + '</td>' + CRLF
	cHtml += '      <td class="itemTab" align="center">' + cValToChar(SZ9->Z9_DTCAD) + '</td>' + CRLF
	cHtml += '      <td class="itemTab" align="center">' + alltrim(SZ9->Z9_CODIGO) + '</td>' + CRLF
	If SZ9->(FieldPos("Z9_JUSTIFI")) > 0
		cHtml += '      <td class="itemTab" >' + alltrim(SZ9->Z9_JUSTIFI) + '</td>' + CRLF
	Else
		cHtml += '      <td class="itemTab" > </td>' + CRLF
	EndIf
	cHtml += '    </tr>' + CRLF
	cHtml += '  </tbody>' + CRLF
	cHtml += '</table>' + CRLF
	If cp_Status == 'Rejeitado'
		cHtml += '	<br>' + CRLF
		cHtml += '	<hr>' + CRLF
		cHtml += '<table width="50%" border="0" cellspacing="2">' + CRLF
		cHtml += '  <tbody>' + CRLF
		cHtml += '    <tr>' + CRLF
		cHtml += '      <td class="TitMot" width="30%">Motivo</td>' + CRLF
		cHtml += '    </tr>' + CRLF
		cHtml += '    <tr>' + CRLF
		cHtml += '	  <td class="itemTab">' + SZ9->Z9_MOTIVO + '</td>	' + CRLF
		cHtml += '    </tr>' + CRLF
		cHtml += '  </tbody>' + CRLF
		cHtml += '</table>' + CRLF
	Else
		cHtml += '	<br>' + CRLF
		cHtml += '	<hr>' + CRLF
		cHtml += '<table width="50%" border="0" cellspacing="2">' + CRLF
		cHtml += '  <tbody>' + CRLF
		cHtml += '    <tr>' + CRLF
		cHtml += '      <td class="TitSts" width="10%">Etapa</td>' + CRLF
		cHtml += '		<td class="TitSts" width="20%">Usuario</td>' + CRLF
		cHtml += '      <td class="TitSts" width="20%">Data Liberacao</td>' + CRLF
		cHtml += '    </tr>' + CRLF
		cHtml += '    <tr>' + CRLF
		cHtml += '		<td class="itemTab"><strong>Cadastro</strong></td>' + CRLF
		cHtml += '	  	<td class="itemTab" align="center">' + alltrim(SZ9->Z9_PUIDR) + '</td>' + CRLF
		cHtml += '		<td class="itemTab" align="center">' + cValToChar(SZ9->Z9_DTLIBC) + '</td>' + CRLF
		cHtml += '    </tr>' + CRLF
		cHtml += '    <tr>' + CRLF
		cHtml += '		<td class="itemTab"><strong>Contabil</strong></td>' + CRLF
		cHtml += '	  	<td class="itemTab" align="center">' + alltrim(SZ9->Z9_PUIDF) + '</td>' + CRLF
		cHtml += '		<td class="itemTab" align="center">' + cValToChar(SZ9->Z9_DTLIBFI) + '</td>' + CRLF
		cHtml += '    </tr>' + CRLF
		cHtml += '    <tr>' + CRLF
		cHtml += '		<td class="itemTab"><strong>Compras</strong></td>' + CRLF
		cHtml += '	  	<td class="itemTab" align="center">' + alltrim(SZ9->Z9_PUIDC) + '</td>	' + CRLF
		cHtml += '		<td class="itemTab" align="center">' + cValToChar(SZ9->Z9_DTLIBCP) + '</td>' + CRLF
		cHtml += '    </tr>' + CRLF
		cHtml += '  </tbody>' + CRLF
		cHtml += '</table>' + CRLF
	EndIf
	cHtml += '</body>' + CRLF
	cHtml += '</html>' + CRLF


	If cp_Status == "Rejeitado" .or. cp_Status == "Aprovado"
		PswOrder(2)
		If PswSeek( SZ9->Z9_PUIDR, .T. )
			cEmail := alltrim(PswRet()[1][14]) // Retorna vetor com informações do usuário
		EndIf
	ElseIf cp_Status == "Contabil"
		aLib := strToKarr(GetMv("CL_PRDFIS"), '#')
		cEmail := ""

		For nX := 1 to len(aLib)
			PswOrder(2)
			If PswSeek( aLib[nX], .T. )
				cEmail += alltrim(PswRet()[1][14])+';' // Retorna vetor com informações do usuário
			EndIf
		Next nX

	ElseIf cp_Status == "Compras"
		aLib := strToKarr(GetMv("CL_PRDCMP"), '#')
		cEmail := ""

		For nX := 1 to len(aLib)
			PswOrder(2)
			If PswSeek( aLib[nX], .T. )
				cEmail += alltrim(PswRet()[1][14])+';' // Retorna vetor com informações do usuário
			EndIf
		Next nX
	EndIf

	//cCC := "CamilaSilva@eurofins.com"

	U_SendMail(, cEmail, ;
		cCC,;
		'solicitacao Cadastro de Produto ',;
		cHtml,;
		'')

return()


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

user function NtCodNew(_cFunc)
	local cNome     := ""
	local cFldtemp  := iif(_cFunc==2,GetTempPath(),"\Temp\")
	Local cFile     := "" //cFldtemp + cNome + ".xls"
	local cQuery    := ""
	local cSheet    := ""
	local nX        := 0
	local cTitulo   := "Novos Cadastros de Produto"
	Local aParambox := {}

	If !IsBlind()

		aAdd(aParamBox,{1,"Data de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
		aAdd(aParamBox,{1,"Data até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02

		If !ParamBox(aParamBox,"Relação de Produtos",,,,,,,,ProcName(),.T.,.T.)
			return()
		Else
			dDataDe  := MV_PAR01
			dDataAte := MV_PAR02
		Endif
	Else
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0100" MODULO "COM"
		dDataDe  := dDataBase
		dDataAte := dDataBase
	EndIf

	cNome  := "NovosProdutos_"+dTos(dDataBase)
	cFile  := cFldtemp + cNome + ".xls"
	cSheet := "Cadastros - " + dTos(dDataBase)

	FWMakeDir('\Temp\',.F.)

	cQuery += " SELECT ltrim(rtrim(B1_DESC)) AS [NAME]
	cQuery += "      , ltrim(rtrim(B1_SEGUM)) as UOM_CODE
	cQuery += "      , 'No' as [CUSTOM]
	cQuery += "      , ltrim(rtrim(B1_ZZSGPRD)) AS [ITEM_CODE]
	cQuery += "      , ltrim(rtrim(str(B1_CONV)))+'x'+ltrim(rtrim(B1_SEGUM)) AS PURCHASE_UNIT
	cQuery += "      , 'BR-PR-UNKNOWN' AS SUPPLIER_ID
	cQuery += "      , 'PLEASE CHANGE THE SUPPLIER' AS SUPPLIER_NAME
	cQuery += "      , 'No' AS PREFERRED
	cQuery += "      , 0 AS PRICE
	cQuery += "      , 'BRL' AS CURRENCY
	cQuery += "      , LTRIM(RTRIM(B1_XPARTNU)) AS PART_NUM
	cQuery += "      , LTRIM(RTRIM(B1_COD)) AS ERP_CODE
	cQuery += "      , ltrim(rtrim(B1_XIDREQ)) AS[ID_REQ]
	cQuery += "      , B1_ZZDTCRI AS [DT_INC]
	cQuery += " FROM " + RetSqlName("SB1")
	cQuery += " WHERE D_E_L_E_T_ = ''
	cQuery += " AND B1_ZZDTCRI >= '" + dTos(dDataDe) + "'
	cQuery += " AND B1_ZZDTCRI <= '" + dTos(dDataAte) + "'
	cQuery += " AND B1_ZZSGPRD != ''
	cQuery += " GROUP BY ltrim(rtrim(B1_DESC))
	cQuery += "      , ltrim(rtrim(B1_SEGUM))
	cQuery += "      , ltrim(rtrim(B1_ZZSGPRD))
	cQuery += "      , ltrim(rtrim(str(B1_CONV)))+'x'+ltrim(rtrim(B1_SEGUM))
	cQuery += "      , LTRIM(RTRIM(B1_XPARTNU))
	cQuery += "      , LTRIM(RTRIM(B1_COD))
	cQuery += "      , ltrim(rtrim(B1_XIDREQ))
	cQuery += "      , B1_ZZDTCRI
	TcQuery cQuery New Alias (cTRB := GetNextAlias())


	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())

		If file(cFile)
			FERASE(cFile)
		EndIf

		oFWMsExcel := FWMsExcelEx():New()

		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitulo)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"Name"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"UOM Code"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Custom"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Item Class Code"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Purchase Unit"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier ID"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier Name"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Preferred"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Price"                        ,1,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Currency"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Part Number"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"ERP Ref. Code"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"ID Req"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Cad."                    ,1,4)

		while (cTRB)->(!eof())

			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->NAME,;
				(cTRB)->UOM_CODE,;
				(cTRB)->CUSTOM,;
				(cTRB)->ITEM_CODE,;
				(cTRB)->PURCHASE_UNIT,;
				(cTRB)->SUPPLIER_ID,;
				(cTRB)->SUPPLIER_NAME,;
				(cTRB)->PREFERRED,;
				(cTRB)->PRICE,;
				(cTRB)->CURRENCY,;
				(cTRB)->PART_NUM,;
				(cTRB)->ERP_CODE,;
				(cTRB)->ID_REQ,;
				sTod((cTRB)->DT_INC)})

			(cTRB)->(dbSkip())
		EndDo

//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cFile)

		If IsBlind()
			sleep(5000)
		EndIf

		// If ApOleClient("MSEXCEL") .and. File(cFile) .and. !IsBlind()
		// 	//Abrindo o excel e abrindo o arquivo xml
		// 	oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
		// 	oExcel:WorkBooks:Open(cFile)     //Abre uma planilha
		// 	oExcel:SetVisible(.T.)              //Visualiza a planilha
		// 	oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
		// EndIf

		If _cFunc = 1
			If File(cFile)
				cCC := "" //"leandro@solucaocompacta.com.br"

				aLib := strToKarr(GetMv("CL_PRDCMP"), '#')
				//cEmail := "compras@eurofins.com"
				cEmail := "compras@eurofinslatam.com"
			/*
			For nX := 1 to len(aLib)
				PswOrder(2)
				If PswSeek( aLib[nX], .T. )
					If !Empty(alltrim(PswRet()[1][14]))
						cEmail += alltrim(PswRet()[1][14])+';' // Retorna vetor com informações do usuário
					EndIf
				EndIf
			Next nX
			*/

				U_SendMail(, cEmail, ;
					cCC,;
					'Relatorio de Novos Produtos - ' + cValToChar(Date()),;
					'Relatorio de Novos Produtos',;
					cFile)

				If File(cFile)
					FERASE(cFile)
				EndIf
			EndIf
		else
			If ApOleClient("MSEXCEL") .and. File(cFile) .and. !IsBlind()
				//Abrindo o excel e abrindo o arquivo xml
				oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
				oExcel:WorkBooks:Open(cFile)     //Abre uma planilha
				oExcel:SetVisible(.T.)              //Visualiza a planilha
				oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
			EndIf
		endif

	EndIf
	(cTRB)->(dbCloseArea())

	If IsBlind()
		RESET ENVIRONMENT
	EndIf

return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function ImpSZ9TXT()

	Local aArea     := GetArea()
	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "TXT files (*.txt) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'TXT'
			Processa({|| fImporta() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fImporta
função importação dos dados
@type function
@version 12.1.33
@author adm_tla8
@since 28/10/2022
@return variant, return_description
/*/
Static Function fImporta()
	local aArea      := GetArea()
	local cArqLog    := "zImptxt_" + dToS(Date()) + "_" + StrTran(Time(), ':' , '-' ) + ".log"
	local nTotLinhas := 0
	local cLinAtu    := ""
	local nLinhaAtu  := 0
	local aLinha     := {}
	local oArquivo
	local aLinhas
	local nX         := 0
	private aItens   := {}

	Private cDirLog  := GetTempPath() + "x_importacao\"
	Private cLog     := ""


	If ! ExistDir(cDirLog)
		MakeDir(cDirLog)
	EndIf

	oArquivo := FWFileReader():New(cArqOri)

	If (oArquivo:Open())

		If ! (oArquivo:EoF())

			aLinhas := oArquivo:GetAllLines()
			nTotLinhas := Len(aLinhas)
			ProcRegua(nTotLinhas)


			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqOri)
			oArquivo:Open()

			//Enquanto tiver linhas
			While (oArquivo:HasLine())
				lValid := .T.
				nLinhaAtu++
				IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

				cLinAtu := oArquivo:GetLine()
				aLinha  := StrTokArr2(cLinAtu, "|",.T.)

				If len(aLinha) != 9
					cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", estrutura do arquivo invalida. " + cValToChar(len(aLinha)) + ";" + CRLF
					lValid := .F.
				EndIf

				If !Empty(aLinha[nPosTipo])
					If !VldTipo(aLinha[nPosTipo])
						cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", TIPO PRODUTO invalido [ " + aLinha[nPosTipo] + " ] - Col. :" + cValToChar(nPosTipo) + ";" + CRLF
						lValid := .F.
					EndIf
				Else
					cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", TIPO PRODUTO nao informado - Col. :" + cValToChar(nPosTipo) + ";" + CRLF
					lValid := .F.
				EndIf

				If Empty(aLinha[nPosDesc])
					cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", nao informado DESCRICAO do produto - Col. :" + cValToChar(nPosDesc) + ";" + CRLF
					lValid := .F.
				EndIf

				If !Empty(aLinha[nPosUM])
					If !VldUM(aLinha[nPosUM])
						cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", UNIDADE MEDIDA invalida [ " + aLinha[nPosUM] + " ] - Col. :" + cValToChar(nPosUM) + ";" + CRLF
						lValid := .F.
					Else
						If !VldSegUM(aLinha[nPosUM])
							cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", UNIDADE MEDIDA COUPA nao vinculado com esta unidade de medida [ " + aLinha[nPosUM] + " ] - Col. :" + cValToChar(nPosUM) + ";" + CRLF
							lValid := .F.
						EndIf
					EndIf
				Else
					cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", UNIDADE MEDIDA nao informada - Col. :" + cValToChar(nPosUM) + ";" + CRLF
					lValid := .F.
				EndIf

				If !Empty(aLinha[nPosOri])
					If !vldOrig(aLinha[nPosOri])
						cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", ORIGEM do produto invalida [ " + aLinha[nPosOri] + " ] - Col. :" + cValToChar(nPosOri) + ";" + CRLF
						lValid := .F.
					EndIf
				Else
					cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", ORIGEM do produto nao informado - Col. :" + cValToChar(nPosOri) + ";" + CRLF
					lValid := .F.
				EndIf

				If !Empty(aLinha[nPosConta])
					If !vldConta(aLinha[nPosConta])
						cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", CONTA CONTABIL do produto invalida [ " + aLinha[nPosConta] + " ] - Col. :" + cValToChar(nPosConta) + ";" + CRLF
						lValid := .F.
					EndIf
				Else
					cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", CONTA CONTABIL nao informado - Col. :" + cValToChar(nPosConta) + ";" + CRLF
					lValid := .F.
				EndIf

				If !Empty(aLinha[nPosNCM])
					If !vldNCM(aLinha[nPosNCM])
						cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", NCM do produto invalida [ " + aLinha[nPosNCM] + " ] - Col. :" + cValToChar(nPosNCM) + ";" + CRLF
						lValid := .F.
					EndIf
				Else
					If !aLinha[nPosTipo] $ cTpProd
						cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", NCM do produto nao informado - Col. :" + cValToChar(nPosNCM) + ";" + CRLF
						lValid := .F.
					EndIf
				EndIf

				If !Empty(aLinha[nPosGrp])
					If !vldGrp(aLinha[nPosGrp], aLinha[nPosTipo])
						cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", GRUPO PDB do produto invalida [ " + aLinha[nPosGrp] + " ] - Col. :" + cValToChar(nPosGrp) + ";" + CRLF
						lValid := .F.
					EndIf
				Else
					cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", GRUPO PDB do produto nao informado - Col. :" + cValToChar(nPosGrp) + ";" + CRLF
					lValid := .F.
				EndIf

				If Empty(aLinha[nPosPN])
					cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", nao informado PART NUMBER do produto - Col. :" + cValToChar(nPosPN) + ";" + CRLF
					lValid := .F.
				EndIf

				If lValid
					aAdd(aItens,{aLinha[nPosTipo],;
						aLinha[nPosGrp],;
						RetSGrp(substr(aLinha[nPosGrp],1,3)),;
						alltrim(aLinha[nPosDesc]),;
						aLinha[nPosUM],;
						RetSegUM(aLinha[nPosUM]),;
						alltrim(aLinha[nPosConta]),;
						alltrim(aLinha[nPosNCM]),;
						alltrim(aLinha[nPosOri]),;
						alltrim(aLinha[nPosPN]),;
						alltrim(aLinha[nPosJust])})
				EndIf
			EndDo


			If ! Empty(cLog)
				cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
				MemoWrite(cDirLog + cArqLog, cLog)
				ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
			Else
				For nX := 1 to len(aItens)
					reclock("SZ9",.T.)
					SZ9->Z9_FILIAL  := FwXFilial("SZ9")
					SZ9->Z9_IDREQ   := GETSXENUM("SZ9","Z9_IDREQ")
					SZ9->Z9_INTEGRA := "S"
					SZ9->Z9_TIPO    := aItens[nX,1]
					SZ9->Z9_GRUPO   := aItens[nX,2]
					SZ9->Z9_SUBGRP  := aItens[nX,3]
					SZ9->Z9_CODIGO  := ""
					SZ9->Z9_DESCR   := FwCutOff(upper(aItens[nX,4]),.T.)
					SZ9->Z9_UM      := aItens[nX,5]
					SZ9->Z9_LOCPAD  := '01'
					SZ9->Z9_SEGUM   := aItens[nX,6]
					SZ9->Z9_FATOR   := 1
					SZ9->Z9_TPCONV  := "D"
					SZ9->Z9_CONTA   := aItens[nX,7]
					SZ9->Z9_NCM     := aItens[nX,8]
					SZ9->Z9_ORIGEM  := aItens[nX,9]
					SZ9->Z9_USRREQ  := __cUserID
					SZ9->Z9_PUIDR   := cUserName
					SZ9->Z9_DTCAD   := dDataBase
					SZ9->Z9_CADLIB  := "N"
					SZ9->Z9_PARTNUM := aItens[nX,10]
					If SZ9->(FieldPos("Z9_JUSTIFI")) > 0
						SZ9->Z9_JUSTIFI := aItens[nX,11]
					EndIf
					If SZ9->(FieldPos("Z9_ORIGCHI")) > 0 .and. len(aItens[nX]) >= 12
						SZ9->Z9_ORIGCHI := aItens[nX,12]
					EndIf
					SZ9->(MsUnlock())
					ConfirmSX8()
				Next nX
			EndIf

		Else
			MsgStop("Arquivo não tem conteúdo!", "Atenção")
		EndIf


		oArquivo:Close()
	Else
		MsgStop("Arquivo não pode ser aberto!", "Atenção")
	EndIf

	RestArea(aArea)
Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function VldTipo(cp_TIpo)

	local aArea := GetArea()
	local lRet := .T.
	dbSelectArea("SX5")
	If !dbSeek(xFilial("SX5")+"02"+cp_TIpo)
		lRet := .F.
	EndIf
	RestArea(aArea)

Return(lRet)
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static Function VldUM(cp_UM)
return(SAH->(dbSetOrder(1), dbSeek(FWxFilial("SAH") + cp_UM)))

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static Function VldSegUM(cp_UM)
	local lRet := .T.
	local aArea := GetArea()

	dbSelectArea("SAH")
	dbSetOrder(1)
	If dbSeek(FWxFilial("SAH") + cp_UM )
		If Empty(SAH->AH_XUMCOUP)
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)

return( lRet )

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function vldOrig(cp_Origem)
return( ExistCpo("SX5","S0"+cp_Origem) )


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function vldConta(cp_Conta)
return( CT1->(dbSetOrder(1), dbSeek(FWxFilial("CT1") + cp_Conta)) )


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function vldNCM(cp_NCM)
	local lRet := .T.

	dbSelectArea("SYD")
	dbSetOrder(1)
	If dbSeek(FWxFilial("SYD") + cp_NCM)
		If SYD->YD_MSBLQL == '1'
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

return( lRet )


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function vldGrp(cp_Grp, cp_Tipo)
	local lRet := .F.
	local aArea := GetArea()

	dbSelectArea("SZH")
	dbSetOrder(1)
	If dbSeek(FWxFilial("SZH") + cp_Grp)
		If SZH->ZH_MSBLQL != '1'
			lRet := .T.
		EndIf
		If (cp_Tipo == "AF" .and. SZH->ZH_CAMEX != 'S') .or. (cp_Tipo != "AF" .and. SZH->ZH_CAMEX == 'S')
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
return( lRet )

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function RetSegUM(cp_UM)
	local cRet := ""
	dbSelectArea("SAH")
	dbSetOrder(1)
	If dbSeek(FWxFilial("SAH") + cp_UM )
		If !Empty(SAH->AH_XUMCOUP)
			cRet := SAH->AH_XUMCOUP
		EndIf
	EndIf

return(cRet)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function RetSGrp(cp_SubGrp)
	local cRet := ""

	dbSelectArea("SX5")
	If dbSeek(FWxFilial("SX5") + "Z7" + cp_SubGrp)
		cRet := alltrim(SX5->X5_CHAVE)
	EndIf

return(cRet)


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------!SECTION
static function CadItem()
	local cArqLog       := "zProctxt_" + dToS(Date()) + "_" + StrTran(Time(), ':' , '-' ) + ".log"
	Local cWhere        := "%Z9_OK = '" + cMark + "' AND Z9_LIBFIS = 'S' AND Z9_CADLIB = 'S' AND (Z9_CODIGO = '' or Z9_CODIGO = '01' ) AND Z9_STATUS != '4' AND Z9_LIBCOM != 'S' %"
	local nAtual        := 0
	local nTotal        := 0
	local nZ            := 0
	Local oModel        := Nil
	local cError        := ""
	Private cDirLog     := GetTempPath() + "x_importacao\"
	Private cLog        := ""
	Private lMsErroAuto := .F.


	If ! ExistDir(cDirLog)
		MakeDir(cDirLog)
	EndIf

	//Construindo a consulta
	BeginSql Alias "SQL_SZ9"

        SELECT SZ9.R_E_C_N_O_ AS REC
        FROM %table:SZ9% SZ9
        WHERE %Exp:cWhere%
            AND SZ9.%notDel%
	EndSql

	dbSelectArea("SQL_SZ9")
	Count To nTotal
	ProcRegua(nTotal)
	SQL_SZ9->(dbGoTop())
	If SQL_SZ9->(!eof())
		while SQL_SZ9->(!eof())

			nAtual++
			IncProc("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")


			dbSelectArea("SZ9")
			SZ9->(dbGoTo(SQL_SZ9->REC))

			oModel  := FwLoadModel ("MATA010")
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()


			oModel:SetValue("SB1MASTER","B1_COD"            , '01'              )
			oModel:SetValue("SB1MASTER","B1_TIPO"           , SZ9->Z9_TIPO      )
			oModel:SetValue("SB1MASTER","B1_ZZSGPRD"        , SZ9->Z9_GRUPO     )
			If !Empty(SZ9->Z9_SUBGRP)
				oModel:SetValue("SB1MASTER","B1_ZZSUBGR"    , SZ9->Z9_SUBGRP    )
			EndIf
			oModel:SetValue("SB1MASTER","B1_DESC"           , SZ9->Z9_DESCR     )
			oModel:SetValue("SB1MASTER","B1_UM"             , SZ9->Z9_UM        )
			oModel:SetValue("SB1MASTER","B1_SEGUM"          , SZ9->Z9_SEGUM     )
			oModel:SetValue("SB1MASTER","B1_LOCPAD"         , SZ9->Z9_LOCPAD    )
			oModel:SetValue("SB1MASTER","B1_CONV"           , SZ9->Z9_FATOR     )
			oModel:SetValue("SB1MASTER","B1_TIPCONV"        , SZ9->Z9_TPCONV    )
			oModel:SetValue("SB1MASTER","B1_CONTA"          , SZ9->Z9_CONTA     )
			oModel:SetValue("SB1MASTER","B1_POSIPI"         , SZ9->Z9_NCM       )
			oModel:SetValue("SB1MASTER","B1_ORIGEM"         , SZ9->Z9_ORIGEM    )
			oModel:SetValue("SB1MASTER","B1_XIDREQ"         , SZ9->Z9_IDREQ     )
			oModel:SetValue("SB1MASTER","B1_XPARTNU"        , SZ9->Z9_PARTNUM   )
			oModel:SetValue("SB1MASTER","B1_GARANT"         , '2'               )
			oModel:SetValue("SB1MASTER","B1_ZZINTPA"        , 'S'               )
			oModel:SetValue("SB1MASTER","B1_ZZDTCRI"        , dDataBase         )

			If SB1->(FieldPos("B1_XORIGCH")) > 0 .and. SZ9->(FieldPos("Z9_ORIGCHI")) > 0
				oModel:SetValue("SB1MASTER","B1_XORIGCH"    , SZ9->Z9_ORIGCHI   )
			EndIf

			If oModel:VldData()
				oModel:CommitData()

				cQuery := "SELECT TOP 1 B1_COD PRODUTO FROM " + RetSqlName("SB1")
				cQuery += " WHERE D_E_L_E_T_ = '' AND B1_XIDREQ = '" + SZ9->Z9_IDREQ + "'"
				TcQuery cQuery New Alias (cTRBPRD := GetNextAlias())

				If (cTRBPRD)->(!eof())
					reclock("SZ9",.F.)
					SZ9->Z9_STATUS  := '4'
					SZ9->Z9_LIBCOM  := 'S'
					SZ9->Z9_DTLIBCP := dDataBase
					SZ9->Z9_PUIDC   := cUserName
					SZ9->Z9_CODIGO  := (cTRBPRD)->PRODUTO
					SZ9->(MsUnlock())

					Notifica("Aprovado",cUserName)

				EndIf

			Else

				cLog := ""
				//For nZ := 1 To Len(oModel:GetErrorMessage())
				cLog += oModel:GetErrorMsgText()+ CRLF
				//Next nZ

				If !Empty(cLog)
					cError += cLog + CRLF + CRLF
					// VarInfo("",)
				EndIf
			EndIf

			oModel:DeActivate()
			oModel:Destroy()

			oModel := NIL
			SQL_SZ9->(dbSkip())
		EndDo

		If !Empty(cError)
			cError := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cError
			MemoWrite(cDirLog + cArqLog, cError)
			ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
		EndIf

	Else
		FwAlertWarning("Não existem itens aptos a serem liberados.")
	EndIf
	SQL_SZ9->(dbCloseArea())

Return Nil

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------!SECTION
User function LibCadLote(np_Opc)

	Local cWhere        := ""
	local nAtual        := 0
	local nTotal        := 0

	If np_Opc ==  1
		cWhere        := "%Z9_OK = '" + cMark + "' AND Z9_LIBFIS != 'S' AND Z9_CADLIB != 'S' %"
	ElseIf np_Opc ==  2
		cWhere        := "%Z9_OK = '" + cMark + "' AND Z9_LIBFIS != 'S' AND Z9_CADLIB = 'S' AND Z9_STATUS = '1' %"
	EndIf

	//Construindo a consulta
	BeginSql Alias "SQL_SZ9"

        SELECT SZ9.R_E_C_N_O_ AS REC
        FROM %table:SZ9% SZ9
        WHERE %Exp:cWhere%
            AND SZ9.%notDel%
	EndSql

	dbSelectArea("SQL_SZ9")
	Count To nTotal
	ProcRegua(nTotal)
	SQL_SZ9->(dbGoTop())
	If SQL_SZ9->(!eof())
		while SQL_SZ9->(!eof())

			nAtual++
			IncProc("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

			dbSelectArea("SZ9")
			SZ9->(dbGoTo(SQL_SZ9->REC))

			If np_Opc == 1

				reclock("SZ9",.F.)
				SZ9->Z9_CADLIB  := 'S'
				SZ9->Z9_DTLIBC  := date()
				// SZ9->Z9_PUIDR   := cUserName
				SZ9->Z9_LIBFIS  := 'N'
				SZ9->Z9_DTLIBFI := cTod( '' )
				SZ9->Z9_PUIDF   := ''
				SZ9->Z9_LIBCOM  := 'N'
				SZ9->Z9_DTLIBCP := cTod( '' )
				SZ9->Z9_PUIDC   := ''
				SZ9->Z9_STATUS  := '1'
				SZ9->(MsUnLock())
				// Notifica('Contabil')

			ElseIf np_Opc == 2

				reclock("SZ9",.F.)
				SZ9->Z9_LIBFIS  := 'S'
				SZ9->Z9_DTLIBFI := Date()
				SZ9->Z9_PUIDF   := cUserName
				SZ9->Z9_LIBCOM  := 'N'
				SZ9->Z9_DTLIBCP := cTod( '' )
				SZ9->Z9_PUIDC   := ''
				SZ9->Z9_STATUS := '2'
				SZ9->(MsUnLock())
				// Notifica('Compras')

			EndIf

			SQL_SZ9->(dbSkip())
		EndDo

	Else
		FwAlertWarning("Não existem itens aptos a serem liberados.")
	EndIf

	SQL_SZ9->(dbCloseArea())


return()


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function CadSZH()

	Local aArea    := GetArea()
	Local cDelOk   := ".T."
	Local cFunTOk  := ".T." //Pode ser colocado como "u_zVldTst()"
	Local aRotAdic := {}

	aadd(aRotAdic,{ "# Importa CSV","u_UpdSgrp", 0 , 6 })

	//Chamando a tela de cadastros
	AxCadastro('SZH', 'Grupo PDB', cDelOk, cFunTOk,aRotAdic)

	RestArea(aArea)
Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function VldSZH01()
	local lRet := .T. as logical
	local cCpoValid := alltrim(StrTran(ReadVar(),"M->",""))

	If cCpoValid == "ZH_FERIAS"

		If M->ZH_FERIAS == "N"
			M->ZH_DFERIAS := cTod("")
			M->ZH_PUIDSUB := CriaVar("ZH_PUIDSUB")
			M->ZH_COMPSUB := CriaVar("ZH_COMPSUB")
		EndIf

	EndIf

return( lRet )


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function UpdSgrp()
	Local aArea     := GetArea()
	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| UpdSZH() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function UpdSZH()
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

				If ! "codigo" $ Lower(cLinAtu)
					If !Empty(aLinha[nPosCodigo])
						cCodigo   := aLinha[nPosCodigo]
						cDescric  := alltrim(upper(aLinha[nPosDescri]))
						cConta    := aLinha[nPosCta]
						cBloq     := aLinha[nPosBloq]
						cCamex    := aLinha[nPosCamex]
						cEnvFor   := upper(iif(Empty(aLinha[nPosEnvFor]),"N",aLinha[nPosEnvFor]))
						cPUIDComp := aLinha[nPosPUIDCom]
						cFerias   := aLinha[nPosFerias]
						dDtFerias := cTod(aLinha[nPosDtFerias])
						cPUIDSub  := aLinha[nPosPUIDSub]


						DbSelectArea('SZH')
						SZH->(DbSetOrder(1))
						lSeek := SZH->(DbSeek(FWxFilial('SZH') + cCodigo))
						cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", Codigo [" + cCodigo + " - " + cDescric + "] " +;
							"registro "+iif(lseek,"alterado","incluido") + "." + CRLF

						//Realiza a alteração do fornecedor
						RecLock('SZH', !lSeek)
						SZH->ZH_CODIGO  := cCodigo
						SZH->ZH_DESC    := cDescric
						SZH->ZH_CONTA   := cConta
						SZH->ZH_MSBLQL  := cBloq
						SZH->ZH_CAMEX   := cCamex
						SZH->ZH_ENVFOR  := cEnvFor
						SZH->ZH_PUIDCOM := cPUIDComp
						SZH->ZH_FERIAS  := cFerias
						SZH->ZH_DFERIAS := dDtFerias
						SZH->ZH_PUIDSUB := cPUIDSub
						If !Empty(cPUIDComp)
							PswOrder(2)
							If PswSeek( cPUIDComp, .T. )
								SZH->ZH_COMPRAD := PswRet()[1][4]
							EndIf
						EndIf
						If !EMpty(cPUIDSub)
							If PswSeek( cPUIDSub, .T. )
								SZH->ZH_COMPSUB := PswRet()[1][4]
							EndIf
						EndIf
						SZH->(MsUnlock())
					Endif


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


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function AllMark()

	Local cWhere        := ""

	aSelFil := SelFil()

	If !aSelFil[1]
		return(.F.)
	EndIf

	cQuery := " UPDATE SZ9010 SET Z9_OK = ' ' FROM SZ9010 WHERE D_E_L_E_T_ = ''
	TcSQLExec(cQuery)

	If aSelFil[2] == 0
		cWhere        := "% (Z9_CODIGO = '' or Z9_CODIGO = '01') AND Z9_STATUS = '' AND Z9_LIBCOM != 'S' %"
	Else
		cWhere        := "% (Z9_CODIGO = '' or Z9_CODIGO = '01') AND Z9_STATUS = '" +  cValToChar(aSelFil[2]) + "' AND Z9_LIBCOM != 'S' %"
	EndIf


	//Construindo a consulta
	BeginSql Alias "SQL_SZ9"

        SELECT SZ9.R_E_C_N_O_ AS REC
        FROM %table:SZ9% SZ9
        WHERE %Exp:cWhere%
            AND SZ9.%notDel%
	EndSql

	dbSelectArea("SQL_SZ9")
	SQL_SZ9->(dbGoTop())
	If SQL_SZ9->(!eof())
		while SQL_SZ9->(!eof())

			dbSelectArea("SZ9")
			SZ9->(dbGoTo(SQL_SZ9->REC))

			RecLock("SZ9",.F.)
			oMark:MarkRec()
			SZ9->(MsUnlock())

			SQL_SZ9->(dbSkip())
		End
	EndIf
	SQL_SZ9->(dbCloseArea())


	dbSelectArea("SZ9")
	SZ9->(dbGoTop())

	oMark:oBrowse:Refresh(.T.)
return()

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function SelFil()

	local lRet := .F.
	Local oBFiltro
	Local oFont1 := TFont():New("Courier",,020,,.F.,,,,,.F.,.F.)
	Local oLstBox
	Local nLstBox := 0
	Local aItens := {"Pendente Liberação Solicitante","Pendente Aprovação Contábil","Pendente Aprovação Compras","Rejeição Contabil","Rejeição Compras"}
	Static oDlgFil

	DEFINE MSDIALOG oDlgFil TITLE "::.. Seleção Registro ..::" FROM 000, 000  TO 170, 350 COLORS 0, 16777215 PIXEL

	@ 005, 005 LISTBOX oLstBox VAR nLstBox ITEMS aItens SIZE 165, 056 OF oDlgFil COLORS 0, 16777215 FONT oFont1 PIXEL
	@ 072, 000 BUTTON oBFiltro PROMPT "APLICAR FILTRO" SIZE 175, 012 OF oDlgFil PIXEL

	// Don't change the Align Order
	oBFiltro:Align := CONTROL_ALIGN_BOTTOM
	oBFiltro:bAction := {|| lRet := .T., oDlgFil:End()}
	ACTIVATE MSDIALOG oDlgFil CENTERED

	nLstBox := iif(nLstBox<=4,nLstBox-= 1, nLstBox)
return({lRet, nLstBox})


	// oMark:AddLegend( "Empty(Z9_STATUS)", "DISABLE"    ,    "Pendente Liberação" )
	// oMark:AddLegend( "Z9_STATUS == '1'", "BR_AMARELO" ,    "Cadastro Liberado" )
	// oMark:AddLegend( "Z9_STATUS == '2'", "BR_AZUL"    ,    "Liberacao Contabil" )
	// oMark:AddLegend( "Z9_STATUS == '3'", "BR_MARROM"  ,    "Rejeicao Contabil" )
	// oMark:AddLegend( "Z9_STATUS == '4'", "ENABLE"     ,    "Cadastro Aprovado (Produto Criado)" )
	// oMark:AddLegend( "Z9_STATUS == '5'", "BR_PRETO"   ,    "Rejeicao Compras" )
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------

user function vldtpZ9()
	local lRet := .T.


	If alltrim(FWFldGet('Z9_TIPO')) == "AF"
		dbSelectArea("SZH")
		dbSetOrder(1)
		If dbSeek(FWxFilial("SZH") + FWFldGet('Z9_GRUPO'))
			If SZH->ZH_CAMEX != 'S'
				Help( ,, 'ZMVCSZ9',,"Para tipo de produto AI deve ser informado um grupo PDB com controle Capex." , 1, 0 )
				lRet := .F.
			EndIf
		EndIf
	EndIf

return lRet


user function SGRUPDB()

	cQuery := ""
	cQuery += "SELECT * FROM SGRUPDB"
	TcQuery cQuery New Alias (cTRB := GetNextAlias())


	dbSelectArea((cTRB))
	while (cTRB)->(!eof())

		dbSelectArea("SX5")
		reclock("SX5",.T.)
		SX5->X5_FILIAL := (cTRB)->X5_FILIAL
		SX5->X5_TABELA := ':Z'
		SX5->X5_CHAVE := (cTRB)->X5_CHAVE
		SX5->X5_DESCRI := (cTRB)->X5_DESCRI
		SX5->X5_DESCSPA := (cTRB)->X5_DESCSPA
		SX5->X5_DESCENG := (cTRB)->X5_DESCENG
		SX5->(MsUnLock())

		(cTRB)->(dbSkip())
	EndDo
	(cTRB)->(dbCloseArea())

return()
