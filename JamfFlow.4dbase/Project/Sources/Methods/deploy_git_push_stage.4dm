//%attributes = {}
  // deploy_git_push_stage

$vt_porcilain:=$1

$vb_goodToGo:=True:C214

ARRAY TEXT:C222(at_commit_path;0)
ARRAY TEXT:C222(at_commit_localStatus;0)
ARRAY TEXT:C222(at_commit_serverStatus;0)
ARRAY TEXT:C222(at_commit_Action;0)

While (Length:C16($vt_porcilain)#0)
	$vl_positionNextEOL:=Position:C15("\n";$vt_porcilain)  // EOL is newline on mac
	If ($vl_positionNextEOL<0)
		$vt_line:=$vt_porcilain
	Else 
		$vt_line:=Substring:C12($vt_porcilain;1;$vl_positionNextEOL-1)
		If (Length:C16($vt_porcilain)>($vl_positionNextEOL+1))
			$vt_porcilain:=Substring:C12($vt_porcilain;$vl_positionNextEOL+1)
		Else 
			$vt_porcilain:=""
		End if 
	End if 
	
	If ($vt_line="")
		$vb_goodToGo:=False:C215
	Else 
		  // expect: "status<space>filepath"
		If (Length:C16($vt_line)<3)
			$vb_goodToGo:=False:C215
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"[stop] git status line "+sh_str_dq ($vt_line)+" isn't in the expected format (too short)"
		Else 
			$vt_status:=Substring:C12($vt_line;1;2)
		End if 
	End if 
	
	If (Not:C34($vb_goodToGo))
		$vt_porcilain:=""  // Pop the while
	Else 
		$vt_status1:=$vt_status[[1]]
		$vt_status2:=$vt_status[[2]]
		$vt_file:=Substring:C12($vt_line;4)
		
		$q:=Char:C90(Double quote:K15:41)
		If ($vt_file=($q+"@"+$q))
			$vt_file:=Substring:C12($vt_file;2;Length:C16($vt_file)-2)
		End if 
		
		APPEND TO ARRAY:C911(at_commit_path;$vt_file)
		APPEND TO ARRAY:C911(at_commit_localStatus;deploy_git_push_stage_stateCode ($vt_status1))
		APPEND TO ARRAY:C911(at_commit_serverStatus;deploy_git_push_stage_stateCode ($vt_status2))
		
		Case of   // Run add operation to track new items
			: ($vt_status="A ")
				$vt_operation:="File already added to tracking. Ready for sync."+<>CRLF
				
			: ($vt_status="AD")
				$vt_operation:="File will be deleted. Ready for sync."+<>CRLF
				
			: ($vt_status=" M")
				$vt_operation:="Modified file will be auto-staged on commit."+<>CRLF
				
			: ($vt_status="??")
				$vt_operation:="Adding new file to tracking."+<>CRLF
				$vt_shell_cmd:="git add "+sh_str_dq ($vt_file)
				$vt_shell_cmd:=git_get ("gitcmd";$vt_shell_cmd)
				If ($vt_shell_cmd#"")
					$vt_shell_stdin:=""
					$vt_shell_stdout:=""
					$vt_shell_stderr:=""
					LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
					If (OK#1)
						vt_deployedItemsSummary:=vt_deployedItemsSummary+"Error calling git command line: "+String:C10(vl_Error)
					Else 
						vt_deployedItemsSummary:=vt_deployedItemsSummary+"============== File Add =============="+<>CRLF
						vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stdout+<>CRLF
						vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stderr+<>CRLF
						While (vt_deployedItemsSummary=("@"+(<>CRLF)+(<>CRLF)))
							vt_deployedItemsSummary:=Substring:C12(vt_deployedItemsSummary;1;Length:C16(vt_deployedItemsSummary)-1)
						End while 
						vt_deployedItemsSummary:=vt_deployedItemsSummary+"======================================"+<>CRLF
					End if 
				End if 
				
			Else 
				$vt_operation:="Unexpected change type"+<>CRLF
		End case   //Case of   // Run add operation to track new items
		
		APPEND TO ARRAY:C911(at_commit_Action;$vt_operation)
		
	End if   //If (Not($vb_goodToGo))
End while   //While (Length($vt_porcilain)#0)




  // Done looping throught the lines on the status to see what needs to be added
  // Ready to commmit
$vl_commitWinRef:=Open form window:C675("commit")
DIALOG:C40("commit")
CLOSE WINDOW:C154($vl_commitWinRef)

If (OK=0)
	  // They cancelled 
Else 
	$vt_shell_cmd:="git commit -a -m "+sh_str_dq (vt_CommitComment)
	$vt_shell_cmd:=git_get ("gitcmd";$vt_shell_cmd)
	If ($vt_shell_cmd#"")
		$vt_shell_stdin:=""
		$vt_shell_stdout:=""
		$vt_shell_stderr:=""
		LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
		If (OK#1)
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"Error calling git command line: "+String:C10(vl_Error)
		Else 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"================= Commit ================"+<>CRLF
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stdout+<>CRLF
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stderr+<>CRLF
			While (vt_deployedItemsSummary=("@"+(<>CRLF)+(<>CRLF)))
				vt_deployedItemsSummary:=Substring:C12(vt_deployedItemsSummary;1;Length:C16(vt_deployedItemsSummary)-1)
			End while 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"========================================="+<>CRLF
		End if 
	End if 
	
	
	  // Push to origin
	$vt_shell_cmd:="git push origin master"
	$vt_shell_cmd:=git_get ("gitcmd";$vt_shell_cmd)
	If ($vt_shell_cmd#"")
		$vt_shell_stdin:=""
		$vt_shell_stdout:=""
		$vt_shell_stderr:=""
		LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
		If (OK#1)
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"Error calling git command line: "+String:C10(vl_Error)
		Else 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"================= Commit ================"+<>CRLF
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stdout+<>CRLF
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stderr+<>CRLF
			While (vt_deployedItemsSummary=("@"+(<>CRLF)+(<>CRLF)))
				vt_deployedItemsSummary:=Substring:C12(vt_deployedItemsSummary;1;Length:C16(vt_deployedItemsSummary)-1)
			End while 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"========================================="+<>CRLF
		End if 
	End if 
	
End if   // If (OK=1)


$0:=$vb_goodToGo