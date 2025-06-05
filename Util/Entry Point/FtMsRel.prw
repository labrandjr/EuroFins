#include 'totvs.ch'

/*/{Protheus.doc} FtMsRel
Defini��o de Chave Primaria de usu�rio. Este ponto de entrada � utilizado para incluir tabelas de usu�rio,
quando se utiliza o conceito de contato �nico do Administrador de Vendas / Call Center ou o Banco de Conhecimento.
Para que se possa utilizar o Banco de Conhecimento utilizando uma tabela de usu�rio (Ex. SZ1),
torna-se necess�rio informar ao sistema qual a chave prim�ria de relacionamento.
Por exemplo, a chave prim�ria de relacionamento do cadastro de clientes �: FILIAL + CODIGO + LOJA.
@type function
@version 12.1.33
@author adm_tla8
@since 27/12/2022
@return array, retorna amarra��o entre as tabelas
/*/
User Function FtMsRel()

	Local aRet    As Array
	Local aChave  As Array
	Local bMostra As Block
	Local cTabela As Character
	Local aFields As Array


	aRet := {}
// Tabela do usuario
	cTabela := 'SZZ'
// Campos que compoe a chave na ordem. Nao  passar filial (automatico)
	aChave  := { 'ZZ_IDREQ'}
// Bloco de codigo a ser exibido
	bMostra := { ||SZZ->ZZ_IDREQ}
//Array com os campos que identificam os campos utilizados na descri��o
	aFields := {'ZZ_IDREQ','ZZ_NOME'}
// funcoes do sistema para identificar o registro
	AAdd( aRet, { cTabela, aChave, bMostra,aFields } )





Return aRet
