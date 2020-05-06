//%attributes = {}
  // Import_CreateNewSet

CREATE RECORD:C68([Sets:1])
[Sets:1]ID:1:=Sequence number:C244([Sets:1])
[Sets:1]Name:2:=vt_NewConfigSetName
[Sets:1]Category:18:=sh_arr_getCurrentValue (->at_ImportSetCategory)
[Sets:1]Shared_YN:17:=(sh_arr_getCurrentValue (->at_ImportSet_PrivateOrShared)="Shared")
[Sets:1]Description:3:=vt_NewConfigSetDescription
[Sets:1]ChangeControl_Note:6:=vt_NewConfigSet_ChangeControl
[Sets:1]CreatedBy:8:=Current user:C182
[Sets:1]CreatedDate:7:=Current date:C33(*)
[Sets:1]CreatedTime:10:=Current time:C178(*)
[Sets:1]LastModifiedDate:5:=Current date:C33(*)
[Sets:1]LastModifiedTime:9:=Current time:C178(*)
[Sets:1]Approval_Requested:14:=(vl_ImportReqApprovalCheckbox=1)
[Sets:1]Approved_Date:12:=Date:C102("00/00/00")
[Sets:1]Approved_Time:13:=?00:00:00?
[Sets:1]ApprovedBy_User:11:=""
[Sets:1]CreatedBy:8:=<>vt_currentUser
[Sets:1]LastModifiedBy:15:=<>vt_currentUser
SAVE RECORD:C53([Sets:1])

$0:=[Sets:1]ID:1