
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

        $Forticare = (Get-FGTMonitorLicenseStatus).forticare

        Section -Style Heading2 'FortiCare ' {
            Paragraph "The following section details Forticare settings configured on Fortigate."
            BlankLine

            $OutObj = @()

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

            Paragraph "The following section details support settings configured on Fortigate."
            BlankLine
            $ExpiresHW = (($Forticare | Select-Object -ExpandProperty support).hardware).expires
            $SupportHW = [pscustomobject]@{
                "Type"            = "Hardware"
                "Level"           = $Forticare.support.hardware.support_level
                "Status"          = $Forticare.support.hardware.status
                "Expiration Date" = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($ExpiresHW)) | Get-Date -Format dd/MM/yyyy
            }
            $ExpiresEn = (($Forticare | Select-Object -ExpandProperty support).enhanced).expires
            $SupportEn = [pscustomobject]@{
                "Type"            = "Enhanced"
                "Level"           = $Forticare.support.enhanced.support_level
                "Status"          = $Forticare.support.enhanced.status
                "Expiration Date" = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($ExpiresEn)) | Get-Date -Format dd/MM/yyyy
            }

            $TableParams = @{
                Name = "Support"
                List = $false
            }

            $Support = @()
            $Support += $SupportHW
            $Support += $SupportEn
            $Support | Table @TableParams
        }

    }

    end {

    }

}