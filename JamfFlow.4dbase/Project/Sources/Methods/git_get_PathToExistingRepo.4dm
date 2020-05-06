//%attributes = {}
If (($vt_localRepoPosixPath="") | (Test path name:C476($vt_localRepoPosixPath)#Is a folder:K24:2))
	  // Not yet set up
	  // See if they have a github folder
	$vt_expectedPath:=System folder:C487(Documents folder:K41:18)+":GitHub"
	If (Test path name:C476($vt_expectedPath)#Is a folder:K24:2)
		$vt_expectedPath:=System folder:C487(Documents folder:K41:18)
		$vt_openFolderMessage:="Please select/create a local Git repo folder..."
	End if 
	$vt_localRepoSystemPath:=Select folder:C670($vt_expectedPath)
	If (OK=1)
		  // Selected
		$vt_localRepoPosixPath:=Convert path system to POSIX:C1106($vt_localRepoSystemPath)
		  // Write back to prefs table
		$vt_localRepoPosixPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path")
	Else 
		ABORT:C156
	End if 
End if 

$vt_localRepoSystemPath:=Convert path POSIX to system:C1107($vt_localRepoPosixPath)
If (Test path name:C476($vt_localRepoSystemPath)=Is a folder:K24:2)
	$vb_goodToGo:=True:C214
Else 
	sh_msg_Alert ("I could not find the Git local "+sh_str_dq ($vt_localRepoPosixPath)+" repo folder. Check your settings then try again.")
	myModSettings 
	$vb_goodToGo:=False:C215
End if 





$vt_shell_cmd:=Replace string:C233(vt_git_cmd;"git ";$vt_gitPath+" ")
$vt_shell_cmd:=Replace string:C233($vt_shell_cmd;":";"/")
$vl_hdPosition:=Position:C15("/";$vt_shell_cmd)
$vt_shell_cmd:=Substring:C12($vt_shell_cmd;$vl_hdPosition)
$vt_shell_stdin:=""
$vt_shell_stdout:=""
$vt_shell_stderr:=""
LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
If (OK=1)
	vt_settings_gitTerminal:=""
	vt_settings_gitTerminal:=vt_settings_gitTerminal+"$ "+vt_git_cmd+<>CRLF+<>CRLF
	vt_settings_gitTerminal:=vt_settings_gitTerminal+"stdout> "+$vt_shell_stdout
	vt_settings_gitTerminal:=vt_settings_gitTerminal+"stderr> "+$vt_shell_stderr
	
	APPEND TO ARRAY:C911(at_setting_cmds;vt_git_cmd)
	APPEND TO ARRAY:C911(at_settings_stdouts;$vt_shell_stdout)
Else 
	vt_settings_gitTerminal:="Error calling git: "+String:C10(vl_Error)
End if 
