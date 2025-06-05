#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

#DEFINE MSG_ON       "ligada"
#DEFINE MSG_OFF      "desligada"

//-----------------------------------------------------------------
/*/{Protheus.doc} LinLigInt
Rotina que liga/desliga a Integração com o LIncros

@type		Function
@author		Régis Ferreira
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
        If MsgYesNo("A Integração Protheus x Lincros está " + cStatus + ". Deseja alterar ?", FunDesc())
            PutMv( "ZZ_LINCR05" , !lLigada )
            MsgInfo("Integração Protheus x Lincros " + Upper(iif(lLigada,MSG_OFF,MSG_ON)) ,FunDesc())
        EndIf
    else
        MsgInfo("Usuário sem permissão para ligar/desligar a integração.",FunDesc())
    endif

Return
