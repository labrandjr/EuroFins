#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"

/****c* classes/ManagerTXT
  *  NAME
  *    ManagerTXT - 
  *  AUTHOR 
  *    Cassiano Gonçalves Ribeiro
  *  CREATION DATE 
  *    13-04-12
  *  SYNOPSIS
  *    object := ManagerTXT():New()
  *  FUNCTION
  *    Responsável por manipular operações com arquivos txt, utilizando a 2ª Familia de Funções ADVPL para ler e gravar arquivos txt
  *  ATTRIBUTES
  *    ...
  *  METHODS
  *  INPUTS
  *      *  RESULT
  *    algum resultado
  *  EXAMPLE
  *    object := ManagerTXT():New()
  *  NOTES
  *    Nao execute as sextas feiras depois das 18h.
  *  BUGS
  *    Trabalhamos para que nao surjam.
  *  SEE ALSO
  *    Descansar.
  ******
  * Outras informacoes a respeito da classe ou funcao.
  */

// 'dummy' function - Uso Interno
User Function ManagTXT; Return // 'dummy' function - Uso Interno

Class ManagerTXT
	
	Data nHandArquivo
	Data cNameArq
	Data cFile
	
	Method NEW( cNameArq)		Constructor			// Método Construtor da Classe
	Method CRIARTXT()								// Cria um arquivo TXT
	Method INCLINHA( cLinha )						// Inclui uma linha no arquivo txt
	Method ABRIRTXT()								// Abre Arquivo TXT
	Method LERLINHA()								// Lê um arquivo texto retornando um array com as linhas lidas. Fecha arquivo após a leitura
	Method FECHAARQUIVO()
	
EndClass

// Construtor
Method New( cNameArq ) Class ManagerTXT
	
	Default cNameArq 		:= ""
	Default nHandArquivo 	:= 0
	
	::cNameArq := cNameArq
	
Return

// Cria um arquivo txt
Method CRIARTXT() Class ManagerTXT
	
	Local lRet := .T.

	If File(::cNameArq)
		FErase(::cNameArq)
	EndIf
	
	::nHandArquivo		:= FCreate(::cNameArq,0)
	::cFile				:= ::nHandArquivo
	If ::nHandArquivo < 0
		lRet := .F.
	    Alert("Erro na criação do arquivo "+ ::cNameArq +"." )
	    Conout("Erro na criação do arquivo "+ ::cNameArq +"." )
	EndIf
	
Return lRet

// Inclui uma linha no arquivo txt
Method INCLINHA( cLinha ) Class ManagerTXT
	
	Local cEOL := "CHR(13)+CHR(10)"
	
	FWrite( ::cFile , cLinha + &cEOL )
	
Return

// Abre o arquivo txt
Method ABRIRTXT() Class ManagerTXT
	
	Local lRet := .T.
  	
  	If File(::cNameArq)
  		
		::nHandArquivo := FT_FUSE(::cNameArq)
		If ::nHandArquivo < 0
		    lRet := .F.
	     	Alert("Erro ao abrir o arquivo "+ ::cNameArq +"." )
	      	Conout("Erro ao abrir o arquivo "+ ::cNameArq +"." )
	    Else
	      	FT_FGOTOP() //PONTO NO TOPO
	    EndIf
 	Else
	    lRet := .F.
	    Alert("Erro ao localizar o arquivo "+ ::cNameArq +"." )
	    Conout("Erro ao localizar o arquivo "+ ::cNameArq +"." )
	EndIf
	
Return (lRet)

// Leitura de arquivo txt
Method LERLINHA(lProc) Class ManagerTXT
	
	Local aRet		:= {}
  	Local cBuffer 	:= ""
  	
  	If lProc
		ProcRegua(FT_FLASTREC()) //QTOS REGISTROS LER
	EndIf
	
	Do While !FT_FEOF() //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
		
			If lProc
				IncProc()
			EndIf
			
			// Capturar dados
			cBuffer := FT_FREADLN() //LENDO LINHA
			AADD(aRet,{cBuffer})
			
		FT_FSKIP() //próximo registro(linha) no arquivo txt
	EndDo
	FT_FUSE()//Fecha o arquivo
	
Return (aRet)

//-------------------------------------------------------------
Method FECHAARQUIVO() class ManagerTXT

	Local lRet		:= .F.

	If ::nHandArquivo > 0
		lRet	 := fClose(::nHandArquivo)
		FT_FUse()
	EndIF

return lRet


//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

	Conout("[" + DTOC(Date()) + " " + Time() + "] ManagerTXT - " + cMensagem )

Return
