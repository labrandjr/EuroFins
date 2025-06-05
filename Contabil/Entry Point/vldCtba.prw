USER FUNCTION vldCtba(cRotina)
 local lRet				 := .T.
 Local cUsrPerm			:= ""

	cUsrPerm := AllTrim(GetMV("ZZ_USRCTBA"))

    IF !(ALLTRIM(CT2->CT2_ROTINA) $ "CTBA101,CTBA102") .and. !(RetCodUsr() $ cUsrPerm) .and. !(ALLTRIM(CT2->CT2_ROTINA) == 'CTBA500' .and. !(SUBSTR(CT2->CT2_LOTE,1,3) == 'FOL') )
       lRet := .F.
       Alert("Não é permitido alterar/excluir lançamentos importados ."+cRotina)
    ENDIF



RETURN lRet
