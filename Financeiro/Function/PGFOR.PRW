#include 'protheus.ch'

/*/{Protheus.doc} PGFOR
Rotina de retorno de dados de tributo pagamento CNAB Fornecedor
@type function
@version 12.1.33
@author Leandro Cesar
@since 24/10/2022
/*/
user function PGFOR()
	local xRet      := ''

	If SE2->E2_FORMPAG == '17' //PAGAMENTO DE TRIBUTOS GPS
		xRet := '01'                                                                //GPS
		xRet += '1007'                                                              //Contribuinte Individual - Recolhimento Mensal - NIT/PIS/PASEP
		xRet += strZero(Month(SE2->E2_EMISSAO),2) + StrZ(Year(SE2->E2_EMISSAO),4)
		xRet += substr(SM0->M0_CGC,1,14)
		xRet += strZero((SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE))*100,14)
		xRet += replicate("0",14)
		xRet += strZero(0*100,14)
		xRet += strZero((SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE))*100,14)
		xRet += GravaData(SE2->E2_VENCREA,.F.,5)
		xRet += space(8)
		xRet += SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA)
		xRet += substr(SM0->M0_NOMECOM,1,30)
	ElseIf SE2->E2_FORMPAG == '16' //PAGAMENTO DE TRIBUTOS DARF
		xRet := '02'                                                                //DARF SIMPLES
		xRet += SE2->E2_CODRET                                                                  //CODIGO DA RECEITA
		xRet += '2'
		xRet += substr(SE2->E2_ZZCNPJC,1,14)
		xRet += GravaData(SE2->E2_ZZAPURA,.F.,5)
		xRet += "00000000000000000"
		xRet += strZero(SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE)*100,14)
		xRet += strZero(0*100,14)
		xRet += strZero(0*100,14)
		xRet += strZero((SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE))*100,14)
		xRet += GravaData(SE2->E2_VENCTO,.F.,5)
		xRet += GravaData(dDataBase,.F.,5)
		xRet += space(30)
		xRet += substr(SM0->M0_NOMECOM,1,30)
	ElseIf SE2->E2_FORMPAG == '22' //PAGAMENTO DE TRIBUTOS GARE - SP ICMS
		xRet := '05'                                                                //DARF SIMPLES
		xRet += '0462'                                                                  //CODIGO DA RECEITA
		xRet += '2'
		xRet += substr(SM0->M0_CGC,1,14)
		xRet += substr(SM0->M0_INSC,1,12)
		xRet += "000000000000"
		xRet += strZero(Month(SE2->E2_EMISSAO),2) + StrZ(Year(SE2->E2_EMISSAO),4)
		xRet += "000000000000"
		xRet += strZero(SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE)*100,14)
		xRet += strZero(0*100,14)
		xRet += strZero(0*100,14)
		xRet += strZero((SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE))*100,14)
		xRet += GravaData(SE2->E2_VENCTO,.F.,5)
		xRet += GravaData(SE2->E2_VENCREA,.F.,5)
		xRet += space(11)
		xRet += substr(SM0->M0_NOMECOM,1,30)
	ElseIf SE2->E2_FORMPAG == '25' //PAGAMENTO DE TRIBUTOS IPVA
		xRet := '07'          		                                                //DARF SIMPLES
		xRet += space(04)                                                           //CODIGO DA RECEITA
		xRet += '2'
		xRet += substr(SM0->M0_CGC,1,14)
		xRet += StrZ(Year(SE2->E2_VENCTO),4)
		xRet += "000000000"															//renavam
		xRet += "SP"
		xRet += "00000"																//codigo de municipio
		xRet += "XXXXXXX"															//placa
		xRet += ""																	//opcao de pagamento
		xRet += strZero(SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE)*100,14)
		xRet += strZero(0,14)
		xRet += strZero((SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE))*100,14)
		xRet += GravaData(SE2->E2_VENCTO,.F.,5)
		xRet += GravaData(SE2->E2_VENCREA,.F.,5)
		xRet += space(30)
		xRet += "000000000000"														// renavam
		xRet += substr(SM0->M0_NOMECOM,1,30)
	ElseIf SE2->E2_FORMPAG == '35' //PAGAMENTO DE TRIBUTOS FGTS
		xRet := '11'          		                                                //FGTS
		xRet += SE2->E2_CODRET                                                      //CODIGO DA RECEITA
		xRet += '2'
		xRet += substr(SM0->M0_CGC,1,14)
		xRet += PADR(SE2->E2_CODBAR,48)
		xRet += space(16)  															//Identificador FGTS
		xRet += space(9)                                                            //lacre
		xRet += substr(SM0->M0_NOMECOM,1,30)                                        //nome contribuinte
        xRet += GravaData(dDataBase,.F.,5)                                          //data pagamento
		xRet += strZero(SE2->(E2_SALDO+E2_ACRESC-E2_SDDECRE)*100,14)
		xRet += space(30)
	EndIf

return( xRet )

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

user function GatBcoFor()
	local cRet		:= CriaVar("A2_FORMPAG")
	local cBanco	:= M->A2_BANCO

	if !Empty(cBanco)
		if cBanco == '341'
			cRet	:= '01'
		Else
			cRet	:= '41'
		EndIf
	EndIf

return( cRet )
