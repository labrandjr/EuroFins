#include 'totvs.ch'
#include 'topconn.ch'


/*/{Protheus.doc} F260BUT
Adiciona botão no browser da rotina do DDA
@type function
@version 12.1.27
@author Leandro Cesar
@since 26/08/2022
@return array, array do arotina
/*/
User Function F260BUT()
	Local aMenu := PARAMIXB

	aAdd(aMenu,{'# Ajusta Mov. DDA','U_CorrigeDDA( )',0,5 })

Return aMenu

// --------------------------------------------------------------------------------------------------------------------------------------------------


/*/{Protheus.doc} CorrigeDDA
realiza correção nos registros de DDA
@type function
@version 12.1.27
@author Leandro Cesar
@since 26/08/2022
/*/
user function CorrigeDDA()
	local cQuery as character

	If FWAlertYesNo("Confirma a correção dos registros DDA?","Aviso")

// 1. AJUSTA O STATUS PARA OS TÍTULOS JÁ COM CODIGO DE BARRAS
		cQuery := " UPDATE FIG010 SET FIG_CONCIL ='1' , FIG_DDASE2 = E2_FILIAL+'|'+E2_PREFIXO+'|'+E2_NUM+'|'+E2_PARCELA+'|'+E2_TIPO+'|'+E2_FORNECE+'|'+E2_LOJA+'|', FIG_USCONC = 'TLA8', FIG_DTCONC = '20220819'
		cQuery += " FROM FIG010
		cQuery += " INNER JOIN SE2010 ON SE2010.D_E_L_E_T_=''
		cQuery += "  AND LEFT (FIG_FILIAL,2)  = LEFT(E2_FILIAL,2)
		cQuery += " AND FIG_FORNEC = E2_FORNECE
		cQuery += " AND FIG_LOJA = E2_LOJA
		cQuery += " AND FIG_VALOR = E2_VALOR
		cQuery += " AND FIG_CODBAR = E2_CODBAR
		cQuery += " AND FIG_CONCIL <> '1'
		cQuery += " AND E2_VENCTO >= (SELECT CONVERT(VARCHAR(8),GETDATE(),112))
		cQuery += " WHERE FIG010.D_E_L_E_T_ = ''
		TcSQLExec(cQuery)

// 2. AJUSTA O FORNECEDOR MESMO RAIZ CNPJ COM O FORNECEDOR DO TÍTULO
		cQuery := " UPDATE FIG010 SET FIG_XCNPJ = FIG_CNPJ, FIG_FORNEC = A2_COD, FIG_LOJA = A2_LOJA, FIG_CNPJ = A2_CGC, FIG_NOMFOR = SUBSTRING(A2_NOME,1,20)
		cQuery += "  FROM FIG010
		cQuery += " INNER JOIN SE2010 ON SE2010.D_E_L_E_T_ = ''
		cQuery += "  AND ( FIG_VALOR >= (E2_VALOR - 0.01) AND FIG_VALOR <= (E2_VALOR + 0.01) )
		cQuery += "  AND (FIG_VENCTO >= CONVERT(CHAR, DATEADD(DAY,-1, CAST(E2_VENCTO AS smalldatetime)),112)
		cQuery += "                     AND FIG_VENCTO <= CONVERT(CHAR, DATEADD(DAY,+1, CAST(E2_VENCTO AS smalldatetime)),112))
		cQuery += " INNER JOIN SA2010 ON SA2010.D_E_L_E_T_ = '' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
		cQuery += " AND SUBSTRING(A2_CGC,1,8) = SUBSTRING(FIG_CNPJ,1,8)
		cQuery += " AND A2_CGC != FIG_CNPJ
		cQuery += "  WHERE FIG010.D_E_L_E_T_ = ''
		cQuery += "  AND FIG_CONCIL <> '1'
		cQuery += "  AND E2_CODBAR = ''
		cQuery += "  AND E2_SALDO != 0
		TcSQLExec(cQuery)



//  2. CORRIGE OS DADOS DO FORNECEDOR;
		cQuery := " UPDATE FIG010 SET FIG_FORNEC = A2_COD, FIG_LOJA = A2_LOJA, FIG_NOMFOR = SUBSTRING(A2_NOME,1,20)
		cQuery += " FROM FIG010
		cQuery += " INNER JOIN SA2010 ON SA2010.D_E_L_E_T_ = '' AND A2_CGC = FIG_CNPJ
		cQuery += "  WHERE FIG010.D_E_L_E_T_ = ''
		cQuery += " AND FIG_CONCIL <> '1'
		cQuery += " AND (FIG_FORNEC != A2_COD OR FIG_LOJA != A2_LOJA)
		TcSQLExec(cQuery)

		//  3. AJUSTA FILIAL DA FIG COM A FILIAL DO SE1
		cQuery := " UPDATE FIG010 SET FIG_XFILOR = FIG_FILIAL, FIG_FILIAL = E2_FILIAL
		cQuery += " FROM FIG010
		cQuery += " INNER JOIN SE2010 ON SE2010.D_E_L_E_T_ = ''
		cQuery += " AND ( FIG_VALOR >= (E2_VALOR -0.01) AND FIG_VALOR <= (E2_VALOR +0.01) )
		cQuery += " AND (FIG_VENCTO >= CONVERT(CHAR, DATEADD(DAY,-1, CAST(E2_VENCTO AS smalldatetime)),112)
		cQuery += " AND FIG_VENCTO <= CONVERT(CHAR, DATEADD(DAY,+1, CAST(E2_VENCTO AS smalldatetime)),112))
		cQuery += " INNER JOIN SA2010 ON SA2010.D_E_L_E_T_ = '' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA
		cQuery += " AND SUBSTRING(A2_CGC,1,8) = SUBSTRING(FIG_CNPJ,1,8)
		cQuery += " WHERE FIG010.D_E_L_E_T_ = ''
		cQuery += " AND FIG_CONCIL <> '1'
		cQuery += " AND E2_SALDO != 0
		cQuery += " AND E2_FILIAL != FIG_FILIAL
		TcSQLExec(cQuery)

		FWAlertSuccess("Ajuste Finalizado.","Aviso")

	EndIf

return
