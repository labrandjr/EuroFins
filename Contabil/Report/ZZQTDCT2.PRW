#Include 'Protheus.ch'
#Include "totvs.ch"
#include "topconn.ch"

/*/{protheus.doc}
Gera Planilha Excel referente a quantidade de movimentações do CT2
@author Régis Ferreira
@since 13/07/2021
/*/
User Function ZZQTDCT2()
	Local aParambox	:= {}
	aAdd(aParamBox,{1,"Data Movimentação de :"	,dDataBase,,"","","",70,.T.}) //MV_PAR01
	aAdd(aParamBox,{1,"Data Movimentação até:"	,dDataBase,,"","","",70,.T.}) //MV_PAR02
	If ParamBox(aParamBox,"Quantidade de Movimentações Contabeis",,,,,,,,ProcName(),.T.,.T.)
		Processa({||GeraPlan() },"Gerando Planilha..." )
	Endif
Return

Static Function GeraPlan
	Local cArqNome	:= GetTempPath() + (CriaTrab(Nil,.F.) + ".xls")
	Local cTitulo	:= "Movimentações Contábeis"
	Local aCampos, cCampos,cAlias
	Local oExcel,nAlign,nType,i,aValores
	Local aCab      := StrToKarr("Empresa;Tipo;Quantidade;Valor;% (Valor)",";")
	Local aValores
	Local cFilMOV   := ""
	Local aEmp
	Local cEmp      := ""
	Local aVlr      := {}
	Local f         := 1
    Local nX        := 1
	Local cQuery    := ""
	Local _cSemAuto := .F.
	Local _cSemManual:= .F.

	Set Deleted On
	SM0->(DbGoTop())
	While SM0->(!Eof())
		If SubStr(AllTrim(SM0->M0_CODIGO),1,1) < "99"
			if Empty(cEmp)
				cEmp := SubStr(SM0->M0_CODFIL,1,2)
			else
				if !SubStr(SM0->M0_CODFIL,1,2) $ cEmp
					cEmp += ";"+SubStr(SM0->M0_CODFIL,1,2)
				endif
			endif
		EndIf
		SM0->(DbSkip())
	End
	aEmp := StrToKarr(cEmp,";")
	aSort(aEmp,,,{|x,y| x < y})

	cCampos := "D2_COD,D2_TOTAL,D2_TOTAL,D2_TOTAL,D2_TOTAL"
	aCampos := StrToKarr(cCampos,",")
	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet(cTitulo)
	oExcel:AddTable(cTitulo,cTitulo)

	For i:=1 To Len(aCampos)
		If aCampos[i] == "D2_TOTAL"
			nAlign := 3
			nType  := 2
		Else
			nAlign := 1
			nType  := 1
		Endif
		oExcel:AddColumn(cTitulo,cTitulo,aCab[i],nAlign,nType,.f.)
	Next i

	aValores := {}
	For f:=1 to Len(aEmp)
		cFilMOV := GetFil(aEmp[f]+"00")
		//BeginSql Alias "CT"
		cQuery := " SELECT "+ CRLF
		cQuery += "     'MANUAL' 'TIPO',  "+ CRLF
		cQuery += "     Substring(CT2_FILIAL,1,2) 'FILIAL', "+ CRLF
		cQuery += "     COUNT(CT2_LOTE) 'QTD_REG', "+ CRLF
		cQuery += "     Round(SUM(CT2_VALOR),2) 'VALOR' "+ CRLF
		cQuery += " FROM " + retsqlname("CT2")+ " "+ CRLF
		cQuery += " WHERE "+ CRLF
		cQuery += "     CT2_LOTE NOT IN ('COM001','FIN001','FAT001','EST001','ATF001') AND  "+ CRLF
		cQuery += "     CT2_DATA BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "+ CRLF
		cQuery += "     SubString(CT2_FILIAL,1,2) = '"+aEmp[f]+"' AND "+ CRLF
		cQuery += "     D_E_L_E_T_ = ''  "+ CRLF
		cQuery += " GROUP BY Substring(CT2_FILIAL,1,2) "+ CRLF

		cQuery += " UNION ALL  "+ CRLF

		cQuery += " SELECT  "+ CRLF
		cQuery += "     'AUTOMATICA' 'TIPO',  "+ CRLF
		cQuery += "     Substring(CT2_FILIAL,1,2) 'FILIAL', "+ CRLF
		cQuery += "     COUNT(CT2_LOTE) 'QTD_REG', "+ CRLF
		cQuery += "     Round(SUM(CT2_VALOR),2) 'VALOR' "+ CRLF
		cQuery += " FROM " + retsqlname("CT2")+ " "+ CRLF
		cQuery += " WHERE "+ CRLF
		cQuery += "     CT2_LOTE IN ('COM001','FIN001','FAT001','EST001','ATF001') AND  "+ CRLF
		cQuery += "     CT2_DATA BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "+ CRLF
		cQuery += "     SubString(CT2_FILIAL,1,2) = '"+aEmp[f]+"' AND "+ CRLF
		cQuery += "     D_E_L_E_T_ = ''  "+ CRLF
		cQuery += " GROUP BY Substring(CT2_FILIAL,1,2) "+ CRLF

		cQuery += " Union All "+ CRLF

		cQuery += " SELECT  "+ CRLF
		cQuery += "     'TOTAL' 'TIPO',  "+ CRLF
		cQuery += "     'FILIAL' 'FILIAL', "+ CRLF
		cQuery += "     COUNT(CT2_LOTE) 'QTD_REG', "+ CRLF
		cQuery += "     Round(SUM(CT2_VALOR),2) 'VALOR' "+ CRLF
		cQuery += " FROM " + retsqlname("CT2")+ " "+ CRLF
		cQuery += " WHERE "+ CRLF
		cQuery += "     CT2_DATA BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "+ CRLF
		cQuery += "     SubString(CT2_FILIAL,1,2) = '"+aEmp[f]+"' AND "+ CRLF
		cQuery += "     D_E_L_E_T_ = ''  "+ CRLF
		cQuery += " GROUP BY Substring(CT2_FILIAL,1,2) "+ CRLF
		cQuery += " ORDER BY 2,1 "+ CRLF
		//EndSQL
		TcQuery cQuery New Alias "CT"

		CT->(DbGoTop())
		While !CT->(Eof())

			aadd(aValores,{cFilMOV,CT->TIPO,CT->QTD_REG,CT->VALOR})
			IncProc( "Processando...")

			CT->(DbSkip())
		End
		CT->(DbCloseArea())
		if len(aValores) >0 .AND. len(aValores) == 3
			aadd(aValores[1],Transform(Round((aValores[1,4]/aValores[3,4])*100,2),"@E 999,999,999,999.99"))
			aadd(aValores[2],Transform(Round((aValores[2,4]/aValores[3,4])*100,2),"@E 999,999,999,999.99"))
			aadd(aValores[3],"")

			oExcel:AddRow(cTitulo,cTitulo,aValores[1])
			oExcel:AddRow(cTitulo,cTitulo,aValores[2])
			oExcel:AddRow(cTitulo,cTitulo,aValores[3])
			oExcel:AddRow(cTitulo,cTitulo,{"","","","",""})
		Elseif len(aValores) >0
        /*
			aadd(aValores[1],Transform(Round((aValores[1,4]/aValores[3,4])*100,2),"@E 999,999,999,999.99"))
			aadd(aValores[1],Transform(Round((aValores[1,4]/aValores[2,4])*100,2),"@E 999,999,999,999.99"))
			aadd(aValores[2],"")
        */
			For nX := 1 To Len(aValores)
				If nX == 1
					nPos:=  Ascan(aValores[nX],{|x| AllTrim(x) == "AUTOMATICA"})
                    //aScan(_cString[1],{ |x| SUBSTRING(AllTrim(x),1,7) $ "L010100"})
					nPos1:= Ascan(aValores[nX],{|x| AllTrim(x)  == "TOTAL"})
					nPos2:= Ascan(aValores[nX],{|x| AllTrim(x)  == "MANUAL"})
					If nPos2 <> 0
						_cSemAuto:= .T.
					Endif
					If nPos <> 0
						_cSemManual:= .T.
					Endif
				endif
			Next Nx


			iF (_cSemAuto)
				aadd(aValores[1],Transform(Round((aValores[1,4]/aValores[3,4])*100,2),"@E 999,999,999,999.99"))
				//aadd(aValores[2],Transform(Round((aValores[2,4]/aValores[3,4])*100,2),"@E 999,999,999,999.99"))
				aadd(aValores[2],"")
				AADD(aVlr,{cFilMOV,"AUTOMATICA",0,0,Transform(Round((0)*100,2),"@E 999,999,999,999.99")})

				oExcel:AddRow(cTitulo,cTitulo,aValores[1])
				oExcel:AddRow(cTitulo,cTitulo,aVlr[1])
				oExcel:AddRow(cTitulo,cTitulo,aValores[2])
				oExcel:AddRow(cTitulo,cTitulo,{"","","","",""})
			ELSEIF (_cSemManual)
				aadd(aValores[1],Transform(Round((aValores[1,4]/aValores[2,4])*100,2),"@E 999,999,999,999.99"))
				//aadd(aValores[2],Transform(Round((aValores[2,4]/aValores[3,4])*100,2),"@E 999,999,999,999.99"))
				aadd(aValores[2],"")
				AADD(aVlr,{cFilMOV,"MANUAL",0,0,Transform(Round((0)*100,2),"@E 999,999,999,999.99")})

				oExcel:AddRow(cTitulo,cTitulo,aVlr[1])
				oExcel:AddRow(cTitulo,cTitulo,aValores[1])
				oExcel:AddRow(cTitulo,cTitulo,aValores[2])
				oExcel:AddRow(cTitulo,cTitulo,{"","","","",""})
			ENDIF
		endif
		aValores := {}
		_cSemAuto:= .F.
		_cSemManual:= .F.
		aVlr:= {}
	Next f
	oExcel:Activate()
	oExcel:GetXMLFile(cArqNome)
	If File(cArqNome)
		If MsgYesNo("Abrir arquivo "+cArqNome+"?","Concluido")
			ShellExecute("Open",cArqNome,"","",1)
		Endif
	Endif

Return

User Function Xpto11
	RpcSetEnv("01","5000","admin","agis","EST")
	Define MsDialog oMainWnd From 80,0 To 400,700 Pixel
	@ 25,05 Button "fatser"  Of oMainWnd Size 80,15 Pixel Action U_ZZQTDCT2()
	Activate MsDialog oMainWnd
Return


Static Function GetFil(cFil)

	Local aArea  := GetArea()
	Local aFilMOV := {}
	Local cFilMOV := ""

	aFilMOV := FWSM0Util():GetSM0Data( cEmpAnt , cFil , { "M0_NOMECOM" } )
	cFilMOV := Alltrim(aFilMOV[1,2])

	RestArea(aArea)

Return cFilMOV
