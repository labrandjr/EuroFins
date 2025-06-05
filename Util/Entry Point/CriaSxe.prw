#include 'protheus.ch'
#include 'parmtype.ch'

user function CriaSXE()

Local cAlias	:= PARAMIXB[1]
Local cCampo	:= PARAMIXB[2]
Local cAliasQry	:= GetNextAlias()
Local aArea		:= GetArea()
Local cRet


If cAlias == "SC7" .and. AllTrim(cCampo) == "C7_NUM"

	BeginSql Alias cAliasQry
	
	SELECT	ISNULL(MAX(SC7.C7_NUM),'') C7_NUM
	
	FROM	%Table:SC7% SC7
	
	WHERE	SC7.C7_FILIAL = %xFilial:SC7%
		AND SUBSTRING(SC7.C7_NUM,1,1) IN ('0','1','2','3','4','5','6','7','8','9')  
		AND LEN(SC7.C7_NUM)	= 6
		AND	SC7.%NotDel%

	EndSQl
	
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!EOF())
	
		cRet := (cAliasQry)->C7_NUM
	
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	If Empty(cRet)
		cRet := "000000"
	EndIf
	
	cRet := Soma1(cRet)

elseIf cAlias == "SC5" .and. AllTrim(cCampo) == "C5_NUM"

	BeginSql Alias cAliasQry
	
	SELECT	ISNULL(MAX(SC5.C5_NUM),'') C5_NUM
	
	FROM	%Table:SC5% SC5
	
	WHERE	SC5.C5_FILIAL	= %xFilial:SC5%
		AND SUBSTRING(SC5.C5_NUM,1,1) IN ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E')  
		AND LEN(SC5.C5_NUM)	= 6
		AND	SC5.%NotDel%
	
	EndSQl
	
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!EOF())
	
		cRet := (cAliasQry)->C5_NUM
	
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	If Empty(cRet)
		cRet := "000000"
	EndIf
	
	cRet := Soma1(cRet)	

elseIf cAlias == "SA1" .and. AllTrim(cCampo) == "A1_COD"

	BeginSql Alias cAliasQry
	
	SELECT	ISNULL(MAX(SA1.A1_COD),'') A1_COD
	
	FROM	%Table:SA1% SA1
	
	WHERE	SA1.A1_FILIAL = %xFilial:SA1%
		AND SUBSTRING(SA1.A1_COD,1,1) IN ('0','1','2','3','4','5','6','7','8','9')  
		AND LEN(SA1.A1_COD)	= 6
		AND	SA1.%NotDel%
	
	EndSQl
	
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!EOF())
	
		cRet := (cAliasQry)->A1_COD
	
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	If Empty(cRet)
		cRet := "000000"
	EndIf
	
	cRet := Soma1(cRet)	

elseIf cAlias == "SA2" .and. AllTrim(cCampo) == "A2_COD"

	BeginSql Alias cAliasQry
	
	SELECT	ISNULL(MAX(SA2.A2_COD),'') A2_COD
	
	FROM	%Table:SA2% SA2
	
	WHERE	SA2.A2_FILIAL = %xFilial:SA2%
		AND SUBSTRING(SA2.A2_COD,1,1) IN ('0','1','2','3','4','5','6','7','8','9')  
		AND LEN(SA2.A2_COD)	= 6
		AND	SA2.%NotDel%
	
	EndSQl
	
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!EOF())
	
		cRet := (cAliasQry)->A2_COD
	
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	If Empty(cRet)
		cRet := "000000"
	EndIf
	
	cRet := Soma1(cRet)	
EndIf

RestArea(aArea)

return cRet
