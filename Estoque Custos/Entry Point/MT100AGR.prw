#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} MT100AGR
Ap�s a grava��o da nota de entrada , grava conta cont�bil e centro de custo na tabela SFT.
@author Marcos Candido
@since 22/08/2013
/*/

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MT100AGR � Autor � Marcos Candido        � Data �22/08/13  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada apos gravacao da nota fiscal de entrada   ���
���          � Utilizado para gravar a conta contabil e centro de custo   ���
���          � em campos da tabela SFT.                                   ���
���          �                                                            ���
��� 26/05/14 � Para gravar automaticamente os codigos de retencao 		  ���
���          � nos titulos gerados de impostos e que serao recolhidos     ���
���          � atraves de DARF. 										  ���
���          �                                                            ���
��� 06/01/15 � Atualizar o vencimento do titulo a pagar conforme nova     ���
���          � regra estabelecida pela diretoria da Eurofins. Os venci-   ���
���          � mentos deverao cair todas as tercas ou quintas da 1a e 3a  ���
���          � semana do mes considerando o prazo de 60 dias a partir da  ���
���          � emissao da nota                                            ���
���          � Caso a data de pagamento (terca e quinta-feira da primeira ���
���          � e terceira semanas do mes) recaia em dia nao util, por     ���
���          � conta de feriados nacionais, estaduais ou municipais, o    ���
���          � pagamento sera automaticamente prorrogado para o primeiro  ���
���          � dia util subsequente.                                      ���
���          �                                                            ���
��� 09/09/16 � Envia e-mail aos usuarios cadastrados de que o produto com ���
��� 	     � TIPO igual a MP e o GRUPO igual a PAD deve ser cadastrado  ���
��� 	     � na rotina de Diferimento de Padroes                        ���
���          �                                                            ���
/*/
User Function MT100AGR

	Local aAreaAtual  := GetArea()
	Local cFornUniao  := CriaVar("A2_COD")

	Local nVolume     := CriaVar("F1_VOLUME1")
	Local cEspecie    := CriaVar("F1_ESPECI1")
	Local nPBruto     := CriaVar("F1_PBRUTO")
	Local nPLiqui     := CriaVar("F1_PLIQUI")
	Local cTransp     := CriaVar("F1_TRANSP")
	Local cDados      := CriaVar("F1_MENNOTA")
	Local cDescTrans  := CriaVar("A4_NOME")
	Local cTitulo     := "Dados Complementares da Nota Fiscal de Importa��o: "+SF1->F1_DOC+"/"+SF1->F1_SERIE
	Local nOpc        := 0
	Local oDlg
	Local aInfo       := {}
	Local cEvento     := "Z16"
	Local aInfo2      := {}
	Local cEvento2    := "Z18"

	Public cF1_CODNFE := SF1->F1_CODNFE

	If INCLUI .or. L103CLASS

		//�����������������������������������������������
		//� Atualizacao da tabela SFT conforme SD1      �
		//�����������������������������������������������
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
		While !Eof() .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

			dbSelectArea("SFT")
			dbSetOrder(1)
			If dbSeek(xFilial("SFT")+"E"+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD))
				RecLock("SFT",.F.)
				FT_CONTA := SD1->D1_CONTA
				FT_ZZCC  := SD1->D1_CC
				MsUnlock()
			Endif

			//����������������������������������Ŀ
			//� Posiciona SB1                    �
			//������������������������������������
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD1->D1_COD)

			//  //EM REUNIAO DIA 25/09/2017 FOI ACORDADO COM A GISELE A DESATIVACAO DO ENVIO DE EMAIL DE ESTOQUE MAXIMO PARA ANATECH
			//    // TAMBEM FOI ACORDADO QUE O EMAIL DE DIFERIMENTO DEVE SER ENVIADO PARA NF DE QUALQUER EMPRESA E NAO SOMENTE EUROFINS
			// If SM0->M0_CODIGO == '05'
			// 	//�������������������������������������������������������Ŀ
			// 	//� Verifica se o produto atingiu o estoque maximo.       �
			// 	//���������������������������������������������������������

			// 	//����������������������������������Ŀ
			// 	//� Posiciona SB2                    �
			// 	//������������������������������������
			// 	dbSelectArea("SB2")
			// 	dbSetOrder(1)

			// 	//ALTERADO POIS O CAMPO B2_X_EMAX NAO FOI ENCONTRADO NO P11
			// 	//If dbSeek(xFilial("SB2")+SD1->(D1_COD+D1_LOCAL)) .and. SB2->B2_X_EMAX > 0
			// 	If dbSeek(xFilial("SB2")+SD1->(D1_COD+D1_LOCAL)) .and. SB1->B1_EMAX > 0

			// 		//nSaldoSB2 := SALDOSB2(.T.,.T.,dDataBase)//+SD1->D1_QUANT
			// 		nSaldoSB2 := CalcEst(SD1->D1_COD, SD1->D1_LOCAL, dDataBase+1)[1]

			// 		//ALTERADO POIS O CAMPO B2_X_EMAX NAO FOI ENCONTRADO NO P11
			// 		//If nSaldoSB2 >= SB2->B2_X_EMAX
			// 		If nSaldoSB2 >= SB1->B1_EMAX
			// 			//���������������������������������������������������������������������������������������������������������������Ŀ
			// 			//� Envia e-mail aos usuarios cadastrados de que o saldo do produto ficou igual ou maior que o estoque maximo.    �
			// 			//�����������������������������������������������������������������������������������������������������������������
			// 			aadd(aInfo , "O produto "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" chegou ao saldo de "+;
				// 			           Transform(nSaldoSB2,"@E 999,999.9999")+" "+SB1->B1_UM+" no armaz�m "+SB2->B2_LOCAL+", o que significa que � maior ou igual a seu estoque m�ximo, que � de "+;
				// 			           //ALTERADO POIS O CAMPO B2_X_EMAX NAO FOI ENCONTRADO NO P11
			// 			           //Transform(SB2->B2_X_EMAX,"@E 999,999.9999")+" "+SB1->B1_UM+".")
			// 			           Transform(SB1->B1_EMAX,"@E 999,999.9999")+" "+SB1->B1_UM+".")
			// 			aadd(aInfo , " ")
			// 		Endif

			// 	Endif

			// Elseif SM0->M0_CODIGO == '01' .and. SF1->F1_TIPO == 'N'
			if SF1->F1_TIPO == 'N'
				//���������������������������������������������������������������������������������Ŀ
				//� Envia e-mail aos usuarios cadastrados de que o produto com TIPO igual a MP e o  �
				//� GRUPO igual a PAD deve ser cadastrado na rotina de Diferimento de Padroes       �
				//�����������������������������������������������������������������������������������
				If SB1->B1_TIPO == 'MP' .and. SB1->B1_GRUPO == 'PAD '
					If Len(aInfo2) == 0
						aadd(aInfo2 , "A nota fiscal N�mero/S�rie "+SF1->F1_DOC+"/"+SF1->F1_SERIE+" do fornecedor "+SF1->F1_FORNECE+"/"+SF1->F1_LOJA+;
							" acaba de ser inclu�da no sistema. Verifique se o(s) produto(s) abaixo deve(m) ser cadastrado(s) na rotina de Diferimento de Padr�es.")
						aadd(aInfo2 , " ")
					Endif
					aadd(aInfo2 , "C�digo: "+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC))
				Endif
			endif
			//Endif

			dbSelectArea("SD1")
			dbSkip()

		Enddo

		//SECTION - grava��o usu�rio classificacao
		//NOTE alterado por Leandro Cesar - 20/03/23
		//REVIEW Grava o usu�rio que fez a classifica��o da nota fiscal
		If SF1->(FieldPos("F1_XLOGCLA")) > 0
			reclock("SF1",.F.)
			SF1->F1_XLOGCLA := alltrim(cUserName)
			SF1->(MsUnlock())
		EndIf
		//!SECTION

		If SF1->(FieldPos("F1_XDTCLAS")) > 0
			reclock("SF1",.F.)
			SF1->F1_XDTCLAS := Date()
			SF1->(MsUnlock())
		EndIf

		If Len(aInfo) > 0
			aadd(aInfo , "Favor verificar. ")
			MEnviaMail(cEvento,aInfo)
		Endif

		If Len(aInfo2) > 0
			aadd(aInfo2 , " ")
			aadd(aInfo2 , "Favor verificar. ")
			MEnviaMail(cEvento2,aInfo2)
		Endif

		//���������������������������������������������������������������������
		//� Atualizacao da tabela SE2 conforme registros dos impostos gerados �
		//���������������������������������������������������������������������
		cFornUniao := Padr(Alltrim(GetMV("MV_UNIAO")),6)+"00"
		dbSelectArea("SE2")
		dbSetOrder(6)
		If dbSeek(xFilial("SE2")+cFornUniao+SF1->(F1_PREFIXO+F1_DUPL),.T.)
			While se2->(!Eof() .and. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == xFilial()+cFornUniao+SF1->(F1_PREFIXO+F1_DOC))
				If Alltrim(SE2->E2_NATUREZ) == Alltrim(&(GetMV("MV_IRF"))) .AND. !SF1->F1_SERIE $ "RPA|ALU"
					RecLock("SE2",.F.)
					SE2->E2_DIRF   := "1"
					SE2->E2_CODRET := "1708"
					MsUnlock()
				elseif Alltrim(SE2->E2_NATUREZ) == Alltrim(&(GetMV("MV_IRF"))) .AND. SF1->F1_SERIE == "ALU"
					RecLock("SE2",.f.)
					SE2->E2_DIRF := '1'
					SE2->E2_CODRET := '3208'
					SE2->(MsUnlock())
				Endif
				If Alltrim(SE2->E2_NATUREZ) == Alltrim(GetMV("MV_PISNAT"))
					RecLock("SE2",.F.)
					SE2->E2_DIRF   := "1"
					SE2->E2_CODRET := "5952"
					MsUnlock()
				Endif
				If Alltrim(SE2->E2_NATUREZ) == Alltrim(GetMV("MV_COFINS"))
					RecLock("SE2",.F.)
					SE2->E2_DIRF   := "1"
					SE2->E2_CODRET := "5952"
					MsUnlock()
				Endif
				If Alltrim(SE2->E2_NATUREZ) == Alltrim(GetMV("MV_CSLL"))
					RecLock("SE2",.F.)
					SE2->E2_DIRF   := "1"
					SE2->E2_CODRET := "5952"
					MsUnlock()
				Endif
				If SF1->F1_SERIE == 'RPA' .AND. AllTrim(SF1->F1_ESPECIE) == 'FAT' .AND. SF1->F1_VALIRF > 0 .and. 'TX' $ AllTrim(E2_TIPO)
					RecLock("SE2",.f.)
					SE2->E2_DIRF := '1'
					SE2->E2_CODRET := '0588'
					SE2->(MsUnlock())
				Endif
				dbSkip()
			Enddo
		Endif

		//Retirado a valida��o dos dados de importa��o pois foi criada outra tela para grava��o da importa��o devido a necessidade de mais campos
		//Ticket#2019082910049676


		// //�����������������������������������������������������������������������������������
		// //� Abre janela para digitacao de dados adicionais pois trata-se de uma importacao  �
		// //�����������������������������������������������������������������������������������
		// If SF1->F1_EST == 'EX' .AND. SF1->F1_FORMUL == 'S'

		// 	@ 115,085 To 330,575 Dialog oDlg Title cTitulo
		// 	@ 002,003 To 082,245 Title ""

		// 	@ 1.0,1.1 Say OemToAnsi('Nr de Volumes ')
		// 	@ 0.8,6.4 MsGet nVolume  Picture "@E 9999.999" Size 56,10
		// 	@ 1.0,17.6 Say OemToAnsi('Esp�cie       ')
		// 	@ 0.8,22.6 MsGet cEspecie Picture "@!" Size 56,10

		// 	@ 2.1,1.1 Say OemToAnsi('Peso Bruto    ')
		// 	@ 1.9,6.4 MsGet nPBruto Picture "@E 999,999.999" Size 56,10
		// 	@ 2.1,17.6 Say OemToAnsi('Peso L�quido  ')
		// 	@ 1.9,22.6 MsGet nPLiqui Picture "@E 999,999.999" Size 56,10

		// 	@ 3.2,1.1 Say OemToAnsi('Transportadora')
		// 	@ 3.0,6.4 MsGet cTransp Picture "@!" F3 "SA4" Valid VeSA4(cTransp,@cDescTrans) Size 40,10
		// 	@ 3.0,12.1 MsGet cDescTrans When .F. Size 140,10

		// 	@ 4.3,1.1 Say OemToAnsi('Dados Adicionais')
		// 	@ 4.1,6.4 MsGet cDados Picture "@!" Size 186,10

		// 	@ 089,090 BmpButton Type 1 Action(nOpc:=1,Close(oDlg))
		// 	@ 089,125 BmpButton Type 2 Action(Close(oDlg))

		// 	Activate Dialog oDlg Centered

		// 	If nOpc == 1

		// 		dbSelectArea("SF1")
		// 		RecLock("SF1",.F.)
		// 		  SF1->F1_VOLUME1  := nVolume
		// 		  SF1->F1_ESPECI1  := cEspecie
		// 		  SF1->F1_PBRUTO   := nPBruto
		// 		  SF1->F1_PLIQUI   := nPLiqui
		// 		  SF1->F1_TRANSP   := cTransp
		// 		  SF1->F1_MENNOTA  := cDados
		// 		MsUnlock()

		// 	Endif

		// Endif

		//���������������������������������������������������������������������
		//� Se a transportadora foi indicada, crio registro na tabela SF8     �
		//� (Amarracao NF Orig x NF Imp/Fre) o que possibilitara o uso dessa  �
		//� transportadora nos relatorios de controle de produtos controlados.�
		//���������������������������������������������������������������������
		//Retirado esse reclock pois estava impedindo de excluir uma nota fiscal de importa��o
		//devido a esse registro de de NF complementar e no nosso caso, n�o � nota complementar
		//chamado Ticket#2020011010032568
		// If !Empty(SF1->F1_TRANSP)
		// 	dbSelectArea("SF8")
		// 	RecLock("SF8",.T.)
		// 	  Replace F8_FILIAL 	With xFilial("SF8")
		// 	  Replace F8_NFDIFRE 	With cNFiscal
		// 	  Replace F8_SEDIFRE 	With cSerie
		// 	  Replace F8_LOJTRAN 	With cLoja
		// 	  Replace F8_TRANSP		With SF1->F1_TRANSP
		// 	  Replace F8_DTDIGIT 	With SF1->F1_DTDIGIT
		// 	  Replace F8_NFORIG		With SF1->F1_DOC
		// 	  Replace F8_SERORIG 	With SF1->F1_SERIE
		// 	  Replace F8_FORNECE 	With SF1->F1_FORNECE
		// 	  Replace F8_LOJA		With SF1->F1_LOJA
		// 	  //Replace F8_TIPO		With "F"
		// 	MsUnlock()
		// Endif

	Endif

	RestArea(aAreaAtual)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � VeSA4    �Autor  �Marcos Candido      � Data �  07/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Consiste Transportadora                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VeSA4(cTransp,cDescTrans)

	Local lRet := .T.
	Local aAreaAtual := GetArea()

	dbSelectArea("SA4")
	dbSetOrder(1)
	If !Empty(cTransp)
		If !dbSeek(xFilial("SA4")+cTransp)
			IW_MsgBox(OemToansi("C�digo inv�lido. Verifique."),OemToAnsi("Aten��o!"),"ALERT")
			lRet := .F.
		Else
			cDescTrans := SA4->A4_NOME
		Endif
	Else
		IW_MsgBox(OemToansi("C�digo inv�lido. Verifique."),OemToAnsi("Aten��o!"),"ALERT")
		lRet := .F.
	Endif

	RestArea(aAreaAtual)

Return lRet
