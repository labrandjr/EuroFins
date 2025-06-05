#INCLUDE 'Protheus.CH'
#INCLUDE 'Topconn.ch'
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} FA430FIG

Permite modificar o CNPJ obtido da leitura do arquivo de retorno DDA, de modo que a tabela SA2 seja posicionada
através do CNPJ modificado neste ponto de entrada.
Eventos: Antes da gravação do movimento DDA na tabela FIG.

@type function
@author Evandro de Almeida
@since 05/05/2020
@version P11,P12
@database MSSQL

@return cCNPJ CNPJ do Retorno do DDA
/*/
User Function FA430FIG()

	Local aDados 		:= PARAMIXB
	Local cCNPJ 		:= ParamIxb[1]
	Local cCNPJAlt 		:= SubString( cCNPJ, 1, Len( cCNPJ ) - 6 )
	Local cCNPJAchou 	:= " "
	Local cQuery 		:= " "

	If Select("TRB") > 0
		TRB->(DbCloseArea()) // Fecha a area
	Endif

	cQuery = "select A2_CGC from " + RetSqlTab("SE2") + CRLF
	cQuery += "join " + RetSqlTab("SA2") + " on E2_FORNECE = A2_COD and E2_LOJA = A2_LOJA and substring(A2_CGC,1,8) = '"+cCNPJAlt+"' " + CRLF
	cQuery += "where " + RetSqlDel("SE2") + " " + CRLF
    cQuery += "  and E2_VALOR >= "+cValtochar(nValPgto-0.02) + CRLF
    cQuery += "  and E2_VALOR <= "+cValtochar(nValPgto+0.02) + CRLF
    cQuery += "  and E2_VENCTO >= '"+DTOS(daySub(dBaixa,1))+"'" + CRLF
    cQuery += "  and E2_VENCTO <= '"+DTOS(daySum(dBaixa,1))+"'" + CRLF
    // cQuery += "  and " + RetSqlFil("SE2") + CRLF

	MemoWrite("\sql\FA430FIG.sql", cQuery)
	TcQuery cQuery New Alias "TRB" // Cria tabela temporária

	While TRB->(!Eof())
		cCNPJAchou:= TRB->A2_CGC
		TRB->( dbSkip () )
	Enddo

	If cCNPJAchou <> " "
		cCNPJ := cCNPJAchou
	Endif

//Alert('CGC: ' + aDados[1] + 'cgc_alt: '+ cCNPJAlt + ' Fornecedor: ' + aDados[2] + ' Prefixo: '+aDados[3] + ' Título: '+aDados[4] +' Parcela: '+aDados[5])

Return cCNPJ
