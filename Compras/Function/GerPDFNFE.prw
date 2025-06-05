#include 'totvs.ch'

/*/{Protheus.doc} GerPDFNfe
Rotina responsavel for gerar os arquivos do COUPA Digitalization
@type function
@version 12.1.33
@author Leandro Cesar
@since 03/11/2022
@param cp_ChvNfe, character, chave de acesso documento
@param lp_NFe, logical, informa se é uma NFe (.T.) ou DACTe
@return logical, retorna se o processo foi gerado corretamente
@obs DANFE = CHVNFE_DANFE.PDF - CTE = CHVNFE_DACTE.PDF
/*/
user function GerPDFNfe(cp_ChvNfe, lp_NFe)

	local cXML        := ""  as character
	local oBNfe       := ""  as character
	local oFWriter    := nil as object
	local cPasta      := ""  as character
	local cFile       := ""  as character
	local cNomRet     := ""  as character
	local lGerXML     := .F. as logical
	default lp_NFe    := .T.
	default cp_ChvNfe := ""

	cPasta    := "\coupa\INVOICE\attachments\"

	cp_ChvNfe := alltrim(cp_ChvNfe)
	cFile     := cp_ChvNfe + ".xml"
	lParam    := .F. // informa se abre o arquivo
	lDSetup   := .T. // desabilita o setup
	dbSelectArea("ZNF")
	dbSetOrder(1)
	If dbSeek(FwxFilial("ZNF") + cp_ChvNfe)

		If File(cFile)
			fErase(cFile)
		EndIf

		If File(cPasta + cp_ChvNfe + ".pdf")
			fErase(cPasta + cp_ChvNfe + ".pdf")
		EndIf

		If File(cPasta + cp_ChvNfe + ".xml")
			fErase(cPasta + cp_ChvNfe + ".xml")
		EndIf


		cXML     := ZNF->ZNF_XML
		cError   := ""
		cWarning := ""
		oBNfe    := XmlParser(cXML,"_",@cError,@cWarning)


		If lp_NFe
			cPDF := U_MONNF003(oBNfe,cp_ChvNfe,cPasta,lParam,lDSetup)  //NFe
			frename(cPasta+cp_ChvNfe+"_danfe.pdf",	cPasta+cp_ChvNfe+".pdf" )
			cNomRet += alltrim(iif(!Empty(cNomRet),"|","")+alltrim(cp_ChvNfe+".pdf"))
		Else
			cPDFCte := U_MONNF028(oBNfe,cp_ChvNfe,cPasta,lParam,lDSetup) //DAC
			frename(cPasta+cp_ChvNfe+"_dacte.pdf", cPasta+cp_ChvNfe+".pdf" )
			cNomRet += alltrim(iif(!Empty(cNomRet),"|","")+alltrim(cp_ChvNfe+".pdf"))
		EndIf

		If lGerXML
			sleep(1000)
			oFWriter := FWFileWriter():New(cPasta + cFile, .T.)
			oFWriter:SetCaseSensitive(.T.)

			//Se houve falha ao criar, mostra a mensagem
			If ! oFWriter:Create()
				MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oFWriter:Error():Message, "Atenção")
				cNomRet := ""
			Else
				oFWriter:Write(cXML)
				oFWriter:Close()
				cNomRet += alltrim(iif(!Empty(cNomRet),"|","")+alltrim(cFile))
			EndIf
		EndIf

	EndIf

return(cNomRet)
