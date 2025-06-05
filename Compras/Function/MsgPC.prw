#include "totvs.ch"
/*/{protheus.doc}MsgPC
Monta tela para manutecao da mensagem que constara no Pedido de Compra.                                         
@author Marcos Candido
@since 10/07/2011
/*/
User Function MsgPC(cNumPedido)
	Local cMemo1 := Space(TamSX3("ZB_MSG")[1])
	Local oMemo1
	Local nOpca := 0
	Local oDlgMsg
	Local aAreaAtual := GetArea()
	Local lTem := .F.

	if !FwIsInCallStack("U_IMPPOCOUPA")
		dbSelectArea("SZB")
		dbSetOrder(1)
		If dbSeek(xFilial("SZB")+cNumPedido)
			cMemo1 := SZB->ZB_MSG
			lTem := .T.
		Endif
		DEFINE MSDIALOG oDlgMsg TITLE "Mensagem Complementar para o Pedido de Compra" FROM C(244),C(183) TO C(445),C(600) PIXEL
		@ C(015),C(005) Say "Mensagem" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgMsg
		@ C(025),C(005) GET oMemo1 Var cMemo1 MEMO Size C(200),C(066) PIXEL OF oDlgMsg
		ACTIVATE MSDIALOG oDlgMsg ON INIT EnchoiceBar(oDlgMsg,{|| (nOpca:=1,oDlgMsg:End()) },{||oDlgMsg:End()},,) CENTERED
		If nOpca == 1	
			dbSelectArea("SZB")
			If lTem
				Reclock("SZB",.F.)
			Else
				Reclock("SZB",.T.)
				Replace	ZB_FILIAL	With	xFilial("SZB")
				Replace	ZB_NUMPC	With	cNumPedido
			Endif
			Replace	ZB_MSG	 With	 StrTran(cMemo1,Chr(13)," ")
			MsUnlock()
		Endif
		RestArea(aAreaAtual)
	EndIf
Return

/*
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
*/
Static Function C(nTam)                                                         
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)