#Include "Protheus.ch"
#Include "Topconn.ch" 

/*/{protheus.doc}F200VAR
Apos carregar os dados do arquivo de recepcao bancaria e sera utilizado para alterar os dados recebidos linha a linha.
@since 27/06/19
@Author Thaís Fumagalli

=============================================
o array aValores irá  permitir 
que qualquer exceção ou necessidade seja
tratado no ponto de entrada em PARAMIXB        
==============================================
 Estrutura de aValores
	Numero do T?ulo	- 01
	data da Baixa		- 02
 Tipo do T?ulo		- 03
 Nosso Numero			- 04
 Valor da Despesa		- 05
 Valor do Desconto    - 06
 Valor do Abatiment  	- 07
 Valor Recebido      	- 08
 Juros				- 09
 Multa				- 10
 Outras Despesas		- 11
 Valor do Credito		- 12
 Data Credito			- 13
 Ocorrencia			- 14
 Motivo da Baixa 		- 15
 Linha Inteira		- 16
 Data de Vencto	   	- 17

aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, xBuffer,dDtVc,{} })

/*/

User Function F200VAR()
	Local aArea    	:= Getarea() 
	nValRec := nValRec + nJuros - nDescont
	RestArea(aArea)
Return nValRec