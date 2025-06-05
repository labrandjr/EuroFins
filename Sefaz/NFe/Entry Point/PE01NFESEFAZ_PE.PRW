#Include 'Totvs.ch'

/*/{Protheus.doc} PE01NFESEFAZ
	Ponto de Entrada executado na rotina NfeSefaz - transmissao a NF-e - Geracao do XML.
	@author 	Régis Ferreira
	@since 		08/12/2021
	@version 	1.0
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function PE01NFESEFAZ()
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Local aProd		:= aParam[1]
	Local cMensCli	:= aParam[2]	
	Local cMensFis	:= aParam[3]
	Local aDest		:= aParam[4]
	Local aNota		:= aParam[5]
	Local aInfoItem	:= aParam[6]
	Local aDupl		:= aParam[7]
	Local aTransp	:= aParam[8]
	Local aEntrega	:= aParam[9]
	Local aRetirada	:= aParam[10]
	Local aVeiculo	:= aParam[11]
	Local aReboque	:= aParam[12]
	Local aNfVincRur:= aParam[13]
	Local aEspVol	:= aParam[14]
	Local aNfVinc	:= aParam[15]
	Local aDetPag	:= aParam[16]
	Local aObsCont	:= aParam[17]
	Local aProcRef	:= aParam[18]
	Local nCont		:= 0

	if cFilAnt == "0400"
		//--- Caso o Informações adicionais esteja preenchido
		SB5->(dbSetOrder(1))
		For nCont:= 1 to Len(aProd)
			SB5->(dbSeek( xFilial("SB1") + aProd[nCont,02] ))
            if !Empty(SB5->B5_DESCNFE)
                aProd[nCont,4] := Alltrim(SB5->B5_DESCNFE)
            endif
		Next
	end	

Return({aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag,aObsCont,aProcRef})

