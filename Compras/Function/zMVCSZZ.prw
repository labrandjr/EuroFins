//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#include "tbiconn.ch"

//Variáveis Estáticas
Static cTitulo   := "Ficha Requisição Cadastro Fornecedor"



//Posições do Array
Static nPosCodigo   := 1 //Coluna A no Excel
Static nPosLoja     := 2 //Coluna B no Excel


User Function zMVCSZZ()
	Local aArea   := GetArea()
	private oBrowse
	private cMark := GetMark()
	public lGerFAuto := .T.

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZZ")
	oBrowse:SetDescription(cTitulo)

	// If FwAlertYesNo("Deseja visualizar apenas suas ficha de cadastro?")
	// 	oBrowse:SetFilterDefault("upper(alltrim(SZZ->ZZ_PUIDR)) == '" + upper(alltrim(cUserName)) +"'" )
	// EndIf

	Processa( {|| U_FGerFor() },"Aguarde. Gerando fichas pendentes efetivacao ..." )

	If IsAprov()
		If FwAlertYesNo("Deseja realizar filtro somente para sua aprovação?")
			oBrowse:SetFilterDefault("@"+FilAprov())
		EndIf
	EndIf

	//Legendas
	oBrowse:AddLegend( "Empty(ZZ_STATUS)", "DISABLE" , "Pendente Liberação" )
	oBrowse:AddLegend( "ZZ_STATUS == '1' ", "BR_AMARELO" , "Cadastro Liberado" )
	oBrowse:AddLegend( "ZZ_STATUS == '3' ", "BR_MARROM" , "Cadastro Rejeicao" )
	oBrowse:AddLegend( "ZZ_STATUS == '4' .and. ZZ_TPREG == 'B' ", "BR_PRETO" , "Cadastro Bloqueado" )
	oBrowse:AddLegend( "ZZ_STATUS == '4' ", "ENABLE" , "Cadastro Aprovado" )

	oBrowse:Activate()

	RestArea(aArea)
Return Nil

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function IsAprov()
	local lRet as logical
	local cPuID as character

	lRet := .F.
	cPuID := alltrim(cUserName)

	cTRB := GetNextAlias()
	BeginSql Alias cTRB
                Select count(*) AS Reg
                From %Table:SZC%
                Where %NotDel% and
                ZC_PUID = %Exp:cPuID%

	EndSql

	dbSelectArea((cTRB))
	If (cTRB)->Reg != 0
		lRet := .T.
	EndIf

return(lRet)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function FilAprov()
	local cFilRet as character

	cFilRet := " ZZ_STATUS != '4' AND ZZ_IDREQ IN (SELECT DISTINCT Z5_NUM FROM " + RetSqlName("SZ5") + " SZ5 " + ;
		" WHERE SZ5.D_E_L_E_T_ = '' AND Z5_PUIDAPV = '' AND Z5_PUID = '" + alltrim(cUserName) + "') "

return(cFilRet)


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function MenuDef()
	Local aRot    := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar'          ACTION 'VIEWDEF.zMVCSZZ'                            OPERATION MODEL_OPERATION_VIEW ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'             ACTION 'VIEWDEF.zMVCSZZ'                            OPERATION 3 ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'             ACTION 'VIEWDEF.zMVCSZZ'                            OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'             ACTION 'VIEWDEF.zMVCSZZ'                            OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

	ADD OPTION aRot TITLE 'Envia Cad. Aprov.'   ACTION 'u_GerAlc(SZZ->ZZ_IDREQ, "F", SZZ->ZZ_TIPO)' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRot TITLE 'Reenvia WF. Aprov.'  ACTION 'u_RWF_FOR(SZZ->ZZ_IDREQ, "F")'              OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRot TITLE 'Status Aprovcao'     ACTION 'u_ConsApv(SZZ->ZZ_IDREQ)'                   OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRot TITLE 'Anexar Documento'    ACTION 'U_MSdoc()'                                  OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRot TITLE 'Req. Alteracao For.' ACTION 'U_ReqAltFor()'                              OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRot TITLE 'Reclass. Alteracao'  ACTION 'U_ReclasAF()'                               OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRot TITLE 'Relatorio'           ACTION 'U_RptFornece()'                             OPERATION MODEL_OPERATION_UPDATE ACCESS 0

	If __cUserID $ GetMv("CL_BLQSA2",.F.,"000000")
		ADD OPTION aRot TITLE 'Bloqueio Fornecedor' ACTION 'U_BlqCadFor()'                          OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	EndIf

	If __cUserID $ "000430#001133"
		ADD OPTION aRot TITLE '# Força Integracao'      ACTION 'U_FGerFor()'                          OPERATION MODEL_OPERATION_UPDATE ACCESS 0
		ADD OPTION aRot TITLE '# MILE Bloq. Fornec.'    ACTION 'U_UpdBlqFor()'                          OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	EndIf

	IF __cUserId $ GetMv("CL_USRCGC")
		ADD OPTION aRot TITLE '# Desativa/Ativa Validacao CNPJ'      ACTION 'U_AtvCGC()'                          OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ENDIF



Return aRot

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function MSdoc()

	// EnviaNt(SZZ->ZZ_CNPJ, SZZ->ZZ_IDREQ, 'EM APROVACAO')

	If SZZ->ZZ_STATUS == "4"
		Help( ,, 'Help',, 'Não é possivel anexar documento a uma Ficha de cadastro já aprovada.', 1, 0 )
		return( .F. )
	EndIf

	lret := MsDocument('SZZ',SZZ->(RecNo()), 4)

return .t.

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function DuplicF(cp_Chave, cp_IDReq)

	cQuery := ""
	cQuery += " SELECT AC9_ENTIDA AS ENTIDA
	cQuery += "      , AC9_CODENT AS CODENT
	cQuery += "      , AC9_CODOBJ AS CODOBJ
	cQuery += "   FROM " + RetSqlName("AC9") + " AC9
	cQuery += "  WHERE AC9.D_E_L_E_T_ = ''
	cQuery += "    AND AC9_ENTIDA = 'SZZ'
	cQuery += "    AND AC9_CODENT = '" + cp_IDReq + "'
	TcQuery cQuery New Alias (cTRB := GetNextAlias())


	dbSelectArea((cTRB))
	If (cTRB)->(!eof())
		while (cTRB)->(!eof())

			DbSelectArea("AC9")
			AC9->(DbSetOrder(1)) //AC9_FILIAL, AC9_CODOBJ, AC9_ENTIDA, AC9_FILENT, AC9_CODENT
			If !dbSeek(FwXFilial("AC9") + (cTRB)->CODOBJ + 'SA2' + '    ' + cp_Chave)
				Reclock("AC9", .T.)
				AC9->AC9_FILIAL := FWxFilial('AC9')
				AC9->AC9_ENTIDA := "SA2"
				AC9->AC9_CODENT := cp_Chave
				AC9->AC9_CODOBJ := (cTRB)->CODOBJ
				AC9->(MsUnlock())
			Endif

			(cTRB)->(dbSkip())
		EndDo
	EndIf
	(cTRB)->(dbCloseArea())




return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ModelDef()
	Local oModel   := Nil
	Local oStSZZ   := FWFormStruct(1, "SZZ")
	// local aGrpCpo1 :={'ZZ_UF'     , 'ZZ_END'    , 'ZZ_COMPLEM', 'ZZ_BAIRRO' , 'ZZ_CODMUN', 'ZZ_MUN'   , 'ZZ_CEP'    , 'ZZ_PAIS'   , 'ZZ_CODPAIS', 'ZZ_COND'}
	// local aGrpCpo2 :={'ZZ_BANCO'  , 'ZZ_AGENCIA', 'ZZ_NUMCON' , 'ZZ_COLIG'}
	// local aGrpCpo3 :={'ZZ_NOME'   , 'ZZ_NREDUZ'}
	// local aGrpCpo4 :={'ZZ_SIMPNAC', 'ZZ_RECPIS' , 'ZZ_RECCOFI' , 'ZZ_RECCSLL', 'ZZ_RECISS', 'ZZ_CALCIRF', 'ZZ_CONTRIB', 'ZZ_NATUREZ'}
	// local aGrpCpo5 :={'ZZ_NOMGEST', 'ZZ_PERFIL'}
	// local nX       := 0

	// Local bVldPre := {|| u_SZ9Pre()}

	oModel := MPFormModel():New("zMVCSZZM", ,/*{|oModel| }*/,/*bCommit*/,/*bCancel*/)

	// If ALTERA .and. !Empty(SZZ->ZZ_GRPALT)
	// 	If !'1' $ SZZ->ZZ_GRPALT
	// 		For nX := 1 to len(aGrpCpo1)
	// 			oStSZZ:SetProperty(aGrpCpo1[nX], MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.' ))
	// 		Next nX
	// 	EndIf

	// 	If !'2' $ SZZ->ZZ_GRPALT
	// 		For nX := 1 to len(aGrpCpo2)
	// 			oStSZZ:SetProperty(aGrpCpo2[nX], MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.' ))
	// 		Next nX
	// 	EndIf

	// 	If !'3' $ SZZ->ZZ_GRPALT
	// 		For nX := 1 to len(aGrpCpo3)
	// 			oStSZZ:SetProperty(aGrpCpo3[nX], MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.' ))
	// 		Next nX
	// 	EndIf

	// 	If !'4' $ SZZ->ZZ_GRPALT
	// 		For nX := 1 to len(aGrpCpo4)
	// 			oStSZZ:SetProperty(aGrpCpo4[nX], MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.' ))
	// 		Next nX
	// 	EndIf

	// 	If !'5' $ SZZ->ZZ_GRPALT
	// 		For nX := 1 to len(aGrpCpo5)
	// 			oStSZZ:SetProperty(aGrpCpo5[nX], MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.' ))
	// 		Next nX
	// 	EndIf
	// EndIf

	oModel:AddFields("FORMSZZ",/*cOwner*/,oStSZZ)
	oModel:SetPrimaryKey({'ZZ_FILIAL','ZZ_IDREQ'},{'ZZ_FILIAL','ZZ_CNPJ'})
	oModel:SetDescription("Modelo de Dados " + cTitulo)
	oModel:GetModel("FORMSZZ"):SetDescription( cTitulo )


Return oModel

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("zMVCSZZ")
	Local oStSZZ := FWFormStruct(2, "SZZ")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	Local oView  := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_SZZ", oStSZZ, "FORMSZZ")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_SZZ', 'Dados do Grupo de Produtos' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZZ","TELA")
Return oView


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------


user function lstClFor()
	Local aArea   := GetArea()
	Local cOpcoes := ""

	cOpcoes := ""
	cOpcoes += "Ensaios de Proficiencia;"
	cOpcoes += "Insumos (Exceto MRC);"
	cOpcoes += "Padrao MRC;"
	cOpcoes += "Laboratorio de Apoio (Ensaios Clinicos);"
	cOpcoes += "Manutencao de Equipamento Lab;"
	cOpcoes += "Servicos de Auditoria Interna;"
	cOpcoes += "Servicos de Calibracao;"
	cOpcoes += "Servicos de Ensaios;"
	cOpcoes += "Servicos de Logistica;"
	cOpcoes += "Servicos de Meio Ambiente;"
	cOpcoes += "Servicos de Saude e Seguranca;"
	cOpcoes += "Servicos de TI e Software;"
	cOpcoes += "Servicos de Treinamento;"
	cOpcoes += "Servicos de Consultoria;"
	cOpcoes += "Servicos de Terceiros;"
	cOpcoes += "Servicos de Temporarios;"
	cOpcoes += "Outros;"

	RestArea(aArea)
Return cOpcoes

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function GerAlc(cp_Doc, cp_TpAprov,cp_Tipo)
	local cQuery as character
	local cTRB   as character
	local lRet   as logical

	lRet := .T.

	If SZZ->ZZ_STATUS == "4"
		Help( ,, 'Help',, 'Não é possivel gerar nova aprovação para ficha de cadastro já aprovada.', 1, 0 )
		return( .F. )
	EndIf

	If !Empty(SZZ->ZZ_STATUS)
		If !FwAlertYesNo("Ficha de Cadastro de Fornecedor [" + alltrim(SZZ->ZZ_IDREQ) + "] já inicializou o processo de Workflow de aprovação. "+;
				"Deseja estornar o Workflow atual e gerar um novo?")
			return(.F.)
		EndIf
	EndIf


	// If SZZ->ZZ_TIPO $ "J|X"
	cQuery := ""
	cQuery += " SELECT COUNT(*) AS REG FROM " + RetSqlName("AC9") + " AC9
	cQuery += " WHERE AC9.D_E_L_E_T_ = ''
	cQuery += " AND AC9_ENTIDA = 'SZZ'
	cQuery += " AND AC9_CODENT = '" + SZZ->ZZ_IDREQ + "'
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	If (cTRB)->REG == 0
		Help( ,, 'Help',, 'Favor anexar documento antes de enviar a ficha para aprovação.', 1, 0 )
		return( .F. )
	EndIf
	(cTRB)->(dbCloseArea())
	// EndIf


	cQuery := ""
	cQuery += " SELECT SZ5.R_E_C_N_O_ AS RECSZ5, Z5_WFID AS WF_ID FROM " + RetSqlName("SZ5") + " SZ5
	cQuery += " WHERE SZ5.D_E_L_E_T_ =  ''
	cQuery += " AND Z5_NUM = '" + alltrim(cp_Doc) + "'
	cQuery += " AND Z5_TIPO = '" + cp_TpAprov + "'
	cQuery += " AND Z5_STATUS <> 'A' "
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	If (cTRB)->(!eof())

		while (cTRB)->(!eof())

			If !Empty((cTRB)->WF_ID)
				WFKillProcess((cTRB)->WF_ID)
			EndIf

			dbSelectArea("SZ5")
			SZ5->(dbGoTo((cTRB)->RECSZ5))
			reclock("SZ5",.F.)
			SZ5->(dbDelete())
			SZ5->(MsUnlock())

			(cTRB)->(dbSkip())
		EndDo

	EndIf
	(cTRB)->(dbCloseArea())

	/*
	SELECT ZI_ITEM AS SEQ
     , ZC_SETOR AS SETOR
     , ZC_DESCSET AS DESCRICAO
     , ZC_USER AS USUARIO
     , ZC_PUID AS PUID
     , ZC_NOME AS NOME
     , ZC_EMAIL AS E_MAIL
  FROM SZI010 SZI
INNER JOIN SZC010 SZC ON SZC.D_E_L_E_T_ = SZI.D_E_L_E_T_ AND ZI_GRUPO = ZC_SETOR
AND ZC_USER <> '001122'
LEFT JOIN SZ5010 SZ5 ON SZ5.D_E_L_E_T_ = '' AND Z5_GRPAPV = ZC_SETOR
AND Z5_USER = ZC_USER
AND Z5_NUM = '001149'
 WHERE SZI.D_E_L_E_T_ = ''
 AND ZI_TPAPROV = 'F'
 AND ZI_TCLIFOR = 'J'
 AND Z5_USER IS NULL
 ORDER BY 1
	*/


	cQuery := ""
	cQuery += " SELECT ZI_ITEM AS SEQ
	cQuery += "      , ZC_SETOR AS SETOR
	cQuery += "      , ZC_DESCSET AS DESCRICAO
	cQuery += "      , ZC_USER AS USUARIO
	cQuery += "      , ZC_PUID AS PUID
	cQuery += "      , ZC_NOME AS NOME
	cQuery += "      , ZC_EMAIL AS E_MAIL
	cQuery += "   FROM " + RetSqlName("SZI") + " SZI
	cQuery += " INNER JOIN " + RetSqlName("SZC") + " SZC ON SZC.D_E_L_E_T_ = SZI.D_E_L_E_T_ AND ZI_GRUPO = ZC_SETOR
	// CONFORME SOLICITAÇÃO DO FABIO, ELE NÃO IRÁ MAIS RECEBER EMAILS DE APROVAÇÃO DE FICHA DE CADASTRO DE FORNECEDORES
	If GetMv("CL_NWFFR")
		cQuery += " AND ZC_USER <> '001122' "
	ENDIF
	cQuery += " LEFT JOIN "+RetSqlName("SZ5")+" SZ5 ON SZ5.D_E_L_E_T_ = '' AND Z5_GRPAPV = ZC_SETOR "
	//cQuery += " AND Z5_USER = ZC_USER "
	cQuery += " AND Z5_NUM = '"+alltrim(cp_Doc)+"' "
	cQuery += " WHERE SZI.D_E_L_E_T_ = ''
	cQuery += " AND ZI_TPAPROV = '" + cp_TpAprov + "'
	cQuery += " AND ZI_TCLIFOR = '" + cp_Tipo + "'
	cQuery += " AND Z5_USER IS NULL "
	cQuery += " ORDER BY 1
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	If (cTRB)->(!eof())

		while (cTRB)->(!eof())
			lGeraAlc := .T.
			If alltrim((cTRB)->DESCRICAO) $ "CQ|QUALIDADE|QUALI" .and. alltrim(upper(SZZ->ZZ_CLASFOR)) == 'OUTROS'
				lGeraAlc := .F.
			EndIf



			If lGeraAlc

				reclock("SZ5",.T.)
				SZ5->Z5_FILIAL  := FwXFilial("SZ5")
				SZ5->Z5_NUM     := cp_Doc
				SZ5->Z5_TIPO    := cp_TpAprov
				SZ5->Z5_NIVEL   := (cTRB)->SEQ
				SZ5->Z5_USER    := (cTRB)->USUARIO
				SZ5->Z5_EMISSAO := Date()
				SZ5->Z5_STATUS  := "B"
				SZ5->Z5_SEQ     := ""
				SZ5->Z5_DATALIB := cTod("")
				SZ5->Z5_GRPAPV  := (cTRB)->SETOR
				SZ5->Z5_PUID    := (cTRB)->PUID
				SZ5->Z5_WFID    := CriaVar("Z5_WFID")
				SZ5->(MsUnlock())

				Reclock("SZZ",.F.)
				SZZ->ZZ_STATUS := "1"
				If alltrim(SZZ->ZZ_CLASFOR) != 'Outros'
					SZZ->ZZ_HOMOLOG := "S"
				EndIf
				SZZ->(MsUnlock())

			EndIf

			(cTRB)->(dbSkip())
		EndDo

		GeraWF(cp_Doc, cp_TpAprov)

	EndIf
	(cTRB)->(dbCloseArea())

return(lRet)


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function GeraWF(cp_Numero, cp_Tipo)
	local cHostWF  as character
	local aInfLink as array
	local nX := 1  as numeric

	cHostWF   := GetMv("CL_WFLINK")

	aMotAlt   := {"Dados Cadastrais",;
		"Dados Bancario",;
		"Razao Social",;
		"Dados Fiscais",;
		"Dados Flash Expense",;
		"Desbloqueio Fornecedor"}

	cAssunto  := "Aprovacao Cadastro Fornecedor"
	PutMv("MV_WFHTML","T")

	dbSelectArea("SZ5")
	dbSetOrder(1)
	If dbSeek(FWxFilial("SZ5") + padr(cp_Numero,TamSx3("Z5_NUM")[1]) + padr(cp_Tipo,TamSx3("Z5_TIPO")[1]))

		while SZ5->(!eof()) .and. alltrim(SZ5->Z5_NUM) == alltrim(cp_Numero) .and. alltrim(SZ5->Z5_TIPO) == alltrim(cp_Tipo)

			if ALLTRIM(SZ5->Z5_STATUS) <> "A"
				aInfLink := {}
				oProcess := TWFProcess():New(alltrim(cp_Numero), cAssunto)

				oProcess:cTo := "wfFornece"
				oProcess:NewTask("APROVACAO", "\workflow\modelo\Euro_Fornecedor.html")
				oProcess:cSubject := "Aprovacao Ficha Cadastro Fornecedor " + cp_Numero
				oProcess:NewVersion(.T.)
				oProcess:oHtml:ValByName("ficha"		    , SZZ->ZZ_IDREQ )
				oProcess:oHtml:ValByName("tpreg"		    , IIF(SZZ->ZZ_TPREG=="A","ALTERACAO","INCLUSAO") )
				oProcess:oHtml:ValByName("nome"			    , SZZ->ZZ_NOME )
				oProcess:oHtml:ValByName("NReduz"		    , SZZ->ZZ_NREDUZ )
				oProcess:oHtml:ValByName("cnpj"			    , SZZ->ZZ_CNPJ )
				oProcess:oHtml:ValByName("tpFornece"		, X3COMBO('ZZ_TIPO',SZZ->ZZ_TIPO) )
				oProcess:oHtml:ValByName("tpFornecimento"	, upper(SZZ->ZZ_CLASFOR) )
				oProcess:oHtml:ValByName("telefone"			, '('+SZZ->ZZ_DDD+') ' + SZZ->ZZ_TEL )
				oProcess:oHtml:ValByName("email"			, SZZ->ZZ_EMAIL )
				oProcess:oHtml:ValByName("coligada"			, X3COMBO('ZZ_COLIG',SZZ->ZZ_COLIG) )
				oProcess:oHtml:ValByName("cep"			    , SZZ->ZZ_CEP )
				oProcess:oHtml:ValByName("pais"			    , SZZ->ZZ_PAIS )
				oProcess:oHtml:ValByName("endereco"			, SZZ->ZZ_END )
				oProcess:oHtml:ValByName("bairro"			, SZZ->ZZ_BAIRRO )
				oProcess:oHtml:ValByName("codMun"			, SZZ->ZZ_CODMUN )
				oProcess:oHtml:ValByName("municipio"		, SZZ->ZZ_MUN )
				oProcess:oHtml:ValByName("uf"			    , SZZ->ZZ_UF )
				oProcess:oHtml:ValByName("InscE"			, alltrim(SZZ->ZZ_INSCR) )
				oProcess:oHtml:ValByName("InscM"			, alltrim(SZZ->ZZ_INSCRM)  )
				oProcess:oHtml:ValByName("OpSim"			, X3COMBO('ZZ_SIMPNAC',SZZ->ZZ_SIMPNAC) )

				cMotAlt := ""
				For nX := 1 to len(alltrim(SZZ->ZZ_GRPALT))
					nPos := val(substr(SZZ->ZZ_GRPALT,nX,1))
					cMotAlt += aMotAlt[nPos] + ', '
				Next nX

				If !Empty(cMotAlt)
					cMotAlt := alltrim(cMotAlt)
					oProcess:oHtml:ValByName("motAlt"			, substr(cMotAlt,1,len(cMotAlt)-1) )
				Else
					oProcess:oHtml:ValByName("motAlt"			, "" )
				EndIf

				cNaturez := SZZ->ZZ_NATUREZ
				If !Empty(cNaturez)
					dbSelectArea("SED")
					dbSetOrder(1)
					If dbSeek(FWxFilial("SED") + cNaturez)
						cNaturez := alltrim(SED->ED_CODIGO) + " - " + alltrim(SED->ED_DESCRIC)
					EndIf
				EndIf
				oProcess:oHtml:ValByName("Naturez"			, cNaturez )

				// oProcess:oHtml:ValByName("Conta"			, SZZ->ZZ_CONTA )
				oProcess:oHtml:ValByName("Banco"			, SZZ->ZZ_BANCO )
				oProcess:oHtml:ValByName("Agencia"			, SZZ->ZZ_AGENCIA )
				oProcess:oHtml:ValByName("CtaDep"			, SZZ->ZZ_NUMCON )
				oProcess:oHtml:ValByName("bacen"			, SZZ->ZZ_CODPAIS )
				oProcess:oHtml:ValByName("contrib"			, X3COMBO('ZZ_CONTRIB',SZZ->ZZ_CONTRIB) )
				oProcess:oHtml:ValByName("pis"			    , X3COMBO('ZZ_RECPIS',SZZ->ZZ_RECPIS) )
				oProcess:oHtml:ValByName("Cofins"			, X3COMBO('ZZ_RECCOFI',SZZ->ZZ_RECCOFI) )
				oProcess:oHtml:ValByName("csll"			    , X3COMBO('ZZ_RECCSLL',SZZ->ZZ_RECCSLL) )
				oProcess:oHtml:ValByName("irrf"			    , X3COMBO('ZZ_RECISS',SZZ->ZZ_RECISS) )

				oProcess:oHtml:ValByName("motivo"			, " " )
				oProcess:oHtml:ValByName("puid"			    , SZ5->Z5_PUID )
				oProcess:oHtml:ValByName("puidR"			, SZZ->ZZ_PUIDR )
				oProcess:oHtml:ValByName("observ"			,  FwCutOff(SZZ->ZZ_OBSERV, .T.)  )

				dbSelectArea("SZ4")
				SZ4->(dbSetOrder(1), dbSeek(FWxFilial("SZ4")+ SZ5->Z5_GRPAPV))
				oProcess:oHtml:ValByName("grpAprov"			, SZ5->Z5_GRPAPV + " - " + alltrim(SZ4->Z4_DESCRIC) )

				PswOrder(2)
				(  PswSeek(SZZ->ZZ_PUIDR, .T.) )
				cIDX := PswID()

				aAdd(aInfLink,SZZ->ZZ_IDREQ)
				aAdd(aInfLink,Alltrim(SZZ->ZZ_NOME))
				aAdd(aInfLink,Alltrim(SZZ->ZZ_PUIDR) + " - " + UsrFullName(cIDX))
				aAdd(aInfLink,SZZ->ZZ_FILCAD)

				cTexto := "Iniciando processo -  " + cAssunto + " / " + cp_Numero
				cCodStatus := "100100" // Código do cadastro de status de processo
				//oProcess:Track(cCodStatus, cTexto, cUserName, "INICIO")  // Rastreabilidade

				cTexto := "Gerando solicitacao para envio..."
				cCodStatus := "100200"
				oProcess:UserSiga := WFCodUser(cUserName)


				oProcess:bReturn := "U_WFRETFOR()"
				//RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,"000004","1001","ENVIO DE WORKFLOW PARA APROVACAO DE SOLICITAÇÃO DE PREÇO",cUsername)

				// cMailID := oProcess:Start("\workflow\emp"+FwCodEmp()+"\wfFornece\")
				cMailID := oProcess:Start()

				reclock("SZ5",.F.)
				SZ5->Z5_WFID := cValToChar(oProcess:fProcessID) +"."+ cValToChar(oProcess:fTaskID)
				SZ5->(MsUnLock())

				// oProcess:bTimeOut := {{"U_WFTMOSC()", nDias, nHoras, nMinutos}}

				cHtmlModelo := "\workflow\modelo\wflink_Fornece.html"
				oProcess:NewTask(cAssunto, cHtmlModelo)
				oProcess:cSubject := cAssunto

				cTo := RetEmailAPv(SZ5->Z5_GRPAPV, SZ5->Z5_PUID)  //"leandro@solucaocompacta.com.br"
				// Informe o endereço eletrônico do destinatário.
				oProcess:cTo := cTo
				If Len(aInfLink) == 4
					oProcess:ohtml:ValByName("cFicha"   ,aInfLink[1])
					oProcess:ohtml:ValByName("cNomeFor" ,aInfLink[2])
					oProcess:ohtml:ValByName("cUsuario" ,aInfLink[3])
					oProcess:ohtml:ValByName("cCadFil" ,aInfLink[4])
				EndIf
				oProcess:ohtml:ValByName("proc_link",cHostWF+"emp01/wfFornece/" + cMailID + ".htm")
				oProcess:Start()

			endif

			SZ5->(dbSkip())
		End

	EndIf

return()


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function RetEmailAPv(cp_Grupo, cp_Aprov)
	local cQuery := "" as character
	local cRet   := "" as character
	local aArea  := GetArea()

	cQuery := ""
	cQuery += " SELECT ltrim(rtrim(ZC_EMAIL)) AS EMAIL FROM " + RetSqlName("SZC")
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += "  AND ZC_SETOR = '" + cp_Grupo + "'"
	cQuery += "  AND ZC_PUID = '" + cp_Aprov + "'"
	TcQuery cQuery New Alias (cTRT := GetNextAlias())

	dbSelectArea((cTRT))
	If (cTRT)->(!eof())
		cRet := (cTRT)->EMAIL
	EndIf
	(cTRT)->(dbCloseArea())

	RestArea(aArea)

return(cRet)
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function RWF_FOR(cp_Numero, cp_Tipo)
	local cHostWF as character
	local aInfLink as array

	cHostWF   := GetMv("CL_WFLINK")


	cAssunto  := "Aprovacao Cadastro Fornecedor"
	PutMv("MV_WFHTML","T")


	cQuery := ""
	cQuery += " SELECT R_E_C_N_O_ AS REC_SZ5 FROM " + RetSqlName("SZ5") + " SZ5
	cQuery += "  WHERE SZ5.D_E_L_E_T_ = ''
	cQuery += "    AND Z5_NUM = '" + cp_Numero + "'
	cQuery += "    AND Z5_TIPO = '" + cp_Tipo + "'
	//cQuery += "    AND Z5_STATUS = 'B'
	cQuery += "    AND Z5_STATUS <> 'A'
	TcQuery cQuery New Alias (cTRA := GetNextAlias())

	dbSelectArea((cTRA))
	If (cTRA)->(!eof())
		Do while (cTRA)->(!eof())

			dbSelectArea("SZ5")
			SZ5->(dbGoTo((cTRA)->REC_SZ5))

			//finaliza o workflow atual
			If !Empty(SZ5->Z5_WFID)
				WFKillProcess(SZ5->Z5_WFID)
			EndIf


			aInfLink := {}
			oProcess := TWFProcess():New(alltrim(cp_Numero), cAssunto)

			oProcess:cTo := "wfFornece"
			oProcess:NewTask("APROVACAO", "\workflow\modelo\Euro_Fornecedor.html")
			oProcess:cSubject := "Aprovacao Ficha Cadastro Fornecedor " + cp_Numero
			oProcess:NewVersion(.T.)

			oProcess:oHtml:ValByName("ficha"		    , SZZ->ZZ_IDREQ )
			oProcess:oHtml:ValByName("tpreg"		    , IIF(SZZ->ZZ_TPREG=="A","ALTERACAO","INCLUSAO") )

			oProcess:oHtml:ValByName("nome"			    , SZZ->ZZ_NOME )
			oProcess:oHtml:ValByName("NReduz"		    , SZZ->ZZ_NREDUZ )
			oProcess:oHtml:ValByName("cnpj"			    , SZZ->ZZ_CNPJ )
			oProcess:oHtml:ValByName("tpFornece"		, X3COMBO('ZZ_TIPO',SZZ->ZZ_TIPO) )
			oProcess:oHtml:ValByName("tpFornecimento"	, upper(SZZ->ZZ_CLASFOR) )
			oProcess:oHtml:ValByName("telefone"			, '('+SZZ->ZZ_DDD+') ' + SZZ->ZZ_TEL )
			oProcess:oHtml:ValByName("email"			, SZZ->ZZ_EMAIL )
			oProcess:oHtml:ValByName("coligada"			, X3COMBO('ZZ_COLIG',SZZ->ZZ_COLIG) )
			oProcess:oHtml:ValByName("cep"			    , SZZ->ZZ_CEP )
			oProcess:oHtml:ValByName("pais"			    , SZZ->ZZ_PAIS )
			oProcess:oHtml:ValByName("endereco"			, SZZ->ZZ_END )
			oProcess:oHtml:ValByName("bairro"			, SZZ->ZZ_BAIRRO )
			oProcess:oHtml:ValByName("codMun"			, SZZ->ZZ_CODMUN )
			oProcess:oHtml:ValByName("municipio"		, SZZ->ZZ_MUN )
			oProcess:oHtml:ValByName("uf"			    , SZZ->ZZ_UF )
			oProcess:oHtml:ValByName("InscE"			, alltrim(SZZ->ZZ_INSCR) )
			oProcess:oHtml:ValByName("InscM"			, alltrim(SZZ->ZZ_INSCRM)  )
			oProcess:oHtml:ValByName("OpSim"			, X3COMBO('ZZ_SIMPNAC',SZZ->ZZ_SIMPNAC) )

			cNaturez := SZZ->ZZ_NATUREZ
			If !Empty(cNaturez)
				dbSelectArea("SED")
				dbSetOrder(1)
				If dbSeek(FWxFilial("SED") + cNaturez)
					cNaturez := alltrim(SED->ED_CODIGO) + " - " + alltrim(SED->ED_DESCRIC)
				EndIf
			EndIf
			oProcess:oHtml:ValByName("Naturez"			, cNaturez )

			oProcess:oHtml:ValByName("Conta"			, SZZ->ZZ_CONTA )
			oProcess:oHtml:ValByName("Banco"			, SZZ->ZZ_BANCO )
			oProcess:oHtml:ValByName("Agencia"			, SZZ->ZZ_AGENCIA )
			oProcess:oHtml:ValByName("CtaDep"			, SZZ->ZZ_NUMCON )
			oProcess:oHtml:ValByName("bacen"			, SZZ->ZZ_CODPAIS )
			oProcess:oHtml:ValByName("contrib"			, X3COMBO('ZZ_CONTRIB',SZZ->ZZ_CONTRIB) )
			oProcess:oHtml:ValByName("pis"			    , X3COMBO('ZZ_RECPIS',SZZ->ZZ_RECPIS) )
			oProcess:oHtml:ValByName("Cofins"			, X3COMBO('ZZ_RECCOFI',SZZ->ZZ_RECCOFI) )
			oProcess:oHtml:ValByName("csll"			    , X3COMBO('ZZ_RECCSLL',SZZ->ZZ_RECCSLL) )
			oProcess:oHtml:ValByName("irrf"			    , X3COMBO('ZZ_RECISS',SZZ->ZZ_RECISS) )

			oProcess:oHtml:ValByName("motivo"			, " " )
			oProcess:oHtml:ValByName("puid"			    , SZ5->Z5_PUID  )
			oProcess:oHtml:ValByName("puidR"			, SZZ->ZZ_PUIDR )
			oProcess:oHtml:ValByName("observ"			, FwCutOff(SZZ->ZZ_OBSERV, .T.) )

			dbSelectArea("SZ4")
			SZ4->(dbSetOrder(1), dbSeek(FWxFilial("SZ4")+ SZ5->Z5_GRPAPV))
			oProcess:oHtml:ValByName("grpAprov"			, SZ5->Z5_GRPAPV + " - " + alltrim(SZ4->Z4_DESCRIC) )

			PswOrder(2)
			(  PswSeek(SZZ->ZZ_PUIDR, .T.) )
			cIDX := PswID()

			aAdd(aInfLink,SZZ->ZZ_IDREQ)
			aAdd(aInfLink,Alltrim(SZZ->ZZ_NOME))
			aAdd(aInfLink,Alltrim(SZZ->ZZ_PUIDR) + " - " + UsrFullName(cIDX))

			cTexto := "Iniciando processo -  " + cAssunto + " / " + cp_Numero
			cCodStatus := "100100" // Código do cadastro de status de processo
			//oProcess:Track(cCodStatus, cTexto, cUserName, "INICIO")  // Rastreabilidade

			cTexto := "Gerando solicitacao para envio..."
			cCodStatus := "100200"
			oProcess:UserSiga := WFCodUser(cUserName)


			oProcess:bReturn := "U_WFRETFOR()"
			//RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,"000004","1001","ENVIO DE WORKFLOW PARA APROVACAO DE SOLICITAÇÃO DE PREÇO",cUsername)

			// cMailID := oProcess:Start("\workflow\emp"+FwCodEmp()+"\wfFornece\")
			cMailID := oProcess:Start()

			reclock("SZ5",.F.)
			SZ5->Z5_WFID := cValToChar(oProcess:fProcessID) +"."+ cValToChar(oProcess:fTaskID)
			SZ5->(MsUnLock())

			// oProcess:bTimeOut := {{"U_WFTMOSC()", nDias, nHoras, nMinutos}}

			cHtmlModelo := "\workflow\modelo\wflink_Fornece.html"
			oProcess:NewTask(cAssunto, cHtmlModelo)
			oProcess:cSubject := cAssunto

			cTo := RetEmailAPv(SZ5->Z5_GRPAPV, SZ5->Z5_PUID) //"leandro@solucaocompacta.com.br"
			// Informe o endereço eletrônico do destinatário.
			oProcess:cTo := alltrim(cTo)
			If Len(aInfLink) == 3
				oProcess:ohtml:ValByName("cFicha"   ,aInfLink[1])
				oProcess:ohtml:ValByName("cNomeFor" ,aInfLink[2])
				oProcess:ohtml:ValByName("cUsuario" ,aInfLink[3])
			EndIf
			oProcess:ohtml:ValByName("proc_link",cHostWF+"emp"+FwCodEmp()+"/wfFornece/" + cMailID + ".htm")
			oProcess:Start()



			(cTRA)->(dbSkip())
		EndDo
	Else
		FwAlertInfo("Não existem pendência de aprovação para essa ficha de cadastro.","Reencio WF")
	EndIf

return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
user function WFRETFOR(oProcess)


	Local nOpc := 3 // ----> Inclusão
	Local _cTipo:= 1
	Local _cNomUser:= ""
	local lGeraCad := .T.
	public lGerFAuto := .T.


	cDocumento := oProcess:oHtml:RetByName("ficha")
	cCNPJ      := oProcess:oHtml:RetByName("cnpj")
	cGrpApov   := substr(oProcess:oHtml:RetByName("grpAprov"),1,3)
	cPUIDAprov := oProcess:oHtml:RetByName("puid")
	cMotivo    := oProcess:oHtml:RetByName("motivo")
	cRetorno   := oProcess:oHtml:RetByName("aprova")

	ConOut("Documento: " + cDocumento)
	ConOut("Grupo Aprova: " + cGrpApov)
	ConOut("PUID Aprova: " + cPUIDAprov)
	ConOut("Motivo: " + cMotivo)
	ConOut("Retorno: " + cRetorno)


	cQuery := ""
	cQuery += " SELECT R_E_C_N_O_ AS REC_SZ5 FROM " + RetSqlName("SZ5") + " SZ5
	cQuery += "  WHERE SZ5.D_E_L_E_T_ = ''
	cQuery += "    AND Z5_NUM = '" + cDocumento + "'
	cQuery += "    AND Z5_TIPO = 'F'
	cQuery += "    AND Z5_GRPAPV = '" + cGrpApov + "'
	TcQuery cQuery New Alias (cTRA := GetNextAlias())

	dbSelectArea((cTRA))
	Do while (cTRA)->(!eof())

		dbSelectArea("SZ5")
		SZ5->(dbGoTo((cTRA)->REC_SZ5))
		reclock("SZ5",.F.)
		SZ5->Z5_STATUS  := cRetorno
		SZ5->Z5_DATALIB := Date()
		SZ5->Z5_PUIDAPV := cPUIDAprov
		SZ5->(MsUnlock())

		(cTRA)->(dbSkip())
	EndDo
	(cTRA)->(dbCloseArea())


	cQuery := ""
	cQuery += " SELECT  TOP 1 Z5_USER AS REC_USER FROM " + RetSqlName("SZ5") + " SZ5
	cQuery += "  WHERE SZ5.D_E_L_E_T_ = ''
	cQuery += "    AND Z5_NUM = '" + cDocumento + "'
	cQuery += "    AND Z5_TIPO = 'F'
	cQuery += "    AND Z5_GRPAPV = '" + cGrpApov + "'
	cQuery += "    AND Z5_PUID = '"+cPUIDAprov+"'
	cQuery += "    AND Z5_STATUS = '"+cRetorno+"' "
	TcQuery cQuery New Alias (cTRA := GetNextAlias())

	dbSelectArea((cTRA))
	If (cTRA)->(!Eof())
		_cNomUser:= ALLTRIM(UsrFullName((cTRA)->REC_USER))
	Endif
	(cTRA)->(dbCloseArea())



	If !Empty(cMotivo)
		cMotivo := FWCutOff(alltrim(cMotivo),.T.)
		dbSelectArea("SZZ")
		dbSetOrder(1)
		dbSeek(FWxFilial("SZZ") + cDocumento)
		reclock("SZZ",.F.)
		//SZZ->ZZ_MOTIVO := alltrim(SZZ->ZZ_MOTIVO) + CRLF + ' ------------ ' + CRLF + cMotivo
		SZZ->ZZ_MOTIVO := ALLTRIM(oProcess:oHtml:RetByName("grpAprov"))+'-'+_cNomUser+'-'+cMotivo + CRLF + '---' + CRLF + alltrim(SZZ->ZZ_MOTIVO)
		SZZ->(MsUnlock())
	EndIf

	cQuery := ""
	cQuery += " SELECT COUNT(*) AS REG FROM " + RetSqlName("SZ5") + " SZ5
	cQuery += "  WHERE SZ5.D_E_L_E_T_ = ''
	cQuery += "    AND Z5_NUM = '" + cDocumento + "'
	cQuery += "    AND Z5_TIPO = 'F'
	cQuery += "    AND Z5_STATUS != 'A'
	TcQuery cQuery New Alias (cTRA := GetNextAlias())

	dbSelectArea((cTRA))
	If (cTRA)->REG != 0
		lGeraCad := .F.
	EndIf
	(cTRA)->(dbCloseArea())

	If lGeraCad

		// dbSelectArea("SZZ")
		// dbSetOrder(1)
		// dbSeek(FWxFilial("SZZ") + cDocumento)

		// If SZZ->ZZ_TPREG == 'A'
		// 	dbSelectArea("SA2")
		// 	dbSetOrder(1)
		// 	dbSeek(FWxFilial("SA2") + SZZ->ZZ_COD + SZZ->ZZ_LOJA)
		// 	nOpc := 4
		// 	aRet := {{SZZ->ZZ_COD, SZZ->ZZ_LOJA}}
		// EndIf


		dbSelectArea("SZZ")
		dbSetOrder(1)
		dbSeek(FWxFilial("SZZ") + cDocumento)
		cCNPJ := SZZ->ZZ_CNPJ
		If SZZ->ZZ_TPREG == 'A'
			dbSelectArea("SA2")
			if SZZ->ZZ_UF == "EX"
				_cTipo:= 2
				dbSetOrder(1)
				If dbSeek(FWxFilial("SA2") + SZZ->ZZ_COD + SZZ->ZZ_LOJA)
					nOpc := 4
					If SA2->A2_COD != SZZ->ZZ_COD
						reclock("SZZ",.F.)
						SZZ->ZZ_COD  := SA2->A2_COD
						SZZ->ZZ_LOJA := SA2->A2_LOJA
						SZZ->(MsUnlock())
					EndIf
					aRet := {{SZZ->ZZ_COD, SZZ->ZZ_LOJA}}
				Else
					reclock("SZZ",.F.)
					SZZ->ZZ_TPREG := "I"
					SZZ->(MsUnlock())
				EndIf
			else
				dbSetOrder(3)
				If dbSeek(FWxFilial("SA2") + cCNPJ)
					nOpc := 4
					If SA2->A2_COD != SZZ->ZZ_COD
						reclock("SZZ",.F.)
						SZZ->ZZ_COD  := SA2->A2_COD
						SZZ->ZZ_LOJA := SA2->A2_LOJA
						SZZ->(MsUnlock())
					EndIf
					aRet := {{SZZ->ZZ_COD, SZZ->ZZ_LOJA}}
				Else
					reclock("SZZ",.F.)
					SZZ->ZZ_TPREG := "I"
					SZZ->(MsUnlock())
				EndIf
			endif
		EndIf


		oModel := FWLoadModel('MATA020')

		oModel:SetOperation(nOpc)
		oModel:Activate()

		If SZZ->ZZ_TPREG != 'A'
			If SZZ->ZZ_UF == "EX" .and. SZZ->ZZ_COLIG == 'S' .and. !Empty(SZZ->ZZ_COD) .and. !Empty(SZZ->ZZ_LOJA)
				aRet := {{SZZ->ZZ_COD, SZZ->ZZ_LOJA}}
			Else
				aRet := U_RetCodFor(SZZ->ZZ_CNPJ, SZZ->ZZ_UF, SZZ->ZZ_TIPO)
			EndIf
		EndIf

		oModel:SetValue( 'SA2MASTER' , 'A2_COD'         , aRet[1,1]             )
		oModel:SetValue( 'SA2MASTER' , 'A2_LOJA'        , aRet[1,2]             )
		oModel:SetValue( 'SA2MASTER' , 'A2_NOME'        , SZZ->ZZ_NOME          )
		oModel:SetValue( 'SA2MASTER' , 'A2_NREDUZ'      , SZZ->ZZ_NREDUZ        )
		oModel:SetValue( 'SA2MASTER' , 'A2_END'         , SZZ->ZZ_END           )
		oModel:SetValue( 'SA2MASTER' , 'A2_BAIRRO'      , SZZ->ZZ_BAIRRO        )
		oModel:SetValue( 'SA2MASTER' , 'A2_EST'         , SZZ->ZZ_UF            )
		oModel:SetValue( 'SA2MASTER' , 'A2_COD_MUN'     , SZZ->ZZ_CODMUN        )
		oModel:SetValue( 'SA2MASTER' , 'A2_MUN'         , SZZ->ZZ_MUN           )
		oModel:SetValue( 'SA2MASTER' , 'A2_TIPO'        , IIF(SZZ->ZZ_TIPO=='C','F',SZZ->ZZ_TIPO)        )
		oModel:SetValue( 'SA2MASTER' , 'A2_CGC'         , SZZ->ZZ_CNPJ          )
		oModel:SetValue( 'SA2MASTER' , 'A2_COMPLEM'     , SZZ->ZZ_COMPLEM       )
		oModel:SetValue( 'SA2MASTER' , 'A2_ZZCOLIG'     , SZZ->ZZ_COLIG         )
		oModel:SetValue( 'SA2MASTER' , 'A2_CEP'         , SZZ->ZZ_CEP           )
		oModel:SetValue( 'SA2MASTER' , 'A2_DDD'         , SZZ->ZZ_DDD           )
		oModel:SetValue( 'SA2MASTER' , 'A2_TEL'         , SZZ->ZZ_TEL           )
		oModel:SetValue( 'SA2MASTER' , 'A2_INSCR'       , SZZ->ZZ_INSCR         )
		oModel:SetValue( 'SA2MASTER' , 'A2_INSCRM'      , SZZ->ZZ_INSCRM        )
		oModel:SetValue( 'SA2MASTER' , 'A2_PAIS'        , SZZ->ZZ_PAIS          )
		If SZZ->ZZ_TPPESSO == 'FF'
			oModel:SetValue( 'SA2MASTER' , 'A2_EMAIL'   , lower(substr(alltrim(SZZ->ZZ_EMAIL),1,70))         )
			oModel:SetValue( 'SA2MASTER' , 'A2_ZZPCEML' , lower(SZZ->ZZ_EMAIL)  )
		Else
			oModel:SetValue( 'SA2MASTER' , 'A2_ZZPCEML' , lower(SZZ->ZZ_EMAIL)  )
		EndIf
		oModel:SetValue( 'SA2MASTER' , 'A2_SIMPNAC'     , SZZ->ZZ_SIMPNAC       )
		oModel:SetValue( 'SA2MASTER' , 'A2_NATUREZ'     , SZZ->ZZ_NATUREZ       )
		oModel:SetValue( 'SA2MASTER' , 'A2_BANCO'       , SZZ->ZZ_BANCO         )
		oModel:SetValue( 'SA2MASTER' , 'A2_AGENCIA'     , SZZ->ZZ_AGENCIA       )
		oModel:SetValue( 'SA2MASTER' , 'A2_NUMCON'      , SZZ->ZZ_NUMCON        )
		oModel:SetValue( 'SA2MASTER' , 'A2_CODPAIS'     , SZZ->ZZ_CODPAIS       )
		oModel:SetValue( 'SA2MASTER' , 'A2_RECPIS'      , SZZ->ZZ_RECPIS        )
		oModel:SetValue( 'SA2MASTER' , 'A2_RECCOFI'     , SZZ->ZZ_RECCOFI       )
		oModel:SetValue( 'SA2MASTER' , 'A2_RECCSLL'     , SZZ->ZZ_RECCSLL       )
		oModel:SetValue( 'SA2MASTER' , 'A2_RECISS'      , SZZ->ZZ_RECISS        )
		oModel:SetValue( 'SA2MASTER' , 'A2_CONTRIB'     , SZZ->ZZ_CONTRIB       )
		oModel:SetValue( 'SA2MASTER' , 'A2_CALCIRF'     , SZZ->ZZ_CALCIRF       )
		oModel:SetValue( 'SA2MASTER' , 'A2_ZZHOMOL'     , SZZ->ZZ_HOMOLOG       )
		oModel:SetValue( 'SA2MASTER' , 'A2_TPESSOA'     , SZZ->ZZ_TPPESSO       )
		oModel:SetValue( 'SA2MASTER' , 'A2_NOMRESP'     , SZZ->ZZ_NOMGEST       )
		oModel:SetValue( 'SA2MASTER' , 'A2_XPERFIL'     , SZZ->ZZ_PERFIL        )
		oModel:SetValue( 'SA2MASTER' , 'A2_XEMPFLS'     , SZZ->ZZ_EMPFLS        )
		oModel:SetValue( 'SA2MASTER' , 'A2_COND'        , SZZ->ZZ_COND          )
		oModel:SetValue( 'SA2MASTER' , 'A2_XFICHA'      , SZZ->ZZ_IDREQ         )
		oModel:SetValue( 'SA2MASTER' , 'A2_XOUTCLA'     , SZZ->ZZ_OUTCLAS       )
		oModel:SetValue( 'SA2MASTER' , 'A2_XCLAFOR'     , SZZ->ZZ_CLASFOR       )

		If SZZ->ZZ_TPREG == 'A'
			oModel:SetValue( 'SA2MASTER' , 'A2_CONTA'   , SZZ->ZZ_CONTA         )
			oModel:SetValue( 'SA2MASTER' , 'A2_MSBLQL'   , '2'                  )
			If SA2->(FieldPos("A2_XDTALT")) > 0
				oModel:SetValue( 'SA2MASTER' , 'A2_XDTALT'   , dDataBase        )
			EndIf
		Endif

		If SA2->(FieldPos("A2_XFILCAD")) > 0
			oModel:SetValue( 'SA2MASTER' , 'A2_XFILCAD'   , SZZ->ZZ_FILCAD       )
		EndIf

		If oModel:VldData()
			oModel:CommitData()

			//realiza o vinculo com os arquivos anexos
			DuplicF(aRet[1,1]+aRet[1,2], SZZ->ZZ_IDREQ)

			reclock("SZZ",.F.)
			SZZ->ZZ_COD     := aRet[1,1]
			SZZ->ZZ_LOJA    := aRet[1,2]
			SZZ->ZZ_STATUS  := '4'
			SZZ->(MsUnlock())

			// envia e-mail
			EnviaNt(cCNPJ, cDocumento, 'CADASTRO APROVADO',_cTipo,SZZ->ZZ_COD, SZZ->ZZ_LOJA)

			// enviar e-mail compras

		Else
			VarInfo("Erro ao incluir",oModel:GetErrorMessage())
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
		oModel := NIL
	Else
		dbSelectArea("SZZ")
		dbSetOrder(1)
		dbSeek(FWxFilial("SZZ") + cDocumento)
		EnviaNt(cCNPJ, cDocumento, 'EM APROVACAO',_cTipo,SZZ->ZZ_COD, SZZ->ZZ_LOJA)
	EndIf


	If cRetorno == "R"
		dbSelectArea("SZZ")
		dbSetOrder(1)
		dbSeek(FWxFilial("SZZ") + cDocumento)
		reclock("SZZ",.F.)
		SZZ->ZZ_STATUS := '3'
		SZZ->(MsUnlock())


		cQuery := ""
		cQuery += " SELECT SZ5.R_E_C_N_O_ AS RECSZ5, Z5_WFID AS WF_ID FROM " + RetSqlName("SZ5") + " SZ5
		cQuery += " WHERE SZ5.D_E_L_E_T_ =  ''
		cQuery += " AND Z5_NUM = '" + alltrim(cDocumento) + "'
		cQuery += " AND Z5_TIPO = 'F'
		TcQuery cQuery New Alias (cTRB := GetNextAlias())

		dbSelectArea((cTRB))
		If (cTRB)->(!eof())

			while (cTRB)->(!eof())
				If !Empty((cTRB)->WF_ID)
					WFKillProcess((cTRB)->WF_ID)
				EndIf
				(cTRB)->(dbSkip())
			EndDo

		EndIf
		(cTRB)->(dbCloseArea())


	EndIf

return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function vldSZZ01()
	Local cNome := ""
	local lRet := .T.

	If  upper(alltrim(M->ZZ_CLASFOR)) == "OUTROS"
		Do while Empty(cNome)
			cNome := FwInputBox("Informar Classificacao Fornecedor?", cNome)
		EndDo
		FwFldPut( 'ZZ_OUTCLAS'     , cNome)
	Else
		FwFldPut( 'ZZ_OUTCLAS'     , space(20))
	EndIf

	//validacao da natureza financeira
	U_vldSZZ03()

Return(lRet)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldSZZ03
valida o preenchimento da natureza financeira
@type function
@version 12.1.33
@author adm_tla8
@since 21/02/2023
@return logical, validacao do campo
/*/
User Function vldSZZ03()
	local lRet := .T.


	cTipo := FWFldGet('ZZ_TIPO')
	If cTipo == 'X'
		FwFldPut( 'ZZ_NATUREZ'   , '0201015'                , , , , .T.)
	ElseIf cTipo == "J"
		If upper(alltrim(M->ZZ_CLASFOR)) == "INSUMOS (EXCETO MRC)" .or. upper(alltrim(M->ZZ_CLASFOR)) == "PADRAO MRC"
			FwFldPut( 'ZZ_NATUREZ'   , '0201002'                , , , , .T.)
		ElseIf upper(alltrim(M->ZZ_CLASFOR)) $ "LABORATORIO DE APOIO (ENSAIOS CLINICOS)#MANUTENCAO DE EQUIPAMENTO LAB#SERVICOS DE AUDITORIA INTERNA#" + ;
				"SERVICOS DE CALIBRACAO#SERVICOS DE ENSAIOS#SERVICOS DE LOGISTICA#SERVICOS DE MEIO AMBIENTE#SERVICOS DE SAUDE E SEGURANCA#" + ;
				"SERVICOS DE TI E SOFTWARE#SERVICOS DE TREINAMENTO#SERVICOS DE CONSULTORIA#SERVICOS DE TERCEIROS#SERVICOS DE TEMPORARIOS" .and. +;
				FWFldGet('ZZ_RECPIS') == '2' .and. FWFldGet('ZZ_RECCOFI') == '2' .and. FWFldGet('ZZ_RECCSLL') == '2' .and. FWFldGet('ZZ_RECISS') == 'N'

			FwFldPut( 'ZZ_NATUREZ'   , '0201003'                , , , , .T.)
		Endif
	ElseIf cTipo == 'F'
		FwFldPut( 'ZZ_NATUREZ'   , '0201014'                , , , , .T.)
	ElseIf cTipo == 'C'
		FwFldPut( 'ZZ_NATUREZ'   , '0201014'                , , , , .T.)
	EndIf

Return(lRet)



// -----------------------------------------------------------------------------------------------------------------------------------------------------------------


User Function RetCodFor(cp_CNPJ, cXEst, cp_Tipo)
	Local cTMP1         := GetNextAlias()
	Local cTMP2         := GetNextAlias()
	Local aret          := {}
	Local aXArea        := GetArea()



	If Alltrim(cXEst) <> "EX" .and. !Empty(cp_CNPJ)
		If cp_Tipo == "J"
			cCNPJBase := Substr(cp_CNPJ,1,8)
			cCNPJLoja := RIGHT(Substr(cp_CNPJ,1,12),2)
			cQry := " SELECT A2_COD COD, MAX(A2_LOJA) AS LOJA FROM "+RETSQLNAME("SA2")+" WHERE D_E_L_E_T_ = '' AND SUBSTRING(A2_CGC,1,8) = '"+cCNPJBase+"' "
			cQry += " GROUP BY A2_COD "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTMP1, .T., .F. )


			dbSelectArea((cTMP1))
			If ! (cTMP1)->(eof())
				cQry := " SELECT A2_COD COD FROM "+RETSQLNAME("SA2")+" WHERE D_E_L_E_T_ = '' AND SUBSTRING(A2_CGC,1,8) = '"+cCNPJBase+"' AND A2_COD = '"+(cTMP1)->COD+"' "
				cQry += " GROUP BY A2_COD "
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTMP2, .T., .F. )
				If ! (cTMP2)->(eof())
					aadd(aRet    , {(cTMP1)->COD , SOMA1((cTMP1)->LOJA)})
				ELSE
					aadd(aRet    , {(cTMP1)->COD , cCNPJLoja})
				ENDIF
				(cTMP2)->(dbCloseArea())
			Else

				cQry := " SELECT max(A2_COD) COD FROM "+RETSQLNAME("SA2")+" WHERE D_E_L_E_T_ = '' AND SUBSTRING(A2_COD,1,1) = '0'"
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTMP2, .T., .F. )

				dbSelectArea((cTMP2))
				If ! (cTMP2)->(eof())
					aadd(aRet    , {soma1((cTMP2)->COD)                         , cCNPJLoja})
				else
					aadd(aRet    , {"000001"                                    , cCNPJLoja})
				EndIF
				(cTMP2)->(dbCloseArea())
			EndIf
			(cTMP1)->(dbCloseArea())
		Else
			cQry := " SELECT max(A2_COD) COD FROM "+RETSQLNAME("SA2")+" WHERE D_E_L_E_T_ = '' AND SUBSTRING(A2_COD,1,1) = '0'"
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTMP2, .T., .F. )

			dbSelectArea((cTMP2))
			If ! (cTMP2)->(eof())
				aadd(aRet    , {soma1((cTMP2)->COD)                         , "01"})
			else
				aadd(aRet    , {"000001"                                    , "01"})
			EndIF
			(cTMP2)->(dbCloseArea())
		EndIf
	Else
		cQry := " SELECT MAX(RIGHT(A2_COD,4)) COD FROM "+RETSQLNAME("SA2")+" WHERE D_E_L_E_T_ = ''
		cQry += "   AND SUBSTRING(A2_COD,1,2) = 'EX'"
		cQry += "   AND A2_EST = 'EX'
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTMP1, .T., .F. )

		dbSelectArea((cTMP1))
		If ! (cTMP1)->(eof())
			aadd(aRet    , {'EX' + soma1((cTMP1)->COD)                         , "01"})
		EndIf
		(cTMP1)->(dbCloseArea())

	EndIf
	RestArea(aXArea)

Return (aRet)


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function EnviaNt(cp_CNPJ, cp_Documento, cp_Status, cp_tipo,cp_cli,cp_loja)
	local aArea := GetArea()
	Default cp_tipo:= 1
	Default cp_cli:= ""
	Default cp_loja:= ""

	If cp_tipo == 1
		dbSelectArea("SZZ")
		dbSetOrder(2)
		dbSeek(FWxFilial("SZZ") + cp_CNPJ)
	ELSE
		dbSelectArea("SZZ")
		dbSetOrder(1)
		dbSeek(FWxFilial("SZZ") + cp_Documento)
	ENDIF

	cAssunto := 'Processo Aprovação Fornecedor'
	//enviar e-mail de aprovação
	oProcess := TWFProcess():New(alltrim(cp_Documento), "Processo Aprovação Fornecedor")
	cHtmlModelo := "\workflow\modelo\Euro_AvisoFornecedor.html"
	oProcess:NewTask(cAssunto, cHtmlModelo)
	oProcess:cSubject := cAssunto

	PswOrder(2)
	(  PswSeek(SZZ->ZZ_PUIDR, .T.) )
	cIDX := PswID()
	cTo := UsrRetMail(cIDX)
	// Informe o endereço eletrônico do destinatário.

	If alltrim(Upper(cp_Status)) == 'CADASTRO APROVADO'
		cTo += ';compras@eurofins.com'
	EndIf

	oProcess:cTo := cTo

	oProcess:ohtml:ValByName("ficha"       , SZZ->ZZ_IDREQ)
	oProcess:ohtml:ValByName("cnpj"        , alltrim(SZZ->ZZ_NOME))
	oProcess:ohtml:ValByName("fornecedor"  , alltrim(SZZ->ZZ_NOME))
	oProcess:ohtml:ValByName("dataCad"     , cValToChar(SZZ->ZZ_EMISSAO))
	oProcess:ohtml:ValByName("status"      , cp_Status)
	oProcess:ohtml:ValByName("motivo"      , cValToChar(SZZ->ZZ_MOTIVO))

	cQuery := ""
	cQuery += " SELECT Z5_NIVEL AS NIVEL
	cQuery += "     , Z4_DESCRIC AS GRUPO_APV
	cQuery += "     , Z5_DATALIB AS DATADT_LIB
	cQuery += "     , Z5_PUIDAPV AS RESP_APV
	cQuery += "     , CASE WHEN Z5_STATUS = 'B' THEN 'PENDENTE APROVACAO'
	cQuery += "            WHEN Z5_STATUS = 'A' THEN 'APROVADO'
	cQuery += "            WHEN Z5_STATUS = 'R' THEN 'REJEITADO' ELSE Z5_STATUS END AS STATUS
	cQuery += "  FROM SZ5010 SZ5
	cQuery += " INNER JOIN SZ4010 SZ4 ON SZ4.D_E_L_E_T_ = '' AND Z4_CODIGO = Z5_GRPAPV
	cQuery += " WHERE SZ5.D_E_L_E_T_ = ''
	cQuery += "   AND Z5_NUM = '" + cp_Documento + "'
	cQuery += " GROUP BY Z5_NIVEL, Z4_DESCRIC, Z5_DATALIB, Z5_PUIDAPV, Z5_STATUS
	cQuery += " ORDER BY 1
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	while (cTRB)->(!eof())
		aadd(oProcess:oHtml:ValByName("it.grupo")		    , alltrim((cTRB)->GRUPO_APV)                     		)
		aadd(oProcess:oHtml:ValByName("it.dataApv")		    , cValToChar(StoD((cTRB)->DATADT_LIB))             		)
		aadd(oProcess:oHtml:ValByName("it.respApv")		    , alltrim((cTRB)->RESP_APV)                     		)
		aadd(oProcess:oHtml:ValByName("it.statusApv")		, alltrim((cTRB)->STATUS)                     			)
		(cTRB)->(dbSkip())
	EndDo
	(cTRB)->(dbCloseArea())
	oProcess:Start()

	RestArea(aArea)

return



// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function ConsApv(cp_Documento)
	Local oGroup1
	Local oBrowser
	Local aLista := {}
	Static oDlgaPV



	// Insert items here
	Aadd(aLista,{"",cTOd(""),"",""})

	cQuery := ""
	cQuery += " SELECT Z5_NIVEL AS NIVEL
	cQuery += "     , Z4_DESCRIC AS GRUPO_APV
	cQuery += "     , Z5_DATALIB AS DATADT_LIB
	cQuery += "     , Z5_PUIDAPV AS RESP_APV
	cQuery += "     , CASE WHEN Z5_STATUS = 'B' THEN 'PENDENTE APROVACAO'
	cQuery += "            WHEN Z5_STATUS = 'A' THEN 'APROVADO'
	cQuery += "            WHEN Z5_STATUS = 'R' THEN 'REJEITADO' ELSE Z5_STATUS END AS STATUS
	cQuery += "  FROM SZ5010 SZ5
	cQuery += " INNER JOIN SZ4010 SZ4 ON SZ4.D_E_L_E_T_ = '' AND Z4_CODIGO = Z5_GRPAPV
	cQuery += " WHERE SZ5.D_E_L_E_T_ = ''
	cQuery += "   AND Z5_NUM = '" + cp_Documento + "'
	cQuery += " GROUP BY Z5_NIVEL, Z4_DESCRIC, Z5_DATALIB, Z5_PUIDAPV, Z5_STATUS
	cQuery += " ORDER BY 1
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())
		aLista := {}
		while (cTRB)->(!eof())

			Aadd(aLista,{alltrim((cTRB)->GRUPO_APV),;
				sTod(alltrim((cTRB)->DATADT_LIB)),;
				alltrim((cTRB)->RESP_APV),;
				alltrim((cTRB)->STATUS)})

			(cTRB)->(dbSkip())
		EndDo
	EndIf
	(cTRB)->(dbCloseArea())

	DEFINE MSDIALOG oDlgaPV TITLE "::.. Status Aprovação ..::" FROM 000, 000  TO 190, 550 COLORS 0, 16777215 PIXEL

	@ 005, 005 GROUP oGroup1 TO 090, 270 PROMPT "  STATUS DE APROVAÇÃO  " OF oDlgaPV COLOR 0, 16777215 PIXEL

	@ 012, 010 LISTBOX oBrowser Fields HEADER "SETOR","DATA APROV.","RESTP. APROV.","STATUS" SIZE 254, 072 OF oDlgaPV PIXEL ColSizes 50,5
	oBrowser:SetArray(aLista)
	oBrowser:bLine := {|| {;
		aLista[oBrowser:nAt,1],;
		aLista[oBrowser:nAt,2],;
		aLista[oBrowser:nAt,3],;
		aLista[oBrowser:nAt,4];
		}}
	// DoubleClick event
	oBrowser:bLDblClick := {|| aLista[oBrowser:nAt,1] := !aLista[oBrowser:nAt,1],;
		oBrowser:DrawSelect()}

	ACTIVATE MSDIALOG oDlgaPV CENTERED

Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function VldFic01()
	local lRet as logical
	local cTipo as character

	lRet := .T.

	cTipo := FWFldGet('ZZ_TIPO')
	If cTipo == 'X'
		FwFldPut( 'ZZ_INSCR'     , 'ISENTO'                 , , , , .T.)
		FwFldPut( 'ZZ_SIMPNAC'   , '2'                      , , , , .T.)
		FwFldPut( 'ZZ_RECPIS'    , '2'                      , , , , .T.)
		FwFldPut( 'ZZ_RECCOFI'   , '2'                      , , , , .T.)
		FwFldPut( 'ZZ_RECCSLL'   , '2'                      , , , , .T.)
		FwFldPut( 'ZZ_RECISS'    , 'N'                      , , , , .T.)
		FwFldPut( 'ZZ_CONTRIB'   , '2'                      , , , , .T.)
		FwFldPut( 'ZZ_TPPESSO'   , '  '                     , , , , .T.)

	ElseIf cTipo == 'F'
		FwFldPut( 'ZZ_INSCR'     , 'ISENTO'                 , , , , .T.)
		FwFldPut( 'ZZ_SIMPNAC'   , '2'                      , , , , .T.)
		FwFldPut( 'ZZ_TPPESSO'   , '  '                     , , , , .T.)

	ElseIf cTipo == 'C'
		FwFldPut( 'ZZ_INSCR'     , 'ISENTO'                 , , , , .T.)
		FwFldPut( 'ZZ_SIMPNAC'   , '2'                      , , , , .T.)
		FwFldPut( 'ZZ_COLIG'     , 'N'                      , , , , .T.)
		FwFldPut( 'ZZ_TPPESSO'   , 'FF'                     , , , , .T.)
		FwFldPut( 'ZZ_CONTRIB'   , '2'                      , , , , .T.)

	Else
		FwFldPut( 'ZZ_INSCR'     , CriaVar('ZZ_INSCR')      , , , , .T.)
		FwFldPut( 'ZZ_SIMPNAC'   , CriaVar('ZZ_SIMPNAC')    , , , , .T.)
		FwFldPut( 'ZZ_RECPIS'    , CriaVar('ZZ_RECPIS')     , , , , .T.)
		FwFldPut( 'ZZ_RECCOFI'   , CriaVar('ZZ_RECCOFI')    , , , , .T.)
		FwFldPut( 'ZZ_RECCSLL'   , CriaVar('ZZ_RECCSLL')    , , , , .T.)
		FwFldPut( 'ZZ_RECISS'    , CriaVar('ZZ_RECISS')     , , , , .T.)
		FwFldPut( 'ZZ_CONTRIB'   , CriaVar('ZZ_CONTRIB')    , , , , .T.)
		FwFldPut( 'ZZ_TPPESSO'   , '  '                     , , , , .T.)

	EndIf

	//validacao da natureza financeira
	U_vldSZZ03()

return(lRet)


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function VldFic02()
	local lRet as logical
	local cUF as character

	lRet := .T.

	cUF := FWFldGet('ZZ_UF')
	If cUF != 'EX'
		FwFldPut( 'ZZ_PAIS'     , '105' , , , , .T.)
		FwFldPut( 'ZZ_CODPAIS'  , '01058' , , , , .T.)

	Else
		FwFldPut( 'ZZ_PAIS'     , CriaVar('ZZ_PAIS') , , , , .T.)
		FwFldPut( 'ZZ_CODPAIS'  , CriaVar('ZZ_CODPAIS') , , , , .T.)

	EndIf

return(lRet)


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function VldFic04()
	local lRet as logical
	local cCpo as character

	lRet := .T.
	cCpo := ReadVar()


	If alltrim(strTran(cCpo,"M->","")) == "ZZ_AGENCIA"
		If FwIsNumeric(alltrim(&(ReadVar())))
			M->ZZ_AGENCIA := strZero(VAL(M->ZZ_AGENCIA),4)
			FwFldPut( 'ZZ_AGENCIA'     , strZero(VAL(M->ZZ_AGENCIA),4) , , , , .T.)
		EndIf
	EndIf

return(lRet)


// ---------------------------------------------------------------------------------------------------------------------------------------------------

User Function XPicP(cp_TipPes)
	Local cPict := ""
	Default cp_TipPes := ""

	If cp_TipPes $ "F|C"
		cPict := "@R 999.999.999-99"
	Else
		cPict := "@R 99.999.999/9999-99"
	EndIf
	cPict += "%C"


Return(cPict)

// ---------------------------------------------------------------------------------------------------------------------------------------------------
static function CodColig()

	local cIDReq := M->ZZ_IDREQ
	Local cGCod  := space(TamSx3("A2_COD")[1])
	Local cGLoja := space(TamSx3("A2_LOJA")[1])
	Local oBConf
	Local oGCod
	Local oGLoja
	Local oGroup1
	Local oSay1
	Local oSay2
	Local lOK := .F.
	Local lRet := .T.
	Static oDlgCod

	DEFINE MSDIALOG oDlgCod TITLE "CODIGO GLOBAL - COLIGADO" FROM 000, 000  TO 120, 330 COLORS 0, 16777215 PIXEL

	@ 005, 005 GROUP oGroup1 TO 037, 160 OF oDlgCod COLOR 0, 16777215 PIXEL
	@ 010, 010 SAY oSay1 PROMPT "CODIGO" SIZE 025, 007 OF oDlgCod COLORS 0, 16777215 PIXEL
	@ 020, 010 MSGET oGCod VAR cGCod SIZE 060, 010 OF oDlgCod COLORS 0, 16777215 PIXEL
	@ 010, 087 SAY oSay2 PROMPT "LOJA" SIZE 025, 007 OF oDlgCod COLORS 0, 16777215 PIXEL
	@ 020, 087 MSGET oGLoja VAR cGLoja SIZE 026, 010 OF oDlgCod COLORS 0, 16777215 PIXEL
	@ 039, 095 BUTTON oBConf PROMPT "Confirmar" SIZE 065, 017 OF oDlgCod PIXEL

	oBConf:bAction := {|| lOK := .T., oDlgCod:End()}

	ACTIVATE MSDIALOG oDlgCod CENTERED

	If lOK
		If !Empty(cGCod) .and. !Empty(cGLoja)

			If len(alltrim(cGCod)) != 6 .or. len(alltrim(cGLoja)) != 2
				FwAlertError("Coidog e Loja informado já utilizado em outro cadastro.","Codigo Duplicado")
				lRet := .F.
			Else
				dbSelectArea("SA2")
				dbSetOrder(1)
				If dbSeek(FWxFilial("SA2") + cGCod + cGLoja)
					FwAlertError("Coidog e Loja informado já utilizado em outro cadastro.","Codigo Duplicado")
					lRet := .F.
				Else

					cTRB := GetNextAlias()
					BeginSql Alias cTRB
                Select count(*) AS Reg
                From %Table:SZZ%
                Where %NotDel% and
                ZZ_IDREQ != %Exp:cIDReq% and
                ZZ_COD = %Exp:cGCod% and
                ZZ_LOJA = %Exp:cGLoja% and
                ZZ_STATUS != '4'
					EndSql

					dbSelectArea((cTRB))
					If (cTRB)->Reg != 0
						FwAlertError("Coidog e Loja informado já vinculado a uma Requisição de Cadastro em aberto.","Codigo Duplicado")
						lRet := .F.
					EndIf
					(cTRB)->(dbCloseArea())
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return({lRet,cGCod,cGLoja})

// --------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} vldSZZ02
Validacao campo coligado
@type function
@version 12.1.33
@author Leandro Cesar
@since 28/01/2023
@return logical, retorna se esta OK
/*/
User Function vldSZZ02()
	Local aRetAux := {}
	local lRet := .T.

	If  upper(alltrim(M->ZZ_UF)) == "EX" .and. M->ZZ_COLIG == 'S'
		aRetAux := CodColig()

		If (lRet := aRetAux[1])
			M->ZZ_COD := aRetAux[2]
			M->ZZ_LOJA := aRetAux[3]
		Else
			M->ZZ_COD  := space(TamSx3("A2_COD")[1])
			M->ZZ_LOJA := space(TamSx3("A2_LOJA")[1])
		Endif
	Else
		M->ZZ_COD  := space(TamSx3("A2_COD")[1])
		M->ZZ_LOJA := space(TamSx3("A2_LOJA")[1])
	EndIf

Return(lRet)


// ---------------------------------------------------------------------------------------------------------------------------------------------------

User Function BlqCadFor()
	local cGCNPJ    := space(TamSX3("A2_CGC")[1])
	local cGCodigo  := space(TamSX3("A2_COD")[1])
	local cGFornece := space(TamSX3("A2_NOME")[1])
	local cGLoja    := space(TamSX3("A2_LOJA")[1])
	local cMGMot    := ""
	local lConf     := .F.
	local oBCanc
	local oBConf
	local oGCNPJ
	local oGCodigo
	local oGFornece
	local oGLoja
	local oGMotivo
	local oGroup1
	local oGroup2
	local oMGMot
	local oSay1
	local oSay2
	local oSay3
	local oSay4

	Static oDlgBlqFor


	If !__cUserID $ GetMv("CL_BLQSA2",.F.,"000000")
		FwAlertError("Usuário sem permissão de realizar bloqueio de cadastro de fornecedor.","Bloqueio Fornecedor")
		return(.F.)
	EndIf

	DEFINE MSDIALOG oDlgBlqFor TITLE ">> Bloqueio Cadastro de Fornecedor <<" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

	@ 007, 005 GROUP oGroup1 TO 040, 116 PROMPT " Fornecedor (Codigo e Loja) " OF oDlgBlqFor COLOR 0, 16777215 PIXEL
	@ 015, 007 SAY oSay1 PROMPT "Codigo" SIZE 025, 007 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 023, 007 MSGET oGCodigo VAR cGCodigo SIZE 060, 010 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 015, 075 SAY oSay2 PROMPT "Loja" SIZE 025, 007 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 023, 075 MSGET oGLoja VAR cGLoja SIZE 033, 010 OF oDlgBlqFor COLORS 0, 16777215 PIXEL

	@ 007, 124 GROUP oGroup2 TO 040, 246 PROMPT " Fornecedor (CNPJ) " OF oDlgBlqFor COLOR 0, 16777215 PIXEL
	@ 015, 127 SAY oSay3 PROMPT "CNPJ" SIZE 025, 007 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 023, 127 MSGET oGCNPJ VAR cGCNPJ SIZE 114, 010 OF oDlgBlqFor COLORS 0, 16777215 PIXEL

	@ 045, 005 SAY oSay4 PROMPT "Fornecedor" SIZE 042, 007 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 053, 005 MSGET oGFornece VAR cGFornece SIZE 241, 010 OF oDlgBlqFor COLORS 0, 16777215 PIXEL


	@ 066, 002 GROUP oGMotivo TO 128, 247 PROMPT "   >>> Motivo Bloqueio Cadastro <<<   " OF oDlgBlqFor COLOR 0, 16777215 PIXEL
	@ 075, 005 GET oMGMot VAR cMGMot OF oDlgBlqFor MULTILINE SIZE 240, 050 COLORS 0, 16777215 HSCROLL PIXEL

	@ 131, 105 BUTTON oBConf PROMPT "Confirmar" SIZE 068, 015 OF oDlgBlqFor PIXEL
	@ 131, 178 BUTTON oBCanc PROMPT "Cancelar" SIZE 068, 015 OF oDlgBlqFor PIXEL

	oGCodigo:bValid := {|| validFor(@cGCodigo, @cGLoja, @cGCNPJ, @cGFornece)}
	oGCNPJ:bValid   := {|| validFor(@cGCodigo, @cGLoja, @cGCNPJ, @cGFornece)}
	oGCNPJ:bValid   := {|| validFor(@cGCodigo, @cGLoja, @cGCNPJ, @cGFornece)}
	oGFornece:disable()
	oBConf:bAction  := {|| iif(VldAltFor('2',{cMGMot}), (lConf := .t., oDlgBlqFor:End()), nil)}
	oBCanc:bAction  := {|| lConf := .F., oDlgBlqFor:End()}
	// oCMotivo:bChange   := {|| nMotivo := oCMotivo:nAt }

	ACTIVATE MSDIALOG oDlgBlqFor CENTERED

	If lConf
		If FWAlertYesNo("Confirma o bloqueio do cadastro de fornecedor [" + alltrim(cGFornece) + "]?","Bloqueio Fornecedor")

			cIdReq := GETSXENUM("SZZ","ZZ_IDREQ")
			If __lSX8
				ConfirmSX8()
			Endif

			cChaveUpd := SA2->(A2_COD + A2_LOJA)

			Reclock("SZZ",.T.)
			SZZ->ZZ_FILIAL  := FWxFilial("SZZ")
			SZZ->ZZ_COD     := SA2->A2_COD
			SZZ->ZZ_LOJA    := SA2->A2_LOJA
			SZZ->ZZ_NOME    := SA2->A2_NOME
			SZZ->ZZ_NREDUZ  := SA2->A2_NREDUZ
			SZZ->ZZ_END     := SA2->A2_END
			SZZ->ZZ_BAIRRO  := SA2->A2_BAIRRO
			SZZ->ZZ_UF      := SA2->A2_EST
			SZZ->ZZ_CODMUN  := SA2->A2_COD_MUN
			SZZ->ZZ_MUN     := SA2->A2_MUN
			SZZ->ZZ_TIPO    := iif(SA2->A2_TIPO == "F" .and. SA2->A2_TPESSOA == "FF","C",SA2->A2_TIPO)
			SZZ->ZZ_CNPJ    := SA2->A2_CGC
			SZZ->ZZ_COMPLEM := SA2->A2_COMPLEM
			SZZ->ZZ_COLIG   := SA2->A2_ZZCOLIG
			SZZ->ZZ_CEP     := SA2->A2_CEP
			SZZ->ZZ_DDD     := SA2->A2_DDD
			SZZ->ZZ_TEL     := SA2->A2_TEL
			SZZ->ZZ_INSCR   := SA2->A2_INSCR
			SZZ->ZZ_INSCRM  := SA2->A2_INSCRM
			SZZ->ZZ_PAIS    := SA2->A2_PAIS
			If SA2->A2_TPESSOA == "FF"
				SZZ->ZZ_EMAIL   := SA2->A2_EMAIL
				SZZ->ZZ_EMAIL   := SA2->A2_ZZPCEML
			Else
				SZZ->ZZ_EMAIL   := SA2->A2_ZZPCEML
			EndIf
			SZZ->ZZ_SIMPNAC := SA2->A2_SIMPNAC
			SZZ->ZZ_NATUREZ := SA2->A2_NATUREZ
			SZZ->ZZ_BANCO   := SA2->A2_BANCO
			SZZ->ZZ_AGENCIA := SA2->A2_AGENCIA
			SZZ->ZZ_NUMCON  := SA2->A2_NUMCON
			SZZ->ZZ_CODPAIS := SA2->A2_CODPAIS
			SZZ->ZZ_RECPIS  := SA2->A2_RECPIS
			SZZ->ZZ_RECCOFI := SA2->A2_RECCOFI
			SZZ->ZZ_RECCSLL := SA2->A2_RECCSLL
			SZZ->ZZ_RECISS  := SA2->A2_RECISS
			SZZ->ZZ_CONTRIB := SA2->A2_CONTRIB
			SZZ->ZZ_CALCIRF := SA2->A2_CALCIRF
			SZZ->ZZ_HOMOLOG := SA2->A2_ZZHOMOL
			SZZ->ZZ_TPPESSO := SA2->A2_TPESSOA
			SZZ->ZZ_NOMGEST := SA2->A2_NOMRESP
			SZZ->ZZ_PERFIL  := SA2->A2_XPERFIL
			SZZ->ZZ_EMPFLS  := SA2->A2_XEMPFLS
			SZZ->ZZ_COND    := SA2->A2_COND
			SZZ->ZZ_CONTA    := SA2->A2_CONTA
			SZZ->ZZ_IDREQ   := cIdReq

			SZZ->ZZ_STATUS  := "4"
			SZZ->ZZ_EMISSAO := dDataBase
			SZZ->ZZ_PUIDR   := cUserName
			SZZ->ZZ_OUTCLAS := SA2->A2_XOUTCLA
			SZZ->ZZ_CLASFOR := SA2->A2_XCLAFOR
			SZZ->ZZ_TPREG   := "B"
			SZZ->ZZ_SEQALT  := SeqAltFor()
			SZZ->ZZ_OBSERV  := alltrim(cUserName) + cValToChar(Date()) + " - " + substr(Time(),1,5) + " Motivo Bloqueio : " + FwCutOff(cMGMot, .T.)
			SZZ->ZZ_FILCAD  := FWCODFIL()

			SZZ->(MsUnlock())

			cQuery := ""
			cQuery += " UPDATE SA2 SET A2_MSBLQL = '1' FROM " + RetSqlName("SA2") + " SA2 WHERE D_E_L_E_T_ = '' AND A2_COD + A2_LOJA = '" + cChaveUpd + "' "
			TcSqlExec(cQuery)

			FWAlertSuccess("Cadastro bloqueado com sucesso.","Bloqueio de Cadastro")
		EndIf
	EndIf

Return


// ---------------------------------------------------------------------------------------------------------------------------------------------------

User Function ReqAltFor()
	local oBCanc
	local oBConf
	local oGCNPJ
	local cGCNPJ    := space(TamSX3("A2_CGC")[1])
	local oGFornece
	local cGFornece := space(TamSX3("A2_NOME")[1])
	local oGLoja
	local cGLoja    := space(TamSX3("A2_LOJA")[1])
	local oGCodigo
	local cGCodigo  := space(TamSX3("A2_COD")[1])
	local oGroup1
	local oGroup2
	local oSay1
	local oSay2
	local oSay3
	local oSay4
	local lConf     := .F.
	local oGMotivo
	local oMGMot
	local cMGMot    := ""
	local aMotAlt   := {"Dados Cadastrais",;
		"Dados Bancario",;
		"Razao Social",;
		"Dados Fiscais",;
		"Dados Flash Expense",;
		"Desbloqueio Fornecedor"}
	Local oCheckBo1
	Local lCheckBo1 := .F.
	Local oCheckBo2
	Local lCheckBo2 := .F.
	Local oCheckBo3
	Local lCheckBo3 := .F.
	Local oCheckBo4
	Local lCheckBo4 := .F.
	Local oCheckBo5
	Local lCheckBo5 := .F.
	Local oCheckBo6
	Local lCheckBo6 := .F.

	local nMotAlt   := 0
	local oCMotivo
	static oDlgAltFor

	DEFINE MSDIALOG oDlgAltFor TITLE ">> Solicitacao Alteracao Fornecedor <<" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

	@ 007, 005 GROUP oGroup1 TO 040, 116 PROMPT " Fornecedor (Codigo e Loja) " OF oDlgAltFor COLOR 0, 16777215 PIXEL
	@ 015, 007 SAY oSay1 PROMPT "Codigo" SIZE 025, 007 OF oDlgAltFor COLORS 0, 16777215 PIXEL
	@ 023, 007 MSGET oGCodigo VAR cGCodigo SIZE 060, 010 OF oDlgAltFor COLORS 0, 16777215 PIXEL
	@ 015, 075 SAY oSay2 PROMPT "Loja" SIZE 025, 007 OF oDlgAltFor COLORS 0, 16777215 PIXEL
	@ 023, 075 MSGET oGLoja VAR cGLoja SIZE 033, 010 OF oDlgAltFor COLORS 0, 16777215 PIXEL

	@ 007, 124 GROUP oGroup2 TO 040, 246 PROMPT " Fornecedor (CNPJ) " OF oDlgAltFor COLOR 0, 16777215 PIXEL
	@ 015, 127 SAY oSay3 PROMPT "CNPJ" SIZE 025, 007 OF oDlgAltFor COLORS 0, 16777215 PIXEL
	@ 023, 127 MSGET oGCNPJ VAR cGCNPJ SIZE 114, 010 OF oDlgAltFor COLORS 0, 16777215 PIXEL

	@ 045, 005 SAY oSay4 PROMPT "Fornecedor" SIZE 042, 007 OF oDlgAltFor COLORS 0, 16777215 PIXEL
	@ 053, 005 MSGET oGFornece VAR cGFornece SIZE 241, 010 OF oDlgAltFor COLORS 0, 16777215 PIXEL


	@ 066, 002 GROUP oGMotivo TO 128, 247 PROMPT "   >>> Motivo Alteracao Cadastro <<<   " OF oDlgAltFor COLOR 0, 16777215 PIXEL
	// @ 075, 005 GET oMGMot VAR cMGMot OF oDlgAltFor MULTILINE SIZE 240, 050 COLORS 0, 16777215 HSCROLL PIXEL
	// @ 075, 005 MSCOMBOBOX oCMotivo VAR nMotAlt ITEMS aMotAlt SIZE 240, 010 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 075, 014 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT aMotAlt[1] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 085, 014 CHECKBOX oCheckBo2 VAR lCheckBo2 PROMPT aMotAlt[2] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 095, 014 CHECKBOX oCheckBo3 VAR lCheckBo3 PROMPT aMotAlt[3] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 075, 130 CHECKBOX oCheckBo4 VAR lCheckBo4 PROMPT aMotAlt[4] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 085, 130 CHECKBOX oCheckBo5 VAR lCheckBo5 PROMPT aMotAlt[5] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
	@ 095, 130 CHECKBOX oCheckBo6 VAR lCheckBo6 PROMPT aMotAlt[6] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL


	@ 131, 105 BUTTON oBConf PROMPT "Confirmar" SIZE 068, 015 OF oDlgAltFor PIXEL
	@ 131, 178 BUTTON oBCanc PROMPT "Cancelar" SIZE 068, 015 OF oDlgAltFor PIXEL

	oGCodigo:bValid := {|| validFor(@cGCodigo, @cGLoja, @cGCNPJ, @cGFornece)}
	oGCNPJ:bValid   := {|| validFor(@cGCodigo, @cGLoja, @cGCNPJ, @cGFornece)}
	oGCNPJ:bValid   := {|| validFor(@cGCodigo, @cGLoja, @cGCNPJ, @cGFornece)}
	oGFornece:disable()
	oBConf:bAction  := {|| iif(VldAltFor('1',{lCheckBo1,lCheckBo2,lCheckBo3,lCheckBo4,lCheckBo5,lCheckBo6}), (lConf := .t., oDlgAltFor:End()), nil)}
	oBCanc:bAction  := {|| lConf := .F., oDlgAltFor:End()}

	ACTIVATE MSDIALOG oDlgAltFor CENTERED

	If lConf
		If FWAlertYesNo("Confirma gerar ficha de alteração de fornecedor para [" + alltrim(cGFornece) + "]?","Requisicao Alteracao Fornecedor")

			cGrpAlt := ""
			If lCheckBo1
				cGrpAlt += "1"
			EndIf
			If lCheckBo2
				cGrpAlt += "2""
			EndIf
			If lCheckBo3
				cGrpAlt += "3"
			EndIf
			If lCheckBo4
				cGrpAlt += "4"
			EndIf
			If lCheckBo5
				cGrpAlt += "5"
			EndIf
			If lCheckBo6
				cGrpAlt += "6"
			EndIf

			cIdReq := GETSXENUM("SZZ","ZZ_IDREQ")
			If __lSX8
				ConfirmSX8()
			Endif
			Reclock("SZZ",.T.)
			SZZ->ZZ_FILIAL  := FWxFilial("SZZ")
			SZZ->ZZ_COD     := SA2->A2_COD
			SZZ->ZZ_LOJA    := SA2->A2_LOJA
			SZZ->ZZ_NOME    := SA2->A2_NOME
			SZZ->ZZ_NREDUZ  := SA2->A2_NREDUZ
			SZZ->ZZ_END     := SA2->A2_END
			SZZ->ZZ_BAIRRO  := SA2->A2_BAIRRO
			SZZ->ZZ_UF      := SA2->A2_EST
			SZZ->ZZ_CODMUN  := SA2->A2_COD_MUN
			SZZ->ZZ_MUN     := SA2->A2_MUN
			SZZ->ZZ_TIPO    := iif(SA2->A2_TIPO == "F" .and. SA2->A2_TPESSOA == "FF","C",SA2->A2_TIPO)
			SZZ->ZZ_CNPJ    := SA2->A2_CGC
			SZZ->ZZ_COMPLEM := SA2->A2_COMPLEM
			SZZ->ZZ_COLIG   := SA2->A2_ZZCOLIG
			SZZ->ZZ_CEP     := SA2->A2_CEP
			SZZ->ZZ_DDD     := SA2->A2_DDD
			SZZ->ZZ_TEL     := SA2->A2_TEL
			SZZ->ZZ_INSCR   := SA2->A2_INSCR
			SZZ->ZZ_INSCRM  := SA2->A2_INSCRM
			SZZ->ZZ_PAIS    := SA2->A2_PAIS
			If SA2->A2_TPESSOA == "FF"
				SZZ->ZZ_EMAIL   := SA2->A2_EMAIL
			Else
				SZZ->ZZ_EMAIL   := SA2->A2_ZZPCEML
			EndIf
			SZZ->ZZ_SIMPNAC := SA2->A2_SIMPNAC
			SZZ->ZZ_NATUREZ := SA2->A2_NATUREZ
			SZZ->ZZ_BANCO   := SA2->A2_BANCO
			SZZ->ZZ_AGENCIA := SA2->A2_AGENCIA
			SZZ->ZZ_NUMCON  := SA2->A2_NUMCON
			SZZ->ZZ_CODPAIS := SA2->A2_CODPAIS
			SZZ->ZZ_RECPIS  := SA2->A2_RECPIS
			SZZ->ZZ_RECCOFI := SA2->A2_RECCOFI
			SZZ->ZZ_RECCSLL := SA2->A2_RECCSLL
			SZZ->ZZ_RECISS  := SA2->A2_RECISS
			SZZ->ZZ_CONTRIB := SA2->A2_CONTRIB
			SZZ->ZZ_CALCIRF := SA2->A2_CALCIRF
			SZZ->ZZ_HOMOLOG := SA2->A2_ZZHOMOL
			SZZ->ZZ_TPPESSO := SA2->A2_TPESSOA
			SZZ->ZZ_NOMGEST := SA2->A2_NOMRESP
			SZZ->ZZ_PERFIL  := SA2->A2_XPERFIL
			SZZ->ZZ_EMPFLS  := SA2->A2_XEMPFLS
			SZZ->ZZ_COND    := SA2->A2_COND
			SZZ->ZZ_CONTA    := SA2->A2_CONTA
			SZZ->ZZ_IDREQ   := cIdReq

			SZZ->ZZ_STATUS  := ""
			SZZ->ZZ_EMISSAO := dDataBase
			SZZ->ZZ_PUIDR   := cUserName
			SZZ->ZZ_OUTCLAS := SA2->A2_XOUTCLA
			SZZ->ZZ_CLASFOR := SA2->A2_XCLAFOR
			SZZ->ZZ_TPREG   := "A"
			SZZ->ZZ_SEQALT  := SeqAltFor()
			SZZ->ZZ_OBSERV  := cMGMot
			SZZ->ZZ_FILCAD  := FWCODFIL()
			SZZ->ZZ_GRPALT  := cGrpAlt

			SZZ->(MsUnlock())

		EndIf
	EndIf

Return
// --------------------------------------------------------------------------------------------------------------------------------------------------
static function VldAltFor(cp_Tipo,ap_Var)
	local lRet := .T.
	local nX := 1
	If cp_Tipo == '2'
		If Empty(ap_Var[1])
			lRet := .F.
			FWAlertInfo("Favor preencher o motivo da alteracao do cadastro de fornecedor.","Validacao AltFor")
		EndIf
	Else
		lEscolha := .F.
		For nX := 1 to len(ap_Var)
			If ap_Var[nX]
				lEscolha := .T.
			EndIf
		Next nX
		If !lEscolha
			lRet := .F.
			FWAlertInfo("Favor preencher o tipo de  alteracao a ser feito no cadastro de fornecedor.","Validacao AltFor")
		Else
			lRet := .T.
		EndIf
	EndIf

return (lRet)
// --------------------------------------------------------------------------------------------------------------------------------------------------
static function SeqAltFor()
	local cRetSeq := "001"

return (cRetSeq)

// --------------------------------------------------------------------------------------------------------------------------------------------------

static function validFor(cp_Codigo, c_Loja, cp_CNPJ, cp_Nome)

	local lRet := .T.
	local aArea := FWGetArea()

	If !Empty(cp_Codigo) .and. !Empty(c_Loja)
		dbSelectArea("SA2")
		dbSetOrder(1)
		If dbSeek(FWxFilial("SA2") + cp_Codigo + c_Loja)

			cp_CNPJ := SA2->A2_CGC
			cp_Nome := SA2->A2_NOME
		Else
			lRet := .F.
		EndIf
	ElseIf !Empty(cp_CNPJ)
		dbSelectArea("SA2")
		dbSetOrder(3)
		If dbSeek(FWxFilial("SA2") + cp_CNPJ)

			cp_Codigo := SA2->A2_COD
			c_Loja := SA2->A2_LOJA
			cp_Nome := SA2->A2_NOME
		Else
			lRet := .F.
		EndIf
	Else
	EndIf

	FWRestArea(aArea)
return(lRet)


// --------------------------------------------------------------------------------------------------------------------------------------------------

user function RptFornece()


	Local aParambox := {}



	aAdd(aParamBox,{1,"Data de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
	aAdd(aParamBox,{1,"Data até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02

	If !ParamBox(aParamBox,"Cadastro Fornecedor - COUPA",,,,,,,,ProcName(),.T.,.T.)
		return()
	Else
		dDataDe  := MV_PAR01
		dDataAte := MV_PAR02
	Endif

	FWMsgRun(, {|| ProcRpt(dDataDe, dDataAte)}, "Processando", "Processando ... ")

return
// --------------------------------------------------------------------------------------------------------------------------------------------------
Static Function ProcRpt(dDataDe, dDataAte)

	local cNome     := ""
	local cFldtemp  := "c:\Temp\"
	Local cFile     := "" //cFldtemp + cNome + ".xls"
	local cQuery    := ""
	local cSheet    := ""
	local cTitulo   := ""

	cNome   := "NovosFornecedores_"+dTos(dDataDe)+"__"+dTos(dDataAte)
	cFile   := cFldtemp + cNome + ".xls"
	cTitulo := "Novos Cadastros de Fornecedor - " + cValToChar(dDataDe) + " " + cValToChar(dDataAte)
	cSheet  := "Cadastros Fornecedor"

	FWMakeDir(cFldtemp,.F.)
	/*
	cQuery += " SELECT 'BR-PR-'+A2_COD+A2_LOJA as COLUNA_1
	cQuery += "	, ltrim(rtrim(A2_NOME)) as COLUNA_2
	cQuery += "	, 'BR-PR-'+A2_COD+A2_LOJA as COLUNA_3
	cQuery += "	, case when A2_MSBLQL = '1' THEN 'inactive' else 'active' end as COLUNA_4
	cQuery += "	, 'BR-PR' as COLUNA_5
	cQuery += "	, 'BR-PR' as COLUNA_6
	cQuery += "	, ltrim(rtrim(A2_CGC)) AS COLUNA_7
	cQuery += "	, CASE WHEN A2_TIPO = 'FF' THEN ltrim(rtrim(A2_EMAIL)) ELSE ltrim(rtrim(A2_ZZPCEML)) END AS COLUNA_8
	cQuery += "	, '' AS COLUNA_9
	cQuery += "	, '' AS COLUNA_10
	cQuery += "	, '' AS COLUNA_11
	cQuery += "	, '' AS COLUNA_12
	cQuery += "	, '' AS COLUNA_13
	cQuery += "	, ltrim(rtrim(A2_END)) AS COLUNA_14
	cQuery += "	, '' AS COLUNA_15
	cQuery += "	, ltrim(rtrim(A2_MUN)) AS COLUNA_16
	cQuery += "	, ltrim(rtrim(A2_EST)) AS COLUNA_17
	cQuery += "	, ltrim(rtrim(A2_CEP)) AS COLUNA_18
	cQuery += "	, 'BR' AS COLUNA_19
	cQuery += "	, 'none' AS COLUNA_20
	cQuery += "	, 'prompt' as COLUNA_21
	cQuery += "	, 'prompt' as COLUNA_22
	cQuery += "	, 'no' as COLUNA_23
	cQuery += "	, '' as COLUNA_24
	cQuery += "	, 'Invoice' as COLUNA_25
	cQuery += "	, ltrim(rtrim(isnull(ZZE_CODCOU,E4_DESCRI))) as COLUNA_26
	cQuery += "	, '' as COLUNA_27
	cQuery += "	, '' as COLUNA_28
	cQuery += "	, '' as COLUNA_29
	cQuery += "	, '' as COLUNA_30
	cQuery += "	, '' as COLUNA_31
	cQuery += "	, '' as COLUNA_32
	cQuery += "	, '' as COLUNA_33
	cQuery += "	, '' as COLUNA_34
	cQuery += "	, '' as COLUNA_35
	cQuery += "	, '' as COLUNA_36
	cQuery += "	, '' as COLUNA_37
	cQuery += "	, '' as COLUNA_38
	cQuery += "	, '' as COLUNA_39
	cQuery += "	, '' as COLUNA_40
	cQuery += "	, '' as COLUNA_41
	cQuery += "	, '' as COLUNA_42
	cQuery += "	, '' as COLUNA_43
	cQuery += "	, '' as COLUNA_44
	cQuery += "	, '' as COLUNA_45
	cQuery += "	, '' as COLUNA_46
	cQuery += "	, '' as COLUNA_47
	cQuery += "	, '' as COLUNA_48
	cQuery += "	, '' as COLUNA_49
	cQuery += "	, '' as COLUNA_50
	cQuery += "	, '' as COLUNA_51
	cQuery += "	, ltrim(rtrim(A2_INSCR)) AS COLUNA_52
	cQuery += "	, A2_ZZDTCRI AS COLUNA_53
	cQuery += "	, A2_XDTALT AS COLUNA_54
	cQuery += "	, A2_XFICHA AS COLUNA_55
	cQuery += "	, A2_XFILCAD AS COLUNA_56
	cQuery += "	FROM " + RetSqlName("SA2") + " SA2 WITH(NOLOCK)
	cQuery += "	left join " + RetSqlName("SE4") + " SE4 ON SE4.D_E_L_E_T_ = '' AND E4_CODIGO = A2_COND
	cQuery += "	left join " + RetSqlName("ZZE") + " ZZE ON ZZE.D_E_L_E_T_ = '' AND ZZE_CODPRO = E4_CODIGO
	cQuery += "	WHERE SA2.D_E_L_E_T_ = ''
	cQuery += "	AND ((A2_ZZDTCRI >= '" + dTos(dDataDe) + "'
	cQuery += "	AND A2_ZZDTCRI <= '" + dTos(dDataAte) + "')
	cQuery += "	OR (A2_XDTALT >= '" + dTos(dDataDe) + "'
	cQuery += "	AND A2_XDTALT <= '" + dTos(dDataAte) + "'))
	TcQuery cQuery New Alias (cTRB := GetNextAlias())
	*/

	cQuery:= " "
	cQuery += " SELECT 'BR-PR-'+A2_COD+A2_LOJA as COLUNA_1
	cQuery += " , ltrim(rtrim(A2_NOME)) as COLUNA_2
	cQuery += " , '' as COLUNA_3
	cQuery += " , 'BR-PR' as COLUNA_4
	cQuery += " , case when A2_MSBLQL = '1' THEN 'inactive' else 'active' end as COLUNA_5
	cQuery += " , '' AS COLUNA_6
	cQuery += " , 'BR-PR' as COLUNA_7
	cQuery += " , 'BR-PR-'+A2_COD+A2_LOJA as COLUNA_8
	cQuery += " , '' AS COLUNA_9
	cQuery += " , ltrim(rtrim(A2_CGC)) AS COLUNA_10
	cQuery += " , '' AS COLUNA_11
	cQuery += " , '' AS COLUNA_12
	cQuery += " , '' AS COLUNA_13
	cQuery += " , '' AS COLUNA_14
	cQuery += " , '' AS COLUNA_15
	cQuery += " , CASE WHEN A2_TIPO = 'FF' THEN ltrim(rtrim(A2_EMAIL)) ELSE ltrim(rtrim(A2_ZZPCEML)) END AS COLUNA_16
	cQuery += " , '' AS COLUNA_17
	cQuery += " , '' AS COLUNA_18
	cQuery += " , '' AS COLUNA_19
	cQuery += " , '' AS COLUNA_20
	cQuery += " , '' AS COLUNA_21
	cQuery += " , ltrim(rtrim(A2_END)) AS COLUNA_22
	cQuery += " , '' AS COLUNA_23
	cQuery += " , '' AS COLUNA_24
	cQuery += " , '' AS COLUNA_25
	cQuery += " , ltrim(rtrim(A2_MUN)) AS COLUNA_26
	cQuery += " , ltrim(rtrim(A2_EST)) AS COLUNA_27
	cQuery += " , ltrim(rtrim(A2_CEP)) AS COLUNA_28
	cQuery += " , 'BR' AS COLUNA_29
	cQuery += " , '' AS COLUNA_30
	cQuery += " , '' AS COLUNA_31
	cQuery += " , '' AS COLUNA_32
	cQuery += " , 'none' AS COLUNA_33
	cQuery += " , 'prompt' as COLUNA_34
	cQuery += " , 'prompt' as COLUNA_35
	cQuery += " , 'no' as COLUNA_36
	cQuery += " , '' AS COLUNA_37
	cQuery += " , '' AS COLUNA_38
	cQuery += " , 'Invoice' as COLUNA_39
	cQuery += " , '' AS COLUNA_40
	cQuery += " , ltrim(rtrim(isnull(ZZE_CODCOU,E4_DESCRI))) as COLUNA_41
	cQuery += " , '' AS COLUNA_42
	cQuery += " , '' AS COLUNA_43
	cQuery += " , '' AS COLUNA_44
	cQuery += " , '' AS COLUNA_45
	cQuery += " , '' AS COLUNA_46
	cQuery += " , '' AS COLUNA_47
	cQuery += " , '' AS COLUNA_48
	cQuery += " , '' AS COLUNA_49
	cQuery += " , '' AS COLUNA_50
	cQuery += " , '' AS COLUNA_51
	cQuery += " , '' AS COLUNA_52
	cQuery += " , '' AS COLUNA_53
	cQuery += " , '' AS COLUNA_54
	cQuery += " , '' AS COLUNA_55
	cQuery += " , '' AS COLUNA_56
	cQuery += " , '' AS COLUNA_57
	cQuery += " , '' AS COLUNA_58
	cQuery += " , '' AS COLUNA_59
	cQuery += " , '' AS COLUNA_60
	cQuery += " , '' AS COLUNA_61
	cQuery += " , '' AS COLUNA_62
	cQuery += " , '' AS COLUNA_63
	cQuery += " , '' AS COLUNA_64
	cQuery += " , '' AS COLUNA_65
	cQuery += " , '' AS COLUNA_66
	cQuery += " , '' AS COLUNA_67
	cQuery += " , '' AS COLUNA_68
	cQuery += " , '' AS COLUNA_69
	cQuery += " , '' AS COLUNA_70
	cQuery += " , '' AS COLUNA_71
	cQuery += " , '' AS COLUNA_72
	cQuery += " , '' AS COLUNA_73
	cQuery += " , '' AS COLUNA_74
	cQuery += " , '' AS COLUNA_75
	cQuery += " , '' AS COLUNA_76
	cQuery += " , '' AS COLUNA_77
	cQuery += " , '' AS COLUNA_78
	cQuery += " , '' AS COLUNA_79
	cQuery += " , '' AS COLUNA_80
	cQuery += " , '' AS COLUNA_81
	cQuery += " , '' AS COLUNA_82
	cQuery += " , '' AS COLUNA_83
	cQuery += " , '' AS COLUNA_84
	cQuery += " , '' AS COLUNA_85
	cQuery += " , '' AS COLUNA_86
	cQuery += " , '' AS COLUNA_87
	cQuery += " , '' AS COLUNA_88
	cQuery += " , '' AS COLUNA_89
	cQuery += " , '' AS COLUNA_90
	cQuery += " , '' AS COLUNA_91
	cQuery += " , '' AS COLUNA_92
	cQuery += " , '' AS COLUNA_93
	cQuery += " , '' AS COLUNA_94
	cQuery += " , '' AS COLUNA_95
	cQuery += " , '' AS COLUNA_96
	cQuery += " , ltrim(rtrim(A2_INSCR)) AS COLUNA_97
	cQuery += " , '' AS COLUNA_98
	cQuery += " , '' AS COLUNA_99
	cQuery += " , '' AS COLUNA_100
	cQuery += " , '' AS COLUNA_101
	cQuery += " , '' AS COLUNA_102
	cQuery += " , '' AS COLUNA_103
	cQuery += " , A2_ZZDTCRI AS COLUNA_104
	cQuery += " , A2_XDTALT AS COLUNA_105
	cQuery += " , A2_XFICHA AS COLUNA_106
	cQuery += " , A2_XFILCAD AS COLUNA_107
	cQuery += " FROM " + RetSqlName("SA2") + " SA2 WITH(NOLOCK)
	cQuery += " left join " + RetSqlName("SE4") + " SE4 ON SE4.D_E_L_E_T_ = '' AND E4_CODIGO = A2_COND
	cQuery += " left join " + RetSqlName("ZZE") + " ZZE ON ZZE.D_E_L_E_T_ = '' AND ZZE_CODPRO = E4_CODIGO
	cQuery += " WHERE SA2.D_E_L_E_T_ = ''
	cQuery += " AND ((A2_ZZDTCRI >= '" + dTos(dDataDe) + "'
	cQuery += " AND A2_ZZDTCRI <= '" + dTos(dDataAte) + "')
	cQuery += " OR (A2_XDTALT >= '" + dTos(dDataDe) + "'
	cQuery += " AND A2_XDTALT <= '" + dTos(dDataAte) + "'))
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
		/*
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Name"                                             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Display Name"                                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier Number"                                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Status"                                           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Content Groups"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Enterprise Code"                                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Account number"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Email"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Phone Work"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Phone Mobile"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Phone Fax"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Name Given"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Name Family"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Street1"                          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Street2"                          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address City"                             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address State"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Postal Code"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Country Code"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Invoice Matching Level"                           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO Method"                                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO Change Method"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Buyer Hold"                                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO Email"                                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Payment Method"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Payment Terms"                                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Shipping Terms"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML URL"                                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Domain"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Identity"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Supplier Domain"                          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Supplier Identity"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Secret"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Protocol"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML SSL Version"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Disable Cert Verify"                              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML HTTP Basic Auth Username"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML HTTP Basic Auth Password"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow cXML Invoicing"                             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing - Supplier Domain"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing - Supplier Identity"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing - Buyer Domain"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing - Buyer Identity"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing Shared Key"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Hold invoices for AP review"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"On Hold"                                          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow Invoicing From CSN"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Create Invoices with No Backing Document"         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow Invoicing Choose Billing Account From CSN"  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow Non-Backed Lines on PO Invoices"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Group Supplier Name"                              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier notes"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Inc"                                         ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Alt"                                         ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Ficha Cad"                                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Filial Cad"                                       ,1,1)
		*/
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Name"                                             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Display Name"                                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Id"                                     			,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Content Groups"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Status"                                     		,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Commodity"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Enterprise Code"                                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier Number"                                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Parent Company"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Account Number"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tax ID"                                     		,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tax Code"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"DUNS"                                     		,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Online Store URL"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Online Store Login"                               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Email"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Phone Work"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Phone Mobile"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Phone Fax"                       	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Name Given"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Contact Name Family"                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Street1"                         	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Street2"                         	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Street3"                         	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Street4"                         	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address City"                             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address State"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Postal Code"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Country Code"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Vat Number"                       ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Vat Country Code"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Primary Address Local Tax Number"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Invoice Matching Level"                           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO Method"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO Change Method"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Buyer Hold"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Default Locale"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO Email"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Payment Method"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Remit-To Requirements"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Payment Terms"                                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Shipping Terms"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML URL"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Domain"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Identity"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Supplier Domain"                          ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Supplier Identity"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML Protocol"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML SSL Version"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Disable Cert Verify"                              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"PO cXML HTTP Basic Auth Username"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow cXML Invoicing"                             ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing - Supplier Domain"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing - Supplier Identity"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing - Buyer Domain"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing - Buyer Identity"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"cXML Invoicing Shared Key"                  		,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Savings (%)"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"On Hold"                                     		,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Invoice Emails"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Account Types"                                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Always Route Invoices From This Supplier For Approval",1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow Invoicing From CSN"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Create Invoices with No Backing Document"         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow Invoicing Choose Billing Account From CSN"  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Restricted account types"                         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Preferred Language"                               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Preferred Currency"                               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Country of Operation Code"                      	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow Non-Backed Lines on PO Invoices"            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Website"                                     		,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Email domain"                                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Default contact email"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Hold invoices for AP review"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow CSP Access without Two Factor"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Request change orders"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Send Email Added Notification"                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Enable for Early Payments"                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Early Payment Programs"                           ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supply Chain Finance Configurations"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Only pay financed invoices via Coupa Pay"         ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Parent Business Entity Name"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tags"                                     		,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Preferred Commodities"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"One Time Supplier"                                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Scope Three Emissions"                            ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Last Invited Email"                               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Last Invited At"                                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Last Reminded At"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Proxy ID"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier website"                                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Do Not Offer Static Discounting"                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Create Credit Notes without Backing Invoice"      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Allow supplier to propose item substitute on Order Confirmations"                                     			,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Group Supplier Name"                              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"VAT Group"                                     	,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier Notes"                                   ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Enterprise Country"                               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier Type - to be fixed"                      ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier Diversity Classification"                ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Supplier Type"                                    ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Default Bank ID"                                  ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Legal Entity"                                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Inc"                                         ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Data Alt"                                         ,1,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Ficha Cad"                                        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Filial Cad"                                       ,1,1)

		while (cTRB)->(!eof())

			cCNPJ := alltrim((cTRB)->COLUNA_10)
			cCNPJ := iif(len(cCNPJ) == 14, transform(cCNPJ,"@R 99.999.999/9999-99"), transform(cCNPJ,"@R 999.999.999-99") )

			/*
			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->COLUNA_1,;
				(cTRB)->COLUNA_2,;
				(cTRB)->COLUNA_3,;
				(cTRB)->COLUNA_4,;
				(cTRB)->COLUNA_5,;
				(cTRB)->COLUNA_6,;
				cCNPJ,;
				(cTRB)->COLUNA_8,;
				(cTRB)->COLUNA_9,;
				(cTRB)->COLUNA_10,;
				(cTRB)->COLUNA_11,;
				(cTRB)->COLUNA_12,;
				(cTRB)->COLUNA_13,;
				(cTRB)->COLUNA_14,;
				(cTRB)->COLUNA_15,;
				(cTRB)->COLUNA_16,;
				(cTRB)->COLUNA_17,;
				(cTRB)->COLUNA_18,;
				(cTRB)->COLUNA_19,;
				(cTRB)->COLUNA_20,;
				(cTRB)->COLUNA_21,;
				(cTRB)->COLUNA_22,;
				(cTRB)->COLUNA_23,;
				(cTRB)->COLUNA_24,;
				(cTRB)->COLUNA_25,;
				(cTRB)->COLUNA_26,;
				(cTRB)->COLUNA_27,;
				(cTRB)->COLUNA_28,;
				(cTRB)->COLUNA_29,;
				(cTRB)->COLUNA_30,;
				(cTRB)->COLUNA_31,;
				(cTRB)->COLUNA_32,;
				(cTRB)->COLUNA_33,;
				(cTRB)->COLUNA_34,;
				(cTRB)->COLUNA_35,;
				(cTRB)->COLUNA_36,;
				(cTRB)->COLUNA_37,;
				(cTRB)->COLUNA_38,;
				(cTRB)->COLUNA_39,;
				(cTRB)->COLUNA_40,;
				(cTRB)->COLUNA_41,;
				(cTRB)->COLUNA_42,;
				(cTRB)->COLUNA_43,;
				(cTRB)->COLUNA_44,;
				(cTRB)->COLUNA_45,;
				(cTRB)->COLUNA_46,;
				(cTRB)->COLUNA_47,;
				(cTRB)->COLUNA_48,;
				(cTRB)->COLUNA_49,;
				(cTRB)->COLUNA_50,;
				(cTRB)->COLUNA_51,;
				(cTRB)->COLUNA_52,;
				sTod((cTRB)->COLUNA_53),;
				sTod((cTRB)->COLUNA_54),;
				(cTRB)->COLUNA_55,;
				(cTRB)->COLUNA_56})
				*/


			oFWMsExcel:AddRow(cSheet,cTitulo,{(cTRB)->COLUNA_1,;
				(cTRB)->COLUNA_2,;
				(cTRB)->COLUNA_3,;
				(cTRB)->COLUNA_4,;
				(cTRB)->COLUNA_5,;
				(cTRB)->COLUNA_6,;
				(cTRB)->COLUNA_7,;
				(cTRB)->COLUNA_8,;
				(cTRB)->COLUNA_9,;
				cCNPJ,;
				(cTRB)->COLUNA_11,;
				(cTRB)->COLUNA_12,;
				(cTRB)->COLUNA_13,;
				(cTRB)->COLUNA_14,;
				(cTRB)->COLUNA_15,;
				(cTRB)->COLUNA_16,;
				(cTRB)->COLUNA_17,;
				(cTRB)->COLUNA_18,;
				(cTRB)->COLUNA_19,;
				(cTRB)->COLUNA_20,;
				(cTRB)->COLUNA_21,;
				(cTRB)->COLUNA_22,;
				(cTRB)->COLUNA_23,;
				(cTRB)->COLUNA_24,;
				(cTRB)->COLUNA_25,;
				(cTRB)->COLUNA_26,;
				(cTRB)->COLUNA_27,;
				(cTRB)->COLUNA_28,;
				(cTRB)->COLUNA_29,;
				(cTRB)->COLUNA_30,;
				(cTRB)->COLUNA_31,;
				(cTRB)->COLUNA_32,;
				(cTRB)->COLUNA_33,;
				(cTRB)->COLUNA_34,;
				(cTRB)->COLUNA_35,;
				(cTRB)->COLUNA_36,;
				(cTRB)->COLUNA_37,;
				(cTRB)->COLUNA_38,;
				(cTRB)->COLUNA_39,;
				(cTRB)->COLUNA_40,;
				(cTRB)->COLUNA_41,;
				(cTRB)->COLUNA_42,;
				(cTRB)->COLUNA_43,;
				(cTRB)->COLUNA_44,;
				(cTRB)->COLUNA_45,;
				(cTRB)->COLUNA_46,;
				(cTRB)->COLUNA_47,;
				(cTRB)->COLUNA_48,;
				(cTRB)->COLUNA_49,;
				(cTRB)->COLUNA_50,;
				(cTRB)->COLUNA_51,;
				(cTRB)->COLUNA_52,;
				(cTRB)->COLUNA_53,;
				(cTRB)->COLUNA_54,;
				(cTRB)->COLUNA_55,;
				(cTRB)->COLUNA_56,;
				(cTRB)->COLUNA_57,;
				(cTRB)->COLUNA_58,;
				(cTRB)->COLUNA_59,;
				(cTRB)->COLUNA_60,;
				(cTRB)->COLUNA_61,;
				(cTRB)->COLUNA_62,;
				(cTRB)->COLUNA_63,;
				(cTRB)->COLUNA_64,;
				(cTRB)->COLUNA_65,;
				(cTRB)->COLUNA_66,;
				(cTRB)->COLUNA_67,;
				(cTRB)->COLUNA_68,;
				(cTRB)->COLUNA_69,;
				(cTRB)->COLUNA_70,;
				(cTRB)->COLUNA_71,;
				(cTRB)->COLUNA_72,;
				(cTRB)->COLUNA_73,;
				(cTRB)->COLUNA_74,;
				(cTRB)->COLUNA_75,;
				(cTRB)->COLUNA_76,;
				(cTRB)->COLUNA_77,;
				(cTRB)->COLUNA_78,;
				(cTRB)->COLUNA_79,;
				(cTRB)->COLUNA_80,;
				(cTRB)->COLUNA_81,;
				(cTRB)->COLUNA_82,;
				(cTRB)->COLUNA_83,;
				(cTRB)->COLUNA_84,;
				(cTRB)->COLUNA_85,;
				(cTRB)->COLUNA_86,;
				(cTRB)->COLUNA_87,;
				(cTRB)->COLUNA_88,;
				(cTRB)->COLUNA_89,;
				(cTRB)->COLUNA_90,;
				(cTRB)->COLUNA_91,;
				(cTRB)->COLUNA_92,;
				(cTRB)->COLUNA_93,;
				(cTRB)->COLUNA_94,;
				(cTRB)->COLUNA_95,;
				(cTRB)->COLUNA_96,;
				(cTRB)->COLUNA_97,;
				(cTRB)->COLUNA_98,;
				(cTRB)->COLUNA_99,;
				(cTRB)->COLUNA_100,;
				(cTRB)->COLUNA_101,;
				(cTRB)->COLUNA_102,;
				(cTRB)->COLUNA_103,;
				sTod((cTRB)->COLUNA_104),;
				sTod((cTRB)->COLUNA_105),;
				(cTRB)->COLUNA_106,;
				(cTRB)->COLUNA_107})
			(cTRB)->(dbSkip())
		EndDo

		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cFile)



		If ApOleClient("MSEXCEL") .and. File(cFile) .and. !IsBlind()
			//Abrindo o excel e abrindo o arquivo xml
			oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
			oExcel:WorkBooks:Open(cFile)     //Abre uma planilha
			oExcel:SetVisible(.T.)              //Visualiza a planilha
			oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
		EndIf



	EndIf
	(cTRB)->(dbCloseArea())





return()


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function FGerFor()

	Local nOpc := 3 // ----> Inclusão
	Local _cTipo:= 1
	local cQuery := "" as character
	public lGerFAuto := .T.

	cQuery := ""
	cQuery += " SELECT * FROM " + RetSqlname("SZZ") +" SZZ "
	cQuery += " WHERE SZZ.D_E_L_E_T_ = ''
	cQuery += "  AND ZZ_STATUS = '1'
	//cQuery += "  AND ZZ_IDREQ = '001228'
	TcQuery cQuery New Alias (cTRA := GetNextAlias())


	dbSelectArea((cTRA))
	(cTRA)->(dbGoTop())
	If (cTRA)->(!eof())
		while (cTRA)->(!eof())
			nOpc := 3
			lGeraCad := .t.
			cDocumento := (cTRA)->ZZ_IDREQ

			cQuery := ""
			cQuery += " SELECT COUNT(*) AS REG FROM " + RetSqlName("SZ5") + " SZ5
			cQuery += "  WHERE SZ5.D_E_L_E_T_ = ''
			cQuery += "    AND Z5_NUM = '" + cDocumento + "'
			cQuery += "    AND Z5_TIPO = 'F'
			cQuery += "    AND Z5_STATUS != 'A'
			TcQuery cQuery New Alias (cTRB := GetNextAlias())

			dbSelectArea((cTRB))
			If (cTRB)->REG != 0
				lGeraCad := .F.
			EndIf
			(cTRB)->(dbCloseArea())

			If lGeraCad


				aRet := {}

				dbSelectArea("SZZ")
				dbSetOrder(1)
				dbSeek(FWxFilial("SZZ") + cDocumento)
				cCNPJ := SZZ->ZZ_CNPJ
				If SZZ->ZZ_TPREG == 'A'
					dbSelectArea("SA2")
					if SZZ->ZZ_UF == "EX"
						_cTipo:= 2
						dbSetOrder(1)
						If dbSeek(FWxFilial("SA2") + SZZ->ZZ_COD + SZZ->ZZ_LOJA)
							nOpc := 4
							If SA2->A2_COD != SZZ->ZZ_COD
								reclock("SZZ",.F.)
								SZZ->ZZ_COD  := SA2->A2_COD
								SZZ->ZZ_LOJA := SA2->A2_LOJA
								SZZ->(MsUnlock())
							EndIf
							aRet := {{SZZ->ZZ_COD, SZZ->ZZ_LOJA}}
						Else
							reclock("SZZ",.F.)
							SZZ->ZZ_TPREG := "I"
							SZZ->(MsUnlock())
						EndIf
					else
						dbSetOrder(3)
						If dbSeek(FWxFilial("SA2") + cCNPJ)
							nOpc := 4
							If SA2->A2_COD != SZZ->ZZ_COD
								reclock("SZZ",.F.)
								SZZ->ZZ_COD  := SA2->A2_COD
								SZZ->ZZ_LOJA := SA2->A2_LOJA
								SZZ->(MsUnlock())
							EndIf
							aRet := {{SZZ->ZZ_COD, SZZ->ZZ_LOJA}}
						Else
							reclock("SZZ",.F.)
							SZZ->ZZ_TPREG := "I"
							SZZ->(MsUnlock())
						EndIf
					endif
				EndIf

				oModel := FWLoadModel('MATA020')

				oModel:SetOperation(nOpc)
				oModel:Activate()

				If SZZ->ZZ_TPREG != 'A'
					If SZZ->ZZ_UF == "EX" .and. SZZ->ZZ_COLIG == 'S' .and. !Empty(SZZ->ZZ_COD) .and. !Empty(SZZ->ZZ_LOJA)
						aRet := {{SZZ->ZZ_COD, SZZ->ZZ_LOJA}}
					Else
						aRet := U_RetCodFor(SZZ->ZZ_CNPJ, SZZ->ZZ_UF, SZZ->ZZ_TIPO)
					EndIf
				EndIf

				oModel:SetValue( 'SA2MASTER' , 'A2_COD'         , aRet[1,1]             )
				oModel:SetValue( 'SA2MASTER' , 'A2_LOJA'        , aRet[1,2]             )
				oModel:SetValue( 'SA2MASTER' , 'A2_NOME'        , SZZ->ZZ_NOME          )
				oModel:SetValue( 'SA2MASTER' , 'A2_NREDUZ'      , SZZ->ZZ_NREDUZ        )
				oModel:SetValue( 'SA2MASTER' , 'A2_END'         , SZZ->ZZ_END           )
				oModel:SetValue( 'SA2MASTER' , 'A2_BAIRRO'      , SZZ->ZZ_BAIRRO        )
				oModel:SetValue( 'SA2MASTER' , 'A2_EST'         , SZZ->ZZ_UF            )
				If alltrim(SZZ->ZZ_UF) == 'EX'
					oModel:SetValue( 'SA2MASTER' , 'A2_GRPTRIB' , 'EX1'                 )
				EndIf
				oModel:SetValue( 'SA2MASTER' , 'A2_COD_MUN'     , SZZ->ZZ_CODMUN        )
				oModel:SetValue( 'SA2MASTER' , 'A2_MUN'         , SZZ->ZZ_MUN           )
				oModel:SetValue( 'SA2MASTER' , 'A2_TIPO'        , IIF(SZZ->ZZ_TIPO=='C','F',SZZ->ZZ_TIPO)        )
				oModel:SetValue( 'SA2MASTER' , 'A2_CGC'         , SZZ->ZZ_CNPJ          )
				oModel:SetValue( 'SA2MASTER' , 'A2_COMPLEM'     , SZZ->ZZ_COMPLEM       )
				oModel:SetValue( 'SA2MASTER' , 'A2_ZZCOLIG'     , SZZ->ZZ_COLIG         )
				oModel:SetValue( 'SA2MASTER' , 'A2_CEP'         , SZZ->ZZ_CEP           )
				oModel:SetValue( 'SA2MASTER' , 'A2_DDD'         , SZZ->ZZ_DDD           )
				oModel:SetValue( 'SA2MASTER' , 'A2_TEL'         , SZZ->ZZ_TEL           )
				oModel:SetValue( 'SA2MASTER' , 'A2_INSCR'       , SZZ->ZZ_INSCR         )
				oModel:SetValue( 'SA2MASTER' , 'A2_INSCRM'      , SZZ->ZZ_INSCRM        )
				oModel:SetValue( 'SA2MASTER' , 'A2_PAIS'        , SZZ->ZZ_PAIS          )
				If SZZ->ZZ_TPPESSO == 'FF'
					oModel:SetValue( 'SA2MASTER' , 'A2_EMAIL'   , lower(substr(alltrim(SZZ->ZZ_EMAIL),1,70))         )
					oModel:SetValue( 'SA2MASTER' , 'A2_ZZPCEML' , lower(SZZ->ZZ_EMAIL)  )
				Else
					oModel:SetValue( 'SA2MASTER' , 'A2_ZZPCEML' , lower(SZZ->ZZ_EMAIL)  )
				EndIf
				oModel:SetValue( 'SA2MASTER' , 'A2_SIMPNAC'     , SZZ->ZZ_SIMPNAC       )
				oModel:SetValue( 'SA2MASTER' , 'A2_NATUREZ'     , SZZ->ZZ_NATUREZ       )
				oModel:SetValue( 'SA2MASTER' , 'A2_BANCO'       , SZZ->ZZ_BANCO         )
				oModel:SetValue( 'SA2MASTER' , 'A2_AGENCIA'     , SZZ->ZZ_AGENCIA       )
				oModel:SetValue( 'SA2MASTER' , 'A2_NUMCON'      , SZZ->ZZ_NUMCON        )
				oModel:SetValue( 'SA2MASTER' , 'A2_CODPAIS'     , SZZ->ZZ_CODPAIS       )
				oModel:SetValue( 'SA2MASTER' , 'A2_RECPIS'      , SZZ->ZZ_RECPIS        )
				oModel:SetValue( 'SA2MASTER' , 'A2_RECCOFI'     , SZZ->ZZ_RECCOFI       )
				oModel:SetValue( 'SA2MASTER' , 'A2_RECCSLL'     , SZZ->ZZ_RECCSLL       )
				oModel:SetValue( 'SA2MASTER' , 'A2_RECISS'      , SZZ->ZZ_RECISS        )
				oModel:SetValue( 'SA2MASTER' , 'A2_CONTRIB'     , SZZ->ZZ_CONTRIB       )
				oModel:SetValue( 'SA2MASTER' , 'A2_CALCIRF'     , SZZ->ZZ_CALCIRF       )
				oModel:SetValue( 'SA2MASTER' , 'A2_ZZHOMOL'     , SZZ->ZZ_HOMOLOG       )
				oModel:SetValue( 'SA2MASTER' , 'A2_TPESSOA'     , SZZ->ZZ_TPPESSO       )
				oModel:SetValue( 'SA2MASTER' , 'A2_NOMRESP'     , SZZ->ZZ_NOMGEST       )
				oModel:SetValue( 'SA2MASTER' , 'A2_XPERFIL'     , SZZ->ZZ_PERFIL        )
				oModel:SetValue( 'SA2MASTER' , 'A2_XEMPFLS'     , SZZ->ZZ_EMPFLS        )
				oModel:SetValue( 'SA2MASTER' , 'A2_COND'        , SZZ->ZZ_COND          )
				oModel:SetValue( 'SA2MASTER' , 'A2_XFICHA'      , SZZ->ZZ_IDREQ         )
				oModel:SetValue( 'SA2MASTER' , 'A2_XOUTCLA'     , SZZ->ZZ_OUTCLAS       )
				oModel:SetValue( 'SA2MASTER' , 'A2_XCLAFOR'     , SZZ->ZZ_CLASFOR       )

				If SZZ->ZZ_TPREG == 'A'
					oModel:SetValue( 'SA2MASTER' , 'A2_CONTA'   , SZZ->ZZ_CONTA         )
					oModel:SetValue( 'SA2MASTER' , 'A2_MSBLQL'   , '2'                  )
					If SA2->(FieldPos("A2_XDTALT")) > 0
						oModel:SetValue( 'SA2MASTER' , 'A2_XDTALT'   , dDataBase        )
					EndIf
				Endif

				If SA2->(FieldPos("A2_XFILCAD")) > 0
					oModel:SetValue( 'SA2MASTER' , 'A2_XFILCAD'   , SZZ->ZZ_FILCAD       )
				EndIf

				If oModel:VldData()
					oModel:CommitData()

					//realiza o vinculo com os arquivos anexos
					DuplicF(aRet[1,1]+aRet[1,2], SZZ->ZZ_IDREQ)

					reclock("SZZ",.F.)
					SZZ->ZZ_COD     := aRet[1,1]
					SZZ->ZZ_LOJA    := aRet[1,2]
					SZZ->ZZ_STATUS  := '4'
					SZZ->(MsUnlock())

					// envia e-mail
					EnviaNt(cCNPJ, cDocumento, 'CADASTRO APROVADO',_cTipo,SZZ->ZZ_COD, SZZ->ZZ_LOJA)
				Else
					VarInfo("Erro ao incluir",oModel:GetErrorMessage())
				EndIf

				oModel:DeActivate()
				oModel:Destroy()
				oModel := NIL
			Endif
			(cTRA)->(dbSkip())
		EndDo
	EndIf


return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------


User function ReclasAF()
	local oBCanc
	local oBConf
	local oGCNPJ
	local cGCNPJ    := space(TamSX3("A2_CGC")[1])
	local oGFornece
	local cGFornece := space(TamSX3("A2_NOME")[1])
	local oGLoja
	local cGLoja    := space(TamSX3("A2_LOJA")[1])
	local oGCodigo
	local cGCodigo  := space(TamSX3("A2_COD")[1])
	local oGroup1
	local oGroup2
	local oSay1
	local oSay2
	local oSay3
	local oSay4
	local lConf     := .F.
	local oGMotivo
	local aMotAlt   := {"Dados Cadastrais",;
		"Dados Bancario",;
		"Razao Social",;
		"Dados Fiscais",;
		"Dados Flash Expense",;
		"Desbloqueio Fornecedor"}
	Local oCheckBo1
	Local lCheckBo1 := .F.
	Local oCheckBo2
	Local lCheckBo2 := .F.
	Local oCheckBo3
	Local lCheckBo3 := .F.
	Local oCheckBo4
	Local lCheckBo4 := .F.
	Local oCheckBo5
	Local lCheckBo5 := .F.
	Local oCheckBo6
	Local lCheckBo6 := .F.
	static oDlgAltFor

	If FWAlertYesNo("Deseja reclassificar alteração da ficha de fornecedor para [" + alltrim(SZZ->ZZ_NOME) + "]?","Reclassificacao Alteracao Fornecedor")


		If !Empty(SZZ->ZZ_STATUS)
			FwAlertError("Nao e possivel reclassificar uma ficha em processo de aprovacao ou ja aprovada.","Aviso")
			return(.f.)
		EndIf

		cGCNPJ    := SZZ->ZZ_CNPJ
		cGFornece := SZZ->ZZ_NOME
		cGLoja    := SZZ->ZZ_LOJA
		cGCodigo  := SZZ->ZZ_COD

		If "1" $ SZZ->ZZ_GRPALT
			lCheckBo1 := .T.
		EndIf

		If "2" $ SZZ->ZZ_GRPALT
			lCheckBo2 := .T.
		EndIf

		If "3" $ SZZ->ZZ_GRPALT
			lCheckBo3 := .T.
		EndIf

		If "4" $ SZZ->ZZ_GRPALT
			lCheckBo4 := .T.
		EndIf

		If "5" $ SZZ->ZZ_GRPALT
			lCheckBo5 := .T.
		EndIf

		If "6" $ SZZ->ZZ_GRPALT
			lCheckBo6 := .T.
		EndIf

		DEFINE MSDIALOG oDlgAltFor TITLE ">> Reclassificacao Alteracao Fornecedor <<" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

		@ 007, 005 GROUP oGroup1 TO 040, 116 PROMPT " Fornecedor (Codigo e Loja) " OF oDlgAltFor COLOR 0, 16777215 PIXEL
		@ 015, 007 SAY oSay1 PROMPT "Codigo" SIZE 025, 007 OF oDlgAltFor COLORS 0, 16777215 PIXEL
		@ 023, 007 MSGET oGCodigo VAR cGCodigo SIZE 060, 010 OF oDlgAltFor COLORS 0, 16777215 PIXEL
		@ 015, 075 SAY oSay2 PROMPT "Loja" SIZE 025, 007 OF oDlgAltFor COLORS 0, 16777215 PIXEL
		@ 023, 075 MSGET oGLoja VAR cGLoja SIZE 033, 010 OF oDlgAltFor COLORS 0, 16777215 PIXEL

		@ 007, 124 GROUP oGroup2 TO 040, 246 PROMPT " Fornecedor (CNPJ) " OF oDlgAltFor COLOR 0, 16777215 PIXEL
		@ 015, 127 SAY oSay3 PROMPT "CNPJ" SIZE 025, 007 OF oDlgAltFor COLORS 0, 16777215 PIXEL
		@ 023, 127 MSGET oGCNPJ VAR cGCNPJ SIZE 114, 010 OF oDlgAltFor COLORS 0, 16777215 PIXEL

		@ 045, 005 SAY oSay4 PROMPT "Fornecedor" SIZE 042, 007 OF oDlgAltFor COLORS 0, 16777215 PIXEL
		@ 053, 005 MSGET oGFornece VAR cGFornece SIZE 241, 010 OF oDlgAltFor COLORS 0, 16777215 PIXEL


		@ 066, 002 GROUP oGMotivo TO 128, 247 PROMPT "   >>> Motivo Alteracao Cadastro <<<   " OF oDlgAltFor COLOR 0, 16777215 PIXEL
		@ 075, 014 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT aMotAlt[1] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
		@ 085, 014 CHECKBOX oCheckBo2 VAR lCheckBo2 PROMPT aMotAlt[2] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
		@ 095, 014 CHECKBOX oCheckBo3 VAR lCheckBo3 PROMPT aMotAlt[3] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
		@ 075, 130 CHECKBOX oCheckBo4 VAR lCheckBo4 PROMPT aMotAlt[4] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
		@ 085, 130 CHECKBOX oCheckBo5 VAR lCheckBo5 PROMPT aMotAlt[5] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL
		@ 095, 130 CHECKBOX oCheckBo6 VAR lCheckBo6 PROMPT aMotAlt[6] SIZE 100, 008 OF oDlgBlqFor COLORS 0, 16777215 PIXEL


		@ 131, 105 BUTTON oBConf PROMPT "Confirmar" SIZE 068, 015 OF oDlgAltFor PIXEL
		@ 131, 178 BUTTON oBCanc PROMPT "Cancelar" SIZE 068, 015 OF oDlgAltFor PIXEL

		oGCodigo:Disable()
		oGLoja:Disable()
		oGCNPJ:Disable()
		oGFornece:Disable()

		If lCheckBo1
			oCheckBo1:Disable()
		EndIf

		If lCheckBo2
			oCheckBo2:Disable()
		EndIf

		If lCheckBo3
			oCheckBo3:Disable()
		EndIf

		If lCheckBo4
			oCheckBo4:Disable()
		EndIf

		If lCheckBo5
			oCheckBo5:Disable()
		EndIf

		If lCheckBo6
			oCheckBo6:Disable()
		EndIf

		oBConf:bAction  := {|| iif(VldAltFor('1',{lCheckBo1,lCheckBo2,lCheckBo3,lCheckBo4,lCheckBo5,lCheckBo6}), (lConf := .t., oDlgAltFor:End()), nil)}
		oBCanc:bAction  := {|| lConf := .F., oDlgAltFor:End()}

		ACTIVATE MSDIALOG oDlgAltFor CENTERED

		If lConf

			cGrpAlt := ""
			If lCheckBo1
				cGrpAlt += "1"
			EndIf
			If lCheckBo2
				cGrpAlt += "2""
			EndIf
			If lCheckBo3
				cGrpAlt += "3"
			EndIf
			If lCheckBo4
				cGrpAlt += "4"
			EndIf
			If lCheckBo5
				cGrpAlt += "5"
			EndIf
			If lCheckBo6
				cGrpAlt += "6"
			EndIf

			Reclock("SZZ",.F.)
			SZZ->ZZ_GRPALT  := cGrpAlt
			SZZ->(MsUnlock())


		EndIf
	EndIf

Return

// -------------------------------------------------------------------------------------------------------------------------------------------------


User Function UpdBlqFor()
	Local aArea     := GetArea()
	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| BlzFor() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function BlzFor()
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
						cCodigo := aLinha[nPosCodigo]
						cLoja   := aLinha[nPosLoja]


						dbSelectArea('SA2')
						SA2->(DbSetOrder(1))
						If dbSeek(FWxFilial('SA2') + cCodigo + cLoja)
							cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", Codigo [" + cCodigo + " - " + cLoja + "] " +;
								"registro bloqueado com sucesso." + CRLF

							//Realiza a alteração do fornecedor
							RecLock('SA2', .F.)
							SA2->A2_MSBLQL  := '1'
							SA2->(MsUnlock())
						Else
							cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", Codigo [" + cCodigo + " - " + cLoja + "] " +;
								"registro não bloqueado falha na localização do registro." + CRLF
						Endif
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

//-------------------------------------------------------------------------------------------------------------------------
User Function AtvCGC()
	Local aArea:= GetArea()


	If GetMv("CL_ATVCGC")
		PutMV("CL_ATVCGC", .F.)
		FWAlertSuccess("Desativada validação de CNPJ/CPF na inclusão de ficha de fornecedor. Fazer um logoff para valer a mudança efetuada.", "Validação CNPJ/CPF")
	ELSE
		PutMV("CL_ATVCGC", .T.)
		FWAlertSuccess("Ativada validação de CNPJ/CPF na inclusão de ficha de fornecedor. Fazer um logoff para valer a mudança efetuada.", "Validação CNPJ/CPF")
	ENDIF

	RestArea(aArea)

Return
