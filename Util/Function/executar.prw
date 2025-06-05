#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EXECUTAR
Tela para execução de linhas de comando.

@author Ivan Haponczuk
@since 29/11/2017
@version 1.0

@return Nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
User Function EXECUTAR()

	Local oMdl := Nil
	Local oDlg := Nil
	Local nAlt := 100
	Local nLar := 300

	Local oFnt01 := TFont():New( "Arial",, 16,, .F.,,,,, .F. )

	Local cCmb := ""
	Local cAux := ""
	Local cRun := Space(300)
	Local aHis := LerHis()

	Private lErr := .F.

	oMdl := FWDialogModal():New()
	oMdl:SetTitle( "Executar" )
	oMdl:SetSize( nAlt, nLar )
	oMdl:SetBackground( .T. )
	oMdl:SetEscClose( .T. )
	oMdl:CreateDialog()

	oDlg := oMdl:getPanelMain()
	nAlt := ( oDlg:nHeight / 2 )
	nLar := ( oDlg:nWidth / 2 )

	oSay01 := tSay():New( 010, 010, {|| "Digite uma linha de código ou uma função que deseja executar." }, oDlg,, oFnt01,,,, .T.,,, 300, 020 )

	oBmp02 := TBitmap():New( 027, 010, 15, 15, "PARAMETROS",,, oDlg,,,,,,,,, .T. )

	oCmb01 := tComboBox():New( 025, 030, bSetGet( cCmb ), aHis, nLar-40, 015, oDlg,, {|| cRun := PadR( cCmb, 300 ) },,,, .T. )
	oCmb01:SetHeight( 34 )

	@025,030 MSGET cRun SIZE nLar-51,015 FONT oFnt01 OF oDlg PIXEL

	oFormBar := FWFormBar():New( oMdl:oFormBar:oOwner )
	oFormBar:AddClose( {|| oMdl:oOwner:End() }, "Cancelar", "" )
	oFormBar:AddOK( {|| cAux := cRun, AddHis( @aHis, cRun ), GrvHis( aHis, 30 ), Execute( cRun ), oCmb01:SetItems( aHis ), oCmb01:Select( 1 ), cRun := cAux }, "Executar", "" )
	oMdl:oFormBar := oFormBar

	oMdl:Activate()

Return Nil

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Execute
Executa como comando uma string informada.

@author Ivan Haponczuk
@since 29/11/2017
@version 1.0

@param cRun, character, Texto de comando a ser executado.

@return undefined, Retorno do comando executado.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function Execute( cRun, aHis )

	Local xReturn := ""
	Local oError  := ErrorBlock( {|e| Error( e ) })

	Default cRun := ""

	lErr := .F.

	BEGIN SEQUENCE

		Processa( {|| xReturn := &( cRun ) }, "Executando", "Executando linha de comando, aguarde...", .F. )

	END SEQUENCE

	//oBlk:= ErrorBlock( oError )

Return ( xReturn )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Error
Tela de apresentação do erro enviado.

@author Ivan Haponczuk
@since 29/11/2017
@version 1.0

@param oError, object, Objeto de erro do sistema.

@return Nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function Error( oError )

	MsgAlert( "Mensagem de Erro: " + chr(10) + oError:Description )
	lErr := .T.

Return Nil

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddHis
Adiciona uma execução no array de histórico de execuções.

@author Ivan Haponczuk
@since 02/08/2018
@version 1.0

@param aHis, array, Vetor contendo a lista de execuções.
@param cRun, character, Execução a ser adicionada a lista.

@return array, Vetor de histórico de execuções com a execução informada adicionada.
/*/
//---------------------------------------------------------------------------------------------------------------------------------------------
Static Function AddHis( aHis, cRun )

	Local nX   := 0
	Local aNew := {}

	cRun := AllTrim( cRun )
	aAdd( aNew, "" )
	aAdd( aNew, cRun )

	For nX := 1 To Len( aHis )
		If ( !Empty( aHis[nX] ) .And. !( aHis[nX] == cRun ) )
			aAdd( aNew, aHis[nX] )
		EndIf
	Next nX

	aHis := aNew

Return ( aHis )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetHisArq
Retorna o endereço e nome do arquivo de histórico de execuções.

@author Ivan Haponczuk
@since 02/08/2018
@version 1.0

@return character, Endereço e nome do arquivo.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetHisArq()

	Local cArq := ""

	cArq := GetTempPath()
	cArq += "MCFG001"

Return ( cArq )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvHis
Grava o histórico de execuções em arquivo.

@author Ivan Haponczuk
@since 02/08/2018
@version 1.0

@param aHis, array, Vetor contendo a lista de execuções.
@param nQnt, number, Quantidade de últimas execuções a serem gravadas no arquivo.

@return Nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GrvHis( aHis, nQnt )

	Local nX   := 0
	Local nHnd := 0
	Local cArq := GetHisArq()

	If File( cArq )
		FErase( cArq )
	EndIf

	nHnd := FCreate( cArq )
	If ( nHnd < 0 )
		MsgAlert( "Erro ao criar arquivo: " + Str( FError() ) )
		Return Nil
	EndIf

	If ( Len( aHis ) < nQnt )
		nQnt := Len( aHis )
	EndIf

	For nX := 1 To nQnt
		FWrite( nHnd, aHis[nX] + CRLF )
	Next nX

	FClose( nHnd )

Return Nil

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvHis
Le o arquivo de histórico de execuções e o retorna em um array.

@author Ivan Haponczuk
@since 02/08/2018
@version 1.0

@return array, Array com o histórico de execuções.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function LerHis()

	Local aHis := {}
	Local cArq := GetHisArq()

	If File( cArq )

		FT_FUse( cArq )
		FT_FGoTop()

		While !FT_FEOF()
			aAdd( aHis, FT_FReadLn() )
			FT_FSkip()
		EndDo

		FT_FUse()

	EndIf

	If Len( aHis ) == 0
		aAdd( aHis, "" )
	EndIf

Return ( aHis )
