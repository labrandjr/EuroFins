#include 'totvs.ch'


user function bxcrauto()

	Processa()

return()
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------

static function Processa()

	Local oBCanc
	Local oBConf
	Local oBInvert
	Local oBVisual
	Local oGroup1
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {}
	Local aAlterFields := {"E1_OK,E1_FILIAL,E1_PREFIXO,E1_NUM,E1_TIPO,E1_PAR","CELA,E1_EMISSAO,E1_VENCREA,E1_CLIENTE,E1_LOJA,","E1_NOMCLI,E1_VALOR,E1_SALDO,E1_IRRF,E1_INSS,E1_","CSLL,E1_COFINS,E1_PIS"}

	PRIVATE cLoteFin 	:= Space(TamSX3("E5_LOTE")[1])
	PRIVATE cBco110 	:= CRIAVAR("A6_COD")
	PRIVATE cAge110 	:= CRIAVAR("A6_AGENCIA")
	PRIVATE cCta110 	:= CRIAVAR("A6_NUMCON")
	PRIVATE cCliDe  	:= CRIAVAR("E1_CLIENTE")
	PRIVATE cCliAte 	:= CRIAVAR("E1_CLIENTE")
	PRIVATE cMotBx		:= CriaVar("E5_MOTBX")
	PRIVATE nMulta		:= 0
	PRIVATE nDescont	:= 0
	PRIVATE nCorrec		:= 0
	PRIVATE nJuros		:= 0
	PRIVATE nVA			:= 0
	PRIVATE cPadrao		:= "520"
	PRIVATE cBord110	:= CriaVar("E1_NUMBOR")
	PRIVATE cBcoDe		:= CriaVar("E1_PORTADO")
	PRIVATE cBcoAte		:= CriaVar("E1_PORTADO")
	PRIVATE cPortado	:= CriaVar("E1_PORTADO")
	PRIVATE dVencIni	:= dDataBase
	PRIVATE dVencFim	:= dDataBase
	PRIVATE cMarca		:= GetMark()
	PRIVATE nTotAbat	:= 0			// Utilizada por Fa070Data
	PRIVATE dBaixa 		:= dDataBase	// Utilizada por Fa070Data
	PRIVATE dDtCredito 	:= dBaixa		// Utilizada por Fa070Data
	PRIVATE cBanco		:= cBco110
	PRIVATE cAgencia	:= cAge110
	PRIVATE cConta		:= cCta110

	Static oGetDados

	Static oDlg

	For nX := 1 to Len(aFields)
		Aadd(aHeaderEx, {AllTrim(GetSx3Cache(aFields[nX],"X3_TITULO")),;
			GetSx3Cache(aFields[nX],"X3_CAMPO"),;
			GetSx3Cache(aFields[nX],"X3_PICTURE"),;
			GetSx3Cache(aFields[nX],"X3_TAMANHO"),;
			GetSx3Cache(aFields[nX],"X3_DECIMAL"),;
			GetSx3Cache(aFields[nX],"X3_VALID"),;
			GetSx3Cache(aFields[nX],"X3_USADO"),;
			GetSx3Cache(aFields[nX],"X3_TIPO"),;
			GetSx3Cache(aFields[nX],"X3_F3"),;
			GetSx3Cache(aFields[nX],"X3_CONTEXT"),;
			GetSx3Cache(aFields[nX],"X3_CBOX"),;
			GetSx3Cache(aFields[nX],"X3_RELACAO")})
	Next nX
	aadd(aHeaderEx,{"Registro","_REG"," ",8,0,"","","N","","","",""})

	oPanelDados := FinWindow:GetVisPanel()

	nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 150) /2
	nEspLin  := 0


	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,40,40,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 002,002+nEspLarg TO 150,160+nEspLarg PIXEL OF oPanel

	@ 004,005+nEspLarg SAY "Vencimento" SIZE 40,08 PIXEL OF oPanel //
	@ 013,005+nEspLarg MSGET dVencIni SIZE 45,08  PIXEL OF oPanel HASBUTTON
	@ 013,060+nEspLarg SAY "at‚ " SIZE 10,08  PIXEL OF oPanel // ""
	@ 013,080+nEspLarg MSGET dVencFim Valid dVencFim >= dVencIni SIZE 50,08  PIXEL OF oPanel HASBUTTON

	@ 023,005+nEspLarg SAY "Cliente " SIZE 40,08 PIXEL OF oPanel //
	@ 032,005+nEspLarg MSGET cCliDe	F3 "CLI"  SIZE 45,08 Picture PesqPict("SA1","A1_COD",Len(cCliDe)) PIXEL OF oPanel HASBUTTON
	@ 032,060+nEspLarg SAY "at‚ " SIZE 10,08  PIXEL OF oPanel //
	@ 032,080+nEspLarg MSGET cCliAte	F3 "CLI" VALID cCliAte >= cCliDe SIZE 45,08 Picture PesqPict("SA1","A1_COD",Len(cCliAte)) PIXEL OF oPanel HASBUTTON

	@ 042,005+nEspLarg SAY "Mot.Baixa" SIZE 40,08  PIXEL OF oPanel //
	@ 051,005+nEspLarg COMBOBOX oCbx VAR cMotBx ;
		ITEMS aDescMotBx SIZE 65, 47  PIXEL OF oPanel ;
		Valid F110BXBORD(.T.) .And. (ShowMotBx("R",.T.))

	@ 072,005+nEspLarg Say "Banco : " SIZE 30,08  PIXEL OF oPanel  //
	@ 081,005+nEspLarg MSGET oBanco110 VAR cBco110 F3 cF3Bco When MovBcoBx(cMotBx, .T.) Valid (CarregaSa6(@cBco110, @cAge110, @cCta110, .T.,,,,,.T., @cOldBanco, @cOldAgenc) .And. IIF(lJFilBco, JurVldSA6("1", {cEscrit, cBco110, cAge110, cCta110}), .T.)) SIZE 30,08  PIXEL OF oPanel HASBUTTON
	@ 072,040+nEspLarg Say "Agência : " SIZE 30,08  PIXEL OF oPanel //
	@ 081,040+nEspLarg MSGET cAge110 When MovBcoBx(cMotBx, .T.) Valid (CarregaSa6(@cBco110, @cAge110, @cCta110, .T.,,,,,.T., @cOldBanco, @cOldAgenc) .And. IIF(lJFilBco, JurVldSA6("2", {cEscrit, cBco110, cAge110, cCta110}), .T.)) SIZE 30,08 PIXEL OF oPanel HASBUTTON
	@ 072,080+nEspLarg Say "Conta : " SIZE 30,08  PIXEL OF oPanel //
	@ 081,080+nEspLarg MSGET cCta110 When MovBcoBx(cMotBx, .T.) Valid If(CarregaSa6(@cBco110,@cAge110,@cCta110,.T.,,.T.,,,.T., @cOldBanco, @cOldAgenc),.T.,oBanco110:SetFocus() .And. IIF(lJFilBco, JurVldSA6("3", {cEscrit, cBco110, cAge110, cCta110}), .T.)) PIXEL OF oPanel SIZE 60,08 HASBUTTON


	@ 092,005+nEspLarg SAY "Border“" SIZE 40,08  PIXEL OF oPanel	//
	@ 101,005+nEspLarg MSGET cBord110 Picture "@S6" SIZE 65,08 PIXEL OF oPanel ;
		Valid F110BXBORD(.T.) .and. Iif(!MovBcoBx(cMotBx, .T.),Empty(cBord110),.T.)	HASBUTTON

	@ 092,080+nEspLarg SAY "Lote"  PIXEL OF oPanel SIZE 40,08 //
	@ 101,080+nEspLarg MSGET cLoteFin Picture "@!" When !Empty(cBord110) .And. lBxCnab  Valid CheckLote("R")  SIZE 60,08 PIXEL OF oPanel HASBUTTON

	@ 115,005+nEspLarg SAY "Data Baixa"  PIXEL OF oPanel SIZE 40,08 //
	@ 125,005+nEspLarg MSGET dBaixa Picture "@S6" SIZE 65,08 PIXEL OF oPanel HASBUTTON ;





	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)


	DEFINE MSDIALOG oDlg TITLE ":::... Baixas Contas Receber Eurofins ...:::" FROM 000, 000  TO 600, 1020 COLORS 0, 16777215 PIXEL

	oGetDados := MsNewGetDados():New( 005, 005, 255, 505, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

	@ 260, 005 GROUP oGroup1 TO 296, 506 OF oDlg COLOR 0, 16777215 PIXEL
	@ 269, 010 BUTTON oBInvert PROMPT "Inverter Seleção" SIZE 072, 018 OF oDlg PIXEL
	@ 269, 349 BUTTON oBConf PROMPT "Confirmar" SIZE 072, 018 OF oDlg PIXEL
	@ 269, 089 BUTTON oBVisual PROMPT "Visualizar Titulo" SIZE 072, 018 OF oDlg PIXEL
	@ 269, 428 BUTTON oBCanc PROMPT "Cancelar" SIZE 072, 018 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return


