#include 'rwmake.ch'

/*

���Programa  � MT241LOK �Autor  � Marcos Candido     � Data �  11/10/13   ���
���Desc.     � Ponto de entrada na rotina de Movimentos Internos - mod2   ���
���          � Usada para consistir se o usuario tem ou nao autorizacao   ���
���          � para usar movimentos diferentes de Requisicao              ���
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
			cProblema   := "Usu�rio sem permiss�o para realizar movimenta��es valorizadas."
			cSolucao    := "Para fazer essa movimenta��o, solicite ao TI."
			lCont := .F.
		Endif
	elseIf cTipoTM <> 'R'
		If !RetCodUsr() $ GETMV("ZZ_MOVINT")
			cProblema   := "Usu�rio sem permiss�o para realizar essa movimenta��o"
			cSolucao    := "Para fazer essa movimenta��o, solicite ao TI."
			lCont := .F.
		Endif
	//Caso o produto seja padr�o
	elseif SubStr(cProd,1,5) == "09A20" .and. !(IsInCallStack("U_BXPADROES")) .and. !(IsInCallStack("U_MNTPADR"))
		if !cFilAnt $ GetMv("ZZ_FILPAD")
			cProblema   := "Produtos classificados como 'PADR�O' n�o podem ser requisitados."
			cSolucao    := "Utilize a rotina de baixa de padr�es."
			lCont := .F.
		Endif
	endif

	/*
	If lCont .and. cTpProd == "MP" .and. Empty(CCC) .and. SM0->M0_CODIGO == '01' .and. !(IsInCallStack("U_BXPADROES"))
		IW_MsgBox(OemToAnsi("Em produtos classificados como 'MP' o campo 'CENTRO DE CUSTO' deve ser preenchido.") , OemToAnsi("Aten��o") , "STOP")
		lCont := .F.
	Endif*/

	if !lCont
		Help(NIL, NIL, "MT241LOK", NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
    endif

Return lCont
