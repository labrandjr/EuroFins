#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc}	MATA094
Ponto de entrada que trata valores unitários por produto na aprovação de SA

@author				Régis Ferreira - Totvs IP Jundiaí
@since				28/10/2020
@return				lRet
/*/
User Function MATA094()

    local aParam 	:= PARAMIXB
    local oObj		:= Nil
    local cIdPonto 	:= ""
    local cIdModel 	:= ""
    local lIsGrid	:= .F.
    local xRet

    if aParam <> Nil
        oObj 		:= aParam[1]
        cIdPonto 	:= aParam[2]
        cIdModel 	:= aParam[3]

        lIsGrid		:= (len( aParam ) > 3)
    endIf

    if cIdPonto == "BUTTONBAR"
        if "SA" $ SCR->CR_TIPO //Senão for do tipo SA não acrescenta o Botão
            If FwIsInCallStack("A94ExLiber") .or. FwIsInCallStack("A094Rejeita") .or. FwIsInCallStack("aOpcVis") .or. FwIsInCallStack("A094Bloqu")
                xRet := { {'# Analisar Valores', , { || AnValores(Alltrim(SCR->CR_NUM)) }, } }
            EndIf
        endif
    else
        xRet    := .T.
    endif

return xRet


Static Function AnValores(cSANUM)

    Local aCabec    := {"Item","Produto","Descrição","Quantidade","V. Unitário","Valor Total"}
    Local aArea := GetArea()
    Private aDados  := {}

    Processa({|| GetSA(cSANUM)},"Aguarde! Gerando dados a processar.") //Processa dados a exibir

    //Monta tela de valores
	If !Empty(aDados)
		Define MsDialog oDlg From 0,0 to 430,680 Pixel Font tFont():New("Arial",,14) 
			oBrowse := TCBrowse():New(01,01,340,180,,aCabec,{10,60,100,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
			oBrowse:SetArray(aDados)
			oBrowse:bLine := {|| {aDados[oBrowse:nAt,1],aDados[oBrowse:nAt,2],aDados[oBrowse:nAt,3],aDados[oBrowse:nAt,4],aDados[oBrowse:nAt,5],aDados[oBrowse:nAt,6]} } 
			@ 190,10 button "Fechar" of oDlg Size 50,10 Pixel Action oDlg:End() Font tFont():New("Arial",,18)        
		Activate MsDialog oDlg Centered
	Else
		MsgInfo("<h5>Não há dados a processar com esses parâmetros.</h5>",FunName())
	Endif

    RestArea(aArea)

Return

//Rotina que irá fazer a busca dos produtos a exibir
Static Function GetSA(cSANUM)

    Local nTotal    := 0
    Local cUser     := Alltrim(RetCodUsr())

    BeginSql Alias "GETDBL"
        select DISTINCT
            CP_ITEM CP_ITEM, 
            CP_PRODUTO CP_PRODUTO,
            B1_DESC B1_DESC,
            CP_QUANT CP_QUANT,
            DBM_VALOR/CP_QUANT VUNIT,
            DBM_VALOR DBM_VALOR
        from 
            %Table:DBM% DBM,
            %Table:SB1% SB1,
            %Table:SCP% SCP
        where 
            DBM.D_E_L_E_T_ = ' ' and SCP.D_E_L_E_T_ = ' ' and
            SB1.D_E_L_E_T_ = ' ' and
            DBM_ITEM = CP_ITEM and 
            DBM_FILIAL = CP_FILIAL and
            DBM_NUM = CP_NUM and
            CP_PRODUTO = B1_COD and
            DBM_TIPO = 'SA' and
            DBM_NUM = %Exp:cSANUM% and
            DBM_FILIAL = %Exp:SCR->CR_FILIAL% and
            DBM_USER = %Exp:cUser%
    EndSql

    While GETDBL->(!Eof())  
        aadd(aDados,{GETDBL->CP_ITEM,GETDBL->CP_PRODUTO,GETDBL->B1_DESC,Transform(GETDBL->CP_QUANT, "@E 999,999,999.99"),Transform(GETDBL->VUNIT, "@E 999,999,999.99"),Transform(GETDBL->DBM_VALOR, "@E 999,999,999.99")})
        nTotal := nTotal + GETDBL->DBM_VALOR
	    GETDBL->(DbSkip())
	End
    GETDBL->(DbCloseArea())

    //Acrescenta o total
    aadd(aDados,{"","","","","TOTAL",Transform(nTotal, "@E 999,999,999.99")})

Return
