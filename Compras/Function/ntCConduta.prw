#include "totvs.ch"
#include "topconn.ch"
#include 'tbiconn.ch'

/*/{Protheus.doc} ntCConduta
Rotina de notificação notas fiscais com bloqueio codigo de conduta
@type function
@version 12.1.27
@author Leandro Cesar
@since 22/08/2022
/*/


static lEurofins := !("YMLLLM" $ GetEnvServer())

user function ntCConduta()
	local cEmpX := "01"
	local cFilX := iif(lEurofins, "0100", "5000")
	local cQuery := ""

	ConOut("Inicio da rotina de schedule NTCConduta")
	ConOut("Inicio: "+cValToChar(Date())+" - "+cValToChar(Time()))
	Prepare Environment Empresa cEmpX Filial cFilX

	cQuery := ""
	cQuery += " SELECT F1_FILIAL AS FILIAL
	cQuery += "   FROM " + RetSqlName("SF1") + " SF1
	cQuery += "  WHERE SF1.D_E_L_E_T_ = ''
	cQuery += "    AND F1_STATUS = 'B'
	If SF1->(FieldPos("F1_XTPBLOQ")) > 0
		cQuery += "    AND F1_XTPBLOQ in ('A','C','')
	EndIf
	cQuery += "  GROUP BY F1_FILIAL
	TcQuery cQuery New Alias (cTRX := GetNextAlias())

	dbSelectArea((cTRX))
	(cTRX)->(dbGoTop())
	while (cTRX)->(!eof())


		cQuery := ""
		cQuery += " SELECT F1_FILIAL + ' - ' + ZM_DESCRIC AS EMPRESA
		cQuery += " 	 , F1_DOC AS NFISCAL
		cQuery += " 	 , F1_EMISSAO AS EMIS_NF
		cQuery += " 	 , C7_NUM AS PEDIDO
		cQuery += " 	 , C7_ZZCCOUP AS COUPA
		cQuery += " 	 , C7_EMISSAO AS EMIS_PC
		cQuery += " 	 , A2_NOME AS FORNECEDOR
		cQuery += " 	 , C7_XSOLICI AS SOLICIT
		cQuery += "      , (SELECT TOP 1 ltrim(rtrim(X5_DESCRI)) from SX5010 SX5 where SX5.D_E_L_E_T_ = '' AND X5_TABELA = ':1' AND X5_CHAVE = F1_FILIAL) AS EMAIL
	    cQuery += "      , (SELECT USR_EMAIL FROM SYS_USR USR WHERE USR.D_E_L_E_T_ = '' AND USR_ID  = CR_USER) AS EMAIL_APV
		cQuery += "      , (SELECT TOP 1 ltrim(rtrim(X5_DESCRI)) from SX5010 SX5 where SX5.D_E_L_E_T_ = '' AND X5_TABELA = ':2' AND X5_CHAVE = F1_FILIAL) AS EMAIL_B
		cQuery += " 	 , SUM(D1_TOTAL) AS VLR_NF
		cQuery += "   FROM " + RetSqlName("SF1") + " SF1
		cQuery += "  INNER JOIN " + RetSqlName("SZM") + " SZM ON ZM_FILEMP = SUBSTRING(F1_FILIAL,1,2)
		cQuery += "  INNER JOIN " + RetSqlName("SA2") + " SA2 ON A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA
		cQuery += "  INNER JOIN " + RetSqlName("SD1") + " SD1 ON D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA
		cQuery += "  INNER JOIN " + RetSqlName("SC7") + " SC7 ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC
		cQuery += "  INNER JOIN " + RetSqlName("SCR") + " SCR ON CR_FILIAL = F1_FILIAL AND CR_NUM = F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
		cQuery += "  WHERE SF1.D_E_L_E_T_ = ''
		cQuery += "    AND SZM.D_E_L_E_T_ = ''
		cQuery += "    AND SA2.D_E_L_E_T_ = ''
		cQuery += "    AND SD1.D_E_L_E_T_ = ''
		cQuery += "    AND SC7.D_E_L_E_T_ = ''
		cQuery += "    AND SCR.D_E_L_E_T_ = ''
		cQuery += "    AND F1_STATUS = 'B'
		If SF1->(FieldPos("F1_XTPBLOQ")) > 0
			cQuery += " AND F1_XTPBLOQ in ('A','C','')
		EndIf
		cQuery += "    AND CR_TIPO = 'NF'
		cQuery += "    AND CR_NIVEL = '01'
		cQuery += "    AND CR_STATUS = '02'
		cQuery += "    AND C7_EMISSAO > F1_EMISSAO
		cQuery += "    AND F1_FILIAL = '" + (cTRX)->FILIAL + "' "
		cQuery += "  GROUP BY ZM_DESCRIC
		cQuery += "      , F1_FILIAL
		cQuery += " 	 , F1_DOC
		cQuery += " 	 , F1_EMISSAO
		cQuery += " 	 , C7_NUM
		cQuery += " 	 , C7_ZZCCOUP
		cQuery += " 	 , C7_EMISSAO
		cQuery += " 	 , A2_NOME
		cQuery += " 	 , C7_XSOLICI
		cQuery += " 	 , CR_USER
		TcQuery cQuery New Alias (cTRB := GetNextAlias())

		dbSelectArea((cTRB))
		(cTRB)->(dbGoTop())


		If  (cTRB)->(!eof())
			// cEmail := FWGetSX5(':1', PadR((cTRX)->FILIAL, TamSx3("X5_CHAVE")[1]))[1,4]
			// cEmailCP := FWGetSX5(':2', PadR((cTRX)->FILIAL, TamSx3("X5_CHAVE")[1]))[1,4]

			cEmail   := (cTRB)->EMAIL
			cEmlBuma := (cTRB)->EMAIL_B

			cHtml := '<!doctype html> ' + CRLF
			cHtml += ' <html> ' + CRLF
			cHtml += ' <head> ' + CRLF
			cHtml += ' <meta charset="utf-8"> ' + CRLF
			cHtml += ' <title>Eurofins - Bloqueio Código de Conduta</title> ' + CRLF
			cHtml += ' 	<style type="text/css"> ' + CRLF
			cHtml += ' 		.titulo{ ' + CRLF
			cHtml += ' 			text-align: center; ' + CRLF
			cHtml += ' 			font-family: "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", "DejaVu Sans", Verdana, "sans-serif"; ' + CRLF
			cHtml += ' 			font-size: 20px; ' + CRLF
			cHtml += ' 			color: #580607 ' + CRLF
			cHtml += ' 		} ' + CRLF
			cHtml += ' 		.titTab{ ' + CRLF
			cHtml += ' 			text-align: center; ' + CRLF
			cHtml += ' 			font-size: 16px; ' + CRLF
			cHtml += ' 			background: #484557; ' + CRLF
			cHtml += ' 			color:white; ' + CRLF
			cHtml += ' 		}	 ' + CRLF
			cHtml += ' 		.itemTab{ ' + CRLF
			cHtml += ' 			font-size: 14px; ' + CRLF
			cHtml += ' 			background:#D8D8D8 ' + CRLF
			cHtml += ' 		} ' + CRLF
			cHtml += ' 		table{ ' + CRLF
			cHtml += ' 			margin-top: 1.5cm; ' + CRLF
			cHtml += ' 			margin-left: 1.5cm; ' + CRLF
			cHtml += ' 			margin-right: 1.5cm; ' + CRLF
			cHtml += ' 			font-family: "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", "DejaVu Sans", Verdana, "sans-serif" ' + CRLF
			cHtml += ' 		} ' + CRLF
			cHtml += ' 	</style> ' + CRLF
			cHtml += ' </head> ' + CRLF
			cHtml += ' <body> ' + CRLF

			cHtml += ' <div> ' + CRLF
			cHtml += ' 	<p class="titulo"><strong>Relacao de Notas Fiscais Pendentes Liberacao</strong></p> ' + CRLF
			cHtml += ' 	<p class="titulo"><strong>(Codigo de Conduta)</strong></p> ' + CRLF
			cHtml += ' </div> ' + CRLF
			cHtml += ' <table width="90%" border="0" cellspacing="2"> ' + CRLF
			cHtml += '   <tbody> ' + CRLF
			cHtml += '     <tr> ' + CRLF
			cHtml += '       <td class="titTab" width="10%">Filial / Empresa</td> ' + CRLF
			cHtml += ' 	     <td class="titTab" width="10%">Solicitante</td> ' + CRLF
			cHtml += ' 	     <td class="titTab" width="10%">Nota Fiscal</td> ' + CRLF
			cHtml += '       <td class="titTab" width="10%">Emissao NF</td> ' + CRLF
			cHtml += '       <td class="titTab" width="10%">Pedido de Compra</td> ' + CRLF
			cHtml += '       <td class="titTab" width="10%">Pedido Coupa</td> ' + CRLF
			cHtml += '       <td class="titTab" width="10%">Emissao PC</td> ' + CRLF
			cHtml += '       <td class="titTab" width="20%">Fornecedor</td> ' + CRLF
			cHtml += '       <td class="titTab" width="10%">Valor Total NF</td> ' + CRLF
			cHtml += '     </tr> ' + CRLF


			while (cTRB)->(!eof())
				cSolicit := ""
				If alltrim((cTRB)->SOLICIT) != ''
					cSolicit := alltrim((cTRB)->SOLICIT)
				Else
					cSolicit := cEmlBuma
				EndIf

				cHtml += '     <tr> ' + CRLF
				cHtml += ' 	     <td class="itemTab">' + alltrim((cTRB)->EMPRESA) + '</td> ' + CRLF
				cHtml += ' 	     <td class="itemTab">' + lower(alltrim(cSolicit)) + '</td> ' + CRLF
				cHtml += '       <td class="itemTab" align="center">' + alltrim((cTRB)->NFISCAL)  + '</td> ' + CRLF
				cHtml += '       <td class="itemTab" align="center">' + cValToChar(sToD((cTRB)->EMIS_NF)) + '</td> ' + CRLF
				cHtml += '       <td class="itemTab" align="center">' + (cTRB)->PEDIDO + '</td> ' + CRLF
				cHtml += '       <td class="itemTab" align="center">' + (cTRB)->COUPA + '</td> ' + CRLF
				cHtml += '       <td class="itemTab" align="center">' + cValToChar(sToD((cTRB)->EMIS_PC)) + '</td> ' + CRLF
				cHtml += '       <td class="itemTab">' + alltrim((cTRB)->FORNECEDOR) + '</td> ' + CRLF
				cHtml += '       <td class="itemTab" align="right">' + Transform((cTRB)->VLR_NF, x3Picture("D1_TOTAL")) + '</td> ' + CRLF
				cHtml += '     </tr> ' + CRLF

				(cTRB)->(dbSkip())
			EndDo

			cHtml += '   </tbody> ' + CRLF
			cHtml += ' </table> ' + CRLF

			cHtml += ' </body> ' + CRLF
			cHtml += ' </html> ' + CRLF


			//cCC := "CamilaSilva@eurofins.com"
			cCC := ""

			U_SendMail(, cEmail, ;
				cCC,;
				'Notas Fiscais Bloqueio Codigo de Conduta ',;
				cHtml,;
				'')


		EndIf
		(cTRB)->(dbCloseArea())
		(cTRX)->(dbSkip())
	EndDo
	(cTRX)->(dbCloseArea())


	Reset Environment
	ConOut("Termino da rotina de schedule NTCConduta.")
	ConOut("Fim: "+cValToChar(Date())+" - "+cValToChar(Time()))

return
