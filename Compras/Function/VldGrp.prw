#include 'rwmake.ch'

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} VldGrp
Gatilho disparado pelo campo C7_PRODUTO, em que verifico
se o comprador tem permissao para usar o produto digitado
atraves do(s) grupo(s) do produto indicado(s) no cadastro
do comprador.
@author Marcos Candido
@since 06/03/15

/*/
User Function VldGrp(cProduto)

	Local cUserLogado := RetCodUsr()
	Local aAreaAtual  := GetArea()
	Local cGrupo      := ""
	Local lRet        := .F.

	If FWISINCALLTACK("U_ImpPOCOUPA")
		lRet	:= .T.
	Else
		dbSelectArea("SY1")
		dbSetOrder(3)
		If dbSeek(xFilial("SY1")+cUserLogado)
			If Alltrim(SY1->Y1_ZZGRP) <> "*"
				cGrupo := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_GRUPO")
				If cGrupo $ Alltrim(SY1->Y1_ZZGRP)
					lRet := .T.
				Endif
			Else
				lRet := .T.
			Endif
		Endif

		If !lRet
			Aviso(OemToAnsi("Aten็ใo") , OemToAnsi("Usuแrio nใo tem permissใo para fazer pedido de compra para esse tipo de produto."+ENTER+ENTER+"Verifique.") , {"Sair"} ,2)
			cProduto := Space(Len(cProduto)	)
		Endif
	Endif

RestArea(aAreaAtual)

Return cProduto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ GetGrupo บ Autor ณ Marcos Candido     บ Data ณ 09/03/15    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar para permitir ao usuario escolher os Gruposบฑฑ
ฑฑบ          ณ de produtos que o comprador usar no pedido de compra.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function GetGrupos

Local cTituloJan := "Grupos de Produtos"
Local MvPar      := ""
Local MvParDef   := ""
Local aAreaAtual := GetArea()
Local nTamMax    := TamSX3("BM_GRUPO")[1]
Local cAux       := ""

Private aSit:={} , l1Elem := .F.

MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

CursorWait()

dbSelectArea("SBM")
dbGoTop()
While !Eof()
	Aadd(aSit,BM_GRUPO + " - " + Alltrim(BM_DESC))
	MvParDef+=BM_GRUPO
	dbSkip()
Enddo

CursorArrow()

IF f_Opcoes(@MvPar,cTituloJan,aSit,MvParDef,,,l1Elem,nTamMax,14,,,,.T.,.T.)	// Chama funcao f_Opcoes
	For nR:=1 To Len(mvpar) Step nTamMax
		If Substr(mvPar,nR,nTamMax) <> Replicate("*",nTamMax)
			cAux += Substr(mvPar,nR,nTamMax)+";"
		Endif
	Next
	&MvRet := cAux                         										// Devolve Resultado
EndIF

RestArea(aAreaAtual)

Return(.T.)

/*
Function f_Opcoes(	uVarRet			,;	//Variavel de Retorno
					cTitulo			,;	//Titulo da Coluna com as opcoes
					aOpcoes			,;	//Opcoes de Escolha (Array de Opcoes)
					cOpcoes			,;	//String de Opcoes para Retorno
					nLin1			,;	//Nao Utilizado
					nCol1			,;	//Nao Utilizado
					l1Elem			,;	//Se a Selecao sera de apenas 1 Elemento por vez  ==> .T.=MultiSelecao   .F.=Apenas um
					nTam			,;	//Tamanho da Chave
					nElemRet		,;	//No maximo de elementos na variavel de retorno
					lMultSelect		,;	//Inclui Botoes para Selecao de Multiplos Itens
					lComboBox		,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
					cCampo			,;	//Qual o Campo para a Montagem do aOpcoes
					lNotOrdena		,;	//Nao Permite a Ordenacao
					lNotPesq		,;	//Nao Permite a Pesquisa
					lForceRetArr    ,;	//Forca o Retorno Como Array
					cF3				 ;	//Consulta F3
				  )
*/