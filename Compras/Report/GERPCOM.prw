#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} GERPCOM
Relatorio de Gerenciamento de Compras
@author Unknown
@since 29/12/2017
@type function
/*/
user function GERPCOM()
Local oReport
Local lLandscape := .F.
Private cPerg := "GERPCOM"
Private cTitulo := "GERENCIAMENTO PROCESSO DE COMPRAS"

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

oSection1 := TRSection():New(oReport,"Pedidos","TMP")

TRCell():New(oSection1,"C1_FILIAL"	,"TMP","Filial")
TRCell():New(oSection1,"C1_CODCOMP"	,"TMP","Comprador")
TRCell():New(oSection1,"Y1_NOME"	,"TMP","Nome")
TRCell():New(oSection1,"C1_NUM"		,"TMP","Num. SC")
TRCell():New(oSection1,"C1_ITEM"	,"TMP","Item SC")
TRCell():New(oSection1,"C1_SOLICIT"	,"TMP","Solicit. SC")
TRCell():New(oSection1,"C1_PRODUTO"	,"TMP","Cod Produto")
TRCell():New(oSection1,"C1_DESCRI"	,"TMP","Descricao")
TRCell():New(oSection1,"C1_EMISSAO"	,"TMP","Emissao SC")
TRCell():New(oSection1,"SCDTLIB"	,"TMP","Aprovacao SC",,,,{|| STOD(SCDTLIB)})
TRCell():New(oSection1,"C1RESIDUO"  ,"TMP","Resíduo. SC")
TRCell():New(oSection1,"C1_DATPRF"	,"TMP","Dt. Necess. SC")
TRCell():New(oSection1,"C1_PEDIDO"	,"TMP","Num. PC")
TRCell():New(oSection1,"C1_ITEMPED"	,"TMP","Item PC")
TRCell():New(oSection1,"C7_EMISSAO"	,"TMP","Emissao PC")
TRCell():New(oSection1,"PCDTLIB"	,"TMP","Aprovacao PC",,,,{|| STOD(PCDTLIB)})
TRCell():New(oSection1,"C7RESIDUO"  ,"TMP","Resíduo. PC")
TRCell():New(oSection1,"C7_DATPRF"	,"TMP","Dt. Entreg. PC")
TRCell():New(oSection1,"D1_DOC"		,"TMP","Num. NF")
TRCell():New(oSection1,"D1_ITEM"	,"TMP","Item NF")
TRCell():New(oSection1,"D1_DTDIGIT"	,"TMP","Receb. NF")

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
Local cComDe 	:= MV_PAR01 		//comprador de
Local cComAte 	:= MV_PAR02 		//comprador ate
Local cSCDe 	:= MV_PAR03 		//Solicitação de Compra de
Local cSCAte 	:= MV_PAR04 		//Solicitação de Compra ate
Local cPedDe 	:= MV_PAR05 		//Pedido de compra de
Local cPedAte 	:= MV_PAR06 		//Pedido de compra ate
Local cDtSCDe 	:= dTos(MV_PAR07) 	//emissao da SC de
Local cDtSCAte 	:= dTos(MV_PAR08) 	//emissao da SC ate
Local cDtPCDe 	:= dTos(MV_PAR09) 	//emissao do PC de
Local cDtPcAte 	:= dTos(MV_PAR10) 	//emissao do PC ate
Local cDtRecDe 	:= dTos(MV_PAR09) 	//recebimento de
Local cDtrecAte	:= dTos(MV_PAR10) 	//recebimento ate

oSection1:BeginQuery()

	BeginSql alias "TMP"

	SELECT DISTINCT C1_FILIAL, C1_CODCOMP, Y1_NOME, C1_NUM, 
		C7_NUM, C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_EMISSAO, C1_PEDIDO, C1_ITEMPED,
		C7_EMISSAO, C1_DATPRF, C7_DATPRF,C1_SOLICIT,
		CASE WHEN C1_APROV='L' THEN SCRSC.CR_DATALIB ELSE '' END SCDTLIB,
		CASE WHEN C1_RESIDUO='S' THEN 'SIM' ELSE '' END C1RESIDUO, 
		SCRPC.CR_DATALIB PCDTLIB,D1_DOC, D1_ITEM, D1_DTDIGIT, C7_NUM,
		CASE WHEN C7_RESIDUO='S' THEN 'SIM' ELSE '' END C7RESIDUO 
		FROM SC1010 SC1
		LEFT JOIN SY1010 SY1 ON
			SY1.%notDel%  AND
			SY1.Y1_FILIAL = %xfilial:SY1% AND
			C1_CODCOMP = SY1.Y1_COD
		LEFT JOIN SC7010 SC7 ON
			SC7.%notDel%  AND
			SC7.C7_FILIAL = %xfilial:SC7% AND
			SC1.C1_PEDIDO = SC7.C7_NUM AND
			SC1.C1_ITEM = SC7.C7_ITEMSC AND
			SC1.C1_PRODUTO = SC7.C7_PRODUTO
			//SC7.C7_RESIDUO <> 'S' //Linha comentada para trazer itens com resíduo a pedido da Silmara
		LEFT JOIN SD1010 SD1 ON
			SD1.%notDel%  AND
			SD1.D1_FILIAL = %xfilial:SD1% AND
			SC7.C7_FORNECE = SD1.D1_FORNECE AND 
			SC7.C7_LOJA = SD1.D1_LOJA AND 
			SC7.C7_NUM = SD1.D1_PEDIDO AND 
			SC7.C7_ITEM = SD1.D1_ITEMPC AND
			SC7.C7_PRODUTO = SD1.D1_COD
		LEFT JOIN SCR010 SCRSC ON
			SCRSC.%notDel% AND SCRSC.CR_TIPO = 'SC' AND
			SCRSC.CR_FILIAL = %xfilial:SCR% AND
			SC1.C1_NUM = SCRSC.CR_NUM
		LEFT JOIN SCR010 SCRPC ON
			SCRPC.%notDel% AND SCRPC.CR_TIPO <> 'SC' AND
			SCRPC.CR_FILIAL = %xfilial:SCR% AND
			SC7.C7_NUM = SCRPC.CR_NUM
		WHERE
		SC1.%notDel% AND SC1.C1_FILIAL = %xfilial:SC1% AND
 			//SC1.C1_RESIDUO <> 'S' AND //Linha comentada para trazer itens com resíduo a pedido da Silmara
			SC1.C1_CODCOMP BETWEEN %exp:cComDe% AND %exp:cComAte% AND
			SC1.C1_NUM BETWEEN %exp:cSCDe% AND %exp:cSCAte% AND
			((SC1.C1_PEDIDO BETWEEN %exp:cPedDe% AND %exp:cPedAte%) OR (SC1.C1_PEDIDO IS NULL)) AND
			((SC1.C1_EMISSAO BETWEEN %exp:cDtSCDe% AND %exp:cDtSCAte%) OR (SC1.C1_EMISSAO IS NULL)) AND
			((SC7.C7_EMISSAO BETWEEN %exp:cDtPCDe% AND %exp:cDtPCAte%) OR (SC7.C7_EMISSAO IS NULL)) AND
			((SD1.D1_DTDIGIT BETWEEN %exp:cDtRecDe% AND %exp:cDtRecAte%) OR (SD1.D1_DTDIGIT IS NULL))
			ORDER BY C1_CODCOMP, C1_NUM, C1_PEDIDO
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
Aadd(aRegs,{cPerg,"01","Comprador de"		,"","","mv_ch1"  ,"C",03,0,1,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SY1",""})
Aadd(aRegs,{cPerg,"02","Comprador ate"		,"","","mv_ch2"  ,"C",03,0,1,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SY1",""})
Aadd(aRegs,{cPerg,"03","Sol. Compra de"		,"","","mv_ch3"  ,"C",06,0,1,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SC1",""})
Aadd(aRegs,{cPerg,"04","Sol. Compra ate"	,"","","mv_ch4"  ,"C",06,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SC1",""})
Aadd(aRegs,{cPerg,"05","Ped. Compra de"		,"","","mv_ch5"  ,"C",06,0,1,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SC7",""})
Aadd(aRegs,{cPerg,"06","Ped. Compra ate"	,"","","mv_ch6"  ,"C",06,0,1,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SC7",""})
Aadd(aRegs,{cPerg,"07","Emissao SC de"		,"","","mv_ch7"  ,"D",08,0,1,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
Aadd(aRegs,{cPerg,"08","Emissao SC ate"		,"","","mv_ch8"  ,"D",08,0,1,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
Aadd(aRegs,{cPerg,"09","Emissao PC de"		,"","","mv_ch9"  ,"D",08,0,1,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
Aadd(aRegs,{cPerg,"10","Emissao PC ate"		,"","","mv_ch10" ,"D",08,0,1,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
Aadd(aRegs,{cPerg,"11","Recebimento de"		,"","","mv_ch11" ,"D",08,0,1,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
Aadd(aRegs,{cPerg,"12","Recebimento ate"	,"","","mv_ch12" ,"D",08,0,1,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})


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