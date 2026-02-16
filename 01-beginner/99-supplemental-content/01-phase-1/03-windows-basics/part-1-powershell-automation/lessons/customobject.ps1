# Custom Object : A custom object in PowerShell is a user-defined data structure that lets you group related information together using named properties. You can create it with [PSCustomObject] to store and organize data in a structured way, similar to a record or a simple class.
# Custom objects are useful for representing complex data structures, such as configuration settings, user profiles, or any other data that has multiple attributes.

# $person = [PSCustomObject]@{
#     FirstName = "Ganil"
#     LastName = "Batist"
#     Age = 47
#     Occupation = "DevopSec"
# }

# Accessing properties of the custom object
# $person.FirstName
# "Full Name: $($person.FirstName) $($person.LastName)"

# List of Custom Objects
$employees = @(
    [PSCustomObject]@{Name = "Alice"; Age = 45; Role = "Manager"},
    [PSCustomObject]@{Name = "Bob"; Age = 30; Role = "Developer"},
    [PSCustomObject]@{Name = "Charlie"; Age = 28; Role = "Designer"}   
)

# Iterating through the list of custom objects
foreach ($i in $employees) {
   # $i.Name
   "$($i.Name) is $($i.Age) years old and works as a $($i.Role)."
}
