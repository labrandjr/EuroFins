#include "totvs.ch"
#include "topconn.ch"
/*/{protheus.doc} F050ROT
PE para mostrar a fun��o de importar baixa autom�tica para invoices
@author R�gis Ferreira
@since 21/09/2021
/*/

User Function F050ROT              
    
    Local aRotina := ParamIxb
    
    aAdd( aRotina, { "# Baixar Invoices", "U_BXINVOICE()", 0, 8} )
    
Return aRotina         
