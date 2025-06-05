#include "topconn.ch"
#include "Protheus.ch"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} CTBIMPFC
Inclusão de Conta Contábil Cadastro de Cliente/Fornecedor
@author Unknown
@since 02/01/2018
/*/



******************************************************************************************************
******************************************************************************************************
// Inclusão de Conta Contábil Cliente / Fornecedor												    //
******************************************************************************************************
******************************************************************************************************
User Function CTBIMPFC()

Local aArea		:= GetArea()
Local aOpcoes	:= { "Cliente", "Fornecedor", "Ambos" }
Local aParBox	:= {}
Local cPerg		:= "INCFC"

Private oProcess:= Nil

aAdd(aParBox,{3,"Opção",1,aOpcoes,80,"",.T.})

if ParamBox(aParBox,"Inclusão de Conta Contábil Cadastro de Cliente/Fornecedor",,,,,,,,cPerg,.T.,.T.)
   OkProc()
endif

RestArea(aArea)

Return

******************************************************************************************************
******************************************************************************************************
//Funcao responsavel pelo processamento principal da rotina.                                        //
******************************************************************************************************
******************************************************************************************************
Static Function OkProc()

// Verifica se o módulo em uso é o SIGACTB.
If Alltrim(GETMV("MV_MCONTAB")) <> "CTB"
	MsgStop("Esta rotina se aplica somente ao módulo contábil SIGACTB!")
	Return
EndIf

// Faz a chamada de processamento.
If mv_par01 == 1
	oProcess:= MsNewProcess():New({|| ProcSA1()}, "Processamento", "Gravando Conta Contábil Clientes...", .F.)
	oProcess:Activate()
ElseIf mv_par01 == 2 // Fornecedores
	oProcess:= MsNewProcess():New({|| ProcSA2()}, "Processamento", "Gravando Conta Contábil Fornecedores...", .F.)
	oProcess:Activate()
ElseIf mv_par01 == 3
	oProcess:= MsNewProcess():New({|| ProcSA1()}, "Processamento", "Gravando Conta Contábil Clientes...", .F.)
	oProcess:Activate()

	oProcess:= MsNewProcess():New({|| ProcSA2()}, "Processamento", "Gravando Conta Contábil Fornecedores...", .F.)
	oProcess:Activate()
EndIf

MsgInfo("Criação das Contas Contábeis efetuada!","CTBIMPFC")

Return

******************************************************************************************************
******************************************************************************************************
//Funcao responsavel pelo processamento para Clientes		                                        //
******************************************************************************************************
******************************************************************************************************
Static Function ProcSA1()

Local cQry
Local cAlias	:= GetNextAlias()
Local cContaC	:= ""
Local cSeq		:= ""


if(Select(cAlias) > 0)
	(cAlias)->(DBCloseArea())
endIf

cQry := " SELECT A1_CONTA, R_E_C_N_O_ " + CRLF
cQry += " FROM " + RetSqlName("SA1") + "  " + CRLF
cQry += " WHERE 	A1_FILIAL 	= '" + xFilial("SA1") +"' 	AND " + CRLF
cQry += "           A1_CONTA    = '' AND " + CRLF
cQry += " D_E_L_E_T_ = ' '  " + CRLF

TcQuery cQry Alias &cAlias New

While !(cAlias)->(Eof())

	dbSelectArea("SA1")
	dbGoto((cAlias)->R_E_C_N_O_)

	IncProc("Processando Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
	// Chama rotina comum ao SA1/SA2 para criação de contas.
	U_CTBINCFC("1","M")  //M - Rotina de Menu

	(cAlias)->(dbSkip())
enddo

Return

******************************************************************************************************
******************************************************************************************************
//Funcao responsavel pelo processamento para Fornecedores                                           //
******************************************************************************************************
******************************************************************************************************
Static Function ProcSA2()

Local cQry
Local cAlias	:= GetNextAlias()
Local cContaC	:= ""
Local cSeq		:= ""


if(Select(cAlias) > 0)
	(cAlias)->(DBCloseArea())
endIf

cQry := " SELECT A2_CONTA, R_E_C_N_O_ " + CRLF
cQry += " FROM " + RetSqlName("SA2") + "  " + CRLF
cQry += " WHERE 	A2_FILIAL 	= '" + xFilial("SA2") +"' 	AND " + CRLF
cQry += "           A2_CONTA    = '' AND " + CRLF
cQry += " D_E_L_E_T_ = ' '  " + CRLF

TcQuery cQry Alias &cAlias New

While !(cAlias)->(Eof())

	dbSelectArea("SA2")
	dbGoto((cAlias)->R_E_C_N_O_)

	IncProc("Processando Fornecedor/Loja: " + SA2->A2_COD+"/"+SA2->A2_LOJA)
	// Chama rotina comum ao SA1/SA2 para criação de contas.
	U_CTBINCFC("2","M")  //M - Rotina de Menu

	(cAlias)->(dbSkip())
endDo

Return

