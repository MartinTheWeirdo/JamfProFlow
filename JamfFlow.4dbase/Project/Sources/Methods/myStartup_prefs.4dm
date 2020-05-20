//%attributes = {}

  // Preload some resources into memory
  // Populate prefs if they do not yet exist


  // Default path to git repo? 
$vt_localRepoSystemPath:=System folder:C487(Documents folder:K41:18)+"GitHub:JamfProConfigSets:"
$vt_localRepoSystemPath_gitFolde:=$vt_localRepoSystemPath+".git"
If (Test path name:C476($vt_localRepoSystemPath_gitFolde)=Is a folder:K24:2)  // We have a winner
	  // exists
	$vt_localRepoSystemPath:=Convert path system to POSIX:C1106($vt_localRepoSystemPath)
	$vt_localRepoSystemPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path";$vt_localRepoSystemPath;False:C215;$vt_localRepoSystemPath)
Else 
	  // does not exist
	$vt_localRepoSystemPath:=sh_prefs_getValueForKey ("setting.git.local_repo_posix_path";"";False:C215;$vt_localRepoSystemPath)
End if 

  // Rest of the prefs are simpler
$vt_prefvalue:=sh_prefs_getValueForKey ("setting.approval.allowPostApprovalChange";"False";False:C215;"false")
$vt_prefvalue:=sh_prefs_getValueForKey ("setting.jamf.capi.http.timeout_seconds";"10";False:C215;"10")
$vt_prefvalue:=sh_prefs_getValueForKey ("setting.login.ad.domain";"";False:C215;"my.org")
$vt_prefvalue:=sh_prefs_getValueForKey ("setting.login.ad.domaincontroller.fqdn";"";False:C215;"ad.my.org")
$vt_prefvalue:=sh_prefs_getValueForKey ("setting.login.ad.domaincontroller.port";"";False:C215;"636")
$vt_prefvalue:=sh_prefs_getValueForKey ("setting.login.ad.userbase.ou";"";False:C215;"DC=my,DC=org")

  // Load keypairs table into an array
ARRAY TEXT:C222(<>as40_keyValuePairs_Keys;0)
ARRAY TEXT:C222(<>as40_keyValuePairs_Values;0)
ALL RECORDS:C47([KeyValuePairs:4])
ORDER BY:C49([KeyValuePairs:4];[KeyValuePairs:4]KeyName:2)
SELECTION TO ARRAY:C260([KeyValuePairs:4]KeyName:2;<>as40_keyValuePairs_Keys)
SELECTION TO ARRAY:C260([KeyValuePairs:4]ValueString:3;<>as40_keyValuePairs_Values)
