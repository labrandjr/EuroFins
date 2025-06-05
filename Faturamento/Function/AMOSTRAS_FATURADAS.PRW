#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "colors.ch"

/*/{Protheus.doc} InlbConnect 
Faz conexao no banco INTEGRACAO para incluir clientes na base do Protheus.
@author  Marcos Candido   
@since  25/09/13   
@Obs ALAC                                                      
/*/
User Function InlbConnect
Local aSays      := {}
Local aButtons   := {}
Local cCadastro  := OemToansi('Integra็ใo entre sistemas - Protheus x QualiLims')
Local lOkParam   := .F.
Local cPerg      := PADR("PROTHQUALI",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}
Local cMens      := OemToAnsi('A op็ใo de Parโmetros desta rotina deve ser acessada antes de sua execu็ใo!')

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Organiza o Grupo de Perguntas e Help ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHelpPor := {}
aAdd(aHelpPor,"Informe se deseja atualizar o cadastro ")
aAdd(aHelpPor,"de Clientes, ou buscar as informa็๕es ")
aAdd(aHelpPor,"para gerar Faturamento.               ")
Aadd(aPergs,{"Qual Processamento","","","mv_ch1","N",1,0,1,"C","","MV_PAR01","Atualiz Cliente","","","","","Faturamento","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria, se necessario, o grupo de Perguntas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AjustaSX1(cPerg,aPergs)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Interface com o usuario             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aSays,OemToAnsi('Este programa visa integrar os sistemas Protheus e QualiLims, atuali-'))
aAdd(aSays,OemToAnsi('zando o cadastro de clientes e as tabelas para faturamento do Protheus  '))
aAdd(aSays,OemToAnsi('a partir do QualiLims.'))
aAdd(aButtons, { 5,.T.,{|| AcessaPar(cPerg,@lOkParam) } } )
aAdd(aButtons, { 1,.T.,{|o|If(lOkParam,(Processa({|lEnd| ProcGer()}),o:oWnd:End()),Aviso(OemToAnsi('Aten็ใo!!!'), cMens , {'Ok'})) } } )
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons,,230,450 ) // altura x largura

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ          บ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao chamada pelo botao OK na tela inicial de processamenบฑฑ
ฑฑบ          ณ to. Executa a integracao entre os sistemas.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ProcGer

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa a regua de processamento                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If mv_par01 == 1
	//LjMsgRun("Aguarde...","Atualiza็ใo do Cadastro de Clientes",{|| Run01() })
	Processa({|lEnd| Run01() } , "Atualiza็ใo do Cadastro de Clientes")
Else
	//LjMsgRun("Aguarde...","Gera็ใo de Pedidos de Venda",{|| Run02() })
	Processa({|lEnd| Run02() } , "Gera็ใo de Pedidos de Venda")
Endif

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Run02    บAutor  ณMicrosiga           บ Data ณ  21/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ALAC                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Run02

Local lCont := .T.
Local aFieldsFat := {}

Local oOK := LoadBitmap(GetResources(),"CHECKED" )
Local oNO := LoadBitmap(GetResources(),"UNCHECKED" )
Local aBrowse := {}
Local cCliAnt := ""
Local nField := 1
Local cPerg      := PADR("PROTHQUAL2",10) , aPergs := {}
Local aHelpPor   := {} , aHelpIng := {} , aHelpEsp := {}

Local aCabExcel := {'','Revisao','C๓digo','Loja','Nome Cliente','Num. O.S.','Identifica็ใo','E-Mail','Valor','Mensagem','Data Recebimento','Data Liberacao','Info MAPA'}

Private lMark := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Organiza o Grupo de Perguntas e Help ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aHelpPor,"Indique o C๓digo do Cliente Inicial a")
aAdd(aHelpPor,"ser considerado no filtro dos dados.")
Aadd(aPergs,{"Do Cliente","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique a Loja do Cliente Inicial a")
aAdd(aHelpPor,"ser considerado no filtro dos dados.")
Aadd(aPergs,{"Da Loja","","","mv_ch2","C",2,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique o C๓digo do Cliente Final a")
aAdd(aHelpPor,"ser considerado no filtro dos dados.")
Aadd(aPergs,{"Ate o Cliente","","","mv_ch3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique a Loja do Cliente Final a")
aAdd(aHelpPor,"ser considerado no filtro dos dados.")
Aadd(aPergs,{"Ate a Loja","","","mv_ch4","C",2,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique o N๚mero da O.S. Inicial a")
aAdd(aHelpPor,"ser considerada no filtro dos dados.")
Aadd(aPergs,{"Da Ordem de Servico","","","mv_ch5","C",20,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique o N๚mero da O.S. Final a")
aAdd(aHelpPor,"ser considerada no filtro dos dados.")
Aadd(aPergs,{"Ate a Ordem de Servico","","","mv_ch6","C",20,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique o N๚mero da Amostra ")
aAdd(aHelpPor,"Inicial a ser considerada no ")
aAdd(aHelpPor,"filtro dos dados.")
Aadd(aPergs,{"Da Amostra","","","mv_ch7","C",20,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique o N๚mero da Amostra ")
aAdd(aHelpPor,"Final a ser considerada no ")
aAdd(aHelpPor,"filtro dos dados.")
Aadd(aPergs,{"Ate a Amostra","","","mv_ch8","C",20,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique a Ordem que deseja visualizar")
aAdd(aHelpPor,"os dados. Por Cliente+Loja ou Ordem de ")
aAdd(aHelpPor,"Servi็o.")
Aadd(aPergs,{"Dados Classificados por","","","mv_ch9","N",01,0,0,"C","","MV_PAR09","Cliente+Loja","","","","","Ordem de Serv.","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique a Data Inicial de  ")
aAdd(aHelpPor,"Libera็ใo das amostras a ser ")
aAdd(aHelpPor,"considerada no filtro dos dados.")
Aadd(aPergs,{"Da Data de Liberacao","","","mv_cha","D",08,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

aHelpPor := {}
aAdd(aHelpPor,"Indique a Data Final de  ")
aAdd(aHelpPor,"Libera็ใo das amostras a ser ")
aAdd(aHelpPor,"considerada no filtro dos dados.")
Aadd(aPergs,{"Ate a Data de Liberacao","","","mv_chb","D",08,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria, se necessario, o grupo de Perguntas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AjustaSx1(cPerg,aPergs)

If !Pergunte(cPerg,.T.)
	Return
Endif

aadd(aFieldsFat , {"CODIGOPROTHEUS"	,"C",020,0})
aadd(aFieldsFat , {"LOJAPROTHEUS"	,"C",020,0})
aadd(aFieldsFat , {"IDENTIFICACAO"	,"C",020,0})
aadd(aFieldsFat , {"EMAILNF"			,"C",050,0})
aadd(aFieldsFat , {"VLRTOTAL"  		,"N",015,2})
aadd(aFieldsFat , {"MENSNOTA"			,"C",300,0})
aadd(aFieldsFat , {"NUMEROOS"			,"C",020,0})
aadd(aFieldsFat , {"STATUSREG"		,"C",001,0})
aadd(aFieldsFat , {"RECEBIMENTO"		,"C",025,0})
aadd(aFieldsFat , {"LIBERACAO"		,"C",025,0})
aadd(aFieldsFat , {"DESCONTO"			,"N",012,2})
aadd(aFieldsFat , {"DESCONTOP"		,"N",008,4})
aadd(aFieldsFat , {"INFOMAPA"			,"C",040,0})

aadd(aFieldsSet , {"IDENTIFICACAO"	,"C",020,0})
aadd(aFieldsSet , {"IDSETOR"			,"N",006,0})
aadd(aFieldsSet , {"VALOR"  			,"N",015,2})
aadd(aFieldsSet , {"ANALISES"			,"C",999,0})

oConExt := FWDBAccess():New(cSemLic+cDBMSAlias , cServer , nPort)
oConExt:SetConsoleError( .T. )         // Habilita exibi็ใo dos erros no console do Protheus

If oConExt:OpenConnection()
	
	cAliasFat := GetNextAlias()
	
	nTotReg := 0                       // Numero de Registros a Processar
	cQ := "SELECT COUNT(*) AS nRegistros FROM FATURAMENTO (NOLOCK) "
	cQ += "WHERE "
	cQ += "(STATUSREG IS NULL OR STATUSREG = 'R') AND "
	cQ += "MENSNOTA <> '_PROTHEUS_' AND "
	cQ += "CODIGOPROTHEUS >= '"+mv_par01+"' AND "
	cQ += "LOJAPROTHEUS   >= '"+mv_par02+"' AND "
	cQ += "CODIGOPROTHEUS <= '"+mv_par03+"' AND "
	cQ += "LOJAPROTHEUS   <= '"+mv_par04+"' AND "
	cQ += "NUMEROOS       >= '"+mv_par05+"' AND "
	cQ += "NUMEROOS       <= '"+mv_par06+"' AND "
	cQ += "IDENTIFICACAO  >= '"+mv_par07+"' AND "
	cQ += "IDENTIFICACAO  <= '"+mv_par08+"' "
	oConExt:NewAlias( cQ , cAliasFat , aFieldsFat )
	
	nTotReg := (cAliasFat)->nRegistros        // Numero de Registros Selecionados
	
	(cAliasFat)->(dbCloseArea())
	
	cAliasFat := GetNextAlias()
	
	//cQ := "SELECT TOP 50 * FROM FATURAMENTO "
	//cQ += "WHERE MENSNOTA <> '_PROTHEUS_' AND "
	cQ := "SELECT * FROM FATURAMENTO (NOLOCK) "
	cQ += "WHERE "
	cQ += "(STATUSREG IS NULL OR STATUSREG = 'R') AND "
	cQ += "MENSNOTA <> '_PROTHEUS_' AND "
	cQ += "CODIGOPROTHEUS >= '"+mv_par01+"' AND "
	cQ += "LOJAPROTHEUS   >= '"+mv_par02+"' AND "
	cQ += "CODIGOPROTHEUS <= '"+mv_par03+"' AND "
	cQ += "LOJAPROTHEUS   <= '"+mv_par04+"' AND "
	cQ += "NUMEROOS       >= '"+mv_par05+"' AND "
	cQ += "NUMEROOS       <= '"+mv_par06+"' AND "
	cQ += "IDENTIFICACAO  >= '"+mv_par07+"' AND "
	cQ += "IDENTIFICACAO  <= '"+mv_par08+"' "
	If mv_par09 == 1
		cQ += "ORDER BY CODIGOPROTHEUS,LOJAPROTHEUS,IDENTIFICACAO"
	Else
		cQ += "ORDER BY NUMEROOS,IDENTIFICACAO"
	Endif
	oConExt:NewAlias( cQ , cAliasFat , aFieldsFat )
	
	If oConExt:HasError()
		cMsg := "Erro na selecao dos dados - Erro: " + AllTrim( oConExt:ErrorMessage() )+"."
		lCont := .F.
	Endif
	
	If nTotReg == 0
		cMsg := "Nใo hแ dados na tabela para serem exibidos."
		lCont := .F.
	Endif

	If lCont
		
		nConExt := oConExt:Handle()
		TCSetConn( nConExt ) // numero da conexao do banco QUALILIMS
		
		dbSelectArea(cAliasFat)
		//Count to nTotReg
		
		ProcRegua(nTotReg)
		
		dbGoTop()
		
		While !Eof()
			
			IncProc("Montando consulta ao banco de dados...")
			
			If (DtoS((cAliasFat)->LIBERACAO) < DtoS(mv_par10) .or. DtoS((cAliasFat)->LIBERACAO) > DtoS(mv_par11))
				dbSkip()
				Loop
			Endif	 
					
			cCodCli := Alltrim((cAliasFat)->CODIGOPROTHEUS)
			cLojCli := Alltrim((cAliasFat)->LOJAPROTHEUS)
			
			cDtRecebe := DtoC((cAliasFat)->RECEBIMENTO)			
			cDtLibera := DtoC((cAliasFat)->LIBERACAO)
			
			TCSetConn( nConALAC ) // numero da conexao do banco padrao do ALAC
			
			cNomeCli := Substr(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_NOME"),1,25)
			
			TCSetConn( nConExt ) // numero da conexao do banco QUALILIMS
			
			aadd(aBrowse ,	{	.F. ,;
									Iif((cAliasFat)->STATUSREG=='R',"SIM",Space(3)),;
									cCodCli,;
									cLojCli,;
									cNomeCli,;
									(cAliasFat)->NUMEROOS,;
									(cAliasFat)->IDENTIFICACAO,;
									(cAliasFat)->EMAILNF,;
									Transform((cAliasFat)->VLRTOTAL,"@E 9,999,999.99"),;
									(cAliasFat)->MENSNOTA,;
									cDtRecebe,;
									cDtLibera,;
									Transform((cAliasFat)->DESCONTO,"@E 999,999.9999"),;
									Transform((cAliasFat)->DESCONTOP,"@E 999.9999"),;
									(cAliasFat)->INFOMAPA})
			
			dbSelectArea(cAliasFat)
			dbSkip()
		Enddo
		
		If Len(aBrowse) > 0
			
			DEFINE DIALOG oDlg TITLE "Sele็ใo de Registros" FROM 167,140 TO 530,1290 PIXEL
			
			oBrowse := TWBrowse():New( 01,01,500,180,,{'','Revisใo','C๓digo','Loja','Nome Cliente','Num. O.S.','Identifica็ใo','E-Mail','Valor','Mensagem','Data Recebimento','Data Libera็ใo','Desconto ($)','Desconto (%)','Info MAPA'},{05,09,05,05,50,20,40,40,20,100,35,35,25,25,35},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
			
			oBrowse:SetArray(aBrowse)
			oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07],aBrowse[oBrowse:nAt,08],aBrowse[oBrowse:nAt,09],aBrowse[oBrowse:nAt,10],aBrowse[oBrowse:nAt,11],aBrowse[oBrowse:nAt,12],aBrowse[oBrowse:nAt,13],aBrowse[oBrowse:nAt,14],aBrowse[oBrowse:nAt,15] } }
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ So permite marcar codigos iguais de cliente+loja.                ณ
			//ณ Se estiver tudo certo, troca a imagem no duplo click do mouse    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//oBrowse:bLDblClick := {|| Iif( fValBrow( aBrowse , oBrowse:nAt ) , oBrowse:DrawSelect() , Nil ) }
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ So permite marcar um codigo e desmarca outra caixa que estiver   ณ
			//ณ marcada.                                                         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//oBrowse:bLDblClick := {|| If(nField <> oBrowse:nAt,(aBrowse[nField][1] := .F.,nField := oBrowse:nAt,aBrowse[nField][1] := .T.,oBrowse:Refresh()),)}
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Marca todos os itens sem criar validacao                         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],oBrowse:DrawSelect()}
			
			@ 010,512 BUTTON "  O K  "  SIZE 040,012 PIXEL OF oDlg Action(lCont:=.T.,oDlg:End()) // TOOLTIP "Ok"
			@ 030,512 BUTTON "Cancelar" SIZE 040,012 PIXEL OF oDlg Action(lCont:=.F.,oDlg:End()) // TOOLTIP "Cancelar"
			@ 050,512 BUTTON "Excel"    SIZE 040,012 PIXEL OF oDlg Action(U_GeraExcel(aCabExcel,aBrowse),oBrowse:Refresh()) // TOOLTIP "Envia dados para o Excel"
			@ 070,512 BUTTON "Excluir"  SIZE 040,012 PIXEL OF oDlg Action(U_Excluir(@aBrowse,oConExt,oOK,oNO),oBrowse:Refresh()) // TOOLTIP "Excluir registros"
			
			ACTIVATE DIALOG oDlg CENTERED
			
		Else
			
			lCont := .F.
			
		Endif
		
		If lCont

			TCSetConn( nConALAC ) // numero da conexao do banco padrao do ALAC
			
			// Verifico se a amostra selecionada ja foi incluida em pedido de venda anterior,
			// pois o usuario pode ter marcado uma amostra identificada como REVISAO.
			// Devo sinalizar para o usuario sobre qual o pedido que a amostra ja esta cadastrada.
			// Cabe a ele (usuario) decidir se continua ou nao o processo de inclusao do pedido para a amostra
			// que eh uma revisao.
			aAmostra := {}
			dbSelectArea("SC5")
			dbSetOrder(5)
			For nA:=1 to Len(aBrowse)
				If aBrowse[nA,1] // O registro esta selecionado
					If dbSeek(xFilial("SC5")+Alltrim(aBrowse[nA,7]),.T.)
						aadd(aAmostra , {Alltrim(aBrowse[nA,7]), SC5->C5_NUM})
					Endif
				Endif
			Next
			
			If Len(aAmostra) > 0
				lCont := MostraAmostra(aAmostra)
			Endif
		
		Endif
		
		If lCont
			
			cAux := ""
			
			// Leio os registros selecionados para obter o numero de todas as identificacoes
			// para poder procura-las na tabela FATURAMENTO_SETOR
			For nA:=1 to Len(aBrowse)
				If aBrowse[nA,1] // O registro esta selecionado
					cAux += iif(Empty(cAux),"",";")+Alltrim(aBrowse[nA,7])
				Endif
			Next
			
			cAliasFSet := GetNextAlias()
			
			cQ := "SELECT * FROM FATURAMENTO_SETOR "
			cQ += "WHERE "
			cQ += "IDENTIFICACAO IN "+FormatIn(cAux,";")+" "
			cQ += "ORDER BY IDENTIFICACAO"
			oConExt:NewAlias( cQ , cAliasFSet , aFieldsSet )
			
			TCSetConn( nConExt ) // numero da conexao do banco QUALILIMS
			
			ProcRegua(Len(aBrowse))
			
			For nA:=1 to Len(aBrowse)
				
				IncProc("Processando registros da tabela de FATURAMENTO da base INTEGRAวรO...")
				
				If aBrowse[nA,1] // O registro esta selecionado
					
					dbSelectArea(cAliasFSet)
					dbGotop()
					While !Eof()
						
						If Alltrim(aBrowse[nA,7]) == Alltrim((cAliasFSet)->IDENTIFICACAO)

							nVlrDesc  := Val(StrTran(StrTran(aBrowse[nA,13],".",""),",","."))
							nPercDesc := Val(StrTran(StrTran(aBrowse[nA,14],".",""),",","."))
							
							nPreco := IIF((cAliasFSet)->VALOR > 0 , (cAliasFSet)->VALOR , 1)
							If StrZero((cAliasFSet)->IDSETOR,4) == '0000'
								cProd := '310999'
							Else
								cProd  := '31' + StrZero((cAliasFSet)->IDSETOR,4)
							Endif
							cAnl   := (cAliasFSet)->ANALISES
							cAmost := Alltrim((cAliasFSet)->IDENTIFICACAO)
							cDescr := ""
							
							cCodCli := StrZero(Val(aBrowse[nA,3]),6)
							cLojCli := StrZero(Val(aBrowse[nA,4]),2)
							If cCodCli == '000000' .and. cLojCli == '00'
								cCodCli := '999999'
								cLojCli := '01'
							Endif

							TCSetConn( nConALAC ) // numero da conexao do banco padrao do ALAC
	
							lCliOK := .T.
							dbSelectArea("SA1")
							dbSetOrder(1)
							If !dbSeek(xFilial("SA1")+cCodCli+cLojCli)
						
								If Len(aLogErro) > 0
									aadd(aLogErro , "." )
								Endif
								aadd(aLogErro , "O C๓digo/Loja do Cliente "+cCodCli+"/"+cCodCli+" nใo estแ na base do Protheus. O pedido nใo foi incluํdo." )
								lCliOK := .F.
							
							Else
						
								If SA1->A1_MSBLQL == '1' // 1=bloqueado
								
									If Len(aLogErro) > 0
										aadd(aLogErro , "." )
									Endif
									aadd(aLogErro , "O C๓digo/Loja do Cliente "+cCodCli+"/"+cCodCli+" estแ bloqueado. O pedido nใo foi incluํdo." )
									lCliOK := .F.
															
								Endif
								
							Endif	

							If lCliOk
							
								dDtRecebe := CtoD(aBrowse[nA,11])
								dDtLibera := CtoD(aBrowse[nA,12])
							
								aadd(aDados , { 	cCodCli						, cLojCli	,;
														cProd							, cDescr		,;
														Alltrim(aBrowse[nA,8]) 	, 1			,;
														nPreco						, nPreco		,;
														Alltrim(aBrowse[nA,10])	, cAnl		,;
														cAmost 						, dDtRecebe	,;
														dDtLibera					, nVlrDesc   ,;
														nPercDesc					, Alltrim(aBrowse[nA,15])})
														
							Else
							
								aBrowse[nA,1] := .F. // Desmarco o registro para nao atualizar o campo STATUSREG e assim, possilibitar nova leitura
							
							Endif
							
						Endif

						TCSetConn( nConExt ) // numero da conexao do banco QUALILIMS						
						
						dbSelectArea(cAliasFSet)
						dbSkip()
						
					Enddo
					
				Endif
				
			Next nA
			/*
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Estrutura do array aDados                	ณ
			//ณ     -----------------                    	ณ
			//ณ 			1	Codigo Cliente para Faturamento	ณ
			//ณ 			2	Loja Cliente para Faturamento		ณ
			//ณ 			3  Codigo do produto  					ณ
			//ณ 			4  Descricao do produto  				ณ
			//ณ 			5  Email para o envio da nota  		ณ
			//ณ 			6  quantidade  							ณ
			//ณ 			7  Valor unitario  						ณ
			//ณ 			8  Valor total  							ณ
			//ณ 			9  Mensagem para a nota  				ณ
			//ณ 			10 Analise               				ณ
			//ณ 			11 Cod da amostra        				ณ
			//ณ 			12 Data do Recebimento   				ณ
			//ณ 			13 Data da Liberacao     				ณ
			//ณ 			14 Valor do Desconto     				ณ
			//ณ 			15 Percentual do Desconto				ณ	
			//ณ 			16 Informacoes MAPA      			   ณ	
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			*/
			
			If Len(aDados) > 0
				
				aadd(aDados , {	"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
										"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
										"ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" , "ZZZ" ,;
										"ZZZ" })

				TCSetConn( nConALAC ) // numero da conexao do banco padrao do ALAC
				
				aSort(aDados,,, { |x,y| x[11] < y[11] })
				
				ProcRegua(Len(aDados))              
				
				For t:=1 to Len(aDados)
					
					IncProc("Gerando Pedidos de Venda...")
					
					If cAglut # aDados[t][11]
						
						If Len(aCabec) > 0 .and. Len(aTotItens) > 0
							
							lMsErroAuto := .F.
							
							Begin Transaction
							
							MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aTotItens,3)
							
							If lMsErroAuto
								//MostraErro()
								cErro := MemoRead(NomeAutoLog())
								DisarmTransaction()
								Break
							Endif
							
							End Transaction
							
							If lMsErroAuto
								If Len(aLogErro) > 0
									aadd(aLogErro , "." )
								Endif
								aadd(aLogErro , "Verifique o seguinte erro: "+cErro)
							Endif
							
							aCabec    := {}
							aTotItens := {}
							aItens    := {}
							
						Endif
						
						If aDados[t][11] == "ZZZ"
							Exit
						Else
							cAglut    := aDados[t][11]
							cEmailNfe := ""
							cMenNota  := ""
						Endif
						
						dbSelectArea("SA1")
						dbSetOrder(1)
						If !dbSeek(xFilial("SA1")+aDados[t][1]+aDados[t][2])
							
							If Len(aLogErro) > 0
								aadd(aLogErro , "." )
							Endif
							aadd(aLogErro , "O C๓digo/Loja do Cliente "+aDados[t][1]+"/"+aDados[t][2]+" nใo estแ na base do Protheus. O pedido nใo foi incluํdo." )
							
						Else
							
							If SA1->A1_MSBLQL == '1' // 1=bloqueado
								
								If Len(aLogErro) > 0
									aadd(aLogErro , "." )
								Endif
								aadd(aLogErro , "O C๓digo/Loja do Cliente "+aDados[t][1]+"/"+aDados[t][2]+" estแ bloqueado. O pedido nใo foi incluํdo." )
								
							Else
								
								cTipoCli  := SA1->A1_TIPO
								cEstCli   := SA1->A1_EST
								cCondPag  := SA1->A1_COND
								cCliente  := SA1->A1_COD
								cLjCli    := SA1->A1_LOJA
								cNomeFant := SA1->A1_NREDUZ
								cMunCli   := SA1->A1_MUN
								
								dEmissao   	:= dDataBase
								nMoeda     	:= 1
								cCodAmos    := aDados[t][11]
								dDtEntrega 	:= DataValida(dDataBase,.T.)
								dDtRecebe 	:= aDados[t][12]
								dDtLibera   := aDados[t][13]
								cInfoMapa   := aDados[t][16]
								
								If !Empty(cMenNota)
									cMenNota += " "
								Endif
								If !Empty(aDados[t][9]) .and. !(cMenNota $ aDados[t][9])
									cMenNota += aDados[t][9]
								Endif
																
								If Empty(Alltrim(aDados[t][5]))
									If Empty(SA1->A1_NFEMAIL)
										If !(Alltrim(SA1->A1_EMAIL) $ cEmailNfe)
											If !Empty(cEmailNfe) .and. Right(cEmailNfe,1) <> ";"
												cEmailNfe += ";"
											Endif
											cEmailNfe += Alltrim(SA1->A1_EMAIL)
										Endif
									Else
										If !(Alltrim(SA1->A1_NFEMAIL) $ cEmailNfe)
											If !Empty(cEmailNfe) .and. Right(cEmailNfe,1) <> ";"
												cEmailNfe += ";"
											Endif
											cEmailNfe += Alltrim(SA1->A1_NFEMAIL)
										Endif
									Endif
								Else
									If !(Alltrim(aDados[t][5]) $ cEmailNfe)
										If !Empty(cEmailNfe) .and. Right(cEmailNfe,1) <> ";"
											cEmailNfe += ";"
										Endif
										cEmailNfe += aDados[t][5]
									Endif
								Endif
								
								aCabec := {	{"C5_TIPO"		, "N"				,	NIL},;
												{"C5_CLIENTE"	, cCliente		,	NIL},;
												{"C5_LOJACLI"	, cLjCli			,	NIL},;
												{"C5_CLIENT"	, cCliente		,	NIL},;
												{"C5_LOJAENT"	, cLjCli			,	NIL},;
												{"C5_NFANT"		, cNomeFant		,	NIL},;
												{"C5_MUNIC"		, cMunCli		,	NIL},;
												{"C5_CLAUDO"	, cCliente		,	NIL},;
												{"C5_LLAUDO"	, cLjCli			,	NIL},;
												{"C5_TIPCERT"	, "N"				,	NIL},;
												{"C5_NROCERT"	, cCodAmos		,	NIL},;
												{"C5_KM"			, 0				,	NIL},;
												{"C5_TIPOCLI"	, cTipoCli		,	NIL},;
												{"C5_CONDPAG"	, cCondPag		,	NIL},;
												{"C5_XDTENT"	, dDtEntrega	,	NIL},;
												{"C5_MOEDA"		, nMoeda			,	NIL},;
												{"C5_TXMOEDA"	, 1				,	NIL},;
												{"C5_XTEMPO"	, "P"				,	NIL},;
												{"C5_TIPLIB"	, "2"				,	NIL},;
												{"C5_XUSER2"	, "1"				,	NIL},;
												{"C5_HOMOGE"	, "N"				,	NIL},;
												{"C5_TABELA"	, Space(3)		,	NIL},;
												{"C5_TPCARGA"	, "2"				,	NIL},;
												{"C5_DATAPED"	, dDataBase		,	NIL},;
												{"C5_DATAREC"	, dDtRecebe		,	NIL},;
												{"C5_DATAENV"	, dDtLibera		,	NIL},;
												{"C5_XOBS"		, cMenNota    	,	NIL},;
												{"C5_NFEMAIL"	, cEmailNfe    ,	NIL},;
												{"C5_XINFMAP"	, cInfoMapa    ,	NIL},;
												{"C5_EMISSAO"	, dEmissao		,	NIL}}
								
							Endif
							
						Endif
						
					Endif
					
					If Len(aCabec) > 0
						
						aItens   := {}
						cProduto := aDados[t][3]
						cOrigAn  := "I"
						cRevCert := "01"
						nQtdVen  := aDados[t][6] 				// Quantidade
						nPrecVen := Round(aDados[t][7],2) 	// Preco Unitario
						nTotal   := NoRound(nQtdVen * nPrecVen,2)
						cTes     := "505"
						cItem    := StrZero(Len(aTotItens)+1,2)
						cAnalise := aDados[t][10]
						cCodAmos := aDados[t][11]
						nVlrDesc  := aDados[t][14]
						nPercDesc := aDados[t][15]
						If nVlrDesc > 0
							nVlrLista := nPrecVen+nVlrDesc
						ElseIf nPercDesc > 0
							nVlrLista := Round(nPrecVen/((100-nPercDesc)/100),2)
						Else
							nVlrLista := nPrecVen
						Endif
						
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+cProduto))
						cUMedida := SB1->B1_UM
						cArmaz   := SB1->B1_LOCPAD
						cDescric := SB1->B1_DESC
						
						SF4->(dbSetOrder(1))
						SF4->(dbSeek(xFilial("SF4")+cTes))
						aDadosCfo := {}
						Aadd(aDadosCfo,{"OPERNF","S"})
						Aadd(aDadosCfo,{"TPCLIFOR",cTipoCli})
						Aadd(aDadosCfo,{"UFDEST",cEstCli})
						cCFOP    := MaFisCfo(,SF4->F4_CF,aDadosCfo)
						cClasFis := SB1->B1_ORIGEM+SF4->F4_SITTRIB
						cCodISS  := SB1->B1_CODISS
						
						aItens := {	{"C6_ITEM"		, cItem			,	NIL},;
										{"C6_PRODUTO"	, cProduto		,	NIL},;
										{"C6_DESCRI"	, cDescric		,	NIL},;
										{"C6_EORIGAN"	, cOrigAn		,	NIL},;
										{"C6_REVCERT"	, cRevCert		,	NIL},;
										{"C6_ENTREG"	, dDtEntrega	,	NIL},;
										{"C6_QTDVEN"	, nQtdVen		,	NIL},;
										{"C6_PRCVEN"	, nPrecVen		,	NIL},;
										{"C6_NROCERT"	, cCodAmos		,	NIL},;
										{"C6_XCODAM"	, cAnalise		, 	NIL},;
										{"C6_QTDENT"	, 0				,	NIL},;
										{"C6_VALOR" 	, nTotal			,	NIL},;
										{"C6_UM"			, cUMedida		,	NIL},;
										{"C6_TES"   	, cTes			,	NIL},;
										{"C6_CF"  		, cCFOP 			,	NIL},;
										{"C6_DESCONT" 	, nPercDesc		,	NIL},;
										{"C6_VALDESC" 	, nVlrDesc		,	NIL},;
										{"C6_LOCAL"   	, cArmaz			,	NIL},;
										{"C6_CLI"		, cCliente		,	NIL},;
										{"C6_LOJA"		, cLjCli			,	NIL},;
										{"C6_CLASFIS"	, cClasFis		,	NIL},;
										{"C6_CODISS"	, cCodISS		,	NIL},;
										{"C6_OPAPONT"	, "N"		  		,	NIL},;
										{"C6_CODRESP"	, "000001"		,	NIL},;
										{"C6_PRUNIT"	, nVlrLista		,	NIL}}
						
						aadd(aTotItens , aClone(aItens))
						
					Endif
					
				Next t
				
			Else
				
				cMsg := "Processo cancelado, ou nใo hแ dados a exibir."
				
			Endif
			
		Else
			
			cMsg := "Processo cancelado, ou nใo hแ dados a exibir."
			
		Endif
		
	Endif
	
Else
	
	cMsg := "Falha de Conexใo com a Base Externa - Erro: " + AllTrim( oConExt:ErrorMessage() )
	lCont := .F.
	
Endif

If lCont .and. Empty(cMsg) .and. !lMsErroAuto
	
	TCSetConn( nConExt ) // numero da conexao do banco QUALILIMS
	
	For nB:=1 to Len(aBrowse)
		
		If aBrowse[nB,1] // O registro esta selecionado
			
			cQ := "UPDATE FATURAMENTO SET STATUSREG='P' "
			cQ += "WHERE "
			cQ += "CODIGOPROTHEUS = '"+aBrowse[nB,3]+"' AND "
			cQ += "LOJAPROTHEUS   = '"+aBrowse[nB,4]+"' AND "
			cQ += "IDENTIFICACAO  = '"+aBrowse[nB,7]+"'"
			oConExt:TransBegin()
			If !oConExt:SQLExec( cQ )
				cMsg := "Erro na atualizacao dos dados - Erro: " + AllTrim( oConExt:ErrorMessage() )
				lCont := .F.
				oConExt:TransDisarm()
			Endif
			oConExt:TransEnd()
			
		Endif
		
	Next
	
Endif

If !lCont .and. !Empty(cMsg)
	IW_MsgBox(cMsg , "Aten็ใo" , "STOP")
Endif

oConExt:CloseConnection()
oConExt:Finish()

TCSetConn( nConALAC ) // numero da conexao do banco padrao do ALAC

If Len(aLogErro) > 0
	aadd(aLogErro , "." )
	aadd(aLogErro , "." )
	aadd(aLogErro , "Favor verificar a(s) diverg๊ncia(s) . ")
	MEnviaMail("Z02",aLogErro)
	IW_MsgBox("Diverg๊ncias foram encontradas e enviadas por e-mail para seu conhecimento e provid๊ncias. Por favor, verifique." , "Aten็ใo" , "ALERT")
Endif

Return lCont

/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funcao   ณ AcessaPar   ณ Autor ณ Marcos Candido     ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao para acessar o grupo de perguntas                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function AcessaPar(cPerg,lOk)

If Pergunte(cPerg)
	lOk := .T.
Endif

Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MMENSZ02 บAutor  ณ Marcos Candido     บ Data ณ  29/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para adequar a mensagem que o usuario ira receber   บฑฑ
ฑฑบ          ณ sobre evento pre cadastrado.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Z02 ==> Divergencias encontradas na integracao entre os    บฑฑ
ฑฑบ          ณ         sistemas Protheus e QualiLims                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ALAC                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MMENSZ02

Local cMens := ""
Local aInfo := PARAMIXB

For m:=1 to Len(aInfo[1])
	cAux := Alltrim(aInfo[1][m])
	cAux := StrTran(cAux,CHR(10),"")
	cAux := StrTran(cAux,CHR(13)," ")
	If !Empty(cAux)
		cMens += cAux+CHR(13)+CHR(10)
	Endif
	If Len(cMens) >= 1000000  // 1048576 = 1Mb (para evitar String size overflow. Que eh quando o limite de armazemento de 1 Mb eh ultrapassado)
		cMens += CHR(13)+CHR(10)
		cMens += "NรO FOI POSSIVEL ENVIAR TODAS AS DIVERGสNCIAS, DEVIDO LIMITAวรO TษCNICA DO TAMANHO DA MENSAGEM QUE ษ DE 1MB."
		Exit
	Endif
Next

Return cMens


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fValBrow บAutor  ณ Marcos Candido     บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para checar se o usuario marcou codigos iguais ou   บฑฑ
ฑฑบ          ณ nao de clientes. So sera permitido que codigos iguais      บฑฑ
ฑฑบ          ณ sejam marcados.                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ALAC                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fValBrow( aBrowse , nPos )

Local nX        := 0
Local nTotLin   := 0
Local cCodCli   := ""
Local lRet      := .F.

Default aBrowse := {}
Default nPos    := 0

If lMark
	aBrowse[nPos][1] := !aBrowse[nPos][1]
	lMark := .F.
Else
	If aBrowse[nPos][1]
		aBrowse[nPos][1] := !aBrowse[nPos][1]
		lMark := .T.
	Endif
	
	If !Empty( aBrowse ) .AND. nPos > 0
		nTotLin           := Len( aBrowse )
		For nX := 1 To nTotLin
			If aBrowse[ nX  , 1 ] //Item jแ marcado
				cCodCli := ( aBrowse[ nX  , 3 ] + aBrowse[ nX  , 4 ] ) //Cod Cli + Loja ---- Exemplo das posi็๕es
				Exit
			Endif
		Next nX
		If !Empty( cCodCli )
			lRet := ( cCodCli == ( aBrowse[ nPos  , 3 ] + aBrowse[ nPos , 4 ] ) )         //Cod Cli + Loja ---- Exemplo das posi็๕es
			If lRet
				aBrowse[nPos][1] := !aBrowse[nPos][1]
			Endif
		Endif
	Endif
Endif

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraExcel บAutor  ณ Marcos Candido    บ Data ณ  07/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia dados do browse para o Ms-Excel                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ALAC                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GeraExcel(aCabExcel,aItExcel)

DlgToExcel({ {"ARRAY", "Exporta็ใo para o Excel", aCabExcel, aItExcel} })

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Excluir   บAutor  ณ Marcos Candido    บ Data ณ  13/06/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Permite usuario filtrar novamente os dados do browse       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ALAC                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Excluir(aBrowse,oConExt,oOK,oNO)

Local lRet  := .F.
Local nQtd  := 0 , nB := 0
Local lCont := .T.
Local cMsg  := "" , cQ := ""
Local aNewBrowse := {}

aEval(aBrowse, {|e| Iif( e[1] , nQtd++ , nQtd+=0 )} )

If nQtd > 0
	lRet := IW_MsgBox("Confirma a exclusใo dos itens selecionados?" , "Aten็ใo" , "YESNO")
Else
	IW_MsgBox("Nenhum registro foi selecionado." , "Aten็ใo" , "INFO")
Endif

If lRet
	
	TCSetConn( nConExt ) // numero da conexao do banco QUALILIMS
	
	For nB:=1 to Len(aBrowse)
		
		If aBrowse[nB,1] // O registro esta selecionado
			
			cQ := "UPDATE FATURAMENTO SET STATUSREG='P' "
			cQ += "WHERE "
			cQ += "CODIGOPROTHEUS = '"+aBrowse[nB,3]+"' AND "
			cQ += "LOJAPROTHEUS   = '"+aBrowse[nB,4]+"' AND "
			cQ += "IDENTIFICACAO  = '"+aBrowse[nB,7]+"'"
			oConExt:TransBegin()
			If !oConExt:SQLExec( cQ )
				cMsg := "Erro na atualizacao dos dados - Erro: " + AllTrim( oConExt:ErrorMessage() )
				lCont := .F.
				oConExt:TransDisarm()
			Endif
			oConExt:TransEnd()
			
		Endif
		
	Next
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Depois que excluํ os registros da base, tenho que atualizar ณ
	//ณ o array aBrowse, para que nao exiba mais os dados que foram ณ
	//ณ deletados.                              	                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lCont
		For nB:=1 to Len(aBrowse)
			If !aBrowse[nB,1] // O registro NAO esta selecionado
				aadd(aNewBrowse ,	{	.F. , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
				aCopy(aBrowse , aNewBrowse , nB ,, Len(aNewBrowse))
			Endif
		Next
		If Len(aNewBrowse) > 0
			aBrowse := aClone(aNewBrowse)
		Else
			aBrowse :=	{	.F. , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""}
		Endif
		
		oBrowse:SetArray(aBrowse)
		oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07],aBrowse[oBrowse:nAt,08],aBrowse[oBrowse:nAt,09],aBrowse[oBrowse:nAt,10],aBrowse[oBrowse:nAt,11],aBrowse[oBrowse:nAt,12],aBrowse[oBrowse:nAt,13],aBrowse[oBrowse:nAt,14] } }
		
	Endif
	
Endif

If !lCont .and. !Empty(cMsg)
	IW_MsgBox(cMsg , "Aten็ใo" , "STOP")
Endif

//TCSetConn( nConALAC ) // numero da conexao do banco padrao do ALAC

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ NoAcento บAutor  ณMicrosiga           บ Data ณ  30/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao emprestada do rdmake NFESEFAZ.PRW                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ALAC                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NoAcento(cString)

Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "แ้ํ๓๚"+"มษอำฺ"
Local cCircu := "โ๊๎๔๛"+"ยสฮิÛ"
Local cTrema := "ไ๋๏๖ü"+"ฤหฯึÜ"
Local cCrase := "เ่์๒๙"+"ภศฬาู"
Local cTio   := "ใ๕รี"
Local cCecid := "็ว"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString
	cString := strTran( cString, cMaior, "" )
EndIf
If cMenor$ cString
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX

Return cString



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINLBCONNECTบAutor  ณ Marcos Candido     บ Data ณ  25/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Exibe tela com as amostras que ja constam em outros       บฑฑ
ฑฑบ          ณ  pedidos de venda, e pergunta ao usuario se continua a     บฑฑ
ฑฑบ          ณ  incluir as revisoes de amostras ou nao.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Alac                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MostraAmostra(aAmostra)

Local oDlgMsg  , cMemo1 := ""  
Local lOk := .T. , nM := 0

cMemo1 := "AMOSTRA"+Space(10)+"NUM. PEDIDO"+CHR(13)+CHR(10)+CHR(13)+CHR(10)

For nM:=1 to Len(aAmostra)
   cMemo1 += aAmostra[nM,1]+Space(10)+aAmostra[nM,2]+CHR(13)+CHR(10)
Next		

DEFINE MSDIALOG oDlgMsg TITLE "Integra็ใo entre sistemas" FROM C(244),C(183) TO C(445),C(600) PIXEL

oFont1 := TFont():New("Calibri",9,14)
oFont2 := TFont():New("Courier New",8,20)                                                        

@ C(009),C(005) Say "Verifique abaixo as amostras que jแ constam nos seguintes pedidos de venda:" Size C(190),C(030) COLOR CLR_RED PIXEL OF oDlgMsg FONT oFont1
@ C(024),C(005) GET oMemo1 Var cMemo1 MEMO When .F. Size C(200),C(066) COLOR CLR_HBLUE PIXEL OF oDlgMsg HSCROLL FONT oFont2
		
ACTIVATE MSDIALOG oDlgMsg ON INIT EnchoiceBar(oDlgMsg,{|| (lOk:=.T.,oDlgMsg:End()) },{|| (lOk:=.F.,oDlgMsg:End()) },,) CENTERED

lOk := IW_MsgBox("Continua o processo de inclusใo de pedidos com essas amostras ?" , "Processamento" , "YESNO")

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()   ณ Autores ณ Norbert/Ernani/Mansano ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolucao horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C(nTam)                                                         

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
	nTam *= 0.8                                                                
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
	nTam *= 1                                                                  
Else	// Resolucao 1024x768 e acima                                           
	nTam *= 1.28                                                               
EndIf                                                                         
                                                                                
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                                               
//ณTratamento para tema "Flat"ณ                                               
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                               
If "MP8" $ oApp:cVersion                                                      
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
		nTam *= 0.90                                                            
	EndIf                                                                      
EndIf                                                                         

Return Int(nTam)
