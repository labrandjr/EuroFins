#include 'rwmake.ch'

/*/{Protheus.doc} MT240TOK
Ponto de entrada na rotina de movimentos internos (Mod 1)
para validação do código do produto que está sendo baixado.
@author Régis Ferreira Totvs IP Jundiaí
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
            cProblema   := "Usuário sem permissão para realizar movimentações valorizadas."
		    cSolucao    := "Para fazer essa movimentação, solicite ao TI."
		    lRet := .F.
	    Endif
    //Caso a movimentação não seja requisição
    elseif Posicione("SF5",1,xFilial("SF5")+cTm,"F5_TIPO") <> "R"
        If !RetCodUsr() $ GETMV("ZZ_MOVINT")
		    cProblema   := "Usuário sem permissão para realizar essa movimentação"
		    cSolucao    := "Para fazer essa movimentação, solicite ao TI."
            lRet := .F.
	    Endif
    //Caso o produto seja padrão
    elseif SubStr(cProd,1,5) == "09A20"
        if !cFilAnt $ GetMv("ZZ_FILPAD")
		    cProblema   := "Produtos classificados como 'PADRÃO' não podem ser requisitados."
		    cSolucao    := "Utilize a rotina de baixa de padrões."
            lRet := .F.
	    Endif
    endif

    if !lRet
		Help(NIL, NIL, "MT240TOK", NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
    endif

Return (lRet)
