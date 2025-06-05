#include "rwmake.ch"
/*/{protheus.doc}MATR700  
Relacao de Pedidos aptos a faturar.
@Author Alexandre Inacio Lemes 
@since 25/10/2002
@Obs Baseado no original de Claudinei M. Benzi  De  05/09/1991 
/*/
User Function PedApto2

LOCAL titulo 	  := OemToAnsi("Relacao de Pedidos de Vendas")
LOCAL cDesc1 	  := OemToAnsi("Este programa irá emitir a relação dos Pedidos de Vendas.")
LOCAL cDesc2 	  := OemToAnsi("Será feita a pesquisa no almoxarifado e verificado")
LOCAL cDesc3 	  := OemToAnsi("se a quantidade está disponível.")
LOCAL nomeprog   := "PEDAPTO2"
LOCAL wnrel  	  := "PEDAPTO2"
LOCAL cString 	  := "SC6"
Local cPerg      := PADR("PVAPT2",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}

PRIVATE aOrdem    := {OemToAnsi(" Por N§ Pedido "),OemToAnsi(" Por Produto "),OemToAnsi(" Por Data Entrega "),OemToAnsi(" Por Cliente ")} //,OemToAnsi(" Por Razao Social")} 
PRIVATE aReturn   := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}		               
PRIVATE tamanho	:= "G"
PRIVATE limite    := 220
PRIVATE li        := 80
PRIVATE m_pag     := 1
PRIVATE nLastKey  := 0
PRIVATE lEnd      := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Organiza o Grupo de Perguntas e Help ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHelpPor := {}
aAdd(aHelpPor,"Informe o número do pedido de venda")
aAdd(aHelpPor,"inicial a ser considerado na seleção. ")
Aadd(aPergs,{"Do Pedido","","","mv_ch1","C",6,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe o número do pedido de venda")
aAdd(aHelpPor,"final a ser considerado na seleção. ")
Aadd(aPergs,{"Ate o Pedido","","","mv_ch2","C",6,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})
                                                                     
aHelpPor := {}
aAdd(aHelpPor,"Informe o código do produto inicial a")
aAdd(aHelpPor,"ser considerado na seleção. ")
Aadd(aPergs,{"Do Produto","","","mv_ch3","C",15,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe o código do produto final a")
aAdd(aHelpPor,"ser considerado na seleção. ")
Aadd(aPergs,{"Ate o Produto","","","mv_ch4","C",15,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a máscara do produto.")
Aadd(aPergs,{"Mascara do Produto","","","mv_ch5","C",15,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a situação dos pedidos de venda")
aAdd(aHelpPor,"a ser considerado na seleção. ")
Aadd(aPergs,{"Imprime Ped. Venda","","","mv_ch6","N",01,0,1,"C","","MV_PAR06","Aptos a Faturar","","","","","Nao Aptos","","","","","Todos","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe se o IPI sera adicionado ao ")
aAdd(aHelpPor,"total do pedido.")
Aadd(aPergs,{"Somar IPI ao total","","","mv_ch7","N",01,0,1,"C","","MV_PAR07","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe qual moeda será considerada ")
aAdd(aHelpPor,"na emissáo do relatório.")
Aadd(aPergs,{"Qual Moeda","","","mv_ch8","N",01,0,1,"C","","MV_PAR08","Moeda 1","","","","","Moeda 2","","","","","Moeda 3","","","","","Moeda 4","","","","","Moeda 5","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a caracte´ristica do Tipo de")
aAdd(aHelpPor,"Entrada e Saída a ser considerada na")
aAdd(aHelpPor,"seleção.")
Aadd(aPergs,{"Quanto ao TES","","","mv_ch9","N",01,0,1,"C","","MV_PAR09","Gera Duplic.","","","","","Nao Gera Duplic.","","","","","Todos","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data inicial de entrega ")
aAdd(aHelpPor,"a ser considerada na seleção.")
Aadd(aPergs,{"Da Data de Entrega","","","mv_cha","D",08,0,1,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data final de entrega ")
aAdd(aHelpPor,"a ser considerada na seleção.")
Aadd(aPergs,{"Ate a Data de Entrega","","","mv_chb","D",08,0,1,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe em que tipo de data serão")
aAdd(aHelpPor,"considerados os valores dos pedidos")
aAdd(aHelpPor,"de venda.")
Aadd(aPergs,{"Converter Valores","","","mv_chc","N",01,0,1,"C","","MV_PAR12","Data de Emissao","","","","","Data Base","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe se a composição da coluna")
aAdd(aHelpPor,"impostos será somente IPI ou ")
aAdd(aHelpPor,"IPI+ICMS+ISS.")
Aadd(aPergs,{"Composicao/Coluna Impostos","","","mv_chd","N",01,0,1,"C","","MV_PAR13","IPI","","","","","IPI+ICMS+ISS","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe o código inicial do cliente")
aAdd(aHelpPor,"a ser considerado na seleção. ")
Aadd(aPergs,{"Do Cliente","","","mv_che","C",6,0,1,"G","","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a loja inicial do cliente")
aAdd(aHelpPor,"a ser considerada na seleção.")
Aadd(aPergs,{"Da loja","","","mv_chf","C",2,0,1,"G","","MV_PAR15","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe o código final do cliente")
aAdd(aHelpPor,"a ser considerado na seleção. ")
Aadd(aPergs,{"Ate o Cliente","","","mv_chg","C",6,0,1,"G","","MV_PAR16","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a loja final do cliente")
aAdd(aHelpPor,"a ser considerada na seleção.")
Aadd(aPergs,{"Ate a loja","","","mv_chh","C",2,0,1,"G","","MV_PAR17","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data inicial de emissão ")
aAdd(aHelpPor,"da Ordem de Produção.")
Aadd(aPergs,{"Da Data de Emissao","","","mv_chi","D",08,0,1,"G","","MV_PAR18","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data final de emissão ")
aAdd(aHelpPor,"da Ordem de Produção.")
Aadd(aPergs,{"Ate a Data de Emissao","","","mv_chj","D",08,0,1,"G","","MV_PAR19","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data inicial de liberação ")
aAdd(aHelpPor,"dos pedidos.")
Aadd(aPergs,{"Da Data de Liberacao","","","mv_chk","D",08,0,1,"G","","MV_PAR20","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data final de liberação ")
aAdd(aHelpPor,"dos pedidos.")
Aadd(aPergs,{"Ate a Data de Liberacao","","","mv_chl","D",08,0,1,"G","","MV_PAR21","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria, se necessario, o grupo de Perguntas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AjustaSx1(cPerg,aPergs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01         // Do Pedido                                ³
//³ mv_par02         // Ate o Pedido                             ³
//³ mv_par03         // Do Produto                               ³
//³ mv_par04 	     // Ate o Produto                             ³
//³ mv_par05 	     // Mascara                                   ³
//³ mv_par06 	     // Aptos a Faturar Nao Aptos Todos           ³
//³ mv_par07 	     // Soma Ipi ao Tot Sim Nao                   ³
//³ mv_par08 	     // Qual moeda                                ³
//³ mv_par09 	     // Quanto ao Tes- Gera Dupl, Nao Gera, Todos ³
//³ mv_par10         // Data de entrega de                       ³
//³ mv_par11         // Data de entrega Ate                      ³
//³ mv_par12         // Converter valores 1-emissao  2-Data Base ³
//³ mv_par13         // Coluna impostos 1-IPI/2-IPI/ICMS/ISS     ³
//³ mv_par14         // Do Cliente                               ³
//³ mv_par15         // Da Loja                                  ³
//³ mv_par16         // Ate o Cliente                            ³
//³ mv_par17         // Ate a Loja                               ³
//³ mv_par18         // Da data de emissao da OP                 ³
//³ mv_par19         // Ate a data de emissao da OP              ³
//³ mv_par20         // Da data de liberacao do pedido           ³
//³ mv_par21         // Ate a data de liberacao do pedido        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IW_MsgBox(OemtoAnsi("Para considerar os pedidos liberados de uma determinada data, preencha os dois últimos parâmetros. Caso contrário, deixe-os em branco."),;
                    OemtoAnsi("Informação") , "INFO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrdem,,Tamanho)

If ( nLastKey == 27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
EndIf

SetDefault(aReturn,cString)

If ( nLastKey == 27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
EndIf

RptStatus({|lEnd| C700Imp(@lEnd,wnRel,cString,aReturn,aOrdem,tamanho,limite,titulo,cDesc1,cDesc2,cDesc3)},Titulo)

Return(.T.)

/*/						
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C700IMP  ³ Autor ³ Alexandre Inacio Lemes³ Data ³25/10/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR700			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C700Imp(lEnd,WnRel,cString,aReturn,aOrdem,tamanho,limite,titulo,cDesc1,cDesc2,cDesc3)

LOCAL nomeprog   := "PEDAPTO2"
LOCAL cabec1 	 := "IT CODIGO PRODUTO  DESCRICAO DO PRODUTO            ESTOQUE      -----------  PEDIDO  -------------      QTD.       QTD.       VALOR DO    PRECO UNIT.       SITUACAO DA        IMPOSTOS     VALOR A   DATA     TES NUM.PED" 
LOCAL cabec2 	 := "                                                  DISPONIVEL    VENDIDO     ATENDIDO      SALDO       LIBERADA   BLOQUEADA    DESCONTO      LIQUIDO      ORDEM DE PRODUCAO                  FATURAR  ENTREGA       CLIENTE"
LOCAL cbtxt      := SPACE(10)
LOCAL cAliasSC5  := "SC5"
LOCAL cAliasSC6  := "SC6" 
LOCAL cAliasSC9  := "SC9" 
LOCAL cAliasSF4  := "SF4"
LOCAL cTrab		 := ""
LOCAL cDescOrdem := ""
LOCAL cTipo  	 := ""
LOCAL cQuery     := ""
LOCAL cQryAd     := ""
LOCAL cName      := ""
LOCAL cPedido    := ""
LOCAL cFilter    := ""
LOCAL cIndexSC5  := "" 
LOCAL cIndexSC6  := ""
LOCAL cIndexSC9  := ""
LOCAL cKey 	     := ""
LOCAL cCampo     := ""
LOCAL cVends     := ""
LOCAL cDescTab   := ""
LOCAL cNumero    := ""
LOCAL cItem      := "" 
LOCAL cProduto   := "" 
LOCAL cDescricao := "" 
LOCAL cLocal     := ""
LOCAL cOp        := ""
LOCAL cTes       := ""
LOCAL dEntreg    := dDataBase 
LOCAL dC5Emissao := dDataBase
LOCAL nTipo		 := GetMv("MV_COMP")
LOCAL nOrdem 	 := aReturn[8]
LOCAL nX	 	 := 1
LOCAL CbCont 	 := 0
LOCAL nAcTotFat	 := 0
LOCAL nTotFat 	 := 0
LOCAL nAcdescont := 0
LOCAL nTotDesc	 := 0
LOCAL nTotImp	 := 0
LOCAL nTotImpPar:= 0
LOCAL nQtLib 	 := 0
LOCAL nQtBloq	 := 0
LOCAL nTQtde 	 := 0
LOCAL nTPed  	 := 0
LOCAL nTQLib 	 := 0
LOCAL nTQBLoq	 := 0
LOCAL nTQEnt 	 := 0
LOCAL nSC5       := 0
LOCAL nSC6       := 0 
LOCAL nSC9		  := 0
LOCAL nTotLocal  := 0
LOCAL nValdesc   := 0
LOCAL nTFat      := 0
LOCAL nImpLinha  := 0
LOCAL nItem      := 0    
LOCAL nC5Moeda   := 0    
LOCAL nPos       := 0
LOCAL nQtdven    := 0
LOCAL nQtdent    := 0
LOCAL nPrunit    := 0
LOCAL nValor     := 0
LOCAL nValEnt    := 0
LOCAL nPrcven    := 0
LOCAL nVldesc    := 0
LOCAL nValIPI    := 0 
LOCAL aQuant 	  := {}
LOCAL aCampos	  := {}
LOCAL aTam   	  := {}
LOCAL aStruSC5   := {}
LOCAL aStruSC6   := {} 
LOCAL aStruSC9   := {}
LOCAL aStruSF4   := {}
LOCAL aImpostos  := MaFisRelImp("MTR700",{"SC5","SC6"})
LOCAL lContInt   := .T. 
LOCAL lFiltro	  := .T.
LOCAL lCabPed    := .T.
LOCAL lQuery     := .F.
LOCAL lBarra     := .F.
LOCAL lImp 		  := .F.
LOCAL cQueryAdd  := ""
Local aItExcel := {}
Local aCabExcel := {'Num.Pedido','Cod.Cliente','Loja Cliente','Nome Cliente','Data Emissao','Moeda','Num.Pedido Cliente','Total do Pedido','E-Mail Solicitante','Observações','Condicao Pagto'}

/*
IT CODIGO PRODUTO  DESCRICAO DO PRODUTO            ESTOQUE      -----------  PEDIDO  -------------      QTD.       QTD.       VALOR DO    PRECO UNIT.       SITUACAO DA        IMPOSTOS     VALOR A   DATA     TES NUM.PED" 
                                                  DISPONIVEL    VENDIDO     ATENDIDO      SALDO       LIBERADA   BLOQUEADA    DESCONTO      LIQUIDO      ORDEM DE PRODUCAO                  FATURAR  ENTREGA       CLIENTE"
XX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXX 999999999999999 99999999999 99999999999 99999999999 99999999999 99999999999 99999999999    99999999999 XXXXXXXXXXXXXXXXXXXXXXXX 99999,99 9999.999,99 99/99/9999 999 999999999*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array com base no SB2 e Monta arquivo de trabalho     ³
//³ para baixar estoque na listagem.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("B2_LOCAL")
AADD(aCampos,{ "TB_LOCAL" ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B2_COD")
AADD(aCampos,{ "TB_COD"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B2_QATU")
AADD(aCampos,{ "TB_SALDO" ,"N",aTam[1],aTam[2] } )

cTrab:= CriaTrab(aCampos)

USE &cTrab ALIAS STR NEW
IndRegua("STR",cTrab,"TB_LOCAL+TB_COD",,,"Selecionando Registros...")
dbSelectArea("SC6")
dbSetOrder(nOrdem) 

cQueryAdd := ""
#IfDEF TOP
	If TcSrvType() <> "AS/400"
		
		lQuery    := .T.
		cAliasSC5 := "QRYSC6"
		cAliasSC6 := "QRYSC6"
		cAliasSC9 := "QRYSC6"
		cAliasSF4 := "QRYSC6"
		
		aStruSC5  := SC5->(dbStruct())
		aStruSC6  := SC6->(dbStruct())
		aStruSC9  := SC9->(dbStruct())
		aStruSF4  := SF4->(dbStruct())

		cQuery := "SELECT "
		cQuery += "SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_EMISSAO,"
		cQuery += "SC5.C5_CONDPAG,SC5.C5_MOEDA,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,SC5.C5_ZZNFMAI,"
		cQuery += "SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_OP,SC6.C6_TES,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,"
		cQuery += "SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_PRCVEN,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_LOCAL,SC6.C6_QTDENT,SC6.C6_BLQ,SC5.C5_ZZLLAUD,SC6.C6_PEDCLI,SC6.C6_NUMOP,SC6.C6_ITEMOP,SC5.C5_ZZOBS,"

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Esta rotina foi escrita para adicionar no select os campos do SC6  ³
        //³usados no filtro do usuario quando houver, a rotina acrecenta      ³
        //³somente os campos que forem adicionados ao filtro testando         ³
        //³se os mesmo já existem no select ou se forem definidos novamente   ³
        //³pelo o usuario no filtro.                                          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	
        If !Empty(aReturn[7])
		   For nX := 1 To SC6->(FCount())
		 	  cName := SC6->(FieldName(nX))
		 	  If AllTrim( cName ) $ aReturn[7]
	      		  If aStruSC6[nX,2] <> "M"  
	      		    If !cName $ cQuery .And. !cName $ cQryAd
		        	  cQryAd += cName +","
		            EndIf 	
		       	  EndIf
			  EndIf 			       	
		   Next nX
        EndIf    
     
        cQuery += cQryAd		

		cQuery += "SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_NFISCAL,SC9.C9_BLEST,SC9.C9_BLCRED,SC9.C9_PRODUTO,"
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³o Campo C9_QTDLIB e somado por haver varios C9 para cada C6.       ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	
		cQuery += "SUM(SC9.C9_QTDLIB) C9_QTDLIB,"
		cQuery += "SF4.F4_FILIAL,SF4.F4_DUPLIC,SF4.F4_CODIGO "
		cQuery += "FROM "
		cQuery += RetSqlName("SC5")+" SC5 ,"+RetSqlName("SC6")+" SC6 ,"+RetSqlName("SC9")+" SC9 ,"+RetSqlName("SF4")+" SF4 "
		cQuery += "WHERE "
		cQuery += "SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_NUM >= '"+mv_par01+"' AND SC5.C5_NUM <= '"+mv_par02+"' AND "
		cQuery += "SC5.C5_CLIENTE >= '"+mv_par14+"' AND SC5.C5_LOJACLI >= '"+mv_par15+"' AND "
		cQuery += "SC5.C5_CLIENTE <= '"+mv_par16+"' AND SC5.C5_LOJACLI <= '"+mv_par17+"' AND "
		cQuery += "SC5.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' AND SC6.C6_NUM   = SC5.C5_NUM AND "
		cQuery += "SC5.C5_EMISSAO >= '" + Dtos(mv_par18) + "' AND "
		cQuery += "SC5.C5_EMISSAO <= '" + Dtos(mv_par19) + "' AND "
		cQuery += "SC6.C6_PRODUTO >= '" + mv_par03       + "' AND "
		cQuery += "SC6.C6_PRODUTO <= '" + mv_par04       + "' AND "
		cQuery += "SC6.C6_ENTREG  >= '" + dtos(mv_par10) + "' AND "
		cQuery += "SC6.C6_ENTREG  <= '" + dtos(mv_par11) + "' AND "
		If !Empty(mv_par20) .and. !Empty(mv_par21)
			cQuery += "SC9.C9_DATALIB >= '" + dtos(mv_par20) + "' AND "
			cQuery += "SC9.C9_DATALIB <= '" + dtos(mv_par21) + "' AND "		
		Endif
		cQuery += "SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND SC6.C6_BLQ<>'R ' AND SC6.D_E_L_E_T_ = ' ' AND "
		cQuery += "SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC6.C6_ITEM = SC9.C9_ITEM AND "
		cQuery += "SC6.C6_PRODUTO = SC9.C9_PRODUTO AND SC9.C9_NFISCAL = '" + space(TamSx3("C9_NFISCAL")[1]) + "' AND "
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Trata o Relacionamento com C9 conforme a opcao do MV_PAR06 -> "IMPRIMIR PEDIDOS ?" ³
        //³ "IMPRIMIR PEDIDOS ?"                                                               ³
        //³ MV_PAR06 == 1 -> Pedidos Aptos a Faturar com C9 liberado.                          ³
        //³ MV_PAR06 == 2 -> Pedidos Nao Aptos a Faturar com C9 bloqueado no Credito ou Estoque³
        //³ MV_PAR06 == 3 -> Todos - pedidos liberados e bloqueados do C9 + os C6 sem os C9    ³
        //³ para MV_PAR06 == 3 o relacionamento com C9 na Query e feito atraves de UNION.      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	
		If mv_par06 == 1
			cQuery += "SC9.C9_BLEST = '" + space(TamSx3("C9_BLEST")[1]) + "' AND "
			cQuery += "SC9.C9_BLCRED = '" + space(TamSx3("C9_BLCRED")[1]) + "' AND "
			cQuery += "SC9.C9_QTDLIB > 0 AND "
		ElseIf mv_par06 == 2
			cQuery += "(SC9.C9_BLEST <> '" + space(TamSx3("C9_BLEST")[1]) + "' OR "
			cQuery += "SC9.C9_BLCRED <> '" + space(TamSx3("C9_BLCRED")[1]) + "') AND "
		EndIf
		cQuery += "SC9.D_E_L_E_T_ = ' ' "
		
		cQuery += " AND SF4.F4_FILIAL = '"+xFilial("SF4")+"'"
		cQuery += " AND SC6.C6_TES = SF4.F4_CODIGO AND "
		If mv_par09 == 1
			cQuery += "SF4.F4_DUPLIC = 'S' AND "
		ElseIf mv_par09 == 2
			cQuery += "SF4.F4_DUPLIC <> 'S' AND "
		EndIf
		cQuery += "SF4.D_E_L_E_T_ = ' ' "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para tratamento do filtro do usuario.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("F700QRY")
			cQueryAdd := ExecBlock("F700QRY", .F., .F., {aReturn[7]})
			If ValType(cQueryAdd) == "C"
				cQuery += " AND ( " + cQueryAdd + ")"
			EndIf
		EndIf

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Agrupamento de todos os campos comuns do SELECT para que nos relacionamentos com     ³
        //³ C5,C6 e C9 com varios C9 para cada C6 gerem apenas um registro com o campo C9_QTDLIB ³
        //³ somado.                                                                              ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   			
	    cQuery += "GROUP BY "
		cQuery += "SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_EMISSAO,"
		cQuery += "SC5.C5_CONDPAG,SC5.C5_MOEDA,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,SC5.C5_ZZNFMAI,"
		cQuery += "SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_OP,SC6.C6_TES,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,"
		cQuery += "SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_PRCVEN,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_LOCAL,SC6.C6_QTDENT,SC6.C6_BLQ,SC5.C5_ZZLLAUD,SC6.C6_PEDCLI,SC6.C6_NUMOP,SC6.C6_ITEMOP,SC5.C5_ZZOBS,"
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Adiciona os campos fornecidos pelo filtro do usuario.             ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	
        cQuery += cQryAd		
		cQuery += "SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_NFISCAL,SC9.C9_BLEST,SC9.C9_BLCRED,SC9.C9_PRODUTO,"
		cQuery += "SF4.F4_FILIAL,SF4.F4_DUPLIC,SF4.F4_CODIGO "
		
		If mv_par06 == 3
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Quando o MV_PAR06 ==3 ->"TODOS OS PEDIDOS" esse UNION acrescenta a Query os registros³
            //³ do C6 que nao possuem C9.                                                            ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ATENCAO !!!! ao manipular os campos do SELECT ou a ordem da Clausula ORDER BY verificar   ³
			//³ a concordancia entre os mesmos !!!!!!!!!                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			cQuery += "UNION "
			cQuery += "SELECT "
			cQuery += "SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_EMISSAO,"
			cQuery += "SC5.C5_CONDPAG,SC5.C5_MOEDA,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,SC5.C5_ZZNFMAI,"
			cQuery += "SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_OP,SC6.C6_TES,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,"
			cQuery += "SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_PRCVEN,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_LOCAL,SC6.C6_QTDENT,SC6.C6_BLQ,SC5.C5_ZZLLAUD,SC6.C6_PEDCLI,SC6.C6_NUMOP,SC6.C6_ITEMOP,SC5.C5_ZZOBS,"
            cQuery += cQryAd		
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Para o uso de UNION a estrutura deste SELECT deve ser igual a do SELECT anterior     ³
            //³ note que a nomeclatura do C9 usa os mesmos nomes dos campos da TABELA, porem com o   ³
            //³ uso de ' ' para nao fazer referencia a ela.                                          ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   			
			cQuery += "' ' C9_FILIAL,' ' C9_PEDIDO,' ' C9_ITEM,' ' C9_NFISCAL,' ' C9_BLEST,' ' C9_BLCRED,' ' C9_PRODUTO, 0 C9_QTDLIB,"
			cQuery += "SF4.F4_FILIAL,SF4.F4_DUPLIC,SF4.F4_CODIGO "
			cQuery += "FROM "
			cQuery += RetSqlName("SC5")+" SC5 ,"+RetSqlName("SC6")+" SC6 ,"+RetSqlName("SF4")+" SF4 "
			cQuery += "WHERE "
			cQuery += "SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_NUM >= '"+mv_par01+"' AND SC5.C5_NUM <= '"+mv_par02+"' AND "
			cQuery += "SC5.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' AND SC6.C6_NUM   = SC5.C5_NUM AND "
			cQuery += "SC5.C5_CLIENTE >= '"+mv_par14+"' AND SC5.C5_LOJACLI >= '"+mv_par15+"' AND "
			cQuery += "SC5.C5_CLIENTE <= '"+mv_par16+"' AND SC5.C5_LOJACLI <= '"+mv_par17+"' AND "
			cQuery += "SC5.C5_EMISSAO >= '" + Dtos(mv_par18) + "' AND "
			cQuery += "SC5.C5_EMISSAO <= '" + Dtos(mv_par19) + "' AND "
			cQuery += "SC6.C6_PRODUTO >= '" + mv_par03       + "' AND "
			cQuery += "SC6.C6_PRODUTO <= '" + mv_par04       + "' AND "
			cQuery += "SC6.C6_ENTREG  >= '" + dtos(mv_par10) + "' AND "
			cQuery += "SC6.C6_ENTREG  <= '" + dtos(mv_par11) + "' AND "
			cQuery += "SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND SC6.C6_BLQ<>'R ' AND SC6.D_E_L_E_T_ = ' ' AND "
			cQuery += "SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SC6.C6_TES = SF4.F4_CODIGO AND "
			cQuery += "NOT EXISTS (SELECT SC9.C9_PEDIDO FROM "+RetSqlName("SC9")+" SC9 " 
			cQuery += "WHERE "
		    cQuery += "SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC6.C6_ITEM = SC9.C9_ITEM AND "
		    cQuery += "SC9.C9_NFISCAL = '"+Space(Len(SC9->C9_NFISCAL))+"' AND "		    
		    cQuery += "SC6.C6_PRODUTO = SC9.C9_PRODUTO AND SC9.D_E_L_E_T_ = ' ') AND "
			If mv_par09 == 1
				cQuery += "SF4.F4_DUPLIC = 'S' AND "
			ElseIf mv_par09 == 2
				cQuery += "SF4.F4_DUPLIC <> 'S' AND "
			EndIf
			cQuery += "SF4.D_E_L_E_T_ = ' ' "
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento do filtro do usuario.                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType(cQueryAdd) == "C" .And. !Empty(cQueryAdd)
				cQuery += " AND ( " + cQueryAdd + ")"
			EndIf
			
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ATENCAO !!!! ao manipular os campos do SELECT ou a ordem da Clausula ORDER BY verificar   ³
		//³ a concordancia entre os mesmos !!!!!!!!!                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOrdem = 1
			cDescOrdem:= "PEDIDO"
			cQuery += "ORDER BY 2"
		ElseIf nOrdem = 2
			cDescOrdem:= "PRODUTO"
			cQuery += "ORDER BY 18"
		ElseIf nOrdem = 3
			cDescOrdem:= "DATA DE ENTREGA"+"PEDIDO"
			cQuery += "ORDER BY 30,2"
		ElseIf nOrdem = 4
			cDescOrdem:= "CLIENTE"+"PEDIDO"
			cQuery += "ORDER BY 3,4,2"
		EndIf
		
		cQuery := ChangeQuery(cQuery)
				
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC5,.T.,.T.)
		
		For nSC5 := 1 To Len(aStruSC5)
			If aStruSC5[nSC5][2] <> "C" .and.  FieldPos(aStruSC5[nSC5][1]) > 0
				TcSetField(cAliasSC5,aStruSC5[nSC5][1],aStruSC5[nSC5][2],aStruSC5[nSC5][3],aStruSC5[nSC5][4])
			EndIf
		Next nSC5

		For nSC6 := 1 To Len(aStruSC6)
			If aStruSC6[nSC6][2] <> "C" .and. FieldPos(aStruSC6[nSC6][1]) > 0
				TcSetField(cAliasSC6,aStruSC6[nSC6][1],aStruSC6[nSC6][2],aStruSC6[nSC6][3],aStruSC6[nSC6][4])
			EndIf
		Next nSC6

        For nSC9 := 1 To Len(aStruSC9)
            If aStruSC9[nSC9][2] <> "C" .and. FieldPos(aStruSC9[nSC9][1]) > 0
					TcSetField(cAliasSC9,aStruSC9[nSC9][1],aStruSC9[nSC9][2],aStruSC9[nSC9][3],aStruSC9[nSC9][4])
            EndIf
        Next nSC9
	Else
#EndIf 
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Definicao dos filtros dos arquivos C6 e C9 para codbase.    ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   			
		dbSelectArea(cAliasSC9)
		cIndexSC9  := CriaTrab(NIL,.F.)
		cKey := IndexKey()		                         
		cFilter := "C9_FILIAL == '"+xFilial("SC9")+"' .And. "
		cFilter += "C9_NFISCAL = '" + space(TamSx3("C9_NFISCAL")[1]) + "' .AND. "
		cFilter += "C9_CLIENTE >= '"+mv_par14+"' .and. C9_LOJA >= '"+mv_par15+"' .and. "
		cFilter += "C9_CLIENTE <= '"+mv_par16+"' .and. C9_LOJA <= '"+mv_par17+"' "
		If mv_par06 <> 3
			If mv_par06 == 1
				cFilter += " .And. C9_BLEST = '" + space(TamSx3("C9_BLEST")[1]) + "' .And. "		 	
				cFilter += "C9_BLCRED = '" + space(TamSx3("C9_BLCRED")[1]) + "' .And. "		 	 				
				cFilter += "C9_QTDLIB > 0"		 	 				
			Else
				cFilter += " .And. (C9_BLEST <> '" + space(TamSx3("C9_BLEST")[1]) + "' .Or. "		 	
     			cFilter += "C9_BLCRED <> '" + space(TamSx3("C9_BLCRED")[1]) + "')"		 	 								
			EndIf	
		EndIf	
		IndRegua(cAliasSC9,cIndexSC9,cKey,,cFilter,"Selecionando Registros...")
		#IfNDEF TOP
			DbSetIndex(cIndexSC9+OrdBagExt())
		#EndIf 
		
		cFilter:="" 
		cAliasSC6 := cString
		dbSelectArea(cAliasSC6)
		cIndexSC6  := CriaTrab(NIL,.F.) 
		cFilter := If( Empty(dbFilter()),"","("+dbFilter()+") .And. " )
		cFilter += 'C6_FILIAL == "'+xFilial("SC6")+'" .And. '
		cFilter += '(C6_NUM >= "'+mv_par01+'" .And. C6_NUM <= "'+mv_par02+'") .And. '
		cFilter += '(C6_PRODUTO >= "'+mv_par03+'" .And. C6_PRODUTO <= "'+mv_par04+'") .And. '
		cFilter += 'Dtos(C6_ENTREG) >= "'+Dtos(mv_par10)+'" .And. '
		cFilter += 'Dtos(C6_ENTREG) <= "'+Dtos(mv_par11)+'" .And. '
		cFilter += 'C6_QTDVEN-C6_QTDENT > 0 .And. ' 
		cFilter += 'Alltrim(C6_BLQ) <> "R"'
		If nOrdem = 1
			cDescOrdem:= "PEDIDO"
			cKey :="C6_FILIAL+C6_NUM"   
		ElseIf nOrdem = 2
			cDescOrdem:= "PRODUTO"
			cKey :="C6_FILIAL+C6_PRODUTO"
		ELSEIf nOrdem = 3
			cDescOrdem:= "DATA DE ENTREGA"
			cKey :="C6_FILIAL+DTOS(SC6->C6_ENTREG)"
		ELSEIf nOrdem = 4
			cDescOrdem:= "CLIENTE"
			cKey :="C6_FILIAL+C6_CLI+C6_LOJA+C6_NUM"
		EndIf
		IndRegua(cAliasSC6,cIndexSC6,cKey,,cFilter,"Selecionando Registros...")
		#IfNDEF TOP
			DbSetIndex(cIndexSC6+OrdBagExt())
		#EndIf                           
		DbGoTop()
		
#IfDEF TOP
	EndIf
#EndIf	

If MV_PAR06 == 1
	cTipo := " APTOS A FATURAR "
ELSEIf MV_PAR06 == 2
	cTipo := " NAO LIBERADOS   "
ELSE
	cTipo := ""
EndIf
titulo += cTipo +  " - ORDEM DE " + cDescOrdem + " - " + GetMv("MV_MOEDA"+STR(mv_par08,1))	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Area do While e retorna o total Elementos da regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectArea(cAliasSC6)
SetRegua(SC6->(RecCount()))

While !( cAliasSC6 )->( Eof() ) .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se cancelado pelo usuario                        	       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEnd
		@ PROW()+1,001 Psay "CANCELADO PELO OPERADOR"
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a validacao dos filtros do usuario e Parametros  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAliasSC6 ) 
	lFiltro := IIf((!Empty(aReturn[7]).And.!&(aReturn[7])) .Or. !(ValidMasc((cAliasSC6)->C6_PRODUTO,MV_PAR05)),.F.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se ser  considerado pelo TES qto gerac. duplic. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery .And. mv_par09 <> 3
		dbSelectArea((cAliasSF4))
		dbSetOrder(1)
		msSeek(xFilial()+(cAliasSC6)->C6_TES)
		If ( (cAliasSF4)->F4_DUPLIC == "S" .And. mv_par09 == 2 ) .Or. ( (cAliasSF4)->F4_DUPLIC != "S" .And. mv_par09 == 1 )
			lFiltro := .F.
		EndIf
	EndIf 
    
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tiver O.P e se ela estiver fora da faixa de data de   ³
	//³ datas de emissao (parametros mv_par18 e mv_par19), des-  ³
	//³ preza registro.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty((cAliasSC6)->C6_NUMOP)
		dbSelectArea("SC2")
		dbSetOrder(1)
		If dbSeek(xFilial("SC2")+(cAliasSC6)->C6_NUMOP+(cAliasSC6)->C6_ITEMOP,.T.)
			/
			If Dtos(C2_EMISSAO) < Dtos(mv_par18) 
	      		lFiltro := .F.
	  		Endif
			If Dtos(C2_EMISSAO) > Dtos(mv_par19)
	      		lFiltro := .F.
	  		Endif
	  		/
	  	Else
	  		lFiltro := .F.
	  	Endif
	Else
  		lFiltro := .F.
  	Endif		
  	*/
	
	If lFiltro
		
		dbSelectArea(cAliasSC6)
		
		cNumero    := (cAliasSC6)->C6_NUM
		cItem      := (cAliasSC6)->C6_ITEM
		cProduto   := (cAliasSC6)->C6_PRODUTO
		cDescricao := (cAliasSC6)->C6_DESCRI
		cLocal     := (cAliasSC6)->C6_LOCAL
		cOp        := (cAliasSC6)->C6_OP
		cTes       := (cAliasSC6)->C6_TES
		cPedCli    := (cAliasSC6)->C6_PEDCLI
		nQtdven    := (cAliasSC6)->C6_QTDVEN
		nQtdent    := (cAliasSC6)->C6_QTDENT
		nPrunit    := (cAliasSC6)->C6_PRUNIT
		nValor     := (cAliasSC6)->C6_VALOR
		nPrcven    := (cAliasSC6)->C6_PRCVEN
		nVldesc    := (cAliasSC6)->C6_VALDESC
		dEntreg    := (cAliasSC6)->C6_ENTREG
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfica se o pedido de venda esta apto a faturar(nQtLib!=0) ³
		//³ ou com bloqueio(nQtBloq!=0) , conforme o parametro mv_par06  ³
		//³ seleciona os reguistros a serem impressos.                   ³
		//³ Elementos do Array aQuant :                                  ³
		//³ 1. Produto                                                   ³
		//³ 2. Quantidade Liberada                                       ³
		//³ 3. Quantidade Bloqueada                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aQuant 	 := {}
		
		If !lQuery
			dbSelectArea(cAliasSC9)
			msSeek(xFilial("SC9")+(cAliasSC6)->C6_NUM+(cAliasSC6)->C6_ITEM,.F.)			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Quando nao for Query apos posicionar o C9 gira os registros do C9 enquanto o produto ³
			//³ for o mesmo dentro do pedido, essa rotina preve varias liberacoes do C9 para cada C6.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While (cAliasSC9)->C9_FILIAL == xFilial("SC9") .And. (cAliasSC9)->C9_PEDIDO == (cAliasSC6)->C6_NUM .And. ;
				(cAliasSC9)->C9_ITEM == (cAliasSC6)->C6_ITEM .And. (cAliasSC9)->C9_PRODUTO == (cAliasSC6)->C6_PRODUTO
				
				nPos := Ascan(aQuant, {|x|x[1]== (cAliasSC9)->C9_PRODUTO})
				
				If (cAliasSC9)->C9_BLEST == space(TamSx3("C9_BLEST")[1]).And.(cAliasSC9)->C9_BLCRED == space(TamSx3("C9_BLCRED")[1]).And.(cAliasSC9)->C9_QTDLIB > 0
					If mv_par06 <> 2
						If nPos != 0
							aQuant[nPos,2]+= (cAliasSC9)->C9_QTDLIB
						Else
							Aadd(aQuant,{(cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_QTDLIB,0})
						EndIf
					EndIf
				ElseIf (cAliasSC9)->C9_BLEST <> space(TamSx3("C9_BLEST")[1]).Or.(cAliasSC9)->C9_BLCRED <> space(TamSx3("C9_BLCRED")[1])
					If mv_par06 <> 1
						If nPos != 0
							aQuant[nPos,3]+= (cAliasSC9)->C9_QTDLIB
						Else
							Aadd(aQuant,{(cAliasSC9)->C9_PRODUTO,0,(cAliasSC9)->C9_QTDLIB})
						EndIf
					EndIf
				EndIf
				
				dbSelectArea(cAliasSC9)
				dbSkip()
				
			EndDo
		Else
			nPos := Ascan(aQuant, {|x|x[1]== (cAliasSC9)->C9_PRODUTO})
			If (cAliasSC9)->C9_BLEST == space(TamSx3("C9_BLEST")[1]).And.(cAliasSC9)->C9_BLCRED == space(TamSx3("C9_BLCRED")[1]).And.(cAliasSC9)->C9_QTDLIB > 0
				If mv_par06 <> 2
					If nPos != 0
						aQuant[nPos,2]+= (cAliasSC9)->C9_QTDLIB
					Else
						Aadd(aQuant,{(cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_QTDLIB,0})
					EndIf
				EndIf
			ElseIf (cAliasSC9)->C9_BLEST <> space(TamSx3("C9_BLEST")[1]).Or.(cAliasSC9)->C9_BLCRED <> space(TamSx3("C9_BLCRED")[1])
				If mv_par06 <> 1
					If nPos != 0
						aQuant[nPos,3]+= (cAliasSC9)->C9_QTDLIB
					Else
						Aadd(aQuant,{(cAliasSC9)->C9_PRODUTO,0,(cAliasSC9)->C9_QTDLIB})
					EndIf
				EndIf
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Varre o Array aQuant e alimenta as variaveis nQtdLib e nQtBloq com o conteudo.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aQuant)
			If mv_par06 == 2 .And. aQuant[1,2] > 0 .Or. mv_par06 == 1 .And. aQuant[1,3] > 0
				lContInt := .F.
			Else
				nQtlib += aQuant[nX,2]
				nQtBloq+= aQuant[nX,3]
			EndIf
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o cabecalho do pedido no relatorio.                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lCabPed .And. lContInt .And. Len(aQuant)>0 .And. mv_par06 <> 3) .Or. (lCabPed .And. lContInt .And. mv_par06 == 3)
			
			If li > 58
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			EndIf
			
			dbSelectArea(cAliasSC5)
			
			If !lQuery
				SC5->( dbSetOrder( 1 ) ) 
				MsSeek(xFilial("SC5")+(cAliasSC6)->C6_NUM)
			EndIf
			
			MaFisIni((cAliasSC5)->C5_CLIENTE,(cAliasSC5)->C5_LOJACLI,"C",(cAliasSC5)->C5_TIPO,(cAliasSC5)->C5_TIPOCLI,aImpostos,,,"SB1","MTR700")
			
			For nX:= 1 TO 5
				cCampo := "C5_VEND"+STR(nX,1)
				cCampo := (cAliasSC5)->(FieldGet(FieldPos(cCampo)))
				If !Empty(cCampo)
					cVends += If(lBarra,"/","") + cCampo
					lBarra :=.T.
				EndIf
			Next nX
			
			@li,  0 Psay "PEDIDO : " + (cAliasSC5)->C5_NUM		
			
			cUF := ""
			If (cAliasSC5)->C5_TIPO $ "BD"
				dbSelectArea("SA2")
				dbSetOrder(1)
				If msSeek( xFilial()+(cAliasSC6)->C6_CLI+(cAliasSC6)->C6_LOJA )
					@li, PCol()+2 Psay "FORNECEDOR : " + SA2->A2_COD+' - '+ Subs(SA2->A2_NOME,1,40)	
					cUF := SA2->A2_EST
					cObs := ""
					cNomeCF := SA2->A2_NOME
				EndIf
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				If msSeek( xFilial()+(cAliasSC6)->C6_CLI+(cAliasSC6)->C6_LOJA )
					@li, PCol()+2 Psay "CLIENTE : " + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40)		
					cUF := SA1->A1_EST
					cObs := Alltrim(SA1->A1_OBSERV)			
					cNomeCF := SA1->A1_NOME	
				EndIf
			EndIf
			
			@li, PCol()+2 Psay "LOJA: " + (cAliasSC5)->C5_LOJACLI
			@li, PCol()+2 Psay "EMISSAO: " + DTOC((cAliasSC5)->C5_EMISSAO)
			@li, PCol()+2 Psay "TRANSPORTADORA: " + (cAliasSC5)->C5_TRANSP
			@li, PCol()+2 Psay "VENDEDOR(ES): " + cVends
			@li, PCol()+2 Psay "COND.PGTO: " + (cAliasSC5)->C5_CONDPAG
			@li, PCol()+2 Psay "ESTADO: " + cUF
			@li, PCol()+2 Psay "LOJA LAUDO: " + (cAliasSC5)->C5_ZZLLAUD
			@li, PCol()+2 Psay "MOEDA PEDIDO: "+Str((cAliasSC5)->C5_MOEDA,1)

			If !Empty(cObs)
				li++
				@li,0 PSAY "OBSERVACOES: "+cObs
			Endif
			li+=2
			
			cPedido     := (cAliasSC6)->C6_NUM
			nC5Moeda    := (cAliasSC5)->C5_MOEDA
			dC5Emissao  := (cAliasSC5)->C5_EMISSAO
			lCabPed     := .F.
			
			cInfo1 := (cAliasSC5)->C5_NUM
			cInfo2 := (cAliasSC6)->C6_CLI
			cInfo3 := (cAliasSC6)->C6_LOJA
			cInfo4 := cNomeCF
			cInfo5 := DTOC((cAliasSC5)->C5_EMISSAO)
			cInfo6 := Str((cAliasSC5)->C5_MOEDA,1)
			cInfo7 := ''
			cInfo8 := 0
			cInfo9 := (cAliasSC5)->C5_ZZNFMAI
			cInfo10:= (cAliasSC5)->C5_ZZOBS
			cInfo11:= Posicione("SE4",1,xFilial("SE4")+(cAliasSC5)->C5_CONDPAG,"E4_DESCRI")
			
			aadd(aItExcel , { cInfo1 , cInfo2 , cInfo3 , cInfo4 , cInfo5 , cInfo6 , cInfo7 , cInfo8 , cInfo9, cInfo10, cInfo11 })

		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ o Skip dos dados Validos do C6 e dado antes da impressao dos itens do relatorio por  ³
		//³ causa da compatibilizacao das logicas com Query e codbase onde a disposicao dos dados³
		//³ se deram de formas dIferentes.                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasSC6)
		dbSkip()
		IncRegua()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os itens do pedido no relatorio.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  cNumero + cItem + cProduto <> (cAliasSC6)->C6_NUM + (cAliasSC6)->C6_ITEM + (cAliasSC6)->C6_PRODUTO
			
			If ( lContInt .And. Len(aQuant)>0 .And. mv_par06 <> 3 ) .Or. ( lContInt .And. mv_par06 == 3 )
				
				If li > 58
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				EndIf

				nValEnt := (nQtdEnt * nPrcVen)   
				If (nQtLib+nQtBloq)<> 0
					nTFat   := (nQtLib+nQtBloq) * nPrcven
				Else	
					nTFat   := (nQtdven - nQtdent) * nPrcVen
				Endif	
				MaFisAdd(cProduto,cTes,(nQtLib+nQtBloq),nPrunit,nVldesc,,,,0,0,0,0,(nTFat),0,0,0)
				
				nItem += 1
				
				lImp := .T.
				
				nTotLocal := 0
				nTFat     := 0
				nValdesc  := 0
				nImpLinha	  := 0
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizacao do saldo disponivel em estoque com base no SB2 atraves de arquivo de trab³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("STR")
				If msSeek(cLocal+cProduto)
					nTotLocal := STR->TB_SALDO
					RecLock("STR",.F.)
				ELSE
					dbSelectArea("SB2")
					msSeek(xFilial()+cProduto+cLocal)
					nTotLocal := SaldoSB2()
					RecLock("STR",.T.)
					REPLACE TB_COD WITH cProduto,TB_LOCAL WITH cLocal,TB_SALDO WITH nTotLocal
				EndIf
				
				If nQtLib <= 0
					REPLACE TB_SALDO WITH TB_SALDO - (nQtdven - nQtdent)
				EndIf
				
				MsUnLock()
				
				If !Empty(cOp)
					dbSelectArea("SX5")
					msSeek(xFilial()+"E2"+cOp)
					cDescTab := X5Descri()
				Else
					cDescTab := ""
				EndIf
				
				
				If (nQtLib+nQtBloq)<>0
					nTFat   := (nQtLib+nQtBloq) * nPrcven
				Else
					nTFat   := (nQtdven - nQtdent) * nPrcVen
				Endif 
				
				If nPrunit > 0
					nValDesc  := (nPrunit - nPrcVen) * (nQtdVen - nQtdEnt)
				Else
					nValDesc  := nVlDesc
				EndIf
				 
				nValIPI   := MaFisRet(nItem,"IT_VALIPI")
				nImpLinha := nValIPI
				
				If MV_PAR13 == 2 
				   nImpLinha += ( MaFisRet(nItem,"IT_VALICM") + MaFisRet(nItem,"IT_VALISS") ) 
				EndIf 				
				
				nTotImpPar   += nImpLinha        
					
				
				If mv_par07 = 1
					nTFat     += nValIPI
					nAcTotFat += nValIPI
				EndIf
				
				If nValDesc < 0
					nValDesc := 0
				EndIf
  
				@li, 00 Psay cItem + " " + cProduto + " " + Substr(cDescricao,1,27)
				@li, 47 Psay nTotLocal               Picture PesqPictQt("B2_QATU",15)
				@li, 63 Psay nQtdVen                 PicTure PesqPictQt("C6_QTDVEN",11)
				@li, 75 Psay nQtdEnt                 PicTure PesqPictQt("C6_QTDENT",11)
				@li, 87 Psay (nQtdVen - nQtdEnt)     PicTure PesqPictQt("C6_QTDVEN",11)
				@li, 99 Psay nQtLib                  Picture PesqPictQt("C6_QTDVEN",11)
				@li,111 Psay nQtBloq                 Picture PesqPictQt("C6_QTDVEN",11)
				//@li,123 Psay xMoeda(nValDesc,nC5Moeda,mv_par08,IIf(mv_par12 == 1,dC5Emissao,dDataBase)) PicTure tm(nValDesc,11)
				@li,123 Psay nValDesc PicTure tm(nValDesc,11)				
				//@li,138 Psay xMoeda(nPrcVen ,nC5Moeda,mv_par08,IIf(mv_par12 == 1,dC5Emissao,dDataBase)) PicTure PesqPict((cAliasSC6),"C6_PRCVEN",11)
				@li,138 Psay nPrcVen  PicTure PesqPict((cAliasSC6),"C6_PRCVEN",11)				
				@li,150 Psay Substr(cOp+"-"+cDescTab,1,24)

				If nImpLinha > 0
					//@li,177 Psay xMoeda(nImpLinha,nC5Moeda,mv_par08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase)) PicTure PesqPict((cAliasSC6),"C6_VALOR",08)
					@li,175 Psay nImpLinha PicTure "@E 99999,99" //PesqPict((cAliasSC6),"C6_VALOR",08)
				EndIf
				If nTFat > 0
					//@li,187 Psay xMoeda(nTFat,nC5Moeda,mv_par08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))    PicTure tm(nTFat,10)
			      @li,184 Psay nTFat    PicTure "@E 9999.999,99" // tm(nTFat,10)					
				EndIf
				@ li,196 Psay dEntreg
  			   	@ li,207 psay cTES
  			   	@ li,211 Psay cPedCli
								
				nTQLib  	+= nQtLib
				nTQBloq 	+= nQtBloq
				nTQtde  	+= nQtdVen
				nTQEnt  	+= nQtdEnt
				//nTPed   	+= xMoeda(nPrcVen,nC5Moeda,mv_par08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))
				nTPed   	+= nPrcVen
				
		    	If(nQtLib+nQtBloq)<>0
					nAcTotFat	+= (nQtLib+nQtBloq) * nPrcVen
			 	Else
		  			nAcTotFat	+= (nQtdven-nQtdent) * nPrcVen
	   		Endif
				
				nAcdescont  += nValDesc
				nQtlib  	:= 0
				nQtBloq		:= 0 
			
				
				li++
				
			EndIf
			
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Skip somente dos registros invalidos do C6 recusados pelo filtro -> lFiltro = .F. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasSC6)
		dbSkip()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o Rodape do pedido no relatorio.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSC6)->C6_NUM  <> cPedido .And. lImp
		
		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIf
		
		@li,0   Psay "TOTAL DO PEDIDO--> "
		//@li,119 Psay xMoeda(nAcDescont,nC5Moeda,MV_PAR08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))	PicTure tm(nAcDescont,15)
		@li,119 Psay nAcDescont	PicTure tm(nAcDescont,15)
		If nTotImpPar > 0
			//@li,175 Psay xMoeda(nTotImpPar,nC5Moeda,MV_PAR08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))	Picture PesqPict((cAliasSC6),"C6_VALOR",10)
			@li,175 Psay nTotImpPar	Picture PesqPict((cAliasSC6),"C6_VALOR",10)
		EndIf
		If nAcTotFat > 0
			//@li,185 Psay xMoeda(nAcTotFat,nC5Moeda,MV_PAR08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))	PicTure tm(nAcTotFat,12)
			@li,185 Psay nAcTotFat PicTure tm(nAcTotFat,12)
			nPos := aScan(aItExcel , {|x| x[1] == cPedido})
			If nPos > 0
				aItExcel[nPos][7] := cPedCli
				aItExcel[nPos][8] := nAcTotFat
			Endif
		EndIf
		
		//nTotFat  += xMoeda(nAcTotFat, nC5Moeda,mv_par08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))
		//nTotDesc += xMoeda(nAcDescont,nC5Moeda,mv_par08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))
		//nTotImp  += xMoeda(nTotImpPar,nC5Moeda,mv_par08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))
		nTotFat  += nAcTotFat
		nTotDesc += nAcDescont
		nTotImp  += nTotImpPar
		
		nAcTotFat	:= 0
		nAcdescont	:= 0
		nTotImpPar 	:= 0
		nQtlib 		:= 0
		nQtBloq 	:= 0
		nItem		:= 0
		cVends      := ""
		lCabPed     := .T.
		lBarra      := .F.
		lImp        := .F.
		li          += 2
		
		MaFisEnd()
	EndIf
	
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime os valores totais do final do Relatorio. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotFat > 0
	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf
	@li,  0 Psay "TOTAL GERAL--> "
	@li, 63 Psay nTQtde				PicTure PesqPictQt("C6_QTDVEN",11)
	@li, 75 Psay nTQent	         PicTure PesqPictQt("C6_QTDENT",11)
	@li, 87 Psay (nTQtde-nTQEnt)	PicTure PesqPictQt("C6_QTDVEN",11)
	@li, 99 Psay nTQLib				Picture PesqPictQt("C6_QTDVEN",11)
	@li,111 Psay nTQBloq			   Picture PesqPictQt("C6_QTDVEN",11)
	@li,123 Psay nTotDesc			PicTure tm(nTotDesc,11)
	@li,135 Psay nTPed				PicTure PesqPict((cAliasSC6),"C6_PRCVEN",14)
	If nTotImp > 0
		@li,172 Psay nTotImp Picture PesqPict((cAliasSC6),"C6_VALOR",13)
	EndIf
	@li,186 Psay nTotFat	PicTure tm(nTotFat,11)
	li++
EndIf

If li != 80
	roda(cbcont,cbtxt,Tamanho)
EndIf

dbSelectArea("STR")
dbCloseArea()
fErase(cTrab+".DBF")
fErase(cTrab+OrdBagExt())

If lQuery
	dbSelectArea(cAliasSC5)
	dbCloseArea()
	dbSelectArea("SC6")
Else	
	RetIndex("SC9")
	Ferase(cIndexSC9+OrdBagExt())
	dbSelectArea("SC9")
	dbClearFilter()
	
	RetIndex("SC6")
	Ferase(cIndexSC6+OrdBagExt())
	dbSelectArea("SC6")
	dbClearFilter()
	dbSetOrder(1)
	dbGotop()
EndIf

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()

If Len(aItExcel) > 0
	cChv   := ""
	nTotPV := 0
	nTotG  := 0
	aNewExcel := {}
	For nI:=1 To Len(aItExcel)
		If Empty(cChv)
			cChv := aItExcel[nI][2]+aItExcel[nI][3]+aItExcel[nI][9]
		Endif
		If cChv <> aItExcel[nI][2]+aItExcel[nI][3]+aItExcel[nI][9]
			If nTotPV > 0
				aadd(aNewExcel , {' ',' ',' ',' ',' ',' ','Total desta quebra',nTotPV,' '})
				aadd(aNewExcel , {' ',' ',' ',' ',' ',' ',' ',' ',' '})
				cChv   := aItExcel[nI][2]+aItExcel[nI][3]+aItExcel[nI][9]
				nTotPV := 0
			Endif
		Endif
		nTotPV += aItExcel[nI][8]
		nTotG  += aItExcel[nI][8]
		aadd(aNewExcel , {aItExcel[nI][1],aItExcel[nI][2],aItExcel[nI][3],aItExcel[nI][4],aItExcel[nI][5],aItExcel[nI][6],aItExcel[nI][7],aItExcel[nI][8],aItExcel[nI][9],aItExcel[nI][10],aItExcel[nI][11]})
	Next
	If nTotPV > 0
		aadd(aNewExcel , {' ',' ',' ',' ',' ',' ','Total desta quebra',nTotPV,' '})
		aadd(aNewExcel , {' ',' ',' ',' ',' ',' ',' ',' ',' '})		
		aadd(aNewExcel , {' ',' ',' ',' ',' ',' ','Total Geral',nTotG,' '})		
	Endif
	
	If IW_MsgBox(OemToAnsi("Envia dados para o MS-Excel?") , OemToAnsi("Informação") , "YESNO")
		DlgToExcel({ {"ARRAY", "Exportação para o Excel", aCabExcel, aNewExcel} })
	Endif
Endif

Return(.T.)

