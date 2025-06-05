#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FATINCON
Módulo: FATURAMENTO
Tipo: Relatório
Gera relatório de inconsitências no preenchimento dos pedidos de venda 
@since 17/09/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function FATINCON()
Local oReport
Local lLandscape := .F.
Private cTitulo := "Conferência de Pedidos de Venda"
Private cPerg := "FATINCON"
		
	Processa({||oReport := ReportDef() },"Gerando Planilha..." )

oReport:PrintDialog()

Return

Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},cTitulo,/*lLandscape*/,"Total de Descontos",.f.,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)

oSection1 := TRSection():New(oReport,"Conferência de Pedidos de Venda","TMP")

TRCell():New(oSection1,"NUMPV"		,"TMP","Num. Pedido")
TRCell():New(oSection1,"EMISSAO"	,"TMP","Emissão Pedido")
TRCell():New(oSection1,"FORNISS"	,"TMP","Forn. ISS")
TRCell():New(oSection1,"ESTPRES"	,"TMP","UF Prestação")
TRCell():New(oSection1,"MUNPRES"	,"TMP","Mun. Prestação")
TRCell():New(oSection1,"ITEM"		,"TMP","ITEM")
TRCell():New(oSection1,"PRODUTO"	,"TMP","Produto")
TRCell():New(oSection1,"CODISS"		,"TMP","Cod. ISS")
TRCell():New(oSection1,"CC"			,"TMP","Centro de Custo")
TRCell():New(oSection1,"CCUSTO"		,"TMP","Centro de Custo")
TRCell():New(oSection1,"CONTA"		,"TMP","Conta")

Return oReport



/*/{Protheus.doc} FATINCON
Módulo: FATURAMNETO
Tipo: Relatório
Gera relatório de inconsitências no preenchimento dos pedidos de venda 
Função PrintReport
@type function
/*/

Static Function PrintReport(oReport)
Local oSection1 := oReport:Section(1)

oSection1:BeginQuery()

	BeginSql alias "TMP"
	
		select 
			C6_NUM		'NUMPV', 
			CONVERT(DATE, C5_EMISSAO,103)	'EMISSAO', 
			C5_FORNISS	'FORNISS', 
			C5_ESTPRES	'ESTPRES', 
			C5_MUNPRES	'MUNPRES', 
			C6_ITEM		'ITEM', 
			C6_PRODUTO	'PRODUTO', 
			C6_CODISS	'CODISS', 
			C6_CC		'CC', 
			C6_CONTA	'CONTA' 
		from %Table:SC6% as SC6
			left join %Table:SC5% as SC5 on C5_LOJACLI = C6_LOJA and C5_NUM = C6_NUM and C5_CLIENT = C6_CLI and SC5.%NotDel% and C5_FILIAL = C6_FILIAL
			left join %Table:SB1% as SB1 on B1_COD = C6_PRODUTO and B1_FILIAL = C6_FILIAL and SB1.%NotDel%
		where (C6_CODISS = ' ' or C6_CC = ' ' or C6_CONTA = ' ' or C5_FORNISS = ' ' or C5_ESTPRES = ' ' or C5_MUNPRES = ' ')
		and SC6.%NotDel%
		and C6_BLQ = ' '
		and C6_FILIAL = %Exp:cFilAnt%
		and B1_TIPO = 'SA'
		and C6_QTDVEN > C6_QTDENT
		and C6_NOTA = ' '
		order by C6_NUM, C6_ITEM
	
	ENDSQL

oSection1:EndQuery()

oSection1:Print()

return
