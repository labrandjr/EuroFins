#include "totvs.ch"
/*/{protheus.doc}LogRisco
Grava alterações do campo A1_RISCO num log para integração com outro sistema
@author Sergio Braz
@since 11/10/2019
/*/
User Function LogRisco
	Local cPath := U_GetPar("ZZ_LOGRISC","C","\LOGRISCO\","LOCAL ONDE SERA GRAVADO LOG DE RISCO PARA INTEGRAÇÃO COM SISTEMA MYLIMS")
	Local cResp := M->A1_COD+"-"+M->A1_LOJA+";"+M->A1_CGC+";"+M->A1_RISCO+";"+M->A1_NOME
	Local cFile := cPath+"SA1_"+Dtos(dDataBase)+"_"+Left(StrTran(Time(),":",""),4)+".CSV"
	MakeDir(cPath)
	MemoWrite(cFile,cResp)
Return
