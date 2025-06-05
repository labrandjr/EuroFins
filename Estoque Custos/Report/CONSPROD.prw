#Include "rwmake.Ch"
/*/{Protheus.doc} CONSPROD
Consumo mes a mes
@author Marcos Candido
@since 02/01/2018


/*/
User Function CONSPROD()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL Tamanho  := "G"
LOCAL titulo   := "Consumos/Vendas mes a mes de Materiais"
LOCAL cDesc1   := "Este programa exibirá o consumo dos últimos 12 meses de cada material"
LOCAL cDesc2   := "ou produto acabado. No caso dos produtos ele estará listando o total"
LOCAL cDesc3   := "das vendas."
LOCAL cString  := "SB1"
LOCAL aOrd     := {}
LOCAL wnrel    := "CONSPROD"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn:= {"Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE nLastKey := 0 ,cPerg := "CONSPR"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ValidPerg()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // codigo de                                    ³
//³ mv_par02	 // codigo ate                                   ³
//³ mv_par03     // tipo de                                      ³
//³ mv_par04     // tipo ate                                     ³
//³ mv_par05     // grupo de                                     ³
//³ mv_par06     // grupo ate                                    ³
//³ mv_par07     // descricao de                                 ³
//³ mv_par08     // descricao ate                                ³
//³ mv_par09     // Almoxarifado                                 ³
//³ mv_par10     // Tipo de Saida (Por NF /                      ³
//³                                Por Movimentos Internos /     ³
//³                                Ambos) 						 ³
//³ mv_par11     // Envia para Excel                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao Setprint                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| Impressao(@lEnd,aOrd,wnRel,cString,tamanho,titulo)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³          ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³        			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Impressao(lEnd,aOrd,WnRel,cString,tamanho,titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aMeses:= {"JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"}
LOCAL nX ,nAno := 0 ,nMes := 0 ,aTot[12] ,lPassou ,nCol ,nMesAux
Local cPath	   := "C:\TEMP"
Local cBarra   := If(IsSrvUnix(), "/", "\")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis privadas exclusivas deste programa                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cMes ,cCondicao ,lContinua := .T. ,cCondSec ,cAnt, nMesConf
PRIVATE aColuna1 := { 074, 085, 096, 107, 118, 129, 140, 151, 162, 173, 184, 195}

MontaDir(cPath)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem Dos Dados do cabecalho do relatorio                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAno := Year(dDataBase)
If Month(dDatabase) < 12
	nAno--
Endif

nMes := Month(dDataBase)+1
IF nMes = 13
	nMes := 1
Endif

nMesConf := nMes
cMes := StrZero(nMes,2)
cAno := StrZero(nAno,4)

cabec1 := "CODIGO          TP GRUP DESCRICAO                                UM ALMOX"//JAN/20??   FEV/20??   MAR/20??   ABR/20??   MAI/20??   JUN/20??   JUL/20??   AGO/20??   SET/20??   OUT/20??   NOV/20??   DEZ/20??   TOTAL
//         123456789012345 12 1234 1234567890123456789012345678901234567890 12   XX  1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890
//         0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
//         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
FOR nX := 1 TO 12
	IF aMeses[nMes] == "JAN" .And. nX != 1
		nAno++
	EndIF
	cabec1 += Space(3)+aMeses[nMes]+"/"+StrZero(nAno,4)
	nMes++
	IF nMes > 12
		nMes := 1
	ENDIF
NEXT nX
cabec1 += Space(5)+"TOTAL"
cabec2 := ""

dDataDe := CtoD("01/"+cMes+"/"+cAno)
If mv_par10 == 1 .or. mv_par10 == 3
	dbSelectArea("SD2")
	dbSetorder(6)	// filial + produto + armazem + data de emissao + numero sequencial
	cArqSD2 := CriaTrab(nil,.f.)
	cFiltroSD2 := "D2_FILIAL == '"+xFilial("SD2")+"' .and. D2_COD >= '"+MV_PAR01+"' "
	cFiltroSD2 += ".and. D2_COD <= '"+mv_par02+"' .and. D2_LOCAL =='"+mv_par09+"' "
	cFiltroSD2 += ".and. DTOS(D2_EMISSAO) >= '"+DTOS(dDataDe)+"' .and. DTOS(D2_EMISSAO) <= '"+DTOS(dDataBase)+"'
	cFiltroSD2 += ".and. !(D2_TIPO $ 'DB')"
	cChaveSD2  := IndexKey()
	IndRegua("SD2",cArqSD2+OrdBagExt(),cChaveSD2,,cFiltroSD2,"Selecionando Registros...")
	dbSelectArea("SD2")
Endif

If mv_par10 == 2 .or. mv_par10 == 3
	dbSelectArea("SD3")
	dbSetorder(7)	// filial + produto + armazem + data de emissao + numero sequencial
	cArqSD3 := CriaTrab(nil,.f.)
	cFiltroSD3 := "D3_FILIAL == '"+xFilial("SD3")+"' .and. D3_COD >= '"+MV_PAR01+"' "
	cFiltroSD3 += ".and. D3_COD <= '"+mv_par02+"' .and. D3_LOCAL =='"+mv_par09+"' "
	cFiltroSD3 += ".and. DTOS(D3_EMISSAO) >= '"+DTOS(dDataDe)+"' .and. DTOS(D3_EMISSAO) <= '"+DTOS(dDataBase)+"'"
	cFiltroSD3 += ".and. D3_TM >= '500' .and. D3_ESTORNO <> 'S'"
	cChaveSD3  := IndexKey()
	IndRegua("SD3",cArqSD3+OrdBagExt(),cChaveSD3,,cFiltroSD3,"Selecionando Registros...")
	dbSelectArea("SD3")
Endif

aCampos := {}
AADD(aCampos,{"CODPRO"    , "C" , 15 , 0 })
AADD(aCampos,{"DESCPROD"  , "C" , 40 , 0 })
AADD(aCampos,{"UNIDMED"   , "C" , 02 , 0 })
AADD(aCampos,{"QUANT"     , "N" , 10 , 0 })
AADD(aCampos,{"ALMOX"     , "C" , 02 , 0 })
AADD(aCampos,{"TIPO"      , "C" , 02 , 0 })
AADD(aCampos,{"GRUPO"     , "C" , 04 , 0 })
AADD(aCampos,{"MES"       , "C" , 02 , 0 })
AADD(aCampos,{"ANO"       , "C" , 04 , 0 })
AADD(aCampos,{"COLUNA"    , "N" , 03 , 0 })

cArqTrab := CriaTrab(aCampos,.T.)
dbUseArea(.T.,,cArqTrab , "TRB" )
cIndTRB := CriaTrab(Nil,.F.)
IndRegua("TRB",cIndTRB+OrdBagExt(),"CODPRO+ALMOX+ANO+MES",,,"Preparando Arquivo Temporario...")
dbSelectArea("TRB")

nAno := Year(dDataBase)
If Month(dDatabase) < 12
	nAno--
Endif

nMes := Month(dDataBase)+1
IF nMes = 13
	nMes := 1
Endif

aCampos := {}
AADD(aCampos,{"CODPRO"    , "C" , 15 , 0 })
AADD(aCampos,{"DESCPROD"  , "C" , 40 , 0 })
AADD(aCampos,{"UNIDMED"   , "C" , 02 , 0 })
AADD(aCampos,{"ALMOX"     , "C" , 02 , 0 })
AADD(aCampos,{"TIPO"      , "C" , 02 , 0 })
AADD(aCampos,{"GRUPO"     , "C" , 04 , 0 })
FOR nX := 1 TO 12
	IF aMeses[nMes] == "JAN" .And. nX != 1
		nAno++
	EndIF
	AADD(aCampos,{aMeses[nMes]+"_"+StrZero(nAno,4)  , "N" , 10 , 0 })
	nMes++
	IF nMes > 12
		nMes := 1
	ENDIF
NEXT nX
cArqWRK := CriaTrab(aCampos,.T.)
dbUseArea(.T.,,cArqWRK , "WRK" )

dbSelectArea("SB1")
SetRegua(LastRec())

Set SoftSeek On
dbSetOrder(1)
dbSeek(xFilial("SB1")+mv_par01)
Set SoftSeek Off

AFILL(aTot,0)
While lContinua .And. !EOF() .and. B1_FILIAL == xFilial("SB1")

	If lEnd
		@Prow()+1,001 PSay "CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	Endif

	IncRegua()

	If B1_COD < mv_par01 .Or. B1_COD > mv_par02
		dbSkip()
		Loop
	EndIf

	If B1_TIPO < mv_par03 .Or. B1_TIPO > mv_par04
		dbSkip()
		Loop
	EndIf

	If B1_GRUPO < mv_par05 .Or. B1_GRUPO > mv_par06
		dbSkip()
		Loop
	EndIf

	If B1_DESC < mv_par07 .Or. B1_DESC > mv_par08
		dbSkip()
		Loop
	EndIf

	If mv_par10 == 1 .or. mv_par10 == 3
		dbSelectArea("SD2")
		If dbSeek(xFilial("SD2")+SB1->B1_COD)

			aDadosSD2 := {}
			While !Eof() .and. SD2->D2_COD == SB1->B1_COD .and. SD2->D2_FILIAL == xFilial("SD2")

				AADD(aDadosSD2 , {SD2->D2_EMISSAO , SD2->D2_COD , SD2->D2_LOCAL , SD2->D2_QUANT})
				dbSelectArea("SD2")
				dbSkip()

			End

    	    aSD2Ord := 	ASORT(aDadosSD2,,, { |x, y, z, w | Dtos(x[1]) < Dtos(y[1]) })

			For SD:=1 to Len(aSD2Ord)

				nGravColuna := PesqColuna(aSD2Ord[SD][1])
				dbSelectArea("TRB")
				If dbSeek(aSD2Ord[SD][2]+aSD2Ord[SD][3]+StrZero(Year(aSD2Ord[SD][1]),4)+StrZero(Month(aSD2Ord[SD][1]),2))
					RecLock("TRB",.F.)
				Else
					RecLock("TRB",.T.)
					  Replace CODPRO   With aSD2Ord[SD][2]
					  Replace DESCPROD With SB1->B1_DESC
					  Replace UNIDMED  With SB1->B1_UM
					  Replace ALMOX    With aSD2Ord[SD][3]
					  Replace TIPO     With SB1->B1_TIPO
					  Replace GRUPO    With SB1->B1_GRUPO
					  Replace MES	   With StrZero(Month(aSD2Ord[SD][1]),2)
					  Replace ANO	   With StrZero(Year(aSD2Ord[SD][1]),4)
				Endif
				Replace QUANT   With	QUANT + aSD2Ord[SD][4]
				Replace COLUNA  With 	nGravColuna
				MsUnlock()


			Next

		Endif
	Endif

	If mv_par10 == 2 .or. mv_par10 == 3

		dbSelectArea("SD3")
		If dbSeek(xFilial("SD3")+SB1->B1_COD)

			aDadosSD3 := {}
			While !Eof() .and. SD3->D3_COD == SB1->B1_COD .and. SD3->D3_FILIAL == xFilial("SD3")

				AADD(aDadosSD3 , {SD3->D3_EMISSAO , SD3->D3_COD , SD3->D3_LOCAL , SD3->D3_QUANT})
				dbSelectArea("SD3")
				dbSkip()

			End

    	    aSD3Ord := 	ASORT(aDadosSD3,,, { |x, y, z, w | Dtos(x[1]) < Dtos(y[1]) })

			For SD:=1 to Len(aSD3Ord)

				nGravColuna := PesqColuna(aSD3Ord[SD][1])
				dbSelectArea("TRB")
				If dbSeek(aSD3Ord[SD][2]+aSD3Ord[SD][3]+StrZero(Year(aSD3Ord[SD][1]),4)+StrZero(Month(aSD3Ord[SD][1]),2))
					RecLock("TRB",.F.)
				Else
					RecLock("TRB",.T.)
					  Replace CODPRO   With aSD3Ord[SD][2]
					  Replace DESCPROD With SB1->B1_DESC
					  Replace UNIDMED  With SB1->B1_UM
					  Replace ALMOX    With aSD3Ord[SD][3]
					  Replace TIPO     With SB1->B1_TIPO
					  Replace GRUPO    With SB1->B1_GRUPO
					  Replace MES	   With StrZero(Month(aSD3Ord[SD][1]),2)
					  Replace ANO	   With StrZero(Year(aSD3Ord[SD][1]),4)
				Endif
				Replace QUANT   With	QUANT + aSD3Ord[SD][4]
				Replace COLUNA  With 	nGravColuna
				MsUnlock()

			Next

		Endif
	Endif

    dbSelectArea("SB1")
    dbSkip()

End

If mv_par10 == 1
	titulo  := "Vendas mes a mes de Materiais"
ElseIf mv_par10 == 2
	titulo  := "Consumos mes a mes de Materiais"
Endif

dbSelectArea("TRB")
dbGoTop()
SetRegua(RecCount())

While !Eof()

	If li > 58
		Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
	EndIf

	IncRegua()

	@ li,000 PSAY TRB->CODPRO
	@ li,016 PSAY TRB->TIPO
	@ li,019 PSAY TRB->GRUPO
	@ li,024 PSAY TRB->DESCPROD
	@ li,065 PSAY TRB->UNIDMED
	@ li,070 PSAY TRB->ALMOX

	cProdAnt  := CODPRO
	aImpLin   := {}
	aLinhaOrd := {}

	dbSelectArea("WRK")
	RecLock("WRK",.T.)
	  Replace	CODPRO		With	TRB->CODPRO
	  Replace	TIPO		With	TRB->TIPO
	  Replace	GRUPO		With	TRB->GRUPO
	  Replace	DESCPROD	With	TRB->DESCPROD
	  Replace	UNIDMED		With	TRB->UNIDMED
	  Replace	ALMOX		With	TRB->ALMOX
	MsUnlock()

	dbSelectArea("TRB")
	While !Eof() .and. cProdAnt == CODPRO

 		AADD(aImpLin , {COLUNA , INT(QUANT)} )

		dbSelectArea("WRK")
		RecLock("WRK",.F.)

		nAno := Year(dDataBase)
		If Month(dDatabase) < 12
			nAno--
		Endif

		nMes := Month(dDataBase)+1
		IF nMes = 13
			nMes := 1
		Endif

		For nX := 1 TO 12
			If aMeses[nMes] == "JAN" .And. nX != 1
				nAno++
			Endif
			xCampo := (aMeses[nMes]+"_"+StrZero(nAno,4))
			If StrZero(nMes,2) == TRB->MES .and. StrZero(nAno,4) == TRB->ANO
			//If WRK->(&xCampo) == 0
				WRK->(&xCampo) := INT(TRB->QUANT)
				Exit
			Endif
			nMes++
			If nMes > 12
				nMes := 1
			Endif
		Next nX

		MsUnlock()

		dbSelectArea("TRB")
		dbSkip()

	Enddo

	aLinhaOrd := ASORT(aImpLin,,, { |x, y | x[1] < y[1] })

	nTotLinha := 0
	For ee:=1 to len(aLinhaOrd)
		@ li,aLinhaOrd[ee][1]   PSAY aLinhaOrd[ee][2] Picture PesqPictQt("B3_Q01",10)
		nTotLinha += aLinhaOrd[ee][2]
		nPos1 := aScan(aColuna1 , aLinhaOrd[ee][1])
		aTot[nPos1] += aLinhaOrd[ee][2]
	Next

	@ li,206 PSAY nTotLinha Picture PesqPictQt("B3_Q01",10)

	li++

EndDo

If li <> 80
	li++
	If li > 58
		Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
	EndIf
	@ li,010 PSAY "TOTAL"+Replicate(".",58)
	nCol := 74
	nTotLinha := 0
	For ee := 1 To 12
		@ li,nCol PSay aTot[ee] Picture PesqPictQt("B3_Q01",10)
		nCol += 11
		nTotLinha += aTot[ee]
	Next
	@ li,206 PSAY nTotLinha Picture PesqPictQt("B3_Q01",10)
	li += 2
	Roda(cbcont,cbtxt,Tamanho)
EndIf

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

If mv_par11 == 1

	cArqSai := "CONSUMO.DBF"

	If File(cPath+cBarra+cArqSai)     	// Apagar Arquivo de Saida Anterior
		FErase(cPath+cBarra+cArqSai)
	Endif

	cArqTmp := cArqWRK + ".DBF"            // Arquivo Temporario Auxiliar
	Copy File &cArqTmp To &cArqSai         	// Copiar Arquivo de Dados de Saida

	CpyS2T(cArqSai,cPath,.F.)
	If !ApOleClient("MsExcel")
   		MsgBox("Microsoft Excel Não Instalado !", "Atenção", "INFO")
   	Else
   		oExcelApp := MsExcel():New()
       	oExcelApp:WorkBooks:Open(cPath+cBarra+cArqSai)
       	oExcelApp:SetVisible(.T.)
   	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
Set Filter To
Retindex(cString)

If mv_par10 == 1 .or. mv_par10 == 3
	dbSelectArea("SD2")
	Set Filter To
	Retindex("SD2")
	fErase(cArqSD2+OrdBagExt())
Endif

If mv_par10 == 2 .or. mv_par10 == 3
	dbSelectArea("SD3")
	Set Filter To
	Retindex("SD3")
	fErase(cArqSD3+OrdBagExt())
Endif

dbSelectArea("TRB")
dbCloseArea()
fErase(cIndTRB+OrdBagExt())
fErase(cArqTrab+OrdBagExt())

dbSelectArea("WRK")
dbCloseArea()
fErase(cArqWRK+OrdBagExt())

Return


Static Function PesqColuna(dEmissao)
/* -------------------------*/

nChecaMes := nMesConf
nUseCol1 := 0

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[1]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[2]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[3]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[4]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[5]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[6]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[7]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[8]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[9]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[10]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[11]
Endif

nChecaMes++
If nChecaMes > 12
	nChecaMes := 1
Endif

If StrZero(Month(dEmissao),2) == StrZero(nChecaMes,2)
	nUseCol1 := aColuna1[12]
Endif

Return(nUseCol1)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  10/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()

Local aAreaAtual := GetArea()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Do Produto"     ,"","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
aAdd(aRegs,{cPerg,"02","Ate o Produto"  ,"","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
aAdd(aRegs,{cPerg,"03","Tipo De"        ,"","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Tipo Ate"       ,"","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Grupo De"       ,"","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Grupo Ate"      ,"","","mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Descricao De"   ,"","","mv_ch7","C",30,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Descricao Ate"  ,"","","mv_ch8","C",30,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Almoxarifado"   ,"","","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Tipo de Saida"  ,"","","mv_cha","N",01,0,3,"C","","mv_par10","NF Saida","","","","","Movim. Internos","","","","","Ambos","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Envia para Excel"  ,"","","mv_chb","N",01,0,1,"C","","mv_par11","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
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