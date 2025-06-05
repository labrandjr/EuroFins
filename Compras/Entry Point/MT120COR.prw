#include 'rwmake.ch'
/*/{protheus.doc} MT120COR
Ponto de entrada na rotina de Pedido de Compra
Serve para indicar mais cores na legenda (usado em conjunto com o P.E. MT120LEG).
@Author Marcos Candido
@since 29/12/2017
@Obs Em 23/05/2019 adicionadas as condições C7_CONAPRO=L por Sergio Braz
/*/
User Function MT120COR

	Local aMaisCor := PARAMIXB[1]
	Local nLoc := aScan(aMaisCor , {|x| x[2]=='ENABLE'})

	aMaisCor[nLoc][1] := 'C7_QUJE==0 .And. C7_QTDACLA==0 .and. C7_ZZMAIL=="S" .and. C7_CONAPRO=="L"' //-- Pendente mas com e-mail enviado

	aAdd(aMaisCor , { 'C7_QUJE==0 .and. C7_QTDACLA==0 .and. C7_ZZMAIL=="N" .and. C7_CONAPRO=="L"'  , 'BR_PINK'})	 //-- E-mail nao enviado

Return aMaisCor