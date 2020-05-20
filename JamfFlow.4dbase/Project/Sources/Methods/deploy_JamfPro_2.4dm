//%attributes = {}
  // deploy_JamfPro_2
  // Called by : deploy > deploy_jamfPro > deploy_JamfPro_Push 

$vt_targetServer:=$1
$vt_Push_MergeOrCreateNew:=$2
$vb_ScopeRemovalRequested:=$3
$vb_AddDateTimeToName:=$4
$vt_dateTimeStamp:=$5
$vt_API_User_Name:=$6
$vt_API_Password:=$7

C_TEXT:C284($vt_targetServer;$1;$vt_Push_MergeOrCreateNew;$2;$vt_dateTimeStamp;$5;$vt_API_User_Name;$6;$vt_API_Password;$7)
C_BOOLEAN:C305($vb_ScopeRemovalRequested;$3;$vb_AddDateTimeToName;$4)


C_TEXT:C284($vt_deployed_Note)


$vb_UserInteruptedProcess:=False:C215  // We'll flip this if the user presses the stop button in the progress bar

$vt_onErrorAction:="Ask"  // The first time we hit an error we'll ask if they want to stop or just skip error items

$vl_progressProcessRef:=sh_progress_new ("Uploading Configurations...";900;500)

  // To keep a list of what worked and what did not that we can display when done...
ARRAY TEXT:C222(at_deployed_Set;0)
ARRAY TEXT:C222(at_deployed_ItemType;0)
ARRAY TEXT:C222(at_deployed_ItemName;0)
ARRAY TEXT:C222(at_deployed_AddedOrUpdated;0)
ARRAY TEXT:C222(at_deployed_Status;0)
ARRAY TEXT:C222(at_deployed_Note;0)
ARRAY LONGINT:C221(al_deploy_rowColors;0)
$vl_TotalSetCount:=0
$vl_TotalItemCount:=0
$vl_TotalItemCount_ok:=0
$vl_TotalItemCount_skip:=0
$vl_TotalItemCount_fail:=0


FIRST RECORD:C50([Sets:1])
For ($vl_pushListIterator;1;Records in selection:C76([Sets:1]))  // Loop throught the list of sets
	
	If (Is in set:C273("$ab_DeploySetsHighlightedSet"))
		
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"======================================================="+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Starting upload of configuration set "+[Sets:1]Name:2+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"======================================================="+<>CRLF
		
		$vl_TotalSetCount:=$vl_TotalSetCount+1
		
		  // Load the XML records for this set
		QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
		ORDER BY:C49([XML:2];[XML:2]PushPriority:11;>;[XML:2]ItemType:6;>;[XML:2]HumanReadableItemName:9;>)
		
		$vl_NumberOfItemsToSave:=Records in selection:C76([XML:2])
		For ($vl_xmlIterator;1;$vl_NumberOfItemsToSave)  // Loop through the xml records for the current set
			
			QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Singular_Name:3=[XML:2]ItemType:6)
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"• Sending "+[Endpoints:7]Human_Readable_Singular_Name:3+": "+[XML:2]HumanReadableItemName:9
			Progress SET PROGRESS ($vl_progressProcessRef;$vl_xmlIterator/$vl_NumberOfItemsToSave;[Endpoints:7]Human_Readable_Singular_Name:3+": "+[XML:2]HumanReadableItemName:9;False:C215)
			
			
			If (deploy_JamfPro_Push_Skip ([Endpoints:7]API_Endpoint_Name:8))
				$vt_deployed_Note:="⚠️ I don't know how to import this endpoint type."  // This item will never make it to processing, so set a note for the outcome nofification
				$vb_processThisItem:=False:C215
				$vt_postOrPutRestMethod:=""
				$vb_goodToGo:=True:C214
			Else 
				$vb_processThisItem:=True:C214
			End if 
			
			
			If ($vb_processThisItem)
				C_OBJECT:C1216($o_return)
				  //
				  // Submit XML for upload to Jamf Pro...
				  //
				$o_return:=deploy_JamfPro_3 ($vt_Push_MergeOrCreateNew;$vt_targetServer;$vt_API_User_Name;$vt_API_Password;$vt_onErrorAction;$vl_xmlIterator;$vl_NumberOfItemsToSave;$vb_AddDateTimeToName;$vt_dateTimeStamp)
				$vb_goodToGo:=$o_return.$vb_goodToGo
				$vt_postOrPutRestMethod:=$o_return.$vt_postOrPutRestMethod
				$vt_deployed_Note:=$o_return.$vt_deployed_Note
				$vt_onErrorAction:=$o_return.$vt_onErrorAction
				$vb_processThisItem:=$o_return.$vb_processThisItem
			End if 
			
			
			  // Accounting for our work...
			$vl_TotalItemCount:=$vl_TotalItemCount+1
			Case of 
				: (Not:C34($vb_processThisItem))
					$vl_TotalItemCount_skip:=$vl_TotalItemCount_skip+1
				: ($vb_goodToGo)
					$vl_TotalItemCount_ok:=$vl_TotalItemCount_ok+1
				: (Not:C34($vb_goodToGo))
					$vl_TotalItemCount_fail:=$vl_TotalItemCount_fail+1
			End case 
			deploy_JamfPro_Push_dlgArrays ($vb_goodToGo;$vb_processThisItem;$vt_postOrPutRestMethod;$vt_deployed_Note)
			
			
			If (Progress Stopped ($vl_progressProcessRef))
				sh_msg_Alert ("Stop button clicked. Upload to Jamf Pro stopped.")
				$vb_UserInteruptedProcess:=True:C214
				$vl_xmlIterator:=$vl_NumberOfItemsToSave  // pop xml loop
				$vl_pushListIterator:=Records in selection:C76([Sets:1])  // pop sets loop
			End if 
			
			
			If ((Not:C34($vb_goodToGo)) & ($vt_onErrorAction="Stop"))
				  // Pop the loop
				$vl_xmlIterator:=$vl_NumberOfItemsToSave  // pop xml loop
				$vl_pushListIterator:=Records in selection:C76([Sets:1])  // pop sets loop
			End if 
			
			
			
			NEXT RECORD:C51([XML:2])
		End for   // For ($vl_xmlIterator;1;Records in selection([XML]))  // Loop through the xml records for the current set
		
	End if 
	NEXT RECORD:C51([Sets:1])
End for   // For ($vl_pushListIterator;1;Records in selection([Sets]))  // Loop throught the list of sets

sh_prg_close ($vl_progressProcessRef)  // Close progress window

deploy_JamfPro_Push_showDialog ($vb_UserInteruptedProcess;$vl_TotalItemCount;$vl_TotalSetCount;$vl_TotalItemCount_ok;$vl_TotalItemCount_skip;$vl_TotalItemCount_fail)

$0:=$vb_goodToGo
