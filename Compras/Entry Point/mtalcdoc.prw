#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} MTALCDOC
O Ponto de entrada é executado após geração ou atualização da alçada
@type function
@version 12.1.33
@author Leandro Cesar
@since 11/11/2022
/*/
User Function MTALCDOC()
	local aDoc   := PARAMIXB[1]
	// local dData  := PARAMIXB[2]
	local nTp    := PARAMIXB[3]
	// local cGrpIT := PARAMIXB[4]

	If nTp == 3 .and. !"EXCLUIR" $ UPPER(cCadastro)

		cQuery := ""
		cQuery += " SELECT TOP 1 R_E_C_N_O_ AS REC_SCR, CR_STATUS AS STATUS_SCR FROM " + RetSqlName("SCR") + " SCR "
		cQuery += " WHERE CR_FILIAL = '" + FwCodFil() + "' "
		cQuery += " AND CR_NUM = '" + aDoc[1] + "'"
		cQuery += " AND CR_TIPO = '" + aDoc[2] + "'"
		cQuery += " ORDER BY 1 DESC "
		TcQuery cQuery New Alias (cTRB := GetNextAlias())

		dbSelectArea((cTRB))
		If (cTRB)->(!eof())
			If (cTRB)->STATUS_SCR == '03'
				dbSelectArea("SCR")
				SCR->(dbGoTo((cTRB)->REC_SCR))

				If alltrim(SCR->CR_NUM) == alltrim(aDoc[1])
					SCR->(DBRecall())
				EndIf

			EndIf
		EndIf
		(cTRB)->(dbCloseArea())

	EndIf


Return
