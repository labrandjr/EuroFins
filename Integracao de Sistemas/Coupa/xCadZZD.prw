#include 'protheus.ch'
#include 'FWMVCDef.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} 
Tela de visualização do histórico de logs de integração
@author Tiago Maniero
@since 15/05/2020
@version undefined

@type function
/*/
//-----------------------------------------------------------------
User Function xCadZZD()

	Local aArea := GetArea()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZZD")
	oBrowse:SetDescription("Ocorrências integrações COUPA")
	oBrowse:AddLegend("ZZD_STATUS=='I'", "GREEN", "INTEGRADO")
	oBrowse:AddLegend("ZZD_STATUS=='N'", "RED", "NÃO INTEGRADO")
	oBrowse:Activate()

	RestArea(aArea)
	
Return Nil

//-----------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar"    		ACTION 'PesqBrw'				OPERATION 1			ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'			Action 'VIEWDEF.xCadZZD' 		OPERATION 2 		ACCESS 0
	ADD OPTION aRotina Title 'Exporta Arquivo' 		Action 'u_zExpArq()'			OPERATION 9 		ACCESS 0
	ADD OPTION aRotina Title 'Imp. Segund. UM' 		Action 'u_fImpSegUM()'			OPERATION 3 		ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"      		ACTION 'VIEWDEF.xCadZZD'  		OPERATION  MODEL_OPERATION_DELETE  ACCESS 0
	ADD OPTION aRotina TITLE "Arquivos pendentes"	ACTION 'u_zQtdArqC()'  			OPERATION 9 		ACCESS 0
	
	ADD OPTION aRotina TITLE "Bloqueio Fornecedor"	ACTION 'u_fImpBlqFor()'			OPERATION 9 		ACCESS 0
	ADD OPTION aRotina TITLE "Bloqueio Clientes"	ACTION 'u_fImpBlqCli()'			OPERATION 9 		ACCESS 0

	/*
	ADD OPTION aRotina TITLE "Incluir"      ACTION 'VIEWDEF.xCadZZD'  OPERATION  MODEL_OPERATION_INSERT  ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION 'VIEWDEF.xCadZZD'  OPERATION  MODEL_OPERATION_UPDATE  ACCESS 0
	*/

Return aRotina

//-----------------------------------------------------------------
Static Function ModelDef()

	Local oStruZZD := FWFormStruct(1, "ZZD")
	Local oModel
	
	oModel := MPFormModel():New('ZZDCAD',,,)
	oModel:AddFields('ZZDMASTER', /*cOwner*/, oStruZZD)
	oModel:GetModel('ZZDMASTER' ):SetDescription("Número da Ocorrência")
	oModel:SetDescription("Número da Ocorrência")
	oModel:SetPrimaryKey({})

Return oModel

//-----------------------------------------------------------------
Static Function ViewDef()

	Local oView    := Nil
	Local oModel   := FWLoadModel('xCadZZD')
	Local oStruZZD := FWFormStruct(2, "ZZD")

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_ZZD', oStruZZD, 'ZZDMASTER')
	
Return oView

//-----------------------------------------------------------------
User Function zQtdArqC()
	
	Local aArqs			:= {}
	Local cDiretorio	:= "\coupa\PO\pendente\"

	aArqs := Directory( cDiretorio + "*.csv","S")
	
	If Len(aArqs) == 0
		MsgAlert("Nenhum Arquivo pendente na pasta [" + cDiretorio + "] para importação",funDesc())
	Else
		MsgAlert( cValToChar(Len(aArqs)) + " arquivos pendentes na pasta [" + cDiretorio + "] para importação",funDesc())
	EndIf

Return
