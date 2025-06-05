#include "totvs.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#define ISS_SIM		"1"
#define ISS_NAO		"2"

static lEurofins := !("YMLLLM" $ GetEnvServer())

/*/{protheus.doc}RTITREC
Relação de títulos a receber
@author Sergio Braz
@since 18/10/2019
@type UserFunction
/*/
User Function RTitRec
	IIf(Type("cFilAnt")=="U",rpcsetenv("01","0100","admin","agis4","FIN"),Nil)
	If AskMe()
		GetData()
		Processa({||GeraPlan(.F.)},"Aguarde! Gerando Planilha.")
		E1->(DbCloseArea())
	Endif
Return

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function GetData
	BeginSql Alias "E1"
		Select R_E_C_N_O_ NUMREG
		From %Table:SE1%
		Where  %NotDel% AND  E1_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02%
			and E1_EMISSAO Between %Exp:MV_PAR03% and %Exp:MV_PAR04%
			and E1_VENCTO Between %Exp:MV_PAR05% and %Exp:MV_PAR06%
			and E1_CLIENTE+E1_LOJA Between %Exp:MV_PAR07+MV_PAR08% and %Exp:MV_PAR09+MV_PAR10%
			and E1_SALDO > 0 and E1_TIPO NOT IN ('IR-','IS-')
		Order by E1_MOEDA,E1_FILIAL,E1_EMISSAO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA
	EndSql
Return

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function AskMe
	Local aPergs 	:= {}
	Local cPerg		:= ""
	AADD(aPergs,{1,"Da Filial"     ,CriaVar("E1_FILIAL",.f.),"@!",'.t.','SM0','.T.',60,.F.})
	AADD(aPergs,{1,"Até Filial"    ,CriaVar("E1_FILIAL",.f.),"@!",'.t.','SM0','.T.',60,.F.})
	AADD(aPergs,{1,"Da Emissão"    ,ctod(""),,'.t.',,'.T.',80,.F.})
	AADD(aPergs,{1,"Até Emisssão"  ,ctod(""),,'.t.',,'.T.',80,.F.})
	AADD(aPergs,{1,"Do Vencimento" ,ctod(""),,'.t.',,'.T.',80,.F.})
	AADD(aPergs,{1,"Até Vencimento",ctod(""),,'.t.',,'.T.',80,.F.})
	AADD(aPergs,{1,"Do cliente"    ,CriaVar("A1_COD",.F.),"@!",".T.","SA1",'.T.',80,.F.})
	AADD(aPergs,{1,"Da .loja"      ,CriaVar("A1_LOJA",.F.),"@!",".T.",,'.T.',40,.F.})
	AADD(aPergs,{1,"Até cliente"   ,CriaVar("A1_COD",.F.),"@!",".T.","SA1",'.T.',80,.F.})
	AADD(aPergs,{1,"Até loja"      ,CriaVar("A1_LOJA",.F.),"@!",".T.",,'.T.',40,.F.})
	aAdd(aPergs,{2,"Tipo","1",{"1=Saldos","2=Totais"},60,.F.,.F.}) //MV_PAR11
	aAdd(aPergs,{2,"Considera ISS?","1",{"1=Sim","2=Não"},50,.F.,.F.}) //MV_PAR12

//Return ParamBox(aPergs,"Parâmetros",{})
Return ParamBox(aPergs,"Parâmetros",,,,,,,,cPerg,.T.,.T.)

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function GeraPlan(lp_SchedAut)
	Local cOldFil       := cFilAnt
	Local i,j,aValores,nRegs,nAlign,nType
	Local cTpPlan       := iif(MV_PAR11=="2","_TOT","_SLD")
	local cFldtemp      := iif(!IsBlind(),GetTempPath(),"\Temp\")
	Local cFile         := cFldtemp + (CriaTrab(Nil,.F.) + cTpPlan + ".xls") //GetTempPath() + (CriaTrab(Nil,.F.) + cTpPlan + ".xls")
	Local oExcel        := FwMsExcel():New()
	Local cPlan
	Local aFields       := GetFields()
	Private nValLiq     := 0
	Private nValAtu     := 0
	Private nValOrig    := 0
	Private cNomMoe     := ""

	Private nValBx      := 0
	Private nValNomin   := 0
	Private nImpBaixado := 0

	Private nValPIS     := 0
	Private nValCSLL    := 0
	Private nValCOFINS  := 0
	Private nValIRRF    := 0
	Private nValISS     := 0

	Private cStatusCli  := ""
	Private cTipoCob    := ""

	Private cMoeda      := "Real"
	Private cCond       := ""
	Private cConta      := ""

	Private cEndereco   := ""

	Private cVend       := ""
	Private cPedido     := ""
	Private cColigad    := ""

	Private cNSU        := "" as character
	Default lp_SchedAut := .F.

	FWMakeDir('\Temp\',.F.)

	If !IsBlind()
		Count to nRegs
	EndIf

	E1->(DbGoTop())
	For j:=1 to 2
		cPlan := "Títulos a Receber em "+iif(j==1,"Reais","outras moedas")
		oExcel:AddWorksheet(cPlan)
		oExcel:AddTable(cPlan,cPlan)
	Next
	For i:=1 To Len(aFields)
		If ValType(&(aFields[i,2])) == "D"
			nAlign := 2
			nType  := 4
		ElseIf ValType(&(aFields[i,2])) == "N"
			nAlign := 3
			nType  := 2
		Else
			nAlign := 1
			nType  := 1
		Endif
		For j:=1 to 2
			cPlan := "Títulos a Receber em "+iif(j==1,"Reais","outras moedas")
			oExcel:AddColumn(cPlan,cPlan,Capital(aFields[i,1]),nAlign,nType,.f.)
		Next
	Next

	If !IsBlind()
		ProcRegua(nRegs)
	EndIf

	While E1->(!Eof())
		SE1->(DbGoTo(E1->NUMREG))
		cFilAnt := SE1->E1_FILIAL

		//NOTE - alterado por Leandro Cesar 03/11/22

		If lp_SchedAut
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1), dbSeek(FWxFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) ))
			If cFilAnt $ "0500#0501#0502#0503#0504#0800#0802" .or. SA1->A1_ZZCOLIG == 'S' .or. alltrim(cFilAnt) == '1'
				E1->(DbSkip())
				loop
			EndIf
		EndIf

		Posicione("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"")
		Posicione("SC5",1,xFilial("SC5")+SE1->E1_PEDIDO,"")
		cNomMoe := Posicione("SX5",1,xFilial("SX5")+"ZZ"+StrZero(SE1->E1_MOEDA,2,0),"X5_DESCRI")
		if Empty(Alltrim(cNomMoe))
			cNomMoe:= Posicione("SX5",1,xFilial("SX5")+"ZZ"+Alltrim(SE1->E1_MOEDA),"X5_DESCRI")
		endif

		cStatusCli	:= iif( Posicione("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_MSBLQL") == "1","BLOQUEADO","LIBERADO")
		cTipoCob	:= x3combo( "A1_ZZTPCOB", Posicione("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_ZZTPCOB") )

		cCond  		:= Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"Trim(E4_DESCRI)")
		nValLiq 	:= ROUND(SE1->E1_SALDO-SE1->E1_IRRF-(SE1->E1_PIS-CalcImp("PIS"))-(SE1->E1_COFINS-CalcImp("COF"))-(SE1->E1_CSLL-CalcImp("CSL")),2)
		aValores 	:= {}
		cVend       := Posicione("SA3", 1, xFilial("SA3")+SC5->C5_ZZVEND, "A3_NOME")
		cPedido		:= bscPedido(SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA)
		cColigad	:= iif(SA1->A1_ZZCOLIG=="S","Sim","Não")

		//nValAtu := SE1->(IIf(E1_TXMDCOR == 0,E1_VLCRUZ,E1_SALDO * E1_TXMDCOR))
		nValAtu		:= iif(SE1->E1_VLCRUZ == 0,SE1->E1_VALOR,SE1->E1_VLCRUZ)
		nValOrig	:= SE1->E1_VALOR

		//Julio Lisboa - 15/01/2020
		//Calculo dos Impostos
		nValPIS		:= bscSaldo( "PIS", SE1->E1_PIS, 		SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )
		nValCSLL	:= bscSaldo( "CSL", SE1->E1_CSLL, 		SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )
		nValCOFINS	:= bscSaldo( "COF", SE1->E1_COFINS, 	SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )
		nValIRRF	:= bscSaldo( "IR-", SE1->E1_IRRF, 		SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )

		If AllTrim(MV_PAR12) == ISS_SIM
			nValISS		:= bscSaldo( "IS-", SE1->E1_ISS, 		SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )
		Else
			nValISS		:= 0
		EndIf

		//nValNomin		:= ( SE1->E1_SALDO - SE1->E1_IRRF )
		nImpBaixado		:= 0
		nImpBaixado		+= bscSaldo( "PIS", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )
		nImpBaixado		+= bscSaldo( "COF", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )
		nImpBaixado		+= bscSaldo( "CSL", 0, SE1->E1_FILIAL , SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_CLIENTE , SE1->E1_LOJA )

		//valor baixado
		nValBx			:= ( SE1->E1_VALOR - SE1->E1_SALDO ) - nImpBaixado
		nValNomin		:= ( SE1->E1_VALOR - nValBx ) - SE1->E1_IRRF

		nValNomin		-= nValISS
		nValLiq			-= nValISS

		If AllTrim(SE1->E1_TIPO) == "RA"
			nValLiq		:= nValLiq * -1
			nValAtu		:= nValAtu * -1
			nValOrig	:= nValOrig * -1
			nValNomin	:= nValNomin * -1
		EndIf


		//NOTE preenche o campo de NSU
		//alterado por Leandro Cesar - 24/06/22
		// E1_DOCTEF - REDE ITAU - E1_NSUTEF - GETNET SANTANDER;
			If !Empty(SE1->E1_DOCTEF)
			cNSU := alltrim(SE1->E1_DOCTEF)
		Else
			cNSU := alltrim(SE1->E1_NSUTEF)
		EndIf

		cMoeda  	:= Capital(GetMV("MV_MOEDA"+cValToChar(SE1->E1_MOEDA)))
		For i:=1 to Len(aFields)
			AADD(aValores,&(aFields[i,2]))
		Next

		cEndereco		:= ""

		cPlan := "Títulos a Receber em "+iif(SE1->E1_MOEDA==1,"Reais","outras moedas")
		oExcel:AddRow(cPlan,cPlan,aValores)
		E1->(DbSkip())

		If !IsBlind()
			IncProc()
		EndIf
	End

	oExcel:Activate()
	oExcel:GetXMLFile(cFile)

	If IsBlind()
		sleep(5000)
	EndIf

	If File(cFile) .and. !IsBlind()
		If MsgYesNo("Abrir arquivo "+cFile)
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open(cFile)
			oExcel:SetVisible(.T.)
		Endif
	Endif

	cFilAnt := cOldFil
Return(cFile)

// ---------------------------------------------------------------------------------------------------------------------------------------------------

static function bscSaldo(cTipo,nVlrAtu,cFilTit,cPrefTit,cNumTit,cCliTit,cLojTit)

	local nRet		:= 0
	local cQuery	:= ""
	local cAlias	:= GetNextAlias()

	if MV_PAR11 == "2"
		nRet		:= nVlrAtu
	else
		cQuery		+= "SELECT " + CRLF
		cQuery		+= "	SUM(E1_VALOR) VALOR" + CRLF
		cQuery		+= "FROM " + CRLF
		cQuery		+= "	" + RetSqlTab("SE1") + CRLF
		cQuery		+= "WHERE " + CRLF
		cQuery		+= "	D_E_L_E_T_ = ' ' " + CRLF
		cQuery		+= "	AND E1_TIPO = '" + cTipo + "' " + CRLF
		cQuery		+= "	AND E1_FILIAL = '" + cFilTit + "' " + CRLF
		cQuery		+= "	AND E1_PREFIXO = '" + cPrefTit + "' " + CRLF
		cQuery		+= "	AND E1_NUM = '" + cNumTit + "' " + CRLF
		cQuery		+= "	AND E1_CLIENTE = '" + cCliTit + "' " + CRLF
		cQuery		+= "	AND E1_LOJA = '" + cLojTit + "' " + CRLF
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
	endif

return nRet

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function CalcImp(cImp)
	Local nImp
	BeginSql Alias "IM"
		Select Sum(E1_VALOR) E1_VALOR
		From %Table:SE1%
		Where %NotDel% and E1_FILIAL = %Exp:SE1->E1_FILIAL%  and E1_TITPAI = %Exp:SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)% and E1_TIPO = %Exp:cImp%
	EndSql
	nImp := IM->E1_VALOR
	IM->(DbCloseArea())
Return nImp

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function GetFields
	Local aF := {}
	// Local cNomMoe := ""
	AADD(aF,{"Filial","SE1->E1_FILIAL"})
	AADD(aF,{"CNPJ/CPF","SA1->A1_CGC"})
	AADD(aF,{"Cliente","SA1->A1_COD"})
	AADD(aF,{"Loja","SA1->A1_LOJA"})
	AADD(aF,{"Nome Cliente","SA1->A1_NOME"})
	AADD(aF,{"Tipo","SE1->E1_TIPO"})
	AADD(aF,{"Prf-Numero Parcela","SE1->E1_PREFIXO+'-'+SE1->E1_NUM+'-'+SE1->E1_PARCELA"})
	AADD(aF,{"Data de Emissão","SE1->E1_EMISSAO"})
	AADD(aF,{"Vencto Título","SE1->E1_VENCTO"})
	AADD(aF,{"Vencto Real","SE1->E1_VENCREA"})
	AADD(aF,{"Dias Atraso","DDATABASE-SE1->E1_VENCREA"})
	AADD(aF,{"Moeda","cNomMoe"})


	//REMOVIDO - 31/01/2020 AADD(aF,{"Moeda","cValToChar(SE1->E1_MOEDA)+'-'+cMoeda"})

	//AADD(aF,{"Vlr Original (Bruto)","SE1->E1_VALOR"})
	AADD(aF,{"Vlr Original (Bruto)","nValOrig"})

	AADD(aF,{"Valor em Real","SE1->E1_VLCRUZ"})

	//REMOVIDO - 31/01/2020 AADD(aF,{"Vlr em Reais","nValAtu"})

	//AADD(aF,{"Vlr Nominal (Saldo-IR)","SE1->E1_SALDO-SE1->E1_IRRF"})
	AADD(aF,{"Vlr Nominal (Saldo-IR)","nValNomin"})
	AADD(aF,{"Vlr Liq p/Baixa (Saldo-IR-PCC)","nValLiq"})
	AADD(aF,{"Bco St","SE1->E1_PORTADO+' '+SE1->E1_SITUACA"})

	//AADD(aF,{"PIS","SE1->E1_PIS"})
	AADD(aF,{"PIS","nValPIS"})

	//AADD(aF,{"CSLL","SE1->E1_CSLL"})
	AADD(aF,{"CSLL","nValCSLL"})

	//AADD(aF,{"COFINS","SE1->E1_COFINS"})
	AADD(aF,{"COFINS","nValCOFINS"})

	//AADD(aF,{"IRRF","SE1->E1_IRRF"})
	AADD(aF,{"IRRF","nValIRRF"})

	AADD(aF,{"ISS","nValISS"})

	AADD(aF,{"Lim.Crédito","SA1->A1_LC"})
	AADD(aF,{"Risco","SA1->A1_RISCO"})
	AADD(aF,{"Classif.Vend","SA1->A1_CLASVEN"})

	AADD(aF,{"Município","SA1->A1_MUN"})

	AADD(aF,{"DDD","SA1->A1_DDD"})
	AADD(aF,{"Telefone","SA1->A1_TEL"})
	AADD(aF,{"e-Mail Ficha","Trim(SC5->C5_ZZNFMAI)"})
	AADD(aF,{"e-Mail Financeiro","Trim(SA1->A1_EMAIL)"})
	AADD(aF,{"Histórico","Trim(SE1->E1_HIST)"})

	AADD(aF,{"Obs. Cadastro","AllTrim(SA1->A1_OBSERV )"})

	//REMOVIDO - 31/01/2020 AADD(aF,{"Pedido","SE1->E1_PEDIDO"})

	AADD(aF,{"Cond.Pgto","SC5->C5_CONDPAG"})
	AADD(aF,{"Descrição CP","SE4->E4_DESCRI"})

	AADD(aF,{"Portador","SE1->E1_PORTADO"})
	AADD(aF,{"Situacao","SE1->E1_SITUACA"})
	AADD(aF,{"Status Cliente","cStatusCli"})
	AADD(aF,{"Tipo Cobrança","cTipoCob"})

	AADD(aF,{"Conta Contábil","SA1->A1_CONTA"})

	//2020012110066789 alterado para esta posição
	AADD(aF,{"Endereço","AllTrim( SA1->A1_END ) + ', ' + AllTrim(SA1->A1_BAIRRO) "})

	//2020012110066789 alterado para esta posição
	AADD(aF,{"CEP","SA1->A1_CEP"})

	//Chamado #30023
	AADD(aF,{"Cod. Vendedor","SC5->C5_ZZVEND"})
	AADD(aF,{"Vendedor","cVend"})
	AADD(aF,{"Pedido","cPedido"})
	AADD(aF,{"Coligada?","cColigad"})

	//alterado por Leandro Cesar - 24/06/22
	AADD(aF,{"NSU","cNSU"})


Return aF

// ---------------------------------------------------------------------------------------------------------------------------------------------------

static function bscPedido(cFilPed,cSeriePed,cNFPed,cCliPed,cLojPed)

	local cRet		:= ""
	local cQuery	:= ""
	local cAlias	:= GetNextAlias()

	cQuery		+= "SELECT " + CRLF
	cQuery		+= "	DISTINCT C6_PEDCLI " + CRLF
	cQuery		+= "FROM " + CRLF
	cQuery		+= "	" + RetSqlTab("SD2")+ ", " + CRLF
	cQuery		+= "	" + RetSqlTab("SC6")+ " " + CRLF
	cQuery		+= "WHERE " + CRLF
	cQuery		+= "	SD2.D_E_L_E_T_ 			= ' ' " + CRLF
	cQuery		+= "	AND SC6.D_E_L_E_T_ 		= ' ' " + CRLF
	cQuery		+= "	AND SD2.D2_TIPO 		= 'N' " + CRLF
	cQuery		+= "	AND SD2.D2_FILIAL 		= '" + cFilPed + "' " + CRLF
	cQuery		+= "	AND SD2.D2_SERIE 		= '" + cSeriePed + "' " + CRLF
	cQuery		+= "	AND SD2.D2_DOC 			= '" + cNFPed + "' " + CRLF
	cQuery		+= "	AND SC6.C6_CLI 			= SD2.D2_CLIENTE " + CRLF
	cQuery		+= "	AND SC6.C6_LOJA 		= SD2.D2_LOJA " + CRLF
	cQuery		+= "	AND SC6.C6_NUM 			= SD2.D2_PEDIDO " + CRLF
	cQuery		+= "	AND SC6.C6_FILIAL 		= SD2.D2_FILIAL " + CRLF
	cQuery		+= "	AND SC6.C6_PRODUTO 		= SD2.D2_COD " + CRLF
	cQuery		+= "	AND SC6.C6_ITEM 		= SD2.D2_ITEMPV " + CRLF
	cQuery		+= "" + CRLF

	tcquery cQuery New Alias &cAlias

	if (cAlias)->(!Eof())
		if Empty(cRet)
			cRet	:= (cAlias)->C6_PEDCLI
		else
			cRet	+= " / "+(cAlias)->C6_PEDCLI
		endif
	endif

	(cAlias)->(DbCloseArea())

return cRet

// ---------------------------------------------------------------------------------------------------------------------------------------------------

User Function SchTitRec()
	local cFile  := ""
	local cPasta := "\Temp\"
	local cPara  := ""
	local cEmpX  := "01"
	local cFilX  := iif(lEurofins, "0100", "5000")

	PREPARE ENVIRONMENT EMPRESA cEmpX FILIAL cFilX MODULO "FIN"

	U_zLogMsg("Inicio da rotina de schedule RTitRec")

	prepMV()
	GetData()
	aAreaAux := GetArea()
	cFile := GeraPlan(.T.)
	RestArea(aAreaAux)
	E1->(DbCloseArea())

	If File(cFile)

		cFileZip := strTran(cFile,".xls",".ZIP")
		If FZip(cFileZip,{cFile},cPasta) == 0
			FErase(cFile)
		EndIf

		If File(cFileZip)
			cPara := GetMv("CL_EMAILCR")
			U_SendMail(, cPara, ;
				'',;
				'Relatorio de Cobranca - ' + cValToChar(Date()),;
				'Relatorio de Cobranca',;
				cFileZip)

			// sleep(5000)

			If File(cFileZip)
				FERASE(cFileZip)
			EndIf
		EndIf
	endif
	U_zLogMsg("Termino da rotina de schedule RTitRec.")

	RESET ENVIRONMENT

return

// ---------------------------------------------------------------------------------------------------------------------------------------------------

static function prepMV()

	MV_PAR01 := "    "
	MV_PAR02 := "ZZZZ"
	MV_PAR03 := cTod("01/01/2000")
	MV_PAR04 := cTod("31/12/2050")
	MV_PAR05 := cTod("01/01/2000")
	MV_PAR06 := cTod("31/12/2050")
	MV_PAR07 := space(TamSx3("A1_COD")[1])
	MV_PAR08 := space(TamSx3("A1_LOJA")[1])
	MV_PAR09 := "ZZZZZZ"
	MV_PAR10 := "ZZ"
	MV_PAR11 := "1"
	MV_PAR12 := "1"

return

// ---------------------------------------------------------------------------------------------------------------------------------------------------

User Function SchTitAtrs()
	local cFile  := ""
	local cPasta := "\Temp\"
	local cPara  := ""
	local cEmpX  := "01"
	local cFilX  := iif(lEurofins, "0100", "5000")

	PREPARE ENVIRONMENT EMPRESA cEmpX FILIAL cFilX MODULO "FIN"

	U_zLogMsg("Inicio da rotina de schedule RTitRec")

	prepMV()
	GetAtrsDate()
	aAreaAux := GetArea()
	cFile := GeraPlan(.T.)
	RestArea(aAreaAux)
	E1->(DbCloseArea())

	If File(cFile)

		cFileZip := strTran(cFile,".xls",".ZIP")
		If FZip(cFileZip,{cFile},cPasta) == 0
			FErase(cFile)
		EndIf

		_cCC:= GetMv("CL_CCMAICR")

		If File(cFileZip)
			cPara := GetMv("CL_EMAILCR")
			U_SendMail(, cPara, ;
				_cCC,;
				'Relatorio de Titulos vencidos não baixados - ' + cValToChar(Date()),;
				'Relatorio de Titulos vencidos não baixados',;
				cFileZip)

			// sleep(5000)

			If File(cFileZip)
				FERASE(cFileZip)
			EndIf
		EndIf
	endif
	U_zLogMsg("Termino da rotina de schedule RTitRec.")

	RESET ENVIRONMENT

return

// ---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function GetAtrsDate

	_cData:= DTOS(DataValida(DaySub(ddatabase, 1),.F.))
	BeginSql Alias "E1"
		Select R_E_C_N_O_ NUMREG
		From %Table:SE1%
		Where  %NotDel% AND  E1_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02%
			and E1_EMISSAO Between %Exp:MV_PAR03% and %Exp:MV_PAR04%
			and E1_VENCREA Between %Exp:MV_PAR05% and %Exp:MV_PAR06%
			and E1_CLIENTE+E1_LOJA Between %Exp:MV_PAR07+MV_PAR08% and %Exp:MV_PAR09+MV_PAR10%
			and E1_SALDO > 0 and E1_TIPO NOT IN ('IR-','IS-')
			//and DATEDIFF(DAY,E1_VENCREA, CONVERT(VARCHAR,CONVERT(DATE,getdate(),121),112)) = 2
			AND E1_VENCREA = %Exp:_cData%
			and E1_BAIXA = ''
		Order by E1_MOEDA,E1_FILIAL,E1_EMISSAO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA
	EndSql
Return
