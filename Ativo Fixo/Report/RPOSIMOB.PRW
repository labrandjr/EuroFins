#include "totvs.ch"
/*/{protheus.doc} RPosImob
Relatório de Posição do Ativo Imobilizado Analítico
@author Sergio Braz
@since 23/08/2019
/*/

User Function RPosImob
	Private nRegs
	If AskMe()         
		GetQry()		
		Processa({|| ExpExcel()})
	Endif
Return

Static Function AskMe
	Local aPergs := {}                             
	AADD(aPergs,{1,"Da filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Ate filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Da Data Aquisição",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Até Data Aquisição",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Do Bem ",CriaVar("N1_CBASE",.f.),,'.t.',,'.T.',60,.F.})               
	AADD(aPergs,{1,"Até Bem ",CriaVar("N1_CBASE",.f.),,'.t.',,'.T.',60,.F.})               
	AADD(aPergs,{1,"Do Item ",CriaVar("N1_ITEM",.f.),,'.t.',,'.T.',60,.F.})               
	AADD(aPergs,{1,"Até Item ",CriaVar("N1_ITEM",.f.),,'.t.',,'.T.',60,.F.})               
	AADD(aPergs,{1,"Do Grupo",CriaVar("N1_GRUPO",.f.),,'.t.','SNG','.T.',60,.F.})               
	AADD(aPergs,{1,"Até Grupo ",CriaVar("N1_GRUPO",.f.),,'.t.','SNG','.T.',60,.F.})               
Return ParamBox(aPergs,"Parametros",{})

Static Function ExpExcel
	Local oExcel := FWMSExcel():New()
	Local cFilOld := cFilAnt
	Local cFile := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local aFields, aTitulos,aValores
	Local cFields:="N1_FILIAL;N1_GRUPO;NG_DESCRIC;N1_CBASE;N1_ITEM;N1_AQUISIC;N1_DESCRIC;N1_NFISCAL;N1_FORNEC;N1_LOJA;A2_NOME;N3_TIPO;cTipoAtivo;N3_DINDEPR;"+;
		"N3_DTBAIXA;N4_VLROC1;N4_MOTIVO;cMotivo;N3_VORIG1;N3_VRDACM1;N3_VORIG1-SN3->N3_VRDACM1;N3_VRDMES1;N3_TXDEPR1;N3_CCDESP;cDescCC;N3_CCONTAB;cContaCont;"+;
		"N3_CCDEPR;cContaDepr;N3_CDEPREC;cDespDepr"
	Local cTitulos := "Filial;Grupo;Descrição do Grupo;Código do Bem;Item;Aquisição;Descrição do Bem;Nota Fiscal;Fornecedor;Loja;Razão Social;Tipo Ativo;Desc.Tipo;Ini.Depreciação;"+;
		"Baixa;Valor Baixa;Motivo Movimentação;Desc.Motivo;Valor Aquisição;Depreciação Acumulada;Valor Residual;Depreciação Mês;Taxa Depreciação;C.Custo Deprec.;Desc. C.Custo;"+;
		"Conta Contábil;Desc.Cnt.Cont.;Conta Depreciação;Desc.Conta;Conta Des.Deprec;Desc. Conta Desp."
	Local cPlan  := "Ativo Imobilizado"
	Local cTable := "Posição do Ativo Imobilizado Analítico"     
	Local lFirst := .t.                   
	Private cTipoAtivo,cDescCC,cContaCont,cContaDepr,cDespDepr,cMotivo
	aTitulos := StrToKarr(cTitulos,";")
	aFields  := StrToKarr(cFields,";")
	ProcRegua(nRegs)
	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan,cTable)
 	While N1->(!Eof())
 		SN1->(DbGoTo(N1->NUMREG)) 
 		cFilAnt := SN1->N1_FILIAL
		Posicione("SNG",1,xFilial("SNG")+SN1->N1_GRUPO,"")
		Posicione("SN3",1,xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM),"")
		Posicione("SN4",1,xFilial("SN4")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO+DTOS(N3_AQUISIC)+"01"),"")
		Posicione("SA2",1,xFilial("SA2")+SN1->(N1_FORNEC+N1_LOJA),"") 	 
		GEtN4()
		cMotivo    := RetField("SX5",1,xFilial("SX5")+"16"+SN4->N4_MOTIVO,"X5_DESCRI")
		cTipoAtivo := RetField("SX5",1,xFilial("SX5")+"G1"+SN3->N3_TIPO,"X5_DESCRI")
		cDescCC    := RetField("CTT",1,xFilial("CTT")+SN3->N3_CCDESP,"CTT_DESC01")
		cContaCont := RetField("CT1",1,xFilial("CT1")+SN3->N3_CCONTAB,"CT1_DESC01")
		cContaDepr := RetField("CT1",1,xFilial("CT1")+SN3->N3_CCDEPR,"CT1_DESC01")
		cDespDepr  := RetField("CT1",1,xFilial("CT1")+SN3->N3_CDEPREC,"CT1_DESC01")
		If lFirst                                         
			For i:=1 To Len(aFields)
				If "_"$aFields[i]
					If At("_",aFields[i])==3
						aFields[i] := "S"+Left(aFields[i],2)+"->"+aFields[i]
					Else                                         
					    aFields[i] := Left(aFields[i],3)+"->"+aFields[i]
					Endif
				Endif
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
				oExcel:AddColumn(cPlan,cTable,aTitulos[i],nAlign,nType,.f.)
			Next 
			lFirst := .f.    
		Endif
		aValores := {} 
		For i:=1 to Len(aFields)
			AADD(aValores,&(aFields[i]))
		Next
		oExcel:AddRow(cPlan,cTable,aValores)
		N1->(DbSkip())
		IncProc() 
	End 
	N1->(DbCloseArea())
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	cFilAnt := cFilOld
	If File(cFile)
		ShellExecute("Open",cFile,"","",1)
	Endif
	
Return

Static Function GetQry
	BeginSql Alias "N1"
		Select Count(*) CONTADOR
		From %Table:SN1% SN1
		Where %NotDel% and N1_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02% and
			N1_AQUISIC Between %Exp:MV_PAR03% and %Exp:MV_PAR04% and N1_CBASE Between %Exp:MV_PAR05% and %Exp:MV_PAR06% and
			N1_ITEM Between %Exp:MV_PAR07% and %Exp:MV_PAR08% and N1_GRUPO Between %Exp:MV_PAR09% and %Exp:MV_PAR10%
	EndSql                      
	nRegs := N1->CONTADOR                   	
	N1->(DbCloseArea())  
	BeginSql Alias "N1"
		Select R_E_C_N_O_ NUMREG
		From %Table:SN1%
		Where %NotDel% and N1_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02% and
			N1_AQUISIC Between %Exp:MV_PAR03% and %Exp:MV_PAR04% and N1_CBASE Between %Exp:MV_PAR05% and %Exp:MV_PAR06% and
			N1_ITEM Between %Exp:MV_PAR07% and %Exp:MV_PAR08% and N1_GRUPO Between %Exp:MV_PAR09% and %Exp:MV_PAR10%
		Order by N1_FILIAL,N1_CBASE,N1_ITEM
	EndSql                      	
Return

User Function TstRel
RpcSetEnv("01","0100","Admin","agis4","FIS")
U_RPosImob()
Return

Static Function GetN4
	Local aArea := GetArea()
	BeginSql Alias "N4"
		SELECT SN4.R_E_C_N_O_ NUMREG
		FROM %Table:SN4% SN4, %Table:SN3% SN3
		WHERE SN4.%NotDel% AND N4_OCORR='01' AND  N3_CBASE=N4_CBASE AND N3_ITEM=N3_ITEM AND N4_TIPO=N3_TIPO AND N3_FILIAL=N4_FILIAL AND SN3.%NotDel% and
		N3_CBASE=%Exp:SN3->N3_CBASE% and N3_ITEM = %Exp:SN3->N3_ITEM% and N3_TIPO=%Exp:SN3->N3_TIPO% 
	EndSql    
	SN4->(DbGoTo(N4->NUMREG))
	N4->(DbCloseArea())
	RestArea(aArea)
Return 

user function exp
rpcsetenv("01","0100","admin","agis4","EST")
beginsql alias "tt"
	SELECT SN4.N4_CBASE, SN4.N4_ITEM, SN4.N4_TIPO, SN4.N4_OCORR,
	       SN3.N3_VORIG1 AS AQUISIC,
	       SN3.N3_VRDACM1 AS ACUMUL
	FROM SN1010 SN1
	LEFT JOIN SNG010 SNG ON SNG.NG_GRUPO = SN1.N1_GRUPO
	AND SNG.D_E_L_E_T_ = ' '
	LEFT JOIN SN3010 SN3 ON SN3.N3_FILIAL = SN1.N1_FILIAL
	AND SN3.N3_CBASE = SN1.N1_CBASE
	AND SN3.N3_ITEM = SN1.N1_ITEM
	AND SN3.D_E_L_E_T_ = ' '
	LEFT JOIN SN4010 SN4 ON SN4.N4_FILIAL = SN3.N3_FILIAL
	AND SN4.N4_CBASE = SN3.N3_CBASE
	AND SN4.N4_ITEM = SN3.N3_ITEM
	AND SN4.N4_TIPO = SN3.N3_TIPO
	AND SN4.N4_OCORR = '01'
	AND SN4.D_E_L_E_T_ = ' '
	WHERE SN1.D_E_L_E_T_ = ' ' 
	  AND SN1.N1_GRUPO <> ' '
	  AND LEFT(SN1.N1_FILIAL,2) = '01'
	  AND SN1.N1_AQUISIC <= '20190731'
endsql             
copy to \tempor01
memowrite("x:\result.csv",str(VLRAQUIS,14,2)+";"+str(DEPACUMUL,14,4)+";"+str(VLRRESID,14,2))
winexec("x:\result.csv")
return
