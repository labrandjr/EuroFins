#include "topconn.ch"
#include "Protheus.ch"
#INCLUDE "rwmake.ch"

************************************************************************************************************
************************************************************************************************************
//Importacao de Arquivo CSV para Gravar Campo na Tabela SB1				    			                  //
************************************************************************************************************
************************************************************************************************************



/*/{Protheus.doc} GravaSB1
Importacao de Arquivo CSV para Gravar Campo na Tabela SB1
@author Unknown
@since 04/01/2018
/*/
User Function GravaSB1()

	Local aArea		:= GetArea()
	Local cArquivo	:= 	''
	Local aItens	:= {}
	Local aParBox		:= {}
	Local cPerg			:= "GRVSB1"

	Private nHanErr			:= 0
	Private oProcess		:= Nil

	aAdd(aParBox,{6,"Arquivo CSV",Space(300),"","","",90,.T.,"Arquivos CSV |*.CSV"})

	If ParamBox(aParBox,"Atualização da Tabela SB1",,,,,,,,cPerg,.T.,.T.)

		cArquivo:= Alltrim(mv_par01)

		oProcess:= MsNewProcess():New({|| fLeitura(cArquivo,@aItens)}, "Dados do Arquivo", "Carregando informações do Arquivo...", .F.)
		oProcess:Activate()

		oProcess:= MsNewProcess():New({|| fGravaSB1(@aItens)}, "Produto", "Gravando informações...", .F.)
		oProcess:Activate()

	endif

	RestArea(aArea)

Return

************************************************************************************************************
************************************************************************************************************
//Função: fLeitura() - Faz a Leitura do arquivo CSV
************************************************************************************************************
************************************************************************************************************
Static Function fLeitura(cArquivo,aItens)

	Local nTotReg		:= 0
	Local nCount		:= 0
	Local nI			:= 0
	Local nJ			:= 0
	Local aArrayTmp		:= {}
	Local cLinhaTmp		:= ""

	If Empty(cArquivo)
		Aviso(FunDesc(),	"O Arquivo de Importação não foi informado. Verifique!", {"Ok"}, 3)
	Else
		nHandle	:= FT_FUSE(cArquivo)
		If nHandle == -1
			Aviso(FunDesc(),	"Não foi possível abrir o arquivo [" + cArquivo + "] especificado. Verifique!", {"Ok"}, 3)
		Else
			nTotReg	:= FT_FLASTREC()
			oProcess:SetRegua1(nTotReg)
			FT_FGOTOP()

			// Faz a leitura do arquivo
			While !FT_FEOF()
				nCount ++
				oProcess:IncRegua1("Processando registro: " + cValToChar(nCount) + "/" + cValToChar(nTotReg))

				cLinhaTmp	:= FT_FREADLN() // Lê a linha do arquivo texto (CSV)

				If Left(cLinhaTmp, 01) != ";"

					cLinhaTmp := StrTran(cLinhaTmp, ".", "")
					cLinhaTmp := StrTran(cLinhaTmp, ",", ".")

					aArrayTmp := StrTokArr(cLinhaTmp, ";")

					aAdd(aItens, aArrayTmp)

				EndIf

				FT_FSKIP()
			EndDo

			FT_FUSE()

		EndIf
	EndIf

Return

************************************************************************************************************
************************************************************************************************************
//Função: fGravaSb1() - Grava Campos da Tabela SB1											              //
************************************************************************************************************
************************************************************************************************************
Static Function fGravaSb1(aItens)

	Local aArea		:= {}
	Local nTotReg	:= Len(aItens)
	Local nCount	:= 0
	Local nX		:= 0

	For nX := 1 to Len(aItens)

		nCount ++
		oProcess:IncRegua1("Processando registro: " + cValToChar(nCount) + "/" + cValToChar(nTotReg))

		if nX > 1
			SB1->(dbSetOrder(1))
			if SB1->(dbSeek(xFilial("SB1") + Alltrim(aItens[nX,1]) ))
				if Substr(Alltrim(aItens[nX,2]),1,1) <> "#"
					RecLock("SB1",.f.)
					SB1->B1_ZZCCUST:= STRZERO(VAL(aItens[nX,2]),2)
					MsUnlock()
				endif
			endif
		endif
	Next nX

Return
