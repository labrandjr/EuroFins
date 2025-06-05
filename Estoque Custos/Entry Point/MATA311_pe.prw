#Include 'Protheus.ch'


/*/{Protheus.doc} MATA311
Ponto de entrada executado depois da efetivação da transferência para gravar o centro de custo na tabela SD2
@author Marcos Candido
@since 04/01/2018
/*/

User Function MATA311()
	Local aParam    := PARAMIXB
	local cIdPonto  := aParam[2]
	local oModel	:= aParam[1]
	
	If cIdPonto == "MODELCOMMITNTTS"
		if IsInCallStack('A311EFETIV')
			Efetiva(oModel:getModel('NNTDETAIL'))
		endif
	ENDIF
	
Return.T.


//Rotina que é chamado na efetivação da transferência do MATA311
static function Efetiva(oGrid)

	local alines	:= oGrid:GetLinesChanged()
	local nI		:= 1
	
	while nI <= len(alines)
		oGrid:goLine(aLines[nI])
		nI++
		if(oGrid:getValue('NNT_FILORI') == oGrid:getValue('NNT_FILDES'))
			loop
		endif
		
		//Chama rotina para levar dados da nota fiscal
		addCC(oGrid:getValue('NNT_DOC'),;
				oGrid:getValue('NNT_SERIE'),;
				oGrid:getValue('NNT_PROD'),;
				oGrid:getValue('NNT_LOTECT'),;
				oGrid:getValue('NNT_LOCAL'),;
				oGrid:getValue('NNT_FILORI'),;
				oGrid:getValue('NNT_FILDES'),;
				oGrid:getValue('NNT_ZZCC'))
	enddo
		
return 


static function addCC(cDoc,cSerie,cProd,cLote,cLocal,cFilNF,cFilDes,cCCusto)
	
	//Pega o CNPJ da empresa que foi feita a transferência
	Local cCNPJ 	:= Posicione("SM0",1,"01"+Alltrim(cFilDes),"M0_CGC")
	//Busca código do cliente e loja da filial de transferência.
	Local cClient	:= Posicione("SA1",3,xFilial("SA1")+cCNPJ,"A1_COD")
	Local cLoja		:= Posicione("SA1",3,xFilial("SA1")+cCNPJ,"A1_LOJA")
	

	DbSelectArea('SD2')	
	DbSetOrder(3)
	if !(SD2->(dbseek(cFilNF+cDoc+cSerie+cClient+cLoja+cProd)))
		return 
	endif

	While SD2->D2_FILIAL==cFilNF .and. SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD) == cDoc+cSerie+cClient+cLoja+cProd
		//Grava o centro de custo na nota fiscal diretamente
		If RecLock('SD2',.F.)
			Replace D2_CCUSTO  With cCCusto
			MsUnLock()
		EndIf
        SD2->(dbSkip())
	Enddo

return
