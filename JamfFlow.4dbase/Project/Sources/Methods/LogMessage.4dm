//%attributes = {}
  // LogMessage
  // LogMessage($vt_CurrentMethodName;$vt_CurrentMethodPath;$vt_appArea;$vt_Level;$vt_Message)
  // LogMessage(Current method name;Current method path;$vt_appArea;$vt_Level;$vt_Message)

$vt_CurrentMethodName:=$1
$vt_CurrentMethodPath:=$2
$vt_appArea:=$3
$vt_Level:=$4
$vt_Message:=$5

CREATE RECORD:C68([LogItems:6])
[LogItems:6]method_name:7:=$vt_CurrentMethodName
[LogItems:6]method_path:8:=$vt_CurrentMethodPath
[LogItems:6]App_area:6:=$vt_appArea
[LogItems:6]ID:1:=Sequence number:C244([LogItems:6])
[LogItems:6]Item_date:2:=Current date:C33(*)
[LogItems:6]Item_time:3:=Current time:C178(*)
[LogItems:6]Level:5:=$vt_Level
[LogItems:6]Message:4:=$vt_Message
SAVE RECORD:C53([LogItems:6])
UNLOAD RECORD:C212([LogItems:6])