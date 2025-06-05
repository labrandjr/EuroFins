/*/{Protheus.doc} EUGAT001
Gatilho que irá replicar o pedido de compras do cliente (C6_PEDCLI) para todas as linhas do pedido de venda conforme solicitado pela Renata Pereira

@type Gatilho
@author Régis Ferreira
@since 04/10/2024
@version 1.0
/*/
User Function EUGAT001()

    Local cPVCliente    := M->C6_PEDCLI
    Local nPosAtu       := n
    Local nContador     := 0
    Local nPosPVCli     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PEDCLI"})
    Local lValida       := SuperGetMv("ZZ_GPEDCLI",.F.,.F.)

    if lValida
        if !IsInCallStack("U_INSPVENDA") .and. !IsInCallStack("U_ANATECHCONNECT")
            if MsgYesNo("Deseja replicar o pedido do cliente para todas as linhas do pedido?","Atenção")

                for nContador := 1 to len(aCols)
                    If !aCols[nContador,Len(aHeader)+1]
                        if nContador <> nPosAtu
                            aCols[nContador][nPosPVCli] := cPVCliente
                        endif
                    endif
                Next nContador
            endif
        endif
    endif

Return cPVCliente
