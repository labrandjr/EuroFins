#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDEF.ch'


/*/{Protheus.doc} A010TOK
Ponto de entrada antes da gravação do produto para tratar geração automatica do código
@author RICARDO REY
@since 15/09/2017
@version 1
/*/
user function A010TOK()
	Local cGrupo	:= ""
	Local cSeq
	Local lRet		:= .t.
	Local cVldTipo	:= Alltrim(SuperGetMv("ZZ_TIPOPRD"))  //("SA/SG/SL")
	Local lPrdInt	:= GetNewPar("ZZ_PRDINT",.T.)

	public lPLockInc
	public cCodRepl

	oModelx := FWModelActive()


	******************************************************************************************************
	//Validação do Tipo do Produto para preenchimento da NCM conforme parâmetro informado ("ZZ_TIPOPRD")//
	//OBS:Possui validação no X3_WHEN                                                                   //
	******************************************************************************************************
	if INCLUI.or. ALTERA
		/*If M->B1_TIPO == 'SA' //serviço
			If Empty(M->B1_CC)
				MyHelp('Campo Obrigatório','Para produtos tipo "SA" é obrigatório informar Centro de Custo','Informe o Centro de Custo')
				Return .f.
			Endif
			If Empty(M->B1_CODISS)
				MyHelp('Campo obrigatório','Para produtos tipo "SA" é obrigatório informar Código do Serviço (ISS)','Informe o Código do Serviço')
				Return .f.
			Endif
		Endif*/
		if !M->B1_TIPO $ cVldTipo .and. Empty(M->B1_POSIPI)
			lRet:= .f.
			MsgInfo("Necessário informar a NCM do Produto !" ,"Cadastro de Produtos")
			Return(lRet)
		endif

		if M->B1_TIPO == "SA" .AND. Empty(M->B1_ZZCCUST)
			lRet:= .f.
			MsgInfo("Necessário informar o campo Centro de Custo Eurofins (Cuca) !" ,"Cadastro de Produtos")
			Return(lRet)
		endif

		if !M->B1_TIPO == "SA" .and. !M->B1_TIPO == "AM" .AND. Empty(M->B1_ZZSGPRD)
			lRet := .f.
			MsgInfo("Necessário informar o Grupo PDB, na aba Cadastrais!" ,"Cadastro de Produtos")
			Return(lRet)
		endif

		if M->B1_ZZCCUST == "99" .AND. ALTERA .AND. !lPLockInc
			lRet := .f.
			MsgInfo("Defina o Centro de Custo Eurofins!" ,"Cadastro de Produtos")
			Return(lRet)
		endif
	endif

	if INCLUI

		if M->B1_TIPO == "SA" .and. Len(Alltrim(M->B1_COD)) < 5
			lRet := .f.
			MsgInfo("Código do produto inválido. Verifique!" ,"Cadastro de Produtos")
			Return(lRet)
		endif
		
		if M->B1_TIPO == "SA"
			oMOdelx:SetValue("SB1MASTER","B1_MSBLQL","1") //Sempre vai gravar produto SA desbloqueado a Pedido da Debora Panserini Ticket#2019100310062571
		else
			oMOdelx:SetValue("SB1MASTER","B1_MSBLQL","2") //Sempre vai gravar desbloqueado a Pedido da Debora Panserini Ticket#2019100310062571
		endif

	endif

	if !INCLUI .or. M->B1_TIPO == "SA" //neste caso, o usuario irá informar o código do produto manualmente
		Return .T.
	endif

	if ! lPLockInc
		cGrupo := Alltrim(Substr(M->B1_ZZSGPRD,1,5))

		BeginSql Alias "TMP"
		%noParser%

			SELECT TOP 1 *
			FROM
				%table:SB1% SB1
			WHERE
				SB1.%notDel% AND
				B1_FILIAL	= %xFilial:SB1%	AND
				Substring(B1_ZZSGPRD,1,5)	= %Exp:cGrupo% AND
				B1_TIPO <> 'SA'
			ORDER BY B1_COD desc

		EndSql

		TMP->(dbGoTop())

		if Empty(cGrupo) //gera código de produto sequencial

			cSeq := StrZero(Val(TMP->B1_COD)+1,05)

		else // gera sequencial dentro do grupo B1_ZZSGPRD

			cSeq 	:= StrZero(Val(Substr(TMP->B1_COD,7,4))+1,4)

		endif

		TMP->(dbCloseArea())

		cCod := cGrupo+iif(Empty(cGrupo),"",".")+cSeq
	//	M->B1_COD := cCod
	//	Alert(cCOD)
		oModelx:SetValue("SB1MASTER",'B1_COD',cCod)
		if M->B1_TIPO == "SA"
			oMOdelx:SetValue("SB1MASTER","B1_MSBLQL","1") //Sempre vai gravar desbloqueado a Pedido da Debora Panserini Ticket#2019100310062571
		else
			oMOdelx:SetValue("SB1MASTER","B1_MSBLQL","2") //Sempre vai gravar desbloqueado a Pedido da Debora Panserini Ticket#2019100310062571
		endif
	else
		if (Alltrim(cCodRepl) <> Alltrim(M->B1_COD))
			Alert ("Réplica de produto em andamento. Tente novamente em alguns instantes.")
			lRet := .F.
		endif
	endif

	If lPrdInt .and. existBlock("fIntPrd")
		U_fIntFor(.F.)
	EndIf

Return (lRet)

Static Function MyHelp(cTipo,cProblema,cSolucao)
	Help(NIL, NIL, cTipo, NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
Return