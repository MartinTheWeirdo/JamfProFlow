//%attributes = {}
  // sh_string_getSingularForm 

  // Suppose we're printing a note like "Found 2 scripts". That looks fine, but what if there's only one? 
  // "Found 1 scripts" looks dumb. We can run the string and count through here to fix it. 

$vt_string:=$1
If (Count parameters:C259=2)
	$vl_count:=$2
Else 
	$vl_count:=1
End if 

If ($vl_count=1)
	$vl_len:=Length:C16($vt_string)
	Case of 
		: (Substring:C12($vt_string;$vl_len-2)="ies")
			  // "Stories" to "Story"
			$vt_string:=Substring:C12($vt_string;1;$vl_len-3)+"y"
		: (Substring:C12($vt_string;$vl_len)="s")
			  // "Hats" to "Hat"
			$vt_string:=Substring:C12($vt_string;1;$vl_len-1)
	End case 
End if 
$0:=$vt_string
