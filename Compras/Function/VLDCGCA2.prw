#include "totvs.ch"
/*/{Protheus.doc} VLDCGCA2
Validação para o campo A2_CGC.
Alertar caso a raiz de um CNPJ já estava cadastrado no cadastro de Fornecedores
@author Regis Ferreira
@since 24/04/2019
/*/
User Function VLDCGCA2
	Local aArea     := GetArea()
	Local cCNPJ 	:= SubStr(M->A2_CGC,1,8)
	Local cMens 	:= ""
	Local lRet      := .T.
	if Alltrim(M->A2_TIPO) == "J"  .AND. !FwIsInCallStack("U_ZMVCSZZ")
		//Consulta para ver se tem CNPJ já cadastrado
		BeginSql Alias "A2CGC"
			SELECT
				 DISTINCT A2.A2_COD
			FROM %Table:SA2% A2
			WHERE
				A2.%NotDel% AND
				A2.A2_TIPO = 'J' AND
				SUBSTRING(A2.A2_CGC,1,8) = %Exp:cCNPJ%
			ORDER by 1
		EndSql
		//Percorre todos registros com essa RAIZ de CNPJ
		While A2CGC->(!Eof())
			cMens += "A Raiz do CNPJ "+Transform(M->A2_CGC, "@R 99.999.999/9999-99")+" já foi usada no cadastro do fornecedor com o código "+Alltrim(A2_COD)+CRLF+CRLF
			A2CGC->(DbSkip())
		end
		A2CGC->(DbCloseArea())
		if !Empty(CMens)
			alert(cMens)
		endif
	endif
	RestArea(aArea)
return lRet
