#include "totvs.ch"
#include "topconn.ch"
#include "Dbstruct.ch"

#DEFINE     INTEGRADO           "1"
#DEFINE     NAO_INTEG           "2"
#DEFINE     ERRO_INTE           "3"

/*/{Protheus.doc} execIntFor
Realiza a integração dos fornecedores

@type 		function
@author 	Julio Lisboa
@since 		19/03/2020
@return		nil, nulo
/*/
User Function execIntFor()

    If fPerg()
        Processa( {|| fProcess() })
    EndIf

Return

//*******************************************************
static function fPerg()

    Local aParamBox 	:= {}
    Local aOpcao        := {}

    aAdd( aOpcao , "1=Não Integrados" )
    aAdd( aOpcao , "2=Com Erros" )
    aAdd( aOpcao , "3=Todos" )

    aAdd(aParamBox,{1,"Fornecedor de"       ,space(getSX3Cache("A2_COD","X3_TAMANHO")),"","","SA2","",50,.F.}) //MV_PAR01
    aAdd(aParamBox,{1,"Loja de"             ,space(getSX3Cache("A2_LOJA","X3_TAMANHO")),"","","","",35,.F.}) //MV_PAR02
    aAdd(aParamBox,{1,"Fornecedor até"    	,space(getSX3Cache("A2_COD","X3_TAMANHO")),"","","SA2","",50,.T.}) //MV_PAR03
    aAdd(aParamBox,{1,"Loja Ate"            ,space(getSX3Cache("A2_LOJA","X3_TAMANHO")),"","","","",35,.T.}) //MV_PAR04
    aAdd(aParamBox,{2,"Status"    			,"1",aOpcao,65,"",.T.})	//MV_PAR05

    lPerg	:= ParamBox(aParamBox,"Parametros",,,,.T.,,,,"execIntFor",.T.,.T.)

Return lPerg

//*******************************************************
static function fProcess()

    Local cQuery        := ""
    Local cAlias        := GetnextAlias()
    Local nQtdReg       := 0
    Local aAreaSA2      := SA2->(GetArea())

    cQuery      += "SELECT " + CRLF
    cQuery      += "    SA2.R_E_C_N_O_  RECNO" + CRLF
    cQuery      += "FROM " + CRLF
    cQuery      += "    " + RetSqlTab("SA2") + CRLF
    cQuery      += "WHERE " + CRLF
    cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
    cQuery      += "    AND A2_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' " + CRLF
    cQuery      += "    AND A2_LOJA BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' " + CRLF

    If MV_PAR05 == "1" //Não integrados
        cQuery      += "    AND A2_ZZINTEG = '" + NAO_INTEG + "' " + CRLF
    ElseIf MV_PAR05 == "2" //Com erro
        cQuery      += "    AND A2_ZZINTEG = '" + ERRO_INTE + "' " + CRLF
    EndIf

    cQuery      += "ORDER BY " + CRLF
    cQuery      += "    A2_COD,A2_LOJA " + CRLF

    TcQuery cQuery New Alias &cAlias
    Count to nQtdReg
    (cAlias)->(DbGoTop())

    SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
    ProcRegua( nQtdReg )

    If (cAlias)->(!Eof())
        While (cAlias)->(!Eof())

            SA2->(DbGoTo( (cAlias)->RECNO ) )

            U_fIntFor(.T.)

            IncProc()
            (cAlias)->(DbSkip())
        EndDo
    Else
        MsgAlert("Nenhum registro localizado com os parâmetros informados.",FunDesc())
    EndIf

    RestArea(aAreaSA2)

return
