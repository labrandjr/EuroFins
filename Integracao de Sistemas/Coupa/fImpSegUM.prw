#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

#DEFINE QUANT_COLUNAS       4

#DEFINE POS_CODIGO          01
#DEFINE POS_SEGUM           02
#DEFINE POS_CONVER          03
#DEFINE POS_TIPCONV         04


//-----------------------------------------------------------------
/*/{Protheus.doc} fImpSegUM
Rotina responsável pela importação de um CSV
para alteração da segunda unidade de medida

@type		Function
@author 	Julio Lisboa
@since 		23/07/2020
@return		nil, nulo
/*/
//-----------------------------------------------------------------
user function fImpSegUM()

    private cArquivo        := ""

    cArquivo := cGetFile("Arquivos CSV | *.csv", "Selecione o arquivo",,  "",.t.,GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE )

    if !empty(cArquivo) .and. file(cArquivo)
        Processa( {|| fProcess()} )
    else
        MsgAlert("Arquivo [" + cArquivo + "] não localizado.",FunDesc())
    endif

return

//-----------------------------------------------------------------
static function fProcess()

    local nHandle       := 0
    local nTotReg       := 0
    local cErro         := ""
    local cLinha        := ""
    local cProduto      := ""
    local cSegum        := ""
    local nFatConv      := 0
    local cTipoConv     := ""
    local aDados        := {}
    local lRet          := .T.
    local lSimulacao    := .F.
    local aAreaSB1      := SB1->(GetArea())
    local aAreaSAH      := SAH->(GetArea())

    private _nLinha     := 0

    lSimulacao      := MsgYesNo("Deseja Executar a rotina em modo SIMULAÇÃO ? OK-Sim, Não-Produção",FunDesc())

    nHandle	:= FT_FUSE(cArquivo)
    nTotReg	:= FT_FLASTREC()
    FT_FGOTOP()

    ProcRegua(nTotReg)

    backupArquivo(cArquivo)

    BEGIN TRANSACTION

        While !FT_FEOF()
            IncProc("Processando a linha " + cValToChar(_nLinha) + " de " + cValToChar(nTotReg) + "...")
            _nLinha++
            cLinha      := FT_FREADLN()

            If _nLinha == 1
                lRet        := .F.
            Else
                lRet        := .T.
            EndIf

            if lRet
                aDados      := StrTokArr(cLinha, ";")

                if Len(aDados) < QUANT_COLUNAS
                    cErro       := "O arquvio deve ter [" + cValToChar(QUANT_COLUNAS) + "] colunas"
                    lRet        := .F.
                endif
            endif

            If lRet
                cProduto            := AllTrim(aDados[POS_CODIGO])
                cSegum              := AllTrim(aDados[POS_SEGUM])
                nFatConv            := Val( AllTrim(aDados[POS_CONVER]) )
                cTipoConv           := AllTrim(aDados[POS_TIPCONV])

                SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
                SAH->(DbSetOrder(1)) //AH_FILIAL+AH_UNIMED

                If !SB1->(DbSeek( FwxFilial("SB1") + PADR( cProduto , Tamsx3("B1_COD")[1]) ))
                    lRet        := .F.
                    cErro       := "Produto [" + cProduto + "] não localizado - linha [" + cValToChar(_nLinha) + "]"
                    exit
                EndIf

                If lRet
                    If !SAH->(DbSeek( FwxFilial("SAH") + PADR( cSegum , Tamsx3("AH_UNIMED")[1]) ))
                        lRet        := .F.
                        cErro       := "Unidade de Medida [" + cSegum + "] não localizada - linha [" + cValToChar(_nLinha) + "]"
                        exit
                    EndIf
                EndIf

                If lRet
                    If nFatConv <= 0
                        lRet        := .F.
                        cErro       := "Fator de Conversão Zerado - linha [" + cValToChar(_nLinha) + "]"
                        exit
                    EndIf
                EndIf

                If lRet
                    If !Empty(cTipoConv) .and. !( cTipoConv $ "MD" )
                        lRet        := .F.
                        cErro       := "Tipo de Conversão deve ser vazio, M ou D - linha [" + cValToChar(_nLinha) + "]"
                        exit
                    EndIf
                EndIf

                If lRet
                    lRet    := atualizaPrd( cProduto , cSegum , nFatConv , cTipoConv , @cErro )

                    if !lRet
                        DisarmTransaction()
                        exit
                    else
                        If lSimulacao
                            DisarmTransaction()
                        endif
                    endif
                EndIf
            EndIf

            FT_FSKIP()
        EndDo
        FT_FUSE()

    END TRANSACTION

    If !lRet
        MsgAlert(cErro,FunDesc())
    Else
        If lSimulacao
            MsgAlert( cValToChar(_nLinha - 1) + " Produtos SIMULADOS com sucesso!",FunDesc())
        Else
            MsgAlert( cValToChar(_nLinha - 1) + " Produtos alterados com sucesso!",FunDesc())
        EndIf
    EndIf

    RestArea(aAreaSAH)
    RestArea(aAreaSB1)

return

//-----------------------------------------------------------------
static function atualizaPrd( cProduto , cSegum , nFatConv , cTipoConv , cErro )

    local cSql          := ""
    local lRet          := .F.

    cSql        += " UPDATE "
    cSql        += "    " + RetSqlName("SB1")
    cSql        += " SET "
    cSql        += "    B1_SEGUM = '" + cSegum + "' "
    cSql        += "    ,B1_CONV = " + cValToChar(nFatConv)
    cSql        += "    ,B1_TIPCONV = '" + cTipoConv + "' "
    cSql        += " WHERE "
    cSql        += "    B1_COD = '" + cProduto + "' "
    cSql        += "    AND D_E_L_E_T_ = ' ' "
    cSql        += " "

    If TcSqlExec(cSql) >= 0
        lRet        := .T.
    else
        cErro       := "ERRO na atualização do produto - " + TcSqlError()
    EndIf

return lRet

//-----------------------------------------------------------------
static function backupArquivo(cArquivo)

    local cDiretorio  := "\coupa\"

    if !existDir(cDiretorio)
        makedir(cDiretorio)
    endif

    cDiretorio  += "ARQUIVOS_PROD\"
    if !existDir(cDiretorio)
        makedir(cDiretorio)
    endif

    cDiretorio  += DTOS(Date()) + "\"
    if !existDir(cDiretorio)
        makedir(cDiretorio)
    endif

    if existdir(cDiretorio)
        //CpyT2S(cArquivo,cDiretorio)

        if __CopyFile(cArquivo,cDiretorio + cArquivo)
            conout("fImpSegUM - Arquivo copiado com sucesso!")
        else
            conout("fImpSegUM - Erro na copia do arquivo")
        endif
    endif

return

//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

    Conout("[" + DTOC(Date()) + " " + Time() + "] fImpSegUM - " + cMensagem )

Return
