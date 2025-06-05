#include "totvs.ch"
#include "topconn.ch"
#Include 'Protheus.ch'

#DEFINE ENTER "&#13;&#10;"

/*
 Programa		:	RELAPVCT2
 Autor			:	Régis Ferreira - Totvs IP
 Data			:	22/06/2022
 Descricao		:	Relatório de contabilização
 */

User Function RELAPVCT2()

	Local aArea         := GetArea()
	Private oProcess	:= Nil
	Private oFWMsExcel
	Private cWorkSheet  := "CT2"
	Private cTitulo     := "Relatorio de Aprova/Reprova de Contabilidade"

	If PergParam()

		oProcess:= MsNewProcess():New({|| fGeraExcel()}, "Buscando Dados", "...", .F.)
		oProcess:ACTIVATE()

	Endif

	RestArea(aArea)

Return

/*
 Programa		:	fGeraExcel
 Autor			:	Régis Ferreira - Totvs IP
 Data			:	22/06/2022
 Descricao		:	Criacao do arquivo Excel na funcao
 */
Static Function fGeraExcel()
	Local cQuery     := ""
	Local oExcel
	Local cArquivo   := GetTempPath() + GetNextAlias()+".xls"
	Local nAtual     := 0
	Local nTotal     := 0
	Local cAlias     := GetNextAlias()
	Local cTipoLanc	 := ""
	Local cManuAuto	 := ""

	cQuery := " Select "                                                                                                                                        + CRLF
	cQuery += "     CT2_FILIAL CT2_FILIAL, "                                                                                                                    + CRLF
	cQuery += "     CT2_DC CT2_DC, "                                                                                                                            + CRLF
	cQuery += "     CT2_MANUAL CT2_MANUAL, "                                                                                                                    + CRLF
	cQuery += "     CT2_DATA CT2_DATA, "                                                                                                                        + CRLF
	cQuery += "     CT2_LOTE CT2_LOTE,"                                                                                                                         + CRLF
	cQuery += "     CT2_SBLOTE CT2_SBLOTE, "                                                                                                                    + CRLF
	cQuery += "     CT2_DOC CT2_DOC, "                                                                                                                          + CRLF
	cQuery += "     CT2_LINHA CT2_LINHA, "                                                                                                                      + CRLF
	cQuery += "     CT2_DEBITO CT2_DEBITO, "                                                                                                                    + CRLF
	cQuery += "     CT1DEB.CT1_DESC01 CONTADEB, "                                                                                                               + CRLF
	cQuery += "     CT2_CREDIT CT2_CREDIT, "                                                                                                                    + CRLF
	cQuery += "     CT1CRE.CT1_DESC01 CONTACRE, "                                                                                                               + CRLF
	cQuery += "     CT2_VALOR CT2_VALOR, "                                                                                                                      + CRLF
	cQuery += "     CT2_HIST CT2_HIST, "                                                                                                                        + CRLF
	cQuery += "     CT2_CCD CT2_CCD, "                                                                                                                          + CRLF
	cQuery += "     CTTDEB.CTT_DESC01 CUSTODEB, "                                                                                                               + CRLF
	cQuery += "     CT2_CCC CT2_CCC, "                                                                                                                          + CRLF
	cQuery += "     CTTCRE.CTT_DESC01 CUSTOCRE, "                                                                                                               + CRLF
	cQuery += "     CT2_TPSALD CT2_TPSALD, "                                                                                                                    + CRLF
	cQuery += "     X5_DESCRI X5_DESCRI, "                                                                                                                      + CRLF
	cQuery += "     CT2_ORIGEM CT2_ORIGEM, "                                                                                                                    + CRLF
	cQuery += "     CT2_ROTINA CT2_ROTINA, "                                                                                                                    + CRLF
	//cQuery += "     ISNULL(CAST(CAST(CT2_ZZAPRO AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS CT2_ZZAPRO,"                                                       + CRLF
	//cQuery += "     ISNULL(CAST(CAST(CT2_ZZMOTI AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS CT2_ZZMOTI"                                                        + CRLF
	cQuery += "     ISNULL(CAST(CAST(ZZI_ZZAPRO AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS ZZI_ZZAPRO,"                                                       + CRLF
	cQuery += "     ISNULL(CAST(CAST(ZZI_ZZMOTI AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS ZZI_ZZMOTI"                                                        + CRLF
	cQuery += " from "                                                                                                                                          + CRLF
	cQuery += "     "+RetSqlName("CT2")+ " CT2 "                                                                                                                + CRLF
	cQuery += "     Left Join "+RetSqlName("CT1")+ " CT1DEB on CT1DEB.CT1_CONTA = CT2_DEBITO and CT1DEB.D_E_L_E_T_ = ' '"                                       + CRLF
	cQuery += "     Left Join "+RetSqlName("CT1")+ " CT1CRE on CT1CRE.CT1_CONTA = CT2_CREDIT and CT1CRE.D_E_L_E_T_ = ' '"                                       + CRLF
	cQuery += "     Left Join "+RetSqlName("CTT")+ " CTTDEB on CTTDEB.CTT_CUSTO = CT2_CCD and CTTDEB.D_E_L_E_T_ = ' '"                                          + CRLF
	cQuery += "     Left Join "+RetSqlName("CTT")+ " CTTCRE on CTTCRE.CTT_CUSTO = CT2_CCC and CTTCRE.D_E_L_E_T_ = ' '"                                          + CRLF
	cQuery += "     Left Join "+RetSqlName("SX5")+ " SX5 on X5_TABELA = 'SL' and CT2_FILIAL = X5_FILIAL and X5_CHAVE = CT2_TPSALD and "+RetSqlDel("SX5")        + CRLF
	cQuery += "     Left Join "+RetSqlName("ZZI")+ " ZZI on ZZI.ZZI_CHAVE = CT2.CT2_DATA+CT2.CT2_LOTE+CT2.CT2_SBLOTE+CT2.CT2_DOC and ZZI_FILIAL = CT2_FILIAL and ZZI.D_E_L_E_T_ = ' '" + CRLF
	cQuery += " where "                                                                                                                                         + CRLF
	cQuery += "     "+RetSqlDel("CT2")                                                                                                                          + CRLF
	cQuery += "     and CT2_DATA between    '"+dTos(MV_PAR03)+"' and '"+dTos(MV_PAR04)+"'"                                                                      + CRLF
	cQuery += "     and CT2_LOTE between    '"+MV_PAR05+"' and '"+MV_PAR06+"'"                                                                                  + CRLF
	cQuery += "     and CT2_FILIAL between  '"+MV_PAR01+"' and '"+MV_PAR02+"'"                                                                                  + CRLF
	if MV_PAR07 == "2"
		cQuery += " and CT2_TPSALD = 'X' "                                                                                                                      + CRLF
	elseif MV_PAR07 == "3"
		cQuery += " and CT2_TPSALD = 'Y' "                                                                                                                      + CRLF
	endif
	cQuery += " Order by 1,2,3,4,5,6"

	//Executando consulta e setando o total da regua
	oProcess:IncRegua1("Gerando Planilha Contabil")
	TcQuery cQuery New Alias &cAlias

	//Cria a planilha do excel
	oFWMsExcel := FWMSExcel():New()

	//Criando a aba da planilha
	oFWMsExcel:AddworkSheet(cWorkSheet)

	//Criando a Tabela e as colunas
	oFWMsExcel:AddTable(cWorkSheet, cTitulo)

	//oFWMsExcel:AddColumn(cWorkSheet, cTitulo, Coluna, (1-Esquerda 2-Centralizado 3-Direita),(1-Geral 2-Numerico 3-Monetário 4-Data, Totalizar? .T. ou .F.)
	//oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Usuário Inclusão"	    , 1, 1, .F.)
	//oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Usuário Alteração"	    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Filial"				    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Nome Filial"			    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Lancam. Man/Auto"   	    , 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Data Contab."      	    , 2, 4, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Lote"	        	    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Sub Lote"        	    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Documento"       	    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Linha"   			    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Tipo de Lancamento"	    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Conta Debito"		    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Descricao Conta Debito"	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Conta Credito"		    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Descricao Conta Credito" , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Valor"				    , 3, 3, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Historico"   	        , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Centro de Custo Debito"	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Descricao Custo Debito " , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Centro de Custo Credito" , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Descricao Custo Credito"	, 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Tipo de Saldo"   	    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Descricao Tp Saldo"      , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Origem Lancamento"       , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Reprovacao"			    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Aprovacao"			    , 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Rotina"  			    , 1, 1, .F.)

	//Definindo o tamanho da regua
	Count To nTotal
	oProcess:SetRegua1(nTotal)
	(cAlias)->(DbGoTop())

	//Percorrendo os dados da query
	While !((cAlias)->(EoF()))

		//Incrementando a regua
		nAtual++
		oProcess:IncRegua2("Imprimindo registro contabil - "+Alltrim(Str(nAtual))+" de "+Alltrim(Str(nTotal)))

		if (cAlias)->CT2_DC == "1"
			cTipoLanc := "DEBITO"
		elseif (cAlias)->CT2_DC == "2"
			cTipoLanc := "CREDITO"
		elseif (cAlias)->CT2_DC == "3"
			cTipoLanc := "PARTIDA DOBRADA"
		elseif (cAlias)->CT2_DC == "4"
			cTipoLanc := "CONT.HISTORICO"
		elseif (cAlias)->CT2_DC == "5"
			cTipoLanc := "RATEIO"
		elseif (cAlias)->CT2_DC == "6"
			cTipoLanc := "LANÇAMENTO PADRAO"
		endif

		if (cAlias)->CT2_MANUAL == "2"
			cManuAuto := "AUTOMATICO"
		elseif (cAlias)->CT2_MANUAL == "1"
			// if Alltrim((cAlias)->CT2_ROTINA) == "CTBA101" .or. Alltrim((cAlias)->CT2_ROTINA) == "CTBA102" .or. Alltrim((cAlias)->CT2_ROTINA) == "CTBA103"
			// 	cManuAuto := "MANUAL"
			// else
			// 	cManuAuto := "AUTOMATICO"
			// endif
            cManuAuto := "MANUAL"
		endif

		//Adicionando uma nova linha
		oFWMsExcel:AddRow(cWorkSheet, cTitulo, {;
			(cAlias)->CT2_FILIAL,;
			Alltrim(Upper(Posicione("SM0",1,cEmpAnt+(cAlias)->CT2_FILIAL,"M0_FILIAL"))),;
			cManuAuto,;
			Stod((cAlias)->CT2_DATA),;
			(cAlias)->CT2_LOTE,;
			(cAlias)->CT2_SBLOTE,;
			(cAlias)->CT2_DOC,;
			(cAlias)->CT2_LINHA,;
			Upper(cTipoLanc),;
			(cAlias)->CT2_DEBITO,;
			(cAlias)->CONTADEB,;
			(cAlias)->CT2_CREDIT,;
			(cAlias)->CONTACRE,;
			(cAlias)->CT2_VALOR,;
			(cAlias)->CT2_HIST,;
			(cAlias)->CT2_CCD,;
			(cAlias)->CUSTODEB,;
			(cAlias)->CT2_CCC,;
			(cAlias)->CUSTOCRE,;
			(cAlias)->CT2_TPSALD,;
			(cAlias)->X5_DESCRI,;
			(cAlias)->CT2_ORIGEM,;
			StrTran(StrTran(StrTran((cAlias)->ZZI_ZZMOTI,"| ","|")," |","|"),"|",ENTER),;
			StrTran(StrTran(StrTran((cAlias)->ZZI_ZZAPRO,"| ","|")," |","|"),"|",ENTER),;
			(cAlias)->CT2_ROTINA;
			})

		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	oProcess:IncRegua2("Abrindo Planilha no Excel")

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()
	oExcel:WorkBooks:Open(cArquivo)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()

Return

Static Function PergParam()

	Local aParambox     := {}
	Local aTipoSld      := {}
	aAdd( aTipoSld , "1=Todos")
	aAdd( aTipoSld , "2-Bloqueado")
	aAdd( aTipoSld , "3-Reprovado")

	aAdd(aParamBox,{1,"Filial De"				,space(tamsx3("F2_FILIAL")[1])  ,""	,""	,"SM0"	,""	,80,.F.})	//MV_PAR01
	aAdd(aParamBox,{1,"Filial Ate"				,space(tamsx3("F2_FILIAL")[1])  ,""	,""	,"SM0"	,""	,80,.T.})	//MV_PAR02
	aAdd(aParamBox,{1,"Data Cont. De"			,Ctod("")	                    ,""	,""	,""	,""	,80,.T.})		//MV_PAR03
	aAdd(aParamBox,{1,"Data Cont. Ate"			,Ctod("")	                    ,""	,""	,""	,""	,80,.T.})		//MV_PAR04
	aAdd(aParamBox,{1,"Lote De"				    ,space(tamsx3("CT2_LOTE")[1])   ,"",""	,""	,""	,80,.F.})		//MV_PAR05
	aAdd(aParamBox,{1,"Lote Ate"				,space(tamsx3("CT2_LOTE")[1])   ,"",""	,""	,""	,80,.T.})		//MV_PAR06
	aAdd(aParamBox,{2,"Tipo Saldo"  			,"3"                            ,aTipoSld,80,"",.T.})			//MV_PAR07

Return ParamBox(aParamBox,"Parametros",,,,.T.,,,,"RELAPVCT2",.T.,.T.)
