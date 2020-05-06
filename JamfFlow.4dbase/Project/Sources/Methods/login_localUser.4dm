//%attributes = {}
  // Login_localUser

$vt_username:=$1
$vt_password:=$2
$vt_passwordHash:=$3

$vb_successfulLogin:=False:C215

If (Current user:C182="Designer")
	  // Single User project -- the designer user has no password
	$vb_successfulLogin:=True:C214
Else 
	CHANGE CURRENT USER:C289($vt_username;$vt_password)
	If (OK=1)
		$vb_successfulLogin:=True:C214
	Else 
		CHANGE CURRENT USER:C289
		If (Current user:C182#"")
			$vb_successfulLogin:=True:C214
		End if 
	End if 
End if 

$0:=$vb_successfulLogin
