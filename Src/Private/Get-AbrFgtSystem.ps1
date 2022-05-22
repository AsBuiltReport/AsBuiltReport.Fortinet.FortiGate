
function Get-AbrFgtSystem {
    <#
    .SYNOPSIS
        Used by As Built Report to returns System settings.
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
        Write-PscriboMessage "Discovering System settings information from $System."
    }

    process {

        Section -Style Heading2 'System' {
            Paragraph "The following section details System settings configured on Fortigate."
            BlankLine

            Section -Style Heading3 'Global' {
                $OutObj = @()

                $info = Get-FGTSystemGlobal | Select-Object hostname, alias, daily-restart, restart-time, admin-port, admin-sport, admin-https-redirect, admin-ssh-port

                if ($info.'daily-restart' -eq "enable") {
                    $reboot = "Everyday at $($info.'restart-time')"
                }
                else {
                    $reboot = "disable"
                }

                $OutObj = [pscustomobject]@{
                    "Nom"           = $info.'hostname'
                    "Alias"         = $info.'alias'
                    "Reboot"        = $reboot
                    "Port SSH"      = $info.'admin-ssh-port'
                    "Port HTTP"     = $info.'admin-port'
                    "Port HTTPS"    = $info.'admin-sport'
                    "HTTPS Rediect" = $info.'admin-https-redirect'
                }

                $TableParams = @{
                    Name = "Global"
                    List = $true
                }

                $OutObj | Table @TableParams
            }
        }
    }

    end {

    }

}