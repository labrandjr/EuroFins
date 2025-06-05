#include "rwmake.ch"

#DEFINE ENTER CHR(13)+CHR(10)
/*/{Protheus.doc} MT120LOK
Valida de linha na rotina de Pedido de Compras se o item digitado esta com os campos Conta Contabil e Centro de Custo preenchidos.
@author Marcos Candido
@since 29/12/2017
/*/
User Function MT120LOK

	Local lRet       := .T.
	Local nPItem     := aScan(aHeader,{|x| Trim(x[2])=="C7_ITEM"})
	Local nPCCusto   := aScan(aHeader,{|x| Trim(x[2])=="C7_CC"})
	Local nPCtaC     := aScan(aHeader,{|x| Trim(x[2])=="C7_CONTA"})
	Local nPVlUnit   := aScan(aHeader,{|x| Trim(x[2])=="C7_PRECO"})
	Local nPVlTot    := aScan(aHeader,{|x| Trim(x[2])=="C7_TOTAL"})

	Local cConta     := aCols[n,nPCtaC]
	Local cCC        := aCols[n,nPCCusto]
	Local cItemPC    := aCols[n,nPItem]
	Local nVlrUnit   := aCols[n,nPVlUnit]
	Local nVlrTot    := aCols[n,nPVlTot]

	Local cMens0 := ""
	Local cMens1 := "Centro de Custo Obrigatório !"
	Local cMens2 := "O Centro de Custo não deve ser informado !"
	Local cMens3 := "Conta Contábil Obrigatória !"
	Local cMens4 := "O Valor Unitário está zerado."
	Local cMens5 := "O Valor Total está zerado."


	/*
	If !Empty(cConta)
		If !(Substr(cConta,1,1) $ "12") .and. Empty(cCC)
			cMens0 := cMens1
		ElseIf Substr(cConta,1,1) $ "12" .and. !Empty(cCC)
			cMens0 := cMens2
		Endif
	Else
		cMens0 := cMens3
	Endif
	*/
	/*If Empty(cCC)
		cMens0 := cMens1
	Endif*/

	If !Empty(cMens0)
		Aviso(OemToAnsi("Atenção") , OemToAnsi(cMens0+ENTER+ENTER+"Verifique o item "+cItemPC+".") , {"Sair"})
		lRet := .F.
	Endif

	If lRet .and. nVlrUnit <=0
		Aviso(OemToAnsi("Atenção") , OemToAnsi(cMens4+ENTER+ENTER+"Verifique o item "+cItemPC+".") , {"Sair"})
		lRet := .F.
	Endif

	If lRet .and. nVlrTot <=0
		Aviso(OemToAnsi("Atenção") , OemToAnsi(cMens5+ENTER+ENTER+"Verifique o item "+cItemPC+".") , {"Sair"})
		lRet := .F.
	Endif

Return lRet