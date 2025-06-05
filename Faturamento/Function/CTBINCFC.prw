#INCLUDE "protheus.ch"
#INCLUDE "FWMVCDEF.CH"

Static __oModelAut := NIL //variavel oModel para substituir msexecauto em MVC

/*/{protheus.doc}CTBINCFC
Programa para carga de clientes e fornecedores no plano de contas.                                                    
Chamado pelos pontos de entrada M020INC/M030INC/Outros.   
@Author J.DONIZETE R.SILVA 
@since  14/02/08    
@Parameters : '1' = Clientes, '2' = Fornecedores
@Obs em 28/11/2011 Alterada a forma de obtenção do tipo do fornecedor(_cTipo)  
/*/

User Function CTBINCFC(_cCad,cOpcao)
	Local aArea:= GetArea()
	Local _xAreaCF 	:= Iif(_cCad=="1",SA1->(GetArea()),SA2->(GetArea()))
	Local _xAreaCT1		:= {}
	Local _xAreaSM0		:= {}
	Local _xAreaSX2 	:= {}
	Local _cNome		:= Iif(_cCad=="1",SA1->A1_NOME,SA2->A2_NOME)
	Local _cCod			:= Iif(_cCad=="1",SA1->A1_COD,SA2->A2_COD)
	Local _cEst			:= Iif(_cCad=="1",SA1->A1_EST,SA2->A2_EST)
	Local _cConta		:= ""
	Local _cCtaSint		:= ""
	Local _aCad		  	:= {}
	Local _lCria		:= .f. // Esta variável define se será criado ou não conta analítica. A alteração da mesma
	Local lMsErroAuto   := .F.
	Local lMsHelpAuto   := .T.
	Local _cAlias		:= Iif(_cCad=="1","SA1","SA2")
	Local _cNtSped		:= Iif(_cCad=="1","01","02")
	Local _cCodPla		:= "M02"
	Local _cContaG		:= ""
	Local _cModoSA1SA2 	:= ""
	Local _cModoCT1 	:= ""
	Local _cFilial		:= ""
	Local _cEmpAnt		:= cEmpAnt // Guardar a empresa atual
	Local _cFilAnt		:= cFilAnt // Guardar a filial atual
	Local _lCriaEmp		:= .f.
	Local _lSA1SA2C		:= .f.
	Local _lProc		:= .t.
	Private aRotina 	:= &('staticcall(CTBA020,MENUDEF)')
	// Não processa se não houver parâmetros.
	If !_cCad $ "1,2"
		Return(.f.)
	EndIf
	// Processa somente se o módulo for SIGACTB e a opção for de Inclusão.
	If Upper(Alltrim(GetMv("MV_MCONTAB"))) == "CTB"
		dbSelectArea(_cAlias)
		// Este escopo deve ser atualizado com as regras definidas pelo Contador.
		if _cCad == "1"
			if Empty(SA1->A1_CONTA)
				if SA1->A1_ZZCOLIG == "S" .and. SA1->A1_TIPO <> "X"
					cContaR	:= "11201"
					cSeq	:= fBuscaSeq(cContaR)
					_cConta	:= cSeq
					_cContaG:= "41090"
					_lCria	:= .t.
				elseif SA1->A1_ZZCOLIG == "S" .and. SA1->A1_TIPO == "X"
					cContaR	:= "11202"
					cSeq	:= fBuscaSeq(cContaR)
					_cConta	:= cSeq
					_cContaG:= "41090"
					_lCria	:= .t.
				elseif SA1->A1_ZZCOLIG == "N" .and. SA1->A1_TIPO <> "X"
					_cConta	:= "11203001"+Alltrim(SA1->A1_COD)+Alltrim(SA1->A1_LOJA)
					_cContaG:= "41000"
					_lCria	:= .t.
				elseif SA1->A1_ZZCOLIG == "N" .and. SA1->A1_TIPO == "X"
					_cConta	:= "11204001"+Alltrim(SA1->A1_COD)+Alltrim(SA1->A1_LOJA)
					_cContaG:= "41000"
					_lCria	:= .t.
				endif
			endif
		else
			if Empty(SA2->A2_CONTA)
				if SA2->A2_ZZCOLIG == "S" .and. SA2->A2_TIPO <> "X"
					cContaR	:= "21101001"
					cSeq	:= fBuscaSeq(cContaR)
					_cConta	:= cSeq
					_cContaG:= "21090"
					_lCria	:= .t.
				elseif SA2->A2_ZZCOLIG == "S" .and. SA2->A2_TIPO == "X"
					cContaR	:= "21102001"
					cSeq	:= fBuscaSeq(cContaR)
					_cConta	:= cSeq
					_cContaG:= "21090"
					_lCria	:= .t.
				elseif SA2->A2_ZZCOLIG == "N" .and. SA2->A2_TIPO <> "X"
					_cConta	:= "21103001"+Alltrim(SA2->A2_COD)+Alltrim(SA2->A2_LOJA)
					_cContaG:= "21000"
					_lCria	:= .t.
				elseif SA2->A2_ZZCOLIG == "N" .and. SA2->A2_TIPO == "X"
					_cConta	:= "21104001"+Alltrim(SA2->A2_COD)+Alltrim(SA2->A2_LOJA)
					_cContaG:= "21000"
					_lCria	:= .t.
				endif
			endif
		endif
		If _lCria
			dbSelectArea("CT1")
			_xAreaCT1 := GetArea()
			dbSetOrder(1)
			DbSeek(_cFilial + _cConta)
			// Se encontrar, atualiza a descrição do plano de contas.
			If Found()
				If CT1->CT1_DESC01 <> _cNome
					If RecLock("CT1",.f.) // Atualiza a razão social
						CT1->CT1_DESC01 := _cNome
						msunlock()
					EndIf
				EndIf
				// Caso não encontre a conta no plano de contas, criar a mesma.
			Else
				//Rotina Automatica para criar Conta Contábi
				ModelCT1(_cFilial,_cConta,_cNome,_cCad,_cNtSped,_cCodPla,_cContaG)	
			Endif
			RestArea(_xAreaCT1)
		EndIf
		// Restaura áreas de trabalho.
		RestArea(_xAreaCF)
		// Atualiza a conta no cadastro do Cliente.
		If _cCad=="1"
			If Empty(SA1->A1_CONTA)
				If Reclock(_cAlias, .F.)
					REPLACE SA1->A1_CONTA	with _cConta
					MsUnlock()
				EndIf
			Endif
		Else //Atualiza a conta no cadastro de Fornecedores
			If Empty(SA2->A2_CONTA)
				If Reclock(_cAlias, .F.)
					REPLACE SA2->A2_CONTA	with _cConta
					MsUnlock()
				EndIf
			EndIf
		Endif
	Endif
	RestArea(aArea)

Return(.t.)

//Função: fBuscaSeq() - Busca Sequência da Conta Contábil a ser criada									
Static Function fBuscaSeq(cContaR)
	Local cAlias	:= GetNextAlias()
	Local cContaC	:= ""
	Local cSeq		:= ""
	Local nTam		:= Len(cContaR)
	Local cTam      := "%"+cValToChar(nTam)+"%"
	BeginSql Alias cAlias
		SELECT MAX(CT1_CONTA) CT1_CONTA 
		FROM %Table:CT1%
		WHERE 	CT1_FILIAL 	= %xFilial:CT1%	AND %NotDel% AND Substring(CT1_CONTA,1,%Exp:cTam%) = %Exp:cContaR%
	EndSql
	if !(cAlias)->(Eof())
		cSeq	:= Substr((cAlias)->CT1_CONTA,nTam+1,3)
		cContaC	:= cContaR+SOMA1(cSeq)
	endif
	(cAlias)->(DBCloseArea())
Return(cContaC)


/// ROTINA AUTOMATICA - INCLUSAO DE CONTA CONTABIL CTB
Static Function ModelCT1(_cFilial,_cConta,_cNome,_cCad,_cNtSped,_cCodPla,_cContaG)
	Local nOpcAuto :=0
	Local nX
	Local oCT1
	Local aLog
	Local cLog :=""
	Local lRet := .T.
	Local _cCodPlaRec	:= "000002"


	If __oModelAut == Nil //somente uma unica vez carrega o modelo CTBA020-Plano de Contas CT1
		__oModelAut := FWLoadModel('CTBA020')
	EndIf
	nOpcAuto:=3
	__oModelAut:SetOperation(nOpcAuto) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
	__oModelAut:Activate() //ativa modelo
	// Preencho os valores da CT1
	oCT1 := __oModelAut:GetModel('CT1MASTER') //Objeto similar enchoice CT1
	oCT1:SETVALUE('CT1_CONTA'	,_cConta)
	oCT1:SETVALUE('CT1_DESC01'	,_cNome)
	oCT1:SETVALUE('CT1_CLASSE'	,'2')
	oCT1:SETVALUE('CT1_NORMAL' 	,_cCad)
	oCT1:SETVALUE('CT1_ACITEM' 	, "1")
	oCT1:SETVALUE('CT1_ACCUST'  , "1" )
	oCT1:SETVALUE('CT1_ACCLVL'  , "1" )
	oCT1:SETVALUE('CT1_CCOBRG'  , "2" )
	oCT1:SETVALUE('CT1_ITOBRG'  , "2" )
	oCT1:SETVALUE('CT1_CLOBRG'  , "2" )
	oCT1:SETVALUE('CT1_CTAVM '  , ""  )
	oCT1:SETVALUE('CT1_NTSPED'  , _cNtSped )				
	oCT1:SETVALUE('CT1_BOOK  '  , "001/002/003/004/005"  )
	oCT1:SETVALUE('CT1_NATCTA'  , iif(_cCad=="1","01","02") )

	oCVD := __oModelAut:GetModel('CVDDETAIL') //Objeto similar getdados CVD
	oCVD:SETVALUE('CVD_FILIAL' ,xFilial('CVD'))//ok
	oCVD:SETVALUE('CVD_ENTREF','99')//ok
	oCVD:SETVALUE('CVD_CODPLA',_cCodPla)//ok 
	oCVD:SETVALUE('CVD_TPUTIL','S')//Ok
	oCVD:SETVALUE('CVD_CLASSE','2')//ok 
	oCVD:SETVALUE('CVD_VERSAO','0001')//ok
	//oCVD:SETVALUE('CVD_CTASUP','21999')//Ok
	oCVD:SETVALUE('CVD_CTAREF',_cContaG)//ok

	oCVD:AddLine()
    oCVD:GoLine( 2 )
    oCVD:SETVALUE('CVD_FILIAL' ,xFilial('CVD'))//ok
    oCVD:SETVALUE('CVD_ENTREF','10')//ok
    oCVD:SETVALUE('CVD_CODPLA',_cCodPlaRec)//ok
    oCVD:SETVALUE('CVD_TPUTIL','A')//Ok
    oCVD:SETVALUE('CVD_CLASSE','2')//ok
    oCVD:SETVALUE('CVD_VERSAO','0001')//ok
    //oCVD:SETVALUE('CVD_CTASUP',SubStr(ContaRec(_cConta),1,10))//Ok
    oCVD:SETVALUE('CVD_CTAREF',ContaRec(_cConta))//ok

	If Left(_cConta,5)=='21103|21104'
		oCVD:SETVALUE('CVD_NATCTA','02')//Ok
	ElseIf Left(_cConta,5)$'21101|21102'
		oCVD:SETVALUE('CVD_NATCTA','01')//Ok
	Endif	

	// Preencho os valores da CTS
	
	oCTS := __oModelAut:GetModel('CTSDETAIL') //Objeto similar getdados CTS
	oCTS:SETVALUE('CTS_FILIAL' ,xFilial('CTS'))
	oCTS:SETVALUE('CTS_CODPLA' ,_cCodPla)
	oCTS:SETVALUE('CTS_CONTAG' ,_cContaG)  
	oCTS:SETVALUE('CTS_CTASUP'	,'21999')               
//	oCTS:SETVALUE('CTS_NORMAL'	,'2')
//	oCTS:SETVALUE('CTS_CLASSE'	,'2')
//	oCTS:SETVALUE('CTS_LINHA'	,'5')
//	oCTS:SETVALUE('CTS_TPSALD'	,'1')
	If Left(_cConta,5)=='21103'
//		oCTS:SETVALUE('CTS_ORDEM','0000000450')
//		oCTS:SETVALUE('CTS_CT1INI','2110300100407901')
//		oCTS:SETVALUE('CTS_CT1FIM','2110300100407901')
	ElseIf Left(_cConta,5)$'21101|21102'
//		oCTS:SETVALUE('CTS_ORDEM','0000000430')
//		oCTS:SETVALUE('CTS_CT1INI','21101001001')
//		oCTS:SETVALUE('CTS_CT1FIM','21101001001')
	Endif
	
	If __oModelAut:VldData() //validacao dos dados pelo modelo
		__oModelAut:CommitData() //gravacao dos dados
	Else
		aLog := __oModelAut:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
		//laco para gravar em string cLog conteudo do array aLog
		For nX := 1 to Len(aLog)
			If !Empty(aLog[nX])
			cLog += Alltrim(aLog[nX]) + CRLF
			EndIf
		Next nX
		lMsErroAuto := .T. //seta variavel private como erro
		AutoGRLog(cLog) //grava log para exibir com funcao mostraerro
		mostraerro()
		lRet := .F. //retorna false
	EndIf
	__oModelAut:DeActivate() //desativa modelo
Return( lRet )


Static Function ContaRec(_cConta)

    Local cContaRet := ""

    if SubStr(_cConta,1,5) == "11203"
        cContaRet := "1.01.02.02.01"
    elseif SubStr(_cConta,1,5) == "11204"
        cContaRet := "1.01.02.02.02"
    elseif SubStr(_cConta,1,5) == "21103"
        cContaRet := "2.01.01.03.01"
    elseif SubStr(_cConta,1,5) == "21104"
        cContaRet := "2.01.01.03.01"
    elseif SubStr(_cConta,1,5) == "21102"
        cContaRet := "2.01.01.03.04"
    elseif SubStr(_cConta,1,5) == "21101"
        cContaRet := "2.01.01.03.03"
    elseif SubStr(_cConta,1,5) == "11201"
        cContaRet := "1.01.02.02.03"
    elseif SubStr(_cConta,1,5) == "11202"
        cContaRet := "2.01.02.02.04"
    endif
    
Return cContaRet
