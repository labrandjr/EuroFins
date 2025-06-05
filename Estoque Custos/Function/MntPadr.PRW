#include "totvs.ch"
#DEFINE MAXGETDAD 120
#DEFINE ENTER CHR(13)+CHR(10)
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MntPadr  ºAutor  ³ Marcos Candido     º Data ³  18/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa que possibilitara a digitacao dos dados ineren-   º±±
±±º          ³ tes aos produtos que deverao receber baixa automatica do   º±±
±±º          ³ estoque. Esse diferimento esta visando os produtos do      º±±
±±º          ³ grupo de produtos igual a MV_ZZGRUPO.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  Especifico Eurofins                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} MntPadr
Digitacao dos dados inerentes aos produtos que deverao receber baixa automatica do estoque, ou seja, grupo de produtos igual a MV_ZZGRUPO.
@author Marcos Candido
@since 02/01/2018

/*/
User Function MntPadr

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCores := {}

Private cCadastro:=OemToAnsi("Diferimento Automático")
Private aRotina := {}

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
aRotina := { {OemToAnsi("Pesquisar")		,"AxPesqui"		, 0 , 1},;
			 {OemToAnsi("Visualizar")		,"U_PadBrw"		, 0 , 2},;
			 {OemToAnsi("Incluir")			,"U_PadBrw"		, 0 , 3},;
			 {OemToAnsi("Excluir") 			,"U_PadBrw"		, 0 , 5 , 21},;
			 {OemToAnsi("Baixa Total") 		,"U_PadBxT"		, 0 , 2},;
		 	 {OemToAnsi("Legenda")			,"U_PadLeg"		, 0 , 2,0}}

//			 {OemToAnsi("Alterar")			,"U_PadBrw"		, 0 , 4 , 20},;

aCores := {	{"ZD_STATUS=='1'"	,'BR_VERDE' },;		// Produto ainda nao diferido
			{"ZD_STATUS=='2'"	,'BR_AZUL' },;		// Produto em Diferimento
			{"ZD_STATUS=='3'"	,'BR_VERMELHO'}}	// Produto ja Diferido


//If SM0->M0_CODIGO # '01'																							//Retirado em 22/05/15 conforme chamado. - Roudineli Totvs
//	Aviso(OemToAnsi('Atenção!!!'), OemToAnsi('Esta rotina só pode ser executada na empresa Eurofins.') , {'Sair'})	//Retirado em 22/05/15 conforme chamado. - Roudineli Totvs
//	Return																											//Retirado em 22/05/15 conforme chamado. - Roudineli Totvs
//Endif																												//Retirado em 22/05/15 conforme chamado. - Roudineli Totvs

dbSelectArea("SZD")
dbSetOrder(1)

mBrowse(6,1,22,75,"SZD",,,,,,aCores)

dbSelectArea("SZD")
RetIndex("SZD")
dbClearFilter()


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  PadInc  ³ Autor ³ Marcos Candido        ³ Data ³ 18/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao dos produtos que serao baixados     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void  PadInc(ExpC1,ExpN1,ExpN2)                            ³±±
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
User Function PadBrw(cAlias,nReg,nOpc)

Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize()
Local aButtons  := {}

Local cSeek     := ""
Local cWhile    := ""

Local lContinua := .T.
Local lInclui   := (nOpc == 3)
Local lAltera   := (nOpc == 6)

Local nOpca     := 0
Local cCadastro := OemToAnsi("Diferimento Automático")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oDlg
Private aCols     := {}
Private aHeader   := {}
Private aTELA[0][0],aGETS[0]

If nOpc > Len(aRotina)
	nOpc := 1
Endif

SaveInter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F4 para comunicacao com saldos em estoque        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F4 TO U_MostraEst()

If nOpc == 4
	If SZD->ZD_STATUS == '2'
		IW_MsgBox("Produto não pode ser excluído, pois já está em processo de Diferimento." , "Atenção" , "STOP")
		lContinua := .F.
	ElseIf SZD->ZD_STATUS == '3'
		IW_MsgBox("Produto não pode ser excluído, pois já foi Diferido." , "Atenção" , "STOP")
		lContinua := .F.
	Endif
Endif

If lContinua

	If lInclui
		RegToMemory( "SZD", .T., .F. )
	Else
		If lAltera
			SoftLock("SZD")
			RegToMemory( "SZD", .F., .F. )
		Else
			RegToMemory( "SZD", .F., .F. )
			lContinua := .T.
		EndIf
	EndIf

	dbSelectArea("SZE")
	dbSetOrder(1)

	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHeader e aCols utilizando a funcao FillGetDados.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lInclui
			cSeek  := xFilial("SZE")+M->ZD_SEQUENC+M->ZD_COD+M->ZD_ARMAZ
			cWhile := "SZE->ZE_FILIAL+SZE->ZE_SEQUENC+SZE->ZE_COD+SZE->ZE_ARMAZ"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FillGetDados(nOpc,"SZE",1,cSeek,{|| &cWhile },,,,,,,,aHeader,aCols,,,,)
		Endif

		If Empty(aCols)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FillGetDados(nOpc,"SZE",1,,,,,,,,,.T.,aHeader,aCols,,,,)
		Endif

		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 100, .t., .t. } )

		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )

	 	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
			EnChoice( "SZD", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.F. )
			oGetD := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIF(!lInclui.And.!lAltera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"TudoOk()","TudoOk()","",/*alteraveis*/,/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,/*delok*/,,aHeader,aCols)
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(nOpc == 4 .or. (lInclui .and. Obrigatorio(aGets,aTela) .And. oGetD:TudoOk()),(nOpca:=1,oDlg:End()) , (nOpca:=2) )},{||oDlg:End()},,aButtons)

		If nOpca == 1
			Begin Transaction
				PadGrava(nOpc-2,aCols,aHeader)
				If __lSX8
					ConfirmSX8()
				Endif
			End Transaction
			MsUnlockAll()
		ElseIf __lSX8
			RollBackSX8()
		Endif
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F4 para comunicacao com Saldos em estoque     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET KEY VK_F4 TO

RestInter()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EncheaCols  ºAutor  ³ Marcos Candido  º Data ³  05/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ExecBlock executado por gatilho no campo ZD_MESES.         º±±
±±º          ³ Faz o preenchimento do aCols conforme a quantidade de      º±±
±±º          ³ meses para o diferimento.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EncheAcols

Local nM := 0
Local nH := 0
Local nQtd := NoRound(M->ZD_QTDORI / M->ZD_MESES,6)
Local nAux := 0
Local aAreaAtual := GetArea()
Local nQtdMeses := M->ZD_MESES
Local cCampo    := ""
Local nPosSeq   := 0
Local nPosProd  := 0
Local nPosArm   := 0
Local nPosDt    := 0
Local nPosQtd   := 0
Local nPosSld   := 0

nAux := nQtd * nQtdMeses
nAux := M->ZD_QTDORI - nAux

// Reinicializo as variaveis para evitar duplicar os registros
aCols   := {}
aHeader := {}
FillGetDados(3,"SZE",1,,,,,,,,,.T.,aHeader,aCols,,,,)

nPosSeq   := GdFieldPos("ZE_SEQUENC")
nPosProd  := GdFieldPos("ZE_COD")
nPosArm   := GdFieldPos("ZE_ARMAZ")
nPosDt    := GdFieldPos("ZE_DATA")
nPosQtd   := GdFieldPos("ZE_QUANT")
nPosSld   := GdFieldPos("ZE_SALDO")

For nM:=1 to nQtdMeses

	If nM > 1
		AADD(aCols,Array(Len(aHeader)+1))
		For nI:=1 to Len(aHeader)
			If !(Alltrim(aHeader[nI][2]) $ "ZE_REC_WT|ZE_ALI_WT" )
				cCampo:=Alltrim(aHeader[nI,2])
				If aHeader[nI,10] # "V"
					aCols[Len(aCols)][nI] := SZE->(FieldGet(FieldPos(cCampo)))
				Else
					aCols[Len(aCols)][nI] := SZE->(CriaVar(cCampo,.T.))
				Endif
			Else
				If Alltrim(aHeader[nI][2]) == "ZE_REC_WT"
					aCols[Len(aCols)][nI] := 0
				ElseIf Alltrim(aHeader[nI][2]) == "ZE_ALI_WT"
					aCols[Len(aCols)][nI] := "SZE"
				EndIf
			Endif
		Next i
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Endif

	aCols[nM][nPosSeq]  := M->ZD_SEQUENC
	aCols[nM][nPosProd] := M->ZD_COD
	aCols[nM][nPosArm]  := M->ZD_ARMAZ
	aCols[nM][nPosDt]   := CtoD(Space(8))
	aCols[nM][nPosQtd]  := NoRound((nQtd+iif(nM==nQtdMeses,nAux,0)),4)//nQtd+iif(nM==nQtdMeses,nAux,0)
	aCols[nM][nPosSld]  := NoRound(M->ZD_QTDORI-((nQtd*nM)+iif(nM==nQtdMeses,nAux,0)),4)

Next

oGetD:aCols:=aCols
oGetD:ForceRefresh()

RestArea(aAreaAtual)

Return(nQtdMeses)


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PadGrava ³ Autor ³ Marcos Candido        ³ Data ³ 18/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Gravacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³  PadGrava()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PadGrava(nOpcao,aCols,aHeader)

Local aArea     := GetArea()
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local lGravou   := .F.
Local nX        := 0
Local nY        := 0
Local nPosRecNo := Len(aHeader)

Do Case
Case nOpcao == 1 // Inclusao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava o Cabecalho                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZD")
	dbSetOrder(1)
	If MsSeek(xFilial("SZD")+M->ZD_SEQUENC+M->ZD_COD+M->ZD_ARMAZ)
		RecLock("SZD",.F.)
	Else
		RecLock("SZD",.T.)
	EndIf
	For nX := 1 TO FCount()
		FieldPut(nX,M->&(EVAL(bCampo,nX)))
	Next nX
	SZD->ZD_FILIAL := xFilial("SZD")
	SZD->ZD_STATUS := '1'

	SZD->(FkCommit())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os itens                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZE")

	For nX := 1 To Len(aCols)

		If !aCols[nX,Len(aCols[nX])]

			If aCols[nX][nPosRecno] > 0
				dbGoto(aCols[nX][nPosRecno])
				RecLock("SZE",.F.)
			Else
				RecLock("SZE",.T.)
				  SZE->ZE_FILIAL  := xFilial("SZE")
				  SZE->ZE_SEQUENC := M->ZD_SEQUENC
				  SZE->ZE_COD     := M->ZD_COD
				  SZE->ZE_ARMAZ   := M->ZD_ARMAZ
			Endif

			For nY := 1 To Len(aHeader)
				If ( aHeader[nY][10] != "V" )
					SZE->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
				EndIf
			Next nY

			MsUnLock()

		Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ caso o aCols esteja marcado como deletado, apago o registro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SZE")
			If aCols[nX][nPosRecno] > 0
				dbGoto(aCols[nX][nPosRecno])
				RecLock("SZE")
					dbDelete()
				MsUnlock()
			Endif

		Endif

		SZE->(FkCommit())

	Next nX

	lGravou := .T.

Case nOpcao == 2 // Exclusao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³De acordo com a normalizacao, exclui os itens e depois o cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZE")
	For nX := 1 To Len(aCols)
		If aCols[nX][nPosRecno] > 0
			dbGoto(aCols[nX][nPosRecno])
			RecLock("SZE")
				dbDelete()
			MsUnlock()
		Endif
	Next nX

	RecLock("SZD",.F.)
		dbDelete()
	MsUnlock()

	lGravou := .T.

//OtherWise

EndCase

RestArea(aArea)

Return(lGravou)


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  PadLeg  ³ Autor ³ Marcos Candido        ³ Data ³ 18/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra Legenda das cores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MntPadr                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PadLeg

Local aCores2 := {}

aCores2 := {{"BR_VERDE"		,"Produto ainda não Diferido"},;
			{"BR_AZUL"		,"Produto em Diferimento"},;
			{"BR_VERMELHO"	,"Produto já Diferido"}}

BrwLegenda(cCadastro,OemtoAnsi("Situação dos registros"),aCores2)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ShowF4   ³ Autor ³ Fernando Joly Siquini ³ Data ³ 13/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da funcao F4                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MntPadr                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MostraEst(a,b,c)

Local cCampo := AllTrim(Upper(ReadVar()))

If cCampo == "M->ZD_COD" .Or. cCampo == "M->ZD_QTDORI"
	MaViewSB2(M->ZD_COD)
Endif

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNTPADR   ºAutor  ³Microsiga           º Data ³  11/20/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VeArmaz

Local aAreaAtual := GetArea()
Local lRet := .T.

If !(SB2->(dbSeek(xFilial("SB2")+M->ZD_COD+M->ZD_ARMAZ)))
	Help(" ",1,"A260LOCAL")
	lRet := .F.
Endif

RestArea(aAreaAtual)

Return lRet



User Function PadBxT

If Day(dDataBase) == Day(LastDay(dDataBase))
	Alert("Não pode ser realizado baixa Total de Padrões no último dia do mês")
	Return
endif

If !IW_MsgBox(OemToAnsi("Todos os registros pendentes serão baixados. Confirma ?"), OemToAnsi("Informação") , "YESNO")
	Return
endif

Processa({|| RunOk() },OemToAnsi("Diferimento de Padrões"))

Return


Static Function RunOk

Local cQuery  := ""
Local cStatus := ""
Local nM      := 0
Local aCab 		:= {} , aItem := {} , aTotItem := {}
Local nOpc
Local cTM  		:= SuperGetMv("MV_ZZTM",.f.)
Local cNumOP    := ""
Local aDados    := {}
Local cNumDoc   := ""
Local lCont     := .T.

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

if Empty(cTM)
	IW_MsgBox(OemToAnsi("Por favor cadastre o tipo de movimentação, parametro MV_ZZTM"), OemToAnsi("Atenção") , "ALERT")
	Return
endif


If Select("WRK1") > 0
	WRK1->(dbCloseArea())
Endif



cQuery := "SELECT COUNT(*) AS nRegistros FROM "+RetSQLName("SZD")+" SZD ,"+RetSQLName("SZE")+" SZE "
cQuery += "WHERE SZD.ZD_STATUS <> '3' AND "
cQuery += "SZD.ZD_FILIAL = '"+xFilial("SZD")+"' AND "
cQuery += "SZE.ZE_FILIAL = '"+xFilial("SZE")+"' AND "
cQuery += "SZD.ZD_COD = '" + SZD->ZD_COD + "' AND "
cQuery += "SZD.ZD_SEQUENC = '" + SZD->ZD_SEQUENC + "' AND "
cQuery += "SZD.ZD_SEQUENC = SZE.ZE_SEQUENC AND "
cQuery += "SZD.ZD_COD = SZE.ZE_COD AND "
cQuery += "SZD.ZD_ARMAZ = SZE.ZE_ARMAZ AND "
cQuery += "SZE.ZE_DATA = ' ' AND "
cQuery += "SZD.D_E_L_E_T_ <> '*' AND "
cQuery += "SZE.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
TcQuery cQuery New Alias "WRK1"

nTotRegs := WRK1->nRegistros

WRK1->(dbCloseArea())

cQuery := "SELECT * , SZD.R_E_C_N_O_ AS SZDREC, SZE.R_E_C_N_O_ AS SZEREC FROM "+RetSQLName("SZD")+" SZD ,"+RetSQLName("SZE")+" SZE "
cQuery += "WHERE SZD.ZD_STATUS <> '3' AND "
cQuery += "SZD.ZD_FILIAL = '"+xFilial("SZD")+"' AND "
cQuery += "SZE.ZE_FILIAL = '"+xFilial("SZE")+"' AND "
cQuery += "SZD.ZD_COD = '" + SZD->ZD_COD + "' AND "
cQuery += "SZD.ZD_SEQUENC = '" + SZD->ZD_SEQUENC + "' AND "
cQuery += "SZD.ZD_SEQUENC = SZE.ZE_SEQUENC AND "
cQuery += "SZD.ZD_COD = SZE.ZE_COD AND "
cQuery += "SZD.ZD_ARMAZ = SZE.ZE_ARMAZ AND "
cQuery += "SZE.ZE_DATA = ' ' AND "
cQuery += "SZD.D_E_L_E_T_ <> '*' AND "
cQuery += "SZE.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
TcQuery cQuery New Alias "WRK1"

WRK1->(dbGoTop())

//Acrescentado o if, pois dava erro ao baixar uma sequência de padrão que não tinha saldo.
if nTotRegs <= 0
	Alert("Não há saldo para baixa total da sequência "+SZD->ZD_SEQUENC+" do produto "+SZD->ZD_COD)
	return .F.
else
	ProcRegua(nTotRegs)
endif

/*
While !Eof()
    IncProc(OemToAnsi("Organizando dados..."))
	aadd(aDados , { cTM , cNumOP , WRK1->ZE_COD, WRK1->ZE_ARMAZ , WRK1->ZE_QUANT , WRK1->SZDREC , WRK1->SZEREC , WRK1->ZE_SEQUENC , WRK1->ZD_CCUSTO})
	WRK1->(dbSkip())
Enddo
*/

SF5->(dbSetOrder(1))
SB1->(dbSetOrder(1))

SF5->(dbSeek(xFilial("SF5")+cTM))

SB1->(dbSeek(xFilial("SB1")+WRK1->ZE_COD))

cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
cNumDoc := A261RetINV(cNumDoc)
aCab :={{"D3_DOC"		,	cNumDoc			,	NIL},;
		{"D3_TM"		,	cTM	,	Nil},;
		{"D3_EMISSAO"   ,	dDataBase 		,	NIL},;
		{"D3_CC"		,	WRK1->ZD_CCUSTO  ,	Nil}}

While WRK1->(!Eof())

	IncProc(OemToAnsi("Aplicando Diferimento..."))

	aItem:={{"D3_COD"		,	WRK1->ZE_COD	 ,	Nil},;
			{"D3_LOCAL"		,	WRK1->ZE_ARMAZ	 ,	Nil},;
			{"D3_QUANT"		,	WRK1->ZE_QUANT	 ,	Nil},;
			{"D3_GRUPO"		,	SB1->B1_GRUPO	 ,	Nil},;
			{"D3_TIPO"		,	SB1->B1_TIPO	 ,	Nil},;
			{"D3_CONTA"		,	SB1->B1_CONTA	 ,	Nil},;
			{"D3_UM"	    ,	SB1->B1_UM	     ,	Nil}}

	aadd(aTotItem,aItem)

	WRK1->(dbSkip())

Enddo

Begin Transaction
MsExecAuto({|x,y,z|Mata241(x,y,z)},aCab,aTotItem,nOpc)
If lMsErroAuto
	MostraErro()
	DisarmTransaction()
	Break
Endif
End Transaction

If lMsErroAuto
	Return(.F.)
Endif

ProcRegua(nTotRegs)
WRK1->(dbGoTop())

while WRk1->(!Eof())
	IncProc(OemToAnsi("Atualizando Diferimentos..."))

	SZE->(dbGoTo(WRK1->SZEREC))
	If SZE->ZE_SALDO == 0
		cStatus := '3'
	Else
		cStatus := '2'
	Endif
	RecLock("SZE",.F.)
	SZE->ZE_DATA := dDataBase
	MsUnlock()

	dbGoTo(WRK1->SZDREC)
	RecLock("SZD",.F.)
	SZD->ZD_STATUS := cStatus
	MsUnlock()

	WRK1->(dbSkip())
enddo

WRK1->(dbCloseArea())

IW_MsgBox(OemToAnsi("Processamento Concluído."), OemToAnsi("Informação") , "INFO")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNTPADR   ºAutor  ³Microsiga           º Data ³  11/20/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho ao colocar a quantidade a diferir para consultar   º±±
±±º          ³ Se há saldo para criar esse diferimento                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Régis Ferreira                                             º±±
±±º          ³ Gatilhar a função ZZANASAL no campo ZD_QTDORI              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
User Function ZZANASAL

	Local nQatu	:= Posicione("SB2",1,xFilial("SB2")+M->ZD_COD+M->ZD_ARMAZ,"B2_QATU")
	Local nSze	:= 0
	local lRet	:= .T.
	Local aArea := GetArea()
	Local cMens1:= ""
	Local cMens2:= ""
	Local cMens3:= ""
	Local cMens4:= ""
	Local cMens5:= ""
	
	BeginSQL alias "ZZ"
		
		Select Sum(ZE_QUANT) ZE_QUANT
		From %Table:SZE%
		Where %NotDel% and ZE_FILIAL=%xFilial:SZE% and ZE_COD=%Exp:ZD_COD% and ZE_DATA='        '

	EndSql

	nSze := ZZ->ZE_QUANT
	ZZ->(DbCloseArea())
	RestArea(aArea)

	//Verifica se pode abrir ou não o diferimento
	if Round(M->ZD_QTDORI,6) > ( Round(nQatu,6)- Round(nSze,6))
		cMens1	:= "Não há saldo suficiente para abrir esse diferimento!"
		cMens2	:= "Produto Padrão: "+AllTrim(M->ZD_COD)
		cMens3	:= "Saldo em Estoque: "+Alltrim(Str(Round(nQatu,6)))
		cMens4	:= "Saldo de Diferimento em Aberto: "+AllTrim(Str(Round(nSze,6)))
		cMens5	:= "Saldo disponível para abrir Diferimento: "+Alltrim(Str(Round(Round(nQatu,6)-Round(nSze,6),6)))
		Aviso("Informação",cMens1+ENTER+cMens2+ENTER+cMens3+ENTER+cMens4+ENTER+cMens5,{"Ok"}, 3)
		lRet := .F.	
	endif
	
	if lRet
		nQatu := M->ZD_QTDORI
	else
		nQatu := 0
	endif
	
return nQatu
