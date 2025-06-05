#include 'rwmake.ch'

/*

±±ºPrograma  ³ MT241LOK ºAutor  ³ Marcos Candido     º Data ³  11/10/13   º±±
±±ºDesc.     ³ Ponto de entrada na rotina de Movimentos Internos - mod2   º±±
±±º          ³ Usada para consistir se o usuario tem ou nao autorizacao   º±±
±±º          ³ para usar movimentos diferentes de Requisicao              º±±
*/
/*/{Protheus.doc} MT241LOK
Nao permite que o usuario faca a movimentacao se for item PADRAO.
@author Marcos Candido
@since 02/01/2018
/*/
User Function MT241LOK

	Local aInfo   := PARAMIXB
	Local cTipoTM := Posicione("SF5",1,xFilial("SF5")+cTM,"F5_TIPO")
	Local lCont   := .T.
	Local cProd   := GdFieldGet("D3_COD",aInfo[1])
	Local cProblema := ""
    Local cSolucao  := ""

	If Posicione("SF5",1,xFilial("SF5")+cTm,"F5_VAL") == "S"
		If !RetCodUsr() $ GETMV("ZZ_TMVAL") 
			cProblema   := "Usuário sem permissão para realizar movimentações valorizadas."
			cSolucao    := "Para fazer essa movimentação, solicite ao TI."
			lCont := .F.
		Endif
	elseIf cTipoTM <> 'R'
		If !RetCodUsr() $ GETMV("ZZ_MOVINT")
			cProblema   := "Usuário sem permissão para realizar essa movimentação"
			cSolucao    := "Para fazer essa movimentação, solicite ao TI."
			lCont := .F.
		Endif
	//Caso o produto seja padrão
	elseif SubStr(cProd,1,5) == "09A20" .and. !(IsInCallStack("U_BXPADROES")) .and. !(IsInCallStack("U_MNTPADR"))
		if !cFilAnt $ GetMv("ZZ_FILPAD")
			cProblema   := "Produtos classificados como 'PADRÃO' não podem ser requisitados."
			cSolucao    := "Utilize a rotina de baixa de padrões."
			lCont := .F.
		Endif
	endif

	/*
	If lCont .and. cTpProd == "MP" .and. Empty(CCC) .and. SM0->M0_CODIGO == '01' .and. !(IsInCallStack("U_BXPADROES"))
		IW_MsgBox(OemToAnsi("Em produtos classificados como 'MP' o campo 'CENTRO DE CUSTO' deve ser preenchido.") , OemToAnsi("Atenção") , "STOP")
		lCont := .F.
	Endif*/

	if !lCont
		Help(NIL, NIL, "MT241LOK", NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
    endif

Return lCont
