#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} ManSx5
Manuten��o das tabelas gen�ricas pelos usu�rios, fora do configurador.
@author Marcelo Colato
@since 04/01/2018
/*/
User Function ManSx5(_cTabela, _lPerSel, _lPerMan, _lPosiciona)

Local _lRet			:= .t.
Local _aBkpHead	:= {}
Local _aBkpCols	:= {}
Local _nBkpN		:= nil
Local _cTitulo		:= "Tabela Gen�rica"
Local _aBkpRot		:= {}

Private oSelec,oSalvar

//���������������������������������������������������������������������������Ŀ
//� Somente usuario com as permiss�es Alterar TES (15) e Excluir TES (16),    �
//� � que poderao usar esta op��o										      �
//�����������������������������������������������������������������������������
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

	//�����������������������������������������������������������Ŀ
	//� Verifica se j� existem as vari�veis utilizadas por alguma �
	//� rotina anterior. Se existir, efetua um backup.            �
	//�������������������������������������������������������������
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

	//���������������������������������������������������������Ŀ
	//� Inicializa as vari�veis para a estrutura do MsGetDados. �
	//�����������������������������������������������������������
	aCols		:= {}
	aHeader	:= {}
	aRotina	:= {{"Alterar", "AxAltera", , 4}}

	Aadd(aHeader, {"C�digo"		, "X5_CHAVE"	, "@!", 006, 0, "NaoVazio().AND.U_VlMnSx5(1)",,"C",,})
	Aadd(aHeader, {"Descri��o"	, "X5_DESCRI"	, "@!", 055, 0, "NaoVazio().AND.U_VlMnSx5(2)",,"C",,})

	//������������������������������������������������������������Ŀ
	//� Pega o t�tulo das tabelas do arquivo SX5 e depois alimenta �
	//� as linhas do aCols com os dados da tabela selecionada.     �
	//��������������������������������������������������������������
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

	//���������������������������������������������������������������������Ŀ
	//� Exibe a tela de dados e armazena o retorno para a rotina chamadora. �
	//�����������������������������������������������������������������������
	_lRet := fMosTel(_cTitulo, _lPerSel, _lPerMan, _cTabela,_lPosiciona)

	//������������������������������������������������Ŀ
	//� Retorna a posi��o das vari�veis da MsGetDados, �
	//� caso as mesmas tenham sido reiniciadas.        �
	//��������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fMosTel   �Autor  �Marcelo Colato      � Data �  05/01/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina auxliar para exibir os dados da tabela selecionada. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC FUNCTION fMosTel(_cTitulo, _lPerSel, _lPerMan, _cTabela, _lPosiciona)
Local oDlg,oGrp1,oGetDados,oCancela
Local _lRet			:= _lPerSel
Local _lFechar		:= .f.
Local _aCampos		:= Iif(_lPerMan, {"X5_CHAVE", "X5_DESCRI"}, {})
Local _nPosChv		:= Ascan(aHeader, {|x| Alltrim(x[2])=="X5_CHAVE"})
Local _nLim			:= Iif(_lPerMan, 999999, Len(aCols))
Local _bCancela	:= {|| _lFechar := .t., _lRet := .f., Close(oDlg)}
Local _bSelec		:= {|| Iif(aCols[n, Len(aHeader)+1], IW_MsgBox("Item apagado!","Aten��o!","STOP"), ;
								Eval({|| SX5->(DbSeek(xFilial("SX5") + _cTabela + aCols[n, _nPosChv]), .f.), _lRet := .t.,;
								_lFechar := .t., Close(oDlg)}) ) }
Local _bSalvar		:= {|| fSalvar(_cTabela), Iif(_lPerSel, oSelec:Enable(), oSelec:Disable()), oSalvar:Disable(),;
								oSelec:Refresh(), oSalvar:Refresh()}
Local _cPosiciona	:= ""
Local _nPos			:= 0
Local _cIndex		:= "Codigo"
Local _aIndice		:= {"Codigo","Descricao"}
Local _nOrdem		:= 1

//������������������������������������������������������������������
//� Se for posicionar em algum item, seleciona o valor com base    �
//� no campo da consulta padr�o para localizar este dado no acols. �
//������������������������������������������������������������������
IF _lPosiciona .AND. !Empty(Alltrim(ReadVar()))
	_cPosiciona := &(ReadVar())
ENDIF

//���������������������������������������������������������Ŀ
//� Monta a tela de dados posicionando no registro correto. �
//�����������������������������������������������������������
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

//����������������������������������������������������������������Ŀ
//� Monta a estrutura do combo para selecionar a ordem de exibi��o.�
//������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fManSx5Val�Autor  �Marcelo Colato      � Data �  05/01/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina auxiliar para validar a mudan�a de linha no acols.  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		IW_MsgBox("O campo C�digo n�o pode estar vazio!" , "Aten��o!" , "ALERT")
		_lRet := .f.
	ENDIF
	IF !aCols[_n, Len(aHeader)+1] .AND. Empty(Alltrim(aCols[_n, _nPosDsc]))
		IW_MsgBox("O campo Descri��o n�o pode estar vazio!", "Aten��o!" , "ALERT")
		_lRet := .f.
	ENDIF

	IF !_lRet
		EXIT
	ENDIF
NEXT

RETURN(_lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fSalvar  �Autor  �Marcelo Colato      � Data �  05/01/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina auxiliar para salvar os dados alterados.            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VlMnSx5   �Autor  �Marcelo Colato      � Data �  05/01/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina auxiliar para validar o preechimento dos campos e a ���
���          � dele��o de uma linha.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
				IW_MsgBox("Conte�do duplicado na tabela!", "Aten��o!" , "STOP")
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