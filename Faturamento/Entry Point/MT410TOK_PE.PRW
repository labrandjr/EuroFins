#include "totvs.ch"
#include "topconn.ch"

/*
 Programa		:	MT410TOK
 Autor			:	Régis Ferreira - Totvs IP
 Data			:	16/12/2021
 Descricao		:	PE ao salvar o pedido de venda que irá validar se o campo C5_ZZPCLI esta preenchido
                    caso esteja, será replicado ao campo C6_PEDCLI
 Cliente		:	Clyde
 */

User Function MT410TOK()

	Local aArea     := GetArea()
	Local lRet      := .T.
	Local cPedCli   := Alltrim(M->C5_ZZPCCLI)
	Local nItem     := 0
	Local nPosPCC   := GDFieldPos("C6_PEDCLI")

	if !Empty(cPedCli) //Caso o campo esteja preechido, vai replicar ou não para o C6
		if MSGYESNO( "O campo do pedido de compras do cliente foi preenchido, replicar para todos os itens do pedido de venda?", "Replica pedido de compras do cliente?" )
			for nItem := 1 to len(aCols)
				aCols[nItem,nPosPCC] := cPedCli
			Next nItem
		endif
	endif

	cCliente  := AllTrim(M->C5_CLIENTE)
	cLoja     := AllTrim(M->C5_LOJACLI)
	cNatureza := AllTrim(M->C5_NATUREZ)
	(cTRB := GetNextAlias())
	BeginSql Alias cTRB
        Select
            ZB7_NATURE 'NATUREZA'
        From
            %Table:ZB7% ZB7
        where
            ZB7.%NotDel% AND
            ZB7_FILIAL = %Exp:cFilAnt% AND
            ZB7_CLIENT = %Exp:cCliente% AND
            ZB7_LOJA   = %Exp:cLoja%
	EndSql

	While (cTRB)->(!eof())

		cNatCli := (cTRB)->NATUREZA

		If alltrim(cNatCli) != alltrim(cNatureza)
			If FwAlertYesNo("Natureza do pedido de venda [" + alltrim(cNatureza) + "] diferente da natureza da amarracao <b>(cliente x natureza)</b> [" + alltrim(cNatCli) + "]. Deseja atualizar natureza?")
				M->C5_NATUREZ := cNatCli
				If Posicione("SED",1,xFilial("SED")+ PadL(cNatCli,TamSx3("C5_NATUREZ")[1]),"ED_CALCISS") == "S"
					M->C5_RECISS := "1"
				Else
					M->C5_RECISS := "2"
				EndIf
			EndIf
		EndIf
		(cTRB)->(dbSkip())
	End

	(cTRB)->(dbCloseArea())

	RestArea(aArea)

Return lRet
