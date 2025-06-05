#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"

/*/{protheus.doc}MAVALMMAIL 
Ponto de entrada na rotina que envia e-mails automaticamente.                                                 
@Author Marcos Candido
@since 13/12/12  
@Obs
±±ºDesc.     ³ -   º±±
±±º          ³     º±±
±±º          ³ Podera ser aplicado para verificar qualquer tipo de con-   º±±
±±º          ³ dicao. Explicar abaixo qual o evento que sera considerado  º±±
±±º          ³ para criar filtro.                                         º±±
±±º Eventos  ³ 001 -> Produto atingiu ponto de pedido: O e-mail so deve-  º±±
±±º Filtrados³        ra ser enviado caso o armazem seja o 05 e grupo de  º±±
±±º          ³        produtos igual a 0010                               º±±
±±º          ³ Aplicado em : 13/12/12                                     º±±
±±º          ³ 035 -> Inclusao de solicitacao de Compra. A rotina verifi- º±±
±±º          ³        cara quem foi o Solicitante e enviara e-mail ao res-º±±
±±º          ³        pectivo aprovador.                                  º±±
±±º          ³ Aplicado em : 30/05/13                                     º±±
±±º          ³ 030 -> Inclusao de Documento de Entrada. O e-mail so sera  º±±
±±º          ³        enviado se no documento constar algum produto aloca-º±±
±±º          ³        do no armazem 05.                                   º±±
±±º          ³ Aplicado em : 13/09/13                                     º±±
±±º          ³ 037 -> Inclusao de pedido de Compra. A rotina enviara in-  º±±
±±º          ³        formacoes a respeito do pedido de compra detalhando º±±
±±º          ³        os itens para o aprovador ficar ciente.             º±±
±±º          ³ Aplicado em : 13/10/14                                     º±±
±±º          ³ Z17 -> Inclusao de solicitacao ao armazem. A rotina enviaraº±±
±±º          ³        informacoes a respeito da S.A. detalhando os itens  º±±
±±º          ³        que foram solicitados pelo usuario.                 º±±
±±º          ³ Aplicado em : 18/04/16                                     º±±
/*/
User Function MAVALMMAIL

Local aPars := PARAMIXB
Local lSend := .T.
Local aAreaAtual := GetArea()
Local cNumSC := ""
Local cQ     := ""
Local cMens  := ""

Local cServer  := Alltrim(GetMV("MV_RELSERV"))			//"smtp.suaconta.com.br"
Local cPass    := Alltrim(GetMV("MV_RELPSW"))			//Space(25)
Local cAccount := Alltrim(GetMV("MV_RELACNT"))			//"seu@email.com.br"
Local cUserAut := Alltrim(GetMv("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email
Local cPassAut := Alltrim(GetMv("MV_RELAPSW",,cPass))	//Senha para Autenticação no Servidor de Email
Local lAutentica  := GetMv("MV_RELAUTH",,.F.)			//Determina se o Servidor de Email necessita de Autenticação
Local cAssunto := ""
Local aItensSC := {}
Local cAux     := ""
Local lOk      := .F.
Local nTotRegs :=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto atingiu ponto de pedido.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If aPars[1] == "001"
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+aPars[2][1]))

	If (Alltrim(aPars[2][3]) <> "05" .and. SB1->B1_GRUPO <> "0010")
		lSend := .F.
	Endif
Endif
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de Solicitacao de Compra.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If aPars[1] == "035"

 	aAreaSC1  := SC1->(GetArea())
	cUsrSolic := SC1->C1_USER
	cNumSC    := aPars[2][1]
	cArmaz    := SC1->C1_LOCAL
	cCCusto   := SC1->C1_CC
	cAssunto  := "Inclusao de Solicitacao de Compra - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)

	PswOrder(1)
	PswSeek(cUsrSolic,.T.)
	aUsuario := PswRet(1)
	cNomUsr  := AllTrim(aUsuario[1,4])

	cQ += "SELECT DISTINCT ZC_APROVAD FROM "+RetSQLName("SZC")+" SZC "
	cQ += "WHERE SZC.ZC_FILIAL = '"+xFilial("SZC")+"' AND "
	cQ += "SZC.ZC_SOLICIT = '"+cUsrSolic+"' AND "
	cQ += "(SZC.ZC_LOCAL = '"+cArmaz+"' OR SZC.ZC_LOCAL = '**') AND "
	cQ += "(SZC.ZC_CCUSTO = '"+cCCusto+"' OR SZC.ZC_CCUSTO = '**') AND "
	cQ += "SZC.D_E_L_E_T_ <> '*'"

	If Select("WRK1") > 0
		WRK1->(dbCloseArea())
	Endif

	cQ := ChangeQuery(cQ)
	TcQuery cQ New Alias "WRK1"

	dbSelectArea("WRK1")

	cEMailAprv := ""
	cNomAprv   := ""
	While !Eof()
		PswOrder(1)
		PswSeek(WRK1->ZC_APROVAD,.T.)
		aUsuario   := PswRet(1)
		cEMailAprv += IIF(!Empty(cEMailAprv),";","")+AllTrim(aUsuario[1,14])
		cNomAprv   += IIF(!Empty(cNomAprv),", ","")+AllTrim(aUsuario[1,4])
		dbSelectArea("WRK1")
		dbSkip()
	Enddo

	WRK1->(dbCloseArea())

	If !Empty(cEMailAprv)

		dbSelectArea("SC1")
		dbSetOrder(1)
		dbSeek(xFilial("SC1")+cNumSC)
		While !Eof() .and. SC1->C1_FILIAL==xFilial("SC1") .and. SC1->C1_NUM==cNumSC
			aadd(aItensSC , {C1_ITEM , C1_PRODUTO , C1_DESCRI , Alltrim(Transform(C1_QUANT,"@E 999,999,999.99")) , C1_LOCAL , Dtoc(C1_DATPRF) , C1_OBS})
			dbSkip()
		Enddo

		cMens := "A Solicitação de Compra nº '+cNumSC+' foi incluída pelo usuário '+cNomUsr+' e aguarda sua aprovação.<br><br>Itens desta Solicitação:<br>"
		aCab  := {"Item","Código","Descrição","Qtde","Armazém","Data da Necessidade","Observação"}
		cMens := u_GetHTML(aCab,aItensSC,cMens,cNomAprv)

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lOk

		If lOk .and. lAutentica
			If !MailAuth(cUserAut,cPassAut)
		        DISCONNECT SMTP SERVER RESULT lOk
			EndIf
		EndIf

		If lOk
			SEND MAIL FROM cAccount TO cEMailAprv SUBJECT cAssunto BODY cMens RESULT lOk
		Endif

		DISCONNECT SMTP SERVER RESULT lOk

   	Endif
	lSend := lOk
   	RestArea(aAreaSC1)
ElseIf aPars[1] == "030"  //Inclusao de Nota de Entrada         
	lCont := .F.
	If aPars[2][6] == 3  // so considero inclusao
		SD1->(dbSetOrder(1))
		If SD1->(dbSeek(xFilial("SD1")+aPars[2][1]+aPars[2][2]+aPars[2][3]+aPars[2][4]))
			While SD1->(Eof()) .and. SD1->D1_FILIAL==xFilial("SD1") .and. SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) ==;
		     aPars[2][1]+aPars[2][2]+aPars[2][3]+aPars[2][4]
				If SD1->D1_LOCAL == "05"
					lCont := .T.
				Endif
				SD1->(dbSkip())
			Enddo
		Endif
	Endif
	lSend := lCont
Endif
*/


/*If aPars[1] == "037" //Aviso ao Aprovador do Pedido de compra para fazer a liberacao.
	cNumPC    := aPars[2][1]
	cNumCot   := aPars[2][2]
	cGrupApr  := aPars[2][3]
	cStatPC   := aPars[2][4]
	cUserPC   := aPars[2][5]
	cEMailAprv := ""
	cNomAprv   := ""
	aItensPC   := {}
 	aAreaSC7  := SC7->(GetArea())
 	cAssunto  := "Inclusao de Pedido de Compra - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
	
	cQ := " SELECT SCR.CR_USER FROM "+RetSQLName("SCR")+" SCR "
	cQ += " where SCR.CR_TIPO = 'IP' "
	cQ += " and SCR.CR_FILIAL = '"+xFilial("SCR")+"' "
	cQ += " and SCR.D_E_L_E_T_ = ' '
	cQ += " and SCR.CR_NUM = '"+cNumPC+"' "
	cQ += " and SCR.CR_DATALIB = ' ' "
	cQ += " and SCR.CR_NIVEL in (select MIN(SCR1.CR_NIVEL) from "+RetSQLName("SCR")+" SCR1 where SCR1.D_E_L_E_T_ = ' ' and SCR1.CR_NUM = '"+cNumPC+"' and SCR1.CR_FILIAL = '"+xFilial("SCR")+"' and SCR1.CR_TIPO = 'IP' AND SCR1.CR_DATALIB = ' ')
	
	
//If !Empty(cGrupApr)
	If Select("WRK1") > 0
		WRK1->(dbCloseArea())
	endif
	
	cQ := ChangeQuery(cQ)
	TcQuery cQ New Alias "WRK1"
	
	nTotRegs := WRK1->(RECCOUNT())
		
	if nTotReg >0 
		dbSelectArea("WRK1")

		While !Eof()
			PswOrder(1)
			PswSeek(WRK1->CR_USER,.T.)
			aUsuario   := PswRet(1)
			cEMailAprv += IIF(!Empty(cEMailAprv),";","")+AllTrim(aUsuario[1,14])
			cNomAprv   += IIF(!Empty(cNomAprv),", ","")+AllTrim(aUsuario[1,4])
			dbSelectArea("WRK1")
			dbSkip()
		Enddo

		cEmailUsr += "regis.ferreira@totvs.com.br"
		WRK1->(dbCloseArea())

		If !Empty(cEMailAprv)

			dbSelectArea("SC7")
			dbSetOrder(1)
			dbSeek(xFilial("SC7")+cNumPC)
			While !Eof() .and. SC7->C7_FILIAL==xFilial("SC7") .and. SC7->C7_NUM==cNumPC
				aadd(aItensPC , {C7_ITEM , C7_PRODUTO , C7_DESCRI , Alltrim(Transform(C7_QUANT,"@E 999,999,999.99")) , C7_LOCAL , Dtoc(C7_DATPRF) , C7_OBS})
				dbSkip()
			Enddo

			If Val(StrTran(Time(),":","")) < 120000
				cAux := "Bom dia,"
			ElseIf Val(StrTran(Time(),":","")) < 180000
				cAux := "Boa tarde,"
			Else
				cAux := "Boa noite,"
			Endif

			cMens += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
			cMens += '<html><head><title>Aviso de Inclusão de Pedido de Compra</title>'
			cMens += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cMens += '<meta content="MSHTML 6.00.6000.16850" name="GENERATOR"></head>'
			cMens += '<body bgcolor="#ffffff">'
			cMens += '<p><font color="#0000ff" size="4" face="Gautami">'+cAux+' Sr(a) '+cNomAprv+'</font></p>'
			cMens += '</font></p><br>'
			cMens += '<p><font color="#0000ff" size="4" face="Gautami">O Pedido de Compra nº '+cNumPC+' foi incluído pelo usuário '+cUserPC+' e aguarda sua aprovação.</font></p>'
			cMens += '<br>'
			cMens += '<p><font color="#0000ff" face="Gautami" size="4">Itens deste Pedido:</font></p>
			cMens += '<table border="1" cellpadding="3" cellspacing="0" style="width: 100%">
			cMens += '<tbody>
			cMens += '<tr>
			cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Item</span></td>'
			cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Código</span></td>'
			cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Descrição</span></td>'
			cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Qtde</span></td>'
			cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Armazém</span></td>'
			cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Data da Necessidade</span></td>'
			cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Observação</span></td>'
			cMens += '</tr>'
			For nI:=1 to Len(aItensPC)
				cMens += '<tr>'
				cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aItensPC[nI,1]+'</font></td>'
				cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aItensPC[nI,2]+'</font></td>'
				cMens += '<td bordercolor="#400040"><p align="left"><font color="#0000ff" face="Gautami">'+aItensPC[nI,3]+'</font></td>'
				cMens += '<td bordercolor="#400040"><p align="right"><font color="#0000ff" face="Gautami">'+aItensPC[nI,4]+'</font></td>'
				cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aItensPC[nI,5]+'</font></td>'
				cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aItensPC[nI,6]+'</font></td>'
				cMens += '<td bordercolor="#400040"><p align="left"><font color="#0000ff" face="Gautami">'+aItensPC[nI,7]+'</font></td>'
				cMens += '</tr>'
			Next
			cMens += '</tbody>'
			cMens += '</table>'
			cMens += '</font></p>'
			cMens += '<br>'
			cMens += '<p><strong><font color="#0000ff" size="2" face="Arial">E-mail automático enviado pelo módulo SIGACOM.</font></strong></p></body></html>'

			CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lOk

			If lOk .and. lAutentica
				If !MailAuth(cUserAut,cPassAut)
			        DISCONNECT SMTP SERVER RESULT lOk
				EndIf
			EndIf

			If lOk
				SEND MAIL FROM cAccount TO cEMailAprv SUBJECT cAssunto BODY cMens RESULT lOk
			Endif

			DISCONNECT SMTP SERVER RESULT lOk

		    If lOk
		   		lSend := .F.
	   		Endif

   		Endif

	Else

	    lSend := .F.

	Endif

   	RestArea(aAreaSC7)

Endif
*/

If aPars[1] == "002" //Produto atingiu estoque negativo
	If (Substr(aPars[2][1],1,3) == 'MOD' .or. Alltrim(aPars[2][3]) == '99')
		lSend := .F.
	Endif
Endif

/*
If aPars[1] == "003"  //Solicitacao de Compra com cotacao pendente ³

	cEMailDest := ""
	cQ         := ""
	cNumCot    := aPars[2][1]
	cAssunto   := "Solicitacao de Compra com cotacao pendente - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)

	cQ += "SELECT AN_USER FROM "+RetSQLName("SAN")+" SAN "
	cQ += "WHERE SAN.AN_FILIAL = '"+xFilial("SAN")+"' AND "
	cQ += "SAN.AN_EVENTO = '003' AND "
	cQ += "SAN.D_E_L_E_T_ <> '*'"

	If Select("WRK1") > 0
		WRK1->(dbCloseArea())
	Endif

	cQ := ChangeQuery(cQ)
	TcQuery cQ New Alias "WRK1"

	dbSelectArea("WRK1")

	While !Eof()
		PswOrder(1)
		PswSeek(WRK1->AN_USER,.T.)
		aUsuario   := PswRet(1)
		cEMailDest += IIF(!Empty(cEMailDest),";","")+AllTrim(aUsuario[1,14])
		dbSelectArea("WRK1")
		dbSkip()
	Enddo

	WRK1->(dbCloseArea())

	If Val(StrTran(Time(),":","")) < 120000
		cAux := "Bom dia,"
	ElseIf Val(StrTran(Time(),":","")) < 180000
		cAux := "Boa tarde,"
	Else
		cAux := "Boa noite,"
	Endif

	cMens += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
	cMens += '<html><head><title>Aviso de S.C. com cotação pendente</title>'
	cMens += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cMens += '<meta content="MSHTML 6.00.6000.16850" name="GENERATOR"></head>'
	cMens += '<body bgcolor="#ffffff">'
	cMens += '<font color="#0000ff" size="4" face="Gautami">'+cAux+'</font>'
	cMens += '<font size="1"><br></font>'
	cMens += '<p><font color="#0000ff" size="4" face="Gautami">A cotação nº '+cNumCot+' aguarda pelos trâmites do processo de análise de cotação.</font></p>'
	cMens += '<br>'
	cMens += '</font></p>'
	cMens += '<br>'
	cMens += '<p><strong><font color="#0000ff" size="2" face="Arial">E-mail automático enviado pelo módulo SIGACOM.</font></strong></p></body></html>'

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lOk

	If lOk .and. lAutentica
		If !MailAuth(cUserAut,cPassAut)
	        DISCONNECT SMTP SERVER RESULT lOk
		EndIf
	EndIf

	If lOk
		SEND MAIL FROM cAccount TO cEMailDest SUBJECT cAssunto BODY cMens RESULT lOk
	Endif

	DISCONNECT SMTP SERVER RESULT lOk

    If lOk
   		lSend := .F.
	Endif

Endif
*/

If aPars[1] == "034" //Liberacao de pedido de compra

	If aPars[2][2] == 'PC'  // Se for CP (contrato de parceria) deixo a rotina enviar a mensagem padrao

		cNumPC     := aPars[2][1]
		cEMailDest := ""
		cQ         := ""
		cAssunto   := "Liberacao de pedido para compra - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)

		cQ += "SELECT AN_USER FROM "+RetSQLName("SAN")+" SAN "
		cQ += "WHERE SAN.AN_FILIAL = '"+xFilial("SAN")+"' AND "
		cQ += "SAN.AN_EVENTO = '034' AND "
		cQ += "SAN.D_E_L_E_T_ <> '*'"

		If Select("WRK1") > 0
			WRK1->(dbCloseArea())
		Endif

		cQ := ChangeQuery(cQ)
		TcQuery cQ New Alias "WRK1"

		dbSelectArea("WRK1")

		While !Eof()
			PswOrder(1)
			PswSeek(WRK1->AN_USER,.T.)
			aUsuario   := PswRet(1)
			cEMailDest += IIF(!Empty(cEMailDest),";","")+AllTrim(aUsuario[1,14])
			dbSelectArea("WRK1")
			dbSkip()
		Enddo

		WRK1->(dbCloseArea())

		If Val(StrTran(Time(),":","")) < 120000
			cAux := "Bom dia,"
		ElseIf Val(StrTran(Time(),":","")) < 180000
			cAux := "Boa tarde,"
		Else
			cAux := "Boa noite,"
		Endif

		cMens += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
		cMens += '<html><head><title>Liberacao de Pedido de Compra</title>'
		cMens += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		cMens += '<meta content="MSHTML 6.00.6000.16850" name="GENERATOR"></head>'
		cMens += '<body bgcolor="#ffffff">'
		cMens += '<font color="#0000ff" size="4" face="Gautami">'+cAux+'</font>'
		cMens += '<font size="1"><br></font>'
		cMens += '<p><font color="#0000ff" size="4" face="Gautami">O pedido nº '+cNumPC+' foi liberado para compra.</font></p>'
		cMens += '<br>'
		cMens += '</font></p>'
		cMens += '<br>'
		cMens += '<p><strong><font color="#0000ff" size="2" face="Arial">E-mail automático enviado pelo módulo SIGACOM.</font></strong></p></body></html>'

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lOk

		If lOk .and. lAutentica
			If !MailAuth(cUserAut,cPassAut)
		        DISCONNECT SMTP SERVER RESULT lOk
			EndIf
		EndIf

		If lOk
			SEND MAIL FROM cAccount TO cEMailDest SUBJECT cAssunto BODY cMens RESULT lOk
		Endif

		DISCONNECT SMTP SERVER RESULT lOk

	    If lOk
	   		lSend := .F.
		Endif

	Else

		lSend := .T.

	Endif

Endif

If aPars[1] == "Z17"  //Inclusao de Solicitacao ao armazem 
	cAssunto := "Inclusao de Solicitacao ao Armazem - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
	cQ := "SELECT AN_USER FROM "+RetSQLName("SAN")+" SAN "
	cQ += "WHERE SAN.AN_FILIAL = '"+xFilial("SAN")+"' AND "
	cQ += "SAN.AN_EVENTO = 'Z17' AND "
	cQ += "SAN.D_E_L_E_T_ <> '*'"
	TcQuery cQ New Alias "WRK1"
	While !Eof()
		PswOrder(1)
		PswSeek(WRK1->AN_USER,.T.)
		aUsuario   := PswRet(1)
		cEMailDest := AllTrim(aUsuario[1,14])
		cNomeDest  := AllTrim(aUsuario[1,4])
		lOk        := .F.
		If !Empty(cEMailDest)
			For nSA:=1 To Len(aPars[2])
				aItensSA := {}
				dbSelectArea("SCP")
				dbSetOrder(1)
				dbSeek(aPars[2][nSA][1]+aPars[2][nSA][2])
				While !Eof() .and. SCP->CP_FILIAL==aPars[2][nSA][1] .and. SCP->CP_NUM==aPars[2][nSA][2]
					cNumSA  := SCP->CP_NUM
					cNomUsr := SCP->CP_SOLICIT
					aadd(aItensSA , {CP_ITEM , CP_PRODUTO , CP_DESCRI , Alltrim(Transform(CP_QUANT,"@E 999,999,999.99")) , CP_CC , Dtoc(CP_DATPRF) , CP_OBS})
					dbSkip()
				Enddo
			Next nSA
			cMens := "A Solicitação ao Armazém nº "+cNumSA+" foi incluída pelo usuário "+cNomUsr+" e aguarda pela liberação dos itens descritos abaixo.<br>Itens desta Solicitação:<br>"
			aCab := {"Item","Código","Descrição","Qtde","Centro de Custo","Data da Necessidade","Observação"}
			cMens := u_GetHTML(aCab,aItensSA,cMens,cNomeDest)
			CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lOk
			If lOk .and. lAutentica
				If !MailAuth(cUserAut,cPassAut)
			        DISCONNECT SMTP SERVER RESULT lOk
				EndIf
			EndIf
			If lOk
				SEND MAIL FROM cAccount TO cEMailDest SUBJECT cAssunto BODY cMens RESULT lOk
			Endif
			DISCONNECT SMTP SERVER RESULT lOk
		Endif
		WRK1->(dbSkip())
	Enddo
	WRK1->(dbCloseArea())
    If lOk
   		lSend := .F.
   	Endif
Endif

RestArea(aAreaAtual)

Return lSend
