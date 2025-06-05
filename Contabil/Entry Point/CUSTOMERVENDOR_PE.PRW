#include "protheus.ch"
#include "parmtype.ch"
 /*/{protheus.doc}CUSTOMERVENDOR
Ponto de entrada MVC para cadastro de fornecedores
@author Unknown
@since __/__/____
 /*/
User Function CUSTOMERVENDOR()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local lIsGrid := .F.
	Local nLinha := 0
	Local nQtdLinhas := 0
	Local cMsg := ""

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "MODELPOS"

		ElseIf cIdPonto == "MODELVLDACTIVE"

			lGerFAuto := If (Type("lGerFAuto") == "U", .F., lGerFAuto)

			If !lGerFAuto
				If oObj:nOperation == 3
					If GetMv("CL_BQIAFOR",.F.,'S') == "S"
						Help(nil, nil, "Help - Bloqueio", nil, "Opção de Inclusão / Alteração do cadasatro de fornecedor desativado.", 1, 0, nil,;
							nil, nil, nil, nil, {"Utilize a rotina de Ficha Cadastro de Fornecedor."})
						xRet := .F.
					EndIf
				ElseIf oObj:nOperation == 4
					If GetMv("CL_BQIAFOR",.F.,'S') == "S" .and. !alltrim(cUserName) $ GetMv("CL_USRFIS",.F.,"")
						Help(nil, nil, "Help - Bloqueio", nil, "Opção de Inclusão / Alteração do cadasatro de fornecedor desativado.", 1, 0, nil,;
							nil, nil, nil, nil, {"Utilize a rotina de Ficha Cadastro de Fornecedor."})
						xRet := .F.
					EndIf
				EndIf



			EndIf

		ElseIf cIdPonto == "FORMPOS"

			// If FWFldGet("A2_TPESSOA") == "FF"
			// 	If Empty(FWFldGet("A2_NOMRESP"))
			// 		Help( ,, 'Help',, 'Campo Nome Gestor não preenchido.', 1, 0 )
			// 		xRet := .F.
			// 	EndIf

			// 	If !"EUROFINS" $ upper(FWFldGet("A2_EMAIL"))
			// 		Help( ,, 'Help',, 'E-Mail Informado incorreto, deve conter o dominio EUROFINS.', 1, 0 )
			// 		xRet := .F.
			// 	EndIf

			//         If Empty(FWFldGet("A2_XPERFIL"))
			// 			Help( ,, 'Help',, 'Campo Perfil de acesso ao Flash Expense não preenchido.', 1, 0 )
			// 			xRet := .F.
			// 		EndIf

			//          If Empty(FWFldGet("A2_XEMPFLS"))
			// 			Help( ,, 'Help',, 'Não foi realizado o vinculo com a filial de acesso do funcionário. Favor acessar o menu outras ações e realizar o vinculo.', 1, 0 )
			// 			xRet := .F.
			// 		EndIf

			// EndIf

		ElseIf cIdPonto == "FORMLINEPRE"


		ElseIf cIdPonto == "FORMLINEPOS"

		ElseIf cIdPonto == "MODELCOMMITTTS"

        	/*
            if INCLUI
		  		U_M020INC()
            endif
		  	*/

		ElseIf cIdPonto == "MODELCOMMITNTTS"
			If oObj:nOperation == 4
				If SA2->(FieldPos("A2_XDTALT")) > 0
					reclock("SA2",.F.)
					SA2->A2_XDTALT := dDataBase
					SA2->(MsUnlock())
				EndIf
			EndIf

		ElseIf cIdPonto == "FORMCOMMITTTSPRE"

		ElseIf cIdPonto == "FORMCOMMITTTSPOS"


		ElseIf cIdPonto == "MODELCANCEL"

		ElseIf cIdPonto == "BUTTONBAR"
			xRet := {{"Salvar", "# Atualiza E-Mail Compras", {||u_UpdEmailFor()}}}
		EndIf
	EndIf

Return xRet
