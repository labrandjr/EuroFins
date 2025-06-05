#Include 'Protheus.ch'
#Include "totvs.ch"

/*/{protheus.doc}
Gera Planilha Excel referente ao Transfer Price
Necessidade Rosiani - Contábil

@author Régis Ferreira
@since 16/12/2021
/*/

User Function EuroTPric()

	Local aArea := GetArea()
	Local aParambox   := {}
	Private oFWMsExcel
	Private cWorkSheet := "EuroTPric"
	Private cTitulo    := "Relatório Transfer Price"
	
	//Adicionando os parametros do ParamBox
	aAdd(aParamBox,{1,"Data Emissão de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
    aAdd(aParamBox,{1,"Data Emissão até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02
    aAdd(aParamBox,{1,"Filial de:"			,CriaVar("F2_FILIAL",.f.),"","","SM0","",70,.F.}) //MV_PAR03
    aAdd(aParamBox,{1,"Filial Ate:"			,CriaVar("F2_FILIAL",.f.),"","","SM0","",70,.T.}) //MV_PAR04
    
    If ParamBox(aParamBox,"Transfer Price",,,,,,,,ProcName(),.T.,.T.)
        Processa({||fGeraExcel() },"Gerando Planilha..." )
    Endif

	RestArea(aArea)
Return

/*
 Programa		:	fGeraExcel
 Autor			:	Régis Ferreira - Totvs IP
 Data			:	16/12/2021
 Descricao		:	Criacao do arquivo Excel na funcao EuroTpRic
 Cliente		:	Eurofins
 */

Static Function fGeraExcel()
	Local cQuery    := ""
	Local oExcel
	Local cArquivo  := GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
    Local nAtual    := 0
	
	cQuery += " select " + CRLF
    cQuery += "	    D2_FILIAL, " + CRLF
    cQuery += "	    D2_COD, " + CRLF
    cQuery += "	    B1_DESC, " + CRLF
    cQuery += "	    CTT_CUSTO, " + CRLF
    cQuery += "	    CTT_DESC01, " + CRLF
    cQuery += "	    CT1_CONTA, " + CRLF
    cQuery += "	    CT1_DESC01, " + CRLF
    cQuery += "	    CONVERT(VARCHAR(10),CONVERT(Date, D2_EMISSAO),103) D2_EMISSAO, " + CRLF
    cQuery += "	    D2_DOC+'/'+D2_SERIE D2_DOC, " + CRLF
    cQuery += "	    D2_CLIENTE+'/'+D2_LOJA D2_CLIENTE, " + CRLF
    cQuery += "	    A1_NOME, " + CRLF
    cQuery += "	    A1_EST, " + CRLF
    cQuery += "	    D2_TOTAL, " + CRLF
    cQuery += "	    D2_ZZNROCE, " + CRLF
    cQuery += "	    A1_ZZCOLIG " + CRLF
    cQuery += "	from "+RetSqlName("SD2")+" as SD2 " + CRLF
    cQuery += "	    left join  "+RetSqlName("CTT")+"  as CTT on CTT_CUSTO = D2_CCUSTO AND CTT.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "	    left join  "+RetSqlName("CT1")+"  as CT1 on CT1_CONTA = D2_CONTA AND CT1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "	    left join  "+RetSqlName("SA1")+"  as SA1 on A1_COD = D2_CLIENTE and A1_LOJA = D2_LOJA AND SA1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "	    left join  "+RetSqlName("SX5")+"  as SX5 on X5_TABELA = 'T3' and X5_CHAVE = A1_SATIV1 and D2_FILIAL = X5_FILIAL AND SX5.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "	    left join  "+RetSqlName("SB1")+"  as SB1 on B1_COD = D2_COD AND D2_FILIAL = B1_FILIAL AND SB1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "	    inner join "+RetSqlName("SF2")+"  as SF2 on F2_DOC = D2_DOC and F2_FILIAL = D2_FILIAL AND D2_SERIE = F2_SERIE and D2_CLIENTE = F2_CLIENTE and D2_LOJA = F2_LOJA and SF2.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "	where " + CRLF
    cQuery += "	    B1_TIPO like 'SA' " + CRLF
    cQuery += "	    and D2_EMISSAO Between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' " + CRLF
    cQuery += "	    and D2_FILIAL  Between '"+mv_par03+"' and '"+mv_par04+"' " + CRLF
    cQuery += "	    and SD2.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "	Order by 1,9,14 " + CRLF
		
	//Executando consulta e setando o total da regua
	PlsQuery(cQuery, "QRY_TRPRI")
	DbSelectArea("QRY_TRPRI")
	
	//Cria a planilha do excel
	oFWMsExcel := FWMSExcel():New()
	
	//Criando a aba da planilha
	oFWMsExcel:AddworkSheet(cWorkSheet)
	
	//Criando a Tabela e as colunas
	oFWMsExcel:AddTable(cWorkSheet, cTitulo)
	
	//oFWMsExcel:AddColumn(cWorkSheet, cTitulo, Coluna, (1-Esquerda 2-Centralizado 3-Direita),(1-Geral 2-Numerico 3-Monetário 4-Data, Totalizar? .T. ou .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Filial"				, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Produto"     		, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Descrição"       	, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Centro Custo"    	, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Descrição"			, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Conta Contabil"		, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Descrição"   		, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Data Emissão"		, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Documento/Serie" 	, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Cliente/Loja"    	, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Nome"            	, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Estado"  			, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Total NF"			, 1, 3, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "N. Certificado"		, 2, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Coligada?"		    , 2, 1, .F.)
	
	//Definindo o tamanho da regua
	Count To nTotal
	ProcRegua(nTotal)
	QRY_TRPRI->(DbGoTop())
	
	//Percorrendo os dados da query
	While !(QRY_TRPRI->(EoF()))
		
		//Incrementando a regua
		nAtual++
		IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		
		//Adicionando uma nova linha
		oFWMsExcel:AddRow(cWorkSheet, cTitulo,;
            {QRY_TRPRI->D2_FILIAL,;
			QRY_TRPRI->D2_COD,;
			QRY_TRPRI->B1_DESC,;
			QRY_TRPRI->CTT_CUSTO,;
			QRY_TRPRI->CTT_DESC01,;
			QRY_TRPRI->CT1_CONTA,;
			QRY_TRPRI->CT1_DESC01,;
			QRY_TRPRI->D2_EMISSAO,;
			QRY_TRPRI->D2_DOC,;
			QRY_TRPRI->D2_CLIENTE,;
			QRY_TRPRI->A1_NOME,;
			QRY_TRPRI->A1_EST,;
			QRY_TRPRI->D2_TOTAL,;
			QRY_TRPRI->D2_ZZNROCE,;
			QRY_TRPRI->A1_ZZCOLIG;
		})

		QRY_TRPRI->(DbSkip())
	EndDo
	QRY_TRPRI->(DbCloseArea())
	
	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
	
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()
	oExcel:WorkBooks:Open(cArquivo)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()
	
Return
