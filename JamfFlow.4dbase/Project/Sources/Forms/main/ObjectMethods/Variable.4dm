Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		If (Undefined:C82(<>vt_currentUser))
			<>vt_currentUser:=""
		End if 
		If (<>vt_currentUser="")
			CANCEL:C270  // close this instance so we don't get doubles 
			myStartup 
		End if 
End case 
