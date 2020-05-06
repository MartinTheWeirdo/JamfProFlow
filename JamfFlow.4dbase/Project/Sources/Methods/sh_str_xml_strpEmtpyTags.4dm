//%attributes = {}
  // sh_str_xml_strpEmtpyTags
$vt_xml:=$1

C_TEXT:C284($vt_xml)
C_LONGINT:C283($vl_pos_found)
C_LONGINT:C283($vl_length_found)

$vl_pos_found:=0
$vl_length_found:=0
While (Match regex:C1019("<[^>]+/>";$vt_xml;1;$vl_pos_found;$vl_length_found))
	$vt_xml:=Delete string:C232($vt_xml;$vl_pos_found;$vl_length_found)
End while 

$0:=$vt_xml