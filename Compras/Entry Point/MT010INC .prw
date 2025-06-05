#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT010INC
Ponto de entrada após a gravação do produto.
Serve para informar o usuario com qual codigo o produto foi gravado na geração automatica.
@author RICARDO REY
@since 15/09/2017
/*/
user function MT010INC ()
/*
	local aArea := getArea()

	public lPLockInc
	public cCodRepl

	if INCLUI
		if !(SB1->B1_TIPO == "SA") //neste caso, o usuario irá informar o código do produto manualmente
			MsgInfo("Produto cadastrado com o código: " + SB1->B1_COD,"Cadastro de Produtos")
		endif

		if !lPLockInc
			lPLockInc := .T.
			cCodRepl := Alltrim(SB1->B1_COD)
			Processa( {|| U_replProd() }, "Aguarde...", "Realizando replica para outras filiais...",.F.)
			lPLockInc := .F.
			cCodRepl := ""
		endif


	endif
	restArea(aArea)
*/
return