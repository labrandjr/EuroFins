#include "totvs.ch"
#include "topconn.ch"
/*/{protheus.doc} F050ROT
PE para mostrar a função de importar baixa automática para invoices
@author Régis Ferreira
@since 21/09/2021
/*/

User Function F050ROT              
    
    Local aRotina := ParamIxb
    
    aAdd( aRotina, { "# Baixar Invoices", "U_BXINVOICE()", 0, 8} )
    
Return aRotina         
