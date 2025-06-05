#include "topconn.ch"
#include "Protheus.ch"
#INCLUDE "rwmake.ch"

/*
���Programa  � M030INC  �Autor  � Marcos Candido     � Data �  12/07/13   ���
���Desc.     � Ponto de entrada na inclusao do cadastro de clientes.      ���
���          � Usado para criar conta contabil automaticamente.           ���
���Uso       � Eurofins                                                   ���
*/
/*/{Protheus.doc} M030INC
Na inclusao do cadastro de clientes.Usado para criar conta contabil automaticamente.
@author Marcos Candido
@since 02/01/2018
/*/
User Function M030INC

	Local aArea:= GetArea()
    Local lOk   := .F.

    If Valtype(PARAMIXB) == "N"
        lOk     := PARAMIXB <> 3
    Else
        lOk     := .T.
    EndIf

    geraLog( Replicate("*",35))
    geraLog( "Inicio rotina" )
    geraLog( "CNPJ (M->): " + AllToChar(M->A1_CGC) )
    geraLog( "CNPJ (SA1->): " + AllToChar(SA1->A1_CGC) )
    geraLog( "PARAMIXB: " + AllToChar(PARAMIXB) )
    geraLog( "FunName: " + AllToChar(FunName()) )

    If lOk //PARAMIXB <> 3
        geraLog( "Executando programa CTBINCFC..." )
        U_CTBINCFC("1","P") // P - Ponto de Entrada
    EndIf

    geraLog( "Final rotina" )

    RestArea(aArea)

Return

Static Function geraLog( cMensagem )

    Conout("[" + DTOC(date()) + " " + Time() + "] M030INC - " + cMensagem )

Return
