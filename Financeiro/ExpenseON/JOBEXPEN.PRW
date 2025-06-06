#include "rwmake.ch"
#include 'protheus.ch'
#include "topconn.ch"
#include "tbiconn.ch"

static lEurofins := !("YMLLLM" $ GetEnvServer())

User Function JOBEXPEN(cEmp,cFil)

	Private lJob := .T. //para poder abrir as telas de controle

	cEmp := "01"
	cFil := iif(lEurofins, "0100", "5000")

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

	ConOut(OEMToANSI(cValToChar(FWTimeStamp(2)) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Inicio... "))

	StartJob("U_PROCEXPEN",GetEnvServer(),.F.,lJob,cEmp,cFil)

	ConOut(OEMToANSI(cValToChar(FWTimeStamp(2)) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Fim... "))


Return


User Function PROCEXPEN(lJob,cEmp,cFil)

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

	RpcSetType ( 3 )
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "FIN"
	INTEXPEN(lJob,cEmp,cFil)
	RESET ENVIRONMENT

Return(.T.)

Static Function INTEXPEN(lJob,cEmp,cFil)

	Local dDtIni := ctod("01/01/2021")
	Local dDtFim := date()+15

	//Integra��o do Cadasro de Fornecedores x Funcionarios
	ConOut(OEMToANSI(cValToChar(FWTimeStamp(2)) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Inicio IntegraSA2 ... "))
	U_IntegraSA2(lJob)
	ConOut(OEMToANSI(cValToChar(FWTimeStamp(2)) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Fim IntegraSA2 ... "))

	// //Integra��o dos Adiantamentos
	// ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Inicio IntegraPA ... "))
	// U_IntegraPA(dDtIni, dDtFim,lJob)
	// ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Fim IntegraPA ... "))


	// utiliza a mesma regra de bloqueio do Lincrons
	// If getnewpar("ZZ_LINCR05",.F.)
	// 	If Day(ddatabase) >= getnewpar("ZZ_LINCR06",.F.)
	// 		geraLog("Integra��o desligada pelo par�metro ZZ_LINR06")
	// 	Else
	//Integra��o das Despesas
	// ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Inicio IntegraDP ... "))
	// U_IntegraDP(dDtIni, dDtFim,lJob)
	// ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Fim IntegraDP ... "))
	// 	EndIf
	// Else
	// 	geraLog("Integra��o desligada pelo par�metro ZZ_LINR05")
	// EndIf

	If GetMv("CL_INTFFIN")
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Inicio IntegraDP ... "))
		U_IntegraDP(dDtIni, dDtFim,lJob)
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | JOBEXPENSE ["+cEmp+cFil+"] ------> Fim IntegraDP ... "))
	EndIf



Return()


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function AtDtIntSE2()

	Local oBDesativa
	Local oBAtiva
	Local oFont1 := TFont():New("Arial Rounded MT Bold",,018,,.F.,,,,,.F.,.F.)
	Local oSay1
	local cOpc := ""
	Static oDlg

	lAtivo := !GetMv("CL_INTFFIN",.F.,.F.)

	DEFINE MSDIALOG oDlg TITLE "" FROM 000, 000  TO 090, 350 COLORS 0, 16777215 PIXEL

	@ 000, 000 SAY oSay1 PROMPT "      INTEGRA��O DESPESAS FLASH EXPENSE" SIZE 175, 010 OF oDlg FONT oFont1 COLORS 16711680, 16777215 PIXEL

	// Don't change the Align Order
	oSay1:Align := CONTROL_ALIGN_TOP

	If lAtivo
		@ 024, 048 BUTTON oBAtiva PROMPT "ATIVAR" SIZE 077, 017 OF oDlg PIXEL
		cCSS := ""
		cCSS   += "QPushButton { color: white }"
		cCSS   += "QPushButton { font-weight: bold }"
		cCSS   += "QPushButton { border: 2px solid #CECECE }"
		cCSS   += "QPushButton { background-color: #72a50c }"
		cCSS   += "QPushButton { border-radius: 8px }"

		oBAtiva:SetCss(cCSS)
		oBAtiva:bAction     := {|| cOpc := "A", oDlg:End()}
	Else
		@ 024, 048 BUTTON oBDesativa PROMPT "DESATIVAR" SIZE 077, 017 OF oDlg PIXEL
		cCSS := ""
		cCSS   += "QPushButton { color: white }"
		cCSS   += "QPushButton { font-weight: bold }"
		cCSS   += "QPushButton { border: 2px solid #CECECE }"
		cCSS   += "QPushButton { background-color: #9c3346 }"
		cCSS   += "QPushButton { border-radius: 8px }"

		oBDesativa:SetCss(cCSS)
		oBDesativa:bAction  := {|| cOpc := "B", oDlg:End() }
	Endif






	ACTIVATE MSDIALOG oDlg CENTERED

	If cOpc == "A"
		PutMV("CL_INTFFIN",.T.)
		FWAlertSuccess("Ativa��o Integra��o Flash Expense (FIN - Relat�rio) realizado com sucesso.","Ativa��o Integra��o")
	ElseIf cOpc == "B"
		PutMV("CL_INTFFIN",.F.)
		FwAlertWarning("Desativa��o Integra��o Flash Expense (FIN - Relat�rio) realizado com sucesso.","Desativa��o Integra��o")

	Else
		FwAlertError("Opera��o cancelada pelo usu�rio.","Integra��o Flash Expense")
	EndIf

return()
