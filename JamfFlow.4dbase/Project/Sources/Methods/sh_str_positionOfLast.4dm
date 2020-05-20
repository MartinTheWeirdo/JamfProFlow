//%attributes = {}
  // sh_str_positionOfLast
  // $vl_positionOfLast:=sh_str_positionOfLast(".";"email.jamf.com) == 11

C_TEXT:C284($vt_find;$1;$vt_in;$2)
C_LONGINT:C283($vl_positionOfLast;$vl_start;$vl_lengthfound)

$vt_find:=$1
$vt_in:=$2

$vl_positionOfLast:=-1
$vl_start:=1
Repeat 
	$vl_position:=Position:C15($vt_find;$vt_in;$vl_start;$vl_lengthfound)
	If ($vl_position>0)
		$vl_positionOfLast:=$vl_position
		$vl_start:=$vl_position+$vl_lengthfound
	End if 
Until ($vl_position<1)

$0:=$vl_positionOfLast