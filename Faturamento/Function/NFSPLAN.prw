#Include 'Protheus.ch'
#Include "RwMake.ch"
#INCLUDE "font.ch"
#Include "rptdef.ch"
#Include "fwprintsetup.ch"


#define	SERVICO	"S"
#define	VENDAS	"V"
/*/{protheus.doc} NFSPLAN
Gera planilhas de notas fiscais de saída/serviço
@author Unknown
@since __/__/____
/*/

User Function NFSPLAN()

Local aParambox	:= {}
Local aOptions	:= {"S=SERVICO","V=VENDAS"}
Local cPerg		:= "NFSPLA"

aAdd(aParamBox,{2,"Opção"				,"1",aOptions,70,.F.,.T.}) //MV_PAR01
aAdd(aParamBox,{1,"Filial de:"			,Space(TamSx3("F1_FILIAL")[1]),"","","SM0","",70,.F.}) //MV_PAR03
aAdd(aParamBox,{1,"Filial até:"			,Space(TamSx3("F1_FILIAL")[1]),"","","SM0","",70,.F.}) //MV_PAR04
aAdd(aParamBox,{1,"Data Emissão de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
aAdd(aParamBox,{1,"Data Emissão até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02

If ParamBox(aParamBox,"Notas Fiscais de Saída/Serviço",,,,,,,,cPerg,.T.,.T.)
	Processa({||GeraPlan() },"Gerando Planilha..." )
endif

Return

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Gera Planilha Excel
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GeraPlan
                                
Local cAlias	:= GetNextAlias()                                
Local nAuxHdl	:= 0
Local cArqNome	:= (CriaTrab(Nil,.F.) + ".xls")
Local cTitulo	:= "NOTAS FISCAIS DE SAÍDA"
Local cTipoEsp	:= ""                                   
Private aCab	:= {}
Private aDados	:= {}                 

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery:= " SELECT SF2.F2_FILIAL AS FILIAL, "+CRLF
cQuery+= "        SF2.F2_EMISSAO AS EMISSAO, "+CRLF
cQuery+= "        SF2.F2_SERIE AS SERIE, "+CRLF
cQuery+= "        SF2.F2_DOC AS NUM_NF,"+CRLF
cQuery+= "        SF2.F2_CLIENTE AS COD_CLIENTE, "+CRLF
cQuery+= "        SF2.F2_LOJA AS LOJA_CLI, "+CRLF
cQuery+= "        RTRIM(SA1.A1_NOME) AS RAZAO_SOCIAL, "+CRLF
cQuery+= "        SA1.A1_CGC AS CNPJ, "+CRLF
cQuery+= "        SA1.A1_NATUREZ AS COD_NATUREZA,"+CRLF
cQuery+= "        RTRIM(SED.ED_DESCRIC) AS DESCR_NATUREZA, "+CRLF
cQuery+= "        SA1.A1_EST AS ESTADO, "+CRLF
cQuery+= "        SF2.F2_VALBRUT AS VAL_BRUTO, "+CRLF
cQuery+= "        SF2.F2_BASEISS AS BASE_ISS, "+CRLF
cQuery+= "        SF2.F2_VALISS AS VLR_ISS, "+CRLF
cQuery+= "        SF2.F2_BASIMP5 AS BASE_COFINS, "+CRLF
cQuery+= "        SF2.F2_VALIMP5 AS VLR_COFINS, "+CRLF
cQuery+= "        SF2.F2_BASIMP6 AS BASE_PIS, "+CRLF
cQuery+= "        SF2.F2_VALIMP6 AS VLR_PIS, "+CRLF
cQuery+= "        SF2.F2_BASEIRR AS BASE_IRRF, "+CRLF
cQuery+= "        SF2.F2_VALIRRF AS VLR_IRRF, "+CRLF
cQuery+= "        SF2.F2_BASPIS AS BASE_PIS_RET, "+CRLF
cQuery+= "        SF2.F2_VALPIS AS VLR_PIS_RET, "+CRLF
cQuery+= "        SF2.F2_BASCOFI AS BASE_COF_RET, "+CRLF
cQuery+= "        SF2.F2_VALCOFI AS VLR_COF_RET, "+CRLF
cQuery+= "        SF2.F2_BASCSLL AS BASE_CSLL_RET, "+CRLF
cQuery+= "        SF2.F2_VALCSLL AS VLR_CSLL_RET "+CRLF
cQuery+= " FROM SF2010 SF2 "+CRLF
cQuery+= "      LEFT JOIN SA1010 SA1 ON SA1.A1_COD = SF2.F2_CLIENTE "+CRLF
cQuery+= "   	    	  AND SA1.A1_LOJA = SF2.F2_LOJA "+CRLF
cQuery+= "     		   	  AND SF2.F2_TIPO IN ('N') "+CRLF
cQuery+= "     	          AND SA1.D_E_L_E_T_ = ' ' "+CRLF
cQuery+= "      LEFT JOIN SED010 SED ON SED.ED_CODIGO = SA1.A1_NATUREZ  AND SED.D_E_L_E_T_ = ' ' "+CRLF
cQuery+= "    			  WHERE SF2.D_E_L_E_T_ = ' ' "+CRLF
cQuery+= " 					  	AND SF2.F2_EMISSAO BETWEEN '20180201' AND '20180228' "+CRLF
cQuery+= "        				AND SF2.F2_ESPECIE IN ('RPS') "+CRLF
cQuery+= " ORDER BY SF2.F2_FILIAL, "+CRLF
cQuery+= "          SF2.F2_EMISSAO, "+CRLF
cQuery+= "          SF2.F2_SERIE, "+CRLF
cQuery+= "          SF2.F2_DOC "+CRLF
Return

