//%attributes = {}
  // git_getSyncStatus

If ((FORM Event:C1606.code=On Load:K2:1) | (FORM Event:C1606.code=On Clicked:K2:4))
	vt_GitInfo:=""
	$vt_shell_cmd:="git status"
	$vt_shell_cmd:=git_get ("gitcmd";$vt_shell_cmd)
	If ($vt_shell_cmd#"")
		$vt_shell_stdin:=""
		$vt_shell_stdout:=""
		$vt_shell_stderr:=""
		LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
		If (OK=1)
			vt_GitInfo:=$vt_shell_stdout+" "+$vt_shell_stderr
		Else 
			vt_GitInfo:="Error calling git: "+String:C10(vl_Error)
		End if 
	End if 
End if 
