#include "totvs.ch"
#include "topconn.ch"
#include "ap5mail.ch"
/*/{Protheus.doc} ENVHTML
Envia e-mail de WF de Compras para SC/PC
@author Regis Ferreira
@since 24/04/2019
/*/
User Function ENVHTML(cTIPO, cNum, aDados, cRotina)
	Local aArea         := GetArea()
	Local cEMailAprv 	:= ""
	Local cNomAprv     	:= ""
	Local cAssunto		:= ""
	Local cTo			:= ""
	Local cMens			:= ""
	Local cServer  		:= Alltrim(GetMV("MV_RELSERV"))			//"smtp.suaconta.com.br"
	Local cPass    		:= Alltrim(GetMV("MV_RELPSW"))			//Space(25)
	Local cUser 		:= Alltrim(GetMV("MV_RELACNT"))			//"seu@email.com.br"
	Local cUserAut 		:= Alltrim(GetMv("MV_RELAUSR",,cUser))//Usuário para Autenticação no Servidor de Email
	Local cPassAut 		:= Alltrim(GetMv("MV_RELAPSW",,cPass))	//Senha para Autenticação no Servidor de Email
	Local lAutentica  	:= GetMv("MV_RELAUTH",,.F.)			//Determina se o Servidor de Email necessita de Autenticação
	Local lOK			:= .F.
	Local cUPCSC		:= "" //Usuario que incluiu ou alterou a SC/PC
	Local aItens		:= {}
	Local nTotRegs 		:= 0 //QUantidade de registros
	Local aCab
	Local cSolic                               
	If !Getmv("ZZ_WFATIVO")//,".T.","L","Ativa envio de email nas movimentações de compras")
		Return
	Endif
	//Se for SC
	If cTipo =="SC" .and. Alltrim(cRotina) =="MATA110"
		//Calcular se tem Aprovador de SC
		BeginSql Alias "CR"
			SELECT DISTINCT CR_USER
			FROM %Table:SCR%
			WHERE CR_FILIAL = %xFilial:SCR% AND
			CR_NUM = %Exp:cNum% AND CR_TIPO = 'SC' AND %NotDel%
			ORDER BY CR_USER
		EndSql
		//Percorre todos aprovadores
		While CR->(!Eof())
			cEMailAprv := ""
			cNomAprv   := ""
			aItens	   := {}
			cTo		   := UsrRetMail(CR->CR_USER)
			cNomAprv   := AllTrim(UsrRetName(CR->CR_USER))
			Posicione("DBM",2,xFilial("DBM")+cTipo+cNum,"")
			While DBM->(!Eof().and. DBM_FILIAL+DBM_TIPO+Alltrim(DBM_NUM) == xFilial()+cTipo+cNum)
				if DBM->DBM_USER == CR->CR_USER
					If Posicione("SC1",1,xFilial("SC1")+DBM->(Left(DBM_NUM,6) + DBM_ITEM),"!Eof()")
						SC1->(aadd(aItens, {C1_ITEM,C1_PRODUTO,C1_DESCRI,Alltrim(Transform(C1_QUANT,"@E 999,999,999.99")),dToc(C1_DATPRF),C1_OBS}))
					endif
				endif
				DBM->(dbSkip())
			End
			//Se tiver aprovador e itens
			If !Empty(cTo) .and. !Empty(aItens)
				cAssunto  := IIf(aDados[2]==2,"Alteração","Inclusão")+" de Solicitacao de Compra - Empresa/Filial: "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
				if aDados[2] == 2
					cMens := "A Solicitação de Compra nº ["+cNum+"] foi alterada e aguarda nova aprovação."
				else
					cMens := "A Solicitação de Compra nº ["+cNum+"] foi incluída e aguarda aprovação."
				endif                
				aCab := {'Item','Codigo','Descrição','Quantidade','Dt Necessidade','Observação'}
				cMens := U_GetHTML(aCab,aItens,cMens,cNomAprv)
				U_ENVMAIL(cUser, cTo, cAssunto, cMens, lOk, cServer, cUser, cPass, lAutentica, cUserAut, cPassAut)
			endif
			CR->(dbSkip())
		end
		CR->(DbCloseArea())
	Elseif cTipo == "SC" .and. Alltrim(cRotina) == "MATA094" //Aprovação ou rejeição de solicitação de compras
		BeginSql Alias "C1"      
			Column C1_DATPRF as Date
			Select C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_QUANT, C1_DATPRF, C1_OBS, C1_USER
			From %Table:DBM% DBM, %Table:SC1% SC1
			Where DBM.DBM_FILIAL = %xFilial:DBM% and DBM.%NotDel% and DBM.DBM_NUM = %Exp:cNum% and   
				  SC1.C1_FILIAL = %xFilial:SC1% and SC1.%NotDel% and SC1.C1_NUM = DBM.DBM_NUM and SC1.C1_ITEM = DBM_ITEM AND DBM_TIPO='SC'
			Order BY C1_ITEM
		EndSql     
		aItens := {}
		cTo := ""
		While C1->(!Eof())                                
			cAprov := UsrFullName(C1->C1_USER)
			C1->(aadd(aItens, {C1_ITEM,C1_PRODUTO,C1_DESCRI,Alltrim(Transform(C1_QUANT,"@E 999,999,999.99")),dToc(C1_DATPRF),C1_OBS}))
			If !Alltrim(Lower(UsrRetMail(C1->C1_USER)))$cTo
				cTo += IIf(Empty(cTo),"",";")+Alltrim(Lower(UsrRetMail(C1->C1_USER)))
			Endif
			C1->(DbSkip())
		End           
		C1->(DbCloseArea())
		If Len(aItens)>0
			cAssunto := "A Solicitação de Compras ["+cNum+"] foi "+Iif(aDados[3]==1,"aprovada.","rejeitada.")
			aCab     := {'Item','Produto','Descrição','Quantidade','Entrega','Observações'}
			cMens := U_GetHTML(aCab,aItens,cAssunto,cAprov)              
			cTo += ";compras@eurofins.com;estoque"+cFilAnt+"@eurofins.com"
			U_ENVMAIL(cUser,cTo,cAssunto,cMens,lOk,cServer,cUser,cPass,lAutentica,cUserAut,cPassAut)
		Endif
	ElseIf cTipo == "IP" .and. Alltrim(cRotina) $ "MATA094|MATA120"
		BeginSql Alias "NIVEL"
			Select Distinct CR_NIVEL
			From %Table:SCR%
			Where %NotDel% and CR_FILIAL = %xFilial:SCR% and CR_NUM = %Exp:cNum% and CR_DATALIB='        ' and CR_TIPO = %Exp:cTipo%
			Order By CR_NIVEL
		EndSql    
		If NIVEL->(!Eof())                  
			BeginSql Alias "APROV"
				Select Distinct CR_USER
				From %Table:SCR%
				Where %NotDel% and CR_FILIAL = %xFilial:SCR% and CR_NUM = %Exp:cNum% and CR_DATALIB='        ' and CR_NIVEL = %Exp:NIVEL->CR_NIVEL% and CR_TIPO = %Exp:cTipo%
				Order by CR_USER
			EndSql
			While APROV->(!Eof())
				cTo       := UsrRetmail(APROV->CR_USER)+";estoque"+cFilAnt+"@eurofins.com"
				cAssunto  := "O Pedido de Compras ["+AllTrim(cNum)+"] da Empresa "+Alltrim(SM0->M0_NOME)+" / Filial "+Alltrim(SM0->M0_FILIAL)
				If cRotina == "MATA094"
					cAssunto += IIF(aDados[3]==1," aguarda aprovação."," foi "+IIF(aDados[3]==5,"rejeitado.","bloqueado."))
				Else
					cAssunto += " aguarda aprovação."
				Endif
				BeginSql Alias "C7"      
					Column C7_DATPRF as Date
					Select C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_QUANT, C7_DATPRF, C7_OBS,C7_NUMSC,C7_ITEMSC
					From %Table:DBM% DBM, %Table:SC7% SC7
					Where DBM.DBM_FILIAL = %xFilial:DBM% and DBM.%NotDel% and DBM.DBM_NUM = %Exp:cNum% and DBM.DBM_USER = %Exp:APROV->CR_USER% and  
						  SC7.C7_FILIAL = %xFilial:SC7% and SC7.%NotDel% and SC7.C7_NUM = DBM.DBM_NUM and SC7.C7_ITEM = DBM_ITEM and DBM_TIPO = %Exp:cTipo% and C7_TIPO = '1' 
					Order BY C7_ITEM
				EndSql                                                   
				aItens := {}			              
				While C7->(!Eof())
					C7->(AADD(aItens,{C7_ITEM,C7_PRODUTO,C7_DESCRI,Alltrim(Transform(C7_QUANT,"@E 999,999,999.99")),DtoC(C7_DATPRF),C7_OBS}))
					If Posicione("SC1",1,xFilial("SC1")+C7->(C7_NUMSC+C7_ITEMSC),"!Eof()")
						If !Empty(UsrRetMail(SC1->C1_USER))
							If !AllTrim(UsrRetMail(SC1->C1_USER))$cTo
								cTo += ";"+AllTrim(UsrRetMail(SC1->C1_USER))
							Endif						
						Endif
					Endif
					C7->(DbSkip())
				End       
				C7->(DbCloseArea())                                                                                        
				If Len(aItens)>0 
					aCab := {'Item','Codigo','Descrição','Quantidade','Dt Entrega','Observação'}
					cMens := U_GetHTML(aCab,aItens,cAssunto,UsrFullName(APROV->CR_USER))
					U_ENVMAIL(cUser, cTo, cAssunto, cMens, lOk, cServer, cUser, cPass, lAutentica, cUserAut, cPassAut)
				Endif
			APROV->(DbSkip())
			End
			APROV->(DbCloseArea())
		Else
			cTo := "estoque"+cFilAnt+"@eurofins.com;compras@eurofins.com"
			BeginSql Alias "C1"
				Select Distinct C1_USER
				From %Table:SC1%
				Where %NotDel% and C1_FILIAL=%xFilial:SC1% and C1_PEDIDO = %Exp:cNum%
			EndSql 
			cAprov := "Estoque"                                                                  
			While C1->(!Eof())               
				If !AllTrim(Lower(UsrRetMail(C1->C1_USER)))$Lower(cTo) 
					cTo += ";"+AllTrim(Lower(UsrRetMail(C1->C1_USER)))
				Endif                             
				If !AllTrim(UsrFullName(C1->C1_USER))$cAprov
					cAprov += "/"+UsrFullName(C1->C1_USER)
				Endif
				C1->(DbSkip())
			End                         
			C1->(DbCloseArea())
			BeginSql Alias "C7"     
				Column C7_DATPRF as Date
				Select C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_QUANT, C7_DATPRF, C7_OBS
				From %Table:SC7% SC7
				Where  SC7.C7_FILIAL = %xFilial:SC7% and SC7.%NotDel% and SC7.C7_NUM = %Exp:cNum%
				Order BY C7_ITEM			
			EndSql            
			aItens := {}                                                          
			While C7->(!Eof())
				C7->(AADD(aItens,{C7_ITEM,C7_PRODUTO,C7_DESCRI,Alltrim(Transform(C7_QUANT,"@E 999,999,999.99")),DtoC(C7_DATPRF),C7_OBS}))
				C7->(DbSkip())
			End                                                                  
			C7->(DbCloseArea())
			cAssunto := "O pedido ["+cNum+"] da empresa "+AllTrim(SM0->M0_NOME)+" Filial "+AllTrim(SM0->M0_FILIAL)+" foi "+IIf(aDados[3]==5,"rejeitado.","aprovado.")
			aCab := {'Item','Codigo','Descrição','Quantidade','Dt Entrega','Observação'}
			cMens := U_GetHTML(aCab,aItens,cAssunto,cAprov)
			U_EnvMail(cUser,cTo,cAssunto,cMens,lOk,cServer,cUser,cPass,lAutentica,cUserAut,cPassAut)             				
		Endif		
		NIVEL->(DbCloseArea())
	ElseIf cTipo == "IP" .and. AllTrim(cRotina) == "MATA160"
		BeginSql Alias "CR"
			Select Distinct CR_NIVEL,CR_USER
			From %Table:SC8% SC8, %Table:SCR% SCR
			Where SC8.%NotDel% and SCR.%NotDel% and C8_FILIAL = %xFilial:SC8% and CR_FILIAL = %xFilial:SCR% and 
			C8_NUM = %Exp:cNum% and CR_TIPO=%Exp:cTipo% and C8_NUMPED = CR_NUM AND CR_DATALIB='        ' and C8_NUMPED Not In ('XXXXXX','      ')
			Order by CR_NIVEL
		EndSql                                
		If CR->(!Eof())                  
			cNivel := CR->CR_NIVEL
			While CR->CR_NIVEL==cNivel.and. CR->(!Eof())
				cTo := AllTrim(Lower(UsrRetMail(CR->CR_USER)))+";estoque"+cFilAnt+"@eurofins.com" 
				BeginSql Alias "PEDI"
					Select Distinct C8_NUMPED
					From %Table:SC8% SC8
					Where SC8.%NotDel% and C8_FILIAL = %xFilial:SC8% and C8_NUM = %Exp:cNum% and C8_NUMPED Not In ('XXXXXX','      ')
					Order By C8_NUMPED
				EndSql                       
				While PEDI->(!Eof())
					BeginSql Alias "C8" 
						Column C8_DATPRF as Date
						Select C8_ITEM,C8_PRODUTO,C8_QUANT,C8_DATPRF,C8_NUMPED,C8_ITEMPED,C8_NUMSC,C8_ITEMSC
						From %Table:SC8% SC8
						Where SC8.%NotDel% and C8_FILIAL = %xFilial:SC8% and C8_NUM = %Exp:cNum% and C8_NUMPED=%Exp:PEDI->C8_NUMPED%
						Order By C8_ITEMSC
					EndSql     
					aItens := {}
					While C8->(!Eof())                
						cAssunto := "O pedido ["+PEDI->C8_NUMPED+"] da empresa "+AllTrim(SM0->M0_NOME)+" Filial "+AllTrim(SM0->M0_FILIAL)+" aguarda aprovação."
						Posicione("SB1",1,xFilial("SB1")+C8->C8_PRODUTO,"")    
						Posicione("SC7",1,xFilial("SC7")+C8->(C8_NUMPED+C8_ITEMPED),"")
						Posicione("SC1",1,xFilial("SC1")+C8->(C8_NUMSC+C8_ITEMSC),"")
						If !AllTrim(Lower(UsrRetMail(SC1->C1_USER)))$cTo
							cTo += ';'+AllTrim(Lower(UsrRetMail(SC1->C1_USER)))
						Endif
						C8->(AADD(aItens,{C8_ITEMSC,C8_PRODUTO,AllTrim(SB1->B1_DESC),AllTrim(Transform(C8_QUANT,"@E 999,999,999.99")),Dtoc(C8_DATPRF),AllTrim(SC7->C7_OBS)}))
						C8->(DbSkip())
					End
					C8->(DbCloseArea())
					aCab := {'Item','Codigo','Descrição','Quantidade','Dt Entrega','Observação'}
					If !Empty(cTo).and.Len(aItens)>0
						cMens := U_GetHTML(aCab,aItens,cAssunto,UsrFullName(CR->CR_USER))
						U_ENVMAIL(cUser, cTo, cAssunto, cMens, lOk, cServer, cUser, cPass, lAutentica, cUserAut, cPassAut)
					Endif
					PEDI->(DbSkip())
				End                 
				PEDI->(DbCloseArea())
				CR->(DbSkip())
			End
		EndIf               
		CR->(DbCloseArea())
	ElseIf cTipo == "NF" .and. AllTrim(cRotina)=="MATA103"
		BeginSql Alias "NF"  
			Column D1_EMISSAO as Date
			Select D1_FILIAL, D1_ITEM,D1_SERIE,D1_DOC, D1_FORNECE, D1_QUANT,D1_LOJA, D1_TIPO,D1_COD, D1_PEDIDO, D1_ITEMPC,D1_EMISSAO,C1_USER,C1_NUM,C1_ITEM
			From %Table:SD1% SD1, %Table:SC7% SC7, %Table:SC1% SC1
			Where SD1.%NotDel% and SC7.%NotDel% and SC1.%NotDel% and
				D1_FILIAL = %xFilial:SD1% and C7_FILIAL = %xFilial:SC7% and C1_FILIAL = %xFilial:SC1% and
				D1_PEDIDO = C7_NUM and D1_ITEMPC = C7_ITEM and C1_NUM = C7_NUMSC and C1_ITEM = C7_ITEMSC and C7_TIPO = '1' and 
				D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA = %Exp:cNum% and D1_TIPO = 'N'
			Order BY D1_ITEM 
		EndSql
		cTo := "estoque"+cFilAnt+"@eurofins.com"            
		aItens := {}
		While NF->(!Eof())
			cSolic   := AllTrim(UsrFullName(NF->C1_USER))
			cAssunto := "A solicitação de compras ["+NF->(C1_NUM+"] foi atendida através da N.F. "+D1_DOC+" Serie "+D1_SERIE+" de "+dtoc(D1_EMISSAO))
			If !AllTrim(Lower(UsrRetMail(NF->C1_USER)))$cTo			
				cTo += ";" + AllTrim(Lower(UsrRetMail(NF->C1_USER)))
			Endif     
			Posicione("SB1",1,xFilial("SB1")+NF->D1_COD,"")
			NF->(AADD(aItens,{D1_ITEM,D1_COD,AllTrim(SB1->B1_DESC),Transform(D1_QUANT,"@E 999,999,999.99"),C1_NUM,C1_ITEM}))
			NF->(DbSkip())			
		End                         
		NF->(DbCloseArea())
		If Len(aItens)>0
			aCab := {"Item NF","Produto","Descrição","Quantidade","Solicitação","Item SC"}
			cMens := U_GetHTML(aCab,aItens,cAssunto,cSolic)		
			U_EnvMail(cUser,cTo,cAssunto,cMens,lOk,cServer,cUser,cPass,lAutentica,cUserAut,cPassAut)
		Endif
	ElseIf cTipo == "CT" .and. cRotina=="MATA131"
		cTo := "compras@eurofins.com;estoque"+cFilAnt+"@eurofins.com"
		BeginSql Alias "CT"
			Select Distinct C8_NUMSC,C8_ITEMSC
			From %Table:SC8%
			Where %NotDel% and C8_NUM=%Exp:cNum% and C8_FILIAL = %xFilial:SC8%
			Order By 1,2
		EndSql	          
		aItens := {}       
		aCab:={"Item","Produto","Descrição","Quantidade","Sol.Compras"}
		While CT->(!Eof())
			If Posicione("SC1",1,xFilial("SC1")+CT->(C8_NUMSC+C8_ITEMSC),"!Eof()")
				cAssunto := "A solicitação de compras ["+CT->C8_NUMSC+"] tornou-se a cotação "+cNum
				cSolic := UsrFullName(SC1->C1_USER) 
				If !Lower(AllTrim(UsrRetMail(SC1->C1_USER)))$cTo
					cTo += ";"+Lower(UsrRetMail(SC1->C1_USER))
				EndIf
				SC1->(AADD(aItens,{C1_ITEM,C1_PRODUTO,C1_DESCRI,Transform(C1_QUANT,"@E 999,999,999.99"),C1_NUM}))                                                
			EndIf
			CT->(DbSkip())
		End   
		CT->(DbCloseArea())
		If Len(aItens)>0  
			cMens := U_GetHTML(aCab,aItens,cAssunto,cSolic)
			U_EnvMail(cUser,cTo,cAssunto,cMens,lOk,cServer,cUser,cPass,lAutentica,cUserAut,cPassAut)
		Endif
	Endif
	RestArea(aArea)
Return Nil

User Function EnvMail(cUser, cTo, cAssunto, cMens, lOk, cServer, cUser, cPass, lAutentica, cUserAut, cPassAut)
	CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPass Result lOk
	If lOk .and. lAutentica
		If !MailAuth(cUserAut,cPassAut)
			DISCONNECT SMTP SERVER RESULT lOk
		EndIf
	EndIf   
//	cMens += cTo
//	cTo := "cps.sbraz@totvs.com.br"
	If lOk
		SEND MAIL FROM cUser TO cTo SUBJECT cAssunto BODY cMens RESULT lOk
	Endif
	DISCONNECT SMTP SERVER RESULT lOk
Return

//Gera um html de uma tabela com cabeçalhos
User Function GetHTML(aCab,aItens,cAssunto,cAprov)
	Local cMens         
	Local cSaudacao                   
	Local i,j      
	If Time() < "12:00:00"
		cSaudacao := "Bom dia"
	ElseIf Time() < "18:00:00"
		cSaudacao := "Boa tarde"
	Else
		cSaudacao := "Boa noite"
	Endif
	cMens := "<html><body bgcolor='ffffff'>"
	cMens += "<font face='tahoma' size=2 color=blue>"
	cMens += "<h4>"+cSaudacao+", Sr(a) "+AllTrim(cAprov)+"</h4>"
	cMens += "<font face='tahoma' size=2><br>"
	cMens += "<h4>" + cAssunto + "</h4><br>"
	cMens += "<table border=1 cellpadding='3' cellspacing='0' style='width: 100%'>"                 
	cMens += "<tr>"
	For I:= 1 to Len(aCab)
		cMens += "<th align='center'><font face='tahoma' size=2 color=blue><b>"+aCab[i]+"</b></th>"
	Next	      
	cMens += "</tr>" 
	For i:=1 to Len(aItens)
		cMens += "<tr>"
		For j:= 1 to Len(aItens[i])
			cMens += "<td align='center'><font face='tahoma' size=2 color=blue><b>"+aItens[i,j]+"</p></b></td>"
		Next           
		cMens += "</tr>" 
	Next    
	cMens += "</table><br>"
	cMens += "<p>E-mail automático enviado pelo módulo SIGACOM.</font>"	
	If "TESTE"$Upper(GetEnvServer())
		cMens += '<h3 style="color:Tomato;">Ambiente de testes-Desconsiderar</h3>'
	Endif                                                             
	cMens+="</body></html>"
Return cMens
