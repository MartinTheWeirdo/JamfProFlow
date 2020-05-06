//%attributes = {}
  // Import_Selected_GetIDs_

$vt_xmlElementRef:=$1
$vt_xmlElementName:=$2
$vt_RootObjectInfo:=$3

If ($vt_xmlElementName="id")
	  // We found an ID element
	  // Get its value...
	C_TEXT:C284($vt_idElementValue)
	DOM GET XML ELEMENT VALUE:C731($vt_xmlElementRef;$vt_idElementValue)
	If (Num:C11($vt_idElementValue)<0)
		  // Things like site will appear with -1 ID if they have no setting. 
		  // Stale computer inventory with deleted profiles won't match up with anything 
		  //  in the db and you'll get negative IDs in /Computer/configuration_profiles/configuration_profile
		  // In these cases, skip it.  
	Else 
		Import_Selected_GetIDs_id ($vt_xmlElementRef;$vt_idElementValue;$vt_RootObjectInfo)
	End if   // If ($vt_idElementValue="-1")
Else 
	  // This is not an id element. Let's see if it has any children who are
	ARRAY LONGINT:C221($al_childTypes;0)
	ARRAY TEXT:C222($at_childNodeRefs;0)
	DOM GET XML CHILD NODES:C1081($vt_xmlElementRef;$al_childTypes;$at_childNodeRefs)
	For ($i;1;Size of array:C274($al_childTypes))
		If ($al_childTypes{$i}=XML ELEMENT:K45:20)  // $childTypes_al -- XML ELEMENT Longint 11
			Import_Selected_GetIDs ($at_childNodeRefs{$i};$vt_RootObjectInfo)  // Call this method re-entrantly
		End if 
	End for 
End if   // If ($vt_xmlElementName="id")