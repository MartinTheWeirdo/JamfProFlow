//%attributes = {}
  //deploy_git_listOps

  // Drop-down menu: at_gitOpsDropdownMenu
  // Listbox: ab_DeploySetsListBoxGit

  // Select an action...
  // Refresh list from local git repo
  // Refresh local git repo from git server
  // Import git set into database

vt_deployedItemsSummary:=""

$vt_selectedOperation:=sh_arr_getCurrentValue (->at_gitOpsDropdownMenu)
Case of 
		
	: ($vt_selectedOperation="Refresh list from local git repo")
		  // Nothing to do for this one. The popup's method refreshes any time it's clicked, no matter which option is chosen. 
		
	: ($vt_selectedOperation="Refresh local git repo from git server")
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Running git pull --force..."+<>CRLF
		o_gitRun:=git_run ("git pull --force")
		$vt_shell_stdout:=o_gitRun.$vt_shell_stdout
		$vt_shell_stderr:=o_gitRun.$vt_shell_stderr
		If ($vt_shell_stdout="")
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"Error calling git command line. Try syncing using a git app or command line."
		Else 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"-> "+$vt_shell_stdout+<>CRLF
			vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_shell_stderr+<>CRLF
		End if 
		
	: ($vt_selectedOperation="Import git set into database")
		deploy_git_listOps_import 
		
End case   // : ($vt_selectedOperation=)
