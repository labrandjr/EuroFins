#include "protheus.ch"
#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ IMPCSV04 ºAutor  ³ Marcos Candido     º Data ³ 06/09/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Leitura de arquivo CSV contendo os codigos dos produtos    º±±
±±º          ³ e respectivas quantidades que serao inventariadas na data  º±±
±±º          ³ indicada.                                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Eurofins                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} IMPCSV04
Leitura de arquivo CSV contendo os codigos dos produtos e respectivas quantidades que serao inventariadas na data indicada.
@author Marcos Candido
@since 02/01/2018

/*/
User Function IMPCSV04

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpt   := 0
Local cDiret := Space(40)
Local oDlg, oImport, oPath, oBtBrw, oBtOk, oBtCan
Local cPath := '*.CSV | *.CSV | , OemtoAnsi("Selecione o diretório p/ buscar o arquivo. "),,"",.F.,GETF_RETDIRECTORY'


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de interface com o usuario                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Define MsDialog oDlg Title OemToAnsi("Leitura de Arquivo CSV") From 00,00 to 175,480 Pixel

@ 00.4,01 To 04.55,25
@ 01,03 Say OemToansi("Este programa irá ler o conteúdo do arquivo texto com a extensão ")
@ 02,03 Say OemToansi("CSV e possibilitar a atualização da tabela de Baixa de Padrões.")
@ 05.75,06 Say OemToansi("Diretório:")
@ 70,047 MsGet oPath Var cDiret Size 150,08 of oDlg Pixel

Define sButton oBtOk  From 005,208 Type 1  Action (nOpt := 1, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtCan From 020,208 Type 2  Action (nOpt := 0, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtBrw From 068,010 Type 14 Action (cDiret := PegaDirArq(cPath), oPath:Refresh()) Enable of oDlg Pixel

Activate MsDialog oDlg Center

If nOpt == 1
	If Empty(cDiret)
		IW_MsgBox(OemToAnsi("Nenhum arquivo foi selecionado. Operação cancelada.") , OemToAnsi("Atenção") , "STOP")
	Else
		Processa({|| OkLeCSV(cDiret) },OemToAnsi("Processando Arquivo..."))
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PegaDirArq(cPath)

Local cDir := Space(40)

cDir := cGetFile(cPath)

Return(cDir)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPCSV    ºAutor  ³Microsiga           º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OkLeCSV(cRetArq)

Local aReadCSV  := {} , aDados := {}
Local cLineRead := ""
Local aQtd      := TamSx3("D3_QUANT")
Local aItem     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo e o le por completo          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fT_fUse(cRetArq)
fT_fGotop()

While !fT_fEof()

	cLineRead := fT_fReadLn()
	If !Empty(cLineRead)
		aAdd( aReadCSV , cLineRead )
	Endif
	fT_fSkip()

Enddo

fT_fUse()

ProcRegua(Len(aReadCSV))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Separa os dados                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For a:=1 to Len(aReadCSV)

	IncProc(OemToAnsi("Lendo arquivo CSV..."))

	aPos := {}
	cLin := aReadCSV[a]

	For nLts:=1 to Len(cLin)
		If SubStr(cLin,nLts,1) == ';'
			Aadd(aPos,nLts)
		EndIf
	Next

	cProduto := SubStr(Alltrim(cLin),1,(aPos[1]-1))
	cArmz	 := SubStr(Alltrim(cLin),(aPos[1]+1),(aPos[2]-1)-aPos[1])
	cQtd	 := SubStr(Alltrim(cLin),(aPos[2]+1),(aPos[3]-1)-aPos[2])
	cQtdDif  := SubStr(Alltrim(cLin),(aPos[3]+1),(aPos[4]-1)-aPos[3])
	cCCusto  := SubStr(Alltrim(cLin),(aPos[4]+1),Len(cLin)-aPos[4])

	cProduto := cProduto+Space(15-Len(cProduto))
	cQtd     := StrTran(cQtd,".","")
	cQtd     := StrTran(cQtd,",",".")
	cQtd     := StrZero(Val(cQtd),aQtd[1],aQtd[2])

	aadd(aDados , { cProduto , cArmz , cQtd , cQtdDif , cCCusto })

Next

dbSelectArea("SB1")
dbSetOrder(1)

ProcRegua(Len(aDados))

For t:=1 to Len(aDados)

	IncProc("Atualizando cadastro de Padroes...")

	aItem := {}

	dbSelectArea("SB1")
	If dbSeek(xFilial("SB1")+aDados[t][1])

		If SB1->B1_MSBLQL == '1' // BLOQUEADO
			RecLock("SB1",.F.)
			  B1_MSBLQL := '2'
			  B1_ESPECIF := 'ESTAVA BLOQUEADO'
			MsUnlock()
		Endif

		cProxNum := GetSXENum("SZD","ZD_SEQUENC")

		If __lSX8
			ConfirmSX8()
		Endif

		dbSelectArea("SZD")
		RecLock("SZD",.T.)
		  ZD_FILIAL := xFilial("SZD")
		  ZD_SEQUENC := cProxNum
		  ZD_COD    := aDados[t][1]
		  ZD_ARMAZ  := aDados[t][2]
		  ZD_QTDORI := Val(aDados[t][3])
		  ZD_MESES  := Val(aDados[t][4])
		  ZD_STATUS := '1'
		  ZD_CCUSTO := aDados[t][5]
		MsUnlock()


		nQtd := NoRound(SZD->ZD_QTDORI / SZD->ZD_MESES,6)
		nAux := 0
		nQtdMeses := SZD->ZD_MESES

		nAux := nQtd * nQtdMeses
		nAux := SZD->ZD_QTDORI - nAux

		dbSelectArea("SZE")
		For nQ:=1 to nQtdMeses
			RecLock("SZE",.T.)
		  	  ZE_FILIAL := xFilial("SZE")
		  	  ZE_SEQUENC := SZD->ZD_SEQUENC
		  	  ZE_COD    := aDados[t][1]
		  	  ZE_ARMAZ  := aDados[t][2]
		  	  ZE_QUANT  := nQtd+iif(nQ==nQtdMeses,nAux,0)
		  	  ZE_SALDO  := SZD->ZD_QTDORI-((nQtd*nQ)+iif(nQ==nQtdMeses,nAux,0))
			MsUnlock()
		Next

	Endif

Next

Return