  // at_gitOpsDropdownMenu

If (FORM Event:C1606.code=On Clicked:K2:4)
	If (Self:C308->#1)
		If ((sh_prefs_getValueForKey ("setting.git.local_repo_posix_path"))="")
			sh_msg_Alert ("Please go to the Flow>Preferences Menu item and enter the path for your local repo folder first...")
			ABORT:C156
		Else 
			deploy_git_listOps 
		End if 
	End if 
End if   // If (FORM Event.code=On Clicked)

If ((Form event code:C388=On Load:K2:1) | ((FORM Event:C1606.code=On Clicked:K2:4) & (Self:C308->#1)))  // Update the list of sets in the local git repo folder
	If (sh_prefs_getValueForKey ("setting.git.local_repo_posix_path")#"")
		FOLDER LIST:C473(git_get ("LocalRepoPathSystem");at_deployLocalGitSetNames)
		  // Don't show the git file
		$vl_indexOfDotGitEntry:=Find in array:C230(at_deployLocalGitSetNames;".git")
		If ($vl_indexOfDotGitEntry>0)
			DELETE FROM ARRAY:C228(at_deployLocalGitSetNames;$vl_indexOfDotGitEntry)
		End if 
	End if 
End if 


If (FORM Event:C1606.code=On Clicked:K2:4)
	If (Self:C308->#1)
		vt_deployedItemsSummary:=Replace string:C233(vt_deployedItemsSummary;"\n\n\n";"\n\n")
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Local git repo items listing was updated."
		BEEP:C151
		Self:C308->:=1  // Pop back to the first element... the dropdown's menu label. 
	End if 
End if   // If (FORM Event.code=On Clicked)
