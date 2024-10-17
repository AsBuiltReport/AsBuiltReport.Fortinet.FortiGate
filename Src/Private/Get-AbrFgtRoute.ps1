
function Get-AbrFgtRoute {
    <#
    .SYNOPSIS
        Used by As Built Report to returns Route settings.
    .DESCRIPTION
        Documents the configuration of Fortinet FortiGate in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         Alexis La Goutte
        Twitter:        @alagoutte
        Github:         alagoutte
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate
    #>
    [CmdletBinding()]
    param (

    )

    begin {
        Write-PScriboMessage "Discovering route settings information from $System."
    }

    process {

        Section -Style Heading2 'Route' {
            Paragraph "The following section details route settings configured on FortiGate."
            BlankLine

            $MonitorRouterIPv4 = Get-FGTMonitorRouterIPv4
            $Statics = Get-FGTRouterStatic
            $PolicyBasedRouting = Get-FGTRouterPolicy

            if ($InfoLevel.Route -ge 1) {
                $tableName = "Summary"
                Section -Style Heading3 $tableName {
                    Paragraph "The following section provides a summary of route settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "Monitor Route"      = @($MonitorRouterIPv4).count
                        "Static Route"       = @($Statics).count
                        "Policy Based Route" = @($PolicyBasedRouting).count
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                }
            }

            if ($MonitorRouterIPv4 -and $InfoLevel.Route -ge 1) {
                $tableName = "Route Monitor"
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    foreach ($route in $MonitorRouterIPv4) {

                        #when there is blackhole, interface is set to Null
                        if ("Null" -eq $route.interface) {
                            $interface = "Blackhole"
                        }
                        else {
                            $interface = $route.interface
                        }

                        $OutObj += [pscustomobject]@{
                            "Type"                     = $route.type
                            "IP/Mask"                  = $route.ip_mask
                            "Gateway"                  = $route.gateway
                            "Interface"                = $interface
                            "Distance/Metric/Priority" = "$($route.distance) / $($route.metric) / $($route.priority)"
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Type" = 15; "IP/Mask" = 25;}
                }
            }

            if ($Statics -and $InfoLevel.Route -ge 1) {
                $tableName = "Static Route"
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    foreach ($static in $statics) {

                        #if using Address object on static route Destination, display the named object
                        if ($static.dstaddr) {
                            $dst = $static.dstaddr
                        }
                        #if using Internet Service (ISDB)...
                        elseif ($static.'internet-service') {
                            #TODO: add Lookup, only display the id...
                            $dst = $static.'internet-service'
                        } else {
                            $dst = $($static.dst | ConvertTo-CIDR)
                        }

                        #when Blackhole is enable, display blackhole for interface
                        if ($static.blackhole -eq "enable") {
                            $interface = "Blackhole"
                        } elseif ($static.device -eq "") {
                            #No device => SD-Wan (Zone)
                            $interface = $static.'sdwan-zone'.name
                        } else {
                            $interface = $static.device
                        }

                        $OutObj += [pscustomobject]@{
                            "Status"                   = $static.status
                            "Destination"              = $dst
                            "Gateway"                  = $static.gateway
                            "Interface"                = $interface
                            "Distance/Weight/Priority" = "$($static.distance) / $($static.weight) / $($static.priority)"
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Status" = 15; "Destination" = 25;}
                }
            }

            if ($PolicyBasedRouting -and $InfoLevel.Route -ge 1) {
                Section -Style Heading3 'Policy Based Route' {
                    $OutObj = @()

                    foreach ($pbr in $PolicyBasedRouting) {

                        if ($pbr.src) {
                            $src = $($pbr.src.subnet | ConvertTo-CIDR)
                        }
                        else {
                            $src = $pbr.srcaddr.name
                        }
                        if ($pbr.dst) {
                            $dst = $($pbr.dst.subnet | ConvertTo-CIDR)
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
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName
                }
            }

        }
    }

    end {

    }

}