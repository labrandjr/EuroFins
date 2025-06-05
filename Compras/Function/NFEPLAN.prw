#Include "totvs.ch"
#Include "topconn.ch"

/*/{protheus.doc}
Gera Planilha Excel referente a Notas Fiscais de Entrada
@author Sergio Braz
@since 01/03/2019
/*/
User Function NFEPLAN
	Local aParambox	:= {}
	aAdd(aParamBox,{1,"Data Digitação de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
	aAdd(aParamBox,{1,"Data Digitação até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02
	aAdd(aParamBox,{1,"Filial de:"			,CriaVar("F1_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR03
	aAdd(aParamBox,{1,"Filial até:"			,CriaVar("F1_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR04
	aAdd(aParamBox,{1,"Especie NF:"			,Space(250),"","","ZZESP","",70,.F.}) //MV_PAR05
	aAdd(aParamBox,{1,"Fornecedor de:" 		,CriaVar("D1_FORNECE ",.f.),"","","SA2","",70,.F.}) //MV_PAR06
	aAdd(aParamBox,{1,"Loja de:" 			,CriaVar("D1_LOJA ",.f.),"","","","",70,.F.}) //MV_PAR07
	aAdd(aParamBox,{1,"Fornecedor até:"		,CriaVar("D1_FORNECE ",.f.),"","","SA2","",70,.F.}) //MV_PAR08
	aAdd(aParamBox,{1,"Loja até:" 			,CriaVar("D1_LOJA ",.f.),"","","","",70,.F.}) //MV_PAR09
	aAdd(aParamBox,{1,"Plano Ref.:" 		,CriaVar("CVD_CODPLA ",.f.),"","","ZZCVD","",75,.T.}) //MV_PAR10

	If ParamBox(aParamBox,"Notas Fiscais de Entrada",,,,,,,,ProcName(),.T.,.T.)
		Processa({||GeraPlan() },"Gerando Planilha..." )
	Endif
Return

Static Function GeraPlan

	Local nRecnoCVD	:= 0
	Local lErro		:= .F.
	Local nRegs
	Local cArqNome	:= GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local cTitulo	:= "NOTAS FISCAIS DE ENTRADA"
	Local cTipoEsp	:= StrTran(Alltrim(MV_PAR05),"/","','")
	Local aCampos, cCampos,cAlias
	Local oExcel,nAlign,nType,i
	Private cNaturez, cNatured, aValores

	BeginSql Alias "D1"
		Select SD1.R_E_C_N_O_ NUMREG, SDE.DE_ITEM, D1_TOTAL + CASE WHEN F1_EST = 'EX' THEN D1_VALICM + D1_VALIMP6+D1_VALIMP5 ELSE 0 END + (D1_ICMSCOM + D1_VALIPI + D1_VALIMP5 + D1_VALIMP6 + D1_VALISS + D1_VALINS +
       CASE WHEN ( SELECT TOP 1 E2_IRRF
                    FROM SE2010 SE2
                    WHERE SE2.D_E_L_E_T_ = ''
                    AND SE2.E2_FILIAL = SF1.F1_FILIAL
                    AND SE2.E2_NUM = SF1.F1_DOC
                    AND SE2.E2_PREFIXO = SF1.F1_SERIE
                    AND SE2.E2_FORNECE = SF1.F1_FORNECE
                    AND SE2.E2_LOJA = SF1.F1_LOJA
                    ORDER BY SE2.E2_PARCELA) > 0
        THEN D1_VALIRR ELSE 0 END + D1_VALFRE + D1_SEGURO + D1_ICMSRET + D1_DESPESA - D1_VALDESC ) AS NEW_VLR_CTB
		From %Table:SF1% SF1, %Table:SD1% SD1
		left join %Table:SDE% as SDE on D1_FORNECE = DE_FORNECE and  D1_LOJA = DE_LOJA and  D1_DOC = DE_DOC and  D1_SERIE = DE_SERIE and D1_FILIAL = DE_FILIAL and D1_ITEM = DE_ITEMNF and SDE.D_E_L_E_T_ = ' '
		Where SD1.%NotDel% and SF1.%NotDel% and
		D1_FILIAL = F1_FILIAL and
		D1_DOC = F1_DOC and
		D1_SERIE = F1_SERIE and
		D1_FORNECE = F1_FORNECE and
		D1_LOJA = F1_LOJA and
		D1_DTDIGIT Between %Exp:mv_par01% and %Exp:mv_par02% and
		D1_FILIAL Between %Exp:mv_par03% and %Exp:mv_par04% and
		F1_ESPECIE IN(%Exp:cTipoEsp%)
		and  F1_FORNECE >=   %Exp:mv_par06%
		and  F1_FORNECE <=   %Exp:mv_par08%
		and  F1_LOJA >=   %Exp:mv_par07%
		and  F1_LOJA <=   %Exp:mv_par09%
		and  F1_STATUS <> ' '
        and  D1_RATEIO = '1'
		// Order By D1_FILIAL,D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM
        union all
		Select SD1.R_E_C_N_O_ NUMREG, '' AS DE_ITEM, D1_TOTAL + CASE WHEN F1_EST = 'EX' THEN D1_VALICM + D1_VALIMP6+D1_VALIMP5 ELSE 0 END + (D1_ICMSCOM + D1_VALIPI + D1_VALIMP5 + D1_VALIMP6 + D1_VALISS + D1_VALINS +
        CASE WHEN ( SELECT TOP 1 E2_IRRF
                    FROM SE2010 SE2
                    WHERE SE2.D_E_L_E_T_ = ''
                    AND SE2.E2_FILIAL = SF1.F1_FILIAL
                    AND SE2.E2_NUM = SF1.F1_DOC
                    AND SE2.E2_PREFIXO = SF1.F1_SERIE
                    AND SE2.E2_FORNECE = SF1.F1_FORNECE
                    AND SE2.E2_LOJA = SF1.F1_LOJA
                    ORDER BY SE2.E2_PARCELA) > 0
        THEN D1_VALIRR ELSE 0 END    + D1_VALFRE + D1_SEGURO + D1_ICMSRET + D1_DESPESA - D1_VALDESC ) AS NEW_VLR_CTB
		From %Table:SF1% SF1, %Table:SD1% SD1
		Where SD1.%NotDel% and SF1.%NotDel% and
		D1_FILIAL = F1_FILIAL and
		D1_DOC = F1_DOC and
		D1_SERIE = F1_SERIE and
		D1_FORNECE = F1_FORNECE and
		D1_LOJA = F1_LOJA and
		D1_DTDIGIT Between %Exp:mv_par01% and %Exp:mv_par02% and
		D1_FILIAL Between %Exp:mv_par03% and %Exp:mv_par04% and
		F1_ESPECIE IN(%Exp:cTipoEsp%)
		and  F1_FORNECE >=   %Exp:mv_par06%
		and  F1_FORNECE <=   %Exp:mv_par08%
		and  F1_LOJA >=   %Exp:mv_par07%
		and  F1_LOJA <=   %Exp:mv_par09%
		and  F1_STATUS <> ' '
		and  D1_RATEIO != '1'
		// Order By D1_FILIAL,D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM

	EndSql
	Count to nRegs
	ProcRegua(nRegs)
	D1->(DbGoTop())
	If nRegs==0
		MsgAlert("Não existe informações para gerar Planilha !","Atenção")
	Else
		cCampos := "D1_FILIAL,F1_STATUS,D1_DOC,D1_SERIE,D1_EMISSAO,D1_DTDIGIT,F1_ESPECIE,D1_TIPO,F1_FORNECE,F1_LOJA,A2_NOME,CC2_MUN,A2_EST,"
		cCampos += "A2_CGC,D1_ITEM,D1_COD,D1_ZZDESCR,D1_TP,D1_ZZNCM,D1_ZZOBS,D1_TES,"
		cCampos += "F4_FINALID,F4_ESTOQUE,F4_DUPLIC,F4_ATUATF,D1_CF,F4_CODBCC,D1_CONTA,CT1_DESC01,CVD_CTAREF,CVD_CTASUP,D1_CC,"
		cCampos += "CTT_DESC01,D1_TOTAL,VLR_NFISCAL,D1_BASEICM,D1_VALICM,D1_ICMSCOM,D1_ICMSRET,D1_PICM,D1_ALIQSOL,D1_CLASFIS,D1_BASEIPI,D1_VALIPI,"
		cCampos += "FT_CTIPI,D1_BASIMP6,D1_VALIMP6,FT_CSTPIS,D1_BASIMP5,D1_VALIMP5,FT_CSTCOF,E1_NATUREZ,ED_DESCRIC,D1_BASEISS,D1_VALISS,D1_BASEINS,"
		cCampos += "D1_VALINS,D1_BASEIRR,D1_VALIRR,D1_BASEPIS,D1_VALPIS,D1_BASECOF,D1_VALCOF,D1_BASECSL,D1_VALCSL,D1_VALFRE,"
		cCampos += "D1_SEGURO,D1_DESPESA,D1_VALDESC,F1_UFORITR,F1_MUORITR,F1_UFDESTR,F1_MUDESTR,D1_CUSTO,NEW_VLR_CTB,"
		cCampos += "D1_RATEIO,DE_ITEM,F1_XSTA_CC,F1_XLOGCLA,F1_MENNOTA,F1_XTPBLOQ,F1_XSTA_RF,"
		cCampos += "F1_XDTLIB,F1_XDTBLOQ,F1_XREGBLQ,F1_XMOTCC,F1_XMOTRF,F1_XDTCLAS,D1_CONHEC,F1_RECBMTO"

		aCampos := StrToKarr(cCampos,",")
		oExcel := FWMSEXCEL():New()
		oExcel:AddworkSheet(cTitulo)
		oExcel:AddTable(cTitulo,cTitulo)
		For i:=1 To Len(aCampos)
			If alltrim(aCampos[i]) == "NEW_VLR_CTB"
				nAlign := 3
				nType  := 2
				oExcel:AddColumn(cTitulo,cTitulo,"Vlr Contabil",nAlign,nType,.f.)
			ElseIf alltrim(aCampos[i]) == "VLR_NFISCAL"
				nAlign := 3
				nType  := 2
				oExcel:AddColumn(cTitulo,cTitulo,"Vlr Nota Fiscal",nAlign,nType,.f.)
			ElseIf alltrim(aCampos[i]) == "D1_TOTAL"
				nAlign := 3
				nType  := 2
				oExcel:AddColumn(cTitulo,cTitulo,"Vlr Produtos",nAlign,nType,.f.)
			Else
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
				oExcel:AddColumn(cTitulo,cTitulo,RetField('SX3',2,aCampos[i],'Trim(X3_TITULO)'),nAlign,nType,.f.)
			EndIf

		Next
		While !D1->(Eof())
			SD1->(DbGoTo(D1->NUMREG))
			Posicione("SF1",1,SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA),"")
			Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"")
			Posicione("CTT",1,xFilial("CTT")+SD1->D1_CC,"")
			Posicione("CT1",1,xFilial("CT1")+SD1->D1_CONTA,"")
			cNaturez := Posicione("SE2",6,SD1->(D1_FILIAL+D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC),"E2_NATUREZ")
			cNatured := Posicione("SED",1,xFilial("SED")+cNaturez,"ED_DESCRIC")
			cRetISS := Posicione("SED",1,xFilial("SED")+cNaturez,"ED_CALCISS")

			// cUserInc := Embaralha(SD1->D1_USERLGI,1)
			// cUserInc := iif(!empty(cUserInc),alltrim(UsrRetName(substring(cUserInc,3,6))) + " - " + alltrim(UsrFullName(substring(cUserInc,3,6))),"")

			//Posicione("CVD",1,xFilial("CVD")+CT1->CT1_CONTA,"")
			CVD->(DbSetOrder(1)) //CVD_FILIAL+CVD_CONTA+CVD_ENTREF+CVD_CTAREF+CVD_CUSTO+CVD_VERSAO
			If !Empty(SD1->D1_CONTA)
				nRecnoCVD	:= retRecnoCVD(CT1->CT1_CONTA,MV_PAR10)
				If nRecnoCVD > 0
					CVD->(DbGoTo( nRecnoCVD ))
				Else
					MsgAlert("Nao localizado o plano referencial [" + MV_PAR10 + "] da conta [" + CT1->CT1_CONTA + "].",FunDesc())
					lErro	:= .T.
					exit
				EndIf
			EndIf

			If SD1->D1_TIPO$'BD'
				aCampos[09] := "A1_NOME"
				aCampos[10] := "A1_EST"
				aCampos[11] := "A1_CGC"
				Posicione("SA1",1,xFilial("SA1")+SD1->(D1_FORNECE+D1_LOJA),"")
				Posicione("SFT",1,SD1->(D1_FILIAL+'S'+D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM),"")
				cCodMun := SA1->A1_EST+SA1->A1_COD_MUN
			Else
				aCampos[09] := "A2_NOME"
				aCampos[10] := "A2_EST"
				aCampos[11] := "A2_CGC"
				Posicione("SA2",1,xFilial("SA2")+SD1->(D1_FORNECE+D1_LOJA),"")
				Posicione("SFT",1,SD1->(D1_FILIAL+'E'+D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM),"")
				cCodMun := SA2->A2_EST+SA2->A2_COD_MUN
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
				elseif "NATUREZ"$aCampos[i]
					AADD(aValores,cNaturez)
				elseif "ED_DESCRIC"$aCampos[i]
					AADD(aValores,cNatured)
				elseif "DE_ITEM"$aCampos[i]
					AADD(aValores,D1->DE_ITEM)
				elseif "VLR_NFISCAL"$aCampos[i]
					AADD(aValores,SD1->(D1_TOTAL + D1_VALIPI + D1_DESPESA + D1_VALFRE - D1_VALDESC + D1_SEGURO))
				elseif "CC2_MUN"$aCampos[i]
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
				Else
					If alltrim(aCampos[i]) == "NEW_VLR_CTB"
						AADD(aValores,D1->NEW_VLR_CTB + iif(SF4->F4_LFICM == "T", aValores[34],0) + iif(cRetISS=="S",0, aValores[49]*-1))
					Else
						If RetField("SX3",2,aCampos[i],"!Empty(X3_PICTURE).and.X3_TIPO#'N'")
							AADD(aValores,Transform(&(cAlias+"->"+aCampos[i]),SX3->X3_PICTURE))
						Else
							AADD(aValores,&(cAlias+"->"+aCampos[i]))
						Endif
					Endif
				Endif
			Next

			//Busca CC de notas com rateio
			GetCC()

			oExcel:AddRow(cTitulo,cTitulo,aValores)
			IncProc( "Processando...")
			D1->(DbSkip())
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
	D1->(DbCloseArea())
Return

static function retRecnoCVD(cConta,cCodPla)

	local nRecno			:= 0
	local cQuery			:= ""
	local cAlias			:= getnextalias()

	cQuery		+= "SELECT  " + CRLF
	cQuery		+= "	CVD.R_E_C_N_O_ REC_CVD " + CRLF
	cQuery		+= "FROM " + CRLF
	cQuery		+= "	" + RetSqlTab("CVD") + CRLF
	cQuery		+= "WHERE " + CRLF
	cQuery		+= "	CVD_FILIAL = '" + FwXFilial("CVD") + "' " + CRLF
	cQuery		+= "	AND CVD_CONTA = '" + cConta + "' " + CRLF
	cQuery		+= "	AND CVD_CODPLA = '" + cCodPla + "' " + CRLF
	cQuery		+= "	AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery		+= "" + CRLF

	Conout("Query: " + ChangeQuery(cQuery))

	TcQuery cQuery new alias &cAlias

	if (cAlias)->(!eof())
		nRecno	:= (cAlias)->REC_CVD
	endIf

	(cAlias)->(DbCloseArea())

return nRecno

/*
Rotina que irá validar se o item da nota fiscal tem rateio de centro de custo ou não
Caso tenha rateio, irá levar os dados da SDE e não da SD1
*/
Static Function GetCC()

	if aValores[76] == '1' //rateio por CC Item NF
		BeginSql Alias "DE"
			Select
				DE_CC,
				DE_PERC
			From
				%Table:SDE%
			Where
				%NotDel% and
				DE_FILIAL 	= %EXP:aValores[1]% and
				DE_DOC		= %EXP:aValores[3]% and
				DE_SERIE	= %EXP:aValores[4]% and
				DE_FORNECE	= %EXP:aValores[9]% and
				DE_LOJA		= %EXP:aValores[10]% and
				DE_ITEMNF	= %EXP:aValores[15]% and
				DE_ITEM		= %EXP:aValores[77]%
		EndSql

		While !DE->(Eof())
			aValores[29] := DE->DE_CC //Centro de Custo
			aValores[30] := Alltrim(Posicione("CTT",1,xFilial("CTT")+DE->DE_CC,"CTT_DESC01")) //Descriï¿½ï¿½o do CC
			aValores[34] := Round(aValores[34]*(DE->DE_PERC/100),2) //Total
			aValores[74] := Round(aValores[74]*(DE->DE_PERC/100),2) //Custo 1
			aValores[36] := Round(aValores[36]*(DE->DE_PERC/100),2) //Base ICMS
			aValores[37] := Round(aValores[37]*(DE->DE_PERC/100),2) //Valor ICMS
			aValores[38] := Round(aValores[38]*(DE->DE_PERC/100),2) //Valor ICMS Complementar
			aValores[39] := Round(aValores[39]*(DE->DE_PERC/100),2) //Valor ICMS ST
			aValores[43] := Round(aValores[43]*(DE->DE_PERC/100),2) //Base IPI
			aValores[44] := Round(aValores[44]*(DE->DE_PERC/100),2) //Valor IPI
			aValores[46] := Round(aValores[46]*(DE->DE_PERC/100),2) //Base PIS
			aValores[47] := Round(aValores[47]*(DE->DE_PERC/100),2) //Valor PIS
			aValores[49] := Round(aValores[49]*(DE->DE_PERC/100),2) //Base COFINS
			aValores[50] := Round(aValores[50]*(DE->DE_PERC/100),2) //Valor COFINS
			aValores[54] := Round(aValores[54]*(DE->DE_PERC/100),2) //Base ISS
			aValores[55] := Round(aValores[55]*(DE->DE_PERC/100),2) //Valor ISS
			aValores[56] := Round(aValores[56]*(DE->DE_PERC/100),2) //Base INSS
			aValores[57] := Round(aValores[57]*(DE->DE_PERC/100),2) //Valor INSS
			aValores[58] := Round(aValores[58]*(DE->DE_PERC/100),2) //Base IR
			aValores[59] := Round(aValores[59]*(DE->DE_PERC/100),2) //Valor IR
			aValores[60] := Round(aValores[60]*(DE->DE_PERC/100),2) //Base PIS
			aValores[61] := Round(aValores[61]*(DE->DE_PERC/100),2) //Valor PIS
			aValores[62] := Round(aValores[62]*(DE->DE_PERC/100),2) //Base COFINS
			aValores[63] := Round(aValores[63]*(DE->DE_PERC/100),2) //Valor COFINS
			aValores[64] := Round(aValores[64]*(DE->DE_PERC/100),2) //Base CSLL
			aValores[65] := Round(aValores[65]*(DE->DE_PERC/100),2) //Valor CSLL
			aValores[66] := Round(aValores[66]*(DE->DE_PERC/100),2) //Valor FRETE
			aValores[67] := Round(aValores[67]*(DE->DE_PERC/100),2) //Base SEGURO
			aValores[68] := Round(aValores[68]*(DE->DE_PERC/100),2) //Valor DESPESA
			aValores[69] := Round(aValores[69]*(DE->DE_PERC/100),2) //Valor DESCONTO
			aValores[75] := Round(aValores[75]*(DE->DE_PERC/100),2) //Valor Contabilizado
			aValores[35] := Round(aValores[35]*(DE->DE_PERC/100),2) //Valor Total
			DE->(DbSkip())
		end
		DE->(DbCloseArea())
	Endif

Return







// Select SD1.R_E_C_N_O_ NUMREG, SDE.DE_ITEM, D1_TOTAL + CASE WHEN F1_EST = 'EX' THEN D1_VALICM + D1_VALIMP6+D1_VALIMP5 ELSE 0 END + (D1_ICMSCOM + D1_VALIPI + D1_VALIMP5 + D1_VALIMP6 + D1_VALISS + D1_VALINS +
//        ISNULL(CASE WHEN D1_ITEM = (SELECT MIN(D1_ITEM) FROM SD1010 DITEM
//             WHERE DITEM.D_E_L_E_T_ = '' AND DITEM.D1_FILIAL = SF1.F1_FILIAL AND DITEM.D1_DOC = SF1.F1_DOC
//             AND DITEM.D1_SERIE = SF1.F1_SERIE AND DITEM.D1_FORNECE = SF1.F1_FORNECE
//             AND DITEM.D1_LOJA = SF1.F1_LOJA)
//             AND
//             ISNULL(DE_ITEM,'') = (SELECT ISNULL(MIN(DE_ITEM),'') FROM SDE010 DCCITEM
//             WHERE DCCITEM.D_E_L_E_T_ = '' AND DCCITEM.DE_DOC = SD1.D1_DOC
//             AND DCCITEM.DE_SERIE = SD1.D1_SERIE AND DCCITEM.DE_FORNECE = SF1.F1_FORNECE
//             AND DCCITEM.DE_LOJA = SD1.D1_LOJA)
//             THEN
//             (
//             SELECT TOP 1 E2_IRRF
//             FROM SE2010 SE2
//             WHERE SE2.D_E_L_E_T_ = ''
//             AND SE2.E2_FILIAL = SF1.F1_FILIAL
//             AND SE2.E2_NUM = SF1.F1_DOC
//             AND SE2.E2_PREFIXO = SF1.F1_SERIE
//             AND SE2.E2_FORNECE = SF1.F1_FORNECE
//             AND SE2.E2_LOJA = SF1.F1_LOJA
//             ORDER BY SE2.E2_PARCELA
//             )
//             ELSE 0
//         END,0) + D1_VALFRE + D1_SEGURO + D1_ICMSRET + D1_DESPESA - D1_VALDESC ) AS NEW_VLR_CTB
// 		From %Table:SF1% SF1, %Table:SD1% SD1
// 		left join %Table:SDE% as SDE on D1_FORNECE = DE_FORNECE and  D1_LOJA = DE_LOJA and  D1_DOC = DE_DOC and  D1_SERIE = DE_SERIE and D1_FILIAL = DE_FILIAL and D1_ITEM = DE_ITEMNF and SDE.D_E_L_E_T_ = ' '
// 		Where SD1.%NotDel% and SF1.%NotDel% and
// 		D1_FILIAL = F1_FILIAL and
// 		D1_DOC = F1_DOC and
// 		D1_SERIE = F1_SERIE and
// 		D1_FORNECE = F1_FORNECE and
// 		D1_LOJA = F1_LOJA and
// 		D1_DTDIGIT Between %Exp:mv_par01% and %Exp:mv_par02% and
// 		D1_FILIAL Between %Exp:mv_par03% and %Exp:mv_par04% and
// 		F1_ESPECIE IN(%Exp:cTipoEsp%)
// 		and  F1_FORNECE >=   %Exp:mv_par06%
// 		and  F1_FORNECE <=   %Exp:mv_par08%
// 		and  F1_LOJA >=   %Exp:mv_par07%
// 		and  F1_LOJA <=   %Exp:mv_par09%
// 		and  F1_STATUS <> ' '
//         and  D1_RATEIO = '1'
// 		// Order By D1_FILIAL,D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM
//         union all
// 		Select SD1.R_E_C_N_O_ NUMREG, '' AS DE_ITEM, D1_TOTAL + CASE WHEN F1_EST = 'EX' THEN D1_VALICM + D1_VALIMP6+D1_VALIMP5 ELSE 0 END + (D1_ICMSCOM + D1_VALIPI + D1_VALIMP5 + D1_VALIMP6 + D1_VALISS + D1_VALINS +
//         ISNULL(CASE WHEN D1_ITEM = (SELECT MIN(D1_ITEM) FROM SD1010 DITEM
//             WHERE DITEM.D_E_L_E_T_ = '' AND DITEM.D1_FILIAL = SF1.F1_FILIAL AND DITEM.D1_DOC = SF1.F1_DOC
//             AND DITEM.D1_SERIE = SF1.F1_SERIE AND DITEM.D1_FORNECE = SF1.F1_FORNECE
//             AND DITEM.D1_LOJA = SF1.F1_LOJA)
//             THEN
//             (
//             SELECT TOP 1 E2_IRRF
//             FROM SE2010 SE2
//             WHERE SE2.D_E_L_E_T_ = ''
//             AND SE2.E2_FILIAL = SF1.F1_FILIAL
//             AND SE2.E2_NUM = SF1.F1_DOC
//             AND SE2.E2_PREFIXO = SF1.F1_SERIE
//             AND SE2.E2_FORNECE = SF1.F1_FORNECE
//             AND SE2.E2_LOJA = SF1.F1_LOJA
//             ORDER BY SE2.E2_PARCELA
//             )
//             ELSE 0
//         END,0)    + D1_VALFRE + D1_SEGURO + D1_ICMSRET + D1_DESPESA - D1_VALDESC ) AS NEW_VLR_CTB
// 		From %Table:SF1% SF1, %Table:SD1% SD1
// 		Where SD1.%NotDel% and SF1.%NotDel% and
// 		D1_FILIAL = F1_FILIAL and
// 		D1_DOC = F1_DOC and
// 		D1_SERIE = F1_SERIE and
// 		D1_FORNECE = F1_FORNECE and
// 		D1_LOJA = F1_LOJA and
// 		D1_DTDIGIT Between %Exp:mv_par01% and %Exp:mv_par02% and
// 		D1_FILIAL Between %Exp:mv_par03% and %Exp:mv_par04% and
// 		F1_ESPECIE IN(%Exp:cTipoEsp%)
// 		and  F1_FORNECE >=   %Exp:mv_par06%
// 		and  F1_FORNECE <=   %Exp:mv_par08%
// 		and  F1_LOJA >=   %Exp:mv_par07%
// 		and  F1_LOJA <=   %Exp:mv_par09%
// 		and  F1_STATUS <> ' '
// 		and  D1_RATEIO != '1'
// 		// Order By D1_FILIAL,D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM

// ajuste
