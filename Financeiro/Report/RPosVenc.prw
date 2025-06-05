#include "totvs.ch"   
/*/{protheus.doc}RPOSVENC
Relatório de Posição dos títulos por vencimento
@author Sergio Braz
@since 22/10/2019
/*/
User Function RPosVenc  
	IIf(Type('cFilAnt')=="U",rpcsetenv("01","0101","admin","agis4","EST"),Nil)
	If AskMe()                                  
		GetData()
		Processa({|| GeraPlan()},"Aguarde! Gerando planilha.")
		E1->(DbCloseArea())
	EndIf
Return

Static Function GetData   
	BeginSql Alias "E1"
		Column E1_EMISSAO as Date
		Column E1_VENCTO as Date
		Column E1_VENCREA as Date
		Column E1_DTVARIA as Date
		Column E1_BAIXA as Date
		SELECT *
		FROM %Table:SE1%
		WHERE %NotDel% and E1_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02%
		AND E1_VENCREA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		ORDER BY E1_FILIAL,E1_VENCREA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO
	EndSql
Return                

Static Function AskMe
	Local aPergs := {}
	AADD(aPergs,{1,"Da Filial"     ,CriaVar("E1_FILIAL",.f.),"@!",'.t.','SM0','.T.',60,.F.})
	AADD(aPergs,{1,"Até Filial"    ,CriaVar("E1_FILIAL",.f.),"@!",'.t.','SM0','.T.',60,.F.})
	AADD(aPergs,{1,"Do Vencimento" ,ctod(""),,'.t.',,'.T.',80,.F.})
	AADD(aPergs,{1,"Até Vencimento",ctod(""),,'.t.',,'.T.',80,.F.})
Return ParamBox(aPergs,"Parâmetros",{})

Static Function GeraPlan                                                                                                                               
	Local i,j,aValores,nRegs,nAlign,nType
	Local cFile := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local oExcel  := FwMsExcel():New()
	Local cPlan                          
	Local cTitulo
	Local aFields := StrToKarr("E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,E1_PORTADO,E1_SITUACA,E1_NUMBCO,E1_CLIENTE,E1_LOJA,CNPJ,E1_NOMCLI,"+;
		"E1_EMISSAO,E1_VENCTO,E1_VENCREA,Moeda,E1_VALOR,E1_VLCRUZ,E1_SALDO,E1_TXMOEDA,E1_TXMDCOR,E1_DTVARIA,E1_IRRF,E1_PIS,E1_COFINS,E1_CSLL,E1_ISS,"+;
		"E1_ACRESC,E1_SDACRES,E1_DECRESC,E1_SDDECRE,E1_DESCONT,E1_JUROS,E1_BAIXA",",")
	Private Moeda := ""
	Private CNPJ := ""
	Count to nRegs
	E1->(DbGoTop()) 
	ProcRegua(nRegs)                    
	cPlan := "Títulos por vencimento real"
	oExcel:AddWorksheet(cPlan)
	oExcel:AddTable(cPlan,cPlan)
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
		cTitulo := RetField("SX3",2,aFields[i],"Trim(X3_TITULO)")
		cTitulo := IIf(Empty(cTitulo),aFields[i],cTitulo)
		oExcel:AddColumn(cPlan,cPlan,cTitulo,nAlign,nType,.f.)
	Next
	ProcRegua(nRegs)
	While E1->(!Eof()) 	                    
		aValores := {}
		Moeda := cValToChar(E1->E1_MOEDA)+"-"+GetMV("MV_MOEDA"+cValToChar(E1->E1_MOEDA))
		CNPJ := Posicione("SA1",1,xFilial("SA1")+E1->E1_CLIENTE+E1->E1_LOJA,"A1_CGC")
		For i:=1 to Len(aFields)
			If "CNPJ"$aFields[i]
				If Len(Alltrim(CNPJ))==11
					AADD(aValores,Transform(CNPJ, "@R 999.999.999-99" ))
				Else
					AADD(aValores,TransForm(CNPJ,"@R 99.999.999/9999-99" ))
				Endif
			Else
				AADD(aValores,&(aFields[i]))
			endif
		Next    
		oExcel:AddRow(cPlan,cPlan,aValores)		
		E1->(DbSkip())
		IncProc()
	End                 
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	If File(cFile)
		If MsgYesNo("Abrir arquivo "+cFile)
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open(cFile)
			oExcel:SetVisible(.T.)			
		Endif	
	Endif	
Return

