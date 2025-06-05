#include "totvs.ch"
/*/{protheus.doc} RVARCAM
Relatorio de Variação Cambial Calculada
@author Sergio Braz
@since 18/04/19
/*/
User Function RVarCam
	If AskMe()
		GetData()
		Processa({|| ExpExcel()})
		E5->(DbCloseArea())
	Endif
Return
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetData
	Local cWhere := ""

	If Left(MV_PAR03,1) = 'R'
		cWhere := "%E5_RECPAG in ('R')%"
	ElseIf Left(MV_PAR03,1) = 'P'
		cWhere := "%E5_RECPAG in ('P')%"

	Else
		cWhere := "%E5_RECPAG in ('P','R')%"

	Endif
// E5_RECPAG = %Exp:Left(MV_PAR03,1)%
	BeginSql Alias "E5"
		Select E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_NATUREZ,E5_MOEDA,Sum(E5_VALOR) E5_VALOR, E5_RECPAG
		From %Table:SE5% SE5
		Where %NotDel% and E5_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02% and
			E5_TIPODOC = 'VM' and
            %Exp:cWhere% and E5_DATA = %Exp:MV_PAR04%
		Group By E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_NATUREZ,E5_MOEDA, E5_RECPAG
		Order By E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA
	EndSql
Return
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function AskMe
	Local aPergs := {}
	Local aCart  := {"Receber","Pagar","Ambos"}
	AADD(aPergs,{1,"Da filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{1,"Ate filial",CriaVar("E1_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
	AADD(aPergs,{2,"Carteira",aCart[1],aCart,70,'.t.',.f.})
	AADD(aPergs,{1,"Data ",Ctod(''),,'.t.',,'.T.',70,.F.})
Return ParamBox(aPergs,"Parametros",{})
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function ExpExcel
	Local oExcel               := FWMSExcel():New()
	Local cFile                := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local cFields              := "E5->E5_FILIAL;E5->E5_PREFIXO;E5->E5_NUMERO;E5->E5_PARCELA;E5->E5_TIPO;E5->E5_CLIFOR;"+;
		"E5->E5_LOJA;SE1->E1_NOMCLI;E5->E5_NATUREZ;SED->ED_DESCRIC;E5->E5_RECPAG;SE1->E1_EMISSAO;SE1->E1_VENCTO;SE1->E1_VENCREA;"+;
		"SE1->E1_VALOR;E5->E5_MOEDA;cDescMoeda;SE1->E1_VLCRUZ;SE1->E1_SALDO;Transform(SE1->E1_TXMOEDA, '@E 999,999.9999' );SE1->E1_DTVARIA;"+;
		"Transform(SE1->E1_TXMDCOR, '@E 999,999.9999' );E5->E5_VALOR;((SE1->E1_SALDO*SE1->E1_TXMDCOR)*nInv);SA2->A2_CONTA"
	Local cTitles              := "Filial,Pref.,Titulo,Parc.,Tipo,Cliente/Fornecedor,Loja,Razao Social,Cod.Nat.,Desc.Natureza,Rec/Pag,"+;
		"Emissao,Vencimento,Venc.Real,Valor Parc.,Moeda,Desc.Moeda,Vlr.R$.,Saldo,Tx.Moeda,Dt.Variac.,Tx.Variacao,Calc.Variacao,Saldo Contábil,Cnt.Ctb Forn."
	Local aFields
	local aValores
	Local cPlan                := "Variacao Cambial"
	Local cTable               := iif(MV_PAR03 == "Ambos","Contas a Pagar e a Receber" ,"Contas a "+Capital(MV_PAR03))
	Local cInverte
	local i                    := 0
	Private nInv               := 1
	Private cAlias, cDescMoeda := ""

	Count to nRegs
	ProcRegua(nRegs)
	E5->(DbGoTop())
	// If Left(MV_PAR03,1)$"R"
	// 	cAlias := "SE1"
	// 	cFields := StrTran(cFields,"A2","A1")
	// Else
	// 	cAlias := "SE2"
	// 	cFields := StrTran(cFields,"SE1->E1_","SE2->E2_")
	// 	cFields := StrTran(cFields,"NOMCLI","NOMFOR")
	// Endif
	aFields := StrToKarr(cFields,";")
	aTitles := StrToKarr(cTitles,",")
	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan,cTable)
	For i:=1 To Len(aFields)
		If ValType(&(aFields[i])) == "D"
			nAlign := 2
			nType  := 4
		ElseIf ValType(&(aFields[i])) == "N" .or. 'Transform'$aFields[i]
			nAlign := 3
			nType  := 2
		Else
			nAlign := 1
			nType  := 1
		Endif
		oExcel:AddColumn(cPlan,cTable,aTitles[i],nAlign,nType,.f.)
	Next
	While E5->(!Eof())
		aValores := {}

		If Left(E5->E5_RECPAG,1)$"R"
			cAlias := "SE1"
			cFields := StrTran(cFields,"A2","A1")
			cFields := StrTran(cFields,"SE2->E2_","SE1->E1_")
			cFields := StrTran(cFields,"NOMFOR","NOMCLI")
		Else
			cAlias := "SE2"
			cFields := StrTran(cFields,"A1","A2")
			cFields := StrTran(cFields,"SE1->E1_","SE2->E2_")
			cFields := StrTran(cFields,"NOMCLI","NOMFOR")
		Endif
		aFields := StrToKarr(cFields,";")

		If cAlias=="SE1"
			Posicione("SE1",2,E5->(E5_FILIAL+E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"")
			Posicione("SA1",1,xFilial("SA1")+E5->(E5_CLIFOR+E5_LOJA),"")
			cInverte := MVRECANT+'|'+MV_CRNEG+'|'+MVABATIM
		Else
			Posicione("SE2",1,E5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA),"")
			Posicione("SA2",1,xFilial("SA2")+E5->(E5_CLIFOR+E5_LOJA),"")
			cInverte := MVPAGANT+'|'+MV_CPNEG+'|'+MVABATIM
		Endif
		nInv       := IIF(E5->E5_TIPO$cInverte,-1,1)
		Posicione("SED",1,xFilial("SED")+E5->E5_NATUREZ,"")
		cDescMoeda := AllTrim(GetMV("MV_MOEDA"+cValToChar(Val(E5->E5_MOEDA))))
		dEmisTit   := cTod("")

		lSE2FilCom := Empty(FwXFilial("SE2"))
		lSE5FilCom := Empty(FwXFilial("SE5"))

		For i:=1 to Len(aFields)
			If "_EMISSAO" $ aFields[i]
				dEmisTit := &(aFields[i])
			EndIf


			If "_TXMDCOR)*nInv)" $ aFields[i]

				nSaldo     := 0
				nTaxaDia   := 0
				cFilSE5    := E5->E5_FILIAL
				dDataReaj  := MV_PAR04
				If cAlias == "SE2"
					lCmpMulFil := .F.

					lSemTaxaM2 := (nTaxaDia := Iif(!Empty(SE2->E2_TXMOEDA),SE2->E2_TXMOEDA,RecMoeda(dDataReaj,SE2->E2_MOEDA))) == 0
					nSaldo     := SaldoTit(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, "P", SE2->E2_FORNECE, SE2->E2_MOEDA ,dDataReaj,, SE2->E2_LOJA,,;
						Iif(lSemTaxaM2,1,nTaxaDia), 1,,, Nil, @lCmpMulFil)

					If lCmpMulFil .And. !lSE2FilCom .And. !lSE5FilCom
						nSaldo -= FRVlCompFil("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,1,,,,1,SE2->E2_MOEDA,If(lSemTaxaM2,1,nTaxaDia),dDataReaj,.T.)
					EndIf

					If !(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) .And. !(SE2->E2_TIPO $ MVABATIM) .And. !(SE2->E2_TIPO $ MVPAGANT+"/"+MVPROVIS+"/"+MV_CPNEG) .and. nSaldo > 0
						nSaldo -= SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataReaj,SE2->E2_FORNECE,SE2->E2_LOJA)
					EndIf
                    nSaldo :=  ((nSaldo*SE2->E2_TXMDCOR)*nInv)
				Else

					nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataReaj,;
						dDataReaj, SE1->E1_LOJA, , 1, 1)
                    nSaldo :=  ((nSaldo*SE1->E1_TXMDCOR)*nInv)
				EndIf

				aAdd(aValores,nSaldo)
			ElseIf "_TXMOEDA" $ aFields[i]
				If Empty(&(aFields[i]))
					nTaxaDia := RecMoeda(dEmisTit,Val(E5->E5_MOEDA))
				Else
					nTaxaDia := &(aFields[i])
				EndIf
				aAdd(aValores,nTaxaDia)
			Else
				aAdd(aValores,&(aFields[i]))
			EndIf
		Next
		oExcel:AddRow(cPlan,cTable,aValores)
		E5->(DbSkip())
		IncProc()
	End
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	If File(cFile)
		ShellExecute("Open",cFile,"","",1)
	Endif
Return
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function otpx
	RpcSetEnv("01","0100","admin","agis3","FIN")
	define msdialog omainwnd from 0,0 to 800,1300 pixel
	@ 05,05 button "ok" of omainwnd pixel action u_rvarcam()
	activate msdialog omainwnd
Return
