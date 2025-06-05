#include "totvs.ch"
#include "Protheus.ch"

/*/{protheus.doc}MT094CPC
PE para trazer a OBS do pedido de compras na aprovação de PCs
@author Régis Ferreira
@since 23/10/2019
/*/

User Function MT094CPC()
	//Johnny Fernandes - Totvs IP - 20/04/2020 - Adicionado | no começo, devido ser necessário como parametro do ponto de entrada, além de separar os demais campos com |
	Local cCampos := "|C7_OBS" //  A separação dos campos devem ser feitos com uma barra vertical ( | )
	 
Return (cCampos)