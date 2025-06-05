#include "totvs.ch"
#include "ap5mail.ch"
/*/{protheus.doc}JobEst
Job que envia emails informando estoque mínimo, máximo e sem movimentação
@author Sergio Braz
@since 03/10/2019
/*/
User Function JOBEST
	Local aCabProd , aProd,cHtml,cTipo,cEmail,cBlindC,F,aEmp:={},cArquivo,cPadrao,cControl,aTitulos,aArq
	Local cFiliais 		:= ""	//Quais filiais geram o excel no JOB
	Local cMV_ZZTPEST	:= ""	//Tipos de produtos que geram o excel no JOB
	Local dZZ_JOBEST
	Local cEmail   		:= ""
	Local i				:= 0
	Private cForn,cPed,nQuantPC,cSolic,dProxima,nQtdEnt,nQuantSC,dUltMov,nQtdMOv,nCCMov

	aCabProd := {}
	aProd    := {{},{},{},{}}
	aTitulos := Array(4)
	AADD(aCabProd,{"Codigo","Descrição","Classe ABC","Un.Med.","Armazém","Saldo Atual","Valor. Unit.","Valor Total","Ult.Movimentação","Qtd.Movimentada","CC.Movimentação","Qtd.Aberta em PC","PCs Abertos","Fornecedor","Próxima Entrega","Quantidade Próx. entrega","Consumo Médio","Estoque Seguraça","Ponto de Pedido","Estoque Máximo","Tipo","Controlado"})
	AADD(aCabProd,{"Codigo","Descrição","Classe ABC","Un.Med.","Armazém","Saldo Atual","Valor. Unit.","Valor Total","Ult.Movimentação","Qtd.Movimentada","CC.Movimentação","Qtd.Aberta em PC","PCs Abertos","Fornecedor","Próxima Entrega","Quantidade Próx. entrega","Consumo Médio","Estoque Seguraça","Ponto de Pedido","Estoque Máximo","Tipo","Controlado"})
	AADD(aCabProd,{"Codigo","Descrição","Classe ABC","Un.Med.","Armazém","Saldo Atual","Valor. Unit.","Valor Total","Ult.Movimentação","Qtd.Movimentada","CC.Movimentação","Qtd.Aberta em PC","PCs Abertos","Fornecedor","Próxima Entrega","Quantidade Próx. entrega","Consumo Médio","Estoque Seguraça","Ponto de Pedido","Estoque Máximo","Tipo","Controlado"})
	AADD(aCabProd,{"Codigo","Descrição","Classe ABC","Un.Med.","Armazém","Saldo Atual","Valor. Unit.","Valor Total","Ult.Movimentação","Qtd.Movimentada","CC.Movimentação","Qtd.Aberta em PC","PCs Abertos","Fornecedor","Próxima Entrega","Quantidade Próx. entrega","Consumo Médio","Estoque Seguraça","Ponto de Pedido","Estoque Máximo","Tipo","Controlado"})
	aArq := {"EstMin.xls","EstMax.xls","SemMov.xls","SaldoTot.xls"}


	OpenSM0()
	Set Deleted On
	SM0->(DbGoTop())
	While SM0->(!Eof())
		SM0->(AADD(aEmp,{M0_CODIGO,M0_CODFIL}))
		SM0->(DbSkip())
	End
	aSort(aEmp,,,{|x,y| x[1]+x[2]<y[1]+y[2]})
	SM0->(DbCloseAll())
	For f:=1 to Len(aEmp)

		//If !File(GetSrvProfString("StartPath", "\system")+"SX2"+aEmp[f,1]+"0.dtc")
		//Loop
		//Endif

		RpcSetEnv(aEmp[f,1],aEmp[f,2])

		PegaParam(@cFiliais, @cMV_ZZTPEST, @dZZ_JOBEST, @cEmail)


		if "TESTE"$Upper(GetEnvServer())
			aTitulos[1] := "(BASE TESTE) Produtos com saldo menor que estoque mínimo em "+dtoc(dDataBase)
			aTitulos[2] := "(BASE TESTE) Produtos com saldo maior que estoque máximo em "+dtoc(dDataBase)
			aTitulos[3] := "(BASE TESTE) Produtos sem movimentação a mais de 6 meses em "+dtoc(dDataBase)
			aTitulos[4] := "(BASE TESTE) Saldos dos Produtos em "+dtoc(dDataBase)
		else
			aTitulos[1] := "Produtos com saldo menor que estoque mínimo em "+dtoc(dDataBase)
			aTitulos[2] := "Produtos com saldo maior que estoque máximo em "+dtoc(dDataBase)
			aTitulos[3] := "Produtos sem movimentação a mais de 6 meses em "+dtoc(dDataBase)
			aTitulos[4] := "Saldos dos Produtos em "+dtoc(dDataBase)
		endif

		//Limpar variaveis aProd para não gerar erro
		aProd    := {{},{},{},{}}
		cTipo    := "%"+FormatIn(cMV_ZZTPEST,"|")+"%"
		cBlindC  := ""

		If Trim(aEmp[f,2])$cFiliais	.and. dZZ_JOBEST<dDataBase

			AtuPar("ZZ_JOBEST")

			BeginSql alias "PROD"
				Select SB2.R_E_C_N_O_ NUMREG
				From %Table:SB2% SB2, %Table:SB1% SB1
				Where	SB2.%NotDel% and B2_FILIAL = %xFilial:SB2% and
						SB1.%NotDel% and B1_FILIAL = %xFilial:SB1% and
						B2_COD = B1_COD and B1_TIPO IN %Exp:cTipo%
				Order by B2_COD
			EndSQL

			While (PROD->(!EOF()))
				SB2->(DbGoTo(PROD->NUMREG))
				cPadrao  := Posicione("SB1",1,xFilial("SB1")+SB2->B2_COD,"B1_TIPO+IIf(Left(B1_COD,5)=='09A20','/ PADRAO','')")
				cControl := SB1->(IIf(B1_GRUPO=='G001','EXERCITO',IIF(B1_GRUPO=='G002','POL.FEDERAL','')))
				Posicione("SB3",1,xFilial("SB3")+SB2->B2_COD,"")
				GetSD3()
				GetSD2()
				GetSC7()
				//GetSC1()
				if SB2->B2_QATU < SB1->B1_EMIN
					AADD(aProd[1],{Trim(SB1->B1_COD),Trim(SB1->B1_DESC),SB1->B1_ZZCLABC,SB1->B1_UM,SB2->B2_LOCAL,SB2->B2_QATU,SB2->B2_CM1,SB2->(B2_QATU*B2_CM1),dUltMov,nQtdMov,nCCMov,nQuantPC,cPed,cForn,dProxima,nQtdEnt,SB3->B3_MEDIA,SB1->B1_ESTSEG,SB1->B1_EMIN,SB1->B1_EMAX,cPadrao,cControl})
				endif
				if SB2->B2_QATU > SB1->B1_EMAX .and. SB1->B1_EMAX > 0
					AADD(aProd[2],{Trim(SB2->B2_COD),Trim(SB1->B1_DESC),SB1->B1_ZZCLABC,SB1->B1_UM,SB2->B2_LOCAL,SB2->B2_QATU,SB2->B2_CM1,SB2->(B2_CM1*B2_QATU),dUltMov,nQtdMov,nCCMov,nQuantPC,cPed,cForn,dProxima,nQtdEnt,SB3->B3_MEDIA,SB1->B1_ESTSEG,SB1->B1_EMIN,SB1->B1_EMAX,cPadrao,cControl})
				endif
				If dUltMOv+180<dDataBase .and. !Empty(dUltMov) .and. SB2->B2_QATU > 0
					AADD(aProd[3],{Trim(SB2->B2_COD),Trim(SB1->B1_DESC),SB1->B1_ZZCLABC,SB1->B1_UM,SB2->B2_LOCAL,SB2->B2_QATU,SB2->B2_CM1,SB2->(B2_QATU*B2_CM1),dUltMOv,nQtdMov,nCCMov,nQuantPC,cPed,cForn,dProxima,nQtdEnt,SB3->B3_MEDIA,SB1->B1_ESTSEG,SB1->B1_EMIN,SB1->B1_EMAX,cPadrao,cControl})
				Endif
				AADD(aProd[4],{Trim(SB2->B2_COD),Trim(SB1->B1_DESC),SB1->B1_ZZCLABC,SB1->B1_UM,SB2->B2_LOCAL,SB2->B2_QATU,SB2->B2_CM1,SB2->(B2_QATU*B2_CM1),dUltMOv,nQtdMov,nCCMov,nQuantPC,cPed,cForn,dProxima,nQtdEnt,SB3->B3_MEDIA,SB1->B1_ESTSEG,SB1->B1_EMIN,SB1->B1_EMAX,cPadrao,cControl})
				PROD->(DbSkip())
			End

			PROD->(DbCloseArea())
			makedir("\JobEst\")
			For i:=1 to Len(aArq)
				cHtml := "<HTML>"
				cHtml += "<Br><h3>"+aTitulos[i]+"</h3><Br>"
				cHtml += "<Br><h3>Empresa/Filial :"+SM0->(cEmpAnt+'/'+cFilAnt+' '+Trim(M0_NOMECOM))+"</h3><Br>"
				If "TESTE"$Upper(GetEnvServer())
					cHtml += '<h1 style="color:Red;">E-mail enviado pela base de teste, desconsiderar esses saldos!</h1>'
				Endif
				cHtml += "</HTML>"
				cArquivo := "\Jobest\"+cempant+cfilant+aArq[i]
				If File(cArquivo)
					fErase(cArquivo)
				Endif
				If Len(aProd[i])>0 .and. !Empty(aProd[i])
					Arr2XLS(aCabProd[i],aProd[i],cArquivo,aTitulos[i])
					U_SndMail(,,,cEmail,,cBlindC,aTitulos[i],cHtml,cArquivo)
				Endif
			Next
		EndIf
		RpcClearEnv()
	Next

Return .T.

Static Function PegaParam(cFiliais, cMV_ZZTPEST,dZZ_JOBEST, cEmail)

	cFiliais 	:= GetMV("ZZ_EMFIJOB")	//Quais filiais
	cMV_ZZTPEST	:= GetMV("MV_ZZTPEST")	//Tipos de produtos
	dZZ_JOBEST	:= SuperGetMV("ZZ_JOBEST",.T.,"31/12/2049")	//Ultima data executado o JOBEST
	cEmail  	:= SuperGetMV("ZZ_EMJOB01",.T.,"")//Quais emails enviar (por filial)
	cEmail 		+= iif(!Empty(SuperGetMV("ZZ_EMJOB02")),";"+SuperGetMV("ZZ_EMJOB02"),"")//Quais emails enviar (por filial)

Return

Static Function AtuPar(cParJob)

	PutMV(cParJob,dtoc(dDataBase))

Return

//envia email com anexo
User Function SndMail(cSmtp,cConta,cPass,cDest,cCopia,cBlindC,cAssunto,cTexto,cAnexo,lAut)
	Local lOk
	Default cSmtp  := GetMV("MV_RELSERV")
	Default cConta := GetMV("MV_RELACNT")
	Default cPass  := GetMV("MV_RELPSW")
	Default lAut   := GETMV("MV_RELAUTH")
	Default cAssunto := "Sem Assunto"
	Default cAnexo   := ""
	Default cTexto   := ""
	Default cCopia   := ""
	Default cBlindc  := ""
	cConta := iif(cConta == "               <>", GetMV("MV_RELACNT"), cConta)
	CONNECT SMTP SERVER cSMTP ACCOUNT cConta PASSWORD cPass RESULT lOK
	VldMail("Connect")
	If lOk
		If lAut
			lOK := MailAuth(Alltrim(cConta),AllTrim(cPass))
			VldMail("Authentication")
		Endif
		If lOk
			Send Mail From cConta to cDest CC cCopia BCC cBlindc Subject cAssunto Body cTexto Attachment cAnexo Result lOk
			VldMail("Send Mail")
			DISCONNECT SMTP SERVER
			VldMail("Disconnect")
		Endif
	Endif

Return(lOk)


//Exibe mensagem de erro em um dos processos: conexão, autenticação, envio ou desconexão.
Static Function VldMail(x)
	Local cMsg
	GET MAIL ERROR cMsg
	If !"FULLY"$Upper(cMsg)
		MsgInfo(x+"-"+cMsg+" "+Time(),"EnvMail")
	Endif
Return

Static Function GetSC7
	BeginSql alias "C7"
		Column PROXENTREGA as Date
		Select
		 	C7_NUM	'NUMPC',
			C7_FORNECE 'FORN',
			C7_LOJA 'LOJA',
			C7_DATPRF 'PROXENTREGA',
			SUM(C7_QUANT-C7_QUJE) 'QTDAB'
		From %Table:SC7%
		Where 	%NotDel% and C7_FILIAL = %xFilial:SC7% and
				C7_ENCER <> ' E' and
				C7_RESIDUO <> 'S' and
				C7_QUANT > C7_QUJE and
				C7_CONAPRO = 'L' and
				C7_PRODUTO = %EXP:SB2->B2_COD%  and
                C7_LOCAL = %Exp:SB2->B2_LOCAL%
		Group by C7_NUM, C7_FORNECE, C7_LOJA, C7_DATPRF
		Order by 4
	EndSql
	cPed:=cForn:=""
	nQuantPC := 0
	nQtdEnt  := C7->QTDAB
	dProxima := C7->PROXENTREGA
	While C7->(!Eof())
		nQuantPC += C7->QTDAB
		cPed += C7->(IIf(NUMPC$cPed,"",IIf(Empty(cPed),"","/ ")+NUMPC))
		cForn += C7->(IIf(FORN+LOJA$cForn,"",IIf(Empty(cForn),"","/ ")+FORN+LOJA))
		C7->(DbSkip())
	End
	cForn := Posicione("SA2",1,xFilial("SA2")+cForn,"AllTrim(A2_NOME)")
	C7->(DbCloseArea())
Return

Static Function GetSC1
	BeginSql Alias "C1"
		Select Distinct C1_NUM, Sum(C1_QUANT-C1_QUJE) QTDSC
		From %Table:SC1%
		Where %NotDel% and C1_FILIAL = %xFilial:SC1% and
			C1_PRODUTO = %Exp:SB2->B2_COD% and C1_APROV = 'L' and
			C1_QUANT > C1_QUJE and C1_RESIDUO <> 'S'
		Group By C1_NUM
		Order By C1_NUM
	EndSql
	cSolic := ""
	nQuantSC:=0
	While C1->(!Eof())
		cSolic   += IIf(Empty(cSolic),"","/ ")+C1->C1_NUM
		nQuantSC += C1->QTDSC
		C1->(DbSkip())
	End
	C1->(DbCloseArea())
Return

Static Function Arr2XLS(aCab,aItens,cFile,cTable)
	Local oExcel := FwMsExcel():New()
	Local cPlan  := "plan1"
	Local i, nAlign, nType
	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan,cTable)
	For i:=1 to Len(acab)
		If ValType(aItens[1,i]) == "D"
			nAlign := 2
			nType  := 4
		ElseIf ValType(aItens[1,i]) == "N"
			nAlign := 3
			nType  := 2
		Else
			nAlign := 1
			nType  := 1
		Endif
		oExcel:AddColumn(cPlan,cTable,aCab[i],nAlign,nType,.f.)
	Next
	For i:=1 to Len(aItens)
		oExcel:AddRow(cPlan,cTable,aItens[i])
	Next
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
Return

Static Function GetSD3
	dUltMov:= ctod("//")
	BeginSql Alias "D3"
		Column ULTIMA as Date
		Select TOP 1 D3_QUANT QTDMOV, D3_CC CCMOV, Max(D3_EMISSAO) ULTIMA
		From %Table:SD3%
		Where %NotDel% and D3_FILIAL = %xFilial:SD3% and D3_COD = %Exp:SB2->B2_COD% and D3_ESTORNO <> 'S'  and D3_LOCAL = %Exp:SB2->B2_LOCAL%
		Group by D3_QUANT, D3_CC
		Order by Max(D3_EMISSAO) DESC
	EndSql
	dUltMov := D3->ULTIMA
	nQtdMOv := D3->QTDMOV
	nCCMov	:= D3->CCMOV
	D3->(DbCloseArea())
Return

Static Function GetSD2
	BeginSql Alias "D2"
		Column ULTIMA as Date
		Select TOP 1 D2_QUANT QTDMOV, D2_CCUSTO CCMOV, Max(D2_EMISSAO) ULTIMA
		From %Table:SD2% SD2
        Inner Join %Table:SF4% SF4 on SF4.%Notdel% and SD2.D2_TES = SF4.F4_CODIGO and SF4.F4_PODER3 = 'N'
		Where SD2.%NotDel% and D2_FILIAL = %xFilial:SD2% and D2_COD = %Exp:SB2->B2_COD% and D2_LOCAL = %Exp:SB2->B2_LOCAL%
		Group by D2_QUANT, D2_CCUSTO
		Order by Max(D2_EMISSAO) DESC
	EndSql
	if !Empty(D2->ULTIMA)
		if D2->ULTIMA > dUltMOv
			dUltMov := D2->ULTIMA
			nQtdMOv := D2->QTDMOV
			nCCMov	:= D2->CCMOV
		endif
	endif
	D2->(DbCloseArea())
Return
