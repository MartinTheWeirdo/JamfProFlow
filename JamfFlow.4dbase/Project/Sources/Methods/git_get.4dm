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
		  // This variant checks to see if the path in settings is good and prompts the user to set it if it is not.
		
		$vt_localRepoPosixPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path")
		If ($vt_localRepoPosixPath="")
			$vb_validGit:=False:C215
		Else 
			$vt_localRepoSystemPath:=Convert path POSIX to system:C1107($vt_localRepoPosixPath)
			$vt_localRepoSystemPath_gitFile:=$vt_localRepoSystemPath+".git"
			$vb_validGit:=(Test path name:C476($vt_localRepoSystemPath_gitFile)=Is a folder:K24:2)
		End if 
		
		If (Not:C34($vb_validGit))
			$vt_defaultGitFolder:=System folder:C487(Documents folder:K41:18)+"GitHub"
			If (Test path name:C476($vt_defaultGitFolder)#Is a folder:K24:2)  // Nothing doing? 
				$vt_defaultGitFolder:=System folder:C487(Documents folder:K41:18)  // Just start with documents folder
			End if 
			$vt_localRepoSystemPath:=Select folder:C670("Please select your local git repo folder...";$vt_defaultGitFolder)
			If (OK=1)
				$vt_localRepoSystemPath_gitFile:=$vt_localRepoSystemPath+".git"
				If (Test path name:C476($vt_localRepoSystemPath_gitFile)=Is a folder:K24:2)  // We have a winner
					$vt_localRepoPosixPath:=Convert path system to POSIX:C1106($vt_localRepoSystemPath)
					$vt_localRepoPosixPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path";$vt_localRepoPosixPath;True:C214)
					$vt_return:=$vt_localRepoPosixPath
					  // Change the menu options
					ARRAY TEXT:C222(at_gitOpsDropdownMenu;0)
					APPEND TO ARRAY:C911(at_gitOpsDropdownMenu;"Select an action...")
					APPEND TO ARRAY:C911(at_gitOpsDropdownMenu;"Refresh list from local git repo")
					APPEND TO ARRAY:C911(at_gitOpsDropdownMenu;"Refresh local git repo from git server")
					APPEND TO ARRAY:C911(at_gitOpsDropdownMenu;"Import git set into database")
				Else 
					sh_msg_Alert ("I don't see the git folder "+sh_str_dq ())
				End if 
			Else 
				$vt_localRepoPosixPath:=""
			End if 
		End if 
		$vt_return:=$vt_localRepoPosixPath
		
		
	: ($vt_infoNeeded="LocalRepoPathSystem")
		  // This can return "" if path is not set
		$vt_localRepoPosixPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path")
		  //If ($vt_localRepoPosixPath="")
		  //$vt_localRepoPosixPath:=git_get ("LocalRepoPathPosix")
		  //End if 
		If ($vt_localRepoPosixPath#"")
			$vt_localRepoSystemPath:=Convert path POSIX to system:C1107($vt_localRepoPosixPath)
			  // Is it valid? 
			$vt_localRepoSystemPath_gitFoldr:=$vt_localRepoSystemPath+".git"
			If (Test path name:C476($vt_localRepoSystemPath_gitFoldr)#Is a folder:K24:2)
				  // Pref is set, but it's not a valid repo. Return empty string
				$vt_localRepoSystemPath_gitFoldr:=""
			End if 
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
