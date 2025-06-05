#INCLUDE "PROTHEUS.CH"
#INCLUDE "MYMATR170.CH"

/*/{Protheus.doc} MyMatr170
Emissão do boletim de entrada
@author Ricardo Berti
@since 29/12/2017
@return ${return}, ${return_description}
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpcx, numeric, descricao
/*/
User Function MyMatr170(cAlias,nReg,nOpcx)

U_MyM170R3(cAlias,nReg,nOpcx)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR170R3³ Rev.  ³ Edson Maricate        ³ Data ³07.07.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Boletim de Entrada                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR17OR3(ExpC1,ExpN1,ExpN2)                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                     	          ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA        ³Programa   MATR170.PRX  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data          |BOPS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³               |                 ³±±
±±³      02  ³Flavio Luiz Vicco         ³ 06/04/2006    |00000095603      ³±±
±±³      03  ³                          ³               |                 ³±±
±±³      04  ³                          ³               |                 ³±±
±±³      05  ³                          ³               |                 ³±±
±±³      06  ³                          ³               |                 ³±±
±±³      07  ³                          ³               |                 ³±±
±±³      08  ³Ricardo Berti		        ³ 21/08/2006    |00000105488      ³±±
±±³      09  ³                          ³               |                 ³±±
±±³      10  ³Flavio Luiz Vicco         ³ 06/04/2006    |00000095603      ³±±
±±³      10* ³Ricardo Berti		        ³ 21/08/2006    |00000105488      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function MyM170R3(cAlias,nReg,nOpcx)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel  :="MyMATR170"
LOCAL cDesc1 := STR0001	//"Este programa ira emitir o Boletim de Entrada."
LOCAL cDesc2 := ""
LOCAL cDesc3 := ""
LOCAL cString:= "SF1"
LOCAL aArea		:= GetArea()
LOCAL aAreaSF1	:= SF1->(GetArea())

STATIC aTamSXG

PRIVATE lAuto		:= Upper(FunName())=="MATA103"
PRIVATE Titulo		:= STR0002	//"Boletim de Entrada"
PRIVATE aReturn		:= {STR0003, 1,STR0004, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog	:= "MyMATR170"
PRIVATE nLastKey	:= 0
PRIVATE cPerg		:= If(lAuto,"","MTR170")
PRIVATE cAuxLinha	:= SPACE(132)

If lAuto
	nReg := SF1->(Recno())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica conteudo da variavel Grupo de Fornecedor (001)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamSXG := If(aTamSXG == NIL, TamSXG("001"), aTamSXG)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSx1()
Pergunte("MTR170",.F.)

If lAuto
	mv_par05 := Aviso("Informação","Informe o que deseja imprimir ...",{"C.Contábil","C.Custo"},2,"Boletim de Entrada")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utiLizadas para parametros                         ³
//³ mv_par01             // da Data                              ³
//³ mv_par02             // ate a Data                           ³
//³ mv_par03             // Nota De                              ³
//³ mv_par04             // Nota Ate                             ³
//³ mv_par05             // Imprime Centro Custo X Cta. Contabil ³
//³ mv_par06             // Imprimir o Custo ? Total ou Unit rio ³
//³ mv_par07             // Ordenar itens por? Item+Prod/ Prd+It ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,"M",,!lAuto)

If nLastKey == 27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| R170Imp(@lEnd,wnrel,cString,nReg)},Titulo)


RestArea(aAreaSF1)
RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R170IMP  ³ Rev.  ³ Edson Maricate        ³ Data ³06.07.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada e impressao do Relatorio.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R170Imp(lEnd,wnrel,cString,nReg)

Local li          := 99
LOCAL cLocDest    := GetMV("MV_CQ")
Local cForMunic   := GetMv("MV_MUNIC")
Local aDivergencia:= {}
Local aPedidos  	:= {}
Local aDescPed    := {}
Local aCQ         := {}
Local aEntCont    := {}
Local _lQtdErr    := .F.
Local _lPrcErr    := .F.
Local _QtdSal     := .F.
Local _lTes       := .F.
Local cForAnt     := 0
Local nDocAnt     := 0
Local nCt         := 0
Local nX          := 0
Local nImp        := 0
Local nRecno      := 0
Local lPedCom     := .F.
Local cQuery      := ""
Local cArqInd     := ""
Local cArqIndSD1  := ""
Local cParcIR     := ""
Local cParcINSS   := ""
Local cParcISS    := ""
Local cParcCof    := ""
Local cParcPis    := ""
Local cParcCsll   := ""
Local cParcSest   := ""
Local cPrefixo
Local aImps       := {}
Local nBasePis    := 0
Local nValPis     := 0
Local nBaseCof    := 0
Local nValCof     := 0
Local nRec        := 0
Local aRelImp     := MaFisRelImp("MT100",{ "SF1" })
Local lFornIss    := (SE2->(FieldPos("E2_FORNISS")) > 0 .And. SE2->(FieldPos("E2_LOJAISS")) > 0)
Local cFornIss 	  := ""
Local cLojaIss    := ""
Local cRemito     := ""
Local cItemRem    := ""
Local cSerieRem   := ""
Local cFornRem    := ""
Local cLojaRem    := ""
Local cCodRem     := ""
Local cPedido     := ""
Local cItemPed    := ""
Local lQuery      := .F.
Local cDtEmis     := ""
Local i 		  := 0

Local cCdCt   := CriaVar("F1_ZZCONTA",.F.)

Local cCC01   := CriaVar("F1_ZZCC01",.F.)
Local nPerc01 := CriaVar("F1_ZZPE01",.F.)

Local cCC02   := CriaVar("F1_ZZCC02",.F.)
Local nPerc02 := CriaVar("F1_ZZPE02",.F.)

Local cCC03   := CriaVar("F1_ZZCC03",.F.)
Local nPerc03 := CriaVar("F1_ZZPE03",.F.)

Local cCC04   := CriaVar("F1_ZZCC04",.F.)
Local nPerc04 := CriaVar("F1_ZZPE04",.F.)

Local cCC05   := CriaVar("F1_ZZCC05",.F.)
Local nPerc05 := CriaVar("F1_ZZPE05",.F.)

Local cCC06   := CriaVar("F1_ZZCC06",.F.)
Local nPerc06 := CriaVar("F1_ZZPE06",.F.)

Local cCC07   := CriaVar("F1_ZZCC07",.F.)
Local nPerc07 := CriaVar("F1_ZZPE07",.F.)

Local cCC08   := CriaVar("F1_ZZCC08",.F.)
Local nPerc08 := CriaVar("F1_ZZPE08",.F.)

Private cAliasSF1	:= "SF1"

If lAuto
	dbSelectArea("SF1")
	dbGoto(nReg)
	MV_PAR03 := SF1->F1_DOC
	MV_PAR04 := SF1->F1_DOC
	MV_PAR01 := SF1->F1_DTDIGIT
	MV_PAR02 := SF1->F1_DTDIGIT
Else
	dbSelectArea("SF1")
	dbSetOrder(1)
	#IFDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Query para SQL                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT *  "
		cQuery += "FROM "	    + RetSqlName( 'SF1' )
		cQuery += " WHERE "
		cQuery += "F1_FILIAL='"    	+ xFilial( 'SF1' )	+ "' AND "
		cQuery += "F1_DTDIGIT>='"  	+ DTOS(MV_PAR01)	+ "' AND "
		cQuery += "F1_DTDIGIT<='"  	+ DTOS(MV_PAR02)	+ "' AND "
		cQuery += "F1_DOC>='"  		+ MV_PAR03			+ "' AND "
		cQuery += "F1_DOC<='"  		+ MV_PAR04			+ "' AND "
		cQuery += "NOT ("+IsRemito(3,'F1_TIPODOC')+ ") AND "
		cQuery += "D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY " + SqlOrder(SF1->(IndexKey()))
		cQuery := ChangeQuery(cQuery)

		cAliasSF1 := "QRYSF1"
		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), 'QRYSF1', .F., .T.)
		aEval(SF1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("QRYSF1",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

		If ( mv_par07 == 1 )
			cArqIndSD1 := CriaTrab(,.F.)
			IndRegua( "SD1", cArqIndSD1, "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM" )
		EndIf

		lQuery := .T.
	#ELSE
		If !Empty(MV_PAR03)
			SF1->(dbSeek(xFilial("SF1")+MV_PAR03,.T.))
		Else
			cArqInd   := CriaTrab( , .F. )
			cQuery := "F1_FILIAL=='"	   	+xFilial("SF1")	+"'.AND."
			cQuery += "DTOS(F1_DTDIGIT)>='"	+DTOS(MV_PAR01)	+"'.AND."
			cQuery += "DTOS(F1_DTDIGIT)<='"	+DTOS(MV_PAR02)	+"'.AND."
			cQuery += "F1_DOC >= '"  	   	+MV_PAR03		+"'.AND."
			cQuery += "F1_DOC <= '"  		+MV_PAR04		+"'"
			cQuery += ".AND. !("+IsRemito(2,'SF1->F1_TIPODOC')+")"

			IndRegua( "SF1", cArqInd, IndexKey(), , cQuery )
			SF1->( dbSetIndex( cArqInd + OrdBagExt() ) )
		EndIf

		If ( mv_par07 == 1 )
			cArqIndSD1 := CriaTrab(,.F.)
			IndRegua( "SD1", cArqIndSD1, "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM" )
			SD1->( dbSetIndex( cArqIndSD1 + OrdBagExt() ) )
		EndIf

		lQuery := .F.
	#ENDIF
EndIf

If !lAuto
	(cAliasSF1)->(dbGoTop())
EndIf

SF1->(SetRegua(LastRec()))
While ( (cAliasSF1)->(!Eof()) .And. (cAliasSF1)->F1_FILIAL == xFilial("SF1") .And.;
		((cAliasSF1)->F1_DOC <= MV_PAR04) )

	IncRegua()
	aCQ	:= {}
	If lEnd
		@PROW()+1,001 PSAY STR0005		//"CANCELADO PELO OPERADOR"
		Exit
	Endif

	dbSelectArea(cAliasSF1)
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		(cAliasSF1)->(dbSkip())
		Loop
	EndIf
	If (cAliasSF1)->F1_DTDIGIT < MV_PAR01 .OR. (cAliasSF1)->F1_DTDIGIT > MV_PAR02
		(cAliasSF1)->(dbSkip())
		Loop
	EndIf

	If (cAliasSF1)->F1_DOC < MV_PAR03 .or. (cAliasSF1)->F1_DOC > MV_PAR04
		(cAliasSF1)->(dbSkip())
		Loop
	EndIf

	If (lAuto .And. (cAliasSF1)->(Recno()) <> nReg)
		(cAliasSF1)->(dbSkip())
		Loop
	EndIf
	cDtEmis  := (cAliasSF1)->F1_EMISSAO

	If lQuery
		dbSelectArea("SF1")
		dbSeek(xFilial("SF1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
	EndIf

	cCdCt   := (cAliasSF1)->F1_ZZCONTA
	cCC01   := (cAliasSF1)->F1_ZZCC01
	nPerc01 := (cAliasSF1)->F1_ZZPE01
	cCC02   := (cAliasSF1)->F1_ZZCC02
	nPerc02 := (cAliasSF1)->F1_ZZPE02
	cCC03   := (cAliasSF1)->F1_ZZCC03
	nPerc03 := (cAliasSF1)->F1_ZZPE03
	cCC04   := (cAliasSF1)->F1_ZZCC04
	nPerc04 := (cAliasSF1)->F1_ZZPE04
	cCC05   := (cAliasSF1)->F1_ZZCC05
	nPerc05 := (cAliasSF1)->F1_ZZPE05
	cCC06   := (cAliasSF1)->F1_ZZCC06
	nPerc06 := (cAliasSF1)->F1_ZZPE06
	cCC07   := (cAliasSF1)->F1_ZZCC07
	nPerc07 := (cAliasSF1)->F1_ZZPE07
	cCC08   := (cAliasSF1)->F1_ZZCC08
	nPerc08 := (cAliasSF1)->F1_ZZPE08

	dbSelectArea("SD1")
	dbSeek(xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do Cabecalho.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSF1)
	If li > 20
		li := R170Cabec()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao dos itens da Nota de Entrada.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	nCt     := 1
	nDocAnt := D1_DOC+D1_SERIE
	cForAnt := D1_FORNECE+D1_LOJA
	aDivergencia := {}
	aPedidos     := {}
	aDescPed     := {}
	aEntCont     := {}

	//                                 1         2         3         4         5         6         7         8         9        10        11        12        13
	//                         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	//                         999999999999999 XX XXXXXXXXXXXXXXXXXXXX 99999999.99 99,999,999.99 999,999,999.99  99  99 12345678901234567890 999 9999 99,999,999.99
	//                         999999999999999 XX XXXXXXXXXXXXXXXXX XX 99999999.99 99,999,999.99 999,999,999.99  99  99 12345678901234567890 999 9999 99,999,999.99
	If mv_par05 <> 3
		If mv_par08 == 1
			cLinha :=         "               |  |                 |  |           |            |            |     |     |                    |   |     |             "
		Else
			cLinha :=         "               |  |                    |           |            |            |     |     |                    |   |     |             "
		EndIf
	Else
		If mv_par08 == 1
			cLinha :=         "               |  |                 |  |           |            |            |     |     |   |     |             "
		Else
			cLinha :=         "               |  |                    |           |            |            |     |     |   |     |             "
		EndIf
	EndIf
	@ li,000 PSAY __PrtThinLine()
	li += 1
	@ li,000 PSAY STR0006 // "-------------------------------------------------------- DADOS DA NOTA FISCAL -------------------------------------------------------"
	li += 1
	@ li,000 PSAY If(mv_par08==1,If(cPaisLoc<>"BRA",STR0064,STR0063),If(cPaisLoc<>"BRA",STR0044,STR0007))+If(mv_par05==1,"   "+STR0009+If(cPaisLoc=="BRA"," ","")+"  |",If(mv_par05==2,"   "+STR0010+If(cPaisLoc=="BRA"," ","")+"   |",""))+STR0011+If(mv_par06==2,STR0012,STR0013)  //"Codigo Material|UN|Descr. da Mercadoria|Quantidade |Vlr. Unitario| Valor Total  |IPI|ICM|   "###"Conta Contabil"###"Centro  Custo "###"   |TES|CFOP|"###"Custo Unit. "###"Custo Total "
	li += 1

	While ( !Eof() .And. SD1->D1_DOC+SD1->D1_SERIE == nDocAnt .And.;
		cForAnt == SD1->D1_FORNECE+SD1->D1_LOJA .And.;
		SD1->D1_FILIAL == xFilial("SD1") )

		If li >= 60
			li := 1
			@ li,000 PSAY STR0085 //"------------------------------------------------------- ITENS DA NOTA FISCAL ----------------------------------------------------"
			li += 1
			@ li,000 PSAY If(mv_par08==1,If(cPaisLoc<>"BRA",STR0064,STR0063),If(cPaisLoc<>"BRA",STR0044,STR0007))+If(mv_par05==1,"   "+STR0009+If(cPaisLoc=="BRA"," ","")+"  |",If(mv_par05==2,"   "+STR0010+If(cPaisLoc=="BRA"," ","")+"   |",""))+STR0011+If(mv_par06==2,STR0012,STR0013)  //"Codigo Material|UN|Descr. da Mercadoria|Quantidade |Vlr. Unitario| Valor Total  |IPI|ICM|   "###"Conta Contabil"###"Centro  Custo "###"   |TES|CFOP|"###"Custo Unit. "###"Custo Total "
			li += 1
			@ li,000 PSAY __PrtThinLine()
			li += 1
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Todos os Arquivos Ref. ao Itens                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SD1->D1_COD)

		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+SD1->D1_TES)

		cPedido   := SD1->D1_PEDIDO
		cItemPed  := SD1->D1_ITEMPC

		If cPaisLoc <> "BRA" .And. !Empty(SD1->D1_REMITO)
			cRemito   := SD1->D1_REMITO
			cItemRem  := SD1->D1_ITEMREM
			cSerieRem := SD1->D1_SERIREM
			cFornRem  := SD1->D1_FORNECE
			cLojaRem  := SD1->D1_LOJA
			cCodRem	  := SD1->D1_COD

			aArea := SD1->(GetArea())

			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			If SD1->(dbSeek(xFilial("SD1")+cRemito+cSerieRem+cFornRem+cLojaRem+cCodRem+Alltrim(cItemRem))) .And. !Empty(SD1->D1_PEDIDO)
				cPedido   := SD1->D1_PEDIDO
				cItemPed  := SD1->D1_ITEMPC
			Endif
			RestArea(aArea)
		Endif

		dbSelectArea("SC7")
		dbSetOrder(19)
		If dbSeek(xFilial("SC7")+SD1->D1_COD+cPedido+cItemPed)
			dbSelectArea("SC1")
			dbSetOrder(2)
			dbSeek(xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC+SC7->C7_ITEMSC)

			dbSelectArea("SE4")
			dbSetOrder(1)
			dbSeek(xFilial("SE4")+SC7->C7_COND)

			lPedCom := !Empty(IF(SC7->C7_TIPO == 1,SubStr(SC1->C1_SOLICIT,1,15), SubStr(UsrFullName(SC7->C7_USER),1,15))+SC7->C7_CC)

			cProblema := ""
			If ( SD1->D1_QTDPEDI > 0 .And. (SC7->C7_QUANT <> SD1->D1_QTDPEDI) ) .Or. SC7->C7_QUANT <> SD1->D1_QUANT
				cProblema += "Q"
				_lQtdErr := .T.
			Else
				cProblema += " "
			EndIf
			If (SC7->C7_QUANT - SC7->C7_QUJE) < SD1->D1_QUANT  .AND. SD1->D1_TES == "   "
				_QtdSal := .T.
				n_proc1 :=-(SD1->D1_QUANT - (SC7->C7_QUANT - SC7->C7_QUJE)) / SC7->C7_QUANT * 100
			EndIf
			If SD1->D1_TES != "   " .AND. (SC7->C7_QUANT - SC7->C7_QUJE) < 0
				_QtdSal := .T.
				N_PORC1 :=-(SC7->C7_QUANT - SC7->C7_QUJE) / SC7->C7_QUANT * 100
			EndIf
			If IIf(Empty(SC7->C7_REAJUSTE),SC7->C7_PRECO,Formula(SC7->C7_REAJUSTE)) # SD1->D1_VUNIT
				If SC7->C7_MOEDA <> 1
					cProblema := cProblema+"M"
				Else
					cProblema := cProblema+"P"
				EndIf
				_lPrcErr := .T.
			Else
				cProblema := cProblema+" "
			EndIf
			If SC7->C7_DATPRF <> SD1->D1_DTDIGIT
				cProblema := cProblema+"E"
			Else
				cProblema := cProblema+" "
			EndIf
			If !Empty(cProblema)
				aADD(aDivergencia,cProblema)
			Else
				aADD(aDivergencia,"Ok ")
			Endif
			aADD(aPedidos,{SC7->C7_NUM+"/"+SC7->C7_ITEM,;
				SC7->C7_DESCRI,;
				TransForm(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT",11)),;
				TransForm(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO",13)),;
				DTOC(SC7->C7_EMISSAO),;
				DTOC(SC7->C7_DATPRF),;
				SC7->C7_NUMSC+"/"+SC7->C7_ITEMSC,;
				If(lPedCom,IF(SC7->C7_TIPO == 1,SubStr(SC1->C1_SOLICIT,1,15), SubStr(UsrFullName(SC7->C7_USER),1,15)),"") ,;
				If(lPedCom,SC7->C7_CC,""),;
				AllTrim(SE4->E4_DESCRI)} )
		Else
			aADD(aDivergencia,STR0079) //"Err"
			aADD(aPedidos,{"",STR0014,"","","","","","","",""}) //"Sem Pedido de Compra"
		Endif

		If !Empty(SD1->D1_NUMCQ) .AND. SF4->F4_ESTOQUE == "S"
			AADD(aCQ,SD1->D1_NUMCQ+SD1->D1_COD+cLocDest+"001"+DTOS(SD1->D1_DTDIGIT))
		Endif

		R170Load(0,cLinha)
		R170Load(0,SD1->D1_COD)
		R170Load(16,SD1->D1_UM)
		If mv_par08 == 1
			If SD1->(FieldPos("D1_ZZDESCR")) <> 0 .and. !Empty(SD1->D1_ZZDESCR)
            	cAux := SD1->D1_ZZDESCR
   			Else
   				cAux := SB1->B1_DESC
   			Endif
			If SD1->(FieldPos("D1_ZZOBS")) <> 0 .and. !Empty(SD1->D1_ZZOBS)
				cAux := Alltrim(cAux)+" - Obs: "+Alltrim(SD1->D1_ZZOBS)
			Endif
			R170Load(19,SubStr(cAux,1,17))
			R170Load(37,SubStr(SD1->D1_LOCAL,1,2))
		Else
			If SD1->(FieldPos("D1_ZZDESCR")) <> 0 .and. !Empty(SD1->D1_ZZDESCR)
            	cAux := SD1->D1_ZZDESCR
   			Else
   				cAux := SB1->B1_DESC
   			Endif
			If SD1->(FieldPos("D1_ZZOBS")) <> 0 .and. !Empty(SD1->D1_ZZOBS)
				cAux := Alltrim(cAux)+" - Obs: "+Alltrim(SD1->D1_ZZOBS)
			Endif
			R170Load(19,SubStr(cAux,1,20))
		EndIf
		R170Load(40,Transform(SD1->D1_QUANT,PesqPict("SD1","D1_QUANT",11)))
		R170Load(52,TransForm(SD1->D1_VUNIT,PesqPict("SD1","D1_VUNIT",12)))
		If cPaisLoc=="BRA"
			R170Load(65,Transform(SD1->D1_TOTAL,PesqPict("SD1","D1_TOTAL",12)))
			R170Load(78,Transform(SD1->D1_IPI,PesqPict("SD1","D1_IPI",5)))
			R170Load(84,Transform(SD1->D1_PICM,PesqPict("SD1","D1_PICM",5)))
		Else
			R170Load(73,Transform(SD1->D1_TOTAL,PesqPict("SD1","D1_TOTAL",14)))
		EndIf
		If mv_par05 == 1
			R170Load(90,SD1->D1_CONTA)
		ElseIf mv_par05 == 2
			R170Load(90,SD1->D1_CC)
		Endif

		If (( mv_par05 == 1 ) .Or. ( mv_par05 == 2 ))
			R170Load(111,SD1->D1_TES)
			R170Load(115,SD1->D1_CF)
			If mv_par06 = 1
				R170Load(121,Transform(SD1->D1_CUSTO,PesqPict("SD1","D1_CUSTO",10)))
			Else
				R170Load(121,Transform((SD1->D1_CUSTO/SD1->D1_QUANT),PesqPict("SD1","D1_CUSTO",10)))
			EndIf
		Else
			R170Load(90,SD1->D1_TES)
			R170Load(94,SD1->D1_CF)
			If mv_par06 = 1
				R170Load(100,Transform(SD1->D1_CUSTO,PesqPict("SD1","D1_CUSTO",10)))
			Else
				R170Load(100,Transform((SD1->D1_CUSTO/SD1->D1_QUANT),PesqPict("SD1","D1_CUSTO",10)))
			EndIf
		EndIf
		R170Say(Li)

		Li := Li + 1
		If !Empty(SD1->D1_TES)
			_lTES := .T.
		EndIf

		If mv_par08 == 1
			_nCntTam := 18
			If SD1->(FieldPos("D1_ZZDESCR")) <> 0 .and. !Empty(SD1->D1_ZZDESCR)
				cAux := SD1->D1_ZZDESCR
			Else
				cAux := SB1->B1_DESC
			Endif
			If SD1->(FieldPos("D1_ZZOBS")) <> 0 .and. !Empty(SD1->D1_ZZOBS)
				cAux := Alltrim(cAux)+" - Obs: "+Alltrim(SD1->D1_ZZOBS)
			Endif
			While !(AllTrim(SubStr(cAux,_nCntTam))=="")
				R170Load(0,cLinha)
				R170Load(19,SubStr(cAux,_nCntTam,17))
				_nCntTam := _nCntTam + 17
				R170Say(Li)
				Li := Li + 1
			EndDo
		Else
			_nCntTam := 21
			If SD1->(FieldPos("D1_ZZDESCR")) <> 0 .and. !Empty(SD1->D1_ZZDESCR)
				cAux := SD1->D1_ZZDESCR
			Else
				cAux := SB1->B1_DESC
			Endif
			If SD1->(FieldPos("D1_ZZOBS")) <> 0 .and. !Empty(SD1->D1_ZZOBS)
				cAux := Alltrim(cAux)+" - Obs: "+Alltrim(SD1->D1_ZZOBS)
			Endif
			While !(AllTrim(SubStr(cAux,_nCntTam))=="")
				R170Load(0,cLinha)
				R170Load(19,SubStr(cAux,_nCntTam,20))
				_nCntTam := _nCntTam + 20
				R170Say(Li)
				Li := Li + 1
			EndDo
		EndIf

		If ( mv_par05 == 3 )
			If ( SD1->D1_RATEIO == "1" )
				dbSelectArea("SDE")
				dbSetOrder(1)
				If MsSeek(xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
					While !Eof() .And. DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF ==;
						xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM
						aAdd(aEntCont,{SDE->DE_ITEMNF,SDE->DE_ITEM,SDE->DE_PERC,SDE->DE_CC,SDE->DE_CONTA,SDE->DE_ITEMCTA,SDE->DE_CLVL})
						dbSelectArea("SDE")
						dbSkip()
					EndDo
				EndIf
			Else
				If !Empty(SD1->D1_CC) .Or. !Empty(SD1->D1_CONTA) .Or. !Empty(SD1->D1_ITEMCTA)
					aAdd(aEntCont,{SD1->D1_ITEM," - ","   -   ",SD1->D1_CC,SD1->D1_CONTA,SD1->D1_ITEMCTA,SD1->D1_CLVL})
				EndIf
			EndIf
		EndIf

		dbSelectArea("SD1")
		dbSkip()
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Entidades Contabeis ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aEntCont) > 0
		If Li >= 60
			Li := 1
		Endif
		@ li,000 PSAY __PrtThinLine()
		li += 1
		cLinha :=   "        |      |       |                 |                      |            |              "
		@ Li, 0 PSAY STR0061  //"------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
		li += 1
		@ Li,000 PSAY STR0062 //"Item NF | Item | % Rat | Centro de Custo | Conta Contabil       | Item Conta | Classe Valor "
		li += 1

		For nX:=1 to Len(aEntCont)
			If Li >= 60
				Li := 1
				cLinha :=   "        |      |       |                 |                      |            |              "
				@ Li, 0 PSAY STR0061  //"------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
				li += 1
				@ Li,000 PSAY STR0062 //"Item NF | Item | % Rat | Centro de Custo | Conta Contabil       | Item Conta | Classe Valor "
				li += 1
			Endif
			R170Load(0,cLinha)
			R170Load(0,aEntCont[nX][1])
			R170Load(10,aEntCont[nX][2])
			R170Load(16,If(ValType(aEntCont[nX][3])=="N",Transform(aEntCont[nX][3],"@E 999.99"),aEntCont[nX][3]))
			R170Load(25,aEntCont[nX][4])
			R170Load(43,aEntCont[nX][5])
			R170Load(66,aEntCont[nX][6])
			R170Load(79,aEntCont[nX][7])
			R170Say(Li)
			li += 1
		Next nX
		aEntCont := {}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime produtos enviados ao Controle de Qualidade SD7       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Len(aCQ) > 0
		If Li >= 60
			Li := 1
		Endif
		li += 1
		//                               1         2         3         4         5         6         7         8         9        10        11        12        13
		//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                     XXXXXXXXXXXXXXX                    XX                               XX                      99/99/9999                        999999
		cLinha :=    "                     |                               |                            |                           |                     "
		@ Li, 0 PSAY STR0015 //"------------------------------------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------------------------------"
		li += 1
		@ Li,000 PSAY STR0016 //"Produto              |         Local Origem          |        Local Destino       |    Data Transferencia     |     Numero do CQ.   "
		li += 1

		For nX:=1 to Len(aCQ)
			If Li >= 60
				Li := 1
				//                               1         2         3         4         5         6         7         8         9        10        11        12        13
				//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				//                     XXXXXXXXXXXXXXX                    XX                               XX                      99/99/9999                        999999
				cLinha :=    "                     |                               |                            |                           |                     "
				@ Li, 0 PSAY STR0015 //"------------------------------------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------------------------------"
				li += 1
				@ Li,000 PSAY STR0016 //"Produto              |         Local Origem          |        Local Destino       |    Data Transferencia     |     Numero do CQ.   "
				li += 1
			Endif
			dbSelectArea("SD7")
			dbSetOrder(1)
			dbSeek(xFilial("SD7")+aCQ[nX])
			If Found()
				R170Load(0,cLinha)
				R170Load(0,SD7->D7_PRODUTO)
				R170Load(34,SD7->D7_LOCAL)
				R170Load(68,SD7->D7_LOCDEST)
				R170Load(92,DTOC(SD7->D7_DATA))
				R170Load(123,SD7->D7_NUMERO)
				R170Say(Li)
				li += 1
			Endif
		Next nX
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Divergencia com Pedido de Compra.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Li := Li + 1
	//                            1         2         3         4         5         6         7         8         9        10        11        12        13
	//                  012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	//                   123 123456-12 12345678901234567890 99999999,99|99.999.999,99 99/99/9999 99/99/9999 999999/99 xxxxxxxxxxxx 999999999
	If cPaisLoc == "BRA"
		cLinha  :=    "   |           |                  |           |             |          |          |         |               |         |             "
	Else
		cLinha  :=    "   |           |                    |           |             |          |          |            |               |         |             "
	EndIf
	@ li,000 PSAY __PrtThinLine()
	Li += 1
	@ Li,000 PSAY STR0019 //"--------------------------------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA --------------------------------------------------"
	Li += 1
	@ Li,000 PSAY If(cPaisLoc=="BRA",STR0020,STR0058) //"Div|Numero   |Descricao do Produto|Quantidade |Preco Unitar.| Emissao  | Entrega  |   S.C.  |Solicitante    | C.Custo |Cond.Pagto   "
	Li += 1
	If !Empty(aPedidos) .And. !Empty(aDivergencia)
		For nX := 1 To Len(aPedidos)
			If Li > 60
				Li := 0
				@ Li,000 PSAY STR0019 //"--------------------------------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA --------------------------------------------------"
				Li += 1
				@ Li,000 PSAY If(cPaisLoc=="BRA",STR0020,STR0058) //"Div|Numero   |Descricao do Produto|Quantidade |Preco Unitar.| Emissao  | Entrega  |   S.C.  |Solicitante    | C.Custo |Cond.Pagto   "
				Li += 1
			EndIf
			R170Load(0,cLinha)
			R170Load(0,aDivergencia[nX])
			R170Load(4,aPedidos[nX][1])
			If cPaisLoc == "BRA"
				R170Load(16,AllTrim(Substr(aPedidos[nX][2],1,18)))
				R170Load(35,aPedidos[nX][3])
				R170Load(47,aPedidos[nX][4])
				R170Load(61,aPedidos[nX][5])
				R170Load(72,aPedidos[nX][6])
				R170Load(83,aPedidos[nX][7])
				R170Load(93,aPedidos[nX][8])
				R170Load(109,aPedidos[nX][9])
				R170Load(119,aPedidos[nX][10])
			Else
				R170Load(16,AllTrim(Substr(aPedidos[nX][2],1,18)))
				R170Load(37,aPedidos[nX][3])
				R170Load(49,aPedidos[nX][4])
				R170Load(63,aPedidos[nX][5])
				R170Load(74,aPedidos[nX][6])
				R170Load(85,aPedidos[nX][7])
				R170Load(98,aPedidos[nX][8])
				R170Load(114,aPedidos[nX][9])
				R170Load(124,aPedidos[nX][10])
			EndIf
			R170Say(Li)
			Li += 1
			_nCntTam := 19
			While !(AllTrim(SubStr(aPedidos[nX][2],_nCntTam)) == "")
				R170Load(0,cLinha)
				R170Load(16,SubStr(aPedidos[nX][2],_nCntTam,18))
				R170Say(Li)
				_nCntTam := _nCntTam + 18
				Li += 1
			End
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Totais da Nota Fiscal                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Li >= 60
		Li := 1
	Endif
	dbSelectArea(cAliasSF1)
	@ li,000 PSAY __PrtThinLine()
	Li += 1
	@ Li,000 PSAY STR0023 //"------------------------------------------------------- TOTAIS DA NOTA FISCAL ------------------------------------------------------"
	Li += 1
	//                             1         2         3         4         5         6         7         8         9        10        11        12        13
	//                   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	//                      999,999,999,999.99    999,999,999,999.99    999,999,999,999.99    999,999,999,999.99      999,999,999,999.99   999,999,999,999.99
	If cPaisLoc=="BRA"
		cLinha  :=     "                     |                     |                     |                      |                        |                  "
	Else
		cLinha  :=     "                     |                     |                                            |                        |                  "
	EndIf
	@ Li,000 PSAY If(cPaisLoc<>"BRA",STR0046,STR0024) //" BASE DE CALCULO ICMS|  VALOR DO ICMS      |BASE CALC.ICMS SUBST.|  VALOR ICMS SUBST.   |VALOR TOTAL DOS PRODUTOS|    DESCONTOS     "
	Li += 1
	R170Load(0,cLinha)
	If cPaisLoc=="BRA"
		R170Load(003,Transform((cAliasSF1)->F1_BASEICM,"@E 999,999,999,999.99"))
		R170Load(025,Transform((cAliasSF1)->F1_VALICM, "@E 999,999,999,999.99"))
		R170Load(047,Transform((cAliasSF1)->F1_BRICMS, "@E 999,999,999,999.99"))
		R170Load(069,Transform((cAliasSF1)->F1_ICMSRET,"@E 999,999,999,999.99"))
	Else
		aImps:=R170IMPT(cAliasSF1)
		R170Load(003,Transform(aImps[1],"@E 999,999,999,999.99")) // Base de imposto
		R170Load(025,Transform(aImps[2],"@E 999,999,999,999.99")) // Valor do Imposto
	EndIf
	R170Load(093,Transform((cAliasSF1)->F1_VALMERC,"@E 999,999,999,999.99"))
	R170Load(114,Transform((cAliasSF1)->F1_DESCONT,"@E 999,999,999,999.99"))
	R170Say(Li)
	Li += 1
	@ Li,000 PSAY __PrtThinLine()
	Li += 1
	cLinha  :=    "                        |                         |                        |                         |                             "
	@ Li,000 PSAY If(cPaisLoc<>"BRA",STR0045,STR0025) //"  VALOR DO FRETE        |      VALOR DO SEGURO    | OUTRAS DESPESAS ACESSO.|   VALOR TOTAL DO IPI    |   VALOR TOTAL DA NOTA       "
	Li += 1
	R170Load(0,cLinha)
	R170Load(001,Transform((cAliasSF1)->F1_FRETE,  "@E 99,999,999,999,999.99"))
	R170Load(027,Transform((cAliasSF1)->F1_SEGURO, "@E 99,999,999,999,999.99"))
	R170Load(053,Transform((cAliasSF1)->F1_DESPESA,"@E 99,999,999,999,999.99"))
	If cPaisLoc=="BRA"
		R170Load(079,Transform((cAliasSF1)->F1_VALIPI, "@E 99,999,999,999,999.99"))
		R170Load(108,Transform((cAliasSF1)->F1_VALBRUT,"@E 99,999,999,999,999.99"))
	Else
		R170Load(079,Transform((cAliasSF1)->F1_VALBRUT,"@E 99,999,999,999,999.99"))
	EndIf
	R170Say(Li)
	Li += 1
	@ Li,000 PSAY __PrtThinLine()
	Li += 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime desdobramento de Duplicatas.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFornece := {{(cAliasSF1)->F1_FORNECE,(cAliasSF1)->F1_LOJA,PadR(MVNOTAFIS,Len(SE2->E2_TIPO))},;
   				{PadR(GetMv('MV_UNIAO')  ,Len(SE2->E2_FORNECE)),PadR(Replicate('0',Len(SE2->E2_LOJA)),Len(SE2->E2_LOJA)),PadR(MVTAXA,Len(SE2->E2_TIPO))},;
				{PadR(GetMv('MV_FORINSS'),Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVINSS,Len(SE2->E2_TIPO))},;
				{PadR(GetMv('MV_MUNIC')  ,Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVISS ,Len(SE2->E2_TIPO))}}
	If SE2->(FieldPos("E2_PARCSES")) > 0
		aadd(aFornece,{PadR(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)),PadR(IIf(SubStr(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)+1)<>"",SubStr(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)+1),"00"),Len(SE2->E2_LOJA)),PadR('SES',Len(SE2->E2_TIPO)),"E2_PARCSES",{ || .T. }})
	EndIf


	cPrefixo := If(Empty((cAliasSF1)->F1_PREFIXO),&(GetMV("MV_2DUPREF")),(cAliasSF1)->F1_PREFIXO)
	dbSelectArea("SE2")
	dbSetOrder(6)
	dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+cPrefixo+(cAliasSF1)->F1_DOC)

 	nRec:=RECNO()
			//Verifica se o Fornecedor do Titulo ja existe no aFornec //
	IF dbSeek(xFilial("SE2")+cForMunic)
   		While !Eof().and. alltrim(SE2->E2_FORNECE) == alltrim(cForMunic)
   		   	IF Ascan(aFornece,{|x| (alltrim(x[1])+alltrim(x[2])) == (alltrim(cForMunic)+alltrim(SE2->E2_LOJA))}) = 0
   		 		aAdd(aFornece, {PadR(GetMv('MV_MUNIC'),Len(SE2->E2_FORNECE)),SE2->E2_LOJA,PadR(MVISS ,Len(SE2->E2_TIPO))} )
   	   		EndIf
	  	 	DBSkip()
		EndDo
	EndIF

	dbGoto(nRec)

		//Li += 1
		If Li >= 60
			Li := 1
		Endif
		//                               1         2         3         4         5         6         7         8         9        10        11        12        13
		//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                      123 123456789012A 99/99/9999 99,999,999,999.99                            123 123456789012A 99/99/99   99,999,999,999.99 xxxxxxxxxx
		@ Li,000 PSAY STR0026 //"--------------------------------------------------- DESDOBRAMENTO DE DUPLICATAS ----------------------------------------------------"
		Li += 1
		If cPaisLoc=="MEX"
			cLinha :=     "   |                     |          |                 |           ||   |                     |          |                 |         "
		Else
			cLinha :=     "   |             |          |                 |                   ||   |             |          |                 |                 "
		EndIf

		@ Li,000 PSAY If(cPaisLoc=="MEX",STR0109,STR0027) //"Ser|Titulo/Parc. | Vencto   |Valor do Titulo  | Natureza          ||Ser|Titulo/Parc. | Vencto   |Valor do Titulo  | Natureza        "
		Li += 1

		Col := 0
		R170Load(0,cLinha)

		dbSelectArea('SE2')
		dbSetOrder(6)
		dbSeek(xFilial('SE2')+aFornece[1][1]+aFornece[1][2]+cPrefixo+(cAliasSF1)->F1_DOC)

		While !Eof() .And. xFilial('SE2')+aFornece[1][1]+aFornece[1][2]+cPrefixo+(cAliasSF1)->F1_DOC==;
			E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM

			If SE2->E2_TIPO == aFornece[1,3]

				R170Dupl(@Li,@Col)
				cParcCSS := SE2->E2_PARCCSS
				cParcIR  := SE2->E2_PARCIR
				cParcINSS:= SE2->E2_PARCINS
				cParcISS := SE2->E2_PARCISS
				cParcCof := SE2->E2_PARCCOF
				cParcPis := SE2->E2_PARCPIS
				cParcCsll:= SE2->E2_PARCSLL
				If lFornIss .And. !Empty(SE2->E2_FORNISS) .And. !Empty(SE2->E2_LOJAISS)
					cFornIss := SE2->E2_FORNISS
					cLojaIss := SE2->E2_LOJAISS
				Else
					cFornIss := aFornece[4,1]
					cLojaIss :=	aFornece[4,2]
				Endif
				cParcSest := IIf(SE2->(FieldPos("E2_PARCSES"))>0,SE2->E2_PARCSES,"")

				nRecno   := SE2->(Recno())

				dbSelectArea('SE2')
				dbSetOrder(1)
				If (!Empty(cParcIR)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcIR+aFornece[2,3]+aFornece[2,1]+aFornece[2,2])
					R170Dupl(@Li,@Col)
				Endif
				If (!Empty(cParcINSS)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcINSS+aFornece[3,3])
					R170Dupl(@Li,@Col)
				Endif

				For i=1 to Len(aFornece)
					If AllTrim(aFornece[i,1])==alltrim(cForMunic)
						If (!Empty(cParcISS)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcISS+aFornece[i,3]+cFornIss+aFornece[i,2])
						    IF cDtEmis == SE2->E2_EMISSAO
								R170Dupl(@Li,@Col)
						   	EndIf
						EndIf
					EndIf
				Next i

				If (!Empty(cParcCof)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCof+aFornece[2,3])
					R170Dupl(@Li,@Col)
				Endif
				If (!Empty(cParcPis)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcPis+aFornece[2,3])
					R170Dupl(@Li,@Col)
				Endif
				If (!Empty(cParcCsll)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCsll+aFornece[2,3])
					R170Dupl(@Li,@Col)
				Endif

				If (!Empty(cParcCSS)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCSS+aFornece[2,3])
					While !Eof() .And. xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCSS+aFornece[2,3] ==;
							SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO

						If PadR(GetMv('MV_CSS'),Len(SE2->E2_NATUREZ)) == SE2->E2_NATUREZ
							R170Dupl(@Li,@Col)
						EndIf

						dbSelectArea('SE2')
						dbSetOrder(1)
						dbSkip()
					EndDo
				Endif
				If (!Empty(cParcSest)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcSest+aFornece[5,3])
					R170Dupl(@Li,@Col)
				Endif

				SE2->(dbGoto(nRecno))

			EndIf

			dbSelectArea('SE2')
			dbSetOrder(6)
			dbSkip()
		EndDo

		R170Say(Li)
		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		Li += 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Dados do Livros Fiscais.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisloc=="BRA"
		dbSelectArea("SF3")
		dbSetOrder(4)
		dbSeek(xFilial("SF3")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE)
		If Found()
			//Li += 1
			If Li >= 60
				Li := 1
			Endif
			//                                    1         2         3         4         5         6         7         8         9        10        11        12        13
			//                           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			//                            xxx xxxx  99  99,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99       9,999,999,999.99

			@ Li,000 PSAY STR0030 //"----------------------------------------------- DEMONSTRATIVO DOS LIVROS FISCAIS ---------------------------------------------------"
			Li += 1
			@ Li,000 PSAY STR0031 //"|                               |   Operacoes c/ credito de Imposto   |            Operacoes s/ credito de Imposto                 |"
			Li += 1
			//                                 1         2         3         4         5         6         7         8         9        10        11        12        13
			//                       012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			//                        xxxx xxxx  99   9,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99       9,999,999,999.99

			@ Li,000 PSAY STR0032 //"|    |CFOP |Alic| Valor Contable | Base de Calculo  |     Impuesto     |     Exentas      |      Otras       |     Observacion      |"
			Li += 1
			cLinha :=               "|    |     |    |                |                  |                  |                  |                  |                      |"
			While ! Eof() .And. xFilial("SF3")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE==F3_FILiAL+F3_CLiEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

				If Val(Substr(SF3->F3_CFO,1,1))<5

					R170Load(0,cLinha)
					R170Load(01,IIf(!Empty((cAliasSF1)->F1_ISS) .And. SF3->F3_TIPO == "S" ,STR0087,STR0088)) //"ISS"##"ICMS"
					R170Load(06,SF3->F3_CFO)
					R170Load(12,Transform(SF3->F3_ALIQICM,"99"))
					R170Load(17,Transform(SF3->F3_VALCONT,"@E 9,999,999,999.99"))
					R170Load(34,Transform(SF3->F3_BASEICM,"@E 999,999,999,999.99"))
					R170Load(53,Transform(SF3->F3_VALICM,"@E 999,999,999,999.99"))
					R170Load(72,Transform(SF3->F3_ISENICM,"@E 999,999,999,999.99"))
					R170Load(91,Transform(SF3->F3_OUTRICM,"@E 999,999,999,999.99"))
					R170Say(Li)
					Li++
					If !EMPTY(SF3->F3_ICMSRET)
						R170Load(0,cLinha)
						R170Load(109,STR0080) //"RET  "
						R170Load(114,Transform(SF3->F3_ICMSRET,"@E 9,999,999,999.99"))
						R170Say(Li)
						Li += 1
					Endif
					If !EMPTY(SF3->F3_ICMSCOM)
						R170Load(0,cLinha)
						R170Load(109,STR0081) //"Compl"
						R170Load(114,Transform(SF3->F3_ICMSCOM,"@E 9,999,999,999.99"))
						R170Say(Li)
						Li += 1
					Endif
					If !Empty(SF3->F3_BASEIPI) .Or. !Empty(SF3->F3_ISENIPI) .Or. !Empty(SF3->F3_OUTRIPI)
						R170Load(0,cLinha)
						R170Load(01,STR0086) //"IPI"
     					R170Load(12,Transform(Posicione("SD1",1,xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA,"D1_IPI"),"99"))
						R170Load(17,Transform(SF3->F3_VALCONT,"@E 9,999,999,999.99"))
						R170Load(34,Transform(SF3->F3_BASEIPI,"@E 999,999,999,999.99"))
						R170Load(53,Transform(SF3->F3_VALIPI,"@E 999,999,999,999.99"))
						R170Load(72,Transform(SF3->F3_ISENIPI,"@E 999,999,999,999.99"))
						R170Load(91,Transform(SF3->F3_OUTRIPI,"@E 999,999,999,999.99"))
					Endif

					If ! Empty(SF3->F3_VALOBSE)
						R170Load(110,STR0082) //"OBS. "
						R170Load(114,Transform(SF3->F3_VALOBSE,"@E 9,999,999,999.99"))
					Endif
					R170Say(Li)
					Li += 1
				Endif

				dbSkip()
			End

		Endif

		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		Li += 1
		@ Li,000 PSAY STR0059 //  "----------------------------------------------- DEMONSTRATIVO DOS DEMAIS IMPOSTOS ---------------------------------------------------"
		Li += 1
		@ Li,000 PSAY STR0060 //  "|                   | Base de Calculo  |     Imposto      |                                                                         |"
		Li += 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Dados ref ao PIS                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_BASEPS2"} ) )
			If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2])))
				nBasePis := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2]) ) ) )
			EndIf
		EndIf

		If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_VALPS2"} ) )
			If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2])))
				nValPis := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2]) ) ) )
			EndIf
		EndIf

		If !Empty(nValPis)
			R170Load(0,"|                   | Base de Calculo  |     Imposto      |")
			R170Load(01,STR0083) //"PIS APURACAO"
			R170Load(21,Transform(nBasePis,"@E 999,999,999,999.99"))
			R170Load(40,Transform(nValPis,"@E 999,999,999,999.99"))
			R170Say(Li)
			Li++
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Dados ref ao COFINS                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_BASECF2"} ) )
			If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2])))
				nBaseCof := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2]) ) ) )
			EndIf
		EndIf

		If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_VALCF2"} ) )
			If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2])))
				nValCof := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2]) ) ) )
			EndIf
		EndIf

		If !Empty(nValCof)
			R170Load(0,"|                   | Base de Calculo  |     Imposto      |")
			R170Load(01,STR0084) //"COFINS APURACAO"
			R170Load(21,Transform(nBaseCof,"@E 999,999,999,999.99"))
			R170Load(40,Transform(nValCof,"@E 999,999,999,999.99"))
			R170Say(Li)
			Li++
		Endif

		@ Li,000 PSAY __PrtThinLine()

		Li += 1
		If Li >= 63
			Li := 1
		Endif

		@ Li,000 PSAY "--------------------------------------- CLASSIFICAÇÃO DA NOTA CONFORME CRITÉRIOS DA EUROFINS ----------------------------------------"

		Li += 1
		If Li >= 63
			Li := 1
		Endif

		@ Li,000 PSAY "| Conta Contabil | Descricao                            | C.Custo | Descricao       | Perc.   | C.Custo | Descricao       | Perc.   |"

		Li += 1
		If Li >= 63
			Li := 1
		Endif

		cCdCt := (cAliasSF1)->F1_ZZCONTA
		SX5->(dbSetOrder(1))
		SX5->(dbSeek(xFilial("SX5")+"Z6"+cCdCt))
		cDescrCt := Substr(Alltrim(X5Descri()),1,36)

		@ Li,000 PSAY "| "+cCdCt
		@ Li,017 PSAY "| "+cDescrCt

		aCCs := {}

		If nPerc01 > 0
			SX5->(dbSeek(xFilial("SX5")+"Z5"+cCC01))
			aadd(aCCs , {cCC01 , Substr(Alltrim(X5Descri()),1,15) , nPerc01})
		Endif
		If nPerc02 > 0
			SX5->(dbSeek(xFilial("SX5")+"Z5"+cCC02))
			aadd(aCCs , {cCC02 , Substr(Alltrim(X5Descri()),1,15) , nPerc02})
		Endif
		If nPerc03 > 0
			SX5->(dbSeek(xFilial("SX5")+"Z5"+cCC03))
			aadd(aCCs , {cCC03 , Substr(Alltrim(X5Descri()),1,15) , nPerc03})
		Endif
		If nPerc04 > 0
			SX5->(dbSeek(xFilial("SX5")+"Z5"+cCC04))
			aadd(aCCs , {cCC04 , Substr(Alltrim(X5Descri()),1,15) , nPerc04})
		Endif
		If nPerc05 > 0
			SX5->(dbSeek(xFilial("SX5")+"Z5"+cCC05))
			aadd(aCCs , {cCC05 , Substr(Alltrim(X5Descri()),1,15) , nPerc05})
		Endif
		If nPerc06 > 0
			SX5->(dbSeek(xFilial("SX5")+"Z5"+cCC06))
			aadd(aCCs , {cCC06 , Substr(Alltrim(X5Descri()),1,15) , nPerc06})
		Endif
		If nPerc07 > 0
			SX5->(dbSeek(xFilial("SX5")+"Z5"+cCC07))
			aadd(aCCs , {cCC07 , Substr(Alltrim(X5Descri()),1,15) , nPerc07})
		Endif
		If nPerc08 > 0
			SX5->(dbSeek(xFilial("SX5")+"Z5"+cCC08))
			aadd(aCCs , {cCC08 , Substr(Alltrim(X5Descri()),1,15) , nPerc08})
		Endif

		nColuna := 56
		If Len(aCCs) == 1
			aadd(aCCs , { " " , " " , 0})
		Endif

		For nC:=1 to Len(aCCs)
			@ Li,nColuna    PSAY "|"
			@ Li,nColuna+2  PSAY aCCs[nC,1]
			@ Li,nColuna+10 PSAY "|"
			@ Li,nColuna+12 PSAY aCCs[nC,2]
			@ Li,nColuna+28 PSAY "|"
			@ Li,nColuna+30 PSAY aCCs[nC,3] Picture "@E 999.999"
			If nColuna == 56
				nColuna := nColuna + 38
			Else
				@ Li,nColuna+38 PSAY "|"
				nColuna := 56
				Li++
				If Li >= 63
					Li := 1
				Endif
			Endif
		Next

		Li++
		If Li >= 63
			Li := 1
		Endif

		@ Li,000 PSAY __PrtThinLine()

		If Li < 62
			Li := 62
		Endif

	Else
		aItens:=R170IMPI(cAliasSF1)
		If Len(aItens[1])>=0
			Li += 1
			If Li >= 60
				Li := 1
			Endif
			//                                     1         2         3         4         5         6         7         8         9        10        11        12        13
			//                           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			cLinha :=	    "|                  |                                          |     |        |                         |"
			@ Li,000 PSAY STR0042 //"-----------------------------------------------   RELACAO DE IMPOSTOS POR ITEM   ---------------------------------------------------"
			Li :=Li+1
			@ Li,000 PSAY STR0050  // |     PRODUTO      |               DESCRICAO                  | IMP |  ALIQ  |     BASE DE CALCULO     |      VALOR DO IMPOSTO
			Li += 1

			For nImp:=1 to Len(aItens)
				R170Load(000,cLinha)
				R170Load(001,aItens[nImp][1])
				R170Load(022,aItens[nImp][2])
				R170Load(064,aItens[nImp][3])
				R170Load(070,Transform(NoRound(aItens[nImp][4]),PesqPict("SD1","D1_ALQIMP6")))
				R170Load(080,Transform(aItens[nImp][5],PesqPict("SM2","M2_MOEDA1")))
				R170Load(106,Transform(aItens[nImp][6],PesqPict("SM2","M2_MOEDA1")))
				R170Say(Li)
				Li++
			Next
		Endif

		@ Li,000 PSAY __PrtThinLine()
		If Li < 57
			Li := 57
		Endif

	EndIf

	//                           1         2         3         4         5         6         7         8         9        10        11        12        13
	//                  123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	@ Li,000 PSAY STR0033 //"------------------------------------------------------------------- VISTOS ---------------------------------------------------------"
	Li += 1
	@ Li,000 PSAY "|                               |                                |                                  |                              |"
	Li += 1
	@ Li,000 PSAY STR0034 //"| Recebimento  Fiscal           | Contabil/Custos                | Departamento Fiscal              | Administracao                |"
	Li += 1
	@ Li,000 PSAY __PrtThinLine()
	dbSelectArea(cAliasSF1)
	dbSkip()
	_lTES := .F.
	_lPrcErr := .F.
	_lQtdErr := .F.
	_QtdSal := .F.
EndDo

dbSelectArea("SF1")
RetIndex("SF1")
If File(cArqInd+ OrdBagExt())
	FErase(cArqInd+ OrdBagExt() )
EndIf

dbSelectArea("SD1")
RetIndex("SD1")
If File(cArqIndSD1+ OrdBagExt())
	FErase(cArqIndSD1+ OrdBagExt() )
EndIf

#IFDEF TOP
	If !lAuto
		dbSelectArea("QRYSF1")
		dbCloseArea()
	EndIf
#ENDIF

If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R170Cabec() ³ Rev.  ³ Edson Maricate     ³ Data ³06/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do Boletim.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R170Cabec()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function R170Cabec()

Local li         := 01
Local aVencto    := {}
Local aAuxCombo1 := {"N","D","B","I","P","C"}
Local aCombo1	 := {STR0051,;	//"Normal"
	STR0052,;	//"Devoluçao"
	STR0053,;	//"Beneficiamento"
	STR0054,;	//"Compl.  ICMS"
	STR0055,;	//"Compl.  IPI"
	STR0056}	//"Compl. Preco/frete"
Local cNumDoc := ""
Local nIncCol := If(cPaisLoc=="MEX",8,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ li,000 PSAY AvalImp(132)
@ li,000 PSAY  ""
@ Li,000 PSAY STR0035 +CUSERNAME + STR0036+Dtoc(dDataBase) //"Usuario: "###" Data Base: "
Li += 1
@ li,000 PSAY __PrtFatLine()
Li += 1

If (cAliasSF1)->F1_TIPO $ "DB"
	dbSelectArea("SE1")
	dbSetOrder(2)
	dbSeek(xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC)
	While !Eof() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
		If ALLTRIM(E1_ORIGEM)=="MATA100"
			aADD(aVencto,E1_VENCREA)
		EndIf
		dbSkip()
	End
	@ li,000 PSAY OemToAnsi(STR0047)+SD1->D1_NUMSEQ+Space(66)+OemToAnsi(STR0048)+Dtoc(Date())+Space(14)+OemToAnsi(STR0049)+Time()   //  N. ## Data Ref. ### Hora Ref.
	li += 1
	@ li,000 PSAY STR0037 +dtoc((cAliasSF1)->F1_DTDIGIT)+IIF((cAliasSF1)->F1_TIPO=="D",STR0038," - ("+Alltrim(STR0053)+")") //"BOLETIM DE ENTRADA      Material recebido em: "###" - (Devolucao)"
	li += 1

	cCGC:=" - "
	cCGC+=Alltrim(RetTitle("A1_CGC"))
	cCGC+=": "
	cIE:=" "+AllTrim(RetTitle("A1_INSCR"))+": "
	cIEM:=" "+AllTrim(RetTitle("A1_INSCRM"))+": "

	@ li,0 PSAY SM0->M0_NOME + "-" + SM0->M0_FILIAL + cCGC + SM0->M0_CGC
	Li += 1
	@ li,0 PSAY __PrtThinLine()
	Li += 1
	@ li,0 PSAY If(cPaisLoc=="MEX",STR0107,STR0039) //"Dados do Cliente                                                                                 | Nota Fiscal  | Emissao  | Vencto"
	Li += 1
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
	cTipoNF	:= aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TIPO)]

	@ li,000 PSAY SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SUBS(SA1->A1_NOME,1,40)
	@ li,If(cPaisLoc=="BRA",069,065)-nIncCol PSAY "| "+(cAliasSF1)->F1_SERIE+" "+(cAliasSF1)->F1_DOC
	@ li,084 PSAY "| "+(cAliasSF1)->F1_ESPECIE
	@ li,091 PSAY "| "+PadR(CtipoNF,18)
	@ li,111 PSAY "|"+DTOC((cAliasSF1)->F1_EMISSAO)
	@ li,122 PSAY IIf( Len(aVencto) == 1,"|"+DTOC(aVencto[1]),If(Len(aVencto) ==0,"|"+STR0115,"|"+STR0040)) //"Diversos"
	Li += 1
	@ li,000 PSAY SA1->A1_END
	@ li,If(cPaisLoc=="BRA",069,065)-nIncCol PSAY STR0041
	@ li,115 PSAY transform(((cAliasSF1)->F1_VALBRUT),PesqPict("SF1","F1_VALBRUT")) //"| Valor Total   "
	Li += 1
	@ li,000 PSAY SA1->A1_MUN+" "+SA1->A1_EST+" "+Substr(cCGC,4,Len(cCGC)-3)+" "+If(cPaisLoc<>"BRA",Transform(SA1->A1_CGC,PesqPict("SA1","A1_CGC")),Transform(SA1->A1_CGC,PicPesFJ(If(Len(AllTrim(SA1->A1_CGC))<14,"F","J"))))+" "+cIE+" "+SA1->A1_INSCR+" "+cIEM+" "+SA1->A1_INSCRM //" CGC: "###"  I.E: "###"  I.M. "
Else
	dbSelectArea("SE2")
	dbSetOrder(6)
	dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC)
	While !Eof() .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
		If ALLTRIM(E2_ORIGEM)=="MATA100"
			aADD(aVencto,E2_VENCTO)
		EndIf
		dbSkip()
	End
	@ li,000 PSAY OemToAnsi(STR0047)+SD1->D1_NUMSEQ+Space(68)+OemToAnsi(STR0048)+Dtoc(Date())+Space(14)+OemToAnsi(STR0049)+Time()   // N. ### Data Impressao ### Hora Ref.
	li += 1
	@ li,000 PSAY STR0037 +Dtoc((cAliasSF1)->F1_DTDIGIT) //"BOLETIM DE ENTRADA      Material recebido em: "
	li += 1

	cCGC:=" - "
	cCGC+=Alltrim(RetTitle("A1_CGC"))
	cCGC+=": "
	cIE:=" "+AllTrim(RetTitle("A1_INSCR"))+": "
	cIEM:=" "+AllTrim(RetTitle("A1_INSCRM"))+": "

	@ li,0 PSAY SM0->M0_NOME + "-" + SM0->M0_FILIAL + cCGC + SM0->M0_CGC //" - CGC.: "
	li += 1
	@ li,000 PSAY __PrtThinLine()
	li += 1
	@ li,0 PSAY If(cPaisLoc=="BRA",STR0043,If(cPaisLoc=="MEX",STR0108,STR0057)) //"Dados do Fornecedor                                                                              | Nota Fiscal  | Emissao  | Vencto"
	li += 1
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(XFilial("SA2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
	cTipoNF	:= aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TIPO)]
	cNumDoc := If(cPaisLoc=="BRA",(cAliasSF1)->F1_DOC,PadR((cAliasSF1)->F1_DOC,If(cPaisLoc=="MEX",21,13),""))

	@ li,000 PSAY SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SubStr(SA2->A2_NOME,1,40)
	@ li,069-nIncCol PSAY "| "+(cAliasSF1)->F1_SERIE+" "+cNumDoc
	@ li,If(cPaisLoc=="BRA",84,88) PSAY "| "+(cAliasSF1)->F1_ESPECIE
	@ li,If(cPaisLoc=="BRA",91,95) PSAY "| "+PadR(CtipoNF,If(cPaisLoc=="BRA",19,16))
	@ li,If(cPaisLoc=="BRA",111,114) PSAY "|"+DTOC((cAliasSF1)->F1_EMISSAO)
	@ li,If(cPaisLoc=="BRA",122,125) PSAY "|"+IIf( Len(aVencto) == 1, DTOC(aVencto[1]), Iif(Len(aVencto) == 0,STR0115,STR0040)) //"Diversos"

	li += 1
	@ li,000 PSAY SA2->A2_END
	@ li,069-nIncCol PSAY STR0041
	@ li,115 PSAY transform(((cAliasSF1)->F1_VALBRUT),PesqPict("SF1","F1_VALBRUT")) //"| Valor Total   "
	li += 1
	@ li,000 PSAY SA2->A2_MUN+" "+SA2->A2_EST+" "+Substr(cCGC,4,Len(cCGC)-3)+" "+If(cPaisLoc<>"BRA",Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC")),Transform(SA2->A2_CGC,PicPesFJ(If(Len(AllTrim(SA2->A2_CGC))<14,"F","J"))))+" "+cIE+" "+SA2->A2_INSCR+" "+cIEM+" "+SA2->A2_INSCRM //" CGC: "###"  I.E: "###"  I.M. "
EndIf
li += 1
Return( li )


Static Function R170Load(nPos,cTexto)

cAuxLinha := Substr(cAuxLinha,1,nPos)+cTexto+Substr(cAuxLinha,nPos+Len(cTexto)+1,132-nPos+Len(cTexto))

Return

Static Function R170Say(nLinha)

@ nLinha,000 PSAY cAuxLinha
cAuxLinha := SPACE(132)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³R170IMPT  ºAuthor ³Armando P. Waiteman º Date ³  08/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a somatoria dos impostos da nota. Retornando um array   º±±
±±º          ³com todas as informacoes a serem impressas                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR170                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R170IMPT(cAliasSF1)


Local aArea    := {}
Local aAreaSD1 := {}
Local aImp     := {}
Local aImpostos:= {}
Local nImpos:= 0
Local nBase := 0
Local nY,cCampImp,cCampBas

aArea:=GetArea()


dbSelectArea("SD1")
aAreaSD1:=GetArea()

dbSetOrder(3)

cSeek:=(xFilial("SD1")+Dtos((cAliasSF1)->F1_EMISSAO)+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+;
	(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

If dbSeek(cSeek)
	While cSeek==xFilial("SD1")+dtos(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
		if empty(TesImpInf(D1_TES))
			exit
		endif
		aImpostos:=TesImpInf(D1_TES)
		For nY:=1 to Len(aImpostos)
			cCampImp:="SD1->"+(aImpostos[nY][2])
			cCampBas:="SD1->"+(aImpostos[nY][7])
			nImpos+=&cCampImp
		Next
		nBase +=&cCampBas
		dbSkip()
	Enddo
EndIf

RestArea(aAreaSD1)
RestArea(aArea)

AADD(aImp,nBase)
AADD(aImp,nImpos)


Return aImp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³R170IMPI  ºAuthor ³Armando P. Waiteman º Date ³  08/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com lista de impostos por item                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR170                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R170IMPI(cAliasSF1)


Local aArea    := {}
Local aAreaSD1 := {}
Local aImp     := {}
Local aRet     := {}
Local nY

aArea:=GetArea()


dbSelectArea("SD1")
aAreaSD1:=GetArea()

dbSetOrder(3)

cSeek:=(xFilial("SD1")+Dtos((cAliasSF1)->F1_EMISSAO)+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+;
	(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

If dbSeek(cSeek)
	While cSeek==xFilial("SD1")+dtos(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
		aImp:=TesImpInf(D1_TES)

		// Pega a descricao do produto
		If SD1->(FieldPos("D1_ZZDESCR")) <> 0 .and. !Empty(SD1->D1_ZZDESCR)
			cDescProd := SD1->D1_ZZDESCR
		Else
			dbSelectArea("SB1")
			aAreaSB1:=GetArea()
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD1->D1_COD)
			cDescProd:=B1_DESC
			RestArea(aAreaSB1)
		Endif

		dbSelectArea("SD1")
		For nY:=1 to Len(aImp)
			AADD(aRet,{SD1->D1_COD,cDescProd,aImp[nY][1],&("SD1->"+aImp[nY][10]),&("SD1->"+(aImp[nY][7])),&("SD1->"+(aImp[nY][2]))})
		Next
		dbSkip()
	Enddo
EndIf

If Len(aRet)<= 0
	AADD(aRet,{"" ,"" ,"" ,0 ,0 ,0})
EndIf

RestArea(aAreaSD1)
RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³R170Dupl  ºAuthor ³ALexandre I. Lemes  º Date ³  04/01/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime o Desdobramento de duplicatas                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR170                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R170DUPL(Li,Col)
Local nIncCol := If(cPaisLoc=="MEX",8,0)

dbSelectArea("SE2")

If Li >= 60
	Li := 1
	@ Li,000 PSAY STR0026 //"--------------------------------------------------- DESDOBRAMENTO DE DUPLICATAS ----------------------------------------------------"
	Li := Li + 1
	@ Li,000 PSAY If(cPaisLoc=="MEX",STR0109,STR0027) //"Ser|Titulo       | Vencto   |Valor do Titulo  | Natureza          ||Ser|Titulo       | Vencto   |Valor do Titulo  | Natureza        "
	Li := Li + 1
Endif

R170Load(Col,SE2->E2_PREFIXO)
R170Load(Col+4,SE2->E2_NUM)
R170Load(Col+16+nIncCol,SE2->E2_PARCELA)
R170Load(Col+18+nIncCol,dtoc(SE2->E2_VENCTO))
R170Load(Col+29+nIncCol,Transform(SE2->E2_VALOR,"@E 99,999,999,999.99"))
R170Load(Col+48+nIncCol,SE2->E2_NATUREZ)

If Col == 0
	Col := 68
Else
	Col := 0
	R170Say(Li)
	R170Load(0,cLinha)
	Li := Li + 1
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1    ³Autor ³ Aline Correa do Vale ³Data³16/01/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta perguntas do SX1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

Local aAreaAnt	 := GetArea()
Local aAreaSX1	 := SX1->(GetArea())
Local aAreaSX3	 := SX3->(GetArea())
Local aSXB		 := {}
Local nTamSX1    := Len(SX1->X1_GRUPO)
Local nTamSXB    := Len(SXB->XB_ALIAS)
Local aEstrut	 := {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
Local i			 := 1
Local j			 := 1
Local aHelpPor07 := {'Ordem de Impressao ', '', ''}
Local aHelpEsp07 := {'Orden de impresion ', '', ''}
Local aHelpEng07 := {'Print Order        ', '', ''}
Local aHelpPor08 := {'Se voce escolher imprimir o Armazem,  ', 'a descricao do Produto sera'      , 'reduzida em duas posicoes.'}
Local aHelpEsp08 := {'Si usted elige imprimir el Deposito,  ', 'la descripcion del producto sera ', 'reducida en dos posiciones.'}
Local aHelpEng08 := {'If you choose to print the Warehouse, ', 'the product description will be'  , 'reduced in two positions.'}

PutSX1Help("P.MTR17007.", aHelpPor07, aHelpEng07, aHelpEsp07)

PutSx1('MTR170','08','Imprime Armazem    ?','Imprime Deposito   ?','Show  Warehouse    ?','mv_ch8','N',2,0,2,'C','','','','','mv_par08','Sim','Si','Yes','','Nao','No','No','','','','','','','','','', aHelpPor08, aHelpEsp08, aHelpEng08)

// Ajusta a opcao do tipo
dbSelectArea("SX1")
If dbSeek(PADR("MTR170",nTamSX1)+"05")
	RecLock("SX1",.F.)
	Replace X1_DEF03   With "Entidade Contab"
	Replace X1_DEFSPA3 With "Ente Contable"
	Replace X1_DEFENG3 With "Account.Entity"
	MsUnLock()
EndIf

//-- Consulta SXB
Aadd(aSXB,{"SD1NF","1","01","DB"	,"Documento de Entrada"	,"Factura de Entrada"	,"Inflow Invoice"		,"SD1"       		})
Aadd(aSXB,{"SD1NF","2","01","01"	,"Documento"			,"Factura"				,"Document"				,"SD1"       		})
Aadd(aSXB,{"SD1NF","4","01","01"	,"Documento"			,"Factura"				,"Document"				,"SD1->D1_DOC"  	})
Aadd(aSXB,{"SD1NF","4","01","02"	,"Serie"				,"Serie"				,"Series"				,"SD1->D1_SERIE"	})
Aadd(aSXB,{"SD1NF","4","01","03"	,"Fornecedor"			,"Proveedor"			,"Supplier"				,"SD1->D1_FORNECE"	})
Aadd(aSXB,{"SD1NF","4","01","04"	,"Loja"		   			,"Tienda"				,"Unit"					,"SD1->D1_LOJA"		})
Aadd(aSXB,{"SD1NF","4","01","05"	,"Item"					,"Item"					,"Item"					,"SD1->D1_ITEMORI"	})
Aadd(aSXB,{"SD1NF","5","01",""		,""						,""						,""						,"SD1->D1_DOC"		})

dbSelectArea("SXB")
dbSetOrder(1)
For i := 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !dbSeek(PADR(aSXB[i,1],nTamSXB)+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			lSXB := .T.
			RecLock("SXB",.T.)
			For j:=1 To Len(aSXB[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajustando o dicionario SX1        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(PADR('MTR170',nTamSX1)+"03") .And. Empty(SX1->X1_F3)
	RecLock("SX1",.F.)
	Replace X1_F3 With 'SD1NF'
	MsUnLock()
EndIf
If dbSeek(PADR('MTR170',nTamSX1)+"04") .And. Empty(SX1->X1_F3)
	RecLock("SX1",.F.)
	Replace X1_F3 With 'SD1NF'
	MsUnLock()
EndIf
RestArea(aAreaSX1)
RestArea(aAreaSX3)
RestArea(aAreaAnt)
Return
