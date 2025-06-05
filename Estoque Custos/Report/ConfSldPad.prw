#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BxPadroes บAutor  ณ Marcos Candido    บ Data ณ  11/10/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que ira realizar a inclusao de movimentos internos  บฑฑ
ฑฑบ          ณ de requisicao dos produtos cadastrados nas tabelas SZD e   บฑฑ
ฑฑบ          ณ SZE.                                                       บฑฑ
ฑฑบ          ณ Processo automatico de Diferimento (baixa)                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eurofins                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*/{Protheus.doc} ConfSldPad
Inclusao de movimentos internos de requisicao dos produtos cadastrados nas tabelas SZD e SZE.  Processo automatico de Diferimento (baixa)
@author Marcos Candido
@since 02/01/2018
/*/
User Function ConfSldPad

If IW_MsgBox(OemToAnsi("Confirma o processamento da rotina de Avalia็ใo de Saldo de Diferimento de Padr๕es ?"), OemToAnsi("Informa็ใo") , "YESNO")
	Processa({|| RunOk() },OemToAnsi("Conferindo Saldo a Diferir dos Padr๕es"))
	IW_MsgBox(OemToAnsi("Processamento Concluํdo."), OemToAnsi("Informa็ใo") , "INFO")
Else
	IW_MsgBox(OemToAnsi("Processamento Cancelado."), OemToAnsi("Informa็ใo") , "ALERT")
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBXPADROES บAutor  ณMicrosiga           บ Data ณ  05/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RunOk

Local cQuery  := ""
Local nM      := 0 , nTotRegs := 0
Local aDados  := {} , aResult := {}

SB2->(dbSetOrder(1))

If Select("WRK1") > 0
	WRK1->(dbCloseArea())
Endif

cQuery := "SELECT COUNT(*) AS nRegistros FROM "+RetSQLName("SZD")+" SZD ,"+RetSQLName("SZE")+" SZE "
cQuery += "WHERE SZD.ZD_STATUS <> '3' AND "
cQuery += "SZD.ZD_FILIAL = '"+xFilial("SZD")+"' AND "
cQuery += "SZE.ZE_FILIAL = '"+xFilial("SZE")+"' AND "
cQuery += "SZD.ZD_SEQUENC = SZE.ZE_SEQUENC AND "
cQuery += "SZD.ZD_COD = SZE.ZE_COD AND "
cQuery += "SZD.ZD_ARMAZ = SZE.ZE_ARMAZ AND "
cQuery += "SZD.ZD_DTLANC <= '"+DtoS(dDataBase)+"' AND "
cQuery += "SZE.ZE_DATA = ' ' AND "
cQuery += "SZD.D_E_L_E_T_ <> '*' AND "
cQuery += "SZE.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
TcQuery cQuery New Alias "WRK1"

nTotRegs := WRK1->nRegistros

If Select("WRK1") > 0
	WRK1->(dbCloseArea())
Endif

cQuery := "SELECT * FROM "+RetSQLName("SZD")+" SZD ,"+RetSQLName("SZE")+" SZE "
cQuery += "WHERE SZD.ZD_STATUS <> '3' AND "
cQuery += "SZD.ZD_FILIAL = '"+xFilial("SZD")+"' AND "
cQuery += "SZE.ZE_FILIAL = '"+xFilial("SZE")+"' AND "
cQuery += "SZD.ZD_SEQUENC = SZE.ZE_SEQUENC AND "
cQuery += "SZD.ZD_COD = SZE.ZE_COD AND "
cQuery += "SZD.ZD_ARMAZ = SZE.ZE_ARMAZ AND "
cQuery += "SZD.ZD_DTLANC <= '"+DtoS(dDataBase)+"' AND "
cQuery += "SZE.ZE_DATA = ' ' AND "
cQuery += "SZD.D_E_L_E_T_ <> '*' AND "
cQuery += "SZE.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
TcQuery cQuery New Alias "WRK1"

dbSelectArea("WRK1")
dbGoTop()

ProcRegua(nTotRegs)

While !Eof()
	IncProc(OemToAnsi("Organizando dados..."))
	If aScan(aDados , {|x| x[1]==WRK1->ZE_COD .and. x[2]==WRK1->ZE_ARMAZ .and. x[3]==WRK1->ZE_SEQUENC}) == 0
		aadd(aDados , { WRK1->ZE_COD, WRK1->ZE_ARMAZ , WRK1->ZE_SEQUENC , WRK1->ZE_SALDO+WRK1->ZE_QUANT })
	Endif
	dbSkip()
Enddo

ProcRegua(Len(aDados))

For nM:=1 to Len(aDados)

	IncProc(OemToAnsi("Avaliando Estoque..."))

	dbSelectArea("SB2")
	If dbSeek(xFilial("SB2")+aDados[nM][1]+aDados[nM][2])
		aadd(aResult , { aDados[nM][3] , aDados[nM][1] , aDados[nM][2] , aDados[nM][4] , SB2->B2_QATU })
	Endif

Next nM

If Select("WRK1") > 0
	WRK1->(dbCloseArea())
Endif

If Len(aResult) > 0
	ImprLog(aResult)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ImprLog  บAutor  ณ Marcos Candido     บ Data ณ  08/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para apresentar em relatorio, os produtos conside-  บฑฑ
ฑฑบ          ณ rados "Padrao" com seus saldos a diferir e a quantidade    บฑฑ
ฑฑบ          ณ disponivel em estoque.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eurofins                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ImprLog(aResult)

//	uTCReport ACTIVATE
//Return (Run02(aResult))

Run02(aResult)

Return

Static Function Run02(aResult)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1  := "Este programa tem como objetivo imprimir relat๓rio os produtos considerados"
Local cDesc2  := "'Padrao' com seus saldos a diferir e a quantidade disponivel em estoque. "
Local cDesc3  := " "
Local titulo  := "Relacao dos Saldos a Diferir dos Padroes"
Local Cabec1  := "  NUMERO        CODIGO       ARMZ             SALDO A            SALDO ATUAL"
Local Cabec2  := "SEQUENCIAL      PRODUTO                       DIFERIR             EM ESTOQUE"
Local imprime := .T.
Local aOrd    := {}
Local cPerg   := ""
/*
  NUMERO        CODIGO       ARMZ             SALDO A            SALDO ATUAL
SEQUENCIAL      PRODUTO                       DIFERIR             EM ESTOQUE
  999999    999999999999999   99   999,999,999.999999     999,999,999.999999
*/

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "CONFSLDPAD"
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private m_pag       := 01
Private wnrel       := "CONFSLDPAD"
Private cString     := "SZD"
Li                  := 80

//===============================================================================================
// Monta a interface padrao com o usuario...
//===============================================================================================
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,aResult) },Titulo)

Return

/*
==============================================================================
Funcao     	RUNREPORT | Autor ณ                    | Data ณ
==============================================================================
Descricao 	Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS
			monta a janela com a regua de processamento.
==============================================================================
Uso     	Programa principal
==============================================================================*/
Static Function RunReport(Cabec1,Cabec2,Titulo,aResult)

Local nB      := 0
Local cCodAnt := ""
Local nQtd    := 0
Local nValAnt := 0
Local nEscolha := 0

aSort(aResult ,,, {|x,y| x[2]+x[1] < y[2]+y[1]})

SetRegua(Len(aResult))

nEscolha := Aviso("Op็๕es" , "Informe quais valores deseja visualizar:" , {"Com Dif.","Sem Dif.","Tudo"} , 2 )

For nB:=1 to Len(aResult)

	IncRegua()

	nVeQtd := 0
	lCont  := .F.
	cAux   := aResult[nB][2]
	aEval(aResult , {|z| iif(z[2]==cAux , nVeQtd+=z[4] , nVeQtd+=0) })

	// So mostra itens com diferencas
	If nEscolha == 1
		If nVeQtd <> aResult[nB][5]
			lCont := .T.
		Endif
	// So mostra itens sem diferencas
	ElseIf nEscolha == 2
		If nVeQtd == aResult[nB][5]
			lCont := .T.
		Endif
	// Mostra tudo
	Else
		lCont := .T.
	Endif

	If lCont
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica o cancelamento pelo usuario...                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lAbortPrint
			@ Li,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Li > 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		Endif

		If cCodAnt <> aResult[nB][2]
			cCodAnt := aResult[nB][2]
			If nQtd > 0
				@ Li,022 Psay "Sub Total:"
				@ Li,035 Psay nQtd         Picture "@E 999,999,999.999999"
				@ Li,058 Psay nValAnt-nQtd Picture "@E 999,999,999.999999"
				nQtd := 0
				Li+=2
			Endif
		Endif

		If Li > 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		Endif

		@ Li,002 Psay aResult[nB][1]
		@ Li,012 Psay aResult[nB][2]
		@ Li,030 Psay aResult[nB][3]
		@ Li,035 Psay aResult[nB][4] Picture "@E 999,999,999.999999"
		@ Li,058 Psay aResult[nB][5] Picture "@E 999,999,999.999999"
		Li++
		nQtd += aResult[nB][4]
		nValAnt := aResult[nB][5]

	Endif

Next

If Li > 58
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
Endif

@ Li,022 Psay "Sub Total:"
@ Li,035 Psay nQtd Picture "@E 999,999,999.999999"
@ Li,058 Psay nValAnt-nQtd Picture "@E 999,999,999.999999"

Roda(cbcont,cbtxt,Tamanho)

SET DEVICE TO SCREEN
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
