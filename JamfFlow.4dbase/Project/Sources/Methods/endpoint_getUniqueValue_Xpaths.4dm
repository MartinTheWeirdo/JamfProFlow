//%attributes = {}
  // endpoint_getUniqueValue_Xpaths
  // $vt_xpathsToUniqueValues:=endpoint_getUniqueValue_Xpaths($vt_endpointType)

$vt_endpointType:=$1

QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Singular_Name:3=$vt_endpointType)
If (Records in selection:C76([Endpoints:7])=1)
	$vt_xpathsToUniqueValues:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17
Else 
	LogMessage (Current method name:C684;Current method path:C1201;"Saving XML";"data error";"There's no match for $vt_endpointType=[Endpoints]Human_Readable_Singular_Name "+$vt_endpointType)
	$vt_xpathsToUniqueValues:=""
End if 

$0:=$vt_xpathsToUniqueValues
