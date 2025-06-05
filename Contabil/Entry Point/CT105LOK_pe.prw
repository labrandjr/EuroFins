USER FUNCTION CT105LOK ()
local lRet := .T.
local aParam  := PARAMIXB

if aParam[1] == 4 .or. aParam[1] == 5
    lRet := u_vldCtba('CT105LOK') 
endif

RETURN lRet