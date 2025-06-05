#include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FPCCSE1  ºAutor  ³ Marcos Candido     º Data ³  26/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na geracao de NCC quando o valor dos      º±±
±±º          ³ impostos supera o valor da nota.                           º±±
±±º          ³ Estou ajustando o valor e vencimento da NCC para que fique º±±
±±º          ³ igual ao do titulo NF.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eurofins                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*/{Protheus.doc} FPCCSE1
Na geracao de NCC quando o valor dos impostos supera o valor da nota.
Estou ajustando o valor e vencimento da NCC para que fique igual ao do titulo NF.
@author Marcos Candido
@since 03/01/2018
/*/
User Function FPCCSE1

Local aAreaAtual := GetArea()
Local cPref      := SE1->E1_PREFIXO
Local cNumTit    := SE1->E1_NUM
Local cParc      := SE1->E1_PARCELA
Local cTip       := "NF "
Local nVlr       := 0
Local dVcto      := dVctoR := CtoD(Space(8))

SE1->(dbSetOrder(1))
SE1->(dbSeek(xFilial("SE1")+cPref+cNumTit+cParc+cTip))

nVlr   := SE1->E1_VALOR
dVcto  := SE1->E1_VENCTO
dVctoR := SE1->E1_VENCREA

RestArea(aAreaAtual)

RecLock("SE1",.F.)
  SE1->E1_VALOR   := nVlr
  SE1->E1_SALDO   := nVlr
  SE1->E1_VLCRUZ  := nVlr
  SE1->E1_VENCTO  := dVcto
  SE1->E1_VENCREA := dVctoR

Return