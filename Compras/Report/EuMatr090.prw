#INCLUDE "MYMATR090.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MyMatr090
Emiss�o da rela��o de compras
@author Unknown
@since 29/12/2017

/*/
User Function EuMatr090()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//����������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                �
	//������������������������������������������������������������������������
	oReport:= ReportDef()
	oReport:PrintDialog()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ReportDef�Autor  �Alexandre Inacio Lemes �Data  �06/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da rela��o de Compras                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oExpO1: Objeto do relatorio                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local aOrdem   := {STR0004,STR0005,STR0006,STR0007}//"Fornecedor"###"Data De Digitacao"###"Tipo+Grupo+Codigo"###" Grupo+Codigo"
Local aArea	   := Getarea()
Local aSB1Cod  := TamSX3("B1_COD")
Local aSB1Ite  := TAMSX3("B1_CODITE")
Local lVeiculo := Upper(GetMV("MV_VEICULO")) == "S"
Local nTamCli  := Max(TAMSX3("A1_NOME")[1],TAMSX3("A2_NOME")[1])-15
Local cTitle   := STR0001 //"Relacao de Compras"
Local cPictImp := X3Picture("D1_TOTAL")
Local nTamSX1  := Len(SX1->X1_GRUPO)
Local oReport
Local oSection1
Local oSection2
#IFDEF TOP
	Local cAliasSD1 := GetNextAlias()
#ELSE
	Local cAliasSD1 := "SD1"
#ENDIF

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // Produto de                           �
//� mv_par02             // Produto Ate                          �
//� mv_par03             // Data digitacao de                    �
//� mv_par04             // Data digitacao Ate                   �
//� mv_par05             // Fornecedor de                        �
//� mv_par06             // Fornecedor Ate                       �
//� mv_par07             // Imprime Devolucao Compra ?           �
//� mv_par08             // Filtra Dt Devolucao ?                �
//� mv_par09             // Moeda                                �
//� mv_par10             // Outras moedas                        �
//� mv_par11             // Somente NFE com TES                  �
//� mv_par12             // Imprime Devolucao Venda  ?           �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Ajustar o SX1 para SIGAVEI, SIGAPEC e SIGAOFI                �
//����������������������������������������������������������������
dbSelectArea("SX1")
dbSetOrder(1)
dbSeek(PADR("MTR090",nTamSX1))
Do While !SX1->(Eof()) .And. SX1->X1_GRUPO == PADR("MTR090",nTamSX1)
	If "PRODU" $ Upper(SX1->X1_PERGUNT) .And. Upper(SX1->X1_TIPO) == "C" .And. ;
		(SX1->X1_TAMANHO <> IIf( lVeiculo , aSB1Ite[1] , aSB1Cod[1] ) .Or. Upper(SX1->X1_F3) <> IIf( lVeiculo , "VR4" , "SB1" ) )
		RecLock("SX1",.F.)
		SX1->X1_TAMANHO := IIf( lVeiculo , aSB1Ite[1] , aSB1Cod[1] )
		SX1->X1_F3      := IIf( lVeiculo , "VR4" , "SB1" )
		dbCommit()
		MsUnlock()
	EndIf
	DbSkip()
EndDo

DbCommitall()
RestArea(aArea)

Pergunte("MTR090",.F.)
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
oReport:= TReport():New("EuMATR090",cTitle,"MTR090", {|oReport| ReportPrint(oReport,aOrdem,cAliasSD1)},STR0002+" "+STR0003) //"Este relatorio ira imprimir a relacao de itens referentes a compras efetuadas."
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//oSection1:= TRSection():New(oReport,STR0001,{"SD1","SF1","SD2","SF2","SB1","SA1","SA2","SF4"},aOrdem)
// Adicionado por Guilherme Ricci - TOTVS IP - 20/01/2016 - Solicitado no chamado 2016011910017728 por Thiago Almeida
oSection1:= TRSection():New(oReport,STR0001,{"SD1","SF1","SD2","SF2","SB1","SA1","SA2","SF4","SA5"},aOrdem)
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderPage()
oSection1:SetLineStyle(.F.)
oSection1:SetReadOnly() //NAO RETIRAR

oSection1:SetNoFilter("SA1")
oSection1:SetNoFilter("SA2")
oSection1:SetNoFilter("SF1")
oSection1:SetNoFilter("SF2")
oSection1:SetNoFilter("SD2")
oSection1:SetNoFilter("SF4")
oSection1:SetNoFilter("SD2")
oSection1:SetNoFilter("SB1")
// Adicionado por Guilherme Ricci - TOTVS IP - 20/01/2016 - Solicitado no chamado 2016011910017728 por Thiago Almeida
oSection1:SetNoFilter("SA5")

TRCell():New(oSection1,"D1_DOC"    ,"SD1",/*Titulo*/	,/*Picture*/, TamSX3("D1_DOC")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_COD"    ,"SD1",/*Titulo*/	,/*Picture*/,TamSX3("D1_COD")[1]+15,/*lPixel*/,/*{|| code-block de impressao }*/,/**/,/**/, /**/, /**/, /**/,.F.)

If lVeiculo
   TRCell():New(oSection1,"D1_CODITE" ,"SD1",RetTitle("B1_CODITE"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf

TRCell():New(oSection1,"COD"       ,"SD1",/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cCod })  // C�lula para controle do c�digo do produto, n�o ser� impressa
oSection1:Cell("COD"):Disable()

TRCell():New(oSection1,"B1_DESC"   ,"SB1",/*Titulo*/	,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_ZZSGPRD","SB1",/*Titulo*/	,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_QUANT"  ,"SD1",/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_UM"     ,"SD1",STR0031		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALUNIT"   ,"   ",STR0023		,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValUnit })

If cPaisloc=="BRA"
	If lVeiculo
		TRCell():New(oSection1,"D1_IPI","SD1",STR0039,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	Else
		TRCell():New(oSection1,"D1_IPI","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf
Else
	TRCell():New(oSection1,"IMPNOINC","   ",STR0024,cPictImp,/*Tamanho*/,/*lPixel*/,{|| nImpNoInc })
EndIf

TRCell():New(oSection1,"VALTOTAL"  ,"   ",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValTot  })

If cPaisloc=="BRA"
	If lVeiculo
		TRCell():New(oSection1,"D1_PICM","SD1",STR0040,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	Else
		TRCell():New(oSection1,"D1_PICM","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf
Else
	TRCell():New(oSection1,"IMPINC","   ",STR0025,cPictImp,/*Tamanho*/,/*lPixel*/,{|| nImpInc })
EndIf

TRCell():New(oSection1,"D1_FORNECE","SD1",STR0032		,/*Picture*/,TamSX3("D1_FORNECE")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"RAZAOSOC"  ,"   ",STR0027		,/*Picture*/,nTamCli-10	,/*lPixel*/,{|| cRazao })
TRCell():New(oSection1,"D1_TIPO"   ,"SD1",STR0033		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_TES"    ,"SD1",STR0034		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_TP"     ,"SD1",STR0035		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_GRUPO"  ,"SD1",/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_DTDIGIT","SD1",STR0036		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALCUSTO"  ,"   ",STR0028		,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValCusto })
TRCell():New(oSection1,"D1_LOCAL"  ,"SD1",STR0037		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_UPRC"   ,"SB1","Ult.Prc.Compra",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

// Adicionado por Guilherme Ricci - TOTVS IP - 20/01/2016 - Solicitado no chamado 2016011910017728 por Thiago Almeida
//TRCell():New(oSection1,"A5_CODPRF"  ,"SA5","Cod.Pr.Forn."	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
// Fim adicao

oSection1:Cell("VALUNIT"):GetFieldInfo("D1_VUNIT")
oSection1:Cell("VALTOTAL"):GetFieldInfo("D1_TOTAL")
oSection1:Cell("VALCUSTO"):GetFieldInfo("D1_CUSTO")

oSection2:= TRSection():New(oSection1,STR0001,{"SD2","SF2","SD1","SF1","SB1","SA1","SA2","SF4"})
oSection2:SetHeaderPage()
oSection2:SetTotalInLine(.F.)
oSection2:SetLineStyle()
oSection2:SetReadOnly() //NAO RETIRAR

oSection2:SetNoFilter("SA1")
oSection2:SetNoFilter("SA2")
oSection2:SetNoFilter("SF1")
oSection2:SetNoFilter("SF2")
oSection2:SetNoFilter("SD2")
oSection2:SetNoFilter("SF4")
oSection2:SetNoFilter("SD1")
oSection2:SetNoFilter("SB1")

TRCell():New(oSection2,"D2_DOC"    ,"SD2",/*Titulo*/,/*Picture*/,6			 ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_COD"    ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B1_DESC"   ,"SB1",/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B1_ZZSGPRD","SB1",/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_QUANT"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| SD2->D2_QUANT * -1 })
TRCell():New(oSection2,"D2_UM"     ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"PRCVEN"    ,"   ",STR0023	 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValUnit })

If cPaisloc=="BRA"
	TRCell():New(oSection2,"D2_IPI","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
Else
	TRCell():New(oSection2,"IMPNOINC","   ",STR0024,cPictImp,/*Tamanho*/,/*lPixel*/,{|| nImpNoInc })
EndIf

TRCell():New(oSection2,"VALTOTAL"  ,"   ",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValTot * -1 })

If cPaisloc=="BRA"
	TRCell():New(oSection2,"D2_PICM","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
Else
	TRCell():New(oSection2,"IMPINC","   ",STR0025,cPictImp,/*Tamanho*/,/*lPixel*/,{|| nImpInc })
EndIf

TRCell():New(oSection2,"D2_CLIENTE","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"RAZAOSOC"  ,"   ",STR0027	 ,/*Picture*/,nTamCli-10 ,/*lPixel*/,{|| cRazao })
TRCell():New(oSection2,"D2_TIPO"   ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_TES"    ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_TP"     ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_GRUPO"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_EMISSAO","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"VALCUSTO"  ,"   ",STR0028	 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValCusto * -1 })
TRCell():New(oSection2,"D2_LOCAL"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B1_UPRC"   ,"SB1","Ult.Prc.Compra",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:Cell("PRCVEN"  	):GetFieldInfo("D2_PRCVEN"	)
oSection2:Cell("VALTOTAL"	):GetFieldInfo("D2_TOTAL"	)
oSection2:Cell("VALCUSTO"	):GetFieldInfo("D2_CUSTO"	)
oSection2:Cell("D2_DOC"		):GetFieldInfo("D1_DOC"		)
oSection2:Cell("D2_CLIENTE"	):GetFieldInfo("D1_FORNECE"	)
oSection2:Cell("D2_TIPO"	):GetFieldInfo("D1_TIPO"	)
oSection2:Cell("D2_TES"		):GetFieldInfo("D1_TES"		)
oSection2:Cell("D2_TP"		):GetFieldInfo("D1_TP"		)
oSection2:Cell("D2_GRUPO"	):GetFieldInfo("D1_GRUPO"	)
oSection2:Cell("D2_EMISSAO"	):GetFieldInfo("D1_DTDIGIT"	)

oSection2:Cell("D2_DOC"		):HideHeader()
oSection2:Cell("D2_COD"		):HideHeader()
oSection2:Cell("B1_DESC"	):HideHeader()
oSection2:Cell("B1_ZZSGPRD"	):HideHeader()
oSection2:Cell("D2_QUANT"	):HideHeader()
oSection2:Cell("D2_UM"		):HideHeader()
oSection2:Cell("PRCVEN"		):HideHeader()
If cPaisloc=="BRA"
	oSection2:Cell("D2_IPI"	):HideHeader()
Else
	oSection2:Cell("IMPNOINC"):HideHeader()
EndIf
oSection2:Cell("VALTOTAL"):HideHeader()
If cPaisloc=="BRA"
	oSection2:Cell("D2_PICM"):HideHeader()
Else
	oSection2:Cell("IMPINC"	):HideHeader()
EndIf
oSection2:Cell("D2_CLIENTE"	):HideHeader()
oSection2:Cell("RAZAOSOC"	):HideHeader()
oSection2:Cell("D2_TIPO"	):HideHeader()
oSection2:Cell("D2_TES"		):HideHeader()
oSection2:Cell("D2_TP"		):HideHeader()
oSection2:Cell("D2_GRUPO"	):HideHeader()
oSection2:Cell("D2_EMISSAO"	):HideHeader()
oSection2:Cell("VALCUSTO"	):HideHeader()
oSection2:Cell("D2_LOCAL"	):HideHeader()
oSection2:Cell("B1_UPRC"	):HideHeader()

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Alexandre Inacio Lemes �Data  �06/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da rela��o de Compras                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,aOrdem,cAliasSD1)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local nOrdem     := oReport:Section(1):GetOrder()
Local aImpostos  := {}
Local aRecno     := {}
Local cCampImp   := ""
Local cTipo1	 := ""
Local cTipo2	 := ""
Local cFilUsrSD1 := ""
Local cCondSD2   := ""
Local cArqTrbSD2 := ""
Local nNewIndSD2 := 0
Local nImpos     := 0
Local nY         := 0
Local nDecs      := Msdecimais(mv_par09) //casas decimais utilizadas na moeda da impressao
Local oBreak
Local oBreak1
Local oBreak2
Local oBreak3
Local lQuery     := .F.
Local lMoeda     := .T.

#IFDEF TOP
	Local cSelect   := ""
	Local cSelect1  := ""
    Local cOrder    := ""
	Local cWhereSB1 := ""
	Local cWhereSF1 := ""
	Local cWhereSF4 := "%%"
    Local cFrom     := "%%"
	Local cAliasSF4 := cAliasSD1
	Local aStrucSD1 := SD1->(dbStruct())
	Local cName		:= ""
	Local nX        := 0
#ELSE
	Local cCondicao := ""
    Local cIndexKey := ""
	Local cAliasSF4 := "SF4"
#ENDIF

PRIVATE cRazao   := ""
PRIVATE lVeiculo := Upper(GetMV("MV_VEICULO")) == "S"
PRIVATE nValUnit := 0
PRIVATE nValTot  := 0
PRIVATE nValCusto:= 0
PRIVATE	nImpInc  :=	0
PRIVATE	nImpNoInc:=	0
PRIVATE cCod	 := ""

//������������������������������������������������������������Ŀ
//� Adiciona a ordem escolhida ao titulo do relatorio          �
//��������������������������������������������������������������
oReport:SetTitle(oReport:Title() + " ("+AllTrim(aOrdem[nOrdem])+") ")

dbSelectArea("SD1")
//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
#IFDEF TOP

 	MakeSqlExpr(oReport:uParam)

 	oReport:Section(1):BeginQuery()

    lQuery := .T.

	cSelect := "%"

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("D1_VALIMP")
	While !Eof() .And. X3_ARQUIVO == "SD1" .And. X3_CAMPO = "D1_VALIMP"
		cSelect += ", " + X3_CAMPO
		DbSkip()
	EndDo

	If lVeiculo
		cSelect   += ",B1_CODITE "
	    cWhereSB1 := "%"
		cWhereSB1 += " B1_CODITE >= '" + MV_PAR01 + "'"
		cWhereSB1 += " AND B1_CODITE <= '" + MV_PAR02 + "'"
	    cWhereSB1 += "%"
    Else
	    cWhereSB1 := "%"
		cWhereSB1 += " D1_COD >= '" + MV_PAR01 + "'"
		cWhereSB1 += " AND D1_COD <= '" + MV_PAR02 + "'"
	    cWhereSB1 += "%"
 	Endif

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
	cSelect1 := "D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_DTDIGIT, D1_COD,   D1_QUANT, D1_VUNIT,"
	cSelect1 += "D1_TOTAL,  D1_TES, D1_IPI,   D1_PICM,    D1_TIPO, D1_TP,      D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, D1_ITEM, D1_UM,"
   	cFilUsrSD1:= oSection1:GetAdvplExp()
    If !Empty(cFilUsrSD1)
		For nX := 1 To SD1->(FCount())
			cName := SD1->(FieldName(nX))
		 	If AllTrim( cName ) $ cFilUsrSD1
	      		If aStrucSD1[nX,2] <> "M"
	      			If !cName $ cSelect .And. !cName $ cSelect1
		        		cSelect += ","+cName
		          	Endif
		       	EndIf
			EndIf
		Next
    Endif

	If mv_par11 == 1
		cSelect += ", F4_AGREG "
	    cFrom := "%"
	    cFrom += "," + RetSqlName("SF4") + " SF4 "
	    cFrom += "%"

	    cWhereSF4 := "%"
		cWhereSF4 += " SF4.F4_FILIAL ='" + xFilial("SF4") + "'"
		cWhereSF4 += " AND SF4.F4_CODIGO = SD1.D1_TES"
		cWhereSF4 += " AND SF4.D_E_L_E_T_ <> '*' AND "
        cWhereSF4 += "%"
    EndIf

	If (mv_par12 == 1)
		cTipo1 := "D','B"
		cTipo2 := cTipo1
	Else
		cTipo1 := "B"
		cTipo2 := "D','B"
	EndIf

    cSelect += "%"

	cWhereSF1 := "%"
	cWhereSF1 += "NOT ("+IsRemito(3,'SF1.F1_TIPODOC')+ ") AND "
	cWhereSF1 += "%"

	If nOrdem == 1
		cOrder := "% D1_FILIAL, D1_FORNECE, D1_LOJA,    D1_DOC,   D1_SERIE,  D1_ITEM %"
	ElseIf nOrdem == 2
		cOrder := "% D1_FILIAL, D1_DTDIGIT, D1_FORNECE, D1_LOJA,   D1_DOC,   D1_SERIE, D1_ITEM %"
	ElseIf nOrdem == 3 .And. lVeiculo
		cOrder := "% D1_FILIAL, D1_TP,	    D1_GRUPO,   B1_CODITE, D1_DTDIGIT %"
	ElseIf nOrdem == 3 .And. !lVeiculo
		cOrder := "% D1_FILIAL, D1_TP,		D1_GRUPO,   D1_COD,    D1_DTDIGIT %"
	ElseIf nOrdem == 4 .And. lVeiculo
		cOrder := "% D1_FILIAL, D1_GRUPO,   D1_CODITE,  D1_DTDIGIT %"
	ElseIf nOrdem == 4 .And. !lVeiculo
		cOrder := "% D1_FILIAL, D1_GRUPO,   D1_COD,     D1_DTDIGIT %"
	EndIf

	BeginSql Alias cAliasSD1

	SELECT D1_FILIAL,D1_DOC,     D1_SERIE,   D1_FORNECE, D1_LOJA, D1_DTDIGIT,    D1_COD,   D1_QUANT, D1_VUNIT,
		   D1_TOTAL, D1_TES,     D1_IPI,     D1_PICM,    D1_TIPO, D1_TP,         D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, D1_ITEM,D1_UM,
	       F1_MOEDA, F1_TXMOEDA, F1_DTDIGIT, B1_DESC, B1_ZZSGPRD, B1_UM,  B1_UPRC, A1_NOME RAZAO, A1_NREDUZ RAZAORED, SD1.R_E_C_N_O_ SD1RECNO,
	       B1_CODITE D1_CODITE,  'C' TIPO //,	 A5_CODPRF
	       %Exp:cSelect%

	FROM %table:SF1% SF1 , %table:SD1% SD1 , %table:SB1% SB1 , %table:SA1% SA1 %Exp:cFrom%, %table:SA5% SA5

   	WHERE SF1.F1_FILIAL   = %xFilial:SF1%   AND
	      %Exp:cWhereSF1%
	      SF1.%NotDel%                      AND
          SD1.D1_FILIAL   =  %xFilial:SD1%  AND
          SD1.D1_DOC      =  SF1.F1_DOC     AND
          SD1.D1_SERIE    =  SF1.F1_SERIE   AND
          SD1.D1_FORNECE  =  SF1.F1_FORNECE AND
          SD1.D1_LOJA     =  SF1.F1_LOJA    AND
	      SD1.D1_TIPO  IN (%Exp:cTipo1%)    AND
	      SD1.%NotDel%                      AND
          SB1.B1_FILIAL   =  %xFilial:SB1%  AND
          SB1.B1_COD      =  SD1.D1_COD     AND
	      SB1.%NotDel%                      AND
          SA1.A1_FILIAL   =  %xFilial:SA1%  AND
          SA1.A1_COD      =  SD1.D1_FORNECE AND
          SA1.A1_LOJA     =  SD1.D1_LOJA    AND
	      SA1.%NotDel%                      AND
	      %Exp:cWhereSF4%
 	      SD1.D1_DTDIGIT >= %Exp:Dtos(mv_par03)% AND
	      SD1.D1_DTDIGIT <= %Exp:Dtos(mv_par04)% AND
		  SD1.D1_FORNECE >= %Exp:mv_par05% AND
	      SD1.D1_FORNECE <= %Exp:mv_par06% AND
	      /* Adicionado por Guilherme Ricci - TOTVS IP - 20/01/2016 - Solicitado no chamado 2016011910017728 por Thiago Almeida */
	      //SA5.A5_FORNECE = SD1.D1_FORNECE	AND
	      //SA5.A5_LOJA	 = SD1.D1_LOJA		AND
	      //SA5.A5_PRODUTO = SD1.D1_COD		AND
	      //SA5.A5_CODPRF  = SD1.D1_ZZCODF	AND
	      /* Fim Adicao */
	      %Exp:cWhereSB1%

	UNION

	SELECT D1_FILIAL, D1_DOC,     D1_SERIE,   D1_FORNECE, D1_LOJA, D1_DTDIGIT,    D1_COD,   D1_QUANT, D1_VUNIT,
		   D1_TOTAL,  D1_TES,     D1_IPI,     D1_PICM,    D1_TIPO, D1_TP,         D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, D1_ITEM,D1_UM,
	       F1_MOEDA,  F1_TXMOEDA, F1_DTDIGIT, B1_DESC, B1_ZZSGPRD, B1_UM, B1_UPRC,  A2_NOME RAZAO, A2_NREDUZ RAZAORED, SD1.R_E_C_N_O_ SD1RECNO,
   	       B1_CODITE  D1_CODITE,  'F' TIPO //, A5_CODPRF
	       %Exp:cSelect%

	FROM %table:SF1% SF1 , %table:SD1% SD1 , %table:SB1% SB1 , %table:SA2% SA2 %Exp:cFrom%
	/* Adicionado por Guilherme Ricci - TOTVS IP - 20/01/2016 - Solicitado no chamado 2016011910017728 por Thiago Almeida */
	, %table:SA5% SA5
    /* Fim Adicao */

   	WHERE SF1.F1_FILIAL   = %xFilial:SF1%   AND
	      %Exp:cWhereSF1%
	      SF1.%NotDel%                      AND
          SD1.D1_FILIAL   =  %xFilial:SD1%  AND
          SD1.D1_DOC      =  SF1.F1_DOC     AND
          SD1.D1_SERIE    =  SF1.F1_SERIE   AND
          SD1.D1_FORNECE  =  SF1.F1_FORNECE AND
          SD1.D1_LOJA     =  SF1.F1_LOJA    AND
	      SD1.D1_TIPO NOT IN (%Exp:cTipo2%)  AND
	      SD1.%NotDel%                      AND
          SB1.B1_FILIAL   =  %xFilial:SB1%  AND
          SB1.B1_COD      =  SD1.D1_COD     AND
	      SB1.%NotDel%                      AND
          SA2.A2_FILIAL   =  %xFilial:SA2%  AND
          SA2.A2_COD      =  SD1.D1_FORNECE AND
          SA2.A2_LOJA     =  SD1.D1_LOJA    AND
	      SA2.%NotDel%                      AND
	      %Exp:cWhereSF4%
 	      SD1.D1_DTDIGIT >= %Exp:Dtos(mv_par03)% AND
	      SD1.D1_DTDIGIT <= %Exp:Dtos(mv_par04)% AND
		  SD1.D1_FORNECE >= %Exp:mv_par05% AND
	      SD1.D1_FORNECE <= %Exp:mv_par06% AND
	      /* Adicionado por Guilherme Ricci - TOTVS IP - 20/01/2016 - Solicitado no chamado 2016011910017728 por Thiago Almeida */
	      //SA5.A5_FORNECE = SD1.D1_FORNECE	AND
	      //SA5.A5_LOJA	 = SD1.D1_LOJA		AND
	      //SA5.A5_PRODUTO = SD1.D1_COD		AND
	      //SA5.A5_CODPRF  = SD1.D1_ZZCODF	AND
	      /* Fim Adicao */
	      %Exp:cWhereSB1%

	ORDER BY %Exp:cOrder%

	EndSql

    oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

#ELSE
	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao Advpl                          �
	//��������������������������������������������������������������������������
	MakeAdvplExpr(oReport:uParam)

	cCondicao := 'D1_FILIAL == "'       + xFilial("SD1") + '".And.'

    If lVeiculo
		cCondicao += 'D1_CODITE >= "'   + mv_par01       + '".And.D1_CODITE <="'       + mv_par02       + '".And.'
    Else
		cCondicao += 'D1_COD >= "'      + mv_par01       + '".And.D1_COD <="'          + mv_par02       + '".And.'
    EndIf

	//��������������������������������������������������������������Ŀ
	//� Despreza Nota Fiscal sem TES de acordo com parametro         �
	//����������������������������������������������������������������
	If mv_par11 == 1
	   cCondicao += '!Empty(D1_TES) .And. '
	Endif

	//�������������������������Ŀ
	//� Imprime Dev. Vendas ? 	�
	//���������������������������
	If mv_par12 == 2
	   cCondicao += '!(D1_TIPO $ "D") .And. '
	EndIf

	cCondicao += 'Dtos(D1_DTDIGIT) >= "'+ Dtos(mv_par03) + '".And.Dtos(D1_DTDIGIT) <="'+ Dtos(mv_par04) + '".And.'
	cCondicao += 'D1_FORNECE >= "'      + mv_par05       + '".And.D1_FORNECE <="'      + mv_par06       + '".And. '
	cCondicao += '!('+IsRemito(2,"SD1->D1_TIPODOC")+')'

	If nOrdem == 1
		cIndexKey := "D1_FILIAL+D1_FORNECE+D1_LOJA+D1_DOC+D1_SERIE+D1_ITEM"
	ElseIf nOrdem == 2
		cIndexKey := "D1_FILIAL+Dtos(D1_DTDIGIT)+D1_FORNECE+D1_LOJA+D1_DOC+D1_SERIE+D1_ITEM"
	ElseIf nOrdem == 3 .And. lVeiculo
		cIndexKey := "D1_FILIAL+D1_TP+D1_GRUPO+D1_CODITE+Dtos(D1_DTDIGIT)"
	ElseIf nOrdem == 3 .And. !lVeiculo
		cIndexKey := "D1_FILIAL+D1_TP+D1_GRUPO+D1_COD+Dtos(D1_DTDIGIT)"
	ElseIf nOrdem == 4 .And. lVeiculo
		cIndexKey := "D1_FILIAL+D1_GRUPO+D1_CODITE+Dtos(D1_DTDIGIT)"
	ElseIf nOrdem == 4 .And. !lVeiculo
		cIndexKey := "D1_FILIAL+D1_GRUPO+D1_COD+Dtos(D1_DTDIGIT)"
	EndIf

	oReport:Section(1):SetFilter(cCondicao,cIndexKey)

	TRPosition():New(oSection1,"SB1",1,{|| xFilial("SB1")+(cAliasSD1)->D1_COD })

#ENDIF

//��������������������������������������������������������������Ŀ
//� Monta IndRegua caso liste NFs de devolucao                   �
//����������������������������������������������������������������
If mv_par07 == 1
	cArqTrbSD2:= CriaTrab("",.F.)
	//�����������������������������������������������������������Ŀ
	//� Verifica data caso FILTRE NFs de devolucao fora do periodo�
	//�������������������������������������������������������������
	If mv_par08 == 1
		cCondSD2	:=	( "D2_FILIAL == '" + xFilial("SD2") + "'" )
		cCondSD2	+=	( " .And. DTOS(D2_EMISSAO)>='" + DTOS(mv_par03) + "'" )
		cCondSD2	+=	( " .And. DTOS(D2_EMISSAO)<='" + DTOS(mv_par04) + "'" )
	Else
		cCondSD2	:=	( "D2_FILIAL == '" + xFilial("SD2") + "'")
	EndIf
	cCondSD2 +=	( ".And. !(" + IsRemito(2,'SD2->D2_TIPODOC') + ")" )

	dbSelectArea("SD2")
	IndRegua("SD2",cArqTrbSD2,"D2_FILIAL+D2_COD+D2_NFORI+D2_ITEMORI+D2_SERIORI+D2_CLIENTE+D2_LOJA",,cCondSD2,STR0010)		//"Selecionando Registros..."
	nNewIndSD2 := RetIndex("SD2")
	dbSelectArea("SD2")
	#IFNDEF TOP
		dbSetIndex(cArqTrbSD2+OrdBagExt())
	#ENDIF
	dbSetOrder(nNewIndSD2+1)
	dbGoTop()
EndIf

cFilUsrSD1:= oSection1:GetAdvplExp()

If nOrdem == 1

	//��������������������������������������������������������������Ŀ
	//� Definicao das quebras e totalizadores que serao Impressos.   �
	//����������������������������������������������������������������
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("D1_DOC")    ,STR0017,.F.,"NFE") // "TOTAL NOTA FISCAL --> "
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_FORNECE"),STR0018,.F.) // "TOTAL FORNECEDOR  --> "

	//��������������������������������������������������������������������������������������������������������������������������Ŀ
	//� A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  �
	//����������������������������������������������������������������������������������������������������������������������������
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )

	//��������������������������������������������������������������Ŀ
	//� Dispara a funcao PrintDevol() para a impressao da oSection2  �
	//� apartir do Break NFE abaixo apos a impressao do totalizador. �
	//����������������������������������������������������������������
	oBreak:= oReport:Section(1):GetBreak("NFE")
	oBreak:OnPrintTotal({|| PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })

	//��������������������������������������������������������������Ŀ
	//� Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          �
	//����������������������������������������������������������������
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() , oSection1:GetFunction("SD1QTD2"):ReportValue() + oSection2:GetFunction("SD2QTD2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1NIC2"):GetValue() + oSection2:GetFunction("SD2NIC2"):GetValue() , oSection1:GetFunction("SD1NIC2"):ReportValue() + oSection2:GetFunction("SD2NIC2"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() , oSection1:GetFunction("SD1TOT2"):ReportValue() + oSection2:GetFunction("SD2TOT2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1INC2"):GetValue() + oSection2:GetFunction("SD2INC2"):GetValue() , oSection1:GetFunction("SD1INC2"):ReportValue() + oSection2:GetFunction("SD2INC2"):ReportValue() ) },.F.,.T.)
    EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() , oSection1:GetFunction("SD1CUS2"):ReportValue() + oSection2:GetFunction("SD2CUS2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )

ElseIf nOrdem == 2

	//��������������������������������������������������������������Ŀ
	//� Definicao das quebras e totalizadores que serao Impressos.   �
	//����������������������������������������������������������������
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("D1_DOC")    ,STR0017,.F.,"NFE") // "TOTAL NOTA FISCAL --> "
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_FORNECE"),STR0018,.F.) // "TOTAL FORNECEDOR  --> "
	oBreak3 := TRBreak():New(oSection1,oSection1:Cell("D1_DTDIGIT"),STR0019,.F.) // "TOT. NA DATA "

	//��������������������������������������������������������������������������������������������������������������������������Ŀ
	//� A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  �
	//����������������������������������������������������������������������������������������������������������������������������
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )

	//��������������������������������������������������������������Ŀ
	//� Dispara a funcao PrintDevol() para a impressao da oSection2  �
	//� apartir do Break NFE abaixo apos a impressao do totalizador. �
	//����������������������������������������������������������������
	oBreak:= oReport:Section(1):GetBreak("NFE")
	oBreak:OnPrintTotal({|| PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })

	//��������������������������������������������������������������Ŀ
	//� Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          �
	//����������������������������������������������������������������
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1NIC2"):GetValue() + oSection2:GetFunction("SD2NIC2"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1INC2"):GetValue() + oSection2:GetFunction("SD2INC2"):GetValue() },.F.,.F.)
    EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD3"):GetValue() + oSection2:GetFunction("SD2QTD3"):GetValue() , oSection1:GetFunction("SD1QTD3"):ReportValue() + oSection2:GetFunction("SD2QTD3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1NIC3"):GetValue() + oSection2:GetFunction("SD2NIC3"):GetValue() , oSection1:GetFunction("SD1NIC3"):ReportValue() + oSection2:GetFunction("SD2NIC3"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT3"):GetValue() + oSection2:GetFunction("SD2TOT3"):GetValue() , oSection1:GetFunction("SD1TOT3"):ReportValue() + oSection2:GetFunction("SD2TOT3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1INC3"):GetValue() + oSection2:GetFunction("SD2INC3"):GetValue() , oSection1:GetFunction("SD1INC3"):ReportValue() + oSection2:GetFunction("SD2INC3"):ReportValue() ) },.F.,.T.)
    EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS3"):GetValue() + oSection2:GetFunction("SD2CUS3"):GetValue() , oSection1:GetFunction("SD1CUS3"):ReportValue() + oSection2:GetFunction("SD2CUS3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )

ElseIf nOrdem == 3

	//��������������������������������������������������������������Ŀ
	//� Definicao das quebras e totalizadores que serao Impressos.   �
	//����������������������������������������������������������������
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("COD"),STR0014,.F.,"PROD") // "TOTAL PRODUTO     --> "
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_GRUPO")  ,STR0015,.F.) // "TOTAL GRUPO "
	oBreak3 := TRBreak():New(oSection1,oSection1:Cell("D1_TP")     ,STR0016,.F.) // "TOTAL TIPO  "

	//��������������������������������������������������������������Ŀ
	//� Dispara a funcao PrintDevol() para a impressao da oSection2  �
	//� apartir do Break NFE abaixo apos a impressao do totalizador. �
	//����������������������������������������������������������������
	oBreak:= oReport:Section(1):GetBreak("PROD")
	oBreak:OnBreak({|| PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })

	//��������������������������������������������������������������Ŀ
	//� Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          �
	//����������������������������������������������������������������
	//��������������������������������������������������������������������������������������������������������������������������Ŀ
	//� A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  �
	//����������������������������������������������������������������������������������������������������������������������������
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD1"):GetValue() + oSection2:GetFunction("SD2QTD1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1NIC1"):GetValue() + oSection2:GetFunction("SD2NIC1"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT1"):GetValue() + oSection2:GetFunction("SD2TOT1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1INC1"):GetValue() + oSection2:GetFunction("SD2INC1"):GetValue() },.F.,.F.)
    EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS1"):GetValue() + oSection2:GetFunction("SD2CUS1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1NIC2"):GetValue() + oSection2:GetFunction("SD2NIC2"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1INC2"):GetValue() + oSection2:GetFunction("SD2INC2"):GetValue() },.F.,.F.)
    EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD3"):GetValue() + oSection2:GetFunction("SD2QTD3"):GetValue() , oSection1:GetFunction("SD1QTD3"):ReportValue() + oSection2:GetFunction("SD2QTD3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1NIC3"):GetValue() + oSection2:GetFunction("SD2NIC3"):GetValue() , oSection1:GetFunction("SD1NIC3"):ReportValue() + oSection2:GetFunction("SD2NIC3"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT3"):GetValue() + oSection2:GetFunction("SD2TOT3"):GetValue() , oSection1:GetFunction("SD1TOT3"):ReportValue() + oSection2:GetFunction("SD2TOT3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1INC3"):GetValue() + oSection2:GetFunction("SD2INC3"):GetValue() , oSection1:GetFunction("SD1INC3"):ReportValue() + oSection2:GetFunction("SD2INC3"):ReportValue() ) },.F.,.T.)
    EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS3"):GetValue() + oSection2:GetFunction("SD2CUS3"):GetValue() , oSection1:GetFunction("SD1CUS3"):ReportValue() + oSection2:GetFunction("SD2CUS3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )

ElseIf nOrdem == 4

	//��������������������������������������������������������������Ŀ
	//� Definicao das quebras e totalizadores que serao Impressos.   �
	//����������������������������������������������������������������
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("COD"),STR0014,.F.,"PROD") // "TOTAL PRODUTO     --> "
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_GRUPO")  ,STR0015,.F.) // "TOTAL GRUPO "

	//��������������������������������������������������������������Ŀ
	//� Dispara a funcao PrintDevol() para a impressao da oSection2  �
	//� apartir do Break NFE abaixo apos a impressao do totalizador. �
	//����������������������������������������������������������������
	oBreak:= oReport:Section(1):GetBreak("PROD")
	oBreak:OnBreak({|| PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })

	//��������������������������������������������������������������Ŀ
	//� Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          �
	//����������������������������������������������������������������
	//��������������������������������������������������������������������������������������������������������������������������Ŀ
	//� A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  �
	//����������������������������������������������������������������������������������������������������������������������������
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD1"):GetValue() + oSection2:GetFunction("SD2QTD1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1NIC1"):GetValue() + oSection2:GetFunction("SD2NIC1"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT1"):GetValue() + oSection2:GetFunction("SD2TOT1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1INC1"):GetValue() + oSection2:GetFunction("SD2INC1"):GetValue() },.F.,.F.)
    EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS1"):GetValue() + oSection2:GetFunction("SD2CUS1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() , oSection1:GetFunction("SD1QTD2"):ReportValue() + oSection2:GetFunction("SD2QTD2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1NIC2"):GetValue() + oSection2:GetFunction("SD2NIC2"):GetValue() , oSection1:GetFunction("SD1NIC2"):ReportValue() + oSection2:GetFunction("SD2NIC2"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() , oSection1:GetFunction("SD1TOT2"):ReportValue() + oSection2:GetFunction("SD2TOT2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1INC2"):GetValue() + oSection2:GetFunction("SD2INC2"):GetValue() , oSection1:GetFunction("SD1INC2"):ReportValue() + oSection2:GetFunction("SD2INC2"):ReportValue() ) },.F.,.T.)
    EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() , oSection1:GetFunction("SD1CUS2"):ReportValue() + oSection2:GetFunction("SD2CUS2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )

EndIf

//��������������������������������������������������������������Ŀ
//� Os TRFunctions abaixo nao sao impressos, servem apenas para  �
//� acumular os valores das oSection1 e oSection2 para serem     �
//� utilizados na impressao do totalizador geral da oSection1    �
//� acima ONPRINT que subtrai as devolucoes SD1 - SD2.           �
//����������������������������������������������������������������
If nOrdem == 3 .Or. nOrdem == 4

	TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    oSection1:GetFunction("SD1QTD1"):Disable()
    oSection1:GetFunction("SD1TOT1"):Disable()
    oSection1:GetFunction("SD1CUS1"):Disable()
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),"SD1NIC1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		TRFunction():New(oSection1:Cell("IMPINC")  ,"SD1INC1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	    oSection1:GetFunction("SD1NIC1"):Disable()
	    oSection1:GetFunction("SD1INC1"):Disable()
	EndIf

	TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    oSection2:GetFunction("SD2QTD1"):Disable()
    oSection2:GetFunction("SD2TOT1"):Disable()
    oSection2:GetFunction("SD2CUS1"):Disable()
    If cPaisloc <> "BRA"
		TRFunction():New(oSection2:Cell("IMPNOINC"),"SD2NIC1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		TRFunction():New(oSection2:Cell("IMPINC")  ,"SD2INC1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	    oSection2:GetFunction("SD2NIC1"):Disable()
	    oSection2:GetFunction("SD2INC1"):Disable()
    EndIf

EndIf

TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
oSection1:GetFunction("SD1QTD2"):Disable()
oSection1:GetFunction("SD1TOT2"):Disable()
oSection1:GetFunction("SD1CUS2"):Disable()
If cPaisloc <> "BRA"
	TRFunction():New(oSection1:Cell("IMPNOINC"),"SD1NIC2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("IMPINC")  ,"SD1INC2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	oSection1:GetFunction("SD1NIC2"):Disable()
	oSection1:GetFunction("SD1INC2"):Disable()
EndIf

TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
oSection2:GetFunction("SD2QTD2"):Disable()
oSection2:GetFunction("SD2TOT2"):Disable()
oSection2:GetFunction("SD2CUS2"):Disable()
If cPaisloc <> "BRA"
	TRFunction():New(oSection2:Cell("IMPNOINC"),"SD2NIC2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection2:Cell("IMPINC")  ,"SD2INC2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	oSection2:GetFunction("SD2NIC2"):Disable()
	oSection2:GetFunction("SD2INC2"):Disable()
EndIf

If nOrdem == 2 .Or. nOrdem == 3

	TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    oSection1:GetFunction("SD1QTD3"):Disable()
    oSection1:GetFunction("SD1TOT3"):Disable()
    oSection1:GetFunction("SD1CUS3"):Disable()
    If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),"SD1NIC3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		TRFunction():New(oSection1:Cell("IMPINC")  ,"SD1INC3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	    oSection1:GetFunction("SD1NIC3"):Disable()
	    oSection1:GetFunction("SD1INC3"):Disable()
	EndIf

	TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
    oSection2:GetFunction("SD2QTD3"):Disable()
    oSection2:GetFunction("SD2TOT3"):Disable()
    oSection2:GetFunction("SD2CUS3"):Disable()
    If cPaisloc <> "BRA"
		TRFunction():New(oSection2:Cell("IMPNOINC"),"SD2NIC3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		TRFunction():New(oSection2:Cell("IMPINC")  ,"SD2INC3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	    oSection2:GetFunction("SD2NIC3"):Disable()
	    oSection2:GetFunction("SD2INC3"):Disable()
    EndIf

EndIf

oReport:SetMeter(SD1->(LastRec()))
dbSelectArea(cAliasSD1)

oSection1:Init()

While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())

	lMoeda := .T.

	oReport:IncMeter()
	If oReport:Cancel()
		Exit
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Considera filtro escolhido                                   �
	//����������������������������������������������������������������
	dbSelectArea(cAliasSD1)
	If !Empty(cFilUsrSD1)
	    If !(&(cFilUsrSD1))
	       dbSkip()
    	   Loop
    	EndIf
	EndIf

	If lQuery
		//������������������������������������������������������������������������������Ŀ
		//� Desconsidera quando for Cliente e Tipo da NF <> Devolucao ou Beneficiamento  �
		//| Em situa��es onde o C�digo do Cliente e C�digo do Fornecedor s�o iguais      |
		//| e necess�rio este crit�rio para n�o imprimir o relat�rio incorretamente.     |
		//��������������������������������������������������������������������������������
	 	if (cAliasSD1)->TIPO == "C"
		   If !(cAliasSD1)->D1_TIPO $ "DB"
			   dbSkip()
    		   Loop
    		EndIf
    	EndIf

		//��������������������������������������������������������������Ŀ
		//� Nao imprimir notas com moeda diferente da escolhida.         �
		//����������������������������������������������������������������
		If mv_par10==2
			If If((cAliasSD1)->F1_MOEDA==0,1,(cAliasSD1)->F1_MOEDA) != mv_par09
				lMoeda := .F.
			Endif
		EndIf

		cRazao   := (cAliasSD1)->RAZAO
        nValUnit := xmoeda((cAliasSD1)->D1_VUNIT,(cAliasSD1)->F1_MOEDA,mv_par09,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)
        nValTot  := xmoeda((cAliasSD1)->D1_TOTAL,(cAliasSD1)->F1_MOEDA,mv_par09,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)
		nValCusto:= xmoeda((cAliasSD1)->D1_CUSTO,1,mv_par09,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)

		// Vari�vel para atualizar o C�digo quando for estiver usando ve�culo ou n�o
		If lVeiculo
		   cCod:=(cAliasSD1)->D1_CODITE
		Else
		   cCod:= (cAliasSD1)->D1_COD
		EndIf

		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf((cAliasSD1)->D1_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:=(cAliasSD1)+"->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,(cAliasSD1)->F1_MOEDA,mv_par09,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next
		EndIf
	Else
		//��������������������������������������������������������������Ŀ
		//� Nao imprimir notas com moeda diferente da escolhida.         �
		//����������������������������������������������������������������
		If mv_par10==2
			If If(SF1->F1_MOEDA==0,1,SF1->F1_MOEDA) != mv_par09
				lMoeda := .F.
			Endif
		EndIf

		//���������������������������������������������������������������Ŀ
		//�Posiciona o Fornecedor SA2 ou Cliente SA1 conf. o tipo da Nota �
		//�����������������������������������������������������������������
		If (cAliasSD1)->D1_TIPO $ "DB"
			SA1->(dbSetOrder(1))
			SA1->(MsSeek( xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA ))
			cRazao := SA1->A1_NOME
		Else
			SA2->(dbSetOrder(1))
			SA2->(MsSeek( xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA ))
			cRazao := SA2->A2_NOME
		EndIf

		//��������������������������������������������������������������Ŀ
		//� posiciona o SF1                                              �
		//����������������������������������������������������������������
		SF1->(MsSeek((cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))

		//��������������������������������������������������������������Ŀ
		//� posiciona o SF4                                              �
		//����������������������������������������������������������������
		If mv_par11 == 1
			SF4->(MsSeek( xFilial("SF4") + (cAliasSD1)->D1_TES ))
		EndIf

		nValUnit := xmoeda((cAliasSD1)->D1_VUNIT,SF1->F1_MOEDA,mv_par09,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
		nValTot  := xmoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,mv_par09,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
		nValCusto:= xmoeda((cAliasSD1)->D1_CUSTO,1,mv_par09,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)

		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf((cAliasSD1)->D1_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:=(cAliasSD1)+"->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,SF1->F1_MOEDA,mv_par09,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next
		EndIf

	EndIf

    If lMoeda

		oSection1:PrintLine()

		//���������������������������������������������������������������Ŀ
		//� Verificar a existencia de Devolucoes de Compras.              �
		//�����������������������������������������������������������������
		If (cAliasSD1)->D1_QTDEDEV <> 0 .And. mv_par07 == 1
			AADD(aRecno,IIf(lQuery,(cAliasSD1)->SD1RECNO,Recno()))
		Endif

    EndIf

	dbSelectArea(cAliasSD1)
	dbSkip()

EndDo

oSection1:Finish()

//��������������������������������������������������������������Ŀ
//� Exclui o Arquivo Trabalho SD2 quando imprime NFs de devolucao�
//����������������������������������������������������������������
If mv_par07 == 1

	RetIndex("SD2")
	dbSelectArea("SD2")
	dbClearFilter()
	dbSetOrder(1)

	If File(cArqTrbSD2+OrdBagExt())
		Ferase(cArqTrbSD2+OrdBagExt())
	EndIf

EndIf

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PrintDevol� Autor �Alexandre Inacio Lemes �Data  �07/08/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime as devolucoes de compras SD2                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,nRecno)

Local nDecs    := Msdecimais(mv_par09) //casas decimais utilizadas na moeda da impressao
Local nX       := 0
Local nY       := 0
Local nSaveRec := If( lQuery, nRecno, Recno() )

oSection2:Init()

TRPosition():New(oSection2,"SB1",1,{|| xFilial("SB1")+SD2->D2_COD })

For nX :=1 to Len(aRecno)

	dbSelectArea("SD1")
	dbGoto(aRecno[nX])
	dbSelectArea("SD2")
	MsSeek(SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_DOC+SD1->D1_ITEM+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
	SF2->(MsSeek(SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))

	While !Eof() .And. SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_DOC+SD1->D1_ITEM+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==;
		SD2->D2_FILIAL+SD2->D2_COD+SD2->D2_NFORI+SD2->D2_ITEMORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA

		If nX == 1
			oReport:PrintText(STR0012,,oSection2:Cell("D2_DOC"):ColPos()) //'-Devolucoes:'
		Endif

		If lVeiculo
			oReport:PrintText("[ " + SD2->D2_CODITE + " ]",,oSection2:Cell("D2_COD"):ColPos())
		EndIf

		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf(SD2->D2_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:="SD2->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,SF2->F2_MOEDA,mv_par09,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next nY
		Endif

   		nValUnit := xmoeda(SD2->D2_PRCVEN,SF2->F2_MOEDA,mv_par09,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
		nValTot  := xmoeda(SD2->D2_TOTAL,SF2->F2_MOEDA,mv_par09,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
		nValCusto:= xmoeda(SD2->D2_CUSTO1,1,mv_par09,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)

		SA2->(dbSetOrder(1))
		SA2->(MsSeek( xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA ))
		cRazao := SA2->A2_NOME

		oSection2:PrintLine()

		dbSelectArea("SD2")
		dbSkip()

	EndDo

    If nX == Len(aRecno)
		oReport:ThinLine()
		oReport:SkipLine()
    EndIf

Next nX

oSection2:Finish()

dbSelectArea(cAliasSD1)
dbgoto(nSaveRec)
aRecno := {}

Return