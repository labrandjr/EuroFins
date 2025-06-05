#Include 'Protheus.ch'
#Include "totvs.ch"

/*/{Protheus.doc} ZZVALINV
Finalidade: Rotina que irá validar se a invoice que está sendo lançada, já foi lançada com outro número de título.
Módulo: Financeiro

@type function
@author Régis Ferreira - Totvs IP Jundiaí
@since 19/03/2020
@version Protheus 12 - Financeiro
@return nil

/*/

User Function ZZVALINV
	
	Local aAreaAtual:= GetArea()
	Local lRet 	:= .T.
	Local cInv	:= M->E2_ZZNUINV
	Local cFil	:= cFilAnt
	Local cFor	:= M->E2_FORNECE
	Local cLoja	:= M->E2_LOJA
	Local cTipo	:= M->E2_TIPO
	Local cTitulo	:= "Invoice já lançada - ZZVALINV"
	Local cProblema	:= "O número de Invoice "+AllTrim(cInv)+" já foi lançado para o fornecedor "+AllTrim(cFor)+" loja "+AllTrim(cLoja)+"."
	Local cSolucao	:= "Verifique se o código da invoice que está sendo lançada está correto!" 
	
	if !Empty(cInv)
		BeginSql Alias "INV"		
			select 
				Count(*) 'CONTAGEM' 
			from %table:SE2% SE2
			where 
				SE2.%NotDel% and
				SE2.E2_ZZNUINV = %Exp:cInv% and
				SE2.E2_FILIAL = %Exp:cFil% and
				SE2.E2_TIPO = %Exp:cTipo% and
				SE2.E2_FORNECE = %Exp:cFor% and
				SE2.E2_LOJA = %Exp:cLoja%
		EndSql
	
		if INV->CONTAGEM > 0
			lRet := .F.
			Help(NIL, NIL, cTitulo, NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
		end
		
		INV->(DbCloseArea())
	endif
	
	RestArea(aAreaAtual)

Return lRet