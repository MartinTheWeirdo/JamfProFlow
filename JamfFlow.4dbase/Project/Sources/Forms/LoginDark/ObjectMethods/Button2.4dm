If (FORM Event:C1606.code=On Clicked:K2:4)
	$vt_userPipePass:=sh_str_dq (vt_username+"|"+vt_password)  // We'd need to escape double-quotes in passwords
	C_TEXT:C284($vt_shell_cmd;$vt_shell_stderr;$vt_shell_stdin;$vt_shell_stdout)
	$vt_appName:=sh_str_dq ("JamfUtil_login")
	$vt_shell_cmd:="security add-generic-password -U -a "+$vt_appName+" -s "+$vt_appName+" -w "+$vt_userPipePass
	  // Success : OK=1, nothing in stdout or stderr.
	  // FAIL    : OK=1, stderr="security: SecKeychainItemCreateFromContent (<default>): The specified item already exists in the keychain.\n"
	$vt_shell_stdin:=""
	$vt_shell_stdout:=""
	$vt_shell_stderr:=""
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	If (OK=1)
		Case of 
			: ($vt_shell_stderr#"")
				sh_msg_Alert ("Problem saving to keychain:\n"+$vt_shell_stderr)
			Else 
				sh_msg_Alert ("Login saved to keychain.")
		End case 
	End if 
End if 
