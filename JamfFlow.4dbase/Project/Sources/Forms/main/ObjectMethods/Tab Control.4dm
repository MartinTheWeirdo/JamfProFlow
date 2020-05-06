Case of 
	: (Form event code:C388=On Clicked:K2:4)
		
		Case of 
			: (at_MainTabControl=2)
				ALL RECORDS:C47([Sets:1])
				QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
				ORDER BY:C49([Sets:1];[Sets:1]LastModifiedDate:5;<;[Sets:1]LastModifiedTime:9;<)
				
			: (at_MainTabControl=3)
				ALL RECORDS:C47([Sets:1])
				QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
				ORDER BY:C49([Sets:1];[Sets:1]LastModifiedDate:5;<;[Sets:1]LastModifiedTime:9;<)
		End case 
		
End case 
