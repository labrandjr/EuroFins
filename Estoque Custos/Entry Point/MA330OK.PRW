#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} MA330OK
Antes da execu��o do custo m�dio, � verificado se o fechamento do m�s anterior foi realizado.
@author R�gis Ferreira
@since 11/05/2020
/*/

User Function MA330OK()
    
    Local lRet      := .T.
    Local dUltFecha := GetMV("MV_ULMES")//Data do ultimo fechamento MV_ULMES
    Local dUltFeB9 //Data do ultimo fechamento SB9
    Local dDataCon  := MV_PAR01-35 //Data que ir� consultar se houve fechamento, coloquei -35 para conferir se o m�s anterior foi encerrado
    Local lAtivo    := GetMv("ZZ_MA330")  //Par�metro que ativa ou desativa esse PE

    //Caso o par�metro ZZ_MA330 estava como Falso, desativamos esse PE.
    if !lAtivo
        return lRet
    endif



    //Consulta a �ltima data de fechamento na SB9
    BeginSql Alias "ULTFECH"
        Select
	        Max(SB9.B9_DATA) B9_DATA
        From 
	        %Table:SB9% SB9
        Where 
	        SB9.%NotDel% and 
	        SB9.B9_FILIAL = %xFilial:SB9%
    ENDSQL

    dUltFeB9 := ULTFECH->B9_DATA
    ULTFECH->(DbCloseArea())

    //Confere se a data do par�metro est� de acordo com o ultimo fechamento SB9
    if lRet
        if Dtoc(LastDate(dDataCon)) != dToc(sTod(DUltFeB9))
            MsgStop("A data do par�metro do �ltimo fechamento �: "+dToc(DUltFecha)+ Chr(13) + Chr(10) +;
                    "A data do �ltimo fechamento realizado �: "+dToc(sTod(DUltFeB9))+ Chr(13) + Chr(10) +;
                    "Data que est� sendo rodado o custo m�dio: "+dToc(MV_PAR01),;
                    "N�o ser� poss�vel continuar")
            lRet := .F.
        endif
    endif

    //Confere o MV_ULMES com a ultima data do fechamento SB9
    if lRet
        if dToc(DUltFecha) != dToc(sTod(DUltFeB9))
            MsgStop("A data do par�metro do �ltimo fechamento �: "+dToc(DUltFecha)+ Chr(13) + Chr(10) +;
                    "A data do �ltimo fechamento realizado �: "+dToc(sTod(DUltFeB9))+ Chr(13) + Chr(10) +;
                    "Data que est� sendo rodado o custo m�dio: "+dToc(MV_PAR01),;
                    "N�o ser� poss�vel continuar")
            lRet := .F.
        endif
    endif

Return lRet