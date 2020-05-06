Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		ARRAY TEXT:C222(at_ImportSetCategory;0)
		ALL RECORDS:C47([Tags:10])
		ORDER BY:C49([Tags:10];[Tags:10]Name:2)
		SELECTION TO ARRAY:C260([Tags:10]Name:2;at_ImportSetCategory)
		at_ImportSetCategory:=0
		APPEND TO ARRAY:C911(at_ImportSetCategory;"Add a new option...")
		
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (sh_arr_getCurrentValue (->at_ImportSetCategory)="Add a new option...")
			$vt_request:=Request:C163("Enter the new set category")
			If (OK=1)
				CREATE RECORD:C68([Tags:10])
				[Tags:10]Name:2:=$vt_request
				SAVE RECORD:C53([Tags:10])
			End if 
			APPEND TO ARRAY:C911(at_ImportSetCategory;$vt_request)
			at_ImportSetCategory:=Size of array:C274(at_ImportSetCategory)
		End if 
		
End case 
