//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#include "tbiconn.ch"


User Function LP510009()
	Local _cCOnta:= ""
	Local aAreaSED:= SED->(GetArea())
	Local aAreaSA2:= SA2->(GetArea())
	Local aAreaSE2:= SE2->(GetArea())
	Local aArea:= GetArea()
	Local _cQuery:= ""


	IF SED->ED_ZZUSAUX=="S"
		_cCOnta:= SED->ED_ZZCTAUX
	ELSE
		_cQuery:= ""
		_cQuery+= " SELECT * "
		_cQuery+= " FROM "+RetSqlName("SA2")+" "
		_cQuery+= " WHERE "+RetSqlName("SA2")+".D_E_L_E_T_ = '' "
		_cQuery+= " AND A2_COD = '"+SE2->E2_FORNECE+"' "
		_cQuery+= " AND A2_LOJA = '"+SE2->E2_LOJA+"' "
		TcQuery _cQuery New Alias (cSA2 := GetNextAlias())

		IF (cSA2)->(!Eof())
			If !Empty((cSA2)->A2_CONTA)
				_cCOnta:= (cSA2)->A2_CONTA
			ELSE
				_cCOnta:= "CTA.FOR:"+(cSA2)->A2_COD+"/"+(cSA2)->A2_LOJA
			ENDIF
		Endif
		DbSelectArea((cSA2))
		(cSA2)->(DbCloseArea())
	ENDIF

	RestArea(aAreaSED)
	RestArea(aAreaSA2)
	RestArea(aAreaSE2)
	RestArea(aArea)

Return _cCOnta
