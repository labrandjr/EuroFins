#include "rwmake.ch"
/*/{Protheus.doc} PedExcel
Criacao de um arquivo .DBF de itens de pedidos de venda para ser aberto pelo MS-Excel
@author Paulo Roberto de Oliveira
@since 02/01/2018

/*/
User Function PedExcel()
////////////////////////
//
Private lEnd  := .F.                   // Variaveis Auxiliares
Private cPerg := Padr("PEDEXC",10)
Private aStruct, cArqPed, cIndPed
//
U_Parametr()                           // Verificacao e Criacao de Parametros Especificos
//
Perguntas()                            // Verificar Perguntas Especificas
//
If !Pergunte(cPerg, .T.)
   Return (.T.)
Endif
//
If Mv_Par02 < Mv_Par01 .Or. Empty(Mv_Par02) .Or. Mv_Par06 < Mv_Par04 .Or. Empty(Mv_Par06) .Or.;
   Mv_Par07 < Mv_Par05 .Or. Empty(Mv_Par07) .Or. Mv_Par11 < Mv_Par10 .Or. Empty(Mv_Par11) .Or.;
   Mv_Par13 < Mv_Par12 .Or. Empty(Mv_Par13) .Or. Mv_Par16 < Mv_Par14 .Or. Empty(Mv_Par16) .Or.;
   Mv_Par17 < Mv_Par15 .Or. Empty(Mv_Par17) .Or. Mv_Par20 < Mv_Par19 .Or. Empty(Mv_Par20)
   //
   MsgBox("Parâmetros Informados Incorretamente !!!", "Atenção !!!", "INFO")
   Return (.T.)
   //
Endif
//
cArqPed := Alltrim(GetMv("MV_GS_APV")) // Arquivo de Pedidos de Venda Temporario
cArqSai := Alltrim(GetMv("MV_GS_CPV")) // Arquivo de Saida Local p/ Abrir no MS-Excel  // C:\TEMP\PEDVENDA.DBF
//
For nA:=1 to Len(cArqSai)
	If Substr(cArqSai,nA,1) == "\"
		nAux := nA
	Endif
Next
cDiret := Substr(cArqSai,1,nAux)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria diretorio, caso nao exista                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeDir(cDiret)

If MsgBox("Confirma a Geração do Arquivo dos Pedidos de Venda para o MS-Excel", "Pedidos de Venda", "YESNO")
   If File(cArqSai)
      FErase(cArqSai)                  // Apagar Arquivo Temporario Anterior Se Existir
   Endif
   If File(cArqPed)
      FErase(cArqPed)                  // Apagar Arquivo Temporario Anterior Se Existir
   Endif
   Processa({|lEnd| AtuPedid()}, "Pedidos de Venda")
Endif
//
//If File(cArqPed) .And. !Empty(cArqSai) // Mostrar o Arquivo Como Uma Planilha do MS-Excel
If !Empty(cArqSai) // Mostrar o Arquivo Como Uma Planilha do MS-Excel
   //
   If File(cArqSai)
      FErase(cArqSai)                  // Apagar Arquivo Temporario Anterior Se Existir
   Endif
   //
   //Copy File &cArqPed To &cArqSai      // Copiar o Arquivo p/ Abrir pelo MS-Excel
   //
//   If MsgBox("Deseja Abrir o Arquivo de Pedidos de Venda Gerado em " + /*cArqSai +*/ " pelo MS-Excel", "Planilha do MS-Excel !!!", "YESNO")
      //
      If !ApOleClient("MsExcel")
         MsgBox("Microsoft Excel Não Instalado nesta Máquina !!!", "Atenção !!!", "INFO")
      Else
         //
         Processa({|lEnd| geraExcel()}, "Gerando planilha Excel, aguarde...")
//         oExcelApp := MsExcel():New()
//         oExcelApp:WorkBooks:Open("pedvenda.xml")
//         oExcelApp:SetVisible(.T.)
         //
      Endif
      //
//   Endif
   //
Endif
//
Return (.T.)

//////////////////////////
Static Function AtuPedid()
//////////////////////////
//
Private xCUSTOMER := U_Converte(Upper(SM0->M0_NOMECOM))    // Nome da Empresa
Private xSEND_TO  := Alltrim(GetMv("MV_GS_EMLS"))          // Lista de E-mails
//
If Empty(xCUSTOMER)
   xCUSTOMER := "EUROFINS DO BRASIL ANALISES DE ALIMENTOS LTDA"
Endif
//
SC5->(DbSetOrder(2))                   // Cabecalho de Pedidos de Venda
SC6->(DbSetOrder(1))                   // Itens de Pedidos de Venda
SF4->(DbSetOrder(1))                   // Tipos de Entrada/Saida
SA1->(DbSetOrder(1))                   // Clientes
SB1->(DbSetOrder(1))                   // Produtos
SBR->(DbSetOrder(1))                   // Dados Basicos do Produto
SBM->(DbSetOrder(1))                   // Grupos de Produtos
SZ1->(DbSetOrder(1))                   // Tipos de Amostras
SZ3->(DbSetOrder(1))                   // Descricao das Amostras
SZ6->(DbSetOrder(1))                   // Configuracao p/ Laudos
SZ7->(DbSetOrder(1))                   // Resultados das Analises
//
nTipPro := 4                           // Tamanho do Tipo do Codigo Inteligente do Produto
//
AbreArqPed()                           // Abrir Arquivo Temporario de Pedidos de Venda
//
DbSelectArea("SC5")
ProcRegua(SC5->(LastRec()))
SC5->(DbSeek(xFilial("SC5") + Dtos(Mv_Par01), .T.))
//
While SC5->(!Eof()) .And. SC5->C5_FILIAL == xFilial("SC5") .And. Dtos(SC5->C5_EMISSAO) <= Dtos(Mv_Par02)
      //
      IncProc("Data de Emissão -> " + Dtoc(SC5->C5_EMISSAO))
      //
      If lEnd
         Exit
      Endif
      //
      If SC5->C5_TIPO # "N"            // Apenas Pedidos do Tipo Normal
         //
         SC5->(DbSkip())
         Loop
         //
      Endif
      //
      If (SC5->C5_CLIENTE + SC5->C5_LOJACLI) < (Mv_Par04 + Mv_Par05) .Or.;
         (SC5->C5_CLIENTE + SC5->C5_LOJACLI) > (Mv_Par06 + Mv_Par07)
         //
         SC5->(DbSkip())
         Loop
         //
      Endif
      //
      If (SC5->C5_ZZCLAUD + SC5->C5_ZZLLAUD) < (Mv_Par14 + Mv_Par15) .Or.;
         (SC5->C5_ZZCLAUD + SC5->C5_ZZLLAUD) > (Mv_Par16 + Mv_Par17)
         //
         SC5->(DbSkip())
         Loop
         //
      Endif
      //
      If Mv_Par18 == 1 .Or. Mv_Par18 == 2        // 1=Dados p/ o Laboratorio, 2=Dados p/ a Gerencia
         //
         If SC5->C5_NUM < Mv_Par19 .Or. SC5->C5_NUM > Mv_Par20
            //
            SC5->(DbSkip())
            Loop
            //
         Endif
         //
      Endif
      //
      lTipo := .F.                     // Flag de Tipo de Pedido Valido (.T.) ou Nao (.F.)
      //
      If Mv_Par03 == 1                 // Nacional
         //
         If SC5->C5_ZZTIPCE == "N"
            //
            lTipo := .T.
            cTipo := " - Nacionais"
            //
         Endif
         //
      Elseif Mv_Par03 == 2             // Teste
         //
         If SC5->C5_ZZTIPCE == "T"
            //
            lTipo := .T.
            cTipo := " - Testes"
            //
         Endif
         //
      Elseif Mv_Par03 == 3             // Intercompany
         //
         If SC5->C5_ZZTIPCE == "I"
            //
            lTipo := .T.
            cTipo := " - Intercompany"
            //
         Endif
         //
      Elseif Mv_Par03 == 4             // Outros
         //
         If SC5->C5_ZZTIPCE == "O"
            //
            lTipo := .T.
            cTipo := " - Outros"
            //
         Endif
         //
      Else                             // Todos
         //
         lTipo := .T.
         cTipo := " - Todos"
         //
      Endif
      //
      If !lTipo
         //
         SC5->(DbSkip())
         Loop
         //
      Endif
      //
      SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM, .F.))
      //
      xC6_ITEM := SC6->C6_ITEM         // Primeiro Item do Pedido de Venda
      //
      While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
            //
            If Mv_Par08 == 1           // Apenas o Item Principal (1=Sim, 2=Nao)
               //
               If SC6->C6_ITEM # xC6_ITEM
                  //
                  SC6->(DbSkip())
                  Loop
                  //
               Endif
               //
            Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Somente Origem de Analise == Interna   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If mv_par21 == 1 .and. SC6->C6_ZZEORIG # "I"
            	SC6->(dbSkip())
            	Loop
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Somente Origem de Analise == Externa   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            ElseIf mv_par21 == 2 .and. SC6->C6_ZZEORIG # "E"
            	SC6->(dbSkip())
            	Loop
            Endif

            //
            SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO, .F.))
            //
            If SB1->(!Found())
               //
               SC6->(DbSkip())
               Loop
               //
            Endif
            //
            SBM->(DbSeek(xFilial("SBM") + SB1->B1_GRUPO, .F.))
            //
            If SC6->C6_PRODUTO < Mv_Par10 .Or. SC6->C6_PRODUTO > Mv_Par11 .Or.;
               SB1->B1_GRUPO < Mv_Par12 .Or. SB1->B1_GRUPO > Mv_Par13
               //
               SC6->(DbSkip())
               Loop
               //
            Endif
            //
            xBR_BASE    := Substr(SC6->C6_PRODUTO, 1, nTipPro)
            xBR_DESCPRD := Space(25)
            //
            SBR->(DbSeek(xFilial("SBR") + xBR_BASE, .F.))
            //
            If SBR->(Found())
               xBR_DESCPRD := SBR->BR_DESCPRD
            Endif
            //
            SZ1->(DbSeek(xFilial("SZ1") + SC6->C6_ZZTIPO, .F.))
            //
            SZ3->(DbSeek(xFilial("SZ3") + SC6->C6_ZZSDESC, .F.))
            //
            SF4->(DbSeek(xFilial("SF4") + SC6->C6_TES, .F.))
            //
            If SF4->(!Found())
               //
               SC6->(DbSkip())
               Loop
               //
            Endif
            //
            lTes := .F.                // Flag de TES Valido (.T.) ou Nao (.F.)
            //
            If (Mv_Par09 == 1 .And. SF4->F4_DUPLIC == "S")      // Gera Financeiro
               lTes := .T.
            Elseif (Mv_Par09 == 2 .And. SF4->F4_DUPLIC # "S")   // Nao Gera Financeiro
               lTes := .T.
            Elseif (Mv_Par09 == 3)
               lTes := .T.
            Endif
            //
            If !lTes
               //
               SC6->(DbSkip())
               Loop
               //
            Endif
            //
            xZ7_TIPPRO := Substr(SC6->C6_PRODUTO, 1, nTipPro)
            xZ7_RESQTD := ""
            xZ7_MARGEM := ""
            xZ7_LIMQTD := ""
            xZ7_RESUL1 := ""
            xZ7_RESUL2 := ""
            xZ7_RESUL3 := ""
            //
            SZ6->(DbSeek(xFilial("SZ6") + xZ7_TIPPRO, .F.))
            //
            While SZ6->(!Eof()) .And. SZ6->Z6_FILIAL == xFilial("SZ6") .And. SZ6->Z6_TIPPRO == xZ7_TIPPRO
                  //
                  If SZ6->Z6_ORDEM == "00"       // Desprezar Ordem "00"=Spike
                     //
                     SZ6->(DbSkip())
                     Loop
                     //
                  Endif
                  //
                  xZ7_RESULT := ""
                  //
                  SZ7->(DbSeek(xFilial("SZ7") + SC6->C6_NUM + SC6->C6_ITEM + SZ6->Z6_TIPPRO + SZ6->Z6_TIPDOC + SZ6->Z6_ORDEM, .F.))
                  //
                  If SZ7->(Found())
                     //
                     If (SZ7->Z7_TIPRES $ "P,N")
                        //
                        If SZ7->Z7_TIPRES == "P"
                           xZ7_RESULT := "POSITIVO"
                        Else
                           xZ7_RESULT := "NEGATIVO"
                        Endif
                        //
                        If Empty(xZ7_RESUL1)
                           xZ7_RESUL1 := xZ7_RESULT
                        Elseif Empty(xZ7_RESUL2)
                           xZ7_RESUL2 := xZ7_RESULT
                        Elseif Empty(xZ7_RESUL3)
                           xZ7_RESUL3 := xZ7_RESULT
                        Endif
                        //
                     Elseif (SZ7->Z7_TIPQTD $ "P,N,C,Q")
                        //
                        If SZ7->Z7_TIPQTD == "P"
                           xZ7_RESULT := "POSITIVO"
                        Elseif SZ7->Z7_TIPQTD == "N"
                           xZ7_RESULT := "NEGATIVO"
                        Elseif SZ7->Z7_TIPQTD == "C"
                           xZ7_RESULT := Alltrim(SZ7->Z7_RESQTD)
                        Elseif SZ7->Z7_TIPQTD == "Q"
                           xZ7_RESULT := "NAO QUANTIFICAVEL"
                        Endif
                        //
                        If Empty(xZ7_RESQTD)
                           //
                           xZ7_RESQTD := xZ7_RESULT
                           xZ7_MARGEM := SZ7->Z7_MARGEM
                           xZ7_LIMQTD := SZ7->Z7_LIMQTD
                           //
                        Endif
                        //
                     Endif
                     //
                  Endif
                  //
                  SZ6->(DbSkip())
                  //
            Enddo
            //
            GravarDados()              // Gravar os Dados do Pedido de Venda
            //
            SC6->(DbSkip())
            //
      Enddo
      //
      SC5->(DbSkip())
      //
Enddo
//
//FechaArqPed()                          // Fechar Arquivo Temporario de Pedidos de Venda
//
SC5->(DbSetOrder(1))
//
Return (.T.)

/////////////////////////////
Static Function GravarDados()
/////////////////////////////
//
Local _cChave := (SC6->C6_NUM + SC6->C6_ITEM)
//
DbSelectArea("PED")                    // Atualizar Dados do Pedido de Venda
PED->(DbSeek(_cChave, .F.))
//
If PED->(Found())
   _lGrava := .F.
Else
   _lGrava := .T.
Endif
//
DbSelectArea("PED")
If PED->(RecLock("PED", _lGrava))
   //
   If Mv_Par18 == 1                    // Dados p/ o Laboratorio
      //
      PED->PEDIDO := SC6->C6_NUM
      PED->NROITE := SC6->C6_ITEM
      PED->DATEMI := SC5->C5_EMISSAO
      PED->TIPCER := SC5->C5_ZZTIPCE
      PED->NROCER := SC6->C6_ZZNROCE
      PED->REVCER := SC6->C6_ZZREVCE
      PED->CODPRO := SC6->C6_PRODUTO
      PED->DESPRO := U_Converte(Upper(SC6->C6_DESCRI))
      PED->CODGEN := xBR_DESCPRD
      PED->GRUPRO := SB1->B1_GRUPO
      PED->DESGRU := U_Converte(Upper(SBM->BM_DESC))
      PED->CODTES := SC6->C6_TES
      PED->PREUNI := SC6->C6_PRCVEN
      PED->DATPED := SC5->C5_ZZDATAP
      PED->DATREC := SC5->C5_ZZDATAR
      PED->DATENT := SC5->C5_ZZDTENT
      PED->PADENT := IIf(SC5->C5_ZZTEMPO == "P", "P=PADRAO", IIf(SC5->C5_ZZTEMPO == "E", "E=EXPRESSO", "-"))
      PED->HOMOGE := SC5->C5_ZZHOMOG
      PED->CLIFAT := SC5->C5_CLIENTE
      PED->LOJFAT := SC5->C5_LOJACLI
      PED->NOMFAT := U_Converte(Upper(Posicione("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_NOME")))
      PED->CONFAT := U_Converte(Upper(SC5->C5_ZZCON02))
      PED->CLILAU := SC5->C5_ZZCLAUD
      PED->LOJLAU := SC5->C5_ZZLLAUD
      PED->NOMLAU := U_Converte(Upper(Posicione("SA1", 1, xFilial("SA1") + SC5->C5_ZZCLAUD + SC5->C5_ZZLLAUD, "A1_NOME")))
      PED->CONLAU := U_Converte(Upper(SC5->C5_ZZCON01))
      PED->TIPAMO := Alltrim(SC6->C6_ZZTIPO) + "-" + U_Converte(Upper(Alltrim(SZ1->Z1_DESCP)))
      PED->DESAMO := Alltrim(SC6->C6_ZZSDESC) + "-" + U_Converte(Upper(Alltrim(SZ3->Z3_DESCP)))
      PED->CODAMO := U_Converte(Upper(SC6->C6_ZZCODAM))
      PED->LOTE01 := U_Converte(Upper(SC6->C6_ZZLOT01))
      PED->LOTE02 := U_Converte(Upper(SC6->C6_ZZLOT02))
      PED->LOTE03 := U_Converte(Upper(SC6->C6_ZZLOT03))
      PED->LOTE04 := U_Converte(Upper(SC6->C6_ZZLOT04))
      PED->NRONOT := SC6->C6_NOTA
      PED->SERNOT := SC6->C6_SERIE
      PED->DATNOT := SC6->C6_DATFAT
      PED->RESQTD := xZ7_RESQTD
      PED->MARGEM := xZ7_MARGEM
      PED->LIMQTD := xZ7_LIMQTD
      PED->RESUL1 := xZ7_RESUL1
      PED->RESUL2 := xZ7_RESUL2
      PED->RESUL3 := xZ7_RESUL3
      PED->CODRES := SC6->C6_ZZCODRE + "-" + U_Converte(Upper(U_PesqResp(SC6->C6_ZZCODRE, "P")))
      //
   Else                                // Dados p/ a Gerencia
      //
      PED->CUSTOMER   := xCUSTOMER
      PED->ORDER_NO   := SC6->C6_NUM
      PED->ITEM       := SC6->C6_ITEM
      PED->ORDER_DATE := SC5->C5_EMISSAO
      PED->PURCHASE_O := SC6->C6_ZZNROCE
      PED->COM_LIMS   := IIf(Substr(SC6->C6_PRODUTO, 1, 2) == "IC", Alltrim(Substr(SC6->C6_PRODUTO, 3, 13)), SC6->C6_PRODUTO)
      PED->SAMPLE     := U_Converte(Upper(SC6->C6_ZZCODAM))
      PED->CODE_LOT   := U_Converte(Upper(Alltrim(SC6->C6_ZZLOT01) + " " + Alltrim(SC6->C6_ZZLOT02) + " " + Alltrim(SC6->C6_ZZLOT03) + " " + Alltrim(SC6->C6_ZZLOT04)))
      PED->OBSERV     := U_Converte(Upper(SC5->C5_ZZOBS))
      PED->SEND_TO    := xSEND_TO
      //
   Endif
   //
   PED->(MsUnlock())
   //
Endif
//
Return (.T.)

////////////////////////////
Static Function AbreArqPed()
////////////////////////////
//
cArqPed := Alltrim(GetMv("MV_GS_APV")) // Arquivo de Pedidos de Venda Temporario
//
If Empty(cArqPed)
   cArqPed := "\SYSTEM\PEDVENDA.DTC"
Endif
//
aStruct := {}                          // Estrutura dos Arquivo Temporario
//
If Mv_Par18 == 1                       // Dados p/ o Laboratorio
   //
   Aadd(aStruct, {"PEDIDO", "C", 006, 0})   // Numero do Pedido de Venda
   Aadd(aStruct, {"NROITE", "C", 002, 0})   // Item do Pedido de Venda
   Aadd(aStruct, {"DATEMI", "D", 008, 0})   // Data de Emissao do Pedido
   Aadd(aStruct, {"TIPCER", "C", 001, 0})   // Tipo de Certificado
   Aadd(aStruct, {"NROCER", "C", 020, 0})   // Numero do Certificado
   Aadd(aStruct, {"REVCER", "C", 002, 0})   // Revisao do Certificado
   Aadd(aStruct, {"CODPRO", "C", 015, 0})   // Codigo do Produto
   Aadd(aStruct, {"DESPRO", "C", 040, 0})   // Descricao do Produto
   Aadd(aStruct, {"CODGEN", "C", 025, 0})   // Descricao do Codigo do Produto Inteligente da Genescan
   Aadd(aStruct, {"GRUPRO", "C", 004, 0})   // Grupo de Produtos
   Aadd(aStruct, {"DESGRU", "C", 030, 0})   // Descricao do Grupo de Produtos
   Aadd(aStruct, {"CODTES", "C", 003, 0})   // Codigo do Tipo de Entrada/Saida
   Aadd(aStruct, {"PREUNI", "N", 014, 2})   // Preco Unitario de Venda
   Aadd(aStruct, {"DATPED", "D", 008, 0})   // Data do Pedido
   Aadd(aStruct, {"DATREC", "D", 008, 0})   // Data de Recebimento
   Aadd(aStruct, {"DATENT", "D", 008, 0})   // Data do Entrega
   Aadd(aStruct, {"PADENT", "C", 010, 0})   // Tempo de Entrega
   Aadd(aStruct, {"HOMOGE", "C", 001, 0})   // Homogeneizacao
   Aadd(aStruct, {"CLIFAT", "C", 006, 0})   // Codigo do Cliente p/ Fatura
   Aadd(aStruct, {"LOJFAT", "C", 002, 0})   // Loja p/ Fatura
   Aadd(aStruct, {"NOMFAT", "C", 040, 0})   // Nome do Cliente p/ Fatura
   Aadd(aStruct, {"CONFAT", "C", 030, 0})   // Contato p/ Fatura
   Aadd(aStruct, {"CLILAU", "C", 006, 0})   // Codigo do Cliente p/ Laudo
   Aadd(aStruct, {"LOJLAU", "C", 002, 0})   // Loja p/ Laudo
   Aadd(aStruct, {"NOMLAU", "C", 040, 0})   // Nome do Cliente p/ Laudo
   Aadd(aStruct, {"CONLAU", "C", 030, 0})   // Contato p/ Laudo
   Aadd(aStruct, {"TIPAMO", "C", 045, 0})   // Tipo da Amostra
   Aadd(aStruct, {"DESAMO", "C", 085, 0})   // Descricao da Amostra
   Aadd(aStruct, {"CODAMO", "C", 100, 0})   // Codigo da Amostra
   Aadd(aStruct, {"LOTE01", "C", 100, 0})   // Rotulo/Lote 01
   Aadd(aStruct, {"LOTE02", "C", 100, 0})   // Rotulo/Lote 02
   Aadd(aStruct, {"LOTE03", "C", 100, 0})   // Rotulo/Lote 03
   Aadd(aStruct, {"LOTE04", "C", 100, 0})   // Rotulo/Lote 04
   Aadd(aStruct, {"NRONOT", "C", 006, 0})   // Numero da Nota Fiscal
   Aadd(aStruct, {"SERNOT", "C", 003, 0})   // Serie da Nota Fiscal
   Aadd(aStruct, {"DATNOT", "D", 008, 0})   // Data da Nota Fiscal
   Aadd(aStruct, {"RESQTD", "C", 030, 0})   // Resultado da Quantificacao
   Aadd(aStruct, {"MARGEM", "C", 020, 0})   // Margem de Erro da Quantificacao
   Aadd(aStruct, {"LIMQTD", "C", 020, 0})   // Limite de Quantificacao
   Aadd(aStruct, {"RESUL1", "C", 030, 0})   // Resultado da Analise 1
   Aadd(aStruct, {"RESUL2", "C", 030, 0})   // Resultado da Analise 2
   Aadd(aStruct, {"RESUL3", "C", 030, 0})   // Resultado da Analise 3
   Aadd(aStruct, {"CODRES", "C", 060, 0})   // Responsavel pelo Laudo
   //
Else                                   // Dados p/ a Gerencia
   //
   Aadd(aStruct, {"CUSTOMER"  , "C", 040, 0})   // Nome da Empresa
   Aadd(aStruct, {"ORDER_NO"  , "C", 006, 0})   // Numero do Pedido de Venda
   Aadd(aStruct, {"ITEM"      , "C", 002, 0})   // Item do Pedido de Venda
   Aadd(aStruct, {"ORDER_DATE", "D", 008, 0})   // Data de Emissao do Pedido
   Aadd(aStruct, {"PURCHASE_O", "C", 020, 0})   // Numero do Certificado
   Aadd(aStruct, {"COM_LIMS"  , "C", 015, 0})   // Codigo do Produto
   Aadd(aStruct, {"SAMPLE"    , "C", 100, 0})   // Codigo da Amostra
   Aadd(aStruct, {"CODE_LOT"  , "C", 250, 0})   // Rotulo/Lote/Observacao (400)
   Aadd(aStruct, {"OBSERV"    , "C", 250, 0})   // Observacoes
   Aadd(aStruct, {"SEND_TO"   , "C", 200, 0})   // Lista de E-mails
   //
Endif
//
If File(cArqPed)
   FErase(cArqPed)                     // Apagar Arquivo Temporario Anterior
Endif
//
cArqTmp := CriaTrab(aStruct, .T.)      // Criar Arquivo Temporario Auxiliar
//
cArqAux := cArqTmp + ".DTC"            // Arquivo Temporario Auxiliar
//
Copy File &cArqAux To &cArqPed         // Copiar Arquivo Temporario Consolidado
//
FErase(cArqTmp + ".DTC")               // Apagar Arquivo Temporario Auxiiliar
//
If Mv_Par18 == 1
   cChave := "PED->PEDIDO + PED->NROITE"
Else
   cChave := "PED->ORDER_NO + PED->ITEM"
Endif
//
//DbUseArea(.T.,, cArqPed, "PED", .F., .F.)
DbUseArea(.T.,, cArqPed, "PED", .F., .F.)
//
cIndPed := CriaTrab(Nil, .F.)

IndRegua("PED", cIndPed, cChave,,, "Selecionando Registros ...")
//
DbSelectArea("PED")
DbSetIndex(cIndPed + OrdBagExt())
//
Return (.T.)

/////////////////////////////
Static Function FechaArqPed()
/////////////////////////////
//
DbSelectArea("PED")                    // Fechar Arquivo Temporario
PED->(DbCloseArea())
FErase(cIndPed + OrdBagExt())          // Apagar Indice Temporario
//
Return (.T.)

///////////////////////////
Static Function Perguntas()
///////////////////////////
//
Local sAlias := Alias()                // Variaveis Auxiliares
Local aRegs  := {}
//
SX1->(DbSetOrder(1))                   // Perguntas do Sistema
//
Aadd(aRegs,{cPerg,"01","Da Data de Emissao do Ped.   ?","","","mv_cha","D",08,0,0,"G","",;
    "Mv_Par01","","","","01/01/06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Ate a Data Emissao do Ped.   ?","","","mv_chb","D",08,0,0,"G","NaoVazio()",;
    "Mv_Par02","","","","31/12/49","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Tipo de Pedido p/ Apuracao   ?","","","mv_chc","N",01,0,5,"C","",;
    "Mv_Par03","Nacional","","","","","Teste","","","","","Intercompany","","","","","Outros","","","","","Todos","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Do Codigo do Cliente Fat.    ?","","","mv_chd","C",06,0,0,"G","",;
    "Mv_Par04","","","","      ","","","","","","","","","","","","","","","","","","","","","SA1","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","Da Loja do Cliente Fat.      ?","","","mv_che","C",02,0,0,"G","",;
    "Mv_Par05","","","","  ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"06","Ate o Codigo Cliente Fat.  . ?","","","mv_chf","C",06,0,0,"G","NaoVazio()",;
    "Mv_Par06","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"07","Ate a Loja do Cliente Fat.   ?","","","mv_chg","C",02,0,0,"G","NaoVazio()",;
    "Mv_Par07","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"08","Apenas o Item Principal      ?","","","mv_chh","N",01,0,2,"C","",;
    "Mv_Par08","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"09","Quanto ao Tipo Ent./Saida    ?","","","mv_chi","N",01,0,3,"C","",;
    "Mv_Par09","Com Financeiro","","","","","Sem Financeiro","","","","","Ambos","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"10","Do Codigo do Produto         ?","","","mv_chj","C",15,0,0,"G","",;
    "Mv_Par10","","","","               ","","","","","","","","","","","","","","","","","","","","","SB1","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"11","Ate o Codigo do Produto      ?","","","mv_chl","C",15,0,0,"G","NaoVazio()",;
    "Mv_Par11","","","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","SB1","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"12","Do Grupo de Produtos         ?","","","mv_chm","C",04,0,0,"G","",;
    "Mv_Par12","","","","    ","","","","","","","","","","","","","","","","","","","","","SBM","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"13","Ate o Grupo de Produtos      ?","","","mv_chn","C",04,0,0,"G","NaoVazio()",;
    "Mv_Par13","","","","ZZZZ","","","","","","","","","","","","","","","","","","","","","SBM","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"14","Do Codigo do Cliente Laudo   ?","","","mv_cho","C",06,0,0,"G","",;
    "Mv_Par14","","","","      ","","","","","","","","","","","","","","","","","","","","","SA1","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"15","Da Loja do Cliente p/ Laudo  ?","","","mv_chp","C",02,0,0,"G","",;
    "Mv_Par15","","","","  ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"16","Ate o Codigo Cliente Laudo   ?","","","mv_chq","C",06,0,0,"G","NaoVazio()",;
    "Mv_Par16","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"17","Ate a Loja do Cliente Laudo  ?","","","mv_chr","C",02,0,0,"G","NaoVazio()",;
    "Mv_Par17","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"18","Setor para Destinacao        ?","","","mv_chs","N",01,0,1,"C","",;
    "Mv_Par18","Laboratorio","","","","","Gerencia","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"19","Do Numero do Ped. de Venda   ?","","","mv_cht","C",06,0,0,"G","",;
    "Mv_Par19","","","","      ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"20","Ate o Numero Ped. de Venda   ?","","","mv_chu","C",06,0,0,"G","NaoVazio()",;
    "Mv_Par20","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"21","Origem da Analise            ?","","","mv_chv","N",01,0,0,"C","",;
    "Mv_Par21","Interna","","","","","Externa","","","","","Ambas","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//
For i := 1 To Len(aRegs)               // Gravar as Perguntas
    //
    SX1->(DbSeek(cPerg + aRegs[i, 2]))
    //
    If SX1->(!Found())
       //
       DbSelectArea("SX1")
       If SX1->(Reclock("SX1", .T.))
          //
          For j := 1 To FCount()
              FieldPut(j, aRegs[i, j])
          Next
          //
          SX1->(MsUnlock())
          //
       Endif
       //
    Endif
    //
Next
//
For i := 1 To Len(aRegs)          // Regravar as Perguntas
    //
    SX1->(DbSeek(cPerg + aRegs[i, 2]))
    //
    If SX1->(Found())
       //
       DbSelectArea("SX1")
       If SX1->(Reclock("SX1", .F.))
          //
          If (i >= 1 .And. i <= 2) .Or. (i >= 4 .And. i <= 7) .Or. (i >= 10 .And. i <= 17) .Or. (i >= 19 .And. i <= 20)
             SX1->X1_CNT01 := SX1->X1_CNT01
          Endif
          //
          If i == 3 .Or. i == 8 .Or. i == 9 .Or. i == 18
             SX1->X1_PRESEL := SX1->X1_PRESEL
          Endif
          //
          SX1->(MsUnlock())
          //
       Endif
       //
    Endif
    //
Next
//
DbSelectArea(sAlias)
//
Return (.T.)

static function geraExcel
	local cTxt := ""
	local oExcel := FWMSEXCEL():New()
	local aCol := {}
	local aRow
	local cDesc
	local cDirUsr  := GetTempPath()+"pedvenda.xml"
	local nReg

	dbSelectArea("PED")
	dbSetIndex(cIndPed + OrdBagExt())

	oExcel:AddworkSheet("Pedidos")
	oExcel:AddTable ("Pedidos","Pedidos")

	ProcRegua(PED->(LastRec()))

	PED->(dbGotop())

	For j := 1 To Len(aStruct)
    	oExcel:AddColumn("Pedidos","Pedidos",PED->(FieldName(j)),1,1)
    	aAdd(aCol,PED->(FieldName(j)))
    Next

    while !(PED->(Eof()))
    	IncProc()

    	aRow := {}
		for i:=1 to PED->(fCount())
			if (FieldName(i) == "DESPRO")
				cDesc := strTran(PED->(FieldGet(i)),"<","")
				cDesc := strTran(cDesc,">","")
				aAdd(aRow,cDesc)
			elseif (FieldName(i) == "CODAMO")
				cDesc := strTran(PED->(FieldGet(i)),"&","E")
				aAdd(aRow,cDesc)
			else
				aAdd(aRow,PED->(FieldGet(i)))
			endif
		next

		oExcel:AddRow("Pedidos","Pedidos",aRow)
		PED->(dbSkip())
	enddo

	oExcel:Activate()
	oExcel:GetXMLFile(cDirUsr)

    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open(cDirUsr)
    oExcelApp:SetVisible(.T.)
    oExcelApp:Destroy()


return