//%attributes = {}
  // deploy_JamfPro_Push_showDialog
  // deploy_JamfPro_Push_showDialog($vb_UserInteruptedProcess;$vl_TotalItemCount;$vl_TotalSetCount;$vl_TotalItemCount_ok;$vl_TotalItemCount_skip;$vl_TotalItemCount_fail)

$vb_UserInteruptedProcess:=$1
$vl_TotalItemCount:=$2
$vl_TotalSetCount:=$3
$vl_TotalItemCount_ok:=$4
$vl_TotalItemCount_skip:=$5
$vl_TotalItemCount_fail:=$6


vt_deployJamfProSummary:=""
If ($vb_UserInteruptedProcess)
	vt_deployJamfProSummary:=vt_deployJamfProSummary+"Upload cancelled after "
Else 
	vt_deployJamfProSummary:=vt_deployJamfProSummary+"Uploaded a total of "
End if 
vt_deployJamfProSummary:=vt_deployJamfProSummary+String:C10($vl_TotalItemCount)+" "+sh_str_getSingularForm ("items";$vl_TotalItemCount)+" "
vt_deployJamfProSummary:=vt_deployJamfProSummary+"from "+String:C10($vl_TotalSetCount)+" "+sh_str_getSingularForm ("Sets";$vl_TotalSetCount)+". "
vt_deployJamfProSummary:=vt_deployJamfProSummary+"Please see the transcript for additional details."+<>CRLF
vt_deployJamfProSummary:=vt_deployJamfProSummary+"✅ "+String:C10($vl_TotalItemCount_ok)+<>CRLF
vt_deployJamfProSummary:=vt_deployJamfProSummary+"⚠️ "+String:C10($vl_TotalItemCount_skip)+<>CRLF
vt_deployJamfProSummary:=vt_deployJamfProSummary+"🚫 "+String:C10($vl_TotalItemCount_fail)
BEEP:C151
$vl_outcomeFormWindowRef:=Open form window:C675("deploy_outcome")
DIALOG:C40("deploy_outcome")
CLOSE WINDOW:C154($vl_outcomeFormWindowRef)
