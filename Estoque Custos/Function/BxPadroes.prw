#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BxPadroes ºAutor  ³ Marcos Candido    º Data ³  11/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que ira realizar a inclusao de movimentos internos  º±±
±±º          ³ de requisicao dos produtos cadastrados nas tabelas SZD e   º±±
±±º          ³ SZE.                                                       º±±
±±º          ³ Processo automatico de Diferimento (baixa)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//User Function BxPadroes(aParam)
/*/{Protheus.doc} BxPadroes
Inclusao de movimentos internos de requisicao dos produtos cadastrados nas tabelas SZD e SZE. Processo automatico de Diferimento (baixa)
@author Marcos Candido
@since 02/01/2018
/*/
User Function BxPadroes

If IW_MsgBox(OemToAnsi("Confirma o processamento da rotina de Diferimento de Padrões ?"), OemToAnsi("Informação") , "YESNO")
	Processa({|| RunOk() },OemToAnsi("Diferimento de Padrões"))
Else
	IW_MsgBox(OemToAnsi("Processamento Cancelado."), OemToAnsi("Informação") , "ALERT")
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BXPADROES ºAutor  ³Microsiga           º Data ³  05/09/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunOk

Local cQuery  := ""
Local cStatus := ""
Local nM      := 0
Local aCab 		:= {} , aItem := {} , aTotItem := {}
Local nOpc
Local cTM  		:= SuperGetMv("MV_ZZTM",.f.)
Local cNumOP    := ""
Local aDados    := {}
Local cNumDoc   := ""
Local lCont     := .T.

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

if Empty(cTM)
	IW_MsgBox(OemToAnsi("Por favor cadastre o tipo de movimentação, parametro MV_ZZTM"), OemToAnsi("Atenção") , "ALERT")
	Return
endif

If Day(dDataBase) == Day(LastDay(dDataBase))

	//PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] Tables 'SZD,SZE,SF5,SD3,SB1' Modulo 'EST'

	//ConOut("Iniciando rotina BxPadroes.PRW. Inicio: "+Time()+" - "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL))

	If Select("WRK1") > 0
		WRK1->(dbCloseArea())
	Endif

	cQuery := "SELECT DISTINCT ZE_DATA FROM "+RetSQLName("SZE")+" SZE "
	cQuery += "WHERE SZE.ZE_FILIAL = '"+xFilial("SZE")+"' AND "
	cQuery += "SZE.ZE_DATA = '"+DtoS(dDataBase)+"' AND "
	cQuery += "SZE.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "WRK1"

	If WRK1->ZE_DATA == DtoS(dDataBase)
		lCont := .F.
	Endif

	If Select("WRK1") > 0
		WRK1->(dbCloseArea())
	Endif

	If lCont

		cQuery := "SELECT COUNT(*) AS nRegistros FROM "+RetSQLName("SZD")+" SZD ,"+RetSQLName("SZE")+" SZE "
		cQuery += "WHERE SZD.ZD_STATUS <> '3' AND "
		cQuery += "SZD.ZD_FILIAL = '"+xFilial("SZD")+"' AND "
		cQuery += "SZE.ZE_FILIAL = '"+xFilial("SZE")+"' AND "
		cQuery += "SZD.ZD_SEQUENC = SZE.ZE_SEQUENC AND "
		cQuery += "SZD.ZD_COD = SZE.ZE_COD AND "
		cQuery += "SZD.ZD_ARMAZ = SZE.ZE_ARMAZ AND "
		cQuery += "SZD.ZD_DTLANC <= '"+DtoS(dDataBase)+"' AND "
		cQuery += "SZE.ZE_DATA = ' ' AND "
		cQuery += "SZD.D_E_L_E_T_ <> '*' AND "
		cQuery += "SZE.D_E_L_E_T_ <> '*' "

		cQuery := ChangeQuery(cQuery)
		TcQuery cQuery New Alias "WRK1"

		nTotRegs := WRK1->nRegistros

		If Select("WRK1") > 0
			WRK1->(dbCloseArea())
		Endif

		cQuery := "SELECT * , SZD.R_E_C_N_O_ AS SZDREC, SZE.R_E_C_N_O_ AS SZEREC FROM "+RetSQLName("SZD")+" SZD ,"+RetSQLName("SZE")+" SZE "
		cQuery += "WHERE SZD.ZD_STATUS <> '3' AND "
		cQuery += "SZD.ZD_FILIAL = '"+xFilial("SZD")+"' AND "
		cQuery += "SZE.ZE_FILIAL = '"+xFilial("SZE")+"' AND "
		cQuery += "SZD.ZD_SEQUENC = SZE.ZE_SEQUENC AND "
		cQuery += "SZD.ZD_COD = SZE.ZE_COD AND "
		cQuery += "SZD.ZD_ARMAZ = SZE.ZE_ARMAZ AND "
		cQuery += "SZD.ZD_DTLANC <= '"+DtoS(dDataBase)+"' AND "
		cQuery += "SZE.ZE_DATA = ' ' AND "
		cQuery += "SZD.D_E_L_E_T_ <> '*' AND "
		cQuery += "SZE.D_E_L_E_T_ <> '*' "

		cQuery := ChangeQuery(cQuery)
		TcQuery cQuery New Alias "WRK1"

		dbSelectArea("WRK1")
		dbGoTop()

		ProcRegua(nTotRegs)


//****************************************************
//modificado para uso de parametro exclusivo MV_ZZTM
//****************************************************
//		//If aParam[1] == "01"
//		If SM0->M0_CODIGO=='01'
//			cTM  := "600"
//		Else
//			cTM  := "501"
//		Endif
//****************************************************
		Begin Transaction

		While !Eof()
		    IncProc(OemToAnsi("Organizando dados..."))
			If aScan(aDados , {|x| x[3]==WRK1->ZE_COD .and. x[4]==WRK1->ZE_ARMAZ .and. x[8]==WRK1->ZE_SEQUENC}) == 0
				aadd(aDados , { cTM , cNumOP , WRK1->ZE_COD, WRK1->ZE_ARMAZ , WRK1->ZE_QUANT , WRK1->SZDREC , WRK1->SZEREC , WRK1->ZE_SEQUENC , WRK1->ZD_CCUSTO})
			Endif
			dbSkip()
		Enddo

		If Select("WRK1") > 0
			WRK1->(dbCloseArea())
		Endif

		ProcRegua(Len(aDados))

		cCCAux := aDados[1][9]

		For nM:=1 to Len(aDados)

			IncProc(OemToAnsi("Aplicando Diferimento..."))

			if aDados[nM][9] == cCCAux

				dbSelectArea("SF5")
				dbSetOrder(1)
				If dbSeek(xFilial("SF5")+cTM)

					dbSelectArea("SB1")
					dbSetOrder(1)
					If dbSeek(xFilial("SB1")+aDados[nM][3])

						If Empty(cNumDoc)
							cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
							cNumDoc := A261RetINV(cNumDoc)
							aCab :={{"D3_DOC"		,	cNumDoc			,	NIL},;
									{"D3_TM"		,	aDados[nM][1]	,	Nil},;
									{"D3_CC"		,	aDados[nM][9]	,	Nil},;
									{"D3_EMISSAO"   ,	dDataBase 		,	NIL}}

						Endif

						aItem:={{"D3_OP"		,	aDados[nM][2]	,	Nil},;
								{"D3_COD"		,	aDados[nM][3]	,	Nil},;
								{"D3_LOCAL"		,	aDados[nM][4]	,	Nil},;
								{"D3_QUANT"		,	aDados[nM][5]	,	Nil},;
								{"D3_GRUPO"		,	SB1->B1_GRUPO	,	Nil},;
								{"D3_TIPO"		,	SB1->B1_TIPO	,	Nil},;
								{"D3_CONTA"		,	SB1->B1_CONTA	,	Nil},;
								{"D3_UM"	    ,	SB1->B1_UM	    ,	Nil},;
								{"D3_ZZSEQZE"	,	aDados[nM][8]	,	Nil},;
								{"D3_ZZRECZE"	,	aDados[nM][7]	,	Nil}}

//								if Alltrim(aDados[nM][3]) == '09A20.0177' .or. Alltrim(aDados[nM][3]) == '09A20.0612'
//									Alert(Alltrim(aDados[nM][3]))
//								endif


						aadd(aTotItem,aItem)

					Endif

				Endif

			else

				If Len(aCab) > 0
//					Begin Transaction
						MsExecAuto({|x,y,z|Mata241(x,y,z)},aCab,aTotItem,nOpc)
						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
							Break
						Endif
//					End Transaction

					If lMsErroAuto
						Alert("PROCESSO NÃO FOI CONCLUÍDO, ANALISE O ERRO!")
						Return(.F.)
					Endif

					cNumDoc := ''
					cCCAux := aDados[nM][9]
					aCab := {}
					aItem := {}
					aTotItem := {}
					nM--
				endif

			Endif

		Next nM

		If Len(aCab) > 0
//			Begin Transaction
			MsExecAuto({|x,y,z|Mata241(x,y,z)},aCab,aTotItem,nOpc)
			If lMsErroAuto
				MostraErro()
				Alert("PROCESSO NÃO FOI CONCLUÍDO, ANALISE O ERRO!")
				DisarmTransaction()
				Break
			Endif
//			End Transaction

			If lMsErroAuto
				Return(.F.)
			Endif
		Endif

		ProcRegua(Len(aDados))

		For nM:=1 to Len(aDados)

			IncProc(OemToAnsi("Atualizando Sistema..."))

			dbSelectArea("SZE")
			dbGoTo(aDados[nM][7])
			If SZE->ZE_SALDO == 0
				cStatus := '3'
			Else
				cStatus := '2'
			Endif
			RecLock("SZE",.F.)
			ZE_DATA := dDataBase
			MsUnlock()

			dbSelectArea("SZD")
			dbGoTo(aDados[nM][6])
			RecLock("SZD",.F.)
			ZD_STATUS := cStatus
			MsUnlock()

		Next nM


		End Transaction

		If !lMsErroAuto
			IW_MsgBox(OemToAnsi("Processamento Concluído."), OemToAnsi("Informação") , "INFO")
		endif
		//ConOut("Finalizando rotina BxPadroes.PRW. Termino: "+Time()+" - "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL))

		//RESET ENVIRONMENT

	Else

		IW_MsgBox(OemToAnsi("Não é possível executar esta rotina mais de uma vez no mesmo mês."), OemToAnsi("Atenção") , "ALERT")

	Endif

Else

	IW_MsgBox(OemToAnsi("Ajuste a data base do sistema para o último dia do mês e execute a rotina novamente."), OemToAnsi("Atenção") , "STOP")

Endif

//aParam := aSize(aParam,0)
//aParam := Nil

Return
