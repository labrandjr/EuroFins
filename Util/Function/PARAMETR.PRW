#include "rwmake.ch"
/*/{Protheus.doc} Parametr
Rotinas para criacao de parametros, de tabelas, validacoes, gatilhos e outras p/ fins especificos
@author Paulo Roberto de Oliveira
@since 04/01/2018
/*/
User Function Parametr()
////////////////////////
//
Local _xAlias := Alias()               // Salvar Contextos
Local _xOrder := IndexOrd()
Local _xRecno := Recno()
//
Local _nRegSX6 := SX6->(Recno())
Local _nOrdSX6 := SX6->(IndexOrd())
//
_cX6_VAR     := ""                     // Parametro Especifico
_cX6_CONTEUD := ""                     // Conteudo Especifico
//
SX6->(DbSetOrder(1))                   // Parametros do Sistema
//
_cX6_VAR     := "MV_GS_PRE"
_cX6_CONTEUD := "B 25"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())                     // Criar o Parametro Se Nao Existir
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Prefixo do Arquivo do Documento do  MS-Word Utili-"
      SX6->X6_DESC1   := "zado na Geracao de Certificados de Analise.       "
      SX6->X6_DESC2   := ""
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_lMudaAno    := .F.
_cX6_VAR     := "MV_GS_ANO"
_cX6_CONTEUD := Substr(Strzero(Year(dDataBase), 4), 3, 2)
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Ano do Arquivo do Documento  do  MS-Word Utilizado"
      SX6->X6_DESC1   := "na Geracao de Certificados de Analise.            "
      SX6->X6_DESC2   := ""
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Else
   //
   cAnoAtu := Substr(Strzero(Year(dDataBase), 4), 3, 2)
   cAnoPar := Alltrim(GetMv("MV_GS_ANO"))
   //
   If cAnoAtu > cAnoPar                // Se o Ano Atual Superior ao do Parametro
      //
      _cX6_CONTEUD := cAnoAtu          // Atualizar o Conteudo
      //
      DbSelectArea("SX6")
      If SX6->(RecLock("SX6", .F.))
         //
         SX6->X6_CONTEUD := _cX6_CONTEUD
         SX6->X6_CONTSPA := SX6->X6_CONTEUD
         SX6->X6_CONTENG := SX6->X6_CONTEUD
         //
         SX6->(MsUnlock())
         //
         _lMudaAno := .T.
         //
      Endif
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_NRON"
_cX6_CONTEUD := "N00000"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Numero Sequencial  do  Arquivo  do  Documento  do "
      SX6->X6_DESC1   := "Ms-Word Utilizado na Geracao de Certificados para "
      SX6->X6_DESC2   := "Analises Nacionais.                               "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Else
   //
   If _lMudaAno                        // Se o Ano Atual Superior ao do Parametro
      //
      _cX6_CONTEUD := "N00000"         // Atualizar o Conteudo
      //
      DbSelectArea("SX6")
      If SX6->(RecLock("SX6", .F.))
         //
         SX6->X6_CONTEUD := _cX6_CONTEUD
         SX6->X6_CONTSPA := SX6->X6_CONTEUD
         SX6->X6_CONTENG := SX6->X6_CONTEUD
         //
         SX6->(MsUnlock())
         //
      Endif
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_NROI"
_cX6_CONTEUD := "I00000"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Numero Sequencial  do  Arquivo  do  Documento  do "
      SX6->X6_DESC1   := "Ms-Word Utilizado na Geracao de Certificados para "
      SX6->X6_DESC2   := "Analises Intercompany.                            "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Else
   //
   If _lMudaAno                        // Se o Ano Atual Superior ao do Parametro
      //
      _cX6_CONTEUD := "I00000"         // Atualizar o Conteudo
      //
      DbSelectArea("SX6")
      If SX6->(RecLock("SX6", .F.))
         //
         SX6->X6_CONTEUD := _cX6_CONTEUD
         SX6->X6_CONTSPA := SX6->X6_CONTEUD
         SX6->X6_CONTENG := SX6->X6_CONTEUD
         //
         SX6->(MsUnlock())
         //
      Endif
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_NROT"
_cX6_CONTEUD := "T00000"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Numero Sequencial  do  Arquivo  do  Documento  do "
      SX6->X6_DESC1   := "Ms-Word Utilizado na Geracao de Certificados para "
      SX6->X6_DESC2   := "Analises de Testes.                               "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Else
   //
   If _lMudaAno                        // Se o Ano Atual Superior ao do Parametro
      //
      _cX6_CONTEUD := "T00000"         // Atualizar o Conteudo
      //
      DbSelectArea("SX6")
      If SX6->(RecLock("SX6", .F.))
         //
         SX6->X6_CONTEUD := _cX6_CONTEUD
         SX6->X6_CONTSPA := SX6->X6_CONTEUD
         SX6->X6_CONTENG := SX6->X6_CONTEUD
         //
         SX6->(MsUnlock())
         //
      Endif
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_DOT"
_cX6_CONTEUD := "\Samples\Documents\Laudos\"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Pasta dos Arquivos de Modelos de Documentos Utili-"
      SX6->X6_DESC1   := "zados para Laudos do MS-Word (.Dot).              "
      SX6->X6_DESC2   := ""
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_DOC"
_cX6_CONTEUD := "C:\WordTmp\"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Pasta dos Arquivos de Documentos Gerados  Utiliza-"
      SX6->X6_DESC1   := "zados para Laudos do MS-Word (.Doc) na Estacao.   "
      SX6->X6_DESC2   := ""
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_COP"
_cX6_CONTEUD := "\Laudos\" + Strzero(Year(dDataBase), 4) + "\"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Pasta dos Arquivos de Documentos Gerados  Utiliza-"
      SX6->X6_DESC1   := "zados para Laudos do MS-Word (.Doc) no Servidor.  "
      SX6->X6_DESC2   := ""
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_ICM"
_cX6_CONTEUD := "NAT_ICMS  "
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Codigo da Natureza para Titulos Financeiros  Gera-"
      SX6->X6_DESC1   := "dos a partir das Notas Fiscais de Importacao  para"
      SX6->X6_DESC2   := "o Valor do ICMS.                                  "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_SEG"
_cX6_CONTEUD := "NAT_SEGURO"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Codigo da Natureza para Titulos Financeiros  Gera-"
      SX6->X6_DESC1   := "dos a partir das Notas Fiscais de Importacao  para"
      SX6->X6_DESC2   := "o Valor do Seguro.                                "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_DESP"
_cX6_CONTEUD := "NAT_DESPESA"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Codigo da Natureza para Titulos Financeiros  Gera-"
      SX6->X6_DESC1   := "dos a partir das Notas Fiscais de Importacao  para"
      SX6->X6_DESC2   := "o Valor das Despesas.                             "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_IIMP"
_cX6_CONTEUD := "IMP_IMPORT"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Codigo da Natureza para Titulos Financeiros  Gera-"
      SX6->X6_DESC1   := "dos a partir das Notas Fiscais de Importacao  para"
      SX6->X6_DESC2   := "o Valor do Imposto de Importacao.                 "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_CA01"
_cX6_CONTEUD := "000159,000066,999999,"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Lista de Codigos de Clientes que Requerem a  Emis-"
      SX6->X6_DESC1   := "sao do Anexo 1 Referente a Resultados de Laudos.  "
      SX6->X6_DESC2   := "                                                  "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_CA02"
_cX6_CONTEUD := "000032,999999,"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Lista de Codigos de Clientes que Requerem a  Emis-"
      SX6->X6_DESC1   := "sao do Anexo 2 Referente a Resultados de Laudos.  "
      SX6->X6_DESC2   := "                                                  "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_APV"
_cX6_CONTEUD := "\SYSTEM\PEDVENDA.DBF"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Arquivo de dados de Pedidos de Venda a ser gerado "
      SX6->X6_DESC1   := "para ser aberto posteriormente no MS-Excel.       "
      SX6->X6_DESC2   := "                                                  "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_CPV"
_cX6_CONTEUD := "C:\TEMP\PEDVENDA.DBF"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Arquivo de dados de Pedidos  de  Venda  copiado em"
      SX6->X6_DESC1   := "maquina local para ser aberto pelo MS-Excel.      "
      SX6->X6_DESC2   := "                                                  "
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
_cX6_VAR     := "MV_GS_EMLS"
_cX6_CONTEUD := "analises@genescan.com.br;f.oliveira@genescan.com.br;f.machado@genescan.com.br;f.barreto@genescan.com.br"
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(!Found())
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .T.))
      //
      SX6->X6_FIL     := xFilial("SX6")
      SX6->X6_VAR     := _cX6_VAR
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Lista de E-mails para serem informados no  Arquivo"
      SX6->X6_DESC1   := "de Dados de Pedidos de Venda para a Gerencia.     "
      SX6->X6_DESC2   := ""
      SX6->X6_DSCSPA  := SX6->X6_DESCRIC
      SX6->X6_DSCSPA1 := SX6->X6_DESC1
      SX6->X6_DSCSPA2 := SX6->X6_DESC2
      SX6->X6_DSCENG  := SX6->X6_DESCRIC
      SX6->X6_DSCENG1 := SX6->X6_DESC1
      SX6->X6_DSCENG2 := SX6->X6_DESC2
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := SX6->X6_CONTEUD
      SX6->X6_CONTENG := SX6->X6_CONTEUD
      SX6->X6_PROPRI  := "U"
      SX6->X6_PYME    := "S"
      //
      SX6->(MsUnlock())
      //
   Endif
   //
Endif
//
SX6->(DbSetOrder(_nOrdSX6))            // Restaurar Contextos
SX6->(DbGoTo(_nRegSX6))
//
CriarTab()                             // Verificacao e Criacao de Tabelas Especificas
//
CriarCon()                             // Verificacao e Criacao de Consultas Especificas
//
DbSelectArea(_xAlias)
DbSetOrder(_xOrder)
DbGoTo(_xRecno)
//
If _lMudaAno
   MsgBox("Foram Alterados os Parâmetros de Ano e Sequência para Certificados !!!", "Atenção !!!", "INFO")
Endif
//
Return (.T.)

//////////////////////////
Static Function CriarTab()
//////////////////////////
//
Local cX5_TABELA := "00"               // Tabela Geral do Sistema
Local cX5_CHAVE  := "Z1    "           // Reponsaveis p/ Laudos
Local cX5_DESCRI := ""                 // Descricao do Responsavel
//
Local _nRegSX5 := SX5->(Recno())       // Salvar Contextos
Local _nOrdSX5 := SX5->(IndexOrd())
//
SX5->(DbSetOrder(1))                   // Tabelas do Sistema
//
SX5->(DbSeek(xFilial("SX5") + cX5_TABELA + cX5_CHAVE, .F.))
//
If SX5->(!Found())
   //
   DbSelectArea("SX5")
   If SX5->(RecLock("SX5", .T.))
      //
      SX5->X5_FILIAL  := xFilial("SX5")
      SX5->X5_TABELA  := cX5_TABELA
      SX5->X5_CHAVE   := cX5_CHAVE
      SX5->X5_DESCRI  := "RESPONSAVEIS P/ LAUDOS"
      SX5->X5_DESCSPA := SX5->X5_DESCRI
      SX5->X5_DESCENG := SX5->X5_DESCRI
      //
      SX5->(MsUnLock())
      //
   Endif
   //
Endif
//
For x := 1 To 3                        // Criacao dos Responsaveis p/ Laudos
    //
    cX5_TABELA := "Z1"
    cX5_CHAVE  := Space(6)
    cX5_DESCRI := Space(50)
    //
    If x == 1
       //
       cX5_CHAVE   := "000001"
       cX5_DESCRI  := "Mariana C. Daher, Gerente de Servicos Tecnicos"
       cX5_DESCENG := "Mariana C. Daher, Technical Service Manager"
       cX5_DESCSPA := "Mariana C. Daher, Gerente de Servicos Tecnicos"
       //
    Elseif x == 2
       //
       cX5_CHAVE   := "000002"
       cX5_DESCRI  := "Flavia Machado S. D'Elia, Labmanager"
       cX5_DESCENG := "Flavia Machado S. D'Elia, Labmanager"
       cX5_DESCSPA := "Flavia Machado S. D'Elia, Labmanager"
       //
    Elseif x == 3
       //
       cX5_CHAVE   := "000003"
       cX5_DESCRI  := "Juliana B. Sacilotti, Gerente de Servicos Tecnicos"
       cX5_DESCENG := "Juliana B. Sacilotti, Technical Service Manager"
       cX5_DESCSPA := "Juliana B. Sacilotti, Gerente de Servicos Tecnicos"
       //
    Endif
    //
    SX5->(DbSeek(xFilial("SX5") + cX5_TABELA + cX5_CHAVE, .F.))
    //
    If SX5->(!Found())
       //
       DbSelectArea("SX5")
       If SX5->(RecLock("SX5", .T.))
          //
          SX5->X5_FILIAL  := xFilial("SX5")
          SX5->X5_TABELA  := cX5_TABELA
          SX5->X5_CHAVE   := cX5_CHAVE
          SX5->X5_DESCRI  := cX5_DESCRI
          SX5->X5_DESCSPA := cX5_DESCSPA
          SX5->X5_DESCENG := cX5_DESCENG
          //
          SX5->(MsUnLock())
          //
       Endif
       //
    Endif
    //
Next
//
cX5_TABELA := "00"                     // Tabela Geral do Sistema
cX5_CHAVE  := "Z2    "                 // Modelos .Dot do MS-Word p/ Laudos
cX5_DESCRI := ""                       // Descricao do Modelo .Dot
//
SX5->(DbSeek(xFilial("SX5") + cX5_TABELA + cX5_CHAVE, .F.))
//
If SX5->(!Found())
   //
   DbSelectArea("SX5")
   If SX5->(RecLock("SX5", .T.))
      //
      SX5->X5_FILIAL  := xFilial("SX5")
      SX5->X5_TABELA  := cX5_TABELA
      SX5->X5_CHAVE   := cX5_CHAVE
      SX5->X5_DESCRI  := "MODELOS .DOT DO MS-WORD P/ LAUDOS"
      SX5->X5_DESCSPA := SX5->X5_DESCRI
      SX5->X5_DESCENG := SX5->X5_DESCRI
      //
      SX5->(MsUnLock())
      //
   Endif
   //
Endif
//
For x := 1 To 8                        // Criacao dos Responsaveis p/ Laudos
    //
    cX5_TABELA := "Z2"
    cX5_CHAVE  := Strzero(x, 2) + Space(4)
    cX5_DESCRI := "Modelo Nro. " + Alltrim(cX5_CHAVE) + " do MS-Word p/ Laudos (.Dot)"
    //
    If x == 1
       cX5_DESCRI := "Ciclos, Resultado, Limite (Uma Linha)"
    Elseif x == 2
       cX5_DESCRI := "Especie, Resultado, Margem, Limite (Uma Linha)"
    Elseif x == 3
       cX5_DESCRI := "Ciclos, Resultado, Limite (Duas Linhas)"
    Elseif x == 5
       cX5_DESCRI := "Ciclos, Resultado, Limite (Tres Linhas)"
    Endif
    //
    SX5->(DbSeek(xFilial("SX5") + cX5_TABELA + cX5_CHAVE, .F.))
    //
    If SX5->(!Found())
       //
       DbSelectArea("SX5")
       If SX5->(RecLock("SX5", .T.))
          //
          SX5->X5_FILIAL  := xFilial("SX5")
          SX5->X5_TABELA  := cX5_TABELA
          SX5->X5_CHAVE   := cX5_CHAVE
          SX5->X5_DESCRI  := cX5_DESCRI
          SX5->X5_DESCSPA := SX5->X5_DESCRI
          SX5->X5_DESCENG := SX5->X5_DESCRI
          //
          SX5->(MsUnLock())
          //
       Endif
       //
    Endif
    //
Next
//
SX5->(DbSetOrder(_nOrdSX5))            // Restaurar Contextos
SX5->(DbGoTo(_nRegSX5))
//
Return (.T.)

//////////////////////////
Static Function CriarCon()
//////////////////////////
//
Local _nRegSXB := SXB->(Recno())       // Salvar Contextos
Local _nOrdSXB := SXB->(IndexOrd())
//
Local aRegs := {}
//
SXB->(DbSetOrder(1))                   // Consultas Padrao
//
Aadd(aRegs,{"XBR   ", "1", "01", "DB", "Tipos de Produto    ", "Tipos de Produto    ", "Tipos de Produto    ", "SBR"            , ""})
Aadd(aRegs,{"XBR   ", "2", "01", "01", "Codigo Base         ", "Codigo Base         ", "Codigo Base         ", ""               , ""})
Aadd(aRegs,{"XBR   ", "2", "02", "02", "Descricao           ", "Descricao           ", "Descricao           ", ""               , ""})
Aadd(aRegs,{"XBR   ", "4", "01", "01", "Codigo Base         ", "Codigo Base         ", "Codigo Base         ", "SBR->BR_BASE"   , ""})
Aadd(aRegs,{"XBR   ", "4", "01", "02", "Descricao           ", "Descricao           ", "Descricao           ", "SBR->BR_DESCPRD", ""})
Aadd(aRegs,{"XBR   ", "4", "01", "03", "Grupo               ", "Grupo               ", "Grupo               ", "SBR->BR_GRUPO"  , ""})
Aadd(aRegs,{"XBR   ", "4", "02", "01", "Codigo Base         ", "Codigo Base         ", "Codigo Base         ", "SBR->BR_BASE"   , ""})
Aadd(aRegs,{"XBR   ", "4", "02", "02", "Descricao           ", "Descricao           ", "Descricao           ", "SBR->BR_DESCPRD", ""})
Aadd(aRegs,{"XBR   ", "4", "02", "03", "Grupo               ", "Grupo               ", "Grupo               ", "SBR->BR_GRUPO"  , ""})
Aadd(aRegs,{"XBR   ", "5", "01", "01", "                    ", "                    ", "                    ", "SBR->BR_BASE"   , ""})
//
For i := 1 To Len(aRegs)
    //
    SXB->(DbSeek(aRegs[i, 1] + aRegs[i, 2] + aRegs[i, 3] + aRegs[i, 4]))
    //
    If SXB->(!Found())
       //
       DbSelectArea("SXB")
       If SXB->(Reclock("SXB", .T.))
          //
          For j := 1 To FCount()
              FieldPut(j, aRegs[i, j])
          Next
          //
          SXB->(MsUnlock())
          //
       Endif
       //
    Endif
    //
Next
//
SXB->(DbSetOrder(_nOrdSXB))            // Restaurar Contextos
SXB->(DbGoTo(_nRegSXB))
//
Return (.T.)

//////////////////////////////////////////
User Function PesqResp(_cCodigo, _cLingua)
//////////////////////////////////////////
//
Local cX5_TABELA := "Z1"               // Tabela de Responsaveis p/ Laudos
Local cX5_CHAVE  := Space(6)           // Codigo do Responsavel p/ Laudos
Local cX5_DESCRI := Space(50)          // Nome do Responsavel p/ Laudos
//
Local _cAlias  := Alias()              // Salvar Contextos
Local _nOrder  := IndexOrd()
Local _nRecno  := Recno()
//
Local _nRegSX5 := SX5->(Recno())
Local _nOrdSX5 := SX5->(IndexOrd())
//
If !(_cLingua $ "P,E,S")               // A Lingua Deve Ser P=Portugues, E=Ingles, S=Espanhol
   _cLingua := "P"
Endif
SX5->(DbSetOrder(1))                   // Tabelas do Sistema
//
cX5_CHAVE := Upper(Substr(Alltrim(_cCodigo) + Space(6), 1, 6))
//
SX5->(DbSeek(xFilial("SX5") + cX5_TABELA + cX5_CHAVE, .F.))
//
If SX5->(Found())
   //
   If _cLingua == "P"
      cX5_DESCRI := Alltrim(SX5->X5_DESCRI)
   Elseif _cLingua == "E"
      cX5_DESCRI := Alltrim(SX5->X5_DESCENG)
   Elseif _cLingua == "S"
      cX5_DESCRI := Alltrim(SX5->X5_DESCSPA)
   Endif
   //
Endif
//
If Empty(cX5_DESCRI)
   cX5_DESCRI := "N/T"
Endif
//
SX5->(DbSetOrder(_nOrdSX5))            // Restaurar Contextos
SX5->(DbGoTo(_nRegSX5))
//
DbSelectArea(_cAlias)
DbSetOrder(_nOrder)
DbGoTo(_nRecno)
//
Return (cX5_DESCRI)

/////////////////////////////////
User Function PesqCert(_cTipCert)
/////////////////////////////////
//
Local _cNroCert := ""                  // Numero do Certificado a Retornar
Local _cPreCert := ""                  // Prefixo do Certificado
Local _cAnoCert := ""                  // Ano do Certificado
Local _cSeqCert := ""                  // Numero Sequencial do Certificado por Tipo
//
Local _xAlias := Alias()               // Salvar Contextos
Local _xOrder := IndexOrd()
Local _xRecno := Recno()
//
Local _nRegSX6 := SX6->(Recno())
Local _nOrdSX6 := SX6->(IndexOrd())
//
Local _cX6_VAR     := ""               // Parametro Especifico
Local _cX6_CONTEUD := ""               // Conteudo Especifico
//
If !(_cTipCert $ "N,I,T,O")
   _cTipCert := "N"
Endif
//
If _cTipCert == "O"                    // Outros (Remessa) : Nao Tem Certificado
   Return ("N/T")
Endif
//
U_Parametr()                           // Verificacao e Criacao de Parametros Especificos
//
SX6->(DbSetOrder(1))                   // Parametros do Sistema
//
If _cTipCert == "N"                    // Nacional
   _cX6_VAR := "MV_GS_NRON"
Elseif _cTipCert == "I"                // Intercompany
   _cX6_VAR := "MV_GS_NROI"
Elseif _cTipCert == "T"                // Testes
   _cX6_VAR := "MV_GS_NROT"
Endif
//
_cPreCert := GetMv("MV_GS_PRE")
_cAnoCert := GetMv("MV_GS_ANO")
_cSeqCert := GetMv(_cX6_VAR)
//
SX6->(DbSeek(xFilial("SX6") + _cX6_VAR, .F.))
//
If SX6->(Found())
   //
   _cX6_CONTEUD := Soma1(_cSeqCert)    // Proximo Numero Sequencial
   //
   DbSelectArea("SX6")
   If SX6->(RecLock("SX6", .F.))
      //
      SX6->X6_CONTEUD := _cX6_CONTEUD
      SX6->X6_CONTSPA := _cX6_CONTEUD
      SX6->X6_CONTENG := _cX6_CONTEUD
      //
      SX6->(MsUnlock())
      //
   Endif
   //
   _cSeqCert := GetMv(_cX6_VAR)        // Novo Numero Sequencial
   //
Endif
//
_cNroCert := Alltrim(_cPreCert) + "-" + Alltrim(_cAnoCert) + "-" + Alltrim(_cSeqCert)
//
SX6->(DbSetOrder(_nOrdSX6))            // Restaurar Contextos
SX6->(DbGoTo(_nRegSX6))
//
DbSelectArea(_xAlias)
DbSetOrder(_xOrder)
DbGoTo(_xRecno)
//
Return (_cNroCert)

///////////////////////////////////////////
User Function AchaOrdem(_cArquivo, _cChave)
///////////////////////////////////////////
//
Local _sAlias := Alias()               // Area Corrente
Local _cOrdem := "1"                   // Inicio da Pesquisa Sempre Pela Ordem "1"
Local _nOrdem := 0                     // Ordem do Indice Desejado
Local _lOk    := .F.                   // Status de Indice Desejado Encontrado
//
SIX->(DbSetOrder(1))                   // Tabela de Indices do Sistema
//
_cChave := Upper(Alltrim(Strtran(_cChave, " ", "")))
//
SIX->(DbSeek(_cArquivo + _cOrdem, .F.))
//
While SIX->(!Eof()) .And. (SIX->INDICE == _cArquivo)
      //
      _nOrdem := (_nOrdem + 1)
      //
      If (Upper(Alltrim(Strtran(SIX->CHAVE, " ", ""))) == _cChave)
         //
         _lOk := .T.
         Exit
         //
      Endif
      //
      SIX->(DbSkip())
      //
Enddo
//
If !(_lOk)
   _nOrdem := Val(_cOrdem)             // Retornar a Ordem Master Se Nao Encontrar
Endif
//
DbSelectArea(_sAlias)
//
Return (_nOrdem)

////////////////////////////////
User Function Converte(_cString)
////////////////////////////////
//
Local _cExpressao := _cString          // Expressao c/ Acentuacao Convertida p/ Sem Acentuacao
//
_cExpressao := Strtran(_cExpressao, Chr(243), "O")
_cExpressao := Strtran(_cExpressao, Chr(225), "A")
_cExpressao := Strtran(_cExpressao, Chr(227), "A")
_cExpressao := Strtran(_cExpressao, Chr(237), "I")
_cExpressao := Strtran(_cExpressao, Chr(250), "U")
_cExpressao := Strtran(_cExpressao, Chr(186), "R")
_cExpressao := Strtran(_cExpressao, Chr(231), "C")
_cExpressao := Strtran(_cExpressao, Chr(233), "E")
_cExpressao := Strtran(_cExpressao, Chr(234), "E")
_cExpressao := Strtran(_cExpressao, Chr(244), "O")
_cExpressao := Strtran(_cExpressao, Chr(245), "O")
_cExpressao := Strtran(_cExpressao, Chr(195), "A")
//
Return (_cExpressao)