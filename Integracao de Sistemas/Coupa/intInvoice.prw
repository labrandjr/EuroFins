#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} INTINVOICE
Chama função para criar csv no servidor
@author Tiago Maniero
@since 26/05/2020
/*/
User Function IntInvoice(lForce,lDelete)
	local aArea   := getArea()
	local aAreaC7 := SC7->(getArea())

	default lForce	:= .F.
	default lDelete := .F.

	geraLog(Replicate("-",20))
	geraLog( "Inicio rotina" )
	geraLog("Filial/NF/Serie: [" + SF1->F1_FILIAL + '/' + SF1->F1_DOC + '/' + SF1->F1_SERIE + ']')

	DbSelectArea("SC7")
	DbSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	if DbSeek(SD1->D1_FILIAL+SD1->D1_PEDIDO)
		geraLog("Pedido: [" + SD1->D1_PEDIDO + ']')

		If lForce
			u_expInvoice(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,lDelete)
		else
			u_expInvoice(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,lDelete)
		endif
	endif

	geraLog( "Final rotina" )
	geraLog(Replicate("-",20))

	RestArea(aArea)
	RestArea(aAreaC7)

Return


//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

	Conout("[" + DTOC(Date()) + " " + Time() + "] IntInvoice - " + cMensagem )

Return
