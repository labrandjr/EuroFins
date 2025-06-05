#include 'protheus.ch'
#include 'parmtype.ch'




/*/{Protheus.doc} VldEB01
Rotina para validar usuarios que só podem incluir pedido de compras para grupo EB01
@author RICARDO REY
@since 17/10/2017

/*/
user function VldEB01()
Local lRet := .t.
Local cGrupo := Posicione("SB1",1,xFilial("SB1")+M->C7_PRODUTO,"B1_GRUPO")

if at(RetCodUsr(),GetMV("MV_ZZEB01")) <> 0 .and. cGrupo <> 'EB01'
	MsgStop("Este usuário só pode cadastrar pedidos de compra de produtos do grupo EB01" ,"Pedido de Compras")
	lRet := .f.
endif

Return lRet



