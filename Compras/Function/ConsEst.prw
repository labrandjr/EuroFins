#include 'rwmake.ch'

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} ConsEst
gatilho no campo C1_QUANT, verifica se o saldo em estoque eh maior que o estoque de seguranca.
Se for, nao deixa o usuario incluir a S.C.
Ele sera avisado para fazer uma Requisicao interna.
@author Marcos Candido
@since 29/12/2017

/*/
User Function ConsEst(cProd,nQuant,cLoc)

Local nSaldoEst := 0 , nAux := 0 , nQtdPrev := 0
Local xRet
Local cMens1    := "O saldo em estoque deste item é maior que o Estoque de Segurança indicado no cadastro."
Local cMens2    := "Saldo Atual: "
Local cMens3    := "Estoque de Segurança: "
Local cMens4    := "Não há necessidade de fazer uma nova compra. Use a Requisição Interna."
Local cMens5    := "Não há saldo em estoque para este item."
Local cMens6    := "Providencie que uma Solicitação de Compra seja incluída para dar início ao processo de compras."
Local cMens7    := "Não há cadastro de Saldo Inicial para este produto. Cadastre-o primeiro antes de prosseguir."
Local cMens8    := "Este produto ainda não foi atualizado com a quantidade que deve avisar a respeito do Estoque de Segurança."
Local cMens9    := "A rotina seguirá normalmente, no entanto verifique a possibilidade de preencher esse campo."
Local cMens10   := "O saldo em estoque deste item é insuficiente para atender a sua solicitação."
Local cMens11   := "Utilize a tecla F4 no campo CÓDIGO DO PRODUTO para visualizar a quantidade disponível."
//Local cMens12   := "O saldo em estoque deste item é maior que o Ponto de Pedido indicado no cadastro." //"O saldo em estoque deste item é maior que o Estoque Mínimo indicado no cadastro."
//Alterado a mensagem, vez de considerar o estoque minimo, irá considerar o estoque máximo
Local cMens12   := "O saldo em estoque deste item é maior que Estoque Máximo indicado no cadastro." //"O saldo em estoque deste item é maior que o Estoque Maximo indicado no cadastro."
Local cMens13   := "Ponto de Pedido: " //"Estoque Mínimo: "
Local cMens14   := "Este produto ainda não foi atualizado com a quantidade que deve avisar a respeito do Ponto de Pedido." //"Este produto ainda não foi atualizado com a quantidade que deve avisar a respeito do Estoque Mínimo."
Local cMens15   := "Este produto ainda não foi atualizado com a quantidade que deve avisar a respeito do Estoque Máximo."
Local cMens16   := "Somando-se o saldo em estoque com a quantidade prevista de entrega e a quantidade digitada nesta S.C., extrapola-se o estoque máximo permitido para o produto."
Local cMens17   := "Ajuste a quantidade de sua S.C. e/ou verifique a quantidade a ser entregue e sua previsão de chegada."
Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])== "CP_QUANT"})
Local nPosLocal := aScan(aHeader,{|x| AllTrim(x[2])== "CP_LOCAL"})
cLoc := aCols[n][nPosLocal]

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cProd))
SB2->(dbSetOrder(1))
If SB2->(dbSeek(xFilial("SB2")+cProd+cLoc))

	nQtdPrev := SB2->B2_SALPEDI

	nSaldoEst := CalcEst(cProd, cLoc, dDataBase+1)[1]

	If IsInCallStack("MATA110") // Solicitacao de compra
//		If SM0->M0_CODIGO == '01'
			If SB1->B1_EMAX > 0
			 	// Somo a Qtd disponivel em estoque com a Qtd que o usuario esta indicando na SC e a Qtd Prevista a entrar
			 	// Se o resultado for maior do que o estabelecido pelo estoque maximo, nao deve deixar o usuario continuar
				nAux := nSaldoEst + nQuant + nQtdPrev
				If nAux > SB1->B1_EMAX
					Aviso("Informação" , cMens16+ENTER+cMens17 , {"Ok"} , 3)
					xRet := 0
				Endif
			Else
				Aviso("Informação" , cMens15+ENTER+cMens9 , {"Ok"} , 3)
				xRet := nQuant
			Endif

			//Alterado de B1_EMIN para B1_EMAX, pois ao colocar um pedido maior que o estoque minimo, não deixava concluir o PC - Régis Ferreira
			If SB1->B1_EMAX > 0
				//If nSaldoEst > SB1->B1_ESTSEG
				If nSaldoEst > SB1->B1_EMAX
					//Aviso("Atenção" , cMens12+ENTER+ENTER+cMens2+Alltrim(Transform(nSaldoEst,"@E 999,999,999.99999"))+ENTER+cMens13+Alltrim(Transform(SB1->B1_ESTSEG,"@E 999,999,999.99999"))+ENTER+ENTER+cMens4 , {"Sair"} , 3)
					Aviso("Atenção" , cMens12+ENTER+ENTER+cMens2+Alltrim(Transform(nSaldoEst,"@E 999,999,999.99999"))+ENTER+cMens13+Alltrim(Transform(SB1->B1_EMIN,"@E 999,999,999.99999"))+ENTER+ENTER+cMens4 , {"Sair"} , 3)
		        	xRet := 0
		   		Else
		   			xRet := nQuant
			  	Endif
			Else
				Aviso("Informação" , cMens14+ENTER+cMens9 , {"Ok"} , 3)
				xRet := nQuant
			Endif
/*
		Else
			//If SB2->B2_X_PPEDI > 0
			if SB1->B1_ESTSEG > 0
				//If nSaldoEst > SB2->B2_X_PPEDI // SB1->B1_ESTSEG
				If nSaldoEst >  SB1->B1_ESTSEG
					//Aviso("Atenção" , cMens1+ENTER+ENTER+cMens2+Alltrim(Transform(nSaldoEst,"@E 999,999,999.99999"))+ENTER+cMens3+Alltrim(Transform(SB2->B2_X_PPEDI,"@E 999,999,999.99999"))+ENTER+ENTER+cMens4 , {"Sair"} , 3)
					Aviso("Atenção" , cMens1+ENTER+ENTER+cMens2+Alltrim(Transform(nSaldoEst,"@E 999,999,999.99999"))+ENTER+cMens3+Alltrim(Transform(SB1->B1_ESTSEG,"@E 999,999,999.99999"))+ENTER+ENTER+cMens4 , {"Sair"} , 3)
		        	xRet := 0
		   		Else
		   			xRet := nQuant
			  	Endif
			Else
				Aviso("Informação" , cMens8+ENTER+cMens9 , {"Ok"} , 3)
				xRet := nQuant
			Endif
		Endif
*/
	ElseIf IsInCallStack("MATA105")  // Solicitacao ao Armazem
		If nSaldoEst <= 0
			Aviso("Atenção" , cMens5+ENTER+ENTER+cMens6 , {"Sair"} , 3)
        	aCols[n][nPosQuant] := 0
			xRet := Space(Len(cProd))
		ElseIf nQuant > nSaldoEst
			Aviso("Atenção" , cMens10+ENTER+ENTER+cMens11 , {"Sair"} , 3)
        	xRet := cProd
        	aCols[n][nPosQuant] := 0
		Else
			xRet := cProd
	  	Endif
	Endif

Else

	If IsInCallStack("MATA110") // Solicitacao de compra
		xRet := nQuant
	ElseIf IsInCallStack("MATA105")  // Solicitacao ao Armazem
		Aviso("Atenção" , cMens7 , {"Sair"} , 3)
       	xRet := Space(Len(cProd))
	Endif

Endif

SysRefresh()

Return xRet
