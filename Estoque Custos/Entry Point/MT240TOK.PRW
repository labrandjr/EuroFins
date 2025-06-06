#include 'rwmake.ch'

/*/{Protheus.doc} MT240TOK
Ponto de entrada na rotina de movimentos internos (Mod 1)
para valida��o do c�digo do produto que est� sendo baixado.
@author R�gis Ferreira Totvs IP Jundia�
@since 18/06/2020
@version 1.0

@type function
/*/
User Function MT240TOK

    Local lRet  := .T.
    Local cProd := Alltrim(M->D3_COD)
    Local cTm   := M->D3_TM
    Local cProblema := ""
    Local cSolucao  := ""

    //Caso o produto movimente Valores
    If Posicione("SF5",1,xFilial("SF5")+cTm,"F5_VAL") == "S"
        If !RetCodUsr() $ GETMV("ZZ_TMVAL") 
            cProblema   := "Usu�rio sem permiss�o para realizar movimenta��es valorizadas."
		    cSolucao    := "Para fazer essa movimenta��o, solicite ao TI."
		    lRet := .F.
	    Endif
    //Caso a movimenta��o n�o seja requisi��o
    elseif Posicione("SF5",1,xFilial("SF5")+cTm,"F5_TIPO") <> "R"
        If !RetCodUsr() $ GETMV("ZZ_MOVINT")
		    cProblema   := "Usu�rio sem permiss�o para realizar essa movimenta��o"
		    cSolucao    := "Para fazer essa movimenta��o, solicite ao TI."
            lRet := .F.
	    Endif
    //Caso o produto seja padr�o
    elseif SubStr(cProd,1,5) == "09A20"
        if !cFilAnt $ GetMv("ZZ_FILPAD")
		    cProblema   := "Produtos classificados como 'PADR�O' n�o podem ser requisitados."
		    cSolucao    := "Utilize a rotina de baixa de padr�es."
            lRet := .F.
	    Endif
    endif

    if !lRet
		Help(NIL, NIL, "MT240TOK", NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
    endif

Return (lRet)
