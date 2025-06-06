#include "protheus.ch"
#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � IMPCSV04 �Autor  � Marcos Candido     � Data � 06/09/13    ���
�������������������������������������������������������������������������͹��
���Desc.     � Leitura de arquivo CSV contendo os codigos dos produtos    ���
���          � e respectivas quantidades que serao inventariadas na data  ���
���          � indicada.                                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Eurofins                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} IMPCSV04
Leitura de arquivo CSV contendo os codigos dos produtos e respectivas quantidades que serao inventariadas na data indicada.
@author Marcos Candido
@since 02/01/2018

/*/
User Function IMPCSV04

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
@ 02,03 Say OemToansi("CSV e possibilitar a atualiza��o da tabela de Baixa de Padr�es.")
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
Local aQtd      := TamSx3("D3_QUANT")
Local aItem     := {}

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