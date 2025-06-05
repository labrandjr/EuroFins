#include 'protheus.ch'
#include 'parmtype.ch'
#include "RWMAKE.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} exclProd
Módulo: TODOS
Tipo: Rotina
Finalidade: Função que replica a exclusão do produto que acabou de ser excluído.

@author Augusto Krejci Bem-Haja
@since 23/10/2017
@version undefined

@type function
/*/
user function exclProd ()
	local aFilExc := getFiliais()
	local lRet := .F.


	private lMsErroAuto := .F.

	beginTran()
	for i:=1 to len(aFilExc)
		IncProc("Excluindo produto na filial " + aFilExc[i] + "...")
		excluiProduto(aFilExc[i])
		if lMsErroAuto
			exit
		endif
	next

	if lMsErroAuto
		alert("Não foi possível efetuar a exclusão.")
		disarmTransaction()
	else
		lRet := .T.
		msgAlert("Exclusão efetuada com sucesso em todas as filiais.","Aviso")
		endTran()
	endif
return lRet

static function getFiliais()
	local aFiliais := FWLoadSM0()
	local aFilSel := {}

	for i := 1 to len(aFiliais)
		if !(subStr(aFiliais[i][2],1,1) $ 'CG')
			if (cFilAnt <> aFiliais[i][2])
				aAdd(aFilSel,aFiliais[i][2])
			endif
		endif
	next
return aFilSel

static function excluiProduto(cFilExc)
	local cEmpOrig  := cEmpAnt
	local cFilOrig	:= cFilAnt
	local aVetor := {}
	local cEmpExc := cEmpAnt

	setaFilial(cEmpExc,cFilExc)

	aVetor:= {{"B1_COD"         ,M->B1_COD 	    ,NIL}}
	MSExecAuto({|x,y| Mata010(x,y)},aVetor,5)

	If lMsErroAuto
		MostraErro()
	Endif

	setaFilial(cEmpOrig, cFilOrig)

return

static function setaFilial(cEmp,cFil)
	cEmpAnt := cEmp
	cFilAnt := cFil
return