$vt:=""
$vt:=$vt+"When we are pushing items to a target Jamf Pro, we need to see if the item already exists. "
$vt:=$vt+"The JSS ID may be different than the source JamfPro. So we need a unique name. This is usually "
$vt:=$vt+"the name of the item, but for devices, we use serial number since those should be unique. "
$vt:=$vt+"Does not apply to singletons. "
$vt:=$vt+"This is probably the same as the first line of the uniqueness constraint xpath list."
sh_msg_Alert ($vt)