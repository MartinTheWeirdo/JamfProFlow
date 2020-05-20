If (FORM Event:C1606.code=On Load:K2:1)
	vt_username:=""
	vt_password:=""
	C_TEXT:C284($vt_shell_cmd;$vt_shell_stderr;$vt_shell_stdin;$vt_shell_stdout)
	$vt_username:=sh_str_dq (vt_username)
	$vt_password:=sh_str_dq (vt_password)
	$vt_appName:=sh_str_dq ("JamfUtil_login")
	$vt_shell_cmd:="security find-generic-password -a "+$vt_appName+" -s "+$vt_appName+" -w"
	  // PASSWORD EXISTS:
	  // stdout="passwordplaintext\n"
	  // PASSWORD DOES NOT EXIST:
	  // stderr="security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain.\n"
	$vt_shell_stdin:=""
	$vt_shell_stdout:=""
	$vt_shell_stderr:=""
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	If (OK=1)
		Case of 
			: ($vt_shell_stderr#"")
				  // Not found, most likely. Do nothing in this case. 
			: ($vt_shell_stdout#"")
				$vt_shell_stdout:=Substring:C12($vt_shell_stdout;1;Length:C16($vt_shell_stdout)-1)  // Strip trailing newline
				$vl_pipePosition:=Position:C15("|";$vt_shell_stdout)
				If (($vl_pipePosition>0) & ($vl_pipePosition<=Length:C16($vt_shell_stdout)))
					vt_username:=Substring:C12($vt_shell_stdout;1;$vl_pipePosition-1)  // Start to pipe
					vt_password:=Substring:C12($vt_shell_stdout;$vl_pipePosition+1)  // Pipe to end
				End if 
		End case 
	End if 
End if 
