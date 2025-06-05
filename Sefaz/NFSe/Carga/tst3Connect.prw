#Include 'Protheus.ch'
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} tst3Connect
Conexão WebService NFSe
@author Unknown
@since 04/01/2018
/*/
User Function tst3Connect()
Local lRet := .F.
	Local oWsdl := TWsdlManager():New()
	Local cXmlRet := ""
	local cWsdlURL := "https://nfsehomol.garibaldi.rs.gov.br/portal/Servicos?wsdl"
	local aSimple := {}
	local aOps		:= {}
	local cMsg		:= ""
	local cXml		:= ""

	//Define as propriedades para tratar os prefixos NS das tags do XML e para remover as tags vazias
	oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs 
	oWsdl:lUseNSPrefix := .F.
	oWsdl:lRemEmptyTags := .T.
	oWsdl:lCheckInput := .F.

	//Informa os arquivos da quebra do certificado digital
	oWsdl:cSSLCACertFile	:= "\certs\000005_ca.pem"
	oWsdl:cSSLCertFile	:= "\certs\000005_cert.pem"
	oWsdl:cSSLKeyFile		:= "\certs\000005_key.pem"
	oWsdl:cSSLKeyPwd		:= "Euro@2016"


	//0 - O programa tenta descobrir a versão do protocolo, isto é, se a versão do protocolo remoto é SSLv3 ou TLSv1
	//1 - Força a utilização do TLSv1
	//2 - Força a utilização do SSLv2
	//3 - Força a utilização do SSLv3
	oWSDL:nSSLVersion		:= 0

	oWSDL:nTimeout		:= 120

	//"Parseia" o WSDL para manipular o mesmo através do objeto da classe TWsdlManager
	lRet := oWsdl:ParseURL( cWsdlURL )
	If lRet
		// Lista as operações disponíveis
  		aOps := oWsdl:ListOperations()
  		varinfo( "", aOps )

		//Define a operação com a qual será trabalhada no Documento Hábil em questão
		lRet := oWsdl:SetOperation( "obterLoteNotaFiscal" )
		If lRet
			oWsdl:cLocation := "https://nfsehomol.garibaldi.rs.gov.br/portal/Servicos"

			//Se houver mensagem definida, envia a mensagem. Do contrário, mostra o erro do objeto.
			oWsdl:lVerbose := .T. //#DEL

			// Lista os tipos simples da mensagem de input envolvida na operação
  			aSimple := oWsdl:SimpleInput()
  			varinfo( "", aSimple )

			//nPos := aScan( aSimple, {|x| x[2] == "bd" } )
			//lRet := oWsdl:SetValue( aSimple[nPos][1], "bd" )

//			cXml += '<pedidoStatusLote versao="1.0">'
//			cXml += '<CNPJ>94088952000152</CNPJ>' // LABORATORIO ALAC LTDA
//			cXml += '<cLote>265</cLote>'
//			cXml += '</pedidoStatusLote>'

			cXml += '<pedidoLoteNFSe versao="1.0">'
			cXml += '<CNPJ>94088952000152</CNPJ>' // LABORATORIO ALAC LTDA
			cXml += '<notaInicial>1</notaInicial>'
			cXml += '<notaFinal>1</notaFinal>'
			cXml += '<serieNotaFiscal>S</serieNotaFiscal>'
			cXml += '</pedidoLoteNFSe>'

//			cXml += '<pedConsultaTrans versao="1.0">'
//			cXml += '<CNPJ>94088952000152</CNPJ>'
//			cXml += '<chvAcessoNFS-e>439408895200015290S00000000421000021230</chvAcessoNFS-e>'
//			cXml += '</pedConsultaTrans>'

			cXml := SignNFSeA1(cXml,"pedidoLoteNFSe","","000005","Euro@2016")

			lRet := oWsdl:SetFirst( "xml", cXml )
			if lRet
				cMsg := oWsdl:GetSoapMsg()

				//Retirado o elemento da tag devido o obj nao suportar
				cMsg := StrTran(cMsg, ' xmlns="http://ws.pc.gif.com.br/"', '')
				//cMsg := StrTran(cMsg, "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>", '')


				If !Empty( cMsg )
					//Envia a mensagem SOAP ao servidor
					//oWsdl:lProcResp := .F. //Não processa o retorno automaticamente no objeto (será tratado através do método GetSoapResponse)
					lRet := oWsdl:SendSoapMsg(cMsg)
					//If lRet
						//Trata a resposta do WebService
						cXmlRet := oWsdl:GetSoapResponse()
						If ! Empty( cXmlRet )
							Aviso( "Response", cXmlRet, { "OK"}, 3, "Response" )
//							aviso(cXmlRet)
						Else
							Alert("Não foi possível tratar a resposta do WebService. A requisição pode ou não ter tido sucesso.")
						Endif
					//Else
					//	Alert("Ocorreu um problema ao enviar a requisição: " + oWsdl:cError, 1, 0 )
					//Endif
				Else
					Alert("Há um problema em obter a mensagem SOAP: " + oWsdl:cError)
				Endif
			Else
				Alert("Ocorreu um problema na definição de valores: " + oWsdl:cError)
			Endif
		Else
			Alert("Houve um problema ao definir a operação para envio:" + oWsdl:cError)
		Endif
	Else
		Alert("Houve um problema ao acessar o WSDL do serviço: " + oWsdl:cError)
	Endif

	oWsdl := Nil
Return Nil


/*
Funcao de assinatura de um XML no padrao X.509.
*/
Static Function SignNFSeA1(cXML,cTag,cAttID,cIdEnt,cPassword)

Local cXmlToSign  := ""
Local cDir        := IIf(IsSrvUnix(),"certs/", "certs\")
Local cRootPath   := StrTran(GetSrvProfString("RootPath","")+IIf(!IsSrvUnix(),"\","/"),IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
Local cStartPath  := StrTran(cRootPath+IIf(!IsSrvUnix(),"\","/")+GetSrvProfString("StartPath","")+IIf(!IsSrvUnix(),"\","/"),IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
Local cArqXML     := Lower(CriaTrab(,.F.))
Local cMacro      := ""
Local cError      := ""
Local cWarning    := ""
Local cDigest     := ""
Local cSignature  := ""
Local cSignInfo   := ""
Local cIniXml     := ""
Local cFimXml     := ""
Local nAt         := 0

cPassCert   		:= cPassword

//cPassCert   := "1234"

cRootPath  := StrTran(cRootPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
cStartPath := StrTran(cStartPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
cStartPath := StrTran(cStartPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Assina a NFSe                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("EVPPrivSign")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Canoniza o XML                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXmlToSign := XmlC14N(cXml, "", @cError, @cWarning)

		If Empty(cError) .And. Empty(cWarning)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retira a Tag anterior a tag de assinatura                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAt := At("<"+cTag,cXmlToSign)
			cIniXML    := SubStr(cXmlToSign,1,nAt-1)
			cXmlToSign := SubStr(cXmlToSign,nAt)
			nAt := At("</"+cTag+">",cXmltoSign)
			cFimXML    := SubStr(cXmltoSign,nAt+Len(cTag)+3)
			cXmlToSign := SubStr(cXmlToSign,1,nAt+Len(cTag)+2)

			cDigest := Alltrim(cXmlToSign)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o DigestValue da assinatura                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDigest := XmlC14N(cDigest, "", @cError, @cWarning)
	       cMacro  := "EVPDigest"

	       cDigest := Encode64(&cMacro.( cDigest , 3 ))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o SignedInfo  da assinatura                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSignInfo := GetSignInfo(cDigest)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Assina o XML                                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMacro     := "EVPPrivSign"

			cSignature := &cMacro.(IIf(IsSrvUnix(),"/", "\")+cDir+cIdEnt+"_key.pem" , XmlC14N(cSignInfo, "", @cError, @cWarning) , 3 , cPassCert , @cError)
			cSignature := Encode64(cSignature)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envelopa a assinatura                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cXmlToSign += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
			cXmltoSign += cSignInfo
			cXmlToSign += '<SignatureValue>'+cSignature+'</SignatureValue>'
			cXmlToSign += '<KeyInfo>'
			cXmlToSign += '<X509Data>'
//			cXmlToSign += '<X509SubjectName>CN=LABORATORIO ALAC LTDA,OU=(EM BRANCO),OU=(EM BRANCO),OU=(EM BRANCO),OU=(EM BRANCO),OU=(EM BRANCO),OU=94088952000152,OU=(EM BRANCO),O=ICP-Brasil,C=BR</X509SubjectName>'
			cXmlToSign += '<X509Certificate>'+GetCertificate(IIf(IsSrvUnix(),"/", "\")+cDir+cIdEnt+"_cert.pem",.F.,cIdEnt)+'</X509Certificate>'
			cXmlToSign += '</X509Data>'
			cXmlToSign += '</KeyInfo>'
			cXmlToSign += '</Signature>'

			cXmlToSign := cIniXML+cXmlToSign+cFimXML

			cXmlToSign := StrTran(cXmlToSign,"</"+cTag+">","")
			cXmlToSign := cXmlToSign+"</"+cTag+">"
		Else
			cXmlToSign := cXml
			ConOut("Sign Error thread: "+cError+"/"+cWarning)
		EndIf
	Else
		cXmlToSign := "Falha"
		ConOut("Falha ao tentar assinar NFSE.","Necessario Build " + GetBuild() + " ou superior.")
	EndIf

Return(cXmlToSign)



/*
Gera o envelopamento da tag SignedInfo para a assinatura.
*/
Static Function GetSignInfo(cDigest)
Local cSignedInfo	:= ""

	cSignedInfo += '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
	cSignedInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
	cSignedInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
	cSignedInfo += '<Reference URI="">'
	cSignedInfo += '<Transforms>'
	cSignedInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
	cSignedInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
	cSignedInfo += '</Transforms>'
	cSignedInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
	cSignedInfo += '<DigestValue>' + cDigest + '</DigestValue>'
	cSignedInfo += '</Reference>'
	cSignedInfo += '</SignedInfo>'

Return(cSignedInfo)


/*
Retorna os dados do certificado.
*/
Static Function GetCertificate(cFile,lHSM,cIdEnt)
Local cCertificado := cFile
Local nAT          := 0
Local nRAT         := 0
Local nHandle      := 0
Local nBuffer      := 0

If file(cfile)
	lDirCert  := .T.
	nHandle      := FOpen( cFile, 0 )
	nBuffer      := FSEEK(nHandle,0,FS_END)


	FSeek( nHandle, 0 )
	FRead( nHandle , cCertificado , nBuffer )
	FClose( nHandle )

	nAt := AT("BEGIN CERTIFICATE", cCertificado)
	If (nAt > 0)
		nAt := nAt + 22
		cCertificado := substr(cCertificado, nAt)
	EndIf
	nRat := AT("END CERTIFICATE", cCertificado)
	If (nRAt > 0)
		nRat := nRat - 6
		cCertificado := substr(cCertificado, 1, nRat)
	EndIf
	cCertificado := StrTran(cCertificado, Chr(13),"")
	cCertificado := StrTran(cCertificado, Chr(10),"")
	cCertificado := StrTran(cCertificado, Chr(13)+Chr(10),"")
Else
	lDirCert  := .F.
	Conout("Certificado nao encontrado no diretorio Certs - Realizar a configuracao do certificado para entidade "+cIdEnt+" !")
EndIf

Return(cCertificado)

