#include 'protheus.ch'
#include 'topconn.ch'
#include 'fwmvcdef.ch'
#include 'font.ch'
#Include "HBUTTON.CH"

static _oArqTMP


//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description

@param xParam Parameter Description
@return xRet Return Description
@author  -
@since 16/12/2022
/*/
//--------------------------------------------------------------
User Function AglINSS()
	Local oBAtualiza
	Local oBCanc
	local oBGeraF
	Local oBInvert
	Local oGCompet
	Local oGDarf
	Local oGFornece
	Local oGLoja
	Local oGNome
	Local oGroup1
	Local oGroup2
	Local oGroup3
	Local oGVencto
	Local oGVlrGuia
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	private aBrwFis   := {}
	private aBrwRH    := {}
	private cGDarf    := space(TamSx3("E2_CODBAR")[1])
	private cGFornece := space(TamSx3("E2_FORNECE")[1])
	private cGLoja    := space(TamSx3("E2_LOJA")[1])
	private cGNome    := space(TamSx3("A2_NOME")[1])
	private dGCompet  := Date()
	private dGVencto  := cTod( '' )
	private nGVlrGuia := 0
	private oBrwFis
	private oBrwRH
	private oNo       := LoadBitmap( GetResources(), "LBNO")
	private oOk       := LoadBitmap( GetResources(), "LBOK")
	private nValTit := 0
	private nQtdReg := 0
	Static oDlgDARF
	cGFornece := 'INSP'
	cGLoja    := '00'
	cGNome    := 'INSTITUTO NACIONAL DE PREVIDENCIA SOCIAL'
	dGCompet  := lastDay(MonthSub(dDataBase,1))
	nQtdReg := 0
	// Insert items here
	aAdd(aBrwFis,{.F.,'','','','','',cTod(''),'',cTod(''),Transform(0,X3Picture("E2_SALDO"))})

	// Insert items here
	aAdd(aBrwRH,{'','','','','',cTod(''),cTod(''),Transform(0,X3Picture("E2_SALDO"))})

	DEFINE MSDIALOG oDlgDARF TITLE "Aglutinação Financeira de Impostos" FROM 000, 000  TO 630, 1000 COLORS 0, 16777215 PIXEL

	@ 004, 005 GROUP oGroup1 TO 054, 399 OF oDlgDARF COLOR 0, 16777215 PIXEL

	@ 010, 010 SAY oSay1        PROMPT "Competência"                SIZE 039, 007 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 018, 010 MSGET oGCompet   VAR dGCompet                        SIZE 056, 010 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 010, 112 SAY oSay2        PROMPT "Fornecedor"                 SIZE 034, 007 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 018, 112 MSGET oGFornece  VAR cGFornece                       SIZE 039, 010 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 018, 155 MSGET oGLoja     VAR cGLoja                          SIZE 012, 010 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 018, 172 MSGET oGNome     VAR cGNome                          SIZE 196, 010 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 031, 010 SAY oSay3        PROMPT "Codigo de Barras [ DARF ]"  SIZE 070, 007 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 039, 010 MSGET oGDarf     VAR cGDarf                          SIZE 230, 010 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 031, 350 SAY oSay4        PROMPT "Vencimento"                 SIZE 041, 007 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 039, 350 MSGET oGVencto   VAR dGVencto                        SIZE 041, 010 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 031, 265 SAY oSay5        PROMPT "Valor Guia"                 SIZE 029, 007 OF oDlgDARF COLORS 0, 16777215 PIXEL
	@ 040, 265 MSGET oGVlrGuia  VAR nGVlrGuia                       SIZE 071, 010 OF oDlgDARF COLORS 0, 16777215 PIXEL

	@ 059, 005 GROUP oGroup2 TO 105, 495 PROMPT "  ::.. Titulo de Complemento ..::  " OF oDlgDARF COLOR 0, 16777215 PIXEL

	@ 067, 010 LISTBOX oBrwRH Fields HEADER "Filial","Prefixo","Numero","Tipo","Fornecedor","Emissão","Venctimento","Valor" SIZE 480, 033 OF oDlgDARF PIXEL ColSizes 50,50
	oBrwRH:SetArray(aBrwRH)
	oBrwRH:bLine := {|| {;
		aBrwRH[oBrwRH:nAt,1],;
		aBrwRH[oBrwRH:nAt,2],;
		aBrwRH[oBrwRH:nAt,3],;
		aBrwRH[oBrwRH:nAt,4],;
		aBrwRH[oBrwRH:nAt,5],;
		aBrwRH[oBrwRH:nAt,6],;
		aBrwRH[oBrwRH:nAt,7],;
		aBrwRH[oBrwRH:nAt,8];
		}}
	// DoubleClick event
	// oBrwRH:bLDblClick := {|| Invert('I'),;
		// 	oBrwRH:DrawSelect()}
	@ 105, 005 GROUP oGroup3 TO 295, 495 PROMPT "  ::.. Titulos Fiscal ..:: " OF oDlgDARF COLOR 0, 16777215 PIXEL

	@ 125, 010 LISTBOX oBrwFis Fields HEADER "","Filial","Prefixo","Numero","Tipo","Parcela","Emissão","Fornecedor","Vencimento","Valor (Saldo)" SIZE 480, 160 OF oDlgDARF PIXEL ColSizes 50,50
	oBrwFis:SetArray(aBrwFis)
	oBrwFis:bLine := {|| {;
		Iif(aBrwFis[oBrwFis:nAT,1],oOk,oNo),;
		aBrwFis[oBrwFis:nAt,2],;
		aBrwFis[oBrwFis:nAt,3],;
		aBrwFis[oBrwFis:nAt,4],;
		aBrwFis[oBrwFis:nAt,5],;
		aBrwFis[oBrwFis:nAt,6],;
		aBrwFis[oBrwFis:nAt,7],;
		aBrwFis[oBrwFis:nAt,8],;
		aBrwFis[oBrwFis:nAt,9],;
		aBrwFis[oBrwFis:nAt,10];
		}}
	// DoubleClick event
	oBrwFis:bLDblClick := {|| Invert('I'),;
		oBrwFis:DrawSelect()}
	@ 003, 403 BUTTON oBAtualiza    PROMPT "Atualizar"          SIZE 090, 012 OF oDlgDARF PIXEL
	@ 017, 403 BUTTON oBInvert      PROMPT "Inverter Seleção"   SIZE 090, 012 OF oDlgDARF PIXEL
	@ 031, 403 BUTTON oBGeraF       PROMPT "Gerar Financeiro"   SIZE 090, 012 OF oDlgDARF PIXEL
	@ 045, 403 BUTTON oBCanc        PROMPT "Cancelar"           SIZE 090, 012 OF oDlgDARF PIXEL

	SET MESSAGE OF oDlgDARF COLORS 0, 14215660
	TMsgItem():New(oDlgDARF:oMsgBar,"QTD. REGISTROS: " + cValToChara(nQtdReg),400,,,,.T.,{||})
	TMsgItem():New(oDlgDARF:oMsgBar,"VALOR TOTAL: " + Transform(nValTit,x3picture("E2_VALOR")) ,400,,,,.T.,{||})


	oBAtualiza:bAction :={|| Atualiza()}
	oBInvert:bAction   :={|| Invert( 'A' )}
	oBCanc:bAction     :={|| oDlgDARF:End()}
	oGDarf:bValid      :={|| vldCodbar()}
	oGVlrGuia:Picture  := x3Picture("E2_VALOR")
	oGLoja:Disable()
	oGNome:Disable()

	ACTIVATE MSDIALOG oDlgDARF CENTERED

Return
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function vldCodbar()
	local lValid as logical
	local cCodBarras as character
	local nValor as numeric
	lValid := .T.

	cCodBarras := cGDarf
	If FinVldLD(cCodBarras, .T.)
		nValor := val(substr(cCodBarras,5,7)+substr(cCodBarras,13,4))/100

		nGVlrGuia := nValor
	Else
		lValid := .F.
	EndIf

    If Empty(dGVencto)
        dGVencto := cTod('20/'+cValToChar(Month(dGCompet))+'/'+cValToChar(year(dGCompet)))

	EndIf

return(lValid)
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function Atualiza()
	local cQuery    as character
	local lContinua as logical

	lContinua := .T.

	If Empty(cGDarf)
		FwAlertWarning("Favor realizar o preenchimento do código de barras da Darf de pagamento.","Validacao DARF")
		lContinua := .F.
	EndIf


	If Empty(dGVencto)
        dGVencto := cTod('20/'+cValToChar(Month(dGCompet))+'/'+cValToChar(year(dGCompet)))

	EndIf

	If Empty(nGVlrGuia)
		FwAlertWarning("Favor realizar o preenchimento do valor da Guia de pagamento DARF.","Validacao DARF")
		lContinua := .F.
	EndIf

	If !lContinua
		return(lContinua)
	EndIf

	nValTit  := 0

	cQuery := ""
	cQuery += " SELECT * FROM " + RetSqlName("SE2") +" SE2 "
	cQuery += "  WHERE SE2.D_E_L_E_T_  = ''
	cQuery += "    AND E2_TIPO = 'INS'
	cQuery += "    AND LEFT(E2_VENCTO,6) = '" + substr(dTos(dGCompet),1,6) + "'
	cQuery += "    AND E2_SALDO != 0 AND E2_ORIGEM = 'MATA100'
	cQuery += "    AND LEFT(E2_FILIAL,2) = '" + substr(FwCodFil(),1,2) + "'
	TcQuery cQuery New Alias (cTRB := GetNextAlias())


	dbSelectArea((cTRB))
	(cTRB)->(dbGoTop())
	If (cTRB)->(!eof())
		aBrwFis := {}
		while (cTRB)->(!eof())

			aAdd(aBrwFis,{.T.,;
				(cTRB)->E2_FILIAL,;
				(cTRB)->E2_PREFIXO,;
				(cTRB)->E2_NUM,;
				(cTRB)->E2_TIPO,;
				(cTRB)->E2_PARCELA,;
				sTod((cTRB)->E2_EMISSAO),;
				(cTRB)->E2_NOMFOR,;
				sTod((cTRB)->E2_VENCTO),;
				Transform((cTRB)->E2_SALDO,X3Picture("E2_SALDO"))})

			nValTit += (cTRB)->E2_SALDO
			nQtdReg += 1

			(cTRB)->(dbSkip())
		EndDo
		oBrwFis:SetArray(aBrwFis)
		oBrwFis:bLine := {|| {;
			Iif(aBrwFis[oBrwFis:nAT,1],oOk,oNo),;
			aBrwFis[oBrwFis:nAt,2],;
			aBrwFis[oBrwFis:nAt,3],;
			aBrwFis[oBrwFis:nAt,4],;
			aBrwFis[oBrwFis:nAt,5],;
			aBrwFis[oBrwFis:nAt,6],;
			aBrwFis[oBrwFis:nAt,7],;
			aBrwFis[oBrwFis:nAt,8],;
			aBrwFis[oBrwFis:nAt,9],;
			aBrwFis[oBrwFis:nAt,10];
			}}

		aBrwRH := {}
		aAdd(aBrwRH,{FWxFilial("SE2"),'','xxxxxx','INS','UNIAO',dDataBase,dGVencto,Transform(abs(nValTit - nGVlrGuia),X3Picture("E2_SALDO"))})
		oBrwRH:SetArray(aBrwRH)
		oBrwRH:bLine := {|| {;
			aBrwRH[oBrwRH:nAt,1],;
			aBrwRH[oBrwRH:nAt,2],;
			aBrwRH[oBrwRH:nAt,3],;
			aBrwRH[oBrwRH:nAt,4],;
			aBrwRH[oBrwRH:nAt,5],;
			aBrwRH[oBrwRH:nAt,6],;
			aBrwRH[oBrwRH:nAt,7],;
			aBrwRH[oBrwRH:nAt,8];
			}}



	EndIf
	(cTRB)->(dbCloseArea())
	oBrwFis:Refresh()
	oBrwRH:Refresh()




return()
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function Invert(cp_TP)
	local nX  := 0 as numeric
	nValTit := 0
	nQtdReg := 0

	If cp_TP == "I"
		aBrwFis[oBrwFis:nAt,1] := !aBrwFis[oBrwFis:nAt,1]
	Else
		For nX := 1 to len(aBrwFis)
			aBrwFis[nX,1] := !aBrwFis[nX,1]
		Next nX
	EndIf

	For nX := 1 to len(aBrwFis)
		If aBrwFis[nX,1]
			nValTit += val(strtran(strTran(aBrwFis[nX,10],'.',''),',','.'))
			nQtdReg += 1
		EndIf
	Next nX

	aBrwRH[1][8] :=  Transform(abs(nValTit - nGVlrGuia),X3Picture("E2_SALDO"))
	oDlgDARF:oMsgBar:aItem[1]:cMsg := "QTD. REGISTROS: " + cValToChara(nQtdReg)
	oDlgDARF:oMsgBar:aItem[2]:cMsg := "VALOR TOTAL: " + Transform(nValTit,x3picture("E2_VALOR"))
	oBrwFis:Refresh()
	oBrwRH:Refresh()
	oDlgDARF:Refresh()

return()


// ----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function GeraExcel()
	local oExcel
	local cPlan		:= 'DADOS'
	local cTitPlan	:= 'DADOS GERAÇÃO DARF - LIQUIDAÇÃO'
	local aArea		:= GetArea()
	oExcel := FWMsExcel():New()

	oExcel:AddWorkSheet(cPlan)
	oExcel:AddTable(cPlan,cTitPlan)


	oExcel:AddColumn(cPlan,cTitPlan,"Filial"						,1,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Prefixo"					    ,1,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Num. Titulo"					,1,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Parcela"					    ,1,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Tipo"					        ,1,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Titulo Pai"					,1,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Dirf"							,2,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Codigo Retencao"				,2,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Fornecedor"					,1,1,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Valor Original"				,3,2,.T.)
	oExcel:AddColumn(cPlan,cTitPlan,"Data Emissao"					,2,4,.F.)
	oExcel:AddColumn(cPlan,cTitPlan,"Data Vencimento"				,2,4,.F.)


	DbSelectArea("TRB")
	DbGoTop()
	While TRB->(!Eof())
		If TRB->MARCA == cMarca
			oExcel:AddRow(cPlan,cTitPlan,{TRB->FILIAL,;
				substr(TRB->TITULO,1,3),;
				substr(TRB->TITULO,5,9),;
				substr(TRB->TITULO,15,1),;
				substr(TRB->TITULO,17,3),;
				TRB->TITPAI,;
				TRB->DIRF,;
				TRB->CODRET,;
				TRB->FORNECE,;
				TRB->VALORI,;
				TRB->EMISSAO,;
				TRB->VENCTO})
		Endif
		TRB->(dbSkip())
	End
	DbSelectArea("TRB")
	DbGoTop()


	cPatch := "C:\TEMP\"
	aDir := Directory(cPatch,"D")
	If Len(aDir) == 0
		MakeDir(cPatch)
	EndIf

	cNomFile := "TITDARF_" + cCodRet +"_" + dTos(dDataI)+ "-"+dTos(dDataF)+".xml"
	oExcel:Activate()
	oExcel:GetXMLFile(cPatch + cNomFile)


	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!" + CRLF + "Arquivo gerado na pasta [ " + cPatch + cNomFile + " ]")
	else
		oExcel := MSExcel():New()
		oExcel:WorkBooks:Open(cPatch + cNomFile)
		oExcel:SetVisible(.T.)
	EndIf

	restArea(aArea)

return
// --------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function GeraFat()
	local lRet              := .T.
	local aArray            := {}
	local aTit              := {}
	local nValor            := 0
	local cCondicao         := "107"
	local dVencto           := cTod("")
	local cCodRet           := ''
	// Variáveis utilizadas para o controle de erro da rotina automática
	private lMsErroAuto     := .F.
	private lAutoErrNoFile  := .T.


	DbSelectArea("TRB")
	DbGoTop()
	While TRB->(!Eof())
		If TRB->MARCA == cMarca

			aAdd(aTit, {substr(TRB->TITULO,1,3),;
				substr(TRB->TITULO,5,9),;
				substr(TRB->TITULO,15,1),;
				substr(TRB->TITULO,17,3),;
				.F.,;
				cFornece,;
				cLoja })
			dVencto := TRB->VENCTO
			cCodRet := TRB->CODRET
			nValor += TRB->VALORI
		Endif
		TRB->(dbSkip())
	End
	DbSelectArea("TRB")
	DbGoTop()

	If len(aTit) > 0
		Begin Transaction

			aArray := {"FAT",;
				"FT",;
				cNumFatX,;
				cNatureza,;
				cTod("01/01/20"),;
				dDataF,;
				cFornece,;
				"  ",;
				cFornece,;
				cLoja,;
				cCondicao,;
				01,;
				aTit,;
				0,;
				0}

			Pergunte("AFI290",.F.)
			MsExecAuto( { |x,y| FINA290(x,y)},3,aArray)

			If lMsErroAuto
				MostraErro()
				lRet := .F.
				DisarmTransaction()
			Else

				dbSelectArea("SE2")
				dbSetOrder(1)
				If dbSeek(FwXFilial("SE2") + "FAT" + padr(cNumFatX, TamSx3("E2_NUM")[1]) + "AFT " + cFornece + cLoja )

					reclock("SE2", .F.)
					SE2->E2_VENCTO  := dVencto //dataValida(sTod(substr(dtos(dDataBase),1,6)+'20'),.F.)
					SE2->E2_VENCREA := dVencto //dataValida(sTod(substr(dtos(dDataBase),1,6)+'20'),.F.)
					SE2->E2_VENCREA := dVencto //dataValida(sTod(substr(dtos(dDataBase),1,6)+'20'),.F.)
					SE2->E2_CODRET  := cCodRet
					SE2->E2_NATUREZ := cNatureza
					SE2->(MsUnlock())

					MsgInfo("Titulo <b>GERADO [ FAT - FT - " + cNumFatX + " ] </b> com sucesso","Geracao Fatura Impostos")
				EndIf
			Endif
		End Transaction
	else
		lRet := .f.
		MsgAlert("Não foi selecionado registros para geração de fatura","Operação cancelada")
	EndIf
return ( lRet )
