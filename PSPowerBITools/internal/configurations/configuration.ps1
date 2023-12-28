<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
Set-PSFConfig -Module 'PSPowerBITools' -Name 'Example.Setting' -Value 10 -Initialize -Validation 'integer' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>

# Whether the module files should be dotsourced on import.
$configParams = @{
    Module      = 'PSPowerBITools'
    Name        = 'Import.DoDotSource'
    Value       = $false
    Initialize  = $true
    Validation  = 'bool'
    Description = "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
}
Set-PSFConfig @configParams

# Whether the module files should be imported individually.
$configParams = @{
    Module      = 'PSPowerBITools'
    Name        = 'Import.IndividualFiles'
    Value       = $false
    Initialize  = $true
    Validation  = 'bool'
    Description = "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."
}
Set-PSFConfig @configParams

# Reload the login of Power BI
$configParams = @{
    Module      = 'PSPowerBITools'
    Name        = 'Login.Reload'
    Value       = $false
    Initialize  = $true
    Validation  = 'bool'
    Description = "Whether the login of Power BI should be reloaded. By default, the login is only loaded once per session. This can be used to force a reload of the login."
}
Set-PSFConfig @configParams

