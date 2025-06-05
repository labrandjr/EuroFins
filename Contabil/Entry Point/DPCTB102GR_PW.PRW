#INCLUDE "totvs.ch"

#Define ENTER Chr(10) + Chr (13)


// * Rotina		:	DPCTB102GR
// * Autor			:	Régis Ferreira
// * Data			:	08/06/2022
// * Descricao		:	PE utilizado após a gravacao do lancamento contábil


User Function DPCTB102GR()

	Local aArea 	    := GetArea()
	Local aAreaCT2 	    := CT2->(GetArea())
	Local aAreaZZI 	    := ZZI->(GetArea())
	Local nOpcao        := Paramixb[1]
	Local dDatLC        := Paramixb[2]
	Local cLote         := Paramixb[3]
	Local cSubLt        := Paramixb[4]
	Local cDoc          := Paramixb[5]
	Local cMsgMot       := ""
	Local cMsgAprov     := ""
	Local lAtivaBlq     := GetMv("ZZ_ATBLQCT") // Ativa ou desativa a integração
	Default cZZTpSaldo  := ""
	Default cZZUsrHora  := ""
	Default cZZMemo1    := ""

	if lAtivaBlq

		if IsInCallStack("CTBA102") .or. IsInCallStack("CTBA500")

			// Se alteracao ou alteração
			If (nOpcao == 4 .or. nOpcao == 3 .or. nOpcao == 7) //.and. Empty(cZZTpSaldo)
				CT2->(dbSetOrder(1))
				if CT2->(DbSeek(xFilial("CT2")+dtos(dDatLC)+cLote+cSublt+cDoc))
					while CT2->(!EOF()) .and. dDatLC == CT2->CT2_DATA .and. cLote == CT2->CT2_LOTE .and. cSublt == CT2->CT2_SBLOTE .and. cDoc == CT2->CT2_DOC .and. xFilial("CT2") == CT2->CT2_FILIAL

						if CT2->(RecLock("CT2",.F.))
							If CT2->(FieldPos("CT2_XTTPSL")) > 0
								If CT2->CT2_TPSALDO == '3'
									CT2->CT2_XTTPSL := CT2->CT2_TPSALDO
								EndIf
							EndIf
							CT2->CT2_TPSALD := padr("X",TamSx3("CT2_TPSALD")[1])
							CT2->CT2_MANUAL := '1'
							CT2->(MsUnLock())
						endif

						CT2->(DbSkip())
					EndDo
				endif
			EndIf

			// Se alteracao ou alteração
			If nOpcao == 4 .and. (cZZTpSaldo == "Y" .or. cZZTpSaldo == "X" .or. cZZTpSaldo == "1" .or. cZZTpSaldo == "3")
				CT2->(dbSetOrder(1))
				if CT2->(DbSeek(xFilial("CT2")+dtos(dDatLC)+cLote+cSublt+cDoc))
					while CT2->(!EOF()) .and. dDatLC == CT2->CT2_DATA .and. cLote == CT2->CT2_LOTE .and. cSublt == CT2->CT2_SBLOTE .and. cDoc == CT2->CT2_DOC .and. xFilial("CT2") == CT2->CT2_FILIAL

						if CT2->(RecLock("CT2",.F.))
							CT2->CT2_TPSALD := padr(cZZTpSaldo,TamSx3("CT2_TPSALD")[1])
							CT2->CT2_MANUAL := '1'
							cMsgMot     := cZZMemo1
							cMsgAprov   := cZZUsrHora

                            /*cMsgMot := ""
                            if cZZTpSaldo == "1"
                                if Empty(CT2->CT2_ZZAPRO)
                                cMsgMot := cZZUsrHora
                                else
                                    cMsgMot := Alltrim(CT2->CT2_ZZAPRO) +" | "+ cZZUsrHora
                                endif
                                //CT2->CT2_ZZAPRO := cMsg
                            endif

                            if Empty(CT2->CT2_ZZMOTI)
                                cMsgAprov := cZZMemo1
                            else
                                cMsgAprov := Alltrim(CT2->CT2_ZZMOTI)+" | "+cZZMemo1
                            endif
                            //CT2->CT2_ZZMOTI := cMsg*/
                            CT2->(MsUnLock())
                        endif

                        CT2->(DbSkip())
                    EndDo
                endif
            EndIf

            //Caso tenha aprovador ou motivo preenchido, irá preenchar a tabela ZZI
            if !Empty(cMsgAprov) .or. !Empty(cMsgMot)

                ZZI->(DbSetOrder(1))
                if ZZI->(DbSeek(xFilial("ZZI")+padr(dtos(dDatLC)+cLote+cSublt+cDoc,TamSX3("ZZI_CHAVE")[1])))
                    cMsgMot     := ZZI->ZZI_ZZMOTI +"|"+ cMsgMot
                    cMsgAprov   := ZZI->ZZI_ZZAPRO +"|"+ cMsgAprov
                    if ZZI->(RecLock("ZZI", .F.))

                        ZZI->ZZI_ZZMOTI := cMsgMot
                        if cZZTpSaldo == "1"
                            ZZI->ZZI_ZZAPRO := cMsgAprov
                        endif

                        ZZI->(MsUnlock())
                    endif
                else
                    if ZZI->(RecLock("ZZI", .T.))
                        ZZI->ZZI_FILIAL := xfilial("ZZI")
                        ZZI->ZZI_CHAVE  := Alltrim(dtos(dDatLC)+cLote+cSublt+cDoc)
                        ZZI->ZZI_ZZMOTI := cMsgMot
                        if cZZTpSaldo == "1"
                            ZZI->ZZI_ZZAPRO := cMsgAprov
                        endif
                        ZZI->(MsUnlock())
                    endif
                endif
            endif

            //Caso seja exclusão, será excluído também da tabela ZZI
            if nOpcao == 5
                ZZI->(DbSetOrder(1))
                if ZZI->(DbSeek(padr(xFilial("ZZI")+dtos(dDatLC)+cLote+cSublt+cDoc,TamSX3("ZZI_CHAVE")[1])))
                    if ZZI->(RecLock("ZZI", .F.))
                        ZZI->(DbDelete())
                        ZZI->(MsUnlock())
                    endif
                endif

            endif

            ExecLibX5(dDatLC,dDatLC)
        endif
    endif

	RestArea(aArea)
    RestArea(aAreaCT2)
    RestArea(aAreaZZI)

Return

Static Function ExecLibX5(dDatLC,dDatLC)

    Local aAreaSX5 := SX5->(GetArea())

    SX5->(DBSetOrder(1))
    SX5->(DBGoTop())
    SX5->(DBSeek(xFilial("SX5")+"SL") )
    While SX5->(!EOF()) .And. SX5->( X5_FILIAL + X5_TABELA ) == xFilial("SX5") + "SL"
        FWMsgRun(, {|| CTBA190( .T., dDatLC, dDatLC,,, SX5->X5_CHAVE, .F.,"", .F. )}, "Reprocessando Período", "Reprocessando Tipo de Saldo - "+Alltrim(Upper(SX5->X5_DESCRI))+" ... ")
        SX5->(DbSkip())
    Enddo

    RestArea(aAreaSX5)

Return
