#include "totvs.ch"
#include "fwmvcdef.ch"
/*/{protheus.doc} CTBA020
ponto de entrada mvc, torna obrigatorio preencher visão gerencial da linha
@author Unknown
@since __/__/____
/*/


User Function CTBA020()
Local aParam := PARAMIXB
Local xRet := .T.
Local oObj := ''
Local cIdPonto := ''
Local cIdModel := ''
Local oModelCts := nil
Local nLinha := 0
Local cMsg := ''
If aParam <> NIL
	oObj := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]
	If cIdPonto == 'MODELPOS'
		oModelCts := oObj:getModel('CTSDETAIL')
		for nI := 1 to oModelCts:Length()
			oModelCts:GoLine(nI)
			If EMPTY (oModelCts:GetValue("CTS_CODPLA"))
				xRet := .F.
				Help( ,, 'Help',, 'Favor preencher a Visao Gerencial da linha '+ cValToChar(nI), 1, 0 )
				EXIT
			endif
		next
	endIf
endIf
Return xRet