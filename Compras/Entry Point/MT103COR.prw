#include 'totvs.ch'

User Function MT103COR()
	Local aCores := aClone(PARAMIXB[1])

	aIns(aCores,1)

	aCores[1]:= { 'F1_STATUS=="B" .and. F1_XSTA_CC =="R"' , 'BR_CANCEL' }

Return( aCores )
