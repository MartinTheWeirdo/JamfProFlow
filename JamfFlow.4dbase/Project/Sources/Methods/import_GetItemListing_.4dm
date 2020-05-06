//%attributes = {}
  //import_GetItemListing_ ($selectedSourceServer;$vt_SelectedItemType)

  // We get a server and the kind of data they want to see, we get a list of items (computers, etc.)
  //  in that data category and populate arrays for a list box. 

$vt_selectedSourceServer:=$1
$vt_SelectedItemType:=$2

  // Some of the things in the dropdown for data types could be meta-choices. 
  // E.g. Settings could pull data from multiple endpoints

ARRAY TEXT:C222($at_selectedItemTypes;0)
Case of 
		
	: ($vt_SelectedItemType="All Settings")
		QUERY:C277([EndpointCategories:8];[EndpointCategories:8]Category_Name:2="Settings")
		$vl_SettingsCategoryID:=[EndpointCategories:8]ID:1
		QUERY:C277([Endpoints:7];[EndpointCategories:8]Parent Category:3=$vl_SettingsCategoryID;*)
		QUERY:C277([Endpoints:7]; & ;[Endpoints:7]isDepreciated:29=False:C215;*)
		QUERY:C277([Endpoints:7]; & ;[Endpoints:7]Has_Method_Get:12=True:C214)
		SELECTION TO ARRAY:C260([Endpoints:7]Human_Readable_Plural_Name:2;$at_selectedItemTypes)
		
	: ($vt_SelectedItemType="Everything except devices")
		  //QUERY([Endpoints];[Endpoints]Has_Method_Get=True)
		  //QUERY SELECTION([Endpoints];[Endpoints]API_Endpoint_Name#"computers";*)
		  //QUERY SELECTION([Endpoints]; & ;[Endpoints]API_Endpoint_Name#"mobiledevices";*)
		  //QUERY SELECTION([Endpoints]; & ;[Endpoints]API_Endpoint_Name#"users")
		QUERY:C277([Endpoints:7];[Endpoints:7]Has_Method_Get:12=True:C214;*)
		QUERY:C277([Endpoints:7]; & ;[Endpoints:7]isDepreciated:29=False:C215;*)
		QUERY:C277([Endpoints:7]; & ;[Endpoints:7]API_Endpoint_Name:8#"computers";*)
		QUERY:C277([Endpoints:7]; & ;[Endpoints:7]API_Endpoint_Name:8#"mobiledevices";*)
		QUERY:C277([Endpoints:7]; & ;[Endpoints:7]API_Endpoint_Name:8#"users")
		SELECTION TO ARRAY:C260([Endpoints:7]Human_Readable_Plural_Name:2;$at_selectedItemTypes)
		
	: ($vt_SelectedItemType="Everything")
		  // We'll pull in everything that has a GET method, except computer reports
		QUERY:C277([Endpoints:7];[Endpoints:7]Has_Method_Get:12=True:C214;*)
		QUERY:C277([Endpoints:7]; & ;[Endpoints:7]isDepreciated:29=False:C215;*)
		QUERY:C277([Endpoints:7]; & [Endpoints:7]API_Endpoint_Name:8#"computerreports";*)
		QUERY:C277([Endpoints:7]; & [Endpoints:7]API_Endpoint_Name:8#"savedsearches")
		SELECTION TO ARRAY:C260([Endpoints:7]Human_Readable_Plural_Name:2;$at_selectedItemTypes)
		
	Else 
		APPEND TO ARRAY:C911($at_selectedItemTypes;$vt_SelectedItemType)
End case 


$vl_currentFormWindowRef:=Current form window:C827
$vl_left:=10
$vl_top:=50
$vl_right:=0
$vl_bottom:=0
GET WINDOW RECT:C443($vl_left;$vl_top;$vl_right;$vl_bottom;$vl_currentFormWindowRef)
$vl_progressProcessRef:=Progress New (False:C215)
  //Progress SET WINDOW VISIBLE (False)
Progress SET WINDOW VISIBLE (True:C214;$vl_left+20;$vl_top+100;True:C214)
Progress SET FONT SIZES (13;12;13)
Progress SET TITLE ($vl_progressProcessRef;"Reading data from "+$vt_selectedSourceServer)
Progress SET BUTTON ENABLED ($vl_progressProcessRef;True:C214)


  // Now loop through the list of selected data types 
$vl_countOfDataItemTypesToReadIn:=Size of array:C274($at_selectedItemTypes)
For ($vl_selectedDataTypesIterator;1;$vl_countOfDataItemTypesToReadIn)
	
	If (Progress Stopped ($vl_progressProcessRef))
		$vl_selectedDataTypesIterator:=$vl_countOfDataItemTypesToReadIn+1  // Pop the loop
	Else   // Keep going
		
		  // Put the current type we want to read into a var
		$vt_selectedItemType:=$at_selectedItemTypes{$vl_selectedDataTypesIterator}
		
		  // TODO...
		  // We either need to do indeterminate (good choice for small things.)
		  // For computers/Devices/Users, should get count via API then show the load for each. 
		  // Each type could have it's own sub progress
		Progress SET PROGRESS ($vl_progressProcessRef;$vl_selectedDataTypesIterator-1/$vl_countOfDataItemTypesToReadIn;"Reading "+$vt_selectedItemType;False:C215)
		
		  //
		  // Make the call to the API
		  //
		import_GetItemListing_arrays ($vt_selectedSourceServer;$vt_SelectedItemType)
		
	End if   // Progress stop button check
End for 

  // Sort arrays
MULTI SORT ARRAY:C718(at_sourceItemLB_types;>;at_sourceItemLB_Names;>;al_sourceItemLB_IDs;>)

  // Trim trailing CR off the item details box text that will be left over after we've looped throught the data types array
$vt:="@"+<>CRLF
If (vt_sourceSetSummary=$vt)
	vt_sourceSetSummary:=Substring:C12(vt_sourceSetSummary;1;Length:C16(vt_sourceSetSummary)-1)
End if 

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
