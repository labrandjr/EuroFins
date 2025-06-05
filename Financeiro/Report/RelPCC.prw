#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
/*/{protheus.doc} RelPCC
Relacao de baixas
@author Unknown
@since __/__/____
/*/
user function RelPCC()
	Local oReport
	Private cPerg := "RELPCC"
	Private cTitulo := "Relação de baixas"

	AjustaSX1()
	Pergunte(cPerg,.F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

Static Function ReportDef()
Local oReport
Local oBaixas

oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},cTitulo,.T.,/*uTotalText*/,.f.,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oBaixas := TRSection():New(oReport,"","TMP")

TRCell():New(oBaixas,"E1_PREFIXO"	,"TMP" ,"Prf",,TamSx3("E5_PREFIXO")[1], .F.)
TRCell():New(oBaixas,"E1_NUM" 		,"TMP" ,"Numero",,TamSx3("E5_NUMERO")[1],.F.)
TRCell():New(oBaixas,"E1_PARCELA"	,"TMP" ,"Parcela",,TamSx3("E5_PARCELA")[1], .F.)	//"Prc"
TRCell():New(oBaixas,"E1_TIPO"		,"TMP" ,"TP",,TamSx3("E5_TIPODOC")[1], .F.)	//"TP"
TRCell():New(oBaixas,"E5_CLIENTE"	,"TMP" ,"Cliente",,TamSx3("E5_CLIFOR")[1], .F.)	//"Cli/For"
TRCell():New(oBaixas,"E1_LOJA"		,"TMP" ,"Loja",,TamSx3("E5_LOJA")[1], .F.)	//"Cli/For"
TRCell():New(oBaixas,"E1_NOMCLI"	,"TMP" ,"Nome",,15, .F.)	//"Nome Cli/For"
TRCell():New(oBaixas,"E1_NATUREZ"	,"TMP" ,"Natureza",,11, .F.)	//"Natureza"
TRCell():New(oBaixas,"E1_EMISSAO"	,"TMP" ,"Emissão","@D")
TRCell():New(oBaixas,"E1_VENCREA"	,"TMP" ,"Vencto",,TamSx3("E5_VENCTO")[1], .F.)	//"Vencto"
TRCell():New(oBaixas,"E5_HISTOR"	,"TMP" ,"Historico",, TamSx3("E5_HISTOR")[1]/2+1, .F.,,,.T.)	//"Historico"
TRCell():New(oBaixas,"E1_BAIXA"		,"TMP" ,"Dt Baixa",,TamSx3("E5_DATA")[1] + 1, .F.)	//"Dt Baixa"
TRCell():New(oBaixas,"E1_VALOR"		,"TMP" ,"Valor Original",, TamSX3("E5_VALOR")[1]	,/*[lPixel]*/,,"RIGHT",,"RIGHT")	//"Valor Original"
TRCell():New(oBaixas,"E5_VLJUROS"	,"TMP" ,"Jur/Multa",, TamSX3("E5_VLJUROS")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")//"Jur/Multa"
TRCell():New(oBaixas,"E5_VLCORRE"	,"TMP" ,"Correcao",, TamSX3("E5_VLCORRE")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")//"Correcao"
TRCell():New(oBaixas,"E5_VLDESCO"	,"TMP" ,"Descontos",, TamSX3("E5_VLDESCO")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")//"Descontos"
TRCell():New(oBaixas,"IMPOSTOS"		,"TMP" ,"Impostos",, TamSX3("E5_VALOR")[1]	,/*[lPixel]*/,,"RIGHT",,"RIGHT")	//"Impostos"
TRCell():New(oBaixas,"E1_IR"		,"TMP" ,"IR",, TamSX3("E5_VALOR")[1]	,/*[lPixel]*/,,"RIGHT",,"RIGHT")	//"Impostos"
TRCell():New(oBaixas,"E1_PIS"		,"TMP" ,"PIS",, TamSX3("E5_VALOR")[1]	,/*[lPixel]*/,,"RIGHT",,"RIGHT")	//"Impostos"
TRCell():New(oBaixas,"E1_COFINS"	,"TMP" ,"COFINS",, TamSX3("E5_VALOR")[1]	,/*[lPixel]*/,,"RIGHT",,"RIGHT")	//"Impostos"
TRCell():New(oBaixas,"E1_CSLL"		,"TMP" ,"CSLL",, TamSX3("E5_VALOR")[1]	,/*[lPixel]*/,,"RIGHT",,"RIGHT")	//"Impostos"
TRCell():New(oBaixas,"E1_ISS"		,"TMP" ,"ISS",, TamSX3("E5_VLDESCO")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"E1_INSS"		,"TMP" ,"INSS",, TamSX3("E5_VLDESCO")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")
TRCell():New(oBaixas,"E5_VALOR"		,"TMP" ,"Total Baixado",, TamSX3("E5_VALOR")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")//"Total Baixado"
TRCell():New(oBaixas,"E5_BANCO"		,"TMP" ,"Bco",, TamSX3("E5_BANCO")[1]+1,.f.)	//"Bco"
TRCell():New(oBaixas,"E5_DTDIGIT"	,"TMP" ,"Dt Dig",,10, .f.)	//"Dt Dig."
TRCell():New(oBaixas,"E5_MOTBX"		,"TMP" ,"Mot",,3, .f.)	//"Mot"
TRCell():New(oBaixas,"E5_FILORIG"	,"TMP" ,"Orig",,FWSizeFilial()+2, .f.)	//"Orig"
TRCell():New(oBaixas,"A1_CGC"		,"TMP" ,"CNPJ",, TamSX3("A1_CGC")[1],/*[lPixel]*/,,"RIGHT",,"RIGHT")

return oReport



Static Function PrintReport(oReport)
Local oBaixas := oReport:Section(1)
Local cData1  := dtos(MV_PAR01)
Local cData2  := dtos(MV_PAR02)

oBaixas:BeginQuery()

	BeginSql alias "TMP"

		SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO,
		SE1.E1_NATUREZ, SE5.E5_BANCO, SE1.E1_SITUACA, SE1.E1_CLIENTE, SE1.E1_LOJA,
		SE1.E1_NOMCLI, SA1.A1_CGC, SE1.E1_EMISSAO, SE5.E5_DTDIGIT, SE1.E1_VENCTO,
		SE1.E1_VENCREA, SE1.E1_BAIXA, SE1.E1_VALOR, SE1.E1_IRRF+SE1.E1_PIS+SE1.E1_COFINS+SE1.E1_CSLL+SE1.E1_ISS+SE1.E1_INSS AS IMPOSTOS,
		SE1.E1_IRRF, SE1.E1_PIS, SE1.E1_COFINS, SE1.E1_CSLL, SE1.E1_ISS, SE1.E1_INSS, SE1.E1_DESCONT,
		SE1.E1_JUROS, SE5.E5_VALOR, SE5.E5_FILORIG, SE5.E5_HISTOR, SE5.E5_MOTBX, E5_VLCORRE
		FROM %table:SE1% SE1
		LEFT JOIN %table:SE5% SE5 ON
		SE5.E5_FILIAL = SE1.E1_FILIAL
		AND SE5.E5_PREFIXO = SE1.E1_PREFIXO
		AND SE5.E5_NUMERO = SE1.E1_NUM
		AND SE5.E5_PARCELA = SE1.E1_PARCELA
		AND SE5.E5_CLIFOR = SE1.E1_CLIENTE
		AND SE5.E5_LOJA = SE1.E1_LOJA
		AND SE5.E5_NATUREZ = SE1.E1_NATUREZ
		AND SE5.E5_MOTBX = 'NOR'
		AND SE5.%notDel%
		LEFT JOIN %table:SA1% SA1 ON
		SA1.A1_COD = SE1.E1_CLIENTE AND
		SA1.A1_LOJA = SE1.E1_LOJA AND
		SA1.%notDel%
		WHERE SE1.%notDel%
		AND E1_FILIAL = %xfilial:SE1%
        AND E1_BAIXA BETWEEN %exp:cData1% AND %exp:cData2%
        AND E1_TIPO NOT IN ('IR-',
                      		'PIS',
                      		'COF',
                      		'CSL',
                      		'IS-',
                      		'INS')
        ORDER BY E1_FILIAL, E1_BAIXA

	EndSql

oBaixas:EndQuery()

oBaixas:Print()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1    ³Autor ³                      ³Data³ 28/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta perguntas do SX1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()
xPutSx1(cPerg,"01","Baixas de "		,"","","mv_ch1" ,"D",08						 	,0,0,"G","",""   ,"","","mv_par01",,,,,,,,,,,,,,,,,{""},{""},{""})
xPutSx1(cPerg,"02","Baixas ate "		,"","","mv_ch2" ,"D",08						 	,0,0,"G","",""   ,"","","mv_par02",,,,,,,,,,,,,,,,,{""},{""},{""})
Return NIL

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
     cF3, cGrpSxg,cPyme,;
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
     cDef02,cDefSpa2,cDefEng2,;
     cDef03,cDefSpa3,cDefEng3,;
     cDef04,cDefSpa4,cDefEng4,;
     cDef05,cDefSpa5,cDefEng5,;
     aHelpPor,aHelpEng,aHelpSpa,cHelp)

LOCAL aArea := GetArea()
Local cKey
Local lPort := .f.
Local lSpa := .f.
Local lIngl := .f.

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

cPyme    := Iif( cPyme           == Nil, " ", cPyme          )
cF3      := Iif( cF3           == NIl, " ", cF3          )
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     )
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      )
cHelp      := Iif( cHelp          == Nil, "" , cHelp          )

dbSelectArea( "SX1" )
dbSetOrder( 1 )

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
// RFC - 15/03/2007
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

If !( DbSeek( cGrupo + cOrdem ))

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

     Reclock( "SX1" , .T. )

     Replace X1_GRUPO   With cGrupo
     Replace X1_ORDEM   With cOrdem
     Replace X1_PERGUNT With cPergunt
     Replace X1_PERSPA With cPerSpa
     Replace X1_PERENG With cPerEng
     Replace X1_VARIAVL With cVar
     Replace X1_TIPO    With cTipo
     Replace X1_TAMANHO With nTamanho
     Replace X1_DECIMAL With nDecimal
     Replace X1_PRESEL With nPresel
     Replace X1_GSC     With cGSC
     Replace X1_VALID   With cValid

     Replace X1_VAR01   With cVar01

     Replace X1_F3      With cF3
     Replace X1_GRPSXG With cGrpSxg

     If Fieldpos("X1_PYME") > 0
          If cPyme != Nil
               Replace X1_PYME With cPyme
          Endif
     Endif

     Replace X1_CNT01   With cCnt01
     If cGSC == "C"               // Mult Escolha
          Replace X1_DEF01   With cDef01
          Replace X1_DEFSPA1 With cDefSpa1
          Replace X1_DEFENG1 With cDefEng1

          Replace X1_DEF02   With cDef02
          Replace X1_DEFSPA2 With cDefSpa2
          Replace X1_DEFENG2 With cDefEng2

          Replace X1_DEF03   With cDef03
          Replace X1_DEFSPA3 With cDefSpa3
          Replace X1_DEFENG3 With cDefEng3

          Replace X1_DEF04   With cDef04
          Replace X1_DEFSPA4 With cDefSpa4
          Replace X1_DEFENG4 With cDefEng4

          Replace X1_DEF05   With cDef05
          Replace X1_DEFSPA5 With cDefSpa5
          Replace X1_DEFENG5 With cDefEng5
     Endif

     Replace X1_HELP With cHelp

     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

     MsUnlock()
Else

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
   lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA)
   lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG)

   If lPort .Or. lSpa .Or. lIngl
          RecLock("SX1",.F.)
          If lPort
        SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
          EndIf
          If lSpa
               SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
          EndIf
          If lIngl
               SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
          EndIf
          SX1->(MsUnLock())
     EndIf
Endif

RestArea( aArea )

Return





