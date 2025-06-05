#include "rwmake.ch"

/*/{Protheus.doc} F040ALTR
Preenche o campo E1_TITPAI na validação do imposto PCC na baixa do título a receber (FINA040)
@author Marcos Candido
@since 03/01/2018
/*/
User Function F040ALTR

	Local aAreaAtual  := GetArea()
	Local cInfoTitPai := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
	Local aTipos      := {"PI-","CF-","CS-","IR-"}
	Local cChave      := "" , nT := 0
	Local cTp         := SE1->E1_TIPO

	dbSelectArea("SE1")
	dbSetOrder(1)

	For nT:=1 to Len(aTipos)
		cChave := StrTran(cInfoTitPai,cTp,aTipos[nT])
		If dbSeek(xFilial("SE1")+cChave) .and. Empty(SE1->E1_TITPAI)
			RecLock("SE1",.F.)
			  E1_TITPAI := cInfoTitPai
			MsUnlock()
		Endif
	Next

	RestArea(aAreaAtual)

Return