//%attributes = {}
  // deploy_JamfPro_Push_dlgArrays
  // deploy_JamfPro_Push_dlgArrays($vb_goodToGo;$vb_processThisItem;$vt_postOrPutRestMethod;$vt_deployed_Note)


$vb_goodToGo:=$1
$vb_processThisItem:=$2
$vt_postOrPutRestMethod:=$3
$vt_deployed_Note:=$4


  // Write outcome to a status array set we can display when we're done
APPEND TO ARRAY:C911(at_deployed_Set;[Sets:1]Name:2)
APPEND TO ARRAY:C911(at_deployed_ItemType;[Endpoints:7]Human_Readable_Plural_Name:2)
APPEND TO ARRAY:C911(at_deployed_ItemName;[XML:2]HumanReadableItemName:9)
Case of 
	: ($vt_postOrPutRestMethod=HTTP POST method:K71:2)
		APPEND TO ARRAY:C911(at_deployed_AddedOrUpdated;"Add New")
	: ($vt_postOrPutRestMethod=HTTP PUT method:K71:6)
		APPEND TO ARRAY:C911(at_deployed_AddedOrUpdated;"Update")
	Else 
		If ($vb_processThisItem)
			APPEND TO ARRAY:C911(at_deployed_AddedOrUpdated;"Unknown")
		Else 
			APPEND TO ARRAY:C911(at_deployed_AddedOrUpdated;"Skip")
		End if 
End case 
Case of 
	: (Not:C34($vb_processThisItem))
		APPEND TO ARRAY:C911(at_deployed_Status;"Skipped")
		APPEND TO ARRAY:C911(al_deploy_rowColors;Yellow:K11:2)
	: ($vb_goodToGo)
		APPEND TO ARRAY:C911(at_deployed_Status;"OK")
		APPEND TO ARRAY:C911(al_deploy_rowColors;White:K11:1)
	: (Not:C34($vb_goodToGo))
		APPEND TO ARRAY:C911(at_deployed_Status;"Failed")
		APPEND TO ARRAY:C911(al_deploy_rowColors;Red:K11:4)
	Else 
		APPEND TO ARRAY:C911(at_deployed_Status;"Unknown")
		APPEND TO ARRAY:C911(al_deploy_rowColors;Yellow:K11:2)
End case 
APPEND TO ARRAY:C911(at_deployed_Note;$vt_deployed_Note)


  // No function output needed. 
