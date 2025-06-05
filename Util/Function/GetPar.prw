#include "totvs.ch"
/*/{protheus.doc} GetPar
Verifica a existência de um parâmetro e o retorna, caso contrário, cria.
@author Sergio Braz
@since 24/08/16
/*/
User Function GetPar(cPar,cValor,cTipo,cDescri,cFil)
	Local cSX6  := "SX6"
	Local nLen      := Len(&("SX6->X6_DESCRIC"))
	Local cInsert
	Default cTipo   := "C"
	Default cDescri := "Parâmetro personalizado"
	Default cFil    := xFilial(cSX6)
	If RetField(cSX6,1,cFil+cPar,"Eof()")
		cInsert := "Insert into SX6"+cEmpAnt+"0 "
		cInsert += "(X6_FIL,X6_VAR,X6_TIPO,X6_DESCRIC,X6_DSCSPA,X6_DSCENG,X6_DESC1,X6_DSCSPA1,X6_DSCENG1,X6_DESC2,X6_DSCSPA2,"
		cInsert += "X6_DSCENG2,X6_CONTEUD,X6_CONTSPA,X6_CONTENG,X6_PROPRI,X6_PYME) "
		cInsert += "Values "
		cInsert += "('"+cFil+"','"+cPar+"','"+cTipo+"','"
		cInsert += MemoLine(cDescri,nLen,1)+"','"+MemoLine(cDescri,nLen,1)+"','"+MemoLine(cDescri,nLen,1)+"','"
		cInsert += MemoLine(cDescri,nLen,2)+"','"+MemoLine(cDescri,nLen,2)+"','"+MemoLine(cDescri,nLen,2)+"','"
		cInsert += MemoLine(cDescri,nLen,3)+"','"+MemoLine(cDescri,nLen,3)+"','"+MemoLine(cDescri,nLen,3)+"','"
		cInsert += cValor+"','"+cValor+"','"+cValor+"','U','S')"
		XX:=TcSqlExec(cInsert)
		conout(xx)
		conout(tcsqlerror())
	Else
		cTipo  := (cSX6)->&("X6_TIPO")
		cValor := (cSX6)->&("X6_CONTEUD")
	Endif
	If cTipo=="D"
		cValor := ctod(cValor)
	ElseIf cTipo=="N"
		cValor := Val(cValor)
	ElseIf cTipo=="L"
		cValor := &(cValor)
	Endif
Return cValor

User Function PutPar(cPar,xValor,cFil)
	Local cSX6   := "SX6"
	Local nLFil  := Len(xFilial(cSX6))
	Default cFil := xFilial(cSX6)
	cFil := Left(cFil,nLFil)
	If Posicione(cSX6,1,cFil+cPar,"!Eof()")
		RecLock(cSX6,.f.)
		(cSX6)->&("X6_CONTEUD := X6_CONTSPA	:= X6_CONTENG ") := xValor
		(cSX6)->(MsUnlock())
	Endif
Return