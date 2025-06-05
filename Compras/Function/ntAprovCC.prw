#include 'totvs.ch'


/*/{Protheus.doc} ntAprovCC
Envia notificacao de aprovacao do documento de condito de conduta para o setor fiscal
@type function
@version 12.1.33
@author Leandro Cesar
@since 21/10/2022
@param cp_ChaveNF, character, chave da nota fiscal
/*/
user function ntAprovCC(cp_ChaveNF)
	local cHTML := ""
	local aArea := GetArea()
// u_ntAprovCC("0929136100  00169601")

	dbSelectArea("SF1")
	dbSetOrder(1)
	If dbSeek(FWxFilial("SF1") + alltrim(cp_ChaveNF) )

		dbSelectArea("SA2")
		SA2->(dbSetOrder(1), dbSeek(FWxFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA))

		cHtml += '<!doctype html> ' + CRLF
		cHtml += '<html> ' + CRLF
		cHtml += '<head> ' + CRLF
		cHtml += '<meta charset="utf-8"> ' + CRLF
		cHtml += '<title>Aprovacao Codigo Conduta / Recebimento Fiscal</title> ' + CRLF
		cHtml += '	<style type="text/css"> ' + CRLF
		cHtml += '		.LinTit{ ' + CRLF
		cHtml += '		text-align: RIGHT; ' + CRLF
		cHtml += '			font-family: "Verdana"; ' + CRLF
		cHtml += '			font-size: 12px; ' + CRLF
		cHtml += '			color:black ' + CRLF
		cHtml += '		} ' + CRLF
		cHtml += '		.LinTexto{ ' + CRLF
		cHtml += '		text-align: LEFT; ' + CRLF
		cHtml += '			font-family: "Verdana"; ' + CRLF
		cHtml += '			font-size: 12px; ' + CRLF
		cHtml += '			background: #D9D2D2; ' + CRLF
		cHtml += '			color:black ' + CRLF
		cHtml += '		} ' + CRLF
		cHtml += '		p{ ' + CRLF
		cHtml += '			text-align: center; ' + CRLF
		cHtml += '			font-size: 20px; ' + CRLF
		cHtml += '			font-family: Segoe, "Segoe UI", "DejaVu Sans", "Trebuchet MS", Verdana, "sans-serif"; ' + CRLF
		cHtml += '			color:darkred; ' + CRLF
		cHtml += '		} ' + CRLF
		cHtml += '	</style> ' + CRLF
		cHtml += '	</head> ' + CRLF
		cHtml += '	<body> ' + CRLF
		cHtml += '		<p>Aprovacao Codigo de Conduta</p> ' + CRLF
		cHtml += '		<table width="50%" border="0" cellspacing="2" align="center"> ' + CRLF
		cHtml += '			  <tbody> ' + CRLF
		cHtml += '				<tr> ' + CRLF
		cHtml += '				  <th scope="row" width="40%" class="LinTit">FILIAL</th> ' + CRLF
		cHtml += '				  <td width="5%">&nbsp;</td> ' + CRLF
		cHtml += '				  <td class="LinTexto">' + FwXFilial("SF1") + '</td> ' + CRLF
		cHtml += '				</tr> ' + CRLF
		cHtml += '				<tr> ' + CRLF
		cHtml += '				  <th scope="row" class="LinTit">NOTA FISCAL&nbsp;</th> ' + CRLF
		cHtml += '				  <td>&nbsp;</td> ' + CRLF
		cHtml += '				  <td class="LinTexto">' + SF1->F1_DOC + ' / ' + SF1->F1_SERIE + '</td> ' + CRLF
		cHtml += '				</tr> ' + CRLF
		cHtml += '				<tr> ' + CRLF
		cHtml += '				  <th scope="row" class="LinTit">FORNECEDOR&nbsp;</th> ' + CRLF
		cHtml += '				  <td>&nbsp;</td> ' + CRLF
		cHtml += '				  <td class="LinTexto">' + SA2->A2_COD + " - " + SA2->A2_LOJA + " : " + SA2->A2_NOME + '</td> ' + CRLF
		cHtml += '				</tr> ' + CRLF
		cHtml += '				<tr> ' + CRLF
		cHtml += '				  <th scope="row" class="LinTit">EMISSÃO&nbsp;</th> ' + CRLF
		cHtml += '				  <td>&nbsp;</td> ' + CRLF
		cHtml += '				  <td class="LinTexto">' + cValToChar(SF1->F1_EMISSAO) + '</td> ' + CRLF
		cHtml += '				</tr> ' + CRLF
		cHtml += '				<tr> ' + CRLF
		cHtml += '				  <th scope="row" >&nbsp;</th> ' + CRLF
		cHtml += '				  <td>&nbsp;</td> ' + CRLF
		cHtml += '				  <td>&nbsp;</td> ' + CRLF
		cHtml += '				</tr> ' + CRLF
		cHtml += '				<tr> ' + CRLF
		cHtml += '				  <th scope="row" class="LinTit">APROVADOR&nbsp;</th> ' + CRLF
		cHtml += '				  <td>&nbsp;</td> ' + CRLF
		cHtml += '				  <td class="LinTexto">' + cValToChar(Date()) + " " + substr(Time(),1,5) + " - " + UsrRetName(__cUserId)  + ' : ' + alltrim(UsrFullName(__cUserId)) + '</td> ' + CRLF
		cHtml += '				</tr> ' + CRLF
		cHtml += '			  </tbody> ' + CRLF
		cHtml += '		</table> ' + CRLF
		cHtml += '	</body> ' + CRLF
		cHtml += '</html> ' + CRLF

		cCC := "" //"leandro@solucaocompacta.com.br"

		If FwCodFil() $ '0100'
			cEmail := "nf@eurofins.com"
		ElseIf FwCodFil() $ '0101'
			cEmail := "nfrecife@eurofins.com"
		ElseIf FWCodEmp() == '03'
			cEmail := "admagroscience@eurofins.com"
		ElseIf FWCodEmp() == '04'
			cEmail := "nfealac@eurofins.com"
         ElseIf FwCodFil() $ '0600'
			cEmail := "nfipex@eurofins.com"
         ElseIf FwCodFil() $ '0602'
			cEmail := "nfanatech@eurofins.com"
         ElseIf FwCodFil() $ '0603'
			cEmail := "nfsbc@eurofins.com"
         ElseIf FwCodFil() $ '0604'
			cEmail := "nfeasl@eurofins.com"
		ElseIf FWCodEmp() == '50'
			cEmail := "nfgrupopasteur@eurofins.com"
		ElseIf FWCodEmp() == '51'
			cEmail := "nfimagem@eurofins.com"
		ElseIf FWCodEmp() == '52'
			cEmail := "nfcatg@eurofins.com"
		else
			cEmail := ""
		EndIf

		U_SendMail(, cEmail, ;
			cCC,;
			'Aprovacao Nota Fiscal [' + alltrim(SF1->F1_DOC) + '] - Codigo de Conduta / Recebimento Fiscal',;
			cHtml,;
			'')


	EndIf

	RestArea(aArea)

return
