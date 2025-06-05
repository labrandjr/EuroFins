#include "totvs.ch"
#Include 'topconn.ch'
#include "tbiconn.ch"
#Include 'Protheus.ch'
/*/{protheus.doc}mt120fim
Ponto de entrada após a geração de um pedido de compras
@author Sergio Braz
@since 30/04/2019
/*/
User Function mt120fim
	Local aPar     := paramixb
	Local aLstBox  := {}
	Local lEnvMail := .F.
	Local z        := 1
	local lExpPoTX := GetMv("CL_EXPPOTX",.F.,"N") == "S"

	If cValtoChar(aPar[1]) $ "349" .and. aPar[3] == 1 //Se incluiu/alterou/copiou e confirmou
		U_ENVHTML("IP",aPar[2],{,,aPar[1],},"MATA120")//tipo, pedido,opcao,funname
	Endif


	If cValtoChar(aPar[1]) $ "3|4|9" .and. aPar[3] == 1

		//SECTION ENVIO E-MAIL PC
		//REVIEW Altera o status de integracao do pedio de compra
		//NOTE Alterado por Leandro Cesar - 20/02/2023

		IF alltrim(cValtoChar(aPar[1])) == "4"
			cPedido := SC7->C7_NUM
			cQuery := ""
			cQuery += "UPDATE " + RetSqlName("SC7") + " SET C7_XMODALT = '1' FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = ''
			cQuery += " AND C7_FILIAL = '" + cFilAnt + "'"
			cQuery += " AND C7_NUM = '" + cPedido + "'"
			cQuery += " AND C7_ENCER <> 'E' AND C7_QUJE = 0 AND C7_RESIDUO = ' '
			TcSqlExec(cQuery)
			//!SECTION
		EndIf

		//SECTION ENVIO DOS IMPOSTOS PARA COUPA
		//TODO Realiza a integração dos campos de impostos e despesas com o sistema COUPA
		//NOTE Alterado por Leandro Cesar - 08/07/2022
		//LINK
		If lExpPoTX
			cPedido := SC7->C7_NUM
			oCoupa  := ExpCoupa():New(cPedido)
			oCoupa:ExportFile()

			FreeObj(oCoupa)
			oCoupa := Nil
		EndIf
		//!SECTION
	EndIf


	// VERIFICA SE O PEDIDO POSSUI ITENS CHINA, B1_XORIGCH, E O FORNECEDOR DO PEDIDO É NACIONAL, A2_EST DIFERENTE DE EX
	If cValtoChar(aPar[1]) $ "3|4|9" .and. aPar[3] == 1
		cQuery:= " "
		cQuery+= " SELECT * "
		cQuery+= " FROM "+RetSqlName("SC7")+" "
		cQuery+= " INNER JOIN "+RetSqlName("SA2")+" ON "+RetSqlName("SA2")+".D_E_L_E_T_ = '' "
		cQuery+= " AND A2_COD = C7_FORNECE "
		cQuery+= " AND A2_LOJA = C7_LOJA "
		cQuery+= " INNER JOIN "+RetSqlName("SB1")+" ON "+RetSqlName("SB1")+".D_E_L_E_T_ = '' "
		cQuery+= " AND B1_COD = C7_PRODUTO "
		cQuery+= " AND B1_FILIAL = C7_FILIAL "
		cQuery+= " WHERE "+RetSqlName("SC7")+".D_E_L_E_T_ = '' "
		cQuery+= " AND C7_NUM = '"+SC7->C7_NUM+"' "
		cQuery+= " AND C7_FILIAL = '"+FwxFilial("SC7")+"' "
		TcQuery cQuery New Alias (cTRBSC7 := GetNextAlias())


		IF (cTRBSC7)->(!Eof())
			While (cTRBSC7)->(!Eof())
				If ALLTRIM((cTRBSC7)->A2_EST) <> "EX"
					If ALLTRIM((cTRBSC7)->B1_XORIGCH) == "S"
						lEnvMail:= .T.
						aAdd(aLstBox,{(cTRBSC7)->C7_NUM,(cTRBSC7)->B1_COD,(cTRBSC7)->C7_ITEM})
					ENDIF
				ENDIF
				(cTRBSC7)->(DbSkip())
			Enddo
		Endif


		IF lEnvMail
			FOR z:=1 to len(aLstBox)
				If Z==1
					cConteudo:= "O pedido de compra "+SC7->C7_NUM+" do fornecedor: "+SC7->C7_FORNECE+"/"+SC7->C7_LOJA+" possui os seguintes itens China "
					cConteudo+= " Item: "+aLstBox[Z][3]+" / Produto: "+aLstBox[Z][2]+" "
				else
					cConteudo+= " , Item: "+aLstBox[Z][3]+" / Produto: "+aLstBox[Z][2]+" "
				endif
			NEXT z
			U_REQMAIL(cConteudo)
		ENDIF

		DbSelectArea((cTRBSC7))
		(cTRBSC7)->(DbCloseArea())

	ENDIF

return

//----------------------------------------------------------------------------------------------------------------------------------

USER FUNCTION REQMAIL(_CConteudo)
	Local cContent 	:= ""
	Local NERR 		:= 0
	Local cDe 		:= GetMV("MV_RELACNT")
	Local cPara 	:= GetMV("CL_MAILCH")
	Local cAssunto 	:= "PEDIDO DE COMPRA COM ITEM CHINA MAS FORNECEDOR NACIONAL"
	Local cMsg 		:= Iif(ValType(_CConteudo) <> Nil, _CConteudo, "")

	Local oServer
	Local oMessage
	Private cPopAddr 	:= "" // Endereco do servidor POP3
	Private cSMTPAddr 	:= GetMV("MV_RELSERV")
	Private cPOPPort 	:= 0 // Porta do servidor POP
	Private nSMTPPort 	:= 25 // Porta do servidor SMTP
	Private cUser 		:= GetMV("MV_RELACNT")
	Private cPass 		:= GetMV("MV_RELPSW")
	Private nSMTPTime 	:= 60
	cContent := "attachment 1 e-mail"

	oServer := TMailManager():New()
	oServer:setUseSSL(.F.)
	oServer:Init(cPopAddr, cSMTPAddr, cUser, cPass, cPOPPort, nSMTPPort)

	If (nErr := oServer:SetSmtpTimeOut( nSMTPTime )) != 0

		cLogMsg := alltrim("Falha ao setar o time out: " + oServer:getErrorString(nErr))
		FwLogMsg("INFO",, "EUROFINS", FunName(), "", "01", cLogMsg, 0,0, {})
		//MsgInfo( "Falha ao setar o time out: " + oServer:getErrorString(nErr) )
		Return .F.
	EndIf

	//realiza a conexão SMTP
	If (nErr := oServer:SmtpConnect()) != 0
		cLogMsg := alltrim("Falha ao conectar: "+ oServer:getErrorString(nErr) )
		FwLogMsg("INFO",, "EUROFINS", FunName(), "", "01", cLogMsg, 0,0, {})
		MsgInfo( "Falha ao conectar: "+ oServer:getErrorString(nErr) )
		Return .F.
	EndIf

	// Realiza autenticacao no servidor
	If GetMv("MV_RELAUTH")
		If (nErr := oServer:smtpAuth(GetMV("MV_RELACNT"), GetMV("MV_RELPSW"))) != 0
			cLogMsg := alltrim("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr) )
			FwLogMsg("INFO",, "EUROFINS", FunName(), "", "01", cLogMsg, 0,0, {})
			MsgInfo("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr) )
			Return .F.
		EndIf
	EndIf

	oMessage := TMailMessage():New()
	oMessage:SetConfirmRead(.T.)
	oMessage:Clear()

	oMessage:cFrom 		:= cDe
	oMessage:cTo 		:= cPara
	oMessage:cCc 		:= ""
	oMessage:cBcc 		:= ""
	oMessage:cSubject 	:= cAssunto
	oMessage:cBody 		:= cMsg
	oMessage:cDate		:= cValToChar(Date())

	//Envia o e-mail
	If  (nErr := oMessage:Send( oServer ))  != 0
		cLogMsg := alltrim("Erro ao enviar o e-mail: "+ oServer:getErrorString(nErr) )
		FwLogMsg("INFO",, "EUROFINS", FunName(), "", "01", cLogMsg, 0,0, {})
		MsgInfo( "Erro ao enviar o e-mail: "+ oServer:getErrorString(nErr) )
		Return .F.
	EndIf

	//Desconecta do servidor
	If  (nErr := oServer:SmtpDisconnect()) != 0
		cLogMsg := alltrim("Erro ao desconectar do servidor SMTP: "+ oServer:getErrorString(nErr) )
		FwLogMsg("INFO",, "EUROFINS", FunName(), "", "01", cLogMsg, 0,0, {})
		msgInfo( "Erro ao desconectar do servidor SMTP: "+ oServer:getErrorString(nErr) )
		Return .F.
	EndIf

RETURN(.T.)



