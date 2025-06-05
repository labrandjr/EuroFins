/*/{Protheus.doc} MT103NTZ
Ponto de entrada para mudar a natureza financeira quando há integração pelo lincros
Ao integrar CTE precisa usar uma natureza especifica
@type function
@author Régis Ferreira - Totvs IP Jundiaí 
@since 06/03/2023
/*/
User function MT103NTZ()          
    
    Local cNatuCTE := ParamIxb[1]

    if IsInCallStack("U_LINCIP01") //Se vier da integração do Lincros, muda a natureza
        cNatuCTE := Padr(GetMv("ZZ_LINCR09"),TamSx3("E2_NATUREZ")[1])
    endif
    
Return cNatuCTE
