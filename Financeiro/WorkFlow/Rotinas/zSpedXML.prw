//Bibliotecas
#Include "Protheus.ch"
 
/*/{Protheus.doc} zSpedXML
Fun��o que gera o arquivo xml da nota (normal ou cancelada) atrav�s do documento e da s�rie disponibilizados
@author Atilio
@since 25/07/2017
@version 1.0
@param cDocumento, characters, C�digo do documento (F2_DOC)
@param cSerie, characters, S�rie do documento (F2_SERIE)
@param cArqXML, characters, Caminho do arquivo que ser� gerado (por exemplo, C:\TOTVS\arquivo.xml)
@param lMostra, logical, Se ser� mostrado mensagens com os dados (erros ou a mensagem com o xml na tela)
@type function
@example Segue exemplo abaixo
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo1.xml", .F.) //N�o mostra mensagem com o XML
     
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo2.xml", .T.) //Mostra mensagem com o XML
/*/
 
User Function zSpedXML(cDocumento, cSerie, cArqXML, lMostra)
    Local aArea         := GetArea()
    Local cURLTss       := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ      := nil
    Local cIdEnt        := &('StaticCall(SPEDNFE, GetIdEnt)')
    Local cTextoXML     := ""
    local lAchou        := .F.
    local cPasLoc       := GetMv("GK_DIRLOC", .T., "C:\geeker\")

    Default cDocumento  := ""
    Default cSerie      := ""
    Default cArqXML     := ""
    Default lMostra     := .F.
        
    if(!ExistDir(cPasLoc))
		MakeDir(cPasLoc)
	endIf

    cArqXML := cPasLoc + "arquivo_"+cSerie+cDocumento+".xml"

    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
         
        //Instancia a conex�o com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"   
         
        //Se tiver notas
        If oWebServ:RetornaNotas()
            lAchou := .T.

            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
             
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                     
                //Sen�o, pega o xml normal
                Else
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                EndIf
                 
                //Gera o arquivo
                MemoWrite(cArqXML, cTextoXML)
                 
                //Se for para mostrar, ser� mostrado um aviso com o conte�do
                If lMostra
                    Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                 
            //Caso n�o encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar par�metros, documento e s�rie n�o encontrados ("+cDocumento+"/"+cSerie+")...")
                 
                If lMostra
                    Aviso("zSpedXML", "Verificar par�metros, documento e s�rie n�o encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
         
        //Sen�o, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
             
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return lAchou
