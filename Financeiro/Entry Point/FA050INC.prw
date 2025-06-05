#Include "RWMAKE.CH"
/*/{Protheus.doc} FA050INC
Valida se o centro de custo foi informado na inclusao manual de títulos a pagar quando usar natureza de despesa.
@author Vitor Luis Fattori
@since 03/01/2018
/*/
User Function FA050INC
	Local aArea := GetArea()
	Local _lRet 	  := .T.
	Local aSED        := SED->(GetArea())
	Local aCT1        := CT1->(GetArea())
	Local _cBuscaCta  := ""
	Local _lObrig	  := .F.
	Local _lAcCC	  := .F.
	Local _lAchouCT1  := .F.
	Local _cCC		  := ""
	Local _cTipo	  := M->E2_TIPO
	Local _cOrigem	  := M->E2_ORIGEM
	Local _cRateio	  := M->E2_RATEIO
	local cCSSCampo    := "TGet { color: #000000; selection-background-color: #369CB5;    background-color: #fff2f0;     padding-left: 3px;     padding-right: 3px;     border: 1px solid #D3362C;     border-radius: 3px; }tLabel{color: #000000;}"
	local nAtual       := 0
	//Variáveis de controle dos objetos da tela
	Private oPai       := GetWndDefault()
	Private aControles := oPai:aControls
	Private nAtuPvt    := 0

	//incluida essa condição para que quando a rotina FINA050 seja executada via execauto essas regras não sejam executadas,ja que as validações
	//já são feitas antes.. e para poder executar as integrações do sistema ExpenseON
	// 25/08/22 - Sergio IP
	If IsBlind()
		Return(_lRet)
	EndIf
	//Fim

	If Empty(M->E2_ZZNUINV).AND.M->E2_TIPO=='INV'
		Alert("Para tipo 'INV' é obrigatório informar "+RetField("SX3",2,"E2_ZZNUINV","Alltrim(X3_TITULO)")+"!")
		Return .f.
	Endif
	If Posicione("SED",1,xFilial("SED") + M->E2_NATUREZ,"ED_ZZCTB=='S'")
		//Obtem indicacao da conta a ser pesquisada.
		_cBuscaCta := SED->ED_CONTA
		If Posicione("CT1",1,xFilial("CT1")+_cBuscaCta,"!Eof()")
			_lAchouCT1 := .T.
			If CT1->CT1_CCOBRG == "1"
				_lObrig = .T.
			EndIf
			If CT1->CT1_ACCUST == "1"
				_lAcCC = .T.
			EndIf
		EndIf
		If _lAchouCT1
			_cCC := M->E2_CCUSTO
			If _lObrig .And. Empty(_cCC) .AND. !_cTipo $ MVABATIM .AND. !_cTipo $ MVPROVIS .AND. !_cTipo $ MVPAGANT  .AND. !alltrim(_cOrigem) $ "FINA290" .AND. !_cRateio == "S"
				_lRet := .F.
				Alert("Obrigatório informar o centro de custos!!!")
			ElseIf .Not. _lAcCC .And. .Not. Empty(_cCC)
				_lRet := .F.
				Alert("Para esta natureza nao devera ser informado Centro de Resultado!!!")
			EndIf
		EndIf
	EndIf

	IF alltrim(M->E2_TIPO) == 'TX' .and. alltrim(M->E2_FORNECE) == 'UNIAO' .and. Empty(M->E2_CODRET)

		_lRet := .F.
		Help(, , "Help", , "Codigo retencao nao preenchido!", 1, 0, , , , , , {"Verifique o preenchimento do campo codigo de retencao."})

		//Percorrendo os objetos criados da tela
		For nAtual := 1 To Len(aControles)
			nAtuPvt := nAtual

			//Se tiver variável e descrição
			If Type("aControles[nAtuPvt]:cReadVar") != "U" .And. Type("aControles[nAtuPvt]:cToolTip") != "U"

				//Somente se tiver conteúdo de TGet
				If ! Empty(aControles[nAtuPvt]:cReadVar) .And. ! Empty(aControles[nAtuPvt]:cToolTip) .And. 'M->' $ Upper(aControles[nAtuPvt]:cReadVar)

					//Se for o campo de email e ele estiver vazio -OU- Se for o campo de home page e ele estiver vazio
					If (Alltrim(aControles[nAtuPvt]:cReadVar) == "M->E2_CODRET" .And. Empty(M->E2_CODRET))
						aControles[nAtuPvt]:SetCSS(cCSSCampo)
					EndIf

				EndIf
			EndIf
		Next


	EndIf



	CT1->(RestArea(aCT1))
	SED->(RestArea(aSED))
	RestArea(aArea)
Return(_lRet)
