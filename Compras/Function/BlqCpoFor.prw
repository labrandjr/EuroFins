#include 'totvs.ch'

user function blqCpoFor()
	Local lRet      := .T.
	local nI        := 0
	local nU        := 0
	local nX        := 0
	Private objOdlg := GetWndDefault()

	If Inclui
		Return(.T.)
	EndIf

	If Altera
		For nI := 1 To Len(objOdlg:aControls)
			If ValType(objOdlg:aControls[nI]) <> 'U' .And. AllTrim(Upper(objOdlg:aControls[nI]:ClassName())) $ "TFOLDER"
				For nU := 1 To Len(objOdlg:ACONTROLS[nI]:APROMPTS)
					For nX := 1 To Len(objOdlg:aControls)
						If ValType(objOdlg:aControls[nX]) <> 'U' .And. AllTrim(Upper(objOdlg:aControls[nX]:CLASSNAME())) $ "FWTGET/FWCOMBOBOX"
							If cValToChar(GetSx3Cache(Trim(Upper(strTran(objOdlg:aControls[nX]:cReadVar,'M->',''))),"X3_FOLDER")) != ;
									cValToChar(aScan(objOdlg:ACONTROLS[nI]:APROMPTS,{|x| upper(alltrim(x)) == "FISCAIS"}))
								objOdlg:aControls[nX]:bWhen := {|X| SELF:lActive  .AND. .F.}
							EndIf
						EndIf
					Next nJ
				Next nU
			EndIf
		Next nI
	EndIf

return( lRet )
