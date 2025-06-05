#include 'totvs.ch'
#include 'topconn.ch'


user function EuroDirf()

	If MsgYesNo("Deseja processar os registros 5952?","Aviso")
		Dirf_5952()
	EndIf

	If MsgYesNo("Deseja processar os registros 1708?","Aviso")
		Dirf_1708()
	EndIf

return()

// ---------------------------------------------------------------------------------------------------------------------------------------------------

static function Dirf_1708()


	cQuery := ""
	cQuery += " SELECT * FROM DIRF_1708"
	cQuery += " WHERE AUX = 'X' "
	TcQuery cQuery New Alias (cTRB := GetNextAlias())


	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())

	while (cTRB)->(!eof())

		dbSelectArea("SR4")
		dbSetOrder(2)
		If dbSeek( (cTRB)->FILIAL + (cTRB)->ANO + (cTRB)->CPFCGC + (cTRB)->CODRET + (cTRB)->MES)
			cMat := SR4->R4_MAT
			lAchou := .F.

			while SR4->(!eof()) .and. SR4->(R4_FILIAL + R4_ANO + R4_CPFCGC + R4_CODRET + R4_MES) == (cTRB)->FILIAL + (cTRB)->ANO + (cTRB)->CPFCGC + ;
					(cTRB)->CODRET + (cTRB)->MES

				If alltrim(SR4->R4_TIPOREN) == "A"
					lAchou := .T.
				EndIf

				SR4->(dbSkip())
			EndDo

			If !lAchou
				reclock("SR4",.T.)
				SR4->R4_FILIAL  := (cTRB)->FILIAL
				SR4->R4_ANO     := (cTRB)->ANO
				SR4->R4_CODRET  := (cTRB)->CODRET
				SR4->R4_CPFCGC  := (cTRB)->CPFCGC
				SR4->R4_MAT     := cMat
				SR4->R4_MES     := (cTRB)->MES
				SR4->R4_ORIGEM  := '2'
				SR4->R4_ISNIF   := "1"
				SR4->R4_TIPOREN := "A"
				SR4->R4_VALOR   := (cTRB)->VLR_TRIBUT
				SR4->(MsUnlock())
			EndIf

		EndIf


		(cTRB)->(dbSkip())
	EndDo
	(cTRB)->(dbCloseArea())

return()


// ---------------------------------------------------------------------------------------------------------------------------------------------------

static function Dirf_5952()


	cQuery := ""
	cQuery += " SELECT * FROM DIRF_5952"
	cQuery += " WHERE AUX = 'X' "
	TcQuery cQuery New Alias (cTRB := GetNextAlias())


	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())

	while (cTRB)->(!eof())

		dbSelectArea("SR4")
		dbSetOrder(2)
		If dbSeek( (cTRB)->FILIAL + (cTRB)->ANO + (cTRB)->CPFCGC + (cTRB)->CODRET + (cTRB)->MES)
			cMat := SR4->R4_MAT
			lAchou := .F.

			while SR4->(!eof()) .and. SR4->(R4_FILIAL + R4_ANO + R4_CPFCGC + R4_CODRET + R4_MES) == (cTRB)->FILIAL + (cTRB)->ANO + (cTRB)->CPFCGC + ;
					(cTRB)->CODRET + (cTRB)->MES

				If alltrim(SR4->R4_TIPOREN) == "A"
					lAchou := .T.
				EndIf

				SR4->(dbSkip())
			EndDo

			If !lAchou
				reclock("SR4",.T.)
				SR4->R4_FILIAL  := (cTRB)->FILIAL
				SR4->R4_ANO     := (cTRB)->ANO
				SR4->R4_CODRET  := (cTRB)->CODRET
				SR4->R4_CPFCGC  := (cTRB)->CPFCGC
				SR4->R4_MAT     := cMat
				SR4->R4_MES     := (cTRB)->MES
				SR4->R4_ORIGEM  := '2'
				SR4->R4_ISNIF    := "1"
				SR4->R4_TIPOREN := "A"
				SR4->R4_VALOR   := (cTRB)->VLR_TRIBUT
				SR4->(MsUnlock())
			EndIf

		EndIf


		(cTRB)->(dbSkip())
	EndDo
	(cTRB)->(dbCloseArea())

return()
