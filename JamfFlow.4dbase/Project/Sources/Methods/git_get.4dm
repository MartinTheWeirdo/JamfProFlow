//%attributes = {}
  // git_get("InfoNeeded")
  // $vt_localRepoPoxixPath:=git_get("LocalRepoPathPosix")
  // git_get("LocalRepoPathSystem")
  // git_get("git")

$vt_infoNeeded:=$1
If (Count parameters:C259=2)
	$vt_shell_cmd:=$2
Else 
	$vt_shell_cmd:=""
End if 

$vt_return:=""


Case of 
		
	: ($vt_infoNeeded="gitcmd")
		$vt_return:=""  // Return empty on fail
		If ($vt_shell_cmd#"")
			$vt_gitPath:=git_get ("git")
			$vt_localRepoPosixPath:=git_get ("LocalRepoPathPosix")
			$vt_gitDir:=" --git-dir="+sh_str_dq ($vt_localRepoPosixPath)  // /Users/admin/Documents/GitHub/JamfProFlow-Sets
			$vt_execPath:=git_get ("exec-path")
			If (($vt_gitPath#"") & ($vt_localRepoPosixPath#""))  // We got values for both of the paths we need? 
				If ($vt_shell_cmd="git @")
					$vt_shell_cmd:=Delete string:C232($vt_shell_cmd;1;3)
					$vt_shell_cmd:=$vt_gitPath+$vt_execPath+$vt_shell_cmd
					  //$vt_shell_cmd:=$vt_gitPath+$vt_gitDir+$vt_execPath+$vt_shell_cmd
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY";$vt_localRepoPosixPath)
					  // Try setting exec dir as env var here? Check if it would bleed into user shell... env in terminal, e.g.
					$vt_return:=$vt_shell_cmd
				End if 
			End if 
		End if 
		
		
		
		
		
		
	: ($vt_infoNeeded="LocalRepoPathPosix")
		
		$vt_localRepoPosixPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path")
		$vb_localRepoPoxixPath_hasValue:=($vt_localRepoPosixPath#"")
		If ($vb_localRepoPoxixPath_hasValue)
			$vt_localRepoSystemPath:=Convert path POSIX to system:C1107($vt_localRepoPosixPath)
			$vt_localRepoSystemPath_gitFile:=$vt_localRepoSystemPath+".git"
			$vb_hasGitFile:=(Test path name:C476($vt_localRepoSystemPath_gitFile)=Is a folder:K24:2)
		Else 
			$vb_hasGitFile:=False:C215
		End if 
		
		Case of 
			: (Not:C34($vb_hasGitFile))
				$vt_doYaWannaPrompt:="The git repo folder "+sh_str_dq ($vt_localRepoPosixPath)+" set in prefs wasn't found. Would you like to re-set the link to another folder?"
			: (Not:C34($vb_localRepoPoxixPath_hasValue))
				$vt_doYaWannaPrompt:="Do you already have a local git repository folder you'd like to use?"
			Else 
				$vt_doYaWannaPrompt:=""
				$vt_return:=$vt_localRepoPosixPath
		End case 
		
		If ($vt_doYaWannaPrompt#"")
			  // Ask them if they have a local repo folder
			$vb_Yes:=sh_msg_Alert ($vt_doYaWannaPrompt;"Yes";"No")
			If ($vb_Yes)
				  // They answered yes. Ask them to show us where it is...
				
				$vt_defaultGitFolder:=System folder:C487(Documents folder:K41:18)+"GitHub"
				If (Test path name:C476($vt_defaultGitFolder)#Is a folder:K24:2)  // Nothing doing? 
					$vt_defaultGitFolder:=System folder:C487(Documents folder:K41:18)  // Just start with documents folder
				End if 
				$vt_localRepoSystemPath:=Select folder:C670("Please select the folder for the existing git repository...";$vt_defaultGitFolder)
				$vt_localRepoSystemPath_gitFile:=$vt_localRepoSystemPath+".git"
				If (Test path name:C476($vt_localRepoSystemPath_gitFile)=Is a folder:K24:2)  // We have a winner
					$vt_localRepoPosixPath:=Convert path system to POSIX:C1106($vt_localRepoSystemPath)
					$vt_localRepoPosixPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path";$vt_localRepoPosixPath;True:C214)
					$vt_return:=$vt_localRepoPosixPath
				End if 
			Else 
				sh_msg_Alert ("Create or clone a repo with git command line or Github Desktop so you have a local folder then try again.")
			End if   //
		End if 
		
		
	: ($vt_infoNeeded="LocalRepoPathSystem")
		$vt_localRepoPosixPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path")
		If ($vt_localRepoPosixPath="")
			$vt_localRepoPosixPath:=git_get ("LocalRepoPathPosix")
		End if 
		If ($vt_localRepoPosixPath#"")
			$vt_localRepoSystemPath:=Convert path POSIX to system:C1107($vt_localRepoPosixPath)
		End if 
		$vt_return:=$vt_localRepoSystemPath
		
		
	: ($vt_infoNeeded="git")
		  // /Users/admin/Documents/GitHub/JamfProFlow/JamfProFlow.4dbase/Resources/git/bin/git
		$vt_gitPath:=Get 4D folder:C485(Current resources folder:K5:16)+"git:bin:git"
		If (Test path name:C476($vt_gitPath)#Is a document:K24:1)
			$vt_return:="git"
		Else 
			$vt_return:=Convert path system to POSIX:C1106($vt_gitPath)
		End if 
		
	: ($vt_infoNeeded="exec-path")
		  // /Library/Developer/CommandLineTools/usr/libexec/git-core (with standard Apple dev tools)
		  // /Users/admin/Documents/GitHub/JamfProFlow/JamfProFlow.4dbase/Resources/git/libexec/git-core (embedded in app)
		$vt_gitPath:=Get 4D folder:C485(Current resources folder:K5:16)+"git:libexec:git-core"
		If (Test path name:C476($vt_gitPath)#Is a folder:K24:2)
			$vt_return:=""
		Else 
			$vt_gitPath:=Convert path system to POSIX:C1106($vt_gitPath)+"/"
			$vt_return:=" --exec-path="+sh_str_dq ($vt_gitPath)
		End if 
		
		
End case 

$0:=$vt_return
