#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ITEM
Chamada na manutenção do cadastro de produtos - REPLICA
@type 12.1.33
@author Eurofins
@since 15/01/2018
/*/

User Function ITEM()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.
	Local nLinha     := 0
	Local nQtdLinhas := 0
	Local cMsg       := ''
	local aArea      := getArea()
	Local lPrdInt    := GetNewPar("ZZ_PRDINT",.F.)
	Local lExistCpo  := SB1->(FieldPos("B1_ZZINTPA")) > 0

	public lPLockInc
	public cCodRepl
	public lPLockExc

	lSolCad := If (Type("lSolCad") == "U", .F., lSolCad)

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := ( Len( aParam ) > 3 )
		//Chamada Após a gravação da tabela do formulário
		if cIdPonto == 'FORMCOMMITTTSPOS'
			// chamada na inclusão do produto
			if INCLUI
				if !(SB1->B1_TIPO == "SA")
					//MsgInfo("Produto cadastrado com o código: " + SB1->B1_COD,"Cadastro de Produtos")
				endif
				if !lPLockInc .and. existblock("replProd") .and. cIdModel == "SB1MASTER"
					lPLockInc := .T.
					cCodRepl := Alltrim(SB1->B1_COD)
					Processa( {|| U_replProd() }, "Aguarde...", "Realizando replica para outras filiais...",.F.)
					lPLockInc := .F.
					cCodRepl := ""
					restArea(aArea)
				endif

				If !lPLockInc .AND. lPrdInt .and. existBlock("fIntPrd") .and. cIdModel == "SB1MASTER"
					if lExistCpo .and. SB1->B1_ZZINTPA == "S"
						U_fIntPrd(.F.)
					endif
				EndIf
			endif
			// chamada na alteração do produto
			if ALTERA
				if !lPLockInc .and.  existblock("replProd")
					lPLockInc := .T.
					cCodRepl := Alltrim(SB1->B1_COD)
					Processa( {|| U_replProd() }, "Aguarde...", "Realizando replica para outras filiais...",.F.)
					lPLockInc := .F.
					cCodRepl := ""
				endif
				restArea(aArea)

				If !lPLockInc .AND. lPrdInt .and. existBlock("fIntPrd") .and. cIdModel == "SB1MASTER"
					if lExistCpo .and. SB1->B1_ZZINTPA == "S"
						U_fIntPrd(.F.,.T.)
					endif
				EndIf
			endif

			// chamada na exclusão do produto
			If !ALTERA .and. !INCLUI
				if !lPLockExc .and.  existblock("exclProd")
					lPLockExc := .T.
					Processa( {|| xRet:= U_exclProd() }, "Aguarde...", "Realizando replica para outras filiais...",.F.)
					lPLockExc := .F.
				endif
			endif
		ElseIf cIdPonto == "BUTTONBAR"


			If (lSolCad .And. !oObj:IsCopy())

				oObj:GetModel("SB1MASTER"):LoadValue("B1_COD"       , '01'          )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_TIPO"      , SZ9->Z9_TIPO  )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_ZZSGPRD"   , SZ9->Z9_GRUPO )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_ZZSUBGR"   , SZ9->Z9_SUBGRP)
				oObj:GetModel("SB1MASTER"):LoadValue("B1_DESC"      , SZ9->Z9_DESCR )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_UM"        , SZ9->Z9_UM    )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_SEGUM"     , SZ9->Z9_SEGUM )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_LOCPAD"    , SZ9->Z9_LOCPAD)
				oObj:GetModel("SB1MASTER"):LoadValue("B1_CONV"      , SZ9->Z9_FATOR )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_TIPCONV"   , SZ9->Z9_TPCONV)
				oObj:GetModel("SB1MASTER"):LoadValue("B1_CONTA"     , SZ9->Z9_CONTA )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_POSIPI"    , SZ9->Z9_NCM   )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_ORIGEM"    , SZ9->Z9_ORIGEM)
				oObj:GetModel("SB1MASTER"):LoadValue("B1_XIDREQ"    , SZ9->Z9_IDREQ )
				oObj:GetModel("SB1MASTER"):LoadValue("B1_XPARTNU"   , SZ9->Z9_PARTNUM )
				// oObj:GetModel("SB1MASTER"):LoadValue("B1_MSBLQL"    , '2'           )

				// RECUPERA A VIEW ATIVA E ATUALIZA (NECESSÁRIO PARA EXIBIÇÃO DO CONTEÚDO)
				oView := FwViewActive()
                oView:lModify := .T.
				oView:Refresh()

			EndIf

			xRet := {}

		EndIf
	EndIf
Return xRet

