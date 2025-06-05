#Include "Protheus.Ch"
#include 'totvs.ch'
#include "topconn.ch"
#include "tbiconn.ch"

static lEurofins := !("YMLLLM" $ GetEnvServer())


/*/{Protheus.doc} FSWIP002
description integração expenseON
@type function
@version
@author Sergio
@since 25/07/2022
@return variant, return_description
/*/
User Function FSWIP002(cFilTit,cIdRef,cChvSE2,lMsg)

	Local oIntExp := nil
	Local cOk     := ""

	DbSelectArea("ZZH")
	DbSetOrder(1)
	If ZZH->(dbSeek(FWxFilial("ZZH")+cFilTit))

		oIntExp := ExpenseOn():New()
		cOk := oIntExp:PostChangPG(cIdRef,cChvSE2,1)

		// SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)


	EndIf

	FreeObj(oIntExp)

	If lMsg
		If !Empty(cOK)
			Aviso("Integracao ExpenseON",cOk,{"Ok"},2,"Erro na Atualizacao do Status")
		Else
			Aviso("Integracao ExpenseON","Integração da Atualização de Status com Sucesso",{"Ok"},1,"Atualizacao do Status")
		EndIf
	EndIf

Return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
user function SCH_FSW003()

	// Set(_SET_DATEFORMAT, 'dd/mm/yyyy')
	cEmp := "01"
	cFil := iif(lEurofins, "0100", "5000")

	ConOut(OEMToANSI(cValToChar(FWTimeStamp(2)) + " * * * | JOBEXPENSE FIN ["+cEmp+cFil+"] ------> Inicio... "))

	RpcSetType ( 3 )
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "FIN"

	u_FSWSC003()

	RESET ENVIRONMENT

	ConOut(OEMToANSI(cValToChar(FWTimeStamp(2)) + " * * * | JOBEXPENSE FIN ["+cEmp+cFil+"] ------> Fim... "))



return
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSWSC003
Integração contingencia relatório de despesa - ExpenseOn
@type function JOB
@version 12.1.33
@author ADM_TLA8
@since 03/03/2023
/*/
User Function FSWSC003()
	local nX           := 0  as numerics
	Local oIntExp      := nil
	Local cOk          := ""
	local aReport      := {} as array
	local cPrefSE2     := "DEP"
	local cTipoSE2     := "RDV"

	cCadastro := "Integração Report Pay"
	cPlan := cCadastro
	aCabLog := {}

	aadd(aCabLog, {"Empresa "          , "@C"               , 20})
	aadd(aCabLog, {"Filial "           , "@C"               , 20})
	aadd(aCabLog, {"reference "        , "@C"               , 20}) // 01 - id reference	string	Referência da despesa
	aadd(aCabLog, {"name "             , "@C"               , 20}) // 02 - nome reference	string	Referência da despesa
	aadd(aCabLog, {"totalReimbursable ", "@E 999,999,999.99", 20}) // 05 - total do reembolso
	aadd(aCabLog, {"startDate "        , ""                 , 20}) // 03 - emissao
	aadd(aCabLog, {"name "             , "@C"               , 20}) //07 - creator	User	Usuário criador da despesa
	aadd(aCabLog, {"reportStatusName " , ""                 , 20}) // 10 - msg de status
	aadd(aCabLog, {"msgstatus "        , "@C"               , 200}) //11 - msg de critica atualização status
	aadd(aCabLog, {"compstatus "       , "@C"               , 200}) //12 - msg de critica atualização compensação
    aadd(aCabLog, {"status "           , ""                 , 10}) //12 - msg de critica atualização compensação

	dbSelectArea("ZZH")
	DbSetOrder(1)
	ZZH->(dbGoTop())
	while ZZH->(!eof()) .and. !Empty(ZZH->ZZH_URL)
		aAreaZZH := ZZH->(FwGetArea())
		cFilProc := ZZH->ZZH_FILPRO
		aRetJson := {}
		oIntExp  := ExpenseOn():New()
		cOk      := oIntExp:GetReportPayStatus(7,monthsub(dDataBase,3),dDataBase)

		If Empty(cOK)
			oStrJson := oIntExp:GetRetornoApi()

			If oStrJson['success']
				If valType(oStrJson['data']) == 'J'
					If valType(oStrJson['data']['reports']) == "A"
						aRetJson := oStrJson['data']['reports']
						For nX := 1 to len(aRetJson)

							aAdd(aReport,{cFilProc,;
								FwFilialName( ,cFilProc, 1 ),;
								aRetJson[nX]['reference'],;
								aRetJson[nX]['name'],;
								aRetJson[nX]['totalReimbursableExpense'],;
								aRetJson[nX]['startDate'],;
								aRetJson[nX]['creator']['name'],;
								aRetJson[nX]['reportStatusName'],;
								"",;
								"",;
								.T.})

						Next nX
					EndIf
				EndIf
			EndIf
		Else

			cMsgRet 	:= oIntExp:GetErro()
			cStCode 	:= oIntExp:GetStatusCode()
			aRetErro    := Array(11)
			aRetErro[1] := cFilProc
			aRetErro[2] := FwFilialName( ,cFilProc, 1 )
			aRetErro[3] := ""
			aRetErro[4] := ""
			aRetErro[5] := ""
			aRetErro[6] := ""
			aRetErro[7] := ""
			aRetErro[8] := ""
			aRetErro[9] := cMsgRet
			aRetErro[10] := cStCode
			aRetErro[11] := .F.

			AAdd(aReport, aRetErro)

			// Aviso("Integracao ExpenseON",cOk,{"Ok"},2,"Erro na Atualizacao do Status")
		EndIf
		FwRestArea(aAreaZZH)
		ZZH->(dbSkip())
	EndDo

	FreeObj(oIntExp)

	If !Empty(aReport)
		For nX := 1 to len(aReport)
			If aReport[nX][11]
				dbSelectArea("ZZH")
				dbSetOrder(1)
				If ZZH->(dbSeek(FWxFilial("ZZH")+aReport[nX][1]))

					BeginSql Alias "SE2_R"
                    SELECT SE2.R_E_C_N_O_ AS REC_SE2 FROM %Table:SE2% SE2
                    WHERE SE2.E2_FILIAL = %Exp:aReport[nX][1]%
                    AND E2_PREFIXO = %Exp:cPrefSE2%
                    AND E2_TIPO = %Exp:cTipoSE2%
                    AND E2_SALDO = 0
                    AND E2_XIDEXP = %Exp:aReport[nX][3]%
                    AND SE2.%NotDel%
					EndSql

					While SE2_R->(!Eof())
						dbSelectArea("SE2")
						SE2->(dbGoTo(SE2_R->REC_SE2))

						oIntExp := ExpenseOn():New()
						cOk     := oIntExp:PostChangPG(AllTrim(SE2->E2_XIDEXP),;
							SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO),1)

						If !Empty(cOK)
							cMsgRet         := oIntExp:GetErro()
							cStCode         := oIntExp:GetStatusCode()
							aReport[nX][9]  := cMsgRet
							aReport[nX][10] := cStCode
							aReport[nX][11] := .F.
						EndIf

						SE2_R->(dbSkip())
					EndDo
					SE2_R->(dbCloseArea())
				EndIf
			EndIf
		Next nX
	EndIf

	aRetErro := {}
	For nX := 1 to len(aReport)
		If !aReport[nX][11]

			AAdd(aRetErro, aReport[nX])
		EndIf
	Next nX

	If len(aRetErro) > 0
		GeraLog(cPlan,aRetErro,aCabLog,.T.)
	EndIf


Return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function	GeraLog(cPlan,aLog,aCabecLog,lJob)

	Local cArqPlan 		:= "integracao_expenseon_Report_Pay.xls"
	Local cArquivo 		:= "\JobExpenseOn\"+cArqPlan
	Local cHtml    		:= ""
	Local cWorkSheet 	:= cPlan
	Local cTable 		:= "Executado em  "+dtoc(date())+" as "+time()
	Local nY            := 0
	Local oFwMsEx		:= nil
	Local cEmailResp    := SuperGetMV("CL_MAIEXPEN",.F.,"")

	makedir("\JobExpenseOn\")

	cHtml := "<HTML>"
	cHtml += "<Br><h3>"+cWorkSheet+"</h3><Br>"
	cHtml += "</HTML>"

	If File(cArquivo)
		fErase(cArquivo)
	Endif

	oFwMsEx := FWMsExcel():New()
	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )

	For nY := 1 to Len(aCabecLog)
		oFwMsEx:AddColumn( cWorkSheet, cTable , aCabecLog[ny][1], 1,1)
	Next nY

	For nY := 1 to Len(aLog)
		oFwMsEx:AddRow(cWorkSheet, cTable, aLog[ny])
	Next nY

	oFwMsEx:Activate()
	oFwMsEx:GetXMLFile(cArquivo)

	If !Empty(cEmailResp)
		fEnvEmail("Integração ExpenseON","",cEmailResp,cHtml,iif(lJob,.f.,.t.),cArquivo,"",cArqPlan)
	EndIf

Return()
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function fEnvEmail(cAssunto,cRemetente,cDestinatario,cMensagem,lMensagem,cArquivo,cCopia,cArqPlan)

	Local cMailServer   := GetMV("MV_RELSERV")       					// substituir por servidor de e-mail
	Local cMailConta    := GetMV("MV_EMCONTA")       					// substituir por conta de e-mail
	Local cMailSenha    := GetMV("MV_EMSENHA")        					// substituir pela senha da conta
	Local oServer
	Local oMessage
	Local nPortaSMTP    := 25
	Local xRet          := 0
	Local cMsg          := ""

	Default cArquivo := ""
	Default cCopia   := ""

	//Cria a conexão com o server STMP ( Envio de e-mail )
	oServer := TMailManager():New()
	If nPortaSMTP == 465
		oServer:SetUseSSL( .T. )
	ElseIf nPortaSMTP == 587
		oServer:SetUseTLS( .T. )
	EndIf
	oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPortaSMTP )

	//seta um tempo de time out com servidor de 1min
	If oServer:SetSmtpTimeOut( 60 ) != 0
		If lMensagem
			MsgAlert("Falha ao setar o time out","Atencao")
		Else
			Conout( "Falha ao setar o time out" )
		Endif
		Return .F.
	EndIf

	//realiza a conexão SMTP
	If oServer:SmtpConnect() != 0
		If lMensagem
			MsgAlert("Falha ao conectar no servidor SMTP","Atencao")
		Else
			Conout( "Falha ao conectar no servidor SMTP" )
		Endif
		Return .F.
	EndIf

	// authenticate on the SMTP server (if needed)
	If GetMv("MV_RELAUTH")
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Falha na authenticate no SMTP server: " + oServer:GetErrorString( xRet )
			If lMensagem
				MsgAlert(cMsg,"Atencao")
			Else
				Conout( cMsg )
			Endif
			oServer:SMTPDisconnect()
			return .f.
		endif
	EndIf

	//Apos a conexão, cria o objeto da mensagem
	oMessage := TMailMessage():New()

	//Limpa o objeto
	oMessage:Clear()

	//Popula com os dados de envio
	oMessage:cFrom              := cMailConta //cRemetente
	oMessage:cTo                := cDestinatario
	oMessage:cCc                := cCopia
	oMessage:cBcc               := ""
	oMessage:cSubject           := cAssunto
	oMessage:cBody              := cMensagem

	//Adiciona um attach
	If !Empty(cArquivo)
		If oMessage:AttachFile( cArquivo ) < 0
			If lMensagem
				MsgAlert("Erro ao atachar o arquivo","Atencao")
			Else
				Conout( "Erro ao atachar o arquivo" )
			Endif
			Return .F.
		Else
			//adiciona uma tag informando que é um attach e o nome do arq
			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cArqPlan+'')
		EndIf
	EndIf

	//Envia o e-mail
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		cMsg := "Erro ao enviar o e-mail: " + oServer:GetErrorString( xRet )
		If lMensagem
			MsgAlert(cMsg,"Atencao")
		Else
			Conout( cMsg )
		Endif
		Return .F.
	endif

	//Desconecta do servidor
	If oServer:SmtpDisconnect() != 0
		If lMensagem
			MsgAlert("Erro ao disconectar do servidor SMTP","Atencao")
		Else
			Conout( "Erro ao disconectar do servidor SMTP" )
		Endif
		Return .F.
	EndIf

Return .T.
