//%attributes = {}
$vt:=$1

C_TEXT:C284($vt)
C_LONGINT:C283($vl_pos_found)
C_LONGINT:C283($vl_length_found)

If ($vt="<html>@")
	
	  // Remove html tags
	$vl_pos_found:=0
	$vl_length_found:=0
	While (Match regex:C1019("<[^>]+>";$vt;1;$vl_pos_found;$vl_length_found))
		$vt:=Delete string:C232($vt;$vl_pos_found;$vl_length_found)
	End while 
	
	  // Get rid of CRs and LFs
	$vt:=Replace string:C233($vt;Char:C90(Carriage return:K15:38);" ")
	$vt:=Replace string:C233($vt;Char:C90(Line feed:K15:40);" ")
	
	  // Get rid of the fluff text
	$vt:=Replace string:C233($vt;"Status page";"")
	$vt:=Replace string:C233($vt;"You can get technical details here.";"")
	$vt:=Replace string:C233($vt;"Please continue your visit at our home page.";"")
	
	While ($vt="@  @")
		$vt:=Replace string:C233($vt;"  ";" ")
	End while 
	
	  // delete space at beginning or end
	If ($vt=" @")
		If ($vt=" ")
			$vt:=""
		Else 
			$vt:=Substring:C12($vt;2)
		End if 
	End if 
	If ($vt="@ ")
		$vt:=Substring:C12($vt;1;Length:C16($vt)-1)
	End if 
	
End if 


  //  // Remove tags
  //$vl_pos_found:=0
  //$vl_length_found:=0
  //While (Match regex("<[^>]+>";$vt;1;$vl_pos_found;$vl_length_found))
  //$vt:=Delete string($vt;$vl_pos_found;$vl_length_found)
  //End while 

  //  // Remove blank lines and lines with nothing but whitespace
  //$vl_pos_found:=0
  //$vl_length_found:=0
  //While (Match regex("^ *\\n";$vt;1;$vl_pos_found;$vl_length_found))
  //$vt:=Delete string($vt;$vl_pos_found;$vl_length_found)
  //End while 

  //$vl_pos_found:=0
  //$vl_length_found:=0
  //While (Match regex("\\n *\\n";$vt;1;$vl_pos_found;$vl_length_found))
  //$vt:=Delete string($vt;$vl_pos_found;$vl_length_found)
  //End while 

  //$vt:=Replace string($vt;"You can get technical details here.";"")
  //$vt:=Replace string($vt;"Please continue your visit at our home page.";"")
  //$vt:=Replace string($vt;"   \n";"")


  //  //\n\n   Status page\n\n\nNot Found\nThe server has not found anything matching the request URI\nYou can get technical details here.\nPlease continue your visit at our home page.\n\n\n\n
  //  //$vt_xml:=Replace string($vt_xml;"Not Found"+Char(Line feed);"")

  //$vt_2LF:=(Char(Line feed))*2
  //$vt_2CR:=(Char(Carriage return))*2

  //While (Position($vt_2CR;$vt)>0)
  //$vt:=Replace string($vt;$vt_2CR;Char(Carriage return))
  //End while 
  //While (Position($vt_2LF;$vt)>0)
  //$vt:=Replace string($vt;$vt_2LF;Char(Line feed))
  //End while 

  //  // Strip CR or LF at the very end
  //$vl:=Length($vt)
  //If ($vl>0)
  //$vt_lastChar:=$vt[[$vl]]
  //If (($vt_lastChar=Char(Line feed)) | ($vt_lastChar=Char(Carriage return)))
  //$vt:=Substring($vt;1;$vl-1)
  //End if 
  //End if 

  //  //$vt_xml:=Replace string($vt_xml;(Char(Carriage return))*2;<>CRLF)
  //  //$vt_xml:=Replace string($vt_xml;(Char(Line feed))*3;<>CRLF)
  //  //$vt_xml:=Replace string($vt_xml;(Char(Line feed))*2;<>CRLF)

$0:=$vt