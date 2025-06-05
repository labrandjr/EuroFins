#include "rwmake.ch"


/*/{Protheus.doc} NossNumI
Calculo do campo "Nosso Numero" para o Banco Itau
@author Marcos Candido
@since 04/01/2018
/*/
User Function NossNumI

Local cNumAtual  := ""
Local cAgenc     := ""
Local cCont      := ""
Local cTudo      := ""
Local cDig       := ""
Local aAreaAtual := GetArea()
Local cNossNum := SE1->E1_NUMBCO

If Empty(cNossNum)

	cAgenc    := Alltrim(SEE->EE_AGENCIA)
	cCont     := Substr(SEE->EE_CONTA,1,5)
	cNumAtual := Alltrim(SEE->EE_FAXATU)
	cTudo     := cAgenc+cCont+cNumAtual

	cDig     := Modulo10(cTudo)
	cNossNum := Alltrim(cNumAtual+Str(cDig,1,0))

	dbSelectArea("SEE")
	RecLock("SEE",.F.)
	  Replace	EE_FAXATU	With	Soma1(cNumAtual,8)
	MsUnlock()

	dbSelectArea("SE1")
	RecLock("SE1",.F.)
	  Replace	E1_NUMBCO	With	cNossNum
	MsUnlock()

Endif

RestArea(aAreaAtual)

cNossNum := Right(Alltrim(cNossNum),9)
cNossNum := Substr(cNossNum,1,8)

Return cNossNum

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo10 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo10(cData)

LOCAL L,D,P := 0
LOCAL B := .T.

L := Len(cData)
D := 0

While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		Endif
	Endif
	D := D + P
	L := L - 1
	B := !B
Enddo

D := 10 - (Mod(D,10))

If D = 10
	D := 0
Endif

Return(D)
