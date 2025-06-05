#Include	"Protheus.Ch"


//O ponto de entrada F430BXA tem como finalidade permitir a gravação de complemento das baixas CNAB a pagar do retorno bancário.
//Este ponto de entrada é chamado a cada registro do arquivo de retorno
User Function F430BXA() 

    Local aAreaAtu := getArea()

    //Atualização do status de pagamento para o ExpenseON 
    If ExistBlock("FSWIP002")
        If FieldPos("E2_XIDEXP") > 0
            If !Empty(SE2->E2_XIDEXP) .and. SE2->E2_SALDO == 0
                U_FSWIP002(SE2->E2_FILIAL,AllTrim(SE2->E2_XIDEXP),SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO),.F.)
            EndIf
        EndIf
    EndIf
        
    RestArea(aAreaAtu)

Return ()