#include "totvs.ch"
/*/{protheus.doc}RNFFAT
Relação de Notas Faturadas por Pedido de Cliente
@author Sergio Braz
@since 24/10/2019
/*/
User Function RNFFat
	Iif(Type("cFilAnt")=="U",RpcSetEnv("01","0100","admin","agis4","EST"),Nil)
	If AskMe()
		Processa({|| GeraPlan()},"Aguarde! Gerando planilha...")
	Endif
Return

Static Function AskMe
	Local aPergs := {}
	AADD(aPergs,{1,"Da Filial",CriaVar("C6_FILIAL",.F.),"@!",".T.","SM0",".T.",40,.F.})
	AADD(aPergs,{1,"Da Filial",CriaVar("C6_FILIAL",.F.),"@!",".T.","SM0",".T.",40,.F.})
	AADD(aPergs,{1,"Da Data de Emissão",ctod(''),,".T.",,".T.",60,.F.})
	AADD(aPergs,{1,"Até Data de Emissão",ctod(''),,".T.",,".T.",60,.F.})
Return ParamBox(aPergs,"Parâmetros",{})

Static Function GeraPlan
	Local cOldFil := cFilAnt
	Local cFile := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local oExcel := FwMsExcel():New()
	Local aFields     := GetFields()
	Local cPlan  := "NF Faturadas de Pedidos"
	Local i,nAlign,nType
	Local aValores
	ProcRegua(GetData())
	oExcel:AddWorkSheet(cPlan)
	oExcel:AddTable(cPlan,cPlan)
	For i:=1 To Len(aFields)
		If ValType(&(aFields[i,1])) == "D"
			nAlign := 2
			nType  := 4
		ElseIf ValType(&(aFields[i,1])) == "N" 
			nAlign := 3
			nType  := 2
		Else
			nAlign := 1
			nType  := 1
		Endif
		oExcel:AddColumn(cPlan,cPlan,aFields[i,2],nAlign,nType,.f.)
	Next	
	While D2->(!Eof())
		SD2->(DbGoTo(D2->NUMREG))
		cFilAnt := SD2->D2_FILIAL
		Posicione("SF2",1,xFilial("SF2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA),"")
		Posicione("SC6",1,xFilial("SC6")+SD2->(D2_PEDIDO+D2_ITEMPV),"")
		Posicione("SA1",1,xFilial("SA1")+SD2->(D2_CLIENTE+D2_LOJA),"")
		aValores := {}
		For i:=1 to Len(aFields)
			AADD(aValores,&(aFields[i,1]))
		Next    
		oExcel:AddRow(cPlan,cPlan,aValores)		
		IncProc()
		D2->(DbSkip())
	End	
	D2->(DbCloseArea())
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	If File(cFile)
		If MsgYesNo("Abrir arquivo "+cFile)
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open(cFile)
			oExcel:SetVisible(.T.)			
		Endif	
	Endif	
	cFilAnt := cOldFil	
Return

Static Function GetData
	Local nRegs
	BeginSql Alias "D2"
		Select COUNT(*) NUMREG
		From %Table:SD2%
		Where %NotDel% and D2_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02% and 
			D2_EMISSAO Between %Exp:MV_PAR03% and %Exp:MV_PAR04% and
			D2_ESPECIE = 'SPED' and D2_TIPO = 'N'
	EndSql
	nRegs := D2->NUMREG
	D2->(DbCloseArea())
	BeginSql Alias "D2"
		Select R_E_C_N_O_ NUMREG
		From %Table:SD2%
		Where %NotDel% and D2_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02% and 
			D2_EMISSAO Between %Exp:MV_PAR03% and %Exp:MV_PAR04% and
			D2_ESPECIE <> 'SPED' and D2_TIPO = 'N'
		Order By D2_FILIAL, D2_DOC, D2_ITEM
	EndSql	
Return nRegs

Static Function GetFields
	Local aF := {}
	aadd(aF,{"SD2->D2_FILIAL" ,"Filial"})
	aadd(aF,{"SD2->D2_EMISSAO","Emissao"})
	aadd(aF,{"SD2->D2_SERIE"  ,"Serie"})
	aadd(aF,{"SD2->D2_DOC"    ,"Doc"})
	aadd(aF,{"SD2->D2_CLIENTE","Cliente"})
	aadd(aF,{"SD2->D2_LOJA"   ,"Loja"})
	aadd(aF,{"SA1->A1_NOME"   ,"Razao social"})
	aadd(aF,{"SC6->C6_NUM"    ,"Pedido protheus"})
	aadd(aF,{"SC6->C6_PEDCLI" ,"Pedido cliente"})
	aadd(aF,{"SF2->F2_ESPECIE","Espécie"})
	aadd(aF,{"SD2->D2_ITEM","Item NF"})
	aadd(aF,{"SC6->C6_PRODUTO","Produto"})
	aadd(aF,{"SC6->C6_DESCRI","Desc. Produto"})
	aadd(aF,{"SC6->C6_ZZEORIG","Origem Análise"})
	aadd(aF,{"SC6->C6_ZZNROCE","Núm. Certificado"})		
Return aF