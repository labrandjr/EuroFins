#include 'totvs.ch'


static lEurofins := !("YMLLLM" $ GetEnvServer())

user function SendMail(cp_De as character, cp_Para as character, ;
		cp_CC as character, cp_Assunto as character, ;
		cp_Texto as character, cp_Anexo as character)

	local cContent     := ""
	local cUser        := GetMV("MV_RELACNT")
	local cPass        := GetMV("MV_RELPSW")
	local cSMTPAddr    := iif(at(":",GetMV("MV_RELSERV"),1) > 0, substr(GetMV("MV_RELSERV"), 1, At(":",GetMV("MV_RELSERV"),1)-1),GetMV("MV_RELSERV"))  // Endereco do servidor SMTP
	local nSMTPPort    := iif(at(":",GetMV("MV_RELSERV"),1) > 0, val(substr(GetMV("MV_RELSERV"), At(":",GetMV("MV_RELSERV"),1)+1,10)),587) // Porta do servidor SMTP
	local cPopAddr     := '' // Endereco do servidor POP
	local nPOPPort     := 0 // Porta do servidor POP
	local lSSL         := GetMv("MV_RELSSL")
	local nSMTPTime    := 60
	local oServer
	local NERR         := 0
	local aEraseFile   := {}
	local n            := 0
	default cp_De      := cUser
	default cp_Para    := ""
	default cp_CC      := ""
	default cp_Assunto := ""
	default cp_Texto   := ""
	default cp_Anexo   := ""

	If lEurofins
		nSMTPPort := 25
	EndIf
	// cp_Anexo := Anexa(cp_Anexo)

	cMsg := "    USUARIO : " + cUser + CRLF
	cMsg += "       PASS : " + CpaSS + CRLF
	cMsg += " SERV. SMTP : " + cSMTPAddr + CRLF
	cMsg += "  PORT SMTP : " + ALLTRIM(STR(nSMTPPort)) + CRLF
	cMsg += "        SSL : " + IIF(lSSL,"SIM",'NAO') + CRLF

	cContent := "attachment 1 e-mail"
	FWMakeDir( "\arq_temp_aux\email_attachfile\" )

	oServer := TMailManager():New()
	If nSMTPPort == 465
		oServer:SetUseSSL( .T. )
	ElseIf nSMTPPort == 587
		oServer:SetUseTLS( .T. )
	EndIf
	oServer:Init(cPopAddr, cSMTPAddr, cUser, cPass, nPOPPort, nSMTPPort)


	If (nErr := oServer:SetSmtpTimeOut( nSMTPTime )) != 0
		u_zLogMsg( "Falha ao setar o time out: " + oServer:getErrorString(nErr) )
		Return .F.
	EndIf

	//realiza a conexao SMTP
	If (nErr := oServer:SmtpConnect()) != 0
		u_zLogMsg( "Falha ao conectar: "+ oServer:getErrorString(nErr) )
		Return .F.
	EndIf

	// Realiza autenticacao no servidor
	If GetMv("MV_RELAUTH")
		If (nErr := oServer:smtpAuth(GetMV("MV_RELACNT"), GetMV("MV_RELPSW"))) != 0
			u_zLogMsg("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr) )
			Return .F.
		EndIf
	EndIf

	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:SetConfirmRead(.T.)

	oMessage:cFrom 		:= cp_De			//e-mail de envio
	oMessage:cTo 		:= cp_Para		//e-mail que vai receber
	oMessage:cCc 		:= cp_CC
	oMessage:cBcc 		:= ""
	oMessage:cSubject 	:= cp_Assunto
	oMessage:cBody 		:= cp_Texto
	oMessage:cDate		:= cValToChar(Date())

	If !Empty(cp_Anexo)
		aAnexo := {}
		aAnexo := strToKarr(cp_Anexo,";")
		cAnexEnv := ""
		aEraseFile := {}
		For n := 1 To len(aAnexo)
			cPathTemp := "\arq_temp_aux\email_attachfile\"
			cAnexEnv := aAnexo[n]
			cNomeArq := "FILE"
			if (nPosAt := RAT("\",aAnexo[n])) > 0
				cNomeArq := SubStr(aAnexo[n], nPosAt+1 )
			Endif
			aAdd(aEraseFile,  cAnexEnv)

			If oMessage:AttachFile(cAnexEnv) < 0 .and. !Empty(cAnexEnv)
				u_zLogMsg( "Erro ao atachar o arquivo" )
				Return .F.
			Else
				//adiciona uma tag informando que e um attach e o nome do arq
				oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cNomeArq )
			EndIf

		Next n
	EndIf

	//Envia o e-mail
	If  (nErr := oMessage:Send( oServer ))  != 0
		u_zLogMsg( "Erro ao enviar o e-mail: "+ oServer:getErrorString(nErr) )
		Return .F.
	EndIf

	//Desconecta do servidor
	If  (nErr := oServer:SmtpDisconnect()) != 0
		u_zLogMsg( "Erro ao desconectar do servidor SMTP: "+ oServer:getErrorString(nErr) )
		Return .F.
	EndIf

	//exclui o arquivo anexo
	// aEval(aEraseFile,{|x|, FERASE(x)})
return(.T.)
