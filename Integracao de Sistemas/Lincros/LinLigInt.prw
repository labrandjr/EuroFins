#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

#DEFINE MSG_ON       "ligada"
#DEFINE MSG_OFF      "desligada"

//-----------------------------------------------------------------
/*/{Protheus.doc} LinLigInt
Rotina que liga/desliga a Integra��o com o LIncros

@type		Function
@author		R�gis Ferreira
@since		01/12/2022
/*/
//-----------------------------------------------------------------
User Function LinLigInt()

    Local cStatus   := "ligada!"
    Local lLigada   := getnewpar("ZZ_LINCR05",.F.)
    Local cUsrAuth  := getnewpar("ZZ_LINCR07","000000")

    If !lLigada
        cStatus     := "desligada!"
    EndIf

    If RetCodUsr() $ cUsrAuth
        If MsgYesNo("A Integra��o Protheus x Lincros est� " + cStatus + ". Deseja alterar ?", FunDesc())
            PutMv( "ZZ_LINCR05" , !lLigada )
            MsgInfo("Integra��o Protheus x Lincros " + Upper(iif(lLigada,MSG_OFF,MSG_ON)) ,FunDesc())
        EndIf
    else
        MsgInfo("Usu�rio sem permiss�o para ligar/desligar a integra��o.",FunDesc())
    endif

Return
