#Include 'Protheus.ch'
#Include 'RWMAKE.CH'
/*/{protheus.doc}ALTPAR 
Permite alterar alguns parâmetros
@author	Evandro de Almeida  
@since 28/11/2012   

/*/


User Function ALTPAR()

// Defini  o das vari veis do programa.
Public _mvDatafis := GetMv("MV_DATAFIS")
Public _mvDatafin := GetMv("MV_DATAFIN")
Public _mvDatarec := GetMv("MV_DATAREC")
Public _mvDataest := GetMv("MV_DBLQMOV")
Public _zzUsuario := GetMv("ZZ_ALTPAR")

// Verifica se o usu rio   o Administrador do sistema ou usu rios autorizados.

If !RetCodUsr() $ _zzUsuario
	Alert("Somente usu rios autorizados podem executar esta rotina.")
	Return
EndIf


// Solicita ao usu rio nome do arquivo.
@ 150,  1 TO 400, 435 DIALOG oMyDlg TITLE OemToAnsi("Bloqueio de Par metros")
@   2, 10 TO 110, 210
@  10, 12 Say " Data limite p/opera  es fiscais (MV_DATAFIS) ?"
@  10,155 Get _mvDatafis Size 50,50
@  20, 12 Say " Data limite p/opera  es financeiras (MV_DATAFIN)?"
@  20,155 Get _mvDatafin Size 50,50
@  30, 12 Say " Data limite p/reconcilia  o banc. (MV_DATAREC)?"
@  30,155 Get _mvDatarec Size 50,50
@  40, 12 Say " Data limite p/movimenta  es do estoque (MV_DBLQMOV)?"
@  40,155 Get _mvDataest Size 50,50
@  50, 12 Say "  ltimo fech.estoque (MV_ULMES): " + Transform(GETMV("MV_ULMES"),"@D")
@  60, 12 Say "  ltimo c lc.deprec. (MV_ULTDEPR): " + Transform(GETMV("MV_ULTDEPR"),"@D")
@  70, 12 Say ""
@  80, 12 Say ""
@  90, 12 Say ""
@ 110,150 BMPBUTTON TYPE 01 ACTION (RunProc(), Close(oMyDlg))
@ 110,180 BMPBUTTON TYPE 02 ACTION Close(oMyDlg)
Activate Dialog oMyDlg Centered

Return


Static Function RunProc()

//Funcao	:RUNPROC   
//Autor		:Evandro de Almeida  
//Data		:28/11/2012   
//Descricao	:Fun  o para alterar os par metros.     
//Uso		:Fun  o ALTPAR                                   
//+------------------------------------------------------------------------------+
//| Data       | Responss vel       | Altera  es                                 |
//|-------------------------------------------------------------------------------
//| 28/11/2012 | Evandro de Almeida | Altera  es para atendimento as regras do   |
//|            |                    | CNPEM                                      |
//+------------------------------------------------------------------------------+

// Faz valida  es e Altera os par metros. 
If !Empty(_mvDatafis)
	PutMv("MV_DATAFIS",_mvDatafis)
Else
	Alert("Data limite p/opera  es fiscais em branco.")
EndIf

If !Empty(_mvDatafin)
	PutMv("MV_DATAFIN",_mvDatafin)   
Else
	Alert("Data limite p/opera  es financeiras em branco.")
EndIf

If !Empty(_mvDatarec)
	If _mvDatarec < GETMV("MV_DATAFIN")
		Alert("Data limite para reconcilia  o banc ria menor ou igual a data limite de mov.financeiras.")
	Else
		PutMv("MV_DATAREC",_mvDatarec)
	EndIf
Else
	Alert("Data limite p/reconcilia  o banc. em branco.")
EndIf

If !Empty(_mvDataest)
	If _mvDataest < GETMV("MV_ULMES")
		Alert("Data limite para movimenta  es do estoque n o pode ser menor que a data de fechamento.")
	Else
		PutMv("MV_DBLQMOV",_mvDataest)
	EndIf
Else
	Alert("Data limite p/movimenta  es do estoque em branco.")
EndIf

Return