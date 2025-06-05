#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
/*/{protheus.doc} WSServicosService
Web Service para consultar situação de nota fiscal
@author Unknown
@since __/__/____
/*/

/* ===============================================================================
WSDL Location    https://nfsehomol.garibaldi.rs.gov.br/portal/Servicos?wsdl
Gerado em        01/22/16 16:17:00
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TGGRTJS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSServicosService
------------------------------------------------------------------------------- */

WSCLIENT WSServicosService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD anularNotaFiscal
	WSMETHOD cancelarLote
	WSMETHOD cancelarNotaFiscal
	WSMETHOD consultarNotaFiscal
	WSMETHOD consultarSituacaoNotaFiscal
	WSMETHOD enviarLoteCupom
	WSMETHOD enviarLoteDms
	WSMETHOD enviarLoteNotas
	WSMETHOD inutilizacao
	WSMETHOD licencaTLS
	WSMETHOD obterCriticaLote
	WSMETHOD obterCriticaLoteDms
	WSMETHOD obterCupomParaImpressao
	WSMETHOD obterLoteNotaFiscal
	WSMETHOD obterNotaFiscal
	WSMETHOD obterNotaFiscalXml
	WSMETHOD obterNotasEmPDF
	WSMETHOD obterNotasEmPNG
	WSMETHOD obterReciboLote
	WSMETHOD obterStatusLoteDms
	WSMETHOD pedidoGuia
	WSMETHOD ping

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cxml                      AS string
	WSDATA   creturn                   AS string
	WSDATA   cbd                       AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSServicosService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150410] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSServicosService
Return

WSMETHOD RESET WSCLIENT WSServicosService
	::cxml               := NIL 
	::creturn            := NIL 
	::cbd                := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSServicosService
Local oClone := WSServicosService():New()
	oClone:_URL          := ::_URL 
	oClone:cxml          := ::cxml
	oClone:creturn       := ::creturn
	oClone:cbd           := ::cbd
Return oClone

// WSDL Method anularNotaFiscal of Service WSServicosService

WSMETHOD anularNotaFiscal WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:anularNotaFiscal xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:anularNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method cancelarLote of Service WSServicosService

WSMETHOD cancelarLote WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:cancelarLote xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:cancelarLote>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method cancelarNotaFiscal of Service WSServicosService

WSMETHOD cancelarNotaFiscal WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:cancelarNotaFiscal xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:cancelarNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method consultarNotaFiscal of Service WSServicosService

WSMETHOD consultarNotaFiscal WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:consultarNotaFiscal xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:consultarNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method consultarSituacaoNotaFiscal of Service WSServicosService

WSMETHOD consultarSituacaoNotaFiscal WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:consultarSituacaoNotaFiscal xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:consultarSituacaoNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviarLoteCupom of Service WSServicosService

WSMETHOD enviarLoteCupom WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:enviarLoteCupom xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:enviarLoteCupom>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviarLoteDms of Service WSServicosService

WSMETHOD enviarLoteDms WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:enviarLoteDms xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:enviarLoteDms>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviarLoteNotas of Service WSServicosService

WSMETHOD enviarLoteNotas WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:enviarLoteNotas xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:enviarLoteNotas>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method inutilizacao of Service WSServicosService

WSMETHOD inutilizacao WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:inutilizacao xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:inutilizacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method licencaTLS of Service WSServicosService

WSMETHOD licencaTLS WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:licencaTLS xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:licencaTLS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterCriticaLote of Service WSServicosService

WSMETHOD obterCriticaLote WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterCriticaLote xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterCriticaLote>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterCriticaLoteDms of Service WSServicosService

WSMETHOD obterCriticaLoteDms WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterCriticaLoteDms xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterCriticaLoteDms>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterCupomParaImpressao of Service WSServicosService

WSMETHOD obterCupomParaImpressao WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterCupomParaImpressao xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterCupomParaImpressao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterLoteNotaFiscal of Service WSServicosService

WSMETHOD obterLoteNotaFiscal WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterLoteNotaFiscal xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterLoteNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterNotaFiscal of Service WSServicosService

WSMETHOD obterNotaFiscal WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterNotaFiscal xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterNotaFiscalXml of Service WSServicosService

WSMETHOD obterNotaFiscalXml WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterNotaFiscalXml xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterNotaFiscalXml>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterNotasEmPDF of Service WSServicosService

WSMETHOD obterNotasEmPDF WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterNotasEmPDF xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterNotasEmPDF>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterNotasEmPNG of Service WSServicosService

WSMETHOD obterNotasEmPNG WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterNotasEmPNG xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterNotasEmPNG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterReciboLote of Service WSServicosService

WSMETHOD obterReciboLote WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterReciboLote xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterReciboLote>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterStatusLoteDms of Service WSServicosService

WSMETHOD obterStatusLoteDms WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterStatusLoteDms xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterStatusLoteDms>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method pedidoGuia of Service WSServicosService

WSMETHOD pedidoGuia WSSEND cxml WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:pedidoGuia xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:pedidoGuia>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ping of Service WSServicosService

WSMETHOD ping WSSEND cbd WSRECEIVE creturn WSCLIENT WSServicosService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:ping xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("bd", ::cbd, cbd , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:ping>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.pc.gif.com.br/",,,; 
	"http://nfsehomol.garibaldi.rs.gov.br/portal/Servicos")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



