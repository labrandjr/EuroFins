#include "Protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{protheus.doc}BKPATF  
Este programa gera backup dos arquivos do Ativo.           
Chamada atraves do menu miscelanea.                        
@Author DONIZETE
@since 12/01/05 
@Obs
±±³ Alterado ³ Data    ³ Motivo                                           ³±±
±±³ Diogo M. ³ 05/03/10³ Adaptado rotina para fazer backup de todos os re ³±±
±±³          ³         ³ gistros das tabelas, independente se o mesmo est ³±±
±±³          ³         ³ a deletado ou nao; Implementado opcao restore.   ³±±
/*/
User Function BKPATF()
	Local cTabSN1		:= ""
	Local lEnd			:= .F.
	Local aOpcoes		:= If(Upper(AllTrim(cUserName)) $ Upper('Administrador,Totvs'),{"Backup","Restore"},{"Backup"})

	Private aParamBox	:= {}
	Private _cNomArq		:= ""
	Private _cArqDest1	:= ""
	Private _cData		:= "_" + DTOS(ddatabase)
	Private _aEmpresa	:= {}
	Private _cPathDest	:= "\BkpAtivo\"
	Private _lYesNo		:= .F.
	Private _lExistArq	:= .F.
	Private _lOk			:= .F.
	Private _cEmpFil		:= SM0->M0_CODIGO+"/"+SM0->M0_NOME

	aAdd(aParamBox,{3,"Opções",1,aOpcoes,50,"",.T.})
	If ParamBox(aParamBox,"Parametros",,,,.T.,,,,"BKPATF",.T.,.T.)
		If MV_PAR01 == 1
			_lYesNo := MsgBox("Confirma backup do ativo da empresa "+_cEmpFil+"?","Backup","YESNO")
			If _lYesNo	== .F.
				Return
			EndIf

			// Executa o processo principal.
			Processa( {|| RunBkp() },"Aguarde. Gerando backup dos arquivos ..." )
		Else
			_lYesNo := MsgBox("Confirma restore do ativo da empresa "+_cEmpFil+"?","Restore","YESNO")
			If _lYesNo	== .F.
				Return
			EndIf

			cTabSN1 := cGetFile('Arquivo SN1 (sn1*.DTC) | sn1*.DTC','Selecione o arquivo SN1',0,'SERVIDOR\BKPAtivo\',.T.,GETF_NOCHANGEDIR,.T.)
			If !Empty(cTabSN1)
				Private oProcess := Nil

				oProcess := MsNewProcess():New( { |lEnd| RunRestore(@lEnd,cTabSN1) } , "Aguarde o processamento" , "" , .T.)
				oProcess:Activate()
			EndIf
		EndIf
	EndIf

Return

//³ FUNCAO PRINCIPAL                                                    ³
Static Function RunBkp()
	// Inicializa empresas a serem processadas.
	Local nI := 0
	aadd(_aEmpresa,SM0->M0_CODIGO)

	// Define o número de arquivos a serem processados.
	ProcRegua(15)

	// Processa o backup.
	For nI=1 to len(_aEmpresa)

		//.. Backup das tabelas do Ativo Fixo ..//
		Backup("SN1", nI)
		If _lOk
			Backup("SN2", nI)
			Backup("SN3", nI)
			Backup("SN4", nI)
			Backup("SN5", nI)
			Backup("SN6", nI)
			Backup("SN7", nI)
			Backup("SN8", nI)
			Backup("SN9", nI)
			Backup("SNA", nI)
			Backup("SNB", nI)
			Backup("SNC", nI)
			Backup("SND", nI)
			Backup("SNE", nI)
			Backup("SNG", nI)
			Backup("SNH", nI)
			Backup("SNI", nI)
			Backup("SNJ", nI)
			Backup("SNQ", nI)
			Backup("SNR", nI)
			Backup("SNS", nI)
			Backup("SNT", nI)
			Backup("SNG", nI)
			//Backup("SNZ", nI)
			Backup("SNK", nI)
			Backup("SNN", nI)
			Backup("SNM", nI)
			Backup("SNG", nI)
			Backup("SNL", nI)
			Backup("SNV", nI)
			Backup("SNW", nI)
			Backup("SNX", nI)
			Backup("SNY", nI)
			Backup("SNO", nI)
			Backup("SNP", nI)
			Backup("FNG", nI)

			MsgBox("Backup concluido. Arquivos gravados na raiz do server em "+_cPathDest+".")

		EndIf

	Next

Return

//³ FUNCAO DE BACKUP                                                    ³
Static Function Backup(_cTabela, nI)
	Local cQuery := ""
	Local aAreaSX3 := {}
	// Incrementa a régua.
	IncProc("Processando tabela " + _cTabela)

	// Verifica se o diretório de backup existe.
	_cPathDest := Alltrim(_cPathDest)
	If !File(Left(_cPathDest,Len(_cPathDest)-1))
		Alert("A Pasta [ " + _cPathDest + " ] não existe no servidor. Procure o administrador e peça para criá-la.")
		Return
	EndIf

	// Carrega o alias. Necessário para que o SIGA crie a tabela caso não exista.
	dbSelectArea(_cTabela)

	// Faz o backup.
	_cNomArq	:=_cTabela-_aEmpresa[nI]-"0"
	_cArqDest1	:=_cPathDest+_cNomArq+_cData+".DTC"

	// Verifica se já existe arquivo.
	If File(_cArqDest1)
		_lExistArq := .T.
	EndIf

	_lYesNo := .T.
	If _lExistArq .And. !_lOk
		_lYesNo := MsgBox("Backup efetuado anteriormente. Sobrepor?","Sobrescrever?","YESNO")
	EndIf

	If !_lYesNo
		_lOk := .F.
	Else
		_lOk := .T.
	EndIf

	If !_lExistArq .Or. _lOk
		/* Faz backup de todos os registros independente se o mesmo estiver deletado
		cQuery := " SELECT * FROM " + RetSqlName(_cTabela)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cNomArq,.T.,.F.)

		aAreaSX3 := SX3->(GetArea())
		SX3->(DbSelectArea("SX3"))
		SX3->(DbSetOrder(1))
		If SX3->(DbSeek(_cTabela))
			Do While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == _cTabela
				If SX3->X3_TIPO == "N"
					TcSetField(_cNomArq, SX3->X3_CAMPO, SX3->X3_TIPO, TamSx3(SX3->X3_CAMPO)[1], TamSx3(SX3->X3_CAMPO)[2])
				EndIf
				SX3->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaSX3)

		DbSelectArea(_cNomArq)
		*/
		Use &_cNomArq Alias _cNomArq SHARED NEW VIA "TOPCONN"
		copy to &_cArqDest1 VIA "CTREECDX"
		DbCloseArea(_cNomArq)
	Else
		Alert("Backup não efetuado!")
	EndIf

Return


/*/
±±³Fun‡ao    ³ RunRestore³ Autor ³ Diogo Mesquita       ³ Data ³ 11/03/10 ³±±
±±³Descri‡ao ³ Funcao responsavel por processar o restore dos arquivos.   ³±±
±±³Sintaxe   ³ RunRestore(< lPar01, cPar02 >)                             ³±±
±±³Parametros³ lPar01: Controle de processamento;                         ³±±
±±³          ³ cPar02: Arquivo SN1 (DTC) selecionado.                     ³±±
±±³Retorno   ³ lReturn                                                    ³±±
±±³Uso       ³ SIGAATF                                                    ³±±
±±³ Analista ³ Data    ³ Motivo                                           ³±±
/*/
Static Function RunRestore(lEnd,cArquivo)
	Local lReturn 		:= .T.
	Local aTabelas		:= {'SN1','SN2','SN3','SN4','SN5','SN6','SN7','SN8','SN9','SNA','SNB','SNC','SND','SNE','SNG'}
	Local nI := nY		:= 0
	Local cAux			:= ""
	Local cMsg			:= ""
	Local lOK			:= .T.
	Local cTabela		:= ""
	Local cAlias		:= ""
	Local aEstrutura	:= {}
	Local nQtdReg		:= 0
	Local nReg			:= 0
	Local aAux			:= {}

	For nI := Len(cArquivo) to 1 Step -1
		If SubStr(cArquivo,nI,1) == '\'
			Exit
		EndIf
		cAux := Substr(cArquivo,nI,1) + cAux
	Next nI
	cAux := SubStr(cAux,4,16)

	For nI := 1 to Len(aTabelas)
		If !File("\BKPAtivo\"+aTabelas[nI]+cAux)
			cMsg += aTabelas[nI] + " "
		Else
			aAdd(aAux,aTabelas[nI])
		EndIf
	Next nI

	If !Empty(cMsg)
		cMsg := "Arquivo da(s) tabela(s): " + cMsg + " não encontrado(s). Deseja realmente continuar ?"
		If !MsgYesNo(cMsg,"ATENÇÃO")
			lOK := .F.
		EndIf
	EndIf

	If lOK
		oProcess:SetRegua1(Len(aAux))
		For nI := 1 to Len(aAux)
			oProcess:IncRegua1("Lendo tabela " + aAux[nI] + "...")
			cTabela := RetSqlName(aAux[nI])
			DbUseArea(.T.,"TOPCONN",cTabela,"TMP",.F.,.F.)
			if Select("TMP") <= 0
				MSGSTOP("Nao foi possível abrir a tabela " + cTabela + " em modo EXCLUSIVO. O processo será abortado.","ERRO")
				Return .F.
			endif
			DbSelectArea("TMP")
			If TMP->(NetErr())
				MSGSTOP("Nao foi possível abrir a tabela " + cTabela + " em modo EXCLUSIVO. O processo será abortado.","ERRO")
				Return .F.
			Else
				MsAguarde({|lEnd| fLimpaTabela(cTabela)},"Aguarde o processamento","Excluindo registros atuais da tabela " + cTabela + "...",.T.)
			EndIf
			TMP->(DbCloseArea())

			DbUseArea(.T.,"CTREECDX","\BKPAtivo\"+aAux[nI]+cAux,"TMP",.F.,.F.)
			TMP->(DbSelectArea("TMP"))
			Count to nQtdReg
			TMP->(DbGoTop())
			oProcess:SetRegua2(nQtdReg)

			cAlias := aAux[nI]
			&(cAlias)->(DbSelectArea(cAlias))
			aEstrutura := &(cAlias)->(DbStruct())
			Do While TMP->(!Eof())
				oProcess:IncRegua2("Restaurando registro " + StrZero(++nReg,8) + " de " + StrZero(nQtdReg,8))

				&(cAlias)->(RecLock(cAlias,.T.))
				For nY := 1 to Len(aEstrutura)
					If TMP->(FieldPos(aEstrutura[nY,1])) > 0
						&(cAlias)->(FieldPut(&(cAlias)->(FieldPos(aEstrutura[nY,1])),TMP->(FieldGet(TMP->(FieldPos(aEstrutura[nY,1]))))))
					EndIf
				Next nY
				&(cAlias)->(MsUnLock())

				TMP->(DbSkip())
			EndDo
			TMP->(DbCloseArea())
			nReg := 0
		Next nI

		MSGINFO("Processamento finalizado.","INFORMAÇÃO")
	Else
		MSGSTOP("Processamento abortado.", "ERRO")
	EndIf
Return (lReturn)

/*/
±±³Funcao    ³ fLimpaTabela³ Autor ³ Diogo Mesquita     ³ Data ³ 12/03/10 ³±±
±±³Descricao ³ Funcao responsavel por limpar a tabela em processamento.   ³±±
±±³Sintaxe   ³ fLimpaTabela(< cPar01 >)                                   ³±±
±±³Parametros³ cPar01: Tabela em processamento.                           ³±±
±±³Retorno   ³ Nil                                                        ³±±
±±³Uso       ³ SIGAATF                                                    ³±±
±±³ Analista ³ Data    ³ Motivo                                           ³±±
/*/
Static Function fLimpaTabela(cTabela)

	TMP->(DbSelectArea("TMP"))
	ZAP

Return Nil


/*user function tstbkp
rpcsetenv("01","0101")
dbselectarea("SA1")
COPY TO \BACKUPSA1.DTC VIA "CTREECDX"  
CPYS2T("\BACKUPSA1.DTC","D:\")
FERASE("\BACKUPSA1.DTC")
return*/