#include "protheus.ch"
#include "rwmake.ch"

#DEFINE __cCarteira "109"
#DEFINE __cMoeda    "9"
/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |BOLITAU   |Autor  |Felipe Zago Zechini | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Impressao de boleto Itau                                    |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | Transilva LOG                                              |
+-----------+------------------------------------------------------------+
*/
User Function BLTITAU(cNomeParam, cNota, cPrefixo, cCliTit, cLojaTit, cTipoTit,lDanfe, cNotaDe, cNotaAte, lMsgConfirma)//RC - 13/01/16 - Ajuste para imprimir os boletos diretamente após a impressão danfe
	Local aPergs 		:= {}
	local nMV	       	:= 0//rc
	local aMvPar  	   	:= {}//rc
	local aArea		   	:= lj7getarea({"SA1","SF2","SA6","SEE","SC5","SE1"}) 

	Private lExec    	:= .F.
	Private cIndexName 	:= ''
	Private cIndexKey  	:= ''
	Private cFilter    	:= ''
	private cNomeArq	:= cNomeParam

	DEFAULT cNota := Space(09)
	DEFAULT lDanfe := .F. //RC - 13/01/16 - Ajuste para imprimir os boletos diretamente após a impressão danfe
	DEFAULT cNotaDe := space(tamsx3("E1_NUM")[1]) //RC - 13/01/16 - Ajuste para imprimir os boletos diretamente após a impressão danfe
	DEFAULT cNotaAte := space(tamsx3("E1_NUM")[1]) //RC - 13/01/16 - Ajuste para imprimir os boletos diretamente após a impressão danfe
	default lMsgConfirma := .T.

	//rc - salva os MV_PAR padroes
	For nMv := 1 To 40
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
	Next nMv
	//--

	Tamanho  := "M"
	titulo   := "Impressao de Boleto com Codigo de Barras"
	cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
	cDesc2   := ""
	cDesc3   := ""
	cString  := "SE1"
	wnrel    := "BOLETO"
	lEnd     := .F.
	cPergBl     := Alltrim(Padr("BLTITGK",10))
	aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	nLastKey := 0

	cNf	:= cNota

	dbSelectArea("SE1")

	PutSx1( cPergBl   ,"01","De Prefixo"	           ,"","","mv_ch1","C",3,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"02","Ate Prefixo"	           ,"","","mv_ch2","C",3,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"03","De Numero"		       ,"","","mv_ch3","C",9,0,0,"G","","SE1","","","MV_PAR03","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"04","Ate Numero"	           ,"","","mv_ch4","C",9,0,0,"G","","SE1","","","MV_PAR04","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"05","De Parcela"	           ,"","","mv_ch5","C",1,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"06","Ate Parcela"	           ,"","","mv_ch6","C",1,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"07","De Portador"	           ,"","","mv_ch7","C",3,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"08","Ate Portador" 	       ,"","","mv_ch8","C",3,0,0,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"09","De Cliente"	           ,"","","mv_ch9","C",6,0,0,"G","","SA1","","","MV_PAR09","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"10","Ate Cliente"	           ,"","","mv_cha","C",6,0,0,"G","","SA1","","","MV_PAR10","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"11","De Loja"		           ,"","","mv_chb","C",2,0,0,"G","","","","","MV_PAR11","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"12","Ate Loja"		       ,"","","mv_chc","C",2,0,0,"G","","","","","MV_PAR12","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"13","De Emissao"	           ,"","","mv_chd","D",8,0,0,"G","","","","","MV_PAR13","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"14","Ate Emissao"	           ,"","","mv_che","D",8,0,0,"G","","","","","MV_PAR14","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"15","De Vencimento"	       ,"","","mv_chf","D",8,0,0,"G","","","","","MV_PAR15","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"16","Ate Vencimento"         ,"","","mv_chg","D",8,0,0,"G","","","","","MV_PAR16","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"17","Do Bordero"	           ,"","","mv_chh","C",6,0,0,"G","","","","","MV_PAR17","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"18","Ate Bordero"            ,"","","mv_chi","C",6,0,0,"G","","","","","MV_PAR18","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"19","Banco     "             ,"","","mv_chj","C",3,0,0,"G","","SA6","","","MV_PAR19","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"20","Agencia    "            ,"","","mv_chl","C",5,0,0,"G","","","","","MV_PAR20","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1( cPergBl   ,"21","Conta      "            ,"","","mv_chm","C",10,0,0,"G","","","","","MV_PAR21","","","","","","","","","","","","","","","","",{},{},{})

	//RC - 13/01/16 - Ajuste para imprimir os boletos diretamente após a impressão danfe
	if !lDanfe
		If !Pergunte(cPergBl,.T.)
			Return
		Endif
	else
		DbSelectArea("SF2")
		DbSetOrder(1)
		SF2->(DbSeek(xFilial("SF2")+padr(cNotaDe,tamsx3("E1_NUM")[1])+padr("1",tamsx3("E1_PREFIXO")[1])))

		DbSelectArea("SA1")
		DbSetOrder(1)
		SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
				
		if(lMsgConfirma .AND. !MsgYesNo("Deseja imprimir / enviar e-mail do(s) boleto(s) para esta(s) Nota(s) ?"))
			return
		endif

		MV_PAR01 := ""
		MV_PAR02 := replicate("Z",tamSX3("E1_PREFIXO")[1])
		MV_PAR03 := padr(cNotaDe,tamsx3("E1_NUM")[1])
		MV_PAR04 := padr(cNotaAte,tamsx3("E1_NUM")[1])
		MV_PAR05 := ""
		MV_PAR06 := replicate("Z",tamSX3("E1_PARCELA")[1])
		MV_PAR07 := ""
		MV_PAR08 := replicate("Z",tamSX3("E1_PORTADO")[1])
		MV_PAR09 := ""
		MV_PAR10 := replicate("Z",tamSX3("E1_CLIENTE")[1])
		MV_PAR11 := ""
		MV_PAR12 := replicate("Z",tamSX3("E1_LOJA")[1])
		MV_PAR13 := ctod("01/01/2000")
		MV_PAR14 := ctod("31/12/2049")
		MV_PAR15 := ctod("01/01/2000")
		MV_PAR16 := ctod("31/12/2049")
		MV_PAR17 := ""
		MV_PAR18 := replicate("Z",tamSX3("E1_NUMBOR")[1])
		//rc - retirado em 12/08/16
		//MV_PAR19 := "341"
		//MV_PAR20 := "0263 "
		//		MV_PAR21 := "0000594632"
		//MV_PAR21 := "0000821365"		
		//--
	endif
	//--

	If Empty(cNF)

		cIndexName	:= Criatrab(Nil,.F.)
		cIndexKey	:= "E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
		cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
		cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And."
		cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And.E1_NUM<='" + MV_PAR04 + "'.And."
		cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "' "
		//cFilter		+= "E1_CLIENTE>='" + MV_PAR09 + "'.And.E1_CLIENTE<='" + MV_PAR10 + "'.And."
		//cFilter		+= "E1_LOJA>='" + MV_PAR11 + "'.And.E1_LOJA<='"+MV_PAR12+"'.And."
		//cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par13)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par14)+"'.And."
		//cFilter		+= "DTOS(E1_VENCREA)>='"+DTOS(mv_par15)+"'.and.DTOS(E1_VENCREA)<='"+DTOS(mv_par16)+"'.And."
		//cFilter		+= "E1_NUMBOR>='" + MV_PAR17 + "'.And.E1_NUMBOR<='" + MV_PAR18 + "'.And."
		//if(!lDanfe)
		//	cFilter		+= "E1_PORTADO = '"+ mv_par19 +"' .AND. "
		//endIf
		//cFilter		+= "!(E1_TIPO$MVABATIM)"
		//If Empty(MV_PAR19) .and. !lDanfe
		//	cFilter		+= ".And. E1_PORTADO>='" + MV_PAR07 + "'.And.E1_PORTADO<='" + MV_PAR08 + "' "
		//	cFilter		+= ".And. E1_PORTADO<>'   '"
		//Endif
	Else
		cFilter += " E1_FILIAL	== '"+ xFilial("SE1") 	+"' .AND. 	"
		cFilter += " E1_NUM 	== '"+ cNF 				+"' .AND. 	"
		cFilter	+= " E1_PREFIXO == '"+ cPrefixo 		+"'	.AND. 	"	
		cFilter += " E1_CLIENTE	== '"+ cCliTit 		 	+"' .AND. 	"
		cFilter += " E1_LOJA	== '"+ cLojaTit 	 	+"' .AND. 	"		
		cFilter += " E1_TIPO	== '"+ cTipoTit 		+"' .AND. 	"
		cFilter += " E1_SALDO 	>  0 					 			"			
	Endif
	
	//Aviso(FunDesc(), cFilter, {"OK"}, 3, FunDesc())

	/*
	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	DbSelectArea("SE1")
	#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF
	dbGoTop()
	*/

	If Empty(cNF) .and. !lDanfe //RC - 13/01/16 - Ajuste para imprimir os boletos diretamente após a impressão danfe

		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
		@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
		@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
		@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
		ACTIVATE DIALOG oDlg CENTERED

		dbGoTop()
	Else
		lExec := .t.
	Endif

	If lExec
		Processa({|lEnd|MontaRel(lDanfe, cNota, cPrefixo, cCliTit, cLojaTit)})//RC - 13/01/16 - Ajuste para imprimir os boletos diretamente após a impressão danfe
	Endif

	/*
	RetIndex("SE1")
	
	Ferase(cIndexName+OrdBagExt())
	*/

	//rc - restaura os MV_PAR padroes
	For nMv := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv
	
	lj7restarea(aArea)

Return

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |BOLITAU   |Autor  |Microsiga           | Data |  11/21/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |                                                            |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | AP                                                         |
+-----------+------------------------------------------------------------+
*/
Static Function MontaRel(lDanfe, cNota, cPrefixo, cCliTit, cLojaTit)
	Local oPrint
	Local nX		:= 0
	Local cNroDoc 	:= " "
	Local aDadosEmp    := {	SM0->M0_NOMECOM                                    ,;//[1]Nome da Empresa
	SM0->M0_ENDCOB                                     ,;                        //[2]Endereço
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB ,; //[3]Complemento
	"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
	"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
	"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ;     //[6]
	Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
	Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
	Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

	Local aDadosTit   := {}
	Local aDadosBanco := {}
	Local aDatSacado  := {}
	Local aBolText    := {	"APOS O VENCIMENTO COBRAR MORA DE R$....... ",;								
							"",;
							"AO DIA",;
							"Não receber sem juros e multa após o vencimento.",;
							"Não conceder descontos.",;
							"Sujeito a negativação após vencimento",;
							"Efetuar o pagamento somente através desse boleto e na rede bancaria."}

	Local nI          := 1
	Local aCB_RN_NN   := {}
	Local nVlrAbat	  := 0

	//RC - 14/01/16 - Ajuste para geração de PDF
	Local lAdjustToLegacy := .T. 
	Local lDisableSetup   := .T.	
	local cDirSrv 		  := "\cobranca\boletos\"
	local cDirArq 		  := cDirSrv	
	local cChaveImpr	  := ""
	local lImprimiu		  := .F.
	local cEmailTo		  := ""
	local cEmailTst		  := SuperGetMv("ZZ_MLTSBI", .T., "fabio@geekercompany.com;luciano.savio999@gmail.com")
	local cEmailBcc			:= ""
	local cTitulo			:= "Financeiro Braswell - Boletos"
	local cMsgPad			:= ""
	local cMensagem			:= ""
	local cAnexo			:= ""
	local lMsg				:= .F.
	local cSender			:= ""
	local cArq				:= ""
	local lErroEmail		:= .F.
	local cTpNFTit			:= SuperGetMv("ZZ_TPWFVC", .F., "'NF'")
	//--

	Private cStartPath       := GetSrvProfString("Startpath","")
	Private nPDesconto		:= 0//Alterado rC Renato Castro em 15/03/16
	Private nVDesconto		:= 0//Alterado rC Renato Castro em 15/03/16
	Private nVlrPago		:= 0//Alterado rC Renato Castro em 15/03/16

	default lDanfe := .F.

	if !ExistDir("c:\temp")
		MakeDir("c:\temp")
	endif

	if !ExistDir(cDirArq)
		MakeDir(cDirArq)
	endif

	if !ExistDir(cDirSrv)
		MakeDir(cDirSrv)
	endif

	//RC - Alterações referentes ao envio do boleto por e-mail
	cMsgPad := "Segue em anexo o(s) boleto(s) da NF-e n° XXXXXX emitida em YYYYYY."+CRLF
	cMsgPad += "Estaremos a sua disposição caso necessite de mais informações."+CRLF+CRLF
	cMsgPad += "Cordialmente" +CRLF+CRLF
	cMsgPad += "BRASWELL PAPEL E CELULOSE LTDA"

	if !lDanfe		
		oPrint:= FWMSPrinter():New(cNomeArq, 6, lAdjustToLegacy, , lDisableSetup)
		oPrint:SetPortrait() // ou SetLandscape()
		oPrint:SetPaperSize(DMPAPER_A4) 
		oPrint:cPathPDF := cDirArq 
		oPrint:lViewPDF := .T.
		
		cMsgPad := "Segue em anexo o(s) boleto(s) emitido(s) em YYYYYY."+CRLF
		cMsgPad += "Estaremos a sua disposição caso necessite de mais informações."+CRLF+CRLF
		cMsgPad += "Cordialmente" +CRLF+CRLF
		cMsgPad += "BRASWELL PAPEL E CELULOSE LTDA"
	endif
	//--

	DbGoTop()
	SE1->(DbSetOrder(2))
	if(	SE1->(DbSeek( 	PadR( xFilial("SE1")	, TamSx3("E1_FILIAL"	)[1]) +;
						PadR( cCliTit			, TamSx3("E1_CLIENTE"	)[1]) +; 
						PadR( cLojaTit			, TamSx3("E1_LOJA"		)[1]) +;
						PadR( cPrefixo			, TamSx3("E1_PREFIXO"	)[1]) +;
						PadR( cNota 			, TamSx3("E1_NUM"		)[1]) 	)))
						
		Do While SE1->(!EOF() .AND. Alltrim(SE1->E1_CLIENTE)	== Alltrim(cCliTit)  .AND.; 
									Alltrim(SE1->E1_LOJA) 		== Alltrim(cLojaTit) .AND.; 
									Alltrim(SE1->E1_PREFIXO) 	== Alltrim(cPrefixo) .AND.; 
									Alltrim(SE1->E1_NUM) 		== Alltrim(cNota) )

			if(Alltrim(SE1->E1_TIPO) $ cTpNFTit)

				if !lDanfe//RC - 13/01/16 - Ajuste para imprimir os boletos diretamente após a impressão danfe
					If Marked("E1_OK")
						If !empty(SC5->C5_CLIENTE+SC5->C5_LOJACLI).and.(SC5->C5_FILIAL+SC5->C5_NUM==SE1->E1_FILIAL+SE1->E1_PEDIDO)
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.)
						Else
							//Posiciona o SA1 (Cliente)
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
						Endif
						
						MV_PAR19 := SE1->E1_PORTADO
						MV_PAR20 := SE1->E1_AGEDEP
						MV_PAR21 := SE1->E1_CONTA
						//--
						If Empty(MV_PAR19)
							//Posiciona o SA6 (Bancos)
							DbSelectArea("SA6")
							DbSetOrder(1)
							DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)

							//Posiciona na Arq de Parametros CNAB
							DbSelectArea("SEE")
							DbSetOrder(1)
							DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
						Else
							//Posiciona o SA6 (Bancos)
							DbSelectArea("SA6")
							DbSetOrder(1)
							DbSeek(xFilial("SA6")+MV_PAR19+MV_PAR20+MV_PAR21,.T.)

							//Posiciona na Arq de Parametros CNAB
							DbSelectArea("SEE")
							DbSetOrder(1)
							DbSeek(xFilial("SEE")+MV_PAR19+MV_PAR20+MV_PAR21,.T.)
						Endif
						
						// Luiz Alberto - 06-02-2012 - Athena
						// Efetua o Preenchimento do Campo E1_NUMBCO com
						// o Numero Sequencial da Tabela E1_FAIXATU.

						DbSelectArea("SE1")
						If Empty(SE1->E1_NUMBCO)
							NossoNum()
						Endif
						//RC
						//Reclock("SE1",.F.)
						//SE1->E1_CONTA 	:= SA6->A6_NUMCON
						//SE1->E1_ZZDVNN 	:= aCB_RN_NN[4]
						//SE1->(msunlock())
						//--

						aAdd(aDadosBanco, Alltrim(SA6->A6_COD))     // [1]Numero do Banco
						aAdd(aDadosBanco, Alltrim("BANCO ITAU"))    // [2]Nome do Banco
						aAdd(aDadosBanco, Left(Alltrim(SA6->A6_AGENCIA),4)) // [3]Agência
						aAdd(aDadosBanco, Left(Alltrim(SA6->A6_NUMCON),9))  // [4]Conta Corrente
						aAdd(aDadosBanco, Right(Alltrim(SA6->A6_NUMCON),1))  // [5]Dígito da conta corrente
						aAdd(aDadosBanco, Alltrim(__cCarteira))     // [6]Codigo da Carteira


						//Alterado por Raul em 31/08/2012 - Pegar End. Normal pq não trabalhamos c/ endereço de cobrança
						//é um cadastro para cada objetivo. pegar do cliente cobrança do orçamento/pedido
						aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
						AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
						AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
						AllTrim(SA1->A1_MUN )                            ,;  		// [4]Cidade
						SA1->A1_EST                                      ,;     	// [5]Estado
						SA1->A1_CEP                                      ,;      	// [6]CEP
						SA1->A1_CGC										 ,;         // [7]CGC
						SA1->A1_PESSOA									  }         // [8]PESSOA

						nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
						nPDesconto := SE1->E1_DESCFIN//Alterado rC Renato Castro em 15/03/16
						nVDesconto := (SE1->E1_VALOR-nVlrAbat)*(nPDesconto/100)//Alterado rC Renato Castro em 15/03/16
						/*
						--------------------------------------------------------------
						Parte do Nosso Numero. Sao 8 digitos para identificar o titulo
						--------------------------------------------------------------
						*/
						cNroDoc	:= StrZero(	Val(Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)),8)
						/*
						----------------------
						Monta codigo de barras
						----------------------
						*/

						_nVlrAbat   := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
						nSaldo		:= E1_VALOR - E1_IRRF - E1_COFINS - E1_PIS - E1_CSLL

						alert(cValToChar(nSaldo))

						//nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase, ;
						//dDataBase, SE1->E1_LOJA )//Alterado Renato Castro em 21/06/16

						/*aCB_RN_NN := fLinhaDig(aDadosBanco[1]      ,; // Numero do Banco
						__cMoeda            ,; // Codigo da Moeda
						aDadosBanco[6]      ,; // Codigo da Carteira
						aDadosBanco[3]      ,; // Codigo da Agencia
						aDadosBanco[4]      ,; // Codigo da Conta
						aDadosBanco[5]      ,; // DV da Conta
						(E1_VALOR-nVlrAbat) ,; // Valor do Titulo
						E1_VENCREA          ,; // Data de Vencimento do Titulo
						cNroDoc              ) // Numero do Documento no Contas a Receber*///Alterado Renato Castro em 21/06/16

						aCB_RN_NN := fLinhaDig(aDadosBanco[1]      ,; // Numero do Banco
						__cMoeda            ,; // Codigo da Moeda
						aDadosBanco[6]      ,; // Codigo da Carteira
						aDadosBanco[3]      ,; // Codigo da Agencia
						aDadosBanco[4]      ,; // Codigo da Conta
						aDadosBanco[5]      ,; // DV da Conta
						nSaldo				,; // Valor do Titulo
						E1_VENCREA          ,; // Data de Vencimento do Titulo
						cNroDoc              ) // Numero do Documento no Contas a Receber

						/*nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase, ;
						dDataBase, SE1->E1_LOJA )*///Alterado Renato Castro em 21/06/16

						aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
						E1_EMISSAO                          ,;  // [2] Data da emissão do título
						dDataBase                    		,;  // [3] Data da emissão do boleto
						E1_VENCREA                           ,;  // [4] Data do vencimento
						nSaldo              				 ,;  // [5] Valor do título
						aCB_RN_NN[3]                        ,;  // [6] Nosso número (Ver fórmula para calculo)
						E1_PREFIXO                          ,;  // [7] Prefixo da NF
						E1_TIPO	                           	,; 	// [8] Tipo do Titulo
						E1_VALJUR						} 	// [9] Valor de juros   
						
						
						if(Empty(cEmailTst))
							cEmailTo := alltrim(posicione("SA1",1,xfilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_EMAIL"))
						else
							cEmailTo := cEmailTst 
						endIf
										
						Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
						
						//Reclock("SE1",.F.)
						//SE1->E1_ZZDVNN 	:= aCB_RN_NN[4]
						//SE1->(msunlock())
						

						nX := nX + 1

					EndIf
				else
					//Posiciona o SA1 (Cliente)
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
					//if posicione("SA1",1,xfilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_BLEMAIL") == "1" //RC - Só imprime / envia boleto para clientes parametrizados - retirado em 12/08/16
					//if SA1->A1_BLEMAIL == "1" //RC - Só imprime / envia boleto para clientes parametrizados
						//rc - adicionado em 12/08/16				
						MV_PAR19 := SE1->E1_PORTADO
						MV_PAR20 := SE1->E1_AGEDEP
						MV_PAR21 := SE1->E1_CONTA
						//--
						If Empty(MV_PAR19)
							//Posiciona o SA6 (Bancos)
							DbSelectArea("SA6")
							DbSetOrder(1)
							DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)

							//Posiciona na Arq de Parametros CNAB
							DbSelectArea("SEE")
							DbSetOrder(1)
							DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
						Else
							//Posiciona o SA6 (Bancos)
							DbSelectArea("SA6")
							DbSetOrder(1)
							DbSeek(xFilial("SA6")+MV_PAR19+MV_PAR20+MV_PAR21,.T.)

							//Posiciona na Arq de Parametros CNAB
							DbSelectArea("SEE")
							DbSetOrder(1)
							DbSeek(xFilial("SEE")+MV_PAR19+MV_PAR20+MV_PAR21,.T.)
						Endif

						//inserido por raul em 28/08/12
						//posiciona no pedido
						DbSelectArea("SC5")
						DbSetOrder(1)
						DbSeek(xFilial("SC5")+SE1->E1_PEDIDO,.T.)

						If !empty(SC5->C5_CLIENTE+SC5->C5_LOJACLI).and.(SC5->C5_FILIAL+SC5->C5_NUM==SE1->E1_FILIAL+SE1->E1_PEDIDO)
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.)
						Else
							//Posiciona o SA1 (Cliente)
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
						Endif
						// Luiz Alberto - 06-02-2012 - Athena
						// Efetua o Preenchimento do Campo E1_NUMBCO com
						// o Numero Sequencial da Tabela E1_FAIXATU.

						DbSelectArea("SE1")
						If Empty(SE1->E1_NUMBCO)
							NossoNum()
						Endif
						//RC
						//Reclock("SE1",.F.)
						//SE1->E1_CONTA 	:= SA6->A6_NUMCON
						//SE1->E1_ZZDVNN 	:= aCB_RN_NN[4]
						//SE1->(msunlock())
						//--

						aAdd(aDadosBanco, Alltrim(SA6->A6_COD))     // [1]Numero do Banco
						aAdd(aDadosBanco, Alltrim("BANCO ITAU"))    // [2]Nome do Banco
						aAdd(aDadosBanco, Left(Alltrim(SA6->A6_AGENCIA),4)) // [3]Agência
						aAdd(aDadosBanco, Left(Alltrim(SA6->A6_NUMCON),9))  // [4]Conta Corrente
						aAdd(aDadosBanco, Right(Alltrim(SA6->A6_NUMCON),1))  // [5]Dígito da conta corrente
						aAdd(aDadosBanco, Alltrim(__cCarteira))     // [6]Codigo da Carteira


						//Alterado por Raul em 31/08/2012 - Pegar End. Normal pq não trabalhamos c/ endereço de cobrança
						//é um cadastro para cada objetivo. pegar do cliente cobrança do orçamento/pedido
						aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
						AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
						AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
						AllTrim(SA1->A1_MUN )                            ,;  		// [4]Cidade
						SA1->A1_EST                                      ,;     	// [5]Estado
						SA1->A1_CEP                                      ,;      	// [6]CEP
						SA1->A1_CGC										 ,;         // [7]CGC
						SA1->A1_PESSOA									  }         // [8]PESSOA

						nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
						nPDesconto := SE1->E1_DESCFIN//Alterado rC Renato Castro em 15/03/16
						nVDesconto := (SE1->E1_VALOR-nVlrAbat)*(nPDesconto/100)//Alterado rC Renato Castro em 15/03/16
						/*                    
						--------------------------------------------------------------
						Parte do Nosso Numero. Sao 8 digitos para identificar o titulo
						--------------------------------------------------------------
						*/
						cNroDoc	:= StrZero(	Val(Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)),8)
						/*
						----------------------
						Monta codigo de barras
						----------------------
						*/
						_nVlrAbat   := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
						nSaldo		:= E1_VALOR - E1_IRRF - E1_COFINS - E1_PIS - E1_CSLL

						//nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase, ;
						//dDataBase, SE1->E1_LOJA )//Alterado Renato Castro em 21/06/16

						/*aCB_RN_NN := fLinhaDig(aDadosBanco[1]      ,; // Numero do Banco
						__cMoeda            ,; // Codigo da Moeda
						aDadosBanco[6]      ,; // Codigo da Carteira
						aDadosBanco[3]      ,; // Codigo da Agencia
						aDadosBanco[4]      ,; // Codigo da Conta
						aDadosBanco[5]      ,; // DV da Conta
						(E1_VALOR-nVlrAbat) ,; // Valor do Titulo
						E1_VENCREA          ,; // Data de Vencimento do Titulo
						cNroDoc              ) // Numero do Documento no Contas a Receber*///Alterado Renato Castro em 21/06/16

						aCB_RN_NN := fLinhaDig(aDadosBanco[1]      ,; // Numero do Banco
						__cMoeda            ,; // Codigo da Moeda
						aDadosBanco[6]      ,; // Codigo da Carteira
						aDadosBanco[3]      ,; // Codigo da Agencia
						aDadosBanco[4]      ,; // Codigo da Conta
						aDadosBanco[5]      ,; // DV da Conta
						nSaldo				,; // Valor do Titulo
						E1_VENCREA          ,; // Data de Vencimento do Titulo
						cNroDoc              ) // Numero do Documento no Contas a Receber

						/*nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase, ;
						dDataBase, SE1->E1_LOJA )*///Alterado Renato Castro em 21/06/16

						aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
						E1_EMISSAO                          ,;  // [2] Data da emissão do título
						dDataBase                    		,;  // [3] Data da emissão do boleto
						E1_VENCREA                           ,;  // [4] Data do vencimento
						nSaldo               				,;  // [5] Valor do título
						aCB_RN_NN[3]                        ,;  // [6] Nosso número (Ver fórmula para calculo)
						E1_PREFIXO                          ,;  // [7] Prefixo da NF
						E1_TIPO	                           	,;   // [8] Tipo do Titulo
						E1_VALJUR							} 	// [9] Valor de juros

						//RC - 19/01/16 - geração de PDF após a impressão do danfe				
						cEmailTst := "fabio@gkcmp.com.br"
						if(Empty(cEmailTst))
							cEmailTo := alltrim(posicione("SA1",1,xfilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_EMAIL"))
						else
							cEmailTo := cEmailTst 
						endIf

						cMensagem := strtran(cMsgPad,"XXXXXX",alltrim(SE1->E1_NUM) + " / Série: " + alltrim(SE1->E1_PREFIXO))
						cMensagem := strtran(cMensagem,"YYYYYY",Dtoc(SE1->E1_EMISSAO))
							
						if cChaveImpr <> SE1->E1_PREFIXO+SE1->E1_NUM
							if oPrint <> nil
								//oPrint:Preview()
								oPrint:lViewPDF := .F.
								oPrint:Print()
								//Fabio Ajustes
								//CpyT2S(cDirArq + cNomeArq, cDirSrv)//Copia o PDF da estação para o servidor
							
								//FErase(cAnexo)
								FreeObj(oPrint)
								oPrint := Nil
								lImprimiu := .T.
							endif
							
							cMensagem := strtran(cMsgPad,"XXXXXX",alltrim(SE1->E1_NUM) + " / Série: " + alltrim(SE1->E1_PREFIXO))
							cMensagem := strtran(cMensagem,"YYYYYY",Dtoc(SE1->E1_EMISSAO))
							cAnexo := cDirSrv + "\" + cNomeArq
							oPrint:= FWMSPrinter():New(cNomeArq, 6, lAdjustToLegacy, , lDisableSetup)
							oPrint:SetPortrait() // ou SetLandscape()
							oPrint:SetPaperSize(DMPAPER_A4) 
							oPrint:cPathPDF := cDirArq 
							oPrint:lViewPDF := .F.
							cChaveImpr := SE1->E1_PREFIXO+SE1->E1_NUM
							lImprimiu := .F.
						endif
						//--

						Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
						
						//Reclock("SE1",.F.)
						//SE1->E1_ZZDVNN 	:= aCB_RN_NN[4]
						//SE1->(msunlock())

						nX := nX + 1
					endif
			endif
			
			SE1->(DbSkip())
			IncProc()
			nI++

		EndDo
	endIf

	//RC - 19/01/16 - geração de PDF após a impressão do danfe
	if !lDanfe .or. (!lImprimiu .and. oPrint <> nil)
		if(!lDanfe)
			cMensagem := strtran(cMsgPad,"XXXXXX",alltrim(SE1->E1_NUM) + " / Série: " + alltrim(SE1->E1_PREFIXO))
			cMensagem := strtran(cMensagem,"YYYYYY",Dtoc(dDataBase))
		endif
		
		//oPrint:Preview()     // Visualiza antes de imprimir
		oPrint:Print()
		//Fabio ajustes
		//CpyT2S(cDirArq + cNomeArq, cDirSrv)//Copia o PDF da estação para o servidor
		cAnexo := cDirSrv + "\" + cNomeArq
	
		//FErase(cAnexo)
		FreeObj(oPrint)
		oPrint := Nil
	endif

	if oPrint <> nil
		FreeObj(oPrint)
		oPrint := Nil
	endif

	if lErroEmail
		Alert("Ocorreram erros ao enviar emails ! Verifique.")
	//else
	//	msgalert("E-mails enviados com sucesso !")
	endif

	//--

Return Nil


/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |Impress   |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Impressao dos dados do boleto em modo grafico               |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | AP                                                         |
+-----------+------------------------------------------------------------+
*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
	Local oFont8
	Local oFont8n
	Local oFont11c
	Local oFont10
	Local oFont14
	Local oFont16n
	Local oFont15
	Local oFont14n
	Local oFont24
	Local nI := 0
	local cImgLogo := GetMv("ZZ_IMLGCB", .T., "\cobranca\imagens\01Eurofins.jpeg")

	//Parametros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)
	oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont8n   := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont9   := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:StartPage()   // Inicia uma nova página

	/******************/
	/* PRIMEIRA PARTE */
	/******************/

	nRow1 := 0

	oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
	oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

	oPrint:Say  (nRow1+0134,100,aDadosBanco[2],oFont11 )	        // [2]Nome do Banco
	oPrint:Say  (nRow1+0125,513,aDadosBanco[1]+"-7",oFont21 )		// [1]Numero do Banco

	oPrint:Say  (nRow1+0134,1900,"Comprovante de Entrega",oFont10)
	oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

	oPrint:Say  (nRow1+0180,100 ,"Beneficiário: ",oFont8)
	oPrint:Say  (nRow1+0230,100 ,aDadosEmp[1],oFont8n)				//Nome + CNPJ
	//oPrint:Say  (nRow1+0200,100 ,Alltrim(aDadosEmp[2])+" "+aDadosEmp[3]+" "+aDadosEmp[4],oFont8)				//Nome + CNPJ

	oPrint:Say  (nRow1+0180,1060,"Agência/Código Beneficiário",oFont8)
	oPrint:Say  (nRow1+0230,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10) //+"-"+aDadosBanco[5]

	oPrint:Say  (nRow1+0180,1510,"Nro.Documento",oFont8)
	oPrint:Say  (nRow1+0230,1510,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow1+0280,100 ,"Pagador",oFont8)
	oPrint:Say  (nRow1+0330,100 ,aDatSacado[1],oFont9)				//Nome

	oPrint:Say  (nRow1+0280,1060,"Vencimento",oFont8)
	oPrint:Say  (nRow1+0330,1080,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

	oPrint:Say  (nRow1+0280,1510,"Valor do Documento",oFont8)
	oPrint:Say  (nRow1+0330,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

	oPrint:Say  (nRow1+0430,0100,"Recebi(emos) o bloqueto/título",oFont10)
	oPrint:Say  (nRow1+0480,0100,"com as características acima.",oFont10)
	oPrint:Say  (nRow1+0380,1060,"Data",oFont8)
	oPrint:Say  (nRow1+0380,1410,"Assinatura",oFont8)
	oPrint:Say  (nRow1+0480,1060,"Data",oFont8)
	oPrint:Say  (nRow1+0480,1410,"Entregador",oFont8)

	oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
	oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
	oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
	oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

	oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
	oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
	oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
	oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

	oPrint:Say  (nRow1+0195,1910,"(  )Mudou-se"                                	,oFont8)
	oPrint:Say  (nRow1+0235,1910,"(  )Ausente"                                    ,oFont8)
	oPrint:Say  (nRow1+0275,1910,"(  )Não existe nº indicado"                  	,oFont8)
	oPrint:Say  (nRow1+0315,1910,"(  )Recusado"                                	,oFont8)
	oPrint:Say  (nRow1+0355,1910,"(  )Não procurado"                              ,oFont8)
	oPrint:Say  (nRow1+0395,1910,"(  )Endereço insuficiente"                  	,oFont8)
	oPrint:Say  (nRow1+0435,1910,"(  )Desconhecido"                            	,oFont8)
	oPrint:Say  (nRow1+0475,1910,"(  )Falecido"                                   ,oFont8)
	oPrint:Say  (nRow1+0515,1910,"(  )Outros(anotar no verso)"                  	,oFont8)

	/*****************/
	/* SEGUNDA PARTE */
	/*****************/

	nRow2 := 0

	oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
	oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
	oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

	oPrint:Say  (nRow2+0694,100,aDadosBanco[2],oFont11 )		// [2]Nome do Banco
	oPrint:Say  (nRow2+0685,513,aDadosBanco[1]+"-7",oFont21 )	// [1]Numero do Banco
	oPrint:Say  (nRow2+0694,1800,"Recibo do Pagador",oFont10)

	oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
	oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
	oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
	oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

	oPrint:Line (nRow2+0910,500,nRow2+1050,500)
	oPrint:Line (nRow2+0980,750,nRow2+1050,750)
	oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
	oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
	oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

	oPrint:Say  (nRow2+0740,100 ,"Local de Pagamento",oFont8)
	oPrint:Say  (nRow2+0755,400 ,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont10)
	oPrint:Say  (nRow2+0795,400 ,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU",oFont10)

	oPrint:Say  (nRow2+0740,1810,"Vencimento"                                     ,oFont8)
	cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0780,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0840,100 ,"Beneficiário:"                                        ,oFont8)
	oPrint:Say  (nRow2+0845,260 ,aDadosEmp[1]+"    - "+aDadosEmp[6]	,oFont8n) //Nome + CNPJ
	oPrint:Say  (nRow2+0890,260 ,Alltrim(aDadosEmp[2])+" "+aDadosEmp[3]+" "+aDadosEmp[4],oFont8n)				//Nome + CNPJ

	oPrint:Say  (nRow2+0840,1810,"Agência/Código Beneficiário",oFont8)
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]) //+"-"+aDadosBanco[5]
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0880,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0940,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say  (nRow2+0970,100, StrZero(Day(dDataBase),2) +"/"+ StrZero(Month(dDataBase),2) +"/"+ Right(Str(Year(dDataBase)),4),oFont10)

	oPrint:Say  (nRow2+0940,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (nRow2+0970,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow2+0940,1005,"Espécie Doc."                                   ,oFont8)
	//oPrint:Say  (nRow2+0970,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo
	oPrint:Say  (nRow2+0970,1050, "DM"										,oFont10) //Tipo do Titulo

	oPrint:Say  (nRow2+0940,1305,"Aceite"                                         ,oFont8)
	oPrint:Say  (nRow2+0970,1400,"N"                                             ,oFont10)

	oPrint:Say  (nRow2+0940,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (nRow2+0970,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

	oPrint:Say  (nRow2+0940,1810,"Nosso Número"                                   ,oFont8)
	cString := Alltrim(Substr(aDadosTit[6],1,3)+"/"+SubStr(AllTrim(SE1->E1_NUMBCO), 1,8)+"-"+aCB_RN_NN[4])   //Substr(aDadosTit[6],4)
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0970,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+1010,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (nRow2+1010,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (nRow2+1040,555 ,aDadosBanco[6]                                  	,oFont10)

	oPrint:Say  (nRow2+1010,755 ,"Espécie"                                        ,oFont8)
	oPrint:Say  (nRow2+1040,805 ,"R$"                                             ,oFont10)

	oPrint:Say  (nRow2+1010,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say  (nRow2+1010,1485,"Valor"                                          ,oFont8)

	oPrint:Say  (nRow2+1010,1810,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+1040,nCol,cString ,oFont11c)

	oPrint:Say  (nRow2+1080,100 ,"Instruções de responsabilidade do beneficiário. Qualquer dúvida sobre este boleto, contate o beneficiário)",oFont8)	
	oPrint:SayBitmap( nRow2+1080, 1200, cImgLogo,0300,0280 )

	oPrint:Say  (nRow2+1130,100 ,aBolText[1]+" "+AllTrim(Transform(aDadosTit[9],"@E 99,999.99"))+" AO DIA"  ,oFont10)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	oPrint:Say  (nRow2+1180,100 ,"APOS"+"  "+cString+"  "+"MULTA DE............"+	AllTrim(Transform(aDadosTit[5]*(0.02),"@E 99,999.99")),oFont10)
	//	oPrint:Say  (nRow2+1230,100 ,aBolText[2]   ,oFont10)                                                                                           
	cString := Alltrim(Transform(nVDesconto,"@E 99,999,999.99"))	

	oPrint:Say  (nRow2+1230,100 ,aBolText[4]   ,oFont10)
	oPrint:Say  (nRow2+1260,100 ,aBolText[5]   ,oFont10)
	oPrint:Say  (nRow2+1290,100 ,aBolText[6]   ,oFont10)
	oPrint:Say  (nRow2+1320,100 ,aBolText[7]   ,oFont10)

	oPrint:Say  (nRow2+1080,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow2+1150,1810,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (nRow2+1220,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow2+1290,1810,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (nRow2+1360,1810,"(=)Valor Cobrado"                               ,oFont8)

	//Temp
	//oPrint:Say  (nRow2+1380,100,"APOS VCTO ACESSE WWW.ITAU.COM.BR/BOLETOS PARA ATUALIZAR SEU BOLETO"                               ,oFont10)


	oPrint:Say  (nRow2+1430,100 ,"Pagador"                                         ,oFont8)
	oPrint:Say  (nRow2+1460,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
	oPrint:Say  (nRow2+1513,400 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (nRow2+1566,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow2+1619,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow2+1619,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
	EndIf

	oPrint:Say  (nRow2+1619,1850,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

	oPrint:Say  (nRow2+1635,100 ,"Pagador/Avalista",oFont8)
	oPrint:Say  (nRow2+1675,1500,"Autenticação Mecânica",oFont8)

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

	nRow3 := 0

	For nI := 100 to 2300 step 50
		oPrint:Line(nRow3+1830, nI, nRow3+1830, nI+30)
	Next nI

	oPrint:Line (nRow3+1950,100,nRow3+1950,2300)
	oPrint:Line (nRow3+1950,500,nRow3+1870, 500)
	oPrint:Line (nRow3+1950,710,nRow3+1870, 710)

	oPrint:Say  (nRow3+1934,100,aDadosBanco[2],oFont11 )		// 	[2]Nome do Banco
	oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-7",oFont21 )	// 	[1]Numero do Banco
	oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],oFont15n)			//	Linha Digitavel do Codigo de Barras

	oPrint:Line (nRow3+2050,100,nRow3+2050,2300 )
	oPrint:Line (nRow3+2150,100,nRow3+2150,2300 )
	oPrint:Line (nRow3+2220,100,nRow3+2220,2300 )
	oPrint:Line (nRow3+2290,100,nRow3+2290,2300 )

	oPrint:Line (nRow3+2150,500 ,nRow3+2290,500 )
	oPrint:Line (nRow3+2220,750 ,nRow3+2290,750 )
	oPrint:Line (nRow3+2150,1000,nRow3+2290,1000)
	oPrint:Line (nRow3+2150,1300,nRow3+2290,1300)//TODO
	oPrint:Line (nRow3+2150,1480,nRow3+2290,1480)

	oPrint:Say  (nRow3+1980,100 ,"Local de Pagamento",oFont8)
	oPrint:Say  (nRow3+1995,400 ,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont10)
	oPrint:Say  (nRow3+2035,400 ,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU",oFont10)

	oPrint:Say  (nRow3+1980,1810,"Vencimento",oFont8)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol	 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2020,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2080,100 ,"Beneficiário:",oFont8)
	oPrint:Say  (nRow3+2085,260 ,aDadosEmp[1]+"    - "+aDadosEmp[6]	,oFont8n) //Nome + CNPJ
	oPrint:Say  (nRow3+2130,260 ,Alltrim(aDadosEmp[2])+" "+aDadosEmp[3]+" "+aDadosEmp[4],oFont8n)				//Nome + CNPJ

	oPrint:Say  (nRow3+2080,1810,"Agência/Código Beneficiário",oFont8)
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]) //+"-"+aDadosBanco[5]
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2120,nCol,cString ,oFont11c)

	oPrint:Say (nRow3+2180,100 ,"Data do Documento"                             ,oFont8)
	oPrint:Say (nRow3+2210,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

	oPrint:Say (nRow3+2180,505 ,"Nro.Documento"                                 ,oFont8)
	oPrint:Say (nRow3+2210,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say (nRow3+2180,1005,"Espécie Doc."                                  ,oFont8)
	//oPrint:Say (nRow3+2210,1050,aDadosTit[8]									,oFont10) //Tipo do Titulo
	oPrint:Say (nRow3+2210,1050,"DM"									,oFont10) //Tipo do Titulo

	oPrint:Say (nRow3+2180,1305,"Aceite"                                        ,oFont8)
	oPrint:Say (nRow3+2210,1400,"N"                                             ,oFont10)

	oPrint:Say  (nRow3+2180,1485,"Data do Processamento"                        ,oFont8)
	oPrint:Say  (nRow3+2210,1550,StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4)                               ,oFont10) // Data impressao


	oPrint:Say  (nRow3+2180,1810,"Nosso Número"                                 ,oFont8)
	cString := Alltrim(Substr(aDadosTit[6],1,3)+"/"+SubStr(AllTrim(SE1->E1_NUMBCO), 1,8)+"-"+aCB_RN_NN[4])   //Substr(aDadosTit[6],4)
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2210,nCol,cString,oFont11c)


	oPrint:Say  (nRow3+2250,100 ,"Uso do Banco"                                 ,oFont8)

	oPrint:Say  (nRow3+2250,505 ,"Carteira"                                     ,oFont8)
	oPrint:Say  (nRow3+2280,555 ,aDadosBanco[6]                                 ,oFont10)

	oPrint:Say  (nRow3+2250,755 ,"Espécie"                                      ,oFont8)
	oPrint:Say  (nRow3+2280,805 ,"R$"                                           ,oFont10)

	oPrint:Say  (nRow3+2250,1005,"Quantidade"                                   ,oFont8)
	oPrint:Say  (nRow3+2250,1485,"Valor"                                        ,oFont8)

	oPrint:Say  (nRow3+2250,1810,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2280,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2320,100 ,"Instruções de responsabilidade do beneficiário. Qualquer dúvida sobre este boleto, contate o beneficiário)",oFont8)
	oPrint:SayBitmap( nRow2+2320, 1200, cImgLogo,0300,0280 )

	oPrint:Say  (nRow3+2370,100 ,aBolText[1]+" "+AllTrim(Transform(aDadosTit[9],"@E 99,999.99"))+" AO DIA"  ,oFont10)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	oPrint:Say  (nRow3+2420,100 ,"APOS"+"  "+cString+"  "+"MULTA DE............"+	AllTrim(Transform(aDadosTit[5]*(0.02),"@E 99,999.99")),oFont10)
	//	oPrint:Say  (nRow3+2470,100 ,aBolText[2]   ,oFont10) 
	cString := Alltrim(Transform(nVDesconto,"@E 99,999,999.99"))
	//oPrint:Say  (nRow3+2470,100 ,"CONCEDER ABATIMENTO DE............"+ cString ,oFont10)  
	//oPrint:Say  (nRow3+2520,100 ,aBolText[2]   ,oFont10)


	oPrint:Say  (nRow3+2320,1810,"(-)Desconto/Abatimento"                       ,oFont8)
	oPrint:Say  (nRow3+2390,1810,"(-)Outras Deduções"                           ,oFont8)
	oPrint:Say  (nRow3+2460,1810,"(+)Mora/Multa"                                ,oFont8)
	oPrint:Say  (nRow3+2530,1810,"(+)Outros Acréscimos"                         ,oFont8)
	oPrint:Say  (nRow3+2600,1810,"(=)Valor Cobrado"                             ,oFont8)

	// TEMP
	oPrint:Say  (nRow2+2620,100,"APOS VCTO ACESSE WWW.ITAU.COM.BR/BOLETOS PARA ATUALIZAR SEU BOLETO"                               ,oFont10)

	oPrint:Say  (nRow3+2670,100 ,"Pagador"                                       ,oFont8)
	oPrint:Say  (nRow3+2680,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"           ,oFont10)

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow3+2680,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow3+2680,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
	EndIf

	oPrint:Say  (nRow3+2733,400 ,aDatSacado[3]                                  ,oFont10)
	oPrint:Say  (nRow3+2786,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
	oPrint:Say  (nRow3+2786,1750,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

	oPrint:Say  (nRow3+2795,100 ,"Pagador/Avalista"                             ,oFont8)
	oPrint:Say  (nRow3+2835,1500,"Autenticação Mecânica - Ficha de Compensação" ,oFont8)

	oPrint:Line (nRow3+1950,1800,nRow3+2640,1800 )
	oPrint:Line (nRow3+2360,1800,nRow3+2360,2300 )
	oPrint:Line (nRow3+2430,1800,nRow3+2430,2300 )
	oPrint:Line (nRow3+2500,1800,nRow3+2500,2300 )
	oPrint:Line (nRow3+2570,1800,nRow3+2570,2300 )
	oPrint:Line (nRow3+2640,100 ,nRow3+2640,2300 )

	oPrint:Line (nRow3+2800,100,nRow3+2800,2300  )

	oPrint:FWMSBAR("INT25",67,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.022,1,Nil,Nil,"A",.F.) //datasupri //RC - 14/01/16 - Ajuste para geração de PDF

	oPrint:EndPage() // Finaliza a página
	Return Nil

	/*
	+-----------+----------+-------+--------------------+------+-------------+
	| Programa  |BOLITAU   |Autor  |Microsiga           | Data |  11/21/05   |
	+-----------+----------+-------+--------------------+------+-------------+
	| Desc.     |Obtenção da linha digitavel/codigo de barras                |
	|           |                                                            |
	+-----------+------------------------------------------------------------+
	| Uso       | AP                                                         |
	+-----------+------------------------------------------------------------+
	*/
	Static Function fLinhaDig (cCodBanco, ; // Codigo do Banco (341)
	cCodMoeda, ; // Codigo da Moeda (9)
	cCarteira, ; // Codigo da Carteira
	cAgencia , ; // Codigo da Agencia
	cConta   , ; // Codigo da Conta
	cDvConta , ; // Digito verificador da Conta
	nValor   , ; // Valor do Titulo
	dVencto  , ; // Data de vencimento do titulo
	cNroDoc   )  // Numero do Documento Ref ao Contas a Receber

	//Local cValorFinal   := StrZero(int(nValor*100),10)
	Local cValorFinal   := StrZero(nValor*100,10)//RC
	Local cFator        := ALLTRIM(STR(dVencto - IIF(DTOS(dVencto)>=GetMv("CL_NVDTBL"),CtoD(GetMv("CL_DT1000")),CtoD("07/10/1997"))))
	Local cCodBar   	:= Replicate("0",43)
	Local cCampo1   	:= Replicate("0",05)+"."+Replicate("0",05)
	Local cCampo2   	:= Replicate("0",05)+"."+Replicate("0",06)
	Local cCampo3   	:= Replicate("0",05)+"."+Replicate("0",06)
	Local cCampo4   	:= Replicate("0",01)
	Local cCampo5   	:= Replicate("0",14)
	Local cTemp     	:= ""
	Local cNossoNum 	:= SubStr(AllTrim(SE1->E1_NUMBCO), 1, 8) // Nosso numero
	Local cDV			:= "" // Digito verificador dos campos
	Local cLinDig		:= ""
	/*
	-------------------------
	Definicao do NOSSO NUMERO
	-------------------------
	*/
	If At("-",cConta) > 0
		cDig   := Right(AllTrim(cConta),1)
		cConta := AllTrim(Str(Val(Left(cConta,At('-',cConta)-1) + cDig)))
		cConta := AllTrim(Str(Val(cConta)))
	Endif
	cNossoNum   := Alltrim(cAgencia) + Right(Alltrim(cConta),5) + /*cDvConta +*/ cCarteira + SubStr(AllTrim(SE1->E1_NUMBCO), 1, 8) //cNroDoc
	cDvNN 		:= Right(AllTrim(SE1->E1_NUMBCO),1)
	cNossoNum   := cCarteira + cNroDoc + cDvNN
	/*
	-----------------------------
	Definicao do CODIGO DE BARRAS
	-----------------------------
	*/

	cTemp := Alltrim(cCodBanco)            + ; // 01 a 03
	Alltrim(cCodMoeda)            + ; // 04 a 04    
	Alltrim(cFator)               + ; // 06 a 09
	Alltrim(cValorFinal)          + ; // 10 a 19
	Alltrim(cCarteira)            + ; // 20 a 22
	SubStr(AllTrim(SE1->E1_NUMBCO),1,8) +; // 23 A 30
	Alltrim(cDvNN)                + ; // 31 a 31
	Alltrim(cAgencia)             + ; // 32 a 35
	Alltrim(Right(cConta,5))       + ; // 36 a 40
	Alltrim(cDvConta)             + ; // 41 a 41
	"000"                             // 42 a 44
	cDvCB  := Alltrim(Str(modulo11(cTemp)))	// Digito Verificador CodBarras
	cCodBar:= SubStr(cTemp,1,4) + cDvCB + SubStr(cTemp,5)// + cDvNN + SubStr(cTemp,31)

	/*
	-----------------------------------------------------
	Definicao da LINHA DIGITAVEL (Representacao Numerica)
	-----------------------------------------------------

	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

	CAMPO 1:
	AAA = Codigo do banco na Camara de Compensacao
	B = Codigo da moeda, sempre 9
	CCC = Codigo da Carteira de Cobranca
	DD = Dois primeiros digitos no nosso numero
	X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	*/
	cTemp   := cCodBanco + cCodMoeda + cCarteira + Substr(SubStr(AllTrim(SE1->E1_NUMBCO), 1, 8),1,2)
	cDV		:= Alltrim(Str(Modulo10(cTemp)))
	cCampo1 := SubStr(cTemp,1,5) + '.' + Alltrim(SubStr(cTemp,6)) + cDV + Space(2)
	/*
	CAMPO 2:
	DDDDDD = Restante do Nosso Numero
	E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
	FFF = Tres primeiros numeros que identificam a agencia
	Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	*/
	cTemp	:= Substr(SubStr(AllTrim(SE1->E1_NUMBCO), 1, 8),3) + cDvNN + Substr(cAgencia,1,3)
	cDV		:= Alltrim(Str(Modulo10(cTemp)))
	cCampo2 := Substr(cTemp,1,5) + '.' + Substr(cTemp,6) + cDV + Space(3)
	/*
	CAMPO 3:
	F = Restante do numero que identifica a agencia
	GGGGGG = Numero da Conta + DAC da mesma
	HHH = Zeros (Nao utilizado)
	Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	*/
	cTemp   := Substr(cAgencia,4,1) + Right(cConta,5) + Alltrim(cDvConta) + "000"
	cDV		:= Alltrim(Str(Modulo10(cTemp)))
	cCampo3 := Substr(cTemp,1,5) + '.' + Substr(cTemp,6) + cDV + Space(2)
	/*
	CAMPO 4:
	K = DAC do Codigo de Barras
	*/
	cCampo4 := cDvCB + Space(2)
	/*
	CAMPO 5:
	UUUU = Fator de Vencimento
	VVVVVVVVVV = Valor do Titulo
	*/
	//cCampo5 := cFator + StrZero(int(nValor * 100),14 - Len(cFator))
	cCampo5 := cFator + StrZero(nValor * 100,14 - Len(cFator))//Alterado Renato Castro em 21/06/16
	cLinDig := cCampo1 + cCampo2 + cCampo3 + cCampo4 + cCampo5
Return {cCodBar, cLinDig, cNossoNum, cDvNN}


/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |MODULO10  |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Cálculo do Modulo 10 para obtenção do DV dos campos do      |
|           |Codigo de Barras                                            |
+-----------+------------------------------------------------------------+
| Uso       | Financeiro Transilva LOG                                   |
+-----------+------------------------------------------------------------+
*/
Static Function Modulo10(cData)
	Local  L,D,P := 0
	Local B     := .F.
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
Return D

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |MODULO11  |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Calculo do Modulo 11 para obtencao do DV do Codigo de Barras|
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | Financeiro Transilva LOG                                   |
+-----------+------------------------------------------------------------+
*/
Static Function Modulo11(cData)
	Local L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	// Some o resultado de cada produto efetuado e determine o total como (D);
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
	// DAC = 11 - Mod 11(D)
	D := 11 - (mod(D,11))
	// OBS: Se o resultado desta for igual a 0, 1, 10 ou 11, considere DAC = 1.
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
Return D
