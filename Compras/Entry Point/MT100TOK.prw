#include 'totvs.ch'
#include 'protheus.ch'
#include 'topconn.ch'

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} MT100TOK
Validar a inclus�o da NF de entrada
@author Unknown
@since 29/12/2017
/*/
user function MT100TOK()
	local aArea     := GetArea()
	local aAreaSC7  := SC7->(GetArea())
	local lRet      := .T.
	local nX        := 0
	local nPosPc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
	local nPosItPc  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
	local nUsado    := Len(aHeader)
	local cCondPag	:= ""
	local cCondPed	:= CCONDICAO
	local cTipoPed	:= CTIPO
	local cMsgPed	:= ""
	local lCConduta := GetMv("CL_CCONDUT",.F.,.F.)
	local lRecFis := GetMv("CL_RECFIS",.F.,.F.)

	if (!INCLUI .and. !ALTERA ) .or. IsInCallStack("MATA920") .or. IsInCallStack("U_LINMONITOR") .or. IsInCallStack("U_LINCROS") .or. IsInCallStack("U_LINCIP01")
		Return lRet
	endif
	/*
	if Alltrim(CESPECIE) == "NFS"
		if Empty(M->F1_CODNFE)
			msgAlert("Esp�cie informada necessita do C�digo de Verifica��o !","ATEN��O")
			lRet:= .f.
		endif
	endif
	*/
	dbSelectArea("SC7")
	dbSetOrder(14)

	if cTipoPed == "N"
		for nX :=1 to len(aCols)
			if !aCols[nx][nUsado+1]
				if !Empty(aCols[nx][nPosPc])
					if MsSeek(xFilEnt(xFilial("SC7"))+aCols[nx][nPosPc]+aCols[nx][nPosItPc])
						cCondPag := SC7->C7_COND
						if cCondPag <> cCondPed
							if !Empty(cMsgPed)
								cMsgPed += ", "
							endif
							cMsgPed += aCols[nx][nPosPc]
							lRet := .F.
						endif
					endif
				endif
			endif
		next nX

		if !Empty(cMsgPed)
			IW_MsgBox("A(s) condi��o(�es) de pagamento do(s) pedido(s): " + cMsgPed + " est�(�o) diferente(s) da selecionada."+ENTER+ENTER+"Verifique.","Diverg�ncia","STOP")
		endif
	endif


	If lCConduta .and. !alltrim(cEspecie) $ GetMv("CL_ESPNVCC",.F.,"")
		lRet := U_vldCodC(lRet)
	EndIf

	If lRecFis
		lRet := U_vldRecF(lRet)
	EndIf

	//NOTE - VALIDA��O NATUREZA DE RENDIMENTO
	If GetMv("CL_NATRENE",.F.,"N") == "S"
		ValidNtRen(@lRet)
	EndIf

	restArea(aAreaSC7)
	restArea(aArea)
return lRet

// ----------------------------------------------------------------------------------------------------------------------------------------------------------

user function vldCodC(lp_Ret)
	local nX      := 0         as numeric
	local lOK     := lp_Ret    as logical
	local aArea   := GetArea() as array
	local lValida := .T.       as logical

	cQuery := ""
	cQuery += " SELECT TOP 1 CR_DATALIB, CR_STATUS
	cQuery += " FROM " + RetSqlName("SCR") + " SCR WHERE  CR_TIPO = 'NF'
	cQuery += " AND CR_FILIAL = '" + FWxFilial("SCR") + "'
	cQuery += " AND CR_NUM = '" + cNFiscal+cSerie+cA100For+cLoja + "'
	cQuery += " AND D_E_L_E_T_ = ''
	cQuery += " ORDER BY R_E_C_N_O_ DESC
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	If (cTRB)->(!eof())
		If (cTRB)->CR_STATUS == '03'
			lValida := .F.
		EndIf
	EndIf
	(cTRB)->(dbCloseArea())

	If lValida
		For nX := 1 to Len(aCols)
			If !aCols[nX,Len(aHeader)+1]
				If !Empty(alltrim(GDFieldGet("D1_PEDIDO",nX)))
					dbSelectArea("SC7")
					dbSetOrder(1)
					If dbSeek(FWxFilial("SC7") + GDFieldGet("D1_PEDIDO",nX))
						If dDEmissao < SC7->C7_EMISSAO
							FWAlertWarning("Para pedidos de compra emitidos posterior a data de emiss�o da nota fiscal deve ser gerado atrav�s da rotina de pr�-nota.",;
								"Codigo de Conduta")
							lOK := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	RestArea(aArea)
return(lOK)

// ----------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldRecF
Valida��o controle de recebimento Fiscal - bloqueio de inclus�o vi documento de entrada
@type function
@version 12.1.33
@author adm_tla8
@since 08/06/2023
@param lp_Ret, logical, retorno do ponto de entrada
@return logical, retora se passou na valida��o do recebimento fiscal
/*/
user function vldRecF(lp_Ret)
	local lOK     := lp_Ret    as logical
	local aArea   := GetArea() as array
	local lValida := .T.       as logical

	cQuery := ""
	cQuery += " SELECT TOP 1 CR_DATALIB, CR_STATUS
	cQuery += " FROM " + RetSqlName("SCR") + " SCR WHERE  CR_TIPO = 'NF'
	cQuery += " AND CR_FILIAL = '" + FWxFilial("SCR") + "'
	cQuery += " AND CR_NUM = '" + cNFiscal+cSerie+cA100For+cLoja + "'
	cQuery += " AND D_E_L_E_T_ = ''
	cQuery += " ORDER BY R_E_C_N_O_ DESC
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	If (cTRB)->(!eof())
		If (cTRB)->CR_STATUS == '03'
			lValida := .F.
		EndIf
	EndIf
	(cTRB)->(dbCloseArea())

	If lValida
		aBlqRFis := U_RetTRec(cEspecie)
		If len(aBlqRFis) > 0
			lBlqRFis := .F.
			If alltrim(cEspecie) == alltrim(aBlqRFis[1])
				If aBlqRFis[2] == 'P'
					If Substr(dTos(dDEmissao),1,6) != Substr(dTos(Date()),1,6)
						lBlqRFis := .T.
					EndIf
				Else
					nDias := 0
					nDias := DateDiffDay(dDEmissao, Date())
					If nDias > aBlqRFis[3]
						lBlqRFis := .T.
					EndIf
				EndIf
				If lBlqRFis
					FWAlertWarning("Para Nota Fiscal com especie [" + alltrim(cEspecie) + "] lan�ado em per�odo diferente do per�odo de emiss�o " + ;
						"deve ser gerado atrav�s da rotina de pr�-nota.","Bloqueio Nota Fiscal.")
					lOK := .F.
				EndIf
			EndIf

		EndIf
	EndIf

	RestArea(aArea)
return(lOK)

// ----------------------------------------------------------------------------------------------------------------------------------------------------------

user function VldPCCC()
	local lOK     := .T.          as logical
	local cPedido := M->D1_PEDIDO as character
	local aArea   := GetArea()    as array

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(FWxFilial("SC7") + cPedido)
		If dDEmissao > SC7->C7_EMISSAO

			cQuery := ""
			cQuery += " SELECT TOP 1 CR_DATALIB, CR_STATUS
			cQuery += " FROM " + RetSqlName("SCR") + " SCR WHERE  CR_TIPO = 'NF'
			cQuery += " AND CR_FILIAL = '" + FWxFilial("SC5") + "'
			cQuery += " AND CR_NUM = '" + cNFiscal+cSerie+cA100For+cLoja + "'
			cQuery += " AND D_E_L_E_T_ = ''
			cQuery += " ORDER BY R_E_C_N_O_ DESC
			TcQuery cQuery New Alias (cTRB := GetNextAlias())

			dbSelectArea((cTRB))
			If (cTRB)->(eof())
				FWAlertWarning("Para pedidos de compra emitidos posterior a data de emiss�o da nota fiscal deve ser gerado atrav�s da rotina de pr�-nota.",;
					"Codigo de Conduta")
				lOK := .F.
			EndIf
			(cTRB)->(dbCloseArea())
		EndIf
	EndIf

	RestArea(aArea)

return(lOK)

// --------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidNtRen
validacao preenchimento natureza de rendimento
@type function
@version 12.1.210
@author Leandro Cesar
@since 23/10/2023
@param lp_Ret, logical, return da rotina (ok)

OBS.: a chamada da fun��o deve ser feita no ponto de entrada MT100TOK() e a passagem do par�metro � o lRet como refer�ncia do MT100TOK(), ex: ValidNtRen(@lRet)
/*/
static function ValidNtRen(lp_Ret)
	local nPosPrd := aScan(aHeader,{|x| alltrim(x[2]) == 'D1_ITEM' })
	local nX as numeric
	local nY as numeric
	local lRetImp as logical
	bEval := &('{|x| iif(x[6] $ "IRR|COD|PIS|CSL",lRetImp := .T.,nil) }')

	lRetImp := .F.
	aEval( oFisRod:aArray, bEval )


	If lRetImp
		If Empty(aColsDHR)
			Help('',1,'NATREN',,'Nota Fiscal com reten��o de impostos e n�o identificado vinculo com a natureza de rendimento.',1,0)
			lp_Ret := .F.
		Else
			If len(aColsDHR) != len(aCols)
				Help('',1,'NATREN',,'Existem produtos n�o vinculados com a natureza de rendimento.',1,0)
				lp_Ret := .F.
			EndIf
		EndIf

		If lp_Ret
			For nX := 1 to len(aCols)
				For nY := 1 to len(aColsDHR)
					If aColsDHR[nY][1] == aCols[nX,nPosPrd]
						If Empty(aColsDHR[nY][2][1][1])
							Help('',1,'NATREN',,'Nota Fiscal com reten��o de impostos e o item [ ' + aCols[nX,nPosPrd] + ' ] '+;
								'n�o vinculado com a natureza de rendimento.',1,0)
							lp_Ret := .F.
						EndIf
					EndIf
				Next nY
			Next nX
		EndIf
	EndIf

Return()
