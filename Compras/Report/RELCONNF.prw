#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} RELCONNF
Módulo: Compras
Tipo: Relatório
GEração de relatório em excel para conferência de notas ficais/títulos financeiros. 
@since 03/09/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function RELCONNF()
Local oReport
Local lLandscape := .F.
Local aParambox	:= {}
Private cTitulo := "Conferência de nota fiscais"
Private cPerg := "RELCONNF"


	aAdd(aParamBox,{1,"Data Digitação de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
	aAdd(aParamBox,{1,"Data Digitação até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02
	aAdd(aParamBox,{1,"Filial de:"			,CriaVar("F1_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR03
	aAdd(aParamBox,{1,"Filial até:"			,CriaVar("F1_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR04
	aAdd(aParamBox,{1,"Fornecedor de:" 		,CriaVar("F1_FORNECE",.f.),"","","SA2","",70,.F.}) //MV_PAR05
	aAdd(aParamBox,{1,"Loja de:" 			,CriaVar("F1_LOJA ",.f.),"","","","",70,.F.}) //MV_PAR06
	aAdd(aParamBox,{1,"Fornecedor até:"		,CriaVar("F1_FORNECE",.f.),"","","SA2","",70,.F.}) //MV_PAR07
	aAdd(aParamBox,{1,"Loja até:" 			,CriaVar("F1_LOJA ",.f.),"","","","",70,.F.}) //MV_PAR08
	If ParamBox(aParamBox,"Notas Fiscais de Entrada",,,,,,,,ProcName(),.T.,.T.)
		Processa({||oReport := ReportDef() },"Gerando Planilha..." )
	Endif

	oReport:PrintDialog()

Return

Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},cTitulo,/*lLandscape*/,"Total de Descontos",.f.,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)

oSection1 := TRSection():New(oReport,"Conferência de NF Entrada","TMP")

TRCell():New(oSection1,"FILIAL"			,"TMP","Filial")
TRCell():New(oSection1,"TIPO"			,"TMP","TIPO")
TRCell():New(oSection1,"ESPECIE"		,"TMP","Especie")
TRCell():New(oSection1,"NFISCAL"		,"TMP","Nota Fiscal")
TRCell():New(oSection1,"SERIE"			,"TMP","Serie")
TRCell():New(oSection1,"CODIGO_FOR"		,"TMP","Cód. Forn.")
TRCell():New(oSection1,"LOJA_FOR"		,"TMP","Loja")
TRCell():New(oSection1,"FORNECEDOR"		,"TMP","Fornecedor")
TRCell():New(oSection1,"CENTROCUSTO"	,"TMP","Centro de Custo")
TRCell():New(oSection1,"EMISSAO"		,"TMP","Dt Emissão")
TRCell():New(oSection1,"ENTRADA"		,"TMP","Dt Digitação")
TRCell():New(oSection1,"VALOR_BRUTO"	,"TMP","Valor Total")
TRCell():New(oSection1,"VENCTO"			,"TMP","Vencimento")
TRCell():New(oSection1,"VENC_REAL"		,"TMP","Vencto. Real")
TRCell():New(oSection1,"DIFVENCTO"		,"TMP","Dif. Vencto")
TRCell():New(oSection1,"DIFENTRA"		,"TMP","Dif. Entrada")
TRCell():New(oSection1,"COMPETENCIA"	,"TMP","Competencia")

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
	
		SELECT DISTINCT
			SF1.F1_FILIAL AS FILIAL,
			SF1.F1_TIPO as TIPO,
			SF1.F1_ESPECIE as ESPECIE,
			SF1.F1_DOC AS NFISCAL,
			SF1.F1_SERIE AS SERIE,
			SF1.F1_FORNECE AS CODIGO_FOR,
			SF1.F1_LOJA AS LOJA_FOR,
			SE2.E2_NOMFOR AS FORNECEDOR,
			SD1.D1_CC as CENTROCUSTO,
			CONVERT(DATE, SF1.F1_EMISSAO, 103) AS EMISSAO,
			CONVERT(DATE,SF1.F1_DTDIGIT, 103) AS ENTRADA,
			//SF1.F1_VALBRUT AS VALOR_BRUTO,
			SD1.D1_TOTAL as VALOR_BRUTO,
			CONVERT(DATE, SE2.E2_VENCTO, 103) AS VENCTO,
			CONVERT(DATE, SE2.E2_VENCREA, 103) AS VENC_REAL,
			case 
				when Datediff(day,F1_DTDIGIT,E2_VENCREA)   < 0 then 'VENCIDO'
				when Datediff(day,F1_DTDIGIT,E2_VENCREA) >= 0 then 'OK'
			end DIFVENCTO,
			Datediff(day,F1_EMISSAO,F1_DTDIGIT) as DIFENTRA,
			case 
				when Datediff(MONTH,F1_EMISSAO,F1_DTDIGIT) > 0 then 'FORA DO MES'
				when Datediff(MONTH,F1_EMISSAO,F1_DTDIGIT) = 0 then 'DENTRO DO MES'
			end COMPETENCIA
		FROM %Table:SF1% SF1
			LEFT JOIN %Table:SE2% as SE2 ON SE2.E2_FILIAL = SF1.F1_FILIAL AND SE2.E2_PREFIXO = SF1.F1_SERIE AND SE2.E2_NUM = SF1.F1_DOC AND SE2.E2_FORNECE = SF1.F1_FORNECE AND SE2.E2_LOJA = SF1.F1_LOJA AND SE2.%NotDel%
			LEFT JOIN %Table:SD1% as SD1 on D1_FILIAL = F1_FILIAL and D1_FORNECE = F1_FORNECE and D1_LOJA = F1_LOJA and D1_DOC = F1_DOC and D1_SERIE = F1_SERIE and SD1.%NotDel%
		WHERE SF1.%NotDel%
			AND SF1.F1_DTDIGIT BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND SF1.F1_FILIAL BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND SF1.F1_FORNECE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07%
			AND SF1.F1_LOJA BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08%
			AND SF1.F1_DUPL <> ' '
		ORDER BY 1,4,5 
	
	ENDSQL

oSection1:EndQuery()

oSection1:Print()

return
