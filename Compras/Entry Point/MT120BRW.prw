#include "totvs.ch"
#include "ap5mail.ch"
/*/{Protheus.doc}MT120BRW 
Na rotina de pedido de compra adiciona opção de alterar data de entrega do pedido.
@Author  Marcos Candido     
@since 21/11/2013   

/*/
User Function MT120BRW
	aAdd(aRotina,{"Alt.Dt.Entrega","U_AltDtEnt()", 0, 6, 6, Nil }) 
	AtuSC7()
Return

Static Function AtuSC7                          
	Local aArea := GetArea()
	BeginSql Alias "C7"
		Select R_E_C_N_O_ NumReg
		From %Table:SC7% 
		Where %NotDel% and C7_FILIAL = %xFilial:SC7% and C7_ZZTIPO = '  ' //and C7_NUMCOT <> '      '
	EndSql
	While C7->(!Eof())
		SC7->(DbGoTo(C7->NumReg))
		//RecLock("SC7",.f.)
		if SC7->(DBRLock())
			SC7->C7_ZZTIPO := RetField("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TIPO")
			SC7->(DBRUnlock(SC7->(recno())))
		endif
		C7->(DbSkip())
	End
	C7->(DbCloseArea())	
	RestArea(aArea)
Return

/*
±±ºPrograma  ³ AltDtEnt ºAutor  ³ Marcos Candido     º Data ³  21/11/13   º±±
±±ºDesc.     ³ Permite alterar a data de entrega no pedido, mesmo que ja  º±±
±±º          ³ tenha sido aprovado.                                       º±±
*/
User Function AltDtEnt(cNumPC)                     
	Local oJanela , oDlg1 //:= rpcsetenv("01","0101")
	Local dDtAtual := CtoD(Space(8))
	Local dDtNova  := CtoD(Space(8))    
	Local nOk    := 0
	Local nRadio := 1
	Local aAreaAtual := GetArea()
	Local cNumPCPos  := SC7->C7_NUM
	Local cIdCV8 := ""
	Local lOk    := .T.
	Local aInfo  := {}
	Local cMens  := ""
	Local cAux   := ""
	Local cUsrSC := ""
	Local cEmailUsr := ""
	Local cNomUsr   := ""
	Local cServer  := Alltrim(GetMV("MV_RELSERV"))			//"smtp.suaconta.com.br"
	Local cPass    := Alltrim(GetMV("MV_RELPSW"))			//Space(25)
	Local cAccount := Alltrim(GetMV("MV_RELACNT"))			//"seu@email.com.br"
	Local cUserAut := Alltrim(GetMv("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email
	Local cPassAut := Alltrim(GetMv("MV_RELAPSW",,cPass))	//Senha para Autenticação no Servidor de Email
	Local lAutentica  := GetMv("MV_RELAUTH",,.F.)			//Determina se o Servidor de Email necessita de Autenticação
	Local cAssunto  := "Alteracao de Data de Entrega - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
	SC1->(dbSetOrder(1))
	SC7->(dbSetOrder(1))
	If SC7->C7_CONAPRO == 'L' .and. SC7->C7_QUJE < SC7->C7_QUANT
		dDtAtual := SC7->C7_DATPRF
		Define MsDialog oJanela From 0,0 to 129,258 Pixel Title "Alteração da Data de Entrega"
		@ 003,003 To 039,129 of oJanela Pixel
		@ 012,010 Say "Data Atual " of oJanela Pixel
		@ 011,050 Get dDtAtual When .F. Size 50,10 of oJanela Pixel
		@ 026,010 Say "Nova Data " of oJanela Pixel
		@ 025,050 Get dDtNova Valid !Empty(dDtNova) .and. dDtNova >= dDataBase Size 50,10 of oJanela Pixel
		define sButton From  047,053 Type 1 Enable of oJanela Pixel Action(nOk:=1,oJanela:End())
		Activate MsDialog oJanela Center
	Else
		IW_MsgBox("Opção válida quando o Pedido já foi Aprovado e ainda não foi recebido." , "Atenção" , "ALERT")
	Endif
	If nOK == 1 .and. !Empty(dDtNova) .and. dDtNova <> dDtAtual 
		DEFINE MSDIALOG oDlg1 FROM  69,70 TO 220,331 TITLE OemToAnsi("Alteração de Data") PIXEL
		@ 0.3, 2 TO 58, 128 OF oDlg1 PIXEL
		@ 8, 08 SAY OemToAnsi("Data a Considerar") SIZE 80, 8 OF oDlg1 PIXEL	
		@ 7, 75 MSGET dDtNova SIZE 50,8 OF oDlg1 PIXEL When .F.
		@ 20,08 Radio oRadio VAR nRadio ;
		ITEMS "Apenas para este item deste Pedido", ; 
		"Para todos os itens deste Pedido" ; 
		3D SIZE 105,10 OF oDlg1 PIXEL
		DEFINE SBUTTON FROM 60, 100 TYPE 1 ENABLE ACTION oDlg1:End() OF oDlg1
		ACTIVATE MSDIALOG oDlg1 CENTERED
		If nRadio == 1		 	//gravar apenas para o registro corrente
			ProcLogIni( {} , "MATA121" , cNumPCPos , @cIdCV8 )	
			ProcLogAtu( "INICIO"   , "Alteração da Data de Entrega" , , , .T.)
			ProcLogAtu( "MENSAGEM" , "Alteração da Data de Entrega" , "Item: "+SC7->C7_ITEM+CRLF+"Valor Anterior: "+DtoC(SC7->C7_DATPRF)+CRLF+"Valor Atual: "+DtoC(dDtNova) , , .T.)
			ProcLogAtu( "FIM" , "Alteração da Data de Entrega" , , , .T.)
			If !Empty(SC7->(C7_NUMSC+C7_ITEMSC))
				If SC1->(dbSeek(xFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))
					aadd(aInfo , {SC7->C7_ITEM , SC7->C7_PRODUTO , Alltrim(SC7->C7_DESCRI) , DtoC(SC7->C7_DATPRF) , DtoC(dDtNova) , SC1->C1_USER , SC7->C7_NUMSC})
				Endif
			Endif
			dbSelectArea("SC7")
			RecLock("SC7",.F.)
			SC7->C7_DATPRF := dDtNova
			MsUnlock()
		Else					//gravar a data para todos os registros
			SC7->(dbSeek(xFilial("SC7")+cNumPCPos))
			ProcLogIni( {} , "MATA121" , cNumPCPos , @cIdCV8 )	
			ProcLogAtu( "INICIO"   , "Alteração da Data de Entrega" , , , .T.)
			While !SC7->(Eof()) .and. SC7->C7_FILIAL==xFilial("SC7") .and. SC7->C7_NUM == cNumPCPos
				ProcLogAtu( "MENSAGEM" , "Alteração da Data de Entrega" , "Item: "+SC7->C7_ITEM+CRLF+"Valor Anterior: "+DtoC(SC7->C7_DATPRF)+CRLF+"Valor Atual: "+DtoC(dDtNova) , , .T.)
				If !Empty(SC7->(C7_NUMSC+C7_ITEMSC))
					If SC1->(dbSeek(xFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))
						aadd(aInfo , {SC7->C7_ITEM , SC7->C7_PRODUTO , Alltrim(SC7->C7_DESCRI) , DtoC(SC7->C7_DATPRF) , DtoC(dDtNova) , SC1->C1_USER , SC7->C7_NUMSC})
					Endif
				Endif
				dbSelectArea("SC7")
				RecLock("SC7",.F.)
				SC7->C7_DATPRF := dDtNova
				MsUnlock()
				dbSkip()
			Enddo
			ProcLogAtu( "FIM" , "Alteração da Data de Entrega" , , , .T.)
		Endif		
	Endif
	If Len(aInfo) > 0
		For nI:=1 to Len(aInfo)
			If !(cUsrSC $ aInfo[nI,6])
				cUsrSC += aInfo[nI,6] + "; "
				PswOrder(1)
				PswSeek(aInfo[nI,6],.T.)
				aUsuario  := PswRet(1)
				If !AllTrim(aUsuario[1,4])$cNomUsr
					cNomUsr   += AllTrim(aUsuario[1,4]) + ", "
				Endif
				If !AllTrim(aUsuario[1,14])$cEmailUsr
					cEmailUsr += AllTrim(aUsuario[1,14]) + "; "
				Endif
			Endif
		Next nI
		cEmailUsr += ";estoque"+cFilAnt+"@eurofins.com"
		cMens := 'O Pedido de Compra nº '+cNumPCPos+' sofreu alteração na data de entrega do(s) item(ns) abaixo.'
		//cMens += cEmailUsr
		//cEmailUsr := "regis.ferreira@totvs.com.br"
		aCab  := {"Item","Código","Descrição","Data de Entrega Original","Nova Data de Entrega","User","Num. da S.C."}
		cMens := U_GetHTML(aCab,aInfo,cMens,cNomUsr)                         
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lOk	
		If lOk .and. lAutentica
			If !MailAuth(cUserAut,cPassAut)
				DISCONNECT SMTP SERVER RESULT lOk
			EndIf
		EndIf 
		If lOk
			SEND MAIL FROM cAccount TO cEMailUsr SUBJECT cAssunto BODY cMens RESULT lOk
		Endif
		DISCONNECT SMTP SERVER RESULT lOk
	Endif
	RestArea(aAreaAtual)
Return		

//remove emails duplicados 
Static Function Limpa(cEmail)
	Local cNovaLista := ""
	Local i 
	Local aEmails 
	Local cItem   
	While ","$cEmail
		cEmail := StrTran(cEmail,",",";")
	End             
	cEmail:=Lower(cEmail)           
	aEmails := StrToKarr(cEmail,";")
	aEmails := aSort(aEmails,,,{|x,y| x<y})
	For i :=1 to Len(aEmails)
		cItem := AllTrim(aEmails[i])
		If !cItem$cNovaLista
			cNovaLista += IIf(Empty(cNovaLista),"",";")+cItem
		EndIf
	Next
Return cNovaLista