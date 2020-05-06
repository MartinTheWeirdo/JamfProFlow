Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		vt_manageXMLDisplay:=""
		REDUCE SELECTION:C351([XML:2];0)
		
	: (FORM Event:C1606.code=On Selection Change:K2:29)
		FIRST RECORD:C50([XML:2])
		For ($i;1;Records in selection:C76([XML:2]))
			If (Is in set:C273("$ListboxSetManageXML"))
				vt_manageXMLDisplay:=[XML:2]XML:2
			End if 
			NEXT RECORD:C51([XML:2])
		End for 
		
End case 
