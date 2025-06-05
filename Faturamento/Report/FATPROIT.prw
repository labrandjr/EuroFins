#Include 'Protheus.ch'
#Include "totvs.ch"
/*/{protheus.doc}
Gera Planilha Excel referente a Notas Fiscais de Produtos
@author Sergio Braz
@since 01/03/2019
/*/
User Function FATPROIT()
	Local aParambox	:= {}
	aAdd(aParamBox,{1,"Data Emissão de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
	aAdd(aParamBox,{1,"Data Emissão até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02
	aAdd(aParamBox,{1,"Filial de:"			,CriaVar("F2_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR03
	aAdd(aParamBox,{1,"Filial até:"			,CriaVar("F2_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR04
	aAdd(aParamBox,{1,"Cliente de:" 		,CriaVar("F2_CLIENTE",.f.),"","","SA1","",70,.F.}) //MV_PAR05
	aAdd(aParamBox,{1,"Loja de:" 			,CriaVar("F2_LOJA ",.f.),"","","","",70,.F.}) //MV_PAR06
	aAdd(aParamBox,{1,"Cliente até:"		,CriaVar("F2_CLIENTE",.f.),"","","SA1","",70,.F.}) //MV_PAR07
	aAdd(aParamBox,{1,"Loja até:" 			,CriaVar("F2_LOJA ",.f.),"","","","",70,.F.}) //MV_PAR08
	If ParamBox(aParamBox,"Notas Fiscais de Serviço",,,,,,,,ProcName(),.T.,.T.)
		Processa({||GeraPlan() },"Gerando Planilha..." )
	Endif
Return

Static Function GeraPlan
	Local nRegs
	Local cArqNome	:= GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local cTitulo	:= "NOTAS FISCAIS DANFE"
	Local aCampos, cCampos,cAlias
	Local oExcel,nAlign,nType,i,aValores
	Local aCab := StrToKarr("Filial;Num. Docto.;Serie;Emissao;Espec.Docum.;Tipo de N.F.;Cliente;Razao Social;"+;
		"CNPJ/CPF;Estado;Municipio;Item;Produto;Descricao;Tipo Produto;Pos.IPI/NCM;Vlr.Total;Total.NFiscal;Tipo Saida;Finalidade;Atu.Estoque;"+;
		"Gera Dupl.;Atual.Ativo;Cod. Fiscal;C Contabil;Desc Conta;Centro Custo;Desc CC;Base ICMS;Vlr.ICMS;"+;
		"ICMS Comple.;ICMS Solid.;Aliq. ICMS;Alq ICMS Sol;Sit.Tribut.;Vlr.Base IPI;Vlr.IPI;Trib. IPI;Base PIS;"+;
		"Valor PIS;CST Pis;Base Cofins;Valor Cofins;CST COF;Base de ISS;Valor do ISS;Vlr. Frete;Vlr. Seguro;"+;
		"Vlr. Despesa;Chave Eletrônica",";")
	BeginSql Alias "F2"
		Select Distinct SD2.R_E_C_N_O_ NUMREG, F2_FILIAL,F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA
		From %Table:SF2% SF2, %Table:SFT% SFT, %Table:SD2% SD2
		Where SF2.%NotDel% and SFT.%NotDel% and SD2.%NotDel% and
			F2_EMISSAO Between %Exp:mv_par01% and %Exp:mv_par02% and
			F2_FILIAL Between %Exp:mv_par03% and %Exp:mv_par04% and
			F2_CLIENTE Between %Exp:mv_par05% and %Exp:mv_par07% and
			F2_LOJA Between  %Exp:mv_par06% and %Exp:mv_par08% and
			F2_FILIAL = D2_FILIAL and F2_DOC = D2_DOC and F2_SERIE = D2_SERIE and
			F2_ESPECIE = 'SPED' and
			F2_FILIAL = FT_FILIAL and
			F2_SERIE = FT_SERIE and
			F2_DOC = FT_NFISCAL and
			F2_CLIENTE = FT_CLIEFOR and
			F2_LOJA = FT_LOJA and
			FT_TIPOMOV = 'S'
		Order By F2_FILIAL,F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA
	EndSql
	Count to nRegs
	ProcRegua(nRegs)
	F2->(DbGoTop())
	If nRegs==0
		MsgAlert("Não existe informações para gerar Planilha !","Atenção")
	Else
		cCampos := "D2_FILIAL,D2_DOC,D2_SERIE,D2_EMISSAO,F2_ESPECIE,D2_TIPO,F2_CLIENTE,"
		cCampos += "A2_NOME,A2_CGC,A2_EST,CC2_MUN,D2_ITEM,D2_COD,B1_DESC,D2_TP,B1_POSIPI,"
		cCampos += "D2_TOTAL,VLR_NFISCAL,D2_TES,F4_FINALID,F4_ESTOQUE,F4_DUPLIC,F4_ATUATF,D2_CF,"
		cCampos += "D2_CONTA,CT1_DESC01,D2_CCUSTO,CTT_DESC01,D2_BASEICM,D2_VALICM,D2_ICMSCOM,D2_ICMSRET,D2_PICM,D2_ALIQSOL,"
		cCampos += "D2_CLASFIS,D2_BASEIPI,D2_VALIPI,FT_CTIPI,D2_BASIMP6,D2_VALIMP6,FT_CSTPIS,D2_BASIMP5,D2_VALIMP5,"
		cCampos += "FT_CSTCOF,D2_BASEISS,D2_VALISS,D2_VALFRE,"
		cCampos += "D2_SEGURO,D2_DESPESA,F2_CHVNFE"
		aCampos := StrToKarr(cCampos,",")
		oExcel := FWMSEXCEL():New()
		oExcel:AddworkSheet(cTitulo)
		oExcel:AddTable(cTitulo,cTitulo)
		For i:=1 To Len(aCampos)
			cAlias := IIf(At("_",aCampos[i])==3,"S"+Left(aCampos[i],2),Left(aCampos[i],3))
			If "VLR_NFISCAL" $ aCampos[i]
				nAlign := 3
				nType  := 2
			ElseIf ValType(&(cAlias+'->'+aCampos[i])) == "D"
				nAlign := 3
				nType  := 4
			ElseIf ValType(&(cAlias+'->'+aCampos[i])) == "N"
				nAlign := 3
				nType  := 2
			Else
				nAlign := 1
				nType  := 1
			Endif
			If RetField('SX3',2,aCampos[i],'Eof()')
				x:=1
			Endif
			oExcel:AddColumn(cTitulo,cTitulo,aCab[i],nAlign,nType,.f.)
		Next
		While !F2->(Eof())
			SD2->(DbGoTo(F2->NUMREG))
			Posicione("SF2",1,F2->(F2_FILIAL+F2_DOC+F2_SERIE),"")
			Posicione("SB1",1,SD2->(D2_FILIAL+D2_COD),"")
            Posicione("CT1",1,xFilial("CT1")+SD2->D2_CONTA,"")
			Posicione("CTT",1,xFilial("CTT")+SD2->D2_CCUSTO,"")
			Posicione("SFT",1,SF2->(F2_FILIAL+'S'+F2_SERIE+F2_DOC+F2_CLIENTE+F2_LOJA),"")
			Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"")
			cCodMun := ""
			If SF2->F2_TIPO $ 'BD'
				Posicione("SA2",1,xFilial("SA2")+SF2->(F2_CLIENTE+F2_LOJA),"")
				Posicione("SED",1,xFilial("SED")+SA2->A2_NATUREZ,"")
				aCampos[08] := "A2_NOME"
				aCampos[09] := "A2_CGC"
				aCampos[10] := "A2_EST"
				cCodMun := SA2->A2_EST+SA2->A2_COD_MUN
			Else
				Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"")
				Posicione("SED",1,xFilial("SED")+SA1->A1_NATUREZ,"")
				aCampos[08] := "A1_NOME"
				aCampos[09] := "A1_CGC"
				aCampos[10] := "A1_EST"
				cCodMun := SA1->A1_EST+SA1->A1_COD_MUN
			Endif
			aValores := {}
			For i:=1 to Len(aCampos)
				cAlias := IIf(At("_",aCampos[i])==3,'S'+Left(aCampos[i],2),Left(aCampos[i],3))
				If "CGC"$aCampos[I]
					If Len(Alltrim(&(cAlias+"->"+aCampos[i])))==11
						AADD(aValores,Transform(&(cAlias+"->"+aCampos[i]), "@R 999.999.999-99" ))
					Else
						AADD(aValores,TransForm(&(cAlias+"->"+aCampos[i]),"@R 99.999.999/9999-99" ))
					Endif
				ElseIf "CC2_MUN"$aCampos[I]
					If !Empty(cCodMun)
						dbSelectArea("CC2")
						If CC2->(dbSetOrder(1), dbSeek(FWxFilial("CC2") + cCodMun))
							cCodMun := alltrim(CC2->CC2_MUN)
							AADD(aValores,cCodMun)
						Else
							AADD(aValores,"")
						EndIf
					Else
						AADD(aValores,"")
					EndIf
				ElseIf "VLR_NFISCAL"$aCampos[I]
					AADD(aValores,SD2->(D2_TOTAL + D2_VALIPI + D2_DESPESA + D2_VALFRE - D2_DESCON + D2_SEGURO))
				Else
					If RetField("SX3",2,aCampos[i],"!Empty(X3_PICTURE).and.X3_TIPO#'N'")
						AADD(aValores,Transform(&(cAlias+"->"+aCampos[i]),SX3->X3_PICTURE))
					Else
						AADD(aValores,&(cAlias+"->"+aCampos[i]))
					Endif
				Endif
			Next
			oExcel:AddRow(cTitulo,cTitulo,aValores)
			IncProc( "Processando...")
			F2->(DbSkip())
		End
		oExcel:Activate()
		oExcel:GetXMLFile(cArqNome)
		If File(cArqNome)
			If MsgYesNo("Abrir arquivo "+cArqNome+"?","Concluido")
				ShellExecute("Open",cArqNome,"","",1)
			Endif
		Endif
	Endif
	F2->(DbCloseArea())
Return
