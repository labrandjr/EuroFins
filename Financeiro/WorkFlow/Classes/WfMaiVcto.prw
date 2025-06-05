#include 'protheus.ch'

/*/{Protheus.doc} WfMaiVcto
Monta o e-mail para envio do workflow

@author Geeker
@since 06/06/2017
@version 1.0
/*/
class WfMaiVcto 
	data TP_NREDUZ
	data TP_NOME

	data TP_LIMITE
	data TP_DIAS

	data TP_PRIM
	data TP_SEG
	data TP_TERC

	data dDtRef
	data aTitulos	
	data cCorpo
	data cAssunto
	data cDestino
	data cAnexo
	data cTipoWf
	
	data cCodCli
	data cNomeCli
	data cCNPJ
	data cEnderec
	
	data dDtVencto
	data nDiasAtraso

	data nTx1De
	data nTx1Ate
	data nTx2De
	data nTx2Ate
	data nTx3De
	data nTx3Ate

	data oTxParamWf
	data cAnexos
	data cLocSrv
	data cLocBol
	data cTpNome

	data cTpVcto
	data cTpEnvioVct
		
	method new() constructor
	method getInfo() 	
	method wrkFlow()	
	method getAssunto()	
	method getCorpo()
	method envMail()
	method getTxt()
	method getAnexos()
	method getMaiorAtr()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author Geeker
@since 06/06/2017 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new() class WfMaiVcto
	::TP_NREDUZ		:= "N"
	::TP_NOME		:= "R"

	::TP_LIMITE		:= "L"
	::TP_DIAS		:= "D"

	::TP_PRIM		:= "P"
	::TP_SEG		:= "S"
	::TP_TERC		:= "T"

	::dDtRef		:= StoD("")
	::aTitulos 		:= {}	
	::cCorpo		:= ""
	::cAssunto		:= ""
	::cDestino		:= ""
	::cNomeCli		:= ""
	::cCNPJ			:= ""
	::cEnderec		:= ""
	::cAnexo		:= ""
	::cTipoWf		:= ""
	::dDtVencto		:= StoD("")
	::nDiasAtraso   := 0
	::cAnexos		:= ""
	::cTpNome		:= SuperGetMv("ZZ_TPNOMCL"	, .T., ::TP_NOME )

	::nTx1De		:= SuperGetMv("ZZ_TX1DE"	, .T., 1 	)
	::nTx1Ate		:= SuperGetMv("ZZ_TX1ATE"	, .T., 5 	)
	::nTx2De		:= SuperGetMv("ZZ_TX2DE"	, .T., 6	)
	::nTx2Ate		:= SuperGetMv("ZZ_TX2ATE"	, .T., 15	)
	::nTx3De		:= SuperGetMv("ZZ_TX3DE"	, .T., 16	)
	::nTx3Ate		:= SuperGetMv("ZZ_TX3ATE"	, .T., 99999)
	
	::oTxParamWf	:= TxParamWf():new()
	::cLocSrv		:= "\cobranca\danfe\"	
	::cLocBol		:= "\cobranca\boletos\"	

	::cTpVcto		:= GetMv("GK_TPVCML", .T., "D")
	::cTpEnvioVct	:= ""
return


/*/{Protheus.doc} new
Metodo construtor
@author fabio
@since 20/08/2016 
@version 1.0
/*/
method wrkFlow() class WfMaiVcto
	local cRet := ""
		
	if(Empty(cRet))
		cRet := ::getTxt()
	endIf
	
	if(Empty(cRet))
		cRet := ::getInfo()
	endIf
	 
	if(Empty(cRet))
		cRet := ::getAssunto()
	endIf
	
	if(Empty(cRet))	
		cRet := ::getCorpo()
	endIf
	
	if(Empty(cRet))
		cRet := ::getAnexos()
	endIf
	
	if(Empty(cRet))
		cRet := ::envMail()
	endIf	
return cRet

/*/{Protheus.doc} getAnexos
Busca os anexos
@author fabio
@since 20/08/2016 
@version 1.0
/*/	
method getAnexos() class WfMaiVcto
	local nI 	:= 1
	local cRet 	:= ""
	
	for nI := 1 to Len(::aTitulos)				
		if(::aTitulos[nI]:lTemNF)
			::cAnexos += ::cLocSrv + "NF"  + Alltrim(::aTitulos[nI]:cEmptTit) + Alltrim(::aTitulos[nI]:cFilTitulo) + Alltrim(::aTitulos[nI]:cNumTit) + Alltrim(::aTitulos[nI]:cPrefixo) + ".pdf" + ";"
		endIf

		if(::aTitulos[nI]:lTemBol)
			::cAnexos += ::cLocBol + "BOL" + Alltrim(::aTitulos[nI]:cEmptTit) + Alltrim(::aTitulos[nI]:cFilTitulo) + Alltrim(::aTitulos[nI]:cNumTit) + Alltrim(::aTitulos[nI]:cPrefixo) + ".pdf" + ";"
		endIf
	next
	
return cRet

/*/{Protheus.doc} envMail
Envia o e-mail de fato
@author fabio
@since 20/08/2016 
@version 1.0
/*/	
method getTxt() class WfMaiVcto
	::oTxParamWf:aTitulos	:= ::aTitulos
	::oTxParamWf:cEmpTit	:= cEmpAnt
	::oTxParamWf:getTxEmp_TxParamWf()
return

/*/{Protheus.doc} envMail
Envia o e-mail de fato
@author fabio
@since 20/08/2016 
@version 1.0
/*/	
method envMail() class WfMaiVcto
	local oEnviaMail	:= EnviaMail():new()	
	
	//::cDestino := "fabio@gkcmp.com.br"	
return oEnviaMail:enviaEmail(::cCorpo,::cAssunto,::cDestino, ::cAnexos) 

/*/{Protheus.doc} getInfo
Busca os dados dos vendedores

@author fabio
@since 20/08/2016 
@version 1.0
/*/
method getInfo() class WfMaiVcto
	local cRet 		:= ""
	local cDesTst 	:= SuperGetMv("ZZ_TSMAWF",.F., "")
	local cMailCpy  := SuperGetMv("ZZ_MAILREC",.F., "fabio@gkcmp.com.br;")
	local cDstCob	:= ""
	
	if(Empty(::aTitulos))
	 	cRet 		:= "Sem t�tulos"
	else
		cDstCob 		+= Alltrim(cMailCpy) 				+ iif(SubStr(Alltrim(cMailCpy)				, Len(Alltrim(cMailCpy))) == ";"				, "", ";")
		cDstCob 		+= Alltrim(::aTitulos[1]:cMailCob) 	+ iif(SubStr(Alltrim(::aTitulos[1]:cMailCob), Len(Alltrim(::aTitulos[1]:cMailCob))) == ";"	, "", ";")
		cDstCob 		+= Alltrim(::aTitulos[1]:cMailEsp) 	+ iif(SubStr(Alltrim(::aTitulos[1]:cMailEsp), Len(Alltrim(::aTitulos[1]:cMailEsp))) == ";"	, "", ";")

		::cDestino 		:= cDstCob
		
		conout("--------------- Geeker --------------")

		conout(" E-mail copia : " + cMailCpy)
		conout(" E-mail cobranca : " + ::aTitulos[1]:cMailCob)
		conout(" E-mail normal : " + ::aTitulos[1]:cMailEsp)

		conout("--------------- Geeker --------------")
		
		if(Alltrim(Upper(::cTpNome)) == ::TP_NOME)
			::cNomeCli	:= ::aTitulos[1]:cRazaoCli
		elseIf(Alltrim(Upper(::cTpNome)) == ::TP_NREDUZ)
			::cNomeCli	:= ::aTitulos[1]:cNomeCli			
		endIf

		::cCodCli		:= ::aTitulos[1]:cClientTit
		::cCNPJ			:= ::aTitulos[1]:cCNPJ
		::cEnderec		:= ::aTitulos[1]:cEnderec
		::dDtVencto	   	:= ::aTitulos[1]:dVencReal
		::nDiasAtraso  	:= ::getMaiorAtr()
	endIf
	
	if(!Empty(cDesTst))	
		::cDestino := cDesTst
	endIf
	
	//if(::nDiasAtraso < 3)
	//	cRet := "O envio de e-mail ocorrer� ap�s o terceiro dia do vencimento do t�tulo: "+::aTitulos[1]:cNumTit
	//endif
	
return cRet

/*/{Protheus.doc} getMaiorAtr
Metodo para buscar a data mais atrasada

@author fabio
@since 20/08/2016 
@version 1.0
/*/
method getMaiorAtr() class WfMaiVcto
	local nI 		:= 1
	local nMaiorAtr	:= 0
	local nAuxAtr	:= 0

	for nI := 1 to Len(::aTitulos)
		nAuxAtr := DateDiffDay(::aTitulos[nI]:dVencReal, dDataBase)

		if(nAuxAtr > nMaiorAtr)
			nMaiorAtr := nAuxAtr
		endIf
	next

return nMaiorAtr

/*/{Protheus.doc} getDestino
Get destino

@author fabio
@since 20/08/2016 
@version 1.0
/*/
method getAssunto() class WfMaiVcto
	local cRet 		:= ""

	if(::cTipoWf == "V")
		::cAssunto := "["+ ::oTxParamWf:cNomEmp  +"] - Aviso de T�tulos Vencidos "		
	elseif(::cTipoWf == "A")
		::cAssunto := "["+ ::oTxParamWf:cNomEmp  +"] - Aviso de T�tulos � vencer"
	endif 	
	
return  cRet

/*/{Protheus.doc} getCorpo
Busca o corpo

@author fabio
@since 20/08/2016 
@version 1.0
/*/
method getCorpo() class WfMaiVcto
	local nI 		:= 1
	local nTotSld 	:= 0
	local cRet		:= ""	
	local lAssuDeb	:= GetMv("GK_ASDB", .T., .F.)
	
	::cCorpo += '  <html xmlns="http://www.w3.org/1999/xhtml"> ' 
	::cCorpo += '  <head> '
	::cCorpo += '  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '         
	::cCorpo += '  <title>Lembrete de T�tulos a Vencer:</title> '
	::cCorpo += '  <style type="text/css"> '
	::cCorpo += ' .folha { ' 
	::cCorpo += '   page-break-after: always; ' 
	::cCorpo += ' } ' 
	::cCorpo += ' body { '
	::cCorpo += '   margin-left: 0px; '
	::cCorpo += '   margin-top: 0px; '
	::cCorpo += '   margin-right: 0px; '
	::cCorpo += '   margin-bottom: 0px; '
	::cCorpo += '   background-color: #fff; '
	::cCorpo += '   color: #58585a; '
	::cCorpo += '   font-family: Arial, Helvetica, sans-serif; '
	::cCorpo += '   -webkit-print-color-adjust: exact; '
	::cCorpo += ' } '
	::cCorpo += ' .tabela1 { '
	::cCorpo += '   border: 1px solid #818285; '
	::cCorpo += ' } '
	::cCorpo += ' .tabela1 th { '
	::cCorpo += '   color: #fff; '
	::cCorpo += '   padding: 1px 1px; '
	::cCorpo += '   border: 1px solid #888; '
	::cCorpo += '   font-size: 10px; '
	::cCorpo += '   background-color: #58585a; '
	::cCorpo += '   align : left; '
	::cCorpo += ' } '
	::cCorpo += ' .tabela1 td { '
	::cCorpo += '   padding: 3px 2px; '
	::cCorpo += '   border: 1px solid #818285; '
	::cCorpo += '   font-size: 10px; '
	::cCorpo += ' } '
	::cCorpo += ' .tabela2 { '
	::cCorpo += '   border: 1px solid #818285; '
	::cCorpo += ' } '
	::cCorpo += ' .tabela2 td{ '
	::cCorpo += '   font-size: 10px; '
	::cCorpo += ' } '
	::cCorpo += ' .bgcinza { '
	::cCorpo += '   color: #fff; '
	::cCorpo += '   padding: 2px 4px; '
	::cCorpo += '   border: 2px solid #888; '
	::cCorpo += '   background-color: #58585a; '
	::cCorpo += ' } '
	::cCorpo += ' #container { '
	::cCorpo += '   width: 990px; '
	::cCorpo += '   margin: 0 auto;	 '
	::cCorpo += ' } '
	::cCorpo += ' #valores { '
	::cCorpo += '   width: 880px; '
	::cCorpo += '   margin: 0 auto; '
	::cCorpo += ' } '
	::cCorpo += ' .bgazul { '
	::cCorpo += '   -webkit-print-color-adjust: exact; '
	::cCorpo += '   background-color: #3E4095; '
	::cCorpo += '   color: #fff; '
	::cCorpo += ' } '
	::cCorpo += ' .azul { '
	::cCorpo += '   color: #3E4095; '
	::cCorpo += '   font-size:12px; '
	::cCorpo += ' } '
	::cCorpo += ' .spanpad { '
	::cCorpo += '  font-size:12px; '
	::cCorpo += ' } '  
	::cCorpo += ' h2 { '
	::cCorpo += '  font-size: 10px; '
	::cCorpo += ' } '
	::cCorpo += ' #selo { '
	::cCorpo += '  margin: 0 30px 0 10px; '
	::cCorpo += '  float: left; '
	::cCorpo += ' } '  
	::cCorpo += ' #itens { '
	::cCorpo += '  font-size: 10px; '
	::cCorpo += ' } '  
	::cCorpo += ' .tabelaPr { '
	::cCorpo += '   border: 1px solid #000000; '	
	::cCorpo += ' } '  
	::cCorpo += ' .break { ' 
	::cCorpo += '   page-break-before: always; ' 
	::cCorpo += ' } '
	::cCorpo += ' </style> '
	::cCorpo += ' </head> '
	::cCorpo += ' <body link="white" vlink="white" alink="white"> '   
	::cCorpo += ' <FORM><br> '  
	::cCorpo += ' <div id="container"> '
	::cCorpo += ' <table cellspacing="5" width="100%"> '
	::cCorpo += ' <tr> '
	::cCorpo += ' <td> '					
	::cCorpo += ' <table class="bgazul" width="100%" class="bgazul" border="0" cellspacing="18" cellpadding="0" style="border-bottom: 7px solid #ccc;"> '												
	::cCorpo += ' <tr> '	
		
	::cCorpo += ' 	<td width="30%"><img src="'+ ::oTxParamWf:cImgLogo +'" width=108 height=60 style="display: block; border: 0px; outline: none; width: 70%; height: 30%; max-width: 600px;"/></td> '

	if(::cTipoWf == "A")
		::cCorpo += ' 	<td width="35%" align="center"><font face="Arial, Helvetica, sans-serif" size="5" color="white"><strong>Importante - Títulos a Vencer</strong></font></td> '
	elseif(::cTipoWf == "V")
		if(::nDiasAtraso >= ::nTx1De .and. ::nTx1Ate <= 10)
			::cCorpo += ' 	<td width="35%" align="center"><font face="Arial, Helvetica, sans-serif" size="5" color="white"><strong>Títulos Vencidos</strong></font></td> '
		elseif(::nDiasAtraso >= ::nTx2De .and. ::nTx2Ate <= 10)
			::cCorpo += ' 	<td width="35%" align="center"><font face="Arial, Helvetica, sans-serif" size="5" color="white"><strong>Títulos Vencidos</strong></font></td> '
		elseif(::nDiasAtraso >= ::nTx3De .and. ::nTx3Ate <= 10)
			::cCorpo += ' 	<td width="35%" align="center"><font face="Arial, Helvetica, sans-serif" size="5" color="white"><strong>Títulos Vencidos</strong></font></td> '
		endif
	endif

	::cCorpo += ' 	<td width="35%" align="right"> '																	
	::cCorpo += ' 	  <table cellspacing="1" cellpadding="0"> '
	::cCorpo += ' 		  <tr> '
	::cCorpo += ' 			  <td valign="top"> '
	::cCorpo += ' 				  <font style="color:white; font-size: 14px;"> '
	::cCorpo += ' 					  <strong>'+ ::oTxParamWf:cTelEmp  +'<br /> '
	::cCorpo += ' 				  </font> '
	::cCorpo += ' 				  <font style="color:white; font-size: 12px;"> '
	::cCorpo += ' 					  '+ ::oTxParamWf:cCNPJEmp +'<br /> '
	::cCorpo += ' 					  '+ ::oTxParamWf:cEnderEmp +'<br /> '
	::cCorpo += ' 					  '+ ::oTxParamWf:cCidadeEmp +'</strong><br> '
	::cCorpo += ' 					  <a href="http://'+ ::oTxParamWf:cSiteEmp +'/" style="color:white">'+ ::oTxParamWf:cSiteEmp +'</a><br /> '
	::cCorpo += ' 				  </font> '
	::cCorpo += ' 			  </td> '
	::cCorpo += ' 		  </tr> '
	::cCorpo += ' 	  </table> '
	::cCorpo += ' 	</td> '
	::cCorpo += ' </tr> '
	::cCorpo += ' </table> '
	::cCorpo += ' </td> '
	::cCorpo += ' </tr> '
	::cCorpo += ' <tr> '
	::cCorpo += ' <td> '
	::cCorpo += '   <h2><span class="azul">Data Refêrencia: </span><span class="spanpad">'+ DtoC(::dDtRef) +'<span></h2> '
		
	if(::cTipoWf == "A")
		::cCorpo += '<span class="spanpad" link="blue" vlink="blue" alink="blue">' + ::oTxParamWf:cTxAVencer
	elseif(::cTipoWf == "V")
		if(::nDiasAtraso >= ::nTx1De .and. ::nDiasAtraso <= ::nTx1Ate)
			::cCorpo 	+= '<span class="spanpad" link="blue" vlink="blue" alink="blue">'+ ::oTxParamWf:cTx1Vencidos
			::cAssunto 	+= iif(lAssuDeb, " - Texto 1", "")

		elseif(::nDiasAtraso >= ::nTx2De .and. ::nDiasAtraso <= ::nTx2Ate)
			::cCorpo 	+= '<span class="spanpad" link="blue" vlink="blue" alink="blue">'+ ::oTxParamWf:cTx2Vencidos
			::cAssunto 	+= iif(lAssuDeb, " - Texto 2", "")

		elseif(::nDiasAtraso >= ::nTx3De .and. ::nDiasAtraso <= ::nTx3Ate)
			::cCorpo 	+= '<span class="spanpad" link="blue" vlink="blue" alink="blue">'+ ::oTxParamWf:cTx3Vencidos
			::cAssunto 	+= iif(lAssuDeb, " - Texto 3", "")

		endif
	endif

	if(!Empty(::oTxParamWf:c1TxtCustom))
		::cCorpo += ::oTxParamWf:c1TxtCustom
	endIf

	::cCorpo += ' <br><br> <table width="100%" border="1" cellpadding="5" cellspacing="0" class="tabela1"> '
	::cCorpo += ' 	  <tr> '
	::cCorpo += ' 		<td width="15%" class="bgcinza"><strong>Cliente:</strong></td> '
	::cCorpo += ' 		<td width="85%">'+ Alltrim(::cNomeCli) +'</td> '
	::cCorpo += ' 	  </tr> '
	::cCorpo += ' 	  <tr> '
	::cCorpo += ' 		<td class="bgcinza"><strong>CNPJ:</strong></td> '
	::cCorpo += ' 		<td>'+ Alltrim(Transform(::cCNPJ, "@r 99.999.999/9999-99")) +'</td> '
	::cCorpo += ' 	  </tr> '
	::cCorpo += ' 	  <tr> '
	::cCorpo += ' 		<td class="bgcinza"><strong>Endereço:</strong></td> '
	::cCorpo += ' 		<td>'+ Alltrim(::cEnderec) +'</td> '
	::cCorpo += ' 	  </tr> '                          
	::cCorpo += '   </table> '
	::cCorpo += ' </td> '
	::cCorpo += ' </tr> '
	::cCorpo += ' <tr> '
	::cCorpo += ' <td> '
	::cCorpo += '   <h2><span class="azul">Títulos:</span></h2> '
	::cCorpo += ' </td> '
	::cCorpo += ' </tr> '
	::cCorpo += ' <tr> '
	::cCorpo += ' <td> '
	::cCorpo += '   <table width="100%" border="1" align="left" cellpadding="5" cellspacing="0" class="tabela1"> '
	::cCorpo += ' 	<tr> '					 	
	::cCorpo += ' 	  <th>Nota</th> '
	::cCorpo += ' 	  <th>Série</th> '
	::cCorpo += ' 	  <th>Parcela</th> '
	::cCorpo += ' 	  <th>Emissão</th> '
	::cCorpo += ' 	  <th>Vencimento</th> '
	::cCorpo += ' 	  <th>Total</th> '                          
	::cCorpo += ' 	</tr> '
					  
	for nI := 1 to Len(::aTitulos)
		::cCorpo += ' 	<tr> '					 	
		::cCorpo += ' 	  <td>'+ ::aTitulos[nI]:cNumTit 											+'</td> '
		::cCorpo += ' 	  <td>'+ ::aTitulos[nI]:cPrefixo 											+'</td> '
		::cCorpo += ' 	  <td>'+ ::aTitulos[nI]:cParcela 											+'</td> '
		::cCorpo += ' 	  <td>'+ DtoC(::aTitulos[nI]:dEmissao) 										+'</td> '
		::cCorpo += ' 	  <td>'+ DtoC(::aTitulos[nI]:dVencReal) 									+'</td> '
		::cCorpo += ' 	  <td>'+ Transform(::aTitulos[nI]:nSaldo, PesqPict( "SE1", "E1_SALDO" ) ) 	+'</td> '                          
		::cCorpo += ' 	</tr> '
		
		nTotSld += ::aTitulos[nI]:nSaldo
	next	
	::cCorpo += ' </table> '				
	::cCorpo += ' </td> '
	::cCorpo += ' </tr> '
	::cCorpo += ' <tr> '
	::cCorpo += '   <td> '
	::cCorpo += ' 	  <table width="10%" border="1" align="left" cellpadding="2" cellspacing="0" class="tabela2"> '
	::cCorpo += ' 		  <tr> '           
	::cCorpo += ' 			  <td height="20" > '
	::cCorpo += ' 				  <table width="100%"> '
	::cCorpo += ' 					  <tr> '
	::cCorpo += ' 						  <td width="10%" height="10"><strong>Total:</strong></td> '
	::cCorpo += ' 						  <td width="10%">'+ Transform(nTotSld, PesqPict( "SE1", "E1_SALDO" )) +'</td> '
	::cCorpo += ' 					  </tr> '	
	::cCorpo += ' 				  </table> '
	::cCorpo += ' 			  </td> '
	::cCorpo += ' 		  </tr> '
	::cCorpo += ' 	  </table> '
	::cCorpo += '   </td> '
	::cCorpo += ' </tr> '              	           
	::cCorpo += ' </form> '
	::cCorpo += ' </div> '
	::cCorpo += ' </body> '
	::cCorpo += ' </html> ' 
return cRet
