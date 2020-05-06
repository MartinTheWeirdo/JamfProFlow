//%attributes = {}
  // deploy_JamfPro_Push 

$vt_targetServer:=$1
$vt_Push_MergeOrCreateNew:=$2

C_TEXT:C284($vt_targetServer;$1;$vt_Push_MergeOrCreateNew;$2)
C_BOOLEAN:C305($vb_ScopeRemovalRequested;$vb_AddDateTimeToName)

$vb_ScopeRemovalRequested:=(vl_DeployScopeCheckbox=0)  // Flipping the meaning of true on this one... positive makes sense to user, negative makes sense in code logic
$vb_AddDateTimeToName:=(vl_DeployAddDateCheckbox=1)


If ($vb_AddDateTimeToName)
	$vt_dateTimeStamp:=" "+[UserTable:5]User_Initials:12+" "+String:C10(Current date:C33)+"T"+String:C10(Current time:C178)
End if 

$vb_goodToGo:=False:C215

$vt_userPipePass:=Import_GetJamfProServerLogin ($vt_targetServer)
If ($vt_userPipePass="")
	sh_msg_Alert ("I couldn't find a username and password for this Jamf Pro. Re-add it using the import server dropdown menu.")
	$vb_goodToGo:=False:C215
Else 
	$vl_PipePosition:=Position:C15("|";$vt_userPipePass)
	$vt_API_User_Name:=Substring:C12($vt_userPipePass;1;$vl_PipePosition-1)  // escape double-quotes in passwords? pipes in user?
	$vt_API_Password:=Substring:C12($vt_userPipePass;$vl_PipePosition+1)
End if   // If ($vt_userPipePass="")

$vb_goodToGo:=deploy_JamfPro_Push_ ($vt_targetServer;$vt_Push_MergeOrCreateNew;$vb_ScopeRemovalRequested;$vb_AddDateTimeToName;$vt_dateTimeStamp;$vt_API_User_Name;$vt_API_Password)

$0:=$vb_goodToGo
