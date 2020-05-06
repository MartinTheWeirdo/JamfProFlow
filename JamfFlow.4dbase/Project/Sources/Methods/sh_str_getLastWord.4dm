//%attributes = {}
  // sh_str_getLastWord
$vt:=$1

If (Count parameters:C259=2)
	$vt_delim:=$2
Else 
	$vt_delim:=" "
End if 

If (Position:C15($vt_delim;$vt)<1)
	$0:=$vt
Else 
	For ($i;Length:C16($vt);1;-1)
		If ($vt[[$i]]=$vt_delim)
			$0:=Substring:C12($vt;$i+1)
			$i:=-99
		End if 
	End for 
End if 