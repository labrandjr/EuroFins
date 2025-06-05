#include "totvs.ch"

/*/{protheus.doc}IMPRPS
Importa arquivos da RPS enviados pela prefeitura de indaiatuba e atualiza campos na tabela SF2
@type function
@version 1.0
@author Sergio Braz
@since 31/08/18
@link https://gkcmp.com.br (Geeker Company)
@history 05/05/2023, Ademar Fernandes Jr, Tratamento da gravaçao do novo campo F2_XMAILNF (E-mail do Tomador)
@return variant, Nil
/*/
User Function ImpRPS()
	Local oDlg
	Local cPath := U_getpar("ZZ_PATHRPS","F:\FATURAMENTO\EDBR\RET.TXT","C","PASTA E ARQUIVO PARA IMPORTACAO DO RPS NO PROTHEUS")
	Local cText := OemToAnsi('Este programa irá integrar as informações das Notas Fiscais Eletrônicas '+;
				'que foram geradas pelo programa DEISS da prefeitura de Indaiatuba e atualizar os dados no sistema Protheus.')

	Define MsDialog oDlg From 0,0 to 300,500 Pixel Title "Importa RPS - Prefeitura de Indaiatuba"
	@ 005,005 Get cText of oDlg Size 240,080 Pixel When .f. MultiLine Font tFont():New("Arial",,24)
	@ 092,005 Say "Arquivo :" of oDlg Pixel Font tFont():New("Arial",,24)
	@ 090,045 MsGet cPath of oDlg Size 140,15 Pixel Font tFont():New("Arial",,18)
	@ 120,005 Button "Processar" of oDlg Size 100,15 Pixel Action (Processa({||Importa(cPath)}),oDlg:End()) Font tFont():New("Arial",,24)
	@ 120,145 Button "Cancelar" of oDlg Size 100,15 Pixel Action oDlg:End() Font tFont():New("Arial",,24)
	Activate MsDialog oDlg Centered
Return

/*
*/
Static Function Importa(cFile)
	Local cLinha,aLinha,cNota,dData,cHora,cChav,cStat,cMail

	If !Empty(cFile)
		If File(cFile)
			PUTMV("ZZ_PATHRPS",cFile)	//-->> RETIRAR COMENTARIO DESTA LINHA QUANDO LIBERAR O FONTE !!!!

			FT_FUSE(cFile)
			ProcRegua(FT_FLASTREC())

			While !FT_FEOF()
				cLinha := FT_FREADLN()

				While "||"$cLinha
					cLinha := StrTran(cLinha,"||","| |")
				End                                     

				aLinha := StrToKarr(cLinha,"|")
				If Len(aLinha)>=8
					cNota  := PadL(aLinha[06],9,"0")
					cNFE   := aLinha[06]
					dData  := Stod(Left(aLinha[07],8))
					cHora  := Substr(aLinha[07],10,6)
					cChav  := aLinha[08]               
					cStat  := aLinha[23]
					cMail  := aLinha[48]

					If cStat $ "N"
						BeginSql Alias "WSF2"
							Select R_E_C_N_O_ NumReg
							From %Table:SF2%
							Where %NotDel% and F2_FILIAL=%xFilial:SF2% and F2_NFELETR = '         ' and 
								F2_DOC = %Exp:cNota% and F2_SERIE='   '
						EndSql   

						If WSF2->(!Eof())
							SF2->(DbGoTo(WSF2->NUMREG))

							RecLock("SF2",.f.)
							SF2->F2_NFELETR :=  cNFE
							SF2->F2_EMINFE	:=	dData
							SF2->F2_HORNFE 	:=	cHora
							SF2->F2_CODNFE 	:=	cChav
							if SF2->(FieldPos("F2_XMAILNF"))>0
								SF2->F2_XMAILNF	:=	cMail
							endif
							SF2->(MSUNLOCK())
						EndIf
						WSF2->(DbCloseArea())
					Endif
				Endif
				IncProc()
				FT_FSKIP()
			End
			MsgInfo("Processo concluído.",ProcName())
		Else
			MsgStop("Arquivo "+AllTrim(cFile)+" nao localizado.",ProcName())
		Endif
	Endif

Return

/*user function xxx
rpcsetenv("01","0100")
u_imprps()
return*/
