# Hashtable is Dictionary
$settings = @{
    "AppName" = "App1"
    "version" = "1.0.0"
    "maxusers" = 100
}
# Retrieve the value 
# $settings["appname", "version"]

# To change the value in the HashTable
# $settings["version"] = "2.0.0"
# $settings["version"]

# To Loop through the HashTable
#foreach($i in $settings){
#    $i
#}

$settings.ContainsKey("version")
