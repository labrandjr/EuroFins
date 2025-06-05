#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#include 'topconn.ch'

/*/{Protheus.doc} GOODRECEIPT
Gera csv no servidor para integração de recebimento de mercadorias
@author Tiago Maniero
@since 29/05/2020
/*/
User Function GoodReceipt(lForce,lEstorno)

    local aArea     := getArea()
    local aAreaC7   := SC7->(getArea())
    local aAreaSD1  := SD1->(GetArea())

    default lForce      := .F.
    default lDelete     := lEstorno

    geraLog( Replicate("*",30) )
    geraLog( "Inicio Rotina" )

    if !lDelete
        geraLog("Chamada pela rotina MATA140")
    elseif lDelete
        geraLog("Chamada pela rotina U_SF1100E")
    else
        geraLog("Rotina: " + ProcName(1))
    endif

    SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
    SC7->(DbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

    montaCsv(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)

    /*
    If SD1->(DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ))
        if SC7->(DbSeek(SD1->D1_FILIAL+SD1->D1_PEDIDO))
            If lForce
                montaCsv(SF1->F1_DOC,SF1->F1_SERIE,SC7->C7_FORNECE,SC7->C7_LOJA)
            else
                if SC7->C7_ZZINTCO == "S"
                    montaCsv(SF1->F1_DOC,SF1->F1_SERIE,SC7->C7_FORNECE,SC7->C7_LOJA)
                endif
            endif
        endif
    endif
    */

    geraLog( "Final Rotina" )
    geraLog( Replicate("*",30) )

    RestArea(aArea)
    RestArea(aAreaC7)
    RestArea(aAreaSD1)

Return


Static Function montaCsv(cDoc,cSerie,cFornecedor,cLoja)

    local oFile
    local cAlias    := ""
    local cArq      := ""
    local cAdress   := ""
    local cLinArq   := ""
    Local oLibCoupa := nil

    oLibCoupa		:= LibCoupa():new()
	oLibCoupa:seqEntradaNF()

    cAlias  := SelectProdutos(cDoc,cSerie,cFornecedor,cLoja)
    cAdress := (cAlias)->ADDRESS

    if (cAlias)->(!EoF())
        cArq := "GR_BR-PR_" + DtoS(dDatabase) + StrTran(Time(),":","") + "_" + cAdress + FWUUIDV4(.T.) +".csv"
        oFile :=  ManagerTXT():New("\coupa\OUTGOING\pendente\" + cArq)
        oFile:CRIARTXT()

        cLinArq     := "Quantity,"              //1
        cLinArq     += "Type,"                  //2
        cLinArq     += "Order Line ID,"         //3
        cLinArq     += "Order Line Number,"     //4
        cLinArq     += "Order Line PO ID,"      //5
        cLinArq     += "Status,"                //6
        cLinArq     += "Match Reference,"       //7
        cLinArq     += "External Id"            //8

        //oFile:INCLINHA("Quantity,Type,Order Line ID,Order Line Number,Order Line PO ID,Status,Match Reference,External Id")
        oFile:INCLINHA( cLinArq )

        geraLog("Criando o arquivo: " + "\coupa\OUTGOING\pendente\" + cArq )

        CompLinhas(@oFile,cAlias)

        oFile:FechaArquivo()

        GravaZZD("\coupa\OUTGOING\pendente\",cArq,cDoc,"")
    endIf

Return

Static Function SelectProdutos(cDoc,cSerie,cFornecedor,cLoja)

    local cQuery    := ""
    local cAlias    := GetNextAlias()
    local nQtdTotal := 0

    cQuery += "Select DISTINCT D1_FILIAL,D1_COD,D1_QUANT,D1_QTSEGUM,C7_ITEM,D1_ZZSQCOU,C7_ZZCCOUP,D1_PEDIDO,D1_ITEM, ISNULL(ZZC.ZZC_LE,ZZC_1.ZZC_LE) ADDRESS " + CRLF
    cQuery += " FROM " + RetSqlTab("SD1") + CRLF
    cQuery += "    INNER JOIN " + RetSqlTab("SF1") + CRLF
    cQuery += "     ON D1_DOC = F1_DOC " + CRLF
    cQuery += "        AND D1_SERIE = F1_SERIE " + CRLF
    cQuery += "        AND D1_FILIAL = F1_FILIAL " + CRLF
    cQuery += "        AND D1_FORNECE = F1_FORNECE " + CRLF
    cQuery += "        AND D1_LOJA = F1_LOJA " + CRLF
    cQuery += "        AND SF1.D_E_L_E_T_ = ' ' "
    cQuery += "    INNER JOIN " + RetSqlTab("SA2") + CRLF
    cQuery += "     ON A2_COD = D1_FORNECE " + CRLF
    cQuery += "        AND A2_LOJA = D1_LOJA " + CRLF
    cQuery += "        AND SA2.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "    INNER JOIN " + RetSqlTab("SC7") + CRLF
    cQuery += "     ON  D1_FORNECE = C7_FORNECE " + CRLF
    cQuery += "        AND D1_FILIAL = C7_FILIAL " + CRLF
    //cQuery += "        AND D1_LOJA = C7_LOJA " + CRLF
    cQuery += "        AND D1_PEDIDO = C7_NUM " + CRLF
    cQuery += "        AND D1_ITEMPC = C7_ITEM " + CRLF
    cQuery += "        AND D1_COD = C7_PRODUTO " + CRLF
    cQuery += "        AND SC7.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += "    LEFT JOIN " + RetSqlTab("SCH") + CRLF
    cQuery += "     ON  CH_FORNECE = C7_FORNECE " + CRLF
    cQuery += "        AND CH_LOJA = C7_LOJA " + CRLF
    cQuery += "        AND CH_PEDIDO = C7_NUM " + CRLF
    cQuery += "        AND CH_ITEMPD = C7_ITEM " + CRLF
    cQuery += "        AND CH_FILIAL = C7_FILIAL " + CRLF
    cQuery += "        AND SCH.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "		LEFT JOIN " + RetSqlTab("ZZC") + CRLF
    cQuery += "		    ON  ZZC.ZZC_FILCLI     = D1_FILIAL" + CRLF
    cQuery += "		    AND ZZC.ZZC_CCUSTO = CH_CC" + CRLF
    cQuery += "		    AND ZZC.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "		LEFT JOIN " + RetSqlName("ZZC") + " ZZC_1 " + CRLF
    cQuery += "		    ON  ZZC_1.ZZC_FILCLI     = D1_FILIAL " + CRLF
    cQuery += "		    AND ZZC_1.ZZC_CCUSTO = C7_CC " + CRLF
    cQuery += "		    AND ZZC_1.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += "    WHERE D1_FILIAL = '" + xFilial("SD1") + "' " + CRLF
    cQuery += "        AND C7_ZZCCOUP <> ' ' " + CRLF
    cQuery += "        AND D1_DOC = '" + cDoc + "' " + CRLF
    cQuery += "        AND D1_SERIE = '" + cSerie + "' " + CRLF
    cQuery += "        AND D1_FORNECE = '" + cFornecedor + "' " + CRLF
    cQuery += "        AND D1_LOJA = '" + cLoja + "' " + CRLF
    cQuery += "        AND SD1.D_E_L_E_T_ = '" + Iif(lDelete,"*"," ") + "' "

    TcQuery cQuery New Alias &cAlias
    Count to nQtdTotal
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    geraLog("Resulta da consulta : " + cValToChar(nQtdTotal))
    geraLog("Query: " + changequery(cQuery) )

Return cAlias

Static Function CompLinhas(oFile,cAlias)
    local cStatus := ""
    local nQtd      := 0
    local oLibCoupa := LibCoupa():New()

    Iif(lDelete,cStatus := "voided",cStatus := "created")

    While (cAlias)->(!EoF())

        nQtd        := ConvUM( (cAlias)->D1_COD , (cAlias)->D1_QUANT , 0 , 2 )

        oFile:INCLINHA(cValToChar(nQtd) + ",";
            + Iif(cStatus=="created","ReceivingQuantityConsumption,","ReceivingReturnToSupplier,");
            + ",";
            + cValToChar(Val((cAlias)->C7_ITEM)) + ",";
            + AllTrim((cAlias)->C7_ZZCCOUP) + ",";
            + cStatus + ",";
            + ",";
            + AllTrim((cAlias)->C7_ZZCCOUP) + "-" + (cAlias)->D1_ZZSQCOU )

        (cAlias)->(DbSkip())

    EndDo
    (cAlias)->(DbCloseArea())

Return

Static Function GravaZZD(cDir,cArq,cNota,cPedido)

    local oLibCoupa

    oLibCoupa	:= LibCoupa():New()
    oLibCoupa:setTipo("GOODRECEIPT")
    oLibCoupa:setChave(cArq)

    If lDelete
        oLibCoupa:setOperacao("EXCLUSAO")
    Else
        oLibCoupa:setOperacao("INCLUSAO")
    EndIf

    oLibCoupa:setArquivo(cDir+cArq)
    oLibCoupa:setNF(cNota)
    oLibCoupa:setPedido(cPedido)

    oLibCoupa:setIsErro(.F.)
    oLibCoupa:setOcorrencia("INCLUIDO COM SUCESSO")
    oLibCoupa:setPro2COupa(.T.)
    oLibCoupa:gravaZZD()

Return

//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

    Conout("[" + DTOC(Date()) + " " + Time() + "] GOODRECEIPT - " + cMensagem )

Return
