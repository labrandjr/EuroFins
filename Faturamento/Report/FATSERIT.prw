#Include 'Protheus.ch'
#Include "totvs.ch"

/*/{protheus.doc}
Gera Planilha Excel referente a Notas Fiscais de Serviço
@author Sergio Braz
@since 01/03/2019
/*/
User Function FATSERIT()
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
	Local cTitulo	:= "NOTAS FISCAIS DE SERVIÇO"
	Local aCampos, cCampos,cAlias
	Local oExcel,nAlign,nType,i,aValores             
	Local aCab := StrToKarr("Filial;DT Emissao;Serie Docto.;Numero;Cliente;Loja;Nome;CNPJ/CPF;Natureza;Descricao;"+;
		"Município;Estado;Vlr.Bruto;Base ISS;Valor ISS;Recolha ISS;Base Cofins;Valor Cofins Ap.;Base PIS;Valor PIS Ap.;Base IR;Valor IRRF;"+;
		"Base PIS;Valor PIS Ret.;Base COFINS;Valor COFINS Ret.;Base CSLL;Valor CSLL;Tipo E/S;Finalidade;CST Pis;Cod.BC Cred.",";")
	BeginSql Alias "F2"
		Select Distinct SF2.R_E_C_N_O_ NUMREG,F2_FILIAL,F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA
		From %Table:SF2% SF2, %Table:SD2% SD2, %Table:SF4% SF4, %Table:SFT% SFT
		Where SF2.%NotDel% and SD2.%NotDel% and SF4.%NotDel% and SFT.%NotDel% and
			F2_EMISSAO Between %Exp:mv_par01% and %Exp:mv_par02% and 
			F2_FILIAL Between %Exp:mv_par03% and %Exp:mv_par04% and 
			F2_CLIENTE Between %Exp:mv_par05% and %Exp:mv_par07% and
			F2_LOJA Between  %Exp:mv_par06% and %Exp:mv_par08% and
			F2_TIPO = 'N' and F2_ESPECIE <> 'SPED' and 
			F2_FILIAL = D2_FILIAL and F2_SERIE = D2_SERIE and F2_DOC = D2_DOC and 
			F2_CLIENTE = D2_CLIENTE and F2_LOJA = D2_LOJA and
			D2_TES = F4_CODIGO and F4_ZZTM = '54' and
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
		cCampos := "F2_FILIAL,F2_EMISSAO,F2_SERIE,F2_DOC,F2_CLIENTE,F2_LOJA,A1_NOME,A1_CGC,"
		cCampos += "A1_NATUREZ,ED_DESCRIC,A1_MUN,A1_EST,F2_VALBRUT,F2_BASEISS,F2_VALISS,F2_RECISS,F2_BASIMP5,F2_VALIMP5,"
		cCampos += "F2_BASIMP6,F2_VALIMP6,F2_BASEIRR,F2_VALIRRF,F2_BASPIS,F2_VALPIS,F2_BASCOFI,F2_VALCOFI,"
		cCampos += "F2_BASCSLL,F2_VALCSLL,FT_TES,F4_FINALID,FT_CSTPIS,FT_CODBCC"		
		aCampos := StrToKarr(cCampos,",")
		oExcel := FWMSEXCEL():New()
		oExcel:AddworkSheet(cTitulo)
		oExcel:AddTable(cTitulo,cTitulo)
		For i:=1 To Len(aCampos)            
			cAlias := IIf(At("_",aCampos[i])==3,"S"+Left(aCampos[i],2),Left(aCampos[i],3))
			If ValType(&(cAlias+'->'+aCampos[i])) == "D"
				nAlign := 2
				nType  := 4
			ElseIf ValType(&(cAlias+'->'+aCampos[i])) == "N"
				nAlign := 3
				nType  := 2
			Else
				nAlign := 1
				nType  := 1
			Endif                               
			oExcel:AddColumn(cTitulo,cTitulo,aCab[i],nAlign,nType,.f.)
		Next                                        
		While !F2->(Eof())            
			SF2->(DbGoTo(F2->NUMREG))
			Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"")
			Posicione("SED",1,xFilial("SED")+SA1->A1_NATUREZ,"")
			Posicione("SFT",1,SF2->(F2_FILIAL+'S'+F2_SERIE+F2_DOC+F2_CLIENTE+F2_LOJA),"")  
			Posicione("SF4",1,xFilial("SF4")+SFT->FT_TES,"")          
			aValores := {}
			For i:=1 to Len(aCampos)
				cAlias := IIf(At("_",aCampos[i])==3,'S'+Left(aCampos[i],2),Left(aCampos[i],3))
				If "CGC"$aCampos[I]
					If Len(Alltrim(&(cAlias+"->"+aCampos[i])))==11    
						AADD(aValores,Transform(&(cAlias+"->"+aCampos[i]), "@R 999.999.999-99" )) 
					Else                                        
						AADD(aValores,TransForm(&(cAlias+"->"+aCampos[i]),"@R 99.999.999/9999-99" ))
					Endif
				elseIf "F2_VALPIS"$aCampos[I] .or. "F2_VALCOFI"$aCampos[I] .or. "F2_VALCSLL"$aCampos[I]
					if SF2->F2_VALBRUT < 215.15
						AADD(aValores,Transform(0,SX3->X3_PICTURE))
					else
						AADD(aValores,Transform(&(cAlias+"->"+aCampos[i]),SX3->X3_PICTURE))
					endif
				elseif "F2_RECISS"$aCampos[I]
					if SF2->F2_RECISS == "1"
						AADD(aValores,"Sim")
					else
						AADD(aValores,"Não")
					endif
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

User Function Xpto2
	RpcSetEnv("01","0100","admin","agis3","EST")
	Define MsDialog oMainWnd From 0,0 To 800,1400 Pixel
		@ 25,05 Button "fatser"  Of oMainWnd Size 80,15 Pixel Action u_fatserit()
		@ 45,05 Button "fatprod" Of oMainWnd Size 80,15 Pixel Action u_fatproit()
	Activate MsDialog oMainWnd
Return