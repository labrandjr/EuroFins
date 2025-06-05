#include "totvs.ch"
#include "protheus.ch"
#include 'Topconn.ch'

/*/{Protheus.doc} MA410MNU
Inclusão de rotinas no menu do pedido de venda 
@author Unknown
@since 26/06/2022
/*/

User Function MA410MNU
	
	Local aArea := GetArea() 

	aadd(aRotina,{'# Excluir Vários Pedidos' ,'U_IPEXCPV()' , 0 , 4,0,NIL})

	RestArea(aArea)

Return

User Function IPEXCPV()

	Private oProcess	:= Nil

	If Pergs()
		oProcess:= MsNewProcess():New({|| ExcluiPV()}, "Excluindo Pedidos", "...", .F.)
		oProcess:ACTIVATE()
	endif

Return

Static Function ExcluiPV()

	Local cQuery 		:= ""
	Local cAlias 		:= GetNextAlias()
	Local aArea			:= GetArea()
	Local aAreaSC5		:= SC5->(GetArea())
	Local aAreaSC6		:= SC6->(GetArea())
	Local aCab			:= {}
	Local aItens		:= {}
	Local lRet			:= .T.
	Local nRegs			:= 0
	Local nContador 	:= 0
	
	Private lMsErroAuto := .F.

	cQuery := " Select " + CRLF
	cQuery += " 	C5_NUM " + CRLF
	cQuery += " From "+RetSqlName("SC5")+ " SC5 " + CRLF
	cQuery += " Where " + CRLF
	cQuery += " 	1=1 " + CRLF
	cQuery += " 	And C5_CLIENTE between '"+MV_PAR01+"' and '"+MV_PAR03+"' " + CRLF
	cQuery += " 	And C5_LOJACLI between '"+MV_PAR02+"' and '"+MV_PAR04+"' " + CRLF
	cQuery += " 	And C5_NUM 	   between '"+MV_PAR05+"' and '"+MV_PAR06+"' " + CRLF
	cQuery += " 	And ((C5_LIBEROK = '' and C5_NOTA = '' and C5_BLQ = '')  " + CRLF
	cQuery += " 		Or (C5_LIBEROK <> '' and C5_NOTA = '' and C5_BLQ = ''))  " + CRLF
	cQuery += " 	And C5_FILIAL = '"+xFilial("SC5")+"' " + CRLF
	cQuery += " 	And D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " Order by C5_NUM " + CRLF

	TCQuery cQuery New Alias &(cAlias)
	Count to nRegs

	oProcess:SetRegua1(nRegs)

	if nRegs <= 0
		MsgAlert("Não há pedidos a serem excluídos!")
	else
		(cAlias)->(DbGotop())
		while (cAlias)->(!Eof())
			
			lRet := .T.
			nContador ++
			oProcess:IncRegua1("Pedido de Venda "+CValToChar(nContador)+" de "+CValToChar(nRegs))

			aCab 	:= {}
			aItens	:= {}
			oProcess:IncRegua2("Alterando o pedido "+CValToChar(nContador)+" de "+CValToChar(nRegs))
			lRet := AltPv((cAlias)->C5_NUM,@aCab,@aItens)
			if lRet
				oProcess:IncRegua2("Excluindo o pedido "+CValToChar(nContador)+" de "+CValToChar(nRegs))
				lRet := ExcPv(@aCab,@aItens)
			endif
			(cAlias)->(DbSkip())

		Enddo
	endif

	(cAlias)->(DBCloseArea())

	SC6->(RestArea(aAreaSC6))
	SC5->(RestArea(aAreaSC5))
	RestArea(aArea)

Return

Static Function Pergs()

	Local aParambox	:= {}
	aAdd(aParamBox,{1,"Cliente de:" 		,CriaVar("C5_CLIENTE",.f.),"","","SA1",""	,70,.F.}) //MV_PAR01
	aAdd(aParamBox,{1,"Loja de:" 			,CriaVar("C5_LOJACLI",.f.),"","","",""		,70,.F.}) //MV_PAR02
	aAdd(aParamBox,{1,"Cliente até:"		,CriaVar("C5_CLIENTE",.f.),"","","SA1",""	,70,.T.}) //MV_PAR03
	aAdd(aParamBox,{1,"Loja até:" 			,CriaVar("C5_LOJACLI",.f.),"","","",""		,70,.T.}) //MV_PAR04
	aAdd(aParamBox,{1,"Pedido de:" 			,CriaVar("C5_NUM",.f.),"","","SC5",""		,70,.F.}) //MV_PAR04
	aAdd(aParamBox,{1,"Pedido até:" 		,CriaVar("C5_NUM",.f.),"","","SC5",""		,70,.T.}) //MV_PAR04

Return ParamBox(aParamBox,"Exclusão de Pedidos de Venda",,,,,,,,ProcName(),.T.,.T.)


Static Function AltPv(cNumPV,aCab,aItens)

	Local lRet := .T.
	Local aAuxItens	:= {}

	SC5->(DbSetOrder(1))
	if SC5->(DbSeek(xFilial("SC5")+cNumPV))
		aadd(aCab,{"C5_NUM"		,SC5->C5_NUM	,Nil})
		aadd(aCab,{"C5_TIPO"   	,SC5->C5_TIPO	, Nil})
		aadd(aCab,{"C5_CLIENTE"	,SC5->C5_CLIENTE, Nil})
		aadd(aCab,{"C5_LOJACLI"	,SC5->C5_LOJACLI, Nil})
		aadd(aCab,{"C5_LOJAENT"	,SC5->C5_LOJAENT, Nil})
		aadd(aCab,{"C5_CONDPAG"	,SC5->C5_CONDPAG, Nil})

	Endif
	
	SC6->(DbSetOrder(1))
	if SC6->(DbSeek(xFilial("SC6")+cNumPV))
		while SC6->(!Eof()) .and. xfilial("SC6") == SC6->C6_FILIAL .and. cNumPV == SC6->C6_NUM

			aAuxItens := {}
			aadd(aAuxItens,{"LINPOS"    , "C6_ITEM"		, SC6->C6_ITEM })
			aadd(aAuxItens,{"AUTDELETA" , "N"      		, Nil          })
			aadd(aAuxItens,{"C6_PRODUTO", SC6->C6_PRODUTO  , Nil          })
			aadd(aAuxItens,{"C6_QTDVEN" , SC6->C6_QTDVEN   , Nil          })
			aadd(aAuxItens,{"C6_PRCVEN" , SC6->C6_PRCVEN   , Nil          })
			aadd(aAuxItens,{"C6_PRUNIT" , SC6->C6_PRUNIT   , Nil          })
			aadd(aAuxItens,{"C6_VALOR"  , SC6->C6_VALOR    , Nil          })
			aadd(aAuxItens,{"C6_TES"    , SC6->C6_TES   	, Nil          })
			aadd(aItens, aAuxItens)
			SC6->(DbSkip())

		enddo

	endif

	Begin Transaction
	
	lMsErroAuto    := .F.
	if !Empty(aCab) .and. !Empty(aItens)
		MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCab, aItens, 4, .F.)

		If lMsErroAuto
			MsgAlert("Erro na alteração do pedido de venda")
			MOSTRAERRO()
			lRet := .F.
			DisarmTransaction()
		EndIf
	endif

	End Transaction

Return lRet

Static Function ExcPv(aCab,aItens)

	Local lRet := .T.

	Begin Transaction
	
	lMsErroAuto    := .F.
	if !Empty(aCab) .and. !Empty(aItens)
		MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCab, aItens, 5, .F.)

		If lMsErroAuto
			MsgAlert("Erro na Exclusão do pedido de venda")
			MOSTRAERRO()
			lRet := .F.
			DisarmTransaction()
		EndIf
	endif

	End Transaction

Return lRet
