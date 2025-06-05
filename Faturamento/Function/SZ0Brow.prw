#include "rwmake.ch"


/*/{Protheus.doc} SZ0Brow
Browse para permitir manutencao das Classificacoes dadas as notas fiscais da Eurofins
@author Marcos Candido
@since 02/01/2018
/*/
User Function SZ0Brow

dbSelectArea("SZ0")

AxCadastro("SZ0",OemToAnsi("Classificação da N.F. Eurofins"))

dbSelectArea("SZ0")
RetIndex("SZ0")

Return