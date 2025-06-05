#include "totvs.ch"
/*/{protheus.doc}rvarcal2
Relatorio variação contas a receber
@author Sergio Braz 
@since 14/05/2019
/*/
User Function RVarCal2
	If AskMe() 
		GetData()          
		Processa({|| ExpExcel()})
	Endif
Return

Static Function GetData
	BeginSql Alias "E1" 
		Select R_E_C_N_O_ NumReg
		From %Table:SE1%
		Where %NotDel% and E1_MOEDA<>1 and E1_SALDO <> 0 and E1_FILIAL Between %Exp:MV_PAR01% and %Exp:mv_par02% and
			E1_CLIENTE+E1_LOJA Between %Exp:MV_PAR03+MV_PAR04% and %Exp:MV_PAR05+MV_PAR06% and
			E1_EMISSAO Between %Exp:MV_PAR07% and %Exp:MV_PAR08% and
			E1_VENCTO Between %Exp:MV_PAR09% and %Exp:MV_PAR10%
		Order by 
			E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA
	EndSql
	//MemoWrite("D:\QUERY02.TXT",GetLastQuery()[2])
Return

Static Function AskMe
	Local aPergs := {}                             
	AADD(aPergs,{1,"Da filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Ate filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Do Cliente",CriaVar("A1_COD",.f.),,'.t.','SA1','.T.',70,.F.})
	AADD(aPergs,{1,"Da Loja ",CriaVar("A1_LOJA",.f.),,'.t.',,'.T.',30,.F.})
	AADD(aPergs,{1,"Até Cliente",CriaVar("A1_COD",.f.),,'.t.','SA1','.T.',70,.F.})
	AADD(aPergs,{1,"Até Loja ",CriaVar("A1_LOJA",.f.),,'.t.',,'.T.',30,.F.})	
	AADD(aPergs,{1,"Da Dt. Emissão",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Até Dt.Emissão",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Da Dt. Vencto.",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Até Dt. Vencto.",ctod(''),,'.t.',,'.T.',60,.F.})	
Return ParamBox(aPergs,"Parametros",{})

Static Function ExpExcel
	Local oExcel := FWMSExcel():New()
	Local cFile := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local cFields := "E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,cNatureza,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_EMISSAO,"+;
				"E1_VENCTO,E1_VENCREA,E1_VALOR,E1_SALDO,(cvaltochar(E1_MOEDA)),cDescMoeda,E1_VLCRUZ,E1_TXMOEDA,E1_DTVARIA,E1_TXMDCOR,cConta,nVarCam"
	Local cTitles := "Filial,Pref.,Documento,Parc.,Tipo,Natureza,Desc.Natureza,Fornecedor,Loja,Razão Social,Emissao,"+;
				"Vencto.,Vencto.Real,Valor,Saldo Moeda Estr.,Moeda,Desc.Moeda,Valor R$,Tx.Informada,Dt.Ult.Variação,Tx.Ult.Variação,Conta Contábil,Vr.Base p/Variação(R$)"
	Local aFields, aTitulos,aValores, oExcel
	Local cPlan  := "Variacao"
	Local cTable := "Contas a Receber"
	Private cDescMoeda,cNatureza,cConta,nVarCam := 0
	cFields := StrTran(cFields,"E1_","SE1->E1_")
	aFields := StrToKarr(cFields,",")
	aTitles := StrToKarr(cTitles,",")
	Count to nRegs 
	E1->(DbGoTop())
	ProcRegua(nRegs)
	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan,cTable)
	For i:=1 To Len(aFields)
		If ValType(&(aFields[i])) == "D"
			nAlign := 2
			nType  := 4
		ElseIf ValType(&(aFields[i])) == "N"
			nAlign := 3
			nType  := 2
		Else
			nAlign := 1
			nType  := 1
		Endif
		oExcel:AddColumn(cPlan,cTable,aTitles[i],nAlign,nType,.f.)
	Next
	While E1->(!Eof())
		SE1->(DbGoTo(E1->NUMREG))
		aValores := {} 
		cConta     := Posicione("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"AllTrim(A1_CONTA)")		
		cNatureza  := Posicione("SED",1,xFilial("SED")+SE1->E1_NATUREZ,"AllTrim(ED_DESCRIC)")
		cDescMoeda := AllTrim(GetMV("MV_MOEDA"+cValToChar(SE1->E1_MOEDA)))
		nVarCam    := SE1->(IIF(Empty(E1_DTVARIA),E1_VLCRUZ,E1_SALDO * E1_TXMDCOR))
		For i:=1 to Len(aFields)
			AADD(aValores,&(aFields[i]))
		Next
		oExcel:AddRow(cPlan,cTable,aValores)
		E1->(DbSkip())
		IncProc()
	End  
	E1->(DbCloseArea())
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	If File(cFile)
		ShellExecute("Open",cFile,"","",1)
	Endif
Return