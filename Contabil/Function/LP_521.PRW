#include 'totvs.ch'

user function LP_521(cp_Tipo)
	local nValRet as numeric
	local cChave as character

	nValRet := 0
	cChave := SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)
	If cp_Tipo == "VLR"
		dbSelectArea("FIA")
		FIA->(dbSetOrder(1))
		If dbSeek(cChave)
			while FIA->(!eof()) .and. FIA->(FIA_FILIAL + FIA_CLIENT + FIA_LOJA + FIA_PREFIX + FIA_NUM + FIA_PARCEL + FIA_TIPO) == cChave
				nValRet += FIA->FIA_VLLOC
				FIA->(dbSkip())
			EndDo
			nValRet := Round(nValRet,TamSx3("FIA_VLLOC")[2])
		EndIf
	EndIf

return(nValRet)
