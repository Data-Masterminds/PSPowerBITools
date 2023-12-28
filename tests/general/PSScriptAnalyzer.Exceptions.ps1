# List of excludes
$global:ScriptAnalyzerExcludes = @(
)

<#
	Contains list of exceptions for the PSScriptAnalyzer rule.
	Insert the file names of files that may contain them.

	Example:
	"Install-UtPatch" = @("PSReviewUnusedParameter")
#>

$global:MayContainScriptAnalyzerError = @{

}