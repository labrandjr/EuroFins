#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"

/*/{Protheus.doc} MT094END
Ponto de entrada para gravar a data e hora da liberação da SC
@author ricardo rey
@since 24/04/2018
/*/
user function MT094END()
	Local aArea       := GetArea()
	Local aDados      := PARAMIXB // cDocto,cTipo,nOpc,cFilDoc
	Local aAreaAtual  := GetArea()
	Local dDtAprv     := CtoD(Space(8))
	Local cQ          := ""
	Local nPrazo      := 0
	Local aDadosPC    := {}
	Local cAux        := "" , cMens := ""
	Local cNomSolic   := ""
	Local cEMailSolic := ""
	Local cNumPC      := aDados[1]
	Local cNumDoc      := Alltrim(PARAMIXB[1]) // Numero do documento
	Local nEscolha    := PARAMIXB[3] // (1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear)
	Local cTipo       := PARAMIXB[2] // Tipo de documento  (PC, NF, SA, IP, AE)


	If cTipo == "SC"
		If nEscolha <> 2
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1")+cNumDoc))
			while SC1->C1_NUM == cNumDoc .and. !Eof()
				RecLock("SC1",.F.)
				C1_ZZDATA := dDataBase
				C1_ZZHORA := Time()
				MsUnlock()
				dbSkip()
			End
		Else
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1")+cNumDoc))
			while SC1->C1_NUM == cNumDoc .and. !Eof()
				RecLock("SC1",.F.)
				C1_ZZDATA := cTod("  /  /  ")
				C1_ZZHORA := "     "
				MsUnlock()
				dbSkip()
			End
		Endif
		U_ENVHTML(cTipo,cNumDoc,aDados,AllTrim(FunName()))

	ElseIf alltrim(cTipo) == "NF"
		//SECTION alteracao
		//NOTE - Alterado por Leandro Cesar - 21/10/22
		//ANCHOR - envia notificação para aprovação de documento fiscal
		If nEscolha == 1 .or. nEscolha == 3
			dbSelectArea("SF1")
			SF1->(dbSetOrder(1))
			If dbSeek(FWxFilial("SF1") + alltrim(cNumDoc))
				reclock("SF1",.F.)
				SF1->F1_XDTLIB := Date()
				SF1->(MsUnlock())
			EndIf
            //só envia o e-mail quando o documento não estiver bloqueado
			If SF1->F1_STATUS != 'B'
				U_ntAprovCC(cNumDoc)
			EndIf
		EndIf
		//!SECTION
	Endif

	RestArea(aArea)
Return
