#include "rwmake.ch"

/*/{protheus.doc}MA080VLD 
Ponto de entrada ativado no botao "OK" do cadastro do TES. (Inclusao / Alteracao / Exclusao).
@Author Marcos Candido
@since  03/09/2015

/*/
User Function MA080VLD

Local lRetorno := .T.   
Local aInfo := {}
Local aOpc  := PARAMIXB

If aOpc[1] == 3		

	aadd(aInfo , "O TES abaixo acaba de ser incluido no sistema pelo usuário: "+Substr(cUsuario,7,15) )
	aadd(aInfo , " " )
	aadd(aInfo , "Código: "+M->F4_CODIGO )
	aadd(aInfo , "Texto Padrão: "+M->F4_TEXTO )
	aadd(aInfo , "Finalidade: "+M->F4_FINALID )

ElseIf aOpc[1] == 4

	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4")+M->F4_CODIGO)

	For j:=1 to FCount()
		If FieldGet(FieldPos(FieldName(j))) <>  &("M->"+(FieldName(j)))
			If Len(aInfo) == 0
				aadd(aInfo , "Os seguintes campos foram alterados no cadastro de TES: " +M->F4_CODIGO )
				aadd(aInfo , "pelo usuário: "+Substr(cUsuario,7,15) )
				aadd(aInfo , " " )
			Endif
			If ValType(FieldGet(FieldPos(FieldName(j)))) == "N"
				cOld := Str(FieldGet(FieldPos(FieldName(j))))
				cNew := Str(&("M->"+(FieldName(j))))
			Elseif ValType(FieldGet(FieldPos(FieldName(j)))) == "D"
				cOld := DtoC(FieldGet(FieldPos(FieldName(j))))
				cNew := DtoC(&("M->"+(FieldName(j))))
			Elseif ValType(FieldGet(FieldPos(FieldName(j)))) == "C"
				cOld := FieldGet(FieldPos(FieldName(j)))
				cNew := &("M->"+(FieldName(j)))
			Else
				cOld := ""
				cNew := ""
			Endif
			aadd(aInfo , FieldName(j) )
			aadd(aInfo , "Conteúdo Anterior: "+cOld )
			aadd(aInfo , "Novo Conteúdo : "+cNew )
		Endif		
	Next

Else 

	aadd(aInfo , "O TES abaixo acaba de ser excluido no sistema pelo usuário: "+Substr(cUsuario,7,15) )
	aadd(aInfo , " " )
	aadd(aInfo , "Código: "+SF4->F4_CODIGO )
	aadd(aInfo , "Texto Padrão: "+SF4->F4_TEXTO )
	aadd(aInfo , "Finalidade: "+SF4->F4_FINALID )

Endif

aadd(aInfo , " ")
MEnviaMail("Z09",aInfo)

Return(lRetorno)	
