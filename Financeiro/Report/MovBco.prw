#include 'totvs.ch'
#include 'topconn.ch'


user function MovBco()
	local l_Job        := .F.
	local cTitle       := "Movimento Bancário Periodo"
	local bProcess     := ""
	local cDescription := "Este programa tem como objetivo exportar o saldo do movimento bancario por periodo."
	local cPerg        := 'MOVBCO'
	private cFunction  := Substr(FunName(),1,8)
	l_Job              := IsBlind()
	bProcess           := {|oSelf| Processa(oSelf)}

	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg,,.T.,3,'',.T. )


return()
// ---------------------------------------------------------------------------------------------------------------------------------------------------

static function Processa(op_Self)

	local cQuery as character
	local cSheet as character
	local cTitulo as character
	local cArquivo as charecter

	op_Self:SetRegua1(2)
	op_Self:SetRegua2(6)

	cArquivo := "c:\temp\MovBCO_" + alltrim(MV_PAR01) + ".XML"

	cPeriodo := substr(MV_PAR01,3,4) + substr(MV_PAR01,1,2)

    cTabela14 := Tab14()
	cTitulo := "Movimento Conciliado Banco - Periodo " + substr(MV_PAR01,1,2) + '-' + substr(MV_PAR01,3,4)

	cQuery := ""
	cQuery += "SELECT * FROM " + RetSqlName("SZM") +" SZM WITH(NOLOCK) WHERE SZM.D_E_L_E_T_ = '' ORDER BY ZM_FILEMP "
	TcQuery cQuery New Alias (cTRB_EMP := GetNextAlias())

	dbSelectArea((cTRB_EMP))
	(cTRB_EMP)->(dbGoTop())
	IF (cTRB_EMP)->(!eof())

		oFWMsExcel := FWMsExcelEx():New()
		while (cTRB_EMP)->(!eof())
			cSheet := (cTRB_EMP)->ZM_CODIGO
			cXEmp := (cTRB_EMP)->ZM_FILEMP

			cQuery := ""
			cQuery += " SELECT E5_BANCO AS BANCO, E5_AGENCIA AS AGENCIA, E5_CONTA AS CONTA FROM " + RetSqlName("SE5") + " SE5 WITH(NOLOCK)
			cQuery += "  WHERE SE5.D_E_L_E_T_ = ''
			cQuery += " AND SUBSTRING(E5_DATA,1,6) = '" + cPeriodo + "'
			cQuery += " AND SUBSTRING(E5_FILIAL,1,2) = '" + cXEmp + "'
			cQuery += " GROUP BY E5_BANCO, E5_AGENCIA, E5_CONTA
			cQuery += " ORDER BY 1, 2
			TcQuery cQuery New Alias (cTRB_BCO := GetNextAlias())

			dbSelectArea((cTRB_BCO))
			(cTRB_BCO)->(dbGoTop())
			IF (cTRB_BCO)->(!eof())


				oFWMsExcel:AddworkSheet(cSheet)
				oFWMsExcel:AddTable(cSheet, cTitulo)

				oFWMsExcel:AddColumn(cSheet, cTitulo,"Reporting Company"    ,1,1)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Periodo"              ,1,1)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Banco"                ,1,1)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Agencia"              ,1,1)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Conta"                ,1,1)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Nome Banco"           ,1,1)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"NReduz Banco"         ,1,1)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Desc. Operacao"       ,1,1)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor Receber"        ,3,2)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor Pagar"          ,3,2)
				oFWMsExcel:AddColumn(cSheet, cTitulo,"Saldo"                ,3,2)


				while (cTRB_BCO)->(!eof())


					cQuery := ""
					cQuery += " SELECT ZM_CODIGO [Filial]
					cQuery += " 	 , SUBSTRING(E5_DATA,1,6) AS [Periodo]
					cQuery += " 	 , E5_BANCO AS [Banco]
					cQuery += " 	 , E5_AGENCIA AS [Agencia]
					cQuery += " 	 , E5_CONTA AS [Conta]
					cQuery += " 	 , ISNULL(A6_NOME,'') AS [Nome]
					cQuery += " 	 , ISNULL(A6_NREDUZ,'') AS [Nreduz]
					cQuery += " 	 , CASE WHEN ISNULL(A6_NOME,'') LIKE '%APLICACAO%' THEN ISNULL(ED_DESCRIC,'') ELSE 'MOVIMENTO' END AS [Operacao]
					cQuery += " 	 , SUM(CASE WHEN E5_RECPAG = 'R' THEN E5_VALOR ELSE 0 END) AS [Receber]
					cQuery += " 	 , SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR *-1 ELSE 0 END) AS [Pagar]
					cQuery += "      , SUM(CASE WHEN E5_RECPAG = 'R' THEN E5_VALOR ELSE 0 END) + SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR *-1 ELSE 0 END) AS Saldo
					cQuery += " FROM " + RetSqlName("SE5") + " SE5 WITH(NOLOCK)
					cQuery += " INNER JOIN " + RetSqlName("SZM") + " SZM WITH(NOLOCK)  ON SZM.D_E_L_E_T_ = '' AND ZM_FILEMP = SUBSTRING(E5_FILIAL,1,2)
					cQuery += " LEFT JOIN " + RetSqlName("SA6") + " SA6 WITH(NOLOCK) ON SA6.D_E_L_E_T_ = '' AND A6_FILIAL = SUBSTRING(E5_FILIAL,1,2) AND A6_COD = E5_BANCO AND A6_AGENCIA = E5_AGENCIA AND A6_NUMCON = E5_CONTA
					cQuery += " LEFT JOIN " + RetSqlName("SED") + " SED WITH(NOLOCK) ON SED.D_E_L_E_T_ = '' AND ED_CODIGO = E5_NATUREZ
					cQuery += " WHERE SE5.D_E_L_E_T_ = ''
					cQuery += " AND SE5.E5_BANCO = '" +  (cTRB_BCO)->BANCO + "'
					cQuery += " AND SE5.E5_AGENCIA = '" +  (cTRB_BCO)->AGENCIA + "'
					cQuery += " AND SE5.E5_CONTA = '" +  (cTRB_BCO)->CONTA + "'
					cQuery += " AND substring(SE5.E5_FILIAL,1,2) = '" +  cXEmp + "'
					cQuery += " AND substring(SE5.E5_DATA,1,6) = '" + cPeriodo + "'
                    cQuery += " AND E5_RECPAG != ''
                    cQuery += " AND E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','V2','C2','CP','TL','BA','I2','EI','VA')
                    cQuery += " AND (E5_TIPODOC <> 'VL' OR E5_TIPO <> 'VP')
                    cQuery += " AND NOT (E5_TIPODOC = 'ES' AND E5_RECPAG = 'P' AND E5_MOTBX = 'CMP')
                    cQuery += " AND NOT (E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ = '               ' AND (E5_TIPODOC NOT IN('TR','TE')))
                    cQuery += " AND NOT (E5_TIPODOC IN ('TR','TE') AND ((E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') OR (E5_DOCUMEN BETWEEN '*                ' AND '*ZZZZZZZZZZZZZZZZ' )))
                    cQuery += " AND	NOT (E5_TIPODOC IN ('TR','TE') AND E5_NUMERO = '      ' AND  E5_MOEDA NOT IN " + FormatIn(cTabela14+"/DO","/") + " )
                    cQuery += " AND	E5_VALOR <> 0
                    cQuery += " AND E5_SITUACA <> 'C'
                    cQuery += " AND NOT (E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ')
                    cQuery += " AND NOT (E5_TIPODOC = 'PA ' AND E5_ORIGEM = 'FINA090' AND E5_NUMCHEQ <> ' ')
					cQuery += " GROUP BY ZM_CODIGO
					cQuery += " 	 , SUBSTRING(E5_DATA,1,6)
					cQuery += " 	 , E5_BANCO
					cQuery += " 	 , E5_AGENCIA
					cQuery += " 	 , E5_CONTA
					cQuery += " 	 , A6_NOME
					cQuery += " 	 , A6_NREDUZ
					cQuery += " 	 , CASE WHEN ISNULL(A6_NOME,'') LIKE '%APLICACAO%' THEN ISNULL(ED_DESCRIC,'') ELSE 'MOVIMENTO' END
					TcQuery cQuery New Alias (cTRB := GetNextAlias())

					nRegs := 0
					op_Self:IncRegua1("Leitura dos registros financeiro")
					dbSelectArea((cTRB))
					Count to nRegs
					op_Self:SetRegua2(nRegs)
					(cTRB)->(dbGoTop())
					If (cTRB)->(!eof())

						If file(cArquivo)
							FERASE(cArquivo)
						EndIf

                        nSaldo := 0
						cDtSaldo := Substr(dTos(monthSub(sToD(cPeriodo+'01'),1)),1,6)
						cQuery := ""
						cQuery += " SELECT ZM_CODIGO [Filial]
						cQuery += "      , SUBSTRING((E8_DTSALAT),1,6) as [Periodo]
						cQuery += "      , E8_BANCO AS [Banco]
						cQuery += " 	 , E8_AGENCIA AS [Agencia]
						cQuery += " 	 , E8_CONTA AS [Conta]
						cQuery += " 	 , ISNULL(A6_NOME,'') AS [Nome]
						cQuery += " 	 , ISNULL(A6_NREDUZ,'') AS [NReduz]
						cQuery += " 	 , 'SALDO INI'        AS [Operacao]
						cQuery += "      , 0 as [Receber]
						cQuery += "      , 0 as [Pagar]
						cQuery += "      , (E8_SALATUA) as [Saldo]
						cQuery += "   FROM SE8010 SE8 WITH(NOLOCK)
						cQuery += " INNER JOIN SZM010 ON SZM010.D_E_L_E_T_ = '' AND ZM_FILEMP = SUBSTRING(E8_FILIAL,1,2)
						cQuery += " LEFT JOIN SA6010 ON SA6010.D_E_L_E_T_ = '' AND A6_FILIAL = SUBSTRING(E8_FILIAL,1,2) AND A6_COD = E8_BANCO AND A6_AGENCIA = E8_AGENCIA AND A6_NUMCON = E8_CONTA
						cQuery += " WHERE SE8.D_E_L_E_T_ = ''
						cQuery += " AND E8_DTSALAT = (SELECT MAX(E8_DTSALAT) FROM SE8010 WHERE SE8010.D_E_L_E_T_ = '' AND E8_FILIAL = SE8.E8_FILIAL AND E8_BANCO = SE8.E8_BANCO AND E8_AGENCIA = SE8.E8_AGENCIA AND E8_CONTA = SE8.E8_CONTA AND E8_FILIAL = SE8.E8_FILIAL AND substring(E8_DTSALAT,1,6) <= '" + cDtSaldo + "')
						cQuery += " AND E8_BANCO = '" + (cTRB_BCO)->BANCO + "'
						cQuery += " AND E8_AGENCIA = '" + (cTRB_BCO)->AGENCIA + "'
						cQuery += " AND E8_CONTA = '" + (cTRB_BCO)->CONTA + "'
						cQuery += " AND SUBSTRING(E8_FILIAL,1,2) = '" + cXEmp + "'

						TcQuery cQuery New Alias (TRB_SI := GetNextAlias())

						dbSelectArea((TRB_SI))
						(TRB_SI)->(dbGoTop())
						If (TRB_SI)->(!eof())
							oFWMsExcel:AddRow(cSheet, cTitulo,{(TRB_SI)->Filial,;
								(cTRB)->Periodo,;
								(TRB_SI)->Banco,;
								(TRB_SI)->Agencia,;
								(TRB_SI)->Conta,;
								(TRB_SI)->Nome,;
								(TRB_SI)->Nreduz,;
								(TRB_SI)->Operacao,;
								(TRB_SI)->Receber,;
								(TRB_SI)->Pagar,;
								(TRB_SI)->Saldo})
							nSaldo := (TRB_SI)->Saldo
						EndIf
						(TRB_SI)->(dbCloseArea())

						while (cTRB)->(!eof())
							// If MovBcoBx((cTRB)->Motivo,.T.)

								nSaldo += (cTRB)->Saldo
								oFWMsExcel:AddRow(cSheet, cTitulo,{(cTRB)->Filial,;
									(cTRB)->Periodo,;
									(cTRB)->Banco,;
									(cTRB)->Agencia,;
									(cTRB)->Conta,;
									(cTRB)->Nome,;
									(cTRB)->Nreduz,;
									(cTRB)->Operacao,;
									(cTRB)->Receber,;
									(cTRB)->Pagar,;
									nSaldo})
							// EndIf

							(cTRB)->(dbSkip())
						EndDo
					EndIf


					(cTRB_BCO)->(dbSkip())
				EndDo
			EndIf
			(cTRB_BCO)->(dbCloseArea())



			(cTRB_EMP)->(dbSkip())
		EndDo

		op_Self:IncRegua1("Exportando registro Excel")
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)
		If ApOleClient("MSEXCEL")
			//Abrindo o excel e abrindo o arquivo xml
			oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
			oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
			oExcel:SetVisible(.T.)              //Visualiza a planilha
			oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
		EndIf

	EndIf
	(cTRB_EMP)->(dbCloseArea())




return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} Tab14
Carrega e retorna moedas da tabela 14
@type function
@version 12.1.27
@author Leandro Cesar
@since 08/08/2022
@return character, dados da tabea 14 cadastrado na SX5
/*/
Static Function Tab14() As Character
	Local cTabela14 As Character
	Local aRetSX5 	As Array
	Local nX		As Numeric

	cTabela14 := ""
	aRetSX5   := FWGetSX5( "14",,"pt-br")
	nX		  := 0

	For nX := 1 to Len(aRetSX5)
		cTabela14 += (Alltrim(aRetSX5[nX,3]) + "/")
	Next nX

	If cPaisLoc == "BRA"
		cTabela14 := SubStr(cTabela14, 1, Len(cTabela14) - 1)
	Else
		cTabela14 += "/$ "
	EndIf

Return cTabela14
