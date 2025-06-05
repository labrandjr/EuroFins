#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

#DEFINE CAMPO_MARK			"OK"
#DEFINE TITULO_JANELA		"Bloqueio de Fornecedores"
#DEFINE POS_NOME_CAMPO		01
#DEFINE POS_TIPO_CAMPO		02

//-----------------------------------------------------------------
/*/{Protheus.doc} fImpBlqFor
Rotina responsável pela importação de um CSV
para realizar o bloqueio no fornecedor

@type		Function
@author 	Julio Lisboa
@since 		16/12/2020
@return		nil, nulo
/*/
//-----------------------------------------------------------------
user function fImpBlqFor()

	local cQuery		:= ""
	local aCampos		:= {}
	local aEstruct		:= {}
	local aSize			:= msAdvSize(.F.)
	local nAltura		:= aSize[06] * 0.8 //500
	local nLargura		:= aSize[05] * 0.8 //1200
	local cAliasTmp		:= GetNextAlias()
	local lExistReg		:= .F.

	private oDlg				:= nil
	private oTabTemp			:= nil
	private oMark				:= nil
	private cAliasBrowse		:= GetNextAlias()
	private aRotina				:= {}
	private lExecute			:= .F.

	if fPerg()
		cQuery				:= getQuery()
		cAliasTmp			:= getAliasTab(@lExistReg)
		if !lExistReg
			MsgAlert("Nenhum registro localizado no período informado.",FunDesc())
		else
			aCampos				:= montaCampos( cAliasTmp )
			aEstruct			:= montaEstrutura( cAliasTmp )
			oTabTemp			:= criaTabelaTemp( cAliasBrowse , aEstruct )
			FWMsgRun( ,{ || CpyAliasParaTabTemp( cAliasTmp , cAliasBrowse , aEstruct ) } ,FunDesc(), "Buscando, Aguarde..."  )

			aAdd( aRotina , { "Confirmar"	,"Eval({|| lExecute	:= .T., oDlg:end() })",0,9,0,NIL})
			aAdd( aRotina , { "Fechar"		,"Eval({|| lExecute := .F., oDlg:end() })",0,9,0,NIL})

			oMark := FWMarkBrowse():New()
			oMark:SetAlias( cAliasBrowse )
			oMark:SetQuery( cQuery )
			oMark:SetDescription( "Bloqueio de Fornecedores" )
			oMark:SetFieldMark( CAMPO_MARK )
			oMark:SetFilterDefault()
			oMark:SetFields(aCampos)
			oMark:setTemporary(.T.)
			oMark:SetSemaphore(.F.)
			oMark:setMenuDef("fImpBlqFor")
			oMark:setAllMark( { || oMark:AllMark() } )
			oMark:DisableReport()

			Define MsDialog oDlg From 0,0 to nAltura,nLargura Pixel Title TITULO_JANELA
			oMark:setOwner( oDlg )
			oMark:Activate()
			Activate MsDialog oDlg Centered
		endif
	endif

	if lExecute
		Processa( { || bloqueia() })
	endif

	if lExistReg
		oMark:DeActivate()
		oTabTemp:Delete()
	endif

return

//-----------------------------------------------------------------
static function fPerg()

	Local aParamBox 		:= {}
	Local aOrdenacao		:= {}

	aAdd( aOrdenacao , "1=Codigo e Loja" )
	aAdd( aOrdenacao , "2=Razão Social" )
	aAdd( aOrdenacao , "3=Nome Fantasia" )
	aAdd( aOrdenacao , "4=CNPJ" )
	aAdd( aOrdenacao , "5=Data Ulitma Nota" )

	aAdd(aParamBox,{1,"Data Maxima"			,Ctod("")	,""	,""	,""	,""	,70,.T.})		//MV_PAR01
	Aadd(aParamBox,{2,"Ordenação","1",aOrdenacao,80,.F.,.T.})// MV_PAR02

return ParamBox(aParamBox,"Parametros",,,,.T.,,,,"fImpBlqFor",.T.,.T.)

//-----------------------------------------------------------------
static function montaCampos( cAliasTmp )

	local aStruct		:= {}
	local aCampos		:= {}
	local nCampo		:= 0
	local cCampo		:= ""
	local cTitulo		:= ""
	local cTipo			:= ""
	local cPicture		:= ""

	aStruct		:= (cAliasTmp)->(DbStruct())
	For nCampo := 1 to Len( aStruct )
		cCampo		:= AllTrim( aStruct[nCampo,POS_NOME_CAMPO] )
		cTitulo		:= GetSx3Cache( cCampo , "X3_TITULO" )
		cTipo		:= GetSx3Cache( cCampo , "X3_TIPO" )
		cPicture	:= GetSx3Cache( cCampo , "X3_PICTURE" )

		if !(cCampo == "OK")
			If cTipo == "D"
				TcSetField( cAliasTmp , cCampo , "D" )
				aStruct[nCampo,POS_TIPO_CAMPO]	:= "D"
			EndIf
			aAdd( aCampos , { cTitulo , cCampo , cTipo ,,, cPicture })
		endif
	Next

return aCampos

//-----------------------------------------------------------------
static function montaEstrutura( cAliasTmp )
return (cAliasTmp)->(DbStruct())

//-----------------------------------------------------------------
static function getQuery()

	local cQuery		:= ""

	cQuery		+= "SELECT" + CRLF
	cQuery		+= "        '  ' OK  ," + CRLF
	cQuery		+= "        A2_COD   ," + CRLF
	cQuery		+= "        A2_LOJA  ," + CRLF
	cQuery		+= "        A2_NOME  ," + CRLF
	cQuery		+= "        A2_NREDUZ," + CRLF
	cQuery		+= "        A2_CGC   ," + CRLF
	cQuery		+= "        MAX(F1_DTDIGIT) F1_DTDIGIT" + CRLF
	cQuery		+= "FROM" + CRLF
	cQuery		+= "        " + RetSqlTab("SF1") + CRLF
	cQuery		+= "LEFT JOIN" + CRLF
	cQuery		+= "        " + RetSqlTab("SA2") + CRLF
	cQuery		+= "ON" + CRLF
	cQuery		+= "        A2_COD         = F1_FORNECE" + CRLF
	cQuery		+= "AND     A2_LOJA        = F1_LOJA" + CRLF
	cQuery		+= "AND     SA2.D_E_L_E_T_ =' '" + CRLF
	cQuery		+= "WHERE" + CRLF
	cQuery		+= "        F1_SERIE NOT IN ('ND')" + CRLF
	cQuery		+= "AND     SF1.D_E_L_E_T_ =' '" + CRLF
	cQuery		+= "AND     SA2.A2_MSBLQL <> '1'" + CRLF
	cQuery		+= "AND     SA2.A2_COD <> ' ' " + CRLF
	cQuery		+= "AND     SF1.F1_DTDIGIT <> ' ' " + CRLF
	cQuery		+= "GROUP BY" + CRLF
	cQuery		+= "        A2_COD   ," + CRLF
	cQuery		+= "        A2_LOJA  ," + CRLF
	cQuery		+= "        A2_NOME  ," + CRLF
	cQuery		+= "        A2_NREDUZ," + CRLF
	cQuery		+= "        A2_CGC   ," + CRLF
	cQuery		+= "        A2_MSBLQL" + CRLF
	cQuery		+= "HAVING" + CRLF
	cQuery		+= "        MAX(F1_DTDIGIT) <= '" + DTOS(MV_PAR01) + "'" + CRLF
	cQuery		+= "ORDER BY" + CRLF

	If AllTrim(MV_PAR02) == "1"
		cQuery		+= "        A2_COD," + CRLF
		cQuery		+= "        A2_LOJA" + CRLF
	ElseIf AllTrim(MV_PAR02) == "2"
		cQuery		+= "        A2_NOME" + CRLF
	ElseIf AllTrim(MV_PAR02) == "3"
		cQuery		+= "        A2_NREDUZ" + CRLF
	ElseIf AllTrim(MV_PAR02) == "4"
		cQuery		+= "        A2_CGC" + CRLF
	ElseIf AllTrim(MV_PAR02) == "5"
		cQuery		+= "        F1_DTDIGIT" + CRLF
	Else
		cQuery		+= "        A2_COD," + CRLF
		cQuery		+= "        A2_LOJA" + CRLF
	EndIf

return cQuery

//-----------------------------------------------------------------
static function getAliasTab(lExistReg)

	local cQuery			:= getQuery()
	local cAlias			:= getnextalias()
	local nQtdRegs			:= 0

	TcQuery cQuery new Alias &cAlias
	count to nQtdRegs
	(cAlias)->(DbGoTop())

	lExistReg		:= nQtdRegs > 0

return cAlias

//-----------------------------------------------------------------
static function criaTabelaTemp( cAliasBrowse , aEstruct )

	local oTab			:= nil

	oTab				:= FwTemporaryTable():New( cAliasBrowse )
	oTab:SetFields( aEstruct )

	If AllTrim(MV_PAR02) == "1"
		oTab:AddIndex( "01" , {"A2_COD","A2_LOJA"} )
	ElseIf AllTrim(MV_PAR02) == "2"
		oTab:AddIndex( "01" , {"A2_NOME"} )
	ElseIf AllTrim(MV_PAR02) == "3"
		oTab:AddIndex( "01" , {"A2_NREDUZ"} )
	ElseIf AllTrim(MV_PAR02) == "4"
		oTab:AddIndex( "01" , {"A2_CGC"} )
	ElseIf AllTrim(MV_PAR02) == "5"
		oTab:AddIndex( "01" , {"F1_DTDIGIT"} )
	Else
		coTab:AddIndex( "01" , {"A2_COD","A2_LOJA"} )
	EndIf
	oTab:Create()

return oTab

//-----------------------------------------------------------------
static function CpyAliasParaTabTemp( cAliasTmp , cAliasBrowse , aEstruct )

	local aAreaTmp		:= (cAliasTmp)->(GetArea())
	local nCampo		:= 0
	local cCampo		:= ""

	(cAliasTmp)->(DbGoTop())
	While (cAliasTmp)->(!Eof())

		if reclock( cAliasBrowse , .T. )
			for nCampo := 1 to len(aEstruct)
				cCampo		:= AllTrim( aEstruct[nCampo,POS_NOME_CAMPO] )
				(cAliasBrowse)->&(cCampo)		:= (cAliasTmp)->&(cCampo)
			next
			(cAliasBrowse)->(MsUnlock())
		endif

		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasBrowse)->(DbGoTop())

	restArea(aAreaTmp)

return

//-----------------------------------------------------------------
static function bloqueia()

	local nQtdBloq		:= 0
	local nQtdRegs		:= 0
	local nRegistro		:= 0
	local aAreaSA2		:= SA2->(GetArea())
	Local nQtdRegs      := (cAliasBrowse)->(RecCount())

	ProcRegua( nQtdRegs )
	(cAliasBrowse)->(DbGoTop())
	SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA

	While (cAliasBrowse)->(!Eof())
		nRegistro++

		If oMark:IsMark()
			If SA2->(DbSeek( FwXFilial("SA2") + (cAliasBrowse)->A2_COD + (cAliasBrowse)->A2_LOJA ))
				if reclock("SA2",.F.)
					SA2->A2_MSBLQL		:= "1"
					SA2->(MsUnlock())
				endif
				nQtdBloq++
			endif
		endif
		IncProc()
		(cAliasBrowse)->(DbSkip())
	EndDo

	if nQtdBloq > 0
		MsgAlert("Total de Fornecedores bloqueados: " + cValToChar(nQtdBloq),FunDesc())
	endif

	restArea(aAreaSA2)

return
