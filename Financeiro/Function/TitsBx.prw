#Include "PROTHEUS.Ch"

Static lFWCodFil := FindFunction("FWCodFil")
STATIC lUnidNeg	:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR190  � Autor � Adrianne Furtado      � Data � 02.09.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o das baixas                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR190(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/



/*/{Protheus.doc} TitsBx
Relatorio das baixas
@author Adrianne Furtado
@since 04/01/2018
/*/
User Function TitsBx

Local oReport:= Nil
Private cChaveInterFun := ""

/* GESTAO - inicio */
Private aSelFil	:= {}
/* GESTAO - fim */


If FindFunction("TRepInUse") .And. TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	U_R3TitsBx()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Nereu Humberto Junior  � Data �16.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport	:= Nil
Local oSection	:= Nil
Local oCell		:= Nil
Local nPlus		:= 0
Local oBaixas	:= Nil
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("TITSBX","Relacao de Baixas","FIN190", {|oReport| ReportPrint(oReport)},"Este programa ir� emitir a rela��o dos titulos baixados."+" "+"Poder� ser emitido por data, banco, natureza ou alfab�tica"+" "+"de cliente ou fornecedor e data da digita��o.")

Pergunte("FIN190",.F.)

oReport:SetLandScape()

/* GESTAO - inicio */
oReport:SetUseGC(.F.)
oReport:SetGCVPerg( .F. )
/* GESTAO - fim */

oBaixas := TRSection():New(oReport,"Baixas",{"SE5","SED"},{"Por Data","Por Banco","Por Natureza","Alfabetica","Nro. Titulo","Dt.Digitacao","Por Lote","Por Data de Credito"})

oBaixas:SetTotalInLine(.F.)

TRCell():New(oBaixas,"E5_PREFIXO"	,, "Prf",,TamSx3("E5_PREFIXO")[1], .F.)

If "PTG/MEX" $ cPaisLoc
	TRCell():New(oBaixas,"E5_NUMERO" 	,, "Numero",,TamSx3("E5_NUMERO")[1]+18,.F.)
Else
	TRCell():New(oBaixas,"E5_NUMERO" 	,, "Numero",,TamSx3("E5_NUMERO")[1]+2,.F.)
Endif

If cPaisLoc == "BRA"
	nPlus := 5
Else
	nPlus := 3
Endif
TRCell():New(oBaixas,"E5_PARCELA"	,, "Prc",,TamSx3("E5_PARCELA")[1], .F.)
TRCell():New(oBaixas,"E5_TIPODOC"	,, "TP",,TamSx3("E5_TIPODOC")[1], .F.)
TRCell():New(oBaixas,"E5_CLIFOR"	,, "Cli/For",,TamSx3("E5_CLIFOR")[1]+8, .F.)
TRCell():New(oBaixas,"NOME CLI/FOR"	,, "Nome Cli/For",, 20, .F.)
TRCell():New(oBaixas,"E5_NATUREZ"	,, "Natureza",,TamSx3("E5_NATUREZ")[1]-1, .F.)
TRCell():New(oBaixas,"E5_VENCTO"	,, "Vencto",,TamSx3("E5_VENCTO")[1], .F.)
TRCell():New(oBaixas,"E5_HISTOR"	,, "Historico",, TamSx3("E5_HISTOR")[1]+8, .F.)
TRCell():New(oBaixas,"E5_DATA"		,, "Dt Baixa",,TamSx3("E5_DATA")[1], .F.)
TRCell():New(oBaixas,"E5_VALOR"		,, "Valor Original",, TamSX3("E5_VALOR")[1]+3	,/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"IMPOSTOS"		,, "Impostos",, TamSX3("E5_VLJUROS")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"VLRIRRF"		,, "IRRF",, TamSX3("E5_VLCORRE")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"VLRPIS"		,, "PIS",, TamSX3("E5_VLDESCO")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"VLRCOFINS"	,, "COFINS",, TamSX3("E5_VLDESCO")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"VLRCSLL"		,, "CSLL",, TamSX3("E5_VLDESCO")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"E5_VALORPG"	,, "Total Baixado",, TamSX3("E5_VALOR")[1]+3,/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"E5_BANCO"		,, "Bco",, TamSX3("E5_BANCO")[1]+1,.T.)
TRCell():New(oBaixas,"E5_DTDIGIT"	,, "Dt Dig.",,8, .T.)
TRCell():New(oBaixas,"E5_MOTBX"		,, "Mot",,3, .T.)
TRCell():New(oBaixas,"E5_ORIG"		,, "Orig",,2, .T.)
TRCell():New(oBaixas,"VLRISS"		,, "ISS",, TamSX3("E5_VLDESCO")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"VLRINSS"		,, "INSS",, TamSX3("E5_VLDESCO")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")

oBaixas:SetNoFilter({"SED"})

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Nereu Humberto Junior  � Data �16.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)
Local oBaixas	:= oReport:Section(1)
Local nOrdem	:= oReport:Section(1):GetOrder()
Local cAliasSE5	:= "SE5"
Local cTitulo 	:= ""
Local cSuf		:= LTrim(Str(mv_par12))
Local cMoeda	:= GetMv("MV_MOEDA"+cSuf)
Local cCondicao	:= ""
Local cCond1 	:= ""
Local cChave 	:= ""
Local bFirst
Local oBreak1, oBreak2
Local nDecs	   	:= GetMv("MV_CENT"+(IIF(mv_par12 > 1 , STR(mv_par12,1),"")))
Local cAnterior, cAnt
Local aRelat	:={}
Local nI  := 1
Local lVarFil	:= (mv_par17 == 1 .and. SM0->(Reccount()) > 1	) // Cons filiais abaixo
Local nTotBaixado := 0
Local aTotais	:={}
Local cTotText	:=	""
Local nGerOrig	:= 0
Local nRegSM0 := SM0->(Recno())
Local nRegSE5 := SE5->(Recno())
Local nJ		:= 1
Local lNaturez := .F.
Local lMultiNat := .F.

Private cNomeArq

If oReport:lXlsTable
	ApMsgAlert("Formato de impress�o Tabela n�o suportado neste relat�rio")
	oReport:CancelPrint()
	Return
Endif

cFilterUser := ""

/* GESTAO - inicio */
If MV_PAR40 == 1
	If Empty(aSelFil)
	aSelFil := AdmGetFil(.F.,.F.,"SE5")
		If Empty(aSelFil)
		   Aadd(aSelFil,cFilAnt)
		Endif
	Endif
Else
	Aadd(aSelFil,cFilAnt)
Endif

lVarFil := Len(aSelFil) > 1

/* GESTAO - fim */

//��������������������������������Ŀ
//� Defini��o dos cabe�alhos       �
//����������������������������������
If mv_par11 == 1
	cTitulo := "Relacao dos Titulos Recebidos em " + cMoeda
Else
	cTitulo := "Relacao dos Titulos Pagos em " + cMoeda
EndIf

/*���������������������������������Ŀ
//�  VALORES ANTERIORES A ALTERACAO �
//�aRelat[x][01]: Prefixo			�
//�         [02]: Numero 			�
//�         [03]: Parcela			�
//�         [04]: Tipo do Documento	�
//�         [05]: Cod Cliente/Fornec�
//�         [06]: Nome Cli/Fornec	�
//�         [07]: Natureza         	�
//�         [08]: Vencimento       	�
//�         [09]: Historico       	�
//�         [10]: Data de Baixa    	�
//�         [11]: Valor Original   	�
//�         [12]: Jur/Multa        	�
//�         [13]: Correcao         	�
//�         [14]: Descontos        	�
//�         [15]: Abatimento       	�
//�         [16]: Impostos         	�
//�         [17]: Total Pago       	�
//�         [18]: Banco            	�
//�         [19]: Data Digitacao   	�
//�         [20]: Motivo           	�
//�         [21]: Filial de Origem 	�
//�         [22]: Filial            �
//�         [23]: E5_BENEF - cCliFor�
//�         [24]: E5_LOTE          	�
//�         [25]: E5_DTDISPO        �
//�����������������������������������*/

/*���������������������������������Ŀ
//�        VALOR ATUAIS             �
//�aRelat[x][01]: Prefixo			�
//�         [02]: Numero 			�
//�         [03]: Parcela			�
//�         [04]: Tipo do Documento	�
//�         [05]: Cod Cliente/Fornec�
//�         [06]: Nome Cli/Fornec	�
//�         [07]: Natureza         	�
//�         [08]: Vencimento       	�
//�         [09]: Historico       	�
//�         [10]: Data de Baixa    	�
//�         [11]: Valor Original   	�
//�         [12]: Impostos         	�
//�         [13]: IRRF             	�
//�         [14]: PIS              	�
//�         [15]: COFINS           	�
//�         [16]: CSLL             	�
//�         [17]: Total Pago       	�
//�         [18]: Banco            	�
//�         [19]: Data Digitacao   	�
//�         [20]: Motivo           	�
//�         [21]: Filial de Origem 	�
//�         [22]: Filial            �
//�         [23]: E5_BENEF - cCliFor�
//�         [24]: E5_LOTE          	�
//�         [25]: E5_DTDISPO        �
//�         [26]: lOriginal ???     �
//�         [27]: Vlr Mov.Fin.da Bx �
//�         [28]: Num. do Registro  �
//�         [29]: ISS               �
//�         [30]: INSS              �
//�����������������������������������*/

aRelat := FA190ImpR4(nOrdem,@aTotais,oReport,@nGerOrig,@lMultiNat)

If Len(aRelat) = 0
	Return Nil
EndIf

Do Case
Case nOrdem == 1
	nCond1  := 10
	cTitulo += " Por Data de Pagamento"
Case nOrdem == 2
	nCond1  := 18
	cTitulo += " Por Banco"
Case nOrdem == 3
	nCond1  := 7
	cTitulo += " Por Natureza"
Case nOrdem == 4
	nCond1  := 23 //E5_BENEF
	cTitulo += " Por Ordem Alfabetica"
Case nOrdem == 5
	nCond1  := 2
	cTitulo += " Por Nro. dos Titulos"
Case nOrdem == 6	//Ordem 6 (Digitacao)
	nCond1  := 19
	cTitulo += " Por Data de Digitacao"
Case nOrdem == 7 // por Lote
	nCond1  := 24	//"E5_LOTE"
	cTitulo += " Por Lote"
OtherWise						// Data de Cr�dito (dtdispo)
	nCond1  := 25	//"E5_DTDISPO"
	cTitulo += " Por Data de Pagamento"
EndCase

If !Empty(mv_par28) .And. ! ";" $ mv_par28 .And. Len(AllTrim(mv_par28)) > 3
	ApMsgAlert("Separe os tipos a imprimir (pergunta 28) por um ; (ponto e virgula) a cada 3 caracteres")
	Return(Nil)
Endif
If !Empty(mv_par29) .And. ! ";" $ mv_par29 .And. Len(AllTrim(mv_par29)) > 3
	ApMsgAlert("Separe os tipos que n�o deseja imprimir (pergunta 29) por um ; (ponto e virgula) a cada 3 caracteres")
	Return(Nil)
Endif

//Validacao no array para que seus tipos nao gerem error log
//no exec block em TrPosition()
aEval(aRelat, {|e| Iif( e[5] == Nil, e[5] := "", .T. )} )
//������������������������������������������������������������������������Ŀ
//�Metodo TrPosition()                                                     �
//�                                                                        �
//�Posiciona em um registro de uma outra tabela. O posicionamento ser�     �
//�realizado antes da impressao de cada linha do relat�rio.                �
//�                                                                        �
//�                                                                        �
//�ExpO1 : Objeto Report da Secao                                          �
//�ExpC2 : Alias da Tabela                                                 �
//�ExpX3 : Ordem ou NickName de pesquisa                                   �
//�ExpX4 : String ou Bloco de c�digo para pesquisa. A string ser� macroexe-�
//�        cutada.                                                         �
//�                                                                        �
//��������������������������������������������������������������������������
TRPosition():New(oBaixas,"SED",1,{|| xFilial("SED") + aRelat[nI,07]})
If !((MV_MULNATR .and. mv_par11 = 1 .and. mv_par38 = 2 .and. !mv_par39 == 2) .or. (MV_MULNATP .and. mv_par11 = 2 .and. mv_par38 = 2 .and. !mv_par39 == 2) )
	TRPosition():New(oBaixas,"SE5",7,{|| xFilial("SE5") + aRelat[nI,01]+ aRelat[nI,02]+ aRelat[nI,03]+ aRelat[nI,04]+ aRelat[nI,05]})
EndIf
//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
oBaixas:Cell("E5_PREFIXO")	:SetBlock( { || aRelat[nI,01] } )
oBaixas:Cell("E5_NUMERO")	:SetBlock( { || aRelat[nI,02] } )
oBaixas:Cell("E5_PARCELA")	:SetBlock( { || aRelat[nI,03] } )
oBaixas:Cell("E5_TIPODOC")	:SetBlock( { || aRelat[nI,04] } )
oBaixas:Cell("E5_CLIFOR")	:SetBlock( { || aRelat[nI,05] } )
oBaixas:Cell("NOME CLI/FOR"):SetBlock( { || aRelat[nI,06] } )
oBaixas:Cell("E5_NATUREZ")	:SetBlock( { || aRelat[nI,07] } )
oBaixas:Cell("E5_VENCTO")	:SetBlock( { || aRelat[nI,08] } )
oBaixas:Cell("E5_HISTOR")	:SetBlock( { || aRelat[nI,09] } )
oBaixas:Cell("E5_DATA")		:SetBlock( { || aRelat[nI,10] } )
oBaixas:Cell("E5_VALOR")	:SetBlock( { || aRelat[nI,11] } )
oBaixas:Cell("IMPOSTOS") 	:SetBlock( { || aRelat[nI,12] } )
oBaixas:Cell("VLRIRRF")		:SetBlock( { || aRelat[nI,13] } )
oBaixas:Cell("VLRPIS")		:SetBlock( { || aRelat[nI,14] } )
oBaixas:Cell("VLRCOFINS")	:SetBlock( { || aRelat[nI,15] } )
oBaixas:Cell("VLRCSLL") 	:SetBlock( { || aRelat[nI,16] } )
oBaixas:Cell("E5_VALORPG")	:SetBlock( { || aRelat[nI,17] } )
oBaixas:Cell("E5_BANCO")	:SetBlock( { || aRelat[nI,18] } )
oBaixas:Cell("E5_DTDIGIT")	:SetBlock( { || aRelat[nI,19] } )
oBaixas:Cell("E5_MOTBX")	:SetBlock( { || aRelat[nI,20] } )
oBaixas:Cell("E5_ORIG")		:SetBlock( { || aRelat[nI,21] } )
oBaixas:Cell("VLRISS") 		:SetBlock( { || aRelat[nI,29] } )
oBaixas:Cell("VLRINSS") 	:SetBlock( { || aRelat[nI,30] } )

oBaixas:SetTotalText("Total Geral : ")
oBaixas:SetHeaderPage()

If (nOrdem == 1 .or. nOrdem == 6 .or. nOrdem == 8)
	oBreak1 := TRBreak():New( oBaixas, { || aRelat[nI][22]+DToS(aRelat[nI][nCond1]) }, "Sub Total")
	oBreak1:SetTotalText({ || cTotText })	 //"Sub Total"
Else //nOrdem == 2 .or. nOrdem == 3 .or. nOrdem == 4 .or. nOrdem == 5 .or. nOrdem == 7
	oBreak1 := TRBreak():New( oBaixas, { || aRelat[nI][22]+aRelat[nI][nCond1] }, "Sub Total")
	oBreak1:SetTotalText({ || cTotText })	 //"Sub Total"
EndIf
oBreak3 := TRBreak():New( oReport, { || }, "Total Geral")

//             New(<oParent>                       , [cID], <cFunction>, [oBreak], [cTitle], [cPicture], [uFormula], [lEndSection], [lEndReport]) --> NIL
TRFunction():New(oBaixas:Cell("E5_VALOR")	 	,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("E5_VALOR")  :nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,11],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("IMPOSTOS")		,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("IMPOSTOS") :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRIRRF")	 	,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRIRRF")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.) //"Sub Total"
TRFunction():New(oBaixas:Cell("VLRPIS")	 		,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRPIS")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.) //"Sub Total"
TRFunction():New(oBaixas:Cell("VLRCOFINS") 		,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRCOFINS"):nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.) //"Sub Total"
TRFunction():New(oBaixas:Cell("VLRCSLL") 		,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRCSLL"):nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.) //"Sub Total"
TRFunction():New(oBaixas:Cell("E5_VALORPG")	    ,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("E5_VALORPG"):nSize,nDecs), {|| aRelat[nI][27]}/*[ uFormula ]*/ , .F., .F.,.F.) //"Sub Total"
TRFunction():New(oBaixas:Cell("VLRISS") 		,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRISS"):nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.) //"Sub Total"
TRFunction():New(oBaixas:Cell("VLRINSS") 		,/*[cID*/, "SUM", oBreak1  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRINSS"):nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.) //"Sub Total"

If ((MV_MULNATR .and. mv_par11 = 1 .and. MV_PAR38 = 2) .or. (MV_MULNATP .and. mv_par11 = 2 .and. MV_PAR38 = 2))
	TRFunction():New(oBaixas:Cell("E5_VALOR")	 	,/*[cID*/, "SUM", oBreak3  , "Total Geral : ", tm(E5_VALOR,oBaixas:Cell("E5_VALOR")  :nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,11],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
Else
	TRFunction():New(oBaixas:Cell("E5_VALOR")	 	,/*[cID*/, "SUM", oBreak3  , "Total Geral : ", tm(E5_VALOR,oBaixas:Cell("E5_VALOR")  :nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,11],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
EndIf
TRFunction():New(oBaixas:Cell("IMPOSTOS")		,/*[cID*/, "SUM", oBreak3  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("IMPOSTOS") :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRIRRF")	 	,/*[cID*/, "SUM", oBreak3  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRIRRF")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRPIS")	 		,/*[cID*/, "SUM", oBreak3  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRPIS")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRCOFINS") 		,/*[cID*/, "SUM", oBreak3  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRCOFINS"):nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRCSLL")	 	,/*[cID*/, "SUM", oBreak3  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRCSLL")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("E5_VALORPG")	    ,/*[cID*/, "SUM", oBreak3  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("E5_VALORPG"):nSize,nDecs), {|| aRelat[nI][27]}/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRISS")	 		,/*[cID*/, "SUM", oBreak3  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRISS")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRINSS")	 	,/*[cID*/, "SUM", oBreak3  , "Sub Total", tm(E5_VALOR,oBaixas:Cell("VLRINSS")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.,.F.)

//����������������������������������������Ŀ
//� Imprimir TOTAL por filial somente quan-�
//� do houver mais do que 1 filial.        �
//������������������������������������������
If lVarFil
	oBreak2 := TRBreak():New( oBaixas, { || aRelat[nI][22] }, "FILIAL")
	TRFunction():New(oBaixas:Cell("E5_VALOR")	 	,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("E5_VALOR")  :nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,11],0) }/*[ uFormula ]*/ , .F., .F.)
	TRFunction():New(oBaixas:Cell("IMPOSTOS")	 	,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("IMPOSTOS")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.) //"FILIAL"
	TRFunction():New(oBaixas:Cell("VLRIRRF")		,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("VLRIRRF") :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.) //"FILIAL"
	TRFunction():New(oBaixas:Cell("VLRPIS")	 		,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("VLRPIS")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.) //"FILIAL"
	TRFunction():New(oBaixas:Cell("VLRCOFINS")	 	,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("VLRCOFINS")  :nSize,nDecs), /*[ uFormula ]*/ , .F., .F.) //"FILIAL"
	TRFunction():New(oBaixas:Cell("VLRCSLL") 		,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("VLRCSLL"):nSize,nDecs), /*[ uFormula ]*/ , .F., .F.) //"FILIAL"
	TRFunction():New(oBaixas:Cell("E5_VALORPG")		,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("E5_VALORPG"):nSize,nDecs), {|| aRelat[nI][27]}/*[ uFormula ]*/ , .F., .F.) //"FILIAL"
	TRFunction():New(oBaixas:Cell("VLRISS") 		,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("VLRISS"):nSize,nDecs), /*[ uFormula ]*/ , .F., .F.) //"FILIAL"
	TRFunction():New(oBaixas:Cell("VLRINSS") 		,/*[cID*/, "SUM", oBreak2  , "FILIAL", tm(E5_VALOR,oBaixas:Cell("VLRINSS"):nSize,nDecs), /*[ uFormula ]*/ , .F., .F.) //"FILIAL"
	oBreak2:SetTotalText({ || "FILIAL" + " : " + cTxtFil })	 //"FILIAL"
EndIf

oBreak1:OnPrintTotal({ || PRINTTOT(aTotais,oReport,.F.,,@nJ   ) })
If nOrdem != 3 .and. lVarFil
	oBreak2:OnPrintTotal({ || PRINTTOT(aTotais,oReport,.T.,,@nJ) })
EndIf

oBaixas:Cell("E5_VALOR")	:SetPicture(tm(E5_VALOR,oBaixas:Cell("E5_VALOR")  	:nSize,nDecs))
oBaixas:Cell("IMPOSTOS")	:SetPicture(tm(E5_VALOR,oBaixas:Cell("IMPOSTOS")  	:nSize,nDecs))
oBaixas:Cell("VLRIRRF")		:SetPicture(tm(E5_VALOR,oBaixas:Cell("VLRIRRF")		:nSize,nDecs))
oBaixas:Cell("VLRPIS")		:SetPicture(tm(E5_VALOR,oBaixas:Cell("VLRPIS")  	:nSize,nDecs))
oBaixas:Cell("VLRCOFINS")	:SetPicture(tm(E5_VALOR,oBaixas:Cell("VLRCOFINS")  :nSize,nDecs))
oBaixas:Cell("VLRCSLL")		:SetPicture(tm(E5_VALOR,oBaixas:Cell("VLRCSLL")		:nSize,nDecs))
oBaixas:Cell("E5_VALORPG")	:SetPicture(tm(E5_VALOR,oBaixas:Cell("E5_VALORPG")	:nSize,nDecs))
oBaixas:Cell("VLRISS")		:SetPicture(tm(E5_VALOR,oBaixas:Cell("VLRISS") 		:nSize,nDecs))
oBaixas:Cell("VLRINSS")		:SetPicture(tm(E5_VALOR,oBaixas:Cell("VLRINSS") 	:nSize,nDecs))

//����������������������������������������Ŀ
//Total Geral
//����������������������������������������Ŀ
oBreak3 := TRBreak():New( oBaixas, { || }, "Total Geral")
TRFunction():New(oBaixas:Cell("E5_VALOR")	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("E5_VALOR")		:nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,11],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("IMPOSTOS")	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("IMPOSTOS")	:nSize,nDecs), {|| aRelat[nI,12]}/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRIRRF")	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("VLRIRRF")  	:nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,13],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRPIS")	 	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("VLRPIS")  	:nSize,nDecs), {|| If(aRelat[nI,26] .Or. aRelat[nI,14] > 0,aRelat[nI,14],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRCOFINS")	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("VLRCOFINS")	:nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,15],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRCSLL")	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("VLRCSLL")  	:nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,16],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("E5_VALORPG")	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("E5_VALORPG")  	:nSize,nDecs), {|| aRelat[nI,27] }/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRISS")	 	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("VLRISS")  	:nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,29],0) }/*[ uFormula ]*/ , .F., .F.,.F.)
TRFunction():New(oBaixas:Cell("VLRINSS")	,/*[cID*/, "SUM", oBreak3  , "", tm(E5_VALOR,oBaixas:Cell("VLRINSS")  	:nSize,nDecs), {|| If(aRelat[nI,26],aRelat[nI,30],0) }/*[ uFormula ]*/ , .F., .F.,.F.)

oReport:SetTitle(cTitulo)
oReport:SetMeter(Len(aRelat))

oBaixas:Init()
nI := 1
While nI <= Len(aRelat)

	If oReport:Cancel()
		nI++
		Exit
	EndIf

    //If ((MV_MULNATR .and. mv_par11 = 1 .and. mv_par38 = 2 .and. !mv_par39 == 2) .or. (MV_MULNATP .and. mv_par11 = 2 .and. mv_par38 = 2 .and. !mv_par39 == 2) )
	If lNaturez
		If !Empty(aRelat[nI,28])
			SE5->(dbGoTo(aRelat[nI,29]))
		Endif
    Endif

	//�����������������������������������������������Ŀ
	//�Posiciona na Filial do Movimento a ser impresso�
	//�������������������������������������������������
	//If ((MV_MULNATR .and. mv_par11 = 1 .and. mv_par38 = 2 .and. !mv_par39 == 2) .or. (MV_MULNATP .and. mv_par11 = 2 .and. mv_par38 = 2 .and. !mv_par39 == 2))
	If lNaturez
	  	SE5->(dbGoto(aRelat[nI,29]))
	Else
	  	SE5->(dbGoto(aRelat[nI,28]))
	Endif
  	cFilAnt := SE5->E5_FILIAL
   	oReport:IncMeter()
	oBaixas:PrintLine()

	If (nOrdem == 1 .or. nOrdem == 6 .or. nOrdem == 8)
		cTotText := "Sub Total" + " : " + DToC(aRelat[nI][nCond1])
	Else //nOrdem == 2 .or. nOrdem == 3 .or. nOrdem == 4 .or. nOrdem == 5 .or. nOrdem == 7
		cTotText := "Sub Total" + " : " + aRelat[nI][nCond1]
		If nOrdem == 2 //Banco
			SA6->(DbSetOrder(1))
			SA6->(MsSeek(xFilial("SA6")+aRelat[nI][nCond1]))
			cTotText += " " + TRIM(SA6->A6_NOME)
		ElseIf nOrdem == 3 //Natureza
			SED->(DbSetOrder(1))
			SED->(MsSeek(xFilial("SED")+aRelat[nI][nCond1]))
			cTotText += SED->ED_DESCRIC
		EndIf
	EndIf

	If lVarFil
		cTxtFil := aRelat[nI][22]
	EndIf

	nI++

EndDo
SE5->(dbGoto(nRegSE5))
SM0->(dbGoTo(nRegSM0))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

//nao retirar "nI--" pois eh utilizado na impressao do ultimo TRFunction
nI--

oBaixas:Finish()
PRINTTOT(aTotais,oReport,.F.,3,@nJ)

Return NIL


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PRINTTOT � Autor � Daniel Tadashi Batori � Data � 10.10.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime os totais "Baixados", "Mov Fin.", "Compens."       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PRINTTOT(aTotal,oReport,lFil)                              ���
���          � aTotais -> array a ser utilizado para impressao            ���
���          � oReport -> objeto TReport                                  ���
���          � lFil -> .F. se for total da secao ou .T. se for da filial  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PRINTTOT(aTotais,oReport,lFil,nBreak,nJ)
Local nDecs := GetMv("MV_CENT"+(If(mv_par12 > 1 , STR(mv_par12,1),"")))
Local cAnt := ""
Local nAscan := 0
Local cGeral := OemToAnsi("Geral")
Local nTamAnt:= 0
Default nJ 	 := 1

If lFil == .T.
	oReport:SkipLine(2)
EndIf

nAscan := Ascan(aTotais , {|e| Alltrim(e[1]) ==  cGeral } )

If nBreak <> 3
	If Len(aTotais)>0
		cAnt := aTotais[nJ][1]
	EndIf
	While (nJ< Len(aTotais)) .And. (cAnt == aTotais[nJ][1]) .and. nJ < nAscan
		oReport:PrintText( PadR(aTotais[nJ][2],12," ") + Transform(aTotais[nJ][3], tm(aTotais[nJ][3],20,nDecs) ) )
		nJ++
	EndDo
Else
	oReport:PrintText( '' )
	oReport:PrintText( "Geral" + ':' )
	While nAscan > 0
		oReport:PrintText( PadR(aTotais[nAscan][2],12," ") + Transform(aTotais[nAscan][3], tm(aTotais[nAscan][3],20,nDecs) ) )
		nAscan := If( (nAscan+1)<=Len(aTotais) .and. aTotais[nAscan+1][1] == cGeral,nAscan+1,0)
	EndDo
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR190  � Autor � Wagner Xavier         � Data � 05.10.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o das baixas                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR190(void)                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function R3TitsBx()

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������

Local wnrel
Local aOrd:={OemToAnsi("Por Data"),OemToAnsi("Por Banco"),OemToAnsi("Por Natureza"),OemToAnsi("Alfabetica"),OemToAnsi("Nro. Titulo"),OemToAnsi("Dt.Digitacao"),OemToAnsi("Por Lote"),"Por Data de Credito"}
Local cDesc1 := "Este programa ir� emitir a rela��o dos titulos baixados."
Local cDesc2 := "Poder� ser emitido por data, banco, natureza ou alfab�tica"
Local cDesc3 := "de cliente ou fornecedor e data da digita��o."
Local tamanho:="G"
Local cString:="SE5"

Private titulo:=OemToAnsi("Relacao de Baixas")
Private cabec1
Private cabec2
Private cNomeArq
Private aReturn := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 1, 2, 1, "",1 }
Private nomeprog:="TitsBx"
Private aLinha  := { },nLastKey := 0
Private cPerg   := Padr("FIN190",10)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)

//����������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                     �
//� mv_par01            // da data da baixa                  �
//� mv_par02            // at� a data da baixa               �
//� mv_par03            // do banco                          �
//� mv_par04            // at� o banco                       �
//� mv_par05            // da natureza                       �
//� mv_par06            // at� a natureza                    �
//� mv_par07            // do c�digo                         �
//� mv_par08            // at� o c�digo                      �
//� mv_par09            // da data de digita��o              �
//� mv_par10            // ate a data de digita��o           �
//� mv_par11            // Tipo de Carteira (R/P)            �
//� mv_par12            // Moeda                             �
//� mv_par13            // Hist�rico: Baixa ou Emiss�o       �
//� mv_par14            // Imprime Baixas Normais / Todas    �
//� mv_par15            // Situacao                          �
//� mv_par16            // Cons Mov Fin                      �
//� mv_par17            // Cons filiais abaixo               �
//� mv_par18            // da filial                         �
//� mv_par19            // ate a filial                      �
//� mv_par20            // Do Lote                           �
//� mv_par21            // Ate o Lote                        �
//� mv_par22            // da loja                           �
//� mv_par23            // Ate a loja                        �
//� mv_par24            // NCC Compensados                   �
//� mv_par25            // Outras Moedas                     �
//� mv_par26            // do prefixo                        �
//� mv_par27            // at� o prefixo                     �
//� mv_par28            // Imprimir os Tipos                 �
//� mv_par29            // Nao Imprimir Tipos			       �
//� mv_par30            // Imprime nome (Normal ou reduzido) �
//� mv_par31            // da data da vencto. do tit         �
//� mv_par32            // at� a data de vencto do tit.      �
//� mv_par33            // da filial origem                  �
//� mv_par34            // ate filial origem                 �
//� mv_par35            // Impr.Incl. Adiantamentos ?Sim/Nao �
//� mv_par36            // Imprime Titulos em Carteira ?     |
//� mv_par37            // Imp. mov. cheque aglutinado?Cheque/Baixa/Ambos�
//� mv_par38            // Cons. Nat. Aglutinadas? Sim/Nao   |
//| mv_par39            // Filtrar Natureza Por?             |
//|                                  - Padrao                |
//|                                  - Nat.Principal         |
//|                                  - Mult.Naturezas        |
//������������������������������������������������������������
//����������������������������������������������������������Ŀ
//� Envia controle para a fun��o SETPRINT                    �
//������������������������������������������������������������
wnrel := "TitsBx"            //Nome Default do relat�rio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Return(Nil)
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return(Nil)
EndIf

cFilterUser := aReturn[7]

RptStatus({|lEnd| Fa190Imp(@lEnd,wnRel,cString)},Titulo)

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FA190Imp � Autor � Wagner Xavier         � Data � 05.10.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o das baixas                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FA190Imp(lEnd,wnRel,cString)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd    - A��o do Codeblock                                ���
���          � wnRel   - T�tulo do relat�rio                              ���
���          � cString - Mensagem                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FA190Imp(lEnd,wnRel,cString)

Local cExp 			:= ""
Local CbTxt,CbCont
Local nValor:=0,nDesc:=0,nJuros:=0,nMulta:=0,nJurMul:=0,nCM:=0,dData,nVlMovFin:=0
Local nTotValor:=0,nTotDesc:=0,nTotJurMul:=0,nTotCm:=0,nTotOrig:=0,nTotBaixado:=0,nTotMovFin:=0,nTotComp:=0,nTotFat:=0
Local nGerValor:=0,nGerDesc:=0,nGerJurMul:=0,nGerCm:=0,nGerOrig:=0,nGerBaixado:=0,nGerMovFin:=0,nGerComp:=0,nGerFat:=0
Local nFilOrig:=0,nFilJurMul:=0,nFilCM:=0,nFilDesc:=0
Local nFilAbLiq:=0,nFilAbImp:=0,nFilValor:=0,nFilBaixado:=0,nFilMovFin:=0,nFilComp:=0, nFilFat:=0
Local nAbatLiq := 0,nTotAbImp := 0,nTotImp := 0,nTotAbLiq := 0,nGerAbLiq := 0,nGerAbImp := 0
Local cBanco,cNatureza,cAnterior,cCliFor,nCT:=0,dDigit,cLoja
Local lContinua		:=.T.
Local lBxTit		:=.F.
Local lBxLoja		:=.F.			//Verifica se o titulo foi baixado pelo loja e tem a excecao do MV_LJTROCO = .T.
Local tamanho		:="G"
Local aCampos:= {},cNomArq1:="",nVlr,cLinha,lOriginal:=.T.
Local nAbat 		:= 0
Local cHistorico
Local lManual 		:= .f.
Local cTipodoc
Local nRecSe5 		:= 0
Local dDtMovFin
Local cRecPag
Local nRecEmp 		:= SM0->(Recno())
Local cMotBaixa		:= CRIAVAR("E5_MOTBX")
Local cFilNome 		:= Space(15)
Local cCliFor190	:= ""
Local aTam 			:= IIF(mv_par11 == 1,TamSX3("E1_CLIENTE"),TamSX3("E2_FORNECE"))
Local aColu 		:= {}
Local nDecs	   		:= GetMv("MV_CENT"+(IIF(mv_par12 > 1 , STR(mv_par12,1),"")))
Local nMoedaBco		:= 1
Local cCarteira
#IFDEF TOP
	Local aStru		:= SE5->(DbStruct()), nI
	Local cQuery
#ENDIF
Local cFilTrb
Local lAsTop		:= .F.
Local cFilSe5		:= ".T."
Local cChave, bFirst
Local cFilOrig
Local lAchou		:= .F.
Local lF190Qry		:= ExistBlock("F190QRY")
Local cQueryAdd		:= ""
Local lAjuPar15		:= Len(AllTrim(mv_par15))==Len(mv_par15)
Local lAchouEmp		:= .T.
Local lAchouEst		:= .F.
Local nTamEH		:= TamSx3("EH_NUMERO")[1]
Local nTamEI		:= TamSx3("EI_NUMERO")[1]+TamSx3("EI_REVISAO")[1]+TamSx3("EI_SEQ")[1]
Local cCodUlt		:= SM0->M0_CODIGO
Local cFilUlt		:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local nRecno
Local nSavOrd
Local aAreaSE5
Local cChaveNSE5	:= ""

Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
				 !Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
				 !Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
				 !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

Local nTaxa:= 0
Local lUltBaixa := .F.
Local cChaveSE1 := ""
Local cChaveSE5 := ""
Local cSeqSE5 := ""
Local cBancoAnt, cAgAnt, cContaAnt
Local lNaturez := .F.

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emiss�o(default))
Local lPccBxCr	:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)
Local nPccBxCr := 0
Local nIRRF    := 0
Local nTotIRRF := 0
Local nGerIRRF := 0
Local nFilIRRF := 0
Local nPIS     := 0
Local nTotPIS  := 0
Local nGerPIS  := 0
Local nFilPIS  := 0
Local nCOFINS  := 0
Local nTotCOFI := 0
Local nGerCOFI := 0
Local nFilCOFI := 0
Local nCSLL    := 0
Local nTotCSLL := 0
Local nGerCSLL := 0
Local nFilCSLL := 0
Local nISS     := 0
Local nTotISS  := 0
Local nGerISS  := 0
Local nFilISS  := 0
Local nINSS    := 0
Local nTotINSS := 0
Local nGerINSS := 0
Local nFilINSS := 0

//Controla o Pis Cofins e Csll na RA (1 = Controla reten��o de impostos no RA; ou 2 = N�o controla reten��o de impostos no RA(default))
Local lRaRtImp  := FRaRtImp()
Local lConsImp := .T.

If MV_PAR41 == 2
	lConsImp := .F.
EndIf

Private nIndexSE5	:= 0
//��������������������������������������������������������������Ŀ
//� Vari�veis utilizadas para Impress�o do Cabe�alho e Rodap�    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1
nOrdem 	:= aReturn[8]
cSuf	:= LTrim(Str(mv_par12))
cMoeda	:= GetMv("MV_MOEDA"+cSuf)
cCond3	:= ".T."

//��������������������������������������������������Ŀ
//� Quando selecionada a opcao "Multiplas Naturezas" |
//� forcar a utilizacao do relatorio atraves da      |
//� funcao FINR199 (Rel.Multiplas Naturezas)         |
//����������������������������������������������������
If mv_par39 == 3
	mv_par38 := 2
EndIf
//��������������������������������Ŀ
//� Defini��o dos cabe�alhos       �
//����������������������������������
If mv_par11 == 1
	titulo := OemToAnsi("Relacao dos Titulos Recebidos em ")  + cMoeda
	cabec1 := iif(aTam[1] > 6 , OemToAnsi("Cliente-Nome Cliente "),OemToAnsi("Prf Numero    Prc TP  Cliente   Nome Cliente         Natureza   Vencto   Historico               Dt Baixa  Valor Original    Impostos        IRRF         PIS      COFINS        CSLL  Total Baixado Bco  Dt Digit Mot Orig"))
	cabec2 := iif(aTam[1] > 6 , OemToAnsi("                       Prf Numero       P TP     Natureza   Vencto     Historico          Dt Baixa   Valor Original  Tx Permanen        Multa     Correcao    Descontos  Abatimentos     Total Rec. Bco Dt Digit.  Mot.Baixa"),"")
Else
	titulo := OemToAnsi("Relacao dos Titulos Pagos em ") + cMoeda
	cabec1 := iif(aTam[1] > 6 , OemToAnsi("Fornecedor           Nome do Fornecedor"),OemToAnsi("Prf Numero     Prc TP  Fornec Nome Fornecedor    Natureza   Vencto     Historico             Dt Baixa  Valor Original   Jur/Multa    Correcao   Descontos     Abatim.    Impostos   Total Baixado   Bco   Dt Dig.  Mot Orig "))
	cabec2 := iif(aTam[1] > 6 , OemToAnsi("                       Prf Numero     Prc TP     Natureza   Vencto     Historico          Dt Baixa     Valor Original   Jur/Multa    Correcao   Descontos     Abatim.    Impostos   Total Baixado   Bco   Dt Dig.  Mot Orig "),"")
EndIf

/*
Prf Numero    Prc TP  Cliente   Nome Cliente         Natureza   Vencto   Historico               Dt Baixa  Valor Original    Impostos        IRRF         PIS      COFINS        CSLL  Total Baixado Bco  Dt Digit Mot Orig
XXX XXXXXXXXX XXX xxx xxxxxx-xx xxxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx/xx/xx xxxxxxxxxxxxxxxxxxxxxxx xx/xx/xx  999.999.999,99 9999.999,99 9999.999,99 9999.999,99 9999.999,99 9999.999,99 999,999.999,99 xxx  xx/xx/xx xxx xx
*/

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If mv_par17 == 2
	cFilDe := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	cFilAte:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Else
	cFilDe := mv_par18	// Todas as filiais
	cFilAte:= mv_par19
EndIf
// Definicao das condicoes e ordem de impressao, de acordo com a ordem escolhida pelo
// usuario.
DbSelectArea("SE5")
Do Case
Case nOrdem == 1
	cCondicao := "E5_DATA >= mv_par01 .and. E5_DATA <= mv_par02"
	cCond2 := "E5_DATA"
	cChave := IndexKey(1)
	cChaveInterFun := cChave
	titulo += OemToAnsi(" por data de pagamento")
	bFirst := {|| MsSeek(xFilial("SE5")+Dtos(mv_par01),.T.)}
Case nOrdem == 2
	cCondicao := "E5_BANCO >= mv_par03 .and. E5_BANCO <= mv_par04"
	cCond2 := "E5_BANCO"
	cChave := IndexKey(3)
	cChaveInterFun := cChave
	titulo += OemToAnsi(" por Banco")
	bFirst := {||MsSeek(xFilial("SE5")+mv_par03,.T.)}
Case nOrdem == 3
	cCondicao := "E5_MULTNAT = '1' .Or. (E5_NATUREZ >= mv_par05 .and. E5_NATUREZ <= mv_par06)"
	cCond2 := "E5_NATUREZ"
	cChave := IndexKey(4)
	cChaveInterFun := cChave
	titulo += OemToAnsi(" por Natureza")
	bFirst := {||MsSeek(xFilial("SE5")+mv_par05,.T.)}
Case nOrdem == 4
	cCondicao := ".T."
	cCond2 := "E5_BENEF"
	cChave := "E5_FILIAL+E5_BENEF+DTOS(E5_DATA)+E5_PREFIXO+E5_NUMERO+E5_PARCELA"
	cChaveInterFun := cChave
	titulo += OemToAnsi(" Alfabetica")
	bFirst := {||MsSeek(xFilial("SE5"),.T.)}
Case nOrdem == 5
	cCondicao := ".T."
	cCond2 := "E5_NUMERO"
	cChave := "E5_FILIAL+E5_NUMERO+E5_PARCELA+E5_PREFIXO+DTOS(E5_DATA)"
	cChaveInterFun := cChave
	titulo += OemToAnsi(" Nro. dos Titulos")
	bFirst := {||MsSeek(xFilial("SE5"),.T.)}
Case nOrdem == 6	//Ordem 6 (Digitacao)
	cCondicao := ".T."
	cCond2 := "E5_DTDIGIT"
	cChave := "E5_FILIAL+DTOS(E5_DTDIGIT)+E5_PREFIXO+E5_NUMERO+E5_PARCELA+DTOS(E5_DATA)"
	cChaveInterFun := cChave
	titulo += OemToAnsi(" Por Data de Digitacao")
	bFirst := {||MsSeek(xFilial("SE5"),.T.)}
Case nOrdem == 7 // por Lote
	cCondicao := "E5_LOTE >= mv_par20 .and. E5_LOTE <= mv_par21"
	cCond2 := "E5_LOTE"
	cChave := IndexKey(5)
	cChaveInterFun := cChave
	titulo += OemToAnsi(" por Lote")
	bFirst := {||MsSeek(xFilial("SE5")+mv_par20,.T.)}
OtherWise						// Data de Cr�dito (dtdispo)
	cCondicao := "E5_DTDISPO >= mv_par01 .and. E5_DTDISPO <= mv_par02"
	cCond2 := "E5_DTDISPO"
	cChave := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
	cChaveInterFun := cChave
	titulo += OemToAnsi(" por data de pagamento")
	bFirst := {||MsSeek(xFilial("SE5")+Dtos(mv_par01),.T.)}
EndCase

If !Empty(mv_par28) .And. ! ";" $ mv_par28 .And. Len(AllTrim(mv_par28)) > 3
	ApMsgAlert("Separe os tipos a imprimir (pergunta 28) por um ; (ponto e virgula) a cada 3 caracteres")
	Return(Nil)
Endif
If !Empty(mv_par29) .And. ! ";" $ mv_par29 .And. Len(AllTrim(mv_par29)) > 3
	ApMsgAlert("Separe os tipos que n�o deseja imprimir (pergunta 29) por um ; (ponto e virgula) a cada 3 caracteres")
	Return(Nil)
Endif

#IFDEF TOP
	If TcSrvType() != "AS/400" .and. TCGetDB()!="SYBASE"
		lAsTop := .T.
		cCondicao := ".T."
		DbSelectArea("SE5")
		cQuery := ""
		aEval(DbStruct(),{|e| cQuery += ","+AllTrim(e[1])})
		// Obtem os registros a serem processados
		cQuery := "SELECT " +SubStr(cQuery,2)
		cQuery +=         ",SE5.R_E_C_N_O_ SE5RECNO "
		cQuery += "FROM " + RetSqlName("SE5")+" SE5 "
		cQuery += "WHERE E5_RECPAG = '" + IIF( mv_par11 == 1, "R","P") + "' AND "
		cQuery += "      E5_DATA    between '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND "
		cQuery += "      E5_DATA    <= '" + DTOS(dDataBase) + "' AND "
		cQuery += "      E5_BANCO   between '" + mv_par03       + "' AND '" + mv_par04       + "' AND "
		//-- Realiza filtragem pela natureza principal
		If mv_par39 == 2
			cQuery +=  " E5_NATUREZ between '" + mv_par05       + "' AND '" + mv_par06     	+ "' AND "
		Else
			cQuery +=  " (E5_NATUREZ between '" + mv_par05       + "' AND '" + mv_par06     	+ "' OR "
			cQuery +=  " EXISTS (SELECT EV_FILIAL, EV_PREFIXO, EV_NUM, EV_PARCELA, EV_CLIFOR, EV_LOJA "
			cQuery +=            " FROM "+RetSqlName("SEV")+" SEV "
			cQuery +=           " WHERE E5_FILIAL  = EV_FILIAL  AND "
			cQuery +=                  "E5_PREFIXO = EV_PREFIXO AND "
			cQuery +=                  "E5_NUMERO  = EV_NUM     AND "
			cQuery +=                  "E5_PARCELA = EV_PARCELA AND "
			cQuery +=                  "E5_TIPO    = EV_TIPO    AND "
			cQuery +=                  "E5_CLIFOR  = EV_CLIFOR  AND "
			cQuery +=                  "E5_LOJA    = EV_LOJA    AND "
			cQuery +=                  "EV_NATUREZ between '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
			cQuery +=                  "SEV.D_E_L_E_T_ = ' ')) AND "
		EndIf
		cQuery += "      E5_CLIFOR  between '" + mv_par07       + "' AND '" + mv_par08       + "' AND "
		cQuery += "      E5_DTDIGIT between '" + DTOS(mv_par09) + "' AND '" + DTOS(mv_par10) + "' AND "
		cQuery += "      E5_LOTE    between '" + mv_par20       + "' AND '" + mv_par21       + "' AND "
		cQuery += "      E5_LOJA    between '" + mv_par22       + "' AND '" + mv_par23 	    + "' AND "
		cQuery += "      E5_PREFIXO between '" + mv_par26       + "' AND '" + mv_par27 	    + "' AND "
		cQuery += "      SE5.D_E_L_E_T_ = ' '  AND "
		cQuery += "		  E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE') AND "
		cQuery += " 	  E5_SITUACA NOT IN ('C','E','X') AND "
		cQuery += "      ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR "
		cQuery += "      (E5_TIPODOC <> 'CD')) "
		cQuery += "		  AND E5_HISTOR NOT LIKE '%"+'Baixa Automatica / Lote'+"%'"

		If mv_par11 == 2
			cQuery += " AND E5_TIPODOC <> 'E2'"
		EndIf

		If !Empty(mv_par28) // Deseja imprimir apenas os tipos do parametro 28
			cQuery += " AND E5_TIPO IN "+FormatIn(mv_par28,";")
		ElseIf !Empty(Mv_par29) // Deseja excluir os tipos do parametro 29
			cQuery += " AND E5_TIPO NOT IN "+FormatIn(mv_par29,";")
		EndIf

		If mv_par16 == 2
			cQuery += " AND E5_TIPODOC <> '" + SPACE(LEN(E5_TIPODOC)) + "'"
			cQuery += " AND E5_NUMERO  <> '" + SPACE(LEN(E5_NUMERO)) + "'"
			cQuery += " AND E5_TIPODOC <> 'CH'"
		Endif

		If mv_par17 == 2
			cQuery += " AND E5_FILIAL = '" + xFilial("SE5") + "'"
		Else
			cQuery += " AND E5_FILIAL between '" + mv_par18 + "' AND '" + mv_par19 + "'"
		Endif

		If lF190Qry
			cQueryAdd := ExecBlock("F190QRY", .F., .F., {aReturn[7]})
			If ValType(cQueryAdd) == "C"
				cQuery += " AND (" + cQueryAdd + ")"
			EndIf
		EndIf

		// seta a ordem de acordo com a opcao do usuario
		cQuery += " ORDER BY " + SqlOrder(cChave)
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "NEWSE5", .F., .T.)
		For nI := 1 TO LEN(aStru)
			If aStru[nI][2] != "C"
				TCSetField("NEWSE5", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
			EndIf
		Next
		DbGoTop()
	Else
#ENDIF
		//�������������������������������������������������������������Ŀ
		//� Abre o SE5 com outro alias para ser filtrado porque a funcao�
		//� TemBxCanc() utilizara o SE5 sem filtro.							 �
		//���������������������������������������������������������������
		If Select("NEWSE5") == 0 .And. !( ChkFile("SE5",.F.,"NEWSE5") )
			Return(Nil)
		EndIf
		lAsTop := .F.
		DbSelectArea("NEWSE5")
		cFilSE5 := 'E5_RECPAG=='+IIF(mv_par11 == 1,'"R"','"P"')+'.and.'
		cFilSE5 += 'DTOS(E5_DATA)>='+'"'+dtos(mv_par01)+'"'+'.and.DTOS(E5_DATA)<='+'"'+dtos(mv_par02)+'".and.'
		cFilSE5 += 'DTOS(E5_DATA)<='+'"'+dtos(dDataBase)+'".and.'
		If nOrdem == 3
   			cFilSE5 += '(E5_MULTNAT = "1" .Or. (E5_NATUREZ>='+'"'+mv_par05+'"'+'.and.E5_NATUREZ<='+'"'+mv_par06+'")).and.'
		Else
			cFilSE5 += '(E5_NATUREZ>='+'"'+mv_par05+'"'+'.and.E5_NATUREZ<='+'"'+mv_par06+'").and.'
		Endif
		cFilSE5 += 'E5_CLIFOR>='+'"'+mv_par07+'"'+'.and.E5_CLIFOR<='+'"'+mv_par08+'".and.'
		cFilSE5 += 'DTOS(E5_DTDIGIT)>='+'"'+dtos(mv_par09)+'"'+'.and.DTOS(E5_DTDIGIT)<='+'"'+dtos(mv_par10)+'".and.'
		cFilSE5 += 'E5_LOTE>='+'"'+mv_par20+'"'+'.and.E5_LOTE<='+'"'+mv_par21+'".and.'
		cFilSE5 += 'E5_LOJA>='+'"'+mv_par22+'"'+'.and.E5_LOJA<='+'"'+mv_par23+'".and.'
		cFilSe5 += 'E5_PREFIXO>='+'"'+mv_par26+'"'+'.And.E5_PREFIXO<='+'"'+mv_par27+'"'
		If !Empty(mv_par28) // Deseja imprimir apenas os tipos do parametro 28
			cFilSe5 += '.And.E5_TIPO $'+'"'+ALLTRIM(mv_par28)+Space(1)+'"'
		ElseIf !Empty(Mv_par29) // Deseja excluir os tipos do parametro 29
			cFilSe5 += '.And.!(E5_TIPO $'+'"'+ALLTRIM(mv_par29)+Space(1)+'")'
		EndIf
#IFDEF TOP
	Endif
#ENDIF
// Se nao for TOP, ou se for TOP e for AS400, cria Filtro com IndRegua
// Pois em SQL os registros ja estao filtrados em uma Query
If !lAsTop
	cNomeArq := CriaTrab(Nil,.F.)
	IndRegua("NEWSE5",cNomeArq,cChave,,cFilSE5,OemToAnsi("Selecionando Registros..."))
Endif

//������������������������������������������Ŀ
//� Define array para arquivo de trabalho    �
//��������������������������������������������
AADD(aCampos,{"LINHA","C",80,0 } )

//����������������������������Ŀ
//� Cria arquivo de Trabalho   �
//������������������������������
cNomArq1 := CriaTrab(aCampos)
dbUseArea( .T.,, cNomArq1, "Trb", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("TRB",cNomArq1,"LINHA",,,OemToAnsi("Selecionando Registros..."))

aColu := Iif(aTam[1] > 6,{023,027,TamParcela("E1_PARCELA",40,39,38),042,000,022},{0,4,14,18,22,32,53,64,73,97,107,122,134,146,158,170,182,197,202,211,215})

If MV_PAR16 == 1
	/*
	cChaveSE5  := "E5_FILIAL + E5_BANCO + E5_AGENCIA + E5_CONTA + E5_NUMCHEQ + E5_TIPODOC + E5_SEQ"
	dbSelectArea("SE5")
	cIndexSE5 := CriaTrab(nil,.f.)
	IndRegua("SE5",cIndexSE5,cChaveSE5,,,"Selecionando")

	#IFNDEF TOP
		dbSetIndex(cIndexSE5+OrdBagExt())
		nIndexSE5 := RetIndex("SE5")
	#ELSE
		nIndexSE5 := RetIndex("SE5")+1
	#ENDIF
	dbSelectArea("SE5")
	dbSetOrder(nIndexSE5+1)
	dbGoTop()
	*/
	dbSelectArea("SE5")
	dbSetOrder(17) //"E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+E5_TIPODOC+E5_SEQ"
	dbGoTop()

Endif

DbSelectArea("SM0")
DbSeek(cEmpAnt+cFilDe,.T.)

While !Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	cFilNome:= SM0->M0_FILIAL
	DbSelectArea("NEWSE5")
	SetRegua(RecCount())
	// Se nao for TOP, ou se for TOP e for AS400, posiciona no primeiro registro do escopo
	// Pois em SQL os registro ja estao filtrados em uma Query e ja esta no inicio do arquivo
	If !lAsTop
		Eval(bFirst) // Posiciona no primeiro registro a ser processado
	Endif

	//If ((MV_MULNATR .and. mv_par11 = 1 .and. mv_par38 = 2 .and. !mv_par39 == 2) .or. (MV_MULNATP .and. mv_par11 = 2 .and. mv_par38 = 2 .and. !mv_par39 == 2) )
	If lNaturez

		Finr199R3(	@nGerOrig,@nGerValor,@nGerDesc,@nGerJurMul,@nGerCM,@nGerAbLiq,@nGerAbImp,@nGerBaixado,@nGerMovFin,@nGerComp,;
					@nFilOrig,@nFilValor,@nFilDesc,@nFilJurMul,@nFilCM,@nFilAbLiq,@nFilAbImp,@nFilBaixado,@nFilMovFin,@nFilComp,;
					lEnd,cCondicao,cCond2,aColu,lContinua,cFilSe5,lAsTop,Tamanho,nOrdem, @nGerFat, @nFilFat)

		#IFDEF TOP
			If TcSrvType() != "AS/400" .and. TCGetDB()!="SYBASE"
				dbSelectArea("SE5")
				dbCloseArea()
				ChKFile("SE5")
				dbSelectArea("SE5")
				dbSetOrder(1)
			Endif
		#ENDIF
		If Empty(xFilial("SE5"))
			Exit
		Endif
		dbSelectArea("SM0")
		cCodUlt := SM0->M0_CODIGO
		cFilUlt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
		dbSkip()
		Loop

	Else

		While NEWSE5->(!Eof()) .And. NEWSE5->E5_FILIAL==xFilial("SE5") .And. &cCondicao .and. lContinua
			If lEnd
				@PROW()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")
				lContinua:=.F.
				Exit
			EndIf

			IncRegua()
			DbSelectArea("NEWSE5")
			// Testa condicoes de filtro
			If !Fr190TstCond(cFilSe5,.F.)
				NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
				Loop
			Endif

			// Se nao for TOP, ou se for TOP e for AS400, posiciona no primeiro registro do escopo
			// Pois em SQL os registro ja estao filtrados em uma Query e ja esta no inicio do arquivo
			If !lAsTop
				SE2->(dbSetOrder(1))
				SE2->(MsSeek(NEWSE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
				If SE2->E2_MULTNAT == '1'
					lNaturez := .F.
					SEV->(dbSetOrder(1))
					SEV->(MsSeek(NEWSE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
					While NEWSE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA) .and. !lNaturez
						If SEV->EV_NATUREZ >= mv_par05 .and. SEV->EV_NATUREZ <= mv_par06
							lNaturez := .T.
						EndIf
						SEV->(DbSkip())
					EndDo
					If !lNaturez
						NEWSE5->(dbSkip())
						Loop
					EndIf
				Else
					If !(NEWSE5->E5_NATUREZ >= mv_par05 .and. NEWSE5->E5_NATUREZ <= mv_par06)
						NEWSE5->(dbSkip())
						Loop
					EndIf
				EndIf
			EndIf

			If (NEWSE5->E5_RECPAG == "R" .and. ! (NEWSE5->E5_TIPO $ "PA /"+MV_CPNEG )) .or. ;	//Titulo normal
				(NEWSE5->E5_RECPAG == "P" .and.   (NEWSE5->E5_TIPO $ "RA /"+MV_CRNEG )) 	//Adiantamento
				cCarteira := "R"
			Else
				cCarteira := "P"
			Endif

			dbSelectArea("NEWSE5")
			cAnterior 	:= &cCond2
			cBancoAnt	:= NEWSE5->E5_BANCO
			cAgAnt		:= NEWSE5->E5_AGENCIA
			cContaAnt	:= NEWSE5->E5_CONTA

			nTotValor	:= 0
			nTotDesc	:= 0
			nTotJurMul  := 0
			nTotCM		:= 0
			nCT			:= 0
			nTotOrig	:= 0
			nTotBaixado	:= 0
			nTotAbLiq  	:= 0
			nTotImp		:= 0
			nTotMovFin	:= 0
			nTotComp	:= 0
			nTotFat	    := 0
			nTotIRRF    := 0
			nTotPIS     := 0
			nTotCSSL    := 0
			nTotCOFI    := 0

			While NEWSE5->(!EOF()) .and. &cCond2=cAnterior .and. NEWSE5->E5_FILIAL=xFilial("SE5") .and. lContinua

				lManual := .f.
				dbSelectArea("NEWSE5")

				IF lEnd
					@PROW()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")
					lContinua:=.F.
					Exit
				EndIF

				If (Empty(NEWSE5->E5_TIPODOC) .And. mv_par16 == 1) .Or.;
					(Empty(NEWSE5->E5_NUMERO)  .And. mv_par16 == 1)
					lManual := .t.
				EndIf

				// Testa condicoes de filtro
				If !Fr190TstCond(cFilSe5,.T.)
					dbSelectArea("NEWSE5")
					NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
					Loop
				Endif

				// Imprime somente cheques
				If mv_par37 == 1 .And. NEWSE5->E5_TIPODOC == "BA"

					aAreaSE5 := SE5->(GetArea())
					lAchou := .F.

					SE5->(dbSetOrder(11))
					cChaveNSE5	:= NEWSE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)
					SE5->(MsSeek(xFilial("SE5")+cChaveNSE5))

					// Procura o cheque aglutinado, se encontrar, marca lAchou := .T. e despreza
					WHILE SE5->(!EOF()) .And. SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)	== cChaveNSE5
						If SE5->E5_TIPODOC == "CH"
							lAchou := .T.
							Exit
						Endif
						SE5->(dbSkip())
					Enddo
					RestArea(aAreaSE5)
					// Achou cheque aglutinado para a baixa, despreza o registro
					If lAchou
						NEWSE5->(dbSkip())
						Loop
					Endif

				ElseIf mv_par37 == 2 .And. NEWSE5->E5_TIPODOC == "CH" //somente baixas

					aAreaSE5 := SE5->(GetArea())
					lAchou := .F.

					SE5->(dbSetOrder(11))
					cChaveNSE5	:= NEWSE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)
					SE5->(MsSeek(xFilial("SE5")+cChaveNSE5))

					// Procura a baixa aglutinada, se encontrar despreza o movimento bancario
					WHILE SE5->(!EOF()) .And. SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)	== cChaveNSE5
						If SE5->E5_TIPODOC $ "BA"
							lAchou := .T.
							Exit
						Endif
						SE5->(dbSkip())
					Enddo
					RestArea(aAreaSE5)
					// Achou cheque aglutinado para a baixa, despreza o registro
					If lAchou
						NEWSE5->(dbSkip())
						Loop
					Endif
				Endif

				cNumero    	:= NEWSE5->E5_NUMERO
				cPrefixo   	:= NEWSE5->E5_PREFIXO
				cParcela   	:= NEWSE5->E5_PARCELA
				dBaixa     	:= NEWSE5->E5_DATA
				cBanco     	:= NEWSE5->E5_BANCO
				cNatureza  	:= NEWSE5->E5_NATUREZ
				cCliFor    	:= NEWSE5->E5_BENEF
				cLoja      	:= NEWSE5->E5_LOJA
				cSeq       	:= NEWSE5->E5_SEQ
				cNumCheq   	:= NEWSE5->E5_NUMCHEQ
				cRecPag 	:= NEWSE5->E5_RECPAG
				cTipodoc   	:= NEWSE5->E5_TIPODOC
				cMotBaixa	:= NEWSE5->E5_MOTBX
				cCheque    	:= NEWSE5->E5_NUMCHEQ
				cTipo      	:= NEWSE5->E5_TIPO
				cFornece   	:= NEWSE5->E5_CLIFOR
				cLoja      	:= NEWSE5->E5_LOJA
				dDigit     	:= NEWSE5->E5_DTDIGIT
				lBxTit	  	:= .F.
				cFilorig    := NEWSE5->E5_FILORIG

				If (NEWSE5->E5_RECPAG == "R" .and. ! (NEWSE5->E5_TIPO $ "PA /"+MV_CPNEG )) .or. ;	//Titulo normal
					(NEWSE5->E5_RECPAG == "P" .and.   (NEWSE5->E5_TIPO $ "RA /"+MV_CRNEG )) 	//Adiantamento
					dbSelectArea("SE1")
					dbSetOrder(1)
					lBxTit := MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo)
					If !lBxTit
						lBxTit := dbSeek(NEWSE5->E5_FILORIG+cPrefixo+cNumero+cParcela+cTipo)
					Endif
					cCarteira := "R"
					dDtMovFin := IIF (lManual,CTOD("//"), DataValida(SE1->E1_VENCTO,.T.))
					While SE1->(!Eof()) .and. SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO==cPrefixo+cNumero+cParcela+cTipo
						If SE1->E1_CLIENTE == cFornece .And. SE1->E1_LOJA == cLoja	// Cliente igual, Ok
							Exit
						Endif
						SE1->( dbSkip() )
					EndDo
					If !SE1->(EOF()) .And. mv_par11 == 1 .and. !lManual .and.  ;
						(NEWSE5->E5_RECPAG == "R" .and. !(NEWSE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG))
						If SE5->(FieldPos("E5_SITCOB")) > 0
							cExp := "NEWSE5->E5_SITCOB"
						Else
							cExp := "SE1->E1_SITUACA"
						Endif

						If mv_par36 == 2 // Nao imprime titulos em carteira
							// Retira da comparacao as situacoes branco, 0, F e G
							mv_par15 := AllTrim(mv_par15)
							mv_par15 := StrTran(mv_par15,"0","")
							mv_par15 := StrTran(mv_par15,"F","")
							mv_par15 := StrTran(mv_par15,"G","")
						Else
							If (NEWSE5->E5_RECPAG == "R") .And. lAjuPar15
								mv_par15  += " "
							Endif
						EndIf

						cExp += " $ mv_par15"
						If !(&cExp)
							dbSelectArea("NEWSE5")
							NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
							Loop
						Endif
					Endif
					cCond3:="E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_SEQ+E5_NUMCHEQ==cPrefixo+cNumero+cParcela+cTipo+DtoS(dBaixa)+cSeq+cNumCheq"
					nDesc := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
					nIRRF := nPIS := nValor := nCOFINS := nCSLL := nCM := nVlMovFin := 0
					nISS  := nINSS := 0
				Else
					dbSelectArea("SE2")
					DbSetOrder(1)
					cCarteira := "P"
				    lBxTit := MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)

				    Iif(lBxTit, nRecSE2	:= SE2->(Recno()), nRecSE2 := 0 )

					If !lBxTit
						lBxTit := dbSeek(NEWSE5->E5_FILORIG+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)
					Endif
					dDtMovFin := IIF(lManual,CTOD("//"),DataValida(SE2->E2_VENCTO,.T.))
					cCond3:="E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+DtoS(E5_DATA)+E5_SEQ+E5_NUMCHEQ==cPrefixo+cNumero+cParcela+cTipo+cFornece+DtoS(dBaixa)+cSeq+cNumCheq"
					nDesc := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
					nIRRF := nPIS := nValor := nCOFINS := nCSLL := nCM := nVlMovFin := 0
					nISS  := nINSS := 0
					cCheque    := Iif(Empty(NEWSE5->E5_NUMCHEQ),SE2->E2_NUMBCO,NEWSE5->E5_NUMCHEQ)
				Endif
				dbSelectArea("NEWSE5")
				IncRegua()
				cHistorico := Space(40)
				While NEWSE5->( !Eof()) .and. &cCond3 .and. lContinua .And. NEWSE5->E5_FILIAL==xFilial("SE5")

					IncRegua()
					dbSelectArea("NEWSE5")
					cTipodoc   := NEWSE5->E5_TIPODOC
					cCheque    := NEWSE5->E5_NUMCHEQ

					lAchouEmp := .T.
					lAchouEst := .F.

					IF lEnd
						@PROW()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")
						lContinua:=.F.
						Exit
					EndIF

					// Testa condicoes de filtro
					If !Fr190TstCond(cFilSe5,.T.)
						dbSelectArea("NEWSE5")
						NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
						Loop
					Endif

					If NEWSE5->E5_SITUACA $ "C/E/X"
						dbSelectArea("NEWSE5")
						NEWSE5->( dbSkip() )
						Loop
					EndIF

					If NEWSE5->E5_LOJA != cLoja
						Exit
					Endif

					If NEWSE5->E5_FILORIG < mv_par33 .or. NEWSE5->E5_FILORIG > mv_par34
						dbSelectArea("NEWSE5")
						NEWSE5->( dbSkip() )
						Loop
					Endif

					//���������������������������������������������������Ŀ
					//� Nao imprime os registros de emprestimos excluidos �
					//�����������������������������������������������������
					If NEWSE5->E5_TIPODOC == "EP"
						aAreaSE5 := NEWSE5->(GetArea())
						dbSelectArea("SEH")
						dbSetOrder(1)
						lAchouEmp := MsSeek(xFilial("SEH")+Substr(NEWSE5->E5_DOCUMEN,1,nTamEH))
						RestArea(aAreaSE5)
						If !lAchouEmp
							NEWSE5->(dbSkip())
							Loop
						EndIf
					EndIf

					//�����������������������������������������������������������������Ŀ
					//� Nao imprime os registros de pagamento de emprestimos estornados �
					//�������������������������������������������������������������������
					If NEWSE5->E5_TIPODOC == "PE"
						aAreaSE5 := NEWSE5->(GetArea())
						dbSelectArea("SEI")
						dbSetOrder(1)
						If	MsSeek(xFilial("SEI")+"EMP"+Substr(NEWSE5->E5_DOCUMEN,1,nTamEI))
							If SEI->EI_STATUS == "C"
								lAchouEst := .T.
							EndIf
						EndIf
						RestArea(aAreaSE5)
						If lAchouEst
							NEWSE5->(dbSkip())
							Loop
						EndIf
					EndIf

					//�����������������������������Ŀ
					//� Verifica o vencto do Titulo �
					//�������������������������������
					cFilTrb := If(mv_par11==1,"SE1","SE2")
					If (cFilTrb)->(!Eof()) .And.;
						((cFilTrb)->&(Right(cFilTrb,2)+"_VENCREA") < mv_par31 .Or. (!Empty(mv_par32) .And. (cFilTrb)->&(Right(cFilTrb,2)+"_VENCREA") > mv_par32))
						dbSelectArea("NEWSE5")
						NEWSE5->(dbSkip())
						Loop
					Endif

					dBaixa     	:= NEWSE5->E5_DATA
					cBanco     	:= NEWSE5->E5_BANCO
					cNatureza  	:= NEWSE5->E5_NATUREZ
					cCliFor    	:= NEWSE5->E5_BENEF
					cSeq       	:= NEWSE5->E5_SEQ
					cNumCheq   	:= NEWSE5->E5_NUMCHEQ
					cRecPag		:= NEWSE5->E5_RECPAG
					cMotBaixa	:= NEWSE5->E5_MOTBX
					cTipo190	:= NEWSE5->E5_TIPO
					cFilorig    := NEWSE5->E5_FILORIG
					//��������������������������������������������������������������Ŀ
					//� Obter moeda da conta no Banco.                               �
					//����������������������������������������������������������������
					If ( cPaisLoc # "BRA".And.!Empty(NEWSE5->E5_BANCO+NEWSE5->E5_AGENCIA+NEWSE5->E5_CONTA) ) .OR. ( FindFunction( "FXMultSld" ) .AND. FXMultSld() )
						SA6->(DbSetOrder(1))
						SA6->(MsSeek(xFilial()+NEWSE5->E5_BANCO+NEWSE5->E5_AGENCIA+NEWSE5->E5_CONTA))
						nMoedaBco	:=	Max(SA6->A6_MOEDA,1)
					Else
						nMoedaBco	:=	1
					Endif

					If !Empty(NEWSE5->E5_NUMERO)
						If (NEWSE5->E5_RECPAG == "R" .and. !(NEWSE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG)) .or. ;
							(NEWSE5->E5_RECPAG == "P" .and. NEWSE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG) .Or.;
							(NEWSE5->E5_RECPAG == "P" .And. NEWSE5->E5_TIPODOC $ "DB#OD")
							dbSelectArea( "SA1")
							dbSetOrder(1)
							lAchou := .F.
							If Empty(xFilial("SA1"))  //SA1 Compartilhado
								If dbSeek(xFilial("SA1")+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									lAchou := .T.
								Endif
							Else
								cFilOrig := NEWSE5->E5_FILIAL //Procuro SA1 pela filial do movimento
								If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
										lAchou := .T.
									Else
										cFilOrig := NEWSE5->E5_FILORIG //Procuro SA1 pela filial origem
										If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
											If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
												lAchou := .T.
											Endif
										Endif
									Endif
								Else
									cFilOrig := NEWSE5->E5_FILORIG	//Procuro SA1 pela filial origem
									If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
										If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
											lAchou := .T.
										Endif
									Endif
								Endif
							EndIF
							If lAchou
								cCliFor := Iif(mv_par30==1,SA1->A1_NREDUZ,SA1->A1_NOME)
							Endif
						Else
							dbSelectArea( "SA2")
							dbSetOrder(1)
							lAchou := .F.
							If Empty(xFilial("SA2"))  //SA2 Compartilhado
								If dbSeek(xFilial("SA2")+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									lAchou := .T.
								Endif
							Else
								cFilOrig := NEWSE5->E5_FILIAL //Procuro SA2 pela filial do movimento
								If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
										lAchou := .T.
									Else
										cFilOrig := NEWSE5->E5_FILORIG //Procuro SA2 pela filial origem
										If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
											If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
												lAchou := .T.
											Endif
										Endif
									Endif
								Else
									cFilOrig := NEWSE5->E5_FILORIG	//Procuro SA2 pela filial origem
									If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
										If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
											lAchou := .T.
										Endif
									Endif
								Endif
							EndIF
							If lAchou
								cCliFor := Iif(mv_par30==1,SA2->A2_NREDUZ,SA2->A2_NOME)
							Endif
						EndIf
					EndIf
					dbSelectArea("SM2")
					dbSetOrder(1)
					dbSeek(NEWSE5->E5_DATA)
					dbSelectArea("NEWSE5")
					nTaxa:= 0
					If cPaisLoc=="BRA"
						If !Empty(NEWSE5->E5_TXMOEDA)
							nTaxa:=NEWSE5->E5_TXMOEDA
						Else
							If nMoedaBco == 1
								nTaxa := NEWSE5->E5_VALOR / NEWSE5->E5_VLMOED2
							Else
								nTaxa := NEWSE5->E5_VLMOED2 / NEWSE5->E5_VALOR
							Endif
						EndIf
					EndIf
					nRecSe5:=If(lAsTop,NEWSE5->SE5RECNO,Recno())
					nDesc+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VLDESCO,Round(xMoeda(NEWSE5->E5_VLDESCO,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))
					nJuros+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VLJUROS,Round(xMoeda(NEWSE5->E5_VLJUROS,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))
					nMulta+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VLMULTA,Round(xMoeda(NEWSE5->E5_VLMULTA,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))
					nJurMul+= nJuros + nMulta
					nCM+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VLCORRE,Round(xMoeda(NEWSE5->E5_VLCORRE,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))

					If cCarteira == "R" .and. mv_par12 == SE1->E1_MOEDA
					   nCM := 0

					ElseIf cCarteira == "P" .and. mv_par12 == SE2->E2_MOEDA
					   nCM := 0

					Endif

					If lPccBaixa .and. Empty(NEWSE5->E5_PRETPIS) .And. Empty(NEWSE5->E5_PRETCOF) .And. Empty(NEWSE5->E5_PRETCSL)
						If nRecSE2 > 0

							aAreabk  := Getarea()
							aAreaSE2 := SE2->(Getarea())
							SE2->(DbGoto(nRecSE2))

							nTotAbImp+=(NEWSE5->E5_VRETPIS)+(NEWSE5->E5_VRETCOF)+(NEWSE5->E5_VRETCSL)+;
										SE2->E2_INSS+ SE2->E2_ISS+ SE2->E2_IRRF

							Restarea(aAreaSE2)
							Restarea(aAreabk)
						Else
							nTotAbImp+=(NEWSE5->E5_VRETPIS)+(NEWSE5->E5_VRETCOF)+(NEWSE5->E5_VRETCSL)
							//nPIS    += (NEWSE5->E5_VRETPIS)
							//nCOFINS += (NEWSE5->E5_VRETCOF)
							//nCSLL   += (NEWSE5->E5_VRETCSL)
						Endif
					Endif
					If NEWSE5->E5_TIPODOC $ "VL/V2/BA/RA/PA/CP"
						cHistorico := NEWSE5->E5_HISTOR
						nValor+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VALOR,Round(xMoeda(NEWSE5->E5_VALOR,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))

						//Pcc Baixa CR
						If cCarteira == "R" .and. lPccBxCr .and. cPaisLoc == "BRA"
							If Empty(NEWSE5->E5_PRETPIS)
								nPccBxCr += Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VRETPIS,Round(xMoeda(NEWSE5->E5_VRETPIS,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,,NEWSE5->E5_TXMOEDA),nDecs+1))
							Endif
							If Empty(NEWSE5->E5_PRETCOF)
								nPccBxCr += Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VRETCOF,Round(xMoeda(NEWSE5->E5_VRETCOF,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,,NEWSE5->E5_TXMOEDA),nDecs+1))
							Endif
							If Empty(NEWSE5->E5_PRETCSL)
								nPccBxCr += Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VRETCSL,Round(xMoeda(NEWSE5->E5_VRETCSL,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,,NEWSE5->E5_TXMOEDA),nDecs+1))
							Endif
						Endif

					Else
						nVlMovFin+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VALOR,Round(xMoeda(NEWSE5->E5_VALOR,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))
						cHistorico := Iif(Empty(NEWSE5->E5_HISTOR),"MOV FIN MANUAL",NEWSE5->E5_HISTOR)
						cNatureza  	:= NEWSE5->E5_NATUREZ
					Endif
					dbSkip()
					If lManual		// forca a saida do looping se for mov manual
						Exit
					Endif
				EndDO

				If (nDesc+nValor+nJurMul+nCM+nVlMovFin) > 0
					//������������������������������Ŀ
					//� C�lculo do Abatimento        �
					//��������������������������������
					If cCarteira == "R" .and. !lManual
						dbSelectArea("SE1")
						nRecno := Recno()
						nAbat := 0
						nAbatLiq := 0
						If !SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG

							//nIRRF += SE1->E1_IRRF

							//�����������������������������������������������������������������������Ŀ
							//� Encontra a ultima sequencia de baixa na SE5 a partir do t�tulo da SE1 �
							//�������������������������������������������������������������������������
							aAreaSE1 := SE1->(GetArea())
							dbSelectArea("SE5")
							dbSetOrder(7)
							cChaveSE1 := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
							SE5->(MsSeek(xFilial("SE5")+cChaveSE1))

							cSeqSE5 := SE5->E5_SEQ

							While SE5->(!EOF()) .And. cChaveSE1 == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
								If SE5->E5_SEQ > cSeqSE5
									cSeqSE5 := SE5->E5_SEQ
								Endif
								SE5->(dbSkip())
							Enddo

							SE5->(MsSeek(xFilial("SE5")+cChaveSE1+cSeqSE5))
							cChaveSE5 := cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja+cSeq

							If cChaveSE5 == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) .And.;
								Empty(SE1->E1_SALDO)
								If SE1->E1_VALOR <> SE1->E1_VALLIQ
									lUltBaixa := .T.
								EndIf
							EndIf

							RestArea(aAreaSE1)

							//��������������������������������������������������������������������Ŀ
							//� Calcula o valor total de abatimento do titulo e impostos se houver �
							//����������������������������������������������������������������������
							nTotAbImp := 0

							If lUltBaixa
								nAbat := SumAbatRec(cPrefixo,cNumero,cParcela,SE1->E1_MOEDA,"V",dBaixa,@nTotAbImp,@nIRRF,@nCSLL,@nPIS,@nCOFINS,@nINSS)
								nAbatLiq := nAbat - nTotAbImp
							EndIf

							lUltBaixa := .F.
						EndIf
						dbSelectArea("SE1")
						dbGoTo(nRecno)
						cCliFor190 := SE1->E1_CLIENTE+SE1->E1_LOJA

						SA1->(DBSetOrder(1))
						If SA1->(DBSeek(xFilial("SA1")+cCliFor190) )
							lCalcIRF := SA1->A1_RECIRRF == "1" .and. SA1->A1_IRBAX == "1" // se for na baixa
						Else
							lCalcIRF := .F.
						EndIf
						If lCalcIRF
							nTotAbImp += SE1->E1_IRRF
						EndIf
					Elseif !lManual
						dbSelectArea("SE2")
						nRecno := Recno()
						nAbat := 0
						nAbatLiq := 0
						If !SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
							nAbat :=	SomaAbat(cPrefixo,cNumero,cParcela,"P",mv_par12,,cFornece,cLoja)
							nAbatLiq := nAbat
						EndIf
						dbSelectArea("SE2")
						dbGoTo(nRecno)
					EndIF

					If li > 58
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
					EndIF

					IF mv_par11 == 1 .and. aTam[1] > 6 .and. !lManual
						If lBxTit
							@li, aColu[05] PSAY SE1->E1_CLIENTE
						Endif
						@li, aColu[06] PSAY SubStr(cCliFor,1,18)
						li++
					Elseif mv_par11 == 2 .and. aTam[1] > 6 .and. !lManual
						If lBxTit
							@li, aColu[05] PSAY SE2->E2_FORNECE
						Endif
						@li, aColu[06] PSAY SubStr(cCliFor,1,18)
						li++
					Endif

					@li, aColu[01] PSAY cPrefixo
					@li, aColu[02] PSAY cNumero

					If cPaisLoc	$ "MEX|PTG"
					   li++
					Endif

					@li, aColu[03] PSAY cParcela
					@li, aColu[04] PSAY cTipo

					If !lManual
						dbSelectArea("TRB")
						lOriginal := .T.
						//������������������������������Ŀ
						//� Baixas a Receber             �
						//��������������������������������
						If cCarteira == "R"
							cCliFor190 := SE1->E1_CLIENTE+SE1->E1_LOJA
							nVlr:= SE1->E1_VLCRUZ
							If mv_par12 > 1
								nVlr := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par12,SE1->E1_BAIXA,nDecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),nDecs+1)
							EndIF
							//������������������������������Ŀ
							//� Baixa de PA                  �
							//��������������������������������
						Else
							cCliFor190 := SE2->E2_FORNECE+SE2->E2_LOJA
							nVlr:= SE2->E2_VLCRUZ
							lCalcIRF:= Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CALCIRF") == "1" .Or.;//1-Normal, 2-Baixa
								           Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CALCIRF") == " "

							// MV_MRETISS "1" retencao do ISS na Emissao, "2" retencao na Baixa.
					   		nVlr:= SE2->E2_VLCRUZ

							If lConsImp   //default soma os impostos no valor original
								nVlr += SE2->E2_INSS+ Iif(GetNewPar('MV_MRETISS',"1")=="1",SE2->E2_ISS,0) +;
									   	Iif(lCalcIRF,SE2->E2_IRRF,0)
								If ! lPccBaixa  // SE PCC NA EMISSAO SOMA PCC
									nVlr += SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL
								EndIf
							EndIf

							If mv_par12 > 1
								nVlr := Round(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par12,SE2->E2_BAIXA,nDecs+1,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0)),nDecs+1)
							Endif
						Endif
						cFilTrb := If(cCarteira=="R","SE1","SE2")
						IF DbSeek( xFilial(cFilTrb)+cPrefixo+cNumero+cParcela+cCliFor190+cTipo)
							nAbat:=0
							lOriginal := .F.
						Else
							nVlr:=NoRound(nVlr)
							RecLock("TRB",.T.)
							Replace linha With xFilial(cFilTrb)+cPrefixo+cNumero+cParcela+cCliFor190+cTipo
							MsUnlock()
						EndIF
					Else
						If lAsTop
							dbSelectArea("SE5")
						Else
							dbSelectArea("NEWSE5")
						Endif
						dbgoto(nRecSe5)
						nVlr := Round(xMoeda(E5_VALOR,nMoedaBco,mv_par12,E5_DATA,nDecs+1,,If(cPaisLoc=="BRA",E5_TXMOEDA,0)),nDecs+1)
						nAbat:= 0
						lOriginal := .t.
						If lAsTop
							nRecSe5:=NEWSE5->SE5RECNO
						Else
							nRecSe5:=Recno()
							NEWSE5->( dbSkip() )
						Endif
						dbSelectArea("TRB")
					Endif
					IF cCarteira == "R"
						If ( !lManual )
							If mv_par13 == 1  // Utilizar o Hist�rico da Baixa ou Emiss�o
								cHistorico := Iif(Empty(cHistorico), SE1->E1_HIST, cHistorico )
							Else
								cHistorico := Iif(Empty(SE1->E1_HIST), cHistorico, SE1->E1_HIST )
							Endif
						EndIf
						If aTam[1] <= 6 .and. !lManual
							If lBxTit
								@li, aColu[05] PSAY SE1->E1_CLIENTE+"-"+SE1->E1_LOJA
							Endif
							@li, aColu[06] PSAY SubStr(cCliFor,1,20)
						Endif
						@li,aColu[07] PSAY cNatureza
						If Empty( dDtMovFin ) .or. dDtMovFin == Nil
							dDtMovFin := CtoD("  /  /  ")
						Endif
						@li, aColu[08] PSAY IIf(lManual,dDtMovFin,DataValida(SE1->E1_VENCTO,.T.))
						@li, aColu[09] PSAY SubStr( cHistorico ,1,23)
						@li, aColu[10] PSAY dBaixa
						IF nVlr > 0
							@li,aColu[11] PSAY nVlr  Picture tm(nVlr,14,nDecs)
						Endif
					Else
						If mv_par13 == 1  // Utilizar o Hist�rico da Baixa ou Emiss�o
							cHistorico := Iif(Empty(cHistorico), SE2->E2_HIST, cHistorico )
						Else
							cHistorico := Iif(Empty(SE2->E2_HIST), cHistorico, SE2->E2_HIST )
						Endif
						If aTam[1] <= 6 .and. !lManual
							If lBxTit
								@li, aColu[05] PSAY SE2->E2_FORNECE
							Endif
							@li, aColu[06] PSAY SubStr(cCliFor,1,20)
						Endif
						@li, aColu[07] PSAY cNatureza
						If Empty( dDtMovFin ) .or. dDtMovFin == Nil
							dDtMovFin := CtoD("  /  /  ")
						Endif
						@li, aColu[08] PSAY IIf(lManual,dDtMovFin,DataValida(SE2->E2_VENCTO,.T.))
						If !Empty(cCheque)
							@li, aColu[09] PSAY SubStr(ALLTRIM(cCheque)+"/"+Trim(cHistorico),1,18)
						Else
							@li, aColu[09] PSAY SubStr(cHistorico,1,21)
						EndIf
						@li, aColu[10] PSAY dBaixa
						IF nVlr > 0
							@li,aColu[11] PSAY nVlr Picture tm(nVlr,14,nDecs)
						Endif
					Endif
					nCT++

					//PCC Baixa CR
					//Somo aos abatimentos de impostos, os impostos PCC na baixa.
					//Caso o calculo do PCC CR seja pela emissao, esta variavel estara zerada
					nTotAbImp := nTotAbImp + nPccBxCr

					@li,aColu[12] PSAY nTotAbImp 	Picture tm(nTotAbImp,11,nDecs)
					@li,aColu[13] PSAY nIRRF      	PicTure tm(nIRRF ,11,nDecs)
					@li,aColu[14] PSAY nPIS       	PicTure tm(nPIS,11,nDecs)
					@li,aColu[15] PSAY nCOFINS 		Picture tm(nCOFINS,11,nDecs)
					@li,aColu[16] PSAY nCSLL 	    Picture tm(nCSLL,11,nDecs)
					If nVlMovFin > 0
						@li,aColu[17] PSAY nVlMovFin     PicTure tm(nVlMovFin,14,nDecs)
					Else
						@li,aColu[17] PSAY nValor		 PicTure tm(nValor,14,nDecs)
					Endif
					@li, aColu[18] PSAY cBanco
					If Len(DtoC(dDigit)) <= 8
						@li,aColu[19] PSAY dDigit
					Else
						@li,aColu[19] PSAY dDigit
					EndIf

					If empty(cMotBaixa)
						cMotBaixa := "NOR"  //NORMAL
					Endif

					@li,aColu[20] PSAY Substr(cMotBaixa,1,3)
					@li,aColu[21] PSAY cFilorig

					nTotOrig   += Iif(lOriginal,nVlr,0)
					nTotBaixado+= If(cTipodoc $ "CP/BA" .AND. cMotBaixa $ "CMP/FAT",0,nValor)		// n�o soma, j� somou no principal
					nTotImp    += nTotAbImp
					nTotIRRF   += nIRRF
					nTotPIS    += nPIS
					nTotCOFI   += nCOFINS
					nTotCSLL   += nCSLL
					nTotISS    += nISS
					nTotINSS   += nINSS
					//nTotValor  += IIF( nVlMovFin <> 0, nVlMovFin , Iif(MovBcoBx(cMotBaixa),nValor,0))
					nTotValor  += IIF( lBxLoja , nVlr, IIF(nVlMovFin <> 0, nVlMovFin , Iif(MovBcoBx(cMotBaixa),IIF(lBxLoja,nVlr,nValor),0)))
					nTotMovFin += nVlMovFin
					//nTotComp   += Iif(cTipodoc == "CP",nValor,0)
					nTotComp   += Iif(cTipodoc == "CP",IIF(lBxLoja,nVlr,nValor),0)
					//nTotFat	   += Iif(cMotBaixa $ "FAT",nValor, 0)
					nTotFat	   += Iif(cMotBaixa $ "FAT",IIF(lBxLoja,nVlr,nValor), 0)
					nDesc := nJurMul := nValor := nCM := nAbat := nTotAbImp := nAbatLiq := nVlMovFin := 0
					nIRRF := nPIS := nValor := nCOFINS := nCSLL := nTotAbImp := nAbatLiq := nVlMovFin := 0
					nISS  := nINSS := 0
					nPccBxCr	 := 0			//PCC Baixa
					li++
				Endif
				dbSelectArea("NEWSE5")
			Enddo

			If (nTotValor+nIRRF+nPIS+nCOFINS+nTotOrig+nTotMovFin+nTotComp)>0
				li++
				IF li > 58
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				Endif
				If nCT > 0
					IF nOrdem == 1 .or. nOrdem == 6 .or. nOrdem == 8
						@li, 0 PSAY "Sub Total : " + DTOC(cAnterior)
					Elseif nOrdem == 2 .or. nOrdem == 4 .or. nOrdem == 7
						cLinha := "Sub Total : "+cAnterior+" "
						If nOrdem == 4
							If (mv_par11 == 1 .and. (cRecpag == "R" .and. !(cTipo190 $ MVPAGANT+"/"+MV_CPNEG))) .or. ;
								(cRecpag == "P" .and. cTipo190 $ MVRECANT+"/"+MV_CRNEG) .Or.;
								(cRecPag == "P" .And. cTipoDoc $ "DB#OD")

								dbSelectArea("SA1")
								DbSetOrder(1)
								If !Empty(cAnterior)
									MsSeek(cFilial+cFornece+cLoja)
									cLinha+=" "+A1_CGC
								Else
									cLinha+= OemToAnsi("Moviment. Financeiras Manuais ")
								Endif
							ElseIF (mv_par11 == 2 .and. (cRecpag == "P" .and. !(cTipo190 $ MVRECANT+"/"+MV_CRNEG))) .or.;
									(cRecpag == "R" .and. cTipo190 $ MVPAGANT+"/"+MV_CPNEG)
								dbSelectArea("SA2")
								DbSetOrder(1)
								If !Empty(cAnterior)
									MsSeek(cFilial+cFornece+cLoja)
									cLinha+=TRIM(A2_NOME)+"  "+A2_CGC
								Else
									cLinha+= OemToAnsi("Moviment. Financeiras Manuais ")
								Endif
							Endif
						Elseif nOrdem == 2
							dbSelectArea("SA6")
							DbSetOrder(1)
							MsSeek(xFilial("SA6")+cBancoAnt+cAgAnt+cContaAnt)
							cLinha+=TRIM(A6_NOME)
						Endif
						@li,0 PSAY cLinha
					Elseif nOrdem == 3
						dbSelectArea("SED")
						DbSetOrder(1)
						MsSeek(cFilial+cAnterior)
						@li, 0 PSAY "SubTotal : " + cAnterior + " "+ED_DESCRIC
					Endif
					If nOrdem != 5
						@li,aColu[11] PSAY nTotOrig     PicTure tm(nTotOrig,14,nDecs)
						@li,aColu[12] PSAY nTotImp      Picture tm(nTotImp,11,nDecs)
						@li,aColu[13] PSAY nTotIRRF     PicTure tm(nTotIRRF,11,nDecs)
  						@li,aColu[14] PSAY nTotPIS      PicTure tm(nTotPIS ,11,nDecs)
						@li,aColu[15] PSAY nTotCOFI     PicTure tm(nTotCOFI,11,nDecs)
						@li,aColu[16] PSAY nTotCSLL     Picture tm(nTotCSLL,11,nDecs)
						@li,aColu[17] PSAY nTotValor    PicTure tm(nTotValor,14,nDecs)
						If nTotBaixado > 0
							@li,197 PSAY "Baixados"
							@li,206 PSAY nTotBaixado  PicTure tm(nTotBaixado,14,nDecs)
						Endif
						If nTotMovFin > 0
							li++
							@li,197 PSAY "Mov Fin."
							@li,206 PSAY nTotMovFin   PicTure tm(nTotMovFin,14,nDecs)
						Endif
						If nTotComp > 0
							li++
							@li,197 PSAY "Compens."
							@li,206 PSAY nTotComp     PicTure tm(nTotComp,14,nDecs)
						Endif
						If nTotFat > 0
							li++
							@li,197 PSAY "Bx.Fatura"
							@li,206 PSAY nTotFat     PicTure tm(nTotFat,14,nDecs)
						Endif
						li+=2
					Endif
					dbSelectArea("NEWSE5")
				Endif
			Endif

			//�������������������������Ŀ
			//�Incrementa Totais Gerais �
			//���������������������������
			nGerOrig	+= nTotOrig
			nGerValor	+= nTotValor
			nGerIRRF	+= nTotIRRF
			nGerPIS	    += nTotPIS
			nGerCOFI	+= nTotCOFI
			nGerCSLL	+= nTotCSLL
			nGerAbImp	+= nTotImp
			nGerBaixado += nTotBaixado
			nGerMovFin	+= nTotMovFin
			nGerComp	+= nTotComp
			nGerFat     += nTotFat
			//�������������������������Ŀ
			//�Incrementa Totais Filial �
			//���������������������������
			nFilOrig	+= nTotOrig
			nFilValor	+= nTotValor
			nFilIRRF	+= nTotIRRF
			nFilPIS		+= nTotPIS
			nFilCOFI	+= nTotCOFI
			nFilCSLL	+= nTotCSLL
			nFilAbImp	+= nTotImp
			nFilBaixado += nTotBaixado
			nFilMovFin	+= nTotMovFin
			nFilComp	+= nTotComp
			nFilFat	    += nTotFat
		Enddo
	Endif
	//����������������������������������������Ŀ
	//� Imprimir TOTAL por filial somente quan-�
	//� do houver mais do que 1 filial.        �
	//������������������������������������������
	if mv_par17 == 1 .and. SM0->(Reccount()) > 1 .And. li != 80
		@li,  0 PSAY "FILIAL : " +  cFilAnt + " - " + cFilNome
		@li,aColu[11] PSAY nFilOrig       PicTure tm(nFilOrig,14,nDecs)
		@li,aColu[12] PSAY nFilAbImp      PicTure tm(nFilAbImp,11,nDecs)
		@li,aColu[13] PSAY nFilIRRF       PicTure tm(nFilIRRF,11,nDecs)
		@li,aColu[14] PSAY nFilPIS        PicTure tm(nFilPIS ,11,nDecs)
		@li,aColu[15] PSAY nFilCOFI       PicTure tm(nFilCOFI,11,nDecs)
		@li,aColu[16] PSAY nFilCSLL       PicTure tm(nFilCSLL,11,nDecs)
		@li,aColu[17] PSAY nFilValor      PicTure tm(nFilValor,14,nDecs)
		If nFilBaixado > 0
			@li,197 PSAY "Baixados"
			@li,206 PSAY nFilBaixado    PicTure tm(nFilBaixado,14,nDecs)
		Endif
		If nFilMovFin > 0
			li++
			@li,197 PSAY "Mov Fin."
			@li,206 PSAY nFilMovFin   PicTure tm(nFilMovFin,14,nDecs)
		Endif
		If nFilComp > 0
			li++
			@li,197 PSAY "Compens."
			@li,206 PSAY nFilComp     PicTure tm(nFilComp,14,nDecs)
		Endif
		If nFilFat > 0
			li++
			@li,197 PSAY "Bx.Fatura"
			@li,206 PSAY nFilFat     PicTure tm(nFilFat,14,nDecs)
		Endif
		li+=2
		If Empty(xFilial("SE5"))
			Exit
		Endif

		nFilOrig:=nFilIRRF:=nFilCOFI:=nFilPIS:=nFilCSLL:=nFilAbImp:=nFilValor:=0
		nFilBaixado:=nFilMovFin:=nFilComp:=nFilFat:=0
		nFilISS:=nFilINSS:=0
	Endif
	dbSelectArea("SM0")
	cCodUlt := SM0->M0_CODIGO
	cFilUlt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	dbSkip()
Enddo

If li != 80
	// Imprime o cabecalho, caso nao tenha espaco suficiente para impressao do total geral
	If (li+4)>=60
		SM0->(MsSeek(cCodUlt+cFilUlt))
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	li+=2
	@li,  0 PSAY OemToAnsi("Total Geral : ")
	@li,aColu[11] PSAY nGerOrig       PicTure tm(nGerOrig,14,nDecs)
	@li,aColu[12] PSAY nGerAbImp      PicTure tm(nGerAbImp,11,nDecs)
	@li,aColu[13] PSAY nGerIRRF       PicTure tm(nGerIRRF,11,nDecs)
	@li,aColu[14] PSAY nGerPIS        PicTure tm(nGerPIS ,11,nDecs)
	@li,aColu[15] PSAY nGerCOFI       PicTure tm(nGerCOFI,11,nDecs)
	@li,aColu[16] PSAY nGerCSLL       PicTure tm(nGerCSLL,11,nDecs)
	@li,aColu[17] PSAY nGerValor      PicTure tm(nGerValor,14,nDecs)
	If nGerBaixado > 0
		@li,197 PSAY OemToAnsi("Baixados")
		@li,206 PSAY nGerBaixado    PicTure tm(nGerBaixado,14,nDecs)
	Endif
	If nGerMovFin > 0
		li++
		@li,197 PSAY OemToAnsi("Mov Fin.")
		@li,206 PSAY nGerMovFin   PicTure tm(nGerMovFin,14,nDecs)
	Endif
	If nGerComp > 0
		li++
		@li,197 PSAY "Compens."
		@li,206 PSAY nGerComp     PicTure tm(nGerComp,14,nDecs)
	Endif
	If nGerFat > 0
		li++
		@li,197 PSAY "Bx.Fatura"
		@li,206 PSAY nGerFat     PicTure tm(nGerFat,14,nDecs)
	Endif
	li++
	roda(cbcont,cbtxt,"G")
Endif

SM0->(dbgoto(nRecEmp))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
dbSelectArea("TRB")
dbCloseArea()
Ferase(cNomArq1+GetDBExtension())
dbSelectArea("NEWSE5")
dbCloseArea()
If cNomeArq # Nil
	Ferase(cNomeArq+OrdBagExt())
Endif
dbSelectArea("SE5")
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer to
	dbCommit()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fr190TstCo� Autor � Claudio D. de Souza   � Data � 22.08.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Testa as condicoes do registro do SE5 para permitir a impr.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Fr190TstCon(cFilSe5)													  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cFilSe5 - Filtro em CodBase										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINR190																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Fr190TstCond(cFilSe5,lInterno)
Local lRet := .T.
Local nMoedaBco
Local lManual := .F.

If (Empty(NEWSE5->E5_TIPODOC) .And. mv_par16 == 1) .Or.;
	(Empty(NEWSE5->E5_NUMERO)  .And. mv_par16 == 1)
	lManual := .t.
EndIf

Do Case
Case !&(cFilSe5)           		// Verifico filtro CODEBASE tambem para TOP
	lRet := .F.
Case NEWSE5->E5_TIPODOC $ "DC/D2/JR/J2/TL/MT/M2/CM/C2"
	lRet := .F.
Case NEWSE5->E5_SITUACA $ "C/E/X" .or. NEWSE5->E5_TIPODOC $ "TR#TE" .or.;
	(NEWSE5->E5_TIPODOC == "CD" .and. NEWSE5->E5_VENCTO > NEWSE5->E5_DATA)
	lRet := .F.
Case NEWSE5->E5_TIPODOC == "E2" .and. mv_par11 == 2
	lRet := .F.
Case Empty(NEWSE5->E5_TIPODOC) .and. mv_par16 == 2
	lRet := .F.
Case Empty(NEWSE5->E5_NUMERO) .and. mv_par16 == 2
	lRet := .F.
Case mv_par16 == 2 .and. NEWSE5->E5_TIPODOC $ "CH"
	lRet := .F.
Case NEWSE5->E5_TIPODOC == "TR" .Or. NEWSE5->E5_MOTBX == "DSD"
	lRet := .F.
Case mv_par11 = 1 .And. E5_TIPODOC $ "E2#CB"
	lRet := .F.
//Case NEWSE5->E5_BANCO < mv_par03 .Or. NEWSE5->E5_BANCO > MV_PAR04
Case IIf(mv_par03 == mv_par04,NEWSE5->E5_BANCO != mv_par03 .And. !Empty(NEWSE5->E5_BANCO),NEWSE5->E5_BANCO < mv_par03 .Or. NEWSE5->E5_BANCO > MV_PAR04)
	lRet := .F.
	//���������������������������������������������������������������������Ŀ
	//�Se escolhido o par�metro "baixas normais", apenas imprime as baixas  �
	//�que gerarem movimenta��o banc�ria e as movimenta��es financeiras     �
	//�manuais, se consideradas.                                            �
	//�����������������������������������������������������������������������
Case mv_par14 == 1 .and. !MovBcoBx(NEWSE5->E5_MOTBX) .and. !lManual
	lRet := .F.
	//��������������������������������������������������������������Ŀ
	//� Considera filtro do usuario                                  �
	//����������������������������������������������������������������
Case !Empty(cFilterUser).and.!(&cFilterUser)
	lRet := .F.
	//������������������������������������������������������������������������Ŀ
	//� Verifica se existe estorno para esta baixa, somente no nivel de quebra �
	//� mais interno, para melhorar a performance 										�
	//��������������������������������������������������������������������������
Case	lInterno .And.;
		!Empty(NEWSE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)) .And.;
	  	TemBxCanc(NEWSE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
	lRet := .F.
EndCase

If lRet .And. NEWSE5->E5_RECPAG == "R"
	If ( NEWSE5->E5_TIPODOC = "RA" .And. mv_par35 = 2 ) .Or.;
		(NEWSE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG.and. mv_par24 == 2 .and.;
		NEWSE5->E5_MOTBX == "CMP")
		lRet := .F.
	EndIf
Endif
If lRet .And. NEWSE5->E5_RECPAG == "P"
	If ( NEWSE5->E5_TIPODOC = "PA" .And. mv_par35 = 2 ) .Or.;
		(NEWSE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG .and. mv_par24 == 2 .and.;
		 NEWSE5->E5_MOTBX == "CMP")
		lRet := .F.
	EndIf
Endif

If lRet .And. mv_par25 == 2
	If ( cPaisLoc # "BRA".And.!Empty(NEWSE5->E5_BANCO+NEWSE5->E5_AGENCIA+NEWSE5->E5_CONTA) ) .OR. ( FindFunction( "FXMultSld" ) .AND. FXMultSld() )
	   SA6->(DbSetOrder(1))
	   SA6->(MsSeek(xFilial()+NEWSE5->E5_BANCO+NEWSE5->E5_AGENCIA+NEWSE5->E5_CONTA))
	   nMoedaBco	:=	Max(SA6->A6_MOEDA,1)
	ElseIf !Empty(NEWSE5->E5_ORDREC)
		nMoedaBco:= Val(NEWSE5->E5_MOEDA)
	Else
	   nMoedaBco	:=	1
	Endif
	If nMoedaBco <> mv_par12
		lRet := .F.
	EndIf
EndIf

If lRet
	// Testar se considerar mov bancario e se o cancelamento da baixa tiver sido realizado, n�o imprimir o mov.
	If MV_PAR16 == 1
		If Fr190MovCan(17,"NEWSE5")
		   lRet := .F.
		Endif
	Endif
Endif

If lRet
	// Se for um recebimento de Titulo pago em dinheiro originado pelo SIGALOJA, nao imprime o mov.
	If NEWSE5->E5_TIPODOC == "BA" .and. NEWSE5->E5_MOTBX == "LOJ" .And. IsMoney(NEWSE5->E5_MOEDA)
		lRet := .F.
	EndIf
EndIf

If Empty(NEWSE5->E5_TIPO) .and. Empty(NEWSE5->E5_DOCUMEN)
	lRet := .F.
EndIf

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � FA190ImpR4 � Autor � Adrianne Furtado      � Data � 05.09.06 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o das baixas                                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe e � FA190ImpR4(nOrdem,aTotais)                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nOrdem    - Ordem que sera utilizada na emissao do relatorio ���
���          � aTotais   - Array que retorna o totalizador especifico de    ���
���          � 			   cada quebra de secao                             ���
���          � oReport   - objeto da classe TReport                         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function FA190ImpR4(nOrdem,aTotais,oReport,nGerOrig,lMultiNat)
Local oBaixas	:= oReport:Section(1)
Local cExp 			:= ""
Local CbTxt,CbCont
Local nValor:=0,nDesc:=0,nJuros:=0,nMulta:=0,nJurMul:=0,nCM:=0,dData,nVlMovFin:=0
Local nTotValor:=0,nTotDesc:=0,nTotJurMul:=0,nTotCm:=0,nTotOrig:=0,nTotBaixado:=0,nTotMovFin:=0,nTotComp:=0,nTotFat:=0
Local nGerValor:=0,nGerDesc:=0,nGerJurMul:=0,nGerCm:=0,nGerBaixado:=0,nGerMovFin:=0,nGerComp:=0,nGerFat:=0
Local nFilOrig:=0,nFilJurMul:=0,nFilCM:=0,nFilDesc:=0
Local nFilAbLiq:=0,nFilAbImp:=0,nFilValor:=0,nFilBaixado:=0,nFilMovFin:=0,nFilComp:=0,nFilFat:=0
Local nAbatLiq := 0,nTotAbImp := 0,nTotImp := 0,nTotAbLiq := 0,nGerAbLiq := 0,nGerAbImp := 0
Local cBanco,cNatureza,cAnterior,cCliFor,nCT:=0,dDigit,cLoja
Local lContinua		:=.T.
Local lBxTit		:=.F.
Local tamanho		:="G"
Local aCampos:= {},cNomArq1:="",nVlr,cLinha,lOriginal:=.T.
Local nAbat 		:= 0
Local cHistorico
Local lManual 		:= .f.
Local cTipodoc
Local nRecSe5 		:= 0
Local dDtMovFin
Local cRecPag
Local nRecEmp 		:= SM0->(Recno())
Local cMotBaixa		:= CRIAVAR("E5_MOTBX")
Local cFilNome 		:= Space(15)
Local cCliFor190	:= ""
Local aTam 			:= IIF(mv_par11 == 1,TamSX3("E1_CLIENTE"),TamSX3("E2_FORNECE"))
Local aColu 		:= {}
Local nDecs	   		:= GetMv("MV_CENT"+(IIF(mv_par12 > 1 , STR(mv_par12,1),"")))
Local nMoedaBco		:= 1
Local cCarteira
#IFDEF TOP
	Local aStru		:= SE5->(DbStruct()), nI
	Local cQuery
#ENDIF
Local cFilTrb
Local lAsTop		:= .F.
Local cFilSe5		:= ".T."
Local cChave, bFirst
Local cFilOrig
Local lAchou		:= .F.
Local lF190Qry		:= ExistBlock("F190QRY")
Local cQueryAdd		:= ""
Local lAjuPar15		:= Len(AllTrim(mv_par15))==Len(mv_par15)
Local lAchouEmp		:= .T.
Local lAchouEst		:= .F.
Local nTamEH		:= TamSx3("EH_NUMERO")[1]
Local nTamEI		:= TamSx3("EI_NUMERO")[1]+TamSx3("EI_REVISAO")[1]+TamSx3("EI_SEQ")[1]
Local cCodUlt		:= SM0->M0_CODIGO
Local cFilUlt		:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local nRecno
Local nSavOrd
Local aAreaSE5
Local cChaveNSE5	:= ""
Local nRecSE2		:= 0
Local aAreaSE2
Local aAreabk

Local aRet 			:= {}
Local cAuxFilNome
Local cAuxCliFor
Local cAuxLote
Local dAuxDtDispo
Local cFilUser	 	:= ""

Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
				 !Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
				 !Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
				 !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

Local nTaxa:= 0
Local lUltBaixa := .F.
Local cChaveSE1 := ""
Local cChaveSE5 := ""
Local cSeqSE5 := ""
Local lNaturez := .F.

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emiss�o(default))
Local lPccBxCr	:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)
Local nPccBxCr := 0
Local nIRRF    := 0
Local nTotIRRF := 0
Local nGerIRRF := 0
Local nFilIRRF := 0
Local nPIS     := 0
Local nTotPIS  := 0
Local nGerPIS  := 0
Local nFilPIS  := 0
Local nCOFINS  := 0
Local nTotCOFI := 0
Local nGerCOFI := 0
Local nFilCOFI := 0
Local nCSLL    := 0
Local nTotCSLL := 0
Local nGerCSLL := 0
Local nFilCSLL := 0
Local nISS     := 0
Local nTotISS  := 0
Local nGerISS  := 0
Local nFilISS  := 0
Local nINSS    := 0
Local nTotINSS := 0
Local nGerINSS := 0
Local nFilINSS := 0

//Controla o Pis Cofins e Csll na RA (1 = Controla reten��o de impostos no RA; ou 2 = N�o controla reten��o de impostos no RA(default))
Local lRaRtImp  := FRaRtImp()

Local cEmpresa		:= IIF(lUnidNeg,FWCodEmp(),"")
Local cAge, cContaBco
Local cMascNat := ""
Local lConsImp := .T.

/* GESTAO - inicio */
Local cTmpSE5Fil	:= ""
Local lNovaGestao	:= .F.
Local nSelFil		:= 0
Local nLenSelFil	:= 0
Local lGestao	    := Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local lExclusivo 	:= .F.
Local aModoComp 	:= {}
/* GESTAO - fim */

Default lMultiNat := .F.

/* GESTAO - inicio */
#IFDEF TOP
	lNovaGestao := .T.
#ELSE
	lNovaGestao := .F.
#ENDIF
/* GESTAO - fim */

If lFWCodFil .And. lGestao
	aAdd(aModoComp, FWModeAccess("SE5",1) )
	aAdd(aModoComp, FWModeAccess("SE5",2) )
	aAdd(aModoComp, FWModeAccess("SE5",3) )
	lExclusivo := Ascan(aModoComp, 'E') > 0
Else
	dbSelectArea("SE5")
	lExclusivo := !Empty(xFilial("SE5"))
EndIf

If MV_PAR41 == 2
	lConsImp := .F.
EndIf

nGerOrig :=0

li := 1

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If mv_par17 == 2 // Cons filiais abaixo
	cFilDe := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	cFilAte:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Else
	cFilDe := mv_par18	// Todas as filiais
	cFilAte:= mv_par19
EndIf
// Definicao das condicoes e ordem de impressao, de acordo com a ordem escolhida pelo
// usuario.
DbSelectArea("SE5")
Do Case
Case nOrdem == 1
	cCondicao := "E5_DATA >= mv_par01 .and. E5_DATA <= mv_par02"
	cCond2 := "E5_DATA"
	cChave := IndexKey(1)
	cChaveInterFun := cChave
	bFirst := {|| MsSeek(xFilial("SE5")+Dtos(mv_par01),.T.)}
Case nOrdem == 2
	cCondicao := "E5_BANCO >= mv_par03 .and. E5_BANCO <= mv_par04"
	cCond2 := "E5_BANCO"
	cChave := IndexKey(3)
	cChaveInterFun := cChave
	bFirst := {||MsSeek(xFilial("SE5")+mv_par03,.T.)}
Case nOrdem == 3
	cCondicao := "E5_MULTNAT = '1' .Or. (E5_NATUREZ >= mv_par05 .and. E5_NATUREZ <= mv_par06)"
	cCond2 := "E5_NATUREZ"
	cChave := IndexKey(4)
	cChaveInterFun := cChave
	bFirst := {||MsSeek(xFilial("SE5")+mv_par05,.T.)}
Case nOrdem == 4
	cCondicao := ".T."
	cCond2 := "E5_BENEF"
	cChave := "E5_FILIAL+E5_BENEF+DTOS(E5_DATA)+E5_PREFIXO+E5_NUMERO+E5_PARCELA"
	cChaveInterFun := cChave
	bFirst := {||MsSeek(xFilial("SE5"),.T.)}
Case nOrdem == 5
	cCondicao := ".T."
	cCond2 := "E5_NUMERO"
	cChave := "E5_FILIAL+E5_NUMERO+E5_PARCELA+E5_PREFIXO+DTOS(E5_DATA)"
	cChaveInterFun := cChave
	bFirst := {||MsSeek(xFilial("SE5"),.T.)}
Case nOrdem == 6	//Ordem 6 (Digitacao)
	cCondicao := ".T."
	cCond2 := "E5_DTDIGIT"
	cChave := "E5_FILIAL+DTOS(E5_DTDIGIT)+E5_PREFIXO+E5_NUMERO+E5_PARCELA+DTOS(E5_DATA)"
	cChaveInterFun := cChave
	bFirst := {||MsSeek(xFilial("SE5"),.T.)}
Case nOrdem == 7 // por Lote
	cCondicao := "E5_LOTE >= '"+mv_par20+"' .and. E5_LOTE <= '"+mv_par21+"'"
	cCond2 := "E5_LOTE"
	cChave := IndexKey(5)
	cChaveInterFun := cChave
	bFirst := {||MsSeek(xFilial("SE5")+mv_par20,.T.)}
OtherWise						// Data de Cr�dito (dtdispo)
	cCondicao := "E5_DTDISPO >= mv_par01 .and. E5_DTDISPO <= mv_par02"
	cCond2 := "E5_DTDISPO"
	cChave := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
	cChaveInterFun := cChave
	bFirst := {||MsSeek(xFilial("SE5")+Dtos(mv_par01),.T.)}
EndCase

If !Empty(mv_par28) .And. ! ";" $ mv_par28 .And. Len(AllTrim(mv_par28)) > 3
	ApMsgAlert("Separe os tipos a imprimir (pergunta 28) por um ; (ponto e virgula) a cada 3 caracteres")
	Return(Nil)
Endif
If !Empty(mv_par29) .And. ! ";" $ mv_par29 .And. Len(AllTrim(mv_par29)) > 3
	ApMsgAlert("Separe os tipos que n�o deseja imprimir (pergunta 29) por um ; (ponto e virgula) a cada 3 caracteres")
	Return(Nil)
Endif

#IFDEF TOP
	If TcSrvType() != "AS/400" .and. TCGetDB()!="SYBASE"

		lAsTop := .T.
		cCondicao := ".T."
		DbSelectArea("SE5")
		cQuery := ""
		aEval(DbStruct(),{|e| cQuery += ","+AllTrim(e[1])})
		// Obtem os registros a serem processados
		cQuery := "SELECT " +SubStr(cQuery,2)
		cQuery +=         ",SE5.R_E_C_N_O_ SE5RECNO "
		cQuery += "FROM " + RetSqlName("SE5")+" SE5 "
		cQuery += "WHERE E5_RECPAG = '" + IIF( mv_par11 == 1, "R","P") + "' AND "
		cQuery += "      E5_DATA    between '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND "
		cQuery += "      E5_DATA    <= '" + DTOS(dDataBase) + "' AND "
		cQuery += "      E5_BANCO   between '" + mv_par03       + "' AND '" + mv_par04       + "' AND "
		//-- Realiza filtragem pela natureza principal
		If mv_par39 == 2
			cQuery +=  " E5_NATUREZ between '" + mv_par05       + "' AND '" + mv_par06     	+ "' AND "
		Else
			cQuery +=       " (E5_NATUREZ between '" + mv_par05       + "' AND '" + mv_par06       + "' OR "
			cQuery +=       " EXISTS (SELECT EV_FILIAL, EV_PREFIXO, EV_NUM, EV_PARCELA, EV_CLIFOR, EV_LOJA "
			cQuery +=                 " FROM "+RetSqlName("SEV")+" SEV "
			cQuery +=                " WHERE E5_FILIAL  = EV_FILIAL AND "
			cQuery +=                       "E5_PREFIXO = EV_PREFIXO AND "
			cQuery +=                       "E5_NUMERO  = EV_NUM AND "
			cQuery +=                       "E5_PARCELA = EV_PARCELA AND "
			cQuery +=                       "E5_TIPO    = EV_TIPO AND "
			cQuery +=                       "E5_CLIFOR  = EV_CLIFOR AND "
			cQuery +=                       "E5_LOJA    = EV_LOJA AND "
			cQuery +=                       "EV_NATUREZ between '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
			cQuery +=                       "SEV.D_E_L_E_T_ = ' ')) AND "
		EndIf
		cQuery += "      E5_CLIFOR  between '" + mv_par07       + "' AND '" + mv_par08       + "' AND "
		cQuery += "      E5_DTDIGIT between '" + DTOS(mv_par09) + "' AND '" + DTOS(mv_par10) + "' AND "
		cQuery += "      E5_LOTE    between '" + mv_par20       + "' AND '" + mv_par21       + "' AND "
		cQuery += "      E5_LOJA    between '" + mv_par22       + "' AND '" + mv_par23 	    + "' AND "
		cQuery += "      E5_PREFIXO between '" + mv_par26       + "' AND '" + mv_par27 	    + "' AND "
		cQuery += "      SE5.D_E_L_E_T_ = ' '  AND "
		cQuery += "		  E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE') AND "
		cQuery += " 	  E5_SITUACA NOT IN ('C','E','X') AND "
		cQuery += "      ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR "
		cQuery += "      (E5_TIPODOC <> 'CD')) "
		cQuery += "		  AND E5_HISTOR NOT LIKE '%"+'Baixa Automatica / Lote'+"%'"

		If mv_par11 == 2
			cQuery += " AND E5_TIPODOC <> 'E2'"
		EndIf

		If !Empty(mv_par28) // Deseja imprimir apenas os tipos do parametro 28
			cQuery += " AND E5_TIPO IN "+FormatIn(mv_par28,";")
		ElseIf !Empty(Mv_par29) // Deseja excluir os tipos do parametro 29
			cQuery += " AND E5_TIPO NOT IN "+FormatIn(mv_par29,";")
		EndIf

		If mv_par16 == 2
			cQuery += " AND E5_TIPODOC <> '" + SPACE(LEN(E5_TIPODOC)) + "'"
			cQuery += " AND E5_NUMERO  <> '" + SPACE(LEN(E5_NUMERO)) + "'"
			cQuery += " AND E5_TIPODOC <> 'CH'"
		Endif

		If mv_par17 == 2
			cQuery += " AND E5_FILIAL = '" + xFilial("SE5") + "'"
		Else
			cQuery += " AND E5_FILIAL between '" + mv_par18 + "' AND '" + mv_par19 + "'"
		Endif

		cFilUser := oBaixas:GetSqlExp('SE5')

		If lF190Qry
			cQueryAdd := ExecBlock("F190QRY", .F., .F., {cFilUser})
			If ValType(cQueryAdd) == "C"
				cQuery += " AND (" + cQueryAdd + ")"
			EndIf
		EndIf

		If !Empty(cFilUser)
			cQuery += " AND (" + cFilUser + ") "
		EndIf

		// seta a ordem de acordo com a opcao do usuario
		cQuery += " ORDER BY " + SqlOrder(cChave)
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "NEWSE5", .F., .T.)
		For nI := 1 TO LEN(aStru)
			If aStru[nI][2] != "C"
				TCSetField("NEWSE5", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
			EndIf
		Next
		DbGoTop()
	Else
#ENDIF
		//�������������������������������������������������������������Ŀ
		//� Abre o SE5 com outro alias para ser filtrado porque a funcao�
		//� TemBxCanc() utilizara o SE5 sem filtro.							 �
		//���������������������������������������������������������������
		If Select("NEWSE5") == 0 .And. !( ChkFile("SE5",.F.,"NEWSE5") )
			Return(Nil)
		EndIf
		lAsTop := .F.
		DbSelectArea("NEWSE5")
		cFilSE5 := 'E5_RECPAG=='+IIF(mv_par11 == 1,'"R"','"P"')+'.and.'
		cFilSE5 += 'DTOS(E5_DATA)>='+'"'+dtos(mv_par01)+'"'+'.and.DTOS(E5_DATA)<='+'"'+dtos(mv_par02)+'".and.'
		cFilSE5 += 'DTOS(E5_DATA)<='+'"'+dtos(dDataBase)+'".and.'
		If nOrdem == 3
			cFilSE5 += '(E5_MULTNAT = "1" .Or. (E5_NATUREZ>='+'"'+mv_par05+'"'+'.and.E5_NATUREZ<='+'"'+mv_par06+'")).and.'
		Else
			cFilSE5 += '(E5_NATUREZ>='+'"'+mv_par05+'"'+'.and.E5_NATUREZ<='+'"'+mv_par06+'").and.'
		Endif
		cFilSE5 += 'E5_CLIFOR>='+'"'+mv_par07+'"'+'.and.E5_CLIFOR<='+'"'+mv_par08+'".and.'
		cFilSE5 += 'DTOS(E5_DTDIGIT)>='+'"'+dtos(mv_par09)+'"'+'.and.DTOS(E5_DTDIGIT)<='+'"'+dtos(mv_par10)+'".and.'
		cFilSE5 += 'E5_LOTE>='+'"'+mv_par20+'"'+'.and.E5_LOTE<='+'"'+mv_par21+'".and.'
		cFilSE5 += 'E5_LOJA>='+'"'+mv_par22+'"'+'.and.E5_LOJA<='+'"'+mv_par23+'".and.'
		cFilSe5 += 'E5_PREFIXO>='+'"'+mv_par26+'"'+'.And.E5_PREFIXO<='+'"'+mv_par27+'"'

		If !Empty(mv_par28) // Deseja imprimir apenas os tipos do parametro 28
			cFilSe5 += '.And.E5_TIPO $'+'"'+ALLTRIM(mv_par28)+Space(1)+'"'
		ElseIf !Empty(Mv_par29) // Deseja excluir os tipos do parametro 29
			cFilSe5 += '.And.!(E5_TIPO $'+'"'+ALLTRIM(mv_par29)+Space(1)+'")'
		EndIf

		cFilUser := oBaixas:GetAdvPlExp('SE5')
		If !Empty(cFilUser)
			cFilSe5 += '.And. (' + cFilUser + ')'
		Endif

#IFDEF TOP
	Endif
#ENDIF
// Se nao for TOP, ou se for TOP e for AS400, cria Filtro com IndRegua
// Pois em SQL os registros ja estao filtrados em uma Query
If !lAsTop
	cNomeArq := CriaTrab(Nil,.F.)
	IndRegua("NEWSE5",cNomeArq,cChave,,cFilSE5,OemToAnsi("Selecionando Registros..."))
Endif

//������������������������������������������Ŀ
//� Define array para arquivo de trabalho    �
//��������������������������������������������
AADD(aCampos,{"LINHA","C",80,0 } )

//����������������������������Ŀ
//� Cria arquivo de Trabalho   �
//������������������������������
cNomArq1 := CriaTrab(aCampos)
dbUseArea( .T.,, cNomArq1, "Trb", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("TRB",cNomArq1,"LINHA",,,OemToAnsi("Selecionando Registros..."))

aColu := Iif(aTam[1] > 6,{023,027,TamParcela("E1_PARCELA",40,39,38),042,000,022},{000,004,TamParcela("E1_PARCELA",17,16,15),019,023,030})

If MV_PAR16 == 1
	/*
	cChaveSE5  := "E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+E5_TIPODOC+E5_SEQ"
	dbSelectArea("SE5")
	cIndexSE5 := CriaTrab(nil,.f.)
	IndRegua("SE5",cIndexSE5,cChaveSE5,,,"Selecionando")

	#IFNDEF TOP
		dbSetIndex(cIndexSE5+OrdBagExt())
		nIndexSE5 := RetIndex("SE5")
	#ELSE
		nIndexSE5 := RetIndex("SE5")+1
	#ENDIF

	dbSelectArea("SE5")
	#IFNDEF TOP
		dbSetIndex(cIndexSE5+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndexSE5+1)
	dbGoTop()
	*/
	dbSelectArea("SE5")
	dbSetOrder(17) //"E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+E5_TIPODOC+E5_SEQ"
	dbGoTop()

Endif

DbSelectArea("SM0")
DbSeek(cEmpAnt+cFilDe,.T.)

While !Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	cFilNome:= SM0->M0_FILIAL
	DbSelectArea("NEWSE5")

	// Se nao for TOP, ou se for TOP e for AS400, posiciona no primeiro registro do escopo
	// Pois em SQL os registro ja estao filtrados em uma Query e ja esta no inicio do arquivo
	If !lAsTop
		Eval(bFirst) // Posiciona no primeiro registro a ser processado
	Endif

	//If ((MV_MULNATR .and. mv_par11 = 1 .and. mv_par38 = 2 .and. !mv_par39 == 2) .or. (MV_MULNATP .and. mv_par11 = 2 .and. mv_par38 = 2 .and. !mv_par39 == 2))
	If lNaturez

		Finr199(	@nGerOrig,@nGerValor,@nGerDesc,@nGerJurMul,@nGerCM,@nGerAbLiq,@nGerAbImp,@nGerBaixado,@nGerMovFin,@nGerComp,;
					@nFilOrig,@nFilValor,@nFilDesc,@nFilJurMul,@nFilCM,@nFilAbLiq,@nFilAbImp,@nFilBaixado,@nFilMovFin,@nFilComp,;
					.F.,cCondicao,cCond2,aColu,lContinua,cFilSe5,lAsTop,Tamanho, @aRet, @aTotais, nOrdem, @nGerFat, @nFilFat)

		#IFDEF TOP
			If TcSrvType() != "AS/400" .and. TCGetDB()!="SYBASE"
				dbSelectArea("SE5")
				dbCloseArea()
				ChKFile("SE5")
				dbSelectArea("SE5")
				dbSetOrder(1)
			Endif
		#ENDIF
		If Empty(xFilial("SE5"))
			Exit
		Endif
		dbSelectArea("SM0")
		cCodUlt := SM0->M0_CODIGO
		cFilUlt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
		dbSkip()
		Loop

	Else

		While NEWSE5->(!Eof()) .And. NEWSE5->E5_FILIAL==xFilial("SE5") .And. &cCondicao .and. lContinua

			DbSelectArea("NEWSE5")
			// Testa condicoes de filtro
			If !Fr190TstCond(cFilSe5,.F.)
				NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
				Loop
			Endif

			// Se nao for TOP, ou se for TOP e for AS400, posiciona no primeiro registro do escopo
			// Pois em SQL os registro ja estao filtrados em uma Query e ja esta no inicio do arquivo
			If !lAsTop
				SE2->(dbSetOrder(1))
				SE2->(MsSeek(NEWSE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
				If SE2->E2_MULTNAT == '1'
					lNaturez := .F.
					SEV->(dbSetOrder(1))
					SEV->(MsSeek(NEWSE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
					While NEWSE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA) .and. !lNaturez
						If SEV->EV_NATUREZ >= mv_par05 .and. SEV->EV_NATUREZ <= mv_par06
							lNaturez := .T.
						EndIf
						SEV->(DbSkip())
					EndDo
					If !lNaturez
						NEWSE5->(dbSkip())
						Loop
					EndIf
				Else
					If !(NEWSE5->E5_NATUREZ >= mv_par05 .and. NEWSE5->E5_NATUREZ <= mv_par06)
						NEWSE5->(dbSkip())
						Loop
					EndIf
				EndIf
			EndIf
			If (NEWSE5->E5_RECPAG == "R" .and. ! (NEWSE5->E5_TIPO $ "PA /"+MV_CPNEG )) .or. ;	//Titulo normal
				(NEWSE5->E5_RECPAG == "P" .and.   (NEWSE5->E5_TIPO $ "RA /"+MV_CRNEG )) 	//Adiantamento
				cCarteira := "R"
			Else
				cCarteira := "P"
			Endif

			dbSelectArea("NEWSE5")
			cAnterior 	:= &cCond2
			nTotValor	:= 0
			nTotDesc	:= 0
			nTotJurMul  := 0
			nTotCM		:= 0
			nCT			:= 0
			nTotOrig	:= 0
			nTotBaixado	:= 0
			nTotAbLiq  	:= 0
			nTotImp		:= 0
			nTotMovFin	:= 0
			nTotComp	:= 0
			nTotFat	    := 0
			nTotIRRF    := 0
			nTotPIS     := 0
			nTotCSSL    := 0
			nTotCOFI    := 0

			While NEWSE5->(!EOF()) .and. &cCond2=cAnterior .and. NEWSE5->E5_FILIAL=xFilial("SE5") .and. lContinua

				lManual := .f.
				dbSelectArea("NEWSE5")

				If (Empty(NEWSE5->E5_TIPODOC) .And. mv_par16 == 1) .Or.;
					(Empty(NEWSE5->E5_NUMERO)  .And. mv_par16 == 1)
					lManual := .t.
				EndIf

				// Testa condicoes de filtro
				If !Fr190TstCond(cFilSe5,.T.)
					dbSelectArea("NEWSE5")
					NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
					Loop
				Endif

				// Imprime somente cheques
				If mv_par37 == 1 .And. NEWSE5->E5_TIPODOC == "BA"

					aAreaSE5 := SE5->(GetArea())
					lAchou := .F.

					SE5->(dbSetOrder(11))
					cChaveNSE5	:= NEWSE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)
					SE5->(MsSeek(xFilial("SE5")+cChaveNSE5))

					// Procura o cheque aglutinado, se encontrar, marca lAchou := .T. e despreza
					WHILE SE5->(!EOF()) .And. SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)	== cChaveNSE5
						If SE5->E5_TIPODOC == "CH"
							lAchou := .T.
							Exit
						Endif
						SE5->(dbSkip())
					Enddo
					RestArea(aAreaSE5)
					// Achou cheque aglutinado para a baixa, despreza o registro
					If lAchou
						NEWSE5->(dbSkip())
						Loop
					Endif

				ElseIf mv_par37 == 2 .And. NEWSE5->E5_TIPODOC == "CH" //somente baixas

					aAreaSE5 := SE5->(GetArea())
					lAchou := .F.

					SE5->(dbSetOrder(11))
					cChaveNSE5	:= NEWSE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)
					SE5->(MsSeek(xFilial("SE5")+cChaveNSE5))

					// Procura a baixa aglutinada, se encontrar despreza o movimento bancario
					WHILE SE5->(!EOF()) .And. SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)	== cChaveNSE5
						If SE5->E5_TIPODOC $ "BA"
							lAchou := .T.
							Exit
						Endif
						SE5->(dbSkip())
					Enddo
					RestArea(aAreaSE5)
					// Achou cheque aglutinado para a baixa, despreza o registro
					If lAchou
						NEWSE5->(dbSkip())
						Loop
					Endif
				Endif

				cNumero    	:= NEWSE5->E5_NUMERO
				cPrefixo   	:= NEWSE5->E5_PREFIXO
				cParcela   	:= NEWSE5->E5_PARCELA
				dBaixa     	:= NEWSE5->E5_DATA
				cBanco     	:= NEWSE5->E5_BANCO
				cNatureza  	:= NEWSE5->E5_NATUREZ
				cCliFor    	:= NEWSE5->E5_BENEF
				cLoja      	:= NEWSE5->E5_LOJA
				cSeq       	:= NEWSE5->E5_SEQ
				cNumCheq   	:= NEWSE5->E5_NUMCHEQ
				cRecPag     := NEWSE5->E5_RECPAG
				cTipodoc   	:= NEWSE5->E5_TIPODOC
				cMotBaixa	:= NEWSE5->E5_MOTBX
				cCheque    	:= NEWSE5->E5_NUMCHEQ
				cTipo      	:= NEWSE5->E5_TIPO
				cFornece   	:= NEWSE5->E5_CLIFOR
				cLoja      	:= NEWSE5->E5_LOJA
				dDigit     	:= NEWSE5->E5_DTDIGIT
				lBxTit	  	:= .F.
				cFilorig    := NEWSE5->E5_FILORIG

				If (NEWSE5->E5_RECPAG == "R" .and. ! (NEWSE5->E5_TIPO $ "PA /"+MV_CPNEG )) .or. ;	//Titulo normal
					(NEWSE5->E5_RECPAG == "P" .and.   (NEWSE5->E5_TIPO $ "RA /"+MV_CRNEG )) 	//Adiantamento
					dbSelectArea("SE1")
					dbSetOrder(1)
					lBxTit := MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo)
					If !lBxTit
						lBxTit := dbSeek(NEWSE5->E5_FILORIG+cPrefixo+cNumero+cParcela+cTipo)
					Endif
					cCarteira := "R"
					dDtMovFin := IIF (lManual,CTOD("//"), DataValida(SE1->E1_VENCTO,.T.))
					While SE1->(!Eof()) .and. SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO==cPrefixo+cNumero+cParcela+cTipo
						If SE1->E1_CLIENTE == cFornece .And. SE1->E1_LOJA == cLoja	// Cliente igual, Ok
							Exit
						Endif
						SE1->( dbSkip() )
					EndDo
					If !SE1->(EOF()) .And. mv_par11 == 1 .and. !lManual .and.  ;
						(NEWSE5->E5_RECPAG == "R" .and. !(NEWSE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG))
						If SE5->(FieldPos("E5_SITCOB")) > 0
							cExp := "NEWSE5->E5_SITCOB"
						Else
							cExp := "SE1->E1_SITUACA"
						Endif

						If mv_par36 == 2 // Nao imprime titulos em carteira
							// Retira da comparacao as situacoes branco, 0, F e G
							mv_par15 := AllTrim(mv_par15)
							mv_par15 := StrTran(mv_par15,"0","")
							mv_par15 := StrTran(mv_par15,"F","")
							mv_par15 := StrTran(mv_par15,"G","")
						Else
							If (NEWSE5->E5_RECPAG == "R") .And. lAjuPar15
								mv_par15  += " "
							Endif
						EndIf

						cExp += " $ mv_par15"
						If !(&cExp)
							dbSelectArea("NEWSE5")
							NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
							Loop
						Endif
					Endif
					cCond3:="E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_SEQ+E5_NUMCHEQ==cPrefixo+cNumero+cParcela+cTipo+DtoS(dBaixa)+cSeq+cNumCheq"
					nDesc := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
					nIRRF := nPIS := nValor := nCOFINS := nCSLL := nCM := nVlMovFin := 0
					nISS  := nINSS := 0
				Else
					dbSelectArea("SE2")
					DbSetOrder(1)
					cCarteira := "P"
				    lBxTit := MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)

				    Iif(lBxTit, nRecSE2	:= SE2->(Recno()), nRecSE2 := 0 )

					If !lBxTit
						lBxTit := dbSeek(NEWSE5->E5_FILORIG+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)
					Endif
					dDtMovFin := IIF(lManual,CTOD("//"),DataValida(SE2->E2_VENCTO,.T.))
					cCond3:="E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+DtoS(E5_DATA)+E5_SEQ+E5_NUMCHEQ==cPrefixo+cNumero+cParcela+cTipo+cFornece+DtoS(dBaixa)+cSeq+cNumCheq"
					nDesc := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
					nIRRF := nPIS := nValor := nCOFINS := nCSLL := nCM := nVlMovFin := 0
					nISS  := nINSS := 0
					cCheque    := Iif(Empty(NEWSE5->E5_NUMCHEQ),SE2->E2_NUMBCO,NEWSE5->E5_NUMCHEQ)
				Endif
				dbSelectArea("NEWSE5")

				cHistorico := Space(40)
				While NEWSE5->( !Eof()) .and. &cCond3 .and. lContinua .And. NEWSE5->E5_FILIAL==xFilial("SE5")

					dbSelectArea("NEWSE5")
					cTipodoc   := NEWSE5->E5_TIPODOC
					cCheque    := NEWSE5->E5_NUMCHEQ

					lAchouEmp := .T.
					lAchouEst := .F.

					// Testa condicoes de filtro
					If !Fr190TstCond(cFilSe5,.T.)
						dbSelectArea("NEWSE5")
						NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
						Loop
					Endif

					If NEWSE5->E5_SITUACA $ "C/E/X"
						dbSelectArea("NEWSE5")
						NEWSE5->( dbSkip() )
						Loop
					EndIF

					If NEWSE5->E5_LOJA != cLoja
						Exit
					Endif

					If NEWSE5->E5_FILORIG < mv_par33 .or. NEWSE5->E5_FILORIG > mv_par34
						dbSelectArea("NEWSE5")
						NEWSE5->( dbSkip() )
						Loop
					Endif

					//���������������������������������������������������Ŀ
					//� Nao imprime os registros de emprestimos excluidos �
					//�����������������������������������������������������
					If NEWSE5->E5_TIPODOC == "EP"
						aAreaSE5 := NEWSE5->(GetArea())
						dbSelectArea("SEH")
						dbSetOrder(1)
						lAchouEmp := MsSeek(xFilial("SEH")+Substr(NEWSE5->E5_DOCUMEN,1,nTamEH))
						RestArea(aAreaSE5)
						If !lAchouEmp
							NEWSE5->(dbSkip())
							Loop
						EndIf
					EndIf

					//�����������������������������������������������������������������Ŀ
					//� Nao imprime os registros de pagamento de emprestimos estornados �
					//�������������������������������������������������������������������
					If NEWSE5->E5_TIPODOC == "PE"
						aAreaSE5 := NEWSE5->(GetArea())
						dbSelectArea("SEI")
						dbSetOrder(1)
						If	MsSeek(xFilial("SEI")+"EMP"+Substr(NEWSE5->E5_DOCUMEN,1,nTamEI))
							If SEI->EI_STATUS == "C"
								lAchouEst := .T.
							EndIf
						EndIf
						RestArea(aAreaSE5)
						If lAchouEst
							NEWSE5->(dbSkip())
							Loop
						EndIf
					EndIf

					//�����������������������������Ŀ
					//� Verifica o vencto do Titulo �
					//�������������������������������
					cFilTrb := If(mv_par11==1,"SE1","SE2")
					If (cFilTrb)->(!Eof()) .And.;
						((cFilTrb)->&(Right(cFilTrb,2)+"_VENCREA") < mv_par31 .Or. (!Empty(mv_par32) .And. (cFilTrb)->&(Right(cFilTrb,2)+"_VENCREA") > mv_par32))
						dbSelectArea("NEWSE5")
						NEWSE5->(dbSkip())
						Loop
					Endif

					dBaixa     	:= NEWSE5->E5_DATA
					cBanco     	:= NEWSE5->E5_BANCO
					cNatureza  	:= NEWSE5->E5_NATUREZ
					cCliFor    	:= NEWSE5->E5_BENEF
					cSeq       	:= NEWSE5->E5_SEQ
					cNumCheq   	:= NEWSE5->E5_NUMCHEQ
					cRecPag		:= NEWSE5->E5_RECPAG
					cMotBaixa	:= NEWSE5->E5_MOTBX
					cTipo190	:= NEWSE5->E5_TIPO
					cFilorig    := NEWSE5->E5_FILORIG
					//��������������������������������������������������������������Ŀ
					//� Obter moeda da conta no Banco.                               �
					//����������������������������������������������������������������
					If ( cPaisLoc # "BRA".And.!Empty(NEWSE5->E5_BANCO+NEWSE5->E5_AGENCIA+NEWSE5->E5_CONTA) ) .OR. ( FindFunction( "FXMultSld" ) .AND. FXMultSld() )
						SA6->(DbSetOrder(1))
						SA6->(MsSeek(xFilial()+NEWSE5->E5_BANCO+NEWSE5->E5_AGENCIA+NEWSE5->E5_CONTA))
						nMoedaBco	:=	Max(SA6->A6_MOEDA,1)
					Else
						nMoedaBco	:=	1
					Endif

					If !Empty(NEWSE5->E5_NUMERO)
						If (NEWSE5->E5_RECPAG == "R" .and. !(NEWSE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG)) .or. ;
							(NEWSE5->E5_RECPAG == "P" .and. NEWSE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG) .Or.;
							(NEWSE5->E5_RECPAG == "P" .And. NEWSE5->E5_TIPODOC $ "DB#OD")
							dbSelectArea( "SA1")
							dbSetOrder(1)
							lAchou := .F.
							If Empty(xFilial("SA1"))  //SA1 Compartilhado
								If dbSeek(xFilial("SA1")+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									lAchou := .T.
								Endif
							Else
								cFilOrig := NEWSE5->E5_FILIAL //Procuro SA1 pela filial do movimento
								If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
										lAchou := .T.
									Else
										cFilOrig := NEWSE5->E5_FILORIG //Procuro SA1 pela filial origem
										If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
											If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
												lAchou := .T.
											Endif
										Endif
									Endif
								Else
									cFilOrig := NEWSE5->E5_FILORIG	//Procuro SA1 pela filial origem
									If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
										If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
											lAchou := .T.
										Endif
									Endif
								Endif
							EndIF
							If lAchou
								cCliFor := Iif(mv_par30==1,SA1->A1_NREDUZ,SA1->A1_NOME)
							Else
								cCliFor	:= 	Upper(Alltrim(NEWSE5->E5_BENEF))
							Endif
						Else
							dbSelectArea( "SA2")
							dbSetOrder(1)
							lAchou := .F.
							If Empty(xFilial("SA2"))  //SA2 Compartilhado
								If dbSeek(xFilial("SA2")+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									lAchou := .T.
								Endif
							Else
								cFilOrig := NEWSE5->E5_FILIAL //Procuro SA2 pela filial do movimento
								If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
										lAchou := .T.
									Else
										cFilOrig := NEWSE5->E5_FILORIG //Procuro SA2 pela filial origem
										If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
											If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
												lAchou := .T.
											Endif
										Endif
									Endif
								Else
									cFilOrig := NEWSE5->E5_FILORIG	//Procuro SA2 pela filial origem
									If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
										If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
											lAchou := .T.
										Endif
									Endif
								Endif
							EndIF
							If lAchou
								cCliFor := Iif(mv_par30==1,SA2->A2_NREDUZ,SA2->A2_NOME)
							Else
								cCliFor	:= 	Upper(Alltrim(NEWSE5->E5_BENEF))
							Endif
						EndIf
					EndIf
					dbSelectArea("SM2")
					dbSetOrder(1)
					dbSeek(NEWSE5->E5_DATA)
					dbSelectArea("NEWSE5")
					nTaxa:= 0

					If cPaisLoc=="BRA"
						If !Empty(NEWSE5->E5_TXMOEDA)
							nTaxa:=NEWSE5->E5_TXMOEDA
						Else
							If nMoedaBco == 1
								nTaxa := NEWSE5->E5_VALOR / NEWSE5->E5_VLMOED2
							Else
								nTaxa := NEWSE5->E5_VLMOED2 / NEWSE5->E5_VALOR
							EndIf
						EndIf
					EndIf
					nRecSe5:=If(lAsTop,NEWSE5->SE5RECNO,Recno())
					nDesc+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VLDESCO,Round(xMoeda(NEWSE5->E5_VLDESCO,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))
					nJuros+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VLJUROS,Round(xMoeda(NEWSE5->E5_VLJUROS,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))
					nMulta+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VLMULTA,Round(xMoeda(NEWSE5->E5_VLMULTA,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))
					nJurMul+= nJuros + nMulta
					nCM+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VLCORRE,Round(xMoeda(NEWSE5->E5_VLCORRE,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))

					If lPccBaixa .and. Empty(NEWSE5->E5_PRETPIS) .And. Empty(NEWSE5->E5_PRETCOF) .And. Empty(NEWSE5->E5_PRETCSL)
						If nRecSE2 > 0

							aAreabk  := Getarea()
							aAreaSE2 := SE2->(Getarea())
							SE2->(DbGoto(nRecSE2))

							nTotAbImp+=(NEWSE5->E5_VRETPIS)+(NEWSE5->E5_VRETCOF)+(NEWSE5->E5_VRETCSL)+;
										SE2->E2_INSS+ SE2->E2_ISS+ SE2->E2_IRRF

							Restarea(aAreaSE2)
							Restarea(aAreabk)
						Else
							nTotAbImp+=(NEWSE5->E5_VRETPIS)+(NEWSE5->E5_VRETCOF)+(NEWSE5->E5_VRETCSL)
						Endif
					Endif

					If NEWSE5->E5_TIPODOC $ "VL/V2/BA/RA/PA/CP"
						nValTroco := 0
						cHistorico := NEWSE5->E5_HISTOR
						//nValor+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VALOR,Round(xMoeda(NEWSE5->E5_VALOR,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))

						If mv_par11 == 2
							If cPaisLoc == "ARG" .and. !EMPTY(NEWSE5->E5_ORDREC)
								nValor += Iif(VAL(NEWSE5->E5_MOEDA)==mv_par12,NEWSE5->E5_VALOR,Round(xMoeda(NEWSE5->E5_VALOR,VAL(NEWSE5->E5_MOEDA),mv_par12,NEWSE5->E5_DATA,nDecs+1,NEWSE5->E5_TXMOEDA),nDecs+1))
							Else
							 	nValor += Iif(mv_par12==nMoedaBco,NEWSE5->E5_VALOR,Round(xMoeda(NEWSE5->E5_VLMOED2,SE2->E2_MOEDA,mv_par12,SE2->E2_BAIXA,nDecs+1,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0))+nJurMul-nDesc,nDecs+1))
							Endif
						Else
						 	nValor+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VALOR,Round(xMoeda(NEWSE5->E5_VLMOED2,SE1->E1_MOEDA,mv_par12,SE1->E1_BAIXA,nDecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),nDecs+1))
						EndIf

						//Pcc Baixa CR
						If cCarteira == "R" .and. lPccBxCr .and. cPaisLoc == "BRA" .And. (IiF(lRaRtImp,NEWSE5->E5_TIPO $ MVRECANT,.T.) .OR. lPccBaixa)
							If Empty(NEWSE5->E5_PRETPIS)
								nPccBxCr += Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VRETPIS,Round(xMoeda(NEWSE5->E5_VRETPIS,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,,NEWSE5->E5_TXMOEDA),nDecs+1))
							Endif
							If Empty(NEWSE5->E5_PRETCOF)
								nPccBxCr += Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VRETCOF,Round(xMoeda(NEWSE5->E5_VRETCOF,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,,NEWSE5->E5_TXMOEDA),nDecs+1))
							Endif
							If Empty(NEWSE5->E5_PRETCSL)
								nPccBxCr += Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VRETCSL,Round(xMoeda(NEWSE5->E5_VRETCSL,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,,NEWSE5->E5_TXMOEDA),nDecs+1))
							Endif
						Endif

					Else
						nVlMovFin+=Iif(mv_par12==1.And.nMoedaBco==1,NEWSE5->E5_VALOR,Round(xMoeda(NEWSE5->E5_VALOR,nMoedaBco,mv_par12,NEWSE5->E5_DATA,nDecs+1,nTaxa),nDecs+1))
						cHistorico := Iif(Empty(NEWSE5->E5_HISTOR),"MOV FIN MANUAL",NEWSE5->E5_HISTOR)
						cNatureza  	:= NEWSE5->E5_NATUREZ
					Endif

					cAuxFilNome := cFilAnt + " - "+ cFilNome
					cAuxCliFor  := cCliFor
					cAuxLote    := E5_LOTE
					dAuxDtDispo := E5_DTDISPO

					dbSkip()
					If lManual		// forca a saida do looping se for mov manual
						Exit
					Endif
				EndDO

				If (nDesc+nValor+nJurMul+nCM+nVlMovFin) > 0
					AAdd(aRet, Array(30))

					// Defaults >>>
					aRet[Li][01] := ""
					aRet[Li][02] := ""
					aRet[Li][03] := ""
					aRet[Li][04] := ""
					aRet[Li][05] := ""
					// <<< Defaults

					aRet[Li][22] := cAuxFilNome
					aRet[Li][23] := cAuxCliFor
					aRet[Li][24] := cAuxLote
					aRet[Li][25] := dAuxDtDispo
					//������������������������������Ŀ
					//� C�lculo do Abatimento        �
					//��������������������������������
					If cCarteira == "R" .and. !lManual
						dbSelectArea("SE1")
						nRecno := Recno()
						nAbat := 0
						nAbatLiq := 0
						If !SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG

							//�����������������������������������������������������������������������Ŀ
							//� Encontra a ultima sequencia de baixa na SE5 a partir do t�tulo da SE1 �
							//�������������������������������������������������������������������������
							aAreaSE1 := SE1->(GetArea())
							dbSelectArea("SE5")
							dbSetOrder(7)
							cChaveSE1 := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
							SE5->(MsSeek(xFilial("SE5")+cChaveSE1))

							cSeqSE5 := SE5->E5_SEQ

							While SE5->(!EOF()) .And. cChaveSE1 == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
								If SE5->E5_SEQ > cSeqSE5
									cSeqSE5 := SE5->E5_SEQ
								Endif
								SE5->(dbSkip())
							Enddo

							lUltBaixa := .F.
							SE5->(MsSeek(xFilial("SE5")+cChaveSE1+cSeqSE5))
							cChaveSE5 := cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja+cSeq

							If cChaveSE5 == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) .And.;
								Empty(SE1->E1_SALDO)
								If SE1->E1_VALOR <> SE1->E1_VALLIQ
									lUltBaixa := .T.
								EndIf
							EndIf

							//��������������������������������������������������������������������Ŀ
							//� Calcula o valor total de abatimento do titulo e impostos se houver �
							//����������������������������������������������������������������������
							nTotAbImp  := 0
							If lUltBaixa
								//nAbat := SumAbatRec(cPrefixo,cNumero,cParcela,SE1->E1_MOEDA,"V",dBaixa,@nTotAbImp)
								nAbat := SumAbatRec(cPrefixo,cNumero,cParcela,SE1->E1_MOEDA,"V",dBaixa,@nTotAbImp,@nIRRF,@nCSLL,@nPIS,@nCOFINS,@nINSS)
								nAbatLiq := nAbat - nTotAbImp
							EndIf
							lUltBaixa := .F.
							RestArea(aAreaSE1)

							cCliFor190 := SE1->E1_CLIENTE+SE1->E1_LOJA

							SA1->(DBSetOrder(1))
							If SA1->(DBSeek(xFilial("SA1")+cCliFor190) )
								lCalcIRF := SA1->A1_RECIRRF == "1" .and. SA1->A1_IRBAX == "1" // se for na baixa
							Else
								lCalcIRF := .F.
							EndIf
							If lCalcIRF
								nTotAbImp += SE1->E1_IRRF
							EndIf
						EndIf
						dbSelectArea("SE1")
						dbGoTo(nRecno)
					Elseif !lManual
						dbSelectArea("SE2")
						nRecno := Recno()
						nAbat := 0
						nAbatLiq := 0
						If !SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
							nAbat :=	SomaAbat(cPrefixo,cNumero,cParcela,"P",mv_par12,,cFornece,cLoja)
							nAbatLiq := nAbat
						EndIf
						dbSelectArea("SE2")
						dbGoTo(nRecno)
					EndIF
					aRet[li][05]:= " "
					IF mv_par11 == 1 .and. aTam[1] > 6 .and. !lManual
						If lBxTit
							aRet[li][05] := SE1->E1_CLIENTE
						Endif
						aRet[li][06] := AllTrim(cCliFor)
					Elseif mv_par11 == 2 .and. aTam[1] > 6 .and. !lManual
						If lBxTit
							aRet[li][05] := SE2->E2_FORNECE
						Endif
						aRet[li][06] := AllTrim(cCliFor)
					Endif

					aRet[li][01] := cPrefixo
					aRet[li][02] := cNumero
					aRet[li][03] := cParcela
					aRet[li][04] := cTipo

					If !lManual
						dbSelectArea("TRB")
						lOriginal := .T.
						//������������������������������Ŀ
						//� Baixas a Receber             �
						//��������������������������������
						If cCarteira == "R"
							cCliFor190 := SE1->E1_CLIENTE+SE1->E1_LOJA
							nVlr:= SE1->E1_VLCRUZ
							If mv_par12 > 1
								nVlr := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par12,SE1->E1_BAIXA,nDecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),nDecs+1)
							EndIF
							//������������������������������Ŀ
							//� Baixa de PA                  �
							//��������������������������������
						Else
							cCliFor190 := SE2->E2_FORNECE+SE2->E2_LOJA
							lCalcIRF:= Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CALCIRF") == "1" .Or.;//1-Normal, 2-Baixa
								    	   Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CALCIRF") == " "

							// MV_MRETISS "1" retencao do ISS na Emissao, "2" retencao na Baixa.
							nVlr:= SE2->E2_VLCRUZ
							If lConsImp   //default soma os impostos no valor original
								nVlr += SE2->E2_INSS+ Iif(GetNewPar('MV_MRETISS',"1")=="1",SE2->E2_ISS,0) +;
									   	Iif(lCalcIRF,SE2->E2_IRRF,0)
								If ! lPccBaixa  // SE PCC NA EMISSAO SOMA PCC
									nVlr += SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL
								EndIf
							EndIf

							If mv_par12 > 1
								nVlr := Round(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par12,SE2->E2_BAIXA,nDecs+1,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0)),nDecs+1)
							Endif
						Endif
						aRet[li,28] := nRecSE5
						dbgoto(nRecSe5)
						cFilTrb := If(cCarteira=="R","SE1","SE2")
						IF DbSeek( xFilial(cFilTrb)+cPrefixo+cNumero+cParcela+cCliFor190+cTipo)
							nAbat:=0
							lOriginal := .F.
						Else
							nVlr:=NoRound(nVlr)
							RecLock("TRB",.T.)
							Replace linha With xFilial(cFilTrb)+cPrefixo+cNumero+cParcela+cCliFor190+cTipo
							MsUnlock()
						EndIF
					Else
						If lAsTop
							dbSelectArea("SE5")
						Else
							dbSelectArea("NEWSE5")
						Endif
						aRet[li,28] := nRecSE5
						dbgoto(nRecSe5)
						nVlr := Round(xMoeda(E5_VALOR,nMoedaBco,mv_par12,E5_DATA,nDecs+1,,If(cPaisLoc=="BRA",E5_TXMOEDA,0)),nDecs+1)
						nAbat:= 0
						lOriginal := .t.
						If lAsTop
							nRecSe5:=NEWSE5->SE5RECNO
						Else
							nRecSe5:=Recno()
							NEWSE5->( dbSkip() )
						Endif
						dbSelectArea("TRB")
					Endif
					IF cCarteira == "R"
						If ( !lManual )
							If mv_par13 == 1  // Utilizar o Hist�rico da Baixa ou Emiss�o
								cHistorico := Iif(Empty(cHistorico), SE1->E1_HIST, cHistorico )
							Else
								cHistorico := Iif(Empty(SE1->E1_HIST), cHistorico, SE1->E1_HIST )
							Endif
						EndIf
						If aTam[1] <= 6 .and. !lManual
							If lBxTit
								aRet[li][05] := SE1->E1_CLIENTE
							Endif
							aRet[li][06] := AllTrim(cCliFor)
						Endif
						aRet[li][07] := cNatureza
						If Empty( dDtMovFin ) .or. dDtMovFin == Nil
							dDtMovFin := CtoD("  /  /  ")
						Endif
						aRet[li][08] := IIf(lManual,dDtMovFin,DataValida(SE1->E1_VENCTO,.T.)) //Vencto
						aRet[li][09] := AllTrim(cHistorico)
						aRet[li][10] := dBaixa
						IF nVlr > 0
							aRet[li][11] := nVlr // Picture tm(nVlr,14,nDecs)
						Endif
						// Busco o ISS
						nISS := Posicione("SE1",1,xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)+"IS-","E1_VALOR")
					Else
						If mv_par13 == 1  // Utilizar o Hist�rico da Baixa ou Emiss�o
							cHistorico := Iif(Empty(cHistorico), SE2->E2_HIST, cHistorico )
						Else
							cHistorico := Iif(Empty(SE2->E2_HIST), cHistorico, SE2->E2_HIST )
						Endif
						If aTam[1] <= 6 .and. !lManual
							If lBxTit
								aRet[li][05] := SE2->E2_FORNECE
							Endif
							aRet[li][06] := AllTrim(cCliFor)
						Endif
						aRet[li][07] := cNatureza
						If Empty( dDtMovFin ) .or. dDtMovFin == Nil
							dDtMovFin := CtoD("  /  /  ")
						Endif
						aRet[li][08] := IIf(lManual,dDtMovFin,DataValida(SE2->E2_VENCTO,.T.))
						If !Empty(cCheque)
							aRet[li][09] := ALLTRIM(cCheque)+"/"+Trim(cHistorico)
						Else
							aRet[li][09] := ALLTRIM(cHistorico)
						EndIf
						aRet[li][10] := dBaixa
						IF nVlr > 0
							aRet[li][11] := nVlr //Picture tm(nVlr,14,nDecs)
						Endif
						nISS  := SE2->E2_ISS
						nINSS := SE2->E2_INSS
					Endif
					nCT++
					aRet[li][12] := nTotAbImp //nJurMul    //PicTure tm(nJurMul,11,nDecs)

					If cCarteira == "R" .and. mv_par12 == SE1->E1_MOEDA
					   aRet[li][13] := nIRRF // 0

					ElseIf cCarteira == "P" .and. mv_par12 == SE2->E2_MOEDA
					   aRet[li][13] := 0

					Else
					   aRet[li][13] := nIRRF // nCM        //PicTure tm(nCM ,11,nDecs)

					Endif

					//PCC Baixa CR
					//Somo aos abatimentos de impostos, os impostos PCC na baixa.
					//Caso o calculo do PCC CR seja pela emissao, esta variavel estara zerada
					nTotAbImp := nTotAbImp + nPccBxCr

					aRet[li][14] := nPIS 		// nDesc      //PicTure tm(nDesc,11,nDecs)
					aRet[li][15] := nCOFINS 	// nAbatLiq  	//Picture tm(nAbatLiq,11,nDecs)
					aRet[li][16] := nCSLL 		// nTotAbImp 	//Picture tm(nTotAbImp,11,nDecs)
					aRet[li][29] := nISS
					aRet[li][30] := nINSS
					If nVlMovFin > 0
						aRet[li][17] := nVlMovFin     //PicTure tm(nVlMovFin,15,nDecs)
					Else
						aRet[li][17] := nValor			//PicTure tm(nValor,15,nDecs)
					Endif
					aRet[li][18] := cBanco
					If Len(DtoC(dDigit)) <= 8
						aRet[li][19] := dDigit
					Else
						aRet[li][19] := dDigit
					EndIf

					If empty(cMotBaixa)
						cMotBaixa := "NOR"  //NORMAL
					Endif

					aRet[li][20] := Substr(cMotBaixa,1,3)
					aRet[li][21] := cFilorig

					aRet[li][26] := lOriginal
					aRet[li][27] := If( nVlMovFin <> 0, nVlMovFin , If(MovBcoBx(cMotBaixa),nValor,0))
					nTotOrig   += If(lOriginal,nVlr,0)
					nTotBaixado+= If(cTipodoc $ "CP/BA" .AND. cMotBaixa $ "CMP/FAT",0,nValor)		// n�o soma, j� somou no principal
					//nTotDesc   += nDesc
					//nTotJurMul += nJurMul
					//nTotCM     += nCM
					//nTotAbLiq  += nAbatLiq
					nTotImp    += nTotAbImp
					nTotIRRF   += nIRRF
					nTotPIS    += nPIS
					nTotCOFI   += nCOFINS
					nTotCSLL   += nCSLL
					nTotISS    += nISS
					nTotINSS   += nINSS
					nTotValor  += If( nVlMovFin <> 0, nVlMovFin , If(MovBcoBx(cMotBaixa),nValor,0))
					nTotMovFin += nVlMovFin
					nTotComp   += If(cTipodoc == "CP",nValor,0)
					nTotFat    += If(cMotBaixa $ "FAT",nValor,0)
					nDesc := nJurMul := nValor := nCM := nAbat := nTotAbImp := nAbatLiq := nVlMovFin := 0
					nIRRF := nPIS := nValor := nCOFINS := nCSLL := nTotAbImp := nAbatLiq := nVlMovFin := 0
					nISS  := nINSS := 0
					nPccBxCr := 0		//PCC Baixa CR
					li++
				Endif
				dbSelectArea("NEWSE5")
			Enddo

			If (nOrdem == 1 .or. nOrdem == 6 .or. nOrdem == 8)
				cQuebra := DtoS(cAnterior)
			Else //nOrdem == 2 .or. nOrdem == 3 .or. nOrdem == 4 .or. nOrdem == 5 .or. nOrdem == 7
				cQuebra := cAnterior
			EndIf

			//If (nTotValor+nDesc+nJurMul+nCM+nTotOrig+nTotMovFin+nTotComp+nTotFat)>0
			If (nTotValor+nIRRF+nPIS+nCOFINS+nTotOrig+nTotMovFin+nTotComp+nTotFat)>0
				If nCT > 0
					If nTotBaixado > 0
						AAdd(aTotais,{cQuebra,"Baixados",nTotBaixado})
					Endif
					If nTotMovFin > 0
						AAdd(aTotais,{cQuebra,"Mov Fin.",nTotMovFin})
					Endif
					If nTotComp > 0
						AAdd(aTotais,{cQuebra,"Compens.",nTotComp})
					Endif
					If nTotFat > 0
						AAdd(aTotais,{cQuebra,"Bx.Fatura",nTotFat})
					Endif
				Endif
			Endif

			//�������������������������Ŀ
			//�Incrementa Totais Gerais �
			//���������������������������
			nGerBaixado += nTotBaixado
			nGerMovFin	+= nTotMovFin
			nGerComp	+= nTotComp
			nGerFat		+= nTotFat
			nGerIRRF	+= nTotIRRF
			nGerPIS	    += nTotPIS
			nGerCOFI	+= nTotCOFI
			nGerCSLL	+= nTotCSLL
			nGerISS     += nTotISS
			nGerINSS    += nTotINSS

			//�������������������������Ŀ
			//�Incrementa Totais Filial �
			//���������������������������
			nFilOrig	+= nTotOrig
			nFilValor	+= nTotValor
			nFilDesc	+= nTotDesc
			nFilJurMul	+= nTotJurMul
			nFilCM		+= nTotCM
			nFilAbLiq	+= nTotAbLiq
			nFilAbImp	+= nTotImp
			nFilBaixado += nTotBaixado
			nFilMovFin	+= nTotMovFin
			nFilComp	+= nTotComp
			nFilFat     += nTotFat
			nFilIRRF	+= nTotIRRF
			nFilPIS		+= nTotPIS
			nFilCOFI	+= nTotCOFI
			nFilCSLL	+= nTotCSLL
			nFilISS     += nTotISS
			nFilINSS    += nTotINSS

		Enddo
	Endif
	//����������������������������������������Ŀ
	//� Imprimir TOTAL por filial somente quan-�
	//� do houver mais do que 1 filial.        �
	//������������������������������������������
	if mv_par17 == 1 .and. SM0->(Reccount()) > 1
		If nFilBaixado > 0
			AAdd( aTotais,{ IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ), "Baixados", nFilBaixado } )
		Endif
		If nFilMovFin > 0
			AAdd( aTotais,{ IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ), "Mov Fin.", nFilMovFin } )
		Endif
		If nFilComp > 0
			AAdd( aTotais,{ IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ), "Compens.", nFilComp } )
		Endif
		If nFilFat > 0
			AAdd( aTotais,{ IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ), "Compens.", nFilFat } )
		Endif

		If Empty(xFilial("SE5"))
			Exit
		Endif

		//nFilOrig:=nFilJurMul:=nFilCM:=nFilDesc:=nFilAbLiq:=nFilAbImp:=nFilValor:=0
		nFilOrig:=nFilIRRF:=nFilCOFI:=nFilPIS:=nFilCSLL:=nFilAbImp:=nFilValor:=0
		nFilBaixado:=nFilMovFin:=nFilComp:=nFilFat:=0
		nFilISS:=nFilINSS:=0
	Endif
	dbSelectArea("SM0")
	cCodUlt := SM0->M0_CODIGO
	cFilUlt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	dbSkip()
Enddo

If nGerBaixado > 0
	AAdd(aTotais,{"Geral","Baixados",nGerBaixado})
Endif
If nGerMovFin > 0
	AAdd(aTotais,{"Geral","Mov.Fin.",nGerMovFin})
Endif
If nGerComp > 0
	AAdd(aTotais,{"Geral","Compens.",nGerComp})
EndIf
If nGerFat > 0
	AAdd(aTotais,{"Geral","Bx.Fatura",nGerFat})
EndIf

SM0->(dbgoto(nRecEmp))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
dbSelectArea("TRB")
dbCloseArea()
Ferase(cNomArq1+GetDBExtension())
dbSelectArea("NEWSE5")
dbCloseArea()
If cNomeArq # Nil
	Ferase(cNomeArq+OrdBagExt())
Endif
dbSelectArea("SE5")
dbSetOrder(1)

Return aRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FR190MovCan� Autor � Marcelo Celi Marques � Data � 05.10.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o registro selecionado pertente a um titulo    ���
���          � cuja baixa foi cancelada, mas, que gerou mov bancario      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FR190MovCan(nIndexSE5,_SE5)								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nIndexSE5 - Filtro provis�rio criado no inicio da rotina	  ���
���          � E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ    >>	  ���
���          � +E5_TIPODOC+E5_SEQ                                   	  ���
���          � 															  ���
���          � _SE5 - Nome da tabela tempor�ria do SE5 gerada       	  ���
���          � no inicio da rotina										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINR190/FINR199											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FR190MovCan(nIndexSE5,_SE5)

Local lRet := .F.
Local aAreaSE5 := (_SE5)->(GetArea())

If Empty((_SE5)->E5_MOTBX)
	dbSelectArea("SE5")
	dbSetOrder(nIndexSE5+1)
	If dbSeek((_SE5)->(E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+"EC"+E5_SEQ))
		lRet := .T.
	Endif
	dbSelectArea(_SE5)
	RestArea(aAreaSE5)
Endif

Return lRet
