#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} RELCOEST
Módulo: Compras
Tipo: Relatório
GEração de relatório em excel para conferência de Estoque. 
@since 10/09/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function RELCOEST()
Local oReport
Local lLandscape := .F.
Local aParambox	:= {}
Private cTitulo := "Conferência de Estoque"
Private cPerg := "RELCOEST"

	aAdd(aParamBox,{1,"Filial de:"			,CriaVar("B2_FILIAL" ,.f.),"","","SM0","",70,.F.}) //MV_PAR01
	aAdd(aParamBox,{1,"Filial até:"			,CriaVar("B2_FILIAL" ,.f.),"","","SM0","",70,.F.}) //MV_PAR02
	aAdd(aParamBox,{1,"Produto de:" 		,CriaVar("B2_COD",.f.),"","","SB1","",70,.F.}) //MV_PAR03
	aAdd(aParamBox,{1,"Produto até:"		,CriaVar("B2_COD",.f.),"","","SB1","",70,.F.}) //MV_PAR04
	aAdd(aParamBox,{1,"Data Fechameto:"  	,dDataBase,,"","","",70,.F.}) //MV_PAR05	
	
	If ParamBox(aParamBox,"Conferência de Estoque",,,,,,,,ProcName(),.T.,.T.)
		Processa({||oReport := ReportDef() },"Gerando Planilha..." )
	Endif

oReport:PrintDialog()

Return

Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},cTitulo,/*lLandscape*/,"Total de Descontos",.f.,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)

oSection1 := TRSection():New(oReport,"Conferência de Estoque","TMP")

TRCell():New(oSection1,"FILIAL"			,"TMP","Filial")
TRCell():New(oSection1,"CODIGO"			,"TMP","Codigo")
TRCell():New(oSection1,"DESCRICAO"		,"TMP","Descrição")
TRCell():New(oSection1,"TIPO"			,"TMP","Tipo")
TRCell():New(oSection1,"BLOQUEADO"		,"TMP","Bloqueado?")
TRCell():New(oSection1,"QTDATUAL"		,"TMP","Qtd. Atual")
TRCell():New(oSection1,"VALATUAL"		,"TMP","Val. Atual")
TRCell():New(oSection1,"CUSTOMEDIO"		,"TMP","Custo Médio")
TRCell():New(oSection1,"QTDDIFERIR"		,"TMP","Qtd. a Diferir")
TRCell():New(oSection1,"DATAEMISSAO"	,"TMP","Útima Baixa")
TRCell():New(oSection1,"DTDIGIT"		,"TMP","Ult. Compra")


Return oReport



/*/{Protheus.doc} RELCONNF
Módulo: Compras
Tipo: Relatório
GEração de relatório em excel para conferência de notas ficais/títulos financeiros. 
Função PrintReport
@type function
/*/

Static Function PrintReport(oReport)
Local oSection1 := oReport:Section(1)

oSection1:BeginQuery()

	BeginSql alias "TMP"
	
		select	B9_FILIAL	'FILIAL',
			B9_COD		'CODIGO',
			B1_DESC		'DESCRICAO', 
			B1_TIPO		'TIPO',
			case 
				when B1_MSBLQL = '1' then 'SIM'
				when B1_MSBLQL = '2' then 'NAO'
			end 'BLOQUEADO',
			B9_QINI		'QTDATUAL', 
			B9_VINI1	'VALATUAL', 
			B9_CM1		'CUSTOMEDIO',
			IsNull(Round((select Sum(ZE_QUANT) from SZE010 SZE where SZE.%NotDel% and ZE_COD = SB9.B9_COD and ZE_FILIAL = SB9.B9_FILIAL and ZE_DATA = ' '),6),0) as 'QTDDIFERIR',
			Convert(Date, Max(D1_DTDIGIT),103) 'DTDIGIT',
			iif (Max(D3_EMISSAO) is null, null, Convert(Date, Max(D3_EMISSAO),103)) 'DATAEMISSAO' 
		from %Table:SB9% as SB9
			inner	join %Table:SB1% as SB1 on B9_COD = B1_COD and B9_FILIAL = B1_FILIAL and SB1.%NotDel%
			left	join %Table:SD3% as SD3 on D3_FILIAL = B9_FILIAL and D3_COD = B9_COD and D3_ESTORNO <> 'S' and SD3.%NotDel%
			Left	Join %Table:SD1% as SD1 on D1_FILIAL = B9_FILIAL and D1_COD = B9_COD and D1_TIPO = 'N' and SD1.%NotDel%
		where SB9.%NotDel% and 
			B9_FILIAL between %Exp:MV_PAR01% and %Exp:MV_PAR02% and
			B9_COD between %Exp:MV_PAR03% and %Exp:MV_PAR04% and
			B9_DATA = %Exp:MV_PAR05% and
			B1_TIPO in ('MP','EC')
		group by B9_FILIAL, B9_COD, B1_DESC, B1_TIPO, B1_MSBLQL, B9_QINI, B9_VINI1, B9_CM1
		order by B9_FILIAL, B9_COD, B1_DESC, B1_TIPO, B1_MSBLQL, B9_QINI, B9_VINI1, B9_CM1
	
	ENDSQL

oSection1:EndQuery()

oSection1:Print()

return
