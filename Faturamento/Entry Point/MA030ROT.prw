#include 'protheus.ch'

/*
���Programa  � MA030ROT �Autor  � Marcos Candido     � Data �  18/02/13   ���
���Desc.     � Ponto de entrada na rotina de Cadastro de clientes para    ���
���          � permitir a inclusao de novos botoes na tela principal.     ���
���          � Usado para permitir ao usuario que cadastre uma mensagem   ���
���          � no campo A1_OBSERV para todas as lojas que estivem sob o   ���
���          � mesmo codigo.                                              ���
*/
/*/{Protheus.doc} MA030ROT
Na rotina de Cadastro de clientes para permitir a inclusao de novos botoes na tela principal.
Usado para permitir ao usuario que cadastre uma mensagem no campo A1_OBSERV para todas as lojas que estivem sob o mesmo codigo.
@author Marcos Candido
@since 02/01/2018
/*/
User Function MA030ROT

Local aMaisOpt := {}

aadd(aMaisOpt ,	{ "At.&Observ.","U_SA1Obs", 0, 3, 0, .T.})

Return aMaisOpt


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA030ROT  �Autor  �Microsiga           � Data �  02/18/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function SA1Obs

Local nOpt := 0
Local cMsg := Space(100)
Local oDlg, oBtBrw, oBtOk, oBtCan
Local lTodos := .T.
Local aAreaAtual := GetArea()
Local cCodCli := SA1->A1_COD
Local cLojCli := SA1->A1_LOJA

//���������������������������������������������������������������������Ŀ
//� Montagem da tela de interface com o usuario                         �
//�����������������������������������������������������������������������
Define MsDialog oDlg Title OemToAnsi("Atualiza��o do campo OBSERVA��O") From 00,00 to 185,480 Pixel

@ 00.4,01 To 06,25
@ 01,03 Say OemToansi("Esta op��o permite que uma mensagem seja gravada no campo de ")
@ 02,03 Say OemToansi("OBSERVA��O (A1_OBSERV) no cadastro de Clientes. O contexto ")
@ 03,03 Say OemToansi("poder� ser aplicado em todas as lojas do c�digo posicionado.")
@ 04.50,03 Say OemToansi("Mensagem:")
@ 66,023 MsGet cMsg Size 160,08 of oDlg Pixel

Define sButton oBtOk  From 005,208 Type 1  Action (nOpt := 1, oDlg:End()) Enable of oDlg Pixel
Define sButton oBtCan From 020,208 Type 2  Action (nOpt := 0, oDlg:End()) Enable of oDlg Pixel

Activate MsDialog oDlg Center

If nOpt == 1  .and. !Empty(cMsg)

	If Aviso("Atualiza��o","Aplicar a mensagem em todas as lojas do c�digo "+cCodCli+" ?", {"Sim","N�o"},1,"Informa��o") == 2
		lTodos := .F.
	Endif

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cCodCli)

	While !Eof() .and. xFilial("SA1")==SA1->A1_FILIAL .AND. SA1->A1_COD == cCodCli
		If lTodos
			RecLock("SA1",.F.)
			  A1_OBSERV := cMsg
			MsUnlock()
		Else
			If SA1->A1_LOJA == cLojCli
				RecLock("SA1",.F.)
				  A1_OBSERV := cMsg
				MsUnlock()
			Endif
		Endif
		dbSkip()
	Enddo

	Aviso("Atualiza��o","Processo conclu�do.", {"Sair"},1,"Informa��o")

Endif

RestArea(aAreaAtual)

Return