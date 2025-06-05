#include "protheus.ch"
#include "parmtype.ch"
/*/{protheus.doc} CRMA980
Ponto de entrada mvc 
@author Sergio Braz
@since 11/10/2019
/*/
Static nExecModelPos := 0 
User Function CRMA980()
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.
    Local nLinha := 0
    Local nQtdLinhas := 0
    Local cMsg := ""
    If aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)
        If cIdPonto == "MODELPOS"  
        	If ++nExecModelPos == 1 .and. (INCLUI .or. (ALTERA .AND. M->A1_RISCO<>SA1->A1_RISCO))
        		U_LogRisco()
        	Endif
        ElseIf cIdPonto == "FORMPOS"
        ElseIf cIdPonto == "FORMLINEPRE"
        ElseIf cIdPonto == "FORMLINEPOS"
        ElseIf cIdPonto == "MODELCOMMITTTS"
            If INCLUI			
				u_m030inc()
			EndIf	
		ElseIf cIdPonto == "MODELCOMMITNTTS"
        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
        ElseIf cIdPonto == "MODELCANCEL"
        ElseIf cIdPonto == "BUTTONBAR"
        EndIf
    EndIf
Return xRet
 