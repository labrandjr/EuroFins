#include "totvs.ch"
#include "topconn.ch"
#Include 'TBICONN.ch'
#include 'protheus.ch'
#include 'parmtype.ch'

#Define INVBanco  37
#Define INVAgen   38
#Define INVConta  39
#Define ValoTit   17
#Define ValoReais 19
#Define Taxa      32
#Define Contrato  33
#Define Filial    2

/*/{protheus.doc} BXINVOICE
Rotina que ira ler arquivo CSV/TXT separado por ;
Baixar o título a pagar automaticamente.
@author Régis Ferreira
@since 21/09/21
/*/

User Function BXINVOICE()

	Local cDir              := ""
	Local aArea             := GetArea()
	Local aAreaSE2          := SE2->(GetArea())
	Local cTexto            := "Este Programa tem o objetivo de ler o arquivo txt/csv preenchido "+;
		"pela corretora e fazer a baixa dos títulos. "+;
		"Carregar Títulos?"
	Private cBanco          := ""
	Private oBrowse
	Private cFilBKP         := cFilAnt
	Private cEmpBKP         := cEmpAnt
	Private cNumEmpBKP      := cNumEmp
	Private dDataBx         := dDataBase
	Private oProcess		:= Nil
	Private cFonte          := "BXINVOICE"
	Private cProblema       := ""
	Private cSolucao        := ""
	Private lBaixar         := .T.
	Private aReadCSV        := {}
	Private oDlg            := IIf(Type("cFilAnt")=="U",RpcSetEnv("01","0100"),Nil)

	If !MsgYesNo(cTexto,"Baixas Automáticas de Invoices!")
		Return
	Endif

	cDir:=cGetFile("*.CSV|*.CSV",,0,"C:\",.F., GETF_LOCALHARD,.F.)

	If Empty(cDir)
		Return
	Endif
	if cDir == "C:\"
		Alert("Não deve ser salvo arquivos no C:\")
		Return
	endif

	//Rotina para ler arquivo txt/csv
	LerCSV(cDir)

	dDataBase := dDataBx
	MontaTela()

	cFilAnt := cFilBKP
	cEmpAnt := cEmpBKP
	cNumEmp := cEmpBKP + cFilBKP
	OpenFile(cNumEmp)

	dDataBase := dDataBx

	RestArea(aAreaSE2)
	RestArea(aArea)

Return


/*/{protheus.doc} LerCSV
Rotina que ira ler arquivo CSV/TXT separado por ;
@author Régis Ferreira
@since 21/09/21
/*/
Static Function LerCSV(cDirArq)

	Local lPrimeiro     := .T.
	Local cLineRead     := ""
	Local aArqCSV       := {}
	Local cAuxFil       := ""
	Local lContinua     := .T.
	Local nContrato     := 0

	Private nTotalF     := 0
	Private nTotalV     := 0

	fT_fUse(cDirArq)

	fT_fGotop()

	While !fT_fEof()


		cLineRead := fT_fReadLn()
		If !Empty(cLineRead)

			//Caso seja a primeira linha, não gravado o arquivo por ser o cabeçalho.
			If !lPrimeiro
				//Para evitar que venha erros do EXCEL, verifico se os primeiros registros são ;;;;;
					if left(Alltrim(cLineRead),6) <> ";;;;;"
					//Limpa alguns caracteres no arquivo CSV para deixar os valores corretos.
					cLineRead           := replace(cLineRead,"; ",";")
					cLineRead           := replace(cLineRead," ;",";")
					cLineRead           := replace(cLineRead,";  ","0,00")
					aArqCSV             := StrTokArr2(".T.;"+cLineRead,";",.T.)
					aArqCSV[1]          := .T.
					aArqCSV[ValoTit]    := Replace(aArqCSV[ValoTit]," ","")
					aArqCSV[ValoTit]    := Replace(aArqCSV[ValoTit],".","")
					aArqCSV[ValoReais]  := Replace(aArqCSV[ValoReais]," ","")
					aArqCSV[ValoReais]  := Replace(aArqCSV[ValoReais],".","")
					aArqCSV[Taxa]       := Replace(aArqCSV[Taxa]," ","")
					aArqCSV[Taxa]       := Replace(aArqCSV[Taxa],".","")
					aArqCSV[ValoTit]    := Replace(aArqCSV[ValoTit],",",".")
					aArqCSV[ValoReais]  := Replace(aArqCSV[ValoReais],",",".")
					aArqCSV[Taxa]       := Replace(aArqCSV[Taxa],",",".")
					aArqCSV[ValoTit]    := Val(aArqCSV[ValoTit])
					aArqCSV[ValoReais]  := Val(aArqCSV[ValoReais])
					aArqCSV[Taxa]       := Val(aArqCSV[Taxa])

					if Empty(cAuxFil) .or. Alltrim(cAuxFil) != Alltrim(aArqCSV[Filial]) .or. Empty(cBanco)

						cfilAnt := Alltrim(aArqCSV[Filial])

						//Busca os bancos a serem usados
						if PergBanc(aArqCSV[Filial])
							cAuxFil := aArqCSV[Filial]
							cBanco  := Padr(MV_PAR01,tamSx3("A6_COD")[1])
						else
							lContinua := .F.
						endif
					endif
					if lContinua
						if !Empty(cBanco)
							aadd(aArqCSV,Padr(MV_PAR01,tamSx3("A6_COD")[1]))
							aadd(aArqCSV,Padr(MV_PAR02,tamSx3("A6_AGENCIA")[1]))
							aadd(aArqCSV,Padr(MV_PAR03,tamSx3("A6_NUMCON")[1]))
							cBanco := Padr(MV_PAR01,tamSx3("A6_COD")[1])
						endif
						if !Empty(aArqCSV)
							aadd( aReadCSV , aArqCSV )
						endif
					endif
				endif
			Else
				lPrimeiro := .F.
			Endif
		Endif

		//o Arquivo deve ter no mínimo 35 colunas (arquivo + bancos selecionados)
		if Len(aArqCSV) <=35 .and. !lPrimeiro .and. !Empty(aArqCSV)
			Alert("O arquivo para importação deve ter no mínimo 35 colunas, revise as colunas","Importação Abortada")
			Return
		endif
		fT_fSkip()

	Enddo

	fT_fUse()

	for nContrato := 1 to len(aReadCSV)

		if Empty(aReadCSV[nContrato,33]) .and. aReadCSV[nContrato,14] <> "1"
			MsgStop("Existem títulos sem contrato."+CRLF+"Preencha os contratos", "Importação abortada.")
			Return
		endif

	Next nContrato

	cFilAnt := cFilBKP
	cEmpAnt := cEmpBKP
	cNumEmp := cEmpBKP + cFilBKP
	OpenFile(cNumEmp)

Return


/*/{protheus.doc} MontaTela
Rotina que ira demonstrar aos usuários os dados lidos no arquivo CSV
Baixar o título a pagar automaticamente.
@author Régis Ferreira
@since 21/09/21
/*/
Static Function MontaTela()

	Local oNo	        := LoadBitmap( GetResources(), "LBNO" )
	Local oOk	        := LoadBitmap( GetResources(), "LBOK" )
	Local aCabec        := {"Ok","Filial","Company","C. Custo","Invoice","Título","Tipo","Valor Original","Valor","Valor Em Reais","Taxa","Contrato","Banco","Agência","Conta","Histórico","Natureza","Descrição","Fornecedor","Nome Fant.","Razão Social","Moeda","Descrição","Data Invoice","ISS", "Pis","Cofins","Irrf","Cide","IOF","Desp. Corretagem","Total Em Reais","Vencimento","Vencimento Real","País","Data Contabil"}
	Local aScreenRes    := MsAdvSize() //Resolução do monitor
	Local nValor        := 0
	Local nI            := 0
	Local oFont         := TFont():New('Courier new',,-18,.T.)

	//Soma o valor total dos títulos
	for nI := 1 to len(aReadCSV)
		nValor += aReadCSV[nI,19]
	Next nI

	If !Empty(aReadCSV)
		Define MsDialog oDlg From 0,0 to aScreenRes[6],aScreenRes[5] Pixel Font tFont():New("Arial",,20)
		@ 010,010 button "Marca Todos"      of oDlg Size 60,10 Pixel Action Marca(.t.)	Font tFont():New("Arial",,18)
		@ 010,090 button "Inverte"          of oDlg Size 60,10 Pixel Action Marca(.f.)	Font tFont():New("Arial",,18)
		@ 010,170 button "Baixar Invoices"  of oDlg Size 60,10 Pixel Action (xBxInv()) Font tFont():New("Arial",,18)
		@ 010,250 button "Cancelar"         of oDlg Size 60,10 Pixel Action oDlg:End() Font tFont():New("Arial",,18)
		@ 025,010 Say    "Título(s): "+Alltrim(Transform(len(aReadCSV),"@E 99,999.99"))+" - Total de Título(s): "+Alltrim(Transform(nValor,"@E 999,999,999.99")) of oDlg Size 500,10 FONT oFont Pixel
		oBrowse := TCBrowse():New(40,01,aScreenRes[6]-(0.07*aScreenRes[6]),aScreenRes[5]-(0.80*aScreenRes[5]),,aCabec,{10,20,30,30,50,30,20,70,30,50,30,50,70},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oBrowse:SetArray(aReadCSV)
		oBrowse:bLine := {|| {IIf(  aReadCSV[oBrowse:nAt,1],oOk,oNo),;
			aReadCSV[oBrowse:nAt,2],;                                           //Filial
		aReadCSV[oBrowse:nAt,3],;                                           //Company
		aReadCSV[oBrowse:nAt,4],;                                           //C. Custo
		aReadCSV[oBrowse:nAt,5],;                                           // Invoice
		aReadCSV[oBrowse:nAt,6],;                                           // Título
		aReadCSV[oBrowse:nAt,7],;                                           // Tipo
		aReadCSV[oBrowse:nAt,16],;                                          // Valor Original
		Alltrim(Transform(aReadCSV[oBrowse:nAt,17], "@E 999,999,999.99")),; // Valor
		Alltrim(Transform(aReadCSV[oBrowse:nAt,19], "@E 999,999,999.99")),; //Valor em Reais
		Alltrim(Transform(aReadCSV[oBrowse:nAt,32], "@E 99.99999")),;       // Taxa
		aReadCSV[oBrowse:nAt,33],;                                          //Contrato
		aReadCSV[oBrowse:nAt,37],;                                          //Banco
		aReadCSV[oBrowse:nAt,38],;                                          //Agencia
		aReadCSV[oBrowse:nAt,39],;                                          //Conta
		aReadCSV[oBrowse:nAt,8],;                                           // Histórico
		aReadCSV[oBrowse:nAt,9],;                                           // Natureza
		aReadCSV[oBrowse:nAt,10],;                                          //Descrição
		aReadCSV[oBrowse:nAt,11],;                                          // Fornecedor
		aReadCSV[oBrowse:nAt,12],;                                          // nome Fantasia
		aReadCSV[oBrowse:nAt,13],;                                          //Razão Social
		aReadCSV[oBrowse:nAt,14],;                                          //Moeda
		aReadCSV[oBrowse:nAt,15],;                                          //Descrição
		aReadCSV[oBrowse:nAt,18],;                                          //Data Invoice
		aReadCSV[oBrowse:nAt,20],;                                          //ISS
		aReadCSV[oBrowse:nAt,21],;                                          //Pis
		aReadCSV[oBrowse:nAt,22],;                                          //Cofins
		aReadCSV[oBrowse:nAt,23],;                                          //IRRF
		aReadCSV[oBrowse:nAt,24],;                                          //CIDe
		aReadCSV[oBrowse:nAt,25],;                                          //IOF
		aReadCSV[oBrowse:nAt,26],;                                          //Desp Corretagem
		aReadCSV[oBrowse:nAt,27],;                                          //Total Em Reais
		aReadCSV[oBrowse:nAt,28],;                                          //Vencimento
		aReadCSV[oBrowse:nAt,29],;                                          //Vencimento Real
		aReadCSV[oBrowse:nAt,30],;                                          //Pais
		aReadCSV[oBrowse:nAt,31],;                                          // Data Contabil
		aReadCSV[oBrowse:nAt,34],;                                          // Prefixo
		aReadCSV[oBrowse:nAt,35],;                                          // Parcela
		aReadCSV[oBrowse:nAt,36]} }                                         // LOJA

		oBrowse:bLDblClick   := {|| muda()}
		Activate MsDialog oDlg Centered
	Else
		MsgInfo("<h5>Não há dados a processar com esses parâmetros.</h5>",FunName())
	Endif

Return


/*/{protheus.doc} muda
Função que muda as opções marcadas na tela do usuário
@author Régis Ferreira
@since 21/09/21
/*/
static function muda
	If oBrowse:ColPos ==1
		aReadCSV[oBrowse:nAt,1] := !aReadCSV[oBrowse:nAt,1]
	ElseIf oBrowse:ColPos==9
		aReadCSV[oBrowse:nAt,9] := FwInputBox("Email",aReadCSV[oBrowse:nAt,9])
	Endif
	oBrowse:Refresh()
return

/*/{protheus.doc} Marca
Opção para marcar todos ´titulos para o usuário
@author Régis Ferreira
@since 21/09/21
/*/
Static Function Marca(lTipo)
	Local i
	For i:=1 to Len(aReadCSV)
		aReadCSV[i,1] := IIf(lTipo,.t.,!aReadCSV[i,1])
	Next
Return


/*/{protheus.doc} PergBanc
Rotina que perguntar o usuário quais os bancos que vão ser usados nas baixas
@author Régis Ferreira
@since 21/09/21
/*/
Static Function PergBanc(cFilBanc)

	Local aPergs := {}
	AADD(aPergs,{1,"Banco: "    ,CriaVar("A6_COD",.f.)      ,"@!",'.t.',"SA6",'.T.',50,.T.}) //MV_PAR01
	AADD(aPergs,{1,"Agência: "  ,CriaVar("A6_AGENCIA",.f.)  ,"@!",'.t.',"",'.T.',50,.T.}) //MV_PAR02
	AADD(aPergs,{1,"Conta:"     ,CriaVar("A6_NUMCON",.f.)   ,"@!",'.t.',"",'.T.',50,.T.}) //MV_PAR03

Return ParamBox(aPergs,"Selecione o banco para Filial "+cFilBanc,{})


/*/{protheus.doc} BxInv
Rotina automática que faz a baixa dos títulos marcados
@author Régis Ferreira
@since 21/09/21
/*/
Static Function BxInv()

	Local nQtdtit       := 0
	Local abaixa        := {}
	Local nSeqBx        := 1    //Sequencia de baixa a ser cancelada
	Local nOpc          := 3    //Baixa
	Local lExibeLanc    := .F.  //Exibe lançamento
	Local lOnline       := .T.
	Local cHist         := ""
	Local nRegs         := len(aReadCSV)
	Local cErroTit      := ""
	local aCabErro         := {}
	local aErro         := {}
	Private lMsErroAuto := .F.
	Public cContrSE2    := ""

	DbSelectArea("SE2")
	SE2->(dbSetOrder(1))

	aAdd(aCabErro, {"Filial"})
	aAdd(aCabErro, {"Prefixo"})
	aAdd(aCabErro, {"Numero"})
	aAdd(aCabErro, {"Tipo"})
	aAdd(aCabErro, {"Parcela"})
	aAdd(aCabErro, {"Problema"})
	aAdd(aCabErro, {"Solucao"})
	aAdd(aCabErro, {"Erro"})



	oProcess:SetRegua1(nRegs)

	Begin Transaction

		for nQtdtit := 1 to len(aReadCSV)

			if Alltrim(cFilAnt) <> aReadCSV[nQtdtit,2]
				//Troca a filial
				cFilAnt := aReadCSV[nQtdtit,2]
				cEmpAnt := cEmpBKP
				cNumEmp := cEmpAnt + cFilAnt
				OpenFile(cNumEmp)
				//cFilant := aReadCSV[nQtdtit,2]
				dDataBase := dDataBx
			endif

			oProcess:IncRegua1("Filial "+cFilAnt+" - "+SM0->M0_FILIAL)
			lBaixar := .T.
			if lBaixar

				//Somente baixa o que tem o X marcado na tela
				if aReadCSV[nQtdtit,1]

					//Rotina automática que faz a baixa
					SE2->(dbSetOrder(1))
					if SE2->(DbSeek(aReadCSV[nQtdtit,2] + Padr(aReadCSV[nQtdtit,34],tamSx3("E2_PREFIXO")[1]) + padr(aReadCSV[nQtdtit,6],tamSx3("E2_NUM")[1]) + padr(aReadCSV[nQtdtit,35],tamSx3("E2_PARCELA")[1])+Padr(aReadCSV[nQtdtit,7],tamSx3("E2_TIPO")[1])+Padr(aReadCSV[nQtdtit,11],tamSx3("E2_FORNECE")[1])+Padr(aReadCSV[nQtdtit,36],tamSx3("E2_LOJA")[1])))

						if SE2->E2_SALDO < aReadCSV[nQtdtit,ValoTit]
							lBaixar := .F.
							cProblema := "Filial: "+SE2->E2_FILIAL+" - Núm.Tit.: "+SE2->E2_NUM+". Valor do título a baixar: "+Transform(aReadCSV[nQtdtit,ValoTit],"@E 999,999,999.99")+;
								"Saldo do Título: "+Transform(SE2->E2_SALDO,"@E 999,999,999.99") + " Não há saldo suficiente para baixar o título. Devido ao erro, nenhuma baixa será realizada, corriga o arquivo."
							cSolucao  := "Revise o arquivo a ser baixado!"
							aAdd(aErro,{SE2->E2_FILIAL,;
								SE2->E2_PREFIXO,;
								SE2->E2_NUM,;
								SE2->E2_TIPO,;
								SE2->E2_PARCELA,;
								cProblema,;
								cSolucao,;
								"",;
								.F.})
							// Exit
						endif

						if lBaixar
							aBaixa := {}
							cHist := "PAGTO NF "+SE2->E2_NUM+" "+Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"A2_NOME")
							Aadd(aBaixa, {"E2_FILIAL"       , SE2->E2_FILIAL,               nil})
							Aadd(aBaixa, {"E2_PREFIXO"      , SE2->E2_PREFIXO,              nil})
							Aadd(aBaixa, {"E2_NUM"          , SE2->E2_NUM,                  nil})
							Aadd(aBaixa, {"E2_PARCELA"      , SE2->E2_PARCELA,              nil})
							Aadd(aBaixa, {"E2_TIPO"         , SE2->E2_TIPO,                 nil})
							Aadd(aBaixa, {"E2_FORNECE"      , SE2->E2_FORNECE,              nil})
							Aadd(aBaixa, {"E2_LOJA"         , SE2->E2_LOJA ,                nil})
							Aadd(aBaixa, {"AUTMOTBX"        , "DEB",                        nil})
							Aadd(aBaixa, {"AUTBANCO"        , aReadCSV[nQtdtit,INVBanco],   nil})
							Aadd(aBaixa, {"AUTAGENCIA"      , aReadCSV[nQtdtit,INVAgen],    nil})
							Aadd(aBaixa, {"AUTCONTA"        , aReadCSV[nQtdtit,INVConta],   nil})
							Aadd(aBaixa, {"AUTDTBAIXA"      , dDataBase,                    nil})
							Aadd(aBaixa, {"AUTDTCREDITO"    , dDataBase,                    nil})
							Aadd(aBaixa, {"AUTHIST"         , cHist,                        nil})
							Aadd(aBaixa, {"AUTVLRPG"        , aReadCSV[nQtdtit,ValoTit],    nil})
							Aadd(aBaixa, {"AUTTXMOEDA"      , aReadCSV[nQtdtit,Taxa],       nil})
							Aadd(aBaixa, {"E2_ZZCTCAM"      , aReadCSV[nQtdtit,Contrato],   nil})

							cContrSE2 := aReadCSV[nQtdtit,Contrato]
							//Pergunte da rotina
							pergunte("FIN080", .F.)

							oProcess:IncRegua2("Baixando Invoice - "+Alltrim(SE2->E2_NUM)+" - "+Alltrim(Str(nQtdtit))+" de "+Alltrim(Str(nRegs)))

							//Chama a execauto da rotina de baixa manual (FINA080)
							lMsErroAuto := .F.
							MsExecauto({|a,b,c,d,e,f,| FINA080(a,b,c,d,e,f)}, aBaixa, nOpc, .F., nSeqBx, lExibeLanc, lOnline)

							If lMsErroAuto
								cErroTit := GetErroTit()
								cProblema   := "Filial: "+SE2->E2_FILIAL+" - Núm.Tit.: "+SE2->E2_NUM+". " + cErroTit + " Devido ao erro, nenhuma baixa será realizada, corriga o arquivo."
								cSolucao    := "Revise o arquivo a ser baixado!"
								lBaixar := .F.

								aAdd(aErro,{SE2->E2_FILIAL,;
									SE2->E2_PREFIXO,;
									SE2->E2_NUM,;
									SE2->E2_TIPO,;
									SE2->E2_PARCELA,;
									cProblema,;
									cSolucao,;
									cErroTit,;
									.F.})

								// Exit
							EndIf
						endif
					else
						cProblema   := "Filial: "+aReadCSV[nQtdtit,2]+" - Núm.Tit.: "+aReadCSV[nQtdtit,6]+". Título que está na planilha não foi encontrado no momento da baixa! Devido ao erro, nenhuma baixa será realizada, corriga o arquivo."
						cSolucao    := "Revise Número / Prefixo / Parcela / Tipo / Fornecedor / Loja que estão no arquivo a ser baixado!"
						lBaixar     := .F.
						// Exit
						aAdd(aErro,{aReadCSV[nQtdtit,2],;
							Padr(aReadCSV[nQtdtit,34],tamSx3("E2_PREFIXO")[1]),;
							padr(aReadCSV[nQtdtit,6],tamSx3("E2_NUM")[1]),;
							Padr(aReadCSV[nQtdtit,7],tamSx3("E2_TIPO")[1]),;
							padr(aReadCSV[nQtdtit,35],tamSx3("E2_PARCELA")[1]),;
							cProblema,;
							cSolucao,;
							"",;
							.F.})

					endif
				endif
			endif
		Next nQtdtit

		// if lBaixar
		// MSGALERT("Processo Finalizado", "Baixa de Invoices" )
		// else
		// 	DisarmTransaction()
		// 	Help(NIL, NIL, cFonte, NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
		// endif

		If len(aErro) == 0
			MSGALERT("Processo Finalizado", "Baixa de Invoices" )
		Else
			FwAlertWarning("Processo finalizado com erro. Favor verifique o arquivo com log de erro.","Baixa de Invoices")
			aCols2Xls(aErro, aCabErro)
		EndIf

	End Transaction

Return


/*
Essa rotina tem a finalidade de filtrar o erro que é mostrado em tela na função MOSTRAERRO()
Ele pega o texto e retorna para a rotina tratar
*/
Static Function GetErroTit()

	Local cArqErro := "ERRO_CARGA_BXINVOICE.LOG"
	Local cMsgErro := ""

	FERASE(GetSrvProfString("Startpath","")+"\"+cArqErro)
	MostraErro(GetSrvProfString("Startpath",""),cArqErro)
	cMsgErro  := MemoRead(GetSrvProfString("Startpath","")+"\"+cArqErro)
	FERASE(GetSrvProfString("Startpath","")+"\"+cArqErro)

Return cMsgErro


Static Function xBxInv()

	oProcess:= MsNewProcess():New({|| BxInv()}, "Baixando Títulos", "...", .F.)
	oProcess:ACTIVATE()

	oDlg:End()

Return
