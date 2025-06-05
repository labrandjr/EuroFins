#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "colors.ch"

/*/{Protheus.doc} AnatechConnect
Gera pedidos de venda na base do Protheus a partir de arquivos XML.
@author Marcos Candido
@since 04/01/2018
@Obs Anatech
/*/
User Function AnatechConnect()
	
	Local aSays      := {}
	Local aButtons   := {}
	Local cCadastro  := OemToansi('Integração entre sistemas - Protheus x MyLims')
	Local lOkParam   := .T.
	Local cMens      := OemToAnsi('A opção de Parâmetros desta rotina deve ser acessada antes de sua execução!')
	If Substr(Alltrim(SM0->M0_CODFIL),1,2) <> '05' .and. Substr(Alltrim(SM0->M0_CODFIL),1,2) <> '08' .and. Substr(Alltrim(SM0->M0_CODFIL),1,2) <> '06'
		Aviso(OemToAnsi('Atenção!!!'), OemToAnsi('Esta rotina só pode ser executada na empresa Anatech ou ASL.') , {'Sair'})
		Return
	Endif
	aAdd(aSays,OemToAnsi('Este programa visa integrar os sistemas Protheus e MyLims, atualizando '))
	aAdd(aSays,OemToAnsi('as tabelas para faturamento do Protheus. '))
	//aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
	aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| ProcGer()}),o:oWnd:End()),Aviso(OemToAnsi('Atenção!!!'), cMens , {'Ok'})) } } )
	aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch( cCadastro, aSays, aButtons,,200,440 ) // altura x largura

Return

/*/
	Funcao chamada pelo botao OK na tela inicial de processamento. Executa a integracao entre os sistemas.
/*/
Static Function ProcGer()
	If IW_MsgBox(OemToAnsi("Confirma processamento ?") , OemToAnsi("Atenção") , "YESNO")
		Processa({|lEnd| Run01() } , "Geração de Pedidos de Venda")
	Else
		IW_MsgBox(OemToAnsi("Processamento Cancelado.") , OemToAnsi("Aviso") , "ALERT")
	Endif
Return

Static Function Run01()
	Local lCont 		:= .T.
	Local aDados 		:= {}
	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local cItem  		:= "0"
	Local aTotItens 	:= {}
	Local cMsg 			:= ""
	Local dDtBsOri 		:= dDataBase
	Local aLogErro 		:= {}
	Local cEmailNF 		:= "" , cMensNF := "" , nVlr := 0
	Local lFirst 		:= .T.
	Local oOK 			:= LoadBitmap(GetResources(),"CHECKED" )
	Local oNO 			:= LoadBitmap(GetResources(),"UNCHECKED" )
	Local aBrowse 		:= {}
	Local cCliAnt 		:= ""
	Local nField 		:= 1
	Local cAglut 		:= ""
	Local cError    	:= ""
	Local cWarning  	:= ""
	Local cPath     	:= SuperGetMV("ZZ_LOCMYEN",,"\XML_MYLIMS\ENVIO\")//"\XML_MYLIMS\ENVIO\"
	Local aFile     	:= {}
	Local lCont     	:= .T.
	Local aCabExcel 	:= {'','Código','Loja','Nome Cliente','Num. Grupo','C. Invoice','N. Amostra','N. Processo','Serviço','Valor','Data Coleta','Mens. Nota'}
	Local aArqOk    	:= {}
	Local aProcs    	:= {}
	Local cCNPJContr 	:= ""
	Local cNomeContr 	:= ""
	Local cContContr 	:= ""
	Local cCNPJSolic 	:= ""
	Local cNomeSolic 	:= ""
	Local cContSolic 	:= ""
	Local cCNPJRepr  	:= ""
	Local cNomeRepr  	:= ""
	Local cContRepr  	:= ""
	Local cCNPJFat   	:= ""
	Local cNomeFat   	:= ""
	Local cContFat   	:= ""
	Local cTes 		 	:= SuperGetMv("MV_ZZTESMY",,"543")
	Local nB         	:= 0
	Local nX         	:= 0
	Local nC         	:= 0
	Local nA         	:= 0
	Local t          	:= 0
	Local nY         	:= 0
    Local cFilBKP    	:= cFilAnt
    Local cFilService	:= ""
	Local cProdXML		:= ""
	Local cCCColeta		:= ""
	Local cCodAreaSer	:= ""
    Local nVlrMetodos   := 0
	Local cMetodos		:= ""
	Local cCC_PRD		:= ""
	Local nMethodSer	:= 0
	Local nCountMethod	:= 0
	Local cNumAmostra	:= ""
	Local cNumProcesso	:= ""
	Local cNrGrupo		:= ""
	Local CDTCOLETA		:= "//" 
	Local nTotAmostra 	:= 0
	Local cPagtoMylins 	:= ""
	Local cVendedor		:= ""
	Local cEmailFat		:= ""
	Local lMetodo		:= .T.
	Local nValAmostra	:= 0 //Soma o valor total da amostra
	Local nValTotAmos	:= 0 //pega o valor total da amostra na Tag VLTOTAL dentro da tag AMOSTRA
	Local nValor		:= 0
	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.
	Private cServiArea	:= ""
	Private lMsgDifer	:= SuperGetMv("ZZ_MOSTRAM",.F.,.T.) //Parâmetro para mostrar mensagem de divergência ou não entre amostras e total da amostra
	
	aFiles := Directory(cPath+"*.XML")
	
	If Len(aFiles) > 0
		For nX:=1 to Len(aFiles)
			lMetodo	  := .T.
			cEmailFat := ""
			cServiArea:= ""
			cError    := ""
			cWarning  := ""
			lCont     := .T.
			oFullXML  := XmlParserFile(cPath+aFiles[nX,1],"_",@cError,@cWarning)
			oXML      := oFullXML
			If Empty(oXML)
				IW_MsgBox(OemToAnsi("Arquivo "+cPath+aFiles[nX,1]+" sem dados consistentes.") , OemToAnsi("Erro") , "STOP")
				lCont := .F.
			EndIf
			If lCont .and. !Empty(cError)
				IW_MsgBox(OemToAnsi(cError) , OemToAnsi("Erro") , "STOP")
				lCont := .F.
			EndIf
			If lCont
				cCNPJCPF    := oXML:_DADOS:_INVOICE:_CNPJ:TEXT
				cCodInvoice := oXML:_DADOS:_INVOICE:_CDINVOICE:TEXT
				cBusca      := alltrim(StrTran(StrTran(StrTran(cCNPJCPF,"/",""),"-",""),".",""))
				cCodServ    := oXML:_DADOS:_INVOICE:_CDCADAUXILIAR01:TEXT
				cEnvRet     := oXML:_DADOS:_INVOICE:_CDCADAUXILIAR02:TEXT
				cMsgNF      := oXML:_DADOS:_INVOICE:_NMTXTAUXILIAR02:TEXT
				if AttIsMemberOf(oXML:_DADOS:_INVOICE , "_CONDICAOPGTO")
					cPagtoMylins:= Upper(Alltrim(oXML:_DADOS:_INVOICE:_CONDICAOPGTO:TEXT))
				else
					cPagtoMylins:= "CONDICAO DE PAGAMENTO INVALIDA"
				endif
				if AttIsMemberOf(oXML:_DADOS:_INVOICE , "_RESPVENDAS")
					cVendedor	:= Upper(Alltrim(oXML:_DADOS:_INVOICE:_RESPVENDAS:TEXT))
				else
					cVendedor:= ""
				endif
				if AttIsMemberOf(oXML:_DADOS:_INVOICE , "_EMAILFAT")
					cEmailFat	:= Lower(Alltrim(oXML:_DADOS:_INVOICE:_EMAILFAT:TEXT))
				else
					cEmailFat:= ""
				endif
				
				//Régis Ferreira - Totvs IP Jundiaí 22/12/2023
				//Na tag CDCADAUXILIAR01 pode vir duas situações
				//Situação 1 - Somente o código 2, nesse caso será o código do Serviço mesmo.
				//Situação 2 - 2,16420, nesse caso, o 2 será o código do serviço e o 16420 será o centro de custo que a coleta será considerado.
				cCCColeta := ""
				cFilService:= ""
				if "," $ cCodServ
					cCCColeta := SubStr(cCodServ,rAt(",",cCodServ)+1,len(cCodServ)-1)
				endif
				cCodServ  := Left(cCodServ,1)

				If cCodServ == '1'
					cServ := cCodServ+' - Análises de Combustíveis e/ou Produtos Químicos'
				ElseIf cCodServ == '2'
					if Substr(Alltrim(SM0->M0_CODFIL),1,2) <> '08' .or. Alltrim(SM0->M0_CODFIL) == "0604"
						cServ := cCodServ+' - Análises Ambientais'
					else
						cServ := cCodServ+' - Testes e Análises Técnicas'
					endif
				ElseIf cCodServ == '3'
					cServ := cCodServ+' - Perícias, Laudos, Exames Téc. e An. Técnicas'
				ElseIf cCodServ == '4'
					cServ := cCodServ+' - Ass. ou Cons. de Qualquer Natureza'
				ElseIf cCodServ == '5'
					cServ := cCodServ+' - Serviços de Biologia, Biotecnologia e Qu?ica.'
				Elseif cCodServ == '6'
					cServ := cCodServ+' - Serviços de Qu?ica'
				Else
					//Antes tinha uma retorno falso caso o serviço não fosse informado
					//o Cesar Garcia pediu para sempre ser 2 a partir de agora quando não vier informado
					cCodServ := '2'
					if Substr(Alltrim(SM0->M0_CODFIL),1,2) <> '08' .or. Alltrim(SM0->M0_CODFIL) == "0604"
						cServ := cCodServ+' - Análises Ambientais'
					else
						cServ := cCodServ+' - Testes e Análises Técnicas'
					endif
					//IW_MsgBox(OemToAnsi("O código de Serviço "+cCodServ+" não foi identificado.") , OemToAnsi("Erro") , "ALERT")
					//lCont := .F.
				Endif
				If lCont
					dbSelectArea("SA1")
					dbSetOrder(3)
					If !dbSeek(xFilial("SA1")+cBusca)
						IW_MsgBox(OemToAnsi("Cliente com CNPJ/CPF "+cCNPJCPF+" não se encontra na base de dados.") , OemToAnsi("Erro") , "ALERT")
						lCont := .F.
					Else
						cCodCli  := SA1->A1_COD
						cLojCli  := SA1->A1_LOJA
						cNomeCli := SA1->A1_NOME
						if SA1->A1_MSBLQL == "1"
							IW_MsgBox(OemToAnsi("Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" se encontra bloqueado na base de dados."+CRLF+"Arquivo: "+aFiles[nX,1]) , OemToAnsi("Erro") , "ALERT")
							lCont := .F.
						endif
					Endif
				Endif

				//Régis Ferreira - Totvs IP Jundiaí 22/12/2023
				//Acrescentado o ServiceServer para gravar esse pedido na filial que estiver na tag SERVICECENTER
				if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS , "_SERVICECENTER")
					cFilService := oXML:_DADOS:_AMOSTRAS:_SERVICECENTER:TEXT
				endif
				if Len(FWSM0Util():GetSM0Data( "01" , cFilService , { "M0_CODFIL" } )) <= 0
					lCont := .F.
					MsgStop("TAG SERVICECENTER com conteúdo "+cFilService+". Esse código não é uma Filial válida no Protheus!"+CRLF+"Arquivo: "+aFiles[nX,1],"Verifique")
				endif

				//Régis Ferreira - Totvs IP Jundiai 02/05/2025
				if lCont .and. cFilService <> cFilant
					Loop
				endif

				//Valida se o vendedor está cadastrado e é válido para continuar
				//Régis Ferreira - Totvs IP Jundiaí 18/11/2024
				if lCont
					lCont := GetVendedor(@cVendedor,cCodInvoice) 
				endif

				if Empty(cEmailFat)
					lCont := .F.
					MsgAlert("Não foi informado o e-mail de faturamento. Verifique o e-mail no Mylins"+CRLF+"Invoice: "+cCodInvoice,"Atenção")
				endif

				//Valida se a condição de pagamento está cadastrada e é válida na tabela ZZP para continuar.
				//Régis Ferreira - Totvs IP Jundiaí 18/11/2024
				if lCont
					lCont := GetCondPagto(@cPagtoMylins,cCodInvoice) 
				endif

				If lCont
					nValColet 	:= 0
					nValAmostra := 0
					nValTotAmos := 0
					If Type("oXML:_DADOS:_COLETAS:_COLETA") <> "U"
						If ValType(oXML:_DADOS:_COLETAS:_COLETA) == "A"
							For nB:=1 to Len(oXML:_DADOS:_COLETAS:_COLETA)
								nValColet += Val(oXML:_DADOS:_COLETAS:_COLETA[nB]:_VLDESPESAS:TEXT)
							Next nB
						Else
							nValColet += Val(oXML:_DADOS:_COLETAS:_COLETA:_VLDESPESAS:TEXT)
						Endif
					else
						// ANCHOR alterado por Leandro Cesar 12/09/22
						// NOTE comentado a linha pois os XML de amostra não tem o gripo da tag Coleta;
						// MsgStop("Erro na Importação do XML. O XML não tem a tag Coleta. Converse com o responsável. Código da Invoice: "+cCodInvoice, "Erro")
					Endif
					If Type("oXML:_DADOS:_PROCESSOS:_PROCESSO") <> "U"
						If ValType(oXML:_DADOS:_PROCESSOS:_PROCESSO) == "A"
							For nC:=1 to Len(oXML:_DADOS:_PROCESSOS:_PROCESSO)
								cNumProc   := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NRPROCESSO:TEXT
								cCNPJContr := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_CNPJCON:TEXT
								cNomeContr := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NMEMPRESACON:TEXT
								cContContr := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NMCONTATOCON:TEXT
								cCNPJSolic := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_CNPJSOL:TEXT
								cNomeSolic := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NMEMPRESASOL:TEXT
								cContSolic := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NMCONTATOSOL:TEXT
								cCNPJRepr := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_CNPJREP:TEXT
								cNomeRepr := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NMEMPRESAREP:TEXT
								cContRepr := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NMCONTATOREP:TEXT
								cCNPJFat := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_CNPJFAT:TEXT
								cNomeFat := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NMEMPRESAFAT:TEXT
								cContFat := oXML:_DADOS:_PROCESSOS:_PROCESSO[nC]:_NMCONTATOFAT:TEXT
								aadd(aProcs , { cNumProc, cCNPJContr, cNomeContr, cContContr, cCNPJSolic, cNomeSolic, cContSolic,;
									cCNPJRepr, cNomeRepr, cContRepr, cCNPJFat, cNomeFat, cContFat})
							Next nC
						Else
							cNumProc   := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NRPROCESSO:TEXT
							cCNPJContr := oXML:_DADOS:_PROCESSOS:_PROCESSO:_CNPJCON:TEXT
							cNomeContr := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NMEMPRESACON:TEXT
							cContContr := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NMCONTATOCON:TEXT
							cCNPJSolic := oXML:_DADOS:_PROCESSOS:_PROCESSO:_CNPJSOL:TEXT
							cNomeSolic := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NMEMPRESASOL:TEXT
							cContSolic := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NMCONTATOSOL:TEXT
							cCNPJRepr := oXML:_DADOS:_PROCESSOS:_PROCESSO:_CNPJREP:TEXT
							cNomeRepr := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NMEMPRESAREP:TEXT
							cContRepr := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NMCONTATOREP:TEXT
							cCNPJFat := oXML:_DADOS:_PROCESSOS:_PROCESSO:_CNPJFAT:TEXT
							cNomeFat := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NMEMPRESAFAT:TEXT
							cContFat := oXML:_DADOS:_PROCESSOS:_PROCESSO:_NMCONTATOFAT:TEXT
							aadd(aProcs , { cNumProc, cCNPJContr, cNomeContr, cContContr, cCNPJSolic, cNomeSolic, cContSolic,;
								cCNPJRepr, cNomeRepr, cContRepr, cCNPJFat, cNomeFat, cContFat})
						Endif
					Endif
					If Type("oXML:_DADOS:_AMOSTRAS:_AMOSTRA") <> "U"
						
						if Type("oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA") <> "U"
						
							If ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA) == "A"
								For nA:=1 to Len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA)
									//Regis 05/01/2024
									// ANCHOR alterado por Leandro Cesar 12/09/22
									// NOTE ajustado parar ler o conteudo do campo de valor de despesa do grupo Amostras
									//nValColet += Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_VLDESPESAS:TEXT)
									cNumAmostra := oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_NRAMOSTRA:TEXT
									cNumProcesso:= oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_NRPROCESSO:TEXT
									//nValor    	:= Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA[nA]:_VLTOTAL:TEXT) + nValColet
									cDtColeta 	:= oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_DTCOLETA:TEXT
									cNrGrupo  	:= oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_NRGRUPO:TEXT
									cDtColeta 	:= DtoC(StoD(Substr(StrTran(cDtColeta,"-",""),1,8)))
									cChvUnica 	:= cCodCli+cLojCli+cNumAmostra+cNumProcesso
									//nValColet 	:= 0
									cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])
									cCodAreaSer	:= oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_NRGRUPO:TEXT

									//Régis Ferreira - Totvs IP Jundiaí 22/12/2023
									//Se for o primeiro registro, grava um campo a mais que será o campo da coleta, antes a coleta somado ao valor das amostras e agora vamos separar
									if nA == 1 .and. nValColet > 0 
										aadd(aBrowse ,	{	.F. ,;
										cCodCli,;
										cLojCli,;
										cNomeCli,;
										cNrGrupo,;
										cCodInvoice+"-"+cEnvRet,;
										cNumAmostra,;
										cNumProcesso,;
										cServ,;
										Transform(nValColet,"@E 9,999,999.99"),;
										cDtColeta,;
										cMsgNF,;
										cProdXML,;
										cCCColeta,;
										cEmailFat,;
										cVendedor,;
										cPagtoMylins,;
										cFilService}) 
										nValColet 	:= 0
									endif

									//Guarda o valor total da TAG, caso o valor das amostras não bata com o total, será gerado uma linha com a diferença desse valor
									if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA], "_VLTOTAL")
										nTotAmostra := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_VLTOTAL:TEXT)
									else
										nTotAmostra := 0
									endif

									lCont := ValProd(cProdXML)
										//Regis 05/01/2024
										if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA, "_METHODSERVICEAREAS")
											if ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS) == "A"


												//Rotina responsável por analisar o valor de cada linha da amostra e comparar com o total para avisar o usuário
												nValAmostra := 0
												for nMethodSer := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS)
													if ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD) == "A"
														for nCountMethod := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD)
															nValAmostra  += Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD[nCountMethod]:_VLMETODOS:TEXT)
														Next nCountMethod
													else
														nValAmostra  += Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD:_VLMETODOS:TEXT)
													endif
												Next nMethodSer

												if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA], "_VLTOTAL")
													nValTotAmos := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_VLTOTAL:TEXT)
												endif
												if nValAmostra <> nValTotAmos .and. abs(nValAmostra - nValTotAmos) > 1 .and. lMsgDifer
													MsgAlert("Arquivo: "+aFiles[nX,1]+CRLF+;
													"Amostra: "+oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_CDAMOSTRA:TEXT+CRLF+;
													"Soma do valor na Amostra: "+Transform(nValAmostra,PesqPict("SC6","C6_VALOR"))+CRLF+;
													"Total da Amostra: "+Transform(nValTotAmos,PesqPict("SC6","C6_VALOR")),"Atenção")
												endif

												for nMethodSer := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS)
													cMetodos	:= Padr(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREA:TEXT,TamSx3("ZZO_AMOSTR")[1])
													cProdXML 	:= Padr(Alltrim(GetAdvfVal("ZZO","ZZO_PROD",xFilial("ZZO")+cMetodos,1,"")),TamSx3("B1_COD")[1])
													if lMetodo
														if Empty(cProdXML)
															ValMetodo(cMetodos,aFiles[nX,1])
															lCont := .F.
															lMetodo := .F.
														else
															lCont := ValProd(cProdXML)
														endif
													else
														lCont := .F.
													endif
													if lCont
														if ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD) == "A"

															for nCountMethod := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD)
																
																nValor 	:= Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD[nCountMethod]:_VLMETODOS:TEXT)

																aadd(aBrowse ,	{	.F. ,;
																	cCodCli,;
																	cLojCli,;
																	cNomeCli,;
																	cNrGrupo,;
																	cCodInvoice+"-"+cEnvRet,;
																	cNumAmostra,;
																	cNumProcesso,;
																	cServ,;
																	Transform(nValor,"@E 9,999,999.99"),;
																	cDtColeta,;
																	cMsgNF,;
																	cProdXML,;
																	"",;
																	cEmailFat,;
																	cVendedor,;
																	cPagtoMylins,;
																	cFilService})
																aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
																nTotAmostra := nTotAmostra - nValor
															Next nCountMethod
														else

															aadd(aBrowse ,	{	.F. ,;
																	cCodCli,;
																	cLojCli,;
																	cNomeCli,;
																	cNrGrupo,;
																	cCodInvoice+"-"+cEnvRet,;
																	cNumAmostra,;
																	cNumProcesso,;
																	cServ,;
																	Transform(nValor,"@E 9,999,999.99"),;
																	cDtColeta,;
																	cMsgNF,;
																	cProdXML,;
																	"",;
																	cEmailFat,;
																	cVendedor,;
																	cPagtoMylins,;
																	cFilService})
																	aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
															nTotAmostra := nTotAmostra - nValor
														endif
													endif
												Next nMethodSer
												//Se nTotAmostra for maior que zero, será feito a diferença do valor, somando as amostras e abatendo o valor total dela
												if nTotAmostra > 0 .and. lCont
													cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])
													aadd(aBrowse ,	{	.F. ,;
																				cCodCli,;
																				cLojCli,;
																				cNomeCli,;
																				cNrGrupo,;
																				cCodInvoice+"-"+cEnvRet,;
																				cNumAmostra,;
																				cNumProcesso,;
																				cServ,;
																				Transform(nTotAmostra,"@E 9,999,999.99"),;
																				cDtColeta,;
																				cMsgNF,;
																				cProdXML,;
																				"",;
																				cEmailFat,;
																				cVendedor,;
																				cPagtoMylins,;
																				cFilService})
													nTotAmostra := nTotAmostra - nTotAmostra
												endif
											else
												cMetodos	:= Padr(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREA:TEXT,TamSx3("ZZO_AMOSTR")[1])
												cProdXML 	:= Padr(Alltrim(GetAdvfVal("ZZO","ZZO_PROD",xFilial("ZZO")+cMetodos,1,"")),TamSx3("B1_COD")[1])
												if lMetodo
													if Empty(cProdXML)
														ValMetodo(cMetodos,aFiles[nX,1])
														lCont := .F.
														lMetodo := .F.
													else
														lCont := ValProd(cProdXML)
													endif
												else
													lCont := .F.
												endif
												if lCont
													if ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD) == "A"

														//Rotina responsável por analisar o valor de cada linha da amostra e comparar com o total para avisar o usuário
														nValAmostra := 0
														for nCountMethod := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD)
															nValAmostra += Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD[nCountMethod]:_VLMETODOS:TEXT)
														Next nCountMethod

														if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA], "_VLTOTAL")
															nValTotAmos := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_VLTOTAL:TEXT)
														endif
														if nValAmostra <> nValTotAmos .and. abs(nValAmostra - nValTotAmos) > 1 .and. lMsgDifer
															MsgAlert("Arquivo: "+aFiles[nX,1]+CRLF+;
															"Amostra: "+oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_CDAMOSTRA:TEXT+CRLF+;
															"Soma do valor na Amostra: "+Transform(nValAmostra,PesqPict("SC6","C6_VALOR"))+CRLF+;
															"Total da Amostra: "+Transform(nValTotAmos,PesqPict("SC6","C6_VALOR")),"Atenção")
														endif
														
														for nCountMethod := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD)
															nValor 	:= Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD[nCountMethod]:_VLMETODOS:TEXT)

															aadd(aBrowse ,	{	.F. ,;
																cCodCli,;
																cLojCli,;
																cNomeCli,;
																cNrGrupo,;
																cCodInvoice+"-"+cEnvRet,;
																cNumAmostra,;
																cNumProcesso,;
																cServ,;
																Transform(nValor,"@E 9,999,999.99"),;
																cDtColeta,;
																cMsgNF,;
																cProdXML,;
																"",;
																cEmailFat,;
																cVendedor,;
																cPagtoMylins,;
																cFilService})
															aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
															nTotAmostra := nTotAmostra - nValor
														Next nCountMethod
													else
														nValor := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD:_VLMETODOS:TEXT)
														
														//Mensagem de avisa sobre o valor da soma das amostras não bater com o valor total da amostra, somente um AVISO
														nValAmostra := 0
														nValAmostra += nValor
														if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA], "_VLTOTAL")
															nValTotAmos := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_VLTOTAL:TEXT)
														endif
														if nValAmostra <> nValTotAmos .and. abs(nValAmostra - nValTotAmos) > 1 .and. lMsgDifer
															MsgAlert("Arquivo: "+aFiles[nX,1]+CRLF+;
															"Amostra: "+oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_CDAMOSTRA:TEXT+CRLF+;
															"Soma do valor na Amostra: "+Transform(nValAmostra,PesqPict("SC6","C6_VALOR"))+CRLF+;
															"Total da Amostra: "+Transform(nValTotAmos,PesqPict("SC6","C6_VALOR")),"Atenção")
														endif

														aadd(aBrowse ,	{	.F. ,;
																cCodCli,;
																cLojCli,;
																cNomeCli,;
																cNrGrupo,;
																cCodInvoice+"-"+cEnvRet,;
																cNumAmostra,;
																cNumProcesso,;
																cServ,;
																Transform(nValor,"@E 9,999,999.99"),;
																cDtColeta,;
																cMsgNF,;
																cProdXML,;
																"",;
																cEmailFat,;
																cVendedor,;
																cPagtoMylins,;
																cFilService})
																aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
																nTotAmostra := nTotAmostra - nValor
													endif
													//Se nTotAmostra for maior que zero, será feito a diferença do valor, somando as amostras e abatendo o valor total dela
													if nTotAmostra > 0
														cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])
														aadd(aBrowse ,	{	.F. ,;
																					cCodCli,;
																					cLojCli,;
																					cNomeCli,;
																					cNrGrupo,;
																					cCodInvoice+"-"+cEnvRet,;
																					cNumAmostra,;
																					cNumProcesso,;
																					cServ,;
																					Transform(nTotAmostra,"@E 9,999,999.99"),;
																					cDtColeta,;
																					cMsgNF,;
																					cProdXML,;
																					"",;
																					cEmailFat,;
																					cVendedor,;
																					cPagtoMylins,;
																					cFilService})
														nTotAmostra := nTotAmostra - nTotAmostra
													endif
												endif
											endif
										else
											cNumAmostra := oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_NRAMOSTRA:TEXT
											cNumProcesso:= oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_NRPROCESSO:TEXT
											nValColet 	:= Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_VLTOTAL:TEXT)
											cDtColeta 	:= oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_DTCOLETA:TEXT
											cNrGrupo  	:= oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_NRGRUPO:TEXT
											cDtColeta 	:= DtoC(StoD(Substr(StrTran(cDtColeta,"-",""),1,8)))
											cChvUnica 	:= cCodCli+cLojCli+cNumAmostra+cNumProcesso
											//nValColet 	:= 0
											cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])
											cCodAreaSer	:= oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA[nA]:_NRGRUPO:TEXT

												aadd(aBrowse ,	{	.F. ,;
													cCodCli,;
													cLojCli,;
													cNomeCli,;
													cNrGrupo,;
													cCodInvoice+"-"+cEnvRet,;
													cNumAmostra,;
													cNumProcesso,;
													cServ,;
													Transform(nValColet,"@E 9,999,999.99"),;
													cDtColeta,;
													cMsgNF,;
													cProdXML,;
													cCCColeta,;
													cEmailFat,;
													cVendedor,;
													cPagtoMylins,;
													cFilService})
												nTotAmostra := nTotAmostra - nValColet
												nValColet 	:= 0
												aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
												
										endif									
										//Se nTotAmostra for maior que zero, será feito a diferença do valor, somando as amostras e abatendo o valor total dela
										if nA == Len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA) .and. nTotAmostra > 0
											cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])
											aadd(aBrowse ,	{	.F. ,;
																		cCodCli,;
																		cLojCli,;
																		cNomeCli,;
																		cNrGrupo,;
																		cCodInvoice+"-"+cEnvRet,;
																		cNumAmostra,;
																		cNumProcesso,;
																		cServ,;
																		Transform(nTotAmostra,"@E 9,999,999.99"),;
																		cDtColeta,;
																		cMsgNF,;
																		cProdXML,;
																		"",;
																		cEmailFat,;
																		cVendedor,;
																		cPagtoMylins,;
																		cFilService})
											nTotAmostra := nTotAmostra - nTotAmostra
										endif

								Next nA
							Else
								// ANCHOR alterado por Leandro Cesar 12/09/22
								// NOTE ajustado parar ler o conteudo do campo de valor de despesa do grupo Amostras
								//nValColet += Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_VLDESPESAS:TEXT)
								cNumAmostra  := oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_NRAMOSTRA:TEXT
								cNumProcesso := oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_NRPROCESSO:TEXT
								//nValor    := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_VLTOTAL:TEXT) + nValColet
								cDtColeta := oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_DTCOLETA:TEXT
								cNrGrupo  := oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_NRGRUPO:TEXT
								cDtColeta := DtoC(StoD(Substr(StrTran(cDtColeta,"-",""),1,8)))
								cChvUnica := cCodCli+cLojCli+cNumAmostra+cNumProcesso
								cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])
								lCont := ValProd(cProdXML)

								//Régis Ferreira - Totvs IP Jundiaí 22/12/2023
								//Se for o primeiro registro, grava um campo a mais que será o campo da coleta, antes a coleta somado ao valor das amostras e agora vamos separar
								if nValColet >0 
									aadd(aBrowse ,	{	.F. ,;
									cCodCli,;
									cLojCli,;
									cNomeCli,;
									cNrGrupo,;
									cCodInvoice+"-"+cEnvRet,;
									cNumAmostra,;
									cNumProcesso,;
									cServ,;
									Transform(nValColet,"@E 9,999,999.99"),;
									cDtColeta,;
									cMsgNF,;
									cProdXML,;
									cCCColeta,;
									cEmailFat,;
									cVendedor,;
									cPagtoMylins,;
									cFilService})
								endif
								nValColet := 0

								//Guarda o valor total da TAG, caso o valor das amostras não bata com o total, será gerado uma linha com a diferença desse valor
								if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA, "_VLTOTAL")
									nTotAmostra := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_VLTOTAL:TEXT)
								else
									nTotAmostra := 0
								endif

								if !AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA, "_METHODSERVICEAREAS")
									MsgAlert("A TAG METHODSERVICEAREAS não existe no arquivo! Arquivo: "+aFiles[nX,1],"Atenção")
								else
									if ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS) == "A"

										//Rotina responsável por analisar o valor de cada linha da amostra e comparar com o total para avisar o usuário
										nValAmostra := 0
										for nMethodSer := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS)
											if ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD) == "A"
												For nCountMethod := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD)
														nValAmostra += Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD[nCountMethod]:_VLMETODOS:TEXT)
												Next nCountMethod
											else
												nValAmostra += Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD:_VLMETODOS:TEXT)
											endif
										Next nMethodSer

										if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA, "_VLTOTAL")
											nValTotAmos := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_VLTOTAL:TEXT)
										endif
										if nValAmostra <> nValTotAmos .and. abs(nValAmostra - nValTotAmos) > 1 .and. lMsgDifer
											MsgAlert("Arquivo: "+aFiles[nX,1]+CRLF+;
											"Amostra: "+oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_CDAMOSTRA:TEXT+CRLF+;
											"Soma do valor na Amostra: "+Transform(nValAmostra,PesqPict("SC6","C6_VALOR"))+CRLF+;
											"Total da Amostra: "+Transform(nValTotAmos,PesqPict("SC6","C6_VALOR")),"Atenção")
										endif

										for nMethodSer := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS)
											cMetodos	:= Padr(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREA:TEXT,TamSx3("ZZO_AMOSTR")[1])
											cProdXML 	:= Padr(Alltrim(GetAdvfVal("ZZO","ZZO_PROD",xFilial("ZZO")+cMetodos,1,"")),TamSx3("B1_COD")[1])
											if lMetodo
												if Empty(cProdXML)
													ValMetodo(cMetodos,aFiles[nX,1])
													lCont := .F.
													lMetodo := .F.
												else
													lCont := ValProd(cProdXML)
												endif
											else
												lCont := .F.
											endif

											if lCont
												if ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD) == "A"

													for nCountMethod := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD)
														nValor 	:= Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD[nCountMethod]:_VLMETODOS:TEXT)

														aadd(aBrowse ,	{	.F. ,;
															cCodCli,;
															cLojCli,;
															cNomeCli,;
															cNrGrupo,;
															cCodInvoice+"-"+cEnvRet,;
															cNumAmostra,;
															cNumProcesso,;
															cServ,;
															Transform(nValor,"@E 9,999,999.99"),;
															cDtColeta,;
															cMsgNF,;
															cProdXML,;
															"",;
															cEmailFat,;
															cVendedor,;
															cPagtoMylins,;
															cFilService})
														aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
														nTotAmostra := nTotAmostra - nValor
													Next nCountMethod
												else
													nValor := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS[nMethodSer]:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD:_VLMETODOS:TEXT)

													aadd(aBrowse ,	{	.F. ,;
															cCodCli,;
															cLojCli,;
															cNomeCli,;
															cNrGrupo,;
															cCodInvoice+"-"+cEnvRet,;
															cNumAmostra,;
															cNumProcesso,;
															cServ,;
															Transform(nValor,"@E 9,999,999.99"),;
															cDtColeta,;
															cMsgNF,;
															cProdXML,;
															"",;
															cEmailFat,;
															cVendedor,;
															cPagtoMylins,;
															cFilService})
															aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
													nTotAmostra := nTotAmostra - nValor
												endif
											endif

											if lCont
												//Se nTotAmostra for maior que zero, será feito a diferença do valor, somando as amostras e abatendo o valor total dela
												if nMethodSer == len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS) .and. nTotAmostra > 0
													cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])
													aadd(aBrowse ,	{	.F. ,;
																				cCodCli,;
																				cLojCli,;
																				cNomeCli,;
																				cNrGrupo,;
																				cCodInvoice+"-"+cEnvRet,;
																				cNumAmostra,;
																				cNumProcesso,;
																				cServ,;
																				Transform(nTotAmostra,"@E 9,999,999.99"),;
																				cDtColeta,;
																				cMsgNF,;
																				cProdXML,;
																				"",;
																				cEmailFat,;
																				cVendedor,;
																				cPagtoMylins,;
																				cFilService})
													nTotAmostra := nTotAmostra - nTotAmostra
												endif
											endif
										Next nMethodSer
									else
										cMetodos	:= Padr(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREA:TEXT,TamSx3("ZZO_AMOSTR")[1])
										cProdXML 	:= Padr(Alltrim(GetAdvfVal("ZZO","ZZO_PROD",xFilial("ZZO")+cMetodos,1,"")),TamSx3("B1_COD")[1])
										if lMetodo
											if Empty(cProdXML)
												ValMetodo(cMetodos,aFiles[nX,1])
												lCont := .F.
												lMetodo := .F.
											else
												lCont := ValProd(cProdXML)
											endif
										else
											lCont := .F.
										endif
										if lCont
											if ValType(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD) == "A"

												nValAmostra := 0
												for nCountMethod := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD)
													nValAmostra	+= Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD[nCountMethod]:_VLMETODOS:TEXT)
												Next nCountMethod
												if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA, "_VLTOTAL")
													nValTotAmos := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_VLTOTAL:TEXT)
												endif
												if nValAmostra <> nValTotAmos .and. abs(nValAmostra - nValTotAmos) > 1 .and. lMsgDifer
													MsgAlert("Arquivo: "+aFiles[nX,1]+CRLF+;
													"Amostra: "+oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_CDAMOSTRA:TEXT+CRLF+;
													"Soma do valor na Amostra: "+Transform(nValTotAmos,PesqPict("SC6","C6_VALOR"))+CRLF+;
													"Total da Amostra: "+Transform(nValAmostra,PesqPict("SC6","C6_VALOR")),"Atenção")
												endif

												for nCountMethod := 1 to len(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD)
													nValor 	:= Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD[nCountMethod]:_VLMETODOS:TEXT)											

													aadd(aBrowse ,	{	.F. ,;
														cCodCli,;
														cLojCli,;
														cNomeCli,;
														cNrGrupo,;
														cCodInvoice+"-"+cEnvRet,;
														cNumAmostra,;
														cNumProcesso,;
														cServ,;
														Transform(nValor,"@E 9,999,999.99"),;
														cDtColeta,;
														cMsgNF,;
														cProdXML,;
														"",;
														cEmailFat,;
														cVendedor,;
														cPagtoMylins,;
														cFilService})
													aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
													nTotAmostra := nTotAmostra - nValor
												Next nCountMethod
											else
												nValor := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_AMOSTRAMETHODSERVICEAREA:_METHODSERVICEAREAS:_METHODSERVICEAREASMETHOD:_METHODSERVICEAREASMETHOD:_VLMETODOS:TEXT)

												//Mensagem de avisa sobre o valor da soma das amostras não bater com o valor total da amostra, somente um AVISO
												nValAmostra := 0
												nValAmostra += nValor
												if AttIsMemberOf(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA, "_VLTOTAL")
													nValTotAmos := Val(oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_VLTOTAL:TEXT)
												endif
												if nValAmostra <> nValTotAmos .and. abs(nValAmostra - nValTotAmos) > 1 .and. lMsgDifer
													MsgAlert("Arquivo: "+aFiles[nX,1]+CRLF+;
													"Amostra: "+oXML:_DADOS:_AMOSTRAS:_AMOSTRA:_AMOSTRA:_CDAMOSTRA:TEXT+CRLF+;
													"Soma do valor na Amostra: "+Transform(nValTotAmos,PesqPict("SC6","C6_VALOR"))+CRLF+;
													"Total da Amostra: "+Transform(nValAmostra,PesqPict("SC6","C6_VALOR")),"Atenção")
												endif
												
												aadd(aBrowse ,	{	.F. ,;
														cCodCli,;
														cLojCli,;
														cNomeCli,;
														cNrGrupo,;
														cCodInvoice+"-"+cEnvRet,;
														cNumAmostra,;
														cNumProcesso,;
														cServ,;
														Transform(nValor,"@E 9,999,999.99"),;
														cDtColeta,;
														cMsgNF,;
														cProdXML,;
														"",;
														cEmailFat,;
														cVendedor,;
														cPagtoMylins,;
														cFilService})
														aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
														nTotAmostra := nTotAmostra - nValor
											endif
										endif

										//Se nTotAmostra for maior que zero, será feito a diferença do valor, somando as amostras e abatendo o valor total dela
										if nTotAmostra > 0 .and. lCont
											cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])
											aadd(aBrowse ,	{	.F. ,;
																		cCodCli,;
																		cLojCli,;
																		cNomeCli,;
																		cNrGrupo,;
																		cCodInvoice+"-"+cEnvRet,;
																		cNumAmostra,;
																		cNumProcesso,;
																		cServ,;
																		Transform(nTotAmostra,"@E 9,999,999.99"),;
																		cDtColeta,;
																		cMsgNF,;
																		cProdXML,;
																		"",;
																		cEmailFat,;
																		cVendedor,;
																		cPagtoMylins,;
																		cFilService})
											nTotAmostra := nTotAmostra - nTotAmostra
										endif
									endif
								endif
							Endif
						else
							cChvUnica 	:= cCodCli+cLojCli+cNumAmostra+cNumProcesso
							cProdXML  	:= Padr("09000.000"+SubStr(cServ,1,1),TamSx3("B1_COD")[1])

							//Régis Ferreira - Totvs IP Jundiaí 22/12/2023
							//Se for o primeiro registro, grava um campo a mais que será o campo da coleta, antes a coleta somado ao valor das amostras e agora vamos separar
							aadd(aBrowse ,	{	.F. ,;
							cCodCli,;
							cLojCli,;
							cNomeCli,;
							cNrGrupo,;
							cCodInvoice+"-"+cEnvRet,;
							cNumAmostra,;
							cNumProcesso,;
							cServ,;
							Transform(nValColet,"@E 9,999,999.99"),;
							cDtColeta,;
							cMsgNF,;
							cProdXML,;
							cCCColeta,;
							cEmailFat,;
							cVendedor,;
							cPagtoMylins,;
							cFilService})
							nValColet 	:= 0
                            aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
						endif
					Else
						If Type("oXML:_DADOS:_COLETAS:_COLETA") <> "U"
							If ValType(oXML:_DADOS:_COLETAS:_COLETA) == "A"
								For nB:=1 to Len(oXML:_DADOS:_COLETAS:_COLETA)
									cNumAmostra  := ""
									cNumProcesso := oXML:_DADOS:_COLETAS:_COLETA[nB]:_NRPROCESSO:TEXT
									nValor       := nValColet
									cDtColeta    := oXML:_DADOS:_COLETAS:_COLETA[nB]:_DTCOLETA:TEXT
									cDtColeta    := DtoC(StoD(Substr(StrTran(cDtColeta,"-",""),1,8)))
									cNrGrupo := ""
									cChvUnica := cCodCli+cLojCli+cNumAmostra+cNumProcesso
									//nValColet := 0
									aadd(aBrowse ,	{	.F. ,;
										cCodCli,;
										cLojCli,;
										cNomeCli,;
										cNrGrupo,;
										cCodInvoice+"-"+cEnvRet,;
										cNumAmostra,;
										cNumProcesso,;
										cServ,;
										Transform(nValor,"@E 9,999,999.99"),;
										cDtColeta,;
										cMsgNF})
									aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
								Next nB
							Else
								cNumAmostra  := ""
								cNumProcesso := oXML:_DADOS:_COLETAS:_COLETA:_NRPROCESSO:TEXT
								nValor       := nValColet
								cDtColeta    := oXML:_DADOS:_COLETAS:_COLETA:_DTCOLETA:TEXT
								cDtColeta    := DtoC(StoD(Substr(StrTran(cDtColeta,"-",""),1,8)))
								cNrGrupo := ""
								cChvUnica := cCodCli+cLojCli+cNumAmostra+cNumProcesso
								aadd(aBrowse ,	{	.F. ,;
									cCodCli,;
									cLojCli,;
									cNomeCli,;
									cNrGrupo,;
									cCodInvoice+"-"+cEnvRet,;
									cNumAmostra,;
									cNumProcesso,;
									cServ,;
									Transform(nValor,"@E 9,999,999.99"),;
									cDtColeta,;
									cMsgNF})
								aadd(aArqOk , {	.F. , cChvUnica , aFiles[nX,1] })
							Endif
						else
							MsgStop("")
						endif
					Endif
				Endif
			Endif
		Next nX
		
		if lCont

			If Len(aBrowse) > 0
				lCont := .F.
				DEFINE DIALOG oDlg TITLE "Seleção de Registros" FROM 167,140 TO 530,1290 PIXEL
				oBrowse := TWBrowse():New( 01,01,500,180,,{'','Código','Loja','Nome Cliente','Num. Grupo','C. Invoice','N. Amostra','N. Processo','Serviço','Valor','Data Coleta','Mensagem','Tipo Produto','C.Custo','E-mail',"Vendedor","Cond.Pagto","Filial"},{05,25,10,130,40,40,60,60,130,40,35,60,60,40,60,40,40},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
				oBrowse:SetArray(aBrowse)
				oBrowse:bLine:= {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07],aBrowse[oBrowse:nAt,08],aBrowse[oBrowse:nAt,09],aBrowse[oBrowse:nAt,10],aBrowse[oBrowse:nAt,11],aBrowse[oBrowse:nAt,12],aBrowse[oBrowse:nAt,13],aBrowse[oBrowse:nAt,14],aBrowse[oBrowse:nAt,15],aBrowse[oBrowse:nAt,16],aBrowse[oBrowse:nAt,17],aBrowse[oBrowse:nAt,18] } }
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?So permite marcar codigos iguais de cliente+loja.                ?
				//?Se estiver tudo certo, troca a imagem no duplo click do mouse    ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//oBrowse:bLDblClick := {|| Iif( fValBrow( aBrowse , oBrowse:nAt ) , oBrowse:DrawSelect() , Nil ) }
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?So permite marcar um codigo e desmarca outra caixa que estiver   ?
				//?marcada.                                                         ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//oBrowse:bLDblClick := {|| If(nField <> oBrowse:nAt,(aBrowse[nField][1] := .F.,nField := oBrowse:nAt,aBrowse[nField][1] := .T.,oBrowse:Refresh()),)}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Marca todos os itens sem criar validacao                         ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],oBrowse:DrawSelect()}
				oBrowse:bHeaderClick := {|| Marcar(oBrowse)}
				@ 010,512 BUTTON "  O K   " SIZE 040,012 PIXEL OF oDlg Action(lCont:=.T.,oDlg:End()) // TOOLTIP "Ok"
				@ 030,512 BUTTON "Cancelar" SIZE 040,012 PIXEL OF oDlg Action(lCont:=.F.,oDlg:End()) // TOOLTIP "Cancelar"
				@ 050,512 BUTTON "  Excel " SIZE 040,012 PIXEL OF oDlg Action(U_GeraExcel(aCabExcel,aBrowse),oBrowse:Refresh()) // TOOLTIP "Envia dados para o Excel"
				//@ 070,512 BUTTON "Excluir"  SIZE 040,012 PIXEL OF oDlg Action(U_Excluir(@aBrowse,oConExt,oOK,oNO),oBrowse:Refresh()) // TOOLTIP "Excluir registros"
				ACTIVATE DIALOG oDlg CENTERED
				If lCont
					ProcRegua(Len(aBrowse))
					For nA:=1 to Len(aBrowse)
						IncProc("Processando as informações selecionadas e gerando os pedidos...")
						If aBrowse[nA,1] // O registro esta selecionado

							//troca a filial
							//cFilService := aBrowse[nA,18]

							cCodCli 	:= aBrowse[nA,2]
							cLojCli 	:= aBrowse[nA,3]
							cAmost  	:= aBrowse[nA,7]
							cProces 	:= aBrowse[nA,8]
							//cProd   := Substr(aBrowse[nA,9],1,1)
							cProd		:= aBrowse[nA,13]
							nPreco  	:= Val(StrTran(StrTran(aBrowse[nA,10],".",""),",","."))
							dDtRecebe 	:= CtoD(aBrowse[nA,11])
							cCodInv 	:= aBrowse[nA,6]
							cMsgNF  	:= aBrowse[nA,12]
							cNrGrupo	:= aBrowse[nA,5]
							cCC_PRD		:= aBrowse[nA,14]
							lCliOK 		:= .T.
							dbSelectArea("SA1")
							dbSetOrder(1)
							If !dbSeek(xFilial("SA1")+cCodCli+cLojCli)
								If Len(aLogErro) > 0
									aadd(aLogErro , "." )
								Endif
								MsgAlert("O código/Loja do Cliente "+cCodCli+"/"+cCodCli+" não está na base do Protheus. O pedido não foi incluído." )
								lCliOK := .F.
							Else
								If SA1->A1_MSBLQL == '1' // 1=bloqueado
									If Len(aLogErro) > 0
										aadd(aLogErro , "." )
									Endif
									MsgAlert("O código/Loja do Cliente "+cCodCli+"/"+cCodCli+" está bloqueado. O pedido não foi incluído." )
									lCliOK := .F.
								Endif
							Endif
							If lCliOk
								aadd(aDados , { 	cCodCli		, cLojCli	,;
									cProd		, 1			,;
									nPreco		, cProces   ,;
									cAmost 		, dDtRecebe	,;
									cCodInv		, cMsgNF	,;
									cNrGrupo	, cCC_PRD,;
									aBrowse[nA,15],aBrowse[nA,16],aBrowse[nA,17],;//E-mail, vendedor e condição Pagto
									cFilService}) 
								nLoc := aScan(aArqOk , {|z| z[2] == aBrowse[nA,2]+aBrowse[nA,3]+aBrowse[nA,7]+aBrowse[nA,8]})
								If nLoc > 0
									aArqOk[nLoc,1] := .T. // Marco o registro para descartar o XML
								Endif
							Endif
						Endif
					Next nA
					/*
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//?Estrutura do array aDados                			?
					//?    -----------------                    			?
					//?			1  Codigo Cliente para Faturamento		?
					//?			2  Loja Cliente para Faturamento		?
					//?			3  Codigo do produto  					?
					//?			4  Quantidade  							?
					//?			5  Valor total  						?
					//?			6  Processo              				?
					//?			7  Cod da amostra        				?
					//?			8  Data do Recebimento   				?
					//?			9  Codigo da Invoice + Envia Retorno 	?
					//?                                   (0=Sim 1=Nao)    ?
					//?		   10  Mensagem para Nota fiscal	        ?
					//?		   11  Numero do Grupo de Amostra           ?
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					*/
					If Len(aDados) > 0
						aadd(aDados , {	"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
							"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
							"ZZZ" , "ZZZ" , "ZZZ","ZZZ","ZZZ","ZZZ"})
						aSort(aDados,,, { |x,y| x[16]+x[1]+x[2]+x[6]+x[9] < y[16]+y[1]+y[2]+y[6]+y[9] })  // Codigo Cliente + Loja Cliente + Processo + Cod Invoice
						ProcRegua(Len(aDados))
						For t:=1 to Len(aDados)
							IncProc("Gerando Pedidos de Venda...")
							If cAglut # aDados[t][16]+aDados[t][1]+aDados[t][2]+aDados[t][6]+aDados[t][9]

								/*//Troca a filial
								if Empty(cAglut)
									cFilAnt := aDados[t][16]
								endif*/

								If Len(aCabec) > 0 .and. Len(aTotItens) > 0
									lMsErroAuto := .F.
									Begin Transaction
										MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aTotItens,3)
										If lMsErroAuto
											MostraErro()
											//cErro := MemoRead(NomeAutoLog())
											DisarmTransaction()
											Break
										Endif
									End Transaction

									/*if cFilAnt <> aDados[t][16]
										cFilAnt := aDados[t][16]
									endif*/
	
									aCabec    := {}
									aTotItens := {}
									aItens    := {}
								Endif
								If aDados[t][1] == "ZZZ"
									Exit
								Else
									cAglut    := aDados[t][16]+aDados[t][1]+aDados[t][2]+aDados[t][6]+aDados[t][9]
									cEmailNfe := ""
									cVendedor := ""
									cPagtoMylins := ""
									cMenNota  := aDados[t][10]
								Endif
								dbSelectArea("SA1")
								dbSetOrder(1)
								dbSeek(xFilial("SA1")+aDados[t][1]+aDados[t][2])
								cTipoCli  := SA1->A1_TIPO
								cEstCli   := SA1->A1_EST
								cCondPag  := SA1->A1_COND
								cCliente  := SA1->A1_COD
								cLjCli    := SA1->A1_LOJA
								cNomeFant := SA1->A1_NREDUZ
								cMunCli   := SA1->A1_MUN
								cEmailNfe := aDados[t][13]
								cVendedor := aDados[t][14]
								cPagtoMylins := aDados[t][15]
								cFilService:= aDados[t][16]
								cVend     := SA1->A1_VEND
								dEmissao   := dDataBase
								nMoeda     := 1
								cAnalise   := aDados[t][6]
								cCodAmos   := aDados[t][7]
								dDtRecebe  := aDados[t][8]
								dDtEntrega := DataValida(dDataBase,.T.)
								cCodInv    := aDados[t][9]
								nNumProc   := aScan(aProcs , {|x| x[1] == cAnalise})
								If nNumProc > 0
									cCNPJContr := aProcs[nNumProc][2]
									cNomeContr := aProcs[nNumProc][3]
									cContContr := aProcs[nNumProc][4]
									cCNPJSolic := aProcs[nNumProc][5]
									cNomeSolic := aProcs[nNumProc][6]
									cContSolic := aProcs[nNumProc][7]
									cCNPJRepr  := aProcs[nNumProc][8]
									cNomeRepr  := aProcs[nNumProc][9]
									cContRepr  := aProcs[nNumProc][10]
									cCNPJFat   := aProcs[nNumProc][11]
									cNomeFat   := aProcs[nNumProc][12]
									cContFat   := aProcs[nNumProc][13]
								Endif
								If !Empty(cMenNota)
									cMenNota += " "
								Endif
								aCabec := {	{"C5_TIPO"		, "N"			,	NIL},;
									{"C5_CLIENTE"	, cCliente		,	NIL},;
									{"C5_LOJACLI"	, cLjCli		,	NIL},;
									{"C5_CLIENT"	, cCliente		,	NIL},;
									{"C5_LOJAENT"	, cLjCli		,	NIL},;
									{"C5_NFANT"		, cNomeFant		,	NIL},;
									{"C5_MUNIC"		, cMunCli		,	NIL},;
									{"C5_CLAUDO"	, cCliente		,	NIL},;
									{"C5_LLAUDO"	, cLjCli		,	NIL},;
									{"C5_TIPCERT"	, "N"			,	NIL},;
									{"C5_VEND1"		, cVendedor		,	NIL},; //Trocado o código do vendedor conforme vem no XML {"C5_VEND1"		, cVend			,	NIL},;
									{"C5_NROCERT"	, cAnalise		,	NIL},;
									{"C5_KM"		, 0				,	NIL},;
									{"C5_TIPOCLI"	, cTipoCli		,	NIL},;
									{"C5_CONDPAG"	, cPagtoMylins	,	NIL},; //trocado a condição de pagamento conforme vem no XML {"C5_CONDPAG"	, cCondPag		,	NIL},;
									{"C5_XDTENT"	, dDtEntrega	,	NIL},;
									{"C5_MOEDA"		, nMoeda		,	NIL},;
									{"C5_TXMOEDA"	, 1				,	NIL},;
									{"C5_XTEMPO"	, "P"			,	NIL},;
									{"C5_TIPLIB"	, "2"			,	NIL},;
									{"C5_TABELA"	, Space(3)		,	NIL},;
									{"C5_TPCARGA"	, "2"			,	NIL},;
									{"C5_DATAPED"	, dDataBase		,	NIL},;
									{"C5_DATAREC"	, dDtRecebe		,	NIL},;
									{"C5_DATAENV"	, dDtRecebe		,	NIL},;
									{"C5_MENNOTA"	, cMenNota    	,	NIL},;
									{"C5_NFEMAIL"	, cEmailNfe    	,	NIL},; //Trocado para o e-mail que vem no XML e não mais o que está no cadastro do cliente {"C5_NFEMAIL"	, cEmailNfe    	,	NIL},;
									{"C5_ZZNFMAI"	, cEmailNfe    	,	NIL},; //Não estava sendo alimentado esse campo, acrescenti a pedido da Renata
									{"C5_ZZCODIN"	, cCodInv    	,	NIL},;
									{"C5_EMISSAO"	, dEmissao		,	NIL},;
									{"C5_XCNPJCO"	, cCNPJContr	,	NIL},;
									{"C5_XNOMECO"	, cNomeContr	,	NIL},;
									{"C5_XCONTCO"	, cContContr	,	NIL},;
									{"C5_XCNPJSO"	, cCNPJSolic	,	NIL},;
									{"C5_XNOMESO"	, cNomeSolic	,	NIL},;
									{"C5_XCONTSO"	, cContSolic	,	NIL},;
									{"C5_XCNPJRE"	, cCNPJRepr		,	NIL},;
									{"C5_XNOMERE"	, cNomeRepr		,	NIL},;
									{"C5_XCONTRE"	, cContRepr		,	NIL},;
									{"C5_XCNPJFA"	, cCNPJFat		,	NIL},;
									{"C5_XNOMEFA"	, cNomeFat		,	NIL},;
									{"C5_XCONTFA"	, cContFat		,	NIL}}
							Endif
							If Len(aCabec) > 0
								aItens   := {}
								//cProduto := "09000.000"+aDados[t][3]
								//Régis Ferreira - 27/12/2023
								//o código do produto agora está dentro do aDados (Browser)
								cProduto := aDados[t][3]
								cOrigAn  := "I"
								cRevCert := "01"
								nQtdVen  := aDados[t][4] 			// Quantidade
								nPrecVen := Round(aDados[t][5],2) 	// Preco Unitario
								If nPrecVen > 0
									nTotal   := NoRound(nQtdVen * nPrecVen,2)
									cItem    := iif(cItem=="0" , Soma1(StrZero(Val(cItem),2),2) , Soma1(cItem,2) )
									cCodAmos := aDados[t][7]
									nVlrLista := nPrecVen
									cNrGrupo  := aDados[t][11]
									SB1->(dbSetOrder(1))
									SB1->(dbSeek(xFilial("SB1")+cProduto))
									cUMedida := SB1->B1_UM
									cArmaz   := SB1->B1_LOCPAD
									cDescric := SB1->B1_DESC
									cCodISS  := SB1->B1_CODISS
									SF4->(dbSetOrder(1))
									SF4->(dbSeek(xFilial("SF4")+cTes))
									aDadosCfo := {}
									Aadd(aDadosCfo,{"OPERNF","S"})
									Aadd(aDadosCfo,{"TPCLIFOR",cTipoCli})
									Aadd(aDadosCfo,{"UFDEST",cEstCli})
									cCFOP    := MaFisCfo(,SF4->F4_CF,aDadosCfo)
									cClasFis := SB1->B1_ORIGEM+SF4->F4_SITTRIB
									aItens := {	{"C6_ITEM"		, cItem			,	NIL},;
										{"C6_PRODUTO"	, cProduto		,	NIL},;
										{"C6_DESCRI"	, cDescric		,	NIL},;
										{"C6_ZZEORIG"	, cOrigAn		,	NIL},;
										{"C6_REVCERT"	, cRevCert		,	NIL},;
										{"C6_ENTREG"	, dDtEntrega	,	NIL},;
										{"C6_QTDVEN"	, nQtdVen		,	NIL},;
										{"C6_PRCVEN"	, nPrecVen		,	NIL},;
										{"C6_NROCERT"	, cAnalise		,	NIL},;
										{"C6_ZZCODAM"	, cCodAmos		, 	NIL},;
										{"C6_QTDENT"	, 0				,	NIL},;
										{"C6_VALOR" 	, nTotal		,	NIL},;
										{"C6_UM"		, cUMedida		,	NIL},;
										{"C6_TES"   	, cTes			,	NIL},;
										{"C6_CF"  		, cCFOP 		,	NIL},;
										{"C6_LOCAL"   	, cArmaz		,	NIL},;
										{"C6_CLI"		, cCliente		,	NIL},;
										{"C6_LOJA"		, cLjCli		,	NIL},;
										{"C6_CLASFIS"	, cClasFis		,	NIL},;
										{"C6_CODISS"	, cCodISS		,	NIL},;
										{"C6_OPAPONT"	, "N"	  		,	NIL},;
										{"C6_XNRGRUP"	, cNrGrupo 		,	NIL}}
									if !Empty(aDados[t][12])
										aadd(aItens,{"C6_CC",aDados[t][12], Nil})
									endif
									//									{"C6_PRUNIT"	, nVlrLista		,	NIL}}
									aadd(aTotItens , aClone(aItens))
								endif
							Endif
						Next t
					Else
						cMsg := "Processo cancelado, ou não há dados a exibir."
					Endif
				Else
					cMsg := "Processo cancelado, ou não há dados a exibir."
				Endif
			Endif
		endif

		cFilAnt := cFilBKP

		If !lCont .and. !Empty(cMsg)
			IW_MsgBox(cMsg , "Atenção" , "STOP")
			aArqOk := {}
		Endif
/*
	If Len(aLogErro) > 0
		aadd(aLogErro , "." )
		aadd(aLogErro , "." )
		aadd(aLogErro , "Favor verificar a(s) diverg?cia(s) . ")
		MEnviaMail("Z06",aLogErro)
		IW_MsgBox("Diverg?cias foram encontradas e enviadas por e-mail para seu conhecimento e provid?cias. Por favor, verifique." , "Atenção" , "ALERT")
	Endif
*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?So apago os arquivos XML que foram desconsiderados	?
		//?devido alguma inconsistencia.            			?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		For nY:=1 To Len(aArqOk)
			If aArqOk[nY][1]
				FErase(cPath+aArqOk[nY][3])
			Endif
		Next nY
	Else
		IW_MsgBox("O diretório está vazio." , "Arquivo XML" , "ALERT")
	Endif
Return
Static Function Marcar(oBrowse)
	local nX := 0
	For nX := 1 To Len(oBrowse:aArray)
		oBrowse:aArray[nX,1] := !oBrowse:aArray[nX,1]
	Next nX
	oBrowse:Refresh()
Return

Static Function ValProd(cProdXML)

	Local lRet 		:= .T.
	Local aArea		:= GetArea() 
	Local aAreaSB1 	:= SB1->(GetArea())

	SB1->(DbSetOrder(1))
	if !SB1->(DbSeek(xFilial("SB1")+cProdXML))
		MsgStop("Produto "+Alltrim(cProdXML)+" não encontrado no cadastro de produtos.")
		lRet := .F.
	endif

	SB1->(RestArea(aAreaSB1))
	RestArea(aArea)

Return lRet

Static Function ValMetodo(cMetodos,cNomArq)

	Local lRet 		:= .T.
	Local aArea		:= GetArea() 
	Local aAreaZZO 	:= ZZO->(GetArea())

	ZZO->(DbSetOrder(1))
	if !ZZO->(DbSeek(xFilial("ZZO")+cMetodos))
		if !cMetodos $ cServiArea
			MsgStop("Service Area "+Alltrim(cMetodos)+" não encontrado no cadastro."+CRLF+"Arquivo: "+Alltrim(cNomArq))
			cServiArea += cMetodos+"/"
		endif
		lRet := .F.
	endif

	ZZO->(RestArea(aAreaZZO))
	RestArea(aArea)

Return lRet

/*
Régis Ferreira 18/11/2024 - Acrescentado para buscar o vendedor com a condição que vem no XML novo do Mylins
*/
Static Function GetVendedor(cVendedor,cCodInvoice)

	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSA3	:= SA3->(GetArea())
	Local nCount	:= 0
	Local cVendA3	:= Padr(cVendedor,TamSx3("A3_NOME")[1])
	Local cRet		:= ""

	SA3->(DbSetOrder(2))
	if SA3->(DbSeek(xFilial("SA3")+cVendA3))
		While !SA3->(EOF()) .and. SA3->A3_FILIAL+SA3->A3_NOME == xFilial("SA3")+cVendA3
			nCount ++
			cRet := SA3->A3_COD
			SA3->(DbSkip())
		enddo
	endif

	if nCount == 0 //Se não achar o vendedor, vai mandar em branco conforme combinado com o Cesar
		MsgAlert("Não foi encontrado nenhum vendedor com o nome ("+Alltrim(cVendA3)+"). Verifique o cadastro de vendedores!","ATENÇÃO")
		cVendedor := ""
		lRet := .F.
	else
		if nCount > 1 //Se tiver mais de um vendedor com o mesmo nome, para a importação
			MsgAlert("Foi encontrado mais de um vendedor com o nome ("+Alltrim(cVendA3)+"). Verifique o cadastro de vendedores!"+CRLF+"Não é possível ter mais de um vendedor com o mesmo nome."+CRLF+"Invoice: "+cCodInvoice,"ATENÇÃO")
			lRet 		:= .F.
		else
			//Se achar, troca o nome do vendedor que está no XML pelo código
			cVendedor 	:= cRet
		endif
	endif

	SA3->(RestArea(aAreaSA3))
	RestArea(aArea)
	
Return lRet

Static Function GetCondPagto(cPagtoMylins,cCodInvoice)

	Local lRet 		:= .F.
	Local aArea		:= GetArea()
	Local aAreaZZP	:= ZZP->(GetArea())
	Local cCond		:= Padr(cPagtoMylins,TamSx3("ZZP_CONDMY")[1])

	ZZP->(dbSetOrder(1))
	if ZZP->(DbSeek(xFilial("ZZP")+cCond))
		cPagtoMylins := ZZP->ZZP_CONDPR
		lRet := .T.
	endif

	if !lRet
		MsgAlert("Não foi encontrado nenhuma condição de pagamento no De/Para entre protheus e Mylins, verifique a condição de pagamento ("+Alltrim(cPagtoMylins)+")."+CRLF+;
		"Analise a condição de pagamento do XML ou o de/para de condição de pagamento"+CRLF+"Invoice: "+cCodInvoice,"ATENÇÃO")
	endif

	ZZP->(RestArea(aAreaZZP))
	RestArea(aArea)

Return lRet
