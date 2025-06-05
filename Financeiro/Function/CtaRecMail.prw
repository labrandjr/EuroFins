#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} CtaRecMail
Envia e-mails automaticamente aos clientes com duplicatas com mais de 3/10 dias em atraso. 

@author Marcos Candido
@since 04/01/2018
/*/
User Function CtaRecMail(aParam)

Local cQ1   := "" , cQ2 := ""
Local cDestino := ""
Local cRemete  := ""
Local cNomeCli := ""
Local aDupli   := {}
Local aEMailCli := {}
Local cEMailCli := ""
Local aInfo     := {}

PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] Tables 'SE1,SA1,SB1.SD2,SC5' Modulo 'FIN'

ConOut("Iniciando rotina CtaRecMail.PRW. Inicio: "+Time()+" - "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL))

// titulos vencidos
cQ1 += "SELECT E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, "
cQ1 += "E1_VENCTO, E1_VENCREA, E1_VALOR, E1_SALDO, A1_NOME, A1_CONTATO, A1_CGC "
cQ1 += "FROM "+RetSQLName("SE1")+" SE1, "+RetSQLName("SA1")+" SA1 "
cQ1 += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
cQ1 += "SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA AND "
cQ1 += "SE1.E1_VENCTO >= '20111101' AND "
cQ1 += "SE1.E1_VENCTO <= '"+DTOS(dDataBase-2)+"' AND SE1.E1_SALDO > 0 AND "
cQ1 += "SE1.E1_TIPO = 'NF ' AND "
cQ1 += "(SE1.E1_ZZDATA = SPACE(8) OR SE1.E1_ZZDATA < '"+DtoS(dDataBase-11)+"') AND "
cQ1 += "SA1.A1_ZZENVIO <> 'N' AND "
cQ1 += "SE1.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
cQ1 += "ORDER BY E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA"

// titulos vincendos
cQ2 += "SELECT E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, "
cQ2 += "E1_VENCTO, E1_VENCREA, E1_VALOR, E1_SALDO, A1_NOME, A1_CONTATO, A1_CGC "
cQ2 += "FROM "+RetSQLName("SE1")+" SE1, "+RetSQLName("SA1")+" SA1 "
cQ2 += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
cQ2 += "SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA AND "
cQ2 += "SE1.E1_VENCTO >= '"+DtoS(dDataBase)+"' AND SE1.E1_SALDO > 0 AND "
cQ2 += "SE1.E1_TIPO = 'NF ' AND "
cQ2 += "SA1.A1_ZZENVIO <> 'N' AND "
cQ2 += "SE1.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
cQ2 += "ORDER BY E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA"

If Select("WRK1") > 0
	WRK1->(dbCloseArea())
Endif
If Select("WRK2") > 0
	WRK2->(dbCloseArea())
Endif

cQ1 := ChangeQuery(cQ1)
TcQuery cQ1 New Alias "WRK1"

cQ2 := ChangeQuery(cQ2)
TcQuery cQ2 New Alias "WRK2"

dbSelectArea("WRK1")
dbGoTop()
cCliAnt   := WRK1->E1_CLIENTE+WRK1->E1_LOJA
cNomeCli  := WRK1->A1_NOME
cCNPJ     := WRK1->A1_CGC

While !Eof()

	If cCliAnt <> WRK1->E1_CLIENTE+WRK1->E1_LOJA
		For nE:=1 to Len(aEMailCli)
			cEMailCli += IIF(nE>1,";","")+aEMailCli[nE]
		Next
		aadd(aInfo , {aDupli , cNomeCli , cCliAnt , cEMailCli , cCNPJ})
		cCliAnt  := WRK1->E1_CLIENTE+WRK1->E1_LOJA
		cNomeCli := WRK1->A1_NOME
		cCNPJ    := WRK1->A1_CGC
		cEMailCli := ""
		aEMailCli := {}
		aDupli    := {}
	Endif

	nValTit  := 0
	nValIRRF := 0
	nValPIS  := 0
	nValCOFI := 0
	nValCSLL := 0
	nValLiq  := 0
	SE1->(dbSetOrder(2))
	SE1->(dbSeek(xFilial("SE1")+WRK1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)))
	While SE1->(!Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and.;
	   SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA) == WRK1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
		If SE1->E1_TIPO == "NF "
			nValTit += SE1->E1_VALOR
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizo a data que o e-mail foi enviado para criar controle ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SE1",.F.)
			  SE1->E1_ZZDATA := dDataBase
			MsUnlock()
        ElseIf SE1->E1_TIPO == "IR-"
        	nValIRRF += SE1->E1_VALOR
		Elseif SE1->E1_TIPO == "PI-"
            nValPIS += SE1->E1_VALOR
		ElseIf SE1->E1_TIPO == "CF-"
  			nValCOFI += SE1->E1_VALOR
		ElseIf SE1->E1_TIPO == "CS-"
			nValCSLL += SE1->E1_VALOR
		Endif
        SE1->(dbSkip())
	Enddo

	nValLiq := nValTit - nValIRRF - nValPIS - nValCOFI - nValCSLL

	aadd(aDupli , {WRK1->E1_NUM , WRK1->E1_PARCELA , DtoC(STOD(WRK1->E1_EMISSAO)) ,;
	 DtoC(STOD(WRK1->E1_VENCTO)) , Alltrim(Transform(nValTit,"@E 999,999,999.99")) ,;
	 Alltrim(Transform(nValLiq,"@E 999,999,999.99")) , StrZero(dDataBase-STOD(WRK1->E1_VENCTO),4) , "1" })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura dos e-mails indicados nos pedidos de venda           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial("SD2")+WRK1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA))
	While !Eof() .and. SD2->D2_FILIAL==xFilial("SD2") .and.;
	      SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == WRK1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
			If aScan(aEMailCli , Alltrim(SC5->C5_NFEMAIL)) == 0
				aadd(aEMailCli , Alltrim(SC5->C5_NFEMAIL))
			Endif
		Endif
		dbSelectArea("SD2")
		dbSkip()
	Enddo

	dbSelectArea("WRK1")
	dbSkip()

Enddo

WRK1->(dbCloseArea())

dbSelectArea("WRK2")
dbGoTop()
cCliAnt   := WRK2->E1_CLIENTE+WRK2->E1_LOJA
cNomeCli  := WRK2->A1_NOME
cCNPJ     := WRK2->A1_CGC
cEMailCli := ""
aEMailCli := {}
aDupli    := {}

While !Eof()

	If cCliAnt <> WRK2->E1_CLIENTE+WRK2->E1_LOJA

		// aglutinar informacoes por cliente para que ele receba um unico email
		nLoc1 := aScan(aInfo , {|z| z[3] == cCliAnt})
		cEMailCli := ""

		For nE:=1 to Len(aEMailCli)
			If nLoc1 > 0
				If !(aEMailCli[nE] $ aInfo[nLoc1][4])
					If !Empty(aInfo[nLoc1][4])
						aInfo[nLoc1][4] += ";"+aEMailCli[nE]
					Else
						aInfo[nLoc1][4] += aEMailCli[nE]
					Endif
				Endif
			Else
				cEMailCli += IIF(nE>1,";","")+aEMailCli[nE]
			Endif
		Next

		aNewDupli := {}
		If nLoc1 > 0
			aNewDupli := aClone(aInfo[nLoc1][1])
			For nA:=1 to Len(aDupli)
				aadd(aNewDupli , {aDupli[nA][1] , aDupli[nA][2] , aDupli[nA][3] ,;
				    aDupli[nA][4] , aDupli[nA][5] , aDupli[nA][6] ,;
				     aDupli[nA][7] , aDupli[nA][8] })
			Next
			aInfo[nLoc1][1] := aNewDupli
		Else
			aadd(aInfo , {aDupli , cNomeCli , cCliAnt , cEMailCli , cCNPJ})
		Endif

		cCliAnt  := WRK2->E1_CLIENTE+WRK2->E1_LOJA
		cNomeCli := WRK2->A1_NOME
		cCNPJ    := WRK2->A1_CGC
		cEMailCli := ""
		aEMailCli := {}
		aDupli    := {}
	Endif

	nValTit  := 0
	nValIRRF := 0
	nValPIS  := 0
	nValCOFI := 0
	nValCSLL := 0
	nValLiq  := 0
	SE1->(dbSetOrder(2))
	SE1->(dbSeek(xFilial("SE1")+WRK2->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)))
	While SE1->(!Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and.;
	   SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA) == WRK2->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
		If SE1->E1_TIPO == "NF "
			nValTit += SE1->E1_VALOR
        ElseIf SE1->E1_TIPO == "IR-"
        	nValIRRF += SE1->E1_VALOR
		Elseif SE1->E1_TIPO == "PI-"
            nValPIS += SE1->E1_VALOR
		ElseIf SE1->E1_TIPO == "CF-"
  			nValCOFI += SE1->E1_VALOR
		ElseIf SE1->E1_TIPO == "CS-"
			nValCSLL += SE1->E1_VALOR
		Endif
        SE1->(dbSkip())
	Enddo

	nValLiq := nValTit - nValIRRF - nValPIS - nValCOFI - nValCSLL

	aadd(aDupli , {WRK2->E1_NUM , WRK2->E1_PARCELA , DtoC(STOD(WRK2->E1_EMISSAO)) ,;
	 DtoC(STOD(WRK2->E1_VENCTO)) , Alltrim(Transform(nValTit,"@E 999,999,999.99")) ,;
	 Alltrim(Transform(nValLiq,"@E 999,999,999.99")) , 0 , "2"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura dos e-mails indicados nos pedidos de venda           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial("SD2")+WRK2->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA))
	While !Eof() .and. SD2->D2_FILIAL==xFilial("SD2") .and.;
	      SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == WRK2->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
			If aScan(aEMailCli , Alltrim(SC5->C5_NFEMAIL)) == 0
				aadd(aEMailCli , Alltrim(SC5->C5_NFEMAIL))
			Endif
		Endif
		dbSelectArea("SD2")
		dbSkip()
	Enddo

	dbSelectArea("WRK2")
	dbSkip()

Enddo

WRK2->(dbCloseArea())

// ordenar por Cod.Cliente+Loja
aSort(aInfo,,,{|x,y| x[3] < y[3]})

For nG:=1 to Len(aInfo)
	Mensagem(aInfo[nG])
Next nG

ConOut("Finalizando rotina CtaRecMail.PRW. Termino: "+Time()+" - "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL))

RESET ENVIRONMENT

aParam := aSize(aParam,0)
aParam := Nil

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Mensagem ºAutor  ³ Marcos Candido     º Data ³  18/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formata mensagem a ser enviada por email aos responsaveis  º±±
±±º          ³ do setor financeiro do cliente que esta com duplicatas em  º±±
±±º          ³ aberto e a vencer                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Eurofins                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mensagem(aDados)

Local cMens    := "" , cTXT := ""
Local cAssunto := "Titulos Vencidos / A Vencer"  // "Aviso de Cobranca"
Local aDestino := {}
Local cAux     := IIF(Len(Alltrim(aDados[5]))==14,'CNPJ: '+Transform(aDados[5],"@R 99.999.999/9999-99"),IIF(Len(Alltrim(aDados[5]))==11,'CPF: '+Transform(aDados[5],"@R 999.999.999-99"),""))
Local cEst     := Posicione("SA1",1,xFilial("SA1")+aDados[3],"A1_EST")

Local cServer  := Alltrim(GetMV("MV_RELSERV"))			//"smtp.suaconta.com.br"
Local cPass    := "Euro@123"
Local cAccount := "financeiro@eurofins.com"
Local cUserAut := Alltrim(GetMv("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email
Local cPassAut := Alltrim(GetMv("MV_RELAPSW",,cPass))	//Senha para Autenticação no Servidor de Email
Local lAutentica  := GetMv("MV_RELAUTH",,.F.)			//Determina se o Servidor de Email necessita de Autenticação
Local lOk := .F.
//Local cCopia := "denisecarnelos@eurofins.com.br;financeiro@eurofins.com.br"
Local cCopia := "financeiro@eurofins.com"
Local cEMailCli := aDados[4]

If cEst <> 'EX'
	// texto para os titulos vencidos
	cTXT00 := 'À empresa '
	cTXT01 := 'Prezado cliente, '
	cTXT02 := 'Constam em nossos registros, as seguintes notas fiscais em aberto em nosso contas a receber.'
	cTXT03 := 'Pedimos, por gentileza, que verifique essa relação e nos posicione através dos e-mails denisecarnelos@eurofins.com e brunobertanha@eurofins.com ou pelos telefones (19) 2107-5507 e (19) 2107-5506.'
	cTXT04 := 'Caso as notas fiscais já tenham sido pagas, pedimos por gentileza, que encaminhe os comprovantes de pagamento, auxiliando-nos na baixa das mesmas em nosso sistema.'
	// texto para os titulo vincendos
	cTXT05 := 'A seguir, as notas fiscais emitidas recentemente e com data de vencimento futura.'
	cTXT06 := 'Pedimos, por gentileza, que verifique se dispõem de toda a documentação necessária para que as mesmas sejam pagas até a data de vencimento indicada.'
	//cTXT07 := 'Caso não possua tais documentos, por gentileza, solicite-os para a Srª Aline Gomes, setor de faturamento, através do e-mail alinegomes@eurofins.com.br ou pelo telefone (19) 2107-5504.'
	cTXT07 := 'Caso não possua tais documentos, por gentileza, solicite-os para a Srª Agata Gomes, setor de faturamento, através do e-mail agatagomes@eurofins.com ou pelo telefone (19) 2107-5500.'
Else
	// text for overdues invoices
	cTXT00 := 'To company '
	cTXT01 := 'Dear customer, '
	cTXT02 := 'As per our records, the following invoices are still open in our Accounts Receivable.'
	cTXT03 := 'We kindly ask you to check the above list and inform us the status of the invoices via e-mail to denisecarnelos@eurofins.com and brunobertanha@eurofins.com or by phone +55 (19) 2107-5507 and +55 (19) 2107-5506.'
	cTXT04 := 'In case the invoices have already been paid, we kindly ask you to send us the swift of the payment in order help us with our accounts reconciliation.'
	// text for invoices on due date
	cTXT05 := 'Follow the list of invoices issued recently, with respective maturity dates.'
	cTXT06 := 'We kindly ask you to check if you have all required documentation in order to make the payments up to due date.'
	//cTXT07 := 'If not, please request such documentation to Mrs. Aline Gomes, billing department, via e-mail alinegomes@eurofins.com.br or phone +55 (19) 2107-5504.'
	cTXT07 := 'If not, please request such documentation to Mrs. Agata Gomes, billing department, via e-mail agatagomes@eurofins.com or phone +55 (19) 2107-5500.'
Endif

//aadd( aDestino , {"" , cEMailCli+";"+GetMV("MV_RESPFIN")} )
//aadd( aDestino , {"" , marcossilva@eurofins.com.br"} )
//cEMailCli := "marcossilva@eurofins.com.br"

cMens += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"> '
cMens += '<html><head><title>Aviso de Atraso</title>'
cMens += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
cMens += '<meta content="MSHTML 6.00.6000.16850" name="GENERATOR"></head>'
cMens += '<body bgcolor="#ffffff">'
cMens += '<p><font color="#000000" size="4" face="Arial">'
cMens += cTXT00+aDados[2]+IIF(!Empty(cAux),' - '+cAux,'')+' ('+Transform(aDados[3],"@R 999999/99")+')'+'</p>'
cMens += '<p>'+cTXT01+'<br><br>'

// tabela com titulos vencidos
lFirst := .T.
For nD:=1 to Len(aDados[1])
	If aDados[1][nD,8] == "1"
		If lFirst
			cMens += cTXT02+'<br>'
			cMens += cTXT03+'<br>'
			cMens += cTXT04+'<br>'
			cMens += '</p>'
			cMens += '<p></p>'
			cMens += '<p>'
			cMens += '<table bordercolor="#000000" border="1" cellspacing="0"  cellpadding="3" width="100%" '
			cMens += 'align=center style="Z-INDEX: 0">'
			cMens += '<font face="Arial"><font color="#000000"><caption>Relação dos Títulos (valores não atualizados)</caption>  '
			cMens += '<tr>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Número Nota Fiscal</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Parcela</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Data de Emissão</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Data de Vencimento</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Valor Bruto</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Valor Líquido</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Dias em Aberto</p></td></tr>'
			lFirst := .F.
		Endif
		cMens += '<tr>'
		cMens += '<td bordercolor="#000000"><p align="center">'+aDados[1][nD,1]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="center">'+IIF(Empty(aDados[1][nD,2]),'1/1',aDados[1][nD,2])+'</td>'
		cMens += '<td bordercolor="#000000"><p align="center">'+aDados[1][nD,3]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="center">'+aDados[1][nD,4]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="right">'+aDados[1][nD,5]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="right">'+aDados[1][nD,6]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="center">'+aDados[1][nD,7]+'</td>'
		cMens += '</tr>'
	Endif
Next
If !lFirst
	cMens += '</font></font></table></p>'
Endif
//cMens += '<p>&nbsp;</p>'

// tabela com titulos vincendos
lFirst := .T.
For nD:=1 to Len(aDados[1])
	If aDados[1][nD,8] == "2"
		If lFirst
			cMens += '<p>'
			cMens += cTXT05+'<br>'
			cMens += cTXT06+'<br>'
			cMens += cTXT07+'<br><br>'
			cMens += '</p>'
			cMens += '<p></p>'
			cMens += '<p>'
			cMens += '<table bordercolor="#000000" border="1" cellspacing="0"  cellpadding="3" width="100%" '
			cMens += 'align=center style="Z-INDEX: 0">'
			cMens += '<font face="Arial"><font color="#000000"><caption>Relação dos Títulos</caption>  '
			cMens += '<tr>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Número Nota Fiscal</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Parcela</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Data de Emissão</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Data de Vencimento</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Valor Bruto</p></td>'
			cMens += '<td bordercolor="#000000">'
			cMens += '<p align="center">Valor Líquido</p></td>'
			lFirst := .F.
		Endif
		cMens += '<tr>'
		cMens += '<td bordercolor="#000000"><p align="center">'+aDados[1][nD,1]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="center">'+IIF(Empty(aDados[1][nD,2]),'1/1',aDados[1][nD,2])+'</td>'
		cMens += '<td bordercolor="#000000"><p align="center">'+aDados[1][nD,3]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="center">'+aDados[1][nD,4]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="right">'+aDados[1][nD,5]+'</td>'
		cMens += '<td bordercolor="#000000"><p align="right">'+aDados[1][nD,6]+'</td>'
		cMens += '</tr>'
	Endif
Next
If !lFirst
	cMens += '</font></font></table></p>'
Endif
cMens += '<p>&nbsp;</p>'

cMens += '<p>Atenciosamente,<br>'
cMens += 'Contas a Receber<br><br></p>'
cMens += '<p>Eurofins do Brasil Análises de Alimentos Ltda</font>&nbsp;</p>'
cMens += '<p>&nbsp;</p>'
cMens += '<p>'
cMens += '<font color="#000000" face="Arial" size="2"><strong>Não responder este e-mail. Envio automático do '
cMens += 'Protheus System - Version 12 by Totvs Software S.A. ®</strong></font></p></body></html>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configuro o sistema para criar Confirmacao de Leitura        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ConfirmMailRead(.T.)
//MConnect(cMens,aDestino,cAssunto,.T.,.F.)
//Sleep(500)
//ConfirmMailRead(.F.)
//MDisconnect()

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
	ConfirmMailRead(.T.)
	//SEND MAIL FROM cAccount TO cEMailCli CC GetMV("MV_RESPFIN") SUBJECT cAssunto BODY cMens RESULT lOk
	SEND MAIL FROM cAccount TO cEMailCli CC cCopia SUBJECT cAssunto BODY cMens RESULT lOk
Endif

If lOk
	ConOut("E-Mail enviado a "+cEMailCli)
	ConfirmMailRead(.F.)
Else
    GET MAIL ERROR cErrorMsg
	ConOut("E-Mail não enviado ! Erro: "+cErrorMsg)
Endif

DISCONNECT SMTP SERVER RESULT lOk

Return