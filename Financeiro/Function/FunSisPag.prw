#include "rwmake.ch"


/*/{Protheus.doc} ContaFav
Retorna a agencia e a conta do favorecido para o arquivo de pagamentos (SISPAG)
@author Marcos Candido
@since 04/01/2018
/*/
User Function ContaFav

Local cRet := ""

/*
���������������������������������������������������������������Ŀ
�  Campos customizados                                          �
�                                                               �
�SA2 -> Fornecedor                                              �
�	A2_X_POUP , C , 10  --> Numero da conta poupanca            �
�	A2_X_DIGP , C , 2   --> Digito da conta poupanca            �
�	A2_X_DIGCT, C , 2   --> Digito da conta corrente            �
�                                                               �
�SE2 -> Titulos a Pagar                                         �
�	E2_X_POUP , C , 1  --> Indica se o pagamento sera feito na  �
�	                       conta poupanca do fornecedor         �
�                          (em caso de DOC, TEC)                �
�����������������������������������������������������������������
*/

If SA2->A2_BANCO $ "341/409"
	cRet := "0"+STRZERO(VAL(SA2->A2_AGENCIA),4)+" "+"000000"+IIF(SE2->E2_ZZPOUP=="S",STRZERO(VAL(SA2->A2_ZZPOUP),6),STRZERO(VAL(SA2->A2_NUMCON),6))+" "+IIF(SE2->E2_ZZPOUP=="S",Alltrim(SA2->A2_ZZDIGP),RIGHT(ALLTRIM(SA2->A2_NUMCON),1))
Else
	cRet := STRZERO(VAL(SA2->A2_AGENCIA),5)+" "+IIF(SE2->E2_ZZPOUP=="S",STRZERO(VAL(SA2->A2_ZZPOUP),12),STRZERO(VAL(SA2->A2_NUMCON),12))+" "+IIF(SE2->E2_ZZPOUP=="S",Alltrim(SA2->A2_DIGPOUP),RIGHT(ALLTRIM(SA2->A2_NUMCON),1))
Endif

Return cRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � DIGVER   � Autor � Marcos Candido        � Data � 20/10/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o layout para o DV do Codigo de Barras             ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SISPAG                                                     ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DIGIVER()

Local cDigCamp := ""

If Len(Alltrim(SE2->E2_CODBAR)) == 44
	cDigCamp := Substr(SE2->E2_CODBAR,5,1)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
	cDigCamp := Substr(SE2->E2_CODBAR,33,1)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 43
	cDigCamp := Substr(SE2->E2_CODBAR,33,1)
Else
	cDigCamp := "0"
Endif

Return(cDigCamp)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � VENCTOCB � Autor � Marcos Candido        � Data � 20/10/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ExecBlock para retornar vencimento do codigo de barras.    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SISPAG                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VENCTOCB

Local cRetVcto := ""

If Len(Alltrim(SE2->E2_CODBAR)) == 44
	cRetVcto := Substr(SE2->E2_CODBAR,6,4)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
	cRetVcto := Substr(SE2->E2_CODBAR,34,4)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 43
	cRetVcto := "0000"
Else
	cRetVcto := "0000"
EndIf

cRetVcto := Strzero(Val(cRetVcto),4)

Return(cRetVcto)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ValTit   � Autor � Marcos Candido        � Data � 20/10/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o layout para o Valor no Codigo de Barras          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SISPAG                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ValTiT()

Local cVlrCampo := ""

If Len(Alltrim(SE2->E2_CODBAR)) == 44
	cVlrCampo := Substr(SE2->E2_CODBAR,10,10)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
	cVlrCampo := Substr(SE2->E2_CODBAR,38,10)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 43
	cVlrCampo := Alltrim(Substr(SE2->E2_CODBAR,34,10))
Else
	cVlrCampo := "0"
EndIf

cVlrCampo := Strzero(Val(cVlrCampo),10)

Return(cVlrCampo)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CAMPOLIV � Autor � Marcos Candido        � Data � 20/10/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o layout para o Campo Livre de Dados do Codigo de  ���
���          � Barras.                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SISPAG                                                     ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CampoLiv

Local cCampFree := ""

If Len(Alltrim(SE2->E2_CODBAR)) == 44
	cCampFree := Substr(SE2->E2_CODBAR,20,25)
ElseIF Len(Alltrim(SE2->E2_CODBAR)) == 47
	cCampFree := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+Substr(SE2->E2_CODBAR,22,10)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 40
	cCampFree := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+Substr(SE2->E2_CODBAR,22,10)
Else
	cCampFree := Replicate("0",25)
EndIf

Return (cCampFree)
