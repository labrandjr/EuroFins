#Include 'Protheus.ch'

/*/{Protheus.doc} MA131QSC
Acrescentado o campo C1_ITEM no filtro de aglutinação das SCs.
@author Regis Ferreira
@since 20/01/2019
@Obs Segundo o setor de compras, nenhuma OP deve ser aglutinada, pois posso pedir o mesmo
produto para a mesma data na mesma SC e isso deve ser tratado separado.
/*/

User Function MA131QSC()

	Local bQuebra := PARAMIXB[1]
	Local cFiltrSC := ""
	//Peguei o retorno de PARAMIXB[1] e acrescentei o campo C1_ITEM pois as SCs nunca devem se aglutinadas mesmo que um produto seja igual. 
	cFiltrSC :={|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_ITEM}

Return cFiltrSC