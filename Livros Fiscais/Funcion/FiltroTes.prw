#Include "PROTHEUS.CH"

/*/{Protheus.doc} FiltroTES
Filtra o TES de acordo com o tipo de movimento escolhido pelo usuario.
@author Thais Fumagalli
@since 04/01/2018
/*/
User Function FiltroTES
	Local _lRet  	:= .t.

	// Verifica se o tipo de movimento foi informado.
	//If !Empty(acols[n,GDFieldPos("D1_OPER")])
		If FUNNAME()=="MATA103"      // Se for acionado da Nota fiscal de compras
			If !Empty(acols[n,GDFieldPos("D1_OPER")])
				IIF (Alltrim(SF4->F4_ZZTM)==Alltrim(acols[n,GDFieldPos("D1_OPER")]).AND.SF4->F4_MSBLQL=="2",_lRet := .t.,_lRet := .F.)
			EndIf
		ELSEIF FUNNAME()=="MATA121"  // Se for acionado do Pedido de compras
			IIF (Alltrim(SF4->F4_ZZTM)==Alltrim(acols[n,GDFieldPos("C7_OPER")]).AND.SF4->F4_MSBLQL=="2",_lRet := .t.,_lRet := .F.)
		ELSEIF FUNNAME()=="MATA410"  // Se for acionado do Pedido de vendas
			IIF (Alltrim(SF4->F4_ZZTM)==Alltrim(acols[n,GDFieldPos("C6_OPER")]).AND.SF4->F4_MSBLQL=="2",_lRet := .t.,_lRet := .F.)
		ELSEIF FUNNAME()=="VEIXA001" // Se for acionado no Módulo de Veículos - Compra Veículos
			IIF (Alltrim(SF4->F4_ZZTM)==Alltrim(acols[n,GDFieldPos("VVG_OPER")]).AND.SF4->F4_MSBLQL=="2",_lRet := .t.,_lRet := .F.)
		ELSEIF FUNNAME()=="VEIXA018" // Se for acionado no Módulo de Veículos - Venda p/ Concessionarias
			IIF (Alltrim(SF4->F4_ZZTM)==Alltrim(acols[n,GDFieldPos("VV0_OPER")]).AND.SF4->F4_MSBLQL=="2",_lRet := .t.,_lRet := .F.)
		ELSE                         //  Se for acionado de outros modulos
			_lRet := .t.
		EndIF
	//EndIf

Return(_lRet)
