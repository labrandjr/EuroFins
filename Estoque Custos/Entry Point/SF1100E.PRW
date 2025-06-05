#include "rwmake.ch"

/*/{Protheus.doc} SF1100E
Exclui registros das tabelas SZA e CD5 na exclusão da NF entrada.
@author Marcos Candido
@since 02/01/2018

/*/
User Function SF1100E()

	Local aAreaAtual := GetArea()
	Local aInfo   := {}
	Local cEvento := "Z19"

	//Chama integração com Coupa
	u_intInvoice( .F. , .T. )
	u_goodReceipt( .F. , .T. )
	
	If AliasInDic("SZA")
	
		dbSelectArea("SZA")
		dbSetOrder(2)
		dbSeek(xFilial("SZA")+SF1->(F1_FORNECE+F1_LOJA),.T.)
	
		While !Eof() .and. ZA_FILIAL+ZA_FORNECE+ZA_LOJA == SF1->(F1_FILIAL+F1_FORNECE+F1_LOJA)
	
			If ZA_NUMDOC+ZA_SERIE == SF1->(F1_DOC+F1_SERIE)
				RecLock("SZA",.F.)
				  Replace	ZA_STATUS	With	"1"
				  Replace	ZA_NUMDOC	With	Space(Len(ZA_NUMDOC))
				  Replace	ZA_SERIE	With	Space(Len(ZA_SERIE))
				  Replace	ZA_DATANF	With	CtoD(Space(8))
				MsUnlock()
			ElseIf ZA_NFCOMPL+ZA_SERNFC == SF1->(F1_DOC+F1_SERIE)
				RecLock("SZA",.F.)
				  Replace	ZA_NFCOMPL	With	Space(Len(ZA_NFCOMPL))
				  Replace	ZA_SERNFC	With	Space(Len(ZA_SERNFC))
				MsUnlock()
			Endif
			dbSkip()
	
		Enddo
	
		dbSelectArea("CD5")
		dbSetOrder(1)
		dbSeek(xFilial("CD5")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),.T.)
	
		While !Eof() .and. CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	
			RecLock("CD5",.F.)
			  dbDelete()
			MsUnlock()
			dbSkip()
	
		Enddo
	
	Endif
	
	If SM0->M0_CODIGO == '01' .and. SF1->F1_TIPO == 'N'
	
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
		While !Eof() .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD1->D1_COD)
	
			//³ Envia e-mail aos usuarios cadastrados de que o produto com TIPO igual a MP e o  ³
			//³ GRUPO igual a PAD teve sua nota excluida. E pede para ele avaliar a rotina de   ³
			//³ Diferimento de Padroes.                                                         ³
			If SB1->B1_TIPO == 'MP' .and. SB1->B1_GRUPO == 'PAD '
				If Len(aInfo) == 0
					aadd(aInfo , "A nota fiscal Número/Série "+SF1->F1_DOC+"/"+SF1->F1_SERIE+" do fornecedor "+SF1->F1_FORNECE+"/"+SF1->F1_LOJA+;
				       " acaba de ser excluída no sistema. Verifique se o(s) produto(s) abaixo foi(ram) cadastrado(s) na rotina de Diferimento de Padrões.")
				 	aadd(aInfo , " ")
				Endif
				aadd(aInfo , "Código: "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC))
				aadd(aInfo , " ")
			Endif
	
			dbSelectArea("SD1")
			dbSkip()
	
		Enddo
	
		If Len(aInfo) > 0
			aadd(aInfo , "Favor verificar. ")
			MEnviaMail(cEvento,aInfo)
		Endif
	
	Endif
	
	
	RestArea(aAreaAtual)
	
Return (.T.)
