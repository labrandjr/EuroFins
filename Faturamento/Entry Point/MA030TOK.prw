#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ma030TOk �Autor  � Marcos Candido     � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada ativado no botao "OK" do cadastro do      ���
���          � cliente.                                                   ���
���          � Serao verificados os campos CNPJ e Inscricao Estadual.     ���
���          �                                                            ���
���          � Adicionado por Marcos Candido - em 03/09/15                ���
���          � Formatar a mensagem que o usuario ira receber sobre o      ���
���          � registro que foi excluido.                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Eurofins                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//�����������������������������������������������������������������������Ŀ
//� Verifica se o cliente nao eh de exportacao e se tem o CNPJ preenchido �
//�������������������������������������������������������������������������
	If M->A1_EST <> "EX" .and. Empty(M->A1_CGC)
		IW_MsgBox(OemtoAnsi("Informe o CNPJ/CPF do cliente.") , OemtoAnsi("Aten��o") , "ALERT")
		lRetorno := .F.
	Endif

//�������������������������������������������������������������������������������������������Ŀ
//� Verifica se o cliente eh de exportacao e se tem a Inscricao Estadual preenchida com ISENTO�
//���������������������������������������������������������������������������������������������
	If M->A1_EST == "EX" .and. UPPER(ALLTRIM(M->A1_INSCR)) <> "ISENTO"
		IW_MsgBox(OemtoAnsi("Para clientes fora do pa�s, preencha 'ISENTO' no campo da Inscri��o Estadual.") , OemtoAnsi("Aten��o") , "ALERT")
		lRetorno := .F.
	Endif

//��������������������������������������������������������������������������������������Ŀ
//� Verifica se o cliente nao eh de exportacao e se tem a Inscricao Estadual vazia       �
//����������������������������������������������������������������������������������������
	If M->A1_EST <> "EX" .and. Empty(alltrim(M->A1_INSCR))
		IW_MsgBox(OemtoAnsi("Informe a Inscri��o Estadual do cliente. Se ele for isento, preencha 'ISENTO'.") , OemtoAnsi("Aten��o") , "ALERT")
		lRetorno := .F.
	Endif

//��������������������������������������������������������������������������������������Ŀ
//� Verifica se o CNPJ ja foi cadastrado em outro registro                               �
//����������������������������������������������������������������������������������������
	If lRetorno .and. M->A1_EST <> "EX"
		dbSelectArea("SA1")
		dbSetOrder(3)
		If dbSeek(xFilial("SA1")+M->A1_CGC) .and. M->A1_COD+M->A1_LOJA <> SA1->A1_COD+SA1->A1_LOJA
			If Len(Alltrim(M->A1_CGC)) == 14
				IW_MsgBox(OemtoAnsi("O CNPJ digitado j� est� vinculado ao c�digo "+SA1->A1_COD+"/"+SA1->A1_LOJA+". Verifique.") , OemtoAnsi("Aten��o") , "ALERT")
			Else
				IW_MsgBox(OemtoAnsi("O CPF digitado j� est� vinculado ao c�digo "+SA1->A1_COD+"/"+SA1->A1_LOJA+". Verifique.") , OemtoAnsi("Aten��o") , "ALERT")
			Endif
			lRetorno := .F.
		Endif
	Endif


//Exporta��o de Risco de Cliente para ELyns e MyLins
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
					aadd(aInfo , "pelo usu�rio: "+Substr(cUsuario,7,15) )
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
				aadd(aInfo , "Conte�do Anterior: "+cOld )
				aadd(aInfo , "Novo Conte�do : "+cNew )
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
