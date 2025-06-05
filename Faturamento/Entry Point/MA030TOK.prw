#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ma030TOk ºAutor  ³ Marcos Candido     º Data ³  12/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada ativado no botao "OK" do cadastro do      º±±
±±º          ³ cliente.                                                   º±±
±±º          ³ Serao verificados os campos CNPJ e Inscricao Estadual.     º±±
±±º          ³                                                            º±±
±±º          ³ Adicionado por Marcos Candido - em 03/09/15                º±±
±±º          ³ Formatar a mensagem que o usuario ira receber sobre o      º±±
±±º          ³ registro que foi excluido.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Eurofins                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} MA030TOK
Ativado no botao "OK" do cadastro do cliente.
Serao verificados os campos CNPJ e Inscricao Estadual.  Formatar a mensagem que o usuario ira receber sobre o registro que foi excluido.
@author Marcos Candido
@since 02/01/2018
/*/
User Function MA030TOK

	Local lRetorno := .T.
	Local aAreaAtual := GetArea()
	Local aInfo := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o cliente nao eh de exportacao e se tem o CNPJ preenchido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->A1_EST <> "EX" .and. Empty(M->A1_CGC)
		IW_MsgBox(OemtoAnsi("Informe o CNPJ/CPF do cliente.") , OemtoAnsi("Atenção") , "ALERT")
		lRetorno := .F.
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o cliente eh de exportacao e se tem a Inscricao Estadual preenchida com ISENTO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->A1_EST == "EX" .and. UPPER(ALLTRIM(M->A1_INSCR)) <> "ISENTO"
		IW_MsgBox(OemtoAnsi("Para clientes fora do país, preencha 'ISENTO' no campo da Inscrição Estadual.") , OemtoAnsi("Atenção") , "ALERT")
		lRetorno := .F.
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o cliente nao eh de exportacao e se tem a Inscricao Estadual vazia       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->A1_EST <> "EX" .and. Empty(alltrim(M->A1_INSCR))
		IW_MsgBox(OemtoAnsi("Informe a Inscrição Estadual do cliente. Se ele for isento, preencha 'ISENTO'.") , OemtoAnsi("Atenção") , "ALERT")
		lRetorno := .F.
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o CNPJ ja foi cadastrado em outro registro                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .and. M->A1_EST <> "EX"
		dbSelectArea("SA1")
		dbSetOrder(3)
		If dbSeek(xFilial("SA1")+M->A1_CGC) .and. M->A1_COD+M->A1_LOJA <> SA1->A1_COD+SA1->A1_LOJA
			If Len(Alltrim(M->A1_CGC)) == 14
				IW_MsgBox(OemtoAnsi("O CNPJ digitado já está vinculado ao código "+SA1->A1_COD+"/"+SA1->A1_LOJA+". Verifique.") , OemtoAnsi("Atenção") , "ALERT")
			Else
				IW_MsgBox(OemtoAnsi("O CPF digitado já está vinculado ao código "+SA1->A1_COD+"/"+SA1->A1_LOJA+". Verifique.") , OemtoAnsi("Atenção") , "ALERT")
			Endif
			lRetorno := .F.
		Endif
	Endif


//Exportação de Risco de Cliente para ELyns e MyLins
	if lRetorno
		if Inclui
			LogRisco("Inc",Alltrim(M->A1_COD),AllTrim(M->A1_LOJA),Alltrim(M->A1_CGC),Alltrim(M->A1_RISCO),AllTrim(M->A1_NOME))
		else
			if Alltrim(M->A1_RISCO) != AllTrim(SA1->A1_RISCO) .and. !Alltrim(M->A1_RISCO) $ "BCD"
				if M->A1_EST == "EX"
					LogRisco("Alt",Alltrim(M->A1_COD),AllTrim(M->A1_LOJA),"99999",Alltrim(M->A1_RISCO),AllTrim(M->A1_NOME))
				else
					LogRisco("Alt",Alltrim(M->A1_COD),AllTrim(M->A1_LOJA),Alltrim(M->A1_CGC),Alltrim(M->A1_RISCO),AllTrim(M->A1_NOME))
				endif
			endif
		endif
	endif

	If lRetorno .and. ALTERA

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+M->A1_COD+M->A1_LOJA)

		For j:=1 to FCount()
			If FieldGet(FieldPos(FieldName(j))) <>  &("M->"+(FieldName(j)))
				If Len(aInfo) == 0
					aadd(aInfo , "Os seguintes campos foram alterados no cadastro do Cliente: " +M->A1_COD+"/"+M->A1_LOJA+" - "+M->A1_NOME )
					aadd(aInfo , "pelo usuário: "+Substr(cUsuario,7,15) )
					aadd(aInfo , " " )
				Endif
				If ValType(FieldGet(FieldPos(FieldName(j)))) == "N"
					cOld := Str(FieldGet(FieldPos(FieldName(j))))
					cNew := Str(&("M->"+(FieldName(j))))
				Elseif ValType(FieldGet(FieldPos(FieldName(j)))) == "D"
					cOld := DtoC(FieldGet(FieldPos(FieldName(j))))
					cNew := DtoC(&("M->"+(FieldName(j))))
				Elseif ValType(FieldGet(FieldPos(FieldName(j)))) == "C"
					cOld := FieldGet(FieldPos(FieldName(j)))
					cNew := &("M->"+(FieldName(j)))
				Else
					cOld := ""
					cNew := ""
				Endif
				aadd(aInfo , FieldName(j) )
				aadd(aInfo , "Conteúdo Anterior: "+cOld )
				aadd(aInfo , "Novo Conteúdo : "+cNew )
			Endif
		Next

		If Len(aInfo) > 0
			aadd(aInfo , " ")
			MEnviaMail("Z12",aInfo)
		Endif

	Endif

	RestArea(aAreaAtual)

Return(lRetorno)


Static Function LogRisco(cTipo,cCod,cLoja,cCNPJ,cRisco,cNome)
	Local cPath := GetMv("ZZ_LOGRISC")
	Local cResp := ""
	local cNome := "\Cliente_"+cCod+"_"+cLoja+"_"+Dtos(dDataBase)+"_"+Left(StrTran(Time(),":",""),4)+".CSV"
	// Local cFile := cPath + cNome
	local nX := 0

	iif(cTipo == "Inc",cResp := "Insert;",cResp:= "Update;")
	cResp += cCod+"-"+cLoja+";"+cCNPJ+";"+cRisco+";"+cNome+";"+Alltrim(CUSERNAME)+";"+cValToChar(dDataBase)+";"+cValTochar(Time())
	// MakeDir(cPath)
	// MemoWrite(cFile,cResp)

	aDir := {'\\br50fivp001\ITRBR_eLIMSFGS\Data\PRD\EUGSSP_PRD\MicrosigaC',;
		'\\br50fivp001\ITRBR_eLIMSFGS\Data\PRD\EUBRRJ_PRD\MicrosigaC',;
		'\\br50fivp001\ITRBR_eLIMSFGS\Data\PRD\EUBRGA_PRD\MicrosigaC',;
		'\\br50fivp001\ITRBR_eLIMSFGS\Data\PRD\EUBRRE_PRD\MicrosigaC',;
		'\\br50fivp001\ITRBR_eLIMSFGS\Data\PRD\EUBRJMU_PRD\MicrosigaC'}

	For nX := 1 to len(aDir)
		MemoWrite(aDir[nX] + cNome,cResp)
	Next nX



Return
