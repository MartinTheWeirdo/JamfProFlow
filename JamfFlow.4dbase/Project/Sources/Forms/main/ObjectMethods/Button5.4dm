Case of 
	: (Records in set:C195("$set_ManageSetsListbox")>1)
		sh_msg_Alert ("Please highlight just one record")
	: (Records in set:C195("$set_ManageSetsListbox")=0)
		sh_msg_Alert ("Please highlight a record you want to delete")
		
	: (Records in set:C195("$set_ManageSetsListbox")=1)
		
		If (Macintosh option down:C545)
			$vb_Yes:=True:C214
		Else 
			$vt_msg:="Are you sure you want to delete the selected record?"
			$vb_Yes:=sh_msg_Alert ($vt_msg;"Yes";"No")
		End if 
		
		If ($vb_Yes)
			USE SET:C118("$set_ManageSetsListbox")
			QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
			DELETE SELECTION:C66([XML:2])
			DELETE SELECTION:C66([Sets:1])
			ALL RECORDS:C47([Sets:1])
			  // QUERY([XML];[XML]set_id=[Sets]ID)
			ORDER BY:C49([Sets:1];[Sets:1]LastModifiedDate:5;<;[Sets:1]LastModifiedTime:9;<)
		End if 
End case 
