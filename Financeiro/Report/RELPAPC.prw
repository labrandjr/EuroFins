#Include "totvs.ch"
#Include "topconn.ch"

/*/{protheus.doc}
Gera Planilha Excel referente a Pagamentos Antecipados x Pedidos de compras
@author Régis Ferreira
@since 05/11/2021
/*/
User Function RELPAPC
	Local aParambox	:= {}
	aAdd(aParamBox,{1,"Emissão PC de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
	aAdd(aParamBox,{1,"Emissão PC até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02
	aAdd(aParamBox,{1,"Filial de:"			,CriaVar("FIE_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR03
	aAdd(aParamBox,{1,"Filial até:"			,CriaVar("FIE_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR04

	If ParamBox(aParamBox,"Pagamento Antecipado x Pedido de Compras",,,,,,,,ProcName(),.T.,.T.)
		Processa({||GeraPlan() },"Gerando Planilha..." )
	Endif
Return

Static Function GeraPlan

	Local lErro		 := .F.
	Local nRegs
	Local cArqNome	 := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local cTitulo	 := "Pagamento Antecipado x Pedido de Venda"
	Local nTot 		 := 0
	Local cEncerrado := "ENCERRADO"
	Local cResiduo 	 := "SIM"
	Private cNaturez, cNatured, aValores

	BeginSql Alias "PAPC"
		select DISTINCT 
			FIE_FILIAL, 
			C7_EMISSAO,
			FIE_PEDIDO, 
			C7_ZZCCOUP, 
			FIE_NUM, 
			FIE_FORNEC, 
			FIE_LOJA, 
			A2_NOME, 
			FIE_VALOR, 
			FIE_SALDO, 
			C7_ENCER, 
			C7_RESIDUO
		From 
			%Table:FIE% FIE
			left join %Table:SC7% SC7 on C7_FILIAL = FIE_FILIAL and C7_NUM = FIE_PEDIDO and C7_FORNECE = FIE_FORNEC and C7_LOJA = FIE_LOJA and SC7.%NotDel%
			left join %Table:SA2% SA2 on FIE_FORNEC = A2_COD and FIE_LOJA = A2_LOJA and SA2.%NotDel%
		Where FIE.%NotDel%
			and C7_EMISSAO Between %Exp:mv_par01% and %Exp:mv_par02% and
				FIE_FILIAL Between %Exp:mv_par03% and %Exp:mv_par04%
		order by FIE_FILIAL, FIE_PEDIDO
		
	EndSql
	Count to nRegs
	ProcRegua(nRegs)
	PAPC->(DbGoTop())
	If nRegs==0
		MsgAlert("Não existe informações para gerar Planilha !","Atenção")
	Else
		cCampos := "FIE_FILIAL,C7_EMISSAO,FIE_PEDIDO,C7_ZZCCOUP,FIE_NUM,FIE_FORNEC,FIE_LOJA,A2_NOME,FIE_VALOR,FIE_SALDO,C7_ENCER,C7_RESIDUO"
		aCampos := StrToKarr(cCampos,",")
		oExcel := FWMSEXCEL():New()
		oExcel:AddworkSheet(cTitulo)
		oExcel:AddTable(cTitulo,cTitulo)
		oExcel:AddColumn(cTitulo, cTitulo, "Filial"				, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Emissao"			, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Pedido Protheus"	, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Pedido Coupa"		, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Pagto Antecipado"	, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Fornecedor"			, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Loja"				, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Nome"				, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Valor PA"			, 1, 3, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Saldo PA"			, 1, 3, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Encerrado?"			, 2, 1, .F.)
		oExcel:AddColumn(cTitulo, cTitulo, "Resíduo?"			, 2, 1, .F.)
		While !PAPC->(Eof())
			nTot := nTot +1
			
			if PAPC->C7_ENCER == "E" 
				cEncerrado := "ENCERRADO"
			else
				cEncerrado := ""
			endif
			if PAPC->C7_RESIDUO == "R" 
				cResiduo := "SIM"
			else
				cResiduo := "NÃO"
			endif

			oExcel:AddRow(cTitulo, cTitulo, {FIE_FILIAL,;
											 C7_EMISSAO,;
											 FIE_PEDIDO,;
											 C7_ZZCCOUP,;
											 FIE_NUM,;
											 FIE_FORNEC,;
											 FIE_LOJA,;
											 A2_NOME,;
											 FIE_VALOR,;
											 FIE_SALDO,;
											 cEncerrado,;
											 cResiduo})
			IncProc( "Processando registro "+Alltrim(Str(nTot))+" de "+Alltrim(Str(nRegs)))
			PAPC->(DbSkip())
		End

		If !lErro
			oExcel:Activate()
			oExcel:GetXMLFile(cArqNome)
			If File(cArqNome)
				If MsgYesNo("Abrir arquivo "+cArqNome+"?","Concluido")
					ShellExecute("Open",cArqNome,"","",1)
				Endif
			Endif
		Endif
	Endif
	PAPC->(DbCloseArea())
Return
