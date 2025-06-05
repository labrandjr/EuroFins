#include "totvs.ch"
/*/{Protheus.doc} ExpRPS
Gera arquivo texto conforme lay-out definido pela prefeitura de Indaiatuba 
para o programa DEISS, com a finalidade de gerar as notas fiscais. 

@author Sergio Braz
@since 31/08/2018
/*/
User Function EXPRPS
	Local cTexto := 'Este programa visa gerar um arquivo texto com informacoes das notas '
	cTexto += 'de saida, do periodo que for determinado nos parametros e que sera '
	cTexto += 'importado pelo programa DEISS da prefeitura de Indaiatuba, com a   '
	cTexto += 'finalidade de gerar automaticamente as notas fiscais eletronicas. '+CRLF
	cTexto += "Confirma a geracao do arquivo?"
	If MsgYesNo(OemToAnsi(cTexto),OemToansi('Geracao de RPS para o programa DEISS'))
		If AskMe()
			Processa({|| RunCont()},"Gerando arquivo")
		Endif
	Endif
Return

//rotina principal
Static Function RunCont 
	Local cLin, cCpo 
    Local nTotRec
	Local nHdl
	Local nM	  := 0
	Local nA	  := 0
	Local nL      := 0
	Private cCodServ 
	Private cEmail
	Private nValIRRF := 0
	Private nValPIS  := 0                                
	Private nValCOFI := 0
	Private nValCSLL := 0
    Private cCpo
	MV_PAR03 := AllTrim(MV_PAR03)+IIf(Right(AllTrim(MV_PAR03),1)#"\","\","")
	MontaDir(MV_PAR03)
	nHdl := fCreate(MV_PAR03+AllTrim(MV_PAR04))
	If nHdl < 0
		MsgAlert(OemToAnsi("O arquivo de nome "+Alltrim(MV_PAR03)+Alltrim(MV_PAR04)+" nao pode ser executado! Verifique os parâmetros."),OemToAnsi("Atenção!"))
		Return
	Endif
    //Retirado a valida  o abaixo no SQL
    //F2_BASEISS > 0 que estava na select a pedido da Joelma
	BeginSql Alias "WSF2"
		SELECT *
		FROM %Table:SF2%
		WHERE F2_FILIAL = %xFilial:SF2% AND %NotDel% AND
		F2_EMISSAO Between %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
		F2_SERIE = '   ' AND F2_TIPO = 'N' AND F2_NFELETR = '         '
		ORDER BY F2_FILIAL,F2_EMISSAO,F2_DOC,F2_SERIE
	EndSql
	Count to nTotRec
	WSF2->(dbGoTop())
	ProcRegua(nTotRec)//Numero de registros a processar
	While WSF2->(!Eof())
		IncProc(OemToAnsi("Lendo Registros das Notas de Servico..."))
		cMensag := ""
		nValIRRF := nValPIS  := nValCOFI := nValCSLL := 0		
		If VldNF()
			Posicione("SA1",1,xFilial("SA1")+WSF2->(F2_CLIENTE+F2_LOJA),"")
			cMensag  += GetDuplic()+" "			
			cLin := StrZero(++nL,2)+"|" //01-linha
			cLin += AllTrim(SM0->M0_CGC)+"|"//02-cnpj
			cLin += ALLTRIM(SM0->M0_INSCM)+"|"//03-CCM inscricao municipal
			cLin += WSF2->F2_DOC+"|"//04-RPS
			cLin += WSF2->F2_EMISSAO+"|"//05-data rps
			cLin += Left(WSF2->F2_EMISSAO,6)+"|"//06-competencia
			cLin += Alltrim(cCodServ)+"|"//07-codigo do servi o
			cLin += AllTrim(Transform(WSF2->F2_VALBRUT,"@E 99999999999.99"))+"|"//08-Valor do Servico
			cLin += "0,00"+"|"	//09-Valor das dedu  es
			//Muda para 4 - Exporta  o conforme necessidade de mudan a de iSS para exporta  o
            if SA1->A1_EST == "EX"
			    cLin += "4"+"|" //10-Exigibilidade do ISS
            else
                cLin += "1"+"|" //10-Exigibilidade do ISS
            endif
			cLin += "|" //11-numero do processo judicial que suspende de exibilidade
			cLin += Alltrim(SM0->M0_CODMUN)+"|"//12-codigo ibge do municipio onde incide imposto
			cLin += Alltrim(SM0->M0_CODMUN)+"|"//13-codigo ibge do municipio onde realizou-se servi o
			//Exporta  o conforme necessidade de mudan a de iSS para exporta  o
            if SA1->A1_EST == "EX"
                cLin += "01058|"	//14- pais onde foi realizado o servi o
            else
			    cLin += "|"	//14- pais onde foi realizado o servi o
            endif
			cLin += "2"+"|"//15-optante pelo simples 1=sim,2=nao
			cLin += "2"+"|"//16-incentivo fiscal 2=nao
			cLin += "2"+"|"//17-iss retido 2=nao
			cLin += "|"//18-regime especial de tributacao
			cLin += "0,00"+"|"//19-Inss
			cLin += AllTrim(Transform(nValIRRF,"@E 99999999999.99"))+"|"   //20-IR
			cLin += AllTrim(Transform(nValCSLL,"@E 99999999999.99"))+"|"   //21-CSLL
			cLin += AllTrim(Transform(nValCOFI,"@E 99999999999.99"))+"|"   //22-COFINS
			cLin += AllTrim(Transform(nValPIS,"@E 99999999999.99"))+"|"   //23-PIS
			cLin += "0,00"+"|"   //24-ISS
			cLin += "0,00"+"|"   //25-outras reten  es
			//Exporta  o conforme necessidade de mudan a de iSS para exporta  o
            if SA1->A1_EST == "EX"
				cLin += "0,00"+"|"//26-aliquota do servico prestado
			else
				cLin += "2,50"+"|"//26-aliquota do servico prestado
			endif
			cLin += "|"//27-rps substituido
			cLin += NoPipes(GetMensDep())+"|"//28-texto da descricao do servi o
			cLin += NoPipes(cMensag)+"|"//29-observa oes
			cLin += IIf(SA1->A1_EST == "EX","99999999999999",StrZero(Val(SA1->A1_CGC),14))+"|"//30-cnpj do tomador
			cLin += "|"//31-inscricao municipal do tomador
			cLin += Alltrim(SA1->A1_NOME)+"|"//32-razao social
			cLin += GetTipLogr() + "|"//33-tipo de logradouro
			cLin += Alltrim(FisGetEnd(SA1->A1_END)[1])+"|"//34-Logradouro
			cCpo := Alltrim(FisGetEnd(SA1->A1_END)[3])
			cLin += IIf(Val(cCpo)>0,cCpo,"")+"|"//35-Numero Logradouro
			cCpo := If(!Empty(SA1->A1_COMPLEM),SA1->A1_COMPLEM,FisGetEnd(SA1->A1_END)[4])
			cLin += AllTrim(cCpo) + "|"//36-Complemento Logradouro
			cLin += "|"//37-Tipo de Bairro
			cLin += AllTrim(Upper(SA1->A1_BAIRRO))+"|"//38-Bairro
			cLin += RetUF(SA1->A1_EST)+Alltrim(SA1->A1_COD_MUN)+"|"//39-Codigo municipio IBGE do tomador
			cLin += SA1->A1_EST+"|" //40-UF do tomador
			cLin += IIF(SA1->A1_COD_MUN=='99999',Alltrim(Right(SA1->A1_CODPAIS,4)),'')+"|"//41-Codigo do pais Bacen
            //Para exporta  o, clientes extrangerios tinha que tirar essa informa  o por que a prefeitura recusa segundo a Natalia da Agro.
			if SA1->A1_EST == "EX"
			    cLin += "|"//42-CEP
            else
                cLin += AllTrim(SA1->A1_CEP)+"|"//42-CEP
            endif
			cLin += AllTrim(cEmail) + "|" //43-Email do tomador
			cLin += GetFone() + "|"//44-Telefone do tomador com DDD
			cLin += "|"//45-CNPJ do tomador
			cLin += "|"//46-CCM (inscricao municipal) do tomador
			cLin += "|"//47-Razao social do intermediario
			cLin += "|"//48-codigo do municipio do intermediario
			cLin += "|"//49-numero da matricula (CEI)
			cLin += ""//50-numero da ART
			cLin += CRLF
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !(Iw_MsgBox(OemToansi("Ocorreu um erro na grava  o do arquivo. Continua?"),OemToAnsi("Aten  o!"), "YESNO"))
					fClose(nHdl)
				Endif
			Endif
			while "||"$cLin
				cLin := strtran(cLin,"||","| |")
			end	
			aLin:=StrToKarr(cLin,"|")			
		Endif
		WSF2->(dbSkip())
	Enddo
	WSF2->(dbCloseArea())
	fClose(nHdl)
	Aviso(OemToAnsi("Informacao") , OemToAnsi("Processamento conclu do.") , {"Ok"})
Return

//Retorna codigo numerico do estado
Static Function RetUF(cUF)
	Local aUF := {}
	Local n
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})
	n := aScan(aUF,{|X| x[1]==cUF})
	If n>0
		cUF := aUF[n,2]
	Else
		cUF := "  "
	Endif
Return cUF
                                   
//remove pipes dos campos de texto
Static Function NoPipes(cText)
	cText:=AllTrim(cText)
	While "|"$cText
		cText := StrTran(cText,"|",";")
		l:=1
	End
Return cText

//exibe grupo de parametros
Static Function AskMe
	Local aPergs := {}
    Local i := 0
	AADD(aPergs,{1,"Data de",Ctod(""),,'.t.',,'.t.',60,.t.})
	AADD(aPergs,{1,"Data ate",Ctod(""),,'.t.',,'.t.',60,.t.})
	AADD(aPergs,{6,"Path",Space(100),,'.t.','.t.',85,.t.,"*.*","c:\xml\",128+16})
	AADD(aPergs,{1,"Arquivo",Space(20),,'.t.',,'.t.',60,.t.})
	For i:=1 to Len(aPergs)
		&("MV_PAR"+StrZero(i,2)) := PARAMLOAD(__cUserId+"DEISS",aPergs,i,aPergs[i,3])
	Next
Return ParamBox(aPergs,"Parametros DEISS" ,{},,,,,,,"DEISS",.T.,.T.)

//valida se   uma nota de servico
Static Function VldNF
	Local lRet := .F.
	Local cPed := ""
	Local nM          
	Local cLei :=SuperGetMV("MV_ZZLEINF", ,"") //COLOCA MENSAGEM DA LEI
	cEmail := ""
	BeginSql Alias "WSD2"
		Select B1_COD, B1_CODISS, B1_TIPO, D2_PEDIDO, D2_ITEMPV
		From %Table:SB1% SB1, %Table:SD2% SD2
		Where SB1.%NotDel% and B1_FILIAL=%xFilial:SB1% and
		SD2.%NotDel% and D2_FILIAL=%xFilial:SD2% and
		D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA = %Exp:WSF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)% and
		D2_COD=B1_COD and B1_CODISS<>'    '
	EndSql
	While WSD2->(!Eof())
		lRet := .T.
		cCodServ:=WSD2->B1_CODISS
		If !Posicione("SC5",1,xFilial("SC5")+WSD2->D2_PEDIDO,"Alltrim(C5_ZZNFMAI)") $ cEmail
			cEmail += IIf(Empty(cEmail),"",";")+ Alltrim(SC5->C5_ZZNFMAI)
		Endif
		If !Empty(SC5->C5_MENPAD)
			If !(Alltrim(Substr(Formula(SC5->C5_MENPAD),1,100)) $ cMensag)
				cMensag += Alltrim(Substr(Formula(SC5->C5_MENPAD),1,100))+" "
			Endif
		Endif
		If !Empty(SC5->C5_MENNOTA)
			If !(Alltrim(Upper(SC5->C5_MENNOTA)) $ cMensag)
				cMensag += Alltrim(Upper(SC5->C5_MENNOTA))+" "
			Endif
		Endif
		If !Empty(cLei) .And. !AllTrim(FORMULA(cLei)) $ cMensag
			cMensag += CleanSpecChar(AllTrim(FORMULA(cLei)))
		EndIf
		If Posicione("SC6",1,xFilial("SC6")+WSD2->(D2_PEDIDO+D2_ITEMPV),"!Empty(C6_PEDCLI)")
			If !Alltrim(SC6->C6_PEDCLI) $ cPed
				cPed += IIf(Empty(cPed),"",", ")+Alltrim(SC6->C6_PEDCLI)
			Endif
		Endif 
		WSD2->(dbSkip())
	Enddo       
	WSD2->(DbCloseArea())
	If !Empty(cPed) 
		cMensag += "NUM. SEU(S) PEDIDO(S): "+cPed
	Endif		
	If Empty(cEmail)
		cEmail := AllTrim(SA1->A1_ZZNFMAI)
	Endif 
	aMail := StrToKarr(cEmail,";")
	If Len(aMail)>1
		cEmail := aMail[1]
	Endif
Return lRet
                                 
//retorna duplicatas
Static Function GetDuplic
	Local nRetPis := SuperGetMv( "MV_ZZRTPIS")
	Local nRetCof := SuperGetMv( "MV_ZZRTCOF")
	Local nRetCsl := SuperGetMv( "MV_ZZRTCSL")
	Local nD
	Local nVlrImp  := 0
	Local aDuplic  := {}
	Local cDuplic  := "DUPLICATAS: "
	BeginSql Alias "WSE1"
		Select E1_PARCELA, E1_PIS, E1_COFINS, E1_CSLL, E1_VALOR, E1_VENCTO, E1_TIPO
		From %Table:SE1%
		Where %NotDel% and E1_FILIAL=%xFilial:SE1% and
		E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM = %Exp:WSF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)% and
		E1_TIPO IN ('NF ','IR-')
	EndSql
	While WSE1->(!Eof())
		If WSE1->E1_TIPO == "NF "
			WSE1->(aadd(aDuplic , {DtoC(Stod(E1_VENCTO)),E1_VALOR,E1_PARCELA}))
			nValPIS  += WSE1->(iif(E1_PIS>=nRetPis,E1_PIS,0))
			nValCOFI += WSE1->(iif(E1_COFINS>=nRetCof,E1_COFINS,0))
			nValCSLL += WSE1->(iif(E1_CSLL>=nRetCsl,E1_CSLL,0))
		ElseIf WSE1->E1_TIPO == "IR-"
			nValIRRF += WSE1->E1_VALOR
		Endif
		WSE1->(dbSkip())
	Enddo
	WSE1->(DbCloseArea())
	If Len(aDuplic) > 0
		For nD:=1 to Len(aDuplic)
			If nD==1
				nVlrImp := nValIRRF + nValPIS + nValCOFI + nValCSLL
			Else
				nVlrImp := 0
			Endif
			nVlr := aDuplic[nD][2]-nVlrImp
			nVlr := Alltrim(Transform(nVlr,"@E 999,999,999.99"))
			cDuplic += "Vencto: " + aDuplic[nD][1] + " Valor: " + nVlr + " Parcela: " + Iif(Empty(aDuplic[nD][3]),"UNICA",aDuplic[nD][3]) + "  " // desconsiderar Parcela:  nica - a pedido da Agata - por Dione Oliveira (TOTVSIP) - 14/02/17
		Next
	Else
		cDuplic := ""
	Endif	
Return cDuplic
                    
//retorna mensagens para deposito
Static Function GetMensDep
	Local cMens := ""
	Local cBancoDep, cBcoDescDep, cAgenciaDep, cContaDep , cChavBancoDep
	Local aChavBancoDep := Separa(SuperGetMv( "MV_ZZCDNFS" , .F. , " " ,  ),"/",.F.)
	cChavBancoDep := aChavBancoDep[1] + padR(aChavBancoDep[2],TamSX3("A6_AGENCIA")[1]) + aChavBancoDep[3]
	cBancoDep 	:= Posicione("SA6",1,xFilial("SA6")+cChavBancoDep,"A6_COD")
	cBcoDescDep	:= AllTrim(SA6->A6_NOME)
	cAgenciaDep	:= AllTrim(SA6->A6_AGENCIA) + "-" + SA6->A6_DVAGE
	cContaDep	:= AllTrim(SA6->A6_NUMCON) + "-" + SA6->A6_DVCTA	
	cMens := "CARO CLIENTE, INFORMAMOS QUE O RECOLHIMENTO DO ISSQN E DE OBRIGATORIEDADE DA " + ;
		alltrim(SM0->M0_NOMECOM) + ". GENTILEZA NAO RETER." + ;
		iif(cFilAnt<>"0300"," SERVICO REFERENTE ANALISES EM ALIMENTOS ","")
	If SA1->A1_ZZTPCOB == "D"
//		cMens += "DADOS PARA DEPOSITO: " + cBcoDescDep + " (" + cBancoDep +") " + "AGENCIA: " + cAgenciaDep + ;
//		 " CONTA: " + cContaDep  //removido em 23/05/19 por sergio braz ch. 2019051610036496
	Endif
Return cMens
//retorna tipo de logradouro
Static Function GetTipLogr
	Local cLogr := SA1->A1_ZZTPLOG
	If Empty(cLogr)
		cLogr := Upper(Substr(SA1->A1_END,1,2))
		If cLogr $ "RU/R./R "	// Rua
			cLogr := "R"
		ElseIf cLogr == "ES"		// Estrada
			cLogr := "ET"
		ElseIf cLogr == "PR"		// Praca
			cLogr := "PC"
		ElseIf cLogr == "RO"		// Rodovia
			cLogr := "RD"
		ElseIf cLogr == "TR"		// Travessa
			cLogr := "TV"
		ElseIf cLogr == "LA"		// Largo
			cLogr := "LG"
		Endif
	Endif	
Return Alltrim(cLogr)

//retorna telefone
Static Function GetFone
	Local cFone := StrTran(StrTran(Alltrim(SA1->A1_TEL)," ",""),"-","")
	Local cDDD  := Right(Alltrim(SA1->A1_DDD),2) 
Return cDDD + cFone                        

/*User function xpto
rpcsetenv("01","0100","admin","agis9","FAT")  
u_exprps()
return*/
