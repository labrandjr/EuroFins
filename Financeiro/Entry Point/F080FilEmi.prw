#include 'totvs.ch'

/*/{protheus.doc}F080FilEmi 
Na rotina FINA080, informa o campo que será comparado com data da baixa.
@Author Marcos Candido   
@since  10/11/16   
@Obs Se o campo indicado tiver uma data menor que a data da baixa, o processo sera interrompido.
/*/
User Function F080FilEmi

	Local cRet := "E2_EMIS1"

Return cRet