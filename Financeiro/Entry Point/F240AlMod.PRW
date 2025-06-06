#include 'protheus.ch'

/*/{Protheus.doc} F240AlMod
altera o conte�do do EA_MODELO na gera��o do Sispag.
@type function
@version 12.1.33
@author Leandro Cesar
@since 24/10/2022
@return character, retorno modelo de pagamento
/*/
user function F240AlMod()
	local cModelo := Paramixb[1]

	If cModelo $ "91"
		cModelo := "19" //considera o segmento (O - pagamento de tributos com c�digo de barra)
	EndIf

Return( cModelo )


/*
SEGMENTO O � OBRIGAT�RIO
Pagamento de Contas de Concession�rias e Tributos com c�digo de barras

SEGMENTO N � OBRIGAT�RIO
Pagamento de Tributos sem c�digo de barras e FGTS-GRF/GRRF/GRDE com c�digo de barras


Segmento A
01 - Cr�dito em conta Corrente
02 - Cheque Pagamento/Administrativo
04 - OP a disposi��o com aviso para favorecido
05 - Cr�dito em conta poupan�a
10 - OP a disposi��o sem aviso para o favorecido

Segmento A e B
03 - DOC C
07 - DOC D
41 - TED - Outro Titular
43 - TED - Mesmo Titular

Segmento J e J-52
30 - Liquida��o de t�tulos em cobran�a no Ita�
31 - Pagamento de t�tulos em outro banco

Segmento N
16 - Pagamento de Tributos DARF
17 - Pagamento de Tributos GPS
18 - Pagamento de Tributos DARF SIMPLES
21 - Pagamento de Tributos DARJ
22 - Pagamento de Tributos GARE ICMS SP
25 - Pagamento de Tributos IPVA (SP e MG)
27 - Pagamento de Tributos DPVAT
29 - GR-PR sem C�digo de Barras
35 - Pagamento de Tributos FGTS - GFIP

Segmento O
13 - pagamento a concession�rias
19 - Pagamento de IPTU
28 - GR-PR com Codigo de Barras

*/
