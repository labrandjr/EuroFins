#include 'protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} WfDaVcto
Classe entidade para 

@author Geeker
@since 06/06/2017
@version 1.0
/*/
class WfDaVcto 
	data TP_LIMITE
	data TP_DIAS

	data TP_PRIM
	data TP_SEG
	data TP_TERC

	data dDtRef
	data cTipoWf
	data aDados
	
	data lGeraDanfe
	data cLocSrv
	data cLocBol

	data lTemBol
	data lTemNF
	data lGeraNf

	data nTx1De
	data nTx1Ate
	data nTx2De
	data nTx2Ate
	data nTx3De
	data nTx3Ate

	data cTpVcto
	data cTpEnvioVct

	method new() constructor 
	method qryTitFin()
	method getTitFin()
	method updLog()
	method geraDanfe()
	method geraBol()
	method geraCustom()
	method vldGeraBol()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method new() class WfDaVcto
	::TP_LIMITE		:= "L"
	::TP_DIAS		:= "D"

	::TP_PRIM		:= "P"
	::TP_SEG		:= "S"
	::TP_TERC		:= "T"

	::dDtRef		:= StoD("")
	::cTipoWf		:= ""	
	::aDados		:= {}
	
	::lGeraDanfe	:= GetMv("GK_GERDANF", .T., .F.)
	::cLocSrv		:= "\cobranca\danfe\"
	::cLocBol		:= "\cobranca\boletos\"	

	::lTemBol		:= .F.
	::lTemNF		:= .F.
	::lGeraNf		:= GetMv("ZZ_GRNFCOB", .T., .F.)

	::nTx1De		:= SuperGetMv("ZZ_TX1DE"	, .T., 1 	)
	::nTx1Ate		:= SuperGetMv("ZZ_TX1ATE"	, .T., 5 	)
	::nTx2De		:= SuperGetMv("ZZ_TX2DE"	, .T., 6	)
	::nTx2Ate		:= SuperGetMv("ZZ_TX2ATE"	, .T., 15	)
	::nTx3De		:= SuperGetMv("ZZ_TX3DE"	, .T., 16	)
	::nTx3Ate		:= SuperGetMv("ZZ_TX3ATE"	, .T., 99999)

	::cTpVcto		:= GetMv("GK_TPVCML", .T., "D")
	::cTpEnvioVct	:= ""
	
return

/*/{Protheus.doc} getTitFin
Busca os títulos vencidos
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method getTitFin() class WfDaVcto
	local cAliasQry := ::qryTitFin()
	local oTitRec	:= nil
	local cCliTit	:= ""
	local aDadoFin	:= {}
	
	private aEtiq  	:= {} // MAXGEAR
	private aPedido	:= {} // MAXGEAR

	while(!(cAliasQry)->(Eof()))
		oTitRec	:= TitRecClass():new_TitRecClass()
		oTitRec:setTdByAlias_TitRecClass(cAliasQry)

		oTitRec:lTemNF	:= iif(!::lGeraDanfe, .F., ::geraDanfe(oTitRec))
		oTitRec:lTemBol := ::geraBol(oTitRec)
		oTitRec:lAnxCus	:= ::geraCustom(oTitRec)

		if(Alltrim((cAliasQry)->E1_CLIENTE) + Alltrim((cAliasQry)->E1_LOJA) != cCliTit .AND. !Empty(cCliTit))
			AAdd(::aDados, aDadoFin)
			aDadoFin := {}
		endIf

		AAdd(aDadoFin, oTitRec)
		cCliTit := Alltrim((cAliasQry)->E1_CLIENTE) + Alltrim((cAliasQry)->E1_LOJA)
				
		(cAliasQry)->(DbSkip())
	endDo

	if(!Empty(aDadoFin))
		AAdd(::aDados, aDadoFin)
	endIf

	if(Select(cAliasQry) > 0)
		(cAliasQry)->(DbCloseArea())
	endIf
return

/*/{Protheus.doc} geraCustom
Metodo para gerar 
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method geraCustom(oTitRec) class WfDaVcto
	/*
	cDiret   := "\IMAGEMBD\"

	Alltrim(SM0->M0_CODFIL)+Alltrim(SF2->F2_DOC)+Alltrim(SF2->F2_SERIE)+"_DESCRITIVO"
	*/
return

/*/{Protheus.doc} geraBol
Metodo gera o boleto
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method geraBol(oTitRec) class WfDaVcto
	local cNomeArq	:= "BOL" + cEmpAnt + cFilAnt + Alltrim(oTitRec:cNumTit) + Alltrim(oTitRec:cPrefixo) + ".pdf"
	local cEmpSv	:= cEmpAnt
	local cFilSv	:= cFilAnt

	if(::vldGeraBol(oTitRec))
		if(!File(::cLocBol + "BOL" + cEmpAnt + cFilAnt + Alltrim(oTitRec:cNumTit) + Alltrim(oTitRec:cPrefixo) + ".pdf"))
			cEmpAnt	:= oTitRec:cEmptTit
			cFilAnt	:= oTitRec:cFilTitulo

			u_BLTITAU(	cNomeArq,; 
						oTitRec:cNumTit,; 
						oTitRec:cPrefixo,; 
						oTitRec:cClientTit,; 
						oTitRec:cLojaTit,;
						oTitRec:cTipo,;
						.T., "", "", .F.)

			::lTemBol	:= .T.

			cEmpAnt		:= cEmpSv
			cFilAnt		:= cFilSv
		else
			::lTemBol 	:= .T.
		endIf
	else
		::lTemBol 	:= .F.
	endIf
	
return ::lTemBol

/*/{Protheus.doc} geraDanfe
Metodo para gerar o DANFE
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method vldGeraBol(oTitRec) class WfDaVcto
	local lRet 		:= .T.
	local cSituBol 	:= GetMv("GK_SITNO"	, .T., "0|")
	local lGerBol	:= GetMv("GK_GERBOL", .T., .F.)

	if(lGerBol)
		if(Alltrim(Upper(oTitRec:cSituac)) $ cSituBol)
			lRet := .F.
		endIf
	else
		lRet := .F.
	endIf

return lRet
 
/*/{Protheus.doc} geraDanfe
Metodo para gerar o DANFE
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method geraDanfe(oTitRec) class WfDaVcto
	local cNomeArq	:= "NF" + cEmpAnt + cFilAnt + Alltrim(oTitRec:cNumTit) + Alltrim(oTitRec:cPrefixo) 
	local cTempXML	:= GetMv("GK_DIRLOC", .T., "C:\geeker\")
	local cEmpSv	:= cEmpAnt
	local cFilSv	:= cFilAnt
	
	if(!ExistDir(cTempXML))
		MakeDir(cTempXML)
	endIf

	cEmpAnt	:= oTitRec:cEmptTit
	cFilAnt	:= oTitRec:cFilTitulo

	if(::lGeraNf .AND. !File(::cLocSrv + "NF" + cEmpAnt + cFilAnt + Alltrim(oTitRec:cNumTit) + Alltrim(oTitRec:cPrefixo) + ".pdf"))
		::lTemNF := u_zGerDanfe(oTitRec:cNumTit, oTitRec:cPrefixo, nil, cNomeArq)		
	else
		::lTemNF := .T.
	endIf

	cEmpAnt	:= cEmpSv
	cFilAnt	:= cFilSv
	
	if(File(cTempXML + cNomeArq + ".pdf") .AND. CpyT2S(cTempXML + cNomeArq + ".pdf", ::cLocSrv))
		conout("teste 01")
	else
		conout("teste 02")
	endIf
return ::lTemNF

/*/{Protheus.doc} qryTitFin
Query dos títulos vencidos
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method qryTitFin() class WfDaVcto
	local cQuery 		:= ""
	local cAliasQry		:= GetNextAlias()
	local nDiasAtraso	:= GetMv("ZZ_NDIATR", .T., 3)
	local nDiasAVcto	:= GetMv("ZZ_AVWFTI", .T., 7)
	local cDesTst 		:= GetMv("ZZ_TSMAWF", .F., "")
	local lAbrAviso		:= GetMv("GK_MSTIVC", .T., .F.)
	local cQtdTst		:= GetMv("GK_QTDTST", .T., "3")
	local cPrfNIn		:= GetMv("GK_PRNTIN", .T., "'ND', '1', 'S', 'B'")
	local cPorNIn		:= GetMv("GK_PORNIN", .T., "")
	local cTpNIn 		:= GetMv("ZZ_TPWFVC", .T., "'NF'")
	local cSiTNIn		:= GetMv("ZZ_STWFVC", .T., "'C', 'R', 'D', '5', 'H', '7', 'P', 'G' ")
	
	if(Empty(cDesTst))	
		cQuery += " SELECT  *															" + CRLF
	else
		cQuery += " SELECT TOP "+ cQtdTst +" *											" + CRLF
	endIf
	
	if(GetMv("ZZ_NLQRY", .T., .F.))
		cQuery += " FROM "+ RetSqlName("SE1") +" (NOLOCK) SE1                    		" + CRLF
		cQuery += " INNER JOIN "+ RetSqlName("SA1") +" (NOLOCK) SA1 ON           		" + CRLF
	else
		cQuery += " FROM "+ RetSqlName("SE1") +" SE1                    				" + CRLF
		cQuery += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON           				" + CRLF		
	endIf
	cQuery += " 		SA1.A1_FILIAL 	LIKE '"+ SubStr(xFilial("SA1"), 1, 2) +"%'    	" + CRLF
	cQuery += " 	AND SA1.A1_COD 		= SE1.E1_CLIENTE           	 					" + CRLF
	cQuery += " 	AND SA1.A1_LOJA 	= SE1.E1_LOJA               					" + CRLF
	//cQuery += " 	AND SA1.A1_BLEMAIL	= '1'											" + CRLF
	cQuery += " 	AND SA1.A1_XBLCOB   <> '2' 						       				" + CRLF
	cQuery += " 	AND SA1.D_E_L_E_T_ 	= ''                        					" + CRLF
	cQuery += " LEFT JOIN "+ RetSqlName("SF2") +" (NOLOCK) SF2 ON 						" + CRLF
	cQuery += " 		SF2.F2_FILIAL 	= SE1.E1_FILIAL 		                        " + CRLF
	cQuery += " 	AND SF2.F2_DOC 		= SE1.E1_NUM                                    " + CRLF
	cQuery += " 	AND SF2.F2_SERIE 	= SE1.E1_PREFIXO                                " + CRLF
	cQuery += " 	AND SF2.F2_CLIENTE 	= SE1.E1_CLIENTE                                " + CRLF
	cQuery += " 	AND SF2.F2_LOJA 	= SE1.E1_LOJA                                   " + CRLF
	cQuery += " 	AND SF2.D_E_L_E_T_ 	= ' '                                           " + CRLF
	cQuery += " WHERE                                               					" + CRLF
	cQuery += " 		SE1.E1_FILIAL 	= '"+ xFilial("SE1") +"'    					" + CRLF	
	cQuery += " 	AND SE1.E1_SALDO	> 0                        						" + CRLF	
	
	if(::cTipoWf == "A")
		cQuery += " 	AND SE1.E1_VENCREA  <= '"+ DtoS(DaySum(::dDtRef, nDiasAVcto)) 	+"'        							" + CRLF
		cQuery += " 	AND SE1.E1_VENCREA  >  '"+ DtoS(::dDtRef) 						+"'        							" + CRLF

	elseif(::cTipoWf == "V" .AND. Alltrim(Upper(::cTpVcto)) == ::TP_LIMITE)
		cQuery += " 	AND SE1.E1_VENCREA  BETWEEN '"+ DtoS(::dDtRef) +"'  AND '"+ DtoS(DaySum(::dDtRef, nDiasAVcto)) +"' 	" + CRLF
	
	elseif(::cTipoWf == "V" .AND. Alltrim(Upper(::cTpVcto)) == ::TP_DIAS)

		if(Alltrim(Upper(::cTpEnvioVct)) == ::TP_PRIM)
			cQuery += " 	AND DATEDIFF(DAY, CONVERT(DATETIME, SE1.E1_VENCREA), GETDATE()) BETWEEN "+ CValToChar(::nTx1De) +" AND "+ CValToChar(::nTx1Ate) + CRLF

		elseIf(Alltrim(Upper(::cTpEnvioVct)) == ::TP_SEG	)
			cQuery += " 	AND DATEDIFF(DAY, CONVERT(DATETIME, SE1.E1_VENCREA), GETDATE()) BETWEEN "+ CValToChar(::nTx2De) +" AND "+ CValToChar(::nTx2Ate) + CRLF

		elseIf(Alltrim(Upper(::cTpEnvioVct)) == ::TP_TERC)
			cQuery += " 	AND DATEDIFF(DAY, CONVERT(DATETIME, SE1.E1_VENCREA), GETDATE()) BETWEEN "+ CValToChar(::nTx3De) +" AND "+ CValToChar(::nTx3Ate) + CRLF

		endIf
	endIf
	
	//cQuery += " 	AND E1.E1_NUM  	IN ('000060242')									" + CRLF
	//cQuery += " 	AND SE1.E1_NUM  	IN ('000004251', '000004229', '000004252')									" + CRLF
	//cQuery += " 	AND SE1.E1_NUM  	IN ('000045606', '000045634')		" + CRLF
	cQuery += " 	AND SE1.E1_TIPO		   IN ("+ cTpNIn  +")	" + CRLF	

	if(!Empty(cSiTNIn))
		cQuery += " 	AND SE1.E1_SITUACA NOT IN ("+ cSiTNIn +")	" + CRLF
	endIf

	if(!Empty(cPorNIn))
		cQuery += " 	AND SE1.E1_PORTADO NOT IN ("+ cPorNIn +")	" + CRLF
	endIf

	if(!Empty(cPrfNIn))
		cQuery += " 	AND SE1.E1_PREFIXO	NOT IN ("+ cPrfNIn +") " + CRLF
	endIf
	
	cQuery += " 	AND SE1.D_E_L_E_T_	= ''                        					" + CRLF
	cQuery += " ORDER BY	E1_CLIENTE, E1_LOJA, 										" + CRLF
	cQuery += " 			E1_PREFIXO, E1_NUM , E1_PARCELA, E1_TIPO					" + CRLF

	if(lAbrAviso)
		Aviso(FunDesc(), cQuery, {"OK"}, 3, FunDesc())
	endIf

	TcQuery cQuery New Alias (cAliasQry)
	
	TCSetField(cAliasQry, "E1_EMISSAO"	, "D")
	TCSetField(cAliasQry, "E1_VENCTO"	, "D")
	TCSetField(cAliasQry, "E1_VENCREA"	, "D")
		
return cAliasQry

/*/{Protheus.doc} updLog
Query dos títulos vencidos
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method updLog(aTitulos) class WfDaVcto
	local nI := 1
	
	for nI := 1 to Len(aTitulos)
		SE1->(DbGoTo(aTitulos[nI]:nRecnoTit))
		if(!SE1->(Eof()))
			SE1->(RecLock("SE1", .F.))
				SE1->E1_XDTWFVC	:= dDataBase
				SE1->E1_XHRWFVC	:= SubStr(Time(), 1, 5)
				SE1->E1_XMLWFVC	:= aTitulos[nI]:cMailCli 
			SE1->(MsUnlock())
		endIf
	next
return
