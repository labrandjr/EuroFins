#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} M460MARK
Valida marcacao dos itens para gerar a nota de saida
@author Marcos Candido
@since 02/01/2018
/*/

#Define ENTER  Chr(10) + Chr (13)

User Function M460MARK
	Local lRet        := .T. , lRet2 := .T. , lRet3 := lRet4 := .T. , lRet5 :=.T.
	Local cMarcado    := ThisMark() // ParamIxb[1]
	Local lMarcouTudo := ThisInv()  // ParamIxb[2]
	Local cQuery      := ""
	Local cArqTRB     := CriaTrab(nil,.f.)
	Local aAreaAtual  := GetArea()
	Local cPerg       := Pergunte("MT461A",.F.)
	Local cMsg1 := ""
	Local cMsg2 := "O(s) Produto(s): "
	Local cMsg3 := ", está(ão) com o campo Centro de Custo ou Cod. ISS vazios. Impossível continuar." // Deseja continuar a gerar a nota mesmo assim?"
	Local cMsg4 := ""
	Local cMsg5 := "O(s) Cliente(s): "
	Local cMsg6 := ", indica(m) data limite para faturamento menor que hoje. Impossível continuar."
	Local cMsg7 := ", indica(m) que necessita(m) de pedido de compra. Impossível continuar."
	Local cMsg8 := ""
	Local cMsg9 := "O(s) pedido(s): "
	Local cMsgA := ", indica(m) campos obrigatórios que não foram preenchidos. Verifique os campos C5_FORNISS, C5_ESTPRES e C5_MUNPRES.  Impossível continuar."
	Local cMsgB := ", Código de Iss e/ou Centro de Custo não preenchido no produto: "     
	Local cMsgC :=""
	Local cMsgD := ""
	If (SM0->M0_CODIGO == '01' .or. SM0->M0_CODIGO == '03')
		SB1->(dbSetOrder(1))
		SA1->(dbSetOrder(1))
		If lMarcouTudo
			cQuery := "SELECT * FROM "+RetSqlName("SC9")+" SC9 "
			cQuery += " WHERE SC9.C9_FILIAL ='"+xFilial("SC9")+"' "
			cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
			//If MV_PAR01 == 1
			cQuery += " AND SC9.C9_BLEST<>'10' "
			cQuery += " AND SC9.C9_BLEST<>'ZZ' "
			//EndIf
			//If MV_PAR03 == 1
				cQuery += " AND SC9.C9_PEDIDO >= '"  +MV_PAR05+"' "
				cQuery += " AND SC9.C9_PEDIDO <= '"  +MV_PAR06+"' "
				cQuery += " AND SC9.C9_CLIENTE >= '" +MV_PAR07+"' "
				cQuery += " AND SC9.C9_CLIENTE <= '" +MV_PAR08+"' "
				cQuery += " AND SC9.C9_LOJA >= '"    +MV_PAR09+"' "
				cQuery += " AND SC9.C9_LOJA <= '"    +MV_PAR10+"' "
				cQuery += " AND SC9.C9_DATALIB >= '" +Dtos(MV_PAR11)+"' "
				cQuery += " AND SC9.C9_DATALIB <= '" +Dtos(MV_PAR12)+"' "
				cQuery += " AND SC9.C9_DATENT >= '"  +DToS(MV_PAR14) + "' "
				cQuery += " AND SC9.C9_DATENT <= '"  +DToS(MV_PAR15) + "' "
			//EndIf
		Else
			cQuery := "SELECT * FROM "+RetSqlName("SC9")+" SC9 "
			cQuery += " WHERE SC9.C9_FILIAL ='"+xFilial("SC9")+"' "
			cQuery += " AND SC9.C9_OK = '"+cMarcado+"' "
			cQuery += " AND SC9.D_E_L_E_T_ <> '*'"
		Endif
		TCQuery cQuery NEW ALIAS (cArqTRB)
		dbSelectArea(cArqTRB)
		dbGoTop()
		While !Eof()
			cTipoPV   := Posicione("SC5",1,xFilial("SC5")+(cArqTRB)->C9_PEDIDO,"C5_TIPO")
			If cTipoPV == 'N'
				SB1->(dbSeek(xFilial("SB1")+(cArqTRB)->C9_PRODUTO))
				SA1->(dbSeek(xFilial("SA1")+(cArqTRB)->C9_CLIENTE+(cArqTRB)->C9_LOJA))
				cNumPCCli := Posicione("SC6",1,xFilial("SC6")+(cArqTRB)->(C9_PEDIDO+C9_ITEM+C9_PRODUTO),"C6_PEDCLI")
				//Não deve ter centro de custo preenchido para produtos que movimentam estoque EC/MP
				/*If Empty(SB1->B1_ZZCCUST) .and. !SB1->B1_TIPO $ ("EC/MP")
					If !(Alltrim((cArqTRB)->C9_PRODUTO) $ cMsg1)
						cMsg1 += Iif(!Empty(cMsg1),", ","")+Alltrim((cArqTRB)->C9_PRODUTO)
						lRet := .F.
					Endif
				Endif*/
				/*
				If SB1->B1_TIPO == 'SA'
				If (Empty(SC6->C6_CC).OR.Empty(SC6->C6_CODISS))
				cMsgC += SC5->C5_NUM
				cMsgB += Iif(!Empty(cMsgB),+", ","")+Alltrim((cArqTRB)->C9_PRODUTO) 
				lRet5 := .F.
				Endif
				If SC5->(Empty(C5_FORNISS) .OR. (!Empty(C5_FORNISS) .AND. !C5_FORNISS $ getNewPar("MV_FPADISS",.t.)) .or. Empty(C5_ESTPRES) .or. Empty(C5_MUNPRES))
				cMsg8 += IIf(Empty(cMsg8),'',', ')+SC5->C5_NUM
				lRet4 := .f.
				Endif
				Endif*/
				If SA1->A1_ZZDTFAT > 0 .AND. SA1->A1_ZZDTFAT < 31
					If Day(dDataBase) > SA1->A1_ZZDTFAT
						If !((cArqTRB)->C9_CLIENTE+"/"+(cArqTRB)->C9_LOJA $ cMsg4)
							cMsg4 += Iif(!Empty(cMsg4),", ","")+(cArqTRB)->C9_CLIENTE+"/"+(cArqTRB)->C9_LOJA
							lRet2 := .F.
						Endif
					Endif
				Endif 
				If SA1->A1_ZZPC == 'S' .AND. Empty(cNumPCCLi)
					If !((cArqTRB)->C9_CLIENTE+"/"+(cArqTRB)->C9_LOJA $ cMsg4)
						cMsg4 += Iif(!Empty(cMsg4),", ","")+(cArqTRB)->C9_CLIENTE+"/"+(cArqTRB)->C9_LOJA
						lRet3 := .F.
					Endif
				Endif  
				If !Empty(MsMM(SA1->A1_OBS)) .and. !SA1->(A1_COD+A1_LOJA)$cMsgD
					cMsgD += SA1->(A1_COD+A1_LOJA+"-"+A1_NOME+":"+AllTrim(MSMM(A1_OBS))+CRLF)
				Endif

				Posicione("SC6",1,xFilial("SC6")+SC5->C5_NUM,"")
				While SC6->(!Eof().and.C6_FILIAL == xFilial().and.C6_NUM == SC5->C5_NUM)
					If RetField("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_TIPO == 'SA'")
						If (Empty(SC6->C6_CC).OR.Empty(SC6->C6_CODISS))
                            if !"Produto: "+Alltrim((cArqTRB)->C9_PRODUTO)+" do pedido de venda: "+SC5->C5_NUM+ " com " $ cMsg1
                                    cMsg1 += "Produto: "+Alltrim((cArqTRB)->C9_PRODUTO)+" do pedido de venda: "+SC5->C5_NUM+ " com "
                                    if Empty(SC6->C6_CC)
                                        cMsg1 += "C.Custo em branco"+ENTER
                                    elseif Empty(SC6->C6_CODISS)
                                        cMsg1 += "Cod.ISS em branco"+ENTER
                                    endif
							    //cMsg1 += Iif(!Empty(cMsg1),", ","")+Alltrim((cArqTRB)->C9_PRODUTO)
                            endif
							lRet := .F.
						Endif
						If SC5->(Empty(C5_FORNISS) .OR. (!Empty(C5_FORNISS).AND.!C5_FORNISS$getNewPar("MV_FPADISS",.t.)).or.Empty(C5_ESTPRES).or.Empty(C5_MUNPRES))
							cMsg8 += IIf(Empty(cMsg8),'',', ')+SC5->C5_NUM
							lRet4 := .f.
						Endif
					Endif
					SC6->(DbSkip())
				End
			Endif
			dbSelectArea(cArqTRB)
			dbSkip()
		Enddo
		(cArqTRB)->(dbCloseArea())
		fErase(cArqTRB+GetdbExtension())
		If !lRet
			//MsgStop("Atenção",cMsg2+cMsg1+cMsg3,{"Sair"},1,"Importante")
            MsgStop(cMsg2+cMsg1+cMsg3,"Atenção")
		Endif
		If !lRet2
			//MsgStop("Atenção",cMsg5+cMsg4+cMsg6,{"Sair"},1,"Importante")
            MsgStop(cMsg5+cMsg4+cMsg6,"Atenção")
			lRet := lRet2
		Endif
		If !lRet3
			//MsgStop("Atenção",cMsg5+cMsg4+cMsg7,{"Sair"},1,"Importante")
            MsgStop(cMsg5+cMsg4+cMsg7,"Atenção")
			lRet := lRet3
		Endif
		If !lRet4
			//MsgStop("Atenção",cMsg9+cMsg8+cMsgA,{"Sair"},1,"Importante")
            MsgStop(cMsg9+cMsg8+cMsgA,"Atenção")
			lRet := lRet4
		Endif
		If !lRet5
			//MsgStop("Atenção",cMsg9+cMsgC+cMsgB,{"Sair"},1,"Importante")
            MsgStop(cMsg9+cMsgC+cMsgB,"Atenção")
			lRet := lRet5
		Endif
	Elseif SM0->M0_CODIGO == '05'
		SA1->(dbSetOrder(1))
		If lMarcouTudo
			cQuery := "SELECT * FROM "+RetSqlName("SC9")+" SC9 "
			cQuery += " WHERE SC9.C9_FILIAL ='"+xFilial("SC9")+"' "
			cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
			cQuery += " AND SC9.C9_BLEST<>'10' "
			cQuery += " AND SC9.C9_BLEST<>'ZZ' "
			If MV_PAR03 == 1
				cQuery += " AND SC9.C9_PEDIDO >= '"  +MV_PAR05+"' "
				cQuery += " AND SC9.C9_PEDIDO <= '"  +MV_PAR06+"' "
				cQuery += " AND SC9.C9_CLIENTE >= '" +MV_PAR07+"' "
				cQuery += " AND SC9.C9_CLIENTE <= '" +MV_PAR08+"' "
				cQuery += " AND SC9.C9_LOJA >= '"    +MV_PAR09+"' "
				cQuery += " AND SC9.C9_LOJA <= '"    +MV_PAR10+"' "
				cQuery += " AND SC9.C9_DATALIB >= '" +Dtos(MV_PAR11)+"' "
				cQuery += " AND SC9.C9_DATALIB <= '" +Dtos(MV_PAR12)+"' "
				cQuery += " AND SC9.C9_DATENT >= '"  +DToS(MV_PAR14) + "' "
				cQuery += " AND SC9.C9_DATENT <= '"  +DToS(MV_PAR15) + "' "
			EndIf
		Else
			cQuery := "SELECT * FROM "+RetSqlName("SC9")+" SC9 "
			cQuery += " WHERE SC9.C9_FILIAL ='"+xFilial("SC9")+"' "
			cQuery += " AND SC9.C9_OK = '"+cMarcado+"' "
			cQuery += " AND SC9.D_E_L_E_T_ <> '*'"
		Endif
		TCQuery cQuery NEW ALIAS (cArqTRB)
		dbSelectArea(cArqTRB)
		dbGoTop()
		While !Eof()
			cTipoPV   := Posicione("SC5",1,xFilial("SC5")+(cArqTRB)->C9_PEDIDO,"C5_TIPO")
			If cTipoPV == 'N'
				SA1->(dbSeek(xFilial("SA1")+(cArqTRB)->C9_CLIENTE+(cArqTRB)->C9_LOJA))
				If SA1->A1_ZZDTFAT > 0 .AND. SA1->A1_ZZDTFAT < 31
					If Day(dDataBase) > SA1->A1_ZZDTFAT
						If !((cArqTRB)->C9_CLIENTE+"/"+(cArqTRB)->C9_LOJA $ cMsg4)
							cMsg4 += Iif(!Empty(cMsg4),", ","")+(cArqTRB)->C9_CLIENTE+"/"+(cArqTRB)->C9_LOJA
							lRet2 := .F.
						Endif
					Endif
				Endif
				Posicione("SC6",1,xFilial("SC6")+SC5->C5_NUM,"")
				While SC6->(!Eof().and.C6_FILIAL == xFilial().and.C6_NUM == SC5->C5_NUM)
					If RetField("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_TIPO == 'SA'")
						If (Empty(SC6->C6_CC).OR.Empty(SC6->C6_CODISS))
							cMsg1 += Iif(!Empty(cMsg1),", ","")+Alltrim((cArqTRB)->C9_PRODUTO)
							lRet4 := .F.
						Endif
						If SC5->(Empty(C5_FORNISS) .OR. (!Empty(C5_FORNISS).AND.!C5_FORNISS$getNewPar("MV_FPADISS",.t.)).or.Empty(C5_ESTPRES).or.Empty(C5_MUNPRES))
							cMsg8 += IIf(Empty(cMsg8),'',', ')+SC5->C5_NUM
							lRet4 := .f.
						Endif
					Endif
					SC6->(DbSkip())
				End
			Endif
			dbSelectArea(cArqTRB)
			dbSkip()
		Enddo
		(cArqTRB)->(dbCloseArea())
		fErase(cArqTRB+GetdbExtension())
		If !lRet
			//MsgStop("Atenção",cMsg5+cMsg4+cMsg6,{"Sair"},1,"Importante")
            MsgStop(cMsg5+cMsg4+cMsg6,"Atenção")
		Endif
		If !lRet2
			//MsgStop("Atenção",cMsg5+cMsg4+cMsg6,{"Sair"},1,"Importante")
            MsgStop(cMsg5+cMsg4+cMsg6,"Atenção")
			lRet := lRet2
		Endif
		If !lRet4
			//MsgStop("Atenção",cMsg9+cMsg8+cMsgA,{"Sair"},1,"Importante")
            MsgStop(cMsg9+cMsg8+cMsgA,"Atenção")
			lRet := lRet4
		Endif
	Endif    
	If !Empty(cMsgD) .and. lRet
		lRet := MsgYesNo("Há observações para os clientes abaixo:"+CRLF+cMsgD,"<H4>Confirma?</h4>")
	Endif
	RestArea(aAreaAtual)
	Pergunte("MT460A",.F.)
Return lRet
