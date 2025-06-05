#include 'protheus.ch'

/*/{Protheus.doc} TitRecClass
(long_description)
@author Geeker
@since 06/06/2017
@version 1.0
/*/
class TitRecClass
	data cCodNfe
	data cChaNfe

 	data cClientTit
	data cLojaTit
	data cNomeCli
	data cRazaoCli
	data cMailCli
	data cMailCob
	data cMailEsp
	data cEnderec
	data cCNPJ
	
	data cEmptTit
	data cFilTitulo
	data cPrefixo
	data cNumTit
	data cParcela
	data cTipo
	data cNatureza
	data cPortador
	data dEmissao
	data dVencto
	data dVencReal
	data nValor
	data nSaldo
	data dDtBord
	data cNumBord
	data nDesconto
	data nMulta
	data nJuros
	data nMoeda
	data cHistoric
	data cBanco
	data cAgen
	data cConta	
	data cSituac
	data nRecnoTit
	data lTemBol
	data lTemNF
	data lAnxCus
	data cAnxCus
	
	method new_TitRecClass() constructor 
	method setByAlias_TitRecClass()
	method setCliByAlias_TitRecClass()
	method setTdByAlias_TitRecClass()
	method setNfByAliascAlias_TitRecClass()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author Geeker
@since 06/06/2017 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new_TitRecClass() class TitRecClass
	::cCodNfe 		:= ""
	::cChaNfe		:= ""

	::cFilTitulo	:= ""
	::cPrefixo		:= ""
	::cNumTit		:= ""
	::cParcela		:= ""
	::cTipo			:= ""
	::cNatureza		:= ""
	::cPortador		:= ""
	::cClientTit	:= ""
	::cLojaTit		:= ""
	::cNomeCli		:= ""
	::cRazaoCli		:= ""
	::dEmissao		:= Stod("")	
	::dVencto		:= Stod("")
	::dVencReal		:= Stod("")
	::nValor		:= 0
	::nSaldo		:= 0
	::dDtBord		:= Stod("")
	::cNumBord		:= ""
	::nDesconto		:= 0
	::nMulta		:= 0
	::nJuros		:= 0
	::nMoeda		:= 0
	::cHistoric		:= ""
	::cBanco		:= ""
	::cAgen			:= ""
	::cConta		:= ""
	::cMailCob 		:= ""
	::cMailEsp		:= ""
	::cSituac		:= ""
	::nRecnoTit		:= 0
	::lTemBol		:= .F.
	::lTemNF		:= .F.
	::lAnxCus		:= .F.
	::cAnxCus		:= ""
return

/*/{Protheus.doc} setByAlias_TitRecClass
Seta o objeto pelo alias recebido

@author Geeker
@since 06/06/2017 
@version 1.0
/*/ 
method setByAlias_TitRecClass(cAliasQry) class TitRecClass
	::cEmptTit		:= cEmpAnt
	::cFilTitulo 	:= (cAliasQry)->E1_FILIAL
	::cPrefixo 		:= (cAliasQry)->E1_PREFIXO
	::cNumTit 		:= (cAliasQry)->E1_NUM
	::cParcela 		:= (cAliasQry)->E1_PARCELA
	::cTipo 		:= (cAliasQry)->E1_TIPO
	::cNatureza 	:= (cAliasQry)->E1_NATUREZ
	::cPortador 	:= (cAliasQry)->E1_PORTADO
	::cClientTit	:= (cAliasQry)->E1_CLIENTE
	::cLojaTit 		:= (cAliasQry)->E1_LOJA
	::cNomeCli		:= (cAliasQry)->E1_NOMCLI
	::dEmissao 		:= (cAliasQry)->E1_EMISSAO
	::dVencto 		:= (cAliasQry)->E1_VENCTO
	::dVencReal 	:= (cAliasQry)->E1_VENCREA
	::nValor 		:= (cAliasQry)->E1_VALOR
	::nSaldo 		:= (cAliasQry)->E1_SALDO
	::dDtBord		:= (cAliasQry)->E1_DATABOR
	::cNumBord		:= (cAliasQry)->E1_NUMBOR	
	::nDesconto 	:= (cAliasQry)->E1_DESCONT
	::nMulta 		:= (cAliasQry)->E1_MULTA
	::nJuros 		:= (cAliasQry)->E1_JUROS
	::nMoeda 		:= (cAliasQry)->E1_MOEDA
	::cHistoric		:= (cAliasQry)->E1_HIST
	::cBanco 		:= (cAliasQry)->E1_PORTADO
	::cAgen 		:= (cAliasQry)->E1_AGEDEP
	::cConta 		:= (cAliasQry)->E1_CONTA
	::cSituac		:= (cAliasQry)->E1_SITUACA
	::nRecnoTit		:= (cAliasQry)->R_E_C_N_O_
return

/*/{Protheus.doc} setCliByAlias_TitRecClass
Set o cliente pelo alias

@author Geeker
@since 06/06/2017 
@version 1.0
/*/ 
method setCliByAlias_TitRecClass(cAliasQry) class TitRecClass	
	::cMailEsp	:= Alltrim((cAliasQry)->A1_EMAIL)	//Alltrim((cAliasQry)->A1_ZZNFMAI)
	::cMailCob	:= Alltrim((cAliasQry)->A1_XMAICOB)
	::cMailCli	:= Alltrim((cAliasQry)->A1_XMAICOB)
	::cEnderec	:= (cAliasQry)->A1_END
	::cCNPJ		:= (cAliasQry)->A1_CGC
	::cRazaoCli	:= (cAliasQry)->A1_NOME
return


/*/{Protheus.doc} setNfByAliascAlias_TitRecClass
Metodo para setar as informacoes da nota fiscal

@author Geeker
@since 06/06/2017 
@version 1.0
/*/ 
method setNfByAliascAlias_TitRecClass(cAliasQry) class TitRecClass
	::cCodNfe	:= (cAliasQry)->F2_CODNFE
	::cChaNfe	:= (cAliasQry)->F2_CHVNFE
return

/*/{Protheus.doc} setCliByAlias_TitRecClass
Set o cliente pelo alias

@author Geeker
@since 06/06/2017 
@version 1.0
/*/ 
method setTdByAlias_TitRecClass(cAliasQry) class TitRecClass
	::setByAlias_TitRecClass(cAliasQry)
	::setCliByAlias_TitRecClass(cAliasQry)
	::setNfByAliascAlias_TitRecClass(cAliasQry)
return