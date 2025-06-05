#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"


/*/{Protheus.doc} FSWIP001
Integracao Protheus com ExpenseOn
@ Cadastros de Forncedores(SA2),Centro de Custo(CTT), Conta Contábeil(CT1)
@type function
@author Luciano.Braga/Sergio
@since 05/2022
/*/
User Function FSWIP001()

	Local oBrowse 	:= Nil
	Local aParam1	:= {}
	Local aRetP1	:= {}
	Local nI		:= 0
	Local cFilter   := ""

	Private cAliasInt    := ""

	aAdd(aParam1,{3,"Integração"	,1	,{"SA2 - Fornecedores x Usuarios","CTT - Centro Custo","SED - Naturezas x Categorias.","SE2 - Contas a Pagar x Despesas"},100,"",.T. })

	For nI := 1 To Len(aParam1)
		aAdd(aRetP1,aParam1[nI][3])
	Next nI

	If  !ParamBox(aParam1/*aParametros*/,"Selecione Integracao"/*cTitle*/,@aRetP1/*aRet*/,/*bOk*/,/*aButtons*/,.T./*lCentered*/,/*nPosx*/,/*nPosy*/,/*oDlgWizard*/,/* cLoad*/,.F./* lCanSave*/,.F./*lUserSave*/)
		Return
	EndIf

	Do Case
	Case aRetP1[01]==1
		cAliasInt  	:= "SA2"
		cNmInt      := "Fornecedores x Usuarios"
		cFilter		:= "Empty(A2_MSEXP) .and. A2_TPESSOA == 'FF' "
	Case aRetP1[01]==2
		cAliasInt := "CTT"
		cNmInt      := "Centro de Custo"
		cFilter		:= "Empty(CTT_MSEXP) .and. CTT_CLASSE == '2' "
	Case aRetP1[01]==3
		cAliasInt := "SED"
		cNmInt      := "Naturezas x Categorias"
		cFilter		:= "Empty(ED_MSEXP) .and. ED_COND == 'D' .and. ED_TIPO == '2' "
	Case aRetP1[01]==4
		cAliasInt := "SE2"
		cNmInt      := "Contas a Pagar x Despesas"
		cFilter		:= "E2_XIDEXP <> '' "
	OTHERWISE
		Return
	EndCase

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasInt)
	oBrowse:SetDescription("Integracao ExpenseOn - "+cNmInt)
	oBrowse:SetFilterDefault( cFilter )
	oBrowse:DisableDetails()

	If cAliasInt ==  "SA2"
		oBrowse:AddButton( "Integra Individual","U_APIEXPI",,4,)
		oBrowse:AddButton( "Integra Geral","U_APIEXPG",,4,)
	ElseIf cAliasInt ==  "SE2"
		oBrowse:AddButton( "Integra Despesas","U_APIEXPI",,4,)
		oBrowse:AddButton( "Ativa/Desativa Integracao","U_AtDtIntSE2()",,4,)
	Else
		oBrowse:AddButton( "Integra Individual","U_APIEXPI",,4,)
	EndIf

	oBrowse:Activate()

Return()

/*/{Protheus.doc} MenuDef
Definicoes do arotina
@type function
@author Luciano.Braga
@since 05/2022
/*/
Static Function MenuDef()

	Local aRotina	:= {}

Return(aRotina)


User Function APIEXPI()

	Local lRet      := .F.
	Local aDados    := {}
	Local cMsgRet 	:= ""
	Local cStCode 	:= ""
	Local aAreaSM0	:= SM0->(GetArea())
	Local nI        := 0
	Local aParam1   := {}
	Local aRetP1    := {}
	Local cOldCadastro	:= IIf(Type('cCadastro') == "C",cCadastro,"")
	Local oIntExp   := Nil
	Local aRetFil   := {}
	Local cFilBkp   := cFilAnt

	If !ApMsgYesNo( IIf(cAliasInt  == "SE2","Confirma a consulta de despesas?", "Confirma integração do registro posicionado?"))
		Return
	EndIf

	Do Case
	Case cAliasInt  == "SA2"

		aDados    := {}
		AAdd(aDados, { SA2->A2_FILIAL, SA2->A2_COD, SA2->A2_LOJA, SA2->(RECNO()) })

		//SECTION - Ticket : 351982
		//NOTE Alterado por Leandro Cesar - 03/02/023
		//LINK http://cs.solucaocompacta.com.br/compacta/paginas/assentamento.php?idocorr=351982
		aEmpFE := {}
		If SA2->(FieldPos("A2_XEMPFLS")) > 0
			If !Empty(SA2->A2_XEMPFLS)
				aEmpFE := StrToKarr(SA2->A2_XEMPFLS,"#")
			EndIf
		EndIf

		DbSelectArea("ZZH")
		DbSetOrder(1)
		DbGoTop()

		//NOTE - alterado por Leandro Cesar - 27/02/2023
		//LINK - http://cs.solucaocompacta.com.br/compacta/paginas/assentamento.php?idocorr=364162
		//SECTION Ticket: 364162
		nRecSA2 := SA2->(Recno())
		lSucess := .T.
		//!SECTION

		While !EOF() .AND. !EMPTY(ZZH->ZZH_URL)
			lProcFil := .F.
			If aScan(aEmpFE,{|x| alltrim(x) == alltrim(ZZH->ZZH_FILPRO) }) > 0
				lProcFil := .T.
			EndIf

			If Empty(aEmpFE)
				lProcFil := .T.
			EndIf

			//!SECTION

			oIntExp   := ExpenseOn():New()

			// Posicionar na filia a ser integrada
			If oIntExp:ChkFilial( ZZH->ZZH_FILPRO ) .and. lProcFil

				lRet := oIntExp:GrvUser( aDados , ZZH->ZZH_FILPRO, @lSucess  )
				If lRet
					//ojResponse  := oIntExp:GetRetornoApi()
					aRet        := oIntExp:GetRetornoArray()
					AAdd(aRetFil, aRet)
				Else
					cMsgRet 	:= oIntExp:GetErro()
					cStCode 	:= oIntExp:GetStatusCode()
					Alert(cMsgRet + " " +cStCode+" - Organização: "+SM0->M0_NOME)
				EndIf


			EndIf

			FreeObj(oIntExp)

			DbSelectArea("ZZH")
			ZZH->( DbSkip() )

		EndDo

		//NOTE - alterado por Leandro Cesar - 27/02/2023
		//LINK - http://cs.solucaocompacta.com.br/compacta/paginas/assentamento.php?idocorr=364162
		//SECTION Ticket: 364162
		If !lSucess
			dbSelectArea("SA2")
			SA2->(dbGoto(nRecSA2))
			SA2->(Reclock("SA2",.F.))
			SA2->A2_MSEXP := ""
			SA2->(Msunlock())
		EndIf
		//!SECTION
		If Len(aRetFil) > 0
			TelaLog("SA2",aRetFil,cOldCadastro,.f.)
		EndIf

		RestArea(aAreaSM0)
		cFilAnt := cFilBkp


	Case cAliasInt  == "CTT"

		DbSelectArea("ZZH")
		DbSetOrder(1)
		DbGoTop()

		aDados    := {}
		AAdd(aDados, { CTT->CTT_FILIAL, CTT->CTT_CUSTO , CTT->(RECNO()) })

		While !EOF() .AND. !EMPTY(ZZH->ZZH_URL)
			// Posicionar na filia a ser integrada

			oIntExp   := ExpenseOn():New()

			// Posicionar na filia a ser integrada
			If oIntExp:ChkFilial( ZZH->ZZH_FILPRO )

				lRet := oIntExp:GrvCCusto( aDados, ZZH->ZZH_FILPRO )
				If lRet
					//ojResponse  := oIntExp:GetRetornoApi()
					aRet        := oIntExp:GetRetornoArray()
					AAdd(aRetFil, aRet)
				Else
					cMsgRet 	:= oIntExp:GetErro()
					cStCode 	:= oIntExp:GetStatusCode()
					Alert(cMsgRet + " " +cStCode)
				EndIf

			EndIf

			FreeObj(oIntExp)

			DbSelectArea("ZZH")
			ZZH->( DbSkip() )

		EndDo

		If Len(aRetFil) > 0
			TelaLog("CTT",aRetFil,cOldCadastro,.f.)
		EndIf

		RestArea(aAreaSM0)
		cFilAnt := cFilBkp

	Case cAliasInt  == "SED"

		DbSelectArea("ZZH")
		DbSetOrder(1)
		DbGoTop()

		aDados    := {}
		AAdd(aDados, { SED->ED_FILIAL, SED->ED_CODIGO , SED->(RECNO())})

		While !EOF() .AND. !EMPTY(ZZH->ZZH_URL)

			oIntExp   := ExpenseOn():New()

			If oIntExp:ChkFilial( ZZH->ZZH_FILPRO )

				lRet := oIntExp:GrvCategoria( aDados,ZZH->ZZH_FILPRO)
				If lRet
					//ojResponse  := oIntExp:GetRetornoApi()
					aRet        := oIntExp:GetRetornoArray()
					AAdd(aRetFil, aRet)
				Else
					cMsgRet 	:= oIntExp:GetErro()
					cStCode 	:= oIntExp:GetStatusCode()
					Alert(cMsgRet + " " +cStCode)
				EndIf

			EndIf

			FreeObj(oIntExp)
			DbSelectArea("ZZH")
			ZZH->( DbSkip() )

		EndDo

		If Len(aRetFil) > 0
			TelaLog("SED",aRetFil,cOldCadastro,.f.)
		EndIf

		RestArea(aAreaSM0)
		cFilAnt := cFilBkp

	Case cAliasInt  == "SE2"

		aAdd(aParam1,{1,"Dt. Inicio"	,date() - 30,PesqPict("SE2","E2_EMISSAO"),"","",""	,50,.T.})
		aAdd(aParam1,{1,"Dt. Fim"		,date() + 30,PesqPict("SE2","E2_EMISSAO"),"","",""	,50,.T.})
		aAdd(aParam1,{3,"Integração"	,1	,{"Adiantamento","Relatorio"},100,"",.T. })

		For nI := 1 To Len(aParam1)
			aAdd(aRetP1,aParam1[nI][3])
		Next nI

		If ParamBox(aParam1/*aParametros*/,"Integracao Despesas"/*cTitle*/,@aRetP1/*aRet*/,/*bOk*/,/*aButtons*/,.T./*lCentered*/,/*nPosx*/,/*nPosy*/,/*oDlgWizard*/,/* cLoad*/,/* lCanSave*/,/*lUserSave*/)
			If aRetP1[03] == 1 // Adiantamentos
				FwMsgRun(,{|| U_IntegraPA(aRetP1[01], aRetP1[02],.f.) },"Integrando Adiantamentos","Integração ExpenseOn")
			ElseIf aRetP1[03] == 2 // Relatorio de Titulos a Pagar
				FwMsgRun(,{|| U_IntegraDP(aRetP1[01], aRetP1[02],.f.) },"Integrando Despesas","Integração ExpenseOn")
			EndIf
		EndIf

		RestArea(aAreaSM0)
		cFilAnt := cFilBkp

	EndCase

Return


User Function APIEXPG()

	If !ApMsgYesNo( "Confirma integração de todos os registros ?")
		Return
	EndIf

	Do Case
	Case cAliasInt  == "SA2"
		FwMsgRun(,{|| U_IntegraSA2(.f.) },"Integrando Fornecedores (Usuarios)","Integração ExpenseOn")
	Case cAliasInt  == "CTT"
		FwMsgRun(,{|| IntegraCTT() },"Integrando Centro Custo","Integração ExpenseOn")
	Case cAliasInt  == "SED"
		FwMsgRun(,{|| IntegraSED() },"Integrando Naturezas (Categorias)","Integração ExpenseOn")
	EndCase

Return


User Function IntegraSA2(lJob)

	Local lRet      := .F.
	Local aDados    := {}
	Local cMsgRet 	:= ""
	Local cStCode 	:= ""
	Local aAreaSM0	:= SM0->(GetArea())
	Local cOldCadastro	:= ""
	Local oIntExp   := Nil
	Local cQuery    := ""
	Local cAlias 	:= GetNextAlias()
	Local aRetFil   := {}
	Local cFilBkp   := cFilAnt

	If !lJob
		cOldCadastro	:= IIf(Type('cCadastro') == "C",cCadastro,"")
	EndIf


	cQuery += " SELECT A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_ SA2REC "
	cQuery += " FROM "+ RetSqlName("SA2") + " SA2 "
	cQuery += " WHERE A2_FILIAL = '' "
	cQuery += "   AND A2_MSEXP = '' "
	cQuery += "   AND A2_TPESSOA = 'FF' "
	cQuery += "   AND SA2.D_E_L_E_T_ = '' "
	PLSQuery(cQuery,cAlias)

	If (cAlias)->( !Eof() )
		While (cAlias)->( !Eof() )
			aDados := {}
			AAdd(aDados, { (cAlias)->A2_FILIAL, (cAlias)->A2_COD, (cAlias)->A2_LOJA, (cAlias)->SA2REC })

			dbSelectArea("SA2")
			SA2->(dbGoTo((cAlias)->SA2REC))

			//SECTION - Ticket : 351982
			//NOTE Alterado por Leandro Cesar - 03/02/023
			//LINK http://cs.solucaocompacta.com.br/compacta/paginas/assentamento.php?idocorr=351982
			aEmpFE := {}
			If SA2->(FieldPos("A2_XEMPFLS")) > 0
				If !Empty(SA2->A2_XEMPFLS)
					aEmpFE := StrToKarr(SA2->A2_XEMPFLS,"#")
				EndIf
			EndIf

			//NOTE - alterado por Leandro Cesar - 27/02/2023
			//LINK - http://cs.solucaocompacta.com.br/compacta/paginas/assentamento.php?idocorr=364162
			//SECTION Ticket: 364162
			nRecSA2 := SA2->(Recno())
			lSucess := .T.
			//!SECTION

			DbSelectArea("ZZH")
			DbSetOrder(1)
			DbGoTop()

			While !EOF() .AND. !EMPTY(ZZH->ZZH_URL)
				lProcFil := .F.
				If aScan(aEmpFE,{|x| alltrim(x) == alltrim(ZZH->ZZH_FILPRO) }) > 0
					lProcFil := .T.
				EndIf

				If Empty(aEmpFE)
					lProcFil := .T.
				EndIf
				//!SECTION

				oIntExp   := ExpenseOn():New()

				// Posicionar na filia a ser integrada
				If oIntExp:ChkFilial( ZZH->ZZH_FILPRO) .and. lProcFil

					lRet := oIntExp:GrvUser( aDados , ZZH->ZZH_FILPRO, @lSucess )
					If lRet
						aRet        := oIntExp:GetRetornoArray()
						AAdd(aRetFil, aRet)
					Else
						cMsgRet 	:= oIntExp:GetErro()
						cStCode 	:= oIntExp:GetStatusCode()
						aRet := {}
						AAdd(aRet, {"","","", "ERRO" , cMsgRet + " " +cStCode ,"", ZZH->ZZH_FILPRO } )
						AAdd(aRetFil, aRet)
					EndIf

				EndIf

				FreeObj(oIntExp)

				DbSelectArea("ZZH")
				ZZH->( DbSkip() )

			EndDo

			//NOTE - alterado por Leandro Cesar - 27/02/2023
			//LINK - http://cs.solucaocompacta.com.br/compacta/paginas/assentamento.php?idocorr=364162
			//SECTION Ticket: 364162
			If !lSucess
				dbSelectArea("SA2")
				SA2->(dbGoto(nRecSA2))
				SA2->(Reclock("SA2",.F.))
				SA2->A2_MSEXP := ""
				SA2->(Msunlock())
			EndIf
			//!SECTION

			(cAlias)->( dbSkip() )
		End
		(cAlias)->(dbClosearea())



	Else
		If Empty(aDados)
			MsgInfo("Não ha Dados para serem Integrados!!","Integração Fornecedores" )
			Return()
		EndIf
	EndIf

	If Len(aRetFil) > 0
		TelaLog("SA2",aRetFil,cOldCadastro,lJob)
	EndIf

	RestArea(aAreaSM0)
	cFilAnt := cFilBkp

Return()

Static Function IntegraCTT()

	Local lRet      := .F.
	Local aDados    := {}
	Local cMsgRet 	:= ""
	Local cStCode 	:= ""
	Local aAreaSM0	:= SM0->(GetArea())
	Local cOldCadastro	:= IIf(Type('cCadastro') == "C",cCadastro,"")
	Local oIntExp   := Nil
	Local cQuery    := ""
	Local cAlias 	:= GetNextAlias()
	Local aRetFil   := {}
	Local cFilBkp   := cFilAnt

	cQuery += " SELECT CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_ CTTREC "
	cQuery += " FROM "+ RetSqlName("CTT") + " CTT "
	cQuery += " WHERE CTT_FILIAL = '' "
	cQuery += "   AND CTT_MSEXP = '' "
	cQuery += "   AND CTT_CLASSE = '2' "
	cQuery += "   AND CTT.D_E_L_E_T_ = '' "
	PLSQuery(cQuery,cAlias)

	While (cAlias)->( !Eof() )
		AAdd(aDados, { (cAlias)->CTT_FILIAL, (cAlias)->CTT_CUSTO, (cAlias)->CTTREC })
		(cAlias)->( dbSkip() )
	End
	(cAlias)->(dbClosearea())

	If Empty(aDados)
		MsgInfo("Não ha Dados para serem Integrados!!","Integração Centro de Custos" )
		Return()
	EndIf

	DbSelectArea("ZZH")
	DbSetOrder(1)
	DbGoTop()

	While !EOF() .AND. !EMPTY(ZZH->ZZH_URL)

		oIntExp   := ExpenseOn():New()

		// Posicionar na filia a ser integrada
		If oIntExp:ChkFilial( ZZH->ZZH_FILPRO)

			lRet := oIntExp:GrvCCusto( aDados,ZZH->ZZH_FILPRO )
			If lRet
				aRet        := oIntExp:GetRetornoArray()
				AAdd(aRetFil, aRet)
			Else
				cMsgRet 	:= oIntExp:GetErro()
				cStCode 	:= oIntExp:GetStatusCode()
				Alert(cMsgRet + " " +cStCode+" - Organização: "+SM0->M0_NOME)
			EndIf
		EndIf

		FreeObj(oIntExp)

		DbSelectArea("ZZH")
		ZZH->( DbSkip() )

	EndDo

	If Len(aRetFil) > 0
		TelaLog("CTT",aRetFil,cOldCadastro,.f.)
	EndIf

	RestArea(aAreaSM0)
	cFilAnt := cFilBkp

Return()

Static Function IntegraSED()

	Local lRet      := .F.
	Local aDados    := {}
	Local cMsgRet 	:= ""
	Local cStCode 	:= ""
	Local aAreaSM0	:= SM0->(GetArea())
	Local cOldCadastro	:= IIf(Type('cCadastro') == "C",cCadastro,"")
	Local oIntExp   := Nil
	Local cQuery    := ""
	Local cAlias 	:= GetNextAlias()
	Local aRetFil   := {}
	Local cFilBkp   := cFilAnt

	cQuery += " SELECT ED_FILIAL, ED_CODIGO, R_E_C_N_O_ SEDREC "
	cQuery += " FROM "+ RetSqlName("SED") + " SED "
	cQuery += " WHERE ED_FILIAL = '' "
	cQuery += "   AND ED_MSEXP = '' "
	cQuery += "   AND ED_COND = 'D' AND ED_TIPO = '2' "
	cQuery += "   AND SED.D_E_L_E_T_ = '' "
	PLSQuery(cQuery,cAlias)

	While (cAlias)->( !Eof() )
		AAdd(aDados, { (cAlias)->ED_FILIAL, (cAlias)->ED_CODIGO, (cAlias)->SEDREC })
		(cAlias)->( dbSkip() )
	End
	(cAlias)->(dbClosearea())

	If Empty(aDados)
		MsgInfo("Não ha Dados para serem Integrados!!","Integração Naturezas (Categorias)" )
		Return()
	EndIf

	DbSelectArea("ZZH")
	DbSetOrder(1)
	DbGoTop()

	While !EOF() .AND. !EMPTY(ZZH->ZZH_URL)

		oIntExp   := ExpenseOn():New()

		// Posicionar na filia a ser integrada
		If oIntExp:ChkFilial( ZZH->ZZH_FILPRO)

			lRet := oIntExp:GrvCategoria( aDados,ZZH->ZZH_FILPRO )
			If lRet
				aRet        := oIntExp:GetRetornoArray()
				AAdd(aRetFil, aRet)
			Else
				cMsgRet 	:= oIntExp:GetErro()
				cStCode 	:= oIntExp:GetStatusCode()
				Alert(cMsgRet + " " +cStCode+" - Organização: "+SM0->M0_NOME)
			EndIf
		EndIf

		FreeObj(oIntExp)

		DbSelectArea("ZZH")
		ZZH->( DbSkip() )

	EndDo

	If Len(aRetFil) > 0
		TelaLog("SED",aRetFil,cOldCadastro,.f.)
	EndIf

	RestArea(aAreaSM0)
	cFilAnt := cFilBkp


Return()


User Function IntegraPA(dDtIni, dDtFim,lJob)

	Local oIntExp := nil
	Local aRet    := {}
	Local aRetFil := {}
	Local aAreaSM0	:= SM0->(GetArea())
	Local cOldCadastro	:= ""
	Local aRetErro  := {}
	Local cFilBkp   := cFilAnt

	If !lJob
		cOldCadastro	:= IIf(Type('cCadastro') == "C",cCadastro,"")
	EndIf

	DbSelectArea("ZZH")
	DbSetOrder(1)
	DbGoTop()

	While !EOF() .AND. !EMPTY(ZZH->ZZH_URL)

		oIntExp   := ExpenseOn():New()

		If oIntExp:ChkFilial( ZZH->ZZH_FILPRO )

			If oIntExp:GetAdiantamentos( dDtIni, dDtFim )
				If oIntExp:GrvAdiantamentos(ZZH->ZZH_FILPRO)
					aRet := oIntExp:GetRetornoArray()
					//Atualiza o Status dos Adiantamentos
					If Len(aRet) <> 0
						FreeObj(oIntExp)
						oIntExp := ExpenseOn():New()
						oIntExp:PostChangPA(@aRet,3)
					EndIf
					AAdd(aRetFil, aRet)
				Else
					cMsgRet 	:= oIntExp:GetErro()
					cStCode 	:= oIntExp:GetStatusCode()
					aRetErro    := Array(35)
					aRetErro[30] := cMsgRet + " " +cStCode
					aRetErro[34] := ZZH->ZZH_FILPRO
					aRetErro[35] := ""
					aRet        := {}
					AAdd(aRet, aRetErro )
					AAdd(aRetFil, aRet)
				EndIf
			Else
				cMsgRet 	:= oIntExp:GetErro()
				cStCode 	:= oIntExp:GetStatusCode()
				aRetErro    := Array(35)
				aRetErro[30] := cMsgRet + " " +cStCode
				aRetErro[34] := ZZH->ZZH_FILPRO
				aRetErro[35] := "ERRO"
				aRet        := {}
				AAdd(aRet, aRetErro )
				AAdd(aRetFil, aRet)
			EndIf
		EndIf

		FreeObj(oIntExp)
		DbSelectArea("ZZH")
		ZZH->( DbSkip() )

	EndDo

	If Len(aRetFil) > 0
		TelaLog("FPA",aRetFil,cOldCadastro,lJob)
	EndIf

	RestArea(aAreaSM0)
	cFilAnt := cFilBkp

Return()

User Function IntegraDP(dDtIni, dDtFim,lJob)

	Local oIntExp := nil
	Local aRet    := {}
	Local aRetFil := {}
	Local aAreaSM0	:= SM0->(GetArea())
	Local cOldCadastro	:= ""
	Local aRetErro  := {}
	Local cFilBkp   := cFilAnt

	If !lJob
		cOldCadastro	:= IIf(Type('cCadastro') == "C",cCadastro,"")
	EndIf

	DbSelectArea("ZZH")
	DbSetOrder(1)
	DbGoTop()

	While !EOF() .AND. !EMPTY(ZZH->ZZH_URL)

		oIntExp   := ExpenseOn():New()

		If oIntExp:ChkFilial( ZZH->ZZH_FILPRO )

			If oIntExp:GetTitulos( dDtIni, dDtFim )
				If oIntExp:GrvTitulos(ZZH->ZZH_FILPRO)
					aRet := oIntExp:GetRetornoArray()
					//Atualiza o Status dos Adiantamentos
					If Len(aRet) <> 0
						//fase 1
						FreeObj(oIntExp)
						oIntExp := ExpenseOn():New()
						oIntExp:PostChangDP(@aRet,1,1)
						//fase 2
						FreeObj(oIntExp)
						oIntExp := ExpenseOn():New()
						oIntExp:PostChangDP(@aRet,1,2)
					EndIf
					AAdd(aRetFil, aRet)
				Else
					cMsgRet 	:= oIntExp:GetErro()
					cStCode 	:= oIntExp:GetStatusCode()
					aRetErro    := Array(13)
					aRetErro[09] := cMsgRet + " " +cStCode
					aRetErro[10] := "VAZIO"
					aRetErro[13] := ZZH->ZZH_FILPRO
					aRet        := {}
					AAdd(aRet, aRetErro )
					AAdd(aRetFil, aRet)
				EndIf
			Else
				cMsgRet 	:= oIntExp:GetErro()
				cStCode 	:= oIntExp:GetStatusCode()
				aRetErro    := Array(13)
				aRetErro[09] := cMsgRet + " " +cStCode
				aRetErro[10] := "ERRO"
				aRetErro[13] := ZZH->ZZH_FILPRO
				aRet        := {}
				AAdd(aRet, aRetErro )
				AAdd(aRetFil, aRet)
			EndIf

		EndIf

		FreeObj(oIntExp)
		DbSelectArea("ZZH")
		ZZH->( DbSkip() )

	EndDo

	If Len(aRetFil) > 0
		TelaLog("FDP",aRetFil,cOldCadastro,lJob)
	EndIf

	RestArea(aAreaSM0)
	cFilAnt := cFilBkp

Return()



Static Function TelaLog(cTpLog,aRetFil,cOldCadastro,lJob)

	Local aCabecLog := {}
	Local aLog      := {}
	Local aCores    := {}
	Local aLogErro  := {}
	Local nY	    := 0
	Local nX        := 0
	Local cPlan     := ""
	Local aCdCores  := {{ 'BR_VERMELHO',OemtoAnsi('ERRO INTEGRAÇÃO')},;
		{ 'BR_VERDE'   ,OemtoAnsi('SUCESSO INTEGRAÇÃO')}}

	Do Case
	Case cTpLog == "SED"
		cCadastro := "Integração Naturezas x Categorias"
		cPlan := cCadastro
		aCabecLog := {}
		AAdd(aCabecLog, {"Empresa			    ","@!",20} )
		AAdd(aCabecLog, {"Filial			    ","@!",20} )
		AAdd(aCabecLog, {"Codigo				","@!",06} )
		AAdd(aCabecLog, {"Natureza			    ","@!",02} )
		AAdd(aCabecLog, {"Integracao			","@!",20} )
		AAdd(aCabecLog, {"Mensagem			    ","@!",200} )

		aCores   := {{ 'aDados[oCritica:nAt, 5] == "ERRO"'	 ,aCdCores[1,1] },;
			{ 'aDados[oCritica:nAt, 5] == "SUCESSO"',aCdCores[2,1] }}

		For nX:=1 to Len(aRetFil)
			For nY:=1 to Len(aRetFil[nX])
				aadd(aLog,{ aRetFil[nX][nY][6],;
					FwFilialName( ,aRetFil[nX][nY][6], 1 ),;
					aRetFil[nX][nY][2],;
					Posicione("SED",1,FWxFilial("SED")+aRetFil[nX][nY][2],"ED_DESCRIC"),;
					IIf(aRetFil[nX][nY][3],"SUCESSO","ERRO"),;
					aRetFil[nX][nY][4] })
			Next nY
		Next nX

	Case cTpLog == "CTT"

		cCadastro := "Integração Centro Custos"
		cPlan := cCadastro
		aCabecLog := {}
		AAdd(aCabecLog, {"Empresa			    ","@C",20} )
		AAdd(aCabecLog, {"Filial			    ","@C",20} )
		AAdd(aCabecLog, {"Codigo				","@C",06} )
		AAdd(aCabecLog, {"C.Custo			    ","@C",02} )
		AAdd(aCabecLog, {"Integracao			","@C",20} )
		AAdd(aCabecLog, {"Mensagem			    ","@C",200} )

		aCores   := {{ 'aDados[oCritica:nAt, 5] == "ERRO"'	 ,aCdCores[1,1] },;
			{ 'aDados[oCritica:nAt, 5] == "SUCESSO"',aCdCores[2,1] }}

		For nX:=1 to Len(aRetFil)
			For nY:=1 to Len(aRetFil[nX])
				aadd(aLog,{ aRetFil[nX][nY][6],;
					FwFilialName( ,aRetFil[nX][nY][6], 1 ),;
					aRetFil[nX][nY][2],;
					Posicione("CTT",1,FWxFilial("CTT")+aRetFil[nX][nY][2],"CTT_DESC01"),;
					IIf(aRetFil[nX][nY][3],"SUCESSO","ERRO"),;
					aRetFil[nX][nY][4] })
			Next nY
		Next nX

	Case cTpLog == "SA2"

		cCadastro := "Integração Fornecedores x Usuarios"
		cPlan := cCadastro
		aCabecLog := {}
		AAdd(aCabecLog, {"Empresa			    ","@C",20} )
		AAdd(aCabecLog, {"Filial			    ","@C",20} )
		AAdd(aCabecLog, {"Codigo				","@C",06} )
		AAdd(aCabecLog, {"Loja				    ","@C",02} )
		AAdd(aCabecLog, {"Nome				    ","@C",40} )
		AAdd(aCabecLog, {"Integracao			","@C",20} )
		AAdd(aCabecLog, {"Mensagem			    ","@C",200} )

		aCores   := {{ 'aDados[oCritica:nAt, 6] == "ERRO"'	 ,aCdCores[1,1] },;
			{ 'aDados[oCritica:nAt, 6] == "SUCESSO"',aCdCores[2,1] }}

		For nX:=1 to Len(aRetFil)
			For nY:=1 to Len(aRetFil[nX])
				aadd(aLog,{ aRetFil[nX][nY][7],;
					FwFilialName( ,aRetFil[nX][nY][7], 1 ),;
					aRetFil[nX][nY][2],;
					aRetFil[nX][nY][3],;
					Posicione("SA2",1,FWxFilial("SA2")+aRetFil[nX][nY][2]+aRetFil[nX][nY][3],"A2_NREDUZ"),;
					aRetFil[nX][nY][4],;
					aRetFil[nX][nY][5] })
			Next nY
		Next nX

		//Para evitar error.log, verifica se alguma celula é Nil
		For nX:=1 to Len(aLog)
			For nY:=1 to Len(aLog[nX])
				If ValType(aLog[nX,nY]) == "U"
					aLog[nX,nY] := ""
				EndIf
			Next nY
			If aLog[nX,6] == "ERRO"
				aadd(aLogErro,aLog[nX])
			EndIf
		Next nX

	Case cTpLog == "FPA"

		cCadastro := "Geracao de titulos de Adiantamentos"
		cPlan := cCadastro
		aCabecLog := {}
		AAdd(aCabecLog, {"Empresa			    ","@C",20} )
		AAdd(aCabecLog, {"Filial			    ","@C",20} )
		AAdd(aCabecLog, {"reference			    ","@C",20} ) 	// 1 - reference	string	Referência do adiantamento
		AAdd(aCabecLog, {"status	        	",""  ,20} )    //35 - msg de status
		AAdd(aCabecLog, {"msg			        ",""  ,255} )   //30 - msg de critica
		AAdd(aCabecLog, {"parentReference		","@C",20} ) 	// 2 - parentReference	string	Referência do adiantamento de origem caso o mesmo seja valor residual
		AAdd(aCabecLog, {"comment				","@C",20} ) 	// 3 - comment	string	Atributo utilizado para adicionar observações ao adiantamento
		AAdd(aCabecLog, {"amount				","@E 999,999,999.99",20} ) 	// 4 - amount	decimal	Valor do adiantamento
		AAdd(aCabecLog, {"currencyCode			","@C",20} ) 	// 5 - currencyCode	string	Código da moeda do adiantamento. Ex: BRL, USD, etc
		AAdd(aCabecLog, {"convertionRate		","@E 999,999.99",20} ) 	// 6 - convertionRate	decimal	Taxa de conversão do adiantamento
		AAdd(aCabecLog, {"currencyConvertion	","@C",20} ) 	// 7 - currencyConvertion	string	Código da moeda de conversão do adiantamento. Ex: BRL, USD, etc
		AAdd(aCabecLog, {"convertedAmount		","@E 999,999.99",20} ) 	// 8 - convertedAmount	decimal	Valor do adiantamento convertido
		AAdd(aCabecLog, {"advPaymentDate		","@C",20} ) 	// 9 - advPaymentDate	datetime	Data de vencimento do adiantamento
		AAdd(aCabecLog, {"advPaymentStatus		","@E 99",20} ) 	//10 - advPaymentStatus	integer	Código do status do adiantamento
		AAdd(aCabecLog, {"advPaymentStatusName	","@C",20} ) 	//11 - advPaymentStatusName	integer	Descrição do status do adiantamento
		AAdd(aCabecLog, {"creator				","@C",20} ) 	//12 - creator	User	Usuário criador do adiantamento
		AAdd(aCabecLog, {"approver				","@C",20} ) 	//13 - approver	User	Usuário aprovador do adiantamento
		AAdd(aCabecLog, {"costCenterReferenceId ","@C",20} ) 	//14 - costCenterReferenceId	string	Atributo que atrela o adiantamento à um centro de custo específico
		AAdd(aCabecLog, {"firstApproval		    ","@C",20} ) 	//15 - firstApproval	datetime	Data da primeira aprovação do adiantamento
		AAdd(aCabecLog, {"lastApproval	    	","@C",20} ) 	//16 - lastApproval	datetime	Data da última aprovação do adiantamento
		AAdd(aCabecLog, {"submittedDate 		","@C",20} ) 	//17 - submittedDate	datetime	Data do envio para aprovação
		AAdd(aCabecLog, {"paymentDate			","@C",20} ) 	//18 - paymentDate	datetime	Data de reembolso do adiantamento
		AAdd(aCabecLog, {"financeProcessStart	","@C",20} ) 	//19 - financeProcessStart	datetime	Data do processamento do documento financeiro
		AAdd(aCabecLog, {"clientReferenceId	    ","@C",20} ) 	//20 - clientReferenceId	string	Atributo que atrela o adiantamento à um cliente específico
		AAdd(aCabecLog, {"clientName			","@C",20} ) 	//21 - clientName	string	Nome do cliente do adiantamento
		AAdd(aCabecLog, {"projectReferenceId	","@C",20} ) 	//22 - projectReferenceId	string	Atributo que atrela o adiantamento à um projeto específico
		AAdd(aCabecLog, {"projectName			","@C",20} ) 	//23 - projectName	string	Nome do projeto do adiantamento
		AAdd(aCabecLog, {"financeReferenceId	","@C",20} ) 	//24 - financeReferenceId	string	Atributo usado para dar referência ao documento em questão no contas a pagar no ERP
		AAdd(aCabecLog, {"subsidiaryReference	","@C",20} ) 	//25 - subsidiaryReference	string	Referência da filial da despesa
		AAdd(aCabecLog, {"subsidiaryName		","@C",20} ) 	//26 - subsidiaryName	string	Descrição da filial da despesa
		AAdd(aCabecLog, {"areaReference		    ","@C",20} ) 	//27 - areaReference	string	Referência da área da despesa
		AAdd(aCabecLog, {"areaName				","@C",20} ) 	//28 - areaName	string	Descrição da área da despesa
		AAdd(aCabecLog, {"chaveSE2		    	","@C",20} )    //29 - Chave do SE2 gerada
		AAdd(aCabecLog, {"nomeFornecedor        ","@C",50} )    //31 - nome do fornecedor
		AAdd(aCabecLog, {"status		        ","@C",40} )    //32 - msg de status
		AAdd(aCabecLog, {"msgstatus    			","@C",200} )   //33 - msg de critica atualização status

		aCores   := {{ 'Empty(aDados[oCritica:nAt, 5])' 	,aCdCores[2,1] },;
			{ '!Empty(aDados[oCritica:nAt, 5])' 	,aCdCores[1,1] }}

		For nX:=1 to Len(aRetFil)
			For nY:=1 to Len(aRetFil[nX])
				aadd(aLog,{ aRetFil[nX][nY][34],;
					FwFilialName( ,aRetFil[nX][nY][34], 1 ),;
					aRetFil[nX][nY][1],;
					aRetFil[nX][nY][35],;
					AllTrim(aRetFil[nX][nY][30]),;
					aRetFil[nX][nY][2],;
					aRetFil[nX][nY][3],;
					aRetFil[nX][nY][4],;
					aRetFil[nX][nY][5],;
					aRetFil[nX][nY][6],;
					aRetFil[nX][nY][7],;
					aRetFil[nX][nY][8],;
					aRetFil[nX][nY][9],;
					aRetFil[nX][nY][10],;
					aRetFil[nX][nY][11],;
					aRetFil[nX][nY][12],;
					aRetFil[nX][nY][13],;
					aRetFil[nX][nY][14],;
					aRetFil[nX][nY][15],;
					aRetFil[nX][nY][16],;
					aRetFil[nX][nY][17],;
					aRetFil[nX][nY][18],;
					aRetFil[nX][nY][19],;
					aRetFil[nX][nY][20],;
					aRetFil[nX][nY][21],;
					aRetFil[nX][nY][22],;
					aRetFil[nX][nY][23],;
					aRetFil[nX][nY][24],;
					aRetFil[nX][nY][25],;
					aRetFil[nX][nY][26],;
					aRetFil[nX][nY][27],;
					aRetFil[nX][nY][28],;
					aRetFil[nX][nY][29],;
					aRetFil[nX][nY][31],;
					aRetFil[nX][nY][32],;
					aRetFil[nX][nY][33]})
			Next nY
		Next nX

		//Para evitar error.log, verifica se alguma celula é Nil
		For nX:=1 to Len(aLog)
			For nY:=1 to Len(aLog[nX])
				If ValType(aLog[nX,nY]) == "U"
					aLog[nX,nY] := ""
				EndIf
			Next nY
			If aLog[nX,4] == "ERRO"
				aadd(aLogErro,aLog[nX])
			EndIf
		Next nX

	Case cTpLog == "FDP"

		cCadastro := "Geracao de titulos de Despesas"
		cPlan := cCadastro
		aCabecLog := {}

		AAdd(aCabecLog, {"Empresa			    ","@C",20} )
		AAdd(aCabecLog, {"Filial			    ","@C",20} )
		AAdd(aCabecLog, {"reference			    ","@C",20} ) 	// 01 - id reference	string	Referência da despesa
		AAdd(aCabecLog, {"name			        ","@C",20} ) 	// 02 - nome reference	string	Referência da despesa
		AAdd(aCabecLog, {"status	        	",""  ,20} )    // 10 - msg de status
		AAdd(aCabecLog, {"msg			        ",""  ,255} )   // 09 - msg de critica
		AAdd(aCabecLog, {"startDate	        	",""  ,20} )    // 03 - emissao
		AAdd(aCabecLog, {"vencto	        	",""  ,20} )    // 04 - vencto
		AAdd(aCabecLog, {"totalReimbursable   	","@E 999,999,999.99",20} ) 	// 05 - total do reembolso
		AAdd(aCabecLog, {"creator				","@C",20} ) 	//06 - cod creator	User	Usuário criador da despesa
		AAdd(aCabecLog, {"name				    ","@C",20} ) 	//07 - creator	User	Usuário criador da despesa
		AAdd(aCabecLog, {"chaveSE2		    	","@C",20} )    //08 - Chave do SE2 gerada
		AAdd(aCabecLog, {"msgstatus    			","@C",200} )   //11 - msg de critica atualização status
		AAdd(aCabecLog, {"compstatus    		","@C",200} )   //12 - msg de critica atualização compensação

		aCores   := {{ 'aDados[oCritica:nAt, 5] == "ERRO" ' 	,aCdCores[1,1] },;
			{ 'aDados[oCritica:nAt, 5] == "VAZIO"' 	,aCdCores[2,1] },;
			{ 'aDados[oCritica:nAt, 5] == "SUCESSO" ' 	,aCdCores[2,1] }}

		For nX:=1 to Len(aRetFil)
			For nY:=1 to Len(aRetFil[nX])
				aadd(aLog,{ aRetFil[nX][nY][13],;
					FwFilialName( ,aRetFil[nX][nY][13], 1 ),;
					aRetFil[nX][nY][1],;
					aRetFil[nX][nY][2],;
					aRetFil[nX][nY][10],;
					aRetFil[nX][nY][9],;
					aRetFil[nX][nY][3],;
					aRetFil[nX][nY][4],;
					aRetFil[nX][nY][5],;
					aRetFil[nX][nY][6],;
					aRetFil[nX][nY][7],;
					aRetFil[nX][nY][8],;
					aRetFil[nX][nY][11],;
					aRetFil[nX][nY][12]})
			Next nY
		Next nX

		for nX :=1 to len(aLog)
			if Valtype(aLog[nX][4]) <> "U" .and. Valtype(aLog[nX][13]) <> "U"
				if "Não reembolsável" $ aLog[nX][4] .and. aLog[nX][13] == "SUCESSO"
					aLog[nX][5] := "SUCESSO"
				endif
			Endif
		Next nX

		//Para evitar error.log, verifica se alguma celula é Nil
		For nX:=1 to Len(aLog)
			For nY:=1 to Len(aLog[nX])
				If ValType(aLog[nX,nY]) == "U"
					aLog[nX,nY] := ""
				EndIf
			Next nY
			If aLog[nX,5] == "ERRO"
				aadd(aLogErro,aLog[nX])
			EndIf
		Next nX

	OTHERWISE
		Return
	EndCase

	If !lJob
		PLSCRIGEN(/*aDados*/aLog ,/*aCabec*/aCabecLog ,/*cTitulo*/cCadastro,/*lrel*/,/*cRodape*/,/*nFreeze*/,;
				/*aButtons*/, /*bLDblClick*/,/*cRdmake*/,/*cTpRel*/,/*nTmRel*/,;
				/*bBlickUser*/,/*aArrayAux*/,/*lAmbAtv*/,;
				/*cLin1*/,/*cLin2*/,/*cCol1*/,/*cCol2*/,/*cHoriz*/,;
			aCores,aCdCores,/*aLegenda*/,/*oFont*/,/*lSilCrigen*/,/*lResize*/.t.,/*aTipoCab*/)

		cCadastro := cOldCadastro
	Else
		If !Empty(aLogErro)
			fPlanLog(cPlan,aLogErro,aCabecLog,lJob)
		EndIf
	EndIf


Return()

Static Function	fPlanLog(cPlan,aLog,aCabecLog,lJob)

	Local cArqPlan 		:= "integracao_expenseon.xls"
	Local cArquivo 		:= "\JobExpenseOn\"+cArqPlan
	Local cHtml    		:= ""
	Local cWorkSheet 	:= cPlan
	Local cTable 		:= "Executado em  "+dtoc(date())+" as "+time()
	Local nY            := 0
	Local oFwMsEx		:= nil
	Local cEmailResp    := SuperGetMV("CL_MAIEXPEN",.F.,"")

	makedir("\JobExpenseOn\")

	cHtml := "<HTML>"
	cHtml += "<Br><h3>"+cWorkSheet+"</h3><Br>"
	cHtml += "</HTML>"

	If File(cArquivo)
		fErase(cArquivo)
	Endif

	oFwMsEx := FWMsExcel():New()
	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )

	For nY := 1 to Len(aCabecLog)
		oFwMsEx:AddColumn( cWorkSheet, cTable , aCabecLog[ny][1], 1,1)
	Next nY

	For nY := 1 to Len(aLog)
		oFwMsEx:AddRow(cWorkSheet, cTable, aLog[ny])
	Next nY

	oFwMsEx:Activate()
	oFwMsEx:GetXMLFile(cArquivo)

	If !Empty(cEmailResp)
		fEnvEmail("Integração ExpenseON","",cEmailResp,cHtml,iif(lJob,.f.,.t.),cArquivo,"",cArqPlan)
	EndIf

Return()

Static Function fEnvEmail(cAssunto,cRemetente,cDestinatario,cMensagem,lMensagem,cArquivo,cCopia,cArqPlan)

	Local cMailServer   := GetMV("MV_RELSERV")       					// substituir por servidor de e-mail
	Local cMailConta    := GetMV("MV_EMCONTA")       					// substituir por conta de e-mail
	Local cMailSenha    := GetMV("MV_EMSENHA")        					// substituir pela senha da conta
	Local oServer
	Local oMessage
	Local nPortaSMTP    := 25
	Local xRet          := 0
	Local cMsg          := ""

	Default cArquivo := ""
	Default cCopia   := ""

	//Cria a conexão com o server STMP ( Envio de e-mail )
	oServer := TMailManager():New()
	If nPortaSMTP == 465
		oServer:SetUseSSL( .T. )
	ElseIf nPortaSMTP == 587
		oServer:SetUseTLS( .T. )
	EndIf
	oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPortaSMTP )

	//seta um tempo de time out com servidor de 1min
	If oServer:SetSmtpTimeOut( 60 ) != 0
		If lMensagem
			MsgAlert("Falha ao setar o time out","Atencao")
		Else
			Conout( "Falha ao setar o time out" )
		Endif
		Return .F.
	EndIf

	//realiza a conexão SMTP
	If oServer:SmtpConnect() != 0
		If lMensagem
			MsgAlert("Falha ao conectar no servidor SMTP","Atencao")
		Else
			Conout( "Falha ao conectar no servidor SMTP" )
		Endif
		Return .F.
	EndIf

	// authenticate on the SMTP server (if needed)
	If GetMv("MV_RELAUTH")
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Falha na authenticate no SMTP server: " + oServer:GetErrorString( xRet )
			If lMensagem
				MsgAlert(cMsg,"Atencao")
			Else
				Conout( cMsg )
			Endif
			oServer:SMTPDisconnect()
			return .f.
		endif
	EndIf

	//Apos a conexão, cria o objeto da mensagem
	oMessage := TMailMessage():New()

	//Limpa o objeto
	oMessage:Clear()

	//Popula com os dados de envio
	oMessage:cFrom              := cMailConta //cRemetente
	oMessage:cTo                := cDestinatario
	oMessage:cCc                := cCopia
	oMessage:cBcc               := ""
	oMessage:cSubject           := cAssunto
	oMessage:cBody              := cMensagem

	//Adiciona um attach
	If !Empty(cArquivo)
		If oMessage:AttachFile( cArquivo ) < 0
			If lMensagem
				MsgAlert("Erro ao atachar o arquivo","Atencao")
			Else
				Conout( "Erro ao atachar o arquivo" )
			Endif
			Return .F.
		Else
			//adiciona uma tag informando que é um attach e o nome do arq
			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cArqPlan+'')
		EndIf
	EndIf

	//Envia o e-mail
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		cMsg := "Erro ao enviar o e-mail: " + oServer:GetErrorString( xRet )
		If lMensagem
			MsgAlert(cMsg,"Atencao")
		Else
			Conout( cMsg )
		Endif
		Return .F.
	endif

	//Desconecta do servidor
	If oServer:SmtpDisconnect() != 0
		If lMensagem
			MsgAlert("Erro ao disconectar do servidor SMTP","Atencao")
		Else
			Conout( "Erro ao disconectar do servidor SMTP" )
		Endif
		Return .F.
	EndIf

Return .T.
