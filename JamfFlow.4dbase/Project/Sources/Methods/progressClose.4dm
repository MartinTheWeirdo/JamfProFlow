//%attributes = {}
  // progressClose

$vl_progressProcessRef:=$1
  //SET PROCESS VARIABLE($vl_progressProcessRef;vb_closeProgressWindow;True)
POST OUTSIDE CALL:C329($vl_progressProcessRef)
