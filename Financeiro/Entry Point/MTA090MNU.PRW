#include 'totvs.ch'

/*/{Protheus.doc} MTA090MNU
adiciona rotinas no menu cadastro de moeda
@type function
@version 12.1.27
@author Leandro Cesar (solução compacta)
@since 16/05/2022
/*/
user function MTA090MNU()
	aAdd(aRotina, 	{ "@Atualização Moeda BC","U_UpdTaxBC()"		,0,1,0,.F.})
return()
