//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "TbiConn.ch"

//Posições do Array
Static nPosCodigo  := 1 //Coluna A no Excel
Static nPosLojFor  := 2 //Coluna B no Excel
Static nPosEMailPC := 3 //Coluna C no Excel


/*/{Protheus.doc} UpdEmailFor
Atualiza cadastro de fornecer - campo e-mail Pedido de Compra
@type function
@version 12.1.33
@author Leandro Cesar
@since 02/08/2023

/*/
User Function UpdEmailFor()
    Local aArea     := GetArea()
    Private cArqOri := ""

    //Mostra o Prompt para selecionar arquivos
    cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

    //Se tiver o arquivo de origem
    If ! Empty(cArqOri)

        //Somente se existir o arquivo e for com a extensão CSV
        If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
            Processa({|| fImporta() }, "Importando...")
        Else
            MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
        EndIf
    EndIf

    RestArea(aArea)
Return

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function fImporta()
    Local aArea      := GetArea()
    Local cArqLog    := "zImpCSV_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local oArquivo
    Local aLinhas
    Local cCodForn   := ""
    Local cLojForn   := ""
    Private cDirLog    := GetTempPath() + "x_importacao\"
    Private cLog       := ""

    //Se a pasta de log não existir, cria ela
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf

    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)

    //Se o arquivo pode ser aberto
    If (oArquivo:Open())

        //Se não for fim do arquivo
        If ! (oArquivo:EoF())

            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)

            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()

            While (oArquivo:HasLine())

                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

                cLinAtu := oArquivo:GetLine()
                aLinha  := separa(cLinAtu, ";")

                If ! "codigo" $ Lower(cLinAtu)

                    cCodForn := aLinha[nPosCodigo]
                    cLojForn := aLinha[nPosLojFor]
                    cEMailPC := StrTran(aLinha[nPosEMailPC],"/",";")


                    DbSelectArea('SA2')
                    SA2->(DbSetOrder(1))

                    If SA2->(DbSeek(FWxFilial('SA2') + cCodForn + cLojForn))
                        cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", fornecedor [" + cCodForn + cLojForn + " - " + Upper(SA2->A2_NREDUZ) + "] " +;
                            "a observação foi alterada, antes: [" + Alltrim(SA2->A2_ZZPCEML) + "], agora: [" + Alltrim(cEMailPC) + "];" + CRLF

                        //Realiza a alteração do fornecedor
                        RecLock('SA2', .F.)
                            SA2->A2_ZZPCEML  := cEMailPC
                        SA2->(MsUnlock())

                    Else
                        cLog += "- Lin" + cValToChar(nLinhaAtu) + ", fornecedor e loja [" + cCodForn + cLojForn + "] não encontrados no Protheus;" + CRLF
                    EndIf

                Else
                    cLog += "- Lin" + cValToChar(nLinhaAtu) + ", linha não processada - cabeçalho;" + CRLF
                EndIf

            EndDo

            //Se tiver log, mostra ele
            If ! Empty(cLog)
                cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
                MemoWrite(cDirLog + cArqLog, cLog)
                ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
            EndIf

        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf

        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf

    RestArea(aArea)
Return
