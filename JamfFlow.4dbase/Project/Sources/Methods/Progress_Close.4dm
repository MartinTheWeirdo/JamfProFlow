//%attributes = {}
  // Progress_Close ($vl_progressProcessRef)

$vl_progressProcessRef:=$1

Case of 
	: ($vl_progressProcessRef=1)
		Progress QUIT ($vl_progressProcessRef)
	: ($vl_progressProcessRef>1)
		ON ERR CALL:C155("sh_err_call")
		For ($i;1;$vl_progressProcessRef)
			Progress QUIT ($i)
		End for 
		ON ERR CALL:C155("")
End case 
