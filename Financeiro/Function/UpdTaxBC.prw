#include 'totvs.ch'
#include "tbiconn.ch"
#include 'protheus.ch'

/*/{Protheus.doc} UpdTaxBC
Realizar atualização da moeda de acordo com o banco central
@type function
@version 12.1.27
@author Leandro Cesar
@since 16/05/2022
/*/


Static lExecJob := IsBlind()

user function UpdTaxBC()
	Private lAuto := .F.
	Private dDataRef, dData
	Private nValDolar, nValEuro
	Private nValReal              := 1.000000
	Private nValATF              := 0.8287
	Private cNotFound := '<?xml version="1.0" encoding="pt-br"?>'
	Private aMoeda := array(24)

	aEval(aMoeda,{|z| z := 0 })

	If  lExecJob
		RPCSetType( 3 )
		RpcSetEnv('01','01',,,,GetEnvServer(),{ "SM2" })
		sleep( 5000 )
		ConOut('Atualizando Moedas... '+Dtoc(DATE())+' - '+Time())
		lAuto := .T.
	EndIf

	If ( ! lAuto )
		If MsgYesNo("Confirma processamento de atualização cadastro de moeda para a data [" + cValToChar(dDataBase) + "]?","Aviso")
			LjMsgRun(OemToAnsi('Atualização On-line BCB'),,{|| xExecMoeda()} )
			FWAlertSuccess("Atualização finalizada.","Aviso")
		EndIf
	Else
		xExecMoeda()
	EndIf

	If ( lAuto )
		RpcClearEnv()                                                                                  //Libera o Environment
		ConOut('Moedas Atualizadas. '+Dtoc(DATE())+' - '+Time())
	EndIf

Return
//--------------------------------------------------------------------------
Static Function xExecMoeda()
	Local nPass   as numeric
	local cFile   as character
	local cTexto  as character
	local nLinhas as numeric
	local cLinha  as character
	local nX      as numeric

	For nPass := 1 to 1 step -1     //Refaz os ultimos 6 dias. O BCB não disponibiliza periodo maior de uma semana
		dDataRef := dDataBase - nPass

		If dDataRef == dDataBase
			exit
		EndIf

		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5")+"63001")
			While SX5->(!EOF()) .and. SX5->X5_TABELA == '63'
				If SX5->X5_TABELA == '63'
					If strZero(Day(dDataRef),2)+'/'+strZero(month(dDataRef),2) == Substring(SX5->X5_DESCRI,1,5) //cadastro de feriado do protheus tabela 63 SX5
						cFile := Dtos(dDataRef - 1)+'.csv'
					ElseIf     Dow(dDataRef) == 1 //Se for domingo
						cFile := Dtos(dDataRef - 2)+'.csv'
					ElseIf     Dow(dDataRef) == 7 //Se for sabado
						cFile := Dtos(dDataRef - 1)+'.csv'//Dias Normais
					Else //Se for dia normal
						cFile := Dtos(dDataRef)+'.csv'
					EndIf

				EndIf
				SX5->(dbSkip())
			EndDo
		Else
			If Dow(dDataRef) == 1                 //Se for domingo
				cFile := Dtos(dDataRef - 2)+'.csv'
			ElseIf     Dow(dDataRef) == 7         //Se for sabado
				cFile := Dtos(dDataRef - 1)+'.csv'//Dias Normais
			Else         //Se for dia normal
				cFile := Dtos(dDataRef)+'.csv'
			EndIf
		EndIf

		cTexto  := HttpGet('http://www4.bcb.gov.br/Download/fechamento/'+cFile)

		cTexto  := StrTran(cTexto, Chr(10), Chr(13)+Chr(10))

		If ( lAuto )
			ConOut('DownLoading from BCB '+cFile+' In '+Dtoc(DATE()))
		EndIf

		If !cNotFound $ Memoline(cTexto,,1)
			If ! Empty(cTexto)
				nLinhas := MLCount(cTexto)
				aLinha := {}
				For nX := 1 to nLinhas
					cLinha := Memoline(cTexto,,nX)
					aLinha := strToKarr(cLinha,";")
					dData  := dDataBase

					If nX == 1
						dbSelectArea("SM2")
						SM2->(dbSetorder(1))
						If SM2->(dbSeek(dTos(dData)))
							Reclock('SM2',.F.)
						Else
							Reclock('SM2',.T.)
						EndIf
						SM2->M2_DATA    := dData
						SM2->M2_MOEDA1  := nValReal             //Real
						SM2->M2_MOEDA3  := nValATF              //Ativo Fixo
						SM2->M2_INFORM  := "S"
					Endif

					//Grava Moedas


					If SM2->(FieldPos("M2_MOEDA2")) > 0 .and. SM2->(FieldPos("M2_MOEDA4")) > 0
						If aLinha[2] == '220' //DOLAR (DOLAR DOS EUA)
							SM2->M2_MOEDA2      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA2")[2])       //venda
							SM2->M2_MOEDA4      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA4")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA5")) > 0 .and. SM2->(FieldPos("M2_MOEDA6")) > 0
						If aLinha[2] == '978' //EURO (EURO)
							SM2->M2_MOEDA5      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA5")[2])       //venda
							SM2->M2_MOEDA6      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA6")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA7")) > 0 .and. SM2->(FieldPos("M2_MOEDA8")) > 0
						If aLinha[2] == '715' //PESO CHILENO (PESO CHILE)
							SM2->M2_MOEDA7      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA7")[2])       //venda
							SM2->M2_MOEDA8      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA8")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA9")) > 0 .and. SM2->(FieldPos("M2_MOEDA10")) > 0
						If aLinha[2] == '540' //LIBRA (LIBRA ESTERLINA)
							SM2->M2_MOEDA9      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA9")[2])       //venda
							SM2->M2_MOEDA10     := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA10")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA11")) > 0 .and. SM2->(FieldPos("M2_MOEDA12")) > 0
						If aLinha[2] == '070' //COROA (COROA SUECA)
							SM2->M2_MOEDA11      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA11")[2])       //venda
							SM2->M2_MOEDA12      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA12")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA13")) > 0 .and. SM2->(FieldPos("M2_MOEDA14")) > 0
						If aLinha[2] == '165' //DOLAR  CAN (DOLAR CANADENSE)
							SM2->M2_MOEDA13      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA13")[2])       //venda
							SM2->M2_MOEDA14      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA14")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA15")) > 0 .and. SM2->(FieldPos("M2_MOEDA16")) > 0
						If aLinha[2] == '065' //COROA (COROA NORUEGUESA)
							SM2->M2_MOEDA15      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA15")[2])       //venda
							SM2->M2_MOEDA16      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA16")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA17")) > 0 .and. SM2->(FieldPos("M2_MOEDA18")) > 0
						If aLinha[2] == '425' //FRAN SUI (FRANCO SUICO)
							SM2->M2_MOEDA17      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA18")[2])       //venda
							SM2->M2_MOEDA18      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA17")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA20")) > 0 .and. SM2->(FieldPos("M2_MOEDA19")) > 0
						If aLinha[2] == '055' //COROA DIN (COROA DINAMARQUESA)
							SM2->M2_MOEDA20      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA20")[2])       //venda
							SM2->M2_MOEDA19      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA19")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA22")) > 0 .and. SM2->(FieldPos("M2_MOEDA21")) > 0
						If aLinha[2] == '245' //DOLAR NZD ( DOLAR NOVA ZELANDIA)
							SM2->M2_MOEDA22      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA25")[2])       //venda
							SM2->M2_MOEDA21      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA26")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA24")) > 0 .and. SM2->(FieldPos("M2_MOEDA23")) > 0
						If aLinha[2] == '706' //PESO ARG ( PESO ARGENTINO)
							SM2->M2_MOEDA24      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA23")[2])       //venda
							SM2->M2_MOEDA23      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA24")[2])       //compra
						EndIf
					EndIf

					If SM2->(FieldPos("M2_MOEDA26")) > 0 .and. SM2->(FieldPos("M2_MOEDA25")) > 0
						If aLinha[2] == '150' //DOLAR AUD ( DOLAR AUSTRALIANO)
							SM2->M2_MOEDA26      := Round(xConvVlr(aLinha[6]),TamSx3("M2_MOEDA22")[2])       //venda
							SM2->M2_MOEDA25      := Round(xConvVlr(aLinha[5]),TamSx3("M2_MOEDA26")[2])       //compra
						EndIf
					ENdIf

					If nX == nLinhas
						SM2->(MsUnlock())
					EndIf
				Next nX
			Endif
		EndIf
	Next

Return
//------------------------------------------------------------------------------------------------------------------------------------------------------------
static function xConvVlr(np_Valor)
return(val(strTran(strtran(np_Valor,'.',''),',','.')))
