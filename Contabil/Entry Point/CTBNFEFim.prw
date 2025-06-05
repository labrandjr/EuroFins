#include 'totvs.ch'

/*/{Protheus.doc} CTBNFEFim
Ponto de entrada final da contbilização de nota fiscal de entrada
@type function
@version 12.1.33
@author Leandro Cesar
@since 3/10/2023
/*/
User Function CTBNFEFim()
	// local nTipoCtb := ParamIxb[1] // Gerados Lancamentos Por   1=Docto 2=Periodo 3=Dia
	// local dDataIni := ParamIxb[2] // Data Inicial do processamento
	local dDataFim := ParamIxb[3] // Data Final do processamento
	local cFilDe   := ParamIxb[4] // Filial inicial do processamento
	local cFilAte  := ParamIxb[5] // Filial Final do processamento
	// local lContNCC := ParamIxb[6] // Verifica se contabiliza ou nao as notas de credito (pais dif. de Brasil)
	// local lEnd     := ParamIxb[6] // Indica se processamento foi abortado
	Local aSM0 		:= AdmAbreSM0()
	local nContFil  := 0
	local aAreaAux := FwGetArea()
	local aAreaSX6 := SX6->(FwGetArea())

    //NOTE desativado a pedido do Fabio Kimura
    //NOTE por Leandro Cesar - 10/04/2023
	// For nContFil := 1 to Len(aSM0)

	// 	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
	// 		Loop
	// 	EndIf

	// 	dbSelectArea("SX6")
	// 	dbSetOrder(1)
	// 	If MsSeek(aSM0[nContFil][SM0_CODFIL]+"MV_DATAFIS")
	// 		RecLock("SX6",.F.)
	// 		SX6->X6_CONTEUD := dTos(dDataFim)
	// 		SX6->X6_CONTSPA := dTos(dDataFim)
	// 		SX6->X6_CONTENG := dTos(dDataFim)
	// 		dbCommit()
	// 		MsUnLock()
	// 	EndIf

	// 	dbSelectArea("SX6")
	// 	dbSetOrder(1)
	// 	If MsSeek(aSM0[nContFil][SM0_CODFIL]+"MV_DATAFIN")
	// 		RecLock("SX6",.F.)
	// 		SX6->X6_CONTEUD := dTos(dDataFim)
	// 		SX6->X6_CONTSPA := dTos(dDataFim)
	// 		SX6->X6_CONTENG := dTos(dDataFim)
	// 		dbCommit()
	// 		MsUnLock()
	// 	EndIf

	// 	dbSelectArea("SX6")
	// 	dbSetOrder(1)
	// 	If MsSeek(aSM0[nContFil][SM0_CODFIL]+"MV_DATAREC")
	// 		RecLock("SX6",.F.)
	// 		SX6->X6_CONTEUD := dTos(dDataFim)
	// 		SX6->X6_CONTSPA := dTos(dDataFim)
	// 		SX6->X6_CONTENG := dTos(dDataFim)
	// 		dbCommit()
	// 		MsUnLock()
	// 	EndIf


	// Next nContFil

	FwRestArea(aAreaSX6)
	FwRestArea(aAreaAux)

Return NIL
