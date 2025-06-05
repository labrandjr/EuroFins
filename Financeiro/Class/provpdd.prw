#include 'totvs.ch'
#include 'topconn.ch'

CLASS ProvPDD

	Data cFil
	Data cTitulo
	Data cPrefixo
	Data cParcela
	Data cTipo
	Data cCliente
	Data cLoja
	Data oObj

	METHOD New() CONSTRUCTOR
	METHOD UpdPDDTit()
	METHOD Deactivate()

	// Demais métodos pertinentes a sua classe

ENDCLASS

// ----------------------------------------------------------------------------------------------------------------------------------------------------------

METHOD New() CLASS ProvPDD

	::cFil     := ""
	::cTitulo  := ""
	::cPrefixo := ""
	::cParcela := ""
	::cTipo    := ""
	::cCliente := ""
	::cLoja    := ""
	Self:oObj  := NIL

Return Self

// ----------------------------------------------------------------------------------------------------------------------------------------------------------

METHOD UpdPDDTit() CLASS ProvPDD
	local cQuery := "" as character

	cQuery := ""
	cQuery += " SELECT E1_FILIAL AS FILIAL, E1_PREFIXO AS PREFIXO, E1_NUM AS NUMERO, E1_PARCELA AS PARCELA, E1_TIPO AS TIPO
	cQuery += " , E1_CLIENTE AS CLIENTE, E1_LOJA AS LOJA
	cQuery += " , ROUND(SUM(FIA_VLLOC),2) AS VALOR
	cQuery += " , ROUND(ROUND(SUM(FIA_VLLOC),2) / E1_VALOR,2)*100 AS PERC
	cQuery += " FROM " + RetSqlName("FIA") + " FIA
	cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ''
	cQuery += " AND E1_FILIAL = FIA_FILIAL
	cQuery += " AND E1_NUM = FIA_NUM
	cQuery += " AND E1_PREFIXO = FIA_PREFIX
	cQuery += " AND E1_PARCELA = FIA_PARCEL
	cQuery += " AND E1_TIPO = FIA_TIPO
	cQuery += " AND E1_CLIENTE = FIA_CLIENT
	cQuery += " AND E1_LOJA = FIA_LOJA
	cQuery += " AND E1_SALDO != 0
	cQuery += " GROUP BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	while (cTRB)->(!eof())

		dbSelectArea("SE1")
		dbSetOrder(1)
		If dbSeek( (cTRB)->FILIAL + (cTRB)->PREFIXO + (cTRB)->NUMERO + (cTRB)->PARCELA + (cTRB)->TIPO)
			reclock("SE1",.F.)
			SE1->E1_XPRVPRD := (cTRB)->VALOR
			SE1->E1_XPERCPE := (cTRB)->PERC
			SE1->(MsUnlock())
		EndIf
		(cTRB)->(dbSkip())
	EndDo
	(cTRB)->(dbCloseArea())

Return

// ----------------------------------------------------------------------------------------------------------------------------------------------------------


METHOD Deactivate() CLASS ProvPDD

	If ::oObj <> NIL
		::oObj:DeActivate()
		FreeObj(::oObj)
		::oObj := Nil
	EndIf

Return
