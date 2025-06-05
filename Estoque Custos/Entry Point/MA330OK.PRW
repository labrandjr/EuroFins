#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} MA330OK
Antes da execução do custo médio, é verificado se o fechamento do mês anterior foi realizado.
@author Régis Ferreira
@since 11/05/2020
/*/

User Function MA330OK()
    
    Local lRet      := .T.
    Local dUltFecha := GetMV("MV_ULMES")//Data do ultimo fechamento MV_ULMES
    Local dUltFeB9 //Data do ultimo fechamento SB9
    Local dDataCon  := MV_PAR01-35 //Data que irá consultar se houve fechamento, coloquei -35 para conferir se o mês anterior foi encerrado
    Local lAtivo    := GetMv("ZZ_MA330")  //Parâmetro que ativa ou desativa esse PE

    //Caso o parâmetro ZZ_MA330 estava como Falso, desativamos esse PE.
    if !lAtivo
        return lRet
    endif



    //Consulta a última data de fechamento na SB9
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

    //Confere se a data do parâmetro está de acordo com o ultimo fechamento SB9
    if lRet
        if Dtoc(LastDate(dDataCon)) != dToc(sTod(DUltFeB9))
            MsgStop("A data do parâmetro do último fechamento é: "+dToc(DUltFecha)+ Chr(13) + Chr(10) +;
                    "A data do último fechamento realizado é: "+dToc(sTod(DUltFeB9))+ Chr(13) + Chr(10) +;
                    "Data que está sendo rodado o custo médio: "+dToc(MV_PAR01),;
                    "Nâo será possível continuar")
            lRet := .F.
        endif
    endif

    //Confere o MV_ULMES com a ultima data do fechamento SB9
    if lRet
        if dToc(DUltFecha) != dToc(sTod(DUltFeB9))
            MsgStop("A data do parâmetro do último fechamento é: "+dToc(DUltFecha)+ Chr(13) + Chr(10) +;
                    "A data do último fechamento realizado é: "+dToc(sTod(DUltFeB9))+ Chr(13) + Chr(10) +;
                    "Data que está sendo rodado o custo médio: "+dToc(MV_PAR01),;
                    "Nâo será possível continuar")
            lRet := .F.
        endif
    endif

Return lRet