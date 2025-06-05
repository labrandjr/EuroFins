#Include 'Protheus.ch'
#Include "totvs.ch"
#include "tbiconn.ch"
#Include "TopConn.ch"

/*/{protheus.doc}
Gera planilha com registros com a tabela CVD com a CT1
@author Régis Ferreira
@since 10/03/2022
/*/
User Function ZZRELCVD()

    If MsgYesNo("Gerar Relatório de De/Para de Plano de Contas (tabela CVD) ??")
        Processa({||GeraPlan() },"Gerando Planilha..." )
    Endif

Return

Static Function GeraPlan
    Local nRegs
    Local cArqNome	:= GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
    Local cTitulo	:= "De/Para Plano de Contas"
    Local aCampos, cCampos,cAlias
    Local oExcel,nAlign,nType,i
    Local nContador := 0
    Local cQuery    := ""
    Local aCab := StrToKarr("Conta Contábil;Descrição da conta contábil;Condição Normal;Conta Referencial;Conta Superior;Cod. Plano de Contas",";")
            cQuery := " Select "+ CRLF
            cQuery += "     CVD_CONTA, "+ CRLF
            cQuery += "     CT1_DESC01, "+ CRLF
            cQuery += "     CT1_NORMAL, "+ CRLF
            cQuery += "     CVD_CTAREF, "+ CRLF
            cQuery += "     CVD_CTASUP, "+ CRLF
            cQuery += "     CVD_CTASUP, "+ CRLF
            cQuery += "     CVD_CODPLA " + CRLF
            cQuery += " from  "+ CRLF
            cQuery  += "    " + RetsqlTab("CVD") + CRLF
            cQuery += "     inner join " + RetsqlTab("CT1") + " on CT1_CONTA = CVD_CONTA AND CT1.D_E_L_E_T_ = ' ' "+ CRLF
            cQuery += " where "+ CRLF
            cQuery += "     CVD.D_E_L_E_T_ = ' ' "+ CRLF
            cQuery += "     and CVD_CODPLA like 'M02' "+ CRLF

    If Select("RELCVD") > 0
        RELCVD->(DbCloseArea())
    EndIf

    TcQuery cQuery New Alias "RELCVD"

    Count to nRegs
    ProcRegua(nRegs)
    If nRegs==0
        MsgAlert("Não existe informações para gerar Planilha !","Atenção")
    Else
        cCampos := "CVD_CONTA,CT1_DESC01,CT1_NORMAL,CVD_CTAREF,CVD_CTASUP,CVD_CODPLA"
        aCampos := StrToKarr(cCampos,",")
        oExcel := FWMSEXCEL():New()
        oExcel:AddworkSheet(cTitulo)
        oExcel:AddTable(cTitulo,cTitulo)
        For i:=1 To Len(aCampos)
            cAlias := IIf(At("_",aCampos[i])==3,"S"+Left(aCampos[i],2),Left(aCampos[i],3))
            If ValType(&(cAlias+'->'+aCampos[i])) == "D"
                nAlign := 2
                nType  := 4
            ElseIf ValType(&(cAlias+'->'+aCampos[i])) == "N"
                nAlign := 3
                nType  := 2
            Else
                nAlign := 1
                nType  := 1
            Endif
            oExcel:AddColumn(cTitulo,cTitulo,aCab[i],nAlign,nType,.f.)
        Next
        RELCVD->(DbGoTop())
        While !RELCVD->(Eof())
            nContador := nContador +1 
            oExcel:AddRow(cTitulo, cTitulo, {;
                            RELCVD->CVD_CONTA,;
                            RELCVD->CT1_DESC01,;
                            RELCVD->CT1_NORMAL,;
                            RELCVD->CVD_CTAREF,;
                            RELCVD->CVD_CTASUP,;
                            RELCVD->CVD_CODPLA;                           
		    })
            IncProc( "Processando registro "+Alltrim(Str(nContador))+" de "+Alltrim(Str(nRegs)))
            RELCVD->(DbSkip())
        End
        RELCVD->(DbCloseArea())
        oExcel:Activate()
        oExcel:GetXMLFile(cArqNome)
        If File(cArqNome)
            If MsgYesNo("Abrir arquivo "+cArqNome+"?","Concluido")
                ShellExecute("Open",cArqNome,"","",1)
            Endif
        Endif
    Endif
Return
