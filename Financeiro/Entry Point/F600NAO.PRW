#include "rwmake.ch" 
/*/{protheus.doc} SPDF6001
Retorna motivos de baixa.
@author Unknow
@since __/__/____
@history 17/06/2020, Gabriel Da Silva Souza, Retirado o Motivo de Baixa CMP pois ele é necessário no bloco F600.
/*/
User Function SPDF6001()
	Local cMotBaixas	:=	"" //Tipos referentes aos motivos das baixas dos titulos que nao devem ser enviados no BLOCO F600 do SPED PIS/COFINS.	
	cMotBaixas :="DAC,CAN,DEV,PCL"
Return(cMotBaixas)