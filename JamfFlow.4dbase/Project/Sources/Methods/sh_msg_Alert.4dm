//%attributes = {}
$vt_messageText:=$1
If (Count parameters:C259>=2)
	vt_alertDialogButtonText:=$2
Else 
	vt_alertDialogButtonText:="OK"
End if 

If (Count parameters:C259>=3)
	vt_alertDialogButtonText_No:=$3
Else 
	vt_alertDialogButtonText_No:=""
End if 

messageText:=$vt_messageText

  //Case of 
  //: ($vt_messageText="@error@")
  //GET PICTURE FROM LIBRARY("stop.png";messageIcon)
  //: ($vt_messageText="@warning@")
  //GET PICTURE FROM LIBRARY("warning.png";messageIcon)
  //: ($vt_messageText="@success@")
  //GET PICTURE FROM LIBRARY("thumbsup.png";messageIcon)
  //Else 
  //GET PICTURE FROM LIBRARY("jamf.png";messageIcon)
  //End case 
  // GET PICTURE FROM LIBRARY("jamf.png";messageIcon)

$vl_WindowReference:=Open form window:C675("message";Modal form dialog box:K39:7)
DIALOG:C40("message")
$0:=(OK=1)

CLOSE WINDOW:C154($vl_WindowReference)

