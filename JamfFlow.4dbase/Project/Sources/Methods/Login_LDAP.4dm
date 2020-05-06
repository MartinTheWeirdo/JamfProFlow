//%attributes = {}
  // Login_LDAP

$vt_username:=$1
$vt_password:=$2
$vt_passwordHash:=$3

$vb_successfulLogin:=False:C215

  // They put in a upn. See if we already know them...
QUERY:C277([UserTable:5];[UserTable:5]user_name:2=vt_username)
If (Records in selection:C76([UserTable:5])=1)
	If ([UserTable:5]user_password_hash:3=$vt_passwordHash)
		$vb_successfulLogin:=True:C214
	End if 
End if 

If (Not:C34($vb_successfulLogin))
	  // Local login didn't work. Try LDAP...
	$vb_successfulLogin:=Login_LDAP_ ($vt_username;$vt_password;$vt_passwordHash)
End if 

$0:=$vb_successfulLogin
