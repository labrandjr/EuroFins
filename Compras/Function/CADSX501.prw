#include "Protheus.Ch"
#include "TopConn.Ch"
/*/{protheus.doc}CADSX501
Mostra Tela com a Tabela 42 para sele็ใo do Usuแrio
@author Unknown
@since __/__/____
/*/

User Function CADSX501()

	Local cRet			:= ""
	Local aListHdr 		:= {'','Tipo','Descricao'}
	Local cTitulo		:= "Tipo de Esp้cie"
	Local cTabela		:= "42"
	Local aRegs			:= {} //fLdDados(cTabela)  
	Local bDuploClick   := {|| aRegs[oListBox:nAt,1] := !aRegs[oListBox:nAt,1] }  
	Local bValid 		:= { || ValidArray(@oDlg,@oListBox,@aRegs,oOk,oNo,oListBox:nAt) }
	Local oOk			:= LoadBitmap( GetResources(), "LBOK")
	Local oNo			:= LoadBitMap( GetResources(), "LBNO")
	Local lOk			:= .f.
	Local nI			:= 0
	Public CADSX501		:= ""
	
	aRegs:= fLdDados(cTabela)

	Define MsDialog oDlg Title cTitulo From  10,10 To 30 ,65 
	oDlg:lEscClose := .t.                                                                                                     
	
	oListBox := TWBrowse():New( 01,0,220,130,,aListHdr,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) 
			oListBox:SetArray(aRegs)                  
			oListBox:bLDblClick:= { || aRegs[oListBox:nAt,1] := !aRegs[oListBox:nAt,1] }                          
			oListBox:bHeaderClick 	:= {|| } 
			oListBox:bLine 			:= {|| {iif(aRegs[oListBox:nAt,01],oOk,oNo),;
											aRegs[oListBox:nAt,02] ,;
											aRegs[oListBox:nAt,03]	} }
	
		TButton():New(135,3," Ok ",oDlg,{|| (lOk := .t.), oDlg:End() },35,11,,,.F.,.T.,.F.,,.F.,,,.F.)
		TButton():New(135,42," Cancelar ",oDlg,{|| oDlg:End() },35,11,,,.F.,.T.,.F.,,.F.,,,.F.)
		TButton():New(135,82," Marca Todos ",oDlg,{|| selTodos(@aRegs)  },35,11,,,.F.,.T.,.F.,,.F.,,,.F.)
		TButton():New(135,122," Desmarca Todos ",oDlg,{|| invertTodos(@aRegs) },45,11,,,.F.,.T.,.F.,,.F.,,,.F.)
		
	Activate MsDialog oDlg Centered           
	
	If lOk

		For nI := 1 to Len(aRegs)
				                 
			If aRegs[nI,1] .And. Len(cRet) > 0
				cRet += "/"
			Endif				                
				                
			If aRegs[nI,1]	                            
				cRet += aRegs[nI,2]
			Endif
	     
	    Next nI 

	Endif       
	
	CADSX501 := cRet
	
Return(.t.)                        

Static Function fLdDados(cTabela)
	Local aRet		:= {}
	Local aArea		:= GetArea()
	Local cQry		:= ""

	cQry := "SELECT X5_CHAVE, X5_DESCRI "+CRLF
	cQry += "FROM "+RetSqlName('SX5')+ " "+CRLF
	cQry += "WHERE 	X5_FILIAL = '"+xFilial('SX5')+"' AND "+CRLF
	cQry += "		X5_TABELA = '"+cTabela+"' AND D_E_L_E_T_ = ' ' "+CRLF
	cQry += "ORDER BY X5_CHAVE "+CRLF
	
	TcQuery cQry NEW Alias "TSX5"
	
	While TSX5->(!Eof())                              
	
		aAdd(aRet, {.f., TSX5->X5_CHAVE, TSX5->X5_DESCRI } )

		TSX5->(DbSkip())
	Enddo
                                           
	TSX5->(DbCloseArea())
	       
	RestArea(aArea)	
Return(aRet)                                                                


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑณFun็ใo    ณValidArrayณ Autor ณGerson Rovere Schiavo  ณ Data ณ 10/10/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ                                                             ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidArray(oDlg,oListBox,aRegs,oOk,oNo,nPos)

Local lMarca	:=	.f.

For t := 1 to Len(aRegs)
	if	aRegs[t,1] 
		lMarca := .t.
	endif
Next t

if	lMarca
	For	k := 1 to Len(aRegs)
		if	k <> nPos
			aRegs[k,1]	:=	.f.
		endif
	Next k
endif
                   
oListBox:SetArray(aRegs)
oListBox:bLine		:= { || { iif(aRegs[oListBox:nAt,01],oOk,oNo),aRegs[oListBox:nAt,03], aRegs[oListBox:nAt,02]} }

oListBox:Refresh()
oDlg:Refresh()

Return ( .t. )             

Static Function selTodos(aRegs)
	For t := 1 to Len(aRegs)
		aRegs[t,1] := .T.
	Next t

	oListBox:Refresh()
	oDlg:Refresh()

Return ( .t. )

Static Function invertTodos(aRegs)
	For t := 1 to Len(aRegs)
		if aRegs[t,1]
			aRegs[t,1] := .F.
		else
			aRegs[t,1] := .T.
		endIf
	Next t

	oListBox:Refresh()
	oDlg:Refresh()

Return ( .t. ) 

