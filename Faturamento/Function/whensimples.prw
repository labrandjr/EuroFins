#include "totvs.ch"   
/*/{protheus.doc}WhenSimples
Valida��o para os campos A1_NATUREZ E A1_SIMPNAC
@author Sergio Braz
@since 25/10/2019
/*/
/*se o campo Optante Simples na primeira aba = SIM
s� pode preencher a natureza 0101012
se for n�o, pode preencher qualquer natureza a n�o ser a 0101012
sempre validar isso depois que o usu�rio mudar a natureza
ai, depois que colocar a natureza, seja de simples ou n�o
tem que ir na SED dessa natureza que est� no cadastros e trazer a mesma informa��o para o cadastro do cliente
A1_RECISS recebe ED_CALCISS
A1_RECIRRF recebe ED_CALCIRF
A1_RECCSLL recebe ED_CALCCSL
A1_RECINSS recebe ED_CALCINS
A1_RECCOFI recebe ED_CALCCOFI
A1_RECPIS recebe ED_CALCPIS*/

User Function WhenSimples
	Local cCampo := ReadVar()  
	Local lRet   := .T.
	If cCampo $"M->A1_NATUREZ|M->A1_SIMPNAC"
		If cCampo == "M->A1_NATUREZ"
			If Trim(M->A1_NATUREZ) == "0101012" .and. M->A1_SIMPNAC#'1'
				If MsgYesNo('Esta natureza exige a op��o pelo Simples Nacional.','Confirma alterar para Simples Nacional?')
					M->A1_SIMPNAC := '1'					
				Else
					lRet := .f.
				Endif
			Elseif Trim(M->A1_NATUREZ) == "0101008" .and. (AllTrim(M->A1_EST)) # "EX"
				If MsgYesNo('Esta natureza exige a que o cliente seja Exterior.','Confirma alterar para Exterior?')
					M->A1_EST := 'EX'			
					M->A1_COD_MUN := "99999"
					M->A1_MUN := "EXTERIOR"		
				Else
					lRet := .f.
				Endif
			Elseif Trim(M->A1_NATUREZ) == "0101002" .and. (AllTrim(M->A1_SIMPNAC) # "2" .or. AllTrim(M->A1_PESSOA) # "F")
				If MsgYesNo('Esta natureza exige a que o cliente seja pessoa f�sica e n�o optante pelo simples nacional.','Confirma alterar n�o Optante pelo simples nacional e pessoa f�sica?')
					M->A1_SIMPNAC 	:= "2"			
					M->A1_PESSOA 	:= "F"		
				Else
					lRet := .f.
				endif
			ElseIf Trim(M->A1_NATUREZ) # "0101012"
				M->A1_SIMPNAC := "2"
			Endif
		ElseIf cCampo == "M->A1_SIMPNAC" 
			If M->A1_SIMPNAC=="1"
				If !Empty(M->A1_NATUREZ).AND.AllTrim(M->A1_NATUREZ)#"0101012"
					If MsgYesNo("Esta op��o exige que a Natureza seja '0101012'","Confirma altera��o da Natureza?")
						M->A1_NATUREZ := "0101012"  
						M->A1_PESSOA  := "J"  
					Else
						lRet := .f.
					Endif
				Else                                  
					M->A1_NATUREZ := "0101012"    
				Endif
			Else
				M->A1_NATUREZ := CriaVar("A1_NATUREZ",.F.)
			Endif
		EndIf
		If lRet
			If Posicione("SED",1,xFilial("SED")+M->A1_NATUREZ,"!Eof()")
				iif(AllTrim(SED->ED_CALCISS)=="S", M->A1_RECISS := "1", M->A1_RECISS := "2") 
				iif(AllTrim(SED->ED_CALCIRF)=="S", M->A1_RECIRRF := "1", M->A1_RECIRRF := "2") 
				M->A1_RECCSLL := SED->ED_CALCCSL
				M->A1_RECINSS := SED->ED_CALCINS
				M->A1_RECCOFI := SED->ED_CALCCOFI
				M->A1_RECPIS  := SED->ED_CALCPIS				
			Endif
		Endif
	elseIf cCampo $"M->A1_PESSOA|M->A1_EST"
		//Se for pessoa f�sica ou Estado EX, preencher natureza e simples nacional
		If cCampo == "M->A1_PESSOA"
			If Trim(M->A1_PESSOA) == "F"
				if Trim(M->A1_PESSOA) == "F" .and. (Trim(M->A1_SIMPNAC) # "2" .or. Trim(M->A1_NATUREZ) # "0101002")
					If MsgYesNo('Cliente Pessoa F�sica exige o cliente n�o optante pelos simples nacional e a natureza 0101002.','Confirma alterar Simples Nacional e Natureza?')
						M->A1_SIMPNAC := '2'
						M->A1_NATUREZ := '0101002'
					endif
				else
					lRet := .f.
				endif
			endif
		elseif cCampo == "M->A1_EST"
			If Trim(M->A1_EST) == "EX"
				if Trim(M->A1_EST) == "EX" .and. (Trim(M->A1_SIMPNAC) # "2" .or. Trim(M->A1_NATUREZ) # "0101008")
					If MsgYesNo('Cliente Exterior exige cliente n�o no optante pelos simples nacional e a natureza 0101008.','Confirma alterar Simples Nacional e Natureza?')
						M->A1_SIMPNAC := '2'
						M->A1_NATUREZ := '0101008'
						M->A1_EST	  := "EX"
						M->A1_COD_MUN := "99999"
						M->A1_MUN	  := "EXTERIOR"
					else
						lRet := .f.
					endif
				endif
			endif
		endif
	Endif
Return lRet