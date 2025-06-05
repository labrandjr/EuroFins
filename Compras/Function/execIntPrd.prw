#include "totvs.ch"
#include "topconn.ch"
#include "Dbstruct.ch"

#DEFINE     INTEGRADO           "1"
#DEFINE     NAO_INTEG           "2"
#DEFINE     ERRO_INTE           "3"

/*/{Protheus.doc} execIntPrd
Realiza a integração dos produtos

@type 		function
@author 	Julio Lisboa
@since 		19/03/2020
@return		nil, nulo
/*/
User Function execIntPrd()

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

    aAdd(aParamBox,{1,"Produto de"       	,space(getSX3Cache("B1_COD","X3_TAMANHO")),"","","SB1","",50,.F.}) //MV_PAR01
    aAdd(aParamBox,{1,"Produto até"    		,space(getSX3Cache("B1_COD","X3_TAMANHO")),"","","SB1","",50,.T.}) //MV_PAR02
    aAdd(aParamBox,{1,"Tipo de"    		    ,space(getSX3Cache("B1_TIPO","X3_TAMANHO")),"","","02","",20,.F.}) //MV_PAR03
    aAdd(aParamBox,{1,"Tipo até"   		    ,space(getSX3Cache("B1_TIPO","X3_TAMANHO")),"","","02","",20,.T.}) //MV_PAR04
    aAdd(aParamBox,{1,"Grupo De"   		    ,space(getSX3Cache("B1_ZZSGPRD","X3_TAMANHO")),"","","SZH","",20,.F.}) //MV_PAR05
    aAdd(aParamBox,{1,"Grupo Ate"   		,space(getSX3Cache("B1_ZZSGPRD","X3_TAMANHO")),"","","SZH","",20,.T.}) //MV_PAR06
    aAdd(aParamBox,{2,"Status"    			,"1",aOpcao,65,"",.T.})	//MV_PAR07

    lPerg	:= ParamBox(aParamBox,"Parametros",,,,.T.,,,,"execIntPrd",.T.,.T.)

Return lPerg

//*******************************************************
static function fProcess()

    Local cQuery        := ""
    Local cAlias        := GetnextAlias()
    Local nQtdReg       := 0
    Local aAreaSB1      := SB1->(GetArea())
    Local nReg          := 0

    cQuery      += "SELECT " + CRLF
    cQuery      += "    DISTINCT B1_COD" + CRLF
    cQuery      += "FROM " + CRLF
    cQuery      += "    " + RetSqlTab("SB1") + CRLF
    cQuery      += "WHERE " + CRLF
    cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
    cQuery      += "    AND B1_ZZINTPA = 'S' " + CRLF
    cQuery      += "    AND B1_FILIAL = '" + FwXfilial("SB1") + "'" + CRLF
    cQuery      += "    AND B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
    cQuery      += "    AND B1_TIPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
    cQuery      += "    AND B1_ZZSGPRD BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF

    If MV_PAR07 == "1" //Não integrados
        cQuery      += "    AND B1_ZZINTEG = '" + NAO_INTEG + "' " + CRLF
    ElseIf MV_PAR07 == "2" //Com erro
        cQuery      += "    AND B1_ZZINTEG = '" + ERRO_INTE + "' " + CRLF
    EndIf

    cQuery      += "ORDER BY " + CRLF
    cQuery      += "    B1_COD " + CRLF

    TcQuery cQuery New Alias &cAlias
    Count to nQtdReg
    (cAlias)->(DbGoTop())

    SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
    ProcRegua( nQtdReg )

    If (cAlias)->(!Eof())
        While (cAlias)->(!Eof())

            If SB1->(DbSeek( xFilial("SB1") + (cAlias)->B1_COD ))
                U_fIntPrd(.T.)
            EndIf

            nReg++
            IncProc("Processando Registro [" + cValToChar(nReg) + "/" + cValToChar(nQtdReg) + "]")
            (cAlias)->(DbSkip())
        EndDo
    Else
        MsgAlert("Nenhum registro localizado com os parâmetros informados.",FunDesc())
    EndIf

    RestArea(aAreaSB1)

return
