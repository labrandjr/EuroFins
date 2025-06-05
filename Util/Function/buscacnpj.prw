#include 'totvs.ch'
#include 'json.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'


Class buscaCNPJ
	data lResult      as logical
	data cCNPJ        as string
	data oResult      as object

	data cComplemento as string
	data cNome        as string
	data cFantasia    as string
	data cUF          as string
	data cTelefone    as string
	data cEmail       as string
	data cBairro      as string
	data cLogradouro  as string
	data cCEP         as string
	data cMunicipio   as string
	data cCodMun      as string
	data cNumero      as string
	data dAbertura    as date
	data cTipo        as string
	data cNatJur      as string
	data cCnae        as string
	data cDescCnae    as string
	data nCapSocial   as numeric

	Method New(cCNPJ) Constructor
	Method Consultar(cCNPJ)
	Method Destroy()

EndClass

// -------------------------------------------------------------------------------------------------------------------------------------------------------

Method New(c_CNPJ, c_Origem) Class buscaCNPJ
	::cCNPJ   := c_CNPJ
Return Self

// -------------------------------------------------------------------------------------------------------------------------------------------------------


Method Destroy() Class buscaCNPJ

	::lResult      := nil
	::cComplemento := nil
	::cNome        := nil
	::cFantasia    := nil
	::cUF          := nil
	::cTelefone    := nil
	::cEmail       := nil
	::cBairro      := nil
	::cLogradouro  := nil
	::cNumero      := nil
	::cCEP         := nil
	::cMunicipio   := nil
	::cCodMun      := nil

	::dAbertura    := nil
	::cTipo        := nil
	::cNatJur      := nil
	::cCnae        := nil
	::cDescCnae    := nil
	::nCapSocial   := nil



Return Self
// -------------------------------------------------------------------------------------------------------------------------------------------------------


Method Consultar(c_CNPJ) Class buscaCNPJ
	local cURL 		        := ''
	local cStrRet           := ''

	cURL	:= "https://www.receitaws.com.br/v1/cnpj/"+ strTran(StrTran( c_CNPJ, "-", ""),".","")
	MsgRun( "Aguarde..." , "Consultando CNPJ" , { || cStrRet := DecodeUTF8(HTTPGET( cURL ), "cp1252") } )

	If Empty(cStrRet)
		::lResult := .F.
		Return(Self)
	EndIf

	::lResult := FWJsonDeserialize(cStrRet,@::oResult)

	If Upper(self:oResult:Status) == "OK"
		::cComplemento := self:oResult:Complemento
		::cNome        := self:oResult:Nome
		::cFantasia    := Upper(self:oResult:Fantasia)
		::cUF          := self:oResult:Uf
		::cTelefone    := self:oResult:Telefone
		::cEmail       := self:oResult:email
		::cBairro      := self:oResult:Bairro
		::cLogradouro  := self:oResult:Logradouro
		::cNumero      := self:oResult:numero
		::cCEP         := strTran(strTran(self:oResult:cep,".",""),"-","")
		::cMunicipio   := self:oResult:Municipio
		::cCodMun      := retCodMun(self:oResult:Uf, self:oResult:Municipio)

		::dAbertura    := cTod(self:oResult:abertura)
		::cTipo        := self:oResult:tipo
		::cNatJur      := self:oResult:natureza_juridica
		::cCnae        := self:oResult:Atividade_Principal[1]:Code
		::cDescCnae    := FWCutOff(upper(self:oResult:Atividade_Principal[1]:Text),.T.)
		::nCapSocial   := val(self:oResult:capital_social)

	EndIf

Return Self

// ------------------------------------------------------------------------------------------------------------------------------------------------
static function retCodMun(cEstado, cMunicipio)
	local cCodMun as character
	local aArea   as array
	default cEstado    := ""
	default cMunicipio := ""

	cCodMun     := ''
	aArea       := getArea()
	cEstado     := Upper(cEstado)
	cMunicipio  := Alltrim(Upper(ftAcento(cMunicipio)))


	dbSelectArea("CC2")
	dbSetOrder(2)  //CC2_FILIAL+CC2_MUN
	dbSeek(FWxFilial("CC2") + cMunicipio)
	While !( CC2->(Eof()) ) .and. (CC2->CC2_FILIAL == FWxFilial("CC2")) .and. (alltrim(CC2->CC2_MUN) == cMunicipio)
		If  (CC2->CC2_EST == cEstado)
			cCodMun := CC2->CC2_CODMUN
			Exit
		EndIf

		CC2->(dbSkip())
	End

	dbSetOrder(1)
	restArea(aArea)

return(cCodMun)
