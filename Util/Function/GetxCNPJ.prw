#include 'totvs.ch'

user function GetxCNPJ(cp_Origem)
	local lRet  := .T. as logical
	local oCNPJ := nil as object
	local cCNPJ := ""  as character



	If cp_Origem == "F_For"

		cCNPJ := FwFldGet("ZZ_CNPJ")

		dbSelectarea("SA2")
		dbSetOrder(3)
		If dbSeek(FWxFilial("SA2") + cCNPJ)
			Help( ,, 'ZMVCSZZ',,"CNPJ informado ja cadastro no cadastro de fornecedor [" + SA2->A2_COD +" - " + SA2->A2_LOJA + "] ." , 1, 0 )
			return(.F.)
		Else

			dbSelectArea("SZZ")
			dbSetOrder(2)
			If dbSeek(FWxFilial("SA2") + cCNPJ)
				Help( ,, 'ZMVCSZZ',,"Já existe ficha e cadastro de fornecedor para o CNPJ informado [" + SZZ->ZZ_IDREQ +" - " + SZZ->ZZ_PUIDR + "] ." , 1, 0 )
				return(.F.)
			Else

				If len(alltrim(cCNPJ)) != 14
					return(.T.)
				EndIF

				oCNPJ := BuscaCNPJ():New(cCNPJ)
				oCNPJ:Consultar(cCNPJ)
				If GetMv("CL_ATVCGC")
					If oCNPJ:lResult

						cNReduz := substr(Upper(oCNPJ:cFantasia),1,TamSx3("ZZ_NREDUZ")[1])
						If Empty(cNReduz)
							cNReduz := substr(upper(oCNPJ:cNome),1,TamSx3("ZZ_NREDUZ")[1])
						EndIf

						FwFldPut("ZZ_COMPLEM"   , upper(oCNPJ:cComplemento))
						FwFldPut("ZZ_NOME"      , substr(upper(oCNPJ:cNome),1,TamSx3("ZZ_NOME")[1]))
						FwFldPut("ZZ_NREDUZ"    , cNReduz )
						FwFldPut("ZZ_UF"        , oCNPJ:cUf)
						FwFldPut("ZZ_TEL"       , oCNPJ:cTelefone)
						FwFldPut("ZZ_EMAIL"     , substr(Upper(oCNPJ:cEmail),1,TamSx3("ZZ_EMAIL")[1]))
						FwFldPut("ZZ_BAIRRO"    , substr(Upper(oCNPJ:cBairro),1,TamSx3("ZZ_BAIRRO")[1]))
						FwFldPut("ZZ_END"       , oCNPJ:cLogradouro + ", " + oCNPJ:cNumero)
						FwFldPut("ZZ_CEP"       , strTran(strTran(oCNPJ:ccep,".",""),"-",""))
						FwFldPut("ZZ_MUN"       , upper(oCNPJ:cMunicipio))
						FwFldPut("ZZ_CODMUN"    , oCNPJ:cCodMun)
						FwFldPut("ZZ_DTABER"    , oCNPJ:dAbertura)
						FwFldPut("ZZ_TPEMP"     , oCNPJ:cTipo)
						FwFldPut("ZZ_NATJUR"    , oCNPJ:cNatJur)
						FwFldPut("ZZ_CNAE"      , oCNPJ:cCnae)
						FwFldPut("ZZ_DESCCNAE"  , oCNPJ:cDescCnae)
						FwFldPut("ZZ_CAPSOC"    , oCNPJ:nCapSocial)
					ELSE
						FwAlertWarning("CNPJ infromado com o seguinte erro: "+ALLTRIM(oCNPJ:OResult:Message)+". Não será possível continuar o cadastro com este CNPJ", "Validação CNPJ")
						lRet:= .F.
					EndIf
				ENDIF
			EndIf
		EndIf


		oCNPJ:Destroy()
		oCNPJ := NIL
	EndIf

return(lRet)
