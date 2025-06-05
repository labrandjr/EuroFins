USER FUNCTION CT101TOK ()
local lRet := .T. 
local aParam  := PARAMIXB


if aParam[11] == 4 .or. aParam[11] == 5
    lRet := u_vldCtba('CT101TOK') 
endif
  
RETURN lRet
