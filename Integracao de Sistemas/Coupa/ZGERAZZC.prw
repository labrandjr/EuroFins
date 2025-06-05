#include "Totvs.ch"
#include "topconn.ch"

User Function ZGERAZZC()

    local nI            := 1
    local nZ            := 1
    local aCC           := retCC()
    local aIDs          := retIDs()

    conout("INICIO")
    conout("QTd CC: " +  cValtochar(len(aCC)) )
    conout("QTd IDS: " +  cValtochar(len(aIDs)) )

    for nI := 1 to len(aCC)

        for nZ := 1 to Len(aIDs)
            If RECLOCK("ZZC",.T.)
                ZZC->ZZC_CCUSTO     := aCC[nI]
                ZZC->ZZC_FILCLI     := aIDs[nZ,1]
                ZZC->ZZC_ID         := aIDs[nZ,2]
                ZZC->ZZC_LE         := aIDs[nZ,3]

                ZZC->(MsUnlock())
            EndIf
        next
    next

    conout("FIM")

return

static function retIDs()

    local aRet       := {}

    aAdd( aRet , { "0100","4340","CBR001"})
    aAdd( aRet , { "0100","4341","CBR001"})
    aAdd( aRet , { "0100","4342","CBR001"})
    aAdd( aRet , { "0100","4343","CBR001"})
    aAdd( aRet , { "0100","4345","CBR001"})
    aAdd( aRet , { "0100","4347","CBR001"})
    aAdd( aRet , { "0100","4348","CBR001"})
    aAdd( aRet , { "0101","4350","CBR001"})
    aAdd( aRet , { "0100","4A60","CBR001"})
    aAdd( aRet , { "0100","4A86","CBR001"})
    aAdd( aRet , { "0100","4B56","CBR001"})
    aAdd( aRet , { "0101","4F88","CBR001"})
    aAdd( aRet , { "0100","4I18","CBR001"})
    aAdd( aRet , { "0100","4I19","CBR001"})
    aAdd( aRet , { "0100","4N12","CBR001"})
    aAdd( aRet , { "0100","4L65","CBR001"})

return aRet

static function retCC()

    local aRet      := {}

    aADd( aRet, "11101")
    aADd( aRet, "11102")
    aADd( aRet, "11103")
    aADd( aRet, "11104")
    aADd( aRet, "11105")
    aADd( aRet, "11106")
    aADd( aRet, "11201")
    aADd( aRet, "11202")
    aADd( aRet, "11301")
    aADd( aRet, "11302")
    aADd( aRet, "21101")
    aADd( aRet, "21102")
    aADd( aRet, "21103")
    aADd( aRet, "21104")
    aADd( aRet, "21105")
    aADd( aRet, "21106")
    aADd( aRet, "21108")
    aADd( aRet, "21109")
    aADd( aRet, "31101")
    aADd( aRet, "31102")
    aADd( aRet, "41101")
    aADd( aRet, "41102")
    aADd( aRet, "41103")
    aADd( aRet, "41104")
    aADd( aRet, "41105")
    aADd( aRet, "41106")
    aADd( aRet, "41107")
    aADd( aRet, "41201")
    aADd( aRet, "51101")
    aADd( aRet, "51102")
    aADd( aRet, "51103")
    aADd( aRet, "51104")
    aADd( aRet, "51105")
    aADd( aRet, "51106")
    aADd( aRet, "51107")
    aADd( aRet, "51108")
    aADd( aRet, "51109")

return aRet
