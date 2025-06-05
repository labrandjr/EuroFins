#include "rwmake.ch"


/*/{Protheus.doc} ManutClas
Rotina que permitira ao usuario dar manutencao na classificacao dada a nota de saida.
@author Marcos Candido
@since 02/01/2018
/*/
User Function ManutClas

Private cCadastro := "Manuten��o a Classifica��o das Notas Fiscais de Sa�da"

Private aRotina := {{ "Pesquisa" ,"AxPesqui"	, 0 , 1},;
			      	{ "Visualiza","AxVisual"	, 0 , 2},;
		      		{ "Altera"   ,"U_AltClass"	, 0 , 4}}

/*
dbSelectArea("SF2")
dbSetOrder(1)
mBrowse(7,4,20,74,"SF2")

dbSelectArea("SF2")
RetIndex("SF2")
*/

dbSelectArea("SD2")
dbSetOrder(1)
mBrowse(7,4,20,74,"SD2")

dbSelectArea("SD2")
RetIndex("SD2")

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AltClass �Autor  � Marcos Candido     � Data �  28/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para alterar o campo Classificacao                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AltClass(cAlias,nReg,nOpc)

Local aCmpVis := {"D2_DOC","D2_SERIE","D2_CLIENTE","D2_LOJA","D2_EMISSAO","D2_VALBRUT","D2_ZZCC"}
Local aCmpAlt := {"D2_ZZCC"}
Local aAreaAtual := GetArea()

AxAltera(cAlias,nReg,nOpc,aCmpVis,aCmpAlt)

dbSelectArea("SFT")
dbSetOrder(1)
If dbSeek(xFilial("SFT")+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+PADR(D2_ITEM,4)+D2_COD))
	RecLock("SFT",.F.)
	  FT_CONTA := SD2->D2_CONTA
	  FT_ZZCC  := SD2->D2_ZZCC
	MsUnlock()
Endif

RestArea(aAreaAtual)

Return