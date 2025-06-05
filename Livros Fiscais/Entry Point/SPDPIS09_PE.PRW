#Include "Protheus.ch"
#Include "TopConn.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ SPDPIS09 ∫ Autor ≥ VSF by OGS         ∫ Data ≥ 13/08/2012  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Permite adicionar linhas nos registros F100, 0150,         ∫±±
±±∫          ≥ 0500 e 0600 do SPED PIS/COFINS.                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Alterado  ≥ 							                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function SPDPIS09()

Local cQuery   := ""
Local cCodMun  := ""
Local cEndereco:= ""
Local cNumero  := ""     
Local cDtCTB   := ""
Local cDtSE2   := ""
Local cCNPJ	   := ""
Local cCPF	   := ""
Local nAliqPis := 0
Local nValPis  := 0
Local nAliqCof := 0
Local nValCof  := 0
Local nPos     := 0
Local aRet 	   := {}
Local aUF      := {}
Local aAreaAtu := GetArea()
Local cDescric := ""

&&Alert("Executando o Ponto de Entrada SPDPIS09")

aAdd(aUF,{"RO","11"})
aAdd(aUF,{"AC","12"})
aAdd(aUF,{"AM","13"})
aAdd(aUF,{"RR","14"})
aAdd(aUF,{"PA","15"})
aAdd(aUF,{"AP","16"})
aAdd(aUF,{"TO","17"})
aAdd(aUF,{"MA","21"})
aAdd(aUF,{"PI","22"})
aAdd(aUF,{"CE","23"})
aAdd(aUF,{"RN","24"})
aAdd(aUF,{"PB","25"})
aAdd(aUF,{"PE","26"})
aAdd(aUF,{"AL","27"})
aAdd(aUF,{"MG","31"})
aAdd(aUF,{"ES","32"})
aAdd(aUF,{"RJ","33"})
aAdd(aUF,{"SP","35"})
aAdd(aUF,{"PR","41"})
aAdd(aUF,{"SC","42"})
aAdd(aUF,{"RS","43"})
aAdd(aUF,{"MS","50"})
aAdd(aUF,{"MT","51"})
aAdd(aUF,{"GO","52"})
aAdd(aUF,{"DF","53"})
aAdd(aUF,{"SE","28"})
aAdd(aUF,{"BA","29"})
aAdd(aUF,{"EX","99"})

********************************* JUROS RECEBIDOS
cQuery := 	"SELECT DISTINCT E5_FILIAL, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_DATA, "
cQuery += 	"E5_VLDESCO, E5_VLCORRE, E5_VLJUROS, E5_VALOR, E5_NATUREZ, "
cQuery += 	"E5_PREFIXO, E5_NUMERO, E5_SEQ, SA2.A2_COD_MUN, SA2.A2_NOME, SA2.A2_CODPAIS, SA2.A2_EST, "
cQuery += 	"SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_END, SED.ED_CONTA, SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, "
cQuery += 	"SED.ED_PCAPPIS, SED.ED_PCAPCOF, SA2.A2_BAIRRO, CT1.CT1_NTSPED, CT1.CT1_DESC01, "
cQuery += 	"CVD.CVD_CTAREF, CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT " 
cQuery +=	"FROM "+RetSqlName("SE5")+" SE5 "
cQuery += 	"LEFT JOIN "+RetSqlName("SA2")+" SA2 ON "
cQuery +=	"SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA AND SA2.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON "
cQuery += 	"SED.ED_CODIGO = '0103002' AND SED.D_E_L_E_T_ <> '*' "
cQuery +=	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON "	
cQuery +=	"SED.ED_CONTA = CVD.CVD_CONTA AND CVD_CODPLA = '000002' AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=   "INNER JOIN " + RetSqlName("CVN") + " CVN ON "
cQuery +=   "CVD.CVD_CODPLA = CVN.CVN_CODPLA AND CVD.CVD_VERSAO = CVN.CVN_VERSAO "
cQuery +=	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "	
cQuery +=	"CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND SE5.E5_FILIAL = '"+cFilAnt+"' "  
cQuery +=	"AND SE5.E5_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" SE5.E5_VLJUROS > 0 "
cQuery += 	"AND SE5.E5_RECPAG = 'R' "
cQuery += 	"AND SE5.D_E_L_E_T_ <>'*' "
cQuery += 	"AND SE5.E5_SITUACA NOT IN ('X','C') " 
cQuery += 	"AND SE5.E5_TIPO NOT IN ('NDF','PA') "
cQuery += 	"AND SE5.E5_TIPODOC <> 'ES' "
cQuery +=   " AND CVN.CVN_DTVIGF >= '"+DTOS(Paramixb[3])+"' "
cQuery +=   " AND CVN.CVN_ENTREF = '10'"
cQuery += 	"ORDER BY SE5.E5_DATA "

If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := QRY->A2_COD_MUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(QRY->A2_EST) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+QRY->A2_COD_MUN
	Endif
    
	nPos     := At(",",QRY->A2_END)
	cEndereco:= Alltrim(Substr(QRY->A2_END,1,nPos-1))
	cNumero  := Alltrim(Substr(QRY->A2_END,nPos+1,Len(SA2->A2_END)))

	cCodFor := " "
	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cDtSE2  := Substr(QRY->E5_DATA,7,2) + Substr(QRY->E5_DATA,5,2) + Substr(QRY->E5_DATA,1,4)	
	cCodFor := "SA2" + cFilAnt + QRY->E5_CLIFOR + QRY->E5_LOJA

	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= (QRY->E5_VLJUROS * QRY->ED_PCAPPIS) / 100
	nValCof	:= (QRY->E5_VLJUROS * QRY->ED_PCAPCOF) / 100
	
	cCNPJ	:= If(Len(Alltrim(QRY->A2_CGC)) == 14, QRY->A2_CGC, " ")
	cCPF	:= If(Len(Alltrim(QRY->A2_CGC)) <  14, QRY->A2_CGC, " ")
		

		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					QRY->E5_CLIFOR						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cDtSE2								,; 	&& F100 - 05 - DT_OPER
					QRY->E5_VLJUROS   					,; 	&& F100 - 06 - VL_OPER
					QRY->ED_CSTPIS						,;  && F100 - 07 - CST_PIS
					QRY->E5_VLJUROS						,;  && F100 - 08 - VL_BC_PIS
					nAliqPis		 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					QRY->ED_CSTCOF						,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					QRY->E5_VLJUROS						,; 	&& F100 - 12 - VL_BC_COFINS
					nAliqCof							,;  && F100 - 13 - ALIQ_COFINS
					nValCof								,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					QRY->ED_CONTA						,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Juros.Recebidos s/Tit"+QRY->E5_NUMERO	,;  && F100 - 19 - DESC_DOC_OPER
					QRY->E5_LOJA						,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					QRY->E5_CLIFOR						,;  && 0150 - 02 - COD_PART
					QRY->A2_NOME   						,;  && 0150 - 03 - NOME
					QRY->A2_CODPAIS						,; 	&& 0150 - 04 - COD_PAIS
					cCNPJ								,;  && 0150 - 05 - CNPJ
					cCPF								,;  && 0150 - 06 - CPF
					QRY->A2_INSCR						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					QRY->A2_BAIRRO 						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta(QRY->ED_CONTA))		,;	&& 0500 - 05 - NIVEL   			--------> "5"
					QRY->ED_CONTA						,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())

********************************* MULTA RECEBIDA
cQuery := 	"SELECT DISTINCT E5_FILIAL, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_DATA, "
cQuery += 	"E5_VLDESCO, E5_VLCORRE, E5_VLMULTA, E5_VALOR, E5_NATUREZ, "
cQuery += 	"E5_PREFIXO, E5_NUMERO, E5_SEQ, SA2.A2_COD_MUN, SA2.A2_NOME, SA2.A2_CODPAIS, SA2.A2_EST, "
cQuery += 	"SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_END, SED.ED_CONTA, SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, "
cQuery += 	"SED.ED_PCAPPIS, SED.ED_PCAPCOF, SA2.A2_BAIRRO, CT1.CT1_NTSPED, CT1.CT1_DESC01, "
cQuery += 	"CVD.CVD_CTAREF, CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT " 
cQuery +=	"FROM "+RetSqlName("SE5")+" SE5 "
cQuery += 	"LEFT JOIN "+RetSqlName("SA2")+" SA2 ON "
cQuery +=	"SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA AND SA2.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON "
cQuery += 	"SED.ED_CODIGO = '0103002' AND SED.D_E_L_E_T_ <> '*' "
cQuery +=	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON "	
cQuery +=	"SED.ED_CONTA = CVD.CVD_CONTA AND CVD_CODPLA = '000002' AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=   "INNER JOIN " + RetSqlName("CVN") + " CVN ON "
cQuery +=   "CVD.CVD_CODPLA = CVN.CVN_CODPLA AND CVD.CVD_VERSAO = CVN.CVN_VERSAO "
cQuery +=	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "	
cQuery +=	"CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND SE5.E5_FILIAL = '"+cFilAnt+"' "  
cQuery +=	"AND SE5.E5_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" SE5.E5_VLMULTA > 0 "
cQuery += 	"AND SE5.E5_RECPAG = 'R' "
cQuery += 	"AND SE5.D_E_L_E_T_ <>'*' "
cQuery += 	"AND SE5.E5_SITUACA NOT IN ('X','C') "
cQuery += 	"AND SE5.E5_TIPO NOT IN ('NDF','PA') "
cQuery += 	"AND SE5.E5_TIPODOC <> 'ES' "
cQuery +=   " AND CVN.CVN_DTVIGF >= '"+DTOS(Paramixb[3])+"' "
cQuery +=   " AND CVN.CVN_ENTREF = '10'"
cQuery += 	"ORDER BY SE5.E5_DATA "

If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := QRY->A2_COD_MUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(QRY->A2_EST) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+QRY->A2_COD_MUN
	Endif
    
	nPos     := At(",",QRY->A2_END)
	cEndereco:= Alltrim(Substr(QRY->A2_END,1,nPos-1))
	cNumero  := Alltrim(Substr(QRY->A2_END,nPos+1,Len(SA2->A2_END)))

	cCodFor := " "
	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cDtSE2  := Substr(QRY->E5_DATA,7,2) + Substr(QRY->E5_DATA,5,2) + Substr(QRY->E5_DATA,1,4)	
	cCodFor := "SA2" + cFilAnt + QRY->E5_CLIFOR + QRY->E5_LOJA

	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= (QRY->E5_VLMULTA * QRY->ED_PCAPPIS) / 100
	nValCof	:= (QRY->E5_VLMULTA * QRY->ED_PCAPCOF) / 100
	
	cCNPJ	:= If(Len(Alltrim(QRY->A2_CGC)) == 14, QRY->A2_CGC, " ")
	cCPF	:= If(Len(Alltrim(QRY->A2_CGC)) <  14, QRY->A2_CGC, " ")
		

		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					QRY->E5_CLIFOR						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cDtSE2								,; 	&& F100 - 05 - DT_OPER
					QRY->E5_VLMULTA   					,; 	&& F100 - 06 - VL_OPER
					QRY->ED_CSTPIS						,;  && F100 - 07 - CST_PIS
					QRY->E5_VLMULTA						,;  && F100 - 08 - VL_BC_PIS
					nAliqPis		 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					QRY->ED_CSTCOF						,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					QRY->E5_VLMULTA						,; 	&& F100 - 12 - VL_BC_COFINS
					nAliqCof							,;  && F100 - 13 - ALIQ_COFINS
					nValCof								,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					QRY->ED_CONTA						,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Multa.Recebida s/Tit"+QRY->E5_NUMERO	,;  && F100 - 19 - DESC_DOC_OPER
					QRY->E5_LOJA						,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					QRY->E5_CLIFOR						,;  && 0150 - 02 - COD_PART
					QRY->A2_NOME   						,;  && 0150 - 03 - NOME
					QRY->A2_CODPAIS						,; 	&& 0150 - 04 - COD_PAIS
					cCNPJ								,;  && 0150 - 05 - CNPJ
					cCPF								,;  && 0150 - 06 - CPF
					QRY->A2_INSCR						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					QRY->A2_BAIRRO 						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta(QRY->ED_CONTA))		,;	&& 0500 - 05 - NIVEL   			--------> "5"
					QRY->ED_CONTA						,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())

********************************* REND S/SELIC PERDCOMP
cQuery := 	"SELECT DISTINCT SED.ED_CODIGO, CT1.CT1_CONTA, CVD.CVD_CONTA, SED.ED_CONTA, CT2.CT2_VALOR, CT2.CT2_HIST,"
cQuery += 	"CT2.CT2_LOTE, CT2.CT2_DOC, CT2.CT2_LINHA, CT2.CT2_SBLOTE, CT2.CT2_DATA, "
cQuery += 	"SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, SED.ED_PCAPPIS, "
cQuery += 	"SED.ED_PCAPCOF,  CT1.CT1_NTSPED, CT1.CT1_DESC01, CVD.CVD_CTAREF, "
cQuery += 	"CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT "
cQuery +=	"FROM "+RetSqlName("CT2")+" CT2 "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON SED.ED_CODIGO = '0103002' AND SED.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON CT1.CT1_CONTA = '31301004' AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON CT1_CONTA = CVD_CONTA AND CVD_CODPLA = '000002' AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=   "INNER JOIN " + RetSqlName("CVN") + " CVN ON CVD.CVD_CODPLA = CVN.CVN_CODPLA AND CVD.CVD_VERSAO = CVN.CVN_VERSAO "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND CT2.D_E_L_E_T_ <> '*' "
cQuery +=	"AND CT2.CT2_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" CT2_CREDIT IN ('31301004','31301005') "
cQuery +=   " AND CVN.CVN_DTVIGF >= '"+DTOS(Paramixb[3])+"' "
cQuery +=   " AND CVN.CVN_ENTREF = '10'"
cQuery += 	"AND CT2.CT2_FILIAL = '"+cFilAnt+"' "  

If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := SM0->M0_CODMUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(SM0->M0_ESTCOB) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+SM0->M0_CODMUN
	Endif
    
	nPos     := At(",",SM0->M0_ENDCOB)
	cEndereco:= Alltrim(Substr(SM0->M0_ENDCOB,1,nPos-1))
	cNumero  := Alltrim(Substr(SM0->M0_ENDCOB,nPos+1,Len(SM0->M0_ENDCOB)))
	cDescric := Alltrim(QRY->CT2_LOTE)+"/"+Alltrim(QRY->CT2_SBLOTE)+"/"+Alltrim(QRY->CT2_DOC)+"/"+Alltrim(QRY->CT2_HIST)

	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cData  := Substr(QRY->CT2_DATA,7,2) + Substr(QRY->CT2_DATA,5,2) + Substr(QRY->CT2_DATA,1,4)	
	
	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= (QRY->CT2_VALOR * QRY->ED_PCAPPIS) / 100
	nValCof	:= (QRY->CT2_VALOR * QRY->ED_PCAPCOF) / 100
		

		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					SM0->M0_CODFIL						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cData								,; 	&& F100 - 05 - DT_OPER
					QRY->CT2_VALOR   					,; 	&& F100 - 06 - VL_OPER
					QRY->ED_CSTPIS						,;  && F100 - 07 - CST_PIS
					QRY->CT2_VALOR						,;  && F100 - 08 - VL_BC_PIS
					nAliqPis		 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					QRY->ED_CSTCOF						,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					QRY->CT2_VALOR						,; 	&& F100 - 12 - VL_BC_COFINS
					nAliqCof							,;  && F100 - 13 - ALIQ_COFINS
					nValCof								,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					"31301004"							,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Rend.s/Selic"+cDescric				,;  && F100 - 19 - DESC_DOC_OPER
					""									,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					SM0->M0_CODFIL						,;  && 0150 - 02 - COD_PART
					SM0->M0_NOMECOM 					,;  && 0150 - 03 - NOME
					"01058"								,; 	&& 0150 - 04 - COD_PAIS
					SM0->M0_CGC							,;  && 0150 - 05 - CNPJ
					""									,;  && 0150 - 06 - CPF
					SM0->M0_INSC						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					SM0->M0_BAIRCOB						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta("31301004"))			,;	&& 0500 - 05 - NIVEL   			--------> "5"
					"31301004"							,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())

********************************* JUROS COMPENSADOS RECEBIDOS ANTERIORMENTE
cQuery := 	"SELECT DISTINCT SED.ED_CODIGO, CT1.CT1_CONTA, CVD.CVD_CONTA, SED.ED_CONTA, CT2.CT2_VALOR, CT2.CT2_HIST,"
cQuery += 	"CT2.CT2_LOTE, CT2.CT2_DOC, CT2.CT2_LINHA, CT2.CT2_SBLOTE, CT2.CT2_DATA, "
cQuery += 	"SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, SED.ED_PCAPPIS, "
cQuery += 	"SED.ED_PCAPCOF,  CT1.CT1_NTSPED, CT1.CT1_DESC01, CVD.CVD_CTAREF, "
cQuery += 	"CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT "
cQuery +=	"FROM "+RetSqlName("CT2")+" CT2 "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON SED.ED_CODIGO = '0103006' AND SED.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON CT1.CT1_CONTA = '31301006' AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON CT1_CONTA = CVD_CONTA AND CVD_CODPLA = '000002' AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=   "INNER JOIN " + RetSqlName("CVN") + " CVN ON CVD.CVD_CODPLA = CVN.CVN_CODPLA AND CVD.CVD_VERSAO = CVN.CVN_VERSAO "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND CT2.D_E_L_E_T_ <> '*' "
cQuery +=	"AND CT2.CT2_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" CT2_CREDIT IN ('31301006') "
cQuery +=   " AND CVN.CVN_DTVIGF >= '"+DTOS(Paramixb[3])+"' "
cQuery +=   " AND CVN.CVN_ENTREF = '10'"
cQuery += 	"AND CT2.CT2_FILIAL = '"+cFilAnt+"' "  

If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := SM0->M0_CODMUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(SM0->M0_ESTCOB) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+SM0->M0_CODMUN
	Endif
    
	nPos     := At(",",SM0->M0_ENDCOB)
	cEndereco:= Alltrim(Substr(SM0->M0_ENDCOB,1,nPos-1))
	cNumero  := Alltrim(Substr(SM0->M0_ENDCOB,nPos+1,Len(SM0->M0_ENDCOB)))
	cDescric := Alltrim(QRY->CT2_LOTE)+"/"+Alltrim(QRY->CT2_SBLOTE)+"/"+Alltrim(QRY->CT2_DOC)+"/"+Alltrim(QRY->CT2_HIST)

	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cData  := Substr(QRY->CT2_DATA,7,2) + Substr(QRY->CT2_DATA,5,2) + Substr(QRY->CT2_DATA,1,4)	
	
	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= (QRY->CT2_VALOR * QRY->ED_PCAPPIS) / 100
	nValCof	:= (QRY->CT2_VALOR * QRY->ED_PCAPCOF) / 100
		

		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					SM0->M0_CODFIL						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cData								,; 	&& F100 - 05 - DT_OPER
					QRY->CT2_VALOR   					,; 	&& F100 - 06 - VL_OPER
					QRY->ED_CSTPIS						,;  && F100 - 07 - CST_PIS
					QRY->CT2_VALOR						,;  && F100 - 08 - VL_BC_PIS
					nAliqPis		 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					QRY->ED_CSTCOF						,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					QRY->CT2_VALOR						,; 	&& F100 - 12 - VL_BC_COFINS
					nAliqCof							,;  && F100 - 13 - ALIQ_COFINS
					nValCof								,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					"31301006"							,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Juros comp."+cDescric				,;  && F100 - 19 - DESC_DOC_OPER
					""									,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					SM0->M0_CODFIL						,;  && 0150 - 02 - COD_PART
					SM0->M0_NOMECOM 					,;  && 0150 - 03 - NOME
					"01058"								,; 	&& 0150 - 04 - COD_PAIS
					SM0->M0_CGC							,;  && 0150 - 05 - CNPJ
					""									,;  && 0150 - 06 - CPF
					SM0->M0_INSC						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					SM0->M0_BAIRCOB						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta("31301006"))			,;	&& 0500 - 05 - NIVEL   			--------> "5"
					"31301006"							,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())

/*
********************************* CORRE«√O MONET¡RIA
cQuery := 	"SELECT E5_FILIAL, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_DATA, "
cQuery += 	"E5_VLDESCO, E5_VLCORRE, E5_VLJUROS, E5_VALOR, E5_NATUREZ, "
cQuery += 	"E5_PREFIXO, E5_NUMERO, E5_SEQ, SA2.A2_COD_MUN, SA2.A2_NOME, SA2.A2_CODPAIS, SA2.A2_EST, "
cQuery += 	"SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_END, SED.ED_CONTA, SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, "
cQuery += 	"SED.ED_PCAPPIS, SED.ED_PCAPCOF, SA2.A2_BAIRRO, CT1.CT1_NTSPED, CT1.CT1_DESC01, "
cQuery += 	"CVD.CVD_CTAREF, CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT " 
cQuery +=	"FROM "+RetSqlName("SE5")+" SE5 "
cQuery += 	"LEFT JOIN "+RetSqlName("SA2")+" SA2 ON "
cQuery +=	"SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA AND SA2.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON "
cQuery += 	"SED.ED_CODIGO = '0103002' AND SED.D_E_L_E_T_ <> '*' "
cQuery +=	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON "	
cQuery +=	"SED.ED_CONTA = CVD.CVD_CONTA AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "	
cQuery +=	"CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND SE5.E5_FILIAL = '"+cFilAnt+"' "
cQuery +=	"AND SE5.E5_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" SE5.E5_VLCORRE > 0 "
cQuery += 	"AND SE5.E5_RECPAG = 'R' "
cQuery += 	"AND SE5.D_E_L_E_T_ <>'*' "
cQuery += 	"AND SE5.E5_SITUACA NOT IN ('X','C') "
cQuery += 	"AND SE5.E5_TIPO NOT IN ('RA ','NDF','PA ') "
cQuery += 	"ORDER BY SE5.E5_DATA "

If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := QRY->A2_COD_MUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(QRY->A2_EST) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+QRY->A2_COD_MUN
	Endif
    
	nPos     := At(",",QRY->A2_END)
	cEndereco:= Alltrim(Substr(QRY->A2_END,1,nPos-1))
	cNumero  := Alltrim(Substr(QRY->A2_END,nPos+1,Len(SA2->A2_END)))

	cCodFor := " "
	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cDtSE2  := Substr(QRY->E5_DATA,7,2) + Substr(QRY->E5_DATA,5,2) + Substr(QRY->E5_DATA,1,4)	
	cCodFor := "SA2" + cFilAnt + QRY->E5_CLIFOR + QRY->E5_LOJA

	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= (QRY->E5_VLCORRE * QRY->ED_PCAPPIS) / 100
	nValCof	:= (QRY->E5_VLCORRE * QRY->ED_PCAPCOF) / 100
	
	cCNPJ	:= If(Len(Alltrim(QRY->A2_CGC)) == 14, QRY->A2_CGC, " ")
	cCPF	:= If(Len(Alltrim(QRY->A2_CGC)) <  14, QRY->A2_CGC, " ")
		

		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					QRY->E5_CLIFOR						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cDtSE2								,; 	&& F100 - 05 - DT_OPER
					QRY->E5_VLCORRE   					,; 	&& F100 - 06 - VL_OPER
					QRY->ED_CSTPIS						,;  && F100 - 07 - CST_PIS
					QRY->E5_VLCORRE						,;  && F100 - 08 - VL_BC_PIS
					nAliqPis		 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					QRY->ED_CSTCOF						,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					QRY->E5_VLCORRE						,; 	&& F100 - 12 - VL_BC_COFINS
					nAliqCof							,;  && F100 - 13 - ALIQ_COFINS
					nValCof								,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					QRY->ED_CONTA						,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Correcao Monet.s/"+QRY->E5_NUMERO	,;  && F100 - 19 - DESC_DOC_OPER
					QRY->E5_LOJA						,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					QRY->E5_CLIFOR						,;  && 0150 - 02 - COD_PART
					QRY->A2_NOME   						,;  && 0150 - 03 - NOME
					QRY->A2_CODPAIS						,; 	&& 0150 - 04 - COD_PAIS
					cCNPJ								,;  && 0150 - 05 - CNPJ
					cCPF								,;  && 0150 - 06 - CPF
					QRY->A2_INSCR						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					QRY->A2_BAIRRO 						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta(QRY->ED_CONTA))		,;	&& 0500 - 05 - NIVEL   			--------> "5"
					QRY->ED_CONTA						,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())
*/

********************************* TITULO PAGAMENTO PIS NATUEZA 0211001
cQuery := 	"SELECT DISTINCT E5_FILIAL, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_DATA, "
cQuery += 	"E5_VLDESCO, E5_VLCORRE, E5_VLJUROS, E5_VALOR, E5_NATUREZ, E5_HISTOR, "
cQuery += 	"E5_PREFIXO, E5_NUMERO, E5_SEQ, SA2.A2_COD_MUN, SA2.A2_NOME, SA2.A2_CODPAIS, SA2.A2_EST, "
cQuery += 	"SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_END, SED.ED_CONTA, SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, "
cQuery += 	"SED.ED_PCAPPIS, SED.ED_PCAPCOF, SA2.A2_BAIRRO, CT1.CT1_NTSPED, CT1.CT1_DESC01, "
cQuery += 	"CVD.CVD_CTAREF, CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT " 
cQuery +=	"FROM "+RetSqlName("SE5")+" SE5 "
cQuery += 	"LEFT JOIN "+RetSqlName("SA2")+" SA2 ON "
cQuery +=	"SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA AND SA2.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON "
cQuery += 	"SED.ED_CODIGO = '0211001' AND SED.D_E_L_E_T_ <> '*' "
cQuery +=	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON "	
cQuery +=	"SED.ED_CONTA = CVD.CVD_CONTA AND CVD_CODPLA = '000002' AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=   "INNER JOIN " + RetSqlName("CVN") + " CVN ON "
cQuery +=   "CVD.CVD_CODPLA = CVN.CVN_CODPLA AND CVD.CVD_VERSAO = CVN.CVN_VERSAO "
cQuery +=	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "	
cQuery +=	"CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND SE5.E5_FILIAL = '"+cFilAnt+"' "  
cQuery +=	"AND SE5.E5_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" SE5.E5_RECPAG = 'P' "
cQuery += 	"AND SE5.D_E_L_E_T_ <>'*' "
cQuery += 	"AND SE5.E5_SITUACA NOT IN ('X','C') "
cQuery += 	"AND SE5.E5_NATUREZ = '0211001' "
cQuery += 	"AND SE5.E5_TIPODOC IN ('BA','BL','VL') "
cQuery +=   " AND CVN.CVN_DTVIGF >= '"+DTOS(Paramixb[3])+"' "
cQuery +=   " AND CVN.CVN_ENTREF = '10'"
cQuery += 	"ORDER BY SE5.E5_DATA "


If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := SM0->M0_CODMUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(SM0->M0_ESTCOB) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+SM0->M0_CODMUN
	Endif
    
	nPos     := At(",",QRY->A2_END)
	cEndereco:= Alltrim(Substr(SM0->M0_ENDCOB,1,nPos-1))
	cNumero  := Alltrim(Substr(SM0->M0_ENDCOB,nPos+1,Len(SM0->M0_ENDCOB)))
	cDescric := Alltrim(QRY->E5_HISTOR)

	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cData  := Substr(QRY->E5_DATA,7,2) + Substr(QRY->E5_DATA,5,2) + Substr(QRY->E5_DATA,1,4)	
	
	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= (QRY->E5_VALOR / QRY->ED_PCAPPIS) * 100
	nValCof	:= 0  // (QRY->CT2_VALOR * QRY->ED_PCAPCOF) / 100
		

		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					SM0->M0_CODFIL						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cData								,; 	&& F100 - 05 - DT_OPER
					nValPis								,; 	&& F100 - 06 - VL_OPER
					QRY->ED_CSTPIS						,;  && F100 - 07 - CST_PIS
					QRY->E5_VALOR						,;  && F100 - 08 - VL_BC_PIS
					nAliqPis		 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					""									,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					nValCof								,; 	&& F100 - 12 - VL_BC_COFINS
					nValCof								,;  && F100 - 13 - ALIQ_COFINS
					nValCof								,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					QRY->ED_CONTA						,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Pis s/Imp."+cDescric				,;  && F100 - 19 - DESC_DOC_OPER
					""									,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					SM0->M0_CODFIL						,;  && 0150 - 02 - COD_PART
					SM0->M0_NOMECOM 					,;  && 0150 - 03 - NOME
					"01058"								,; 	&& 0150 - 04 - COD_PAIS
					SM0->M0_CGC							,;  && 0150 - 05 - CNPJ
					""									,;  && 0150 - 06 - CPF
					SM0->M0_INSC						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					SM0->M0_BAIRCOB						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta("31301004"))			,;	&& 0500 - 05 - NIVEL   			--------> "5"
					QRY->ED_CONTA						,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())


********************************* TITULO PAGAMENTO COFINS NATUREZA 0211003
cQuery := 	"SELECT DISTINCT E5_FILIAL, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_DATA, "
cQuery += 	"E5_VLDESCO, E5_VLCORRE, E5_VLJUROS, E5_VALOR, E5_NATUREZ, E5_HISTOR, "
cQuery += 	"E5_PREFIXO, E5_NUMERO, E5_SEQ, SA2.A2_COD_MUN, SA2.A2_NOME, SA2.A2_CODPAIS, SA2.A2_EST, "
cQuery += 	"SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_END, SED.ED_CONTA, SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, "
cQuery += 	"SED.ED_PCAPPIS, SED.ED_PCAPCOF, SA2.A2_BAIRRO, CT1.CT1_NTSPED, CT1.CT1_DESC01, "
cQuery += 	"CVD.CVD_CTAREF, CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT " 
cQuery +=	"FROM "+RetSqlName("SE5")+" SE5 "
cQuery += 	"LEFT JOIN "+RetSqlName("SA2")+" SA2 ON "
cQuery +=	"SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA AND SA2.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON "
cQuery += 	"SED.ED_CODIGO = '0211003' AND SED.D_E_L_E_T_ <> '*' "
cQuery +=	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON "	
cQuery +=	"SED.ED_CONTA = CVD.CVD_CONTA AND CVD_CODPLA = '000002' AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=   "INNER JOIN " + RetSqlName("CVN") + " CVN ON "
cQuery +=   "CVD.CVD_CODPLA = CVN.CVN_CODPLA AND CVD.CVD_VERSAO = CVN.CVN_VERSAO "
cQuery +=	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "	
cQuery +=	"CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND SE5.E5_FILIAL = '"+cFilAnt+"' "  
cQuery +=	"AND SE5.E5_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" SE5.E5_RECPAG = 'P' "
cQuery += 	"AND SE5.D_E_L_E_T_ <>'*' "
cQuery += 	"AND SE5.E5_SITUACA NOT IN ('X','C') "
cQuery += 	"AND SE5.E5_NATUREZ = '0211003' "
cQuery += 	"AND SE5.E5_TIPODOC IN ('BA','BL','VL') "
cQuery +=   " AND CVN.CVN_DTVIGF >= '"+DTOS(Paramixb[3])+"' "
cQuery +=   " AND CVN.CVN_ENTREF = '10'"
cQuery += 	"ORDER BY SE5.E5_DATA "

If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := SM0->M0_CODMUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(SM0->M0_ESTCOB) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+SM0->M0_CODMUN
	Endif
    
	nPos     := At(",",QRY->A2_END)
	cEndereco:= Alltrim(Substr(SM0->M0_ENDCOB,1,nPos-1))
	cNumero  := Alltrim(Substr(SM0->M0_ENDCOB,nPos+1,Len(SM0->M0_ENDCOB)))
	cDescric := Alltrim(QRY->E5_HISTOR)

	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cData  := Substr(QRY->E5_DATA,7,2) + Substr(QRY->E5_DATA,5,2) + Substr(QRY->E5_DATA,1,4)
	
	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= 0 //(QRY->CT2_VALOR * QRY->ED_PCAPPIS) / 100
	nValCof	:= (QRY->E5_VALOR / QRY->ED_PCAPCOF) * 100
		

		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					SM0->M0_CODFIL						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cData								,; 	&& F100 - 05 - DT_OPER
					nValCof			   					,; 	&& F100 - 06 - VL_OPER
					""									,;  && F100 - 07 - CST_PIS
					nValPis								,;  && F100 - 08 - VL_BC_PIS
					nValPis			 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					QRY->ED_CSTCOF						,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					nValCof								,; 	&& F100 - 12 - VL_BC_COFINS
					nAliqCof							,;  && F100 - 13 - ALIQ_COFINS
					QRY->E5_VALOR						,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					QRY->ED_CONTA						,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Cofins s/"+cDescric				,;  && F100 - 19 - DESC_DOC_OPER
					""									,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					SM0->M0_CODFIL						,;  && 0150 - 02 - COD_PART
					SM0->M0_NOMECOM 					,;  && 0150 - 03 - NOME
					"01058"								,; 	&& 0150 - 04 - COD_PAIS
					SM0->M0_CGC							,;  && 0150 - 05 - CNPJ
					""									,;  && 0150 - 06 - CPF
					SM0->M0_INSC						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					SM0->M0_BAIRCOB						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta(QRY->ED_CONTA))		,;	&& 0500 - 05 - NIVEL   			--------> "5"
					QRY->ED_CONTA						,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())


********************************* DESCONTOS OBTIDOS
cQuery := 	"SELECT DISTINCT E5_FILIAL, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_DATA, "
cQuery += 	"E5_VLDESCO, E5_VLCORRE, E5_VLJUROS, E5_VALOR, E5_NATUREZ, "
cQuery += 	"E5_PREFIXO, E5_NUMERO, E5_SEQ, SA2.A2_COD_MUN, SA2.A2_NOME, SA2.A2_CODPAIS, SA2.A2_EST, "
cQuery += 	"SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_END, SED.ED_CONTA, SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, "
cQuery += 	"SED.ED_PCAPPIS, SED.ED_PCAPCOF, SA2.A2_BAIRRO, CT1.CT1_NTSPED, CT1.CT1_DESC01, "
cQuery += 	"CVD.CVD_CTAREF, CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT " 
cQuery +=	"FROM "+RetSqlName("SE5")+" SE5 "
cQuery += 	"LEFT JOIN "+RetSqlName("SA2")+" SA2 ON "
cQuery +=	"SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA AND SA2.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON "
cQuery += 	"SED.ED_CODIGO = '0103003' AND SED.D_E_L_E_T_ <> '*' "
cQuery +=	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON "	
cQuery +=	"SED.ED_CONTA = CVD.CVD_CONTA AND CVD_CODPLA = '000002' AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=   "INNER JOIN " + RetSqlName("CVN") + " CVN ON "
cQuery +=   "CVD.CVD_CODPLA = CVN.CVN_CODPLA AND CVD.CVD_VERSAO = CVN.CVN_VERSAO "
cQuery +=	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "	
cQuery +=	"CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND SE5.E5_FILIAL = '"+cFilAnt+"' "  
cQuery +=	"AND SE5.E5_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" SE5.E5_VLDESCO > 0 "
cQuery += 	"AND SE5.E5_RECPAG = 'P' "
cQuery += 	"AND SE5.D_E_L_E_T_ <>'*' "
cQuery += 	"AND SE5.E5_SITUACA NOT IN ('X','C') "
cQuery += 	"AND SE5.E5_TIPODOC NOT IN ('ES') "
cQuery += 	"AND SE5.E5_TIPO <> 'RA ' "
cQuery +=   " AND CVN.CVN_DTVIGF >= '"+DTOS(Paramixb[3])+"' "
cQuery +=   " AND CVN.CVN_ENTREF = '10'"
cQuery += 	"ORDER BY SE5.E5_DATA "

If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := QRY->A2_COD_MUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(QRY->A2_EST) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+QRY->A2_COD_MUN
	Endif
    
	nPos     := At(",",QRY->A2_END)
	cEndereco:= Alltrim(Substr(QRY->A2_END,1,nPos-1))
	cNumero  := Alltrim(Substr(QRY->A2_END,nPos+1,Len(SA2->A2_END)))

	cCodFor := " "
	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cDtSE2  := Substr(QRY->E5_DATA,7,2) + Substr(QRY->E5_DATA,5,2) + Substr(QRY->E5_DATA,1,4)	
	cCodFor := "SA2" + cFilAnt + QRY->E5_CLIFOR + QRY->E5_LOJA

	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= (QRY->E5_VLDESCO * QRY->ED_PCAPPIS) / 100
	nValCof	:= (QRY->E5_VLDESCO * QRY->ED_PCAPCOF) / 100
	
	cCNPJ	:= If(Len(Alltrim(QRY->A2_CGC)) == 14, QRY->A2_CGC, " ")
	cCPF	:= If(Len(Alltrim(QRY->A2_CGC)) <  14, QRY->A2_CGC, " ")
		
		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					QRY->E5_CLIFOR						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cDtSE2								,; 	&& F100 - 05 - DT_OPER
					QRY->E5_VLDESCO   					,; 	&& F100 - 06 - VL_OPER
					QRY->ED_CSTPIS						,;  && F100 - 07 - CST_PIS
					QRY->E5_VLDESCO						,;  && F100 - 08 - VL_BC_PIS
					nAliqPis		 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					QRY->ED_CSTCOF						,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					QRY->E5_VLDESCO						,; 	&& F100 - 12 - VL_BC_COFINS
					nAliqCof							,;  && F100 - 13 - ALIQ_COFINS
					nValCof								,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					QRY->ED_CONTA						,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Desc.Obtido s/Tit"+QRY->E5_NUMERO	,;  && F100 - 19 - DESC_DOC_OPER
					QRY->E5_LOJA						,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					QRY->E5_CLIFOR						,;  && 0150 - 02 - COD_PART
					QRY->A2_NOME   						,;  && 0150 - 03 - NOME
					QRY->A2_CODPAIS						,; 	&& 0150 - 04 - COD_PAIS
					cCNPJ								,;  && 0150 - 05 - CNPJ
					cCPF								,;  && 0150 - 06 - CPF
					QRY->A2_INSCR						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					QRY->A2_BAIRRO 						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta(QRY->ED_CONTA))		,;	&& 0500 - 05 - NIVEL   			--------> "5"
					QRY->ED_CONTA						,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())

********************************* DESCONTOS OBTIDOS ******* PA/NDF
cQuery := 	"SELECT DISTINCT E5_FILIAL, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_DATA, "
cQuery += 	"E5_VLDESCO, E5_VLCORRE, E5_VLJUROS, E5_VALOR, E5_NATUREZ, "
cQuery += 	"E5_PREFIXO, E5_NUMERO, E5_SEQ, SA2.A2_COD_MUN, SA2.A2_NOME, SA2.A2_CODPAIS, SA2.A2_EST, "
cQuery += 	"SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_END, SED.ED_CONTA, SED.ED_CSTPIS, SED.ED_CSTCOF, SED.ED_CLASFIS, "
cQuery += 	"SED.ED_PCAPPIS, SED.ED_PCAPCOF, SA2.A2_BAIRRO, CT1.CT1_NTSPED, CT1.CT1_DESC01, "
cQuery += 	"CVD.CVD_CTAREF, CT1.CT1_DTEXIS, SED.ED_TPREG, SED.ED_TABCCZ, SED.ED_CODCCZ, SED.ED_GRUCCZ, SED.ED_INDCMLT " 
cQuery +=	"FROM "+RetSqlName("SE5")+" SE5 "
cQuery += 	"LEFT JOIN "+RetSqlName("SA2")+" SA2 ON "
cQuery +=	"SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA AND SA2.D_E_L_E_T_ <> '*' "
cQuery += 	"LEFT JOIN "+RetSqlName("SED")+" SED ON "
cQuery += 	"SED.ED_CODIGO = '0103003' AND SED.D_E_L_E_T_ <> '*' "
cQuery +=	"LEFT JOIN "+RetSqlName("CVD")+" CVD ON "	
cQuery +=	"SED.ED_CONTA = CVD.CVD_CONTA AND CVD_CODPLA = '000002' AND CVD.D_E_L_E_T_ <> '*' "
cQuery +=   "INNER JOIN " + RetSqlName("CVN") + " CVN ON "
cQuery +=   "CVD.CVD_CODPLA = CVN.CVN_CODPLA AND CVD.CVD_VERSAO = CVN.CVN_VERSAO "
cQuery +=	"LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "	
cQuery +=	"CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "
cQuery += 	"WHERE 1=1 "
cQuery += 	"AND SE5.E5_FILIAL = '"+cFilAnt+"' "  
cQuery +=	"AND SE5.E5_DATA BETWEEN '"+DTOS(Paramixb[2])+"' AND '"+DTOS(Paramixb[3])+"' AND "
cQuery += 	" SE5.E5_VLDESCO > 0 "
cQuery += 	"AND SE5.E5_RECPAG = 'R' "
cQuery += 	"AND SE5.D_E_L_E_T_ <>'*' "
cQuery += 	"AND SE5.E5_SITUACA NOT IN ('X','C') "
cQuery += 	"AND SE5.E5_TIPO IN ('PA ','NDF') "
cQuery +=   " AND CVN.CVN_DTVIGF >= '"+DTOS(Paramixb[3])+"' "
cQuery +=   " AND CVN.CVN_ENTREF = '10'"
cQuery += 	"ORDER BY SE5.E5_DATA "

If Select("QRY") <> 0
	QRY->(dbCloseArea())
Endif

TcQuery cQuery Alias "QRY" New

QRY->(dbGoTop())
Do While QRY->(!Eof())
    
	cCodMun := QRY->A2_COD_MUN
	nPos    := Ascan( aUF, { |x| Alltrim(x[1]) == Alltrim(QRY->A2_EST) } )	
	If nPos > 0
		cCodMun := aUF[nPos,02]+QRY->A2_COD_MUN
	Endif
    
	nPos     := At(",",QRY->A2_END)
	cEndereco:= Alltrim(Substr(QRY->A2_END,1,nPos-1))
	cNumero  := Alltrim(Substr(QRY->A2_END,nPos+1,Len(SA2->A2_END)))

	cCodFor := " "
	cDtCTB  := Substr(QRY->CT1_DTEXIS,7,2) + Substr(QRY->CT1_DTEXIS,5,2) + Substr(QRY->CT1_DTEXIS,1,4)
	cDtSE2  := Substr(QRY->E5_DATA,7,2) + Substr(QRY->E5_DATA,5,2) + Substr(QRY->E5_DATA,1,4)	
	cCodFor := "SA2" + cFilAnt + QRY->E5_CLIFOR + QRY->E5_LOJA

	nAliqPis:= QRY->ED_PCAPPIS
	nAliqCof:= QRY->ED_PCAPCOF
	nValPis	:= (QRY->E5_VLDESCO * QRY->ED_PCAPPIS) / 100
	nValCof	:= (QRY->E5_VLDESCO * QRY->ED_PCAPCOF) / 100
	
	cCNPJ	:= If(Len(Alltrim(QRY->A2_CGC)) == 14, QRY->A2_CGC, " ")
	cCPF	:= If(Len(Alltrim(QRY->A2_CGC)) <  14, QRY->A2_CGC, " ")
		
		
	Aadd( aRet, {	"F100"								,; 	&& F100 - 01 - REG
					"1"									,; 	&& F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
					QRY->E5_CLIFOR						,; 	&& F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida=  SA1->A1_COD)
					""									,;	&& F100 - 04 - COD_ITEM
					cDtSE2								,; 	&& F100 - 05 - DT_OPER
					QRY->E5_VLDESCO   					,; 	&& F100 - 06 - VL_OPER
					QRY->ED_CSTPIS						,;  && F100 - 07 - CST_PIS
					QRY->E5_VLDESCO						,;  && F100 - 08 - VL_BC_PIS
					nAliqPis		 					,;  && F100 - 09 - ALIQ_PIS
					nValPis								,;  && F100 - 10 - VL_PIS
					QRY->ED_CSTCOF						,;  && F100 - 11 - CST_COFINS  		-> QRY->ED_CSTCOF
					QRY->E5_VLDESCO						,; 	&& F100 - 12 - VL_BC_COFINS
					nAliqCof							,;  && F100 - 13 - ALIQ_COFINS
					nValCof								,;  && F100 - 14 - VL_COFINS 					
					QRY->ED_CLASFIS	 					,;  && F100 - 15 - NAT_BC_CRED		-> QRY->ED_CLASFIS
					"0"									,;  && F100 - 16 - IND_ORIG_CRED
					QRY->ED_CONTA						,;  && F100 - 17 - COD_CTA			-> QRY->ED_CONTA
					""									,;  && F100 - 18 - COD_CCUS
					"Desc.Obtido s/Tit"+QRY->E5_NUMERO	,;  && F100 - 19 - DESC_DOC_OPER
					QRY->E5_LOJA						,;  && F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
					QRY->ED_TPREG						,;  && F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
					QRY->E5_CLIFOR						,;  && 0150 - 02 - COD_PART
					QRY->A2_NOME   						,;  && 0150 - 03 - NOME
					QRY->A2_CODPAIS						,; 	&& 0150 - 04 - COD_PAIS
					cCNPJ								,;  && 0150 - 05 - CNPJ
					cCPF								,;  && 0150 - 06 - CPF
					QRY->A2_INSCR						,;  && 0150 - 07 - IE
					cCodMun 							,;  && 0150 - 08 - COD_MUN
					""	         						,;  && 0150 - 09 - SUFRAMA
					cEndereco   						,;  && 0150 - 10 - END
					cNumero								,;  && 0150 - 11 - NUM
					""									,;  && 0150 - 12 - COMPL
					QRY->A2_BAIRRO 						,;  && 0150 - 13 - BAIRRO					
					cDtCTB								,;	&& 0500 - 02 - DT_ALT   		--------> cDtCTB
					QRY->CT1_NTSPED						,;	&& 0500 - 03 - COD_NAT_CC		--------> QRY->CT1_NTSPED
					"A"									,;	&& 0500 - 04 - IND_CTA			--------> "A"
					Str(CtbNivCta(QRY->ED_CONTA))		,;	&& 0500 - 05 - NIVEL   			--------> "5"
					QRY->ED_CONTA						,;	&& 0500 - 06 - COD_CTA			--------> QRY->CT1_CONTA
					QRY->CT1_DESC01						,;	&& 0500 - 07 - NOME_CTA			--------> QRY->CT1_DESC01
					QRY->CVD_CTAREF						,;	&& 0500 - 08 - COD_CTA_REF		--------> QRY->CVD_CTAREF
					SM0->M0_CGC							,;	&& 0500 - 09 - CNPJ_EST
					QRY->ED_TABCCZ						,;	&& Codigo da tabela da Natureza da Receita.
					QRY->ED_CODCCZ						,;	&& Codigo da Natureza da Receita
					QRY->ED_GRUCCZ						,;	&& Grupo da Natureza da Receita
					""									,;	&& Dt.Fim Natureza da Receita
					""									,;  && 0600 - 02 - DT_ALT
					""									,;  && 0600 - 03 - COD_CCUS
					""})									&& 0600 - 04 - CCUS
	
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())

RestArea(aAreaAtu)

Return aRet

