#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FATAMOS
Faturamento de amostra/analise
@author Marcos Candido
@since 12/02/2019
/*/
user function FATAMOS()
Local oReport
Local lLandscape := .F.
Private cPerg := "FATAMOS"
Private cTitulo := "FATURAMENTO DE ANALISE/AMOSTRAS"

AjustaSX1(cPerg)
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2

//New(cReport,cTitle,uParam,bAction,cDescription,lLandscape,uTotalText,lTotalInLine,cPageTText,lPageTInLine,lTPageBreak,nColSpace)

oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},cTitulo,/*lLandscape*/,"Total de Descontos",.f.,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)

oSection1 := TRSection():New(oReport,"Faturamento","TMP")

TRCell():New(oSection1,"D2_DOC"		,"TMP","Nota Faturada")
TRCell():New(oSection1,"D2_EMISSAO"	,"TMP","Data Faturada")
TRCell():New(oSection1,"D2_COD"		,"TMP","Cod. Analise")
TRCell():New(oSection1,"C6_DESCRI"	,"TMP","Des. Analise")
TRCell():New(oSection1,"C6_ZZNROCE"	,"TMP","Cod. Amostra")
TRCell():New(oSection1,"D2_TOTAL"	,"TMP","Total Analiase")


Return oReport



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrintReport  ³Autor ³                      ³Data³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o Relatorio                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrintReport(oReport)
Local oSection1 := oReport:Section(1)
Local dDataDe 	:= dTos(MV_PAR01) 		//Faturada de 
Local dDataAte 	:= dTos(MV_PAR02) 		//Faturada Ate
//Local cSCDe 	:= MV_PAR03 		//Solicitação de Compra de
//Local cSCAte 	:= MV_PAR04 		//Solicitação de Compra ate
//Local cPedDe 	:= MV_PAR05 		//Pedido de compra de
//Local cPedAte 	:= MV_PAR06 		//Pedido de compra ate
//Local cDtSCDe 	:= dTos(MV_PAR07) 	//emissao da SC de
//Local cDtSCAte 	:= dTos(MV_PAR08) 	//emissao da SC ate
//Local cDtPCDe 	:= dTos(MV_PAR09) 	//emissao do PC de
//Local cDtPcAte 	:= dTos(MV_PAR10) 	//emissao do PC ate
//Local cDtRecDe 	:= dTos(MV_PAR09) 	//recebimento de
//Local cDtrecAte	:= dTos(MV_PAR10) 	//recebimento ate

oSection1:BeginQuery()

	BeginSql alias "TMP"
	
	SELECT D2_DOC, D2_EMISSAO, D2_COD, C6_DESCRI, C6_ZZNROCE, D2_TOTAL 
		FROM SD2010 SD2
		INNER JOIN SC6010 AS SC6 ON 
			SC6.C6_FILIAL = SD2.D2_FILIAL AND 
			SC6.C6_PRODUTO = SD2.D2_COD AND 
			SC6.%notDel% AND 
			SC6.C6_FILIAL = %xfilial:SC6% AND 
			SC6.C6_NUM = SD2.D2_PEDIDO AND 
			SC6.C6_ITEM = SD2.D2_ITEMPV AND 
			SC6.C6_SERIE = SD2.D2_SERIE
		WHERE SD2.%notDel% AND 
			SD2.D2_FILIAL = %xfilial:SD2% AND
			SD2.D2_EMISSAO >= %exp:dDataDe% AND SD2.D2_EMISSAO <= %exp:dDataAte% AND
			SC6.C6_ZZNROCE <> ' ' AND
			SD2.D2_TIPO = 'N'
		ORDER BY D2_EMISSAO, D2_DOC, D2_COD
		
	EndSql

oSection1:EndQuery()


oSection1:Print()

return




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aHelpPor := {}
Local aAreaAtual := GetArea()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Organiza o Grupo de Perguntas e Help ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aRegs,{cPerg,"01","Emissao de"			,"","","mv_ch1"  ,"D",08,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Emissao ate"		,"","","mv_ch2"  ,"D",08,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aAreaAtual)

