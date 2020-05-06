//%attributes = {}
  // Import_UpdateExistingSet 

$vl_setID:=0

$vt_ImportOps_SetListPopupSetNam:=at_ImportOps_SetListPopup{at_ImportOps_SetListPopup}
QUERY:C277([Sets:1];[Sets:1]Name:2=$vt_ImportOps_SetListPopupSetNam)
$vl_FoundSetRecords:=Records in selection:C76([Sets:1])
Case of 
	: ($vl_FoundSetRecords=0)
		sh_msg_Alert ("The selected set no longer exists")
	: ($vl_FoundSetRecords>1)
		sh_msg_Alert ("There's more than on set named "+$vt_ImportOps_SetListPopupSetNam+" so I don't know which one to update. You should delete the extras then try again.")
		LogMessage (Current method name:C684;Current method path:C1201;"Import";"error";"duplicate for set record name "+$vt_ImportOps_SetListPopupSetNam)
	Else 
		$vl_setID:=[Sets:1]ID:1
		  // One match. Good. 
		  //[Sets]ID:=Sequence number([Sets])
		  //[Sets]Name:=vt_NewConfigSetName
		[Sets:1]Category:18:=sh_arr_getCurrentValue (->at_ImportSetCategory)
		[Sets:1]Shared_YN:17:=(sh_arr_getCurrentValue (->at_ImportSet_PrivateOrShared)="Shared")
		[Sets:1]Description:3:=vt_NewConfigSetDescription
		[Sets:1]ChangeControl_Note:6:=vt_NewConfigSet_ChangeControl
		  //[Sets]CreatedBy:=Current user
		  //[Sets]CreatedDate:=Current date(*)
		  //[Sets]CreatedTime:=Current time(*)
		[Sets:1]LastModifiedDate:5:=Current date:C33(*)
		[Sets:1]LastModifiedTime:9:=Current time:C178(*)
		[Sets:1]Approval_Requested:14:=(vl_ImportReqApprovalCheckbox=1)
		[Sets:1]Approved_Date:12:=Date:C102("00/00/00")
		[Sets:1]Approved_Time:13:=?00:00:00?
		[Sets:1]ApprovedBy_User:11:=""
		  //[Sets]CreatedBy:=<>vt_currentUser
		[Sets:1]LastModifiedBy:15:=<>vt_currentUser
		SAVE RECORD:C53([Sets:1])
		
		Import_UpdateExistingSet_Prep ([Sets:1]Name:2;$vl_setID)
		
End case 

$0:=$vl_setID
