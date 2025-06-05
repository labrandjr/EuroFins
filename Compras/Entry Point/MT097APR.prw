#include 'rwmake.ch'

/*/{protheus.doc}MT097APR 
Apos a gravacao da liberacao do pedido de compra. Usado para gravar campos especificos.
@Author  Marcos Candido 
@since 27/09/13   
/*/

User Function MT097APR
	If Alias()=="SC7"
		RecLock("SC7",.F.)
		SC7->C7_ZZMAIL := "N"
		SC7->(MsUnlock())
	Endif
Return