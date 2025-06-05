#INCLUDE "PROTHEUS.CH"
#include 'topconn.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} MT120CPE
Este Ponto de entrada é executado após a inicialização das 
variáveis contendo os dados do cabeçalho do Pedido de Compras. 
Este ponto de entrada tem por objetivo customizar os dados 
das variáveis do cabeçalho do Pedido de Compras.

@type		Function
@author		Julio Lisboa
@since		26/08/2020
/*/
//-----------------------------------------------------------------
User Function MT120CPE()

    Local nOperacao     := PARAMIXB[01]

    geraLog( "Inicio Rotina" )
    
    If FWISINCALLTACK("U_ImpPOCOUPA")
        If nOperacao == 3
            If Type("__nMoedaPC") == "N" .AND. Type("nMoedaPed") == "N"
                geraLog( "Trocando a moeda De/para [" + cValToChar(nMoedaPed) + "/" + cValToChar(__nMoedaPC) + "]" )
                nMoedaPed       := __nMoedaPC
            EndIf
        EndIf
    EndIf

    geraLog( "Final Rotina" )

Return

//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

	Conout("[" + DTOC(Date()) + " " + Time() + "] MT120CPE - " + cMensagem )

Return
