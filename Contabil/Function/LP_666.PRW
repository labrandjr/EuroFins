#include 'totvs.ch'

// u_lp_666("CD","001")
// EJEFOR("666-001        ")
user function lp_666(cp_TP, cp_Seq)
	local xRet

	If cp_TP == "CD" .and. cp_Seq == "001"
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(FWxFilial("SB1") + SD3->D3_COD)

			If alltrim(SB1->B1_ZZSUBGR) $ "092"
				xRet := "41101001"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09A"
				xRet := "41101002"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09B"
				xRet := "41101003"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09C"
				xRet := "41101004"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09D"
				xRet := "41101005"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09E"
				xRet := "41101006"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09F"
				xRet := "41101007"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09G"
				xRet := "41101008"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09Z"
				xRet := "41101009"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "09H"
				xRet := "41101016"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "11A"
				xRet := "41105009"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "15Z"
				xRet := "41102015"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "18B"
				xRet := "42104004"
			ElseIf alltrim(SB1->B1_ZZSUBGR) $ "18C"
				xRet := "42104003"
			Else
				xRet := ""
			EndIf
		EndIf
	EndIf

return(xRet)
