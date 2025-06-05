#include "protheus.ch"
#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY


/*/{Protheus.doc} IMPCSV15
Leitura de arquivo CSV contendo informacoes que atualizarao o cadastro de clientes
@author Marcos Candido
@since 02/01/2018
/*/
User Function IMPCSV15

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nOpt   := 0
Local cDiret := Space(40)
Local oDlg, oImport, oPath, oBtBrw, oBtOk, oBtCan
Local cPath := '*.CSV | *.CSV | , OemtoAnsi("Selecione o diret๓rio p/ buscar o arquivo. "),,"",.F.,GETF_RETDIRECTORY'


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem da tela de interface com o usuario                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Define MsDialog oDlg Title OemToAnsi("Leitura de Arquivo CSV") From 00,00 to 175,480 Pixel

@ 00.4,01 To 04.55,25
@ 01,03 Say OemToansi("Este programa irแ ler o conte๚do do arquivo texto com a extensใo ")
@ 02,03 Say OemToansi("CSV e possibilitar a atualiza็ใo do campo Data Limite para faturamento, ")
@ 03,03 Say OemToansi("no cadastro do cliente.")
@ 05.75,06 Say OemToansi("Diret๓rio:")
@ 70,047 MsGet oPath Var cDiret Size 150,08 of oDlg Pixel

Define sButton oBtOk  From 005,208 Type 1  Action (nOpt := 1, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtCan From 020,208 Type 2  Action (nOpt := 0, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtBrw From 068,010 Type 14 Action (cDiret := PegaDirArq(cPath), oPath:Refresh()) Enable of oDlg Pixel

Activate MsDialog oDlg Center

If nOpt == 1
	If Empty(cDiret)
		IW_MsgBox(OemToAnsi("Nenhum arquivo foi selecionado. Opera็ใo cancelada.") , OemToAnsi("Aten็ใo") , "STOP")
	Else
		Processa({|| OkLeCSV(cDiret) },OemToAnsi("Processando Arquivo..."))
		IW_MsgBox(OemToAnsi("Processamento concluํdo.") , OemToAnsi("Informa็ใo") , "INFO")
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PegaDirArq(cPath)

Local cDir := Space(40)

cDir := cGetFile(cPath)

Return(cDir)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPCSV    บAutor  ณMicrosiga           บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OkLeCSV(cRetArq)

Local aReadCSV  := {} , aDados := {}
Local cLineRead := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abre arquivo e o le por completo          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Separa os dados                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For a:=1 to Len(aReadCSV)

	IncProc(OemToAnsi("Lendo arquivo CSV..."))

	aPos := {}
	cLin := aReadCSV[a]

	For nLts:=1 to Len(cLin)
		If SubStr(cLin,nLts,1) == ';'
			Aadd(aPos,nLts)
		EndIf
	Next

	cCod   := SubStr(Alltrim(cLin),1,(aPos[1]-1))
	cLoj   := SubStr(Alltrim(cLin),(aPos[1]+1),(aPos[2]-1)-aPos[1])
	cDtLim := SubStr(Alltrim(cLin),(aPos[2]+1),Len(cLin)-aPos[2])

	aadd(aDados , { cCod , cLoj , cDtLim })

Next

dbSelectArea("SA1")
dbSetOrder(1)

ProcRegua(Len(aDados))

For t:=1 to Len(aDados)

	IncProc("Atualizando campos em CLIENTES...")

	dbSelectArea("SA1")
	If dbSeek(xFilial("SA1")+aDados[t][1]+aDados[t][2])

		RecLock("SA1",.F.)
		  A1_XDIAFAT := Val(aDados[t][3])
		MsUnlock()

    Endif

Next

Return