#include "totvs.ch"
#include "topconn.ch"
#include 'tbiconn.ch'


/*/{protheus.doc}EnvPC
Envia emails dos pedidos de compra para os fornecedores conforme parametros
@type function
@author Sergio Braz
@since 03/02/2019
/*/

static lEurofins := !("YMLLLM" $ GetEnvServer())


User Function EnvPC
	Local oDlg   := IIf(Type("cFilAnt")=="U",RpcSetEnv("01","0100"),Nil)
	Local oNo	 := LoadBitmap( GetResources(), "LBNO" )
	Local oOk	 := LoadBitmap( GetResources(), "LBOK" )
	Local aCabec := {"Ok","Filial","Pedido","PC Coupa","Emissão","Fornecedor","Loja","Razão Social","Enviado","Email"}
	Private aDados := {}
	Private oBrowse
	If !AskMe()
		Return
	Endif

	Processa({|| GetData()},"Aguarde! Gerando dados a processar.")

	If !Empty(aDados)
		Define MsDialog oDlg From 0,0 to 500,800 Pixel Font tFont():New("Arial",,14)
		oBrowse := TCBrowse():New(01,01,400,230,,aCabec,{10,20,30,40,30,30,20,100,10,100},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oBrowse:SetArray(aDados)
		oBrowse:bLine := {|| {IIf(aDados[oBrowse:nAt,1],oOk,oNo),aDados[oBrowse:nAt,2],aDados[oBrowse:nAt,3],aDados[oBrowse:nAt,4],aDados[oBrowse:nAt,5],aDados[oBrowse:nAt,6],aDados[oBrowse:nAt,7],aDados[oBrowse:nAt,8],aDados[oBrowse:nAt,9],aDados[oBrowse:nAt,10]} }
		oBrowse:bLDblClick   := {|| muda()}
		@ 231,001 button "Marca Todos"      of oDlg Size 200,10 Pixel Action Marca(.t.)	Font tFont():New("Arial",,18)
		@ 231,200 button "Inverte"          of oDlg Size 200,10 Pixel Action Marca(.f.)	Font tFont():New("Arial",,18)
		@ 241,001 button "Enviar por email" of oDlg Size 200,10 Pixel Action (Envia(),oDlg:End()) Font tFont():New("Arial",,18)
		@ 241,200 button "Cancelar"         of oDlg Size 200,10 Pixel Action oDlg:End() Font tFont():New("Arial",,18)
		Activate MsDialog oDlg Centered
	Else
		MsgInfo("<h5>Não há dados a processar com esses parâmetros.</h5>",FunName())
	Endif
Return

Static Function GetData
	BeginSql Alias "C7"
		Select Count(*) Contador
		From %Table:SC7% SC7
		Where SC7.%NotDel% and C7_ENCER<>'E' and  C7_QUJE=0 and C7_RESIDUO=' ' and C7_CONAPRO='L' and
			 C7_FILIAL between %Exp:MV_PAR01% and %Exp:MV_PAR02% and
			 C7_NUM  between %Exp:MV_PAR03% and %Exp:MV_PAR04% and
			 C7_EMISSAO between %Exp:MV_PAR05% and %Exp:MV_PAR06% and
			 C7_ZZMAIL <> %Exp:IIf(Left(MV_PAR07,1)=="A","_",IIf(Left(MV_PAR07,1)=="S","N","S"))%
	EndSql
	ProcRegua(C7->Contador)
	C7->(DbCloseArea())
	BeginSql Alias "C7"
		Column C7_EMISSAO as Date
		Select DISTINCT C7_FILIAL,C7_NUM, C7_FORNECE, C7_LOJA, C7_EMISSAO, C7_ZZMAIL,C7_ZZCCOUP
		From %Table:SC7% SC7
		Where SC7.%NotDel% and C7_ENCER<>'E' and  C7_QUJE=0 and C7_RESIDUO=' ' and C7_CONAPRO='L' and
			 C7_FILIAL between %Exp:MV_PAR01% and %Exp:MV_PAR02% and
			 C7_NUM  between %Exp:MV_PAR03% and %Exp:MV_PAR04% and
			 C7_EMISSAO between %Exp:MV_PAR05% and %Exp:MV_PAR06% and
			 C7_ZZMAIL <> %Exp:IIf(Left(MV_PAR07,1)=="A","_",IIf(Left(MV_PAR07,1)=="S","N","S"))%
		Order By C7_FILIAL, C7_NUM
	EndSql
	While C7->(!Eof())
		lPula := .f.
		BeginSql Alias "NOTLIB"
			Select Count(*) Contador
			From %Table:SC7% SC7
			Where SC7.%NotDel% and C7_FILIAL = %Exp:C7->C7_FILIAL% and C7_NUM=%Exp:C7->C7_NUM% and C7_ENCER<>'E' and  C7_QUJE=0 and C7_RESIDUO=' ' and C7_CONAPRO<>'L' and
				 C7_FILIAL between %Exp:MV_PAR01% and %Exp:MV_PAR02% and
				 C7_NUM  between %Exp:MV_PAR03% and %Exp:MV_PAR04% and
				 C7_EMISSAO between %Exp:MV_PAR05% and %Exp:MV_PAR06% and
				 C7_ZZMAIL <> %Exp:IIf(Left(MV_PAR07,1)=="A","_",IIf(Left(MV_PAR07,1)=="S","N","S"))%
		EndSql
		If NOTLIB->Contador==0
			Posicione("SA2",1,xFilial("SA2")+C7->(C7_FORNECE+C7_LOJA),"")
			C7->(AADD(aDados,{.t.,C7_FILIAL,C7_NUM,C7_ZZCCOUP,C7_EMISSAO,C7_FORNECE,C7_LOJA,SA2->A2_NOME,C7_ZZMAIL,SA2->A2_ZZPCEML}))
		Endif
		NOTLIB->(DbCloseArea())
		C7->(DbSkip())
		IncProc()
	End
	C7->(DbCloseArea())
Return

Static Function Marca(lTipo)
	Local i
	For i:=1 to Len(aDados)
		aDados[i,1] := IIf(lTipo,.t.,!aDados[i,1])
	Next
Return

Static Function Envia
	Local i
	Local cFilOld := cFilAnt
	Private nPosPC
	For i:=1 to Len(aDados)
		If aDados[i,1]
			nPosPC := i
			cFilAnt := aDados[i,2]
			Posicione("SM0",1,cEmpAnt+cFilAnt,"")
			Posicione("SC7",1,xFilial("SC7")+aDados[i,3],"")
			u_pedidoc("SC7",SC7->(Recno()),6)
		Endif
	Next
	cFilAnt := cFilOld
	Posicione("SM0",1,cEmpAnt+cFilAnt,"")
Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function AskMe
	Local aPergs   := {}
	local dDataDe  := MonthSub(Date(),3) as date
	local dDataAte := Date()             as date

	aadd(aPergs, {1, "Filial de"  , Space(Len("A1_FILIAL")), "@!"                 , '.T.', "SM0", '.T.', 60, .F.})
	aadd(aPergs, {1, "Filial até" , Space(Len("A1_FILIAL")), "@!"                 , '.T.', "SM0", '.T.', 60, .T.})
	aadd(aPergs, {1, "Pedido de"  , CriaVar("C7_NUM",.F.)  , "@!"                 , '.T.', "SC7", '.T.', 60, .F.})
	aadd(aPergs, {1, "Pedido até" , "ZZZZZZ"               , "@!"                 , '.T.', "SC7", '.T.', 60, .T.})
	aadd(aPergs, {1, "Emissão de" , dDataDe                , ""                   , '.T.', ""   , '.T.', 60, .F.})
	aadd(aPergs, {1, "Emissão até", dDataAte               , ""                   , '.T.', ""   , '.T.', 60, .T.})
	aadd(aPergs, {2, "Enviados"   , "Ambos"                , {"Ambos","Não","Sim"}, 50   , 't.' , .t.})
Return ParamBox(aPergs,"Parametros",{})
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function muda
	If oBrowse:ColPos ==1
		aDados[oBrowse:nAt,1] := !aDados[oBrowse:nAt,1]
	ElseIf oBrowse:ColPos==10
		aDados[oBrowse:nAt,10] := FwInputBox("Email",aDados[oBrowse:nAt,10])
	Endif
	oBrowse:Refresh()
return


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
user function NewEnvPC()

	local aArea      := GetArea()
	local aColumns   := {}
	local cTitulo    := ""

	private cTempTable := ""
	private oTempTable := Nil
	private cMark    := GetMark()
	private oMark

	If !AskMe()
		Return
	Endif


	//Constrói estrutura da temporária
	cTempTable := fBuildTmp(@oTempTable)

	dbSelectArea(cTempTable)
	(cTempTable)->( dbSetOrder(1) )
	(cTempTable)->( dbGoTop() )
	lAcao := .T.

	aAreaX := FwGetArea()
	Processa({|| GetReg()},"Aguarde! Gerando dados a processar.")
	FwRestArea(aAreaX)

	//Constrói estrutura das colunas do FWMarkBrowse
	aColumns := fBuildColumns()
	aSeek := {}
	aadd(aSeek, {"FILIAL + PEDIDO"    , {{"",GetSx3Cache("C7_NUM","X3_TIPO") , GetSx3Cache("C7_NUM","X3_TAMANHO") , GetSx3Cache("C7_NUM","X3_DECIMAL"),"PEDIDO" ,"@!"}}})
	aadd(aSeek, {"FILIAL + COUPA"     , {{"",GetSx3Cache("C7_ZZCCOUP","X3_TIPO") , GetSx3Cache("C7_ZZCCOUP","X3_TAMANHO") , GetSx3Cache("C7_ZZCCOUP","X3_DECIMAL"),"COUPA" ,"@!"}}})
	aadd(aSeek, {"FILIAL + FORNECEDOR", {{"",GetSx3Cache("A2_COD","X3_TIPO") , GetSx3Cache("A2_COD","X3_TAMANHO") , GetSx3Cache("A2_COD","X3_DECIMAL"),"FORNECEDOR" ,"@!"}}})
	aadd(aSeek, {"FILIAL + NOME"      , {{"",GetSx3Cache("A2_NOME","X3_TIPO") , GetSx3Cache("A2_NOME","X3_TAMANHO") , GetSx3Cache("A2_NOME","X3_DECIMAL"),"NOME" ,"@!"}}})


	//Criando o FWMarkBrowse
	oMark := FWMarkBrowse():New()
	oMark:SetAlias(cTempTable)
	oMark:SetDescription(cTitulo)

	oMark:oBrowse:SetDBFFilter(.T.)
	oMark:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
	oMark:oBrowse:SetFixedBrowse(.T.)
	oMark:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	oMark:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse

	oMark:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
	oMark:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse

	oMark:SetFieldMark( 'OK' )    //Campo que será marcado/descmarcado
	oMark:SetTemporary(.T.)



	//Legendas
	// oMark:AddLegend( "alltrim(STATUS_INC) $ '123' .or. alltrim(STATUS_ALT) $ '123'"  , "BR_BRANCO"   , "Registro sem Flag Envio "  ,1 )
	oMark:AddLegend( "alltrim(EXCLUIDO) == 'SIM' "  , "BR_CANCEL"   , "Registro Excluido "              ,1 )
	oMark:AddLegend( "alltrim(STATUS_INC) == '1' "  , "BR_AMARELO"  , "Registro Inclusao Não Enviado "  ,1 )
	oMark:AddLegend( "alltrim(STATUS_INC) == '2' "  , "BR_PRETO"    , "Erro Envio Inclusao"             ,1 )
	oMark:AddLegend( "alltrim(STATUS_ALT) == '1' "  , "BR_AZUL"     , "Registro Alteracao Não Enviado"  ,2 )
	oMark:AddLegend( "alltrim(STATUS_ALT) == '2' "  , "BR_MARROM"   , "Erro Envio Alteracao"            ,2 )
	oMark:AddLegend( "alltrim(STATUS_INC) == '3' .or. alltrim(STATUS_ALT) == '3' "  , "BR_VERDE"   , "E-Mail Enviado"            ,2 )

	//Colunas
	oMark:SetColumns(aColumns)

	//Inicializa com todos registros marcados
	oMark:AllMark()

	oMark:AddButton( "Reenviar E-Mail", {|| Processa({|| EnviaPC()},"Aguarde! Enviando E-Mail.") } )
	oMark:AddButton( "Log Envio", {|| U_LogEMPC((cTempTable)->FILIAL,(cTempTable)->PEDIDO)} )
	oMark:AddButton( "Atualizar E-Mail", {|| Processa({|| AtuEmail()},"Aguarde! Atualizando E-Mail.") } )
	oMark:AddButton( "Descartar Alteracao", {|| Processa({|| DescAlt()},"Aguarde! Atualizando Registros.") } )
	oMark:Activate()



	oTempTable:Delete()
	oMark:DeActivate()
	FreeObj(oTempTable)
	FreeObj(oMark)
	RestArea( aArea )
Return
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*/{Protheus.doc} fBuildTmp
Constrói tabela temporária.
@type function
@version 12.1.33
@author adm_tla8
@since 20/02/2023
@param oTempTable, object, Endereço do content da temporária
@return character, nome da tabela criada
/*/
Static Function fBuildTmp(oTempTable)
	Local cAliasTemp := "ZMARC_"+FWTimeStamp(1)
	Local aFields    := {}

	//Monta estrutura de campos da temporária
	aadd(aFields, {"OK"        , GetSx3Cache("C7_OK","X3_TIPO")     , GetSx3Cache("C7_OK","X3_TAMANHO")     , GetSx3Cache("C7_OK","X3_DECIMAL")})
	aadd(aFields, {"FILIAL"    , GetSx3Cache("C7_FILIAL","X3_TIPO") , GetSx3Cache("C7_FILIAL","X3_TAMANHO") , GetSx3Cache("C7_FILIAL","X3_DECIMAL")})
	aadd(aFields, {"PEDIDO"    , GetSx3Cache("C7_NUM","X3_TIPO")    , GetSx3Cache("C7_NUM","X3_TAMANHO")    , GetSx3Cache("C7_NUM","X3_DECIMAL")})
	aadd(aFields, {"COUPA"     , GetSx3Cache("C7_ZZCCOUP","X3_TIPO"), GetSx3Cache("C7_ZZCCOUP","X3_TAMANHO"), GetSx3Cache("C7_ZZCCOUP","X3_DECIMAL")})
	aadd(aFields, {"EMISSAO"   , GetSx3Cache("C7_EMISSAO","X3_TIPO"), GetSx3Cache("C7_EMISSAO","X3_TAMANHO"), GetSx3Cache("C7_EMISSAO","X3_DECIMAL")})
	aadd(aFields, {"FORNECEDOR", GetSx3Cache("C7_FORNECE","X3_TIPO"), GetSx3Cache("C7_FORNECE","X3_TAMANHO"), GetSx3Cache("C7_FORNECE","X3_DECIMAL")})
	aadd(aFields, {"LOJA"      , GetSx3Cache("C7_LOJA","X3_TIPO")   , GetSx3Cache("C7_LOJA","X3_TAMANHO")   , GetSx3Cache("C7_LOJA","X3_DECIMAL")})
	aadd(aFields, {"NOME"      , GetSx3Cache("A2_NOME","X3_TIPO")   , GetSx3Cache("A2_NOME","X3_TAMANHO")   , GetSx3Cache("A2_NOME","X3_DECIMAL")})
	aadd(aFields, {"EMAIL"     , GetSx3Cache("A2_ZZPCEML","X3_TIPO"), GetSx3Cache("A2_ZZPCEML","X3_TAMANHO"), GetSx3Cache("A2_ZZPCEML","X3_DECIMAL")})
	aadd(aFields, {"COMPRADOR" , GetSx3Cache("ZH_COMPRAD","X3_TIPO"), GetSx3Cache("ZH_COMPRAD","X3_TAMANHO"), GetSx3Cache("ZH_COMPRAD","X3_DECIMAL")})
	aadd(aFields, {"OPERACAO"  , 'C'                                , 10                                    , 0})
	aadd(aFields, {"STATUS_INC", 'C'                                , 1                                     , 0})
	aadd(aFields, {"STATUS_ALT", 'C'                                , 1                                     , 0})
	aadd(aFields, {"EXCLUIDO"  , 'C'                                , 3                                     , 0})

	oTempTable:= FWTemporaryTable():New(cAliasTemp)
	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("01", {"PEDIDO"} )
	oTempTable:AddIndex("02", {"COUPA"} )
	oTempTable:AddIndex("03", {"FORNECEDOR","LOJA"} )
	oTempTable:AddIndex("04", {"NOME"} )
	oTempTable:Create()

Return oTempTable:GetAlias()
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*/{Protheus.doc} fBuildColumns
Constrói estrutura das colunas que serão apresentadas na tela.
@type function
@version 12.1.33
@author adm_tla8
@since 20/02/2023
@return array, colunas a serem utilizadas
/*/
Static Function fBuildColumns()

	Local nX       := 0
	Local aColumns := {}
	Local aStruct  := {}

	aadd(aStruct, {"OK"        , "OK"               , GetSx3Cache("C7_OK","X3_TIPO")     , GetSx3Cache("C7_OK","X3_TAMANHO")     , GetSx3Cache("C7_OK","X3_DECIMAL")})
	aadd(aStruct, {"FILIAL"    , "FILIAL"           , GetSx3Cache("C7_FILIAL","X3_TIPO") , GetSx3Cache("C7_FILIAL","X3_TAMANHO") , GetSx3Cache("C7_FILIAL","X3_DECIMAL")})
	aadd(aStruct, {"PEDIDO"    , "PEDIDO"           , GetSx3Cache("C7_NUM","X3_TIPO")    , GetSx3Cache("C7_NUM","X3_TAMANHO")    , GetSx3Cache("C7_NUM","X3_DECIMAL")})
	aadd(aStruct, {"COUPA"     , "PEDIDO COUPA"     , GetSx3Cache("C7_ZZCCOUP","X3_TIPO"), GetSx3Cache("C7_ZZCCOUP","X3_TAMANHO"), GetSx3Cache("C7_ZZCCOUP","X3_DECIMAL")})
	aadd(aStruct, {"EMISSAO"   , "DT EMISSAO"       , GetSx3Cache("C7_EMISSAO","X3_TIPO"), GetSx3Cache("C7_EMISSAO","X3_TAMANHO"), GetSx3Cache("C7_EMISSAO","X3_DECIMAL")})
	aadd(aStruct, {"FORNECEDOR", "CODIGO"           , GetSx3Cache("C7_FORNECE","X3_TIPO"), GetSx3Cache("C7_FORNECE","X3_TAMANHO"), GetSx3Cache("C7_FORNECE","X3_DECIMAL")})
	aadd(aStruct, {"LOJA"      , "LOJA"             , GetSx3Cache("C7_LOJA","X3_TIPO")   , GetSx3Cache("C7_LOJA","X3_TAMANHO")   , GetSx3Cache("C7_LOJA","X3_DECIMAL")})
	aadd(aStruct, {"NOME"      , "FORNECEDOR"       , GetSx3Cache("A2_NOME","X3_TIPO")   , GetSx3Cache("A2_NOME","X3_TAMANHO")   , GetSx3Cache("A2_NOME","X3_DECIMAL")})
	aadd(aStruct, {"EMAIL"     , "E-MAIL FORNECEDOR", GetSx3Cache("A2_ZZPCEML","X3_TIPO"), GetSx3Cache("A2_ZZPCEML","X3_TAMANHO"), GetSx3Cache("A2_ZZPCEML","X3_DECIMAL")})
	aadd(aStruct, {"COMPRADOR" , "PUID COMPRADOR"   , GetSx3Cache("ZH_COMPRAD","X3_TIPO"), GetSx3Cache("ZH_COMPRAD","X3_TAMANHO"), GetSx3Cache("ZH_COMPRAD","X3_DECIMAL")})
	aadd(aStruct, {"OPERACAO"  , "OPERACAO"         , 'C'                                , 10                                    , 0})
	aadd(aStruct, {"EXCLUIDO"  , "EXCLUIDO"         , 'C'                                , 3                                    , 0})

	For nX := 2 To Len(aStruct)
		aAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(aStruct[nX][2])
		aColumns[Len(aColumns)]:SetType(aStruct[nX][3])
		aColumns[Len(aColumns)]:SetSize(aStruct[nX][4])
		aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][5])
	Next nX

Return aColumns


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------


Static Function GetReg()
	local cInInc := ""
	local cInAlt := ""

	If Left(MV_PAR07,1) == "A"
		cInInc := "1','2','3"
		cInAlt := "1','2','3"
	ElseIf Left(MV_PAR07,1) == "N"
		cInInc := "1','2"
		cInAlt := "1','2"
	Else
		cInInc := "3"
		cInAlt := "3"
	EndIf


	TcSQLExec(" TRUNCATE TABLE " + oTempTable:GetRealName() )

	BeginSql Alias "C7"
		Select Count(*) Contador
		From %Table:SC7% SC7
		Where SC7.%NotDel%
        and C7_ENCER<>'E'
        and C7_QUJE=0
        and C7_RESIDUO=' '
        and C7_CONAPRO='L'
        and C7_FILIAL between %Exp:MV_PAR01% and %Exp:MV_PAR02%
        and C7_NUM  between %Exp:MV_PAR03% and %Exp:MV_PAR04%
        and C7_EMISSAO between %Exp:MV_PAR05% and %Exp:MV_PAR06%
        and ((C7_XMODINC IN (%Exp:cInInc%)) or (C7_XMODALT in (%Exp:cInAlt%)))
	EndSql
	dbSelectArea("C7")
	ProcRegua(C7->Contador)
	C7->(DbCloseArea())

	BeginSql Alias "C7"

		Select DISTINCT C7_FILIAL
             , C7_NUM
             , C7_FORNECE
             , C7_LOJA
             , C7_EMISSAO
             , C7_ZZMAIL
             , C7_ZZCCOUP
             , A2_NOME
            , isnull((
				SELECT TOP 1 ZH_COMPRAD FROM %Table:SC7% SC7X
					inner join %Table:SB1% SB1 on B1_FILIAL = SC7X.C7_FILIAL and B1_COD = SC7X.C7_PRODUTO and SB1.%NotDel%
					 inner join %Table:SZH% SZH on ZH_CODIGO = B1_ZZSGPRD and SZH.%NotDel%
					WHERE SC7X.D_E_L_E_T_ = '' AND SC7X.C7_FILIAL = SC7.C7_FILIAL AND SC7X.C7_QUJE = 0 AND SC7X.C7_RESIDUO = '' AND SC7X.C7_CONAPRO = 'L'
					AND SC7X.C7_NUM = SC7.C7_NUM
					ORDER BY C7_ITEM
				),'') AS ZH_COMPRAD
             , A2_ZZPCEML
             , case when C7_XMODALT = '' then 'INCLUSAO' else 'ALTERACAO' end OPERACAO
             , C7_XMODINC
             , C7_XMODALT
             , CASE WHEN SC7.D_E_L_E_T_ = '*' THEN 'SIM' ELSE 'NAO' END AS EXCLUIDO
		From %Table:SC7% SC7
        inner join %Table:SA2% SA2 on A2_COD = C7_FORNECE and A2_LOJA = C7_LOJA and SA2.%NotDel%
		Where C7_ENCER <> 'E'
          and C7_QUJE = 0
          and C7_RESIDUO = ' '
          and C7_CONAPRO = 'L'
          and C7_FILIAL between %Exp:MV_PAR01% and %Exp:MV_PAR02%
          and C7_NUM  between %Exp:MV_PAR03% and %Exp:MV_PAR04%
          and C7_EMISSAO between %Exp:MV_PAR05% and %Exp:MV_PAR06%
          and ((C7_XMODINC IN (%Exp:cInInc%)) or (C7_XMODALT in (%Exp:cInAlt%)))
		Order By C7_FILIAL, C7_NUM
	EndSql

	dbSelectArea("C7")
	While C7->(!Eof())

		If( RecLock(cTempTable, .T.) )

			// (cTempTable)->OK         := "  "
			(cTempTable)->FILIAL     := C7->C7_FILIAL
			(cTempTable)->PEDIDO     := C7->C7_NUM
			(cTempTable)->COUPA      := C7->C7_ZZCCOUP
			(cTempTable)->EMISSAO    := sToD(C7->C7_EMISSAO)
			(cTempTable)->FORNECEDOR := C7->C7_FORNECE
			(cTempTable)->LOJA       := C7->C7_LOJA
			(cTempTable)->NOME       := alltrim(C7->A2_NOME)
			(cTempTable)->EMAIL      := alltrim(C7->A2_ZZPCEML)
			(cTempTable)->COMPRADOR  := alltrim(C7->ZH_COMPRAD)
			(cTempTable)->OPERACAO   := C7->OPERACAO
			(cTempTable)->STATUS_INC := C7->C7_XMODINC
			(cTempTable)->STATUS_ALT := C7->C7_XMODALT
			(cTempTable)->EXCLUIDO := C7->EXCLUIDO
			MsUnLock()
		EndIF

		C7->(DbSkip())
		IncProc()
	End
	C7->(DbCloseArea())


Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function EnviaPC()
	Local i
	local nX      := 0
	local cFilOld := cFilAnt
	private nPosPC

	aMvPar := {}

	For nX := 1 To 40
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
	Next nX


	(cTempTable)->( dbSetOrder(1) )
	(cTempTable)->( dbGoTop() )
	nCont:=0
	While !(cTempTable)->(Eof())
		If !Empty((cTempTable)->OK) //Se diferente de vazio, é porque foi marcado
			If (cTempTable)->EXCLUIDO != 'SIM'
				nPosPC := i
				cFilAnt := (cTempTable)->FILIAL

				Posicione("SM0",1,cEmpAnt+cFilAnt,"")
				dbSelectArea("SC7")
				SC7->(dbSetOrder(1), dbSeek(FWxFilial("SC7") + (cTempTable)->PEDIDO))
				u_pedidoc("SC7",SC7->(Recno()),6)
				nCont++
			Else
				FWAlertInfo("Pedido de compra [ " + (cTempTable)->PEDIDO + " ] excluído, o mesmo não será enviado por e-mail.","Aviso - Pedido Excluído")
			EndIf
		Endif
		(cTempTable)->( dbSkip() )
	EndDo

	If nCont == 0
		Alert("Selecione pelo menos um registro!")
		return
	Endif

	cFilAnt := cFilOld
	Posicione("SM0",1,cEmpAnt+cFilAnt,"")

	For nX := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
	Next nX

	Processa({|| GetReg()},"Aguarde! Gerando dados a processar.")
	(cTempTable)->(dbGoTop())
	oMark:Refresh(.T.)

Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function AtuEmail()

	Local E_Mail := ""
	E_Mail := FwInputBox("Informe E-Mail Fornecedor", E_Mail)

	If Empty(E_Mail)
		return(FWAlertInfo("E-Mail Fornecedor não preenchido.","Aviso"))
	EndIf
	// nPosAt := oMark:Obrowse:nAt
	(cTempTable)->( dbSetOrder(1) )
	(cTempTable)->( dbGoTop() )
	nCont:=0
	While !(cTempTable)->(Eof())
		If !Empty((cTempTable)->OK) //Se diferente de vazio, é porque foi marcado
			If (cTempTable)->EXCLUIDO == 'NAO'
				If Empty((cTempTable)->EMAIL)
					RecLock(cTempTable, .F.)
					(cTempTable)->EMAIL      := alltrim(E_Mail)
					(cTempTable)->(MsUnLock())
				EndIf
				nCont++
			Else
				FWAlertInfo("Pedido de compra [ " + (cTempTable)->PEDIDO + " ] excluído, não é possível fazer atualização do e-mail.","Aviso - Pedido Excluído")
			EndIf
		Endif
		(cTempTable)->( dbSkip() )
	EndDo

	If nCont == 0
		Alert("Selecione pelo menos um registro!")
		return
	Endif

	(cTempTable)->(dbGoTop())
	oMark:Refresh(.T.)
	// oMark:oBrowse:Refresh()
	// oMark:oBrowse:GoTop(.T.)
return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
user function retMailPC(cp_Filial, cp_Pedido)
	local nX       as numeric
	local aRetMail as array
	aRetMail := array(7)

	For nX := 1 to len(aRetMail)
		aRetMail[nX] := ""
	Next nX
	cTo := ""

	cQuery := ""
	cQuery += " SELECT C7_XEMSOLI AS SOLICIT, ZH_ENVFOR AS ENVFOR, A2_ZZPCEML AS FORNECE
	cQuery += "      , CASE WHEN ZH_FERIAS = 'S' AND cast(ZH_DFERIAS AS smalldatetime) >= getdate() then ZH_PUIDSUB ELSE '' END AS PUID_SUB
	cQuery += "      , ZH_PUIDCOM AS PUID_COMP, C7_ITEM AS ITEM "
	cQuery += " FROM " + RetSqlName("SC7") + " SC7
	cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_= ' '
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = C7_FILIAL AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_= ' '
	cQuery += " LEFT JOIN " + RetSqlName("SZH") + " SZH ON ZH_CODIGO = B1_ZZSGPRD AND SZH.D_E_L_E_T_= ' '
	cQuery += " WHERE  SC7.D_E_L_E_T_= ' ' AND C7_ENCER <> 'E' AND C7_QUJE = 0 AND C7_RESIDUO = ' '
	cQuery += " AND C7_CONAPRO = 'L'
	cQuery += " AND C7_FILIAL = '" + cp_Filial + "'
	cQuery += " AND C7_NUM = '" + cp_Pedido + "'
	cQuery += " GROUP BY C7_XEMSOLI, ZH_ENVFOR, A2_ZZPCEML, CASE WHEN ZH_FERIAS = 'S' AND cast(ZH_DFERIAS AS smalldatetime) >= getdate() then ZH_PUIDSUB ELSE '' END, ZH_PUIDCOM, C7_ITEM"
	cQuery += " ORDER BY C7_ITEM "
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	while (cTRB)->(!eof())

		If !lower(alltrim((cTRB)->SOLICIT)) $ aRetMail[1]
			aRetMail[1] += lower(alltrim((cTRB)->SOLICIT))+";"
		Endif

		If (cTRB)->ENVFOR == 'S'
			aRetMail[2] := "S"
			If !lower(alltrim((cTRB)->FORNECE)) $ aRetMail[3]
				aRetMail[3] += lower(alltrim((cTRB)->FORNECE))+";"
				// If IsInCallStack("U_NewEnvPC")
				// 	aRetMail[3] += lower(alltrim((cTempTable)->EMAIL))+";"
				// EndIf
			Endif
		EndIf

		If !Empty((cTRB)->PUID_SUB)
			PswOrder(2)
			If PswSeek((cTRB)->PUID_SUB,.T.)
				cIDX := PswID()
				If Empty(cTo)
					cTo := lower(alltrim(UsrRetMail(cIDX)))
				ENdIf
				cTo := lower(alltrim(UsrRetMail(cIDX)))
				If !cTo $ lower(aRetMail[5])
					aRetMail[5] += alltrim(cTo)+";"
				EndIf
			EndIf
		Else
			PswOrder(2)
			If PswSeek((cTRB)->PUID_COMP,.T.)
				cIDX := PswID()
				If Empty(cTo)
					cTo := lower(alltrim(UsrRetMail(cIDX)))
				EndIf
				cTo := lower(alltrim(UsrRetMail(cIDX)))
				If !cTo $ lower(aRetMail[4])
					aRetMail[4] += alltrim(cTo)+";"
					If Empty(aRetMail[6])
						aRetMail[6] := UsrFullName(alltrim(cIDX))+"<"+cTo+">"
						aRetMail[7] := cTo
					EndIf
				EndIf

			EndIf
		EndIf
		(cTRB)->(dbSkip())
	EndDo

	For nX := 1 to len(aRetMail)
		If Right(aRetMail[nX],2) == ';;'
			aRetMail[nX] := ALLTRIM(substr(aRetMail[nX],1,len(aRetMail[nX])-2))
		elseIf Right(aRetMail[nX],1) == ';'
			aRetMail[nX] := ALLTRIM(substr(aRetMail[nX],1,len(aRetMail[nX])-1))
		EndIf

		If Left(aRetMail[nX],1) == ';'
			aRetMail[nX] := ALLTRIM(substr(aRetMail[nX],2,len(aRetMail[nX])))
		EndIf
	Next nX


return(aRetMail)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function GrvLogPC(cp_Pedido, cp_PUID, cp_EMail, cp_Status, cp_Oper, cp_Observ)
	default cp_Pedido := ""
	default cp_PUID   := ""
	default cp_EMail  := ""
	default cp_Status := ""

	reclock("SZL",.T.)
	SZL->ZL_FILIAL := FWxFilial("SZL")
	SZL->ZL_PEDIDO := cp_Pedido
	SZL->ZL_SEQ    := SeqLoc(cp_Pedido)
	SZL->ZL_OPERAC := cp_Oper
	SZL->ZL_DATA   := Date()
	SZL->ZL_HORA   := Substr(Time(),1,5)
	SZL->ZL_STATUS := cp_Status
	SZL->ZL_PUID   := cp_PUID
	SZL->ZL_EMAIL  := cp_EMail
	SZL->ZL_OBS    := cp_Observ
	SZL->(MSUNLOCK())

return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
static function SeqLoc(cp_Pedido)
	local cSeq   as character
	local cQuery as character
	local aAreaX as array

	aAreaX := FWGetArea()

	cQuery := ""
	cQuery += "SELECT ISNULL(MAX(ZL_SEQ),'000') as SEQ FROM " + RetSqlName("SZL")
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += "   AND ZL_FILIAL = '" + FWxFilial("SZL") + "'"
	cQuery += "   AND ZL_PEDIDO = '" + cp_Pedido + "'"
	TcQuery cQuery New Alias(cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	cSeq := Soma1((cTRB)->SEQ)
	(cTRB)->(dbCloseArea())

	FwRestArea(aAreaX)


return(cSeq)

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function LogEMPC(cp_Filial, cp_Pedido)
	Local aBrowse     := {}
	Local oBrowse
	Local oBSair
	Local oBVisul
	Local oGroup1
	Private oNo       := LoadBitmap( GetResources(), 'F5_VERM' )
	Private oOK       := LoadBitmap( GetResources(), 'F5_VERD' )
	Default cp_Pedido := ""
	Static oDlgLog

	cQuery := ""
	cQuery += " SELECT *, R_E_C_N_O_ AS REC FROM " + RetSqlname("SZL") + " SZL"
	cQuery += "  WHERE SZL.D_E_L_E_T_ = '' "
	cQuery += "    AND SZL.ZL_FILIAL = '" + cp_Filial + "'"
	cQuery += "    AND SZL.ZL_PEDIDO = '" + cp_Pedido + "'"
	TcQuery cQuery New Alias (cTRB := GetNextAlias())

	dbSelectArea((cTRB))
	If (cTRB)->(!eof())
		while (cTRB)->(!eof())
			aAdd(aBrowse,{iif((cTRB)->ZL_STATUS=='1',.T.,.F.),;
				(cTRB)->ZL_FILIAL,;
				(cTRB)->ZL_PEDIDO,;
				(cTRB)->ZL_SEQ,;
				sTod((cTRB)->ZL_DATA),;
				(cTRB)->ZL_HORA,;
				X3Combo("ZL_STATUS",(cTRB)->ZL_STATUS),;
				(cTRB)->REC})
			(cTRB)->(dbSkip())
		EndDo
	Else
		Aadd(aBrowse,{.F.,"","","","","","",0})
	EndIf
	(cTRB)->(dbCloseArea())
	DEFINE MSDIALOG oDlgLog TITLE "Log Envio E-Mail Pedido de Compra" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

	@ 007, 005 GROUP oGroup1 TO 127, 295 PROMPT "    >>> LOG ENVIO DE E-MAIL <<<    " OF oDlgLog COLOR 0, 16777215 PIXEL

	@ 019, 010 LISTBOX oBrowse Fields HEADER "","FILIAL","PEDIDO","SEQ","DATA","HORA","STATUS" SIZE 280, 103 OF oDlgLog PIXEL ColSizes 50,50
	oBrowse:SetArray(aBrowse)
	oBrowse:bLine := {|| {;
		IIf(aBrowse[oBrowse:nAT,1],oOk,oNo),;
		aBrowse[oBrowse:nAt,2],;
		aBrowse[oBrowse:nAt,3],;
		aBrowse[oBrowse:nAt,4],;
		aBrowse[oBrowse:nAt,5],;
		aBrowse[oBrowse:nAt,6],;
		aBrowse[oBrowse:nAt,7];
		}}
	// DoubleClick event
	oBrowse:bLDblClick := {|| VisLog(aBrowse[oBrowse:nAt,8]),;
		oBrowse:DrawSelect()}

	@ 130, 005 BUTTON oBVisul   PROMPT "Visualizar Log" SIZE 074, 017 OF oDlgLog PIXEL
	@ 130, 220 BUTTON oBSair    PROMPT "Sair"           SIZE 074, 017 OF oDlgLog PIXEL

	oBVisul:bAction := {|| VisLog(aBrowse[oBrowse:nAt,8])}
	oBSair:bAction  := {|| oDlgLog:End()}

	ACTIVATE MSDIALOG oDlgLog CENTERED

Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function VisLog(np_Rec)
	local cCadBack := ""
	local aRotAux  := {}
	local aArea    := FwGetArea()
	local cFilOld  := cFilAnt


	If !Empty(np_Rec)
		cFilAnt := (cTempTable)->FILIAL
		Posicione("SM0",1,cEmpAnt+cFilAnt,"")
		If Type( "cCadastro" ) == "C"
			cCadBack := cCadastro
		EndIf

		If Type ("aRotina") == "A"
			aRotAux := aClone(aRotina)
		EndIf
		cCadastro := "Log Envio E-Mail Fornecedor"
		aRotina := { {  "Visualizar","AxVisual",0,2 } }

		dbSelectArea("SZL")
		SZL->(dbGoTo(np_Rec))
		AxVisual("SZL",np_Rec,2)

		cCadastro := cCadBack
		aRotina   := aClone(aRotAux)
		cFilAnt   := cFilOld
		Posicione("SM0",1,cEmpAnt+cFilAnt,"")
	EndIf
	FwRestArea(aArea)

return()

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function DescAlt()

	If FwAlertYesNo("Confirma descartar alterações para envio de e-mail dos pedidos selecionados?","Aviso")
		(cTempTable)->( dbSetOrder(1) )
		(cTempTable)->( dbGoTop() )
		nCont:=0
		While !(cTempTable)->(Eof())
			If !Empty((cTempTable)->OK) //Se diferente de vazio, é porque foi marcado

				cQuery := ""
				cQuery += "UPDATE " + RetSqlName("SC7") + " SET C7_XMODINC = '3', C7_XMODALT = '3', C7_ZZMAIL = 'S' FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = ''
				cQuery += " AND C7_FILIAL = '" + (cTempTable)->FILIAL + "'"
				cQuery += " AND C7_NUM = '" + (cTempTable)->PEDIDO + "'"
				cQuery += " AND C7_ENCER <> 'E' AND C7_QUJE = 0 AND C7_RESIDUO = ' '
				cQuery += " AND ((C7_XMODINC in ('1','2')) or (C7_XMODALT in ('1','2')))
				TcSqlExec(cQuery)

				nCont++
			Endif
			(cTempTable)->( dbSkip() )
		EndDo

		If nCont == 0
			Alert("Selecione pelo menos um registro!")
			return
		Endif

		Processa({|| GetReg()},"Aguarde! Gerando dados a processar.")
		(cTempTable)->(dbGoTop())
		oMark:Refresh(.T.)
		oMark:oBrowse:Refresh()
		oMark:oBrowse:GoTop(.T.)
	EndIf

return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function  SchedEnvPC()
	local cEmpX := "01"
	local cFilX := iif(lEurofins, "0100", "5000")
	local cTmpQry := GetNextAlias()

	cInInc := "1"
	cInAlt := "1','2"

	ConOut("Inicio da rotina de schedule Envio PC Fornecedor")
	ConOut("Inicio: "+cValToChar(Date())+" - "+cValToChar(Time()))
	Prepare Environment Empresa cEmpX Filial cFilX

	cFilOld  := cFilAnt
	cDataDe  := dTos(MonthSub(Date(),3) )
	cDataAte := dTos(dDataBase)
	BeginSql Alias cTmpQry

		Select DISTINCT C7_FILIAL AS FILIAL
             , C7_NUM AS PEDIDO
		From %Table:SC7% SC7
		Where SC7.%NotDel%
          and C7_ENCER <> 'E'
          and C7_QUJE = 0
          and C7_RESIDUO = ' '
          and C7_CONAPRO = 'L'
          and C7_EMISSAO between %Exp:cDataDe% and %Exp:cDataAte%
          and (C7_XMODINC IN (%Exp:cInInc%))
          and C7_XMODALT = ''
		Order By C7_FILIAL, C7_NUM
	EndSql
// and ((C7_XMODINC IN (%Exp:cInInc%)) or (C7_XMODALT in (%Exp:cInAlt%)))

	dbSelectArea((cTmpQry))
	While (cTmpQry)->(!Eof())

		cFilAnt := (cTmpQry)->FILIAL

		Posicione("SM0",1,cEmpAnt+cFilAnt,"")
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1), dbSeek(FWxFilial("SC7") + (cTmpQry)->PEDIDO))
		ConOut("Integrando Filial: " + FwXFilial("SC7"))
		ConOut("Integrando Pedido: " + (cTmpQry)->PEDIDO)
		u_pedidoc("SC7",SC7->(Recno()),6)

		(cTmpQry)->(dbSkip())
	EndDo



	cFilAnt := cFilOld
	Posicione("SM0",1,cEmpAnt+cFilAnt,"")

	Reset Environment
	ConOut("Termino da rotina de schedule EnviaPC.")
	ConOut("Fim: "+cValToChar(Date())+" - "+cValToChar(Time()))

return()

// -----------------------------------------------------------------------------------------------------------------------------------------------------------------

user function AtFlagPC(cp_Filial, cp_Pedido, cp_Status)


	If cp_Status == '1'
		cQuery := ""
		cQuery += "UPDATE " + RetSqlName("SC7") + " SET C7_XMODINC = '3' FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = ''
		cQuery += " AND C7_FILIAL = '" + cp_Filial + "'"
		cQuery += " AND C7_NUM = '" + cp_Pedido + "'"
		cQuery += " AND C7_ENCER <> 'E' AND C7_QUJE = 0 AND C7_RESIDUO = ' '
		cQuery += " AND C7_XMODINC != ''
		cQuery += " AND C7_XMODALT = ''
		TcSqlExec(cQuery)

		cQuery := ""
		cQuery += "UPDATE " + RetSqlName("SC7") + " SET C7_XMODINC = '3', C7_XMODALT = '3' FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = ''
		cQuery += " AND C7_FILIAL = '" + cp_Filial + "'"
		cQuery += " AND C7_NUM = '" + cp_Pedido + "'"
		cQuery += " AND C7_ENCER <> 'E' AND C7_QUJE = 0 AND C7_RESIDUO = ' '
		cQuery += " AND C7_XMODINC != ''
		cQuery += " AND C7_XMODALT != ''
		TcSqlExec(cQuery)
	Else

		cQuery := ""
		cQuery += "UPDATE " + RetSqlName("SC7") + " SET C7_XMODINC = '2' FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = ''
		cQuery += " AND C7_FILIAL = '" + cp_Filial + "'"
		cQuery += " AND C7_NUM = '" + cp_Pedido + "'"
		cQuery += " AND C7_ENCER <> 'E' AND C7_QUJE = 0 AND C7_RESIDUO = ' '
		cQuery += " AND C7_XMODINC != ''
		cQuery += " AND C7_XMODALT = ''
		TcSqlExec(cQuery)

		cQuery := ""
		cQuery += "UPDATE " + RetSqlName("SC7") + " SET C7_XMODINC = '3', C7_XMODALT = '2' FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = ''
		cQuery += " AND C7_FILIAL = '" + cp_Filial + "'"
		cQuery += " AND C7_NUM = '" + cp_Pedido + "'"
		cQuery += " AND C7_ENCER <> 'E' AND C7_QUJE = 0 AND C7_RESIDUO = ' '
		cQuery += " AND C7_XMODINC != ''
		cQuery += " AND C7_XMODALT != ''
		TcSqlExec(cQuery)

	EndIf

return()
