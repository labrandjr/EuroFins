#Include "RWMAKE.CH"


/*/{Protheus.doc} UPDPARAM
Programa que permite aos usu�rios configurados no par�metro MV_USERLIB alterar os par�metros de bloqueio.
@author Dione Oliveira
@since 04/04/17
@history 20/02/2018, Thiago Meschiatti, Migra��o de fonte para a vers�o 12.
/*/

User Function UPDPARAM()

// Defini��o das vari�veis do programa.
Public _mvDatafis := GetMv("MV_DATAFIS")
Public _mvDatafin := GetMv("MV_DATAFIN")
Public _mvDatarec := GetMv("MV_DATAREC")   	
Public _mvDblqmov := GetMv("MV_DBLQMOV")
Public _mvDfcEst  := GetMv("MV_ULMES")
Public _mvUserLib := GetMv("MV_USERLIB")

// Verifica se o usu�rio � o Administrador do sistema ou usu�rios autorizados.
If !Alltrim(__cUserID) $ SuperGetMv("MV_USERLIB",.F.,"000000")
	Alert("Somente o Administrador ou usu�rios autorizados podem executar esta rotina. MV_USERLIB")
	Return
EndIf   

// Solicita ao usu�rio nome do arquivo.
	@ 150,  1 TO 400, 435 DIALOG oMyDlg TITLE OemToAnsi("Bloqueio de Par�metros")
	@   2, 10 TO 110, 210
	@  10, 18 Say " Data limite p/opera��es fiscais: " + Transform(GETMV("MV_DATAFIS"),"@D")  
	@  10,140 Get _mvDatafis Size 50,50
	@  20, 18 Say " Data limite p/opera��es financeiras: " + Transform(GETMV("MV_DATAFIN"),"@D")  
	@  20,140 Get _mvDatafin Size 50,50
	@  30, 18 Say " Data limite p/reconcilia��o banc.: " + Transform(GETMV("MV_DATAREC"),"@D")  
	@  30,140 Get _mvDatarec Size 50,50
	@  40, 18 Say " Bloq. Mov. Estoque/Fiscal: " + Transform(GETMV("MV_DBLQMOV"),"@D")  
	@  40,140 Get _mvDblqmov Size 50,50
	@  50, 18 Say " �ltimo fech.estoque: " + Transform(GETMV("MV_ULMES"),"@D")    
	@  50,140 Get _mvDfcEst Size 50,50
	@  60, 18 Say ""
	@  70, 18 Say ""
	@  80, 18 Say ""
	@  90, 18 Say ""
	@ 110,150 BMPBUTTON TYPE 01 ACTION (RunProc(), Close(oMyDlg))
	@ 110,180 BMPBUTTON TYPE 02 ACTION Close(oMyDlg)
	Activate Dialog oMyDlg Centered

Return

Static Function RunProc()

// Faz valida��es e Altera os par�metros. 
	If !Empty(_mvDatafis)
		PutMv("MV_DATAFIS",_mvDatafis)
	EndIf
	
	If !Empty(_mvDatafin)
		PutMv("MV_DATAFIN",_mvDatafin)
	EndIf
	
	If !Empty(_mvDatarec)
		PutMv("MV_DATAREC",_mvDatarec)
	EndIf   
	 
	If !Empty(_mvDblqmov)
		PutMv("MV_DBLQMOV",_mvDblqmov)
	EndIf   

	If !Empty(_mvDfcEst)
		PutMv("MV_ULMES",_mvDfcEst)
	EndIf  
Return