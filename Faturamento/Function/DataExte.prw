#include "msole.ch"
#include "font.ch"
#include "colors.ch"
#include "rwmake.ch"

/*/{Protheus.doc} DataExte
Retorna Data por extenso
@author Unknown

@since 02/01/2018
/*/
User Function DataExte(dDataE, nTipExt, cIdioma)
////////////////////////////////////////////////
//
Local dDataExt    := IIf(Empty(dDataE), dDataBase, dDataE) // Data Desejada para o Extenso
Local cLingua     := IIf(Empty(cIdioma), "P", cIdioma)     // Idioma para o Extenso
Local cDatEmissao := ""                                    // Data de Emissao por Extenso
Local cNomeCidade := ""                                    // Nome da Cidade
Local aMesExtenso := {}                                    // Matriz de Meses do Ano
Local nMesExtenso := Month(dDataExt)                       // Mes a Expandir o Extenso
Local nModoExibir := nTipExt                               // Modo de Exibir o Extenso (1=Numerico, 2=Nome do Mes)
//
cNomeCidade := Alltrim(Upper(Substr(SM0->M0_CIDENT, 1, 1)) +;
               Lower(Substr(SM0->M0_CIDENT, 2, 29)))
//
cNomeCidade := IIf(Empty(cNomeCidade), "Indaiatuba", cNomeCidade)
//
If !(cLingua $ "P,E,S")                // A Lingua Deve Ser P=Portugues, E=Ingles, S=Espanhol
   cLingua := "P"
Endif
//
If cLingua == "P"
   //
   Aadd(aMesExtenso, " de Janeiro de ")
   Aadd(aMesExtenso, " de Fevereiro de ")
   Aadd(aMesExtenso, " de Marco de ")
   Aadd(aMesExtenso, " de Abril de ")
   Aadd(aMesExtenso, " de Maio de ")
   Aadd(aMesExtenso, " de Junho de ")
   Aadd(aMesExtenso, " de Julho de ")
   Aadd(aMesExtenso, " de Agosto de ")
   Aadd(aMesExtenso, " de Setembro de ")
   Aadd(aMesExtenso, " de Outubro de ")
   Aadd(aMesExtenso, " de Novembro de ")
   Aadd(aMesExtenso, " de Dezembro de ")
   //
   If nModoExibir == 1
      cDatEmissao := cNomeCidade + ", " + Strzero(Day(dDataExt), 2, 0) + "/" + Strzero(Month(dDataExt), 2, 0) + "/" + Strzero(Year(dDataExt), 4, 0)
   Else
      cDatEmissao := cNomeCidade + ", " + Strzero(Day(dDataExt), 2, 0) + aMesExtenso[nMesExtenso] + Strzero(Year(dDataExt), 4, 0)
   Endif
   //
Elseif cLingua == "E"
   //
   Aadd(aMesExtenso, "January")
   Aadd(aMesExtenso, "February")
   Aadd(aMesExtenso, "March")
   Aadd(aMesExtenso, "April")
   Aadd(aMesExtenso, "May")
   Aadd(aMesExtenso, "June")
   Aadd(aMesExtenso, "July")
   Aadd(aMesExtenso, "August")
   Aadd(aMesExtenso, "September")
   Aadd(aMesExtenso, "October")
   Aadd(aMesExtenso, "November")
   Aadd(aMesExtenso, "December")
   //
   If nModoExibir == 1
      cDatEmissao := cNomeCidade + ", " + Strzero(Day(dDataExt), 2, 0) + "/" + Strzero(Month(dDataExt), 2, 0) + "/" + Strzero(Year(dDataExt), 4, 0)
   Else
      cDatEmissao := cNomeCidade + ", " + aMesExtenso[nMesExtenso] + " " + Strzero(Day(dDataExt), 2, 0) + "th, " + Strzero(Year(dDataExt), 4, 0)
   Endif
   //
Else
   //
   Aadd(aMesExtenso, " de Janeiro de ")
   Aadd(aMesExtenso, " de Fevereiro de ")
   Aadd(aMesExtenso, " de Marco de ")
   Aadd(aMesExtenso, " de Abril de ")
   Aadd(aMesExtenso, " de Maio de ")
   Aadd(aMesExtenso, " de Junho de ")
   Aadd(aMesExtenso, " de Julho de ")
   Aadd(aMesExtenso, " de Agosto de ")
   Aadd(aMesExtenso, " de Setembro de ")
   Aadd(aMesExtenso, " de Outubro de ")
   Aadd(aMesExtenso, " de Novembro de ")
   Aadd(aMesExtenso, " de Dezembro de ")
   //
   If nModoExibir == 1
      cDatEmissao := cNomeCidade + ", " + Strzero(Day(dDataExt), 2, 0) + "/" + Strzero(Month(dDataExt), 2, 0) + "/" + Strzero(Year(dDataExt), 4, 0)
   Else
      cDatEmissao := cNomeCidade + ", " + Strzero(Day(dDataExt), 2, 0) + aMesExtenso[nMesExtenso] + Strzero(Year(dDataExt), 4, 0)
   Endif
   //
Endif
//
Return (cDatEmissao)
