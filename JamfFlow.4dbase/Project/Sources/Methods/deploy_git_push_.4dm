//%attributes = {}
  // deploy_git_push_ 

  // local repo is stable. 
  // Do we have files to add, change, or delete? 

$vb_goodToGo:=True:C214

$vt_shell_cmd:="git status --porcelain=1"
$vt_shell_cmd:=git_get ("gitcmd";$vt_shell_cmd)
If ($vt_shell_cmd#"")
	$vt_shell_stdin:=""
	$vt_shell_stdout:=""
	$vt_shell_stderr:=""
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	If (OK=1)
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"============== File Status =============="+<>CRLF
		If ($vt_shell_stdout+$vt_shell_stderr="")
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"No file changes reported"+<>CRLF
		Else 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stdout+<>CRLF
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stderr+<>CRLF
		End if 
		While (vt_deployedItemsSummary=("@"+(<>CRLF)+(<>CRLF)))
			vt_deployedItemsSummary:=Substring:C12(vt_deployedItemsSummary;1;Length:C16(vt_deployedItemsSummary)-1)
		End while 
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"========================================="+<>CRLF+<>CRLF
		If (Length:C16($vt_shell_stdout)=0)
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"[done] No changes were reported by git status. Nothing to push to server"
		Else 
			  // There are changes
			$vb_goodToGo:=deploy_git_push_stage ($vt_shell_stdout)
		End if 
	Else 
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Error calling git command line: "+String:C10(vl_Error)
	End if 
End if 

$0:=$vb_goodToGo