#include "rwmake.ch"

/*/{protheus.doc}MT103IPC 
Na nota de entrada atualiza a descricao do produto.
@Author Marcos Candido
@since 18/05/13  
/*/
User Function MT103IPC

	Local nPosAtual := PARAMIXB[1]
	Local nPosDescr := aScan(aHeader,{|x| Alltrim(x[2])== "D1_ZZDESCR"})
	Local nPos1UM   := aScan(aHeader,{|x| Alltrim(x[2])== "D1_UM"})
	Local nPos2UM   := aScan(aHeader,{|x| Alltrim(x[2])== "D1_SEGUM"})
	Local nPosObs 	:= aScan(aHeader,{|x| Alltrim(x[2])== "D1_ZZOBS"})
	Local nPosNCM 	:= aScan(aHeader,{|x| Alltrim(x[2])== "D1_ZZNCM"})
	Local nPosCODF 	:= aScan(aHeader,{|x| Alltrim(x[2])== "D1_ZZCODF"})
	Local nPosTP 	:= aScan(aHeader,{|x| Alltrim(x[2])== "D1_TP"})
	
	If nPosDescr > 0
		aCols[nPosAtual,nPosDescr] := SC7->C7_DESCRI
	Endif
	
	If nPos1UM > 0
	//	aCols[nPosAtual,nPos1UM] := SC7->C7_UM
	Endif
	
	If nPos2UM > 0
	//	aCols[nPosAtual,nPos2UM] := SC7->C7_SEGUM
	Endif
	
	If nPosObs > 0
		aCols[nPosAtual,nPosObs] := SC7->C7_OBS
	Endif
	
	If nPosNCM > 0
		aCols[nPosAtual,nPosNCM] := Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_POSIPI")
	Endif
	
	If nPosCODF > 0
		aCols[nPosAtual,nPosCODF] := Posicione("SA5",1,xFilial("SA5")+CA100For+cLoja+SC7->C7_PRODUTO,"A5_CODPRF")
	Endif
	
	If nPosTP > 0
		aCols[nPosAtual,nPosTP] := Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TIPO")
	Endif

Return