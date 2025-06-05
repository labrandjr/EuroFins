#include 'totvs.ch'

/*/{Protheus.doc} SF1100I
Faz tratativas após incluir um Documento de Entrada
@type function
@version 12.1.33
@author Leandro Cesar
@since 10/07/2023
/*/
user function SF1100I()
	local aArea   := GetArea()        as array
	local aAreaF1 := SF1->(GetArea()) as array

//SECTION - gravação usuário classificacao/inclusão
	//NOTE alterado por Leandro Cesar - 10/07/2023
	//REVIEW Grava o usuário que fez a classificação da nota fiscal
	If SF1->(FieldPos("F1_XLOGCLA")) > 0
		If Empty(SF1->F1_XLOGCLA )
			reclock("SF1",.F.)
			SF1->F1_XLOGCLA := alltrim(cUserName)
			SF1->(MsUnlock())
		EndIf
	EndIf


	If SF1->(FieldPos("F1_XDTCLAS")) > 0
		If Empty(SF1->F1_XDTCLAS)
			reclock("SF1",.F.)
			SF1->F1_XDTCLAS := Date()
			SF1->(MsUnlock())
		EndIf
	EndIf
//!SECTION

	RestArea(aAreaF1)
	RestArea(aArea)
return()
