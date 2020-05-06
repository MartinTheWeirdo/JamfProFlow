//%attributes = {}
  // Login_LDAP_
  // We didn't find them in the users table. Try LDAP.

$vt_username:=$1
$vt_password:=$2
$vt_passwordHash:=$3

$vb_successfulLogin:=False:C215

$vt_ldapDC:=sh_prefs_getValueForKey ("setting.login.ad.domaincontroller.fqdn";"")  // E.g. "domaincontroller.my.org"
$vt_ldapPort:=":"+sh_prefs_getValueForKey ("setting.login.ad.domaincontroller.port";"636")  // E.g. "636"
$vt_ldapBase:=sh_prefs_getValueForKey ("setting.login.ad.userbase.ou";"")  // E.g. "DC=my,DC=org"

If ($vt_ldapDC>"")  // Has an AD been enabled?
	
	C_TEXT:C284($vt_shell_cmd;$vt_shell_stderr;$vt_shell_stdin;$vt_shell_stdout)
	  // UPN Login to AD. 
	  // ldapsearch -H "ldaps://ad.my.org:636" -x -D "CN=svc_ldap,CN=Users,DC=jamf,DC=com" -w "complexifiedpassword" -b "DC=jamf,DC=com" "userPrincipalName=svc_ldap@jamf.com"
	$vt_shell_cmd:=""
	$vt_shell_cmd:=$vt_shell_cmd+"ldapsearch"
	$vt_shell_cmd:=$vt_shell_cmd+" "+"-H "+sh_str_dq ("ldaps://"+$vt_ldapDC+$vt_ldapPort)  // Use simple authentication instead of SASL.
	$vt_shell_cmd:=$vt_shell_cmd+" "+"-x "  // Use simple authentication instead of SASL.
	$vt_shell_cmd:=$vt_shell_cmd+" "+"-D "+sh_str_dq ($vt_username)  // DN or UPN?
	$vt_shell_cmd:=$vt_shell_cmd+" "+"-w "+sh_str_dq ($vt_password)  // Command line passwords are unsafe but this isn't a production account. 
	$vt_shell_cmd:=$vt_shell_cmd+" "+"-b "+sh_str_dq ($vt_ldapBase)  // All users should be in this branch
	$vt_shell_cmd:=$vt_shell_cmd+" "+sh_str_dq ("userPrincipalName="+$vt_username)
	$vt_shell_stdin:=""
	$vt_shell_stdout:=""
	$vt_shell_stderr:=""
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	If (OK#1)
		  //error occurred running the shell command. Maybe they don't have ldapsearh installed or something?
		vt_login_error:="I got an error running LDAP authentication. Maybe \nthe server is down or you're not connected to the network?"
		sh_msg_Alert (vt_login_error)
	Else 
		$vb_successfulLogin:=Login_LDAP_evaluate ($vt_username;$vt_password;$vt_passwordHash;$vt_shell_stdout;$vt_shell_stderr)
	End if 
End if 

$0:=$vb_successfulLogin