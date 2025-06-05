#include 'protheus.ch'

/*/{Protheus.doc} F240ADCM
Permite customizar a browse de border�s, incluindo campos a serem exibidos junto 
aos j� configurados padr�o, alimentando uma array contendo esses campos.
@type function
@author Johnny Fernandes
@since 16/12/2021
@version P12
@database MSSQL,Oracle
/*/

User Function F240ADCM()
    Local aCamposADCM := {}
    
    aAdd(aCamposADCM,'E2_ORIGEM')
    
Return aCamposADCM
