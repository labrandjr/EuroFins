#include 'protheus.ch'

/*/{Protheus.doc} TxParamWf
(long_description)
@author    fabio
@since     04/12/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class TxParamWf
	data aTitulos
	data cEmpTit

	data cNomEmp 		//01
	data cImgLogo       //02
	data cTxAVencer     //03
	data cTx1Vencidos   //04
	data cTx2Vencidos   //05
	data cTx3Vencidos   //06
	data cTelEmp        //07
	data cCNPJEmp       //08
	data cEnderEmp      //09
	data cCidadeEmp		//10
	data cSiteEmp       //11
	data c1TxtCustom
	
	data cFile
	
	method new() constructor 
	method getTxEmp_TxParamWf()
	method getTxtCustom_TxParamWf()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author    fabio
@since     04/12/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/ 
method new() class TxParamWf
	::cFile 		:= GetMv("ZZ_EMCBTX", .T., "\cobranca\01cobranca.txt")
	
 	::cNomEmp 		:= ""
 	::cImgLogo      := ""
 	::cTxAVencer    := ""
 	::cTx1Vencidos  := ""
 	::cTx2Vencidos  := ""
	::cTx3Vencidos	:= ""
 	::cTelEmp       := ""
 	::cCNPJEmp      := ""
 	::cEnderEmp     := ""
 	::cCidadeEmp	:= ""
 	::cSiteEmp      := ""
	::c1TxtCustom	:= ""
return

/*/{Protheus.doc} getTxEmp
Metodo para buscar os dados da empresa
@author    fabio
@since     04/12/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method getTxEmp_TxParamWf() class TxParamWf
	local cString   := iif(File(::cFile), MemoRead(::cFile), "")    
	local cLine		:= ""
	local nI		:= 1
	                 
	FT_FUSE(::cFile)
	while !FT_FEOF()
    	cLine := FT_FREADLN()
    	
    	if(nI == 1)
    		::cNomEmp		:= Alltrim(cLine)
    	elseIf(nI == 2)
    		::cImgLogo 		:= Alltrim(cLine)
    	elseIf(nI == 3)
    		::cTxAVencer	:= Alltrim(cLine)
    	elseIf(nI == 4)
    		::cTx1Vencidos	:= Alltrim(cLine)
    	elseIf(nI == 5)
    		::cTx2Vencidos	:= Alltrim(cLine)
		elseIf(nI == 6)
    		::cTx3Vencidos	:= Alltrim(cLine) 	
    	elseIf(nI == 7)
    		::cTelEmp		:= Alltrim(cLine)
    	elseIf(nI == 8)
    		::cCNPJEmp		:= Alltrim(cLine)
    	elseIf(nI == 9)
    		::cEnderEmp  	:= Alltrim(cLine)
    	elseIf(nI == 10)
    		::cCidadeEmp	:= Alltrim(cLine)
    	elseIf(nI == 11)
    		::cSiteEmp		:= Alltrim(cLine)
    	endIf
    		 		
    	nI++
    	FT_FSKIP()
    endDo    
    FT_FUSE()

	::getTxtCustom_TxParamWf()
return

/*/{Protheus.doc} getTxtCustom_TxParamWf
Metodo para buscar os textos customizados
@author    fabio
@since     04/12/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method getTxtCustom_TxParamWf() class TxParamWf
	if(ExistBlock( "GK0001" ))
		cRetDados := ExecBlock( "GK0001", .F., .F., {::cEmpTit, ::aTitulos})
	
		if(ValType(cRetDados) == "C" .and. !Empty(cRetDados))
			::c1TxtCustom := cRetDados
		endIf
	endIf
return