#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} VldCCSC
Gatilho no campo C1_CC para atualizar o campo C1_TIPCOM
na alteração da SC.
Isto foi necessario devido a bug na rotina padrão
que não atualiza o campo quando se altera o campo C1_CC
nas operações de Alteração da SC
@author ricar
@since 05/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function VldCCSC()
	Local aArea := GetArea()
	Local cQuery
	Local cCod := ''

	cQuery := "SELECT TOP 1 * "
	cQuery += "FROM "+RetSqlName("DHK")+" DHK "
	cQuery += "WHERE D_E_L_E_T_ <> '*' AND "
	cQuery += "DHK_FILIAL = '"+xFilial("DHK")+"' AND "
	cQuery += "DHK_SOLCOM LIKE '%"+Alltrim(M->C1_CC)+"%'"

	If Select("WRK1") > 0
		WRK1->(dbCloseArea())
	Endif

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "WRK1"

	if WRK1->(!Eof())
		cCod := WRK1->DHK_CODIGO
	endif

	WRK1->(dbCloseArea())

	RestArea(aArea)

return cCod


/*/{Protheus.doc} FiltraCC
Faz filtro para mostrar apenas CC da filial logada
Usado na consulta padrão CTT
@author ricar
@since 05/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function FiltraCC
	local lRet := .t.
	Local x:=alltrim(cFilAnt)

	IF IsInCallStack("MATA110") .OR. IsInCallStack("MATA121")
		lRet := iif(x$CTT->CTT_ZZFILI,.t.,.f.)
	ENDIF

Return lRet



/*/{Protheus.doc} VldCCSC2
Validação da digitação do CC na SC e PV
@author ricar
@since 05/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function VldCCSC2()

	Local aArea := GetArea()
	Local cQuery
	Local cCod := ''

	If FWISINCALLTACK("U_ImpPOCOUPA")
		lRet		:= .T.
	Else
		cQuery := "SELECT CTT_ZZFILI "
		cQuery += "FROM "+RetSqlName("CTT")+" CTT "
		cQuery += "WHERE D_E_L_E_T_ <> '*' AND "
		cQuery += "CTT_FILIAL = '"+xFilial("CTT")+"' AND "
		cQuery += "CTT_CUSTO = '"+iif(IsInCallStack("MATA110"),Alltrim(M->C1_CC),Alltrim(M->C7_CC))+"'"

		If Select("WRK1") > 0
			WRK1->(dbCloseArea())
		Endif

		cQuery := ChangeQuery(cQuery)
		TcQuery cQuery New Alias "WRK1"

		lRet := (cFilAnt$WRK1->CTT_ZZFILI)


		WRK1->(dbCloseArea())

		RestArea(aArea)

		if !lRet
			MsgStop("Centro de custo inválido para esta filial")
		endif
	EndIf

return lRet
