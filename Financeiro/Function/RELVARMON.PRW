#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE 'TOPCONN.CH'

User Function RelVarMon()

	Local cPerg		:= "RELVAR"
	local cAlias := getNextAlias()

	Pergunte(cPerg,.T.)

	oReport := reportDef(cAlias, cPerg)
	oReport:printDialog()

Return

//------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function ReportPrint(oReport,cAlias)

	local oSecao1 := oReport:Section(1)

	oSecao1:BeginQuery()

	IF MV_PAR01 == 1

		BeginSQL Alias cAlias
        SELECT
        ZVM.ZVM_FILIAL AS 'FILIAL'
        , ZVM.ZVM_PREFIX AS 'PREFIX'
        , ZVM.ZVM_NUM AS 'TITULO'
        , ZVM.ZVM_TIPO AS 'TIPO'
        , ZVM.ZVM_CLIFOR AS 'FORNECEDOR'
        , ZVM.ZVM_LOJA AS 'LOJA'
        , RTRIM(SA2.A2_NOME) AS 'NOME'
        , RTRIM(SA2.A2_NREDUZ) AS 'NOME_REDUZ'
        , CONVERT(VARCHAR,CONVERT(DATE,ZVM_EMISSA,121),103)  AS 'DT_EMISSAO'
        , CONVERT(VARCHAR,CONVERT(DATE,ZVM_VENCRE,121),103) AS 'DE_VENCTO'
        , ZVM.ZVM_VALOR AS 'VALOR_VARIACAO'
        , ZVM.ZVM_SALDO AS 'SALDO'
        , ZVM.ZVM_VLCRUZ AS 'SALDO_VLCRUZ'
        , ZVM.ZVM_MOEDA AS 'MOEDA'
        , CONVERT(VARCHAR,CONVERT(DATE,ZVM_DTVAR,121),103) AS 'DATA_VARIACAO'
        , ZVM.ZVM_TXFISC AS 'TAXA_VARIACAO
        FROM %table:ZVM%  AS ZVM
        INNER JOIN %table:SA2% AS SA2 ON SA2.%notDel%
        AND SA2.A2_COD = ZVM_CLIFOR
        AND SA2.A2_LOJA = ZVM_LOJA
        WHERE ZVM.%notDel%
        AND ZVM_DTVAR   BETWEEN %Exp:DTOS(MV_PAR02)% AND %Exp:DTOS(MV_PAR03)%
        AND ZVM_VALOR <> 0
		EndSQL
	ELSE
		BeginSQL Alias cAlias
		SELECT
		ZVM.ZVM_FILIAL AS 'FILIAL'
		, ZVM.ZVM_PREFIX AS 'PREFIX'
		, ZVM.ZVM_NUM AS 'TITULO'
		, ZVM.ZVM_TIPO AS 'TIPO'
        , ZVM.ZVM_CLIFOR AS 'CLIENTE'
        , ZVM.ZVM_LOJA AS 'LOJA'
		, RTRIM(SA1.A1_NOME) AS 'NOME'
		, RTRIM(SA1.A1_NREDUZ) AS 'NOME_REDUZ'
		, CONVERT(VARCHAR,CONVERT(DATE,ZVM_EMISSA,121),103)  AS 'DT_EMISSAO'
		, CONVERT(VARCHAR,CONVERT(DATE,ZVM_VENCRE,121),103) AS 'DE_VENCTO'
		, ZVM.ZVM_VALOR AS 'VALOR_VARIACAO'
		, ZVM.ZVM_SALDO AS 'SALDO'
		, ZVM.ZVM_VLCRUZ AS 'SALDO_VLCRUZ'
		, ZVM.ZVM_MOEDA AS 'MOEDA'
		, CONVERT(VARCHAR,CONVERT(DATE,ZVM_DTVAR,121),103) AS 'DATA_VARIACAO'
		, ZVM.ZVM_TXFISC AS 'TAXA_VARIACAO
		FROM %table:ZVM%  AS ZVM
		INNER JOIN %table:SA1% AS SA1 ON SA1.%notDel%
		AND SA1.A1_COD = ZVM_CLIFOR
		AND SA1.A1_LOJA = ZVM_LOJA
		WHERE ZVM.%notDel%
		AND ZVM_DTVAR   BETWEEN %Exp:DTOS(MV_PAR02)% AND %Exp:DTOS(MV_PAR03)%
		AND ZVM_VALOR <> 0
		EndSQL
	ENDIF

	IF(RAT(".prt", oreport:cfile) > 0)
		//alert("Impressão via .prt")
	ELSEIF(RAT(".xml", oreport:cfile) > 0)
		//alert("Impressão via .xml")
	ENDIF

	oSecao1:EndQuery()
	oReport:SetMeter((cAlias)->(RecCount()))
	oSecao1:Print()

return

//------------------------------------------------------------------------------------------------------------------------------------------------------------------


Static Function ReportDef(cAlias, cPerg)

	local cTitle := "Relat?? de Varia? Monet?a"
	local cHelp := "Permite a impress?do relat?? com os valores de varia? monet?a de determinado per?o"
	local oReport
	local oSection1


	Pergunte(cPerg, .f.)

	oReport := TReport():New('RELVARMON',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

	//Primeira sessao
	oSection1 := TRSection():New(oReport,"Varia? Monet?a por T?lo",{cAlias})
    /*

oParent			Objeto			Objeto da classe TRSection que a c?la pertence
cName			Caracter		Nome da c?la
cAlias			Caracter		Tabela utilizada pela c?la
cTitle			Caracter		T?lo da c?la
cPicture		Caracter		Mascara da c?la
nSize*			Num?co		Tamanho da c?la
lPixel			L??o			Aponta se o tamanho foi informado em pixel
bBlock			Bloco de C??o	Bloco de c??o com o retorno do campo
cAlign			Caracter		Alinhamento da c?la. ?LEFT?, ?RIGHT? e ?CENTER?
lLineBreak		L??o			Quebra linha se o conteúdo estourar o tamanho do campo
cHeaderAlign	Caracter		Alinhamento do cabe?ho da c?la. ?LEFT?, ?RIGHT? e ?CENTER?
lCellBreak		L??o			Compatibilidade ? N?utilizado
nColSpace		Num?co		Espa?ento entre as c?las
lAutoSize**		L??o			Ajusta o tamanho da c?la com base no tamanho da p?na e as informa?s impressas
nClrBack		Num?co		Cor de fundo da c?la
nClrFore		Num?co		Cor da fonte da c?la
lBold			L??o			Imprime a fonte em negrito
    */

	ocell2  := TRCell():New(oSection1,"FILIAL", cAlias, "Filial",PesqPict('ZVM',"ZVM_FILIAL"),TamSX3("ZVM_FILIAL")[1]+1,,,"LEFT",,"LEFT")
	ocell2  := TRCell():New(oSection1,"PREFIX", cAlias, "Prefixo",PesqPict('ZVM',"ZVM_PREFIX"),TamSX3("ZVM_PREFIX")[1]+1,,,"CENTER",,"CENTER" 	)
	ocell2  := TRCell():New(oSection1,"TITULO", cAlias, "T?lo",PesqPict('ZVM',"ZVM_NUM") ,TamSX3("ZVM_NUM")[1]+1,,,"CENTER",,"CENTER" )
	ocell2  := TRCell():New(oSection1,"TIPO", cAlias, "Tipo",PesqPict('ZVM',"ZVM_TIPO"),TamSX3("ZVM_TIPO")[1]+1,,,"CENTER",,"CENTER")
	IF MV_PAR01 == 1
		ocell2  := TRCell():New(oSection1,"FORNECEDOR", cAlias, "Cod Fornece",PesqPict('ZVM',"ZVM_CLIFOR"),TamSX3("ZVM_CLIFOR")[1]+3,,,"CENTER",,"CENTER")
	ELSE
		ocell2  := TRCell():New(oSection1,"CLIENTE", cAlias, "Cod Cli",PesqPict('ZVM',"ZVM_CLIFOR"),TamSX3("ZVM_CLIFOR")[1]+1,,,"CENTER",,"CENTER")
	ENDIF
	ocell2  := TRCell():New(oSection1,"LOJA", cAlias, "Loja",PesqPict('ZVM',"ZVM_LOJA"),TamSX3("ZVM_LOJA")[1]+1,,,"CENTER",,"CENTER")
	IF MV_PAR01 == 1
		ocell2  := TRCell():New(oSection1,"NOME_REDUZ", cAlias, "Raz",PesqPict('SA2',"A2_NREDUZ"),TamSX3("A2_NREDUZ")[1]+1,,,"CENTER",,"CENTER")
	ELSE
		ocell2  := TRCell():New(oSection1,"NOME_REDUZ", cAlias, "Raz",PesqPict('SA1',"A1_NREDUZ"),TamSX3("A1_NREDUZ")[1]+1,,,"CENTER",,"CENTER")
	ENDIF
	ocell2  := TRCell():New(oSection1,"DT_EMISSAO", cAlias, "Emissao",PesqPict('ZVM',"ZVM_EMISSA"),TamSX3("ZVM_EMISSA")[1]+4,,,"CENTER",,"CENTER")
	ocell2  := TRCell():New(oSection1,"DE_VENCTO", cAlias, "Dt Vencto",PesqPict('ZVM',"ZVM_VENCRE"),TamSX3("ZVM_VENCRE")[1]+4,,,"CENTER",,"CENTER")
    ocell2  := TRCell():New(oSection1,"VALOR_VARIACAO", cAlias, "Variacao",PesqPict('ZVM',"ZVM_VALOR"),TamSX3("ZVM_VALOR")[1]+1,,,"CENTER",,"CENTER")
	ocell2  := TRCell():New(oSection1,"SALDO", cAlias, "Saldo",PesqPict('ZVM',"ZVM_SALDO"),TamSX3("ZVM_SALDO")[1]+1,,,"CENTER",,"CENTER")
	ocell2  := TRCell():New(oSection1,"SALDO_VLCRUZ", cAlias, "Saldo Moeda",PesqPict('ZVM',"ZVM_VLCRUZ"),TamSX3("ZVM_VLCRUZ")[1]+1,,,"CENTER",,"CENTER")
    ocell2  := TRCell():New(oSection1,"MOEDA", cAlias, "Moeda",PesqPict('ZVM',"ZVM_MOEDA"),TamSX3("ZVM_MOEDA")[1]+1,,,"CENTER",,"CENTER")
    ocell2  := TRCell():New(oSection1,"DATA_VARIACAO", cAlias, "Dt Variacao",PesqPict('ZVM',"ZVM_DTVAR"),TamSX3("ZVM_DTVAR")[1]+4,,,"CENTER",,"CENTER")
    ocell2  := TRCell():New(oSection1,"TAXA_VARIACAO", cAlias, "Tx Variacao",PesqPict('ZVM',"ZVM_TXFISC"),TamSX3("ZVM_TXFISC")[1]+1,,,"CENTER",,"CENTER")

	oBreak := TRBreak():New(oSection1,oSection1:Cell("FORNECEDOR"),"Sub Total Varia?")
	oSection1:SetHeaderBreak(.F.)
    //TRFunction():New(oSection1:Cell("A1_COD"),NIL,"COUNT",oBreak)
    TRFunction():New(oSection1:Cell("VALOR_VARIACAO"),NIL,"SUM",oBreak,"",,,.F.,.F.)


Return(oReport)

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
