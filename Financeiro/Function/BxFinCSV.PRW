#Include "Totvs.ch"
#Include "FwMVCDef.ch"
#Include "FWPrintSetup.ch"
#Include "RPTDEF.CH"
#Include "RwMake.ch"
#Include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "Fileio.ch"

#define _Filial      1
#define _CNPJ        2
#define _Cliente     3
#define _Loja        4
#define _Nome        5
#define _Tipo        6
#define _Titulo      7
#define _Vencto      8
#define _VlrLiq      9
#define _Pis         10
#define _Cofins      11
#define _CSLL        12
#define _Desconto    13
#define _Multa       14
#define _TxPerm      15
#define _NSU         16

Static lExecJob := IsBlind()

User Function BxFinCSV()
	Local aFields		:= {}
	// Local cAlias		:= GetNextAlias()
	Private cTitTela    := " | Baixa Financeira | "
	Private oTempTable

	Private oF08N		:= TFont():New("Arial",,-08,,.F.)
	Private oF08B		:= TFont():New("Arial",,-08,,.T.)
	Private oF10N		:= TFont():New("Arial",,-10,,.F.)
	Private oF10B		:= TFont():New("Arial",,-10,,.T.)
	Private oF11N		:= TFont():New("Arial",,-11,,.F.)
	Private oF11B		:= TFont():New("Arial",,-11,,.T.)
	Private oF12N		:= TFont():New("Arial",,-12,,.F.)
	Private oF12B		:= TFont():New("Arial",,-12,,.T.)
	Private oF14N		:= TFont():New("Arial",,-14,,.F.)
	Private oF14B		:= TFont():New("Arial",,-14,,.T.)
	Private oF24N		:= TFont():New("Arial",,-24,,.F.)
	Private oF24B		:= TFont():New("Arial",,-24,,.T.)

	private cArquivo := space(100)                     as character
	private cBanco   := space(TamSx3("A6_COD")[1])     as character
	private cAgencia := space(TamSx3("A6_AGENCIA")[1]) as character
	private cConta   := space(TamSx3("A6_NUMCON")[1])  as character
	private nVlrDesc := 0                              as numeric

	FWMakeDir( '\log_execauto\', .T. )

	oTempTable := FWTemporaryTable():New( "TTSE1" )

	aadd(aFields, {'OK'      , 'C', 02                      , 0})
	aadd(aFields, {'FILIAL'  , 'C', FWSizeFilial()          , 0})
	aadd(aFields, {'CNPJ'    , 'C', TamSx3("A1_CGC")[1]     , 0})
	aadd(aFields, {'CLIENTE' , 'C', TamSx3("A1_COD")[1]     , 0})
	aadd(aFields, {'LOJA'    , 'C', TamSx3("A1_LOJA")[1]    , 0})
	aadd(aFields, {'NOME'    , 'C', TamSx3("A1_NOME")[1]    , 0})
	aadd(aFields, {'TIPO'    , 'C', TamSx3("E1_TIPO")[1]    , 0})
	aadd(aFields, {'PREFIXO' , 'C', TamSx3("E1_PREFIXO")[1] , 0})
	aadd(aFields, {'TITULO'  , 'C', TamSx3("E1_NUM")[1]     , 0})
	aadd(aFields, {'PARCELA' , 'C', TamSx3("E1_PARCELA")[1] , 0})
	aadd(aFields, {'VENCTO'  , 'D', TamSx3("E1_VENCTO")[1]  , 0})
	aadd(aFields, {'VLRLIQ'  , 'N', TamSx3("E1_VALOR")[1]   , TamSx3("E1_VALOR")[2]})
	aadd(aFields, {'PIS'     , 'N', TamSx3("E1_PIS")[1]     , TamSx3("E1_PIS")[2]})
	aadd(aFields, {'COFINS'  , 'N', TamSx3("E1_COFINS")[1]  , TamSx3("E1_COFINS")[2]})
	aadd(aFields, {'CSLL'    , 'N', TamSx3("E1_CSLL")[1]    , TamSx3("E1_CSLL")[2]})
	aadd(aFields, {'DESCONTO', 'N', TamSx3("E1_DESCONT")[1] , TamSx3("E1_DESCONT")[2]})
	aadd(aFields, {'MULTA'   , 'N', TamSx3("E1_MULTA")[1]   , TamSx3("E1_MULTA")[2]})
	aadd(aFields, {'TXPERM'  , 'N', TamSx3("E1_VALJUR")[1]  , TamSx3("E1_VALJUR")[2]})
	aadd(aFields, {'NSU'     , 'C', TamSx3("E1_NSUTEF")[1]  , 0})
	aadd(aFields, {'STATUS'  , 'C', 1                       , 0})
	aadd(aFields, {'RECSE1'  , 'N', 16                      , 0})


	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("01", {"FILIAL","PREFIXO","TITULO","PARCELA","TIPO"}  )
	oTempTable:AddIndex("02", {"FILIAL","TITULO"} )
	oTempTable:AddIndex("03", {"TITULO"} )
	oTempTable:AddIndex("04", {"NSU"} )
	oTempTable:Create()

	TcSQLExec("SET IDENTITY_INSERT "+oTemptable:GetRealName()+" ON ")

	TelaRegs()

	oTempTable:Delete()

Return
// -----------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function TelaRegs

	Local cAlsMark      := oTempTable:GetAlias()
	Local aSeek         := {}
	Local aFieldFilter  := {}
	Private oMarkBr

	aAdd(aSeek,{"Filial + Prefixo + Titulo + Paracela + Tipo" ,   {{"","C",050,0,"Filial + Prefixo + Titulo + Paracela + Tipo"    ,"@!"}} } )
	aAdd(aSeek,{"Filial + Titulo"                      ,   {{"","C",050,0,"Filial + Titulo"                         ,"@!"}} } )

	aadd(aFieldFilter, {"TITULO"     , "Titulo"         , "C", 040, 0, "@!"})
	aadd(aFieldFilter, {"CLIENTE"    , "Cliente"        , "C", 040, 0, "@!"})
	aadd(aFieldFilter, {"NOME"       , "Nome Cliente"   , "C", 040, 0, "@!"})
	aadd(aFieldFilter, {"VENCTIMENTO", "Data Venctoo"   , "C", 040, 0, "@!"})

	oMarkBr:= FWMarkBrowse():New()
	oMarkBr:AddLegend("STATUS = '1'"    , "GREEN"	        , OemToAnsi("Pendente de Baixa") )
	oMarkBr:AddLegend("STATUS = 'B'"    , "RED" 	        , OemToAnsi("Já Baixado") )
	oMarkBr:AddLegend("STATUS = 'E'"    , "WHITE" 	        , OemToAnsi("Registro com Erro") )
	oMarkBr:AddLegend("STATUS = 'V'"    , "YELLOW" 	        , OemToAnsi("Registro com Erro de valor") )
	oMarkBr:AddLegend("STATUS = 'D'"    , "BLACK" 	        , OemToAnsi("Titulo nao localizado") )
	oMarkBr:AddLegend("STATUS = 'P'"    , "BLUE" 	        , OemToAnsi("Titulo com Baixa Parcial") )
	oMarkBr:AddLegend("STATUS = 'I'"    , "PINK" 	        , OemToAnsi("Titulo com Diferença de imposto") )
	oMarkBr:AddLegend("STATUS = 'C'"    , "BROWN" 	        , OemToAnsi("Titulo Cartao x NSU invalido") )
	oMarkBr:SetDataTable(.T.)
	oMarkBr:SetAlias(cAlsMark)

	oMarkBr:SetColumns(CriaCol( 'FILIAL'    , 'Filial'          ,02, '@!'                     ,FWSizeFilial()         , 0                         ))
	oMarkBr:SetColumns(CriaCol( 'CNPJ'      , 'CNPJ/CPF'        ,03, '@!'                     ,TamSx3("A1_CGC")[1]    , 0                         ))
	oMarkBr:SetColumns(CriaCol( 'CLIENTE'   , 'Cliente'         ,04, '@!'                     ,TamSx3("A1_COD")[1]    , 0                         ))
	oMarkBr:SetColumns(CriaCol( 'LOJA'      , 'Loja'            ,05, '@!'                     ,TamSx3("A1_LOJA")[1]   , 0                         ))
	oMarkBr:SetColumns(CriaCol( 'NOME'      , 'Nome Cliente'    ,06, '@!'                     ,TamSx3("A1_NOME")[1]   , 0                         ))
	oMarkBr:SetColumns(CriaCol( 'TIPO'      , 'Tipo'            ,07, '@!'                     ,TamSx3("E1_TIPO")[1]   , 0                         ))
	oMarkBr:SetColumns(CriaCol( 'PREFIXO'   , 'Prefixo'         ,08, '@!'                     ,TamSx3("E1_PREFIXO")[1], 0                         ))
	oMarkBr:SetColumns(CriaCol( 'TITULO'    , 'Titulo'          ,09, '@!'                     ,TamSx3("E1_NUM")[1]    , 0                         ))
	oMarkBr:SetColumns(CriaCol( 'PARCELA'   , 'Parcela'         ,10, '@!'                     ,TamSx3("E1_PARCELA")[1], 0                         ))
	oMarkBr:SetColumns(CriaCol( 'VENCTO'    , 'Data Vencto'     ,11, '@!'                     ,TamSx3("E1_VENCTO")[1] , 0                         ))
	oMarkBr:SetColumns(CriaCol( 'VLRLIQ'    , 'Vlr. Liquido'    ,12, X3Picture("E1_VALOR")    ,TamSx3("E1_VALOR")[1]  , TamSx3("E1_VALOR")[2]     ))
	oMarkBr:SetColumns(CriaCol( 'PIS'       , 'PIS'             ,13, X3Picture("E1_PIS")      ,TamSx3("E1_PIS")[1]    , TamSx3("E1_PIS")[2]       ))
	oMarkBr:SetColumns(CriaCol( 'COFINS'    , 'Cofins'          ,14, X3Picture("E1_COFINS")   ,TamSx3("E1_COFINS")[1] , TamSx3("E1_COFINS")[2]    ))
	oMarkBr:SetColumns(CriaCol( 'CSLL'      , 'CSLL'            ,15, X3Picture("E1_CSLL")     ,TamSx3("E1_CSLL")[1]   , TamSx3("E1_CSLL")[2]      ))
	oMarkBr:SetColumns(CriaCol( 'DESCONTO'  , 'Vlr Desconto'    ,16, X3Picture("E1_DESCONT")  ,TamSx3("E1_DESCONT")[1], TamSx3("E1_DESCONT")[2]   ))
	oMarkBr:SetColumns(CriaCol( 'MULTA'     , 'Vlr Multa'       ,17, X3Picture("E1_MULTA")    ,TamSx3("E1_MULTA")[1]  , TamSx3("E1_MULTA")[2]     ))
	oMarkBr:SetColumns(CriaCol( 'TXPERM'    , 'Tx Permanc.'     ,18, X3Picture("E1_VALJUR")   ,TamSx3("E1_VALJUR")[1] , TamSx3("E1_VALJUR")[2]    ))
	oMarkBr:SetColumns(CriaCol( 'NSU'       , 'NSU'             ,19, '@!'                     ,TamSx3("E1_NSUTEF")[1] , 0                         ))


	oMarkBr:SetFieldMark("OK")
	oMarkBr:SetMark("OK", cAlsMark, "OK")
	oMarkBr:SetAllMark({||xMarkAll(oMarkBr)})
	oMarkBr:SetMenuDef("")
	oMarkBr:SetIgnoreARotina(.T.)
	oMarkBr:SetAmbiente(.F.)
	oMarkBr:SetWalkThru(.F.)
	oMarkBr:DisableReport()
	oMarkBr:DisableDetails()
	oMarkBr:SetValid({|| (cAlsMark)->STATUS $ "1|E|I" })
	oMarkBr:oBrowse:SetDBFFilter(.T.)
	oMarkBr:oBrowse:SetUseFilter(.T.)
	oMarkBr:oBrowse:SetFieldFilter(aFieldFilter)
	oMarkBr:oBrowse:SetSeek(.T.,aSeek)
	oMarkBr:oBrowse:SetFilterDefault("")
	oMarkBr:ForceQuitButton(.T.)
	oMarkBr:SetDescription(OemToAnsi(cTitTela))
	oMarkBr:AddButton("Carregar Dados"  			, { || MsgRun('Carregando Registros...' ,'Carregando...'    ,{|| LoadTmp()          })  },,2,2 )
	oMarkBr:AddButton("Baixar"    			        , { || MsgRun('Processando...'          ,'Processando...'   ,{|| BaixaFin(oMarkBr) })   },,2,2 )
	oMarkBr:AddButton("Visualizar" 			        , { || MsgRun('Importando...'           ,'Importando...'    ,{|| VisTit()           })  },,2,2 )
	oMarkBr:AddButton("Marcar Todos"    			, { || MsgRun('Atualizando...'          ,'Atualizando...'   ,{|| xMarkAll(oMarkBr)  })  },,2,2 )
	oMarkBr:AddButton("Desmarcar Todos"    			, { || MsgRun('Atualizando...'          ,'Atualizando...'   ,{|| xUMarkAll(oMarkBr) })  },,2,2 )
	oMarkBr:AddButton("Sumario Registros"  			, { || SumReg() },,2,2 )
	oMarkBr:AddButton("Relatorio"    			    , { || MsgRun('Atualizando...'          ,'Atualizando...'   ,{|| rptImport() })  },,2,2 )
	oMarkBr:AddButton("Exporta Brower Excel"        , { || MsgRun('Atualizando...'          ,'Atualizando...'   ,{|| GeraExcel()() })  },,2,2 )
	oMarkBr:AddButton("Sair"            			, { || CloseBrowse()                                                                    },,5,2 )



	oMarkBr:Activate()
	oMarkBr:oBrowse:Setfocus()

Return
// -----------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function LoadTmp

	local cDados     := ""                             as character
	local aPergs     := {}                             as array
	local cCampoIns  := " FILIAL,CNPJ,CLIENTE,LOJA,NOME,TIPO,PREFIXO,TITULO,PARCELA,VENCTO,VLRLIQ,PIS,COFINS,CSLL,DESCONTO,MULTA,TXPERM,NSU "
	local cLinha     := ""                             as character
	local aLinha     := {}                             as array
	// local nTipo      := 0                              as numeric

	aadd( aPergs, {6,"Arquivo"                  ,cArquivo   ,"",,"", 90 ,.T.,"Arquivos .CSV |*.CSV","C:\",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})
	aAdd( aPergs ,{1,"Banco"                    ,cBanco     ,"@!","ExistCpo('SA6', &(ReadVar()))","SA6",".T.",40,.T.})
	aAdd( aPergs ,{1,"Agencia"                  ,cAgencia   ,"@!",".T.",,".T.",40,.T.})
	aAdd( aPergs ,{1,"Conta"                    ,cConta     ,"@!",".T.",,".T.",40,.T.})
	aAdd( aPergs ,{1,"Vlr Min/Max Desconto"     ,nVlrDesc   ,"@R 9.99","Positivo()",,".T.",40,.F.})
	// aAdd( aPergs ,{2,"Tipo de baixa"            ,nTipo      ,{"1=Deposito", "2=Cartao"},122,".T.",.T.})

	If ParamBox(aPergs, "Informe os parâmetros", , , ,.T., , , , , .F., .T.)
		cArquivo := alltrim(MV_PAR01)
		cBanco   := padr(alltrim(MV_PAR02), TamSx3("A6_COD")[1])
		cAgencia := padr(alltrim(MV_PAR03), TamSx3("A6_AGENCIA")[1])
		cConta   := padr(alltrim(MV_PAR04), TamSx3("A6_NUMCON")[1])
		nVlrDesc := MV_PAR05
		// nTipo    := iif(Empty(MV_PAR06),1,MV_PAR06)

		dbSelectArea("SA6")
		dbSetOrder(1)//A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON
		If !dbSeek(FWxFilial("SA6") + cBanco + cAgencia + cConta)
			FWAlertWarning("Dados bancario informado invalido.","Validacao Banco")
			return(.F.)
		EndIf
		If !File(cArquivo)
			Return(.F.)
		EndIf

		oFile := FWFileReader():New(cArquivo)
		If (oFile:Open())

			If ! (oFile:EoF())
				nLin := 0
				TcSQLExec(" TRUNCATE TABLE " + oTemptable:GetRealName() )
				While (oFile:HasLine())
					nLin += 1
					// op_Self:IncRegua2("Importando registro " + cValToChar(nLin) + " de " + cValToChar(nRecQry) + "...")

					cLinha := oFile:GetLine()
					aLinha := StrTokArr2( cLinha, ";", .T. )

					If nLin == 1
						If Upper(alltrim(cLinha)) != "FILIAL;CNPJ/CPF;CLIENTE;LOJA;NOME CLIENTE;TIPO;PRF-NUMERO PARCELA;VENCTO REAL;VLR LIQUIDO;PIS;COFINS;CSLL;DESCONTO;MULTA;TAXA PERM;NSU;FIM"
							FwAlertWarning("Estrutura do arquivo incorreta.","Aviso Erro")
							Exit
						EndIf
					Else

						aTitulo := StrTokArr2(alltrim(alinha[_Titulo]),"-",.T.)

						If len(aTitulo) != 3
							FwAlertWarning("Falha no processamento dos dados.","Aviso Erro")
							Exit
						Else

							alinha[_VlrLiq]   := strTran(alinha[_VlrLiq]    ,"-","0")
							alinha[_Pis]      := strTran(alinha[_Pis]       ,"-","0")
							alinha[_Cofins]   := strTran(alinha[_Cofins]    ,"-","0")
							alinha[_CSLL]     := strTran(alinha[_CSLL]      ,"-","0")
							alinha[_Desconto] := strTran(alinha[_Desconto]  ,"-","0")
							alinha[_Multa]    := strTran(alinha[_Multa]     ,"-","0")
							alinha[_TxPerm]   := strTran(alinha[_TxPerm]    ,"-","0")

							cDados := "'" + alltrim(aLinha[_Filial])    + "','" + ;
								alltrim(alinha[_CNPJ])                  + "','" + ;
								alltrim(alinha[_Cliente])               + "','" + ;
								alltrim(alinha[_Loja])                  + "','" + ;
								alltrim(alinha[_Nome])                  + "','" + ;
								alltrim(alinha[_Tipo])                  + "','" + ;
								alltrim(aTitulo[1])                     + "','" + ;
								alltrim(aTitulo[2])                     + "','" + ;
								alltrim(aTitulo[3])                     + "','" + ;
								dTos(cTod(alltrim(alinha[_Vencto])))    + "',"  + ;
								strTran(strTran(alltrim(iif(Empty(alinha[_VlrLiq]),'0',alinha[_VlrLiq])),".",""),",",".")       + ","   + ;
								strTran(strTran(alltrim(iif(Empty(alinha[_Pis]),'0',alinha[_Pis])),".",""),",",".")             + ","   + ;
								strTran(strTran(alltrim(iif(Empty(alinha[_Cofins]),'0',alinha[_Cofins])),".",""),",",".")       + ","   + ;
								strTran(strTran(alltrim(iif(Empty(alinha[_CSLL]),'0',alinha[_CSLL])),".",""),",",".")           + ","   + ;
								strTran(strTran(alltrim(iif(Empty(alinha[_Desconto]),'0',alinha[_Desconto])),".",""),",",".")   + ","   + ;
								strTran(strTran(alltrim(iif(Empty(alinha[_Multa]),'0',alinha[_Multa])),".",""),",",".")         + ","   + ;
								strTran(strTran(alltrim(iif(Empty(alinha[_TxPerm]),'0',alinha[_TxPerm])),".",""),",",".")       + ",'"   + ;
								alltrim(alinha[_NSU])                            + "'"

							TcSQLExec(" INSERT INTO " + oTemptable:GetRealName() + " (" + cCampoIns + ") VALUES (" + cDados + ")")
						EndIf
					EndIf

				EndDo
			EndIf
			oFile:Close()

		EndIf

		MsgRun('Atualizando Status...','Atualizando...'   ,{|| VldReg() })

		oMarkBr:GoBottom(.T.)
		oMarkBr:Refresh(.T.)

	EndIf
Return
// -----------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function CriaCol(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData     := {||}
	Default nAlign     := 1
	Default nSize     := 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	EndIf

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{|| .T. },.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}
// -----------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function xMarkAll(oObjMark)

	Local cMark    := oObjMark:Mark()

	TcSQLExec(" UPDATE " + oTemptable:GetRealName() + " SET OK = '" + cMark + "' WHERE STATUS = '1' " )

	oObjMark:Refresh(.T.)

Return( .T. )
// -----------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function xUMarkAll(oObjMark)

	TcSQLExec(" UPDATE " + oTemptable:GetRealName() + " SET OK = '' " )

	oObjMark:Refresh(.T.)

Return( .T. )
// -----------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function BaixaFin( oMarkBr )

	Local _bBloco := { | lEnd | BxAux() }

	MsAguarde(_bBloco, "Processando Baixas", "Aguarde...")

	//oMarkBr:GoBottom(.T.)
	oMarkBr:Refresh(.T.)

Return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function BxAux()

	local aBaixa := {} as array
	private lMsErroAuto 	:= .F. as logical

	aBaixa	:= {}
	_cAlias := GetArea()

	If Select("cAliasTMP") > 0
		cAliasTMP->( DbCloseArea() )
	Endif

	cQuery := " SELECT TMP.*, TMP.R_E_C_N_O_ AS RECTMP FROM " + oTemptable:GetRealName() + " TMP
	cQuery += " WHERE OK = 'OK'                       "+CRLF
	cQuery += " AND STATUS IN ('1','E','I')           "+CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cAliasTMP",.T.,.F.)

	dbSelectArea("cAliasTMP")
	cAliasTMP->( dbGoTop() )

	If cAliasTMP->( !Eof() )

		While cAliasTMP->( !Eof() )
			lRet    := .T.
			lTrocaFil := .F.
			nReqTMP := cAliasTMP->RECTMP
			aDadosP := {cBanco, cAgencia, cConta, nVlrDesc}

			aAreaAux := GetArea()
			lRet := StartJob( "U_BxTitCSV()", getenvserver(), .T., {cAliasTMP->RECSE1, cAliasTMP->FILIAL, cAliasTMP->VLRLIQ, cAliasTMP->PIS, ;
				cAliasTMP->COFINS, cAliasTMP->CSLL, cAliasTMP->DESCONTO, cAliasTMP->MULTA, cAliasTMP->TXPERM, aDadosP, cAliasTMP->NSU, dDataBase })
			RestArea(aAreaAux)

			If !lRet
				TcSQLExec(" UPDATE " + oTemptable:GetRealName() + " SET OK = ' ', STATUS = 'E' WHERE R_E_C_N_O_ = " + AllTrim(cValToChar(nReqTMP)) )
			Else
				TcSQLExec(" UPDATE " + oTemptable:GetRealName() + " SET OK = ' ', STATUS = 'B' WHERE R_E_C_N_O_ = " + AllTrim(cValToChar(nReqTMP)) )
			EndIf


			cAliasTMP->( dbSkip() )
		EndDo

		MsgRun('Atualizando Status...','Atualizando...'   ,{|| VldReg() })

		oMarkBr:GoBottom(.T.)
		oMarkBr:Refresh(.T.)

	EndIf
	cAliasTMP->( DbCloseArea() )

	RestArea(_cAlias)
return
// -----------------------------------------------------------------------------------------------------------------------------------------------------------

User Function BxTitCSV(ParamIxb)
	local nRecSE1       := ParamIxb[1]  as numeric

	local cFilXEmp      := ParamIxb[2]  as character
	local nValBx        := ParamIxb[3]  as numeric
	local nPIS          := ParamIxb[4]  as numeric
	local nCOFINS       := ParamIxb[5]  as numeric
	local nCSLL         := ParamIxb[6]  as numeric
	local nDesc         := ParamIxb[7]  as numeric
	local nMulta        := ParamIxb[8]  as numeric
	local nTxPerm       := ParamIxb[9]  as numeric
	local aDadosP       := ParamIxb[10] as array
	local cNSU          := ParamIxb[11] as character
	local dDtAux        := ParamIxb[12] as date
	private lMsErroAuto := .F.          as logical

	cBanco   := aDadosP[1]
	cAgencia := aDadosP[2]
	cConta   := aDadosP[3]
	nVlrDesc := aDadosP[4]
	cEmp     := '01' //Substr(cFilXEmp,1,2)
	cFil     := cFilXEmp


	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,"FIN",, , /*lShowFinal*/, /*lAbend*/, .T. /*lOpenSX*/, /*lConnect*/)

	// Begin Transaction
	dbSelectArea("SE1")
	SE1->(dbGoTo(nRecSE1))
	aBaixa	:= {}
	// conout("2")

	dDataBase := dDtAux

	SED->(dbSetOrder(1), dbSeek(FWxFilial("SED") + SE1->E1_NATUREZ))
	// conout("3")
	nPisCalc := 0
	nCofCalc := 0
	nCslCalc := 0

	If SE1->E1_PIS != 0
		nPisCalc := NoRound((SE1->E1_SALDO * (Iif(SED->ED_PERCPIS>0,SED->ED_PERCPIS,GetMv("MV_TXPIS")) / 100)),2)
	EndIf

	If SE1->E1_COFINS != 0
		nCofCalc := NoRound((SE1->E1_SALDO * (Iif(SED->ED_PERCCOF>0,SED->ED_PERCCOF,GetMv("MV_TXCOFIN")) / 100)),2)
	EndIf

	If SE1->E1_CSLL != 0
		nCslCalc := NoRound((SE1->E1_SALDO * (SED->ED_PERCCSL / 100)),2)
	EndIf


	If nPIS != SE1->E1_PIS
		reclock("SE1",.F.)
		SE1->E1_XBASPIS := SE1->E1_BASEPIS
		SE1->E1_XPIS    := SE1->E1_PIS

		If nPIS == 0
			SE1->E1_BASEPIS := 0
			SE1->E1_PIS     := 0
			nPisCalc        := 0
		Else
			nPisCalc := NoRound((SE1->E1_SALDO * (Iif(SED->ED_PERCPIS>0,SED->ED_PERCPIS,GetMv("MV_TXPIS")) / 100)),2)
			SE1->E1_PIS     := nPIS
		EndIf
		SE1->(MsUnlock())
	EndIf

	If nCOFINS != SE1->E1_COFINS
		reclock("SE1",.F.)
		SE1->E1_XBASCOF := SE1->E1_BASECOF
		SE1->E1_XCOF    := SE1->E1_COFINS

		If nCOFINS == 0
			SE1->E1_BASECOF := 0
			SE1->E1_COFINS  := 0
			nCofCalc        := 0
		Else
			nCofCalc := NoRound((SE1->E1_SALDO * (Iif(SED->ED_PERCCOF>0,SED->ED_PERCCOF,GetMv("MV_TXCOFIN")) / 100)),2)
			SE1->E1_COFINS     := nCOFINS
		EndIf
		SE1->(MsUnlock())
	EndIf

	If nCSLL != SE1->E1_CSLL
		reclock("SE1",.F.)
		SE1->E1_XBASCSL := SE1->E1_BASECSL
		SE1->E1_XCSLL   := SE1->E1_CSLL

		If nCSLL == 0
			SE1->E1_BASECSL := 0
			SE1->E1_CSLL     := 0
			nCslCalc := 0
		Else
			nCslCalc := NoRound((SE1->E1_SALDO * (SED->ED_PERCCSL / 100)),2)
			SE1->E1_CSLL     := nCSLL
		EndIf
		SE1->(MsUnlock())
	EndIf


	nSaldo    := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase,;
		dDataBase, SE1->E1_LOJA ) +SE1->E1_ACRESC - SE1->E1_DESCONT - SE1->E1_IRRF - nPisCalc - nCofCalc - nCslCalc

	nDif      := 0
	nDif      := nSaldo - nValBx
	nDesconto := nDesc
	nMulta    := nMulta
	cHistFin  := "BX AUTO CSV " + cUserName +  " " + cValToChar(dDataBase)

	// If abs(nDif) >= 0.02
	// 	If nDif < 0
	// 		nDesconto += abs(nDif)
	// 	ElseIf nDif > 0
	// 		nMulta += abs(nDif)
	// 	EndIf
	// EndIf

	If !Empty(cNSU)
		nValBx -= SE1->E1_DECRESC
	EndIf

	nValBx += nTxPerm
	aBaixa:= {{"E1_PREFIXO"     , SE1->E1_PREFIXO					,Nil,},;
		{"E1_NUM" 				, SE1->E1_NUM						,Nil,},;
		{"E1_PARCELA"			, SE1->E1_PARCELA					,Nil,},;
		{"E1_TIPO" 				, SE1->E1_TIPO						,Nil,},;
		{"AUTMOTBX" 			, "NOR"							    ,Nil,},;
		{"AUTDTBAIXA" 			, dDataBase					        ,Nil,},;
		{"AUTDTCREDITO"			, dDataBase							,Nil,},;
		{"AUTHIST" 				, cHistFin                          ,Nil,},;
		{"AUTBANCO"    	        , cBanco			           		,Nil,},;
		{"AUTAGENCIA"  	        , cAgencia			         		,Nil,},;
		{"AUTCONTA"    	        , cConta                  			,Nil,},;
		{"AUTDESCONT"			, nDesconto                   		,nIL,.T.},;
		{"AUTMULTA"				, nMulta               				,nIL,.T.},;
		{"AUTJUROS"				, nTxPerm					        ,nIL,.T.},;
		{"AUTVALREC" 		    , nValBx    				    	,Nil,.T.}}

	// aBaixa := FWVetByDic(aBaixa, "SE1")

	// AcessaPerg("FINA070", .F.)

	// aPergAux := {}
	// Pergunte("FINA070", .F., , , , , @aPergAux)
	// MV_PAR01 := '1'
	// MV_PAR02 := nPesoBrt
	// MV_PAR03 := nPesoLiq
	// //Chama a rotina para salvar os parâmetros
	// __SaveParam(cPerg, aPergAux)

	varinfo( "", aBaixa )

	lMsErroAuto := .F.
	lMsHelpAuto	:= .T.
	MSExecAuto({|x,y|Fina070(x,y)},aBaixa,3)
	If lMsErroAuto
		// DisarmTransaction()
		MostraErro("\log_execauto\", "bxfinCSV_"+dtos(date())+"_"+strTran(Time(),":","")+".log")
		lRet := .F.
	ELSE
		lRet := .T.
	Endif
	// RESET ENVIRONMENT
	RpcClearEnv()

Return(lRet)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

static function VisTit()
	local nX          := 0
	private cCadastro := 'CONSULTA - TITULO A RECEBER'

	aMvPar := {}

	For nX := 1 To 40
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
	Next nX

	If !empty(TTSE1->RECSE1)
		dbSelectArea("SE1")
		SE1->(dbGoTo(TTSE1->RECSE1))

		nRec := SE1->(Recno())
		AxVisual('SE1',nRec,2)
		// INCLUI := .F.
		// ALTERA := .F.
		// Pergunte("FIN070",.F.)
		// FA070Tit("SE1",0,SE1->(Recno()))
	EndIf


	For nX := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
	Next nX

return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

static function VldReg()
	// local cQuery := "" as character

	dbSelectArea("TTSE1")
	dbGoTop()
	while TTSE1->(!eof())

		dbSelectArea("SE1")
		dbSetOrder(1)
		If dbSeek( TTSE1->(FILIAL + PREFIXO + TITULO + PARCELA + TIPO ))
			nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase, ;
				dDataBase, SE1->E1_LOJA ) + SE1->E1_ACRESC - SE1->E1_DESCONT - SE1->(E1_PIS + E1_COFINS + E1_CSLL + E1_IRRF)

			//atualiza o recno do se1 nos registros e grava como registro OK
			reclock("TTSE1",.F.)
			TTSE1->RECSE1 := SE1->(Recno())
			TTSE1->STATUS := '1'
			TTSE1->(MSUnlock())

			If !Empty(TTSE1->NSU)
				If abs((nSaldo - TTSE1->VLRLIQ + SE1->E1_DECRESC)) > nVlrDesc
					reclock("TTSE1",.F.)
					TTSE1->STATUS := 'V'
					TTSE1->(MSUnlock())
				EndIf
			Else
				If abs((nSaldo - TTSE1->VLRLIQ)) > nVlrDesc
					reclock("TTSE1",.F.)
					TTSE1->STATUS := 'V'
					TTSE1->(MSUnlock())
				EndIf
			EndIf

			If TTSE1->PIS != SE1->E1_PIS .or. TTSE1->COFINS != SE1->E1_COFINS .or. TTSE1->CSLL != SE1->E1_CSLL
				reclock("TTSE1",.F.)
				TTSE1->STATUS := 'I'
				TTSE1->(MSUnlock())
			EndIf

			If (!Empty(TTSE1->NSU) .and. !alltrim(SE1->E1_TIPO) $ "CC|CD") .or. (Empty(TTSE1->NSU) .and. alltrim(SE1->E1_TIPO) $ "CC|CD")
				reclock("TTSE1",.F.)
				TTSE1->STATUS := 'V'
				TTSE1->(MSUnlock())
			EndIf

			//atualiza o status para os registros já baixados
			If SE1->E1_SALDO == 0
				reclock("TTSE1",.F.)
				TTSE1->STATUS := 'B'
				TTSE1->(MSUnlock())
			EndIf

		Else
			//atualiza o status para os registros não localizado
			reclock("TTSE1",.F.)
			RECSE1 := 0
			STATUS := 'D'
			TTSE1->(MSUnlock())
		EndIf

		TTSE1->(dbSkip())
	EndDo
	TTSE1->(dbGoTop())

return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

static function rptImport()

	Local oReport
	DEFAULT aParam := {}

	oReport:=ReportDef(aParam)
	If !lExecJob
		oReport:PrintDialog()
	Else
		oReport:lPreview	:= .F.
		oReport:Print()
	EndIF

return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ReportDef(aParam)
	Local oReport := Nil
	Local cFile	  := ""
	Local cPath	  := ""

	Default aParam := {}	//Modelo conteudo do array {{'MV_PAR01',Valor},{'MV_PAR02',Valor},{'MV_PARn',ValorN}}


	oReport := TReport():New("rptImport",'Impressao Relação de Baixas Contas Receber',"",{|oReport| ReportPrint(oReport)},;
		'Este programa tem como objetivo imprimir os títulos contidos no arquivo de baixa (CSV), conforme layout, previamente configurado.')

	If lExecJob
		oReport:nDevice := 6

		cPath		:= "C:\TEMP\"
		cFile	 	:= "rptImport"
		If File(cPath+cFile+".PDF")
			FERASE(cPath+cFile+".PDF")
		Endif
		oReport:cFile := cFile
	EndIf

	// Secao 1 - Titulos a Receber

	oSection1 := TRSection():New(oReport,'TITREC')
	TRCell():New(oSection1,"SEC1_PRF",,'PRF',,5,,)
	TRCell():New(oSection1,"SEC1_TITULO",,'TITULO',,13,,)
	TRCell():New(oSection1,"SEC1_PARC",,'PARC.',,5,,)
	TRCell():New(oSection1,"SEC1_TIPO",,'TIPO',,5,,)
	TRCell():New(oSection1,"SEC1_CLI",,'Cli/For',,30,,)
	TRCell():New(oSection1,"SEC1_DTVENC",,'Dt.Vencto',,10,,)
	TRCell():New(oSection1,"SEC1_VORIG",,StrTran('Vlr Original'," ",CRLF),"@E 99999,999.99",12,,,"CENTER",,"CENTER")
	TRCell():New(oSection1,"SEC1_OCOR",,'Ocorrencia',,150,,)

	// Secao 3 - Subtotais

	oSection2 := TRSection():New(oReport,'Subtotais')
	TRCell():New(oSection2,"STOT_TIT",,'SUB-TOTAIS',,69,,)
	TRCell():New(oSection2,"STOT_VORIG",,StrTran('Vlr Original'," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")

	oSection2:SetHeaderSection(.T.)
	oReport:SetLandScape()

	If File(cPath+cFile+".PDF")
		FERASE(cPath+cFile+".PDF")
	Endif

Return(oReport)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------


Static Function ReportPrint(oReport)
	Local nReg 			:= 0
	Local oSecao 		:= oReport:Section(1)
	Private aEstruct 	:= {}

	oReport:Section("TITREC"):Init()
	oSecao:SetHeaderSection(.T.)

	cQuery := ""
	cQuery += " SELECT *
	cQuery += " FROM " + oTemptable:GetRealName() + " TMP "
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += " AND OK = 'OK'
	TcQuery cQuery New Alias (cTMP := GetNextAlias())

	Count to nReg
	oReport:SetMeter(nReg)

	dbSelectArea((cTMP))
	(cTMP)->(dbGoTop())
	While (cTMP)->(!EOF())
		If oReport:Cancel()
			Exit
		EndIf
		oReport:IncMeter()                 //Incrementa a barra de progresso

		// FILIAL
		// CNPJ
		// CLIENTE
		// LOJA
		// NOME
		// TIPO
		// PREFIXO
		// TITULO
		// PARCELA
		// VENCTO
		// VLRLIQ
		// PIS
		// COFINS
		// CSLL
		// DESCONTO
		// MULTA
		// TXPERM
		// NSU

		cOCOR := ""
		oSecao:Cell("SEC1_PRF"):SetValue((cTMP)->PREFIXO)
		oSecao:Cell("SEC1_PRF"):SetAlign("CENTER")

		oSecao:Cell("SEC1_TITULO"):SetValue((cTMP)->TITULO)
		oSecao:Cell("SEC1_TITULO"):SetAlign("LEFT")

		oSecao:Cell("SEC1_PARC"):SetValue((cTMP)->PARCELA)
		oSecao:Cell("SEC1_PARC"):SetAlign("CENTER")

		oSecao:Cell("SEC1_TIPO"):SetValue((cTMP)->TIPO)
		oSecao:Cell("SEC1_TIPO"):SetAlign("LEFT")

		oSecao:Cell("SEC1_CLI"):SetValue((cTMP)->NOME)
		oSecao:Cell("SEC1_CLI"):SetAlign("LEFT")

		oSecao:Cell("SEC1_DTVENC"):SetValue(sTod((cTMP)->VENCTO))
		oSecao:Cell("SEC1_DTVENC"):SetAlign("CENTER")

		oSecao:Cell("SEC1_VORIG"):SetValue((cTMP)->VLRLIQ)
		oSecao:Cell("SEC1_VORIG"):SetAlign("RIGHT")

		dbSelectArea("SE1")
		dbSetOrder(1) //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
		If dbSeek(FWxFilial("SE1") + (cTMP)->PREFIXO + (cTMP)->TITULO + (cTMP)->PARCELA + (cTMP)->TIPO)
			nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase, ;
				dDataBase, SE1->E1_LOJA ) +SE1->E1_ACRESC - SE1->E1_DESCONT - SE1->(E1_PIS + E1_COFINS + E1_CSLL + E1_IRRF)

			If nSaldo != (cTMP)->VLRLIQ
				cOCOR := "VALOR INFORMADO DIFERENTE DO SALDO DO TITULO;"
			ElseIf SE1->E1_VENCTO != sTod((cTMP)->VENCTO)
				cOCOR := "DATA DE VENCIMENTO INFORMADO DIFERENTE DO VENCIMENTO DO TITULO;"
			ElseIf SE1->E1_CLIENTE != (cTMP)->CLIENTE .and. SE1->E1_LOJA != (cTMP)->LOJA
				cOCOR := "CLIENTE E LOJA INFORMADO DIFERENTE DO CLIENTE E LOJA DO TITULO;"
			ElseIf SE1->E1_PIS != (cTMP)->PIS .or. SE1->E1_COFINS != (cTMP)->COFINS .or. SE1->E1_CSLL != (cTMP)->CSLL
				cOCOR := "VALOR DO PCC INFORMADO DIFERENTE DO VALOR DO PCC DO TITULO;"
			Else
				cOCOR := "TITULO OK
			EndIf
		Else
			cOCOR := "TITULO NAO ENCONTRADO"
		EndIf
		oSecao:Cell("SEC1_OCOR"):SetValue(cOCOR)
		oSecao:Cell("SEC1_OCOR"):SetAlign("LEFT")

		oSecao:PrintLine()

		(cTMP)->(dbSkip())
	EndDo
	(cTMP)->(dbCloseArea())

	//Fim da impressão da seção
	oReport:Section("TITREC"):Finish()

return

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

static function SumReg()
	local _cAlias := GetArea()

	Local oBOK
	Local oFont1  := TFont():New("MS Sans Serif", , 023, , .T., , , , , .F., .F.)
	Local oFont2  := TFont():New("MS Sans Serif", , 022, , .T., , , , , .F., .F.)
	Local oGReg
	Local nGReg   := 0
	Local oGTotal
	Local nGTotal := 0
	Local oSay1
	Local oSay2
	Static oDlgTot

	cQuery := " SELECT COUNT(*) AS QTD_REG, SUM(VLRLIQ) AS VLR FROM " + oTemptable:GetRealName() + " TMP
	cQuery += " WHERE OK = 'OK'                       "+CRLF
	cQuery += " AND STATUS IN ('1','E','I')           "+CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cAliasTMP",.T.,.F.)

	dbSelectArea("cAliasTMP")
	cAliasTMP->( dbGoTop() )

	If cAliasTMP->( !Eof() )

		nGReg   := cAliasTMP->QTD_REG
		nGTotal := cAliasTMP->VLR

	EndIf
	cAliasTMP->( DbCloseArea() )


	DEFINE MSDIALOG oDlgTot TITLE "Sumario Registros" FROM 000, 000  TO 180, 200 COLORS 0, 16777215 PIXEL

	@ 003, 009 SAY oSay1 PROMPT "Quant. Registros" SIZE 082, 014 OF oDlgTot FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 018, 017 MSGET oGReg VAR nGReg SIZE 065, 016 OF oDlgTot  PICTURE "@E 9999" COLORS 32768, 16777215 FONT oFont2 PIXEL
	@ 042, 021 SAY oSay2 PROMPT "Valor Total" SIZE 057, 014 OF oDlgTot FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 057, 017 MSGET oGTotal VAR nGTotal SIZE 065, 016 OF oDlgTot  PICTURE "@E 999,999.99"COLORS 32768, 16777215 FONT oFont2 PIXEL
	@ 077, 000 BUTTON oBOK PROMPT "OK" SIZE 100, 012 OF oDlgTot PIXEL

	// Don't change the Align Order
	oBOK:Align := CONTROL_ALIGN_BOTTOM
	oGReg:Disable()
	oGTotal:Disable()
	oBOK:bAction := {|| oDlgTot:End()}

	ACTIVATE MSDIALOG oDlgTot CENTERED

	RestArea(_cAlias)

return()


// --------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function GeraExcel()
	local cSheet := "DADOS"
	local cTitulo := "Movimentos Baixa Deposito"
	cArquivo := "c:\temp\BaixaDeposito.XML"

	cQuery := ""
	cQuery += " SELECT *
	cQuery += " FROM " + oTemptable:GetRealName() + " TMP "
	cQuery += " WHERE D_E_L_E_T_ = '' "

	TcQuery cQuery New Alias (cTMP := GetNextAlias())

	dbSelectArea((cTMP))
	(cTMP)->(dbGoTop())
	If (cTMP)->(!EOF())

		If file(cArquivo)
			FERASE(cArquivo)
		EndIf

		oFWMsExcel := FWMsExcelEx():New()

		oFWMsExcel:AddworkSheet(cSheet)
		oFWMsExcel:AddTable(cSheet, cTitulo)

		oFWMsExcel:AddColumn(cSheet, cTitulo,"##"                     ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Filial"               ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"CNPJ"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Cliente"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Loja"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Nome"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Tipo"                 ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Prefixo"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Numero Titulo"        ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Parcela"              ,1,1)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Vencimento"           ,2,4)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Valor Liquido"        ,3,2,.T.)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Pis"                  ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Cofins"               ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"CSLL"                 ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Desconto"             ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Multa"                ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"Taxa Permanencia"     ,3,2)
		oFWMsExcel:AddColumn(cSheet, cTitulo,"NSU"                  ,1,1)


		While (cTMP)->(!EOF())
			oFWMsExcel:AddRow(cSheet, cTitulo,{(cTMP)->OK,;
				(cTMP)->FILIAL,;
				(cTMP)->CNPJ,;
				(cTMP)->CLIENTE,;
				(cTMP)->LOJA,;
				(cTMP)->NOME,;
				(cTMP)->TIPO,;
				(cTMP)->PREFIXO,;
				(cTMP)->TITULO,;
				(cTMP)->PARCELA,;
				sTod((cTMP)->VENCTO),;
				(cTMP)->VLRLIQ,;
				(cTMP)->PIS,;
				(cTMP)->COFINS,;
				(cTMP)->CSLL,;
				(cTMP)->DESCONTO,;
				(cTMP)->MULTA,;
				(cTMP)->TXPERM,;
				(cTMP)->NSU})


			(cTMP)->(dbSkip())
		EndDo

		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)
		If ApOleClient("MSEXCEL")
			//Abrindo o excel e abrindo o arquivo xml
			oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
			oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
			oExcel:SetVisible(.T.)              //Visualiza a planilha
			oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
		EndIf
	Else
		FwAlertInfo("Não existem registros para ser exportado.","Aviso")
	EndIf
	(cTMP)->(dbCloseArea())

return()
