
#Include "Protheus.ch"


/*/{Protheus.doc} FA750BRW
Adiciona ações relacionadas no Funções Contas a Pagar
@type function
@version 12.1.33
@author Leandro Cesar
@since 9/4/2023
@return array, rotinas do menu
@link http://tdn.totvs.com/pages/releaseview.actionçpageId=6071251
/*/
User Function FA750BRW()
	Local aRotX :={}
	aAdd(aRotX, { "Pedido de Compra"    , "U_MYMTA121()" , 0 , 4,15,NIL})
Return aRotX

// ------------------------------------------------------------------------------------------------------------------------

User Function MYMTA121()
	local cCadBack  := ''
	local aRotAux   := {}
	Local aArea     := GetArea() // Armazena posicionamento atual
	Local lIncluiBk := INCLUI // Armazena o conteudo da variavel INCLUI
	Local lAlteraBk := ALTERA // Armazena o conteudo da variavel INCLUI

	If Type( "cCadastro" ) == "C"
		cCadBack := cCadastro
	EndIf

	If Type ("aRotina") == "A"
		aRotAux := aClone(aRotina)
	EndIf


	MATA121()

	cCadastro := cCadBack
	aRotina := aClone(aRotAux)
	RestArea(aArea)
return
