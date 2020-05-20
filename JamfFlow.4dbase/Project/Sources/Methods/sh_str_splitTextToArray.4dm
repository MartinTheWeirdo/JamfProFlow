//%attributes = {}
  // sh_str_splitTextToArray
  // sh_str_splitTextToArray($vt_ArrayText;$pa_TextArray)

$vt_ArrayText:=$1
$pa_TextArray:=$2

C_COLLECTION:C1488($ct_TextItems)
$ct_TextItems:=Split string:C1554($vt_ArrayText;"\r")
COLLECTION TO ARRAY:C1562($ct_TextItems;$pa_TextArray->)
