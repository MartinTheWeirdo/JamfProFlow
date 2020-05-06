//%attributes = {}
  // git_run

$vt_shell_cmd:=$1  // $vt_shell_cmd:="git status --porcelain=1"

$vt_shell_stdin:=""
$vt_shell_stdout:=""
$vt_shell_stderr:=""

$vt_shell_cmd:=git_get ("gitcmd";$vt_shell_cmd)
If ($vt_shell_cmd#"")
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	If (OK#1)
		  // I actually have no idea what could cause this
		sh_msg_Alert ("There was a problem running the git command. Check the installation?")
	End if 
End if 

C_OBJECT:C1216($0)
$0:=New object:C1471("ok";OK;"$vt_shell_cmd";$vt_shell_cmd;"$vt_shell_stdout";$vt_shell_stdout;"$vt_shell_stderr";$vt_shell_stderr)
