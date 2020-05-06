//%attributes = {}
  //Import_Selected_GetIDs


  // We have been called recursively
$vt_xmlElementRef:=$1
$vt_RootObjectInfo:=$2

C_TEXT:C284($vt_xmlElementName)
DOM GET XML ELEMENT NAME:C730($vt_xmlElementRef;$vt_xmlElementName)

If ($vt_xmlElementName="scope")
	  //TRACE
End if 

  // There are some cases where we will not import dependant items.
Case of 
	: (($vt_xmlElementName="scope") & (vl_ImportScopeDependeciesChkbox=0))
		  // This is a scope item but the user has not requested to include scopes
		$vb_importItem:=False:C215
	: ((($vt_xmlElementName="computers") | ($vt_xmlElementName="mobile_devices")) & (vl_ImportGroupMembersChkbox=0))
		  // if the tag is computers or mobile_devices then this is a list of group members. Don't select them if it was not requested. 
		$vb_importItem:=False:C215
	Else 
		$vb_importItem:=True:C214
End case 

If ($vb_importItem)
	Import_Selected_GetIDs_ ($vt_xmlElementRef;$vt_xmlElementName;$vt_RootObjectInfo)
End if   //If ((vl_ImportScopeDependeciesChkbox=1) | ((vl_ImportScopeDependeciesChkbox=0) & ($vt_xmlElementName#"scope")))

  // Test strap...
  //If (Count parameters=0)
  //C_TEXT($vt_xml;$vt_xmlElementRef)
  //$vt_xml:="<a><a1><name>a1</name><id>1</id><id>1a</id></a1><a2><id>1</id></a2></a>"
  //$vt_xmlElementRef:=DOM Parse XML variable($vt_xml)
  //ARRAY TEXT(at_importSelectedID_Types;0)
  //ARRAY LONGINT(al_importSelectedID_IDs;0)
  //ARRAY TEXT(at_importSelectedID_Names;0)
  //Import_Selected_GetIDs ($vt_xmlElementRef)
  //Else 
  //End if   // If (Count parameters=0)
