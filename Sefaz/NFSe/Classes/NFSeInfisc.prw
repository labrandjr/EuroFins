#INCLUDE "msobject.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "nfseinfisc.ch"

/*/{Protheus.doc} NFSeInfisc

Classe que representa o objeto de conectvidade dp Protheus com o sistema NFS-e Infisc

@author Winston Dellano de Castro
@since 21/12/2015

/*/

class NFSeInfisc

data cTitle
data cEstado
data cCodMun
data cCnpj
data cRazao
data cFantasia
data cInscMun
data cEndCob
data cNumber
data cBairro
data cNomeMun
data cCepEnt
data cCodPais
data cNomePais

data nVlrTotServ
data nVlrTotDesc
data nVlrTotNota
data nVlrTotLiqd
data aVlrRetTotal
data nTotLiqFat
data aVlrTotISS

data cNFSe

//Atributos Retorno Consulta NFSe
data cChvAcesso
data cCnpjRet
data cDHRecbto
data cMot
data cProt
data cSignature
data cSit
data cSitNFSe
data cVersao

method newNFSeInfisc() constructor

method getTitle()
method setTitle()

method getEstado()
method setEstado()

method getCodMun()
method setCodMun()

method getCnpj()
method setCnpj()

method getRazao()
method setRazao()

method getFantasia()
method setFantasia()

method getInscMun()
method setInscMun()

method getEndCob()
method setEndCob()

method getNumber()
method setNumber()

method getBairro()
method setBairro()

method getNomeMun()
method setNomeMun()

method getCepEnt()
method setCepEnt()

method getCodPais()
method setCodPais()

method getNomePais()
method setNomePais()

method getVlrRetTotal()
method setVlrRetTotal()

method getVlrTotISS()
method setVlrTotISS()

method getTotLiqFat()
method setTotLiqFat()

method getVlrTotDesc()
method setVlrTotDesc()

method getVlrTotLiqd()
method setVlrTotLiqd()

method getVlrTotNota()
method setVlrTotNota()

method getVlrTotServ()
method setVlrTotServ()

method getNFSe()
method setNFSe()

method getChvAcesso()
method setChvAcesso()

method getCnpjRet()
method setCnpjRet()

method getDHRecbto()
method setDHRecbto()

method getMot()
method setMot()

method getProt()
method setProt()

method getSignature()
method setSignature()

method getSit()
method setSit()

method getSitNFSe()
method setSitNFSe()

method getVersao()
method setVersao()

method loadOfInvoiceHeader()
method enviarLoteNotas()
method pedidoStatusLote()
method consultaNFSe()
method procConsultNFSe()
method retConsultaNFSe()
method atualizaRetorno()
method validSitPedido()
method retStatusProtheus()
method loadQuery()

endClass

/*/{Protheus.doc} newNFSeInfisc

Metodo construtor da classe NFSeInfisc

@author Winston Dellano de Castro
@since 21/12/2015

/*/
method newNFSeInfisc(cTitle) class NFSeInfisc

	::setTitle(cTitle)

	loadCompanyData(self)

return

/*/{Protheus.doc} getTitle

Coleta o título do browser

@author Winston Dellano de Castro
@since 21/12/2015

@return character título do browser
/*/
method getTitle() class NFSeInfisc
return ::cTitle

/*/{Protheus.doc} setTitle

Define o título do browser

@author Winston Dellano de Castro
@since 21/12/2015

@param cTitle,character,título do browser
/*/
method setTitle(cTitle) class NFSeInfisc
	::cTitle := cTitle
return

/*/{Protheus.doc} getEstado

Coleta a unidade federativa do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character unidade federativa do Prestador
/*/
method getEstado() class NFSeInfisc
return ::cEstado

/*/{Protheus.doc} setEstado

Define a unidade federativa do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cEstado,character,unidade federativa do Prestador
/*/
method setEstado(cEstado) class NFSeInfisc
	::cEstado := cEstado
return

/*/{Protheus.doc} getCodMun

Coleta o código do município do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character código do município do Prestador
/*/
method getCodMun() class NFSeInfisc
return ::cCodMun

/*/{Protheus.doc} setCodMun

Define o código do município do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cCodMun,character,código do município do Prestador
/*/
method setCodMun(cCodMun) class NFSeInfisc
	::cCodMun := cCodMun
return

/*/{Protheus.doc} getCnpj

Coleta o Cnpj do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character Cnpj do Prestador
/*/
method getCnpj() class NFSeInfisc
return ::cCnpj

/*/{Protheus.doc} setCnpj

Define o Cnpj do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cCnpj,character,Cnpj do Prestador
/*/
method setCnpj(cCnpj) class NFSeInfisc
	::cCnpj := cCnpj
return

/*/{Protheus.doc} getRazao

Coleta a Razao Social do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character Razao do Prestador
/*/
method getRazao() class NFSeInfisc
return ::cRazao

/*/{Protheus.doc} setRazao

Define a Razao Social do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cRazao,character,Razao do Prestador
/*/
method setRazao(cRazao) class NFSeInfisc
	::cRazao := cRazao
return

/*/{Protheus.doc} getFantasia

Coleta o Nome Fantasia do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character Fantasia do Prestador
/*/
method getFantasia() class NFSeInfisc
return ::cFantasia

/*/{Protheus.doc} setFantasia

Define o Nome Fantasia do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cFantasia,character,Fantasia do Prestador
/*/
method setFantasia(cFantasia) class NFSeInfisc
	::cFantasia := cFantasia
return

/*/{Protheus.doc} getInscMun

Coleta a Inscrição Municipal do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character Inscrição Municipal do Prestador
/*/
method getInscMun() class NFSeInfisc
return ::cInscMun

/*/{Protheus.doc} setInscMun

Define a Inscrição Municipal do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cInscMun,character,Inscrição Municipal do Prestador
/*/
method setInscMun(cInscMun) class NFSeInfisc
	::cInscMun := cInscMun
return

/*/{Protheus.doc} getEndCob

Coleta o Endereço do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character Endereço do Prestador
/*/
method getEndCob() class NFSeInfisc
return ::cEndCob

/*/{Protheus.doc} setEndCob

Define o Endereço do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cEndCob,character,Endereço do Prestador
/*/
method setEndCob(cEndCob) class NFSeInfisc
	::cEndCob := cEndCob
return

/*/{Protheus.doc} getNumber

Coleta o Número do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character Número do Prestador
/*/
method getNumber() class NFSeInfisc
return ::cNumber

/*/{Protheus.doc} setNumber

Define o Número do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cNumber,character,Número do Prestador
/*/
method setNumber(cNumber) class NFSeInfisc
	::cNumber := cNumber
return

/*/{Protheus.doc} getBairro

Coleta o Bairro do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@return character Bairro do Prestador
/*/
method getBairro() class NFSeInfisc
return ::cBairro

/*/{Protheus.doc} setBairro

Define o Bairro do Prestador

@author Winston Dellano de Castro
@since 21/12/2015

@param cBairro,character,Bairro do Prestador
/*/
method setBairro(cBairro) class NFSeInfisc
	::cBairro := cBairro
return

/*/{Protheus.doc} getNomeMun

Coleta o Nome do município do Prestador

@author Winston Dellano de Castro
@since 07/01/2016

@return character Nome do município do Prestador
/*/
method getNomeMun() class NFSeInfisc
return ::cNomeMun

/*/{Protheus.doc} setNomeMun

Define o Nome do município do Prestador

@author Winston Dellano de Castro
@since 07/01/2016

@param cNomeMun,character,Nome do município do Prestador
/*/
method setNomeMun(cNomeMun) class NFSeInfisc
	::cNomeMun := cNomeMun
return

/*/{Protheus.doc} getCepEnt

Coleta o Código postal do Prestador

@author Winston Dellano de Castro
@since 07/01/2016

@return character Código postal do Prestador
/*/
method getCepEnt() class NFSeInfisc
return ::cCepEnt

/*/{Protheus.doc} setCepEnt

Define o Código postal do Prestador

@author Winston Dellano de Castro
@since 07/01/2016

@param cCepEnt,character,Código postal do Prestador
/*/
method setCepEnt(cCepEnt) class NFSeInfisc
	::cCepEnt := cCepEnt
return

/*/{Protheus.doc} getCodPais

Coleta o Código do país do Prestador

@author Winston Dellano de Castro
@since 07/01/2016

@return character Código do país do Prestador
/*/
method getCodPais() class NFSeInfisc
return ::cCodPais

/*/{Protheus.doc} setCodPais

Define o Código do país do Prestador

@author Winston Dellano de Castro
@since 07/01/2016

@param cCodPais,character,Código do país do Prestador
/*/
method setCodPais(cCodPais) class NFSeInfisc
	::cCodPais := cCodPais
return

/*/{Protheus.doc} getNomePais

Coleta o Nome do país do Prestador

@author Winston Dellano de Castro
@since 07/01/2016

@return character Nome do país do Prestador
/*/
method getNomePais() class NFSeInfisc
return ::cNomePais

/*/{Protheus.doc} setNomePais

Define o Nome do país do Prestador

@author Winston Dellano de Castro
@since 07/01/2016

@param cNomePais,character,Nome do país do Prestador
/*/
method setNomePais(cNomePais) class NFSeInfisc
	::cNomePais := cNomePais
return

/*/{Protheus.doc} getVlrRetTotal

Coleta array com o valor total de cada uma das retenções federais

@author Winston Dellano de Castro
@since 12/01/2016

@return array Valor total de cada uma das retenções federais
/*/
method getVlrRetTotal(nPos) class NFSeInfisc
return ::aVlrRetTotal[1][nPos]

/*/{Protheus.doc} setVlrRetTotal

Define array com o valor total de cada uma das retenções federais

@author Winston Dellano de Castro
@since 12/01/2016

@param aVlrRetTotal,array,Valor total de cada uma das retenções federais
/*/
method setVlrRetTotal(aVlrRetTotal) class NFSeInfisc
	::aVlrRetTotal := aVlrRetTotal
return

/*/{Protheus.doc} getVlrTotISS

Coleta o array com os valores totais do ISSQN [ISS]

@author Winston Dellano de Castro
@since 12/01/2016

@return array Valores totais do ISSQN [ISS]
/*/
method getVlrTotISS(nPos) class NFSeInfisc
return ::aVlrTotISS[1][nPos]

/*/{Protheus.doc} setVlrTotISS

Define o array com os valores totais do ISSQN [ISS]

@author Winston Dellano de Castro
@since 12/01/2016

@param aVlrTotISS,array,Valores totais do ISSQN [ISS]
/*/
method setVlrTotISS(aVlrTotISS) class NFSeInfisc
	::aVlrTotISS := aVlrTotISS
return

/*/{Protheus.doc} getTotLiqFat

Coleta o valor líquido total das faturas

@author Winston Dellano de Castro
@since 12/01/2016

@return numeric Valor líquido total das faturas
/*/
method getTotLiqFat() class NFSeInfisc
return ::nTotLiqFat

/*/{Protheus.doc} setTotLiqFat

Define o valor líquido total das faturas

@author Winston Dellano de Castro
@since 12/01/2016

@param nTotLiqFat,numeric,Valor líquido total das faturas
/*/
method setTotLiqFat(nTotLiqFat) class NFSeInfisc
	::nTotLiqFat := nTotLiqFat
return

/*/{Protheus.doc} getVlrTotDesc

Coleta o valor total de desconto

@author Winston Dellano de Castro
@since 12/01/2016

@return numeric Valor total de desconto
/*/
method getVlrTotDesc() class NFSeInfisc
return ::nVlrTotDesc

/*/{Protheus.doc} setVlrTotDesc

Define o valor total de desconto

@author Winston Dellano de Castro
@since 12/01/2016

@param nVlrTotDesc,numeric,Valor total de desconto
/*/
method setVlrTotDesc(nVlrTotDesc) class NFSeInfisc
	::nVlrTotDesc := nVlrTotDesc
return

/*/{Protheus.doc} getVlrTotLiqd

Coleta o valor líquido total da nota

@author Winston Dellano de Castro
@since 12/01/2016

@return numeric Valor líquido total da nota
/*/
method getVlrTotLiqd() class NFSeInfisc
return ::nVlrTotLiqd

/*/{Protheus.doc} setVlrTotLiqd

Define o valor líquido total da nota

@author Winston Dellano de Castro
@since 12/01/2016

@param nVlrTotLiqd,numeric,Valor líquido total da nota
/*/
method setVlrTotLiqd(nVlrTotLiqd) class NFSeInfisc
	::nVlrTotLiqd := nVlrTotLiqd
return

/*/{Protheus.doc} getVlrTotNota

Coleta o valor total da nota

@author Winston Dellano de Castro
@since 12/01/2016

@return numeric Valor total da nota
/*/
method getVlrTotNota() class NFSeInfisc
return ::nVlrTotNota

/*/{Protheus.doc} setVlrTotNota

Define o valor total da nota

@author Winston Dellano de Castro
@since 12/01/2016

@param nVlrTotNota,numeric,Valor total da nota
/*/
method setVlrTotNota(nVlrTotNota) class NFSeInfisc
	::nVlrTotNota := nVlrTotNota
return

/*/{Protheus.doc} getVlrTotServ

Coleta o valor total de serviços

@author Winston Dellano de Castro
@since 12/01/2016

@return numeric Valor total de serviços
/*/
method getVlrTotServ() class NFSeInfisc
return ::nVlrTotServ

/*/{Protheus.doc} setVlrTotServ

Define o valor total de serviços

@author Winston Dellano de Castro
@since 12/01/2016

@param nVlrTotServ,numeric,Valor total de serviços
/*/
method setVlrTotServ(nVlrTotServ) class NFSeInfisc
	::nVlrTotServ := nVlrTotServ
return

/*/{Protheus.doc} getNFSe

Coleta o código numérico aleatório que faz parte da chave de acesso da NFS-e

@author Winston Dellano de Castro
@since 22/01/2016

@return character código numérico aleatório que faz parte da chave de acesso da NFS-e
/*/
method getNFSe() class NFSeInfisc
return ::cNFSe

/*/{Protheus.doc} setNFSe

Define o código numérico aleatório que faz parte da chave de acesso da NFS-e

@author Winston Dellano de Castro
@since 22/01/2016

@param cNFSe, character, código numérico aleatório que faz parte da chave de acesso da NFS-e
/*/
method setNFSe(cNFSe) class NFSeInfisc
	::cNFSe := cNFSe
return

method getChvAcesso() class NFSeInfisc
return ::cChvAcesso

method setChvAcesso(cChvAcesso) class NFSeInfisc
	::cChvAcesso := alltrim(cChvAcesso)
return

method getCnpjRet() class NFSeInfisc
return ::cCnpjRet

method setCnpjRet(cCnpjRet) class NFSeInfisc
	::cCnpjRet := alltrim(cCnpjRet)
return

method getDHRecbto() class NFSeInfisc
return ::cDHRecbto

method setDHRecbto(cDHRecbto) class NFSeInfisc
	::cDHRecbto := alltrim(cDHRecbto)
return

method getMot() class NFSeInfisc
return ::cMot

method setMot(cMot) class NFSeInfisc
	::cMot := alltrim(cMot)
return

method getProt() class NFSeInfisc
return ::cProt

method setProt(cProt) class NFSeInfisc
	::cProt := alltrim(cProt)
return

method getSignature() class NFSeInfisc
return ::cSignature

method setSignature(cSignature) class NFSeInfisc
	::cSignature := alltrim(cSignature)
return

method getSit() class NFSeInfisc
return ::cSit

method setSit(cSit) class NFSeInfisc
	::cSit := alltrim(cSit)
return

method getSitNFSe() class NFSeInfisc
return ::cSitNFSe

method setSitNFSe(cSitNFSe) class NFSeInfisc
	::cSitNFSe := alltrim(cSitNFSe)
return

method getVersao() class NFSeInfisc
return ::cVersao

method setVersao(cVersao) class NFSeInfisc
	::cVersao := alltrim(cVersao)
return

/*/{Protheus.doc} loadOfInvoiceHeader

Carrega dados do Cabeçalho das NF de Saída

@author Winston Dellano de Castro
@since 15/01/2016

@return ResultSet Cabeçalho das NF de Saída
/*/
method loadOfInvoiceHeader() class NFSeInfisc

	local cQuery          := ""
	local cGroupQuestions := Padr("NFEINFISC",Len(SX1->X1_GRUPO))

	SX1->(dbSetOrder(1))
	if !(SX1->(dbSeek(cGroupQuestions)))
		validQuestions(@cGroupQuestions)
	endif

	if !(Pergunte(cGroupQuestions,.T.))
		lCancelado:= .t.
		return
	else
		lCancelado:= .f.
	endif

	cQuery += "SELECT F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_EMISSAO,F2_HORA,F2_VALBRUT," + CRLF
	cQuery += "       F2_VALCOFI,F2_VALCSLL,F2_VALINSS,F2_VALIRRF,F2_VALISS,F2_VALPIS, " + CRLF
	cQuery += "       F2.R_E_C_N_O_ AS F2_RECNO,F2_FIMP,F2_RECISS                      " + CRLF
	cQuery += "FROM " + retSqlName("SF2") + " F2                                       " + CRLF
	cQuery += "WHERE F2_FILIAL  = '" + xFilial("SF2") + "' AND                         " + CRLF
	cQuery += "      F2_DOC     BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' AND  " + CRLF
	cQuery += "      F2_SERIE   BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' AND  " + CRLF
	cQuery += "      F2_CLIENTE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' AND  " + CRLF
	cQuery += "      F2_LOJA    BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' AND  " + CRLF
	cQuery += "      F2.D_E_L_E_T_ = ' '                                               " + CRLF

	TCQUERY cQuery NEW ALIAS "QSF2"

return

/*/{Protheus.doc} pedidoStatusLote

(Descrição da Função, Classe ou Método)

@author Winston Dellano de Castro
@since 22/01/2016

@param xParam, TipoParam, DescricaoDoParam

@return TipoRet DescricaoRet
/*/
method pedidoStatusLote() class NFSeInfisc
return

/*/{Protheus.doc} enviarLoteNotas

Realiza o envio da Nota Fiscal Eletrônica de Serviço de Garibaldi-RS

@author Winston Dellano de Castro
@since 21/12/2015

@param xParam,TipoParam,DescricaoDoParam

@return TipoRet DescricaoRet
/*/
method enviarLoteNotas() class NFSeInfisc

	//	local oWsdl    	:= WSServicosService():new()
	local lOk      	:= .F.
	local cRetorno 	:= ""
	local cXml     	:= ""
	Private cMsgInfo	:= ""

	::loadOfInvoiceHeader()

	if lCancelado
		Return
	endif
	if QSF2->(!(Eof()))
		cXml := getXmlEnvio(self)

		/*lOk := oWsdl:enviarLoteNotas()

		MsgAlert(oWsdl:cReturn,"Retorno do WS")*/

		//		cXml := getXmlEnvio(self)
		//		u_TWsdlGaribaldi(cXml)

		/*if lOk
		//cRetorno := oWsdl:obterCriticaLote()
		Aviso("NFSe",oWsdl:cReturn,{"OK"},3)
		else
		Aviso("NFSe","Problema de Comunicação",{"OK"},3)
		endif*/
	else
		Aviso("NFSe","Nenhuma Nota Fiscal transmitida. Reveja os parâmetros informados.",{"OK"},3)
	endif

	QSF2->(dbCloseArea())

return

/*/{Protheus.doc} consultaNFSe

Realiza a Consulta de NFSe

@author Thiago Meschiatti
@since 23/03/2016

@param xParam,TipoParam,DescricaoDoParam

/*/
method consultaNFSe() class NFSeInfisc
	Private cMsgInfo	:= ""

	::loadQuery()

	if lCancelado
		Return
	endif

	Processa( {|| ::procConsultNFSe() }, "Aguarde...", "Processando...",.F.)

return

/*/{Protheus.doc} procConsultNFSe

Realiza a Consulta de NFSe

@author Thiago Meschiatti
@since 23/03/2016

@param xParam,TipoParam,DescricaoDoParam

/*/
method procConsultNFSe() class NFSeInfisc

	QSF2->(DbGoTop())
	ProcRegua(QSF2->(RecCount()))
	QSF2->(DbGoTop())

	if QSF2->(!(Eof()))
		while QSF2->(!(Eof()))
			IncProc()
			cMsgInfo += "NFSe: " + QSF2->F2_DOC + "/" + QSF2->F2_SERIE + CRLF

			if QSF2->F2_FIMP == 'G' .and. !empty(QSF2->F2_FIMP)
				u_NFSeConsulta(, alltrim(QSF2->F2_CHVNFE), self)
			else
				if QSF2->F2_FIMP == ' '
					cMsgInfo += "XML da NFS-e não foi gerado. Efetue a geração do XML para realizar a consulta." + CRLF
				elseif QSF2->F2_FIMP == 'S'
					cMsgInfo += "NFS-e autorizada." + CRLF
				else
					cMsgInfo += "NFS-e sem chave de acesso. Não foi possível realizar a consulta." + CRLF
				endif
			endif
			QSF2->(dbSkip())
		enddo
	endif

	QSF2->(dbCloseArea())

	Aviso("NFSe",cMsgInfo,{"Ok"},3,"Resultado do Processamento")

return

/*/{Protheus.doc} retConsultaNFSe

Leitura de Retorno do Método de ConsultaNFSe

@author Winston Dellano de Castro
@since 21/12/2015

@param cXmlRet,TipoParam,Xml de retorno da consulta
/*/
method retConsultaNFSe(cXmlRet) class NFSeInfisc

	local cError    := ""
	local cWarning  := ""
	local cXml		:= ""
	local lRet		:= .t.
	local aRet		:= {}

	Private oObj		:= nil

	oObj := XmlParser(cXmlRet, "_", @cError, @cWarning)

	if !(Empty(cError)) .or. !(Empty(cWarning))
		cMsgInfo += "Falha no parser do arquivo de retorno nível 1." + CRLF
	else
		cNodeRet	:= "oObj:_ENV_ENVELOPE:_ENV_BODY:_NS1_CONSULTARNOTAFISCALRESPONSE:_RETURN:TEXT"
		if type(cNodeRet) == "U"
			cMsgInfo += "Não foi possível ler arquivo de retorno." + CRLF
			lRet	 := .f.
		else
			cXml	:= &(cNodeRet)
			cXml	:= noAccent(cXml)
			cError  := ""
			cWarning:= ""

			oObj 		:= XmlParser(cXml, "_", @cError, @cWarning)
			if !(Empty(cError)) .or. !(Empty(cWarning))
				cMsgInfo += "Falha no parser do arquivo de retorno nível 2." + CRLF
				lRet	 := .f.
			else
				cNodeRet := "oObj:_RESCONSULTATRANS"
				if type(cNodeRet) == "O"
					::setChvAcesso(&(cNodeRet+":_CHVACESSONFS_E:TEXT"))
					::setCnpjRet(&(cNodeRet+":_CNPJ:TEXT"))
					::setDhRecbto(&(cNodeRet+":_DHRECBTO:TEXT"))
					::setMot(&(cNodeRet+":_MOT:TEXT"))
					::setProt(&(cNodeRet+":_NPROT:TEXT"))
					::setSignature(&(cNodeRet+":_SIGNATURE:TEXT"))
					::setSit(&(cNodeRet+":_SIT:TEXT"))
					::setSitNFSe(&(cNodeRet+":_SITNFS_E:TEXT"))
					::setVersao(&(cNodeRet+":_VERSAO:TEXT"))
				else
					lRet := .f.
				endif
			endif
		endif
	endif
return (lRet)

/*/{Protheus.doc} atualizaRetorno

Atualiza status da NFSe

@author Thiago Meschiatti
@since 23/03/16
/*/
method atualizaRetorno() class NFSeInfisc
	local oSql 	:= IpSqlObject():newIpSqlObject()

	if ::validSitPedido()[1]
		oSql:update("SF2", "F2_FIMP = '"+::retStatusProtheus()+"' ", "F2_CHVNFE = '" + ::getChvAcesso() + "' ")
	else
		cMsgInfo += ::validSitPedido()[2] + CRLF
	endif

return

/*/{Protheus.doc} validLote

Metodo que consulta situação do Pedido de Consulta

@author Thiago Meschiatti
@since 23/03/16

/*/
method validSitPedido() class NFSeInfisc
	local aRet := {}

	if ::getSit() == "200"
		aRet := {.f., ::getMot() + ". Consulta rejeitada."}
	else
		aRet := {.t., ""}
	endif

return (aRet)

/*/{Protheus.doc} rerStatusProtheus

Metodo que realiza de/para de Status para código Protheus

@author Thiago Meschiatti
@since 23/03/16

/*/
method retStatusProtheus() class NFSeInfisc
	local cRet := ""

	if ::getSitNFSe() == "1"
		cRet := 'S' //para uso autorizado
		cMsgInfo += "NFS-e autorizada." + CRLF
	elseif ::getSitNFSe() == "2"
		cRet := 'X' //para NFS-e substituta de outra NFS-e
		cMsgInfo += "NFS-e substituta de outra NFS-e." + CRLF
	elseif ::getSitNFSe() == "4"
		cRet := 'Y' //para NFS-e substituída por outra NFS-e
		cMsgInfo += "NFS-e substituída por outra NFS-e." + CRLF
	elseif ::getSitNFSe() == "6"
		cRet := 'Z' //para NFS-e corrigida
		cMsgInfo += "NFS-e corrigida." + CRLF
	else
		cRet := 'G' //para XML gerado com sucesso
	endif

return (cRet)

/**
* Coleta o Xml de envio da Nota Fiscal
**/
static function getXmlEnvio(oSelf)

	local cXml       := ""
	local cCData     := Dtos(dDataBase)
	local cDTrans    := Substr(cCData,1,4) + "-" + Substr(cCData,5,2) + "-" + Substr(cCData,7,2)
	local cHTrans    := AllTrim(Time())
	local cFinalPath := ""
	local cArquivo   := ""
	local aRecnos    := {}

	cXml += '<?xml version="1.0" encoding="UTF-8"?>'
	cXml += '<envioLote versao="1.0">'
	cXml += '<CNPJ>' + oSelf:getCnpj() + '</CNPJ>'
	cXml += '<dhTrans>' + cDTrans + ' ' + cHTrans + '</dhTrans>'

	while QSF2->(!(Eof()))
		if QSF2->F2_FIMP <> 'S'
			cXml += '<NFS-e>'
			cXml += getXmlNFe(@oSelf)

			aAdd(aRecnos,{QSF2->F2_RECNO, getChaveAcesso(oSelf)})

			cXml += '</NFS-e>'
		else
			cMsgInfo += "NFSe: " + QSF2->F2_DOC + "/" + QSF2->F2_SERIE + CRLF
			cMsgInfo += "NFS-e já autorizada." + CRLF
		endif

		QSF2->(dbSkip())
	enddo

	/*cXml += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
	cXml += getSignature(@oSelf)
	cXml += '</Signature>'*/
	cXml += '</envioLote>'

	cFinalPath := cGetFile("Arquivos (*.XML) |*.XML|","Salvar arquivo em:",0,"",.T.,GETF_RETDIRECTORY + GETF_LOCALHARD)
	cFinalPath := if(Empty(AllTrim(cFinalPath)),"C:\",AllTrim(cFinalPath))
	cFinalPath := cFinalPath + cCData + "_" + oSelf:getNFSe() + ".xml"
	cArquivo   := cCData + "_" + oSelf:getNFSe() + ".xml"

	memoWrit(cArquivo,cXml)

	if _CopyFile(cArquivo,cFinalPath)
		updateSF2(@aRecnos)
		cMsgInfo += "XML gravado com sucesso na pasta " + AllTrim(cFinalPath) + "."
		Aviso("NFSe",cMsgInfo,{"Ok"},3,"Resultado do Processamento")
	else
		MsgAlert("Problemas ao gravar o XML na pasta " + AllTrim(cFinalPath) + ".","NFSe")
	endif

return cXml

/**
*
**/
static function updateSF2(aRecnos)

	local nAux := 1
	local nLen := Len(aRecnos)

	for nAux := 1 to nLen
		dbSelectArea("SF2")
		dbGoTop()
		dbGoTo(aRecnos[nAux, N_RECNO])

		SF2->(RecLock("SF2",.F.))
		SF2->F2_FIMP 	:= 'G'
		SF2->F2_CHVNFE	:= aRecnos[nAux, CHAVE_NFE]
		SF2->(MsUnLock())
	next

return

/**
* Retorna o Xml das Notas Fiscais
**/
static function getXmlNFe(oSelf)

	local cdEmi	     := Substr(QSF2->F2_EMISSAO,1,4) + "-" + Substr(QSF2->F2_EMISSAO,5,2) + "-" + Substr(QSF2->F2_EMISSAO,7,2)
	local cXmlNFe    := ""
	local cdVenc     := ""
	local cFaturas   := ""
	Local cMensCli   := ""
	local nBaseIss   := 0
	local nValrIss   := 0
	local nVlrIss    := 0
	local nItemNota  := 0
	local aTomS	     := {}
	local aRetencoe  := {}
	Local nISSST     := QSF2->F2_VALBRUT * (GetMV("MV_ALIQISS")/100)
	Local cQueryP    := ""
	Local nParcelas  := 1
	Local cAlias     := getNextAlias()
	Local nI         := 1
	Local nRegsP     := 0
	Local nPISP      := 0
	Local nCOFINSP   := 0
	Local nCSLLP     := 0
	Local nRetP      := 0
	Local lRetP      := .F.
	Local lRetencoes

	oSelf:setNFSe(StrZero(Randomize(0,999999999),9,0))
	aTomS := loadTomadorData(@oSelf)

	cQueryP := " SELECT E1_PIS " + CRLF
	cQueryP += "      , E1_COFINS " +  CRLF
	cQueryP += "      , E1_CSLL " + CRLF
	cQueryP += "   FROM " + retSqlTab("SE1") + CRLF
	cQueryP += "  WHERE E1_NUM = '" + AllTrim(QSF2->F2_DOC) + "'" + CRLF
	cQueryP += "    AND E1_SERIE = '" + AllTrim(QSF2->F2_SERIE) + "'" + CRLF
	cQueryP += "    AND E1_TIPO = 'NF' " + CRLF
	cQueryP += "    AND " + retSqlDel("SE1") + CRLF
	cQueryP += "    AND " + retSqlFil("SE1") + CRLF

	TcQuery cQueryP new Alias (cAlias)

	Count to nRegsP

	(cAlias)->(DbCloseArea())

	cXmlNFe += '<infNFSe versao="1.1">'
	cXmlNFe += '	<Id>'
	cXmlNFe += '		<cNFS-e>' + oSelf:getNFSe() + '</cNFS-e>'
	cXmlNFe += '		<mod>90</mod>'
	cXmlNFe += '		<serie>'  + AllTrim(QSF2->F2_SERIE) + '</serie>'
	cXmlNFe += '		<nNFS-e>' + AllTrim(QSF2->F2_DOC)   + '</nNFS-e>'
	cXmlNFe += '		<dEmi>'   + AllTrim(cdEmi)         + '</dEmi>'
	cXmlNFe += '		<hEmi>'   + AllTrim(QSF2->F2_HORA)  + '</hEmi>'
	cXmlNFe += '		<tpNF>1</tpNF>'
	cXmlNFe += '		<refNF>' + getChaveAcesso(@oSelf) + '</refNF>'
	cXmlNFe += '		<tpImp>1</tpImp>'
	cXmlNFe += '		<tpEmis>N</tpEmis>'
	cXmlNFe += '		<cancelada>N</cancelada>'
	cXmlNFe += '		<canhoto>1</canhoto>'
	cXmlNFe += '	</Id>'
	cXmlNFe += '	<prest>'
	cXmlNFe += '		<CNPJ>'    + oSelf:getCnpj()     + '</CNPJ>'
	cXmlNFe += '		<xNome>'   + noAccent(oSelf:getRazao())    + '</xNome>'
	cXmlNFe += '		<xFant>'   + oSelf:getFantasia() + '</xFant>'
	cXmlNFe += '		<IM>'      + oSelf:getInscMun()  + '</IM>'
	cXmlNFe += '		<xEmail>faturamentoalac@eurofins.com</xEmail>'
	cXmlNFe += '		<xSite>www.eurofins.com.br</xSite>'
	cXmlNFe += '		<end>'
	cXmlNFe += '			<xLgr>'    + oSelf:getEndCob()   + '</xLgr>'
	cXmlNFe += '			<nro>'     + oSelf:getNumber()   + '</nro>'
	//	cXmlNFe += '			<xCpl>Sala</xCpl>'
	cXmlNFe += '			<xBairro>' + oSelf:getBairro()   + '</xBairro>'
	cXmlNFe += '			<cMun>'    + oSelf:getCodMun()   + '</cMun>'
	cXmlNFe += '			<xMun>'    + oSelf:getNomeMun()  + '</xMun>'
	cXmlNFe += '			<UF>'      + oSelf:getEstado()   + '</UF>'
	cXmlNFe += '			<CEP>'     + oSelf:getCepEnt()   + '</CEP>'
	cXmlNFe += '			<cPais>'   + oSelf:getCodPais()  + '</cPais>'
	cXmlNFe += '			<xPais>'   + oSelf:getNomePais() + '</xPais>'
	cXmlNFe += '		</end>'
	cXmlNFe += '		<fone>5433883232</fone>'
	//	cXmlNFe += '		<fone2>5499999999</fone2>'
	//	cXmlNFe += '		<IE>0291234567</IE>'
	cXmlNFe += '		<regimeTrib>3</regimeTrib>'
	cXmlNFe += '	</prest>'
	cXmlNFe += '	<TomS>'
	if Len(AllTrim(aTomS[TOMS_CPF])) > 11
		cXmlNFe += '	<CNPJ>'  + AllTrim(aTomS[TOMS_CPF])   + '</CNPJ>'
	else
		cXmlNFe += '	<CPF>'  + AllTrim(aTomS[TOMS_CPF])   + '</CPF>'
	endif
	cXmlNFe += '		<xNome>' + noAccent(AllTrim(aTomS[TOMS_XNOME])) + '</xNome>'
	cXmlNFe += '		<ender>'
	cXmlNFe += '			<xLgr>'    + AllTrim(aTomS[TOMS_ENDER_XLGR])    + '</xLgr>'
	cXmlNFe += '			<nro>'     + AllTrim(aTomS[TOMS_ENDER_NRO])     + '</nro>'
	cXmlNFe += '			<xCpl>'    + AllTrim(aTomS[TOMS_ENDER_XCPL])    + '</xCpl>'
	cXmlNFe += '			<xBairro>' + noAccent(AllTrim(aTomS[TOMS_ENDER_XBAIRRO])) + '</xBairro>'
	cXmlNFe += '			<cMun>'    + AllTrim(aTomS[TOMS_ENDER_CMUN])    + '</cMun>'
	cXmlNFe += '			<xMun>'    + AllTrim(aTomS[TOMS_ENDER_XMUN])    + '</xMun>'
	cXmlNFe += '			<UF>'      + AllTrim(aTomS[TOMS_ENDER_UF])      + '</UF>'
	cXmlNFe += '			<CEP>'     + AllTrim(aTomS[TOMS_ENDER_CEP])     + '</CEP>'
	cXmlNFe += '			<cPais>'   + AllTrim(aTomS[TOMS_CPAIS])         + '</cPais>'
	cXmlNFe += '			<xPais>'   + AllTrim(aTomS[TOMS_XPAIS])         + '</xPais>'
	cXmlNFe += '		</ender>'
	cXmlNFe += '		<xEmail>' + AllTrim(SA1->A1_ZZNFMAI) + '</xEmail>'
	cXmlNFe += '		<IE>'     + AllTrim(aTomS[TOMS_IE])  + '</IE>'
	cXmlNFe += '		<IM>'     + AllTrim(aTomS[TOMS_IM])  + '</IM>'
	cXmlNFe += '		<fone>'   + Alltrim(StrTran(StrTran(AllTrim(SA1->A1_DDD) + AllTrim(SA1->A1_TEL),".",""),"-","")) + '</fone>'
	//	cXmlNFe += '		<fone2>'  + aTomS[] + '</fone2>'
	cXmlNFe += '	</TomS>'
	/*	cXmlNFe += '	<dadosDaObra>'
	cXmlNFe += '		<xLogObra>Av Santos</xLogObra>'
	cXmlNFe += '		<xComplObra>Sala</xComplObra>'
	cXmlNFe += '		<vNumeroObra>320</vNumeroObra>'
	cXmlNFe += '		<xBairroObra>Centro</xBairroObra>'
	cXmlNFe += '		<xCepObra>95020460</xCepObra>'
	cXmlNFe += '		<cCidadeObra>4308607</cCidadeObra>'
	cXmlNFe += '		<xCidadeObra>Garibaldi</xCidadeObra>'
	cXmlNFe += '		<xUfObra>RS</xUfObra>'
	cXmlNFe += '		<cPaisObra>01058</cPaisObra>'
	cXmlNFe += '		<xPaisObra>Brasil</xPaisObra>'
	cXmlNFe += '		<numeroArt>123456789012</numeroArt>'
	cXmlNFe += '		<numeroCei>123456789012</numeroCei>'
	cXmlNFe += '		<numeroProj>846548</numeroProj>'
	cXmlNFe += '		<numeroMatri>8494546</numeroMatri>'
	cXmlNFe += '	</dadosDaObra>'*/
	/*	cXmlNFe += '	<transportadora>'
	cXmlNFe += '		<xNomeTrans>Transportadora Ficticia LTDA</xNomeTrans>'
	cXmlNFe += '		<xCpfCnpjTrans>26578334000130</xCpfCnpjTrans>'
	cXmlNFe += '		<xInscEstTrans>1232185494</xInscEstTrans>'
	cXmlNFe += '		<xPlacaTrans>IBB6962</xPlacaTrans>'
	cXmlNFe += '		<xEndTrans>Av. Carlos Gomes</xEndTrans>'
	cXmlNFe += '		<cMunTrans>4308607</cMunTrans>'
	cXmlNFe += '		<xMunTrans>Garibaldi</xMunTrans>'
	cXmlNFe += '		<xUfTrans>RS</xUfTrans>'
	cXmlNFe += '		<cPaisTrans>01058</cPaisTrans>'
	cXmlNFe += '		<xPaisTrans>Brasil</xPaisTrans>'
	cXmlNFe += '		<vTipoFreteTrans>0</vTipoFreteTrans>'
	cXmlNFe += '	</transportadora>'*/

	sumItems()

	aRetencoes := valueRetencoes()
	nItemNota  := 0

	nRetIR := 0
	nRetISS := 0
	nRetPIS := 0
	nRetCofins := 0
	nRetCSLL := 0
	nRetINSS := 0
	nRetImps := 0
    //alterado por Leandro Cesar 23/02/2023 - retirar a duplicidade de cálculo do valor do ISS
    nISSST := 0

	while QSD2->(!(Eof()))

		/* dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + QSD2->D2_COD)*/ //vfv
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + QSD2->D2_CODISS)

		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"60"+ QSD2->D2_CODISS)

		nItemNota += 1

		cXmlNFe += '	<det>'
		cXmlNFe += '		<nItem>'        + AllTrim(StrZero(nItemNota,5,0)) + '</nItem>'
		cXmlNFe += '		<serv>'
		//	cXmlNFe += '			<cServ>'    + Padr(AllTrim(Substr(SB1->B1_CODISS,1,8)),8,"0") + '</cServ>'  //VFV
		cXmlNFe += '			<cServ>'    + Padr(AllTrim(Substr(QSD2->D2_CODISS,1,8)),8,"0") + '</cServ>'
		//		cXmlNFe += '			<cLCServ>1405</cLCServ>'
		cXmlNFe += '			<cLCServ>'+LEFT(Padr(AllTrim(Substr(QSD2->D2_CODISS,1,8)),8,"0"),4)+'</cLCServ>'
		//cXmlNFe += '			<xServ>'    + AllTrim(SB1->B1_DESC)           + '</xServ>' //vfv
		cXmlNFe += '			<xServ>'    + AllTrim(SubStr(SX5->X5_DESCRI,1,55))           + '</xServ>'
        if SA1->A1_EST == "EX"
            cXmlNFe += '			<localVerifResServ>2</localVerifResServ>'
        else
            cXmlNFe += '			<localTributacao>' + oSelf:getCodMun()        + '</localTributacao>'
        Endif
		If QSF2->F2_RECISS<>'2'//Regis Ferreira 11/11/19
			//Essa linha estava comentada
            cXmlNFe += '			<localVerifResServ>1</localVerifResServ>'
		endif

		cXmlNFe += '			<uTrib>'    + AllTrim(QSD2->D2_UM)             + '</uTrib>'
		//		cXmlNFe += '			<uTrib>'    + AllTrim(SB1->B1_UM)             + '</uTrib>'  //VFV
		cXmlNFe += '			<qTrib>'    + ConvType(1               ,14,02) + '</qTrib>'
		cXmlNFe += '			<vUnit>'    + ConvType(QSD2->D2_TOTAL ,14,02) + '</vUnit>'
		cXmlNFe += '			<vServ>'    + ConvType(QSD2->D2_TOTAL  ,14,02) + '</vServ>'
		cXmlNFe += '			<vDesc>0.00</vDesc>'

		/*
		if SA1->A1_SIMPNAC == "1"
		cXmlNFe += '			<vBCISS>0.00</vBCISS>'
		cXmlNFe += '			<pISS>0.00</pISS>'
		cXmlNFe += '			<vISS>0.00</vISS>'

		nBaseIss := 0
		nValrIss := 0
		else
		*/
		nVlrIss := QSD2->D2_BASEISS * QSD2->D2_ALIQISS / 100

		If QSF2->F2_RECISS<>'1'//Braz 08/11/19
			cXmlNFe += '			<vBCISS>'   + ConvType(QSD2->D2_BASEISS,15,02) + '</vBCISS>'
			cXmlNFe += '			<pISS>'     + ConvType(QSD2->D2_ALIQISS,05,02) + '</pISS>'
			cXmlNFe += '			<vISS>'     + ConvType(nVlrIss, 15, 02) + '</vISS>'
		Endif
		//cXmlNFe += '			<vISS>'     + ConvType(QSD2->D2_VALISS,15,02) + '</vISS>'

		nBaseIss += QSD2->D2_BASEISS
		nValrIss += nVlrIss
		//nValrIss += QSD2->D2_VALISS
		//		endif

		cXmlNFe += '			<vBCINSS>'  + ConvType(QSD2->D2_BASEINS,15,02) + '</vBCINSS>'
		cXmlNFe += '			<pRetINSS>' + ConvType(QSD2->D2_ALIQINS,05,02) + '</pRetINSS>'
		cXmlNFe += '			<vRetINSS>' + ConvType(QSD2->D2_VALINS ,15,02) + '</vRetINSS>'
		//		cXmlNFe += '			<vRetINSS>' + ConvType(getRetencao(aRetencoes,"IN-",2),15,02) + '</vRetINSS>'

		nRetINSS += QSD2->D2_VALINS

		cXmlNFe += '			<vRed>0.00</vRed>'

		nVlrIRRF  := getRetencao(aRetencoes,"IR-",2)
		nAliqIRRF := iif(nVlrIRRF>0,QSD2->D2_ALQIRRF,0)
		nBaseIRRF := QSD2->D2_BASEIRR

		if nVlrIRRF - round((nAliqIRRF/100) * nBaseIRRF,2) > 0.01
			nBaseIRRF := round(nVlrIRRF / (nAliqIRRF/100),getSX3Cache("D2_BASEIRR","X3_DECIMAL"))
		endif

		cXmlNFe += '			<vBCRetIR>'    + ConvType(nBaseIRRF,15,02) + '</vBCRetIR>'
		cXmlNFe += '			<pRetIR>'      + ConvType(nAliqIRRF,05,02) + '</pRetIR>'
		//		cXmlNFe += '			<vRetIR>'      + ConvType(QSD2->D2_VALIRRF,15,02) + '</vRetIR>'
		cXmlNFe += '			<vRetIR>'      + ConvType(nVlrIRRF,15,02) + '</vRetIR>'

		lRetencoes := QSD2->(D2_VALCOF+D2_VALCSL+D2_VALPIS)>=(SuperGetMv("MV_ZZRTCOF")+SuperGetMv("MV_ZZRTCSL")+SuperGetMv("MV_ZZRTPIS"))

		// Aqui

		if nRegsP > 1 .or. nRegsP = 1
			TcQuery cQueryP new Alias (cAlias)
			While (cAlias)->(!eof()) .AND. !lRetP
				nRetP := (cAlias)->E1_PIS+(cAlias)->E1_COFINS+(cAlias)->E1_CSLL
				if nRetP >= (SuperGetMv("MV_ZZRTCOF")+SuperGetMv("MV_ZZRTCSL")+SuperGetMv("MV_ZZRTPIS"))
					lRetP := .T.
				endif
				(cAlias)->(DbSkip())
			enddo
			(cAlias)->(DbCloseArea())
		endif



		cXmlNFe += '			<vBCCOFINS>'   + ConvType(QSD2->D2_BASECOF,15,02) + '</vBCCOFINS>'
		//cXmlNFe += '			<pRetCOFINS>'  + ConvType(iif(lRetencoes,QSD2->D2_ALQCOF,0) ,05,02) + '</pRetCOFINS>'

		if lRetP
			cXmlNFe += '			<pRetCOFINS>'  + ConvType(iif(lRetencoes,QSD2->D2_ALQCOF,0) ,05,02) + '</pRetCOFINS>'
			cXmlNFe += '			<vRetCOFINS>'  + ConvType(iif(lRetencoes,QSD2->D2_VALCOF,0) ,15,02) + '</vRetCOFINS>'
		else
			cXmlNFe += '			<pRetCOFINS>'  + ConvType(0,05,02) + '</pRetCOFINS>'
			cXmlNFe += '			<vRetCOFINS>'  + ConvType(0,15,02) + '</vRetCOFINS>'
		endif
		//		cXmlNFe += '			<vRetCOFINS>'  + ConvType(getRetencao(aRetencoes,"CF-",2),15,02) + '</vRetCOFINS>'

		nRetCofins += QSD2->D2_VALCOF

		cXmlNFe += '			<vBCCSLL>'     + ConvType(QSD2->D2_BASECSL,15,02) + '</vBCCSLL>'
		//cXmlNFe += '			<pRetCSLL>'    + ConvType(iif(lRetencoes,QSD2->D2_ALQCSL,0) ,05,02) + '</pRetCSLL>'
		//cXmlNFe += '			<vRetCSLL>'    + ConvType(iif(QSD2->D2_VALCSL>=SuperGetMv( "MV_ZZRTCOF"),QSD2->D2_VALCSL,0) ,15,02) + '</vRetCSLL>'

		if lRetP
			cXmlNFe += '			<pRetCSLL>'    + ConvType(iif(lRetencoes,QSD2->D2_ALQCSL,0) ,05,02) + '</pRetCSLL>'
			cXmlNFe += '			<vRetCSLL>'    + ConvType(iif(lRetencoes,QSD2->D2_VALCSL,0) ,15,02) + '</vRetCSLL>'
		else
			cXmlNFe += '			<pRetCSLL>'    + ConvType(0,05,02) + '</pRetCSLL>'
			cXmlNFe += '			<vRetCSLL>'    + ConvType(0,15,02) + '</vRetCSLL>'
		endif

		//		cXmlNFe += '			<vRetCSLL>'    + ConvType(getRetencao(aRetencoes,"CS-",2),15,02) + '</vRetCSLL>'

		nRetCSLL += QSD2->D2_VALCSL

		cXmlNFe += '			<vBCPISPASEP>' + ConvType(QSD2->D2_BASEPIS,15,02) + '</vBCPISPASEP>'
		//cXmlNFe += '			<pRetPISPASEP>'+ ConvType(iif(lRetencoes,QSD2->D2_ALQPIS,0) ,05,02) + '</pRetPISPASEP>'
		//cXmlNFe += '			<vRetPISPASEP>'+ ConvType(ConvType(iif(QSD2->D2_VALPIS>=SuperGetMv( "MV_ZZRTCOF"),QSD2->D2_VALPIS,0) ,15,02) ,15,02) + '</vRetPISPASEP>'

		if lRetP
			cXmlNFe += '			<pRetPISPASEP>'+ ConvType(iif(lRetencoes,QSD2->D2_ALQPIS,0) ,05,02) + '</pRetPISPASEP>'
			cXmlNFe += '			<vRetPISPASEP>'+ ConvType(iif(lRetencoes,QSD2->D2_VALPIS,0) ,15,02) + '</vRetPISPASEP>'
		else
			cXmlNFe += '			<pRetPISPASEP>'+ ConvType(0,05,02) + '</pRetPISPASEP>'
			cXmlNFe += '			<vRetPISPASEP>'+ ConvType(0,15,02) + '</vRetPISPASEP>'
		endif

		//		cXmlNFe += '			<vRetPISPASEP>'+ ConvType(getRetencao(aRetencoes,"PI-",2),15,02) + '</vRetPISPASEP>'

		nRetPIS += QSD2->D2_VALPIS

		cXmlNFe += '		</serv>'
		If QSF2->F2_RECISS == '1'//Braz-08-11-19
			cXmlNFe += '		<ISSST>'
			cXmlNFe += '			<vRedBCST>0.00</vRedBCST>
			cXmlNFe += '			<vBCST>' + ConvType(QSF2->F2_VALBRUT,15,02) + '</vBCST>
			cXmlNFe += '			<pISSST>'+ ConvType(GetMV("MV_ALIQISS"),05,02) + '</pISSST>
			cXmlNFe += '			<vISSST>'+ ConvType(QSF2->F2_VALBRUT*(GetMV("MV_ALIQISS")/100), 15, 02) + '</vISSST>
			cXmlNFe += '		</ISSST>'
		Endif
		cXmlNFe += '	</det>'
		QSD2->(dbSkip())
	enddo

	cMensCli:= MensNota(QSF2->F2_CLIENTE, QSF2->F2_LOJA, QSF2->F2_SERIE, QSF2->F2_DOC)

	if !SA1->A1_ZZTPCOB $ 'B/D'
		cMensCli+= Posicione("SX5",1,xFilial("SX5")+"ZX"+SA1->A1_ZZTPCOB,"X5_DESCRI")+" "
	endif
	QSD2->(dbCloseArea())

	// Aqui

	loadTotais(@oSelf,@aRetencoes)
	lRetencoes := (nRetPIS+nRetCOFINS+nRetCSLL)>=(SuperGetMv( "MV_ZZRTPIS")+SuperGetMv( "MV_ZZRTCOF")+SuperGetMv( "MV_ZZRTCSL"))
	cXmlNFe += '	<total>'
	cXmlNFe += '		<vServ>' + ConvType(oSelf:getVlrTotServ(),15,02) + '</vServ>'
	cXmlNFe += '		<vDesc>' + ConvType(oSelf:getVlrTotDesc(),15,02) + '</vDesc>'
	cXmlNFe += '		<vtNF>'  + ConvType(oSelf:getVlrTotNota(),15,02) + '</vtNF>'
	//	cXmlNFe += '		<vtLiq>' + ConvType(oSelf:getVlrTotLiqd(),15,02) + '</vtLiq>'
	If QSF2->F2_RECISS=='1'//Braz 8/11/19
		if lRetP
			cXmlNFe += '		<vtLiq>' + ConvType(oSelf:getVlrTotLiqd()-nRetISS-IIf(lRetencoes,(nRetPIS+nRetCOFINS+nRetCSLL),0) ,15,02)  +  '</vtLiq>'
		else
			cXmlNFe += '		<vtLiq>' + ConvType(oSelf:getVlrTotLiqd()-nRetISS-0,15,02)  +  '</vtLiq>'
		endif
	Else
		if lRetP
			cXmlNFe += '		<vtLiq>' + ConvType(oSelf:getVlrTotLiqd()-nRetISS-IIf(lRetencoes,(nRetPIS+nRetCOFINS+nRetCSLL),0),15,02)  +  '</vtLiq>'
		else
			cXmlNFe += '		<vtLiq>' + ConvType(oSelf:getVlrTotLiqd()-nRetISS-0,15,02)  +  '</vtLiq>'
		endif
	Endif

	cXmlNFe += '		<Ret>'

	//rfr-pcc

	//ALTERADO RICARDO REY 05/09/18
	cXmlNFe += '			<vRetIR>'       + ConvType(getRetencao(aRetencoes,"IR-",3) ,15,02) + '</vRetIR>'

	/*
	cXmlNFe += '			<vRetIR>'       + ConvType(getRetencao(aRetencoes,"IR-",3) ,15,02) + '</vRetIR>'
	cXmlNFe += '			<vRetINSS>'     + ConvType(getRetencao(aRetencoes,"IN-",3) ,15,02) + '</vRetINSS>'
	cXmlNFe += '			<vRetPISPASEP>' + ConvType(getRetencao(aRetencoes,"PI-",3) ,15,02) + '</vRetPISPASEP>'
	cXmlNFe += '			<vRetCOFINS>'   + ConvType(getRetencao(aRetencoes,"CF-",3) ,15,02) + '</vRetCOFINS>'
	cXmlNFe += '			<vRetCSLL>'     + ConvType(getRetencao(aRetencoes,"CS-",3) ,15,02) + '</vRetCSLL>'
	*/
	//	if nRetIR > 0
	//		cXmlNFe += '			<vRetIR>'       + ConvType(nRetIR ,15,02) + '</vRetIR>'
	//	endif
	if nRetINSS > 0
		cXmlNFe += '			<vRetINSS>'     + ConvType(nRetINSS ,15,02) + '</vRetINSS>'
	endif
	if nRetPIS > 0
		if lRetP
			cXmlNFe += '			<vRetPISPASEP>' + ConvType(iif(lRetencoes,nRetPIS,0) ,15,02) + '</vRetPISPASEP>'
		else
			cXmlNFe += '			<vRetPISPASEP>' + ConvType(0 ,15,02) + '</vRetPISPASEP>'
		endif
	endif
	if nRetCOFINS > 0
		if lRetP
			cXmlNFe += '			<vRetCOFINS>'   + ConvType(iif(lRetencoes,nRetCOFINS,0) ,15,02) + '</vRetCOFINS>'
		else
			cXmlNFe += '			<vRetCOFINS>'   + ConvType(0 ,15,02) + '</vRetCOFINS>'
		endif
	endif
	if nRetCSLL > 0
		if lRetP
			cXmlNFe += '			<vRetCSLL>'     + ConvType(iif(lRetencoes,nRetCSLL,0),15,02) + '</vRetCSLL>'
		else
			cXmlNFe += '			<vRetCSLL>'     + ConvType(0,15,02) + '</vRetCSLL>'
		endif
	endif
	//fim pcc

	cXmlNFe += '		</Ret>'
	//	cXmlNFe += '		<vtLiqFaturas>' + ConvType(oSelf:getTotLiqFat(),15,02) + '</vtLiqFaturas>'
	If QSF2->F2_RECISS=='1'
		if lRetP
			cXmlNFe += '		<vtLiqFaturas>' + ConvType(oSelf:getVlrTotLiqd()-nRetISS-;
			iif(lRetencoes,+nRetPIS+nRetCOFINS+nRetCSLL,0) - nIssST,15,02) + '</vtLiqFaturas>'
		else
			cXmlNFe += '		<vtLiqFaturas>' + ConvType(oSelf:getVlrTotLiqd()-nRetISS-;
			0 - nIssST,15,02) + '</vtLiqFaturas>'
		endif

	Else
		if lRetP
			cXmlNFe += '		<vtLiqFaturas>' + ConvType(oSelf:getVlrTotLiqd()-nRetISS-;
			iif(lRetencoes,+nRetPIS+nRetCOFINS+nRetCSLL,0),15,02) + '</vtLiqFaturas>'
		else
			cXmlNFe += '		<vtLiqFaturas>' + ConvType(oSelf:getVlrTotLiqd()-nRetISS-;
			0,15,02) + '</vtLiqFaturas>'
		endif
	Endif
	cXmlNFe += '		<ISS>'
	If QSF2->F2_RECISS=='1' //Braz 08-11-19
		cXmlNFe += '			<vBCSTISS>' + ConvType(QSF2->F2_VALBRUT,15,02) + '</vBCSTISS>
		cXmlNFe += '			<vSTISS>'+ ConvType(QSF2->F2_VALBRUT*(GetMV("MV_ALIQISS")/100), 15, 02) + '</vSTISS>
	Else
		cXmlNFe += '			<vBCISS>' + ConvType(nBaseIss ,15,02) + '</vBCISS>'
		cXmlNFe += '			<vISS>'   + ConvType(nValrIss ,15,02) + '</vISS>'
	Endif

	cXmlNFe += '		</ISS>'

	cXmlNFe += '	</total>'

	dbSelectArea("SE1")
	dbSetOrder(2)
	dbSeek(xFilial("SE1") + QSF2->F2_CLIENTE + QSF2->F2_LOJA + QSF2->F2_SERIE + QSF2->F2_DOC)

	cFaturas  := ""
	nItemNota := 0

	while SE1->(!(Eof())) .AND. SE1->E1_FILIAL  == xFilial("SE1")  .AND.;
	SE1->E1_CLIENTE == QSF2->F2_CLIENTE .AND.;
	SE1->E1_LOJA    == QSF2->F2_LOJA    .AND.;
	SE1->E1_PREFIXO == QSF2->F2_SERIE   .AND.;
	SE1->E1_NUM     == QSF2->F2_DOC

		if AllTrim(SE1->E1_TIPO) == "NF"

			cdVenc := Dtos(SE1->E1_VENCTO)
			cdVenc := Substr(cdVenc,1,4) + "-" + Substr(cdVenc,5,2) + "-" + Substr(cdVenc,7,2)
			nItemNota += 1

			cFaturas += '		<fat>'
			cFaturas += '			<nItem>' + AllTrim(StrZero(nItemNota,1,0)) + '</nItem>'
			cFaturas += '			<nFat>'  + AllTrim(SE1->E1_NUM) + AllTrim(SE1->E1_PARCELA) + '</nFat>'
			cFaturas += '			<dVenc>' + cdVenc + '</dVenc>'
			If (nRetPis + nRetCofins + nRetCSLL) >= (SuperGetMv("MV_ZZRTPIS")+SuperGetMv( "MV_ZZRTCOF")+SuperGetMv( "MV_ZZRTCSL"))
				if AllTrim(SE1->E1_PARCELA) == "1" .or. Empty(SE1->E1_PARCELA)
					If QSF2->F2_RECISS=='1' //Braz
						if lRetP
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-getRetencao(aRetencoes,"IR-",2)-getRetencao(aRetencoes,"IS-",2)-E1_PIS-E1_COFINS-E1_CSLL-nISSST,15,02)) + '</vFat>'
						else
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-getRetencao(aRetencoes,"IR-",2)-getRetencao(aRetencoes,"IS-",2)-0,15,02)) + '</vFat>'
						endif
					Else
						if lRetP
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-getRetencao(aRetencoes,"IR-",2)-E1_PIS-E1_COFINS-E1_CSLL,15,02)) + '</vFat>'
						else
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-getRetencao(aRetencoes,"IR-",2)-0,15,02)) + '</vFat>'
						endif
					Endif
				Else
					If QSF2->F2_RECISS=='1' //Braz
						if lRetP
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-E1_PIS-E1_COFINS-E1_CSLL-getRetencao(aRetencoes,"IS-",2),15,02)) + '</vFat>'
						else
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-0-getRetencao(aRetencoes,"IS-",2),15,02)) + '</vFat>'
						endif
					Else
						if lRetP
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-E1_PIS-E1_COFINS-E1_CSLL,15,02)) + '</vFat>'
						else
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-0,15,02)) + '</vFat>'
						endif
					Endif
				Endif
			Else
				if AllTrim(SE1->E1_PARCELA) == "1" .or. Empty(SE1->E1_PARCELA)
					If QSF2->F2_RECISS=='1' //Braz
						cFaturas += '			<vFat>' + ConvType(SE1->E1_VLCRUZ-getRetencao(aRetencoes,"IR-",2)-getRetencao(aRetencoes,"IS-",2),15,02) + '</vFat>'
					Else
						cFaturas += '			<vFat>' + ConvType(SE1->E1_VLCRUZ-getRetencao(aRetencoes,"IR-",2),15,02) + '</vFat>'
					Endif
				else
					If QSF2->F2_RECISS=='1' //Braz
						if lRetP
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-E1_PIS-E1_COFINS-E1_CSLL-getRetencao(aRetencoes,"IS-",2),15,02)) + '</vFat>'
						else
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-0-getRetencao(aRetencoes,"IS-",2),15,02)) + '</vFat>'
						endif
					Else
						if lRetP
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-E1_PIS-E1_COFINS-E1_CSLL,15,02)) + '</vFat>'
						else
							cFaturas += '			<vFat>' + SE1->(ConvType(E1_VLCRUZ-0,15,02)) + '</vFat>'
						endif
					Endif
				endif
			Endif
			cFaturas += '		</fat>'

		endif

		SE1->(dbSkip())
	enddo

	if !(Empty(cFaturas))
		cXmlNFe += '	<faturas>'
		cXmlNFe += cFaturas
		cXmlNFe += '	</faturas>'
	endif

    if SA1->A1_EST == "EX"
	    cXmlNFe += '	<infAdicES>S</infAdicES>'
	else
		cXmlNFe += '	<infAdicLT>' + oSelf:getCodMun() + '</infAdicLT>'
    endif
	cXmlNFe += '	<infAdic>' + cMensCli + '</infAdic>'
	//cXmlNFe += '	<infAdic>Teste de transmissao</infAdic>'
	cXmlNFe += '</infNFSe>'

return cXmlNFe

/**
* Retorna o valor da retenção
**/
static function getRetencao(aRetencoes,cTipo,nKind)

	local nValue := 0
	local nAux   := 0

	nAux := aScan(aRetencoes,{|x| x[1] == AllTrim(cTipo)})

	if nAux > 0
		nValue := aRetencoes[nAux][nKind]
	endif

return nValue

/**
* Calcula as retenções
**/
static function valueRetencoes()

	local cQuery  := ""
	local nTotIt  := 0
	local aReturn := {}

	/*
	cQuery := "SELECT D2_ALIQINS,D2_ALIQISS,D2_ALQCOF,D2_ALQCSL,D2_ALQIRRF,D2_ALQPIS,D2_UM,D2_COD,D2_TES," + CRLF
	cQuery += "       COUNT(D2_FILIAL) IT_TOTAL "
	cQuery += "FROM " + retSqlName("SD2") + " D2 "

	cQuery += "INNER JOIN "+ SF4->(RetSQLName("SF4")) +" AS F4 ON " + CRLF
	cQuery += "     F4.F4_FILIAL  =  '"+ SF4->(xFILIAL("SF4")) +"' " + CRLF
	cQuery += " AND F4.F4_CODIGO  =  D2.D2_TES " + CRLF
	cQuery += " AND F4.F4_AGREG   <> 'N' " + CRLF // Somente TES que agrega valor
	cQuery += " AND F4.F4_DUPLIC  <> 'N' " + CRLF // Somente TES que gera duplicata
	cQuery += " AND F4.D_E_L_E_T_ =  ' ' " + CRLF

	cQuery += "WHERE D2_FILIAL  = '" + xFilial("SD2")   + "' AND "
	cQuery += "		 D2_DOC     = '" + QSF2->F2_DOC     + "' AND "
	cQuery += " 	 D2_SERIE   = '" + QSF2->F2_SERIE   + "' AND "
	cQuery += "		 D2_CLIENTE = '" + QSF2->F2_CLIENTE + "' AND "
	cQuery += "		 D2_LOJA    = '" + QSF2->F2_LOJA    + "' AND "
	cQuery += "      D2.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY D2_ALIQINS,D2_ALIQISS,D2_ALQCOF,D2_ALQCSL,D2_ALQIRRF,D2_ALQPIS,D2_UM,D2_COD,D2_TES" + CRLF

	TCQUERY cQuery NEW ALIAS "TQRY"

	nTotIt := TQRY->IT_TOTAL

	TQRY->(dbCloseArea())
	*/

	//cQuery := "SELECT E1_TIPO,SUM(E1_VALOR) RET_TOT "
	cQuery := "SELECT E1_TIPO,SUM(E1_VLCRUZ) RET_TOT "
	cQuery += "FROM " + retSqlName("SE1") + " E1    "
	cQuery += "WHERE E1_FILIAL  = '" + xFilial("SE1")   + "' AND "
	cQuery += "      E1_CLIENTE = '" + QSF2->F2_CLIENTE + "' AND "
	cQuery += "      E1_LOJA    = '" + QSF2->F2_LOJA    + "' AND "
	cQuery += "      E1_PREFIXO = '" + QSF2->F2_SERIE   + "' AND "
	cQuery += "      E1_NUM     = '" + QSF2->F2_DOC     + "' AND "
	cQuery += "      E1_TIPO    LIKE '%-%'                   AND "
	cQuery += "      E1.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY E1_TIPO"

	TCQUERY cQuery NEW ALIAS "QRYT"

	while QRYT->(!(Eof()))

		//aAdd(aReturn,{AllTrim(QRYT->E1_TIPO),(QRYT->RET_TOT/nTotIt),QRYT->RET_TOT})
		aAdd(aReturn,{AllTrim(QRYT->E1_TIPO) , QRYT->RET_TOT , QRYT->RET_TOT})

		QRYT->(dbSkip())
	enddo

	QRYT->(dbCloseArea())

return aReturn

/**
* Retorna o total geral das retenções
**/
static function getTotRetencao(aRetencoes)

	local nTotal := 0
	local nAux   := 0

	for nAux := 1 to Len(aRetencoes)
		nTotal += aRetencoes[nAux][3]
	next

return nTotal

/**
* Carrega valores para o grupo de tags total
**/
static function loadTotais(oSelf,aRetencoes)

	local cQuery       := ""
	local aVlrTotISS   := {}
	local nTotRetencao := getTotRetencao(aRetencoes)
	Local nTotServ     := 0

	cQuery := "SELECT SUM(D2_TOTAL) V_TOTSERV, SUM(D2_DESCON) V_TOTDESC "
	cQuery += "FROM  " + retSqlName("SD2") + " D2 "

	cQuery += "INNER JOIN "+ SF4->(RetSQLName("SF4")) +" AS F4 ON " + CRLF
	cQuery += "     F4.F4_FILIAL  =  '"+ SF4->(xFILIAL("SF4")) +"' " + CRLF
	cQuery += " AND F4.F4_CODIGO  =  D2.D2_TES " + CRLF
	cQuery += " AND F4.F4_AGREG   <> 'N' " + CRLF // Somente TES que agrega valor
	cQuery += " AND F4.F4_DUPLIC  <> 'N' " + CRLF // Somente TES que gera duplicata
	cQuery += " AND F4.D_E_L_E_T_ =  ' ' " + CRLF

	cQuery += "WHERE "
	cQuery += "D2_FILIAL  = '" + xFilial("SD2")   + "' AND "
	cQuery += "D2_DOC     = '" + QSF2->F2_DOC     + "' AND "
	cQuery += "D2_SERIE   = '" + QSF2->F2_SERIE   + "' AND "
	cQuery += "D2_CLIENTE = '" + QSF2->F2_CLIENTE + "' AND "
	cQuery += "D2_LOJA    = '" + QSF2->F2_LOJA    + "' AND "
	cQuery += "D2.D_E_L_E_T_ = ' ' "

	TCQUERY cQuery NEW ALIAS "QRY"

	dbSelectArea("SF3")
	dbSetOrder(5)
	dbSeek(xFilial("SF3") + QSF2->F2_SERIE + QSF2->F2_DOC + QSF2->F2_CLIENTE + QSF2->F2_LOJA) // F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA

	oSelf:setVlrTotNota(QSF2->F2_VALBRUT)

	oSelf:setVlrTotServ(QRY->V_TOTSERV)
	oSelf:setVlrTotDesc(0)
	oSelf:setVlrTotLiqd(SF3->F3_VALCONT - nTotRetencao)

	QRY->(dbCloseArea())

	//cQuery := "SELECT SUM(E1_VALOR) V_LIQFAT "
	cQuery := "SELECT SUM(E1_VLCRUZ) V_LIQFAT "
	cQuery += "FROM  " + retSqlName("SE1") + " E1 "
	cQuery += "WHERE "
	cQuery += "E1_FILIAL  = '" + xFilial("SE1")   + "' AND "
	cQuery += "E1_CLIENTE = '" + QSF2->F2_CLIENTE + "' AND "
	cQuery += "E1_LOJA    = '" + QSF2->F2_LOJA    + "' AND "
	cQuery += "E1_PREFIXO = '" + QSF2->F2_SERIE   + "' AND "
	cQuery += "E1_NUM     = '" + QSF2->F2_DOC     + "' AND "
	cQuery += "E1_TIPO    = 'NF'                       AND "
	cQuery += "D_E_L_E_T_ = ' ' "

	TCQUERY cQuery NEW ALIAS "QRY"

	oSelf:setTotLiqFat(QRY->V_LIQFAT - nTotRetencao)

	QRY->(dbCloseArea())

	//	aAdd(aVlrTotISS,{0,QSF2->F2_VALISS})

	//	oSelf:setVlrTotISS(aVlrTotISS)

return

/**
* 43494546000001199000S000000976218736215
**/
static function getChaveAcesso(oSelf,cNFSe)

	local cCodIBGE     := SubStr(Alltrim(oSelf:getCodMun()),1,2)
	local cCNPJ        := oSelf:getCnpj()
	local cModeloNF    := "90"
	local cSerie       := Padr(AllTrim(QSF2->F2_SERIE),3,"0")
	local cNumDoc      := PadL(AllTrim(QSF2->F2_DOC)  ,9,"0")
	local cChaveAcesso := cCodIBGE + cCNPJ + cModeloNF + cSerie + cNumDoc + oSelf:getNFSe()

return cChaveAcesso

/**
* Retorna a assinatura eletronica
**/
static function getSignature(oSelf)

	local cSignature := ""

	cSignature := '<SignedInfo>'
	cSignature += '	<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
	cSignature += '	<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
	cSignature += '	<Reference URI="">'
	cSignature += '	<Transforms>'
	cSignature += '		<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
	cSignature += '		<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
	cSignature += '	</Transforms>'
	cSignature += '	<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
	cSignature += '	<DigestValue>hsr+JtpASOG8Yf+gZt7BOuzGWeY=</DigestValue>'
	cSignature += '	</Reference>'
	cSignature += '</SignedInfo>'
	cSignature += '<SignatureValue>eKea3wK5XOdH+9KBNk/ZzeVa8tPLp5mllkeOXx+ABMCCiXh4xTRyshvCc+16VELCU+anY/3TswzPpoxM3hSEct2kNfBYFnZVjXzUoD1Sl9rOAq2mj5Kbaft58fA/Q8JhVssgnCtLtd5itN59iHQh4MBF40nX0tFXtJ4U9AsxNrM=</SignatureValue>'
	cSignature += '<KeyInfo>'
	cSignature += '	<X509Data>'
	cSignature += '		<X509SubjectName></X509SubjectName> ' // CN=SILVA e SILVA LTDA,OU=(EM BRANCO),OU=(EM BRANCO),OU=(EM BRANCO),OU=(EM BRANCO),OU=(EM BRANCO),OU=49454600000119,OU=(EM BRANCO),O=ICP-Brasil,C=BR
	cSignature += '		<X509Certificate></X509Certificate>'
	cSignature += '	</X509Data>'
	cSignature += '</KeyInfo>'

return cSignature

/**
* Coleta os dados do Prestador
**/
static function loadCompanyData(oSelf)

	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(cEmpAnt + cFilAnt))

	/*if SM0->(dbSeek("04" + "01"))*/
	oSelf:setEstado(Alltrim(SM0->M0_ESTENT))
	oSelf:setCodMun(SM0->M0_CODMUN)
	oSelf:setCnpj(Alltrim(SM0->M0_CGC))
	oSelf:setRazao(Alltrim(SM0->M0_NOMECOM))
	oSelf:setFantasia(Alltrim(SM0->M0_NOME))
	oSelf:setInscMun(Alltrim(SM0->M0_INSCM))
	oSelf:setEndCob(ConvType(AllTrim(FisGetEnd(SM0->M0_ENDCOB)[1])))
	oSelf:setNumber(ConvType(FisGetEnd(SM0->M0_ENDCOB)[2]))
	oSelf:setBairro(ConvType(SM0->M0_BAIRCOB))
	oSelf:setNomeMun(ConvType(SM0->M0_CIDENT))
	oSelf:setCepEnt(ConvType(SM0->M0_CEPENT))
	oSelf:setCodPais("01058")
	oSelf:setNomePais("Brasil")
	/*else
	oSelf:setEstado("RS")
	oSelf:setCodMun("4308607")
	oSelf:setCnpj("94088952000152")
	oSelf:setRazao("LABORATORIO ALAC LTDA")
	oSelf:setFantasia("ALAC")
	oSelf:setInscMun("")
	oSelf:setEndCob("ROD ENG. ERMENIO OLIVEIRA PENTEADO")
	oSelf:setNumber("")
	oSelf:setBairro("TOMBADOURO")
	oSelf:setNomeMun("GARIBALDI")
	oSelf:setCepEnt("95720000")
	oSelf:setCodPais("01058")
	oSelf:setNomePais("Brasil")
	endif*/

return

/**
* Coleta os dados do Tomador
**/
static function loadTomadorData(oSelf)

	local aTomS := {}

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + QSF2->F2_CLIENTE + QSF2->F2_LOJA)

	aTomS := {	if(Empty(SA1->A1_CGC),"00000000000000",AllTrim(SA1->A1_CGC)),;
	SA1->A1_NOME,;
	ConvType(AllTrim(FisGetEnd(SA1->A1_END)[1])),;
	ConvType(FisGetEnd(SA1->A1_END)[2]),;
	SA1->A1_COMPLEM,;
	SA1->A1_BAIRRO,;
	retCodUF(SA1->A1_EST) + AllTrim(SA1->A1_COD_MUN),;
	SA1->A1_MUN,;
	SA1->A1_EST,;
	SA1->A1_CEP,;
	SA1->A1_INSCR,;
	SA1->A1_INSCRM,;
	SA1->A1_CODPAIS,;
	Alltrim(Posicione("CCH",1,xFilial("CCH") + SA1->A1_CODPAIS,"CCH_PAIS"))}

return aTomS

/**
* Retorna o código UF
**/
static function retCodUF(cUF)

	local cRetCodUF := ""
	local aUF       := {}

	aAdd(aUF,{"RO","11"})
	aAdd(aUF,{"AC","12"})
	aAdd(aUF,{"AM","13"})
	aAdd(aUF,{"RR","14"})
	aAdd(aUF,{"PA","15"})
	aAdd(aUF,{"AP","16"})
	aAdd(aUF,{"TO","17"})
	aAdd(aUF,{"MA","21"})
	aAdd(aUF,{"PI","22"})
	aAdd(aUF,{"CE","23"})
	aAdd(aUF,{"RN","24"})
	aAdd(aUF,{"PB","25"})
	aAdd(aUF,{"PE","26"})
	aAdd(aUF,{"AL","27"})
	aAdd(aUF,{"MG","31"})
	aAdd(aUF,{"ES","32"})
	aAdd(aUF,{"RJ","33"})
	aAdd(aUF,{"SP","35"})
	aAdd(aUF,{"PR","41"})
	aAdd(aUF,{"SC","42"})
	aAdd(aUF,{"RS","43"})
	aAdd(aUF,{"MS","50"})
	aAdd(aUF,{"MT","51"})
	aAdd(aUF,{"GO","52"})
	aAdd(aUF,{"DF","53"})
	aAdd(aUF,{"SE","28"})
	aAdd(aUF,{"BA","29"})
	aAdd(aUF,{"EX","99"})

	cRetCodUF := aUF[aScan(aUF,{|x| x[1] == AllTrim(cUF)})][02]

return cRetCodUF

/**
* Converte um tipo de dado
**/
static function ConvType(xValor,nTam,nDec)

	local cNovo  := ""

	default nDec := 0

	do case
		case ValType(xValor) == "N"
		if xValor != 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))
		else
			cNovo := "0"
		endif
		case ValType(xValor) == "D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4) + "-" + SubStr(cNovo,5,2) + "-" + SubStr(cNovo,7)
		case ValType(xValor)=="C"
		default nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(AllTrim(xValor),1,nTam))))
	endcase

return cNovo

/**
* Retira a acentuação das strings para envio do xml
**/
Static Function noAccent(cString)

	local cChar  := ""
	local nX     := 0
	local nY     := 0
	local cVogal := "aeiouAEIOU"
	local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	local cTrema := "äëïöü"+"ÄËÏÖÜ"
	local cCrase := "àèìòù"+"ÀÈÌÒÙ"
	local cTio   := "ãõÃÕ"
	local cCecid := "çÇ"
	local cMaior := "&lt;"
	local cMenor := "&gt;"

	for nX:= 1 to Len(cString)

		cChar := SubStr(cString,nX,1)

		if cChar $ cAgudo + cCircu + cTrema + cCecid + cTio + cCrase

			nY := At(cChar,cAgudo)

			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif

			nY:= At(cChar,cCircu)

			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif

			nY:= At(cChar,cTrema)

			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif

			nY:= At(cChar,cCrase)

			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif

			nY:= At(cChar,cTio)

			if nY > 0
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			endif

			nY:= At(cChar,cCecid)

			if nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			endif
		endif
	next

	if cMaior$ cString
		cString := strTran(cString,cMaior,"")
	endif

	if cMenor$ cString
		cString := strTran(cString,cMenor,"")
	endif

	cString := StrTran(cString,CRLF," ")

	for nX:=1 to Len(cString)

		cChar := SubStr(cString,nX,1)

		if (Asc(cChar) < 32 .OR. Asc(cChar) > 123) .AND. !(cChar $ '|')
			cString := StrTran(cString,cChar,".")
		endif
	next nX

return cString

/**
* Cria o Grupo de perguntas
**/
Static Function ValidQuestions(cGroupQuestions)

	local aRegs := {}   // Registros do Grupo de Pergunta
	local a     := .F.  // Variavel de controle
	local i     := 0
	local j     := 0

	SX1->(dbSetOrder(1))

	aAdd(aRegs,{cGroupQuestions,"01","Nota de    ","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SF2"})
	aAdd(aRegs,{cGroupQuestions,"02","Serie de   ","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cGroupQuestions,"03","Nota Ate   ","","","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SF2"})
	aAdd(aRegs,{cGroupQuestions,"04","Serie Ate  ","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cGroupQuestions,"05","Cliente de ","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cGroupQuestions,"06","Loja de    ","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cGroupQuestions,"07","Cliente ate","","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cGroupQuestions,"08","Loja ate   ","","","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})

	for i:=1 to Len(aRegs)
		a := SX1->(dbSeek(cGroupQuestions+aRegs[i,2]))
		RecLock("SX1",!a)
		for j:=1 to FCount()
			if j <= Len(aRegs[i]) .AND. !(a .AND. j>=15)
				FieldPut(j,aRegs[i][j])
			endif
		next
		MsUnlock()
	next i

return

/**
*
**/
static function sumItems()

	local cQuery := ""

	/*
	cQuery := "SELECT D2_ALIQINS,D2_ALIQISS,D2_ALQCOF,D2_ALQCSL,D2_ALQIRRF,D2_ALQPIS,D2_UM,D2_COD,D2_TES," + CRLF
	cQuery += "     SUM(D2_BASECOF) D2_BASECOF," + CRLF
	cQuery += "     SUM(D2_BASECSL) D2_BASECSL," + CRLF
	cQuery += "     SUM(D2_BASEINS) D2_BASEINS," + CRLF
	cQuery += "     SUM(D2_BASEIRR) D2_BASEIRR," + CRLF
	cQuery += "     SUM(D2_BASEISS) D2_BASEISS," + CRLF
	cQuery += "     SUM(D2_BASEPIS) D2_BASEPIS," + CRLF
	cQuery += "     SUM(D2_PRCVEN)  D2_PRCVEN ," + CRLF
	//	cQuery += "     SUM(D2_QUANT)   D2_QUANT  ," + CRLF
	cQuery += "     SUM(D2_TOTAL)   D2_TOTAL  ," + CRLF
	cQuery += "     SUM(D2_VALISS)  D2_VALISS  " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " D2 "

	cQuery += "INNER JOIN "+ SF4->(RetSQLName("SF4")) +" AS F4 ON " + CRLF
	cQuery += "     F4.F4_FILIAL  =  '"+ SF4->(xFILIAL("SF4")) +"' " + CRLF
	cQuery += " AND F4.F4_CODIGO  =  D2.D2_TES " + CRLF
	cQuery += " AND F4.F4_AGREG   <> 'N' " + CRLF // Somente TES que agrega valor
	cQuery += " AND F4.F4_DUPLIC  <> 'N' " + CRLF // Somente TES que gera duplicata
	cQuery += " AND F4.D_E_L_E_T_ =  ' ' " + CRLF

	cQuery += "WHERE "
	cQuery += "     D2_FILIAL  = '" + xFilial("SD2")   + "' AND " + CRLF
	cQuery += "     D2_DOC     = '" + QSF2->F2_DOC     + "' AND " + CRLF
	cQuery += "     D2_SERIE   = '" + QSF2->F2_SERIE   + "' AND " + CRLF
	cQuery += "     D2_CLIENTE = '" + QSF2->F2_CLIENTE + "' AND " + CRLF
	cQuery += "     D2_LOJA    = '" + QSF2->F2_LOJA	  + "' AND " + CRLF
	cQuery += "     D2.D_E_L_E_T_ = ' '                         " + CRLF
	cQuery += "GROUP BY D2_ALIQINS,D2_ALIQISS,D2_ALQCOF,D2_ALQCSL,D2_ALQIRRF,D2_ALQPIS,D2_UM,D2_COD,D2_TES" + CRLF
	*/

	cQuery := "SELECT D2_ALIQINS,D2_ALIQISS,D2_ALQCOF,D2_ALQCSL,D2_ALQIRRF,D2_ALQPIS,D2_CODISS,D2_TES,D2_UM," + CRLF     // vfv Alterado D2_COD PARA D2_CODISS
	cQuery += "     SUM(D2_BASECOF) D2_BASECOF," + CRLF
	cQuery += "     SUM(D2_VALCOF) D2_VALCOF,  " + CRLF
	cQuery += "     SUM(D2_BASECSL) D2_BASECSL," + CRLF
	cQuery += "     SUM(D2_VALCSL) D2_VALCSL,  " + CRLF
	cQuery += "     SUM(D2_BASEPIS) D2_BASEPIS," + CRLF
	cQuery += "     SUM(D2_VALPIS) D2_VALPIS,  " + CRLF
	cQuery += "     SUM(D2_BASEIRR) D2_BASEIRR," + CRLF
	cQuery += "     SUM(D2_VALIRRF) D2_VALIRRF," + CRLF
	cQuery += "     SUM(D2_BASEISS) D2_BASEISS," + CRLF
	cQuery += "     SUM(D2_VALISS)  D2_VALISS, " + CRLF
	cQuery += "     SUM(D2_BASEINS) D2_BASEINS," + CRLF
	cQuery += "     SUM(D2_VALINS) D2_VALINS  ," + CRLF
	//	cQuery += "     SUM(D2_PRCVEN)  D2_PRCVEN ," + CRLF
	cQuery += "     SUM(D2_TOTAL)  D2_PRCVEN ," + CRLF // VFV INCLUSAO PARA TRATAR AS QUANTIDADES
	cQuery += "     SUM(D2_TOTAL)   D2_TOTAL  " + CRLF

	cQuery += "FROM " + RetSqlName("SD2") + " D2 "

	cQuery += "INNER JOIN "+ SF4->(RetSQLName("SF4")) +" AS F4 ON " + CRLF
	cQuery += "     F4.F4_FILIAL  =  '"+ SF4->(xFILIAL("SF4")) +"' " + CRLF
	cQuery += " AND F4.F4_CODIGO  =  D2.D2_TES " + CRLF
	cQuery += " AND F4.F4_AGREG   <> 'N' " + CRLF // Somente TES que agrega valor
	cQuery += " AND F4.F4_DUPLIC  <> 'N' " + CRLF // Somente TES que gera duplicata
	cQuery += " AND F4.D_E_L_E_T_ =  ' ' " + CRLF

	cQuery += "WHERE "
	cQuery += "     D2_FILIAL  = '" + xFilial("SD2")   + "' AND " + CRLF
	cQuery += "     D2_DOC     = '" + QSF2->F2_DOC     + "' AND " + CRLF
	cQuery += "     D2_SERIE   = '" + QSF2->F2_SERIE   + "' AND " + CRLF
	cQuery += "     D2_CLIENTE = '" + QSF2->F2_CLIENTE + "' AND " + CRLF
	cQuery += "     D2_LOJA    = '" + QSF2->F2_LOJA	  + "' AND " + CRLF
	cQuery += "     D2.D_E_L_E_T_ = ' '                         " + CRLF
	cQuery += "GROUP BY D2_ALIQINS,D2_ALIQISS,D2_ALQCOF,D2_ALQCSL,D2_ALQIRRF,D2_ALQPIS,D2_CODISS,D2_TES,D2_UM" + CRLF // vfv Alterado D2_COD PARA D2_CODISS

	TCQUERY cQuery NEW ALIAS "QSD2"

	return
	******************************************************************************************************
	******************************************************************************************************
static function MensNota(cCliente, cLoja, cSerie, cDoc)

	local cQuery := ""
	Local cMens	 := ""
	Local lPriVez:= .t.

	cQuery := "SELECT C5_MENNOTA" + CRLF
	cQuery += "FROM " + retSqlName("SC5") + "  "
	cQuery += "WHERE "
	cQuery += "    C5_FILIAL  = '" + xFilial("SC5")   + "' AND " + CRLF
	cQuery += "    C5_CLIENTE = '" + cCliente     + "' AND " + CRLF
	cQuery += "    C5_LOJACLI = '" + cLoja   + "' AND " + CRLF
	cQuery += "    C5_NOTA    = '" + cDoc + "' AND " + CRLF
	cQuery += "    C5_SERIE   = '" + cSerie  + "' AND " + CRLF
	cQuery += "    D_E_L_E_T_ = ' '                         " + CRLF

	TCQUERY cQuery NEW ALIAS "QSC5"

	While !QSC5->(Eof())

		If !Empty(QSC5->C5_MENNOTA) .and. !AllTrim(QSC5->C5_MENNOTA) $ cMens
			if lPriVez
				cMens+= AllTrim(QSC5->C5_MENNOTA) + " "
				lPriVez:= .f.
			else
				cMens+= " / "+AllTrim(QSC5->C5_MENNOTA) + " "
			endif
		endif

		QSC5->(dbSkip())
	enddo

	QSC5->(dbCloseArea())

return(cMens)

/*/{Protheus.doc} loadQuery

Seleciona as NFSe a serem consultadas

@author Diogo Mesquita
@since 05/04/2016

@return ResultSet Cabeçalho das NF de Saída
/*/
method loadQuery() class NFSeInfisc

	local cQuery          := ""
	local cGroupQuestions := Padr("NFSEQUERY",Len(SX1->X1_GRUPO))

	SX1->(dbSetOrder(1))
	if !(SX1->(dbSeek(cGroupQuestions)))
		validQuestions(@cGroupQuestions)
	endif

	if !(Pergunte(cGroupQuestions,.T.))
		lCancelado:= .t.
		return
	else
		lCancelado:= .f.
	endif

	cQuery += "SELECT F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_FIMP,F2_CHVNFE," + CRLF
	cQuery += "       F2.R_E_C_N_O_ AS F2_RECNO                                        " + CRLF
	cQuery += "FROM " + retSqlName("SF2") + " F2                                       " + CRLF
	cQuery += "WHERE F2_FILIAL  = '" + xFilial("SF2") + "' AND                         " + CRLF
	cQuery += "      F2_DOC     BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' AND  " + CRLF
	cQuery += "      F2_SERIE   BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' AND  " + CRLF
	cQuery += "      F2_CLIENTE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' AND  " + CRLF
	cQuery += "      F2_LOJA    BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' AND  " + CRLF
	cQuery += "      F2.D_E_L_E_T_ = ' '                                               " + CRLF

	TCQUERY cQuery NEW ALIAS "QSF2"

return
