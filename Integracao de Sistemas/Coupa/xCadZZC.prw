#include "Totvs.ch"  

/*/{Protheus.doc} xCadZZC
//Cadastro tabela ZZC
@author Tiago Maniero
@since 04/05/2020
@version 1.0
@type function
/*/
User Function XCadZZC()

	Local cAlias 		:= "ZZC"
	Local cTitulo 		:= "DE/PARA filiais COUPA"
	Local aRotAdic		:= {}

	aadd(aRotAdic,{ "# Importa CSV","u_fImpZZC", 0 , 6 })

	AxCadastro(cAlias,cTitulo,,,aRotAdic)

Return
