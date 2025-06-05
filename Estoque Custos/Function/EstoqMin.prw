#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EstoqMin   ºAutor  ³ Marcos Candido   º Data ³  14/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que ira disparar e-mails automaticamente aos        º±±
±±º          ³ compradores para avisa-los sobre os produtos com saldo     º±±
±±º          ³ menor ou igual ao estoque minimo.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} EstoqMin
Dispara e-mails automaticamente aos compradores para avisa-los sobre os produtos com saldo menor ou igual ao estoque minimo.
@author Marcos Candido
@since 02/01/2018
/*/
User Function EstoqMin(aParam)

Local cQuery   := ""
Local cDestino := ""
Local aProdutos := {}
Local cMens    := ""
Local cAssunto := ""

Local cServer  := ""
Local cPass    := ""
Local cAccount := ""
Local cUserAut := ""
Local cPassAut := ""
Local lAutentica  := .T.
Local lOk := .F.
Local cObs := ""

//VarInfo("valores de aParam",aParam)

PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] Tables 'SB2,SB1' Modulo 'EST'

cDestino := Alltrim(GetMV("MV_EMAILCO"))
cDestin2 := Alltrim(GetMV("MV_EMAILC2"))
If !Empty(cDestin2)
	cDestino += ";"+cDestin2
Endif
cServer  := Alltrim(GetMV("MV_RELSERV"))				//"smtp.suaconta.com.br"
cPass    := Alltrim(GetMV("MV_RELPSW"))					//Space(25)
cAccount := Alltrim(GetMV("MV_RELACNT"))				//"seu@email.com.br"
cUserAut := Alltrim(GetMv("MV_RELAUSR",,cAccount))		//Usuário para Autenticação no Servidor de Email
cPassAut := Alltrim(GetMv("MV_RELAPSW",,cPass))		//Senha para Autenticação no Servidor de Email
lAutentica  := GetMv("MV_RELAUTH",,.F.)				//Determina se o Servidor de Email necessita de Autenticação

cAssunto := "Produtos com saldo menor ou igual ao estoque minimo"
cAssunto += " - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
aProdutos := {}
cQuery   := ""
cMens    := ""

ConOut("Iniciando rotina EstoqMin.PRW. Inicio: "+Time()+" - "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL))

SB1->(dbSetOrder(1))
SC7->(dbSetOrder(4))

dbSelectArea("SB2")
dbSetOrder(1)
dbGoTop()

While !Eof() .and. B2_FILIAL==xFilial("SB2")

//	If SM0->M0_CODIGO == '01' //processo unificado

		SB1->(dbSeek(xFilial("SB1")+SB2->B2_COD))

		If SB2->B2_LOCAL == '01' .and. SB1->B1_ESTSEG > 0

			nSaldoEst := CalcEst(SB2->B2_COD, SB2->B2_LOCAL, dDataBase+1)[1]

			If nSaldoEst <= SB1->B1_ESTSEG
				SC7->(dbSeek(xFilial("SC7")+SB2->B2_COD))
				cObs := ""
				While !SC7->(Eof()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_PRODUTO == SB2->B2_COD
					If SC7->C7_QUJE == 0 .AND. Empty(SC7->C7_RESIDUO) .and. SC7->C7_CONAPRO == 'L' .and. SC7->C7_ZZMAIL == 'S'
						cObs  += IIF(Empty(cObs),"",", ")+"PC Num.: "+SC7->C7_NUM+" - Qtde: "+Alltrim(Transform(SC7->C7_QUANT,"@E 999,999,999.99999"))+" - Dt Entr: "+DtoC(SC7->C7_DATPRF)
					Endif
					SC7->(dbSkip())
				Enddo
				aadd(aProdutos , {Alltrim(SB1->B1_COD) , Alltrim(SB1->B1_DESC) , SB1->B1_UM , SB1->B1_ESTSEG , nSaldoEst , SB2->B2_SALPEDI , cObs } )
			Endif

		Endif

/* processo unificado
	Else

		If SB2->B2_ZZPPEDI > 0 .AND. SB2->B2_LOCAL == '01'

			nSaldoEst := CalcEst(SB2->B2_COD, SB2->B2_LOCAL, dDataBase+1)[1]

			If nSaldoEst <= SB2->B2_ZZPPEDI
				SB1->(dbSeek(xFilial("SB1")+SB2->B2_COD))
				SC7->(dbSeek(xFilial("SC7")+SB2->B2_COD))
				cObs := ""
				While !SC7->(Eof()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_PRODUTO == SB2->B2_COD
					If SC7->C7_QUJE == 0 .AND. Empty(SC7->C7_RESIDUO) .and. SC7->C7_CONAPRO == 'L' .and. SC7->C7_ZZMAIL == 'S'
						cObs  += IIF(Empty(cObs),"",", ")+"PC Num.: "+SC7->C7_NUM+" - Qtde: "+Alltrim(Transform(SC7->C7_QUANT,"@E 999,999,999.99999"))+" - Dt Entr: "+DtoC(SC7->C7_DATPRF)
					Endif
					SC7->(dbSkip())
				Enddo
				aadd(aProdutos , {Alltrim(SB1->B1_COD) , Alltrim(SB1->B1_DESC) , SB1->B1_UM , SB2->B2_ZZPPEDI , nSaldoEst , SB2->B2_SALPEDI , cObs } )
			Endif

		Endif

	Endif
*/
	dbSelectArea("SB2")
	dbSkip()

Enddo

If Len(aProdutos) > 0

	cMens += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"> '
	cMens += '<html><head><title>Aviso de Estoque Minimo</title>'
	cMens += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cMens += '<meta content="MSHTML 6.00.6000.16850" name="GENERATOR"></head>'
	cMens += '<body bgcolor="#cdcdcd">'
	cMens += '<p><font color="#0000ff" size="4" face="Gautami">Sr comprador</font></p>'
	If Len(aProdutos) > 1
		cMens += '<p><font><font face="Gautami"><font color=#0000ff><font size="4"> O sistema verificou que existem produtos que estão com saldo em estoque iguais ou menores do que foi estabelecido como estoque mínimo.</font></font>'
	Else
		cMens += '<p><font><font face="Gautami"><font color=#0000ff><font size="4"> O sistema verificou que existe produto que está com saldo em estoque igual ou menor do que foi estabelecido como estoque mínimo.</font></font>'
	Endif
	cMens += '</font></p>'
	cMens += '<p><font color="#0000ff" face="Gautami"></font></font></p>'
	cMens += '<p><font color="#0000ff" >'
	cMens += '<table bordercolor="#400040" border="1" cellspacing="0"  cellpadding="3" width="100%" '
	cMens += 'align=center style="Z-INDEX: 0">'
	cMens += '<caption><font face="Gautami"><font color="#0000ff">Relação dos Produtos</font> </font>  </caption>  '
	cMens += '<tr>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Código do Produto</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Descrição do Produto</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Unidade de Medida</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Estoque Mínimo Estabelecido</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Saldo Atual em Estoque</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Previsão de Entrada (S.C. e P.C. em aberto)</font></p></td>'
	cMens += '<td bordercolor="#400040">'
	cMens += '<p align="center"><font color="#0000ff" face="Gautami">Informações Adicionais</font></p></td>'
	cMens += '</tr>'
	For nD:=1 to Len(aProdutos)
		cMens += '<tr>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aProdutos[nD,1]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aProdutos[nD,2]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aProdutos[nD,3]+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+Alltrim(Transform(aProdutos[nD,4],"@E 999,999,999.999999"))+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+Alltrim(Transform(aProdutos[nD,5],"@E 999,999,999.999999"))+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+Alltrim(Transform(aProdutos[nD,6],"@E 999,999,999.999999"))+'</font></td>'
		cMens += '<td bordercolor="#400040"><p align="center"><font color="#0000ff" face="Gautami">'+aProdutos[nD,7]+'</font></td>'
		cMens += '</tr>'
	Next
	cMens += '</table><fontface=verdana></font></p>'
	cMens += '<p><font color="#0000ff" face="Gautami">  '
	cMens += '</font>&nbsp;</p>'
    If Len(aProdutos) > 1
		cMens += '<p><font color="#0000ff" face="Gautami">Recomenda-se fazer uma avaliação sobre a necessidade de se comprar alguns desses itens, e verificar as Solicitações de Compra e Pedidos de Compra em aberto (caso existam). '
	Else
		cMens += '<p><font color="#0000ff" face="Gautami">Recomenda-se fazer uma avaliação sobre a necessidade de se comprar esse item, e verificar as Solicitações de Compra e Pedidos de Compra em aberto (caso existam). '
	Endif
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

ConOut("Finalizando rotina EstoqMin.PRW. Termino: "+Time()+" - "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL))

RESET ENVIRONMENT

aParam := aSize(aParam,0)
aParam := Nil

Return
