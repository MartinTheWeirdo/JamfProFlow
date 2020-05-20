If (FORM Event:C1606.code=On Clicked:K2:4)
	If (vt_username="")
		vt_login_error:="Please enter a username."
	Else 
		$vb_successfulLogin:=Login (vt_username;vt_password)
		If ($vb_successfulLogin)
			ACCEPT:C269
		End if 
	End if 
End if   // (FORM Event.code=On Clicked)
