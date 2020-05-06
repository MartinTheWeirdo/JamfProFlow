//%attributes = {}
  // deploy_git_push


$vb_goodToGo:=True:C214


vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+<>CRLF
vt_deployedItemsSummary:=vt_deployedItemsSummary+"Running git status"+<>CRLF
o_gitRun:=git_run ("git status")
$vt_shell_stdout:=o_gitRun.$vt_shell_stdout
$vt_shell_stderr:=o_gitRun.$vt_shell_stderr
If ($vt_shell_stdout="")
	$vb_goodToGo:=False:C215
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"Error calling git command line"
End if 

If ($vb_goodToGo)
	If ($vt_shell_stdout#"@On branch master@")
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[stop] Git status does not show you as being on branch master."+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Use your Git app to sync your changes to your server if you are trying to branch."
		$vb_goodToGo:=False:C215
	End if 
End if 

If ($vb_goodToGo)
	  //On branch master
	  //Your branch is ahead of 'origin/master' by 1 commit.
	  //(Use "git push"to publish your local commits)
	  //nothing to commit, working tree clean
	If ($vt_shell_stdout="@Your branch is ahead of 'origin/master'@")
		$vb_Yes:=sh_msg_Alert ("You already have a local commit that hasn't been pushed to the git server. Do you want me to push them now?";"Yes";"No")
		If ($vb_Yes)
			$vb_goodToGo:=False:C215
			sh_msg_Alert ("Operation cancelled. You can run git push using your own git app to get things back in sync. ")
		Else 
			  // Run the git push.
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"Running git push"+<>CRLF
			o_gitRun:=git_run ("git push origin master")
			$vt_shell_stdout:=o_gitRun.$vt_shell_stdout
			$vt_shell_stderr:=o_gitRun.$vt_shell_stderr
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stdout+<>CRLF
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stderr+<>CRLF
			
			  // stderr fatal: unable to find remote helper for 'https'\n
			
			  // Enumerating objects: 9, done.
			  // Counting objects: 100% (9/9), done.
			  // Delta compression using up to 4 threads
			  // Compressing objects: 100% (4/4), done.
			  // Writing objects: 100% (5/5), 495 bytes | 495.00 KiB/s, done.
			  // Total 5 (delta 1), reused 0 (delta 0)
			  // remote: Resolving deltas: 100% (1/1), completed with 1 local object.
			  //    121518f..b5a154d  master -> master
			
			If ($vt_shell_stdout="@completed@")
				  // Good
			Else 
				$vb_goodToGo:=False:C215
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"Use a git app or command line to get your repo back in sync with the git server."+<>CRLF
			End if 
		End if 
	End if 
End if 



  // Check for server ahead of local


If ($vb_goodToGo)
	$vb_goodToGo:=deploy_git_push_ 
End if 

$0:=$vb_goodToGo