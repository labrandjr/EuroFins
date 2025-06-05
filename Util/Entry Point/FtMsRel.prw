#include 'totvs.ch'

/*/{Protheus.doc} FtMsRel
Definição de Chave Primaria de usuário. Este ponto de entrada é utilizado para incluir tabelas de usuário,
quando se utiliza o conceito de contato único do Administrador de Vendas / Call Center ou o Banco de Conhecimento.
Para que se possa utilizar o Banco de Conhecimento utilizando uma tabela de usuário (Ex. SZ1),
torna-se necessário informar ao sistema qual a chave primária de relacionamento.
Por exemplo, a chave primária de relacionamento do cadastro de clientes é: FILIAL + CODIGO + LOJA.
@type function
@version 12.1.33
@author adm_tla8
@since 27/12/2022
@return array, retorna amarração entre as tabelas
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
//Array com os campos que identificam os campos utilizados na descrição
	aFields := {'ZZ_IDREQ','ZZ_NOME'}
// funcoes do sistema para identificar o registro
	AAdd( aRet, { cTabela, aChave, bMostra,aFields } )





Return aRet
