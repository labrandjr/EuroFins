#include "protheus.ch"
#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � IMPCSV11 �Autor  � Marcos Candido     � Data � 27/03/15    ���
�������������������������������������������������������������������������͹��
���Desc.     � Leitura de arquivo CSV contendo informacoes do estoque     ���
���          � minimo dos produtos .                                      ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Eurofins                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} IMPCSV14
Leitura de arquivo CSV contendo informacoes do estoque minimo dos produtos .
@author Marcos Candido
@since 02/01/2018
/*/
User Function IMPCSV14

//������������������������������Ŀ
//� Declaracao de Variaveis      �
//��������������������������������
Local nOpt   := 0
Local cDiret := Space(40)
Local oDlg, oImport, oPath, oBtBrw, oBtOk, oBtCan
Local cPath := '*.CSV | *.CSV | , OemtoAnsi("Selecione o diret�rio p/ buscar o arquivo. "),,"",.F.,GETF_RETDIRECTORY'


//���������������������������������������������������������������������Ŀ
//� Montagem da tela de interface com o usuario                         �
//�����������������������������������������������������������������������
Define MsDialog oDlg Title OemToAnsi("Leitura de Arquivo CSV") From 00,00 to 175,480 Pixel

@ 00.4,01 To 04.55,25
@ 01,03 Say OemToansi("Este programa ir� ler o conte�do do arquivo texto com a extens�o ")
@ 02,03 Say OemToansi("CSV e possibilitar a atualiza��o da tabela de cadastro de produtos. ")
@ 03,03 Say OemToansi("*** campo Estoque M�nimo *** ")
@ 05.75,06 Say OemToansi("Diret�rio:")
@ 70,047 MsGet oPath Var cDiret Size 150,08 of oDlg Pixel

Define sButton oBtOk  From 005,208 Type 1  Action (nOpt := 1, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtCan From 020,208 Type 2  Action (nOpt := 0, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtBrw From 068,010 Type 14 Action (cDiret := PegaDirArq(cPath), oPath:Refresh()) Enable of oDlg Pixel

Activate MsDialog oDlg Center

If nOpt == 1
	If Empty(cDiret)
		IW_MsgBox(OemToAnsi("Nenhum arquivo foi selecionado. Opera��o cancelada.") , OemToAnsi("Aten��o") , "STOP")
	Else
		Processa({|| OkLeCSV(cDiret) },OemToAnsi("Processando Arquivo..."))
	Endif
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �          �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PegaDirArq(cPath)

Local cDir := Space(40)

cDir := cGetFile(cPath)

Return(cDir)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMPCSV    �Autor  �Microsiga           � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function OkLeCSV(cRetArq)

Local aReadCSV  := {} , aDados := {}
Local cLineRead := ""

//���������������������������������������������
//� Abre arquivo e o le por completo          �
//���������������������������������������������
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

//���������������������������������������������
//� Separa os dados                           �
//���������������������������������������������
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
	cArmaz   := SubStr(Alltrim(cLin),(aPos[1]+1),(aPos[2]-1)-aPos[1])
	cEstqMin := SubStr(Alltrim(cLin),(aPos[2]+1),Len(cLin)-aPos[2])

	aadd(aDados , { cProduto , cArmaz , cEstqMin })

Next

dbSelectArea("SB1")
dbSetOrder(1)

ProcRegua(Len(aDados))

For t:=1 to Len(aDados)

	IncProc("Atualizando Tabela SB1...")

	If dbSeek(xFilial("SB1")+aDados[t][1])
		RecLock("SB1",.F.)
		  B1_ESTSEG		:= Val(aDados[t][3])
		MsUnlock()
	Endif

Next

Return