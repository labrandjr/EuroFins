#include "totvs.ch"
/*/{protheus.doc} RelFin99
Planilhas financeiras
@author Sergio Braz
@since 14/05/2019/*/
User Function RelFin99
	Private aQry  := {}
	Private aPlan := {}
	If AskMe()         
		GetQry()		
		Processa({|| ExpExcel()})
	Endif
Return

Static Function AskMe
	Local aPergs := {}                             
	AADD(aPergs,{1,"Da filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Ate filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Da Data",ctod(''),,'.t.',,'.T.',60,.F.})
	AADD(aPergs,{1,"Até Data",ctod(''),,'.t.',,'.T.',60,.F.})
Return ParamBox(aPergs,"Parametros",{})

Static Function ExpExcel
	Local oExcel := FWMSExcel():New()
	Local cFile := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local aFields, aTitulos,aValores
	Local cPlan  
	Local cTable      
	Local i,p
	Local cTitle := ""
	ProcRegua(Len(aQry))
	For p := 1 to Len(aQry)
		DbUseArea(.t.,"TOPCONN",TcGenQry(,,aQry[p]),"ZZ",.f.,.f.)
		IIF("E5_DATA"$aQry[p]   ,TcSetField("ZZ","E5_DATA","D")   ,Nil)
		IIF("E5_DTDISPO"$aQry[p],TcSetField("ZZ","E5_DTDISPO","D"),Nil)
		oExcel:AddworkSheet(aPlan[p])
		oExcel:AddTable(aPlan[p],aPlan[p])
		For i:=1 To ZZ->(FCount())
			If ValType(FieldGet(i)) == "D"
				nAlign := 2
				nType  := 4
			ElseIf ValType(FieldGet(i)) == "N"
				nAlign := 3
				nType  := 2
			Else
				nAlign := 1
				nType  := 1
			Endif
			cTitle := alltrim(getSX3Cache(FieldName(i),"X3_TITULO"))
			if empty(cTitle)
				cTitle := FieldName(i)
				cTitle := strTran(cTitle,"_","")
			endif
			oExcel:AddColumn(aPlan[p],aPlan[p],cTitle,nAlign,nType,.f.)
		Next
		While ZZ->(!Eof())
			aValores := {} 
			For i:=1 to ZZ->(fCount())
				AADD(aValores,FieldGet(i))
			Next
			oExcel:AddRow(aPlan[p],aPlan[p],aValores)
			ZZ->(DbSkip())
		End 
		IncProc() 
		ZZ->(DbCloseArea())		
	Next
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	If File(cFile)
		ShellExecute("Open",cFile,"","",1)
	Endif
Return

Static Function GetQry
	AADD(aPlan,"Ativo imobilizado")
	AADD(aQry,Qry("*","CL2","Left(CL2_FILIAL,2) Between '"+Left(MV_PAR01,2)+"' and '"+Left(MV_PAR02,2)+"' AND CL2_PER Between '"+dtos(MV_PAR03)+"' and '"+dtos(MV_PAR04)+"' AND CL2_REG = 'F120'"))
	
	AADD(aPlan,"Ativos c/PIS")
	AADD(aQry,Qry("*","SN1","N1_CALCPIS = '1'"))
	
	AADD(aPlan,"Juros recebidos")
	AADD(aQry,Qry("E5_FILIAL,E5_RECPAG,E5_VLJUROS,(E5_VLJUROS+CASE WHEN E5_VLJUROS = 0 THEN E5_VALOR ELSE 0 END) AS TOT_JUROS,E5_VLMULTA,E5_VLDESCO,E5_VLCORRE,E5_VALOR,E5_NATUREZ,E5_DATA,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_DOCUMEN","SE5",;
		"E5_DATA Between '"+Dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND (E5_VLJUROS > 0 OR E5_NATUREZ = '0103002') AND E5_RECPAG = 'R' AND E5_TIPODOC <> 'ES' "+;
		"AND E5_SITUACA NOT IN ('X','C') AND NOT E5_TIPO IN ('NDF','PA') "))
	
	AADD(aPlan,"Multas recebidas")
	AADD(aQry,Qry("E5_FILIAL,E5_RECPAG,E5_VLJUROS,E5_VLMULTA,E5_VLDESCO,E5_VLCORRE,E5_VALOR,E5_NATUREZ,E5_DATA,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_DOCUMEN","SE5",;
		"E5_DATA Between '"+dtos(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND E5_VLMULTA > 0 AND E5_RECPAG = 'R' AND E5_SITUACA NOT IN ('X','C') "+;
		"AND NOT E5_TIPO IN ('NDF','PA') "))
	
	AADD(aPlan,"Descontos Obtidos")
	AADD(aQry,Qry("E5_FILIAL,E5_RECPAG,E5_VLJUROS,E5_VLMULTA,E5_VLDESCO,E5_VLCORRE,E5_VALOR,E5_NATUREZ,E5_DATA,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_DOCUMEN","SE5",;
		"E5_DATA Between '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND E5_VLDESCO > 0 AND E5_SITUACA NOT IN ('X','C') AND (( E5_RECPAG = 'P' AND E5_TIPO <> 'RA ')	OR	(E5_RECPAG = 'R' AND E5_TIPO IN ('PA ','NDF')))","E5_FILIAL,E5_RECPAG"))
	
	AADD(aPlan,"Correção sobre receber")
	AADD(aQry,Qry("E5_FILIAL,E5_RECPAG,E5_VLJUROS,E5_VLMULTA,E5_VLDESCO,E5_VLCORRE,E5_VALOR,E5_NATUREZ,E5_DATA,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_DOCUMEN","SE5",;
		"E5_DATA Between '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND E5_VLCORRE > 0 AND E5_RECPAG = 'R' AND E5_SITUACA NOT IN ('X','C')"))
	
	AADD(aPlan,"Rendimento AplicaÇÃo Financeira")
	AADD(aQry,Qry("E5_FILIAL,E5_RECPAG,E5_VLJUROS,E5_VLMULTA,E5_VLDESCO,E5_VLCORRE,E5_VALOR,E5_NATUREZ,E5_DATA,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_DOCUMEN","SE5",;
		"E5_DATA Between '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND E5_NATUREZ = '0103001' AND E5_SITUACA NOT IN ('X','C')"))
	
	AADD(aPlan,"Registro da Apuração")
	AADD(aQry,Qry("*","CL2","Left(CL2_FILIAL,2) Between '"+Left(MV_PAR01,2)+"' and '"+Left(MV_PAR02,2)+"' AND CL2_PER Between '"+dtos(MV_PAR03)+"' and '"+dtos(MV_PAR04)+"' AND CL2_REG = 'F100'"))
	
	AADD(aPlan,"Valores Retidos Recebimento")
	AADD(aQry,"SELECT E5_FILIAL, E5_DATA ,E5_VENCTO, E5_DTDISPO, E5_PREFIXO, E5_NUMERO, E5_TIPO, E5_PARCELA, E5_CLIFOR, E5_LOJA, RTRIM(A1_NOME), A1_CGC, A1_SIMPNAC, A1_RECCOFI, A1_RECPIS, A1_RECCSLL, E5_MOTBX, E5_TIPODOC, E5_VRETPIS, E5_VRETCOF, E5_VALOR "+;
		"FROM "+RetSqlName("SE5")+" SE5 LEFT JOIN "+RetSqlName("SA1")+" SA1 ON E5_CLIFOR = A1_COD AND E5_LOJA = A1_LOJA "+;
		"WHERE E5_FILIAL Between '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND E5_DATA Between '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' "+;
		"AND E5_SITUACA NOT IN ('C','X') AND E5_VRETPIS > 0 AND E5_RECPAG = 'R' AND SE5.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "+;
		"AND E5_MOTBX NOT IN ('DAC','CAN','DEV','PCL') AND E5_DTCANBX = ' '")
Return aQry

Static Function Qry(cSelect,cFrom,cWhere,cOrder)
	Local cQry 
	Local cW := " D_E_L_E_T_ = ' ' and "+cFrom+"."+IIf(Left(cFrom,1)=="S",Right(cFrom,2),cFrom)+"_FILIAL Between '"+MV_PAR01+"' and '"+MV_PAR02+"' and "
	Default cOrder := ""
	cQry := "Select "+cSelect+" From "+RetSqlName(cFrom)+" "+cFrom+" Where "+cW+cWhere+IIF(Empty(cOrder),""," Order By "+cOrder)
Return cQry 
