#include 'rwmake.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RBxPad
Movimentacoes realizadas dos produtos do grupo PAD (Padrao)
@author Marcos Candido
@since 02/01/2018
/*/
User Function RBxPad
	Local cDesc1  := "Este programa tem como objetivo imprimir relatório com as informações "
	Local cDesc2  := "cadastradas na tabela de Baixa Automática de Padrões, possibilitando avaliar"
	Local cDesc3  := "os movimentos já realizados e o seu saldo. Especifico para a Eurofins."
	Local titulo  := "Relacao dos Movimentos de Baixa de Padroes"
	Local Cabec1  := "CODIGO DO        DESCRICAO                                           UNID  ARM.         QUANTIDADE  QTDE DE   DIFERIMENTO         QUANTIDADE         QUANTIDADE              SALDO"
	Local Cabec2  := "PRODUTO                                                              MED.                 ORIGINAL   MESES   REALIZADO EM    DIFERIDA NO DIA        JA DIFERIDA          A DIFERIR"
	Local imprime := .T.
	Local aOrd    := {}
	Local aPergs := {}
	Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
	
	/*
	CODIGO DO        DESCRICAO                                           UNID  ARM.         QUANTIDADE  QTDE DE   DIFERIMENTO         QUANTIDADE         QUANTIDADE              SALDO
	PRODUTO                                                              MED.                 ORIGINAL   MESES   REALIZADO EM    DIFERIDA NO DIA        JA DIFERIDA          A DIFERIR
	999999999999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XX    XX   99,999,999.999999    99       99/99/9999  99,999,999.999999
	                                                                                                               99/99/9999  99,999,999.999999
	                                                                                                               99/99/9999  99,999,999.999999  99,999,999.999999  99,999,999.999999
	*/
	
	Private cPerg       := PADR("RELBXPAD",10)
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private limite      := 220
	Private tamanho     := "G"
	Private nomeprog    := "RBXPAD"
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private m_pag       := 01
	Private wnrel       := "RBXPAD"
	Private cString     := "SZD"
	Li                  := 80
	
	//If SM0->M0_CODIGO # '01'																							//Retirado em 22/05/15 conforme chamado. - Roudineli Totvs
	//	Aviso(OemToAnsi('Atenção!!!'), OemToAnsi('Esta rotina só pode ser executada na empresa Eurofins.') , {'Sair'})	//Retirado em 22/05/15 conforme chamado. - Roudineli Totvs
	//	Return																											//Retirado em 22/05/15 conforme chamado. - Roudineli Totvs
	//Endif																												//Retirado em 22/05/15 conforme chamado. - Roudineli Totvs
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria, se necessario, o grupo de Perguntas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSx1(cPerg)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o grupo de Perguntas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)
	//===============================================================================================
	// Monta a interface padrao com o usuario...
	//===============================================================================================
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)
	
Return

/*
==============================================================================
Funcao     	RUNREPORT | Autor ³                    | Data ³
==============================================================================
Descricao 	Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS
			monta a janela com a regua de processamento.
==============================================================================
Uso     	Programa principal
==============================================================================*/
Static Function RunReport(Cabec1,Cabec2,Titulo)

	Local cQ := ""      
	Local nQtdDif,nQtdSal
	Local nTotRegs := 0
	Local aItExcel := {}
	Local aCabExcel := {'Código do Produto','Descrição','Unidade de Medida','Armazém','Quantidade Original','Quantidade de Meses','Diferimento Realizado em','Quantidade Diferida no dia','Quantidade já Diferida','Saldo a Diferir'}
	
	cQ += "SELECT * FROM "+RetSQLName("SZD")+" SZD, "+RetSQLName("SZE")+" SZE "
	cQ += "WHERE "
	cQ += "SZD.ZD_FILIAL = '"+xFilial("SZD")+"' AND "
	cQ += "SZE.ZE_FILIAL = '"+xFilial("SZE")+"' AND "
	cQ += "SZD.ZD_COD >=   '"+mv_par01+"' AND SZD.ZD_COD <= '"+mv_par02+"' AND "
	cQ += "SZD.ZD_ARMAZ >= '"+mv_par03+"' AND SZD.ZD_ARMAZ <= '"+mv_par04+"' AND "
	cQ += "SZD.ZD_SEQUENC = SZE.ZE_SEQUENC AND "
	cQ += "SZD.ZD_COD = SZE.ZE_COD AND SZD.ZD_ARMAZ = SZE.ZE_ARMAZ AND "
	cQ += "SZD.D_E_L_E_T_ <> '*' AND SZE.D_E_L_E_T_ <> '*' "
	cQ += "ORDER BY ZD_COD,ZD_ARMAZ,ZD_SEQUENC"
	
	If Select("WRK1") > 0
		WRK1->(dbCloseArea())
	Endif
	
	cQ := ChangeQuery(cQ)
	TcQuery cQ New Alias "WRK1"
	
	dbSelectArea("WRK1")
	nTotRegs := RecCount()
	dbGoTop()
	
	SetRegua(nTotRegs)
	
	If mv_par06 == 1	// impressao
	
		While !Eof() .and. !lAbortPrint
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Interrupcao(lAbortPrint)
				li++
				@ li,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Loop
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio. . .                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If li > 58
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			Endif
	
			li++
	
			cCodAnt := WRK1->(ZD_COD+ZD_ARMAZ+ZD_SEQUENC)
			lFirst  := .T.
			nQtdDif := 0
	        nQtdSal := 0
			While !Eof() .and. cCodAnt == WRK1->(ZD_COD+ZD_ARMAZ+ZD_SEQUENC)
	
				IncRegua()
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao do cabecalho do relatorio. . .                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If li > 58
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				Endif
	
				If lFirst
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+cCodAnt))
	
					@ li,000 PSAY WRK1->ZD_COD
					@ li,017 PSAY Substr(StrTran(SB1->B1_DESC,Chr(9),""),1,50)
					@ li,070 PSAY SB1->B1_UM
					@ li,076 PSAY WRK1->ZD_ARMAZ
					@ li,081 PSAY WRK1->ZD_QTDORI Picture "@E 99,999,999.999999"
					@ li,102 PSAY WRK1->ZD_MESES  Picture "99"
					lFirst  := .F.
					nQtdOri := WRK1->ZD_QTDORI
				Endif
	
				nLinAtu := li
	
				If mv_par05 == 1 	// visualiza detalhes 1=sim
					If !Empty(StoD(WRK1->ZE_DATA))
						@ li,111 PSAY StoD(WRK1->ZE_DATA)
						@ li,123 PSAY WRK1->ZE_QUANT Picture "@E 99,999,999.999999"
						nLinAtu := li
						li++
					Endif
				Endif
				If !Empty(StoD(WRK1->ZE_DATA))
					nQtdDif += WRK1->ZE_QUANT
				Else
					nQtdSal += WRK1->ZE_QUANT
				Endif
	
	 	       	dbSelectArea("WRK1")
				dbSkip()
	
			Enddo
	
			@ nLinAtu,142 PSAY nQtdDif 	Picture "@E 99,999,999.999999"
			@ nLinAtu,161 PSAY nQtdSal 	Picture "@E 99,999,999.999999"
			//@ nLinAtu,161 PSAY nQtdOri-nQtdDif 	Picture "@E 99,999,999.999999"
	
			li++
			@ li,000 Psay __PrtThinLine()
	        li++
	
		Enddo
	
		Roda(cbcont,cbtxt,Tamanho)
	
		SET DEVICE TO SCREEN
		If aReturn[5]==1
			dbCommitAll()
			SET PRINTER TO
			OurSpool(wnrel)
		Endif
	
		MS_FLUSH()
	
	Else
	
		While !Eof() .and. !lAbortPrint
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Interrupcao(lAbortPrint)
				Loop
			Endif
	
			cCodAnt := WRK1->(ZD_COD+ZD_ARMAZ+ZD_SEQUENC)
			lFirst  := .T.
			nQtdDif := 0
	        nQtdSal := 0
			While !Eof() .and. cCodAnt == WRK1->(ZD_COD+ZD_ARMAZ+ZD_SEQUENC)
	
				IncRegua()
	
				If lFirst
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+cCodAnt))
	
					aadd(aItExcel , {WRK1->ZD_COD , Substr(StrTran(SB1->B1_DESC,Chr(9),""),1,50) , SB1->B1_UM , WRK1->ZD_ARMAZ ,;
						    Transform(WRK1->ZD_QTDORI,"@E 99,999,999.999999"), Transform(WRK1->ZD_MESES,"99") ,;
						    DtoC(CtoD(Space(8))) , " " , " " , " "})
	
					lFirst  := .F.
					nQtdOri := WRK1->ZD_QTDORI
				Endif
	
				If mv_par05 == 1 	// visualiza detalhes 1=sim
					If !Empty(StoD(WRK1->ZE_DATA))
						aItExcel[Len(aItExcel)][7] := DtoC(StoD(WRK1->ZE_DATA))
						aItExcel[Len(aItExcel)][8] := Transform(WRK1->ZE_QUANT,"@E 99,999,999.999999")
					Endif
				Endif
				If !Empty(StoD(WRK1->ZE_DATA))
					nQtdDif += WRK1->ZE_QUANT
				Else
					nQtdSal += WRK1->ZE_QUANT
				Endif
	
	 	       	dbSelectArea("WRK1")
				dbSkip()
	
			Enddo
	
			aItExcel[Len(aItExcel)][9]  := Transform(nQtdDif,"@E 99,999,999.999999")
			aItExcel[Len(aItExcel)][10] := Transform(nQtdSal,"@E 99,999,999.999999")
			//aItExcel[Len(aItExcel)][10] := Transform(nQtdOri-nQtdDif,"@E 99,999,999.999999")
	
		Enddo
	
		DlgToExcel({ {"ARRAY", "Exportação para o Excel", aCabExcel, aItExcel} })
	
	Endif
	
	WRK1->(dbCloseArea())
	
Return
	
	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Local aHelpPor := {}
	Local aAreaAtual := GetArea()
	Local aRegs := {}
	Local i,j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Organiza o Grupo de Perguntas e Help ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aAdd(aHelpPor,"Informe o código do produto inicial a ")
	aAdd(aHelpPor,"ser considerado nas informações que")
	aAdd(aHelpPor,"serão exibidas.")
	Aadd(aRegs,{cPerg,"01","Do Produto","","","mv_ch1","C",15,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","PADSLD","",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o código do produto final a ")
	aAdd(aHelpPor,"ser considerado nas informações que")
	aAdd(aHelpPor,"serão exibidas.")
	Aadd(aRegs,{cPerg,"02","Ate o Produto","","","mv_ch2","C",15,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","PADSLD","",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o código do armazém inicial a ")
	aAdd(aHelpPor,"ser considerado nas informações que")
	aAdd(aHelpPor,"serão exibidas.")
	Aadd(aRegs,{cPerg,"03","Do Armazem","","","mv_ch3","C",02,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o código do armazém final a ")
	aAdd(aHelpPor,"ser considerado nas informações que")
	aAdd(aHelpPor,"serão exibidas.")
	Aadd(aRegs,{cPerg,"04","Ate o Armazem","","","mv_ch4","C",02,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Deseja visualizar o detalhes dos")
	aAdd(aHelpPor,"diferimentos já realizados?")
	Aadd(aRegs,{cPerg,"05","Visualiza detalhes","","","mv_ch5","N",01,0,1,"C","","MV_PAR05","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Deseja montar a impressão ou enviar ")
	aAdd(aHelpPor,"os dados para o Ms-Excel?")
	Aadd(aRegs,{cPerg,"06","Metodo de Saida" ,"","","mv_ch6","N",01,0,1,"C","","MV_PAR06","Impressao","","","","","Excel","","","","","","","","","","","","","","","","","","","","",""})//,"."+cPerg+"06."
	
	
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