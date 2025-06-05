#include "rwmake.ch"

/*/{Protheus.doc} ExpCSV02
Exporta dados de Notas de Saida
@author Unknown
@since 14/02/2008

/*/
User Function ExpCSV02()

	Local aSays      := {}
	Local aButtons   := {}
	Local cCadastro  := OemToansi('Geração de arquivo texto para Planilha Excel')
	Local lOkParam   := .F.
	Local cPerg      := PADR("EXCSV2",10) , aPergs := {}
	Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
	Local cMens      := OemToAnsi('A opção de Parâmetros desta rotina deve ser acessada antes de sua execução!')


	/**
	* Organiza o Grupo de Perguntas e Help
	**/
	aHelpPor := {}
	aAdd(aHelpPor,"Informe a data inicial a ser considerada")
	aAdd(aHelpPor,"na filtragem das informações.")
	Aadd(aPergs,{"Da Data","","","mv_ch1","D",8,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe a data final a ser considerada")
	aAdd(aHelpPor,"na filtragem das informações.")
	Aadd(aPergs,{"Ate a Data","","","mv_ch2","D",8,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe o diretório em que será gerado")
	aAdd(aHelpPor,"o arquivo.")
	aAdd(aHelpPor,"Por exemplo: C:\TEMP\")
	Aadd(aPergs,{"Diretorio","","","mv_ch3","C",30,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Dê um nome para o arquivo.")
	aAdd(aHelpPor,"SEMPRE INDIQUE A EXTENSÃO CSV.")
	aAdd(aHelpPor,"Por exemplo: EUROFINS.CSV")
	Aadd(aPergs,{"Arquivo","","","mv_ch4","C",20,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe o código do produto inicial a ser")
	aAdd(aHelpPor,"considerado na filtragem das informações.")
	Aadd(aPergs,{"Do Produto","","","mv_ch5","C",15,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe o código do produto final a ser")
	aAdd(aHelpPor,"considerado na filtragem das informações.")
	Aadd(aPergs,{"Ate o Produto","","","mv_ch6","C",15,0,1,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",aHelpPor,aHelpIng,aHelpEsp})

	aHelpPor := {}
	aAdd(aHelpPor,"Informe se serão consideradas as saidas")
	aAdd(aHelpPor,"que geraram financeiro, ou não geraram ")
	aAdd(aHelpPor,"ou ambas.  ")
	Aadd(aPergs,{"Qto ao TES","","","mv_ch7","N",1,0,1,"C","","MV_PAR07","Gera Financ.","","","","","Nao Gera Financ.","","","","","Ambas","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe se serão consideradas as saidas")
	aAdd(aHelpPor,"que geraram financeiro, ou não geraram ")
	aAdd(aHelpPor,"ou ambas.  ")
	Aadd(aPergs,{"Nota De","","","mv_ch8","N",1,0,1,"C","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","SF2","","","","",aHelpPor,aHelpIng,aHelpEsp})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe se serão consideradas as saidas")
	aAdd(aHelpPor,"que geraram financeiro, ou não geraram ")
	aAdd(aHelpPor,"ou ambas.  ")
	Aadd(aPergs,{"Nota Ate","","","mv_ch9","N",1,0,1,"C","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SF2","","","","",aHelpPor,aHelpIng,aHelpEsp})

	/**
	* Cria, se necessario, o grupo de Perguntas
	**/
	//AjustaSx1(cPerg,aPergs)

	/**
	* Monta Interface com o usuario
	**/
	aAdd(aSays,OemToAnsi('Este programa visa gerar um arquivo texto com informações das notas'))
	aAdd(aSays,OemToAnsi('de saída, do período que for determinado nos parâmetros, para poder'))
	aAdd(aSays,OemToAnsi('ser lido em uma Planilha do MS-Excel.'))
	aAdd(aSays,OemToAnsi('Os códigos dos produtos também serão listados.'))
	aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
	aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| GeraArq()}),o:oWnd:End()),Aviso(OemToAnsi('Atenção!!!'), cMens , {'Ok'})) } } )
	aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( cCadastro, aSays, aButtons,,230,430 ) // altura x largura

Return


/**
* Funcao chamada pelo botao OK na tela inicial de processamento. Executa a geracao do arquivo texto.
**/
Static Function GeraArq()

	Local cDir    := ""
	Local cNomArq := Alltrim(mv_par04)

	nPos := Rat(".",cNomArq)

	If nPos > 0
		If Substr(cNomArq,nPos) # ".CSV"
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
	/**
	* Se nao existir, cria o diretorio, e em seguida, cria o arquivo texto.
	**/
	MontaDir(cDir)
	nHdl := fCreate(cDir+cNomArq)

	If nHdl == -1
		MsgAlert(OemToAnsi("O arquivo de nome "+cDir+cNomArq+" não pode ser executado! Verifique os parâmetros."),OemToAnsi("Atenção!"))
		Return
	Endif

	/**
	* Inicializa a regua de processamento
	**/
	Processa({|| RunCont() },"Processando...")

Return


/**
* Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA monta a janela com a regua de processamento.
**/
Static Function RunCont()

	Local cCpo       := ""
	Local cFiltro    := ""
	Local cCodAnt    := ""
	Local nTot01     := 0
	Local nTot02     := 0
	Local nTotLiq01  := 0
	Local nTotLiq02  := 0
	Local cChaveSD2  := ""
	Local cNomArqSD2 := ""
	Local lFirst     := .T.

	Private aDados1 := {}
	Private aDados2 := {}
	Private cSerieProd := GetMV("MV_ZZSERPR")
	Private cUtilContr := GetMV("MV_ZZUTCTR")

	Private nTamLin := 335 //Eurofins

	//If Substr(SM0->M0_CODFIL,1,2) == '05' //Anatech
		nTamLin := 707
	//ElseIf Substr(SM0->M0_CODFIL,1,2) == '02' //Innolab
	//	nTamLin := 324
	//ElseIf Substr(SM0->M0_CODFIL,1,2) == '04' //Alac
	//	nTamLin := 322
	//endif

	Private cLin    := Space(nTamLin)	//	Variavel para criacao da linha do registros para gravacao
	Private _cEOL   := "CHR(13)+CHR(10)"
	_cEOL := Trim(_cEOL)
	_cEOL := &_cEOL

/*
Codigo Produto ;Centro Custo+Conta Contabil+Descricao       ;Descricao Produto                                 ;Dt Em NF;Numero NF;Nome Cliente                            ;Valor Tot NF;Valor Líquid;Segmento de Mercado                                        ;Cd Cli;Lja;CPF/CNPJ         ;Vendedor                                       ;CPF/CNPJ Contrat  ;Nome Contratante                                  ;Contato Contratante           ;CPF/CNPJ Solicit  ;Nome Solicitante                                  ;Contato Solicitante           ;CPF/CNPJ Represent;Nome Representante do Servico                     ;Contato Representante         ;CPF/CNPJ Faturam. ;Nome Faturamento do Servico                       ;Contato Faturamento
xxxxxxxxxxxxxxx;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;99/99/99;999999999;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;999999999,99;999999999,99;999-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;999999;99;99.999.999/9999-99;XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;99.999.999/9999-99;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;99.999.999/9999-99;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;99.999.999/9999-99;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;99.999.999/9999-99;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*/

	SB1->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	SF2->(dbSetOrder(1))
	SZ0->(dbSetOrder(1))

	dbSelectArea("SD2")
	cFiltro := 'D2_FILIAL=="'+xFilial("SD2")+'" .and. '
	cFiltro += 'DTOS(D2_EMISSAO)>="'+dtos(mv_par01)+'" .and. DTOS(D2_EMISSAO)<="'+dtos(mv_par02)+'" .and. D2_DOC >="'+MV_PAR08+'" .and. D2_DOC <= "'+MV_PAR09+'" .and. '

	If Empty(cSerieProd)
		cSerieProd := "X  "
	endif
	cFiltro += 'D2_SERIE <> "'+cSerieProd+'" .and. !(D2_TIPO $ "DB") .and. '
	cFiltro += 'D2_COD >= "'+mv_par05+'" .and. D2_COD <= "'+mv_par06+'"'
	cChaveSD2  := 'D2_FILIAL+D2_COD+DTOS(D2_EMISSAO)+D2_DOC+D2_SERIE'
	cNomArqSD2 := CriaTrab(Nil,.F.)
	IndRegua("SD2",cNomArqSD2,cChaveSD2,,cFiltro,OemToAnsi("Selecionando Registros..."))

	dbSelectArea("SD2")
	#IfNDEF TOP
		dbSetIndex(cNomArqSD2+OrdBagExt())
	#endif

	dbGoTop()

	ProcRegua(RecCount()) // Numero de registros a processar

	While SD2->(!(Eof()))

		/**
		* Incrementa a regua
		**/
		IncProc(OemToAnsi("Processando informações..."))

		If lFirst
			//If Substr(SM0->M0_CODFIL,1,2) == '05'
			If cUtilContr == .T.
				cLin := "Codigo Produto;Centro Custo;Conta Contabil;Descricao;Descricao Produto;Data Emissao NF;Numero NF;Nome Cliente;Valor Total NF;Valor Líquido;Segmento de Mercado;Codigo Cliente;Loja Cliente;CPF/CNPJ;Vendedor;CPF/CNPJ Contratante;Nome Contratante;Contato Contratante;CPF/CNPJ Solicitante;Nome Solicitante;Contato Solicitante;CPF/CNPJ Representante;Nome Representante do Servico;Contato Representante;CPF/CNPJ Faturamento;Nome Faturamento do Servico;Contato Faturamento"
			Else
				cLin := "Codigo Produto;Centro Custo;Conta Contabil;Descricao;Descricao Produto;Data Emissao NF;Numero NF;Nome Cliente;Valor Total NF;Valor Líquido;Segmento de Mercado;Codigo Cliente;Loja Cliente;CPF/CNPJ;Vendedor"
			Endif
			cLin += _cEOL
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
				Exit
			Endif
			cLin := Space(nTamLin)				//	Variavel para criacao da linha do registros para gravacao
			lFirst := .F.
		Endif

		If SD2->D2_COD < mv_par05 .or. SD2->D2_COD > mv_par06
			SD2->(dbSkip())
			Loop
		Endif

		SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES))
		SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))

		If mv_par07 == 1 .and. SF4->F4_DUPLIC == "N"
			SD2->(dbSkip())
			Loop
		Endif

		If mv_par07 == 2 .and. SF4->F4_DUPLIC == "S"
			SD2->(dbSkip())
			Loop
		Endif

		/*
		SF2->(dbSeek(xFilial("SF2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
		If !Empty(SF2->F2_X_CLAS1)
			SZ0->(dbSeek(xFilial("SZ0")+SF2->F2_X_CLAS1))
			cDadosCont := SZ0->Z0_CCUSTO+"-"+SZ0->Z0_CONTA+"-"+SZ0->Z0_DESCRIC
		Else
			cDadosCont := Space(44)
		Endif
		*/

		If Empty(cCodAnt)
			cCodAnt := D2_COD
		Else
			If SD2->D2_COD # cCodAnt
				Quebra(nTot01,nTotLiq01,cCodAnt)
				cCodAnt   := D2_COD
				nTot01    := 0
				nTotLiq01 := 0
			Endif
		Endif

		nPos1 := aScan(aDados1 , {|x| x[1] == cCodAnt})
		If nPos1 == 0
			aadd(aDados1, {cCodAnt , SB1->B1_DESC , SD2->D2_QUANT , SD2->(D2_TOTAL+D2_VALIPI) , "", ((SD2->D2_TOTAL)-(SD2->D2_VALICM + SD2->D2_VALIMP5 + SD2->D2_VALIMP6 )) })
		Else
			aDados1[nPos1,3] += SD2->D2_QUANT
			aDados1[nPos1,4] += SD2->(D2_TOTAL+D2_VALIPI)
			aDados1[nPos1,6] += ((SD2->D2_TOTAL)-(SD2->D2_VALICM + SD2->D2_VALIMP5 + SD2->D2_VALIMP6 ))
		Endif

		cCC := Space(TamSX3("Z0_CCUSTO")[1]+TamSX3("Z0_CONTA")[1]+TamSX3("Z0_DESCRIC")[1])+Space(2)
		If !(Empty(SD2->D2_ZZCC))
			SZ0->(dbSeek(xFilial("SZ0")+SD2->D2_ZZCC))
			cDadosCont := SZ0->Z0_CCUSTO+"-"+SZ0->Z0_CONTA+"-"+SZ0->Z0_DESCRIC
			cDCCUSTO := SZ0->Z0_CCUSTO
			cDCCONTA := SZ0->Z0_CONTA
			cDCDESCR := SZ0->Z0_DESCRIC
			cCC := SZ0->Z0_CCUSTO+Space(TamSX3("Z0_CONTA")[1]+TamSX3("Z0_DESCRIC")[1])+Space(2)
		Else
			cDadosCont := Space(44)
			cDCCUSTO := ""
			cDCCONTA := ""
			cDCDESCR := ""
		Endif

		If nPos1 == 0
			aDados1[Len(aDados1),5] := 	cCC
		Else
			aDados1[nPos1,5] := cCC
		Endif

		If !(Empty(cDadosCont))
			nPos2 := aScan(aDados2 , {|x| x[1] == SZ0->Z0_CCUSTO})
			If nPos2 == 0
				aadd(aDados2 , {SZ0->Z0_CCUSTO , SZ0->Z0_DESCRIC , SD2->(D2_TOTAL+D2_VALIPI) , ((SD2->D2_TOTAL)-(SD2->D2_VALICM + SD2->D2_VALIMP5 + SD2->D2_VALIMP6)) })
			Else
				aDados2[nPos2,3] += SD2->(D2_TOTAL+D2_VALIPI)
				aDados2[nPos2,4] += ((SD2->D2_TOTAL)-(SD2->D2_VALICM + SD2->D2_VALIMP5 + SD2->D2_VALIMP6))
			Endif
		Endif

		cLin := Space(nTamLin)

		cCpo := D2_COD+";"
		cLin := Stuff(cLin,01,Len(cCpo),cCpo)						// Codigo do produto

		//cCpo := cDadosCont+";"
		//cLin := Stuff(cLin,17,Len(cCpo),cCpo)						// Centro de Custo + Conta Contabil + Descricao
		cCpo := cDCCUSTO+";"
		cLin := Stuff(cLin,17,Len(cCpo),cCpo)						// Centro de Custo

		cCpo := cDCCONTA+";"
		cLin := Stuff(cLin,24,Len(cCpo),cCpo)						// Conta Contabil

		cCpo := cDCDESCR+";"
		cLin := Stuff(cLin,33,Len(cCpo),cCpo)						// Descricao

		cCpo := SB1->B1_DESC+";"
		cLin := Stuff(cLin,65,45,cCpo)						// descricao do produto

		cCpo := Transform(GravaData(D2_EMISSAO,.F.,1),"@R 99/99/99")+";"
		cLin := Stuff(cLin,113,Len(cCpo),cCpo)						// Emissao da nota

		cCpo := D2_DOC+";"
		cLin := Stuff(cLin,122,Len(cCpo),cCpo)						// Numero da nota

		cCpo := Posicione("SA1",1,xFilial("SA1")+SD2->(D2_CLIENTE+D2_LOJA),"A1_NOME")+";"
		cLin := Stuff(cLin,132,Len(cCpo),cCpo)						// Nome do cliente

		cCpo := StrZero(SD2->(D2_TOTAL+D2_VALIPI),12,2)+";"
		cLin := Stuff(cLin,173,Len(cCpo),StrTran(cCpo,".",","))	// Valor Total da Nota Fiscal

		cCpo := StrZero( (SD2->D2_TOTAL)-(SD2->D2_VALICM + SD2->D2_VALIMP5 + SD2->D2_VALIMP6),12,2)+";"
		cLin := Stuff(cLin,186,Len(cCpo),StrTran(cCpo,".",","))	// Valor Líquido

		cCpox := Posicione("SA1",1,xFilial("SA1")+SD2->(D2_CLIENTE+D2_LOJA),"A1_SATIV1")
		cCpo := Substr(cCpox,1,3)+"-"+Posicione("SX5",1,xFilial("SX5")+"T3"+cCpox,"X5_DESCRI")+";"
		cLin := Stuff(cLin,199,Len(cCpo),cCpo)						// Segmento de Mercado

		cCpo := SD2->D2_CLIENTE+";"
		cLin := Stuff(cLin,259,Len(cCpo),cCpo)						// Codigo cliente

		cCpo := SD2->D2_LOJA+";"
		cLin := Stuff(cLin,266,Len(cCpo),cCpo)						// Loja cliente

		cCpo := Posicione("SA1",1,xFilial("SA1")+SD2->(D2_CLIENTE+D2_LOJA),"A1_CGC")
		If Len(alltrim(cCpo))==14
			cCpo := Transform(cCpo,"@R 99.999.999/9999-99")+";"
		Elseif Len(alltrim(cCpo))==11
			cCpo := Transform(cCpo,"@R 999.999.999-99")+";"
		Endif
		cLin := Stuff(cLin,269,Len(cCpo),cCpo)					// CPF / CNPJ

		cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_VEND1")
		cCpo += "-"+Posicione("SA3",1,xFilial("SA3")+cCpo,"A3_NOME")
		cLin := Stuff(cLin,288,Len(cCpo),cCpo)					// Vendedor 1

		//If Substr(SM0->M0_CODFIL,1,2) == '05'
		If cUtilContr == .T.
			cCpo  := ";"
			cCpox := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_ZZCNPJC")
			If Len(alltrim(cCpox))==14
				cCpo += Transform(cCpox,"@R 99.999.999/9999-99")+";"
			Elseif Len(alltrim(cCpox))==11
				cCpo += Transform(cCpox,"@R 999.999.999-99")+";"
			Else
				cCpo += Space(18)+";"
			Endif
			cLin := Stuff(cLin,335,Len(cCpo),cCpo)					// CNPJ Contratante

			cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_ZZNOMEC")+";"
			cLin := Stuff(cLin,355,Len(cCpo),cCpo)					// Nome Contratante

			//cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XCONTCO")+";"
			//cLin := Stuff(cLin,406,Len(cCpo),cCpo)					// Contato Contratante
        /*
			cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XCNPJSO")
			If Len(alltrim(cCpo))==14
				cCpo := Transform(cCpo,"@R 99.999.999/9999-99")+";"
			Elseif Len(alltrim(cCpo))==11
				cCpo := Transform(cCpo,"@R 999.999.999-99")+";"
			Else
				cCpo := Space(18)+";"
			Endif
			cLin := Stuff(cLin,437,Len(cCpo),cCpo)					// CNPJ Solicitante
		*/
			//cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XNOMESO")+";"
			//cLin := Stuff(cLin,456,Len(cCpo),cCpo)					// Nome Solicitante

			//cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XCONTSO")+";"
			//cLin := Stuff(cLin,507,Len(cCpo),cCpo)					// Contato Solicitante
		/*
			cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XCNPJRE")
			If Len(alltrim(cCpo))==14
				cCpo := Transform(cCpo,"@R 99.999.999/9999-99")+";"
			Elseif Len(alltrim(cCpo))==11
				cCpo := Transform(cCpo,"@R 999.999.999-99")+";"
			Else
				cCpo := Space(18)+";"
			Endif
			cLin := Stuff(cLin,538,Len(cCpo),cCpo)					// CNPJ Representante
		*/
			//cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XNOMERE")+";"
			//cLin := Stuff(cLin,557,Len(cCpo),cCpo)					// Nome Representante

			//cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XCONTRE")+";"
			//cLin := Stuff(cLin,608,Len(cCpo),cCpo)					// Contato Representante
		/*
			cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XCNPJFA")
			If Len(alltrim(cCpo))==14
				cCpo := Transform(cCpo,"@R 99.999.999/9999-99")+";"
			Elseif Len(alltrim(cCpo))==11
				cCpo := Transform(cCpo,"@R 999.999.999-99")+";"
			Else
				cCpo := Space(18)+";"
			Endif
			cLin := Stuff(cLin,639,Len(cCpo),cCpo)					// CNPJ Faturamento
		*/
			//cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XNOMEFA")+";"
			//cLin := Stuff(cLin,658,Len(cCpo),cCpo)					// Nome Faturamento

			//cCpo := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_XCONTFA")
			//cLin := Stuff(cLin,709,Len(cCpo),cCpo)					// Contato Faturamento

 		Endif

		cLin += _cEOL

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
			Return
		Endif

		nTot01    += SD2->(D2_TOTAL+D2_VALIPI)
		nTot02    += SD2->(D2_TOTAL+D2_VALIPI)
		nTotLiq01 += ((SD2->D2_TOTAL)-(SD2->D2_VALICM + SD2->D2_VALIMP5 + SD2->D2_VALIMP6))
		nTotLiq02 += ((SD2->D2_TOTAL)-(SD2->D2_VALICM + SD2->D2_VALIMP5 + SD2->D2_VALIMP6))

		dbSelectArea("SD2")
		dbSkip()

	Enddo

	If nTot02 > 0

		Quebra(nTot01,nTotLiq01,cCodAnt)
		Quebra(nTot02,nTotLiq02," ")

	Endif

	dbSelectArea("SD2")
	RetIndex("SD2")
	#IfNDEF TOP
		fErase(cNomArqSD2+OrdBagExt())
	#endif

	/**
	* O arquivo texto deve ser fechado.
	**/
	fClose(nHdl)

Return


/**
* Funcao para acessar o grupo de perguntas
**/
Static Function AcessaPar(cPerg,lOk)

	If Pergunte(cPerg)
		lOk := .T.
	Endif

Return(lOk)


/**
* Funcao para imprimir o SubTotal por Produto e o Total Geral
**/
Static Function Quebra(nValor,nVlrLiq,cCodAnt)

	cLin := Space(nTamLin)

	cCpo := Space(TamSX3("D2_COD")[1])+";"
	cLin := Stuff(cLin,01,Len(cCpo),cCpo)						// Codigo do produto

	cCpo := Space(5)+";"
	cLin := Stuff(cLin,17,Len(cCpo),cCpo)						// Centro de Custo

	cCpo := Space(7)+";"
	cLin := Stuff(cLin,24,Len(cCpo),cCpo)						// Conta Contabil

	cCpo := Space(30)+";"
	cLin := Stuff(cLin,33,Len(cCpo),cCpo)						// Descricao

	If !(Empty(cCodAnt))
		cCpo := Space(05)+"TOTAL PRODUTO ----> "+cCodAnt+";"
	Else
		cCpo := Space(05)+"TOTAL GERAL ------> "+Space(15)+";"
	Endif
	cLin := Stuff(cLin,65,45,cCpo)						// Descricao do produto

	cCpo := Space(TamSX3("D2_EMISSAO")[1])+";"
	cLin := Stuff(cLin,113,Len(cCpo),cCpo)						// Emissao da nota

	cCpo := Space(TamSX3("D2_DOC")[1])+";"
	cLin := Stuff(cLin,122,Len(cCpo),cCpo)						// Numero da nota

	cCpo := Space(TamSX3("A1_NOME")[1])+";"
	cLin := Stuff(cLin,132,Len(cCpo),cCpo)						// Nome do cliente

	cCpo := StrZero(nValor,12,2)+";"
	cLin := Stuff(cLin,173,Len(cCpo),StrTran(cCpo,".",","))	// Valor Total da Nota Fiscal

	cCpo := StrZero(nVlrLiq,12,2)+";"
	cLin := Stuff(cLin,186,Len(cCpo),StrTran(cCpo,".",","))	// Valor Líquido

	cCpo := Space(4)+Space(TamSX3("X5_DESCRI")[1])+";"
	cLin := Stuff(cLin,199,Len(cCpo),cCpo)						// Segmento de Mercado

	cCpo := Space(TamSX3("A1_COD")[1])+";"
	cLin := Stuff(cLin,259,Len(cCpo),cCpo)						// Codigo cliente

	cCpo := Space(TamSX3("A1_LOJA")[1])+";"
	cLin := Stuff(cLin,266,Len(cCpo),cCpo)						// Loja cliente

	cCpo := Space(TamSX3("A1_CGC")[1])+";"
	cLin := Stuff(cLin,269,Len(cCpo),cCpo)						// CNPJ / CPF

	cCpo := Space(TamSX3("A3_COD")[1]+TamSX3("A3_NOME")[1]+1)
	cLin := Stuff(cLin,288,Len(cCpo),cCpo)						// Vendedor 1

	//If Substr(SM0->M0_CODFIL,1,2) == '05'
	If cUtilContr == .T.
		cCpo := ";"+Space(TamSX3("C5_ZZCNPJC")[1])+";"
		cLin := Stuff(cLin,335,Len(cCpo),cCpo)					// CNPJ Contratante

		cCpo := Space(TamSX3("C5_ZZNOMEC")[1])+";"
		cLin := Stuff(cLin,355,Len(cCpo),cCpo)					// Nome Contratante
/*
		cCpo := Space(TamSX3("C5_XCONTCO")[1])+";"
		cLin := Stuff(cLin,406,Len(cCpo),cCpo)					// Contato Contratante

		cCpo := Space(TamSX3("C5_XCNPJSO")[1])+";"
		cLin := Stuff(cLin,437,Len(cCpo),cCpo)					// CNPJ Solicitante

		cCpo := Space(TamSX3("C5_XNOMESO")[1])+";"
		cLin := Stuff(cLin,456,Len(cCpo),cCpo)					// Nome Solicitante

		cCpo := Space(TamSX3("C5_XCONTSO")[1])+";"
		cLin := Stuff(cLin,507,Len(cCpo),cCpo)					// Contato Solicitante

		cCpo := Space(TamSX3("C5_XCNPJRE")[1])+";"
		cLin := Stuff(cLin,538,Len(cCpo),cCpo)					// CNPJ Representante

		cCpo := Space(TamSX3("C5_XNOMERE")[1])+";"
		cLin := Stuff(cLin,557,Len(cCpo),cCpo)					// Nome Representante

		cCpo := Space(TamSX3("C5_XCONTRE")[1])+";"
		cLin := Stuff(cLin,608,Len(cCpo),cCpo)					// Contato Representante

		cCpo := Space(TamSX3("C5_XCNPJFA")[1])+";"
		cLin := Stuff(cLin,639,Len(cCpo),cCpo)					// CNPJ Faturamento

		cCpo := Space(TamSX3("C5_XNOMEFA")[1])+";"
		cLin := Stuff(cLin,658,Len(cCpo),cCpo)					// Nome Faturamento

		cCpo := Space(TamSX3("C5_XCONTFA")[1]+1)
		cLin := Stuff(cLin,709,Len(cCpo),cCpo)					// Contato Faturamento
*/
	Endif

	cLin += _cEOL

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
		Return
	Endif

	cLin := Space(nTamLin)
	cLin += _cEOL

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
		Return
	Endif

	If Empty(cCodAnt)

		cLin := Space(nTamLin)
		cLin += _cEOL

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
			Return
		Endif

		For nA:=1 to Len(aDados1)

			cLin := Space(nTamLin)

			cCpo := aDados1[nA,1]+";"
			cLin := Stuff(cLin,01,Len(cCpo),cCpo)						// Codigo do produto

			cCpo := Alltrim(aDados1[nA,5])+";"
			cLin := Stuff(cLin,17,6,cCpo)						// Centro de Custo
			cCpo := Space(5)+";"
			cLin := Stuff(cLin,24,Len(cCpo),cCpo)						// Conta Contabil
			cCpo := Space(30)+";"
			cLin := Stuff(cLin,33,Len(cCpo),cCpo)						// Descricao

			cCpo := aDados1[nA,2]+";"
			cLin := Stuff(cLin,65,45,cCpo)						// Descricao do produto

			cCpo := Space(TamSX3("D2_EMISSAO")[1])+";"
			cLin := Stuff(cLin,113,Len(cCpo),cCpo)						// Emissao da nota

			cCpo := Space(TamSX3("D2_DOC")[1])+";"
			cLin := Stuff(cLin,122,Len(cCpo),cCpo)						// Numero da nota

			cCpo := StrZero(aDados1[nA,3],12,2)+";"
			cLin := Stuff(cLin,132,Len(cCpo),StrTran(cCpo,".",","))		// Nome do cliente (quantidade)

			cCpo := StrZero(aDados1[nA,4],12,2)+";"
			cLin := Stuff(cLin,173,Len(cCpo),StrTran(cCpo,".",","))		// Valor Total da Nota Fiscal

			cCpo := StrZero(aDados1[nA,6],12,2)+";"
			cLin := Stuff(cLin,186,Len(cCpo),StrTran(cCpo,".",","))	// Valor Líquido

			cCpo := Space(4)+Space(TamSX3("X5_DESCRI")[1])+";"
			cLin := Stuff(cLin,199,Len(cCpo),cCpo)						// Segmento de Mercado

			cCpo := Space(TamSX3("A1_COD")[1])+";"
			cLin := Stuff(cLin,259,Len(cCpo),cCpo)						// Codigo cliente

			cCpo := Space(TamSX3("A1_LOJA")[1])+";"
			cLin := Stuff(cLin,266,Len(cCpo),cCpo)						// Loja cliente

			cCpo := Space(TamSX3("A1_CGC")[1])+";"
			cLin := Stuff(cLin,269,Len(cCpo),cCpo)						// CNPJ / CPF

			cCpo := Space(TamSX3("A3_COD")[1]+TamSX3("A3_NOME")[1]+1)
			cLin := Stuff(cLin,288,Len(cCpo),cCpo)						// Vendedor 1

			//If Substr(SM0->M0_CODFIL,1,2) == '05'
			If cUtilContr == .T.
				cCpo := ";"+Space(TamSX3("C5_ZZCNPJC")[1])+";"
				cLin := Stuff(cLin,335,Len(cCpo),cCpo)					// CNPJ Contratante

				cCpo := Space(TamSX3("C5_ZZNOMEC")[1])+";"
				cLin := Stuff(cLin,355,Len(cCpo),cCpo)					// Nome Contratante
/*
				cCpo := Space(TamSX3("C5_XCONTCO")[1])+";"
				cLin := Stuff(cLin,406,Len(cCpo),cCpo)					// Contato Contratante

				cCpo := Space(TamSX3("C5_XCNPJSO")[1])+";"
				cLin := Stuff(cLin,437,Len(cCpo),cCpo)					// CNPJ Solicitante

				cCpo := Space(TamSX3("C5_XNOMESO")[1])+";"
				cLin := Stuff(cLin,456,Len(cCpo),cCpo)					// Nome Solicitante

				cCpo := Space(TamSX3("C5_XCONTSO")[1])+";"
				cLin := Stuff(cLin,507,Len(cCpo),cCpo)					// Contato Solicitante

				cCpo := Space(TamSX3("C5_XCNPJRE")[1])+";"
				cLin := Stuff(cLin,538,Len(cCpo),cCpo)					// CNPJ Representante

				cCpo := Space(TamSX3("C5_XNOMERE")[1])+";"
				cLin := Stuff(cLin,557,Len(cCpo),cCpo)					// Nome Representante

				cCpo := Space(TamSX3("C5_XCONTRE")[1])+";"
				cLin := Stuff(cLin,608,Len(cCpo),cCpo)					// Contato Representante

				cCpo := Space(TamSX3("C5_XCNPJFA")[1])+";"
				cLin := Stuff(cLin,639,Len(cCpo),cCpo)					// CNPJ Faturamento

				cCpo := Space(TamSX3("C5_XNOMEFA")[1])+";"
				cLin := Stuff(cLin,658,Len(cCpo),cCpo)					// Nome Faturamento

				cCpo := Space(TamSX3("C5_XCONTFA")[1]+1)
				cLin := Stuff(cLin,709,Len(cCpo),cCpo)					// Contato Faturamento
*/
			Endif

			cLin += _cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
				Return
			Endif

		Next

		cLin := Space(nTamLin)
		cLin += _cEOL

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
			Return
		Endif
		cLin := Space(nTamLin)
		cLin += _cEOL

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
			Return
		Endif

		For nA:=1 to Len(aDados2)

			cLin := Space(nTamLin)

			cCpo := Space(TamSX3("D2_COD")[1])+";"
			cLin := Stuff(cLin,01,Len(cCpo),cCpo)						// Codigo do produto

			cCpo := aDados2[nA,1]+";"
			cLin := Stuff(cLin,17,Len(cCpo),cCpo)						// Centro de Custo

			cCpo := aDados2[nA,2]+";"
			cLin := Stuff(cLin,24,Len(cCpo),cCpo)						// Conta Contabil

			cCpo := space(30)+";"
			cLin := Stuff(cLin,33,Len(cCpo),cCpo)						// Descricao

			cCpo := Space(40)+";"
			cLin := Stuff(cLin,65,45,cCpo)						// Descricao do produto

			cCpo := Space(TamSX3("D2_EMISSAO")[1])+";"
			cLin := Stuff(cLin,113,Len(cCpo),cCpo)						// Emissao da nota

			cCpo := Space(TamSX3("D2_DOC")[1])+";"
			cLin := Stuff(cLin,122,Len(cCpo),cCpo)						// Numero da nota

			cCpo := Space(TamSX3("A1_NOME")[1])+";"
			cLin := Stuff(cLin,132,Len(cCpo),cCpo)						// Nome do cliente (quantidade)

			cCpo := StrZero(aDados2[nA,3],12,2)+";"
			cLin := Stuff(cLin,173,Len(cCpo),StrTran(cCpo,".",","))		// Valor Total da Nota Fiscal

			cCpo := StrZero(aDados1[nA,4],12,2)+";"
			cLin := Stuff(cLin,186,Len(cCpo),StrTran(cCpo,".",","))		// Valor Líquido

			cCpo := Space(4)+Space(TamSX3("X5_DESCRI")[1])+";"
			cLin := Stuff(cLin,199,Len(cCpo),cCpo)						// Segmento de Mercado

			cCpo := Space(TamSX3("A1_COD")[1])+";"
			cLin := Stuff(cLin,259,Len(cCpo),cCpo)						// Codigo cliente

			cCpo := Space(TamSX3("A1_LOJA")[1])+";"
			cLin := Stuff(cLin,266,Len(cCpo),cCpo)						// Loja cliente

			cCpo := Space(TamSX3("A1_CGC")[1])+";"
			cLin := Stuff(cLin,269,Len(cCpo),cCpo)						// CNPJ / CPF

			cCpo := Space(TamSX3("A3_COD")[1]+TamSX3("A3_NOME")[1]+1)
			cLin := Stuff(cLin,288,Len(cCpo),cCpo)						// Vendedor 1

			//If Substr(SM0->M0_CODFIL,1,2) == '05'
			If cUtilContr == .T.
				cCpo := ";"+Space(TamSX3("C5_XCNPJC")[1])+";"
				cLin := Stuff(cLin,335,Len(cCpo),cCpo)					// CNPJ Contratante

				cCpo := Space(TamSX3("C5_ZZNOMEC")[1])+";"
				cLin := Stuff(cLin,355,Len(cCpo),cCpo)					// Nome Contratante
/*
				cCpo := Space(TamSX3("C5_XCONTCO")[1])+";"
				cLin := Stuff(cLin,406,Len(cCpo),cCpo)					// Contato Contratante

				cCpo := Space(TamSX3("C5_XCNPJSO")[1])+";"
				cLin := Stuff(cLin,437,Len(cCpo),cCpo)					// CNPJ Solicitante

				cCpo := Space(TamSX3("C5_XNOMESO")[1])+";"
				cLin := Stuff(cLin,456,Len(cCpo),cCpo)					// Nome Solicitante

				cCpo := Space(TamSX3("C5_XCONTSO")[1])+";"
				cLin := Stuff(cLin,507,Len(cCpo),cCpo)					// Contato Solicitante

				cCpo := Space(TamSX3("C5_XCNPJRE")[1])+";"
				cLin := Stuff(cLin,538,Len(cCpo),cCpo)					// CNPJ Representante

				cCpo := Space(TamSX3("C5_XNOMERE")[1])+";"
				cLin := Stuff(cLin,557,Len(cCpo),cCpo)					// Nome Representante

				cCpo := Space(TamSX3("C5_XCONTRE")[1])+";"
				cLin := Stuff(cLin,608,Len(cCpo),cCpo)					// Contato Representante

				cCpo := Space(TamSX3("C5_XCNPJFA")[1])+";"
				cLin := Stuff(cLin,639,Len(cCpo),cCpo)					// CNPJ Faturamento

				cCpo := Space(TamSX3("C5_XNOMEFA")[1])+";"
				cLin := Stuff(cLin,658,Len(cCpo),cCpo)					// Nome Faturamento

				cCpo := Space(TamSX3("C5_XCONTFA")[1]+1)
				cLin := Stuff(cLin,709,Len(cCpo),cCpo)					// Contato Faturamento
*/
			Endif

			cLin += _cEOL

			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				MsgAlert(OemToansi("Ocorreu um erro na gravação do arquivo."),OemToAnsi("Atenção!"))
				Return
			Endif

		Next

	Endif

Return