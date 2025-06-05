#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} ArqContCC
Geracao de um arquivo texto com dados necessarios para a contabilidade
@author Marcos Candido
@since 04/01/2018
/*/
User Function ArqCoCC2()
Local aSays      := {}
Local aButtons   := {}
Local cCadastro  := OemToansi('Geração de arquivos texto para a Contabilidade')
Local lOkParam   := .F.
Local cPerg      := PADR("ARQCONCC",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
Local cMens      := OemToAnsi('A opção de Parâmetros desta rotina deve ser acessada antes de sua execução!')

Private _cEOL   := "CHR(13)+CHR(10)"
_cEOL := Trim(_cEOL)
_cEOL := &_cEOL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Organiza o Grupo de Perguntas e Help ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHelpPor := {}
aAdd(aHelpPor,"Informe a data inicial a ser considerada")
aAdd(aHelpPor,"na filtragem das informações que serão")
aAdd(aHelpPor,"enviadas ao escritório de contabilidade.")
Aadd(aPergs,{"Da Data","","","mv_ch1","D",8,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data final a ser considerada")
aAdd(aHelpPor,"na filtragem das informações que serão")
aAdd(aHelpPor,"enviadas ao escritório de contabilidade.")
Aadd(aPergs,{"Ate a Data","","","mv_ch2","D",8,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe o diretório em que será gerado")
aAdd(aHelpPor,"o arquivo.")
aAdd(aHelpPor,"Por exemplo: C:\CONTAB\")
Aadd(aPergs,{"Diretorio","","","mv_ch3","C",30,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo com os")
aAdd(aHelpPor,"dados das baixas a receber.")
aAdd(aHelpPor,"Por exemplo: BX_CLI.TXT")
Aadd(aPergs,{"Nome do Arquivo Cta Receber","","","mv_ch4","C",30,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo com os")
aAdd(aHelpPor,"dados das baixas a pagar.")
aAdd(aHelpPor,"Por exemplo: BX_FOR.TXT")
Aadd(aPergs,{"Nome do Arquivo Cta Pagar","","","mv_ch5","C",30,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Deseja gerar os arquivos e envia-los")
aAdd(aHelpPor,"para o Ms-Excel, ou só gera-los")
aAdd(aHelpPor,"em disco?")
Aadd(aPergs,{"Metodo de Saida","","","mv_ch6","N",01,0,1,"C","","MV_PAR06","Excel","","","","","Arquivo","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria, se necessario, o grupo de Perguntas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AjustaSx1(cPerg,aPergs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Interface com o usuario             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aSays,OemToAnsi('Este programa visa gerar para o escritório de contabilidade, um '))
aAdd(aSays,OemToAnsi('arquivo texto com informações das movimentações financeiras '))
aAdd(aSays,OemToAnsi('realizadas no período indicado nos parâmetros. O lay-out foi '))
aAdd(aSays,OemToAnsi('definido pelo sistema Cuca Fresca. '))
aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| ProcGer()}),o:oWnd:End()),Aviso(OemToAnsi('Atenção!!!'), cMens , {'Ok'})) } } )
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons,,210,430 ) // altura x largura

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

Static Function ProcGer

If Empty(mv_par03) // .or. Empty(mv_par04) .or. Empty(mv_par05)
	Aviso("Arquivo Texto","Os parâmetros não foram devidamente preenchidos."+_cEOL+_cEOL+"Verifique.",{"Sair"},3)
    Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| RunCont() },"Processando...")

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
Local nTamLin, cCpo
Local cFiltro   := "", cBarra := ""
Local aDados := {}
Local cDir := "" , nVezes := 2
Local cNomArq1 := Alltrim(mv_par04)
Local cNomArq2 := Alltrim(mv_par05)

Private cLin := ""

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

For nV:=1 to nVezes

	If nV == 1
		cCart := "P"
		cTxtCart := "Pagar"

		If !Empty(cNomArq2)

			nHdl := fCreate(cDir+cNomArq2)

			If nHdl == -1
				MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq2+" não pode ser executado! Verifique os parâmetros."),OemToAnsi("Atenção!"))
				Return
			Endif

			GeraInfo(cCart,cTxtCart)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O arquivo texto deve ser fechado.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fClose(nHdl)

		Endif

	Else

		cCart := "R"
		cTxtCart := "Receber"

		If !Empty(cNomArq1)

			nHdl := fCreate(cDir+cNomArq1)

			If nHdl == -1
				MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq1+" não pode ser executado! Verifique os parâmetros."),OemToAnsi("Atenção!"))
				Return
			Endif

			GeraInfo(cCart,cTxtCart)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O arquivo texto deve ser fechado.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fClose(nHdl)

		Endif

 	Endif

Next nV

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


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³  GeraInfo   ³ Autor ³ Marcos Candido     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para realizar o processamento dos dados.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraInfo(cCart,cTxtCart)

Local cExp 			:= ""
Local nValor:=0,nDesc:=0,nJuros:=0,nMulta:=0,nJurMul:=0,nCM:=0,dData,nVlMovFin:=0
Local nAbatLiq := 0,nTotAbImp := 0,nTotImp := 0,nTotAbLiq := 0,nGerAbLiq := 0,nGerAbImp := 0
Local cBanco,cAnterior,dDispo,cLoja
Local lContinua		:=.T.
Local lBxTit		:=.F.
Local aCampos:= {},cNomArq:="",nVlr,cLinha,lOriginal:=.T.
Local nAbat 		:= 0
Local nRecSe5 		:= 0
Local dDtMovFin
Local nRecEmp 		:= SM0->(Recno())
Local cCliFor190	:= ""
Local nDecs	   		:= GetMv("MV_CENT")
Local nMoedaBco		:= 1
Local cCarteira
Local aStru		:= SE5->(DbStruct()), nI
Local cQuery
Local cFilTrb
Local lAsTop		:= .T.
Local cChave, bFirst
Local cFilOrig
Local lAchou		:= .F.
Local nTamEH		:= TamSx3("EH_NUMERO")[1]
Local nTamEI		:= TamSx3("EI_NUMERO")[1]+TamSx3("EI_REVISAO")[1]+TamSx3("EI_SEQ")[1]
Local cFilUlt		:= SM0->M0_CODFIL
Local nRecno
Local nSavOrd
Local aAreaSE5
Local cChaveNSE5	:= ""
Local nRecSE2		:= 0
Local aAreaSE2
Local aAreabk

Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

Local nTaxa:= 0
Local lUltBaixa := .F.
Local cChaveSE1 := ""
Local cChaveSE5 := ""
Local cSeqSE5 := ""
Local cBancoAnt, cAgAnt, cContaAnt
Local lNaturez := .F.

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
Local lPccBxCr	:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)
Local nPccBxCr := 0
Local nVlrIR := nVlrPIS := nVlrCOF := nVlrCSL := 0

//Controla o Pis Cofins e Csll na RA (1 = Controla retenção de impostos no RA; ou 2 = Não controla retenção de impostos no RA(default))
Local lRaRtImp  := If (FindFunction("FRaRtImp"),FRaRtImp(),.F.)
Local cLinCabec := ""

Local aItExcel  := {}
Local aCabExcel := {}

If cCart == "R"
	cLinCabec := "CNPJ EUROFINS;INDICACAO DA NOTA;DATA EMISSAO DOCUMENTO;ESPECIE;SERIE DA NOTA;NUMERO DA NOTA;CNPJ-CPF CLIENTE;NUM NOTA+PARCELA;DATA VENCIMENTO;VALOR A BAIXAR;CONTA DE PGTO;DATA BAIXA;VALOR PAGO;JUROS;DESCONTO;PIS,COFINS,CSLL,BASE"
	aCabExcel := {"CNPJ EUROFINS","INDICACAO DA NOTA","DATA EMISSAO DOCUMENTO","ESPECIE","SERIE DA NOTA","NUMERO DA NOTA","CNPJ-CPF CLIENTE","NUM NOTA+PARCELA","DATA VENCIMENTO","VALOR A BAIXAR","CONTA DE PGTO","DATA BAIXA","VALOR PAGO","JUROS","DESCONTO","PIS","COFINS","CSLL","BASE"}
	//cLinCabec := "CNPJ EUROFINS;INDICACAO DA NOTA;DATA EMISSAO DOCUMENTO;ESPECIE;NUMERO DA NOTA;CNPJ-CPF CLIENTE;NUM NOTA+PARCELA;DATA VENCIMENTO;VALOR A BAIXAR;CONTA DE PGTO;DATA BAIXA;VALOR PAGO;JUROS;DESCONTO"
	//aCabExcel := {"CNPJ EUROFINS","INDICACAO DA NOTA","DATA EMISSAO DOCUMENTO","ESPECIE","NUMERO DA NOTA","CNPJ-CPF CLIENTE","NUM NOTA+PARCELA","DATA VENCIMENTO","VALOR A BAIXAR","CONTA DE PGTO","DATA BAIXA","VALOR PAGO","JUROS","DESCONTO"}
Else
	cLinCabec := "CNPJ EUROFINS;INDICACAO DA NOTA;DATA EMISSAO DOCUMENTO;ESPECIE;SERIE DA NOTA;NUMERO DA NOTA;PRC;CNPJ-CPF FORNECEDOR;NUM NOTA+PARCELA;CONTA DE PGTO;HISTORICO DA CONTA;DATA BAIXA;VALOR PAGO;JUROS;DESCONTO;VALOR A BAIXAR;DATA VENCIMENTO;ORIGEM"
	aCabExcel := {"CNPJ EUROFINS","INDICACAO DA NOTA","DATA EMISSAO DOCUMENTO","ESPECIE","SERIE DA NOTA","NUMERO DA NOTA","PRC","CNPJ-CPF FORNECEDOR","NUM NOTA+PARCELA","CONTA DE PGTO","HISTORICO DA CONTA","DATA BAIXA","VALOR PAGO","JUROS","DESCONTO","VALOR A BAIXAR","DATA VENCIMENTO","ORIGEM"}
Endif

Private nIndexSE5	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCond3	:= ".T."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilDe := SM0->M0_CODFIL
cFilAte:= SM0->M0_CODFIL

dbSelectArea("SE5")
cCondicao := "E5_DTDISPO >= mv_par01 .and. E5_DTDISPO <= mv_par02"
cCond2 := "E5_DTDISPO"
cChave := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
cChaveInterFun := cChave
bFirst := {||MsSeek(xFilial("SE5")+Dtos(mv_par01),.T.)}

cCondicao := ".T."
DbSelectArea("SE5")
cQuery := ""
aEval(DbStruct(),{|e| cQuery += ","+AllTrim(e[1])})

// Obtem os registros a serem processados
cQuery := "SELECT " +SubStr(cQuery,2)
cQuery += ",SE5.R_E_C_N_O_ SE5RECNO "
cQuery += "FROM " + RetSqlName("SE5")+" SE5 "
cQuery += "WHERE "

If cCart == "R"
	cQuery += "E5_RECPAG = 'R' AND "
Else
	cQuery += "E5_RECPAG = 'P' AND "
Endif

cQuery += "      E5_DTDISPO    between '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND "
//cQuery += "      E5_DATA    <= '" + DTOS(dDataBase) + "' AND "
cQuery += "      SE5.D_E_L_E_T_ = ' '  AND "
cQuery += "		  E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE') AND "
cQuery += " 	  E5_SITUACA NOT IN ('C','E','X') AND "
cQuery += "      ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR "
cQuery += "      (E5_TIPODOC <> 'CD')) "
cQuery += "		  AND E5_HISTOR NOT LIKE '%"+"Baixa Automatica / Lote"+"%'"

If cCart=="P"
	cQuery += " AND E5_TIPODOC <> 'E2'"
endif

cQuery += " AND E5_TIPODOC <> '" + SPACE(LEN(E5_TIPODOC)) + "'"
cQuery += " AND E5_NUMERO  <> '" + SPACE(LEN(E5_NUMERO)) + "'"
cQuery += " AND E5_TIPODOC <> 'CH'"
cQuery += " AND E5_FILIAL = '" + FwxFilial("SE5") + "'"

cCondFil := "NEWSE5->E5_FILIAL==xFilial('SE5')"

// seta a ordem de acordo com a opcao do usuario
cQuery += " ORDER BY " + SqlOrder(cChave)
cQuery := ChangeQuery(cQuery)
IF CCART == "R"
	MEMOWRITE("C:\TEMP\REC.SQL",cquery)
ELSE
	MEMOWRITE("C:\TEMP\PAG.SQL",cquery)
ENDIF

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "NEWSE5", .F., .T.)
For nI := 1 TO LEN(aStru)
	If aStru[nI][2] != "C"
		TCSetField("NEWSE5", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
	EndIf
Next
DbGoTop()

Count to nTotReg

ProcRegua(nTotReg) // Numero de registros a processar

DbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array para arquivo de trabalho    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{"LINHA","C",80,0 } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de Trabalho   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TRB") > 0
	dbCloseArea()
Endif
cNomArq := CriaTrab(aCampos)
dbUseArea( .T.,, cNomArq, "TRB", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("TRB",cNomArq,"LINHA",,,OemToAnsi("Selecionando Registros..."))

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

While !Eof() .and. SM0->M0_CODFIL <= cFilAte

	cFilAnt := SM0->M0_CODFIL

	DbSelectArea("NEWSE5")

	While NEWSE5->(!Eof()) .And. &cCondFil .And. &cCondicao .and. lContinua

		DbSelectArea("NEWSE5")

		// Testa condicoes de filtro
		If !Fr190TstCond(.F.,cCart)
			NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
			Loop
		Endif

		If (NEWSE5->E5_RECPAG == "R" .and. ! (NEWSE5->E5_TIPO $ "PA /"+MV_CPNEG )) .or. ;	//Titulo normal
			(NEWSE5->E5_RECPAG == "P" .and.   (NEWSE5->E5_TIPO $ "RA /"+MV_CRNEG )) 	//Adiantamento
			cCarteira := "R"
		Else
			cCarteira := "P"
		Endif

		dbSelectArea("NEWSE5")
		cAnterior 	:= &cCond2
		cBancoAnt	:= NEWSE5->E5_BANCO
		cAgAnt		:= NEWSE5->E5_AGENCIA
		cContaAnt	:= NEWSE5->E5_CONTA

		While NEWSE5->(!EOF()) .and. &cCond2=cAnterior .and. &cCondFil .and. lContinua

			dbSelectArea("NEWSE5")

			// Testa condicoes de filtro
			If !Fr190TstCond(.T.,cCart)
				dbSelectArea("NEWSE5")
				NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
				Loop
			Endif

			cNumero    	:= NEWSE5->E5_NUMERO
			cPrefixo   	:= NEWSE5->E5_PREFIXO
			cParcela   	:= NEWSE5->E5_PARCELA
			dBaixa     	:= NEWSE5->E5_DATA
			cBanco     	:= NEWSE5->E5_BANCO
			cLoja      	:= NEWSE5->E5_LOJA
			cSeq       	:= NEWSE5->E5_SEQ
			cNumCheq   	:= NEWSE5->E5_NUMCHEQ
			cCheque    	:= NEWSE5->E5_NUMCHEQ
			cTipo      	:= NEWSE5->E5_TIPO
			cFornece   	:= NEWSE5->E5_CLIFOR
			cLoja      	:= NEWSE5->E5_LOJA
			dDispo     	:= NEWSE5->E5_DTDISPO
			lBxTit	  	:= .F.
			cFilorig    := NEWSE5->E5_FILORIG

			If (NEWSE5->E5_RECPAG == "R" .and. ! (NEWSE5->E5_TIPO $ "PA /"+MV_CPNEG )) .or. ;	//Titulo normal
				(NEWSE5->E5_RECPAG == "P" .and.   (NEWSE5->E5_TIPO $ "RA /"+MV_CRNEG )) 	//Adiantamento
				dbSelectArea("SE1")
				dbSetOrder(1)
				lBxTit := MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo)
				If !lBxTit
					lBxTit := dbSeek(NEWSE5->E5_FILORIG+cPrefixo+cNumero+cParcela+cTipo)
				Endif
				cCarteira := "R"
				dDtMovFin := DataValida(SE1->E1_VENCTO,.T.)
				While SE1->(!Eof()) .and. SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO==cPrefixo+cNumero+cParcela+cTipo
					If SE1->E1_CLIENTE == cFornece .And. SE1->E1_LOJA == cLoja	// Cliente igual, Ok
						Exit
					Endif
					SE1->( dbSkip() )
				EndDo
				cCond3:="E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_SEQ+E5_NUMCHEQ==cPrefixo+cNumero+cParcela+cTipo+DtoS(dBaixa)+cSeq+cNumCheq"
				nDesc := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
			Else
				dbSelectArea("SE2")
				DbSetOrder(1)
				cCarteira := "P"
				lBxTit 	:= MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)

				Iif(lBxTit, nRecSE2	:= SE2->(Recno()), nRecSE2 := 0 )

				If !lBxTit
					lBxTit := dbSeek(NEWSE5->E5_FILORIG+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)
				Endif
				dDtMovFin := DataValida(SE2->E2_VENCTO,.T.)
				cCond3:="E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+DtoS(E5_DATA)+E5_SEQ+E5_NUMCHEQ==cPrefixo+cNumero+cParcela+cTipo+cFornece+DtoS(dBaixa)+cSeq+cNumCheq"
				nDesc := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
				cCheque := Iif(Empty(NEWSE5->E5_NUMCHEQ),SE2->E2_NUMBCO,NEWSE5->E5_NUMCHEQ)
			Endif

			dbSelectArea("NEWSE5")

			While NEWSE5->( !Eof()) .and. &cCond3 .and. lContinua .And. &cCondFil

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Incrementa a regua                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc("Lendo Registros da Carteira a "+cTxtCart+" ...")

				dbSelectArea("NEWSE5")
				cCheque    := NEWSE5->E5_NUMCHEQ

				// Testa condicoes de filtro
				If !Fr190TstCond(.T.,cCart)
					dbSelectArea("NEWSE5")
					NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
					Loop
				Endif

				If NEWSE5->E5_SITUACA $ "C/E/X"
					dbSelectArea("NEWSE5")
					NEWSE5->( dbSkip() )
					Loop
				EndIF

				If NEWSE5->E5_LOJA != cLoja
					Exit
				Endif

				dBaixa     	:= NEWSE5->E5_DATA
				cSeq       	:= NEWSE5->E5_SEQ
				cNumCheq   	:= NEWSE5->E5_NUMCHEQ
				cFilorig    := NEWSE5->E5_FILORIG
				dDispo     	:= NEWSE5->E5_DTDISPO

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obter moeda da conta no Banco.                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nMoedaBco	:=	1

				If !Empty(NEWSE5->E5_NUMERO)
					If (NEWSE5->E5_RECPAG == "R" .and. !(NEWSE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG)) .or. ;
						(NEWSE5->E5_RECPAG == "P" .and. NEWSE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG) .Or.;
						(NEWSE5->E5_RECPAG == "P" .And. NEWSE5->E5_TIPODOC $ "DB#OD")
						dbSelectArea( "SA1")
						dbSetOrder(1)
						lAchou := .F.
						If Empty(xFilial("SA1"))  //SA1 Compartilhado
							If dbSeek(xFilial("SA1")+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
								lAchou := .T.
							Endif
						Else
							cFilOrig := NEWSE5->E5_FILIAL //Procuro SA1 pela filial do movimento
							If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
								If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
									lAchou := .T.
								Else
									cFilOrig := NEWSE5->E5_FILORIG //Procuro SA1 pela filial origem
									If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
										If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
											lAchou := .T.
										Endif
									Endif
								Endif
							Else
								cFilOrig := NEWSE5->E5_FILORIG	//Procuro SA1 pela filial origem
								If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
										lAchou := .T.
									Endif
								Endif
							Endif
						EndIF
					Else
						dbSelectArea( "SA2")
						dbSetOrder(1)
						lAchou := .F.
						If Empty(FwFilial("SA2"))  //SA2 Compartilhado
							If dbSeek(xFilial("SA2")+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA) .and. !Empty(SA2->A2_CGC)
								lAchou := .T.
							Endif
						Else
							cFilOrig := NEWSE5->E5_FILIAL //Procuro SA2 pela filial do movimento
							If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
								If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
									lAchou := .T.
								Else
									cFilOrig := NEWSE5->E5_FILORIG //Procuro SA2 pela filial origem
									If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
										If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
											lAchou := .T.
										Endif
									Endif
								Endif
							Else
								cFilOrig := NEWSE5->E5_FILORIG	//Procuro SA2 pela filial origem
								If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
										lAchou := .T.
									Endif
								Endif
							Endif
						EndIF
					EndIf
				EndIf
				dbSelectArea("SM2")
				dbSetOrder(1)
				dbSeek(NEWSE5->E5_DATA)
				dbSelectArea("NEWSE5")
				nTaxa:= 0
				If !Empty(NEWSE5->E5_TXMOEDA)
					nTaxa:=NEWSE5->E5_TXMOEDA
				Else
					If nMoedaBco == 1
						nTaxa := NEWSE5->E5_VALOR / NEWSE5->E5_VLMOED2
					Else
						nTaxa := NEWSE5->E5_VLMOED2 / NEWSE5->E5_VALOR
					EndIf
				EndIf
				nRecSe5 := NEWSE5->SE5RECNO
				nDesc   += NEWSE5->E5_VLDESCO
				nJuros  += NEWSE5->E5_VLJUROS
				nMulta  += NEWSE5->E5_VLMULTA
				nJurMul += nJuros + nMulta
				nCM     += NEWSE5->E5_VLCORRE

				If cCarteira == "R" .and. SE1->E1_MOEDA == 1
					nCM := 0
				ElseIf cCarteira == "P" .and. SE2->E2_MOEDA == 1
					nCM := 0
				Endif

				if NEWSE5->E5_NUMERO = '000094840'
					XY:=1
				endif

				If lPccBaixa .and. Empty(NEWSE5->E5_PRETPIS) .And. Empty(NEWSE5->E5_PRETCOF) .And. Empty(NEWSE5->E5_PRETCSL)
					If nRecSE2 > 0

						aAreabk  := Getarea()
						aAreaSE2 := SE2->(Getarea())
						SE2->(DbGoto(nRecSE2))

						nTotAbImp += (NEWSE5->E5_VRETPIS)+(NEWSE5->E5_VRETCOF)+(NEWSE5->E5_VRETCSL)+SE2->E2_INSS+SE2->E2_ISS+SE2->E2_IRRF
						nVlrIR  += SE2->E2_IRRF
						nVlrPIS += (NEWSE5->E5_VRETPIS)
						nVlrCOF += (NEWSE5->E5_VRETCOF)
						nVlrCSL += (NEWSE5->E5_VRETCSL)

						Restarea(aAreaSE2)
						Restarea(aAreabk)
					Else
						nTotAbImp += (NEWSE5->E5_VRETPIS)+(NEWSE5->E5_VRETCOF)+(NEWSE5->E5_VRETCSL)
						nVlrIR  += 0
						nVlrPIS += (NEWSE5->E5_VRETPIS)
						nVlrCOF += (NEWSE5->E5_VRETCOF)
						nVlrCSL += (NEWSE5->E5_VRETCSL)
					Endif
				Endif

				If NEWSE5->E5_TIPODOC $ "VL/V2/BA/RA/PA/CP"

					nValor += NEWSE5->E5_VALOR

					//Pcc Baixa CR
					If cCarteira == "R" .and. lPccBxCr .and. IiF(lRaRtImp,NEWSE5->E5_TIPO $ MVRECANT,.T.)
						If Empty(NEWSE5->E5_PRETPIS)
							nPccBxCr += NEWSE5->E5_VRETPIS
							nVlrPIS += NEWSE5->E5_VRETPIS
						Endif
						If Empty(NEWSE5->E5_PRETCOF)
							nPccBxCr += NEWSE5->E5_VRETCOF
							nVlrCOF += NEWSE5->E5_VRETCOF
						Endif
						If Empty(NEWSE5->E5_PRETCSL)
							nPccBxCr += NEWSE5->E5_VRETCSL
							nVlrCSL += NEWSE5->E5_VRETCSL
						Endif
					Endif

				Else
					nVlMovFin  += NEWSE5->E5_VALOR
				Endif

				dbSkip()

			EndDO

			If (nDesc+nValor+nJurMul+nCM+nVlMovFin) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ C lculo do Abatimento        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCarteira == "R"
					dbSelectArea("SE1")
					nRecno := Recno()
					nAbat := 0
					nAbatLiq := 0
					If !SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Encontra a ultima sequencia de baixa na SE5 a partir do título da SE1 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAreaSE1 := SE1->(GetArea())
						dbSelectArea("SE5")
						dbSetOrder(7)
						cChaveSE1 := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
						SE5->(MsSeek(xFilial("SE5")+cChaveSE1))

						cSeqSE5 := SE5->E5_SEQ

						While SE5->(!EOF()) .And. cChaveSE1 == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
							If SE5->E5_SEQ > cSeqSE5
								cSeqSE5 := SE5->E5_SEQ
							Endif
							SE5->(dbSkip())
						Enddo

						SE5->(MsSeek(xFilial("SE5")+cChaveSE1+cSeqSE5))
						cChaveSE5 := cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja+cSeq

						If cChaveSE5 == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) .And. Empty(SE1->E1_SALDO)
							If SE1->E1_VALOR <> SE1->E1_VALLIQ
								lUltBaixa := .T.
							EndIf
						EndIf

						RestArea(aAreaSE1)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o valor total de abatimento do titulo e impostos se houver ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nTotAbImp := 0

						If lUltBaixa
							nAbat := SumAbatRec(cPrefixo,cNumero,cParcela,SE1->E1_MOEDA,"V",dBaixa,@nTotAbImp)
							nAbatLiq := nAbat - nTotAbImp
						EndIf

						lUltBaixa := .F.
					EndIf
					dbSelectArea("SE1")
					dbGoTo(nRecno)
				Else
					dbSelectArea("SE2")
					nRecno := Recno()
					nAbat := 0
					nAbatLiq := 0
					If !SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						nAbat := SomaAbat(cPrefixo,cNumero,cParcela,"P",1,,cFornece,cLoja)
						nAbatLiq := nAbat
					EndIf
					dbSelectArea("SE2")
					dbGoTo(nRecno)
				EndIF

				cLin := ""

				cCpo1 := Transform(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99")+";" // CNPJ da Empresa

				// contas a pagar
				If cCart=="P"
					cCliFor190 := SE2->E2_FORNECE+SE2->E2_LOJA
					cCpo2 := "E"+";"															// Indicacao da nota -> E = Entrada, S = Saída, P = Serviço, 1 = Serviço 51 e 3 = Serviço 53
					cCpo3 := dtoc(GravaData(SE2->E2_EMISSAO,.T.,5))+";"						// Data do documento
					cAux1 := Alltrim(Posicione("SF1",1,xFilial("SF1")+SE2->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),"F1_ESPECIE"))
					If cAux1 == "SPED"
						cCpo4 := "NFE"                                                           // Espécie da Nota (NF,NFE,NFS)
					ElseIf Empty(cAux1)
						cCpo4 := "FAT"                                                           // Espécie da Nota (NF,NFE,NFS)
					Else
						cCpo4 := cAux1                                                           // Espécie da Nota (NF,NFE,NFS)
					Endif
					cCpo4 += ";"
					cCpo5 := SE2->E2_PREFIXO+";"                                          		// Série da Nota (1,10,11,A,B)
					cCpo6 := StrZero(Val(cNumero),9)+";"                                      	// Numero do documento
					cCpo7 := Alltrim(Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CGC"))	// CNPJ/CPF Fornecedor/Cliente
					cCpo16 := dtoc(GravaData(SE2->E2_VENCTO,.T.,5))+";"                        	// Data do Vencimento
                // contas a receber
				Else
					cCliFor190 := SE1->E1_CLIENTE+SE1->E1_LOJA
					cCpo2 := "P"+";"															// Indicacao da nota -> E = Entrada, S = Saída, P = Serviço, 1 = Serviço 51 e 3 = Serviço 53
					cCpo3 := dtoc(GravaData(SE1->E1_EMISSAO,.T.,5))+";"						// Data do documento
					//cCpo4 := "NFSE"+";"                                                        	// Espécie da Nota (NF,NFE,NFS)
					cCpo4 := "NFS"+";"                                                         	// Espécie da Nota (NF,NFE,NFS)
					cCpo5 := "E"+";"                                                           	// Série da Nota (1,10,11,A,B)
					cCpo6 := StrZero(Val(cNumero),9)+";"                                      	// Numero do documento
					cCpo7 := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliFor190,"A1_CGC")) 	// CNPJ/CPF Fornecedor/Cliente
					cCpo9 := dtoc(GravaData(SE1->E1_VENCTO,.T.,5))+";"                        	// Data do Vencimento
					If nVlrIR == 0
						nVlrIR  += SE1->E1_IRRF
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Baixas a Receber             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCart == "R"
					nVlr := SE1->E1_VLCRUZ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Baixa de PA                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					lCalcIRF := Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CALCIRF") == "1" .Or.;//1-Normal, 2-Baixa
					Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CALCIRF") == " "

					// MV_MRETISS "1" retencao do ISS na Emissao, "2" retencao na Baixa.
					nVlr := SE2->E2_VLCRUZ+SE2->E2_INSS+Iif(GetNewPar('MV_MRETISS',"1")=="1",SE2->E2_ISS,0)+Iif(lCalcIRF,SE2->E2_IRRF,0)
				Endif

				cCpo7 := Transform(cCpo7,iif(len(cCpo7)=11,"@R 999.999.999-99",iif(len(cCpo7)==14,"@R 99.999.999/9999-99",Space(18))))
				cCpo7 := Space(18-Len(cCpo7))+cCpo7+";"
				cAux := cParcela
				If Val(cAux) == 0
					If !Empty(cAux)
						If IsAlpha(cAux)
							nAux := Asc(cAux)
							cAux := Alltrim(Str(nAux-64))
						Else
							cAux := "1"
						Endif
					Else
						cAux := "1"
					Endif
				Endif
				cCpo8 := Space(8)+Transform(StrZero(Val(cNumero),9)+StrZero(Val(cAux),3),"@R 999999999-999")+";"	// Número Documento da Baixa/Parcela
				If cCart == "R"
//					cCpo10 := StrTran(StrZero(nValor-SE1->E1_IRRF,13,2),".",",")+";"                                               	// Valor a baixar
					cCpo10 := StrTran(StrZero(SE1->E1_VALOR-SE1->E1_IRRF,13,2),".",",")+";"                                               	// Valor a baixar
					If cBanco == "341"                                                                              	// Numero da Conta
						cCpo11 := "101.007-7"
					ElseIf cBanco == "237"
						cCpo11 := "101.165-0"
					ElseIf cBanco == "104"
						cCpo11 := "101.016-6"
					ElseIf cBanco == "001"
						cCpo11 := "101.105-7"
					ElseIf cBanco == "033"
						cCpo11 := "101.314-9"
					ElseIf cBanco == "CX1"
						cCpo11 := "100.005-5"
					Else
						cCpo11 := Space(9)
					Endif
					cCpo11 += ";"
					cCpo12 := dtoc(GravaData(dDispo,.T.,5))+";"			                                     	// Data da Disponibilidade
				//	cCpo13 := StrTran(StrZero(nValor-nJurMul+nDesc-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF,13,2),".",",")+";"                             // Valor baixado
					cCpo13 := StrTran(StrZero(SE1->E1_VALOR-nDesc-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_IRRF,13,2),".",",")+";"
					cCpo14 := StrTran(StrZero(nJurMul,13,2),".",",")+";"                                          	// Valor do juros
					cCpo15 := StrTran(StrZero(nDesc,13,2),".",",")                                                	// Valor do desconto
					cCpo16 := StrTran(StrZero(SE1->E1_PIS,13,2),".",",")+";"                                 	// pis
					cCpo17 := StrTran(StrZero(SE1->E1_COFINS,13,2),".",",")+";"                                 	// cofins
					cCpo18 := StrTran(StrZero(SE1->E1_CSLL,13,2),".",",")+";"                                 	// csll
					cCpo19 := StrTran(StrZero(SE1->E1_VALOR-SE1->E1_IRRF,13,2),".",",")+";"                                 	// Valor a baixar
				Else
					If cBanco == "341"                                                                             	// Numero da Conta
						cCpo9 := "101.007-7"
					ElseIf cBanco == "237"
						cCpo9 := "101.165-0"
					ElseIf cBanco == "104"
						cCpo9 := "101.016-6"
					ElseIf cBanco == "001"
						cCpo9 := "101.105-7"
					ElseIf cBanco == "033"
						cCpo9 := "101.314-9"
					ElseIf cBanco == "CX1"
						cCpo9 := "100.005-5"
					Else
						cCpo9 := Space(9)
					Endif
					cCpo9 += ";"
					cCpo10 := "10"+";"                                               	// Codigo 10 - informacao obtida pelo logica
					cCpo11 := dtoc(GravaData(dBaixa,.T.,5))+";"			                                     	// Data da Baixa
					cCpo12 := StrTran(StrZero(nValor,13,2),".",",")+";"                                           	// Valor baixado
					cCpo13 := StrTran(StrZero(nJurMul,13,2),".",",")+";"                                          	// Valor do juros
					cCpo14 := StrTran(StrZero(nDesc,13,2),".",",")+";"                                                	// Valor do desconto
					cCpo15 := StrTran(StrZero(nValor-nJurMul+nDesc,13,2),".",",")+";"                                 	// Valor a baixar
				Endif

				If !Empty(cLinCabec)
					cLin += cLinCabec+_cEOL
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Processo Abortado."),OemToAnsi("Atenção!"))
						Return
					Endif
					cLinCabec := ""
					cLin      := ""
				Endif

				//Verificação de Faturas
				if cCart == "P" .and. cCpo4 == "FAT;"
					cLin += cCpo1+cCpo2+cCpo3+cCpo4+cCpo5+cCpo6+"1;"+cCpo7+cCpo8+cCpo9+cCpo10+cCpo11+cCpo12+cCpo13+cCpo14+cCpo15+cCpo16+"Titulo"+_cEOL
					if !getTitulos(@nHdl,@aItExcel,cNumero,cCpo1,cCpo2,cCpo6,cCpo7,cCpo9,cCpo10,cCpo11,_cEOL,cFornece,cLoja)
						if fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Processo Abortado."),OemToAnsi("Atenção!"))
							return
						else
							if cCart == "R"
								aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,cCpo11,cCpo12,cCpo13,cCpo14,cCpo15,cCpo16,cCpo17,cCpo18,cCpo19})
								if SE1->E1_PIS > 0
									aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,"153.186-7",cCpo12,cCpo16})
								endif
								if SE1->E1_COFINS > 0
									aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,"153.187-5",cCpo12,cCpo17})
								endif
								if SE1->E1_CSLL > 0
									aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,"153.188-3",cCpo12,cCpo18})
								endif
								if nDesc > 0
									aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,"455.006-4",cCpo12,cCpo15})
								endif
							else
								aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,"1",cCpo7,cCpo8,cCpo9,cCpo10,cCpo11,cCpo12,cCpo13,cCpo14,cCpo15,cCpo16,"Titulo"})
							endif
						endif
					endif
				else
					If cCart == "R"
						cLin += cCpo1+cCpo2+cCpo3+cCpo4+cCpo5+cCpo6+cCpo7+cCpo8+cCpo9+cCpo10+cCpo11+cCpo12+cCpo13+cCpo14+cCpo15+cCpo16+cCpo17+cCpo18+cCpo19+_cEOL
						//cLin += cCpo1+cCpo2+cCpo3+cCpo4+cCpo6+cCpo7+cCpo8+cCpo9+cCpo10+cCpo11+cCpo12+cCpo13+cCpo14+cCpo15+_cEOL
						if SE1->E1_PIS > 0
							cLin += cCpo1+cCpo2+cCpo3+cCpo4+cCpo5+cCpo6+cCpo7+cCpo8+cCpo9+cCpo10+"153.186-7"+cCpo12+cCpo16+_cEOL
						endif
						if SE1->E1_COFINS > 0
							cLin += cCpo1+cCpo2+cCpo3+cCpo4+cCpo5+cCpo6+cCpo7+cCpo8+cCpo9+cCpo10+"153.187-5"+cCpo12+cCpo17+_cEOL
						endif
						if SE1->E1_CSLL > 0
							cLin += cCpo1+cCpo2+cCpo3+cCpo4+cCpo5+cCpo6+cCpo7+cCpo8+cCpo9+cCpo10+"153.188-3"+cCpo12+cCpo18+_cEOL
						endif
						if nDesc > 0
							cLin += cCpo1+cCpo2+cCpo3+cCpo4+cCpo5+cCpo6+cCpo7+cCpo8+cCpo9+cCpo10+"455.006-4"+cCpo12+cCpo15+_cEOL
						endif
					Else
						cLin += cCpo1+cCpo2+cCpo3+cCpo4+cCpo5+cCpo6+"1;"+cCpo7+cCpo8+cCpo9+cCpo10+cCpo11+cCpo12+cCpo13+cCpo14+cCpo15+cCpo16+"Titulo"+_cEOL
					Endif

					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Processo Abortado."),OemToAnsi("Atenção!"))
						Return
					Else
						If cCart == "R"
							aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,cCpo11,cCpo12,cCpo13,cCpo14,cCpo15,cCpo16,cCpo17,cCpo18,cCpo19})
							//aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,cCpo11,cCpo12,cCpo13,cCpo14,cCpo15})
								if SE1->E1_PIS > 0
									aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,"153.186-7",cCpo12,cCpo16})
								endif
								if SE1->E1_COFINS > 0
									aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,"153.187-5",cCpo12,cCpo17})
								endif
								if SE1->E1_CSLL > 0
									aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,"153.188-3",cCpo12,cCpo18})
								endif
								if nDesc > 0
									aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,cCpo7,cCpo8,cCpo9,cCpo10,"455.006-4",cCpo12,cCpo15})
								endif
						Else
							aadd(aItExcel , {cCpo1,cCpo2,cCpo3,cCpo4,cCpo5,cCpo6,"1",cCpo7,cCpo8,cCpo9,cCpo10,cCpo11,cCpo12,cCpo13,cCpo14,cCpo15,cCpo16,"Titulo"})
						Endif
					Endif
				Endif

				dbSelectArea("TRB")
				lOriginal := .T.

				cFilTrb := If(cCarteira=="R","SE1","SE2")
				IF DbSeek( xFilial(cFilTrb)+cPrefixo+cNumero+cParcela+cCliFor190+cTipo)
					nAbat:=0
					lOriginal := .F.
				Else
					nVlr:=NoRound(nVlr)
					RecLock("TRB",.T.)
					  Replace LINHA With xFilial(cFilTrb)+cPrefixo+cNumero+cParcela+cCliFor190+cTipo
					MsUnlock()
				EndIF

				nDesc := nJurMul := nValor := nCM := nAbat := nTotAbImp := nAbatLiq := nVlMovFin := 0
				nPccBxCr	 := 0			//PCC Baixa
				nVlrIR := nVlrPIS := nVlrCOF := nVlrCSL := 0
			Endif

			dbSelectArea("NEWSE5")

		Enddo

	Enddo

	dbSelectArea("SM0")
	cFilUlt := SM0->M0_CODFIL
	dbSkip()

Enddo

SM0->(dbgoto(nRecEmp))
cFilAnt := SM0->M0_CODFIL

dbSelectArea("TRB")
dbCloseArea()
Ferase(cNomArq+GetDBExtension())
If cNomArq # Nil
	Ferase(cNomArq+OrdBagExt())
Endif

dbSelectArea("NEWSE5")
dbCloseArea()

dbSelectArea("SE5")
dbSetOrder(1)

If mv_par06 == 1
	For nI:=1 to Len(aItExcel)
		For nE:=1 to Len(aItExcel[nI])
			aItExcel[nI,nE] := StrTran(aItExcel[nI,nE],";","")
		Next nE
	Next nI
	DlgToExcel({ {"ARRAY", "Exportação para o Excel", aCabExcel, aItExcel} })
Endif


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fr190TstCo³ Autor ³ Claudio D. de Souza   ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Testa as condicoes do registro do SE5 para permitir a impr.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Fr190TstCon()										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR190													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fr190TstCond(lInterno,cCart)

Local lRet := .T.

Do Case
	Case NEWSE5->E5_TIPODOC $ "DC/D2/JR/J2/TL/MT/M2/CM/C2"
		lRet := .F.
	Case NEWSE5->E5_SITUACA $ "C/E/X" .or. NEWSE5->E5_TIPODOC $ "TR#TE" .or.;
		(NEWSE5->E5_TIPODOC == "CD" .and. NEWSE5->E5_VENCTO > NEWSE5->E5_DATA)
		lRet := .F.
	Case NEWSE5->E5_TIPODOC == "E2" .and. cCart=="P"
		lRet := .F.
	Case Empty(NEWSE5->E5_TIPODOC)
		lRet := .F.
	Case Empty(NEWSE5->E5_NUMERO)
		lRet := .F.
	Case NEWSE5->E5_TIPODOC $ "CH"
		lRet := .F.
	Case NEWSE5->E5_TIPODOC == "TR" .Or. NEWSE5->E5_MOTBX == "DSD"
		lRet := .F.
	Case cCart=="R" .And. E5_TIPODOC $ "E2#CB"
		lRet := .F.
	Case !MovBcoBx(NEWSE5->E5_MOTBX)
		lRet := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe estorno para esta baixa, somente no nivel de quebra ³
		//³ mais interno, para melhorar a performance 							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case lInterno .And.;
		!Empty(NEWSE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)) .And.;
		TemBxCanc(NEWSE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
		lRet := .F.
	Case !Empty(NEWSE5->E5_FORNECE)
		If Empty(Posicione("SA2",1,xFilial("SA2")+NEWSE5->(E5_FORNECE+E5_LOJA),"A2_CGC"))
			lRet := .F.
		Endif
		If lRet .and. Alltrim(Posicione("SA2",1,xFilial("SA2")+NEWSE5->(E5_FORNECE+E5_LOJA),"A2_CGC"))=='00000000000000'
			lRet := .F.
		Endif
	Case !Empty(NEWSE5->E5_CLIENTE)
		If Empty(Posicione("SA1",1,xFilial("SA1")+NEWSE5->(E5_CLIENTE+E5_LOJA),"A1_CGC"))
			lRet := .F.
		Endif
		If lRet .and. Alltrim(Posicione("SA1",1,xFilial("SA1")+NEWSE5->(E5_CLIENTE+E5_LOJA),"A1_CGC"))=='00000000000000'
			lRet := .F.
		Endif
EndCase

Return lRet

/*/Funcao que grava os titulos referentes a fatura no arquivo./*/
Static Function getTitulos(nHdl,aItExcel,cNumero,cCpo1,cCpo2,cCpo6,cCpo7,cCpo9,cCpo10,cCpo11,_cEOL,cFornece,cLoja)
	local nVezes 	:= 5
	local nI		:= 1
	local lRet		:= .F.
	local cLin		:= ""
	local cTit3,cTit4,cTit5,cTit6,cTit8,cTit9,cTit12,cTit13,cTit14,cTit15,cTit16	:= ""
	private cAlias	:= ""


	cAlias := QryRgsSE2(cNumero,cFornece,cLoja)
	(cAlias)->(dbGoTop())

	While !(cAlias)->(Eof()) //Fazer um loop
		cTit3 := getEmissao()
		cTit4 := getEspecie()                                                  // Espécie da Nota (NF,NFE,NFS)
		cTit5 := (cAlias)->E2_PREFIXO+";"                                      // Série da Nota (1,10,11,A,B)
		cTit6 := StrZero(Val((cAlias)->E2_NUM),9)+";"                         // Numero do documento
		cTit8 := Space(8)+Transform(StrZero(Val((cAlias)->E2_NUM),9)+StrZero(Val(getParcela((cAlias)->E2_PARCELA)),3),"@R 999999999-999")+";"	// Número Documento da Baixa/Parcela
		cTit9 := getConta()                                                    // Banco
		getValorTitulo (@cTit12,@cTit13,@cTit14,@cTit15)
		cTit16 := dtoc(stod((cAlias)->E2_VENCTO))+";"                         // Data do Vencimento

		cLin := cCpo1+cCpo2+cTit3+cTit4+cTit5+cTit6+"1;"+cCpo7+cTit8+cCpo9+cCpo10+cCpo11+cTit12+cTit13+cTit14+cTit15+cTit16+"Fatura: "+cCpo6+_cEOL
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Processo Abortado."),OemToAnsi("Atenção!"))
			Return
		Else
			aadd(aItExcel , {cCpo1,cCpo2,cTit3,cTit4,cTit5,cTit6,"1",cCpo7,cTit8,cCpo9,cCpo10,cCpo11,cTit12,cTit13,cTit14,cTit15,cTit16,"Fatura: "+cCpo6})
		Endif
		lRet := .T.
		(cAlias)->(DbSkip())
	Enddo
return lRet

/*/Funcao que retorna uma query com títulos referentes a fatura no arquivo./*/
Static Function QryRgsSE2(cNumero,cFornece,cLoja)
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cEol   := chr(10) + chr(13)

	cQuery := " SELECT E2_NUM, E2_PREFIXO, E2_VALOR, E2_JUROS, E2_DESCONT, E2_MULTA, E2_PARCELA, E2_EMIS1, E2_VENCTO, E2_FORNECE, E2_LOJA, E2_BCOPAG, E2_FILORIG, E2_ORIGEM FROM " +RetSqlName("SE2") +" SE2 "+ cEol
	cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "'"+ cEol
	cQuery += " AND E2_FATURA = '"+ cNumero + "'" + cEol
	cQuery += " AND E2_FORNECE = '"+ cFornece + "'" + cEol
	cQuery += " AND E2_LOJA = '"+ cLoja + "'" + cEol
	cQuery += " AND D_E_L_E_T_ <> '*' " + cEol

	TCQUERY cQuery NEW ALIAS &cAlias
Return cAlias

/*/Funcao que retorna o numero da parcela./*/
Static Function getParcela(cAux)
	If Val(cAux) == 0
		If !Empty(cAux)
			If IsAlpha(cAux)
				nAux := Asc(cAux)
				cAux := Alltrim(Str(nAux-64))
			Else
				cAux := "1"
			Endif
		Else
			cAux := "1"
		Endif
	Endif
Return cAux

/*/Funcao que retorna os valores da parcela./*/
Static Function getValorTitulo (cTit12,cTit13,cTit14,cTit15)
	local nValor, nJuros, nMulta,nJurMul, nDesc := 0

	nValor := (cAlias)->E2_VALOR
	nDesc  := (cAlias)->E2_DESCONT
	nJuros := (cAlias)->E2_JUROS
	nMulta := (cAlias)->E2_MULTA
	nJurMul:= nJuros + nMulta

	cTit12 := StrTran(StrZero(nValor,13,2),".",",")+";"                    // Valor baixado
	cTit13 := StrTran(StrZero(nJurMul,13,2),".",",")+";"                   // Valor do juros
	cTit14 := StrTran(StrZero(nDesc,13,2),".",",")+";"                     // Valor do desconto
	cTit15 := StrTran(StrZero(nValor+nJurMul-nDesc,13,2),".",",")+";"      // Valor a baixar
Return

/*/Funcao que retorna a especie da nf referente ao titulo./*/
Static Function getEspecie()
    local aArea		:= GetArea()
    local cAux		:= ""
	local cEspecie 	:= ""

//	cAux := Alltrim(Posicione("SF1",1,xFilial("SF1")+(cAlias)->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),"F1_ESPECIE"))
	cAux := Alltrim(Posicione("SF1",1,(cAlias)->(E2_FILORIG+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),"F1_ESPECIE"))
	If cAux == "SPED"
		cEspecie := "NFE"                                                           // Espécie da Nota (NF,NFE,NFS)
	ElseIf Empty(cAux)
		cEspecie := "FAT"                                                           // Espécie da Nota (NF,NFE,NFS)
	Else
		cEspecie := cAux                                                           // Espécie da Nota (NF,NFE,NFS)
	Endif
	cEspecie += ";"

	RestArea(aArea)
Return cEspecie

/*/Funcao que retorna a data de emissao do titulo./*/
Static Function getEmissao()
    local aArea		:= GetArea()
    local dEmissao
	local cEmissao 	:= ""

		//dEmissao := Posicione("SF1",1,xFilial("SF1")+(cAlias)->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),"F1_DTDIGIT")
		dEmissao := Posicione("SF1",1,(cAlias)->(E2_FILORIG+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),"F1_DTDIGIT")
		cEmissao := dtoc(GravaData(dEmissao,.T.,5))
		cEmissao += ";"

	RestArea(aArea)
Return cEmissao

/*/Funcao que retorna a conta./*/
Static Function getConta()
    local aArea		:= GetArea()
	local cBanco 	:= ""
	local cConta	:= ""

	cBanco     	:= (cAlias)->E2_BCOPAG

	If cBanco == "341"                                                                             	// Numero da Conta
		cConta := "101.007-7"
	ElseIf cBanco == "237"
		cConta := "101.165-0"
	ElseIf cBanco == "104"
		cConta := "101.016-6"
	ElseIf cBanco == "001"
		cConta := "101.105-7"
	ElseIf cBanco == "033"
		cConta := "101.314-9"
	ElseIf cBanco == "CX1"
		cConta := "100.005-5"
	Else
		cConta := Space(9)
	Endif
	cConta += ";"

	RestArea(aArea)
Return cConta