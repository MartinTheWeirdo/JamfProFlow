//%attributes = {}
ALL RECORDS:C47([KeyValuePairs:4])
APPLY TO SELECTION:C70([KeyValuePairs:4];[KeyValuePairs:4]ValueString:3:="")

ALL RECORDS:C47([XML:2])
DELETE SELECTION:C66([XML:2])

ALL RECORDS:C47([Sets:1])
DELETE SELECTION:C66([Sets:1])

ALL RECORDS:C47([UserTable:5])
  //QUERY SELECTION([UserTable];[UserTable]user_name#"Designer")
DELETE SELECTION:C66([UserTable:5])

QUERY:C277([JamfProServers:3];[JamfProServers:3]URL:2#"https://jamfproflow.jamfcloud.com")
DELETE SELECTION:C66([JamfProServers:3])

ALL RECORDS:C47([LogItems:6])
DELETE SELECTION:C66([LogItems:6])
