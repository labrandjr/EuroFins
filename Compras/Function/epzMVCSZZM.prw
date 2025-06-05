#include 'totvs.ch'
#include 'topconn.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} zMVCSZZM
ponto de entrada da rotina zMVCSZZ - ficha de cadastro de fornecedor
@type function
@version 12.1.33
@author Leandro Cesar
@since 26/12/2022
@return object, return_description
/*/
user function zMVCSZZM()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local _aGrpB	 := {}
	Local _aGrpA	 := {}
	local aGrpCpo1 :={'ZZ_UF'     , 'ZZ_END'    , 'ZZ_COMPLEM', 'ZZ_BAIRRO' , 'ZZ_CODMUN', 'ZZ_MUN'   , 'ZZ_CEP'    , 'ZZ_PAIS'   , 'ZZ_CODPAIS', 'ZZ_COND'}
	local aGrpCpo2 :={'ZZ_BANCO'  , 'ZZ_AGENCIA', 'ZZ_NUMCON' , 'ZZ_COLIG'}
	local aGrpCpo3 :={'ZZ_NOME'   , 'ZZ_NREDUZ'}
	local aGrpCpo4 :={'ZZ_SIMPNAC', 'ZZ_RECPIS' , 'ZZ_RECCOFI' , 'ZZ_RECCSLL', 'ZZ_RECISS', 'ZZ_CALCIRF', 'ZZ_CONTRIB', 'ZZ_NATUREZ'}
	local aGrpCpo5 :={'ZZ_NOMGEST', 'ZZ_PERFIL'}
	Local _cCpo001 := {'ZZ_INSCR','ZZ_TIPO', 'ZZ_CNPJ', 'ZZ_CLASFOR','ZZ_TPPESSO','ZZ_UF','ZZ_NOME','ZZ_NREDUZ','ZZ_END', 'ZZ_COMPLEM', 'ZZ_BAIRRO','ZZ_CODMUN','ZZ_MUN','ZZ_COLIG','ZZ_CEP','ZZ_DDD','ZZ_TEL','ZZ_INSCRM','ZZ_PAIS','ZZ_EMAIL','ZZ_COND'}
	Local _cCpo002 := {'ZZ_INSCR','ZZ_NATUREZ','ZZ_SIMPNAC','ZZ_CODPAIS', 'ZZ_RECPIS','ZZ_RECCOFI','ZZ_RECCSLL','ZZ_RECISS','ZZ_CALCIRF','ZZ_CONTRIB'}
	Local _cCpo003 := {'ZZ_NATUREZ','ZZ_BANCO','ZZ_AGENCIA', 'ZZ_NUMCON', 'ZZ_CONTA'}
	Local _cCpo004 := {'ZZ_PERFIL','ZZ_NOMGEST'}
	//Local _cCamposTd  := {'ZZ_OBSERV','ZZ_CARGO'}
	local nX := 0
	Local a  := 0
	Local lTem001:= .F.
	Local lTem002:= .F.
	Local lTem003:= .F.
	Local lTem004:= .F.
	Local lT001A:= .F.

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := ( Len( aParam ) > 3 )
		//Chamada Após a gravação da tabela do formulário
		// If lIsGrid
		// 	nQtdLinhas := oObj:GetQtdLine()
		// 	nLinha     := oObj:nLine
		// EndIf

		If  cIdPonto == 'MODELPOS'
			// cMsg := 'Chamada na validação total do modelo (MODELPOS).' + CRLF
			// cMsg += 'ID ' + cIdModel + CRLF

			// If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
			// 	Help( ,, 'Help',, 'O MODELPOS retornou .F.', 1, 0 )
			// EndIf

			If oObj:nOperation == 4
				If !Empty(FWFldGet('ZZ_STATUS'))
					If !ApMsgYesNo("Ficha de Cadastro de Fornecedor [" + alltrim(FWFldGet('ZZ_IDREQ')) + "] já inicializou o processo de Workflow de aprovação. "+;
							"Deseja estornar o Workflow atual e gerar um novo?")
						return(.F.)
					EndIf
				EndIf



				cQuery := ""
				cQuery += " SELECT SZ5.R_E_C_N_O_ AS RECSZ5, Z5_WFID AS WF_ID FROM " + RetSqlName("SZ5") + " SZ5
				cQuery += " WHERE SZ5.D_E_L_E_T_ =  ''
				cQuery += " AND Z5_NUM = '" + alltrim(FWFldGet('ZZ_IDREQ')) + "'
				cQuery += " AND Z5_TIPO = 'F'
				cQuery += " AND Z5_STATUS <> 'A' "
				TcQuery cQuery New Alias (cTRB := GetNextAlias())

				dbSelectArea((cTRB))
				If (cTRB)->(!eof())

					while (cTRB)->(!eof())

						If !Empty((cTRB)->WF_ID)
							WFKillProcess((cTRB)->WF_ID)
						EndIf

						dbSelectArea("SZ5")
						SZ5->(dbGoTo((cTRB)->RECSZ5))
						reclock("SZ5",.F.)
						SZ5->(dbDelete())
						SZ5->(MsUnlock())

						(cTRB)->(dbSkip())
					EndDo

				EndIf
				(cTRB)->(dbCloseArea())
			EndIf
			If oObj:nOperation != 5
				FWFldPut("ZZ_STATUS", "")
			EndIf
		ElseIf cIdPonto == 'MODELVLDACTIVE'
			// cMsg := 'Chamada na validação total do modelo (MODELPOS).' + CRLF
			// cMsg += 'ID ' + cIdModel + CRLF

			// If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
			// 	Help( ,, 'Help',, 'O MODELPOS retornou .F.', 1, 0 )
			// EndIf

			If oObj:nOperation == 3
				For nX := 1 to len(_cCpo001)
					oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo001[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
				Next nX
				For nX := 1 to len(_cCpo002)
					oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo002[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
				Next nX
				For nX := 1 to len(_cCpo003)
					oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo003[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
				Next nX
				For nX := 1 to len(_cCpo004)
					oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo004[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
				Next nX
			ENDIF

			If oObj:nOperation == 4

				If SZZ->ZZ_STATUS != "4"
					If alltrim(SZZ->ZZ_PUIDR) != alltrim(cUserName)
						If !FwAlertYEsNo('Ficha de cadastro pertencente a outro usuário. Deseja Continuar?',"Aviso")
							xRet := .F.
						EndIf
					EndIf
				Else
					Help( ,, 'Help',, 'Não é possivel alterar uma Ficha de cadastro já aprovada.', 1, 0 )
					xRet := .F.
				EndIf


				cQuery := ""
				cQuery += " SELECT Z5_GRPAPV AS GRUPO_APROVADOR FROM " + RetSqlName("SZ5") + " SZ5
				cQuery += " WHERE SZ5.D_E_L_E_T_ =  ''
				cQuery += " AND Z5_NUM = '" + SZZ->ZZ_IDREQ + "'
				cQuery += " AND Z5_TIPO = 'F'
				cQuery += " AND Z5_STATUS = 'A' "
				cQuery += " GROUP BY Z5_GRPAPV "
				TcQuery cQuery New Alias (cTRB := GetNextAlias())

				If (cTRB)->(!Eof())
					While (cTRB)->(!Eof())
						AADD(_aGrpA,{(cTRB)->GRUPO_APROVADOR})
						(cTRB)->(DbSkip())
					Enddo
				Endif

				DbSelectArea((cTRB))
				(cTRB)->(DbCloseArea())


				cQuery := ""
				cQuery += " SELECT Z5_GRPAPV AS GRUPO_APROVADOR FROM " + RetSqlName("SZ5") + " SZ5
				cQuery += " WHERE SZ5.D_E_L_E_T_ =  ''
				cQuery += " AND Z5_NUM = '" + SZZ->ZZ_IDREQ + "'
				cQuery += " AND Z5_TIPO = 'F'
				cQuery += " AND Z5_STATUS <> 'A' "
				cQuery += " GROUP BY Z5_GRPAPV "
				TcQuery cQuery New Alias (cTRB := GetNextAlias())

				If (cTRB)->(!Eof())
					While (cTRB)->(!Eof())
						AADD(_aGrpB,{(cTRB)->GRUPO_APROVADOR})
						(cTRB)->(DbSkip())
					Enddo
				Endif

				DbSelectArea((cTRB))
				(cTRB)->(DbCloseArea())



				iF Len(_aGrpA) <= 0
					If !Empty(SZZ->ZZ_GRPALT)
						If !'1' $ SZZ->ZZ_GRPALT
							For nX := 1 to len(aGrpCpo1)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(aGrpCpo1[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
						EndIf

						If !'2' $ SZZ->ZZ_GRPALT
							For nX := 1 to len(aGrpCpo2)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(aGrpCpo2[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
						EndIf

						If !'3' $ SZZ->ZZ_GRPALT
							For nX := 1 to len(aGrpCpo3)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(aGrpCpo3[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
						EndIf

						If !'4' $ SZZ->ZZ_GRPALT
							For nX := 1 to len(aGrpCpo4)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(aGrpCpo4[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
						EndIf

						If !'5' $ SZZ->ZZ_GRPALT
							For nX := 1 to len(aGrpCpo5)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(aGrpCpo5[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
						EndIf
					EndIf
				else
					For a:=1 to len(_aGrpA)
						If "001" $ ALLTRIM(_aGrpA[a][1])
							For nX := 1 to len(_cCpo001)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo001[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
							lT001A:= .T.
						Endif

						If "002" $ ALLTRIM(_aGrpA[a][1])
							For nX := 1 to len(_cCpo002)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo002[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
						Endif


						If "003" $ ALLTRIM(_aGrpA[a][1])
							For nX := 1 to len(_cCpo003)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo003[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
						Endif


						If "004" $ ALLTRIM(_aGrpA[a][1])
							For nX := 1 to len(_cCpo004)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo004[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
							Next nX
						Endif
					Next a

					For a:=1 to len(_aGrpB)

						If "001" $ ALLTRIM(_aGrpB[a][1])
							For nX := 1 to len(_cCpo001)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo001[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
							Next nX
							lTem001:= .T.
						Endif

						If "002" $ ALLTRIM(_aGrpB[a][1])
							For nX := 1 to len(_cCpo002)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo002[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
							Next nX
							lTem002:= .T.
						Endif


						If "003" $ ALLTRIM(_aGrpB[a][1])
							For nX := 1 to len(_cCpo003)
								iF lT001A .AND. ALLTRIM(_cCpo003[nX]) <> "ZZ_INSCR"
								ELSE
									oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo003[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
								ENDIF
							Next nX
							lTem003:= .T.
						Endif


						If "004" $ ALLTRIM(_aGrpB[a][1])
							For nX := 1 to len(_cCpo004)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo004[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
							Next nX
							lTem004:= .T.
						Endif


						If "006" $ ALLTRIM(_aGrpB[a][1])

							iF !lTem001
								For nX := 1 to len(_cCpo001)
									oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo001[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
								Next nX
							ENDIF

							iF !lTem002
								For nX := 1 to len(_cCpo002)
									oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo002[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
								Next nX
							ENDIF

							iF !lTem003
								For nX := 1 to len(_cCpo003)
									oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo003[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
								Next nX
							ENDIF


							For nX := 1 to len(_cCpo004)
								oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo004[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
							Next nX


						Endif

						If "005" $ ALLTRIM(_aGrpB[a][1])
							iF !lTem001
								For nX := 1 to len(_cCpo001)
									oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo001[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
								Next nX
							ENDIF

							iF !lTem002
								For nX := 1 to len(_cCpo002)
									oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo002[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
								Next nX
							ENDIF

							iF !lTem003
								For nX := 1 to len(_cCpo003)
									oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo003[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
								Next nX
							ENDIF

							iF !lTem004
								For nX := 1 to len(_cCpo004)
									oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo004[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
								Next nX
							ENDIF
						Endif

					Next a
				endif

				If len(_aGrpB) <= 0 .OR. len(_aGrpA) <= 0
					For nX := 1 to len(_cCpo001)
						oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo001[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
					Next nX


					For nX := 1 to len(_cCpo002)
						oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo002[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
					Next nX

					For nX := 1 to len(_cCpo003)
						oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo003[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
					Next nX


					For nX := 1 to len(_cCpo004)
						oObj:GetModel("FORMSZZ"):GetStruct():SetProperty(_cCpo004[nX], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
					Next nX
				Endif

			EndIf
		ElseIf cIdPonto == 'FORMPOS'

			If FWFldGet("ZZ_TIPO") $ "F|J|C"
				If Empty(FWFldGet("ZZ_CNPJ"))
					Help( ,, 'Help',, 'Campo CNPJ/CPF não preenchido.', 1, 0 )
					xRet := .F.
				EndIf
			EndIf

			If FWFldGet("ZZ_TIPO") $ "C"
				If Empty(FWFldGet("ZZ_TPPESSO"))
					Help( ,, 'Help',, 'Campo Tipo Pessoa não preenchido.', 1, 0 )
					xRet := .F.
				EndIf

				If FWFldGet("ZZ_TPPESSO") == "FF"
					If Empty(FWFldGet("ZZ_NOMGEST"))
						Help( ,, 'Help',, 'Campo Nome Gestor não preenchido.', 1, 0 )
						xRet := .F.
					EndIf

					If !"EUROFINS" $ upper(FWFldGet("ZZ_EMAIL"))
						Help( ,, 'Help',, 'E-Mail Informado incorreto, deve conter o dominio EUROFINS.', 1, 0 )
						xRet := .F.
					EndIf

					If Empty(FWFldGet("ZZ_PERFIL"))
						Help( ,, 'Help',, 'Campo Perfil de acesso ao Flash Expense não preenchido.', 1, 0 )
						xRet := .F.
					EndIf

					If Empty(FWFldGet("ZZ_EMPFLS"))
						Help( ,, 'Help',, 'Não foi realizado o vinculo com a filial de acesso do funcionário. Favor acessar o menu outras ações e realizar o vinculo.', 1, 0 )
						xRet := .F.
					EndIf


					//RETIRADA VALIDAÇÃO POIS AGORA PODEM SER INCLUÍDOS SEM ESSA INFORMAÇÃO, DEVIDO AOS CADASTROS DE FORNECEDORES
					// QUE PAGAMENTO EM BOLETO
					/*
					If Empty(FWFldGet("ZZ_BANCO")) .or. Empty(FWFldGet("ZZ_AGENCIA")) .or. Empty(FWFldGet("ZZ_NUMCON"))
						Help( ,, 'Help',, 'Não foi realizado o preenchimento dos dados bancário. Favor revisar o preenchimento dos campos código, agência e conta do banco.', 1, 0 )
						xRet := .F.
					EndIf
					*/
				EndIf
			EndIf

			If Empty(FWFldGet("ZZ_BANCO")) .or. Empty(FWFldGet("ZZ_AGENCIA")) .or. Empty(FWFldGet("ZZ_NUMCON"))
				IF !MsgYesNo("Banco/Agência ou Conta estão em branco. Deseja prosseguir com o cadastro ou revisá-lo?")
					xRet := .F.
				Endif
			Endif


			// If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
			// 	Help( ,, 'Help',, 'O FORMPOS retornou .F.', 1, 0 )
			// EndIf

		ElseIf cIdPonto == 'FORMLINEPRE'
			// If aParam[5] == 'DELETE'
			// 	cMsg := 'Chamada na pre validação da linha do formulário (FORMLINEPRE).' + CRLF
			// 	cMsg += 'Onde esta se tentando deletar uma linha' + CRLF
			// 	cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) +;
				// 		' linha(s).' + CRLF
			// 	cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) +; CRLF
			// 	cMsg += 'ID ' + cIdModel + CRLF

			// 	If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
			// 		Help( ,, 'Help',, 'O FORMLINEPRE retornou .F.', 1, 0 )
			// 	EndIf
			// EndIf

		ElseIf cIdPonto == 'FORMLINEPOS'
			// cMsg := 'Chamada na validação da linha do formulário (FORMLINEPOS).' +; CRLF
			// cMsg += 'ID ' + cIdModel + CRLF
			// cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ;
				// 	' linha(s).' + CRLF
			// cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF

			// If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
			// 	Help( ,, 'Help',, 'O FORMLINEPOS retornou .F.', 1, 0 )
			// EndIf

		ElseIf cIdPonto == 'MODELCOMMITTTS'
			// ApMsgInfo('Chamada apos a gravação total do modelo e dentro da transação (MODELCOMMITTTS).' + CRLF + 'ID ' + cIdModel )

		ElseIf cIdPonto == 'MODELCOMMITNTTS'
			// ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel)

			//ElseIf cIdPonto == 'FORMCOMMITTTSPRE'

		ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
			// ApMsgInfo('Chamada apos a gravação da tabela do formulário (FORMCOMMITTTSPOS).' + CRLF + 'ID ' + cIdModel)

		ElseIf cIdPonto == 'MODELCANCEL'
			// cMsg := 'Chamada no Botão Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'

			// If !( xRet := ApMsgYesNo( cMsg ) )
			// 	Help( ,, 'Help',, 'O MODELCANCEL retornou .F.', 1, 0 )
			// EndIf

		ElseIf cIdPonto == 'BUTTONBAR'
			xRet := {}
			// xRet := { {'Salvar', 'SALVAR', { || Alert( 'Salvou' ) }, 'Este botao Salva' } }
			aadd(xRet,{"# Vinc. Empresa - Flash Exp.","# Vinc. Empresa - Flash Exp.", {|| U_RetEmpFlash("SZZ") } })
		EndIf
	EndIf

return(xRet)
