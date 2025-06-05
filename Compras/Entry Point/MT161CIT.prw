#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT161CIT
No acionamento do botão Analisa Cotação, filtra somente os itens que ainda não foram analizados
@author ricardo rey
@since 24/04/2018
/*/
user function MT161CIT()
	Local cFiltro := ''

	cFiltro := " AND C8_PRODUTO NOT IN (SELECT CE_PRODUTO FROM " + RetSqlName("SCE") + " WHERE CE_NUMCOT = '" + SC8->C8_NUM + "' AND CE_FILIAL = '" + xFilial("SCE") +"') "
	//cFiltro := " AND C8_ZZANALI <> 'S' "
Return (cFiltro)