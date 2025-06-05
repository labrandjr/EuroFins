#include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Mt930SF3 ºAutor  ³ Marcos Candido     º Data ³  22/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada no reprocessamento do livro fiscal.       º±±
±±º          ³                                                            º±±
±±³          ³ Utilizado para gravar a conta contabil e centro de custo   ³±±
±±³          ³ em campos da tabela SFT.                                   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/




/*/{Protheus.doc} MT930SF3
No reprocessamento do livro fiscal.  Utilizado para gravar a conta contabil e centro de custo em campos da tabela SFT.
@author Marcos Candido
@since 22/08/2013
/*/
User Function MT930SF3

Local aAreaAtual := GetArea()

SB1->(dbSetOrder(1))

If Substr(SF3->F3_CFO,1,1) < "5"  // NOTA DE ENTRADA

	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA))

	While !Eof() .and. xFilial("SD1")+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == ;
	          SF3->(F3_FILIAL+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)

		dbSelectArea("SFT")
		dbSetOrder(1)
		If dbSeek(xFilial("SFT")+"E"+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD))
			RecLock("SFT",.F.)
			  FT_CONTA := SD1->D1_CONTA
			  FT_ZZCC  := SD1->D1_CC
			MsUnlock()
		Endif
		dbSelectArea("SD1")
		dbSkip()

	Enddo

Else							// NOTA DE SAIDA

	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial("SD2")+SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA))

	While !Eof() .and. xFilial("SD2")+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == ;
	          SF3->(F3_FILIAL+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)

		SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))

		dbSelectArea("SFT")
		dbSetOrder(1)
		If dbSeek(xFilial("SFT")+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+PADR(D2_ITEM,4)+D2_COD))
			RecLock("SFT",.F.)
			  FT_CONTA := SB1->B1_CONTA
			  FT_ZZCC  := SB1->B1_ZZCCUST
			MsUnlock()
		Endif

		dbSelectArea("SD2")
		RecLock("SD2",.F.)
  		  SD2->D2_CONTA := SB1->B1_CONTA
		  SD2->D2_ZZCC  := SB1->B1_ZZCCUST
		MsUnlock()
		dbSkip()

	Enddo

Endif

RestArea(aAreaAtual)

Return
