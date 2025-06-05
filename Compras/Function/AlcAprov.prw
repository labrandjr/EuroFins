#include 'totvs.ch'
#include 'topconn.ch'
#include 'hbutton.ch'

/*/{Protheus.doc} CadSZC
Cadastro amarração grupo x usuario
@type function
@version 12.1.33
@author Leandro Cesar
@since 21/12/2022
/*/
user function CadSZC()
	Local aArea   := GetArea()
	Local cAlias  := "SZC"
	Local cDelOk  := ".T."
	Local cFunTOk := ".T."
	local cTitulo := "Amarração Grupo x Usuario"

	AxCadastro(cAlias, cTitulo, cDelOk, cFunTOk)

	RestArea(aArea)

return

	// ----------------------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} CadSZ4
Cadastro de Grupo de Usuário - Aprovacao
@type function
@version 12.1.33
@author Leandro Cesar
@since 21/12/2022
/*/
user function CadSZ4()
	Local aArea   := GetArea()
	Local cAlias  := "SZ4"
	Local cDelOk  := ".T."
	Local cFunTOk := ".T."
	local cTitulo := "Cadastro Grupo de Usuario"

	AxCadastro(cAlias, cTitulo, cDelOk, cFunTOk)
	RestArea(aArea)

return


// ----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function BrowSZI()
	local cTitulo   := "Amarracao Alcada Aprovacao"
	Local aArea     := GetArea()
	private aRotina := MenuDef()
	private oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZI")
	oBrowse:SetDescription(cTitulo)

	oBrowse:Activate()

	RestArea(aArea)


return

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function MenuDef()
	Local aMenus as array

	aMenus := {	{ 'Visualizar'			,'u_ManutSZI(2)' ,0,2} ,; 				//"Visualizar"
	{ 'Incluir'							,'u_ManutSZI(3)' ,0,3} ,; 				//"Incluir"
	{ 'Alterar'							,'u_ManutSZI(4)' ,0,4} ,; 				//"Alterar"
	{ 'Excluir'							,'u_ManutSZI(5)' ,0,5} } 				//"Excluir registro"


Return(aMenus)


// ----------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function ManutSZI(np_Opc)
	local aAlterFields :={"ZI_GRUPO"    , "ZI_DESCGRP"}
	local aColsEx      := {}
	local aFieldFill   := {}
	local aFields      :={"ZI_ITEM"     , "ZI_GRUPO"       , "ZI_DESCGRP"}
	local aHeaderEx    := {}
	local lGrava       := .F.
	local nX
	local oBCanc
	local oBConf
	local oCTpAprov
	local oCTpFor
	local oGCodigo
	local oGDesc
	local oGroup1
	local oPanel1
	local oSay1
	local oSay2
	local oSay3
	private aCTpFor    :={""            , "F=Pessoa Física", "J=Pessoa Jurídica", "X=Exterior", "C=Colaborador"}
	private aTpAprov   :={"F=Fornecedor", "P=Produto"}
	private cGCodigo   := ""
	private cGDesc     := space(TamSX3("ZI_DESCRI")[1])
	private nCTpAprov  := 1
	private nCTpFor    := 1
	Static oGetDados

	Static oDlgSZI

	For nX := 1 to Len(aFields)
		Aadd(aHeaderEx, {AllTrim(GetSx3Cache(aFields[nX],"X3_TITULO")),;
			GetSx3Cache(aFields[nX],"X3_CAMPO"),;
			GetSx3Cache(aFields[nX],"X3_PICTURE"),;
			GetSx3Cache(aFields[nX],"X3_TAMANHO"),;
			GetSx3Cache(aFields[nX],"X3_DECIMAL"),;
			GetSx3Cache(aFields[nX],"X3_VALID"),;
			GetSx3Cache(aFields[nX],"X3_USADO"),;
			GetSx3Cache(aFields[nX],"X3_TIPO"),;
			GetSx3Cache(aFields[nX],"X3_F3"),;
			GetSx3Cache(aFields[nX],"X3_CONTEXT"),;
			GetSx3Cache(aFields[nX],"X3_CBOX"),;
			GetSx3Cache(aFields[nX],"X3_RELACAO")})
	Next nX
	aadd(aHeaderEx,{"Registro","_REG"," ",8,0,"","","N","","","",""})


	If np_Opc == 3
		cGCodigo := GetSxeNum("SZI","ZI_CODIGO")

		// Define field values
		For nX := 1 to Len(aFields)
			If aFields[nX] == "ZI_ITEM"
				Aadd(aFieldFill, "01")
			Else
				Aadd(aFieldFill, CriaVar(aFields[nX]))
			EndIf
		Next nX
		Aadd(aFieldFill, 0)
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)

	Else
		cGCodigo  := SZI->ZI_CODIGO
		cGDesc    := SZI->ZI_DESCRI
		nCTpFor   := aScan(aCTpFor,{|x| left(x,1) == SZI->ZI_TCLIFOR})
		nCTpAprov := aScan(aTpAprov,{|x| left(x,1) == SZI->ZI_TPAPROV})
		dbSelectArea("SZI")
		dbSetOrder(1)
		If dbSeek(FWxFilial("SZI") + cGCodigo)
			while SZI->(!eof()) .and. SZI->ZI_CODIGO == cGCodigo
				aFieldFill := {}
				For nX := 1 to Len(aFields)
					aAdd(aFieldFill, &("SZI->"+aFields[nX]))
				Next nX

				Aadd(aFieldFill, SZI->(Recno()))
				Aadd(aFieldFill, .F.)
				Aadd(aColsEx, aFieldFill)
				SZI->(dbSkip())
			EndDo
		EndIf

	EndIf

	DEFINE MSDIALOG oDlgSZI TITLE "..:: Amarracao Alcada Aprovacao ::.." FROM 000, 000  TO 320, 800 COLORS 0, 16777215 PIXEL

	@ 004, 005 GROUP oGroup1 TO 057, 326 OF oDlgSZI COLOR 0, 16777215 PIXEL
	@ 009, 007 SAY oSay1 PROMPT "Codigo" SIZE 025, 007 OF oDlgSZI COLORS 0, 16777215 PIXEL
	@ 018, 007 MSGET oGCodigo VAR cGCodigo SIZE 033, 010 OF oDlgSZI COLORS 0, 16777215 PIXEL

	@ 009, 050 SAY oSay2 PROMPT "Descricao" SIZE 030, 007 OF oDlgSZI COLORS 0, 16777215 PIXEL
	@ 018, 050 MSGET oGDesc VAR cGDesc SIZE 249, 010 OF oDlgSZI COLORS 0, 16777215 PIXEL

	@ 034, 007 SAY oSay3 PROMPT "Tipo Aprovacao" SIZE 046, 007 OF oDlgSZI COLORS 0, 16777215 PIXEL
	@ 042, 007 MSCOMBOBOX oCTpAprov VAR nCTpAprov ITEMS aTpAprov SIZE 072, 010 OF oDlgSZI COLORS 0, 16777215 PIXEL

	@ 034, 114 SAY oSay4 PROMPT "Tipo Fornecedor" SIZE 045, 007 OF oDlgSZI COLORS 0, 16777215 PIXEL
	@ 042, 114 MSCOMBOBOX oCTpFor VAR nCTpFor ITEMS aCTpFor SIZE 072, 010 OF oDlgSZI COLORS 0, 16777215 PIXEL


	@ 061, 005 MSPANEL oPanel1 SIZE 390, 091 OF oDlgSZI COLORS 0, 16777215 RAISED
	oGetDados := MsNewGetDados():New( 000, 000, 090, 389, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+ZI_ITEM", ;
		aAlterFields,, 99, "AllwaysTrue", "", "AllwaysTrue", oPanel1, aHeaderEx, aColsEx)

	@ 008, 330 BUTTON oBConf PROMPT "Confirmar" SIZE 067, 012 OF oDlgSZI PIXEL
	@ 023, 330 BUTTON oBCanc PROMPT "Cancelar" SIZE 067, 012 OF oDlgSZI PIXEL

	// Don't change the Align Order
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oCTpAprov:bChange       := {|| nCTpAprov := oCTpAprov:nAt }
	oCTpFor:bChange         := {|| nCTpFor := oCTpFor:nAt }
	oCTpFor:bWhen           := {|| nCTpAprov == 1}
	oGetDados:aColsSize     := {10, 30, 60, 10}
	oBCanc:bAction          := {|| oDlgSZI:End()}
	oBConf:bAction          := {|| IIf(lGrava := GravaSZI(),oDlgSZI:End(),nil)}
	oGCodigo:Disable(.T.)


	ACTIVATE MSDIALOG oDlgSZI CENTERED

	If np_Opc == 3
		If lGrava
			ConfirmSX8()
		Else
			RollBackSX8()
		EndIf
	EndIf
Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function GravaSZI()
	local lRet  as logical
	local nX    as numeric
	local aArea as array

	aArea := GetArea()
	lRet  := .T.

	If Empty(cGCodigo)
		FwAlertInfo("Favor realizar o preenchimento do campo CODIGO.","Validação")
		lRet := .F.
	EndIf

	If Empty(cGDesc)
		FwAlertInfo("Favor realizar o preenchimento do campo DESCRICAO.","Validação")
		lRet := .F.
	EndIf

	If Empty(aTpAprov[nCTpAprov])
		FwAlertInfo("Favor realizar o preenchimento do campo TIPO APROVACAO.","Validação")
		lRet := .F.
	EndIf

	If lRet
		If FwAlertYesNo("Confirma GravaçãO da alçada de aprovação?","Confirmação")
			For nX := 1 to len(oGetDados:aCols)
				If ! oGetDados:aCols[nx,Len(oGetDados:aHeader)+1]

					If Empty(oGetDados:aCols[nX][4])
						reclock("SZI",.T.)

						SZI->ZI_FILIAL  := FWxFilial("SZI")
						SZI->ZI_CODIGO  := cGCodigo
						SZI->ZI_DESCRI  := cGDesc
						SZI->ZI_TPAPROV := left(aTpAprov[nCTpAprov],1)
						If substr(aTpAprov[nCTpAprov],1,1) == 'F'
							SZI->ZI_TCLIFOR := left(aCTpFor[nCTpFor],1)
						EndIf
						SZI->ZI_ITEM    := oGetDados:aCols[nX][1]
						SZI->ZI_GRUPO   := oGetDados:aCols[nX][2]
						SZI->ZI_DESCGRP := oGetDados:aCols[nX][3]
						SZI->ZI_LOGREG  := alltrim(cUserName) + " " + cValToChar(Date()) + " - " + substr(Time(),1,5)
						SZI->(MsUnlock())

					Else
						dbSelectArea("SZI")
						SZI->(dbGoTo(oGetDados:aCols[nX][4]))

						reclock("SZI",.F.)
						SZI->ZI_FILIAL  := FWxFilial("SZI")
						SZI->ZI_CODIGO  := cGCodigo
						SZI->ZI_DESCRI  := cGDesc
						SZI->ZI_TPAPROV := left(aTpAprov[nCTpAprov],1)
						If substr(aTpAprov[nCTpAprov],1,1) == 'F'
							SZI->ZI_TCLIFOR := aCTpFor[nCTpFor]
						EndIf
						SZI->ZI_ITEM    := oGetDados:aCols[nX][1]
						SZI->ZI_GRUPO   := oGetDados:aCols[nX][2]
						SZI->ZI_DESCGRP := oGetDados:aCols[nX][3]
						SZI->ZI_LOGREG  := alltrim(cUserName) + " " + cValToChar(Date()) + " - " + substr(Time(),1,5)
						SZI->(MsUnlock())

					EndIf
				Else
					If !Empty(oGetDados:aCols[nX][4])
						dbSelectArea("SZI")
						SZI->(dbGoTo(oGetDados:aCols[nX][4]))
						reclock("SZI",.F.)
						SZI->(dbDelete())
						SZI->(MsUnlock())
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	RestArea(aArea)

return(lRet)
