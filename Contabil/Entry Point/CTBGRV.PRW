#INCLUDE 'TOTVS.CH'

User Function CTBGRV()

	local cOrigem := ALLTRIM(PARAMIXB[2])
	local nRecno  := 0
	local aArea   := GetArea()

	If cOrigem == "CTBA500"
		nRecno := aArea[3]

		dbSelectArea( "CT2" )
		dbGoTo( nRecno )

		Reclock("CT2", .F.)
        CT2->CT2_TPSALD := padr("3",TamSx3("CT2_TPSALD")[1])
        CT2->CT2_MANUAL := '1'
		MsUnlock()

	EndIf

	RestArea(aArea)
return
