#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RETCODFOR �Autor  �Thais Fumagalli     � Data �  15/09/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Criado programa para facilitar a codifica��o e numera��o   ���
���          � sequencia de TES         .                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Gatilho no campo F4_ZZTM                                   ���
�������������������������������������������������������������������������ͼ��
*/

/*/{Protheus.doc} RetCodTes
Programa para facilitar a codifica��o e numera��o sequencia de TES.
@author Thais Fumagalli
@since 04/01/2018
/*/
User Function RetCodTes

	// Vari�veis da fun��o.
	Local _nCod := 0
	Local _xArea:= GetArea()

	cQuery := " SELECT MAX(F4_CODIGO) AS MAIOR FROM " + RetSqlName("SF4")
	cQuery += " WHERE SUBSTRING(F4_CODIGO,1,2) = '"+Substr(M->F4_ZZTM,1,2)+"' AND"
	cQuery += " D_E_L_E_T_=' '"

	TcQuery cQuery New Alias "TSF4"

	TSF4->(dbGoTop())

	If TSF4->(!Eof()) .and. !Empty(TSF4->MAIOR)
		_nCod := Soma1(TSF4->MAIOR)
	Else
		_nCod := Substr(M->F4_ZZTM,1,2)+"0"
	Endif

	TSF4->(dbCloseArea())

	M->F4_CODIGO := _nCod

	// Restaura �rea
	RestArea(_xArea)

// Fim do programa.
Return(_nCod)
