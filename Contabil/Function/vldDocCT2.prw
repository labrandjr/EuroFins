#include 'totvs.ch'


user function vldDocCT2()
	local lRet := .T. as logical

	cCpo := alltrim(&(ReadVar()))
	lCt102Auto := IIf(Type("lCt102Auto") == "U", .T., lCt102Auto)

	If len(cCpo) < 9
		If IsNumeric(cCpo)
			&(ReadVar()) := REPLICATE("0", 9-len(cCpo)) + cCpo
		EndIf
	EndIf


return(lRet)
