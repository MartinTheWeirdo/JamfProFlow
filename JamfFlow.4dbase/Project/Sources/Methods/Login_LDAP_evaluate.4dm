//%attributes = {}
  //Login_LDAP_evaluate


$vt_username:=$1
$vt_password:=$2
$vt_passwordHash:=$3
$vt_shell_stdout:=$4
$vt_shell_stderr:=$5

$vb_successfulLogin:=False:C215

Case of 
	: ($vt_shell_stderr#"")
		  // Fail: (stderr)
		  // ldap_bind: Invalid credentials (49)\n\tadditional info: 80090308: LdapErr: DSID-0C090434, comment: AcceptSecurityContext error, data 52e, v4563\n
		$vl_postionInvalidCredentials:=Position:C15("Invalid credentials";$vt_shell_stderr)
		If ($vl_postionInvalidCredentials>0)
			QUERY:C277([UserTable:5];[UserTable:5]user_name:2=vt_username)
			If (Records in selection:C76([UserTable:5])=1)
				[UserTable:5]login_count_fail:6:=[UserTable:5]login_count_fail:6+1
				SAVE RECORD:C53([UserTable:5])
			End if 
		End if 
		vt_login_error:="Bad username or password.\n"+$vt_shell_stderr
		
	: ($vt_shell_stdout#"")
		$vb_successfulLogin:=Login_LDAP_evaluate_stdout ($vt_username;$vt_password;$vt_passwordHash;$vt_shell_stdout;$vt_shell_stderr)
	Else 
		  // Neither stderr or stdout has a value. I don't know what would cause this. 
		vt_login_error:="Unexpected response from directory server lookup. Try again?"
End case 

$0:=$vb_successfulLogin
