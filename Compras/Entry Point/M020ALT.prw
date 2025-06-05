#include "topconn.ch"
#include "Protheus.ch"
#INCLUDE "rwmake.ch"

/*/{protheus.doc}M020ALT
Ponto de entrada na alteracao do cadastro de fornecedores
/*/

User Function M020ALT()

    Local aArea			:= GetArea()
    Local lForInt		:= GetNewPar("ZZ_FORINT",.F.)

    If lForInt .and. existBlock("fIntFor")
        U_fIntFor(.F.)
    EndIf

    RestArea(aArea)

Return


