#include 'protheus.ch'
#include 'topconn.ch'
#include 'rwmake.ch'


/*/{Protheus.doc} conciliaDDA
Realiza a conciliação DDA com mais critério de analise e possibilita a conciliação manual do DDA.
@type function
@version 12.1.27
@author Leandro Cesar
@since 15/08/2022
/*/
user function conciliaDDA()
	Local aArea		:= GetArea()
	local oTitulo
	local aTitulo	:= {}
	local dDtIni	:= CTOD("01/01/2001","DDMMYY")
	local dDtFin	:= CTOD("01/01/2001","DDMMYY")
	local aSize 	:= MSADVSIZE(.F.)
	local aRegs 	:= {}
	local aHelpPor 	:= {}
	local aHelpSpa	:= {}
	local aHelpEng 	:= {}
	local cPerg 	:= padr("PCONCDDA",10)
	local aSM0		:= RetSM0()
	local lContinua := .T.
	local cCPNEG	:=	MV_CPNEG
	local aAuxSE2	:= {}
	local nNivel	:= 19
	local nX     	:= 0
	local nOpc2		:= 2
	private aStatus := {}
	private oOk		:= LoadBitmap( GetResources(), "ENABLE"				)	//Nivel 1
	private oN2		:= LoadBitmap( GetResources(), "BR_AZUL"			)	//Nivel 2
	private oN3		:= LoadBitmap( GetResources(), "BR_PRETO"			)	//Nivel 3
	private oN4		:= LoadBitmap( GetResources(), "BR_CINZA"			)	//Nivel 4
	private oN5		:= LoadBitmap( GetResources(), "BR_BRANCO"			)	//Nivel 5
	private oN6		:= LoadBitmap( GetResources(), "BR_AMARELO"			)	//Nivel 6
	private oN7		:= LoadBitmap( GetResources(), "BR_LARANJA"			)	//Nivel 7
	private oN8		:= LoadBitmap( GetResources(), "BR_PINK"			)	//Nivel 8
	private oN9		:= LoadBitmap( GetResources(), "BR_VIOLETA"			)	//Nivel 9
	private oN10	:= LoadBitmap( GetResources(), "BR_AZUL_CLARO"		)	//Nivel 10
	private oN11	:= LoadBitmap( GetResources(), "BR_MARROM"			)	//Nivel 11
	private oN12	:= LoadBitmap( GetResources(), "F14_AZUL.PNG"		)	//Nivel 12
	private oN13	:= LoadBitmap( GetResources(), "BR_VERDE_ESCURO"	)	//Nivel 13
	private oN14	:= LoadBitmap( GetResources(), "BR_VERMELHO"		)	//Nivel 14
	private oN15	:= LoadBitmap( GetResources(), "F10_AMAR.PNG"		)	//Nivel 15
	private oN16	:= LoadBitmap( GetResources(), "F10_VERM_OCEAN.PNG"	)	//Nivel 16
	private oN17	:= LoadBitmap( GetResources(), "F5_VERM_OCEAN.PNG"	)	//Nivel 17
	private oNo		:= LoadBitmap( GetResources(), "BR_CANCEL"			)	//Nivel 18

	private oN19	:= LoadBitmap( GetResources(), "UPDWARNING17.PNG"	)	//Nivel 19
	private oN18	:= LoadBitmap( GetResources(), "FWSTD_MNU_CUT.PNG"	)	//Nivel 20
	private oN21	:= LoadBitmap( GetResources(), "TMKIMG16_MDI.PNG"	)	//Nivel 21


	private aLegenda := {}

	static oDlgDDA
	static oTempDB

	aAdd(aStatus,oOk)
	aAdd(aStatus,oN2)
	aAdd(aStatus,oN3)
	aAdd(aStatus,oN4)
	aAdd(aStatus,oN5)
	aAdd(aStatus,oN6)
	aAdd(aStatus,oN7)
	aAdd(aStatus,oN8)
	aAdd(aStatus,oN9)
	aAdd(aStatus,oN10)
	aAdd(aStatus,oN11)
	aAdd(aStatus,oN12)
	aAdd(aStatus,oN13)
	aAdd(aStatus,oN14)
	aAdd(aStatus,oN15)
	aAdd(aStatus,oN16)
	aAdd(aStatus,oN17)
	aAdd(aStatus,oN19)
	aAdd(aStatus,oNo)
	aAdd(aStatus,oN18)
	aAdd(aStatus,oN21)

	aAdd(aLegenda, {"ENABLE"				,"CONCILIADO: FILIAL (OK), VENCIMENTO (OK), VALOR (OK), FORNECEDOR (OK)"})
	aAdd(aLegenda, {"BR_AZUL"				,"CONCILIADO: FILIAL (OK), VENCIMENTO (OK), VALOR (OK), FORNECEDOR (RZ)"})
	aAdd(aLegenda, {"BR_PRETO"				,"CONCILIADO: FILIAL (OK), VENCIMENTO (OK), VALOR (IN), FORNECEDOR (OK)"})
	aAdd(aLegenda, {"BR_CINZA"				,"CONCILIADO: FILIAL (OK), VENCIMENTO (OK), VALOR (IN), FORNECEDOR (RZ)"})
	aAdd(aLegenda, {"BR_BRANCO"				,"CONCILIADO: FILIAL (OK), VENCIMENTO (IN), VALOR (OK), FORNECEDOR (OK)"})
	aAdd(aLegenda, {"BR_AMARELO"			,"CONCILIADO: FILIAL (OK), VENCIMENTO (IN), VALOR (OK), FORNECEDOR (RZ)"})
	aAdd(aLegenda, {"BR_LARANJA"			,"CONCILIADO: FILIAL (OK), VENCIMENTO (IN), VALOR (IN), FORNECEDOR (OK)"})
	aAdd(aLegenda, {"BR_PINK"				,"CONCILIADO: FILIAL (OK), VENCIMENTO (IN), VALOR (IN), FORNECEDOR (RZ)"})
	aAdd(aLegenda, {"BR_VIOLETA"			,"CONCILIADO: FILIAL (DF), VENCIMENTO (OK), VALOR (OK), FORNECEDOR (OK)"})
	aAdd(aLegenda, {"BR_AZUL_CLARO"			,"CONCILIADO: FILIAL (DF), VENCIMENTO (OK), VALOR (OK), FORNECEDOR (RZ)"})
	aAdd(aLegenda, {"BR_MARROM"				,"CONCILIADO: FILIAL (DF), VENCIMENTO (OK), VALOR (IN), FORNECEDOR (OK)"})
	aAdd(aLegenda, {"F14_AZUL.PNG"			,"CONCILIADO: FILIAL (DF), VENCIMENTO (OK), VALOR (IN), FORNECEDOR (RZ)"})
	aAdd(aLegenda, {"BR_VERDE_ESCURO"		,"CONCILIADO: FILIAL (DF), VENCIMENTO (IN), VALOR (OK), FORNECEDOR (OK)"})
	aAdd(aLegenda, {"BR_VERMELHO"			,"CONCILIADO: FILIAL (DF), VENCIMENTO (IN), VALOR (OK), FORNECEDOR (RZ)"})
	aAdd(aLegenda, {"F10_AMAR.PNG"			,"CONCILIADO: FILIAL (DF), VENCIMENTO (IN), VALOR (IN), FORNECEDOR (OK)"})
	aAdd(aLegenda, {"F10_VERM_OCEAN.PNG"	,"CONCILIADO: FILIAL (DF), VENCIMENTO (IN), VALOR (IN), FORNECEDOR (RZ)"})
	aAdd(aLegenda, {"F5_VERM_OCEAN.PNG"		,"CONCILIADO MANUALMENTE"												})
	aAdd(aLegenda, {"UPDWARNING17.PNG"		,"POSSIVEL CONCILIACAO MANUAL"											})
	aAdd(aLegenda, {"BR_CANCEL"				,"NAO CONCILIADO"														})
	aAdd(aLegenda, {"FWSTD_MNU_CUT.PNG"		,"REGISTRO ENCERRADO PARA CONCILIACAO"									})
	aAdd(aLegenda, {"TMKIMG16_MDI.PNG"		,"REGISTRO DE ANTECIPACAO RECEBIVEL"									})

	//aAdd(aStatus,oNo)

	//	dbSelectArea("SX1")
	//	dbSetOrder(1)
	//	If !SX1->(dbSeek(cPerg))
	aAdd(aRegs,{"Filial De  			"	,"Filial De				"	,"Filial De				"	,"mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","","",""})
	aAdd(aRegs,{"Filial Ate 			"	,"Filial Ate			"	,"Filial Ate			"	,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","","",""})
	aAdd(aRegs,{"Fornecedor De			"	,"Fornecedor De			"	,"Fornecedor De			"	,"mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","",""})
	aAdd(aRegs,{"Fornecedor Ate			"	,"Fornecedor Ate		"	,"Fornecedor Ate		"	,"mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","",""})
	aAdd(aRegs,{"Loja De				"	,"Loja De				"	,"Loja De				"	,"mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","",""})
	aAdd(aRegs,{"Loja Ate				"	,"Loja Ate				"	,"Loja Ate				"	,"mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Considerar Data		"	,"Considerar Data		"	,"Considerar Data		"	,"mv_ch7","N",01,0,0,"C","","mv_par07","Vencimento","Vencimento","Vencimento","","","Vencimento Real","Vencimento Real","Vencimento Real","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Data Vencto De			"	,"Data Vencto De		"	,"Data Vencto De		"	,"mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Data Vencto Ate		"	,"Data Vencto Ate		"	,"Data Vencto Ate		"	,"mv_ch9","D",08,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Processado De			"	,"Processado De			"	,"Processado De			"	,"mv_chA","D",08,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Processado Ate			"	,"Processado Ate		"	,"Processado Ate		"	,"mv_chB","D",08,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Dias a Avancar			"	,"Dias a Avancar		"	,"Dias a Avancar		"	,"mv_chC","N",02,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Dias a Retroceder		"	,"Dias a Avancar		"	,"Dias a Avancar		"	,"mv_chD","N",02,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Diferenca a Menor		"	,"Diferenca a Menor		"	,"Diferenca a Menor		"	,"mv_chE","N",14,2,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Diferenca a Maior		"	,"Diferenca a Maior		"	,"Diferenca a Maior		"	,"mv_chF","N",14,2,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{"Considera DDA Encerrado"   ,"Considera DDA Encerrado"	,"Considera DDA Encerrado"	,"mv_chG","N",01,0,0,"C","","mv_par16","Sim","Sim","Sim","","","Nao","Nao","Nao","","","Ambos","Ambos","Ambos","","","","","","","","","","","","","","",""})
	CriaSX1(cPerg, aRegs)
	//	EndIf

	If !Pergunte(cPerg, .T. )
		Return( .F. )
	EndIf


	dDtIni	:= Max(dDtIni,Iif(Empty(mv_par08),dDtIni,mv_par08))
	dDtFin	:= Max(dDtFin,Iif(Empty(mv_par09),dDtFin,mv_par09))


	FIG->(dbSetOrder(2)) //Filial+Fornecedor+Loja+Vencto+Titulo
	cChave		:= FIG->(IndexKey())
	cAliasFIG	:= GetNextAlias()
	aStru		:= FIG->(dbStruct())
	cCampos		:= ""
	cFilIn		:= ''
	If !Empty(xFilial("SE2"))
		For nInc := 1 To Len( aSM0 )
			If aSM0[nInc][2] >= mv_par01 .and. aSM0[nInc][2] <= mv_par02
				cFilIn += aSM0[nInc][2] + "/"
			EndIf
		Next
	Else
		cFilIn := xFilial("SE2")
	Endif


	CONCFIG()
	CriArq()

	aEval(aStru,{|x| cCampos += ","+AllTrim(x[1])})

	cQuery := " WITH TEMP AS ( "
	cQuery += " SELECT "+SubStr(cCampos,2) + ", R_E_C_N_O_ RECNOFIG, "
	cQuery += " ROW_NUMBER() OVER( PARTITION BY FIG_FILIAL,FIG_TITULO,FIG_CNPJ ORDER BY R_E_C_N_O_ DESC) CONTADOR "
	cQuery += " FROM " + RetSqlName("FIG") + " FIG  "
	//cQuery += " WHERE FIG_FILIAL 	IN "  + FormatIn(cFilIn,"/")
	cQuery += " WHERE FIG_FILIAL 	>= '" + mv_par01 + "' "
	cQuery += "   AND FIG_FILIAL 	<= '" + mv_par02 + "' "
	cQuery += "   AND FIG_FORNEC	>= '" + mv_par03 + "' "
	cQuery += "   AND FIG_FORNEC	<= '" + mv_par04 + "' "
	cQuery += "   AND FIG_LOJA		>= '" + mv_par05 + "' "
	cQuery += "   AND FIG_LOJA		<= '" + mv_par06 + "' "
	cQuery += "   AND FIG_VENCTO	>= '" + DTOS(dDtIni) + "' "
	cQuery += "   AND FIG_VENCTO	<= '" + DTOS(dDtFin) + "' "
	cQuery += "   AND FIG_DATA		>= '" + DTOS(mv_par10) + "' "
	cQuery += "   AND FIG_DATA		<= '" + DTOS(mv_par11) + "' "
	cQuery += "   AND FIG_VALOR		> 0  "
	cQuery += "   AND FIG_CONCIL 	= '2' "
	cQuery += "   AND FIG_CODBAR 	<> '" + Space(TamSx3("FIG_CODBAR")[1]) + "' "
	cQuery += "   AND FIG.D_E_L_E_T_ = ' ' "
	If MV_PAR16 == 1
		cQuery += "   AND FIG_XENCER = 'S' )"
	ElseIf MV_PAR16 == 2
		cQuery += "   AND FIG_XENCER <> 'S' )"
	EndIf
	cQuery += "   SELECT * FROM TEMP "
	cQuery += "   WHERE CONTADOR = 1 "
	cQuery += " ORDER BY " + SqlOrder(cChave)
	//cQuery := ChangeQuery(cQuery)
	//	TcQuery cQuery New Alias cAliasFIG
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFIG,.T.,.T.)


	For nX :=  1 To Len(aStru)
		If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1]) > 0
			TcSetField(cAliasFIG,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX


	If ((cAliasFIG)->(Bof()) .or. (cAliasFIG)->(Eof()))
		Alert("Não foram identificados registros DDA para os parâmetros informado.")
		lContinua := .F.
	Else


		//preenche os dados iniciais da FIG
		dbSelectArea((cAliasFIG))
		(cAliasFIG)->(dbGoTop())
		while (cAliasFIG)->(!eof())

			MsProcTxt("Processando titulo "+Alltrim((cAliasFIG)->FIG_TITULO))

			cFornece 	:= (cAliasFIG)->FIG_FORNEC
			cLoja 		:= (cAliasFIG)->FIG_LOJA
			cCNPJDDA 	:= (cAliasFIG)->FIG_CNPJ
			cCNPJOrig 	:= space(14)
			dVencMin	:= DaySub( (cAliasFIG)->FIG_VENCTO, mv_par13 )
			dVencMax	:= DaySum( (cAliasFIG)->FIG_VENCTO, mv_par12 )
			nValorMin	:= (cAliasFIG)->FIG_VALOR - mv_par14
			nValorMax	:= (cAliasFIG)->FIG_VALOR + mv_par15
			cNomFor		:= ''

			dbSelectArea("SA2")
			dbSetOrder(3)
			If dbSeek(xFilial("SA2") + alltrim((cAliasFIG)->FIG_CNPJ))
				cFornece := SA2->A2_COD
				cLoja 	 := SA2->A2_LOJA
				cNomFor	 := SA2->A2_NREDUZ
			Else

				cQuery := " SELECT A2_CGC, FIG_CNPJ, E2_FORNECE, E2_LOJA, E2_NOMFOR
				cQuery += " FROM "+RetSqlName("FIG")+" FIG "
				cQuery += " INNER JOIN "+RetSqlName("SE2")+" SE2 ON SE2.D_E_L_E_T_ = ' '
				If mv_par07 == 1
					cQuery +=	"   AND E2_VENCTO	>= '"	+ DTOS(dVencMin) + "' "
					cQuery +=	"   AND E2_VENCTO	<= '"	+ DTOS(dVencMax) + "' "
				Else
					cQuery +=	"   AND E2_VENCREA	>= '"	+ DTOS(dVencMin) + "' "
					cQuery +=	"   AND E2_VENCREA	<= '"	+ DTOS(dVencMax) + "' "
				Endif
				//cQuery += " AND E2_SALDO = FIG_VALOR
				cQuery += " AND E2_SALDO >= " + cValToChar(nValorMin)
				cQuery += " AND E2_SALDO <= " + cValToChar(nValorMax)
				cQuery += " AND E2_CODBAR = '" + Space(TAMSX3("FIG_CODBAR")[1]) + "'
				cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA AND SUBSTRING(FIG_CNPJ,1,8) = SUBSTRING(A2_CGC,1,8)
				cQuery += " WHERE FIG.D_E_L_E_T_ = ' '
				cQuery += " AND FIG.R_E_C_N_O_ = " + cValToChar((cAliasFIG)->RECNOFIG)
				cQuery += " GROUP BY A2_CGC, FIG_CNPJ, E2_FORNECE, E2_LOJA, E2_NOMFOR "
				TcQuery cQuery New Alias(cTRB := GetNextAlias())

				dbSelectArea((cTRB))
				(cTRB)->(dbGoTop())
				ProcRegua(RecCount())
				If (cTRB)->(!eof())
					while (cTRB)->(!eof())
						cCNPJOrig	:= (cTRB)->FIG_CNPJ
						cCNPJDDA	:= (cTRB)->A2_CGC
						cFornece	:= (cTRB)->E2_FORNECE
						cLoja 		:= (cTRB)->E2_LOJA
						cNomFor		:= (cTRB)->E2_NOMFOR
						(cTRB)->(dbSkip())
					EndDo
				EndIf
				(cTRB)->(dbCloseArea())
			EndIf

			//If !(Empty(cFornece) .OR. Empty((cAliasFIG)->FIG_CODBAR) .OR. ;
			If !(Empty((cAliasFIG)->FIG_CODBAR) .OR. Empty((cAliasFIG)->FIG_TITULO) .OR. Empty((cAliasFIG)->FIG_VENCTO) .OR. ;
					Empty((cAliasFIG)->FIG_VALOR) .OR. Empty((cAliasFIG)->FIG_CNPJ))

				dbSelectArea("TRBDDA")
				RecLock("TRBDDA",.T.)
				cRecTRB := STRZERO(TRBDDA->(Recno()))


				TRBDDA->SEQMOV 		:= SUBSTR(cRecTRB,-5)
				TRBDDA->SEQCON		:= ""
				TRBDDA->FIL_DDA		:= (cAliasFIG)->FIG_FILIAL
				TRBDDA->FOR_DDA		:= cFornece
				TRBDDA->LOJ_DDA		:= cLoja
				TRBDDA->NOM_FOR		:= cNomFor
				TRBDDA->CNPJ_DDA	:= cCNPJDDA
				TRBDDA->CNPJ_ORIG	:= cCNPJOrig
				TRBDDA->TIT_DDA		:= (cAliasFIG)->FIG_TITULO+"000000"
				TRBDDA->TIP_DDA		:= (cAliasFIG)->FIG_TIPO
				TRBDDA->DTV_DDA		:= (cAliasFIG)->FIG_VENCTO
				TRBDDA->VLR_DDA		:= Transform((cAliasFIG)->FIG_VALOR,"@E 999,999,999,999.99")
				TRBDDA->REC_DDA		:= (cAliasFIG)->RECNOFIG
				TRBDDA->OK     		:= IIF((cAliasFIG)->FIG_XENCER=="S",20,19) // NAO CONCILIADO
				TRBDDA->CODBAR		:= (cAliasFIG)->FIG_CODBAR

				TRBDDA->ENCERRA		:= (cAliasFIG)->FIG_XENCER
				TRBDDA->MOTIVO		:= (cAliasFIG)->FIG_XMOTIV
				TRBDDA->RAIZCNPJ	:= substr(cCNPJDDA,1,8)
				TRBDDA->ORDEM		:= '1'
				TRBDDA->X_ANTRE		:= "2"
				MsUnlock()
			EndIf

			(cAliasFIG)->(dbSkip())
		endDo
		(cAliasFIG)->(dbCloseArea())

	EndIf

	If lContinua
		cAliasSE2 := GetNextAlias()
		aStru  := SE2->(dbStruct())
		cCampos := ""

		cQuery := "SELECT "
		cQuery +=		"E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_EMISSAO,"
		cQuery +=		"E2_VENCTO,E2_VENCREA,E2_VALOR,E2_EMIS1,E2_HIST,E2_SALDO,E2_ACRESC,E2_ORIGEM,E2_TXMOEDA,"
		cQuery +=		"E2_SDACRES,E2_DECRESC,E2_SDDECRE,E2_IDCNAB,E2_FILORIG,E2_CODBAR,E2_STATUS,E2_DTBORDE,"
        // cQuery +=       " E2_X_ANTRE,"
		cQuery +=		"R_E_C_N_O_ RECNOSE2 "
		cQuery += "FROM " + RetSqlName("SE2") + " SE2 "
		//cQuery +=		" WHERE E2_FILIAL IN "	+ FormatIn(cFilIn,"/") + " "
		cQuery +=		" WHERE E2_FILIAL   >= '" + mv_par01 + "' "
		cQuery += 		"   AND E2_FILIAL	<= '"+ mv_par02 + "' "
		cQuery += 		"   AND E2_FORNECE	>= '"+ mv_par03 + "' "
		cQuery += 		"   AND E2_FORNECE	<= '"+ mv_par04 + "' "
		cQuery += 		"   AND E2_LOJA		>= '"	+ mv_par05 + "' "
		cQuery += 		"   AND E2_LOJA		<= '"	+ mv_par06 + "' "
		If mv_par07 == 1
			cQuery +=	"   AND E2_VENCTO	>= '"	+ DTOS(dDtIni) + "' "
			cQuery +=	"   AND E2_VENCTO	<= '"	+ DTOS(dDtFin) + "' "
			cChave := "E2_FORNECE+E2_LOJA+DTOS(E2_VENCTO)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
		Else
			cQuery +=	"   AND E2_VENCREA	>= '"	+ DTOS(dDtIni) + "' "
			cQuery +=	"   AND E2_VENCREA	<= '"	+ DTOS(dDtFin) + "' "
			cChave := "E2_FORNECE+E2_LOJA+DTOS(E2_VENCREA)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
		Endif
		cQuery += 		"   AND E2_SALDO > 0 "
		cQuery += 		"   AND E2_TIPO NOT IN " + FORMATIN(cCPNEG+MVPAGANT,,3)
		cQuery += 		"   AND E2_TIPO NOT IN " + FORMATIN(MVABATIM,'|')
		cQuery += 		"   AND E2_TIPO NOT IN " + FORMATIN(MVTXA+"INA",,3)
		cQuery += 		"   AND E2_TIPO NOT IN " + FORMATIN(MVTAXA,,3)
		cQuery += 		"   AND E2_TIPO NOT IN " + FORMATIN(MVPROVIS,,3)
		cQuery +=		"   AND E2_CODBAR = '"	+ Space(TAMSX3("E2_CODBAR")[1]) + "' "
		cQuery +=		"   AND E2_IDCNAB = '"	+ Space(TAMSX3("E2_IDCNAB")[1]) + "' "
		cQuery +=		"   AND E2_NUMBOR = '"	+ Space(TAMSX3("E2_NUMBOR")[1]) + "' "
		cQuery +=		"   AND D_E_L_E_T_ = ' ' "
		cQuery +=	"ORDER BY " + SqlOrder(cChave)

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)

		For nX :=  1 To Len(aStru)
			If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1]) > 0
				TcSetField(cAliasSE2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX


		WHILE (cAliasSE2)->(!Eof())
			aAdd(aAuxSE2,{	(cAliasSE2)->E2_FILIAL,;
				(cAliasSE2)->E2_FORNECE,;
				(cAliasSE2)->E2_LOJA,;
				If(mv_par07 == 1,(cAliasSE2)->E2_VENCTO,(cAliasSE2)->E2_VENCREA ),;
				Transform((cAliasSE2)->E2_VALOR,"@E 999,999,999,999.99"),;
				(cAliasSE2)->RECNOSE2})
			DbSkip()
		EndDo

		(cAliasSE2)->(dbGoTop())
		If ((cAliasSE2)->(Bof()) .or. (cAliasSE2)->(Eof()))
			Alert("Não foram identificados registros no contas a pagar para os parâmetros informado.")
			lContinue := .F.
		Else

			dbSelectArea(cAliasSE2)
			While !((cAliasSE2)->(Eof()))
				If SA2->(dbSetOrder(1), dbSeek(xFilial("SA2") + (cAliasSE2)->E2_FORNECE + (cAliasSE2)->E2_LOJA))
					cCNPJDDA := substr(SA2->A2_CGC,1,8)
				Else
					cCNPJDDA := substr(TRBDDA->CNPJ_DDA,1,8)
				EndIf
				// Grava dados do SE2 no arquivo de trabalho
				DbSelectArea("TRBDDA")
				RecLock("TRBDDA",.T.)
				cRecTRB := STRZERO(TRBDDA->(Recno()))

				TRBDDA->SEQMOV 		:= SUBSTR(cRecTRB,-5)
				TRBDDA->SEQCON		:= ""
				TRBDDA->FIL_SE2		:= (cAliasSE2)->E2_FILIAL
				TRBDDA->FOR_SE2		:= (cAliasSE2)->E2_FORNECE
				TRBDDA->LOJ_SE2		:= (cAliasSE2)->E2_LOJA
				TRBDDA->TIT_SE2		:= (cAliasSE2)->(E2_PREFIXO+"-"+E2_NUM+"-"+E2_PARCELA)
				TRBDDA->KEY_SE2		:= (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA)
				TRBDDA->TIP_SE2		:= (cAliasSE2)->E2_TIPO
				TRBDDA->DTV_SE2		:= If(mv_par07 == 1,(cAliasSE2)->E2_VENCTO,(cAliasSE2)->E2_VENCREA )
				TRBDDA->VLR_SE2		:= Transform((cAliasSE2)->E2_VALOR,"@E 999,999,999,999.99")
				TRBDDA->REC_SE2		:= If(lQuery,(cAliasSE2)->RECNOSE2,(cAliasSE2)->(Recno()))
				TRBDDA->OK     		:= 19		// N„O CONCILIADO
				TRBDDA->RAIZCNPJ	:= substr(SA2->A2_CGC,1,8)
				TRBDDA->ORDEM		:= '2'
				// TRBDDA->X_ANTRE		:= (cAliasSE2)->E2_X_ANTRE
				MsUnlock()



				cFilSE2 	:= TRBDDA->FIL_SE2
				cFornece	:= TRBDDA->FOR_SE2
				cLoja		:= TRBDDA->LOJ_SE2
				cNum		:= TRBDDA->KEY_SE2
				cTipo		:= TRBDDA->TIP_SE2
				cVencto		:= DTOS(TRBDDA->DTV_SE2)
				dVencMin	:= TRBDDA->DTV_SE2- mv_par13
				dVencMax	:= TRBDDA->DTV_SE2+ mv_par12
				cVencMin	:= DTOS(dVencMin)
				cVencMax	:= DTOS(dVencMax)
				cValor		:= TRBDDA->VLR_SE2
				nValorMin	:= (cAliasSE2)->E2_VALOR - mv_par14
				nValorMax	:= (cAliasSE2)->E2_VALOR + mv_par15
				cValorMin	:= Transform(nValorMin,"@E 999,999,999,999.99")
				cValorMax	:= Transform(nValorMax,"@E 999,999,999,999.99")
				cTitSE2		:= TRBDDA->TIT_SE2
				nRecSe2		:= TRBDDA->REC_SE2
				cSeqSe2 	:= TRBDDA->SEQMOV
				nRecTrb  	:= TRBDDA->(Recno())



				dbSelectArea("TRBDDA")
				DbSetOrder(1)	//FOR_DDA+LOJ_DDA+DTV_DDA+TIT_DDA"
				nRecno := Recno()
				nRecnoAux := nRecno
				//***************************************************
				// Incluido Data de vencimento  no seek para deixar *
				// a chave de pesquisa mais forte. Caso a mesma nao *
				// seja encontrada a chave sera Forncedeor e Loja   *
				//***************************************************

				IF ((nScan := aScan(aAuxSE2,{|x| x[1]==(cAliasSE2)->E2_FILIAL .AND. ;
						x[4]== If(mv_par07 == 1,(cAliasSE2)->E2_VENCTO,(cAliasSE2)->E2_VENCREA )  .and.;
						x[5] == Transform((cAliasSE2)->E2_VALOR,"@E 999,999,999,999.99") .and. ;
						x[2]+x[3] == (cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA .and. ;
						x[6] <> (cAliasSE2)->RECNOSE2}))) > 0
					lDup := .T.
					(cAliasSE2)->(dbskip())
					Loop


				ENDIF


				If DbSeek(cFornece + cLoja + cVencto ) .and. cFilSe2 == TRBDDA->FIL_DDA .and. Empty(TRBDDA->SEQCON) .and. TRBDDA->VLR_DDA == cValor .and. Empty(TRBDDA->CNPJ_ORIG)

					nNivel := 1
					nRecno := Recno()

					DbGoTo(nRecTrb)
					dbDelete()
					dbGoto(nRecno)
					RecLock("TRBDDA")
					TRBDDA->SEQCON 	:= SUBSTR(cRecTRB,-5)
					TRBDDA->FIL_SE2	:= (cAliasSE2)->E2_FILIAL
					TRBDDA->FOR_SE2	:= (cAliasSE2)->E2_FORNECE
					TRBDDA->LOJ_SE2	:= (cAliasSE2)->E2_LOJA
					TRBDDA->TIT_SE2	:= (cAliasSE2)->(E2_PREFIXO+"-"+E2_NUM+"-"+E2_PARCELA)
					TRBDDA->KEY_SE2	:= (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA)
					TRBDDA->TIP_SE2	:= (cAliasSE2)->E2_TIPO
					TRBDDA->DTV_SE2	:= If(mv_par07 == 1,(cAliasSE2)->E2_VENCTO,(cAliasSE2)->E2_VENCREA )
					TRBDDA->VLR_SE2	:= Transform((cAliasSE2)->E2_VALOR,"@E 999,999,999,999.99")
					TRBDDA->REC_SE2	:= (cAliasSE2)->RECNOSE2
					// If (cAliasSE2)->E2_X_ANTRE == '1'
					// 	/*
					// 	msgInfo("Foi identificado título de ANTECIPACAO RECEBIVEL na conciliação DDA favor verificar." + chr(13) + chr(10) + ;
					// 	"FILIAL:  " + (cAliasSE2)->E2_FILIAL + chr(13) + chr(10) + ;
					// 	"PREFIXO: " + (cAliasSE2)->E2_PREFIXO + chr(13) + chr(10) + ;
					// 	"TITULO:  " + (cAliasSE2)->E2_NUM + chr(13) + chr(10) + ;
					// 	"PARCELA: " + (cAliasSE2)->E2_PARCELA ,"IDENTIFICACAO OCORRENCIA")
					// 	*/
					// 	TRBDDA->OK     	:= 21	// NIVEL DE CONCILIACAO TITULO ANTECIPACAO RECEBIVEL
					// 	TRBDDA->ORDEM	:= '3'
					// Else
						TRBDDA->OK     	:= nNivel	// NIVEL DE CONCILIACAO
						TRBDDA->ORDEM	:= '6'
					// EndIf
					// TRBDDA->X_ANTRE		:= (cAliasSE2)->E2_X_ANTRE
					MsUnlock()
				ElseIf DbSeek(cFornece + cLoja + cVencto ) .and. cFilSe2 == TRBDDA->FIL_DDA .and. Empty(TRBDDA->SEQCON) .and. TRBDDA->VLR_DDA == cValor .and. !Empty(TRBDDA->CNPJ_ORIG)

					nNivel := 2
					nRecno := Recno()

					DbGoTo(nRecTrb)
					dbDelete()
					dbGoto(nRecno)
					RecLock("TRBDDA")
					TRBDDA->SEQCON 	:= SUBSTR(cRecTRB,-5)
					TRBDDA->FIL_SE2	:= (cAliasSE2)->E2_FILIAL
					TRBDDA->FOR_SE2	:= (cAliasSE2)->E2_FORNECE
					TRBDDA->LOJ_SE2	:= (cAliasSE2)->E2_LOJA
					TRBDDA->TIT_SE2	:= (cAliasSE2)->(E2_PREFIXO+"-"+E2_NUM+"-"+E2_PARCELA)
					TRBDDA->KEY_SE2	:= (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA)
					TRBDDA->TIP_SE2	:= (cAliasSE2)->E2_TIPO
					TRBDDA->DTV_SE2	:= If(mv_par07 == 1,(cAliasSE2)->E2_VENCTO,(cAliasSE2)->E2_VENCREA )
					TRBDDA->VLR_SE2	:= Transform((cAliasSE2)->E2_VALOR,"@E 999,999,999,999.99")
					TRBDDA->REC_SE2	:= (cAliasSE2)->RECNOSE2
					// If (cAliasSE2)->E2_X_ANTRE == '1'
					// 	//msgInfo("Foi identificado título de ANTECIPACAO RECEBIVEL na conciliação DDA [" + (cAliasSE2)->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA) + "], favor verificar.","IDENTIFICACAO OCORRENCIA")
					// 	TRBDDA->OK     	:= 21	// NIVEL DE CONCILIACAO TITULO ANTECIPACAO RECEBIVEL
					// 	TRBDDA->ORDEM	:= '3'
					// Else
						TRBDDA->OK     	:= nNivel	// NIVEL DE CONCILIACAO
						TRBDDA->ORDEM	:= '6'
					// EndIf
					// TRBDDA->X_ANTRE		:= (cAliasSE2)->E2_X_ANTRE
					MsUnlock()

				ElseIf TRBDDA->(dbSetOrder(9),dbSeek(substr(cCNPJDDA,1,8)))
					nRecno := Recno()

					If alltrim(TRBDDA->CNPJ_DDA) == '33172537000198'
						cTeste := ''
					EndIf

					While !(TRBDDA->(Eof())) .and. substr(TRBDDA->CNPJ_DDA,1,8) ==  substr(cCNPJDDA,1,8) //TRBDDA->(FOR_DDA+LOJ_DDA) == cFornece+cLoja

						nNivel := 19 //Nao conciliado

						//------------------------------------------------
						//Chave exata
						//Filial - OK
						//Data Vencto - OK
						//Valor - OK
						//Fornecedor - OK
						If cFilSe2 == TRBDDA->FIL_DDA	 .and. ;
								TRBDDA->VLR_DDA == cValor .and. ;
								DTOS(TRBDDA->DTV_DDA) == cVencto .and.;
								Empty(TRBDDA->SEQCON) .and. Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 1
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Chave exata
							//Filial - OK
							//Data Vencto - OK
							//Valor - OK
							//Fornecedor - Raiz
						ElseIf cFilSe2 == TRBDDA->FIL_DDA	 .and. ;
								TRBDDA->VLR_DDA == cValor .and. ;
								DTOS(TRBDDA->DTV_DDA) == cVencto .and.;
								Empty(TRBDDA->SEQCON) .and. !Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 2
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - OK
							//Data Vencto - OK
							//Valor - Intervalo
							//Fornecedor - OK
						ElseIf cFilSe2 == TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) == cVencto .and.  ;
								TRBDDA->VLR_DDA >= cValorMin .and. ;
								TRBDDA->VLR_DDA <= cValorMax .and.;
								Empty(TRBDDA->SEQCON)  .and. Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 3
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - OK
							//Data Vencto - OK
							//Valor - Intervalo
							//Fornecedor - Raiz
						ElseIf cFilSe2 == TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) == cVencto .and.  ;
								TRBDDA->VLR_DDA >= cValorMin .and. ;
								TRBDDA->VLR_DDA <= cValorMax .and.;
								Empty(TRBDDA->SEQCON) .and. !Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 4
							nRecno := Recno()
							Exit


							//------------------------------------------------
							//Filial - OK
							//Data Vencto - Intervalo
							//Valor - OK
							//Fornecedor - OK
						ElseIf cFilSe2 == TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) >= cVencMin .and.;
								DTOS(TRBDDA->DTV_DDA) <= cVencMax .and.;
								TRBDDA->VLR_DDA == cValor .and.;
								Empty(TRBDDA->SEQCON) .and. Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 5
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - OK
							//Data Vencto - Intervalo
							//Valor - OK
							//Fornecedor - Raiz
						ElseIf cFilSe2 == TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) >= cVencMin .and.;
								DTOS(TRBDDA->DTV_DDA) <= cVencMax .and.;
								TRBDDA->VLR_DDA == cValor .and.;
								Empty(TRBDDA->SEQCON) .and. !Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 6
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - OK
							//Data Vencto - Intervalo
							//Valor - Intervalo
							//Fornecedor - ok
						ElseIf cFilSe2 == TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) >= cVencMin .and.;
								DTOS(TRBDDA->DTV_DDA) <= cVencMax .and.;
								TRBDDA->VLR_DDA >= cValorMin .and.;
								TRBDDA->VLR_DDA <= cValorMax  .and.;
								Empty(TRBDDA->SEQCON) .and. Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 7
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - OK
							//Data Vencto - Intervalo
							//Valor - Intervalo
							//Fornecedor - Raiz
						ElseIf cFilSe2 == TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) >= cVencMin .and.;
								DTOS(TRBDDA->DTV_DDA) <= cVencMax .and.;
								TRBDDA->VLR_DDA >= cValorMin .and.;
								TRBDDA->VLR_DDA <= cValorMax  .and.;
								Empty(TRBDDA->SEQCON) .and. !Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 8
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - Diferente
							//Data Vencto - OK
							//Valor - OK
							//Fornecedor - OK
						ElseIf cFilSe2 != TRBDDA->FIL_DDA	 .and. ;
								TRBDDA->VLR_DDA == cValor .and. ;
								DTOS(TRBDDA->DTV_DDA) == cVencto .and.;
								Empty(TRBDDA->SEQCON) .and. Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 9
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - Diferente
							//Data Vencto - OK
							//Valor - OK
							//Fornecedor - Raiz
						ElseIf cFilSe2 != TRBDDA->FIL_DDA	 .and. ;
								TRBDDA->VLR_DDA == cValor .and. ;
								DTOS(TRBDDA->DTV_DDA) == cVencto .and.;
								Empty(TRBDDA->SEQCON) .and. !Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 10
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - Diferente
							//Data Vencto - OK
							//Valor - Intervalo
							//Fornecedor - OK
						ElseIf cFilSe2 != TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) == cVencto .and.  ;
								TRBDDA->VLR_DDA >= cValorMin .and. ;
								TRBDDA->VLR_DDA <= cValorMax .and.;
								Empty(TRBDDA->SEQCON) .and. Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 11
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - Diferente
							//Data Vencto - OK
							//Valor - Intervalo
							//Fornecedor - Raiz
						ElseIf cFilSe2 != TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) == cVencto .and.  ;
								TRBDDA->VLR_DDA >= cValorMin .and. ;
								TRBDDA->VLR_DDA <= cValorMax .and.;
								Empty(TRBDDA->SEQCON) .and. !Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 12
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - Diferente
							//Data Vencto - intevalo
							//Valor - OK
							//Fornecedor - OK
						ElseIf cFilSe2 != TRBDDA->FIL_DDA .and. ;
								TRBDDA->VLR_DDA == cValor  .and.  ;
								DTOS(TRBDDA->DTV_DDA) >= cVencMin .and. ;
								DTOS(TRBDDA->DTV_DDA) <= cVencMax .and.;
								Empty(TRBDDA->SEQCON) .and. Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 13
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - Diferente
							//Data Vencto - intevalo
							//Valor - OK
							//Fornecedor - Raiz
						ElseIf cFilSe2 != TRBDDA->FIL_DDA .and. ;
								TRBDDA->VLR_DDA == cValor  .and.  ;
								DTOS(TRBDDA->DTV_DDA) >= cVencMin .and. ;
								DTOS(TRBDDA->DTV_DDA) <= cVencMax .and.;
								Empty(TRBDDA->SEQCON) .and. !Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 14
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - Diferente
							//Data Vencto - intervalo
							//Valor - Intervalo
							//Fornecedor - OK
						ElseIf cFilSe2 != TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) >= cVencMin .and.;
								DTOS(TRBDDA->DTV_DDA) <= cVencMax .and.;
								TRBDDA->VLR_DDA >= cValorMin .and.;
								TRBDDA->VLR_DDA <= cValorMax .and.;
								Empty(TRBDDA->SEQCON) .and. Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 15
							nRecno := Recno()
							Exit

							//------------------------------------------------
							//Filial - Diferente
							//Data Vencto - intervalo
							//Valor - Intervalo
							//Fornecedor - Raiz
						ElseIf cFilSe2 != TRBDDA->FIL_DDA .and. ;
								DTOS(TRBDDA->DTV_DDA) >= cVencMin .and.;
								DTOS(TRBDDA->DTV_DDA) <= cVencMax .and.;
								TRBDDA->VLR_DDA >= cValorMin .and.;
								TRBDDA->VLR_DDA <= cValorMax .and.;
								Empty(TRBDDA->SEQCON) .and. !Empty(TRBDDA->CNPJ_ORIG)
							nNivel := 16
							nRecno := Recno()
							Exit
						Else
							TRBDDA->(dbSkip())
							Loop
						Endif

					Enddo
					IIF(nNivel < 18 .and. Type('lOk')=="U",lOk:=.T.,Nil)
					//Caso houve algum tipo de possibilidade de conciliacao
					If nNivel < 18

						//Caso tenho conseguido travar os registros do SE2 e FIG
						If lOk
							DbGoTo(nRecTrb)
							dbDelete()
							dbGoto(nRecno)
							RecLock("TRBDDA")
							TRBDDA->SEQCON 	:= SUBSTR(cRecTRB,-5)
							TRBDDA->FIL_SE2	:= (cAliasSE2)->E2_FILIAL
							TRBDDA->FOR_SE2	:= (cAliasSE2)->E2_FORNECE
							TRBDDA->LOJ_SE2	:= (cAliasSE2)->E2_LOJA
							TRBDDA->TIT_SE2	:= (cAliasSE2)->(E2_PREFIXO+"-"+E2_NUM+"-"+E2_PARCELA)
							TRBDDA->KEY_SE2	:= (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA)
							TRBDDA->TIP_SE2	:= (cAliasSE2)->E2_TIPO
							TRBDDA->DTV_SE2	:= If(mv_par07 == 1,(cAliasSE2)->E2_VENCTO,(cAliasSE2)->E2_VENCREA )
							TRBDDA->VLR_SE2	:= Transform((cAliasSE2)->E2_VALOR,"@E 999,999,999,999.99")
							TRBDDA->REC_SE2	:= (cAliasSE2)->RECNOSE2
							// If (cAliasSE2)->E2_X_ANTRE == '1'
							// 	//msgInfo("Foi identificado título de ANTECIPACAO RECEBIVEL na conciliação DDA [" + (cAliasSE2)->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA) + "], favor verificar.","IDENTIFICACAO OCORRENCIA")
							// 	TRBDDA->OK     	:= 21	// NIVEL DE CONCILIACAO TITULO ANTECIPACAO RECEBIVEL
							// 	TRBDDA->ORDEM	:= '3'
							// Else
								TRBDDA->OK     	:= nNivel	// NIVEL DE CONCILIACAO
								TRBDDA->ORDEM	:= '6'
							// EndIf
							// TRBDDA->X_ANTRE		:= (cAliasSE2)->E2_X_ANTRE
							MsUnlock()
						Endif
						lOk := .T.
					Endif
				EndIf

				(cAliasSE2)->(dbSkip())
			EndDo
			(cAliasSE2)->(dbCloseArea())

			dbSelectArea("TRBDDA")
			TRBDDA->(dbGoTop())
			while TRBDDA->(!eof())
				If TRBDDA->OK == 19

					dVencMin	:= DaySub( TRBDDA->DTV_DDA, mv_par13 )
					dVencMax	:= DaySum( TRBDDA->DTV_DDA, mv_par12 )
					nValorMin	:= val(strTran(strTran(TRBDDA->VLR_DDA,".",""),",",".")) - mv_par14
					nValorMax	:= val(strTran(strTran(TRBDDA->VLR_DDA,".",""),",",".")) + mv_par15

					If auxCon()
						nNivel := 18
						RecLock("TRBDDA",.F.)
						TRBDDA->OK     	:= nNivel
						TRBDDA->ORDEM	:= '4'
						TRBDDA->(MsUnlock())
					EndIf
				EndIf

				TRBDDA->(dbSkip())
			EndDo


			dbSelectArea("TRBDDA")
			dbSetOrder(10)
			//dbSetOrder(8)	//DTV_DDA+DTV_SE2"
			dbGoTop()

			aObjects := {}
			aPosObj := {}
			AAdd( aObjects, { 100, 100, .T., .T., .F. } ) // Dados da Enchoice
			AAdd( aObjects, { 100, 010, .T., .T., .F. } ) // Dados da getdados

			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
			aPosObj := MsObjSize( aInfo, aObjects, .T., .F.)


			DEFINE MSDIALOG oDlgDDA TITLE "::.. CONCILIADOR DDA ..::" From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
			oDlgDDA:lMaximized := .T.

			//oPanel := TPanel():New(0,0,'',oDlgDDA,, .T., .T.,, ,30,30,.T.,.T. )
			oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],'',oDlgDDA,, .T., .T.,, ,aPosObj[1,4],aPosObj[1,3],.T.,.T. )
			oPane2 := TPanel():New(aPosObj[2,1],aPosObj[2,2],'',oDlgDDA,, .T., .T.,, ,aPosObj[2,4],aPosObj[2,3],.T.,.T. )


			@ 01.0,.5 LISTBOX oTitulo Fields HEADER " ", "SEQ.",;
				"FILIAL DDA",;
				"FORNEC.DDA",;
				"LOJA DDA",;
				"NOME FOR",;
				"TITULO DDA",;
				"TIPO DDA",;
				"VENCTO.DDA",;
				"VALOR DDA",;
				"CNPJ CONC./DDA",;
				"CNPJ ORIG",;
				"FILIAL SE2",;
				"FORNEC.SE2",;
				"LOJA SE2",;
				"TITULO SE2",;
				"TIPO SE2",;
				"VENCTO.SE2",;
				"VALOR SE2" ColSizes 12, 	GetTextWidth(0,"BBBB"),;//SEQ
				GetTextWidth(0,"BBBBB"),;							//Filial
				GetTextWidth(0,"BBBBB"),;							//Fornecedor
				GetTextWidth(0,"BBBB"),;							//Loja
				GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBB"),; 	  		//Nome Fornecedor
				GetTextWidth(0,"BBBBBBBB"),;			 	  		//Titulo
				GetTextWidth(0,"BBBB"),;							//Tipo
				GetTextWidth(0,"BBBBBB"),;							//Vencto
				GetTextWidth(0,"BBBBBBBBB"),;						//Valor
				GetTextWidth(0,"BBBBBBBBBBBBBB"),;					//CNPJ DDA
				GetTextWidth(0,"BBBBBBBBBBBBBB"),;					//CNPJ ORIG
				GetTextWidth(0,"BBBBB"),;							//Filial
				GetTextWidth(0,"BBBBB"),;							//Fornecedor
				GetTextWidth(0,"BBBB"),;							//Loja
				GetTextWidth(0,"BBBBBBBBBBB"),;  			 		//Titulo
				GetTextWidth(0,"BBBB"),;							//Tipo
				GetTextWidth(0,"BBBBBB"),;							//Vencto
				GetTextWidth(0,"BBBBBBBBB")	;						//Valor
				SIZE 160, 060 OF oPanel  PIXEL NOSCROLL
			//SIZE 160, 060 OF oDlgDDA  PIXEL NOSCROLL


			oTitulo:bLine := { || {aStatus[TRBDDA->OK],;
				TRBDDA->SEQMOV 	,;
				TRBDDA->FIL_DDA	,;
				TRBDDA->FOR_DDA	,;
				TRBDDA->LOJ_DDA	,;
				TRBDDA->NOM_FOR ,;
				TRBDDA->TIT_DDA	,;
				TRBDDA->TIP_DDA	,;
				TRBDDA->DTV_DDA	,;
				PADR(TRBDDA->VLR_DDA,18) ,;
				TRBDDA->CNPJ_DDA ,;
				TRBDDA->CNPJ_ORIG ,;
				TRBDDA->FIL_SE2	,;
				TRBDDA->FOR_SE2	,;
				TRBDDA->LOJ_SE2	,;
				TRBDDA->TIT_SE2	,;
				TRBDDA->TIP_SE2	,;
				TRBDDA->DTV_SE2	,;
				PADR(TRBDDA->VLR_SE2,18) }}

			oTitulo:bLDblClick := {|| ReconDDA(oTitulo),oTitulo:Refresh()}


			@ 007, 020 BUTTON oBtnLeg PROMPT "LEGENDAS" 	SIZE 100, 030 OF oPane2 PIXEL
			@ 007, 150 BUTTON oBtnCon PROMPT "CONCILIAR" 	SIZE 100, 030 OF oPane2 PIXEL
			@ 007, 290 BUTTON oBtnCan PROMPT "FECHAR" 		SIZE 100, 030 OF oPane2 PIXEL

			@ 007, 430 BUTTON oBtnDes PROMPT "ENCERRAR DDA"  SIZE 100, 030 OF oPane2 PIXEL
			//@ 007, 570 BUTTON oBtnSE2 PROMPT "Ajusta Título" SIZE 100, 030 OF oPane2 PIXEL

			oBtnCon:bAction := {||nOpc2 := 1, oDlgDDA:End() }
			oBtnCan:bAction := {||nOpc2 := 2, oDlgDDA:End() }
			//oBtnLeg:bAction := {|| BrwLegenda("LEGENDA  - [OK] Valor Exato, [IN] Intervalo Definido Paramtro, [RZ] Raiz CNPJ","LEGENDA CONCILIAÇÃO DDA",aLegenda,30) }
			oBtnLeg:bAction := {|| Legenda() }
			oBtnDes:bAction := {|| EncDDA()}

			oBtnCon:SetCss("QPushButton{ background-image: url(rpo:COMPTITL_MDI.PNG);"+;
				" font-family: Verdana, Geneva, sans-serif; font-size: 18px;	font-style: bold;"+;
				" background-repeat: none; margin: 2px }")

			oBtnCan:SetCss("QPushButton{ background-image: url(rpo:FINAL_OCEAN.PNG);"+;
				" font-family: Verdana, Geneva, sans-serif; font-size: 18px;	font-style: bold;"+;
				" background-repeat: none; margin: 2px }")

			oBtnLeg:SetCss("QPushButton{ background-image: url(rpo:COLOR_OCEAN.PNG);"+;
				" font-family: Verdana, Geneva, sans-serif; font-size: 18px;	font-style: bold;"+;
				" background-repeat: none; margin: 2px }")

			oBtnDes:SetCss("QPushButton{ background-image: url(rpo:UPDWARNING_MDI.PNG);"+;
				" font-family: Verdana, Geneva, sans-serif; font-size: 18px;	font-style: bold;"+;
				" background-repeat: none; margin: 2px }")

			oTitulo:Align := CONTROL_ALIGN_ALLCLIENT
			ACTIVATE MSDIALOG oDlgDDA CENTERED


			If nOpc2 == 1
				Processa( {|| nil }, "Aguarde...", "Carregando definição de conciliação DDA...",.F.)
				BEGIN TRANSACTION

					dbSelectArea("TRBDDA")
					dbGoTop()
					While !(TRBDDA->(Eof()))
						nRecSE2 := TRBDDA->REC_SE2
						nRecDDA := TRBDDA->REC_DDA
						cTitSE2 := ''

						If nRecSE2 > 0 .and. nRecDDA > 0 .and. TRBDDA->OK <> 21

							dbSelectArea("SE2")
							dbGoto(nRecSE2)
							If RecLock("SE2",.F.)
								SE2->E2_CODBAR	:= TRBDDA->CODBAR
								_nDif:= VAL(StrTran(StrTran(TRBDDA->VLR_DDA,".",""),",","."))  - SE2->E2_SALDO
								IF _nDif <> 0
								// ACRESCIMO
									IF _nDif >0
										SE2->E2_ACRESC 	:= _nDif
										SE2->E2_SDACRES := SE2->E2_SDACRES +_nDif
									ENDIF

								// DECRESCIMO
									IF _nDif < 0
										SE2->E2_DECRESC 	:= _nDif*-1
										SE2->E2_SDDECRE 	:= SE2->E2_SDDECRE +_nDif*-1
									ENDIF

								ENDIF
								If substr(TRBDDA->CODBAR,1,3) == '237'
									SE2->E2_FORMPAG := '30'
								Else
									SE2->E2_FORMPAG := '31'
								EndIf

								cTitSE2			:= SE2->E2_FILIAL+"|"+;
									SE2->E2_PREFIXO+"|"+;
									SE2->E2_NUM+"|"+;
									SE2->E2_PARCELA+"|"+;
									SE2->E2_TIPO+"|"+;
									SE2->E2_FORNECE+"|"+;
									SE2->E2_LOJA+"|"
							Endif

							dbSelectArea("FIG")
							dbGoto(nRecDDA)
							If RecLock("FIG",.F.)

								SA2->(dbSetOrder(3), dbSeek(xFilial("SA2") + TRBDDA->CNPJ_DDA))

								FIG->FIG_DDASE2	:= cTitSE2				//Chave do SE2 com o qual foi conciliado
								FIG->FIG_CONCIL	:= "1" 					//Conciliado
								FIG->FIG_DTCONC	:= dDatabase			//Data da Conciliacao
								FIG->FIG_USCONC	:= cUsername			//Usuario responsavel pela conciliacao
								FIG->FIG_CNPJ   := TRBDDA->CNPJ_DDA		//CNPJ da concilicao
								FIG->FIG_FORNEC := SA2->A2_COD			//Codigo do fornecedor
								FIG->FIG_LOJA   := SA2->A2_LOJA 		//Loja do fornecedor
								FIG->FIG_NOMFOR := SA2->A2_NOME			//Nome do fornecedor

								If FIG->(FieldPos("FIG_XCNPJ")) > 0
									FIG->FIG_XCNPJ := TRBDDA->CNPJ_ORIG	//CNPJ original se houve a troca
								EndIf
								If FIG->(FieldPos("FIG_XLOGGR")) > 0
									FIG->FIG_XLOGGR := alltrim(cUserName) + '|' + dTos(Date()) + '|' + Time() //Log de gravacao Usuario + Data + Hora
								EndIf
								If FIG->(FieldPos("FIG_XREGRA")) > 0
									FIG->FIG_XREGRA  := cValToChar(TRBDDA->OK)
								EndIf
								If FIG->(FieldPos("FIG_XENCER")) > 0
									FIG->FIG_XENCER := TRBDDA->ENCERRA
								EndIf
								If FIG->(FieldPos("FIG_XMOTIV")) > 0
									FIG->FIG_XMOTIV	:= TRBDDA->MOTIVO
								EndIf

							Endif
						ElseIf TRBDDA->OK == 20

							dbSelectArea("FIG")
							dbGoto(nRecDDA)
							If RecLock("FIG",.F.)
								If FIG->(FieldPos("FIG_XREGRA")) > 0
									FIG->FIG_XREGRA  := cValToChar(TRBDDA->OK)
								EndIf

								If FIG->(FieldPos("FIG_XENCER")) > 0
									FIG->FIG_XENCER := 'S'
								EndIf

								If FIG->(FieldPos("FIG_XMOTIV")) > 0
									FIG->FIG_XMOTIV	:= TRBDDA->MOTIVO
								EndIf

								If FIG->(FieldPos("FIG_XLOGGR")) > 0
									FIG->FIG_XLOGGR := alltrim(cUserName) + '|' + dTos(Date()) + '|' + Time() //Log de gravacao Usuario + Data + Hora
								EndIf
							Endif
						ElseIf TRBDDA->REC_DDA <> 0 .and. TRBDDA->OK <> 21

							dbSelectArea("FIG")
							dbGoto(nRecDDA)
							If RecLock("FIG",.F.)
								If FIG->(FieldPos("FIG_XREGRA")) > 0
									FIG->FIG_XREGRA  := ''
								EndIf

								If FIG->(FieldPos("FIG_XENCER")) > 0
									FIG->FIG_XENCER := 'N'
								EndIf

								If FIG->(FieldPos("FIG_XMOTIV")) > 0
									FIG->FIG_XMOTIV	:= ''
								EndIf

								If FIG->(FieldPos("FIG_XLOGGR")) > 0
									FIG->FIG_XLOGGR := ''
								EndIf
							Endif

						EndIf
						dbSelectArea("TRBDDA")
						dbSkip()
						Loop
					Enddo

				END TRANSACTION

			EndIf



		EndIf
	EndIf
	//Finalizar o arquivo de trabalho
	dbSelectArea("TRBDDA")
	//Set Filter To
	dbCloseArea()

	//Deleta tabela temporária criada no banco de dados
	If oTempDB <> Nil
		oTempDB:Delete()
		oTempDB := Nil
	Endif

	dbSelectArea("FIG")
	dbSetOrder(1)

	RestArea(aArea)

Return


//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ReconDDA(oTitulo)
	Local oDlg1EC
	local oBCanc
	local oBConf
	local oGCNPJ_dda
	local oGCodBar_dda
	local oGValor_dda
	local oGroup1
	local oGTit_dda
	local oGVenc_dda
	local oPainelT
	local oSay1
	local oSay2
	local oSay3
	local oSay4
	local oSay5
	local cGTit_dda 	:= "Define variable value"
	local dGVenc_dda 	:= Date()
	Local oOk        	:= LoadBitMap(GetResources(), "LBOK")
	Local oNo        	:= LoadBitMap(GetResources(), "LBNO")
	local cGCNPJ_dda 	:= "Define variable value"
	local cGCodBar_dda 	:= "Define variable value"
	local nGValor_dda	:= 0
	Local lRet			:= .T.
	Local nNilvel		:= TRBDDA->OK
	local nOpca1 		:= 2
	private oManual
	private aManual 	:= {}
	Static oDlgDDM


	If TRBDDA->X_ANTRE == '1'
		Alert("Registro de titulo ANTECIPACAO RECEBIVEL, nao pode sofrer manutencao.")
		Return(.F.)
	EndIf


	If nNilvel == 18 .OR. nNilvel == 19   // Se n„o reconciliado
		If TRBDDA->REC_DDA == 0
			Return()
		EndIf

		//FIG->(dbGoTo(TRBDDA->REC_DDA))

		cGTit_dda 		:= TRBDDA->TIT_DDA
		dGVenc_dda		:= TRBDDA->DTV_DDA
		cGCNPJ_dda		:= TRBDDA->CNPJ_DDA
		nGValor_dda		:= TRBDDA->VLR_DDA
		cGCodBar_dda	:= TRBDDA->CODBAR


		dVencMin	:= DaySub( TRBDDA->DTV_DDA, mv_par13 )
		dVencMax	:= DaySum( TRBDDA->DTV_DDA, mv_par12 )
		nValorMin	:= val(strTran(strTran(TRBDDA->VLR_DDA,".",""),",",".")) - mv_par14
		nValorMax	:= val(strTran(strTran(TRBDDA->VLR_DDA,".",""),",",".")) + mv_par15

		cQuery := " SELECT E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PARCELA, E2_NUM, E2_PREFIXO, A2_NREDUZ, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_SALDO, SE2.R_E_C_N_O_ AS RECSE2, E2_TIPO, A2_CGC
		cQuery += " FROM "+RetSqlName("FIG")+" FIG "
		cQuery += " INNER JOIN "+RetSqlName("SE2")+" SE2 ON SE2.D_E_L_E_T_ = ' '
		If mv_par07 == 1
			cQuery +=	"   AND E2_VENCTO	>= '"	+ DTOS(dVencMin) + "' "
			cQuery +=	"   AND E2_VENCTO	<= '"	+ DTOS(dVencMax) + "' "
		Else
			cQuery +=	"   AND E2_VENCREA	>= '"	+ DTOS(dVencMin) + "' "
			cQuery +=	"   AND E2_VENCREA	<= '"	+ DTOS(dVencMax) + "' "
		Endif
		cQuery += " AND E2_SALDO >= " + cValToChar(nValorMin)
		cQuery += " AND E2_SALDO <= " + cValToChar(nValorMax)
		cQuery += " AND E2_CODBAR = '" + Space(TAMSX3("E2_CODBAR")[1]) + "'
		// cQuery += " AND E2_X_ANTRE <> '1'
		cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
		//cQuery += " AND SUBSTRING(A2_CGC,1,8) <> SUBSTRING(FIG_CNPJ,1,8)
		cQuery += " WHERE FIG.D_E_L_E_T_ = ' '
		cQuery += " AND FIG.R_E_C_N_O_ = " + cValToChar(TRBDDA->REC_DDA)
		cQuery += " GROUP BY E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PARCELA, E2_NUM, E2_PREFIXO, A2_NREDUZ, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_SALDO, SE2.R_E_C_N_O_, E2_TIPO, A2_CGC"
		TcQuery cQuery New Alias(cTRBMAN := GetNextAlias())


		dbSelectArea((cTRBMAN))
		(cTRBMAN)->(dbGoTop())
		If (cTRBMAN)->(!eof())
			while (cTRBMAN)->(!eof())
				aAdd(aManual,{.F.,;
					(cTRBMAN)->E2_FILIAL,;
					(cTRBMAN)->E2_PARCELA,;
					(cTRBMAN)->E2_NUM,;
					(cTRBMAN)->E2_PREFIXO,;
					(cTRBMAN)->A2_NREDUZ,;
					sTod((cTRBMAN)->E2_EMISSAO),;
					sTod(If(mv_par07 == 1,(cTRBMAN)->E2_VENCTO,(cTRBMAN)->E2_VENCREA )),;
					Transform((cTRBMAN)->E2_SALDO,"@E 999,999,999,999.99"),;
					(cTRBMAN)->E2_FORNECE,;
					(cTRBMAN)->E2_LOJA,;
					(cTRBMAN)->E2_TIPO,;
					(cTRBMAN)->A2_CGC,;
					(cTRBMAN)->RECSE2})
				(cTRBMAN)->(dbSkip())
			EndDo

		Else
			Alert("Não foram identificados registros para conciliação manual.")
			Return(.F.)
		EndIf

		DEFINE MSDIALOG oDlgDDM TITLE "::.. Conciliador DDA Manual ..::" FROM 000, 000  TO 420, 800 COLORS 0, 16777215 PIXEL

		@ 002, 002 GROUP oGroup1 TO 061, 395 PROMPT " ::.. REGISTRO DDA ..:: " OF oDlgDDM COLOR 0, 16777215 PIXEL
		@ 012, 005 SAY oSay1 PROMPT "TITULO" SIZE 025, 007 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 021, 005 MSGET oGTit_dda VAR cGTit_dda SIZE 060, 010 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 012, 091 SAY oSay2 PROMPT "VENCIMENTO" SIZE 036, 007 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 021, 091 MSGET oGVenc_dda VAR dGVenc_dda SIZE 060, 010 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 012, 178 SAY oSay3 PROMPT "CNPJ" SIZE 025, 007 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 021, 178 MSGET oGCNPJ_dda VAR cGCNPJ_dda SIZE 060, 010 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 012, 275 SAY oSay4 PROMPT "VALOR" SIZE 025, 007 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 021, 275 MSGET oGValor_dda VAR nGValor_dda SIZE 060, 010 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 035, 005 SAY oSay5 PROMPT "CODIGO DE BARRAS" SIZE 062, 007 OF oDlgDDM COLORS 0, 16777215 PIXEL
		@ 044, 005 MSGET oGCodBar_dda VAR cGCodBar_dda SIZE 332, 010 OF oDlgDDM COLORS 0, 16777215 PIXEL


		@ 065, 002 MSPANEL oPainelT SIZE 392, 113 OF oDlgDDM COLORS 0, 16777215 RAISED
		@ 000, 000 LISTBOX oManual Fields HEADER "","FILIAL","PARCELA","TITULO","PREFIXO","FORNECEDOR","EMISSÃO","VENCTO","SALDO" SIZE 391, 112 OF oPainelT PIXEL ColSizes 50,50
		oManual:SetArray(aManual)
		oManual:bLine := {|| {;
			if(aManual[oManual:nAt,1],oOk,oNo),;
			aManual[oManual:nAt,2],;
			aManual[oManual:nAt,3],;
			aManual[oManual:nAt,4],;
			aManual[oManual:nAt,5],;
			aManual[oManual:nAt,6],;
			aManual[oManual:nAt,7],;
			aManual[oManual:nAt,8],;
			aManual[oManual:nAt,9];
			}}

		oManual:bLDblClick := {|| Mark()}

		@ 182, 240 BUTTON oBConf PROMPT "Confirmar" SIZE 076, 024 OF oDlgDDM PIXEL
		@ 182, 319 BUTTON oBCanc PROMPT "Cancelar" SIZE 076, 024 OF oDlgDDM PIXEL

		oGTit_dda:Disable(.T.)
		oGVenc_dda:Disable(.T.)
		oGCNPJ_dda:Disable(.T.)
		oGValor_dda:Disable(.T.)
		oGCodBar_dda:Disable(.T.)

		oManual:Align := CONTROL_ALIGN_ALLCLIENT
		oBCanc:bAction := {|| oDlgDDM:End()}
		oBConf:bAction := {|| nOpca1 := 1, oDlgDDM:End() }
		ACTIVATE MSDIALOG oDlgDDM CENTERED
		nRecno := TRBDDA->(Recno())//Recno()
		TRBDDA->(dbSkip())
		nRecAux := TRBDDA->(Recno())//Recno()
		TRBDDA->(dbGoto(nRecno))

		If nOpca1 == 1
			For nX := 1 To Len(aManual)
				If aManual[nX][1]
					nNivel := 17
					nRecno := TRBDDA->(Recno())//Recno()
					dbSelectArea("TRBDDA")
					DbSetOrder(6)	//SEQMOV+FOR_DDA+LOJ_DDA+DTV_DDA+TIT_DDA"
					If dbSeek(aManual[nX][5] + aManual[nX][4] + aManual[nX][3])
						dbDelete()
					EndIf
					TRBDDA->(dbGoto(nRecno))

					RecLock("TRBDDA",.F.)
					TRBDDA->SEQCON 		:= SUBSTR(cRecTRB,-5)
					TRBDDA->FIL_SE2		:= aManual[nX][2]
					TRBDDA->FOR_SE2		:= aManual[nX][10]
					TRBDDA->LOJ_SE2		:= aManual[nX][11]
					TRBDDA->TIT_SE2		:= aManual[nX][5] + "-" + aManual[nX][4] + "-" + aManual[nX][3]
					TRBDDA->KEY_SE2		:= aManual[nX][5] + aManual[nX][4] + aManual[nX][3]
					TRBDDA->TIP_SE2		:= aManual[nX][12]
					TRBDDA->DTV_SE2		:= aManual[nX][8]
					TRBDDA->VLR_SE2		:= aManual[nX][9]
					If TRBDDA->CNPJ_DDA <> aManual[nX][13]
						TRBDDA->CNPJ_ORIG	:= TRBDDA->CNPJ_DDA
					EndIf
					TRBDDA->CNPJ_DDA	:= aManual[nX][13]
					TRBDDA->REC_SE2		:= aManual[nX][14]
					TRBDDA->OK     		:= nNivel
					TRBDDA->ORDEM    	:= '5'
					TRBDDA->X_ANTRE		:= '2'
					MsUnlock()
				EndIf
			Next nX
		EndIf
			   /*
		dbSelectArea("TRBDDA")
		dbSetOrder(10)
		dbGoTop()
				 */
	Else
		DEFINE MSDIALOG oDlg1EC FROM  69,70 TO 165,331 TITLE  '::.. Estorno Conciliação DDA ..::' PIXEL
		@  0, 2 TO 28, 128 OF oDlg1EC	PIXEL
		@  7.5,  9 SAY  "Registro já conciliado/cancelado"  SIZE 115, 7 OF oDlg1EC PIXEL
		@ 14  ,  9 SAY  "Deseja estornar a conciliação?"  SIZE 100, 7 OF oDlg1EC PIXEL
		DEFINE SBUTTON FROM 32, 71 TYPE 1 ENABLE ACTION (nOpca1:=1,oDlg1EC:End()) OF oDlg1EC
		DEFINE SBUTTON FROM 32, 99 TYPE 2 ENABLE ACTION (oDlg1EC:End()) OF oDlg1EC

		ACTIVATE MSDIALOG oDlg1EC CENTERED

		IF	nOpca1 == 1

			//Cancela reconciliacao
			nRecOrig := VAL(TRBDDA->SEQMOV)
			nSeqSE2	:= VAL(TRBDDA->SEQCON)
			nRecSE2	:= TRBDDA->REC_SE2
			nRecDDA	:= TRBDDA->REC_DDA

			//Limpo os dados do registro de SE2 conciliado
			dbSelectArea("TRBDDA")
			TRBDDA->FIL_SE2 	:= Space(Len(TRBDDA->FIL_SE2))
			TRBDDA->FOR_SE2 	:= Space(Len(TRBDDA->FOR_SE2))
			TRBDDA->LOJ_SE2 	:= Space(Len(TRBDDA->LOJ_SE2))
			TRBDDA->TIT_SE2 	:= Space(Len(TRBDDA->TIT_SE2))
			TRBDDA->TIP_SE2 	:= Space(Len(TRBDDA->TIP_SE2))
			TRBDDA->DTV_SE2 	:= cTod("//")
			TRBDDA->VLR_SE2 	:= Space(Len(TRBDDA->VLR_SE2))
			TRBDDA->KEY_SE2 	:= Space(Len(TRBDDA->KEY_SE2))
			TRBDDA->REC_SE2		:= 0
			TRBDDA->SEQCON		:= Space(5)
			TRBDDA->OK			:= 19
			TRBDDA->ENCERRA   	:= Space(Len(TRBDDA->ENCERRA))
			TRBDDA->MOTIVO    	:= Space(Len(TRBDDA->MOTIVO))
			TRBDDA->ORDEM    	:= '1'
			TRBDDA->X_ANTRE		:= '2'
			If !Empty(TRBDDA->CNPJ_ORIG)
				If TRBDDA->CNPJ_DDA <> TRBDDA->CNPJ_ORIG
					TRBDDA->CNPJ_DDA	:= TRBDDA->CNPJ_ORIG
					TRBDDA->CNPJ_ORIG	:= Space(Len(TRBDDA->CNPJ_ORIG))
				EndIf
			EndIf

			If nNilvel == 17
				dVencMin	:= DaySub( TRBDDA->DTV_DDA, mv_par13 )
				dVencMax	:= DaySum( TRBDDA->DTV_DDA, mv_par12 )
				nValorMin	:= val(strTran(strTran(TRBDDA->VLR_DDA,".",""),",",".")) - mv_par14
				nValorMax	:= val(strTran(strTran(TRBDDA->VLR_DDA,".",""),",",".")) + mv_par15

				If auxCon()
					TRBDDA->OK     	:= 18
					TRBDDA->ORDEM	:= '4'
				Else
					TRBDDA->OK := 19
				EndIf
			EndIf

			If nNilvel <> 20 .and. nNilvel <> 21
				//Recupera o Registro Deletado
				SET DELETED OFF
				dbGoTo(nSeqSE2)
				dbRecall()

				SET DELETED ON
				dbGoto(nRecOrig)
			EndIf
		Else
			Alert("Operação cancelada pelo usuário.")
		Endif
	Endif
	oTitulo:Refresh()

	dbSelectArea("TRBDDA")
	dbSetOrder(10)
	If nOpca1 == 1
		TRBDDA->(dbGoto(nRecAux))
	Else
		TRBDDA->(dbGoto(nRecno))
	EndIf


Return(lRet)

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
static function Mark()
	local nX := 0

	For nX := 1 To Len(aManual)

		If nX <> oManual:nAt
			aManual[nX,1] := .F.
		Else
			aManual[oManual:nAt,1] := !aManual[oManual:nAt,1]
		EndIf

	Next nX
	oManual:DrawSelect()
	oManual:Refresh()
return

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function RetSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 	:= .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
				IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
				"",;
				"",;
				"",;
				SM0->M0_NOME,;
				SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0



//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function CriArq()

	Local aDbStru := {}
	Local nTamFil := TamSX3("E2_FILIAL")[1]
	Local nTamTip := TamSX3("E2_TIPO")[1]
	Local nTamFor := TamSX3("E2_FORNECE")[1]
	Local nTamLoj := TamSX3("E2_LOJA")[1]
	Local nTamCGC := TamSX3("A2_CGC")[1]
	//Ao tamanho do titulo serão somados os separadores
	Local nTamTit := TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+nTamFil+5
	Local nTamKey := TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+nTamTip+nTamFil
	Local nTamNom := TamSX3("E2_NOMFOR")[1]

	//Arquivo de reconciliacao
	//Campos de sequencia de conciliacao
	aadd(aDbStru,{"SEQMOV    ","C",05,0})
	aadd(aDbStru,{"SEQCON    ","C",05,0})

	//Campos do FIG - Conciliacao DDA
	aadd(aDbStru,{"FIL_DDA   ","C",nTamFil,0})
	aadd(aDbStru,{"FOR_DDA   ","C",nTamFor,0})
	aadd(aDbStru,{"LOJ_DDA   ","C",nTamLoj,0})
	aadd(aDbStru,{"NOM_FOR   ","C",nTamNom,0})
	aadd(aDbStru,{"TIT_DDA   ","C",15,0})
	aadd(aDbStru,{"TIP_DDA   ","C",nTamTip,0})
	aadd(aDbStru,{"DTV_DDA   ","D",08,0})
	aadd(aDbStru,{"VLR_DDA   ","C",18,0})

	aadd(aDbStru,{"CNPJ_DDA   ","C",nTamCGC,0})
	aadd(aDbStru,{"CNPJ_ORIG  ","C",nTamCGC,0})

	//Campos do SE2 - Cadastro Conta a Pagar
	aadd(aDbStru,{"FIL_SE2   ","C",nTamFil,0})
	aadd(aDbStru,{"FOR_SE2   ","C",nTamFor,0})
	aadd(aDbStru,{"LOJ_SE2   ","C",nTamLoj,0})
	aadd(aDbStru,{"TIT_SE2   ","C",nTamTit,0})  //Numero do titulo com separadores (para visualizacao)
	aadd(aDbStru,{"TIP_SE2   ","C",nTamTip,0})
	aadd(aDbStru,{"DTV_SE2   ","D",08,0})
	aadd(aDbStru,{"VLR_SE2   ","C",18,0})
	aadd(aDbStru,{"KEY_SE2   ","C",nTamKey,0}) //Numero do titulo sem separadores (para comparacao)

	//Campos auxiliares
	aadd(aDbStru,{"REC_DDA   ","N",09,0})
	aadd(aDbStru,{"REC_SE2   ","N",09,0})
	aadd(aDbStru,{"OK        ","N",02,0})
	aadd(aDbStru,{"CODBAR    ","C",44,0})

	//Campos de encerramento
	aadd(aDbStru,{"ENCERRA   ","C",01,0})
	aadd(aDbStru,{"MOTIVO    ","C",200,0})
	aadd(aDbStru,{"RAIZCNPJ  ","C",8,0})

	//Campos de ordenação
	aadd(aDbStru,{"ORDEM     ","C",1,0})
	aadd(aDbStru,{"X_ANTRE   ","C",1,0})


	//------------------
	//Criação da tabela temporaria
	//------------------
	If oTempDB <> Nil
		oTempDB:Delete()
		oTempDB := Nil
	Endif

	oTempDB := FWTemporaryTable():New( "TRBDDA" )
	oTempDB:SetFields(aDbStru)
	oTempDB:AddIndex("1" , {"FOR_DDA","LOJ_DDA","DTV_DDA","TIT_DDA"})
	oTempDB:AddIndex("2" , {"FOR_DDA","LOJ_DDA","TIT_DDA","DTV_DDA"})
	oTempDB:AddIndex("3" , {"TIT_DDA"})
	oTempDB:AddIndex("4" , {"FOR_SE2","LOJ_SE2","DTV_SE2","KEY_SE2"})
	oTempDB:AddIndex("5" , {"FOR_SE2","LOJ_SE2","KEY_SE2","DTV_SE2"})
	oTempDB:AddIndex("6" , {"KEY_SE2"})
	oTempDB:AddIndex("7" , {"SEQMOV","FOR_DDA","LOJ_DDA","DTV_DDA","TIT_DDA"})
	oTempDB:AddIndex("8" , {"DTV_SE2","DTV_DDA"})
	oTempDB:AddIndex("9" , {"RAIZCNPJ"})
	oTempDB:AddIndex("A" , {"ORDEM","DTV_SE2","DTV_DDA"})


	oTempDB:Create()

Return


//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function CriaSX1(cPerg, aPergs)
	Local aCposSX1	:= {}
	Local nX 		:= 0
	Local lAltera	:= .F.
	Local cKey		:= ""
	Local nj		:= 1
	Local aArea		:= GetArea()
	Local lUpdHlp	:= .T.

	aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
		"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
		"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
		"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
		"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
		"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
		"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
		"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP", "X1_PICTURE"}

	dbSelectArea( "SX1" )
	dbSetOrder(1)

	cPerg := PadR( cPerg , Len(X1_GRUPO) , " " )

	For nX:=1 to Len(aPergs)
		lAltera := .F.
		If MsSeek( cPerg + Right( Alltrim( aPergs[nX][11] ) , 2) )

			If ( ValType( aPergs[nX][Len( aPergs[nx] )]) = "B" .And. Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
				aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
				lAltera := .T.
			Endif

		Endif

		If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
			lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
		Endif

		If ! Found() .Or. lAltera
			RecLock("SX1",If(lAltera, .F., .T.))
			Replace X1_GRUPO with cPerg
			Replace X1_ORDEM with Right(ALLTRIM( aPergs[nX][11] ), 2)
			For nj:=1 to Len(aCposSX1)
				If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
						FieldPos(AllTrim(aCposSX1[nJ])) > 0 .And. ValType(aPergs[nX][nJ]) != "A"
					Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
				Endif
			Next nj
			MsUnlock()
		Endif
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."

		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif

		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif

		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif

		// Caso exista um help com o mesmo nome, atualiza o registro.
		lUpdHlp := ( !Empty(aHelpSpa) .and. !Empty(aHelpEng) .and. !Empty(aHelpPor) )
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdHlp)

	Next
	RestArea(aArea)

Return()
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function Legenda()

	Local nY     	:= 0
	Local nX     	:= 0
	Local aBmp[21]
	Local aSays[21]
	Local oDlgLeg

	DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aLegenda)*20)+110, 600 TITLE '::.. LEGENDAS CONCILIADOR DDA ..::' OF oMainWnd PIXEL

	DEFINE FONT oBold 	NAME "Arial" SIZE 0, -13 BOLD
	DEFINE FONT oBold2 	NAME "Arial" SIZE 0, -11 BOLD


	@ 15,10 TO 013,400 LABEL '' OF oDlgLeg PIXEL
	//@ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
	@ 03,03 SAY "LEGENDA  - [OK] Valor Exato, [IN] Intervalo Definido Paramtro, [RZ] Raiz CNPJ" OF oDlgLeg PIXEL SIZE 300,009 FONT oBold
	nLin := 20
	nAux := 0
	nCol := 05
	nY 	 := 0
	For nX := 1 To Len(aLegenda)

		nLin += 10

		@ nLin,nCol 		BITMAP aBMP[nX]  		RESNAME aLegenda[nX][1] 	OF oDlgLeg  SIZE 20,10 				PIXEL NOBORDER
		@ nLin,nCol+10 	SAY If((nY+=1)==nY,aLegenda[nY][2]+If(nY==Len(aLegenda),If((nY:=0)==nY,"",""),""),"") 	OF oDlgLeg  PIXEL SIZE 200,009 FONT oBold2
	Next nX
	nY := 0

	oDlgLeg:bLClicked:= {||oDlgLeg:End()}

	ACTIVATE MSDIALOG oDlgLeg CENTERED

Return(NIL)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function EncDDA()
	Local oBtnCanc
	Local oBtnConf
	Local oGBarras
	Local cGBarras := ''
	Local oGCNPJ
	Local cGCNPJ := ''
	Local oGMotivo
	Local cGMotivo := space(200)
	Local oGroup1
	Local oGroup2
	Local oGTitulo
	Local cGTitulo := ''
	Local oGValor
	Local nGValor := 0
	Local oGVencto
	Local dGVencto := cTod("")
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local lOK		:= .F.
	Static oDlgMot

	nGValor  := TRBDDA->VLR_DDA
	dGVencto := TRBDDA->DTV_DDA
	cGTitulo := TRBDDA->TIT_DDA
	cGCNPJ   := TRBDDA->CNPJ_DDA
	cGBarras := TRBDDA->CODBAR
	cGMotivo := TRBDDA->MOTIVO


	If TRBDDA->OK == 18 .OR. TRBDDA->OK == 19

		DEFINE MSDIALOG oDlgMot TITLE "MOTIVO ENCERRAMENTO" FROM 000, 000  TO 250, 700 COLORS 0, 16777215 PIXEL //STYLE nOR( WS_VISIBLE, WS_POPUP )

		@ 002, 002 GROUP oGroup1 TO 044, 347 PROMPT " ::.. DADOS DDA ..:: " OF oDlgMot COLOR 0, 16777215 PIXEL
		@ 013, 007 SAY oSay1 PROMPT "TITULO" SIZE 025, 007 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 012, 038 MSGET oGTitulo VAR cGTitulo SIZE 060, 010 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 013, 119 SAY oSay2 PROMPT "VENCIMENTO" SIZE 040, 007 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 012, 161 MSGET oGVencto VAR dGVencto SIZE 060, 010 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 013, 253 SAY oSay3 PROMPT "VALOR" SIZE 025, 007 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 012, 281 MSGET oGValor VAR nGValor SIZE 060, 010 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 029, 007 SAY oSay4 PROMPT "CNPJ" SIZE 025, 007 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 027, 038 MSGET oGCNPJ VAR cGCNPJ SIZE 060, 010 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 029, 119 SAY oSay5 PROMPT "COD. BARRAS" SIZE 042, 007 OF oDlgMot COLORS 0, 16777215 PIXEL
		@ 027, 161 MSGET oGBarras VAR cGBarras SIZE 181, 010 OF oDlgMot COLORS 0, 16777215 PIXEL

		@ 046, 003 GROUP oGroup2 TO 078, 348 PROMPT "... MOTIVO ... " OF oDlgMot COLOR 0, 16777215 PIXEL
		@ 058, 006 MSGET oGMotivo VAR cGMotivo SIZE 337, 010 OF oDlgMot COLORS 0, 16777215 PIXEL

		@ 081, 282 BUTTON oBtnCanc PROMPT "C&ANCELAR" SIZE 065, 025 OF oDlgMot PIXEL
		@ 081, 212 BUTTON oBtnConf PROMPT "&CONFIRMAR" SIZE 065, 025 OF oDlgMot PIXEL

		oBtnCanc:bAction := {|| lOK := .F., oDlgMot:End()}
		oBtnConf:bAction := {|| iif(Empty(cGMotivo),Alert("Favor preencher o motivo do cancelamento."),(lOK := .T., oDlgMot:End()))}

		oGValor:Disable()
		oGVencto:Disable()
		oGTitulo:Disable()
		oGCNPJ:Disable()
		oGBarras:Disable()


		ACTIVATE MSDIALOG oDlgMot CENTERED

		If lOK
			nNivel := 20
			RecLock("TRBDDA")
			TRBDDA->ENCERRA := 'S'
			TRBDDA->MOTIVO := cGMotivo
			TRBDDA->OK     	:= nNivel	// NIVEL DE CONCILIACAO
			MsUnlock()
		EndIf
	Else
		MsgAlert("Não é possível fazer o cancelamento do DDA para registro com conciliação.","Registsro ja conciliado")
	EndIf
Return

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function LOGDDA()
	local cLog := ''
	local aDados := {}

	If FIG->FIG_CONCIL == '1'
		If !Empty(FIG->FIG_XLOGGR)
			aDados := StrTokArr2(FIG->FIG_XLOGGR, '|', .T.)

			cLog := padr("USUARIO",14,' ') + '  :  ' + aDados[1] + CRLF + ;
				padr("DATA",16,' ')    + '  :  ' + cValToChar(stod(aDados[2])) + CRLF + ;
				padr("HORA",16,' ')    + '  :  ' + aDados[3]

			AVISO("Registro DDA - Conciliado por:", cLog, {"Fechar"}, 1)
		Else
			MsgInfo("Registro não conciliado pelo [ @Conciliador DDA ].","Aviso")
		EndIf
	Else
		MsgInfo("Registro não conciliado.","Aviso")
	EndIf


return()


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
static function auxCon()
	local cQuery := ''
	local lxRet	 := .F.
	local aAreaAux	:= GetArea()

	cQuery := " SELECT COUNT(*) AS REG
	cQuery += " FROM "+RetSqlName("SE2")+" SE2
	cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
	cQuery += " WHERE SE2.D_E_L_E_T_ = ' '
	cQuery += "   AND E2_FILIAL 	>= '" + mv_par01 + "' "
	cQuery += "   AND E2_FILIAL 	<= '" + mv_par02 + "' "
	If mv_par07 == 1
		cQuery +=	"   AND E2_VENCTO	>= '"	+ DTOS(dVencMin) + "' "
		cQuery +=	"   AND E2_VENCTO	<= '"	+ DTOS(dVencMax) + "' "
	Else
		cQuery +=	"   AND E2_VENCREA	>= '"	+ DTOS(dVencMin) + "' "
		cQuery +=	"   AND E2_VENCREA	<= '"	+ DTOS(dVencMax) + "' "
	Endif
	cQuery += " AND E2_SALDO >= " + cValToChar(nValorMin)
	cQuery += " AND E2_SALDO <= " + cValToChar(nValorMax)
	cQuery += " AND E2_CODBAR = '" + Space(TAMSX3("E2_CODBAR")[1]) + "'
	// cQuery += " AND E2_X_ANTRE <> '1'
	TcQuery cQuery New Alias(cTRBPos := GetNextAlias())

	dbSelectArea((cTRBPos))
	If (cTRBPos)->REG > 0
		lxRet := .T.
	EndIf

	(cTRBPos)->(dbCloseArea())

	restArea(aAreaAux)

return(lxRet)


Static Function CONCFIG()


	/*
	rotina criada para calcular
	*/
	_cQuery:= ""
	_cQuery+= " UPDATE "+RetSqlName("FIG")+" SET FIG_CONCIL ='1' "
	_cQuery+= "   FROM "+RetSqlName("FIG")
	_cQuery+= " INNER JOIN "+RetSqlName("SE2")+" ON "+RetSqlName("SE2")+".D_E_L_E_T_=''
	_cQuery+= "  AND LEFT (FIG_FILIAL,2)  = LEFT(E2_FILIAL,2)
	////Solicitado pela Usuaria Neide - Irá conciliar titulos gerados pelas matrizes e com código de barras.
	//_cQuery+= " AND FIG_FORNEC = E2_FORNECE
	//_cQuery+= " AND FIG_LOJA = E2_LOJA
	//_cQuery+= " AND FIG_CNPJ = E2_XCNPJ
	_cQuery+= " AND SUBSTRING(FIG_CNPJ,1,8) = SUBSTRING(E2_XCNPJ,1,8)
	_cQuery+= " AND FIG_VALOR = E2_VALOR
	_cQuery+= " AND FIG_CODBAR = E2_CODBAR
	_cQuery+= " AND FIG_CONCIL <> '1'
	_cQuery+= " AND E2_SALDO <>  0
	//_cQuery+= " AND E2_VENCTO = '20190531'
	_cQuery+= " AND E2_VENCTO >= (SELECT CONVERT(VARCHAR(8),GETDATE(),112))
	_cQuery+= " WHERE "+RetSqlName("FIG")+".D_E_L_E_T_=''
	TCSQLExec( _cQuery)


Return()
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function AlteraSe2()
Local cPrefixo := SUBSTR(TRBDDA->TIT_SE2,1,3)
Local cTitulo  := SUBSTR(TRBDDA->TIT_SE2,5,9)
Local cParcela := SUBSTR(TRBDDA->TIT_SE2,15,2)
Private CLOTE  := ""
Private mv_par03 := 2

dbSelectArea("SE2")
SE2->(dbSetOrder(1))	//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
If SE2->(dbSeek(TRBDDA->FIL_SE2+cPrefixo+cTitulo+cParcela+TRBDDA->TIP_SE2+TRBDDA->FOR_SE2+TRBDDA->LOJ_SE2))
	Fa050Alter("SE2", SE2->(RECNO()), 4)
	MsgAlert("Título alterado com sucesso!")
Else
	MsgAlert("Título não encontrado!")
EndIf

Return
