#Include 'Protheus.ch'
#Include "totvs.ch"
#include "tbiconn.ch"
#Include "TopConn.ch"

/*/{protheus.doc}
Gera planilha com a quantidade de registros manuais ou automáticos feitos dentro do financeiro
@author Régis Ferreira
@since 28/07/2021
/*/
User Function ZZQTDSE5()
    Local aParambox	:= {}
    aAdd(aParamBox,{1,"Data de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
    aAdd(aParamBox,{1,"Data até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02
    If ParamBox(aParamBox,"Qtd Movimentações do Financeiro",,,,,,,,ProcName(),.T.,.T.)
        Processa({||GeraPlan() },"Gerando Planilha..." )
    Endif
Return

Static Function GeraPlan
    Local nRegs
    Local cArqNome	:= GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
    Local cTitulo	:= "Qtd Movimentações do Financeiro"
    Local aCampos, cCampos,cAlias
    Local oExcel,nAlign,nType,i
    Local nContador := 0
    Local cQuery    := ""
    Local aCab := StrToKarr("Titulo Concatenado;Filial;Numero;Parcela;Arquivo Cnab;Tipo E5; Tipo E2;Receber/Pagar;Cliente/Fornecedor;Loja;"+;
        "Nome;Natureza;Vencimento;Histórico;Data Baixa;Valor;Banco;Data Digitação;Portador;Tipo Movimento",";")
            cQuery := " Select distinct "+ CRLF
            cQuery += "     E5_FILIAL+E5_BENEF+E5_LOJA+E5_DATA as 'TIT_CONCATE', "+ CRLF
            cQuery += "     E5_FILIAL, "+ CRLF
            cQuery += "     E5_NUMERO, "+ CRLF
            cQuery += "     E5_PARCELA, "+ CRLF
            cQuery += "     E5_ARQCNAB, "+ CRLF
            cQuery += "     E5_TIPO, "+ CRLF
            cQuery += "     E2_TIPO, "+ CRLF
            cQuery += "     E5_RECPAG, "+ CRLF
            cQuery += "     E5_CLIFOR, "+ CRLF
            cQuery += "     E5_LOJA, "+ CRLF
            cQuery += "     E5_BENEF, "+ CRLF
            cQuery += "     E5_NATUREZ, "+ CRLF
            cQuery += "     E5_VENCTO, "+ CRLF
            cQuery += "     E5_HISTOR, "+ CRLF
            cQuery += "     CONVERT(VARCHAR(10),CONVERT(Date, E5_DATA),103) AS 'DATA_BAIXA', "+ CRLF
            cQuery += "     E5_VALOR, "+ CRLF
            cQuery += "     E5_BANCO, "+ CRLF
            cQuery += "     E5_DTDIGIT, "+ CRLF
            cQuery += "     E2_PORTADO, "+ CRLF
            cQuery += "     CASE   when E2_PORTADO = '   ' then 'Manual'   "+ CRLF
            cQuery += "         when E2_PORTADO is null then 'Manual'        "              + CRLF
            cQuery += "         else 'Automática'             "+ CRLF
            cQuery += "     end AS 'TIPO_BAIXA'           "+ CRLF
            cQuery += " from  "+ CRLF
            cQuery  += "    " + RetsqlTab("SE5") + CRLF
            cQuery += "     left join " + RetsqlTab("SE2") + " on E5_RECPAG = 'P' and E5_NUMERO = E2_NUM and E5_PARCELA = E2_PARCELA AND E5_FILIAL = E2_FILIAL and SE2.D_E_L_E_T_ = ' ' and E5_CLIFOR = E2_FORNECE and E5_LOJA = E2_LOJA "+ CRLF
            cQuery += " where "+ CRLF
            cQuery += "     E5_DATA between '"+dtos(MV_PAR01)+"' and '"+dtos(MV_PAR02)+"' "+ CRLF
            cQuery += "     and (E2_TIPO like 'BOL%' or "+ CRLF
            cQuery += "     E2_TIPO like 'CID%' or "+ CRLF
            cQuery += "     E2_TIPO like 'CSL%' or "+ CRLF
            cQuery += "     E2_TIPO like 'EMP%' or "+ CRLF
            cQuery += "     E2_TIPO like 'FGT%' or "+ CRLF
            cQuery += "     E2_TIPO like 'FOL%' or "+ CRLF
            cQuery += "     E2_TIPO like 'FT%' or "+ CRLF
            cQuery += "     E2_TIPO like 'ICM%' or "+ CRLF
            cQuery += "     E2_TIPO like 'INV%' or "+ CRLF
            cQuery += "     E2_TIPO like 'IRF%' or "+ CRLF
            cQuery += "     E2_TIPO like 'ISS%' or "+ CRLF
            cQuery += "     E2_TIPO like 'PA%' or "+ CRLF
            cQuery += "     E2_TIPO like 'PEN%' or "+ CRLF
            cQuery += "     E2_TIPO like 'PIS%' or "+ CRLF
            cQuery += "     E2_TIPO like 'RDV%' or "+ CRLF
            cQuery += "     E2_TIPO like 'TX%' or "+ CRLF
            cQuery += "     E2_TIPO like 'NF%' ) "+ CRLF
            cQuery += "     and E5_LA = 'S' "+ CRLF
            cQuery += "     and SE5.D_E_L_E_T_ = ' ' "+ CRLF
            cQuery += "     and E5_RECPAG = 'P' "+ CRLF

    If Select("E5") > 0
        E5->(DbCloseArea())
    EndIf

    TcQuery cQuery New Alias "E5"

    Count to nRegs
    ProcRegua(nRegs)
    If nRegs==0
        MsgAlert("Não existe informações para gerar Planilha !","Atenção")
    Else
        cCampos := "E5_FILIAL,E5_FILIAL,E5_NUMERO,E5_PARCELA,E5_ARQCNAB,E5_TIPO,E2_TIPO,E5_RECPAG,E5_CLIFOR,E5_LOJA,"
        cCampos += "E5_BENEF,E5_NATUREZ,E5_VENCTO,E5_HISTOR,E5_DATA,E5_VALOR,E5_BANCO,E5_DTDIGIT,E2_PORTADO,E5_FILIAL"
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
        E5->(DbGoTop())
        While !E5->(Eof())
            nContador := nContador +1 
            oExcel:AddRow(cTitulo, cTitulo, {;
                            E5->TIT_CONCATE,;
                            E5->E5_FILIAL,;
                            E5->E5_NUMERO,;
                            E5->E5_PARCELA,;
                            E5->E5_ARQCNAB,;
                            E5->E5_TIPO,;
                            E5->E2_TIPO,;
                            E5->E5_RECPAG,;
                            E5->E5_CLIFOR,;
                            E5->E5_LOJA,;
                            E5->E5_BENEF,;
                            E5->E5_NATUREZ,;
                            E5->E5_VENCTO,;
                            E5->E5_HISTOR,;
                            E5->DATA_BAIXA,;
                            E5->E5_VALOR,;
                            E5->E5_BANCO,;
                            E5->E5_DTDIGIT,;
                            E5->E2_PORTADO,;
                            E5->TIPO_BAIXA;
		    })
            //oExcel:AddRow(cTitulo,cTitulo,aValores)
            IncProc( "Processando registro "+Alltrim(Str(nContador))+" de "+Alltrim(Str(nRegs)))
            E5->(DbSkip())
        End
        E5->(DbCloseArea())
        oExcel:Activate()
        oExcel:GetXMLFile(cArqNome)
        If File(cArqNome)
            If MsgYesNo("Abrir arquivo "+cArqNome+"?","Concluido")
                ShellExecute("Open",cArqNome,"","",1)
            Endif
        Endif
    Endif
Return
