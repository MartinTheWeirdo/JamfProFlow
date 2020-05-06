//%attributes = {}
  // deploy_jamfPro

C_TEXT:C284($vt_targetServer;$vt_Push_MergeOrCreateNew)
C_BOOLEAN:C305($vb_goodToGo;$vb_ScopeRemovalRequested;$vb_AddDateTimeToName)

$vt_targetServer:=sh_arr_getCurrentValue (->at_SelectTargetJamfProServers)
$vt_Push_MergeOrCreateNew:=sh_arr_getCurrentValue (->at_Push_MergeOrNew_Options)

$vb_goodToGo:=deploy_jamfPro_precheck ($vt_targetServer;$vt_Push_MergeOrCreateNew;vl_DeployAddDateCheckbox)

  // Now send the data to the target server
If ($vb_goodToGo)
	$vb_goodToGo:=deploy_JamfPro_Push ($vt_targetServer;$vt_Push_MergeOrCreateNew)
End if 

$0:=$vb_goodToGo