#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"

/*/{protheus.doc}MT097END 
No final da rotina de liberacao do pedido de compra (mata097). Atualiza a data de entrega do pedido contando novo prazo a partir da data de aprovacao.
@Author Marcos Candido 
@since 09/10/15  
*/
User Function MT097END 

Local aDados     := PARAMIXB	// cDocto,cTipo,nOpc,cFilDoc
Local aAreaAtual := GetArea()
Local dDtAprv    := CtoD(Space(8))
Local cQ       := ""  
Local nPrazo   := 0
Local aDadosPC := {}
Local cAux     := "" , cMens := ""
Local cNomSolic   := ""
Local cEMailSolic := ""
Local cNumPC := aDados[1]

Local cServer  := Alltrim(GetMV("MV_RELSERV"))			//"smtp.suaconta.com.br"
Local cPass    := Alltrim(GetMV("MV_RELPSW"))			//Space(25)
Local cAccount := Alltrim(GetMV("MV_RELACNT"))			//"seu@email.com.br"
Local cUserAut := Alltrim(GetMv("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email
Local cPassAut := Alltrim(GetMv("MV_RELAPSW",,cPass))	//Senha para Autenticação no Servidor de Email
Local lAutentica  := GetMv("MV_RELAUTH",,.F.)			//Determina se o Servidor de Email necessita de Autenticação
Local cAssunto := "Aprovacao de Pedido de Compra - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
Local lOk      := .F.

If aDados[2]=="PC" .and. aDados[3]==2 // Eh pedido de compra e o aprovou

	cQ += "SELECT DISTINCT CR_DATALIB FROM "+RetSQLName("SCR")+" SCR "
	cQ += "WHERE SCR.CR_FILIAL = '"+xFilial("SCR")+"' AND "
	cQ += "SCR.CR_TIPO = '"+aDados[2]+"' AND "
	cQ += "SCR.CR_NUM = '"+cNumPC+"' AND "
	cQ += "SCR.CR_DATALIB <> ' ' AND "
	cQ += "SCR.D_E_L_E_T_ <> '*'"

	If Select("WRK1") > 0
		WRK1->(dbCloseArea())
	Endif	

	cQ := ChangeQuery(cQ)
	TcQuery cQ New Alias "WRK1"	

	dbSelectArea("WRK1")     
	dDtAprv := StoD(WRK1->CR_DATALIB)
	WRK1->(dbCloseArea())
	
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek(xFilial("SC7")+Alltrim(cNumPC),.T.)
	
	While !Eof() .and. xFilial("SC7")==aDados[4] .and. C7_NUM == Alltrim(cNumPC)
		nPrazo := SC7->C7_DATPRF - SC7->C7_EMISSAO
		RecLock("SC7",.F.)
		  C7_DATPRF := dDtAprv+iif(nPrazo <= 0 , 1 , nPrazo)
		MsUnlock()
		dbCommit()

		If aScan(aDadosPC , {|z| z[1]+z[2]==SC7->(C7_NUMSC+C7_ITEMSC)}) == 0
			SC1->(dbSetOrder(1))
			If SC1->(dbSeek(xFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))
				aadd(aDadosPC , {SC7->C7_NUMSC , SC7->C7_ITEMSC , SC7->C7_PRODUTO , SC7->C7_DESCRI , Alltrim(Transform(SC7->C7_QUANT,"@E 999,999,999.99")),;
			                   DtoC(SC7->C7_DATPRF) , Alltrim(SC7->C7_OBS) , Alltrim(Transform(SC1->C1_QUANT,"@E 999,999,999.99")) , DtoC(SC1->C1_DATPRF) , SC1->C1_USER})
			Endif
		Endif
		
		dbSkip()
	Enddo

	If Val(StrTran(Time(),":","")) < 120000
		cAux := "Bom dia,"
	ElseIf Val(StrTran(Time(),":","")) < 180000
		cAux := "Boa tarde,"
	Else
		cAux := "Boa noite,"
	Endif	

	For nD:=1 to Len(aDadosPC)
		PswOrder(1)
		PswSeek(aDadosPC[nD][10],.T.)
		aUsuario    := PswRet(1)
		If !(AllTrim(aUsuario[1,4]) $ cNomSolic)
			cNomSolic   += IIF(!Empty(cNomSolic),", ","")+AllTrim(aUsuario[1,4])
		Endif
		If !(AllTrim(aUsuario[1,14]) $ cEMailSolic)
			cEMailSolic += IIF(!Empty(cEMailSolic),";","")+AllTrim(aUsuario[1,14])
		Endif
		aDadosPC[nD][7] += " (Usuário: "+Alltrim(aUsuario[1,2])+")"
	Next

	cMens += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
	cMens += '<html><head><title>Aviso de Aprovação de Pedido de Compra</title>'
	cMens += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cMens += '<meta content="MSHTML 6.00.6000.16850" name="GENERATOR"></head>'
	cMens += '<body bgcolor="#ffffff">'
	cMens += '<p><font color="#0000ff" size="4" face="Gautami">'+cAux+' Sr(a) '+cNomSolic+'</font></p>'
	cMens += '</font></p><br>'
	cMens += '<p><font color="#0000ff" size="4" face="Gautami">O Pedido de Compra nº '+Alltrim(cNumPC)+' foi aprovado em atendimento à sua Solicitação de Compra.</font></p>'
	cMens += '<br>'	
	cMens += '<p><font color="#0000ff" face="Gautami" size="4">Itens deste Pedido conforme a Solicitação:</font></p>
	cMens += '<table border="1" cellpadding="3" cellspacing="0" style="width: 100%">
	cMens += '<tbody>
	cMens += '<tr>
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Num. S.C.</span></td>'	
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Item S.C.</span></td>'
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Código</span></td>'
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Descrição</span></td>'
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Qtde S.C.</span></td>'
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Data da Necess. S.C.</span></td>'
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Qtde P.C.</span></td>'
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Data da Entrega P.C.</span></td>'
	cMens += '<td bordercolor="#400040" style="text-align: center"><span style="color: #0000cd">Observação P.C.</span></td>'
	cMens += '</tr>'
	For nI:=1 to Len(aDadosPC)
		cMens += '<tr>'
		cMens += '<td bordercolor="#400040"><p align="left"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,1]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,2]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="left"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,3]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="left"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,4]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="right"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,8]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,9]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="right"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,5]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,6]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="left"><font color="#0000ff" face="Gautami">'+aDadosPC[nI,7]+'</font></td>'
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
		SEND MAIL FROM cAccount TO cEMailSolic SUBJECT cAssunto BODY cMens RESULT lOk
	Endif
		
	DISCONNECT SMTP SERVER RESULT lOk		   		

Endif	

RestArea(aAreaAtual)

Return	