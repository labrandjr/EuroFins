#include "totvs.ch"
/*/{protheus.doc} ZZRELEST
Planilha para conferência da virada de saldo do estoque.
@author Régis Ferreira
@since 14/08/20*/
User Function ZZRELEST
    Private aQry    := {} //Querys
    Private aPlan   := {} //Nome das Planilhas
    Private aTab   := {} //Título da tabela
    Private aNomCam := {} //Nome dos Campos
    If AskMe()
        GetQry()
        Processa({|| ExpExcel()})
    Endif
Return

Static Function AskMe
    Local aPergs := {}
    AADD(aPergs,{1,"Da filial",CriaVar("B2_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
    AADD(aPergs,{1,"Ate filial",CriaVar("B2_FILIAL",.f.),"@!",'.t.',"SM0",'.T.',50,.F.})
    AADD(aPergs,{1,"Data Fechamento",ctod(''),,'.t.',,'.T.',60,.F.})
Return ParamBox(aPergs,"Parametros",{})

Static Function ExpExcel
    Local oExcel := FWMSExcel():New()
    Local cFile := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
    Local aValores
    Local i,p
    ProcRegua(Len(aQry))
    For p := 1 to Len(aQry)
        DbUseArea(.t.,"TOPCONN",TcGenQry(,,aQry[p]),"ZZ",.f.,.f.)
        oExcel:AddworkSheet(aPlan[p])
        oExcel:AddTable(aPlan[p],aPlan[p])
        For i:=1 To ZZ->(FCount())
            If ValType(FieldGet(i)) == "D"
                nAlign := 2
                nType  := 4
            ElseIf ValType(FieldGet(i)) == "N"
                nAlign := 3
                nType  := 2
            Else
                nAlign := 1
                nType  := 1
            Endif
            oExcel:AddColumn(aPlan[p],aPlan[p],aNomCam[p][i],nAlign,nType,.f.)
        Next
        While ZZ->(!Eof())
            aValores := {}
            For i:=1 to ZZ->(fCount())
                AADD(aValores,FieldGet(i))
            Next
            oExcel:AddRow(aPlan[p],aPlan[p],aValores)
            ZZ->(DbSkip())
        End
        IncProc()
        ZZ->(DbCloseArea())
    Next
    oExcel:Activate()
    oExcel:GetXMLFile(cFile)
    If File(cFile)
        ShellExecute("Open",cFile,"","",1)
    Endif
Return

Static Function GetQry

    //Quantidade negativa no fechamento de estoque
    AADD(aPlan,"Qtd Negativa")
    AADD(aQry,"select B2_FILIAL,B2_COD,B2_LOCAL,B2_QFIM from "+RetSqlName("SB2")+" SB2 where SB2.D_E_L_E_T_ = ' ' and B2_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and B2_QFIM < 0 order by B2_FILIAL, B2_COD, B2_LOCAL")
    AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Final",";"))

    //Quantidade em estoque 
    AADD(aPlan,"Qtd Sem Vlr")
    AADD(aQry,"select B2_FILIAL,B2_COD,B2_LOCAL,B2_QFIM, B2_VFIM1 from "+RetSqlName("SB2")+" SB2 where SB2.D_E_L_E_T_ = ' ' and B2_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and B2_QFIM <> 0 and B2_VFIM1 = 0 order by B2_FILIAL, B2_COD, B2_LOCAL")
    AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Final;Vlr Final",";"))

    AADD(aPlan,"Vlr Negativo")
    AADD(aQry,"select B2_FILIAL,B2_COD,B2_LOCAL,B2_VFIM1 from "+RetSqlName("SB2")+" SB2 where SB2.D_E_L_E_T_ = ' ' and B2_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and B2_VFIM1 < 0 order by B2_FILIAL, B2_COD, B2_LOCAL")
    AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Vlr Final",";"))

    AADD(aPlan,"Vlr Sem Qtd")
    AADD(aQry,"select B2_FILIAL,B2_COD,B2_LOCAL,B2_QFIM, B2_VFIM1 from "+RetSqlName("SB2")+" SB2 where SB2.D_E_L_E_T_ = ' ' and B2_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and B2_QFIM = 0 and B2_VFIM1 <> 0 order by B2_FILIAL, B2_COD, B2_LOCAL")
    AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Final;Vlr Final",";"))

    AADD(aPlan,"B2. x Saldo")
    AADD(aQry,"select B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B9_QINI, Sum(B2_QFIM-B9_QINI) from "+RetSqlName("SB2")+" SB2, "+RetSqlName("SB9")+" SB9 where SB2.D_E_L_E_T_ = ' ' and SB9.D_E_L_E_T_ = ' ' and B2_FILIAL = B9_FILIAL and B2_COD = B9_COD and B2_LOCAL = B9_LOCAL and B2_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and B9_DATA = '"+dTos(MV_PAR03)+"' group by B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B9_QINI order by B2_FILIAL, B2_COD, B2_LOCAL")
    AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Final;Qtd Inicial;Diferença",";"))

    //Verifica se tem controla de lote
    BeginSql Alias "LOTE"
        select Count(*) QTDREG from %Table:SB1% SB1
        where SB1.B1_RASTRO <> 'N'
        and SB1.%NotDel%
    EndSql

    //Se tem controle de lote, faz verificação
    If LOTE->QTDREG > 0 

        AADD(aPlan,"Lote Negativo")
        AADD(aQry,"select BJ_FILIAL,BJ_COD, BJ_LOCAL, BJ_QINI from "+RetSqlName("SBJ")+" SBJ where SBJ.D_E_L_E_T_ = ' ' and BJ_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and BJ_DATA = '"+dTos(MV_PAR03)+"' and BJ_QINI < 0 order by BJ_FILIAL, BJ_COD, BJ_LOCAL")
        AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Inicial;",";"))

        AADD(aPlan,"B2 x Lote")
        AADD(aQry,"select B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, SUM(BJ_QINI), B2_QFIM-Sum(BJ_QINI) from "+RetSqlName("SB2")+" SB2, "+RetSqlName("SBJ")+" SBJ where SB2.D_E_L_E_T_ = ' ' and SBJ.D_E_L_E_T_ = ' ' and B2_FILIAL = BJ_FILIAL and B2_COD = BJ_COD and B2_LOCAL = BJ_LOCAL and B2_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and BJ_DATA = '"+dTos(MV_PAR03)+"' group by B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM order by B2_FILIAL, B2_COD, B2_LOCAL")
        AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Final;Qtd Inicial;Diferença",";"))

        AADD(aPlan,"B9 x Lote")
        AADD(aQry,"select B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, SUM(BJ_QINI), B9_QINI-Sum(BJ_QINI) from "+RetSqlName("SB9")+" SB9, "+RetSqlName("SBJ")+" SBJ where SB9.D_E_L_E_T_ = ' ' and SBJ.D_E_L_E_T_ = ' ' and B9_FILIAL = BJ_FILIAL and B9_COD = BJ_COD and B9_LOCAL = BJ_LOCAL and B9_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and BJ_DATA = '"+dTos(MV_PAR03)+"' and B9_DATA = '"+dTos(MV_PAR03)+"' group by B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI order by B9_FILIAL, B9_COD, B9_LOCAL")
        AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Final;Qtd Inicial;Diferença",";"))
    endif

    LOTE->(DbCloseArea())

    //Verifica se tem controla de lote/Endereço
    BeginSql Alias "ENDE"
        select Count(*) QTDREG from %Table:SB1% SB1
        where SB1.B1_LOCALIZ <> 'N'
        and SB1.%NotDel%
    EndSql

    //Se tem controle de Endereço, faz verificação
    If ENDE->QTDREG > 0 

        AADD(aPlan,"Endereço Negativo")
        AADD(aQry,"select BK_FILIAL,BK_COD, BK_LOCAL, BK_QINI from "+RetSqlName("SBK")+" SBK where SBK.D_E_L_E_T_ = ' ' and BK_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and BK_DATA = '"+dTos(MV_PAR03)+"' and BK_QINI < 0 order by BK_FILIAL, BK_COD, BK_LOCAL")
        AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Inicial;",";"))

        AADD(aPlan,"B2 x Endereço")
        AADD(aQry,"select B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, SUM(BK_QINI), (B2_QFIM-Sum(BK_QINI)) from "+RetSqlName("SB2")+" SB2, "+RetSqlName("SBK")+" SBK where SB2.D_E_L_E_T_ = ' ' and SBK.D_E_L_E_T_ = ' ' and B2_FILIAL = BK_FILIAL and B2_COD = BK_COD and B2_LOCAL = BK_LOCAL and B2_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and BK_DATA = '"+dTos(MV_PAR03)+"' group by B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM order by B2_FILIAL, B2_COD, B2_LOCAL")
        AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Final;Qtd Ini. Lote;Diferença",";"))

        AADD(aPlan,"B9 x Endereço")
        AADD(aQry,"select B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, SUM(BK_QINI), (B9_QINI-Sum(BK_QINI)) from "+RetSqlName("SB9")+" SB9, "+RetSqlName("SBK")+" SBK where SB9.D_E_L_E_T_ = ' ' and SBK.D_E_L_E_T_ = ' ' and B9_FILIAL = BK_FILIAL and B9_COD = BK_COD and B9_LOCAL = BK_LOCAL and B9_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and BK_DATA = '"+dTos(MV_PAR03)+"' and B9_DATA = '"+dTos(MV_PAR03)+"' group by B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI order by B9_FILIAL, B9_COD, B9_LOCAL")
        AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Ini.;Qtd Ini. Lote;Diferença",";"))
    endif

    ENDE->(DbCloseArea())

    //Verifica se tem controla de lote/Endereço
    BeginSql Alias "ENDLOT"
        select Count(*) QTDREG from %Table:SB1% SB1
        where SB1.B1_LOCALIZ <> 'N' and SB1.B1_RASTRO <> 'N'
        and SB1.%NotDel%
    EndSql

    //Se tem controle de Endereço, faz verificação
    If ENDLOT->QTDREG > 0 
        AADD(aPlan,"B2 x Endereço x Lote")
        AADD(aQry,"select B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, SUM(BJ_QINI), Sum(BK_QINI), Sum(B2_QFIM-BK_QINI)+Sum(B2_QFIM-BJ_QINI) from "+RetSqlName("SB2")+" SB2, "+RetSqlName("SBK")+" SBK, "+RetSqlName("SBJ")+" SBJ where SB2.D_E_L_E_T_ = ' ' and SBK.D_E_L_E_T_ = ' ' and SBJ.D_E_L_E_T_ = ' ' and B2_FILIAL = BK_FILIAL and B2_FILIAL = BJ_FILIAL and B2_COD = BK_COD and B2_COD = BJ_COD and B2_LOCAL = BK_LOCAL and B2_LOCAL = BJ_LOCAL and B2_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and BK_DATA = '"+dTos(MV_PAR03)+"' group by B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM order by B2_FILIAL, B2_COD, B2_LOCAL")
        AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Ini.;Qtd Ini. Lote;Qtd Ini. Ender.;Diferença",";"))

        AADD(aPlan,"B9 x Endereço x Lote")
        AADD(aQry,"select B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, SUM(BJ_QINI), Sum(BK_QINI), Sum(B9_QINI-BK_QINI)+Sum(B9_QINI-BJ_QINI) from "+RetSqlName("SB9")+" SB9, "+RetSqlName("SBK")+" SBK, "+RetSqlName("SBJ")+" SBJ where SB9.D_E_L_E_T_ = ' ' and SBK.D_E_L_E_T_ = ' ' and SBJ.D_E_L_E_T_ = ' ' and B9_FILIAL = BK_FILIAL and B9_FILIAL = BJ_FILIAL and B9_COD = BK_COD and B9_COD = BJ_COD and B9_LOCAL = BK_LOCAL and B9_LOCAL = BJ_LOCAL and B9_FILIAL between '"+Alltrim(MV_PAR01)+"' and '"+Alltrim(MV_PAR02)+"' and BK_DATA = '"+dTos(MV_PAR03)+"' group by B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI order by B9_FILIAL, B9_COD, B9_LOCAL")
        AADD(aNomCam,StrToKarr("Filial;Código;Armazém;Qtd Ini.;Qtd Ini. Lote;Qtd Ini. Ender.;Diferença",";"))
    endif

    ENDLOT->(DbCloseArea())

Return aQry
