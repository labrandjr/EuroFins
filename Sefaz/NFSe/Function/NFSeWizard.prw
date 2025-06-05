#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} NFSeWizard

Rotina para Configuração do Integrador NFS-e
	
@author Winston Dellano de Castro
@since 21/12/2015

/*/

user function NFSeWizard(oNFSe)

	Local lRet			:= .F.
	Local cGrupoPerg	:= "NFSEClassWzd_" + ::cEstado + ::cCodMun
	Local cTitlePerg	:= "Wizard"
	Local oParamBox		:= IpParamBoxObject():newIpParamBoxObject(cGrupoPerg) 			
	              
	oParamBox:setTitle(::cTitle + " - " + cTitlePerg)
	addWzdParams(@oParamBox,@Self)
	
	If (lRet := oParamBox:show() )
		defineParameters(@Self,oParamBox)
	Endif
	
Return lRet


/**
* Adiciona parametros de Exportação de Dados
**/
static function addWzdParams(oParamBox,oObj)

	Local oParam 		:= nil
	Local cGroupPerg	:= oParamBox:getId()
	Local uUpdate		:= ""	
	
	SuperGetMv()
	
	oParam := IpParamObject():newIpParamObject("MV_PAR01", "combo", "Regime Especial", "C", 50, 01 )
	oParam:setValues({"1=Sim","2=Não"})
	uUpdate := PADR(AllTrim(GetNewPar("MV_REGIESP","2")),01)
	oParam:setInitializer( uUpdate  )
	saveParBox(cGroupPerg,uUpdate,01)
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR02", "combo", "Optante pelo Simples Nacional", "C", 50, 01 )
	oParam:setValues({"1=Sim","2=Não"})	
	uUpdate := PADR(AllTrim(GetNewPar("MV_OPTSIMP","2")),01)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,02)
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("MV_PAR03", "combo", "Incentivador Cultural", "C", 50, 01 )
	oParam:setValues({"1=Sim","2=Não"})	 
	uUpdate := PADR(AllTrim(GetNewPar("MV_INCECUL","2")),01)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,03)
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR04", "combo", "Incentivador Fiscal", "C", 50, 01 )
	oParam:setValues({"1=Sim","2=Não"})
	uUpdate := AllTrim(GetNewPar("MV_INCEFIS","2"))
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,04)
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("MV_PAR05", "file", "Diretório Temporário", "C", 70, 500 )	
	uUpdate := PADR(Lower(Alltrim(GetNewPar("ZZ_DIRTMP",GetTempPath()))),500)
	oParam:setFileStartDirectory(uUpdate)
	saveParBox(cGroupPerg,uUpdate,05)
	oParam:setFileParams(GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) 	
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR06", "get", "Nº de Série do Certificado", "C", 50, 80 )
	uUpdate := PADR(Alltrim(Upper(GetNewPar("ZZ_CHVCERT",""))),50)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,06)
	oParamBox:addParam(oParam)	
	
	oParam := IpParamObject():newIpParamObject("MV_PAR07", "get", "Login do Usuário", "C", 50, 50 )
	uUpdate := PADR(AllTrim(GetNewPar("ZZ_NFSEUSR","")),50)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,07)
	oParamBox:addParam(oParam)                          
	
	oParam := IpParamObject():newIpParamObject("MV_PAR08", "password", "Senha do Usuário/Certifificado", "C", 50, 50 )
	uUpdate := PADR(AllTrim(GetNewPar("ZZ_NFSEPAS","")),50)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,08)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("MV_PAR09", "checkbox", "Ativa Concatenção de Itens", "L")
	uUpdate := AllTrim(GetNewPar("MV_ITEMAGL","N")) == "S"
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,09)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR10", "get", "CFOPs a Considerar (Opc.)", "C", 70 , 100 )
	uUpdate := PADR(GetNewPar("ZZ_CFOPNFS",""),50)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,10)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("MV_PAR11", "get", "Nº do Lote NFS-e", "C", 50 , 50 )
	uUpdate := PADR(GetNewPar("ZZ_NFSELOT",""),50)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,11)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR12", "get", "URL do Site NFS-e - Prod.", "C", 150 )
	uUpdate := PADR(Lower(GetNewPar("ZZ_URLNFSE","")),150)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,12)	
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR13", "get", "URL do Site NFS-e - Hom.", "C", 150 )
	uUpdate := PADR(Lower(GetNewPar("ZZ_URLNFSH","")),150)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,13)	
	oParamBox:addParam(oParam)	
	
	oParam := IpParamObject():newIpParamObject("MV_PAR14", "get", "Rotina de Exportação", "C", 40 , 10 )
	uUpdate := PADR(oObj:cRotinaExp,10)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,14)
	oParamBox:addParam(oParam)			

	oParam := IpParamObject():newIpParamObject("MV_PAR15", "get", "Rotina de Importação", "C", 40 , 10 )
	uUpdate := PADR(oObj:cRotinaImp,10)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,15)
	oParamBox:addParam(oParam)			
	
	oParam := IpParamObject():newIpParamObject("MV_PAR16", "get", "Rotina de Transmissão", "C", 40 , 10 )
	uUpdate := PADR(oObj:cRotinaTrans,10) 
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,16)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR17", "checkbox", "Aglutina Itens do Município", "L" )
	uUpdate := oObj:lAglutinaPorCodServ
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,17)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR18", "checkbox", "Ativa Logs", "L")
	uUpdate := GetNewPar("ZZ_LOGNFSE",.T.)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,18)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("MV_PAR19", "checkbox", "Cód. do Prod. na Discr.", "L" )
	uUpdate := GetNewPar("ZZ_SHWCDP",.F.) 
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,19)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("MV_PAR20", "checkbox", "Detalha Prod. na Discr.", "L")
	uUpdate := GetNewPar("ZZ_SHWDTD",.F.) 
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,20)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("MV_PAR21", "get", "Separador de Linhas NFS-e", "C", 40 , 10 )
	uUpdate := PADR(GetNewPar("ZZ_NFSESEP","//"),10)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,21)
	oParamBox:addParam(oParam)	

	oParam := IpParamObject():newIpParamObject("MV_PAR22", "get", "Série da NFS-e", "C", 40 , 03 )
	uUpdate := PADR(GetNewPar("ZZ_NFSESER","A  "),3)
	oParam:setInitializer( uUpdate )
	saveParBox(cGroupPerg,uUpdate,22)
	oParamBox:addParam(oParam)
				
return

/*
	Define os Atributos do Objeto conforme as Perguntas de Exportação
*/
Static Function defineParameters(oObj,oParamBox)
	
	PutMV("MV_REGIESP",oParamBox:getValue("MV_PAR01"))
	PutMV("MV_OPTSIMP",oParamBox:getValue("MV_PAR02"))
	PutMV("MV_INCECUL",oParamBox:getValue("MV_PAR03"))
	PutMV("MV_INCEFIS",oParamBox:getValue("MV_PAR04"))	
	PutMV("ZZ_DIRTMP" ,oParamBox:getValue("MV_PAR05"))
	PutMV("ZZ_CHVCERT",oParamBox:getValue("MV_PAR06"))
	PutMV("ZZ_NFSEUSR",oParamBox:getValue("MV_PAR07"))
	PutMV("ZZ_NFSEPAS",oParamBox:getValue("MV_PAR08"))
	PutMV("MV_ITEMAGL",Iif(oParamBox:getValue("MV_PAR09"),"S","N"))
	PutMV("ZZ_CFOPNFS",oParamBox:getValue("MV_PAR10"))
	PutMV("ZZ_NFSELOT",oParamBox:getValue("MV_PAR11"))
	PutMV("ZZ_URLNFSE",oParamBox:getValue("MV_PAR12"))
	PutMV("ZZ_URLNFSH",oParamBox:getValue("MV_PAR13"))
	PutMV("ZZ_LOGNFSE",oParamBox:getValue("MV_PAR18"))
	PutMV("ZZ_SHWCDP",oParamBox:getValue("MV_PAR19"))
	PutMV("ZZ_SHWDTD",oParamBox:getValue("MV_PAR20"))
	PutMV("ZZ_NFSESEP",oParamBox:getValue("MV_PAR21"))
	PutMV("ZZ_NFSESER",oParamBox:getValue("MV_PAR22"))	
	
	dbSelectArea("CC2")
	CC2->(dbSetOrder(1)) //CC2_FILIAL+CC2_EST+CC2_CODMUN
	If CC2->(MsSeek(xFilial("CC2")+oObj:cEstado+oObj:cCodMun))
		If RecLock("CC2",.F.)
			If CC2->(FieldPos("CC2_ZZROTE")) > 0
				CC2->CC2_ZZROTE := oParamBox:getValue("MV_PAR14")
			Endif
			If CC2->(FieldPos("CC2_ZZROTI")) > 0
				CC2->CC2_ZZROTI := oParamBox:getValue("MV_PAR15") 
			Endif
			If CC2->(FieldPos("CC2_ZZROTS")) > 0
				CC2->CC2_ZZROTS := oParamBox:getValue("MV_PAR16")
			Endif
			If CC2->(FieldPos("CC2_ZZAGLU")) > 0
				CC2->CC2_ZZAGLU := Iif(oParamBox:getValue("MV_PAR17"),"1","2")
			Endif
			CC2->(MsUnLock())			
		Endif
	Endif
	    
	SuperGetMv()
		
Return