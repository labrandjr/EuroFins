#include "totvs.ch"
/*/{protheus.doc}LtPhse
Inicializador de Browse para os campos da SC1 Ultimo fornecedor
@author Sergio Braz
@since 04/10/2019
/*/
User Function LtPhse(ntp)
	Local xResp
	Local aArea := GetArea()
	BeginSql Alias "DD"         
		Column DTDIGIT as Date
		Select 	D1_DTDIGIT DTDIGIT, 
				D1_FORNECE FORNECE, 
				D1_LOJA LOJA, 
				D1_VUNIT VUNIT
		From %Table:SD1% SD1, %Table:SF4% SF4
		Where SD1.%NotDel% and D1_FILIAL = %xFilial:SD1% and D1_COD = %Exp:SC1->C1_PRODUTO% and 
			SF4.%NotDel% and F4_FILIAL = %xFilial:SF4% and F4_PODER3='N' and 
			D1_TES = F4_CODIGO and D1_TIPO = 'N' 
		Order By D1_DTDIGIT Desc			
	EndSql 
	if ntp == 1
		xResp := AllTrim(Posicione("SA2",1,xFilial("SA2")+DD->FORNECE+DD->LOJA,"A2_NOME"))
	elseif ntp == 2
		xResp := DD->DTDIGIT
	elseif ntp == 3
		xResp := NoRound(DD->VUNIT,6)
	endif
	DD->(DbCloseArea())
	RestArea(aArea)
Return xResp