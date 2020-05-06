//%attributes = {}
  // sh_arr_textLinesToArray
  // sh_arr_textLinesToArray ([Endpoints]xPathsToBaseGet_itemNames;->$at_xPathsToBaseGet_itemNames)

$vt:=$1
$pt:=$2

If ($vt#"")
	$vl_position:=Position:C15(<>CRLF;$vt)
	While ($vl_position>0)
		$vt_line:=Substring:C12($vt;1;$vl_position-1)
		$vt:=Substring:C12($vt;$vl_position+1)
		APPEND TO ARRAY:C911($pt->;$vt_line)
		$vl_position:=Position:C15(<>CRLF;$vt)
	End while 
	If ($vt#"")
		APPEND TO ARRAY:C911($pt->;$vt)
	End if 
End if 
