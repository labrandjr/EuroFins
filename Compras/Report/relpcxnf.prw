#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} RELPCXNF
GEração de relatório em excel para conferência de notas ficais x pedidos de Compras
@type function
@version 12.1.27
@author adm_tla8
@since 03/09/2019
/*/
user function RELPCXNF()
	Local oReport
	// Local lLandscape := .F.
	Local aParambox	:= {}
	Private cTitulo := "Conferência de nota fiscais x Pedido de Compras"
	Private cPerg := "RELPCXNF"


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
	// Local oSection2

	oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},cTitulo,/*lLandscape*/,"Total de Descontos",.f.,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)

	oSection1 := TRSection():New(oReport,"Conferência de NF Entrada","TMP")

	TRCell():New(oSection1,"FILIAL"			,"TMP","Filial")
	TRCell():New(oSection1,"CFORNECEDOR"	,"TMP","Cod. Fornec.")
	TRCell():New(oSection1,"LOJA"			,"TMP","Loja")
	TRCell():New(oSection1,"NFORNECEDOR"	,"TMP","Fornecedor")
	TRCell():New(oSection1,"DOCUMENTO"		,"TMP","Documento")
	TRCell():New(oSection1,"SERIE"			,"TMP","Serie")
	TRCell():New(oSection1,"TIPO"			,"TMP","Tipo")
	TRCell():New(oSection1,"ESPECIE"		,"TMP","Especie")
	TRCell():New(oSection1,"PEDIDO"			,"TMP","Pedido")
	TRCell():New(oSection1,"NFDTDIGIT"		,"TMP","Digitação NF")
	TRCell():New(oSection1,"NFEMISSAO"		,"TMP","Emissão NF")
	TRCell():New(oSection1,"PCEMISSAO"		,"TMP","Emissão PC")
	TRCell():New(oSection1,"DIFENTRA"		,"TMP","Dif. Emis. PCxNF")
	TRCell():New(oSection1,"SITUNF"			,"TMP","Situação NF")
	TRCell():New(oSection1,"MES"			,"TMP","Mês Digitação")
	TRCell():New(oSection1,"NOME"			,"TMP","Nome Usuario")
	TRCell():New(oSection1,"COUPA"			,"TMP","Ped. Coupa")
	TRCell():New(oSection1,"VLRPRD"			,"TMP","Valor Produto/NF")
	TRCell():New(oSection1,"APROVCD"		,"TMP","Aprovador (ACD)")
	TRCell():New(oSection1,"DATACD"			,"TMP","Data Aprov (ACD)")
	TRCell():New(oSection1,"CLASNF"			,"TMP","Status Class. NFiscal")

Return oReport


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
GEração de relatório em excel para conferência de notas ficais/títulos financeiros.
@type function
@version 12.1.27
@author adm_tla8
@since 09/12/2022
@param oReport, object, objeto do report
/*/
Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)

	oSection1:BeginQuery()

	BeginSql alias "TMP"

		select DISTINCT
			F1_FILIAL	'FILIAL',
			F1_FORNECE	'CFORNECEDOR',
			F1_LOJA		'LOJA',
			case
				when F1_TIPO in ('N','P','I','C') Then A2_NOME
				when F1_TIPO in ('D','B') Then A1_NOME
			end			'NFORNECEDOR',
			F1_DOC		'DOCUMENTO',
			F1_SERIE	'SERIE',
			F1_TIPO		'TIPO',
			F1_ESPECIE	'ESPECIE',
			D1_PEDIDO	'PEDIDO',
			C7_ITEM,
			CONVERT(DATE, F1_DTDIGIT, 103)	'NFDTDIGIT',
			CONVERT(DATE, F1_EMISSAO, 103)	'NFEMISSAO',
			CONVERT(DATE, C7_EMISSAO, 103)	'PCEMISSAO',
			Datediff(day, C7_EMISSAO,D1_EMISSAO) as 'DIFENTRA',
			case
				when Datediff(day,C7_EMISSAO,D1_EMISSAO) >= 0  then 'OK'
				when Datediff(day,C7_EMISSAO,D1_EMISSAO) < 0  then 'APOS EMISSAO NF'
			end 'SITUNF',
			SUBSTRING(F1_DTDIGIT,5,2) 'MES',
			C7_ZZCCOUP 'COUPA',
            D1_TOTAL AS 'VLRPRD',
            CONVERT(DATE, CR_DATALIB, 103) AS 'APROVCD',
            ISNULL(AK_NOME,'') AS 'DATACD',
            CASE WHEN F1_STATUS = '' AND (F1_STATCON IN ('1','4') OR F1_STATCON = '') THEN 'NF NAO CLASSIFICADA'
                 WHEN (F1_STATCON IN ('1','4') OR F1_STATCON = '') AND F1_TIPO = 'N' AND (F1_STATUS != 'B' AND F1_STATUS != 'C') THEN 'NF NORMAL'
                 WHEN F1_STATUS = 'B' THEN 'NF BLOQUEADA'
                 WHEN F1_STATUS = 'C' THEN 'NF BLOQUEADA S/CLASSF.'
                 WHEN F1_STATUS = 'D' THEN 'EVENTO DESACORDO AGUARDANDO SEFAZ'
                 WHEN F1_STATUS = 'E' THEN 'EVENTO DESACORDO VINCULADO'
                 WHEN F1_STATUS = 'F' THEN 'EVENTO DESACORDO COM PROBLEMAS'
                 WHEN (F1_STATCON IN ('1','4') OR F1_STATCON = '') AND F1_TIPO = 'P' THEN 'NF DE COMPL. IPI'
                 WHEN (F1_STATCON IN ('1','4') OR F1_STATCON = '') AND F1_TIPO = 'I' THEN 'NF DE COMPL. ICMS'
                 WHEN (F1_STATCON IN ('1','4') OR F1_STATCON = '') AND F1_TIPO = 'C' THEN 'NF DE COMPL. PRECO/FRETE'
                 WHEN (F1_STATCON IN ('1','4') OR F1_STATCON = '') AND F1_TIPO = 'B' THEN 'NF DE BENEFICIAMENTO'
                 WHEN (F1_STATCON IN ('1','4') OR F1_STATCON = '') AND F1_TIPO = 'D' THEN 'NF DE DEVOLUCAO'
                 WHEN (F1_STATCON IN ('1','4') AND F1_STATCON != '')  THEN 'NF BLOQ. PARA CONFERENCIA' ELSE '' END AS CLASNF,
                 ltrim(rtrim(C7_XSOLICI)) AS 'NOME'
		from %Table:SF1% as SF1
			inner join %Table:SD1% as SD1 on F1_FILIAL = D1_FILIAL and F1_FORNECE = D1_FORNECE and F1_LOJA = D1_LOJA and F1_DOC = D1_DOC and F1_SERIE = D1_SERIE and SD1.%NotDel% and F1_TIPO = D1_TIPO and D1_PEDIDO <> ' '
			left  join %Table:SC7% as SC7 on F1_FILIAL = C7_FILIAL and F1_FORNECE = C7_FORNECE and SC7.%NotDel% and D1_PEDIDO = C7_NUM and D1_ITEMPC = C7_ITEM and D1_COD = C7_PRODUTO
			left  join %Table:SA2% as SA2 on A2_COD = F1_FORNECE and A2_LOJA = F1_LOJA and SA2.%NotDel%
			left  join %Table:SA1% as SA1 on A1_COD = F1_FORNECE and A1_LOJA = F1_LOJA and SA1.%NotDel%
            left  join %Table:SCR% as SCR on CR_FILIAL = F1_FILIAL and CR_TIPO = 'NF' and CR_NUM = F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA AND CR_STATUS = '03' AND SCR.%NotDel%
            left  join %Table:SAK% as SAK on AK_FILIAL = CR_FILIAL and CR_TIPO = 'NF' and AK_COD = CR_APROV AND SAK.%NotDel%
		where	F1_DTDIGIT between %Exp:MV_PAR01% and %Exp:MV_PAR02% and
				F1_FORNECE between %Exp:MV_PAR05% and %Exp:MV_PAR07% and
				F1_LOJA	   between %Exp:MV_PAR06% and %Exp:MV_PAR08% and
				F1_FILIAL  between %Exp:MV_PAR03% and %Exp:MV_PAR04% and
				SF1.%NotDel%
		order by 1,5,6,4,2,3,7,8,9,10,11,12,13

	ENDSQL

	oSection1:EndQuery()

	oSection1:Print()

return
