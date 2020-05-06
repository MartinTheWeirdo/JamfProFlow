//%attributes = {}
  // sh_str_getPluralUpperForm 

  // Suppose we're listing selected items and the source xpath for a dependancy 
  //  says it's a "computer". We'll list it under the "Computers" category

$vt_string:=$1

$vl_len:=Length:C16($vt_string)
If ($vl_len>2)
	Case of 
		: ($vt_string="@y")  // "Policy" to "Policies"
			$vt_string:=Substring:C12($vt_string;1;$vl_len-1)+"ies"
		: ($vt_string="@ch")  // "Search" to "Searches"
			$vt_string:=$vt_string+"es"
		Else   // "Hat" to "Hats"
			$vt_string:=$vt_string+"s"
	End case 
	
	$vt_string:=Replace string:C233($vt_string;"_";" ")
	$vt_string:=Uppercase:C13($vt_string[[1]])+Substring:C12($vt_string;2)
End if 
$0:=$vt_string
