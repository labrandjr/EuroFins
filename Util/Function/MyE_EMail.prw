#include "ap5mail.ch"
#include "protheus.ch"

/*/{Protheus.doc} MyE_EMail
Rotina generica para envio de email
@author Microsiga
@since 04/01/2018
/*/
User Function MyE_EMail(cArquivo,cTitulo,cSubject,cBody,lShedule,cTo,cCC)

LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
LOCAL cUser,lMens:=.T.,nOp:=0,oDlg

DEFAULT cArquivo := ""
DEFAULT cTitulo  := ""
DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT lShedule := .F.
DEFAULT cTo      := ""
DEFAULT cCc      := ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   IF !lShedule
      MSGINFO("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   ELSE
      ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   ENDIF
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   IF !lShedule
      MSGINFO("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   ELSE
      ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   ENDIF
   RETURN .F.
ENDIF

IF lShedule .AND. EMPTY(cTo)
   IF !lShedule
      ConOut("E-mail para envio, nao informado.")
   ENDIF
   RETURN .F.
ENDIF

PswOrder(1)
PswSeek(__CUSERID,.T.)
aUsuario:= PswRet()
cFrom:= Alltrim(aUsuario[1,14])
cUser:= Subs(cUsuario,7,15)

cCC  := cCC + SPACE(200)
cTo  := cTo + SPACE(200)
cSubject:=cSubject+SPACE(100)

IF EMPTY(cFrom)
   IF !lShedule
       MsgInfo("E-mail do remetente nao definido no cad. do usuario: "+cUser)
   ELSE
       ConOut("E-mail do remetente nao definido no cad. do usuario: "+cUser)
   ENDIF
   RETURN .F.
ENDIF

DO WHILE !lShedule

   nOp  :=0
   nCol1:=8
   nCol2:=33
   nSize:=225
   nLinha:=15

   DEFINE MSDIALOG oDlg OF oMainWnd FROM 0,0 TO 350,544 PIXEL TITLE "Envio de E-mail"

  		@ nLinha,nCol1 Say "Título:"  Size 12,8              OF oDlg PIXEL
        @ nLinha,nCol2 MSGET cTitulo  SIZE nSize,10 WHEN .F. OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say "Usuário:" Size 20,8              OF oDlg PIXEL
        @ nLinha,nCol2 MSGET cUser    SIZE nSize,10 WHEN .F. OF oDlg PIXEL
        nLinha+=20

  		@ 000005,nCol1-4 To nLinha   ,268 LABEL " Informações " OF oDlg PIXEL
        nLinha+=05
        nLinAux:=nLinha
        nLinha+=10

  		@ nLinha,nCol1 Say   "De:"      Size 012,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET cFrom      Size nSize,10 WHEN .F.  OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "Para:"    Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET cTo        Size nSize,10  F3 "_EM" OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "CC:"      Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET cCC        Size nSize,10  F3 "_EM" OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "Assunto:" Size 021,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET cSubject   Size nSize,10           OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "Corpo:"   Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 Get   cBody      Size nSize,20  MEMO     OF oDlg PIXEL HSCROLL

  		@ nLinAux,nCol1-4 To nLinha+28,268 LABEL " Dados de Envio " OF oDlg PIXEL
        nLinha+=35

    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-90 TYPE 1 ACTION (If(Empty(cTo),Help("",1,"AVG0001054"),(oDlg:End(),nOp:=1))) ENABLE OF oDlg PIXEL
    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-45 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg CENTERED

   IF nOp == 0
      RETURN .F.
   ENDIF

   EXIT

ENDDO

cAttachment := cArquivo
cPassword   := AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica  := GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut    := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut    := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email

cTo := AvLeGrupoEMail(cTo)
cCC := AvLeGrupoEMail(cCC)

cBody := StrTran(cBody,Chr(10),Chr(13)+Chr(10))

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   IF !lShedule
       MsgInfo("Falha na Conexão com Servidor de E-Mail")
   ELSE
       ConOut("Falha na Conexão com Servidor de E-Mail")
   ENDIF
ELSE
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configuro o sistema para criar Confirmacao de Leitura e envio a mensagem   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConfirmMailRead(.T.)

   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
   ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desativo o sistema sobre a Confirmacao de Leitura no envio da mensagem     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConfirmMailRead(.F.)

	If !lOK
    	IF !lShedule
     		MsgInfo("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
      	ELSE
        	ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
      	ENDIF
   	ENDIF
ENDIF


DISCONNECT SMTP SERVER

IF lOk
   IF !lShedule
      MsgInfo("E-mail enviado com sucesso.")
   ELSE
      ConOut("E-mail enviado com sucesso.")
   ENDIF
ENDIF

RETURN .T.