#include "protheus.ch"
#include "rwmake.ch"

#DEFINE ENTER CHR(13)+CHR(10)


/*/{Protheus.doc} ExpCSV03
Gera arquivo CSV que sera importado automaticamente pelo MS-Excel com informacoes relativas aos pedidos que foram gerados pela aplicacao que le o arquivo texto que o sistema ELIMS disponibiliza.
@author Marcos Candido
@since 02/01/2018
/*/

User Function ExpCSV03

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local aSays      := {}
Local aButtons   := {}
Local cCadastro  := OemToansi('Gera��o de arquivo texto para Planilha no MS-Excel')
Local lOkParam   := .F.
Local cPerg      := PADR("EXPCSV03",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
Local cMens      := OemToAnsi('A op��o de Par�metros desta rotina deve ser acessada antes de sua execu��o!')

//����������������������������������������
//� Organiza o Grupo de Perguntas e Help �
//����������������������������������������
aHelpPor := {}
aAdd(aHelpPor,"Informe a data inicial a ser considerada")
aAdd(aHelpPor,"na filtragem das informa��es.")
Aadd(aPergs,{"Da Data","","","mv_ch1","D",8,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data final a ser considerada")
aAdd(aHelpPor,"na filtragem das informa��es.")
Aadd(aPergs,{"Ate a Data","","","mv_ch2","D",8,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe o diret�rio em que ser� gerado")
aAdd(aHelpPor,"o arquivo.")
aAdd(aHelpPor,"Por exemplo: C:\TEMP\")
Aadd(aPergs,{"Diretorio","","","mv_ch3","C",30,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"D� um nome para o arquivo.")
aAdd(aHelpPor,"SEMPRE INDIQUE A EXTENS�O CSV.")
aAdd(aHelpPor,"Por exemplo: EUROFINS.CSV")
Aadd(aPergs,{"Arquivo","","","mv_ch4","C",20,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe qual � o status que o pedido")
aAdd(aHelpPor,"deve estar para ser considerado ")
aAdd(aHelpPor,"no processamento.")
Aadd(aPergs,{"Condicao dos Pedidos","","","mv_ch5","N",1,0,1,"C","","MV_PAR05","Em Aberto","","","","","Ja Faturado","","","","","Ambos","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

//���������������������������������������������
//� Cria, se necessario, o grupo de Perguntas �
//���������������������������������������������
//AjustaSx1(cPerg,aPergs)

//���������������������������������������������
//� Monta Interface com o usuario             �
//���������������������������������������������
aAdd(aSays,OemToAnsi('Este programa visa gerar um arquivo texto com informa��es dos pedidos'))
aAdd(aSays,OemToAnsi('de venda gerados a partir do arquivo texto que foi disponibilizado '))
aAdd(aSays,OemToAnsi('pelo eLIMS. O arquivo ser� aberto em uma Planilha do MS-Excel.'))
aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| GeraArq()}),o:oWnd:End()),Aviso(OemToAnsi('Aten��o!!!'), cMens , {'Ok'})) } } )
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons,,230,470 ) // altura x largura

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �          � Autor �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo botao OK na tela inicial de processamen���
���          � to. Executa a geracao do arquivo texto.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function GeraArq

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis                                             �
//�����������������������������������������������������������������������
Local cDir := ""
Local cNomArq := Alltrim(mv_par04)

nPos := Rat(".",cNomArq)

If nPos > 0
	If Substr(cNomArq,nPos) # "CSV"
		cNomArq := Substr(cNomArq,1,nPos) + "CSV"
	Endif
Else
	cNomArq := cNomArq+".CSV"
Endif

cBarra := Right(Alltrim(mv_par03),1)
If cBarra # "\"
	cDir := Alltrim(mv_par03)+"\"
Else
	cDir := Alltrim(mv_par03)
Endif
//�������������������������������������������������������������������������Ŀ
//� Se nao existir, cria o diretorio, e em seguida, cria o arquivo texto.   �
//���������������������������������������������������������������������������
MontaDir(cDir)
nHdl := fCreate(cDir+cNomArq)

If nHdl == -1
	MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq+" n�o pode ser executado! Verifique os par�metros."),OemToAnsi("Aten��o!"))
	Return
Endif

//���������������������������������������������������������������������Ŀ
//� Inicializa a regua de processamento                                 �
//�����������������������������������������������������������������������
Processa({|| RunCont() },"Processando...")

If !ApOleClient("MsExcel")
	MsgBox("Microsoft Excel N�o Instalado !", "Aten��o", "INFO")
Else
	oExcelApp := MsExcel():New()
   	oExcelApp:WorkBooks:Open(cDir+cNomArq)
   	oExcelApp:SetVisible(.T.)
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RUNCONT  � Autor �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunCont

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cFiltro := ""
Local cLin    := ""				//	Variavel para criacao da linha do registros para gravacao
Local lFirst  := .T.
Local cChaveSC5  := ""
Local cNomArqSC5 := ""
Local nTot := 0

dbSelectArea("SC5")
cFiltro := 'C5_FILIAL=="'+xFilial("SC5")+'" .and. '
cFiltro += 'DTOS(C5_EMISSAO)>="'+dtos(mv_par01)+'" .and. DTOS(C5_EMISSAO)<="'+dtos(mv_par02)+'" .and. '
cFiltro += 'C5_TIPO == "N" '
If mv_par05 == 1	// pedidos em aberto
	cFiltro += '.and. '
	cFiltro += 'Empty(C5_NOTA)'
ElseIf mv_par05 == 2	// pedidos faturados
	cFiltro += '.and. '
	cFiltro += '!Empty(C5_NOTA)'
Endif
cChaveSC5  := 'C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM'
cNomArqSC5 := CriaTrab(Nil,.F.)
IndRegua("SC5",cNomArqSC5,cChaveSC5,,cFiltro,OemToAnsi("Selecionando Registros..."))

dbSelectArea("SC5")
#IfNDEF TOP
	dbSetIndex(cNomArqSC5+OrdBagExt())
#endif

dbGoTop()

ProcRegua(RecCount()) // Numero de registros a processar

While !Eof()

	If lFirst
		cLin += "Nome Arquivo;Num. Certificado;Num. Pedido;Dt Emissao;Cod. Cliente;Loja Cliente;Nome Cliente;Produto;Qtde;Vlr Unitario;Vlr Total"
		cLin += ENTER
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert(OemToansi("Ocorreu um erro na grava��o do arquivo."),OemToAnsi("Aten��o!"))
			Exit
		Endif
		lFirst := .F.
	Endif

	//���������������������������������������������������������������������Ŀ
	//� Incrementa a regua                                                  �
	//�����������������������������������������������������������������������
	IncProc(OemToAnsi("Processando informa��es..."))

	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6")+SC5->C5_NUM)

	While !Eof() .and. C6_FILIAL==xFilial("SC6") .and. C6_NUM==SC5->C5_NUM

		cLin := ""
		cLin += SC5->C5_ZZARQ+";" 			//cLin += SC5->C5_X_ARQ+";"
		cLin += SC5->C5_ZZNROCE+";" 		//cLin += SC5->C5_NROCERT+";"
		cLin += SC5->C5_NUM+";"
		cLin += DtoC(SC5->C5_EMISSAO)+";"
		cLin += SC5->C5_CLIENT+";"
		cLin += SC5->C5_LOJACLI+";"
		cLin += SC5->C5_ZZNFANT+";"			// cLin += SC5->C5_NFANT+";"
		cLin += SC6->C6_PRODUTO+";"
		cLin += Transform(SC6->C6_QTDVEN,"@E 99999,999.99999")+";"
		cLin += Transform(SC6->C6_PRCVEN,"@E 99999,999.99999")+";"
		cLin += Transform(SC6->C6_VALOR,"@E 999,999,999.99")
		cLin += ENTER

		nTot += SC6->C6_VALOR

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert(OemToansi("Ocorreu um erro na grava��o do arquivo."),OemToAnsi("Aten��o!"))
			Exit
		Endif

		dbSelectArea("SC6")
		dbSkip()

	Enddo

	dbSelectArea("SC5")
	dbSkip()

Enddo

cLin := ""
cLin += " ; ; ; ; ; ; ; ; ; ; "
cLin += ENTER

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	MsgAlert(OemToansi("Ocorreu um erro na grava��o do arquivo."),OemToAnsi("Aten��o!"))
	Return
Endif

cLin := ""
cLin += " ; ; ; ; ; ; ; ; ;TOTAL;"+Transform(nTot,"@E 999,999,999.99")
cLin += ENTER

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	MsgAlert(OemToansi("Ocorreu um erro na grava��o do arquivo."),OemToAnsi("Aten��o!"))
	Return
Endif

dbSelectArea("SC5")
RetIndex("SC5")
#IfNDEF TOP
	fErase(cNomArqSC5+OrdBagExt())
#endif

//�������������������������������������Ŀ
//� O arquivo texto deve ser fechado.   �
//���������������������������������������
fClose(nHdl)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Funcao   � AcessaPar   � Autor � Marcos Candido     � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para acessar o grupo de perguntas                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AcessaPar(cPerg,lOk)

If Pergunte(cPerg)
	lOk := .T.
Endif

Return(lOk)
