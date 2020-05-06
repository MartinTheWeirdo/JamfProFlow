If ((FORM Event:C1606.code=On Load:K2:1) | (FORM Event:C1606.code=On Clicked:K2:4))
	If ((sh_prefs_getValueForKey ("setting.git.local_repo_posix_path"))#"")
		git_getSyncStatus 
	End if 
End if 
