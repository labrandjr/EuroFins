#include 'protheus.ch'
#Include 'FWMVCDef.ch'

User Function DMCOBTMP()
	Local cFunBkp     	:= FunName()
	Local cArquivo    	:= "\cobranca"+GetDBExtension()
	Local cArqs			:= ""
	Local aStrut      	:= {}
	Private cAliasTmp 	:= "COBTMP"

	//Criando a estrutura que terá na tabela
	aAdd(aStrut, {"TMP_EMPR", "C", 50, 	0} )
	aAdd(aStrut, {"TMP_LOGO", "C", 256, 0} )
	aAdd(aStrut, {"TMP_VEN0", "M", 0, 0} )
	aAdd(aStrut, {"TMP_VEN1", "M", 0, 	0} )
	aAdd(aStrut, {"TMP_VEN2", "M", 0, 	0} )
	aAdd(aStrut, {"TMP_VEN3", "M", 0, 	0} )
	aAdd(aStrut, {"TMP_TELE", "C", 15, 	0} )
	aAdd(aStrut, {"TMP_CNPJ", "C", 14, 	0} )
	aAdd(aStrut, {"TMP_ENDE", "C", 50, 	0} )
	aAdd(aStrut, {"TMP_CIDA", "C", 50, 	0} )
	aAdd(aStrut, {"TMP_SITE", "C", 50, 	0} )
	
	//Se o arquivo dbf / ctree existir, usa ele
	If Select(cAliasTmp) == 0
		If File(cArquivo)
			DbUseArea(.T., "DBFCDX", cArquivo, cAliasTmp, .T., .F.)
			
		//Senão, cria uma temporária
		Else
			//Criando a temporária
			cArqs := CriaTrab( aStrut, .T. )
			DbUseArea(.T., "DBFCDX", cArqs, cAliasTmp, .T., .F.)
		EndIf
	EndIf
	
	SetFunName("ZTMPCOB")
	
	FWExecView("Alteracao de cobranca", "ZTMPCOB", MODEL_OPERATION_INSERT, , {|| .T.})
	
	SetFunName(cFunBkp)
	
	fErase(cArquivo)
	
Return