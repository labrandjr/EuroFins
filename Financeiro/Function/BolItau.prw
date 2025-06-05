#include 'rwmake.ch'
#include 'ap5mail.ch'
#include 'topconn.ch'
#include 'FWPrintSetup.ch'
#include 'protheus.ch'

#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030


/*/{Protheus.doc} BolItau
IMPRESSAO DO BOLETO BANCO ITAU COM CODIGO DE BARRAS
@author Marcos Candido
@since 03/01/2018
/*/
User Function BolItau

LOCAL	aPergs := {}
PRIVATE lExec    := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''

Tamanho  := "M"
titulo   := "Impressão de Boleto com Código de Barras"
cDesc1   := "Este programa destina-se a impressão do Boleto com Código de Barras."
cDesc2   := "Especifico para o Banco Itau."
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
cPerg     := padr("BLTITAU",10)
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

Pergunte(cPerg,.t.)

//Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

If nLastKey == 27
	Set Filter to
	Return
Endif

//SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

cIndexName	:= Criatrab(Nil,.F.)
cIndexKey	:= "E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"

cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"' .And. E1_SALDO>0 .And. "
cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "' .And. E1_PREFIXO<='" + MV_PAR02 + "' .And. "
cFilter		+= "E1_NUM>='" + MV_PAR03 + "' .And. E1_NUM<='" + MV_PAR04 + "' .And. "
cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "' .And. E1_PARCELA<='" + MV_PAR06 + "' .And. "
cFilter		+= "E1_PORTADO>='" + MV_PAR07 + "' .And. E1_PORTADO<='" + MV_PAR08 + "' .And. "
cFilter		+= "E1_CLIENTE>='" + MV_PAR09 + "' .And. E1_CLIENTE<='" + MV_PAR11 + "' .And. "
cFilter		+= "E1_LOJA>='" + MV_PAR10 + "' .And. E1_LOJA<='"+MV_PAR12+"' .And. "
cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par13)+"' .and. DTOS(E1_EMISSAO)<='"+DTOS(mv_par14)+"' .And. "
cFilter		+= "DTOS(E1_VENCREA)>='"+DTOS(mv_par15)+"' .and. DTOS(E1_VENCREA)<='"+DTOS(mv_par16)+"' .And. "
cFilter		+= "!(SE1->E1_TIPO $ MV_CRNEG+MVRECANT+MVABATIM)"

IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
DbSelectArea("SE1")
#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
#ENDIF

dbGoTop()
While !Eof()
	RecLock("SE1",.F.)
	  SE1->E1_OK := Space(Len(SE1->E1_OK))
	MsUnlock()
	dbSkip()
Enddo

dbGoTop()

If Bof() .and. Eof()
	IW_MsgBox("Não há dados a serem exibidos. Verifique os parâmetros." , "Seleção de Títulos" , "ALERT")
Else
	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Títulos"
	@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
	@ 180,275 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
	@ 180,310 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
	ACTIVATE DIALOG oDlg CENTERED

	dbGoTop()
	If lExec
		Processa({|lEnd|MontaRel()})
	Endif
Endif

RetIndex("SE1")
Ferase(cIndexName+OrdBagExt())

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Microsiga             ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrio   ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaRel()
LOCAL oPrint
LOCAL nX := 0
Local cNroDoc :=  " "
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    								,; 	//[1]Nome da Empresa
						Alltrim(SM0->M0_ENDCOB)                            								,; 	//[2]Endereço
						AllTrim(SM0->M0_BAIRCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB	,;	//[3]Complemento
						"CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999")            					,;	//[4]CEP
						"PABX/FAX: "+SM0->M0_TEL                                                  		,;	//[5]Telefones
						"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                   		,;	//[6]CNPJ
						"I.E.: "+Transform(SM0->M0_INSC,"@R 999.999.999.999")}  							//[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
/* Fausto Costa 09/06/2015 - Ajuste conforme solicitação do Bruno*/
//Local aBolText     := {"Após vencimento, cobrar multa de 2,00% ao mês." , "Mora diária de R$ " , "Protestar após o 5º dia após o vencimento."}

Local aBolText     := {"Após vencimento, cobrar multa de R$ " , "Mora diária de R$ " , "Sujeito a protesto após o vencimento."}


LOCAL nI           := 1
LOCAL aCB_RN_NN    := {}
LOCAL nVlrAbat		:= 0

Private PixelX
Private PixelY


//oPrint:= TMSPrinter():New( "Boleto Laser" )
//oPrint:Setup()
//oPrint:SetPortrait() // ou SetLandscape()
//oPrint:StartPage()   // Inicia uma nova página
//oPrint:SetPaperSize(Val(GetProfString(GetPrinterSession(),"PAPERSIZE","1",.T.)))
//oPrint:SetPaperSize(9)

	//oPrint:= TMSPrinter():New(cArquivo)
	//oPrint:SetPortrait()		// Orientacao da impressao. Nesse caso: Retrato .  ou SetLandscape() --> Paisagem
	//oPrint:SetPaperSize(9)	// Folha A4

	oPrint:= FWMSPrinter():New("Boleto Itau")
	//oPrint:SetPortrait()
	//oPrint:SetPaperSize(9)
	//oPrint:SetMargin(30,70,60,60)  // nEsquerda, nSuperior, nDireita, nInferior
	oPrint:SetResolution(78)
	oPrint:SetPortrait()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(60,60,60,100)

	PixelX := oPrint:nLogPixelX()
	PixelY := oPrint:nLogPixelY()


cLogoBco := "LOGOITAU.BMP"
cLogoEmp := "MSMDILOGO.BMP"

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
		cBcoAg  := StrTran(Alltrim(SA6->A6_AGENCIA)+Alltrim(SA6->A6_DVAGE),"-","")
		cBcoCon := StrTran(StrTran(Alltrim(SA6->A6_NUMCON)+Alltrim(SA6->A6_DVCTA),"-",""),".","")
		aDadosBanco  := {SA6->A6_COD                       		,;	// [1]Numero do Banco
						 cLogoBco                    			,;	// [2]Nome do Banco (LOGO)
		                 Transform(cBcoAg,"@R 9999")			,;	// [3]Agência
	                     Transform(cBcoCon,"@R 99999-9")		,;	// [4]Conta Corrente
	                     "109"}				    					// [5]Codigo da Carteira

		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)

		If SA1->A1_ZZTPCOB <> 'D'

			If Empty(SA1->A1_ENDCOB)
				aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
				AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
				AllTrim(SA1->A1_MUN )                            ,; 		// [4]Cidade
				SA1->A1_EST                                      ,;    		// [5]Estado
				SA1->A1_CEP                                      ,;      	// [6]CEP
				SA1->A1_CGC										 ,; 		// [7]CGC
				iif(len(Alltrim(SA1->A1_CGC))==11,"F","J")		}  			// [8]PESSOA
			Else
				aDatSacado   := {AllTrim(SA1->A1_NOME)            	 ,;   	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
				AllTrim(SA1->A1_MUNC)	                             ,;   	// [4]Cidade
				SA1->A1_ESTC	                                     ,;   	// [5]Estado
				SA1->A1_CEPC                                        ,;   	// [6]CEP
				SA1->A1_CGC											 ,;		// [7]CGC
				iif(len(Alltrim(SA1->A1_CGC))==11,"F","J")		}  			// [8]PESSOA
			Endif

			dbSelectArea("SE1")
			/*
			//nVlrAbat  := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,SE1->E1_EMISSAO,SE1->E1_CLIENTE,SE1->E1_LOJA)
			//nVlrAbat  := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			//nValorTit  := SE1->E1_SALDO-nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC
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

			nValorTit := nValorTit - (nValIRRF + nValPIS + nValCOFI + nValCSLL)

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
			nValorTit := nValorTit - (nValIRRF + nValPIS + nValCOFI + nValCSLL)

			RestArea(aAreaSE1)

			cNroDoc := Right(Alltrim(SE1->E1_NUMBCO),9)
			cNroDoc := Substr(cNroDoc,1,8)
			If Empty(cNroDoc)
				cNroDoc := Strzero(VAL(NOSSONUM()),8)
				cConta  := Substr(cBcoCon,1,Len(AllTrim(cBcoCon))-1)
				nDvnn   := Modulo10(cBcoAg+cConta+aDadosBanco[5]+cNroDoc)
				RecLock("SE1",.F.)
			      SE1->E1_NUMBCO := cNroDoc+AllTrim(Str(nDvnn))
				MsUnlock()
				cNroDoc := Right(Alltrim(SE1->E1_NUMBCO),9)
				cNroDoc := Substr(cNroDoc,1,8)
			Endif

			//Monta codigo de barras
			aCB_RN_NN := Ret_cBarra(aDadosBanco[1], Alltrim(cNroDoc) , nValorTit , aDadosBanco[5] , cBcoAg , cBcoCon )

			dbSelectArea("SE1")
			nMora := 0
			If E1_PORCJUR == 0
				//nMora := NoRound(nValorTit*0.0007,2) //Utilizar 2,3% a.m.  Fausto Costa 09/06/2015 - Ajuste conforme solicitação do Bruno
				//nMora := NoRound(nValorTit*0.0019,2) //Utilizar 5,9% a.m.
				nMora := NoRound(nValorTit*0.0006666666,2) //Utilizar 2,0% a.m.
			Else
				nMora := NoRound(nValorTit*(E1_PORCJUR/100),2)
			Endif
			RecLock("SE1",.F.)
			Replace	E1_VALJUR	With	nMora
			MsUnlock()

			aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)		,;  // [1] Número do título
								E1_EMISSAO                          ,;  // [2] Data da emissão do título
								dDataBase                    		,;  // [3] Data da emissão do boleto
								E1_VENCTO                           ,;  // [4] Data do vencimento
								nValorTit              				,;  // [5] Valor do título
								cNroDoc                             ,;  // [6] Nosso número
								E1_PREFIXO                          ,;  // [7] Prefixo da NF
								E1_TIPO	                           	,;	// [8] Tipo do Titulo
								nMora}   								// [9] Mora diaria

			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

		EndIf

	Endif

	dbSelectArea("SE1")
	dbSkip()
	IncProc()

EndDo

oPrint:EndPage()     // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Microsiga             ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrio ³ IMPRESSAO DO BOLETO LASER                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0

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
oFont18n := TFont():New("Arial",9,18,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

nHPage := oPrint:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oPrint:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

/******************/
/* PRIMEIRA PARTE */
/******************/

nRow1 := 0

oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

oPrint:SayBitMap(nRow1   ,095,aDadosBanco[2],150,130)		// [2]Nome do Banco (LOGO)
oPrint:Say  (nRow1+0139,527,aDadosBanco[1]+"-7",oFont21 )	// [1]Numero do Banco
oPrint:Say  (nRow1+0140,1900,"Comprovante de Entrega",oFont10)
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say  (nRow1+0170,100 ,"Beneficiario",oFont8)
oPrint:Say  (nRow1+0220,100 ,aDadosEmp[1],oFont10)				//Nome + CNPJ

oPrint:Say  (nRow1+0170,1060,"Agência/Código Beneficiario",oFont8)
oPrint:Say  (nRow1+0220,1060,aDadosBanco[3]+"/"+aDadosBanco[4],oFont10)

oPrint:Say  (nRow1+0170,1510,"Nro.Documento",oFont8)
oPrint:Say  (nRow1+0220,1510,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0270,100 ,"Pagador",oFont8)
oPrint:Say  (nRow1+0320,100 ,aDatSacado[1],oFont10)				//Nome

oPrint:Say  (nRow1+0270,1060,"Vencimento",oFont8)
oPrint:Say  (nRow1+0320,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

oPrint:Say  (nRow1+0270,1510,"Valor do Documento",oFont8)
oPrint:Say  (nRow1+0320,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/título",oFont10)
oPrint:Say  (nRow1+0440,0100,"com as características acima.",oFont10)

oPrint:SayBitMap(nRow1+0370,630,cLogoEmp,370,095)	// LOGO DA EMPRESA

oPrint:Say  (nRow1+0375,1060,"Data",oFont8)
oPrint:Say  (nRow1+0375,1410,"Assinatura",oFont8)
oPrint:Say  (nRow1+0475,1060,"Data",oFont8)
oPrint:Say  (nRow1+0475,1410,"Entregador",oFont8)

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say  (nRow1+0185,1910,"(  )Mudou-se"                                	,oFont8)
oPrint:Say  (nRow1+0225,1910,"(  )Ausente"                                    ,oFont8)
oPrint:Say  (nRow1+0265,1910,"(  )Não existe nº indicado"                  	,oFont8)
oPrint:Say  (nRow1+0305,1910,"(  )Recusado"                                	,oFont8)
oPrint:Say  (nRow1+0345,1910,"(  )Não procurado"                              ,oFont8)
oPrint:Say  (nRow1+0385,1910,"(  )Endereço insuficiente"                  	,oFont8)
oPrint:Say  (nRow1+0425,1910,"(  )Desconhecido"                            	,oFont8)
oPrint:Say  (nRow1+0465,1910,"(  )Falecido"                                   ,oFont8)
oPrint:Say  (nRow1+0505,1910,"(  )Outros(anotar no verso)"                  	,oFont8)


/*****************/
/* SEGUNDA PARTE */
/*****************/

nRow2 := 180

//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(nRow2+0540, nI,nRow2+0540, nI+30)
Next nI

oPrint:SayBitMap(nRow2+0560,095,aDadosBanco[2],150,130)	// [2]Nome do Banco (LOGO)
oPrint:Say  (nRow2+0699,527,aDadosBanco[1]+"-7",oFont21 )	// [1]Numero do Banco

oPrint:Say  (nRow2+0700,1800,"Recibo do Pagador",oFont10)

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

oPrint:Say  (nRow2+0730,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow2+0755,400 ,"Preferencialmente nas agências Itaú,",oFont10)
oPrint:Say  (nRow2+0785,400 ,"ou até o vencimento em qualquer banco.",oFont10)

oPrint:Say  (nRow2+0730,1810,"Vencimento"                                     ,oFont8)
cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0785,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0830,100 ,"Beneficiario"                                        ,oFont8)
oPrint:Say  (nRow2+0885,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow2+0830,1810,"Agência/Código Beneficiario",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4])
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0885,nCol+090,cString,oFont11c)

oPrint:Say  (nRow2+0930,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (nRow2+0970,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

oPrint:Say  (nRow2+0930,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow2+0970,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0930,1005,"Espécie Doc."                                   ,oFont8)
//oPrint:Say  (nRow2+0940,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo
oPrint:Say  (nRow2+0970,1050,"DM" 									,oFont10) //Tipo do Titulo

oPrint:Say  (nRow2+0930,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow2+0970,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow2+0930,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow2+0970,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

oPrint:Say  (nRow2+0930,1810,"Cart/Nosso Número"                                   ,oFont8)
cString := Alltrim(aCB_RN_NN[3])
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0970,nCol+20,Transform(cString,"@R XXX/XXXXXXXX-X"),oFont11c)
oPrint:Say  (nRow2+1000,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow2+1000,380 ,"CIP"                                     ,oFont8)
oPrint:Say  (nRow2+1040,400 ,"000"                                  	,oFont10)

oPrint:Say  (nRow2+1000,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow2+1040,555 ,aDadosBanco[5]                                  	,oFont10)

oPrint:Say  (nRow2+1000,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow2+1040,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow2+1000,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow2+1000,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow2+1000,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+1040,nCol,cString ,oFont11c)

oPrint:Say  (nRow2+1075,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiario)",oFont8)
//oPrint:Say  (nRow2+1120,100 ,aBolText[1],oFont10)
oPrint:Say  (nRow2+1120,100 ,aBolText[1]+Transform(NoRound(aDadosTit[5]*(2/100),2),"@E 999,999.99"),oFont10)
oPrint:Say  (nRow2+1160,100 ,aBolText[2]+Transform(aDadosTit[9],"@E 999,999.99"),oFont10)
// Imprime mensagem especial caso seja Carrefour
If Substr(aDatSacado[7],1,8)= '45543915'
	oPrint:Say  (nRow2+1200,100 ,"CNPJ DO FORNECEDOR: "+StrTran(aDadosEmp[6],"CNPJ: ",""),oFont10)
	oPrint:Say  (nRow2+1240,100 ,"CNPJ DE RECEBIMENTO GRUPO CARRREFOUR: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)
	oPrint:Say  (nRow2+1280,100 ,"NUMERO DA NOTA FISCAL: "+aDadosTit[1],oFont10)
	oPrint:Say  (nRow2+1320,100 ,aBolText[3],oFont10)
Else
	oPrint:Say  (nRow2+1200,100 ,aBolText[3],oFont10)
Endif

oPrint:SayBitMap(nRow2+1120,1300,cLogoEmp,370,095)	// LOGO DA EMPRESA

oPrint:Say  (nRow2+1070,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow2+1140,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow2+1210,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow2+1280,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow2+1350,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow2+1425,100 ,"Pagador"                                         ,oFont8)
oPrint:Say  (nRow2+1465,300 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
oPrint:Say  (nRow2+1505,300 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow2+1545,300 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

if aDatSacado[8] = "J"
	oPrint:Say  (nRow2+1585,300 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow2+1585,300 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow2+1625,100 ,"Sacador/Avalista",oFont8)
oPrint:Say  (nRow2+1670,1500,"Autenticação Mecânica",oFont8)

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

nRow3 := 200

//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1820, nI, nRow3+1820, nI+30)
Next nI

oPrint:SayBitMap(nRow3+1850,095,aDadosBanco[2],150,130)		//  [2]Nome do Banco (LOGO)
oPrint:Say  (nRow3+1989,527,aDadosBanco[1]+"-7",oFont21 )		// 	[1]Numero do Banco
oPrint:Say  (nRow3+1980,755,aCB_RN_NN[2],oFont18n)			//	Linha Digitavel do Codigo de Barras

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

oPrint:Say  (nRow3+2015,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow3+2040,400 ,"Preferencialmente nas agências Itaú,",oFont10)
oPrint:Say  (nRow3+2070,400 ,"ou até o vencimento em qualquer banco.",oFont10)

oPrint:Say  (nRow3+2015,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2055,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2120,100 ,"Beneficiario",oFont8)
oPrint:Say  (nRow3+2175,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+2120,1810,"Agência/Código Beneficiario",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4])
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2175,nCol+090,cString ,oFont11c)

oPrint:Say  (nRow3+2220,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say (nRow3+2260,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

oPrint:Say  (nRow3+2220,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow3+2260,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2220,1005,"Espécie Doc."                                   ,oFont8)
//oPrint:Say  (nRow3+2230,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo
oPrint:Say  (nRow3+2260,1050,"DM"									,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+2220,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow3+2260,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow3+2220,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow3+2260,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao

oPrint:Say  (nRow3+2220,1810,"Cart/Nosso Número"                                   ,oFont8)
cString := Alltrim(aCB_RN_NN[3])
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2260,nCol+20,Transform(cString,"@R XXX/XXXXXXXX-X"),oFont11c)

oPrint:Say  (nRow3+2290,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow3+2290,380 ,"CIP"                                     ,oFont8)
oPrint:Say  (nRow3+2330,400 ,"000"                                  	,oFont10)

oPrint:Say  (nRow3+2290,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow3+2330,555 ,aDadosBanco[5]                                  	,oFont10)

oPrint:Say  (nRow3+2290,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow3+2330,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow3+2290,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow3+2290,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow3+2290,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2330,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2355,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiario)",oFont8)
//oPrint:Say  (nRow3+2400,100 ,aBolText[1],oFont10)
oPrint:Say  (nRow3+2400,100 ,aBolText[1]+Transform(NoRound(aDadosTit[5]*(2/100),2),"@E 999,999.99"),oFont10)
oPrint:Say  (nRow3+2440,100 ,aBolText[2]+Transform(aDadosTit[9],"@E 999,999.99"),oFont10)
// Imprime mensagem especial caso seja Carrefour
//If Substr(aDatSacado[7],1,8)= '45543915'
//	oPrint:Say  (nRow3+2480,100 ,"CNPJ DO FORNECEDOR: "+StrTran(aDadosEmp[6],"CNPJ: ",""),oFont10)
//	oPrint:Say  (nRow3+2520,100 ,"CNPJ DE RECEBIMENTO GRUPO CARRREFOUR: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)
//	oPrint:Say  (nRow3+2560,100 ,"NUMERO DA NOTA FISCAL: "+aDadosTit[1],oFont10)
//	oPrint:Say  (nRow3+2600,100 ,aBolText[3],oFont10)
//Else
	oPrint:Say  (nRow3+2480,100 ,aBolText[3],oFont10)
//Endif

oPrint:Say  (nRow3+2355,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+2430,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow3+2500,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+2570,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow3+2640,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+2705,100 ,"Pagador"                                         ,oFont8)
oPrint:Say  (nRow3+2730,300 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2730,1600,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow3+2730,1600,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow3+2760,300 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow3+2790,300 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

oPrint:Say  (nRow3+2830,100 ,"Sacador/Avalista"                               ,oFont8)
oPrint:Say  (nRow3+2865,1500,"Autenticação Mecânica - Ficha de Compensação"                        ,oFont8)

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

//MSBAR3("INT25",26,0.8,aCB_RN_NN[1],oPrint  ,.F. ,Nil,Nil ,0.025,1.20,Nil,Nil,"A",.F.)
oPrint:FWMSBAR("INT25" /*cTypeBar*/,70/*nRow*/ ,1.5/*nCol*/, aCB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.025/*nWidth*/,1.20/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
oPrint:EndPage() // Finaliza a página

Return Nil




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDados  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera SE1                        					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ret_cBarra(cCodBanco,cNroDoc,nValor,cCart,cBcoAg,cBcoCon)

LOCAL cValorFinal := StrZero(nValor*100,10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator        := ALLTRIM(STR(SE1->E1_VENCTO - IIF(DTOS(SE1->E1_VENCTO)>=GetMv("CL_NVDTBL"),CtoD(GetMv("CL_DT1000")),CtoD("07/10/1997"))))

cConta := Substr(cBcoCon,1,Len(AllTrim(cBcoCon))-1)
cDacCC := Substr(cBcoCon,Len(AllTrim(cBcoCon)),1)

//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
cS    := cBcoAg + cConta + cCart + cNroDoc
nDvnn := Modulo10(cS) // digito verificador Agencia + Conta + Carteira + Nosso Num
cNN   := cCart + cNroDoc + AllTrim(Str(nDvnn))

//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cS    := cCodBanco + "9" + cFator +  cValorFinal + cNN + cBcoAg + cConta + cDacCC + '000'
nDvcb := Modulo11(cS)
cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS    := cCodBanco + "9" + cCart + SubStr(cNroDoc,1,2)
nDv   := Modulo10(cS)
cRN   := Transform(cS+AllTrim(Str(nDv)),"@R 99999.99999") + ' '

// 	CAMPO 2:
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS  := Substr(cNroDoc,3,6) + Alltrim(Str(nDvnn))+ Subs(cBcoAg,1,3)
nDv := Modulo10(cS)
cRN += Transform(cS+AllTrim(Str(nDv)),"@R 99999.999999") + ' '

// 	CAMPO 3:
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS    := Subs(cBcoAg,4,1) + cBcoCon + '000'
nDv   := Modulo10(cS)
cRN   += Transform(cS+AllTrim(Str(nDv)),"@R 99999.999999") + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   += AllTrim(Str(nDvcb)) + ' '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   += cFator + cValorFinal

Return({cCB,cRN,cNN})



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo10 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrio ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrio ³ IMPRESSAO DO BOLETO LASER DO ITAU COM CODIGO DE BARRAS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11(cData)
LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
Endif
Return(D)


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funo    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrio ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ			:= 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
			"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
			"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
			"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
			"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
			"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
			"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
			"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			 Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif

	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
 		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
 	Endif

	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."

		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif

		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif

		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

Return
