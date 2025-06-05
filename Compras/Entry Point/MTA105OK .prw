#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MTA105OK
Validação do saldo na gravação da requisição
@author ricardo rey
@since 11/12/2018
/*/
user function MTA105OK ()

     Local _areasb2      := SB2->( getarea() )
     Local nPosLoc       := aScan( aHeader, { |x| upper(alltrim(x[2])) == "CP_LOCAL" } )
     Local nPosPrd       := aScan( aHeader, { |x| upper(alltrim(x[2])) == "CP_PRODUTO" } )
     Local nPosQtd       := aScan( aHeader, { |x| upper(alltrim(x[2])) == "CP_QUANT" } )
     Local cLocProd
     Local cCodProd
     Local nQtdProd
     Local aReq          := {}
     Local nPos          := 0
     Local aFaltaSaldo   := {}
     Local lRet          := .T.
     Local cMsgErro      := ""
     Local nX
     Local cProblema     := ""
     Local cSolucao      := ""
     Local lCont         := .T.
     Local lDelete       := .T.

     /***************************************************
     * Soma produtos por armazem
     ***************************************************/
     For nX := 1 To Len( aCols )
          cCodProd := aCols[ nX, nPosPrd ]
          cLocProd := aCols[ nX, nPosLoc ]
          nQtdProd := aCols[ nX, nPosQtd ]
          lDelete  := aCols[nX,Len(aHeader) + 1]
          if !lDelete
               nPos := aScan( aReq, { |x| x[1] = cCodProd .AND. x[2] = cLocProd } )
               if nPos == 0
                    aAdd( aReq, { cCodProd, cLocProd, 0 } )
                    nPos := len( aReq )
               endif
               aReq[ nPos,3 ] += nQtdProd
          endif
     Next nX



     /***************************************************
     * Checa saldo
     ***************************************************/
     SB2->( dbSetOrder( 1 ) ) // B2_FILIAL, B2_COD, B2_LOCAL
     For nX := 1 To Len( aReq )
          lDelete  := aCols[nX,Len(aHeader) + 1]
          if !lDelete
               nSALDO := SB2->( iif( dbSeek( xFilial() + aReq[ nX,1 ] + aReq[ nX,2 ] ) , SaldoSB2(), 0 ))
               if aReq[ nX,3 ] > nSALDO
                    aAdd( aFaltaSaldo, { aReq[ nX,1 ], aReq[ nX,2 ], aReq[ nX,3 ], nSALDO })
               endif
          endif
     Next nX

     SB2->( restarea( _areasb2 ) )

     lRet := ( len( aFaltaSaldo ) = 0 )

     /***************************************************
     * Emite aviso caso saldo insuficiente
     ***************************************************/
     if ! lRet
          For nX := 1 To Len( aFaltaSaldo )
               lDelete  := aCols[nX,Len(aHeader) + 1]
               if !lDelete
                    cMsgErro += "- Não há saldo sufuciente para o total requisitado do produto '" + aFaltaSaldo[ nX,1 ] + "'" +;
                         "no armazém '" + aFaltaSaldo[ nX,2 ] + "' (" + alltrim( str( nSALDO - aReq[ nX,3 ] ) ) + ")" + CHR(13) + CHR(10)
               endif
          Next nX
          Alert ("Produto(s) não tem saldo em estoque:" + CHR(13) + CHR(10) + cMsgErro )
     endif

     For nX := 1 To Len( aCols )
          lDelete  := aCols[nX,Len(aHeader) + 1]
          if !lDelete
               cCodProd := aCols[ nX, nPosPrd ]
               if SubStr(cCodProd,1,5) = "09A20"  //Produtos Pradrões
                    lCont := .F.
                    lRet := lCont          
               endif
          endif
     Next nX     

     if !lCont
          cProblema   := "Não é possível abrir uma solicitação armazém com produtos 'PADRÕES'. "+CHR(13) + CHR(10)
          cProblema   += "Produto Padrões tem o código começado com 09A20."+CHR(13) + CHR(10)
	     cSolucao    := "Verifique o produto utilizado."
		Help(NIL, NIL, "MTA105OK", NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
     endif

Return lRet
