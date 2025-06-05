#include "rwmake.ch"
#include "totvs.ch"
#include "xmlxfun.ch"

/*/{Protheus.doc} F022ATUNF
Gera o arquivo xml de retorno para o mylins após nota fiscal autorizada
@type function
@version 1.0
@author Régis Ferreira
@since 14/08/2024
@link 

Geração é cópia do fonte M460FIM, vai começar a gerar por aqui devido a numeração das notas não serem mais pelo RPS e sim pelo número da prefeitura, então a geração acontecerá depois da nota fiscal autorizada.

/*/
User Function F022ATUNF()

    Local aPeds     := {}
    Local aArea     := GetArea()
    Local aAreaSD2  := SD2->(GetArea())
    Local aAreaSC5  := SC5->(GetArea())
    Local nP        := 0
    Local cPath     := SuperGetMV("ZZ_LOCMYRE",,"\XML_MYLIMS\RETORNO\")//local a ser gerado o XML
    Local cNFSe     := ""
    
     if !Empty(SF2->F2_NFELETR)
        cNFSe := Alltrim(SF2->F2_NFELETR)
        If cFilAnt $ '0500|0501|0502|0503|0802|0602|0603|0604' // Anatech ou ASL

            // Gerar XML que sera usado pelo MyLims 
            aPeds := {}
            SD2->(dbSetOrder(3))
            if SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
                While !SD2->(Eof()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SF2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
                    SC5->(dbSetOrder(1))
                    If SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
                        If Substr(SC5->C5_ZZCODIN,At("-",SC5->C5_ZZCODIN)+1,1) == '0'		// 0=Envia Retorno 1=Nao Envia Retorno
                            If aScan(aPeds , {|x| X[1] == SD2->D2_PEDIDO}) == 0
                                //aadd(aPeds , {SD2->D2_PEDIDO,Substr(SC5->C5_ZZCODIN,1,At("-",SC5->C5_ZZCODIN)-1),SD2->D2_DOC,SD2->D2_EMISSAO})
                                aadd(aPeds , {SD2->D2_PEDIDO,Substr(SC5->C5_ZZCODIN,1,At("-",SC5->C5_ZZCODIN)-1),cNFSe,SD2->D2_EMISSAO})
                            Endif
                        Endif
                    Endif
                    SD2->(dbSkip())
                Enddo
            endif

            For nP:=1 to Len(aPeds)

                cXML := GeraXML(aPeds[nP])
                nXMLFile := FCreate(cPath+aPeds[nP][1]+".xml",0,,.F.)
                If nXMLFile > 0
                    FWrite( nXMLFile,cXML )
                Else
                    MsgAlert("Não foi possível gravar o XML no local indicado.")
                EndIf
                FClose( nXMLFile )

            Next

        Endif
    endif

    SC5->(RestArea(aAreaSC5))
    SD2->(RestArea(aAreaSD2))
    RestArea(aArea)

Return

Static Function GeraXML(aInfo)

    Local cScript := ''
    Local cNumPed := aInfo[1]
    Local cNumInv := aInfo[2]
    Local cNumNF  := aInfo[3]
    Local dDtNF   := aInfo[4]

    cScript += '<?xml version="1.0" encoding="ISO-8859-1"?>'                +CRLF
    cScript += '<DADOS>'                                                    +CRLF
    cScript += '  <INVOICE>'                                                +CRLF
    cScript += '    <CDINVOICE>'+cNumInv+'</CDINVOICE>'                     +CRLF
    cScript += '    <STATUS>Sucesso</STATUS>'                               +CRLF
    cScript += '    <MENSAGEM>NF '+cNumNF+'  '+DtoC(dDtNF)+'</MENSAGEM>'    +CRLF
    cScript += '    <NRPEDIDOVENDA>'+cNumPed+'</NRPEDIDOVENDA>'             +CRLF
    cScript += '  </INVOICE>'                                               +CRLF
    cScript += '</DADOS>'                                                   +CRLF

Return cScript
