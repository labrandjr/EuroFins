#include 'rwmake.ch'
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA070IMP ºAutor  ³ Marcos Candido     º Data ³  15/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na rotina de baixas a receber, ao clicar  º±±
±±º          ³ no botao IMPOSTOS.                                         º±±
±±º          ³ Esta chamada faz com que o sistema apresente os valores do º±±
±±º          ³ IRRF, ISS e INSS, para que usuario possa edita-los. Assim  º±±
±±º          ³ como acontece com o PIS, COFINS e CSLL                     º±±
±±º          ³ Se o titulo referente ao imposto calculado nao existir, a  º±±
±±º          ³ rotina o criara, para garantir que a baixa do titulo prin- º±±
±±º          ³ cipal encontre os valores para o devido abatimento.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*/{Protheus.doc} FA070IMP
Na rotina de baixas a receber, ao clicar no botao IMPOSTOS.

@author Marcos Candido
@since 03/01/2018
/*/
User Function FA070IMP

Local aValores := PARAMIXB
Local lRet   := .T. , cQ := ""
Local aAreaAtual := GetArea()
Local cChav1 := SE1->E1_CLIENTE
Local cChav2 := SE1->E1_LOJA
Local cChav3 := SE1->E1_PREFIXO
Local cChav4 := SE1->E1_NUM
Local aDados := {}

aadd( aDados, {	SE1->E1_PREFIXO,;
			 	SE1->E1_NUM,;
			 	SE1->E1_TIPO,;
			 	SE1->E1_CLIENTE,;
			 	SE1->E1_LOJA,;
			 	SE1->E1_NOMCLI,;
			 	SE1->E1_EMISSAO,;
			 	SE1->E1_VENCTO,;
			 	SE1->E1_VENCREA,;
			 	SE1->E1_VENCORI,;
			 	SE1->E1_MOEDA,;
			 	SE1->E1_OCORREN,;
			 	SE1->E1_PARCELA})

If aValores[1] > 0 // IRRF

	If Select("WSE1") > 0
		WSE1->(dbCloseArea())
	Endif

	dbSelectArea("SE1")
	aAreaSE1 := GetArea()
	cQ := "SELECT E1_PREFIXO, E1_NUM, E1_TIPO "
	cQ += "FROM "+RetSqlName("SE1")+" SE1 "
	cQ += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
	cQ += "SE1.E1_CLIENTE =  '"+cChav1+"' AND "
	cQ += "SE1.E1_LOJA =     '"+cChav2+"' AND "
	cQ += "SE1.E1_PREFIXO =  '"+cChav3+"' AND "
	cQ += "SE1.E1_NUM =      '"+cChav4+"' AND "
	cQ += "SE1.E1_TIPO =     'IR-' AND "
	cQ += "SE1.D_E_L_E_T_ <> '*'"
	cQ := ChangeQuery(cQ)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"WSE1",.T.,.T.)
	aEval(SE1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSE1",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSE1")
	dbGoTop()

	If Bof() .and. Eof()

		dbSelectArea("SE1")
		RecLock("SE1",.T.)
  		  Replace	E1_FILIAL  	With	xFilial("SE1")
  		  Replace	E1_PREFIXO 	With	aDados[1][1]
  		  Replace	E1_NUM		With	aDados[1][2]
  		  Replace	E1_TIPO		With	"IR-"
  		  Replace	E1_PARCELA	With	aDados[1][13]
  		  Replace	E1_NATUREZ	With	&(GetMv("MV_IRF"))
  		  Replace	E1_CLIENTE	With	aDados[1][4]
  		  Replace	E1_LOJA		With	aDados[1][5]
  		  Replace	E1_NOMCLI	With	aDados[1][6]
  		  Replace	E1_EMISSAO	With	aDados[1][7]
  		  Replace	E1_VENCTO	With	aDados[1][8]
  		  Replace	E1_VENCREA	With	aDados[1][9]
  		  Replace	E1_VALOR  	With	aValores[1]
  		  Replace	E1_SALDO  	With	aValores[1]
  	  	  Replace	E1_VLCRUZ 	With	aValores[1]
  		  Replace	E1_EMIS1	With	aDados[1][7]
  		  Replace	E1_LA		With	"S"
  		  Replace	E1_SITUACA	With	"0"
  		  Replace	E1_VENCREA	With	aDados[1][10]
  		  Replace	E1_VENCORI	With	aDados[1][8]
  		  Replace	E1_MOEDA	With	aDados[1][11]
  		  Replace	E1_OCORREN	With	aDados[1][12]
 		  Replace	E1_STATUS	With	"A"
  		  Replace	E1_ORIGEM	With	"MATA460"
  		  Replace	E1_MSFIL	With	cFilAnt
  		  Replace	E1_MSEMP	With	cEmpAnt
  		  Replace	E1_TITPAI	With	aDados[1][1]+aDados[1][2]+aDados[1][13]+aDados[1][3]+aDados[1][4]+aDados[1][5]
		MsUnlock()

	Endif

	If Select("WSE1") > 0
		WSE1->(dbCloseArea())
	Endif

	RestArea(aAreaSE1)

Endif

If aValores[3] > 0 // PIS

	If Select("WSE1") > 0
		WSE1->(dbCloseArea())
	Endif

	dbSelectArea("SE1")
	aAreaSE1 := GetArea()
	cQ := "SELECT E1_PREFIXO, E1_NUM, E1_TIPO "
	cQ += "FROM "+RetSqlName("SE1")+" SE1 "
	cQ += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
	cQ += "SE1.E1_CLIENTE =  '"+cChav1+"' AND "
	cQ += "SE1.E1_LOJA =     '"+cChav2+"' AND "
	cQ += "SE1.E1_PREFIXO =  '"+cChav3+"' AND "
	cQ += "SE1.E1_NUM =      '"+cChav4+"' AND "
	cQ += "SE1.E1_TIPO =     'PI-' AND "
	cQ += "SE1.D_E_L_E_T_ <> '*'"
	cQ := ChangeQuery(cQ)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"WSE1",.T.,.T.)
	aEval(SE1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSE1",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSE1")
	dbGoTop()

	If Bof() .and. Eof()

		dbSelectArea("SE1")
		RecLock("SE1",.T.)
  		  Replace	E1_FILIAL  	With	xFilial("SE1")
  		  Replace	E1_PREFIXO 	With	aDados[1][1]
  		  Replace	E1_NUM		With	aDados[1][2]
  		  Replace	E1_TIPO		With	"PI-"
  		  Replace	E1_PARCELA	With	aDados[1][13]
  		  Replace	E1_NATUREZ	With	GetMv("MV_PISNAT")
  		  Replace	E1_CLIENTE	With	aDados[1][4]
  		  Replace	E1_LOJA		With	aDados[1][5]
  		  Replace	E1_NOMCLI	With	aDados[1][6]
  		  Replace	E1_EMISSAO	With	aDados[1][7]
  		  Replace	E1_VENCTO	With	aDados[1][8]
  		  Replace	E1_VENCREA	With	aDados[1][9]
  		  Replace	E1_VALOR  	With	aValores[3]
  		  Replace	E1_SALDO  	With	aValores[3]
  	  	  Replace	E1_VLCRUZ 	With	aValores[3]
  		  Replace	E1_EMIS1	With	aDados[1][7]
  		  Replace	E1_LA		With	"S"
  		  Replace	E1_SITUACA	With	"0"
  		  Replace	E1_VENCREA	With	aDados[1][10]
  		  Replace	E1_VENCORI	With	aDados[1][8]
  		  Replace	E1_MOEDA	With	aDados[1][11]
  		  Replace	E1_OCORREN	With	aDados[1][12]
 		  Replace	E1_STATUS	With	"A"
  		  Replace	E1_ORIGEM	With	"MATA460"
  		  Replace	E1_MSFIL	With	cFilAnt
  		  Replace	E1_MSEMP	With	cEmpAnt
  		  Replace	E1_TITPAI	With	aDados[1][1]+aDados[1][2]+aDados[1][13]+aDados[1][3]+aDados[1][4]+aDados[1][5]
		MsUnlock()

	Endif

	If Select("WSE1") > 0
		WSE1->(dbCloseArea())
	Endif

	RestArea(aAreaSE1)

Endif

If aValores[4] > 0 // COFINS

	If Select("WSE1") > 0
		WSE1->(dbCloseArea())
	Endif

	dbSelectArea("SE1")
	aAreaSE1 := GetArea()
	cQ := "SELECT E1_PREFIXO, E1_NUM, E1_TIPO "
	cQ += "FROM "+RetSqlName("SE1")+" SE1 "
	cQ += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
	cQ += "SE1.E1_CLIENTE =  '"+cChav1+"' AND "
	cQ += "SE1.E1_LOJA =     '"+cChav2+"' AND "
	cQ += "SE1.E1_PREFIXO =  '"+cChav3+"' AND "
	cQ += "SE1.E1_NUM =      '"+cChav4+"' AND "
	cQ += "SE1.E1_TIPO =     'CF-' AND "
	cQ += "SE1.D_E_L_E_T_ <> '*'"
	cQ := ChangeQuery(cQ)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"WSE1",.T.,.T.)
	aEval(SE1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSE1",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSE1")
	dbGoTop()

	If Bof() .and. Eof()

		dbSelectArea("SE1")
		RecLock("SE1",.T.)
  		  Replace	E1_FILIAL  	With	xFilial("SE1")
  		  Replace	E1_PREFIXO 	With	aDados[1][1]
  		  Replace	E1_NUM		With	aDados[1][2]
  		  Replace	E1_TIPO		With	"CF-"
  		  Replace	E1_PARCELA	With	aDados[1][13]
  		  Replace	E1_NATUREZ	With	GetMv("MV_COFINS")
  		  Replace	E1_CLIENTE	With	aDados[1][4]
  		  Replace	E1_LOJA		With	aDados[1][5]
  		  Replace	E1_NOMCLI	With	aDados[1][6]
  		  Replace	E1_EMISSAO	With	aDados[1][7]
  		  Replace	E1_VENCTO	With	aDados[1][8]
  		  Replace	E1_VENCREA	With	aDados[1][9]
  		  Replace	E1_VALOR  	With	aValores[4]
  		  Replace	E1_SALDO  	With	aValores[4]
  	  	  Replace	E1_VLCRUZ 	With	aValores[4]
  		  Replace	E1_EMIS1	With	aDados[1][7]
  		  Replace	E1_LA		With	"S"
  		  Replace	E1_SITUACA	With	"0"
  		  Replace	E1_VENCREA	With	aDados[1][10]
  		  Replace	E1_VENCORI	With	aDados[1][8]
  		  Replace	E1_MOEDA	With	aDados[1][11]
  		  Replace	E1_OCORREN	With	aDados[1][12]
 		  Replace	E1_STATUS	With	"A"
  		  Replace	E1_ORIGEM	With	"MATA460"
  		  Replace	E1_MSFIL	With	cFilAnt
  		  Replace	E1_MSEMP	With	cEmpAnt
  		  Replace	E1_TITPAI	With	aDados[1][1]+aDados[1][2]+aDados[1][13]+aDados[1][3]+aDados[1][4]+aDados[1][5]
		MsUnlock()

	Endif

	If Select("WSE1") > 0
		WSE1->(dbCloseArea())
	Endif

	RestArea(aAreaSE1)

Endif

If aValores[5] > 0 // CSLL

	If Select("WSE1") > 0
		WSE1->(dbCloseArea())
	Endif

	dbSelectArea("SE1")
	aAreaSE1 := GetArea()
	cQ := "SELECT E1_PREFIXO, E1_NUM, E1_TIPO "
	cQ += "FROM "+RetSqlName("SE1")+" SE1 "
	cQ += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
	cQ += "SE1.E1_CLIENTE =  '"+cChav1+"' AND "
	cQ += "SE1.E1_LOJA =     '"+cChav2+"' AND "
	cQ += "SE1.E1_PREFIXO =  '"+cChav3+"' AND "
	cQ += "SE1.E1_NUM =      '"+cChav4+"' AND "
	cQ += "SE1.E1_TIPO =     'CS-' AND "
	cQ += "SE1.D_E_L_E_T_ <> '*'"
	cQ := ChangeQuery(cQ)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"WSE1",.T.,.T.)
	aEval(SE1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSE1",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

	dbSelectArea("WSE1")
	dbGoTop()

	If Bof() .and. Eof()

		dbSelectArea("SE1")
		RecLock("SE1",.T.)
  		  Replace	E1_FILIAL  	With	xFilial("SE1")
  		  Replace	E1_PREFIXO 	With	aDados[1][1]
  		  Replace	E1_NUM		With	aDados[1][2]
  		  Replace	E1_TIPO		With	"CS-"
  		  Replace	E1_PARCELA	With	aDados[1][13]
  		  Replace	E1_NATUREZ	With	GetMv("MV_CSLL")
  		  Replace	E1_CLIENTE	With	aDados[1][4]
  		  Replace	E1_LOJA		With	aDados[1][5]
  		  Replace	E1_NOMCLI	With	aDados[1][6]
  		  Replace	E1_EMISSAO	With	aDados[1][7]
  		  Replace	E1_VENCTO	With	aDados[1][8]
  		  Replace	E1_VENCREA	With	aDados[1][9]
  		  Replace	E1_VALOR  	With	aValores[5]
  		  Replace	E1_SALDO  	With	aValores[5]
  	  	  Replace	E1_VLCRUZ 	With	aValores[5]
  		  Replace	E1_EMIS1	With	aDados[1][7]
  		  Replace	E1_LA		With	"S"
  		  Replace	E1_SITUACA	With	"0"
  		  Replace	E1_VENCREA	With	aDados[1][10]
  		  Replace	E1_VENCORI	With	aDados[1][8]
  		  Replace	E1_MOEDA	With	aDados[1][11]
  		  Replace	E1_OCORREN	With	aDados[1][12]
 		  Replace	E1_STATUS	With	"A"
  		  Replace	E1_ORIGEM	With	"MATA460"
  		  Replace	E1_MSFIL	With	cFilAnt
  		  Replace	E1_MSEMP	With	cEmpAnt
  		  Replace	E1_TITPAI	With	aDados[1][1]+aDados[1][2]+aDados[1][13]+aDados[1][3]+aDados[1][4]+aDados[1][5]
		MsUnlock()

	Endif

	If Select("WSE1") > 0
		WSE1->(dbCloseArea())
	Endif

	RestArea(aAreaSE1)

Endif

RestArea(aAreaAtual)

Return lRet