#include "rwmake.ch"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} F060ABT
Apresenta mensagem que somente titulos com o campo NOSSO NUMERO preenchido serao considerados na formacao do bordero.
@author Marcos Candido
@since 03/01/2018
/*/
User Function F060ABT

	Local lRet := .F.
	Local cMens1 := "Importante lembrar que somente os títulos que já tiveram seus boletos impressos é que seram considerados na montagem do borderô."
	Local cMens2 := "É na impressão do boleto que o campo NOSSO NÚMERO é atribuído ao título."

	Aviso("Borderô",cMens1+ENTER+ENTER+cMens2,{"OK"},3)

Return lRet