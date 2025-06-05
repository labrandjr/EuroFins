#include "Totvs.ch"  

/*/{Protheus.doc} axCadZZG
//Cadastro tabela ZZG
@author R�gis Ferreira
@since 16/11/2021
@version 1.0
@type function
/*/
User Function axCadZZG()

	Local cAlias 		:= "ZZG"
	Local cTitulo 		:= "Cond. Pagto InterCompany"
	Local cValida  		:= "U_INCZZG()"

	AxCadastro(cAlias,cTitulo,,cValida)

Return

User Function IncZZG

	Local cQuery := ""
	Local lRet	 := .T.
	Local nRegs  := 0

	if INCLUI

		cQuery := " Select " + CRLF
		cQuery += " 	ZZG_CLIENT " + CRLF
		cQuery += " From " + CRLF
		cQuery += " "+RetSqlName("ZZG")+" " + CRLF
		cQuery += " where " + CRLF
		cQuery += " 	ZZG_CLIENT 		= '"+M->ZZG_CLIENT+"' " + CRLF
		cQuery += " 	and ZZG_LOJA 	= '"+M->ZZG_LOJA+"' " + CRLF
		cQuery += " 	and D_E_L_E_T_ 	= ' ' " + CRLF
		cQuery += " 	and ZZG_FILIAL = '"+cFilAnt+"' " + CRLF

		dbUseArea(.t., "TOPCONN", TCGenQry(,, cQuery), "TMP", .f., .t.)

		Count to nRegs

		TMP->(dbCloseArea())

		if nRegs > 0
			lRet := .F.
			Help(NIL, NIL, "AXCADZZG", NIL, "Cadastro duplicado. Cliente/Loja j� tem cadastro nessa rotina!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Reveja se o cliente/loja est� correto ou altere o cadastro j� existente."})
		endif

	endif

Return lRet
