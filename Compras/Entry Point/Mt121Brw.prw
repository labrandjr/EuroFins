#include 'totvs.ch'


//Posições do Array
Static nPosFilial   := 1 //Coluna A no Excel
Static nPosCoupa     := 2 //Coluna B no Excel
Static nPosPed     := 3 //Coluna C no Excel
Static nPosProd     := 4 //Coluna D no Excel


/*/{protheus.doc}Mt121Brw 
Adiciona opção de enviar log de envio de pedido por email na rotina MATA121 (Pedido de compra).
@Author Marcos Candido
@since 12/05/16  
/*/
User Function Mt121Brw

	aadd(aRotina , {"LOG E-Mail/Alt." , "U_LOGPCMAIL" , 0 , 1, 0 , NIL})
	If __cuserID $ GetMv("CL_USRRES")
		aadd(aRotina , {"#Retornar Resíduo" , "U_RETRES" , 0 , 1, 0 , NIL})
	Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LogPCMailºAutor  ³ Marcos Candido     º Data ³  12/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra as ocorrencias registradas no envio do pedido de    º±±
±±º          ³ compra por e-mail.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function LogPCMail(cAlias,nReg,nOpc)

	Local cIdCV8     := SC7->C7_ZZIDCV8
	Local cDataEnvio := DtoS(SC7->C7_ZZDTEM)

	If !Empty(cIdCV8)
		ProcLogView(cFilAnt , "MATA121" , SC7->C7_NUM ) //, cIdCV8)
	Elseif !Empty(cDataEnvio)
		Aviso("Informação" , "A última data em que este pedido foi enviado por e-mail foi: "+DtoC(StoD(cDataEnvio))+"." , {"Ok"})
	Else
		Aviso("Aviso" , "Não há registro da última data em que este pedido foi enviado por e-mail." , {"Sair"})
	Endif

Return


//---------------------------------------------------------------------------------------------------------------------------------


User Function RetRes()
	Local aArea     := GetArea()
	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| ResPC() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return


//-----------------------------------------------------------------------------------------------------------------------------



Static Function ResPC()
	Local aArea      := GetArea()
	Local cArqLog    := "zImpCSV_Ped_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
	Local nTotLinhas := 0
	Local cLinAtu    := ""
	Local nLinhaAtu  := 0
	Local aLinha     := {}
	Local oArquivo
	Local aLinhas
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

				If !"filial;pedido_coupa;pedido_item;produto" $ Lower(cLinAtu)
					If !Empty(aLinha[nPosFilial])
						cFil := aLinha[nPosFilial]
						cCoupa   := aLinha[nPosCoupa]
						cPed   := aLinha[nPosPed]
						cProd   := aLinha[nPosProd]


						dbSelectArea('SC7')
						SC7->(dbOrderNickName("ZZCOUP2"))
						//padr(alltrim(cGNat),tamsx3("ED_CODIGO")[1])
						If dbSeek(padr(alltrim(cFil),tamsx3("C7_FILIAL")[1]) + padr(alltrim(cCoupa),tamsx3("C7_ZZCCOUP")[1]) + cPed )
							cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", Pedido [" + cPed + "] " +;
								", Produto [" + cProd + "] registro voltado resíduo com sucesso." + CRLF

							//Realiza a alteração do pedido de compra
							RecLock('SC7', .F.)
							SC7->C7_RESIDUO  := ''
							SC7->(MsUnlock())
						Else
							cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", Pedido [" + cPed + "] " +;
								", Produto [" + cProd + "] registro com falha na localização." + CRLF
						Endif
					Endif

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
