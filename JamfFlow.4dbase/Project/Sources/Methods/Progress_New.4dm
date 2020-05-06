//%attributes = {}
  // Progress_New
  // col 3 +1340
  // $vl_progressProcessRef:=Progress_New ("Saving Configuration Set";1340;100)

$vt_title:=$1
$vl_left_offset:=$2
$vl_top_offset:=$3

$vl_currentFormWindowRef:=Current form window:C827
$vl_left:=10
$vl_top:=50
$vl_right:=0
$vl_bottom:=0
GET WINDOW RECT:C443($vl_left;$vl_top;$vl_right;$vl_bottom;$vl_currentFormWindowRef)
$vl_progressProcessRef:=Progress New (True:C214)
Progress SET WINDOW VISIBLE (False:C215)
Progress SET WINDOW VISIBLE (True:C214;$vl_left+$vl_left_offset;$vl_top+$vl_top_offset;True:C214)
Progress SET TITLE ($vl_progressProcessRef;$vt_title)
Progress SET BUTTON ENABLED ($vl_progressProcessRef;True:C214)
Progress SET FONT SIZES (13;11;13)

$0:=$vl_progressProcessRef