#include "protheus.ch"
#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY


/*/{Protheus.doc} IMPCSV10
Leitura de arquivo CSV contendo informacoes que atualizarao o cadastro de clientes
@author Marcos Candido
@since 02/01/2018
/*/
User Function IMPCSV10

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Declaracao de Variaveis      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local nOpt   := 0
Local cDiret := Space(40)
Local oDlg, oImport, oPath, oBtBrw, oBtOk, oBtCan
Local cPath := '*.CSV | *.CSV | , OemtoAnsi("Selecione o diret�rio p/ buscar o arquivo. "),,"",.F.,GETF_RETDIRECTORY'


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Montagem da tela de interface com o usuario                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Define MsDialog oDlg Title OemToAnsi("Leitura de Arquivo CSV") From 00,00 to 175,480 Pixel

@ 00.4,01 To 04.55,25
@ 01,03 Say OemToansi("Este programa ir� ler o conte�do do arquivo texto com a extens�o ")
@ 02,03 Say OemToansi("CSV e possibilitar a atualiza豫o dos campos Segmento de Mercado, ")
@ 03,03 Say OemToansi("Vendedor, Codigo do Cliente no ELims e C�digo do Cliente no CRM.")
@ 05.75,06 Say OemToansi("Diret�rio:")
@ 70,047 MsGet oPath Var cDiret Size 150,08 of oDlg Pixel

Define sButton oBtOk  From 005,208 Type 1  Action (nOpt := 1, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtCan From 020,208 Type 2  Action (nOpt := 0, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtBrw From 068,010 Type 14 Action (cDiret := PegaDirArq(cPath), oPath:Refresh()) Enable of oDlg Pixel

Activate MsDialog oDlg Center

If nOpt == 1
	If Empty(cDiret)
		IW_MsgBox(OemToAnsi("Nenhum arquivo foi selecionado. Opera豫o cancelada.") , OemToAnsi("Aten豫o") , "STOP")
	Else
		Processa({|| OkLeCSV(cDiret) },OemToAnsi("Processando Arquivo..."))
	Endif
Endif

Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  �          튍utor  �                    � Data �             볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �                                                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       �                                                            볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function PegaDirArq(cPath)

Local cDir := Space(40)

cDir := cGetFile(cPath)

Return(cDir)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔MPCSV    튍utor  쿘icrosiga           � Data �             볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �                                                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       �                                                            볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function OkLeCSV(cRetArq)

Local aReadCSV  := {} , aDados := {}
Local cLineRead := ""

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Abre arquivo e o le por completo          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Separa os dados                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
For a:=1 to Len(aReadCSV)

	IncProc(OemToAnsi("Lendo arquivo CSV..."))

	aPos := {}
	cLin := aReadCSV[a]

	For nLts:=1 to Len(cLin)
		If SubStr(cLin,nLts,1) == ';'
			Aadd(aPos,nLts)
		EndIf
	Next

	/*
	cCodElims := SubStr(Alltrim(cLin),1,(aPos[1]-1))
	cCodProth := SubStr(Alltrim(cLin),(aPos[1]+1),(aPos[2]-1)-aPos[1])
	cCodCRM   := SubStr(Alltrim(cLin),(aPos[2]+1),(aPos[3]-1)-aPos[2])
	cVendedor := SubStr(Alltrim(cLin),(aPos[3]+1),(aPos[4]-1)-aPos[3])
	cCodSegm  := SubStr(Alltrim(cLin),(aPos[4]+1),Len(cLin)-aPos[4])

	aadd(aDados , { cCodElims , StrTran(cCodProth,"-","") , cCodCRM , cVendedor , cCodSegm })
	*/

	cCNPJCPF  := SubStr(Alltrim(cLin),1,(aPos[1]-1))
	cVendedor := SubStr(Alltrim(cLin),(aPos[1]+1),Len(cLin)-aPos[1])

	aadd(aDados , { cCNPJCPF , cVendedor })

Next

dbSelectArea("SA1")
dbSetOrder(3)

ProcRegua(Len(aDados))

For t:=1 to Len(aDados)

	IncProc("Atualizando campos em CLIENTES...")

	dbSelectArea("SA1")
	If dbSeek(xFilial("SA1")+aDados[t][1])

		RecLock("SA1",.F.)
		  /*
		  A1_X_ELIMS := aDados[t][1]
  		  A1_X_CRM   := aDados[t][3]
		  A1_VEND    := aDados[t][4]
		  A1_SATIV1  := aDados[t][5]
		  */
		  A1_VEND    := aDados[t][2]
		MsUnlock()

    Endif

Next

dbSelectArea("SA3")
dbSetOrder(1)

ProcRegua(Len(aDados))

For t:=1 to Len(aDados)

	IncProc("Atualizando campos em VENDEDORES...")

	If !Empty(aDados[t][2])
		If Alltrim(aDados[t][2]) == '000000'
			cUserId    := " "
			cUserEmail := " "
			cUsrNom    := "VENDEDOR PADRAO"
			cUsrNRed   := "VENDEDOR PADRAO"
		ElseIf Alltrim(aDados[t][2]) == 'EDBR'
			cUserId    := " "
			cUserEmail := " "
			cUsrNom    := "VENDEDOR BACK-OFFICE"
			cUsrNRed   := "VENDEDOR BACK-OFFICE"
		Else
			PswOrder(2)
			If PswSeek(aDados[t][2],.T.)
				cUserId    := PswID()
				cUserEmail := UsrRetMail(cUserId)
				cUsrNom    := UsrFullName(cUserId)
				cUsrNRed   := aDados[t][2]
			Else
				cUserId    := " "
				cUserEmail := " "
				cUsrNom    := "VENDEDOR PADRAO"
				cUsrNRed   := "VENDEDOR PADRAO"
			Endif
	 	Endif

		dbSelectArea("SA3")
		If !dbSeek(xFilial("SA3")+aDados[t][2])
			RecLock("SA3",.T.)
			  A3_FILIAL  := xFilial("SA3")
			  A3_COD     := aDados[t][2]
			  A3_NOME    := cUsrNom
			  A3_NREDUZ  := cUsrNRed
			  A3_EMAIL   := cUserEmail
			  A3_CODUSR  := cUserId
			MsUnlock()
		Endif
	Endif

Next

Return