#include "totvs.ch"
#include "Protheus.ch"

/*/{protheus.doc}MT094CPC
PE para trazer a OBS do pedido de compras na aprova��o de PCs
@author R�gis Ferreira
@since 23/10/2019
/*/

User Function MT094CPC()
	//Johnny Fernandes - Totvs IP - 20/04/2020 - Adicionado | no come�o, devido ser necess�rio como parametro do ponto de entrada, al�m de separar os demais campos com |
	Local cCampos := "|C7_OBS" //  A separa��o dos campos devem ser feitos com uma barra vertical ( | )
	 
Return (cCampos)