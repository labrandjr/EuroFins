#include "rwmake.ch"
#include "topconn.ch"
/*/{Protheus.doc} MA080MNU
Adiciona fun��o na aRotina do Cadastro de TES
@author Robson Neves
@since 04/01/2018
/*/

User Function MA080MNU()               // Ponto de Entrada p/ Adicionar Opcoes na Tela de Cadastro de Tipos de Entrada/Saida (Rotina MATA080)
	Local aRotina := ParamIxb[1]

	Aadd(aRotina, {"Copiar TES ", "U_COPIATES()", 0, 9, 0, Nil})
Return (aRotina)

User Function CopiaTes()               // Rotina de Copia de Tipos de Entrada/Saida
	Private oJanela                        // Janela de Dialogo
	Private lContinua := .F.               // Variavel Auxiliar
	Private xF4_CODIGO                     // Codigo do Tipo de Entrada/Saida a Ser Incluido na Copia
	xF4_CODORI := SF4->F4_CODIGO           // Obter Variaveis da Origem e Destino do Tipo de Entrada/Saida
	xF4_TIPORI := SF4->F4_TIPO
	xF4_CODDES := Substr(SF4->F4_CODIGO, 1, 1) + "ZZ"
	@ 150, 180 To 270, 438 Dialog oJanela Title "C�pia do Tipo de E/S " + Alltrim(xF4_CODORI)
	@ 015, 015 Say "C�digo a Ser Criado " Size 057, 010
	@ 015, 068 Get xF4_CODDES Picture "@!" Size 25, 10 Valid ValidTes()
	@ 040, 052 BmpButton Type 1 Action Continua()
	@ 040, 092 BmpButton Type 2 Action Close(oJanela)
	Activate Dialog oJanela Center
	If !lContinua .Or. Empty(xF4_CODDES)
	   Return (.T.)
	Endif
	If MsgBox("Confirma a Inclus�o do Tipo de Entrada/Saida " + Alltrim(xF4_CODDES) + " no Cadastro ?", "Tipos de Entrada/Sa�da", "YESNO")
	   DbSelectArea("SF4")                 // Captar os Dados do Tipo de Entrada/Saida Atual (Origem)
	   aCampos   := {}
	   aRegistro := {}
	   For i := 1 To FCount()              // Captar os Campos de Origem
		   cNomeCampo := Upper(Alltrim(FieldName(i)))
		   cConteudo  := FieldGet(i)
		   nPosicao   := FieldPos(cNomeCampo)
		   If cNomeCampo == "F4_CODIGO"
			  Aadd(aCampos, xF4_CODDES)
		   Elseif cNomeCampo == "F4_FINALID"
			  Aadd(aCampos, "*** REVISAR *** " + cConteudo)
		   Else
			  Aadd(aCampos, cConteudo)
		   Endif
	   Next i
	   If Len(aCampos) > 0                 // Acumular o Registro de Origem p/ o Registro de Destino
		  Aadd(aRegistro, aCampos)
	   Endif
	   For i := 1 To Len(aRegistro)        // Copiar o Registro de Origem p/ o Novo Registro de Destino
		   SF4->(DbSetOrder(1))            // Verificar e Gravar os Dados Copiados no Destino
		   SF4->(DbSeek(xFilial("SF4") + xF4_CODDES, .F.))
		   If SF4->(!Found())              // Incluir o Registro
			  DbSelectArea("SF4")
			  If SF4->(Reclock("SF4", .T.))
				 For j := 1 To FCount()
					 FieldPut(j, aRegistro[i, j])
				 Next j
				 SF4->(MsUnlock())
			  Endif
		   Endif
	   Next i
	Endif
Return (.T.)

Static Function Continua()
	lContinua := .T.
	Close(oJanela)
Return (.T.)

Static Function ValidTes()             // Validacao do Tipo de Entrada/Saida a Ser Copiado
	Local __cAlias  := Alias()             // Salvar Contextos
	Local __nOrder  := IndexOrd()
	Local __nRecno  := Recno()
	Local __nRegSF4 := SF4->(Recno())
	Local __nOrdSF4 := SF4->(IndexOrd())
	Local _lRetorno := .T.                 // Status de Tipo de Entrada/Saida Valido (.T.) ou Nao (.F.)
	SF4->(DbSetOrder(1))                   // Tipos de Entrada/Saida
	SF4->(DbSeek(xFilial("SF4") + xF4_CODDES, .F.))
	If SF4->(Found()) .And. !Empty(xF4_CODDES)
	   MsgBox("O C�digo do Tipo de Entrada/Sa�da a Ser Criado " + Alltrim(xF4_CODDES) + " J� est� Cadastrado no Sistema, Verifique !!!", "Aten��o !!!", "ALERT")
	   _lRetorno := .F.
	Endif
	If xF4_CODDES < "500" .And. xF4_TIPORI $ "S,"
	   MsgBox("O Tipo de Entrada/Sa�da " + Alltrim(xF4_CODDES) + " Deve Ser de Sa�da de Acordo com o Tipo de Origem, Verifique !!!", "Aten��o !!!", "ALERT")
	   _lRetorno := .F.
	Elseif xF4_CODDES >= "500" .And. xF4_TIPORI $ "E,"
	   MsgBox("O Tipo de Entrada/Sa�da " + Alltrim(xF4_CODDES) + " Deve Ser de Entrada de Acordo com o Tipo de Origem, Verifique !!!", "Aten��o !!!", "ALERT")
	   _lRetorno := .F.
	Endif
	SF4->(DbSetOrder(__nOrdSF4))           // Restaurar Contextos
	SF4->(DbGoTo(__nRegSF4))
	DbSelectArea(__cAlias)
	DbSetOrder(__nOrder)
	DbGoTo(__nRecno)
	If !_lRetorno
	   xF4_CODDES := Space(Len(SF4->F4_CODIGO))
	Endif
Return (_lRetorno)