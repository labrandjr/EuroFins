#include "totvs.ch"
#Include 'TopConn.ch'


// * Rotina		:	CT102BTO
// * Autor			:	Régis Ferreira
// * Data			:	08/06/2022
// * Descricao		:	PE criação de botões na rotina CTBA102 para aprovação contábil


#Define ENTER       Chr (10) + Chr (13)
#Define PIPE        "|"
#Define FinalLinha  "----------------------------------------------------"

User Function CT102BTO()

	Local   aArea       := GetArea()
	Local   aBtn        := {}
	Local   cUserVal    := GetMv("ZZ_VLBLQCT") // Usuários que podem fazer aprovação ou reprovação contábil
	Local   lAtivaBlq   := GetMv("ZZ_ATBLQCT") // Ativa ou desativa a integração
	Private lValUser    := .T.
	Public  cZZMotivo   := ""
	Public  cZZTpSaldo  := ""
	Public  cZZMemo1    := ""
	Public  cZZUsrHora  := ""

	if ALTERA .and. lAtivaBlq

		if RetCodUsr() $ cUserVal
			Aadd( aBtn, {"Reprovar Lanc. Manual"  ,{ || BlqCT2() },"Reprovar Lanc. Manual"       ,"Reprovar Lanc. Manual"} )
			Aadd( aBtn, {"Aprovar Lanc. Manual"   ,{ || LibCT2() },"Aprovar Lanc. Manual"       ,"Aprovar Lanc. Manual"} )
		endif

	endif
	Aadd( aBtn, {"Visualizar Aprov./Reprov."  ,{ || VisuCT2() },"Visualizar Aprov./Reprov."  ,"Visualizar Aprov./Reprov."} )

	RestArea(aArea)

Return (aBtn)

Static Function BlqCT2()

	Local aArea     := GetArea()
	Local nOpcao    := 0
	Local cMemo1    := Space(TamSX3("ZZI_ZZMOTI")[1])
	Local oMemo1
	Local oDlgMsg
	Local cChave    := ""

	DbSelectArea("TMP")
	TMP->(DbGoTop())
	While TMP->(!EOF())
		cChave := Dtos(TMP->CT2_DATA)+TMP->CT2_LOTE+TMP->CT2_SBLOTE+TMP->CT2_DOC
		Exit
	enddo

	lValUser := ValUser(cChave)

	if !lValUser
		Help(NIL, NIL, "CT102BUT_PE", NIL, cZZMotivo, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Procure o responsável pelo contábil ou outro usuário para aprovação/reprovação deste lote!"})
	else
		DEFINE MSDIALOG oDlgMsg TITLE "Motivo da Recusa" FROM C(244),C(183) TO C(445),C(600) PIXEL
		@ C(015),C(005) Say "Texto" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgMsg
		@ C(025),C(005) GET oMemo1 Var cMemo1 MEMO Size C(200),C(066) PIXEL OF oDlgMsg
		ACTIVATE MSDIALOG oDlgMsg ON INIT EnchoiceBar(oDlgMsg,{|| (nOpcao:=1,oDlgMsg:End()) },{||oDlgMsg:End()},,) CENTERED

		cZZMemo1 := Alltrim(PswChave(RetCodUsr()))+" - "+Alltrim(FwGetUserName(RetCodUsr()))+" - "+Alltrim(dToc(ddatabase))+" - "+Time()+"|"+cMemo1+"|"+FinalLinha+"|"
		cZZMemo1 := Upper(ALltrim(strtran(cZZMemo1,chr(13)+chr(10),"|")))

		if nOpcao = 1

			If Type("cZZTpSaldo") == "C"
				cZZTpSaldo  := "Y"
				//cZZUsrHora   := Alltrim(UsrRetName(__CUSERID)) +" - "+ Alltrim(dToc(Date()))
				cZZUsrHora  := Alltrim(PswChave(RetCodUsr()))+" - "+Alltrim(FwGetUserName(RetCodUsr()))+" - "+Alltrim(dToc(ddatabase))+" - "+Time()
			endif

			// DbSelectArea("TMP")
			// TMP->(DbGoTop())
			// While TMP->(!EOF())
			//     if TMP->(RecLock("TMP",.F.))
			//         TMP->CT2_ZZMOTI  := TMP->CT2_ZZMOTI +PIPE+ cZZMemo1
			//         TMP->CT2_TPSALD  := "Y"
			//         TMP->(MsUnLock())
			//     endif
			//     TMP->(DbSkip())
			// EndDo

			MsgAlert("Motivo da reprova gravado! Salvar", "Atencao")

		Endif
	endif

	RestArea(aArea)

Return

Static Function LibCT2()

	Local aArea     := GetArea()
	Local cChave    := ""
	Local lBlqLib   := .F.

	DbSelectArea("TMP")
	TMP->(DbGoTop())
	While TMP->(!EOF())
		if Alltrim(TMP->CT2_TPSALDO) $ "X/Y"
			lBlqLib := .T.
		endif
		TMP->(DbSkip())
	enddo

	DbSelectArea("TMP")
	TMP->(DbGoTop())
	While TMP->(!EOF())
		cChave := Dtos(TMP->CT2_DATA)+TMP->CT2_LOTE+TMP->CT2_SBLOTE+TMP->CT2_DOC
		Exit
	enddo

	if !lBlqLib
		Help(NIL, NIL, "CT102BUT_PE", NIL, "Esse Lançamento contabil nao esta bloqueado ou reprovado e por isso nao pode ser aprovado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Analise o lançamento a ser aprovado"})
	else
		lValUser := ValUser(cChave)

		if !lValUser
			Help(NIL, NIL, "CT102BUT_PE", NIL, cZZMotivo, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Procure o responsavel pelo contabil ou outro usuario para aprovacao/reprovacao deste lote!"})
		else

			If Type("cZZTpSaldo") == "C"
				If CT2->(FieldPos("CT2_XTTPSL")) > 0
					If !Empty(CT2->CT2_XTTPSL)
						cZZTpSaldo  := CT2->CT2_XTTPSL
					Else
						cZZTpSaldo  := "1"
					EndIf
				Else
					cZZTpSaldo  := "1"
				EndIf
				cZZUsrHora  := Alltrim(PswChave(RetCodUsr()))+" - "+Alltrim(FwGetUserName(RetCodUsr()))+" - "+Alltrim(dToc(ddatabase))+" - "+Time()
			endif

            /*DbSelectArea("TMP")
            TMP->(DbGoTop())
            While TMP->(!EOF())
                if TMP->(RecLock("TMP",.F.))
                    TMP->CT2_TPSALD  := "1"
                    TMP->CT2_ZZAPRO  := cZZUsrHora
                    TMP->(MsUnLock())
                endif
                TMP->(DbSkip())
            EndDo*/

            MsgAlert("Aprovacao realizada! Salvar", "Atencao")
        endif
    endif

    RestArea(aArea)

Return


Static Function ValUser(cChave)

    Local lRet      := .T.
    Local cQuery    := ""
    Local cAlias    := GetNextAlias()

    cQuery := " Select Distinct SUBSTRING(CT2_USERGI, 3, 1)+SUBSTRING(CT2_USERGI, 7, 1)+ SUBSTRING(CT2_USERGI, 11,1)+SUBSTRING(CT2_USERGI, 15,1)+"                                                      + ENTER
    cQuery += " SUBSTRING(CT2_USERGI, 2, 1)+SUBSTRING(CT2_USERGI, 6, 1)+ SUBSTRING(CT2_USERGI, 10,1)+SUBSTRING(CT2_USERGI, 14,1)+ SUBSTRING(CT2_USERGI, 1, 1)+"                                         + ENTER
    cQuery += " SUBSTRING(CT2_USERGI, 5, 1)+ SUBSTRING(CT2_USERGI, 9, 1)+SUBSTRING(CT2_USERGI, 13,1)+ SUBSTRING(CT2_USERGI, 17,1)+SUBSTRING(CT2_USERGI, 4, 1)+ SUBSTRING(CT2_USERGI, 8, 1) CRIACAO "    + ENTER
    cQuery += " FROM "+RetSqlName("CT2") + " CT2 "                                                                                                                                                      + ENTER
    cQuery += " where "                                                                                                                                                                                 + ENTER
    cQuery += "     "+RetSqlDel("CT2")                                                                                                                                                                  + ENTER
    cQuery += "     and CT2_FILIAL = '"+xFilial("CT2")+"'"                                                                                                                                              + ENTER
    cQuery += "     and CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC = '"+cChave+"'"                                                                                                                            + ENTER

    TcQuery cQuery Alias &cAlias New

    While !(cAlias)->(Eof())
        if RetCodUsr() $ (cAlias)->CRIACAO
            lRet    := .F.
            cZZMotivo := "Seu usuario foi quem criou esse lote contabil, por isso nao pode ser bloqueado/reprovado por voce."
        Endif
        (cAlias)->(DbSkip())
    enddo

    (cAlias)->(DbCloseArea())

    if lRet
        cQuery    := ""
        cAlias    := GetNextAlias()

        cQuery := " Select Distinct SUBSTRING(CT2_USERGA, 3, 1)+SUBSTRING(CT2_USERGA, 7, 1)+ SUBSTRING(CT2_USERGA, 11,1)+SUBSTRING(CT2_USERGA, 15,1)+"                                                      + ENTER
        cQuery += " SUBSTRING(CT2_USERGA, 2, 1)+SUBSTRING(CT2_USERGA, 6, 1)+ SUBSTRING(CT2_USERGA, 10,1)+SUBSTRING(CT2_USERGA, 14,1)+ SUBSTRING(CT2_USERGA, 1, 1)+"                                         + ENTER
        cQuery += " SUBSTRING(CT2_USERGA, 5, 1)+ SUBSTRING(CT2_USERGA, 9, 1)+SUBSTRING(CT2_USERGA, 13,1)+ SUBSTRING(CT2_USERGA, 17,1)+SUBSTRING(CT2_USERGA, 4, 1)+ SUBSTRING(CT2_USERGA, 8, 1) ALTERACAO "  + ENTER
        cQuery += " FROM "+RetSqlName("CT2") + " CT2 "                                                                                                                                                      + ENTER
        cQuery += " where "                                                                                                                                                                                 + ENTER
        cQuery += "     "+RetSqlDel("CT2")                                                                                                                                                                  + ENTER
        cQuery += "     and CT2_FILIAL = '"+xFilial("CT2")+"'"                                                                                                                                              + ENTER
        cQuery += "     and CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC = '"+cChave+"'"

        TcQuery cQuery Alias &cAlias New

        While !(cAlias)->(Eof())
            if RetCodUsr() $ (cAlias)->ALTERACAO
                lRet    := .F.
                cZZMotivo := "Seu usuario foi quem alterou esse lote contabil por ultimo, por isso nao pode ser bloqueado/reprovado por voce."
            Endif
            (cAlias)->(DbSkip())
        enddo

        (cAlias)->(DbCloseArea())

    Endif

Return lRet

Static Function VisuCT2()

    Local aArea     := GetArea()
    Local aAreaCT2  := CT2->(GetArea())
    Local aAreaZZI  := ZZI->(GetArea())
    Local cMemo1    := Space(TamSX3("ZZI_ZZMOTI")[1])
    Local oMemo1
	Local oDlgVisu
    Local cChave    := ""

    DbSelectArea("TMP")
    TMP->(DbGoTop())
    While TMP->(!EOF())
        cChave := Dtos(TMP->CT2_DATA)+TMP->CT2_LOTE+TMP->CT2_SBLOTE+TMP->CT2_DOC
        Exit
    enddo

    cZZMemo1 := cMemo1

    ZZI->(dbSetOrder(1))
    if ZZI->(DbSeek(xFilial("ZZI")+Padr(cChave,TamSx3("ZZI_CHAVE")[1])))
        while ZZI->(!EOF()) .and. Alltrim(ZZI->ZZI_CHAVE) == cChave .and. xFilial("ZZI") == ZZI->ZZI_FILIAL
            if !ZZI->ZZI_ZZMOTI $ cZZMemo1
                cZZMemo1 := ZZI->ZZI_ZZMOTI
            endif
            ZZI->(DbSkip())
        enddo
    Endif

    cZZMemo1 := Upper(ALltrim(strtran(cZZMemo1,"|",chr(13)+chr(10))))
    cMemo1 := cZZMemo1

    DEFINE MSDIALOG oDlgVisu TITLE "Motivo da Recusa" FROM C(244),C(183) TO C(445),C(600) PIXEL
    @ C(015),C(005) Say "Texto" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgVisu
    @ C(025),C(005) GET oMemo1 Var cMemo1 MEMO Size C(200),C(066) when .F. PIXEL OF oDlgVisu
    ACTIVATE MSDIALOG oDlgVisu ON INIT EnchoiceBar(oDlgVisu,{|| (oDlgVisu:End()) },{||oDlgVisu:End()},,) CENTERED

    RestArea(aAreaCT2)
    RestArea(aAreaZZI)
    RestArea(aArea)

Return
