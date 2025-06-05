#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} ManSx5
Manuten็ใo das tabelas gen้ricas pelos usuแrios, fora do configurador.
@author Marcelo Colato
@since 04/01/2018
/*/
User Function ManSx5(_cTabela, _lPerSel, _lPerMan, _lPosiciona)

Local _lRet			:= .t.
Local _aBkpHead	:= {}
Local _aBkpCols	:= {}
Local _nBkpN		:= nil
Local _cTitulo		:= "Tabela Gen้rica"
Local _aBkpRot		:= {}

Private oSelec,oSalvar

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Somente usuario com as permiss๕es Alterar TES (15) e Excluir TES (16),    ณ
//ณ ้ que poderao usar esta op็ใo										      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (VerSenha(15) .and. VerSenha(16))

	If _cTabela == nil
		_cTabela    := "Z6"
	Endif
	IF _lPerSel == nil
		_lPerSel := .T. 	// .F.
	ENDIF
	IF _lPerMan == nil
		_lPerMan := .T.	// .F.
	ENDIF
	IF _lPosiciona == nil
		_lPosiciona := .F.
	ENDIF

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se jแ existem as variแveis utilizadas por alguma ณ
	//ณ rotina anterior. Se existir, efetua um backup.            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF Type("aCols")=="A"
		_aBkpCols := Aclone(aCols)
	ENDIF
	IF Type("aHeader")=="A"
		_aBkpHead := Aclone(aHeader)
	ENDIF
	IF Type("n")=="N"
		_nBkpN := n
		n := 1
	ENDIF
	IF Type("aRotina")=="A"
		_aBkprot := Aclone(aRotina)
	ENDIF

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa as variแveis para a estrutura do MsGetDados. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCols		:= {}
	aHeader	:= {}
	aRotina	:= {{"Alterar", "AxAltera", , 4}}

	Aadd(aHeader, {"C๓digo"		, "X5_CHAVE"	, "@!", 006, 0, "NaoVazio().AND.U_VlMnSx5(1)",,"C",,})
	Aadd(aHeader, {"Descri็ใo"	, "X5_DESCRI"	, "@!", 055, 0, "NaoVazio().AND.U_VlMnSx5(2)",,"C",,})

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Pega o tํtulo das tabelas do arquivo SX5 e depois alimenta ณ
	//ณ as linhas do aCols com os dados da tabela selecionada.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SX5")
	DbsetOrder(1)
	IF DbSeek(xFilial("SX5") + "00" + _cTabela, .f.)
		_cTitulo := Alltrim(SX5->X5_DESCRI)
	ENDIF
	DbSeek(xFilial("SX5") + _cTabela, .f.)

	WHILE !Eof() .AND. xFilial("SX5") + _cTabela == SX5->(X5_FILIAL + X5_TABELA)
		Aadd(aCols, {SX5->X5_CHAVE, SX5->X5_DESCRI, .F.})
		DbSkip()
	ENDDO

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Exibe a tela de dados e armazena o retorno para a rotina chamadora. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_lRet := fMosTel(_cTitulo, _lPerSel, _lPerMan, _cTabela,_lPosiciona)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Retorna a posi็ใo das variแveis da MsGetDados, ณ
	//ณ caso as mesmas tenham sido reiniciadas.        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF Len(_aBkpCols)>0
		aCols := Aclone(_aBkpCols)
	ENDIF
	IF Len(_aBkpHead)>0
		aHeader := Aclone(_aBkpHead)
	ENDIF
	IF _nBkpN <> nil
		n := _nBkpN
	ENDIF
	IF Len(_aBkpRot)>0
		aRotina := Aclone(_aBkpRot)
	ENDIF

Else

	Help(" ",1,"SEMPERM")

EndIf

RETURN(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMosTel   บAutor  ณMarcelo Colato      บ Data ณ  05/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina auxliar para exibir os dados da tabela selecionada. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION fMosTel(_cTitulo, _lPerSel, _lPerMan, _cTabela, _lPosiciona)
Local oDlg,oGrp1,oGetDados,oCancela
Local _lRet			:= _lPerSel
Local _lFechar		:= .f.
Local _aCampos		:= Iif(_lPerMan, {"X5_CHAVE", "X5_DESCRI"}, {})
Local _nPosChv		:= Ascan(aHeader, {|x| Alltrim(x[2])=="X5_CHAVE"})
Local _nLim			:= Iif(_lPerMan, 999999, Len(aCols))
Local _bCancela	:= {|| _lFechar := .t., _lRet := .f., Close(oDlg)}
Local _bSelec		:= {|| Iif(aCols[n, Len(aHeader)+1], IW_MsgBox("Item apagado!","Aten็ใo!","STOP"), ;
								Eval({|| SX5->(DbSeek(xFilial("SX5") + _cTabela + aCols[n, _nPosChv]), .f.), _lRet := .t.,;
								_lFechar := .t., Close(oDlg)}) ) }
Local _bSalvar		:= {|| fSalvar(_cTabela), Iif(_lPerSel, oSelec:Enable(), oSelec:Disable()), oSalvar:Disable(),;
								oSelec:Refresh(), oSalvar:Refresh()}
Local _cPosiciona	:= ""
Local _nPos			:= 0
Local _cIndex		:= "Codigo"
Local _aIndice		:= {"Codigo","Descricao"}
Local _nOrdem		:= 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se for posicionar em algum item, seleciona o valor com base    ณ
//ณ no campo da consulta padrใo para localizar este dado no acols. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF _lPosiciona .AND. !Empty(Alltrim(ReadVar()))
	_cPosiciona := &(ReadVar())
ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a tela de dados posicionando no registro correto. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := _cTitulo
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 551
oDlg:nHeight := 369
oDlg:lShowHint := .F.
oDlg:lCentered := .T.
oDlg:bInit := {|| oGetDados:GoTo(_nPos), oGetDados:Refresh()}

oGrp1 := TGROUP():Create(oDlg)
oGrp1:cName := "oGrp1"
oGrp1:nLeft := 13
oGrp1:nTop := 8
oGrp1:nWidth := 518
oGrp1:nHeight := 265
oGrp1:lShowHint := .F.
oGrp1:lReadOnly := .F.
oGrp1:Align := 0
oGrp1:lVisibleControl := .T.

@ 145, 115 BUTTON "_Gravar"		SIZE 50,13 ACTION Eval(_bSalvar) OBJECT oSalvar
@ 145, 165 BUTTON "_Selecionar"	SIZE 50,13 ACTION Eval(_bSelec) OBJECT oSelec
@ 145, 215 BUTTON "_Cancelar"   SIZE 50,13 ACTION Eval(_bCancela) OBJECT oCancela

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a estrutura do combo para selecionar a ordem de exibi็ใo.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
@ 148, 015 SAY "Ordenar por:"
@ 11.3, 007 COPACOMBO oCmbIdx VAR _cIndex ;
		ITEMS _aIndice ;
		SIZE 045, 015 ;
		OF oDlg ;
		ON CHANGE Eval({|| _cPosiciona := aCols[n, 1], _nOrdem := Ascan(_aIndice, _cIndex), ;
			Asort(aCols,,, {|x,y| x[_nOrdem]<y[_nOrdem]}), _nPos := Ascan(aCols, {|x| x[_nPosChv]==_cPosiciona}),;
			oGetDados:GoTo(_nPos), oGetDados:Refresh()})
*/

oSalvar:Disable()
IF !_lPerSel
	oSelec:Disable()
ENDIF

//oGetDados := MsGetDados():New(007, 008, 135, 264, 1, "U_fManSx5Val(1)", "U_fManSx5Val(2)", "", _lPerMan, ;
//					_aCampos, , .F., _nLim, "U_LNOK","U_LNOK",,Iif(_lPerman, "U_VlMnSx5(3)", "AlwaysFalse"), oDlg)
oGetDados := MsGetDados():New(007, 008, 135, 264, 1, "U_fManSx5Val(1)", "U_fManSx5Val(2)", "", _lPerMan, ;
					_aCampos, , .F., _nLim, , , ,Iif(_lPerman, "U_VlMnSx5(3)", "AlwaysFalse"), oDlg)

IF !Empty(Alltrim(_cPosiciona))
	IF (_nPos := Ascan(aCols, {|x| x[_nPosChv]==_cPosiciona}))<=0
		_nPos := n
	ENDIF
ENDIF

ACTIVATE DIALOG oDlg CENTERED VALID _lFechar

RETURN(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfManSx5ValบAutor  ณMarcelo Colato      บ Data ณ  05/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina auxiliar para validar a mudan็a de linha no acols.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION fManSx5Val(_nTipo)
Local _nLimite	:= Iif(_nTipo==1, n, Len(aCols))
Local _nInicio	:= Iif(_nTipo==1, n, 1)
Local _n			:= 0
Local _lRet		:= .t.
Local _x			:= 0
Local _nPosChv	:= Ascan(aHeader, {|x| Alltrim(x[2])=="X5_CHAVE"})
Local _nPosDsc	:= Ascan(aHeader, {|x| Alltrim(x[2])=="X5_DESCRI"})

FOR _n:=_nInicio TO _nLimite
	IF !aCols[_n, Len(aHeader)+1] .AND. Empty(Alltrim(aCols[_n, _nPosChv]))
		IW_MsgBox("O campo C๓digo nใo pode estar vazio!" , "Aten็ใo!" , "ALERT")
		_lRet := .f.
	ENDIF
	IF !aCols[_n, Len(aHeader)+1] .AND. Empty(Alltrim(aCols[_n, _nPosDsc]))
		IW_MsgBox("O campo Descri็ใo nใo pode estar vazio!", "Aten็ใo!" , "ALERT")
		_lRet := .f.
	ENDIF

	IF !_lRet
		EXIT
	ENDIF
NEXT

RETURN(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fSalvar  บAutor  ณMarcelo Colato      บ Data ณ  05/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina auxiliar para salvar os dados alterados.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION fSalvar(_cTabela)
Local _n	:= 0

DbSelectArea("SX5")

FOR _n:=1 TO Len(aCols)
	IF DbSeek(xFilial("SX5") + _cTabela + aCols[_n,1], .f.) .AND. aCols[_n, 3]
		RecLock("SX5", .F.)
			DbDelete()
		MsUnlock()
	ELSEIF !aCols[_n, 3]
		RecLock("SX5", !Found())
			SX5->X5_FILIAL		:= xFilial("SX5")
			SX5->X5_TABELA		:= _cTabela
			SX5->X5_CHAVE		:= aCols[_n, 1]
			SX5->X5_DESCRI		:= aCols[_n, 2]
			SX5->X5_DESCSPA	:= aCols[_n, 2]
			SX5->X5_DESCENG	:= aCols[_n, 2]
		MsUnlock()
	ENDIF
NEXT
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVlMnSx5   บAutor  ณMarcelo Colato      บ Data ณ  05/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina auxiliar para validar o preechimento dos campos e a บฑฑ
ฑฑบ          ณ dele็ใo de uma linha.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION VlMnSx5(_nTipo)
Local _lRet 	:= .T.
Local _n			:= 0
Local _cCont	:= &(ReadVar())

IF _cCont#aCols[n, _nTipo] .OR. _nTipo==3
	IF _nTipo==1
		FOR _n:=1 TO Len(aCols)
			IF _n#n .AND. aCols[_n, _nTipo]==_cCont
				_lRet := .f.
				IW_MsgBox("Conte๚do duplicado na tabela!", "Aten็ใo!" , "STOP")
				EXIT
			ENDIF
		NEXT
	ENDIF

	IF _lRet
		oSalvar:Enable()
		oSelec:Disable()
		oSelec:Refresh()
		oSalvar:Refresh()
	ENDIF
ENDIF
RETURN(_lRet)