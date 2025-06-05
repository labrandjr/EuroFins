#Include "Protheus.ch"
#Include "Topconn.ch"

#Define IMP_DISCO  	1
#Define IMP_SPOOL  	2
#Define IMP_EMAIL  	3
#Define IMP_EXCEL  	4
#Define IMP_HTML  	5
#Define IMP_PDF   	6

/*/{Protheus.doc} NFSeMain
Rotina principal de geração de NFSe em PDF
@type function
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
@link https://gkcmp.com.br (Geeker Company)
@return variant, Nil
/*/
User function NFSeMain(aParam)
    local cPerg		:= "NFSEMAIN" //-Limite: 10 caracteres
	local cTitulo1	:= FunName()+" - "+FunDesc()
	local cMsg1		:= 'Processamento a geração dos PDFs...'
	local lAborta1	:= .F.

	private oNFSePDF
	private aLjArea	:= Lj7GetArea({"SX1","SC5","SC6","SC9","SD2","SF2"})

	// default aParam := ({ cFilNFSe,cNumNFSe,cSerNFSe,cNFSeCli,cNFSeLoj,cModNFSe,cFullPath })
	default aParam  := { "", "", "", "", "", "", "" }

	//--->>>> Trecho utilizando durante o Desenvolvimento e Testes da rotina <<<<---// ((???))
	// if GetTempPath() <> "C:\Users\adema\AppData\Local\Temp\"
	// 	MsgAlert(OemToAnsi("TAKE EASY... Rotina ainda em construção !!!"),FunDesc())
	// 	Return
	// endif

	oNFSePDF := NFSeMain():new_NFSeMain()
	oNFSePDF:cPerg := cPerg

	//-Verifica quais Filiais podem processar essa rotina
	Processa({|| oNFSePDF:verFiliais_NFSeMain()}, cTitulo1, cMsg1, lAborta1)

    if( Empty(oNFSePDF:cError) )
	
		//-Verifica se a Filial passada pode processar a NFSe
		if !Empty(aParam[1])

			if !( aParam[1] $ oNFSePDF:cFilProc )
				lAborta1 := .T.
			endif
		else
			if !( cFilAnt $ oNFSePDF:cFilProc )
				lAborta1 := .T.
			endif
		endif

		if lAborta1
			oNFSePDF:cError := "Esta rotina funciona apenas nas Filiais abaixo: "+CRLF
			oNFSePDF:cError += "-> " + oNFSePDF:cFilProc
			MsgAlert(OemToAnsi(oNFSePDF:cError), OemToAnsi(oNFSePDF:cNomEmp+"Atenção!"))
		else
			//-Processa apenas se Filiais de Indaiatuba/Recife (0100/0101/)
			oNFSePDF:cFilProc := aParam[1]
			Processa({|| oNFSePDF:execMain_NFSeMain(aParam)}, cTitulo1, cMsg1, lAborta1)
		endif

		Lj7RestArea(aLjArea)
	endif

Return Nil

/*/{Protheus.doc} NFSeMain
Classe principal de geração de NFSe em PDF
@type class
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
/*/
Class NFSeMain

	data cError			&& Variavel preenchida caso ocorra algum erro na rotina/processo 
	data cNomEmp		&& Nome da Empresa entre conchetes
	data cAlias1Q		&& alias da query principal a ser processada
	data cPerg			&& nome da pergunta (sx1) a utilizar nos filtros
	data cCliente
	data cLoja
	data cFilNFSe
	data cNumNFSe
	data cSerNFSe
	data cModNFSe
	data cFontNFSe
	data cAliasMod
	data lDelPdfs
	data cFilProc

	method new_NFSeMain() constructor

	method execMain_NFSeMain(aParam)		// Executa a chamada dos metodos na ordem
	method verFiliais_NFSeMain()			// Verifica quais Filiais podem ter processamento (???_FILPRC)
	method validParam_NFSeMain(aParam)		// Valida os parametros passados
	method createSx1_NFSeMain()				// Cria as Perguntas, se necessario
	method createPath_NFSeMain(aParam)		// Criar as Pastas utilizadas para gravar o PDF
	method getProtheus_NFSeMain()			// Busca no Protheus os dados necessarios
	method procRelat_NFSeMain()				// Inicia o processamento das informaçoes
	method delArqPdf_NFSeMain(cFullPath)	// Deleta os arquivos PDF da pasta criada/utilizada

	method getMensag_NFSeMain()				// Monta as mensagens a serem impressas na NFSe
	method getMsgDupl_NFSeMain()			// Busca e monta a mensagem complementar das duplicatas

endClass

/*/{Protheus.doc} new_NFSeMain
Metodo Construtor
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
/*/
method new_NFSeMain() class NFSeMain

    ::cError	:= ""
    ::cNomEmp	:= "["+Upper(Substr(SM0->M0_NOMECOM,1,AT(" ",SM0->M0_NOMECOM)-1))+"] "
	::cAlias1Q	:= ""
	::cPerg		:= ""
	::cCliente	:= ""
	::cLoja		:= ""
	::cFilNFSe	:= ""
	::cNumNFSe	:= ""
	::cSerNFSe	:= ""
	::cModNFSe	:= ""
	::cFontNFSe	:= ""
	::cAliasMod	:= "ZZN"	//-Cadastro de Modelos de NFSe
	::lDelPdfs	:= SuperGetMV("ZZ_DELPDF",.F.,.F.)
	::cFilProc	:= ""

return

/*/{Protheus.doc} execMain_NFSeMain
Metodo que executa os metodos em ordem de execuçao
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
@param aParam, array, Informaçoes pra pesquisar a NF Serviço ({ cFilNFSe,cNumNFSe,cSerNFSe,cNFSeCli,cNFSeLoj,cModNFSe,cFullPath })
/*/
method execMain_NFSeMain(aParam) class NFSeMain

    if( Empty(::cError) )
        ::validParam_NFSeMain(aParam)
    endIf

    if( Empty(::cError) )
        ::createPath_NFSeMain(aParam)
    endIf

    if( Empty(::cError) )
        ::getProtheus_NFSeMain()
    endIf

    if( Empty(::cError) )
        ::procRelat_NFSeMain()
    endIf

	if !Empty(::cAlias1Q) .And. Select(::cAlias1Q) > 0
		(::cAlias1Q)->(dbCloseArea())
	endif

return

/*/{Protheus.doc} NFSeMain::verFiliais_NFSeMain
Metodo que verifica quais Filiais podem ter processamento (???_FILPRC)
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 17/04/2023
/*/
method verFiliais_NFSeMain() class NFSeMain
	local nTReg		:= 0
	local cQuery2	:= ""
	local cAlias2Q	:= ""

	//-Busca as Filiais cadastradas na tabela ZZN -  &(::cAliasMod+"_FONTE")
	cQuery2 += " SELECT DISTINCT "+(::cAliasMod+"_FILPRC")
	cQuery2 += " FROM "+RetSqlName(::cAliasMod)
	cQuery2 += " WHERE D_E_L_E_T_ = ' ' "
	cQuery2 += " ORDER BY "+(::cAliasMod+"_FILPRC")

	cQuery2 := ChangeQuery(cQuery2)

	cAlias2Q := GetNextAlias()
	if !Empty(cAlias2Q) .And. Select(cAlias2Q) > 0
		(cAlias2Q)->(dbCloseArea())
	endif
	TcQuery cQuery2 New Alias (cAlias2Q)

	COUNT to nTReg
	(cAlias2Q)->(dbGoTop())

	if nTReg > 0
		While !Eof()
			::cFilProc += &(::cAliasMod+"_FILPRC")+"/"
			dbSkip()
		EndDo
	else
		::cError := "Não foi encontrada nenhuma Filial cadastrada nos Modelos de E-mail."+CRLF
		::cError += "Por favor, cadastre pelo menos os Modelos abaixo:"+CRLF
		::cError += "- Indaiatuba "+CRLF
		::cError += "- Recife "+CRLF

		MsgAlert(OemToAnsi(::cError), OemToAnsi(::cNomEmp+"Atenção!"))
	endif

return

/*/{Protheus.doc} validParam_NFSeMain
Metoddo que valida os parametros passados
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
@param aParam, array, Informaçoes pra pesquisar a NF Serviço ({ cFilNFSe,cNumNFSe,cSerNFSe,cNFSeCli,cNFSeLoj,cModNFSe })
/*/
method validParam_NFSeMain(aParam) class NFSeMain

	dbSelectArea("SX1")
	dbSetOrder(1)	//-X1_GRUPO+X1_ORDEM

	//-cFilNFSe,cNumNFSe,cSerNFSe,cNFSeCli,cNFSeLoj,cModNFSe
	if Empty(aParam[2]) //-Nao está posicionado na NF Serviço

		if !dbSeek(PadR(::cPerg, Len(SX1->X1_GRUPO)), .F.)
			::createSx1_NFSeMain()
		endif
		
		//-Limpa os parametros para forçar recarregar
		MV_PAR01 := ""	//-Modelo da NFSe - Tabela ZZN
		MV_PAR02 := 1	//-Imprime em Lote = SIM
		MV_PAR03 := ""	//-Cliente De
		MV_PAR04 := ""	//-Loja De
		MV_PAR05 := ""	//-Cliente Ate
		MV_PAR06 := ""	//-Loja Ate
		MV_PAR07 := ""	//-NF Serviço De
		MV_PAR08 := ""	//-Serie NFSe De
		MV_PAR09 := ""	//-NF Serviço Ate
		MV_PAR10 := ""	//-Serie NFSe Ate

		if !Pergunte(::cPerg, .T.)
			Lj7RestArea(aLjArea)
			Return Nil
		endif

		//-Atualiza o MV_PAR21 e MV_PAR22 para não conflitar com os PEs
		::cModNFSe	:= Alltrim(MV_PAR01)
		MV_PAR21	:= ::cModNFSe
		MV_PAR22	:= MV_PAR02	//-Imprime em Lote = NAO
	else
		//-cFilNFSe,cNumNFSe,cSerNFSe,cNFSeCli,cNFSeLoj,cModNFSe
		::cFilNFSe	:= aParam[1]
		::cNumNFSe	:= aParam[2]
		::cSerNFSe	:= aParam[3]
		::cCliente	:= aParam[4]
		::cLoja		:= aParam[5]
		::cModNFSe	:= iif(len(aParam) >= 6, aParam[6], "" )
		
		//-Atualiza o MV_PAR21 e MV_PAR22 para não conflitar com os PEs
		MV_PAR21	:= ::cModNFSe
		MV_PAR22	:= 2	//-Imprime em Lote = NAO
	endif

	if Empty(::cModNFSe)
		::cError := "Modelo de NFSe não informado!"
		MsgAlert(OemToAnsi(::cError), OemToAnsi(::cNomEmp+"Atenção!"))
	else
		dbSelectArea(::cAliasMod)
		dbSetOrder(1)

		if !dbSeek(xFilial(::cAliasMod) + ::cModNFSe,.F.)
			::cError := "Modelo de NFSe não encontrado no cadastro!"
			MsgAlert(OemToAnsi(::cError), OemToAnsi(::cNomEmp+"Atenção!"))
		else
			::cFontNFSe := Alltrim((::cAliasMod)->( &(::cAliasMod+"_FONTE") ))
		endif

		if Empty(::cFontNFSe)
			::cError := "Programa-fonte para executar a Geração da NFSe não informado no cadastro!"
			MsgAlert(OemToAnsi(::cError), OemToAnsi(::cNomEmp+"Atenção!"))
		else
			if !ExistBlock(SubStr(Alltrim(::cFontNFSe),3))
				::cError := "Programa-fonte para executar a Geração da NFSe não está compilado neste ambiente!"
				MsgAlert(OemToAnsi(::cError), OemToAnsi(::cNomEmp+"Atenção!"))
			endif
		endif
	endif

return

/*/{Protheus.doc} NFSeMain::createSx1_NFSeMain
Metodo que cria o Grupo de Perguntas caso ainda nao exista
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
/*/
method createSx1_NFSeMain() class NFSeMain
	Local a1Area := GetArea()
	local cPerg	 := PADR(::cPerg, Len(SX1->X1_GRUPO))
	Local aRegs  := {}
    Local i,j

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs, {cPerg, "01", "Modelo da NFSe "		,"" ,"" ,"mv_ch1", "C", 06, 0, 0, "G", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ::cAliasMod })
	aAdd(aRegs, {cPerg, "02", "Impressão em Lote "	,"" ,"" ,"mv_ch2", "N", 01, 0, 1, "C", "", "MV_PAR02", "1-Sim"			, "1-Sim", "1-Sim", "", "", "2-Não", "2-Não", "2-Não", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
	aAdd(aRegs, {cPerg, "03", "Cliente De "        	,"" ,"" ,"mv_ch3", "C", 06, 0, 0, "G", "", "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1" })
	aAdd(aRegs, {cPerg, "04", "Loja De "       		,"" ,"" ,"mv_ch4", "C", 02, 0, 0, "G", "", "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
	aAdd(aRegs, {cPerg, "05", "Cliente Ate "       	,"" ,"" ,"mv_ch5", "C", 06, 0, 0, "G", "", "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1" })
	aAdd(aRegs, {cPerg, "06", "Loja Ate "      		,"" ,"" ,"mv_ch6", "C", 02, 0, 0, "G", "", "MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
	aAdd(aRegs, {cPerg, "07", "NF Serviço De "     	,"" ,"" ,"mv_ch7", "C", 09, 0, 0, "G", "", "MV_PAR07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SF2" })
	aAdd(aRegs, {cPerg, "08", "Serie NFSe De "		,"" ,"" ,"mv_ch8", "C", 03, 0, 0, "G", "", "MV_PAR08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
	aAdd(aRegs, {cPerg, "09", "NF Serviço Ate "    	,"" ,"" ,"mv_ch9", "C", 09, 0, 0, "G", "", "MV_PAR09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SF2" })
	aAdd(aRegs, {cPerg, "10", "Serie NFSe Ate "		,"" ,"" ,"mv_chA", "C", 03, 0, 0, "G", "", "MV_PAR10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				EndIf
			Next
			MsUnlock()
		EndIf
	Next

	RestArea(a1Area)
Return

/*/{Protheus.doc} NFSeMain::createPath_NFSeMain
Metoddo para criar as Pastas utilizadas para gravar o PDF
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 06/04/2023
@param aParam, array, Informaçoes pra pesquisar a NF Serviço ({ cFilNFSe,cNumNFSe,cSerNFSe,cNFSeCli,cNFSeLoj,cModNFSe,cFullPath })
@param cFullPath, character, Caminho completo para limpar/gravar os PDFs
/*/
method createPath_NFSeMain(aParam) class NFSeMain
	Local i
	Local aPath
	Local cDrive
	Local cPasta
	Local cName
	Local cDirPDF

	default aParam := {	"",;		//-01
						"",;		//-02
						"",;		//-03
						"",;		//-04
						"",;		//-05
						"",; 		//-06
						GetSrvProfString("ROOTPATH","")+SuperGetMV("ZZ_NFSEPDF",.F.,"\NFSE\") }	//-07-cFullPath
	
	cFullPath := iif( !Empty(aParam[7]), Alltrim(aParam[7]), GetSrvProfString("ROOTPATH","")+SuperGetMV("ZZ_NFSEPDF",.F.,"\NFSE\") )

	cDirPDF	:= cFullPath	// +Alltrim(RetCodUsr())+"\"
	
	//-Limpa conteudo dos diretorios, antes do processamento
	::delArqPdf_NFSeMain(cFullPath)

	/*
	SplitPath( 'c:\path\20230406\arquivo.ext', @cDrive, @cDir, @cNome, @cExt )
	- Retorna o seguinte:
	cDrive // Resultado: "c:"
	cDir   // Resultado: "\path\20230406\"
	cNome  // Resultado: "arquivo"
	cExt   // Resultado: ".ext"
	*/
	//-SplitPath ( <cArquivo>, [@cDrive], [@cDiretorio], [@cNome], [@cExtensao] )
	SplitPath(cDirPDF, @cDrive, @cDirPDF, @cName,)

	cPasta := ""
	cDrive := iif(ExistDir(cDrive), cDrive, "C:")
	aPath  := StrToKarr(cDirPDF,"\")
	For i:=1 to Len(aPath)
		cPasta += "\"+aPath[i]
		if !ExistDir( cDrive + cPasta )
			MakeDir( cDrive + cPasta )
		endif
	Next                 

Return

/*/{Protheus.doc} NFSeMain::delArqPdf_NFSeMain
Metoddo para deletar os arquivos Pdfs criadas/utilizadas
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 24/04/2023
@param cFullPath, character, Caminho completo para limpar/gravar os PDFs
/*/
method delArqPdf_NFSeMain(cFullPath) class NFSeMain
	Local nX
	Local aFilesPDF

	default cFullPath := GetSrvProfString("ROOTPATH","")+SuperGetMV("ZZ_NFSEPDF",.F.,"\NFSE\")	// +Alltrim(RetCodUsr())+"\"
	
	//-Limpa conteudo dos diretorios, antes do processamento
	if ::lDelPdfs

		aFilesPDF := Directory(cFullPath+"*.PDF" )
		For nX := 1 to Len(aFilesPDF)
			FErase(cFullPath+aFilesPDF[nX,1])
		Next

		aFilesPDF := Directory(cFullPath+"*.REL")
		For nX := 1 to Len(aFilesPDF)
			FErase(cFullPath+aFilesPDF[nX,1])
		Next

	endif

Return

/*/{Protheus.doc} NFSeMain::getProtheus_NFSeMain
Metoddo para buscar no Protheus os dados necessarios
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
/*/
method getProtheus_NFSeMain() class NFSeMain
	local nTReg1	:= 0
	local cQuery1	:= ""

	cQuery1 += "SELECT * "
	cQuery1 += "FROM "+RetSqlName("SF2")+" SF2 "

	cQuery1 += "INNER JOIN "+RetSqlName("SD2")+" SD2 "
	cQuery1 += "	ON  SD2.D_E_L_E_T_ = ' ' "
	cQuery1 += "	AND D2_FILIAL  = F2_FILIAL "
	cQuery1 += "	AND D2_CLIENTE = F2_CLIENTE "
	cQuery1 += "	AND D2_LOJA    = F2_LOJA "
	cQuery1 += "	AND D2_DOC     = F2_DOC "
	cQuery1 += "	AND D2_SERIE   = F2_SERIE "

	cQuery1 += "WHERE SF2.D_E_L_E_T_ = ' ' "
	if MV_PAR22 == 1	//-Considera as Perguntas? - SIM
		cQuery1 += "	AND F2_FILIAL  = '"+ xFilial("SF2") +"' "
		cQuery1 += "	AND F2_CLIENTE BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR05 +"' "
		cQuery1 += "	AND F2_LOJA    BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR06 +"' "
		cQuery1 += "	AND F2_DOC     BETWEEN '"+ MV_PAR07 +"' AND '"+ MV_PAR09 +"' "
		cQuery1 += "	AND F2_SERIE   BETWEEN '"+ MV_PAR08 +"' AND '"+ MV_PAR10 +"' "
	else
		cQuery1 += "	AND F2_FILIAL = '"+ ::cFilNFSe +"' "
		cQuery1 += "	AND F2_DOC    = '"+ ::cNumNFSe +"' "
		cQuery1 += "	AND F2_SERIE  = '"+ ::cSerNFSe +"' "
	endif
	//-Validaçoes solicitadas no DOC SDP
	cQuery1 += "	AND F2_NFELETR > '' "
	cQuery1 += "	AND F2_EMINFE > '' "
	cQuery1 += "	AND F2_HORNFE > '' "
	cQuery1 += "	AND F2_CODNFE > '' "

	cQuery1 += "ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_COD,D2_ITEM "

	cQuery1 := ChangeQuery(cQuery1)

	::cAlias1Q := GetNextAlias()
	if !Empty(::cAlias1Q) .And. Select(::cAlias1Q) > 0
		(::cAlias1Q)->(dbCloseArea())
	endif
	TcQuery cQuery1 New Alias (::cAlias1Q)

	COUNT to nTReg1
	(::cAlias1Q)->(dbGoTop())

	if nTReg1 == 0
		::cError := "Nenhuma NFSe encontrada para os filtros informados!"
		MsgAlert(OemToAnsi(::cError), OemToAnsi(::cNomEmp+"Atenção!"))
	endif

return

/*/{Protheus.doc} NFSeMain::procRelat_NFSeMain
Metodo que faz o processamento das informaçoes e chama a rotina da NF Serviço
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 03/04/2023
/*/
method procRelat_NFSeMain() class NFSeMain

	dbSelectArea(::cAlias1Q)

	if MV_PAR22 == 2	//-Considera as Perguntas? - NAO
		
		(::cAlias1Q)->( &(::cFontNFSe) )

	else
		While !Eof()

			(::cAlias1Q)->( &(::cFontNFSe) )

			dbSelectArea(::cAlias1Q)
			dbSkip()
		EndDo
	endif

Return

/*/{Protheus.doc} NFSeMain::getMensag_NFSeMain
Metodo que monta as mensagens a serem impressas na NFSe
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 14/04/2023
/*/
method getMensag_NFSeMain() class NFSeMain
	Local cPedido := ""
	Local cMsgObs := ""
	Local cMsgDup := ""
	Local cLei	  :=SuperGetMV("MV_ZZLEINF",.F.,"") //COLOCA MENSAGEM DA LEI
	Local cAuxLei := ""
	local a1Area  := GetArea()
	local a2Area  := SD2->( GetArea() )

	/*
	Regras copiadas dos fontes abaixo:
	...\eurofins-desenv\NF-Servicos\Ja-Existem\ExpRPS.prw
	...\eurofins-deles\Sefaz\NFSe\Function\NFSE_Anatec\nfsAnatec.prw
	*/

	//-Tabela SC5 foi posicionada no inicio da rotina de geração do PDF
	If !Empty(SC5->C5_MENPAD)
		If !(Alltrim(Substr(FORMULA(SC5->C5_MENPAD),1,100)) $ cMsgObs)
			cMsgObs += iif(!Empty(cMsgObs)," | ","")
			cMsgObs += Alltrim(Substr(FORMULA(SC5->C5_MENPAD),1,100))+" "
		Endif
	Endif
/*
	If !Empty(SC5->C5_MENNOTA)
		If !(Alltrim(Upper(SC5->C5_MENNOTA)) $ cMsgObs)
			cMsgObs += iif(!Empty(cMsgObs)," | ","")
			cMsgObs += Alltrim(Upper(SC5->C5_MENNOTA))+" "
		Endif
	Endif
*/

	If !Empty(cLei) 
		cAuxLei := AllTrim(FORMULA(cLei))

		If !Empty(cAuxLei) .And. !(cAuxLei $ cMsgObs)
			cMsgObs += iif(!Empty(cMsgObs)," | ","")
			cMsgObs += Upper(cAuxLei)
		EndIf
	EndIf

	//Foi necessário retirar a função acima, pois na hora da impressão das notas, pode haver muitos pedidos de venda vinculados a nf
	GetMenNota(@cPedido)
	
	dbSelectArea("SD2")
	dbSetOrder(3)	//-D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.f.)

	While !Eof() .And.;
		SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA

		If Posicione("SC6",1,xFilial("SC6")+SD2->(D2_PEDIDO+D2_ITEMPV),"!Empty(C6_PEDCLI)")
			If !Alltrim(SC6->C6_PEDCLI) $ cPedido .and. !Alltrim(SC6->C6_PEDCLI) $ cMsgObs
				cPedido += IIf(Empty(cPedido),"",", ")+Alltrim(SC6->C6_PEDCLI)
			Endif
		Endif

		dbSkip()
	Enddo

	If !Empty(cPedido)
		cMsgObs += iif(!Empty(cMsgObs)," | ","")
		//A pedido da Renata Pereira, isso não é pra ser impresso na filial 0604
		cMsgObs += iif(cFilAnt <> "0604","NUM. SEU(S) PEDIDO(S): ","")+cPedido
	Endif

	//-----------------------------------------
	cMsgDup := ::getMsgDupl_NFSeMain()
	//-----------------------------------------

	if !Empty(cMsgDup)
		cMsgObs += iif(!Empty(cMsgObs)," | ","")
		cMsgObs += Alltrim(cMsgDup)
	else
		cMsgObs += iif(!Empty(cMsgObs)," | ","")
		cMsgObs += "DATA DE VENCIMENTO DESTA NFS-e: "+DTOC(SE1->E1_VENCREA)
	endif

	RestArea(a2Area)
	RestArea(a1Area)

Return cMsgObs

/*/{Protheus.doc} NFSeMain::getMsgDupl_NFSeMain
Metodo que busca e monta a mensagem complementar das duplicatas
@type method
@version 1.0
@author Ademar Fernandes Jr.
@since 14/04/2023
/*/
method getMsgDupl_NFSeMain() class NFSeMain
	Local nRetPis := SuperGetMv( "MV_ZZRTPIS")
	Local nRetCof := SuperGetMv( "MV_ZZRTCOF")
	Local nRetCsl := SuperGetMv( "MV_ZZRTCSL")
	Local nVlrImp  := 0
	Local nValIRRF := 0
	Local nValPIS  := 0
	Local nValCOFI := 0
	Local nValCSLL := 0
	Local aDuplic  := {}
	Local cDuplic  := ""
	Local nD

	BeginSql Alias "WSE1"
		Select E1_PARCELA, E1_PIS, E1_COFINS, E1_CSLL, E1_VALOR, E1_VENCTO, E1_TIPO
		From %Table:SE1%
		Where %NotDel% and E1_FILIAL=%xFilial:SE1% 
		and	E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM = %Exp:SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)% 
		and	E1_TIPO IN ('NF ','IR-','FT ')
	EndSql

	While WSE1->(!Eof())

		If WSE1->E1_TIPO == "NF " .or. WSE1->E1_TIPO == "FT "
			WSE1->(aadd(aDuplic , {DtoC(Stod(E1_VENCTO)), E1_VALOR, E1_PARCELA}))

			nValPIS  += WSE1->(iif(E1_PIS   >= nRetPis, E1_PIS, 0))
			nValCOFI += WSE1->(iif(E1_COFINS>= nRetCof, E1_COFINS, 0))
			nValCSLL += WSE1->(iif(E1_CSLL  >= nRetCsl, E1_CSLL, 0))

		ElseIf WSE1->E1_TIPO == "IR-"
			nValIRRF += WSE1->E1_VALOR
		Endif
		WSE1->(dbSkip())
	Enddo
	WSE1->(DbCloseArea())
	
	If Len(aDuplic) > 0
		cDuplic  := "DUPLICATAS - "

		For nD:=1 to Len(aDuplic)
			If nD==1
				nVlrImp := nValIRRF + nValPIS + nValCOFI + nValCSLL
			Else
				nVlrImp := 0
			Endif
			nVlr := aDuplic[nD][2]-nVlrImp
			nVlr := Alltrim(Transform(nVlr,"@E 999,999,999.99"))

			if (::cAliasMod)->( &(::cAliasMod+"_CODMUN") )	== "20509"	//-Indaiatuba
				cDuplic += "Vencto: "+aDuplic[nD][1]+", Valor: "+nVlr+", Parcela: "+Iif(Empty(aDuplic[nD][3]),"UNICA",aDuplic[nD][3])+" | "
			else
				cDuplic += "Vencto: "+aDuplic[nD][1]+", Parcela: "+Iif(Empty(aDuplic[nD][3]),"UNICA",aDuplic[nD][3])+" | "
			endif
		Next
		
		cDuplic := SubStr(Alltrim(cDuplic), 1, (Len(cDuplic)-2))
	Else
		cDuplic := ""
	Endif	

Return cDuplic

/*
Busca todos os dados do campo C5_MENNOTA de todos os pedidos de venda vinculados a NF
Régis Ferreira - 22/05/2024
*/
Static Function GetMenNota(cMsgObs)

	Local cQueryPed := ""
	Local cAliasPed := GetNextAlias()
	Local cMenNota	:= ""

	cQueryPed := " Select 															" + CRLF
	cQueryPed += " 		DISTINCT C5_MENNOTA 										" + CRLF
	cQueryPed += " From " + RetSqlName("SC5") + " SC5 								" + CRLF
	cQueryPed += " Where 															" + CRLF
	cQueryPed += " 		1=1															" + CRLF
	cQueryPed += " 		And C5_FILIAL = '"+xFilial("SC5")+"'						" + CRLF
	cQueryPed += " 		And C5_NUM in (												" + CRLF
	cQueryPed += " 						Select 										" + CRLF
	cQueryPed += " 							Distinct D2_PEDIDO 						" + CRLF
	cQueryPed += " 						From " + RetSqlName("SD2") + " SD2 			" + CRLF
	cQueryPed += " 						Where 										" + CRLF
	cQueryPed += " 							1=1										" + CRLF
	cQueryPed += " 							And SD2.D_E_L_E_T_ = ' '				" + CRLF
	cQueryPed += " 							And D2_DOC = '"+SF2->F2_DOC+"'			" + CRLF
	cQueryPed += " 							And D2_SERIE = '"+SF2->F2_SERIE+"'		" + CRLF
	cQueryPed += " 							And D2_CLIENTE = '"+SF2->F2_CLIENTE+"'	" + CRLF
	cQueryPed += " 							And D2_LOJA = '"+SF2->F2_LOJA+"'		" + CRLF
	cQueryPed += " 							And D2_FILIAL = '"+xFilial("SD2")+"')	" + CRLF
	cQueryPed += " 		And SC5.D_E_L_E_T_= ' ' 									" + CRLF
	cQueryPed += " 		And C5_MENNOTA <> ' '										" + CRLF

	TcQuery cQueryPed New Alias &(cAliasPed)

	(cAliasPed)->(DbGoTop())

	While !(cAliasPed)->(EOF())

		if !Empty((cAliasPed)->C5_MENNOTA)
			cMenNota += IIf(Empty(cMenNota),"",", ")+Upper(Alltrim((cAliasPed)->C5_MENNOTA))
		endif
		(cAliasPed)->(DbSkip())
	enddo

	(cAliasPed)->(DbCloseArea())

	if !Empty(cMenNota)
		cMsgObs += " | "
		cMsgObs += cMenNota+" "
	endif

Return
