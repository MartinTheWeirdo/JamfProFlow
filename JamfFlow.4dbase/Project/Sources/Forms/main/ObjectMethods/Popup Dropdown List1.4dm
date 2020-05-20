  // at_gitOpsDropdownMenu

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		$vt_LocalRepoPathSystem:=git_get ("LocalRepoPathSystem")
		If ($vt_LocalRepoPathSystem="")
			  // There is none set
			  // Change the menu options
			ARRAY TEXT:C222(at_gitOpsDropdownMenu;0)
			APPEND TO ARRAY:C911(at_gitOpsDropdownMenu;"Select an action...")
			APPEND TO ARRAY:C911(at_gitOpsDropdownMenu;"Add your local git repo folder...")
		Else   // There is a local git repo folder setting
			  // Is it valid? 
			$vt_LocalRepoPathSystem_gitFoldr:=$vt_LocalRepoPathSystem+".git"
			If (Test path name:C476($vt_LocalRepoPathSystem_gitFoldr)=Is a folder:K24:2)
				  // It is valid...
				FOLDER LIST:C473($vt_LocalRepoPathSystem;at_deployLocalGitSetNames)
				  // Don't show the git file
				$vl_indexOfDotGitEntry:=Find in array:C230(at_deployLocalGitSetNames;".git")
				If ($vl_indexOfDotGitEntry>0)
					DELETE FROM ARRAY:C228(at_deployLocalGitSetNames;$vl_indexOfDotGitEntry)
				End if 
			Else   // There is a folder set in preferences, but it is not valid
				  // Change the menu options
				ARRAY TEXT:C222(at_gitOpsDropdownMenu;0)
				APPEND TO ARRAY:C911(at_gitOpsDropdownMenu;"Select an action...")
				APPEND TO ARRAY:C911(at_gitOpsDropdownMenu;"Reset local git repo folder...")
			End if 
		End if 
		at_gitOpsDropdownMenu:=1
		
		
		
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		If (Self:C308->#1)
			  //If ((sh_prefs_getValueForKey ("setting.git.local_repo_posix_path"))="")
			  //sh_msg_Alert ("Please go to the Flow>Preferences Menu item and enter the path for your local repo folder first...")
			  //ABORT
			  //Else 
			deploy_git_listOps 
			  //End if 
			
			BEEP:C151
			Self:C308->:=1  // Pop back to the first element... the dropdown's menu label. 
		End if 
		
End case 
