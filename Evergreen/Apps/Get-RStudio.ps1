Function Get-RStudio {
    <#
        .SYNOPSIS
            Returns the available RStudio version and download URI.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
            Based on Get-AtlassianBitbucket.ps1
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the update URI
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Content = Invoke-RestMethodWrapper @params

    # Read the JSON and build an array of platform, channel, version
    If ($Null -ne $Content) {

        # Match version number
        try {
            $Lines = $Content -split "\n"
            $Version = [RegEx]::Match($Lines[0], $res.Get.Update.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            $Version = "Unknown"
        }

        # Step through each installer type
        ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {

            # Build the output object; Output object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $Version
                Type    = $item.Name
                URI     = $res.Get.Download.Uri[$item.Key] -replace $res.Get.Download.ReplaceText, $Version
            }
            Write-Output -InputObject $PSObject
        }
    }
}
