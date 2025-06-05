#INCLUDE "PROTHEUS.CH"
#include 'topconn.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} MT140SAI
EM QUE PONTO : Ponto de entrada disparado antes do retorno da rotina ao browse.
Dessa forma, a tabela SF1 pode ser reposicionada antes do retorno ao browse.

@type		Function
@author		Julio Lisboa
@since		04/08/2020
/*/
//-----------------------------------------------------------------
User Function MT140SAI()

	Local aAreaSF1      := SF1->(GetArea())
	Local aAreaSD1      := SD1->(GetArea())
	Local cSeqEnt       := ""
	Local oLibCoupa     := LibCoupa():New()

	oLibCoupa:seqEntradaNF()

//PARAMIXB[1] = Numero da operação - ( 2-Visualização, 3-Inclusão, 4-Alteração, 5-Exclusão )
//PARAMIXB[2] = Número da nota
//PARAMIXB[3] = Série da nota
//PARAMIXB[4] = Fornecedor
//PARAMIXB[5] = Loja
//PARAMIXB[6] = Tipo
//PARAMIXB[7] = Opção de Confirmação (1 = Confirma pré-nota; 0 = Não Confirma pré-nota)

	If ParamIxb[1] == 3 .or. ParamIxb[1] == 4
		SF1->( dbSetOrder( 1 ) )
		SF1->( MsSeek( xFilial( 'SF1' ) + ParamIxb[2] + ParamIxb[3] + ParamIxb[4] + ParamIxb[5] ) )
		GrvCCRF()
	EndIf

	restArea(aAreaSD1)
	restArea(aAreaSF1)

Return

// -------------------------------------------------------------------------------------------------------------------------------------------

static function GrvCCRF()

	local lBlqCCond := .F.                as logical
	local lBlqRFis  := .F.                as logical
	local aAreaSF1  := SF1->(FwGetArea()) as array
	local aAreaSD1  := SD1->(FwGetArea()) as array
	local cGrpCCond := "CD" + FwCodFil()  as character
	local cGrpRFis  := "RF" + FwCodFil()  as character
	local cGrpCF    := "CR" + FwCodFil()  as character
	local nMoedaCor := 1                  as numeric
	local lCConduta := GetMv("CL_CCONDUT",.F.,.F.)

	If lCConduta

		If !alltrim(SF1->F1_ESPECIE) $ GetMv("CL_ESPNVCC",.F.,"")

			dbSelectArea("SD1")
			dbSetOrder(1)
			If dbSeek(FWxFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))
				while SD1->(!eof()) .and. ;
						SD1->D1_FILIAL == FwXFilial("SD1") .and. SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
					If !Empty(SD1->D1_PEDIDO)
						dbSelectArea("SC7")
						SC7->(dbSetOrder(1))
						If dbSeek(FWxFilial("SC7") + SD1->D1_PEDIDO)
							If SF1->F1_EMISSAO < SC7->C7_EMISSAO
								lBlqCCond  := .T.
							EndIf
							If !Empty(SC7->C7_MOEDA)
								nMoedaCor := SC7->C7_MOEDA
							EndIf
						EndIf
					EndIf
					SD1->(dbSkip())
				EndDo
			EndIf
		EndIf


		lVldPro := .T.
		dbSelectArea("SD1")
		dbSetOrder(1)
		If dbSeek(FWxFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))
			while SD1->(!eof()) .and. ;
					SD1->D1_FILIAL == FwXFilial("SD1") .and. SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
				// If alltrim(SD1->D1_COD) $ GetMv("CL_PRDFRF",.F.,"")

				dbSelectArea("SZK")
				SZK->(dbSetOrder(1))
				If dbSeek(FWxFilial("SZK") + SD1->D1_COD)
					lVldPro := .F.
				EndIf
				SD1->(dbSkip())
			EndDo
		EndIf

		aBlqRFis := U_RetTRec(SF1->F1_ESPECIE)
		If len(aBlqRFis) > 0 .and. lVldPro

			If alltrim(SF1->F1_ESPECIE) == alltrim(aBlqRFis[1])
				If aBlqRFis[2] == 'P'
					If Substr(dTos(SF1->F1_EMISSAO),1,6) != Substr(dTos(Date()),1,6)
						lBlqRFis := .T.
					EndIf
				Else
					nDias := 0
					nDias := DateDiffDay(SF1->F1_EMISSAO, Date())
					If nDias > aBlqRFis[3]
						lBlqRFis := .T.
					EndIf
				EndIf
			EndIf
		EndIf

		If lBlqCCond .or. lBlqRFis

			cTpBloq := ""
			cMotCC  := ""
			cMotRF  := ""
			If lBlqCCond .and. lBlqRFis
				cGrupo  := cGrpCF
				cMotivo := "Codigo Conduta e Recebimento Fiscal"
				cTpBloq := "A"
				// cMotCC  := U_TextInput("Informe o motivo do bloqueio Cod. Conduta")
				cMotRF  := U_TextInput("Informe o motivo do bloqueio Rec. Fiscal")
			ElseIf lBlqCCond .and. !lBlqRFis
				cGrupo  := cGrpCCond
				cMotivo := "Codigo Conduta"
				cTpBloq := "C"
				// cMotCC  := U_TextInput("Informe o motivo do bloqueio Cod. Conduta")
			else
				cGrupo  := cGrpRFis
				cMotivo := "Recebimento Fiscal"
				cTpBloq := "R"
				cMotRF  := U_TextInput("Informe o motivo do bloqueio Rec. Fiscal")
			EndIf

			nValorTot := SF1->F1_VALBRUT

			dbSelectArea("SCR")
			dbSetOrder(1)
			If dbSeek(FWxFilial("SCR") + "NF" +  SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
				while SCR->(!eof()) .and. alltrim(SCR->CR_NUM) == alltrim(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

					RecLock("SCR",.F.)
					SCR->(dbDelete())
					SCR->(MsUnlock())

					SCR->(dbSkip())
				EndDo
			EndIf


			MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",nValorTot,,,cGrupo,,;
				Iif(SF1->F1_MOEDA == 0, nMoedaCor,SF1->F1_MOEDA ),SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,1)

			reclock("SF1",.F.)
			SF1->F1_STATUS  := "B"
			SF1->F1_APROV   := cGrupo
			SF1->F1_XSTA_CC := ''
			SF1->F1_XSTA_RF := ''
			SF1->F1_XTPBLOQ := cTpBloq
			SF1->F1_XDTLIB  := cToD("")
			SF1->F1_XDTBLOQ := Date()

			If len(aBlqRFis) > 0
				SF1->F1_XREGBLQ := aBlqRFis[1]+ '-' +aBlqRFis[2]+ '-' +cValToChar(aBlqRFis[3])
			Else
				SF1->F1_XREGBLQ := ""
			EndIf

			SF1->F1_XMOTCC  := cMotCC
			SF1->F1_XMOTRF  := cMotRF

			SF1->(MsUnlock())

			If lBlqCCond .and. lBlqRFis
				FwAlertInfo("Nota fiscal bloqueada devido classificação do Código de Conduta e Recebimento Fiscal.<br><b>Emissão da nota fiscal anterior a emissão do pedido de " + ;
					"compra e periodo emissão diferente do periodo de classificação.</b><br> Favor aguardar a liberação do documento pela diretoria.","Bloqueio Nota Fiscal.")
			ElseIf lBlqCCond .and. !lBlqRFis
				FwAlertInfo("Nota fiscal bloqueada devido classificação do código de conduta.<br><b>Emissão da nota fiscal anterior a emissão do pedido de " + ;
					"compra.</b><br> Favor aguardar a liberação do documento pela diretoria.","Bloqueio Nota Fiscal.")
			Else
				FwAlertInfo("Nota fiscal bloqueada devido Recebiento Fiscal.<br><b>Periodo de emissão da nota fiscal diferente do periodo de classificação da nota fiscal " + ;
					".</b><br> Favor aguardar a liberação do documento pela diretoria.","Bloqueio Nota Fiscal.")
			EndIf

		EndIf

	EndIf

	FWRestArea(aAreaSD1)
	FWRestArea(aAreaSF1)


return()
