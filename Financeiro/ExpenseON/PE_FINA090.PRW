#Include	"Protheus.Ch"


//Pontos de Entrada FINA090 sera executado na baixa automatica.
User Function FINA090() 

    Local aAreaAtu := getArea()

    //Atualização do status de pagamento para o ExpenseON
    If ExistBlock("FSWIP002")
        If FieldPos("E2_XIDEXP") > 0
            If !Empty(SE2->E2_XIDEXP)
                U_FSWIP002(SE2->E2_FILIAL,AllTrim(SE2->E2_XIDEXP),SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO),.F.)
            EndIf
        EndIf
    EndIf
    
    RestArea(aAreaAtu)

Return ()