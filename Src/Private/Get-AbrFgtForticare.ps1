
function Get-AbrFgtForticare {
    <#
    .SYNOPSIS
        Used by As Built Report to returns FortiCare settings.
    .DESCRIPTION
        Documents the configuration of Fortinet Fortigate in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         Alexis La Goutte
        Twitter:        @alagoutte
        Github:         alagoutte
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.Fortigate
    #>
    [CmdletBinding()]
    param (

    )

    begin {
        Write-PscriboMessage "Discovering Forticare settings information from $System."
    }

    process {

        Section -Style Heading2 'FortiCare ' {
            Paragraph "The following section details Forticare settings configured on Fortigate."
            BlankLine

            $OutObj = @()
            $Forticare = (Get-FGTMonitorLicenseStatus).forticare
            $Serial = $DefaultFGTConnection.serial

            $OutObj = [pscustomobject]@{
                "Model"   = $Model
                "Serial"  = $Serial
                "Status"  = $Forticare.status
                "Account" = $Forticare.account.ToLower()
                "Company" = $Forticare.company
            }

            $TableParams = @{
                Name = "FortiCare"
                List = $true
            }

            $OutObj | Table @TableParams
        }
    }

    end {

    }

}