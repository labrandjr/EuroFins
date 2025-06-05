#include "protheus.ch"
#include "tcbrowse.ch"
#include "topconn.ch"

Static aPrazos

/*/{Protheus.doc} pcd
Rotina para geracao de provisao para cobranca duvidosas
@type function
@version 12.1.27
@author adm_tla8
@since 20/08/2022
/*/
user Function Euro_PCD()

	private aRotina := MenuDef()
	private cCadastro := OemToAnsi("Geracao de provisao para cobranca duvidosa - Eurofins") //
    private  dDataCalc := dDataBase

	aPergAux := {}
	Pergunte("EUROPCD02", .F., , , , , @aPergAux)
	MV_PAR01 := 90
	MV_PAR02 := 50
	MV_PAR03 := 150
	MV_PAR04 := 75
	MV_PAR05 := 360
	MV_PAR06 := 100
	MV_PAR07 := 0
	MV_PAR08 := 0
	MV_PAR09 := 0
	MV_PAR010 := 0
	MV_PAR011 := 0
	MV_PAR012 := 0
	MV_PAR013 := 0
	MV_PAR014 := 0
	MV_PAR015 := 0
	MV_PAR016 := 0
	MV_PAR017 := 0
	MV_PAR018 := 0
	MV_PAR019 := 0
	MV_PAR020 := 0
	//Chama a rotina para salvar os parâmetros
	__SaveParam("EUROPCD002", aPergAux)

	SetPrz(.T.)


	mBrowse( 6, 1,22,75,"SE1",,,,,, U_EPCD_Leg("SE1"))

	dbSelectArea("SE1")
	dbSetOrder(1)

	aPrazos	:=	Nil

Return
// --------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EPCD_GERA
Gera a provisao
@type function
@version 12.1.27
@author adm_tla8
@since 20/08/2022
@return return_type, return_description
/*/
user Function EPCD_GERA()
	Local bNewProc	:=	{|oCenterPanel,lEnd| AuxGera(oCenterPanel)}
	LOCAL aTreeProc := {}
	Local nX
	Local cTxtProc	:= "O Objetivo desta rotina é gerar lancamentos contábeis das provisoes para cobranca duvidosa" + CRLF
	cTxtProc	+= "O valor das provisoes sera calculado com base nos parametros escolhidos para o reprocesamento e " + CRLF
	cTxtProc	+= "nos limites e percentuais informados:"	+CRLF+CRLF
	For nX:= 1 To Len(aPrazos)
		If nX == 1
			cTxtProc	+=	"Vencidos a  mais de "+Str(aPrazos[nX,2],5)+" dias : "+Str(aPrazos[nX,3],6,2)+"%"+CRLF+CRLF
		Else
			cTxtProc	+=	"Vencidos entre "+Str(aPrazos[nX,2],5)+" e "+Str(aPrazos[nX-1,2],5)+" dias: "+Str(aPrazos[nX,3],6,2)+"%"+CRLF
		Endif
	Next

	Pergunte("EUROPCD001",.F.)

	tNewProcess():New("FINA650",OemToAnsi("Geracao de provisao para cobranca duvidosa - Eurofins"),bNewProc,cTxtProc,"EUROPCD001",aTreeProc)

Return

// --------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AuxGera
Rotina para geracao de provisao para cobranca duvidosas
@type function
@version 12.1.27
@author adm_tla8
@since 20/08/2022
@param oSelf, object, param_description
@return return_type, return_description
/*/
Static Function AuxGera(oSelf)
	Local cAliasQry1 := GetNextAlias()
	Local nPerc      := 0
	Local nValProv   := 0
	Local aProvisao  := {}
	Local cArquivo   := ""
	Local nTotalLanc := 0
	Local nX
	Local aDiario    := {}
	Local lOnline    := .F.
	Local aFlagCTB   := {}
	Local lUsaFlag   := SuperGetMV( "MV_CTBFLAG" , .T., .F.)
	Local cWherVen   := "%%" // Define qual o vencimento do E1 será escolhido pelo usuário no PE para execução da Query.
	Local cCpoVenc   := "E1_VENCREA" // Vencimento padrão utilizado pelo sistema.
	local cEmpBkp := cEmpAnt
	local cFilBkp := cFilAnt
	local cNumEmpBkp := cNumEmp
	local aEmpresas  := FWAllCompany()
	Local aFiliais   := {}
	Local nEmpAtu    := 0
	Local nFilAtu    := 0
	//NOTE VerIfica o numero do Lote
	PRIVATE cLote
	LoteCont( "FIN" )

	aRetInfo := {'FLAG', 'SM0_CODFIL', 'SM0_EMPRESA', 'SM0_FILIAL'}
	lCheckUser  := .F.
	lAllEmp     := .T.
	lOnlySelect := .T.
	aFiliais := FwListBranches( lCheckUser , lAllEmp , lOnlySelect , aRetInfo )

	// For nEmpAtu := 1 To Len(aEmpresas)
	// 	aFiliais := FWAllFilial(aEmpresas[nEmpAtu])

	//Percorre todas as filiais da empresa atual
	cFilFil := ""
	aEval(aFiliais,{|x| cFilFil += iif(x[1],x[2]+'#','') })
	cFilFil := substr(cFilFil,1,len(alltrim(cFilFil))-1)
	cQuery := ""
	cQuery += "SELECT CTG_FILIAL AS FILIAL FROM " + RetSqlName("CTG") +" CTG "
	cQuery += " WHERE CTG.D_E_L_E_T_ = ''"
	cQuery += "   AND CTG_EXERC = '" + Substr(dTos(dDataBase),1,4) + "'
	cQuery += "   AND CTG_PERIOD = '" + Substr(dTos(dDataBase),5,2) + "'
	cQuery += "   AND CTG_STATUS != '1'
	cQuery += "   AND CTG_FILIAL IN " + FormatIn(cFilFil,"#")
	TcQuery cQuery New Alias (cTRB_CTG := GetNextAlias())

	lContinua := .T.
	dbSelectArea((cTRB_CTG))
	while (cTRB_CTG)->(!eof())
		lContinua := .F.
		FwAlertWarning("Foi identificado calendário encerrado para o perído para FILIAL [" + (cTRB_CTG)->FILIAL + "].","Validação Calendário.")
		(cTRB_CTG)->(dbSkip())
	EndDo
	(cTRB_CTG)->(dbCloseArea())

	If !lContinua
		return(.F.)
	EndIf

	For nFilAtu := 1 To Len(aFiliais)
		If aFiliais[nFilAtu][1]
			cEmpFil   := aFiliais[nFilAtu][2] //padrão EEFF
			aDiario   := {}
			lOnline   := .F.
			aFlagCTB  := {}
			aProvisao := {}
			CursorWait()
			cEmpAnt := '01'//SubStr(cEmpFil,1,2)
			cFilAnt := alltrim(cEmpFil)
			cNumEmp := alltrim(cEmpAnt + cFilAnt)
			DbCloseAll()
			OpenFile(cNumEmp)
			ResetModulo( {"SIGAFIN",6} )
			CursorArrow()


			aPergAux := {}
			Pergunte("EUROPCD002", .F., , , , , @aPergAux)
			MV_PAR01 := 90
			MV_PAR02 := 50
			MV_PAR03 := 150
			MV_PAR04 := 75
			MV_PAR05 := 360
			MV_PAR06 := 100
			MV_PAR07 := 0
			MV_PAR08 := 0
			MV_PAR09 := 0
			MV_PAR010 := 0
			MV_PAR011 := 0
			MV_PAR012 := 0
			MV_PAR013 := 0
			MV_PAR014 := 0
			MV_PAR015 := 0
			MV_PAR016 := 0
			MV_PAR017 := 0
			MV_PAR018 := 0
			MV_PAR019 := 0
			MV_PAR020 := 0
			//Chama a rotina para salvar os parâmetros
			__SaveParam("EUROPCD002", aPergAux)

			Pergunte("EUROPCD001",.F.)
			dDatBkp := dDataBase
			dDataCalc := MV_PAR14

	        SetPrz(.T.)
            Pergunte("EUROPCD001",.F.)

			If Len(aPrazos) > 0
				oSelf:Savelog("Processamento iniciado.")
				oSelf:SetRegua1(3)
				oSelf:IncRegua1()
				oSelf:SetRegua2(2)
				oSelf:IncRegua2()
				nTam:=	  TAMSX3("E1_SALDO")[1]
				nDec:=	  TAMSX3("E1_SALDO")[2]
				// cNotIn		:= '%'+FormatIn(MVRECANT+"|"+MV_CPNEG,"|")+"%"

				//NOTE Ponto de entrada permite a escolha do campo relativo ao vencimento que será observado ao gerar a provisão
				If ExistBlock("F650VnPro")
					cCpoVenc := ExecBlock("F650VnPro",.F.,.F.)
					// Verifica se existe o campo na tabela SE1
					If SE1->( FieldPos(cCpoVenc) ) <= 0
						cCpoVenc := "E1_VENCREA" // Vencimento padrão utilizado pelo sistema.
						Help(" ",1,"NOMECPO")
					EndIf
				Endif
				cWherVen := "% " +cCpoVenc+ " < '" +dTOS(aPrazos[Len(aPrazos),1]) + "' %"
				cCpoVenc := "%" +cCpoVenc+ "%"
				BeginSql Alias cAliasQry1

                    COLUMN E1_EMIS1 AS DATE
                    COLUMN E1_VENCORI AS DATE
                    COLUMN E1_VENCTO AS DATE
                    COLUMN E1_BAIXA AS DATE
                    COLUMN E1_SALDO AS NUMERIC(nTam,nDec)
                    COLUMN E1_IRRF AS NUMERIC(nTam,nDec)
                    COLUMN E1_MOEDA AS NUMERIC(2,0)

                    SELECT E1_SALDO, E1_IRRF,E1_MOEDA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, %exp:cCpoVenc%, E1_EMIS1, SE1.R_E_C_N_O_ AS RECSE1, SUM(FIA_VALOR) FIA_VALOR
                    FROM %table:SE1% SE1
                    INNER JOIN %TABLE:SA1% SA1 ON A1_FILIAL = %xFilial:SA1%
                                        AND A1_COD = E1_CLIENTE
                                        AND A1_LOJA = E1_LOJA
                                        AND A1_ZZCOLIG != 'S'
                        LEFT JOIN %TABLE:FIA% FIA ON FIA_FILIAL = %xFilial:FIA%
                                        AND FIA_CLIENT	=	E1_CLIENTE
                                        AND FIA_LOJA	=   E1_LOJA
                                        AND FIA_PREFIX	=   E1_PREFIXO
                                        AND FIA_NUM		=   E1_NUM
                                        AND FIA_PARCEL	=   E1_PARCELA
                                        AND FIA_TIPO	=   E1_TIPO
                        WHERE E1_FILIAL = %xFilial:SE1%
                            AND  E1_CLIENTE BETWEEN %exp:mv_par01% AND  %exp:mv_par02%
                            AND  E1_PREFIXO BETWEEN %exp:mv_par03% AND  %exp:mv_par04%
                            AND  E1_TIPO    BETWEEN %exp:mv_par05% AND  %exp:mv_par06%
                            AND  E1_NATUREZ BETWEEN %exp:mv_par07% AND  %exp:mv_par08%
                            AND  %exp:cWherVen%
                            AND  E1_TIPO IN ('NF','BOL','OT','FT')
                            AND  (E1_SALDO > 0 OR E1_BAIXA > %Exp:MV_PAR14% )
                            AND  SE1.%NotDel%
                        GROUP BY E1_SALDO, E1_IRRF, E1_MOEDA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, %exp:cCpoVenc%, E1_EMIS1, SE1.R_E_C_N_O_
                        ORDER BY %exp:cCpoVenc%
				EndSql

				oSelf:Savelog("Fim selecao movimentos.")
				cCpoVenc := SUBSTR(cCpoVenc,2,LEN(cCpoVenc)-2) // Retiro as tags
				While !EOF()

					dbSelectArea("SE1")
					SE1->(dbgoTo((cAliasQry1)->RECSE1))
					dDataReaj := dDataCalc
					cFilSE5 := SE1->E1_FILIAL
					If SE1->E1_VENCREA < dDataCalc .And. RecMoeda(SE1->E1_VENCREA,'1') > 0
						dDataReaj := SE1->E1_VENCREA
					EndIf

					nImpBaixado		:= 0
					// nImpBaixado		+= bscSaldo( "PIS", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA, SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
					// nImpBaixado		+= bscSaldo( "COF", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA, SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )
					// nImpBaixado		+= bscSaldo( "CSL", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA, SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )

					nTaxaDia    := Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA))

					nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, 1, dDataReaj,;
						MV_PAR14, SE1->E1_LOJA,	cFilSE5 , nTaxaDia, 0)

					nIrrf    := 0
					nValPCD  := nSaldo - nImpBaixado //(cAliasQry1)->E1_SALDO
					nIrrf    := (cAliasQry1)->E1_IRRF
					nValPCD  -= nIrrf
					nPerc    := GetPerc(&cCpoVenc)
					nValProv := (nPerc*nValPCD/100)-(cAliasQry1)->FIA_VALOR
					If Abs(nValProv) > 0 .And. Abs(nValProv) >= mv_par09
						AADD(aProvisao, {(cAliasQry1)->E1_PREFIXO, (cAliasQry1)->E1_NUM, (cAliasQry1)->E1_PARCELA, (cAliasQry1)->E1_TIPO, (cAliasQry1)->E1_CLIENTE, (cAliasQry1)->E1_LOJA, (cAliasQry1)->E1_MOEDA, nValProv})
					Endif
					(cAliasQry1)->(dBsKIP())
				Enddo

				oSelf:IncRegua2()
				oSelf:Savelog("Calculadas "+Str(Len(aProvisao))+" Provisoes. Gravando movimentos...")
				oSelf:IncRegua1()
				dbCloseArea()
				oSelf:SetRegua2(Len(aProvisao) +1 )
			EndIf

			If Len(aProvisao) > 0
				Begin Transaction
					lOnline	:= (mv_par12 == 1 .And. VerPadrao('51A'))
					If lOnline
						nHdlPrv := HeadProva(cLote,"FINA650",Substr(cUsuario,7,6),@cArquivo)
					Endif
					For nX := 1 To Len(aProvisao)
						oSelf:IncRegua2()
						cNextSeq	:=	GetSeq(aProvisao[nX])
						RecLock('FIA',.T.)
						FIA_FILIAL	:=  xFilial('FIA')
						FIA_PREFIX	:=  aProvisao[nX,1]
						FIA_NUM		:=  aProvisao[nX,2]
						FIA_PARCEL	:=  aProvisao[nX,3]
						FIA_TIPO	:=  aProvisao[nX,4]
						FIA_CLIENT	:=	aProvisao[nX,5]
						FIA_LOJA	:=  aProvisao[nX,6]
						FIA_MOEDA	:=  aProvisao[nX,7]

						FIA_VALOR	:=  aProvisao[nX,8]
						FIA_VLLOC	:=  xMoeda(aProvisao[nX,8],aProvisao[nX,7],1,dDataCalc)
						FIA_SEQ		:=	cNextSeq
						FIA_DIACTB	:=	MV_PAR10
						FIA_DTPROV	:=	dDataCalc
						MsUnLock()
						If lOnline

							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, {"FIA_LA", "S", "FIA", FIA->( Recno() ), 0, 0, 0} )
							Endif
							nTotalLanc += DetProva( nHdlPrv, '51A', "FINA650", cLote, /*nLinha*/, /*lExecuta*/,;
			                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
			                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
								If UsaSeqCor()
								aadd(aDiario,{"FIA",FIA->(RECNO()),FIA->FIA_DIACTB,"FIA_NODIA","FIA_DIACTB"})
							Else
								aDiario := {}
							EndIf
						Endif
					Next
					If lOnline
						//+-----------------------------------------------------+
						//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
						//+------------------------`-----------------------------+
						RodaProva(nHdlPrv,nTotalLanc)

						//+-----------------------------------------------------+
						//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
						//+-----------------------------------------------------+
						If !cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, (mv_par11 == 1) /*lDigita*/,;
								(mv_par12 == 1) /*lAglut*/, /*cOnLine*/, /*dData*/, /*dReproc*/,;
								@aFlagCTB, /*aDadosProva*/, aDiario )
							If cPaisLoc =="PTG"
								Final("Erro na geracao da contabilizao")
							Endif
						Endif

						aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
						aDiario := {}
					Endif
				End Transaction
			Endif
			oSelf:Savelog("Processamento finalizado.") //
			// If !IsBlind()
			// 	If Len(aProvisao) > 0
			// 		Aviso("Finalizado","Provisoes geradas com sucesso [ " + cFilAnt + " ].",{"Ok"})
			// 	Else
			// 		Aviso("Finalizado","Nenhuma provisao foi gerada [ " + cFilAnt + " ].",{"Ok"})
			// 	Endif
			// Endif

		EndIf
	Next
	// Next
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cNumEmp := cNumEmpBkp

	DbCloseAll()
	OpenFile(cNumEmp)
	ResetModulo( {"SIGAFIN",6} )


Return

// ----------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EPCD_VPRO
Visualiza as provisoes
@type function
@version 12.1.27
@author adm_tla8
@since 20/08/2022
@param cAlias, character, alias tabela
@param nReg, numeric, recno registro
@param nOpc, numeric, opção
/*/
user Function EPCD_VPRO(cAlias,nReg,nOpc)
	Local bWhile
	Local cQuery
	Local cSeek
	Local lQuery    := .T.
	Local oDlg
	Private aCols   := {}
	Private aHeader := {}

	RegToMemory("SE1",.F.)

	dbSelectArea("FIA")
	dbSetOrder(1)
	#IFDEF TOP
		lQuery  := .T.
		cQuery := "SELECT * "
		cQuery += "FROM "+RetSqlName("FIA")+" FIA "
		cQuery += "WHERE FIA.FIA_FILIAL='"+xFilial("FIA")+"' "
		cQuery += "	  				AND FIA_CLIENT		=	'"+SE1->E1_CLIENTE+"' "
		cQuery += "		  				AND FIA_LOJA		= '"+SE1->E1_LOJA		+"' "
		cQuery += "		  				AND FIA_PREFIX	=	'"+SE1->E1_PREFIXO+"' "
		cQuery += "		  				AND FIA_NUM			= '"+SE1->E1_NUM		+"' "
		cQuery += "		  				AND FIA_PARCEL	= '"+SE1->E1_PARCELA+"' "
		cQuery += "		  				AND FIA_TIPO		=	'"+SE1->E1_TIPO		+"' "
		cQuery += "		  				AND D_E_L_E_T_	=	' ' "
		cQuery += "ORDER BY "+SqlOrder(FIA->(IndexKey()))
		dbSelectArea("SC6")
		dbCloseArea()
	#ENDIF
	cSeek  := xFilial("FIA")+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
	bWhile := {|| xFilial("FIA")+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) }


	//+ Montagem do aHeader e aCols
	//+------------------------------------------------------------------------------------------------------------+
	//|FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,       |
	//|				  cQuery, bMountFile, lInclui )                                                                |
	//|nOpcx			- Opcao (inclusao, exclusao, etc).                                                         |
	//|cAlias		- Alias da tabela referente aos itens                                                          |
	//|nOrder		- Ordem do SINDEX                                                                              |
	//|cSeekKey		- Chave de pesquisa                                                                            |
	//|bSeekWhile	- Loop na tabela cAlias                                                                        |
	//|uSeekFor		- Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar |
	//|				  o registro)                                                                                  |
	//|aNoFields	- Array com nome dos campos que serao excluidos na montagem do aHeader                         |
	//|aYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader                         |
	//|lOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario   |
	//|cQuery		- Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera     |
	//|	           parametros cSeekKey e bSeekWhiele)                                                              |
	//|bMountFile	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)                     |
	//|lInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco                 |
	//|aHeaderAux	-                                                                                              |
	//|aColsAux		-                                                                                              |
	//|bAfterCols	- Bloco executado apos inclusao de cada linha no aCols                                         |
	//|bBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols                                     |
	//|bAfterHeader -                                                                                              |
	//|cAliasQry	- Alias para a Query                                                                           |
	//+------------------------------------------------------------------------------------------------------------+

	FillGetDados(2,"FIA",1,cSeek,bWhile,,,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,,/*bBeforeCols*/,/*bAfterHeader*/,"FIATRB")

	//Faz o calculo automatico de dimensoes de objetos
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( cAlias, nReg, nOpc, , , , , aPosObj[1],,3,,,)
	MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,"",,,,,,,,,,,)
	oDlg:lMaximized := .T.
	ACTIVATE MSDIALOG oDlg On INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
Return

// --------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EPCD_Leg
Cria uma janela contendo a legenda da mBrowse ou retorna a para o Browse
@type function
@version 12.1.27
@author adm_tla8
@since 20/08/2022
@param cAlias, character, alias da tabela
@param nReg, numeric, num. registro
@return array, array com a legenda
/*/
user Function EPCD_Leg(cAlias, nReg)
	Local aCores := {"BR_PRETO","BR_AZUL","BR_MARRON","BR_CINZA", "BR_LARANJA","BR_PINK","BR_AMARELO" }
	Local nX
	Local aRet	:=	{}

	If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		If Len(aPrazos) > 0
			For nX:= 1 To Len(aPrazos) +1
				If nX == 1
					aadd(aRet,{"SE1->(E1_SALDO > 0 .And. Dtos(E1_VENCREA) <= '"+Dtos(aPrazos[nX,1])+"')",aCores[nX]})
				ElseIf nX <= Len(aCores)  .And. nX <= Len(aprazos)
					aadd(aRet,{"SE1->(E1_SALDO > 0 .And. Dtos(E1_VENCREA) > '"+Dtos(aPrazos[nX-1,1])+"' .And. Dtos(E1_VENCREA) <= '"+Dtos(aprazos[nX,1])+"')",aCores[nX]})
				ElseiF nX > len(aPrazos)
					aadd(aRet,{"SE1->(E1_SALDO > 0 .And. Dtos(E1_VENCREA) > '"+Dtos(aprazos[nX-1,1])+"' .And. Dtos(E1_VENCREA) <= '"+dtos(dDataCalc)+"')",Iif(nX > len(aCores),'BR_BRANCO',aCores[nX])})
				Endif
			Next
		Endif
		Aadd(aRet,{"SE1->(E1_SALDO > 0 .And. Dtos(E1_VENCREA) > '"+Dtos(dDataCalc)+"')",'BR_VERDE'})
		Aadd(aRet,{"SE1->(E1_SALDO == 0 )",'BR_VERMELHO'})
	Else
		If Len(aPrazos) > 0
			For nX:= 1 To Len(aprazos) +1
				If nX == 1
					aadd(aRet,{aCores[nX], "Venc. mais de "+Str(aPrazos[nX,2],5)+" dias"})
				ElseIf nX <= Len(aCores)  .And. nX <= Len(aprazos)
					aadd(aRet,{aCores[nX], "Venc. entre "+Str(aPrazos[nX,2],5)+" e "+Str(aPrazos[nX-1,2],5)+" dias"})
				ElseiF nX > len(aPrazos)
					aadd(aRet,{'BR_BRANCO', "Venc. faz menos de "+Str(aPrazos[nX-1,2],5) +" dias"})
				Endif
			Next
		Endif
		aadd(aRet,{"BR_VERDE", "Nao vencidos"})
		aadd(aRet,{"BR_VERMELHO", "Baixados"})
		BrwLegenda("Legenda", "Legenda", aRet)
	Endif

Return aRet

// ---------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPrz
CArrega os percentuais e periodos em um array
@type function
@version 12.1.27
@author adm_tla8
@since 20/08/2022
@param lRefaz, logical, informa se refaz ou não os prazos
/*/
Static Function SetPrz(lRefaz)
	Local nI := 1
	Default lRefaz	:=	.F.
	aPrazos	:=	IIf(lRefaz,Nil,aPrazos)

	If aPrazos == Nil
		Pergunte('EUROPCD002',.F.)
		aPrazos	:=	{}
		While  nI<20 .And. &('mv_par'+StrZero(nI,2)) > 0
			AAdd(aPrazos, {dDataCalc-&('mv_par'+StrZero(nI,2)),&('mv_par'+StrZero(nI,2)),&('mv_par'+StrZero(nI+1,2))})
			nI += 2
		Enddo
		aSort(aPrazos,,,{|x,y| x[2]>y[2]})
	Endif
Return

// --------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EPCD_PRZ
Carrgar as perguntas de prazo e percentual
@type function
@version 12.1.27
@author adm_tla8
/*/
User Function EPCD_PRZ()

	If Pergunte('EUROPCD002',.T.)
		SetPrz(.T.)
	Endif

Return

// --------------------------------------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina :={{ OemToAnsi("Pesquisa"), "axPesqui" , 0 , 1},;
		{OemToAnsi("Percentuais")                   , "U_EPCD_PRZ"  , 0, 3},;
		{OemToAnsi("Vis. Titulo")                   , "AxVisual"    , 0, 2},;
		{OemToAnsi("Vis. Provis.")                  , "U_EPCD_VPRO" , 0, 2},;
		{OemToAnsi("Gerar provisao")                , "U_EPCD_GERA" , 0, 3},;
		{OemToAnsi("Reverte Provisao")              , "U_reverpdd"  , 0, 3},;
		{OemToAnsi("Estorno Provisao")              , "U_Estpcd"    , 0, 3},;
		{OemToAnsi("Exporta Provisao")              , "U_RptPCD"    , 0, 3},;
		{OemToAnsi("Legenda")                       , "U_EPCD_Leg"  , 0, 6}}

Return(aRotina)

// --------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPerc
Pega o percentual drovisao apra uma data
@type function
@version 12.1.27
@author adm_tla8
@since 20/08/2022
@param dData, date, param_description
/*/
static Function GetPerc(dData)
	Local nX	:=	1
	Local nPerc := 	0
	While nX <= Len(aPrazos)
		If dData < aPrazos[nX,1]
			nPerc	:=	aPrazos[nX,3]
			Exit
		EndIf
		nX++
	Enddo

Return nPerc

// --------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSeq
Pega a proxima sequencia de provisa
@type function
@version 12.1.27
@author adm_tla8
@since 20/08/2022
@param aProvisao, array, array das provisoes
@return character, numero da sequencia
/*/
Static Function GetSeq(aProvisao)
	Local cAliasQry1 := GetNextAlias()
	Local cRet	:=	""
	BeginSql Alias cAliasQry1
	SELECT MAX(FIA_SEQ) FIA_SEQ
	FROM %table:FIA% FIA
	WHERE FIA_FILIAL = %xFilial:FIA%
          AND  FIA_PREFIX 	= %exp:aProvisao[1]%
          AND  FIA_NUM   	= %exp:aProvisao[2]%
          AND  FIA_PARCEL  	= %exp:aProvisao[3]%
          AND  FIA_TIPO   	= %exp:aProvisao[4]%
          AND  FIA_CLIENT 	= %exp:aProvisao[5]%
          AND  FIA_LOJA		= %exp:aProvisao[6]%
  		  AND FIA.%NotDel%
	EndSql

	If Empty(FIA_SEQ)
		cRet	:=	"001"
	Else
		cRet	:=	Soma1(FIA_SEQ)
	Endif
	DbCloseArea()

Return cRet

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

static function bscSaldo(cTipo,nVlrAtu,cFilTit,cPrefTit,cNumTit,cCliTit,cLojTit, cTitPai)

	local nRet		:= 0
	local cQuery	:= ""
	local cAlias	:= GetNextAlias()


	cQuery		+= "SELECT " + CRLF
	cQuery		+= "	SUM(E1_VALOR) VALOR" + CRLF
	cQuery		+= "FROM " + CRLF
	cQuery		+= "	" + RetSqlTab("SE1") + CRLF
	cQuery		+= "WHERE " + CRLF
	cQuery		+= "	D_E_L_E_T_ = ' ' " + CRLF
	// cQuery		+= "	AND E1_TIPO = '" + cTipo + "' " + CRLF
	cQuery		+= "	AND E1_FILIAL = '" + cFilTit + "' " + CRLF
	cQuery		+= "	AND E1_TITPAI = '" + cTitPai + "' " + CRLF
	// cQuery		+= "	AND E1_PREFIXO = '" + cPrefTit + "' " + CRLF
	// cQuery		+= "	AND E1_NUM = '" + cNumTit + "' " + CRLF
	// cQuery		+= "	AND E1_CLIENTE = '" + cCliTit + "' " + CRLF
	// cQuery		+= "	AND E1_LOJA = '" + cLojTit + "' " + CRLF
	cQuery		+= "	AND E1_SALDO = '0' " + CRLF
	cQuery		+= "" + CRLF

	tcquery cQuery New Alias &cAlias

	if (cAlias)->(!Eof())
		if nVlrAtu == 0 .AND. (cAlias)->VALOR > 0
			nRet	:= (cAlias)->VALOR
		else
			nRet	:= nVlrAtu - (cAlias)->VALOR
		endif
	else
		nRet	:= nVlrAtu
	endif

	(cAlias)->(DbCloseArea())


return nRet



