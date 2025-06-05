#include "totvs.ch"   
/*/{protheus.doc}rvarcal1
Relatório Variação Contas a Pagar
@author Sergio Braz
@since 14/05/2019
/*/
User Function RVarCal1
	If AskMe() 
		GetData()          
		Processa({|| ExpExcel()})
	Endif
Return

Static Function GetData
	BeginSql Alias "E2" 
		Select R_E_C_N_O_ NumReg
		From %Table:SE2%
		Where %NotDel% and E2_MOEDA<>1 and E2_SALDO <> 0 and E2_FILIAL Between %Exp:MV_PAR01% and %Exp:mv_par02% and
			E2_FORNECE+E2_LOJA Between %Exp:MV_PAR03+MV_PAR04% and %Exp:MV_PAR05+MV_PAR06% and
			E2_EMISSAO Between %Exp:MV_PAR07% and %Exp:MV_PAR08% and
			E2_VENCTO Between %Exp:MV_PAR09% and %Exp:MV_PAR10%
		Order by 
			E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA
	EndSql
Return

Static Function AskMe
	Local aPergs := {}                             
	AADD(aPergs,{1,"Da filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Ate filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Do Fornecedor ",CriaVar("A2_COD",.f.),,'.t.','SA2A','.T.',70,.F.})
	AADD(aPergs,{1,"Da Loja ",CriaVar("A2_LOJA",.f.),,'.t.',,'.T.',30,.F.})
	AADD(aPergs,{1,"Até Fornecedor ",CriaVar("A2_COD",.f.),,'.t.','SA2A','.T.',70,.F.})
	AADD(aPergs,{1,"Até Loja ",CriaVar("A2_LOJA",.f.),,'.t.',,'.T.',30,.F.})	
	AADD(aPergs,{1,"Da Dt. Emissão",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Até Dt.Emissão",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Da Dt. Vencto.",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Até Dt. Vencto.",ctod(''),,'.t.',,'.T.',60,.F.})	
Return ParamBox(aPergs,"Parametros",{})

Static Function ExpExcel
	Local oExcel := FWMSExcel():New()
	Local cFile := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local cFields := "E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,cNatureza,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_EMISSAO,"+;
				"E2_VENCTO,E2_VENCREA,E2_VALOR,E2_SALDO,(cvaltochar(E2_MOEDA)),cDescMoeda,E2_VLCRUZ,E2_TXMOEDA,E2_DTVARIA,E2_TXMDCOR,cConta,nVarCam"
	Local cTitles := "Filial,Pref.,Documento,Parc.,Tipo,Natureza,Desc.Natureza,Fornecedor,Loja,Razão Social,Emissao,"+;
				"Vencto.,Vencto.Real,Vr. Moeda Estr.,Sld.Moeda Estr.,Moeda,Desc.Moeda,Valor R$,Tx.Informada,Dt.Ult.Variação,Tx.Ult.Variação,Conta Contábil,Vr.Base p/Variação(R$)"
	Local aFields, aTitulos,aValores, oExcel
	Local cPlan  := "Variacao Conferência"
	Local cTable := "Contas a Pagar"
	Private cDescMoeda,cNatureza,cConta,nVarCam := 0
	cFields := StrTran(cFields,"E2_","SE2->E2_")
	aFields := StrToKarr(cFields,",")
	aTitles := StrToKarr(cTitles,",")
	Count to nRegs                             
	E2->(DbGoTop())
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
	While E2->(!Eof())
		SE2->(DbGoTo(E2->NUMREG))
		aValores := {} 
		cConta     := Posicione("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"AllTrim(A2_CONTA)")		
		cNatureza  := Posicione("SED",1,xFilial("SED")+SE2->E2_NATUREZ,"AllTrim(ED_DESCRIC)")
		cDescMoeda := AllTrim(GetMV("MV_MOEDA"+cValToChar(SE2->E2_MOEDA)))
		nVarCam    := SE2->(IIF(Empty(E2_DTVARIA),E2_VLCRUZ,E2_SALDO * E2_TXMDCOR))
		For i:=1 to Len(aFields)
			AADD(aValores,&(aFields[i]))
		Next
		oExcel:AddRow(cPlan,cTable,aValores)
		E2->(DbSkip())
		IncProc()
	End  
	E2->(DbCloseArea())
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	If File(cFile)
		ShellExecute("Open",cFile,"","",1)
	Endif
Return

User Function vvv  
	RpcSetEnv("01","0100","admin","agis3","FIN")
	define msdialog omainwnd from 0,0 to 800,1300 pixel
	@ 05,05 button "cal1" of omainwnd pixel action u_rvarcal1()
	@ 25,05 button "cal2" of omainwnd pixel action u_rvarcal2()
	activate msdialog omainwnd
Return