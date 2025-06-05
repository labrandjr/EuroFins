#include 'protheus.ch'

/*/{Protheus.doc} F240AlMod
altera o conteúdo do EA_MODELO na geração do Sispag.
@type function
@version 12.1.33
@author Leandro Cesar
@since 24/10/2022
@return character, retorno modelo de pagamento
/*/
user function F240AlMod()
	local cModelo := Paramixb[1]

	If cModelo $ "91"
		cModelo := "19" //considera o segmento (O - pagamento de tributos com código de barra)
	EndIf

Return( cModelo )


/*
SEGMENTO O – OBRIGATÓRIO
Pagamento de Contas de Concessionárias e Tributos com código de barras

SEGMENTO N – OBRIGATÓRIO
Pagamento de Tributos sem código de barras e FGTS-GRF/GRRF/GRDE com código de barras


Segmento A
01 - Crédito em conta Corrente
02 - Cheque Pagamento/Administrativo
04 - OP a disposição com aviso para favorecido
05 - Crédito em conta poupança
10 - OP a disposição sem aviso para o favorecido

Segmento A e B
03 - DOC C
07 - DOC D
41 - TED - Outro Titular
43 - TED - Mesmo Titular

Segmento J e J-52
30 - Liquidação de títulos em cobrança no Itaú
31 - Pagamento de títulos em outro banco

Segmento N
16 - Pagamento de Tributos DARF
17 - Pagamento de Tributos GPS
18 - Pagamento de Tributos DARF SIMPLES
21 - Pagamento de Tributos DARJ
22 - Pagamento de Tributos GARE ICMS SP
25 - Pagamento de Tributos IPVA (SP e MG)
27 - Pagamento de Tributos DPVAT
29 - GR-PR sem Código de Barras
35 - Pagamento de Tributos FGTS - GFIP

Segmento O
13 - pagamento a concessionárias
19 - Pagamento de IPTU
28 - GR-PR com Codigo de Barras

*/
