#include "rwmake.ch"
#include "topconn.ch"

#DEFINE ENTER CHR(13)+CHR(10)


/*/{protheus.doc}ExpCSV04 
Gera arquivo CSV das notas fiscais de entrada que tiveram calculo de icms complementar.
@Author  Marcos Candido     
@since  08/02/2016   
/*/
User Function ExpCSV04

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local aSays      := {}
Local aButtons   := {}
Local cCadastro  := OemToansi('Gera豫o de arquivo texto para Planilha no MS-Excel')
Local lOkParam   := .F.
Local cPerg      := PADR("EXPCSV04",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
Local cMens      := OemToAnsi('A op豫o de Par�metros desta rotina deve ser acessada antes de sua execu豫o!')

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//� Organiza o Grupo de Perguntas e Help �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
aHelpPor := {}
aAdd(aHelpPor,"Informe a data inicial a ser considerada")
aAdd(aHelpPor,"na filtragem das informa寤es.")
Aadd(aPergs,{"01","Dt Digitacao Inicial","","","mv_ch1","D",8,0,1,"G","","MV_PAR01"})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data final a ser considerada")
aAdd(aHelpPor,"na filtragem das informa寤es.")
Aadd(aPergs,{"02","Dt Digitacao Final","","","mv_ch2","D",8,0,1,"G","","MV_PAR02"})

aHelpPor := {}
aAdd(aHelpPor,"Informe o diret�rio em que ser� gerado")
aAdd(aHelpPor,"o arquivo.")
aAdd(aHelpPor,"Por exemplo: C:\TEMP\")
Aadd(aPergs,{"03","Diretorio","","","mv_ch3","C",30,0,1,"G","","MV_PAR03"})

aHelpPor := {}
aAdd(aHelpPor,"D� um nome para o arquivo.")
aAdd(aHelpPor,"SEMPRE INDIQUE A EXTENS홒 CSV.")
aAdd(aHelpPor,"Por exemplo: EUROFINS.CSV")
Aadd(aPergs,{"04","Arquivo","","","mv_ch4","C",20,0,1,"G","","MV_PAR04"})

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Cria, se necessario, o grupo de Perguntas �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
AjustaSx1(cPerg,aPergs)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Monta Interface com o usuario             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aAdd(aSays,OemToAnsi('Este programa visa gerar um arquivo texto com informa寤es das notas '))
aAdd(aSays,OemToAnsi('fiscais de entrada que tiveram c�lculo de ICMS Complementar.        '))
aAdd(aSays,OemToAnsi('O arquivo ser� aberto em uma Planilha do MS-Excel.'))
aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| GeraArq()}),o:oWnd:End()),Aviso(OemToAnsi('Aten豫o!!!'), cMens , {'Ok'})) } } )
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons,,230,470 ) // altura x largura

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튔un뇙o    �          � Autor �                    � Data �             볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒escri뇙o � Funcao chamada pelo botao OK na tela inicial de processamen볍�
굇�          � to. Executa a geracao do arquivo texto.                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Programa principal                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

Static Function GeraArq

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se nao existir, cria o diretorio, e em seguida, cria o arquivo texto.   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
MontaDir(cDir)
nHdl := fCreate(cDir+cNomArq)

If nHdl == -1
	MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq+" n�o pode ser executado! Verifique os par�metros."),OemToAnsi("Aten豫o!"))
	Return
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Inicializa a regua de processamento                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Processa({|| RunCont() },"Processando...")

If !ApOleClient("MsExcel")
	MsgBox("Microsoft Excel N�o Instalado !", "Aten豫o", "INFO")
Else
	oExcelApp := MsExcel():New()
   	oExcelApp:WorkBooks:Open(cDir+cNomArq)
   	oExcelApp:SetVisible(.T.)
Endif

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튔un뇙o    � RUNCONT  � Autor �                    � Data �             볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒escri뇙o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  볍�
굇�          � monta a janela com a regua de processamento.               볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Programa principal                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

Static Function RunCont

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local cQ   := ""
Local cLin := ""				//	Variavel para criacao da linha do registros para gravacao
Local lFirst := .T.
Local nTot1  := 0
Local nTot2  := 0
Local nTot3  := 0
Local cNomeFor := ""

cQ += "SELECT FT_NFISCAL, FT_SERIE, FT_EMISSAO, FT_ENTRADA, FT_CLIEFOR, FT_LOJA, FT_CFOP, FT_ALIQICM, FT_VALICM, FT_VALCONT, FT_ICMSCOM "
cQ += "FROM "+RetSQLName("SFT")+" "
cQ += "WHERE FT_FILIAL = '"+xFilial("SFT")+"' AND "
cQ += "FT_TIPOMOV = 'E' AND "
cQ += "FT_ENTRADA >= '"+DtoS(mv_par01)+"' AND FT_ENTRADA <= '"+DtoS(mv_par02)+"' AND "
cQ += "FT_ICMSCOM > 0 AND "
cQ += "D_E_L_E_T_ <> '*' "
cQ += "ORDER BY FT_ENTRADA"

cQ := ChangeQuery(cQ)
TcQuery cQ New Alias "WSFT"

dbSelectArea("WSFT")
dbGoTop()

ProcRegua(RecCount()) // Numero de registros a processar

While !Eof()

	If lFirst
		cLin += "Nota Fiscal;Serie Nota Fiscal;Dt Emissao;Dt Digitacao;Cod. Fornecedor;Loja Fornecedor;Nome Fornecedor;CFOP;Aliq. ICMS;Vlr ICMS;Vlr Contabil;Vlr ICMS Complementar"
		cLin += ENTER
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert(OemToansi("Ocorreu um erro na grava豫o do arquivo."),OemToAnsi("Aten豫o!"))
			Exit
		Endif
		lFirst := .F.
	Endif

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Incrementa a regua                                                  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	IncProc(OemToAnsi("Processando informa寤es..."))

	cNomeFor := Posicione("SA2",1,xFilial("SA2")+WSFT->(FT_CLIEFOR+FT_LOJA),"A2_NOME")

	cLin := ""
	cLin += WSFT->FT_NFISCAL+";"
	cLin += WSFT->FT_SERIE+";"
	cLin += DtoC(StoD(WSFT->FT_EMISSAO))+";"
	cLin += DtoC(StoD(WSFT->FT_ENTRADA))+";"
	cLin += WSFT->FT_CLIEFOR+";"
	cLin += WSFT->FT_LOJA+";"
	cLin += cNomeFor+";"
	cLin += WSFT->FT_CFOP+";"
	cLin += Transform(WSFT->FT_ALIQICM,"@E 99.99")+";"
	cLin += Transform(WSFT->FT_VALICM,"@E 999,999,999,999.99")+";"
	cLin += Transform(WSFT->FT_VALCONT,"@E 999,999,999,999.99")+";"
	cLin += Transform(WSFT->FT_ICMSCOM,"@E 999,999,999,999.99")
	cLin += ENTER

	nTot1 += WSFT->FT_VALICM
	nTot2 += WSFT->FT_VALCONT
	nTot3 += WSFT->FT_ICMSCOM

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		MsgAlert(OemToansi("Ocorreu um erro na grava豫o do arquivo."),OemToAnsi("Aten豫o!"))
		Exit
	Endif

	dbSelectArea("WSFT")
	dbSkip()

Enddo

cLin := ""
cLin += " ; ; ; ; ; ; ; ; ; ; ; "
cLin += ENTER

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	MsgAlert(OemToansi("Ocorreu um erro na grava豫o do arquivo."),OemToAnsi("Aten豫o!"))
	Return
Endif

cLin := ""
cLin += " ; ; ; ; ; ; ; ;TOTAL;"+Transform(nTot1,"@E 999,999,999,999.99")+";"+Transform(nTot2,"@E 999,999,999,999.99")+";"+Transform(nTot3,"@E 999,999,999,999.99")
cLin += ENTER

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	MsgAlert(OemToansi("Ocorreu um erro na grava豫o do arquivo."),OemToAnsi("Aten豫o!"))
	Return
Endif

dbSelectArea("WSFT")
dbCloseArea("WSFT")
RetIndex("SFT")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� O arquivo texto deve ser fechado.   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
fClose(nHdl)

Return

/*
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇� Funcao   � AcessaPar   � Autor � Marcos Candido     � Data �          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Funcao para acessar o grupo de perguntas                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      �                                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Static Function AcessaPar(cPerg,lOk)

If Pergunte(cPerg)
	lOk := .T.
Endif

Return(lOk)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg, aRegs)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aHelpPor := {}
Local aAreaAtual := GetArea()
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

For i:=1 to Len(aRegs)
	aIns(aRegs[i],1)
	aRegs[i,1]:=cPerg
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aAreaAtual)
Return

