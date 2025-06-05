#INCLUDE "totvs.ch"


/*/{Protheus.doc} TWsdlGaribaldi
Conexão WebService NFSe
@author Unknown
@since 04/01/2018
/*/
User Function TWsdlGaribaldi(cXml)

  Local oWsdl := nil
  Local xRet  := nil
  Local aOps  := {}

  private aComplex := {}
  private aSimple  := {}

  // Cria o objeto da classe TWsdlManager
  oWsdl := TWsdlManager():new()

  oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs 

  // Faz o parse de uma URL
  xRet := oWsdl:ParseURL("https://nfsehomol.garibaldi.rs.gov.br/portal/Servicos?wsdl")

  if xRet == .F.
    MsgAlert(oWsdl:cError,"ParseURL")
    return
  endif

  aOps := oWsdl:ListOperations()

  if Len(aOps) == 0
  	MsgAlert(oWsdl:cError,"ListOperations")
    return
  endif

  varinfo("",aOps)

  // Define a operação
  xRet := oWsdl:SetOperation("Servicos_enviarLoteNotas")
  //xRet := oWsdl:SetOperation(aOps[1][1])
  if xRet == .F.
     MsgAlert(oWsdl:cError,"SetOperation")
     return
  endif

  aComplex := oWsdl:NextComplex()
  varinfo("", aComplex)

  aSimple := oWsdl:SimpleInput()
  varinfo("", aSimple)

  // Define o valor de cada parâmeto necessário
  xRet := oWsdl:SetValue(0,cXml)
  //xRet := oWsdl:SetValue(aSimple[1][1], "90210")
  if xRet == .F.
    MsgAlert(oWsdl:cError,"SetValue")
    return
  endif

  // Exibe a mensagem que será enviada
  Alert(oWsdl:GetSoapMsg())

  // Envia a mensagem SOAP ao servidor
  xRet := oWsdl:SendSoapMsg()
  if xRet == .F.
    MsgAlert(oWsdl:cError,"SendSoapMsg")
    return
  endif

  // Pega a mensagem de resposta
  Alert(oWsdl:GetSoapResponse())

  if xRet == .F.
    MsgAlert(oWsdl:cError,"GetSoapResponse")
    return
  endif

return
