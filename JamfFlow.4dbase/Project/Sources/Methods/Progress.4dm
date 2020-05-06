//%attributes = {}
  // progress
  // progress($vl_progressProcessRef;$vt_Progress_CurrentSet;$vl_Progress_Set_Percent;$vt_Progress_CurrentXml;$vl_Progress_xml_Percent;vt_ProgressLog)

C_LONGINT:C283($vl_progressProcessRef;$vl_Progress_Set_Percent;$vl_Progress_xml_Percent)
C_TEXT:C284($vt_Progress_CurrentSet;$vt_Progress_CurrentXml;$vt_ProgressLog)

$vl_progressProcessRef:=$1
$vt_Progress_CurrentSet:=$2
$vl_Progress_Set_Percent:=$3
$vt_Progress_CurrentXml:=$4
$vl_Progress_xml_Percent:=$5
$vt_ProgressLog:=$6

If ($vt_ProgressSummary="Close")
	CANCEL:C270
Else 
	SET PROCESS VARIABLE:C370($vl_progressProcessRef;vt_Progress_CurrentSet;$vt_Progress_CurrentSet;vl_Progress_Set_Percent;$vl_Progress_Set_Percent;vt_Progress_CurrentXml;$vt_Progress_CurrentXml;vl_Progress_xml_Percent;$vl_Progress_xml_Percent;vt_ProgressLog;$vt_ProgressLog)
End if 


  //$vt_ProgressSummary:=

  //vl_ProgressThermometer:=0
  //vt_ProgressSummary:=""

  //:=$3



  //: (Count parameters=4)
  //  // Called from calling process to update progress


  //$vl_progressProcessRef:=$1
  //$pv_callingProcessLogRollVar:=$2
  //$vt_message:=$3
  //$vl_ProgressThermometerPercent:=$4

  //$pv_callingProcessLogRollVar:=$pv_callingProcessLogRollVar+$vt_message
  //SET PROCESS VARIABLE($vl_progressProcessRef;vt_ProgressSummary;$pv_callingProcessLogRollVar->;vl_ProgressThermometer;$vl_ProgressThermometerPercent)


  //$vl_progressProcessRef:=$1
  //$vl_callingProcessRef:=$2
  //$pv_callingProcessLogRoll:=$3

  //SET PROCESS VARIABLE($vl_progressProcessRef;
  //vt_deployedItemsStatus;$2

  //vt_ProgressSummary:=""
  //vl_ProgressThermometer:=0
  //vt_ProgressSummary:=""



  //$vl_progressWindowRef:=Open form window("Progress")
  //vt_deployedItemsStatus:=""
  //vt_ProgressSummary:=""
  //vl_ProgressThermometer:=0
  //vt_ProgressSummary:=""
  //DIALOG("Progress")

  //: ($vt_request="close")
  //CLOSE WINDOW($vl_progressWindowRef):=Open form window("Progress")
  //DIALOG("Progress")


  //Else 





  //End case 
