#include "rwmake.ch"
#include "totvs.ch"
#include "xmlxfun.ch"

#DEFINE ENTER CHR(13)+CHR(10)

/*
╠╠╨Programa  Ё M460FIM  ╨Autor  Ё Marcos Candido     ╨ Data Ё  28/09/09   ╨╠╠
╠╠╨Desc.     Ё  Ponto de entrada no final do processamento das notas      ╨╠╠
╠╠╨          Ё  fiscais de saida. Estou verificando se eh devido ou nao   ╨╠╠
╠╠╨          Ё  o valor do IRRF. E dou tratamento caso esteja             ╨╠╠
*/
/*/{Protheus.doc} M460FIM
No final do processamento das notas fiscais de saida. Estou verificando se eh devido ou nao o valor do IRRF. E dou tratamento caso esteja
@author Marcos Candido
@since 02/01/2018
/*/
User Function M460FIM



// ******** NAO DEVE SER UTILIZADO *** DEIXADO APENAS PARA DOCUMENTAгцO DO HISTORICO ***************
//
// Este fonte foi retirado do projeto pois estava interferindo
// no calculo dos impostos na versЦo 12. Problema detectado pela Thais Fumagali em 09/01/18
// SerА reavaliado posteriormente apenas o trecho que gera o XML para o MyLins
//
//**************************************************************************************************

Local aAreaAtual := GetArea()
Local aAreaSE1   := {} , aDados := {}
Local lTemIr := .F.
Local cNatur  := ""
Local nPercIR := 0
Local lEntrei := .F. , aParam := {}
Local lCarrefour := .F.
Local aChaveSE1 := {}
Local cChvUnica := ""
Local cScript := ''
Local cPath   := SuperGetMV("ZZ_LOCMYRE",,"\XML_MYLIMS\RETORNO\")//"\XML_MYLIMS\RETORNO\"

Local aAreaSE1IR := {}	// Fausto Costa 02/06/2015
Local aAreaSEDIR := {}	// Fausto Costa 02/06/2015
Local aChvSE1IR	:= {} // Fausto Costa 02/06/2015
Local nPercIRRF	:= 0 // Fausto Costa 02/06/2015
Local nIRRFAux := 0 // Fausto Costa 02/06/2015
Local lIRRFOK := .F. // Fausto Costa 02/06/2015

Local aAreaSE1 := {}
Local aAreaSD2 := {}
Local aAreaSFT := {}
Local cNaturez := ""


dbSelectArea("SF2")

//
//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se houve alteracao na tabela SF2, deve-se       Ё
//Ё Reprocessar o Livro Fiscal.                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды

/*Retirado, pois segundo Agata Gomes os vencimentos devem respeitar as condiГУes de pagamento e desconsiderar as tratativas chumbadas.
If SM0->M0_CODIGO == '01'	// Eurofins

	//зддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifico se cliente eh o Carrefour, para dar    Ё
	//Ё tratamento especifico ao vencimento             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддды
	If SF2->F2_TIPO = 'N'
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
		If (Substr(SA1->A1_CGC,1,8)='45543915' .or. Substr(SA1->A1_CGC,1,8)='62545579')
			lCarrefour := .T.
		Endif
	Endif

	//зддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alteracao dos vencimentos dos titulos a receber Ё
	//Ё conforme solicitacao de cada cliente            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SE1")
	aAreaSE1 := GetArea()
	dbSetOrder(2)  // Filial+Cliente+Loja+Prefixo+No. Titulo+Parcela+Tipo
	If dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC))
		//зддддддддддддддддддд©
		//Ё Acucar Quata      Ё
		//Ё                   +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair nos dias 10, 15 ou 25  Ё
		//Ё                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		If SF2->F2_CLIENTE == "000001"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_VENCTO) >= 1 .and. Day(E1_VENCTO) <= 9
					cDiaCerto := "10"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 11 .and. Day(E1_VENCTO) <= 14
					cDiaCerto := "15"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 16 .and. Day(E1_VENCTO) <= 24
					cDiaCerto := "25"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 26
					cDiaCerto := "10"+Substr(DtoC(E1_VENCTO),3)
				Else
					cDiaCerto := DtoC(E1_VENCTO)
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo
		//зддддддддддддддддддд©
		//Ё Bunge             Ё
		//Ё                   +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair toda terca-feira       Ё
		//Ё mas se cair na quarta, antecipa.                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000013"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				nDiaSem := Dow(E1_VENCTO)

				If nDiaSem < 3
					nDiaCerto := 3-nDiaSem
				Elseif nDiaSem == 4
					nDiaCerto := -1
				Elseif nDiaSem >= 5
					nDiaCerto := 10-nDiaSem
				Else
					nDiaCerto := 0
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	E1_VENCTO+nDiaCerto
	  			  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo
		//зддддддддддддддддддд©
		//Ё Danone            Ё
		//Ё                   +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que dias 10, 20 ou 01           Ё
		//Ё                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000035"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_VENCTO) >= 1 .and. Day(E1_VENCTO) <= 10
					cDiaCerto := "10"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 10 .and. Day(E1_VENCTO) <= 20
					cDiaCerto := "20"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 20
					cDiaCerto := "01"
					cMesCerto := StrZero(Month(E1_VENCTO)+1,2)
					cAnoCerto := StrZero(Year(E1_VENCTO),4)
					If cMesCerto = "13"
						cMesCerto := "01"
						cAnoCerto := StrZero(Year(E1_VENCTO)+1,4)
					Endif
					cDiaCerto := cDiaCerto+"/"+cMesCerto+"/"+cAnoCerto
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo

		//зддддддддддддддддддд©
		//Ё Iracema           Ё
		//Ё                   +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair toda terca (e nao ante-Ё
		//Ё cipa se cair na quarta-feira)                   Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000215"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				nDiaSem := Dow(E1_VENCTO)

				If nDiaSem < 3
					nDiaCerto := 3-nDiaSem
				Elseif nDiaSem >= 4
					nDiaCerto := 10-nDiaSem
				Else
					nDiaCerto := 0
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	E1_VENCTO+nDiaCerto
	  			  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo
		//зддддддддддддддддддддддд©
		//Ё Empresa Brasileira de Ё
		//Ё Bebidas.              +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair dias 05, 10, 15, 20, 25 ou Ё
		//Ё 30.                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000352"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_VENCTO) >= 1 .and. Day(E1_VENCTO) <= 5
					cDiaCerto := "05"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 11 .and. Day(E1_VENCTO) <= 15
					cDiaCerto := "15"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 16 .and. Day(E1_VENCTO) <= 20
					cDiaCerto := "20"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 21 .and. Day(E1_VENCTO) <= 25
					cDiaCerto := "25"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 25
					cDiaCerto := DtoC(LastDay(E1_VENCTO))
				Else
					cDiaCerto := DtoC(E1_VENCTO)
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
	  			  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo
		//зддддддддддддддддддддддд©
		//Ё Danisco               Ё
		//Ё                       +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair toda quinta-feira (e nao   Ё
		//Ё antecipa)                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000362"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				nDiaSem := Dow(E1_VENCTO)

				If nDiaSem < 5
					nDiaCerto := 5-nDiaSem
				Elseif nDiaSem == 6
					nDiaCerto := 6
				Else
					nDiaCerto := 0
				Endif

	            RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	E1_VENCTO+nDiaCerto
	  			  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
	            MsUnlock()
				dbCommit()

	            dbSkip()

			Enddo
		//зддддддддддддддддддддддд©
		//Ё Minerva               Ё
		//Ё                       +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair toda quarta-feira (e nao   Ё
		//Ё antecipa)                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000477"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				nDiaSem := Dow(E1_VENCTO)

				If nDiaSem < 4
					nDiaCerto := 4-nDiaSem
				Elseif nDiaSem == 5
					nDiaCerto := 6
				Elseif nDiaSem == 6
					nDiaCerto := 5
				Else
					nDiaCerto := 0
				Endif

	            RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	E1_VENCTO+nDiaCerto
	  			  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
	            MsUnlock()
				dbCommit()

	            dbSkip()

			Enddo
		//зддддддддддддддддддд©
		//Ё Bimbo             Ё
		//Ё                   +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair nos dias 15 ou 30      Ё
		//Ё                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000009"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_VENCTO) >= 1 .and. Day(E1_VENCTO) <= 15
					cDiaCerto := "15"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 16
					cDiaCerto := DtoC(LastDay(E1_VENCTO))
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo
		//зддддддддддддддддддд©
		//Ё Fischer           Ё
		//Ё                   +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que dias 10, 20 ou 30           Ё
		//Ё                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000205"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_VENCTO) >= 1 .and. Day(E1_VENCTO) <= 10
					cDiaCerto := "10"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 11 .and. Day(E1_VENCTO) <= 20
					cDiaCerto := "20"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 20
					cDiaCerto := DtoC(LastDay(E1_VENCTO))
				Else
					cDiaCerto := DtoC(E1_VENCTO)
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo
		//зддддддддддддддддддд©
		//Ё Proteste          Ё
		//Ё                   +дддддддддддддддддддддддддддддддддддддддд©
		//Ё Se Vencto cair de  1 a  7 mudar para dia 30 do mesmo mes.  Ё
		//Ё Se Vencto cair de  8 a 21 mudar para dia 15 mes seguinte.  Ё
		//Ё Se Vencto cair de 22 a 30 mudar para dia 30 mes seguinte.  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->(F2_CLIENTE+F2_LOJA) == "00041601"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_VENCTO) >= 1 .and. Day(E1_VENCTO) <= 7
					If Month(E1_VENCTO) == 2
						cDiaCerto := DtoC(LastDay(E1_VENCTO))
					Else
						cDiaCerto := "30"+Substr(DtoC(E1_VENCTO),3)
					Endif
				ElseIf Day(E1_VENCTO) >= 8 .and. Day(E1_VENCTO) <= 21
					cDiaCerto := "15"
					nMesCerto := Month(E1_VENCTO)+1
					nAnoCerto := Year(E1_VENCTO)
					If nMesCerto > 12
						nAnoCerto++
						nMesCerto := 1
					Endif
					cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
				ElseIf Day(E1_VENCTO) >= 22 .and. Day(E1_VENCTO) <= 31
					cDiaCerto := "30"
					nMesCerto := Month(E1_VENCTO)+1
					nAnoCerto := Year(E1_VENCTO)
	                If nMesCerto == 2
						cDiaCerto := Substr(DtoC(LastDay(E1_VENCTO)),1,2)
					ElseIf nMesCerto > 12
						nAnoCerto++
						nMesCerto := 1
					Endif
					cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
				Else
					cDiaCerto := DtoC(E1_VENCTO)
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo
		//зддддддддддддддддддд©
		//Ё LioTecnica        Ё
		//Ё                   +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair nos dias 05, 10 ou 25  Ё
		//Ё                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->(F2_CLIENTE+F2_LOJA) == "00008602"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_VENCTO) >= 1 .and. Day(E1_VENCTO) <= 5
					cDiaCerto := "05"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 6 .and. Day(E1_VENCTO) <= 10
					cDiaCerto := "10"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 11 .and. Day(E1_VENCTO) <= 25
					cDiaCerto := "25"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 26
					cDiaCerto := "05"
					nMesCerto := Month(E1_VENCTO)+1
					nAnoCerto := Year(E1_VENCTO)
					If nMesCerto > 12
						nAnoCerto++
						nMesCerto := 1
					Endif
					cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
				Else
					cDiaCerto := DtoC(E1_VENCTO)
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo
		//зддддддддддддддддддд©
		//Ё M Dias Branco     Ё
		//Ё                   +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair em multiplos de 5.     Ё
		//Ё 05,10,15,20,25 ou 30                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf (SF2->F2_CLIENTE=="000180" .or. SF2->F2_CLIENTE=="001371" .or. SF2->F2_CLIENTE=="001467")

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_VENCTO) >= 1 .and. Day(E1_VENCTO) <= 5
					cDiaCerto := "05"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 6 .and. Day(E1_VENCTO) <= 10
					cDiaCerto := "10"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 11 .and. Day(E1_VENCTO) <= 15
					cDiaCerto := "15"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 16 .and. Day(E1_VENCTO) <= 20
					cDiaCerto := "20"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 21 .and. Day(E1_VENCTO) <= 25
					cDiaCerto := "25"+Substr(DtoC(E1_VENCTO),3)
				ElseIf Day(E1_VENCTO) >= 26
					If Month(E1_VENCTO) == 2
						cDiaCerto := "05"
						nMesCerto := Month(E1_VENCTO)+1
						nAnoCerto := Year(E1_VENCTO)
						cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
					Else
						cDiaCerto := "30"+Substr(DtoC(E1_VENCTO),3)
					Endif
				Else
					cDiaCerto := DtoC(E1_VENCTO)
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo

		//зддддддддддддддддддд©
		//Ё Suco Cutrale      Ё
		//Ё                   +дддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se faturamento for feito de 1 a 20 mudar para dia 05 do mes seguinte.      Ё
		//Ё Se faturamento for feito de 21 a 31 mudar para dia 05 do mes seguinte+1.   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "000329"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_EMISSAO) >= 1 .and. Day(E1_EMISSAO) <= 20
					cDiaCerto := "05"
					nMesCerto := Month(E1_EMISSAO)+1
					nAnoCerto := Year(E1_EMISSAO)
					If nMesCerto > 12
						nAnoCerto++
						nMesCerto:=1
					Endif
					cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
				Else
					cDiaCerto := "05"
					nMesCerto := Month(E1_EMISSAO)+2
					nAnoCerto := Year(E1_EMISSAO)
					If nMesCerto > 12
						nAnoCerto++
						nMesCerto:=1
					Endif
					cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo

		//зддддддддддддддддддд©
		//Ё Cervejaria Kaiser Ё
		//Ё                   +дддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se faturamento for feito de 1 a 6 mudar para dia 16 .                      Ё
		//Ё Se faturamento for feito de 7 a 16 mudar para dia 26                       Ё
		//Ё Se faturamento for feito de 17 a 31 mudar para dia 6 do mes seguinte       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf (SF2->F2_CLIENTE == "001117" .or. SF2->F2_CLIENTE == "002260")

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(E1_EMISSAO) >= 1 .and. Day(E1_EMISSAO) <= 6
					cDiaCerto := "16"
					nMesCerto := Month(E1_EMISSAO)
					nAnoCerto := Year(E1_EMISSAO)
					cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
				ElseIf Day(E1_EMISSAO) >= 7 .and. Day(E1_EMISSAO) <= 16
					cDiaCerto := "26"
					nMesCerto := Month(E1_EMISSAO)
					nAnoCerto := Year(E1_EMISSAO)
					cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
				ElseIf Day(E1_EMISSAO) >= 17 .and. Day(E1_EMISSAO) <= 31
					cDiaCerto := "06"
					nMesCerto := Month(E1_EMISSAO)+1
					nAnoCerto := Year(E1_EMISSAO)
					If nMesCerto > 12
						nAnoCerto++
						nMesCerto:=1
					Endif
					cDiaCerto := cDiaCerto+"/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4)
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo

		//зддддддддддддддддддд©
		//Ё Carrefour         Ё
		//Ё                   +дддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Comecar a contar os vencimentos apos 20 dias da emissao da nota.           Ё
		//Ё Se o vencimento cair de 01 a 10 mudar para dia 10                          Ё
		//Ё Se o vencimento cair de 11 a 20 mudar para dia 20                          Ё
		//Ё Se o vencimento cair de 21 a 31 mudar para O ultimo dia do mes             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf lCarrefour

			dVencto := SE1->E1_EMISSAO+20

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				If Day(dVencto) >= 1 .and. Day(dVencto) <= 10
					cDiaCerto := "10"+Substr(DtoC(dVencto),3)
				ElseIf Day(dVencto) >= 11 .and. Day(dVencto) <= 20
					cDiaCerto := "20"+Substr(DtoC(dVencto),3)
				ElseIf Day(dVencto) >= 21
					cDiaCerto := DtoC(LastDay(dVencto))
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	CtoD(cDiaCerto)
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo

		//зддддддддддддддддддддддд©
		//Ё Nutribras             Ё
		//Ё                       +ддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair toda sexta-feira           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "002862"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				nDiaSem := Dow(E1_VENCTO)

				If nDiaSem <= 6
					nDiaCerto := 6-nDiaSem
				Else
					nDiaCerto := 6
				Endif

	            RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	E1_VENCTO+nDiaCerto
	  			  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
	            MsUnlock()
				dbCommit()

	            dbSkip()

			Enddo
		//зддддддддддддддддддддддддд©
		//Ё Industria de Sorvetes   Ё
		//Ё Zeca's Sorvetes         Ё
		//Ё                         +ддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair toda terca-feira ou    Ё
		//Ё quinta-feira.                                   Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE == "003285"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				nDiaSem := Dow(E1_VENCTO)

				If nDiaSem < 3
					nDiaCerto := 3-nDiaSem
				Elseif nDiaSem < 5
					nDiaCerto := 5-nDiaSem
				Elseif nDiaSem == 6
					nDiaCerto := 4
				Elseif nDiaSem == 7
					nDiaCerto := 3
				Else
					nDiaCerto := 0
				Endif

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	E1_VENCTO+nDiaCerto
	  			  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo

   		//зддддддддддддддддддд©
		//Ё Mondelez          Ё
		//Ё                   +дддддддддддддддддддддддддддддддддд©
		//Ё Vencimentos tem que cair no 2o dia util do mes sendo Ё
		//Ё que o prazo inicial eh de 15 dias apos a emissao.    Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf SF2->F2_CLIENTE $ "000082#001384"

			While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)

				nMesCerto := Month(SF2->F2_EMISSAO)+1
				nAnoCerto := Year(SF2->F2_EMISSAO)
				dDiaCerto := CtoD(Space(8))

				If nMesCerto > 12
					nMesCerto := 1
					nAnoCerto++
				Endif
				dDiaCerto := CtoD("01/"+StrZero(nMesCerto,2)+"/"+StrZero(nAnoCerto,4))
				dDiaCerto := DataValida(dDiaCerto,.T.)
				dDiaCerto := dDiaCerto + 1
				dDiaCerto := DataValida(dDiaCerto,.T.)

				RecLock("SE1",.F.)
				  Replace	E1_VENCTO	With	dDiaCerto
				  Replace	E1_VENCREA	With	DataValida(E1_VENCTO,.T.)
				MsUnlock()
				dbCommit()
				dbSkip()

			Enddo

	    Endif

	Endif

	RestArea(aAreaSE1)

	//Usuaria Agata Gomes informou que o desvio abaixo nЦo serА mais utilizado.
	/*
	//зддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se o cliente estiver identificado que trata-se  Ё
	//Ё de uma empresa coligada do Grupo Pao de Acucar, Ё
	//Ё atualizo o campo no titulo a receber com essa   Ё
	//Ё informacao para permitir filtro em relatorios.  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддды
	If SF2->F2_TIPO == "N" .and.;
	     Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_X_GPA")="S" .and.;
	      dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC))

		While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM ==;
					SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
			RecLock("SE1",.F.)
			  Replace	E1_X_GPA	With	"S"
			MsUnlock()
			dbCommit()
			dbSkip()
		Enddo
	Endif

Endif
*/

//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualizacao do campo FT_ZZCC que devera guardar Ё
//Ё o centro de custo da tabela SD2 que foi gravado Ё
//Ё pelo ponto de entrada SF2460I.                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("SD2")
dbSetOrder(3)
dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
While !Eof() .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

	dbSelectArea("SFT")
	dbSetOrder(1)
	If dbSeek(xFilial("SFT")+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+PADR(D2_ITEM,4)+D2_COD))
		RecLock("SFT",.F.)
		  FT_CONTA := SD2->D2_CONTA
		  FT_ZZCC  := SD2->D2_ZZCC
		MsUnlock()
	Endif
	dbSelectArea("SD2")
	dbSkip()

Enddo

dbSelectArea("SF2")


//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento ao PIS/COFINS/CSLL                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды
//DESATIVADO CONFORME DESCRITO NO CABEC

/*
dbSelectArea("SE1")
aAreaSE1 := GetArea()
dbSetOrder(2)  // Filial+Cliente+Loja+Prefixo+No. Titulo+Parcela+Tipo
If dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC))
	While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
		If E1_TIPO == "NF "
			cNaturez := SE1->E1_NATUREZ
		Endif
		dbSkip()
	Enddo
Endif

If !Empty(cNaturez) .and. SF2->F2_BASEISS > 0
	SED->(dbSetOrder(1))
	SED->(dbSeek(xFilial("SED")+cNaturez))
	dbSelectArea("SF2")
    RecLock("SF2",.F.)
      F2_VALPIS  := Round(F2_BASPIS  * (SED->ED_PERCPIS/100) , 2)
      F2_VALCOFI := Round(F2_BASCOFI * (SED->ED_PERCCOF/100) , 2)
      F2_VALCSLL := Round(F2_BASCSLL * (SED->ED_PERCCSL/100) , 2)
    MsUnlock()
    dbCommit()

	dbSelectArea("SFT")
	aAreaSFT := GetArea()
	dbSelectArea("SD2")
	aAreaSD2 := GetArea()
	dbSetOrder(3)
	dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.T.)
	While !Eof() .and. D2_FILIAL==xFilial("SD2") .and. D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		RecLock("SD2",.F.)
      	  D2_VALPIS := Round(D2_BASEPIS  * (D2_ALQPIS/100) , 2)
      	  D2_VALCOF := Round(D2_BASECOFI * (D2_ALQCOF/100) , 2)
      	  D2_VALCSL := Round(D2_BASECSLL * (D2_ALQCSL/100) , 2)
    	MsUnlock()
    	dbCommit()

		dbSelectArea("SFT")
		dbSetOrder(1)
		If dbSeek(xFilial("SFT")+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+PADR(D2_ITEM,4)+D2_COD))
			RecLock("SFT",.F.)
			  FT_VRETPIS := SD2->D2_VALPIS
			  FT_VRETCOF := SD2->D2_VALCOF
			  FT_VRETCSL := SD2->D2_VALCSL
			MsUnlock()
		Endif

		dbSelectArea("SD2")
		dbSkip()
	Enddo

	RestArea(aAreaSFT)
	RestArea(aAreaSD2)

	dbSelectArea("SE1")
	dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC))
	While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
		If E1_TIPO == "NF "
			RecLock("SE1",.F.)
			  E1_PIS    := SF2->F2_VALPIS
			  E1_COFINS := SF2->F2_VALCOFI
			  E1_CSLL   := SF2->F2_VALCSLL
			  If E1_SABTPIS > 0
	  			  E1_SABTPIS := SF2->F2_VALPIS
				  E1_SABTCOF := SF2->F2_VALCOFI
				  E1_SABTCSL := SF2->F2_VALCSLL
			  Endif
			MsUnlock()
			dbCommit()
		Endif
		If E1_TIPO == "PI-"
			RecLock("SE1",.F.)
		  	  E1_VALOR  := SF2->F2_VALPIS
			  E1_SALDO  := SF2->F2_VALPIS
			  E1_VLCRUZ := SF2->F2_VALPIS
			MsUnlock()
			dbCommit()
		Endif
		If E1_TIPO == "CF-"
			RecLock("SE1",.F.)
		  	  E1_VALOR  := SF2->F2_VALCOFI
			  E1_SALDO  := SF2->F2_VALCOFI
			  E1_VLCRUZ := SF2->F2_VALCOFI
			MsUnlock()
			dbCommit()
		Endif
		If E1_TIPO == "CS-"
			RecLock("SE1",.F.)
		  	  E1_VALOR  := SF2->F2_VALCSLL
			  E1_SALDO  := SF2->F2_VALCSLL
			  E1_VLCRUZ := SF2->F2_VALCSLL
			MsUnlock()
			dbCommit()
		Endif
		dbSkip()
	Enddo

Endif

RestArea(aAreaSE1)

*/

//If SM0->M0_CODIGO == '05' // Anatech
//If Substr(SM0->M0_CODFIL,1,2) == '05' // Anatech
//Retirada a geraГЦo do XML para o Mylins desse fonte e passado para o fonte F022ATUNF, pois agora serА gerado o XML depois da nota fiscal autorizada, com isso podemos ter o nЗmero da NFSE (da prefeitura) em vez do RPS
//Retirado a pedido da Renata Pereira em 14/08/2024
//RИgis Ferreira - 14/08/2024
/*If Substr(SM0->M0_CODFIL,1,4) $ '0500|0501|0502|0503|0802|0602|0603|0604' // Anatech ou ASL

	// Gerar XML que sera usado pelo MyLims
	aPeds := {}
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.T.)
	While !Eof() .and. D2_FILIAL==xFilial("SD2") .and. D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
			If Substr(SC5->C5_ZZCODIN,At("-",SC5->C5_ZZCODIN)+1,1) == '0'		// 0=Envia Retorno 1=Nao Envia Retorno
				If aScan(aPeds , {|x| X[1] == SD2->D2_PEDIDO}) == 0
					aadd(aPeds , {SD2->D2_PEDIDO,Substr(SC5->C5_ZZCODIN,1,At("-",SC5->C5_ZZCODIN)-1),SD2->D2_DOC,SD2->D2_EMISSAO})
				Endif
			Endif
		Endif
		dbSelectArea("SD2")
		dbSkip()
	Enddo

	For nP:=1 to Len(aPeds)

		//cError   := ''
		//cWarning := ''
		//oXML     := Nil
		//Gera o Objeto XML ref. ao script
		//oXML := XmlParser( GeraXML(aPeds[nP]), "_", @cError, @cWarning )
		// Tranforma o Objeto XML em arquivo
		//SAVE oXML XMLFILE cPath+aPeds[nP][1]+".xml"

		cXML := GeraXML(aPeds[nP])
		nXMLFile := FCreate(cPath+aPeds[nP][1]+".xml",0,,.F.)
		If nXMLFile > 0
			FWrite( nXMLFile,cXML )
		Else
			MsgAlert("NЦo foi possМvel gravar o XML no local indicado.")
			lGravado	:= .F.
		EndIf
		FClose( nXMLFile )

	Next

Endif*/

/*
//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento ao IR - Fausto Costa 02/06/2015      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды
aAreaSE1IR := SE1->(GetArea())

DbSelectArea("SE1")
SE1->(DbGoTop())
SE1->(DbSetOrder(1))  // Filial + Prefixo + No. Titulo + Parcela + Tipo
If SE1->(DbSeek(xFilial("SE1")+SF2->(F2_SERIE+F2_DOC+" NF ")))
	lIRRFOK := .T.
ElseIf SE1->(DbSeek(xFilial("SE1")+SF2->(F2_SERIE+F2_DOC+"ANF ")))
	lIRRFOK := .T.
EndIf

If lIRRFOK
	aAreaSEDIR := SED->(GetArea())
	DbSelectArea("SED")
	SED->(DbSetOrder(1))  // Filial + Codigo
	If SED->(DbSeek(xFilial("SED")+SE1->E1_NATUREZ))
		nPercIRRF := SED->ED_PERCIRF
	EndIf
	RestArea(aAreaSEDIR)


	If SE1->E1_VRETIRF > 0 .AND.  SE1->E1_IRRF == 0
		RecLock("SE1",.F.)
			SE1->E1_VRETIRF := Round(SF2->F2_VALBRUT*(nPercIRRF/100),2)
		MsUnlock()
		dbCommit()

	ElseIf SE1->E1_VRETIRF > 0 .AND.  SE1->E1_IRRF > 0 .AND. SE1->E1_IRRF == SE1->E1_VRETIRF
		RecLock("SE1",.F.)
			SE1->E1_VRETIRF := Round(SF2->F2_VALBRUT*(nPercIRRF/100),2)
			SE1->E1_IRRF := SE1->E1_VRETIRF
		MsUnlock()
		dbCommit()
		aadd(aChvSE1IR, {SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)+"IR-", SE1->E1_IRRF})

	ElseIf SE1->E1_VRETIRF > 0 .AND.  SE1->E1_IRRF > 0 .AND. SE1->E1_IRRF <> SE1->E1_VRETIRF
		nIRRFAux := SE1->(E1_IRRF - E1_VRETIRF)
		RecLock("SE1",.F.)
			SE1->E1_VRETIRF := Round(SF2->F2_VALBRUT*(nPercIRRF/100),2)
			SE1->E1_IRRF := SE1->E1_VRETIRF + nIRRFAux
		MsUnlock()
		dbCommit()
		aadd(aChvSE1IR, {SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)+"IR-", SE1->E1_IRRF})

	EndIf

	For nP:=1 to Len(aChvSE1IR)
		If SE1->(DbSeek(xFilial("SE1")+aChvSE1IR[nP,1]))
			RecLock("SE1",.F.)
				SE1->E1_VALOR  := aChvSE1IR[nP,2]
				SE1->E1_SALDO  := aChvSE1IR[nP,2]
				SE1->E1_VLCRUZ := aChvSE1IR[nP,2]
			MsUnlock()
			dbCommit()
		Endif
	Next

EndIF

If nPercIRRF > 0
	dbSelectArea("SF2")
	RecLock("SF2",.F.)
		SF2->F2_VALIRRF  := Round(SF2->F2_VALBRUT * (nPercIRRF/100),2)
	MsUnlock()
	dbCommit()
EndIf

RestArea(aAreaSE1IR)
// Fim Tratamento ao IR - Fausto Costa 02/06/2015
//FIM DO DESATIVADO CONFORME CABEC
*/

/*Retirado para que a Agata Gomes possa efetuar um teste e verificar se o os impostos estЦo batendo.
//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cliente Hospital Santa Marcelina - 003970/01    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды
If SF2->F2_TIPO=='N' .and. SF2->F2_CLIENTE=='003970' .and. SM0->M0_CODIGO == '01' // Eurofins

	aChaveSE1:={}

	dbSelectArea("SE1")
	aAreaSE12 := GetArea()
	dbSetOrder(2)  // Filial+Cliente+Loja+Prefixo+No. Titulo+Parcela+Tipo
	If dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC))
		While !Eof() .and. E1_MSFIL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
			// Atualizo o valor dos impostos do titulo principal
			If E1_TIPO == "NF "
				RecLock("SE1",.F.)
				  E1_PIS    := Round(E1_VALOR * 0.0065,2)
				  E1_COFINS := Round(E1_VALOR * 0.03,2)
				  E1_CSLL   := Round(E1_VALOR * 0.01,2)
				  If E1_SABTPIS > 0
				  	E1_SABTPIS := E1_PIS
				  Endif
				  If E1_SABTCOF > 0
				  	E1_SABTCOF := E1_COFINS
				  Endif
				  If E1_SABTCSL > 0
				  	E1_SABTCSL := E1_CSLL
				  Endif
				MsUnlock()
				dbCommit()
				aadd(aChaveSE1 , {E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+"PI-" , E1_PIS}    )
				aadd(aChaveSE1 , {E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+"CF-" , E1_COFINS} )
				aadd(aChaveSE1 , {E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+"CS-" , E1_CSLL}   )
			Endif
			dbSkip()
		Enddo

   		// Atualizo os registros dos impostos
   		For nP:=1 to Len(aChaveSE1)
   			If dbSeek(xFilial("SE1")+aChaveSE1[nP,1])
   				RecLock("SE1",.F.)
				  E1_VALOR  := aChaveSE1[nP,2]
				  E1_SALDO  := aChaveSE1[nP,2]
				  E1_VLCRUZ := aChaveSE1[nP,2]
				MsUnlock()
   				dbCommit()
   			Endif
   		Next

   	Endif

	RestArea(aAreaSE12)

Endif
*/


&& Atualiza tabela CDL - Complemento de exportacao
If Alltrim(SF2->F2_EST) == "EX" .and. Alltrim(SF2->F2_ESPECIE) == 'SPED'
	updCDL()
EndIf


RestArea(aAreaAtual)

Return


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁM460FIM   ╨Autor  ЁMicrosiga           ╨ Data Ё  04/10/15   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function GeraXML(aInfo)

Local cScript := ''
Local cNumPed := aInfo[1]
Local cNumInv := aInfo[2]
Local cNumNF  := aInfo[3]
Local dDtNF   := aInfo[4]

cScript += '<?xml version="1.0" encoding="ISO-8859-1"?>'+ENTER
cScript += '<DADOS>'+ENTER
cScript += '  <INVOICE>'+ENTER
cScript += '    <CDINVOICE>'+cNumInv+'</CDINVOICE>'+ENTER
cScript += '    <STATUS>Sucesso</STATUS>'+ENTER
cScript += '    <MENSAGEM>NF '+cNumNF+'  '+DtoC(dDtNF)+'</MENSAGEM>'+ENTER
cScript += '    <NRPEDIDOVENDA>'+cNumPed+'</NRPEDIDOVENDA>'+ENTER
cScript += '  </INVOICE>'+ENTER
cScript += '</DADOS>'+ENTER

Return cScript




Static Function updCDL()
	Local aArea    	:= GetArea()
	Local aAreaSD2  := SD2->(GetArea())
	Local aAreaCDL  := CDL->(GetArea())

	dbSelectArea("CDL")
	dbsetorder(1)
	dbseek( xFilial("CDL") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))

	While CDL->(!Eof()) .AND. CDL->(CDL_DOC+CDL_SERIE+CDL_FORNEC+CDL_LOJA) == SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

		RecLock("CDL",.F.)
        	CDL->(dbDelete())
  		CDL->(MsUnlock("CDL"))

		CDL->(dbSkip())

	EndDo

	dbSelectArea("SD2")
	dbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	dbSeek(xFilial("SD2")+ SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
	While SD2->(!Eof()) .AND. SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
		//cria os CDL
		RecLock("CDL", .T.)
			CDL->CDL_FILIAL  :=  xFilial("CDL")
			CDL->CDL_DOC     :=  SF2->F2_DOC
			CDL->CDL_SERIE   :=  SF2->F2_SERIE
			CDL->CDL_ESPEC   :=  SF2->F2_ESPECIE
			CDL->CDL_CLIENT  :=  SF2->F2_CLIENTE
			CDL->CDL_LOJA    :=  SF2->F2_LOJA
			CDL->CDL_ITEMNF  :=  SD2->D2_ITEM
			CDL->CDL_PRODNF  :=  SD2->D2_COD
			CDL->CDL_UFEMB   :=  SM0->M0_ESTENT
			CDL->CDL_LOCEMB  :=  SM0->M0_CIDENT
			CDL->(MsUnlock("CDL"))
		SD2->(DbSkip())
	EndDo

  	CDL->(RestArea(aAreaCDL))
  	SD2->(RestArea(aAreaSD2))
  	RestArea(aArea)
Return
