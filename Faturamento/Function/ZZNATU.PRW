#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"

/*/{protheus.doc}ZZNATU
    Gatilho que valida a natureza do cliente que está no cadastro de Cliente x Nature (ZB7010.PRW)
    @author Régis Ferreira
    @since 25/05/2020
/*/

User Function ZZNATU()


	Local aArea		:= GetArea()
	Local cCliente  := AllTrim(M->C5_CLIENTE)
	Local cLoja     := AllTrim(M->C5_LOJACLI)
	Local cNatureza := AllTrim(M->C5_NATUREZ)

	BeginSql Alias "C5_NATU"
        Select
            ZB7_NATURE 'NATUREZA'
        From
            %Table:ZB7% ZB7
        where
            ZB7.%NotDel% AND
            ZB7_FILIAL = %Exp:cFilAnt% AND
            ZB7_CLIENT = %Exp:cCliente% AND
            ZB7_LOJA   = %Exp:cLoja%
	EndSql

	While (C5_NATU->(!EOF()))

		cNatureza := C5_NATU->NATUREZA

		If Posicione("SED",1,xFilial("SED")+ PadL(cNatureza,TamSx3("C5_NATUREZ")[1]),"ED_CALCISS") == "S"
			M->C5_RECISS := "1"
		Else
			M->C5_RECISS := "2"
		EndIf

		C5_NATU->(DbSkip())
	End

	C5_NATU->(DbCloseArea())
	RestArea(aArea)

Return cNatureza
