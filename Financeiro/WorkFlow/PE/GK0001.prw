#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"

/*/{Protheus.doc} GK0001
PE para manipular os textos customizados
@author GKDSK01
@since 06/04/2018
@version 1.0
/*/
user function GK0001()
	local cEmpTit 	:= PARAMIXB[1]
	local aTitulos	:= PARAMIXB[2]
    local cRetTxt   := ""
    local cLinkPrf  := ""
    local cTxtAux   := ""
    local nI        := 1
        
    if(!Empty(aTitulos))
        for nI := 1 to Len(aTitulos)
            cLinkPrf    := ""
            cTxtAux     := ""

            if(Alltrim(SM0->M0_CODFIL) == '0400')
                if(!Empty(aTitulos[nI]:cChaNfe))
                    cTxtAux  += PadR(aTitulos[nI]:cNumTit, TamSx3("F2_DOC")[1]) + ": "
                    cLinkPrf += 'https://nfse.garibaldi.rs.gov.br/portal/consulta.jspx?nf=' + Alltrim(aTitulos[nI]:cChaNfe)                
                    cTxtAux  += '<a href="'+ cLinkPrf +'" target="_top"><font color="blue">'+ cLinkPrf +'</font></a>'
                    cTxtAux  += " - Chave de acesso : " + Alltrim(aTitulos[nI]:cChaNfe) + "<br>"
                endIf

            elseIf(!Empty(aTitulos[nI]:cCodNfe))

                if(Alltrim(SM0->M0_CODFIL) == '0100')
                    if(!Empty(aTitulos[nI]:cCodNfe))
                        cTxtAux  += PadR(aTitulos[nI]:cNumTit, TamSx3("F2_DOC")[1]) + ": "
                        cLinkPrf += 'http://www.indaiatuba.sp.gov.br/fazenda/rendas-mobiliarias/nfse/consulta/'
                        cTxtAux  += '<a href="'+ cLinkPrf +'" target="_top"><font color="blue">'+ cLinkPrf +'</font></a>'
                        cTxtAux  += " - Chave de acesso : " + Alltrim(aTitulos[nI]:cCodNfe) + "<br>"
                    endIf
                                        
                elseIf(Alltrim(SM0->M0_CODFIL) == '0101')
                    if(!Empty(aTitulos[nI]:cCodNfe))
                        cTxtAux  += PadR(aTitulos[nI]:cNumTit, TamSx3("F2_DOC")[1]) + ": "
                        cLinkPrf += 'https://nfse.recife.pe.gov.br/nfse.aspx?inscricao='+ Alltrim(SM0->M0_INSCM) +'&nf='+Alltrim(Str(VAL(aTitulos[nI]:cNumTit)))+'&cod=' + StrTran(Alltrim(aTitulos[nI]:cCodNfe),"-","")
                        cTxtAux += '<a href="'+ cLinkPrf +'" target="_top"><font color="blue">'+ cLinkPrf +'</font></a>'                
                        cTxtAux += " - Chave de acesso : " + Alltrim(aTitulos[nI]:cCodNfe) + "<br>"
                    endIf

                elseIf(Alltrim(SM0->M0_CODFIL) $ '0200|0600|0601')
                    if(!Empty(aTitulos[nI]:cCodNfe))
                        cTxtAux  += PadR(aTitulos[nI]:cNumTit, TamSx3("F2_DOC")[1]) + ": "
                        cLinkPrf += 'https://notacarioca.rio.gov.br/contribuinte/notaprint.aspx?ccm='+ Alltrim(SM0->M0_INSCM) +'&nf='+Alltrim(Str(VAL(aTitulos[nI]:cNumTit))) +'&cod=' + StrTran(Alltrim(aTitulos[nI]:cCodNfe),"-","")
                        cTxtAux  += '<a href="'+ cLinkPrf +'" target="_top"><font color="blue">'+ cLinkPrf +'</font></a>'                    
                        cTxtAux  += " - Chave de acesso : " + Alltrim(aTitulos[nI]:cCodNfe) + "<br>"
                    endIf

                elseIf(Alltrim(SM0->M0_CODFIL) $ '0500|00501|0502|0503|0602')
                    if(!Empty(aTitulos[nI]:cCodNfe))
                        cTxtAux  += PadR(aTitulos[nI]:cNumTit, TamSx3("F2_DOC")[1]) + ": "
                        cLinkPrf += 'https://nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?nf='+ Alltrim(Str(VAL(aTitulos[nI]:cNumTit))) +'&inscricao='+Alltrim(SM0->M0_INSCM) +'&verificacao=' + StrTran(Alltrim(aTitulos[nI]:cCodNfe),"-","")+'&returnurl=..%2fpublico%2fverificacao.aspx%3ftipo%3d0'
                        cTxtAux  += '<a href="'+ cLinkPrf +'" target="_top"><font color="blue">'+ cLinkPrf +'</font></a>'                
                        cTxtAux  += " - Chave de acesso : " + Alltrim(aTitulos[nI]:cCodNfe) + "<br>"
                    endIf

                elseIf(Alltrim(SM0->M0_CODFIL) $ '0800|0802|0604')
                    if(!Empty(aTitulos[nI]:cCodNfe))
                        cTxtAux  += PadR(aTitulos[nI]:cNumTit, TamSx3("F2_DOC")[1]) + ": "
                        cLinkPrf += 'http://visualizar.ginfes.com.br/report/consultarNota?__report=nfs_ver4&cdVerificacao='+ StrTran(Alltrim(aTitulos[nI]:cCodNfe),"-","") +'&numNota=' + Alltrim(Str(VAL(aTitulos[nI]:cNumTit)))+'&cnpjPrestador='+Alltrim(SM0->M0_CGC)
                        cTxtAux  += '<a href="'+ cLinkPrf +'" target="_top"><font color="blue">'+ cLinkPrf +'</font></a>'
                        cTxtAux  += " - Chave de acesso : " + Alltrim(aTitulos[nI]:cCodNfe) + "<br>"
                    endIf

                elseIf(Alltrim(SM0->M0_CODFIL) $ '0504|0603')
                    if(!Empty(aTitulos[nI]:cCodNfe))
                        cTxtAux  += PadR(aTitulos[nI]:cNumTit, TamSx3("F2_DOC")[1]) + ": "
                        cLinkPrf += 'http://nfse.isssbc.com.br/report/consultarNota?__report=nfs_sao_bernardo_campo_novo&cdVerificacao='+ StrTran(Alltrim(aTitulos[nI]:cCodNfe),"-","") +'&numNota=' + Alltrim(Str(VAL(aTitulos[nI]:cNumTit)))+'&cnpjPrestador='+Alltrim(SM0->M0_CGC)
                        cTxtAux  += '<a href="'+ cLinkPrf +'" target="_top"><font color="blue">'+ cLinkPrf +'</font></a>'
                        cTxtAux  += " - Chave de acesso : " + Alltrim(aTitulos[nI]:cCodNfe) + "<br>"
                    endIf

                endif
            endIf

            cRetTxt += cTxtAux
        next
    endIf

    if(!Empty(cRetTxt))
        cRetTxt := '<span class="spanpad" link="blue" vlink="blue" alink="blue">Para visualizar a NOTA FISCAL: </br></br>' + cRetTxt + '</span>'        
    endIf

return cRetTxt
