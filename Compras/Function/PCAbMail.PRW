#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} PcAbMail
Rotina que ira disparar e-mails automaticamente ao comprador, avisando-o que ha pedidos de compra em aberto e que estao atrasados em sua entrega.
@author Marcos Candido
@since 02/01/2018
/*/
User Function PcAbMail(aParam)

Local cQuery   := ""
Local cDestino := ""
Local aPedidos := {}
Local cMens    := ""
Local cAssunto := ""

Local cServer  := ""
Local cPass    := ""
Local cAccount := ""
Local cUserAut := ""
Local cPassAut := ""
Local lAutentica  := .T.
Local lOk := .F.

//VarInfo("valores de aParam",aParam)

PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] Tables 'SC7,SA2,SB1' Modulo 'COM'

cDestino := Alltrim(GetMV("MV_EMAILCO"))
cServer  := Alltrim(GetMV("MV_RELSERV"))				//"smtp.suaconta.com.br"
cPass    := Alltrim(GetMV("MV_RELPSW"))					//Space(25)
cAccount := Alltrim(GetMV("MV_RELACNT"))				//"seu@email.com.br"
cUserAut := Alltrim(GetMv("MV_RELAUSR",,cAccount))		//Usuário para Autenticação no Servidor de Email
cPassAut := Alltrim(GetMv("MV_RELAPSW",,cPass))		//Senha para Autenticação no Servidor de Email
lAutentica  := GetMv("MV_RELAUTH",,.F.)				//Determina se o Servidor de Email necessita de Autenticação

cAssunto := "Aviso de Pedidos de Compra Nao Entregues"
cAssunto += " - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
aPedidos := {}
cQuery   := ""
cMens    := ""

ConOut("Iniciando rotina PcAbMail.PRW. Inicio: "+Time()+" - "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL))

cQuery += "SELECT C7_FORNECE, C7_LOJA, C7_NUM, C7_ITEM, C7_QUANT, C7_QUJE, C7_DATPRF, C7_CONAPRO, C7_PRODUTO "
cQuery += "FROM "+RetSQLName("SC7")+" SC7 "
cQuery += "WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"' AND "
cQuery += "SC7.C7_QUJE < SC7.C7_QUANT AND C7_DATPRF < '"+DtoS(dDataBase)+"' AND "
cQuery += "SC7.C7_CONAPRO = 'L' AND "
cQuery += "SC7.C7_RESIDUO = ' ' AND "
cQuery += "SC7.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY C7_FORNECE,C7_LOJA,C7_NUM"
/*
SELECT C7_FORNECE, C7_LOJA, C7_NUM, C7_ITEM, C7_QUANT, C7_QUJE, C7_DATPRF, C7_CONAPRO, C7_PRODUTO
FROM SC7010 SC7
WHERE SC7.C7_FILIAL = '01' AND
SC7.C7_QUJE < SC7.C7_QUANT AND C7_DATPRF < '20150302' AND
SC7.C7_CONAPRO = 'L' AND
SC7.C7_RESIDUO = ' ' AND
SC7.D_E_L_E_T_ <> '*'
ORDER BY C7_FORNECE,C7_LOJA,C7_NUM
*/

If Select("WRK1") > 0
	WRK1->(dbCloseArea())
Endif

SA2->(dbSetOrder(1))
SB1->(dbSetOrder(1))

cQuery := ChangeQuery(cQuery)
TcQuery cQuery New Alias "WRK1"

dbSelectArea("WRK1")
dbGoTop()

While !Eof()

	SA2->(dbSeek(xFilial("SA2")+WRK1->(C7_FORNECE+C7_LOJA)))
	SB1->(dbSeek(xFilial("SB1")+WRK1->C7_PRODUTO))

	aadd(aPedidos , {WRK1->C7_NUM , WRK1->C7_ITEM , WRK1->C7_QUANT-WRK1->C7_QUJE , WRK1->C7_DATPRF ,;
	Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC) , Alltrim(SA2->A2_NOME)} )
	dbSkip()

Enddo

WRK1->(dbCloseArea())

If Len(aPedidos) > 0

	cMens += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"> '
	cMens += '<html><head><title>Aviso de Atraso</title>'
	cMens += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cMens += '<meta content="MSHTML 6.00.6000.16850" name="GENERATOR"></head>'
	cMens += '<body bgcolor="#cdcdcd">'
	cMens += '<p><font color="#0000ff" size="4" face="Gautami">Sr comprador</font></p>'
	If Len(aPedidos) > 1
		cMens += '<p><font><font face="Gautami"><font color=#0000ff><font size="4"> O sistema verificou que existem pedidos de compra que ainda não foram recebidos.</font></font>'
	Else
		cMens += '<p><font><font face="Gautami"><font color=#0000ff><font size="4"> O sistema verificou que existe pedido de compra que ainda não foi recebido.</font></font>'
	Endif
	cMens += '</font></p>'
	cMens += '<p><font color="#0000ff" face="Gautami"></font></font></p>'
	cMens += '<p><font color="#0000ff" >'
	cMens += '<table bordercolor="#400040" border="1" cellspacing="0"  cellpadding="3" width="100%" '
	cMens += 'align=center style="Z-INDEX: 0">'
	cMens += '<caption><font face="Gautami"><font color="#0000ff">Relação dos Pedidos de Compra em Aberto</font> </font>  </caption>  '
	cMens += '<tr>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Número do Pedido</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Item</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Produto</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Fornecedor</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Saldo a Entregar</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Data Prevista</font></p></td>'
	cMens += '</tr>'
	For nD:=1 to Len(aPedidos)
		cMens += '<tr>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aPedidos[nD,1]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aPedidos[nD,2]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aPedidos[nD,5]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aPedidos[nD,6]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+Alltrim(Transform(aPedidos[nD,3],"@E 999,999,999.999999"))+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+DtoC(StoD(aPedidos[nD,4]))+'</font></td>'
		cMens += '</tr>'
	Next
	cMens += '</table><fontface=verdana></font></p>'
	cMens += '<p><font color="#0000ff" face="Gautami">  '
	cMens += '</font>&nbsp;</p>'
	cMens += '<p><font color="#0000ff" face="Gautami">Verifique junto a seus fornecedores o motivo do atraso na entrega. '
	cMens += '</font><font > '
	cMens += '<br></p>'
	cMens += '<p><font color="#0000ff" size="2" '
	cMens += 'face=Arial><strong></strong></font></font>'
	cMens += '<font></font>&nbsp;</p>'
	cMens += '<p><font color="#0000ff" face="Arial" size="2"><strong></strong></font>&nbsp;</p>'
	cMens += '<p>'
	cMens += '<font color="#0000ff" face="Arial" size="2"><strong>Não responder este e-mail. Envio automático do '
	cMens += 'Protheus System - Version 12 by Totvs Software S.A. ®</strong></font></p></body></html>'

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lOk

	If lOk .and. lAutentica
		If !MailAuth(cUserAut,cPassAut)
			ConOut("Falha na autenticacao do usuario.")
			DISCONNECT SMTP SERVER RESULT lOk
			If !lOk
				GET MAIL ERROR cErrorMsg
				ConOut("E-Mail nao enviado ! Erro: "+cErrorMsg)
			EndIf
		EndIf
	EndIf

	If lOk
		//ConfirmMailRead(.T.)
		SEND MAIL FROM cAccount TO cDestino SUBJECT cAssunto BODY cMens RESULT lOk
	Endif

	If lOk
		ConOut("E-Mail enviado a "+cDestino)
	Else
		GET MAIL ERROR cErrorMsg
		ConOut("E-Mail não enviado ! Erro: "+cErrorMsg)
	Endif

	//ConfirmMailRead(.F.)
	DISCONNECT SMTP SERVER RESULT lOk

Endif

ConOut("Finalizando rotina PCAbMail.PRW. Termino: "+Time()+" - "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL))

RESET ENVIRONMENT

aParam := aSize(aParam,0)
aParam := Nil

Return
