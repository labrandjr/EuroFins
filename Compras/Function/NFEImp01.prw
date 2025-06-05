#include 'rwmake.ch'
#include 'totvs.ch'

#DEFINE LINHAS 9999

/*/{Protheus.doc} NFEImp01
Programa que possibilitara a digitacao dos dados inerentes
a nota fiscal de importacao e que em seguida, ira
gerar a nota corretamente, calculando os devidos impostos.
@author Marcos Candido
@since 02/01/2018
/*/
User Function NFEImp01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPos
Local bBlock
Local nX         := 0

Private nPosCod:=0,nPosLocal:=0,nPosQuant:=0,nPosDesc:=0,nPosObs:=0,nPosItem:=0
Private cCadastro:=OemToAnsi("Dados para a Nota Fiscal de Importação")
Private aRotina := {}
Private lConsFrete := .F.
Private nTaxa := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//³    6 - Altera registro corrente e nao deixa incluir linha    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina := { {OemToAnsi("Pesquisar")	,"AxPesqui"		, 0 , 1},;
			 {OemToAnsi("Visualizar")	,"U_NFEIVisu"	, 0 , 2},;
 			 {OemToAnsi("viS. Cálculo")	,"U_NFEICalc"	, 0 , 2},;
			 {OemToAnsi("Incluir")		,"U_NFEIInc"	, 0 , 3},;
			 {OemToAnsi("Alterar")		,"U_NFEIAlt"	, 0 , 4 , 20},;
			 {OemToAnsi("Excluir") 		,"U_NFEIExc"	, 0 , 5 , 21},;
			 {OemToAnsi("Gerar NFE")	,"U_NFEIGera"	, 0 , 6 , 20},;
		 	 {OemToAnsi("Legenda")		,"U_NFEILeg"	, 0 , 2,0}}

// 			 {OemToAnsi("NF Complem.")	,"U_NFEICompl"	, 0 , 4 , 20},;
//			 {OemToAnsi("Despesas") 	,"U_NFEIDesp"	, 0 , 4 , 20},;

aCores := {	{"ZA_STATUS=='1'"	,'BR_VERDE' },;		// Dados aguardando utilizacao
			{"ZA_STATUS=='2'"	,'BR_VERMELHO'}}	// Dados Ja utilizados


dbSelectArea("SZA")
dbSetOrder(1)

mBrowse(6,1,22,75,"SZA",,,,,,aCores)

dbSelectArea("SZA")
RetIndex("SZA")
dbClearFilter()


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEIInc  ³ Autor ³ Marcos Candido        ³ Data ³ 28/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de inclusao dos dados para a Nota de importacao   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void NFEIInc(ExpC1,ExpN1,ExpN2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEIInc(cAlias,nReg,nOpc)

Local GetList  := {}, oDlg
Local cCampo   := "", i:=0
Local nX       := 0
Local aObjects 	:= {},aPosObj  :={}
Local aSize    	:= MsAdvSize()
Local aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local cM2       := GetMV("MV_MOEDA2")
Local cM3       := GetMV("MV_MOEDA3")
Local cM4       := GetMV("MV_MOEDA4")
Local cM5       := GetMV("MV_MOEDA5")
Local aAreaAtual := GetArea()
Local aCpsGet   := {"ZA_ITEM","ZA_PROD","ZA_QUANT","ZA_Q_ESTOQ","ZA_VUNIT","ZA_TOTAL","ZA_VADUANA","ZA_ALIQIPI","ZA_ALIQII",;
                     "ZA_ALIQICM","ZA_ALIQPIS","ZA_ALIQCOF","ZA_LOCAL","ZA_NCM","ZA_ADICAO","ZA_SEQ_ADI","ZA_FABRIC",;
                      "ZA_PESO","ZA_SISCOME","ZA_TES","ZA_PEDIDO","ZA_ITEMPC","ZA_CC"}

Private aMoedas   := {" ",cM2,cM3,cM4,cM5}
Private nPosCod:=0 , nPosLocal:=0 , nPosQuant:=0 , nPosVUnit:=0 , nPosTES := 0 , nPosDI := 0
Private nPosTotal:=0 , nPosVAduana:=0 , nPosAliqIPI:=0 , nPosAliqII:=0 , nPosItem := 0  , nPosTES := 0
Private cNumero		:= CriaVar("ZA_SEQUENC")
Private dDataEmi	:= dDataBase
Private cFornece	:= Space(TamSX3("A2_COD")[1])
Private cLojaFor	:= Space(TamSX3("A2_LOJA")[1])
Private cNomFor     := Space(TamSX3("A2_NOME")[1])
Private nTaxaMoeda  := 0
Private cNumDI      := Space(TamSX3("ZA_NUM_DI")[1])
Private cLocDesemb  := Space(TamSX3("ZA_LOCDESE")[1])
Private cUFDesemb   := Space(TamSX3("ZA_UFDESEM")[1])
Private dDtDesemb   := CtoD(Space(8))
Private cNotaCompl  := Space(TamSX3("ZA_NFCOMPL")[1])
Private cSerieNFC   := Space(TamSX3("ZA_SERNFC")[1])
Private cZACC		:= Space(TamSX3("ZA_CC")[1])
Private nMoedaNFEI  := 1
Private nIImport    := 0
Private nCapataz    := 0
Private nFrete      := 0
Private nSeguro     := 0
Private nSiscomex   := 0
Private nOpca		:= 0
Private aButtons  := {}
Private aHeader   := {}
Private aCols     := {}
Private Continua,nUsado:=0

dbSelectArea("SZA")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( cAlias )
While !EOF() .And. (X3_ARQUIVO == cAlias)
	If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .And. aScan(aCpsGet , Alltrim(X3_CAMPO)) > 0
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
	Endif
	dbSkip()
Enddo

For nx := 1 To Len(aHeader)
	Do Case
		Case Trim(aHeader[nx][2]) == "ZA_PROD"
			nPosCod:=nX
		Case Trim(aHeader[nx][2]) == "ZA_QUANT"
			nPosQuant:=nX
		Case Trim(aHeader[nx][2]) == "ZA_LOCAL"
			nPosLocal:=nX
		Case Trim(aHeader[nx][2]) == "ZA_VUNIT"
			nPosVUnit:=nX
		Case Trim(aHeader[nx][2]) == "ZA_TOTAL"
			nPosTotal:=nX
		Case Trim(aHeader[nx][2]) == "ZA_VADUANA"
			nPosVAduana:=nX
		Case Trim(aHeader[nx][2]) == "ZA_ALIQIPI"
			nPosAliqIPI:=nX
		Case Trim(aHeader[nx][2]) == "ZA_ALIQII"
			nPosAliqII:=nX
		Case Trim(aHeader[nx][2]) == "ZA_ITEM"
			nPosItem:=nX
		Case Trim(aHeader[nx][2]) == "ZA_TES"
			nPosTES:=nX
	EndCase
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCOLS,Array(nUsado+1))
For nCntFor	:= 1 To nUsado
	aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
	If ( AllTrim(aHeader[nCntFor][2]) == "ZA_ITEM" )
		aCols[1][nCntFor] := "0001"
	EndIf
Next nCntFor
aCOLS[1][Len(aHeader)+1] := .F.

AADD(aButtons, {'PEDIDO',{||NfeForF5(aCols)},OemToAnsi("Selecionar Pedido de Compra - <F5>"),OemToAnsi("Pedido")} )
SetKey( VK_F5 , { || NfeForF5(aCols) } )

AADD(aObjects,{100,100,.T.,.T.,.F.})
AADD(aObjects,{300,100,.T.,.T.,.F.})

aPosObj:=MsObjSize(aInfo,aObjects)

While .T.
	Continua := .F.

	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
	@ 00+2.7,0.8 Say OemToAnsi("N£mero Documento")
	@ 01.4+2,0.8 MsGet cNumero Picture PesqPict("ZA","ZA_SEQUENC") Size 40,09 When .F.
	@ 00.7+2,10 Say OemToAnsi("N£mero D.I.")
	@ 01.4+2,10 MsGet cNumDI Picture PesqPict("ZA","ZA_NUM_DI") Size 50,09
	@ 00.7+2,20 Say OemToAnsi("Emissão")
	@ 01.4+2,20 MsGet dDataEmi Valid dDataEmi <= dDataBase Size 40,09
	@ 00.7+2,29.5 Say OemToAnsi("Local Desembaraço")
	@ 01.4+2,29.5 MsGet cLocDesemb Picture PesqPict("ZA","ZA_LOCDESE") Size 112,09
	@ 00.7+2,44 Say OemToAnsi("UF")
	@ 01.4+2,44 MsGet cUFDesemb Picture PesqPict("ZA","ZA_UFDESEM") F3 "12" Valid(!Empty(cUFDesemb) .and. ExistCpo("SX5","12"+cUFDesemb)) Size 15,09

	@ 02.7+2,0.8 Say OemToAnsi("Fornecedor")
	@ 03.4+2,0.8 MsGet cFornece F3 "SA2" Picture PesqPict("ZA","ZA_FORNECE") Valid VeForn(cFornece,cLojaFor,@cNomFor) Size 30,09
	@ 03.4+2,5.2 MsGet cLojaFor Picture PesqPict("ZA","ZA_LOJA") Valid VeForn(cFornece,cLojaFor,@cNomFor) Size 15,09
	@ 03.4+2,7.2 MsGet cNomFor Size 120,09 When .F.
	@ 02.7+2,26.2 Say OemToAnsi("Moeda")
	@ 03.4+2,26.2 COMBOBOX nMoedaNFEI ITEMS aMoedas SIZE 40,15
	@ 02.7+2,35 Say OemToAnsi("Taxa")
	@ 03.4+2,35 MsGet nTaxaMoeda PICTURE X3Picture("ZA_TAXA") SIZE 30,09

	@ 04.7+2,0.8 Say OemToAnsi("Imp. de Importação")
	@ 05.4+2,0.8 MsGet nIImport Picture X3Picture("ZA_IIMPORT") SIZE 50,09
	@ 04.7+2,14 Say OemToAnsi("Capatazias")
	@ 05.4+2,14 MsGet nCapataz Picture X3Picture("ZA_CAPATAZ") SIZE 50,09
	@ 04.7+2,25 Say OemToAnsi("Frete")
	@ 05.4+2,25 MsGet nFrete Picture X3Picture("ZA_FRETE") SIZE 50,09
	@ 04.7+2,37.5 Say OemToAnsi("Tx Siscomex")
	@ 05.4+2,37.5 MsGet nSiscomex Picture X3Picture("ZA_SISCOME") SIZE 45,09 When .F.

	@ 06.7+2,0.8 Say OemToAnsi("Seguro")
	@ 07.4+2,0.8 MsGet nSeguro Picture X3Picture("ZA_SEGURO") SIZE 50,09
	@ 06.7+2,14 Say OemToAnsi("Data Desembaraço")
	@ 07.4+2,14 MsGet dDtDesemb SIZE 40,09
	@ 06.7+2,25 Say OemToAnsi("Num. NF Complementar")
	@ 07.4+2,25 MsGet cNotaCompl Size 40,09 When .F.
	@ 06.7+2,37.5 Say OemToAnsi("Série NF Compl.")
	@ 07.4+2,37.5 MsGet cSerieNFC Size 20,09 When .F.

	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"U_NFEILinOk","U_NFEITudoOk",'+ZA_ITEM',.T.,Nil,.F.,.T.,LINHAS)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End(),nOpca:=1},{||oDlg:End()},,aButtons)

	If nOpcA == 1
		Begin Transaction
			NFEIGrava(cAlias,nOpc)
			// Processa Gatilhos
			EvalTrigger()
			If __lSX8
				ConfirmSX8()
			Endif
		End Transaction
	ElseIf __lSX8
		RollBackSX8()
	Endif
	Exit
Enddo

SetCursor(0)
dbSelectArea(cAlias)

RestArea(aAreaAtual)

Return nOpca


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEIVisu ³ Autor ³ Marcos Candido        ³ Data ³ 28/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de visualizacao dos dados para a Nota de          ³±±
±±³          ³ importacao                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void NFEIVisu(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEIVisu(cAlias,nReg,nOpc)

Local GetList  := {}, oDlg
Local cCampo   := "", i:=0
Local nX       := 0 , nCnt:=0
Local aObjects 	:= {},aPosObj  :={}
Local aSize    	:= MsAdvSize()
Local aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aAreaAtual := GetArea()
Local aCpsGet   := {"ZA_ITEM","ZA_PROD","ZA_QUANT","ZA_Q_ESTOQ","ZA_VUNIT","ZA_TOTAL","ZA_VADUANA",;
                     "ZA_ALIQIPI","ZA_ALIQII","ZA_ALIQICM","ZA_ALIQPIS","ZA_ALIQCOF","ZA_LOCAL","ZA_NCM",;
                      "ZA_ADICAO","ZA_SEQ_ADI","ZA_FABRIC","ZA_NUMDOC","ZA_SERIE","ZA_DATANF","ZA_PESO",;
                       "ZA_SISCOME","ZA_TES","ZA_VLRII","ZA_VLRIPI","ZA_VLRPIS","ZA_VLRCOF","ZA_VLRICM",;
                       "ZA_VLRCAP","ZA_VLRFRE","ZA_VLRSEG","ZA_VLRSIS","ZA_PEDIDO","ZA_ITEMPC","ZA_CC"}

Private cNumero		:= SZA->ZA_SEQUENC
Private dDataEmi	:= SZA->ZA_EMISSAO
Private cFornece	:= SZA->ZA_FORNECE
Private cLojaFor	:= SZA->ZA_LOJA
Private cNomFor     := Posicione("SA2",1,xFilial("SA2")+cFornece+cLojaFor,"A2_NOME")
Private nTaxaMoeda  := SZA->ZA_TAXA
Private cNotaCompl  := SZA->ZA_NFCOMPL
Private cSerieNFC   := SZA->ZA_SERNFC
Private nMoedaNFEI  := SZA->ZA_MOEDA
Private nIImport    := SZA->ZA_IIMPORT
Private nCapataz    := SZA->ZA_CAPATAZ
Private nFrete      := SZA->ZA_FRETE
Private nSeguro     := SZA->ZA_SEGURO
Private nSiscomex   := 0 // SZA->ZA_SISCOM
Private cNumDI      := SZA->ZA_NUM_DI
Private cLocDesemb  := SZA->ZA_LOCDESE
Private cUFDesemb   := SZA->ZA_UFDESEM
Private dDtDesemb   := SZA->ZA_DTDESEN
Private cZACC       := SZA->ZA_CC
Private nOpca		:= 0
Private aButtons  := {}
PRIVATE aHeader   := {}
PRIVATE aCols     := {}
Private Continua,nUsado:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( cAlias )
While !EOF() .And. (X3_ARQUIVO == cAlias)
	If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .And. aScan(aCpsGet , Alltrim(X3_CAMPO)) > 0
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
	Endif
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZA")
dbSetOrder(1)
dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor,.T.)
While !Eof() .and. ZA_SEQUENC == cNumero
	nCnt++
	AADD(aCols,Array(Len(aHeader)))
	For i:=1 to Len(aHeader)
		cCampo:=Alltrim(aHeader[i,2])
		If aHeader[i,10] # "V"
			aCols[Len(aCols)][i] := FieldGet(FieldPos(cCampo))
			If cCampo == "ZA_VLRSIS"
				nSiscomex += FieldGet(FieldPos(cCampo))
			Endif
		Else
			aCols[Len(aCols)][i] := CriaVar(cCampo)
		Endif
	Next i

	dbSelectArea(cAlias)
	dbSkip()
Enddo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao ache nenhum item , abandona rotina.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCnt == 0
	RestArea(aAreaAtual)
	Return .T.
Endif

AADD(aObjects,{100,100,.T.,.T.,.F.})
AADD(aObjects,{300,100,.T.,.T.,.F.})

aPosObj:=MsObjSize(aInfo,aObjects)

DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]

@ 00.7+2,0.8 Say OemToAnsi("N£mero Documento")
@ 01.4+2,0.8 MsGet cNumero Picture PesqPict("ZA","ZA_SEQUENC") Size 40,09 When .F.
@ 00.7+2,10 Say OemToAnsi("N£mero D.I.")
@ 01.4+2,10 MsGet cNumDI Picture PesqPict("ZA","ZA_NUM_DI") Size 50,09 When .F.
@ 00.7+2,20 Say OemToAnsi("Emissão")
@ 01.4+2,20 MsGet dDataEmi Size 40,09	When .F.
@ 00.7+2,29.5 Say OemToAnsi("Local Desembaraço")
@ 01.4+2,29.5 MsGet cLocDesemb Picture PesqPict("ZA","ZA_LOCDESE") Size 112,09 When .F.
@ 00.7+2,44 Say OemToAnsi("UF")
@ 01.4+2,44 MsGet cUFDesemb Picture PesqPict("ZA","ZA_UFDESEM") Size 15,09 When .F.

@ 02.7+2,0.8 Say OemToAnsi("Fornecedor")
@ 03.4+2,0.8 MsGet cFornece Picture PesqPict("ZA","ZA_FORNECE") Size 30,09 When .F.
@ 03.4+2,5.2 MsGet cLojaFor Picture PesqPict("ZA","ZA_LOJA") Size 15,09 When .F.
@ 03.4+2,7.2 MsGet cNomFor Size 120,09 When .F.
@ 02.7+2,26.2 Say OemToAnsi("Moeda")
@ 03.4+2,26.2 Get nMoedaNFEI PICTURE X3Picture("ZA_MOEDA") SIZE 15,09 When .F.
@ 02.7+2,35 Say OemToAnsi("Taxa")
@ 03.4+2,35 MsGet nTaxaMoeda PICTURE X3Picture("ZA_TAXA") SIZE 30,09	When .F.

@ 04.7+2,0.8 Say OemToAnsi("Imp. de Importação")
@ 05.4+2,0.8 MsGet nIImport Picture X3Picture("ZA_IIMPORT") SIZE 50,09 When .F.
@ 04.7+2,14 Say OemToAnsi("Capatazias")
@ 05.4+2,14 MsGet nCapataz Picture X3Picture("ZA_CAPATAZ") SIZE 50,09 When .F.
@ 04.7+2,25 Say OemToAnsi("Frete")
@ 05.4+2,25 MsGet nFrete Picture X3Picture("ZA_FRETE") SIZE 50,09 When .F.
@ 04.7+2,37.5 Say OemToAnsi("Tx Siscomex")
@ 05.4+2,37.5 MsGet nSiscomex Picture X3Picture("ZA_SISCOME") SIZE 45,09 When .F.

@ 06.7+2,0.8 Say OemToAnsi("Seguro")
@ 07.4+2,0.8 MsGet nSeguro Picture X3Picture("ZA_SEGURO") SIZE 50,09 When .F.
@ 06.7+2,14 Say OemToAnsi("Data Desembaraço")
@ 07.4+2,14 MsGet dDtDesemb SIZE 40,09 When .F.
@ 06.7+2,25 Say OemToAnsi("Num. NF Complementar")
@ 07.4+2,25 MsGet cNotaCompl Size 40,09 When .F.
@ 06.7+2,37.5 Say OemToAnsi("Série NF Compl.")
@ 07.4+2,37.5 MsGet cSerieNFC Size 20,09 When .F.

oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","",.F.,Nil,Nil,Nil,LINHAS)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()},,aButtons)


SetCursor(0)
RestArea(aAreaAtual)

Return nOpca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEIAlt  ³ Autor ³ Marcos Candido        ³ Data ³ 28/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de alteracao dos dados para a Nota de             ³±±
±±³          ³ importacao                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void NFEIAlt(ExpC1,ExpN1,ExpN2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEIAlt(cAlias,nReg,nOpc)

Local GetList  := {}, oDlg
Local cCampo   := "", i:=0
Local nX       := 0 , nCnt:=0
Local aObjects 	:= {},aPosObj  :={}
Local aSize    	:= MsAdvSize()
Local aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aAreaAtual := GetArea()
Local nNumItem := 0 , aNumItem := {}
Local cM2       := GetMV("MV_MOEDA2")
Local cM3       := GetMV("MV_MOEDA3")
Local cM4       := GetMV("MV_MOEDA4")
Local cM5       := GetMV("MV_MOEDA5")
Local aCpsGet   := {"ZA_ITEM","ZA_PROD","ZA_QUANT","ZA_Q_ESTOQ","ZA_VUNIT","ZA_TOTAL","ZA_VADUANA",;
                     "ZA_ALIQIPI","ZA_ALIQII","ZA_ALIQICM","ZA_ALIQPIS","ZA_ALIQCOF","ZA_LOCAL","ZA_NCM",;
                      "ZA_ADICAO","ZA_SEQ_ADI","ZA_FABRIC","ZA_PESO","ZA_SISCOME","ZA_TES","ZA_VLRII",;
                      "ZA_VLRIPI","ZA_VLRPIS","ZA_VLRCOF","ZA_VLRICM","ZA_VLRCAP","ZA_VLRFRE","ZA_VLRSEG","ZA_VLRSIS","ZA_PEDIDO","ZA_ITEMPC","ZA_CC"}

Private aMoedas   := {" ",cM2,cM3,cM4,cM5}
Private nPosCod:=0 , nPosLocal:=0 , nPosQuant:=0 , nPosVUnit:=0 , nPosTES := 0 , nPosDI := 0
Private nPosTotal:=0 , nPosVAduana:=0 , nPosAliqIPI:=0 , nPosAliqII:=0 , nPosItem:=0 , nPosTES:=0
Private cNumero		:= SZA->ZA_SEQUENC
Private dDataEmi	:= SZA->ZA_EMISSAO
Private cFornece	:= SZA->ZA_FORNECE
Private cLojaFor	:= SZA->ZA_LOJA
Private cNomFor     := Posicione("SA2",1,xFilial("SA2")+cFornece+cLojaFor,"A2_NOME")
Private nTaxaMoeda  := SZA->ZA_TAXA
Private nMoedaNFEI  := iif(SZA->ZA_MOEDA <=1 ,2 ,SZA->ZA_MOEDA)
Private nIImport    := SZA->ZA_IIMPORT
Private nCapataz    := SZA->ZA_CAPATAZ
Private nFrete      := SZA->ZA_FRETE
Private nSeguro     := SZA->ZA_SEGURO
Private nSiscomex   := 0 // SZA->ZA_SISCOME
Private cNumDI      := SZA->ZA_NUM_DI
Private cLocDesemb  := SZA->ZA_LOCDESE
Private cUFDesemb   := SZA->ZA_UFDESEM
Private dDtDesemb   := SZA->ZA_DTDESEN
Private cNotaCompl  := SZA->ZA_NFCOMPL
Private cSerieNFC   := SZA->ZA_SERNFC
Private cZACC       := SZA->ZA_CC
Private nOpca		:= 0
Private aButtons  := {}
PRIVATE aHeader   := {}
PRIVATE aCols     := {}
Private Continua,nUsado:=0


dbSelectArea(cAlias)
dbSetOrder(1)
dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor,.T.)
While !Eof() .and. xFilial("SZA")==ZA_FILIAL .and. ZA_SEQUENC==cNumero
	nNumItem++
	If ZA_STATUS == "2"
		aadd( aNumItem , nNumItem)
	Endif
	dbSkip()
Enddo

If Len(aNumItem) > 0
	IW_MsgBox(OemToAnsi("Registros já utilizados. Não é permitida sua alteração.") , OemToAnsi("Atenção") , "ALERT")
	RestArea(aAreaAtual)
	Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( cAlias )
While !EOF() .And. (X3_ARQUIVO == cAlias)
	If X3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL .and. aScan(aCpsGet , Alltrim(X3_CAMPO)) > 0
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
	Endif
	dbSkip()
Enddo

For nx := 1 To Len(aHeader)
	Do Case
		Case Trim(aHeader[nx][2]) == "ZA_PROD"
			nPosCod:=nX
		Case Trim(aHeader[nx][2]) == "ZA_QUANT"
			nPosQuant:=nX
		Case Trim(aHeader[nx][2]) == "ZA_LOCAL"
			nPosLocal:=nX
		Case Trim(aHeader[nx][2]) == "ZA_VUNIT"
			nPosVUnit:=nX
		Case Trim(aHeader[nx][2]) == "ZA_TOTAL"
			nPosTotal:=nX
		Case Trim(aHeader[nx][2]) == "ZA_VADUANA"
			nPosVAduana:=nX
		Case Trim(aHeader[nx][2]) == "ZA_ALIQI"
			nPosAliqIPI:=nX
		Case Trim(aHeader[nx][2]) == "ZA_ALIQII"
			nPosAliqII:=nX
		Case Trim(aHeader[nx][2]) == "ZA_ITEM"
			nPosItem:=nX
		Case Trim(aHeader[nx][2]) == "ZA_TES"
			nPosTES:=nX
	EndCase
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZA")
dbSetOrder(1)
dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor,.T.)
While !Eof() .and. ZA_SEQUENC == cNumero
	nCnt++
	AADD(aCols,Array(Len(aHeader)+1))
	For i:=1 to Len(aHeader)
		cCampo:=Alltrim(aHeader[i,2])
		If aHeader[i,10] # "V"
			aCols[Len(aCols)][i] := FieldGet(FieldPos(cCampo))
			If cCampo == "ZA_VLRSIS"
				nSiscomex += FieldGet(FieldPos(cCampo))
			Endif
		Else
			aCols[Len(aCols)][i] := CriaVar(cCampo)
		Endif
	Next i
	aCols[Len(aCols)][Len(aHeader)+1] := .F.

	dbSelectArea(cAlias)
	dbSkip()
Enddo

AADD(aButtons, {'PEDIDO',{||NfeForF5(aCols)},OemToAnsi("Selecionar Pedido de Compra - <F5>"),OemToAnsi("Pedido")} )
SetKey( VK_F5 , { || NfeForF5(aCols) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao ache nenhum item , abandona rotina.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCnt == 0
	RestArea(aAreaAtual)
	Return .T.
Endif

AADD(aObjects,{100,100,.T.,.T.,.F.})
AADD(aObjects,{300,100,.T.,.T.,.F.})

aPosObj:=MsObjSize(aInfo,aObjects)

DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]

@ 00.7+2,0.8 Say OemToAnsi("N£mero Documento")
@ 01.4+2,0.8 MsGet cNumero Picture PesqPict("ZA","ZA_SEQUENC") Size 40,09 When .F.
@ 00.7+2,10 Say OemToAnsi("N£mero D.I.")
@ 01.4+2,10 MsGet cNumDI Picture PesqPict("ZA","ZA_NUM_DI") Size 50,09
@ 00.7+2,20 Say OemToAnsi("Emissão")
@ 01.4+2,20 MsGet dDataEmi Valid dDataEmi <= dDataBase Size 40,09
@ 00.7+2,29.5 Say OemToAnsi("Local Desembaraço")
@ 01.4+2,29.5 MsGet cLocDesemb Picture PesqPict("ZA","ZA_LOCDESE") Size 112,09
@ 00.7+2,44 Say OemToAnsi("UF")
@ 01.4+2,44 MsGet cUFDesemb Picture PesqPict("ZA","ZA_UFDESEM") F3 "12" Valid(!Empty(cUFDesemb) .and. ExistCpo("SX5","12"+cUFDesemb)) Size 15,09

@ 02.7+2,0.8 Say OemToAnsi("Fornecedor")
@ 03.4+2,0.8 MsGet cFornece Picture PesqPict("ZA","ZA_FORNECE") Size 30,09 When .F.
@ 03.4+2,5.2 MsGet cLojaFor Picture PesqPict("ZA","ZA_LOJA") Size 15,09 When .F.
@ 03.4+2,7.2 MsGet cNomFor Size 120,09 When .F.
@ 02.7+2,26.2 Say OemToAnsi("Moeda")
@ 03.4+2,26.2 COMBOBOX nMoedaNFEI ITEMS aMoedas SIZE 40,15
@ 02.7+2,35 Say OemToAnsi("Taxa")
@ 03.4+2,35 MsGet nTaxaMoeda PICTURE X3Picture("ZA_TAXA") SIZE 30,09

@ 04.7+2,0.8 Say OemToAnsi("Imp. de Importação")
@ 05.4+2,0.8 MsGet nIImport Picture X3Picture("ZA_IIMPORT") SIZE 50,09
@ 04.7+2,14 Say OemToAnsi("Capatazias")
@ 05.4+2,14 MsGet nCapataz Picture X3Picture("ZA_CAPATAZ") SIZE 50,09
@ 04.7+2,25 Say OemToAnsi("Frete")
@ 05.4+2,25 MsGet nFrete Picture X3Picture("ZA_FRETE") SIZE 50,09
@ 04.7+2,37.5 Say OemToAnsi("Tx Siscomex")
@ 05.4+2,37.5 MsGet nSiscomex Picture X3Picture("ZA_SISCOME") SIZE 45,09 When .F.

@ 06.7+2,0.8 Say OemToAnsi("Seguro")
@ 07.4+2,0.8 MsGet nSeguro Picture X3Picture("ZA_SEGURO") SIZE 50,09
@ 06.7+2,14 Say OemToAnsi("Data Desembaraço")
@ 07.4+2,14 MsGet dDtDesemb SIZE 40,09
@ 06.7+2,25 Say OemToAnsi("Num. NF Complementar")
@ 07.4+2,25 MsGet cNotaCompl Size 40,09 When .F.
@ 06.7+2,37.5 Say OemToAnsi("Série NF Compl.")
@ 07.4+2,37.5 MsGet cSerieNFC Size 20,09 When .F.

oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"U_NFEILinOk","U_NFEITudoOk",'+ZA_ITEM',.T.,Nil,.F.,.T.,LINHAS)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End(),nOpca:=1},{||oDlg:End()},,aButtons)

If nOpcA == 1
	Begin Transaction
		NFEIGrava(cAlias,nOpc)
		// Processa Gatilhos
		EvalTrigger()
		If __lSX8
			ConfirmSX8()
		Endif
	End Transaction
ElseIf __lSX8
	RollBackSX8()
Endif

SetCursor(0)

RestArea(aAreaAtual)

Return nOpca


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEIExc  ³ Autor ³ Marcos Candido        ³ Data ³ 28/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao  dos dados para a Nota de             ³±±
±±³          ³ importacao                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void NFEIExc(ExpC1,ExpN1,ExpN2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEIExc(cAlias,nReg,nOpc)

Local GetList  := {}, oDlg
Local cCampo   := "", i:=0
Local nX       := 0 , nCnt:=0
Local aObjects 	:= {},aPosObj  :={}
Local aSize    	:= MsAdvSize()
Local aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aAreaAtual := GetArea()
Local lCont := .T.
Local nNumItem := 0 , aNumItem := {}
Local aCpsGet   := {"ZA_ITEM","ZA_PROD","ZA_QUANT","ZA_Q_ESTOQ","ZA_VUNIT","ZA_TOTAL",;
                      "ZA_VADUANA","ZA_ALIQI","ZA_ALIQII","ZA_ALIQIC","ZA_ALIQPI","ZA_ALIQCO",;
                      "ZA_LOCAL","ZA_NCM","ZA_ADICAO","ZA_SEQ_ADI","ZA_FABRIC","ZA_PESO","ZA_SISCOME","ZA_TES","ZA_PEDIDO","ZA_ITEMPC","ZA_CC"}

Private cNumero		:= SZA->ZA_SEQUENC
Private dDataEmi	:= SZA->ZA_EMISSAO
Private cFornece	:= SZA->ZA_FORNECE
Private cLojaFor	:= SZA->ZA_LOJA
Private cNomFor     := Posicione("SA2",1,xFilial("SA2")+cFornece+cLojaFor,"A2_NOME")
Private nTaxaMoeda  := SZA->ZA_TAXA
Private nMoedaNFEI  := SZA->ZA_MOEDA
Private nIImport    := SZA->ZA_IIMPORT
Private nCapataz    := SZA->ZA_CAPATAZ
Private nFrete      := SZA->ZA_FRETE
Private nSeguro     := SZA->ZA_SEGURO
Private nSiscomex   := 0 // SZA->ZA_SISCOME
Private cNumDI      := SZA->ZA_NUM_DI
Private cLocDesemb  := SZA->ZA_LOCDESE
Private cUFDesemb   := SZA->ZA_UFDESEM
Private dDtDesemb   := SZA->ZA_DTDESEN
Private cNotaCompl  := SZA->ZA_NFCOMPL
Private cSerieNFC   := SZA->ZA_SERNFC
Private nOpca		:= 0
Private aButtons  := {}
PRIVATE aHeader   := {}
PRIVATE aCols     := {}
Private Continua,nUsado:=0


dbSelectArea(cAlias)
dbSetOrder(1)
dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor,.T.)
While !Eof() .and. xFilial("SZA")==ZA_FILIAL .and. ZA_SEQUENC==cNumero
	nNumItem++
	If ZA_STATUS == "2"
		aadd( aNumItem , nNumItem)
	Endif
	dbSkip()
Enddo

If Len(aNumItem) > 0
	IW_MsgBox(OemToAnsi("Registros já utilizados. Não é permitida sua exclusão.") , OemToAnsi("Atenção") , "ALERT")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( cAlias )
While !EOF() .And. (X3_ARQUIVO == cAlias)
	If X3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL .and. aScan(aCpsGet , Alltrim(X3_CAMPO)) > 0
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
	Endif
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZA")
dbSetOrder(1)
dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor,.T.)
While !Eof() .and. ZA_SEQUENC == cNumero
	nCnt++
	AADD(aCols,Array(Len(aHeader)))
	For i:=1 to Len(aHeader)
		cCampo:=Alltrim(aHeader[i,2])
		If aHeader[i,10] # "V"
			aCols[Len(aCols)][i] := FieldGet(FieldPos(cCampo))
			If cCampo == "ZA_VLRSIS"
				nSiscomex += FieldGet(FieldPos(cCampo))
			Endif
		Else
			aCols[Len(aCols)][i] := CriaVar(cCampo)
		Endif
	Next i

	dbSelectArea(cAlias)
	dbSkip()
Enddo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao ache nenhum item , abandona rotina.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCnt == 0
	RestArea(aAreaAtual)
	Return .T.
Endif

AADD(aObjects,{100,100,.T.,.T.,.F.})
AADD(aObjects,{300,100,.T.,.T.,.F.})

aPosObj:=MsObjSize(aInfo,aObjects)

DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]

@ 00.7+2,0.8 Say OemToAnsi("N£mero Documento")
@ 01.4+2,0.8 MsGet cNumero Picture PesqPict("ZA","ZA_SEQUENC") Size 40,09 When .F.
@ 00.7+2,10 Say OemToAnsi("N£mero D.I.")
@ 01.4+2,10 MsGet cNumDI Picture PesqPict("ZA","ZA_NUM_DI") Size 50,09 When .F.
@ 00.7+2,20 Say OemToAnsi("Emissão")
@ 01.4+2,20 MsGet dDataEmi Size 40,09	When .F.
@ 00.7+2,29.5 Say OemToAnsi("Local Desembaraço")
@ 01.4+2,29.5 MsGet cLocDesemb Picture PesqPict("ZA","ZA_LOCDESE") Size 112,09 When .F.
@ 00.7+2,44 Say OemToAnsi("UF")
@ 01.4+2,44 MsGet cUFDesemb Picture PesqPict("ZA","ZA_UFDESEM") Size 15,09 When .F.

@ 02.7+2,0.8 Say OemToAnsi("Fornecedor")
@ 03.4+2,0.8 MsGet cFornece Picture PesqPict("ZA","ZA_FORNECE") Size 30,09 When .F.
@ 03.4+2,5.2 MsGet cLojaFor Picture PesqPict("ZA","ZA_LOJA") Size 15,09 When .F.
@ 03.4+2,7.2 MsGet cNomFor Size 120,09 When .F.
@ 02.7+2,26.2 Say OemToAnsi("Moeda")
@ 03.4+2,26.2 Get nMoedaNFEI PICTURE X3Picture("ZA_MOEDA") SIZE 15,09 When .F.
@ 02.7+2,35 Say OemToAnsi("Taxa")
@ 03.4+2,35 MsGet nTaxaMoeda PICTURE X3Picture("ZA_TAXA") SIZE 30,09	When .F.

@ 04.7+2,0.8 Say OemToAnsi("Imp. de Importação")
@ 05.4+2,0.8 MsGet nIImport Picture X3Picture("ZA_IIMPORT") SIZE 50,09 When .F.
@ 04.7+2,14 Say OemToAnsi("Capatazias")
@ 05.4+2,14 MsGet nCapataz Picture X3Picture("ZA_CAPATAZ") SIZE 50,09 When .F.
@ 04.7+2,25 Say OemToAnsi("Frete")
@ 05.4+2,25 MsGet nFrete Picture X3Picture("ZA_FRETE") SIZE 50,09 When .F.
@ 04.7+2,37.5 Say OemToAnsi("Tx Siscomex")
@ 05.4+2,37.5 MsGet nSiscomex Picture X3Picture("ZA_SISCOME") SIZE 45,09 When .F.

@ 06.7+2,0.8 Say OemToAnsi("Seguro")
@ 07.4+2,0.8 MsGet nSeguro Picture X3Picture("ZA_SEGURO") SIZE 50,09 When .F.
@ 06.7+2,14 Say OemToAnsi("Data Desembaraço")
@ 07.4+2,14 MsGet dDtDesemb SIZE 40,09 When .F.
@ 06.7+2,25 Say OemToAnsi("Num. NF Complementar")
@ 07.4+2,25 MsGet cNotaCompl Size 40,09 When .F.
@ 06.7+2,37.5 Say OemToAnsi("Série NF Compl.")
@ 07.4+2,37.5 MsGet cSerieNFC Size 20,09 When .F.

oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","",.F.,Nil,Nil,Nil,LINHAS)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End(),nOpca:=1},{||oDlg:End()},,aButtons)

If nOpcA == 1
	Begin Transaction
		NFEIExclui(cAlias,nOpc)
		// Processa Gatilhos
		EvalTrigger()
		If __lSX8
			ConfirmSX8()
		Endif
	End Transaction
ElseIf __lSX8
	RollBackSX8()
Endif

RestArea(aAreaAtual)

Return nOpca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEICompl³ Autor ³ Marcos Candido        ³ Data ³ 16/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui o numero da nota complementar no cadastro dos dados ³±±
±±³          ³ da D.I.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void NFEIComl(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NfeImp01                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEICompl(cAlias,nReg,nOpc)

Local cNumNFC := Space(TamSX3("ZA_NFCOMPL")[1])
Local cSerNFC := Space(TamSX3("ZA_SERNFC")[1])
Local nOpt    := 0 , oDlgNFC
Local cNumero := SZA->ZA_SEQUENC
Local cFornece := SZA->ZA_FORNECE
Local cLojaFor := SZA->ZA_LOJA
Local aAreaAtual := GetArea()
Local aGeral  := {}
Local nTotBCIPI := 0 , nTotVlIPI := 0 , nTotBCICMS := 0 , nTotVlICMS := 0
Local nTotBCPIS := 0 , nTotVlPIS := 0 , nTotBCCOF := 0 , nTotVlCOF := 0

If Empty(SZA->ZA_NUMDOC)
	IW_MsgBox(OemToAnsi("Estes dados ainda não geraram nota de entrada. Não é possível incluir o número da Nota de Complemento.") , OemToAnsi("Atenção") , "ALERT")
	Return
Endif
If !Empty(SZA->ZA_NUMDOC) .and. !Empty(SZA->ZA_NFCOMPL)
	IW_MsgBox(OemToAnsi("Já existe Nota Fiscal Complementar para estes dados. Não é possível alterar o número da Nota de Complemento.") , OemToAnsi("Atenção") , "ALERT")
	Return
Endif

@ 090,085 To 230,350 Dialog oDlgNFC Title "Número da Nota Fiscal Complementar"
  @ 0.3,0.5 To 3.6,16.3

  @ 1.2+2,1.4 Say OemToAnsi('Número Nota Fiscal')
  @ 1.9+2,1.4 Get cNumNFC Picture "@! 999999999" SIZE 35,10

  @ 1.2+2,9.4 Say OemToAnsi('Série')
  @ 1.9+2,9.4 Get cSerNFC Picture "@!"  SIZE 20,10

  @ 053.6,37 BmpButton Type 1 Action(nOpt:=1,Close(oDLGNFC))
  @ 053.6,72 BmpButton Type 2 Action(Close(oDLGNFC))
Activate Dialog oDLGNFC Centered

If nOpt == 1 .and. !Empty(cNumNFC)
	(cAlias)->(dbSetOrder(1))
	If dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor)
		While !Eof() .and. ZA_FILIAL==xFilial("SZA") .and. ZA_SEQUENC+ZA_FORNECE+ZA_LOJA == cNumero+cFornece+cLojaFor
			RecLock(cAlias,.F.)
				Replace	 ZA_NFCOMPL  With   cNumNFC
				Replace  ZA_SERNFC   With   cSerNFC
			MsUnlock()
			dbSkip()
		Enddo
	Endif
Endif

RestArea(aAreaAtual)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEIDesp ³ Autor ³ Marcos Candido        ³ Data ³ 09/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui o valor de algumas despesas como Frete Remocao,     ³±±
±±³          ³ Frete Entrega, Despesa Financeira e Variacao Cambial       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void NFEIComl(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NfeImp01                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEIDesp(cAlias,nReg,nOpc)

Local aAreaAtual := GetArea()
Local nFreteRem := CriaVar("ZA_FRTREM",.F.)
Local nFreteEnt := CriaVar("ZA_FRTENT",.F.)
Local nVarCamb  := CriaVar("ZA_VARCAM",.F.)
Local nDespFin  := CriaVar("ZA_DESPFI",.F.)
Local nOpt     := 0 , oDlgDespC
Local cNumero  := SZA->ZA_SEQUENC
Local cFornece := SZA->ZA_FORNECE
Local cLojaFor := SZA->ZA_LOJA
Local nVlrTotAduan := 0
Local nFretRItem   := 0
Local nFretEItem   := 0
Local nVarCItem    := 0
Local nDesPItem    := 0

If Empty(SZA->ZA_NUMDOC)
	IW_MsgBox(OemToAnsi("Estes dados ainda não geraram nota de entrada. Não é possível incluir os valores das Despesas.") , OemToAnsi("Atenção") , "ALERT")
	Return
Endif
If !Empty(SZA->ZA_NUMDOC) .and. Empty(SZA->ZA_NFCOMPL)
	IW_MsgBox(OemToAnsi("Ainda não existe Nota Fiscal Complementar para estes dados. Não é possível incluir os valores das Despesas.") , OemToAnsi("Atenção") , "ALERT")
	Return
Endif

@ 090,085 To 230,580 Dialog oDlgDespC Title "Despesas Complementares"
  @ 003,002 To 047,246 Title "|  Informe o Valor Total  |"

  @ 014,008 Say OemToAnsi('Valor Frete Remoção')
  @ 013,070 Get nFreteRem Picture "@E 9,999,999.99" SIZE 45,10

  @ 014,125 Say OemToAnsi('Valor Frete Entrega')
  @ 013,190 Get nFreteEnt Picture "@E 9,999,999.99" SIZE 45,10

  @ 029,008 Say OemToAnsi('Valor Variação Cambial')
  @ 027,070 Get nVarCamb Picture "@E 9,999,999.99" SIZE 45,10

  @ 029,125 Say OemToAnsi('Valor Desps Financeiras')
  @ 027,190 Get nDespFin Picture "@E 9,999,999.99" SIZE 45,10

  @ 054,089 BmpButton Type 1 Action(nOpt:=1,Close(oDlgDespC))
  @ 054,124 BmpButton Type 2 Action(Close(oDlgDespC))
Activate Dialog oDlgDespC Centered

If nOpt == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetuo o rateio dos valores informados para cada item da importacao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(cAlias)->(dbSetOrder(1))
	If dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor)
		While !Eof() .and. ZA_FILIAL==xFilial("SZA") .and. ZA_SEQUENC+ZA_FORNECE+ZA_LOJA == cNumero+cFornece+cLojaFor
			nVlrTotAduan += ZA_VADUANA
			dbSkip()
		Enddo
	Endif

	If dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor)
		While !Eof() .and. ZA_FILIAL==xFilial("SZA") .and. ZA_SEQUENC+ZA_FORNECE+ZA_LOJA == cNumero+cFornece+cLojaFor

			nFretRItem := NoRound((nFreteRem / nVlrTotAduan) * ZA_VADUANA,3)
			nFretEItem := NoRound((nFreteEnt / nVlrTotAduan) * ZA_VADUANA,3)
			nVarCItem  := NoRound((nVarCamb  / nVlrTotAduan) * ZA_VADUANA,3)
			nDesPItem  := NoRound((nDespFin  / nVlrTotAduan) * ZA_VADUANA,3)

			RecLock(cAlias,.F.)
				Replace  ZA_FRTREM   With   nFretRItem
				Replace  ZA_FRTENT   With   nFretEItem
				Replace  ZA_VARCAM   With   nVarCItem
				Replace  ZA_DESPFI   With   nDespItem
			MsUnlock()

			dbSkip()

		Enddo
	Endif

Endif

RestArea(aAreaAtual)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEIGera ³ Autor ³ Marcos Candido        ³ Data ³ 12/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa que gera a nota fiscal de entrada com base nas    ³±±
±±³          ³ informacoes cadastradas.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void NFEIExc(ExpC1,ExpN1,ExpN2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NfeImp01                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEIGera(cAlias,nReg,nOpc,lCalc)

Local nBCIPI  := 0  // Base de Calculo IPI
Local aRateio := {} , aItem := {} , nRateio := 0
Local nQuant  := 0 , nOpc := 0 , nPeso := 0 , nVlrTotal := 0
Local aIPI    := {} , aPisCof := {} , aICMS := {}
Local aGeral  := {}
Local nTotBCIPI := 0 , nTotVlIPI := 0 , nTotBCICMS := 0 , nTotVlICMS := 0
Local nTotBCPIS := 0 , nTotVlPIS := 0 , nTotBCCOF := 0 , nTotVlCOF := 0
Local nNumItem := 0 , aNumItem := {} , cNomFor := ""
Local aAreaAtual := GetArea()
Local lPcNfe := GETMV("MV_PCNFE")
Local nDespRat := 0 , nVAduan := 0

Local lConsFrete := IIF(SZA->ZA_FRETEIN=="S",.T.,.F.)
Local cSequenc	 := SZA->ZA_SEQUENC
Local cFornece	 := SZA->ZA_FORNECE
Local cLojaFor	 := SZA->ZA_LOJA
Local nCapataz   := SZA->ZA_CAPATAZ
Local nFrete     := SZA->ZA_FRETE
Local nSeguro    := SZA->ZA_SEGURO
Local nSiscomex  := 0
Local nIImport   := 0
Local nDespsAc   := 0

Local cFilialEnt:= SB2->(SC7->(xFilEnt(SC7->C7_FILENT)))
Local cEntrega  := If(SuperGetMv("MV_PCFILEN"),IIF(!Empty(cFilialEnt),cFilialEnt,xFilial("SB2")),xFilial("SB2"))
Local lSb1TES  := SuperGetMv("MV_SB1TES",.F.,.F.)

Private cSerie , cNumero

lCalc := IIf(ValType(lCalc)#"L",.F.,lCalc)

If !lCalc
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(xFilial("SZA")+cSequenc+cFornece+cLojaFor,.T.)

	While !Eof() .and. xFilial("SZA")==ZA_FILIAL .and. ZA_SEQUENC==cSequenc
		nNumItem++
		If ZA_STATUS == "2"
			aadd( aNumItem , nNumItem)
		Endif
		dbSkip()
	Enddo

	If Len(aNumItem) > 0
		IW_MsgBox(OemToAnsi("Registros já utilizados.") , OemToAnsi("Atenção") , "ALERT")
		RestArea(aAreaAtual)
		Return
	Endif

	If !IW_MsgBox(OemToAnsi("Confirma geração da nota de entrada?") , OemToAnsi("Aviso") , "YESNO")
		RestArea(aAreaAtual)
		Return
	Endif
Endif

dbSeek(xFilial("SZA")+cSequenc+cFornece+cLojaFor,.T.)
While !Eof() .and. xFilial("SZA")==ZA_FILIAL .and. ZA_SEQUENC==cSequenc
	nTotBCICMS += ZA_BASICM
	nTotVlICMS += ZA_VLRICM
	nTotBCPIS  += ZA_BASPIS
	nTotVlPIS  += ZA_VLRPIS
	nTotBCCOF  += ZA_BASCOF
	nTotVlCOF  += ZA_VLRCOF
	nTotBCIPI  += ZA_BASIPI
	nTotVlIPI  += ZA_VLRIPI
	nIImport   += ZA_VLRII
	nVAduan    += ZA_VADUANA
	nSiscomex  += ZA_VLRSIS
	nDespsAc   += ZA_VLRSIS+ZA_VLRII

	nVTot  := ZA_VADUANA					// Valor Aduaneiro
	nVUnit := Round(nVTot/ZA_Q_ESTOQ,7) 	//Round(nVTot/ZA_QUANT,2)
	nVTot  := Round(nVUnit * ZA_Q_ESTOQ,2)	//Round(nVUnit * ZA_QUANT,2)

	cNum_DI := StrTran(ZA_NUM_DI,"/","")
	cNum_DI := StrTran(cNum_DI,"-","")
	cNum_DI := Alltrim(cNum_DI)
	dDT_DI  := ZA_EMISSAO
	cLocDes_DI := Alltrim(ZA_LOCDESE)
	cUFDes_DI  := ZA_UFDESEM
	cDtDes_DI  := ZA_DTDESEN
	cFabric    := ZA_FABRIC

	aadd(aGeral , {ZA_ITEM , ZA_PROD , nVUnit , nVTot , ZA_ALIQIPI ,;
				    ZA_BASIPI , ZA_VLRIPI , ZA_ALIQICM , ZA_BASICM , ZA_VLRICM ,;
				     ZA_ALIQPIS , ZA_BASPIS , ZA_VLRPIS , ZA_ALIQCOF , ZA_BASCOF ,;
				       ZA_VLRCOF , ZA_LOCAL , ZA_Q_ESTOQ , ZA_VLRSIS , ZA_VLRII ,;
				        ZA_TES , ZA_ADICAO , ZA_SEQ_ADI , ZA_PEDIDO , ZA_ITEMPC ,;
				        ZA_ALIQII, ZA_CC})

	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Estrutura de aGeral                     ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³   [1] = Item                                        ³
//³   [2] = Codigo do produto                           ³
//³   [3] = Valor Unitario                              ³
//³   [4] = Valor Total                                 ³
//³   [5] = Aliquota de IPI                             ³
//³   [6] = Base IPI                                    ³
//³   [7] = Valor IPI                                   ³
//³   [8] = Aliquota de ICMS                            ³
//³   [9] = Base ICMS                                   ³
//³  [10] = Valor ICMS									³
//³  [11] = Aliquota PIS                                ³
//³  [12] = Base PIS                                    ³
//³  [13] = Valor PIS									³
//³  [14] = Aliquota COFINS                             ³
//³  [15] = Base COFINS                                 ³
//³  [16] = Valor COFINS								³
//³  [17] = Armazem         				            ³
//³  [18] = Quantidade do Produto			            ³
//³  [19] = Siscomex Rateado				            ³
//³  [20] = Imposto de Importacao		                ³
//³  [21] = TES                  		                ³
//³  [22] = Adicao              		                ³
//³  [23] = Sequencia da Adicao  		                ³
//³  [24] = Numero do pedido de compra                  ³
//³  [25] = Item do Pedido de Compra                    ³
//³  [26] = Aliquota do Imposto de Importacao           ³
//³  [27] = CC								           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ProcRegua(Len(aGeral))

aCab     := {}
aItem    := {}
aTotItem := {}

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2")+cFornece+cLojaFor)
cNomFor := SA2->A2_NOME
cCondPgto := Iif(Empty(SA2->A2_COND),"001",SA2->A2_COND)

nVMerc      := nVAduan
nVProds     := nVAduan+nTotVlPIS+nTotVlCOF+nSiscomex+nIImport
nVBruto     := nVProds+nTotVlIPI+nTotVlICMS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra os calculos realizados, para o usuario decidir ³
//³ se continua ou nao.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 010,085 To 410,575 Dialog oDlg Title "Memória de Cálculo"
@ 002,003 To 179,245 Title ""

@ 1.0,1.1 Say OemToAnsi('Fornecedor')
@ 0.9,5.8 MsGet cNomFor Size 150,10 When .F.

@ 028,006 To 050,241 Title " Totais da Nota "
@ 3.0,1.3 Say OemToAnsi("Valor Mercadoria")
@ 2.8,7.5 MsGet nVMerc Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.
//@ 037,088 Say OemToAnsi("Valor Tot Prods")
//@ 035,131 MsGet nVProds Picture X3Picture("ZA_TOTAL") SIZE 35,09 When .F.
@ 3.0,17.6 Say OemToAnsi("Valor Bruto")
@ 2.8,22.6 MsGet nVBruto Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.

@ 060,006 To 172,241 Title " Impostos "
@ 5.5,1.3 Say OemToAnsi("Imp. de Importação")
@ 5.3,7.9 MsGet nIImport Picture X3Picture("ZA_IIMPORT") SIZE 55,09 When .F.
@ 5.5,16.9 Say OemToAnsi("Capatazias")
@ 5.3,22.6 MsGet nCapataz Picture X3Picture("ZA_CAPATAZ") SIZE 55,09 When .F.

@ 6.6,1.3 Say OemToAnsi("Frete")
@ 6.4,7.9 MsGet nFrete Picture X3Picture("ZA_FRETE") SIZE 55,09 When .F.
@ 6.6,16.9 Say OemToAnsi("Seguro")
@ 6.4,22.6 MsGet nSeguro Picture X3Picture("ZA_SEGURO") SIZE 55,09 When .F.

@ 7.7,1.3 Say OemToAnsi("Taxa de Siscomex")
@ 7.5,7.9 MsGet nSiscomex Picture X3Picture("ZA_SISCOME") SIZE 55,09 When .F.
@ 7.7,16.9 Say OemToAnsi('Desps Acessórias ')
@ 7.5,22.6 MsGet nDespsAc Picture X3Picture("ZA_SEGURO") SIZE 55,09 When .F.

@ 8.8,1.3 Say OemToAnsi('Base Cálculo ICMS')
@ 8.6,7.9 MsGet nTotBCICMS Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.
@ 8.8,16.9 Say OemToAnsi('Valor ICMS')
@ 8.6,22.6 MsGet nTotVlICMS Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.

@ 9.9,1.3 Say OemToAnsi('Base Cálculo IPI')
@ 9.7,7.9 MsGet nTotBCIPI  Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.
@ 9.9,16.9 Say OemToAnsi('Valor IPI')
@ 9.7,22.6 MsGet nTotVlIPI Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.

@ 11.0,1.3 Say OemToAnsi('Base Cálculo PIS')
@ 10.8,7.9 MsGet nTotBCPIS  Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.
@ 11.0,16.9 Say OemToAnsi('Valor PIS')
@ 10.8,22.6 MsGet nTotVlPIS Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.

@ 12.1,1.3 Say OemToAnsi('Base Cálculo COFINS')
@ 11.9,7.9 MsGet nTotBCCOF  Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.
@ 12.1,16.9 Say OemToAnsi('Valor COFINS')
@ 11.9,22.6 MsGet nTotVlCOF Picture X3Picture("ZA_TOTAL") SIZE 55,09 When .F.

If lCalc
	@ 18,26 Button "Sair" Size 35,15 Action(Close(oDlg))
Else
	@ 18,20 Button "Continua" Size 35,15 Action(nOpc:=1,Close(oDlg))
	@ 18,32 Button "Abandona" Size 35,15 Action(Close(oDlg))
Endif

Activate Dialog oDlg Centered

If lCalc
	RestArea(aAreaAtual)
	Return
Endif

If nOpc == 0
	IW_MsgBox(OemToAnsi("Processo cancelado.") , OemToAnsi("Aviso") , "STOP")
	RestArea(aAreaAtual)
	Return
Endif

lRet := SX5NumNota()

If !lRet
	IW_MsgBox(OemToAnsi("Processo cancelado.") , OemToAnsi("Aviso") , "STOP")
	RestArea(aAreaAtual)
	Return
Endif

PutMV("MV_PCNFE",.F.)

cDocNFE     := Alltrim(cNumero)+Space(9-Len(Alltrim(cNumero)))
cSerieNFE   := cSerie
dEmissaoNFE := dDataBase

aCab :=	 {{"F1_FILIAL"		,xFilial("SF1")		,Nil},;		// Filial
		  {"F1_TIPO"		,"N"				,Nil},;		// Tipo de Documento
		  {"F1_FORMUL"		,"S"				,Nil},;		// Formulario Proprio
		  {"F1_DOC"			,cDocNFE			,Nil},;		// Numero do Documento
		  {"F1_SERIE"		,cSerieNFE			,Nil},;		// Serie do Documento
		  {"F1_EMISSAO"		,dEmissaoNFE		,Nil},;		// Data de Emissao do Documento
		  {"F1_FORNECE"		,SA2->A2_COD		,Nil},;		// Codigo do Fornecedor
		  {"F1_LOJA"		,SA2->A2_LOJA		,Nil},;		// Loja do Fornecedor
		  {"F1_EST"			,SA2->A2_EST		,Nil},;		// Estado do Fornecedor
		  {"F1_COND"		,cCondPgto			,Nil},;		// Condicao de Pagamento
		  {"F1_ESPECIE"		,"SPED"				,Nil},;		// Especie do Documento
  	      {"F1_BASEICM"		,nTotBCICMS			,Nil},;		// Base de Calculo do ICMS
	      {"F1_VALICM"		,nTotVlICMS			,Nil},;		// Valor do ICMS
	      {"F1_BASEIPI"		,nTotBCIPI			,Nil},;		// Base de Calculo do IPI
	      {"F1_VALIPI"		,nTotVlIPI			,Nil},;		// Valor do IPI
	      {"F1_BASIMP6"		,nTotBCPIS			,Nil},;		// Base PIS
	      {"F1_VALIMP6"		,nTotVlPIS			,Nil},;		// Valor PIS
		  {"F1_BASIMP5"		,nTotBCCOF     		,Nil},;		// Base COFINS
		  {"F1_VALIMP5"		,nTotVlCOF     		,Nil},;		// Valor COFINS
  		  {"F1_VALMERC"		,nVMerc     		,Nil},;		// Valor Mercadoria
   		  {"F1_VALBRUT"		,nVBruto     		,Nil},;		// Valor Bruto
   		  {"F1_II"			,nDespsAc     		,Nil},;		// Imposto de Importacao
   		  {"F1_FRETE"		,0      			,Nil},;		//
   	      {"F1_DESPESA"		,nDespsAc			,Nil},;		// Despesas Acessorias
	      {"E2_NATUREZ"		,SA2->A2_NATUREZ	,Nil}}		// Natureza para o titulo a pagar
   		  //{"F1_SEGURO"		,nSeguro     		,Nil},;		// Valor do Seguro

For nF:=1 to Len(aGeral)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc("Gerando Documento de Entrada...")

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+aGeral[nF][2])

	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4")+aGeral[nF][21])
	nMajCOF := SF4->F4_MALQCOF
	nMajPIS := SF4->F4_MALQPIS

	aItem := {}
	aItem := 	{{"D1_FILIAL"		,xFilial("SD1")		,Nil},;		// Filial
				 {"D1_ITEM"			,aGeral[nF][1]		,Nil},;		// Item
				 {"D1_COD"			,aGeral[nF][2]		,Nil},;		// Codigo do Produto
				 {"D1_ZZCODF"		,aGeral[nF][2]		,Nil},;		// Codigo do Produto
				 {"D1_QUANT"		,aGeral[nF][18]		,Nil},;		// Quantidade
				 {"D1_VUNIT"		,aGeral[nF][3]		,Nil},;		// Valor Unitario
				 {"D1_TOTAL"		,aGeral[nF][4]		,Nil},;		// Valor Total
 				 {"D1_TES"			,aGeral[nF][21]		,Nil},;		// TES
				 {"D1_IPI"			,aGeral[nF][5]		,Nil},;		// Aliquota IPI
				 {"D1_BASEIPI"		,aGeral[nF][6]		,Nil},;		// Base IPI
				 {"D1_VALIPI"		,aGeral[nF][7]		,Nil},;		// Valor IPI
				 {"D1_PICM"			,aGeral[nF][8]		,Nil},;		// Aliquota ICMS
				 {"D1_BASEICM"		,aGeral[nF][9]		,Nil},;		// Base ICMS
				 {"D1_VALICM"		,aGeral[nF][10]		,Nil},;		// Valor ICMS
				 {"D1_ALQIMP6"		,aGeral[nF][11]		,Nil},;		// Aliquota PIS
				 {"D1_BASIMP6"		,aGeral[nF][12]		,Nil},;		// Base PIS
 				 {"D1_VALIMP6"		,aGeral[nF][13]		,Nil},;		// Valor PIS
				 {"D1_ALQIMP5"		,aGeral[nF][14]		,Nil},;		// Aliquota COFINS
				 {"D1_BASIMP5"		,aGeral[nF][15]		,Nil},;		// Base COFINS
 				 {"D1_VALIMP5"		,aGeral[nF][16]		,Nil},;		// Valor COFINS
 				 {"D1_LOCAL"		,aGeral[nF][17]		,Nil},;		// Armazem
  				 {"D1_II"			,aGeral[nF][19]+aGeral[nF][20]		,Nil},;		// Imposto de Importacao (Siscomex Rateado + Imposto de Importacao)
  				 {"D1_ALIQII"		,aGeral[nF][26]		,Nil},;		// Aliquota do Imposto de Importacao
  				 {"D1_VALFRE"		,0					,Nil},;		//
 				 {"D1_DESPESA"		,aGeral[nF][19]+aGeral[nF][20]		,Nil},;		// Valor Despesas  (Siscomex Rateado + Imposto de Importacao)
 				 {"D1_VALPMAJ"		,IIF(nMajPIS > 0 , Round(aGeral[nF][12]*(nMajPIS/100),2) , 0 )	,Nil},;		// Majoracao PIS
 				 {"D1_VALCMAJ"		,IIF(nMajCOF > 0 , Round(aGeral[nF][15]*(nMajCOF/100),2) , 0 )	,Nil},;		// Majoracao COFINS
 				 {"D1_CC"			,aGeral[nF][27]		,Nil}}

	AADD(aTotItem,aItem)

Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera a nota de entrada com os dados recebidos e     ³
//³ calculados.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lOk := IncluiNFEI()

If lOk

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Como a rotina automatica ignora os valores passados ³
	//³ para a composicao da base e valor do PIS e COFINS,  ³
	//³ faco a atualizacao manualmente.  (CABECALHO)        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF1")
	dbSetOrder(1)
	dbSeek(xFilial("SF1")+cDocNFE+cSerieNFE+cFornece+cLojaFor,.T.)
	RecLock("SF1",.F.)
	  Replace	F1_BASEICM	With	nTotBCICMS
	  Replace	F1_VALICM	With	nTotVlICMS
	  Replace	F1_BASEIPI	With	nTotBCIPI
	  Replace	F1_VALIPI	With	nTotVlIPI
	  Replace	F1_BASIMP5	With	nTotBCCOF
	  Replace	F1_VALIMP5	With	nTotVlCOF
	  Replace 	F1_BASIMP6	With	nTotBCPIS
	  Replace	F1_VALIMP6	With	nTotVlPIS
	  Replace	F1_VALMERC	With	nVMerc
	  Replace	F1_VALBRUT	With	nVBruto
  	  Replace	F1_II		With 	nDespsAc  // nIImport
	  Replace	F1_DESPESA	With 	nDespsAc
  	  //Replace	F1_FRETE	With 	nSiscomex
	MsUnlock()
	dbCommit()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Como a rotina automatica ignora os valores passados ³
	//³ para a composicao da base e valor do PIS e COFINS,  ³
	//³ faco a atualizacao manualmente.  (ITENS)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)
	For nG:=1 to Len(aGeral)

		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+aGeral[nG][21])
		nMajCOF := SF4->F4_MALQCOF
		nMajPIS := SF4->F4_MALQPIS

		dbSelectArea("SD1")
		dbSeek(xFilial("SD1")+cDocNFE+cSerieNFE+cFornece+cLojaFor+aGeral[nG][2]+aGeral[nG][1])

		RecLock("SD1",.F.)
		  Replace	D1_BASEIPI	With	aGeral[nG][6]
		  Replace	D1_VALIPI	With	aGeral[nG][7]
		  Replace	D1_BASEICM	With	aGeral[nG][9]
		  Replace	D1_VALICM	With	aGeral[nG][10]
		  Replace	D1_ALQIMP6	With	aGeral[nG][11]
		  Replace	D1_BASIMP6	With	aGeral[nG][12]
		  Replace	D1_VALIMP6	With	aGeral[nG][13]
		  Replace	D1_ALQIMP5	With	aGeral[nG][14]
		  Replace	D1_BASIMP5	With	aGeral[nG][15]
		  Replace	D1_VALIMP5	With	aGeral[nG][16]
		  If !Empty(aGeral[nG][24])
 		    Replace   D1_PEDIDO 	With	aGeral[nG][24]
 		    Replace   D1_ITEMPC 	With	aGeral[nG][25]
 		    Replace   D1_QTDPEDI    With	aGeral[nG][18]
 		  Endif
   		  Replace	D1_II		With	aGeral[nG][19]+aGeral[nG][20]
		  Replace   D1_ALIQII	With	aGeral[nG][26]
		  Replace   D1_DESPESA	With	aGeral[nG][19]+aGeral[nG][20]
  		  //Replace   D1_VALFRE	With	aGeral[nG][19]
		  Replace   D1_VALPMAJ	With	IIF(nMajPIS > 0 , Round(aGeral[nG][12]*(nMajPIS/100),2) , 0 )
		  Replace   D1_VALCMAJ	With	IIF(nMajCOF > 0 , Round(aGeral[nG][15]*(nMajCOF/100),2) , 0 )
		MsUnlock()
		dbCommit()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizo o Pedido de Compra                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//MaAvalPC("SC7",8)
		If !Empty(SD1->D1_PEDIDO+SD1->D1_ITEMPC)
			dbSelectArea("SC7")
			dbSetOrder(19)
			dbSeek(xFilial("SC7")+SD1->D1_COD+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
			RecLock("SC7",.F.)
			  SC7->C7_QUJE 	+= SD1->D1_QTDPEDI
			  SC7->C7_ENCER := IIF(C7_QUANT-C7_QUJE>0," ","E")
			MsUnlock()
			dbCommit()

			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))

			dbSelectArea("SB2")
			dbSetOrder(1)
			If !(cEntrega==SB2->B2_FILIAL .And. SC7->C7_PRODUTO==SB2->B2_COD .And. SC7->C7_LOCAL==SB2->B2_LOCAL)
				If !MsSeek(cEntrega+SC7->C7_PRODUTO+SC7->C7_LOCAL)
					CriaSB2(SC7->C7_PRODUTO,SC7->C7_LOCAL,cEntrega)
				EndIf
			EndIf

			RecLock("SB2",.F.)

			  If SC7->(FieldPos("C7_ESTOQUE"))> 0  .And. lSb1TES
			  	SC1->(dbSetOrder(2))
				SC1->(MsSeek(xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC))

				If (SF4->F4_ESTOQUE=="S" .And. SC1->C1_ESTOQUE=="S") .Or. (SF4->F4_ESTOQUE=="S" .And. Empty(SC1->C1_ESTOQUE))
					SB2->B2_SALPEDI -= SD1->D1_QTDPEDI
					SB2->B2_SALPED2 -= ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2)
				EndIf
			  Else
				If SF4->F4_ESTOQUE=="S" //Atualiza se TES movimentar o Estoque    //..
					If SD1->D1_QTDPEDI > SB2->B2_SALPEDI
						SB2->B2_SALPEDI -= SD1->D1_QTDPEDI - (SD1->D1_QTDPEDI - SB2->B2_SALPEDI)
					Else
						SB2->B2_SALPEDI -= SD1->D1_QTDPEDI
					EndIf
					If ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2) > SB2->B2_SALPED2
						SB2->B2_SALPED2 -= ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2) - (ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2) - SB2->B2_SALPED2)
					Else
						SB2->B2_SALPED2 -= ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2)
					EndIf
				Else
					If Empty(SC7->C7_TES)
						If SD1->D1_QTDPEDI > SB2->B2_SALPEDI
							SB2->B2_SALPEDI -= SD1->D1_QTDPEDI - (SD1->D1_QTDPEDI - SB2->B2_SALPEDI)
						Else
							SB2->B2_SALPEDI -= SD1->D1_QTDPEDI
						EndIf
						If ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2) > SB2->B2_SALPED2
							SB2->B2_SALPED2 -= ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2) - (ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2) - SB2->B2_SALPED2)
						Else
							SB2->B2_SALPED2 -= ConvUm(SD1->D1_COD,SD1->D1_QTDPEDI,0,2)
						EndIf
					EndIf
				EndIf
		  	  EndIf
			MsUnlock()
			dbCommit()
		Endif
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizo o Livro Fiscal atraves do Reprocessamento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
	aParam := {}
	aadd(aParam , DtoC(dDataBase))
	aadd(aParam , DtoC(dDataBase))
	aadd(aParam , 1)
	aadd(aParam , cDocNFE)
	aadd(aParam , cDocNFE)
	aadd(aParam , cSerieNFE)
	aadd(aParam , cSerieNFE)
	aadd(aParam , cFornece)
	aadd(aParam , cFornece)
	aadd(aParam , cLojaFor)
	aadd(aParam , cLojaFor)
	Mata930(.T.,aParam)
	Processa( {|| MATA930(.T.,aParam)} ,"Aguarde" ,"Reprocessando Livro Fiscal...")
	*/
	Pergunte("MTA930",.F.)
	mv_par01 := dDataBase
	mv_par02 := dDataBase
	mv_par03 := 1
	mv_par04 := cDocNFE
	mv_par05 := cDocNFE
	mv_par06 := cSerieNFE
	mv_par07 := cSerieNFE
	mv_par08 := cFornece
	mv_par09 := cFornece
	mv_par10 := cLojaFor
	mv_par11 := cLojaFor
	mv_par12 := xFilial("SF3")
	mv_par13 := xFilial("SF3")
	mv_par14 := 1
	mv_par15 := 2

	//A930RPEntrada(.T.,/*oObj*/,.F.)
	Processa( {|| A930RPEntrada(.T.,/*oObj*/,.F.)} ,"Aguarde" ,"Reprocessando Livro Fiscal...")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³             Estrutura de aGeral2                     ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³   [1] = Aliquota de ICMS                            ³
	//³   [2] = Base ICMS                                   ³
	//³   [3] = Valor ICMS									³
	//³   [4] = Aliquota de IPI                             ³
	//³   [5] = Base IPI                                    ³
	//³   [6] = Valor IPI                                   ³
	//³   [7] = Imposto de Importacao		                ³
	//³   [8] = TES                  		                ³
	//³   [9] = Valor Total do Item                  		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizo o Livro Fiscal (DE NOVO)                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aGeral2 := {}
	nLoc    := 0
	aCampo  := {}
	campo   := ""

	aEval(aGeral,{|campo| aCampo := campo,;
	 nLoc:=aScan(aGeral2,{|X| AllTrim(X[8]) == AllTrim(aCampo[8])}) ,;
	  iif(nLoc==0,AAdd(aGeral2,{aCampo[8],aCampo[9],aCampo[10],aCampo[5],aCampo[6],aCampo[7],aCampo[20],aCampo[21],aCampo[4]}) ,;
	   (aGeral2[nLoc][2]+=X[nLoc][9],aGeral2[nLoc][3]+=X[nLoc][10],aGeral2[nLoc][5]+=X[nLoc][6],aGeral2[nLoc][6]+=X[nLoc][7],aGeral2[nLoc][8]+=X[nLoc][20],aGeral2[nLoc][9]+=X[nLoc][4]) ) })

	dbSelectArea("SF3")
	dbSetOrder(1)
	For nG:=1 To Len(aGeral2)
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+aGeral2[nG][8]))
		cCFOP := SF4->F4_CF
		If dbSeek(xFilial("SF3")+DtoS(dDataBase)+cDocNFE+cSerieNFE+cFornece+cLojaFor+cCFOP+STR(aGeral2[nG][1],5,2))
			RecLock("SF3",.F.)
		  	  Replace	F3_REPROC	With	"N"
		  	  Replace	F3_VALCONT	With	aGeral2[nG][2]-aGeral2[nG][7]					// Base do ICMS - Imposto de Importacao
		  	  Replace	F3_BASEICM	With	iif(SF4->F4_CREDICM=='S' , aGeral2[nG][2] , 0)	// Se TES Creditar ICMS, grava base do imposto
		  	  Replace	F3_VALICM	With	iif(SF4->F4_LFICM=='T'   , aGeral2[nG][3] , 0)	// Se Livro Fiscal do ICMS == Tributado, grava valor do imposto aqui
		  	  Replace	F3_ISENICM	With	iif(SF4->F4_LFICM=='I'   , aGeral2[nG][3] , 0)	// Se Livro Fiscal do ICMS == Isento, grava valor do imposto aqui
		 	  Replace	F3_OUTRICM	With	iif(SF4->F4_LFICM=='O'   , aGeral2[nG][3] , 0)	// Se Livro Fiscal do ICMS == Outros, grava valor do imposto aqui
		 	  Replace	F3_BASEIPI	With	iif(SF4->F4_CREDIPI=='S' , aGeral2[nG][5] , 0)	// Se TES Creditar IPI, grava base do imposto
		 	  Replace	F3_VALIPI	With	iif(SF4->F4_LFIPI=='T'   , aGeral2[nG][6] , 0)	// Se Livro Fiscal do IPI == Tributado, grava valor do imposto aqui
		 	  Replace	F3_ISENIPI	With	iif(SF4->F4_LFIPI=='I'   , aGeral2[nG][6] , 0)	// Se Livro Fiscal do IPI == Isento, grava valor do imposto aqui
		 	  Replace	F3_OUTRIPI	With	iif(SF4->F4_LFIPI=='O'   , aGeral2[nG][3]+aGeral2[nG][9] , 0) 	// Se Livro Fiscal do IPI == Outros, considero Total dos Itens + Total do ICMS e gravo este valor aqui
	  	 	  //Replace	F3_IPIOBS	With	iif(SF4->F4_IPIOBS=='1'  ,
		 	  //Replace	F3_DESPESA	With
			MsUnlock()
			dbCommit()
		Endif
	Next nG

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizo o Livro Fiscal por item.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFT")
	dbSetOrder(1)
	For nG:=1 to Len(aGeral)
		If dbSeek(xFilial("SFT")+"E"+cSerieNFE+cDocNFE+cFornece+cLojaFor+aGeral[nG][1]+aGeral[nG][2])
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+aGeral[nG][21]))
			RecLock("SFT",.F.)
		  	  Replace	FT_QUANT	With	aGeral[nG][18]
		  	  Replace	FT_PRCUNIT	With	aGeral[nG][3]
		  	  Replace	FT_TOTAL	With	aGeral[nG][4]
		  	  Replace	FT_VALCONT	With	aGeral[nG][9]-aGeral[nG][20]
			  Replace	FT_BASEICM	With	aGeral[nG][9]
			  Replace	FT_VALICM	With	iif(SF4->F4_LFICM=='T'   , aGeral[nG][10] , 0)
			  Replace	FT_ISENICM	With	iif(SF4->F4_LFICM=='I'   , aGeral[nG][10] , 0)
		 	  Replace	FT_OUTRICM	With	iif(SF4->F4_LFICM=='O'   , aGeral[nG][10] , 0)
		 	  Replace	FT_BASEIPI	With	iif(SF4->F4_CREDIPI=='S' , aGeral[nG][6] , 0)
		 	  Replace	FT_VALIPI	With	iif(SF4->F4_LFIPI=='T'   , aGeral[nG][7] , 0)
		 	  Replace	FT_ISENIPI	With	iif(SF4->F4_LFIPI=='I'   , aGeral[nG][7] , 0)
		 	  Replace	FT_OUTRIPI	With	iif(SF4->F4_LFIPI=='O'   , aGeral[nG][4]+aGeral[nG][10] , 0)
			  Replace	FT_ALIQPIS	With	aGeral[nG][11]
			  Replace	FT_BASEPIS	With	aGeral[nG][12]
			  Replace	FT_VALPIS 	With	aGeral[nG][13]
			  Replace	FT_ALIQCOF	With	aGeral[nG][14]
			  Replace	FT_BASECOF	With	aGeral[nG][15]
			  Replace	FT_VALCOF 	With	aGeral[nG][16]
			  Replace	FT_VALCONT	With	aGeral[nG][9]
			  //Replace   FT_DESPESA	With	aGeral[nG][19]+aGeral[nG][20]
			MsUnlock()
			dbCommit()
		Endif
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizo o Relacao de Impostos do Doc.Fiscal        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CD2")
	dbSetOrder(2)
	For nG:=1 to Len(aGeral)
		If dbSeek(xFilial("CD2")+"E"+cSerieNFE+cDocNFE+cFornece+cLojaFor+aGeral[nG][1]+aGeral[nG][2])
			While !Eof() .and. CD2_FILIAL==xFilial("CD2") .and.;
			  CD2_TPMOV=="E" .and. CD2_SERIE+CD2_DOC+CD2_CODFOR+CD2_LOJFOR+CD2_ITEM+CD2_CODPRO ==;
			  cSerieNFE+cDocNFE+cFornece+cLojaFor+aGeral[nG][1]+aGeral[nG][2]
				RecLock("CD2",.F.)
				If Alltrim(CD2->CD2_IMP) == "ICM"
  				 	  Replace	CD2_ALIQ	With	aGeral[nG][8]
				  	  Replace	CD2_BC		With	aGeral[nG][9]
				 	  Replace	CD2_VLTRIB	With	aGeral[nG][10]
				ElseIf Alltrim(CD2->CD2_IMP) == "IPI"
  				 	  Replace	CD2_ALIQ	With	aGeral[nG][5]
				  	  Replace	CD2_BC		With	aGeral[nG][6]
				  	  Replace	CD2_VLTRIB	With	aGeral[nG][7]
				ElseIf Alltrim(CD2->CD2_IMP) == "PS2"
  				 	  Replace	CD2_ALIQ	With	aGeral[nG][11]
				  	  Replace	CD2_BC		With	aGeral[nG][12]
				  	  Replace	CD2_VLTRIB 	With	aGeral[nG][13]
				ElseIf Alltrim(CD2->CD2_IMP) == "CF2"
  				 	  Replace	CD2_ALIQ	With	aGeral[nG][14]
					  Replace	CD2_BC		With	aGeral[nG][15]
					  Replace	CD2_VLTRIB	With	aGeral[nG][16]
				Endif
				MsUnlock()
				dbCommit()
				dbSkip()
			Enddo
		Endif
	Next
	*/


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizo o Complemento de Importacao                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CD5")
	For nG:=1 to Len(aGeral)
		RecLock("CD5",.T.)
		  Replace	CD5_FILIAL	With	xFilial("CD5")
		  Replace	CD5_DOC		With	cDocNFE
		  Replace	CD5_SERIE	With	cSerieNFE
		  Replace	CD5_ESPEC	With	"SPED"
  		  Replace	CD5_FORNEC	With	cFornece
  		  Replace	CD5_LOJA	With	cLojaFor
		  Replace	CD5_ITEM	With	aGeral[nG][1]
		  Replace	CD5_TPIMP	With	"0"
		  Replace	CD5_DOCIMP	With	cDocNFE
		  Replace	CD5_BSPIS	With	aGeral[nG][12]
		  Replace	CD5_ALPIS	With	aGeral[nG][11]
		  Replace	CD5_VLPIS	With	aGeral[nG][13]
		  Replace	CD5_BSCOF	With	aGeral[nG][15]
		  Replace	CD5_ALCOF	With	aGeral[nG][14]
		  Replace	CD5_VLCOF	With	aGeral[nG][16]
		  Replace	CD5_LOCAL 	With	"0"
		  Replace	CD5_NDI		With	cNum_DI
		  Replace	CD5_DTDI	With	dDT_DI
		  Replace	CD5_LOCDES	With	cLocDes_DI
		  Replace	CD5_UFDES	With	cUFDes_DI
  		  Replace	CD5_DTDES	With	cDtDes_DI
  		  Replace	CD5_CODEXP	With	cFornece
  		  Replace	CD5_LOJEXP	With	cLojaFor
  		  Replace	CD5_NADIC	With	aGeral[nG][22]
  		  Replace	CD5_SQADIC	With	aGeral[nG][23]
  		  Replace	CD5_CODFAB	With	cFabric
  		  Replace	CD5_LOJFAB	With	cLojaFor
	  	  Replace	CD5_VLRII	With	aGeral[nG][20]
	  	  Replace	CD5_VTRANS	With	'4'
	  	  Replace	CD5_VAFRMM	With	0
	  	  Replace	CD5_INTERM	With	'1'
		MsUnlock()
		dbCommit()
	Next

	dbSelectArea("SE2")
	dbSetOrder(6)
	If dbSeek(xFilial("SE2")+cFornece+cLojaFor+cSerieNFE+cDocNFE,.T.)
		RecLock("SE2",.F.)
		  Replace	E2_VALOR	With	nVBruto
		  Replace	E2_SALDO	With	nVBruto
		  Replace	E2_VLCRUZ	With	nVBruto
		MsUnlock()
		dbCommit()
	Endif

	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(xFilial("SZA")+cSequenc+cFornece+cLojaFor,.T.)

	While !Eof() .and. xFilial("SZA")==ZA_FILIAL .and. ZA_SEQUENC==cSequenc
		RecLock("SZA",.F.)
		  Replace	ZA_STATUS	With	"2"
		  Replace	ZA_NUMDOC	With	cDocNFE
		  Replace	ZA_SERIE	With	cSerieNFE
		  Replace	ZA_DATANF	With	dEmissaoNFE
		MsUnlock()
		dbSkip()
	Enddo

	IW_MsgBox(OemToAnsi("Gerada a nota fiscal com o número/série: "+cDocNFE+"/"+cSerieNFE) , OemToAnsi("Informação") , "INFO")

	cNewNum := Soma1(cDocNFE,Len(Alltrim(cDocNFE)))
	//cNewNum := StrZero(Val(cDocNFE)+1,6)

	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(xFilial("SX5")+"01"+cSerieNFE,.T.)
		RecLock("SX5",.F.)
		  Replace	X5_DESCRI	With	cNewNum
		  Replace 	X5_DESCSPA	With	cNewNum
		  Replace 	X5_DESCENG	With	cNewNum
		MsUnlock()
	Endif

Endif

PutMV("MV_PCNFE",lPcNfe)

RestArea(aAreaAtual)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEICalc ³ Autor ³ Marcos Candido        ³ Data ³ 12/08/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa que apresenta os calculos realizados com base nas ³±±
±±³          ³ informacoes cadastradas.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void NFEIExc(ExpC1,ExpN1,ExpN2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NfeImp01                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEICalc(cAlias,nReg,nOpc)

Local lCalc := .T.

U_NFEIGera(cAlias,nReg,6,lCalc)

Return


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NFEILinOk ³ Autor ³ Marcos Candido        ³ Data ³ 04/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa que faz consistencias apos a digitacao da tela    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFEIIMP01                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEILinOk(o,nx)

LOCAL lRet := .T. , lSai:=.F.
LOCAL cAlias := "SZA"
LOCAL nXZ := 0


// Seta variavel n para valor de nx
If Valtype(nx) == "N"
	n:=nx
EndIf

If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	For nxZ:=1 To Len(aHeader)
		If Empty(aCols[n][nxZ])
			If Trim(aHeader[nxZ][2]) == "ZA_PROD" .AND. n == Len(aCols)
				Help(" ",1,"OBRIGAT2")
				lRet := .F.
				lSai := .T.
			Endif
			If (Trim(aHeader[nxZ][2]) == "ZA_PROD" .OR. Trim(aHeader[nxZ][2]) == "ZA_QUANT") .And. !lSai
				Help(" ",1,"OBRIGAT2")
				lRet := .F.
			Endif
			If (Trim(aHeader[nxZ][2]) == "ZA_LOCAL" .or.;
			   Trim(aHeader[nxZ][2]) == "ZA_VUNIT" .or.;
			   Trim(aHeader[nxZ][2]) == "ZA_TOTAL" .or.;
			   Trim(aHeader[nxZ][2]) == "ZA_Q_ESTOQ") .And. !lSai
				Help(" ",1,"OBRIGAT2")
				lRet := .F.
			Endif
		Endif
		If !lRet
			Exit
		Endif
	Next

	If lRet .And. (INCLUI .or. ALTERA)
		If !lSai
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se a Qtde estiver em branco ele deve dar uma mensagem  ³
			//³ de que este registro nao sera' gravado.                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. Empty(aCols[n][nPosQuant])
				//Help(" ",1,"MA240NAOGR")
				IW_MsgBox(OemToAnsi("O campo Quantidade não foi preenchido.") , OemToAnsi("Atenção") , "ALERT")
				lRet := .F.
			EndIf
			If lRet .And. Empty(GdFieldGet("ZA_ADICAO",n))
				//Help(" ",1,"PEDF_ADICAO")
				IW_MsgBox(OemToAnsi("O campo Adição não foi preenchido.") , OemToAnsi("Atenção") , "ALERT")
				lRet := .F.
			EndIf
			If lRet .And. Empty(GdFieldGet("ZA_SEQ_ADI",n))
				//Help(" ",1,"PW8_SEQ_ADI")
				IW_MsgBox(OemToAnsi("O campo Sequência da Adição não foi preenchido.") , OemToAnsi("Atenção") , "ALERT")
				lRet := .F.
			EndIf
		Else
			lRet := .T.
		Endif

		If !U_ZAVLRTOTAL(aCols[n][nPosTotal])
			Help(" ",1,"TOTAL")
			lRet := .F.
		EndIf
	Endif
	dbSelectarea(cAlias)
EndIf

Return lRet

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NFEITudoOk³ Autor ³ Marcos Candido        ³ Data ³ 04/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a tela toda esta' Ok                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFEIIMP01                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEITudoOk(o)

Local lRetorno := .T.
Local zi := 0


For zi:=1 to Len(aCols)
	If !U_NFEILinOk(nil,zi)
		lRetorno:=.F.
		Exit
	EndIf
Next zi

Return lRetorno


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NFEIGrava ³ Autor ³ Marcos Candido        ³ Data ³ 04/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravar os dados no arquivo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFEIMP01                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NFEIGrava(cAlias,nOpcao)

LOCAL n ,ny ,nMaxArray
LOCAL nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o ultimo elemento do array esta em branco        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMaxArray := Len(aCols)
If Empty(aCols[nMaxArray,nPosCod]) .And. Empty(aCols[nMaxArray,nPosQuant])
	nMaxArray--
Endif

(cAlias)->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula os valores aduaneiros de cada item                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CalcVlrAduan(nMaxArray)

For nx := 1 to nMaxArray
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ verifica se nao esta deletado (DEL)                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nx][Len(aCols[nx])]
		If U_NFEILinOk(nil,nx)
			If !dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor+aCols[nx][nPosItem])
				RecLock(cAlias,.T.)		//	Inclusao
			  	  Replace	ZA_FILIAL	With	xFilial("SZA")
			  	  Replace	ZA_SEQUENC	With	cNumero
			  	  Replace	ZA_FORNECE	With	cFornece
			  	  Replace	ZA_LOJA		With	cLojaFor
  	  			  Replace	ZA_STATUS	With	"1"
			Else
				RecLock(cAlias,.F.)		//	Alteracao
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza dados                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Replace ZA_NUM_DI	With	cNumDI
	  	    Replace	ZA_EMISSAO 	With	dDataEmi
	  	  	Replace	ZA_MOEDA	With	iif(aScan(aMoedas,nMoedaNFEI)==0,2,aScan(aMoedas,nMoedaNFEI))
	  	  	Replace	ZA_TAXA		With	nTaxaMoeda
	  	  	Replace	ZA_IIMPORT	With	nIImport
	  	  	Replace	ZA_CAPATAZ	With	nCapataz
	  	  	Replace ZA_FRETE	With	nFrete
	  	  	Replace	ZA_SEGURO	With	nSeguro
	  	  	Replace ZA_LOCDESE  With	cLocDesemb
			Replace ZA_UFDESEM  With   cUFDesemb
			Replace ZA_DTDESEN  With   dDtDesemb
			Replace	ZA_NFCOMPL  With   cNotaCompl
			Replace ZA_SERNFC  	With   cSerieNFC
	  	  	Replace	ZA_FRETEIN  With   iif(lConsFrete,"S","N")
		  	For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					xVar := Trim(aHeader[ny][2])
					Replace		&xVar.		With	aCols[nx][ny]
				Endif
			Next ny
			MsUnlock()
			dbCommit()
		Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ esta deletado e tem dados, portanto precisa ser excluido da base   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		If !Empty(aCols[nx][nPosCod])
			If dbSeek(xFilial("SZA")+cNumero+cFornece+cLojaFor+aCols[nx][nPosItem])
				RecLock("SZA",.F.)
			  	  dbDelete()
				MsUnlock()
				dbCommit()
			Endif
		Endif
	EndIf
Next nx

FreeUsedCode()
dbSelectArea(cAlias)
dbSetOrder(1)

If IW_MsgBox(OemToAnsi("Deseja que a rotina recalcule os valores rateados dos itens?"),OemToAnsi("Informação") , "YESNO")
	RateioItens(cNumero,cFornece,cLojaFor)
Endif

Return .T.

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEIExclui ³ Autor ³ Marcos Candido     ³ Data ³ 04/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui os dados no arquivo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NFEIExclui(cAlias,nOpcao)

Local nx

(cAlias)->(dbSetOrder(1))

For nx := 1 to Len(aCols)
	If dbSeek(xFilial("SZA")+cNumero,.T.)
		RecLock(cAlias,.F.)
	  	  dbDelete()
		MsUnlock()
		dbCommit()
	Endif
Next nx

FreeUsedCode()

dbSelectArea(cAlias)
dbSetOrder(1)

Return .T.

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NFEILeg  ³ Autor ³ Marcos Candido        ³ Data ³ 04/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra Legenda das cores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFEIMP01                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NFEILeg

Local aCores2 := {}

aCores2 := {{"BR_VERDE"		,"Dados aguardando utilização"},;
			{"BR_VERMELHO"	,"Dados já utilizados"}}

BrwLegenda(cCadastro,OemtoAnsi("Situação dos registros"),aCores2)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VeForn   ºAutor  ³Microsiga           º Data ³  06/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consiste codigo e loja do fornecedor                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NFEIMP01                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VeForn(cFornece,cLojaForn,cNomFor)

Local lRet := .T.
Local aAreaAtual := GetArea()

dbSelectArea("SA2")
dbSetOrder(1)
If Empty(cLojaForn)
	If !dbSeek(xFilial("SA2")+cFornece,.T.)
		ExistCpo('SA2',cFornece)
		lRet := .F.
	Else
		cLojaFor := SA2->A2_LOJA
		cNomFor  := SA2->A2_NOME
	Endif
Else
	If !ExistCpo('SA2',cFornece+cLojaForn)
		lRet := .F.
	Else
		cNomFor := SA2->A2_NOME
	Endif
Endif

RestArea(aAreaAtual)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZAVLRTOTAL  ºAutor  ³ Marcos Candido   º Data ³  10/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica preenchimento do campo TOTAL.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZAVLRTOTAL(nVTotal)

Local nDif    := 0 , lRet := .T.
Local nQtd    := aCols[n,nPosQuant]
Local nVUnit  := aCols[n,nPosVUnit]

nDif := ABS(Round(nQtd * nVUnit , 2)-nVTotal)

If nDif # 0
	lRet := .F.
Endif

Return lRet

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ IncluiNFEI  ³ Autor ³ Marcos Candido     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para incluir as notas de entrada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IncluiNFEI

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

Begin Transaction

	MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aTotItem,3)  // documento de entrada

	//MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aTotItem,3)	// pre nota

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
	Endif

End Transaction

Return(!lMsErroAuto)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ CalcVlrAduan  ³ Autor ³ Marcos Candido     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para calcular o valor aduaneiro da mercadoria         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalcVlrAduan(nItensaCols)

Local nVlrAduan := 0 , nVlrTotAduan := 0
Local aInfoV := {} , aInfoP := {}
Local nMargemV := 0 , nMargemP := 0
Local nPeso := 0 , nTotPeso := 0

If IW_MsgBox(OemToAnsi("O Valor do Frete já consta no Valor Unitário?") , OemToAnsi("Informação") , "YESNO")
	lConsFrete := .T.
Else
	lConsFrete := .F.
Endif

For nM:=1 to nItensaCols

	If !aCols[nM][Len(aCols[nM])]
	  	For nV := 1 to Len(aHeader)
			If aHeader[nV][10] # "V"
				xConteud := Trim(aHeader[nV][2])
				If xConteud == "ZA_TOTAL"
					nVlrAduan    := Round(aCols[nM][nV] * nTaxaMoeda , 7)
					nVlrTotAduan += Round(nVlrAduan,3)
				Endif
				If xConteud == "ZA_PESO"
					nPeso    := aCols[nM][nV]
					nTotPeso += aCols[nM][nV]
				Endif
			Endif
		Next
		aadd(aInfoV , nVlrAduan )
		aadd(aInfoP , nPeso )
   Endif

Next

For nM:=1 to nItensaCols

	If !aCols[nM][Len(aCols[nM])]
	  	For nV := 1 to Len(aHeader)
			If aHeader[nV][10] # "V"
				xConteud := Trim(aHeader[nV][2])
				If xConteud == "ZA_VADUANA"
					nMargemV := Round(aInfoV[nM]/nVlrTotAduan,7)
					nMargemP := Round(aInfoP[nM]/nTotPeso,7)
					nVlr1   := Round((nCapataz+nSeguro) * nMargemV,6)
					nVlr2   := Round(IIf(lConsFrete,0,nFrete) * nMargemP,6)
					aCols[nM][nV] := Round(aInfoV[nM]+nVlr1+nVlr2,6)
				Endif
			Endif
		Next
	Endif

Next

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RateioItens  ºAutor  ³ Marcos Candido  º Data ³  26/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RateioItens(cSequenc,cFornece,cLojaFor)

Local nPeso := 0 , nQuant := 0
Local nVlrTotal := 0
Local aItem := {} , aRateio := {} , aIPI := {} , aICMS := {} , aPisCof := {} , aGeral := {}
Local nRateio   := 0
Local nSiscomex := 0
Local nCapSegII := 0
Local nSegRat   := 0
Local nCapSegRat:= 0
Local nCapRat   := 0
Local nFretRat  := 0
Local nIIRat    := 0
Local nIImport  := 0
Local nCapataz  := 0
Local nFrete    := 0
Local nSeguro   := 0
Local lConsFrete := .F.

Local nBCIPI    := 0
Local nVlrIPI   := 0
Local nTotBCIPI := 0
Local nTotVlIPI := 0

Local nBaseICMS  := 0
Local nVlrICMS   := 0
Local nTotBCICMS := 0
Local nTotVlICMS := 0

Local nNumerador   := 0
Local nDenominador := 0
Local nResult      := 0

Local nVlrPIS      := 0
Local nBasePIS     := 0
Local nTotVlPIS    := 0

Local nVlrCofins   := 0
Local nBaseCofins  := 0
Local nTotVlCOF    := 0

Local nTotBCPIS    := 0
Local nTotBCCOF    := 0

Local dDataDI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Soma as quantidade de todos os itens para fazer o   ³
//³ rateio por margem de contribuicao.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSeek(xFilial("SZA")+cSequenc+cFornece+cLojaFor,.T.)
While !Eof() .and. xFilial("SZA")==ZA_FILIAL .and. ZA_SEQUENC==cSequenc
	nPeso      += IIF(ZA_PESO > 0 , ZA_PESO , 1)
	nVlrTotal  += ZA_TOTAL
	nIImport   := ZA_IIMPORT
	nCapataz   := ZA_CAPATAZ
	nFrete     := ZA_FRETE
	nSeguro    := ZA_SEGURO
	lConsFrete := IIF(ZA_FRETEIN=="S",.T.,.F.)

	nAux1 := Round(ZA_VADUANA/ZA_Q_ESTOQ,4)
	nAux1 := Round(nAux1 * ZA_Q_ESTOQ,4)

	If nAux1 <> ZA_VADUANA
		RecLock("SZA",.F.)
		  ZA_VADUANA := nAux1
		MsUnlock()
	Endif

	aadd(aItem , {ZA_ITEM , ZA_PESO , ZA_TOTAL , IIF(ZA_ALIQIPI>0,(ZA_ALIQIPI/100),0) , (ZA_ALIQII/100) ,;
	                ZA_VADUANA , IIF(ZA_ALIQICM>0,(ZA_ALIQICM/100),0) , (ZA_ALIQPIS/100) , (ZA_ALIQCOF/100) , ZA_PROD ,;
	                ZA_PESO , ZA_LOCAL , ZA_Q_ESTOQ , ZA_SISCOME , ZA_TES})

    dDataDI     := SZA->ZA_EMISSAO
    nQuant      += ZA_QUANT

	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apuro a margem de contribuicao de cada item e       ³
//³ distribuo o valor das despesas neles                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nA:=1 to Len(aItem)
	nSiscomex += aItem[nA][14]
	nCapRat   := nCapataz * Round((aItem[nA][2] / nPeso),6)
	nRateio   := 0
	nSegRat   := nSeguro * Round((aItem[nA][2] / nPeso),6)
	nFretRat  := nFrete  * Round((aItem[nA][2] / nPeso),6)
	nIIRat    := aItem[nA][6] * aItem[nA][5]
	nCapSegRat:= (nCapataz+nSeguro) * Round((aItem[nA][3] / nVlrTotal),6)
	nCapSegII := (nCapataz+nSeguro+nIImport+iif(lConsFrete,0,nFrete)) * Round((aItem[nA][2] / nPeso),6)

	aadd(aRateio , {aItem[nA][1] , nRateio , aItem[nA][3] , aItem[nA][4] , aItem[nA][5] ,;
	                 aItem[nA][6] , aItem[nA][7] , aItem[nA][8] , aItem[nA][9] , aItem[nA][10] ,;
	                  aItem[nA][14] , aItem[nA][11] , aItem[nA][12] , aItem[nA][13] , aItem[nA][14] ,;
	                   nCapSegII , nSegRat , nCapRat , nFretRat , nIIRat ,;
	                    nCapSegRat , aItem[nA][15]})
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Estrutura de aRateio                    ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³   [1] = Item                                        ³
//³   [2] = SEM VALOR                                   ³
//³   [3] = Total do item                               ³
//³   [4] = Aliquota de IPI                             ³
//³   [5] = Aliquota de II                              ³
//³   [6] = Valor Aduaneiro                             ³
//³   [7] = Aliquota de ICMS                            ³
//³   [8] = Aliquota de PIS                             ³
//³   [9] = Aliquota da COFINS                          ³
//³  [10] = Codigo do produto                           ³
//³  [11] = Valor rateado do SISCOMEX                   ³
//³  [12] = Peso do produto                             ³
//³  [13] = Armazem                                     ³
//³  [14] = Quantidade do Produto                       ³
//³  [15] = Siscomex Rateado				            ³
//³  [16] = Vlr Rateado das Capatazias, Seguro ,        ³
//³         Imp. Import e Frete                         ³
//³  [17] = Seguro Rateado  				            ³
//³  [18] = Capatazias Rateadas 			            ³
//³  [19] = Frete rateado    			                ³
//³  [20] = Imposto de Importacao Rateado    			³
//³  [21] = Seguro+Capatazias Rateadas       			³
//³  [22] = TES                              			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apuro a base de calculo e valor do IPI para cada    ³
//³ item.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nB:=1 to Len(aRateio)
	nBCIPI       := NoRound(NoRound(aRateio[nB][6],3) * (1+aRateio[nB][5]),3)
	nVlrIPI      := NoRound(nBCIPI * aRateio[nB][4] , 3)
	aadd(aIPI , {aRateio[nB][1] , nBCIPI , nVlrIPI})
	nTotBCIPI += nBCIPI
	nTotVlIPI += nVlrIPI
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Estrutura de aIPI                       ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³   [1] = Item                                        ³
//³   [2] = Base de Calculo IPI                         ³
//³   [3] = Valor do IPI                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apuro a base de calculo e valor do PIS e COFINS     ³
//³ para cada item.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nC:=1 to Len(aRateio)

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avalio se ha percentual de reducao para a base      ³
	//³ de calculo do ICMS.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPRed := Posicione("SF4",1,xFilial("SF4")+aRateio[nC][22],"F4_BASEICM")

	nNumerador   := 1+((aRateio[nC][7]*IIf(nPRed>0,nPRed/100,1))*(aRateio[nC][5]+(aRateio[nC][4]*(1+aRateio[nC][5]))))
	nDenominador := (1-aRateio[nC][8]-aRateio[nC][9])*(1-(aRateio[nC][7]*IIf(nPRed>0,nPRed/100,1)))
	nResult      := Round(nNumerador/nDenominador,9)
	nVlrPIS      := Round(aRateio[nC][8]*(aRateio[nC][6]*nResult),3)
	nBasePIS     := Round(nVlrPis / aRateio[nC][8],6)
	nVlrCofins   := Round(aRateio[nC][9]*(aRateio[nC][6]*nResult),3)
	nBaseCofins  := Round(nVlrCofins / aRateio[nC][9],6)

	//- novo calculo -//
	nBasePIS     := Round(Round(aRateio[nC][6],3),7)
	nVlrPIS      := Round(nBasePIS*aRateio[nC][8] , 7)
	nBaseCofins  := Round(Round(aRateio[nC][6],3),7)
	nVlrCofins   := Round( nBaseCofins * aRateio[nC][9] , 7)

	aadd(aPisCof , {aRateio[nC][1] , nBasePIS , nVlrPIS , nBaseCofins , nVlrCofins})
	nTotBCPIS += nBasePIS
	nTotVlPIS += nVlrPIS
	nTotBCCOF += nBaseCofins
	nTotVlCOF += nVlrCofins
	*/

	nNumerador   := 1
	nDenominador := (1-aRateio[nC][8]-aRateio[nC][9])
	nResult      := Round(nNumerador/nDenominador,9)
	nBasePIS     := Round(Round(aRateio[nC][6],3) , 6)			// Round(nVlrPis / aRateio[nC][8],6)
	nVlrPIS      := Round(nBasePIS*aRateio[nC][8] , 6)			// Round(aRateio[nC][8]*aRateio[nC][6],6)
	nBaseCofins  := Round(Round(aRateio[nC][6],3) , 6)			// Round(nVlrCofins / aRateio[nC][9],6)
	nVlrCofins   := Round(nBaseCofins * aRateio[nC][9] , 6)	// Round(aRateio[nC][9]*aRateio[nC][6],6)

	aadd(aPisCof , {aRateio[nC][1] , nBasePIS , nVlrPIS , nBaseCofins , nVlrCofins})

	nTotBCPIS += nBasePIS
	nTotVlPIS += nVlrPIS
	nTotBCCOF += nBaseCofins
	nTotVlCOF += nVlrCofins
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Estrutura de aPisCof                    ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³   [1] = Item                                        ³
//³   [2] = Base de Calculo PIS                         ³
//³   [3] = Valor do PIS                                ³
//³   [4] = Base de Calculo COFINS                      ³
//³   [5] = Valor do COFINS                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apuro a base de calculo e valor do ICMS             ³
//³ para cada item.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nD:=1 to Len(aRateio)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avalio se ha percentual de reducao para a base      ³
	//³ de calculo do ICMS.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPRed := Posicione("SF4",1,xFilial("SF4")+aRateio[nD][22],"F4_BASEICM")

	If aRateio[nD][7] > 0  // verifica se a aliquota de ICMS eh maior que zero
		nNumerador   := aRateio[nD][6]+Round(aRateio[nD][6]*aRateio[nD][5],5)+aIPI[nD][3]+aPisCof[nD][3]+aPisCof[nD][5]+aRateio[nD][11]
		nDenominador := 1-aRateio[nD][7]
		nBaseICMS    := Round(nNumerador/nDenominador,3)
		nBaseICMS    := IIf(nPRed>0,nPRed/100,1)*nBaseICMS
		nVlrICMS     := Round(nBaseICMS*aRateio[nD][7],3)
	Else
		//nBaseICMS    := 0
		nVlrICMS     := 0
	Endif

	aadd(aICMS , {aRateio[nD][1] , nBaseICMS , nVlrICMS})
	nTotBCICMS += nBaseICMS
	nTotVlICMS += nVlrICMS
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Estrutura de aICMS                      ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³   [1] = Item                                        ³
//³   [2] = Base de Calculo ICMS                        ³
//³   [3] = Valor do ICMS                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nE:=1 to Len(aRateio)
	aadd(aGeral , {aRateio[nE][1] , 0 , 0 , 0 , 0 ,;
	                0 , iif(aIPI[nE][3]>0 , aIPI[nE][2] , 0) , aIPI[nE][3] , aRateio[nE][7]*100 , aICMS[nE][2] ,;
	                 aICMS[nE][3] , aRateio[nE][8]*100 , aPisCof[nE][2] , aPisCof[nE][3] , aRateio[nE][9]*100 ,;
	                  aPisCof[nE][4] , aPisCof[nE][5] , aRateio[nE][13] , aRateio[nE][14] , aRateio[nE][15] ,;
	                   aRateio[nE][17] , aRateio[nE][18] , aRateio[nE][19] , aRateio[nE][20]})
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Estrutura de aGeral                     ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³   [1] = Item                                        ³
//³   [2] = ZERO                                        ³
//³   [3] = ZERO                                        ³
//³   [4] = ZERO                                        ³
//³   [5] = ZERO                                        ³
//³   [6] = ZERO                                        ³
//³   [7] = Base IPI                                    ³
//³   [8] = Valor IPI                                   ³
//³   [9] = Aliquota de ICMS                            ³
//³  [10] = Base ICMS                                   ³
//³  [11] = Valor ICMS									³
//³  [12] = Aliquota PIS                                ³
//³  [13] = Base PIS                                    ³
//³  [14] = Valor PIS									³
//³  [15] = Aliquota COFINS                             ³
//³  [16] = Base COFINS                                 ³
//³  [17] = Valor COFINS								³
//³  [18] = Armazem         				            ³
//³  [19] = Quantidade do Produto			            ³
//³  [20] = Siscomex Rateado				            ³
//³  [21] = Seguro          				            ³
//³  [22] = Capatazias Rateadas	                        ³
//³  [23] = Frete           				            ³
//³  [24] = Imposto de Importacao		                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SZA")
For nF:=1 to Len(aGeral)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza dados                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek(xFilial("SZA")+cSequenc+cFornece+cLojaFor+aGeral[nF][1])
	RecLock("SZA",.F.)
	  Replace	  ZA_BASIPI	With	aGeral[nF][7]
	  Replace	  ZA_VLRIPI	With	aGeral[nF][8]
  	  Replace	  ZA_BASICM	With	aGeral[nF][10]
	  Replace	  ZA_VLRICM	With	aGeral[nF][11]
	  Replace	  ZA_BASPIS	With	aGeral[nF][13]
	  Replace	  ZA_VLRPIS	With	aGeral[nF][14]
	  Replace	  ZA_BASCOF	With	aGeral[nF][16]
	  Replace	  ZA_VLRCOF	With	aGeral[nF][17]
	  Replace	  ZA_VLRSEG	With	aGeral[nF][21]
	  Replace	  ZA_VLRSIS	With	aGeral[nF][20]
	  Replace	  ZA_VLRCAP	With	aGeral[nF][22]
	  Replace	  ZA_VLRFRE	With	aGeral[nF][23]
	  Replace	  ZA_VLRII	With	aGeral[nF][24]
	MsUnlock()
	dbCommit()
Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NfeForF5 ³ Autor ³ Marcos Candido        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de importacao de Pedidos de Compra.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NFEForF5(aCols)

Local nSldPed    := 0
Local nOpc       := 0
Local nx         := 0
Local cQuery     := ""
Local cAliasSC7  := "SC7"
Local cQueryQPC  := ""
Local bSavKeyF5  := SetKey(VK_F5,Nil)
Local cChave     := ""
Local cCadastro  := ""
Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSC7   := SC7->(GetArea())
Local nF4For     := 0
Local oOk        := LoadBitMap(GetResources(), "LBOK")
Local oNo        := LoadBitMap(GetResources(), "LBNO")
Local aButtons   := { {'PESQUISA',{||A103VisuPC(aRecSC7[oListBox:nAt])},OemToAnsi("Visualiza Pedido"),OemToAnsi("Visualiza Pedido")} }
Local oDlg,oListBox
Local cNomeFor   := ''
Local aTitCampos := {}
Local aConteudos := {}
Local bLine      := { || .T. }
Local cLine      := ""
Local nLoop      := 0
Local lContinua  := .T.
Local oPanel

PRIVATE aF4For     := {}
PRIVATE aRecSC7    := {}
PRIVATE aGets      := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando algum campo estiver em edicao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. IsInCallStack("EDITCELL")
	lContinua:=.F.
EndIf

If lContinua

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o aCols esta vazio, se o Tipo da Nota e'     ³
	//³ normal e se a rotina foi disparada pelo campo correto    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA2")
	DbSetOrder(1)
	MsSeek(xFilial("SA2")+cFornece+cLojaFor)
	cNomeFor	:= SA2->A2_NOME

	DbSelectArea("SC7")

	SC7->( DbSetOrder( 9 ) )

	cAliasSC7 := "QRYSC7"

	cQuery := "SELECT R_E_C_N_O_ RECSC7 FROM "
	cQuery += RetSqlName("SC7") + " SC7 "
	cQuery += "WHERE "
	cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "
	cQuery += "C7_FORNECE = '"+cFornece+"' AND "
	cQuery += "C7_LOJA = '"+cLojaFor+"' AND "
	cQuery += "(C7_QUANT-C7_QUJE-C7_QTDACLA)>0 AND "
	cQuery += "C7_RESIDUO=' ' AND "
	cQuery += "C7_TPOP<>'P' AND "

	If SuperGetMV("MV_RESTNFE")=="S"
		cQuery += "C7_CONAPRO<>'B' AND "
	EndIf

	cQuery += "SC7.D_E_L_E_T_ = ' '"
	cQuery += "ORDER BY " + SqlOrder( SC7->( IndexKey() ) )
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)

	Do While (cAliasSC7)->(!Eof())

		('SC7')->(dbGoto((cAliasSC7)->RECSC7))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Saldo do Pedido de Compra                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSldPed := ('SC7')->C7_QUANT-('SC7')->C7_QUJE-('SC7')->C7_QTDACLA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se nao h  residuos, se possui saldo em abto e   ³
		//³ se esta liberado por alcadas se houver controle.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( Empty(('SC7')->C7_RESIDUO) .And. nSldPed > 0 .And.;
				If(SuperGetMV("MV_RESTNFE")=="S",('SC7')->C7_CONAPRO <> "B",.T.).And.;
				('SC7')->C7_TPOP <> "P" )

			nF4For := aScan(aF4For,{|x|x[2]==('SC7')->C7_LOJA .And. x[3]==('SC7')->C7_NUM})

			If ( nF4For == 0 )
				aConteudos := {.F.,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }
				aAdd(aF4For , aConteudos )
				aAdd(aRecSC7, ('SC7')->(Recno()))
			EndIf
		EndIf

		(cAliasSC7)->(dbSkip())

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe os dados na Tela                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !Empty(aF4For) )

		aTitCampos := {" ",OemToAnsi("Loja"),OemToAnsi("Num.Pedido"),OemToAnsi("Emissao"),OemToAnsi("Origem")}

		cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5]"

		cLine += " } "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta dinamicamente o bline do CodeBlock                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bLine := &( "{ || " + cLine + " }" )

		DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi("Selecionar Pedido de Compra - <F5>") Of oMainWnd PIXEL

		@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
		oPanel:Align := CONTROL_ALIGN_TOP

		oListBox := TWBrowse():New( 27,4,243,86,,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:SetArray(aF4For)
		oListBox:bLDblClick := { || aF4For[oListBox:nAt,1] := !aF4For[oListBox:nAt,1] }
		oListBox:bLine := bLine

		oListBox:Align := CONTROL_ALIGN_ALLCLIENT

		@ 6  ,4   SAY OemToAnsi("Fornecedor") Of oPanel PIXEL SIZE 47 ,9
		@ 4  ,35  MSGET cNomeFor PICTURE PesqPict('SA2','A2_NOME') When .F. Of oPanel PIXEL SIZE 120,9

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpc := 1,nF4For := oListBox:nAt,oDlg:End())},{||(nOpc := 0,nF4For := oListBox:nAt,oDlg:End())},,aButtons)

		Processa({|| NfeProcPC(aF4For,nOpc,cFornece,cLojaFor,@nSldPed)})

	Else
		//Help(" ",1,"A103F4")
		Help(" ",1,"A140F4")
	EndIf

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integrida dos dados de Entrada                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAliasSC7)
dbCloseArea()
DbSelectArea("SC7")

SetKey(VK_F5,bSavKeyF5)

RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NfeProcPC| Autor ³ Marcos Candido        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o carregamento do pedido de compras para a tela   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os itens do pedido de compras            ³±±
±±³          ³ ExpN1 = Opcao valida                                       ³±±
±±³          ³ ExpC1 = Fornecedor                                         ³±±
±±³          ³ ExpC2 = loja fornecedor                                    ³±±
±±³          ³ ExpL1 = retorno do ponto de entrada                        ³±±
±±³          ³ ExpL2 = Uso do ponto de entrada                            ³±±
±±³          ³ ExpN2 = Saldo do pedido                                    ³±±
±±³          ³ ExpL3 = Usa funcao fiscal                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NfeProcPC(aF4For,nOpc,cFornece,cLojaFor,nSldPed)

Local nx         := 0
Local cSeek      := ""
Local cFilialOri :=""
Local cItem		 := StrZero(1,Len(SZA->ZA_ITEM))
Local lZeraCols  := .T.
Local aMT103NPC  := {}
Local aColsBkp   := Aclone(Acols)
Local cPrdNCad   := ""

Private aGets    := {}

If ( nOpc == 1 )

	For nx	:= 1 to Len(aF4For)

		If aF4For[nx][1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Fornecedor                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SA2")
			DbSetOrder(1)
			MsSeek(xFilial("SA2")+cFornece+cLojaFor)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Pedido de Compra                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SC7")
			DbSetOrder(9)
			cSeek := ""
			cSeek += xFilEnt(xFilial("SC7"))+cFornece
			cSeek += aF4For[nx][2]+aF4For[nx][3]
			MsSeek(cSeek)
			If lZeraCols
				aCols		:= {}
				lZeraCols	:= .F.
			EndIf

			// Muda ordem para trazer ordenado por item
			If !Eof()
				cSeek      :=xFilEnt(xFilial("SC7")) + aF4For[nx][3]
				cFilialOri :=C7_FILIAL
				DbSetOrder(14)
				dbSeek(cSeek)
			EndIf

			While ( !Eof() .And. SC7->C7_FILENT+SC7->C7_NUM==cSeek )
				// Verifica se o fornecedor esta correto
				If C7_FILIAL+C7_FORNECE+C7_LOJA == cFilialOri+cFornece+ aF4For[nx][2]
				    // Verifica se o Produto existe Cadastrado na Filial de Entrada
				    DbSelectArea("SB1")
					DbSetOrder(1)
					MsSeek(xFilial("SB1") + SC7->C7_PRODUTO)
					IF !Eof()
					    DbSelectArea("SC7")
						nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
						If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
							PC2Acol(SC7->(RecNo()),,nSlDPed,cItem)
							cItem := SomaIt(cItem)
						EndIf
					Else
					   cPrdNCad += "O Pedido : "+SC7->C7_NUM+"  "+"não encontrou o produto: "+SC7->C7_PRODUTO+CHR(10)
			   		EndIf
				EndIf

				DbSelectArea("SC7")
				dbSkip()
			EndDo
		EndIf
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe Lista dos Produtos não Cadastrados na Filial de Entrega |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Len(cPrdNCad)>0
	   Aviso("NfeProcPC","Verifique, pois os Produtos listados abaixo não estão cadastrados na Filial de Entrega:"+CHR(10)+cPrdNCad,{"Ok"})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o Acols caso o mesmo estiver vazio |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Acols)=0
	    aCols:= aColsBKP
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impede que o item do PC seja deletado pela getdados da NFE na movimentacao das setas. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type( "oGet" ) == "O"
		oGet:lNewLine:=.F.
		oGet:oBrowse:Refresh()
	EndIf

EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NfePC2Acol³ Autor ³ Edson Maricate        ³ Data ³27.01.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Esta rotina atualiza o acols com base no item do pedido de   ³±±
±±³          ³compra                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Numero do registro do SC7                            ³±±
±±³          ³ExpN2 : Item da NF                                           ³±±
±±³          ³ExpN3 : Saldo do Pedido                                      ³±±
±±³          ³ExpC4 : Item a ser carregado no aCols ( D1_ITEM )            ³±±
±±³          ³ExpL5 : Indica se os dados da Pre-Nota devem ser preservados ³±±
±±³          ³ExpA6 : Valores das despesas acessorias do pedido de compras ³±±
±±³          ³ExpN4 : Preco unitário na Pré-Nota						   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Sempre .T.                                            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar a funcao fiscal com  ³±±
±±³          ³base no item do pedido de compra.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PC2Acol(nRecSC7,nItem,nSalPed,cItem)

Local aArea		  := GetArea()
Local aAreaSC7	  := SC7->(GetArea())
Local aAreaSF4	  := SF4->(GetArea())
Local aAreaSB1	  := SB1->(GetArea())
Local nX          := 0
Local nCntFor     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia do item do acols                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nItem == Nil .Or. nItem > Len(aCols)
	aadd(aCols,Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		If IsHeadRec(aHeader[nX][2])
		    aCols[Len(aCols)][nX] := 0
		ElseIf IsHeadAlias(aHeader[nX][2])
		    aCols[Len(aCols)][nX] := "SZA"
		ElseIf Trim(aHeader[nX][2]) == "ZA_ITEM"
			aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,Len(SZA->ZA_ITEM)))
		Else
			aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Next nX
	nItem := Len(aCols)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registros                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
MsGoto(nRecSC7)

dbSelectArea("SB1")
dbSetOrder(1)
MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o acols com base no pedido de compras               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 To Len(aHeader)
	Do Case
	Case Trim(aHeader[nCntFor,2]) == "ZA_PROD"
		aCols[nItem,nCntFor] := SC7->C7_PRODUTO
	Case Trim(aHeader[nCntFor,2]) == "ZA_PESO"
		aCols[nItem,nCntFor] := IIF(SB1->B1_PESO > 0 , SB1->B1_PESO , 1)
	Case Trim(aHeader[nCntFor,2]) == "ZA_QUANT"
		aCols[nItem,nCntFor] := nSalPed
	Case Trim(aHeader[nCntFor,2]) == "ZA_Q_ESTOQ"
		aCols[nItem,nCntFor] := nSalPed      	// VERIFICAR
	Case Trim(aHeader[nCntFor,2]) == "ZA_VUNIT"
		aCols[nItem,nCntFor] := SC7->C7_PRECO
	Case Trim(aHeader[nCntFor,2]) == "ZA_TOTAL"
		aCols[nItem,nCntFor] := SC7->C7_PRECO * nSalPed
	Case Trim(aHeader[nCntFor,2]) == "ZA_TES" .And. !Empty(SC7->C7_TES)
		aCols[nItem,nCntFor] := SC7->C7_TES
	Case Trim(aHeader[nCntFor,2]) == "ZA_LOCAL"
		aCols[nItem,nCntFor] := SC7->C7_LOCAL
	Case Trim(aHeader[nCntFor,2]) == "ZA_ALIQIPI"
		aCols[nItem,nCntFor] := SB1->B1_IPI
	Case Trim(aHeader[nCntFor,2]) == "ZA_NCM"
		aCols[nItem,nCntFor] := SB1->B1_POSIPI
	Case Trim(aHeader[nCntFor,2]) == "ZA_ALIQPIS"
		aCols[nItem,nCntFor] := GetMV("MV_TXPIS")
	Case Trim(aHeader[nCntFor,2]) == "ZA_ALIQCOF"
		aCols[nItem,nCntFor] := GetMV("MV_TXCOFIN")
	Case Trim(aHeader[nCntFor,2]) == "ZA_FABRIC"
		aCols[nItem,nCntFor] := cFornece
	Case Trim(aHeader[nCntFor,2]) == "ZA_PEDIDO"
		aCols[nItem,nCntFor] := SC7->C7_NUM
	Case Trim(aHeader[nCntFor,2]) == "ZA_ITEMPC"
		aCols[nItem,nCntFor] := SC7->C7_ITEM
	EndCase
Next nCntFor

RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aAreaSC7)
RestArea(aArea)

Return .T.