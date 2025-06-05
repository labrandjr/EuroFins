#include "rwmake.ch"
#include "topconn.ch"

/*/{protheus.doc}BolBrad   
Imprime boleto de cobranca para o banco Bradesco
@Author Marcos Candido    
@since 08/02/11   
/*/
User Function BolBrad

LOCAL	aPergs := {} 

PRIVATE lExec    := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''

Tamanho  := "M"
titulo   := "Impressใo de Boleto com C๓digo de Barras"
cDesc1   := "Este programa destina-se a impressใo do Boleto com C๓digo de Barras."
cDesc2   := "Especifico para o Banco Bradesco."
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
cPerg     := padr("BLTBRAD",10)
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
nLastKey := 0

dbSelectArea("SE1")

Aadd(aPergs,{"De Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo","","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch4","C",9,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela","","","mv_ch5","C",1,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela","","","mv_ch6","C",1,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Portador","","","mv_ch7","C",3,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","BCOS1","","","",""})
Aadd(aPergs,{"Ate Portador","","","mv_ch8","C",3,0,0,"G","","MV_PAR08","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","BCOS1","","","",""})
Aadd(aPergs,{"De Cliente","","","mv_ch9","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"De Loja","","","mv_cha","C",2,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Cliente","","","mv_chb","C",6,0,0,"G","","MV_PAR11","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"Ate Loja","","","mv_chc","C",2,0,0,"G","","MV_PAR12","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao","","","mv_chd","D",8,0,0,"G","","MV_PAR13","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao","","","mv_che","D",8,0,0,"G","","MV_PAR14","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Vencimento","","","mv_chf","D",8,0,0,"G","","MV_PAR15","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Vencimento","","","mv_chg","D",8,0,0,"G","","MV_PAR16","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Banco","","","mv_chh","C",3,0,0,"G","","MV_PAR17","","","","","","","","","","","","","","","","","","","","","","","","","BCOS2","","","",""})
Aadd(aPergs,{"Agencia","","","mv_chi","C",5,0,0,"G","","MV_PAR18","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Conta","","","mv_chj","C",10,0,0,"G","","MV_PAR19","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Sub Conta","","","mv_chk","C",3,0,0,"G","","MV_PAR20","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1(cPerg,aPergs)

Pergunte(cPerg,.f.)

Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

cIndexName	:= Criatrab(Nil,.F.)
cIndexKey	:= "E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"

cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And." 
cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And.E1_NUM<='" + MV_PAR04 + "'.And."
cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "'.And."
cFilter		+= "E1_PORTADO>='" + MV_PAR07 + "'.And.E1_PORTADO<='" + MV_PAR08 + "'.And."
cFilter		+= "E1_CLIENTE>='" + MV_PAR09 + "'.And.E1_CLIENTE<='" + MV_PAR11 + "'.And."
cFilter		+= "E1_LOJA>='" + MV_PAR10 + "'.And.E1_LOJA<='"+MV_PAR12+"'.And."
cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par13)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par14)+"'.And."
cFilter		+= 'DTOS(E1_VENCREA)>="'+DTOS(mv_par15)+'".and.DTOS(E1_VENCREA)<="'+DTOS(mv_par16)+'".And.'
cFilter		+= "!(E1_TIPO$MVABATIM) .and. !(E1_TIPO$MVRECANT)"

IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
DbSelectArea("SE1")
#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
#ENDIF

dbGoTop()
@ 001,001 TO 400,700 DIALOG oDlg TITLE "Sele็ใo de Tํtulos"
@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
@ 180,275 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
@ 180,310 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
ACTIVATE DIALOG oDlg CENTERED
	
dbGoTop()
If lExec
	Processa({|lEnd|MontaRel()})
Endif
RetIndex("SE1")
Ferase(cIndexName+OrdBagExt())

Return Nil      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ  MontaRelณ Autor ณ Microsiga             ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio   ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS		      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico para Clientes Microsiga                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MontaRel()

Local oPrint
Local nX := 0
Local cNroDoc :=  " "
Local aDadosEmp    := {	SM0->M0_NOMECOM                                    							,; 	//[1]Nome da Empresa
						SM0->M0_ENDCOB                                     							,; 	//[2]Endere็o
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB	,;	//[3]Complemento
						"CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999")            				,;	//[4]CEP
						"PABX/FAX: "+SM0->M0_TEL                                                  	,;	//[5]Telefones
						"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                   	,;	//[6]CNPJ
						"I.E.: "+Transform(SM0->M0_INSC,"@R 999.999.999.999")}  					//[7]I.E

Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local aBolText     := {"Ap๓s vencimento, cobrar multa de 2,00% ao m๊s." , "Mora diแria de R$ " , "Protestar ap๓s o 5บ dia ap๓s o vencimento."} 

Local nI           := 1
Local aCB_RN_NN    := {}
Local lCarrefour   := .F.

Private cLogoBco := "\IMAGEM\LOGOBRAD.BMP"
Private cLogoEmp := "\IMAGEM\MSMDILOGO.BMP"

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:Setup()
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova pแgina
//oPrint:SetPaperSize(Val(GetProfString(GetPrinterSession(),"PAPERSIZE","1",.T.)))
oPrint:SetPaperSize(9)

dbGoTop()
ProcRegua(RecCount())
Do While !EOF()

	If Marked("E1_OK")

		//Posiciona o SA6 (Bancos)
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(xFilial("SA6")+mv_par17+mv_par18+mv_par19)
	
		//Posiciona na Arq de Parametros CNAB
		DbSelectArea("SEE")
		DbSetOrder(1)
		DbSeek(xFilial("SEE")+mv_par17+mv_par18+mv_par19+mv_par20)	
		cBcoAg  := StrTran(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_DVAGE),"-","")
		cBcoCon := StrTran(Alltrim(SEE->EE_CONTA),"-","")
		aDadosBanco  := {SEE->EE_CODIGO                    		,;	// [1]Numero do Banco
						 cLogoBco                    			,;	// [2]Nome do Banco (LOGO)
	    	             Transform(StrZero(Val(cBcoAg),5),"@R 9999-9")			,;	// [3]Ag๊ncia
	           	         Transform(cBcoCon,"@R 999999-9")		,;	// [4]Conta Corrente
	               	     "09"}				    					// [5]Codigo da Carteira

		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)	
		
		If (Substr(SA1->A1_CGC,1,8)='45543915' .or. Substr(SA1->A1_CGC,1,8)='62545579')
			lCarrefour := .T.
		Endif
	
		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)           	,;     	// [1]Razใo Social
			AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA           	,;     	// [2]C๓digo
			AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO)	,;     	// [3]Endere็o
			AllTrim(SA1->A1_MUN)                            	,; 		// [4]Cidade
			SA1->A1_EST                                      	,;    	// [5]Estado
			SA1->A1_CEP                                      	,;     	// [6]CEP
			SA1->A1_CGC										 	,; 		// [7]CGC
			iif(len(Alltrim(SA1->A1_CGC))==11,"F","J")		}  			// [8]PESSOA
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)            	 ,;   	// [1]Razใo Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]C๓digo
			AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endere็o
			AllTrim(SA1->A1_MUNC)	                             ,;   	// [4]Cidade
			SA1->A1_ESTC	                                     ,;   	// [5]Estado
			SA1->A1_CEPC                                        ,;   	// [6]CEP
			SA1->A1_CGC											 ,;		// [7]CGC
			iif(len(Alltrim(SA1->A1_CGC))==11,"F","J")		}  			// [8]PESSOA
		Endif
	
		dbSelectArea("SE1")
        /*
		nValorTit := SE1->(E1_SALDO-E1_DECRESC+E1_ACRESC)
		nValIRRF  := 0
		nValPIS   := 0
		nValCOFI  := 0
		nValCSLL  := 0
		aAreaSE1  := GetArea()
	
		cQuery := "SELECT * FROM "+RetSQLName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND "
		cQuery += "E1_PREFIXO = '"+SE1->E1_PREFIXO+"' AND E1_NUM = '"+SE1->E1_NUM+"' AND "
		cQuery += "E1_CLIENTE = '"+SE1->E1_CLIENTE+"' AND E1_LOJA = '"+SE1->E1_LOJA+"' AND "
		cQuery += "E1_TIPO <> 'NF ' AND D_E_L_E_T_ <> '*' "
	                     
		cQuery := ChangeQuery(cQuery)
		TcQuery cQuery New Alias "WSE1"
	
		While !Eof() 
			If WSE1->E1_TIPO == "IR-"
	        	nValIRRF += WSE1->E1_VALOR
			Elseif WSE1->E1_TIPO == "PI-" 
	            nValPIS += WSE1->E1_VALOR
			ElseIf WSE1->E1_TIPO == "CF-" 
	  			nValCOFI += WSE1->E1_VALOR
			ElseIf WSE1->E1_TIPO == "CS-" 
				nValCSLL += WSE1->E1_VALOR
			Endif
	        WSE1->(dbSkip())
		Enddo
			
		nValorTit := nValorTit - (nValIRRF + iif(!lCarrefour , nValPIS + nValCOFI + nValCSLL , 0))
	
		dbCloseArea("WSE1")	
		RestArea(aAreaSE1)	
		*/
          
		aAreaSE1  := GetArea()
		nValIRRF  := 0
		nValPIS   := 0
		nValCOFI  := 0
		nValCSLL  := 0
	
		nValorTit := SE1->(E1_SALDO-E1_DECRESC+E1_ACRESC)
		nTotImp   := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_EMISSAO,,@nValIRRF,@nValCSLL,@nValPIS,@nValCOFI)
		nValorTit := nValorTit - (nValIRRF + iif(!lCarrefour , nValPIS + nValCOFI + nValCSLL , 0))
		
		RestArea(aAreaSE1)	
	
		cNroDoc  := Alltrim(SE1->E1_NUMBCO)
		If Empty(cNroDoc)    
			cNroDoc := Right(Alltrim(NOSSONUM()),11)
		Endif
		cNroDoc := Alltrim(cNroDoc)

		//Monta codigo de barras
		aCB_RN_NN := B_Ret_cBarra(aDadosBanco[1] , cNroDoc , nValorTit , aDadosBanco[5] , "9" )	
		RecLock("SE1",.F.)
		  SE1->E1_NUMBCO := Substr(aCB_RN_NN[3],3)   // Nosso n๚mero sem a carteira
		MsUnlock()
	
		dbSelectArea("SE1")	
		nMora := 0
		If E1_PORCJUR == 0
			nMora := NoRound(nValorTit*0.0007,2) //Utilizar 2,3% a.m. 
		Else
			nMora := NoRound(nValorTit*(E1_PORCJUR/100),2)
		Endif
		RecLock("SE1",.F.)
		  Replace	E1_VALJUR	With	nMora
		MsUnlock()
	
		aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)		,;  // [1] N๚mero do tํtulo
							E1_EMISSAO                          ,;  // [2] Data da emissใo do tํtulo
							dDataBase                    		,;  // [3] Data da emissใo do boleto
							E1_VENCTO                           ,;  // [4] Data do vencimento
							nValorTit              				,;  // [5] Valor do tํtulo
							cNroDoc                             ,;  // [6] Nosso n๚mero 
							E1_PREFIXO                          ,;  // [7] Prefixo da NF
							E1_TIPO	                           	,;	// [8] Tipo do Titulo   
							nMora}   								// [9] Mora diaria
						
		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
	EndIf

	dbSkip()
	IncProc()

EndDo

oPrint:EndPage()     // Finaliza a pแgina
oPrint:Preview()     // Visualiza antes de imprimir

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ  Impress ณ Autor ณ Microsiga             ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ IMPRESSAO DO BOLETO LASER                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico para Clientes Microsiga                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

Local oFont8
Local oFont11c
Local oFont10
Local oFont14
Local oFont16n
Local oFont15
Local oFont14n
Local oFont24
Local nI := 0

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8  := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova pแgina

/******************/
/* PRIMEIRA PARTE */
/******************/

nRow1 := 0
 
oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

oPrint:SayBitMap(nRow1+24,090,aDadosBanco[2],345,130)		// [2]Nome do Banco (LOGO)
oPrint:Say  (nRow1+0075,513,aDadosBanco[1]+"-2",oFont21 )	// [1]Numero do Banco
oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega",oFont10)
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say  (nRow1+0150,100 ,"Cedente",oFont8)
oPrint:Say  (nRow1+0200,100 ,aDadosEmp[1],oFont10)				//Nome + CNPJ

oPrint:Say  (nRow1+0150,1060,"Ag๊ncia/C๓digo Cedente",oFont8)
oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"/"+aDadosBanco[4],oFont10)

oPrint:Say  (nRow1+0150,1510,"Nro.Documento",oFont8)
oPrint:Say  (nRow1+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0250,100 ,"Sacado",oFont8)
oPrint:Say  (nRow1+0300,100 ,aDatSacado[1],oFont10)				//Nome

oPrint:Say  (nRow1+0250,1060,"Vencimento",oFont8)
oPrint:Say  (nRow1+0300,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

oPrint:Say  (nRow1+0250,1510,"Valor do Documento",oFont8)
oPrint:Say  (nRow1+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/tํtulo",oFont10)
oPrint:Say  (nRow1+0450,0100,"com as caracterํsticas acima.",oFont10)

oPrint:SayBitMap(nRow1+0370,630,cLogoEmp,370,110)	// LOGO DA EMPRESA

oPrint:Say  (nRow1+0350,1060,"Data",oFont8)
oPrint:Say  (nRow1+0350,1410,"Assinatura",oFont8)
oPrint:Say  (nRow1+0450,1060,"Data",oFont8)
oPrint:Say  (nRow1+0450,1410,"Entregador",oFont8)

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say  (nRow1+0165,1910,"(  )Mudou-se"                                	,oFont8)
oPrint:Say  (nRow1+0205,1910,"(  )Ausente"                                    ,oFont8)
oPrint:Say  (nRow1+0245,1910,"(  )Nใo existe nบ indicado"                  	,oFont8)
oPrint:Say  (nRow1+0285,1910,"(  )Recusado"                                	,oFont8)
oPrint:Say  (nRow1+0325,1910,"(  )Nใo procurado"                              ,oFont8)
oPrint:Say  (nRow1+0365,1910,"(  )Endere็o insuficiente"                  	,oFont8)
oPrint:Say  (nRow1+0405,1910,"(  )Desconhecido"                            	,oFont8)
oPrint:Say  (nRow1+0445,1910,"(  )Falecido"                                   ,oFont8)
oPrint:Say  (nRow1+0485,1910,"(  )Outros(anotar no verso)"                  	,oFont8)
           

/*****************/
/* SEGUNDA PARTE */
/*****************/

nRow2 := 200

oPrint:SayBitMap(nRow2+0584,100,aDadosBanco[2],345,130)		// [2]Nome do Banco (LOGO)
oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-2",oFont21 )	// 	[1]Numero do Banco
oPrint:Say  (nRow2+0644,1800,"Recibo do Sacado",oFont10)

//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(nRow2+0550, nI,nRow2+0550, nI+30)
Next nI

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

oPrint:Line (nRow2+0910,500,nRow2+1050,500)
oPrint:Line (nRow2+0980,375,nRow2+1050,375)
oPrint:Line (nRow2+0980,750,nRow2+1050,750)
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

oPrint:Say  (nRow2+0710,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow2+0725,400 ,"Preferencialmente nas ag๊ncias Bradesco,",oFont10)
oPrint:Say  (nRow2+0765,400 ,"ou at้ o vencimento em qualquer banco.",oFont10)

oPrint:Say  (nRow2+0710,1810,"Vencimento"                                     ,oFont8)
cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0750,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0810,100 ,"Cedente"                                        ,oFont8)
oPrint:Say  (nRow2+0850,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow2+0810,1810,"Ag๊ncia/C๓digo Cedente",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4])
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0850,nCol+090,cString,oFont11c)

oPrint:Say  (nRow2+0910,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (nRow2+0940,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

oPrint:Say  (nRow2+0910,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow2+0940,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0910,1005,"Esp้cie Doc."                                   ,oFont8)
//oPrint:Say  (nRow2+0940,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo
oPrint:Say  (nRow2+0940,1050,"DM" 									,oFont10) //Tipo do Titulo

oPrint:Say  (nRow2+0910,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow2+0940,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow2+0910,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow2+0940,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

oPrint:Say  (nRow2+0910,1810,"Cart/Nosso N๚mero"                                   ,oFont8)
cString := Alltrim(aCB_RN_NN[3])
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0940,nCol+20,Transform(cString,"@R XX/XXXXXXXXXXX-X"),oFont11c)
oPrint:Say  (nRow2+0980,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow2+0980,380 ,"CIP"                                     ,oFont8)
oPrint:Say  (nRow2+1010,400 ,"000"                                  	,oFont10)

oPrint:Say  (nRow2+0980,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow2+1010,555 ,aDadosBanco[5]                                  	,oFont10)

oPrint:Say  (nRow2+0980,755 ,"Esp้cie"                                        ,oFont8)
oPrint:Say  (nRow2+1010,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow2+0980,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow2+0980,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow2+0980,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+1010,nCol,cString ,oFont11c)

oPrint:Say  (nRow2+1050,100 ,"Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do cedente)",oFont8)
oPrint:Say  (nRow2+1110,100 ,aBolText[1],oFont10)
oPrint:Say  (nRow2+1160,100 ,aBolText[2]+Transform(aDadosTit[9],"@E 999,999.99"),oFont10)
// Imprime mensagem especial caso seja Carrefour
If Substr(aDatSacado[7],1,8)=='45543915'
	oPrint:Say  (nRow2+1210,100 ,"CNPJ DO FORNECEDOR: "+StrTran(aDadosEmp[6],"CNPJ: ",""),oFont10)
	oPrint:Say  (nRow2+1260,100 ,"CNPJ DE RECEBIMENTO GRUPO CARRREFOUR: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)
	oPrint:Say  (nRow2+1310,100 ,"NUMERO DA NOTA FISCAL: "+aDadosTit[1],oFont10)
	oPrint:Say  (nRow2+1360,100 ,aBolText[3],oFont10)
Else
	oPrint:Say  (nRow2+1210,100 ,aBolText[3],oFont10)
Endif


oPrint:SayBitMap(nRow2+1120,1300,cLogoEmp,370,110)	// LOGO DA EMPRESA

oPrint:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow2+1120,1810,"(-)Outras Dedu็๕es"                             ,oFont8)
oPrint:Say  (nRow2+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow2+1260,1810,"(+)Outros Acr้scimos"                           ,oFont8)
oPrint:Say  (nRow2+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow2+1400,100 ,"Sacado"                                         ,oFont8)
oPrint:Say  (nRow2+1430,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
oPrint:Say  (nRow2+1483,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow2+1536,400 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

if aDatSacado[8] = "J"
	oPrint:Say  (nRow2+1589,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow2+1589,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow2+1605,100 ,"Sacador/Avalista",oFont8)
oPrint:Say  (nRow2+1645,1500,"Autentica็ใo Mecโnica",oFont8)

oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 ) 
oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )


/******************/
/* TERCEIRA PARTE */
/******************/

nRow3 := 240 //300

oPrint:SayBitMap(nRow3+1874,100,aDadosBanco[2],345,130)		//  [2]Nome do Banco (LOGO)	
oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-2",oFont21 )		// 	[1]Numero do Banco
oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],oFont15n)			//	Linha Digitavel do Codigo de Barras

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1840, nI, nRow3+1840, nI+30)
Next nI

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,375,nRow3+2340,375)
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow3+2015,400 ,"Preferencialmente nas ag๊ncias Bradesco,",oFont10)
oPrint:Say  (nRow3+2055,400 ,"ou at้ o vencimento em qualquer banco.",oFont10)

oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2100,100 ,"Cedente",oFont8)
oPrint:Say  (nRow3+2140,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+2100,1810,"Ag๊ncia/C๓digo Cedente",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4])
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol+090,cString ,oFont11c)

oPrint:Say  (nRow3+2200,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say (nRow3+2230,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

oPrint:Say  (nRow3+2200,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow3+2230,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2200,1005,"Esp้cie Doc."                                   ,oFont8)
//oPrint:Say  (nRow3+2230,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo
oPrint:Say  (nRow3+2230,1050,"DM"									,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+2200,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow3+2230,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao


oPrint:Say  (nRow3+2200,1810,"Cart/Nosso N๚mero"                                   ,oFont8)
cString := Alltrim(aCB_RN_NN[3])
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2230,nCol+20,Transform(cString,"@R XX/XXXXXXXXXXX-X"),oFont11c)

oPrint:Say  (nRow3+2270,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow3+2270,380 ,"CIP"                                     ,oFont8)
oPrint:Say  (nRow3+2300,400 ,"000"                                  	,oFont10)

oPrint:Say  (nRow3+2270,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow3+2300,555 ,aDadosBanco[5]                                  	,oFont10)

oPrint:Say  (nRow3+2270,755 ,"Esp้cie"                                        ,oFont8)
oPrint:Say  (nRow3+2300,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow3+2270,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow3+2270,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow3+2270,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2340,100 ,"Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do cedente)",oFont8)
oPrint:Say  (nRow3+2400,100 ,aBolText[1],oFont10)
oPrint:Say  (nRow3+2450,100 ,aBolText[2]+Transform(aDadosTit[9],"@E 999,999.99"),oFont10)
// Imprime mensagem especial caso seja Carrefour
If Substr(aDatSacado[7],1,8)= '45543915'
	oPrint:Say  (nRow3+2500,100 ,"CNPJ DO FORNECEDOR: "+StrTran(aDadosEmp[6],"CNPJ: ",""),oFont10)
	oPrint:Say  (nRow3+2550,100 ,"CNPJ DE RECEBIMENTO GRUPO CARRREFOUR: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)
	oPrint:Say  (nRow3+2600,100 ,"NUMERO DA NOTA FISCAL: "+aDadosTit[1],oFont10)
	oPrint:Say  (nRow3+2650,100 ,aBolText[3],oFont10)
Else
	oPrint:Say  (nRow3+2500,100 ,aBolText[3],oFont10)
Endif

oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+2410,1810,"(-)Outras Dedu็๕es"                             ,oFont8)
oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+2550,1810,"(+)Outros Acr้scimos"                           ,oFont8)
oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+2690,100 ,"Sacado"                                         ,oFont8)
oPrint:Say  (nRow3+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2700,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow3+2700,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow3+2753,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow3+2806,400 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

oPrint:Say  (nRow3+2815,100 ,"Sacador/Avalista"                               ,oFont8)
oPrint:Say  (nRow3+2855,1500,"Autentica็ใo Mecโnica - Ficha de Compensa็ใo"                        ,oFont8)

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

MSBAR3("INT25",27,0.8,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,1.20,Nil,Nil,"A",.F.)

oPrint:EndPage() // Finaliza a pแgina

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRetDados  บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ calculos para o banco Bradesco 					          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function B_Ret_cBarra(cBanco,cNroDoc,nValor,cCart,cMoeda)

Local cNosso		:= ""
Local cDigNosso		:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra		:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local aRet			:= {}

//Nosso Numero
If Len(cNroDoc) == 12 // ja tem o digito
	cNosso := Substr(cNroDoc,1,11)
	cDigNN := Substr(cNroDoc,12,1)
Else
	cNosso := cNroDoc
	cDigNN := DIGNUMB(cNosso)
Endif

// campo livre
cCampoL := "0"+Substr(SEE->EE_AGENCIA,1,3)+cCart+cNosso+StrZero(Val(Substr(SEE->EE_CONTA,1,6)),7)+"0"

//Fator de Vencimento + Valor do titulo
cFator := ALLTRIM(STR(SE1->E1_VENCTO - IIF(DTOS(SE1->E1_VENCTO)>=GetMv("CL_NVDTBL"),CtoD(GetMv("CL_DT1000")),CtoD("07/10/1997"))))
cFatorValor  := cFator+StrZero(nValor*100,10)

cLivre := cBanco+cMoeda+cFatorValor+cCampoL

// campo do codigo de barra
cDigBarra := CALC_DB(cLivre)
cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5)

// composicao da linha digitavel
cParte1  := Substr(cBarra,1,4)+SUBSTR(cBarra,20,5)
cDig1    := DIGITO001( cParte1 )
cParte2  := Substr(cBarra,25,10)
cDig2    := DIGITO001( cParte2 )
cParte3  := Substr(cBarra,35,10)
cDig3    := DIGITO001( cParte3 )
cParte4  := cDigBarra
cParte5  := cFatorValor

cDigital := Transform(cParte1+cDig1,"@R 99999.99999")+" "+;
			Transform(cParte2+cDig2,"@R 99999.999999")+" "+;
			Transform(cParte3+cDig3,"@R 99999.999999")+" "+;
			cParte4+" "+cParte5
			
Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,cCart+cNosso+cDigNN)

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณDIGITO001 บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPara calculo da linha digitavel                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIGITO001(cVariavel)

Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
cValor:=AllTrim(STR(sumdig,12))
nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cValor,1,1))+1,12))+"0")
If nDezena > 99
	nDezena := VAL(ALLTRIM(STR(VAL(SUBSTR(cValor,1,1))+1,12)))
Endif	
auxi := nDezena - sumdig

If auxi >= 10
	auxi := 0
EndIf

Return(str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCALC_DB   บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo do digito do codigo de barras                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CALC_DB(cVariavel)

Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBOLBRAD   บAutor  ณMicrosiga           บ Data ณ  05/22/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ calcula o digito no NOSSO NUMERO                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIGNUMB(cEsteNum) 

Local cNUMBCO := STRZERO(VAL(cEsteNum),11)
Local cDIGITO := MODULO11("09"+cNUMBCO,2,7) 
Local nSoma := 0

IF cDIGITO == "0"
	nSOMA += 0*2 + 9*7
	FOR I:=1 TO 11
		IF I<6
			nSOMA += (7-I)*VAL(SUBSTR(cNUMBCO,I,1))
		ELSE
			nSOMA += (13-I)*VAL(SUBSTR(cNUMBCO,I,1))
		ENDIF
	NEXT	
	cDIGITO := IIF(MOD(nSOMA,11)==1,"P","0")
ENDIF

Return(cDIGITO)



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg,aPerg)                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aHelpPor := {}
Local aAreaAtual := GetArea()
Local aRegs := aPerg
Local i,j


dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Organiza o Grupo de Perguntas e Help ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
for i := 1 to Len(aRegs)
		aIns(aRegs[i],1)
		aIns(aRegs[i],1)
		aRegs[i,1]:=cPerg
		aRegs[i,2]:=StrZero(i,2)
next

For i:=1 to Len(aRegs)
	If !dbSeek(aRegs[i,1]+aRegs[i,2])
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
