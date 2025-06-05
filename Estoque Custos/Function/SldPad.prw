#include 'protheus.ch'
#DEFINE NMAXPAGE 50

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SldPad   ºAutor  ³ Marcos Candido     º Data ³  12/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que apresentara em uma Consulta Especifica, os      º±±
±±º          ³ codigos de produtos vinculados ao Grupo PAD e com saldo em º±±
±±º          ³ estoque maior que zero.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} SldPad
Consulta Especifica para os codigos de produtos vinculados ao Grupo PAD e com saldo em estoque maior que zero.
@author Sergio Braz
@since 02/01/2018

/*/
User Function SldPad

Local cRet		:= "" //"@#@#"
Local aArea		:= GetArea()

cRet := ODConfig("SB1")

RestArea( aArea )

Return cRet


//--------------------------------------------------------------------------
// Rotina | ODConfig     | Autor | Robson Luiz - Rleg    | Data | 18.02.2013
//--------------------------------------------------------------------------
// Descr. | Rotina para configurar qual tabela, campos e índices.
//--------------------------------------------------------------------------
// Uso    | Oficina de Programação
//--------------------------------------------------------------------------
Static Function ODConfig(cAliasRef)

Local lRet		:= .F.
Local aCampos	:= {}
Local aIndices	:= {}
Local cWhere    := ""

aCampos := {"B1_COD","B1_DESC","B1_TIPO","B1_GRUPO"}

aIndices:=	{{"B1_COD"},{"Codigo"}}
//aIndices:=	{{"B1_DESC"},{"Descricao"}}

lRet := ODShow(cAliasRef,aCampos,aIndices,cWhere)

Return lRet

//--------------------------------------------------------------------------
// Rotina | ODShow       | Autor | Robson Luiz - Rleg    | Data | 18.02.2013
//--------------------------------------------------------------------------
// Descr. | Rotina para apresentar os dados em tela.
//--------------------------------------------------------------------------
// Uso    | Oficina de Programação
//--------------------------------------------------------------------------
Static Function ODShow(cAliasRef,aCampos,aIndices,cWhere)
Local cCmbIndice := ""
Local cPesq := Space(50)
Local cTrbName := "TMP"+cAliasRef
Local cTitle := ""
Local cBLine := ""
Local cSep := ""
Local cCadAnt := ""

Local nX := 0
Local nRecno := 0

Local lRet := .F.

Local bRet:= {|| lRet := .T.,nRecno := IIf(Len(oLstBx:aArray)>=oLstBx:nAt,ATail(oLstBx:aArray[oLstBx:nAt]),0),oDlg:End()}

Local aDados:= {}
Local aHeaders:= {}

Local oDlg
Local oPesq
Local oLstBx

DEFAULT cWhere := ""

//-------------------------------
// Remove o campo filial da lista
//-------------------------------
For nX := 1 to Len(aCampos)
	If "_FILIAL" $ aCampos[nX]
		ADel(aCampos,nX)
		ASize(aCampos,Len(aCampos)-1)
		Exit
	Endif
Next nX
//------------------------
// Monta header do listbox
//------------------------
SX3->(DbSetOrder(2))
For nX := 1 to Len(aCampos)
	SX3->(DbSeek(aCampos[nX]))
	#IFDEF SPANISH
		AAdd(aHeaders,AllTrim(Capital(SX3->X3_TITSPA)))
	#ELSE
		#IFDEF ENGLISH
			AAdd(aHeaders,AllTrim(Capital(SX3->X3_TITENG)))
		#ELSE
			AAdd(aHeaders,AllTrim(Capital(SX3->X3_TITULO)))
		#ENDIF
	#ENDIF
Next nX
//-----------------
// Nome da pesquisa
//-----------------
SX2->(DbSetOrder(1))
SX2->(DbSeek(cAliasRef))
#IFDEF SPANISH
	cTitle := ALLTRIM(SX2->X2_NOMESPA)
#ELSE
	#IFDEF ENGLISH
		cTitle := ALLTRIM(SX2->X2_NOMEENG)
	#ELSE
		cTitle := ALLTRIM(SX2->X2_NOME)
	#ENDIF
#ENDIF
DEFINE MSDIALOG oDlg TITLE "Consulta" + " " + cTitle FROM 268,260 TO 642,796 PIXEL
//------------------
// Texto de pesquisa
//------------------
@ 17,2 MSGET oPesq VAR cPesq SIZE 219,9 COLOR CLR_BLACK PIXEL OF oDlg
//------------------------------------------
// Interface para selecao de indice e filtro
//------------------------------------------
@ 3,228 BUTTON "Filtrar" SIZE 37,12 PIXEL OF oDlg ACTION ;
(ODSetArray(@oLstBx,@aDados,cWhere,cTrbName,aCampos,cAliasRef,cCmbIndice,aIndices,@oDlg,cPesq))

@ 5,2 COMBOBOX cCmbIndice ITEMS aIndices[2] SIZE 220,010 PIXEL OF oDlg ON CHANGE ;
(ODSetArray(@oLstBx,@aDados,cWhere,cTrbName,aCampos,cAliasRef,cCmbIndice,aIndices,@oDlg,cPesq))
//-------------------------
// Invocar o objeto ListBox
//-------------------------
oLstBx := TWBrowse():New(30,3,264,139,Nil,aHeaders,,oDlg,,,,,,,,,,,,,,.T.)
oLstBx:bLDblClick := bRet
//--------------------------
// Botoes de ação do usuário
//--------------------------
DEFINE SBUTTON FROM 172,02 TYPE 1  ENABLE OF oDlg Action(Eval(bRet))
DEFINE SBUTTON FROM 172,35 TYPE 2  ENABLE OF oDlg Action(oDlg:End())
DEFINE SBUTTON FROM 172,68 TYPE 15 ENABLE OF oDlg Action(ODVisual(@oLstBx,cAliasRef))
//------------------------
// Carga inicial dos dados
//------------------------
ODSetArray(@oLstBx,@aDados,cWhere,cTrbName,aCampos,cAliasRef,cCmbIndice,aIndices,@oDlg,cPesq)
ACTIVATE MSDIALOG oDlg CENTERED

If Select(cTrbName) > 0
	(cTrbName)->(DbCloseArea())
Endif

If lRet
	DbSelectArea(cAliasRef)
	DbGoTo(nRecno)
Endif

Return (cAliasRef)->B1_COD

//--------------------------------------------------------------------------
// Rotina | ODSetArray   | Autor | Robson Luiz - Rleg    | Data | 18.02.2013
//--------------------------------------------------------------------------
// Descr. | Rotina para passar os dados do vetor para o objeto TwBrowse.
//--------------------------------------------------------------------------
// Uso    | Oficina de Programação
//--------------------------------------------------------------------------
Static Function ODSetArray(oLstBx,aDados,cWhere,cTrbName,aCampos,cAlias,cCmbIndice,aIndices,oDlg,cPesq)
Local cQuery := ""
Local cCpos := ""
Local cSep := ""
Local cChave := ""
Local cConcat := "+"
Local cLenPsq := ""
Local cFiltro := ""

Local nX := 0
Local cPrefx := PrefixoCpo(cAlias)
Local cOrder := ""

Local bLine := Nil

Local bNextReg := {|a,b,c,d,e| ODPageDown(@a,b,c,d,e)}

Local nTotReg := 0
Local nLenChave := 0
Local nInd := 0

Local lFiltra := .F.

Local aCposAdd := AClone(aCampos)

Default cPesq		:= ""

//-----------------------------------
// Remove espacos do texto pesquisado
//-----------------------------------
cPesq := AllTrim(cPesq)
cLenPsq := AllTrim(Str(Len(cPesq)))
//----------------------------------------
// Verifica se deve ser feito algum filtro
//----------------------------------------
If !Empty(cPesq)
	lFiltra := .T.
Endif
//-------------------------
// Define a ordem utilizada
//-------------------------
nInd := AScan(aIndices[2],cCmbIndice)
//--------------------------------
// Filtro de acordo com a pesquisa
//--------------------------------
If lFiltra
	//----------------------------------------------------------------
	// Define o simbolo de concatenacao de acordo com o banco de dados
	//----------------------------------------------------------------
	If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
		cConcat := "||"
	Endif
	cChave   := Upper(aIndices[1][nInd])
	cChave   := StrTran(cChave,cPrefX+"_FILIAL+","")
	cChvOrig := cChave
	cChave   := StrTran(cChave,cPrefX+"_",cAlias+"."+cPrefX+"_")
	cChave   := StrTran(cChave,"DTOS","")
	If cConcat <> "+"
		cChave := StrTran(cChave,"+",cConcat)
	Endif
	//-------------------------------------------------------
	// Verifica se a chave de busca nao eh maior que o indice
	//-------------------------------------------------------
	nLenChave := ODTamChave(cChvOrig)
	If nLenChave < Val(cLenPsq)
		cLenPsq := AllTrim(Str(nLenChave))
		cPesq	:= SubStr(cPesq,1,nLenChave)
	Endif
	//--------------------------------
	// Concatena a expressao do filtro
	//--------------------------------
	If lFiltra
		cFiltro += " SUBSTRING(" + cChave + ",1," + cLenPsq + ")= '"+cPesq+"' "
	Endif
Endif
//--------------------------------------------
// Monta lista de campos para o objeto ListBox
//--------------------------------------------
SX3->(DbSetOrder(2))
cBLine	:= "{||{"
For nX := 1 To Len(aCampos)
	cBLine += cSep + "oLstBx:aArray[oLstBx:nAt]["+AllTrim(Str(nX))+"]"
	cSep	:= ","
Next nX
cBLine	+= "}}"
bLine	:= &(cBLine)
cSep := ""
//--------------------------
// Prepara e executa a query
//--------------------------
cQuery := ODQuery(NIL,cAlias,cFiltro,cTrbName,.T.)
cQuery := ChangeQuery( cQuery )

If Select(cTrbName) > 0
	(cTrbName)->(DbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTrbName,.T.,.T.)
(cTrbName)->(DbGoTop())
If (cTrbName)->(Eof())
	MsgStop("Nenhum registro foi encontrado")
Else
	//--------------------------
	// Conta registros da tabela
	//--------------------------
	DbSelectArea(cTrbName)
	DbGoTop()
	While !Eof() .AND. nTotReg <= NMAXPAGE
		nTotReg++
		DbSkip()
	End
	DbGoTop()

	aDados := ODPageDown(NIL,cTrbName,aCposAdd,NMAXPAGE,cAlias)

	oLstBx:SetArray(aDados)
	oLstBx:bLine := bLine
	oLstBx:GoTop()
	oLstBx:Refresh()
	oDlg:Refresh()

	If (nTotReg > NMAXPAGE)
		oLstBx:bGoBottom	:= {||Eval(bNextReg,oLstBx,cTrbName,aCposAdd,NMAXPAGE,cAlias),oLstBx:NAT := EVAL( oLstBx:BLOGICLEN ) }

		oLstBx:bSkip		:= {|NSKIP, NOLD, nMax| nMax:=EVAL( oLstBx:BLOGICLEN ),NOLD := oLstBx:NAT, oLstBx:NAT += NSKIP,;
		oLstBx:NAT := MIN( MAX( oLstBx:NAT, 1 ), nMax ),Iif(oLstBx:nAt==nMax,;
		Eval(bNextReg,oLstBx,cTrbName,aCposAdd,NMAXPAGE,cAlias),.F.),oLstBx:NAT - NOLD}
	Endif
Endif
Return

//--------------------------------------------------------------------------
// Rotina | ODQuery      | Autor | Robson Luiz - Rleg    | Data | 18.02.2013
//--------------------------------------------------------------------------
// Descr. | Rotina para efetuar a query.
//--------------------------------------------------------------------------
// Uso    | Oficina de Programação
//--------------------------------------------------------------------------
Static Function ODQuery(aVend,cAlias,cFiltro,cArquivo,lSoQuery)
Local cGrupo := SuperGetMv("MV_ZZGRUPO",.f.)
Local aArea := GetArea()

Local cArqTmp := ""
Local cQuery := ""
Local cConcat := ""

DEFAULT cFiltro	:= ""
DEFAULT lSoQuery:= .F.

//----------------------------------------------------------------
// Define o simbolo de concatenacao de acordo com o banco de dados
//----------------------------------------------------------------
If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
	cConcat := "||"
Else
	cConcat	:= "+"
Endif
//-----------------------------------------
// Verificar qual tabela irá fazer a query.
//-----------------------------------------
If cArquivo == NIL
	cArqTmp	:= "TRBSX5"
Else
	cArqTmp	:= cArquivo
Endif
If Select(cArqTmp) > 0
	(cArqTmp)->(DbCloseArea())
Endif
//----------------------------
// Efetuar e executar a query.
//----------------------------
If cAlias == "SX5"

	SX5->(DbSetOrder(1))
	cQuery := "SELECT DISTINCT X5_TABELA"+cConcat+"X5_CHAVE FROM " + RetSqlName("SX5") + " SX5 "
	//---------------
	// Clausula Where
	//---------------
	cQuery += "WHERE SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND "
	If !Empty(cFiltro)
		cQuery += " " + cFiltro + " AND "
	Endif
	If TcSrvType() != "AS/400"
		cQuery += " SX5.D_E_L_E_T_ = '' "
	Else
		cQuery += " SX5.@DELETED@ = '' "
	Endif
	cQuery += " ORDER BY X5_TABELA"+cConcat+"X5_CHAVE"

ElseIf cAlias == "SB1"

	cQuery := "SELECT SB1.B1_COD, SB2.B2_QATU, SB2.B2_LOCAL "
	//cQuery += "FROM " + RetSQLName("SB1") + " SB1, "+RetSQLName("SB2") + " SB2, "+RetSQLName("SZD") + " SZD "
	cQuery += "FROM " + RetSQLName("SB1") + " SB1, "+RetSQLName("SB2") + " SB2 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
	cQuery += "SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND "
	//cQuery += "SZD.ZD_FILIAL = '" + xFilial("SZD") + "' AND "

	If !Empty(cFiltro)
		cQuery += " " + cFiltro + " AND "
	Endif

	cQuery += "SB1.B1_COD = SB2.B2_COD AND "
	cQuery += "'"+Alltrim(cGrupo)+"'" + " LIKE '%'+SB1.B1_GRUPO+'%' AND "
	cQuery += "SB2.B2_QATU > 0 AND "
	//cQuery += "SB1.B1_COD <> SZD.ZD_COD AND "
	//cQuery += "SB2.B2_LOCAL <> SZD.ZD_ARMAZ AND "
	cQuery += "SB1.D_E_L_E_T_ = '' AND "
	cQuery += "SB2.D_E_L_E_T_ = '' "
	//cQuery += "AND SZD.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY B1_COD,B2_LOCAL"

Endif

If !lSoQuery
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTmp,.T.,.T.)
	(cArqTmp)->(DbGoTop())
Endif

RestArea(aArea)

Return cQuery

//--------------------------------------------------------------------------
// Rotina | ODPageDown   | Autor | Robson Luiz - Rleg    | Data | 18.02.2013
//--------------------------------------------------------------------------
// Descr. | Rotina para ler os dados na tabela conforme retorno da query. E
//        | fazer o controle de número de linhas lidas/visualizas pelo user.
//--------------------------------------------------------------------------
// Uso    | Oficina de Programação
//--------------------------------------------------------------------------
Static Function ODPageDown(oLstBx,cAlias,aCampos,nLimite,cAliasOri)
Local aLinha := {}
Local aDados := {}

Local nX := 0
Local nRegs := 0

Local cChaveInd := ""
Local cSep := ""
Local cChave := ""

(cAliasOri)->(DbSetOrder(1))
For nX := 1 To (cAlias)->(FCount())
	If Type((cAlias)->(FieldName(nX))) == "C"
		cChaveInd += cSep + (cAlias)->(FieldName(nX))
		cSep	:= "+"
	Endif
Next nX

While !(cAlias)->(Eof()) .And. nRegs <= nLimite
	aLinha := {}
	cChave	:= (cAlias)->&(cChaveInd)
	(cAliasOri)->(DbSeek(xFilial(cAliasOri)+cChave))
	For nX := 1 To Len(aCampos)
		AAdd(aLinha,(cAliasOri)->&(aCampos[nX]))
	Next nX
	AAdd(aLinha,(cAliasOri)->(Recno()))
	If oLstBx <> NIL
		AAdd(oLstBx:aArray,aClone(aLinha))
	Else
		Aadd(aDados,aClone(aLinha))
	Endif
	nRegs++
	(cAlias)->(DbSkip())
End
If oLstBx <> NIL
	Return aClone(oLstBx:aArray)
Else
	Return aDados
Endif
Return .F.

//--------------------------------------------------------------------------
// Rotina | ODVisual     | Autor | Robson Luiz - Rleg    | Data | 18.02.2013
//--------------------------------------------------------------------------
// Descr. | Rotina para visualizar os dados na íntegra conforme o registro.
//--------------------------------------------------------------------------
// Uso    | Oficina de Programação
//--------------------------------------------------------------------------
Static Function ODVisual(oLstBx,cAlias)

Local aArea	:= GetArea()
Local nReg	:= 0
//---------------------------------------------------------------
// Tratamento para casos em que o filtro não exiba clientes no F3
//---------------------------------------------------------------
If Len(oLstBx:aArray) >= oLstBx:nAt
	nReg := aTail(oLstBx:aArray[oLstBx:nAt])
	SaveInter()
	//-------------------------------------------------------
	// Cria um aRotina basico para evitar quaisquer problemas
	// com a rotina diferente deste padrao
	//-------------------------------------------------------
	aRotina := {{"Pesquisar","AxPesqui",0,1},{"Visualizar","AxVisual",0,2}}
	DbSelectArea(cAlias)
	DbGoTo(nReg)
	AxVisual(cAlias,nReg,2)
	RestInter()
Endif

RestArea(aArea)

Return

//--------------------------------------------------------------------------
// Rotina | ODTamChave   | Autor | Robson Luiz - Rleg    | Data | 18.02.2013
//--------------------------------------------------------------------------
// Descr. | Rotina para verificar se a chave de busca eh maior que o indice.
//--------------------------------------------------------------------------
// Uso    | Oficina de Programação
//--------------------------------------------------------------------------
Static Function ODTamChave(cChvOrig)

Local nTam	:= 0
Local nX	:= 0
Local aCpos	:= {}
cChvOrig := StrTran(cChvOrig,"DTOS")
cChvOrig := StrTran(cChvOrig,"(")
cChvOrig := StrTran(cChvOrig,")")
aCpos := StrToKArr(cChvOrig,"+")
For nX := 1 To Len(aCpos)
	nTam += TamSX3(aCpos[nX])[1]
Next nX

Return nTam
