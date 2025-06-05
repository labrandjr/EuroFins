#include 'rwmake.ch'


/*/{Protheus.doc} ChkNat
Gatilho no campo A1_NATUREZ, para avisar o usuario sobre a importancia de se escolher o codigo correto da natureza.
@author Marcos Candido
@since 02/01/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ChkNat

Local cMens1 := "Certifique-se do Código de Natureza escolhido para este cliente."
Local cMens2 := "A Natureza tem impacto direto na retenção dos impostos."
Local cEOL   := "CHR(13)+CHR(10)"
cEOL := Trim(cEOL)
cEOL := &cEOL

Aviso(OemToAnsi("Atenção") , OemToAnsi(cMens1)+cEOL+cEOL+OemToAnsi(cMens2) , {"Ok"} ,2)

Return M->A1_NATUREZ