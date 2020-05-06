//%attributes = {}
  // sh_str_dq
  // Wrap input in double-quotes
C_TEXT:C284($1;$0)

  //If (Undefined($1))
  //$vt:=""
  //Else 
$vt:=$1
  //End if 

$0:=Char:C90(Double quote:K15:41)+$1+Char:C90(Double quote:K15:41)