#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

#DEFINE QUANT_COLUNAS       5

#DEFINE POS_CENTROCUSTO     01
#DEFINE POS_FILIALPROTH     02
#DEFINE POS_ADDRESSID       03
#DEFINE POS_CBR00           04
#DEFINE POS_CNPJ            05

//-----------------------------------------------------------------
/*/{Protheus.doc} fImpZZC
Rotina responsável pela importação de um CSV
para inclusão da tabela ZZC

@type		Function
@author 	Julio Lisboa
@since 		21/01/2021
/*/
//-----------------------------------------------------------------
user function fImpZZC()

	private cArquivo        := ""

	cArquivo := cGetFile("Arquivos CSV | *.csv", "Selecione o arquivo",,  "",.t.,GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE )

	if !empty(cArquivo) .and. file(cArquivo)
		Processa( {|| fProcess()} )
	else
		MsgAlert("Arquivo [" + cArquivo + "] não localizado.",FunDesc())
	endif

return

//-----------------------------------------------------------------
static function fProcess()

	local nHandle       := 0
	local nTotReg       := 0
	local cErro         := ""
	local cLinha        := ""
	local aDados        := {}
	local lRet          := .T.
	local aAreaZZC      := ZZC->(GetArea())

	local cCentroCusto      := ""
	local cFilialProtheus   := ""
	local cAddressID        := ""
	local cCodigoCBR        := ""
	local cCNPJ             := ""

	private _nLinha         := 0
	private lApenasNovos    := getnewpar("ZZ_LZZCNEW",.T.)
	private nQtdIncluidos   := 0

	nHandle	:= FT_FUSE(cArquivo)
	nTotReg	:= FT_FLASTREC()
	FT_FGOTOP()

	ProcRegua(nTotReg)

	//backupArquivo(cArquivo)

	BEGIN TRANSACTION

		While !FT_FEOF()
			IncProc("Processando a linha " + cValToChar(_nLinha) + " de " + cValToChar(nTotReg) + "...")
			_nLinha++
			cLinha      := FT_FREADLN()

			If _nLinha == 1
				lRet        := .F.
			Else
				lRet        := .T.
			EndIf

			if lRet
				aDados      := StrTokArr(cLinha, ";")

				if Len(aDados) < QUANT_COLUNAS
					cErro       := "O arquvio deve ter [" + cValToChar(QUANT_COLUNAS) + "] colunas"
					lRet        := .F.
				endif
			endif

			If lRet
				cCentroCusto        := AllTrim(aDados[POS_CENTROCUSTO])
				cFilialProtheus     := AllTrim(aDados[POS_FILIALPROTH])
				cAddressID          := Upper( AllTrim(aDados[POS_ADDRESSID]) )
				cCodigoCBR          := Upper( AllTrim(aDados[POS_CBR00]) )
				cCNPJ               := AllTrim(aDados[POS_CNPJ])

				ZZC->(DbSetOrder(1)) //ZZC_FILIAL+ZZC_CCUSTO
				lRet        := existReg("CTT","CTT_CUSTO",cCentroCusto)
				If !lRet
					cErro           := "Centro de Custo [" + cCentroCusto + "] não localizado - linha [" + cValToChar(_nLinha) + "]"
					exit
				endif

				lRet        := existReg("SYS_COMPANY","M0_CODFIL",cFilialProtheus,.F.)
				If !lRet
					cErro           := "Filial [" + cFilialProtheus + "] não localizada - linha [" + cValToChar(_nLinha) + "]"
					exit
				endif

				lRet        := existReg("SYS_COMPANY","M0_CGC",cCNPJ,.F.)
				If !lRet
					cErro           := "CNPJ [" + cCNPJ + "] não localizado - linha [" + cValToChar(_nLinha) + "]"
					exit
				endif

				If lRet
					lRet    := atualizaZZC( cCentroCusto , cFilialProtheus , cAddressID, cCodigoCBR , cCNPJ )

					if !lRet
						DisarmTransaction()
						exit
					endif
				EndIf
			EndIf

			FT_FSKIP()
		EndDo
		FT_FUSE()

	END TRANSACTION

	If !lRet
		MsgAlert(cErro,FunDesc())
	Else
        if lApenasNovos
		    MsgAlert( cValToChar(nQtdIncluidos) + " De/Para incluido(s).",FunDesc())
        else
		    MsgAlert( cValToChar(nQtdIncluidos) + " De/Para incluido(s)/alterado(s).",FunDesc())
        endif
	EndIf

	RestArea(aAreaZZC)

return

//-----------------------------------------------------------------
static function atualizaZZC( cCentroCusto , cFilialProtheus , cAddressID, cCodigoCBR , cCNPJ )

	local cQuery    := ""
	local cAlias    := GetNextAlias()
	local nRecno    := 0
	local aAreaZZC  := ZZC->(GetArea())
	local lExiste   := .F.
	local lContinua := .F.

	cQuery      += "SELECT " + CRLF
	cQuery      += "    ZZC.R_E_C_N_O_ REC_ZZC " + CRLF
	cQuery      += "FROM " + CRLF
	cQuery      += "    " + RetSqlTab("ZZC") + CRLF
	cQuery      += "WHERE " + CRLF
	cQuery      += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery      += "    AND ZZC_CCUSTO = '" + cCentroCusto + "' " + CRLF
	cQuery      += "    AND ZZC_FILCLI = '" + cFilialProtheus + "' " + CRLF
	cQuery      += "    AND ZZC_ID = '" + cAddressID + "' " + CRLF
	//cQuery      += "    AND ZZC_LE = '" + cCodigoCBR + "' " + CRLF
	cQuery      += "    AND ZZC_CNPJ = '" + cCNPJ + "' " + CRLF
	cQuery      += "" + CRLF

	TcQuery cQuery new Alias &cAlias

	If (cAlias)->(!Eof())
		nRecno      := (cAlias)->REC_ZZC
		lExiste     := nRecno > 0
	EndIf

	ZZC->(DbSetOrder(1)) //ZZC_FILIAL+ZZC_CCUSTO
	If lExiste
		ZZC->(DbGoTo( nRecno ))
	EndIf

	if lApenasNovos
		lContinua   := !lExiste
	else
		lContinua   := .T.
	endif

	if lContinua
		If RecLock("ZZC",!lExiste)
			ZZC->ZZC_CCUSTO     := cCentroCusto
			ZZC->ZZC_FILCLI     := cFilialProtheus
			ZZC->ZZC_ID         := cAddressID
			ZZC->ZZC_LE         := cCodigoCBR
			ZZC->ZZC_CNPJ       := cCNPJ
			ZZC->(MsUnLock())

			nQtdIncluidos++
		EndIf
	EndIf

	(cAlias)->(DbCloseArea())

	RestArea(aAreaZZC)

return .t.

//-----------------------------------------------------------------
static function existReg(cTabela,cCampo,cValor,lSqlName)

	Local lRet			:= .F.
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()

	default cTabela     := ""
	default cCampo      := ""
	default cValor      := ""
	default lSqlName    := .T.

	If Empty( cValor )
		lRet	:= .T.
	Else
		cQuery		+= "SELECT " + CRLF
		cQuery		+= "	COUNT(*) QTD " + CRLF
		cQuery		+= "FROM " + CRLF

		If lSqlName
			cQuery		+= "	" + RetSqlTab( cTabela ) + CRLF
		Else
			cQuery		+= "	" + cTabela + CRLF
		EndIf

		cQuery		+= "WHERE " + CRLF
		cQuery		+= "	D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery		+= "	" + cCampo + " = '" + cValor + "' " + CRLF
		cQuery		+= "" + CRLF

		TcQuery cQuery New Alias &cAlias
		If (cAlias)->(!Eof())
			lRet		:= (cAlias)->QTD > 0
		EndIf

		(cAlias)->(DbCloseArea())
	EndIf

Return lRet

/*
//-----------------------------------------------------------------
Static Function geraLog( cMensagem )

    Conout("[" + DTOC(Date()) + " " + Time() + "] fImpZZC - " + cMensagem )

Return
*/
