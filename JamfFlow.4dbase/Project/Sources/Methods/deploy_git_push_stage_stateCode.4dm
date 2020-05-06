//%attributes = {}
  // deploy_git_push_stage_stateCode

$vt_status:=$1

Case of 
	: ($vt_status=" ")
		$vt_statusHumanReadable:="not updated"
	: ($vt_status="M")
		$vt_statusHumanReadable:="Modified"
	: ($vt_status="A")
		$vt_statusHumanReadable:="added"
	: ($vt_status="D")
		$vt_statusHumanReadable:="deleted"
	: ($vt_status="R")
		$vt_statusHumanReadable:="renamed"
	: ($vt_status="C")
		$vt_statusHumanReadable:="copied"
	: ($vt_status="U")
		$vt_statusHumanReadable:="updated but unmerged"
	: ($vt_status="?")
		$vt_statusHumanReadable:="Untracked (new) file"
	Else 
		$vt_statusHumanReadable:="Unknown"
End case 

$0:=$vt_statusHumanReadable