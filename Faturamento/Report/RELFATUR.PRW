#include "rwmake.ch"
/*/{Protheus.doc} RelFatur
Romaneio do faturamento de pedidos de vendas
@author Paulo Roberto de Oliveira
@since 14/07/2005
/*/
User Function RelFatur(_cDocto, _cSerie)
////////////////////////////////////////
//
If Empty(_cDocto) .Or. ValType(_cDocto) # "C"
	_cDocto := SF2->F2_DOC
Endif
//
If Empty(_cSerie) .Or. ValType(_cSerie) # "C"
	_cSerie := SF2->F2_SERIE
Endif
//
Private wnRel       := "RELFATUR"
Private Tamanho     := "P"
Private Titulo      := "Fatura de Pedidos"
Private cDesc1      := "Este programa tem como objetivo gerar um relatório demonstrativo do romaneio"
Private cDesc2      := "de faturamento de pedidos de venda de acordo com os parâmetros informados."
Private cDesc3      := ""
Private aReturn     := {"Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private NomeProg    := "RELFATUR"
Private nCntImpr    := 0
Private cRodaTxt    := ""
Private cPerg       := PADR("RELFAT",10)
Private nLastKey    := 0
Private cString     := "SF2"
Private Li          := 66
Private m_Pag       := 1
Private Limite      := 80
Private lAbortPrint := .F.
Private cTraco      := Replicate("_", Limite)

Private aCabExcel := {' ',' ',' ',' '}
Private aItExcel  := {}
Private Rodape1 := ''
Private Rodape2 := ''
Private Rodape3 := ''

//
U_Parametr()                           // Verificacao e Criacao de Parametros Especificos
//
Perguntas()                            // Verificar Perguntas Especificas
//
Pergunte(cPerg, .F.)
//
wnRel := SetPrint(cString, wnRel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .F.,, .T., Tamanho)
//
If nLastKey == 27
	Return (.T.)
Endif
//
SetDefault(aReturn, cString)
//
If nLastKey == 27
	Return (.T.)
Endif
//
If Empty(Mv_Par01) .Or. Empty(Mv_Par02) .Or. Empty(Mv_Par03)
	//
	Mv_Par01 := SF2->F2_DOC //_cDocto
	Mv_Par02 := SF2->F2_DOC //_cDocto
	Mv_Par03 := SF2->F2_SERIE //_cSerie
	mv_par04 := SF2->F2_CLIENTE
	mv_par05 := SF2->F2_LOJA
	mv_par06 := SF2->F2_CLIENTE
	mv_par07 := SF2->F2_LOJA
	//
Endif

If Mv_Par02 < Mv_Par01 .Or. Empty(Mv_Par02) .Or. Mv_Par06 < Mv_Par04 .Or. Empty(Mv_Par06)
	MsgBox("Parâmetros Informados Incorretamente !!!", "Atenção !!!", "INFO")
Else
	RptStatus({|lAbortPrint| Relatorio()}, Titulo)
Endif
//
Set Device To Screen
//
If aReturn[5] == 1
	//
	Set Printer To
	DbCommitAll()
	OurSpool(wnRel)
	//
Endif
//
Ms_Flush()

If IW_MsgBox("Deseja enviar os dados para o MS-Excel?" , "Planilha" , "YESNO")
	aadd(aItExcel , {Rodape1,' ',' ',' '})
	aadd(aItExcel , {Rodape2,' ',' ',' '})
	aadd(aItExcel , {Rodape3,' ',' ',' '})
	DlgToExcel({ {"ARRAY", "Exportação para o Excel", aCabExcel, aItExcel} })
Endif

//
Return (.T.)

////////////////////////
User Function ConNotaF()
////////////////////////
//
Private cCadastro  := "Romaneio de Faturamento de Pedidos de Venda"
Private CondBrowse := "SF2->F2_TIPO == 'N'"
Private aRotina    := {{"Pesquisar" , "AxPesqui"                              , 0, 1},;
{"Visualizar", "AxVisual"                              , 0, 2},;
{"Imprimir"  , "U_RelFatur(SF2->F2_DOC, SF2->F2_SERIE)", 0, 9}}
//
U_Parametr()                           // Verificacao e Criacao de Parametros Especificos
//
SF2->(DbSetOrder(1))                   // Cabecalho de Notas Fiscais de Saida
//
DbSelectArea("SF2")                    // CondBrowse True=Vermelho, False=Verde
//
mBrowse(06, 01, 22, 75, "SF2",, '&CondBrowse',,, 2)
//
Set Filter To
//
Return (.T.)

///////////////////////////
Static Function Relatorio()
///////////////////////////
//
Local cItemPV := "01"                  // Item Master do Pedido de Venda
Local nRegIte := 0                     // Registro Corrente do Pedido de Venda
//
Titulo  := "Romaneio de Faturas"
Cabec1  := ""
Cabec2  := ""
nTipo   := IIf(aReturn[4] == 1, 15, 18)
Li      := 66
lPriVez := .T.                         // Flag de Controle de Quebra de Pedido
lRodape := .F.                         // Flag de Controle de Impressao do Rodape
nTipPro := 4                           // Tamanho do Tipo do Codigo Inteligente do Produto
cSimbP  := ""                          // Simbolo da Moeda Padrao
cSingP  := ""                          // Descricao da Moeda Padrao no Singular
cPlurP  := ""                          // Descricao da Moeda Padrao no Plural
cSimbX  := ""                          // Simbolo da Moeda Utilizada no Pedido de Venda
cSingX  := ""                          // Descricao da Moeda Utilizada no Singular
cPlurX  := ""                          // Descricao da Moeda Utilizada no Plural
nItens  := 0                           // Contador de Itens da Nota Fiscal Fatura
nTotal  := 0                           // Valor Total da Nota Fiscal Fatura
nRecSF2 := SF2->(Recno())              // Registro de Nota Fiscal Corrente
xC6_DESCRI := ""
//
SetPrc(0, 0)
//
SB1->(DbSetOrder(1))                   // Produtos
SA1->(DbSetOrder(1))                   // Clientes
SC5->(DbSetOrder(1))                   // Cabecalho de Pedidos de Venda
SC6->(DbSetOrder(1))                   // Itens de Pedidos de Venda
SBR->(DbSetOrder(1))                   // Dados Basicos do Produto
SZ1->(DbSetOrder(1))                   // Tipos de Amostras
SZ2->(DbSetOrder(1))                   // Descritivos p/ Analises
SZ3->(DbSetOrder(1))                   // Descricao das Amostras
SZ6->(DbSetOrder(1))                   // Configuracao de Laudos
SZ7->(DbSetOrder(1))                   // Resultados das Analises
SF4->(DbSetOrder(1))                   // Tipos de Entrada/Saida
SF2->(DbSetOrder(1))                   // Cabecalho de Notas Fiscais de Saida
SD2->(DbSetOrder(3))                   // Itens de Notas Fiscais de Saida
//
//SD2->(DbSetOrder(U_AchaOrdem("SD2", "D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_NROCERT")))
//
DbSelectArea("SF2")
SetRegua(SF2->(LastRec()))
SF2->(DbSeek(xFilial("SF2") + Mv_Par01 + Mv_Par03, .T.))
//
cQuebra := (SF2->F2_DOC + SF2->F2_SERIE)
//
While SF2->(!Eof()) .And. SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_DOC <= Mv_Par02
	//
	IncRegua()
	//
	If lAbortPrint
		Exit
	Endif
	//
	If SF2->F2_SERIE # Mv_Par03 .Or. (SF2->F2_CLIENTE + SF2->F2_LOJA) < (Mv_Par04 + Mv_Par05);
		.Or. (SF2->F2_CLIENTE + SF2->F2_LOJA) > (Mv_Par06 + Mv_Par07)
		//
		SF2->(DbSkip())
		cQuebra := (SF2->F2_DOC + SF2->F2_SERIE)
		Loop
		//
	Endif
	//
	SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, .F.))
	//
	nItens  := 0                     // Contador de Itens Impressos
	nTotal  := 0                     // Valor Total da NFF
	nPagina := 0                     // Contador de Paginas
	aDet    := {}						// array para armazenamento das informacoes a serem impressas
	//
	SD2->(DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA, .T.))
	//
	While SD2->(!Eof()) .And. SD2->D2_FILIAL == xFilial("SD2") .And.;
		(SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA) ==;
		(SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
		//
		SF4->(DbSeek(xFilial("SF4") + SD2->D2_TES, .F.))
		//
		If SF4->(!Found()) .Or. SF4->F4_DUPLIC # "S"
			//
			SD2->(DbSkip())
			Loop
			//
		Endif
		//
		xC6_DESCRI := ""
		cSimbP := Alltrim(GetMv("MV_SIMB1"))
		cSingP := Alltrim(GetMv("MV_MOEDA1"))
		cPlurP := Alltrim(GetMv("MV_MOEDAP1"))
		//
		cSimbX := cSimbP
		cSingX := cSingP
		cPlurX := cPlurP
		//
		SC5->(DbSeek(xFilial("SC5") + SD2->D2_PEDIDO, .F.))
		//
		If SC5->C5_MOEDA > 1 .And. SC5->C5_MOEDA <= 5
			//
			cSimbX := Alltrim(GetMv("MV_SIMB" + Str(SC5->C5_MOEDA, 1)))
			cSingX := Alltrim(GetMv("MV_MOEDA" + Str(SC5->C5_MOEDA, 1)))
			cPlurX := Alltrim(GetMv("MV_MOEDAP" + Str(SC5->C5_MOEDA, 1)))
			//
		Endif
		//
		SC6->(DbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV, .F.))
		//
		xZ2_TIPPRO := Substr(SC6->C6_PRODUTO, 1, nTipPro)
		//
		If Li > 53 .Or. lPriVez
			//
			Cabecalho()             // Impressao do Cabecalho
			//
			lPriVez := .F.
			//
		Endif
		//
		SBR->(DbSeek(xFilial("SBR") + xZ2_TIPPRO, .F.))
		//
		If SBR->(Found())
			//
			xBR_BASE    := xZ2_TIPPRO
			xBR_DESCPRD := Alltrim(SBR->BR_DESCPRD)
			//
		Else
			//
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO, .F.))
			//
			xBR_BASE    := SC6->C6_PRODUTO
			xBR_DESCPRD := " "
			//
		Endif
		//
		If SZ2->(DbSeek(xFilial("SZ2") + xZ2_TIPPRO, .F.))
			If !Empty(SZ2->Z2_DESCFAT)
				xC6_DESCRI := SZ2->Z2_DESCFAT
			Endif
		Endif
		//
		nRegIte := SC6->(Recno())
		//
		xC6_ITEM    := SC6->C6_ITEM
		xC6_PRODUTO := SC6->C6_PRODUTO
		If Empty(xC6_DESCRI)
			xC6_DESCRI  := SC6->C6_DESCRI
		Endif
		//
		//
		If SC6->C6_ITEM # cItemPV
			//
			SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM + cItemPV, .F.))
			//
			If SC6->(!Found())
				SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM, .F.))
			Endif
			//
		Endif
		//
		xC6_ZZCODAM := OemToAnsi(Alltrim(SC6->C6_ZZCODAM))
		xC6_XLOTE1 := OemToAnsi(Alltrim(SC6->C6_ZZLOT01))
		xC6_XLOTE2 := OemToAnsi(Alltrim(SC6->C6_ZZLOT02))
		xC6_XLOTE3 := OemToAnsi(Alltrim(SC6->C6_ZZLOT03))
		xC6_XLOTE4 := OemToAnsi(Alltrim(SC6->C6_ZZLOT04))
		//
		SZ1->(DbSeek(xFilial("SZ1") + SC6->C6_ZZTIPO, .F.))
		//
		SZ3->(DbSeek(xFilial("SZ3") + SC6->C6_ZZSDESC, .F.))
		//
		SC6->(DbGoTo(nRegIte))
		//
		nItens += 1
		nTotal += SC6->C6_VALOR
		//
		If Alltrim(xC6_PRODUTO) == "AGRO"
			If mv_par14 == 2
				xC6_DESCRI := "Agronomical Studies"
			Endif
			lAgro := .T.
		Else
			lAgro := .F.
		Endif
		aadd(aDet , {nItens,SC6->C6_ZZNROCE,xBR_BASE,SC6->C6_VALOR,;
		xC6_DESCRI,xBR_DESCPRD,SZ1->Z1_DESCP,xC6_ZZCODAM,;
		xC6_XLOTE1,xC6_XLOTE2,xC6_XLOTE3,xC6_XLOTE4,lAgro})
		//
		SD2->(DbSkip())
		//
	Enddo

	Detalhe()                  // Impressao do Item de Detalhe
	If Li > 53
		RodaFat()               // Impressao do Rodape
	Endif
	lRodape := .T.
	//
	If !lPriVez
		//
		If Li > 53
			Cabecalho()
		Endif
		//
		TotalFat()                    // Impressao do Total da Fatura
		//
		If lRodape
			RodaFat()
		Endif
		//
	Endif
	//
	SF2->(DbSkip())
	//
	If (SF2->F2_DOC + SF2->F2_SERIE) # cQuebra .Or. SF2->(Eof())
		//
		cQuebra := (SF2->F2_DOC + SF2->F2_SERIE)
		lPriVez := .T.
		Li      := 66
		//
	Endif
	//
Enddo
//
SD2->(DbSetOrder(1))
//
SF2->(DbGoTo(nRecSF2))
//
Return (.T.)

///////////////////////////
Static Function Cabecalho()
///////////////////////////
//
nPagina += 1
//
If Mv_Par11 == 1                       // Faturamento
	//
	SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F.))
	//
Elseif Mv_Par11 == 2                   // Entrega
	//
	SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENT + SC5->C5_LOJAENT, .F.))
	//
Elseif Mv_Par11 == 3                   // Remetente
	//
	SA1->(DbSeek(xFilial("SA1") + SC5->C5_CENVIO + SC5->C5_LENVIO, .F.))
	//
Elseif Mv_Par11 == 4                   // Resultado
	//
	SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLAUDO + SC5->C5_LLAUDO, .F.))
	//
Endif
//
If Mv_Par14 == 1                       // Portugues
	//
	cDataExt := OemToansi(U_DataExte(SF2->F2_EMISSAO, 2, "P"))
	cDataSol := OemToansi("Formulário de solicitação de análise datado de : " + Dtoc(SC5->C5_ZZDATAP))
	cDataRec := OemToansi("Data de Recebimento da(s) amostra(s)           : " + Dtoc(SC5->C5_ZZDATAR))
	cNumeFat := OemToansi("Fatura : " + Alltrim(SF2->F2_DOC))
	cPagiNro := OemToansi("Página : " + Alltrim(Str(nPagina, 3)) + IIf(Mv_Par13 == 0, "", "/" + Alltrim(Str(Mv_Par13, 4))))
	cCabeca1 := OemToansi("Posição  No. da    Descrição do Item                               Preço Total  ")
	cCabeca2 := OemToansi("         Amostra                                                     (" + cSimbX + ")")
	//                     . 999   99-X99999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999.999.999,99
	cCodiCli := OemToansi("No. do Cliente : " + Alltrim(SA1->A1_COD) + "/" + Alltrim(SA1->A1_LOJA))
	//
Elseif Mv_Par14 == 2                   // Ingles
	//
	cDataExt := OemToansi(U_DataExte(SF2->F2_EMISSAO, 2, "E"))
	cDataSol := OemToansi("Date of Order : " + Dtoc(SC5->C5_ZZDATAP))
	cDataRec := OemToansi("Sample reception(s) : " + Dtoc(SC5->C5_ZZDATAR))
	cNumeFat := OemToansi("Invoice : " + Alltrim(SF2->F2_DOC))
	cPagiNro := OemToansi("Page : " + Alltrim(Str(nPagina, 3)) + IIf(Mv_Par13 == 0, "", "/" + Alltrim(Str(Mv_Par13, 4))))
	cCabeca1 := OemToansi("Position  Sample   Item Description                                Total Price  ")
	cCabeca2 := OemToansi("          Number                                                     (" + cSimbX + ")")
	//                     . 999   99-X99999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999.999.999,99
	cCodiCli := OemToansi("Client Number : " + Alltrim(SA1->A1_COD) + "/" + Alltrim(SA1->A1_LOJA))
	//
Else                                   // Espanhol
	//
	cDataExt := OemToansi(U_DataExte(SF2->F2_EMISSAO, 2, "S"))
	cDataSol := OemToansi("Formulário de solicitação de análise datado de : " + Dtoc(SC5->C5_ZZDATAP))
	cDataRec := OemToansi("Data de Recebimento da(s) amostra(s)           : " + Dtoc(SC5->C5_ZZDATAR))
	cNumeFat := OemToansi("Fatura : " + Alltrim(SF2->F2_DOC))
	cPagiNro := OemToansi("Página : " + Alltrim(Str(nPagina, 3)) + IIf(Mv_Par13 == 0, "", "/" + Alltrim(Str(Mv_Par13, 4))))
	cCabeca1 := OemToansi("Posição  No. da    Descrição do Item                               Preço Total  ")
	cCabeca2 := OemToansi("         Amostra                                                     (" + cSimbX + ")")
	//                     . 999   99-X99999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999.999.999,99
	cCodiCli := OemToansi("No. do Cliente : " + Alltrim(SA1->A1_COD) + "/" + Alltrim(SA1->A1_LOJA))
	//
Endif
//
cNomeCli := OemToansi(Alltrim(SA1->A1_NOME))
cEndeCli := OemToansi(Alltrim(SA1->A1_END) + "   " + Alltrim(SA1->A1_BAIRRO))
cCidaCli := OemToansi(Transform(SA1->A1_CEP, "@R 99999-999") + "   " + Alltrim(SA1->A1_MUN) + " - " + Alltrim(SA1->A1_EST))
//
If !Empty(SC5->C5_ZZCON02)
	cContCli := OemToansi("A/C " + Alltrim(SC5->C5_ZZCON02))
Elseif !Empty(SC5->C5_ZZCON01)
	cContCli := OemToansi("A/C " + Alltrim(SC5->C5_ZZCON01))
Else
	cContCli := ""
Endif
//
If Mv_Par11 == 5                       // Nenhum Cliente
	//
	cCodiCli := ""
	cNomeCli := ""
	cEndeCli := ""
	cCidaCli := ""
	cContCli := ""
	//
Endif
//
Li := 0
@ Li, 000 Psay Avalimp(Limite)
//
Li += 7
@ Li, 005 Psay cNomeCli
Li += 1
@ Li, 005 Psay cEndeCli
Li += 1
@ Li, 005 Psay cCidaCli
Li += 1
@ Li, 005 Psay cContCli
@ Li, 043 Psay cCodiCli
//
Li += 2
@ Li, 043 Psay cDataExt
Li += 1
@ Li, 005 Psay cNumeFat
Li += 1
@ Li, 058 Psay cPagiNro
Li += 2
@ Li, 000 Psay cDataSol
Li += 1
@ Li, 000 Psay cDataRec
Li += 1
@ Li, 000 Psay cTraco
Li += 1
@ Li, 000 Psay cCabeca1
Li += 1
@ Li, 000 Psay cCabeca2
Li += 1
@ Li, 000 Psay cTraco
Li += 2
//
If Len(aItExcel) == 0
	aadd(aItExcel , {cNomeCli,' ',' ',' '})
	aadd(aItExcel , {cEndeCli,' ',' ',' '})
	aadd(aItExcel , {cCidaCli,' ',' ',' '})
	aadd(aItExcel , {' ',' ',' ',' '})
	aadd(aItExcel , {' ',' ',' ',cContCli})
	aadd(aItExcel , {' ',' ',' ',cDataExt})
	aadd(aItExcel , {' ',' ',' ',cNumeFat})
	aadd(aItExcel , {' ',' ',' ',' '})
	aadd(aItExcel , {cDataSol,' ',' ',' '})
	aadd(aItExcel , {cDataRec,' ',' ',' '})
	aadd(aItExcel , {' ',' ',' ',' '})
	If Mv_Par14 == 1                       // Portugues
		cAux1 := "Pos."
		cAux2 := "No da Amostra"
		cAux3 := "Descrição do Item"
		cAux4 := "Preço Total (" + cSimbX + ")"
	Elseif Mv_Par14 == 2                   // Ingles
		cAux1 := "Pos."
		cAux2 := "Sample Number"
		cAux3 := "Item Description"
		cAux4 := "Total Price (" + cSimbX + ")"
	Else                                   // Espanhol
		cAux1 := "Pos."
		cAux2 := "No da Amostra"
		cAux3 := "Descrição do Item"
		cAux4 := "Preço Total (" + cSimbX + ")"
	Endif
	aadd(aItExcel , {cAux1,cAux2,cAux3,cAux4})
	aadd(aItExcel , {' ',' ',' ',' '})
Endif

Return (.T.)

/////////////////////////
Static Function Detalhe()
/////////////////////////
//

aSort(aDet,,, {|x,y| x[2] < y[2]} )

For nD:=1 to Len(aDet)

	If nD > 1
		aadd(aItExcel , {' ',' ',' ',' '})
	Endif

	//@ Li, 002 Psay Strzero(aDet[nD][1], 3)
	@ Li, 002 Psay Strzero(nD, 3)
	If Substr(aDet[nD][2],2,1)==" "
		@ Li, 008 Psay Substr(aDet[nD][2],6,9) 							//B 25-09-N03825    ==> 09-N03825
	Else
		@ Li, 008 Psay Substr(aDet[nD][2],6,4)+Substr(aDet[nD][2],12,6)  //691-2009-00004793  ==> 009-04793
	Endif
	@ Li, 019 Psay Substr(aDet[nD][3],1,45)
	@ Li, 066 Psay Transform(aDet[nD][4],"@E 999,999,999.99")

	If Substr(aDet[nD][2],2,1)==" "
		aadd(aItExcel , {Strzero(nD,3),Substr(aDet[nD][2],6,9)                          ,Substr(aDet[nD][3],1,45),Transform(aDet[nD][4], "@E 999,999,999.99")})
	Else
		aadd(aItExcel , {Strzero(nD,3),Substr(aDet[nD][2],6,4)+Substr(aDet[nD][2],12,6),Substr(aDet[nD][3],1,45),Transform(aDet[nD][4], "@E 999,999,999.99")})
	Endif

	Li += 1

	If Li > 58
		//
		RodaFat()
		Cabecalho()
		//
	Endif

	@ Li, 019 Psay OemToansi(Substr(aDet[nD][5], 1, 45))
	aadd(aItExcel , {' ',' ',Substr(aDet[nD][5],1,45),' '})
	Li += 1

	//
	If Li > 58
		//
		RodaFat()
		Cabecalho()
		//
	Endif
	//
	If !Empty(Substr(aDet[nD][5], 46, 45))
		@ Li, 019 Psay OemToansi(Substr(aDet[nD][5], 46, 45))
		aadd(aItExcel , {' ',' ',Substr(aDet[nD][5],46,45),' '})
		Li += 1
	Endif
	//
	If !Empty(Substr(aDet[nD][5], 91, 45))
		@ Li, 019 Psay OemToansi(Substr(aDet[nD][5], 91, 45))
		aadd(aItExcel , {' ',' ',Substr(aDet[nD][5],91,45),' '})
		Li += 1
	Endif
	//
	If Li > 58
		//
		RodaFat()
		Cabecalho()
		//
	Endif
	//

	If !Empty(aDet[nD][6])
		//
		If Mv_Par14 == 1                    // Portugues
			@ Li, 019 Psay OemToansi(Substr("Código : " + aDet[nD][6],1,45))
			aadd(aItExcel , {' ',' ',Substr("Código : " + aDet[nD][6],1,45),' '})
		Elseif Mv_Par14 == 2                // Ingles
			@ Li, 019 Psay OemToansi(Substr("Code : " + aDet[nD][6],1,45))
			aadd(aItExcel , {' ',' ',Substr("Code : " + aDet[nD][6],1,45),' '})
		Else                                // Espanhol
			@ Li, 019 Psay OemToansi(Substr("Código : " + aDet[nD][6], 1, 45))
			aadd(aItExcel , {' ',' ',Substr("Código : " + aDet[nD][6],1,45),' '})
		Endif
		//
		Li += 1
		//
	Endif
	//
	If Mv_Par12 == 1                       // Imprime Analise da Amostra (1=Sim, 2=Nao)
		//
		If Mv_Par14 == 1                    // Portugues
			If aDet[nD][13]
				@ Li, 019 Psay OemToansi("Serviço de Consultoria Estudo Agronômico")
				aadd(aItExcel , {' ',' ',"Serviço de Consultoria Estudo Agronômico",' '})
			Else
				@ Li, 019 Psay OemToansi(Substr("Análise da amostra " + aDet[nD][7],1,45))
				aadd(aItExcel , {' ',' ',Substr("Análise da amostra " + aDet[nD][7],1,45),' '})
			Endif
		Elseif Mv_Par14 == 2                // Ingles
			If aDet[nD][13]
				@ Li, 019 Psay OemToansi("Consulting Services in Agronomical Studies")
				aadd(aItExcel , {' ',' ',"Consulting Services in Agronomical Studies",' '})
			Else
				@ Li, 019 Psay OemToansi(Substr("Analysis of sample " + aDet[nD][7],1,45))
				aadd(aItExcel , {' ',' ',Substr("Analysis of sample " + aDet[nD][7],1,45),' '})
			Endif
		Else                                // Espanhol
			@ Li, 019 Psay OemToansi(Substr("Análise da amostra " + aDet[nD][7], 1, 45))
			aadd(aItExcel , {' ',' ',Substr("Análise da amostra " + aDet[nD][7],1,45),' '})
		Endif
		//
		Li += 1
		//
	Endif
	//
	If Mv_Par08 == 1                       // Imprime Codigo da Amostra (1=Sim, 2=Nao)
		//
		nMemCount := MlCount( aDet[nD][8], 45 )
		If !Empty( nMemCount )
			For nLoop := 1 To nMemCount
				cLinha := MemoLine( aDet[nD][8], 45, nLoop )
				If Li > 58
					RodaFat()
					Cabecalho()
				Endif
				If !Empty(Alltrim(cLinha))
					@ Li,019 PSAY cLinha
					aadd(aItExcel , {' ',' ',cLinha,' '})
					li++
				Endif
			Next nLoop
		EndIf
		//
	Endif
	//
	If Li > 58
		//
		RodaFat()
		Cabecalho()
		//
	Endif
	//
	If Mv_Par08 == 1                       // Imprime Lotes (1=Sim, 2=Nao)
		//
		If !Empty(aDet[nD][9])
			//
			@ Li, 019 Psay Substr(aDet[nD][9],1,45)
			aadd(aItExcel , {' ',' ',Substr(aDet[nD][9],1,45),' '})
			Li += 1
			//
			If !Empty(Substr(aDet[nD][9], 46, 45))
				@ Li, 019 Psay Substr(aDet[nD][9], 46, 45)
				aadd(aItExcel , {' ',' ',Substr(aDet[nD][9],46,45),' '})
				Li += 1
			Endif
			//
			If Li > 58
				//
				RodaFat()
				Cabecalho()
				//
			Endif
			//
		Endif
		//
		If !Empty(aDet[nD][10])
			//
			@ Li, 019 Psay Substr(aDet[nD][10], 1, 45)
			aadd(aItExcel , {' ',' ',Substr(aDet[nD][10],1,45),' '})
			Li += 1
			//
			If !Empty(Substr(aDet[nD][10], 46, 45))
				@ Li, 019 Psay Substr(aDet[nD][10], 46, 45)
				aadd(aItExcel , {' ',' ',Substr(aDet[nD][10],46,45),' '})
				Li += 1
			Endif
			//
			If Li > 58
				//
				RodaFat()
				Cabecalho()
				//
			Endif
			//
		Endif
		//
		If !Empty(aDet[nD][11])
			//
			@ Li, 019 Psay Substr(aDet[nD][11], 1, 45)
			aadd(aItExcel , {' ',' ',Substr(aDet[nD][11],1,45),' '})
			Li += 1
			//
			If !Empty(Substr(aDet[nD][11], 46, 45))
				@ Li, 019 Psay Substr(aDet[nD][11], 46, 45)
				aadd(aItExcel , {' ',' ',Substr(aDet[nD][11],46,45),' '})
				Li += 1
			Endif
			//
			If Li > 58
				//
				RodaFat()
				Cabecalho()
				//
			Endif
			//
		Endif
		//
		If !Empty(aDet[nD][12])
			//
			@ Li, 019 Psay Substr(aDet[nD][12], 1, 45)
			aadd(aItExcel , {' ',' ',Substr(aDet[nD][12],1,45),' '})
			Li += 1
			//
			If !Empty(Substr(aDet[nD][12], 46, 45))
				@ Li, 019 Psay Substr(aDet[nD][12], 46, 45)
				aadd(aItExcel , {' ',' ',Substr(aDet[nD][12],46,45),' '})
				Li += 1
			Endif
			//
			If Li > 58
				//
				RodaFat()
				Cabecalho()
				//
			Endif
			//
		Endif
		//
	Endif
	//
	Li += 1
	//
Next

Return (.T.)

//////////////////////////
Static Function TotalFat()
//////////////////////////
//
@ Li, 000 Psay cTraco
Li += 2
//
@ Li, 019 Psay OemToansi("Total (" + cSimbX + ")")
@ Li, 066 Psay Transform(nTotal, "@E 999,999,999.99")

aadd(aItExcel , {' ',' ',' ',' '})
aadd(aItExcel , {' ',' ',"Total (" + cSimbX + ")",Transform(nTotal, "@E 999,999,999.99")})
aadd(aItExcel , {' ',' ',' ',' '})

Li += 2
//
If SC5->C5_MOEDA # 1                   // Se a Moeda Nao For a Corrente
	//
	If Mv_Par14 == 1                    // Portugues
		//
		@ Li, 002 Psay OemToansi("Obs.: Os valores em " + cPlurX +;
		" serão convertidos para " + cPlurP + " no dia anterior")
		Li += 1
		@ Li, 002 Psay OemToansi("      ao faturamento.")
		Li += 2
      	aadd(aItExcel , {"Obs.: Os valores em " + cPlurX +" serão convertidos para " + cPlurP + " no dia anterior ao faturamento.",' ',' ',' '})
		//
	Elseif Mv_Par14 == 2                // Ingles
		//
		@ Li, 002 Psay OemToansi("Obs.: The values in " + cPlurX +;
		" will be converted to " + cPlurP + " the day before ")
		Li += 1
		@ Li, 002 Psay OemToansi("      invoicing.")
		Li += 2
		aadd(aItExcel , {"Obs.: The values in " + cPlurX +" will be converted to " + cPlurP + " the day before invoicing.",' ',' ',' '})
		//
	Else                                // Espanhol
		//
		@ Li, 002 Psay OemToansi("Obs.: Os valores em " + cPlurX +;
		" serão convertidos para " + cPlurP + " no dia anterior")
		Li += 1
		@ Li, 002 Psay OemToansi("      ao faturamento.")
		Li += 2
		aadd(aItExcel , {"Obs.: Os valores em " + cPlurX +" serão convertidos para " + cPlurP + " no dia anterior ao faturamento.",' ',' ',' '})
		//
	Endif
	//
Endif
//
Return (.T.)

/////////////////////////
Static Function RodaFat()
/////////////////////////
//

If SM0->M0_CODIGO == "01"
	Rodape1 := "Eurofins do Brasil An. de Alimentos Ltda-Rod.Eng. Ermenio O. Penteado s/n Km 57,7"
	Rodape2 := "Bairro Tombadouro - Condominio Industriale - Indaiatuba/SP"
	Rodape3 := "CEP 13337-300 Tel:19 2107-5500 - www.eurofins.com.br"
Elseif SM0->M0_CODIGO == "02"
	Rodape1 := "Innolab do Brasil Ltda - Rua Sacadura Cabral, 236"
	Rodape2 := "Bairro Saude - Rio de Janeiro/RJ"
	Rodape3 := "CEP 20221-161 Tel:21 3509-1750 - www.innolab.com.br"
Elseif SM0->M0_CODIGO == "03"
	Rodape1 := "Eurofins Agroscience Services Ltda - Rod.Eng. Ermenio O. Penteado s/n Km 57,7"
	Rodape2 := "Bairro Tombadouro - Condominio Industriale - Indaiatuba/SP"
	Rodape3 := "CEP 13337-300 Tel:19 2107-5500 - www.eurofins.com.br"
Endif
//
Li := 60
//
If Mv_Par10 == 1                       // Imprime Rodape de Pagina (1=Sim, 2=Nao)
	//
	@ Li, 000 Psay cTraco
	Li += 1
	@ Li, 000 Psay Rodape1
	Li += 1
	@ Li, 000 Psay Rodape2
	Li += 1
	@ Li, 000 Psay Rodape3
	//
Else
	//
	@ Li, 000 Psay ""
	Li += 1
	@ Li, 000 Psay cTraco
	Li += 1
	@ Li, 000 Psay ""
	//
Endif
//
Return (.T.)

///////////////////////////
Static Function Perguntas()
///////////////////////////
//
Local sAlias := Alias()                // Variaveis Auxiliares
Local aRegs  := {}
//
SX1->(DbSetOrder(1))                   // Perguntas do Sistema
//
Aadd(aRegs,{cPerg,"01","Da Nota Fiscal Fatura        ?","","","mv_cha","C",09,0,0,"G","",;
"Mv_Par01","","","","      ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Ate a Nota Fiscal Fatura     ?","","","mv_chb","C",09,0,0,"G","",;
"Mv_Par02","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Da Serie da Nota Fiscal      ?","","","mv_chc","C",03,0,0,"G","",;
"Mv_Par03","","","","   ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Do Codigo do Cliente         ?","","","mv_chd","C",06,0,0,"G","",;
"Mv_Par04","","","","      ","","","","","","","","","","","","","","","","","","","","","SA1","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","Da Loja do Cliente           ?","","","mv_che","C",02,0,0,"G","",;
"Mv_Par05","","","","  ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"06","Ate o Codigo do Cliente      ?","","","mv_chf","C",06,0,0,"G","",;
"Mv_Par06","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"07","Ate a Loja do Cliente        ?","","","mv_chg","C",02,0,0,"G","",;
"Mv_Par07","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"08","Imprime Lotes do Pedido      ?","","","mv_chh","N",01,0,1,"C","",;
"Mv_Par08","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"09","Imprime Codigo da Amostra    ?","","","mv_chi","N",01,0,1,"C","",;
"Mv_Par09","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"10","Imprime Rodape de Pagina     ?","","","mv_chj","N",01,0,1,"C","",;
"Mv_Par10","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"11","Cliente para a Impressao     ?","","","mv_chl","N",01,0,1,"C","",;
"Mv_Par11","Faturamento","","","","","Entrega","","","","","Remetente","","","","","Resultado","","","","","Nenhum","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"12","Imprime Analise da Amostra   ?","","","mv_chm","N",01,0,1,"C","",;
"Mv_Par12","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"13","Numero Total de Paginas      ?","","","mv_chn","N",04,0,0,"G","",;
"Mv_Par13","","","","9999","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"14","Idioma para Impressao        ?","","","mv_cho","N",01,0,1,"C","",;
"Mv_Par14","Portugues","","","","","Ingles","","","","","Espanhol","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//
For i := 1 To Len(aRegs)               // Gravar as Perguntas
	//
	SX1->(DbSeek(cPerg + aRegs[i, 2]))
	//
	If SX1->(!Found())
		//
		DbSelectArea("SX1")
		If SX1->(Reclock("SX1", .T.))
			//
			For j := 1 To FCount()
				FieldPut(j, aRegs[i, j])
			Next
			//
			SX1->(MsUnlock())
			//
		Endif
		//
	Endif
	//
Next
//
For i := 1 To Len(aRegs)          // Regravar as Perguntas
	//
	SX1->(DbSeek(cPerg + aRegs[i, 2]))
	//
	If SX1->(Found())
		//
		DbSelectArea("SX1")
		If SX1->(Reclock("SX1", .F.))
			//
			If i == 1 .Or. i == 2
				SX1->X1_CNT01 := Space(Len(SF2->F2_DOC))
			Endif
			//
			If i == 3
				SX1->X1_CNT01 := Space(Len(SF2->F2_SERIE))
			Endif
			//
			If (i >= 4 .And. i <= 7) .Or. i == 13
				SX1->X1_CNT01 := SX1->X1_CNT01
			Endif
			//
			If i == 8 .Or. i == 9 .Or. i == 10 .Or. i == 11 .Or. i == 12 .Or. i == 14
				SX1->X1_PRESEL := SX1->X1_PRESEL
			Endif
			//
			SX1->(MsUnlock())
			//
		Endif
		//
	Endif
	//
Next
//
DbSelectArea(sAlias)
//
Return (.T.)
