<?

if (empty($_REQUEST["serial"]) || ($_REQUEST["serial"] != "2017"))
{
    header("HTTP/1.0 401 The serial number is not valid");
    // error message to be displayed in installer
    echo "The serial number is not valid";
}