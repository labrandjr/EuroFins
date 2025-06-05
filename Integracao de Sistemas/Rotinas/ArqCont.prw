#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} ArqCont
Gera arquivo texto com dados necessarios para a contabilidade
@author Marcos Candido
@since 04/01/2018
/*/
User Function ArqCont()
Local aSays      := {}
Local aButtons   := {}
Local cCadastro  := OemToansi('Geração de arquivos texto para a Contabilidade')
Local lOkParam   := .F.
Local cPerg      := PADR("ARQCON",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
Local cMens      := OemToAnsi('A opção de Parâmetros desta rotina deve ser acessada antes de sua execução!')

Local nRetPis := SuperGetMv( "MV_ZZRTPIS")
Local nRetCof := SuperGetMv( "MV_ZZRTCOF")
Local nRetCsl := SuperGetMv( "MV_ZZRTCSL")

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
aAdd(aHelpPor,"Informe a versão do lay-out")
aAdd(aHelpPor,"do arquivo.")
Aadd(aPergs,{"Versao Lay-out","","","mv_ch4","C",10,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo em que")
aAdd(aHelpPor,"serão gravadas as notas de entrada.")
aAdd(aHelpPor,"Por exemplo: EUROFINS-ENT.TXT")
Aadd(aPergs,{"Arquivo p/ Notas Entrada","","","mv_ch5","C",30,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo em que")
aAdd(aHelpPor,"serão gravadas as notas de saída.")
aAdd(aHelpPor,"Por exemplo: EUROFINS-SAI.TXT")
Aadd(aPergs,{"Arquivo p/ Notas Saida","","","mv_ch6","C",30,0,1,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo em que")
aAdd(aHelpPor,"serão gravadas as notas de serviço.")
aAdd(aHelpPor,"Por exemplo: EUROFINS-SER.TXT")
Aadd(aPergs,{"Arquivo p/ Notas Servico","","","mv_ch7","C",30,0,1,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo em que")
aAdd(aHelpPor,"serão gravadas as notas de saída ")
aAdd(aHelpPor,"com as numerações canceladas")
aAdd(aHelpPor," ou inutilizadas.")
aAdd(aHelpPor,"Por exemplo: EUROFINS-SAI-CANC.TXT")
Aadd(aPergs,{"Arq. p/ Notas Canceladas de Saida","","","mv_ch8","C",30,0,1,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Dê um nome para o arquivo em que")
aAdd(aHelpPor,"serão gravadas as notas de serviço ")
aAdd(aHelpPor,"com as numerações canceladas.")
aAdd(aHelpPor,"Por exemplo: EUROFINS-SER-CANC.TXT")
Aadd(aPergs,{"Arq. p/ Notas Canceladas de Servico","","","mv_ch9","C",30,0,1,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Se for preciso processar somente")
aAdd(aHelpPor,"um documento, informe o numero dele")
aAdd(aHelpPor,"neste parâmetro.")
Aadd(aPergs,{"Numero da Nota Fiscal","","","mv_cha","C",09,0,1,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria, se necessario, o grupo de Perguntas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AjustaSx1(cPerg,aPergs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Interface com o usuario             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aSays,OemToAnsi('Este programa visa gerar para o escritório de contabilidade, cinco'))
aAdd(aSays,OemToAnsi('arquivos texto com informações das notas de entrada, saída, serviços'))
aAdd(aSays,OemToAnsi('e canceladas, para o período indicado nos parâmetros. O lay-out foi '))
aAdd(aSays,OemToAnsi('definido pelo sistema Cuca Fresca. '))
aAdd(aSays,OemToAnsi(' '))
aAdd(aSays,OemToAnsi('Os parâmetros de data referem-se a Data de Emissão para as notas de'))
aAdd(aSays,OemToAnsi('Saída/Serviço e Data de Digitação para as notas de Entrada.'))
aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| ProcGer()}),o:oWnd:End()),Aviso(OemToAnsi('Atenção!!!'), cMens , {'Ok'})) } } )
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons,,270,430 ) // altura x largura

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
Local cNomArq2 := Alltrim(mv_par06)
Local cNomArq3 := Alltrim(mv_par07)
Local cNomArq4 := Alltrim(mv_par08)
Local cNomArq5 := Alltrim(mv_par09)
Local cCSTPC   := ""
Local cVersLO  := Alltrim(mv_par04)

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


Private _cEOL   := "CHR(13)+CHR(10)"
_cEOL := Trim(_cEOL)
_cEOL := &_cEOL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho para todos os arquivos          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabecArq  := "VERSAO LAYOUT NOTAS FISCAIS:"+iif(Empty(cVersLO),"001",cVersLO)
nTamLinCab := Len(cCabecArq)
cLinCab    := Space(nTamLinCab)								//	Variavel para criacao da linha do registros para gravacao
cLinCab    := Stuff(cLinCab,01,nTamLinCab,cCabecArq)	// Versao do Gabarito de importacao
cLinCab    += _cEOL

If !Empty(cNomArq1)

	nHdl := fCreate(cDir+cNomArq1)

	If nHdl == -1
		MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq1+" não pode ser executado! Verifique os parãmetros."),OemToAnsi("Atenção!"))
		Return
	Endif

	If fWrite(nHdl,cLinCab,Len(cLinCab)) != Len(cLinCab)
		MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
		Return
	Endif

	dbSelectArea("SX5")
	IF !dbSeek(xFilial("SX5")+"Z3") // ESPECIES DE DOCUMENTOS FISCAIS - USADOS NA IMPORTACAO
		Alert("Tabela Z3 não localizada ("+xFilial("SX5")+"Z3). Cadastre na tabela SX5")
		Return
	endif
	While !Eof() .and. X5_TABELA == "Z3"
		aadd(aDados , {Alltrim(X5_CHAVE) , Alltrim(X5_DESCRI)})
		dbSkip()
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Notas de Entrada  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	cChaveSD1  := 'D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_CC+D1_CONTA+D1_CF'
	cNomArqSD1 := CriaTrab(Nil,.F.)
	IndRegua("SD1",cNomArqSD1,cChaveSD1,,,OemToAnsi("Selecionando Registros..."))

	dbSelectArea("SD1")
	#IfNDEF TOP
		dbSetIndex(cNomArqSD1+OrdBagExt())
	#Endif

	cQuery := ""
	cQuery += "SELECT * FROM "+RetSQlName("SF1")+" SF1 "
	cQuery += "WHERE "
	cQuery += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND "
	cQuery += "SF1.F1_DTDIGIT >= '"+dtos(mv_par01)+"' AND SF1.F1_DTDIGIT <= '"+dtos(mv_par02)+"' AND "
	If !Empty(mv_par10)
		cQuery += "SF1.F1_DOC = '"+mv_par10+"' AND "
	Endif
	cQuery += "SF1.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY F1_FILIAL,F1_DTDIGIT,F1_DOC,F1_SERIE"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSF1",.T.,.T.)
	aEval(SF1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSF1",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSF1")
	Count to nTotReg
	dbGoTop()

	ProcRegua(nTotReg) // Numero de registros a processar

	While !Eof()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa a regua                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProc("Lendo Registros das Notas de Entrada...")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se a nota não constar em Livros Fiscais, despreza o registro        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF3")
		dbSetOrder(4)
		If !dbSeek(xFilial("SF3")+WSF1->(F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE))
			dbSelectArea("WSF1")
			dbSkip()
			Loop
		Endif

		If ALLTRIM(WSF1->F1_ESPECIE) == 'CA' .or. ALLTRIM(WSF1->F1_ESPECIE) == 'CTRC' .or. ALLTRIM(WSF1->F1_ESPECIE) == 'CTAC' .or.;
			ALLTRIM(WSF1->F1_ESPECIE) == 'CTFC' .or. ALLTRIM(WSF1->F1_ESPECIE) == 'CTMC' //.or. ALLTRIM(F1_ESPECIE) == 'NFST' --> RETIRADO ESSE FILTRO (NFST) A PEDIDO DA FERNANDA EM 04/02/11
			dbSkip()
			Loop
		Endif

		If WSF1->F1_TIPO $ "B#D"
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+WSF1->(F1_FORNECE+F1_LOJA)))
			cCNPJ := SA1->A1_CGC
			cNome := SA1->A1_NOME
			cIE   := Iif(Empty(SA1->A1_INSCR),"ISENTO",SA1->A1_INSCR)
			cUF   := aUF[aScan(aUF,{|x| x[1] == SA1->A1_EST})][02]
			cCodM := cUF+Iif(Empty(SA1->A1_COD_MUN),"3520509",SA1->A1_COD_MUN)
			cTipoCF := SA1->A1_TIPO
			cOptSimples := IIf(Empty(SA1->A1_SIMPNAC),"0",IIF(SA1->A1_SIMPNAC="1","1","0"))
			cEnd    := Substr(SA1->A1_END,1,at(",",SA1->A1_END)-1)
			cNum    := StrZero(Val(Substr(SA1->A1_END,at(",",SA1->A1_END)+1)),5)
			cCEP    := Transform(SA1->A1_CEP,"@R 99999-999")
			cBairro := SA1->A1_BAIRRO
			cIMun   := SA1->A1_INSCRM
		Else
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+WSF1->(F1_FORNECE+F1_LOJA)))
			cCNPJ := SA2->A2_CGC
			cNome := SA2->A2_NOME
			cIE   := Iif(Empty(SA2->A2_INSCR),"ISENTO",SA2->A2_INSCR)
			cUF   := aUF[aScan(aUF,{|x| x[1] == SA2->A2_EST})][02]
			cCodM := cUF+Iif(Empty(SA2->A2_COD_MUN),"3520509",SA2->A2_COD_MUN)
			cTipoCF := SA2->A2_TIPO
			cOptSimples := IIf(Empty(SA2->A2_SIMPNAC),"0",IIF(SA2->A2_SIMPNAC="1","1","0"))
			cEnd    := Substr(SA2->A2_END,1,at(",",SA2->A2_END)-1)
			cNum    := StrZero(Val(Substr(SA2->A2_END,at(",",SA2->A2_END)+1)),5)
			cCEP    := Transform(SA2->A2_CEP,"@R 99999-999")
			cBairro := SA2->A2_BAIRRO
			cIMun   := SA2->A2_INSCRM
		Endif

		aDupli  := {}
		lISSRet := .F.
		dbSelectArea("SE2")
		dbSetOrder(6)
		If dbSeek(xFilial("SE2")+WSF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC),.T.)
			While !Eof() .and. E2_FILIAL=xFilial("SE2") .and.;
				E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == WSF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC)
				If Alltrim(SE2->E2_TIPO) == "NF"
					aadd(aDupli , {E2_NUM , E2_VENCTO , E2_VALOR})
					If SE2->E2_ISS > 0
						lISSRet := .T.
					Endif
				Endif
				dbSkip()
			Enddo
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Laco existente para contar a quantidade de itens da nota, CFOPs, Centro de Custo e Conta Contabil   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		dbSeek(xFilial("SD1")+WSF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
		/*
		aCFO    := {}
		aCCusto := {}
		aConta  := {}
		*/
		aCFCCCo := {}
		cObsAtivo := ""
		nItem     := 0
		cCSTPC    := ""

		While !Eof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA ==;
			WSF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem dos CFOPs  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLoc := aScan(aCFO , {|x| x[1] == D1_CF})
			If nLoc == 0
				aadd(aCFO , {D1_CF , 1})
			Else
				aCFO[nLoc][2] += 1
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem dos Centros de Custo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLoc := aScan(aCCusto , {|x| x[1] == D1_CC})
			If nLoc == 0
				aadd(aCCusto , {D1_CC , 1})
			Else
				aCCusto[nLoc][2] += 1
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem das Contas Contabeis ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLoc := aScan(aConta , {|x| x[1] == D1_CONTA})
			If nLoc == 0
				aadd(aConta , {D1_CONTA , 1})
			Else
				aConta[nLoc][2] += 1
			Endif
			*/
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem de todas as entidades ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLoc := aScan(aCFCCCo , {|x| x[1] == D1_CC+D1_CONTA+D1_CF})
			If nLoc == 0
				aadd(aCFCCCo , {D1_CC+D1_CONTA+D1_CF , 1})
			Else
				aCFCCCo[nLoc][2] += 1
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem dos Itens da Nota    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nItem++

			If Substr(D1_CF,2,3) == "551"
				cObsAtivo += StrTran(Alltrim(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")),chr(9),"")+iif(!Empty(cObsAtivo),"; ","")
			Endif

			If Empty(cCSTPC)
				cCSTPC    := Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_CSTPIS")
				cNatFrete := Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_INDNTFR")
			Endif

			dbSkip()

		Enddo

		/*
		aAux := {{Len(aCCusto),'cc'},{Len(aConta),'conta'},{Len(aCFO),'cfo'}}
		aSort(aAux,,, { |x,y| x[1] < y[1] })

		nDesdobr  := aAux[Len(aAux)][1]
		cQualDesd := aAux[Len(aAux)][2]

		If cQualDesd == 'cc' .and. Empty(aCCusto[1][1])
			aAux := {{Len(aConta),'conta'},{Len(aCCusto),'cc'},{Len(aCFO),'cfo'}}
			aSort(aAux,,, { |x,y| x[1] < y[1] })
			nDesdobr  := aAux[Len(aAux)][1]
			cQualDesd := aAux[Len(aAux)][2]
		Endif

		If cQualDesd == 'conta' .and. Empty(aConta[1][1])
			aAux := {{Len(aCFO),'cfo'},{Len(aCCusto),'cc'},{Len(aConta),'conta'}}
			aSort(aAux,,, { |x,y| x[1] < y[1] })
			nDesdobr  := aAux[Len(aAux)][1]
			cQualDesd := aAux[Len(aAux)][2]
		Endif
		*/

		aSort(aCFCCCo,,, { |x,y| x[1] < y[1] })
		nDesdobr  := Len(aCFCCCo)

		If nDesdobr <= 1
			cDesdobr := "00"
		Else
			cDesdobr := StrZero(nDesdobr-1,2)
		Endif

		lFirst   := .T.
		nItemSD1 := 0
		cCFOAnt  := ""
		cCCAnt   := ""
		cContAnt := ""
		cChvAnt  := ""

		dbSelectArea("SD1")
		dbSeek(xFilial("SD1")+WSF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
		While !Eof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA ==;
			WSF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
			SB5->(dbSetOrder(1))
			SB5->(dbSeek(xFilial("SB5")+SD1->D1_COD))
			CT1->(dbSetOrder(1))
			CT1->(dbSeek(xFilial("CT1")+SD1->D1_CONTA))

			If lFirst

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Entrada - Movimento Principal    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//nTamLin := 712
				//nTamLin := 822
				nTamLin := 893
				cLin    := Space(nTamLin)			//	Variavel para criacao da linha do registros para gravacao

				cCpo := PADR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),18)
				cLin := Stuff(cLin,01,18,cCpo)					// CNPJ da Empresa
				cLin := Stuff(cLin,19,01,"E")						// Tipo E=Entrada
				cCpo := GravaData(WSF1->F1_DTDIGIT,.T.,5)
				cLin := Stuff(cLin,20,10,Dtoc(cCpo))			// Data da Entrada

				// AO encontrar a ESPECIE SPED e tiver a chave eletronica da nota, usar a especie NFE
				If Alltrim(WSF1->F1_ESPECIE) == "SPED" .and. !Empty(WSF1->F1_CHVNFE)
					cCpo := "NFE  "
				Else
					nLoc := aScan(aDados , {|x| x[1] == Alltrim(WSF1->F1_ESPECIE)})
					If nLoc == 0
						cCpo := "NF   "
					Else
						cCpo := PADR(aDados[nLoc][2],5)
					Endif
				Endif
				lCTE := .F.
				If Alltrim(cCpo) $ 'CTE/CTRC'
					lCTE     := .T.
					If nItem <= 1
						cDesdobr := "00"
					Else
						cDesdobr := StrZero(nItem-1,2)
					Endif
				Endif

				cLin := Stuff(cLin,30,05,cCpo)             			// Espécie
				cAuxEsp := Padr(cCpo,3)
				//cLin := Stuff(cLin,35,03,Space(3))				// Série
				If Alltrim(cCpo) == "NFS"
					cLin := Stuff(cLin,35,03,"E  ")					// Série
				Else
					cLin := Stuff(cLin,35,03,WSF1->F1_SERIE)		// Série
				Endif
				cLin := Stuff(cLin,38,02,"  ")					// Sub Serie da nota
				cLin := Stuff(cLin,40,06,StrZero(0,6))			// Número do Documento
				cCpo := GravaData(WSF1->F1_EMISSAO,.T.,5)
				cLin := Stuff(cLin,46,10,DtoC(cCpo))			// Data do Documento
				If WSF1->F1_EST == "EX"
					cCpo := "P-999.999.999-99  "
				Else
					If Len(Alltrim(cCNPJ)) == 14						// CNPJ do Fornecedor
						cCpo := Transform(cCNPJ,"@R 99.999.999/9999-99")
					Elseif Len(Alltrim(cCNPJ)) == 11					// CPF do Fornecedor
						cCpo := Transform(cCNPJ,"@R 999.999.999-99")
					Else
						cCpo := Space(18)
					Endif
				Endif
				cLin := Stuff(cLin,56,18,cCpo)
				cCpo := Padr(cNome,40)
				cLin := Stuff(cLin,74,40,cCpo)             	// Nome do Fornecedor
				cLin := Stuff(cLin,114,20,cIE)					// Inscr. Est. do Fornecedor
				If WSF1->F1_EST == "EX"
					cCpo := "99.999.99"
				Else
					If Empty(cCodM)
						cCpo := Space(9)
					Else
						cCpo := Transform(cCodM,"@R 99.999.99")
					Endif
				Endif
				cLin := Stuff(cLin,134,09,cCpo)					// Cód. IBGE (Cidade Fornec.)
				cCpo := StrZero(WSF1->F1_VALBRUT,12,2)
				cLin := Stuff(cLin,143,12,StrTran(cCpo,".",","))	// Valor Total da Nota Fiscal
				cCpo := Space(9)  //"999.999-9"
				cLin := Stuff(cLin,155,09,cCpo)					// Numero da conta no banco (pgto em cheque)
				cCpo := Space(10) //"00/00/0000"
				cLin := Stuff(cLin,164,10,cCpo)					// Data do cheque
				cCpo := Space(6)  //"999999"
				cLin := Stuff(cLin,174,06,cCpo)					// numero do cheque
				//If SF1->F1_COND == "001"
				//	cCpo := "0"				// 0=Nota a vista
				//Else
				cCpo := "1"				// 1=Nota a Prazo
				//Endif
				cLin := Stuff(cLin,180,01,cCpo)				// Forma de pagto
				cCpo := PADR(WSF1->F1_NFORIG,12)
				cLin := Stuff(cLin,181,12,cCpo)		        // Num. Nota de Devolução
				If !Empty(WSF1->F1_NFORIG)
					cCpo := PADR("NF   ",05)
				Else
					cCpo := Space(5)
				Endif
				cLin := Stuff(cLin,193,05,cCpo)		        // Espécie da Nota Devolução
				If !Empty(WSF1->F1_SERORIG)
					cCpo := PADR(WSF1->F1_SERORI,03)
				Else
					cCpo := Space(3)
				Endif
				cLin := Stuff(cLin,198,03,cCpo)		        	// Série da Nota Devolução
				cLin := Stuff(cLin,201,02,"  ")					// Sub Serie da nota de devolucao
				//cLin := Stuff(cLin,203,02,cCFO)					// Desdobramento
				cLin := Stuff(cLin,203,02,cDesdobr)					// Desdobramento
				cLin := Stuff(cLin,205,01,"0")					// Local da prestacao de servico - Somente para a GISS das cidades de Guarulhos e São Caetano do Sul
				cLin := Stuff(cLin,206,40,cEnd) 	 		// Endereço do Fornecedor - Obrigatório p/ GISS
				cLin := Stuff(cLin,246,05,cNum)  		// Número do Endereço do Fornecedor - Obrigatório p/ GISS
				cLin := Stuff(cLin,251,09,cCEP)  		// CEP do Endereço do Fornecedor - Obrigatório p/ GISS
				cLin := Stuff(cLin,260,30,cBairro)  		// Bairro do Endereço do Fornecedor - Obrigatório p/ GISS
				cLin := Stuff(cLin,290,02,Space(02))  		// Sigla do País da Cidade do Fornecedor - Obrigatório qdo. exterior
				cLin := Stuff(cLin,292,11,cIMun) 			// Inscrição Municipal do Fornecedor - Obrigatório p/ GISS
				cCpo := StrZero(WSF1->F1_FRETE,18,2)
				cLin := Stuff(cLin,303,18,StrTran(cCpo,".",","))	// Valor do Frete
				cCpo := StrZero(WSF1->F1_SEGURO,18,2)
				cLin := Stuff(cLin,321,18,StrTran(cCpo,".",","))	// Valor do Seguro
				cCpo := StrZero(WSF1->F1_DESCONT,18,2)
				cLin := Stuff(cLin,339,18,StrTran(cCpo,".",","))	// Valor do Desconto
				cCpo := StrZero(0,18)
				cLin := Stuff(cLin,357,18,cCpo)	 						// CNPJ do Local de saida
				cLin := Stuff(cLin,375,40,Space(40))		      	// Nome do CNPJ Local de Saída
				cLin := Stuff(cLin,415,20,Space(20))              	// Inscr. Estad. CNPJ Local Saída
				cCpo := Space(9)
				cLin := Stuff(cLin,435,09,cCpo)	               	// Cód.Mun.IBGE CNPJ Local Saída
				cCpo := StrZero(0,18)
				cLin := Stuff(cLin,444,18,cCpo)							// CNPJ do Local Entrada
				cLin := Stuff(cLin,462,40,Space(40))					// Nome do CNPJ Local de Entrada
				cLin := Stuff(cLin,502,20,Space(20))               // Inscr. Estad. CNPJ Local Entrada
				cLin := Stuff(cLin,522,09,Space(09))					// Cód.Mun.IBGE CNPJ Local Entrada
				cLin := Stuff(cLin,531,18,cCpo)							// CNPJ do Transportador
				cLin := Stuff(cLin,549,40,Space(40))					// Nome do CNPJ do Transportador
				cLin := Stuff(cLin,589,20,Space(20))               // Inscr. Estad. do Transportador
				cLin := Stuff(cLin,609,09,Space(09))					// Cód.Mun.IBGE do Transportador
				cLin := Stuff(cLin,618,10,"CAIXA     ")				// Especie de Volumes
				cLin := Stuff(cLin,628,01,"0")							// Modalidade de Transporte
				cLin := Stuff(cLin,629,07,Space(7))				  		// Placa Veiculo 1
				cLin := Stuff(cLin,636,02,Space(2))						// UF Placa Veiculo 1
				cLin := Stuff(cLin,638,07,Space(7))						// Placa Veiculo 2
				cLin := Stuff(cLin,645,02,Space(2))						// UF Placa Veiculo 2
				cLin := Stuff(cLin,647,07,Space(7))						// Placa Veiculo 3
				cLin := Stuff(cLin,654,02,Space(2))						// UF Placa Veiculo 3
				cCpo := StrZero(WSF1->F1_PESOL,18,3)
				cLin := Stuff(cLin,656,18,StrTran(cCpo,".",","))	// Peso Bruto
				cCpo := StrZero(WSF1->F1_PESOL,18,3)
				cLin := Stuff(cLin,674,18,StrTran(cCpo,".",","))	// Peso Liquido
				If WSF1->F1_FORMUL == "S"
					cCpo := "P"
				Else
					cCpo := "T"
				Endif
				cLin := Stuff(cLin,692,01,cCpo)							// Formulario --> "P" = Nota Própria e "T" = Nota de Terceiros
				cLin := Stuff(cLin,693,20,Space(20))					// Insc.Est.Secundária Fornecedor (so para Amazonas)
				cLin := Stuff(cLin,713,09,Space(09))					// Município de Origem do Frete
				cLin := Stuff(cLin,722,10,StrZero(Val(Right(WSF1->F1_CHVNFE,10)),10))				// Chave NFE-Nota Fisc.Eletrônica
				If Len(aDupli) > 0
					cLin := Stuff(cLin,732,01,Strzero(0,1))			// Indicador do Título de Crédito
				Else
					cLin := Stuff(cLin,732,01,Space(1))				// Indicador do Título de Crédito
				Endif
				cLin := Stuff(cLin,733,20,Space(20))					// Descrição do Título de Crédito
				If Len(aDupli) > 0
					cLin := Stuff(cLin,753,12,Padr(aDupli[1][1],12))	// Número do Título de Crédito
				Else
					cLin := Stuff(cLin,753,12,Space(12))				// Número do Título de Crédito
				Endif
				cLin := Stuff(cLin,765,03,StrZero(0,3))				// Situação Trib. ICMS Transporte
				cLin := Stuff(cLin,768,03,Strzero(Len(aDupli),03))		// Quantidade de Parcelas
				cLin := Stuff(cLin,771,02,Strzero(0,02))				// Dia do Vencimento da Parcela
				cLin := Stuff(cLin,773,07,Space(07))					// Período Inicial Parcelamento
				cLin := Stuff(cLin,780,01,Strzero(0,1))				// Dia vencto. p/ transf.
				cLin := Stuff(cLin,781,02,Strzero(0,2))				// Intervalo entre cada parcela
				cLin := Stuff(cLin,783,10,DtoC(CtoD(Space(8))))		// Dia Inicial do Parcelamento
				cLin := Stuff(cLin,793,02,Space(02))					// Centro de Custo (Conta Banco)
				cLin := Stuff(cLin,795,09,Strzero(Val(WSF1->F1_DOC),9))	// Número do Documento
				cLin := Stuff(cLin,804,18,Strzero(Val(WSF1->F1_NFORIG),9))// Nº Nota de Devolução
				cLin := Stuff(cLin,822,01,cOptSimples)					// Optante do Simples Nacional
				cLin := Stuff(cLin,823,02,cCSTPC)						// Situacao Tributaria do PIS
				If WSF1->F1_BASIMP5 > 0
					cAliqPis  := StrZero(GETMV("MV_TXPIS"),7,4)
					cAliqCof  := StrZero(GETMV("MV_TXCOFIN"),7,4)
				Else
					cAliqPis  := StrZero(0,7,4)
					cAliqCof  := StrZero(0,7,4)
				Endif
				cCpo := StrZero(WSF1->F1_BASIMP6,13,2)
				cLin := Stuff(cLin,825,13,StrTran(cCpo,".",","))		// Base de Calculo do PIS
				cLin := Stuff(cLin,838,07,StrTran(cAliqPis,".",","))	// Aliquota PIS
				cCpo := StrZero(WSF1->F1_VALIMP6,13,2)
				cLin := Stuff(cLin,845,13,StrTran(cCpo,".",","))		// Valor do PIS
				cLin := Stuff(cLin,858,02,cCSTPC)						// Situacao Tributaria do COFINS
				cCpo := StrZero(WSF1->F1_BASIMP5,13,2)
				cLin := Stuff(cLin,860,13,StrTran(cCpo,".",","))		// Base de Calculo do COFINS
				cLin := Stuff(cLin,873,07,StrTran(cAliqCof,".",","))	// Aliquota COFINS
				cCpo := StrZero(WSF1->F1_VALIMP5,13,2)
				cLin := Stuff(cLin,880,13,StrTran(cCpo,".",","))		// Valor do COFINS
				cLin := Stuff(cLin,893,01,cNatFrete)					// Natureza de Frete
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
						fClose(nHdl)
						Return
					Endif
				Endif

			Endif

			If lCTE

				cQuery := ""
				cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
				cQuery += "WHERE "
				cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
				cQuery += "SFT.FT_TIPOMOV = 'E' AND "
				cQuery += "SFT.FT_SERIE = '"  +SD1->D1_SERIE+"' AND "
				cQuery += "SFT.FT_NFISCAL = '"+SD1->D1_DOC+"' AND "
				cQuery += "SFT.FT_CLIEFOR = '"+SD1->D1_FORNECE+"' AND "
				cQuery += "SFT.FT_LOJA = '"   +SD1->D1_LOJA+"' AND "
				cQuery += "SFT.FT_ITEM = '"   +SD1->D1_ITEM+"' AND "
				cQuery += "SFT.D_E_L_E_T_ <> '*'"

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
				aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

				cCodISS   := ""
				nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
				nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
				nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
				nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
				nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

				dbSelectArea("WSFT")
				dbGoTop()
				While !Eof()
					nValCont  += WSFT->FT_VALCONT
					nBaseICMS += WSFT->FT_BASEICM
					nAliqICMS := WSFT->FT_ALIQICM
					nValICMS  += WSFT->FT_VALICM
					nIsenICMS += WSFT->FT_ISENICM
					nOutrICMS += WSFT->FT_OUTRICM
					nBaseRet  += WSFT->FT_BASERET
					nICMSRet  += WSFT->FT_ICMSRET
					nBaseIPI  += WSFT->FT_BASEIPI
					nAliqIPI  := WSFT->FT_ALIQIPI
					nValIPI   += WSFT->FT_VALIPI
					nIsenIPI  += WSFT->FT_ISENIPI
					nDespesa  += WSFT->FT_DESPESA
					cCodISS   := WSFT->FT_CODISS
					nValINSS  += WSFT->FT_VALINS
					nValIRRF  += WSFT->FT_VALIRR
					nValPIS   += WSFT->FT_VALPIS
					nValCOF   += WSFT->FT_VALCOF
					nValCSL   += WSFT->FT_VALCSL
					nValPISR  += WSFT->FT_VRETPIS
					nValCOFR  += WSFT->FT_VRETCOF
					nValCSLR  += WSFT->FT_VRETCSL
					If WSFT->FT_TIPO == 'S'
						nBaseISS  += WSFT->FT_BASEICM
						nValISS   += WSFT->FT_VALICM
						nAliqISS  := WSFT->FT_ALIQICM
					Endif
					dbSkip()
				Enddo

				dbCloseArea()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Entrada - Complemento do Movimento   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//nTamLin := 729
				//nTamLin := 785
				//nTamLin := 797
				nTamLin := 800
				cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

				cLin := Stuff(cLin,03,05,StrZero(0,5))							// Num. Documento Mov. Princ.
				cLin := Stuff(cLin,08,02,Right(Alltrim(SD1->D1_CC),2))			// Centro de custo
				cLin := Stuff(cLin,10,04,CT1->CT1_ZZLOG)						// Codigo Contabil
				cLin := Stuff(cLin,14,06,Transform(SD1->D1_CF,"@R 9.999X"))	// Codigo Fiscal
				cCpo := StrZero(nValCont,12,2)
				cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))				// Valor Contabil
				cCpo := StrZero(nBaseICMS,12,2)
				cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ICMS
				cCpo := StrZero(nAliqICMS,07,4)
				cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
				cCpo := StrZero(nValICMS,12,2)
				cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ICMS
				cCpo := StrZero(nIsenICMS,12,2)
				cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
				If !(cAuxEsp $ "NFE/NF ") .or. nOutrICMS > 0
					If nOutrICMS > 0
						cCpo := StrZero(nOutrICMS,12,2)
					Else
						cCpo := StrZero(nBaseICMS,12,2)
					Endif
				Else
					If nOutrICMS > 0
						cCpo := StrZero(nOutrICMS,12,2)
					Else
						cCpo := StrZero(nValCont,12,2)
					Endif
				Endif
				cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
				cCpo := StrZero(0,7,4)
				cLin := Stuff(cLin,99,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,106,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
				cCpo := StrZero(nBaseRet,12,2)
				cLin := Stuff(cLin,118,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
				cCpo := StrZero(nAliqICMS,7,4)
				cLin := Stuff(cLin,130,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
				cCpo := StrZero(nICMSRet,12,2)
				cLin := Stuff(cLin,137,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
				cCpo := StrZero(nBaseIPI,12,2)
				cLin := Stuff(cLin,149,12,StrTran(cCpo,".",","))			// Valor Base IPI
				cCpo := StrZero(nAliqIPI,7,4)
				cLin := Stuff(cLin,161,07,StrTran(cCpo,".",","))			// Alíquota do IPI
				cCpo := StrZero(nValIPI,12,2)
				cLin := Stuff(cLin,168,12,StrTran(cCpo,".",","))			// Valor Base IPI
				cCpo := StrZero(nIsenIPI,12,2)
				cLin := Stuff(cLin,180,12,StrTran(cCpo,".",","))			// Valor Isento IPI
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,192,12,StrTran(cCpo,".",","))			// Valor Outras IPI
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,204,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
				cLin := Stuff(cLin,216,12,StrTran(cCpo,".",","))			// PVV / Cigarro
				cLin := Stuff(cLin,228,12,StrTran(cCpo,".",","))			// Saída Trib. 12 %
				cLin := Stuff(cLin,240,12,StrTran(cCpo,".",","))			// Saída Trib. 25 %
				cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base Calc. Red.
				cCpo := StrZero(0,7,4)
				cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Alíquota efetiva %
				If WSF1->F1_EST == "EX"
					cCpo := "6"
				Else
					cCpo := " "
				Endif
				cLin := Stuff(cLin,271,01,cCpo)								// Código Antecipação Subs.Trib.
				cCpo := StrZero(nDespesa,14,2)
				cLin := Stuff(cLin,272,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
				cLin := Stuff(cLin,286,10,Space(10))						// Num.Declaração de Importação
				cLin := Stuff(cLin,296,03,StrZero(0,3))				// Quantidade Itens Desdobramento
				cLin := Stuff(cLin,299,09,StrZero(Val(SD1->D1_DOC),9))		// Controle Interno
				cLin := Stuff(cLin,308,25,Space(25))						// Controle Interno
				cCpo := StrZero(0,16)
				cLin := Stuff(cLin,333,16,cCpo)								// Controle Interno
				cLin := Stuff(cLin,349,01,"0")								// Modalidade do Frete
				cLin := Stuff(cLin,350,03,"000") 							// Cód. Observação
				cLin := Stuff(cLin,353,250,Space(250)) 					// Complemento Observação
				cLin := Stuff(cLin,603,01,"0")			 					// Subst. Trib. Ref. Petróleo
				cLin := Stuff(cLin,604,01,"0")			 					// Controle Interno
				cLin := Stuff(cLin,605,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
				If Alltrim(cCodISS)=='19452'
					cCodISS := '1709 '
				Endif
				cLin := Stuff(cLin,606,10,cCodISS+"  ") 					// Código do Serviço
				cCpo1 := StrZero(0,12,2)
				cCpo2 := StrZero(0,07,4)
				cLin := Stuff(cLin,616,12,StrTran(cCpo1,".",",")) 			// Valor do Serviço
				cLin := Stuff(cLin,628,07,StrTran(cCpo2,".",","))			// Alíquota do ISS
				cLin := Stuff(cLin,635,12,StrTran(cCpo1,".",","))			// Valor do ISS Retido
				cCpo := StrZero(nValINSS,12,2)
				cLin := Stuff(cLin,647,12,StrTran(cCpo,".",","))			// Valor do INSS Retido
				cCpo := StrZero(nValIRRF,12,2)
				cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Valor do IRRF Retido
				cCpo := StrZero(nValPISR,12,2)
				cLin := Stuff(cLin,671,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
				cCpo := StrZero(nValCOFR,12,2)
				cLin := Stuff(cLin,683,12,StrTran(cCpo,".",","))			// Valor do COFINS Retido
				cCpo := StrZero(nValCSLR,12,2)
				cLin := Stuff(cLin,695,12,StrTran(cCpo,".",","))			// Valor do CSLL Retido
				cLin := Stuff(cLin,707,02,WSF1->F1_EST)						// UF de Início da Operação
				cLin := Stuff(cLin,709,03,Space(03))						// CFPS
				cCpo := "00"
				cLin := Stuff(cLin,712,02,cCpo)								// Tipo de Serviço
				//If nBaseISS > 0
				//	cLin := Stuff(cLin,714,01,"1")								// Serviço Tomado / Outros Doctos
				//Else
					cLin := Stuff(cLin,714,01,"0")								// Serviço Tomado / Outros Doctos
				//Endif
				If cTipoCF $ "FRLS"
					cCpo := "1"
				ElseIf cTipoCF == "X"
					cCpo := "3"
				Else
					cCpo := "4"
				Endif
				cLin := Stuff(cLin,715,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
				cCpo := StrZero(0,6,2)
				cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
				cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
				cLin := Stuff(cLin,730,06,StrTran(cCpo,".",","))			// Alíquota do IVA-ST
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,736,12,StrTran(cCpo,".",","))			// Valor da Pauta ou Preço Final
				cCpo := StrZero(0,7,4)
				cLin := Stuff(cLin,748,07,StrTran(cCpo,".",","))			// Alíquota Interna
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,755,12,StrTran(cCpo,".",","))			// ICMS Creditado na Nota
				cCpo := StrZero(0,3,0)
				cLin := Stuff(cLin,767,03,StrTran(cCpo,".",","))			// Classificação Lançto. na DACON
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,770,12,StrTran(cCpo,".",","))			// Imp.Sub.Trib. Substituído
				If nValIRRF > 0
					cCpo := "1708"
				Else
					cCpo := Space(4)
				Endif
				cLin := Stuff(cLin,782,04,cCpo)								// Codigo Receita IRRF retido
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,786,12,StrTran(cCpo,".",","))			// FUNRURAL
				cLin := Stuff(cLin,798,03,SD1->D1_CLASFIS)					// CST ICMS
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
						fClose(nHdl)
						Return
					Endif
				Endif

			Else

				//If cQualDesd == 'cfo'

					//If SD1->D1_CF <> cCFOAnt
					If SD1->(D1_CC+D1_CONTA+D1_CF) <> cChvAnt

						/*
						cCFOAnt := SD1->D1_CF
						nPos    := aScan(aCFO , {|x| x[1] == SD1->D1_CF})
						nQtdCFO := aCFO[nPos][2]
						*/
						cChvAnt := SD1->(D1_CC+D1_CONTA+D1_CF)
						nPos    := aScan(aCFCCCo , {|x| x[1] == SD1->(D1_CC+D1_CONTA+D1_CF)})
						nQtdDesd := aCFCCCo[nPos][2]

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Notas de Entrada - Complemento do Movimento   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//nTamLin := 729
						//nTamLin := 785
						//nTamLin := 797
						nTamLin := 800
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cQuery := ""
						cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
						cQuery += "WHERE "
						cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
						cQuery += "SFT.FT_TIPOMOV = 'E' AND "
						cQuery += "SFT.FT_SERIE = '"  +SD1->D1_SERIE+"' AND "
						cQuery += "SFT.FT_NFISCAL = '"+SD1->D1_DOC+"' AND "
						cQuery += "SFT.FT_CLIEFOR = '"+SD1->D1_FORNECE+"' AND "
						cQuery += "SFT.FT_LOJA = '"   +SD1->D1_LOJA+"' AND "
						//cQuery += "SFT.FT_CFOP = '"   +cCFOAnt+"' AND "
						cQuery += "SFT.FT_ZZCC = '"+Substr(cChvAnt,1,9)+"' AND "
						cQuery += "SFT.FT_CONTA = '"+Substr(cChvAnt,10,20)+"' AND "
						cQuery += "SFT.FT_CFOP = '"+Substr(cChvAnt,30,5)+"' AND "
						cQuery += "SFT.D_E_L_E_T_ <> '*' "
						cQuery += "ORDER BY FT_ZZCC,FT_CONTA,FT_CFOP"

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
						aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

						cCodISS   := ""
						nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
						nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
						nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
						nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
						nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

						dbSelectArea("WSFT")
						dbGoTop()
						While !Eof()
							nValCont  += WSFT->FT_VALCONT
							nBaseICMS += WSFT->FT_BASEICM
							nAliqICMS := WSFT->FT_ALIQICM
							nValICMS  += WSFT->FT_VALICM
							nIsenICMS += WSFT->FT_ISENICM
							nOutrICMS += WSFT->FT_OUTRICM
							nBaseRet  += WSFT->FT_BASERET
							nICMSRet  += WSFT->FT_ICMSRET
							nBaseIPI  += WSFT->FT_BASEIPI
							nAliqIPI  := WSFT->FT_ALIQIPI
							nValIPI   += WSFT->FT_VALIPI
							nIsenIPI  += WSFT->FT_ISENIPI
							nDespesa  += WSFT->FT_DESPESA
							cCodISS   := WSFT->FT_CODISS
							nValINSS  += WSFT->FT_VALINS
							nValIRRF  += WSFT->FT_VALIRR
							nValPIS   += WSFT->FT_VALPIS
							nValCOF   += WSFT->FT_VALCOF
							nValCSL   += WSFT->FT_VALCSL
							nValPISR  += WSFT->FT_VRETPIS
							nValCOFR  += WSFT->FT_VRETCOF
							nValCSLR  += WSFT->FT_VRETCSL
							If WSFT->FT_TIPO == 'S'
								nBaseISS  += WSFT->FT_BASEICM
								nValISS   += WSFT->FT_VALICM
								nAliqISS  := WSFT->FT_ALIQICM
							Endif
							dbSkip()
						Enddo

						dbCloseArea()

						/*
						lISSRet := .F.
						If nValISS > 0
							SE2->(dbSetOrder(6))
							If SE2->(dbSeek(xFilial("SE2")+SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC),.T.))
								While !SE2->(Eof()) .and. SE2->E2_FILIAL==xFilial("SE2") .and.;
										SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC)
									If SE2->E2_TIPO == 'NF ' .and. SE2->E2_ISS > 0
										lISSRet := .T.
									Endif
									SE2->(dbSkip())
								Enddo
							Endif
						Endif
						*/

						If nValCont > 0

							cLin := Stuff(cLin,03,05,StrZero(0,5))							// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,08,02,Right(Alltrim(SD1->D1_CC),2))			// Centro de custo
							cLin := Stuff(cLin,10,04,CT1->CT1_ZZLOG)						// Codigo Contabil
							cLin := Stuff(cLin,14,06,Transform(SD1->D1_CF,"@R 9.999X"))	// Codigo Fiscal
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))				// Valor Contabil
							If nValISS == 0
								cCpo := StrZero(nBaseICMS,12,2)
								cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ICMS
								cCpo := StrZero(nAliqICMS,07,4)
								cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
								cCpo := StrZero(nValICMS,12,2)
								cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ICMS
								cCpo := StrZero(nIsenICMS,12,2)
								cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
								If !(cAuxEsp $ "NFE/NF ") .or. nOutrICMS > 0
									If nOutrICMS > 0
										cCpo := StrZero(nOutrICMS,12,2)
									Else
										cCpo := StrZero(nBaseICMS,12,2)
									Endif
								Else
									If nOutrICMS > 0
										cCpo := StrZero(nOutrICMS,12,2)
									Else
										cCpo := StrZero(nValCont,12,2)
									Endif
								Endif
								cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
								cCpo := StrZero(0,7,4)
								cLin := Stuff(cLin,99,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,106,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
								cCpo := StrZero(nBaseRet,12,2)
								cLin := Stuff(cLin,118,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
								cCpo := StrZero(nAliqICMS,7,4)
								cLin := Stuff(cLin,130,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
								cCpo := StrZero(nICMSRet,12,2)
								cLin := Stuff(cLin,137,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
								cCpo := StrZero(nBaseIPI,12,2)
								cLin := Stuff(cLin,149,12,StrTran(cCpo,".",","))			// Valor Base IPI
								cCpo := StrZero(nAliqIPI,7,4)
								cLin := Stuff(cLin,161,07,StrTran(cCpo,".",","))			// Alíquota do IPI
								cCpo := StrZero(nValIPI,12,2)
								cLin := Stuff(cLin,168,12,StrTran(cCpo,".",","))			// Valor Base IPI
								cCpo := StrZero(nIsenIPI,12,2)
								cLin := Stuff(cLin,180,12,StrTran(cCpo,".",","))			// Valor Isento IPI
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,192,12,StrTran(cCpo,".",","))			// Valor Outras IPI
							Else
								cCpo  := StrZero(nValCont,12,2)
								cCpo1 := StrZero(0,12,2)
								cCpo2 := StrZero(0,07,4)
								cLin := Stuff(cLin,32,12,StrTran(cCpo1,".",","))			// Base do ICMS
								cLin := Stuff(cLin,44,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
								cLin := Stuff(cLin,51,12,StrTran(cCpo1,".",","))			// Valor do ICMS
								cLin := Stuff(cLin,63,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
								cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
								cLin := Stuff(cLin,87,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
								cLin := Stuff(cLin,99,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
								cLin := Stuff(cLin,106,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
								cLin := Stuff(cLin,118,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
								cLin := Stuff(cLin,130,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
								cLin := Stuff(cLin,137,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
								cLin := Stuff(cLin,149,12,StrTran(cCpo1,".",","))			// Valor Base IPI
								cLin := Stuff(cLin,161,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
								cLin := Stuff(cLin,168,12,StrTran(cCpo1,".",","))			// Valor Base IPI
								cLin := Stuff(cLin,180,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
								cLin := Stuff(cLin,192,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
							Endif
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,204,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
							cLin := Stuff(cLin,216,12,StrTran(cCpo,".",","))			// PVV / Cigarro
							cLin := Stuff(cLin,228,12,StrTran(cCpo,".",","))			// Saída Trib. 12 %
							cLin := Stuff(cLin,240,12,StrTran(cCpo,".",","))			// Saída Trib. 25 %
							cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base Calc. Red.
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Alíquota efetiva %
							If WSF1->F1_EST == "EX"
								cCpo := "6"
							Else
								cCpo := " "
							Endif
							cLin := Stuff(cLin,271,01,cCpo)								// Código Antecipação Subs.Trib.
							cCpo := StrZero(nDespesa,14,2)
							cLin := Stuff(cLin,272,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
							cLin := Stuff(cLin,286,10,Space(10))						// Num.Declaração de Importação
							//cLin := Stuff(cLin,296,03,StrZero(nQtdCFO,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,296,03,StrZero(nQtdDesd,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,299,09,StrZero(Val(SD1->D1_DOC),9))		// Controle Interno
							cLin := Stuff(cLin,308,25,Space(25))						// Controle Interno
							cCpo := StrZero(0,16)
							cLin := Stuff(cLin,333,16,cCpo)								// Controle Interno
							cLin := Stuff(cLin,349,01,"0")								// Modalidade do Frete
							cLin := Stuff(cLin,350,03,"000") 							// Cód. Observação
							If Substr(cCFOAnt,2,3) == "551"
								cObsAtivo += Space(250-Len(cObsAtivo))
								cLin := Stuff(cLin,353,250,cObsAtivo)						// Complemento Observação
							Else
								cLin := Stuff(cLin,353,250,Space(250)) 					// Complemento Observação
							Endif
							cLin := Stuff(cLin,603,01,"0")			 					// Subst. Trib. Ref. Petróleo
							cLin := Stuff(cLin,604,01,"0")			 					// Controle Interno
							cLin := Stuff(cLin,605,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,606,10,cCodISS+"  ") 			// Código do Serviço
							cCpo := StrZero(nBaseISS,12,2)
							cLin := Stuff(cLin,616,12,StrTran(cCpo,".",",")) 			// Valor do Serviço
							//If nValISS > 0
							If lISSRet
								cCpo := StrZero(nAliqISS,07,4)
								cLin := Stuff(cLin,628,07,StrTran(cCpo,".",","))			// Alíquota do ISS
								cCpo := StrZero(nValISS,12,2)
								cLin := Stuff(cLin,635,12,StrTran(cCpo,".",","))			// Valor do ISS Retido
							Else
								cCpo1 := StrZero(0,12,2)
								cCpo2 := StrZero(0,07,4)
								//cLin := Stuff(cLin,616,12,StrTran(cCpo1,".",",")) 			// Valor do Serviço
								cLin := Stuff(cLin,628,07,StrTran(cCpo2,".",","))			// Alíquota do ISS
								cLin := Stuff(cLin,635,12,StrTran(cCpo1,".",","))			// Valor do ISS Retido
							Endif
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,647,12,StrTran(cCpo,".",","))			// Valor do INSS Retido
							cCpo := StrZero(nValIRRF,12,2)
							cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Valor do IRRF Retido
							cCpo := StrZero(nValPISR,12,2)
							cLin := Stuff(cLin,671,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							cCpo := StrZero(nValCOFR,12,2)
							cLin := Stuff(cLin,683,12,StrTran(cCpo,".",","))			// Valor do COFINS Retido
							cCpo := StrZero(nValCSLR,12,2)
							cLin := Stuff(cLin,695,12,StrTran(cCpo,".",","))			// Valor do CSLL Retido
							cLin := Stuff(cLin,707,02,WSF1->F1_EST)					// UF de Início da Operação
							cLin := Stuff(cLin,709,03,Space(03))						// CFPS
							If nValISS > 0
								If lISSRet
									cCpo := "02"											// ISS Retido
								Else
									cCpo := "01"											// ISS Normal
								Endif
							Else
								cCpo := Space(2)											// Sem ISS
							Endif
							cLin := Stuff(cLin,712,02,cCpo)									// Tipo de Serviço
							//If nBaseISS > 0
							If !(cAuxEsp $ "NFE/NF ")
								cLin := Stuff(cLin,714,01,"1")								// Serviço Tomado / Outros Doctos
							Else
								cLin := Stuff(cLin,714,01,"0")								// Serviço Tomado / Outros Doctos
							Endif
							If cTipoCF $ "FRLS"
								cCpo := "1"
							ElseIf cTipoCF == "X"
								cCpo := "3"
							Else
								cCpo := "4"
							Endif
							cLin := Stuff(cLin,715,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
							If Alltrim(cCFOAnt) $ "2556/2551"
								cCpo := StrZero(nAliqICMS,7,4)
								cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
								cCpo := StrZero(GetMV("MV_ICMPAD"),7,4)
								cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							Else
								cCpo := StrZero(0,6,2)
								cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
								cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							Endif
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,730,06,StrTran(cCpo,".",","))			// Alíquota do IVA-ST
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,736,12,StrTran(cCpo,".",","))			// Valor da Pauta ou Preço Final
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,748,07,StrTran(cCpo,".",","))			// Alíquota Interna
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,755,12,StrTran(cCpo,".",","))			// ICMS Creditado na Nota
							cCpo := StrZero(0,3,0)
							cLin := Stuff(cLin,767,03,StrTran(cCpo,".",","))			// Classificação Lançto. na DACON
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,770,12,StrTran(cCpo,".",","))			// Imp.Sub.Trib. Substituído
							If nValIRRF > 0
								cCpo := "1708"
							Else
								cCpo := Space(4)
							Endif
							cLin := Stuff(cLin,782,04,cCpo)								// Codigo Receita IRRF retido
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,786,12,StrTran(cCpo,".",","))			// FUNRURAL
							cLin := Stuff(cLin,798,03,SD1->D1_CLASFIS)					// CST ICMS
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
									fClose(nHdl)
									Return
								Endif
							Endif

						Else

							cLin := Stuff(cLin,03,05,StrZero(0,5))							// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,08,02,Right(Alltrim(SD1->D1_CC),2))			// Centro de custo
							cLin := Stuff(cLin,10,04,CT1->CT1_ZZLOG)						// Codigo Contabil
							cLin := Stuff(cLin,14,06,Transform(SD1->D1_CF,"@R 9.999X"))	// Codigo Fiscal
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))				// Valor Contabil
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ICMS
							cCpo := StrZero(nAliqICMS,07,4)
							cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ICMS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
							If !(cAuxEsp $ "NFE/NF ") .or. nOutrICMS > 0
								If nOutrICMS > 0
									cCpo := StrZero(nOutrICMS,12,2)
								Else
									cCpo := StrZero(nBaseICMS,12,2)
								Endif
							Else
								If nOutrICMS > 0
									cCpo := StrZero(nOutrICMS,12,2)
								Else
									cCpo := StrZero(nValCont,12,2)
								Endif
							Endif
							cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,99,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,106,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
							cCpo := StrZero(nBaseRet,12,2)
							cLin := Stuff(cLin,118,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,130,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
							cCpo := StrZero(nICMSRet,12,2)
							cLin := Stuff(cLin,137,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
							cCpo := StrZero(nBaseIPI,12,2)
							cLin := Stuff(cLin,149,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(nAliqIPI,7,4)
							cLin := Stuff(cLin,161,07,StrTran(cCpo,".",","))			// Alíquota do IPI
							cCpo := StrZero(nValIPI,12,2)
							cLin := Stuff(cLin,168,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(nIsenIPI,12,2)
							cLin := Stuff(cLin,180,12,StrTran(cCpo,".",","))			// Valor Isento IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,192,12,StrTran(cCpo,".",","))			// Valor Outras IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,204,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
							cLin := Stuff(cLin,216,12,StrTran(cCpo,".",","))			// PVV / Cigarro
							cLin := Stuff(cLin,228,12,StrTran(cCpo,".",","))			// Saída Trib. 12 %
							cLin := Stuff(cLin,240,12,StrTran(cCpo,".",","))			// Saída Trib. 25 %
							cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base Calc. Red.
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Alíquota efetiva %
							If WSF1->F1_EST == "EX"
								cCpo := "6"
							Else
								cCpo := " "
							Endif
							cLin := Stuff(cLin,271,01,cCpo)								// Código Antecipação Subs.Trib.
							cCpo := StrZero(nDespesa,14,2)
							cLin := Stuff(cLin,272,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
							cLin := Stuff(cLin,286,10,Space(10))						// Num.Declaração de Importação
							//cLin := Stuff(cLin,296,03,StrZero(nQtdCFO,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,296,03,StrZero(nQtdDesd,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,299,09,StrZero(Val(SD1->D1_DOC),9))		// Controle Interno
							cLin := Stuff(cLin,308,25,Space(25))						// Controle Interno
							cCpo := StrZero(0,16)
							cLin := Stuff(cLin,333,16,cCpo)								// Controle Interno
							cLin := Stuff(cLin,349,01,"0")								// Modalidade do Frete
							cLin := Stuff(cLin,350,03,"000") 							// Cód. Observação
							cLin := Stuff(cLin,353,250,Space(250)) 					// Complemento Observação
							cLin := Stuff(cLin,603,01,"0")			 					// Subst. Trib. Ref. Petróleo
							cLin := Stuff(cLin,604,01,"0")			 					// Controle Interno
							cLin := Stuff(cLin,605,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,606,10,cCodISS+"  ") 			// Código do Serviço
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,4)
							cCpo3 := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,616,12,StrTran(cCpo1,".",",")) 			// Valor do Serviço
							//cLin := Stuff(cLin,616,12,StrTran(cCpo3,".",",")) 			// Valor do Serviço
							cLin := Stuff(cLin,628,07,StrTran(cCpo2,".",","))			// Alíquota do ISS
							cLin := Stuff(cLin,635,12,StrTran(cCpo1,".",","))			// Valor do ISS Retido
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,647,12,StrTran(cCpo,".",","))			// Valor do INSS Retido
							cCpo := StrZero(nValIRRF,12,2)
							cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Valor do IRRF Retido
							cCpo := StrZero(nValPISR,12,2)
							cLin := Stuff(cLin,671,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							cCpo := StrZero(nValCOFR,12,2)
							cLin := Stuff(cLin,683,12,StrTran(cCpo,".",","))			// Valor do COFINS Retido
							cCpo := StrZero(nValCSLR,12,2)
							cLin := Stuff(cLin,695,12,StrTran(cCpo,".",","))			// Valor do CSLL Retido
							cLin := Stuff(cLin,707,02,WSF1->F1_EST)						// UF de Início da Operação
							cLin := Stuff(cLin,709,03,Space(03))						// CFPS
							cCpo := "00"
							cLin := Stuff(cLin,712,02,cCpo)								// Tipo de Serviço
							//If nBaseISS > 0
							If !(cAuxEsp $ "NFE/NF ")
								cLin := Stuff(cLin,714,01,"1")								// Serviço Tomado / Outros Doctos
							Else
								cLin := Stuff(cLin,714,01,"0")								// Serviço Tomado / Outros Doctos
							Endif
							If cTipoCF $ "FRLS"
								cCpo := "1"
							ElseIf cTipoCF == "X"
								cCpo := "3"
							Else
								cCpo := "4"
							Endif
							cLin := Stuff(cLin,715,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
							cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,730,06,StrTran(cCpo,".",","))			// Alíquota do IVA-ST
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,736,12,StrTran(cCpo,".",","))			// Valor da Pauta ou Preço Final
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,748,07,StrTran(cCpo,".",","))			// Alíquota Interna
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,755,12,StrTran(cCpo,".",","))			// ICMS Creditado na Nota
							cCpo := StrZero(0,3,0)
							cLin := Stuff(cLin,767,03,StrTran(cCpo,".",","))			// Classificação Lançto. na DACON
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,770,12,StrTran(cCpo,".",","))			// Imp.Sub.Trib. Substituído
							If nValIRRF > 0
								cCpo := "1708"
							Else
								cCpo := Space(4)
							Endif
							cLin := Stuff(cLin,782,04,cCpo)								// Codigo Receita IRRF retido
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,786,12,StrTran(cCpo,".",","))			// FUNRURAL
							cLin := Stuff(cLin,798,03,SD1->D1_CLASFIS)					// CST ICMS
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
									fClose(nHdl)
									Return
								Endif
							Endif

						Endif

					Endif

				/*
				Elseif cQualDesd == 'cc'	// por centro de custo

					If SD1->D1_CC <> cCCAnt

						cCCAnt := SD1->D1_CC
						nPos   := aScan(aCCusto , {|x| x[1] == SD1->D1_CC})
						nQtdCC := aCCusto[nPos][2]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Notas de Entrada - Complemento do Movimento   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//nTamLin := 729
						//nTamLin := 785
						nTamLin := 797
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cQuery := ""
						cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
						cQuery += "WHERE "
						cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
						cQuery += "SFT.FT_TIPOMOV = 'E' AND "
						cQuery += "SFT.FT_SERIE = '"  +SD1->D1_SERIE+"' AND "
						cQuery += "SFT.FT_NFISCAL = '"+SD1->D1_DOC+"' AND "
						cQuery += "SFT.FT_CLIEFOR = '"+SD1->D1_FORNECE+"' AND "
						cQuery += "SFT.FT_LOJA = '"   +SD1->D1_LOJA+"' AND "
						cQuery += "SFT.FT_ZZCC = '"   +cCCAnt+"' AND "
						cQuery += "SFT.D_E_L_E_T_ <> '*'"

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
						aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

						cCodISS   := ""
						nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
						nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
						nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
						nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
						nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

						dbSelectArea("WSFT")
						dbGoTop()
						While !Eof()
							nValCont  += WSFT->FT_VALCONT
							nBaseICMS += WSFT->FT_BASEICM
							nAliqICMS := WSFT->FT_ALIQICM
							nValICMS  += WSFT->FT_VALICM
							nIsenICMS += WSFT->FT_ISENICM
							nOutrICMS += WSFT->FT_OUTRICM
							nBaseRet  += WSFT->FT_BASERET
							nICMSRet  += WSFT->FT_ICMSRET
							nBaseIPI  += WSFT->FT_BASEIPI
							nAliqIPI  := WSFT->FT_ALIQIPI
							nValIPI   += WSFT->FT_VALIPI
							nIsenIPI  += WSFT->FT_ISENIPI
							nDespesa  += WSFT->FT_DESPESA
							cCodISS   := WSFT->FT_CODISS
							nValINSS  += WSFT->FT_VALINS
							nValIRRF  += WSFT->FT_VALIRR
							nValPIS   += WSFT->FT_VALPIS
							nValCOF   += WSFT->FT_VALCOF
							nValCSL   += WSFT->FT_VALCSL
							nValPISR  += WSFT->FT_VRETPIS
							nValCOFR  += WSFT->FT_VRETCOF
							nValCSLR  += WSFT->FT_VRETCSL
							If WSFT->FT_TIPO == 'S'
								nBaseISS  += WSFT->FT_BASEICM
								nValISS   += WSFT->FT_VALICM
								nAliqISS  := WSFT->FT_ALIQICM
							Endif
							dbSkip()
						Enddo

						dbCloseArea()

						lISSRet := .F.
						If nValISS > 0
							SE2->(dbSetOrder(6))
							If SE2->(dbSeek(xFilial("SE2")+SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC),.T.))
								While !SE2->(Eof()) .and. SE2->E2_FILIAL==xFilial("SE2") .and.;
										SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC)
									If SE2->E2_TIPO == 'NF ' .and. SE2->E2_ISS > 0
										lISSRet := .T.
									Endif
									SE2->(dbSkip())
								Enddo
							Endif
						Endif

						If nValCont > 0

							cLin := Stuff(cLin,03,05,StrZero(0,5))							// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,08,02,Right(Alltrim(SD1->D1_CC),2))				// Centro de custo
							cLin := Stuff(cLin,10,04,CT1->CT1_ZZLOG)						// Codigo Contabil
							cLin := Stuff(cLin,14,06,Transform(SD1->D1_CF,"@R 9.999X"))	// Codigo Fiscal
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))				// Valor Contabil
							If nValISS == 0
								cCpo := StrZero(nBaseICMS,12,2)
								cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ICMS
								cCpo := StrZero(nAliqICMS,07,4)
								cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
								cCpo := StrZero(nValICMS,12,2)
								cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ICMS
								cCpo := StrZero(nIsenICMS,12,2)
								cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
								If !(cAuxEsp $ "NFE/NF ") .or. nOutrICMS > 0
									If nOutrICMS > 0
										cCpo := StrZero(nOutrICMS,12,2)
									Else
										cCpo := StrZero(nBaseICMS,12,2)
									Endif
								Else
									cCpo := StrZero(nOutrICMS,12,2)
								Endif
								cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
								cCpo := StrZero(0,7,4)
								cLin := Stuff(cLin,99,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,106,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
								cCpo := StrZero(nBaseRet,12,2)
								cLin := Stuff(cLin,118,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
								cCpo := StrZero(nAliqICMS,7,4)
								cLin := Stuff(cLin,130,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
								cCpo := StrZero(nICMSRet,12,2)
								cLin := Stuff(cLin,137,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
								cCpo := StrZero(nBaseIPI,12,2)
								cLin := Stuff(cLin,149,12,StrTran(cCpo,".",","))			// Valor Base IPI
								cCpo := StrZero(nAliqIPI,7,4)
								cLin := Stuff(cLin,161,07,StrTran(cCpo,".",","))			// Alíquota do IPI
								cCpo := StrZero(nValIPI,12,2)
								cLin := Stuff(cLin,168,12,StrTran(cCpo,".",","))			// Valor Base IPI
								cCpo := StrZero(nIsenIPI,12,2)
								cLin := Stuff(cLin,180,12,StrTran(cCpo,".",","))			// Valor Isento IPI
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,192,12,StrTran(cCpo,".",","))			// Valor Outras IPI
							Else
								cCpo  := StrZero(nValCont,12,2)
								cCpo1 := StrZero(0,12,2)
								cCpo2 := StrZero(0,07,4)
								cLin := Stuff(cLin,32,12,StrTran(cCpo1,".",","))			// Base do ICMS
								cLin := Stuff(cLin,44,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
								cLin := Stuff(cLin,51,12,StrTran(cCpo1,".",","))			// Valor do ICMS
								cLin := Stuff(cLin,63,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
								cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
								cLin := Stuff(cLin,87,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
								cLin := Stuff(cLin,99,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
								cLin := Stuff(cLin,106,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
								cLin := Stuff(cLin,118,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
								cLin := Stuff(cLin,130,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
								cLin := Stuff(cLin,137,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
								cLin := Stuff(cLin,149,12,StrTran(cCpo1,".",","))			// Valor Base IPI
								cLin := Stuff(cLin,161,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
								cLin := Stuff(cLin,168,12,StrTran(cCpo1,".",","))			// Valor Base IPI
								cLin := Stuff(cLin,180,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
								cLin := Stuff(cLin,192,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
							Endif
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,204,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
							cLin := Stuff(cLin,216,12,StrTran(cCpo,".",","))			// PVV / Cigarro
							cLin := Stuff(cLin,228,12,StrTran(cCpo,".",","))			// Saída Trib. 12 %
							cLin := Stuff(cLin,240,12,StrTran(cCpo,".",","))			// Saída Trib. 25 %
							cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base Calc. Red.
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Alíquota efetiva %
							If WSF1->F1_EST == "EX"
								cCpo := "6"
							Else
								cCpo := " "
							Endif
							cLin := Stuff(cLin,271,01,cCpo)								// Código Antecipação Subs.Trib.
							cCpo := StrZero(nDespesa,14,2)
							cLin := Stuff(cLin,272,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
							cLin := Stuff(cLin,286,10,Space(10))						// Num.Declaração de Importação
							cLin := Stuff(cLin,296,03,StrZero(nQtdCC,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,299,09,StrZero(Val(SD1->D1_DOC),9))		// Controle Interno
							cLin := Stuff(cLin,308,25,Space(25))						// Controle Interno
							cCpo := StrZero(0,16)
							cLin := Stuff(cLin,333,16,cCpo)								// Controle Interno
							cLin := Stuff(cLin,349,01,"0")								// Modalidade do Frete
							cLin := Stuff(cLin,350,03,"000") 							// Cód. Observação
							If Substr(SD1->D1_CF,2,3) == "551"
								cObsAtivo += Space(250-Len(cObsAtivo))
								cLin := Stuff(cLin,353,250,cObsAtivo)						// Complemento Observação
							Else
								cLin := Stuff(cLin,353,250,Space(250)) 					// Complemento Observação
							Endif
							cLin := Stuff(cLin,603,01,"0")			 					// Subst. Trib. Ref. Petróleo
							cLin := Stuff(cLin,604,01,"0")			 					// Controle Interno
							cLin := Stuff(cLin,605,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,606,10,cCodISS+"  ") 			// Código do Serviço
							cCpo := StrZero(nBaseISS,12,2)
							cLin := Stuff(cLin,616,12,StrTran(cCpo,".",",")) 			// Valor do Serviço
							//If nValISS > 0
							If lISSRet
								cCpo := StrZero(nAliqISS,07,4)
								cLin := Stuff(cLin,628,07,StrTran(cCpo,".",","))			// Alíquota do ISS
								cCpo := StrZero(nValISS,12,2)
								cLin := Stuff(cLin,635,12,StrTran(cCpo,".",","))			// Valor do ISS Retido
							Else
								cCpo1 := StrZero(0,12,2)
								cCpo2 := StrZero(0,07,4)
								//cLin := Stuff(cLin,616,12,StrTran(cCpo1,".",",")) 			// Valor do Serviço
								cLin := Stuff(cLin,628,07,StrTran(cCpo2,".",","))			// Alíquota do ISS
								cLin := Stuff(cLin,635,12,StrTran(cCpo1,".",","))			// Valor do ISS Retido
							Endif
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,647,12,StrTran(cCpo,".",","))			// Valor do INSS Retido
							cCpo := StrZero(nValIRRF,12,2)
							cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Valor do IRRF Retido
							cCpo := StrZero(nValPISR,12,2)
							cLin := Stuff(cLin,671,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							cCpo := StrZero(nValCOFR,12,2)
							cLin := Stuff(cLin,683,12,StrTran(cCpo,".",","))			// Valor do COFINS Retido
							cCpo := StrZero(nValCSLR,12,2)
							cLin := Stuff(cLin,695,12,StrTran(cCpo,".",","))			// Valor do CSLL Retido
							cLin := Stuff(cLin,707,02,WSF1->F1_EST)						// UF de Início da Operação
							cLin := Stuff(cLin,709,03,Space(03))						// CFPS
							If nValISS > 0 .AND. nValICMS > 0
								cCpo := "02"
							ElseIf nValISS > 0 .AND. nValICMS == 0
								cCpo := "01"
							Else
								cCpo := "00"
							Endif
							cLin := Stuff(cLin,712,02,cCpo)								// Tipo de Serviço
							//If nBaseISS > 0
							If !(cAuxEsp $ "NFE/NF ")
								cLin := Stuff(cLin,714,01,"1")								// Serviço Tomado / Outros Doctos
							Else
								cLin := Stuff(cLin,714,01,"0")								// Serviço Tomado / Outros Doctos
							Endif
							If cTipoCF $ "FRLS"
								cCpo := "1"
							ElseIf cTipoCF == "X"
								cCpo := "3"
							Else
								cCpo := "4"
							Endif
							cLin := Stuff(cLin,715,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
							If Alltrim(SD1->D1_CF) $ "2556/2551"
								cCpo := StrZero(nAliqICMS,7,4)
								cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
								cCpo := StrZero(GetMV("MV_ICMPAD"),7,4)
								cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							Else
								cCpo := StrZero(0,6,2)
								cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
								cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							Endif
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,730,06,StrTran(cCpo,".",","))			// Alíquota do IVA-ST
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,736,12,StrTran(cCpo,".",","))			// Valor da Pauta ou Preço Final
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,748,07,StrTran(cCpo,".",","))			// Alíquota Interna
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,755,12,StrTran(cCpo,".",","))			// ICMS Creditado na Nota
							cCpo := StrZero(0,3,0)
							cLin := Stuff(cLin,767,03,StrTran(cCpo,".",","))			// Classificação Lançto. na DACON
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,770,12,StrTran(cCpo,".",","))			// Imp.Sub.Trib. Substituído
							If nValIRRF > 0
								cCpo := "1708"
							Else
								cCpo := Space(4)
							Endif
							cLin := Stuff(cLin,782,04,cCpo)								// Codigo Receita IRRF retido
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,786,12,StrTran(cCpo,".",","))			// FUNRURAL
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
									fClose(nHdl)
									Return
								Endif
							Endif

						Else

							cLin := Stuff(cLin,03,05,StrZero(0,5))							// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,08,02,Right(Alltrim(SD1->D1_CC),2))			// Centro de custo
							cLin := Stuff(cLin,10,04,CT1->CT1_ZZLOG)						// Codigo Contabil
							cLin := Stuff(cLin,14,06,Transform(SD1->D1_CF,"@R 9.999X"))	// Codigo Fiscal
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))				// Valor Contabil
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ICMS
							cCpo := StrZero(nAliqICMS,07,4)
							cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ICMS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
							If !(cAuxEsp $ "NFE/NF ") .or. nOutrICMS > 0
								If nOutrICMS > 0
									cCpo := StrZero(nOutrICMS,12,2)
								Else
									cCpo := StrZero(nBaseICMS,12,2)
								Endif
							Else
								cCpo := StrZero(nOutrICMS,12,2)
							Endif
							cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,99,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,106,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
							cCpo := StrZero(nBaseRet,12,2)
							cLin := Stuff(cLin,118,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,130,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
							cCpo := StrZero(nICMSRet,12,2)
							cLin := Stuff(cLin,137,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
							cCpo := StrZero(nBaseIPI,12,2)
							cLin := Stuff(cLin,149,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(nAliqIPI,7,4)
							cLin := Stuff(cLin,161,07,StrTran(cCpo,".",","))			// Alíquota do IPI
							cCpo := StrZero(nValIPI,12,2)
							cLin := Stuff(cLin,168,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(nIsenIPI,12,2)
							cLin := Stuff(cLin,180,12,StrTran(cCpo,".",","))			// Valor Isento IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,192,12,StrTran(cCpo,".",","))			// Valor Outras IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,204,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
							cLin := Stuff(cLin,216,12,StrTran(cCpo,".",","))			// PVV / Cigarro
							cLin := Stuff(cLin,228,12,StrTran(cCpo,".",","))			// Saída Trib. 12 %
							cLin := Stuff(cLin,240,12,StrTran(cCpo,".",","))			// Saída Trib. 25 %
							cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base Calc. Red.
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Alíquota efetiva %
							If WSF1->F1_EST == "EX"
								cCpo := "6"
							Else
								cCpo := " "
							Endif
							cLin := Stuff(cLin,271,01,cCpo)								// Código Antecipação Subs.Trib.
							cCpo := StrZero(nDespesa,14,2)
							cLin := Stuff(cLin,272,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
							cLin := Stuff(cLin,286,10,Space(10))						// Num.Declaração de Importação
							cLin := Stuff(cLin,296,03,StrZero(nQtdCC,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,299,09,StrZero(Val(SD1->D1_DOC),9))		// Controle Interno
							cLin := Stuff(cLin,308,25,Space(25))						// Controle Interno
							cCpo := StrZero(0,16)
							cLin := Stuff(cLin,333,16,cCpo)								// Controle Interno
							cLin := Stuff(cLin,349,01,"0")								// Modalidade do Frete
							cLin := Stuff(cLin,350,03,"000") 							// Cód. Observação
							cLin := Stuff(cLin,353,250,Space(250)) 					// Complemento Observação
							cLin := Stuff(cLin,603,01,"0")			 					// Subst. Trib. Ref. Petróleo
							cLin := Stuff(cLin,604,01,"0")			 					// Controle Interno
							cLin := Stuff(cLin,605,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,606,10,cCodISS+"  ") 			// Código do Serviço
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,4)
							cCpo3 := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,616,12,StrTran(cCpo1,".",",")) 			// Valor do Serviço
							//cLin := Stuff(cLin,616,12,StrTran(cCpo3,".",",")) 			// Valor do Serviço
							cLin := Stuff(cLin,628,07,StrTran(cCpo2,".",","))			// Alíquota do ISS
							cLin := Stuff(cLin,635,12,StrTran(cCpo1,".",","))			// Valor do ISS Retido
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,647,12,StrTran(cCpo,".",","))			// Valor do INSS Retido
							cCpo := StrZero(nValIRRF,12,2)
							cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Valor do IRRF Retido
							cCpo := StrZero(nValPISR,12,2)
							cLin := Stuff(cLin,671,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							cCpo := StrZero(nValCOFR,12,2)
							cLin := Stuff(cLin,683,12,StrTran(cCpo,".",","))			// Valor do COFINS Retido
							cCpo := StrZero(nValCSLR,12,2)
							cLin := Stuff(cLin,695,12,StrTran(cCpo,".",","))			// Valor do CSLL Retido
							cLin := Stuff(cLin,707,02,WSF1->F1_EST)						// UF de Início da Operação
							cLin := Stuff(cLin,709,03,Space(03))						// CFPS
							cCpo := "00"
							cLin := Stuff(cLin,712,02,cCpo)								// Tipo de Serviço
							//If nBaseISS > 0
							If !(cAuxEsp $ "NFE/NF ")
								cLin := Stuff(cLin,714,01,"1")								// Serviço Tomado / Outros Doctos
							Else
								cLin := Stuff(cLin,714,01,"0")								// Serviço Tomado / Outros Doctos
							Endif
							If cTipoCF $ "FRLS"
								cCpo := "1"
							ElseIf cTipoCF == "X"
								cCpo := "3"
							Else
								cCpo := "4"
							Endif
							cLin := Stuff(cLin,715,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
							cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,730,06,StrTran(cCpo,".",","))			// Alíquota do IVA-ST
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,736,12,StrTran(cCpo,".",","))			// Valor da Pauta ou Preço Final
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,748,07,StrTran(cCpo,".",","))			// Alíquota Interna
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,755,12,StrTran(cCpo,".",","))			// ICMS Creditado na Nota
							cCpo := StrZero(0,3,0)
							cLin := Stuff(cLin,767,03,StrTran(cCpo,".",","))			// Classificação Lançto. na DACON
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,770,12,StrTran(cCpo,".",","))			// Imp.Sub.Trib. Substituído
							If nValIRRF > 0
								cCpo := "1708"
							Else
								cCpo := Space(4)
							Endif
							cLin := Stuff(cLin,782,04,cCpo)								// Codigo Receita IRRF retido
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,786,12,StrTran(cCpo,".",","))			// FUNRURAL
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
									fClose(nHdl)
									Return
								Endif
							Endif

						Endif

					Endif

				Else	// por conta contabil

					If SD1->D1_CONTA <> cContAnt

						cContAnt  := SD1->D1_CONTA
						nPos      := aScan(aConta , {|x| x[1] == SD1->D1_CONTA})
						nQtdConta := aConta[nPos][2]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Notas de Entrada - Complemento do Movimento   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//nTamLin := 729
						//nTamLin := 785
						nTamLin := 797
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cQuery := ""
						cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
						cQuery += "WHERE "
						cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
						cQuery += "SFT.FT_TIPOMOV = 'E' AND "
						cQuery += "SFT.FT_SERIE = '"  +SD1->D1_SERIE+"' AND "
						cQuery += "SFT.FT_NFISCAL = '"+SD1->D1_DOC+"' AND "
						cQuery += "SFT.FT_CLIEFOR = '"+SD1->D1_FORNECE+"' AND "
						cQuery += "SFT.FT_LOJA = '"   +SD1->D1_LOJA+"' AND "
						cQuery += "SFT.FT_CONTA = '"  +cContAnt+"' AND "
						cQuery += "SFT.D_E_L_E_T_ <> '*'"

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
						aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

						cCodISS   := ""
						nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
						nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
						nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
						nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
						nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

						dbSelectArea("WSFT")
						dbGoTop()
						While !Eof()
							nValCont  += WSFT->FT_VALCONT
							nBaseICMS += WSFT->FT_BASEICM
							nAliqICMS := WSFT->FT_ALIQICM
							nValICMS  += WSFT->FT_VALICM
							nIsenICMS += WSFT->FT_ISENICM
							nOutrICMS += WSFT->FT_OUTRICM
							nBaseRet  += WSFT->FT_BASERET
							nICMSRet  += WSFT->FT_ICMSRET
							nBaseIPI  += WSFT->FT_BASEIPI
							nAliqIPI  := WSFT->FT_ALIQIPI
							nValIPI   += WSFT->FT_VALIPI
							nIsenIPI  += WSFT->FT_ISENIPI
							nDespesa  += WSFT->FT_DESPESA
							cCodISS   := WSFT->FT_CODISS
							nValINSS  += WSFT->FT_VALINS
							nValIRRF  += WSFT->FT_VALIRR
							nValPIS   += WSFT->FT_VALPIS
							nValCOF   += WSFT->FT_VALCOF
							nValCSL   += WSFT->FT_VALCSL
							nValPISR  += WSFT->FT_VRETPIS
							nValCOFR  += WSFT->FT_VRETCOF
							nValCSLR  += WSFT->FT_VRETCSL
							If WSFT->FT_TIPO == 'S'
								nBaseISS  += WSFT->FT_BASEICM
								nValISS   += WSFT->FT_VALICM
								nAliqISS  := WSFT->FT_ALIQICM
							Endif
							dbSkip()
						Enddo

						dbCloseArea()

						lISSRet := .F.
						If nValISS > 0
							SE2->(dbSetOrder(6))
							If SE2->(dbSeek(xFilial("SE2")+SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC),.T.))
								While !SE2->(Eof()) .and. SE2->E2_FILIAL==xFilial("SE2") .and.;
										SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC)
									If SE2->E2_TIPO == 'NF ' .and. SE2->E2_ISS > 0
										lISSRet := .T.
									Endif
									SE2->(dbSkip())
								Enddo
							Endif
						Endif

						If nValCont > 0

							cLin := Stuff(cLin,03,05,StrZero(0,5))							// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,08,02,Right(Alltrim(SD1->D1_CC),2))				// Centro de custo
							cLin := Stuff(cLin,10,04,CT1->CT1_ZZLOG)						// Codigo Contabil
							cLin := Stuff(cLin,14,06,Transform(SD1->D1_CF,"@R 9.999X"))	// Codigo Fiscal
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))				// Valor Contabil
							If nValISS == 0
								cCpo := StrZero(nBaseICMS,12,2)
								cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ICMS
								cCpo := StrZero(nAliqICMS,07,4)
								cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
								cCpo := StrZero(nValICMS,12,2)
								cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ICMS
								cCpo := StrZero(nIsenICMS,12,2)
								cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
								If !(cAuxEsp $ "NFE/NF ") .or. nOutrICMS > 0
									If nOutrICMS > 0
										cCpo := StrZero(nOutrICMS,12,2)
									Else
										cCpo := StrZero(nBaseICMS,12,2)
									Endif
								Else
									cCpo := StrZero(nOutrICMS,12,2)
								Endif
								cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
								cCpo := StrZero(0,7,4)
								cLin := Stuff(cLin,99,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,106,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
								cCpo := StrZero(nBaseRet,12,2)
								cLin := Stuff(cLin,118,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
								cCpo := StrZero(nAliqICMS,7,4)
								cLin := Stuff(cLin,130,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
								cCpo := StrZero(nICMSRet,12,2)
								cLin := Stuff(cLin,137,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
								cCpo := StrZero(nBaseIPI,12,2)
								cLin := Stuff(cLin,149,12,StrTran(cCpo,".",","))			// Valor Base IPI
								cCpo := StrZero(nAliqIPI,7,4)
								cLin := Stuff(cLin,161,07,StrTran(cCpo,".",","))			// Alíquota do IPI
								cCpo := StrZero(nValIPI,12,2)
								cLin := Stuff(cLin,168,12,StrTran(cCpo,".",","))			// Valor Base IPI
								cCpo := StrZero(nIsenIPI,12,2)
								cLin := Stuff(cLin,180,12,StrTran(cCpo,".",","))			// Valor Isento IPI
								cCpo := StrZero(0,12,2)
								cLin := Stuff(cLin,192,12,StrTran(cCpo,".",","))			// Valor Outras IPI
								cCpo  := StrZero(nValCont,12,2)
							Else
								cCpo1 := StrZero(0,12,2)
								cCpo2 := StrZero(0,07,4)
								cLin := Stuff(cLin,32,12,StrTran(cCpo1,".",","))			// Base do ICMS
								cLin := Stuff(cLin,44,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
								cLin := Stuff(cLin,51,12,StrTran(cCpo1,".",","))			// Valor do ICMS
								cLin := Stuff(cLin,63,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
								cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
								cLin := Stuff(cLin,87,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
								cLin := Stuff(cLin,99,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
								cLin := Stuff(cLin,106,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
								cLin := Stuff(cLin,118,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
								cLin := Stuff(cLin,130,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
								cLin := Stuff(cLin,137,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
								cLin := Stuff(cLin,149,12,StrTran(cCpo1,".",","))			// Valor Base IPI
								cLin := Stuff(cLin,161,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
								cLin := Stuff(cLin,168,12,StrTran(cCpo1,".",","))			// Valor Base IPI
								cLin := Stuff(cLin,180,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
								cLin := Stuff(cLin,192,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
							Endif
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,204,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
							cLin := Stuff(cLin,216,12,StrTran(cCpo,".",","))			// PVV / Cigarro
							cLin := Stuff(cLin,228,12,StrTran(cCpo,".",","))			// Saída Trib. 12 %
							cLin := Stuff(cLin,240,12,StrTran(cCpo,".",","))			// Saída Trib. 25 %
							cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base Calc. Red.
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Alíquota efetiva %
							If WSF1->F1_EST == "EX"
								cCpo := "6"
							Else
								cCpo := " "
							Endif
							cLin := Stuff(cLin,271,01,cCpo)								// Código Antecipação Subs.Trib.
							cCpo := StrZero(nDespesa,14,2)
							cLin := Stuff(cLin,272,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
							cLin := Stuff(cLin,286,10,Space(10))						// Num.Declaração de Importação
							cLin := Stuff(cLin,296,03,StrZero(nQtdConta,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,299,09,StrZero(Val(SD1->D1_DOC),9))		// Controle Interno
							cLin := Stuff(cLin,308,25,Space(25))						// Controle Interno
							cCpo := StrZero(0,16)
							cLin := Stuff(cLin,333,16,cCpo)								// Controle Interno
							cLin := Stuff(cLin,349,01,"0")								// Modalidade do Frete
							cLin := Stuff(cLin,350,03,"000") 							// Cód. Observação
							If Substr(SD1->D1_CF,2,3) == "551"
								cObsAtivo += Space(250-Len(cObsAtivo))
								cLin := Stuff(cLin,353,250,cObsAtivo)						// Complemento Observação
							Else
								cLin := Stuff(cLin,353,250,Space(250)) 					// Complemento Observação
							Endif
							cLin := Stuff(cLin,603,01,"0")			 					// Subst. Trib. Ref. Petróleo
							cLin := Stuff(cLin,604,01,"0")			 					// Controle Interno
							cLin := Stuff(cLin,605,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,606,10,cCodISS+"  ") 			// Código do Serviço
							cCpo := StrZero(nBaseISS,12,2)
							cLin := Stuff(cLin,616,12,StrTran(cCpo,".",",")) 			// Valor do Serviço
							//If nValISS > 0
							If lISSRet
								cCpo := StrZero(nAliqISS,07,4)
								cLin := Stuff(cLin,628,07,StrTran(cCpo,".",","))			// Alíquota do ISS
								cCpo := StrZero(nValISS,12,2)
								cLin := Stuff(cLin,635,12,StrTran(cCpo,".",","))			// Valor do ISS Retido
							Else
								cCpo1 := StrZero(0,12,2)
								cCpo2 := StrZero(0,07,4)
								//cLin := Stuff(cLin,616,12,StrTran(cCpo1,".",",")) 			// Valor do Serviço
								cLin := Stuff(cLin,628,07,StrTran(cCpo2,".",","))			// Alíquota do ISS
								cLin := Stuff(cLin,635,12,StrTran(cCpo1,".",","))			// Valor do ISS Retido
							Endif
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,647,12,StrTran(cCpo,".",","))			// Valor do INSS Retido
							cCpo := StrZero(nValIRRF,12,2)
							cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Valor do IRRF Retido
							cCpo := StrZero(nValPISR,12,2)
							cLin := Stuff(cLin,671,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							cCpo := StrZero(nValCOFR,12,2)
							cLin := Stuff(cLin,683,12,StrTran(cCpo,".",","))			// Valor do COFINS Retido
							cCpo := StrZero(nValCSLR,12,2)
							cLin := Stuff(cLin,695,12,StrTran(cCpo,".",","))			// Valor do CSLL Retido
							cLin := Stuff(cLin,707,02,WSF1->F1_EST)						// UF de Início da Operação
							cLin := Stuff(cLin,709,03,Space(03))						// CFPS
							If nValISS > 0 .AND. nValICMS > 0
								cCpo := "02"
							ElseIf nValISS > 0 .AND. nValICMS == 0
								cCpo := "01"
							Else
								cCpo := "00"
							Endif
							cLin := Stuff(cLin,712,02,cCpo)								// Tipo de Serviço
							//If nBaseISS > 0
							If !(cAuxEsp $ "NFE/NF ")
								cLin := Stuff(cLin,714,01,"1")								// Serviço Tomado / Outros Doctos
							Else
								cLin := Stuff(cLin,714,01,"0")								// Serviço Tomado / Outros Doctos
							Endif
							If cTipoCF $ "FRLS"
								cCpo := "1"
							ElseIf cTipoCF == "X"
								cCpo := "3"
							Else
								cCpo := "4"
							Endif
							cLin := Stuff(cLin,715,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
							If Alltrim(SD1->D1_CF) $ "2556/2551"
								cCpo := StrZero(nAliqICMS,7,4)
								cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
								cCpo := StrZero(GetMV("MV_ICMPAD"),7,4)
								cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							Else
								cCpo := StrZero(0,6,2)
								cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
								cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							Endif
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,730,06,StrTran(cCpo,".",","))			// Alíquota do IVA-ST
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,736,12,StrTran(cCpo,".",","))			// Valor da Pauta ou Preço Final
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,748,07,StrTran(cCpo,".",","))			// Alíquota Interna
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,755,12,StrTran(cCpo,".",","))			// ICMS Creditado na Nota
							cCpo := StrZero(0,3,0)
							cLin := Stuff(cLin,767,03,StrTran(cCpo,".",","))			// Classificação Lançto. na DACON
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,770,12,StrTran(cCpo,".",","))			// Imp.Sub.Trib. Substituído
							If nValIRRF > 0
								cCpo := "1708"
							Else
								cCpo := Space(4)
							Endif
							cLin := Stuff(cLin,782,04,cCpo)								// Codigo Receita IRRF retido
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,786,12,StrTran(cCpo,".",","))			// FUNRURAL
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
									fClose(nHdl)
									Return
								Endif
							Endif

						Else

							cLin := Stuff(cLin,03,05,StrZero(0,5))							// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,08,02,Right(Alltrim(SD1->D1_CC),2))			// Centro de custo
							cLin := Stuff(cLin,10,04,CT1->CT1_ZZLOG)						// Codigo Contabil
							cLin := Stuff(cLin,14,06,Transform(SD1->D1_CF,"@R 9.999X"))	// Codigo Fiscal
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))				// Valor Contabil
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ICMS
							cCpo := StrZero(nAliqICMS,07,4)
							cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ICMS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
							If !(cAuxEsp $ "NFE/NF ") .or. nOutrICMS > 0
								If nOutrICMS > 0
									cCpo := StrZero(nOutrICMS,12,2)
								Else
									cCpo := StrZero(nBaseICMS,12,2)
								Endif
							Else
								cCpo := StrZero(nOutrICMS,12,2)
							Endif
							cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,99,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,106,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
							cCpo := StrZero(nBaseRet,12,2)
							cLin := Stuff(cLin,118,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,130,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
							cCpo := StrZero(nICMSRet,12,2)
							cLin := Stuff(cLin,137,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
							cCpo := StrZero(nBaseIPI,12,2)
							cLin := Stuff(cLin,149,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(nAliqIPI,7,4)
							cLin := Stuff(cLin,161,07,StrTran(cCpo,".",","))			// Alíquota do IPI
							cCpo := StrZero(nValIPI,12,2)
							cLin := Stuff(cLin,168,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(nIsenIPI,12,2)
							cLin := Stuff(cLin,180,12,StrTran(cCpo,".",","))			// Valor Isento IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,192,12,StrTran(cCpo,".",","))			// Valor Outras IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,204,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
							cLin := Stuff(cLin,216,12,StrTran(cCpo,".",","))			// PVV / Cigarro
							cLin := Stuff(cLin,228,12,StrTran(cCpo,".",","))			// Saída Trib. 12 %
							cLin := Stuff(cLin,240,12,StrTran(cCpo,".",","))			// Saída Trib. 25 %
							cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base Calc. Red.
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Alíquota efetiva %
							If WSF1->F1_EST == "EX"
								cCpo := "6"
							Else
								cCpo := " "
							Endif
							cLin := Stuff(cLin,271,01,cCpo)								// Código Antecipação Subs.Trib.
							cCpo := StrZero(nDespesa,14,2)
							cLin := Stuff(cLin,272,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
							cLin := Stuff(cLin,286,10,Space(10))						// Num.Declaração de Importação
							cLin := Stuff(cLin,296,03,StrZero(nQtdConta,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,299,09,StrZero(Val(SD1->D1_DOC),9))		// Controle Interno
							cLin := Stuff(cLin,308,25,Space(25))						// Controle Interno
							cCpo := StrZero(0,16)
							cLin := Stuff(cLin,333,16,cCpo)								// Controle Interno
							cLin := Stuff(cLin,349,01,"0")								// Modalidade do Frete
							cLin := Stuff(cLin,350,03,"000") 							// Cód. Observação
							cLin := Stuff(cLin,353,250,Space(250)) 					// Complemento Observação
							cLin := Stuff(cLin,603,01,"0")			 					// Subst. Trib. Ref. Petróleo
							cLin := Stuff(cLin,604,01,"0")			 					// Controle Interno
							cLin := Stuff(cLin,605,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,606,10,cCodISS+"  ") 			// Código do Serviço
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,4)
							cCpo3 := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,616,12,StrTran(cCpo1,".",",")) 			// Valor do Serviço
							//cLin := Stuff(cLin,616,12,StrTran(cCpo3,".",",")) 			// Valor do Serviço
							cLin := Stuff(cLin,628,07,StrTran(cCpo2,".",","))			// Alíquota do ISS
							cLin := Stuff(cLin,635,12,StrTran(cCpo1,".",","))			// Valor do ISS Retido
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,647,12,StrTran(cCpo,".",","))			// Valor do INSS Retido
							cCpo := StrZero(nValIRRF,12,2)
							cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Valor do IRRF Retido
							cCpo := StrZero(nValPISR,12,2)
							cLin := Stuff(cLin,671,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							cCpo := StrZero(nValCOFR,12,2)
							cLin := Stuff(cLin,683,12,StrTran(cCpo,".",","))			// Valor do COFINS Retido
							cCpo := StrZero(nValCSLR,12,2)
							cLin := Stuff(cLin,695,12,StrTran(cCpo,".",","))			// Valor do CSLL Retido
							cLin := Stuff(cLin,707,02,WSF1->F1_EST)						// UF de Início da Operação
							cLin := Stuff(cLin,709,03,Space(03))						// CFPS
							cCpo := "00"
							cLin := Stuff(cLin,712,02,cCpo)								// Tipo de Serviço
							//If nBaseISS > 0
							If !(cAuxEsp $ "NFE/NF ")
								cLin := Stuff(cLin,714,01,"1")								// Serviço Tomado / Outros Doctos
							Else
								cLin := Stuff(cLin,714,01,"0")								// Serviço Tomado / Outros Doctos
							Endif
							If cTipoCF $ "FRLS"
								cCpo := "1"
							ElseIf cTipoCF == "X"
								cCpo := "3"
							Else
								cCpo := "4"
							Endif
							cLin := Stuff(cLin,715,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,716,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
							cLin := Stuff(cLin,723,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,730,06,StrTran(cCpo,".",","))			// Alíquota do IVA-ST
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,736,12,StrTran(cCpo,".",","))			// Valor da Pauta ou Preço Final
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,748,07,StrTran(cCpo,".",","))			// Alíquota Interna
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,755,12,StrTran(cCpo,".",","))			// ICMS Creditado na Nota
							cCpo := StrZero(0,3,0)
							cLin := Stuff(cLin,767,03,StrTran(cCpo,".",","))			// Classificação Lançto. na DACON
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,770,12,StrTran(cCpo,".",","))			// Imp.Sub.Trib. Substituído
							If nValIRRF > 0
								cCpo := "1708"
							Else
								cCpo := Space(4)
							Endif
							cLin := Stuff(cLin,782,04,cCpo)								// Codigo Receita IRRF retido
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,786,12,StrTran(cCpo,".",","))			// FUNRURAL
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
									fClose(nHdl)
									Return
								Endif
							Endif

						Endif

					Endif

				Endif
				*/

			Endif

			If lCTE

				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Entrada - Itens do Complemento       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//nTamLin := 449
				//nTamLin := 484
				nTamLin := 588
				cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

				cLin := Stuff(cLin,05,03,StrZero(0,3))				// Número Item
				cLin := Stuff(cLin,08,14,Space(14))				// Código Produto Empresa
				cLin := Stuff(cLin,22,08,Space(8))					// NCM do Produto
				cLin := Stuff(cLin,30,53,Space(53))				// Descrição do Produto
				cLin := Stuff(cLin,83,06,Space(6))					// Unidade do Produto
				cCpo := StrZero(0,6,2)
				cLin := Stuff(cLin,89,06,StrTran(cCpo,".",","))		// Alíquota do IPI
				cCpo := StrZero(0,6,2)
				cLin := Stuff(cLin,95,06,StrTran(cCpo,".",","))		// Alíquota de ICMS
				cLin := Stuff(cLin,101,45,Space(45))					// Descrição Complementar Produto
				cCpo := StrZero(0,18,3)
				cLin := Stuff(cLin,146,18,StrTran(cCpo,".",","))		// Quantidade do Produto
				cCpo := StrZero(0,20,6)
				cLin := Stuff(cLin,164,20,StrTran(cCpo,".",","))		// Valor Unitário do Produto
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,184,18,StrTran(cCpo,".",","))		// Valor Total do Produto
				cLin := Stuff(cLin,202,03,Space(3))					// Código Situação Tributária
				cLin := Stuff(cLin,205,01,"1")							// Indicador Mov. Física Produto
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,206,18,StrTran(cCpo,".",","))		// Valor Desconto/Desp.Acessórias
				cLin := Stuff(cLin,224,06,Space(6))					// Código Natureza Operação
				cLin := Stuff(cLin,230,45,Space(45))					// Descriçao da Natureza Operação
				cCpo := "4"
				cLin := Stuff(cLin,275,01,cCpo)							// Indicador Tributação do ICMS
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,276,18,StrTran(cCpo,".",","))		// Base Cálculo de ICMS
				cLin := Stuff(cLin,294,18,StrTran(cCpo,".",","))		// Valor do ICMS
				cLin := Stuff(cLin,312,18,StrTran(cCpo,".",","))		// Base Cálc. ICMS Subst.Trib.
				cLin := Stuff(cLin,330,18,StrTran(cCpo,".",","))		// Base Cálc. ICMS Subst.Trib.
				cCpo := StrZero(0,13,2)
				cLin := Stuff(cLin,348,13,StrTran(cCpo,".",","))		// B.Cálc. ST Origem/Destino
				cLin := Stuff(cLin,361,13,StrTran(cCpo,".",","))		// ICMS-ST repassar/deduzir
				cLin := Stuff(cLin,374,13,StrTran(cCpo,".",","))		// ICMS-ST complemen. a UF Dest.
				cLin := Stuff(cLin,387,13,StrTran(cCpo,".",","))		// Base Cálculo Retenção ICMS-ST
				cLin := Stuff(cLin,400,13,StrTran(cCpo,".",","))		// Valor Parc. Imp.Retido ICMS-ST
				cLin := Stuff(cLin,413,01,"1")							// Indicador Tributação do IPI
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,414,18,StrTran(cCpo,".",","))		// Base de Cálculo do IPI
				cLin := Stuff(cLin,432,18,StrTran(cCpo,".",","))		// Base de Cálculo do IPI
				cCpo := StrZero(0,13,2)
				cLin := Stuff(cLin,450,13,StrTran(cCpo,".",","))		// Valor Despesas Acessórias
				cCpo := "99"
				cLin := Stuff(cLin,463,02,cCpo)							// Tipo do Produto
				cLin := Stuff(cLin,465,20,Space(20))					// Nº Lote Fabricação-Medicamento
				cLin := Stuff(cLin,485,02,"56")							// Classificacao Trib PIS
				cAliqPis  := StrZero(0,7,4)
				cAliqCof  := StrZero(0,7,4)
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,487,12,StrTran(cCpo,".",","))		// Base de Calculo PIS
				cLin := Stuff(cLin,499,07,StrTran(cAliqPis,".",","))	// Aliquota PIS
				cCpo := StrZero(0,12,3)
				cLin := Stuff(cLin,506,12,StrTran(cCpo,".",","))		// Quantidade PIS
				cCpo := StrZero(0,7,4)
				cLin := Stuff(cLin,518,07,StrTran(cCpo,".",","))		// Aliquota PIS em Reais
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,525,12,StrTran(cCpo,".",","))		// Valor do PIS
				cLin := Stuff(cLin,537,02,"56")							// Classificacao Trib PIS
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,539,12,StrTran(cCpo,".",","))		// Base de Calculo COFINS
				cLin := Stuff(cLin,551,07,StrTran(cAliqCof,".",","))	// Aliquota COFINS
				cCpo := StrZero(0,12,3)
				cLin := Stuff(cLin,558,12,StrTran(cCpo,".",","))		// Quantidade COFINS
				cCpo := StrZero(0,7,4)
				cLin := Stuff(cLin,570,07,StrTran(cCpo,".",","))		// Aliquota COFINS em Reais
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,577,12,StrTran(cCpo,".",","))		// Valor do COFINS
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
						fClose(nHdl)
						Return
					Endif
				Endif
				*/

			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Entrada - Itens do Complemento       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//nTamLin := 449
				//nTamLin := 484
				nTamLin := 588
				cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

				nItemSD1++
				cLin := Stuff(cLin,05,03,StrZero(nItemSD1,3))				// Número Item
				cLin := Stuff(cLin,08,14,Substr(SD1->D1_COD,1,14))						// Código Produto Empresa
				cLin := Stuff(cLin,22,08,Substr(SB1->B1_POSIPI,1,8))					// NCM do Produto
				cLin := Stuff(cLin,30,53,StrTran(SB1->B1_DESC,chr(9),""))						// Descrição do Produto
				cLin := Stuff(cLin,83,06,SB1->B1_UM)						// Unidade do Produto
				cCpo := StrZero(SD1->D1_IPI,6,2)
				cLin := Stuff(cLin,89,06,StrTran(cCpo,".",","))			// Alíquota do IPI
				cCpo := StrZero(SD1->D1_PICM,6,2)
				cLin := Stuff(cLin,95,06,StrTran(cCpo,".",","))			// Alíquota de ICMS
				cLin := Stuff(cLin,101,45,Substr(SB5->B5_CEME,1,45))					// Descrição Complementar Produto
				cCpo := StrZero(SD1->D1_QUANT,18,3)
				cLin := Stuff(cLin,146,18,StrTran(cCpo,".",","))			// Quantidade do Produto
				cCpo := StrZero(SD1->D1_VUNIT,20,6)
				cLin := Stuff(cLin,164,20,StrTran(cCpo,".",","))			// Valor Unitário do Produto
				cCpo := StrZero(SD1->D1_TOTAL,18,2)
				cLin := Stuff(cLin,184,18,StrTran(cCpo,".",","))			// Valor Total do Produto
				cLin := Stuff(cLin,202,03,SD1->D1_CLASFIS)					// Código Situação Tributária
				cLin := Stuff(cLin,205,01,"1")								// Indicador Mov. Física Produto
		    	cCpo := StrZero(SD1->(D1_DESC+D1_DESPESA),18,2)
				cLin := Stuff(cLin,206,18,StrTran(cCpo,".",","))			// Valor Desconto/Desp.Acessórias
				cLin := Stuff(cLin,224,06,SD1->D1_CF)						// Código Natureza Operação
				cCpo := Posicione("SX5",1,xFilial("SX5")+"13"+SD1->D1_CF,"X5_DESCRI")
				cLin := Stuff(cLin,230,45,Substr(cCpo,1,45))								// Descriçao da Natureza Operação
				If Substr(SD1->D1_CLASFIS,2,2) $ "00/20"
					cCpo := "1"
				Elseif Substr(SD1->D1_CLASFIS,2,2) $ "30/40"
					cCpo := "2"
				Elseif Substr(SD1->D1_CLASFIS,2,2) $ "41/50/51/90"
					cCpo := "3"
				Else
					cCpo := "4"
				Endif
				cLin := Stuff(cLin,275,01,cCpo)								// Indicador Tributação do ICMS
				If cCpo $ '2/3'
					cCpo := StrZero(0,18,2)
					cLin := Stuff(cLin,276,18,StrTran(cCpo,".",","))			// Base Cálculo de ICMS
					cCpo := StrZero(0,18,2)
					cLin := Stuff(cLin,294,18,StrTran(cCpo,".",","))			// Valor do ICMS
				Else
					cCpo := StrZero(SD1->D1_BASEICM,18,2)
					cLin := Stuff(cLin,276,18,StrTran(cCpo,".",","))			// Base Cálculo de ICMS
					cCpo := StrZero(SD1->D1_VALICM,18,2)
					cLin := Stuff(cLin,294,18,StrTran(cCpo,".",","))			// Valor do ICMS
				Endif
				cCpo := StrZero(SD1->D1_BRICMS,18,2)
				cLin := Stuff(cLin,312,18,StrTran(cCpo,".",","))			// Base Cálc. ICMS Subst.Trib.
				cCpo := StrZero(SD1->D1_ICMSRET,18,2)
				cLin := Stuff(cLin,330,18,StrTran(cCpo,".",","))			// Base Cálc. ICMS Subst.Trib.
				cCpo := StrZero(0,13,2)
				cLin := Stuff(cLin,348,13,StrTran(cCpo,".",","))			// B.Cálc. ST Origem/Destino
				cLin := Stuff(cLin,361,13,StrTran(cCpo,".",","))			// ICMS-ST repassar/deduzir
				cLin := Stuff(cLin,374,13,StrTran(cCpo,".",","))			// ICMS-ST complemen. a UF Dest.
				cLin := Stuff(cLin,387,13,StrTran(cCpo,".",","))			// Base Cálculo Retenção ICMS-ST
				cLin := Stuff(cLin,400,13,StrTran(cCpo,".",","))			// Valor Parc. Imp.Retido ICMS-ST
				cLin := Stuff(cLin,413,01,"2")								// Indicador Tributação do IPI
				If Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_CTIPI") == "00"      // se IPI for Tributado
					cCpo := StrZero(SD1->D1_BASEIPI,18,2)
					cLin := Stuff(cLin,414,18,StrTran(cCpo,".",","))			// Base de Cálculo do IPI
					cCpo := StrZero(SD1->D1_VALIPI,18,2)
					cLin := Stuff(cLin,432,18,StrTran(cCpo,".",","))			// Base de Cálculo do IPI
				Else
					cCpo := StrZero(0,18,2)
					cLin := Stuff(cLin,414,18,StrTran(cCpo,".",","))			// Base de Cálculo do IPI
					cCpo := StrZero(0,18,2)
					cLin := Stuff(cLin,432,18,StrTran(cCpo,".",","))			// Base de Cálculo do IPI
				Endif
				cCpo := StrZero(0,13,2)
				cLin := Stuff(cLin,450,13,StrTran(cCpo,".",","))			// Valor Despesas Acessórias

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Busco o tipo do item para montar o campo do registro ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTipo := ASCAN(aTipo,{|x| x[1]==SD1->D1_TP})
				If nTipo > 0
					cCpo := aTipo[nTipo][2]
				Else
					cCpo := "99"
				EndIf
				cLin := Stuff(cLin,463,02,cCpo)								// Tipo do Produto
				cLin := Stuff(cLin,465,20,Space(20))						// Nº Lote Fabricação-Medicamento
				cCpo := Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_CSTPIS")
				cLin := Stuff(cLin,485,02,cCpo)								// Classificacao Trib PIS
				If SD1->D1_BASIMP5 > 0
					cAliqPis  := StrZero(GETMV("MV_TXPIS"),7,4)
					cAliqCof  := StrZero(GETMV("MV_TXCOFIN"),7,4)
				Else
					cAliqPis  := StrZero(0,7,4)
					cAliqCof  := StrZero(0,7,4)
				Endif
				cCpo := StrZero(SD1->D1_BASIMP6,12,2)
				cLin := Stuff(cLin,487,12,StrTran(cCpo,".",","))			// Base de Calculo PIS
				cLin := Stuff(cLin,499,07,StrTran(cAliqPis,".",","))			// Aliquota PIS
				cCpo := StrZero(0,12,3)
				cLin := Stuff(cLin,506,12,StrTran(cCpo,".",","))			// Quantidade PIS
				cCpo := StrZero(0,7,4)
				cLin := Stuff(cLin,518,07,StrTran(cCpo,".",","))			// Aliquota PIS em Reais
				cCpo := StrZero(SD1->D1_VALIMP6,12,2)
				cLin := Stuff(cLin,525,12,StrTran(cCpo,".",","))			// Valor do PIS
				cCpo := Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_CSTCOF")
				cLin := Stuff(cLin,537,02,cCpo)								// Classificacao Trib PIS
				cCpo := StrZero(SD1->D1_BASIMP5,12,2)
				cLin := Stuff(cLin,539,12,StrTran(cCpo,".",","))			// Base de Calculo COFINS
				cLin := Stuff(cLin,551,07,StrTran(cAliqCof,".",","))			// Aliquota COFINS
				cCpo := StrZero(0,12,3)
				cLin := Stuff(cLin,558,12,StrTran(cCpo,".",","))			// Quantidade COFINS
				cCpo := StrZero(0,7,4)
				cLin := Stuff(cLin,570,07,StrTran(cCpo,".",","))			// Aliquota COFINS em Reais
				cCpo := StrZero(SD1->D1_VALIMP5,12,2)
				cLin := Stuff(cLin,577,12,StrTran(cCpo,".",","))			// Valor do COFINS
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
						fClose(nHdl)
						Return
					Endif
				Endif

			Endif

			dbSelectArea("SD1")
			dbSkip()
			lFirst := .F.

		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PARCELAS DE NOTA A PRAZO                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTamLin := 31
		cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

		If Len(aDupli) > 0
			For nA:=1 to Len(aDupli)
				cLin := Stuff(cLin,03,05,"PAR")									// Tipo de Parcela
				cLin := Stuff(cLin,06,15,GravaData(DtoC(aDupli[nA][2]),.T.,5))// Data de Vencimento
				cCpo := StrZero(aDupli[nA][3],16,2)
				cLin := Stuff(cLin,16,31,StrTran(cCpo,".",","))				// Valor da Parcela
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
						fClose(nHdl)
						Return
					Endif
				Endif
			Next
		Else
			cLin := Stuff(cLin,03,05,Space(3))					// Tipo de Parcela
			cLin := Stuff(cLin,06,15,DtoC(CtoD(Space(8))))		// Data de Vencimento
			cCpo := StrZero(0,16,2)
			cLin := Stuff(cLin,16,31,StrTran(cCpo,".",","))	// Valor da Parcela
			cLin += _cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
					fClose(nHdl)
					Return
				Endif
			Endif
		Endif

		dbSelectArea("WSF1")
		dbSkip()

	Enddo

	dbSelectArea("WSF1")

	dbCloseArea()
	dbSelectArea("SF1")
	RetIndex("SF1")

	dbSelectArea("SD1")
	RetIndex("SD1")
	#IFNDEF TOP
		fErase(cNomArqSD1+OrdBagExt())
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto das notas de        ³
	//³ entrada deve ser fechado.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fClose(nHdl)

Endif

If !Empty(cNomArq2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abro novo arquivo. Agora para as    ³
	//³ notas de saida.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHdl := fCreate(cDir+cNomArq2)

	If nHdl == -1
		MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq2+" não pode ser executado! Verifique os parãmetros."),OemToAnsi("Atenção!"))
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabecalho do arquivo                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If fWrite(nHdl,cLinCab,Len(cLinCab)) != Len(cLinCab)
		If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
			fClose(nHdl)
			Return
		Endif
	Endif

	dbSelectArea("SD2")
	cChaveSD2  := 'D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_ZZCC+D2_CONTA+D2_CF'
	cNomArqSD2 := CriaTrab(Nil,.F.)
	IndRegua("SD2",cNomArqSD2,cChaveSD2,,,OemToAnsi("Selecionando Registros..."))

	dbSelectArea("SD2")
	#IFNDEF TOP
		dbSetIndex(cNomArqSD2+OrdBagExt())
	#ENDIF

	cQuery := ""
	cQuery += "SELECT * , R_E_C_N_O_ RECSF2 FROM "+RetSQlName("SF2")+" SF2 "
	cQuery += "WHERE "
	cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
	cQuery += "SF2.F2_EMISSAO >= '"+dtos(mv_par01)+"' AND SF2.F2_EMISSAO <= '"+dtos(mv_par02)+"' AND "
	cQuery += "SF2.F2_SERIE <> 'X  ' AND F2_BASEISS = 0 AND "
	If !Empty(mv_par10)
		cQuery += "SF2.F2_DOC = '"+mv_par10+"' AND "
	Endif
	cQuery += "SF2.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY F2_FILIAL,F2_EMISSAO,F2_DOC,F2_SERIE"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSF2",.T.,.T.)
	aEval(SF2->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSF2",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSF2")
	Count to nTotReg
	dbGoTop()

	ProcRegua(nTotReg) // Numero de registros a processar

	While !Eof()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa a regua                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProc(OemToAnsi("Lendo Registros das Notas de Saída..."))

		If WSF2->F2_TIPO $ "D#B"
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+WSF2->(F2_CLIENTE+F2_LOJA)))
			cCNPJ := SA2->A2_CGC
			cNome := SA2->A2_NOME
			cIE   := Iif(Empty(SA2->A2_INSCR),"ISENTO",SA2->A2_INSCR)
			cUF   := aUF[aScan(aUF,{|x| x[1] == SA2->A2_EST})][02]
			cCodM := cUF+Iif(Empty(SA2->A2_COD_MUN),"3520509",SA2->A2_COD_MUN)
			cTipoCF := SA2->A2_TIPO
			cOptSimples := IIf(Empty(SA2->A2_SIMPNAC),"0",IIF(SA2->A2_SIMPNAC="1","1","0"))
			cEnd    := Substr(SA2->A2_END,1,at(",",SA2->A2_END)-1)
			cNum    := StrZero(Val(Substr(SA2->A2_END,at(",",SA2->A2_END)+1)),5)
			cCEP    := Transform(SA2->A2_CEP,"@R 99999-999")
			cBairro := SA2->A2_BAIRRO
			cIMun   := SA2->A2_INSCRM
			cEstado := SA2->A2_EST
			cColig  := ""
		Else
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+WSF2->(F2_CLIENTE+F2_LOJA)))
			cCNPJ := SA1->A1_CGC
			cNome := SA1->A1_NOME
			cIE   := Iif(Empty(SA1->A1_INSCR),"ISENTO",SA1->A1_INSCR)
			cUF   := aUF[aScan(aUF,{|x| x[1] == SA1->A1_EST})][02]
			cCodM := cUF+Iif(Empty(SA1->A1_COD_MUN),"3520509",SA1->A1_COD_MUN)
			cTipoCF := SA1->A1_TIPO
			cOptSimples := IIf(Empty(SA1->A1_SIMPNAC),"0",IIF(SA1->A1_SIMPNAC="1","1","0"))
			cEnd    := Substr(SA1->A1_END,1,at(",",SA1->A1_END)-1)
			cNum    := StrZero(Val(Substr(SA1->A1_END,at(",",SA1->A1_END)+1)),5)
			cCEP    := Transform(SA1->A1_CEP,"@R 99999-999")
			cBairro := SA1->A1_BAIRRO
			cIMun   := SA1->A1_INSCRM
			cEstado := SA1->A1_EST
			cColig  := SA1->A1_ZZCOLIG
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Laco existente so para contar a quantidade de itens da nota, CFOP, Centro de Custo e conta contabil     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD2")
		dbSeek(xFilial("SD2")+WSF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
		aCFO    := {}
		aCCusto := {}
		aConta  := {}
		nItem := 0

		While !Eof() .and. SD2->D2_FILIAL == xFilial("SD2") .and. D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ==;
			WSF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem dos CFOPs  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLoc := aScan(aCFO , {|x| x[1] == D2_CF})
			If nLoc == 0
				aadd(aCFO , {D2_CF , 1})
			Else
				aCFO[nLoc][2] += 1
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem dos Centros de Custo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLoc := aScan(aCCusto , {|x| x[1] == D2_ZZCC})
			If nLoc == 0
				aadd(aCCusto , {D2_ZZCC , 1})
			Else
				aCCusto[nLoc][2] += 1
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem das Contas Contabeis ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLoc := aScan(aConta , {|x| x[1] == D2_CONTA})
			If nLoc == 0
				aadd(aConta , {D2_CONTA , 1})
			Else
				aConta[nLoc][2] += 1
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contagem dos Itens da Nota    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nItem++

			dbSkip()
		Enddo

		aAux := {{Len(aCCusto),'cc'},{Len(aConta),'conta'},{Len(aCFO),'cfo'}}
		aSort(aAux,,, { |x,y| x[1] < y[1] })

		nDesdobr  := aAux[Len(aAux)][1]
		cQualDesd := aAux[Len(aAux)][2]

		If cQualDesd == 'cc' .and. Empty(aCCusto[1][1])
			aAux := {{Len(aConta),'conta'},{Len(aCFO),'cfo'},{Len(aCCusto),'cc'}}
			aSort(aAux,,, { |x,y| x[1] < y[1] })
			nDesdobr  := aAux[Len(aAux)][1]
			cQualDesd := aAux[Len(aAux)][2]
		Endif

		If cQualDesd == 'conta' .and. Empty(aConta[1][1])
			aAux := {{Len(aCFO),'cfo'},{Len(aCCusto),'cc'},{Len(aConta),'conta'}}
			aSort(aAux,,, { |x,y| x[1] < y[1] })
			nDesdobr  := aAux[Len(aAux)][1]
			cQualDesd := aAux[Len(aAux)][2]
		Endif

		If nDesdobr <= 1
			cDesdobr := "00"
		Else
			cDesdobr := StrZero(nDesdobr-1,2)
		Endif

		dbSelectArea("SD2")
		dbSeek(xFilial("SD2")+WSF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
		lFirst   := .T.
		nItemSD2 := 0
		cCSTPC   := Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_CSTPIS")
		cCFOAnt  := ""
		cCCAnt   := ""
		cContAnt := ""

		While !Eof() .and. SD2->D2_FILIAL == xFilial("SD2") .and. D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ==;
			WSF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
			SB5->(dbSetOrder(1))
			SB5->(dbSeek(xFilial("SB5")+SD2->D2_COD))
			CT1->(dbSetOrder(1))
			CT1->(dbSeek(xFilial("CT1")+SD2->D2_CONTA))

			If lFirst

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Substitui nas respectivas posicoes na variavel cLin pelo conteudo   ³
				//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
				//³ string dentro de outra string.                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Saida - Movimento Principal      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//nTamLin := 855
				//nTamLin := 1051
				nTamLin := 1121
				cLin    := Space(nTamLin)				//	Variavel para criacao da linha do registros para gravacao

				cCpo := PADR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),18)
				cLin := Stuff(cLin,01,18,cCpo)						// CNPJ da Empresa
				cLin := Stuff(cLin,19,01,"S")							// Tipo S=Saida
				//cLin := Stuff(cLin,20,05,"NF   ")          			// Espécie
				cLin := Stuff(cLin,20,05,"NFE  ")          				// Espécie
				//cLin := Stuff(cLin,25,03,SF2->F2_SERIE)				// Série
				If SM0->M0_CODIGO == '03'
					cLin := Stuff(cLin,25,03,"1  ")							// Série
				Else
					cLin := Stuff(cLin,25,03,"2  ")							// Série
				Endif
				cLin := Stuff(cLin,28,02,"  ")							// Sub Serie da nota
				cLin := Stuff(cLin,30,12,StrZero(0,12))				// Número do Documento Inicial/Final
				cCpo := GravaData(WSF2->F2_EMISSAO,.T.,5)
				cLin := Stuff(cLin,42,10,DtoC(cCpo))				// Data do Documento
				cLin := Stuff(cLin,52,02,WSF2->F2_EST)				// Unidade Federativa
				If WSF2->F2_EST == "EX"
					cCpo := PADR("P-030",18)
				Else
					If Len(Alltrim(cCNPJ)) == 14							// CNPJ do Cliente
						cCpo := Transform(cCNPJ,"@R 99.999.999/9999-99")
					ElseIf Len(Alltrim(cCNPJ)) == 11						// CPF do Cliente
						cCpo := Transform(cCNPJ,"@R 999.999.999-99")
					Else
						cCpo := Space(18)
					Endif
				Endif
				cLin := Stuff(cLin,54,18,cCpo)
				cCpo := Padr(cNome,40)
				cLin := Stuff(cLin,72,40,cCpo)             // Nome do Cliente
				cLin := Stuff(cLin,112,20,cIE)				// Inscr. Est. do Cliente
				If WSF2->F2_EST == "EX"
					cCpo := "99.999.99"
				Else
					If Empty(cCodM)
						cCpo := Space(9)
					Else
						cCpo := Transform(cCodM,"@R 99.999.99")
					Endif
				Endif
				cLin := Stuff(cLin,132,09,cCpo)							// Cód. IBGE (Cidade Cliente)
				cCpo := StrZero(WSF2->F2_VALBRUT,12,2)
				cLin := Stuff(cLin,141,12,StrTran(cCpo,".",","))	// Valor Total da Nota Fiscal
				If WSF2->F2_COND == "001"
					cCpo := "0"				// 0=Nota a vista
				Else
					cCpo := "1"				// 1=Nota a Prazo
				Endif
				cLin := Stuff(cLin,153,01,cCpo)							// Forma de pagto
				cLin := Stuff(cLin,154,06,"000000")	        			// Número Contador Z
				cCpo := StrZero(0,17,2)
				cLin := Stuff(cLin,160,17,StrTran(cCpo,".",","))	// Valor GT Inicial
				cLin := Stuff(cLin,177,17,StrTran(cCpo,".",","))	// Valor GT Final
				cLin := Stuff(cLin,194,17,StrTran(cCpo,".",","))	// Valor de Cancelamentos
				cLin := Stuff(cLin,211,17,StrTran(cCpo,".",","))	// Valor de Descontos
				If WSF2->F2_EST == "EX"
					cCpo := StrZero(1,15)
				Else
					cCpo := StrZero(0,15)
				Endif
				cLin := Stuff(cLin,228,15,cCpo)							// Registro de Exportação
				cLin := Stuff(cLin,243,06,StrZero(0,6))	        	// Num. Nota de Devolução
				If !Empty(WSF2->F2_NFORI)
					cCpo := PADR("NF   ",05)
				Else
					cCpo := Space(5)
				Endif
				cLin := Stuff(cLin,249,05,cCpo)		        		// Espécie da Nota Devolução
				cCpo := PADR(WSF2->F2_SERIORI,03)
				cLin := Stuff(cLin,254,03,cCpo)		        		// Série da Nota Devolução
				cLin := Stuff(cLin,257,02,Space(02)) 	 			// Sub-Série da Nota de Devolução
				//cLin := Stuff(cLin,259,02,cCFO) 	 					// Desdobramento
				cLin := Stuff(cLin,259,02,cDesdobr) 	 					// Desdobramento
				cLin := Stuff(cLin,261,09,Space(09))  				// DIPAM - Município Início Frete
				cLin := Stuff(cLin,270,06,Space(06))  				// C R O / Intervenção
				cCpo := StrZero(0,15,2)
				cLin := Stuff(cLin,276,17,StrTran(cCpo,".",","))	// Valor GT Final Antes Reinício
				cCpo := "0"
				cLin := Stuff(cLin,293,01,cCpo)		  					// Nota Conjugada
				cCpo := StrZero(WSF2->F2_FRETE,18,2)
				cLin := Stuff(cLin,294,18,StrTran(cCpo,".",","))	// Valor do Frete
				cCpo := StrZero(WSF2->F2_SEGURO,18,2)
				cLin := Stuff(cLin,312,18,StrTran(cCpo,".",","))	// Valor do Seguro
				cCpo := StrZero(WSF2->F2_DESCONT,18,2)
				cLin := Stuff(cLin,330,18,StrTran(cCpo,".",","))	// Valor do Desconto
				cCpo := StrZero(0,18)
				cLin := Stuff(cLin,348,18,cCpo)							// CNPJ do Local de saida
				cLin := Stuff(cLin,366,40,Space(40))		        	// Nome do CNPJ Local de Saída
				cLin := Stuff(cLin,406,20,Space(20))               // Inscr. Estad. CNPJ Local Saída
				cLin := Stuff(cLin,426,09,Space(09))               // Cód.Mun.IBGE CNPJ Local Saída
				cLin := Stuff(cLin,435,18,cCpo)							// CNPJ do Local Entrada
				cLin := Stuff(cLin,453,40,Space(40))					// Nome do CNPJ Local de Entrada
				cLin := Stuff(cLin,493,20,Space(20))               // Inscr. Estad. CNPJ Local Entrada
				cLin := Stuff(cLin,513,09,Space(09))					// Cód.Mun.IBGE CNPJ Local Entrada
				cLin := Stuff(cLin,522,18,cCpo)							// CNPJ do Transportador
				cLin := Stuff(cLin,540,40,Space(40))					// Nome do CNPJ do Transportador
				cLin := Stuff(cLin,580,20,Space(20))               // Inscr. Estad. do Transportador
				cLin := Stuff(cLin,600,09,Space(09))					// Cód.Mun.IBGE do Transportador
				cLin := Stuff(cLin,609,10,"CAIXA     ")				// Especie de Volumes
				cLin := Stuff(cLin,619,01,"0")							// Modalidade de Transporte
				cLin := Stuff(cLin,620,07,Space(7))						// Placa Veiculo 1
				cLin := Stuff(cLin,627,02,Space(2))						// UF Placa Veiculo 1
				cLin := Stuff(cLin,629,07,Space(7))						// Placa Veiculo 2
				cLin := Stuff(cLin,636,02,Space(2))						// UF Placa Veiculo 2
				cLin := Stuff(cLin,638,07,Space(7))						// Placa Veiculo 3
				cLin := Stuff(cLin,645,02,Space(2))						// UF Placa Veiculo 3
				cCpo := StrZero(WSF2->F2_PBRUTO,18,3)
				cLin := Stuff(cLin,647,18,StrTran(cCpo,".",","))	// Peso Bruto
				cCpo := StrZero(WSF2->F2_PLIQUI,18,3)
				cLin := Stuff(cLin,665,18,StrTran(cCpo,".",","))	// Peso Liquido
				cLin := Stuff(cLin,683,10,"00/00/0000")				// Data Averbação de Exportação
				cCpo := StrZero(0,11)
				cLin := Stuff(cLin,693,11,cCpo)							// Número Declaração Exportação
				cLin := Stuff(cLin,704,10,"00/00/0000")				// Data Declaração de Exportação
				cCpo := StrZero(0,16)
				cLin := Stuff(cLin,714,16,cCpo)							// Número Conhecimento Embarque
				cLin := Stuff(cLin,730,02,"00")							// Cód.Tipo Conhecimento Embarque
				cLin := Stuff(cLin,732,10,"00/00/0000")				// Data Conhecimento Embarque
				cLin := Stuff(cLin,742,01,"0")							// Natureza da Exportação
				cLin := Stuff(cLin,743,02,"00")							// Sigla do País da Exportação
				cCpo := StrZero(0,18)
				cLin := Stuff(cLin,745,18,cCpo)							// CNPJ Remetente da Exportação
				cLin := Stuff(cLin,763,40,Space(40))					// Nome Remetente da Exportação
				cLin := Stuff(cLin,803,20,Space(20))            		// Inscr.Est.Remetente Exportação
				cLin := Stuff(cLin,823,09,Space(09))					// Cód.IBGE Remetente Exportação
				cLin := Stuff(cLin,832,01,"0")							// Relacionamento da Exportação
				cLin := Stuff(cLin,833,03,StrZero(0,3))					// Quantidade Registro 71
				cLin := Stuff(cLin,836,20,Space(20))					// Insc.Est.Secundária Cliente
				cLin := Stuff(cLin,856,40,cEnd)						// Endereço
				cLin := Stuff(cLin,896,05,cNum)						// Numero
				cLin := Stuff(cLin,901,09,cCEP)						// CEP
				cLin := Stuff(cLin,910,30,cBairro)					// Bairro
				cLin := Stuff(cLin,940,02,Space(02))				// Sigla do Pais
				cLin := Stuff(cLin,942,11,cIMun)					// Inscricao Municipal
				//cLin := Stuff(cLin,953,10,StrZero(0,10))				// Chave NFE-Nota Fisc.Eletrônica
				cLin := Stuff(cLin,953,10,StrZero(Val(Right(WSF2->F2_CHVNFE,10)),10))				// Chave NFE-Nota Fisc.Eletrônica
				cLin := Stuff(cLin,963,01,Space(01))					// Indicador do Título de Crédito
				cLin := Stuff(cLin,964,20,Space(20))					// Descrição do Título de Crédito
				cLin := Stuff(cLin,984,12,Space(12))					// Número do Título de Crédito
				cLin := Stuff(cLin,996,03,Space(03))					// Situação Trib. ICMS Transporte
				cLin := Stuff(cLin,999,03,StrZero(0,03))				// Quantidade de Parcelas
				cLin := Stuff(cLin,1002,02,StrZero(0,02))				// Dia do Vencimento da Parcela
				cLin := Stuff(cLin,1004,07,Space(07))			   		// Período Inicial Parcelamento
				cLin := Stuff(cLin,1011,01,StrZero(0,01))		   		// Dia vencto. p/ transf.
				cLin := Stuff(cLin,1012,02,StrZero(0,02))		   		// Intervalo entre cada parcela
				cLin := Stuff(cLin,1014,10,Space(10))			   		// Dia Inicial do Parcelamento
				cCpo := StrZero(Val(WSF2->F2_DOC),9)
				cLin := Stuff(cLin,1024,18,cCpo+cCpo)			   		// Nº Documento Inicial e Final
				cCpo := StrZero(Val(WSF2->F2_NFORI),9)
				cLin := Stuff(cLin,1042,09,cCpo)			   			// Nº Nota de Devolução
				cLin := Stuff(cLin,1051,01,cOptSimples)					// Optante do Simples Nacional
				cLin := Stuff(cLin,1052,02,cCSTPC)						// Situacao Tributaria do PIS
				cCpo := StrZero(WSF2->F2_BASIMP6,13,2)
				cLin := Stuff(cLin,1054,13,StrTran(cCpo,".",","))		// Base de Calculo do PIS
				cCpo := StrZero(GETMV("MV_TXPIS"),7,4)
				cLin := Stuff(cLin,1067,07,StrTran(cCpo,".",","))		// Aliquota PIS
				cCpo := StrZero(WSF2->F2_VALIMP6,13,2)
				cLin := Stuff(cLin,1074,13,StrTran(cCpo,".",","))		// Valor do PIS
				cLin := Stuff(cLin,1087,02,cCSTPC)						// Situacao Tributaria do COFINS
				cCpo := StrZero(WSF2->F2_BASIMP5,13,2)
				cLin := Stuff(cLin,1089,13,StrTran(cCpo,".",","))		// Base de Calculo do COFINS
				cCpo := StrZero(GETMV("MV_TXCOFIN"),7,4)
				cLin := Stuff(cLin,1102,07,StrTran(cCpo,".",","))		// Aliquota COFINS
				cCpo := StrZero(WSF2->F2_VALIMP5,13,2)
				cLin := Stuff(cLin,1109,13,StrTran(cCpo,".",","))		// Valor do COFINS

				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
						fClose(nHdl)
						Return
					Endif
				Endif

			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Notas de Saida - Complemento do Movimento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cQualDesd == 'cfo'

				If SD2->D2_CF <> cCFOAnt

					cCFOAnt := SD2->D2_CF
					nPos    := aScan(aCFO , {|x| x[1] == SD2->D2_CF})
					nQtdCFO := aCFO[nPos][2]

					cQuery := ""
					cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
					cQuery += "WHERE "
					cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
					cQuery += "SFT.FT_TIPOMOV = 'S' AND "
					cQuery += "SFT.FT_SERIE = '"  +SD2->D2_SERIE+"' AND "
					cQuery += "SFT.FT_NFISCAL = '"+SD2->D2_DOC+"' AND "
					cQuery += "SFT.FT_CLIEFOR = '"+SD2->D2_CLIENTE+"' AND "
					cQuery += "SFT.FT_LOJA = '"   +SD2->D2_LOJA+"' AND "
					cQuery += "SFT.FT_CFOP = '"   +cCFOAnt+"' AND "
					cQuery += "SFT.D_E_L_E_T_ <> '*'"

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
					aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

					cCodISS   := ""
					nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
					nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
					nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
					nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
					nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

					dbSelectArea("WSFT")
					dbGoTop()
					While !Eof()
						nValCont  += WSFT->FT_VALCONT
						nBaseICMS += WSFT->FT_BASEICM
						nAliqICMS := WSFT->FT_ALIQICM
						nValICMS  += WSFT->FT_VALICM
						nIsenICMS += WSFT->FT_ISENICM
						nOutrICMS += WSFT->FT_OUTRICM
						nBaseRet  += WSFT->FT_BASERET
						nICMSRet  += WSFT->FT_ICMSRET
						nBaseIPI  += WSFT->FT_BASEIPI
						nAliqIPI  := WSFT->FT_ALIQIPI
						nValIPI   += WSFT->FT_VALIPI
						nIsenIPI  += WSFT->FT_ISENIPI
						nDespesa  += WSFT->FT_DESPESA
						cCodISS   := WSFT->FT_CODISS
						nValINSS  += WSFT->FT_VALINS
						nValIRRF  += WSFT->FT_VALIRR
						nValPIS   += WSFT->FT_VALPIS
						nValCOF   += WSFT->FT_VALCOF
						nValCSL   += WSFT->FT_VALCSL
						nValPISR  += WSFT->FT_VRETPIS
						nValCOFR  += WSFT->FT_VRETCOF
						nValCSLR  += WSFT->FT_VRETCSL
						If WSFT->FT_TIPO == 'S'
							nBaseISS  += WSFT->FT_BASEICM
							nValISS   += WSFT->FT_VALICM
							nAliqISS  := WSFT->FT_ALIQICM
						Endif
						dbSkip()
					Enddo

					dbCloseArea()

					/*
					If SF2->F2_VALIRRF == 0
						nValIRRF := 0
					Endif

					lTemImp := .F.
					SE1->(dbSetOrder(2))
					SE1->(dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)))
					While SE1->(!Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and.;
					   		SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
						If SE1->E1_TIPO == 'CF-'
							nValCOFR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'PI-'
							nValPISR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'CS-'
							nValCSLR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'IR-'
							nValIRRF := SE1->E1_VALOR
						Endif
						SE1->(dbSkip())
					Enddo

					If !lTemImp
						nValPISR := 0
						nValCOFR := 0
						nValCSLR := 0
					Else
						If nValCont > 0
							nAux1    := Round(nValCont/WSF2->F2_VALBRUT,5)
							nValPISR := Round(nAux1*nValPISR,2)
							nValCOFR := Round(nAux1*nValCOFR,2)
							nValCSLR := Round(nAux1*nValCSLR,2)
							nValIRRF := Round(nAux1*nValIRRF,2)
						Endif
					Endif
					*/

					If nValCont > 0

						//nTamLin := 665
						//nTamLin := 668
						nTamLin := 677
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cLin := Stuff(cLin,03,11,StrZero(0,11))								// Num. Documento Mov. Princ.
						If !Empty(SD2->D2_ZZCC)
							SZ0->(dbSetOrder(1))
							SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
							cCpo1 := Right(SZ0->Z0_CCUSTO,2)
							cCpo2 := SZ0->Z0_LOGICA
						Else
							cCpo1 := Space(02)
							cCpo2 := Space(04)
						Endif
						cLin := Stuff(cLin,14,02,cCpo1)						// Centro de custo
						If Substr(SD2->D2_CF,2,3) $ "949/913/908/909"
							//cCpo2 := "R051"
							cCpo2 := "R057"
						ElseIf Substr(SD2->D2_CF,2,3) = "915"
							cCpo2 := "R052"
						Endif
						cLin := Stuff(cLin,16,04,cCpo2)									// Conta Contabil
						cLin := Stuff(cLin,20,06,Transform(SD2->D2_CF,"@R 9.999X"))	// Codigo Fiscal
						cCpo := StrZero(nValCont,12,2)
						cLin := Stuff(cLin,26,12,StrTran(cCpo,".",","))					// Valor Contabil
						If nValISS > 0
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,4)
							cLin := Stuff(cLin,38,12,StrTran(cCpo1,".",","))			// Base do ICMS
							cLin := Stuff(cLin,50,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
							cLin := Stuff(cLin,57,12,StrTran(cCpo1,".",","))			// Valor do ICMS
							cLin := Stuff(cLin,69,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cLin := Stuff(cLin,93,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
							cLin := Stuff(cLin,105,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
							cLin := Stuff(cLin,112,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
							cLin := Stuff(cLin,124,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
							cLin := Stuff(cLin,136,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
							cLin := Stuff(cLin,143,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
							cLin := Stuff(cLin,155,12,StrTran(cCpo1,".",","))			// INSS Retido
							cLin := Stuff(cLin,167,12,StrTran(cCpo1,".",","))			// Valor Base IPI
							cLin := Stuff(cLin,179,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
							cLin := Stuff(cLin,186,12,StrTran(cCpo1,".",","))			// Valor IPI
							cLin := Stuff(cLin,198,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
							cLin := Stuff(cLin,210,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
						Else
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,38,12,StrTran(cCpo,".",","))			// Base do ICMS
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,50,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,57,12,StrTran(cCpo,".",","))			// Valor do ICMS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,69,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
							If nOutrICMS > 0
								cCpo := StrZero(nOutrICMS,12,2)
							Else
								If nValICMS > 0
									cCpo := StrZero(0,12,2)
								Else
									cCpo := StrZero(nValCont,12,2)
								Endif
							Endif
							cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,93,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
							//cCpo := StrZero(GetMV("MV_ICMPAD"),7,4)
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,105,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,112,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
							cCpo := StrZero(nBaseRet,12,2)
							cLin := Stuff(cLin,124,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,136,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
							cCpo := StrZero(nICMSRet,12,2)
							cLin := Stuff(cLin,143,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,155,12,StrTran(cCpo,".",","))			// INSS Retido
							cCpo := StrZero(nBaseIPI,12,2)
							cLin := Stuff(cLin,167,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,179,07,StrTran(cCpo,".",","))			// Alíquota do IPI
							cCpo := StrZero(nValIPI,12,2)
							cLin := Stuff(cLin,186,12,StrTran(cCpo,".",","))			// Valor IPI
							cCpo := StrZero(nIsenIPI,12,2)
							cLin := Stuff(cLin,198,12,StrTran(cCpo,".",","))			// Valor Isento IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,210,12,StrTran(cCpo,".",","))			// Valor Outras IPI
						Endif
						cCpo := StrZero(0,12,2)
						cLin := Stuff(cLin,222,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
						cCpo := StrZero(0,12,2)
						cLin := Stuff(cLin,234,01,"0")								// Exportar DNF
						cCpo := StrZero(Val(WSF2->F2_DOC),9)
						cLin := Stuff(cLin,235,18,cCpo+cCpo)						// Controle Interno
						cLin := Stuff(cLin,253,09,Space(09))						// Modelo de Transporte
						cLin := Stuff(cLin,262,04,Space(04))						// Série de Transporte
						cLin := Stuff(cLin,266,06,Space(06))						// Nº da Nota de Transporte
						cLin := Stuff(cLin,272,10,Space(10))						// Data de Emissão
						cLin := Stuff(cLin,282,02,Space(02))						// UF de Transporte
						cCpo := StrZero(0,18)
						cLin := Stuff(cLin,284,18,cCpo)								// CNPJ
						cLin := Stuff(cLin,302,19,Space(19))						// Inscrição Estadual
						cCpo := StrZero(0,16)
						cLin := Stuff(cLin,321,16,cCpo)								// Total do Transporte
						cLin := Stuff(cLin,337,01,"0")								// Modalidade do Frete
						cLin := Stuff(cLin,338,03,"000") 							// Cód. Observação
						cLin := Stuff(cLin,341,250,Space(250)) 					// Complemento Observação
						cLin := Stuff(cLin,591,01,"0")			 					// Subst. Trib. Ref. Petróleo
						cLin := Stuff(cLin,592,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
						cLin := Stuff(cLin,593,02,Space(02))	 					// UF de Início da Operação
						If cTipoCF $ "FRLS"
							cCpo := "1"
						ElseIf cTipoCF == "X"
							cCpo := "3"
						Else
							cCpo := "4"
						Endif
						cLin := Stuff(cLin,595,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
						cCpo := StrZero(0,7,4)
						cLin := Stuff(cLin,596,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
						cLin := Stuff(cLin,603,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
						If WSF2->F2_EST == "EX"
							cCpo := "6"
						Else
							cCpo := " "
						Endif
						cLin := Stuff(cLin,610,01,cCpo)								// Código Antecipação Subs.Trib.
						cCpo := StrZero(nDespesa,14,2)
						cLin := Stuff(cLin,611,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
						cLin := Stuff(cLin,625,10,"00/00/0000")					// Data da Exportação
						cCpo := StrZero(0,15)
						cLin := Stuff(cLin,635,15,cCpo)								// Registro de Exportação
						cCpo := StrZero(0,12)
						cLin := Stuff(cLin,650,12,cCpo)								// Número Despacho de Exportação
						cLin := Stuff(cLin,662,03,StrZero(nQtdCFO,3))			// Quantidade Itens Desdobramento
						cLin := Stuff(cLin,665,01,"0")								// Oper.Combustível/Solv(GRF-CBT)
						cLin := Stuff(cLin,666,03,"000")							// Classificação Lançto. na DACON
						cLin := Stuff(cLin,669,06,"000000")							// Informar a quantidade de itens do desdobramento quando for maior que 999
						cLin := Stuff(cLin,675,03,SD2->D2_CLASFIS)					// CST do ICMS
						cLin += _cEOL

						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
								fClose(nHdl)
								Return
							Endif
						Endif

					Else

						//nTamLin := 665
						nTamLin := 668
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cLin := Stuff(cLin,03,11,StrZero(0,11))					// Num. Documento Mov. Princ.
						If !Empty(SD2->D2_ZZCC)
							SZ0->(dbSetOrder(1))
							SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
							cCpo1 := Right(SZ0->Z0_CCUSTO,2)
							cCpo2 := SZ0->Z0_LOGICA
						Else
							cCpo1 := Space(02)
							cCpo2 := Space(04)
						Endif
						cLin := Stuff(cLin,14,02,cCpo1)						// Centro de custo
						If Substr(SD2->D2_CF,2,3) $ "949/913/908/909"
							//cCpo2 := "R051"
							cCpo2 := "R057"
						ElseIf Substr(SD2->D2_CF,2,3) = "915"
							cCpo2 := "R052"
						Endif
						cLin := Stuff(cLin,16,04,cCpo2)								// Conta Contabil
						cLin := Stuff(cLin,20,06,Transform(SD2->D2_CF,"@R 9.999X"))	// Codigo Fiscal
						cCpo1:= StrZero(0,12,2)
						cCpo2:= StrZero(0,7,4)
						cCpo := StrZero(WSF2->F2_VALBRUT,12,2)
						cLin := Stuff(cLin,26,12,StrTran(cCpo,".",","))		  	// Valor Contabil
						cLin := Stuff(cLin,38,12,StrTran(cCpo1,".",","))			// Base do ICMS
						cLin := Stuff(cLin,50,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
						cLin := Stuff(cLin,57,12,StrTran(cCpo1,".",","))			// Valor do ICMS
						cLin := Stuff(cLin,69,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
						cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))				// Valor do ICMS Outros
						cLin := Stuff(cLin,93,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
						cLin := Stuff(cLin,105,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
						cLin := Stuff(cLin,112,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
						cLin := Stuff(cLin,124,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
						cLin := Stuff(cLin,136,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
						cLin := Stuff(cLin,143,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
						cLin := Stuff(cLin,155,12,StrTran(cCpo1,".",","))			// INSS Retido
						cLin := Stuff(cLin,167,12,StrTran(cCpo1,".",","))			// Valor Base IPI
						cLin := Stuff(cLin,179,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
						cLin := Stuff(cLin,186,12,StrTran(cCpo1,".",","))			// Valor IPI
						cLin := Stuff(cLin,198,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
						cLin := Stuff(cLin,210,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
						cLin := Stuff(cLin,222,12,StrTran(cCpo1,".",","))			// Valor Diversos IPI
						cLin := Stuff(cLin,234,01,"0")								// Exportar DNF
						cCpo := StrZero(Val(WSF2->F2_DOC),9)
						cLin := Stuff(cLin,235,18,cCpo+cCpo)						// Controle Interno
						cLin := Stuff(cLin,253,09,Space(09))						// Modelo de Transporte
						cLin := Stuff(cLin,262,04,Space(04))						// Série de Transporte
						cLin := Stuff(cLin,266,06,Space(06))						// Nº da Nota de Transporte
						cLin := Stuff(cLin,272,10,Space(10))						// Data de Emissão
						cLin := Stuff(cLin,282,02,Space(02))								// UF de Transporte
						cCpo := StrZero(0,18)
						cLin := Stuff(cLin,284,18,cCpo)								// CNPJ
						cLin := Stuff(cLin,302,19,Space(19))						// Inscrição Estadual
						cCpo := StrZero(0,16,2)
						cLin := Stuff(cLin,321,16,StrTran(cCpo,".",","))			// Total do Transporte
						cCpo := StrZero(0,16)
						cLin := Stuff(cLin,337,01,"0")								// Modalidade do Frete
						cLin := Stuff(cLin,338,03,"000") 							// Cód. Observação --> usar 090 qdo a nota for cancelada
						cLin := Stuff(cLin,341,250,Space(250)) 					// Complemento Observação
						cLin := Stuff(cLin,591,01,"0")			 					// Subst. Trib. Ref. Petróleo
						cLin := Stuff(cLin,592,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
						cLin := Stuff(cLin,593,02,Space(02))	 					// UF de Início da Operação
						cLin := Stuff(cLin,595,01," ")								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
						cLin := Stuff(cLin,596,07,StrTran(cCpo2,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
						cLin := Stuff(cLin,603,07,StrTran(cCpo2,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
						cLin := Stuff(cLin,610,01," ")								// Código Antecipação Subs.Trib.
						cCpo := StrZero(0,14,2)
						cLin := Stuff(cLin,611,14,StrTran(cCpo,".",","))			// Valor das Despesas Acessórias
						cLin := Stuff(cLin,625,10,"00/00/0000")						// Data da Exportação
						cCpo := StrZero(0,15)
						cLin := Stuff(cLin,635,15,cCpo)								// Registro de Exportação
						cCpo := StrZero(0,12)
						cLin := Stuff(cLin,650,12,cCpo)								// Número Despacho de Exportação
						cLin := Stuff(cLin,662,03,StrZero(nQtdCFO,3))				// Quantidade Itens Desdobramento
						cLin := Stuff(cLin,665,01,"0")								// Oper.Combustível/Solv(GRF-CBT)
						cLin := Stuff(cLin,666,03,"000")							// Classificação Lançto. na DACON
						cLin := Stuff(cLin,669,06,"000000")							// Informar a quantidade de itens do desdobramento quando for maior que 999
						cLin := Stuff(cLin,675,03,SD2->D2_CLASFIS)					// CST do ICMS
						cLin += _cEOL

						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
								Exit
							Endif
						Endif

					Endif

				Endif

			Elseif cQualDesd == 'cc'	// por centro de custo

				If SD2->D2_ZZCC <> cCCAnt

					cCCAnt  := SD2->D2_ZZCC
					nPos    := aScan(aCCusto, {|x| x[1] == SD2->D2_ZZCC})
					nQtdCC := aCCusto[nPos][2]

					cQuery := ""
					cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
					cQuery += "WHERE "
					cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
					cQuery += "SFT.FT_TIPOMOV = 'S' AND "
					cQuery += "SFT.FT_SERIE = '"  +SD2->D2_SERIE+"' AND "
					cQuery += "SFT.FT_NFISCAL = '"+SD2->D2_DOC+"' AND "
					cQuery += "SFT.FT_CLIEFOR = '"+SD2->D2_CLIENTE+"' AND "
					cQuery += "SFT.FT_LOJA = '"   +SD2->D2_LOJA+"' AND "
					cQuery += "RTRIM(SFT.FT_ZZCC) = '"   +cCCAnt+"' AND "
					cQuery += "SFT.D_E_L_E_T_ <> '*'"

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
					aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

					cCodISS   := ""
					nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
					nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
					nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
					nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
					nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

					dbSelectArea("WSFT")
					dbGoTop()
					While !Eof()
						nValCont  += WSFT->FT_VALCONT
						nBaseICMS += WSFT->FT_BASEICM
						nAliqICMS := WSFT->FT_ALIQICM
						nValICMS  += WSFT->FT_VALICM
						nIsenICMS += WSFT->FT_ISENICM
						nOutrICMS += WSFT->FT_OUTRICM
						nBaseRet  += WSFT->FT_BASERET
						nICMSRet  += WSFT->FT_ICMSRET
						nBaseIPI  += WSFT->FT_BASEIPI
						nAliqIPI  := WSFT->FT_ALIQIPI
						nValIPI   += WSFT->FT_VALIPI
						nIsenIPI  += WSFT->FT_ISENIPI
						nDespesa  += WSFT->FT_DESPESA
						cCodISS   := WSFT->FT_CODISS
						nValINSS  += WSFT->FT_VALINS
						nValIRRF  += WSFT->FT_VALIRR
						nValPIS   += WSFT->FT_VALPIS
						nValCOF   += WSFT->FT_VALCOF
						nValCSL   += WSFT->FT_VALCSL
						nValPISR  += WSFT->FT_VRETPIS
						nValCOFR  += WSFT->FT_VRETCOF
						nValCSLR  += WSFT->FT_VRETCSL
						If WSFT->FT_TIPO == 'S'
							nBaseISS  += WSFT->FT_BASEICM
							nValISS   += WSFT->FT_VALICM
							nAliqISS  := WSFT->FT_ALIQICM
						Endif
						dbSkip()
					Enddo

					dbCloseArea()

					/*
					If SF2->F2_VALIRRF == 0
						nValIRRF := 0
					Endif

					lTemImp := .F.
					SE1->(dbSetOrder(2))
					SE1->(dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)))
					While SE1->(!Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and.;
					   		SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
						If SE1->E1_TIPO == 'CF-'
							nValCOFR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'PI-'
							nValPISR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'CS-'
							nValCSLR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'IR-'
							nValIRRF := SE1->E1_VALOR
						Endif
						SE1->(dbSkip())
					Enddo

					If !lTemImp
						nValPISR := 0
						nValCOFR := 0
						nValCSLR := 0
					Else
						If nValCont > 0
							nAux1    := Round(nValCont/WSF2->F2_VALBRUT,5)
							nValPISR := Round(nAux1*nValPISR,2)
							nValCOFR := Round(nAux1*nValCOFR,2)
							nValCSLR := Round(nAux1*nValCSLR,2)
							nValIRRF := Round(nAux1*nValIRRF,2)
						Endif
					Endif
                    */

					If nValCont > 0

						//nTamLin := 665
						//nTamLin := 668
						nTamLin := 677
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cLin := Stuff(cLin,03,11,StrZero(0,11))								// Num. Documento Mov. Princ.
						If !Empty(SD2->D2_ZZCC)
							SZ0->(dbSetOrder(1))
							SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
							cCpo1 := Right(SZ0->Z0_CCUSTO,2)
							cCpo2 := SZ0->Z0_LOGICA
						Else
							cCpo1 := Space(02)
							cCpo2 := Space(04)
						Endif
						cLin := Stuff(cLin,14,02,cCpo1)						// Centro de custo
						If Substr(SD2->D2_CF,2,3) $ "949/913/908/909"
							//cCpo2 := "R051"
							cCpo2 := "R057"
						ElseIf Substr(SD2->D2_CF,2,3) = "915"
							cCpo2 := "R052"
						Endif
						cLin := Stuff(cLin,16,04,cCpo2)									// Conta Contabil
						cLin := Stuff(cLin,20,06,Transform(SD2->D2_CF,"@R 9.999X"))	// Codigo Fiscal
						cCpo := StrZero(nValCont,12,2)
						cLin := Stuff(cLin,26,12,StrTran(cCpo,".",","))					// Valor Contabil
						If nValISS > 0
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,4)
							cLin := Stuff(cLin,38,12,StrTran(cCpo1,".",","))			// Base do ICMS
							cLin := Stuff(cLin,50,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
							cLin := Stuff(cLin,57,12,StrTran(cCpo1,".",","))			// Valor do ICMS
							cLin := Stuff(cLin,69,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cLin := Stuff(cLin,93,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
							cLin := Stuff(cLin,105,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
							cLin := Stuff(cLin,112,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
							cLin := Stuff(cLin,124,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
							cLin := Stuff(cLin,136,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
							cLin := Stuff(cLin,143,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
							cLin := Stuff(cLin,155,12,StrTran(cCpo1,".",","))			// INSS Retido
							cLin := Stuff(cLin,167,12,StrTran(cCpo1,".",","))			// Valor Base IPI
							cLin := Stuff(cLin,179,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
							cLin := Stuff(cLin,186,12,StrTran(cCpo1,".",","))			// Valor IPI
							cLin := Stuff(cLin,198,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
							cLin := Stuff(cLin,210,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
						Else
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,38,12,StrTran(cCpo,".",","))			// Base do ICMS
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,50,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,57,12,StrTran(cCpo,".",","))			// Valor do ICMS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,69,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
							If nOutrICMS > 0
								cCpo := StrZero(nOutrICMS,12,2)
							Else
								If nValICMS > 0
									cCpo := StrZero(0,12,2)
								Else
									cCpo := StrZero(nValCont,12,2)
								Endif
							Endif
							cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,93,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
							//cCpo := StrZero(GetMV("MV_ICMPAD"),7,4)
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,105,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,112,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
							cCpo := StrZero(nBaseRet,12,2)
							cLin := Stuff(cLin,124,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,136,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
							cCpo := StrZero(nICMSRet,12,2)
							cLin := Stuff(cLin,143,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,155,12,StrTran(cCpo,".",","))			// INSS Retido
							cCpo := StrZero(nBaseIPI,12,2)
							cLin := Stuff(cLin,167,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,179,07,StrTran(cCpo,".",","))			// Alíquota do IPI
							cCpo := StrZero(nValIPI,12,2)
							cLin := Stuff(cLin,186,12,StrTran(cCpo,".",","))			// Valor IPI
							cCpo := StrZero(nIsenIPI,12,2)
							cLin := Stuff(cLin,198,12,StrTran(cCpo,".",","))			// Valor Isento IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,210,12,StrTran(cCpo,".",","))			// Valor Outras IPI
						Endif
						cCpo := StrZero(0,12,2)
						cLin := Stuff(cLin,222,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
						cCpo := StrZero(0,12,2)
						cLin := Stuff(cLin,234,01,"0")								// Exportar DNF
						cCpo := StrZero(Val(WSF2->F2_DOC),9)
						cLin := Stuff(cLin,235,18,cCpo+cCpo)						// Controle Interno
						cLin := Stuff(cLin,253,09,Space(09))						// Modelo de Transporte
						cLin := Stuff(cLin,262,04,Space(04))						// Série de Transporte
						cLin := Stuff(cLin,266,06,Space(06))						// Nº da Nota de Transporte
						cLin := Stuff(cLin,272,10,Space(10))						// Data de Emissão
						cLin := Stuff(cLin,282,02,Space(02))						// UF de Transporte
						cCpo := StrZero(0,18)
						cLin := Stuff(cLin,284,18,cCpo)								// CNPJ
						cLin := Stuff(cLin,302,19,Space(19))						// Inscrição Estadual
						cCpo := StrZero(0,16)
						cLin := Stuff(cLin,321,16,cCpo)								// Total do Transporte
						cLin := Stuff(cLin,337,01,"0")								// Modalidade do Frete
						cLin := Stuff(cLin,338,03,"000") 							// Cód. Observação
						cLin := Stuff(cLin,341,250,Space(250)) 					// Complemento Observação
						cLin := Stuff(cLin,591,01,"0")			 					// Subst. Trib. Ref. Petróleo
						cLin := Stuff(cLin,592,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
						cLin := Stuff(cLin,593,02,Space(02))	 					// UF de Início da Operação
						If cTipoCF $ "FRLS"
							cCpo := "1"
						ElseIf cTipoCF == "X"
							cCpo := "3"
						Else
							cCpo := "4"
						Endif
						cLin := Stuff(cLin,595,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
						cCpo := StrZero(0,7,4)
						cLin := Stuff(cLin,596,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
						cLin := Stuff(cLin,603,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
						If WSF2->F2_EST == "EX"
							cCpo := "6"
						Else
							cCpo := " "
						Endif
						cLin := Stuff(cLin,610,01,cCpo)								// Código Antecipação Subs.Trib.
						cCpo := StrZero(nDespesa,14,2)
						cLin := Stuff(cLin,611,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
						cLin := Stuff(cLin,625,10,"00/00/0000")					// Data da Exportação
						cCpo := StrZero(0,15)
						cLin := Stuff(cLin,635,15,cCpo)								// Registro de Exportação
						cCpo := StrZero(0,12)
						cLin := Stuff(cLin,650,12,cCpo)								// Número Despacho de Exportação
						cLin := Stuff(cLin,662,03,StrZero(nQtdCC,3))			// Quantidade Itens Desdobramento
						cLin := Stuff(cLin,665,01,"0")								// Oper.Combustível/Solv(GRF-CBT)
						cLin := Stuff(cLin,666,03,"000")							// Classificação Lançto. na DACON
						cLin := Stuff(cLin,669,06,"000000")							// Informar a quantidade de itens do desdobramento quando for maior que 999
						cLin := Stuff(cLin,675,03,SD2->D2_CLASFIS)					// CST do ICMS
						cLin += _cEOL

						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
								fClose(nHdl)
								Return
							Endif
						Endif

					Else

						//nTamLin := 665
						nTamLin := 668
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cLin := Stuff(cLin,03,11,StrZero(0,11))					// Num. Documento Mov. Princ.
						If !Empty(SD2->D2_ZZCC)
							SZ0->(dbSetOrder(1))
							SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
							cCpo1 := Right(SZ0->Z0_CCUSTO,2)
							cCpo2 := SZ0->Z0_LOGICA
						Else
							cCpo1 := Space(02)
							cCpo2 := Space(04)
						Endif
						cLin := Stuff(cLin,14,02,cCpo1)						// Centro de custo
						If Substr(SD2->D2_CF,2,3) $ "949/913/908/909"
							//cCpo2 := "R051"
							cCpo2 := "R057"
						ElseIf Substr(SD2->D2_CF,2,3) = "915"
							cCpo2 := "R052"
						Endif
						cLin := Stuff(cLin,16,04,cCpo2)								// Conta Contabil
						cLin := Stuff(cLin,20,06,Transform(SD2->D2_CF,"@R 9.999X"))	// Codigo Fiscal
						cCpo1:= StrZero(0,12,2)
						cCpo2:= StrZero(0,7,4)
						cCpo := StrZero(WSF2->F2_VALBRUT,12,2)
						cLin := Stuff(cLin,26,12,StrTran(cCpo,".",","))		  	// Valor Contabil
						cLin := Stuff(cLin,38,12,StrTran(cCpo1,".",","))			// Base do ICMS
						cLin := Stuff(cLin,50,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
						cLin := Stuff(cLin,57,12,StrTran(cCpo1,".",","))			// Valor do ICMS
						cLin := Stuff(cLin,69,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
						cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))				// Valor do ICMS Outros
						cLin := Stuff(cLin,93,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
						cLin := Stuff(cLin,105,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
						cLin := Stuff(cLin,112,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
						cLin := Stuff(cLin,124,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
						cLin := Stuff(cLin,136,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
						cLin := Stuff(cLin,143,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
						cLin := Stuff(cLin,155,12,StrTran(cCpo1,".",","))			// INSS Retido
						cLin := Stuff(cLin,167,12,StrTran(cCpo1,".",","))			// Valor Base IPI
						cLin := Stuff(cLin,179,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
						cLin := Stuff(cLin,186,12,StrTran(cCpo1,".",","))			// Valor IPI
						cLin := Stuff(cLin,198,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
						cLin := Stuff(cLin,210,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
						cLin := Stuff(cLin,222,12,StrTran(cCpo1,".",","))			// Valor Diversos IPI
						cLin := Stuff(cLin,234,01,"0")								// Exportar DNF
						cCpo := StrZero(Val(WSF2->F2_DOC),9)
						cLin := Stuff(cLin,235,18,cCpo+cCpo)						// Controle Interno
						cLin := Stuff(cLin,253,09,Space(09))						// Modelo de Transporte
						cLin := Stuff(cLin,262,04,Space(04))						// Série de Transporte
						cLin := Stuff(cLin,266,06,Space(06))						// Nº da Nota de Transporte
						cLin := Stuff(cLin,272,10,Space(10))						// Data de Emissão
						cLin := Stuff(cLin,282,02,Space(02))								// UF de Transporte
						cCpo := StrZero(0,18)
						cLin := Stuff(cLin,284,18,cCpo)								// CNPJ
						cLin := Stuff(cLin,302,19,Space(19))						// Inscrição Estadual
						cCpo := StrZero(0,16,2)
						cLin := Stuff(cLin,321,16,StrTran(cCpo,".",","))			// Total do Transporte
						cCpo := StrZero(0,16)
						cLin := Stuff(cLin,337,01,"0")								// Modalidade do Frete
						cLin := Stuff(cLin,338,03,"000") 							// Cód. Observação --> usar 090 qdo a nota for cancelada
						cLin := Stuff(cLin,341,250,Space(250)) 					// Complemento Observação
						cLin := Stuff(cLin,591,01,"0")			 					// Subst. Trib. Ref. Petróleo
						cLin := Stuff(cLin,592,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
						cLin := Stuff(cLin,593,02,Space(02))	 					// UF de Início da Operação
						cLin := Stuff(cLin,595,01," ")								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
						cLin := Stuff(cLin,596,07,StrTran(cCpo2,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
						cLin := Stuff(cLin,603,07,StrTran(cCpo2,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
						cLin := Stuff(cLin,610,01," ")								// Código Antecipação Subs.Trib.
						cCpo := StrZero(0,14,2)
						cLin := Stuff(cLin,611,14,StrTran(cCpo,".",","))			// Valor das Despesas Acessórias
						cLin := Stuff(cLin,625,10,"00/00/0000")						// Data da Exportação
						cCpo := StrZero(0,15)
						cLin := Stuff(cLin,635,15,cCpo)								// Registro de Exportação
						cCpo := StrZero(0,12)
						cLin := Stuff(cLin,650,12,cCpo)								// Número Despacho de Exportação
						cLin := Stuff(cLin,662,03,StrZero(nQtdCC,3))				// Quantidade Itens Desdobramento
						cLin := Stuff(cLin,665,01,"0")								// Oper.Combustível/Solv(GRF-CBT)
						cLin := Stuff(cLin,666,03,"000")							// Classificação Lançto. na DACON
						cLin := Stuff(cLin,669,06,"000000")							// Informar a quantidade de itens do desdobramento quando for maior que 999
						cLin := Stuff(cLin,675,03,SD2->D2_CLASFIS)					// CST do ICMS
						cLin += _cEOL

						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
								Exit
							Endif
						Endif

					Endif

				Endif

			Else		// por conta contabil

				If SD2->D2_CONTA <> cContAnt

					cContAnt  := SD2->D2_CONTA
					nPos      := aScan(aConta, {|x| x[1] == SD2->D2_CONTA})
					nQtdConta := aConta[nPos][2]

					cQuery := ""
					cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
					cQuery += "WHERE "
					cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
					cQuery += "SFT.FT_TIPOMOV = 'S' AND "
					cQuery += "SFT.FT_SERIE = '"  +SD2->D2_SERIE+"' AND "
					cQuery += "SFT.FT_NFISCAL = '"+SD2->D2_DOC+"' AND "
					cQuery += "SFT.FT_CLIEFOR = '"+SD2->D2_CLIENTE+"' AND "
					cQuery += "SFT.FT_LOJA = '"   +SD2->D2_LOJA+"' AND "
					cQuery += "SFT.FT_CONTA = '"  +cContAnt+"' AND "
					cQuery += "SFT.D_E_L_E_T_ <> '*'"

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
					aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

					cCodISS   := ""
					nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
					nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
					nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
					nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
					nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

					dbSelectArea("WSFT")
					dbGoTop()
					While !Eof()
						nValCont  += WSFT->FT_VALCONT
						nBaseICMS += WSFT->FT_BASEICM
						nAliqICMS := WSFT->FT_ALIQICM
						nValICMS  += WSFT->FT_VALICM
						nIsenICMS += WSFT->FT_ISENICM
						nOutrICMS += WSFT->FT_OUTRICM
						nBaseRet  += WSFT->FT_BASERET
						nICMSRet  += WSFT->FT_ICMSRET
						nBaseIPI  += WSFT->FT_BASEIPI
						nAliqIPI  := WSFT->FT_ALIQIPI
						nValIPI   += WSFT->FT_VALIPI
						nIsenIPI  += WSFT->FT_ISENIPI
						nDespesa  += WSFT->FT_DESPESA
						cCodISS   := WSFT->FT_CODISS
						nValINSS  += WSFT->FT_VALINS
						nValIRRF  += WSFT->FT_VALIRR
						nValPIS   += WSFT->FT_VALPIS
						nValCOF   += WSFT->FT_VALCOF
						nValCSL   += WSFT->FT_VALCSL
						nValPISR  += WSFT->FT_VRETPIS
						nValCOFR  += WSFT->FT_VRETCOF
						nValCSLR  += WSFT->FT_VRETCSL
						If WSFT->FT_TIPO == 'S'
							nBaseISS  += WSFT->FT_BASEICM
							nValISS   += WSFT->FT_VALICM
							nAliqISS  := WSFT->FT_ALIQICM
						Endif
						dbSkip()
					Enddo

					dbCloseArea()

					If SF2->F2_VALIRRF == 0
						nValIRRF := 0
					Endif

					lTemImp := .F.
					SE1->(dbSetOrder(2))
					SE1->(dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)))
					While SE1->(!Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and.;
					   		SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

					   If SE1->E1_TIPO == "NF "

					   		nValPISR  += iif(SE1->E1_PIS>=nRetPis,SE1->E1_PIS,0)
					   		nValCOFIR += iif(SE1->E1_COFINS>=nRetCof,SE1->E1_COFINS,0)
					   		nValCSLLR += iif(SE1->E1_CSLL>=nRetCsl,SE1->E1_CSLL,0)

						elseIf SE1->E1_TIPO == 'CF-'
							nValCOFR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'PI-'
							nValPISR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'CS-'
							nValCSLR := SE1->E1_VALOR
							lTemImp := .T.
						Endif
						If SE1->E1_TIPO == 'IR-'
							nValIRRF := SE1->E1_VALOR
						Endif
						SE1->(dbSkip())
					Enddo

					If !lTemImp
						nValPISR := 0
						nValCOFR := 0
						nValCSLR := 0
					Else
						If nValCont > 0
							nAux1    := Round(nValCont/WSF2->F2_VALBRUT,5)
							nValPISR := Round(nAux1*nValPISR,2)
							nValCOFR := Round(nAux1*nValCOFR,2)
							nValCSLR := Round(nAux1*nValCSLR,2)
							nValIRRF := Round(nAux1*nValIRRF,2)
						Endif
					Endif

					If nValCont > 0

						//nTamLin := 665
						//nTamLin := 668
						nTamLin := 677
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cLin := Stuff(cLin,03,11,StrZero(0,11))								// Num. Documento Mov. Princ.
						If !Empty(SD2->D2_ZZCC)
							SZ0->(dbSetOrder(1))
							SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
							cCpo1 := Right(SZ0->Z0_CCUSTO,2)
							cCpo2 := SZ0->Z0_LOGICA
						Else
							cCpo1 := Space(02)
							cCpo2 := Space(04)
						Endif
						cLin := Stuff(cLin,14,02,cCpo1)						// Centro de custo
						If Substr(SD2->D2_CF,2,3) $ "949/913/908/909"
							//cCpo2 := "R051"
							cCpo2 := "R057"
						ElseIf Substr(SD2->D2_CF,2,3) = "915"
							cCpo2 := "R052"
						Endif
						cLin := Stuff(cLin,16,04,cCpo2)									// Conta Contabil
						cLin := Stuff(cLin,20,06,Transform(SD2->D2_CF,"@R 9.999X"))	// Codigo Fiscal
						cCpo := StrZero(nValCont,12,2)
						cLin := Stuff(cLin,26,12,StrTran(cCpo,".",","))					// Valor Contabil
						If nValISS > 0
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,4)
							cLin := Stuff(cLin,38,12,StrTran(cCpo1,".",","))			// Base do ICMS
							cLin := Stuff(cLin,50,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
							cLin := Stuff(cLin,57,12,StrTran(cCpo1,".",","))			// Valor do ICMS
							cLin := Stuff(cLin,69,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cLin := Stuff(cLin,93,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
							cLin := Stuff(cLin,105,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
							cLin := Stuff(cLin,112,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
							cLin := Stuff(cLin,124,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
							cLin := Stuff(cLin,136,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
							cLin := Stuff(cLin,143,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
							cLin := Stuff(cLin,155,12,StrTran(cCpo1,".",","))			// INSS Retido
							cLin := Stuff(cLin,167,12,StrTran(cCpo1,".",","))			// Valor Base IPI
							cLin := Stuff(cLin,179,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
							cLin := Stuff(cLin,186,12,StrTran(cCpo1,".",","))			// Valor IPI
							cLin := Stuff(cLin,198,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
							cLin := Stuff(cLin,210,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
						Else
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,38,12,StrTran(cCpo,".",","))			// Base do ICMS
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,50,07,StrTran(cCpo,".",","))			// Aliquota do ICMS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,57,12,StrTran(cCpo,".",","))			// Valor do ICMS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,69,12,StrTran(cCpo,".",","))			// Valor do ICMS Isento
							If nOutrICMS > 0
								cCpo := StrZero(nOutrICMS,12,2)
							Else
								If nValICMS > 0
									cCpo := StrZero(0,12,2)
								Else
									cCpo := StrZero(nValCont,12,2)
								Endif
							Endif
							cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))			// Valor do ICMS Outros
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,93,12,StrTran(cCpo,".",","))			// Valor do ICMS Diversos
							//cCpo := StrZero(GetMV("MV_ICMPAD"),7,4)
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,105,07,StrTran(cCpo,".",","))			// Aliquota interna do ICMS
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,112,12,StrTran(cCpo,".",","))			// Valor do Imposto Aliquota Interna
							cCpo := StrZero(nBaseRet,12,2)
							cLin := Stuff(cLin,124,12,StrTran(cCpo,".",","))			// Valor Base Subs. Tributária
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,136,07,StrTran(cCpo,".",","))			// Alíquota Subst. Tributária
							cCpo := StrZero(nICMSRet,12,2)
							cLin := Stuff(cLin,143,12,StrTran(cCpo,".",","))			// Valor Imp. subs. Tributária
							cCpo := StrZero(nValINSS,12,2)
							cLin := Stuff(cLin,155,12,StrTran(cCpo,".",","))			// INSS Retido
							cCpo := StrZero(nBaseIPI,12,2)
							cLin := Stuff(cLin,167,12,StrTran(cCpo,".",","))			// Valor Base IPI
							cCpo := StrZero(0,7,4)
							cLin := Stuff(cLin,179,07,StrTran(cCpo,".",","))			// Alíquota do IPI
							cCpo := StrZero(nValIPI,12,2)
							cLin := Stuff(cLin,186,12,StrTran(cCpo,".",","))			// Valor IPI
							cCpo := StrZero(nIsenIPI,12,2)
							cLin := Stuff(cLin,198,12,StrTran(cCpo,".",","))			// Valor Isento IPI
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,210,12,StrTran(cCpo,".",","))			// Valor Outras IPI
						Endif
						cCpo := StrZero(0,12,2)
						cLin := Stuff(cLin,222,12,StrTran(cCpo,".",","))			// Valor Diversos IPI
						cCpo := StrZero(0,12,2)
						cLin := Stuff(cLin,234,01,"0")								// Exportar DNF
						cCpo := StrZero(Val(WSF2->F2_DOC),9)
						cLin := Stuff(cLin,235,18,cCpo+cCpo)						// Controle Interno
						cLin := Stuff(cLin,253,09,Space(09))						// Modelo de Transporte
						cLin := Stuff(cLin,262,04,Space(04))						// Série de Transporte
						cLin := Stuff(cLin,266,06,Space(06))						// Nº da Nota de Transporte
						cLin := Stuff(cLin,272,10,Space(10))						// Data de Emissão
						cLin := Stuff(cLin,282,02,Space(02))						// UF de Transporte
						cCpo := StrZero(0,18)
						cLin := Stuff(cLin,284,18,cCpo)								// CNPJ
						cLin := Stuff(cLin,302,19,Space(19))						// Inscrição Estadual
						cCpo := StrZero(0,16)
						cLin := Stuff(cLin,321,16,cCpo)								// Total do Transporte
						cLin := Stuff(cLin,337,01,"0")								// Modalidade do Frete
						cLin := Stuff(cLin,338,03,"000") 							// Cód. Observação
						cLin := Stuff(cLin,341,250,Space(250)) 					// Complemento Observação
						cLin := Stuff(cLin,591,01,"0")			 					// Subst. Trib. Ref. Petróleo
						cLin := Stuff(cLin,592,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
						cLin := Stuff(cLin,593,02,Space(02))	 					// UF de Início da Operação
						If cTipoCF $ "FRLS"
							cCpo := "1"
						ElseIf cTipoCF == "X"
							cCpo := "3"
						Else
							cCpo := "4"
						Endif
						cLin := Stuff(cLin,595,01,cCpo)								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
						cCpo := StrZero(0,7,4)
						cLin := Stuff(cLin,596,07,StrTran(cCpo,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
						cLin := Stuff(cLin,603,07,StrTran(cCpo,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
						If WSF2->F2_EST == "EX"
							cCpo := "6"
						Else
							cCpo := " "
						Endif
						cLin := Stuff(cLin,610,01,cCpo)								// Código Antecipação Subs.Trib.
						cCpo := StrZero(nDespesa,14,2)
						cLin := Stuff(cLin,611,14,StrTran(cCpo,".",","))		// Valor das Despesas Acessórias
						cLin := Stuff(cLin,625,10,"00/00/0000")					// Data da Exportação
						cCpo := StrZero(0,15)
						cLin := Stuff(cLin,635,15,cCpo)								// Registro de Exportação
						cCpo := StrZero(0,12)
						cLin := Stuff(cLin,650,12,cCpo)								// Número Despacho de Exportação
						cLin := Stuff(cLin,662,03,StrZero(nQtdConta,3))			// Quantidade Itens Desdobramento
						cLin := Stuff(cLin,665,01,"0")								// Oper.Combustível/Solv(GRF-CBT)
						cLin := Stuff(cLin,666,03,"000")							// Classificação Lançto. na DACON
						cLin := Stuff(cLin,669,06,"000000")							// Informar a quantidade de itens do desdobramento quando for maior que 999
						cLin := Stuff(cLin,675,03,SD2->D2_CLASFIS)					// CST do ICMS
						cLin += _cEOL

						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
								fClose(nHdl)
								Return
							Endif
						Endif

					Else

						//nTamLin := 665
						nTamLin := 668
						cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

						cLin := Stuff(cLin,03,11,StrZero(0,11))					// Num. Documento Mov. Princ.
						If !Empty(SD2->D2_ZZCC)
							SZ0->(dbSetOrder(1))
							SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
							cCpo1 := Right(SZ0->Z0_CCUSTO,2)
							cCpo2 := SZ0->Z0_LOGICA
						Else
							cCpo1 := Space(02)
							cCpo2 := Space(04)
						Endif
						cLin := Stuff(cLin,14,02,cCpo1)						// Centro de custo
						If Substr(SD2->D2_CF,2,3) $ "949/913/908/909"
							//cCpo2 := "R051"
							cCpo2 := "R057"
						ElseIf Substr(SD2->D2_CF,2,3) = "915"
							cCpo2 := "R052"
						Endif
						cLin := Stuff(cLin,16,04,cCpo2)								// Conta Contabil
						cLin := Stuff(cLin,20,06,Transform(SD2->D2_CF,"@R 9.999X"))	// Codigo Fiscal
						cCpo1:= StrZero(0,12,2)
						cCpo2:= StrZero(0,7,4)
						cCpo := StrZero(WSF2->F2_VALBRUT,12,2)
						cLin := Stuff(cLin,26,12,StrTran(cCpo,".",","))		  	// Valor Contabil
						cLin := Stuff(cLin,38,12,StrTran(cCpo1,".",","))			// Base do ICMS
						cLin := Stuff(cLin,50,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
						cLin := Stuff(cLin,57,12,StrTran(cCpo1,".",","))			// Valor do ICMS
						cLin := Stuff(cLin,69,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
						cLin := Stuff(cLin,81,12,StrTran(cCpo,".",","))				// Valor do ICMS Outros
						cLin := Stuff(cLin,93,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
						cLin := Stuff(cLin,105,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
						cLin := Stuff(cLin,112,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
						cLin := Stuff(cLin,124,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
						cLin := Stuff(cLin,136,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
						cLin := Stuff(cLin,143,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
						cLin := Stuff(cLin,155,12,StrTran(cCpo1,".",","))			// INSS Retido
						cLin := Stuff(cLin,167,12,StrTran(cCpo1,".",","))			// Valor Base IPI
						cLin := Stuff(cLin,179,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
						cLin := Stuff(cLin,186,12,StrTran(cCpo1,".",","))			// Valor IPI
						cLin := Stuff(cLin,198,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
						cLin := Stuff(cLin,210,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
						cLin := Stuff(cLin,222,12,StrTran(cCpo1,".",","))			// Valor Diversos IPI
						cLin := Stuff(cLin,234,01,"0")								// Exportar DNF
						cCpo := StrZero(Val(WSF2->F2_DOC),9)
						cLin := Stuff(cLin,235,18,cCpo+cCpo)						// Controle Interno
						cLin := Stuff(cLin,253,09,Space(09))						// Modelo de Transporte
						cLin := Stuff(cLin,262,04,Space(04))						// Série de Transporte
						cLin := Stuff(cLin,266,06,Space(06))						// Nº da Nota de Transporte
						cLin := Stuff(cLin,272,10,Space(10))						// Data de Emissão
						cLin := Stuff(cLin,282,02,Space(02))								// UF de Transporte
						cCpo := StrZero(0,18)
						cLin := Stuff(cLin,284,18,cCpo)								// CNPJ
						cLin := Stuff(cLin,302,19,Space(19))						// Inscrição Estadual
						cCpo := StrZero(0,16,2)
						cLin := Stuff(cLin,321,16,StrTran(cCpo,".",","))			// Total do Transporte
						cCpo := StrZero(0,16)
						cLin := Stuff(cLin,337,01,"0")								// Modalidade do Frete
						cLin := Stuff(cLin,338,03,"000") 							// Cód. Observação --> usar 090 qdo a nota for cancelada
						cLin := Stuff(cLin,341,250,Space(250)) 					// Complemento Observação
						cLin := Stuff(cLin,591,01,"0")			 					// Subst. Trib. Ref. Petróleo
						cLin := Stuff(cLin,592,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
						cLin := Stuff(cLin,593,02,Space(02))	 					// UF de Início da Operação
						cLin := Stuff(cLin,595,01," ")								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
						cLin := Stuff(cLin,596,07,StrTran(cCpo2,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
						cLin := Stuff(cLin,603,07,StrTran(cCpo2,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
						cLin := Stuff(cLin,610,01," ")								// Código Antecipação Subs.Trib.
						cCpo := StrZero(0,14,2)
						cLin := Stuff(cLin,611,14,StrTran(cCpo,".",","))			// Valor das Despesas Acessórias
						cLin := Stuff(cLin,625,10,"00/00/0000")						// Data da Exportação
						cCpo := StrZero(0,15)
						cLin := Stuff(cLin,635,15,cCpo)								// Registro de Exportação
						cCpo := StrZero(0,12)
						cLin := Stuff(cLin,650,12,cCpo)								// Número Despacho de Exportação
						cLin := Stuff(cLin,662,03,StrZero(nQtdConta,3))				// Quantidade Itens Desdobramento
						cLin := Stuff(cLin,665,01,"0")								// Oper.Combustível/Solv(GRF-CBT)
						cLin := Stuff(cLin,666,03,"000")							// Classificação Lançto. na DACON
						cLin := Stuff(cLin,669,06,"000000")							// Informar a quantidade de itens do desdobramento quando for maior que 999
						cLin := Stuff(cLin,675,03,SD2->D2_CLASFIS)					// CST do ICMS
						cLin += _cEOL

						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
								Exit
							Endif
						Endif

					Endif

				Endif

			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Notas de Saida - Itens do Complemento       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//nTamLin := 569
			//nTamLin := 604
			nTamLin := 708
			cLin    := Space(nTamLin)				 // Variavel para criacao da linha do registros para gravacao

			nItemSD2++
			cLin := Stuff(cLin,05,03,StrZero(nItemSD2,3))				// Número Item
			cLin := Stuff(cLin,08,14,Substr(SD2->D2_COD,1,14))			// Código Produto Empresa
			cLin := Stuff(cLin,22,08,Substr(SB1->B1_POSIPI,1,8))		// NCM do Produto
			cLin := Stuff(cLin,30,53,Substr(StrTran(SB1->B1_DESC,chr(9),""),1,53))		// Descrição do Produto
			cLin := Stuff(cLin,83,06,SB1->B1_UM)							// Unidade do Produto
			cCpo := StrZero(SD2->D2_IPI,6,2)
			cLin := Stuff(cLin,89,06,StrTran(cCpo,".",","))				// Alíquota do IPI
			If SD2->D2_BASEISS > 0
				cCpo := StrZero(0,6,2)
			Else
				cCpo := StrZero(SD2->D2_PICM,6,2)
			Endif
			cLin := Stuff(cLin,95,06,StrTran(cCpo,".",","))				// Alíquota de ICMS
			cLin := Stuff(cLin,101,45,Substr(SB5->B5_CEME,1,45))		// Descrição Complementar Produto
			cCpo := Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
			cLin := Stuff(cLin,146,30,Substr(cCpo,1,30))					// Unidade de Medida no DNF
			cCpo := StrZero(SD2->D2_QUANT,15,3)
			cLin := Stuff(cLin,176,15,StrTran(cCpo,".",","))			// Quantidade do Produto
			cCpo := StrZero(0,5)
			cLin := Stuff(cLin,191,05,cCpo)									// Capacidade Volumétria (ml)
			cCpo := StrZero(SD2->D2_QUANT,18,3)
			cLin := Stuff(cLin,196,18,StrTran(cCpo,".",","))			// Quantidade do Produto
			cCpo := StrZero(SD2->D2_PRCVEN,20,6)
			cLin := Stuff(cLin,214,20,StrTran(cCpo,".",","))			// Valor Unitário do Produto
			cCpo := StrZero(SD2->D2_TOTAL,18,2)
			cLin := Stuff(cLin,234,18,StrTran(cCpo,".",","))			// Valor Total do Produto
			cLin := Stuff(cLin,252,03,SD2->D2_CLASFIS)					// Código Situação Tributária
			cLin := Stuff(cLin,255,01,"1")								// Indicador Mov. Física Produto
			cCpo := StrZero(SD2->(D2_DESCON+D2_DESPESA),18,2)
			cLin := Stuff(cLin,256,18,StrTran(cCpo,".",","))			// Valor Desconto/Desp.Acessórias
			cLin := Stuff(cLin,274,06,SD2->D2_CF)						// Código Natureza Operação
			cCpo := Posicione("SX5",1,xFilial("SX5")+"13"+SD2->D2_CF,"X5_DESCRI")
			cLin := Stuff(cLin,280,45,Substr(cCpo,1,45))				// Descriçao da Natureza Operação
			cLin := Stuff(cLin,325,06,"000000")							// Número do Cupom Fiscal
			If Substr(SD2->D2_CLASFIS,2,2) $ "00/20"
				cCpo := "1"
			Elseif Substr(SD2->D2_CLASFIS,2,2) $ "30/40"
				cCpo := "2"
			Elseif Substr(SD2->D2_CLASFIS,2,2) $ "41/50/51/90"
				cCpo := "3"
			Else
				cCpo := "4"
			Endif
			cLin := Stuff(cLin,331,01,cCpo)									// Indicador Tributação do ICMS
			If SD2->D2_BASEISS > 0
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,332,18,StrTran(cCpo,".",","))			// Base Cálculo de ICMS
				cLin := Stuff(cLin,350,18,StrTran(cCpo,".",","))			// Valor do ICMS
			Else
				cCpo := StrZero(SD2->D2_BASEICM,18,2)
				cLin := Stuff(cLin,332,18,StrTran(cCpo,".",","))			// Base Cálculo de ICMS
				cCpo := StrZero(SD2->D2_VALICM,18,2)
				cLin := Stuff(cLin,350,18,StrTran(cCpo,".",","))			// Valor do ICMS
			Endif
			cCpo := StrZero(SD2->D2_BRICMS,18,2)
			cLin := Stuff(cLin,368,18,StrTran(cCpo,".",","))			// Base Cálc. ICMS Subst.Trib.
			cCpo := StrZero(SD2->D2_ICMSRET,18,2)
			cLin := Stuff(cLin,386,18,StrTran(cCpo,".",","))			// Base Cálc. ICMS Subst.Trib.
			cCpo := StrZero(0,13,2)
			cLin := Stuff(cLin,404,13,StrTran(cCpo,".",","))			// B.Cálc. ST Origem/Destino
			cLin := Stuff(cLin,417,13,StrTran(cCpo,".",","))			// ICMS-ST repassar/deduzir
			cLin := Stuff(cLin,430,13,StrTran(cCpo,".",","))			// ICMS-ST complemen. a UF Dest.
			cLin := Stuff(cLin,443,13,StrTran(cCpo,".",","))			// Base Cálculo Retenção ICMS-ST
			cLin := Stuff(cLin,456,13,StrTran(cCpo,".",","))			// Valor Parc. Imp.Retido ICMS-ST
			cLin := Stuff(cLin,469,01,"2")								// Indicador Tributação do IPI
			cCpo := StrZero(SD2->D2_BASEIPI,18,2)
			cLin := Stuff(cLin,470,18,StrTran(cCpo,".",","))			// Base de Cálculo do IPI
			cCpo := StrZero(SD2->D2_VALIPI,18,2)
			cLin := Stuff(cLin,488,18,StrTran(cCpo,".",","))			// Base de Cálculo do IPI
			cLin := Stuff(cLin,506,01,"0")									// Tipo Oper. Veículos Novos
			cCpo := StrZero(0,14)
			cCpo := Transform(cCpo,"@R 99.999.999/9999-99")
			cLin := Stuff(cLin,507,18,cCpo)									// CNPJ da Concessionária
			cLin := Stuff(cLin,525,17,Space(17))							// Chassi do Veículo
			cLin := Stuff(cLin,542,18,cCpo)									// CNPJ Operadora de Destino
			cLin := Stuff(cLin,560,10,StrZero(0,10))						// Código Usuário Final
			cCpo := StrZero(0,13,2)
			cLin := Stuff(cLin,570,13,StrTran(cCpo,".",","))				// Valor Despesas Acessórias

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busco o tipo do item para montar o campo do registro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTipo := ASCAN(aTipo,{|x| x[1]==SD2->D2_TP})
			If nTipo > 0
				cCpo := aTipo[nTipo][2]
			Else
				cCpo := "99"
			EndIf
			cLin := Stuff(cLin,583,02,cCpo)									// Tipo do produto
			cLin := Stuff(cLin,585,20,Space(20))							// Nº Lote Fabricação-Medicamento
			cCpo := Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_CSTPIS")
			cLin := Stuff(cLin,605,02,cCpo)								// Classificacao Trib PIS
			cCpo := StrZero(SD2->D2_BASIMP6,12,2)
			cLin := Stuff(cLin,607,12,StrTran(cCpo,".",","))			// Base de Calculo PIS
			cCpo := StrZero(SD2->D2_ALQIMP6,7,4)
			cLin := Stuff(cLin,619,07,StrTran(cCpo,".",","))			// Aliquota PIS
			cCpo := StrZero(0,12,3)
			cLin := Stuff(cLin,626,12,StrTran(cCpo,".",","))			// Quantidade PIS
			cCpo := StrZero(0,7,4)
			cLin := Stuff(cLin,638,07,StrTran(cCpo,".",","))			// Aliquota PIS em Reais
			cCpo := StrZero(SD2->D2_VALIMP6,12,2)
			cLin := Stuff(cLin,645,12,StrTran(cCpo,".",","))			// Valor do PIS
			cCpo := Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_CSTCOF")
			cLin := Stuff(cLin,657,02,cCpo)								// Classificacao Trib PIS
			cCpo := StrZero(SD2->D2_BASIMP5,12,2)
			cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Base de Calculo COFINS
			cCpo := StrZero(SD2->D2_ALQIMP5,7,4)
			cLin := Stuff(cLin,671,07,StrTran(cCpo,".",","))			// Aliquota COFINS
			cCpo := StrZero(0,12,3)
			cLin := Stuff(cLin,678,12,StrTran(cCpo,".",","))			// Quantidade COFINS
			cCpo := StrZero(0,7,4)
			cLin := Stuff(cLin,690,07,StrTran(cCpo,".",","))			// Aliquota COFINS em Reais
			cCpo := StrZero(SD2->D2_VALIMP5,12,2)
			cLin := Stuff(cLin,697,12,StrTran(cCpo,".",","))			// Valor do COFINS
			cLin += _cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
					Exit
				Endif
			Endif

			dbSelectArea("SD2")
			dbSkip()
			lFirst := .F.

		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Notas de Saida - Itens de Registro 71 do Complemento (Conhecimento de Transporte)   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//nTamLin := 84
		nTamLin := 103
		cLin    := Space(nTamLin)				 // Variavel para criacao da linha do registros para gravacao

		cLin := Stuff(cLin,03,03,"R71")									// Tipo
		cLin := Stuff(cLin,06,05,Space(05))								// Modelo de Transporte
		cLin := Stuff(cLin,11,02,Space(02))								// Série de Transporte
		cLin := Stuff(cLin,13,06,StrZero(0,6))							// Número Nota de Transporte
		cLin := Stuff(cLin,19,10,"00/00/0000")							// Data de Emissão
		cLin := Stuff(cLin,29,02,Space(02))								// UF de Transporte
		cCpo := StrZero(0,18)
		cLin := Stuff(cLin,31,18,cCpo)									// CNPJ
		cLin := Stuff(cLin,49,20,Space(20))							 	// Inscrição Estadual
		cCpo := StrZero(0,16,2)
		cLin := Stuff(cLin,69,16,StrTran(cCpo,".",","))	  				// Total do Transporte
		cLin := Stuff(cLin,85,10,StrZero(0,10))							// Chave NFE-Nota Fisc.Eletrônica
		cLin := Stuff(cLin,95,09,StrZero(0,09))							// Número Nota de Transporte
		cLin += _cEOL

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
				Exit
			Endif
		Endif

		dbSelectArea("WSF2")
		dbSkip()

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto das notas de        ³
	//³ saida deve ser fechado.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fClose(nHdl)

	dbSelectArea("WSF2")
	dbCloseArea()
	dbSelectArea("SF2")
	RetIndex("SF2")

	dbSelectArea("SD2")
	RetIndex("SD2")
	#IfNDEF TOP
		fErase(cNomArqSD2+OrdBagExt())
	#endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array para as Notas de Servico    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aServ := {}

If !Empty(cNomArq3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abro novo arquivo. Agora para as    ³
	//³ notas de servico.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHdl := fCreate(cDir+cNomArq3)

	If nHdl == -1
		MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq3+" não pode ser executado! Verifique os parâmetros."),OemToAnsi("Atenção!"))
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabecalho do arquivo                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If fWrite(nHdl,cLinCab,Len(cLinCab)) != Len(cLinCab)
		MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento para as notas de Prestacao de Servico.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	cChaveSD2  := 'D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_ZZCC+D2_CONTA+D2_CF'
	cNomArqSD2 := CriaTrab(Nil,.F.)
	IndRegua("SD2",cNomArqSD2,cChaveSD2,,,OemToAnsi("Selecionando Registros..."))

	dbSelectArea("SD2")
	#IFNDEF TOP
		dbSetIndex(cNomArqSD2+OrdBagExt())
	#ENDIF

	cQuery := ""
	cQuery += "SELECT * , R_E_C_N_O_ RECSF2 FROM "+RetSQlName("SF2")+" SF2 "
	cQuery += "WHERE "
	cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
	cQuery += "SF2.F2_EMISSAO >= '"+dtos(mv_par01)+"' AND SF2.F2_EMISSAO <= '"+dtos(mv_par02)+"' AND "
	cQuery += "SF2.F2_SERIE <> 'X  ' AND F2_BASEISS > 0 AND F2_TIPO = 'N' AND "
	If !Empty(mv_par10)
		cQuery += "SF2.F2_DOC = '"+mv_par10+"' AND "
	Endif
	cQuery += "SF2.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY F2_FILIAL,F2_EMISSAO,F2_DOC,F2_SERIE"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSF2",.T.,.T.)
	aEval(SF2->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSF2",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSF2")
	Count to nTotReg
	dbGoTop()

	ProcRegua(nTotReg) // Numero de registros a processar

	While !Eof()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa a regua                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProc(OemToAnsi("Lendo Registros das Notas de Serviço..."))

		aadd(aServ , WSF2->RECSF2)
		dbSkip()
	Enddo

	ProcRegua(Len(aServ)) // Numero de registros a processar

	For ee:=1 to Len(aServ)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incrementa a regua                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc(OemToAnsi("Processando Registros das Notas de Serviços..."))

			dbSelectArea("SF2")
			dbGoTo(aServ[ee])

			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
			cCNPJ   := SA1->A1_CGC
			cNome   := Alltrim(StrTran(SA1->A1_NOME,CHR(9),""))
			cIE     := Iif(Empty(SA1->A1_INSCR),"ISENTO",SA1->A1_INSCR)
			cUF     := aUF[aScan(aUF,{|x| x[1] == SA1->A1_EST})][02]
			cCodM   := cUF+Iif(Empty(SA1->A1_COD_MUN),"3520509",SA1->A1_COD_MUN)
			cTipoCF := SA1->A1_TIPO
			cEnd    := Substr(SA1->A1_END,1,at(",",SA1->A1_END)-1)
			cNum    := StrZero(Val(Substr(SA1->A1_END,at(",",SA1->A1_END)+1)),5)
			cCEP    := Transform(SA1->A1_CEP,"@R 99999-999")
			cBairro := SA1->A1_BAIRRO
			cIMun   := SA1->A1_INSCRM
			cOptSimples := IIf(Empty(SA1->A1_SIMPNAC),"0",IIF(SA1->A1_SIMPNAC="1","1","0"))
			cEstado := SA1->A1_EST
			cColig  := SA1->A1_ZZCOLIG

			aDupli := {}
			nVlrImp := 0
			nVlIRRF  := 0
			nVlPIS   := 0
			nVlCOFI  := 0
			nVlCSLL  := 0

			dbSelectArea("SE1")
			dbSetOrder(2)
			If dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC),.T.)
				While !Eof() .and. E1_FILIAL=xFilial("SE1") .and.;
					E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
					If SE1->E1_TIPO == "NF "
						//aadd(aDupli , {E1_NUM , E1_VENCTO , E1_VALOR})
						aadd(aDupli , {E1_NUM , E1_VENCTO , E1_VLCRUZ})
			        ElseIf SE1->E1_TIPO == "IR-"
        				nVlrImp += SE1->E1_VALOR
        				nVlIRRF += SE1->E1_VALOR
					Elseif SE1->E1_TIPO == "PI-"
			            nVlrImp += SE1->E1_VALOR
			            nVlPIS  += SE1->E1_VALOR
					ElseIf SE1->E1_TIPO == "CF-"
  						nVlrImp += SE1->E1_VALOR
  						nVlCOFI += SE1->E1_VALOR
					ElseIf SE1->E1_TIPO == "CS-"
						nVlrImp += SE1->E1_VALOR
						nVlCSLL += SE1->E1_VALOR
					Endif
					dbSkip()
				Enddo
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Laco existente so para contar a quantidade de itens da nota, CFOP, Centro de Custo e conta contabil     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD2")
			dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
			aCFO    := {}
			aCCusto := {}
			aConta  := {}
			nItem   := 0

			While !Eof() .and. SD2->D2_FILIAL == xFilial("SD2") .and. D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ==;
				SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Contagem dos CFOPs  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLoc := aScan(aCFO , {|x| x[1] == D2_CF})
				If nLoc == 0
					aadd(aCFO , {D2_CF , 1})
				Else
					aCFO[nLoc][2] += 1
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Contagem dos Centros de Custo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLoc := aScan(aCCusto , {|x| x[1] == D2_ZZCC})
				If nLoc == 0
					aadd(aCCusto , {D2_ZZCC , 1})
				Else
					aCCusto[nLoc][2] += 1
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Contagem das Contas Contabeis ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLoc := aScan(aConta , {|x| x[1] == D2_CONTA})
				If nLoc == 0
					aadd(aConta , {D2_CONTA , 1})
				Else
					aConta[nLoc][2] += 1
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Contagem dos Itens da Nota    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nItem++

				dbSkip()
			Enddo

			aAux := {{Len(aCCusto),'cc'},{Len(aConta),'conta'},{Len(aCFO),'cfo'}}
			aSort(aAux,,, { |x,y| x[1] < y[1] })

			nDesdobr  := aAux[Len(aAux)][1]
			cQualDesd := aAux[Len(aAux)][2]

			If nDesdobr <= 1
				cDesdobr := "00"
			Else
				cDesdobr := StrZero(nDesdobr-1,2)
			Endif

			dbSelectArea("SD2")
			dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
			lFirst   := .T.
			nItemSD2 := 0
			cCFOAnt  := ""
			cCCAnt   := ""
			cContAnt := ""

			While !Eof() .and. SD2->D2_FILIAL == xFilial("SD2") .and. D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ==;
				SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
				SB5->(dbSetOrder(1))
				SB5->(dbSeek(xFilial("SB5")+SD2->D2_COD))

				If lFirst

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Notas de Servico - Movimento Principal    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//nTamLin := 425
					nTamLin := 469
					cLin    := Space(nTamLin)				//	Variavel para criacao da linha do registros para gravacao
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Substitui nas respectivas posicoes na variavel cLin pelo conteudo   ³
					//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
					//³ string dentro de outra string.                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCpo := PADR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),18)
					cLin := Stuff(cLin,01,18,cCpo)					// CNPJ da Empresa
					cLin := Stuff(cLin,19,01,"P")					// Tipo P=Prestacao de Servico
					cLin := Stuff(cLin,20,05,"NFS  ")          		// Espécie
					//cLin := Stuff(cLin,25,03,SF2->F2_SERIE)		// Série
					cLin := Stuff(cLin,25,03,"E  ") 				// Série
					cLin := Stuff(cLin,28,02,"  ")					// Sub Serie da nota
					cLin := Stuff(cLin,30,12,StrZero(0,12))		// Número do Documento Inicial/Final
					cCpo := GravaData(SF2->F2_EMISSAO,.T.,5)
					cLin := Stuff(cLin,42,10,DtoC(cCpo))			// Data do Documento
					cLin := Stuff(cLin,52,02,"  ")					// deixar em branco
					If SF2->F2_EST == "EX"
						cCpo := PADR("P-030",18)
					Else
						If Len(Alltrim(cCNPJ)) == 14					// CNPJ do Cliente
							cCpo := Transform(cCNPJ,"@R 99.999.999/9999-99")
						ElseIf Len(Alltrim(cCNPJ)) == 11					// CPF do Cliente
							cCpo := Transform(cCNPJ,"@R 999.999.999-99")
						Else
							cCpo := Space(18)
						Endif
					Endif
					cLin := Stuff(cLin,54,18,cCpo)
					cCpo := Padr(cNome,40)
					cLin := Stuff(cLin,72,40,cCpo)             // Nome do Cliente
					cLin := Stuff(cLin,112,20,cIE)				// Inscr. Est. do Cliente
					If SF2->F2_EST == "EX"
						cCpo := "99.999.99"
					Else
						If Empty(cCodM)
							cCpo := Space(9)
						Else
							cCpo := Transform(cCodM,"@R 99.999.99")
						Endif
					Endif
					cLin := Stuff(cLin,132,09,cCpo)							// Cód. IBGE (Cidade Cliente)
					cCpo := StrZero(SF2->F2_VALBRUT,12,2)
					cLin := Stuff(cLin,141,12,StrTran(cCpo,".",","))	// Valor Total da Nota Fiscal
					If SF2->F2_COND == "001"
						cCpo := "0"				// 0=Nota a vista
					Else
						cCpo := "1"				// 1=Nota a Prazo
					Endif
					cLin := Stuff(cLin,153,01,cCpo)						// Forma de pagto
					cLin := Stuff(cLin,154,02,cDesdobr)        			// Desdobramento
					cCpo := StrZero(0,17,2)
					cLin := Stuff(cLin,156,05,Space(05))				// Objeto de Isenção
					cLin := Stuff(cLin,161,13,Space(13))				// Número do Alvará
					cLin := Stuff(cLin,174,100,Space(100))				// Número e Página do Livro 57
					cLin := Stuff(cLin,274,06,StrZero(0,6))			// Contador Z
					cLin := Stuff(cLin,280,40,Substr(cEnd,1,40))		// Endereco
					cLin := Stuff(cLin,320,05,cNum)	        			// Número
					cLin := Stuff(cLin,325,09,cCEP)		        		// CEP
					cLin := Stuff(cLin,334,30,cBairro)	        		// Bairro
					If SF2->F2_EST == "EX"
						cLin := Stuff(cLin,364,02,Space(2))			// Sigla do País
					Else
						cLin := Stuff(cLin,364,02,"BR")  				// Sigla do País
					Endif
					cLin := Stuff(cLin,366,11,cIMun) 	 				// Inscrição Municipal
					cCpo := "0"
					cLin := Stuff(cLin,377,01,cCpo)		  				// Nota Conjugada
					cCpo := Substr(SD2->D2_CF,1,1)
					cLin := Stuff(cLin,378,01,cCpo)						// Tipo de Operação
					cCpo := StrZero(0,18,2)
					cLin := Stuff(cLin,379,18,StrTran(cCpo,".",","))	// Valor do Desconto
					cLin := Stuff(cLin,397,20,Space(20))		        // Insc.Est.Secundária Cliente
					cLin := Stuff(cLin,417,09,Space(09))               // Município onde o ISS é Devido
					cLin := Stuff(cLin,426,03,StrZero(Len(aDupli),03)) // Quantidade de Parcelas
					cLin := Stuff(cLin,429,02,StrZero(0,02))           // Dia do Vencimento da Parcela
					cLin := Stuff(cLin,431,07,Space(07))	           // Período Inicial Parcelamento
					cLin := Stuff(cLin,438,01,StrZero(0,01))           // Dia vencto. p/ transf.
					cLin := Stuff(cLin,439,02,StrZero(0,02))           // Intervalo entre cada parcela
					cLin := Stuff(cLin,441,10,Space(10))           		// Dia Inicial do Parcelamento
					cCpo := StrZero(Val(SF2->F2_DOC),9)+Space(9)
					//cLin := Stuff(cLin,451,18,cCpo+cCpo)	       		// Nº Documento Inicial e Final
					cLin := Stuff(cLin,451,18,cCpo)	       				// Nº Documento Inicial e Final
					cLin := Stuff(cLin,469,01,cOptSimples)				// Optante do Simples Nacional
					cLin += _cEOL

					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
							Exit
						Endif
					Endif

				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Servico - Complemento do Movimento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If cQualDesd == 'cfo'

					If SD2->D2_CF <> cCFOAnt

						cCFOAnt := SD2->D2_CF
						nPos    := aScan(aCFO , {|x| x[1] == SD2->D2_CF})
						nQtdCFO := aCFO[nPos][2]

						cQuery := ""
						cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
						cQuery += "WHERE "
						cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
						cQuery += "SFT.FT_TIPOMOV = 'S' AND "
						cQuery += "SFT.FT_SERIE = '"  +SD2->D2_SERIE+"' AND "
						cQuery += "SFT.FT_NFISCAL = '"+SD2->D2_DOC+"' AND "
						cQuery += "SFT.FT_CLIEFOR = '"+SD2->D2_CLIENTE+"' AND "
						cQuery += "SFT.FT_LOJA = '"   +SD2->D2_LOJA+"' AND "
						cQuery += "SFT.FT_CFOP = '"   +cCFOAnt+"' AND "
						cQuery += "SFT.D_E_L_E_T_ <> '*'"

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
						aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

						cCodISS   := ""
						nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
						nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
						nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
						nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
						nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

						dbSelectArea("WSFT")
						dbGoTop()
						While !Eof()
							nValCont  += WSFT->FT_VALCONT
							nBaseICMS += WSFT->FT_BASEICM
							nAliqICMS := WSFT->FT_ALIQICM
							nValICMS  += WSFT->FT_VALICM
							nIsenICMS += WSFT->FT_ISENICM
							nOutrICMS += WSFT->FT_OUTRICM
							nBaseRet  += WSFT->FT_BASERET
							nICMSRet  += WSFT->FT_ICMSRET
							nBaseIPI  += WSFT->FT_BASEIPI
							nAliqIPI  := WSFT->FT_ALIQIPI
							nValIPI   += WSFT->FT_VALIPI
							nIsenIPI  += WSFT->FT_ISENIPI
							nDespesa  += WSFT->FT_DESPESA
							cCodISS   := WSFT->FT_CODISS
							nValINSS  += WSFT->FT_VALINS
							nValIRRF  += WSFT->FT_VALIRR
							nValPIS   += WSFT->FT_VALPIS
							nValCOF   += WSFT->FT_VALCOF
							nValCSL   += WSFT->FT_VALCSL
							nValPISR  += WSFT->FT_VRETPIS
							nValCOFR  += WSFT->FT_VRETCOF
							nValCSLR  += WSFT->FT_VRETCSL
							If WSFT->FT_TIPO == 'S'
								nBaseISS  += WSFT->FT_BASEICM
								nValISS   += WSFT->FT_VALICM
								nAliqISS  := WSFT->FT_ALIQICM
							Endif
							dbSkip()
						Enddo

						dbCloseArea()

						/*
						lTemImp := .F.
						lTemIR  := .F.
						SE1->(dbSetOrder(2))
						SE1->(dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)))
						While SE1->(!Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and.;
						   		SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
							If SE1->E1_TIPO == 'CF-'
								nValCOFR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'PI-'
								nValPISR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'CS-'
								nValCSLR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'IR-'
								nValIRRF += SE1->E1_VALOR
								lTemIR := .T.
							Endif
							SE1->(dbSkip())
						Enddo

						If !lTemImp
							nValPISR := 0
							nValCOFR := 0
							nValCSLR := 0
						Endif
						If !lTemIR
							nValIRRF := 0
						Endif

						If nValCont > 0
							nAux1    := Round(nValCont/SF2->F2_VALBRUT,5)
							nValPISR := Round(nAux1*nValPISR,2)
							nValCOFR := Round(nAux1*nValCOFR,2)
							nValCSLR := Round(nAux1*nValCSLR,2)
							nValIRRF := Round(nAux1*nValIRRF,2)
						Endif
						*/

						If nValCont > 0

							//nTamLin := 488
							nTamLin := 492
							cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

							cLin := Stuff(cLin,03,11,StrZero(0,11))					// Num. Documento Mov. Princ.
							If !Empty(SD2->D2_ZZCC)
								SZ0->(dbSetOrder(1))
								SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
								cCpo1 := Right(SZ0->Z0_CCUSTO,2)
								cCpo2 := SZ0->Z0_LOGICA
							Else
								cCpo1 := Space(02)
								cCpo2 := Space(04)
							Endif
							cLin := Stuff(cLin,14,02,cCpo1)								// Centro de custo
							cLin := Stuff(cLin,16,04,cCpo2)								// Conta Contabil
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))			// Valor Contabil
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ISS
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ISS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ISS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ISS Isento
							cCpo := StrZero(nOutrICMS,12,2)
							cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Atividade Mista
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do INSS
							//cCpo := Space(10)  // SF3->F3_CODISS+Space(2)
							//cLin := Stuff(cLin,99,10,cCpo)								// Codigo do Servico
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,99,10,cCodISS)								// Codigo do Servico
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,109,12,StrTran(cCpo,".",","))		// Empreitada
							If nVlIRRF > 0
								cCpo := StrZero(nValIRRF,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,121,12,StrTran(cCpo,".",","))			// Valor do IRRF
							cLin := Stuff(cLin,133,01,"0")								// Tipo Livro de Servico
							cLin := Stuff(cLin,134,03,"000")							// Codigo de Observacao
							cCpo := Space(250)
							cLin := Stuff(cLin,137,250,cCpo)							// Complemento da Observacao
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,387,12,StrTran(cCpo,".",","))			// Valor ISS Retido
							cLin := Stuff(cLin,399,01,"1")								// Alíq.Cofins(Lucro Real/Estim.)
							If nVlPIS > 0
								cCpo := StrZero(nValPISR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,400,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							If nVlCOFI > 0
								cCpo := StrZero(nValCOFR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,412,12,StrTran(cCpo,".",","))			// Valor da Cofins Retido
							If nVlCSLL > 0
								cCpo := StrZero(nValCSLR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,424,12,StrTran(cCpo,".",","))			// Valor da CSLL Retido
							cLin := Stuff(cLin,436,03,"000")							// Código Fiscal de Prestação de Serviço
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								cCpo := StrZero(nValCont,18,2)
							Else
								cCpo := StrZero(0,18,2)
							Endif
							cLin := Stuff(cLin,439,18,StrTran(cCpo,".",","))		// Base Cálculo de IRRF
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								//cCpo := StrZero(Round((nValIRRF/nValCont)*100,3),6,2)
								cCpo := StrZero(1.5,6,2)
							Else
								cCpo := StrZero(0,6,2)
							Endif
							cLin := Stuff(cLin,457,06,StrTran(cCpo,".",","))		// Alíquota do IRRF
							cLin := Stuff(cLin,463,03,StrZero(nQtdCFO,3))			// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,466,05,Space(5))					// Cod.Tipo Serviço(Empr.Simples)
							cCpo := StrZero(Val(SF2->F2_DOC),9)
							//cLin := Stuff(cLin,471,18,cCpo+cCpo)					// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,471,18,cCpo)				   			// Nº Documento Mov. Princ.
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								cLin := Stuff(cLin,489,04,"1708")					// Cod Receita IRRF retido
							Else
								cLin := Stuff(cLin,489,04,Space(4))					// Cod Receita IRRF retido
							Endif
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
									Exit
								Endif
							Endif

						Else

							//nTamLin := 488
							nTamLin := 492
							cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

							cLin := Stuff(cLin,03,12,StrZero(0,12))					// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,15,02,Space(02))						// Centro de custo
							cLin := Stuff(cLin,17,03,Space(03))						// Conta Contabil
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo1,".",","))			// Valor Contabil
							cLin := Stuff(cLin,32,12,StrTran(cCpo1,".",","))			// Base do ISS
							cLin := Stuff(cLin,44,07,StrTran(cCpo2,".",","))			// Aliquota do ISS
							cLin := Stuff(cLin,51,12,StrTran(cCpo1,".",","))			// Valor do ISS
							cLin := Stuff(cLin,63,12,StrTran(cCpo1,".",","))			// Valor do ISS Isento
							cLin := Stuff(cLin,75,12,StrTran(cCpo1,".",","))			// Atividade Mista
							cLin := Stuff(cLin,87,12,StrTran(cCpo1,".",","))			// Valor do INSS
							//cCpo := Space(10)
							//cLin := Stuff(cLin,99,10,cCpo)								// Codigo do Servico
							cLin := Stuff(cLin,99,10,cCodISS)								// Codigo do Servico
							cLin := Stuff(cLin,109,12,StrTran(cCpo1,".",","))			// Empreitada
							cLin := Stuff(cLin,121,12,StrTran(cCpo1,".",","))			// Valor do IRRF
							cLin := Stuff(cLin,133,01,"0")								// Tipo Livro de Servico
							cLin := Stuff(cLin,134,03,"000")							// Codigo de Observacao
							cCpo := Space(250)
							cLin := Stuff(cLin,137,250,cCpo)							// Complemento da Observacao
							cLin := Stuff(cLin,387,12,StrTran(cCpo1,".",","))			// Valor ISS Retido
							cLin := Stuff(cLin,399,01,"1")								// Alíq.Cofins(Lucro Real/Estim.)
							cLin := Stuff(cLin,400,12,StrTran(cCpo1,".",","))			// Valor do PIS Retido
							cLin := Stuff(cLin,412,12,StrTran(cCpo1,".",","))			// Valor da Cofins Retido
							cLin := Stuff(cLin,424,12,StrTran(cCpo1,".",","))			// Valor da CSLL Retido
							cLin := Stuff(cLin,436,03,"000")							// Código Fiscal de Prestação de Serviço
							cCpo := StrZero(0,18,2)
							cLin := Stuff(cLin,439,18,StrTran(cCpo,".",","))			// Base Cálculo de IRRF
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,457,06,StrTran(cCpo,".",","))			// Alíquota do IRRF
							cLin := Stuff(cLin,463,03,StrZero(nQtdCFO,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,466,05,Space(5))						// Cod.Tipo Serviço(Empr.Simples)
							cCpo := StrZero(Val(SF2->F2_DOC),9)
							//cLin := Stuff(cLin,471,18,cCpo+cCpo)						// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,471,18,cCpo)					   			// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,489,04,Space(4))						// Cod Receita IRRF retido
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
									Exit
								Endif
							Endif

						Endif

					Endif

				Elseif cQualDesd == 'cc'	// por centro de custo

					If SD2->D2_ZZCC <> cCCAnt

						cCCAnt  := SD2->D2_ZZCC
						nPos    := aScan(aCCusto, {|x| x[1] == SD2->D2_ZZCC})
						nQtdCC := aCCusto[nPos][2]

						cQuery := ""
						cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
						cQuery += "WHERE "
						cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
						cQuery += "SFT.FT_TIPOMOV = 'S' AND "
						cQuery += "SFT.FT_SERIE = '"  +SD2->D2_SERIE+"' AND "
						cQuery += "SFT.FT_NFISCAL = '"+SD2->D2_DOC+"' AND "
						cQuery += "SFT.FT_CLIEFOR = '"+SD2->D2_CLIENTE+"' AND "
						cQuery += "SFT.FT_LOJA = '"   +SD2->D2_LOJA+"' AND "
						cQuery += "RTRIM(SFT.FT_ZZCC) = '"   +cCCAnt+"' AND "
						cQuery += "SFT.D_E_L_E_T_ <> '*'"

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
						aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

						cCodISS   := ""
						nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
						nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
						nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
						nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
						nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

						dbSelectArea("WSFT")
						dbGoTop()
						While !Eof()
							nValCont  += WSFT->FT_VALCONT
							nBaseICMS += WSFT->FT_BASEICM
							nAliqICMS := WSFT->FT_ALIQICM
							nValICMS  += WSFT->FT_VALICM
							nIsenICMS += WSFT->FT_ISENICM
							nOutrICMS += WSFT->FT_OUTRICM
							nBaseRet  += WSFT->FT_BASERET
							nICMSRet  += WSFT->FT_ICMSRET
							nBaseIPI  += WSFT->FT_BASEIPI
							nAliqIPI  := WSFT->FT_ALIQIPI
							nValIPI   += WSFT->FT_VALIPI
							nIsenIPI  += WSFT->FT_ISENIPI
							nDespesa  += WSFT->FT_DESPESA
							cCodISS   := WSFT->FT_CODISS
							nValINSS  += WSFT->FT_VALINS
							nValIRRF  += WSFT->FT_VALIRR
							nValPIS   += WSFT->FT_VALPIS
							nValCOF   += WSFT->FT_VALCOF
							nValCSL   += WSFT->FT_VALCSL
							nValPISR  += WSFT->FT_VRETPIS
							nValCOFR  += WSFT->FT_VRETCOF
							nValCSLR  += WSFT->FT_VRETCSL
							If WSFT->FT_TIPO == 'S'
								nBaseISS  += WSFT->FT_BASEICM
								nValISS   += WSFT->FT_VALICM
								nAliqISS  := WSFT->FT_ALIQICM
							Endif
							dbSkip()
						Enddo

						dbCloseArea()

						/*
						lTemImp := .F.
						lTemIR  := .F.
						SE1->(dbSetOrder(2))
						SE1->(dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)))
						While SE1->(!Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and.;
						   		SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
							If SE1->E1_TIPO == 'CF-'
								nValCOFR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'PI-'
								nValPISR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'CS-'
								nValCSLR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'IR-'
								nValIRRF += SE1->E1_VALOR
								lTemIR := .T.
							Endif
							SE1->(dbSkip())
						Enddo

						If !lTemImp
							nValPISR := 0
							nValCOFR := 0
							nValCSLR := 0
						Endif
						If !lTemIR
							nValIRRF := 0
						Endif

						If nValCont > 0
							nAux1    := Round(nValCont/SF2->F2_VALBRUT,5)
							nValPISR := Round(nAux1*nValPISR,2)
							nValCOFR := Round(nAux1*nValCOFR,2)
							nValCSLR := Round(nAux1*nValCSLR,2)
							nValIRRF := Round(nAux1*nValIRRF,2)
						Endif
						*/

						If nValCont > 0

							//nTamLin := 488
							nTamLin := 492
							cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

							cLin := Stuff(cLin,03,11,StrZero(0,11))					// Num. Documento Mov. Princ.
							If !Empty(SD2->D2_ZZCC)
								SZ0->(dbSetOrder(1))
								SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
								cCpo1 := Right(SZ0->Z0_CCUSTO,2)
								cCpo2 := SZ0->Z0_LOGICA
							Else
								cCpo1 := Space(02)
								cCpo2 := Space(04)
							Endif
							cLin := Stuff(cLin,14,02,cCpo1)								// Centro de custo
							cLin := Stuff(cLin,16,04,cCpo2)								// Conta Contabil
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))			// Valor Contabil
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ISS
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ISS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ISS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ISS Isento
							cCpo := StrZero(nOutrICMS,12,2)
							cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Atividade Mista
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do INSS
							//cCpo := Space(10)  // SF3->F3_CODISS+Space(2)
							//cLin := Stuff(cLin,99,10,cCpo)								// Codigo do Servico
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,99,10,cCodISS)								// Codigo do Servico
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,109,12,StrTran(cCpo,".",","))		// Empreitada
							If nVlIRRF > 0
								cCpo := StrZero(nValIRRF,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,121,12,StrTran(cCpo,".",","))		// Valor do IRRF
							cLin := Stuff(cLin,133,01,"0")								// Tipo Livro de Servico
							cLin := Stuff(cLin,134,03,"000")								// Codigo de Observacao
							cCpo := Space(250)
							cLin := Stuff(cLin,137,250,cCpo)								// Complemento da Observacao
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,387,12,StrTran(cCpo,".",","))		// Valor ISS Retido
							cLin := Stuff(cLin,399,01,"1")								// Alíq.Cofins(Lucro Real/Estim.)
							If nVlPIS > 0
								cCpo := StrZero(nValPISR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,400,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							If nVlCOFI > 0
								cCpo := StrZero(nValCOFR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,412,12,StrTran(cCpo,".",","))			// Valor da Cofins Retido
							If nVlCSLL > 0
								cCpo := StrZero(nValCSLR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,424,12,StrTran(cCpo,".",","))			// Valor da CSLL Retido
							cLin := Stuff(cLin,436,03,"000")								// Código Fiscal de Prestação de Serviço
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								cCpo := StrZero(nValCont,18,2)
							Else
								cCpo := StrZero(0,18,2)
							Endif
							cLin := Stuff(cLin,439,18,StrTran(cCpo,".",","))		// Base Cálculo de IRRF
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								//cCpo := StrZero(Round((nValIRRF/nValCont)*100,3),6,2)
								cCpo := StrZero(1.5,6,2)
							Else
								cCpo := StrZero(0,6,2)
							Endif
							cLin := Stuff(cLin,457,06,StrTran(cCpo,".",","))		// Alíquota do IRRF
							cLin := Stuff(cLin,463,03,StrZero(nQtdCC,3))			// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,466,05,Space(5))					// Cod.Tipo Serviço(Empr.Simples)
							cCpo := StrZero(Val(SF2->F2_DOC),9)+Space(9)
							//cLin := Stuff(cLin,471,18,cCpo+cCpo)					// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,471,18,cCpo)				   			// Nº Documento Mov. Princ.
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								cLin := Stuff(cLin,489,04,"1708")					// Cod Receita IRRF retido
							Else
								cLin := Stuff(cLin,489,04,Space(4))					// Cod Receita IRRF retido
							Endif
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
									Exit
								Endif
							Endif

						Else

							//nTamLin := 488
							nTamLin := 492
							cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

							cLin := Stuff(cLin,03,12,StrZero(0,12))					// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,15,02,Space(02))						// Centro de custo
							cLin := Stuff(cLin,17,03,Space(03))						// Conta Contabil
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo1,".",","))			// Valor Contabil
							cLin := Stuff(cLin,32,12,StrTran(cCpo1,".",","))			// Base do ISS
							cLin := Stuff(cLin,44,07,StrTran(cCpo2,".",","))			// Aliquota do ISS
							cAliIssNf := cCpo2
							cLin := Stuff(cLin,51,12,StrTran(cCpo1,".",","))			// Valor do ISS
							cLin := Stuff(cLin,63,12,StrTran(cCpo1,".",","))			// Valor do ISS Isento
							cLin := Stuff(cLin,75,12,StrTran(cCpo1,".",","))			// Atividade Mista
							cLin := Stuff(cLin,87,12,StrTran(cCpo1,".",","))			// Valor do INSS
							//cCpo := Space(10)
							//cLin := Stuff(cLin,99,10,cCpo)								// Codigo do Servico
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,99,10,cCodISS)								// Codigo do Servico
							cLin := Stuff(cLin,109,12,StrTran(cCpo1,".",","))			// Empreitada
							cLin := Stuff(cLin,121,12,StrTran(cCpo1,".",","))			// Valor do IRRF
							cLin := Stuff(cLin,133,01,"0")								// Tipo Livro de Servico
							cLin := Stuff(cLin,134,03,"000")							// Codigo de Observacao
							cCpo := Space(250)
							cLin := Stuff(cLin,137,250,cCpo)							// Complemento da Observacao
							cLin := Stuff(cLin,387,12,StrTran(cCpo1,".",","))			// Valor ISS Retido
							cLin := Stuff(cLin,399,01,"1")								// Alíq.Cofins(Lucro Real/Estim.)
							cLin := Stuff(cLin,400,12,StrTran(cCpo1,".",","))			// Valor do PIS Retido
							cLin := Stuff(cLin,412,12,StrTran(cCpo1,".",","))			// Valor da Cofins Retido
							cLin := Stuff(cLin,424,12,StrTran(cCpo1,".",","))			// Valor da CSLL Retido
							cLin := Stuff(cLin,436,03,"000")							// Código Fiscal de Prestação de Serviço
							cCpo := StrZero(0,18,2)
							cLin := Stuff(cLin,439,18,StrTran(cCpo,".",","))			// Base Cálculo de IRRF
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,457,06,StrTran(cCpo,".",","))			// Alíquota do IRRF
							cLin := Stuff(cLin,463,03,StrZero(nQtdCC,3))				// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,466,05,Space(5))						// Cod.Tipo Serviço(Empr.Simples)
							cCpo := StrZero(Val(SF2->F2_DOC),9)+Space(9)
							//cLin := Stuff(cLin,471,18,cCpo+cCpo)						// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,471,18,cCpo)					   			// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,489,04,Space(4))						// Cod Receita IRRF retido
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
									Exit
								Endif
							Endif

						Endif

					Endif

				Else				// por conta contabil

					If SD2->D2_CONTA <> cContAnt

						cContAnt := SD2->D2_CONTA
						nPos      := aScan(aConta, {|x| x[1] == SD2->D2_CONTA})
						nQtdConta := aConta[nPos][2]

						cQuery := ""
						cQuery += "SELECT * FROM "+RetSQlName("SFT")+" SFT "
						cQuery += "WHERE "
						cQuery += "SFT.FT_FILIAL = '"+xFilial("SFT")+"' AND "
						cQuery += "SFT.FT_TIPOMOV = 'S' AND "
						cQuery += "SFT.FT_SERIE = '"  +SD2->D2_SERIE+"' AND "
						cQuery += "SFT.FT_NFISCAL = '"+SD2->D2_DOC+"' AND "
						cQuery += "SFT.FT_CLIEFOR = '"+SD2->D2_CLIENTE+"' AND "
						cQuery += "SFT.FT_LOJA = '"   +SD2->D2_LOJA+"' AND "
						cQuery += "SFT.FT_CONTA = '"  +cContAnt+"' AND "
						cQuery += "SFT.D_E_L_E_T_ <> '*'"

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSFT",.T.,.T.)
						aEval(SFT->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSFT",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

						cCodISS   := ""
						nValCont  := nBaseICMS := nAliqICMS := nValICMS := nIsenICMS := 0
						nOutrICMS := nBaseRet  := nICMSRet  := nBaseIPI := nAliqIPI  := 0
						nValIPI   := nIsenIPI  := nDespesa  := nValINSS := nValIRRF  := 0
						nValPIS   := nValCOF   := nValCSL   := nValPISR := nValCOFR  := 0
						nValCSLR  := nBaseISS  := nValISS   := nAliqISS := 0

						dbSelectArea("WSFT")
						dbGoTop()
						While !Eof()
							nValCont  += WSFT->FT_VALCONT
							nBaseICMS += WSFT->FT_BASEICM
							nAliqICMS := WSFT->FT_ALIQICM
							nValICMS  += WSFT->FT_VALICM
							nIsenICMS += WSFT->FT_ISENICM
							nOutrICMS += WSFT->FT_OUTRICM
							nBaseRet  += WSFT->FT_BASERET
							nICMSRet  += WSFT->FT_ICMSRET
							nBaseIPI  += WSFT->FT_BASEIPI
							nAliqIPI  := WSFT->FT_ALIQIPI
							nValIPI   += WSFT->FT_VALIPI
							nIsenIPI  += WSFT->FT_ISENIPI
							nDespesa  += WSFT->FT_DESPESA
							cCodISS   := WSFT->FT_CODISS
							nValINSS  += WSFT->FT_VALINS
							nValIRRF  += WSFT->FT_VALIRR
							nValPIS   += WSFT->FT_VALPIS
							nValCOF   += WSFT->FT_VALCOF
							nValCSL   += WSFT->FT_VALCSL
							nValPISR  += WSFT->FT_VRETPIS
							nValCOFR  += WSFT->FT_VRETCOF
							nValCSLR  += WSFT->FT_VRETCSL
							If WSFT->FT_TIPO == 'S'
								nBaseISS  += WSFT->FT_BASEICM
								nValISS   += WSFT->FT_VALICM
								nAliqISS  := WSFT->FT_ALIQICM
							Endif
							dbSkip()
						Enddo

						dbCloseArea()

						/*
						lTemImp := .F.
						lTemIR  := .F.
						SE1->(dbSetOrder(2))
						SE1->(dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)))
						While SE1->(!Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and.;
						   		SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
							If SE1->E1_TIPO == 'CF-'
								nValCOFR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'PI-'
								nValPISR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'CS-'
								nValCSLR += SE1->E1_VALOR
								lTemImp := .T.
							Endif
							If SE1->E1_TIPO == 'IR-'
								nValIRRF += SE1->E1_VALOR
								lTemIR := .T.
							Endif
							SE1->(dbSkip())
						Enddo

						If !lTemImp
							nValPISR := 0
							nValCOFR := 0
							nValCSLR := 0
						Endif
						If !lTemIR
							nValIRRF := 0
						Endif

						If nValCont > 0
							nAux1    := Round(nValCont/SF2->F2_VALBRUT,5)
							nValPISR := Round(nAux1*nValPISR,2)
							nValCOFR := Round(nAux1*nValCOFR,2)
							nValCSLR := Round(nAux1*nValCSLR,2)
							nValIRRF := Round(nAux1*nValIRRF,2)
						Endif
						*/

						If nValCont > 0

							//nTamLin := 488
							nTamLin := 492
							cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

							cLin := Stuff(cLin,03,11,StrZero(0,11))					// Num. Documento Mov. Princ.
							If !Empty(SD2->D2_ZZCC)
								SZ0->(dbSetOrder(1))
								SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
								cCpo1 := Right(SZ0->Z0_CCUSTO,2)
								cCpo2 := SZ0->Z0_LOGICA
							Else
								cCpo1 := Space(02)
								cCpo2 := Space(04)
							Endif
							cLin := Stuff(cLin,14,02,cCpo1)								// Centro de custo
							cLin := Stuff(cLin,16,04,cCpo2)								// Conta Contabil
							cCpo := StrZero(nValCont,12,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo,".",","))			// Valor Contabil
							cCpo := StrZero(nBaseICMS,12,2)
							cLin := Stuff(cLin,32,12,StrTran(cCpo,".",","))			// Base do ISS
							cCpo := StrZero(nAliqICMS,7,4)
							cLin := Stuff(cLin,44,07,StrTran(cCpo,".",","))			// Aliquota do ISS
							cCpo := StrZero(nValICMS,12,2)
							cLin := Stuff(cLin,51,12,StrTran(cCpo,".",","))			// Valor do ISS
							cCpo := StrZero(nIsenICMS,12,2)
							cLin := Stuff(cLin,63,12,StrTran(cCpo,".",","))			// Valor do ISS Isento
							cCpo := StrZero(nOutrICMS,12,2)
							cLin := Stuff(cLin,75,12,StrTran(cCpo,".",","))			// Atividade Mista
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,87,12,StrTran(cCpo,".",","))			// Valor do INSS
							//cCpo := Space(10)  // SF3->F3_CODISS+Space(2)
							//cLin := Stuff(cLin,99,10,cCpo)								// Codigo do Servico
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,99,10,cCodISS)								// Codigo do Servico
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,109,12,StrTran(cCpo,".",","))		// Empreitada
							If nVlIRRF >= nValIRRF
								cCpo := StrZero(nValIRRF,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,121,12,StrTran(cCpo,".",","))		// Valor do IRRF
							cLin := Stuff(cLin,133,01,"0")								// Tipo Livro de Servico
							cLin := Stuff(cLin,134,03,"000")								// Codigo de Observacao
							cCpo := Space(250)
							cLin := Stuff(cLin,137,250,cCpo)								// Complemento da Observacao
							cCpo := StrZero(0,12,2)
							cLin := Stuff(cLin,387,12,StrTran(cCpo,".",","))		// Valor ISS Retido
							cLin := Stuff(cLin,399,01,"1")								// Alíq.Cofins(Lucro Real/Estim.)
							If nVlPIS > 0
								cCpo := StrZero(nValPISR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,400,12,StrTran(cCpo,".",","))			// Valor do PIS Retido
							If nVlCOFI > 0
								cCpo := StrZero(nValCOFR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,412,12,StrTran(cCpo,".",","))			// Valor da Cofins Retido
							If nVlCSLL > 0
								cCpo := StrZero(nValCSLR,12,2)
							Else
								cCpo := StrZero(0,12,2)
							Endif
							cLin := Stuff(cLin,424,12,StrTran(cCpo,".",","))			// Valor da CSLL Retido
							cLin := Stuff(cLin,436,03,"000")								// Código Fiscal de Prestação de Serviço
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								cCpo := StrZero(nValCont,18,2)
							Else
								cCpo := StrZero(0,18,2)
							Endif
							cLin := Stuff(cLin,439,18,StrTran(cCpo,".",","))		// Base Cálculo de IRRF
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								//cCpo := StrZero(Round((nValIRRF/nValCont)*100,3),6,2)
								cCpo := StrZero(1.5,6,2)
							Else
								cCpo := StrZero(0,6,2)
							Endif
							cLin := Stuff(cLin,457,06,StrTran(cCpo,".",","))		// Alíquota do IRRF
							cLin := Stuff(cLin,463,03,StrZero(nQtdConta,3))			// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,466,05,Space(5))					// Cod.Tipo Serviço(Empr.Simples)
							cCpo := StrZero(Val(SF2->F2_DOC),9)+Space(9)
							//cLin := Stuff(cLin,471,18,cCpo+cCpo)					// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,471,18,cCpo)				   			// Nº Documento Mov. Princ.
							//If nVlIRRF >= nValIRRF
							If nVlIRRF > 0
								cLin := Stuff(cLin,489,04,"1708")					// Cod Receita IRRF retido
							Else
								cLin := Stuff(cLin,489,04,Space(4))					// Cod Receita IRRF retido
							Endif
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
									Exit
								Endif
							Endif

						Else

							//nTamLin := 488
							nTamLin := 492
							cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

							cLin := Stuff(cLin,03,12,StrZero(0,12))					// Num. Documento Mov. Princ.
							cLin := Stuff(cLin,15,02,Space(02))						// Centro de custo
							cLin := Stuff(cLin,17,03,Space(03))						// Conta Contabil
							cCpo1 := StrZero(0,12,2)
							cCpo2 := StrZero(0,07,2)
							cLin := Stuff(cLin,20,12,StrTran(cCpo1,".",","))			// Valor Contabil
							cLin := Stuff(cLin,32,12,StrTran(cCpo1,".",","))			// Base do ISS
							cLin := Stuff(cLin,44,07,StrTran(cCpo2,".",","))			// Aliquota do ISS
							cLin := Stuff(cLin,51,12,StrTran(cCpo1,".",","))			// Valor do ISS
							cLin := Stuff(cLin,63,12,StrTran(cCpo1,".",","))			// Valor do ISS Isento
							cLin := Stuff(cLin,75,12,StrTran(cCpo1,".",","))			// Atividade Mista
							cLin := Stuff(cLin,87,12,StrTran(cCpo1,".",","))			// Valor do INSS
							//cCpo := Space(10)
							//cLin := Stuff(cLin,99,10,cCpo)								// Codigo do Servico
							If Alltrim(cCodISS)=='19452'
								cCodISS := '1709 '
							Endif
							cLin := Stuff(cLin,99,10,cCodISS)								// Codigo do Servico
							cLin := Stuff(cLin,109,12,StrTran(cCpo1,".",","))			// Empreitada
							cLin := Stuff(cLin,121,12,StrTran(cCpo1,".",","))			// Valor do IRRF
							cLin := Stuff(cLin,133,01,"0")								// Tipo Livro de Servico
							cLin := Stuff(cLin,134,03,"000")							// Codigo de Observacao
							cCpo := Space(250)
							cLin := Stuff(cLin,137,250,cCpo)							// Complemento da Observacao
							cLin := Stuff(cLin,387,12,StrTran(cCpo1,".",","))			// Valor ISS Retido
							cLin := Stuff(cLin,399,01,"1")								// Alíq.Cofins(Lucro Real/Estim.)
							cLin := Stuff(cLin,400,12,StrTran(cCpo1,".",","))			// Valor do PIS Retido
							cLin := Stuff(cLin,412,12,StrTran(cCpo1,".",","))			// Valor da Cofins Retido
							cLin := Stuff(cLin,424,12,StrTran(cCpo1,".",","))			// Valor da CSLL Retido
							cLin := Stuff(cLin,436,03,"000")							// Código Fiscal de Prestação de Serviço
							cCpo := StrZero(0,18,2)
							cLin := Stuff(cLin,439,18,StrTran(cCpo,".",","))			// Base Cálculo de IRRF
							cCpo := StrZero(0,6,2)
							cLin := Stuff(cLin,457,06,StrTran(cCpo,".",","))			// Alíquota do IRRF
							cLin := Stuff(cLin,463,03,StrZero(nQtdConta,3))			// Quantidade Itens Desdobramento
							cLin := Stuff(cLin,466,05,Space(5))						// Cod.Tipo Serviço(Empr.Simples)
							cCpo := StrZero(Val(SF2->F2_DOC),9)+Space(9)
							//cLin := Stuff(cLin,471,18,cCpo+cCpo)						// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,471,18,cCpo)					   			// Nº Documento Mov. Princ.
							cLin := Stuff(cLin,489,04,Space(4))						// Cod Receita IRRF retido
							cLin += _cEOL

							If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
								If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
									Exit
								Endif
							Endif

						Endif

					Endif

				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Servico - Itens do Complemento     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//nTamLin := 197
				nTamLin := 301
				cLin    := Space(nTamLin)				 // Variavel para criacao da linha do registros para gravacao

				nItemSD2++
				cLin := Stuff(cLin,05,03,StrZero(nItemSD2,3))				// Número Item
				cLin := Stuff(cLin,08,14,Substr(SD2->D2_COD,1,14))			// Código Servico Empresa
				cLin := Stuff(cLin,22,53,Substr(StrTran(SB1->B1_DESC,chr(9),""),1,53))		// Descrição do Servico
				cLin := Stuff(cLin,75,45,Substr(SB5->B5_CEME,1,45))		// Descrição Complementar do servico
				cCpo := StrZero(SD2->D2_TOTAL,18,2)
				cLin := Stuff(cLin,120,18,StrTran(cCpo,".",","))			// Valor Total do Servico
				cCpo := StrZero(SD2->D2_DESCON,18,2)
				cLin := Stuff(cLin,138,18,StrTran(cCpo,".",","))			// Valor Desconto
				cCpo := StrZero(SD2->D2_BASEISS,18,2)
				cLin := Stuff(cLin,156,18,StrTran(cCpo,".",","))			// Base Cálculo de ISS
				cCpo := StrZero(SD2->D2_PICM,06,2)
//				cLin := Stuff(cLin,174,06,StrTran(cCpo,".",","))			// Aliquota do ISS
				//rey
				cLin := Stuff(cLin,174,06,StrTran(StrZero(nAliqISS,6,2),".",","))
				cCpo := StrZero(SD2->D2_VALISS,18,2)
				cLin := Stuff(cLin,180,18,StrTran(cCpo,".",","))			// Valor do ISS
				If SD2->D2_EST == "EX"
					cCpo := Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_CSTPIS")
					cLin := Stuff(cLin,198,02,cCpo)								// Classificacao Trib PIS
					cCpo1 := StrZero(0,12,2)
					cCpo2 := StrZero(0,7,4)
					cLin := Stuff(cLin,200,12,StrTran(cCpo1,".",","))			// Base de Calculo PIS
					cLin := Stuff(cLin,212,07,StrTran(cCpo2,".",","))			// Aliquota PIS
					cLin := Stuff(cLin,219,12,StrTran(cCpo1,".",","))			// Quantidade PIS
					cLin := Stuff(cLin,231,07,StrTran(cCpo2,".",","))			// Aliquota PIS em Reais
					cLin := Stuff(cLin,238,12,StrTran(cCpo1,".",","))			// Valor do PIS
					cCpo := Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_CSTCOF")
					cLin := Stuff(cLin,250,02,cCpo)								// Classificacao Trib PIS
					cLin := Stuff(cLin,252,12,StrTran(cCpo1,".",","))			// Base de Calculo COFINS
					cLin := Stuff(cLin,264,07,StrTran(cCpo2,".",","))			// Aliquota COFINS
					cLin := Stuff(cLin,271,12,StrTran(cCpo1,".",","))			// Quantidade COFINS
					cLin := Stuff(cLin,283,07,StrTran(cCpo2,".",","))			// Aliquota COFINS em Reais
					cLin := Stuff(cLin,290,12,StrTran(cCpo1,".",","))			// Valor do COFINS
				Else
					cCpo := Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_CSTPIS")
					cLin := Stuff(cLin,198,02,cCpo)								// Classificacao Trib PIS
					cCpo := StrZero(SD2->D2_BASIMP6,12,2)
					cLin := Stuff(cLin,200,12,StrTran(cCpo,".",","))			// Base de Calculo PIS
					cCpo := StrZero(SD2->D2_ALQIMP6,7,4)
					cLin := Stuff(cLin,212,07,StrTran(cCpo,".",","))			// Aliquota PIS
					cCpo := StrZero(0,12,3)
					cLin := Stuff(cLin,219,12,StrTran(cCpo,".",","))			// Quantidade PIS
					cCpo := StrZero(0,7,4)
					cLin := Stuff(cLin,231,07,StrTran(cCpo,".",","))			// Aliquota PIS em Reais
					cCpo := StrZero(SD2->D2_VALIMP6,12,2)
					cLin := Stuff(cLin,238,12,StrTran(cCpo,".",","))			// Valor do PIS
					cCpo := Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_CSTCOF")
					cLin := Stuff(cLin,250,02,cCpo)								// Classificacao Trib PIS
					cCpo := StrZero(SD2->D2_BASIMP5,12,2)
					cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base de Calculo COFINS
					cCpo := StrZero(SD2->D2_ALQIMP5,7,4)
					cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Aliquota COFINS
					cCpo := StrZero(0,12,3)
					cLin := Stuff(cLin,271,12,StrTran(cCpo,".",","))			// Quantidade COFINS
					cCpo := StrZero(0,7,4)
					cLin := Stuff(cLin,283,07,StrTran(cCpo,".",","))			// Aliquota COFINS em Reais
					cCpo := StrZero(SD2->D2_VALIMP5,12,2)
					cLin := Stuff(cLin,290,12,StrTran(cCpo,".",","))			// Valor do COFINS
				Endif
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
						Exit
					Endif
				Endif

				dbSelectArea("SD2")
				dbSkip()
				lFirst := .F.

			Enddo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PARCELAS DE NOTA A PRAZO                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTamLin := 31
			cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

			If Len(aDupli) > 0
				For nA:=1 to Len(aDupli)
					cLin := Stuff(cLin,03,05,"PAR")									// Tipo de Parcela
					cLin := Stuff(cLin,06,15,GravaData(DtoC(aDupli[nA][2]),.T.,5))// Data de Vencimento
					cCpo := StrZero(aDupli[nA][3]-iif(nA==1,nVlrImp,0),16,2)
					cLin := Stuff(cLin,16,31,StrTran(cCpo,".",","))				// Valor da Parcela
					cLin += _cEOL

					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
							Exit
						Endif
					Endif
				Next
			Else
				cLin := Stuff(cLin,03,05,Space(3))					// Tipo de Parcela
				cLin := Stuff(cLin,06,15,DtoC(CtoD(Space(8))))		// Data de Vencimento
				cCpo := StrZero(0,16,2)
				cLin := Stuff(cLin,16,31,StrTran(cCpo,".",","))	// Valor da Parcela
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
						Exit
					Endif
				Endif
			Endif

	Next ee

	dbSelectArea("WSF2")
	dbCloseArea()
	dbSelectArea("SF2")
	RetIndex("SF2")

	dbSelectArea("SD2")
	RetIndex("SD2")
	#IfNDEF TOP
		fErase(cNomArqSD2+OrdBagExt())
	#endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto deve ser fechado.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fClose(nHdl)

Endif

If !Empty(cNomArq4)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento para as notas de saida Canceladas / Inutilizadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := ""
	cQuery += "SELECT * FROM "+RetSQlName("SF3")+" SF3 "
	cQuery += "WHERE "
	cQuery += "SF3.F3_FILIAL = '"+xFilial("SF3")+"' AND "
	cQuery += "SF3.F3_DTCANC >= '"+dtos(mv_par01)+"' AND SF3.F3_DTCANC <= '"+dtos(mv_par02)+"' AND "
	//cQuery += "SF3.F3_CODRSEF IN ('101','102') AND "
	//cQuery += "SF3.F3_TIPO <> 'S' AND "
	//cQuery += "SF3.F3_DTCANC <> ' ' AND "
	cQuery += "SF3.F3_CFO > '5000 ' AND "
	cQuery += "SF3.F3_CODISS = '"+Space(TamSX3("F3_CODISS")[1])+"' AND "
	If !Empty(mv_par10)
		cQuery += "SF3.F3_NFISCAL = '"+mv_par10+"' AND "
	Endif
	cQuery += "SF3.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY F3_FILIAL,F3_EMISSAO,F3_NFISCAL,F3_SERIE"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSF3",.T.,.T.)
	aEval(SF3->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSF3",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSF3")
	Count to nTotReg

	dbGoTop()

	If !Bof() .and. !Eof()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Abro novo arquivo. Agora para as    ³
		//³ notas canceladas / inutilizadas     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHdl := fCreate(cDir+cNomArq4)

		If nHdl == -1
			MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq4+" não pode ser executado! Verifique os parãmetros."),OemToAnsi("Atenção!"))
			Return
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cabecalho do arquivo                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If fWrite(nHdl,cLinCab,Len(cLinCab)) != Len(cLinCab)
			MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
			Return
		Endif

		ProcRegua(nTotReg) // Numero de registros a processar

		cNFAnt   := ""

		While !Eof()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incrementa a regua                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc(OemToAnsi("Lendo Registros das Notas Canceladas/Inutilizadas..."))

			If WSF3->F3_NFISCAL+WSF3->F3_SERIE == cNFAnt
				dbSkip()
				Loop
			Else
				cNFAnt := WSF3->F3_NFISCAL+WSF3->F3_SERIE
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Movimento Principal                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTamLin := 1121
			cLin    := Space(nTamLin)				//	Variavel para criacao da linha do registros para gravacao

			If WSF3->F3_TIPO $ "D#B"
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+WSF3->(F3_CLIEFOR+F3_LOJA)))
				cCNPJ := SA2->A2_CGC
				cNome := SA2->A2_NOME
				cIE   := Iif(Empty(SA2->A2_INSCR),"ISENTO",SA2->A2_INSCR)
				cUF   := aUF[aScan(aUF,{|x| x[1] == SA2->A2_EST})][02]
				cCodM := cUF+Iif(Empty(SA2->A2_COD_MUN),"3520509",SA2->A2_COD_MUN)
				cTipoCF := SA2->A2_TIPO
				cOptSimples := IIf(Empty(SA2->A2_SIMPNAC),"0",IIF(SA2->A2_SIMPNAC="1","1","0"))
			Else
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+WSF3->(F3_CLIEFOR+F3_LOJA)))
				cCNPJ := SA1->A1_CGC
				cNome := SA1->A1_NOME
				cIE   := Iif(Empty(SA1->A1_INSCR),"ISENTO",SA1->A1_INSCR)
				cUF   := aUF[aScan(aUF,{|x| x[1] == SA1->A1_EST})][02]
				cCodM := cUF+Iif(Empty(SA1->A1_COD_MUN),"3520509",SA1->A1_COD_MUN)
				cTipoCF := SA1->A1_TIPO
				cOptSimples := IIf(Empty(SA1->A1_SIMPNAC),"0",IIF(SA1->A1_SIMPNAC="1","1","0"))
			Endif

			cCFO    := "00"
			cCSTPC  := Space(2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Substitui nas respectivas posicoes na variavel cLin pelo conteudo   ³
			//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
			//³ string dentro de outra string.                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCpo := PADR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),18)
			cLin := Stuff(cLin,01,18,cCpo)						// CNPJ da Empresa
			cLin := Stuff(cLin,19,01,"S")							// Tipo S=Saida
			cLin := Stuff(cLin,20,05,"NFE  ")          				// Espécie
			cLin := Stuff(cLin,25,03,"2  ")							// Série
			cLin := Stuff(cLin,28,02,"  ")							// Sub Serie da nota
			cLin := Stuff(cLin,30,12,StrZero(0,12))				// Número do Documento Inicial/Final
			cCpo := GravaData(WSF3->F3_EMISSAO,.T.,5)
			cLin := Stuff(cLin,42,10,DtoC(cCpo))				// Data do Documento
			cLin := Stuff(cLin,52,02,WSF3->F3_ESTADO)				// Unidade Federativa
			If WSF3->F3_ESTADO == "EX"
				cCpo := PADR("P-030",18)
			Else
				If Len(Alltrim(cCNPJ)) == 14							// CNPJ do Cliente
					cCpo := Transform(cCNPJ,"@R 99.999.999/9999-99")
				ElseIf Len(Alltrim(cCNPJ)) == 11						// CPF do Cliente
					cCpo := Transform(cCNPJ,"@R 999.999.999-99")
				Else
					cCpo := Space(18)
				Endif
			Endif
			cLin := Stuff(cLin,54,18,cCpo)
			cCpo := Padr(cNome,40)
			cLin := Stuff(cLin,72,40,cCpo)             // Nome do Cliente
			cLin := Stuff(cLin,112,20,cIE)				// Inscr. Est. do Cliente
			If WSF3->F3_ESTADO == "EX"
				cCpo := "99.999.99"
			Else
				If Empty(cCodM)
					cCpo := Space(9)
				Else
					cCpo := Transform(cCodM,"@R 99.999.99")
				Endif
			Endif
			cLin := Stuff(cLin,132,09,cCpo)							// Cód. IBGE (Cidade Cliente)
			cCpo := StrZero(0,12,2)
			cLin := Stuff(cLin,141,12,StrTran(cCpo,".",","))	// Valor Total da Nota Fiscal
			cCpo := "0"				// 0=Nota a vista
			cLin := Stuff(cLin,153,01,cCpo)							// Forma de pagto
			cLin := Stuff(cLin,154,06,"000000")	        			// Número Contador Z
			cCpo := StrZero(0,17,2)
			cLin := Stuff(cLin,160,17,StrTran(cCpo,".",","))	// Valor GT Inicial
			cLin := Stuff(cLin,177,17,StrTran(cCpo,".",","))	// Valor GT Final
			cLin := Stuff(cLin,194,17,StrTran(cCpo,".",","))	// Valor de Cancelamentos
			cLin := Stuff(cLin,211,17,StrTran(cCpo,".",","))	// Valor de Descontos
			If WSF3->F3_ESTADO == "EX"
				cCpo := StrZero(1,15)
			Else
				cCpo := StrZero(0,15)
			Endif
			cLin := Stuff(cLin,228,15,cCpo)							// Registro de Exportação
			cLin := Stuff(cLin,243,06,StrZero(0,6))	        	// Num. Nota de Devolução
			cCpo := Space(5)
			cLin := Stuff(cLin,249,05,cCpo)		        		// Espécie da Nota Devolução
			cCpo := Space(3)
			cLin := Stuff(cLin,254,03,cCpo)		        		// Série da Nota Devolução
			cLin := Stuff(cLin,257,02,Space(02)) 	 			// Sub-Série da Nota de Devolução
			cLin := Stuff(cLin,259,02,cCFO) 	 					// Desdobramento
			cLin := Stuff(cLin,261,09,Space(09))  				// DIPAM - Município Início Frete
			cLin := Stuff(cLin,270,06,Space(06))  				// C R O / Intervenção
			cCpo := StrZero(0,15,2)
			cLin := Stuff(cLin,276,17,StrTran(cCpo,".",","))	// Valor GT Final Antes Reinício
			cCpo := "0"
			cLin := Stuff(cLin,293,01,cCpo)		  					// Nota Conjugada
			cCpo := StrZero(0,18,2)
			cLin := Stuff(cLin,294,18,StrTran(cCpo,".",","))	// Valor do Frete
			cLin := Stuff(cLin,312,18,StrTran(cCpo,".",","))	// Valor do Seguro
			cLin := Stuff(cLin,330,18,StrTran(cCpo,".",","))	// Valor do Desconto
			cCpo := StrZero(0,18)
			cLin := Stuff(cLin,348,18,cCpo)							// CNPJ do Local de saida
			cLin := Stuff(cLin,366,40,Space(40))		        	// Nome do CNPJ Local de Saída
			cLin := Stuff(cLin,406,20,Space(20))               // Inscr. Estad. CNPJ Local Saída
			cLin := Stuff(cLin,426,09,Space(09))               // Cód.Mun.IBGE CNPJ Local Saída
			cLin := Stuff(cLin,435,18,cCpo)							// CNPJ do Local Entrada
			cLin := Stuff(cLin,453,40,Space(40))					// Nome do CNPJ Local de Entrada
			cLin := Stuff(cLin,493,20,Space(20))               // Inscr. Estad. CNPJ Local Entrada
			cLin := Stuff(cLin,513,09,Space(09))					// Cód.Mun.IBGE CNPJ Local Entrada
			cLin := Stuff(cLin,522,18,cCpo)							// CNPJ do Transportador
			cLin := Stuff(cLin,540,40,Space(40))					// Nome do CNPJ do Transportador
			cLin := Stuff(cLin,580,20,Space(20))               // Inscr. Estad. do Transportador
			cLin := Stuff(cLin,600,09,Space(09))					// Cód.Mun.IBGE do Transportador
			cLin := Stuff(cLin,609,10,Space(10))				// Especie de Volumes
			cLin := Stuff(cLin,619,01,"0")							// Modalidade de Transporte
			cLin := Stuff(cLin,620,07,Space(7))						// Placa Veiculo 1
			cLin := Stuff(cLin,627,02,Space(2))						// UF Placa Veiculo 1
			cLin := Stuff(cLin,629,07,Space(7))						// Placa Veiculo 2
			cLin := Stuff(cLin,636,02,Space(2))						// UF Placa Veiculo 2
			cLin := Stuff(cLin,638,07,Space(7))						// Placa Veiculo 3
			cLin := Stuff(cLin,645,02,Space(2))						// UF Placa Veiculo 3
			cCpo := StrZero(0,18,3)
			cLin := Stuff(cLin,647,18,StrTran(cCpo,".",","))	// Peso Bruto
			cLin := Stuff(cLin,665,18,StrTran(cCpo,".",","))	// Peso Liquido
			cLin := Stuff(cLin,683,10,"00/00/0000")				// Data Averbação de Exportação
			cCpo := StrZero(0,11)
			cLin := Stuff(cLin,693,11,cCpo)							// Número Declaração Exportação
			cLin := Stuff(cLin,704,10,"00/00/0000")				// Data Declaração de Exportação
			cCpo := StrZero(0,16)
			cLin := Stuff(cLin,714,16,cCpo)							// Número Conhecimento Embarque
			cLin := Stuff(cLin,730,02,"00")							// Cód.Tipo Conhecimento Embarque
			cLin := Stuff(cLin,732,10,"00/00/0000")				// Data Conhecimento Embarque
			cLin := Stuff(cLin,742,01,"0")							// Natureza da Exportação
			cLin := Stuff(cLin,743,02,"00")							// Sigla do País da Exportação
			cCpo := StrZero(0,18)
			cLin := Stuff(cLin,745,18,cCpo)							// CNPJ Remetente da Exportação
			cLin := Stuff(cLin,763,40,Space(40))					// Nome Remetente da Exportação
			cLin := Stuff(cLin,803,20,Space(20))            		// Inscr.Est.Remetente Exportação
			cLin := Stuff(cLin,823,09,Space(09))					// Cód.IBGE Remetente Exportação
			cLin := Stuff(cLin,832,01,"0")							// Relacionamento da Exportação
			cLin := Stuff(cLin,833,03,StrZero(0,3))					// Quantidade Registro 71
			cLin := Stuff(cLin,836,20,Space(20))					// Insc.Est.Secundária Cliente
			cLin := Stuff(cLin,856,40,Space(40))					// Endereço
			cLin := Stuff(cLin,896,05,Space(05))					// Numero
			cLin := Stuff(cLin,901,09,Space(09))					// CEP
			cLin := Stuff(cLin,910,30,Space(30))					// Bairro
			cLin := Stuff(cLin,940,02,Space(02))					// Sigla do Pais
			cLin := Stuff(cLin,942,11,Space(11))					// Inscricao Municipal
			cLin := Stuff(cLin,953,10,StrZero(Val(Right(WSF3->F3_CHVNFE,10)),10))				// Chave NFE-Nota Fisc.Eletrônica
			cLin := Stuff(cLin,963,01,Space(01))					// Indicador do Título de Crédito
			cLin := Stuff(cLin,964,20,Space(20))					// Descrição do Título de Crédito
			cLin := Stuff(cLin,984,12,Space(12))					// Número do Título de Crédito
			cLin := Stuff(cLin,996,03,Space(03))					// Situação Trib. ICMS Transporte
			cLin := Stuff(cLin,999,03,StrZero(0,03))				// Quantidade de Parcelas
			cLin := Stuff(cLin,1002,02,StrZero(0,02))				// Dia do Vencimento da Parcela
			cLin := Stuff(cLin,1004,07,Space(07))			   		// Período Inicial Parcelamento
			cLin := Stuff(cLin,1011,01,StrZero(0,01))		   		// Dia vencto. p/ transf.
			cLin := Stuff(cLin,1012,02,StrZero(0,02))		   		// Intervalo entre cada parcela
			cLin := Stuff(cLin,1014,10,Space(10))			   		// Dia Inicial do Parcelamento
			cCpo := StrZero(Val(WSF3->F3_NFISCAL),9)
			cLin := Stuff(cLin,1024,18,cCpo+cCpo)			   		// Nº Documento Inicial e Final
			cCpo := StrZero(0,9)
			cLin := Stuff(cLin,1042,09,cCpo)			   			// Nº Nota de Devolução
			cLin := Stuff(cLin,1051,01,cOptSimples)					// Optante do Simples Nacional
			cLin := Stuff(cLin,1052,02,cCSTPC)						// Situacao Tributaria do PIS
			cCpo := StrZero(0,13,2)
			cLin := Stuff(cLin,1054,13,StrTran(cCpo,".",","))		// Base de Calculo do PIS
			cCpo := StrZero(0,7,4)
			cLin := Stuff(cLin,1067,07,StrTran(cCpo,".",","))		// Aliquota PIS
			cCpo := StrZero(0,13,2)
			cLin := Stuff(cLin,1074,13,StrTran(cCpo,".",","))		// Valor do PIS
			cLin := Stuff(cLin,1087,02,cCSTPC)						// Situacao Tributaria do COFINS
			cCpo := StrZero(0,13,2)
			cLin := Stuff(cLin,1089,13,StrTran(cCpo,".",","))		// Base de Calculo do COFINS
			cCpo := StrZero(0,7,4)
			cLin := Stuff(cLin,1102,07,StrTran(cCpo,".",","))		// Aliquota COFINS
			cCpo := StrZero(0,13,2)
			cLin := Stuff(cLin,1109,13,StrTran(cCpo,".",","))		// Valor do COFINS

			cLin += _cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !(Iw_MsgBox(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"), "YESNO"))
					fClose(nHdl)
					Return
				Endif
			Endif

			nQtdCFO := 1

			nTamLin := 668
			cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

			cLin := Stuff(cLin,03,11,StrZero(0,11))					// Num. Documento Mov. Princ.
			cCpo := Space(02)
			cLin := Stuff(cLin,14,02,cCpo)						// Centro de custo
			If Substr(WSF3->F3_CFO,2,3) $ "949/913/908/909"
				//cCpo := "R051"
				cCpo2 := "R057"
			ElseIf Substr(WSF3->F3_CFO,2,3) = "915"
				cCpo := "R052"
			Else
				cCpo := Space(04)
			Endif
			cLin := Stuff(cLin,16,04,cCpo)								// Conta Contabil
			cLin := Stuff(cLin,20,06,Transform(WSF3->F3_CFO,"@R 9.999X"))	// Codigo Fiscal
			cCpo1:= StrZero(0,12,2)
			cCpo2:= StrZero(0,7,4)
			cLin := Stuff(cLin,26,12,StrTran(cCpo1,".",","))		  	// Valor Contabil
			cLin := Stuff(cLin,38,12,StrTran(cCpo1,".",","))			// Base do ICMS
			cLin := Stuff(cLin,50,07,StrTran(cCpo2,".",","))			// Aliquota do ICMS
			cLin := Stuff(cLin,57,12,StrTran(cCpo1,".",","))			// Valor do ICMS
			cLin := Stuff(cLin,69,12,StrTran(cCpo1,".",","))			// Valor do ICMS Isento
			cLin := Stuff(cLin,81,12,StrTran(cCpo1,".",","))				// Valor do ICMS Outros
			cLin := Stuff(cLin,93,12,StrTran(cCpo1,".",","))			// Valor do ICMS Diversos
			cLin := Stuff(cLin,105,07,StrTran(cCpo2,".",","))			// Aliquota interna do ICMS
			cLin := Stuff(cLin,112,12,StrTran(cCpo1,".",","))			// Valor do Imposto Aliquota Interna
			cLin := Stuff(cLin,124,12,StrTran(cCpo1,".",","))			// Valor Base Subs. Tributária
			cLin := Stuff(cLin,136,07,StrTran(cCpo2,".",","))			// Alíquota Subst. Tributária
			cLin := Stuff(cLin,143,12,StrTran(cCpo1,".",","))			// Valor Imp. subs. Tributária
			cLin := Stuff(cLin,155,12,StrTran(cCpo1,".",","))			// INSS Retido
			cLin := Stuff(cLin,167,12,StrTran(cCpo1,".",","))			// Valor Base IPI
			cLin := Stuff(cLin,179,07,StrTran(cCpo2,".",","))			// Alíquota do IPI
			cLin := Stuff(cLin,186,12,StrTran(cCpo1,".",","))			// Valor IPI
			cLin := Stuff(cLin,198,12,StrTran(cCpo1,".",","))			// Valor Isento IPI
			cLin := Stuff(cLin,210,12,StrTran(cCpo1,".",","))			// Valor Outras IPI
			cLin := Stuff(cLin,222,12,StrTran(cCpo1,".",","))			// Valor Diversos IPI
			cLin := Stuff(cLin,234,01,"0")								// Exportar DNF
			cCpo := StrZero(0,9)
			cLin := Stuff(cLin,235,18,cCpo+cCpo)						// Controle Interno
			cLin := Stuff(cLin,253,09,Space(09))						// Modelo de Transporte
			cLin := Stuff(cLin,262,04,Space(04))						// Série de Transporte
			cLin := Stuff(cLin,266,06,Space(06))						// Nº da Nota de Transporte
			cLin := Stuff(cLin,272,10,Space(10))						// Data de Emissão
			cLin := Stuff(cLin,282,02,Space(02))								// UF de Transporte
			cCpo := StrZero(0,18)
			cLin := Stuff(cLin,284,18,cCpo)								// CNPJ
			cLin := Stuff(cLin,302,19,Space(19))						// Inscrição Estadual
			cCpo := StrZero(0,16,2)
			cLin := Stuff(cLin,321,16,StrTran(cCpo,".",","))			// Total do Transporte
			cCpo := StrZero(0,16)
			cLin := Stuff(cLin,337,01,"0")								// Modalidade do Frete
			cLin := Stuff(cLin,338,03,"096") 							// Cód. Observação --> usar 096 qdo a nota for cancelada
			cLin := Stuff(cLin,341,250,Space(250)) 					// Complemento Observação
			cLin := Stuff(cLin,591,01,"0")			 					// Subst. Trib. Ref. Petróleo
			cLin := Stuff(cLin,592,01,"1")			 					// Alíq.Cofins(Lucro Real/Estim.)
			cLin := Stuff(cLin,593,02,Space(02))	 					// UF de Início da Operação
			cLin := Stuff(cLin,595,01," ")								// Operação Realizada com 1=Consum./Usu.final 2=Empr.Simples 3=Exp./Dest.Exp 4-Outras Empresas (ME/EPP)
			cLin := Stuff(cLin,596,07,StrTran(cCpo2,".",","))			// Aliq.ICMS(Fora Estado)=Emp.RAM
			cLin := Stuff(cLin,603,07,StrTran(cCpo2,".",","))			// Aliq.ICMS (Interna) = Emp.RAM
			cLin := Stuff(cLin,610,01," ")								// Código Antecipação Subs.Trib.
			cCpo := StrZero(0,14,2)
			cLin := Stuff(cLin,611,14,StrTran(cCpo,".",","))			// Valor das Despesas Acessórias
			cLin := Stuff(cLin,625,10,"00/00/0000")						// Data da Exportação
			cCpo := StrZero(0,15)
			cLin := Stuff(cLin,635,15,cCpo)								// Registro de Exportação
			cCpo := StrZero(0,12)
			cLin := Stuff(cLin,650,12,cCpo)								// Número Despacho de Exportação
			cLin := Stuff(cLin,662,03,StrZero(1,3))				// Quantidade Itens Desdobramento
			cLin := Stuff(cLin,665,01,"0")								// Oper.Combustível/Solv(GRF-CBT)
			cLin := Stuff(cLin,666,03,"000")							// Classificação Lançto. na DACON

			cLin += _cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
					Exit
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Notas de Saida - Itens do Complemento       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTamLin := 708
			cLin    := Space(nTamLin)				 // Variavel para criacao da linha do registros para gravacao

			cLin := Stuff(cLin,05,03,StrZero(1,3))				// Número Item
			cLin := Stuff(cLin,08,14,Space(14))				// Código Produto Empresa
			cLin := Stuff(cLin,22,08,Space(8))					// NCM do Produto
			cLin := Stuff(cLin,30,53,Space(53))			// Descrição do Produto
			cLin := Stuff(cLin,83,06,Space(2))							// Unidade do Produto
			cCpo := StrZero(0,6,2)
			cLin := Stuff(cLin,89,06,StrTran(cCpo,".",","))				// Alíquota do IPI
			cCpo := StrZero(0,6,2)
			cLin := Stuff(cLin,95,06,StrTran(cCpo,".",","))				// Alíquota de ICMS
			cLin := Stuff(cLin,101,45,Space(45))					// Descrição Complementar Produto
			cLin := Stuff(cLin,146,30,Space(30))					// Unidade de Medida no DNF
			cCpo := StrZero(0,15,3)
			cLin := Stuff(cLin,176,15,StrTran(cCpo,".",","))			// Quantidade do Produto
			cCpo := StrZero(0,5)
			cLin := Stuff(cLin,191,05,cCpo)									// Capacidade Volumétria (ml)
			cCpo := StrZero(0,18,3)
			cLin := Stuff(cLin,196,18,StrTran(cCpo,".",","))			// Quantidade do Produto
			cCpo := StrZero(0,20,6)
			cLin := Stuff(cLin,214,20,StrTran(cCpo,".",","))			// Valor Unitário do Produto
			cCpo := StrZero(0,18,2)
			cLin := Stuff(cLin,234,18,StrTran(cCpo,".",","))			// Valor Total do Produto
			cLin := Stuff(cLin,252,03,Space(3))					// Código Situação Tributária
			cLin := Stuff(cLin,255,01,"1")								// Indicador Mov. Física Produto
			cCpo := StrZero(0,18,2)
			cLin := Stuff(cLin,256,18,StrTran(cCpo,".",","))			// Valor Desconto/Desp.Acessórias
			cLin := Stuff(cLin,274,06,WSF3->F3_CFO)						// Código Natureza Operação
			cLin := Stuff(cLin,280,45,Space(45))				// Descriçao da Natureza Operação
			cLin := Stuff(cLin,325,06,"000000")							// Número do Cupom Fiscal
			cCpo := "4"
			cLin := Stuff(cLin,331,01,cCpo)									// Indicador Tributação do ICMS
			cCpo := StrZero(0,18,2)
			cLin := Stuff(cLin,332,18,StrTran(cCpo,".",","))			// Base Cálculo de ICMS
			cLin := Stuff(cLin,350,18,StrTran(cCpo,".",","))			// Valor do ICMS
			cCpo := StrZero(0,18,2)
			cLin := Stuff(cLin,368,18,StrTran(cCpo,".",","))			// Base Cálc. ICMS Subst.Trib.
			cCpo := StrZero(0,18,2)
			cLin := Stuff(cLin,386,18,StrTran(cCpo,".",","))			// Base Cálc. ICMS Subst.Trib.
			cCpo := StrZero(0,13,2)
			cLin := Stuff(cLin,404,13,StrTran(cCpo,".",","))			// B.Cálc. ST Origem/Destino
			cLin := Stuff(cLin,417,13,StrTran(cCpo,".",","))			// ICMS-ST repassar/deduzir
			cLin := Stuff(cLin,430,13,StrTran(cCpo,".",","))			// ICMS-ST complemen. a UF Dest.
			cLin := Stuff(cLin,443,13,StrTran(cCpo,".",","))			// Base Cálculo Retenção ICMS-ST
			cLin := Stuff(cLin,456,13,StrTran(cCpo,".",","))			// Valor Parc. Imp.Retido ICMS-ST
			cLin := Stuff(cLin,469,01,"2")								// Indicador Tributação do IPI
			cCpo := StrZero(0,18,2)
			cLin := Stuff(cLin,470,18,StrTran(cCpo,".",","))			// Base de Cálculo do IPI
			cCpo := StrZero(0,18,2)
			cLin := Stuff(cLin,488,18,StrTran(cCpo,".",","))			// Base de Cálculo do IPI
			cLin := Stuff(cLin,506,01,"0")									// Tipo Oper. Veículos Novos
			cCpo := StrZero(0,14)
			cCpo := Transform(cCpo,"@R 99.999.999/9999-99")
			cLin := Stuff(cLin,507,18,cCpo)									// CNPJ da Concessionária
			cLin := Stuff(cLin,525,17,Space(17))							// Chassi do Veículo
			cLin := Stuff(cLin,542,18,cCpo)									// CNPJ Operadora de Destino
			cLin := Stuff(cLin,560,10,StrZero(0,10))						// Código Usuário Final
			cCpo := StrZero(0,13,2)
			cLin := Stuff(cLin,570,13,StrTran(cCpo,".",","))				// Valor Despesas Acessórias
			cCpo := "99"
			cLin := Stuff(cLin,583,02,cCpo)									// Tipo do produto
			cLin := Stuff(cLin,585,20,Space(20))							// Nº Lote Fabricação-Medicamento
			cLin := Stuff(cLin,605,02,Space(2))								// Classificacao Trib PIS
			cCpo := StrZero(0,12,2)
			cLin := Stuff(cLin,607,12,StrTran(cCpo,".",","))			// Base de Calculo PIS
			cCpo := StrZero(0,7,4)
			cLin := Stuff(cLin,619,07,StrTran(cCpo,".",","))			// Aliquota PIS
			cCpo := StrZero(0,12,3)
			cLin := Stuff(cLin,626,12,StrTran(cCpo,".",","))			// Quantidade PIS
			cCpo := StrZero(0,7,4)
			cLin := Stuff(cLin,638,07,StrTran(cCpo,".",","))			// Aliquota PIS em Reais
			cCpo := StrZero(0,12,2)
			cLin := Stuff(cLin,645,12,StrTran(cCpo,".",","))			// Valor do PIS
			cLin := Stuff(cLin,657,02,Space(2))								// Classificacao Trib PIS
			cCpo := StrZero(0,12,2)
			cLin := Stuff(cLin,659,12,StrTran(cCpo,".",","))			// Base de Calculo COFINS
			cCpo := StrZero(0,7,4)
			cLin := Stuff(cLin,671,07,StrTran(cCpo,".",","))			// Aliquota COFINS
			cCpo := StrZero(0,12,3)
			cLin := Stuff(cLin,678,12,StrTran(cCpo,".",","))			// Quantidade COFINS
			cCpo := StrZero(0,7,4)
			cLin := Stuff(cLin,690,07,StrTran(cCpo,".",","))			// Aliquota COFINS em Reais
			cCpo := StrZero(0,12,2)
			cLin := Stuff(cLin,697,12,StrTran(cCpo,".",","))			// Valor do COFINS

			cLin += _cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
					Exit
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Notas de Saida - Itens de Registro 71 do Complemento (Conhecimento de Transporte)   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTamLin := 103
			cLin    := Space(nTamLin)				 // Variavel para criacao da linha do registros para gravacao

			cLin := Stuff(cLin,03,03,"R71")									// Tipo
			cLin := Stuff(cLin,06,05,Space(05))								// Modelo de Transporte
			cLin := Stuff(cLin,11,02,Space(02))								// Série de Transporte
			cLin := Stuff(cLin,13,06,StrZero(0,6))							// Número Nota de Transporte
			cLin := Stuff(cLin,19,10,"00/00/0000")							// Data de Emissão
			cLin := Stuff(cLin,29,02,Space(02))								// UF de Transporte
			cCpo := StrZero(0,18)
			cLin := Stuff(cLin,31,18,cCpo)									// CNPJ
			cLin := Stuff(cLin,49,20,Space(20))							 	// Inscrição Estadual
			cCpo := StrZero(0,16,2)
			cLin := Stuff(cLin,69,16,StrTran(cCpo,".",","))	  				// Total do Transporte
			cLin := Stuff(cLin,85,10,StrZero(0,10))							// Chave NFE-Nota Fisc.Eletrônica
			cLin := Stuff(cLin,95,09,StrZero(0,09))							// Número Nota de Transporte

			cLin += _cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
					Exit
				Endif
			Endif

			dbSelectArea("WSF3")
			dbSkip()

		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ O arquivo texto das notas de        ³
		//³ servico canceladas deve ser fechado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fClose(nHdl)

	Endif

	dbSelectArea("WSF3")
	dbCloseArea()
	dbSelectArea("SF3")
	RetIndex("SF3")

Endif

If !Empty(cNomArq5)

	aServCanc := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento para as notas de servico Canceladas              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := ""
	cQuery += "SELECT * , R_E_C_N_O_ RECSF3 FROM "+RetSQlName("SF3")+" SF3 "
	cQuery += "WHERE "
	cQuery += "SF3.F3_FILIAL = '"+xFilial("SF3")+"' AND "
	cQuery += "SF3.F3_DTCANC >= '"+dtos(mv_par01)+"' AND SF3.F3_DTCANC <= '"+dtos(mv_par02)+"' AND "
	cQuery += "SF3.F3_CODISS <> '"+Space(TamSX3("F3_CODISS")[1])+"' AND "
	//cQuery += "SF3.F3_TIPO = 'S' AND "
	cQuery += "SF3.F3_CFO > '5000 ' AND "
	If !Empty(mv_par10)
		cQuery += "SF3.F3_NFISCAL = '"+mv_par10+"' AND "
	Endif
	cQuery += "SF3.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY F3_FILIAL,F3_EMISSAO,F3_NFISCAL,F3_SERIE"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSF3",.T.,.T.)
	aEval(SF3->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSF3",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSF3")
	Count to nTotReg
	dbGoTop()

	If !Bof() .and. !Eof()

		ProcRegua(nTotReg) // Numero de registros a processar

		cNFAnt   := ""

		While !Eof()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incrementa a regua                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc(OemToAnsi("Lendo Registros das Notas de Serviço Canceladas..."))

			If WSF3->F3_NFISCAL+WSF3->F3_SERIE == cNFAnt
				dbSkip()
				Loop
			Else
				cNFAnt := WSF3->F3_NFISCAL+WSF3->F3_SERIE
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Movimento Principal                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aServCanc , WSF3->RECSF3)
			dbSkip()

		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento para as notas de Prestacao de Servico    ³
		//³ que foram canceladas.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aServCanc) > 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abro novo arquivo. Agora para as notas    ³
			//³ de servico canceladas / inutilizadas      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nHdl := fCreate(cDir+cNomArq5)

			If nHdl == -1
				MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq5+" não pode ser executado! Verifique os parãmetros."),OemToAnsi("Atenção!"))
				Return
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cabecalho do arquivo                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If fWrite(nHdl,cLinCab,Len(cLinCab)) != Len(cLinCab)
				MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
				Return
			Endif

			ProcRegua(Len(aServCanc)) // Numero de registros a processar

			For ee:=1 to Len(aServCanc)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Incrementa a regua                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc(OemToAnsi("Lendo Registros das Notas de Serviços Canceladas..."))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Servico - Movimento Principal    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTamLin := 469
				cLin    := Space(nTamLin)				//	Variavel para criacao da linha do registros para gravacao

				dbSelectArea("SF3")
				dbGoTo(aServCanc[ee])

				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+SF3->(F3_CLIEFOR+F3_LOJA)))
				cCNPJ   := SA1->A1_CGC
				cNome   := SA1->A1_NOME
				cIE     := Iif(Empty(SA1->A1_INSCR),"ISENTO",SA1->A1_INSCR)
				cUF     := aUF[aScan(aUF,{|x| x[1] == SA1->A1_EST})][02]
				cCodM   := cUF+Iif(Empty(SA1->A1_COD_MUN),"3520509",SA1->A1_COD_MUN)
				cTipoCF := SA1->A1_TIPO
				cEnd    := Substr(SA1->A1_END,1,at(",",SA1->A1_END)-1)
				cNum    := StrZero(Val(Substr(SA1->A1_END,at(",",SA1->A1_END)+1)),5)
				cCEP    := Transform(SA1->A1_CEP,"@R 99999-999")
				cBairro := SA1->A1_BAIRRO
				cIMun   := SA1->A1_INSCRM
				cOptSimples := IIf(Empty(SA1->A1_SIMPNAC),"0",IIF(SA1->A1_SIMPNAC="1","1","0"))

				aDupli := {}
				nItem := 0
				nItemSD2 := 0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Substitui nas respectivas posicoes na variavel cLin pelo conteudo   ³
				//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
				//³ string dentro de outra string.                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCpo := PADR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),18)
				cLin := Stuff(cLin,01,18,cCpo)					// CNPJ da Empresa
				cLin := Stuff(cLin,19,01,"P")					// Tipo P=Prestacao de Servico
				cLin := Stuff(cLin,20,05,"NFS  ")          		// Espécie
				cLin := Stuff(cLin,25,03,"E  ") 				// Série
				cLin := Stuff(cLin,28,02,"  ")					// Sub Serie da nota
				cLin := Stuff(cLin,30,12,StrZero(0,12))		// Número do Documento Inicial/Final
				cCpo := GravaData(SF3->F3_EMISSAO,.T.,5)
				cLin := Stuff(cLin,42,10,DtoC(cCpo))			// Data do Documento
				cLin := Stuff(cLin,52,02,"  ")					// deixar em branco
				If SF3->F3_ESTADO == "EX"
					cCpo := PADR("P-030",18)
				Else
					If Len(Alltrim(cCNPJ)) == 14					// CNPJ do Cliente
						cCpo := Transform(cCNPJ,"@R 99.999.999/9999-99")
					ElseIf Len(Alltrim(cCNPJ)) == 11					// CPF do Cliente
						cCpo := Transform(cCNPJ,"@R 999.999.999-99")
					Else
						cCpo := Space(18)
					Endif
				Endif
				cLin := Stuff(cLin,54,18,cCpo)
				cCpo := Padr(cNome,40)
				cLin := Stuff(cLin,72,40,cCpo)             // Nome do Cliente
				cLin := Stuff(cLin,112,20,cIE)				// Inscr. Est. do Cliente
				If SF3->F3_ESTADO == "EX"
					cCpo := "99.999.99"
				Else
					If Empty(cCodM)
						cCpo := Space(9)
					Else
						cCpo := Transform(cCodM,"@R 99.999.99")
					Endif
				Endif
				cLin := Stuff(cLin,132,09,cCpo)							// Cód. IBGE (Cidade Cliente)
				cCpo := StrZero(0,12,2)
				cLin := Stuff(cLin,141,12,StrTran(cCpo,".",","))	// Valor Total da Nota Fiscal
				cCpo := "0"				// 0=Nota a vista
				cLin := Stuff(cLin,153,01,cCpo)						// Forma de pagto
				cLin := Stuff(cLin,154,02,"00")	        			// Desdobramento
				cCpo := StrZero(0,17,2)
				cLin := Stuff(cLin,156,05,Space(05))				// Objeto de Isenção
				cLin := Stuff(cLin,161,13,Space(13))				// Número do Alvará
				cLin := Stuff(cLin,174,100,Space(100))				// Número e Página do Livro 57
				cLin := Stuff(cLin,274,06,StrZero(0,6))			// Contador Z
				cLin := Stuff(cLin,280,40,Substr(cEnd,1,40))		// Endereco
				cLin := Stuff(cLin,320,05,cNum)	        			// Número
				cLin := Stuff(cLin,325,09,cCEP)		        		// CEP
				cLin := Stuff(cLin,334,30,cBairro)	        		// Bairro
				If SF3->F3_ESTADO == "EX"
					cLin := Stuff(cLin,364,02,Space(2))			// Sigla do País
				Else
					cLin := Stuff(cLin,364,02,"BR") 				// Sigla do País
				Endif
				cLin := Stuff(cLin,366,11,cIMun) 	 				// Inscrição Municipal
				cCpo := "0"
				cLin := Stuff(cLin,377,01,cCpo)		  				// Nota Conjugada
				cCpo := Substr(SF3->F3_CFO,1,1)
				cLin := Stuff(cLin,378,01,cCpo)						// Tipo de Operação
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,379,18,StrTran(cCpo,".",","))	// Valor do Desconto
				cLin := Stuff(cLin,397,20,Space(20))		        // Insc.Est.Secundária Cliente
				cLin := Stuff(cLin,417,09,Space(09))               // Município onde o ISS é Devido
				cLin := Stuff(cLin,426,03,StrZero(Len(aDupli),03)) // Quantidade de Parcelas
				cLin := Stuff(cLin,429,02,StrZero(0,02))           // Dia do Vencimento da Parcela
				cLin := Stuff(cLin,431,07,Space(07))	           // Período Inicial Parcelamento
				cLin := Stuff(cLin,438,01,StrZero(0,01))           // Dia vencto. p/ transf.
				cLin := Stuff(cLin,439,02,StrZero(0,02))           // Intervalo entre cada parcela
				cLin := Stuff(cLin,441,10,Space(10))           		// Dia Inicial do Parcelamento
				cCpo := StrZero(Val(SF3->F3_NFISCAL),9)+Space(9)
				cLin := Stuff(cLin,451,18,cCpo)	       				// Nº Documento Inicial e Final
				cLin := Stuff(cLin,469,01,cOptSimples)				// Optante do Simples Nacional

				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
						Exit
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Servico - Complemento do Movimento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTamLin := 492
				cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

				cLin := Stuff(cLin,03,12,StrZero(0,12))					// Num. Documento Mov. Princ.
				cLin := Stuff(cLin,15,02,Space(02))						// Centro de custo
				cLin := Stuff(cLin,17,03,Space(03))						// Conta Contabil
				cCpo1 := StrZero(0,12,2)
				cCpo2 := StrZero(0,07,2)
				cLin := Stuff(cLin,20,12,StrTran(cCpo1,".",","))			// Valor Contabil
				cLin := Stuff(cLin,32,12,StrTran(cCpo1,".",","))			// Base do ISS
				cLin := Stuff(cLin,44,07,StrTran(cCpo2,".",","))			// Aliquota do ISS
				cLin := Stuff(cLin,51,12,StrTran(cCpo1,".",","))			// Valor do ISS
				cLin := Stuff(cLin,63,12,StrTran(cCpo1,".",","))			// Valor do ISS Isento
				cLin := Stuff(cLin,75,12,StrTran(cCpo1,".",","))			// Atividade Mista
				cLin := Stuff(cLin,87,12,StrTran(cCpo1,".",","))			// Valor do INSS
				cCpo := Space(10)
				cLin := Stuff(cLin,99,10,cCpo)								// Codigo do Servico
				cLin := Stuff(cLin,109,12,StrTran(cCpo1,".",","))			// Empreitada
				cLin := Stuff(cLin,121,12,StrTran(cCpo1,".",","))			// Valor do IRRF
				cLin := Stuff(cLin,133,01,"0")								// Tipo Livro de Servico
				cLin := Stuff(cLin,134,03,"096")							// Codigo de Observacao
				cCpo := Space(250)
				cLin := Stuff(cLin,137,250,cCpo)							// Complemento da Observacao
				cLin := Stuff(cLin,387,12,StrTran(cCpo1,".",","))			// Valor ISS Retido
				cLin := Stuff(cLin,399,01,"1")								// Alíq.Cofins(Lucro Real/Estim.)
				cLin := Stuff(cLin,400,12,StrTran(cCpo1,".",","))			// Valor do PIS Retido
				cLin := Stuff(cLin,412,12,StrTran(cCpo1,".",","))			// Valor da Cofins Retido
				cLin := Stuff(cLin,424,12,StrTran(cCpo1,".",","))			// Valor da CSLL Retido
				cLin := Stuff(cLin,436,03,"000")							// Código Fiscal de Prestação de Serviço
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,439,18,StrTran(cCpo,".",","))			// Base Cálculo de IRRF
				cCpo := StrZero(0,6,2)
				cLin := Stuff(cLin,457,06,StrTran(cCpo,".",","))			// Alíquota do IRRF
				cLin := Stuff(cLin,463,03,StrZero(1,3))				// Quantidade Itens Desdobramento
				cLin := Stuff(cLin,466,05,Space(5))						// Cod.Tipo Serviço(Empr.Simples)
				cCpo := StrZero(Val(SF3->F3_NFISCAL),9)+Space(9)
				cLin := Stuff(cLin,471,18,cCpo)					   			// Nº Documento Mov. Princ.
				cLin := Stuff(cLin,489,04,Space(4))						// Cod Receita IRRF retido
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
						Exit
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Notas de Servico - Itens do Complemento     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTamLin := 301
				cLin    := Space(nTamLin)				 // Variavel para criacao da linha do registros para gravacao

				cLin := Stuff(cLin,05,03,StrZero(1,3))				// Número Item
				cLin := Stuff(cLin,08,14,Substr(SD2->D2_COD,1,14))			// Código Servico Empresa
				cLin := Stuff(cLin,22,53,Space(53))		// Descrição do Servico
				cLin := Stuff(cLin,75,45,Space(45))		// Descrição Complementar do servico
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,120,18,StrTran(cCpo,".",","))			// Valor Total do Servico
				cLin := Stuff(cLin,138,18,StrTran(cCpo,".",","))			// Valor Desconto
				cLin := Stuff(cLin,156,18,StrTran(cCpo,".",","))			// Base Cálculo de ISS
				cCpo := StrZero(0,06,2)
				cLin := Stuff(cLin,174,06,StrTran(cCpo,".",","))			// Aliquota do ISS
				cCpo := StrZero(0,18,2)
				cLin := Stuff(cLin,180,18,StrTran(cCpo,".",","))			// Valor do ISS
				If SF3->F3_ESTADO == "EX"
					cLin := Stuff(cLin,198,02,Space(2))								// Classificacao Trib PIS
					cCpo1 := StrZero(0,12,2)
					cCpo2 := StrZero(0,7,4)
					cLin := Stuff(cLin,200,12,StrTran(cCpo1,".",","))			// Base de Calculo PIS
					cLin := Stuff(cLin,212,07,StrTran(cCpo2,".",","))			// Aliquota PIS
					cLin := Stuff(cLin,219,12,StrTran(cCpo1,".",","))			// Quantidade PIS
					cLin := Stuff(cLin,231,07,StrTran(cCpo2,".",","))			// Aliquota PIS em Reais
					cLin := Stuff(cLin,238,12,StrTran(cCpo1,".",","))			// Valor do PIS
					cLin := Stuff(cLin,250,02,Space(2))								// Classificacao Trib PIS
					cLin := Stuff(cLin,252,12,StrTran(cCpo1,".",","))			// Base de Calculo COFINS
					cLin := Stuff(cLin,264,07,StrTran(cCpo2,".",","))			// Aliquota COFINS
					cLin := Stuff(cLin,271,12,StrTran(cCpo1,".",","))			// Quantidade COFINS
					cLin := Stuff(cLin,283,07,StrTran(cCpo2,".",","))			// Aliquota COFINS em Reais
					cLin := Stuff(cLin,290,12,StrTran(cCpo1,".",","))			// Valor do COFINS
				Else
					cLin := Stuff(cLin,198,02,Space(2))								// Classificacao Trib PIS
					cCpo := StrZero(0,12,2)
					cLin := Stuff(cLin,200,12,StrTran(cCpo,".",","))			// Base de Calculo PIS
					cCpo := StrZero(0,7,4)
					cLin := Stuff(cLin,212,07,StrTran(cCpo,".",","))			// Aliquota PIS
					cCpo := StrZero(0,12,3)
					cLin := Stuff(cLin,219,12,StrTran(cCpo,".",","))			// Quantidade PIS
					cCpo := StrZero(0,7,4)
					cLin := Stuff(cLin,231,07,StrTran(cCpo,".",","))			// Aliquota PIS em Reais
					cCpo := StrZero(0,12,2)
					cLin := Stuff(cLin,238,12,StrTran(cCpo,".",","))			// Valor do PIS
					cLin := Stuff(cLin,250,02,Space(2))								// Classificacao Trib PIS
					cCpo := StrZero(0,12,2)
					cLin := Stuff(cLin,252,12,StrTran(cCpo,".",","))			// Base de Calculo COFINS
					cCpo := StrZero(0,7,4)
					cLin := Stuff(cLin,264,07,StrTran(cCpo,".",","))			// Aliquota COFINS
					cCpo := StrZero(0,12,3)
					cLin := Stuff(cLin,271,12,StrTran(cCpo,".",","))			// Quantidade COFINS
					cCpo := StrZero(0,7,4)
					cLin := Stuff(cLin,283,07,StrTran(cCpo,".",","))			// Aliquota COFINS em Reais
					cCpo := StrZero(0,12,2)
					cLin := Stuff(cLin,290,12,StrTran(cCpo,".",","))			// Valor do COFINS
				Endif
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
						Exit
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PARCELAS DE NOTA A PRAZO                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTamLin := 31
				cLin    := Space(nTamLin)				// Variavel para criacao da linha do registros para gravacao

				cLin := Stuff(cLin,03,05,Space(3))					// Tipo de Parcela
				cLin := Stuff(cLin,06,15,DtoC(CtoD(Space(8))))		// Data de Vencimento
				cCpo := StrZero(0,16,2)
				cLin := Stuff(cLin,16,31,StrTran(cCpo,".",","))	// Valor da Parcela
				cLin += _cEOL

				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo. Continua?"),OemToAnsi("Atenção!"))
						Exit
					Endif
				Endif

			Next ee

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O arquivo texto das notas de        ³
			//³ servico canceladas deve ser fechado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fClose(nHdl)

		Endif

	Endif

	dbSelectArea("WSF3")
	dbCloseArea()
	dbSelectArea("SF3")
	RetIndex("SF3")

Endif

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
