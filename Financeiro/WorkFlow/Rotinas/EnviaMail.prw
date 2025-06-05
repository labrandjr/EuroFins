#include "totvs.ch"
#include "ap5mail.ch"

/**
 * Classe generica de envio de e-mail Walsywa
 *
 * @author Fabio Hayama
 * @since 10/03/2015
 */

class EnviaMail

	method New() CONSTRUCTOR
	method enviaEmail()
	method envMailSimp()
endClass

method new() class EnviaMail
return

method enviaEmail(cHtml,cAssunto,cToMail,cFile,cFrom,cMailServer,cBCC) class EnviaMail
	local lOk         	:= .F.
	local lAutOk      	:= .F.
	locaL lSmtpAuth   	:= GetMv("MV_RELAUTH",,.F.)
	local nSleepErr		:= 180000	//3 min.
	local nI				:= 1

	private cSubject    	:= Alltrim(cAssunto)
	private cMailConta  	:= SuperGetMV("MV_EMCONTA", .T., "workflow@walsywa.com.br")
	private cMailSenha  	:= SuperGetMV("MV_EMSENHA", .T., "bpeZAT#j2") //Senha alterada em 22/11/2018
	private cMailCtaAut 	:= SuperGetMV("MV_RELACNT", .T., "workflow@mkt.walsywa.com.br")
	private cMailSenaAut 	:= SuperGetMV("MV_RELASNH", .T., "jp3@VCsqFNuaD")
	private cError      	:= ""
	private lSendOK     	:= .F.

	default cFile 			:= ""
	default cFrom			:= cMailConta
	default cMailServer		:= GetMV("MV_RELSERV")
	default cBCC			:= ""

	if !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha) .And. !Empty(cMailCtaAut)
	   	if !lOk
			CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
	   	endIf

	   	if !lAutOk
			if ( lSmtpAuth )
 				lAutOk := MailAuth(cMailCtaAut, cMailSenaAut)
      		else
 	 			lAutOk := .T.
  			endIf
	   	endIf

	   	if lOk .And. lAutOk
	      	ConOut('Initializing automatic e-mail process...' + DtoC(Date()) + " as " + Time()+' Rotina: '+FUNNAME()+' - Emails: '+cToMail)
			for nI := 1 to 3
				if(Empty(cFile) .AND. Empty(cBCC))
					SEND MAIL FROM cFrom TO cToMail SUBJECT cSubject BODY cHtml RESULT lSendOk

				elseif(!Empty(cFile) .AND. Empty(cBCC))
					SEND MAIL FROM cFrom TO cToMail SUBJECT cSubject BODY cHtml ATTACHMENT cFile RESULT lSendOk

				elseif(Empty(cFile) .AND. !Empty(cBCC))
					SEND MAIL FROM cFrom TO cToMail BCC cBCC SUBJECT cSubject BODY cHtml RESULT lSendOk

				elseif(!Empty(cFile) .AND. !Empty(cBCC))
					SEND MAIL FROM cFrom TO cToMail BCC cBCC SUBJECT cSubject BODY cHtml ATTACHMENT cFile RESULT lSendOk

		      	endIf

				if lSendOk
					cAuxStat := "E"
					Exit
				else
				   cAuxStat := "R"
				   GET MAIL ERROR cError
				   cError := "ERRO-" + Alltrim(cError)
				   ConOut('Erro no envio do email! ' + cError)
				   ConOut('Erro no envio Data: '+ DtoC(Date()) + " as " + Time()+' Rotina: '+FUNNAME()+' - Emails: '+cToMail)
				   if "no response" $ Alltrim(cError)
				   		Sleep(nSleepErr)
				   		ConOut(cValtoChar(nI)+" Tentativa(s) de envio do email! ")
				   else
				   		Exit
				   endIf
				endIf
			next
			ConOut('Finalizing automatic e-mail process...'+ DtoC(Date()) + " as " + Time()+' Rotina: '+FUNNAME()+' - Emails: '+cToMail)
		else
		  GET MAIL ERROR cError
		  cError := "ERRO-" + Alltrim(cError)
		  ConOut('Automatic e-mail process error: ' + cError)
		  ConOut('Automatic erro no envio Data: '+ DtoC(Date()) + " as " + Time()+' Rotina: '+FUNNAME()+' - Emails: '+cToMail)
	   endIf
	else
		cError := "ERRO-Variaveis de e-mail vazias."
		ConOut(cError)
	endIf
return cError

method envMailSimp(_ccorpo, _cassunto, _cpara, _cfiles, _de, _cMailSrv, _ccc, _lmsg) class EnviaMail    
	Local _cpara    := IiF(_cpara    == NIL, "" 													, _cpara)
	Local _ccc      := IiF(_ccc      == NIL, "" 													, _ccc)
	Local _cassunto := IiF(_cassunto == NIL, "" 													, _cassunto)
	Local _ccorpo   := IiF(_ccorpo   == NIL, "" 													, _ccorpo)
	Local _cfiles   := IiF(_cfiles   == NIL, "" 													, _cfiles)
	Local _lmsg     := IiF(_lmsg     == NIL, .T.													, _lmsg)
	Local _de       := IiF(_de       == NIL, "sistema"+Str(Randomize( 1, 6 ),1)+"@maxgear.com.br"	, _de)
	local _cMailSrv	:= IiF(_cMailSrv == NIL, "smtp.maxgear.com.br:587" 								, _cMailSrv)
	Local _pass     := "max792813"
	
	CONNECT SMTP SERVER _cMailSrv ACCOUNT _de PASSWORD _pass Result lConectou 
	If lConectou
	   If MAILAUTh(_de, _pass)
	      If !Empty(_cfiles)   
	      	 SEND MAIL FROM _de TO _cpara CC _ccc SUBJECT _cassunto BODY _ccorpo ATTACHMENT _cfiles
	         
	      Else
	         SEND MAIL FROM _de TO _cpara CC _ccc SUBJECT _cassunto BODY _ccorpo
	      Endif
	   Else
	      If _lmsg
	         msgInfo("e-mail não pode ser enviado !")
	      Endif
	   Endif
	Else
	   If _lmsg
	      msgInfo("Servidor de e-mails OFFLINE !")
	   Endif
	Endif
	
	DISCONNECT SMTP SERVER

Return .T.