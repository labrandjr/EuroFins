#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} RELDESC
Emissão do relatório de desconto
@author Unknown
@since 29/12/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function RELDESC()
Local oReport
Local lLandscape := .T.
Private cPerg := "RELDEC"
Private cTitulo := "RELATÓRIO DE DESCONTO"

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

oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},cTitulo,.t./*lLandscape*/,"Total de Descontos",.f.,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)

oSection1 := TRSection():New(oReport,"Pedidos","TMP")

TRCell():New(oSection1,"C7_COMPRA"	,"SC7")
TRCell():New(oSection1,"Y1_NOME"	,"SY1")
TRCell():New(oSection1,"C7_NUM"		,"SC7")
TRCell():New(oSection1,"C7_PRODUTO"	,"SC7")
TRCell():New(oSection1,"C7_DESCRI"	,"SC7")
TRCell():New(oSection1,"B1_TIPO"	,"SB1")
TRCell():New(oSection1,"C7_QUANT"	,"SC7")
TRCell():New(oSection1,"C7_ZZPRINI"	,"SC7", "Prc. Ini.")
TRCell():New(oSection1,"C7_PRECO"	,"SC7", "Prc. Neg.")
TRCell():New(oSection1,"C7_ZZPRFIM"	,"SC7")
TRCell():New(oSection1,"VTOTINI"	,"TMP", "Vlr. Tot. Ini.","@E 999,999,999.99")
TRCell():New(oSection1,"VTOTNEG"	,"TMP", "Vlr. Tot. Neg.","@E 999,999,999.99")
TRCell():New(oSection1,"SAVTOT"		,"TMP", "Saving Tot.","@E 999,999,999.99")


oBreak := TRBreak():New(oSection1,oSection1:Cell("C7_COMPRA"),"Total descontos",.F.)

oTotal := TRFunction():New(oSection1:Cell("SAVTOT"),,"SUM",oBreak,,,, .f., .t. )


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
Local cDtIni 	:= Dtos(MV_PAR01)
Local cDtfIM 	:= Dtos(MV_PAR02)
Local cCompDe 	:= MV_PAR03
Local cCompAte 	:= MV_PAR04
Local cPedDe 	:= MV_PAR05
Local cPedAte 	:= MV_PAR06
Local cProdDe 	:= MV_PAR07
Local cProdAte 	:= MV_PAR08
Local cTipoDe 	:= MV_PAR09
Local cTipoAte 	:= MV_PAR10

oSection1:BeginQuery()

	BeginSql alias "TMP"

		SELECT *, C7_QUANT * C7_ZZPRINI as VTOTINI, C7_QUANT * C7_PRECO as VTOTNEG, C7_QUANT *  C7_ZZPRFIM as SAVTOT
		FROM %table:SC7% SC7, %table:SB1% SB1, %table:SY1% SY1
		WHERE SC7.%notDel% AND
		SB1.%notDel% AND
		SY1.%notDel% AND
		SC7.C7_FILIAL = %xfilial:SC7% AND
		SB1.B1_FILIAL = %xfilial:SB1% AND
		SY1.Y1_FILIAL = %xfilial:SY1% AND
		SC7.C7_PRODUTO = SB1.B1_COD AND
		SC7.C7_COMPRA = SY1.Y1_COD AND
		SC7.C7_EMISSAO BETWEEN %exp:cDtIni% AND %exp:cDtFim% AND
		SC7.C7_COMPRA BETWEEN %exp:cCompDe% AND %exp:cCompAte% AND
		SC7.C7_NUM BETWEEN %exp:cPedDe% AND %exp:cPedAte% AND
		SC7.C7_PRODUTO BETWEEN %exp:cProdDe% AND %exp:cProdAte% AND
		SB1.B1_TIPO BETWEEN %exp:cTipoDe% AND %exp:cTipoAte%
		ORDER BY C7_COMPRA, C7_NUM

	EndSql

oSection1:EndQuery()


oSection1:Print()

Return




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
Aadd(aRegs,{cPerg,"01","Data de"		,"","","mv_ch1" ,"D",08,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
Aadd(aRegs,{cPerg,"02","Data ate"		,"","","mv_ch2" ,"D",08,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
Aadd(aRegs,{cPerg,"03","Comprador de"	,"","","mv_ch3" ,"C",03,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SY1",""})
Aadd(aRegs,{cPerg,"04","Comprador ate"	,"","","mv_ch4" ,"C",03,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SY1",""})
Aadd(aRegs,{cPerg,"05","Ped. Compra de"	,"","","mv_ch5" ,"C",06,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SC7",""})
Aadd(aRegs,{cPerg,"06","Ped. Compra ate","","","mv_ch6" ,"C",06,0,1,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SC7",""})
Aadd(aRegs,{cPerg,"07","Produto de"		,"","","mv_ch7" ,"C",15,0,1,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
Aadd(aRegs,{cPerg,"08","Produto ate"	,"","","mv_ch8" ,"C",15,0,1,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
Aadd(aRegs,{cPerg,"09","Tipo de"		,"","","mv_ch9" ,"C",02,0,1,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","02" ,""})
Aadd(aRegs,{cPerg,"10","Tipo ate"		,"","","mv_ch10","C",02,0,1,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","02" ,""})

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

Return