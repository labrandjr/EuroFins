/*/{Protheus.doc} EUGAT002
Gatilho que irá replicar aTES cliente (C6_TES) para todas as linhas do pedido de venda conforme solicitado pela Renata Pereira

@type Gatilho
@author Régis Ferreira
@since 04/10/2024
@version 1.0
/*/
User Function EUGAT002()

    Local cNumTES       := M->C6_TES
    Local nPosAtu       := n
    Local nContador     := 0
    Local nPsoTES       := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
    Local lValida       := SuperGetMv("ZZ_GATTES",.F.,.F.)

    if lValida
        if !IsInCallStack("U_INSPVENDA") .and. !IsInCallStack("U_ANATECHCONNECT")
            if MsgYesNo("Deseja replicar a TES para todas as linhas do pedido?","Atenção")

                for nContador := 1 to len(aCols)
                    If !aCols[nContador,Len(aHeader)+1]
                        if nContador <> nPosAtu
                            aCols[nContador][nPsoTES] := cNumTES
                        endif
                    endif
                Next nContador
            endif
        endif
    endif

Return cNumTES
