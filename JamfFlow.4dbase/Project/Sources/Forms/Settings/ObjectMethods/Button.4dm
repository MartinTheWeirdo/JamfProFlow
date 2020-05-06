$vt_shell_cmd:=git_get ("gitcmd";vt_git_cmd)

If ($vt_shell_cmd#"")
	$vt_shell_stdin:=""
	$vt_shell_stdout:=""
	$vt_shell_stderr:=""
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	If (OK=1)
		vt_settings_gitTerminal:=""
		vt_settings_gitTerminal:=vt_settings_gitTerminal+"$ "+vt_git_cmd+<>CRLF+<>CRLF
		vt_settings_gitTerminal:=vt_settings_gitTerminal+"(script) "+$vt_shell_cmd+<>CRLF+<>CRLF
		
		If ($vt_shell_stdout#"")
			vt_settings_gitTerminal:=vt_settings_gitTerminal+"stdout #######################################################"+<>CRLF
			vt_settings_gitTerminal:=vt_settings_gitTerminal+$vt_shell_stdout+<>CRLF+<>CRLF
		End if 
		
		If ($vt_shell_stderr#"")
			vt_settings_gitTerminal:=vt_settings_gitTerminal+"stderr #######################################################"+<>CRLF
			vt_settings_gitTerminal:=vt_settings_gitTerminal+$vt_shell_stderr
		End if 
		
		APPEND TO ARRAY:C911(at_setting_cmds;vt_git_cmd)
		APPEND TO ARRAY:C911(at_settings_stdouts;$vt_shell_stdout)
	Else 
		vt_settings_gitTerminal:="Error calling git: "+String:C10(vl_Error)
	End if 
	
End if 