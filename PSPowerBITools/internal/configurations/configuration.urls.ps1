# Default URL for Apps
$configParams = @{
    Module      = 'PSPowerBITools'
    Name        = 'URL.Apps'
    Value       = "https://api.powerbi.com/v1.0/___ORG___/admin/apps"
    Initialize  = $true
    Validation  = 'string'
    Description = "API URL for Apps"
}
Set-PSFConfig @configParams

# Default URL for Apps Users
$configParams = @{
    Module      = 'PSPowerBITools'
    Name        = 'URL.Apps.Users'
    Value       = "https://api.powerbi.com/v1.0/___ORG___/admin/apps/___APPID___/users"
    Initialize  = $true
    Validation  = 'string'
    Description = "API URL for Apps Users"
}
Set-PSFConfig @configParams



