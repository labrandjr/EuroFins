#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR320  � Autor � Nereu Humberto Junior � Data � 30/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Resumo das entradas e saidas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} MyMATR320
Resumo das entradas e saidas
@author Nereu Humberto Junior
@since 02/01/2018
/*/
User Function MyMATR320()

Local oReport
Local nOpc := Aviso("Informa��o","Informe o formato do relat�rio ...",{"Sem C.Cust.","Com C.Cust."},2,"Detalhamento das Requisi��es Internas")

If nOpc == 1
	oReport:=ReportDef()
Else
	oReport:=Report2Def()
Endif

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport:PrintDialog()

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Nereu Humberto Junior  � Data �23.06.2006���
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

Local oReport
Local oSection1
Local oCell
Local cTamVlr  := 20
Local cPictVl  := PesqPict("SD2","D2_CUSTO1",20)
//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao do fonte        �
//� SIGACUSA.PRX aplicados no rpo do cliente, assim verificando     |
//| a necessidade de uma atualizacao nestes fontes. NAO REMOVER !!!	�
//�������������������������������������������������������������������
If !(FindFunction("SIGACUSA_V") .And. SIGACUSA_V() >= 20060321)
    Final("Atualizar SIGACUSA.PRX !!!")
EndIf

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
oReport:= TReport():New("MyMATR320","Detalhamento das Requisicoes Internas","MTR320", {|oReport| ReportPrint(oReport)},"Este programa mostra o detalhamento do Tipo de material (por Sub Grupo), verificando suas Requisi��es Internas.")
oReport:SetPortrait()
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Almoxarifado De                              �
//� mv_par02     // Almoxarifado Ate                             �
//� mv_par03     // Tipo inicial                                 �
//� mv_par04     // Tipo final                                   �
//� mv_par05     // Produto inicial                              �
//� mv_par06     // Produto Final                                �
//� mv_par07     // Emissao de                                   �
//� mv_par08     // Emissao ate                                  �
//� mv_par09     // moeda selecionada ( 1 a 5 )                  �
//� mv_par10     // Saldo a considerar : Atual / Fechamento      �
//� mv_par11     // Considera Saldo MOD: Sim / Nao               �
//� mv_par12     // Imprime OPs geradas pelo SIGAMNT? Sim / Nao  �
//����������������������������������������������������������������
Pergunte("MTR320",.F.)

oSection1 := TRSection():New(oReport,"Movimentacoes dos Produtos",{"SB1","SD1","SD2","SD3"})
oSection1 :SetTotalInLine(.F.)
oSection1 :SetNoFilter("SD1")
oSection1 :SetNoFilter("SD2")
oSection1 :SetNoFilter("SD3")

TRCell():New(oSection1,"B1_TIPO"	,"SB1","Tipo"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"cSubGAnt"	,"   ",/*Titulo*/			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("cSubGAnt"):GetFieldInfo("B1_ZZSUBGR")
TRCell():New(oSection1,"cDescri","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| ImpDescri(cSubGAnt) })
oSection1:Cell("cDescri"):GetFieldInfo("B1_DESC")
TRCell():New(oSection1,"nReqCons"	,"   ","Movimentacoes"+CRLF+"Internas"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRFunction():New(oSection1:Cell("nReqCons"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Nereu Humberto Junior  � Data �21.06.2006���
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
Static Function ReportPrint(oReport,cAliasSDH)

Local oSection1:= oReport:Section(1)
Local cSelectD1 := '', cWhereD1 := ''
Local cSelectD2 := '', cWhereD2 := ''
Local cSelectD3 := '', cWhereD3 := ''
Local cSelectB2 := '', cWhereB2 := ''
Local lContinua :=.T.
Local lPassou   :=.F.
Local nValor    := 0
Local cProduto  := ""
Local cFiltroUsr:= ""
Local nReqCons
Local cSelect	:= ''
Local cSelect1	:= ''
Local aStrucSB1 := SB1->(dbStruct())
Local cName		:= ""
Local nX        := 0


#IFNDEF TOP
	Local cCondicao := ""
#ELSE
	Local cAliasTop := ""
#ENDIF

cMoeda := LTrim(Str(mv_par09))
cMoeda := IIF(cMoeda=="0","1",cMoeda)
oReport:SetTitle( oReport:Title()+" EM "+AllTrim(GetMv("MV_SIMB"+cMoeda))+" - "+"Per�odo de "+dtoc(mv_par07,"ddmmyy")+" At� "+dtoc(mv_par08,"ddmmyy"))

oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

cFiltroUsr := oSection1:GetAdvplExp()

dbSelectArea("SD2")
dbSetOrder(1)
nRegs := SD2->(LastRec())

dbSelectArea("SD3")
dbSetOrder(1)
nRegs += SD3->(LastRec())

dbSelectArea("SD1")
dbSetOrder(1)
nRegs += SD1->(LastRec())

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)

cAliasTop := GetNextAlias()

//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao 1                                           �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

//�������������������������������������������������������������������Ŀ
//�Esta rotina foi escrita para adicionar no select os campos         �
//�usados no filtro do usuario quando houver, a rotina acrecenta      �
//�somente os campos que forem adicionados ao filtro testando         �
//�se os mesmo j� existem no select ou se forem definidos novamente   �
//�pelo o usuario no filtro, esta rotina acrecenta o minimo possivel  �
//�de campos no select pois pelo fato da tabela SD1 ter muitos campos |
//�e a query ter UNION, ao adicionar todos os campos do SD1 podera'   |
//�derrubar o TOP CONNECT e abortar o sistema.                        |
//���������������������������������������������������������������������
cSelect  := "B1_COD,B1_TIPO,B1_UM,B1_GRUPO,B1_DESC,B1_ZZSUBGR,"
cSelect1 := "%"
cSelect2 := "%"
oSection1:GetAdvplExp()
If !Empty(cFiltroUsr)
	For nX := 1 To SB1->(FCount())
		cName := SB1->(FieldName(nX))
	 	If AllTrim( cName ) $ cFiltroUsr
      		If aStrucSB1[nX,2] <> "M"
      			If !cName $ cSelect
	        		cSelect1 += cName + ","
	          	EndIf
	       	EndIf
		EndIf
	Next
	cSelect1 += "%"
Endif

//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabela SD1                                     �
//��������������������������������������������������������������������������
cSelectD1 := "% D1_CUSTO"
If mv_par09 > 1
	cSelectD1 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
EndIf
cSelectD1 += " CUSTO,"
cSelectD1 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do WHERE da tabela SD1                                      �
//��������������������������������������������������������������������������
cWhereD1 := "%"
If cPaisLoc <> "BRA"
	cWhereD1 += " AND D1_REMITO = '" + Space(TamSx3("D1_REMITO")[1]) + "' "
EndIf
cWhereD1 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabela SD2                                     �
//��������������������������������������������������������������������������
cSelectD2 := "% D2_CUSTO"
cSelectD2 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
cSelectD2 += " CUSTO,"
cSelectD2 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do WHERE da tabela SD2                                      �
//��������������������������������������������������������������������������
cWhereD2 := "%"
If cPaisLoc <> "BRA"
	cWhereD2 += " AND D2_REMITO = '" + Space(TamSx3("D2_REMITO")[1]) + "' "
EndIf
cWhereD2 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabelas SD3                                    �
//��������������������������������������������������������������������������
cSelectD3 := "% D3_CUSTO"
cSelectD3 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
cSelectD3 += " CUSTO,"
cSelectD3 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do WHERE da tabela SD3                                      �
//��������������������������������������������������������������������������
cWhereD3 := "%"
If SuperGetMV('MV_D3ESTOR', .F., 'N') == 'N'
	cWhereD3 += " AND D3_ESTORNO <> 'S'"
EndIf
If SuperGetMV('MV_D3SERVI', .F., 'N') == 'N' .And. IntDL()
	cWhereD3 += " AND ( (D3_SERVIC = '   ') OR (D3_SERVIC <> '   ' AND D3_TM <= '500')  "
	cWhereD3 += " OR  (D3_SERVIC <> '   ' AND D3_TM > '500' AND D3_LOCAL ='"+SuperGetMV('MV_CQ', .F., '98')+"') )"
EndIf
cWhereD3 += "%"

BeginSql Alias cAliasTop

		SELECT 	'SD1' ARQ, 				//-- 01 ARQ
				 SB1.B1_COD PRODUTO, 	//-- 02 PRODUTO
				 SB1.B1_TIPO, 			//-- 03 TIPO
				 SB1.B1_UM,   			//-- 04 UM
				 SB1.B1_GRUPO,      	//-- 05 GRUPO
				 SB1.B1_DESC,      		//-- 06 DESCR
				 SB1.B1_ZZSUBGR,
 				 %Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				 D1_DTDIGIT DATA,		//-- 08 DATA
				 D1_TES TES,			//-- 09 TES
				 D1_CF CF,				//-- 10 CF
				 D1_NUMSEQ SEQUENCIA,	//-- 11 SEQUENCIA
				 D1_DOC DOCUMENTO,		//-- 12 DOCUMENTO
				 D1_SERIE SERIE,		//-- 13 SERIE
				 D1_QUANT QUANTIDADE,	//-- 14 QUANTIDADE
				 D1_QTSEGUM QUANT2UM,	//-- 15 QUANT2UM
				 D1_LOCAL ARMAZEM,		//-- 16 ARMAZEM
				 ' ' OP,				//-- 17 OP
				 D1_FORNECE FORNECEDOR,	//-- 18 FORNECEDOR
				 D1_LOJA LOJA,			//-- 19 LOJA
				 D1_TIPO TIPONF,		//-- 20 TIPO NF
				 %Exp:cSelectD1%		//-- 21 CUSTO / 21 B1_CODITE
				 SD1.R_E_C_N_O_ NRECNO  //-- 22 RECNO

		FROM %table:SB1% SB1,%table:SD1% SD1,%table:SF4% SF4

		WHERE SB1.B1_COD     =  SD1.D1_COD		AND  	SD1.D1_FILIAL  =  %xFilial:SD1%		AND
			  SF4.F4_FILIAL  =  %xFilial:SF4%  	AND 	SD1.D1_TES     =  SF4.F4_CODIGO		AND
			  SF4.F4_ESTOQUE =  'S'				AND 	SD1.D1_DTDIGIT >= %Exp:mv_par07%   AND
			  SD1.D1_DTDIGIT <= %Exp:mv_par08%	AND		SD1.D1_ORIGLAN <> 'LF'				AND
			  SD1.D1_LOCAL   >= %Exp:mv_par01%	AND		SD1.D1_LOCAL   <= %Exp:mv_par02%	AND
			  SD1.%NotDel%						AND 	SF4.%NotDel%                        AND
	          SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD     <= %Exp:mv_par06% 	AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND		SB1.B1_TIPO    >= %Exp:mv_par03%	AND
			  SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
			  %Exp:cWhereD1%

	    UNION

		SELECT 'SD2',	     			//-- 01 ARQ
				SB1.B1_COD,	        	//-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,		    //-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				SB1.B1_ZZSUBGR,
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				D2_EMISSAO,				//-- 08 DATA
				D2_TES,					//-- 09 TES
				D2_CF,					//-- 10 CF
				D2_NUMSEQ,				//-- 11 SEQUENCIA
				D2_DOC,					//-- 12 DOCUMENTO
				D2_SERIE,				//-- 13 SERIE
				D2_QUANT,				//-- 14 QUANTIDADE
				D2_QTSEGUM,				//-- 15 QUANT2UM
				D2_LOCAL,				//-- 16 ARMAZEM
				' ',					//-- 17 OP
				D2_CLIENTE,				//-- 18 FORNECEDOR
				D2_LOJA,				//-- 19 LOJA
				D2_TIPO,				//-- 20 TIPO NF
				%Exp:cSelectD2%			//-- 21 CUSTO
				SD2.R_E_C_N_O_ SD2RECNO //-- 22 RECNO

		FROM %table:SB1% SB1,%table:SD2% SD2,%table:SF4% SF4

		WHERE	SB1.B1_COD     =  SD2.D2_COD		AND	SD2.D2_FILIAL  = %xFilial:SD2%		AND
				SF4.F4_FILIAL  = %xFilial:SF4% 		AND	SD2.D2_TES     =  SF4.F4_CODIGO		AND
				SF4.F4_ESTOQUE =  'S'				AND	SD2.D2_EMISSAO >= %Exp:mv_par07%	AND
				SD2.D2_EMISSAO <= %Exp:mv_par08%	AND	SD2.D2_ORIGLAN <> 'LF'				AND
				SD2.D2_LOCAL   >= %Exp:mv_par01%	AND	SD2.D2_LOCAL   <= %Exp:mv_par02%	AND
				SD2.%NotDel%						AND SF4.%NotDel%						AND
		        SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
  				%Exp:cWhereD2%

		UNION

		SELECT 	'SD3',	    			//-- 01 ARQ
				SB1.B1_COD,	    	    //-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,	     	//-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				SB1.B1_ZZSUBGR,
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				D3_EMISSAO,				//-- 08 DATA
				D3_TM TES,				//-- 09 TES
				D3_CF,					//-- 10 CF
				D3_NUMSEQ,				//-- 11 SEQUENCIA
				D3_DOC,					//-- 12 DOCUMENTO
				' ',					//-- 13 SERIE
				D3_QUANT,				//-- 14 QUANTIDADE
				D3_QTSEGUM,				//-- 15 QUANT2UM
				D3_LOCAL,				//-- 16 ARMAZEM
				D3_OP,					//-- 17 OP
				' ',					//-- 18 FORNECEDOR
				' ',					//-- 19 LOJA
				' ',					//-- 20 TIPO NF
				%Exp:cSelectD3%			//-- 21 CUSTO
				SD3.R_E_C_N_O_ SD3RECNO //-- 22 RECNO

		FROM %table:SB1% SB1,%table:SD3% SD3

		WHERE	SB1.B1_COD     =  SD3.D3_COD 		AND SD3.D3_FILIAL  =  %xFilial:SD3%		AND
				SD3.D3_EMISSAO >= %Exp:mv_par07%	AND	SD3.D3_EMISSAO <= %Exp:mv_par08%	AND
				SD3.D3_LOCAL   >= %Exp:mv_par01%	AND	SD3.D3_LOCAL   <= %Exp:mv_par02%	AND
				SD3.%NotDel%						                                   		AND
		        SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
				%Exp:cWhereD3%

		/*UNION

		SELECT 	'SB1',			     	//-- 01 ARQ
				SB1.B1_COD,	    	    //-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,		    //-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				SB1.B1_ZZSUBGR,
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				' ',					//-- 08 DATA
				' ',					//-- 09 TES
				' ',					//-- 10 CF
				' ',					//-- 11 SEQUENCIA
				' ',					//-- 12 DOCUMENTO
				' ',					//-- 13 SERIE
				0,						//-- 14 QUANTIDADE
				0,						//-- 15 QUANT2UM
				' ',	    			//-- 16 ARMAZEM
				' ',					//-- 17 OP
				' ',					//-- 18 FORNECEDOR
				' ',					//-- 19 LOJA
				' ',					//-- 20 TIPO NF
				0,						//-- 21 CUSTO
				0						//-- 22 RECNO

		FROM %table:SB1% SB1

		WHERE   SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
	*/
		ORDER BY 7,2,1

EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relatorio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relatorio                               �
//��������������������������������������������������������������������������
dbSelectArea(cAliasTop)
oReport:SetMeter(nRegs)

oSection1:Init()

While !oReport:Cancel() .And. !(cAliasTop)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Filtro de Usuario                                            �
	//����������������������������������������������������������������
	If !Empty(cFiltroUsr)
	    If !(&cFiltroUsr)
			dbSelectArea(cAliasTop)
			dbSkip()
			Loop
		EndIf
	EndIf

	cSubGAnt := (cAliasTop)->B1_ZZSUBGR
	oSection1:Cell("cSubGAnt"):SetValue(cSubGAnt)

	Store 0 To nReqCons
	lPassou := .F.

	While !oReport:Cancel() .And. !(cAliasTop)->(Eof()) .And. (cAliasTop)->B1_ZZSUBGR == cSubGAnt

		If oReport:Cancel()
			Exit
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Filtro de Usuario                                            �
		//����������������������������������������������������������������
		If !Empty(cFiltroUsr)
		    If !(&cFiltroUsr)
				dbSelectArea(cAliasTop)
				dbSkip()
				Loop
			EndIf
		EndIf

        cProduto  := (cAliasTop)->PRODUTO

		oReport:IncMeter()

		//��������������������������������������������������������������Ŀ
		//� SB1 - Verifica Produtos Sem Movimento						 �
		//����������������������������������������������������������������
		If Alltrim((cAliasTop)->ARQ) == "SB1"
			dbSkip()
			Loop
		EndIf

		//��������������������������������������������������������������Ŀ
		//� SD1 - Verifica Produtos Sem Movimento						 �
		//����������������������������������������������������������������
		If Alltrim((cAliasTop)->ARQ) == "SD1"
			dbSkip()
			Loop
		EndIf

		//��������������������������������������������������������������Ŀ
		//� SD2 - Verifica Produtos Sem Movimento						 �
		//����������������������������������������������������������������
		If Alltrim((cAliasTop)->ARQ) == "SD2"
			dbSkip()
			Loop
		EndIf

		//��������������������������������������������������������������Ŀ
		//� SD3 - Pesquisa requisicoes                                   �
		//����������������������������������������������������������������
		While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SD3"

			nValor := (cAliasTop)->CUSTO

			If (cAliasTop)->TES > "500"
				nValor := nValor*-1
			EndIf

			If Empty((cAliasTop)->OP) .And. Substr((cAliasTop)->CF,3,1) != "3"
				nReqCons += nValor
			EndIf
			lPassou := .T.
			dbSkip()

		EndDo

		dbSelectArea(cAliasTop)

	EndDo

	If lPassou
		oSection1:Cell("cDescri"):SetSize(50)
		oSection1:Cell("nReqCons"):SetValue(nReqCons)
		oSection1:PrintLine()
	EndIf

	dbSelectArea(cAliasTop)

EndDo

oSection1:Finish()

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ImpDescri �Autor�Nereu Humberto Junior � Data � 12/06/2006  ���
�������������������������������������������������������������������������͹��
���Uso       � MATR120                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpDescri(cSubGAnt)

Local aArea   := GetArea()
Local cDescri := ""

dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"Z7"+cSubGAnt)
cDescri := Alltrim(SX5->X5_DESCRI)

RestArea(aArea)

Return(cDescri)




/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Nereu Humberto Junior  � Data �23.06.2006���
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
Static Function Report2Def()

Local oReport
Local oSection1
Local oCell
Local cTamVlr  := 20
Local cPictVl  := PesqPict("SD2","D2_CUSTO1",20)
//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao do fonte        �
//� SIGACUSA.PRX aplicados no rpo do cliente, assim verificando     |
//| a necessidade de uma atualizacao nestes fontes. NAO REMOVER !!!	�
//�������������������������������������������������������������������
If !(FindFunction("SIGACUSA_V") .And. SIGACUSA_V() >= 20060321)
    Final("Atualizar SIGACUSA.PRX !!!")
EndIf

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
oReport:= TReport():New("MyMATR320","Detalhamento das Requisicoes Internas","MTR320", {|oReport| Report2Print(oReport)},"Este programa mostra o detalhamento do Tipo de material (por Sub Grupo), verificando suas Requisi��es Internas.")
oReport:SetPortrait()
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Almoxarifado De                              �
//� mv_par02     // Almoxarifado Ate                             �
//� mv_par03     // Tipo inicial                                 �
//� mv_par04     // Tipo final                                   �
//� mv_par05     // Produto inicial                              �
//� mv_par06     // Produto Final                                �
//� mv_par07     // Emissao de                                   �
//� mv_par08     // Emissao ate                                  �
//� mv_par09     // moeda selecionada ( 1 a 5 )                  �
//� mv_par10     // Saldo a considerar : Atual / Fechamento      �
//� mv_par11     // Considera Saldo MOD: Sim / Nao               �
//� mv_par12     // Imprime OPs geradas pelo SIGAMNT? Sim / Nao  �
//����������������������������������������������������������������
Pergunte("MTR320",.F.)

oSection1 := TRSection():New(oReport,"Movimentacoes dos Produtos",{"SB1","SD1","SD2","SD3"})
oSection1 :SetTotalInLine(.F.)
oSection1 :SetNoFilter("SD1")
oSection1 :SetNoFilter("SD2")
oSection1 :SetNoFilter("SD3")

TRCell():New(oSection1,"B1_TIPO"	,"SB1","Tipo"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection1,"cSubGAnt"	,"   ",/*Titulo*/			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("cSubGAnt"):GetFieldInfo("B1_ZZSUBGR")

TRCell():New(oSection1,"cDescri","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| ImpDescri(cSubGAnt) })
oSection1:Cell("cDescri"):GetFieldInfo("B1_DESC")
oSection1:Cell("cDescri"):SetSize(50)

TRCell():New(oSection1,"cCCAnt"	,"   ","Centro de Custo",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("cCCAnt"):GetFieldInfo("D3_CC")
oSection1:Cell("cCCAnt"):SetSize(20)

TRCell():New(oSection1,"nReqCons"	,"   ","Movimentacoes"+CRLF+"Internas"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRFunction():New(oSection1:Cell("nReqCons"),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Nereu Humberto Junior  � Data �21.06.2006���
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
Static Function Report2Print(oReport,cAliasSDH)

Local oSection1:= oReport:Section(1)
Local cSelectD1 := '', cWhereD1 := ''
Local cSelectD2 := '', cWhereD2 := ''
Local cSelectD3 := '', cWhereD3 := ''
Local cSelectB2 := '', cWhereB2 := ''
Local lContinua :=.T.
Local lPassou   :=.F.
Local nValor    := 0
Local cProduto  := ""
Local cFiltroUsr:= ""
Local nReqCons
Local cSelect	:= ''
Local cSelect1	:= ''
Local aStrucSB1 := SB1->(dbStruct())
Local cName		:= ""
Local nX        := 0


#IFNDEF TOP
	Local cCondicao := ""
#ELSE
	Local cAliasTop := ""
#ENDIF

cMoeda := LTrim(Str(mv_par09))
cMoeda := IIF(cMoeda=="0","1",cMoeda)
oReport:SetTitle( oReport:Title()+" EM "+AllTrim(GetMv("MV_SIMB"+cMoeda))+" - "+"Per�odo de "+dtoc(mv_par07,"ddmmyy")+" At� "+dtoc(mv_par08,"ddmmyy"))

oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

cFiltroUsr := oSection1:GetAdvplExp()

dbSelectArea("SD2")
dbSetOrder(1)
nRegs := SD2->(LastRec())

dbSelectArea("SD3")
dbSetOrder(1)
nRegs += SD3->(LastRec())

dbSelectArea("SD1")
dbSetOrder(1)
nRegs += SD1->(LastRec())

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)

cAliasTop := GetNextAlias()

//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao 1                                           �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

//�������������������������������������������������������������������Ŀ
//�Esta rotina foi escrita para adicionar no select os campos         �
//�usados no filtro do usuario quando houver, a rotina acrecenta      �
//�somente os campos que forem adicionados ao filtro testando         �
//�se os mesmo j� existem no select ou se forem definidos novamente   �
//�pelo o usuario no filtro, esta rotina acrecenta o minimo possivel  �
//�de campos no select pois pelo fato da tabela SD1 ter muitos campos |
//�e a query ter UNION, ao adicionar todos os campos do SD1 podera'   |
//�derrubar o TOP CONNECT e abortar o sistema.                        |
//���������������������������������������������������������������������
cSelect  := "B1_COD,B1_TIPO,B1_UM,B1_GRUPO,B1_DESC,B1_ZZSUBGR,"
cSelect1 := "%"
cSelect2 := "%"
oSection1:GetAdvplExp()
If !Empty(cFiltroUsr)
	For nX := 1 To SB1->(FCount())
		cName := SB1->(FieldName(nX))
	 	If AllTrim( cName ) $ cFiltroUsr
      		If aStrucSB1[nX,2] <> "M"
      			If !cName $ cSelect
	        		cSelect1 += cName + ","
	          	EndIf
	       	EndIf
		EndIf
	Next
	cSelect1 += "%"
Endif

//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabela SD1                                     �
//��������������������������������������������������������������������������
cSelectD1 := "% D1_CUSTO"
If mv_par09 > 1
	cSelectD1 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
EndIf
cSelectD1 += " CUSTO,"
cSelectD1 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do WHERE da tabela SD1                                      �
//��������������������������������������������������������������������������
cWhereD1 := "%"
If cPaisLoc <> "BRA"
	cWhereD1 += " AND D1_REMITO = '" + Space(TamSx3("D1_REMITO")[1]) + "' "
EndIf
cWhereD1 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabela SD2                                     �
//��������������������������������������������������������������������������
cSelectD2 := "% D2_CUSTO"
cSelectD2 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
cSelectD2 += " CUSTO,"
cSelectD2 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do WHERE da tabela SD2                                      �
//��������������������������������������������������������������������������
cWhereD2 := "%"
If cPaisLoc <> "BRA"
	cWhereD2 += " AND D2_REMITO = '" + Space(TamSx3("D2_REMITO")[1]) + "' "
EndIf
cWhereD2 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabelas SD3                                    �
//��������������������������������������������������������������������������
cSelectD3 := "% D3_CUSTO"
cSelectD3 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
cSelectD3 += " CUSTO,"
cSelectD3 += "%"

//������������������������������������������������������������������������Ŀ
//�Complemento do WHERE da tabela SD3                                      �
//��������������������������������������������������������������������������
cWhereD3 := "%"
If SuperGetMV('MV_D3ESTOR', .F., 'N') == 'N'
	cWhereD3 += " AND D3_ESTORNO <> 'S'"
EndIf
If SuperGetMV('MV_D3SERVI', .F., 'N') == 'N' .And. IntDL()
	cWhereD3 += " AND ( (D3_SERVIC = '   ') OR (D3_SERVIC <> '   ' AND D3_TM <= '500')  "
	cWhereD3 += " OR  (D3_SERVIC <> '   ' AND D3_TM > '500' AND D3_LOCAL ='"+SuperGetMV('MV_CQ', .F., '98')+"') )"
EndIf
cWhereD3 += " AND SUBSTRING(D3_CF,3,1) <> '4'"
cWhereD3 += "%"



BeginSql Alias cAliasTop

		SELECT 	'SD1' ARQ, 				//-- 01 ARQ
				 SB1.B1_COD PRODUTO, 	//-- 02 PRODUTO
				 SB1.B1_TIPO, 			//-- 03 TIPO
				 SB1.B1_UM,   			//-- 04 UM
				 SB1.B1_GRUPO,      	//-- 05 GRUPO
				 SB1.B1_DESC,      		//-- 06 DESCR
				 SB1.B1_ZZSUBGR,
				 D1_CC CCUSTO,
 				 %Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				 D1_DTDIGIT DATA,		//-- 08 DATA
				 D1_TES TES,			//-- 09 TES
				 D1_CF CF,				//-- 10 CF
				 D1_NUMSEQ SEQUENCIA,	//-- 11 SEQUENCIA
				 D1_DOC DOCUMENTO,		//-- 12 DOCUMENTO
				 D1_SERIE SERIE,		//-- 13 SERIE
				 D1_QUANT QUANTIDADE,	//-- 14 QUANTIDADE
				 D1_QTSEGUM QUANT2UM,	//-- 15 QUANT2UM
				 D1_LOCAL ARMAZEM,		//-- 16 ARMAZEM
				 ' ' OP,				//-- 17 OP
				 D1_FORNECE FORNECEDOR,	//-- 18 FORNECEDOR
				 D1_LOJA LOJA,			//-- 19 LOJA
				 D1_TIPO TIPONF,		//-- 20 TIPO NF
				 %Exp:cSelectD1%		//-- 21 CUSTO / 21 B1_CODITE
				 SD1.R_E_C_N_O_ NRECNO  //-- 22 RECNO

		FROM %table:SB1% SB1,%table:SD1% SD1,%table:SF4% SF4

		WHERE SB1.B1_COD     =  SD1.D1_COD		AND  	SD1.D1_FILIAL  =  %xFilial:SD1%		AND
			  SF4.F4_FILIAL  =  %xFilial:SF4%  	AND 	SD1.D1_TES     =  SF4.F4_CODIGO		AND
			  SF4.F4_ESTOQUE =  'S'				AND 	SD1.D1_DTDIGIT >= %Exp:mv_par07%   AND
			  SD1.D1_DTDIGIT <= %Exp:mv_par08%	AND		SD1.D1_ORIGLAN <> 'LF'				AND
			  SD1.D1_LOCAL   >= %Exp:mv_par01%	AND		SD1.D1_LOCAL   <= %Exp:mv_par02%	AND
			  SD1.%NotDel%						AND 	SF4.%NotDel%                        AND
	          SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD     <= %Exp:mv_par06% 	AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND		SB1.B1_TIPO    >= %Exp:mv_par03%	AND
			  SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
			  %Exp:cWhereD1%

	    UNION

		SELECT 'SD2',	     			//-- 01 ARQ
				SB1.B1_COD,	        	//-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,		    //-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				SB1.B1_ZZSUBGR,
				D2_CCUSTO CCUSTO,
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				D2_EMISSAO,				//-- 08 DATA
				D2_TES,					//-- 09 TES
				D2_CF,					//-- 10 CF
				D2_NUMSEQ,				//-- 11 SEQUENCIA
				D2_DOC,					//-- 12 DOCUMENTO
				D2_SERIE,				//-- 13 SERIE
				D2_QUANT,				//-- 14 QUANTIDADE
				D2_QTSEGUM,				//-- 15 QUANT2UM
				D2_LOCAL,				//-- 16 ARMAZEM
				' ',					//-- 17 OP
				D2_CLIENTE,				//-- 18 FORNECEDOR
				D2_LOJA,				//-- 19 LOJA
				D2_TIPO,				//-- 20 TIPO NF
				%Exp:cSelectD2%			//-- 21 CUSTO
				SD2.R_E_C_N_O_ SD2RECNO //-- 22 RECNO

		FROM %table:SB1% SB1,%table:SD2% SD2,%table:SF4% SF4

		WHERE	SB1.B1_COD     =  SD2.D2_COD		AND	SD2.D2_FILIAL  = %xFilial:SD2%		AND
				SF4.F4_FILIAL  = %xFilial:SF4% 		AND	SD2.D2_TES     =  SF4.F4_CODIGO		AND
				SF4.F4_ESTOQUE =  'S'				AND	SD2.D2_EMISSAO >= %Exp:mv_par07%	AND
				SD2.D2_EMISSAO <= %Exp:mv_par08%	AND	SD2.D2_ORIGLAN <> 'LF'				AND
				SD2.D2_LOCAL   >= %Exp:mv_par01%	AND	SD2.D2_LOCAL   <= %Exp:mv_par02%	AND
				SD2.%NotDel%						AND SF4.%NotDel%						AND
		        SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
  				%Exp:cWhereD2%

		UNION

		SELECT 	'SD3',	    			//-- 01 ARQ
				SB1.B1_COD,	    	    //-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,	     	//-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				SB1.B1_ZZSUBGR,
				D3_CC CCUSTO,
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				D3_EMISSAO,				//-- 08 DATA
				D3_TM TES,				//-- 09 TES
				D3_CF,					//-- 10 CF
				D3_NUMSEQ,				//-- 11 SEQUENCIA
				D3_DOC,					//-- 12 DOCUMENTO
				' ',					//-- 13 SERIE
				D3_QUANT,				//-- 14 QUANTIDADE
				D3_QTSEGUM,				//-- 15 QUANT2UM
				D3_LOCAL,				//-- 16 ARMAZEM
				D3_OP,					//-- 17 OP
				' ',					//-- 18 FORNECEDOR
				' ',					//-- 19 LOJA
				' ',					//-- 20 TIPO NF
				%Exp:cSelectD3%			//-- 21 CUSTO
				SD3.R_E_C_N_O_ SD3RECNO //-- 22 RECNO

		FROM %table:SB1% SB1,%table:SD3% SD3

		WHERE	SB1.B1_COD     =  SD3.D3_COD 		AND SD3.D3_FILIAL  =  %xFilial:SD3%		AND
				SD3.D3_EMISSAO >= %Exp:mv_par07%	AND	SD3.D3_EMISSAO <= %Exp:mv_par08%	AND
				SD3.D3_LOCAL   >= %Exp:mv_par01%	AND	SD3.D3_LOCAL   <= %Exp:mv_par02%	AND
				SD3.%NotDel%						                                   		AND
		        SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
				%Exp:cWhereD3%

		/*UNION

		SELECT 	'SB1',			     	//-- 01 ARQ
				SB1.B1_COD,	    	    //-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,		    //-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				SB1.B1_ZZSUBGR,
				' ',
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				' ',					//-- 08 DATA
				' ',					//-- 09 TES
				' ',					//-- 10 CF
				' ',					//-- 11 SEQUENCIA
				' ',					//-- 12 DOCUMENTO
				' ',					//-- 13 SERIE
				0,						//-- 14 QUANTIDADE
				0,						//-- 15 QUANT2UM
				' ',	    			//-- 16 ARMAZEM
				' ',					//-- 17 OP
				' ',					//-- 18 FORNECEDOR
				' ',					//-- 19 LOJA
				' ',					//-- 20 TIPO NF
				0,						//-- 21 CUSTO
				0						//-- 22 RECNO

		FROM %table:SB1% SB1

		WHERE   SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
	*/
		ORDER BY 7,8,2,1

EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relatorio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relatorio                               �
//��������������������������������������������������������������������������
dbSelectArea(cAliasTop)
oReport:SetMeter(nRegs)

oSection1:Init()

While !oReport:Cancel() .And. !(cAliasTop)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Filtro de Usuario                                            �
	//����������������������������������������������������������������
	If !Empty(cFiltroUsr)
	    If !(&cFiltroUsr)
			dbSelectArea(cAliasTop)
			dbSkip()
			Loop
		EndIf
	EndIf
		//msgyesno("teste5")
	cSubGAnt := (cAliasTop)->B1_ZZSUBGR
	cCCAnt   := (cAliasTop)->CCUSTO
	oSection1:Cell("cSubGAnt"):SetValue(cSubGAnt)

	Store 0 To nReqCons
	lPassou := .F.

	While !oReport:Cancel() .And. !(cAliasTop)->(Eof()) .And. (cAliasTop)->B1_ZZSUBGR+(cAliasTop)->CCUSTO == cSubGAnt+cCCAnt

		If oReport:Cancel()
			Exit
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Filtro de Usuario                                            �
		//����������������������������������������������������������������
		If !Empty(cFiltroUsr)
		    If !(&cFiltroUsr)
				dbSelectArea(cAliasTop)
				dbSkip()
				Loop
			EndIf
		EndIf

        //cProduto  := (cAliasTop)->PRODUTO

		oReport:IncMeter()

		//��������������������������������������������������������������Ŀ
		//� SB1 - Verifica Produtos Sem Movimento						 �
		//����������������������������������������������������������������
		If Alltrim((cAliasTop)->ARQ) == "SB1"
			dbSkip()
			Loop
		EndIf

		//��������������������������������������������������������������Ŀ
		//� SD1 - Verifica Produtos Sem Movimento						 �
		//����������������������������������������������������������������
		If Alltrim((cAliasTop)->ARQ) == "SD1"
			dbSkip()
			Loop
		EndIf

		//��������������������������������������������������������������Ŀ
		//� SD2 - Verifica Produtos Sem Movimento						 �
		//����������������������������������������������������������������
		If Alltrim((cAliasTop)->ARQ) == "SD2"
			dbSkip()
			Loop
		EndIf

		//��������������������������������������������������������������Ŀ
		//� SD3 - Pesquisa requisicoes                                   �
		//����������������������������������������������������������������
		While !Eof() .And. Alltrim((cAliasTop)->ARQ) == "SD3" .and. (cAliasTop)->B1_ZZSUBGR+(cAliasTop)->CCUSTO == cSubGAnt+cCCAnt

			nValor := (cAliasTop)->CUSTO

			If (cAliasTop)->TES > "500"
				nValor := nValor*-1
			EndIf

			If Empty((cAliasTop)->OP) .And. Substr((cAliasTop)->CF,3,1) != "3"
				nReqCons += nValor
			EndIf
			lPassou := .T.
			dbSkip()

		EndDo

		dbSelectArea(cAliasTop)

	EndDo

	If lPassou
		oSection1:Cell("cCCAnt"):SetValue(cCCAnt)
		oSection1:Cell("nReqCons"):SetValue(nReqCons)
		oSection1:PrintLine()
	EndIf

	dbSelectArea(cAliasTop)

EndDo

oSection1:Finish()

Return NIL