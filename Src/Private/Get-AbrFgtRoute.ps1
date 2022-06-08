
function Get-AbrFgtRoute {
    <#
    .SYNOPSIS
        Used by As Built Report to returns Route settings.
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
        Write-PscriboMessage "Discovering Route settings information from $System."
    }

    process {

        Section -Style Heading2 'Route' {
            Paragraph "The following section details Route settings configured on Fortigate."
            BlankLine

            $MonitorRouterIPv4 = Get-FGTMonitorRouterIPv4

            Section -Style Heading3 'Summary' {

            }

            if ($MonitorRouterIPv4) {
                Section -Style Heading3 'Route' {
                    $OutObj = @()

                    foreach ($route in $MonitorRouterIPv4) {
                        $OutObj += [pscustomobject]@{
                            "Type"                     = $route.type
                            "IP/Mask"                  = $route.ip_mask
                            "Gateway"                  = $route.gateway
                            "Interface"                = $route.interface
                            "Distance/Metric/Priority" = "$($route.distance) / $($route.metric) / $($route.priority)"
                        }
                    }

                    $TableParams = @{
                        Name         = "Route"
                        List         = $false
                        ColumnWidths = 15, 25, 20, 20, 20
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

        }
    }

    end {

    }

}