#Include 'Totvs.ch'
#Include 'TopConn.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} zExpArq
Exporta o arquivo da tabela ZZD

@type		Function
@author		Julio Lisboa
@since		09/07/2020
/*/
//-----------------------------------------------------------------
user function zExpArq()

    Processa( { || fProcess() } )

return

//-------------------------------------------------------------------
static function fProcess()

    local cDirTMP           := GetTempPath(.T.)
    local cNomeArq          := ZZD->ZZD_COD + "_" + DTOS(Date()) + "_" + StrTran(time(),":","") + ".csv"
    local cContent          := ""
    local nHand             := 0

    cContent                := ZZD->ZZD_CONTEU

    if !empty(cContent)
        nHand		:= FCreate( cDirTMP + cNomeArq )
        if nHand > 0
            fWrite(nHand, cContent )
            fClose(nHand)
            shellExecute("Open", cDirTMP + cNomeArq , "", cDirTMP , 1 )
        else
            MsgAlert("Não foi possível criar o arquivo temporário.",FunDesc())
        endif
    else
        MsgAlert("Conteudo vazio do arquivo.",FunDesc())
    endif

return
