#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} VldAltPc
Controla campos que podem ser editados na opção de alteração de pedido de compra
@author RICARDO REY
@since 09/10/2017
/*/
user function VldAltPc()
Local cVar := ReadVar()
Local aCampos := {"M->C7_OBS","M->C7_QUANT","M->C7_PRECO","M->C7_DATPRF"}
Local lOk := .F.

if !ALTERA
	Return .T.
endif

 if Empty(SC7->C7_APROV) //não tem aprovador, pedido pode ser alterado sem restrições
 	lOk := .T.
 else
 	if SC7->C7_CONAPRO <> 'L' //pedido ainda não foi liberado, pedido pode ser alterado sem restrições
 		lOk := .T.
 	else
 		if aScan(aCampos,cVar) <> 0 //campo autorizado a ser alterado após aprovação
 			lOk := .T.
 		endif
 	endif
 endif


 Return lOk


return .t.



/*/{Protheus.doc} VldPrcQtd
//controla valores que poderão ser informados nos campos de quantidade e valor unitario
//na alteração do pedido de comopra
@author RICARDO REY
@since 09/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function VldPrcQtd()
Local cVar 	:= ReadVar()
Local cCampo := "SC7"+Substr(cVar,2)
Local xVar
Local xCampo
Local lOk := .t.

if !ALTERA
	Return .t.
endif


 if Empty(SC7->C7_APROV) //não tem aprovador, pedido pode ser alterado sem restrições
 	lOk := .T.
 else
 	if SC7->C7_CONAPRO <> 'L' //pedido ainda não foi liberado, pedido pode ser alterado sem restrições
 		lOk := .T.
 	else
 		xVar := &(cVar)
 		xCampo := &(cCampo)
 		if xVar > xCampo
 			lOk := .f.
 			MsgStop("Este pedido já foi aprovado, portanto o valor só pode ser alterado para baixo")
 		endif
 	endif
 endif

Return lOk

