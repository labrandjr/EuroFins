#include "rwmake.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Fa740Brw �Autor  � Marcos Candido     � Data �  23/07/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada na rotina que monta a tela que gerencia   ���
���          � as opcoes para o contas a receber.                         ���
���          � Estou adicionando uma nova opcao para alterar o campo      ���
���          � E1_LA para S ou N e com isso conseguir dar manutencao nos  ���
���          � valor dos impostos.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Eurofins                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


/*/{Protheus.doc} Fa740Brw
Na rotina que monta a tela que gerencia as opcoes para o contas a receber.
@author Marcos Candido
@since 03/01/2018
/*/
User Function Fa740Brw

Local aDados := PARAMIXB
Local aMaisOpc := {}

aadd(aMaisOpc,{"Limpa Ctb" , "U_LimpaCTB" , 0 , 4})

Return aMaisOpc

User Function LimpaCTB(cAlias,nReg,nOpc)

Local aCmpVis := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_EMISSAO","E1_VENCTO","E1_VALOR","E1_HIST","E1_NOMCLI"}
Local aCmpAlt := {"E1_LA"}
Local aAreaAtual := GetArea()
Local cPropri   := "" , cValid := ""

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("E1_LA")
cPropri := SX3->X3_PROPRI
cValid  := SX3->X3_VALID

RecLock("SX3",.F.)
  X3_VALID  := "Pertence('SN')"
  X3_PROPRI := "U"
MsUnlock()

RestArea(aAreaAtual)

AxAltera(cAlias,nReg,nOpc,aCmpVis,aCmpAlt)

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("E1_LA")
RecLock("SX3",.F.)
  X3_VALID  := cValid
  X3_PROPRI := cPropri
MsUnlock()

RestArea(aAreaAtual)

Return
