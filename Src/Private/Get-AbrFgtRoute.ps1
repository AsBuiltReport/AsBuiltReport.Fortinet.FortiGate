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
            $BGPNeighbors = Get-FGTMonitorRouterBGPNeighbors
            $BGP = Get-FGTRouterBGP
            $BGPSchema = (Invoke-FGTRestMethod 'api/v2/cmdb/router/bgp?&action=schema').results.children
            $OSPFNeighbors = Get-FGTMonitorRouterOSPFNeighbors
            $OSPF = Get-FGTRouterOSPF
            $OSPFSchema = (Invoke-FGTRestMethod 'api/v2/cmdb/router/ospf?&action=schema').results.children

            if ($InfoLevel.Route -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section provides a summary of route settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "Monitor Route" = @($MonitorRouterIPv4).count
                        "Static Route" = @($Statics).count
                        "Policy Based Route" = @($PolicyBasedRouting).count
                    }

                    $TableParams = @{
                        Name = "Summary"
                        List = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($MonitorRouterIPv4 -and $InfoLevel.Route -ge 1) {
                Section -Style Heading3 'Route Monitor' {
                    $OutObj = @()

                    foreach ($route in $MonitorRouterIPv4) {

                        #when there is blackhole, interface is set to Null
                        if ("Null" -eq $route.interface) {
                            $interface = "Blackhole"
                        } else {
                            $interface = $route.interface
                        }

                        $OutObj += [pscustomobject]@{
                            "Type" = $route.type
                            "IP/Mask" = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $route.ip_mask } else { $route.ip_mask })
                            "Gateway" = $route.gateway
                            "Interface" = $interface
                            "Distance/Metric/Priority" = "$($route.distance) / $($route.metric) / $($route.priority)"
                        }
                    }

                    $TableParams = @{
                        Name = "Route Monitor"
                        List = $false
                        ColumnWidths = 15, 25, 20, 20, 20
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($Statics -and $InfoLevel.Route -ge 1) {
                Section -Style Heading3 'Static Route' {
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
                            $dst = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $static.dst } else { $static.dst })
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
                            "Status" = $static.status
                            "Destination" = $dst
                            "Gateway" = $static.gateway
                            "Interface" = $interface
                            "Distance/Weight/Priority" = "$($static.distance) / $($static.weight) / $($static.priority)"
                        }
                    }

                    $TableParams = @{
                        Name = "Static Route"
                        List = $false
                        ColumnWidths = 15, 25, 20, 20, 20
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($PolicyBasedRouting -and $InfoLevel.Route -ge 1) {
                Section -Style Heading3 'Policy Based Route' {
                    $OutObj = @()

                    foreach ($pbr in $PolicyBasedRouting) {

                        if ($pbr.src) {
                            $src = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $pbr.src.subnet } else { $pbr.src.subnet })
                        } else {
                            $src = $pbr.srcaddr.name
                        }
                        if ($pbr.dst) {
                            $dst = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $pbr.dst.subnet } else { $pbr.dst.subnet })
                        } else {
                            $dst = $pbr.dstaddr.name
                        }

                        $OutObj += [pscustomobject]@{
                            "Status" = $pbr.status
                            "Protocol" = $pbr.protocol
                            "From" = $pbr.'input-device'.name
                            "To" = $pbr.'ouput-device'
                            "Source" = $src
                            "Destination" = $dst
                            "Gateway" = $pbr.gateway
                            "Action" = $pbr.action
                        }
                    }

                    $TableParams = @{
                        Name = "Policy Based Route"
                        List = $false
                        ColumnWidths = 10, 12, 13, 13, 13, 13, 13, 13
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            #There is always BGP config, only display if router-id is configured
            if ($BGP.'router-id' -and $InfoLevel.Route -ge 1) {
                Section -Style Heading3 'BGP' {

                    Section -Style Heading3 'Summary' {
                        Paragraph "The following section provides a summary of BGP settings."
                        BlankLine
                        $OutObj = [pscustomobject]@{
                            "BGP Neighbor" = @($BGP.neighbor).count
                            "BGP Neighbor Group" = @($BGP.'neighbor-group').count
                            "BGP Neighbor Range" = @($BGP.'neighbor-range').count
                            "BGP Network" = @($BGP.network).count
                            "BGP Neighbors Status" = @($BGPNeighbors).count
                        }

                        $TableParams = @{
                            Name = "Summary"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    Section -Style Heading3 'Configuration' {
                        $OutObj = @()

                        foreach ($properties in $BGP.PSObject.properties) {
                            #Skip System Object array (manually display after like Neighbor, network...)
                            if ($properties.typeNameOfValue -eq "System.Object[]") {
                                continue
                            }
                            $name = $properties.name
                            $value = [string]$properties.value
                            #Check the schema of $value
                            if ($BGPSchema.PSObject.Properties.Name -contains $name) {
                                #found the default value
                                $default = $BGPSchema.$name.default
                                if ($null -eq $default) {
                                    $default = ""
                                }
                            }
                            $OutObj += [pscustomobject]@{
                                "Name" = $name
                                "Value" = $value
                                "Default" = $default
                            }
                        }

                        $TableParams = @{
                            Name = "BGP Configuration"
                            List = $false
                            ColumnWidths = 34, 33, 33
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Where-Object { $_.value -ne $_.default } | Set-Style -Style Critical
                        $OutObj | Table @TableParams
                    }

                    if ($BGP.'neighbor') {

                        $neighbor = $BGP.'neighbor'
                        Section -Style Heading3 'Neighbor' {
                            Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                                $OutObj = @()

                                foreach ($n in $neighbor) {

                                    $OutObj += [pscustomobject]@{
                                        "IP" = $n.ip
                                        "Remote AS" = $n.'remote-as'
                                        "Description" = $n.description
                                        "Activate" = $n.activate
                                    }
                                }

                                $TableParams = @{
                                    Name = "BGP Neighbor"
                                    List = $false
                                    ColumnWidths = 25, 25, 25, 25
                                }

                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }

                                $OutObj | Table @TableParams
                            }

                            if ($InfoLevel.Route -ge 2) {

                                foreach ($n in $neighbor) {

                                    Section -Style NOTOCHeading4 -ExcludeFromTOC "Neighbor : $($n.ip)" {

                                        $OutObj = @()

                                        foreach ($properties in $n.PSObject.properties) {

                                            #Skip System Object array
                                            if ($properties.typeNameOfValue -eq "System.Object[]") {
                                                continue
                                            }
                                            #Skip q_origin_key properties (Fortigate internal and equal to name)
                                            if ($properties.name -eq "q_origin_key") {
                                                continue
                                            }
                                            $name = $properties.name
                                            $value = [string]$properties.value
                                            #Check the schema of $value
                                            if ($BGPSchema.'neighbor'.children.PSObject.Properties.Name -contains $name) {
                                                #found the default value
                                                $default = $BGPSchema.'neighbor'.children.$name.default
                                                #if default is null set empty value (some field don't have defaut parameter)
                                                if ($null -eq $default) {
                                                    $default = ""
                                                }
                                            }
                                            $OutObj += [pscustomobject]@{
                                                "Name" = $name
                                                "Value" = $value
                                                "Default" = $default
                                            }
                                        }

                                        $TableParams = @{
                                            Name = "BGP Neighbor Configuration $($n.ip)"
                                            List = $false
                                            ColumnWidths = 34, 33, 33
                                        }

                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }

                                        $OutObj | Where-Object { $_.value -ne $_.default } | Set-Style -Style Critical
                                        $OutObj | Table @TableParams
                                    }
                                }
                            }

                        }
                    }

                    if ($BGP.'neighbor-group') {

                        $neighborgroup = $BGP.'neighbor-group'
                        Section -Style Heading3 'Neighbor Group' {
                            Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                                $OutObj = @()

                                foreach ($n in $neighborgroup) {

                                    $OutObj += [pscustomobject]@{
                                        "Name" = $n.name
                                        "Remote AS" = $n.'remote-as'
                                        "Description" = $n.description
                                        "Activate" = $n.activate
                                    }
                                }

                                $TableParams = @{
                                    Name = "BGP Neighbor Group"
                                    List = $false
                                    ColumnWidths = 25, 25, 25, 25
                                }

                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }

                                $OutObj | Table @TableParams
                            }

                            if ($InfoLevel.Route -ge 2) {

                                foreach ($n in $neighborgroup) {

                                    Section -Style NOTOCHeading4 -ExcludeFromTOC "Neighbor Group : $($n.name)" {

                                        $OutObj = @()

                                        foreach ($properties in $n.PSObject.properties) {

                                            #Skip System Object array
                                            if ($properties.typeNameOfValue -eq "System.Object[]") {
                                                continue
                                            }
                                            #Skip q_origin_key properties (Fortigate internal and equal to name)
                                            if ($properties.name -eq "q_origin_key") {
                                                continue
                                            }
                                            $name = $properties.name
                                            $value = [string]$properties.value
                                            #Check the schema of $value
                                            if ($BGPSchema.'neighbor-group'.children.PSObject.Properties.Name -contains $name) {
                                                #found the default value
                                                $default = $BGPSchema.'neighbor-group'.children.$name.default
                                                #if default is null set empty value (some field don't have defaut parameter)
                                                if ($null -eq $default) {
                                                    $default = ""
                                                }
                                            }
                                            $OutObj += [pscustomobject]@{
                                                "Name" = $name
                                                "Value" = $value
                                                "Default" = $default
                                            }
                                        }

                                        $TableParams = @{
                                            Name = "BGP Neighbor Group Configuration $($n.name)"
                                            List = $false
                                            ColumnWidths = 34, 33, 33
                                        }

                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }

                                        $OutObj | Where-Object { $_.value -NE $_.default } | Set-Style -Style Critical
                                        $OutObj | Table @TableParams
                                    }
                                }
                            }

                        }
                    }

                    if ($BGP.'neighbor-range') {

                        $neighborrange = $BGP.'neighbor-range'
                        Section -Style Heading3 'Neighbor Range' {
                            $OutObj = @()

                            foreach ($n in $neighborrange) {

                                $OutObj += [pscustomobject]@{
                                    "id" = $n.id
                                    "Prefix" = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $n.prefix } else { $n.prefix })
                                    "Neighbor Group" = $n.'neighbor-group'
                                    "Max Neighbor Num  " = $n.'max-neighbor-num'
                                }
                            }

                            $TableParams = @{
                                Name = "BGP Neighbor Range"
                                List = $false
                                ColumnWidths = 10, 35, 30, 25
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }

                    }

                    if ($BGP.network) {

                        $neighbornetwork = $BGP.network
                        Section -Style Heading3 'Network' {
                            $OutObj = @()

                            foreach ($n in $neighbornetwork) {

                                $OutObj += [pscustomobject]@{
                                    "id" = $n.id
                                    "Prefix " = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $n.prefix } else { $n.prefix })
                                    "Network-import-check" = $n.'network-import-check'
                                    "Backdoor" = $n.backdoor
                                    "Route-map" = $n.'route-map'
                                }
                            }

                            $TableParams = @{
                                Name = "BGP Network"
                                List = $false
                                ColumnWidths = 10, 35, 24, 11, 20
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }

                    }

                    if ($BGP.redistribute) {

                        $redistribute = $BGP.redistribute
                        Section -Style Heading3 'Redistribute' {
                            $OutObj = @()

                            foreach ($r in $redistribute) {

                                $OutObj += [pscustomobject]@{
                                    "Name" = $r.name
                                    "Status" = $r.status
                                    "Route-map" = $r.'route-map'
                                }
                            }

                            $TableParams = @{
                                Name = "BGP Redistribute"
                                List = $false
                                ColumnWidths = 40, 30, 30
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Where-Object { $_.status -eq "enable" } | Set-Style -Style OK
                            $OutObj | Table @TableParams
                        }

                    }

                    if ($BGPNeighbors) {

                        Section -Style Heading3 'BGP Neighbor Status' {
                            $OutObj = @()

                            foreach ($n in $BGPNeighbors) {

                                $OutObj += [pscustomobject]@{
                                    "Neighbor IP" = $n.neighbor_ip
                                    "Local IP" = $n.local_ip
                                    "Remote AS" = $n.remote_as
                                    "Admin status" = $n.admin_status
                                    "State" = $n.state
                                    "type" = $n.type
                                }
                            }

                            $TableParams = @{
                                Name = "BGP Neighbor Status"
                                List = $false
                                ColumnWidths = 15, 15, 15, 25, 15, 15
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Where-Object { $_.state -ne "Established" } | Set-Style -Style Critical
                            $OutObj | Where-Object { $_.'Admin Status' -ne "True" } | Set-Style -Style Warning
                            $OutObj | Table @TableParams
                        }

                    }

                }

            }

            #There is always OSPF config, only display if router-id not 0.0.0.0 (not configured)
            if ($OSPF.'router-id' -ne "0.0.0.0" -and $InfoLevel.Route -ge 1) {
                Section -Style Heading3 'OSPF' {

                    Section -Style Heading3 'Summary' {
                        Paragraph "The following section provides a summary of OSPF settings."
                        BlankLine
                        $OutObj = [pscustomobject]@{
                            "OSPF Area" = @($OSPF.area).count
                            "OSPF Interface" = @($OSPF.'ospf-interface').count
                            "OSPF Network" = @($OSPF.network).count
                            "OSPF Summary Address" = @($OSPF.'summary-address').count
                            "OSPF Neighbors Status" = @($OSPFNeighbors).count
                        }

                        $TableParams = @{
                            Name = "Summary"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    Section -Style Heading3 'Configuration' {
                        $OutObj = @()

                        foreach ($properties in $OSPF.PSObject.properties) {
                            #Skip System Object array (manually display after like Neighbor, network...)
                            if ($properties.typeNameOfValue -eq "System.Object[]") {
                                continue
                            }
                            $name = $properties.name
                            $value = [string]$properties.value
                            #Check the schema of $value
                            if ($OSPFSchema.PSObject.Properties.Name -contains $name) {
                                #found the default value
                                $default = $OSPFSchema.$name.default
                                if ($null -eq $default) {
                                    $default = ""
                                }
                            }
                            $OutObj += [pscustomobject]@{
                                "Name" = $name
                                "Value" = $value
                                "Default" = $default
                            }
                        }

                        $TableParams = @{
                            Name = "OSPF Configuration"
                            List = $false
                            ColumnWidths = 34, 33, 33
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Where-Object { $_.value -ne $_.default } | Set-Style -Style Critical
                        $OutObj | Table @TableParams
                    }
                }

                if ($OSPF.area) {

                    $area = $OSPF.area
                    Section -Style Heading3 'Area' {
                        Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                            $OutObj = @()

                            foreach ($a in $area) {

                                $OutObj += [pscustomobject]@{
                                    "ID" = $a.id
                                    "Type" = $a.type
                                    "Authentication" = $a.authentication
                                }
                            }

                            $TableParams = @{
                                Name = "OSPF Area"
                                List = $false
                                ColumnWidths = 34, 33, 33
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }

                        if ($InfoLevel.Route -ge 2) {

                            foreach ($a in $area) {

                                Section -Style NOTOCHeading4 -ExcludeFromTOC "Area : $($a.id)" {

                                    $OutObj = @()

                                    foreach ($properties in $a.PSObject.properties) {

                                        #Skip System Object array
                                        if ($properties.typeNameOfValue -eq "System.Object[]") {
                                            continue
                                        }
                                        #Skip q_origin_key properties (Fortigate internal and equal to name)
                                        if ($properties.name -eq "q_origin_key") {
                                            continue
                                        }
                                        $name = $properties.name
                                        $value = [string]$properties.value
                                        #Check the schema of $value
                                        if ($OSPFSchema.'area'.children.PSObject.Properties.Name -contains $name) {
                                            #found the default value
                                            $default = $OSPFSchema.'area'.children.$name.default
                                            #if default is null set empty value (some field don't have defaut parameter)
                                            if ($null -eq $default) {
                                                $default = ""
                                            }
                                        }
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $name
                                            "Value" = $value
                                            "Default" = $default
                                        }
                                    }

                                    $TableParams = @{
                                        Name = "OSPF Area Configuration $($a.id)"
                                        List = $false
                                        ColumnWidths = 34, 33, 33
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }

                                    $OutObj | Where-Object { $_.value -ne $_.default } | Set-Style -Style Critical
                                    $OutObj | Table @TableParams
                                }
                            }
                        }

                    }
                }

                if ($OSPF.'ospf-interface') {

                    $interface = $OSPF.'ospf-interface'
                    Section -Style Heading3 'Interface' {
                        Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                            $OutObj = @()

                            foreach ($i in $interface) {

                                $OutObj += [pscustomobject]@{
                                    "Name" = $i.name
                                    "Interface" = $i.interface
                                    "Cost" = $i.cost
                                    "Authentification" = $i.authentication
                                    "Status" = $i.status
                                }
                            }

                            $TableParams = @{
                                Name = "OSPF Interface"
                                List = $false
                                ColumnWidths = 20, 20, 20, 20, 20
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }

                        if ($InfoLevel.Route -ge 2) {

                            foreach ($i in $interface) {

                                Section -Style NOTOCHeading4 -ExcludeFromTOC "Interface : $($i.name)" {

                                    $OutObj = @()

                                    foreach ($properties in $i.PSObject.properties) {

                                        #Skip System Object array
                                        if ($properties.typeNameOfValue -eq "System.Object[]") {
                                            continue
                                        }
                                        #Skip q_origin_key properties (Fortigate internal and equal to name)
                                        if ($properties.name -eq "q_origin_key") {
                                            continue
                                        }
                                        $name = $properties.name
                                        $value = [string]$properties.value
                                        #Check the schema of $value
                                        if ($OSPFSchema.'ospf-interface'.children.PSObject.Properties.Name -contains $name) {
                                            #found the default value
                                            $default = $OSPFSchema.'ospf-interface'.children.$name.default
                                            #if default is null set empty value (some field don't have defaut parameter)
                                            if ($null -eq $default) {
                                                $default = ""
                                            }
                                        }
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $name
                                            "Value" = $value
                                            "Default" = $default
                                        }
                                    }

                                    $TableParams = @{
                                        Name = "OSPF Interface Configuration $($i.Name)"
                                        List = $false
                                        ColumnWidths = 34, 33, 33
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }

                                    $OutObj | Where-Object { $_.value -ne $_.default } | Set-Style -Style Critical
                                    $OutObj | Table @TableParams
                                }
                            }
                        }
                    }

                }

                if ($OSPF.network) {

                    $network = $OSPF.network
                    Section -Style Heading3 'Network' {
                        Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                            $OutObj = @()

                            foreach ($n in $network) {

                                $OutObj += [pscustomobject]@{
                                    "ID" = $n.id
                                    "Area" = $n.area
                                    "Prefix" = $n.prefix
                                    "Comments" = $n.coments
                                }
                            }

                            $TableParams = @{
                                Name = "OSPF Network"
                                List = $false
                                ColumnWidths = 10, 25, 25, 40
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }


                    }
                }

                if ($OSPF.'summary-address') {

                    $summary_address = $OSPF.network
                    Section -Style Heading3 'Summmary Address' {
                        Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                            $OutObj = @()

                            foreach ($sa in $summary_address) {

                                $OutObj += [pscustomobject]@{
                                    "ID" = $sa.id
                                    "Prefix" = $sa.prefix
                                    "Tag" = $sa.tag
                                    "Advertise" = $sa.advertise
                                }
                            }

                            $TableParams = @{
                                Name = "OSPF Summary Address"
                                List = $false
                                ColumnWidths = 10, 30, 30, 30
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }


                    }
                }

                if ($OSPF.redistribute) {

                    $redistribute = $OSPF.redistribute
                    Section -Style Heading3 'Redistribute' {
                        $OutObj = @()

                        foreach ($r in $redistribute) {

                            $OutObj += [pscustomobject]@{
                                "Name" = $r.name
                                "Status" = $r.status
                                "Metric" = $r.metric
                                "Metric Type" = $r.'metric-type'
                                "Route-map" = $r.'route-map'
                                "Tag" = $r.tag
                            }
                        }

                        $TableParams = @{
                            Name = "OSPF Redistribute"
                            List = $false
                            ColumnWidths = 15, 15, 15, 15, 25, 15
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Where-Object { $_.status -eq "enable" } | Set-Style -Style OK
                        $OutObj | Table @TableParams
                    }

                }

                if ($OSPFNeighbors) {

                    Section -Style Heading3 'OSPF Neighbor Status' {
                        $OutObj = @()

                        foreach ($n in $OSPFNeighbors) {

                            $OutObj += [pscustomobject]@{
                                "Neighbor IP" = $n.neighbor_ip
                                "Router ID" = $n.router_id
                                "State" = $n.state
                                "Priority" = $n.priority
                            }
                        }

                        $TableParams = @{
                            Name = "OSPF Neighbor Status"
                            List = $false
                            ColumnWidths = 25, 25, 25, 25
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Where-Object { $_.state -ne "Full" } | Set-Style -Style Critical
                        $OutObj | Table @TableParams
                    }

                }

            }

        }
    }

    end {

    }

}