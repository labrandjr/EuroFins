#include "rwmake.ch"
#include "topconn.ch"

#DEFINE ENTER CHR(13)+CHR(10)


/*/{protheus.doc}ExpCSV04 
Gera arquivo CSV das notas fiscais de entrada que tiveram calculo de icms complementar.
@Author  Marcos Candido     
@since  08/02/2016   
/*/
User Function ExpCSV04

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSays      := {}
Local aButtons   := {}
Local cCadastro  := OemToansi('Geração de arquivo texto para Planilha no MS-Excel')
Local lOkParam   := .F.
Local cPerg      := PADR("EXPCSV04",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
Local cMens      := OemToAnsi('A opção de Parâmetros desta rotina deve ser acessada antes de sua execução!')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Organiza o Grupo de Perguntas e Help ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHelpPor := {}
aAdd(aHelpPor,"Informe a data inicial a ser considerada")
aAdd(aHelpPor,"na filtragem das informações.")
Aadd(aPergs,{"01","Dt Digitacao Inicial","","","mv_ch1","D",8,0,1,"G","","MV_PAR01"})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data final a ser considerada")
aAdd(aHelpPor,"na filtragem das informações.")
Aadd(aPergs,{"02","Dt Digitacao Final","","","mv_ch2","D",8,0,1,"G","","MV_PAR02"})

aHelpPor := {}
aAdd(aHelpPor,"Informe o diretório em que será gerado")
aAdd(aHelpPor,"o arquivo.")
aAdd(aHelpPor,"Por exemplo: C:\TEMP\")
Aadd(aPergs,{"03","Diretorio","","","mv_ch3","C",30,0,1,"G","","MV_PAR03"})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo.")
aAdd(aHelpPor,"SEMPRE INDIQUE A EXTENSÃO CSV.")
aAdd(aHelpPor,"Por exemplo: EUROFINS.CSV")
Aadd(aPergs,{"04","Arquivo","","","mv_ch4","C",20,0,1,"G","","MV_PAR04"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria, se necessario, o grupo de Perguntas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSx1(cPerg,aPergs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Interface com o usuario             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aSays,OemToAnsi('Este programa visa gerar um arquivo texto com informações das notas '))
aAdd(aSays,OemToAnsi('fiscais de entrada que tiveram cálculo de ICMS Complementar.        '))
aAdd(aSays,OemToAnsi('O arquivo será aberto em uma Planilha do MS-Excel.'))
aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| GeraArq()}),o:oWnd:End()),Aviso(OemToAnsi('Atenção!!!'), cMens , {'Ok'})) } } )
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons,,230,470 ) // altura x largura

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³          º Autor ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao chamada pelo botao OK na tela inicial de processamenº±±
±±º          ³ to. Executa a geracao do arquivo texto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GeraArq

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao existir, cria o diretorio, e em seguida, cria o arquivo texto.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MontaDir(cDir)
nHdl := fCreate(cDir+cNomArq)

If nHdl == -1
	MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq+" não pode ser executado! Verifique os parãmetros."),OemToAnsi("Atenção!"))
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| RunCont() },"Processando...")

If !ApOleClient("MsExcel")
	MsgBox("Microsoft Excel Não Instalado !", "Atenção", "INFO")
Else
	oExcelApp := MsExcel():New()
   	oExcelApp:WorkBooks:Open(cDir+cNomArq)
   	oExcelApp:SetVisible(.T.)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ RUNCONT  º Autor ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
			Exit
		Endif
		lFirst := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc(OemToAnsi("Processando informações..."))

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
		MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
		Exit
	Endif

	dbSelectArea("WSFT")
	dbSkip()

Enddo

cLin := ""
cLin += " ; ; ; ; ; ; ; ; ; ; ; "
cLin += ENTER

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
	Return
Endif

cLin := ""
cLin += " ; ; ; ; ; ; ; ;TOTAL;"+Transform(nTot1,"@E 999,999,999,999.99")+";"+Transform(nTot2,"@E 999,999,999,999.99")+";"+Transform(nTot3,"@E 999,999,999,999.99")
cLin += ENTER

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
	Return
Endif

dbSelectArea("WSFT")
dbCloseArea("WSFT")
RetIndex("SFT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O arquivo texto deve ser fechado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fClose(nHdl)

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ AcessaPar   ³ Autor ³ Marcos Candido     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para acessar o grupo de perguntas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

