#include "rwmake.ch"
#include "topconn.ch"
#define ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} ArqContInv
Geracao de um arquivo texto com dados necessarios para a contabilidade, relativos ao inventario da empresa.
@author Marcos Candido
@since 04/01/2018
/*/
User Function ArqContInv()

Local aSays      := {}
Local aButtons   := {}
Local cCadastro  := OemToansi('Geração de arquivo texto para a Contabilidade')
Local lOkParam   := .F.
Local cPerg      := PADR("ARQCONINV",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
Local cMens      := OemToAnsi('A opção de Parâmetros desta rotina deve ser acessada antes de sua execução!')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Organiza o Grupo de Perguntas e Help ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHelpPor := {}
aAdd(aHelpPor,"Informe a data de fechamento do estoque ")
aAdd(aHelpPor,"a ser considerada na filtragem das ")
aAdd(aHelpPor,"informações que serão enviadas ao escritório ")
aAdd(aHelpPor,"de contabilidade.")
Aadd(aPergs,{"Data","","","mv_ch1","D",8,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe os armazéns que serão considerados.")
aAdd(aHelpPor,"Separe os códigos com um ponto e virgula (;) ")
aAdd(aHelpPor,"a cada informação que deverá conter ")
aAdd(aHelpPor,"obrigatóriamente 2 dígitos.")
aAdd(aHelpPor,"Ou use '**' para considerar todos.")
Aadd(aPergs,{"Armazem(s)","","","mv_ch2","C",20,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe o diretório em que será gerado")
aAdd(aHelpPor,"o arquivo.")
aAdd(aHelpPor,"Por exemplo: C:\CONTAB\")
Aadd(aPergs,{"Diretorio","","","mv_ch3","C",30,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a versão do lay-out")
aAdd(aHelpPor,"do arquivo.")
Aadd(aPergs,{"Versao Lay-out","","","mv_ch4","C",10,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo em que")
aAdd(aHelpPor,"será gravado o inventário.")
aAdd(aHelpPor,"Por exemplo: ESTOQUE_MES_ANO.TXT")
Aadd(aPergs,{"Arquivo Inventario","","","mv_ch5","C",30,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria, se necessario, o grupo de Perguntas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AjustaSx1(cPerg,aPergs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Interface com o usuario             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aSays,OemToAnsi('Este programa visa gerar para o escritório de contabilidade um  '))
aAdd(aSays,OemToAnsi('arquivo texto com informações do saldo em estoque na data indicada'))
aAdd(aSays,OemToAnsi('nos parâmetros. O lay-out foi definido pelo sistema Cuca Fresca. '))
aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| ProcGer()}),o:oWnd:End()),Aviso(OemToAnsi('Atenção!!!'), cMens , {'Ok'})) } } )
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons,,230,430 ) // altura x largura

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

If !Empty(mv_par02) .and. alltrim(mv_par02) <> "**"
	If !(";" $ mv_par02) .and. Len(AllTrim(mv_par02)) > 3
		ApMsgAlert("Separe os armazéns que deseja imprimir (pergunta 02) por um ponto e virgula (;) a cada 2 caracteres.")
		Return(Nil)
	Endif
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
Local nTamLin, cLin, cCpo
Local cFiltro   := "", cBarra := ""
Local aDados := {} , aUF :={}
Local cDir := ""
Local cNomArq1 := Alltrim(mv_par05)
Local nRegs := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipos de Produtos, conforme classificacao para o SPED               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aTipo		:=	{ {"ME","00"},;
{"MP","01"},;
{"MA","01"},;
{"EM","02"},;
{"PP","03"},;
{"PA","04"},;
{"SP","05"},;
{"PI","06"},;
{"MC","07"},;
{"ML","07"},;
{"AI","08"},;
{"AF","08"},;
{"MO","09"},;
{"SV","09"},;
{"OI","10"},;
{"GG","99"}}

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
nHdl := fCreate(cDir+cNomArq1)

If nHdl == -1
	MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq1+" não pode ser executado! Verifique os parãmetros."),OemToAnsi("Atenção!"))
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho do arquivo                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabecArq  := "VERSAO LAYOUT:"+Alltrim(mv_par04)
nTamLinCab := Len(cCabecArq)
cLinCab    := Space(nTamLinCab)								//	Variavel para criacao da linha do registros para gravacao
cLinCab    := Stuff(cLinCab,01,nTamLinCab,cCabecArq)	// Versao do Gabarito de importacao
cLinCab    += ENTER

If fWrite(nHdl,cLinCab,Len(cLinCab)) != Len(cLinCab)
	MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. A rotina será finalizada."),OemToAnsi("Atenção!"))
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inventario    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cQuery += "SELECT B9_COD, B9_DATA, SUM(B9_VINI1) VALOR, SUM(B9_QINI) QTDE, SUM(B9_CM1) CUNIT FROM "+RetSQlName("SB9")+" SB9 "
cQuery += "WHERE "
cQuery += "SB9.B9_FILIAL = '"+xFilial("SB9")+"' AND "
cQuery += "SB9.B9_DATA = '"+dtos(mv_par01)+"' AND "
If mv_par02 <> "**"
	cQuery += "SB9.B9_LOCAL IN "+FormatIn(mv_par02,";")+" AND "
EndIf
cQuery += "SB9.D_E_L_E_T_ <> '*' "
cQuery += "GROUP BY B9_COD,B9_DATA"

/* TESTE   - OK
SELECT B9_COD, B9_DATA, SUM(B9_VINI1) VALOR, SUM(B9_QINI) QTDE FROM SB9010 SB9
WHERE
SB9.B9_FILIAL = '01' AND
SB9.B9_DATA = '20130731' AND
SUBSTRING(SB9.B9_LOCAL,1,1) = '0' AND
SB9.D_E_L_E_T_ <> '*'
GROUP BY B9_COD,B9_DATA
*/

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSB9",.T.,.T.)
aEval(SF1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSB9",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

dbSelectArea("WSB9")
dbGoTop()

Count to nRegs // Numero de registros a processar

If nRegs > 0

	ProcRegua(nRegs)

	dbGoTop()
	While !Eof()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa a regua                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProc("Lendo Registros da Tabela de Saldos em Estoque...")

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+WSB9->B9_COD))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidero Tipo <> de MP    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SB1->B1_TIPO <> 'MP'
			dbSelectArea("WSB9")
			dbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidero Quantidades Menores ou iguais a zero ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If WSB9->QTDE <= 0
			dbSelectArea("WSB9")
			dbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidero Valores Menores que zero ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//If WSB9->VALOR < 0
		//	dbSelectArea("WSB9")
		//	dbSkip()
		//	Loop
		//Endif

		nTamLin := 309
		cLin    := Space(nTamLin)			//	Variavel para criacao da linha do registros para gravacao

		cCpo := PADR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),18)
		cLin := Stuff(cLin,01,18,cCpo)										// CNPJ da Empresa
		cLin := Stuff(cLin,19,01,"I")										// Tipo I=Inventario
		cCpo := StrZero(Month(StoD(WSB9->B9_DATA)),2)
		cLin := Stuff(cLin,20,02,cCpo)										// Mes
		cLin := Stuff(cLin,22,03,"014")										// Cód. Hist. Inventário
		cLin := Stuff(cLin,25,08,StrZero(Val(SB1->B1_POSIPI),8))			// codigo IPI (NCM)
		cLin := Stuff(cLin,33,14,Substr(SB1->B1_COD,1,14))					// Código Produto para Empresa
		cCpo := NoAcento(Alltrim(StrTran(SB1->B1_DESC,Chr(9),"")))
		cLin := Stuff(cLin,47,53,Substr(cCpo,1,53))						// Descrição do Produto
		cLin := Stuff(cLin,100,06,SB1->B1_UM)      						// Unidade

		cCpo := StrZero(NoRound(WSB9->QTDE,4),18,4)
		cLin := Stuff(cLin,106,18,StrTran(cCpo,".",","))					// Quantidade

		/*
		cCpo1 := Round(Round(WSB9->VALOR,4)/Round(WSB9->QTDE,4),4)
		cCpo  := StrZero(cCpo1,18,4)
		cLin  := Stuff(cLin,124,18,StrTran(cCpo,".",","))					// Valor Unitario

		cCpo2 := NoRound(cCpo1 * NoRound(WSB9->QTDE,4),4)
	 	cCpo  := StrZero(cCpo2,18,4)
		cLin  := Stuff(cLin,142,18,StrTran(cCpo,".",","))					// Valor Total
		*/

		cCpo  := StrZero(WSB9->CUNIT,18,4)
		cLin  := Stuff(cLin,124,18,StrTran(cCpo,".",","))					// Valor Unitario

 		cCpo  := StrZero(WSB9->VALOR,18,4)
		cLin  := Stuff(cLin,142,18,StrTran(cCpo,".",","))					// Valor Total

		cCpo := StrZero(0,7,4)
		cLin := Stuff(cLin,160,07,StrTran(cCpo,".",","))					// Alíq. Subs. Tributária
		cCpo := StrZero(0,12,2)
		cLin := Stuff(cLin,167,12,StrTran(cCpo,".",","))					// Base Subs. Tributária
		cLin := Stuff(cLin,179,01,"1")										// Código Posse das Mercadorias
		cCpo := PADR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),18)
		cLin := Stuff(cLin,180,18,cCpo)										// CNPJ Possuidor/Proprietário
		cLin := Stuff(cLin,198,40,SM0->M0_NOMECOM)							// Nome Possuidor/Proprietário
		cLin := Stuff(cLin,238,20,SM0->M0_INSC)							// Inscr.Estad. do Possuidor/Proprietário
		cLin := Stuff(cLin,258,09,SM0->M0_CODMUN)							// Cod. IBGE Municipio do Possuidor/Proprietário
		cCpo := StrZero(SB1->B1_IPI,6,2)
		cLin := Stuff(cLin,267,06,StrTran(cCpo,".",","))					// 	Alíquota IPI do Produto
		cCpo := StrZero(0,6,2)
		cLin := Stuff(cLin,273,06,StrTran(cCpo,".",","))					// 	Alíquota ICMS do Produto
		cLin := Stuff(cLin,279,03,"000")									// 	Código Produto Tabela IVA
		cCpo := StrZero(0,6,2)
		cLin := Stuff(cLin,282,06,StrTran(cCpo,".",","))					// 	Alíquota IVA-ST
		cCpo := StrZero(0,18,2)
		cLin := Stuff(cLin,288,18,StrTran(cCpo,".",","))					// 	Preco final ao consumidor (em subst. ao IVA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busco o tipo do item para montar o campo do registro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTipo := ASCAN(aTipo,{|x| x[1]==SB1->B1_TIPO})
		If nTipo > 0
			cCpo := aTipo[nTipo][2]
		Else
			cCpo := "99"
		EndIf
		cLin := Stuff(cLin,306,02,cCpo)				   						// 	Tipo de Produto
		cLin := Stuff(cLin,308,01,"0")				   						// 	Ident. se prod. é Medicamento - (0) Nao (1) Sim
		cLin := Stuff(cLin,309,01,"2")				   						// 	Tipo de Registro - Informar (1) para "Saldo Inicial do Produto" ou (2) para "Produto"
		cLin += ENTER

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
				//fClose(nHdl)
				Exit
			Endif
		Endif

		dbSelectArea("WSB9")
		dbSkip()

	Enddo

Else

	IW_MsgBox(OemToansi("Não existe fechamento de estoque registrado para a data informada."),OemToAnsi("Atenção!"), "STOP")

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O arquivo texto deve ser fechado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fClose(nHdl)

dbCloseArea()
dbSelectArea("SB9")
RetIndex("SB9")

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ NoAcento ºAutor  ³Microsiga           º Data ³  30/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao emprestada do rdmake NFESEFAZ.PRW                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ALAC                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NoAcento(cString)

Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString
	cString := strTran( cString, cMaior, "" )
EndIf
If cMenor$ cString
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, ENTER, " " )

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX

Return cString
