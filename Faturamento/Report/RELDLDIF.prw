#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} RELDLDIF
Relatório de Saldo a diferir x Saldo do Produto
@author Unknown
@since 23/02/2019
/*/
user function RELDLDIF()
Local oReport
Local lLandscape := .F.
Private cPerg := "RELDLDIF"
Private cTitulo := "SALDO A DIFERIR X SALDO PRODUTO"

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

oSection1 := TRSection():New(oReport,"SALDO X DIFERIMENTO","TMP")

TRCell():New(oSection1,"CODIGO"			,"TMP","CODIGO")
TRCell():New(oSection1,"DESCRICAO"		,"TMP","DESCRICAO")
TRCell():New(oSection1,"UNIDADE"		,"TMP","UN. DE MEDIDA")
TRCell():New(oSection1,"SATUAL"			,"TMP","SALDO ATUAL")
TRCell():New(oSection1,"SATUALV"		,"TMP","SALDO ATUAL EM VALOR")
TRCell():New(oSection1,"SDIFER"			,"TMP","SALDO A DIFEIR")
TRCell():New(oSection1,"SDIFERV"		,"TMP","SALDO A DIFEIR EM VALOR")
TRCell():New(oSection1,"DIFR"			,"TMP","DIFERENÇA")
TRCell():New(oSection1,"DIFV"			,"TMP","DIFERENÇA EM VALOR")


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
//Local dDataDe 	:= dTos(MV_PAR01) 		//Faturada de 
//Local dDataAte 	:= dTos(MV_PAR02) 		//Faturada Ate
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
	
	select 
		SB2.B2_COD  'CODIGO',
		SB1.B1_DESC 'DESCRICAO',
		SB1.B1_UM	'UNIDADE',
		Round(SB2.B2_QATU,6) 'SATUAL',
		Round(SB2.B2_QATU*SB2.B2_CM1,6) 'SATUALV',
		IsNull(Round(Sum(SZE.ZE_QUANT),6),0) 'SDIFER',
		IsNull(Round(Sum(SZE.ZE_QUANT*SB2.B2_CM1),6),0) 'SDIFERV',
		IsNull(Round(Round(SB2.B2_QATU,6)-Round(IsNull(Sum(SZE.ZE_QUANT),0),6),6),0) 'DIFR',
		IsNull(Round((SB2.B2_QATU-IsNull(Sum(SZE.ZE_QUANT),0))*SB2.B2_CM1,6),0) 'DIFV'
	from SB2010 SB2
		inner join SB1010 as SB1 on SB1.%notDel% and SB1.B1_FILIAL = SB2.B2_FILIAL and SB2.B2_COD = SB1.B1_COD and SB1.B1_FILIAL = %xFilial:SB1%
		left join  SZE010 as SZE on SZE.%notDel% and SZE.ZE_FILIAL = SB2.B2_FILIAL and SZE.ZE_COD = SB2.B2_COD and SZE.ZE_FILIAL = %xFilial:SZE% and SZE.ZE_DATA = ' '
	where
		SB2.%notDel% and 
		SB2.B2_FILIAL = %xFilial:SB2% and
		SB2.B2_COD like '09A20%'
	group by SB2.B2_COD, SB1.B1_DESC, SB1.B1_UM, SB2.B2_QATU, SB2.B2_CM1
	order by SB2.B2_COD
		
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

//dbSelectArea("SX1")
//dbSetOrder(1)
//cPerg := PADR(cPerg,10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Organiza o Grupo de Perguntas e Help ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Aadd(aRegs,{cPerg,"01","Emissao de"			,"","","mv_ch1"  ,"D",08,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//Aadd(aRegs,{cPerg,"02","Emissao ate"		,"","","mv_ch2"  ,"D",08,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

