#include 'totvs.ch'
#include 'topconn.ch'

user function MA020BUT()
	local aButUsr := {} as array

	aadd(aButUsr,{'BMPGROUP', {|| U_RetEmpFlash("SA2") }, "# Vinc. Empresa - Flash", "# Vinc. Empresa - Flash" })

return(aButUsr)

// ---------------------------------------------------------------------------------------------------------------------------------------------------


User Function RetEmpFlash(cp_Origem)

	local cTitulo    := "Cad. Empresa Flash - ExpenseOn"
	local MvPar      := ""
	local MvParDef   := ""
	local aAreaAtual := GetArea()
	local cAux       := ""
	local cTabela    := ":E"
	local nX         := 0
	local nTamMax    := 4
	private aSit     := {} , l1Elem := .F.
	default cp_Origem := "SZZ"

	If cp_Origem == 'SA2'
		MvPar            := Alltrim(M->A2_XEMPFLS)

		If M->A2_TPESSOA != 'FF'
			Help('',1,'FMULTIOP',,'Opção disponível apenas para o Tipo Pesso (FF - Funcionario)!',1,0)
			return(.F.)
		EndIf

	Else
		MvPar            := Alltrim(M->ZZ_EMPFLS)
		If M->ZZ_TPPESSO != 'FF'
			Help('',1,'FMULTIOP',,'Opção disponível apenas para o Tipo Pesso (FF - Funcionario)!',1,0)
			return(.F.)
		EndIf
	Endif
	// CursorWait()
	aRetSX5 := FWGetSX5( cTabela )

	cQuery := ""
	cQuery += " SELECT X5_CHAVE AS CHAVE, X5_DESCRI AS DESCRI
	cQuery += " FROM " + RetSqlname("SX5")+ " SX5 "
	cQuery += " WHERE SX5.D_E_L_E_T_ = '' "
	cQuery += " AND SX5.X5_FILIAL = '0100' "
	cQuery += " AND X5_TABELA = '" + cTabela + "'
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))


	If (cTRB)->(!eof())

		aCat := {}
		while (cTRB)->(!eof())
			aAdd(aCat,alltrim((cTRB)->CHAVE) + " - " + Alltrim((cTRB)->DESCRI))
			mvparDef += alltrim((cTRB)->CHAVE)
			(cTRB)->(dbSkip())
		EndDo
	Else
		Help('',1,'FMULTIOP',,'As opções não foram inseridas!',1,0)
		return(.F.)
	Endif
	// If len(aRetSX5) > 0

	// 	aCat := {}
	// 	For nX := 1 to len(aRetSX5)
	// 		aAdd(aCat,alltrim(aRetSX5[nX][3]) + " - " + Alltrim(aRetSX5[nX][4]))
	// 		mvparDef += alltrim(aRetSX5[nX][3])
	// 	Next nX
	// Else
	// 	Help('',1,'FMULTIOP',,'As opções não foram inseridas!',1,0)
	// 	return(.F.)
	// Endif


	// CursorArrow()

	IF f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,,,l1Elem,nTamMax,14,,,,.T.,.T.)
		For nX :=1 To Len(mvpar) Step nTamMax
			If Substr(mvPar,nX,nTamMax) <> Replicate("*",nTamMax)
				cAux += Substr(mvPar,nX,nTamMax)+"#"
			Endif
		Next

		If cp_Origem == 'SA2'
			FwFldPut( 'A2_XEMPFLS'    , cAux        , , , , .T.)
		Else
			FwFldPut( 'ZZ_EMPFLS'    , cAux        , , , , .T.)
		Endif

	EndIF
	RestArea(aAreaAtual)

Return(.T.)
