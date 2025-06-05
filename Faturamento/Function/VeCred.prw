#include "rwmake.ch"


/*/{Protheus.doc} VeCred
Gatilho no campo C5_CLIENTE se cliente de Exportacao. Verifica se
existe titulo de R.A. inserido, se nao tiver, uma mensagem
sera exibida avisando e se o usuario deseja continuar. O
usuario pode informar que sim e prosseguir, ou nao e entao
os campos CLIENTE e LOJA serao limpos.
@author Marcos Candido
@since 02/01/2018
/*/
User Function VeCred

Local aAreaAtual := GetArea()
Local cRet := M->C5_CLIENTE , lTem , nOpt
Local nUm := 1 , lVai := .T.

While !(ProcName(nUm) == "") .and. lVai
	If UPPER(Alltrim(ProcName(nUM))) == "INSPVENDA"
		lVai := .F.
	Endif
	nUm++
Enddo

If lVai

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)

	If !Eof() .and. A1_EST == "EX"
		dbSelectArea("SE1")
		dbSetOrder(8) // Cliente + Loja + Status + Vencto real
		dbSeek(xFilial("SE1")+M->C5_CLIENTE+M->C5_LOJACLI)

		lTem := .F.
		While !Eof() .and. E1_CLIENTE+E1_LOJA == M->C5_CLIENTE+M->C5_LOJACLI .and. E1_FILIAL == xFilial("SE1")

			If E1_TIPO == "RA " .and. E1_SALDO > 0 		// O TITULO TEM QUE SER R.A. E COM SALDO MAIOR QUE ZERO
				lTem := .T.
			Endif
			dbSkip()

		Enddo

		If !lTem
			nOpt := Aviso(OemToAnsi("Atenção") ,;
			 OemToAnsi("O Cliente não tem R.A. cadastrado ou, o R.A. já foi compensado. Verifique.") ,;
			 {"Continua" , "Cancela"})
			If nOpt == 2
				cRet := Space(6)
				M->C5_LOJACLI := Space(2)
				M->C5_CLIENT  := Space(6)
				M->C5_LOJAENT := Space(2)
				SysRefresh()
			Endif
		Endif

	Endif

Endif

RestArea(aAreaAtual)

Return(cRet)