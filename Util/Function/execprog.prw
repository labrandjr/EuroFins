#include 'protheus.ch'
#include 'parmtype.ch'

user function ExecProg()
	Local aArea := GetArea()
	//Vari�veis da tela
	Private oDlgForm
	Private oGrpForm
	Private oGetForm
	Private cGetForm := Space(250)
	Private oGrpAco
	Private oBtnExec
	//Tamanho da Janela
	Private nJanLarg := 500
	Private nJanAltu := 120
	Private nJanMeio := ((nJanLarg)/2)/2
	Private nTamBtn  := 048


	DEFINE MSDIALOG oDlgForm TITLE "Execu��o Programas" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	@ 003, 003  GROUP oGrpForm TO 30, (nJanLarg/2)-1        PROMPT "F�rmula: " OF oDlgForm COLOR 0, 16777215 PIXEL
	@ 010, 006  MSGET oGetForm VAR cGetForm SIZE (nJanLarg/2)-9, 013 OF oDlgForm COLORS 0, 16777215 PIXEL

	@ (nJanAltu/2)-30, 003 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)-1 PROMPT "A��es: " OF oDlgForm COLOR 0, 16777215 PIXEL
	@ (nJanAltu/2)-24, nJanMeio - (nTamBtn/2) BUTTON oBtnExec PROMPT "Executar" SIZE nTamBtn, 018 OF oDlgForm ACTION(fExecuta()) PIXEL

	ACTIVATE MSDIALOG oDlgForm CENTERED

	RestArea(aArea)
Return

/*---------------------------------------*
| Func.: fExecuta                       |
| Desc.: Executa a f�rmula digitada     |
*---------------------------------------*/

Static Function fExecuta()
	Local aArea    := GetArea()
	Local cFormula := Alltrim(cGetForm)
	Local cError   := ""
	Local bError   := ErrorBlock({ |oError| cError := oError:Description})

	//Se tiver conte�do digitado
	If ! Empty(cFormula)
		//Inicio a utiliza��o da tentativa
		Begin Sequence
			&(cFormula)
		End Sequence

		//Restaurando bloco de erro do sistema
		ErrorBlock(bError)

		//Se houve erro, ser� mostrado ao usu�rio
		If ! Empty(cError)
			MsgStop("Houve um erro na f�rmula digitada: "+CRLF+CRLF+cError, "Aten��o")
		EndIf
	EndIf

	RestArea(aArea)
Return 
