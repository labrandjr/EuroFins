

#include 'totvs.ch'
#include 'topconn.ch'

CLASS ExpCoupa

	Data cFil
	Data cPedido
	Data oObj
	Data cFile
	Data cPatch

	METHOD New() CONSTRUCTOR
	METHOD ExportFile()
	METHOD Deactivate()

	// Demais métodos pertinentes a sua classe

ENDCLASS

// --------------------------------------------------------------------------------------------------------------------------------------------------

METHOD New(cP_Pedido) CLASS ExpCoupa

	::cFil     := FWxFilial("SC7")
	::cPedido  := cP_Pedido
	::cFile    := "po-tax_"+alltrim(cP_Pedido)+".csv"
	::cPatch   := "C:\temp\"
	Self:oObj  := NIL

Return Self

// --------------------------------------------------------------------------------------------------------------------------------------------------

METHOD ExportFile() CLASS ExpCoupa
	local cTMP_SC7 := GetNextAlias() as character
	local cFil     := ::cFil
	local cPOCoupa := ::cPedido

	BeginSQL Alias cTMP_SC7

        SELECT C7_ZZCCOUP AS COUPA
        , SUM(C7_VALFRE) AS FRETE
        , SUM(C7_DESPESA) AS DESPESA
        , SUM(C7_SEGURO) AS SEGURO
        , SUM(C7_VALIPI) AS IPI
        , SUM(C7_VALICM) AS ICMS
        FROM %Table:SC7% SC7
        WHERE SC7.C7_FILIAL = %Exp:cFil%
        AND  SC7.C7_ZZCCOUP = %Exp:cPOCoupa%
        AND SC7.%NotDel%
        GROUP BY C7_ZZCCOUP
	EndSQL

	If (cTMP_SC7)->(!Eof())

		oFWriter := FWFileWriter():New(::cPatch + ::cFile, .T.)
		If !oFWriter:Create()
			u_zLogMsg("Houve um erro ao gerar o arquivo: " + oFWriter:Error():Message)
		Else
			cLinha := "PO Number;Valor IPI;Valor ICMS;Valor Despesas;Valor Seguro;Valor Frete"
			oFWriter:Write(cLinha + CRLF)

			while (cTMP_SC7)->(!Eof())

				cLinha := alltrim((cTMP_SC7)->COUPA) + ";" + ;
					cValToChar((cTMP_SC7)->IPI) + ";" + ;
					cValToChar((cTMP_SC7)->ICMS) + ";" + ;
					cValToChar((cTMP_SC7)->DESPESA) + ";" + ;
					cValToChar((cTMP_SC7)->SEGURO) + ";" + ;
					cValToChar((cTMP_SC7)->FRETE)
				oFWriter:Write(cLinha + CRLF)

				(cTMP_SC7)->(dbSkip())
			EndDo
		EndIf
		oFWriter:Close()
	EndIf
    (cTMP_SC7)->(dbCloseArea())

Return

//---------------------------------------------------------------------------------------------------------------------------------------------------

user function TstPOC()

	local cPedido := "01829540"

	cQuery := " SELECT C7_ZZCCOUP AS PEDIDO FROM SC7010 WHERE SC7010.D_E_L_E_T_ = '' AND C7_EMISSAO >= '20220615' AND C7_ZZCCOUP != '' GROUP BY C7_ZZCCOUP
	TcQuery cQuery New Alias (cTRX := GetNextAlias() )

	dbSelectArea((cTRX))
	while (cTRX)->(!eof())
		cPedido := (cTRX)->PEDIDO
		oCoupa := ExpCoupa():New(cPedido)
		oCoupa:ExportFile()

		FreeObj(oCoupa)
		oCoupa := Nil
		(cTRX)->(dbSkip())
	EndDo
return
