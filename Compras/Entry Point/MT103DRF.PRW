#include 'totvs.ch'


/*/{Protheus.doc} MT103DRF
Ponto de Entrada para alterar o Campo DIRF e Código de Retenção dos Impostos
na Classificação do Documento de Entrada
@type function
@version 12.1.33
@author adm_tla8
@since 3/6/2023
/*/
User Function MT103DRF()

	Local aImpRet := {}
	Local nValor  := 1
	//    - PARAMIXB[1]    Numérica   Combobox com os valores (1=Sim; 2=Não)
	//    - PARAMIXB[2]    Array       Código da Retenção
	//    - PARAMIXB[3]    Objeto      Objeto combo passado por referência
	//    - PARAMIXB[4]    Objeto      Objeto Textbox passado por referência

	If upper(cSerie) != "ALU"
		aAdd(aImpRet,{"IRR", nValor , "1708"})
	Else
		aAdd(aImpRet,{"IRR", nValor , "3208"})
	EndIf
	aAdd(aImpRet,{"PIS", nValor , "5952"})
	aAdd(aImpRet,{"COF", nValor , "5952"})
	aAdd(aImpRet,{"CSL", nValor , "5952"})

Return ( aImpRet )
