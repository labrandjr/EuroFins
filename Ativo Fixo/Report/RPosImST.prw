#include "totvs.ch"
/*/{protheus.doc}RPOSIMST
Relatorio de posição do ativo imobilizado sintético.
@author Sergio Braz
@since 11/10/2019
/*/
User Function RPosImSt
	Local cOldFil := cFilAnt
	If AskMe()
		Processa({|| GeraXLS()},"Aguarde! Gerando Planilha.")
	Endif
	cFilAnt := cOldFil
Return

Static Function AskMe                  
	Local aPergs := {}         
	AADD(aPergs,{1,'Filial de' ,CriaVar("A1_FILIAL",.F.),"@!",'.T.','SM0','.T.',60,.F.})
	AADD(aPergs,{1,'Filial até',CriaVar("A1_FILIAL",.F.),"@!",'.T.','SM0','.T.',60,.F.})
	AADD(aPergs,{1,'Conta Contábil de',CriaVar("N5_CONTA",.F.),"@!",'.T.','CT1','.T.',80,.F.})
	AADD(aPergs,{1,'Conta Contábil até',CriaVar("N5_CONTA",.F.),"@!",'.T.','CT1','.T.',80,.F.})
	AADD(aPergs,{1,'Data (Ano/Mês)',Space(6),"@R 9999/99",'.t.',,'.t.',50,.f.})
	AADD(aPergs,{1,"Tipo de Saldo",CriaVar("N5_TPSALDO",.F.),"@!","ExistCpo('SX5','SL'+MV_PAR06)","SL",".T.",50,.t.})
Return ParamBox(aPergs,"Parametros",{})

User function ooo
	rpcsetenv("01","0100","admin","agis4","ATF")
	define msdialog omainwnd from 0,0 to 800,1400 pixel
	@ 05,05 Button "OK" of omainwnd pixel action u_rposimst()
	activate msdialog omainwnd
Return

Static Function GetData
	BeginSql Alias "N5"
		Select Distinct N5_FILIAL,N5_CONTA
		From %Table:SN5%
		Where %NotDel% and N5_FILIAL Between %Exp:MV_PAR01% and %Exp:MV_PAR02% and 
			N5_CONTA Between %Exp:MV_PAR03% and %Exp:MV_PAR04% AND N5_TPSALDO=%Exp:MV_PAR06%
		Order By N5_FILIAL, N5_CONTA
	EndSql
Return

Static Function GeraXlS
	Local nRegs,nAlign,nType,i
	Local oExcel := FwMsExcel():New()
	Local cFile  := CriaTrab(,.f.)+".xls"
	Local cPath  := GetTempPath()
	Local cPlan  := "Ativo Imobilizado"
	Local cTable := "Posição Ativo Imobilizado Sintético em "+transform(MV_PAR05,"@R 9999/99")    
	Local aCab   := StrToKarr("Filial;Conta;Descrição;Saldo Inicial "+dtoc(Stod(MV_PAR05+"01")-1)+";Adições;Trans.Entradas;Transf.Saídas;Baixas;Saldo Final "+dtoc(lastday(stod(MV_PAR05+"01"))),";")
	Local aType  := {1,1,1,2,2,2,2,2,2}//1=caracter;2=numérico
	Local aAlign := {1,1,1,3,3,3,3,3,3}//1=esquerda;3=direita
	Local aValores  
	Local nInicial,nAdic,nEntr,nSai,nBai,nFinal
	GetData()   
	Count to nRegs
	N5->(DbGoTop())                  
	ProcRegua(nRegs)
	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan,cTable)
	For i:=1 To Len(aCab)
		oExcel:AddColumn(cPlan,cTable,aCab[i],aAlign[i],aType[i],.f.)
	Next
	While N5->(!Eof())
		aValores := {} 
		cFilAnt := N5->N5_FILIAL                           
		Posicione("CT1",1,xFilial("CT1")+N5->N5_CONTA,"")                   
		nInicial := GetType('01249KTUY',.f.) - GetType("58LRSV",.f.) //SALDO INICIAL
		nAdic    := GetType('124KY',.t.)//ADIÇÃO
		nEntr    := GetType('9TU',.t.)//TRANSFERENCIA ENTRADA
		nSai     := GetType('8SV',.t.)//TRANSFERENCIA SAIDA
		nBai     := GetType('5LR',.t.)//BAIXA
		nFinal   := nInicial + nAdic + nEntr - nSai - nBai//SALDO FINAL
		aValores:={N5->N5_FILIAL,N5->N5_CONTA,CT1->CT1_DESC01,nInicial,nAdic,nEntr,nSai,nBai,nFinal}
		oExcel:AddRow(cPlan,cTable,aValores)
		N5->(DBSkip())
		IncProc()
	End
	N5->(DbCloseArea())
	oExcel:Activate()
	oExcel:GetXMLFile(cPath+cFile)
	If File(cPath+cFile)
		If MsgYesNo("Abrir arquivo "+cPath+cFile)
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open(cPath+cFile)
			oExcel:SetVisible(.T.)			
		Endif
	Endif
Return

Static Function GetType(c,lMes)//lmes=se é no mes atual
	Local nResp := 0                  
	Local i          
	Local t:= ""
	For i:=1 to Len(c)
		t+=IIf(empty(t),"",",")+"'"+substr(c,i,1)+"'"
	Next
	t := "%"+t+"%"                    
	If lMes
		BeginSql Alias "II"
			Select Sum(N5_VALOR1) N5_VALOR1
			From %Table:SN5%
			Where %NotDel% and N5_FILIAL = %Exp:N5->N5_FILIAL% and Substring(N5_DATA,1,6) = %Exp:MV_PAR05% and N5_CONTA = %Exp:N5->N5_CONTA% and N5_TIPO In (%Exp:t%) and N5_TPSALDO=%Exp:MV_PAR06%
		EndSql                                                                             
	Else
		BeginSql Alias "II"
			Select Sum(N5_VALOR1) N5_VALOR1
			From %Table:SN5%
			Where %NotDel% and N5_FILIAL = %Exp:N5->N5_FILIAL% and Substring(N5_DATA,1,6) < %Exp:MV_PAR05% and N5_CONTA = %Exp:N5->N5_CONTA% and N5_TIPO In (%Exp:t%) and N5_TPSALDO=%Exp:MV_PAR06%
		EndSql                                                                             	
	Endif
	nResp := II->N5_VALOR1
	II->(DbCloseArea())
Return nResp