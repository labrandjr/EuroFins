#include 'protheus.ch'
#include 'tbiconn.ch'

/*/{Protheus.doc} uEnvWfVcto
Realiza o envio atrav�s do schedule.
@author Geeker
@since 06/06/2017
@version 1.0
/*/
user function vsEnvWfVcto()
	local cAuxEmp 	:= "01"
	local cAuxFil	:= "0101"
	
	RPCSetType(3) 	 
	PREPARE ENVIRONMENT EMPRESA cAuxEmp FILIAL cAuxFil		 
	SetModulo("SIGAFIN","FIN")
	
	conout("-----------------------------")
	conout("Enviando t�tulos vencidos: "+ Upper("vsEnvWfVcto")+" - " + Time())
	conout("-----------------------------")
	
	u_vEnvWfVcto() //Envia vencidos
	
	conout("-----------------------------")
	conout("Envio finalizado: "+ Upper("vsEnvWfVcto")+" - " + Time())
	conout("-----------------------------")
		
	RESET ENVIRONMENT
return

user function rEnvWfVcto()
	//local aEmpRoda 	:= {'0100','0101','0400','0401','0403','0500','0501','0502','0503','0504','0600','0800','0802','0505'}
	Local aEmpRoda	:= {}
	local nI		:= 1
	local cAuxEmp 	:= "01"
	local cAuxFil	:= "0101"

	RPCSetType(3) 	 
	PREPARE ENVIRONMENT EMPRESA cAuxEmp FILIAL cAuxFil		 
	aEmpRoda 	:= StrToKarr(GetMV("ZZ_FILWFCB"),"|")
	RESET ENVIRONMENT

	for nI := 1 to Len(aEmpRoda)
		cAuxFil	:= aEmpRoda[nI]
		
		RPCSetType(3) 	 
		PREPARE ENVIRONMENT EMPRESA cAuxEmp FILIAL cAuxFil		 
		SetModulo("SIGAFIN","FIN")
		
		conout("-----------------------------")
		conout("Enviando t�tulos vencidos: "+ Upper("vsEnvWfVcto")+" - " + Time())
		conout("-----------------------------")
		
		u_vEnvWfVcto() //Envia vencidos
		
		conout("-----------------------------")
		conout("Envio finalizado: "+ Upper("vsEnvWfVcto")+" - " + Time())
		conout("-----------------------------")
			
		RESET ENVIRONMENT
	next
return

/*/{Protheus.doc} uEnvWfVcto
Realiza o envio atrav�s do schedule.
@author Geeker
@since 06/06/2017
@version 1.0
/*/
user function asEnvWfVcto()
	local cAuxEmp 	:= "01"
	local cAuxFil	:= "0101"
	//local aEmpRoda 	:= {'0100','0101','0400','0401','0403','0500','0501','0502','0503','0504','0600','0800','0802','0505'}
	local aEmpRoda 	:= {}
	Local nI 		:= 0
	
	RPCSetType(3) 	 
	PREPARE ENVIRONMENT EMPRESA cAuxEmp FILIAL cAuxFil		 
	aEmpRoda 	:= StrToKarr(GetMV("ZZ_FILWFCB"),"|")
	RESET ENVIRONMENT

	for nI := 1 to Len(aEmpRoda)
		cAuxFil	:= aEmpRoda[nI]

		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cAuxEmp FILIAL cAuxFil		 
		SetModulo("SIGAFIN","FIN")
		
		conout("-----------------------------")
		conout("Enviando t�tulos vencidos: "+ Upper("vsEnvWfVcto")+" - " + Time())
		conout("-----------------------------")
		
		u_aEnvWfVcto() //Envia � vencer
		
		conout("-----------------------------")
		conout("Envio finalizado: "+ Upper("vsEnvWfVcto")+" - " + Time())
		conout("-----------------------------")
			
		RESET ENVIRONMENT
	next
	
return

/*/{Protheus.doc} vEnvWfVcto
Realiza o envio dos t�tulos vencidos.
@author Geeker
@since 06/06/2017
@version 1.0
/*/
user function vEnvWfVcto()
	local oEnvWfVcto 	:= nil
	local oEnviaMail	:= EnviaMail():new()	
	local cCorpo		:= ""
	local cAssunto		:= ""	
	local cDestino		:= GetMv("GK_MLDSAV", .T., "brunazanardo@eurofins.com;regis.ferreira@totvs.com.br")

	//Primeiro envio
	oEnviaMail				:= nil
	oEnviaMail				:= EnviaMail():new()		
	cAssunto				:= "[Eurofins] Inicio do envio titulos vencimento - Primeiro intervalo " + cEmpAnt + cFilAnt
	cCorpo					:= cAssunto
	
	oEnviaMail:enviaEmail(cCorpo, cAssunto, cDestino)
		
	oEnvWfVcto				:= nil
	oEnvWfVcto 				:= EnvWfVcto():new()
	oEnvWfVcto:cTipoWf 		:= "V"
	oEnvWfVcto:cTpEnvioVct	:= oEnvWfVcto:TP_PRIM
	oEnvWfVcto:exec()

	oEnviaMail				:= nil 
	oEnviaMail				:= EnviaMail():new()		
	cAssunto				:= "[Eurofins] Fim do envio titulos vencimento - Primeiro intervalo " + cEmpAnt + cFilAnt
	cCorpo					:= cAssunto
	
	oEnviaMail:enviaEmail(cCorpo, cAssunto, cDestino)
	

	//Segundo envio
	oEnviaMail				:= nil
	oEnviaMail				:= EnviaMail():new()		
	cAssunto				:= "[Eurofins] Inicio do envio titulos vencimento - Segundo intervalo " + cEmpAnt + cFilAnt
	cCorpo					:= cAssunto
	
	oEnviaMail:enviaEmail(cCorpo, cAssunto, cDestino)

	oEnvWfVcto				:= nil
	oEnvWfVcto 				:= EnvWfVcto():new()
	oEnvWfVcto:cTipoWf 		:= "V"
	oEnvWfVcto:cTpEnvioVct	:= oEnvWfVcto:TP_SEG
	oEnvWfVcto:exec()
	
	oEnviaMail				:= nil
	oEnviaMail				:= EnviaMail():new()		
	cAssunto				:= "[Eurofins] Fim do envio titulos vencimento - Segundo intervalo " + cEmpAnt + cFilAnt
	cCorpo					:= cAssunto
	
	//Terceiro envio
	oEnviaMail				:= nil
	oEnviaMail				:= EnviaMail():new()		
	cAssunto				:= "[Eurofins] Inicio do envio titulos vencimento - Terceiro intervalo " + cEmpAnt + cFilAnt
	cCorpo					:= cAssunto

	oEnvWfVcto				:= nil
	oEnvWfVcto 				:= EnvWfVcto():new()
	oEnvWfVcto:cTipoWf 		:= "V"
	oEnvWfVcto:cTpEnvioVct	:= oEnvWfVcto:TP_TERC
	oEnvWfVcto:exec()	

	oEnviaMail				:= nil
	oEnviaMail				:= EnviaMail():new()		
	cAssunto				:= "[Eurofins] Fim do envio titulos vencimento - Terceiro intervalo " + cEmpAnt + cFilAnt
	cCorpo					:= cAssunto
return

/*/{Protheus.doc} aEnvWfVcto
Realiza o envio dos t�tulos � vencer.
@author Geeker
@since 06/06/2017
@version 1.0
/*/
user function aEnvWfVcto()
	local oEnvWfVcto := EnvWfVcto():new()
	local oEnviaMail	:= EnviaMail():new()	
	local cCorpo		:= ""
	local cAssunto		:= ""	
	local cDestino		:= GetMv("GK_MLDSAV", .T., "brunazanardo@eurofins.com;joelmabergamo@eurofins.com;fabio@gkcmp.com.br")

	//Primeiro envio
	oEnviaMail			:= nil
	oEnviaMail			:= EnviaMail():new()		
	cAssunto			:= "[Eurofins] Inicio do envio titulos a vencer " + cEmpAnt + cFilAnt
	cCorpo				:= cAssunto
	
	oEnviaMail:enviaEmail(cCorpo, cAssunto, cDestino)
	
	oEnvWfVcto:cTipoWf := "A"
	oEnvWfVcto:exec()

	//Primeiro envio
	oEnviaMail			:= nil
	oEnviaMail			:= EnviaMail():new()		
	cAssunto			:= "[Eurofins] Inicio do envio titulos a vencer " + cEmpAnt + cFilAnt
	cCorpo				:= cAssunto
return

/*/{Protheus.doc} EnvWfVcto
Classe respons�vel por controlar todo o envio de e-mails de t�tulos a vencer
@author Geeker
@since 06/06/2017
@version 1.0
/*/
class EnvWfVcto 
	data TP_LIMITE
	data TP_DIAS

	data TP_PRIM
	data TP_SEG
	data TP_TERC

	data oWfDaVcto
	data dDtRef
	data cError

	data cTipoWf
	data cTpVcto
	data cTpEnvioVct
	
	method new() constructor 
	method exec()
	method getInfo()
	method envErro()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method new() class EnvWfVcto
	::TP_LIMITE		:= "L"
	::TP_DIAS		:= "D"

	::TP_PRIM		:= "P"
	::TP_SEG		:= "S"
	::TP_TERC		:= "T"

	::oWfDaVcto	 	:= WfDaVcto():new()	
	::cError		:= ""	

	::cTpVcto		:= GetMv("GK_TPVCML", .T., "D")
	::cTpEnvioVct	:= ""
return

/*/{Protheus.doc} getInfo
Busca os dados para envio do workflow
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method getInfo() class EnvWfVcto
	if(Alltrim(Upper(::cTipoWf)) == "A")
		::dDtRef := DaySum(dDataBase, SuperGetMv("ZZ_VCWFTI", .F., 0))
		
		if(Dow(dDataBase) == 6)
			::dDtRef	:= DaySum(::dDtRef, 2)
		endIf
		
		if(Dow(dDataBase) == 7)
			::dDtRef	:= DaySum(::dDtRef, 1)
		endIf
	else
		::dDtRef := dDataBase
		
	endIf
		
	::oWfDaVcto:dDtRef 		:= ::dDtRef
	::oWfDaVcto:cTipoWf		:= ::cTipoWf
	::oWfDaVcto:cTpEnvioVct	:= ::cTpEnvioVct
	::oWfDaVcto:cTpVcto		:= ::cTpVcto
	::oWfDaVcto:getTitFin()	
return

/*/{Protheus.doc} exec
Metodo principal da rotina
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method exec() class EnvWfVcto
	local oWfMaiVcto := nil
	local cRet		 := ""
	local nI		 := 0
	local lGrvLog	 := GetMv("GK_GRLGCB", .T., .F.)	
	
	::getInfo()	
	
	for nI := 1 to Len(::oWfDaVcto:aDados)
		oWfMaiVcto 				:= WfMaiVcto():new()
		oWfMaiVcto:cTpEnvioVct	:= ::cTpEnvioVct
		oWfMaiVcto:cTpVcto		:= ::cTpVcto
		oWfMaiVcto:cTipoWf		:= ::cTipoWf
		oWfMaiVcto:dDtRef		:= ::dDtRef
		oWfMaiVcto:aTitulos 	:= ::oWfDaVcto:aDados[nI] 
		
		cRet					:= oWfMaiVcto:wrkFlow()
	
		if(Empty(cRet))
			if(lGrvLog)
				::oWfDaVcto:updLog(oWfMaiVcto:aTitulos)			
			endIf
		else
			::cError += PadR(oWfMaiVcto:cCodCli	, TamSx3("A1_COD")[1]) 	+ ' - '
			::cError += PadR(oWfMaiVcto:cNomeCli, TamSx3("A1_NOME")[1]) + ': '
			::cError += Alltrim(cRet) + CRLF 
		endIf		
	next
	
	if(!Empty(::cError))
		::envErro()
	endIf
return

/*/{Protheus.doc} envErro
E-mail para enviar os problemas nos envios dos e-mails
@author Geeker
@since 06/06/2017 
@version 1.0
/*/
method envErro() class EnvWfVcto
	local oEnviaMail	:= EnviaMail():new()
	local cAssunto		:= "Erros nos t�tulos a vencer " - DtoC(::dDtRef)
	local cDestino		:= SuperGetMv("ZZ_ERWFVC", .F., "fabio@gkcmp.com.br")
return oEnviaMail:enviaEmail(::cError, cAssunto, cDestino)
