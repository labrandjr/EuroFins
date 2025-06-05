#include "Protheus.ch"
/*/{Protheus.doc} F240fil
Filtra os titulos do contas a pagar conforme tipo de pagamento do bordero.                    |
@author Marciane Gennari
@since 03/01/2018
/*/
User Function F240fil()
	local cFiltro := "" as character


	cFiltro := ""
	If cModPgto == "30"

		If cPort240 == "341"
			cFiltro := " SUBS(E2_CODBAR,1,3)=="+"'"+cPort240+"'"
		Else
			cFiltro := " !EMPTY(E2_CODBAR) "
		EndIf

		cFiltro += " .AND. SUBS(E2_CODBAR,1,1)<>'8' "
		cFiltro += " .AND. E2_FORMPAG == '" + cModPgto + "' "

	ElseIf cModPgto == "31"

		cFiltro := " !EMPTY(E2_CODBAR)"

		If cPort240 == "341"
			cFiltro += " .AND. SUBS(E2_CODBAR,1,3)<>"+"'"+cPort240+"'"
		EndIf

		cFiltro += " .AND. SUBS(E2_CODBAR,1,1)<>'8' "
		cFiltro += " .AND. E2_FORMPAG == '" + cModPgto + "' "

	ElseIf cModPgto == "01"

		cFiltro := " Empty(E2_CODBAR)  .and. "
		cFiltro += "  GetAdvFval('SA2','A2_BANCO',xFilial('SA2')+E2_FORNECE+E2_LOJA,1)  =="+" '"+cPort240+ "'"

	ElseIf cModPgto == "03"

		cFiltro := " Empty(E2_CODBAR) .and. "// .and. "
		cFiltro += " (  !Empty(GetAdvFval('SA2','A2_BANCO',xFilial('SA2')+E2_FORNECE+E2_LOJA,1))  "
		cFiltro += "  .and. GetAdvFval('SA2','A2_BANCO'  ,xFilial('SA2')+E2_FORNECE+E2_LOJA,1)  <>"+"'"+cPort240+"'  )"

	ElseIf cModPgto == "41" .or. cModPgto == "43"

		cFiltro := " Empty(E2_CODBAR) "
		//   cFiltro += " (  !Empty(GetAdvFval('SA2','A2_BANCO',xFilial('SA2')+E2_FORNECE+E2_LOJA,1))  "
		cFiltro += "  .and. !Empty(GetAdvFval('SA2','A2_BANCO',xFilial('SA2')+E2_FORNECE+E2_LOJA,1)  <>"+"'"+cPort240+"'  )"
        cFiltro += "  .and. !Empty(E2_FORBCO) .and. !Empty(E2_FORAGE) .and. !Empty(E2_FORCTA)

    ElseIf cModPgto == "13"  //--- Concessionarias

		cFiltro := " !EMPTY(E2_CODBAR) .AND. SUBS(E2_CODBAR,1,1)=='8' .AND. E2_TIPO <> 'ISS'"

	ElseIf cModPgto == "16"  //--- Darf Normal - Selecionar com codigo de retencao e tipo TX

		//cFiltro := " ( !Empty(E2_CODRET) .OR. !Empty(E2_ZZCDREC) ) .AND. E2_TIPO == 'TX '"
		// cFiltro := " ( (!Empty(E2_CODRET) .OR. !Empty(E2_ZZCDREC) ) .AND. E2_TIPO == 'TX') .OR. (E2_TIPO $ 'COF|PIS' .AND. E2_ORIGEM == 'FISA001')"

        //alterado por Leandro Cesar - 28/11/2022
        cFiltro := " ( (!Empty(E2_CODRET) .or. !Empty(E2_ZZCDREC) ) .and. alltrim(E2_TIPO) == 'TX' .and. alltrim(E2_PREFIXO) $ 'PIS|COF|CID|IRF') .or. (!Empty(E2_ZZCDREC) .and. E2_TIPO $ 'COF|PIS' .and. E2_ORIGEM == 'FISA001')"


	ElseIf cModPgto == "17"  //--- GPS

		cFiltro := " E2_TIPO == 'INS'"

	ElseIf cModPgto == "19"  //--- ISS

		//cFiltro := " E2_TIPO == 'ISS' .OR. E2_TIPO == 'TX ' .AND. E2_NATUREZ == 'ISS       ' .AND. E2_ORIGEM == 'MATA460 ' .OR. 'PREF' $ E2_NOMFOR"
		cFiltro := " E2_TIPO $ 'ISS|0206002' .OR. E2_TIPO == 'TX ' .AND. E2_NATUREZ $ 'ISS|0206002' .AND. E2_ORIGEM $ 'MATA460|MATA954' .OR. 'PREF' $ E2_NOMFOR .OR. 'MUN' $ E2_NOMFOR"

	ElseIf cModPgto == "91"  //--- TRIBUTOS COM CÓDIGO DE BARRAS

		cFiltro := " !EMPTY(E2_CODBAR)"
		cFiltro += " .AND. SUBS(E2_CODBAR,1,1) == '8' "
		cFiltro += " .AND. E2_FORMPAG == '" + cModPgto + "' "

	EndIf

Return(cFiltro)
