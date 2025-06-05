#include "rwmake.ch"
#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} MT110LOK
Valida linha da solicitação de compras.
@Author Marcos Candido
@since 29/12/2017
@Obs Sera avaliado se o usuario tem permissão para indicar o
armazem indicado no item, verificando o cadastro customizado (SZC).
Consistir Centro de Custo e Armazem sempre; pois a digitacao é obrigatoria.
/*/
User Function MT110LOK

Local lCont       := .F.
Local lCont2      := .F.
Local lRet        := .T.
Local aAreaAtual  := GetArea()
Local cUserLogado := RetCodUsr()
Local nPLocal     := aScan(aHeader,{|x| Trim(x[2])=="C1_LOCAL"})
Local nPCCusto    := aScan(aHeader,{|x| Trim(x[2])=="C1_CC"})
Local nPTipo      := aScan(aHeader,{|x| Trim(x[2])=="C1_ZZTIPO"})
Local cMens0      := ""
Local cMens1      := "Usuário sem permissão para usar este armazém."
Local cMens2      := "Se o Tipo do produto for MP, não preencha o Centro de Custo."
Local cMens3      := "Indique o Centro de Custo de sua área."
Local cMens4      := "Indique o Centro de Custo."
Local cMens5      := "Se o Tipo do produto for diferente de MP, ajuste o Armazém para '10'."
Local cMens6      := "Se o Tipo do produto for igual a MP, não utilize o Armazém '10'."
Local cMens7      := "Indique o Armazém."

Return .T. //PE DESABILITADO, A TABELA SZC NAO É MAIS USADA

If AliasInDic("SZC")

	cTipo := aCols[n][nPTipo]

/*	dbSelectArea("SZC")
	dbSetOrder(1)
	dbSeek(xFilial("SZC")+cUserLogado)

	While !Eof() .and. ZC_FILIAL == xFilial("SZC") .and. ZC_SOLICIT == cUserLogado
		If (ZC_LOCAL == '**' .or. ZC_LOCAL == aCols[n][nPLocal])  // deve consistir o armazem que o usuario esta vinculado
			lCont := .T.
		Endif
		dbSkip()
	Enddo
*/

	If !lCont

		//cMens0 := cMens1

	ElseIf Empty(aCols[n][nPCCusto])

		cMens0 := cMens4

	ElseIf Empty(aCols[n][nPLocal])

		cMens0 := cMens7

	Else

		If cTipo <> 'MP'  // se nao for MP o centro de custo eh obrigatorio e o armazem eh 10

			If aCols[n][nPLocal] <> '10' .and. SM0->M0_CODIGO == '01'
				cMens0 := cMens5
			ElseIf dbSeek(xFilial("SZC")+cUserLogado)
				While !Eof() .and. ZC_FILIAL == xFilial("SZC") .and. ZC_SOLICIT == cUserLogado
					If (Alltrim(ZC_CCUSTO) == '**' .or. ZC_CCUSTO == aCols[n][nPCCusto])  // deve consistir o C.Custo que o usuario esta vinculado
						lCont2 := .T.
					Endif
					dbSkip()
				Enddo
				If !lCont2
					cMens0 := cMens3
				Endif


			Endif

		Else  // ser for MP nao tem que ter centro de custo , e tambem nao pode usar o armazem 10

			//If !Empty(aCols[n][nPCCusto])
			//	cMens0 := cMens2
			//Else
			If aCols[n][nPLocal] == '10' .and. SM0->M0_CODIGO == '01'
				cMens0 := cMens6
			Else
				lCont2 := .T.
			Endif

		Endif

	Endif

	If (!lCont .or. !lCont2)
		If Empty(cMens0)
			cMens0 := cMens1
		Endif
		Aviso(OemToAnsi("Atenção") , OemToAnsi(cMens0+ENTER+ENTER+"Verifique.") , {"Sair"},2)
		lRet := .F.
	Endif
Endif

RestArea(aAreaAtual)

Return lRet