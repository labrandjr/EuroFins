#Include 'Protheus.ch'

/*/{Protheus.doc} RetValImp
Retorna valor dos impostos do lançamento padrão 650
@type function
@version 12.1.33
@author Leandro Cesar
@since 3/17/2023
@param cLP, character, Codigo Lançameneto Padrão
@param cSeq, character, Sequência LP
@param cCampo, character, Campo
@param cTipo, character, Tipo
@return numeric, valor de retorno
/*/
User Function RetValImp(cLP,cSeq,cCampo,cTipo)
	Local aArea 	:= GetArea()
	Local nValor  	:= 0
	Local lExistSE2 := .F.


	aAreaSE2 := SE2->(GetArea())


	If SD1->D1_VALIRR > 0 .OR. SD1->D1_VALISS > 0 .OR. SD1->D1_VALINS > 0 .OR. SD1->D1_VALCOF > 0 .OR. SD1->D1_VALPIS > 0 .OR. SD1->D1_VALCSL > 0

		If cLP == "650" .And. cCampo == "CT5_VLR01"


			SE2->(DbSetOrder(6))
			lExistSE2   := SE2->(DbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))

			If 'IRR' $ cTipo
				IF lExistSE2
					If SE2->E2_IRRF > 0
						nValor +=  SD1->D1_VALIRR
					EndIf
				Else
					nValor +=  SD1->D1_VALIRR
				EndIf
			EndIF

			If 'INS' $ cTipo
				IF lExistSE2
					If SE2->E2_INSS > 0
						nValor +=  SD1->D1_VALINS
					EndIf
				Else
					nValor +=  SD1->D1_VALINS
				EndIf
			EndIF

			If 'ISS' $ cTipo
				IF lExistSE2
					If SE2->E2_ISS > 0
						nValor +=  SD1->D1_VALISS
					EndIf
				Else
					nValor +=  SD1->D1_VALISS
				EndIf
			EndIF

			If 'PIS' $ cTipo
				IF lExistSE2
					If SE2->E2_PIS > 0
						nValor +=  SD1->D1_VALPIS
					EndIf
				Else
					nValor +=  SD1->D1_VALPIS
				EndIf
			EndIF

			If 'COF' $ cTipo
				IF lExistSE2
					If SE2->E2_COFINS > 0
						nValor +=  SD1->D1_VALCOF
					EndIf
				Else
					nValor +=  SD1->D1_VALCOF
				EndIf
			EndIF

			If 'CSL' $ cTipo
				IF lExistSE2
					If SE2->E2_CSLL > 0
						nValor +=  SD1->D1_VALCSL
					EndIf
				Else
					nValor +=  SD1->D1_VALCSL
				EndIf
			EndIF

			SE2->(RestArea(aAreaSE2))

			RestArea(aArea)
		EndIf
	EndIf

Return nValor


