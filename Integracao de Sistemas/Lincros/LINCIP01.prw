#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"
#include    "tbiconn.ch"
#include    "Totvs.ch"

/*/{Protheus.doc} LINCIP001
Integracao Protheus com Lincros
@type function
@author Sergio IP
@since 09/2022
/*/
User Function LINCIP01()

	Local lRet      := .T.
	Local lJob		:= .T.

	if IsInCallStack("U_LinMONITOR")
		lJob := .F.
	else
		lJob := .T.
		//RpcSetType( 3 )
		//RpcSetEnv("01","0100")
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL '0100'
	endif

	geraLog(Replicate("*",20))
	geraLog("Iniciando integração Protheus x Lincros")
	geraLog(Replicate("*",20))

	if LockByName("LINCIP01", .F., .F.)
		If !lJob
			geraLog("Integração manual")
			If !getnewpar("ZZ_LINCR05",.F.)
				MsgAlert("Integração com o Lincros Desligada!"+CRLF+"Revise o Parâmetro ZZ_LINCR05",FunDesc())
				geraLog("Integração desligada pelo parâmetro ZZ_LINR05")
			else
				if Day(ddatabase) >= getnewpar("ZZ_LINCR06",.F.)
					MsgAlert("Integração com o Lincros Desligada!"+CRLF+"Revise o Parâmetro ZZ_LINCR06"+;
					"Hoje é dia "+cValtoChar(Day(ddatabase))+" e no parâmetro está configurado que a partir do dia "+cValToChar(getnewpar("ZZ_LINCR06",.F.))+;
					" a integração fica desligada (automaticamente) por causa do fechamento de estoque.",FunDesc())
					geraLog("Integração desligada pelo parâmetro ZZ_LINR06")
				else
					Processa({|| lRet := IntegraCTE(lJob) },"Integrando CTEs","...")
					if lRet 
						Processa({|| lRet := IntegraFatura(lJob) },"Integrando Faturas","...")
					endif
					/*If !lRet
						MsgInfo("Houve erros na Integração ou não há dados para integrar, verifique o monitor","Integrando CTE/Fatura")
					EndIf*/
				endif
			endif
		Else
			geraLog("Integração via Job")
			//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0100"
			If getnewpar("ZZ_LINCR05",.F.)
				if Day(ddatabase) >= getnewpar("ZZ_LINCR06",.F.)
					geraLog("Integração desligada pelo parâmetro ZZ_LINR06")
				else
					IntegraCTE(lJob)
					IntegraFatura(lJob)
				endif
			else
				geraLog("Integração desligada pelo parâmetro ZZ_LINR05")
			endif
		EndIf
	else
		if !lJob
			MsgAlert("A integração Protheus x Lincros já está sendo executada, não é possível executar manualmente nesse momento, aguarde sua finalização!",FunDesc())
		endif
	endif
	//if lJob
	//	Reset ENVIRONMENT
	//endif
	UnLockByName("LINCIP01", .F., .F.)

Return()

Static Function IntegraCTE(lJob)

	Local oIntLin 	:= nil
	Local aRet    	:= {}
	Local aAreaSM0	:= SM0->(GetArea())
	Local cFilBkp   := cFilAnt
	Local aCTEs     := {}
	Local nX        := 0
	Local cLogErro  := ""
	Local lOk       := .t.

	oIntLin  := Lincros():New()

	If oIntLin:GetCtes()
		geraLog("Buscando CTE's para integração...")
		If oIntLin:CtesIds()
			aCTEs := oIntLin:GetArrayCtes()
			geraLog("Quantidade de CTEs: "+cValtochar(Len(aCtes)))
			ProcRegua(Len(aCtes))
			For nX := 1 to Len(aCTEs)
				geraLog("Código da Integração: "+cValTochar(aCtes[nX]))
                geraLog("Integrando registro " + cValToChar(nX) + " de " + cValToChar(Len(aCtes)) + "...")
				IncProc("Integrando registro " + cValToChar(nX) + " de " + cValToChar(Len(aCtes)) + "...")
				FreeObj(oIntLin)
				oIntLin := Lincros():New()
				If oIntLin:PostDadosCtes(aCTEs[nX])
					If oIntLin:GrvCtes(aCTEs[nX])
						aRet := oIntLin:GetRetornoArrayCTE()
					Else	
						cMsgRet  := oIntLin:GetErro()
						cLogErro := OEMToANSI(FWTimeStamp(2)+ "  ERRO NA GERAÇÃO DA CTE Ref:  "+cValToChar(aCTEs[nX])+" ERRO : "+cMsgRet+" " )
                        geraLog(cLogErro)
						lOk := .f.
					EndIf
				Else
					cMsgRet  := oIntLin:GetErro()
					cStCode  := oIntLin:GetStatusCode()
					cLogErro := OEMToANSI(FWTimeStamp(2)+ "  ERRO NA API /cte/recuperarDados Ref: a CTE "+cValToChar(aCTEs[nX])+" ERRO : "+cMsgRet+" "+cStCode+"" )
                    geraLog(cLogErro)
					lOk := .f.
				EndIf
			Next nX
			geraLog("Finalizado Integração de CTE's")
		Else
			cMsgRet  := oIntLin:GetErro()
			cLogErro := OEMToANSI(FWTimeStamp(2)+ "  AVISO : "+cMsgRet+" ")
			geraLog(cLogErro)
		EndIf
	Else
		cMsgRet  := oIntLin:GetErro()
		cStCode  := oIntLin:GetStatusCode()
		cLogErro := OEMToANSI(FWTimeStamp(2)+ "  ERRO NA API /cte/buscarRegistrosParaIntegracao : "+cMsgRet+" "+cStCode+"" )
        geraLog(cLogErro)
		lOk := .f.
	EndIf

	RestArea(aAreaSM0)
	cFilAnt := cFilBkp

	FreeObj(oIntLin)

Return(lOk)

Static Function IntegraFatura(lJob)

	Local oIntLin 	:= nil
	Local aRet    	:= {}
	Local aAreaSM0	:= SM0->(GetArea())
	Local cFilBkp   := cFilAnt
	Local aFaturas  := {}
	Local nX        := 0
	Local cLogErro  := ""
	Local lOk       := .T.

	oIntLin  := Lincros():New()

	If oIntLin:GetFaturas()
		geraLog("Buscando Faturas para integração...")
		If oIntLin:FaturasIds()
			geraLog("Quantidade de faturas"+cValtochar(Len(aFaturas)))
			ProcRegua(Len(aFaturas))
			aFaturas := oIntLin:GetArrayFaturas()
			For nX := 1 to Len(aFaturas)
				geraLog("Código da Integração: "+cValTochar(aFaturas[nX]))
                geraLog("Integrando registro " + cValToChar(nX) + " de " + cValToChar(Len(aFaturas)) + "...")
				IncProc("Integrando registro " + cValToChar(nX) + " de " + cValToChar(Len(aFaturas)) + "...")
				FreeObj(oIntLin)
				oIntLin := Lincros():New()
				If oIntLin:PostDadosFaturas(aFaturas[nX])
					If oIntLin:GrvFatura(aFaturas[nX])
						aRet := oIntLin:GetRetornoArrayFatura()
						//AAdd(aRetFil, aRet)
					Else	
						cMsgRet  := oIntLin:GetErro()
						cLogErro := OEMToANSI(FWTimeStamp(2)+ "  ERRO NA GERAÇÃO DA FATURA Ref:  "+cValToChar(aFaturas[nX])+" ERRO : "+cMsgRet+" " )
						geraLog(cLogErro)
						lOk := .f.
					EndIf
				Else
					cMsgRet  := oIntLin:GetErro()
					cStCode  := oIntLin:GetStatusCode()
					cLogErro := OEMToANSI(FWTimeStamp(2)+ "  ERRO NA API /cte/recuperarDados Ref: a FATURA "+cValToChar(aFaturas[nX])+" ERRO : "+cMsgRet+" "+cStCode+"" )
					geraLog(cLogErro)
					lOk := .f.
				EndIf
			Next nX
		Else
			cMsgRet  := oIntLin:GetErro()
			cLogErro := OEMToANSI(FWTimeStamp(2)+ "  AVISO : "+cMsgRet+" ")
			geraLog(cLogErro)
			lOk := .f.
		EndIf
	Else
		cMsgRet  := oIntLin:GetErro()
		cStCode  := oIntLin:GetStatusCode()
		cLogErro := OEMToANSI(FWTimeStamp(2)+ "  ERRO NA API /fatura/buscarRegistrosParaIntegracao : "+cMsgRet+" "+cStCode+"" )
		//u_EUGrvLog("ERRO_INTEGRACTE",cLogErro)
		geraLog(cLogErro)
		lOk := .f.
	EndIf

	RestArea(aAreaSM0)
	cFilAnt := cFilBkp

	FreeObj(oIntLin)

Return(lOk)

//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

	LogMsg('tlogmsg', 22, 5, 1, '', '', "[" + DTOC(Date()) + " " + Time() + "] LINCIP01 - " + cMensagem )

Return
