#include 'totvs.ch'
// U_LP_511("CRED", "004")
user function LP_511(cp_Tipo, cp_Seq)
	local xRet := nil

	If cp_Tipo == "CRED"
		If cp_Seq == '004'
			IF alltrim(SE2->E2_NATUREZ) == "0210001"
				xRet := "11302006"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0210002"
				xRet := "11301001"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0213005"
				xRet := "11302010"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0210003"
				xRet := "11302009"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0210004"
				xRet := "11302009"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0210010"
				xRet := "11302009"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0202017"
				xRet := "11302009"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0210012"
				xRet := "11302009"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0202018"
				xRet := "11302006"
			ElseIF alltrim(SE2->E2_NATUREZ) == "0202019"
				xRet := "11302006"
			Else
				xRet := ""
			EndIf
		EndIf
	EndIf

return(xRet)
