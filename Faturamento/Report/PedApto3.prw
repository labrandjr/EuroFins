#include "rwmake.ch"
#include "protheus.ch"

/*/{protheus.doc}PedApto3  
Relacao de Pedidos aptos a faturar
@Author Alexandre Inacio Lemes 
@since 25/10/2002
/*/
User Function PedApto3

LOCAL titulo 	  := OemToAnsi("Relacao de Pedidos de Vendas")
LOCAL cDesc1 	  := OemToAnsi("Este programa irá emitir a relação dos Pedidos de Vendas.")
LOCAL cDesc2 	  := OemToAnsi("Serão apresentadas informações relativas as amostras.")
LOCAL cDesc3 	  := OemToAnsi("Específico para o Laboratório ALAC.")
LOCAL nomeprog   := "PEDAPTO3"
LOCAL wnrel  	  := "PEDAPTO3"
LOCAL cString 	  := "SC6"
Local cPerg      := PADR("PVAPT3",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}

PRIVATE aOrdem    := {} //{OemToAnsi(" Por N§ Pedido "),OemToAnsi(" Por Produto "),OemToAnsi(" Por Cliente ")}
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
aAdd(aHelpPor,"Informe o código inicial do cliente")
aAdd(aHelpPor,"a ser considerado na seleção. ")
Aadd(aPergs,{"Do Cliente","","","mv_ch5","C",6,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a loja inicial do cliente")
aAdd(aHelpPor,"a ser considerada na seleção.")
Aadd(aPergs,{"Da loja","","","mv_ch6","C",2,0,1,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe o código final do cliente")
aAdd(aHelpPor,"a ser considerado na seleção. ")
Aadd(aPergs,{"Ate o Cliente","","","mv_ch7","C",6,0,1,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a loja final do cliente")
aAdd(aHelpPor,"a ser considerada na seleção.")
Aadd(aPergs,{"Ate a loja","","","mv_ch8","C",2,0,1,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data inicial de emissão ")
aAdd(aHelpPor,"do Pedido de Venda.")
Aadd(aPergs,{"Da Data de Emissao","","","mv_ch9","D",08,0,1,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Informe a data final de emissão ")
aAdd(aHelpPor,"do Pedido de Venda.")
Aadd(aPergs,{"Ate a Data de Emissao","","","mv_cha","D",08,0,1,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique se as informações serão ")
aAdd(aHelpPor,"enviadas para uma planilha do MS-Excel")
aAdd(aHelpPor,"ou não.")
Aadd(aPergs,{"Envia para o MS-Excel?","","","mv_chb","N",01,0,1,"C","","MV_PAR11","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

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
//³ mv_par04 	      // Ate o Produto                            ³
//³ mv_par05         // Do Cliente                               ³
//³ mv_par06         // Da Loja                                  ³
//³ mv_par07         // Ate o Cliente                            ³
//³ mv_par08         // Ate a Loja                               ³
//³ mv_par09         // Da data de emissao da Pedido             ³
//³ mv_par10         // Ate a data de emissao da Pedido          ³
//³ mv_par11         // Envia para MS-Excel                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

LOCAL nomeprog   := "PEDAPTO3"
LOCAL cabec1 	 := "  PRODUTO                   DESCRICAO                                                           ANALISES                                                       NOME DA AMOSTRA                                         VALOR" 
LOCAL cabec2 	 := ""
LOCAL cbtxt      := SPACE(10)
LOCAL cAliasSC5  := "SC5"
LOCAL cAliasSC6  := "SC6" 
LOCAL cDescOrdem := ""
LOCAL cQuery     := ""
LOCAL cFilter    := ""
LOCAL nTipo		 := GetMv("MV_COMP")
LOCAL nOrdem 	 := 1 // aReturn[8]
LOCAL nX	 	    := 1
LOCAL CbCont 	 := 0
LOCAL nTot1	    := 0
LOCAL nTot2	    := 0
LOCAL nTot3	    := 0
LOCAL aStruSC5   := {}
LOCAL aStruSC6   := {} 
Local lFirst := .T.
//Local aCabExcel := {'Produto','Descricao','Numero do Pedido','Data da Entrada','Data da Liberacao','Analises','Nome da Amostra','Condicao de Pgto','Valor'}   
Local aCabExcel := {'Produto','Descricao','Numero do Pedido','Data da Entrada','Data da Liberacao','Descricao da Amostra','Nome da Amostra','Numero Certificado','Condicao de Pgto','Valor','Observacao','Ped.Cliente'}
Local aItExcel  := {}

/*                                                                      
  PRODUTO                   DESCRICAO                                                           ANALISES                                                       NOME DA AMOSTRA                                         VALOR
CLIENTE: XXXXXX/XX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  NUM.PEDIDO: XXXXXX  DATA EMISSAO: XX/XX/XXXX  DATA ENTRADA: XX/XX/XXXX  DATA LIBERACAO: XX/XX/XXXX  NUM.LAUDO: XXXXXXXXXXXXXXXXXXXX  COND.PGTO: XXX
XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999,99
                                                                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
                                                                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
                                                                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
*/

If mv_par11 == 1
	//Aviso("Importante","Primeiramente o relatório será exibido em tela. Em seguida, os dados serão exportados para o MS-Excel.",{"Ok"},2)
	IW_MsgBox("Primeiramente o relatório será exibido em tela. Em seguida, os dados serão exportados para o MS-Excel.","Importante","INFO")
Endif

lQuery    := .T.
cAliasSC5 := "QRYSC6"
cAliasSC6 := "QRYSC6"

aStruSC5  := SC5->(dbStruct())
aStruSC6  := SC6->(dbStruct())

cQuery := "SELECT "
cQuery += "SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_EMISSAO,SC5.C5_CONDPAG,"
cQuery += "SC5.C5_ZZNROCE,SC5.C5_ZZDATAR,SC5.C5_ZZDTENT,SC5.C5_ZZOBS,C6_ZZCODAM,"
cQuery += "SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_VALOR,SC6.C6_CLI,SC6.C6_LOJA,SC5.C5_ZZNROCE,SC5.C5_ZZOBS, SC6.C6_PEDCLI "
cQuery += "FROM "
cQuery += RetSqlName("SC5")+" SC5 ,"+RetSqlName("SC6")+" SC6 ,"
cQuery += "WHERE "
cQuery += "SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_NUM >= '"+mv_par01+"' AND SC5.C5_NUM <= '"+mv_par02+"' AND "
cQuery += "SC5.C5_CLIENTE >= '"+mv_par05+"' AND SC5.C5_LOJACLI >= '"+mv_par06+"' AND "
cQuery += "SC5.C5_CLIENTE <= '"+mv_par07+"' AND SC5.C5_LOJACLI <= '"+mv_par08+"' AND "
cQuery += "SC5.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' AND SC6.C6_NUM   = SC5.C5_NUM AND "
cQuery += "SC5.C5_EMISSAO >= '" + Dtos(mv_par09) + "' AND "
cQuery += "SC5.C5_EMISSAO <= '" + Dtos(mv_par10) + "' AND "
cQuery += "SC6.C6_PRODUTO >= '" + mv_par03       + "' AND "
cQuery += "SC6.C6_PRODUTO <= '" + mv_par04       + "' AND "
cQuery += "SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND SC6.C6_BLQ<>'R ' AND SC6.D_E_L_E_T_ = ' ' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ATENCAO !!!! ao manipular os campos do SELECT ou a ordem da Clausula ORDER BY verificar   ³
//³ a concordancia entre os mesmos !!!!!!!!!                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If nOrdem = 1
	cDescOrdem:= "PEDIDO"
	cQuery += "ORDER BY 2"
ElseIf nOrdem = 2
	cDescOrdem:= "PRODUTO"
	cQuery += "ORDER BY 14"
ElseIf nOrdem = 3
	cDescOrdem:= "CLIENTE"+"PEDIDO"
	cQuery += "ORDER BY 3,4,2" 
EndIf
*/
cDescOrdem:= "CLIENTE+PEDIDO"
cQuery += "ORDER BY 3,4,2" 

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

titulo += " - ORDEM DE " + cDescOrdem 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Area do While e retorna o total Elementos da regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectArea(cAliasSC6)
SetRegua(SC6->(RecCount()))

While !( cAliasSC6 )->( Eof() ) .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6")

	IncRegua()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se cancelado pelo usuario                        	       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEnd
		@ PROW()+1,001 Psay "CANCELADO PELO OPERADOR"
		Exit
	EndIf

	dbSelectArea( cAliasSC6 ) 

	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf
			
   If lFirst
		@ li,000 Psay "CLIENTE: "+(cAliasSC5)->C5_CLIENTE+"/"+(cAliasSC5)->C5_LOJACLI+" - "
		@ li,021 Psay Posicione("SA1",1,xFilial("SA1")+(cAliasSC5)->C5_CLIENTE+(cAliasSC5)->C5_LOJACLI,"A1_NOME")
		@ li,073 Psay "NUM.PEDIDO: "+(cAliasSC5)->C5_NUM 
		@ li,093 Psay "DATA EMISSAO: "+DtoC((cAliasSC5)->C5_EMISSAO)
		@ li,119 Psay "DATA ENTRADA: "+DtoC((cAliasSC5)->C5_ZZDATAR)
		@ li,145 Psay "DATA LIBERACAO: "+DtoC((cAliasSC5)->C5_ZZDATAR)
		@ li,173 Psay "NUM.LAUDO: "+(cAliasSC5)->C5_ZZNROCE
		@ li,206 Psay "COND.PGTO: "+(cAliasSC5)->C5_CONDPAG
		lFirst  := .F.
		li+=2
		cPedAnt := (cAliasSC5)->C5_NUM
		cCliAnt := (cAliasSC5)->C5_CLIENTE+(cAliasSC5)->C5_LOJACLI
		
		If aScan(aItExcel , {|x| (cAliasSC5)->C5_CLIENTE+"/"+(cAliasSC5)->C5_LOJACLI $ x[1] }) == 0

	  		aadd(aItExcel,{"CLIENTE: "+(cAliasSC5)->C5_CLIENTE+"/"+(cAliasSC5)->C5_LOJACLI+" - "+Posicione("SA1",1,xFilial("SA1")+(cAliasSC5)->C5_CLIENTE+(cAliasSC5)->C5_LOJACLI,"A1_NOME"),;
								" ",;        
								" ",;
								" ",;
								" ",;
								" ",;
								" ",;														
								" ",;
								" "})							  
		Endif
							
	Endif
	
	@ li,000 Psay (cAliasSC6)->C6_PRODUTO
	@ li,016 Psay (cAliasSC6)->C6_DESCRI

	nTamDesc := 67
	
	cDescri1 := (cAliasSC6)->C6_ZZCODAM
	nLinha1  := MLCount(cDescri1,nTamDesc)
	If !Empty(MemoLine(cDescri1,nTamDesc,1))
		@ li,068 PSAY MemoLine(cDescri1,nTamDesc,1)
	Endif
	
	cDescri2 := (cAliasSC5)->C5_ZZOBS
	nLinha2  := MLCount(cDescri2,nTamDesc)
	If !Empty(MemoLine(cDescri2,nTamDesc,1))
		@ li,137 PSAY MemoLine(cDescri2,nTamDesc,1)
	Endif

	@ li,206 Psay (cAliasSC6)->C6_VALOR Picture "@E 999,999,999.99"
	nTot1 += (cAliasSC6)->C6_VALOR
	nTot2 += (cAliasSC6)->C6_VALOR
	nTot3 += (cAliasSC6)->C6_VALOR	

	For nX := 2 To Max(nLinha1,nLinha2)
		If li > 58
			cabec(Titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		Endif 
		lLin1 := .F.
		If nX <= nLinha1
			If !Empty(Memoline(cDescri1,nTamDesc,nX))
				li++
				@ li,068 PSAY Memoline(cDescri1,nTamDesc,nX)
				lLin1 := .T.
			Endif
		Endif
		If nX <= nLinha2
			If !Empty(Memoline(cDescri2,nTamDesc,nX))
				If !lLin1
					li++
				Endif
				@ li,137 PSAY Memoline(cDescri2,nTamDesc,nX)
			Endif
		Endif
	Next nX

	aadd(aItExcel,{(cAliasSC6)->C6_PRODUTO,;
						(cAliasSC6)->C6_DESCRI,;
						(cAliasSC6)->C6_NUM,;
						DtoC((cAliasSC5)->C5_ZZDATAR),;
				  		DtoC((cAliasSC5)->C5_ZZDTENT),;
				  		cDescri1,;
						cDescri2,;
						(cAliasSC5)->C5_ZZNROCE,;
						(cAliasSC5)->C5_CONDPAG,;
						Transform((cAliasSC6)->C6_VALOR,"@E 999,999,999.99"),;
						(cAliasSC5)->C5_ZZOBS,;
						(cAliasSC6)->C6_PEDCLI,;	  //VERIFICAR					
						})

   li+=2
	dbSelectArea(cAliasSC6)
	dbSkip()
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica quebra do cliente  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCliAnt <> (cAliasSC5)->C5_CLIENTE+(cAliasSC5)->C5_LOJACLI

		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIf
		@ li,180 Psay "Total do Pedido ---->"
		@ li,206 Psay nTot1 Picture "@E 999,999,999.99"	
      li++
      
		@ li,180 Psay "Total do Cliente ---->"
		@ li,206 Psay nTot2 Picture "@E 999,999,999.99"	
		li++
				
		@ li,000 Psay __PrtThinLine()
		
		/*
		aadd(aItExcel,{' ',;
							' ',;
							' ',;
							' ',;
							' ',;
							' ',;
							' ',;							
							'Total do Pedido ---->',;
							Transform(nTot1,"@E 999,999,999.99")})	
		*/
		aadd(aItExcel,{' ',;
							' ',;
							' ',;
							' ',;
							' ',;
							' ',;
							' ',;														
							'Total do Cliente ---->',;
							Transform(nTot2,"@E 999,999,999.99")})	
		aadd(aItExcel,{' ',;
							' ',;
							' ',;
							' ',;
							' ',;
							' ',; 
							' ',;
							' ',;														
							' '})	
		nTot1  := 0
		nTot2  := 0
		lFirst := .T.
		li+=2
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica quebra do pedido   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cPedAnt <> (cAliasSC5)->C5_NUM

		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIf
		@ li,180 Psay "Total do Pedido ---->"
		@ li,206 Psay nTot1 Picture "@E 999,999,999.99"	

		/*
		aadd(aItExcel,{' ',;
							' ',;
							' ',;
							' ',;
							' ',;
							' ',;
							' ',;														
							'Total do Pedido ---->',;
							Transform(nTot1,"@E 999,999,999.99")})	
      */
      
		nTot1  := 0
		lFirst := .T.
		li+=2
							
	Endif
	
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime os valores totais do final do Relatorio. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTot3 > 0
	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf
	@ li,180 Psay "Total Geral ---->"
	@ li,206 Psay nTot3 Picture "@E 999,999,999.99"	

	aadd(aItExcel,{' ',;
						' ',;
						' ',;
						' ',;
						' ',;
						' ',;
						' ',;													
						'Total Geral ---->',;
						Transform(nTot3,"@E 999,999,999.99")})							
EndIf

If li != 80
	Roda(cbcont,cbtxt,Tamanho)
EndIf

dbSelectArea(cAliasSC5)
dbCloseArea()
dbSelectArea("SC6")

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()

If mv_par11 == 1 .and. Len(aItExcel) > 0
	//If Aviso("Informação","Confirma o envio dos dados para o MS-Excel?",{"Sim","Não"},2,"Exportação")==1
	If IW_MsgBox("Confirma o envio dos dados para o MS-Excel?" , "Exportação" , "YESNO")
		DlgToExcel({ {"ARRAY", "Exportação para o Excel", aCabExcel, aItExcel} })
	Endif
Endif

Return(.T.)

