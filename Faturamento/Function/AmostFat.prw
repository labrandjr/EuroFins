#include "rwmake.ch"
#include "topconn.ch"

/*/{protheus.doc}AmostFat 
Gera de uma planilha em excel com dados dos faturamentos realizados.
@author Marcos Candido
@since 12/01/2015

/*/

User Function AmostFat

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local aSays      := {}
Local aButtons   := {}
Local cCadastro  := OemToansi('Gera豫o de planilha com as Amostras Faturadas')
Local lOkParam   := .F.
Local cPerg      := PADR("AMOSTFAT",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
Local cMens      := OemToAnsi('A op豫o de Par�metros desta rotina deve ser acessada antes de sua execu豫o!')


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Cria, se necessario, o grupo de Perguntas �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
AjustaSx1(cPerg)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Monta Interface com o usuario             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aAdd(aSays,OemToAnsi('Este programa visa enviar para uma planilha do MS-Excel os dados  '))
aAdd(aSays,OemToAnsi('das amostras faturadas para os clientes, no per�odo compreendido '))
aAdd(aSays,OemToAnsi('pelos par�metros. '))
aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| ProcGer()}),o:oWnd:End()),Aviso(OemToAnsi('Aten豫o!!!'), cMens , {'Ok'})) } } )
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons,,240,430 ) // altura x largura

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튔un뇙o    �          � Autor �                    � Data �             볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒escri뇙o � Funcao chamada pelo botao OK na tela inicial de processamen볍�
굇�          � to. Executa a geracao do arquivo texto.                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Programa principal                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

Static Function ProcGer

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Inicializa a regua de processamento                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Processa({|| RunCont() },"Processando...")

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튔un뇙o    � RUNCONT  � Autor �                    � Data �             볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒escri뇙o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  볍�
굇�          � monta a janela com a regua de processamento.               볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Programa principal                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

Static Function RunCont

Local cQuery    := ""
Local aItExcel  := {}
Local aCabExcel := {"CLIENTE","LOJA","NOME","ESTADO","PRODUTO","DESCRICAO","ITEM DO PEDIDO","NUMERO DO PEDIDO","NUMERO DO CERTIFICADO","QUANTIDADE","VALOR UNITARIO","VALOR TOTAL","NUMERO NOTA FISCAL","DATA FATURAMENTO"}

cQuery += "SELECT D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEMPV, D2_PEDIDO, D2_ZZNROCE, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_DOC, D2_EMISSAO FROM "+RetSQlName("SD2")+" SD2 "
cQuery += "WHERE "
cQuery += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
cQuery += "SD2.D2_EMISSAO >= '"+dtos(mv_par01)+"' AND SD2.D2_EMISSAO <= '"+dtos(mv_par02)+"' AND "
cQuery += "SD2.D2_CLIENTE >= '"+mv_par03+"' AND SD2.D2_LOJA >= '"+mv_par04+"' AND "
cQuery += "SD2.D2_CLIENTE <= '"+mv_par05+"' AND SD2.D2_LOJA <= '"+mv_par06+"' AND "
cQuery += "D2_BASEISS <> 0 AND D2_TIPO = 'N' AND "
cQuery += "SD2.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY D2_FILIAL,D2_CLIENTE,D2_LOJA,D2_DOC"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WSD2",.T.,.T.)
aEval(SD2->(dbStruct()),{|x| If(x[2]!="C",TcSetField("WSD2",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

dbSelectArea("WSD2")

ProcRegua(WSD2->(RecCount()))

Do While !Eof()

	IncProc("Selecionando Registros...")

	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+WSD2->(D2_CLIENTE+D2_LOJA)))

	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+WSD2->(D2_PEDIDO+D2_ITEMPV)))

	aadd(aItExcel , {D2_CLIENTE , D2_LOJA , SA1->A1_NOME , SA1->A1_EST , D2_COD , SC6->C6_DESCRI , D2_ITEMPV, D2_PEDIDO , D2_ZZNROCER , D2_QUANT ,;
						D2_PRCVEN , D2_TOTAL , D2_DOC , DtoC(D2_EMISSAO)})

	dbSelectArea("WSD2")
	dbSkip()

Enddo

If Len(aItExcel) > 0
	U_GeraExcel(aCabExcel,aItExcel)
	IW_MsgBox("Processamento Conclu�do" , "Informa豫o", "INFO")
Else
	IW_MsgBox("N�o h� dados" , "Informa豫o", "ALERT")
Endif

dbSelectArea("WSD2")
dbCloseArea("WSD2")

Return


/*
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇� Funcao   � AcessaPar   � Autor � Marcos Candido     � Data �          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Funcao para acessar o grupo de perguntas                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      �                                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Static Function AcessaPar(cPerg,lOk)

If Pergunte(cPerg)
	lOk := .T.
Endif

Return(lOk)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aHelpPor := {}
Local aAreaAtual := GetArea()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//� Organiza o Grupo de Perguntas e Help �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
Aadd(aRegs,{cPerg,"01","Da Data"				,"","","mv_ch1" ,"D",08,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Ate a Data"			,"","","mv_ch2" ,"D",08,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Do Cliente"			,"","","mv_ch3" ,"C",06,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
Aadd(aRegs,{cPerg,"04","Da Loja "			,"","","mv_ch4" ,"C",02,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","Ate o Cliente"		,"","","mv_ch5" ,"C",06,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
Aadd(aRegs,{cPerg,"06","Ate a Loja "			,"","","mv_ch6" ,"C",02,0,1,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aAreaAtual)


