//%attributes = {}
  // deploy_jamfPro_precheck

$vt_targetServer:=$1
$vt_Push_MergeOrCreateNew:=$2
$vl_DeployAddDateCheckbox:=$3

$vb_DeployAddDateCheckbox:=($vl_DeployAddDateCheckbox=1)

  // Check some re-requisites

  // Did they tell us what server they want to target? 
If ($vt_targetServer#"")
	$vb_goodToGo:=True:C214
Else 
	$vb_goodToGo:=False:C215
	sh_msg_Alert ("Please select a target server")
	$vb_goodToGo:=False:C215
End if 


If ($vb_goodToGo)
	  // There are some data value uniqueness constraints. 
	  // Like you can't have two distribution points with the same name, two computers
	  // can't have the same serial number/UUID, etc.
	FIRST RECORD:C50([Sets:1])
	For ($vl_setIterator;1;Records in selection:C76([Sets:1]))  // Loop throught the list of sets
		If (Is in set:C273("$ab_DeploySetsHighlightedSet"))  // See if the set is highlighted
			  // Load the XML records for this set
			$vb_goodToGo:=deploy_jamfPro_precheck_Set ([Sets:1]ID:1;[Sets:1]Name:2;$vt_targetServer;$vb_DeployAddDateCheckbox;$vt_Push_MergeOrCreateNew)
			If (Not:C34($vb_goodToGo))
				$vl_setIterator:=Records in selection:C76([Sets:1])  // Pop the loop
			End if 
		End if   // If (ab_DeploySetsListBox{$vl_pushListIterator}) // See if the set is highlighted
		NEXT RECORD:C51([Sets:1])
	End for   // For ($vl_pushListIterator;1;Records in selection([Sets]))  // Loop throught the list of sets
End if 

$0:=$vb_goodToGo