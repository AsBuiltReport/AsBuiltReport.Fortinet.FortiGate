
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
            $Statics = Get-FGTRouterStatic
            $PolicyBasedRouting = Get-FGTRouterPolicy

            if ($InfoLevel.Route.Summary -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section make a summary of Route settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "Monitor Route"      = $MonitorRouterIPv4.count
                        "Static Route"       = $Statics.count
                        "Policy Based Route" = $PolicyBasedRouting.count
                    }

                    $TableParams = @{
                        Name         = "Global"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($MonitorRouterIPv4 -and $InfoLevel.Route.Monitor -ge 1) {
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

            if ($Statics -and $InfoLevel.Route.Static -ge 1) {
                Section -Style Heading3 'Static Route' {
                    $OutObj = @()

                    foreach ($static in $statics) {
                        $OutObj += [pscustomobject]@{
                            "Status"                   = $static.status
                            "Destination"              = $static.dst
                            "Gateway"                  = $static.gateway
                            "Interface"                = $static.device
                            "Distance/Weight/Priority" = "$($static.distance) / $($static.weight) / $($static.priority)"
                        }
                    }

                    $TableParams = @{
                        Name         = "Static Route"
                        List         = $false
                        ColumnWidths = 15, 25, 20, 20, 20
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($Statics -and $InfoLevel.Route.Policy -ge 1) {
                Section -Style Heading3 'Policy Based Route' {
                    $OutObj = @()

                    foreach ($pbr in $PolicyBasedRouting) {

                        if ($pbr.src) {
                            $src = $pbr.src.subnet
                        }
                        else {
                            $src = $pbr.srcaddr.name
                        }
                        if ($pbr.dst) {
                            $dst = $pbr.dst.subnet
                        }
                        else {
                            $dst = $pbr.dstaddr.name
                        }

                        $OutObj += [pscustomobject]@{
                            "Status"      = $pbr.status
                            "Protocol"    = $pbr.protocol
                            "From"        = $pbr.'input-device'.name
                            "To"          = $pbr.'ouput-device'
                            "Source"      = $src
                            "Destination" = $dst
                            "Gateway"     = $pbr.gateway
                            "Action"      = $pbr.action
                        }
                    }

                    $TableParams = @{
                        Name         = "Policy Based Route"
                        List         = $false
                        ColumnWidths = 10, 12, 13, 13, 13, 13, 12, 12
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