#include 'totvs.ch'

/*/{Protheus.doc} MTA090MNU
adiciona rotinas no menu cadastro de moeda
@type function
@version 12.1.27
@author Leandro Cesar (solu��o compacta)
@since 16/05/2022
/*/
user function MTA090MNU()
	aAdd(aRotina, 	{ "@Atualiza��o Moeda BC","U_UpdTaxBC()"		,0,1,0,.F.})
return()
