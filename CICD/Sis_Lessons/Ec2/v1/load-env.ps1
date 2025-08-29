Get-Content .env | ForEach-Object {
    $key, $value = $_.Split('=')
    [System.Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim())
}