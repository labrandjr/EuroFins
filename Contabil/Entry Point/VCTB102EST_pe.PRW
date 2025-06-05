USER FUNCTION VCTB102EST ()
local lRet := .T.

if !inclui .and. !altera
     lRet := u_vldCtba('VCTB102EST') 
endif

RETURN lRet
