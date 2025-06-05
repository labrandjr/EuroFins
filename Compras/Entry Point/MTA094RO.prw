#Include 'Protheus.ch'

User Function MTA094RO()

	Private aRotina:= PARAMIXB[1]

	Aadd(aRotina,{'## Rejeitar Docto',"U_ERejDoc()", 0, 4,0,NIL})


Return (aRotina)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

User Function ERejDoc()
	Local oBCanc
	Local oBConf
	Local oGCompra
	Local cGCompra := ""
	Local oGDocto
	Local cGDocto := ""
	Local oGFornece
	Local cGFornece := ""
	Local oGroup1
	Local oMGMot
	Local cMGMot := ""
	Local oGPO
	Local cGPO := ""
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Static oDlgRej


	If SCR->CR_TIPO == 'NF'

		cQuery := ""
		cQuery += " SELECT C7_XCOMP AS COMPRADOR, C7_PUID AS PUID, C7_ZZCCOUP AS PO_COUPA FROM " + RetSqlName("SD1") +" SD1 WITH(NOLOCK) "
		cQuery += " INNER JOIN " + RetSqlName("SC7") + " SC7 WITH(NOLOCK)"
		cQuery += "        ON C7_FILIAL = '" + FWxFilial("SC7") + "'
		cQuery += "        AND C7_NUM  = D1_PEDIDO
		cQuery += "        AND C7_ITEM = D1_ITEMPC
		cQuery += " WHERE D1_FILIAL = '" + FWxFilial("SD1") + "'
		cQuery += " AND D1_DOC = '" + Substr(SCR->CR_NUM,1,9) + "'
		cQuery += " AND D1_SERIE = '" + Substr(SCR->CR_NUM,10,3) + "'
		cQuery += " AND D1_FORNECE + D1_LOJA = '" + Substr(SCR->CR_NUM,13,8) + "'
		cQuery += " GROUP BY C7_XCOMP, C7_PUID, C7_ZZCCOUP


		cGDocto := alltrim(Substr(SCR->CR_NUM,1,9) + ' - ' + Substr(SCR->CR_NUM,10,3) )
		SA2->(dbSetOrder(1), dbSeek(FWxFilial("SA2") + Substr(SCR->CR_NUM,13,8)))
		cGFornece := alltrim(SA2->A2_NOME) + " (" + alltrim(SA2->A2_CGC) + ")"



		DEFINE MSDIALOG oDlgRej TITLE "::.. Rejeição Documento ..::" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

		@ 016, 005 SAY oSay1 PROMPT "Documento" SIZE 036, 007 OF oDlgRej COLORS 0, 16777215 PIXEL
		@ 024, 005 MSGET oGDocto VAR cGDocto SIZE 060, 010 OF oDlgRej COLORS 0, 16777215 PIXEL
		@ 016, 080 SAY oSay2 PROMPT "Fornecedor" SIZE 036, 007 OF oDlgRej COLORS 0, 16777215 PIXEL
		@ 024, 080 MSGET oGFornece VAR cGFornece SIZE 165, 010 OF oDlgRej COLORS 0, 16777215 PIXEL
		@ 039, 005 SAY oSay3 PROMPT "Comprador" SIZE 033, 007 OF oDlgRej COLORS 0, 16777215 PIXEL
		@ 047, 005 MSGET oGCompra VAR cGCompra SIZE 122, 010 OF oDlgRej COLORS 0, 16777215 PIXEL
		@ 039, 142 SAY oSay4 PROMPT "PO Coupa" SIZE 025, 007 OF oDlgRej COLORS 0, 16777215 PIXEL
		@ 047, 142 MSGET oGPO VAR cGPO SIZE 060, 010 OF oDlgRej COLORS 0, 16777215 PIXEL
		@ 062, 002 GROUP oGroup1 TO 122, 247 PROMPT " Motivo Rejeicao " OF oDlgRej COLOR 0, 16777215 PIXEL
		@ 071, 005 GET oMGMot VAR cMGMot OF oDlgRej MULTILINE SIZE 240, 048 COLORS 0, 16777215 HSCROLL PIXEL
		@ 128, 113 BUTTON oBConf PROMPT "Confirmar" SIZE 063, 016 OF oDlgRej PIXEL
		@ 128, 184 BUTTON oBCanc PROMPT "Cancelar" SIZE 063, 016 OF oDlgRej PIXEL

		oGDocto:Disable()
		oGFornece:Disable()
		oGCompra:Disable()
		oGPO:Disable()

		oBConf:bAction := {|| iif(Rejeita(cMGMot), oDlgRej:End(),nil)}
		oBCanc:bAction := {|| oDlgRej:End()}
		ACTIVATE MSDIALOG oDlgRej CENTERED


	else

		FwAlertInfo("Documento inválido para rejeição.","Aviso")
	EndIf

Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------

static function Rejeita(cp_Motivo as character)
	local lRet     := .T.                        as logical
	local cChaveNF := alltrim(SCR->CR_NUM)       as character
	local cChaveAL := SCR->CR_TIPO + SCR->CR_NUM as character
	local aAreaSCR := SCR->(GetArea())           as array

	If FWAlertYesNo( 'Confirma Rejeição do Documento?', 'Confirmação' )

		Begin Transaction

			dbSelectArea("SF1")
			dbSetOrder(1)
			If dbSeek(FWxFilial("SF1") + cChaveNF)
				reclock("SF1" , .F.)
				SF1->F1_XSTA_CC := "R"
				SF1->F1_XLOG_CC := cValToChar(Date()) + " " + substr(Time(),1,5) + " - " + UsrRetName(__cUserId)
				SF1->(MsUnlock())

				dbSelectArea("SCR")
				dbSetOrder(1)
				If dbSeek(FWxFilial("SCR") + cChaveAL )
					while SCR->(!EOF()) .AND. SCR->CR_TIPO + SCR->CR_NUM == cChaveAL
						Reclock("SCR",.F.)
						SCR->CR_STATUS  := '06'
						SCR->CR_XMOTREJ := cp_Motivo
						SCR->(MsUnlock())
						SCR->(dbSkip())
					ENdDo

					cEmail := FWGetSX5(':2', PadR(FwCodFil(), TamSx3("X5_CHAVE")[1]))[1,4]

					cHtml  := HtmlRej(SF1->F1_DOC, cp_Motivo)

					If FWCodEmp() == '01'
						cCC := "nf@eurofins.com"
					ElseIf FWCodEmp() == '01'
						cCC := "nfrecife@eurofins.com"
					ElseIf FWCodEmp() == '03'
						cCC := "admagroscience@eurofins.com"
					ElseIf FWCodEmp() == '50'
						cCC := "nfgrupopasteur@eurofins.com"
					ElseIf FWCodEmp() == '51'
						cCC := "nfimagem@eurofins.com"
					ElseIf FWCodEmp() == '52'
						cCC := "nfcatg@eurofins.com"
					else
						cCC := ""
					EndIf

					cCC += "CamilaSilva@eurofins.com"

					U_SendMail(, cEmail, ;
						cCC,;
						'Notas Fiscais ' + alltrim(SF1->F1_DOC) + '- Rejeitado pelo Codigo de Conduta ',;
						cHtml,;
						'')
				Else
					DisarmTransaction()
				EndIf

			EndIf

		End Transaction


	else
		lRet := .F.
	EndIf
	RestArea(aAreaSCR)


return(lRet)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function HtmlRej(cP_NFiscal, cP_Motivo)
	local cHtml := "" as character
	local aAreaSF1 := SF1->(GetArea()) as array

	cHtml := ''
	cHtml += ' <!doctype html>  ' + CRLF
	cHtml += ' <html>  ' + CRLF
	cHtml += ' <head>  ' + CRLF
	cHtml += ' <meta charset="Windows 1252">  ' + CRLF
	cHtml += ' <title>Eurofins - Rejeicao Codigo de Conduta</title>  ' + CRLF
	cHtml += ' 	<style type="text/css">  ' + CRLF
	cHtml += ' 		.titulo{  ' + CRLF
	cHtml += ' 			text-align: center;  ' + CRLF
	cHtml += ' 			font-family: "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", "DejaVu Sans", Verdana, "sans-serif";  ' + CRLF
	cHtml += ' 			font-size: 20px;  ' + CRLF
	cHtml += ' 			color: #580607  ' + CRLF
	cHtml += ' 		}  ' + CRLF
	cHtml += ' 		.texto{  ' + CRLF
	cHtml += ' 			font-family: "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", "DejaVu Sans", Verdana, "sans-serif";  ' + CRLF
	cHtml += ' 			font-size: 16px;  ' + CRLF
	cHtml += ' 			color: #373251;  ' + CRLF
	cHtml += ' 			margin-left: 0.5cm;  ' + CRLF
	cHtml += ' 			margin-right: 0.5cm  ' + CRLF
	cHtml += ' 		}		  ' + CRLF
	cHtml += ' 		.titTab{  ' + CRLF
	cHtml += ' 			text-align: center;  ' + CRLF
	cHtml += ' 			font-size: 16px;  ' + CRLF
	cHtml += ' 			background: #560C0D;  ' + CRLF
	cHtml += ' 			color:white;  ' + CRLF
	cHtml += ' 		}	  ' + CRLF
	cHtml += ' 		.itemTab{  ' + CRLF
	cHtml += ' 			font-size: 14px;  ' + CRLF
	cHtml += ' 			background:#D8D8D8	  ' + CRLF
	cHtml += ' 		}	  ' + CRLF
	cHtml += ' 		table{   ' + CRLF
	cHtml += ' 			margin-top: 1.5cm;  ' + CRLF
	cHtml += ' 			margin-left: 1.5cm;  ' + CRLF
	cHtml += ' 			margin-right: 1.5cm;  ' + CRLF
	cHtml += ' 			font-family: "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", "DejaVu Sans", Verdana, "sans-serif"   ' + CRLF
	cHtml += ' 		}  ' + CRLF
	cHtml += ' 	</style>  ' + CRLF
	cHtml += ' </head>  ' + CRLF
	cHtml += ' <body>  ' + CRLF
	cHtml += ' <div>  ' + CRLF
	cHtml += ' 	<p class="titulo"><strong>Rejeicao Nota Fiscal - Codigo de Conduta</strong></p>  ' + CRLF
	cHtml += ' </div>  ' + CRLF
	cHtml += ' 	<br>  ' + CRLF
	cHtml += ' 	<hr>  ' + CRLF
	cHtml += ' <p class="texto"><strong>Prezado</strong></p>  ' + CRLF
	cHtml += ' 	<p class="texto">a NF ' + alltrim(cP_NFiscal) + ' foi rejeitada pelo Diretor da linha de Negocios, por favor, identificar o requisitante e solicitar o cancelamento da nota fiscal e nova emissão posterior ao pedido gerado.</p>  ' + CRLF
	cHtml += ' 	<table width="40%" border="0" cellspacing="2">  ' + CRLF
	cHtml += ' 	  <tbody>  ' + CRLF
	cHtml += ' 		<tr>  ' + CRLF
	cHtml += ' 		  <td class="titTab">Motivo Rejeicao</td>  ' + CRLF
	cHtml += ' 		</tr>  ' + CRLF
	cHtml += ' 		<tr>  ' + CRLF
	cHtml += ' 		  <td class="itemTab">' + cP_Motivo + '</td>  ' + CRLF
	cHtml += ' 		</tr>  ' + CRLF
	cHtml += ' 	  </tbody>  ' + CRLF
	cHtml += ' 	</table>  ' + CRLF
	cHtml += ' 	<table width="90%" border="0" cellspacing="2">  ' + CRLF
	cHtml += ' 	  <tbody>  ' + CRLF
	cHtml += ' 		<tr>  ' + CRLF
	cHtml += ' 		  <td class="titTab" width="10%">Nota Fiscal</td>  ' + CRLF
	cHtml += ' 		  <td class="titTab" width="10%">Emissão NF</td>  ' + CRLF
	cHtml += ' 		  <td class="titTab" width="10%">Emissão Pedido</td>  ' + CRLF
	cHtml += ' 		  <td class="titTab" width="10%">Pedido Protheus</td>	  ' + CRLF
	cHtml += ' 		  <td class="titTab" width="10%">Pedido Coupa</td>		  ' + CRLF
	cHtml += ' 		  <td class="titTab" width="10%">Produto</td>  ' + CRLF
	cHtml += ' 		  <td class="titTab" width="30%">Descricao</td>  ' + CRLF
	cHtml += ' 		  <td class="titTab" width="10%">Vlr. Total</td>  ' + CRLF
	cHtml += ' 		</tr>  ' + CRLF
	dbSelectArea("SD1")
	SD1->(dbSetOrder(1))
	dbSeek(FWxFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))
	while SD1->(!eof()) .and. SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA )
		dbSelectArea("SC7")
		dbSetOrder(1)
		dbSeek(FwXFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC)

		SB1->(dbSetOrder(1), dbSeek(FWxFilial("SB1") + SD1->D1_COD))

		cHtml += ' 		<tr>  ' + CRLF
		cHtml += ' 		  <td class="itemTab" align="center">' + SD1->D1_DOC + '</td>  ' + CRLF
		cHtml += ' 		  <td class="itemTab" align="center">' + cValToChar(SD1->D1_EMISSAO) + '</td>  ' + CRLF
		cHtml += ' 		  <td class="itemTab" align="center">' + cValToChar(SC7->C7_EMISSAO) + '</td>  ' + CRLF
		cHtml += ' 		  <td class="itemTab" align="center">' + SC7->C7_NUM + '</td>  ' + CRLF
		cHtml += ' 		  <td class="itemTab" align="center">' + SC7->C7_ZZCCOUP + '</td>  ' + CRLF
		cHtml += ' 		  <td class="itemTab" >' + alltrim(SD1->D1_COD) + '</td>  ' + CRLF
		cHtml += ' 		  <td class="itemTab" >' + alltrim(SB1->B1_DESC) + '</td>  ' + CRLF
		cHtml += ' 		  <td class="itemTab" align="right">' + Transform(SD1->D1_TOTAL, x3Picture("D1_TOTAL")) + '</td>  ' + CRLF
		cHtml += ' 		</tr>' + CRLF
		SD1->(dbSkip())
	EndDo
	cHtml += ' 	  </tbody>' + CRLF
	cHtml += ' 	</table>' + CRLF
	cHtml += ' </body>' + CRLF
	cHtml += ' </html> ' + CRLF

	restArea(aAreaSF1)

return(cHtml)
