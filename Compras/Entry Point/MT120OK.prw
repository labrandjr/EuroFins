#include "totvs.ch"
/*/{protheus.doc}MT120OK
Valida se o comprador tem permissão para o grupo de produtos.
@author Sergio Braz
@since 18/10/2019
/*/
User Function MT120OK
	Local i
	Local lRet := Posicione("SY1",3,xFilial("SY1")+__cUserId,"Alltrim(Y1_ZZGRP) == '*'")
	Local cProdutos := "" 
	Local cCod
	If !lRet       
		lRet := .t.
		For i := 1 to Len(aCols)
			cCod := aCols[i,GdFieldPos("C7_PRODUTO")]      
			Posicione("SB1",1,xFilial("SB1")+cCod,"")
			cProdutos += IIf(Empty(cProdutos),"",", ")+IIf(!Trim(SB1->B1_GRUPO)$Alltrim(SY1->Y1_ZZGRP).and.!Trim(cCod)$cProdutos,Trim(cCod),"")
		Next
	Endif
	If !Empty(cProdutos)
		MsgStop("Os produtos abaixo pertencem a grupos aos quais você não tem permissão de comprar"+CRLF+cProdutos,"MT120OK")
		lRet := .f.
	Endif
Return lRet