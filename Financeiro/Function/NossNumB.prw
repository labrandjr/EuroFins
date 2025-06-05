#include "rwmake.ch"


/*/{Protheus.doc} NossNumB
Calculo do campo "Nosso Numero" para o Banco Bradesco
@author Marcos Candido
@since 04/01/2018
/*/

User Function NossNumB

Local cNumAtual := Alltrim(SEE->EE_FAXATU)
Local cCart     := "09"
Local cTudo     := cCart+cNumAtual
Local nDifer    := 0 , cDig := ""
Local n01,n02,n03,n04,n05,n06,n07,n08,n09,n10,n11,n12,n13
Local aAreaAtual := GetArea()
Local cNossNum := SE1->E1_NUMBCO

If Empty(cNossNum)

	n01 := Val(Substr(cTudo,1,1))
	n02 := Val(Substr(cTudo,2,1))
	n03 := Val(Substr(cTudo,3,1))
	n04 := Val(Substr(cTudo,4,1))
	n05 := Val(Substr(cTudo,5,1))
	n06 := Val(Substr(cTudo,6,1))
	n07 := Val(Substr(cTudo,7,1))
	n08 := Val(Substr(cTudo,8,1))
	n09 := Val(Substr(cTudo,9,1))
	n10 := Val(Substr(cTudo,10,1))
	n11 := Val(Substr(cTudo,11,1))
	n12 := Val(Substr(cTudo,12,1))
	n13 := Val(Substr(cTudo,13,1))

	nSoma := (n01*2) + (n02*7) + (n03*6) + (n04*5) + (n05*4) + (n06*3) + (n07*2) + (n08*7) + (n09*6) + (n10*5) + (n11*4) +;
	   (n12*3) + (n13*2)

	nResto := Mod(nSoma,11)

	If nResto == 1
		cDig := "P"
	ElseIf nResto == 0
		cDig := "0"
	Else
		nDifer := 11-nResto
	Endif

	cNossNum := cNumAtual+If(Empty(cDig),Str(nDifer,1,0),cDig)

	dbSelectArea("SEE")
	RecLock("SEE",.F.)
	  Replace	EE_FAXATU	With	Soma1(cNumAtual)
	MsUnlock()

	dbSelectArea("SE1")
	RecLock("SE1",.F.)
	  Replace	E1_NUMBCO	With	cNossNum
	MsUnlock()

Endif

RestArea(aAreaAtual)

Return(cNossNum)
