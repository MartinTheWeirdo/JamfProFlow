//%attributes = {}
  //Login_LDAP_evaluate_stdout

$vt_username:=$1
$vt_password:=$2
$vt_passwordHash:=$3
$vt_shell_stdout:=$4
$vt_shell_stderr:=$5

$vb_successfulLogin:=False:C215

  // Check for UPN in response
$vl_upnPosition:=Position:C15("userPrincipalName: "+$vt_username;$vt_shell_stdout)
If ($vl_upnPosition<1)
	  // LDAP did not return user info 
	vt_login_error:="Sorry, I wasn't able to get your account info from the user directory. Try again?"
Else 
	  // LDAP returned info on the user. Good login.
	$vb_successfulLogin:=True:C214
	
	  // Update last login info in the users table.
	QUERY:C277([UserTable:5];[UserTable:5]user_name:2=$vt_username)
	Case of 
		: (Records in selection:C76([UserTable:5])=1)
			  // Existing user, updating password
			[UserTable:5]user_password_hash:3:=$vt_passwordHash
			[UserTable:5]last_password_update_date:11:=Current date:C33(*)
			[UserTable:5]login_count_ok:5:=[UserTable:5]login_count_ok:5+1
			[UserTable:5]last_login_ok_date:7:=Current date:C33(*)
			[UserTable:5]last_login_ok_time:8:=Current time:C178(*)
			SAVE RECORD:C53([UserTable:5])
		: (Records in selection:C76([UserTable:5])=0)
			  // New user
			CREATE RECORD:C68([UserTable:5])
			[UserTable:5]ID:1:=Sequence number:C244([UserTable:5])
			$vt_domain:=sh_prefs_getValueForKey ("setting.login.ad.domain")
			[UserTable:5]ad_server_name:4:=$vt_domain
			[UserTable:5]user_name:2:=$vt_username
			[UserTable:5]first_login_ok_date:9:=Current date:C33(*)
			[UserTable:5]first_login_ok_time:10:=Current time:C178(*)
			[UserTable:5]last_login_ok_date:7:=Current date:C33(*)
			[UserTable:5]last_login_ok_time:8:=Current time:C178(*)
			[UserTable:5]login_count_fail:6:=0
			[UserTable:5]login_count_ok:5:=1
			[UserTable:5]user_password_hash:3:=$vt_passwordHash
			[UserTable:5]last_password_update_date:11:=Current date:C33(*)
			SAVE RECORD:C53([UserTable:5])
		Else 
			  // Duplicate user record?
			  // Could add a log warning once we set that up.
			$vt_appArea:="Login"
			$vt_Level:="Data"
			$vt_Message:="Duplicate user record found for "+$vt_username+". Will auth but won't update the last login info..."
			LogMessage (Current method name:C684;Current method path:C1201;$vt_appArea;$vt_Level;$vt_Message)
	End case 
End if   // If ($vl_upnPosition>0)

$0:=$vb_successfulLogin
