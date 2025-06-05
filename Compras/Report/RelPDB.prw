#include "rwmake.ch"
#include "topconn.ch"


/*/{Protheus.doc} RelPDB
Geracao de Excel de PDB
@author Marcos Candido
@since 29/12/2017
/*/
User Function RelPDB
	Local aSays      := {}
	Local aButtons   := {}
	Local cCadastro  := OemToansi('Geração de planilha com dados para o relat?io PDB')
	Local lOkParam   := .F.
	Local cPerg      := PADR("RELPDB01",10) , aPergs := {}
	Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
	Local cMens      := OemToAnsi('A opção de Par?etros desta rotina deve ser acessada antes de sua execução!')
	
	AjustaSx1(cPerg,aPergs)
	
	aAdd(aSays,OemToAnsi('Este programa visa gerar uma planilha em Excel contendo informações '))
	aAdd(aSays,OemToAnsi('das compras realizadas no per?do indicado nos par?etros. Esses '))
	aAdd(aSays,OemToAnsi('dados servir? de base para formar o relat?io chamado PDB. '))
	aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
	aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| ProcGer()}),o:oWnd:End()),Aviso(OemToAnsi('Atenção!!!'), cMens , {'Ok'})) } } )
	aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch( cCadastro, aSays, aButtons,,220,430 ) // altura x largura

Return

Static Function ProcGer

	Local cTmpFile := ''
	Local cPath    := ' '
	Local cQuery   := ''
	Local nTotReg  := 0
	Local aInfo    := {}
	Local cCodPF   := " "
	
	cQuery := "SELECT SD1.D1_COD, SB1.B1_DESC, SB1.B1_UM, SD1.D1_FORNECE, SD1.D1_LOJA, SB1.B1_CONV, SD1.D1_QUANT, SD1.D1_TOTAL, SB1.B1_TIPO, SB1.B1_CODANT "
	cQuery += "FROM "+RetSqlName("SD1")+" SD1 INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = SD1.D1_COD "
	cQuery += "WHERE SD1.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' AND "
	cQuery += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
	cQuery += "SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cQuery += "SD1.D1_TIPO = 'N' AND "
	cQuery += "SD1.D1_DTDIGIT BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"' AND "
	cQuery += "SD1.D1_COD BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND "
	cQuery += "SD1.D1_TP BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
	cQuery += "SD1.D1_FORNECE BETWEEN '"+mv_par07+"' AND '"+mv_par09+"' AND "
	cQuery += "SD1.D1_LOJA BETWEEN '"+mv_par08+"' AND '"+mv_par10+"' "
	cQuery += "ORDER BY SD1.D1_COD,SD1.D1_DTDIGIT"
	
	If Select("TRR") > 0
	   dbSelectArea("TRR")
	   TRR->(dbCloseArea())
	Endif
	
	TCQUERY cQuery New Alias "TRR"
	
	dbSelectArea("TRR")
	TRR->(dbGoTop())
	nTotReg := Contar("TRR","!Eof()")
	TRR->(dbGoTop())
	
	ProcRegua(nTotReg)
	
	While TRR->(!Eof())
	
		IncProc("Organizando informações...")
	
		nLoc := aScan(aInfo , {|x| x[1] == TRR->D1_COD})
		If nLoc == 0
			dbSelectArea("SA5")
			dbSetOrder(1)
			If dbSeek(xFilial("SA5")+TRR->D1_FORNECE+TRR->D1_LOJA+TRR->D1_COD)
				cCodPF := SA5->A5_CODPRF
			Else
				cCodPF := " "
			Endif
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2")+TRR->D1_FORNECE+TRR->D1_LOJA)
			aadd(aInfo , {TRR->D1_COD, TRR->B1_DESC, TRR->B1_UM, TRR->D1_FORNECE, TRR->D1_LOJA, TRR->B1_CONV, TRR->D1_QUANT, TRR->D1_TOTAL, cCodPF, SA2->A2_NOME, TRR->B1_TIPO, TRR->B1_CODANT})
		Else
			dbSelectArea("SA5")
			dbSetOrder(1)
			If dbSeek(xFilial("SA5")+TRR->D1_FORNECE+TRR->D1_LOJA+TRR->D1_COD)
				cCodPF := SA5->A5_CODPRF
			Else
				cCodPF := " "
			Endif
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2")+TRR->D1_FORNECE+TRR->D1_LOJA)
			aInfo[nLoc][4]  := TRR->D1_FORNECE
			aInfo[nLoc][5]  := TRR->D1_LOJA
			aInfo[nLoc][7]  += TRR->D1_QUANT
			aInfo[nLoc][8]  += TRR->D1_TOTAL
			aInfo[nLoc][9]  := cCodPF
			aInfo[nLoc][10] := SA2->A2_NOME
			aInfo[nLoc][11] := TRR->B1_TIPO
		Endif
		dbSelectArea("TRR")
		TRR->(dbSkip())
	Enddo
	
	dbSelectArea("TRR")
	TRR->(dbCloseArea())
	
	oExcel := FWMSEXCEL():New()
	
	oExcel:AddworkSheet("Relatorio PDB")
	oExcel:AddTable ("Relatorio PDB","Relatorio PDB")
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","Supplier",1,1)  //10
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","Supplier Code",1,1) // 4 5
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","Product External Supplier Code",1,1)// 9
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","Local ERP Item Code",1,1) //1
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","Item Description",1,1)//2
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","UOM",1,1)//3
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","Packaging Quantity",1,1)//6
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","Quantity",1,1)//7
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","WAP",1,1)
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","TYPE",1,1)//11
	oExcel:AddColumn("Relatorio PDB","Relatorio PDB","Previous Code",1,1)//12
	
	ProcRegua(Len(aInfo))
	
	For nA:=1 To Len(aInfo)
		IncProc("Gerando planilha...")
		nWAP := aInfo[nA][8]/aInfo[nA][7]
		oExcel:AddRow("Relatorio PDB","Relatorio PDB",{aInfo[nA][10], aInfo[nA][4]+"-"+aInfo[nA][5], aInfo[nA][9], aInfo[nA][1], aInfo[nA][2], aInfo[nA][3], aInfo[nA][6], aInfo[nA][7] , nWap, aInfo[nA][11],aInfo[nA][12]})
	Next
	
	While cPath = " "
		cPath := cGetFile("\","Selecione Diretorio p/ Gravar os Arquivos",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
	Enddo
	
	oExcel:Activate()
	
	cTmpFile:=cPath+"PDB.xml"
	oExcel:GetXMLFile(cTmpFile)
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cTmpFile) 	// Abre a planilha
	oExcelApp:SetVisible(.T.) 			// Visualiza a planilha

Return

Static Function AcessaPar(cPerg,lOk)

	If Pergunte(cPerg)
		lOk := .T.
	Endif

Return(lOk)

Static Function AjustaSX1(cPerg,aPerg)
	Local aHelpPor := {}
	Local aAreaAtual := GetArea()
	Local aRegs := {}
	Local i,j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe a data inicial de digitação das ")
	aAdd(aHelpPor,"notas de entrada a ser considerada na ")
	aAdd(aHelpPor,"filtragem das informações que ser? ")
	aAdd(aHelpPor,"processadas.")
	Aadd(aRegs,{cPerg,"01","Da Data","","","mv_ch1","D",8 ,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe a data final de digitação das ")
	aAdd(aHelpPor,"notas de entrada a ser considerada na ")
	aAdd(aHelpPor,"filtragem das informações que ser? ")
	aAdd(aHelpPor,"processadas.")
	Aadd(aRegs,{cPerg,"02","Ate a Data","","","mv_ch2","D",8,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o c?igo do produto inicial a ")
	aAdd(aHelpPor,"ser considerada no processamento.")
	Aadd(aRegs,{cPerg,"03","Do Produto","","","mv_ch3","C",15,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
	
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o c?igo do produto final a ")
	aAdd(aHelpPor,"ser considerada no processamento.")
	Aadd(aRegs,{cPerg,"04","Ate o Produto","","","mv_ch4","C",15,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o Tipo de produto inicial a ")
	aAdd(aHelpPor,"ser considerado no processamento.")
	Aadd(aRegs,{cPerg,"05","Do Tipo","","","mv_ch5","C",02,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o Tipo de produto final a ")
	aAdd(aHelpPor,"ser considerado no processamento.")
	Aadd(aRegs,{cPerg,"06","Ate o Tipo","","","mv_ch6","C",02,0,1,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
	
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o C?igo inicial do Fornecedor ")
	aAdd(aHelpPor,"a ser considerado no processamento.")
	Aadd(aRegs,{cPerg,"07","Do Fornecedor","","","mv_ch7","C",06,0,1,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
	
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe a Loja inicial do Fornecedor ")
	aAdd(aHelpPor,"a ser considerada no processamento.")
	Aadd(aRegs,{cPerg,"08","Da Loja","","","mv_ch8","C",02,0,1,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o C?igo Final do Fornecedor ")
	aAdd(aHelpPor,"a ser considerado no processamento.")
	Aadd(aRegs,{cPerg,"09","Ate o Fornecedor","","","mv_ch9","C",06,0,1,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
	
	
	aHelpPor := {}
	aAdd(aHelpPor,"Informe a Loja final do Fornecedor ")
	aAdd(aHelpPor,"a ser considerada no processamento.")
	Aadd(aRegs,{cPerg,"10","Ate a Loja","","","mv_cha","C",02,0,1,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	
	RestArea(aAreaAtual)

Return