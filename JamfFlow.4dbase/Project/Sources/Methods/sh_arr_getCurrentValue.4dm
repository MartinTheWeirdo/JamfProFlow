//%attributes = {}
  // sh_arr_getCurrentValue

C_POINTER:C301($1;$pas_pointerToStringArray)
C_TEXT:C284($0;$vt_arrCurrentValue)
C_LONGINT:C283($2;$vl_arrayIndex;$vl_sizeOfArray)

$pas_pointerToStringArray:=$1

Case of 
	: (Count parameters:C259=1)
		$vl_arrayIndex:=$pas_pointerToStringArray->
	: (Count parameters:C259=2)
		$vl_arrayIndex:=$2
	Else 
		  // Error!
End case 

$vl_sizeOfArray:=Size of array:C274($pas_pointerToStringArray->)

If (($vl_arrayIndex>0) & ($vl_arrayIndex<=$vl_sizeOfArray))
	$vt_arrCurrentValue:=$pas_pointerToStringArray->{$vl_arrayIndex}
Else 
	$vt_arrCurrentValue:=""
End if 

$0:=$vt_arrCurrentValue